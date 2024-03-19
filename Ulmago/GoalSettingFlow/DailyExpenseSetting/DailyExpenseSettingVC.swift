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
    
    // 원자재
    var wholeCost: Int = 0 {
        didSet {
            print(#fileID, #function, #line, "- wholeCost: \(wholeCost)")
        }
    }
    
    // presentation layer
    private var wholeCostText: String {
        "\(self.wholeCost / 10000)만원"
    }
    
    var vm: DailyExpenseSettingVM? = nil
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    init?(coder: NSCoder, goalText: String, wholeCost: Int) {
        self.goalText = goalText
        self.wholeCost = wholeCost * 10000
        self.vm = DailyExpenseSettingVM(wholeCost: self.wholeCost)
//        self.wholeCostText = wholeCost + "만원"
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
        
        self.dailyExpenseTextField.delegate = self
        self.dailyExpenseTextField.becomeFirstResponder()
        
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
        
        
        guard let vm = self.vm else { return }
        
        let input = DailyExpenseSettingVM.Input(expenseInput: self.dailyExpenseTextField.rx.text.orEmpty.asObservable())
        
        let output = vm.transform(input: input)
        
        output
            .expenseValidation
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)
        
        vm.expenseValidation
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)
         
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
//        initializeHideKeyboard()
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


extension DailyExpenseSettingVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}

extension Reactive where Base: UIButton {
    var disabled: Binder<Bool> {
        return Binder(base, binding: { target, value in
            if value {
                target.isEnabled = false
                target.alpha = 0.8
            } else {
                target.isEnabled = true
                target.alpha = 1.0
            }
        })
    }
}
