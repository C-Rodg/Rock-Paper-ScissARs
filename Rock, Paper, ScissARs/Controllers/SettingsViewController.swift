//
//  SettingsViewController.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 7/31/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    // Shared Game Instance
    let currentGame: Game = Game.shared
    
    // UI Fields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bestOfSegment: UISegmentedControl!
    @IBOutlet weak var labelStatsRock: UILabel!
    @IBOutlet weak var labelStatsScissors: UILabel!
    @IBOutlet weak var labelStatsPaper: UILabel!
    @IBOutlet weak var labelStatsLosses: UILabel!
    @IBOutlet weak var labelStatsWins: UILabel!
    @IBOutlet weak var cameraStatusViewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates
        self.usernameTextField.delegate = self

        // Load initial settings
        loadInitialSettings()
        
        // Display Camera Alert box if denied
        // Show alert if camera isn't setup
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
            cameraStatusViewContainer.isHidden = false
        }
    }
    
    // LIFECYCLE EVENT - View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check for updated stats
        updateStatistics()
    }
    
    // Load initial settings and stats
    func loadInitialSettings() {
        // Username
        usernameTextField.text = currentGame.username
        
        // Best of games
        switch currentGame.bestOf {
        case 1:
            bestOfSegment.selectedSegmentIndex = 0
        case 3:
            bestOfSegment.selectedSegmentIndex = 1
        case 5:
            bestOfSegment.selectedSegmentIndex = 2
        case 7:
            bestOfSegment.selectedSegmentIndex = 3
        default:
            bestOfSegment.selectedSegmentIndex = 1
        }
    }
    
    // Update statistics
    func updateStatistics() {
        let totalHands = currentGame.chooseRock + currentGame.choosePaper + currentGame.chooseScissors
        if totalHands > 0 {
            let rockPercent = Double(currentGame.chooseRock) / Double(totalHands) * 100
            let paperPercent = Double(currentGame.choosePaper) / Double(totalHands) * 100
            let scissorsPercent = Double(currentGame.chooseScissors) / Double(totalHands) * 100
            labelStatsRock.text = String(format: "%.2f%%", rockPercent)
            labelStatsPaper.text = String(format: "%.2f%%", paperPercent)
            labelStatsScissors.text = String(format: "%.2f%%", scissorsPercent)
        } else {
            labelStatsRock.text = "0%"
            labelStatsPaper.text = "0%"
            labelStatsScissors.text = "0%"
        }
        if currentGame.statsWins == 1 {
            labelStatsWins.text = "\(currentGame.statsWins) win"
        } else {
            labelStatsWins.text = "\(currentGame.statsWins) wins"
        }
        if currentGame.statsLosses == 1 {
            labelStatsLosses.text = "\(currentGame.statsLosses) loss"
        } else {
            labelStatsLosses.text = "\(currentGame.statsLosses) losses"
        }
    }
    
    // Done editing username field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let text = textField.text {
            currentGame.setUsername(to: text)
        }
        return false
    }
    
    
    // Change best of games
    @IBAction func onBestOfGamesChange(_ sender: Any) {
        let idx = bestOfSegment.selectedSegmentIndex
        var bestOfGames = 3
        if idx == 0 {
            bestOfGames = 1
        } else if idx == 1 {
            bestOfGames = 3
        } else if idx == 2 {
            bestOfGames = 5
        } else if idx == 3 {
            bestOfGames = 7
        }
        currentGame.setBestOf(to: bestOfGames)
    }
}
