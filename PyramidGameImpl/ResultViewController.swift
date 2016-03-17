//
//  ResultViewController.swift
//  PyramidGameImpl
//
//  Created by Michael LeKander on 3/17/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var lScoreView: UIButton! {
        didSet {
            lScoreView.setTitle("\(lScore)", forState: .Normal)
        }
    }
    @IBOutlet weak var rScoreView: UIButton! {
        didSet {
            rScoreView.setTitle("\(rScore)", forState: .Normal)
        }
    }
    
    var lScore:Int = 0 {
        didSet {
            lScoreView?.setTitle("\(lScore)", forState: .Normal)
        }
    }
    var rScore:Int = 0 {
        didSet {
            rScoreView?.setTitle("\(rScore)", forState: .Normal)
        }
    }
}