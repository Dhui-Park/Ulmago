//
//  WholeCostSettingVC.swift
//  Ulmago
//
//  Created by dhui on 3/14/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

class WholeCostSettingVC: UIViewController {
    
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var wholeCostTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var vm: WholeCostSettingVM = WholeCostSettingVM()
    
    var userInputRelay : PublishRelay<String> = PublishRelay()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var goalText: String = "" {
        didSet {
            print(#fileID, #function, #line, "- goalText: \(goalText)")
        }
    }
    
    init?(coder: NSCoder, goalText: String) {
        self.goalText = goalText
        super.init(coder: coder)
        print(#fileID, #function, #line, "- goalText from ViewController: \(goalText) ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.wholeCostTextField.becomeFirstResponder()
        
        let mainString = "\(goalText)을/를 위해\n 얼마고와 함께 모을\n 총 비용은 얼마인가요?"
        let range = (mainString as NSString).range(of: goalText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: range)
        self.goalLabel.attributedText = mutableAttributedString
        
        
        
        textFieldSetting(self.wholeCostTextField, "50만원 / 100만원", keyboardType: .numberPad)
        self.wholeCostTextField.delegate = self

        
        self.submitBtn.isEnabled = false
        self.submitBtn.alpha = 0.8

        // 문제: 뷰컨에서 입력되는 텍스트필드의 텍스트를 뷰모델에 제대로 전달 X
        
        let input = WholeCostSettingVM.Input(wholeCostInput: self.userInputRelay.asObservable())
        
        let output = self.vm.transform(input: input)
        
        output
            .isTextFieldEmpty
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)

    }
    
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 총 비용 설정 완료 버튼 클릭")
        
        guard let wholeCostText: String = self.wholeCostTextField.text else { return }
        
        let storyboard = UIStoryboard(name: DailyExpenseSettingVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: DailyExpenseSettingVC.reuseIdentifier, creator: { coder in
            return DailyExpenseSettingVC(coder: coder, goalText: self.goalText, wholeCost: Int(wholeCostText) ?? 0)
        })
        
        if let userGoal = UserGoalRepository.shared.fetchUserGoalEntities().first {
            UserGoalRepository.shared.editUserGoal(at: userGoal._id, updatedGoalTitle: nil, updatedGoalPrice: Int(wholeCostText) ?? 0)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension WholeCostSettingVC: UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
//        if !CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
//            return false
//        }
        
        print(#fileID, #function, #line, "- 🚩")
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = ","
                
         let completeString = textField.text!.replacingOccurrences(of: formatter.groupingSeparator, with: "") + string
                
        let value = Int64(completeString) ?? 0
        
        print(#fileID, #function, #line, "🚩 - value : \(value) completeString: \(completeString)")
        
        var numberFromTextField = value
        

        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)

        if newString.isEmpty {
            self.userInputRelay.accept("")
        } else {
            self.userInputRelay.accept(completeString)
        }
        
        let formattedNumber = formatter.string(from: NSNumber(value: value)) ?? ""
        textField.text = formattedNumber
        

        
        if string.isEmpty {
            
            return true
        }
        

        
        return string == formatter.decimalSeparator
        
        
        
//
//        
//        return false
//        return true
    }
}

