//
//  ResultViewController.swift
//  PyramidGameImpl
//
//  Created by Michael LeKander on 3/18/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class OpponentSelectController: UIViewController {
//    @IBAction func test2(sender: UIButton) {
//        self.performSegueWithIdentifier("easterWin", sender: self)
//    }
//    @IBAction func test1(sender: UIButton) {
//        self.performSegueWithIdentifier("easterLose", sender: self)
//    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let pvc = segue.destinationViewController as? PyramidViewController {
            if let id = segue.identifier {
                pvc.game = PyramidGame(numRanks:13, numSuits:4, pyramidRows:4, handSize:4)
                if id == "chooseSekhmet" {
                    pvc.opponent = SekhmetAI(game:pvc.game)
                } else if id == "chooseHorus" {
                    pvc.opponent = HorusAI(game:pvc.game)
                } else {
                    print("PANIC!!! Unknown segue identifier:\(id)")
                }
            }
        }
//        else if let rvc = segue.destinationViewController as? ResultViewController {
//            if let id = segue.identifier {
//                if id == "easterWin" {
//                    rvc.lScore = 20
//                    rvc.rScore = 10
//                } else if id == "easterLose" {
//                    rvc.lScore = 10
//                    rvc.rScore = 20
//                } else {
//                    print("PANIC!!! Unknown segue identifier:\(id)")
//                }
//            }
//        }
        super.prepareForSegue(segue, sender: sender)
        
    }
}