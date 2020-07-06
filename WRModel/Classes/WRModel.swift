//
//  WRModel.swift
//  Pods
//
//  Created by 项辉 on 2020/3/11.
//

import UIKit
import KakaJSON

/**模型错误类型*/
/**
*/
public enum WRModelError: Error {
        /**打开数据库错误*/
    case openDBFailure
        /**缺少主键*/
    case missPrimaryKey
        /**保存失败*/
    case saveFailure
        /**查询失败*/
    case selectFailure
        /**删除失败*/
    case deleteFailure
        /**更新失败*/
    case updateFailure
}

//MARK:-
/**模型协议*/
public protocol WRModelProtocol: Convertible {
    init()

    static var ExchangePropertys: [[String : String]] { get }
    static var Table: String { get }
    static var PrimaryKey : String? { get }
    static var IgnoreDBPropertys : [String] { get }
}

//MARK:-
extension WRModelProtocol {
    
    public static var Model: WRStruct<Self>.Type {
        get { return WRStruct.self }
        set {}
    }
    
    /**属性交换*/
    /**
    key: 本地使用属性名
    value: 被替换属性名
    */
    public static var ExchangePropertys: [[String : String]] {
        return []
    }
    
    /**表名*/
    /**
     默认使用对象名
     */
    public static var Table: String {
        return WRStruct<Self>.Table
    }
    
    /**主键*/
    /**
     默认为nil。不设置主键 调用 func update() 时直接保存对象
     */
    public static var PrimaryKey : String? {
        return WRStruct<Self>.PrimaryKey
    }
    
    /**数据库忽略属性*/
    /**
     默认为空
     */
    public static var IgnoreDBPropertys : [String] {
        return []
    }
    
    public var model: WRStruct<Self> {
        get { return WRStruct.init(self) }
        set {}
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        return WRStruct<Self>.ExchangePropertys.filter { (exchange) -> Bool in
            return exchange.first?.key == property.name
        }.first?.values.first ?? property.name
    }
}

//MARK:-

public struct WRStruct<T: WRModelProtocol> {
    var base: T
    init(_ base: T) {
        self.base = base
    }
    
    static var Table: String {
        return "\(T.self)"
    }

    static var ExchangePropertys: [[String : String]] {
        return T.ExchangePropertys
    }

    static var PrimaryKey: String? {
        return nil
    }
    
    static var PrimaryKeyProperty : Property? {
        guard let key = T.PrimaryKey else { return nil }
        return Property(with: key)
    }
    
    static var IgnoreDBPropertys : [String] {
        return T.IgnoreDBPropertys
    }

    static var AllProperties : [Property] {
        guard let mt = Metadata.type(T.self) as? ModelType else {
            debugPrint("Not a class or struct instance.")
            return []
        }
        return mt.properties ?? []
    }
    
    static var DBProperties : [Property] {
        var dbProperties: [Property] = []
        
        for property in AllProperties {
            guard WRDatabase.ColumnType("\(property.type)") != .unknown else {
                continue
            }
            if IgnoreDBPropertys.contains(property.name) {
                continue
            }
            if property.name == PrimaryKey {
                dbProperties.insert(property, at: 0)
            } else {
                dbProperties.append(property)
            }
        }
        return dbProperties
    }
}

//MARK:-
fileprivate typealias WRStruct_Private = WRStruct
private extension WRStruct_Private {

    static func Property(with name: String) -> Property? {
        for property in self.AllProperties {
            if property.name == name {
                return property
            }
        }
        return nil
    }
    
    static func Value(with property : Property?, for model: T) -> Any {
        guard property != nil else {
            return ""
        }
        for children in Mirror(reflecting: model).children {
            if children.label == property!.name {
                if children.label == "char" {
                    return "\(children.value as! Character)"
                }
                return children.value
            }
        }
        return ""
    }
}

//MARK:-
fileprivate typealias WRStruct_Public = WRStruct
public extension WRStruct_Public {
    /**创建模型*/
    /// - parameter json: 模型字典
    /// - returns: 模型对象
    static func Create(json: [String : Any]) -> T {
        return json.kj.model(type: T.self) as! T
    }
    
    /**是否存在表*/
    static var IsExistTable: Bool {
        let isExist = WRDatabase.shared.open() && WRDatabase.shared.tableExists(T.Table)
        WRDatabase.shared.close()
        return isExist
    }
}

//MARK:-
fileprivate typealias WRStruct_Selected = WRStruct
public extension WRStruct_Selected {
    
    
    /**查找所有数据信息*/
    /**
     模型所属数据库表单中的所有数据信息 或所有满足条件的数据信息
    
     keyValues 为 nil 时查询所有表中数据信息
     */
    /// - parameter keyValues: 键值字典
    /// - returns: 数据字典数组
    static func Select(allInfos keyValues: [[String : Any?]]? = nil) throws -> [[String : Any?]]? {
        return try _Select(keyValues: keyValues)
    }
    
    /**查找所有数据模型*/
    /**
     模型所属数据库表单中的所有数据模型 或所有满足条件的数据模型
    
     keyValues 为 nil 时查询所有表中数据模型
    */
    /// - parameter keyValues: 键值字典
    /// - returns: 模型数组
    static func Select(allModels keyValues: [[String : Any?]]? = nil) throws -> [T]? {
        guard let infos = try Select(allInfos: keyValues) else {
            return nil
        }
        return infos.map { (info) -> T in
            return Create(json: info)
        }
    }
    
    /**根据主键值查询信息*/
    /**
     需有主键

     实现 static var PrimaryKey : String? { get } 协议方法
    */
    /// - parameter value: 主键值
    /// - returns: 模型信息
    static func Select(primaryKeyInfo value: Any) throws -> [String : Any?]? {
        guard let primaryKey = T.PrimaryKey else
        {
            throw WRModelError.selectFailure
        }
        return try _Select(infos: true, keyValues: [[primaryKey : value]])?.first
    }
    
    /**根据主键值查询模型*/
    /**
     需有主键

     实现 static var PrimaryKey : String? { get } 协议方法
    */
    /// - parameter value: 主键值
    /// - returns: 模型对象
    static func Select(primaryKeyModel value: Any) throws -> T? {
        guard let info = try Select(primaryKeyInfo: value) else {
            return nil
        }
        return Create(json: info)
    }
    
    /**查找满足条件的单一数据信息*/
    /// - parameter keyValues: 查询条件，属性名值字典
    /// - returns: 数据信息
    static func Select(singleInfo keyValues: [[String : Any?]]) throws -> [String : Any?]? {
        return try _Select(infos: true, keyValues: keyValues)?.first
    }
    
    /**查找满足条件的单一数据对象*/
    /// - parameter keyValues: 查询条件，属性名值字典
    /// - returns: 数据对象
    static func Select(singleModel keyValues: [[String : Any?]]) throws -> T? {
        guard let info = try Select(singleInfo: keyValues) else {
            return nil
        }
        return Create(json: info)
    }

    /**分页查找数据信息*/
    /**
    根据属性名、排序方式分页查找数据信息
    */
    /// - parameter keys: 属性名数组
    /// - parameter descs: 排序方式数组
    /// - parameter pageCount: 每页个数
    /// - parameter pageNumber: 当前页码
    /// - returns: 模型信息数组
    static func Select(sortInfos keys: [String], descs: [Bool] = [false], pageCount: Int = 10, pageNumber: Int = 0) throws -> [[String : Any?]]? {
        guard IsExistTable else { return nil}

        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }

        var infos: [[String : Any?]]? = []
        var keysString = ""
        for (index, key) in keys.enumerated() {
            let desc = descs.count > index ? descs[index] : (descs.first ?? false)
            let descString = desc ? "desc" : "asc"
            keysString += key + " " + descString + (index >= keys.count - 1 ? "" : ", ")
        }
        let selectSql = "select * from \(T.Table) order by \(keysString) limit \(pageCount) offset \(pageNumber * pageCount)"

        if let result = WRDatabase.shared.executeQuery(selectSql, withArgumentsIn: []) {
            while result.next() {
                if let info = result.resultDictionary as? [String : Any?] {
                    infos?.append(info)
                } else {
                    result.close()
                    WRDatabase.shared.close()
                    throw WRModelError.selectFailure
                }
            }
            result.close()
        }
        WRDatabase.shared.close()

        return infos
    }
    
    /**分页查找数据对象*/
    /**
    根据属性名、排序方式分页查找数据对象
    */
    /// - parameter keys: 属性名数组
    /// - parameter descs: 排序方式数组
    /// - parameter pageCount: 每页个数
    /// - parameter pageNumber: 当前页码
    /// - returns: 模型对象数组
    static func Select(sortModels keys: [String], descs: [Bool] = [false], pageCount: Int = 10, pageNumber: Int = 0) throws -> [T]? {
        guard let infos = try Select(sortInfos: keys, descs: descs, pageCount: pageCount, pageNumber: pageNumber) else {
            return nil
        }
        return infos.map { (info) -> T in
            return Create(json: info)
        }
    }
    
    private static func _Select(infos isSingle: Bool = false, keyValues:[[String : Any?]]? = nil) throws -> [[String : Any?]]? {
        guard IsExistTable else { return nil}
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }
        var models: [[String : Any?]]? = []
        let selectSql = Sql_selected(keyValues == nil ? true : false, keyValues)

        if let result = WRDatabase.shared.executeQuery(selectSql, withArgumentsIn: []) {
            while result.next() {
                if let info = result.resultDictionary as? [String : Any] {
                    models?.append(info)
                    if isSingle {
                        break
                    }
                } else {
                    result.close()
                    WRDatabase.shared.close()
                    throw WRModelError.selectFailure
                }
            }
            result.close()
        }
        WRDatabase.shared.close()

        return models
    }
}

//MARK:-
fileprivate typealias WRStruct_Save = WRStruct
public extension WRStruct_Save {
    /**保存对象*/
    /**
    */
    func save() throws {
        guard WRDatabase.shared.open() else {
            throw WRModelError.openDBFailure
        }
        if !WRDatabase.shared.tableExists("\(T.Table)") {
            WRDatabase.shared.executeUpdate(WRStruct.Sql_createTable, withArgumentsIn: [])
        }
        WRDatabase.shared.close()

        guard WRDatabase.shared.goodConnection || WRDatabase.shared.open() else { WRDatabase.shared.close(); throw WRModelError.openDBFailure }
        
        let selectSql = WRStruct.Sql_selected(self.base)
        if let _ = WRDatabase.shared.executeQuery(selectSql, withArgumentsIn: [])
        {
            let deleteSql = WRStruct.Sql_delete(self.base)
            guard WRDatabase.shared.executeUpdate(deleteSql, withArgumentsIn: []) else { WRDatabase.shared.close(); throw WRModelError.saveFailure }
        }
        
        let insertSql = WRStruct.Sql_insert(self.base)
        let values = WRStruct.DBProperties.map { (property) -> Any in
            return WRStruct.Value(with: property, for: self.base)
        }
        
        if !WRDatabase.shared.executeUpdate(insertSql, withArgumentsIn: values) {
            throw WRModelError.saveFailure
        }
        WRDatabase.shared.close()
    }
}

//MARK:-
fileprivate typealias WRStruct_Delete = WRStruct
public extension WRStruct_Delete {
    
    /**删除指定键值*/
    /**
     可直接删除表
    */
    /// - parameter isAll: 是否全部删除
    /// - parameter keyValues: 待删除键值对 ，属性名 ： 属性值
    static func Delete(all isAll: Bool = true, keyValues: [[String : Any?]]? = nil) throws {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }
        
        let deleteSql = isAll ? Sql_delete(true) : Sql_delete(false, keyValues)
        guard WRDatabase.shared.executeUpdate(deleteSql, withArgumentsIn: []) else {
            WRDatabase.shared.close()
            throw WRModelError.deleteFailure
        }
        WRDatabase.shared.close()

    }
        
    /**对象从数据库删除*/
    func delete() throws {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }

        guard WRDatabase.shared.executeUpdate(WRStruct.Sql_delete(self.base), withArgumentsIn: []) else {
            WRDatabase.shared.close()
            throw WRModelError.deleteFailure
        }
        WRDatabase.shared.close()
    }
}

//MARK:-
fileprivate typealias WRStruct_Update = WRStruct
public extension WRStruct_Update {
    /**更新数据库指定数据*/
    /**
    column 属性名
    originalValue 原始值
    replaceValue 替换值
    */
    /// - parameter modifyInfos: 修改信息
    static func Update(_ modifyInfos: [(column: String, originalValue: Any?, replaceValue: Any?)]) throws {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }
        
        let sql = Sql_update(modifyInfos)
        guard WRDatabase.shared.executeUpdate(sql, withArgumentsIn: []) else {
            WRDatabase.shared.close()
            throw WRModelError.updateFailure
        }
        WRDatabase.shared.close()
    }

    /**更新对象*/
    func update() throws {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            WRDatabase.shared.close()
            throw WRModelError.openDBFailure
        }
        
        // 无主键直接保存
        guard let _ = T.PrimaryKey else {
            try save()
            return
        }
        
        let updateSql = WRStruct.Sql_update(self.base)
        
        if let results = WRDatabase.shared.executeQuery(WRStruct.Sql_selected(self.base), withArgumentsIn: []) {
            if results.next() {
                results.close()

                let values = WRStruct.DBProperties.map { (property) -> Any in
                    return WRStruct.Value(with: property, for: self.base)
                }
                guard WRDatabase.shared.executeUpdate(updateSql, withArgumentsIn: values) else {
                    results.close()
                    WRDatabase.shared.close()
                    throw WRModelError.updateFailure
                }
            } else {
                try save()
            }
        } else {
            try save()
        }
        WRDatabase.shared.close()
    }
}

//MARK:-
fileprivate typealias WRStruct_SQL = WRStruct
fileprivate extension WRStruct_SQL {
    static func Sql_match(_ dictionaries: [[String : Any?]], _ isSet: Bool = false) -> String {
        var selectedString = ""
        
        var index = 0
        for (index, dictionary) in dictionaries.enumerated() {
            let relation = isSet ? (index != dictionaries.count - 1 ? " , " : "") : (index != dictionaries.count - 1 ? " and " : "")

            if let column = dictionary.first?.key {
                let value = dictionary.first?.value
                
                if value == nil {
                    selectedString += column + (isSet ? " = null" : " is null ")
                    selectedString += relation
                } else {
                    if let property = Property(with: column), let valueString = WRDatabase.ValueStringForColumn(property, value: value!) {
                        selectedString += column + " = " + valueString
                        selectedString += relation
                    }
                }
            }
        }

        return selectedString
    }
    
    static func Sql_match(_ model: T) -> String {
        var selectedString = ""
        
        if let primary = T.PrimaryKey {
            let value = Value(with: Property(with: primary), for: model)
            let valueString = WRDatabase.ValueStringForColumn(PrimaryKeyProperty!, value: value)
            selectedString = primary + " = " + valueString!
        } else {
            for (index, property) in DBProperties.enumerated()
            {
                let value = Value(with: property, for: model)
                if let valueString = WRDatabase.ValueStringForColumn(property, value: value) {
                    selectedString += property.name + " = " + valueString
                } else {
                    selectedString += property.name + " is null "
                }
                selectedString += (index != DBProperties.count - 1 ? " and " : "")
            }
        }
        return selectedString
    }
    
    static var Sql_createTable : String {
        func columnSql(_ property : Property) -> String {
            let typeName = WRDatabase.TypeStirng(WRDatabase.ColumnType("\(property.type)")) ?? ""
            
            let name = property.name

            if name == T.PrimaryKey {
                return name + " " + typeName + " primary key"
            }

            return name + " " + typeName
        }
        
        var cloumnsSql = ""
        for i in 0..<DBProperties.count {
            let property = DBProperties[i]
            
            cloumnsSql += columnSql(property) + (i == DBProperties.count - 1 ? ")" : ", ")
        }
        return "create table if not exists \(T.Table) " + "(" + cloumnsSql
    }
        
    static func Sql_selected(_ isAll: Bool, _ keyValues:[[String : Any?]]? = nil) -> String {
        if isAll {
            return "select * from \(T.Table)"
        }
        
        guard let dictionaries: [[String : Any?]] = keyValues else {
            return ""
        }

        let selectedString = Sql_match(dictionaries)
                
        return "select * from \(T.Table) where \(selectedString)"
    }
        
    static func Sql_selected(_ model: T) -> String {
        let selectedString = Sql_match(model)
        return "select * from \(T.Table) where \(selectedString)"
    }
        
    static func Sql_delete(_ isAll: Bool, _ keyValues: [ [String : Any?] ]? = nil) -> String {
        if isAll {
            return "delete from \(T.Table)"
        }
        guard let dictionaries: [[String : Any?]] = keyValues else {
            return ""
        }

        let selectedString = Sql_match(dictionaries)

        return "delete from \(T.Table) where \(selectedString)"
    }
    
    static func Sql_delete(_ model: T) -> String {
        let selectedString = Sql_match(model)
        
        return "delete from \(T.Table) where \(selectedString)"
    }
    
    static func Sql_insert(_ model: T) -> String {
        let columnsString = DBProperties.map { $0.name }.joined(separator: ", ")
        let valueString = DBProperties.map { _ in return "?" }.joined(separator: ", ")
                
        return "insert into \(T.Table) (\(columnsString)) values(\(valueString))"
    }
    
    static func Sql_update(_ model: T) -> String {
        let columnsString = DBProperties.map { $0.name + " = ?" }.joined(separator: " , ")
        
        guard let primaryKey = T.PrimaryKey else {
            return ""
        }
        guard let primaryValueString = WRDatabase.ValueStringForColumn(PrimaryKeyProperty!, value: Value(with: PrimaryKeyProperty!, for: model)) else {
            return ""
        }

        return "update \(T.Table) set \(columnsString) where \(primaryKey) = \(primaryValueString)"
    }

    static func Sql_update(_ keyValues: [(column: String, originalValue: Any?, replaceValue: Any?)]) -> String {
        let matchSql = Sql_match( keyValues.map { (info) -> [String : Any?] in
            return [info.column : info.originalValue]
        })
        
        let resultMatchSql = Sql_match(keyValues.map { (info) -> [String : Any?] in
            return [info.column : info.replaceValue]
        }, true)

        return "update \(T.Table) set \(resultMatchSql) where \(matchSql)"

    }
}

//MARK:-
extension Dictionary {
    mutating func model_exchange<K:Hashable>(fromKey:K, toKey:K) {
        if let value = self.removeValue(forKey: fromKey as! Key) {
            self[toKey as! Key] = value
        }
    }
}

