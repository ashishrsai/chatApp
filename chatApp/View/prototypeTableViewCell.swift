//
//  prototypeTableViewCell.swift
//  chatApp
//  Class used for the designing of a cell in table view
//  Created by Ashutosh Kumar sai on 18/02/18.
//  Copyright © 2018 Ashish Kumar sai. All rights reserved.
//

import UIKit

class prototypeTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTextCell: UILabel!
    @IBOutlet weak var userDataCell: UILabel!
    
    
    
    //We use this method to define the design of a unit cell in table view
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
