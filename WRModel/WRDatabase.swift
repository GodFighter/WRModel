//
//  WRDatabase.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/7.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit
import FMDB

internal enum DatabaseDataType {
    case unknown
    case text
    case int
    case long
    case bool
    case float
}

public var kWRDBPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/database.db"

public class WRDatabase: FMDatabase {
    
    public static let shared : WRDatabase = {
        let database = WRDatabase(path: kWRDBPath)
        debugPrint("dbPath = \(kWRDBPath)")
        return database
    }()
    
    internal static func type(_ type : String) -> DatabaseDataType {
        switch type {
        case "String", "Optional<String>", "NSString", "Optional<NSString>":
            return .text
        case "Int", "Optional<Int>", "UInt", "Optional<UInt>", "UInt8", "Optional<UInt8>", "Int8", "Optional<Int8>", "UInt16", "Optional<UInt16>", "Int16", "Optional<Int16>":
            return .int
        case "UInt32", "Optional<UInt32>", "Int32", "Optional<Int32>", "UInt64", "Optional<UInt64>", "Int64", "Optional<Int64>":
            return .long
        case "Bool", "Optional<Bool>":
            return .bool
        case "Float", "Optional<Float>", "CGFloat", "Optional<CGFloat>", "Double", "Optional<Double>":
            return .float
        default:
            return .unknown
        }
    }
    
    internal static func typeStirng(_ type : DatabaseDataType) -> String? {
        switch type {
        case .text: return "text"
        case .int: return "int"
        case .long: return "long"
        case .bool: return "bool"
        case .float: return "double"
        default:
            return nil
        }
    }
    
    internal static func typeDefaultValue(_ type : DatabaseDataType) -> Any {
        switch type {
        case .text: return ""
        case .int: return 0
        case .long: return 0
        case .bool: return 0
        case .float: return 0.0
        default:
            return ""
        }
    }
    
}
