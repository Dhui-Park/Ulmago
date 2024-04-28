//
//  UIButton+Ext.swift
//  Ulmago
//
//  Created by dhui on 3/19/24.
//

import Foundation
import UIKit

extension UIButton {
    func submitButtonSetting() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.titleLabel?.font = .boldSystemFont(ofSize: 18)
    }
}
