//
//  DeclarationListViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/26.
//

import UIKit

class DeclarationListViewController: UIViewController {
    
    @IBOutlet var lblCount: UILabel!
    @IBOutlet var tableView: UITableView!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //테이블 뷰에 출력할 데이터 배열
    var tableList: [Declaration] = []
    
    //검색 결과 개수
    var listCountAll = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
        //네비 세팅
        navbarSetting(title: "신고내용")
        networkCheck { [self] in
            //로그인 로그 게시물 데이터 세팅
            dataSetting()
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
    func dataSetting() {
        LoadingHUD.show()
        //서버에서 아이템 데이터 받아오기
        req.apiDeclarationGetAll() { [self] count, list in
            print(list)
            
            tableList = [] //초기화
            
            //페이지에서 가져온 데이터
            if list.count != 0 {
                //배열의 데이터 순회
                for index in 0...(list.count - 1) {
                        //배열에서 하나씩 가져오기
                    let list = list[index] as! [String: Any] //NSDictionary
                    //하나의 DTO 객체를 생성
                    var declaration = Declaration()
                    //json 파싱해서 객체에 데이터 대입
                    declaration.itemid = list["itemid"] as? Int
                    declaration.commentid = list["commentid"] as? Int
                    declaration.declaration = list["declaration"] as? String
                    //배열에 추가
                    tableList.append(declaration)
                }//반복문 종료
            }
            listCountAll = count
            lblCount.text = "\(count)"
            tableView.reloadData()
            //refreshControl 제거
            refreshControl.endRefreshing()
            LoadingHUD.hide()
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "데이터 오류", message: "데이터를 불러올 수 없습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
        LoadingHUD.hide()
    }
    
    
    //refreshControl 객체 생성
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DeclarationListViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        return refreshControl
    }()
    
    //맨 위로 스크롤 시 refesh 기능
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        networkCheck { [self] in
            //데이터 세팅
            dataSetting()
        }
    }
}

//MARK: 테이블뷰
extension DeclarationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.subtitle, reuseIdentifier:"cell")
        
        let list = tableList[indexPath.row]
        
        var text = ""
        if list.commentid == nil {
            text = "itemid:\(list.itemid!)"
        } else {
            text = "itemid:\(list.itemid!), commentid:\(list.commentid!)"
        }
        cell.textLabel?.text = text
        cell.textLabel?.textColor = UIColor.lightGray
        
        cell.detailTextLabel?.text = list.declaration
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = tableList[indexPath.row]
        showAlertBtn3(title: "신고 내용", message: list.declaration!, btn1Title: "해당 콘텐츠 삭제", btn2Title: "해당 콘텐츠 보기", btn3Title: "취소") {
            self.networkCheck {
                var commentid = ""
                if list.commentid == nil {
                    commentid = ""
                } else {
                    commentid = "\(list.commentid!)"
                }
                
                self.req.apiDeclarationDelete(itemid: list.itemid!, commentid: commentid) {
                    self.showAlertBtn1(title: "신고", message: "해당 콘텐츠가 삭제되었습니다.", btnTitle: "확인") {
                        self.dataSetting()
                    }
                } fail: {
                    self.showAlertBtn1(title: "신고", message: "해당 콘텐츠 삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
                }
            }
        } btn2Action: {
            
            let sb = UIStoryboard(name: "Comment", bundle: nil)
            let navi = sb.instantiateViewController(withIdentifier: "CommentListViewController") as! CommentListViewController
            
            //네트워크 사용 여부 확인
            self.networkCheck() { [self] in
                LoadingHUD.show()
                req.apiItemGetDetail(itemid: "\(list.itemid!)") { list in
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
        } btn3Action:{}
    }
    
}



struct Declaration {
    var itemid : Int?
    var commentid : Int?
    var declaration : String?
}
