//
//  DailyBudgetTableViewCell.swift
//  Ulmago
//
//  Created by dhui on 3/23/24.
//

import Foundation
import UIKit

class DailyBudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func editBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
    }
    
    
}
