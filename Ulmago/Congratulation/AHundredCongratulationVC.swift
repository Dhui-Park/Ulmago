//
//  AHundredCongratulationVC.swift
//  Ulmago
//
//  Created by dhui on 4/28/24.
//

import Foundation
import UIKit
import SPConfetti

class AHundredCongratulationVC: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var newGoalSettingBtn: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        SPConfetti.startAnimating(.centerExplosionToDown(yAcceleration: 3), particles: [.triangle, .arc, .polygon])
        
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        SPConfetti.stopAnimating()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func newGoalSettingBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        SPConfetti.stopAnimating()
        
    }
    
    
}
