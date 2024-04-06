//
//  UserGoal.swift
//  Ulmago
//
//  Created by dhui on 4/6/24.
//

import Foundation
import Realm
import RealmSwift

struct UserGoal {
    
    var goalTitle: String
    var goalPrice: Int
    var dailyExpenseLimit: Int
    var id: String? = nil
    
    init(goalTitle: String, goalPrice: Int = 0, dailyExpenseLimit: Int = 0) {
        self.goalTitle = goalTitle
        self.goalPrice = goalPrice
        self.dailyExpenseLimit = dailyExpenseLimit
    }
    
    init(entity: UserGoalEntity) {
        self.id = entity._id.stringValue
        self.goalTitle = entity.goalTitle
        self.goalPrice = entity.goalPrice
        self.dailyExpenseLimit = entity.dailyExpenseLimit
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
class UserGoalEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var goalTitle: String = ""
    @Persisted var goalPrice: Int = 0
    @Persisted var dailyExpenseLimit: Int = 0
    
    
    convenience init(goalTitle: String, goalPrice: Int, dailyExpenseLimit: Int) {
        self.init()
        self.goalTitle = goalTitle
        self.goalPrice = goalPrice
        self.dailyExpenseLimit = dailyExpenseLimit
    }
    
    
}


class UserGoalRepository {
    
    // Singleton Pattern
    static let shared = UserGoalRepository()
   
    
    /// 로컬에 single UserGoal 추가하기
    /// - Parameters:
    ///   - title: 추가할 UserGoal의 타이틀
    ///   - price: 추가할 UserGoal의 전체 금액. 없으면 0으로 설정
    ///   - date: 추가할 UserGoal의 하루 소비 한도. 없으면 0으로 설정
    func createUserGoal(goalTitle: String, goalPrice: Int = 0, dailyExpenseLimit: Int = 0) {
        
        let newUserGoal = UserGoalEntity(goalTitle: goalTitle, goalPrice: goalPrice, dailyExpenseLimit: dailyExpenseLimit)
        
        //Get the default realm. You only need to do this once per thread.
        let realm = try! Realm()
        // Open a thread-safe transaction.
        try! realm.write {
            // Add the instance to the realm.
            realm.add(newUserGoal)
        }
    }
    
    /// All UserGoals 조회하기
    /// - Returns: Array of UserGoalEntities
    func fetchUserGoalEntities() -> [UserGoalEntity] {
        let realm = try! Realm()
        // Access all dogs in the realm
        let allUserGoals = realm.objects(UserGoalEntity.self)
        
        return allUserGoals.map{ $0 }
    }
    
    
    /// Single UserGoal 조회하기
    /// - Parameter forPrimaryKey: 조회할 UserGoal의 PrimaryKey
    /// - Returns: single UserGoalEntity or nil
    func fetchAUserGoal(at forPrimaryKey: ObjectId) -> UserGoalEntity? {
        let realm = try! Realm()
        let specificUserGoal = realm.object(ofType: UserGoalEntity.self, forPrimaryKey: forPrimaryKey)
        
        return specificUserGoal
    }
    
    /// All UserGoals 삭제하기
    func deleteAllUserGoals() {
        let realm = try! Realm()
        
        try! realm.write {
            // Delete all instances of Dog from the realm.
            let allUserGoals = realm.objects(UserGoalEntity.self)
            realm.delete(allUserGoals)
        }
    }
    
    /// Single UserGoal 삭제하기
    /// - Parameter forPrimaryKey: 삭제할 UserGoal의 PrimaryKey
    func deleteAUserGoal(at forPrimaryKey: ObjectId) {
        
        if let userGoalToDelete = self.fetchAUserGoal(at: forPrimaryKey) {
            print(#fileID, #function, #line, "- fetchAUserGoal: \(userGoalToDelete)")
            let realm = try! Realm()
            // Delete the instance from the realm.
            try! realm.write {
                realm.delete(userGoalToDelete)
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
    
    
    /// Single UserGoal 수정하기
    /// - Parameters:
    ///   - forPrimaryKey: 수정할 UserGoal의 PrimaryKey
    ///   - params: 수정할 내용
//    func editBudget(at forPrimaryKey: ObjectId, params: [String: Any]) {
    func editUserGoal(at forPrimaryKey: ObjectId, updatedGoalTitle: String?, updatedGoalPrice: Int?, updatedDailyExpenseLimit: Int? = 0) {
        
        let realm = try! Realm()
        // Get a dog to update
        if let userGoalToEdit = self.fetchAUserGoal(at: forPrimaryKey) {
            // Open a thread-safe transaction
            try! realm.write {
                
//                if case let updatedTitle? = params["title"] as? String {
//                    budgetToEdit.title = updatedTitle
//                }
                if let updatedGoalTitle = updatedGoalTitle {
                    userGoalToEdit.goalTitle = updatedGoalTitle
                }
                if let updatedGoalPrice = updatedGoalPrice {
                    userGoalToEdit.goalPrice = updatedGoalPrice
                }
                
                if let updatedDailyExpenseLimit = updatedDailyExpenseLimit {
                    userGoalToEdit.dailyExpenseLimit = updatedDailyExpenseLimit
                }
                
            }
            
        }
    }
    
    // ======
    
    
    /// UserGoalEntity를 UserGoal으로 바꿔주기
    /// - Returns: Array of UserGoal
    func fetchUserGoalsFromUserGoalEntity() -> [UserGoal] {
        
        return fetchUserGoalEntities().map({ UserGoal(entity: $0) })
        
    }
    
    
    
}
