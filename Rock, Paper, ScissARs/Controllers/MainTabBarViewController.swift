//
//  MainTabBarViewController.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 7/31/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

// Provides custom animation to the Tab Bar Controller
class MainTabBarViewController: UITabBarController {
    
    var barImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove to border
        removeTopBorder()
	
        // Determine tab bar properties and generate image based off current size
        let itemCount:CGFloat = CGFloat(tabBar.items?.count ?? 0)
        let itemSize:CGSize = CGSize(width: (tabBar.frame.width / itemCount) - 20, height: tabBar.frame.height)
        let barImage:UIImage = createBarImage(size: itemSize)
        barImageView = UIImageView(image: barImage)
        barImageView?.center.x = tabBar.frame.width / 2 / 2
        
        // Add bar to view if exists
        if let completeBarView = barImageView {
            tabBar.addSubview(completeBarView)
        }
    }

    // Create the slider at the bottom of the tab controller
    func createBarImage(size: CGSize) -> UIImage {
        let barHeight: CGFloat = 5
        let barColor: UIColor = UIColor.white
        let bar = CGRect(x: 0, y: size.height - barHeight, width: size.width, height: barHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        barColor.setFill()
        UIRectFill(bar)
        guard let barContextImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        UIGraphicsEndImageContext()
        return barContextImage
    }
    
    // Override constructor
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            let current = -(tabBar.items?.index(of: item)?.distance(to: 0))! + 1
            if current == 1 {
                self?.barImageView?.center.x = (tabBar.frame.width / 2 / 2)
            } else if current == 2 {
                self?.barImageView?.center.x = (tabBar.frame.width / 2 / 2) + (tabBar.frame.width / 2)
            } else {
                self?.barImageView?.center.x = tabBar.frame.width - (tabBar.frame.width / 2 / 2)
            }
        }
    }
    
    // Remove top border
    func removeTopBorder() {
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.clipsToBounds = true
    }
}
