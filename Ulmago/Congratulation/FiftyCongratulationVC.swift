//
//  FiftyCongratulationVC.swift
//  Ulmago
//
//  Created by dhui on 4/17/24.
//

import Foundation
import UIKit

//let testVC = FiftyCongratulationVC.create()


class FiftyCongratulationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
    }
    
    class func create() -> Self {
        let storyboard = UIStoryboard(name: FiftyCongratulationVC.reuseIdentifier, bundle: .main)
        
//        storyboard.instantiateInitialViewController()
        
        return storyboard.instantiateViewController(withIdentifier: FiftyCongratulationVC.reuseIdentifier) as! Self
    }
    
//    protocol StoryBoarded {
//        static func instantiate(_ storyboardName: String?) -> Self
//    }
//    
//    extension StoryBoarded {
//        
//        static func instantiate(_ storyboardName: String? = nil) -> Self {
//            
//            let name = storyboardName ?? String(describing: self)
//            
//            let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
//            
//            return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
//        }
//    }
}
