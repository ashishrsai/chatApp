//
//  prototypeTableViewCell.swift
//  chatApp
//
//  Created by Ashutosh Kumar sai on 18/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class prototypeTableViewCell: UITableViewCell {

    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var messageTextCell: UILabel!
    @IBOutlet weak var userDataCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        layoutIfNeeded()
        selectionStyle = UITableViewCellSelectionStyle.none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
