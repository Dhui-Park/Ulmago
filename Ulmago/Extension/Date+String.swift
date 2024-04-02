//
//  Date+String.swift
//  Ulmago
//
//  Created by dhui on 4/2/24.
//

import Foundation
import UIKit

extension Date {
    
    func toDateString(dateFormat: String = "yyyy-MM-dd") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        return dateFormatter.string(from: self)
    }
    
    
}

extension String {
    
    func toDate(dateFormat: String = "yyyy-MM-dd") -> Date {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        return dateFormatter.date(from: self) ?? Date()
    }
}
