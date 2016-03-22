//
//  ViewController.swift
//  PyramidGameImpl
//
//  Created by Alex de Vries on 3/7/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit



enum UIState {
    case MemorizeFirst, HumanYesNo, HumanSelect, HumanBS(ndx:Int), HumanNewCard(ndx:Int), ModelSelect, ModelPass, ModelBS(ndx:Int), ModelPostBS(ndx:Int, call:Bool), ModelNewCard(ndx:Int), Finished;
    
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
            
        case let .ModelPostBS(ndx, _):
            c.state = .ModelNewCard(ndx:ndx)
            
        case .ModelNewCard:
            c.state = .HumanYesNo
            
        case .Finished:
            c.state = .Finished
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
                c.raiseOppHandCard(i)
                c.opponent.observeHandCard(c.game.players[.Right]!.hand[i], ndx:i)
            }
            c.setABTitles("Next", nil)
            c.tutorialText = c.opponent.textInitRemember()
            
        case .HumanYesNo:
            if let nextCard = c.game.nextTurn() {
                for i in 0..<4 {
                    c.hideHandCard(i)
                    c.lowerHandCard(i)
                    c.hideOppHandCard(i)
                    c.lowerOppHandCard(i)
                }
                c.setABTitles("Yes/Bluff", "No")
                c.opponent.observeCard(nextCard)
                c.showPcard()
                c.tutorialText = c.opponent.textPlayerDoYouHaveA(nextCard.rankName)
            } else {
                c.state = .Finished
            }
            
        case .HumanSelect:
            c.setABTitles(nil, nil)
            c.tutorialText = c.opponent.textPlayerSelectCard()
            
        case let .HumanBS(ndx):
            let lPreScore = c.game.players[.Left]!.score
            let rPreScore = c.game.players[.Right]!.score
            c.setABTitles("Next", nil)
            let callBS = c.opponent.callBullshit(c.game.pyramid.getLastFlippedCard())
            var baseText = ""
            if callBS {
                baseText = c.opponent.textPlayerCallBase()+"\n\n"
                c.showHandCard(ndx)
                c.opponent.observeCard(c.game.players[.Left]!.hand[ndx])
                c.game.callBullshit(.Left, call:callBS)
                let lDiff = c.game.players[.Left]!.score - lPreScore
                let rDiff = c.game.players[.Right]!.score - rPreScore
                if lDiff > 0 {
                    c.opponent.observePlayerBluff(false)
                    baseText = baseText + c.opponent.textPlayerCallIncorrect(lDiff)
                } else {
                    c.opponent.observePlayerBluff(true)
                    baseText = baseText + c.opponent.textPlayerCallCorrect(rDiff)
                }
            } else {
                baseText = c.opponent.textPlayerNoCall(c.game.pyramid.rowValue())
                c.game.callBullshit(.Left, call:callBS)
            }
            c.tutorialText = baseText
            
        case let .HumanNewCard(ndx):
            c.setABTitles("Next", nil)
            c.tutorialText = c.opponent.textPlayerNewCard()
            c.replaceHandCard(ndx)
            
        case .ModelSelect:
            let choice = c.opponent.getPlay(c.game.pyramid.getLastFlippedCard())
    
            c.game.selectCard(.Right, ndx: choice)
            if let ndx = choice {
                c.state = .ModelBS(ndx:ndx)
            } else {
                c.state = .ModelPass
            }
        
        case .ModelPass:
            c.setABTitles("Next", nil)
            c.tutorialText = c.opponent.textAIPass(c.game.pyramid.getLastFlippedCard().rankName)
            
        case let .ModelBS(ndx):
            c.setABTitles("Yes", "No")
            c.tutorialText = c.opponent.textAIPlay(c.game.pyramid.getLastFlippedCard().rankName)
            c.raiseOppHandCard(ndx)
            
        case let .ModelPostBS(ndx, call):
            let lPreScore = c.game.players[.Left]!.score
            let rPreScore = c.game.players[.Right]!.score
            if call {
                c.showOppHandCard(ndx)
            }
            c.game.callBullshit(.Right, call:call)
            c.opponent.observeHandCard(c.game.players[.Right]!.hand[ndx], ndx:ndx)
            c.opponent.observePlayerBluffCall(call)
            c.setABTitles("Next", nil)
            var textBase = ""
            if call {
                let lDiff = c.game.players[.Left]!.score - lPreScore
                let rDiff = c.game.players[.Right]!.score - rPreScore
                if lDiff > 0 {
                    textBase = c.opponent.textAICallCorrect(lDiff)
                } else {
                    textBase = c.opponent.textAICallIncorrect(rDiff)
                }
            } else {
                textBase = c.opponent.textAINoCall(c.game.pyramid.rowValue())
            }
            c.tutorialText = textBase
            
        case let .ModelNewCard(ndx):
            c.setABTitles("Next", nil)
            c.replaceOppHandCard(ndx)
            c.tutorialText = c.opponent.textAINewCard()
            
        case .Finished:
            c.finishGame()
            c.setABTitles("Continue", nil)
        }
        c.lscore.setTitle("\(c.game.players[.Left]!.score)", forState: .Normal)
        c.rscore.setTitle("\(c.game.players[.Right]!.score)", forState: .Normal)
    }
}

class PyramidViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    //Initialize a pyramidmodel and load the right model. Not sure why it gives a warning though
    var game: PyramidGame!
    var opponent: PyramidAI!
    let animationDuration = 0.75
    let cardOffset:CGFloat = 32
    let cardBackImage = UIImage(named:"cardbackv2")
    
    
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
    
    @IBOutlet weak var oppCard0: UIImageView!
    @IBOutlet weak var oppCard1: UIImageView!
    @IBOutlet weak var oppCard2: UIImageView!
    @IBOutlet weak var oppCard3: UIImageView!
    
    @IBOutlet weak var oppLabel: UILabel!
    @IBOutlet weak var oppFace: UIImageView!
    
    var cards = [UIButton!]()
    var revealedCards = [Bool](count:4, repeatedValue:false)
    var oppcards = [UIImageView!]()
    var revealedOppcards = [Bool](count:4, repeatedValue:false)
    var pcards = [UIImageView!]()
    
    var tutorialText: String! = nil {
        didSet {
            if let text = tutorialText {
                let c = self
                tutorialTextView.text = text
                dispatch_async(dispatch_get_main_queue()) {
                    c.delayUntil({ return c.presentedViewController == nil }) {
                        c.performSegueWithIdentifier("showDialog", sender: c)
                    }
                }
            }
        }
    }
    
    var state: UIState? {
        didSet {
            if let unwrappedState = state {
                opponent.observeState(unwrappedState)
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
        
        oppFace.image = UIImage(named: opponent.iconName())
        oppLabel.text = opponent.name()
        
        state = .MemorizeFirst
    }
    
    func showPcard() {
        let pcard = pcards.popLast()!
        let newCard = game.pyramid.getLastFlippedCard()
        UIView.transitionWithView(pcard, duration: animationDuration, options: .TransitionFlipFromLeft, animations: { pcard.image = newCard.image }, completion: nil)
    }
    
    func showHandCard(ndx:Int) {
        let playerCard = game.players[.Left]!.hand[ndx]
        let cardView = cards[ndx]
        UIView.transitionWithView(cardView, duration: animationDuration, options: .TransitionFlipFromLeft, animations: { cardView.setBackgroundImage(playerCard.image, forState: .Normal) }, completion: nil)
        revealedCards[ndx] = true
    }
    
    func hideHandCard(ndx:Int) {
        if revealedCards[ndx] {
            let cardView = cards[ndx]
            UIView.transitionWithView(cardView, duration: animationDuration, options: .TransitionFlipFromRight, animations: { cardView.setBackgroundImage(self.cardBackImage, forState: .Normal) }, completion: nil)
            revealedCards[ndx] = false
        }
    }
    
    func raiseHandCard(ndx:Int) {
        let cardView = cards[ndx]
        UIView.animateWithDuration(animationDuration, animations: {
            cardView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func lowerHandCard(ndx:Int) {
        let cardView = cards[ndx]
        UIView.animateWithDuration(animationDuration, animations: {
            cardView.transform = CGAffineTransformMakeTranslation(0, self.cardOffset)
        })
    }
    
    func replaceHandCard(ndx:Int) {
        let playerCard = game.players[.Left]!.hand[ndx]
        let cardView = cards[ndx]
        UIView.animateWithDuration(animationDuration/2, delay: 0, options: .CurveLinear, animations: { cardView.transform = CGAffineTransformMakeTranslation(0, cardView.frame.size.height+10) }) { _ in
            cardView.setBackgroundImage(playerCard.image, forState: .Normal)
            UIView.animateWithDuration(self.animationDuration/2, delay: 0.1, options: .CurveLinear, animations: {cardView.transform = CGAffineTransformMakeTranslation(0, 0)}, completion: nil)
        }
        revealedCards[ndx] = true
    }
    
    func showOppHandCard(ndx:Int) {
        let playerCard = game.players[.Right]!.hand[ndx]
        let cardView = oppcards[ndx]
        UIView.transitionWithView(cardView, duration: animationDuration, options: .TransitionFlipFromLeft, animations: { cardView.image = playerCard.image }, completion: nil)
        oppcards[ndx].image = playerCard.image
        revealedOppcards[ndx] = true
    }
    
    func hideOppHandCard(ndx:Int) {
        if revealedOppcards[ndx] {
            let cardView = oppcards[ndx]
            UIView.transitionWithView(cardView, duration: animationDuration, options: .TransitionFlipFromRight, animations: { cardView.image = self.cardBackImage }, completion: nil)
            revealedOppcards[ndx] = false
        }
    }
    
    func raiseOppHandCard(ndx:Int) {
        let cardView = oppcards[ndx]
        UIView.animateWithDuration(animationDuration, animations: {
            cardView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func lowerOppHandCard(ndx:Int) {
        let cardView = oppcards[ndx]
        UIView.animateWithDuration(animationDuration, animations: {
            cardView.transform = CGAffineTransformMakeTranslation(0, -self.cardOffset)
        })
    }
    
    func replaceOppHandCard(ndx:Int) {
        let cardView = oppcards[ndx]
        UIView.animateWithDuration(animationDuration/2, delay: 0, options: .CurveLinear, animations: { cardView.transform = CGAffineTransformMakeTranslation(0, -cardView.frame.size.height-10) }) { _ in
            cardView.image = self.cardBackImage
            UIView.animateWithDuration(self.animationDuration/2, delay: 0.1, options: .CurveLinear, animations: {cardView.transform = CGAffineTransformMakeTranslation(0, 0)}, completion: nil)
        }
        revealedOppcards[ndx] = false
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
    
    func delayUntil(condition:()->Bool,_ action:()->Void) {
        if !condition() {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC)),dispatch_get_main_queue(), { self.delayUntil(condition, action)})
        } else {
            action()
        }
    }
    
    func finishGame() {
        delayUntil({ return self.presentedViewController == nil }) {
            let lScore = self.game.players[.Left]!.score
            let rScore = self.game.players[.Right]!.score
            if lScore >= rScore {
                self.performSegueWithIdentifier("showWin", sender: self)
            } else {
                self.performSegueWithIdentifier("showLoss", sender: self)
            }
        }
    }
    
    func hidePopover() {
        let pvc = self.presentedViewController
        //TODO: There's probably still a race condition here...
        if pvc != nil {
            pvc!.dismissViewControllerAnimated(true, completion: nil)
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
