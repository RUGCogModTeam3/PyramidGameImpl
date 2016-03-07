//
//  ViewController.swift
//  PyramidGameImpl
//
//  Created by Alex de Vries on 3/7/16.
//  Copyright © 2016 Alex de Vries. All rights reserved.
//

import UIKit

enum UIState {
    case MemorizeFirst, HumanSelect, HumanBS(ndx:Int), HumanNewCard(ndx:Int), ModelSelect, ModelBS(ndx:Int), ModelNewCard(ndx:Int);
    
    func clickAB1(c:PyramidViewController) {
        switch self {
        case .MemorizeFirst:
            for i in 0..<4 {
                c.hideHandCard(i)
            }
            c.state = .HumanSelect
        case let .HumanBS(ndx):
            c.state = .HumanNewCard(ndx:ndx)
        case let .HumanNewCard(ndx):
            c.hideHandCard(ndx)
            c.state = .HumanSelect
        default: break
        }
    }
    
    func clickAB2(c:PyramidViewController) {
        switch self {
        case HumanSelect:
            c.game.selectCard(.Left, ndx: nil)
            c.game.selectCard(.Right, ndx: nil)
            c.state = .HumanSelect
        default: break
        }
    }
    
    func clickAB3(c:PyramidViewController) {
        print("\(self): clickAB3")
    }
    
    func clickCard(c:PyramidViewController, ndx:Int) {
        switch self {
        case .HumanSelect:
            c.game.selectCard(.Left, ndx:ndx)
            c.state = .HumanBS(ndx:ndx)
        default: break
        }
    }
    
    func setup(c:PyramidViewController) {
        switch self {
        case .MemorizeFirst:
            for i in 0..<4 {
                c.showHandCard(i)
            }
            c.setABTitles("Next", nil, nil)
            c.tutorialText.text = "Welcome mortal! Remember your cards well..."
        case .HumanSelect:
            c.setABTitles("Yes (select card)", "No", nil)
            c.game.nextTurn()
            
            let nextCard = c.game.pyramid.getLastFlippedCard()
            c.pcards.popLast()!.image = nextCard.image
            c.tutorialText.text = "Well, human, do you have a \(nextCard.rankName)?"
            
        case let .HumanBS(ndx):
            let lPreScore = c.game.players[.Left]!.score
            let rPreScore = c.game.players[.Left]!.score
            c.setABTitles("Next", nil, nil)
            let callBS = c.model.callBullshit()
            c.showHandCard(ndx)
            c.game.callBullshit(.Left, call:callBS)
            var bsText = ""
            if callBS {
                bsText = "Show me your card! I believe you are bluffing...\n\n"
                let lDiff = c.game.players[.Left]!.score - lPreScore
                let rDiff = c.game.players[.Right]!.score - rPreScore
                if lDiff > 0 {
                    bsText = bsText + "But you were telling the truth! You get \(lDiff) points."
                } else {
                    bsText = bsText + "I was right! I get \(rDiff) points."
                }
            } else {
                bsText = "I trust you are not bluffing... for now. You get \(c.game.pyramid.rowValue()) points."
            }
            c.tutorialText.text = bsText
            c.game.selectCard(.Right, ndx:nil)
        case let .HumanNewCard(ndx):
            c.setABTitles("Next", nil, nil)
            c.tutorialText.text = "This is your new card, mortal. Remember it well."
            c.showHandCard(ndx)
        default: break
        }
        c.lscore.setTitle("\(c.game.players[.Left]!.score)", forState: .Normal)
        c.rscore.setTitle("\(c.game.players[.Right]!.score)", forState: .Normal)
    }
}

class PyramidViewController: UIViewController {

    var model = PyramidModel()
    var game = PyramidGame(numRanks:13, numSuits:4, pyramidRows:4, handSize:4)
    
    @IBOutlet weak var card0: UIButton!
    @IBOutlet weak var card1: UIButton!
    @IBOutlet weak var card2: UIButton!
    @IBOutlet weak var card3: UIButton!
    @IBOutlet weak var actionButton1: UIButton!
    @IBOutlet weak var actionButton2: UIButton!
    @IBOutlet weak var actionButton3: UIButton!
    @IBOutlet weak var tutorialText: UITextView!
    
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
    
    var cards = [UIButton!]()
    var pcards = [UIImageView!]()
    
    var state = UIState.MemorizeFirst {
        didSet {
            state.setup(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //model.loadModel("pyramid")
        //model.run()
        print("here1?")
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
        
        state = .MemorizeFirst
        
        print("here2?")
        gameInit()
    }
    
    func gameInit() {

    }
    
    func showHandCard(ndx:Int) {
        let playerCard = game.players[.Left]!.hand[ndx]
        cards[ndx].setBackgroundImage(playerCard.image, forState: .Normal)
    }
    
    func hideHandCard(ndx:Int) {
        cards[ndx].setBackgroundImage(UIImage(named:"CardBack"), forState: .Normal)
    }
    
    func getCardNdx(c:UIButton) -> Int {
        for i in 0..<cards.count {
            if c == cards[i] {
                return i
            }
        }
        return -1
    }
    
    func setABTitles(ab1:String?, _ ab2:String?, _ ab3:String?) {
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
        if let ab3S = ab3 {
            actionButton3.setTitle(ab3S, forState: .Normal)
            actionButton3.hidden = false;
        } else {
            actionButton3.hidden = true;
        }
    }
    
    @IBAction func clickCard(sender: UIButton) {
        state.clickCard(self, ndx: getCardNdx(sender))
    }
    
    @IBAction func clickAB1(sender: UIButton) {
        state.clickAB1(self)
    }
    @IBAction func clickAB2(sender: UIButton) {
        state.clickAB2(self)
    }
    @IBAction func clickAB3(sender: UIButton) {
        state.clickAB3(self)
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
