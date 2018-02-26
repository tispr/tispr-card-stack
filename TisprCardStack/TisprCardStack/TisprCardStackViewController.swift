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
//  TisprCardStackViewController
//
//  Created by Andrei Pitsko on 07/12/15.
//

import UIKit

public protocol TisprCardStackViewControllerDelegate  {
    func cardDidChangeState(_ cardIndex: Int)
}

open class TisprCardStackViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    /* The speed of animation. */
    fileprivate let animationSpeedDefault: Float = 0.9
    
    open var cardStackDelegate: TisprCardStackViewControllerDelegate? {
        didSet {
            layout.delegate = cardStackDelegate
        }
    }
    
    @objc open var layout: TisprCardStackViewLayout { return collectionViewLayout as! TisprCardStackViewLayout }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setAnimationSpeed(animationSpeedDefault)
        layout.gesturesEnabled = true
        collectionView!.isScrollEnabled = false
        setCardSize(CGSize(width: collectionView!.bounds.width - 40, height: 2*collectionView!.bounds.height/3))
    
    }
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards()
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return card(collectionView, cardForItemAtIndexPath: indexPath)
    }
    
    //This method should be called after adding new card
    @objc open func newCardWasAdded() {
        if layout.newCardShouldAppearOnTheBottom {
            layout.newCardDidAdd(numberOfCards() - 1)
        } else {
            layout.newCardDidAdd(0)
        }
    }

    //method to change animation speed
    @objc open func setAnimationSpeed(_ speed: Float) {
        collectionView!.layer.speed = speed
    }
    
    //method to set size of cards
    @objc open func setCardSize(_ size: CGSize) {
        layout.cardSize = size
    }
    
    //method that should return count of cards
    @objc open func numberOfCards() -> Int {
        assertionFailure("Should be implemented in subsclass")
        return 0
    }

    //method that should return card by index
    @objc open func card(_ collectionView: UICollectionView, cardForItemAtIndexPath indexPath: IndexPath) -> TisprCardStackViewCell {
        assertionFailure("Should be implemented in subsclass")
        return TisprCardStackViewCell()
    }
    
    @objc open func moveCardUp() {
        if layout.index > 0 {
            layout.index -= 1
        }
    }
    
    @objc open func moveCardDown() {
        if layout.index <= numberOfCards() - 1 {
            layout.index += 1
        }
    }

}
