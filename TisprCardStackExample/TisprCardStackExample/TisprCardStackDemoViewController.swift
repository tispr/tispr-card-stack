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
//  TisprCardStackDemoViewController.swift
//  TisprCardStack
//
//  Created by Andrei Pitsko on 7/8/15.
//

import TisprCardStack

class TisprCardStackDemoViewController: CardStackViewController {
    
    
    private struct Constants {
        static let cellIndentifier = "TisprCardStackDemoViewCellIdentifier"
        static let animationSpeed: Float = 0.86
        static let padding: CGFloat = 20.0
        static let kHeight: CGFloat = 0.67
        static let topStackVisibleCardCount = 40
        static let bottomStackVisibleCardCount = 30
        static let bottomStackCardHeight: CGFloat = 45.0
        static let colors = [UIColor(red: 45.0/255.0, green: 62.0/255.0, blue: 79.0/255.0, alpha: 1.0),
                              UIColor(red: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0),
                              UIColor(red: 141.0/255.0, green: 72.0/255.0, blue: 171.0/255.0, alpha: 1.0),
                              UIColor(red: 241.0/255.0, green: 155.0/255.0, blue: 44.0/255.0, alpha: 1.0),
                              UIColor(red: 234.0/255.0, green: 78.0/255.0, blue: 131.0/255.0, alpha: 1.0),
                              UIColor(red: 80.0/255.0, green: 170.0/255.0, blue: 241.0/255.0, alpha: 1.0)]

    }
    
    fileprivate var countOfCards: Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set size of cards
        let size = CGSize(width: view.bounds.width - 2 * Constants.padding, height: Constants.kHeight * view.bounds.height)
        setCardSize(size)
        
        delegate = self
        datasource = self
        //configuration of stacks
        layout.topStackMaximumSize = Constants.topStackVisibleCardCount
        layout.bottomStackMaximumSize = Constants.bottomStackVisibleCardCount
        layout.bottomStackCardHeight = Constants.bottomStackCardHeight
    }
    
    //method to add new card
    @IBAction func addNewCards(_ sender: AnyObject) {
        countOfCards += 1
        newCardAdded()
    }

    
    @IBAction func moveUP(_ sender: AnyObject) {
        moveCardUp()
    }
    
    @IBAction func moveCardDown(_ sender: AnyObject) {
        moveCardDown()
    }

    @IBAction func deleteAction(_ sender: AnyObject) {
        countOfCards -= 1
        deleteCard()
    }

}

extension TisprCardStackDemoViewController : CardStackDatasource {
    func numberOfCards(in cardStack: CardStackView) -> Int {
        return countOfCards
    }
    
    func card(_ cardStack: CardStackView, cardForItemAtIndex index: IndexPath) -> CardStackViewCell {
        let cell = cardStack.dequeueReusableCell(withReuseIdentifier: Constants.cellIndentifier, for: index) as! TisprCardStackDemoViewCell
        cell.backgroundColor = Constants.colors[index.item % Constants.colors.count]
        cell.text.text = "№ \(index.item)"
        return cell
    }
    
}

extension TisprCardStackDemoViewController: CardStackDelegate {
    func cardDidChangeState(_ cell: CardStackViewCell, atIndexPath indexPath: IndexPath, cardIndex: Int) {
        // Method to observe card postion changes
    }
    
    func cardDidMovedToBottom(_ cell: CardStackViewCell, atIndexPath indexPath: IndexPath) {
        // Method to check when a card is moved to bottom
    }
    
    func cardDidMovedToTop(_ cell: CardStackViewCell, atIndexPath indexPath: IndexPath) {
        // Method to check when a card is moved to top
    }
}
