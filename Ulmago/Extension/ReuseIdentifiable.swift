//
//  ReuseIdentifiable.swift
//  Ulmago
//
//  Created by dhui on 3/14/24.
//

import Foundation
import UIKit

protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UIViewController: ReuseIdentifiable { }
