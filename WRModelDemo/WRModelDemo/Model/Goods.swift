//
//  Goods.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/5.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit
import KakaJSON

public class Goods : WRObject {
        
    var goodsId : String = ""
    var goodsName : String = ""
    var goodsSubtitle : String = ""
    var goodsDescription : String = ""
    var storeId : Int = 0
    var evaluates : [GoodsEvaluate]?
    

    override public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "evaluates" : return "evaluateGoodsList"
        default : return property.name
        }
    }
}
