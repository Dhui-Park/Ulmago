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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        self.dailyBudgetTableView.reloadData()
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
            .map { $0 >= 0 ? "오늘의 남은 소비 한도: \($0.formattedWithSeparator)원" : "오늘은 \(abs($0).formattedWithSeparator)원 더 썼어요ㅠㅠ" }
            .bind(to: self.todaysExpenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 목표: 완료 버튼을 누르면 [목표금액 / 모든 날들의 남은 소비 한도]를 적용시키기
        // 1. 완료버튼 누르는 이벤트를 가져온다.
        // 2. 각 날짜의 남은 소비 한도를 모두 더해준다.
        // 3. 목표 금액을 모든 날들의 남은 소비한도로 나눠준다.
        // 4. 그것을 vm의 progressPercent에 반영한다.
        self.submitBtn.rx.tap
            .subscribe(onNext: {
                
            })
        
        // 테이블뷰 하단에 오늘 소비한 금액 표시
        vm.dailySpend
            .map { "\($0)원" }
            .bind(to: self.dailySpendLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 테이블뷰 삭제, 수정 기능
        vm.budgetList
            .debug("🚩")
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
    
    // 추가 버튼 클릭시
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        SwiftAlertView.show(title: "추가하시겠습니까?", message: "무엇에 얼마를 썼나요?", buttonTitles: "취소", "추가") { alertView in
//            alertView.cancelButtonIndex = 1
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
                        self.vm.addToBudgetRepository(newTitle: breakdown, newPrice: Int(amountOfMoney) ?? 0)
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
    
    // 완료 버튼 클릭시
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        #warning("TODO: - budgetList에 date 상관없이 isEmpty로 해서 버그가 일어남 - 해결")
        // 1. tableView에 아무 내역도 없으면 경고 얼럿 띄우기
        if !vm.budgetList.value.contains(where: { $0.date.toDateString() == Date.now.toDateString() }) {
            
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

//MARK: - UITableViewDataSource
extension DailyBudgetVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tempBudgetList.count
    }
    
    fileprivate func showEditingAlertView(_ budget: Budget) {
        // 목표: 테이블뷰쎌의 해당 버튼을 클릭하면 Budget의 title과 price를 변경할 수 있게 한다.
        // 1. 클릭한 쎌의 인덱스패스로 어떤 쎌인지 받아온다.
        
        // 2. 해당 쎌의 title과 price를 변경할 수 있게 수정 얼럿 화면을 띄운다.
        SwiftAlertView.show(title: "수정하시겠습니까?", buttonTitles: "취소", "수정") { alertView in
            alertView.addTextField { textField in
                // 2-1. 수정 얼럿 화면에는 원래 title과 price가 각 텍스트필드의 text로 자리잡고 있다.
                textField.text = budget.title
                textField.tintColor = .primaryColor ?? .black
            }
            alertView.addTextField { textField in
                textField.text = "\(budget.price)"
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
                    guard let objectId = budget.objectId else { return }
                    vm.editBudgetRepository(at: objectId, newTitle: breakdown, newPrice: Int(amountOfMoney) ?? 0)
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
    
    #warning("TODO: - 왜 tableView reload가 되지 않지?")
    fileprivate func showDeletingAlertView(_ budget: Budget) {
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
                // 2. 해당 쎌을 데이터리스트에서 삭제한다.
                // 3. 삭제한 내용을 테이블뷰에 반영한다.
                
                self.vm.deleteTableViewItem(budget)
                // 뷰컨에 삭제 이벤트만 전달 후 뷰컨에서 삭제
                
                // 오늘 하루 소비 금액 업데이트
                self.vm.updateDailySpend()
            default:
                print("default btn clicked")
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyBudgetTableViewCell") as? DailyBudgetTableViewCell else { return UITableViewCell() }
        
        
        cell.configureUI(cellData: self.tempBudgetList[indexPath.row],
                         deletingBtnClicked: self.showDeletingAlertView(_:), editBtnClicked: self.showEditingAlertView(_:))
        
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension DailyBudgetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
    }
}

//MARK: - UITextFieldDelegate
extension DailyBudgetVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}
