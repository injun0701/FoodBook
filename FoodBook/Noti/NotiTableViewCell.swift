//
//  NotiTableViewCell.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/22.
//

import UIKit

class NotiTableViewCell: UITableViewCell {

    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblResult: UILabel!
    @IBOutlet var lblPostDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
