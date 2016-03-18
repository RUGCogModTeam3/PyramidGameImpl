//
//  ViewController.swift
//  PyramidGameImpl
//
//  Created by Alex de Vries on 3/7/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit



enum UIState {
    case MemorizeFirst, HumanYesNo, HumanSelect, HumanBS(ndx:Int), HumanNewCard(ndx:Int), ModelSelect, ModelPass, ModelBS(ndx:Int), ModelPostBS(ndx:Int, call:Bool);
    
    func clickAB1(c:PyramidViewController) {
        switch self {
        case .MemorizeFirst:
            c.state = .HumanYesNo
            
        case .HumanYesNo:
            c.state = .HumanSelect
            
        case let .HumanBS(ndx):
            c.state = .HumanNewCard(ndx:ndx)
            
        case let .HumanNewCard(ndx):
            c.hideHandCard(ndx)
            c.lowerHandCard(ndx)
            c.state = .ModelSelect
            
        case .ModelPass:
            c.state = .HumanYesNo
            
        case let .ModelBS(ndx):
            c.state = .ModelPostBS(ndx:ndx, call:true)
            
        case .ModelPostBS:
            c.state = .HumanYesNo
            
        default: break
        }
    }
    
    func clickAB2(c:PyramidViewController) {
        switch self {
        case .HumanYesNo:
            c.game.selectCard(.Left, ndx: nil)
            c.state = .ModelSelect
            
        case let .ModelBS(ndx):
            c.state = .ModelPostBS(ndx:ndx, call:false)
            
        default: break
        }
    }
    
    func clickCard(c:PyramidViewController, ndx:Int) {
        switch self {
        case .HumanSelect:
            c.game.selectCard(.Left, ndx:ndx)
            c.raiseHandCard(ndx)
            c.state = .HumanBS(ndx:ndx)
            
        default: break
        }
    }
    
    func setup(c:PyramidViewController) {
        switch self {
        case .MemorizeFirst:
            for i in 0..<4 {
                c.showHandCard(i)
                c.raiseHandCard(i)
                c.showOppHandCard(i)
                c.raiseOppHandCard(i)
                c.pModel.storeModelCard(c.game.players[.Right]!.hand[i], ndx:i)
            }
            c.setABTitles("Next", nil)
            c.tutorialText = "Welcome mortal! Remember your cards well..."
            
        case .HumanYesNo:
            for i in 0..<4 {
                c.hideHandCard(i)
                c.lowerHandCard(i)
                c.hideOppHandCard(i)
                c.lowerOppHandCard(i)
            }
            c.setABTitles("Yes/Bluff", "No")
            
            if let nextCard = c.game.nextTurn() {
                c.pModel.storeCard(nextCard)
                c.pcards.popLast()!.image = nextCard.image
                c.tutorialText = "Well, human, do you have a \(nextCard.rankName)?"
            } else {
                c.finishGame()
            }
            
        case .HumanSelect:
            c.setABTitles(nil, nil)
            c.tutorialText = "Select your card, mortal."
            
        case let .HumanBS(ndx):
            let lPreScore = c.game.players[.Left]!.score
            let rPreScore = c.game.players[.Right]!.score
            c.setABTitles("Next", nil)
            let callBS = c.pModel.callBullshit(c.game.pyramid.getLastFlippedCard())
            var bsText = ""
            if callBS {
                bsText = "Show me your card! I believe you are bluffing...\n\n"
                c.showHandCard(ndx)
                c.pModel.storeCard(c.game.players[.Left]!.hand[ndx])
                c.game.callBullshit(.Left, call:callBS)
                let lDiff = c.game.players[.Left]!.score - lPreScore
                let rDiff = c.game.players[.Right]!.score - rPreScore
                if lDiff > 0 {
                    c.pModel.storePlayerBluff(false)
                    bsText = bsText + "But you were telling the truth! You get \(lDiff) points."
                } else {
                    c.pModel.storePlayerBluff(true)
                    bsText = bsText + "I was right! I get \(rDiff) points."
                }
            } else {
                bsText = "I trust you are not bluffing... for now. You get \(c.game.pyramid.rowValue()) points."
                c.game.callBullshit(.Left, call:callBS)
            }
            c.tutorialText = bsText
            
        case let .HumanNewCard(ndx):
            c.setABTitles("Next", nil)
            c.tutorialText = "This is your new card, mortal. Remember it well."
            c.showHandCard(ndx)
            
        case .ModelSelect:
            let choice = c.pModel.getPlay(c.game.pyramid.getLastFlippedCard())
    
            c.game.selectCard(.Right, ndx: choice)
            if let ndx = choice {
                c.state = .ModelBS(ndx:ndx)
            } else {
                c.state = .ModelPass
            }
        
        case .ModelPass:
            c.setABTitles("Next", nil)
            c.tutorialText = "It is now my turn... but I don't have a \(c.game.pyramid.getLastFlippedCard().rankName)."
            
        case let .ModelBS(ndx):
            c.setABTitles("Yes", "No")
            c.tutorialText = "It is now my turn! I do have a \(c.game.pyramid.getLastFlippedCard().rankName).\n\nDo you think I am bluffing?"
            c.raiseOppHandCard(ndx)
            
        case let .ModelPostBS(ndx, call):
            let lPreScore = c.game.players[.Left]!.score
            let rPreScore = c.game.players[.Right]!.score
            if call {
                c.showOppHandCard(ndx)
            }
            c.game.callBullshit(.Right, call:call)
            c.pModel.storeModelCard(c.game.players[.Right]!.hand[ndx], ndx:ndx)
            c.pModel.storePlayerBluffCall(call)
            c.setABTitles("Next", nil)
            var textBase = ""
            if call {
                let lDiff = c.game.players[.Left]!.score - lPreScore
                let rDiff = c.game.players[.Right]!.score - rPreScore
                if lDiff > 0 {
                    textBase = "No, you caught me in my lie! You get \(lDiff) points."
                } else {
                    textBase = "Ha! I was telling the truth! I get \(rDiff) points."
                }
            } else {
                textBase = "Very well, mortal. I get \(c.game.pyramid.rowValue()) points."
            }
            c.tutorialText = textBase + "\n\nNow I get a new card."
        }
        c.lscore.setTitle("\(c.game.players[.Left]!.score)", forState: .Normal)
        c.rscore.setTitle("\(c.game.players[.Right]!.score)", forState: .Normal)
    }
}

class PyramidViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    //Initialize a pyramidmodel and load the right model. Not sure why it gives a warning though
	var game = PyramidGame(numRanks:13, numSuits:4, pyramidRows:4, handSize:4)
    let pModel: PyramidClass
    
    init() {
        pModel = PyramidClass(game:self.game)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        pModel = PyramidClass(game:self.game)
        super.init(coder: aDecoder)
    }
    
    
    @IBOutlet weak var card0: UIButton!
    @IBOutlet weak var card1: UIButton!
    @IBOutlet weak var card2: UIButton!
    @IBOutlet weak var card3: UIButton!
    @IBOutlet weak var actionButton1: UIButton!
    @IBOutlet weak var actionButton2: UIButton!
    @IBOutlet weak var tutorialTextView: UITextView!
    
    @IBOutlet weak var pcard11: UIImageView!
    @IBOutlet weak var pcard12: UIImageView!
    @IBOutlet weak var pcard13: UIImageView!
    @IBOutlet weak var pcard14: UIImageView!
    @IBOutlet weak var pcard21: UIImageView!
    @IBOutlet weak var pcard22: UIImageView!
    @IBOutlet weak var pcard23: UIImageView!
    @IBOutlet weak var pcard31: UIImageView!
    @IBOutlet weak var pcard32: UIImageView!
    @IBOutlet weak var pcard41: UIImageView!
    
    @IBOutlet weak var lscore: UIButton!
    @IBOutlet weak var rscore: UIButton!
    
    @IBOutlet weak var portraitButton: UIButton!
    
    @IBOutlet weak var card0TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var card1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var card2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var card3TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var oppCard0: UIImageView!
    @IBOutlet weak var oppCard1: UIImageView!
    @IBOutlet weak var oppCard2: UIImageView!
    @IBOutlet weak var oppCard3: UIImageView!
    
    @IBOutlet weak var oppCard0TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var oppCard1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var oppCard2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var oppCard3TopConstraint: NSLayoutConstraint!
    
    var cards = [UIButton!]()
    var cardConstraints = [NSLayoutConstraint!]()
    var oppcards = [UIImageView!]()
    var oppcardConstraints = [NSLayoutConstraint!]()
    var pcards = [UIImageView!]()
    
    var tutorialText: String! = nil {
        didSet {
            if let text = tutorialText {
                tutorialTextView.text = text
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("showDialog", sender: self)
                })
            }
        }
    }
    
    var state: UIState? {
        didSet {
            if let unwrappedState = state {
                pModel.observeState(unwrappedState)
                unwrappedState.setup(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cards.append(card0)
        cards.append(card1)
        cards.append(card2)
        cards.append(card3)
        cardConstraints.append(card0TopConstraint)
        cardConstraints.append(card1TopConstraint)
        cardConstraints.append(card2TopConstraint)
        cardConstraints.append(card3TopConstraint)
        pcards.append(pcard41)
        pcards.append(pcard32)
        pcards.append(pcard31)
        pcards.append(pcard23)
        pcards.append(pcard22)
        pcards.append(pcard21)
        pcards.append(pcard14)
        pcards.append(pcard13)
        pcards.append(pcard12)
        pcards.append(pcard11)
        oppcards.append(oppCard0)
        oppcards.append(oppCard1)
        oppcards.append(oppCard2)
        oppcards.append(oppCard3)
        oppcardConstraints.append(oppCard0TopConstraint)
        oppcardConstraints.append(oppCard1TopConstraint)
        oppcardConstraints.append(oppCard2TopConstraint)
        oppcardConstraints.append(oppCard3TopConstraint)
        
        state = .MemorizeFirst
    }
    
    func showHandCard(ndx:Int) {
        let playerCard = game.players[.Left]!.hand[ndx]
        cards[ndx].setBackgroundImage(playerCard.image, forState: .Normal)
    }
    
    func hideHandCard(ndx:Int) {
        cards[ndx].setBackgroundImage(UIImage(named:"CardBack"), forState: .Normal)
    }
    
    func raiseHandCard(ndx:Int) {
        cardConstraints[ndx].constant = 8
    }
    
    func lowerHandCard(ndx:Int) {
        cardConstraints[ndx].constant = 40
    }
    
    func showOppHandCard(ndx:Int) {
        let playerCard = game.players[.Right]!.hand[ndx]
        print("lHand:\(game.players[.Left]!.hand) rHand:\(game.players[.Right]!.hand)")
        oppcards[ndx].image = playerCard.image
    }
    
    func hideOppHandCard(ndx:Int) {
        oppcards[ndx].image = UIImage(named:"CardBack")
    }
    
    func raiseOppHandCard(ndx:Int) {
        oppcardConstraints[ndx].constant = 8
    }
    
    func lowerOppHandCard(ndx:Int) {
        oppcardConstraints[ndx].constant = 40
    }
    
    func getCardNdx(c:UIButton) -> Int {
        for i in 0..<cards.count {
            if c == cards[i] {
                return i
            }
        }
        return -1
    }
    
    func setABTitles(ab1:String?, _ ab2:String?) {
        if let ab1S = ab1 {
            actionButton1.setTitle(ab1S, forState: .Normal)
            actionButton1.hidden = false;
        } else {
            actionButton1.hidden = true;
        }
        if let ab2S = ab2 {
            actionButton2.setTitle(ab2S, forState: .Normal)
            actionButton2.hidden = false;
        } else {
            actionButton2.hidden = true;
        }
    }
    
    func finishGame() {
        let lScore = game.players[.Left]!.score
        let rScore = game.players[.Right]!.score
        if lScore >= rScore {
            performSegueWithIdentifier("showWin", sender: self)
        } else {
            performSegueWithIdentifier("showLoss", sender: self)
        }
    }
    
    func hidePopover() {
        if self.presentedViewController != nil {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func clickCard(sender: UIButton) {
        hidePopover()
        state!.clickCard(self, ndx: getCardNdx(sender))
    }
    
    @IBAction func clickAB1(sender: UIButton) {
        hidePopover()
        state!.clickAB1(self)
    }
    @IBAction func clickAB2(sender: UIButton) {
        hidePopover()
        state!.clickAB2(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender:sender)
        
        if segue.identifier == "showDialog" {
            segue.destinationViewController.popoverPresentationController!.passthroughViews = [card0,card1,card2,card3,actionButton1,actionButton2]
            segue.destinationViewController.popoverPresentationController?.sourceRect = portraitButton.frame
            if let tvc = segue.destinationViewController as? DialogViewController {
                if let ppc = tvc.popoverPresentationController {
                    ppc.delegate = self
                }
                tvc.text = tutorialText
            }
        } else if segue.identifier == "showLoss" || segue.identifier == "showWin" {
            if let rvc = segue.destinationViewController as? ResultViewController {
                rvc.lScore = game.players[.Left]!.score
                rvc.rScore = game.players[.Right]!.score
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

extension Card {
    var rankName:String {
        return (rank == 1) ? "ace" : (rank >= 2 && rank <= 10) ? "\(rank)" : (rank == 11) ? "jack" : (rank == 12) ? "queen" : (rank == 13) ? "king" : "???"
    }
    
    var suitName:String {
        return (suit == 1) ? "hearts" : (suit == 2) ? "diamonds" : (suit == 3) ? "clubs" : (suit == 4) ? "spades" : "???"
    }
    
    var image:UIImage? {
        return UIImage(named:"\(rankName)_of_\(suitName)")
    }
}
