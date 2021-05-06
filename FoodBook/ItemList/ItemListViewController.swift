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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewSetting()
        dataSetting()
    }
    
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func dataSetting() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("item.sqlite").path
        //업데이트 된 시간을 저장할 텍스트 파일 경로를 생성
        let updatePath = docPathURL.appendingPathComponent("update.txt").path
        
        //데이터를 다운로드 받을 URL
        let url = "http://192.168.0.4/item/getall"
        
        //데이터베이스 파일이 없으면 다운로드 받아서 저장한 후 출력
        if fileMgr.fileExists(atPath: dbPath) == false { //데이터베이스 파일이 존재하지 않으면
            NSLog("데이터가 없어서 다운받아 출력함")
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            networkCheck {
                //데이터 다운로드 - get 방식이고 파라미터 없고 결과는 json
                let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
                request.responseJSON { response in
                    //전체 데이터를 객체로 받기
                    if let jsonObject = response.value as? [String:Any] {
                        //데이터를 저장할 테이블 생성
                        let sql = "create table if not exists item(itemid INTEGER not null primary key, itemname text, price INTEGER, description text, imgurl text, updatedate text)"
                        itemDB.executeStatements(sql)
                        
                        //전체 데이터에서 list 키의 값을 배열로 가져오기
                        let list = jsonObject["list"] as! NSArray
                        //배열의 데이터 순회
                        for index in 0...(list.count - 1) {
                            //배열에서 하나씩 가져오기
                            let itemDict = list[index] as! [String: Any] //NSDictionary
                            //하나의 DTO 객체를 생성
                            var item = Item()
                            //json 파싱해서 객체에 데이터 대입
                            item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                            item.itemname = itemDict["itemname"] as? String
                            item.price = ((itemDict["price"] as! NSNumber).intValue)
                            item.description = itemDict["description"] as? String
                            item.imgurl = itemDict["imgurl"] as? String
                            item.updatedate = itemDict["updatedate"] as? String
                            //배열에 추가
                            self.itemList.append(item)
                            
                            //데이터를 삽입할 SQL 생성
                            let sql = "insert into item(itemid, itemname, price, description, imgurl, updatedate) values(:itemid, :itemname, :price, :description, :imgurl, :updatedate)"
                            
                            //파라미터 생성
                            var paramDict = [String:Any]()
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
            }
            
        } else { //데이터베이스 파일이 존재하면
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navbarSetting(title: "FoodBook")
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
        
        cell.lblTitle.text = item.itemname
        cell.lblText.text = item.description
        cell.lblPrice.text = "\(item.price ?? 0)"
        
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
    
   
}


