//
//  ItemListTableViewCell.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {
    @IBOutlet var myImgView: UIImageView!
    @IBOutlet var mylbl: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var imgViewlist: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblText: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var btnLike: UIButton!
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
