//
//  ResultsTile.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 8/19/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

class ResultsTile: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup custom styling
        handleDefaultStyling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup custom styling
        handleDefaultStyling()
    }
    
    // Setup styling on button
    func handleDefaultStyling() {
        self.backgroundColor = UIColor(red: 6/255, green: 16/255, blue: 19/255, alpha: 1.0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
    }
}
