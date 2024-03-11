//
//  ViewController.swift
//  Ulmago
//
//  Created by dhui on 3/11/24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textFieldSetting(self.goalTextField)
        self.goalTextField.delegate = self
        
        self.submitBtn.isEnabled = false
        self.submitBtn.alpha = 0.8

        
//        self.goalTextField.rx.text.orEmpty
//            .scan("", accumulator: { (previous, new) -> String in
//                if new.count > 15 {
//                    print(#fileID, #function, #line, "- ")
//                    return previous
//                } else {
//                    return new
//                }
//            })
//            .bind(to: self.goalTextField.rx.text)
//            .disposed(by: disposeBag)
        
        self.goalTextField.rx.text
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
    
    
    /// 텍스트필드 세팅
    /// - Parameters:
    ///   - textField: 텍스트필드 이름
    ///   - placeholder: 플레이스홀더
    ///   - keyboardType: 키보드 타입
    func textFieldSetting(_ textField: UITextField, _ placeholder: String = "맥북 프로 / 괌 여행 / 자전거", keyboardType: UIKeyboardType = .default) {
        textField.placeholder = placeholder
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.tintColor = .systemOrange
    }

    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 목표 설정 완료 버튼 클릭")
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    // 텍스트필드 글자 수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
