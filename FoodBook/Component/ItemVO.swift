//
//  ItemVO.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct Item {
    var username : String?
    var userimgurl : String?
    var itemid : Int?
    var itemname : String?
    var price : Int?
    var description : String?
    var imgurl : String?
    var commentcount : Int?
    var likecount : Int?
    var useritemlike : Int? //0이면 false, 1이면 ture
    var updatedate : String?
}
