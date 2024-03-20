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
    
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var vm: MainVM = MainVM()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#fileID, #function, #line, "- ")
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        textFieldSetting(self.goalTextField)
        self.goalTextField.delegate = self
        
        self.goalTextField.becomeFirstResponder()
        
        self.submitBtn.isEnabled = false
        self.submitBtn.alpha = 0.8
        self.submitBtn.submitButtonSetting()
        
        #warning("TODO: - 노티피케이션 & 키보드 처리 - 정대리님 영상 보고 공부하기")
       
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()

        
        
        //MARK: - Rx로 데이터 짜기
        
        let input = MainVM.Input(textFieldText: self.goalTextField.rx.text.orEmpty.asObservable())
        
        let output = vm.transform(input: input)
        
        
        output
            .isTextFieldEmpty
            .bind(to: self.submitBtn.rx.disabled)
            .disposed(by: disposeBag)
        
        
    } // viewDidLoad()
   

    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 목표 설정 완료 버튼 클릭")
        
        guard let dataToSend: String = self.goalTextField.text else { return }
        
        let storyboard = UIStoryboard(name: WholeCostSettingVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: WholeCostSettingVC.reuseIdentifier, creator: { coder in
            return WholeCostSettingVC(coder: coder, goalText: dataToSend)
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: - keyboard 처리
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
    
    
    @objc func keyboardWillShow(_ sender: Notification){
        
        print(#fileID, #function, #line, "- sender: \(sender)")
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
        
    @objc func keyboardWillHide(_ sender: Notification){

        if let keyboardSize = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
           let curve = sender.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            let keyboardHeight: CGFloat = 257.0
            let animationOptions = UIView.AnimationOptions(rawValue: curve)
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
                self.bottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    // 텍스트필드 글자 수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}



