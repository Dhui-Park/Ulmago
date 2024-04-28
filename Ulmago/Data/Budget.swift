//
//  Budget.swift
//  Ulmago
//
//  Created by dhui on 3/23/24.
//

import Foundation
import Realm
import RealmSwift

struct Budget {
    
    var title: String
    var price: Int
    var date: Date
    var id: String? = nil
    
    var objectId : ObjectId? {
        get {
            return try? ObjectId(string: id ?? "")
        }
    }
    
    init(title: String, price: Int = 0, date: Date = Date()) {
        self.title = title
        self.price = price
        self.date = date
    }
    
    init(entity: BudgetEntity) {
        self.id = entity._id.stringValue
        self.title = entity.title
        self.price = entity.price
        self.date = entity.date
    }
    
    
    static func getDummies() -> [Budget] {
        return [Budget(title: "치킨", price: 14000, date: "2024-03-26".toDate()),
                Budget(title: "짜장면", price: 6500, date: "2024-04-10".toDate()),
                Budget(title: "짜장면", price: 6500, date: "2024-03-27".toDate()),
                Budget(title: "짜장면", price: 6500, date: "2024-03-27".toDate()),
                Budget(title: "중화짜장면", price: 6500),
                Budget(title: "짬뽕", price: 6500)]
    }
}

//class Todo: Object {
//   @Persisted(primaryKey: true) var _id: ObjectId
//   @Persisted var name: String = ""
//   @Persisted var status: String = ""
//   @Persisted var ownerId: String
//   convenience init(name: String, ownerId: String) {
//       self.init()
//       self.name = name
//       self.ownerId = ownerId
//   }
//}

// 스키마 설정
class BudgetEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String = ""
    @Persisted var price: Int = 0
    @Persisted var date: Date
    
    convenience init(title: String, price: Int, date: Date = Date()) {
        self.init()
        self.title = title
        self.price = price
        self.date = date
    }
    
    
}


class BudgetRepository {
    
    // Singleton Pattern
    static let shared = BudgetRepository()
    
   
    
    /// 로컬에 single Budget 추가하기
    /// - Parameters:
    ///   - title: 추가할 Budget의 제목
    ///   - price: 추가할 Budget의 금액
    ///   - date: 추가할 Budget의 날짜. 넣지 않으면 현재 날짜로 추가된다.
    func createBudget(title: String, price: Int, date: Date) {
        
        let newBudget = BudgetEntity(title: title, price: price, date: date)
        
        //Get the default realm. You only need to do this once per thread.
        let realm = try! Realm()
        // Open a thread-safe transaction.
        try! realm.write {
            // Add the instance to the realm.
            realm.add(newBudget)
        }
    }
    
    /// All Budgets 조회하기
    /// - Returns: Array of BudgetEntities
    func fetchBudgetEntities() -> [BudgetEntity] {
        let realm = try! Realm()
        // Access all dogs in the realm
        let allBudgets = realm.objects(BudgetEntity.self)
        
        return allBudgets.map{ $0 }
    }
    
    // 목표: 총 모은 금액을 가져온다.
    
    
    
    
    
    /// 총 모은 금액을 가져온다.
    /// - Returns: 총 모은 금액
    func fetchAllSavedMoney() -> Int {
        // 1. 총 BudgetEntity를 조회한다.
        var allBudgets: [BudgetEntity] = fetchBudgetEntities()
        var allBudgetsWithFilteredDate = Set(allBudgets.map({ $0.date.toDateString() }))
//        Dictionary(grouping: allBudgets, by: { item in
//            item.date.toDateString()
//        })
//        var groupingBudgetsByDate = Dictionary(grouping: allBudgetsWithFilteredDate, by: \.date)
//        print(#fileID, #function, #line, "- groupingBudgetsByDate: \(groupingBudgetsByDate.keys.count)")
        print(#fileID, #function, #line, "- allBudgetsWithFilteredDate: \(allBudgetsWithFilteredDate)")
        // 2. 총 사용금액을 더해서 가져온다.
        let totalUsageAmount: Int  = allBudgets
            .compactMap { $0.price }
            .reduce(0, +)
        // 3. 하루소비한도를 가져온다.
        let dailyExpenseLimit: Int = UserGoalRepository.shared.fetchSingleUserGoalEntity()?.dailyExpenseLimit ?? 0
        // 4. 하루소비한도를 가져온 BudgetEntity의 갯수만큼 곱해준다.
        let wholeExpenseLimit: Int = dailyExpenseLimit * allBudgetsWithFilteredDate.count
        // 5. 누적된 소비한도에서 총 사용금액을 빼준다. -> 총 모은 금액
        let totalSavedMoneyAmount: Int = wholeExpenseLimit - totalUsageAmount
    
        return totalSavedMoneyAmount
    }
    
    
    /// Single Budget 조회하기
    /// - Parameter forPrimaryKey: 조회할 Budget의 PrimaryKey
    /// - Returns: single BudgetEntity or nil
    func fetchABudget(at forPrimaryKey: ObjectId) -> BudgetEntity? {
        let realm = try! Realm()
        let specificBudget = realm.object(ofType: BudgetEntity.self, forPrimaryKey: forPrimaryKey)
        
        return specificBudget
    }
    
    /// All Budgets 삭제하기
    func deleteAllBudgets() {
        let realm = try! Realm()
        
        try! realm.write {
            // Delete all instances of Dog from the realm.
            let allBudgets = realm.objects(BudgetEntity.self)
            realm.delete(allBudgets)
        }
    }
    
    /// Single Budget 삭제하기
    /// - Parameter forPrimaryKey: 삭제할 Budget의 PrimaryKey
    func deleteABudget(at forPrimaryKey: ObjectId) {
        
        if let budgetToDelete = self.fetchABudget(at: forPrimaryKey) {
            print(#fileID, #function, #line, "- fetchABudget: \(budgetToDelete)")
            let realm = try! Realm()
            // Delete the instance from the realm.
            try! realm.write {
                realm.delete(budgetToDelete)
            }
        } else {
            if let budgetToDelete = self.fetchBudgetEntities().filter({ $0._id == forPrimaryKey }).first {
                let realm = try! Realm()
                // Delete the instance from the realm.
                try! realm.write {
                    realm.delete(budgetToDelete)
                }
            }
        }
    }
    
    
    struct UpdateParms {
        var title : String?
        var price : Int?
    }
    
    func someTest (){
//        editBudget(at: ObjectId(), params: ["title" : "sdfsdf", 
//                                            "price" : 123])
    }
    
    
    /// Single Budget 수정하기
    /// - Parameters:
    ///   - forPrimaryKey: 수정할 Budget의 PrimaryKey
    ///   - params: 수정할 내용
//    func editBudget(at forPrimaryKey: ObjectId, params: [String: Any]) {
    func editBudget(at forPrimaryKey: ObjectId, updatedTitle: String?, updatedPrice: Int?) {
        
        let realm = try! Realm()
        // Get a dog to update
        if let budgetToEdit = self.fetchABudget(at: forPrimaryKey) {
            // Open a thread-safe transaction
            try! realm.write {
                
//                if case let updatedTitle? = params["title"] as? String {
//                    budgetToEdit.title = updatedTitle
//                }
                if let updatedTitle = updatedTitle {
                    budgetToEdit.title = updatedTitle
                }
                if let updatedPrice = updatedPrice {
                    budgetToEdit.price = updatedPrice
                }
            }
            
        }
    }
    
    // ======
    
    
    /// BudgetEntity를 Budget으로 바꿔주기
    /// - Returns: Array of Budget
    func fetchBudgetsFromBudgetEntity() -> [Budget] {
        
        return fetchBudgetEntities().map({ Budget(entity: $0) })
        
    }
    
    
    
}
