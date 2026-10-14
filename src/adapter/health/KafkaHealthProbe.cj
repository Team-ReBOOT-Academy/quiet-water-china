package quiet_water.adapter.health

import quiet_water.adapter.config.*
import quiet_water.api.dto.*
import quiet_water.application.port.outbound.*

/**
 * 在作业1中，经纪人还没有连接：如果bootstrap未设置，组件DOWN，
 * 进程在这种情况下仍然活着（总体状态DEGRADED）。
 */
public class KafkaHealthProbe <: HealthProbe {
    let 配置: 乞卜丨V___亡囗卜丨下工马

    public init(配置: 乞卜丨V___亡囗卜丨下工马) {
        this.配置 = 配置
    }

    public func 卜丨升从乞(): String {
        return "kafka"
    }

    public func 户尺囗乃乞(): ComponentHealth {
        if (this.配置.工与___长升下长升___亡囗卜丨下工马凵尺乞力()) {
            return ComponentHealth(HealthStatus.Up, "bootstrap is configured")
        }
        return ComponentHealth(HealthStatus.Down, 亡囗卜丨下工马___力乞下升凵乚丁与.卡夫卡缺失说明)
    }
}
