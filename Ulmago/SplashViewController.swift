//
//  SplashViewController.swift
//  Ulmago
//
//  Created by dhui on 3/15/24.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var myLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.logoTransition()
        
    }
    
    fileprivate func logoTransition() {
        
        UIView.transition(with: self.myLogo, duration: 1.5, options: .transitionCrossDissolve, animations: {
            self.myLogo.isHidden = false
        }, completion: { finished in
            print(#fileID, #function, #line, "- 로고 애니메이션 끝났음")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: ViewController.reuseIdentifier) as? ViewController else { return }
            self.navigationController?.pushViewController(vc, animated: true)
            
        })
    }
}
