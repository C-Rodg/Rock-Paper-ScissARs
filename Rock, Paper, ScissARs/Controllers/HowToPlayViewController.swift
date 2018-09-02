//
//  HowToPlayViewController.swift
//  Rock, Paper, ScissARs
//
//  Created by C-Rodg on 9/1/18.
//  Copyright © 2018 Curtis Rodgers. All rights reserved.
//

import UIKit

class HowToPlayViewController: UIViewController {
    
    let instructionItems: [InstructionItem] = [
        InstructionItem(image: #imageLiteral(resourceName: "rock"), title: "Rock", description: "Beats scissors. Loses to paper."),
        InstructionItem(image: #imageLiteral(resourceName: "paper"), title: "Paper", description: "Beats rock. Loses to scissors."),
        InstructionItem(image: #imageLiteral(resourceName: "scissor"), title: "Scissors", description: "Beats paper. Loses to rock.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Exit How to play
    @IBAction func exitButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HowToPlayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "instructionCell", for: indexPath) as? InstructionCell else {
            return UITableViewCell()
        }
        cell.icon.image = instructionItems[indexPath.row].image
        cell.title.text = instructionItems[indexPath.row].title
        cell.instructions.text = instructionItems[indexPath.row].description
        
        return cell
    }
}

struct InstructionItem {
    let image: UIImage
    let title: String
    let description: String
}
