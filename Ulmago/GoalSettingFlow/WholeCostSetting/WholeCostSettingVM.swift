//
//  WholeCostSettingVM.swift
//  Ulmago
//
//  Created by dhui on 3/20/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class WholeCostSettingVM {
    
    struct Input {
        let wholeCostInput: Observable<String>
    }
    
    struct Output {
        let isTextFieldEmpty: Observable<Bool>
        
    }
    
    func transform(input: Input) -> Output {
        
        isTextFieldEmpty = input.wholeCostInput
            .debug("test 1")
            .map { $0.count }
            .debug("test 2")
            .map { $0 == 0 }
            .debug("test 3")
        

        return Output(isTextFieldEmpty: isTextFieldEmpty)

    }
    
    var textFieldtext: PublishRelay<String> = PublishRelay()
    
    var isTextFieldEmpty: Observable<Bool> = Observable.empty()
    
    
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        isTextFieldEmpty = textFieldtext
            .map { $0.count }
            .map { $0 == 0 }
        
        
        
    }
}
