//
//  WWByteWriter.swift
//  WWByteReader
//
//  Created by William.Weng on 2026/5/6.
//

import Foundation

/// 一個簡單的二進位資料寫入器，用來把整數、字串、位元組等內容依序編碼成 `Data` => 依順序寫入 `UInt8`、`UInt32`、`String`、`Data` 等資料
public struct WWByteWriter {
    
    public private(set) var data: Data      // 已寫入的二進位資料本體 => 會隨著每次 `write...` 方法呼叫而持續累積
    public private(set) var offset: Int     // 目前寫入位置 => 這個 offset 會隨著每次寫入而自動推進至結尾，外部通常只用來除錯或檢查內部狀態，一般使用時不需要直接存取
    
    /// 建立一個新的 `WWByteWriter` => 建立後，`offset` 會自動設為目前 `data.count`，之後每次寫入都會從最後一個 byte 往後繼續累加。
    public init(data: Data = .init()) {
        self.data = data
        self.offset = data.count
    }
}

// MARK: - 公開屬性
public extension WWByteWriter {
    
    var count: Int { data.count }           // 目前已寫入的位元組數量
    var isEmpty: Bool { data.isEmpty }      // 是否沒有任何資料
}

// MARK: - 公開API
public extension WWByteWriter {
        
    /// 寫入單一位元組
    mutating func writeByte(_ value: UInt8) {
        writeInteger(value)
    }
    
    /// 寫入位元組陣列
    mutating func writeBytes(_ values: [UInt8]) {
        writeData(Data(values))
    }
    
    /// 將字串依指定編碼轉成 `Data` 後寫入
    /// - Parameters:
    ///   - string: 要寫入的字串
    ///   - encoding: 字串編碼，預設 UTF-8
    /// - Throws: `CustomError.stringEncodingFail`，當字串無法使用指定編碼轉成資料時
    mutating func writeString(_ string: String, encoding: String.Encoding = .utf8) throws {
        
        guard let value = string.data(using: encoding) else { throw CustomError.stringEncodingFail }
        writeData(value)
    }
    
    /// 清空已寫入資料並重設 offset
    mutating func reset() {
        data.removeAll(keepingCapacity: false)
        offset = 0
    }
}

// MARK: - 核心程式
public extension WWByteWriter {
    
    /// 寫入 Data
    mutating func writeData(_ value: Data) {
        data.append(value)
        offset = data.count
    }
    
    /// 寫入固定寬度整數 => 這個方法可用於寫入所有符合 `FixedWidthInteger` 的整數型別
    ///   - value: 要寫入的整數值。
    ///   - endian: 位元組順序，預設為 little-endian。
    mutating func writeInteger<T: FixedWidthInteger>(_ value: T, endian: Endian = .little) {
        
        let encodedValue: T
        
        switch endian {
        case .little: encodedValue = value.littleEndian
        case .big: encodedValue = value.bigEndian
        }
        
        withUnsafeBytes(of: encodedValue) { data.append(contentsOf: $0) }
        offset = data.count
    }
}
