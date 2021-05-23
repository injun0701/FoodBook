//
//  NotiViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/22.
//

import UIKit

class NotiViewController: UIViewController {

    @IBOutlet var lblNotiCount: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnNotiDelete: DisabledBtn!
    
    //현재 출력한 체이지 번호를 저장할 프로퍼티
    var page = 1
    //마지막 셀이 처음 보여진 것인지 여부를 설정하는 프로퍼티
    var flag = false
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //테이블 뷰에 출력할 데이터 배열
    var tableList: [Noti] = []
    
    //검색 결과 개수
    var listCountAll = 0
    
    //알림 비우기 버튼
    @IBAction func btnNotiDeleteAction(_ sender: UIButton) {
        //네트워크 체크
        networkCheck {
            LoadingHUD.show()
            self.req.apiUserNotiDelete {
                LoadingHUD.hide()
                self.showAlertBtn1(title: "알림", message: "알림을 모두 삭제했습니다.", btnTitle: "확인") {
                    //로그인 로그 게시물 데이터 세팅
                    self.dataSetting(count: 10)
                }
            } fail: {
                LoadingHUD.hide()
                self.showAlertBtn1(title: "알림", message: "알림 삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
            }
            LoadingHUD.hide()
        }
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
        //네비게이션 세팅
        naviSetting()
    }
    
    //테이블뷰 세팅
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "NotiTableViewCell", bundle: nil), forCellReuseIdentifier: "notiTableViewCell")
        
        //맨 위로 스크롤 했을때 리프레쉬 실행 객체를 테이블뷰에 추가
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
        tableView.addSubview(refreshControl)
        }
    }
    
    //네비게이션 세팅
    func naviSetting() {
        //네비 타이틀 세팅
        navbarSetting(title: "알림")
        //네비게이션 오른쪽 버튼 - Search 뷰로 이동 버튼
        let btnX: UIButton = UIButton(type: UIButton.ButtonType.custom)
        btnX.setImage(UIImage(named: "x"), for: [])
        btnX.addTarget(self, action: #selector(btnXAction), for: UIControl.Event.touchUpInside)
        btnX.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let btnXItem = UIBarButtonItem(customView: btnX)
        
        navigationItem.rightBarButtonItem = btnXItem

    }
    
    //닫기 버튼
    @objc func btnXAction() {
        dismiss(animated: true)
        //알림체크 삭제
        notiCheckDelete()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //로그인 로그 게시물 데이터 세팅
        dataSetting(count: 10)
        
    }
    
    //데이터 세팅
    func dataSetting(count: Int) {
        LoadingHUD.show()
        page = 1
        //서버에서 아이템 데이터 받아오기
        req.apiUserNoti(page: 1) { [self] count, list in
            print(list)
            
            tableList = [] //초기화
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let list = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var noti = Noti()
                    //json 파싱해서 객체에 데이터 대입
                    noti.username = list["username"] as? String
                    noti.userimgurl = list["userimgurl"] as? String
                    noti.commentture = list["commenttrue"] as? Bool
                    noti.itemid = "\((list["itemid"] as! NSNumber).intValue)"
                    noti.postdate = list["postdate"] as? String
                    //배열에 추가
                    tableList.append(noti)
                    tableList.sort(by: {$0.postdate! > $1.postdate!}) //순서 정렬
                }//반복문 종료
                
                listCountAll = count
                lblNotiCount.text = "\(count)"
                tableView.reloadData()
                btnNotiDelete.isOn = .On
                btnNotiDelete.backgroundColor = UIColor().color666666
                //refreshControl 제거
                refreshControl.endRefreshing()
            } else {
                listCountAll = 0
                lblNotiCount.text = "0"
                tableView.reloadData()
                btnNotiDelete.isOn = .Off
            }
            LoadingHUD.hide()
            NSLog("데이터 베이스 생성 성공")
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
        LoadingHUD.hide()
    }
    
    //알림체크 삭제
    func notiCheckDelete() {
        req.apiUserNotiCheckDelete {
            print("알림체크 삭제 성공")
            
        } fail: {
            print("알림체크 삭제 실패")
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
        //로그인 로그 게시물 데이터 세팅
        dataSetting(count: 15)
    }
    
}

//MARK: 테이블뷰
extension NotiViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //셀의 identifier로 사용할 문자열
        let cellIdentifier = "notiTableViewCell"
        //재사용 가능한 셀이 있으면 찾아오기
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotiTableViewCell else {
            return UITableViewCell()
        }
        
        let list = tableList[indexPath.row]
        
        //유저 이미지 출력
        req.getImg(imgurlName: list.userimgurl!, defaultImgurlName: "userimg", toImg: cell.imgViewUser)
        
        DispatchQueue.main.async {
            cell.imgViewUser.layer.cornerRadius = cell.imgViewUser.frame.height/2
            cell.imgViewUser.clipsToBounds = true
        }
        
        cell.lblUserName.text = list.username!
        
        if list.commentture == true {
            cell.lblResult.text = "님이 댓글을 달았습니다."
        } else if list.commentture == false {
            cell.lblResult.text = "님이 좋아요를 눌렀습니다."
        }
        
        cell.lblPostDate.text = list.postdate
        
        //'>'추가
        cell.accessoryType = .disclosureIndicator
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let list = tableList[indexPath.row]
        
        let sb = UIStoryboard(name: "Comment", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "CommentListViewController") as! CommentListViewController
        
        //네트워크 사용 여부 확인
        networkCheck() { [self] in
            LoadingHUD.show()
            req.apiItemGetDetail(itemid: list.itemid!) { list in
                //페이지에서 가져온 데이터
                if list.count != 0 {
            
                let list = list[0] as! [String: Any] //NSDictionary
    
                    //json 파싱해서 객체에 데이터 대입
                    navi.itemId = "\((list["itemid"] as! NSNumber).intValue)"
                    navi.itemImgUrl = list["imgurl"] as? String ?? ""
                    navi.itemPrice = "\((list["price"] as! NSNumber).intValue)"
                    navi.itemName = list["itemname"] as? String ?? ""
                    navi.itemDescription = list["description"] as? String ?? ""
                    let itemDate = cutString(str: list["updatedate"] as? String ?? "", endIndex: 10, fromTheFront: true)
                    navi.itemDate = itemDate
                    navi.itemLikeCount = "\((list["likecount"] as! NSNumber).intValue)"
                    navi.userImgUrl = list["userimgurl"] as? String ?? ""
                    navi.userName = list["username"] as? String ?? ""
                    
                    navi.fromNoti = true
                    LoadingHUD.hide()
                    self.navigationController?.pushViewController(navi, animated: true)
                }
            } fail: {
                LoadingHUD.hide()
                showAlertBtn1(title: "데이터 알림", message: "데이터를 가져올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
            }
            LoadingHUD.hide()
        }
    }
    
    //테이블 뷰에서 스트롤을 하면 호출되는 메소드 (셀이 보여질때 호출되는 메소드)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //처음 마지막 셀이 출력되면
        if flag == false && indexPath.row == self.tableList.count - 1 {
            flag = true
        } else if flag == true && indexPath.row == self.tableList.count - 1 {

            print("\(listCountAll), \(tableList.count)")
            //api db의 전체 데이터 갯수가 리스트 배열의 개수보다 크면 실행
            if listCountAll > self.tableList.count {
                //네트워크 사용 여부 확인
                networkCheck() { [self] in
                    LoadingHUD.show()
                    notiScrollItemAdd(page: page, tableList: self.tableList) { tableList in
                        self.tableList = tableList
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
