//
//  Constant.swift
//  WWByteReader
//
//  Created by William.Weng on 2026/4/23.
//

import UIKit

// MARK: - enum
public extension WWByteReader {
    
    /// 自定義錯誤
    enum CustomError: Error {
        case unsupportedType(type: String)                          // 不支援類型
        case bufferOverflow(offset: Int, size: Int, count: Int)     // 資料溢位
    }
}
