//
//  IntroCollectionViewCell.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/24.
//

import UIKit

class IntroCollectionViewCell: UICollectionViewCell {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var contentLbl: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var imgViewToLeft: UIImageView!
    @IBOutlet var imgViewToRigth: UIImageView!
    @IBOutlet var btn: UIButton!
    
    var btnTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func btn02Action(_ sender: UIButton) {
        btnTapHandler?()
    }
}
