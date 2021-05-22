//
//  SideMenuNaviController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/22.
//

import UIKit
import SideMenu

class SideMenuNaviController: SideMenuNavigationController {
    
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
    }
   
    
}
