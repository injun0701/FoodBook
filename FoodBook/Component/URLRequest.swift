//
//  URLRequest.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import UIKit
import Alamofire
import Nuke

class URLRequest {
    
    typealias VoidToVoid = () -> ()
    
    //MARK: 아이디 중복 체크
    func apiSignUpUserIdCheck(userid: String, success: @escaping () -> Void, fail: @escaping VoidToVoid)  {
        
        //한글일 경우를 대비하려면 인코딩 해야함
        let userIdEncoding = userid.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().signUpUserIdCheck)\(userIdEncoding ?? "")"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case SignUpUserIdCheckStatusCode.success.rawValue:
                    
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("아이디 체크 성공")
                            success()
                        } else {
                            NSLog("아이디 체크 실패")
                            fail()
                        }
                    }
                case SignUpUserIdCheckStatusCode.fail.rawValue:
                    NSLog("아이디 체크 실패")
                    fail()
                default:
                    NSLog("아이디 체크 실패")
                    fail()
                }
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 유저네임 중복 체크
    func apiSignUpUserNameCheck(username: String, success: @escaping () -> Void, fail: @escaping VoidToVoid)  {
        //url은 한글을 인코딩해야함
        
        //한글일 경우를 대비하려면 인코딩 해야함
        let userNameEncoding = username.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().signUpUserNameCheck)\(userNameEncoding ?? "")"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case SignUpUserNameCheckStatusCode.success.rawValue:
                    
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("유저네임 체크 성공")
                            success()
                        } else {
                            NSLog("유저네임 체크 실패")
                            fail()
                        }
                    }
                case SignUpUserNameCheckStatusCode.fail.rawValue:
                    NSLog("유저네임 체크 실패")
                    fail()
                default:
                    NSLog("유저네임 체크 실패")
                    fail()
                }
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 회원가입
    func apiSignUp(userid: String, username: String, passwd: String, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        //post 방식으로 전송할 파라미터
        let parameters = ["userid": userid, "username": username, "userpw": passwd]
        
        let url = FoodBookUrl().signUp
        
        //로그인 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case SignUpStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        //result 키의 데이터 가져오기
                        let result = jsonObject["result"] as! Int32
                        //로그인 성공
                        if result == 1 {
                            success()
                            NSLog("회원가입 성공")
                        } else { //회원가입 실패
                            fail()
                        }
                    }
                case SignUpStatusCode.fail.rawValue:
                    NSLog("회원가입 실패")
                    fail()
                default:
                    NSLog("회원가입 실패")
                    fail()
                }
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 로그인
    func apiUserLogin(userid: String, passwd: String, success: @escaping (String, String, String) -> Void, fail: @escaping VoidToVoid)  {
        
        //post 방식으로 전송할 파라미터
        let parameters = ["userid": userid, "userpw": passwd]
        
        let url = FoodBookUrl().login
        
        //로그인 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case LoginStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        //result 키의 데이터 가져오기
                        let result = jsonObject["result"] as! Int32
                        //로그인 성공
                        if result == 1 {
                            //user키의 값을 가져오기
                            let user = jsonObject["user"] as! NSDictionary
                            //username 가져오기
                            let userid = user["userid"] as! String
                            //username 가져오기
                            let username = user["username"] as! String
                            //userimgurl 가져오기
                            let userimgurl = user["userimgurl"] as! String
                            success(userid, username, userimgurl)
                            NSLog("로그인 성공")
                        } else { //로그인 실패
                            fail()
                        }
                    }
                case LoginStatusCode.fail.rawValue:
                    NSLog("로그인 실패")
                    fail()
                default:
                    NSLog("로그인 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 현재 비밀번호 체크
    func apiUserPasswordCheck(passwd: String, success: @escaping () -> Void, fail: @escaping VoidToVoid)  {
        
        let userid = UserDefaults.standard.value(forKey: UDkey().userid) as? String ?? ""
        
        //post 방식으로 전송할 파라미터
        let parameters = ["userid": userid, "userpw": passwd]
        
        let url = FoodBookUrl().passwordcheck
        
        //현재 비밀번호 체크 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case PasswordCheckStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        //result 키의 데이터 가져오기
                        let result = jsonObject["result"] as! Int32
                        //조회 성공
                        if result == 1 {
                            success()
                            NSLog("현재 비밀번호 조회 성공")
                        } else { //현재 비밀번호 조회 실패
                            fail()
                        }
                    }
                case PasswordCheckStatusCode.fail.rawValue:
                    NSLog("현재 비밀번호 조회 실패")
                    fail()
                default:
                    NSLog("현재 비밀번호 조회 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 비밀번호 변경
    func apiUserPasswordUpdate(passwd: String, success: @escaping () -> Void, fail: @escaping VoidToVoid)  {
        
        let userid = UserDefaults.standard.value(forKey: UDkey().userid) as? String ?? ""
        
        //post 방식으로 전송할 파라미터
        let parameters = ["userid": userid, "userpw": passwd]
        print("userid\(userid), userpw\(passwd)")
        let url = FoodBookUrl().passwordupdate
        
        //비밀번호 변경 - put 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case PasswordUpdateStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        //result 키의 데이터 가져오기
                        let result = jsonObject["result"] as! Int32
                        //로그인 성공
                        if result == 1 {
                            success()
                            NSLog("비밀번호 변경 성공")
                        } else { //비밀번호 변경 실패
                            fail()
                        }
                    }
                case PasswordUpdateStatusCode.fail.rawValue:
                    NSLog("비밀번호 변경 실패")
                    fail()
                default:
                    NSLog("비밀번호 변경 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 유저 정보 수정
    func apiUserEdit(userid: String, username: String, userimgurl: String, img: UIImage, imgChange: Bool, success: @escaping (String, String, String) -> Void, fail: @escaping VoidToVoid)  {
        
        let userid = userid
        let username = username
        let userimgurl = userimgurl
        
        //이미지
        let img = img
        
        //이미지 데이터가 nil이 아니면
        if let imageData = imageDataCheck(img: img, imgurl: userimgurl).0 { //이미지 데이터
            let imageDataFileExtension = imageDataCheck(img: img, imgurl: userimgurl).1 //이미지 확장자
            
            let url = FoodBookUrl().userUpdate
            
            //데이터 수정 - put 방식이고 multipartFormData 방식이고 결과는 json
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(userid.utf8), withName: "userid")
                multipartFormData.append(Data(username.utf8), withName: "username")
                multipartFormData.append(Data(userimgurl.utf8), withName: "oldimgurl")
                if imgChange == true {//이미지를 바꿨다면
                    //이미지파일 전송
                    multipartFormData.append(imageData, withName: "userimgurl", fileName: userimgurl, mimeType: "image/\(imageDataFileExtension)")
                }
            }, to: url, method: .put).validate(statusCode: 200...500).responseJSON { response in
                switch response.result {
                case .success(let value):
                  
                    //응답받은 statusCode
                    let statusCode = response.response?.statusCode ?? 404
                    
                    //성공 실패 케이스 나누기
                    switch statusCode {
                    case UserUpdateStatusCode.success.rawValue:
                        //전체 데이터를 NSDictionary로 변환
                        if let jsonObject = value as? [String:Any] {
                            let result = jsonObject["result"] as! Int32
                            if result == 1 {
                                NSLog("수정 성공")
                                //user키의 값을 가져오기
                                let user = jsonObject["user"] as! NSDictionary
                                //username 가져오기
                                let userid = user["userid"] as! String
                                //username 가져오기
                                let username = user["username"] as! String
                                //userimgurl 가져오기
                                let userimgurl = user["userimgurl"] as! String
                                success(userid, username, userimgurl)
                            } else {
                                NSLog("수정 실패")
                                fail()
                            }
                        }
                    case UserUpdateStatusCode.fail.rawValue:
                        NSLog("수정 실패")
                        fail()
                    default:
                        NSLog("수정 실패")
                        fail()
                    }
                case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                    print(error)
                }
            }
        }
    }
    
    //MARK: 리스트 받아오기
    func apiItemGet(page: Int, count: Int, searchKeyWord: String?, success: @escaping (Int, Int, NSArray) -> Void, fail: @escaping VoidToVoid)  {
        //url은 한글을 인코딩해야함
        
        var searchKeyWord = searchKeyWord
        
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        //한글일 경우를 대비하려면 인코딩 해야함
        let userNameEncoding = userName?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        if searchKeyWord == nil {
            searchKeyWord = ""
        }
        
        //한글일 경우를 대비하려면 인코딩 해야함
        let searchKeyWordEncoding = searchKeyWord?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().itemGet)\(page)&count=\(count)&username=\(userNameEncoding!)&searchkeyword=\(searchKeyWordEncoding!)"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemGetStatusCode.success.rawValue:
                    
                    //전체 데이터를 NSDictionary로 받기
                    if let jsonObject = value as? [String:Any] {
                        NSLog("데이터 받아오기 성공")
                        //데이터에서 전체 데이터 개수를 Int로 가져오기
                        let allcount = jsonObject["allcount"] as! Int
                        //데이터에서 서치한 데이터 전체 개수를 Int로 가져오기
                        let searchcount = jsonObject["searchcount"] as! Int
                        //데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        success(allcount, searchcount, list)
                    }
                case ItemGetStatusCode.fail.rawValue:
                    NSLog("데이터 받아오기 실패")
                    fail()
                default:
                    NSLog("데이터 받아오기 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 좋아요 누른 리스트만 받아오기
    func apiItemLikeGet(page: Int, count: Int, success: @escaping (Int, NSArray) -> Void, fail: @escaping VoidToVoid)  {
        //url은 한글을 인코딩해야함
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        //한글일 경우를 대비하려면 인코딩 해야함
        let userNameEncoding = userName?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().itemLikeGet)\(page)&count=\(count)&username=\(userNameEncoding!)"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemLikeGetStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 받기
                    if let jsonObject = value as? [String:Any] {
                        NSLog("데이터 받아오기 성공")
                        //데이터에서 서치한 데이터 전체 개수를 Int로 가져오기
                        let count = jsonObject["count"] as! Int
                        //데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        success(count, list)
                    }
                case ItemLikeGetStatusCode.fail.rawValue:
                    NSLog("데이터 받아오기 실패")
                    fail()
                default:
                    NSLog("데이터 받아오기 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 마지막 업데이트 시간 받아오기
    func apiLastUpdate(url: String, success: @escaping (String) -> Void, fail: @escaping VoidToVoid)  {
        
        //마지막 업데이트 시간 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: [:])
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case LastUpdateStatusCode.success.rawValue:
                    
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        NSLog("마지막 업데이트 시간 받아오기 성공")
                        //result키 값을 문자열로 불러오기
                        let result = jsonObject["result"] as! String
                        success(result)
                    }
                case LastUpdateStatusCode.fail.rawValue:
                    NSLog("마지막 업데이트 시간 실패")
                    fail()
                default:
                    NSLog("마지막 업데이트 시간 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 이미지 받아오기
    func getImg(imgurlName: String, defaultImgurlName: String, toImg: UIImageView) {
        //메인 스레드에서 작업(일반 스레드는 UI갱신을 못함)
        DispatchQueue.main.async(execute: {
            //이미지 다운로드 받을 URL을 생성
            let url : URL! = URL(string: FoodBookUrl().imgurl + imgurlName)
            //Nuke의 옵션 설정
            let options = ImageLoadingOptions(placeholder: UIImage(named: defaultImgurlName), transition: .fadeIn(duration:0.4))
            //Nuke 라이브러리로 이미지 출력
            Nuke.loadImage(with: url, options: options, into: toImg)
        })
    }
    
    //MARK: 아이템 삽입
    func apiItemInsert(itemname: String, price: String, description: String, itemimgurl: String, username: String, img: UIImage, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        
        let itemname = itemname
        let price = price
        let description = description
        let itemimgurl = itemimgurl
        let username = username
        
        //이미지
        let img = img
        
        //이미지 데이터가 nil이 아니면
        if let imageData = imageDataCheck(img: img, imgurl: itemimgurl).0 { //이미지 데이터
            let imageDataFileExtension = imageDataCheck(img: img, imgurl: itemimgurl).1 //이미지 확장자
                
            let url = FoodBookUrl().itemInsert
            
            //데이터 삽입 - post 방식이고 multipartFormData 방식이고 결과는 json
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(itemname.utf8), withName: "itemname")
                multipartFormData.append(Data(price.utf8), withName: "price")
                multipartFormData.append(Data(username.utf8), withName: "username")
                multipartFormData.append(Data(description.utf8), withName: "description")
                //이미지파일 전송
                multipartFormData.append(imageData, withName: "imgurl", fileName: itemimgurl, mimeType: "image/\(imageDataFileExtension)")
            }, to: url, method: .post).validate(statusCode: 200...500).responseJSON { response in
                switch response.result {
                case .success(let value):
                  
                    //응답받은 statusCode
                    let statusCode = response.response?.statusCode ?? 404
                    
                    //성공 실패 케이스 나누기
                    switch statusCode {
                    case ItemInsertStatusCode.success.rawValue:
                        //전체 데이터를 NSDictionary로 변환
                        if let jsonObject = value as? [String:Any] {
                            let result = jsonObject["result"] as! Int32
                            if result == 1 {
                                NSLog("삽입 성공")
                                success()
                            } else {
                                NSLog("삽입 실패")
                                fail()
                            }
                        }
                    case ItemInsertStatusCode.fail.rawValue:
                        NSLog("삽입 실패")
                        fail()
                    default:
                        NSLog("삽입 실패")
                        fail()
                    }
                case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                    print(error)
                }
            }
        }
    }
    
    //MARK: 아이템 수정
    func apiItemEdit(itemid: String, itemname: String, price: String, description: String, itemimgurl: String, username: String, img: UIImage, imgChange: Bool, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        
        let itemid = itemid
        let itemname = itemname
        let price = price
        let description = description
        let itemimgurl = itemimgurl
        let username = username
        
        //이미지
        let img = img
        
        //이미지 데이터가 nil이 아니면
        if let imageData = imageDataCheck(img: img, imgurl: itemimgurl).0 { //이미지 데이터
            let imageDataFileExtension = imageDataCheck(img: img, imgurl: itemimgurl).1 //이미지 확장자
            
            let url = FoodBookUrl().itemUpdate
            
            //데이터 수정 - put 방식이고 multipartFormData 방식이고 결과는 json
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(itemid.utf8), withName: "itemid")
                multipartFormData.append(Data(itemname.utf8), withName: "itemname")
                multipartFormData.append(Data(price.utf8), withName: "price")
                multipartFormData.append(Data(username.utf8), withName: "username")
                multipartFormData.append(Data(description.utf8), withName: "description")
                multipartFormData.append(Data(itemimgurl.utf8), withName: "oldimgurl")
                if imgChange == true {//이미지를 바꿨다면
                    //이미지파일 전송
                    multipartFormData.append(imageData, withName: "imgurl", fileName: itemimgurl, mimeType: "image/\(imageDataFileExtension)")
                }
            }, to: url, method: .put).validate(statusCode: 200...500).responseJSON { response in
                switch response.result {
                case .success(let value):
                  
                    //응답받은 statusCode
                    let statusCode = response.response?.statusCode ?? 404
                    
                    //성공 실패 케이스 나누기
                    switch statusCode {
                    case ItemUpdateStatusCode.success.rawValue:
                        //전체 데이터를 NSDictionary로 변환
                        if let jsonObject = value as? [String:Any] {
                            let result = jsonObject["result"] as! Int32
                            if result == 1 {
                                NSLog("수정 성공")
                                success()
                            } else {
                                NSLog("수정 실패")
                                fail()
                            }
                        }
                    case ItemUpdateStatusCode.fail.rawValue:
                        NSLog("수정 실패")
                        fail()
                    default:
                        NSLog("수정 실패")
                        fail()
                    }
                case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                    print(error)
                }
            }
        }
    }
    
    //이미지의 이름에서 확장자 체크
    func imageDataCheck(img: UIImage?, imgurl: String) -> (Data?, String) {
        let image = img
        var imageDataFileExtension = "jpg"
        
        if imgurl.contains(".jpg") {
            print("이미지 이름 : \(imgurl)")
            //jpg파일이면 jpegData()로 imageData세팅
            let imageData = image?.jpegData(compressionQuality: 0.5)
            
            //이미지 확장자 "jpg"
            imageDataFileExtension = "jpg"
            
            return (imageData!, imageDataFileExtension)
            
        } else if imgurl.contains(".jpeg")  {
            print("이미지 이름 : \(imgurl)")
            //jpeg파일이면 jpegData()로 imageData세팅
            let imageData = image?.jpegData(compressionQuality: 0.5)
            
            //이미지 확장자 "jpeg"
            imageDataFileExtension = "jpeg"
            
            return (imageData!, imageDataFileExtension)
            
        } else if imgurl.contains(".png")  {
            print("이미지 이름 : \(imgurl)")
            //png파일이면 pngData()로 imageData세팅
            let imageData = image?.pngData()
            
            //이미지 확장자 "png"
            imageDataFileExtension = "png"
            
            return (imageData!, imageDataFileExtension)
            
        } else {
            return (nil, "jpg")
        }
    }
    
    //MARK: 아이템 삭제
    func apiItemDelete(itemid: String, success: @escaping (Int) -> (), fail: @escaping VoidToVoid)  {
        
        let url = "\(FoodBookUrl().itemDelete)\(itemid)"
        
        //데이터 삭제 - delete 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemDeleteStatusCode.success.rawValue:
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int
                        success(result)
                        NSLog("데이터 삭제 성공")
                    }
                case ItemDeleteStatusCode.fail.rawValue:
                    NSLog("데이터 삭제 실패")
                    fail()
                default:
                    NSLog("데이터 삭제 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 댓글 리스트 받아오기
    func apiCommentGet(itemid: String, page: Int, success: @escaping (Int, NSArray) -> Void, fail: @escaping VoidToVoid)  {
        
        let url = "\(FoodBookUrl().commentGet)\(page)&count=3&itemid=\(itemid)"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemGetStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 받기
                    if let jsonObject = value as? [String:Any] {
                        NSLog("데이터 받아오기 성공")
                        //데이터에서 전체 데이터 개수를 Int로 가져오기
                        let count = jsonObject["count"] as! Int
                        //데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        success(count, list)
                    }
                case ItemGetStatusCode.fail.rawValue:
                    NSLog("데이터 받아오기 실패")
                    fail()
                default:
                    NSLog("데이터 받아오기 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 댓글 삽입
    func apiCommentInsert(itemid: String, username: String, comment: String, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        //post 방식으로 전송할 파라미터
        let parameters = ["itemid": itemid, "username": username, "comment": comment]
        
        let url = FoodBookUrl().commentInsert
        
        //로그인 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case CommentInsertStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("댓글 삽입 성공")
                            success()
                        } else {
                            NSLog("댓글 삽입 실패")
                            fail()
                        }
                    }
                case CommentInsertStatusCode.fail.rawValue:
                    NSLog("댓글 삽입 실패")
                    fail()
                default:
                    NSLog("댓글 삽입 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 댓글 수정
    func apiCommentEdit(commentid: String, comment: String, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        //post 방식으로 전송할 파라미터
        let parameters = ["commentid": commentid, "comment": comment]
        
        let url = FoodBookUrl().commentUpdate
        
        //로그인 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .put, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case CommentUpdateStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("댓글 수정 성공")
                            success()
                        } else {
                            NSLog("댓글 수정 실패")
                            fail()
                        }
                    }
                case CommentUpdateStatusCode.fail.rawValue:
                    NSLog("댓글 삽입 실패")
                    fail()
                default:
                    NSLog("댓글 삽입 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 댓글 삭제
    func apiCommentDelete(commentid: String, itemid: String, success: @escaping (Int) -> (), fail: @escaping VoidToVoid)  {
        
        let url = "\(FoodBookUrl().commentDelete)\(commentid)&itemid=\(itemid)"
        
        //데이터 삭제 - delete 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case CommentDeleteStatusCode.success.rawValue:
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int
                        success(result)
                        NSLog("데이터 삭제 성공")
                    }
                case CommentDeleteStatusCode.fail.rawValue:
                    NSLog("데이터 삭제 실패")
                    fail()
                default:
                    NSLog("데이터 삭제 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 좋아요 삽입
    func apiItemLikeInsert(itemid: String, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        
        let username = UserDefaults.standard.value(forKey: UDkey().username) as? String
        
        //post 방식으로 전송할 파라미터
        let parameters = ["itemid": itemid, "username": username ?? ""]
        
        let url = FoodBookUrl().itemLikeInsert
        
        //로그인 - post 방식이고 파라미터 있고 결과는 json
        let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemLikeInsertStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("좋아요 삽입 성공")
                            success()
                        } else {
                            NSLog("좋아요 삽입 실패")
                            fail()
                        }
                    }
                case ItemLikeInsertStatusCode.fail.rawValue:
                    NSLog("좋아요 삽입 실패")
                    fail()
                default:
                    NSLog("좋아요 삽입 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 좋아요 삭제
    func apiItemLikeDelete(itemid: String, success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        //한글일 경우를 대비하려면 인코딩 해야함
        let userNameEncoding = userName?.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().itemLikeDelete)\(itemid)&username=\(userNameEncoding!)"
        
        print(url)
        //데이터 삭제 - delete 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case ItemLikeDeleteStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        if result == 1 {
                            NSLog("좋아요 삭제 성공")
                            success()
                        } else {
                            NSLog("좋아요 삭제 실패")
                            fail()
                        }
                    }
                case ItemLikeDeleteStatusCode.fail.rawValue:
                    NSLog("좋아요 삭제 실패")
                    fail()
                default:
                    NSLog("좋아요 삭제 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 유저 로그인 로그 받아오기
    func apiUserLoginLog(page: Int, success: @escaping (Int, NSArray) -> Void, fail: @escaping VoidToVoid)  {
        
        let userid = UserDefaults.standard.value(forKey: UDkey().userid) as? String ?? ""
        //한글일 경우를 대비하려면 인코딩 해야함
        let useridEncoding = userid.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().loginlog)\(page)&count=15&userid=\(useridEncoding!)"
        
        //데이터 받아오기 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
              
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case LoginLogStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 받기
                    if let jsonObject = value as? [String:Any] {
                        NSLog("데이터 받아오기 성공")
                        //데이터에서 전체 데이터 개수를 Int로 가져오기
                        let count = jsonObject["count"] as! Int
                        //데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        success(count, list)
                    }
                case LoginLogStatusCode.fail.rawValue:
                    NSLog("데이터 받아오기 실패")
                    fail()
                default:
                    NSLog("데이터 받아오기 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
    //MARK: 탈퇴하기
    func apiUserDelete(success: @escaping VoidToVoid, fail: @escaping VoidToVoid)  {
        
        let userid = UserDefaults.standard.value(forKey: UDkey().userid) as? String ?? ""
        //한글일 경우를 대비하려면 인코딩 해야함
        let useridEncoding = userid.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let username = UserDefaults.standard.value(forKey: UDkey().username) as? String ?? ""
        //한글일 경우를 대비하려면 인코딩 해야함
        let usernameEncoding = username.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        
        let url = "\(FoodBookUrl().userDelete)\(useridEncoding!)&username=\(usernameEncoding!)"
        
        //데이터 삭제 - delete 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: nil)
        //요청을 전송하고 결과 사용하기
        request.validate(statusCode: 200...500).responseJSON { response in
            switch response.result {
            case .success(let value):
                
                //응답받은 statusCode
                let statusCode = response.response?.statusCode ?? 404
                
                //성공 실패 케이스 나누기
                switch statusCode {
                case UserDeleteStatusCode.success.rawValue:
                    //전체 데이터를 NSDictionary로 변환
                    if let jsonObject = value as? [String:Any] {
                        let result = jsonObject["result"] as! Int32
                        print("?? \(result)")
                        if result == 1 {
                            NSLog("탈퇴 성공")
                            success()
                        } else {
                            NSLog("탈퇴 실패")
                            fail()
                        }
                    }
                case UserDeleteStatusCode.fail.rawValue:
                    NSLog("탈퇴 실패")
                    fail()
                default:
                    NSLog("탈퇴 실패")
                    fail()
                }
                
            case .failure(let error): //서버와 통신을 못할 때의 실패 케이스 ex)비행기 모드
                print(error)
            }
        }
    }
    
}
