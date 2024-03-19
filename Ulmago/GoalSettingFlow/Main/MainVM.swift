//
//  MainVM.swift
//  Ulmago
//
//  Created by dhui on 3/11/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MainVM {
    
    var isTextFieldEmpty: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    init() {
        
    }
    
    func checkTextFieldEmpty(textField: UITextField, button: UIButton) {
        
        if textField.text?.count != 0 {
            isTextFieldEmpty.accept(false)
        } else {
            isTextFieldEmpty.accept(true)
        }
    }
    
}
