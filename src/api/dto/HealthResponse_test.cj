package quiet_water.api.dto

import quiet_water.adapter.config.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
class HealthResponseTest {
    @TestCase
    func 力乞马尺升力乞力亅与囗卜丨从升丁亡卄乞与亡囗卜丨丁尺升亡丁(): Unit {
        let 组件表 = HashMap<String, ComponentHealth>()
        组件表.add("kafka", ComponentHealth(HealthStatus.Down, 亡囗卜丨下工马___力乞下升凵乚丁与.卡夫卡缺失说明))
        let 响应 = HealthResponse(
            HealthStatus.Degraded,
            亡囗卜丨下工马___力乞下升凵乚丁与.服务名,
            亡囗卜丨下工马___力乞下升凵乚丁与.版本,
            组件表
        )
        let 正文 = 响应.丁囗亅与囗卜丨()
        @Expect(正文.contains("\"status\": \"DEGRADED\""), true)
        @Expect(正文.contains("\"service\": \"quiet-water\""), true)
        @Expect(正文.contains("\"version\": \"1.0.0\""), true)
        @Expect(正文.contains("\"status\": \"DOWN\""), true)
        @Expect(正文.contains("broker is not configured"), true)
    }
}
