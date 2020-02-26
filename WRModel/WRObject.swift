//
//  WRObject.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/5.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit
import KakaJSON

//MARK:-
@objc extension NSObject : WRObjectProtocol, Convertible {
    //MARK: property
    public var db: WRObjectExtension {
        return WRObjectExtension(self)
    }
    
    @objc open var isExist : Bool {
        get {
            return self.db.isExist
        }
    }
    
    @objc open var table : String {
        get {
            return self.db.table
        }
    }
    
    @objc open var primaryKey : String? {
        get {
            return self.db.primaryKey
        }
    }
    
    @objc open var exchangePropertys :  [[String : String]] {
        get {
            return self.db.exchangePropertys
        }
    }

    @objc open var ignoreDBPropertys : [String] {
        get {
            return self.db.ignoreDBPropertys
        }
    }

    //MARK: func
    @objc public static func create(json : [String : Any]) -> Self {
        return json.kj.model(type: self) as! Self
    }


    public func kj_willConvertToModel(from json: [String: Any]) {
        self.perform(#selector(wr_willConvertToModel(from:)), with: json)
    }
    
    public func kj_didConvertToModel(from json: [String: Any]) {
        self.perform(#selector(wr_didConvertToModel(from:)), with: json)
    }
    
    @objc open func wr_willConvertToModel(from json: [String: Any]) {
        
    }

    @objc open func wr_didConvertToModel(from json: [String: Any]) {
        
    }

}

@objc public protocol WRObjectProtocol{
    var db: WRObjectExtension { get }
}

//MARK:-
@objc open class WRObjectExtension : NSObject {
    //MARK: life
    public required override init() {
        super.init()
    }
    
    @objc public init(_ value: NSObject){
        super.init()
        self.value = value
    }
    //MARK: property
    @objc open var value: NSObject = NSObject()
    
    @objc override open var table : String {
        get {
            return "\(self.value.classForCoder)"
        }
    }
    
    @objc override open var primaryKey : String? {
        get {
            return nil
        }
    }

    @objc override open var exchangePropertys :  [[String : String]] {
        get {
            return [[:]]
        }
    }

    @objc override open var ignoreDBPropertys : [String] {
        return []
    }
    
    @objc override open var isExist : Bool {
        get {
            guard let primaryKey = self.value.primaryKey else {
                return false
            }
            if self.primaryKeyProperty == nil {
                self.primaryKeyProperty = self.propertyWithName(primaryKey)
            }
            
            guard let property = self.primaryKeyProperty else {
                return false
            }
            guard let value = self.valueForProperty(property) else {
                return false
            }

            return self.select(value) != nil
        }
    }

    fileprivate var primaryKeyProperty : Property?

    //MARK: func
    fileprivate var allProperties : [Property] {
        guard let mt = Metadata.type(self.value) as? ModelType else {
            debugPrint("Not a class or struct instance.")
            return []
        }
        return mt.properties ?? []
    }

    fileprivate var dbProperties : [Property] {
        var dbProperties = [Property]()
        
        for property in self.allProperties {
            guard WRDatabase.type("\(property.type)") != .unknown else {
                continue
            }
            if self.value.ignoreDBPropertys.contains(property.name) {
                continue
            }
            if property.name == self.value.primaryKey {
                dbProperties.insert(property, at: 0)
                self.primaryKeyProperty = property
            } else {
                dbProperties.append(property)
            }
        }

        return dbProperties
    }

    fileprivate func propertyWithName(_ name : String) -> Property? {
        for property in self.allProperties {
            if property.name == name {
                return property
            }
        }
        return nil
    }

    fileprivate func valueForProperty(_ property : Property?) -> Any? {
        guard property != nil else {
            return nil
        }
        for children in Mirror(reflecting: self.value).children {
            if children.label == property!.name {
                return children.value
            }
        }
        return nil
    }
    
    fileprivate func valueStringForColumn(_ column : String, value : Any) -> String? {
        guard let property = self.propertyWithName(column) else {
            return nil
        }
        let type = WRDatabase.type("\(property.type)")

        return type == DatabaseDataType.text ? "'\(value)'" : "\(value)"
    }
}

//MARK:-
fileprivate typealias WRObjectExtension_DB = WRObjectExtension
extension WRObjectExtension_DB {
    //MARK: Select

    /**查找指定表中所有数据*/
    /// - parameter exchange: 交换数据 block
    /// - parameter suceess: 是否成功 block
    /// - returns: 表数据的字典数组
    @objc open func select_table(_ exchange: (([[String : Any]])->([[String : Any]]))?, suceess: ((Error?) -> ())?) -> [[String : Any]] {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return []
        }
        
        var infos : [[String:Any]] = []
        
        if let results = WRDatabase.shared.executeQuery("select * from \(self.value.table)", withArgumentsIn: []){
            
            while results.next(){
                if let info = results.resultDictionary as? [String : Any]{
                    infos.append(info)
                }
            }
            results.close()
        }
        
        WRDatabase.shared.close()
        if exchange != nil {
            infos = exchange!(infos) 
        }
        suceess?(nil)
        return infos
    }
    
    @objc open func select_table() -> [[String : Any]] {
        return self.select_table(nil, suceess: nil);
    }
    
    
//    @objc open func select(_ columns : [String], values : [Any], exchange: (([[String : Any]])->([[String : Any]]))?, suceess: ((Error?) -> ())?) -> [[String:Any]] {
//        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
//            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
//            return []
//        }
//
//    }
    /**查找指定列的数据*/
    /// - parameter column: 列名
    /// - parameter value: 值
    /// - parameter exchange: 交换数据 block
    /// - parameter suceess: 是否成功 block
    /// - returns: 表数据的字典数组
    @objc open func select(_ columns : [String], values : [Any], exchange: (([[String : Any]])->([[String : Any]]))?, suceess: ((Error?) -> ())?) -> [[String:Any]] {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return []
        }
        
        var infos : [[String:Any]] = []
        
        var selectedString = ""
        for i in 0..<columns.count {
            let dbColumnName = columns[i]
            guard self.propertyWithName(dbColumnName) != nil else {
                suceess?(NSError(domain: "无此纵队", code: -5, userInfo: nil))
                return []
            }
            let value = values[i]
            let primaryValueString = self.valueStringForColumn(dbColumnName, value: value)!
            
            selectedString += (dbColumnName + " = " + primaryValueString + (i != columns.count - 1 ? " and " : ""))
        }
                
        let sql = "select * from \(self.value.table) where \(selectedString)"

        if let results = WRDatabase.shared.executeQuery(sql, withArgumentsIn: []){
            
            while results.next(){
             if let info = results.resultDictionary as? [String : Any]{
                infos.append(info)
                }
            }
            results.close()
        }
        
        WRDatabase.shared.close()
        if exchange != nil {
            infos = exchange!(infos)
        }
        suceess?(nil)
        return infos
    }
    @objc open func select(_ columns : [String], values : [Any]) -> [[String:Any]] {
        return self.select(columns, values: values, exchange: nil, suceess: nil)
    }

    /**根据主键查找对象*/
    /**
    主键必须有，且需要不为空的主键值
    */
    /// - parameter suceess: 是否成功 block
    /// - returns: 表数据的字典
    @objc open func select(_ primaryValue : Any, suceess: ((Error?) -> ())?) -> [String:Any]? {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return nil
        }
        
        guard let primaryKey = self.value.primaryKey else {
            // 无主键
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return nil
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let _ = self.primaryKeyProperty else {
            // 无主键属性
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return nil
        }

        let primaryValueString = self.valueStringForColumn(primaryKey, value: primaryValue)!
        
        var userInfo : [String:Any]? = nil
                
        let sql = "select * from \(self.value.table) where \(primaryKey) = \(primaryValueString)"
        
        if let results = WRDatabase.shared.executeQuery(sql, withArgumentsIn: []){
            
            results.next()
            if let info = results.resultDictionary as? [String : Any]{
                userInfo = info
            }
            results.close()
        }
        
        WRDatabase.shared.close()
        return userInfo
    }
    @objc open func select(_ primaryValue : Any) -> [String:Any]? {
        return self.select(primaryValue, suceess: nil)
    }

    //MARK: - Save
    /**保存数据*/
    /**
    无主键暂不可保存
    */
    /// - parameter suceess: 是否成功 block
    @objc open func save(_ suceess: ((Error?) -> ())?) {
        if WRDatabase.shared.open(), !WRDatabase.shared.tableExists("\(self.value.table)") {
            WRDatabase.shared.executeUpdate(self.createTableSql, withArgumentsIn: [])
            WRDatabase.shared.close()
        }
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            // 数据库打开失败
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }

        guard let primaryKey = self.value.primaryKey else {
            // 无主键
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            suceess?(NSError(domain: "无主键的值", code: -3, userInfo: nil))
            return
        }
        
        WRDatabase.shared.executeUpdate("delete from \(self.value.table) where \(primaryKey) = '\(value)'", withArgumentsIn: [])

        var info : [(String, Any)] = [(String, Any)]()
        
        for property in self.dbProperties {
            var name = property.name
            for info in self.value.exchangePropertys {
                if info.keys.first == property.name {
                    name = info[property.name]!
                    break
                }
            }

            info.append((name, self.valueForProperty(property) as Any))
        }
        let keys = info.map({
            $0.0
        }).joined(separator: ", ")
        
        let valueString : String = info.reduce("") { (result, info) -> String in
            return result.isEmpty ? "?" : result + ", ?"
        }
        
        let insertSql = "insert into \(self.value.table) (\(keys)) values(\(valueString))"

        WRDatabase.shared.executeUpdate(insertSql, withArgumentsIn: info.map({ $0.1 }))

        WRDatabase.shared.close()
        suceess?(nil)
    }
    
    @objc open func save() {
        self.save(nil)
    }

    //MARK: - Delete
    /**删除对象所存表单*/
    /// - parameter suceess: 是否成功 block
    @objc open func deleteAll(_ suceess: ((Error?) -> ())?) {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        WRDatabase.shared.executeUpdate("delete from \(self.value.table)", withArgumentsIn: [])
        WRDatabase.shared.close()
        suceess?(nil)
    }
    @objc open func deleteAll() {
        self.deleteAll(nil)
    }

    @objc open func delete(_ columns: [String], values: [Any], suceess: ((Error?) -> ())?) {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        
        var selectedString = ""
        for i in 0..<columns.count {
            let dbColumnName = columns[i]
            guard self.propertyWithName(dbColumnName) != nil else {
                suceess?(NSError(domain: "无此纵队", code: -5, userInfo: nil))
                return
            }
            let value = values[i]
            let primaryValueString = self.valueStringForColumn(dbColumnName, value: value)!
            
            selectedString += (dbColumnName + " = " + primaryValueString + (i != columns.count - 1 ? " and " : ""))
        }

        WRDatabase.shared.executeUpdate("delete from \(self.value.table) where \(selectedString)", withArgumentsIn: [])
        suceess?(nil)
    }
    @objc open func delete(_ columns: [String], values: [Any]) {
        self.delete(columns, values: values, suceess: nil)
    }
    /**删除单条数据*/
    /**
    无主键暂不可删除
    */
    /// - parameter suceess: 是否成功 block
    @objc open func delete(_ suceess: ((Error?) -> ())?) {
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        
        guard let primaryKey = self.value.primaryKey else {
            // 无主键
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            suceess?(NSError(domain: "无主键的值", code: -3, userInfo: nil))
            return
        }
        
        WRDatabase.shared.executeUpdate("delete from \(self.value.table) where \(primaryKey) = '\(value)'", withArgumentsIn: [])
        
        WRDatabase.shared.close()
        suceess?(nil)
    }
    @objc open func delete() {
        self.delete(nil)
    }

    //MARK: - Update
    /**更新表单指定列*/
    /// - parameter columns: 列名
    /// - parameter values: 列数据
    /// - parameter replaceValues: 替换数据
    /// - parameter suceess: 是否成功 block
    @objc open func update(_ columns : [String], values: [Any], replaceValues: [Any], suceess: ((Error?) -> ())?) {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        
        var dbColumns = ""
        var replaceColumns = ""
        
        for i in 0..<columns.count {
            let dbColumnName = columns[i]
            let replaceValue = replaceValues[i]
            let dbValue = values[i]
            
            dbColumns += (dbColumnName + " = " + "'\(dbValue)'" + (i != columns.count - 1 ? " and " : ""))
            replaceColumns += (dbColumnName + " = " + "'\(replaceValue)'" + (i != columns.count - 1 ? " , " : ""))
        }
            
        let sql = "update \(self.value.table) set \(replaceColumns) where \(dbColumns)"
        if let results = WRDatabase.shared.executeQuery(sql, withArgumentsIn: []) {
            while results.next(){
            }
            results.close()
        }
        WRDatabase.shared.close()
        suceess?(nil)
    }
    @objc open func update(_ columns : [String], values: [Any], replaceValues: [Any]) {
        self.update(columns, values: values, replaceValues: replaceValues, suceess: nil)
    }

    /**更新单条数据指定定列*/
    /**
    无主键暂不可更新
    */
    /// - parameter columns: 列名
    /// - parameter values: 替换值
    /// - parameter suceess: 是否成功 block
    @objc open func update(_ columns : [String], values: [Any], suceess: ((Error?) -> ())?) {
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        
        guard let primaryKey = self.value.primaryKey else {
            // 无主键
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            suceess?(NSError(domain: "无主键的值", code: -3, userInfo: nil))
            return
        }
        
        var succeed : Bool = false

        var replaceColumns = ""
        for i in 0..<columns.count {
            let dbColumnName = columns[i]
            let replaceValue = values[i]
            
            replaceColumns += (dbColumnName + " = " + "'\(replaceValue)'" + (i != columns.count - 1 ? " , " : ""))
        }
        
        let primaryValueString = self.valueStringForColumn(primaryKey, value: value)!
        
        let sql = "update \(self.value.table) set \(replaceColumns) where \(primaryKey) = \(primaryValueString)"
        let selectSql = "select * from \(self.value.table) where \(primaryKey) = \(primaryValueString)"

        if let results = WRDatabase.shared.executeQuery(selectSql, withArgumentsIn: []) {
            results.next()
            if let _ = results.resultDictionary as? [String : Any]{
                succeed = true
            }
            results.close()
        }

        if succeed{
            succeed = WRDatabase.shared.executeUpdate(sql, withArgumentsIn: values)
        }
        WRDatabase.shared.close()
        suceess?(succeed ? nil : NSError(domain: "未找到该主键的对象", code: -4, userInfo: nil))
    }
    @objc open func update(_ columns : [String], values: [Any]) {
        self.update(columns, values: values, suceess: nil)
    }

    /**更新单条数据所有数据*/
    /**
    无主键暂不可更新
    */
    /// - parameter suceess: 是否成功 block
    @objc open func update(_ suceess: ((Error?) -> ())?) {
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            suceess?(NSError(domain: "数据库打开失败", code: -1, userInfo: nil))
            return
        }
        
        guard let primaryKey = self.value.primaryKey else {
            // 无主键
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            suceess?(NSError(domain: "无主键", code: -2, userInfo: nil))
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            suceess?(NSError(domain: "无主键的值", code: -3, userInfo: nil))
            return
        }
        
        var succeed : Bool = false
        var infos : [(String, Any)] = [(String, Any)]()
                
        for property in self.dbProperties {
            var name = property.name
            for info in self.value.exchangePropertys {
                if info.keys.first == property.name {
                    name = info[property.name]!
                    break
                }
            }

            infos.append((name, self.valueForProperty(property) as Any))
        }

        let keys = infos.map({
            $0.0 + " = ?"
        }).joined(separator: " , ")
        
        let values = infos.map({
            $0.1
        })

        let primaryValueString = self.valueStringForColumn(primaryKey, value: value)!

        let sql = "update \(self.value.table) set \(keys) where \(primaryKey) = \(primaryValueString)"
        if let results = WRDatabase.shared.executeQuery("select * from \(self.value.table) where \(primaryKey) = \(primaryValueString)", withArgumentsIn: []) {
            if results.next() {
                if let _ = results.resultDictionary as? [String : Any]{
                    succeed = true
                }
                results.close()
            } else {
                self.save()
            }
        }

        if succeed{
            succeed = WRDatabase.shared.executeUpdate(sql, withArgumentsIn: values)
        }
        WRDatabase.shared.close()
        suceess?(nil)
    }
    @objc open func update() {
        self.update(nil)
    }

}

//MARK:-
fileprivate typealias WRObjectExtension_SQL = WRObjectExtension
extension WRObjectExtension_SQL {
    
    fileprivate var createTableSql : String {
        var cloumnsSql = ""
        
        func columnSql(_ property : Property) -> String {
            let typeName = WRDatabase.typeStirng(WRDatabase.type("\(property.type)")) ?? ""
            
            var name = property.name
            for info in self.value.exchangePropertys {
                if info.keys.first == property.name {
                    name = info[property.name]!
                    break
                }
            }

            if name == self.value.primaryKey {
                return name + " " + typeName + " primary key"
            }

            return name + " " + typeName
        }
        
        for i in 0..<self.dbProperties.count {
            let property = self.dbProperties[i]
            
            cloumnsSql += columnSql(property) + (i == self.dbProperties.count - 1 ? ")" : ", ")
        }
        return "create table if not exists \(self.value.table) " + "(" + cloumnsSql
    }
}
