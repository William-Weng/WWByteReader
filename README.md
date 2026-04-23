# [WWByteReader](https://swiftpackageindex.com/William-Weng)

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWByteReader)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## 🎉 [相關說明](https://qoaformat.org/qoa-specification.pdf)

> A high-performance **big-endian binary reader** designed for audio and video format parsing. It uses a unified shift-and-OR approach to read all data types, with full support for **Int, UInt, Float, and Double**.

> 高效能 **Big-Endian 二進制讀取器**，專為音頻/視頻格式解析設計。統一用位移 + OR 操作讀取所有類型，完美支援 **Int/UInt/Float/Double**。

## ✨ 核心特色

- 🎯 **Big-Endian 統一處理**：所有類型都走同一個位移核心
- 🚀 **高性能**：純位移運算，SIMD 友好，零分配
- ✅ **類型安全**：泛型 + protocol 約束，編譯期檢查
- 🛡️ **越界保護**：自動檢查 + `throws`
- 📦 **零依賴**：純 Swift，無外部框架

## 🚀 快速開始

### SPM 安裝
```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWByteReader", .upToNextMinor(from: "1.0.0"))
]
```

### 基本用法
```swift
import WWByteReader

let data = Data([0xFF, 0xFE, 0x00, 0x00, 0x01, 0x00, 0x40, 0x49, 0x0F, 0xDB])

var reader = WWByteReader(data: data)

let int16: Int16 = try reader.readIntValue()        // -2
let uint32: UInt32 = try reader.readUIntValue()     // 256
let float: Float = try reader.readFloatingPoint()   // 3.1415927
```

## 📖 API 總覽

### 整數讀取
```swift
// 無號整數 (自動推斷大小)
let uint16: UInt16 = try reader.readUIntValue()     // 2 bytes
let uint32: UInt32 = try reader.readUIntValue()     // 4 bytes

// 特殊大小
let uint24: UInt32 = try reader.readUInt24Value()   // 3 bytes → UInt32

// 有號整數
let int16: Int16 = try reader.readIntValue()        // bitPattern 轉換
let int32: Int32 = try reader.readIntValue()
```

### 浮點數讀取
```swift
// 泛型浮點數 (自動推斷 Float/Double)
let float: Float = try reader.readFloatingPoint()
let double: Double = try reader.readFloatingPoint()
```

### 核心原理
- Bytes → readUIntValue() → Bit Pattern → 格式解釋
- [0x40,0x49,0x0F,0xDB] → 0x40490FDB → Float(3.14159) / UInt32(1080039163)

## 🧪 完整測試範例

```swift
import UIKit
import WWByteReader

final class ViewController: UIViewController {
    
    let testData = Data([
        0xFF, 0xFE,                    // Int16 = -2
        0x00, 0x00, 0x01, 0x00,        // UInt32 = 256
        0x40, 0x49, 0x0F, 0xDB,        // Float π
        0x40, 0x09, 0x21, 0xFB,        // Double π (前半)
        0x54, 0x44, 0x2D, 0x18         // Double π (後半)
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readVData()
    }
    
    func readVData() {
        
        do {
            var reader = WWByteReader(data: testData)
            
            let int16: Int16 = try reader.readIntValue()
            let uint32: UInt32 = try reader.readUIntValue()
            let float: Float = try reader.readFloatingPoint()
            let double: Double = try reader.readFloatingPoint()
            
            print("Int16 =", int16)     // -2
            print("UInt32 =", uint32)   // 256
            print("Float =", float)     // 3.1415927
            print("Double =", double)   // 3.141592653589793
        } catch {
            print("Error:", error)
        }
    }
}
```

## 🛠️ 支援類型

| 類型 | 大小 | 方法 |
|------|------|------|
| `Int8`, `UInt8` | 1 byte | `readIntValue()`, `readUIntValue()` |
| `Int16`, `UInt16` | 2 bytes | `readIntValue()`, `readUIntValue()` |
| `Int32`, `UInt32` | 4 bytes | `readIntValue()`, `readUIntValue()` |
| `Int64`, `UInt64` | 8 bytes | `readIntValue()`, `readUIntValue()` |
| `UInt24` | 3 bytes | `readUInt24Value()` → `UInt32` |
| `Float` | 4 bytes | `readFloatingPoint()` |
| `Double` | 8 bytes | `readFloatingPoint()` |

## ⚙️ 技術細節

### Big-Endian 位移核心
```swift
let value = (0..<size).map { index in
    T(data[offset + index]) << (8 * (size - index - 1))  // MSB first
}.reduce(T(0), |)  // 位元 OR 累加
```

### 浮點數轉換
- UInt32(0x40490FDB) → Float(bitPattern:) → 3.1415927
- UInt64(0x400921FB54442D18) → Double(bitPattern:) → 3.141592653589793

## ⚠️ 使用注意

- **僅支援 Big-Endian**：Network byte order
- **自動越界檢查**：`offset + size > data.count` 拋出 `NSError`
- **修改副本**：`WWByteReader` 是 `struct`，傳入時會 copy
- **連續讀取**：`offset` 自動推進


