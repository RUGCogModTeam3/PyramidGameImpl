//
//  PGController.swift
//  Prisoner's Dilemma
//
//  Created by SoundAppraisal on 07/03/16.
//  Copyright (c) 2016 Niels Taatgen. All rights reserved.
//

import Foundation
import UIKit
class PGController: UIViewController {
    var game = PyramidGame(numRanks:10, numSuits:4, pyramidRows:3, handSize:4)
    var model: Model?
    override func viewDidLoad(){
        super.viewDidLoad()
        model!.loadModel("pyramid")
    }
    
    
}

func storeCards(cards: [Card], model:Model?){
    for card in cards{
        var cardchunk = Chunk(s:"modelcard",m:model!)
        cardchunk.setSlot("isa", value: "modelcard")
        cardchunk.setSlot("rank",value: String(card.rank))
        cardchunk.setSlot("location",value: String(card.rank))
        model!.dm.addToDM(cardchunk)
        cardchunk.setSlot("isa", value: "card")
    }
}

func getPlay(){
    switch(model!.lastAction(play)){
    case ("0"):
        return "1"
    case ("1"):
        return "2"
    case ("2"):
        return "3"
    case ("3"):
        return "4"
    case ("4"):
        return "none"
    case ("5"):
        return "random"
    }
}

func inputPlay(card: Card, param: String){
    if(param=="userplay"){
        let action = "userplay"
    }else{
        let action = "card"
    }
    model!.modifyLastAction(action, value: String(card.rank))
}