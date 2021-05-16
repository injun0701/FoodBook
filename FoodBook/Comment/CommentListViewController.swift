//
//  EditContentsViewController.swift
//  Injunstagram
//
//  Created by HongInJun on 2021/05/04.
//

import UIKit

class CommentListViewController: UIViewController {
    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var imgViewContents: UIImageView!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnItemEdit: UIButton!
    
    //셀의 유저네임
    var userName = ""
    //유저 이미지
    var userImg = UIImage()
    //유저 이미지 url
    var userImgUrl = ""
    //셀의 게시물 시간
    var itemDate = ""
    //셀의 게시물 아이디
    var itemId = ""
    //셀의 이미지
    var itemImg = UIImage()
    //셀의 이미지 url
    var itemImgUrl = ""
    //셀의 게시물 이름
    var itemName = ""
    //셀의 가격
    var itemPrice = ""
    //셀의 텍스트
    var itemDescription = ""
    //셀의 날짜
    var listDate = ""
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    //SQLite sql 명령어 객체
    let sql = SQLiteSql()
    //SQLite 파일 urlpath
    let DirectoryPath = SQLiteDocumentDirectoryPath()
    
    //테이블뷰 배열
    var tableList : [Comment] = []
    
    @IBAction func btnItemEditAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListPostViewController") as! ItemListPostViewController
        navi.itemId = itemId
        navi.itemName = itemName
        navi.itemImg = itemImg
        navi.itemImgUrl = itemImgUrl
        navi.itemPrice = itemPrice
        navi.itemDescription = itemDescription
        navi.userImgUrl = userImgUrl
        navi.userName = userName
        navi.mode = "수정"
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    @IBAction func btnCommentAddAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Comment", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "CommentPostViewController") as! CommentPostViewController
        navi.itemId = itemId
        navi.mode = "저장"
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleSetting()
        imgViewSetting()
        tableViewSetting()
        setting()
    }
    
    func titleSetting() {
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func imgViewSetting() {
        DispatchQueue.main.async {
            self.imgViewUser.layer.cornerRadius = self.imgViewUser.frame.height/2
            self.imgViewUser.clipsToBounds = true
        }
    }
    
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentListTableViewCell", bundle: nil), forCellReuseIdentifier: "commentListTableViewCell")
    }
    
    func setting() {
        imgViewUser.image = userImg
        lblUserName.text = userName
        imgViewContents.image = itemImg
        lblItemName.text = itemName
        lblDescription.text = itemDescription
        lblDate.text = itemDate
        lblPrice.text = itemPrice
        
        if userName != UserDefaults.standard.value(forKey: UDkey().username) as! String {
            btnItemEdit.isHidden = true
        }
    }
    
    //MARK: 서버, 로컬 데이터 세팅
    func dataSetting() {
        //초기화
        tableList = []
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let DirectoryPath = "\(DirectoryPath.comment)\(itemId)\(DirectoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(DirectoryPath).path
        
        //데이터베이스 파일이 없으면 다운로드 받아서 저장한 후 출력
        if fileMgr.fileExists(atPath: dbPath) == false { //데이터베이스 파일이 존재하지 않으면
            NSLog("데이터가 없어서 다운받아 출력")
            networkCheck {
                //아이템 추가
                self.itemAdd()
                //마지막 업데이트 시간을 기록
                self.lastUpdateAdd()
            }
        } else { //데이터베이스 파일이 존재하면
            networkCheckSuccessAndFaile {
                //마지막 업데이트 시간 체크해서 시간이 같으면 로컬 데이터 출력, 다르면 서버 데이터 출력
                self.checkApiLastUpdate()
            } faile: { //네트워크가 연결이 안돼서 로컬 데이터 출력
                NSLog("네트워크가 연결이 안돼서 로컬 데이터 출력")
                //로컬 데이터 출력
                self.localData()
            }
        }
    }
    
    //마지막 업데이트 시간 체크해서 시간이 같으면 로컬 데이터 출력, 다르면 서버 데이터 출력
    func checkApiLastUpdate() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let commentDirectoryPath = "\(DirectoryPath.comment)\(itemId)\(DirectoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(commentDirectoryPath).path
        //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
        let updatePath = docPathURL.appendingPathComponent(DirectoryPath.commentupdate).path
        
        //서버에서 마지막 업데이트 시간 받아오기
        req.apiCommentLastUpdate() { result in
            print("result:\(result)")
            
            //업데이트 된 시간을 기혹한 파일의 경로를 이용해 데이터 읽어오기
            let databuffer = fileMgr.contents(atPath: updatePath)
            let updatetime = NSString(data: databuffer!, encoding: String.Encoding.utf8.rawValue) as String?
            
            //로컬에 저장된 시간과 서버의 시간을 비교
            //MARK: 서버의 시간과 로컬의 시간이 같다면 다운로드 받지 않고 SQLite의 내용을 그대로 출력
            if updatetime == result {
                NSLog("서버 업데이트 시간과 로컬 업데이트 시간이 같아서 로컬 데이터 출력")
                //로컬 데이터 출력
                self.localData()
                
            } else { //MARK: 서버 업데이트 시간과 로컬 업데이트 시간이 달라서 서버 데이터 다시 다운로드
                NSLog("서버 업데이트 시간과 로컬 업데이트 시간이 달라서 서버 데이터 다시 다운로드")
                
                //기존 데이터를 지우고 새로 다운로드
                try! fileMgr.removeItem(atPath: dbPath) //데이터베이스 파일 삭제
                try! fileMgr.removeItem(atPath: updatePath) //업데이트 시간 파일 삭제
                self.tableList.removeAll() //itemList 배열 초기화
                //아이템 추가
                self.itemAdd()
                
                //마지막 업데이트 시간을 기록
                self.lastUpdateAdd()
            }
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //마지막 업데이트 시간을 기록
    func lastUpdateAdd() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
        let updatePath = docPathURL.appendingPathComponent(DirectoryPath.commentupdate).path
        
        self.req.apiCommentLastUpdate() { result in
            print("result:\(result)")
            
            //result를 파일에 기록
            let dataBuffer = result.data(using: String.Encoding.utf8)
            fileMgr.createFile(atPath: updatePath, contents: dataBuffer, attributes: nil)
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //아이템 업로드
    func itemAdd() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let commentDirectoryPath = "\(DirectoryPath.comment)\(itemId)\(DirectoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(commentDirectoryPath).path
        
        //서버에서 아이템 데이터 받아오기
        req.apiCommentGet(itemid: itemId) { response in
            print(response)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            //데이터를 저장할 테이블 생성
            let sql = self.sql.createTableComment
            itemDB.executeStatements(sql)
            
         
            //전체 데이터에서 list 키의 값을 배열로 가져오기
            let list = response
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
                    self.tableList.append(item)
                    self.tableList.sort(by: {$0.commentid! > $1.commentid!}) //순서 정렬

                    //데이터를 삽입할 SQL 생성
                    let sql = self.sql.insertIntoComment
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
            }
            //데이터 가져와서 파싱하는 문장 종료
            self.tableView.reloadData()
            itemDB.close()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //로컬 데이터 출력
    func localData() {
        //초기화
        tableList = []
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let commentDirectoryPath = "\(DirectoryPath.comment)\(itemId)\(DirectoryPath.sqlite)"
        let dbPath = docPathURL.appendingPathComponent(commentDirectoryPath).path
        //저장해놓은 데이터베이스 파일의 내용 읽기
        let itemDB = FMDatabase(path: dbPath)
        itemDB.open()
        
        do {
            let sql = self.sql.selectFromComment
            
            //sql 실행
            let rs = try itemDB.executeQuery(sql, values: nil)
            
            //결과를 순회
            while rs.next() {
                var item = Comment()
                item.username = rs.string(forColumn: "username")
                item.userimgurl = rs.string(forColumn: "userimgurl")
                item.comment = rs.string(forColumn: "comment")
                item.itemid = Int(rs.int(forColumn: "itemid"))
                item.commentid = Int(rs.int(forColumn: "commentid"))
                item.updatedate = rs.string(forColumn: "updatedate")
                //데이터를 list에 저장
                self.tableList.append(item)
            }
            //테이블 뷰 다시 출력
            self.tableView.reloadData()
            NSLog("데이터 베이스 읽기 성공")
        } catch let error as NSError {
            NSLog("데이터 베이스 읽기 실패: \(error.localizedDescription)")
        }
        //데이터베이스 닫기
        itemDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSetting()
    }
}

//MARK: 테이블뷰뷰
extension CommentListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableList.count == 0 {
            return 1
        } else {
            return tableList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //사용자 정의 셀 객체를 생성
        let cellIdentifier = "commentListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CommentListTableViewCell else {
            return UITableViewCell()
        }
        if tableList.count == 0 {
            cell.imgViewUser.isHidden = true
            cell.btnEdit.isHidden = true
            cell.lblUserName.text = ""
            cell.lblComment.text = "댓글이 없습니다."
            cell.lblComment.textColor = UIColor.lightGray
            cell.lblPostDate.text = ""
        } else {
            //데이터 찾아오기
            let list = tableList[indexPath.row]
            cell.lblComment.textColor = UIColor.black
            //데이터 출력
            cell.lblUserName.text = list.username
            cell.lblComment.text = list.comment
            cell.lblPostDate.text = list.updatedate
            cell.imgViewUser.isHidden = false

            //유저 이미지 출력
            req.getImg(imgurlName: list.userimgurl!, defaultImgurlName: "userimg", toImg: cell.imgViewUser)
           
            if list.username == UserDefaults.standard.value(forKey: UDkey().username) as? String {
                cell.btnEdit.isHidden = false
                cell.editHandler = {
                    let sb = UIStoryboard(name: "Comment", bundle: nil)
                    let navi = sb.instantiateViewController(withIdentifier: "CommentPostViewController") as! CommentPostViewController
                    navi.itemId = self.itemId
                    navi.commentId = list.commentid!
                    navi.commentText = list.comment!
                    navi.mode = "수정"
                    self.navigationController?.pushViewController(navi, animated: true)
                }
            } else {
                cell.btnEdit.isHidden = true
            }
            
            DispatchQueue.main.async {
                cell.imgViewUser.layer.cornerRadius = cell.imgViewUser.frame.height/2
                cell.imgViewUser.clipsToBounds = true
            }
            
        }
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
