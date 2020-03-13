//
//  WRDatabase.swift
//  Pods
//
//  Created by 项辉 on 2020/3/11.
//

import UIKit
import FMDB
import KakaJSON

enum DatabaseDataType {
    case unknown
    case text
    case int
    case long
    case bool
    case float
}

public var kWRDBPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/database.db"
class WRDatabase: FMDatabase {

    static let shared : WRDatabase = {
        let database = WRDatabase(path: kWRDBPath)
        debugPrint("dbPath = \(kWRDBPath)")
        return database
    }()

    static func type(_ type : String) -> DatabaseDataType {
        if type.contains("String") || type.contains("Character") {
            return .text
        } else if type.contains("Int32") || type.contains("Int64") {
            return .long
        } else if type.contains("Int") {
            return .int
        } else if type.contains("Bool") {
            return .bool
        } else if type.contains("Float") || type.contains("Double") {
            return .float
        } else {
            return .unknown
        }
        /*
        switch type {
        case "String", "Optional<String>", "NSString", "Optional<NSString>":
            return .text
        case "Int", "Optional<Int>", "UInt", "Optional<UInt>", "UInt8", "Optional<UInt8>", "Int8", "Optional<Int8>", "UInt16", "Optional<UInt16>", "Int16", "Optional<Int16>":
            return .int
        case "UInt32", "Optional<UInt32>", "Int32", "Optional<Int32>", "UInt64", "Optional<UInt64>", "Int64", "Optional<Int64>":
            return .long
        case "Bool", "Optional<Bool>":
            return .bool
        case "Float", "Optional<Float>", "CGFloat", "Optional<CGFloat>", "Double", "Optional<Double>", "Swift.Float", "Swift.Double", "Optional(Swift.Float)", "Optional(Swift.Double)":
            return .float
        default:
            return .unknown
        }
 */
    }
    
    static func typeStirng(_ type : DatabaseDataType) -> String? {
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
    
    static func typeNullValue(_ type : DatabaseDataType) -> Any {
        switch type {
        case .text: return "null"
        case .int: return 0
        case .long: return 0
        case .bool: return 0
        case .float: return 0.0
        default:
            return ""
        }
    }

    static func ValueStringForColumn(_ property : Property, value : Any) -> String? {
        let type = WRDatabase.type("\(property.type)")
            
        switch type {
        case .text:
            switch value.self {
            case is String:     return "'\(value as! String)'"
            case is Character:  return "'\(value as! Character)'"
            default:            return nil
            }
        case .float:
            switch value.self {
            case is Float:      return "\(value as! Float)"
            case is CGFloat:    return "\(value as! CGFloat)"
            case is Double:     return "\(value as! Double)"
            case is Float32:    return "\(value as! Float32)"
            case is Float64:    return "\(value as! Float64)"
            case is Float80:    return "\(value as! Float80)"
            case is Int:        return "\(Float(value as! Int))"
            case is UInt:       return "\(Float(value as! UInt))"
            case is Int8:       return "\(Float(value as! Int8))"
            case is UInt8:      return "\(Float(value as! UInt8))"
            case is Int16:      return "\(Float(value as! Int16))"
            case is UInt16:     return "\(Float(value as! UInt16))"
            case is Int32:      return "\(Float(value as! Int32))"
            case is UInt32:     return "\(Float(value as! UInt32))"
            case is Int64:      return "\(Float(value as! Int64))"
            case is UInt64:     return "\(Float(value as! UInt64))"
            default:            return nil
            }
        case .int:
            switch value.self {
            case is Int:    return "\(value as! Int)"
            case is UInt:   return "\(value as! UInt)"
            case is Int8:   return "\(value as! Int8)"
            case is UInt8:  return "\(value as! UInt8)"
            case is Int16:  return "\(value as! Int16)"
            case is UInt16: return "\(value as! UInt16)"
            default:        return nil
            }
        case .bool:
            switch value.self {
            case is Bool: return (value as! Bool) ? "1" : "0"
            default: return nil
            }
        case .long:
            switch value.self {
            case is Int32:  return "\(value as! Int32)"
            case is UInt32: return "\(value as! UInt32)"
            case is Int64:  return "\(value as! Int64)"
            case is UInt64: return "\(value as! UInt64)"
            default:        return nil
            }
        default: return nil
        }
    }

}

