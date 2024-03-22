//
//  DailyBudgetVC.swift
//  Ulmago
//
//  Created by dhui on 3/17/24.
//

import Foundation
import UIKit

class DailyBudgetVC: UIViewController {
    
    @IBOutlet weak var dailyExpenseLabel: UILabel!
    
    var wholeCost: String = "" {
        didSet {
            print(#fileID, #function, #line, "- ")
        }
    }
    
    @IBOutlet weak var todaysExpenseLabel: UILabel!
    
    @IBOutlet weak var dailyBudgetTableView: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    init?(coder: NSCoder, wholeCost: String) {
        self.wholeCost = wholeCost
        super.init(coder: coder)
        print(#fileID, #function, #line, "- wholeCost from DailyMainVC: \(wholeCost) ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.dailyExpenseLabel.text = "목표가 얼마고? : " + self.wholeCost
        
    }
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    
}
