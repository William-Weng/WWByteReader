# [WWByteReader](https://swiftpackageindex.com/William-Weng)

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWByteReader)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## 🎉 [相關說明](https://qoaformat.org/qoa-specification.pdf)

> WWByteReader / WWByteWriter is a high-performance big-endian binary reader and writer for parsing and serializing binary data. It is designed for audio/video formats, network packets, and other structured binary payloads, using a unified shift-and-OR approach to process primitive values consistently.
>
> It provides complete support for reading and writing Int, UInt, Float, Double, Data, String, and length-prefixed String, making it suitable for both fixed-size fields and variable-length binary content.

> WWByteReader / WWByteWriter 是一組高效能的 Big-Endian 二進位讀寫器，可用於二進位資料的解析與序列化。適合音訊 / 影片格式、網路封包，以及其他具結構性的 binary payload，並以統一的位移加上 OR 策略處理基礎數值型別。
>
> 目前完整支援讀寫 Int、UInt、Float、Double、Data、String，以及長度前綴字串，因此同時適合固定長度欄位與可變長度的二進位內容。

## ✨ Features

- 🎯 Big-endian binary reading and writing for structured data.
- 🚀 Unified handling for primitive numeric types with a consistent byte-processing model.
- ✅ Supports both fixed-length values and variable-length payloads.
- 🛡️ Built-in support for raw Data, encoded String, and length-prefixed String.
- 📦 Suitable for file parsing, binary protocols, and custom packet formats.

## ✨ 核心特色

- 🎯 支援以 Big-Endian 方式讀寫具結構性的二進位資料。
- 🚀 對基礎數值型別採用一致的位元組處理模型，行為統一。
- ✅ 同時支援固定長度欄位與可變長度 payload。
- 🛡️ 內建支援原始 Data、指定編碼的 String，以及長度前綴字串。
- 📦 適合檔案格式解析、binary protocol 與自訂封包格式。

## 🚀 快速開始

### SPM 安裝
```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWByteReader", .upToNextMinor(from: "1.3.0"))
]
```

### 公開屬性

| WWByteReader 參數名稱 | 說明 |
|-----------|------|
|  `data` | 要讀取的資料 |
|  `offset` | 目前的偏移量 |
|  `remainingCount` | 剩餘位元組數 |

| WWByteWriter 參數名稱 | 說明 |
|-----------|------|
|  `data` | 已寫入的二進位資料本體 |
|  `offset` | 目前寫入位置 |
|  `count` | 目前已寫入的位元組數量 |
|  `isEmpty` | 是否沒有任何資料 |

### 公開 API

| WWByteReader API名稱 | 說明 |
|-----------|------|
|  `readUIntValue()` | 讀取二進制無號數值 (UInt8 / UInt16 / UInt32 / UInt64) |
|  `readUInt24Value()` | 讀取二進制無號數值 (UInt24) |
|  `readIntValue()` | 讀取二進制有號數值 (Int8 / Int16 / Int32 / Int64) |
|  `readFloatingPoint()` | 讀取二進制讀取浮點數值 (Float / Double) |
|  `readUIntValue(size:endian:)` | 讀取二進制無號數值 (位移取值 + 累加 / 預設為 big-endian) |
|  `readData(count:)` | 讀取指定長度的原始資料 |
|  `readString(count:encoding:)`| 讀取指定長度的字串資料 |
|  `readLengthPrefixedString(encoding:lengthType:)` | 讀取一段以長度前綴表示的字串資料 |
|  `remainingData()` | 查看剩餘的 Data，但不移動 offset |
|  `readRemainingData()` | 讀取剩下的 Data |

| WWByteWriter API名稱 | 說明 |
|-----------|------|
|  `writeByte(_:)` | 寫入單一位元組 |
|  `writeBytes(_:)` | 寫入位元組陣列 |
|  `writeString(_:encoding:maxLength:)` | 將字串依指定編碼轉成 `Data` 後寫入 |
|  `writeLengthPrefixedString(_:encoding:lengthType:)` | 將字串寫成 `[長度: UInt16, 字串資料]` 格式 |
|  `reset()` | 清空已寫入資料並重設 offset |
|  `writeData(_:)` | 寫入 `Data` |
|  `writeInteger(_:endian:)` | 寫入固定寬度整數 (預設為 big-endian) |

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
        readData()
    }
    
    func readData() {
        
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
    
    func writeData() {
        
        do {
            var writer = WWByteWriter()
            
            writer.writeInteger(UInt32(1024))
            try writer.writeString("WWDC", encoding: .utf8)
            try writer.writeLengthPrefixedString("Hello World", lengthType: UInt16.self)
            
            let data = writer.data
            var reader = WWByteReader(data: data)
            
            let value: UInt32 = try reader.readUIntValue()
            let text = try reader.readString(count: 4, encoding: .utf8)
            let message = try reader.readLengthPrefixedString(lengthType: UInt16.self)
            
            print("value = \(value)")       // 1024
            print("text = \(text)")         // WWDC
            print("message = \(message)")   // Hello World

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


