//
//  PyramidModel.swift
//  PyramidGameImpl
//
//  Created by Alex de Vries on 3/7/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import Foundation

class PyramidModel {
    func callBullshit() -> Bool {
        return arc4random_uniform(2) == 1
    }
    
    func chooseCard() -> Int? {
        if arc4random_uniform(2) == 1 {
            return nil
        } else {
            return Int(arc4random_uniform(4))
        }
    }
}