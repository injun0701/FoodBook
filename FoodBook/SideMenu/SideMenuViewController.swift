//
//  SideMenuViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/22.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblUserId: UILabel!
    @IBOutlet var lblUserName: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    var tableList:[SideMenu] = []
    let home = "홈으로"
    let search = "검색"
    let like = "좋아요 누른 게시물"
    let config = "설정"
    
    @IBAction func btnToMyPageAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "MyPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "MyPageViewController") as! MyPageViewController
        self.navigationController?.pushViewController(navi, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        naviSetting()
        viewSetting()
        tableViewSetting()
        dataSetting()
    }
    
    //네비게이션 세팅
    func naviSetting() {
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
    
    //테이블뷰 세팅
    func tableViewSetting() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func dataSetting() {
        tableList = [
            SideMenu(title: home, imgname: "home"),
            SideMenu(title: search, imgname: "search"),
            SideMenu(title: like, imgname: "like"),
            SideMenu(title: config, imgname: "config")
       ]
    }
    
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.subtitle, reuseIdentifier:"cell")
        
        let list = tableList[indexPath.row]
        
        cell.imageView?.image = UIImage(named: list.imgname!)
        
        cell.textLabel?.text = list.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.textLabel?.textColor = UIColor.darkGray
        
        //선택했을 때 회색 배경 없음 설정
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableList[indexPath.row].title == home  {
            self.navigationController?.popToRootViewController(animated: false)
            dismiss(animated: true)
        } else if tableList[indexPath.row].title == search  {
            let sb = UIStoryboard(name: "Search", bundle: nil)
            guard let navi = sb.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
            self.navigationController?.pushViewController(navi, animated: false)
        } else if tableList[indexPath.row].title == like  {
            let sb = UIStoryboard(name: "MyPage", bundle: nil)
            guard let navi = sb.instantiateViewController(withIdentifier: "ItemLikeListViewController") as? ItemLikeListViewController else { return }
            self.navigationController?.pushViewController(navi, animated: false)
        } else if tableList[indexPath.row].title == config  {
            let sb = UIStoryboard(name: "SettingPage", bundle: nil)
            guard let navi = sb.instantiateViewController(withIdentifier: "SettingPageViewController") as? SettingPageViewController else { return }
            self.navigationController?.pushViewController(navi, animated: false)
        }
    }
}

struct SideMenu {
    let title:String?
    let imgname:String?
}
