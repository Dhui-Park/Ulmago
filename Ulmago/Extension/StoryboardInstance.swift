//
//  StoryboardInstance.swift
//  Ulmago
//
//  Created by dhui on 3/14/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    static func getInstance() -> Self? {
        
        let storyboard = UIStoryboard(name: Self.reuseIdentifier, bundle: .main)
        
        return storyboard.instantiateViewController(withIdentifier: Self.reuseIdentifier) as? Self
        

    }
    
}
