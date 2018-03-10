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
//  CardStackViewController
//
//  Created by Andrei Pitsko on 07/12/15.
//

import UIKit

open class CardStackView: UICollectionView {
}

open class CardStackViewCell: UICollectionViewCell {
}

public protocol CardStackDelegate  {
    func cardDidChangeState(_ cardIndex: Int)
}

public protocol CardStackDatasource  {
    func numberOfCards(in cardStack: CardStackView) -> Int
    func card(_ cardStack: CardStackView, cardForItemAtIndex index: IndexPath) -> CardStackViewCell
}


open class CardStackViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    private struct Constants {
        static let cardsPadding: CGFloat = 20
        static let cardsHeightFactor: CGFloat = 0.33

    }
    
    open var cardStackDelegate: CardStackDelegate? {
        didSet {
            layout.delegate = cardStackDelegate
        }
    }
    
    open var datasource: CardStackDatasource?
    
    @objc open var layout: CardStackViewLayout { return collectionViewLayout as! CardStackViewLayout }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        layout.gesturesEnabled = true
        collectionView!.isScrollEnabled = false
        setCardSize(CGSize(width: collectionView!.bounds.width - 2 * Constants.cardsPadding, height: Constants.cardsHeightFactor * collectionView!.bounds.height))
    
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let datasource = datasource else {
            assertionFailure("please set datasource before")
            return 0
        }
        guard let cardStack = collectionView as? CardStackView else {
            assertionFailure("please use CardStackView insted of UICollectionView")
            return 0
        }

        return datasource.numberOfCards(in: cardStack)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return datasource!.card(collectionView as! CardStackView, cardForItemAtIndex: indexPath)
    }
    
    //This method should be called when new card added
    @objc open func newCardAdded() {
        if layout.newCardShouldAppearOnTheBottom {
            layout.newCardDidAdd(datasource!.numberOfCards(in: collectionView as! CardStackView) - 1)
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
    
    @objc open func moveCardUp() {
        if layout.index > 0 {
            layout.index -= 1
        }
    }
    
    @objc open func moveCardDown() {
        if layout.index <= datasource!.numberOfCards(in: collectionView as! CardStackView) - 1 {
            layout.index += 1
        }
    }

}
