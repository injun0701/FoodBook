//
//  ItemDataConfig.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/18.
//

import UIKit

extension UIViewController {
    
    //MARK: 아이템 리스트 - 아이템 업로드
    func itemAdd(page: Int, count: Int, success: @escaping ([Item]) -> ()) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        
        //서버에서 아이템 데이터 받아오기
        req.apiItemGet(page: page, count: count, searchKeyWord: nil) { allcount, searchcount, list in
            print(list)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            
            //데이터를 저장할 테이블 생성
            let sql = SQLiteSql().createTableItem
            itemDB.executeStatements(sql)
            
            var itemList: [Item] = []
            
            //배열의 데이터 순회
            for index in 0...(list.count - 1) {
                    //배열에서 하나씩 가져오기
                let itemDict = list[index] as! [String: Any] //NSDictionary
                //하나의 DTO 객체를 생성
                var item = Item()
                //json 파싱해서 객체에 데이터 대입
                item.username = itemDict["username"] as? String
                item.userimgurl = itemDict["userimgurl"] as? String
                item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                item.itemname = itemDict["itemname"] as? String
                item.price = ((itemDict["price"] as! NSNumber).intValue)
                item.commentcount = ((itemDict["commentcount"] as! NSNumber).intValue)
                item.likecount = ((itemDict["likecount"] as! NSNumber).intValue)
                item.useritemlike = ((itemDict["useritemlike"] as! NSNumber).intValue)
                item.description = itemDict["description"] as? String
                item.imgurl = itemDict["imgurl"] as? String
                item.updatedate = itemDict["updatedate"] as? String
                //배열에 추가
                itemList.append(item)
                itemList.sort(by: {$0.itemid! > $1.itemid!}) //순서 정렬

                //데이터를 삽입할 SQL 생성
                let sql = SQLiteSql().insertIntoItem
                //파라미터 생성
                var paramDict = [String:Any]()
                paramDict["username"] = item.username!
                paramDict["userimgurl"] = item.userimgurl!
                paramDict["itemid"] = item.itemid!
                paramDict["itemname"] = item.itemname!
                paramDict["price"] = item.price!
                paramDict["commentcount"] = item.commentcount!
                paramDict["likecount"] = item.likecount!
                paramDict["useritemlike"] = item.useritemlike!
                paramDict["description"] = item.description!
                paramDict["imgurl"] = item.imgurl!
                paramDict["updatedate"] = item.updatedate!
                
                //sql 실행
                itemDB.executeUpdate(sql, withParameterDictionary: paramDict)
            }//반복문 종료
            
            //전체 데이터의 개수
            UserDefaults.standard.set(allcount, forKey: UDkey().itemcount)
            
            success(itemList)
            itemDB.close()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    
    //MARK: 공통 - 마지막 업데이트 시간 체크해서 시간이 같으면 로컬 데이터 출력, 다르면 서버 데이터 출력
    func checkApiLastUpdate(updatePathName: String, urlName: String, updatetimeSame: @escaping () -> (), updatetimeDifferent: @escaping () -> ()) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var updatePath = ""
        if updatePathName == LastUpdateParameterName().update {
            //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
            updatePath = docPathURL.appendingPathComponent(directoryPath.update).path
        } else if updatePathName == LastUpdateParameterName().commentupdate {
            updatePath = docPathURL.appendingPathComponent(directoryPath.commentupdate).path
        }
        
        var url = ""
        if urlName == LastUpdateParameterName().lastupdate {
            url = FoodBookUrl().lastupdate
        } else if urlName == LastUpdateParameterName().commentlastupdate {
            url = FoodBookUrl().commentlastupdate
        }
        
        //서버에서 마지막 업데이트 시간 받아오기
        req.apiLastUpdate(url: url) { result in
            print("result:\(result)")
            
            //업데이트 된 시간을 기혹한 파일의 경로를 이용해 데이터 읽어오기
            let databuffer = fileMgr.contents(atPath: updatePath)
            let updatetime = NSString(data: databuffer!, encoding: String.Encoding.utf8.rawValue) as String?
            
            //로컬에 저장된 시간과 서버의 시간을 비교
            //MARK: 서버의 시간과 로컬의 시간이 같다면 다운로드 받지 않고 SQLite의 내용을 그대로 출력
            if updatetime == result {
                NSLog("서버 업데이트 시간과 로컬 업데이트 시간이 같아서 로컬 데이터 출력")
                updatetimeSame()
                
            } else { //MARK: 서버 업데이트 시간과 로컬 업데이트 시간이 달라서 서버 데이터 다시 다운로드
                NSLog("서버 업데이트 시간과 로컬 업데이트 시간이 달라서 서버 데이터 다시 다운로드")
                //마지막 업데이트 시간을  로컬 데이터베이스에 기록
                self.lastUpdateAddToLocal(updatePathName: updatePathName, urlName: urlName)
                updatetimeDifferent()
            }
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //MARK: 아이템 리스트 - 아이템의 마지막 업데이트 시간을 로컬 데이터베이스에 기록
    func lastUpdateAddToLocal(updatePathName: String, urlName: String) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var updatePath = ""
        if updatePathName == LastUpdateParameterName().update {
            //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
            updatePath = docPathURL.appendingPathComponent(directoryPath.update).path
        } else if updatePathName == LastUpdateParameterName().commentupdate {
            updatePath = docPathURL.appendingPathComponent(directoryPath.commentupdate).path
        }
        
        var url = ""
        if urlName == LastUpdateParameterName().lastupdate {
            url = FoodBookUrl().lastupdate
        } else if urlName == LastUpdateParameterName().commentlastupdate {
            url = FoodBookUrl().commentlastupdate
        }
        
        req.apiLastUpdate(url: url) { result in
            print("result:\(result)")
            
            //result를 파일에 기록
            let dataBuffer = result.data(using: String.Encoding.utf8)
            fileMgr.createFile(atPath: updatePath, contents: dataBuffer, attributes: nil)
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //MARK: 아이템 리스트 - 로컬 데이터 출력
    func itemLocalData(success: @escaping ([Item]) -> ()) {
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        //저장해놓은 데이터베이스 파일의 내용 읽기
        let itemDB = FMDatabase(path: dbPath)
        itemDB.open()
        
        var itemList: [Item] = []
        
        do {
            //SQLite sql 명령어 객체
            let sql = SQLiteSql().selectFromItem
            
            //sql 실행
            let rs = try itemDB.executeQuery(sql, values: nil)
            
            //결과를 순회
            while  rs.next() {
                var item = Item()
                item.username = rs.string(forColumn: "username")
                item.userimgurl = rs.string(forColumn: "userimgurl")
                item.itemid = Int(rs.int(forColumn: "itemid"))
                item.itemname = rs.string(forColumn: "itemname")
                item.price = Int(rs.int(forColumn: "price"))
                item.commentcount = Int(rs.int(forColumn: "commentcount"))
                item.likecount = Int(rs.int(forColumn: "likecount"))
                item.useritemlike = Int(rs.int(forColumn: "useritemlike"))
                item.description = rs.string(forColumn: "description")
                item.imgurl = rs.string(forColumn: "imgurl")
                item.updatedate = rs.string(forColumn: "updatedate")
                //데이터를 list에 저장
                itemList.append(item)
            }
            NSLog("데이터 베이스 읽기 성공")
            success(itemList)
        } catch let error as NSError {
            NSLog("데이터 베이스 읽기 실패: \(error.localizedDescription)")
        }
        //데이터베이스 닫기
        itemDB.close()
    }
    
    //MARK: 아래로 스크롤 시 아이템 업로드
    func scrollItemAdd(page: Int, count: Int, itemList: [Item], success: @escaping ([Item]) -> ()) {
        
        //서버 통신을 위한 객체
        let req = URLRequest()
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        
        //서버에서 아이템 데이터 받아오기
        req.apiItemGet(page: page, count: count, searchKeyWord: nil) { allcount, searchcount, list in
            print(list)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            
            //전체 데이터의 개수
            UserDefaults.standard.set(allcount, forKey: UDkey().itemcount)
            
            var itemList: [Item] = itemList
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let itemDict = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var item = Item()
                    //json 파싱해서 객체에 데이터 대입
                    item.username = itemDict["username"] as? String
                    item.userimgurl = itemDict["userimgurl"] as? String
                    item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                    item.itemname = itemDict["itemname"] as? String
                    item.price = ((itemDict["price"] as! NSNumber).intValue)
                    item.commentcount = ((itemDict["commentcount"] as! NSNumber).intValue)
                    item.likecount = ((itemDict["likecount"] as! NSNumber).intValue)
                    item.useritemlike = ((itemDict["useritemlike"] as! NSNumber).intValue)
                    item.description = itemDict["description"] as? String
                    item.imgurl = itemDict["imgurl"] as? String
                    item.updatedate = itemDict["updatedate"] as? String
                    //배열에 추가
                    itemList.append(item)
                    itemList.sort(by: {$0.itemid! > $1.itemid!}) //순서 정렬

                    //데이터를 삽입할 SQL 생성
                    let sql = SQLiteSql().insertIntoItem
                    //파라미터 생성
                    var paramDict = [String:Any]()
                    paramDict["username"] = item.username!
                    paramDict["userimgurl"] = item.userimgurl!
                    paramDict["itemid"] = item.itemid!
                    paramDict["itemname"] = item.itemname!
                    paramDict["price"] = item.price!
                    paramDict["commentcount"] = item.commentcount!
                    paramDict["likecount"] = item.likecount!
                    paramDict["useritemlike"] = item.useritemlike!
                    paramDict["description"] = item.description!
                    paramDict["imgurl"] = item.imgurl!
                    paramDict["updatedate"] = item.updatedate!
                    
                    //sql 실행
                    itemDB.executeUpdate(sql, withParameterDictionary: paramDict)
                }//반복문 종료
                success(itemList)
            }
            itemDB.close()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //좋아요 삭제 메소드
    func itemLikeDelete(homePage: Bool, itemid: String, success: @escaping () -> ()) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        req.apiItemLikeDelete(itemid: itemid) {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 삭제가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.itemLike(homePage: homePage) {
                    success()
                }
            }
        } fail: {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //좋아요 업로드 메소드
    func itemLikeInsert(homePage: Bool, itemid: String, success: @escaping () -> ()) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        req.apiItemLikeInsert(itemid: itemid) {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.itemLike(homePage: homePage) {
                    success()
                }
            }
        } fail: {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //좋아요 메소드
    func itemLike(homePage: Bool, success: @escaping () -> ()) {
        //마지막 업데이트 함수 파라미터 이름
        let lastUpdatePara = LastUpdateParameterName()
        
        if homePage == true {
            //SQLite 파일 urlpath
            let directoryPath = SQLiteDocumentDirectoryPath()
            
            //파일 핸들링하기 위한 객체 생성
            let fileMgr = FileManager.default
            
            //데이터베이스 팡리 경로를 생성
            let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
            //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
            let updatePath = docPathURL.appendingPathComponent(directoryPath.update).path
            //기존 데이터를 지우고 새로 다운로드
            try! fileMgr.removeItem(atPath: dbPath) //데이터베이스 파일 삭제
            try! fileMgr.removeItem(atPath: updatePath) //업데이트 시간 파일 삭제
            
        }
      
        success()
        
        //마지막 업데이트 시간을 기록
        lastUpdateAddToLocal(updatePathName: lastUpdatePara.update, urlName: lastUpdatePara.lastupdate)
    }
    
    //MARK: 댓글 업로드
    func commentAdd(page: Int, count: Int, itemId: String, success: @escaping ([Comment], Int) -> ()) {
        //서버 통신을 위한 객체
        let req = URLRequest()
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let commentDirectoryPath = "\(directoryPath.comment)\(itemId)\(directoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(commentDirectoryPath).path
        
        print("id\(itemId)")
        
        //서버에서 아이템 데이터 받아오기
        req.apiCommentGet(itemid: itemId, page: page) { commentCount, list in
            print(list)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            //데이터를 저장할 테이블 생성
            let sql = SQLiteSql().createTableComment
            itemDB.executeStatements(sql)
            
            //전체 데이터의 개수
            let commentCount = commentCount
            
            var commentList: [Comment] = []
            
            //배열의 데이터 순회
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let itemDict = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var item = Comment()
                    //json 파싱해서 객체에 데이터 대입
                    item.username = itemDict["username"] as? String
                    item.userimgurl = itemDict["userimgurl"] as? String
                    item.comment = itemDict["comment"] as? String
                    item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                    item.commentid = ((itemDict["commentid"] as! NSNumber).intValue)
                    item.updatedate = itemDict["updatedate"] as? String
                    //배열에 추가
                    commentList.append(item)
                    commentList.sort(by: {$0.commentid! > $1.commentid!}) //순서 정렬
                    
                    //데이터를 삽입할 SQL 생성
                    let sql = SQLiteSql().insertIntoComment
                    //파라미터 생성
                    var paramDict = [String:Any]()
                    paramDict["username"] = item.username!
                    paramDict["userimgurl"] = item.userimgurl!
                    paramDict["itemid"] = item.itemid!
                    paramDict["commentid"] = item.commentid!
                    paramDict["comment"] = item.comment!
                    paramDict["updatedate"] = item.updatedate!
                    
                    //sql 실행
                    itemDB.executeUpdate(sql, withParameterDictionary: paramDict)
                }//반복문 종료
                success(commentList, commentCount)
            }
            itemDB.close()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //MARK: 댓글 리스트 - 로컬 데이터 출력
    func commentLocalData(itemId: String, success: @escaping ([Comment], Int) -> ()) {
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let commentDirectoryPath = "\(directoryPath.comment)\(itemId)\(directoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(commentDirectoryPath).path
        //저장해놓은 데이터베이스 파일의 내용 읽기
        let itemDB = FMDatabase(path: dbPath)
        itemDB.open()
        
        var commentList: [Comment] = []
        
        do {
            var count = 0
            
            let sql = SQLiteSql().selectFromComment
            
            //sql 실행
            let rs = try itemDB.executeQuery(sql, values: nil)
            
            //결과를 순회
            while rs.next() {
                count = count + 1
                var item = Comment()
                item.username = rs.string(forColumn: "username")
                item.userimgurl = rs.string(forColumn: "userimgurl")
                item.comment = rs.string(forColumn: "comment")
                item.itemid = Int(rs.int(forColumn: "itemid"))
                item.commentid = Int(rs.int(forColumn: "commentid"))
                item.updatedate = rs.string(forColumn: "updatedate")
                //데이터를 list에 저장
                commentList.append(item)
            }
            success(commentList, count)
            NSLog("데이터 베이스 읽기 성공")
        } catch let error as NSError {
            NSLog("데이터 베이스 읽기 실패: \(error.localizedDescription)")
        }
        //데이터베이스 닫기
        itemDB.close()
    }
    
    //MARK: 서치 아래로 스크롤 시 아이템 업로드
    func searchScrollItemAdd(page: Int, itemList: [Item], searchKeyWord: String, success: @escaping ([Item]) -> ()) {
        //이 메소드가 호출될때 마다 페이지 수 1씩 증가
        let page = page + 1
        
        //서버 통신을 위한 객체
        let req = URLRequest()
        
        //서버에서 아이템 데이터 받아오기
        req.apiItemGet(page: page, count: 10, searchKeyWord: searchKeyWord) { allcount, searchcount, list in
            print(list)
            
            var itemList: [Item] = itemList
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let itemDict = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var item = Item()
                    //json 파싱해서 객체에 데이터 대입
                    item.username = itemDict["username"] as? String
                    item.userimgurl = itemDict["userimgurl"] as? String
                    item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                    item.itemname = itemDict["itemname"] as? String
                    item.price = ((itemDict["price"] as! NSNumber).intValue)
                    item.commentcount = ((itemDict["commentcount"] as! NSNumber).intValue)
                    item.likecount = ((itemDict["likecount"] as! NSNumber).intValue)
                    item.useritemlike = ((itemDict["useritemlike"] as! NSNumber).intValue)
                    item.description = itemDict["description"] as? String
                    item.imgurl = itemDict["imgurl"] as? String
                    item.updatedate = itemDict["updatedate"] as? String
                    //배열에 추가
                    itemList.append(item)
                    itemList.sort(by: {$0.itemid! > $1.itemid!}) //순서 정렬
                }//반복문 종료
                success(itemList)
            }
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //MARK: 좋아요 누른 게시판 아래로 스크롤 시 아이템 업로드
    func itemLikeScrollItemAdd(page: Int, itemList: [Item], success: @escaping ([Item]) -> ()) {
        //이 메소드가 호출될때 마다 페이지 수 1씩 증가
        let page = page + 1
        
        //서버 통신을 위한 객체
        let req = URLRequest()
        
        //서버에서 아이템 데이터 받아오기
        req.apiItemLikeGet(page: page, count: 10) { count, list in
            print(list)
            
            var itemList: [Item] = itemList
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let itemDict = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var item = Item()
                    //json 파싱해서 객체에 데이터 대입
                    item.username = itemDict["username"] as? String
                    item.userimgurl = itemDict["userimgurl"] as? String
                    item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                    item.itemname = itemDict["itemname"] as? String
                    item.price = ((itemDict["price"] as! NSNumber).intValue)
                    item.commentcount = ((itemDict["commentcount"] as! NSNumber).intValue)
                    item.likecount = ((itemDict["likecount"] as! NSNumber).intValue)
                    item.useritemlike = ((itemDict["useritemlike"] as! NSNumber).intValue)
                    item.description = itemDict["description"] as? String
                    item.imgurl = itemDict["imgurl"] as? String
                    item.updatedate = itemDict["updatedate"] as? String
                    //배열에 추가
                    itemList.append(item)
                    itemList.sort(by: {$0.itemid! > $1.itemid!}) //순서 정렬
                }//반복문 종료
                success(itemList)
            }
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
}
