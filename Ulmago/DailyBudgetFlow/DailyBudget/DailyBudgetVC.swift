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
    
    var dummies = [0, 1, 2, 3, 4, 5, 6]
    
    // 목표
    var goalText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- goalText: \(goalText)")
        }
    }
    // 총 비용
    var wholeCostText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- wholeCostText: \(wholeCostText)")
        }
    }
    // 소비 한도
    var dailyExpenseText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- dailyExpenseText: \(dailyExpenseText)")
        }
    }
    // 오늘 쓴 돈
    var dailySpend: Int = 0 {
        didSet {
            print(#fileID, #function, #line, "- dailySpend: \(dailySpend)")
        }
    }
    
    @IBOutlet weak var todaysExpenseLabel: UILabel!
    
    @IBOutlet weak var dailyBudgetTableView: UITableView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    init?(coder: NSCoder, wholeCost: String, dailyExpense: String) {
        self.wholeCostText = wholeCost
        self.dailyExpenseText = dailyExpense
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
        
        var dailyExpense: Int = Int(self.dailyExpenseText) ?? 0
        
        self.dailyExpenseLabel.text = "목표가 얼마고? : " + self.wholeCostText
        self.todaysExpenseLabel.text = "오늘의 소비 한도 : \(dailyExpense - dailySpend)원"
        
        let cellNib = UINib(nibName: "DailyBudgetTableViewCell", bundle: .main)
        
        self.dailyBudgetTableView.register(cellNib, forCellReuseIdentifier: "DailyBudgetTableViewCell")
        self.dailyBudgetTableView.dataSource = self
        
    }
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        let alert = UIAlertController(title: "추가하시겠습니까?", message: "무엇에 얼마를 썼나요?", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "추가혀", style: .default, handler: { action in
            guard let textField =  alert.textFields?.first else {
                return
            }
            print(#fileID, #function, #line, "- textfield: \(textField.text)")
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    
}

extension DailyBudgetVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyBudgetTableViewCell") as? DailyBudgetTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    
}
