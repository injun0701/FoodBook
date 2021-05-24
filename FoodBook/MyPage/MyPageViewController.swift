//
//  MyPageViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/19.
//

import UIKit

class MyPageViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblUserId: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblMyItemCount: UILabel!
    @IBOutlet var tableView: UITableView!
    
    //현재 출력한 체이지 번호를 저장할 프로퍼티
    var page = 1
    //마지막 셀이 처음 보여진 것인지 여부를 설정하는 프로퍼티
    var flag = false
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //테이블 뷰에 출력할 데이터 배열
    var itemList: [Item] = []

    //검색 결과 개수
    var searchItemCountAll = 0
    
    //정보 수정으로 이동
    @IBAction func btnToMyPageEditAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "MyPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "MyPageEditViewController") as! MyPageEditViewController
        navi.userImg = imgView.image!
        navi.userId = lblUserId.text!
        navi.userName = lblUserName.text!
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //좋아요 누른 게시판으로 이동
    @IBAction func btnToItemLikeAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "MyPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemLikeListViewController") as! ItemLikeListViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //로그아웃 버튼
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        showAlertBtn2(title: "로그아웃 안내", message: "로그아웃 하시겠습니까?", btn1Title: "취소", btn2Title: "로그아웃") {
        } btn2Action: {
            //로그아웃
            self.logout()
        }
    }
    
    //글쓰기 버튼
    @IBAction func btnAddAction(_ sender: UIButton) {
        LoadingHUD.show()
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListPostViewController") as! ItemListPostViewController
        
        let userImgUrl = UserDefaults.standard.value(forKey: UDkey().userimgurl)
        let userName = UserDefaults.standard.value(forKey: UDkey().username)
        navi.userImgUrl = userImgUrl as! String
        navi.userName = userName as! String
        navi.mode = "저장"
        LoadingHUD.hide()
        self.navigationController?.pushViewController(navi, animated: true)
    }
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //네비 세팅
        naviSetting()
        tableViewSetting()
    }
    
    //네비게이션 세팅
    func naviSetting() {
        navbarSetting(title: "내 정보")
        //네비게이션 오른쪽 버튼 - Search 뷰로 이동 버튼
        let btnConfig: UIButton = UIButton(type: UIButton.ButtonType.custom)
        btnConfig.setImage(UIImage(named: "config"), for: [])
        btnConfig.addTarget(self, action: #selector(btnConfigAction), for: UIControl.Event.touchUpInside)
        btnConfig.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let btnConfigItem = UIBarButtonItem(customView: btnConfig)
        //네비게이션 오른쪽 버튼 - 햄버거 메뉴 생성
        let btnSideMenu: UIButton = UIButton(type: UIButton.ButtonType.custom)
        btnSideMenu.setImage(UIImage(named: "menu"), for: [])
        btnSideMenu.addTarget(self, action: #selector(btnSideMenuAction), for: UIControl.Event.touchUpInside)
        btnSideMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let btnSideMenuItem = UIBarButtonItem(customView: btnSideMenu)
        
        navigationItem.rightBarButtonItems = [btnSideMenuItem, btnConfigItem]

    }
    
    //설정 페이지로 이동
    @objc func btnConfigAction() {
        let sb = UIStoryboard(name: "SettingPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "SettingPageViewController") as! SettingPageViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //사이드 메뉴 호출
    @objc func btnSideMenuAction() {
        presentSideMenu()
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
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        //뷰 세팅
        viewSetting()
        networkCheck { [self] in
            //데이터 세팅
            dataSetting(count: 10, searchKeyWord: userName ?? "")
        }
    }
    
    //뷰 세팅
    func viewSetting() {
        let userId = UserDefaults.standard.value(forKey: UDkey().userid) as? String
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        
        lblUserId.text = userId
        lblUserName.text = userName
        //이미지 세팅
        imgSetting()
    }
    
    //이미지 세팅
    func imgSetting() {
        let userImgUrl = UserDefaults.standard.value(forKey: UDkey().userimgurl) as? String
        networkCheck() { [self] in
            //유저 이미지 출력
            req.getImg(imgurlName: userImgUrl!, defaultImgurlName: "userimg", toImg: imgView)
        }
        //유저이미지 라운드 처리
        DispatchQueue.main.async { [self] in
            imgView.layer.cornerRadius = imgView.frame.height/2
            imgView.clipsToBounds = true
        }
    }
    
    //데이터 세팅
    func dataSetting(count: Int, searchKeyWord: String) {
        LoadingHUD.show()
        //서버에서 아이템 데이터 받아오기
        req.apiItemGet(page: 1, count: count, searchKeyWord: searchKeyWord) { [self] noticheck, allcount, searchcount, list in
            print(list)
            
            itemList = [] //초기화
            
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
                
                searchItemCountAll = searchcount
                lblMyItemCount.text = "\(searchcount)"
                tableView.reloadData()
                
                //refreshControl 제거
                refreshControl.endRefreshing()
            }
            LoadingHUD.hide()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            LoadingHUD.hide()
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
        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
        networkCheck { [self] in
            //데이터 세팅
            dataSetting(count: 10, searchKeyWord: userName ?? "")
        }
    }
    
}

//MARK: 테이블뷰
extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.lblUserName.text = item.username
        
        //유저 이미지 출력
        req.getImg(imgurlName: item.userimgurl!, defaultImgurlName: "userimg", toImg: cell.imgViewUser)
        
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
                    itemLikeDelete(homePage: false, itemid: "\(item.itemid!)") {
                        let itemListCount = itemList.count
                        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
                        //데이터 세팅
                        dataSetting(count: itemListCount, searchKeyWord: userName ?? "")
                    } fail: {
                        let itemListCount = itemList.count
                        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
                        //데이터 세팅
                        dataSetting(count: itemListCount, searchKeyWord: userName ?? "")
                    }
                }
            }
        } else { //좋아요 안한 상태
            cell.btnLike.setImage(UIImage(named: "like"), for: .normal)
            //btnLikeTapHandler 작성
            cell.btnLikeTapHandler = { [self] in
                //네트워크 사용 여부 확인
                networkCheck() {
                    itemLikeInsert(homePage: false, itemid: "\(item.itemid!)", itemUserName: item.username!) {
                        let itemListCount = itemList.count
                        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
                        //데이터 세팅
                        dataSetting(count: itemListCount, searchKeyWord: userName ?? "")
                    } fail: {
                        let itemListCount = itemList.count
                        let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
                        //데이터 세팅
                        dataSetting(count: itemListCount, searchKeyWord: userName ?? "")
                    }
                }
            }
        }
        
        //유저이미지 라운드 처리
        DispatchQueue.main.async {
            cell.imgViewUser.layer.cornerRadius = cell.imgViewUser.frame.height/2
            cell.imgViewUser.clipsToBounds = true
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
        LoadingHUD.show()
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
        navi.userImg = currentCell.imgViewUser.image!
        navi.userName = item.username!
        LoadingHUD.hide()
        self.navigationController?.pushViewController(navi, animated: true)
    }
    
    //테이블 뷰에서 스트롤을 하면 호출되는 메소드 (셀이 보여질때 호출되는 메소드)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //처음 마지막 셀이 출력되면
        if flag == false && indexPath.row == self.itemList.count - 1 {
            flag = true
        } else if flag == true && indexPath.row == self.itemList.count - 1 {

            print("\(searchItemCountAll), \(itemList.count)")
            //api db의 전체 데이터 갯수가 리스트 배열의 개수보다 크면 실행
            if searchItemCountAll > self.itemList.count {
                //네트워크 사용 여부 확인
                networkCheck() { [self] in
                    LoadingHUD.show()
                    let userName = UserDefaults.standard.value(forKey: UDkey().username) as? String
                    searchScrollItemAdd(page: page, itemList: self.itemList, searchKeyWord: userName ?? "") { itemList in
                        self.itemList = itemList
                        self.tableView.reloadData()
                        LoadingHUD.hide()
                    }
                    LoadingHUD.hide()
                    page = page + 1
                    flag = false
                }
            }
        }
    }
}


