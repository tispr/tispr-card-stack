/*
Copyright 2015 BuddyHopp, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//
//  TisprCardStackDemoViewCell.swift
//  TisprCardStack
//
//  Created by Andrei Pitsko on 7/12/15.
//

import UIKit
import TisprCardStack

class TisprCardStackDemoViewCell: TisprCardStackViewCell {

    
    private struct Constants {
        static let cellCornerRadius: CGFloat = 12
        static let animationSpeed: Float = 0.86
        static let rotationRadius: CGFloat = 15
        static let smileNeutral = "smile_neutral"
        static let smileFace1 = "smile_face_1"
        static let smileFace2 = "smile_face_2"
        static let smileRotten1 = "smile_rotten_1"
        static let smileRotten2 = "smile_rotten_2"

    }
    
    @IBOutlet  weak var text: UILabel!
    @IBOutlet private weak var voteSmile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Constants.cellCornerRadius
        clipsToBounds = false
    }
    
    override var center: CGPoint {
        didSet {
            updateSmileVote()
        }
    }
    
    override internal func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        updateSmileVote()
    }
    
    @objc func updateSmileVote() {
        let smileImageName: String
        let rotation = atan2(transform.b, transform.a) * 100
        
        switch rotation {
        case -1 * CGFloat.greatestFiniteMagnitude ..< -1 * Constants.rotationRadius:
            smileImageName = Constants.smileRotten2
        case -1 * Constants.rotationRadius ..< 0:
            smileImageName = Constants.smileRotten1
        case 1..<Constants.rotationRadius:
            smileImageName = Constants.smileFace1
        case Constants.rotationRadius ... CGFloat.greatestFiniteMagnitude:
            smileImageName = Constants.smileFace2
        default:
            smileImageName = Constants.smileNeutral
        }
        
        voteSmile.image = UIImage(named: smileImageName)
    }


}
