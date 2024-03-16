//
//  DailyExpenseSettingVC.swift
//  Ulmago
//
//  Created by dhui on 3/16/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DailyExpenseSettingVC: UIViewController {
    
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var dailyExpenseTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
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
    
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
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
        
        let mainString = "\(goalText)을/를 위해\n"
        let secondString = "\(wholeCostText)을 모을거에요!"
        let range = (mainString as NSString).range(of: goalText)
        let secondRange = (secondString as NSString).range(of: wholeCostText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        let secondMutableAttributedString = NSMutableAttributedString.init(string: secondString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: range)
        secondMutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: secondRange)
        mutableAttributedString.append(secondMutableAttributedString)
        self.goalLabel.attributedText = mutableAttributedString
        
        textFieldSetting(self.dailyExpenseTextField, "5만원 / 10만원", keyboardType: .numberPad)
        
        self.submitBtn.isEnabled = false
        self.submitBtn.alpha = 0.8
        self.submitBtn.submitButtonSetting()
        
        let textFieldInt = Int(self.dailyExpenseTextField.text!) ?? 0
        let wholeCostInt = Int(self.wholeCostText) ?? 0
        
        self.dailyExpenseTextField.rx.text
            .map { $0?.count != 0 }
            .bind(onNext: { isEmpty in
                if isEmpty {
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1.0
                } else {
                    self.submitBtn.isEnabled = false
                    self.submitBtn.alpha = 0.8
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        
        
        let storyboard = UIStoryboard(name: DailyMainVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: DailyMainVC.reuseIdentifier, creator: { coder in
            return DailyMainVC(coder: coder, goalText: self.goalText, wholeCostText: self.wholeCostText)
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
