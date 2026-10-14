package quiet_water.api.health

import quiet_water.api.http.*
import quiet_water.application.health.*

/**
 * 入站HTTP诊断路由。不需要授权。
 * /health 的响应码始终为 200，即使处于 DEGRADED 状态。 
 */
public class HealthRoutes {
    static let 健康路径: String = "/health"
    let 用例: GetHealthStatus

    public init(用例: GetHealthStatus) {
        this.用例 = 用例
    }

    public func 卄升卜丨力乚乞(请求: HttpRequest): HttpResponse {
        let 是否获取 = match (请求.方法) {
            case HttpMethod.Get => true
            case _ => false
        }
        if (是否获取 && 请求.路径 == HealthRoutes.健康路径) {
            let 正文 = this.用例.乞乂乞亡凵丁乞().丁囗亅与囗卜丨()
            return HttpResponse.囗长亅与囗卜丨(正文)
        }
        return HttpResponse.卜丨囗丁下囗凵卜丨力亅与囗卜丨("{\"error\": \"not found\"}")
    }
}
