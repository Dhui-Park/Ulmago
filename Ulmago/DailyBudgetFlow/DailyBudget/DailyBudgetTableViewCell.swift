//
//  DailyBudgetTableViewCell.swift
//  Ulmago
//
//  Created by dhui on 3/23/24.
//

import Foundation
import UIKit
import Realm
import RealmSwift
import SwiftAlertView

class DailyBudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
    var cellData: Budget? = nil
    
    var indexPath: IndexPath? = nil
    
    var editBtnClicked: ((Budget) -> Void)? = nil
    
    var deleteBtnClicked: ((Budget) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    func configureUI(cellData: Budget, deletingBtnClicked: ((Budget) -> Void)? = nil, editBtnClicked: ((Budget) -> Void)? = nil){
        self.cellData = cellData
        self.titleLabel.text = cellData.title
        self.priceLabel.text = "\(cellData.price)원"
        self.deleteBtnClicked = deletingBtnClicked
        self.editBtnClicked = editBtnClicked
    }
    
    #warning("TODO: - 수정 기능 구현")
    @IBAction func editBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        guard let cellData = cellData else { return }
        self.editBtnClicked?(cellData)
    }
    
    #warning("TODO: - 삭제 기능 구현")
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- sender: \(sender)")
        guard let cellData = cellData else { return }
        self.deleteBtnClicked?(cellData)
        
    }
}

extension DailyBudgetTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
