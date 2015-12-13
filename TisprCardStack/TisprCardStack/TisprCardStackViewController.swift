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
    func cardDidChangeState(cardIndex: Int)
}

public class TisprCardStackViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    /* The speed of animation. */
    private let animationSpeedDefault: Float = 0.9
    
    public var cardStackDelegate: TisprCardStackViewControllerDelegate? {
        didSet {
            layout.delegate = cardStackDelegate
        }
    }
    
    public var layout: TisprCardStackViewLayout { return collectionViewLayout as! TisprCardStackViewLayout }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setAnimationSpeed(animationSpeedDefault)
        layout.gesturesEnabled = true
        collectionView!.scrollEnabled = false
        setCardSize(CGSizeMake(collectionView!.bounds.width - 40, 2*collectionView!.bounds.height/3))
    
    }
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards()
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return card(collectionView, cardForItemAtIndexPath: indexPath)
    }
    
    //This method should be called after adding new card
    public func newCardWasAdded() {
        if layout.newCardShouldAppearOnTheBottom {
            layout.newCardDidAdd(numberOfCards() - 1)
        } else {
            layout.newCardDidAdd(0)
        }
    }

    //method to change animation speed
    public func setAnimationSpeed(speed: Float) {
        collectionView!.layer.speed = speed
    }
    
    //method to set size of cards
    public func setCardSize(size: CGSize) {
        layout.cardSize = size
    }
    
    //method that should return count of cards
    public func numberOfCards() -> Int {
        assertionFailure("Should be implemented in subsclass")
        return 0
    }

    //method that should return card by index
    public func card(collectionView: UICollectionView, cardForItemAtIndexPath indexPath: NSIndexPath) -> TisprCardStackViewCell {
        assertionFailure("Should be implemented in subsclass")
        return TisprCardStackViewCell()
    }
    
    public func moveCardUp() {
        if layout.index > 0 {
            layout.index--
        }
    }
    
    public func moveCardDown() {
        if layout.index <= numberOfCards() - 1 {
            layout.index++
        }
    }

}
