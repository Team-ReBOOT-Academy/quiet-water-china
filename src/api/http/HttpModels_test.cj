package quiet_water.api.http

import std.unittest.*
import std.unittest.testmacro.*

@Test
class HttpRequestParseTest {
    @TestCase
    func 户升尺与乞与马乞丁卄乞升乚丁卄(): Unit {
        let 原文 = "GET /health HTTP/1.1\r\nHost: 127.0.0.1:8888\r\n\r\n"
        let 请求 = HttpRequest.户升尺与乞(原文)
        let 是否获取 = match (请求.方法) {
            case HttpMethod.Get => true
            case _ => false
        }
        @Expect(是否获取, true)
        @Expect(请求.路径, "/health")
    }
}
