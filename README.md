TisprCardStack
============


<img src="./Screenshot_main.gif" width="200" alt="Screenshot" />

Library that allows to have  cards UI (like tinder)


Works on iOS 8.

Installation
------------

###[CocoaPods](http://cocoapods.org/):
In your `Podfile`:
```
pod "TisprCardStack"
```
And in your `*.swift`:
```swift
import TisprCardStack
```



###Manual Install
Add `TisprCardStackViewCell.swift`,`TisprCardStackViewController.swift`, `TisprCardStackViewLayout.swift` into your Xcode project.

Usage
-----
1. Create controller 'TisprCardStackViewController' with 'TisprCardStackViewLayout' collectionViewLayout

2. Configuration TisprCardStackViewController,

  ```swift
        setAnimationSpeed(0.85)
        setCardSize(size)
  ```

3. then specify count of cards,
  ```swift
  func numberOfCards() -> Int {}
  ```
	
4. return cards by index:
  ```swift
  card(collectionView: UICollectionView, cardForItemAtIndexPath indexPath: NSIndexPath) -> TisprCardStackViewCell {}
  ```


-----	
1. You can animated add new card calling method:

  ```swift
func newCardWasAdded()
  ```

1. You can configure card stacks by methods:
  ```swift
        layout.topStackMaximumSize = 4
        layout.bottomStackMaximumSize = 30
        layout.bottomStackCardHeight = 45
  ```

1. You can change card position from code by calling methods:
  ```swift
        moveCardUp()
        moveCardDown()
  ```
1. You can track changing of card stack in method:
  ```swift
	func cardDidChangeState(cardIndex: Int)
   ```


For more detail, see the sample project.

Contact
-------

andrei.pitsko@gmail.com

License
-------
Apache License
                           Version 2.0. See LICENSE.txt
