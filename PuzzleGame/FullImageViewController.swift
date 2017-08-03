//
//  FullImageViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 03/08/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.image != nil {
            self.imageView.image = self.image!
        }
    }
}
