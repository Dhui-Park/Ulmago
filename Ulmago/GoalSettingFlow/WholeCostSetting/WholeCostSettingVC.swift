//
//  WholeCostSettingVC.swift
//  Ulmago
//
//  Created by dhui on 3/14/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class WholeCostSettingVC: UIViewController {
    
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var wholeCostTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
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
        
        
        
        self.wholeCostTextField.rx.text
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
//        initializeHideKeyboard()
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 총 비용 설정 완료 버튼 클릭")
        
        guard let wholeCostText: String = self.wholeCostTextField.text else { return }
        
        let storyboard = UIStoryboard(name: DailyExpenseSettingVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: DailyExpenseSettingVC.reuseIdentifier, creator: { coder in
            return DailyExpenseSettingVC(coder: coder, goalText: self.goalText, wholeCost: Int(wholeCostText) ?? 0)
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension WholeCostSettingVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
