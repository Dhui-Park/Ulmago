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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func editBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        // 목표: 테이블뷰쎌의 해당 버튼을 클릭하면 Budget의 title과 price를 변경할 수 있게 한다.
        // 1. 클릭한 쎌의 인덱스패스로 어떤 쎌인지 받아온다.
        guard let indexPath = indexPath,
              let title = cellData?.title,
              let price = cellData?.price else {
            print(#fileID, #function, #line, "- cellData가 아니야")
            return
        }
        // 2. 해당 쎌의 title과 price를 변경할 수 있게 수정 얼럿 화면을 띄운다.
        SwiftAlertView.show(title: "수정하시겠습니까?", buttonTitles: "취소", "수정") { alertView in
            alertView.addTextField { textField in
                // 2-1. 수정 얼럿 화면에는 원래 title과 price가 각 텍스트필드의 text로 자리잡고 있다.
                textField.text = title
                textField.tintColor = .primaryColor ?? .black
            }
            alertView.addTextField { textField in
                textField.text = "\(price)"
                textField.keyboardType = .numberPad
                textField.tintColor = .primaryColor ?? .black
                textField.delegate = self
            }
            alertView.isEnabledValidationLabel = true
            alertView.isDismissOnActionButtonClicked = false
            alertView.backgroundColor = .backgroundColor
            alertView.buttonTitleColor = .primaryColor ?? .blue
        }
        .onActionButtonClicked { [weak self] alertView, buttonIndex in
            
            guard let self = self else { return }
            
            guard let breakdown = alertView.textField(at: 0)?.text,
                  let amountOfMoney = alertView.textField(at: 1)?.text else { return }
    
            switch buttonIndex {
            case 0:
                print(#fileID, #function, #line, "- cancel btn clicked")
            case 1:
                print(#fileID, #function, #line, "- ok btn clicked")
                if breakdown.isEmpty {
                    alertView.validationLabel.text = "내역이 비어있습니다."
                } else if amountOfMoney.isEmpty {
                    alertView.validationLabel.text = "금액을 입력해주세요"
                } else {
                    // 3. 사용자가 수정하면 수정한 내용을 데이터리스트에 수정한다.
                    // 4. 수정한 내용을 테이블뷰에 반영한다.
                    var editedBudgetList = vm.budgetList.value
                    if let editingItemObjectId = editedBudgetList[indexPath.row].id {
                        let objectId = try! ObjectId(string: editingItemObjectId)
//                        BudgetRepository.shared.editBudget(at: objectId, params: ["title" : breakdown,
//                                                                                  "price" : Int(amountOfMoney) ?? 0])
                        BudgetRepository.shared.editBudget(at: objectId, updatedTitle: breakdown, updatedPrice: Int(amountOfMoney) ?? 0)
                    }
                    vm.budgetList.accept(BudgetRepository.shared.fetchBudgetsFromBudgetEntity())
                    vm.updateDailySpend()
                    alertView.dismiss()
                }
                
            default:
                print(#fileID, #function, #line, "- ")
            }
        }
        .onTextChanged { _, text, textFieldIndex in
            if textFieldIndex == 0 {
                print("Username text changed: ", text ?? "")
            }
        }
        
        
        
    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- sender: \(sender)")
        // 목표: 테이블뷰쎌의 해당 쎌의 삭제 버튼을 클릭하면 해당 쎌을 테이블뷰에서 삭제한다.
        // 0. 삭제하시겠습니까? 경고 얼럿 화면을 띄운다.
        SwiftAlertView.show(title: "삭제하시겠습니까?", buttonTitles: "취소", "삭제") { alertView in
            alertView.backgroundColor = .backgroundColor
            alertView.buttonTitleColor = .primaryColor ?? .black
        }
        .onButtonClicked({ [weak self] alertView, buttonIndex in
            guard let self = self else { return }
            switch buttonIndex {
            case 0:
                print("buttonIndex: \(buttonIndex)")
            case 1:
                print("buttonIndex: \(buttonIndex)")
                // 1. 클릭한 쎌의 인덱스패스로 어떤 쎌인지 받아온다.
                guard let indexPath = indexPath else { return }
                print("indexPath from tableView: \(indexPath)")
                // 2. 해당 쎌을 데이터리스트에서 삭제한다.
                // 3. 삭제한 내용을 테이블뷰에 반영한다.
                self.vm.deleteTableViewItem(indexPath: indexPath)
                // 오늘 하루 소비 금액 업데이트
                self.vm.updateDailySpend()
                
            default:
                print("default btn clicked")
            }
        })

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
