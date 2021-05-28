//
//  CommentTableViewCell.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/16.
//

import UIKit

class CommentListTableViewCell: UITableViewCell {

    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblComment: UILabel!
    @IBOutlet var lblPostDate: UILabel!
    @IBOutlet var btnEtc: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    var btnEtcHandler: (() -> Void)?
    var editHandler: (() -> Void)?
    
    @IBAction func btnEtcAction(_ sender: UIButton) {
        self.btnEtcHandler?()
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        self.editHandler?()
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
