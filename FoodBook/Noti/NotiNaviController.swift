//
//  NotiNaviController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/22.
//

import UIKit
import SideMenu

class NotiNaviController: SideMenuNaviController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //나타날때 스타일
        self.presentationStyle = .menuSlideIn
        //가로 사이즈
        self.menuWidth = self.view.frame.width * 1.0
        //보여지는 속도
        self.presentDuration = 0.6
        //사라지는 속도
        self.dismissDuration = 0.6
        //스와이트로 닫기 - true : 가능, false : 불가능
        self.enableSwipeToDismissGesture = false
        //배경 탭해서 닫기 - true : 가능, false : 불가능
        self.enableTapToDismissGesture = true
    }
    
}
