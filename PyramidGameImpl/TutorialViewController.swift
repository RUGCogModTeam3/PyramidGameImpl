//
//  TutorialViewController.swift
//  Pyramid Game
//
//  Created by Michael LeKander on 3/22/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

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
                currNdx = min(max(0, currNdx), imageSequence.count-1)
            } else {
                setImages()
            }
        }
    }
    
    func setImages() {
        let suffix = imageSequence[currNdx]
        tutorialText?.image = UIImage(named: "tutorialText\(suffix)")
        tutorialScreenshot?.image = UIImage(named: "tutorialSS\(suffix)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    @IBAction func advance() {
        currNdx++
    }
    
    @IBAction func goBack() {
        currNdx--
    }
}
