//
//  ViewController.swift
//  WRModelDemo
//
//  Created by 项辉 on 2019/11/5.
//  Copyright © 2019 项辉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
//        let infos = Goods().db.select_table(nil, suceess: nil)
                
        let goods = Goods.create(json: dataJson)
        goods.goodsName = "oaoijsdisjdi"
        goods.db.delete(["goodsName", "storeId"], values: ["蒙古民族的生态文化", 60])
//        let info = goods.db.select("goodsId", value: "e719a33329644fd08e83a7500fbddbe9", exchange: nil, suceess: nil)
//        goods.storeId = 30.0
//        goods.db.save()
//        goods.db.update(["goodsId"], values: [5647])
//        goods.db.select("goodsName", value: "蒙古民族的生态文化")
//        goods.db.save()
////        goods.storeId = 50
////        goods.goodsSubtitle = ""
////        goods.db.save(nil)
////        goods.db.update(["storeId"], values: [76543])
////
//        print("\(info)")

    }


}

