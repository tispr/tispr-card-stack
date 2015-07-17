/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

//
//  TisprCardStackDemoViewCell.swift
//  TisprCardStackExample
//
//  Created by Andrei Pitsko on 7/12/15.
//  Copyright (c) 2015 BuddyHopp Inc. All rights reserved.
//

import UIKit
import TisprCardStack

class TisprCardStackDemoViewCell: TisprCardStackViewCell {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var  voteSmile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 12
        clipsToBounds = false
        
    }
    
    override var center: CGPoint {
        didSet {
            updateSmileVote()
        }
    }
    
    override internal func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        updateSmileVote()
    }
    
    func updateSmileVote() {
        let rotation = atan2(transform.b, transform.a)
        if rotation == 0 {
            voteSmile.hidden = true
        } else {
            voteSmile.hidden = false
            
            let voteSmileImageName = (rotation > 0) ? "smile_face" : "rotten_face"
            voteSmile.image = UIImage(named: voteSmileImageName)
            
        }
    }


}