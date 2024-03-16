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
    @IBOutlet weak var titleLabel: UILabel!
    
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
        
//        self.dailyProgressBar.setProgress(0.6, animated: true)
        
    }
    
    func setProgressRing() {
        
//        // Setting progress
        progressRing.setProgress(0.4, animated: true)
//        progressRing.ringWidth = 15
        progressRing.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        progressRing.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
//        progressBar.setProgress(0.6, animated: true)
    }
    
    func setDailyProgressBar() {
        dailyProgressBar.setProgress(0.6, animated: true)
        dailyProgressBar.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        dailyProgressBar.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
    }
    
    @IBAction func dailyBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    
    @IBAction func previousBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    
}
