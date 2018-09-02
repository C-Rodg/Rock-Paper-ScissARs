//
//  StatusTitleLabel.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 8/12/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

class StatusTitleLabel: UILabel {

    @IBInspectable var cornerRadius: CGFloat = 35 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            if let border = borderColor {
                self.layer.borderColor = border.cgColor
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

}
