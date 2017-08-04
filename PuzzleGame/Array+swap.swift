//
//  Array+swap.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 04/08/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import Foundation

extension Array {
    mutating func swap(ind1: Int, _ ind2: Int){
        var temp: Element
        temp = self[ind1]
        self[ind1] = self[ind2]
        self[ind2] = temp
    }
}
