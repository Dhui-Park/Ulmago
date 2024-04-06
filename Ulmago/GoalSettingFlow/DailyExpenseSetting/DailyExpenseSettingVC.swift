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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#fileID, #function, #line, "- ")
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        let input = DailyExpenseSettingVM.Input(expenseInput: self.dailyExpenseTextField.rx.text.orEmpty.asObservable()) // Observable<String>
        
        let output = vm.transform(input: input)
        
        output
            .expenseValidation
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)
        
        vm.expenseValidation
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)
         
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
    }
    
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        guard let dailyExpense = self.dailyExpenseTextField.text else { return }
       
        let storyboard = UIStoryboard(name: DailyMainVC.reuseIdentifier, bundle: .main)
        
        let vc = storyboard.instantiateViewController(identifier: DailyMainVC.reuseIdentifier, creator: { coder in
            return DailyMainVC(coder: coder, goalText: self.goalText, wholeCostText: "\(self.wholeCost / 10000)", dailyExpense: dailyExpense)
        })
        
        if let userGoal = UserGoalRepository.shared.fetchUserGoalEntities().first {
            UserGoalRepository.shared.editUserGoal(at: userGoal._id, updatedGoalTitle: nil, updatedGoalPrice: self.wholeCost, updatedDailyExpenseLimit: Int(dailyExpense) ?? 0)
        }
        
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

extension DailyExpenseSettingVC {
    @objc fileprivate func handleKeyboardShow(_ sender: NSNotification) {
        print(#fileID, #function, #line, "- ")
        
        if let keyboardSize = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            
            let keyboardHeight: CGFloat = keyboardSize.height
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.bottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc fileprivate func handleKeyboardHide(_ sender: NSNotification) {
        print(#fileID, #function, #line, "- ")
        
        if let keyboardSize = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            
            let keyboardHeight: CGFloat = 274.0
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.bottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
    
}
