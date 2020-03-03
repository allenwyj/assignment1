//
//  SightListViewCell.swift
//  assignment1
//
//  Created by Yujie Wu on 5/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class SightListViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
