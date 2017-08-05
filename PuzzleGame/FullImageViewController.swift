//
//  FullImageViewController.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 03/08/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

protocol FullImageDelegate: class {
    func timerDidFinish()
}

class FullImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    
    //Public properties
    weak var delegate: FullImageDelegate?
    var timeToShow: Double = 0
    var image: UIImage?
    
    //Private constants
    let initialScaleValue = CGFloat(0.25)
    let finalScaleValue = CGFloat(4)
    let finalAlphaValue = CGFloat(0.8)
    let frameDuration = TimeInterval(1.0)
    let frameDelay = TimeInterval(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timerLabel.isHidden = true
        if self.image != nil {
            self.imageView.image = self.image!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateTimer(with: self.timeToShow)
    }
    
    //MARK: - Helper functions
    private func animateTimer(with timerValue: Double) {
        
        self.timerLabel.text = String(Int(timerValue))
        self.timerLabel.transform = CGAffineTransform(scaleX: self.initialScaleValue,
                                                      y: self.initialScaleValue)
        self.timerLabel.isHidden = false
        UIView.animate(withDuration: self.frameDuration,
                       delay: self.frameDelay,
                       options: .layoutSubviews,
                       animations: {
            self.timerLabel.transform = CGAffineTransform(scaleX: self.finalScaleValue,
                                                          y: self.finalScaleValue)
            self.timerLabel.alpha = self.finalAlphaValue
        }) { (isFinished) in
            let newTimerValue = timerValue - 1
            if newTimerValue > 0 {
                self.timerLabel.isHidden = true
                self.animateTimer(with: newTimerValue)
            }
            else {
                self.delegate?.timerDidFinish()
            }
        }
    }
}
