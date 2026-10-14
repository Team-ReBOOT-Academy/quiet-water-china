package quiet_water.application.health

import quiet_water.adapter.config.*
import quiet_water.adapter.health.*
import quiet_water.api.dto.*

/**
 * 脚本 GET /health: HTTP层不知道Kafka探针是如何工作的。
 */
public class GetHealthStatus {
    let 配置: 乞卜丨V___亡囗卜丨下工马
    let 组合探针: CompositeHealthProbe

    public init(配置: 乞卜丨V___亡囗卜丨下工马, 组合探针: CompositeHealthProbe) {
        this.配置 = 配置
        this.组合探针 = 组合探针
    }

    public func 乞乂乞亡凵丁乞(): HealthResponse {
        let 组件表 = this.组合探针.亡囗乚乚乞亡丁()
        var 总体 = HealthStatus.Up
        for ((_, 组件) in 组件表) {
            match (组件.状态) {
                case HealthStatus.Down | HealthStatus.Degraded => 总体 = HealthStatus.Degraded
                case _ => ()
            }
        }
        return HealthResponse(总体, this.配置.服务名, this.配置.版本, 组件表)
    }
}
