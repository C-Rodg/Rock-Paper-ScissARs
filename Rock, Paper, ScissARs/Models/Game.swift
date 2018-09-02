//
//  Game.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 8/19/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

// Game Singleton
class Game {
    static let shared: Game = Game()
    
    let defaults = UserDefaults.standard
    
    // Settings
    var username: String = ""
    var bestOf: Int = 3
    
    // Stats
    var chooseRock: Int = 0
    var choosePaper: Int = 0
    var chooseScissors: Int = 0
    var statsWins: Int = 0
    var statsLosses: Int = 0
    
    // Current Scores
    var myScore: Int = 0
    var otherPlayerScore: Int = 0
    
    
    private init() {
        applySavedSettings()
    }
    
    // Load saved settings & scores
    func applySavedSettings() {
        
        if let user = defaults.string(forKey: "username") {
            self.username = user
        }
        let bestGames = defaults.integer(forKey: "bestOf")
        if bestGames == 1 || bestGames == 3 || bestGames == 5 || bestGames == 7 {
            self.bestOf = bestGames
        }
        
        self.chooseRock = defaults.integer(forKey: "chooseRock")
        self.choosePaper = defaults.integer(forKey: "choosePaper")
        self.chooseScissors = defaults.integer(forKey: "chooseScissors")
        self.statsWins = defaults.integer(forKey: "statsWins")
        self.statsLosses = defaults.integer(forKey: "statsLosses")
    }
    
    // Stats - update formation played score
    func statsRecordFormation(with formation: String) {
        if formation == "rock" {
            self.chooseRock += 1
            defaults.set(self.chooseRock, forKey: "chooseRock")
        } else if formation == "scissors" {
            self.chooseScissors += 1
            defaults.set(self.chooseScissors, forKey: "chooseScissors")
        } else if formation == "paper" {
            self.choosePaper += 1
            defaults.set(self.choosePaper, forKey: "choosePaper")
        }
    }
    

    
    // Stats - set win
    func statsSetWin() {
        self.statsWins += 1
        defaults.set(self.statsWins, forKey: "statsWins")
    }
    
    // Stats - set loss
    func statsSetLoss() {
        self.statsLosses += 1
        defaults.set(self.statsLosses, forKey: "statsLosses")
    }
    
    // Save new best of games
    func setBestOf(to: Int) {
        self.bestOf = to
        defaults.set(to, forKey: "bestOf")
    }
    
    // Save new username
    func setUsername(to: String) {
        self.username = to
        defaults.set(to, forKey: "username")
    }
    
    // Determine if there is a winner for a given score
    func isTotalWinner(withScore score: Int) -> Bool {
        let scoreNeeded: Int = Int(round((Double(self.bestOf) / 2)))
        if scoreNeeded <= score {
            return true
        }
        return false
    }
    
    // Reset the current game
    func resetGame() {
        self.myScore = 0
        self.otherPlayerScore = 0
    }
    
    // Get computer hand formation
    func getComputerHandFormation() -> String {
        let randomNumber = arc4random_uniform(3)
        if randomNumber == 0 {
            return "paper"
        } else if randomNumber == 1 {
            return "rock"
        } else {
            return "scissors"
        }
    }
    
    // Determine winner between two strings
    func getResultsBetween(myPlay: String, player2: String) -> String {
        if myPlay == player2 {
            return "TIE"
        }
        
        if myPlay == "rock" {
            if player2 == "scissors" {
                return "WIN"
            } else {
                return "LOSS"
            }
        } else if myPlay == "scissors" {
            if player2 == "paper" {
                return "WIN"
            } else {
                return "LOSS"
            }
        } else if myPlay == "paper" {
            if player2 == "rock" {
                return "WIN"
            } else {
                return "LOSS"
            }
        }
        return ""
    }
    
    
}
