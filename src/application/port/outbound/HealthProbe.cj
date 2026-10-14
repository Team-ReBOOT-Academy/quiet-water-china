package quiet_water.application.port.outbound

import quiet_water.api.dto.*

/**
 * 健康检查契约。实现存在于adapter/，health脚本只依赖这个接口。
 */
public interface HealthProbe {
    func 卜丨升从乞(): String
    func 户尺囗乃乞(): ComponentHealth
}
