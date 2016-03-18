//
//  ResultViewController.swift
//  PyramidGameImpl
//
//  Created by Michael LeKander on 3/18/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class OpponentSelectController: UIViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("osc prepareForSegue identifier:\(segue.identifier)")
        print(segue.destinationViewController)
        if let pvc = segue.destinationViewController as? PyramidViewController {
            if let id = segue.identifier {
                pvc.game = PyramidGame(numRanks:13, numSuits:4, pyramidRows:4, handSize:4)
                if id == "chooseSekhmet" {
                    print("choose1")
                    pvc.opponent = SekhmetAI(game:pvc.game)
                } else if id == "chooseHorus" {
                    print("choose2")
                    pvc.opponent = HorusAI(game:pvc.game)
                } else {
                    print("PANIC!!!")
                }
                print(pvc.opponent)
            }
        }
        super.prepareForSegue(segue, sender: sender)
        
    }
}