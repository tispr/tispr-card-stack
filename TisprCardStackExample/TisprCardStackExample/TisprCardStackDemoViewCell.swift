//
//  TisprCardStackDemoViewCell.swift
//  TisprCardStackExample
//
//  Created by Andrei Pitsko on 7/12/15.
//  Copyright (c) 2015 BuddyHopp Inc. All rights reserved.
//

import TisprCardStack
import UIKit

class TisprCardStackDemoViewCell: TisprCardStackViewCell {
    
    @IBOutlet weak var text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        clipsToBounds = false
        
        /// FIXME: Use these properties later on for a more customizable layout
        layer.masksToBounds = false;
        layer.shadowOpacity = 0.3;
        layer.shadowRadius = 3.0;
        layer.shadowOffset = CGSizeZero;
        layer.shadowPath = UIBezierPath(rect: bounds).CGPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

    }
}