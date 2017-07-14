//
//  PuzzleCollectionViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 14/07/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

extension UIImage {
    var topHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height/2))) else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    var bottomHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int(size.height/2))), size: CGSize(width: size.width, height: CGFloat(Int(size.height) - Int(size.height/2))))) else { return nil }
        return UIImage(cgImage: image)
    }
    var leftHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width/2, height: size.height))) else { return nil }
        return UIImage(cgImage: image)
    }
    var rightHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))
            else { return nil }
        return UIImage(cgImage: image)
    }
}

class PuzzleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var image:UIImage?
    var imageArray = [[UIImage]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
//        self.collectionView?.addGestureRecognizer(longPressGesture)

        // Do any additional setup after loading the view.
        DispatchQueue.global().async {
            if let imageURL = URL(string: "https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"),
                let data = try? Data(contentsOf: imageURL),
                let image = UIImage(data: data) {
                
                let topHalf = image.topHalf
                let bottomHalf = image.bottomHalf
                
                if let topLeft = topHalf?.leftHalf,
                    let topRight = topHalf?.rightHalf,
                    let bottomLeft = bottomHalf?.leftHalf,
                    let bottomRight = bottomHalf?.rightHalf {
                    self.imageArray = [[topLeft, bottomLeft], [topRight, bottomRight]]
                    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Gesture recogniser
//    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
//    {
//        switch(gesture.state)
//        {
//            
//        case .began:
//            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else
//            {
//                break
//            }
//            
//            self.collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
//            
//        case .changed:
//            self.collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//            
//        case .ended:
//            self.collectionView?.endInteractiveMovement()
//            
//        default:
//            self.collectionView?.cancelInteractiveMovement()
//        }
//    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Float((self.collectionView?.bounds.width)!)/Float(self.imageArray.count)
        let height = Float((self.collectionView?.bounds.width)!)/Float(self.imageArray[indexPath.section].count)
        
        let size = CGSize(width: CGFloat(width),
                          height: CGFloat(height))
        print("Size: \(size)")
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        print("Sections: \(self.imageArray.count)")
        return self.imageArray.count
    }


    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        print("Rows: \(self.imageArray[section].count)")
        return self.imageArray[section].count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let imageView = UIImageView(image: self.imageArray[indexPath.section][indexPath.row])
        cell.backgroundView = imageView
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 moveItemAt sourceIndexPath: IndexPath,
                                 to destinationIndexPath: IndexPath) {
        let image = self.imageArray.remove(at: sourceIndexPath.item)
        self.imageArray.insert(image, at: destinationIndexPath.item)
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
