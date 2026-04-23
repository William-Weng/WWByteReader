//
//  WWByteReader.swift
//  WWByteReader
//
//  Created by William.Weng on 2026/04/23.
//

import UIKit

// MARK: - 無號數Int
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
    /// - Returns: BinaryFloatingPoint
    mutating func readFloatingPoint<T: BinaryFloatingPoint>() throws -> T {
        
        let size = MemoryLayout<T>.size
        
        guard (offset + size) <= data.count else { throw CustomError.bufferOverflow(offset: offset, size: size, count: data.count) }
        
        let bitPattern: UInt64
        
        switch size {
        case 4: bitPattern = try readUIntValue(size: 4)
        case 8: bitPattern = try readUIntValue(size: 8)
        default: throw CustomError.unsupportedType(type: "\(T.self)")
        }
        
        switch size {
        case 4: return Float(bitPattern: UInt32(truncatingIfNeeded: bitPattern)) as! T
        case 8: return Double(bitPattern: bitPattern) as! T
        default: throw CustomError.unsupportedType(type: "\(T.self)")
        }
    }
}

// MARK: - 核心程式
public extension WWByteReader {
    
    /// 讀取二進制無號數值 (位移取值 + 累加)
    /// - Returns: FixedWidthInteger
    mutating func readUIntValue<T: FixedWidthInteger>(size: Int) throws -> T {
        
        if ((offset + size) > data.count)  { throw CustomError.bufferOverflow(offset: offset, size: size, count: data.count) }
        
        let value = (0..<size).map { index in
            return T(data[offset + index]) << (8 * (size - index - 1))      // let b0 = UInt16(data[offset]) << 8
        }.reduce(T(0)) { partialResult, number in
            return partialResult | number                                   // b0 | b1
        }
        
        offset += size
        
        return value
    }
}
