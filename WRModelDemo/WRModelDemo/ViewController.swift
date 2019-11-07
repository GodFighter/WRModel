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
        
        let goods = Goods.create(json: dataJson)
        print("\(goods)")
        goods.goodsName = "goods.name"
        goods.update()
        
        //
//        print(dataJson["goodsId"] as Any)
                             
        

    }


}

