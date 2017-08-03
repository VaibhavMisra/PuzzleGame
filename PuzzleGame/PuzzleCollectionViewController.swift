//
//  PuzzleCollectionViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 14/07/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let rowCount = 3
private let colCount = 4

extension UIImage {
    func getImageArray(forRows numRows:Int, columns numCols:Int) -> [UIImage]? {
        let totalCount = numRows * numCols
        var result = [UIImage](repeating: self, count: totalCount)
        for rowIndex in 0..<numRows {
            for colIndex in 0..<numCols {
                
                let width = self.size.width / CGFloat(numCols)
                let height = self.size.height / CGFloat(numRows)
                let size = CGSize(width: width, height: height)
                
                let origin = CGPoint(x: (CGFloat(colIndex) * width),
                                     y: (CGFloat(rowIndex) * height))
                
                guard let cgImage = cgImage,
                    let image = cgImage.cropping(to: CGRect(origin: origin,
                                                            size: size))
                    else { return nil }
                let index = (rowIndex * numCols) + colIndex
                result[index] = UIImage(cgImage: image)
            }
        }
        return result
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}

public extension Array {
    mutating func swap(ind1: Int, _ ind2: Int){
        var temp: Element
        temp = self[ind1]
        self[ind1] = self[ind2]
        self[ind2] = temp
    }
}

class PuzzleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var image: UIImage?
    var imageArray = [UIImage]()
    var pieceArray = [PuzzlePiece]()
    
    var padding: Int {
        return 20
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action:  #selector(handleLongGesture(_:)))
        self.collectionView?.addGestureRecognizer(longPressGesture)

        // Do any additional setup after loading the view.
        DispatchQueue.global().async {
            if let imageURL = URL(string: "https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"),
                let data = try? Data(contentsOf: imageURL),
                let image = UIImage(data: data) {
                
                if let result = image.getImageArray(forRows: rowCount,
                                                    columns: colCount) {
                    self.imageArray = result
                    
                    for (index, element) in self.imageArray.enumerated() {
                        let piece = PuzzlePiece(image: element, correctIndex: index)
                        self.pieceArray.append(piece)
                    }
                
                    self.pieceArray.shuffle()
                    DispatchQueue.main.sync {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Float((self.collectionView?.bounds.width)! - CGFloat(colCount * self.padding))/Float(colCount)
        let height = Float((self.collectionView?.bounds.height)! - CGFloat(rowCount * self.padding))/Float(rowCount)
        
        let size = CGSize(width: CGFloat(width),
                          height: CGFloat(height))
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(self.padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(self.padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        return self.imageArray.count /// rowCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let imageView = UIImageView(image: self.pieceArray[indexPath.row].image)
        cell.backgroundView = imageView
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 moveItemAt sourceIndexPath: IndexPath,
                                 to destinationIndexPath: IndexPath) {

        let piece = self.pieceArray.remove(at: sourceIndexPath.row)
        self.pieceArray.insert(piece, at: destinationIndexPath.row)
        let result = self.isSorted()
        if result == true {
            self.showCompletionAlert()
        }
    }

    //MARK: - Helper
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            self.collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            self.collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            self.collectionView?.endInteractiveMovement()
        default:
            self.collectionView?.cancelInteractiveMovement()
        }
    }
    
    func isSorted() -> Bool {
        for index in 1..<self.pieceArray.count {
            if self.pieceArray[index - 1].correctIndex >= self.pieceArray[index].correctIndex {
                return false
            }
        }
        return true
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: "Complete!", message: "",
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
