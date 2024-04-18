//
//  PreviousDailyBudgetVC.swift
//  Ulmago
//
//  Created by dhui on 3/21/24.
//

import Foundation
import UIKit
import FSCalendar
import RxSwift
import RxRelay
import RxCocoa
import SwiftAlertView

class PreviousDailyBudgetVC: UIViewController {
    
    @IBOutlet weak var myCalendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var dailyTableView: UITableView = UITableView()
    
    @IBOutlet weak var lookBtn: UIButton!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var dummies: [Budget] = []
    
    var selectedDate: String = Date.now.toDateString()
    
    // 데이터 기반으로 생각하기!!
//    var budgetListIsOpen: Bool = false {
//        didSet {
//            if budgetListIsOpen {
//                self.lookBtn.setTitle("내역 닫기", for: .normal)
//                self.dailyTableView.isHidden = true
//            } else {
//                self.lookBtn.setTitle("내역 보기", for: .normal)
//                self.dailyTableView.isHidden = false
//            }
//        }
//    }
    
    // 딕셔너리로 가공
    var dataDictionary: [String: [Budget]] = [:]
    
    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
    var disposeBag: DisposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.myCalendarView.appearance.headerDateFormat = "yyyy년 MM월" // 날짜 디스플레이 양식
        
        self.dailyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        self.view.addSubview(self.dailyTableView)
        self.dailyTableView.layer.borderColor = UIColor.primaryColor?.withAlphaComponent(0.3).cgColor
        self.dailyTableView.layer.borderWidth = 1
        self.dailyTableView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            self.dailyTableView.topAnchor.constraint(equalTo: self.myCalendarView.bottomAnchor, constant: 10),
            self.dailyTableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.dailyTableView.leadingAnchor.constraint(equalTo: self.myCalendarView.leadingAnchor),
            self.dailyTableView.trailingAnchor.constraint(equalTo: self.myCalendarView.trailingAnchor),
            self.dailyTableView.bottomAnchor.constraint(equalTo: self.lookBtn.topAnchor, constant: -10)
        ])
        
        self.dailyTableView.backgroundColor = UIColor.backgroundColor?.withAlphaComponent(0.9)
        
        self.dailyTableView.isHidden = true
        let cellNib = UINib(nibName: PreviousDailyBudgetTableViewCell.reuseIdentifier, bundle: .main)
        self.dailyTableView.register(cellNib, forCellReuseIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier)
        self.dailyTableView.dataSource = self
        
        
        self.lookBtn.titleLabel?.textColor = .white
        
        // 테이블뷰 삭제, 수정 기능
        vm.budgetList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (budgetList: [Budget]) in
                self.dummies = budgetList.filter({ $0.date.toDateString() == Date.now.toDateString() })
                // 목표: budgetList의 date를 키값으로 하는 딕셔너리를 만들어서 테이블뷰에 보여준다.
                // 1. budgetList의 date를 받아온다.
                // 2. dateDictionary의 키값으로 budgetList의 date를 넣고 value를 Budget으로 만든다.
//                Dictionary(grouping: statEvents, by: { $0.name })
                self.dataDictionary = Dictionary(grouping: budgetList, by: { $0.date.toDateString() })
                // 3. 테이블뷰에 보여줄 데이터를 dateDictionary로 교체한다.
                self.dailyTableView.reloadData()
                self.myCalendarView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 목표: 추가하기 버튼을 누르면 당일날의 테이블 뷰에 Budget이 추가된다.
        // 1. 추가하기 버튼을 tap 한것을 가져온다.
        // 2. 당일날의 테이블뷰에 Budget이 하나 추가된다.
        
        // 목표: budgetListIsOpen으로 버튼 타이틀 바꾸기
        // 1. viewModel의 budgetListIsOpen을 구독한다.
        self.vm.budgetListIsOpen
            .observe(on: MainScheduler.instance)
            .bind(to: self.rx.budgetListIsOpen)
            .disposed(by: disposeBag)
    
    }
    
    class func createInstance() -> PreviousDailyBudgetVC? {
        let storyboard = UIStoryboard(name: PreviousDailyBudgetVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: PreviousDailyBudgetVC.reuseIdentifier, creator: { coder in
            return PreviousDailyBudgetVC(coder: coder)
        })/* as? PreviousDailyBudgetVC*/
        return vc
    }
    
    
    
    @IBAction func lookBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        // UI로 건드리지 말고 데이터에 기반해서 생각하자!
        self.vm.toggleBudgetListIsOpen()
        
        if self.myCalendarView.scope == .month {
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: false)
        } else {
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: true)
        }
    }
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        // 목표: 선택한 날짜의 테이블뷰에 새로운 Budget 아이템을 추가한다.
        // 1. alert창을 띄워 추가할 내역과 금액을 받는다.
        UGAlertView.show(title: "추가하시겠습니까?", message: "무엇에 얼마를 썼나요?", buttonTitles: ["취소", "추가"], boldButtonIndex: 1) { alertView in
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
                        #warning("TODO: - 테이블뷰가 실시간 reload가 되지 않는 버그")
                        // 2. 선택한 날의 Date와 같은 날짜로 BudgetEntity를 만든다.
                        self.vm.addToTableView(newTitle: breakdown, newPrice: Int(amountOfMoney) ?? 0, date: self.selectedDate.toDate())
                        print(#fileID, #function, #line, "- budgetList: \(self.vm.budgetList)")
                        self.vm.updateDailySpend()
//                        self.dummies = self.getBugets(for: self.selectedDate.toDate())
//                        self.dailyTableView.reloadData()
//                        self.myCalendarView.reloadData()
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
        
        // 3. 테이블뷰에 보여준다.
    }
    
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeCalendarKind(myCalendar: FSCalendar, month: Bool){
        print(#fileID, #function, #line, "- dailyTableView.isHidden: \(self.dailyTableView.isHidden)")
        
        // 애니메이션 효과 적용
        myCalendar.setScope(month ? .month : .week, animated: true)
        
        if month {
            // 그냥 toggle()을 하면 테이블뷰가 사라질 때 너무 확 사라져서 0.2초의 딜레이를 주어 애니메이션 효과를 준 것처럼 보이게 했다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.dailyTableView.isHidden.toggle()
            })
        } else {
            self.dailyTableView.isHidden.toggle()
        }
    }
    
    func getBugets(for date: Date) -> [Budget] {
        // 목표: 선택한 날짜의 date로 테이블뷰의 아이템들을 바꿔준다.
        // 1. 선택한 날짜의 date.toDateString()으로 date를 파싱한다.
        let selectedDate = date.toDateString()
        
        // 2. 파싱한 date와 딕셔너리의 키값이 맞는 것을 가져온다.
        if let selectedDictionaryValue: [Budget] = self.dataDictionary[selectedDate] {
            // 3. 딕셔너리의 아이템을 테이블뷰에 보여준다.
            return selectedDictionaryValue
        } else {
            return []
        }
    }
    
}

extension PreviousDailyBudgetVC: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        // 활용할 수 있는 데이터: date
        // 메모가 있을 때 메모의 갯수를 subtitle에 표시한다.
        // 1. 해당 날짜의 budget 개수를 가져온다.
        print("\(self.vm.budgetList.value)")
        var tempBudgetList = self.vm.budgetList.value
        var budgetsForThatDate = tempBudgetList.filter({ $0.date.toDateString() == date.toDateString() })
        // 2. 개수를 문자열로 반환해준다.
        var count = budgetsForThatDate.count
        if count == 0 {
            return nil
        }
        return "\(count)"
    }
    
}

extension PreviousDailyBudgetVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(#fileID, #function, #line, "- didSelect: \(date.toDateString()), monthPosition: \(monthPosition)")
       
        self.selectedDate = date.toDateString()
        
        // index - at
        //
        self.dummies = self.getBugets(for: date)
        
        DispatchQueue.main.async {
            self.dailyTableView.reloadData()
        }
        
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        // 높이 설정 변경
        calendarHeight.constant = bounds.height
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
            calendar.reloadData()
        }
    }
}

extension PreviousDailyBudgetVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummies.count
    }
    
    fileprivate func showEditingAlertView(_ budget: Budget) {
        // 목표: 테이블뷰쎌의 해당 버튼을 클릭하면 Budget의 title과 price를 변경할 수 있게 한다.
        
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
                    vm.editTableViewItem(at: objectId, newTitle: breakdown, newPrice: Int(amountOfMoney) ?? 0)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier, for: indexPath) as? PreviousDailyBudgetTableViewCell else { return UITableViewCell() }
        
        cell.configureUI(cellData: self.dummies[indexPath.row],
                         deletingBtnClicked: self.showDeletingAlertView(_:), editBtnClicked: self.showEditingAlertView(_:))
        

        return cell
    }
    
    
}

//MARK: - UITextFieldDelegate
extension PreviousDailyBudgetVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        
        return false
    }
}

private extension Reactive where Base: PreviousDailyBudgetVC {
    var budgetListIsOpen: Binder<Bool> {
        return Binder(base) { viewController, isOpen in
            if isOpen {
                viewController.lookBtn.setTitle("내역 닫기", for: .normal)
                viewController.dailyTableView.isHidden = true
            } else {
                viewController.lookBtn.setTitle("내역 보기", for: .normal)
                viewController.dailyTableView.isHidden = false
            }
        }
    }
}
