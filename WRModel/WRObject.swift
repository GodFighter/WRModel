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
public class WRObject : Convertible{

    public required init() {}

    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
            default : return property.name
        }
    }
}

public extension WRObject {
    static func create(json : [String : Any]) -> Self {
        return json.kj.model(type: Self.self) as! Self
    }
    
}
