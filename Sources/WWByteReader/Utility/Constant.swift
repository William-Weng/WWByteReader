//
//  Constant.swift
//  WWByteReader
//
//  Created by William.Weng on 2026/4/23.
//

import UIKit

// MARK: - typealias
public extension WWByteReader {
    
    typealias Endian = WWByteWriter.Endian                          // 多位元組整數的位元組排列方式
}

// MARK: - enum
public extension WWByteReader {
    
    /// 自定義錯誤
    enum CustomError: Error {
        case unsupportedType(type: String)                          // 不支援類型
        case bufferOverflow(offset: Int, size: Int, count: Int)     // 資料溢位
        case readOverflow                                           // 讀取資料超出設整大小
        case stringDecodingFail                                     // 字串編碼錯誤 `UTF-8`
    }
}

// MARK: - enum
public extension WWByteWriter {
    
    /// 多位元組整數的位元組排列方式
    /// 一般來說：
    /// - `.little` 表示低位元組在前，這種格式常見於多數現代 CPU 與許多自訂二進位協議
    /// - `.big` 表示高位元組在前，這種格式常見於某些網路協議與標準化資料格式
    enum Endian {
        case little                                                 // Little-endian (`0x12345678` => `[0x78, 0x56, 0x34, 0x12]`)
        case big                                                    // Big-endian (`0x12345678` => `[0x12, 0x34, 0x56, 0x78]`)
    }
    
    /// 自定義錯誤
    enum CustomError: Error {
        case stringEncodingFail                                     // 字串無法使用指定編碼轉成 `Data`
        case dataOverflow                                           // 字串長度超出 `UInt16.max`
    }
}
