# Quiet Water (`quiet-water`)

鄂木斯克国立大学教师平台上的学生 **strategy-service**
（[Teacher Trading Platform](https://omsu.7bits.it/)）。

本服务不在真实交易所下单，也不计算虚拟投资组合。
它位于平台外部：对每一根已收盘K线给出一个 `BUY` / `SELL` / `HOLD` 决策，
并提供诊断接口 `GET /health`。

作者：**llnightll**  
项目文档：[docs/project-description.md](docs/project-description.md)  
服务标识 / 未来的 `strategyId`：`quiet-water`  
脚手架：**Cangjie**（`cjpm`）+ 基于 `std.net` 的 HTTP

## 预先选定的策略

**Walk-forward「及格分」**（quiet water —— 先静，后击）：

1. 每个标的前 `N` 根K线用于收集窗口，对外只发 `HOLD`。
2. 随后 `K` 根K线用已经算好的成功公式考试，仍然只发 `HOLD`。
3. 若考试命中率不低于阈值 `T`，服务才开始交易。
4. 之后窗口每次滑动一根K线，并重新计算成功公式。
5. 入场形态是 RSI(14) 从 30/70 区域的反转；是否允许交易只由 `successRate` 决定。

语言模型不进入 `BUY`/`SELL` 回路。它是发出推荐之后的可选「星星」，
见项目文档。作业 1 不实现它。

起始阈值（来自环境变量，不写在代码里）：`N=90`，`K=45`，`M=10`，`W=20`，`T=0.55`。

## 环境要求

可以**不依赖 IDE** 用两种方式构建并运行：本机 Cangjie SDK 或 Docker。
机器上有其中一种即可。

**方案 A —— 本机 Cangjie SDK**

- Cangjie SDK **1.2.0**（`cjc`、`cjpm`），`CANGJIE_HOME`
- 用 `curl` 检查 `/health`

**方案 B —— 仅 Docker**

- Docker Engine 24+
- 宿主机不需要 SDK；镜像 `zxilly/cangjie` 负责编译二进制

Kafka 密钥和 `secretKey` 由教师另行发放，不在 Git 中。
变量名样例见 `.env.example`。
在经纪人尚未发放之前，服务必须以 `DEGRADED` 状态启动。

## 不依赖开发环境的构建与运行命令

下列命令是 Cangjie 脚手架的运行契约。在 CI 或教师机器上应重复同样步骤。

### cjpm

```bash
cjpm test
cjpm run
```

或构建后再直接运行二进制：

```bash
cjpm build
./target/release/bin/main
```

在 Windows 上可执行文件为 `target\release\bin\main.exe`。

在另一个终端：

```bash
curl -s http://127.0.0.1:8888/health
```

活着的脚手架预期响应（作业 1，Kafka 尚未接入）：

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

即使 `status` 为 `DEGRADED`，HTTP 状态码仍为 **200**。
`/health` 不需要授权。

用 `Ctrl+C` 停止本机进程。

### Docker（更推荐的「无 IDE」路径）

```bash
docker build -t quiet-water:1.0.0 .
docker run --rm -p 8888:8888 --name quiet-water quiet-water:1.0.0
```

检查与停止：

```bash
curl -s http://127.0.0.1:8888/health
docker stop quiet-water
```

环境变量通过 `--env` / `--env-file` 传入，不要烤进镜像。
不要把密码和密钥放进仓库。

容器必须能在 `SIGTERM`（`docker stop`）下干净退出。

## 本仓库有意不包含的内容

- UI —— 投资组合观察已在平台上提供
- 自有数据库 —— 仅在 persistence 作业中出现
- Kafka 客户端 —— 下一份开放作业（`semester-1-broker`）
- 真实经纪商订单 —— 平台不会发送

详细边界、角色与事件契约见
[docs/project-description.md](docs/project-description.md)。
源码布局见 [application.md](application.md)。
