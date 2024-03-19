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
    
    struct Input {
        let textFieldText: Observable<String>
    }
    
    struct Output {
        let isTextFieldEmpty: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        self.isTextFieldEmpty = input.textFieldText
            .map { $0.count }
            .map { $0 == 0 }
        
        return Output(isTextFieldEmpty: isTextFieldEmpty)
    }
    
    // input
    var textFieldText: PublishRelay<String> = PublishRelay()
    
    // output
    var isTextFieldEmpty: Observable<Bool> = Observable.empty()
    
    init() {
        
        
        self.isTextFieldEmpty = self.textFieldText
            .map { $0.count }
            .map { $0 == 0 }
        
        
        
        
    }
    
    
    

    
}
