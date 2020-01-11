//
//  Goods.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/5.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit
import KakaJSON

public class Goods : NSObject {
        
        
    var goodsId : String = ""
    var goodsName : NSString = ""
    var goodsSubtitle : String = ""
    var goodsDescription : String?
    var storeId : Double = 0
    var evaluates : [GoodsEvaluate]?
    var name : String = ""
    
    public override init() {
        super.init()        
    }
    
    public override var table: String {
        return "Good"
    }
    
    public override var primaryKey: String? {
        return "goodsId"
    }
    
    override public func wr_willConvertToModel(from json: [String : Any]) {
        print("wr_willConvertToModel")
    }
    
    override public func wr_didConvertToModel(from json: [String : Any]) {
        print("wr_didConvertToModel")
    }
    

    
    
//    public override var primaryKey: String? {
//        return "goodsId"
//    }

//    public override var exchangePropertys: [[String : String]] {
//        return [["evaluates" : "evaluateGoodsList"]]
//    }
//    public override var primaryKey: String? {
//        return "goodsId"
//    }
//    public override var table : String {
//        return "Good"
//    }
//
//    override public func kj_willConvertToModel(from json: [String : Any]) {
//
//    }
//
//    override public func kj_didConvertToModel(from json: [String : Any]) {
//
//    }
    
}
