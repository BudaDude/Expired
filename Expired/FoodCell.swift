//
//  FoodCell.swift
//  Expired
//
//  Created by George Nance on 5/10/16.
//  Copyright © 2016 George Nance. All rights reserved.
//

import UIKit


class FoodCell : UITableViewCell{
    
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodNameLabel: UILabel!
    @IBOutlet var expirationDateLabel: UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
}