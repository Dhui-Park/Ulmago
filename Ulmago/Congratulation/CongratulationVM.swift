//
//  CongratulationVM.swift
//  Ulmago
//
//  Created by dhui on 4/28/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class CongratulationVM {
    
    static let shared: CongratulationVM = CongratulationVM()
    
    var isAnimating: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    init() {
        print(#fileID, #function, #line, "- ")
    }
    
    
    
}
