//
//  DisabledBtn.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/18.
//

import UIKit

class DisabledBtn: UIButton {

    // 버튼 상태 종류
    enum btnState {
        case On
        case Off
    }

    // 기본 값 = off 상태
    var isOn: btnState = .Off {
        didSet {
            setting()
        }
    }

    // 1. 스토리보드로 버튼 구현시
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 기본 셋팅
        setting()
    }
    
    // 2. 코드로 버튼을 구현시
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 기본 셋팅
        setting()
    }

    func setting() {
        // on 컬러 (기본색)

        switch isOn {
        case .On:
//            self.setTitleColor(onTintColor, for: .normal)
            self.backgroundColor = UIColor().mainColor
            self.isUserInteractionEnabled = true
        case .Off:
//            self.setTitleColor(offTintColor, for: .normal)
            self.backgroundColor = UIColor.lightGray
            self.isUserInteractionEnabled = false
        }
    }
}
