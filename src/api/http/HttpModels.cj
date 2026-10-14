package quiet_water.api.http

/**
 * 方法，框架在启动时解析。随着管理探针的出现而扩展。
 */
public enum HttpMethod {
    | Get
    | Other
}

/**
 * 解析启动的HTTP请求字符串。
 */
public class HttpRequest {
    public let 方法: HttpMethod
    public let 路径: String

    public init(方法: HttpMethod, 路径: String) {
        this.方法 = 方法
        this.路径 = 路径
    }

    /**
     * 解析第一行，如 `GET /health HTTP/1.1`。
     */
    public static func 户升尺与乞(原文: String): HttpRequest {
        let 头结束 = HttpRequest.卄乞升力乞尺与乞户升尺升丁囗尺工卜丨力乞乂(原文)
        let 头块 = if (头结束 >= 0) {
            原文[0..头结束]
        } else {
            原文
        }
        let 行表 = 头块.split("\n")
        if (行表.size == 0) {
            return HttpRequest(HttpMethod.Other, "/")
        }
        let 请求行 = HttpRequest.与丁尺工户尺乞丁凵尺卜丨(行表[0])
        let 分段 = 请求行.split(" ")
        if (分段.size < 2) {
            return HttpRequest(HttpMethod.Other, "/")
        }
        let 方法 = if (分段[0] == "GET") {
            HttpMethod.Get
        } else {
            HttpMethod.Other
        }
        return HttpRequest(方法, 分段[1])
    }

    static func 与丁尺工户尺乞丁凵尺卜丨(行: String): String {
        if (行.endsWith("\r")) {
            return 行[0..行.size - 1]
        }
        return 行
    }

    static func 卄乞升力乞尺与乞户升尺升丁囗尺工卜丨力乞乂(原文: String): Int64 {
        let 视窗分隔 = "\r\n\r\n"
        let 换行分隔 = "\n\n"
        if (原文.contains(视窗分隔)) {
            return HttpRequest.下工尺与丁工卜丨力乞乂囗下(原文, 视窗分隔)
        }
        if (原文.contains(换行分隔)) {
            return HttpRequest.下工尺与丁工卜丨力乞乂囗下(原文, 换行分隔)
        }
        return -1
    }

    static func 下工尺与丁工卜丨力乞乂囗下(原文: String, 针: String): Int64 {
        var 索引: Int64 = 0
        let 上限 = 原文.size - 针.size
        while (索引 <= 上限) {
            if (原文[索引..索引 + 针.size] == 针) {
                return 索引
            }
            索引 = 索引 + 1
        }
        return -1
    }
}

/**
 * 出站HTTP响应，具有固定的JSON头。
 */
public class HttpResponse {
    public let 状态码: Int64
    public let 原因: String
    public let 正文: String

    public init(状态码: Int64, 原因: String, 正文: String) {
        this.状态码 = 状态码
        this.原因 = 原因
        this.正文 = 正文
    }

    public static func 囗长亅与囗卜丨(正文: String): HttpResponse {
        return HttpResponse(200, "OK", 正文)
    }

    public static func 卜丨囗丁下囗凵卜丨力亅与囗卜丨(正文: String): HttpResponse {
        return HttpResponse(404, "Not Found", 正文)
    }

    public func 丁囗乃丫丁乞与(): Array<Byte> {
        let 载荷 = this.正文.toArray()
        let 头 =
            "HTTP/1.1 ${this.状态码} ${this.原因}\r\n" +
            "Content-Type: application/json; charset=utf-8\r\n" +
            "Content-Length: ${载荷.size}\r\n" +
            "Connection: close\r\n" +
            "\r\n"
        return (头 + this.正文).toArray()
    }
}
