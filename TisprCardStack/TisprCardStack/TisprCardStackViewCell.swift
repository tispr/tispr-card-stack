//
//  TisprCardStackViewCell
//
//  Created by Andrei Pitsko on 07/12/15.
//  Copyright (c) 2014 BuddyHopp. All rights reserved.
//

import UIKit

public class TisprCardStackViewCell: UICollectionViewCell {
    
    override public func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        let center = layoutAttributes.center
        var animation = CABasicAnimation(keyPath: "position.y")
        animation.toValue = center.y
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.8, 2.0, 1.0, 1.0)
        layer.addAnimation(animation, forKey: "position.y")

        super.applyLayoutAttributes(layoutAttributes)
    }
    
}