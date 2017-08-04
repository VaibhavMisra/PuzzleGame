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

protocol PuzzleCollectionDelegate: class {
    func puzzlePieceMoved(from intialPos: Int, to finalPos: Int)
    func puzzleSolved()
}

class PuzzleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Private properties
    private var imageArray = [UIImage]()
    private var pieceArray = [PuzzlePiece]()
    
    //MARK: - Public properties
    weak var puzzleDelegate: PuzzleCollectionDelegate?
    var padding: Int = 2

    //MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action:  #selector(handleLongGesture(_:)))
        self.collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    //MARK: - Public method
    func loadPuzzle(with image: UIImage?) {
        if let result = image?.slice(forRows: rowCount,
                                     columns: colCount) {
            self.imageArray = result
            for (index, element) in self.imageArray.enumerated() {
                let piece = PuzzlePiece(image: element, correctIndex: index)
                self.pieceArray.append(piece)
            }
            self.pieceArray.shuffle()
            self.collectionView?.reloadData()
        }
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
        
        self.puzzleDelegate?.puzzlePieceMoved(from: sourceIndexPath.row,
                                              to: destinationIndexPath.row)
        
        let result = self.isSorted()
        if result == true {
            self.puzzleDelegate?.puzzleSolved()
        }
    }

    //MARK: - Gesture Handler
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
    
    //MARK: - Helper
    func isSorted() -> Bool {
        for index in 1..<self.pieceArray.count {
            if self.pieceArray[index - 1].correctIndex >= self.pieceArray[index].correctIndex {
                return false
            }
        }
        return true
    }
}
