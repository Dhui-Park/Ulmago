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
import Realm
import RealmSwift
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
    
    var remainedGraphPercent: Observable<Float> = Observable.empty()
    
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
        
        //
        
        self.budgetList.accept(BudgetRepository.shared.fetchBudgetsFromBudgetEntity())
        
        self.updateDailySpend()
        
        self.goalTextLabel = self.goalText
            .map { self.changeSpecificTextColor(specificText: $0, normalString: "을/를 위해 우리는") }
        
        self.progressPercentText = self.progressPercent
            .map { self.changeSpecificTextColor(specificText: "\($0)%", normalString: "를 모았어요!") }
        
        let dailyExpenseObservable = self.dailyExpenseText
            .compactMap { Int($0) }
        
        
        
        // 오늘 남은 소비한도
        self.remainedDailyExpense = Observable.combineLatest(dailyExpenseObservable, self.dailySpend.asObservable())
            .debug("remained 1")
            .map { dailyExpense, dailySpend in
                return dailyExpense - dailySpend
            }
            .debug("remained 2")
        
        self.remainedGraphPercent = self.remainedDailyExpense
            .do(onNext: {
                print("percent 1 Float($0): \(Float($0)) dailyExpense: \((Float(self.dailyExpenseText.value) ?? 1)) ")
            })
            .map { Float($0) / (Float(self.dailyExpenseText.value) ?? 1)  } // part / whole
            .debug("percent ")
        

        
        
    }
    
    // 한 문장 내에서 특정 부분 텍스트 색깔 바꾸기
    func changeSpecificTextColor(specificText: String, normalString: String) -> NSMutableAttributedString {
        let mainString = specificText + normalString
        let range = (mainString as NSString).range(of: specificText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "redBean"), range: range)
        return mutableAttributedString
    }
    
    // 오늘 소비한 금액 업데이트: Budget의 price들만 모두 더하기
    func updateDailySpend() {
        let sum = self.budgetList.value
            .filter({ $0.date.toDateString() == Date.now.toDateString() })
            .compactMap { $0.price }
            .reduce(0, +)
        
        print("Sum of budgetList's prices is : ", sum)
        self.dailySpend.accept(sum)
        
    }
    
    // 모든 남은 소비 금액들 더하기
    func updateWholeDailySpend() {
        let wholeSum = self.budgetList.value
            .filter({ $0.date.toDateString() == Date.now.toDateString() })
            .compactMap { $0.price }
            .reduce(0, +)
    }
    
    // 테이블뷰에 새로운 Budget 추가
    func addToTableView(newTitle: String, newPrice: Int, date: Date = Date.now) {
        BudgetRepository.shared.createBudget(title: newTitle, price: newPrice, date: date)
        self.budgetList.accept(BudgetRepository.shared.fetchBudgetsFromBudgetEntity())
    }
    
    func editTableViewItem(at: ObjectId, newTitle: String, newPrice: Int) {
        BudgetRepository.shared.editBudget(at: at, updatedTitle: newTitle, updatedPrice: newPrice)
        self.budgetList.accept(BudgetRepository.shared.fetchBudgetsFromBudgetEntity())
    }
    
    // 테이블 뷰의 선택한 Budget 삭제
    func deleteTableViewItem(_ deletingBudget: Budget) {
        var currentBudgetList = self.budgetList.value
        print(#fileID, #function, #line, "- currentBudgetList: \(currentBudgetList)")

        #warning("TODO: - 왜 삭제가 바로바로 적용이 안될까? - 1.objectId가 제대로 들어오지 않나? 2. BudgetRepository의 deleteABudget이 제대로 작동하지 않나?")
        #warning("TODO: - 아하!! 테이블뷰에 추가할때 vm의 budgetList에 realm에 추가된거까지 제대로 반영이 되지 않고 있었다.")
        print(#fileID, #function, #line, "- \(currentBudgetList)")
        // realm에서 지우기
        
        guard let deletingItemObjectId = deletingBudget.objectId else {
            return
        }
        let date = deletingBudget.date
        
        BudgetRepository.shared.deleteABudget(at: deletingItemObjectId)
        
//        BudgetRepository.shared.deleteAllBudgets()
        
        // UI dataList에서 지우기
        
        // 버젯리스트에서 삭제할 해당 쎌을 찾는다.
        var dummies = self.budgetList.value.filter({ $0.date.toDateString() == date.toDateString() })
        
        if let deletingIndex: Int = dummies.firstIndex(where: {
            return deletingItemObjectId.stringValue == ($0.id ?? "")
        }) {
            currentBudgetList.remove(at: deletingIndex)
            self.budgetList.accept(currentBudgetList)
        }
    }
}
