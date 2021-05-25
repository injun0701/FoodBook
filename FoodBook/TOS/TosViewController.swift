//
//  TosViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/25.
//

import UIKit

class TosViewController: UIViewController {

    @IBAction func btnTosAction(_ sender: UIButton) {
        rootVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "약관동의"
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    

}
