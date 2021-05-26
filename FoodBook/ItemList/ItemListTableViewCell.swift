//
//  ItemListTableViewCell.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/10.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {
    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var imgViewlist: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblText: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblLike: UILabel!
    @IBOutlet var btnEtc: UIButton!
    @IBOutlet var btnLike: UIButton!
    
    var btnEtcTapHandler: (() -> Void)?
    var btnLikeTapHandler: (() -> Void)?
    
    @IBAction func btnEtcAction(_ sender: UIButton) {
        btnEtcTapHandler?()
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        btnLikeTapHandler?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
