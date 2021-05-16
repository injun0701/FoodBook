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
    @IBOutlet var btnEdit: UIButton!
    
    var editHandler: (() -> Void)?
    
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
