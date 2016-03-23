//
//  TutorialViewController.swift
//  Pyramid Game
//
//  Created by Michael LeKander on 3/22/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var tutorialScreenshot: UIImageView! {
        didSet { setImages() }
    }
    @IBOutlet weak var tutorialText: UIImageView! {
        didSet { setImages() }
    }
    
    let imageSequence = ["1","2","3","4a","4b","5","6a","6b"]
    var currNdx = 0 {
        didSet {
            if currNdx < 0 || currNdx >= imageSequence.count {
                //currNdx = min(max(0, currNdx), imageSequence.count-1)
                currNdx = (currNdx + imageSequence.count) % imageSequence.count
            }
            setImages()
        }
    }
    
    func setImages() {
        let suffix = imageSequence[currNdx]
        tutorialText?.image = UIImage(named: "tutorialText\(suffix)")
        UIView.transitionWithView(tutorialScreenshot, duration: 0.25, options: .TransitionCrossDissolve, animations: { self.tutorialScreenshot.image = UIImage(named: "tutorialSS\(suffix)") }, completion: nil)
        //leftButton?.hidden = currNdx == 0
        //rightButton?.hidden = currNdx == imageSequence.count-1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImages()
    }
    
    @IBAction func advance() {
        currNdx++
    }
    
    @IBAction func goBack() {
        currNdx--
    }
}
