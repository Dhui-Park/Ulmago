//
//  TestVC.swift
//  Ulmago
//
//  Created by dhui on 4/17/24.
//

import Foundation
import UIKit

class TestVC: UIViewController {
    
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var textBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(#fileID, #function, #line, "- ")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(#fileID, #function, #line, "- ")
    }
    
    class func createInstance() -> TestVC {
        return TestVC(nibName: "TestVC", bundle: nil)
    }
}
