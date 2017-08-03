//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 14/07/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var puzzleImage: UIImage?
    weak var embedVC:PuzzleCollectionViewController?
    
    //Constants
    let initialTime = 3.0
    let fullImageSBId = "fullImageVC"
    let puzzleSBId = "showPuzzle"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.loadImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == self.puzzleSBId) {
            let puzzleVC = segue.destination as! PuzzleCollectionViewController
            self.embedVC = puzzleVC;
        }
    }
    
    fileprivate func loadImage() {
        DispatchQueue.global().async {
            if let imageURL = URL(string: "https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"),
                let data = try? Data(contentsOf: imageURL),
                let image = UIImage(data: data) {
                    self.puzzleImage = image
                DispatchQueue.main.async {
                    self.showFullImage(for: image, seconds: self.initialTime)
                }
            }
        }
    }

    fileprivate func showFullImage(for image: UIImage, seconds: Double) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let fullImageVC = storyboard.instantiateViewController(withIdentifier: self.fullImageSBId) as? FullImageViewController {
            fullImageVC.image = image
            fullImageVC.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(fullImageVC, animated: true, completion: nil)
            self.dismissFullImageView(in: seconds)
        }
    }
    
    fileprivate func dismissFullImageView(in seconds: Double) {
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when){
            self.dismiss(animated: true, completion: {
                self.embedVC?.loadPuzzle(with: self.puzzleImage)
                
            })
        }
    }

}

