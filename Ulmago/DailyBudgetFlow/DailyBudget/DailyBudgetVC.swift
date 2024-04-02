//
//  DailyBudgetVC.swift
//  Ulmago
//
//  Created by dhui on 3/17/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa
import SwiftAlertView

class DailyBudgetVC: UIViewController {
    
    @IBOutlet weak var dailyExpenseLabel: UILabel!
    
    @IBOutlet weak var wholeCostLabel: UILabel!
    
    @IBOutlet weak var todaysExpenseLabel: UILabel!
    
    @IBOutlet weak var dailyBudgetTableView: UITableView!
    
    @IBOutlet weak var dailySpendLabel: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var tempBudgetList: [Budget] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        
        //MARK: - Rx
        // 화면 상단에 사용자가 이전에 설정한 목표 금액 표시
        vm.wholeCostText
            .map { "목표가 얼마고? : " + $0 + "만원" }
            .bind(to: self.wholeCostLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 화면 상단에 사용자가 이전에 설정한 오늘의 소비한도금액 표시
        #warning("TODO: - dailyExpense - dailySpend 로 연동하기")
        vm.remainedDailyExpense
            .map { $0 > 0 ? "오늘의 남은 소비 한도: \($0.formattedWithSeparator)원" : "오늘은 \(abs($0).formattedWithSeparator)원 더 썼어요ㅠㅠ" }
            .bind(to: self.todaysExpenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 테이블뷰 하단에 오늘 소비한 금액 표시
        vm.dailySpend
            .map { "\($0)원" }
            .bind(to: self.dailySpendLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 테이블뷰 삭제, 수정 기능
        vm.budgetList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (budgetList: [Budget]) in
                // 1. 날짜가 오늘인 budget을 가져온다.
                self.tempBudgetList = budgetList.filter({ $0.date.toDateString() == Date.now.toDateString() })
                print(#fileID, #function, #line, "- budgetList: \(budgetList) temp: \(self.tempBudgetList)")
                // 2. 테이블뷰 리로드
                self.dailyBudgetTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        let cellNib = UINib(nibName: "DailyBudgetTableViewCell", bundle: .main)
        
        self.dailyBudgetTableView.register(cellNib, forCellReuseIdentifier: "DailyBudgetTableViewCell")
        self.dailyBudgetTableView.dataSource = self
        self.dailyBudgetTableView.delegate = self
        
        
    }
    
    //MARK: - SwiftAlertView
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        SwiftAlertView.show(title: "추가하시겠습니까?", message: "무엇에 얼마를 썼나요?", buttonTitles: "취소", "추가") { alertView in
            alertView.addTextField { textField in
                textField.placeholder = "내역"
                textField.tintColor = .primaryColor ?? .black
            }
            alertView.addTextField { textField in
                textField.placeholder = "금액"
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
                    DispatchQueue.main.async {
                        self.vm.addToTableView(newTitle: breakdown, newPrice: Int(amountOfMoney) ?? 0)
                        print(#fileID, #function, #line, "- budgetList: \(self.vm.budgetList)")
                        self.vm.updateDailySpend()
                        self.dailyBudgetTableView.reloadData()
                    }
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
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        
        // 1. tableView에 아무 내역도 없으면 경고 얼럿 띄우기
        if vm.budgetList.value.isEmpty {
            // 경고 얼럿 화면 띄우기
            SwiftAlertView.show(title: "내역 입력 없이 돌아가시겠습니까?", message: "오늘의 소비를 입력하지 않았습니다.", buttonTitles: "메인으로", "입력하기") { alertView in
                alertView.backgroundColor = .backgroundColor
                alertView.cancelButtonIndex = 1
                alertView.buttonTitleColor = .primaryColor ?? .black
                alertView.transitionType = .fade
            }
            .onButtonClicked({ alertView, buttonIndex in
                switch buttonIndex {
                case 0:
                    print(#fileID, #function, #line, "- cancel btn clicked")
                    self.navigationController?.popViewController(animated: true)
                case 1:
                    print(#fileID, #function, #line, "- ok btn clicked")
                    alertView.dismiss()
                default:
                    print(#fileID, #function, #line, "- ")
                }
            })
            
        } else {
            // 2. DailyMain 화면으로 돌아가기
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}

extension DailyBudgetVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tempBudgetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyBudgetTableViewCell") as? DailyBudgetTableViewCell else { return UITableViewCell() }
        
        
        let cellData = self.tempBudgetList[indexPath.row]
        cell.cellData = cellData
        cell.indexPath = indexPath
        
        guard let title = cellData.title,
              let price = cellData.price else { return cell }
        
        cell.titleLabel.text = title
        cell.priceLabel.text = "\(price)원"
        
        return cell
    }
    
    
}

extension DailyBudgetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

extension DailyBudgetVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
