//
//  BorderedButton.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 8/5/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

@IBDesignable class BorderedButton: UIButton {

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
    
    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var hasShadow: Bool = false {
        didSet {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 1.0, height: 4.0)
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.3
        }
    }

    override var isHighlighted: Bool {
        didSet {
            guard let current = borderColor else {
                return
            }
            
            let fadedColor = current.withAlphaComponent(0.2).cgColor
            
            if isHighlighted {
                layer.borderColor = fadedColor
            } else {
                self.layer.borderColor = current.cgColor
                let buttonAnimation = CABasicAnimation(keyPath: "borderColor")
                buttonAnimation.fromValue = fadedColor
                buttonAnimation.toValue = current.cgColor
                buttonAnimation.duration = 0.3
                self.layer.add(buttonAnimation, forKey: "")
            }
        }
    }
}
