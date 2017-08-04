//
//  UIImage+Slice.swift
//  PuzzleGame
//
//  Created by Vaibhav Misra on 04/08/17.
//  Copyright © 2017 Vaibhav Misra. All rights reserved.
//

import UIKit

extension UIImage {
    func slice(forRows numRows:Int, columns numCols:Int) -> [UIImage]? {
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
