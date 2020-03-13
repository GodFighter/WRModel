//
//  ViewController.swift
//  WRModel
//
//  Created by GodFighter on 03/11/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRModel

//struct WRStore: WRModelProtocol {
//    static var Table: String {
//        return
//    }
//}

struct WRGoodsEvaluate: WRModelProtocol {
    var gevalId: String = ""
    var gevalAddTime: Int64?
    var gevalScore: Int = 0
    var image: String?
    
    static var ExchangePropertys: [[String : String]] {
        return [["image" : "specInfo"]]
    }

}

struct WRGoodsMembership: WRModelProtocol {
    var goodsId: String = ""
    
    static var ExchangePropertys: [[String : String]] {
        return [["goodsId" : "activityId"]]
    }

}

struct WRGoodsActivity: WRModelProtocol {
    var memberShip: WRGoodsMembership?

    static var ExchangePropertys: [[String : String]] {
        return [["memberShip" : "shopActivityMembership"]]
    }
}


struct WRGoods: WRModelProtocol {
    static var ExchangePropertys: [[String : String]] {
        return [["evaluates" : "evaluateGoodsList"] , ["activities" : "shopActivityList"]]
    }
    
    static var IgnoreDBPropertys: [String] {
        return ["goodsCollect"]
    }
    
    static var Table: String {
        return "Goods"
    }
    
    static var PrimaryKey: String? {
        return "goodsId"
    }
    
    var goodsId: String = ""
    var goodsName: String = ""
    var goodsNameMn: String?
    var goodsStorePrice: CGFloat = 0

    var evaluates: [WRGoodsEvaluate]?
    var activities: [WRGoodsActivity]?
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? WRGoods.Model.SelectAll()
        
//        let objects = try? WRGoods.Model.SelectAll()
//        let object = try? WRGoods.Model.Select("3333")
//        print(object??.goodName)
        
//        let objects = try? WRGoods.Model.Select([  ["goodName" : "3333"], ["goodPrice" : "0"]])
//        print(objects)
        
//        let object = try! WRGoods.Model.Select(["goodPrice" : 0])
//        print(object?.goodName)
        
        do {
            
            guard  let url = Bundle.main.path(forResource: "response_1572919417658", ofType: "json") else {
                print("url 没有数据")//如果没有取到，按照上面步骤验查一下。
                return
            }

            let data = try? Data(contentsOf: URL(fileURLWithPath: url), options: Data.ReadingOptions.alwaysMapped)
            
            guard data != nil else {
                return
            }
            
            var dataJson : [String : Any] = [:]
            do {
                dataJson = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
            } catch {
                print("error")
            }
            
            let object = WRGoods.Model.Create(json: dataJson)
            
            print(object)

//            let object1 = WRGoods.Model.Create(json: ["Goods" : "4444", "goodPrice" : 0, "storeName" : "storeName"])
//            try object1.model.save()
//
//            let object2 = WRGoods.Model.Create(json: ["Goods" : "2222", "goodPrice" : 0])
//            try object2.model.save()
//
//            let object3 = WRGoods.Model.Create(json: ["Goods" : "3333", "goodPrice" : 0])
//            try object3.model.save()

//            let object = try WRGoods.Model.Select("3333")
//            try object?.model.delete()
            
//            try WRGoods.Model.Delete([["goodPrice" : nil]])
            
//            try WRGoods.Model.Delete([["goodPrice" : nil], ["goodName" : "2222"]])
            
//            try WRGoods.Model.Delete([["goodName" : "3333"], ["goodPrice" : 0]])
            
//            var object1 = WRGoods.Model.Create(json: ["Goods" : "4444", "goodPrice" : 50, "storeName" : "storeName"])
//            object1.storeName = nil
//            try object1.model.update()
            
//            try WRGoods.Model.Update([("goodPrice", nil, 20), ("storeName", nil, "lei")])
            
            
        } catch let error {
            print(error)
        }

        //        try? object.model.save()
//        print(WRGoods.Model.IsExistTable)
        //        var object = WRGoods.Model.create(json: ["Goods" : "12345"])
//        print(WRGoods.primaryKey)
//        print(WRGoods.table)
//        print(WRGoods.Model.isExistTable)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

