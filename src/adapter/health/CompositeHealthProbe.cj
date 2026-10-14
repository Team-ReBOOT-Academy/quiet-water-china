package quiet_water.adapter.health

import quiet_water.api.dto.*
import quiet_water.application.port.outbound.*
import std.collection.*

/**
 * 收集端口探针，组成一个组件映射，用于/health的响应。
 */
public class CompositeHealthProbe {
    let 探针表: ArrayList<HealthProbe>

    public init(探针表: ArrayList<HealthProbe>) {
        this.探针表 = 探针表
    }

    public func 亡囗乚乚乞亡丁(): HashMap<String, ComponentHealth> {
        let 组件表 = HashMap<String, ComponentHealth>()
        for (探针 in this.探针表) {
            组件表.add(探针.卜丨升从乞(), 探针.户尺囗乃乞())
        }
        return 组件表
    }
}
