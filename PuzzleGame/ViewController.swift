//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 14/07/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PuzzleCollectionDelegate {

    var puzzleImage: UIImage?
    weak var embedVC:PuzzleCollectionViewController?
    
    //Constants
    let imageURL = "https://s3-eu-west-1.amazonaws.com/wagawin-ad-platform/media/testmode/banner-landscape.jpg"
    let initialTime = 3.0
    let mainStoryboardName = "Main"
    let fullImageSBId = "fullImageVC"
    let puzzleSBId = "showPuzzle"
    let successMsg = "Complete!"
    let successBtnTitle = "OK"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.loadImage {
            if let image = self.puzzleImage {
                self.showFullImage(for: image, seconds: self.initialTime)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == self.puzzleSBId) {
            let puzzleVC = segue.destination as! PuzzleCollectionViewController
            puzzleVC.puzzleDelegate = self
            self.embedVC = puzzleVC;
        }
    }
    
    //MARK: - PuzzleCollectionDelegate
    func puzzlePieceMoved(from intialPos: Int, to finalPos: Int) {
        //Do Something on puzzle piece move
    }
    
    func puzzleSolved() {
        self.showCompletionAlert()
    }
    
    //MARK: - Helper
    
    fileprivate func loadImage(completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.global().async {
            if let imageURL = URL(string: self.imageURL),
                let data = try? Data(contentsOf: imageURL),
                let image = UIImage(data: data) {
                self.puzzleImage = image
                if completion != nil {
                    DispatchQueue.main.async {
                        completion!()
                    }
                }
            }
        }
    }
    
    fileprivate func showFullImage(for image: UIImage, seconds: Double) {
        let storyboard = UIStoryboard(name: self.mainStoryboardName,
                                      bundle: nil)
        if let fullImageVC =
            storyboard.instantiateViewController(withIdentifier: self.fullImageSBId)
                as? FullImageViewController {
            fullImageVC.image = image
            fullImageVC.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(fullImageVC,
                                               animated: true, completion: nil)
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
    
    func showCompletionAlert() {
        let alert = UIAlertController(title: self.successMsg, message: "",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: self.successMsg,
                               style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

