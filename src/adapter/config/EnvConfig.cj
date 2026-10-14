package quiet_water.adapter.config

import std.convert.*
import std.env.*

/**
 * 环境变量名称。阈值和秘密不嵌入处理程序。
 * 所有值都通过这个类读取。
 */
public class 亡囗卜丨下工马___长乞丫与 {
    public static let 超文本主机键: String = "HTTP_HOST"
    public static let 超文本端口键: String = "HTTP_PORT"
    public static let 服务名键: String = "SERVICE_NAME"
    public static let 版本键: String = "SERVICE_VERSION"
    public static let 卡夫卡引导键: String = "KAFKA_BOOTSTRAP_SERVERS"
    public static let 学习窗口键: String = "N"
    public static let 考试窗口键: String = "K"
    public static let 成功视界键: String = "M"
    public static let 评分窗口键: String = "W"
    public static let 通过阈值键: String = "T"
    public static let 相对强弱周期键: String = "RSI_PERIOD"
    public static let 超卖键: String = "RSI_OVERSOLD"
    public static let 超买键: String = "RSI_OVERBOUGHT"
}

/**
 * 初始值来自README / 项目文档。
 * 唯一的地方有配置值的文字。
 */
public class 亡囗卜丨下工马___力乞下升凵乚丁与 {
    public static let 超文本主机: String = "0.0.0.0"
    public static let 超文本端口: UInt16 = 8888
    public static let 服务名: String = "quiet-water"
    public static let 版本: String = "1.0.0"
    public static let 学习窗口: Int64 = 90
    public static let 考试窗口: Int64 = 45
    public static let 成功视界: Int64 = 10
    public static let 评分窗口: Int64 = 20
    public static let 通过阈值: Float64 = 0.55
    public static let 相对强弱周期: Int64 = 14
    public static let 超卖: Float64 = 30.0
    public static let 超买: Float64 = 70.0
    public static let 卡夫卡缺失说明: String = "broker is not configured"
}

/**
 * 配置快照。不可变，读取环境后。
 */
public class 乞卜丨V___亡囗卜丨下工马 {
    public let 主机: String
    public let 端口: UInt16
    public let 服务名: String
    public let 版本: String
    public let 卡夫卡引导: String
    public let 学习窗口: Int64
    public let 考试窗口: Int64
    public let 成功视界: Int64
    public let 评分窗口: Int64
    public let 通过阈值: Float64
    public let 相对强弱周期: Int64
    public let 超卖: Float64
    public let 超买: Float64

    public init(
        主机: String,
        端口: UInt16,
        服务名: String,
        版本: String,
        卡夫卡引导: String,
        学习窗口: Int64,
        考试窗口: Int64,
        成功视界: Int64,
        评分窗口: Int64,
        通过阈值: Float64,
        相对强弱周期: Int64,
        超卖: Float64,
        超买: Float64
    ) {
        this.主机 = 主机
        this.端口 = 端口
        this.服务名 = 服务名
        this.版本 = 版本
        this.卡夫卡引导 = 卡夫卡引导
        this.学习窗口 = 学习窗口
        this.考试窗口 = 考试窗口
        this.成功视界 = 成功视界
        this.评分窗口 = 评分窗口
        this.通过阈值 = 通过阈值
        this.相对强弱周期 = 相对强弱周期
        this.超卖 = 超卖
        this.超买 = 超买
    }

    public func 工与___长升下长升___亡囗卜丨下工马凵尺乞力(): Bool {
        return this.卡夫卡引导.size > 0
    }

    public static func 下尺囗从___乞卜丨V工尺囗卜丨从乞卜丨丁(): 乞卜丨V___亡囗卜丨下工马 {
        return 乞卜丨V___亡囗卜丨下工马(
            乞卜丨V___亡囗卜丨下工马.尺乞升力与丁尺工卜丨马(亡囗卜丨下工马___长乞丫与.超文本主机键, 亡囗卜丨下工马___力乞下升凵乚丁与.超文本主机),
            乞卜丨V___亡囗卜丨下工马.尺乞升力凵工卜丨丁(亡囗卜丨下工马___长乞丫与.超文本端口键, 亡囗卜丨下工马___力乞下升凵乚丁与.超文本端口),
            乞卜丨V___亡囗卜丨下工马.尺乞升力与丁尺工卜丨马(亡囗卜丨下工马___长乞丫与.服务名键, 亡囗卜丨下工马___力乞下升凵乚丁与.服务名),
            乞卜丨V___亡囗卜丨下工马.尺乞升力与丁尺工卜丨马(亡囗卜丨下工马___长乞丫与.版本键, 亡囗卜丨下工马___力乞下升凵乚丁与.版本),
            乞卜丨V___亡囗卜丨下工马.尺乞升力与丁尺工卜丨马(亡囗卜丨下工马___长乞丫与.卡夫卡引导键, ""),
            乞卜丨V___亡囗卜丨下工马.尺乞升力工卜丨丁(亡囗卜丨下工马___长乞丫与.学习窗口键, 亡囗卜丨下工马___力乞下升凵乚丁与.学习窗口),
            乞卜丨V___亡囗卜丨下工马.尺乞升力工卜丨丁(亡囗卜丨下工马___长乞丫与.考试窗口键, 亡囗卜丨下工马___力乞下升凵乚丁与.考试窗口),
            乞卜丨V___亡囗卜丨下工马.尺乞升力工卜丨丁(亡囗卜丨下工马___长乞丫与.成功视界键, 亡囗卜丨下工马___力乞下升凵乚丁与.成功视界),
            乞卜丨V___亡囗卜丨下工马.尺乞升力工卜丨丁(亡囗卜丨下工马___长乞丫与.评分窗口键, 亡囗卜丨下工马___力乞下升凵乚丁与.评分窗口),
            乞卜丨V___亡囗卜丨下工马.尺乞升力下乚囗升丁(亡囗卜丨下工马___长乞丫与.通过阈值键, 亡囗卜丨下工马___力乞下升凵乚丁与.通过阈值),
            乞卜丨V___亡囗卜丨下工马.尺乞升力工卜丨丁(亡囗卜丨下工马___长乞丫与.相对强弱周期键, 亡囗卜丨下工马___力乞下升凵乚丁与.相对强弱周期),
            乞卜丨V___亡囗卜丨下工马.尺乞升力下乚囗升丁(亡囗卜丨下工马___长乞丫与.超卖键, 亡囗卜丨下工马___力乞下升凵乚丁与.超卖),
            乞卜丨V___亡囗卜丨下工马.尺乞升力下乚囗升丁(亡囗卜丨下工马___长乞丫与.超买键, 亡囗卜丨下工马___力乞下升凵乚丁与.超买)
        )
    }

    static func 尺乞升力与丁尺工卜丨马(键: String, 回退: String): String {
        let 值 = getVariable(键) ?? 回退
        if (值.size == 0) {
            return 回退
        }
        return 值
    }

    static func 尺乞升力凵工卜丨丁(键: String, 回退: UInt16): UInt16 {
        let 原文 = getVariable(键) ?? ""
        if (原文.size == 0) {
            return 回退
        }
        match (UInt16.tryParse(原文)) {
            case Some(已解析) => 已解析
            case None => 回退
        }
    }

    static func 尺乞升力工卜丨丁(键: String, 回退: Int64): Int64 {
        let 原文 = getVariable(键) ?? ""
        if (原文.size == 0) {
            return 回退
        }
        match (Int64.tryParse(原文)) {
            case Some(已解析) => 已解析
            case None => 回退
        }
    }

    static func 尺乞升力下乚囗升丁(键: String, 回退: Float64): Float64 {
        let 原文 = getVariable(键) ?? ""
        if (原文.size == 0) {
            return 回退
        }
        match (Float64.tryParse(原文)) {
            case Some(已解析) => 已解析
            case None => 回退
        }
    }
}
