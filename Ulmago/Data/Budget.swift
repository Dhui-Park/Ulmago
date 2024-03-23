//
//  Budget.swift
//  Ulmago
//
//  Created by dhui on 3/23/24.
//

import Foundation

struct Budget {
    
    var title: String?
    var price: Int?
    
    init(title: String? = "내용을 입력하세요", price: Int? = 0) {
        self.title = title
        self.price = price
    }
}
