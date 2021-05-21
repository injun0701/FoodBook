//
//  Component.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct FoodBookUrl {
    let signUpUserIdCheck = "http://192.168.0.4/user/idcheck?userid="
    let signUpUserNameCheck = "http://192.168.0.4/user/usernamecheck?username"
    let signUp = "http://192.168.0.4/user/register"
    let login = "http://192.168.0.4/user/login"
    let passwordcheck = "http://192.168.0.4/user/passwordcheck"
    let passwordupdate = "http://192.168.0.4/user/passwordupdate"
    let userUpdate = "http://192.168.0.4/user/update"
    let itemGet = "http://192.168.0.4/item/paging?pageno="
    let itemLikeGet = "http://192.168.0.4/item/like/paging?pageno="
    let lastupdate = "http://192.168.0.4/item/lastupdatetime"
    let imgurl =  "http://192.168.0.4/img/"
    let itemInsert = "http://192.168.0.4/item/insert"
    let itemUpdate = "http://192.168.0.4/item/update"
    let itemDelete = "http://192.168.0.4/item/delete/"
    let commentGet = "http://192.168.0.4/item/comment/paging?pageno="
    let commentlastupdate = "http://192.168.0.4/item/comment/lastupdatetime"
    let commentInsert = "http://192.168.0.4/item/comment/insert"
    let commentUpdate = "http://192.168.0.4/item/comment/update"
    let commentDelete = "http://192.168.0.4/item/comment/delete?commentid="
    let itemLikeInsert = "http://192.168.0.4/item/like/insert"
    let itemLikeDelete = "http://192.168.0.4/item/like/delete?itemid="
    
}

struct UDkey {
    let userid = "userid"
    let username = "username"
    let userimgurl = "userimgurl"
    let itemcount = "itemcount"
    let commentcount = "commentcount"
}

struct AESkey {
    let defaultKey : String = "abcdefghijklmnopqrstuvwxyz123456" // default key 32
    //Default iv는 0123456789101112
    //AES.swift 파일에서 iv 확인 가능
}

//enumutation(열거형): 나만의 타입을 만듬
enum SignUpUserIdCheckStatusCode : Int {
    case success = 200
    case fail = 400
}
enum SignUpUserNameCheckStatusCode : Int {
    case success = 200
    case fail = 400
}
enum SignUpStatusCode : Int {
    case success = 200
    case fail = 400
}
enum LoginStatusCode : Int {
    case success = 200
    case fail = 400
}
enum PasswordCheckStatusCode : Int {
    case success = 200
    case fail = 400
}
enum PasswordUpdateStatusCode : Int {
    case success = 200
    case fail = 400
}
enum UserUpdateStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemGetStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemLikeGetStatusCode : Int {
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
enum CommentInsertStatusCode : Int {
    case success = 200
    case fail = 400
}
enum CommentUpdateStatusCode : Int {
    case success = 200
    case fail = 400
}
enum CommentDeleteStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemLikeInsertStatusCode : Int {
    case success = 200
    case fail = 400
}
enum ItemLikeDeleteStatusCode : Int {
    case success = 200
    case fail = 400
}

