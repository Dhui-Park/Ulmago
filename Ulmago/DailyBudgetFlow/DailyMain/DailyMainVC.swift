//
//  DailyMainVC.swift
//  Ulmago
//
//  Created by dhui on 3/16/24.
//

import Foundation
import UIKit
import ALProgressView


class DailyMainVC: UIViewController {
    
    @IBOutlet weak var goalTextLabel: UILabel!
    @IBOutlet weak var progressTextLabel: UILabel!
    
    @IBOutlet weak var progressRing: ALProgressRing!
    @IBOutlet weak var dailyProgressBar: ALProgressBar!
    
    @IBOutlet weak var dailyBudgetSubmitBtn: UIButton!
    @IBOutlet weak var previousBudgetSubmitBtn: UIButton!
    
    var goalText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- goalText: \(goalText)")
        }
    }
    
    var wholeCostText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- wholeCostText: \(wholeCostText)")
        }
    }
    
    var dailyExpenseText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- dailyExpenseText: \(dailyExpenseText)")
        }
    }
    
    var progressPercentText: String = "40%"
    
    init?(coder: NSCoder, goalText: String, wholeCostText: String) {
        self.goalText = goalText
        self.wholeCostText = wholeCostText + "만원"
        super.init(coder: coder)
        print(#fileID, #function, #line, "- goalText from ViewController: \(goalText), wholeCostText from WholeCostSettingVC: \(wholeCostText) ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        
        let newBackButton = UIBarButtonItem(title: "다시 설정하기", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUsersCostSetting(_:)), name: .usersCostSettings, object: nil)
        
        self.setProgressRing()
        self.setDailyProgressBar()
        
        
        
        let mainString = "\(goalText)을/를 위해 우리는"
        let range = (mainString as NSString).range(of: goalText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: range)
        self.goalTextLabel.attributedText = mutableAttributedString
        
        
        let secondString = "\(progressPercentText)를 모았어요!"
        let secondRange = (secondString as NSString).range(of: progressPercentText)
        let secondMutableAttributedString = NSMutableAttributedString.init(string: secondString)
        secondMutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: secondRange)
        self.progressTextLabel.attributedText = secondMutableAttributedString
        
        self.dailyBudgetSubmitBtn.submitButtonSetting()
        self.previousBudgetSubmitBtn.submitButtonSetting()
        
        
        
    }
    
    @objc fileprivate func handleUsersCostSetting(_ sender: Notification) {
        print(#fileID, #function, #line, "⭐️ - sender: \(sender)")
        
        guard let goalText = sender.userInfo?["goalText"] as? String,
              let wholeCost = sender.userInfo?["wholeCost"] as? String,
              let dailyExpense = sender.userInfo?["dailyExpense"] as? String else { return }
        
        print(#fileID, #function, #line, "⭐️ - goalText: \(goalText), wholeCost: \(wholeCost), dailyExpense: \(dailyExpense)")
        
        self.goalText = goalText
        self.wholeCostText = "\(wholeCost)"
        self.dailyExpenseText = dailyExpense
        
    }
    
    func setProgressRing() {
        
//        // Setting progress
        progressRing.setProgress(0.4, animated: true)
        progressRing.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        progressRing.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
    }
    
    func setDailyProgressBar() {
        dailyProgressBar.setProgress(0.6, animated: true)
        dailyProgressBar.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        dailyProgressBar.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
    }
    
    @IBAction func dailyBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
       
        let storyboard = UIStoryboard(name: DailyBudgetVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: DailyBudgetVC.reuseIdentifier, creator: { coder in
            return DailyBudgetVC(coder: coder, wholeCost: self.wholeCostText)
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func previousBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        let storyboard = UIStoryboard(name: PreviousDailyBudgetVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: PreviousDailyBudgetVC.reuseIdentifier, creator: { coder in
            return PreviousDailyBudgetVC(coder: coder)
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension DailyMainVC {
    
    @objc func backAction(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "목표나 금액을 다시 설정할까요?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "다시 설정하기", style: .default) { (result : UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
