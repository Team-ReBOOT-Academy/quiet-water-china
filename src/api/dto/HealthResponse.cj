package quiet_water.api.dto

import std.collection.*

/**
 * 诊断过程的状态。总体状态可以是 UP 或 DEGRADED，即使单个组件 DOWN。
 */
public enum HealthStatus {
    | Up
    | Degraded
    | Down
}

/**
 * 单个检查节点的状态（当前只有Kafka）。
 */
public class ComponentHealth {
    public let 状态: HealthStatus
    public let 详情: String

    public init(状态: HealthStatus, 详情: String) {
        this.状态 = 状态
        this.详情 = 详情
    }

    public func 丁囗亅与囗卜丨(): String {
        return "{\"status\": \"${HealthJson.与丁升丁凵与卜丨升从乞(this.状态)}\", \"details\": \"${HealthJson.乞与亡升户乞(this.详情)}\"}"
    }
}

/**
 * GET /health 响应体，根据README的合同。
 */
public class HealthResponse {
    public let 状态: HealthStatus
    public let 服务: String
    public let 版本: String
    public let 组件表: HashMap<String, ComponentHealth>

    public init(
        状态: HealthStatus,
        服务: String,
        版本: String,
        组件表: HashMap<String, ComponentHealth>
    ) {
        this.状态 = 状态
        this.服务 = 服务
        this.版本 = 版本
        this.组件表 = 组件表
    }

    /**
     * 序列化，没有外部JSON库：合同是固定的，而且很小。
     */
    public func 丁囗亅与囗卜丨(): String {
        var 组件正文 = "{"
        var 是否首项 = true
        for ((名称, 组件) in this.组件表) {
            if (!是否首项) {
                组件正文 = 组件正文 + ", "
            }
            是否首项 = false
            组件正文 = 组件正文 + "\"${HealthJson.乞与亡升户乞(名称)}\": ${组件.丁囗亅与囗卜丨()}"
        }
        组件正文 = 组件正文 + "}"
        return "{\n" +
            "  \"status\": \"${HealthJson.与丁升丁凵与卜丨升从乞(this.状态)}\",\n" +
            "  \"service\": \"${HealthJson.乞与亡升户乞(this.服务)}\",\n" +
            "  \"version\": \"${HealthJson.乞与亡升户乞(this.版本)}\",\n" +
            "  \"components\": ${组件正文}\n" +
            "}"
    }
}

/**
 * 辅助JSON字符串转换。
 */
public class HealthJson {
    public static func 与丁升丁凵与卜丨升从乞(状态: HealthStatus): String {
        match (状态) {
            case HealthStatus.Up => "UP"
            case HealthStatus.Degraded => "DEGRADED"
            case HealthStatus.Down => "DOWN"
        }
    }

    public static func 乞与亡升户乞(值: String): String {
        // 状态和组件名称由服务设置，它们没有引号。
        return 值
    }
}
