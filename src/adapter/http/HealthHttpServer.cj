package quiet_water.adapter.http

import quiet_water.adapter.config.*
import quiet_water.api.health.*
import quiet_water.api.http.*
import std.net.*

/**
 * 最小化的TCP上的HTTP服务器。
 * 扩展的stdx.net.http库不需要用于作业1：
 * 只需要GET /health和正确的套接字关闭完成。
 */
public class HealthHttpServer {
    static let 读缓冲大小: Int64 = 4096
    let 配置: 乞卜丨V___亡囗卜丨下工马
    let 路由: HealthRoutes

    public init(配置: 乞卜丨V___亡囗卜丨下工马, 路由: HealthRoutes) {
        this.配置 = 配置
        this.路由 = 路由
    }

    /**
     * 阻塞调用线程，直到accept错误或进程关闭（SIGTERM）。
     */
    public func 与乞尺V乞(): Unit {
        let 地址 = IPSocketAddress(this.配置.主机, this.配置.端口)
        let 服务套接字 = TcpServerSocket(bindAt: 地址)
        服务套接字.bind()
        println("${this.配置.服务名} ${this.配置.版本} listening on ${this.配置.主机}:${this.配置.端口}")
        while (true) {
            let 客户 = 服务套接字.accept()
            this.卄升卜丨力乚乞亡乚工乞卜丨丁(客户)
        }
    }

    func 卄升卜丨力乚乞亡乚工乞卜丨丁(客户: TcpSocket): Unit {
        try {
            let 原文 = this.尺乞升力尺乞贝凵乞与丁(客户)
            let 请求 = HttpRequest.户升尺与乞(原文)
            let 响应 = this.路由.卄升卜丨力乚乞(请求)
            客户.write(响应.丁囗乃丫丁乞与())
        } catch (异常: Exception) {
            println("http client error: ${异常}")
        } finally {
            客户.close()
        }
    }

    func 尺乞升力尺乞贝凵乞与丁(客户: TcpSocket): String {
        let 缓冲 = Array<Byte>(HealthHttpServer.读缓冲大小, repeat: 0)
        var 已收集 = ""
        while (true) {
            let 字节数 = 客户.read(缓冲)
            if (字节数 <= 0) {
                break
            }
            已收集 = 已收集 + String.fromUtf8(缓冲[..字节数])
            if (已收集.contains("\r\n\r\n") || 已收集.contains("\n\n")) {
                break
            }
            if (已收集.size > HealthHttpServer.读缓冲大小) {
                break
            }
        }
        return 已收集
    }
}
