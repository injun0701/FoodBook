//
//  ItemListViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit
import Alamofire
import Nuke

//DTO 역할을 수행할 구조체
struct Item {
    var username : String?
    var itemid : Int?
    var itemname : String?
    var price : Int?
    var description : String?
    var imgurl : String?
    var likecount : Int?
    var updatedate : String?
}

class ItemListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    //테이블 뷰에 출력할 데이터 배열
    var itemList: [Item] = []
    
    
    @IBAction func btnMyInfoAction(_ sender: UIButton) {
        
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListInputViewController") as! ItemListInputViewController
        navi.mode = "저장"
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
    }
    
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    //MARK: 서버, 로컬 데이터 세팅
    func dataSetting() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("item.sqlite").path
        //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
        let updatePath = docPathURL.appendingPathComponent("update.txt").path
        
        //MARK: 데이터베이스 파일이 없으면 다운로드 받아서 저장한 후 출력
        if fileMgr.fileExists(atPath: dbPath) == false { //MARK: 데이터베이스 파일이 존재하지 않으면
            NSLog("데이터가 없어서 다운받아 출력함")
            
            networkCheck {
                //아이템 추가
                self.itemAdd()
                
                //업데이트가 수행된 시간을 파일에 저장
                //업데이트 된 시간 정보를 서버에서 받아오기
                let updateUrl = "http://192.168.0.4/item/lastupdatetime"
                //JSON 데이터를 get 방식으로 다운로드
                let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                updaterequest.responseJSON { response in
                    //받은 데이터를 NSDictionary로 변환
                    if let jsonObject = response.value as? [String:Any] {
                        //result키 값을 문자열로 불러오기
                        let result = jsonObject["result"] as? String
                        
                        //result를 파일에 기록
                        let dataBuffer = result?.data(using: String.Encoding.utf8)
                        fileMgr.createFile(atPath: updatePath, contents: dataBuffer, attributes: nil)
                    }
                }
            }
        } else { //MARK: 데이터베이스 파일이 존재하면
            //업데이트 된 시간을 기혹한 파일의 경로를 이용해 데이터 읽어오기
            let databuffer = fileMgr.contents(atPath: updatePath)
            let updatetime = NSString(data: databuffer!, encoding: String.Encoding.utf8.rawValue) as String?
            networkCheckSuccessAndFaile {
                //업데이트 된 시간 정보를 서버에서 받아오기
                let updateUrl = "http://192.168.0.4/item/lastupdatetime"
                //JSON 데이터를 get 방식으로 다운로드
                let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                updaterequest.responseJSON { response in
                    //받은 데이터를 NSDictionary로 변환
                    if let jsonObject = response.value as? [String:Any] {
                        //result키 값을 문자열로 불러오기
                        let result = jsonObject["result"] as? String
                        
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
                            
                            //업데이트가 수행된 시간을 파일에 저장
                            //업데이트 된 시간 정보를 서버에서 받아오기
                            let updateUrl = "http://192.168.0.4/item/lastupdatetime"
                            //JSON 데이터를 get 방식으로 다운로드
                            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                            updaterequest.responseJSON { response in
                                //받은 데이터를 NSDictionary로 변환
                                if let jsonObject = response.value as? [String:Any] {
                                    //result키 값을 문자열로 불러오기
                                    let result = jsonObject["result"] as? String
                                    
                                    //result를 파일에 기록
                                    let dataBuffer = result?.data(using: String.Encoding.utf8)
                                    fileMgr.createFile(atPath: updatePath, contents: dataBuffer, attributes: nil)
                                }
                            }
                        }
                    }
                }
            } faile: { //MARK: 네트워크가 연결이 안돼서 로컬 데이터 출력
                NSLog("네트워크가 연결이 안돼서 로컬 데이터 출력")
                //로컬 데이터 출력
                self.localData()
            }
        }
    }
    
    //아이템 업로드
    func itemAdd() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("item.sqlite").path
        
        //데이터를 다운로드 받을 URL
        let url = "http://192.168.0.4/item/getall"
        
        //데이터 다운로드 - get 방식이고 파라미터 없고 결과는 json
        let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
        request.responseJSON { response in
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            //데이터를 저장할 테이블 생성
            let sql = "create table if not exists item(itemid INTEGER not null primary key, username text, itemname text, price INTEGER, description text, imgurl text, updatedate text)"
            itemDB.executeStatements(sql)
            
            //전체 데이터를 객체로 받기
            if let jsonObject = response.value as? [String:Any] {
                //전체 데이터에서 list 키의 값을 배열로 가져오기
                let list = jsonObject["list"] as! NSArray
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                    //배열에서 하나씩 가져오기
                    let itemDict = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var item = Item()
                    //json 파싱해서 객체에 데이터 대입
                    item.username = itemDict["username"] as? String
                    item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                    item.itemname = itemDict["itemname"] as? String
                    item.price = ((itemDict["price"] as! NSNumber).intValue)
                    item.description = itemDict["description"] as? String
                    item.imgurl = itemDict["imgurl"] as? String
                    item.updatedate = itemDict["updatedate"] as? String
                    //배열에 추가
                    self.itemList.append(item)
                    
                    //데이터를 삽입할 SQL 생성
                    let sql = "insert into item(itemid, username, itemname, price, description, imgurl, updatedate) values(:itemid, :username, :itemname, :price, :description, :imgurl, :updatedate)"
                    
                    //파라미터 생성
                    var paramDict = [String:Any]()
                    paramDict["username"] = item.username!
                    paramDict["itemid"] = item.itemid!
                    paramDict["itemname"] = item.itemname!
                    paramDict["price"] = item.price!
                    paramDict["description"] = item.description!
                    paramDict["imgurl"] = item.imgurl!
                    paramDict["updatedate"] = item.updatedate!
                    
                    //sql 실행
                    itemDB.executeUpdate(sql, withParameterDictionary: paramDict)
                }//반복문 종료
            }
            //데이터 가져와서 파싱하는 문장 종료
            self.tableView.reloadData()
            itemDB.close()
        }
        //다운로드 종료
    }
    
    //로컬 데이터 출력
    func localData() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("item.sqlite").path
        //저장해놓은 데이터베이스 파일의 내용 읽기
        let itemDB = FMDatabase(path: dbPath)
        itemDB.open()
        
        do {
            let sql = "select * from item order by itemid asc"
            
            //sql 실행
            let rs = try itemDB.executeQuery(sql, values: nil)
            
            //결과를 순회
            while  rs.next() {
                var item = Item()
                item.username = rs.string(forColumn: "username")
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
        } catch let error as NSError {
            NSLog("데이터 베이스 읽기 실패: \(error.localizedDescription)")
        }
        //데이터베이스 닫기
        itemDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navbarSetting(title: "FoodBook")
        dataSetting()
    }
}

extension ItemListViewController: UITableViewDelegate, UITableViewDataSource {
    
    //행의 개수를 설정하는 메소드
    //section이 섹션(그룹) 번호
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
        cell.lblDate.text = item.updatedate
        cell.lblTitle.text = item.itemname
        cell.lblText.text = item.description
        cell.lblPrice.text = "가격: \(item.price ?? 0)"
        
        //메인 스레드에서 작업(일반 스레드는 UI갱신을 못함)
        DispatchQueue.main.async(execute: {
            //이미지 다운로드 받을 URL을 생성
            let url : URL! = URL(string: "http://192.168.0.4/img/\(item.imgurl!)")
            //Nuke의 옵션 설정
            let options = ImageLoadingOptions(placeholder: UIImage(named: "gray"), transition: .fadeIn(duration:0.4))
            //Nuke 라이브러리로 이미지 출력
            Nuke.loadImage(with: url, options: options, into: cell.imgViewlist)
        })
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = itemList[indexPath.row]
        
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListInputViewController") as! ItemListInputViewController
        navi.itemId = item.itemid!
        navi.itemName = item.itemname!
//        navi.listImg = photoImgList
        navi.itemPrice = "\(item.price!)"
        navi.itemDescription = item.description!
        navi.mode = "수정"
        self.navigationController?.pushViewController(navi, animated: true)
    }
}


