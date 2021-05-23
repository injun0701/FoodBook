//
//  Component.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct FoodBookUrl {
    //로컬 서버 url
//    let signUpUserIdCheck = "http://192.168.0.4/user/idcheck?userid="
//    let signUpUserNameCheck = "http://192.168.0.4/user/usernamecheck?username="
//    let signUp = "http://192.168.0.4/user/register"
//    let login = "http://192.168.0.4/user/login"
//    let loginlog = "http://192.168.0.4/user/loginlog/paging?pageno="
//    let noti = "http://192.168.0.4/user/noti/paging?pageno="
//    let notidelete = "http://192.168.0.4/user/noti/delete?username="
//    let noticheckdelete = "http://192.168.0.4/user/noticheck/delete?username="
//    let passwordcheck = "http://192.168.0.4/user/passwordcheck"
//    let passwordupdate = "http://192.168.0.4/user/passwordupdate"
//    let userUpdate = "http://192.168.0.4/user/update"
//    let itemGet = "http://192.168.0.4/item/paging?pageno="
//    let itemGetDetail = "http://192.168.0.4/item/getitem/"
//    let itemLikeGet = "http://192.168.0.4/item/like/paging?pageno="
//    let lastupdate = "http://192.168.0.4/item/lastupdatetime"
//    let imgurl =  "http://192.168.0.4/img/"
//    let itemInsert = "http://192.168.0.4/item/insert"
//    let itemUpdate = "http://192.168.0.4/item/update"
//    let itemDelete = "http://192.168.0.4/item/delete/"
//    let commentGet = "http://192.168.0.4/item/comment/paging?pageno="
//    let commentlastupdate = "http://192.168.0.4/item/comment/lastupdatetime"
//    let commentInsert = "http://192.168.0.4/item/comment/insert"
//    let commentUpdate = "http://192.168.0.4/item/comment/update"
//    let commentDelete = "http://192.168.0.4/item/comment/delete?commentid="
//    let itemLikeInsert = "http://192.168.0.4/item/like/insert"
//    let itemLikeDelete = "http://192.168.0.4/item/like/delete?itemid="
//    let userDelete = "http://192.168.0.4/user/delete?userid="
    
    //서버 url
    let signUpUserIdCheck = "http://foodbook.cafe24app.com/user/idcheck?userid="
    let signUpUserNameCheck = "http://foodbook.cafe24app.com/user/usernamecheck?username="
    let signUp = "http://foodbook.cafe24app.com/user/register"
    let login = "http://foodbook.cafe24app.com/user/login"
    let loginlog = "http://foodbook.cafe24app.com/user/loginlog/paging?pageno="
    let noti = "http://foodbook.cafe24app.com/user/noti/paging?pageno="
    let notidelete = "http://foodbook.cafe24app.com/user/noti/delete?username="
    let noticheckdelete = "http://foodbook.cafe24app.com/user/noticheck/delete?username="
    let passwordcheck = "http://foodbook.cafe24app.com/user/passwordcheck"
    let passwordupdate = "http://foodbook.cafe24app.com/user/passwordupdate"
    let userUpdate = "http://foodbook.cafe24app.com/user/update"
    let itemGet = "http://foodbook.cafe24app.com/item/paging?pageno="
    let itemGetDetail = "http://foodbook.cafe24app.com/item/getitem/"
    let itemLikeGet = "http://foodbook.cafe24app.com/item/like/paging?pageno="
    let lastupdate = "http://foodbook.cafe24app.com/item/lastupdatetime"
    let imgurl =  "http://foodbook.cafe24app.com/item/img/"
    let itemInsert = "http://foodbook.cafe24app.com/item/insert"
    let itemUpdate = "http://foodbook.cafe24app.com/item/update"
    let itemDelete = "http://foodbook.cafe24app.com/item/delete/"
    let commentGet = "http://foodbook.cafe24app.com/item/comment/paging?pageno="
    let commentlastupdate = "http://foodbook.cafe24app.com/item/comment/lastupdatetime"
    let commentInsert = "http://foodbook.cafe24app.com/item/comment/insert"
    let commentUpdate = "http://foodbook.cafe24app.com/item/comment/update"
    let commentDelete = "http://foodbook.cafe24app.com/item/comment/delete?commentid="
    let itemLikeInsert = "http://foodbook.cafe24app.com/item/like/insert"
    let itemLikeDelete = "http://foodbook.cafe24app.com/item/like/delete?itemid="
    let userDelete = "http://foodbook.cafe24app.com/user/delete?userid="
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
enum LoginLogStatusCode : Int {
    case success = 200
    case fail = 400
}
enum NotiStatusCode : Int {
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
enum UserDeleteStatusCode : Int {
    case success = 200
    case fail = 400
}


