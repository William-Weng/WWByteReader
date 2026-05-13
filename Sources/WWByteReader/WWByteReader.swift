//
//  WWByteReader.swift
//  WWByteReader
//
//  Created by William.Weng on 2026/04/23.
//

import Foundation

/// 一個簡單的二進位資料讀取器，用來讀取整數、浮點數
public struct WWByteReader {
    
    public let data: Data
    public var offset: Int = 0

    /// 初始化
    /// - Parameters:
    ///   - data: 要讀取的資料
    ///   - offset: 目前的偏移量
    public init(data: Data, offset: Int = 0) {
        self.data = data
        self.offset = offset
    }
}

// MARK: - 公開屬性
public extension WWByteReader {
    
    var remainingCount: Int { max(0, data.count - offset) }     // 剩餘位元組數
}

// MARK: - 無號數Int
public extension WWByteReader {
    
    /// 讀取二進制無號數值 (位移取值 + 累加)
    /// - Returns: FixedWidthInteger & UnsignedInteger
    mutating func readUIntValue<T: FixedWidthInteger & UnsignedInteger>() throws -> T {
        let size = MemoryLayout<T>.size
        return try readUIntValue(size: size)
    }
    
    /// 讀取二進制無號數值 (位移取值 + 累加)
    /// - Returns: UInt32
    mutating func readUInt24Value() throws -> UInt32 {
        return try readUIntValue(size: 3) as UInt32
    }
}

// MARK: - 有號數Int
public extension WWByteReader {
    
    /// 讀取二進制有號數值 (位移取值 + 累加)
    /// - Returns: FixedWidthInteger & SignedInteger
    mutating func readIntValue<T: FixedWidthInteger & SignedInteger>() throws -> T {
        
        switch T.self {
        case is Int8.Type:
            let value = try readUIntValue() as UInt8
            return Int8(bitPattern: value) as! T
        case is Int16.Type:
            let value = try readUIntValue() as UInt16
            return Int16(bitPattern: value) as! T
        case is Int32.Type:
            let value = try readUIntValue() as UInt32
            return Int32(bitPattern: value) as! T
        case is Int64.Type:
            let value = try readUIntValue() as UInt64
            return Int64(bitPattern: value) as! T
        case is Int.Type:
            let value = try readUIntValue() as UInt
            return Int(bitPattern: value) as! T
        default:
            throw CustomError.unsupportedType(type: "\(T.self)")
        }
    }
}

// MARK: - 浮點數 (Float / Double)
public extension WWByteReader {
    
    /// 讀取浮點數 (取值 => 對應浮點數)
    /// - Parameters:
    ///   - endian: 位元組順序，預設為 big-endian
    /// - Returns: BinaryFloatingPoint
    mutating func readFloatingPoint<T: BinaryFloatingPoint>(endian: Endian = .big) throws -> T {
        
        let size = MemoryLayout<T>.size
        
        guard (offset + size) <= data.count else { throw CustomError.bufferOverflow(offset: offset, size: size, count: data.count) }
        
        switch T.self {
        case is Float.Type:
            let bitPattern: UInt32 = try readUIntValue(size: 4, endian: endian)
            return Float(bitPattern: bitPattern) as! T
            
        case is Double.Type:
            let bitPattern: UInt64 = try readUIntValue(size: 8, endian: endian)
            return Double(bitPattern: bitPattern) as! T
            
        default:
            throw CustomError.unsupportedType(type: "\(T.self)")
        }
    }
}

public extension WWByteReader {
    
    /// 讀取指定長度的字串資料。
    /// - Parameters:
    ///   - count: 要讀取的位元組數。
    ///   - encoding: 字串編碼，預設為 UTF-8。
    /// - Throws:
    ///   - `CustomError.readOverflow`：當可讀取的資料不足時。
    ///   - `CustomError.stringDecodingFail`：當資料無法轉成字串時。
    /// - Returns: 解碼後的字串。
    mutating func readString(count: Int, encoding: String.Encoding = .utf8) throws -> String {
        
        let value = try readData(count: count)
        
        guard let string = String(data: value, encoding: encoding) else { throw CustomError.stringDecodingFail }
        
        return string
    }
    
    /// 讀取一段以長度前綴表示的字串資料 => 會先讀取指定型別的長度值，再依該長度讀取對應數量的位元組，最後使用指定編碼轉換成 `String`。
    /// - Parameters:
    ///   - encoding: 字串解碼格式，預設為 UTF-8。
    ///   - lengthType: 長度前綴的整數型別，預設為 `UInt16`。
    /// - Throws:
    ///   - `CustomError.readOverflow`：當可讀取的資料長度不足時。
    ///   - `CustomError.stringDecodingFail`：當資料無法使用指定編碼轉成字串時。
    ///   - 其他由 `readUIntValue()` 或 `readData(count:)` 拋出的錯誤。
    /// - Returns: 解碼後的字串。
    mutating func readLengthPrefixedString<T: FixedWidthInteger & UnsignedInteger>(encoding: String.Encoding = .utf8, lengthType: T.Type = UInt16.self) throws -> String {
        
        _ = lengthType
        
        let length: T = try readUIntValue()
        let count = Int(length)

        return try readString(count: count, encoding: encoding)
    }
}

// MARK: - 核心程式
public extension WWByteReader {

    /// 讀取指定長度的原始資料 => 會從目前讀取位置擷取指定數量的位元組，並同步更新內部偏移量 `offset`。
    /// - Parameter count: 要讀取的資料長度（位元組數）。
    /// - Throws: `CustomError.readOverflow`，當剩餘資料不足指定長度時。
    /// - Returns: 擷取出的 `Data`。
    mutating func readData(count: Int) throws -> Data {
        
        guard offset + count <= data.count else { throw CustomError.readOverflow }
        
        let value = data.subdata(in: offset ..< offset + count)
        offset += count
        
        return value
    }
    
    /// 讀取二進制無號數值 (位移取值 + 累加)
    /// - Parameters:
    ///   - size: 位元數 (MemoryLayout<T>.size)
    ///   - endian: 位元組順序，預設為 big-endian
    /// - Returns: FixedWidthInteger
    mutating func readUIntValue<T: FixedWidthInteger>(size: Int, endian: Endian = .big) throws -> T {
        
        if ((offset + size) > data.count)  { throw CustomError.bufferOverflow(offset: offset, size: size, count: data.count) }
        
        let value = (0..<size).reduce(T(0)) { partialResult, index in
            
            let byte = T(data[offset + index])
            let shift: Int
            
            switch endian {
            case .big: shift = 8 * (size - index - 1)
            case .little: shift = 8 * index
            }
            
            return partialResult | (byte << shift)
        }
        
        offset += size
        
        return value
    }
}

// MARK: - 讀取資料
public extension WWByteReader {
    
    /// 查看剩餘的 Data，但不移動 offset
    /// - Returns: 從目前 offset 到結尾的資料；若已在結尾，回傳空的 Data
    func remainingData() throws -> Data {
        if (offset > data.count) { throw CustomError.bufferOverflow(offset: offset, size: 0, count: data.count) }
        return data.subdata(in: offset..<data.count)
    }
    
    /// 讀取剩下的 Data
    /// - Returns: 從目前 offset 到結尾的資料
    mutating func readRemainingData() throws -> Data {
                
        let remainingData = try remainingData()
        offset = data.count
        
        return remainingData
    }
}
