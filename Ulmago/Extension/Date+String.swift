//
//  Date+String.swift
//  Ulmago
//
//  Created by dhui on 4/2/24.
//

import Foundation
import UIKit

extension Date {
    
    
    /// Date를 String으로 변환시켜준다.
    /// - Parameter dateFormat: 어떤 Date 타입으로 변환할지 포매팅 타입
    /// - Returns: String
    func toDateString(dateFormat: String = "yyyy-MM-dd") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        return dateFormatter.string(from: self)
    }
    
    
}

extension String {
    
    
    /// String을 Date 타입으로 변환시켜준다.
    /// - Parameter dateFormat: 어떤 Date 타입으로 변환할지 포매팅 타입
    /// - Returns: Date
    func toDate(dateFormat: String = "yyyy-MM-dd") -> Date {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        return dateFormatter.date(from: self) ?? Date()
    }
}
