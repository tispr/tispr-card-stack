//
//  TisprCardStackDemoViewController.swift
//  TisprCardStack
//
//  Created by Andrei Pitsko on 7/8/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import TisprCardStack
import UIKit

class TisprCardStackDemoViewController: TisprCardStackViewController, TisprCardStackViewControllerDelegate {
    
    
    private let colors = [UIColor(red: 45.0/255.0, green: 62.0/255.0, blue: 79.0/255.0, alpha: 1.0),
        UIColor(red: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0),
        UIColor(red: 141.0/255.0, green: 72.0/255.0, blue: 171.0/255.0, alpha: 1.0),
        UIColor(red: 241.0/255.0, green: 155.0/255.0, blue: 44.0/255.0, alpha: 1.0),
        UIColor(red: 234.0/255.0, green: 78.0/255.0, blue: 131.0/255.0, alpha: 1.0),
        UIColor(red: 80.0/255.0, green: 170.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    ]
    
    
    private var countOfCards: Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set animation speed
        setAnimationSpeed(0.85)
        
        //set size of cards
        let size = CGSizeMake(view.bounds.width - 40, 2*view.bounds.height/3)
        setCardSize(size)
        
        cardStackDelegate = self
        
        //configuration of stacks
        layout.topStackMaximumSize = 4
        layout.bottomStackMaximumSize = 30
        layout.bottomStackCardHeight = 45
    }
    
    //method to add new card
    @IBAction func addNewCards(sender: AnyObject) {
        countOfCards++
        newCardWasAdded()
    }

    
    override func numberOfCards() -> Int {
        return countOfCards
    }
    
    override func card(collectionView: UICollectionView, cardForItemAtIndexPath indexPath: NSIndexPath) -> TisprCardStackViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellIdentifier", forIndexPath: indexPath) as! TisprCardStackDemoViewCell
        
        cell.backgroundColor = colors[indexPath.item % colors.count]
        cell.text.text = "Card - \(indexPath.item)"
        
        return cell

    }

    @IBAction func moveUP(sender: AnyObject) {
        moveCardUp()
    }
    
    @IBAction func moveCardDown(sender: AnyObject) {
        moveCardDown()
    }
    
    func cardDidChangeState(cardIndex: Int) {
        println("card with index - \(cardIndex) changed position") 
    }
}