//
//  MutableCollection+shuffle.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 04/08/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import Foundation

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
