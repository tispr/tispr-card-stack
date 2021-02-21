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
//  CardStackViewLayout
//
//  Created by Andrei Pitsko on 07/12/15.
//

import UIKit

open class CardStackViewLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    /// The index of the card that is currently on top of the stack. The index 0 represents the oldest card of the stack.
    var index: Int = 0 {
        didSet {
            //workaround for zIndex
            draggedCellPath = oldValue > index ? IndexPath(item: index, section: 0) : IndexPath(item: oldValue, section: 0)
            guard let cell = collectionView!.cellForItem(at: draggedCellPath!) else {
                return
            }
            collectionView?.bringSubviewToFront(cell)

            collectionView?.performBatchUpdates({ [weak self] in
                self?.invalidateLayout()
            }, completion: { [weak self] _ in
                guard let strongself = self else {
                    return
                }

                strongself.delegate?.cardDidChangeState(strongself.index)
            })
        }
    }
    
    var delegate: CardStackDelegate?
    
    /// The maximum number of cards displayed on the top stack. This value includes the currently visible card.
    @IBInspectable open var topStackMaximumSize: Int = 3
    
    /// The maximum number of cards displayed on the bottom stack.
    @IBInspectable open var bottomStackMaximumSize: Int = 3
    
    /// The visible height of the card of the bottom stack.
    @IBInspectable open var bottomStackCardHeight: CGFloat = 50
    
    /// The size of a card in the stack layout.
    @IBInspectable open var cardSize = CGSize(width: 280, height: 380)
    
    // The inset or outset margins for the rectangle around the card.
    @IBInspectable open var cardInsets: UIEdgeInsets = .zero
    
    /// Cards from bottom stack will be rotated with angle = coefficientOfRotation * hade.
    @IBInspectable open var coefficientOfRotation: Double = 0.25
    
    @IBInspectable open var angleOfRotationForNewCardAnimation: CGFloat = 0.25
    
    @IBInspectable open var verticalOffsetBetweenCardsInTopStack: Int = 10
    @IBInspectable open var centralCardYPosition: Int = 70
    
    @IBInspectable open var minimumXPanDistanceToSwipe: CGFloat = 100
    @IBInspectable open var minimumYPanDistanceToSwipe: CGFloat = 60
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    fileprivate var swipeRecognizerDown: UISwipeGestureRecognizer?
    fileprivate var swipeRecognizerUp: UISwipeGestureRecognizer?
    /// A Boolean value indicating whether the pan and swipe gestures on cards are enabled.
    var gesturesEnabled = false {
        didSet {
            if (gesturesEnabled) {
                let recognizer = UIPanGestureRecognizer(target: self, action: #selector(CardStackViewLayout.handlePan(_:)))
                collectionView?.addGestureRecognizer(recognizer)
                panGestureRecognizer = recognizer
                panGestureRecognizer!.delegate = self
                
                swipeRecognizerDown = UISwipeGestureRecognizer(target: self, action:  #selector(CardStackViewLayout.handleSwipe(_:)))
                swipeRecognizerDown!.direction = UISwipeGestureRecognizer.Direction.down
                swipeRecognizerDown!.delegate = self
                collectionView?.addGestureRecognizer(swipeRecognizerDown!)
                swipeRecognizerDown!.require(toFail: panGestureRecognizer!)
                
                swipeRecognizerUp = UISwipeGestureRecognizer(target: self, action:  #selector(CardStackViewLayout.handleSwipe(_:)))
                swipeRecognizerUp!.direction = UISwipeGestureRecognizer.Direction.up
                swipeRecognizerUp!.delegate = self
                collectionView?.addGestureRecognizer(swipeRecognizerUp!)
                swipeRecognizerUp!.require(toFail: panGestureRecognizer!)
            } else {
                if let recognizer = panGestureRecognizer {
                    collectionView?.removeGestureRecognizer(recognizer)
                }
                if let swipeDownRecog = swipeRecognizerDown {
                    collectionView?.removeGestureRecognizer(swipeDownRecog)
                }
                if let swipeUpRecog = swipeRecognizerUp {
                    collectionView?.removeGestureRecognizer(swipeUpRecog)
                }
                
            }
        }
    }
    
    // Index path of dragged cell
    fileprivate var draggedCellPath: IndexPath?
    
    // The initial center of the cell being dragged.
    fileprivate var initialCellCenter: CGPoint?
    
    // The rotation values of the bottom stack cards.
    fileprivate var bottomStackRotations = [Int: Double]()
    
    // Is the animation for new cards in progress?
    fileprivate var newCardAnimationInProgress = false
    
    
    fileprivate let maxZIndexTopStack = 1000
    fileprivate let dragingCellZIndex = 10000

    // MARK: - Getting the Collection View Information
    
    override open var collectionViewContentSize : CGSize {
        return collectionView!.bounds.size
    }
    
    // MARK: - Providing Layout Attributes
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let indexPaths = indexPathsForElementsInRect(rect)
        let layoutAttributes = indexPaths.map { self.layoutAttributesForItem(at: $0) }.compactMap{ $0 }
        return layoutAttributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var result = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        if (indexPath.item >= index) {
            result = layoutAttributesForTopStackItemWithInitialAttributes(result)
            result.isHidden = (result.indexPath.item >= index + topStackMaximumSize)
        } else {
            result = layoutAttributesForBottomStackItemWithInitialAttributes(result)
            result.isHidden = (result.indexPath.item < (index - bottomStackMaximumSize))
        }
        
        if indexPath.item == draggedCellPath?.item  {
            //workaround for zIndex
            result.zIndex = dragingCellZIndex
        } else {
            result.zIndex = (indexPath.item >= index) ? (maxZIndexTopStack - indexPath.item) : (maxZIndexTopStack + indexPath.item)
        }
        
        return result
    }
    
    fileprivate func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        var result = [IndexPath]()
        
        let count = collectionView!.numberOfItems(inSection: 0)
        
        let topStackCount = min(count - (index + 1), topStackMaximumSize - 1)
        let bottomStackCount = min(index, bottomStackMaximumSize)
        
        let start = index - bottomStackCount
        let end = (index + 1) + topStackCount
        
        for i in start..<end {
            result.append(IndexPath(item: i, section: 0))
        }
        return result
    }
    
    fileprivate func layoutAttributesForTopStackItemWithInitialAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        //we should not change position for card which will be hidden for good animation
        let minYPosition = centralCardYPosition - verticalOffsetBetweenCardsInTopStack*(topStackMaximumSize - 1)
        var yPosition = centralCardYPosition - verticalOffsetBetweenCardsInTopStack*(attributes.indexPath.row - index)
        yPosition = max(yPosition,minYPosition)
        
        //right position for new card
        if attributes.indexPath.item == collectionView!.numberOfItems(inSection: 0) - 1 && newCardAnimationInProgress {
            //New card has to be displayed if there are no topStackMaximumSize cards in the top stack
            if attributes.indexPath.item >= index && attributes.indexPath.item < index + topStackMaximumSize {
                yPosition = centralCardYPosition - verticalOffsetBetweenCardsInTopStack*(attributes.indexPath.row - index)
            } else {
                attributes.isHidden = true
                yPosition = centralCardYPosition
            }
        }
        
        let xPosition = (collectionView!.frame.size.width - cardSize.width)/2
        let cardFrame = CGRect(x: xPosition, y: CGFloat(yPosition), width: cardSize.width, height: cardSize.height)
        attributes.frame = cardFrame
        
        return attributes
    }
    
    fileprivate func layoutAttributesForBottomStackItemWithInitialAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let yPosition = collectionView!.frame.size.height - bottomStackCardHeight
        let xPosition = (collectionView!.frame.size.width - cardSize.width)/2
        
        let frame = CGRect(x: xPosition, y: CGFloat(yPosition), width: cardSize.width, height: cardSize.height)
        attributes.frame = frame
        
        if let angle = bottomStackRotations[attributes.indexPath.item] {
            attributes.transform3D = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        }
        
        return attributes
    }

    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var result: UICollectionViewLayoutAttributes?
        
        if itemIndexPath.item == (collectionView!.numberOfItems(inSection: 0) - 1) && newCardAnimationInProgress {
            
            let yPosition = collectionViewContentSize.height - cardSize.height
            let directionFromRight = arc4random() % 2 == 0
            let xPosition = directionFromRight ? collectionViewContentSize.width : -cardSize.width
            
            let cardFrame = CGRect(x: xPosition, y: yPosition, width: cardSize.width, height: cardSize.height)
            
            result = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            result!.frame = cardFrame
            result!.zIndex = maxZIndexTopStack - itemIndexPath.item
            result!.isHidden = false
            result!.transform3D = CATransform3DMakeRotation(directionFromRight ? angleOfRotationForNewCardAnimation : -angleOfRotationForNewCardAnimation, 0, 0, 1)
        }
        
        return result
    }

    // MARK: - Handling the Swipe and Pan Gesture
    
    @objc internal func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.up:
            // Take the card at the current index
            // and process the swipe up only if it occurs below it
//            var temIndex = index
//            if temIndex >= collectionView!.numberOfItemsInSection(0) {
//                temIndex--
//            }
//            let currentCard = collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: temIndex , inSection: 0))!
//            let point = sender.locationInView(collectionView)
//            if (point.y > CGRectGetMaxY(currentCard.frame) && index > 0) {
            if index > 0 {
                index -= 1
            }
//            }
        case UISwipeGestureRecognizer.Direction.down:
            if index + 1 < collectionView!.numberOfItems(inSection: 0) {
                index += 1
            }
        default:
            break
        }
    }
    
    @objc internal func handlePan(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            let initialPanPoint = sender.location(in: collectionView)
            findDraggingCellByCoordinate(initialPanPoint)
        } else if (sender.state == .changed) {
            let newCenter = sender.translation(in: collectionView!)
            updateCenterPositionOfDraggingCell(newCenter)
        } else {
            if let indexPath = draggedCellPath {
                finishedDragging(collectionView!.cellForItem(at: indexPath)!)
            }
        }
    }
    
    //Define what card should we drag
    fileprivate func findDraggingCellByCoordinate(_ touchCoordinate: CGPoint) {
        if let indexPath = collectionView?.indexPathForItem(at: touchCoordinate) {
            if indexPath.item >= index {
                //top stack
                draggedCellPath = IndexPath(item: index, section: 0)
            } else {
                //bottomStack
                if (index > 0 ) {
                    draggedCellPath = IndexPath(item: index - 1, section: 0)
                }
            }
            initialCellCenter = collectionView?.cellForItem(at: draggedCellPath!)?.center
            
            //workaround for fix issue with zIndex
            let cell = collectionView!.cellForItem(at: draggedCellPath!)
            collectionView?.bringSubviewToFront(cell!)
            
        }
    }
    
    //Change position of dragged card
    fileprivate func updateCenterPositionOfDraggingCell(_ touchCoordinate:CGPoint) {
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItem(at: strongDraggedCellPath) {
                let newCenterX = (initialCellCenter!.x + touchCoordinate.x)
                let newCenterY =  (initialCellCenter!.y + touchCoordinate.y)
                cell.center = CGPoint(x: newCenterX, y: newCenterY)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(storeAngleOfRotation()))
            }
        }
    }
    
    fileprivate func finishedDragging(_ cell: UICollectionViewCell) {
        let deltaX = abs(cell.center.x - initialCellCenter!.x)
        let deltaY = abs(cell.center.y - initialCellCenter!.y)
        let shouldSnapBack = (deltaX < minimumXPanDistanceToSwipe && deltaY < minimumYPanDistanceToSwipe)
        if shouldSnapBack {
            UIView.setAnimationsEnabled(false)
            collectionView!.reloadItems(at: [self.draggedCellPath!])
            UIView.setAnimationsEnabled(true)
        } else {
            _ = storeAngleOfRotation()
            if draggedCellPath?.item == index {
                index += 1
            } else {
                index -= 1
            }
            initialCellCenter = .zero
            draggedCellPath = nil
        }
    }
    
    //Compute and Store angle of rotation
    fileprivate func storeAngleOfRotation() -> Double  {
        var result: Double = 0
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItem(at: strongDraggedCellPath) {
                let centerYIncidence = collectionView!.frame.size.height + cardSize.height - bottomStackCardHeight
                let gamma: Double = Double((cell.center.x -  collectionView!.bounds.size.width/2)/(centerYIncidence - cell.center.y))
                result = atan(gamma)
                bottomStackRotations[strongDraggedCellPath.item] = atan(gamma)*coefficientOfRotation
            }
        }
        return result
    }
    
    // MARK: - appearance of new card
    
    func newCardDidAdd(_ newCardIndex: Int) {
        collectionView?.performBatchUpdates({ [weak self] () in
            self?.newCardAnimationInProgress = true
            self?.collectionView?.insertItems(at: [IndexPath(item: newCardIndex, section: 0)])
            }, completion: {[weak self] _ in
                self?.newCardAnimationInProgress = false
        })
    }
    
    func cardDidRemoved(_ index: Int) {
        collectionView?.performBatchUpdates({ [weak self] () in
            self?.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { _ in })
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var result = true
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: collectionView)
            result = abs(Int(velocity.y)) < 250
        }
        return result
    }
    
}
