//
//  WRObject.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/5.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit
import KakaJSON

//@objcMembers
open class WRObject : Convertible{

    public required init() {}
    
    @objc open var table : String {
        return "\(Self.self)"
    }
    
    @objc open var primaryKey : String? {
        return nil
    }

    fileprivate var primaryKeyProperty : Property?

    open var exchangePropertys :  [[String : String]] {
        return [[:]]
    }

}

//MARK:- 
public extension WRObject {
    static func create(json : [String : Any]) -> Self {
        return json.kj.model(type: Self.self) as! Self
    }
    
    
}

//MARK:-
fileprivate typealias WRObject_Convertible = WRObject
extension WRObject_Convertible {

    public func kj_modelKey(from property: Property) -> ModelPropertyKey {

        for info in self.exchangePropertys {
            if info.keys.first == property.name {
                return info[property.name]!
            }
        }
        
        return property.name
    }
    
    fileprivate var allProperties : [Property] {
        guard let mt = Metadata.type(self) as? ModelType else {
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
            if property.name == self.primaryKey {
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
        for children in Mirror(reflecting: self).children {
            if children.label == property!.name {
                return children.value
            }
        }
        return nil
    }
}

//MARK:-
fileprivate typealias WRObject_DB = WRObject
extension WRObject_DB {
    
    public func select_table() -> [[String : Any]] {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            return []
        }
        
        var infos : [[String:Any]] = []
        
        if let results = WRDatabase.shared.executeQuery("select * from \(self.table)", withArgumentsIn: []){
            
            results.next()
            if let info = results.resultDictionary as? [String : Any]{
                infos.append(info)
            }
            results.close()
        }
        
        WRDatabase.shared.close()
        return infos
    }
    
    public func select(_ primaryKey : String) -> [String:Any]? {
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            return nil
        }
        
        var userInfo : [String:Any]? = nil
        
        if let results = WRDatabase.shared.executeQuery("select * from \(self.table) where id = '\(primaryKey)'", withArgumentsIn: []){
            
            results.next()
            if let info = results.resultDictionary as? [String : Any]{
                userInfo = info
            }
            results.close()
        }
        
        WRDatabase.shared.close()
        return userInfo
    }

    public func save() {
        if WRDatabase.shared.open(), !WRDatabase.shared.tableExists("\(self.table)") {
            WRDatabase.shared.executeUpdate(self.createTableSql, withArgumentsIn: [])
            WRDatabase.shared.close()
        }
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            // 数据库打开失败
            return
        }

        guard let primaryKey = self.primaryKey else {
            // 无主键
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            return
        }
        
        WRDatabase.shared.executeUpdate("delete from \(self.table) where \(primaryKey) = '\(value)'", withArgumentsIn: [])

        var info : [(String, Any)] = [(String, Any)]()
        
        for property in self.dbProperties {
            var name = property.name
            for info in self.exchangePropertys {
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
        
        let insertSql = "insert into \(self.table) (\(keys)) values(\(valueString))"

        WRDatabase.shared.executeUpdate(insertSql, withArgumentsIn: info.map({ $0.1 }))

        WRDatabase.shared.close()
    }
    
    public func delete() {
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            return
        }
        
        guard let primaryKey = self.primaryKey else {
            // 无主键
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            return
        }
        
        WRDatabase.shared.executeUpdate("delete from \(self.table) where \(primaryKey) = '\(value)'", withArgumentsIn: [])
        
        WRDatabase.shared.close()
    }
    
    public func update() {
        
        guard WRDatabase.shared.goodConnection ||  WRDatabase.shared.open() else{
            return
        }
        
        guard let primaryKey = self.primaryKey else {
            // 无主键
            return
        }
        
        if self.primaryKeyProperty == nil {
            self.primaryKeyProperty = self.propertyWithName(primaryKey)
        }
        
        guard let property = self.primaryKeyProperty else {
            // 无主键属性
            return
        }
        guard let value = self.valueForProperty(property) else {
            // 无主键值
            return
        }
        
        var succeed : Bool = false
        var info : [(String, Any)] = [(String, Any)]()
        
        for property in self.dbProperties {
            info.append((property.name, self.valueForProperty(property) as Any))
        }
        let keys = info.map({
            $0.0 + " = ?"
        }).joined(separator: " , ")
        
        let values = info.map({
            $0.1
        })

        let sql = "update \(self.table) set \(keys) where \(primaryKey) = '\(value)'"
        if let results = WRDatabase.shared.executeQuery("select * from \(self.table) where \(primaryKey) = '\(value)'", withArgumentsIn: []) {
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
    }
}

//MARK:-
fileprivate typealias WRObject_SQL = WRObject
extension WRObject_SQL {
    
    fileprivate var createTableSql : String {
        var cloumnsSql = ""
        
        func columnSql(_ property : Property) -> String {
            let typeName = WRDatabase.typeStirng(WRDatabase.type("\(property.type)")) ?? ""
            
            var name = property.name
            for info in self.exchangePropertys {
                if info.keys.first == property.name {
                    name = info[property.name]!
                    break
                }
            }

            if name == self.primaryKey {
                return name + " " + typeName + " primary key"
            }

            return name + " " + typeName
        }
        
        for i in 0..<self.dbProperties.count {
            let property = self.dbProperties[i]
            
            cloumnsSql += columnSql(property) + (i == self.dbProperties.count - 1 ? ")" : ", ")
        }
        return "create table if not exists \(self.table) " + "(" + cloumnsSql
    }

}


