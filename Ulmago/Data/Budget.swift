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
    
    static let shared = BudgetRepository()
    
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
    
    func fetchBudgetEntities() -> [BudgetEntity] {
        let realm = try! Realm()
        // Access all dogs in the realm
        let allBudgets = realm.objects(BudgetEntity.self)
        
        return allBudgets.map{ $0 }
    }
    
    func fetchABudget(at forPrimaryKey: ObjectId) -> BudgetEntity? {
        let realm = try! Realm()
        let specificBudget = realm.object(ofType: BudgetEntity.self, forPrimaryKey: forPrimaryKey)
        
        return specificBudget
    }
    
    func deleteAllBudgets() {
        let realm = try! Realm()
        
        try! realm.write {
            // Delete all instances of Dog from the realm.
            let allBudgets = realm.objects(BudgetEntity.self)
            realm.delete(allBudgets)
        }
    }
    
    func deleteABudget(at forPrimaryKey: ObjectId) {
        
        if let budgetToDelete = self.fetchABudget(at: forPrimaryKey) {
            let realm = try! Realm()
            // Delete the instance from the realm.
            try! realm.write {
                realm.delete(budgetToDelete)
            }
        }
        
    }
    
    struct UpdateParms {
        var title : String?
        var price : Int?
    }
    
    func someTest (){
        editBudget(at: ObjectId(), params: ["title" : "sdfsdf", 
                                            "price" : 123])
    }
    
    
    func editBudget(at forPrimaryKey: ObjectId, params: [String: Any]) {
//    func editBudget(at forPrimaryKey: ObjectId, updatedTitle: String?, updatedPrice: Int?) {
        
        let realm = try! Realm()
        // Get a dog to update
        if let budgetToEdit = self.fetchABudget(at: forPrimaryKey) {
            // Open a thread-safe transaction
            try! realm.write {
                
                if case let updatedTitle? = params["title"] as? String {
                    budgetToEdit.title = updatedTitle
                }
                
                // Update some properties on the instance.
                // These changes are saved to the realm
//                if case let updatedTitle? = updatedTitle {
//                    budgetToEdit.title = updatedTitle
//                }
//                if case let updatedPrice? = updatedPrice {
//                    budgetToEdit.price = updatedPrice
//                }
            }
            
        }
    }
    
    // ======
    
    func fetchBudgets() -> [Budget] {
        
        return fetchBudgetEntities().map({ Budget(entity: $0) })
        
    }
}
