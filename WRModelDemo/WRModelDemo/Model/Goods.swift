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
    var goodsName : NSString = ""
    var goodsSubtitle : String = ""
    var goodsDescription : String?
    var storeId : Double = 0
    var evaluates : [GoodsEvaluate]?
    var name : String = ""

    public override var exchangePropertys: [[String : String]] {
        return [["evaluates" : "evaluateGoodsList"]]
    }
    public override var primaryKey: String? {
        return "goodsId"
    }
    public override var table : String {
        return "Good"
    }

}
