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
    
    //현재 출력한 체이지 번호를 저장할 프로퍼티
    var page = 1
    //마지막 셀이 처음 보여진 것인지 여부를 설정하는 프로퍼티
    var flag = false
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    //SQLite sql 명령어 객체
    let sql = SQLiteSql()
    //SQLite 파일 urlpath
    let directoryPath = SQLiteDocumentDirectoryPath()
    //마지막 업데이트 함수 파라미터 이름
    let lastUpdatePara = LastUpdateParameterName()
    
    //테이블 뷰에 출력할 데이터 배열
    var itemList: [Item] = []
    
    //내정보 버튼
    @IBAction func btnMyInfoAction(_ sender: UIButton) {
        //앲 삭제(UserDefault는 액삭제시 자동 날라감), 회원 탈퇴, 로그아웃, 핸드폰 변경, 로그인 등등
        UserDefaults.standard.removeObject(forKey: UDkey().userid)
        UserDefaults.standard.removeObject(forKey: UDkey().username)
        UserDefaults.standard.removeObject(forKey: UDkey().userimgurl)
        NSLog("로그아웃 상태")
        rootVC()
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
        naviSetting()
    }
    
    //테이블뷰 세팅
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ItemListTableViewCell", bundle: nil), forCellReuseIdentifier: "itemListTableViewCell")
        
        //맨 위로 스크롤 했을때 리프레쉬 실행 객체를 테이블뷰에 추가
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
        tableView.addSubview(refreshControl)
        }
    }
    
    //네비게이션 세팅
    func naviSetting() {
        //네비게이션 오른쪽 버튼 - Search 뷰로 이동 버튼
        let btnSearch = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(btnSearchAction))
        navigationItem.rightBarButtonItems = [btnSearch]
    }
    
    //Search 뷰로 이동
    @objc func btnSearchAction() {
        let sb = UIStoryboard(name: "Search", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //MARK: 서버, 로컬 데이터 세팅
    func dataSetting() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        
        //데이터베이스 파일이 없으면 다운로드 받아서 저장한 후 출력
        if fileMgr.fileExists(atPath: dbPath) == false {
            //데이터베이스 파일이 존재하지 않으면
            fileExistsFalse()
        } else { //데이터베이스 파일이 존재하면
            fileExistsTrue()
        }
    }
    //데이터베이스 파일이 존재하지 않으면
    func fileExistsFalse() {
        NSLog("데이터가 없어서 다운받아 출력")
        networkCheck {
            //아이템 추가
            self.itemAdd(page: 1, count: 10) { itemList, itemCountAll in
                self.itemList = itemList
                self.tableView.reloadData()
                UserDefaults.standard.set(itemCountAll, forKey: UDkey().itemcount)
            }
            //마지막 업데이트 시간을  로컬 데이터베이스에 기록
            self.lastUpdateAddToLocal(updatePathName: self.lastUpdatePara.update, urlName: self.lastUpdatePara.lastupdate)
        }
    }
    
    func fileExistsTrue() {
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        let updatePath = docPathURL.appendingPathComponent(directoryPath.update).path
        
        networkCheckSuccessAndFaile {
            //마지막 업데이트 시간 체크해서 시간이 같으면 로컬 데이터 출력, 다르면 서버 데이터 출력
            self.checkApiLastUpdate(updatePathName: self.lastUpdatePara.update, urlName: self.lastUpdatePara.lastupdate) {
                self.itemList.removeAll() //itemList 배열 초기화
                //로컬 데이터 출력
                self.itemLocalData() { result in
                    self.itemList = result
                    self.tableView.reloadData()
                }
            } updatetimeDifferent: {
                //기존 데이터를 지우고 새로 다운로드
                try! fileMgr.removeItem(atPath: dbPath) //데이터베이스 파일 삭제
                try! fileMgr.removeItem(atPath: updatePath) //업데이트 시간 파일 삭제
                self.itemList.removeAll() //itemList 배열 초기화
                //아이템 추가
                self.itemAdd(page: 1, count: 10) { itemList, itemCountAll in
                    self.itemList = itemList
                    self.tableView.reloadData()
                    UserDefaults.standard.set(itemCountAll, forKey: UDkey().itemcount)
                }
            }
        } fail: { //네트워크가 연결이 안돼서 로컬 데이터 출력
            NSLog("네트워크가 연결이 안돼서 로컬 데이터 출력")
            self.itemList.removeAll() //itemList 배열 초기화
            //로컬 데이터 출력
            self.itemLocalData() { result in
                self.itemList = result
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        //네비게이션 세팅
        navbarSetting(title: "FoodBook")
        //데이터 세팅
        dataSetting()
    }
    
    //MARK: 아래로 스크롤 시 아이템 업로드
    func scrollItemAdd() {
        //이 메소드가 호출될때 마다 페이지 수 1씩 증가
        page = page + 1
        
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        
        //서버에서 아이템 데이터 받아오기
        req.apiItemGet(page: page, count: 10, searchKeyWord: nil) { count, list in
            print(list)
            
            //데이터베이스 파일 생성
            let itemDB = FMDatabase(path: dbPath)
            //데이터베이스 열기
            itemDB.open()
            
            //전체 데이터의 개수
            UserDefaults.standard.set(count, forKey: UDkey().itemcount)
            
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
                    paramDict["commentcount"] = item.commentcount!
                    paramDict["likecount"] = item.likecount!
                    paramDict["useritemlike"] = item.useritemlike!
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
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }

    //refreshControl 객체 생성
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ItemListViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        return refreshControl
    }()
    
    //맨 위로 스크롤 시 refesh 기능
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //데이터 세팅
        dataSetting()
        //refreshControl 제거
        refreshControl.endRefreshing()
        //테이블뷰 리로드
        self.tableView.reloadData()
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
        
        let itemDate = cutString(str: item.updatedate!, endIndex: 10, fromTheFront: true)
        cell.lblDate.text = itemDate
        cell.lblTitle.text = item.itemname
        cell.lblText.text = item.description
        cell.lblPrice.text = "\(item.price ?? 0)원"
        cell.lblLike.text = "댓글: \(item.commentcount ?? 0), 좋아요: \(item.likecount ?? 0)"
        
        //아이템 이미지 출력
        req.getImg(imgurlName: item.imgurl!, defaultImgurlName: "gray", toImg: cell.imgViewlist)
        
        if item.useritemlike == 1 { //좋아요한 상태
            cell.btnLike.setImage(UIImage(named: "like_fill"), for: .normal)
            //btnLikeTapHandler 작성
            cell.btnLikeTapHandler = { [self] in
                //네트워크 사용 여부 확인
                networkCheck() {
                    itemLikeDelete(itemid: "\(item.itemid!)")
                }
            }
        } else { //좋아요 안한 상태
            cell.btnLike.setImage(UIImage(named: "like"), for: .normal)
            //btnLikeTapHandler 작성
            cell.btnLikeTapHandler = { [self] in
                //네트워크 사용 여부 확인
                networkCheck() {
                    itemLikeInsert(itemid: "\(item.itemid!)")
                }
            }
        }
        
        //유저이미지 라운드 처리
        DispatchQueue.main.async {
            cell.myImgView.layer.cornerRadius = cell.myImgView.frame.height/2
            cell.myImgView.clipsToBounds = true
        }
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    //좋아요 삭제 메소드
    func itemLikeDelete(itemid: String) {
        req.apiItemLikeDelete(itemid: itemid) {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 삭제가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.itemLike()
            }
        } fail: {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //좋아요 업로드 메소드
    func itemLikeInsert(itemid: String) {
        req.apiItemLikeInsert(itemid: itemid) {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.itemLike()
            }
        } fail: {
            self.showAlertBtn1(title: "업로드 알림", message: "좋아요 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //좋아요 메소드
    func itemLike() {
        let itemListCount = itemList.count
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
        self.itemList.removeAll() //itemList 배열 초기화
        //아이템 추가
        self.itemAdd(page: 1, count: itemListCount) { itemList, itemCountAll in
            self.itemList = itemList
            UserDefaults.standard.set(itemCountAll, forKey: UDkey().itemcount)
            
            self.tableView.reloadData()
        }
        //마지막 업데이트 시간을 기록
        lastUpdateAddToLocal(updatePathName: lastUpdatePara.update, urlName: lastUpdatePara.lastupdate)
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
        let itemDate = cutString(str: item.updatedate!, endIndex: 10, fromTheFront: true)
        navi.itemDate = "\(itemDate)"
        navi.itemLikeCount = "\(item.likecount!)"
        navi.userImgUrl = item.userimgurl!
        navi.userImg = currentCell.myImgView.image!
        navi.userName = item.username!
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    //테이블 뷰에서 스트롤을 하면 호출되는 메소드 (셀이 보여질때 호출되는 메소드)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //처음 마지막 셀이 출력되면
        if flag == false && indexPath.row == self.itemList.count - 1 {
            flag = true
        } else if flag == true && indexPath.row == self.itemList.count - 1 {
            let itemCountAll = UserDefaults.standard.value(forKey: UDkey().itemcount) as? Int ?? 0
            print("\(itemCountAll), \(itemList.count)")
            //api db의 전체 데이터 갯수가 리스트 배열의 개수보다 크면 실행
            if itemCountAll > self.itemList.count {
                //네트워크 사용 여부 확인
                networkCheck() { [self] in
                    scrollItemAdd()
                    flag = false
                }
            }
        }
    }
}


