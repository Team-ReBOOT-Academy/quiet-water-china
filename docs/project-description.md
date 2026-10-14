# Quiet Water（`quiet-water`）—— 交易策略服务意图

作者：**llnightll**  
平台：鄂木斯克国立大学教师实验台 [Teacher Trading Platform](https://omsu.7bits.it/)  
服务标识（`service`，未来的 `producer` / `strategyId`）：`quiet-water`  
脚手架技术栈：**Cangjie 1.2.0 + `cjpm` + 基于 `std.net` 的 HTTP**（本文不含实现代码，只写意图）

本文档与代码同仓库、同版本管理。覆盖作业 1：项目定义、边界、交互、组成、角色与工具。

目录：

1. [项目定义](#1-项目定义)
2. [项目边界](#2-项目边界)
3. [与外部系统的交互](#3-与外部系统的交互)
4. [方案组成](#4-方案组成)
5. [角色与职责](#5-角色与职责)
6. [工具选择](#6-工具选择)

---

## 1. 项目定义

### 名称与目的

**Quiet Water** 是学生 *strategy-service*。它位于教师平台**外部**，对一次运行中的每一根已收盘K线给出一个决策：`BUY`、`SELL` 或 `HOLD`。

本服务不是交易所、不是经纪商、也不是学生柜面。它不下单，也不计算虚拟投资组合：那是平台的职责。它的职责是**对一根K线给出决策**，并遵守事件契约。

### 待检验的交易想法

假设：在 MOEX 一分钟K线上，单纯形态（RSI 反转）会产生过多虚假入场。只有同时满足两个条件时才值得交易：

1. 已收盘K线具有**价格形态**；
2. 在近期窗口内，同类形态**成功多于失败**（成功公式 / 计数器）。

数据不足时，服务**保持沉默**。因此得名：先静水，考试通过后再出手。

算法是 **walk-forward**，每个标的三个阶段：

| 阶段 | K线 | 服务做什么 | 对外信号 |
|---|---|---|---|
| A. 收集 | `1 … N` | 累积 OHLC，在这段上计算成功公式 | 仅 `HOLD` |
| B. 考试 | `N+1 … N+K` | **不再拟合**地套用公式，并用 `M` 根之后的结果核对 | 仅 `HOLD` |
| C. 交易 | 其后 | 窗口每次滑动一根K线，重算分数，达到及格分才交易 | `BUY` / `SELL` / `HOLD` |

若实时分数下降，则打开**熔断**：重新 `HOLD`，并对接下来的 `K` 根做一次新考试。阶段 C 的每一步**不会**重复完整的 `K` 隔离，否则服务几乎永远无法入场。

**形态（确定性规则）。** RSI(14) 均值回归：

- `BUY` 候选：RSI 曾低于超卖区，且当前收盘价高于前一根收盘价；
- `SELL` 候选：RSI 曾高于超买区，且收盘价低于前一根收盘价；
- 否则没有形态 → `HOLD`。

**成功公式。** 当该形态已经出现过，观察 `M` 根K线之后的价格：

- BUY 成功，若 `close[t+M] > close[t]`；
- SELL 成功，若 `close[t+M] < close[t]`。

`successRate = successes / W`，统计最近已完成的同方向形态。

**阶段 C 的决策：**

- 有形态且 `successRate ≥ T` 且考试已通过 → 形态方向；
- 否则 → `HOLD`。

起始参数（全部来自环境变量，不在代码中写死字面量）：

| 参数 | 含义 | 起始值 |
|---|---|---|
| `N` | 训练窗口长度 | 90 |
| `K` | 考试长度 | 45 |
| `M` | 成功检查视界 | 10 |
| `W` | 计入分数的历史形态数量 | 20 |
| `T` | 及格分 | 0.55 |
| `RSI_PERIOD` | RSI 周期 | 14 |
| `RSI_OVERSOLD` / `RSI_OVERBOUGHT` | 形态区间 | 30 / 70 |

K线 `t` 的成败要到 `t+M` 才可见。考试段最后 `M` 根不计入 —— 否则就是偷看未来。

**星星（不在关键路径上）。** 推荐发出之后，后台微调可以略微移动**下一根**K线的 `confidence`（例如 ±0.05 以内）。它不改变交易方向（`BUY`/`SELL`）。数值相关与命中率由服务代码计算，不由语言模型计算。模型迟到或不可用时，贡献为零。

### 要解决的问题

平台要求对**每一根**已收盘K线给出回答，并严格绑定 `runId` / `sourceEventId` / `instrument` / `sequenceNumber`。在 1 分钟实时运行中不能：

- 每根都交易；
- 在用于评估的同一批K线上拟合公式；
- 把外部 LLM 放进决策回路（延迟、非确定性、未来幂等性）。

服务必须能保持沉默、在延迟窗口上通过考试，并且可复现。

### 目标

1. 固定服务位置：平台外部、经 Kafka、没有 UI。
2. 检验一个假设：形态 + 及格分，而不是「模型猜市场」。
3. 满足课程契约：健康检查、配置来自环境、容器、文档在 Git 中。

### 主要任务

1. 按标的保存自己的K线窗口与阶段（`LEARN` / `EXAM` / `TRADE` / `HALT`）。
2. 计算 RSI 形态与滚动 `successRate`，不偷看未来。
3. 按平台契约为每根K线发布一条推荐。
4. 提供无需授权的 `GET /health`。
5. 密钥与阈值只从环境变量读取。

### 预期结果

- Git 中有本文档；
- 可运行的 Cangjie 脚手架：进程能启动、干净退出，`GET /health` 返回 HTTP 200；
- README 使人能在不使用 IDE 的情况下构建并运行服务；
- 后续作业 —— 接入 Kafka，并在实盘周期中实现阶段 A–C。

当前（作业 1）算法在运行时**不交易**：脚手架启动 HTTP，并报告经纪人未配置（`DEGRADED`）。算法意图已经写死，以免后续阶段破坏它。

---

## 2. 项目边界

### 范围内

- 已收盘K线的接入（Kafka 就绪之后）以及进程内短窗口；
- 形态计算、成功公式、walk-forward 阶段；
- 发布交易推荐；
- HTTP 诊断 `GET /health`；
- 通过环境配置；
- 进程干净退出（容器中的 SIGTERM）。

### 明确不在范围内

| 内容 | 由谁负责 |
|---|---|
| 启动与停止回放、选择标的与周期 | 教师平台 |
| 行情供给 | 平台的外部供应商，不是学生 |
| 虚拟成交、手续费、投资组合、小组 | 平台 |
| 仪表盘 UI、练习、课程文档 | 平台（`omsu.7bits.it`） |
| 真实经纪商订单 | 本实验台上无人负责：平台不发送它们 |
| 发放 Kafka 登录、`secretKey`、主题名 | 教师 |
| 通过 UI 表单提交作业 | 没有这种表单；提交 = Git + 可运行的服务 |
| 在当前运行上训练 LLM 与在线微调 | 不在范围内 |

### 服务控制的数据与决策

控制：

- 针对特定K线的 `signal` 与 `confidence`；
- `suggestedQuantity`（`HOLD` / 预热 / 考试为 0，入场为 1）；
- `dataQuality` 以及 `reason` / `metadata` 文本；
- 自己的 Kafka 消费者 `group.id`；
- 进程就绪（health）。

不控制：

- 平台共识窗口是否收敛；
- 推荐是否被执行；
- 投资组合价值如何变化；
- 教师在本次运行中纳入了哪些标的。

### 与谁交互

| 一方 | 类型 | 作业 1 是否已需要？ |
|---|---|---|
| 学生开发者（`llnightll`） | 人 | 是：运行、读日志 |
| 教师 | 人，实验台所有者 | 是：稍后发放经纪人 |
| Teacher Trading Platform | 外部信息系统 | 意义上已是对手方；网络 —— 从下一份作业开始 |
| 课程实验台的 Apache Kafka | 经纪人 | 在边界内，脚手架尚未接入 |
| 语言模型（星星） | 外部 HTTP API | 仅后续阶段可选 |
| 浏览器 / curl | 健康检查客户端 | 是 |

本服务没有「柜面」用户。唯一的机器 HTTP 客户端是存活/就绪探针（教师、Docker、开发者）。

---

## 3. 与外部系统的交互

### 3.1. 教师平台 + Kafka

平台与学生服务**不是通过 REST** 通信，而是通过受保护 Kafka 中的事件。

**来自实验台文档（已于 2026-10-11 核对）：**

- 协议：`SASL_SSL`，机制 `SCRAM-SHA-512`；
- 教师发放的参数：`bootstrap.servers`、登录、密码、K线主题名、必要时的 CA；
- 当时活动的实验台运行为 `REALTIME`，周期 `1m`，主题类似 `market.candle.internal`；
- 运行标的：`SBER`、`T`、`TATN`、`GAZP`、`MAGN`、`MOEX`、`OZON`；
- 出站推荐事件类型：`strategy.recommendation.created`，`schemaVersion` `1.0`；
- K线与推荐的绑定：`sourceEventId`、`runId`、`instrument`、`sequenceNumber`。

**入站（经纪人存在时）。** 已收盘K线事件。预期信封字段：`eventId`、`eventType`、`schemaVersion`、`occurredAt`、`correlationId`、`causationId`、`producer`、`payload`（标的、OHLC、`runId`、`sequenceNumber`）。

**出站。** 每根K线一条推荐。按平台文档，`payload` 必填字段：`recommendationId`、`sourceEventId`、`runId`、`secretKey`、`strategyId`、`accountId`、`groupId`、`sessionId`、`instrument`、`sequenceNumber`、`signal`、`confidence`、`suggestedQuantity`、`dataQuality`。

**认证。**

- 对 Kafka —— SCRAM 登录/密码，TLS；
- 推荐 payload 中的 `secretKey` —— 服务注册时教师发放的密钥；
- `GET /health` **无需**授权（作业要求）。

nginx 上的 HTTP Basic（`realm="Teacher platform"`）保护的是**课程网站**，不是我们的进程。服务不使用那些凭据。

**约束。**

- 不要硬编码平台内部容器地址；
- 每个实例有自己的 `group.id`，否则学生会共享消息分区；
- 首次连接使用 `auto.offset.reset=earliest`；
- 重复同一根K线必须得到同一决策（为第二学期幂等做铺垫）；
- 回答必须快：LLM 不能挡在 `produce` 前面。

**错误与降级。**

| 情况 | 行为 |
|---|---|
| 没有 `KAFKA_BOOTSTRAP_SERVERS` / 登录 / 主题 | health：`kafka=DOWN`，总体状态 `DEGRADED`，进程继续运行 |
| 经纪人不可达 | health `DOWN`，重连；HTTP health 仍为 200 |
| K线序列不完整 | `HOLD`，`confidence=0`，`dataQuality` 不是 `OK` |
| 未知标的 | 忽略或带 `metadata` 原因的 `HOLD`（待澄清） |
| 过期的 `secretKey` | 平台拒绝推荐；一旦接入结果事件，服务才能得知 |

### 3.2. HTTP 健康检查（本仓库）

- 方法：`GET /health`；
- 授权：无；
- 成功传输：**始终 HTTP 200**，即使组件降级；
- 正文：`status`、`service`、`version`、`components`。

脚手架示例（经纪人尚未发放）：

```json
{
  "status": "DEGRADED",
  "service": "quiet-water",
  "version": "1.0.0",
  "components": {
    "kafka": {
      "status": "DOWN",
      "details": "broker is not configured"
    }
  }
}
```

### 3.3. 语言模型（星星，不在脚手架中）

- 方向：`produce` 之后的出站 HTTPS；
- 模型输入：已经接受的决策与K线特征，而不是「替我决定」；
- 输出：对下一根 `confidence` 的有界微调；
- 认证：来自环境的 API 密钥；
- 错误 / 超时：微调为 0。

### 假设与未决问题

1. **精确的K线 JSON** 尚未由本仓库代码约定。参考实验台章节「Closed candle event」。在经纪人作业之前保持开放。
2. 推荐结果主题名与注册心跳来自教师文档，不猜测。
3. `accountId` / `groupId` / `sessionId` 由教师发放；`.env.example` 中是占位符。
4. 平台不发送真实订单 —— 这是文档事实，不是假设。
5. LLM 不是作业 1 的评判标准。

---

## 4. 方案组成

只列出本服务**实际**需要的节点。作业 1 不引入单独 UI 或自有 DBMS：没有可填满屏幕的内容，在 persistence 作业之前也没有必须跨重启存活的数据。

| 组件 | 用途 | 职责 |
|---|---|---|
| **服务端应用（Cangjie 可执行文件）** | 唯一可运行节点 | HTTP 健康检查、进程生命周期，稍后是「K线 → 决策 → produce」循环 |
| **策略模块（同一进程）** | walk-forward、RSI 形态、成功公式 | 不知道 HTTP 或 Kafka 头 |
| **消息经纪人（课程 Kafka）** | 事件传输 | 由实验台拥有；我们的服务是客户端 |
| **环境配置** | 阈值、地址、密钥 | 所有值来自环境，Git 中零密钥 |
| **Docker 容器** | 不依赖 IDE 运行 | Cangjie 镜像、健康端口、SIGTERM |
| **项目文档 + README** | 意图与复现 | 放在同一仓库 |

**为什么没有 UI。** 投资组合观察已在平台上存在。第二个仪表盘不在范围内。

**为什么脚手架没有数据库。** `N+K` 根一分钟K线的窗口保存在内存中。持久化是第一学期单独关闭的作业（`semester-1-persistence`）。该作业开放时才出现存储节点 —— 不会更早。

**为什么没有单独的「ML 服务」。** 成功公式是对 OHLC 的普通算术。不需要专用推理运行时。

示意图：

```
[教师 / 数据供应商]
              │ K线
              ▼
         [实验台 Kafka]
          │           ▲
   consume│           │ produce 推荐
          ▼           │
     [quiet-water 进程：策略 + std.net health]
          │
          └── GET /health  ← curl / Docker / 教师
```

---

## 5. 角色与职责

只保留没有它们就无法解释项目的角色。不引入「产品负责人」「安全分析师」「独立公司的运维」。

### 人

| 角色 | 谁 | 职责 |
|---|---|---|
| **客户** | 课程教师 | 制定事件契约、开放作业、启动运行、观察投资组合 |
| **开发者** | 学生 `llnightll` | 文档、脚手架、算法、密钥不进 Git、服务回答K线 |
| **运维** | 同一学生作为运行者 | 构建镜像或使用 `cjpm`、设置环境、观察 health 与日志、停止进程 |
| **外部系统管理员** | 教师平台管理员 | Kafka、账号、主题、密钥；我们的仓库不管理这些 |
| **行情所有者 / 供应商** | 实验台供应商（不是学生） | 历史或实时K线；不直接连接到 `quiet-water` |

### 机器

| 角色 | 职责 |
|---|---|
| 服务 `quiet-water` | 决策与健康检查 |
| 平台 | K线流、密钥校验、虚拟投资组合 |
| Kafka | 投递，不是业务逻辑 |

没有「我们服务 UI 的用户」：UI 属于平台。

---

## 6. 工具选择

| 领域 | 选择 | 为什么是这个，而不是别的 |
|---|---|---|
| 语言 | **Cangjie 1.2.0**（`cjc`） | 为本仓库选定；静态类型适合 JSON 事件契约；本机 SDK 与容器共用同一工具链 |
| 包 / 构建 | **`cjpm`**（`cjpm.toml`） | 官方 Cangjie 包管理器：不依赖 IDE 即可 `cjpm test`、`cjpm build`、`cjpm run` |
| HTTP | **`std.net` TCP**（`TcpServerSocket`） | 作业 1 只需要 `GET /health`；脚手架不需要 `stdx.net.http` |
| 序列化 | **显式 JSON DTO**（`HealthResponse`） | health 正文在代码中构造；脚手架没有隐藏的反射映射器 |
| 经纪人 | 平台的**课程 Kafka** | 实验台没有其他传输；客户端出现在经纪人作业中，而不是脚手架 |
| DBMS | **作业 1 中没有** | 随 persistence 作业出现；不为「以后」提前引入 Postgres |
| 文档 | **`docs/` 中的 Markdown** | 作业要求：文档与代码同版本；Confluence/Wiki 会把意图与仓库拆开 |
| 任务 | **`omsu.7bits.it` 上的练习 + Git 提交** | 一个学生服务不需要单独的 Jira |
| Git 托管 | 学生发布课程仓库的位置 | 教师发放 / 接受 URL；托管不硬编码 |
| 测试 | **`cjpm test`**（DTO/HTTP 旁的 `*_test.cj`） | `/health` JSON 与请求解析，不绑定网络端口 |
| CI | README 中的 **`cjpm` 与 Docker 命令** | 在教师本机或容器构建时，单独的云 CI 是可选的 |
| 容器 | **`zxilly/cangjie:nightly` → `nightly-slim`** | 在 SDK 镜像中编译，以原生二进制作为 PID 1 运行，使 `docker stop` 能送达 SIGTERM |
| 本机运行 | `cjpm run` 或 Docker | 不依赖 IDE；Windows 上二进制为 `target\release\bin\main.exe` |
| 密钥 | **环境变量**，样例 `.env.example` | 密码和 `secretKey` 不提交 |
| LLM | 不是脚手架依赖 | 星星已描述；它不在 `cjpm.toml` 中 |

为脚手架否决的替代方案：

- Kotlin / Ktor / Gradle / JVM 镜像 —— 那是另一仓库的技术栈，不是本 Cangjie 实现；
- 在作业 1 中「以防万一」接入 Kafka —— 没有发放密钥时无法构建，也会破坏「没有密钥的脚手架」。
