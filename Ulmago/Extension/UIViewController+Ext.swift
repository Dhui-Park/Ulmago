//
//  UIViewController+Ext.swift
//  Ulmago
//
//  Created by dhui on 3/20/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// 텍스트필드 세팅
    /// - Parameters:
    ///   - textField: 텍스트필드 이름
    ///   - placeholder: 플레이스홀더
    ///   - keyboardType: 키보드 타입
    func textFieldSetting(_ textField: UITextField, _ placeholder: String = "맥북 프로 / 괌 여행 / 자전거", keyboardType: UIKeyboardType = .default) {
        textField.placeholder = placeholder
        textField.textColor = UIColor(named: "redBean")
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(named: "redBean")?.cgColor
        textField.layer.cornerRadius = 8
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.tintColor = UIColor(named: "redBean")
    }
}
