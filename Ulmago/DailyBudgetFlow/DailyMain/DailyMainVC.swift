//
//  DailyMainVC.swift
//  Ulmago
//
//  Created by dhui on 3/16/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa
import ALProgressView
import SwiftAlertView


class DailyMainVC: UIViewController {
    
    @IBOutlet weak var goalTextLabel: UILabel!
    @IBOutlet weak var progressTextLabel: UILabel!
    
    @IBOutlet weak var todaysExpenseLabel: UILabel!
    
    @IBOutlet weak var progressRing: ALProgressRing!
    @IBOutlet weak var dailyProgressBar: ALProgressBar!
    
    @IBOutlet weak var dailyBudgetSubmitBtn: UIButton!
    @IBOutlet weak var previousBudgetSubmitBtn: UIButton!
    
    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // [{(하루 소비한도) - (1일차 소비한 금액)} + {(하루 소비한도) - (2일차 소비한 금액)} + {(하루 소비한도) - (3일차 소비한 금액)} + ... + {(하루 소비한도) - (가장 최근 날짜 소비한 금액)}] / 총 비용

    
    
    fileprivate func receiveUserGoal(_ goalText: String, _ wholeCostText: String, _ dailyExpense: String) {
        self.vm.goalText.accept(goalText)
        self.vm.wholeCostText.accept(wholeCostText)
        self.vm.dailyExpenseText.accept(dailyExpense)
    }
    
    init?(coder: NSCoder, goalText: String, wholeCostText: String, dailyExpense: String) {
        super.init(coder: coder)
        receiveUserGoal(goalText, wholeCostText, dailyExpense)
        print(#fileID, #function, #line, "- goalText from ViewController: \(goalText), wholeCostText from WholeCostSettingVC: \(wholeCostText) ")

    }
    
    required init?(coder: NSCoder) {
        print(#fileID, #function, #line, "- ")
        super.init(coder: coder)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        vm.refreshProgressPercent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        
        let newBackButton = UIBarButtonItem(title: "다시 설정하기", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
       
        
        vm.updateDailySpend()
        
        //MARK: - Rx
        vm.progressPercent
            .debug("😁")
            .observe(on: MainScheduler.instance)
            .map { self.setProgressRing(progressRing: self.progressRing,value: $0) }
            .bind(to: self.rx.progressRing)
            .disposed(by: disposeBag)
        
        
        vm.remainedGraphPercent
            .observe(on: MainScheduler.instance)
            .map { self.setDailyProgressBar(progressBar: self.dailyProgressBar, value: $0) }
            .bind(to: self.rx.dailyProgressBar)
            .disposed(by: disposeBag)
        
        print(#fileID, #function, #line, "- After Notification")
        
        vm.goalTextLabel
            .compactMap { $0 }
            .bind(to: self.goalTextLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        vm.progressPercentText
            .compactMap { $0 }
            .bind(to: self.progressTextLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        vm.remainedDailyExpense
            .map { $0 > 0 ? "오늘의 남은 소비 한도: \($0.formattedWithSeparator)원" : "오늘은 \(abs($0).formattedWithSeparator)원 더 썼어요ㅠㅠ" }
            .bind(to: self.todaysExpenseLabel.rx.text)
            .disposed(by: disposeBag)
        
        self.dailyBudgetSubmitBtn.submitButtonSetting()
        self.previousBudgetSubmitBtn.submitButtonSetting()
        self.previousBudgetSubmitBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        
    }
    
    
    //MARK: - ALProgressView
    func setProgressRing(progressRing: ALProgressRing, value: Float) -> ALProgressRing {
        
//        // Setting progress
        progressRing.setProgress(value, animated: true)
        progressRing.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        progressRing.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
        
        return progressRing
    }
    
    func setDailyProgressBar(progressBar: ALProgressBar, value: Float) -> ALProgressBar {
        progressBar.setProgress(value, animated: true)
        progressBar.startColor = UIColor(named: "redBean")?.withAlphaComponent(0.4) ?? UIColor.systemCyan
        progressBar.endColor = UIColor(named: "redBean") ?? UIColor.systemCyan
        
        return progressBar
    }
    
    @IBAction func dailyBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
       
        let storyboard = UIStoryboard(name: DailyBudgetVC.reuseIdentifier, bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: DailyBudgetVC.reuseIdentifier, creator: { coder in
            return DailyBudgetVC(coder: coder)
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func previousBudgetSubmitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        guard let vc: PreviousDailyBudgetVC = PreviousDailyBudgetVC.createInstance() else { return }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension DailyMainVC {
    
    @objc func backAction(_ sender: UIBarButtonItem) {

        // 목표: 다시 설정하기 버튼을 누르면 UserGoal을 다시 설정하시겠습니까? 물어보는 얼럿창을 띄우고 확인을 누르면 이전 화면으로 돌아가기.
        
        // 1. "목표나 금액을 다시 설정할까요?" 얼럿창 띄우기
        SwiftAlertView.show(title: "목표나 금액을 다시 설정할까요?", buttonTitles: "다시 설정하기", "취소") { alertView in
            alertView.backgroundColor = .backgroundColor
            alertView.buttonTitleColor = .primaryColor ?? .black
        }
        .onButtonClicked({ [weak self] alertView, buttonIndex in
            guard let self = self else { return }
            switch buttonIndex {
            case 0:
                // 1-1. 다시 설정하기 버튼 클릭 -> 이전 화면으로 돌아가기
                print("buttonIndex: \(buttonIndex)")
            
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let vc = storyboard.instantiateViewController(identifier: ViewController.reuseIdentifier, creator: { coder in
                    return ViewController(coder: coder)
                })
                
                self.navigationController?.pushViewController(vc, animated: true)
                self.navigationController?.navigationBar.backItem?.hidesBackButton = true
                
            case 1:
                // 1-2. 취소 -> 얼럿창 dismiss
                print("buttonIndex: \(buttonIndex)")
                alertView.dismiss()
            default:
                print("default btn clicked")
            }
        })
    }
    
}

