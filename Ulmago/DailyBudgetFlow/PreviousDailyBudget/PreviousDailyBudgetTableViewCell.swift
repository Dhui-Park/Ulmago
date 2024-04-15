//
//  PreviousDailyBudgetTableViewCell.swift
//  Ulmago
//
//  Created by dhui on 3/27/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa
import SwiftAlertView

class PreviousDailyBudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    var cellData: Budget? = nil
    
//    var indexPath: IndexPath? = nil
    
    var editBtnClicked: ((Budget) -> Void)? = nil
    
    var deleteBtnClicked: ((Budget) -> Void)? = nil
    
//    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
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
    
    // tableViewCell에서는 ViewModel 쓰지 않는게 좋다.
    @IBAction func editBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        guard let cellData = cellData else { return }
        self.editBtnClicked?(cellData)
    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        // 목표: 뷰컨에 삭제 이벤트를 전달해준다.
        guard let cellData = cellData else { return }
        self.deleteBtnClicked?(cellData)
    }
    
    
}

extension PreviousDailyBudgetTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
