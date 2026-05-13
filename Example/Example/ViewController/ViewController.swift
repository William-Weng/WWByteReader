//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/04/23.
//

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
        writeData()
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
