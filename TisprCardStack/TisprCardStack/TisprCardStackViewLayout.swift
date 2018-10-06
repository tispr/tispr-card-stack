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

//enum PanDirection {
//    case undefined
//    case left
//    case right
//    case up
//    case down
//}

open class CardStackViewLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    /// The index of the card that is currently on top of the stack. The index 0 represents the oldest card of the stack.
    var index: Int = 0 {
        didSet {
            //workaround for zIndex
            draggedCellPath = oldValue > index ? IndexPath(item: index, section: 0) : IndexPath(item: oldValue, section: 0)
            guard let cell = collectionView!.cellForItem(at: draggedCellPath!) else {
                return
            }
            collectionView?.bringSubview(toFront: cell)
            
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
    
    //    var direction : PanDirection!
    
    var initialPanPoint: CGPoint!
    
    /// The maximum number of cards displayed on the top stack. This value includes the currently visible card.
    @IBInspectable open var topStackMaximumSize: Int = 3
    
    /// The maximum number of cards displayed on the bottom stack.
    @IBInspectable open var bottomStackMaximumSize: Int = 3
    
    /// The visible height of the card of the bottom stack.
    @IBInspectable open var bottomStackCardHeight: CGFloat = 100
    
    /// The size of a card in the stack layout.
    @IBInspectable open var cardSize = CGSize(width: 280, height: 380)
    
    // The inset or outset margins for the rectangle around the card.
    @IBInspectable open var cardInsets: UIEdgeInsets = .zero
    
    /// Cards from bottom stack will be rotated with angle = coefficientOfRotation * hade.
    @IBInspectable open var coefficientOfRotation: Double = 0.25
    
    @IBInspectable open var angleOfRotationForNewCardAnimation: CGFloat = 0.25
    
    @IBInspectable open var verticalOffsetBetweenCardsInTopStack: Int = 10
    @IBInspectable open var centralCardYPosition: Int = 20
    
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
                //                collectionView?.removeGestureRecognizer(recognizer)
                swipeRecognizerDown = UISwipeGestureRecognizer(target: self, action:  #selector(CardStackViewLayout.handleSwipe(_:)))
                swipeRecognizerDown!.direction = UISwipeGestureRecognizerDirection.left
                swipeRecognizerDown!.delegate = self
                collectionView?.addGestureRecognizer(swipeRecognizerDown!)
                swipeRecognizerDown!.require(toFail: panGestureRecognizer!)
                
                swipeRecognizerUp = UISwipeGestureRecognizer(target: self, action:  #selector(CardStackViewLayout.handleSwipe(_:)))
                swipeRecognizerUp!.direction = UISwipeGestureRecognizerDirection.right
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
        let minYPosition = centralCardYPosition + verticalOffsetBetweenCardsInTopStack*(topStackMaximumSize - 1)
        var yPosition = centralCardYPosition + verticalOffsetBetweenCardsInTopStack*(attributes.indexPath.row - index)
        yPosition = min(yPosition,minYPosition)
        
        //right position for new card
        if attributes.indexPath.item == collectionView!.numberOfItems(inSection: 0) - 1 && newCardAnimationInProgress {
            //New card has to be displayed if there are no topStackMaximumSize cards in the top stack
            if attributes.indexPath.item >= index && attributes.indexPath.item < index + topStackMaximumSize {
                yPosition = centralCardYPosition + verticalOffsetBetweenCardsInTopStack*(attributes.indexPath.row - index)
            } else {
                attributes.isHidden = true
                yPosition = centralCardYPosition
            }
        }
        
        let xPosition = (collectionView!.frame.size.height - cardSize.height)/2
        let cardFrame = CGRect(x: CGFloat(yPosition), y: xPosition, width: cardSize.width, height: cardSize.height)
        attributes.frame = cardFrame
        
        return attributes
    }
    
    fileprivate func layoutAttributesForBottomStackItemWithInitialAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let yPosition = (collectionView!.frame.size.height - cardSize.height)/2
        //5s 3.9
        //6plus 4.2
        //8plus 4.4
        let xPosition = -(4.4 * collectionView!.frame.size.width)/5
        
        let frame = CGRect(x: xPosition, y: CGFloat(yPosition), width: cardSize.width, height: cardSize.height)
        attributes.frame = frame
        
        //        if let angle = bottomStackRotations[attributes.indexPath.item] {
        //            attributes.transform3D = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        //        }
        
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
            //            result!.transform3D = CATransform3DMakeRotation(directionFromRight ? angleOfRotationForNewCardAnimation : -angleOfRotationForNewCardAnimation, 0, 0, 1)
        }
        
        return result
    }
    
    // MARK: - Handling the Swipe and Pan Gesture
    
    @objc internal func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .failed:
            print("state Failed")
            UIView.setAnimationsEnabled(false)
            collectionView!.reloadItems(at: [self.draggedCellPath!])
            UIView.setAnimationsEnabled(true)
            break
        case .cancelled:
            print("state Cancelled")
            UIView.setAnimationsEnabled(false)
            collectionView!.reloadItems(at: [self.draggedCellPath!])
            UIView.setAnimationsEnabled(true)
            break
        case .changed:
            print("state Changed")
            break
        case .ended:
            print("state Ended")
            switch sender.direction {
            case UISwipeGestureRecognizerDirection.right:
                // Take the card at the current index
                // and process the swipe up only if it occurs below it
                //                var temIndex = index
                //                if temIndex >= collectionView!.numberOfItems(inSection: 0) {
                //                    temIndex -= 1
                //                }
                //                let currentCard = collectionView!.cellForItem(at: IndexPath(item: temIndex, section: 0))!
                //                let point = sender.location(in: collectionView)
                //                if (point.y > currentCard.frame.maxY && index > 0) {
                if index > 0 {
                    index -= 1
                }
            //                }
            case UISwipeGestureRecognizerDirection.left:
                if index + 1 < collectionView!.numberOfItems(inSection: 0) {
                    index += 1
                }
            default:
                break
            }
            break
        case .possible:
            print("state Possible")
            break
        }
        
        
    }
    
    @objc internal func handlePan(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            //            direction = PanDirection.undefined
            //            if (direction == PanDirection.undefined) {
            //
            //                let velocity = sender.velocity(in: sender.view)
            //
            //                let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            //
            //                if isVerticalGesture{
            //                    if (velocity.y > 0) {
            //                        direction = PanDirection.down;
            //                    } else {
            //                        direction = PanDirection.up;
            //                    }
            //                }
            //
            //                else {
            //                    if  velocity.x > 0 {
            //                        direction = PanDirection.right;
            //                    } else {
            //                        direction = PanDirection.left;
            //                    }
            //                }
            //            }
            let initialPanPoint = sender.location(in: collectionView)
            findDraggingCellByCoordinate(initialPanPoint)
        } else if (sender.state == .changed) {
            print("Pan Changed")
            //            let velocity = sender.velocity(in: sender.view)
            //
            //            let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            //
            //            if isVerticalGesture{
            //                if (velocity.y > 0) {
            //                    direction = PanDirection.down;
            //                } else {
            //                    direction = PanDirection.up;
            //                }
            //            }
            //
            //            else {
            //                if  velocity.x > 0 {
            //                    direction = PanDirection.right;
            //                } else {
            //                    direction = PanDirection.left;
            //                }
            //            }
            //            if direction == PanDirection.left || direction == PanDirection.right{
            let newCenter = sender.translation(in: collectionView!)
            updateCenterPositionOfDraggingCell(newCenter)
            //            }
            //            else{
            //                if index != 0{
            //                    UIView.setAnimationsEnabled(false)
            //                    collectionView!.reloadItems(at: [self.draggedCellPath!])
            //                    UIView.setAnimationsEnabled(true)
            //                }
            //            }
        } else {
            print("Pan Ended")
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
            collectionView?.bringSubview(toFront: cell!)
            
        }
    }
    
    //Change position of dragged card
    fileprivate func updateCenterPositionOfDraggingCell(_ touchCoordinate:CGPoint) {
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItem(at: strongDraggedCellPath) {
                var newCenterX = initialCellCenter!.x
                if(touchCoordinate.x < 0){
                    newCenterX += touchCoordinate.x
                }
                let newCenterY = (initialCellCenter!.y)
                cell.center = CGPoint(x: newCenterX, y: newCenterY)
                
                //                cell.transform = CGAffineTransform(rotationAngle: CGFloat(storeAngleOfRotation()))
            }
        }
    }
    
    fileprivate func finishedDragging(_ cell: UICollectionViewCell) {
        let deltaX = abs(cell.center.x - initialCellCenter!.x)
        //        let deltaY = abs(cell.center.y - initialCellCenter!.y)
        let shouldSnapBack = (deltaX < minimumXPanDistanceToSwipe || cell.center.x > initialCellCenter!.x)
        if shouldSnapBack {
            UIView.animate(withDuration: 0.4, animations: {
                cell.center = self.initialCellCenter!
            }) { (true) in
                //                UIView.setAnimationsEnabled(false)
                //                self.collectionView?.scrollToItem(at: self.draggedCellPath!, at: .centeredHorizontally, animated: false)
                //                self.collectionView!.reloadItems(at: [self.draggedCellPath!])
                //                UIView.setAnimationsEnabled(true)
                //                self.collectionView?.bringSubview(toFront: cell)
            }
            
        } else {
            //            _ = storeAngleOfRotation()
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
            
            print(velocity)
            if velocity.x < 0{
                result = true
            } else{
                result = false
            }
        }
        return result
    }
    
}
