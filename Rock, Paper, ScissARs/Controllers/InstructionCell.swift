//
//  InstructionCell.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 9/1/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

class InstructionCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
