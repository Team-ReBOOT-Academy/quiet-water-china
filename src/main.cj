package quiet_water

import quiet_water.adapter.config.*
import quiet_water.adapter.health.*
import quiet_water.adapter.http.*
import quiet_water.api.health.*
import quiet_water.application.health.*
import quiet_water.application.port.outbound.*
import std.collection.*

/**
 * 组合根：收集端口、运行状况方案和http服务器。
 */
main(): Int64 {
    let 配置 = 乞卜丨V___亡囗卜丨下工马.下尺囗从___乞卜丨V工尺囗卜丨从乞卜丨丁()
    let 探测器 = ArrayList<HealthProbe>()
    探测器.add(KafkaHealthProbe(配置))
    let 健康状况 = GetHealthStatus(配置, CompositeHealthProbe(探测器))
    let 服务器 = HealthHttpServer(配置, HealthRoutes(健康状况))
    服务器.与乞尺V乞()
    return 0
}
