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


class DailyMainVC: UIViewController {
    
    @IBOutlet weak var goalTextLabel: UILabel!
    @IBOutlet weak var progressTextLabel: UILabel!
    
    @IBOutlet weak var progressRing: ALProgressRing!
    @IBOutlet weak var dailyProgressBar: ALProgressBar!
    
    @IBOutlet weak var dailyBudgetSubmitBtn: UIButton!
    @IBOutlet weak var previousBudgetSubmitBtn: UIButton!
    
    var vm: DailyBudgetVM = DailyBudgetVM.shared
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // [{(하루 소비한도) - (1일차 소비한 금액)} + {(하루 소비한도) - (2일차 소비한 금액)} + {(하루 소비한도) - (3일차 소비한 금액)} + ... + {(하루 소비한도) - (가장 최근 날짜 소비한 금액)}] / 총 비용

    
    
    init?(coder: NSCoder, goalText: String, wholeCostText: String, dailyExpense: String) {
        super.init(coder: coder)
        self.vm.goalText.accept(goalText)
        self.vm.wholeCostText.accept(wholeCostText)
        self.vm.dailyExpenseText.accept(dailyExpense)
        print(#fileID, #function, #line, "- goalText from ViewController: \(goalText), wholeCostText from WholeCostSettingVC: \(wholeCostText) ")

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        
        let newBackButton = UIBarButtonItem(title: "다시 설정하기", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        print(#fileID, #function, #line, "- Before Notification")
        #warning("TODO: - 왜 NotificationCenter가 작동이 안될까?")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUsersCostSetting(_:)), name: .usersCostSettings, object: nil)
        
        vm.updateDailySpend()
        
        vm.progressPercent
            .map { Double($0) }
            .map { Float($0 * 0.01) }
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
        
        self.dailyBudgetSubmitBtn.submitButtonSetting()
        self.previousBudgetSubmitBtn.submitButtonSetting()
        
        
        
    }
    
    
    
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

        let alertController = UIAlertController(title: "목표나 금액을 다시 설정할까요?", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "다시 설정하기", style: .default) { (result : UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    #warning("TODO: - Notification 안됨")
    @objc fileprivate func handleUsersCostSetting(_ sender: Notification) {
        print(#fileID, #function, #line, "⭐️ - sender: \(sender)")
        
        guard let goalText = sender.userInfo?["goalText"] as? String,
              let wholeCost = sender.userInfo?["wholeCost"] as? String,
              let dailyExpense = sender.userInfo?["dailyExpense"] as? String else { return }
        
        print(#fileID, #function, #line, "⭐️ - goalText: \(goalText), wholeCost: \(wholeCost), dailyExpense: \(dailyExpense)")
        
//        self.goalText = goalText
//        self.wholeCostText = "\(wholeCost)"
//        self.dailyExpenseText = dailyExpense
        
    }
}

