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
    
    var dummies: [String] = ["dummyData1","dummyData2","dummyData3","dummyData4","dummyData5","dummyData6"]
    
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
        
        NSLayoutConstraint.activate([
            self.dailyTableView.topAnchor.constraint(equalTo: self.myCalendarView.bottomAnchor, constant: 10),
            self.dailyTableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.dailyTableView.leadingAnchor.constraint(equalTo: self.myCalendarView.leadingAnchor),
            self.dailyTableView.trailingAnchor.constraint(equalTo: self.myCalendarView.trailingAnchor),
            self.dailyTableView.bottomAnchor.constraint(equalTo: self.addBtn.topAnchor, constant: -10)
        ])
        
        self.dailyTableView.backgroundColor = UIColor.systemCyan
        
        self.dailyTableView.isHidden = true
        let cellNib = UINib(nibName: PreviousDailyBudgetTableViewCell.reuseIdentifier, bundle: .main)
        self.dailyTableView.register(cellNib, forCellReuseIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier)
        self.dailyTableView.dataSource = self
        
        self.addBtn.titleLabel?.text = "내역 보기"
        
        // 테이블뷰 삭제, 수정 기능
        vm.budgetList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
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
        if(self.myCalendarView.scope == .month){// 월간인경우
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: false)
            //주간으로 변경
            
        }else{// 주간인경우
            self.changeCalendarKind(myCalendar: self.myCalendarView, month: true)
            //월간으로 변경
            
        }
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    func changeCalendarKind(myCalendar : FSCalendar, month : Bool){ // 주간 or 월간
        print(#fileID, #function, #line, "- dailyTableView.isHidden: \(self.dailyTableView.isHidden)")
        myCalendar.setScope(month ? .month : .week, animated: true) // 애니메이션 효과 적용
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
    
}

extension PreviousDailyBudgetVC: FSCalendarDataSource {
    
}

extension PreviousDailyBudgetVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(#fileID, #function, #line, "- didSelect: \(date), monthPosition: \(monthPosition)")
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height // 높이 설정 변경
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
            calendar.reloadData()
        }
    }
}

extension PreviousDailyBudgetVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.budgetList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PreviousDailyBudgetTableViewCell.reuseIdentifier, for: indexPath) as? PreviousDailyBudgetTableViewCell else { return UITableViewCell() }
        
        let cellData = self.vm.budgetList.value[indexPath.row]
        cell.cellData = cellData
        cell.indexPath = indexPath
        
        guard let title = cellData.title,
              let price = cellData.price else { return cell }
        
        cell.titleLabel.text = title
        cell.priceLabel.text = "\(price)원"
        
        
        return cell
    }
    
    
}
