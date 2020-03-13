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

struct WRGoods: WRModelProtocol {
//    required init() {
//
//    }
    
    static var ExchangePropertys: [[String : String]] {
        return [["goodName" : "Goods"]]
    }
    
    static var Table: String {
        return "Goods"
    }
    
    static var PrimaryKey: String? {
        return "goodName"
    }

    
    var goodName: String = ""
    var goodPrice: CGFloat = 0
    var storeName: String?
    var goodsLevel: Float? = 0
    var goodsCollect: Bool?

    var stringText: String?
    var nsstringText: NSString? = "1"
    var char: Character? = "2"
    
    var goodsCount: Int?
    var intText: NSInteger? = 4
    var int16Text: Int16? = 5

    
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
            
            try WRGoods.Model.Update([("goodPrice", nil, 20), ("storeName", nil, "lei")])
            
            
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

