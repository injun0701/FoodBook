//
//  Component.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct FoodBookUrl {
    let login = "http://192.168.0.4/user/login"
    let itemGetall = "http://192.168.0.4/item/getall"
    let lastupdate = "http://192.168.0.4/item/lastupdatetime"
    let imgurl =  "http://192.168.0.4/img/"
    let itemInsert = "http://192.168.0.4/item/insert"
    let itemUpdate = "http://192.168.0.4/item/update"
    let itemDelete = "http://192.168.0.4/item/delete/"
}

struct UDkey {
    let userid = "userid"
    let username = "username"
    let userimgurl = "userimgurl"
}

//enumutation(열거형): 나만의 타입을 만듬
enum LoginStatusCode : Int {
    case success = 200
    case fail = 400
}
enum GetAllStatusCode : Int {
    case success = 200
    case fail = 400
}
enum LastUpdateStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemInsertStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemUpdateStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemDeleteStatusCode : Int {
    case success = 200
    case fail = 400
}

