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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
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
        
        dump(sender)
        
//        self.view.frame.origin.y = 0
        self.bottomConstraint.constant = 400
        
//        UIView.animate(withDuration: <#T##TimeInterval#>, delay: <#T##TimeInterval#>, animations: <#T##() -> Void#>)
        
        // 1. 오토레이아웃 건드리기
        // 2. UI 자체를 원래 올려서 보여주기
    }
        
    @objc func keyboardWillHide(_ sender: Notification){
//        self.view.frame.origin.y = 0
        self.bottomConstraint.constant = 120
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



