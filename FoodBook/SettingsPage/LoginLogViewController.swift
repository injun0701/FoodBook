//
//  LoginLogViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/21.
//

import UIKit

class LoginLogViewController: UIViewController {

    @IBOutlet var lblLoginLogCount: UILabel!
    @IBOutlet var tableView: UITableView!
    
    //현재 출력한 체이지 번호를 저장할 프로퍼티
    var page = 1
    //마지막 셀이 처음 보여진 것인지 여부를 설정하는 프로퍼티
    var flag = false
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //테이블 뷰에 출력할 데이터 배열
    var tableList: [LoginLog] = []
    
    //검색 결과 개수
    var listCountAll = 0
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
        //네비 세팅
        navbarSetting(title: "로그인 로그")
        networkCheck { [self] in
            //로그인 로그 게시물 데이터 세팅
            dataSetting(count: 10)
        }
    }
    
    //테이블뷰 세팅
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        
        //맨 위로 스크롤 했을때 리프레쉬 실행 객체를 테이블뷰에 추가
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
        tableView.addSubview(refreshControl)
        }
    }
    
    //데이터 세팅
    func dataSetting(count: Int) {
        LoadingHUD.show()
        //서버에서 아이템 데이터 받아오기
        req.apiUserLoginLog(page: 1) { [self] count, list in
            print(list)
            
            tableList = [] //초기화
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let list = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var loginLog = LoginLog()
                    //json 파싱해서 객체에 데이터 대입
                    loginLog.userid = list["userid"] as? String
                    loginLog.loginlogdate = list["loginlogdate"] as? String
                    //배열에 추가
                    tableList.append(loginLog)
                    tableList.sort(by: {$0.userid! > $1.userid!}) //순서 정렬
                }//반복문 종료
                
                listCountAll = count
                lblLoginLogCount.text = "\(count)"
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
        networkCheck { [self] in
            //로그인 로그 게시물 데이터 세팅
            dataSetting(count: 15)
        }
    }
    
}

//MARK: 테이블뷰
extension LoginLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.subtitle, reuseIdentifier:"cell")
        
        let list = tableList[indexPath.row]
        
        cell.textLabel?.text = list.userid
        cell.textLabel?.textColor = UIColor.lightGray
        
        cell.detailTextLabel?.text = list.loginlogdate
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
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
                    loginLogScrollItemAdd(page: page, tableList: self.tableList) { tableList in
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


