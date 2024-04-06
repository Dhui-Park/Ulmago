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

class PreviousDailyBudgetVC: UIViewController {
    
    @IBOutlet weak var myCalendarView: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    var dailyTableView: UITableView = UITableView()
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var dummies: [Budget] = []
    
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
            self.dailyTableView.bottomAnchor.constraint(equalTo: self.addBtn.topAnchor, constant: -10)
        ])
        
        self.dailyTableView.backgroundColor = UIColor.backgroundColor?.withAlphaComponent(0.9)
        
        self.dailyTableView.isHidden = true
        let cellNib = UINib(nibName: PreviousDailyBudgetTableViewCell.reuseIdentifier, bundle: .main)
        self.dailyTableView.register(cellNib, forCellReuseIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier)
        self.dailyTableView.dataSource = self
        
        self.addBtn.titleLabel?.text = "내역 보기"
        
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
            })
            .disposed(by: disposeBag)
        
    
        
    }
    
    class func createInstance() -> PreviousDailyBudgetVC? {
        let storyboard = UIStoryboard(name: PreviousDailyBudgetVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: PreviousDailyBudgetVC.reuseIdentifier, creator: { coder in
            return PreviousDailyBudgetVC(coder: coder)
        })/* as? PreviousDailyBudgetVC*/
        return vc
    }
    
    
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        if self.myCalendarView.scope == .month {
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: false)
        } else {
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: true)
        }
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    func changeCalendarKind(myCalendar : FSCalendar, month : Bool){
        print(#fileID, #function, #line, "- dailyTableView.isHidden: \(self.dailyTableView.isHidden)")
        
        // 애니메이션 효과 적용
        myCalendar.setScope(month ? .month : .week, animated: true)
        
        if month {
            // 그냥 toggle()을 하면 테이블뷰가 사라질 때 너무 확 사라져서 0.2초의 딜레이를 주어 애니메이션 효과를 준 것처럼 보이게 했다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.dailyTableView.isHidden.toggle()
                self.addBtn.titleLabel?.text = "내역 닫기"
            })
        } else {
            self.dailyTableView.isHidden.toggle()
            self.addBtn.titleLabel?.text = "내역 보기"
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
    
}

extension PreviousDailyBudgetVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(#fileID, #function, #line, "- didSelect: \(date.toDateString()), monthPosition: \(monthPosition)")
       
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier, for: indexPath) as? PreviousDailyBudgetTableViewCell else { return UITableViewCell() }
        
        let cellData = self.dummies[indexPath.row]
        
        cell.cellData = cellData
        cell.indexPath = indexPath
        
//        guard let title = cellData.title,
//              let price = cellData.price else { return cell }
        
        cell.titleLabel.text = cellData.title
        cell.priceLabel.text = "\(cellData.price)원"
        
        
        return cell
    }
    
    
}
