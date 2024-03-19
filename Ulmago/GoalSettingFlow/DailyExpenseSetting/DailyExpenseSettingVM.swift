//
//  DailyExpenseSettingVM.swift
//  Ulmago
//
//  Created by dhui on 3/19/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

/// input (action) -> calculate (vm)  -> output (data state)

class DailyExpenseSettingVM {
    
    struct Input {
        let expenseInput : Observable<String>
    }
    
    struct Output {
        let expenseValidation : Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let isTextFieldTextEmpty = input.expenseInput
            .map { $0.count } // 2. 텍스트필드의 글자 수를 센다.
            .map { $0 == 0 }
        
        let isMaxExpense = input.expenseInput
            .compactMap { Int($0) }
            .map { dailyExpense in
                // 4. 전 화면에서 입력한 총 비용 액수와 사용자가 입력한 소비한도를 비교한다.
                // 5. 조건: 소비한도가 총 비용 액수보다 작다
                print("👉dailyExpense: \(dailyExpense)")
                print("👉wholeCostInt: \(self.wholeCost)")
                return dailyExpense > self.wholeCost
            } // 5. 조건이 참이면 확인 버튼 활성화 / 거짓 -> 비활성화
        
        let expenseValidation = Observable.combineLatest(isTextFieldTextEmpty, isMaxExpense)
                   .map({ (isEmpty, isMax) in
       
                       if isEmpty {
                           return false
                       }
       
                       if isMax {
                           return false
                       }
                       return true
                   })
        
        return Output.init(expenseValidation: expenseValidation)
    }
    
    
    // input
    var textFieldText: PublishRelay<String> = PublishRelay()
    
    // output
    var expenseValidation: Observable<Bool> = Observable.empty()
    
    var isTextFieldTextEmpty: Observable<Bool> = Observable.empty()
    var isMaxExpense: Observable<Bool> = Observable.empty()
    
    
    var wholeCost : Int
    
    
    init(wholeCost: Int) {
        self.wholeCost = wholeCost
        
//        var checkEmptyString = self.dailyExpenseTextField.rx.text.orEmpty // 1. 텍스트필드의 글자를 가져온다.
//            .map { $0.count } // 2. 텍스트필드의 글자 수를 센다.
//            .map { $0 == 0 } // 2-1. 조건: 텍스트필드의 글자 수가 0이 아니면 -> 버튼 활성화
//        isTextFieldTextEmpty = textFieldText
//            .map { $0.count } // 2. 텍스트필드의 글자 수를 센다.
//            .map { $0 == 0 }
//        
////        var checkMaxDailyExpense = self.dailyExpenseTextField.rx.text.orEmpty  // 2. 사용자가 텍스트필드에서 오늘의 소비한도를 입력한다.
////            // 3. 입력된 소비한도를 Int로 바꾼다.
////            .compactMap { Int($0) }
////            .map { dailyExpense in
////                // 4. 전 화면에서 입력한 총 비용 액수와 사용자가 입력한 소비한도를 비교한다.
////                // 5. 조건: 소비한도가 총 비용 액수보다 작다
////                print("👉dailyExpense: \(dailyExpense)")
////                print("👉wholeCostInt: \(self.wholeCost)")
////                return dailyExpense < self.wholeCost
////            } // 5. 조건이 참이면 확인 버튼 활성화 / 거짓 -> 비활성화
//        
//        isMaxExpense = textFieldText
//            .compactMap { Int($0) }
//            .map { dailyExpense in
//                // 4. 전 화면에서 입력한 총 비용 액수와 사용자가 입력한 소비한도를 비교한다.
//                // 5. 조건: 소비한도가 총 비용 액수보다 작다
//                print("👉dailyExpense: \(dailyExpense)")
//                print("👉wholeCostInt: \(self.wholeCost)")
//                return dailyExpense > self.wholeCost
//            } // 5. 조건이 참이면 확인 버튼 활성화 / 거짓 -> 비활성화
//        
//        self.expenseValidation = Observable.combineLatest(isTextFieldTextEmpty, isMaxExpense)
//                   .map({ (isEmpty, isMax) in
//       
//                       if isEmpty {
//                           return false
//                       }
//       
//                       if isMax {
//                           return false
//                       }
//                       return true
//                   })
        
    }
    
}
