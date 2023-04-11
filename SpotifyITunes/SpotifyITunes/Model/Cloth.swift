//
//  Cloth.swift
//  TestDemoMVVM
//
//  Created by Tecorb Technologies on 21/03/23.
//

import Foundation
import SwiftyJSON




class ClothParser: NSObject {
 
    var cloths = Array<ClothModel>()
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        cloths = json["cloth"].arrayValue.map({ (payjson) -> ClothModel in
            return ClothModel(payjson)
        })
       
    }
}

class ClothModel {
    var image: String = ""
    var title: String = ""
    var id: Int = 0
    var category: String = ""
    var description: String = ""
    var price: Int = 0
    
    init(_ json: JSON){
        image = json["image"].stringValue
        title = json["title"].stringValue
        id = json["id"].intValue
        category = json["category"].stringValue
        description = json["description"].stringValue
        price = json["price"].intValue
    }
    
    init(){}
}
