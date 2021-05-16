//
//  ItemListViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit
import Alamofire

class ItemListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    //SQLite sql 명령어 객체
    let sql = SQLiteSql()
    //SQLite 파일 urlpath
    let DirectoryPath = SQLiteDocumentDirectoryPath()
    
    //테이블 뷰에 출력할 데이터 배열
    var itemList: [Item] = []
    
    //내정보 버튼
    @IBAction func btnMyInfoAction(_ sender: UIButton) {
        
    }
    
    //글쓰기 버튼
    @IBAction func btnAddAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListPostViewController") as! ItemListPostViewController
        
        let userImgUrl = UserDefaults.standard.value(forKey: UDkey().userimgurl)
        let userName = UserDefaults.standard.value(forKey: UDkey().username)
        navi.userImgUrl = userImgUrl as! String
        navi.userName = userName as! String
        navi.mode = "저장"
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
    }
    
    //테이블뷰 세팅
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ItemListTableViewCell", bundle: nil), forCellReuseIdentifier: "itemListTableViewCell")
    }
    
    //MARK: 서버, 로컬 데이터 세팅
    func dataSetting() {
        //초기화
        itemList = []
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(DirectoryPath.item).path
        
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
        let dbPath = docPathURL.appendingPathComponent(DirectoryPath.item).path
        //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
        let updatePath = docPathURL.appendingPathComponent(DirectoryPath.update).path
        
        //서버에서 마지막 업데이트 시간 받아오기
        req.apiLastUpdate() { result in
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
                self.itemList.removeAll() //itemList 배열 초기화
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
        let updatePath = docPathURL.appendingPathComponent(DirectoryPath.update).path
        
        self.req.apiLastUpdate() { result in
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
        let dbPath = docPathURL.appendingPathComponent(DirectoryPath.item).path
        
        //서버에서 아이템 데이터 받아오기
        req.apiGetAll() { response in
            print(response)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            //데이터를 저장할 테이블 생성
            let sql = self.sql.createTableItem
            itemDB.executeStatements(sql)
            
         
            //전체 데이터에서 list 키의 값을 배열로 가져오기
            let list = response
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
                item.description = itemDict["description"] as? String
                item.imgurl = itemDict["imgurl"] as? String
                item.updatedate = itemDict["updatedate"] as? String
                //배열에 추가
                self.itemList.append(item)
                self.itemList.sort(by: {$0.itemid! > $1.itemid!}) //순서 정렬

                //데이터를 삽입할 SQL 생성
                let sql = self.sql.insertIntoItem
                //파라미터 생성
                var paramDict = [String:Any]()
                paramDict["username"] = item.username!
                paramDict["userimgurl"] = item.userimgurl!
                paramDict["itemid"] = item.itemid!
                paramDict["itemname"] = item.itemname!
                paramDict["price"] = item.price!
                paramDict["description"] = item.description!
                paramDict["imgurl"] = item.imgurl!
                paramDict["updatedate"] = item.updatedate!
                
                //sql 실행
                itemDB.executeUpdate(sql, withParameterDictionary: paramDict)
            }//반복문 종료
            
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
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(DirectoryPath.item).path
        //저장해놓은 데이터베이스 파일의 내용 읽기
        let itemDB = FMDatabase(path: dbPath)
        itemDB.open()
        
        do {
            let sql = self.sql.selectFromItem
            
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
                item.description = rs.string(forColumn: "description")
                item.imgurl = rs.string(forColumn: "imgurl")
                item.updatedate = rs.string(forColumn: "updatedate")
                //데이터를 list에 저장
                self.itemList.append(item)
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
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        //네비게이션 세팅
        navbarSetting(title: "FoodBook")
        //데이터 세팅
        dataSetting()
    }
}

//MARK: 테이블뷰
extension ItemListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //셀의 identifier로 사용할 문자열
        let cellIdentifier = "itemListTableViewCell"
        //재사용 가능한 셀이 있으면 찾아오기
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemListTableViewCell else {
            return UITableViewCell()
        }
        
        let item = itemList[indexPath.row]
        
        cell.mylbl.text = item.username
        
        print(item.userimgurl!)
        
        //유저 이미지 출력
        req.getImg(imgurlName: item.userimgurl!, defaultImgurlName: "userimg", toImg: cell.myImgView)
        
        cell.lblDate.text = item.updatedate
        cell.lblTitle.text = item.itemname
        cell.lblText.text = item.description
        cell.lblPrice.text = "가격: \(item.price ?? 0)"
        
        //아이템 이미지 출력
        req.getImg(imgurlName: item.imgurl!, defaultImgurlName: "gray", toImg: cell.imgViewlist)
        
        //유저이미지 라운드 처리
        DispatchQueue.main.async {
            cell.myImgView.layer.cornerRadius = cell.myImgView.frame.height/2
            cell.myImgView.clipsToBounds = true
        }
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //테이블 셀의 인덱스
        let cellIndexPath = tableView.indexPathForSelectedRow
        //현재 셀 불러오기
        guard let currentCell = tableView.cellForRow(at: cellIndexPath!) as? ItemListTableViewCell else { return }
        let item = itemList[indexPath.row]
        
        let sb = UIStoryboard(name: "Comment", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "CommentListViewController") as! CommentListViewController
        navi.itemId = "\(item.itemid!)"
        navi.itemName = item.itemname!
        navi.itemImg = currentCell.imgViewlist.image!
        navi.itemImgUrl = item.imgurl!
        navi.itemPrice = "\(item.price!)"
        navi.itemDescription = item.description!
        navi.itemDate = "\(item.updatedate!)"
        navi.userImgUrl = item.userimgurl!
        navi.userImg = currentCell.myImgView.image!
        navi.userName = item.username!
        self.navigationController?.pushViewController(navi, animated: true)
    }
}


