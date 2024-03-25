//
//  DailyBudgetVM.swift
//  Ulmago
//
//  Created by dhui on 3/25/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import UIKit

class DailyBudgetVM {
    
    static let shared: DailyBudgetVM = DailyBudgetVM()
    
    // 목표
    var goalText: BehaviorRelay<String> = BehaviorRelay(value: "")
    var goalTextLabel: Observable<NSMutableAttributedString> = Observable.empty()

    // 총 비용
    var wholeCostText: BehaviorRelay<String> = BehaviorRelay(value: "")

    // 소비 한도
    var dailyExpenseText: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    
    var budgetList: BehaviorRelay<[Budget]> = BehaviorRelay(value: [])
    
    
    // 오늘 쓴 금액
    var dailySpend: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    // 오늘 쓸 수 있는 남은 금액: dailyExpense - dailySpend
    var remainedDailyExpense: Observable<Int> = Observable.empty()
    
    // [{(하루 소비한도) - (1일차 소비한 금액)} + {(하루 소비한도) - (2일차 소비한 금액)} + {(하루 소비한도) - (3일차 소비한 금액)} + ... + {(하루 소비한도) - (가장 최근 날짜 소비한 금액)}] / 총 비용
    var progressPercent: BehaviorRelay<Int> = BehaviorRelay(value: 50)
    var progressPercentText: Observable<NSMutableAttributedString> = Observable.empty()
    
    convenience init(goalText: String, wholeCostText: String, dailyExpense: String) {
        self.init()
        self.goalText.accept(goalText)
        self.wholeCostText.accept(wholeCostText)
        self.dailyExpenseText.accept(dailyExpense)
    }
    
    init() {
        print(#fileID, #function, #line, "- ")
        self.updateDailySpend()
        
        self.goalTextLabel = self.goalText
            .map { self.changeSpecificTextColor(specificText: $0, normalString: "을/를 위해 우리는") }
        
        self.progressPercentText = self.progressPercent
            .map { self.changeSpecificTextColor(specificText: "\($0)%", normalString: "를 모았어요!") }
        
        self.remainedDailyExpense = self.dailyExpenseText
            .compactMap { Int($0) }
            .debug("📌")
            .map { $0 - self.dailySpend.value }
        

        
        
    }
    
    func changeSpecificTextColor(specificText: String, normalString: String) -> NSMutableAttributedString {
        let mainString = specificText + normalString
        let range = (mainString as NSString).range(of: specificText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: range)
        return mutableAttributedString
    }
    
    // 오늘 소비한 금액 업데이트
    func updateDailySpend() {
        let sum = self.budgetList.value
            .compactMap { $0.price }
            .reduce(0, +)
        
        print("Sum of budgetList's prices is : ", sum)
        self.dailySpend.accept(sum)
        
    }
    
    func addToTableView(newTitle: String, newPrice: Int) {
        self.budgetList.accept(self.budgetList.value + [Budget(title: newTitle, price: newPrice)])
    }
    
    func deleteTableViewItem(indexPath: IndexPath) {
        var currentBudgetList = self.budgetList.value
        currentBudgetList.remove(at: indexPath.row)
        self.budgetList.accept(currentBudgetList)
    }
}
