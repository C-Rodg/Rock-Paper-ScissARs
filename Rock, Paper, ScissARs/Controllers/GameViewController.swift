//
//  ViewController.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 7/31/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // Navigate to play computer mode
    @IBAction func navigateToPlayComputer(_ sender: UIButton) {
        self.performSegue(withIdentifier: "navigateToPlayComputer", sender: nil)
    }
    
    // Navigate to play other device mode
    @IBAction func navigateToPlayOtherDevice(_ sender: UIButton) {
        self.performSegue(withIdentifier: "navigateToPlayOnline", sender: nil)
    }
    
    // Navigate to how to play screen
    @IBAction func navigateToHowToPlay(_ sender: Any) {
        self.performSegue(withIdentifier: "navigateToHowToPlay", sender: nil)
    }
}

