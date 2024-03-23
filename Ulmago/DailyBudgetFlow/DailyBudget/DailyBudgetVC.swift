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
    
    
    var budgetList: [Budget] = []
    
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
    
    @IBOutlet weak var dailySpendLabel: UILabel!
    
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
        self.dailyBudgetTableView.delegate = self
        
        
        self.updateDailySpend()
        
    }
    
    // 오늘 소비한 금액 업데이트
    func updateDailySpend() {
        let sum = self.budgetList
            .compactMap { $0.price }
            .reduce(0, +)
        
        print("Sum of budgetList's prices is : ", sum)
        self.dailySpend = sum
        self.dailySpendLabel.text = "\(dailySpend)원"
    }
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        let alertController = UIAlertController(title: "추가하시겠습니까?", message: "무엇에 얼마를 썼나요?", preferredStyle: .alert)
        
        
        // add textfield at index 0
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "내역"
            
        })
        
        // add textfield at index 1
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "금액"
            textField.keyboardType = .numberPad
            textField.delegate = self
        })
        
        // Alert action confirm
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
            guard let newTitle = alertController.textFields?[0].text,
                  let newPrice = alertController.textFields?[1].text else { return }
            
            
            print("내역: \(newTitle)")
            print("금액: \(newPrice)")
            
            DispatchQueue.main.async {
                self.budgetList.insert(Budget(title: newTitle, price: Int(newPrice)), at: self.budgetList.count)
                print(#fileID, #function, #line, "- budgetList: \(self.budgetList)")
                self.updateDailySpend()
                self.dailyBudgetTableView.reloadData()
            }
        })
        alertController.addAction(confirmAction)
        
        // Alert action cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("취소")
        })
        alertController.addAction(cancelAction)
        
        // Present alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        // 1. tableView에 아무 내역도 없으면 경고 얼럿 띄우기
        if self.budgetList.isEmpty {
            // 경고 얼럿 화면 띄우기
            let alert = UIAlertController(title: "내역 입력 없이 돌아가시겠습니까?", message: "오늘의 소비를 입력하지 않았습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "입력하기", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                print("돌아가서 입력하기")
            })
            alert.addAction(cancelAction)
            let confirmAction = UIAlertAction(title: "메인으로", style: .default, handler: { _ in
                print("메인으로 돌아가기")
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            // 2. DailyMain 화면으로 돌아가기
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

extension DailyBudgetVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.budgetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyBudgetTableViewCell") as? DailyBudgetTableViewCell else { return UITableViewCell() }
        
        let cellData = self.budgetList[indexPath.row]
        
        guard let title = cellData.title,
              let price = cellData.price else { return cell }
        
        cell.titleLabel.text = title
        cell.priceLabel.text = "\(price)원"
        
        return cell
    }
    
    
}

extension DailyBudgetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

extension DailyBudgetVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
