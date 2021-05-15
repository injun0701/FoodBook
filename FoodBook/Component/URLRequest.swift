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
    
    typealias voidToVoid = () -> ()
    
    //MARK: 로그인
    func apiUserLogin(userid: String, passwd: String, success: @escaping (String, String, String) -> Void, fail: @escaping voidToVoid)  {
        //post 방식으로 전송할 파라미터
        let parameters = ["userid":userid, "userpw":passwd]
        
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
    
    //MARK: 리스트 받아오기
    func apiGetAll(success: @escaping (NSArray) -> Void, fail: @escaping voidToVoid)  {
        
        let url = FoodBookUrl().itemGetall
        
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
                case GetAllStatusCode.success.rawValue:
                    
                    //전체 데이터를 NSDictionary로 받기
                    if let jsonObject = value as? [String:Any] {
                        NSLog("데이터 받아오기 성공")
                        //전체 데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        success(list)
                    }
                case GetAllStatusCode.fail.rawValue:
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
    func apiLastUpdate(success: @escaping (String) -> Void, fail: @escaping voidToVoid)  {
        
        let url = FoodBookUrl().lastupdate
        
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
    func apiItemInsert(itemname: String, price: String, description: String, userimgurl: String, listimgUrl: String, username: String, img: UIImage, success: @escaping voidToVoid, fail: @escaping voidToVoid)  {
        
        let itemname = itemname
        let price = price
        let description = description
        let userimgurl = userimgurl
        let listimgUrl = listimgUrl
        let username = username
        print("urlrequest에서\(listimgUrl)")
        //이미지
        let img = img
        
        //이미지 데이터가 nil이 아니면
        if let imageData = imageDataCheck(img: img, listimgUrl: listimgUrl).0 { //이미지 데이터
            let imageDataFileExtension = imageDataCheck(img: img, listimgUrl: listimgUrl).1 //이미지 확장자
                
            let url = FoodBookUrl().itemInsert
            
            //데이터 수정 - post 방식이고 multipartFormData 방식이고 결과는 json
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(itemname.utf8), withName: "itemname")
                multipartFormData.append(Data(price.utf8), withName: "price")
                multipartFormData.append(Data(username.utf8), withName: "username")
                multipartFormData.append(Data(userimgurl.utf8), withName: "userimgurl")
                multipartFormData.append(Data(description.utf8), withName: "description")
                //이미지파일 전송
                multipartFormData.append(imageData, withName: "imgurl", fileName: listimgUrl, mimeType: "image/\(imageDataFileExtension)")
                
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
    func apiItemEdit(itemid: String, itemname: String, price: String, description: String, listimgUrl: String, username: String, img: UIImage, success: @escaping voidToVoid, fail: @escaping voidToVoid)  {
        
        let itemid = itemid
        let itemname = itemname
        let price = price
        let description = description
        let listimgUrl = listimgUrl
        let username = username
        
        //이미지
        let img = img
        
        //이미지 데이터가 nil이 아니면
        if let imageData = imageDataCheck(img: img, listimgUrl: listimgUrl).0 { //이미지 데이터
            let imageDataFileExtension = imageDataCheck(img: img, listimgUrl: listimgUrl).1 //이미지 확장자
            
            let url = FoodBookUrl().itemUpdate
            
            //데이터 수정 - put 방식이고 multipartFormData 방식이고 결과는 json
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(Data(itemid.utf8), withName: "itemid")
                multipartFormData.append(Data(itemname.utf8), withName: "itemname")
                multipartFormData.append(Data(price.utf8), withName: "price")
                multipartFormData.append(Data(username.utf8), withName: "username")
                multipartFormData.append(Data(description.utf8), withName: "description")
                multipartFormData.append(Data(listimgUrl.utf8), withName: "oldimgurl")
                //이미지파일 전송
                multipartFormData.append(imageData, withName: "imgurl", fileName: listimgUrl, mimeType: "image/\(imageDataFileExtension)")
                
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
    func imageDataCheck(img: UIImage?, listimgUrl: String) -> (Data?, String) {
        let image = img
        var imageDataFileExtension = "jpg"
        
        if listimgUrl.contains(".jpg") {
            print("이미지 이름 : \(listimgUrl)")
            //jpg파일이면 jpegData()로 imageData세팅
            let imageData = image?.jpegData(compressionQuality: 0.5)
            
            //이미지 확장자 "jpg"
            imageDataFileExtension = "jpg"
            
            return (imageData!, imageDataFileExtension)
            
        } else if listimgUrl.contains(".jpeg")  {
            print("이미지 이름 : \(listimgUrl)")
            //jpeg파일이면 jpegData()로 imageData세팅
            let imageData = image?.jpegData(compressionQuality: 0.5)
            
            //이미지 확장자 "jpeg"
            imageDataFileExtension = "jpeg"
            
            return (imageData!, imageDataFileExtension)
            
        } else if listimgUrl.contains(".png")  {
            print("이미지 이름 : \(listimgUrl)")
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
    func apiItemDelete(itemid: String, success: @escaping (Int) -> (), fail: @escaping voidToVoid)  {
        
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
                    if let jseonObject = value as? [String:Any] {
                        let result = jseonObject["result"] as! Int
                        success(result)
                    }
                    NSLog("데이터 삭제 성공")
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
    
    
}
