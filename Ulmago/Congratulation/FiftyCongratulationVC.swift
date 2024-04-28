//
//  FiftyCongratulationVC.swift
//  Ulmago
//
//  Created by dhui on 4/17/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SPConfetti


//let testVC = FiftyCongratulationVC.create()


class FiftyCongratulationVC: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var vm: CongratulationVM = CongratulationVM.shared
    
    var disposeBag: DisposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        SPConfetti.startAnimating(.centerExplosionToDown(yAcceleration: 3), particles: [.triangle, .arc, .polygon])
        
    }
    
    class func create() -> Self {
        let storyboard = UIStoryboard(name: FiftyCongratulationVC.reuseIdentifier, bundle: .main)
        
//        storyboard.instantiateInitialViewController()
        
        return storyboard.instantiateViewController(withIdentifier: FiftyCongratulationVC.reuseIdentifier) as! Self
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        SPConfetti.stopAnimating()
        self.navigationController?.popViewController(animated: true)
    }
    
}
