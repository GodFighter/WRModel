//
//  ViewController.swift
//  WRModel
//
//  Created by GodFighter on 03/11/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRModel
import KakaJSON

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


enum EnumInt: Int, ConvertibleEnum {
    case Normal
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
    
    var enumText = EnumInt.Normal
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        select()
    }
    
    func save() {
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
            
            try object.model.save()
            
            print(object)
       } catch let error {
            print(error)
        }

    }
    
    func select() {
        let goods = try? WRGoods.Model.Select(sortInfos: ["goodsStorePrice"], descs: [false], pageCount: 1, pageNumber: 0)
        
        print(goods)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

