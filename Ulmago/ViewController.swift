//
//  ViewController.swift
//  Ulmago
//
//  Created by dhui on 3/11/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.goalTextField.placeholder = "맥북 프로 / 괌 여행 / 자전거"
    }

    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
}

