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

protocol PyramidAI {
    func callBullshit(lastRevealedCard:Card) -> Bool
    
    func getPlay(lastRevealedCard:Card) -> Int?
    
    func observeState(state:UIState)
    
    // observe a card in the model's hand.
    func observeHandCard(card:Card, ndx:Int)
    
    // Observe a card not in the model's hand.
    func observeCard(card:Card)
    
    func observePlayerBluff(didBluff:Bool)
    
    func observePlayerBluffCall(choice: Bool)
    
    func textInitRemember()->String
    func textPlayerDoYouHaveA(cardName:String)->String
    func textPlayerSelectCard()->String
    func textPlayerCallBase()->String
    func textPlayerCallCorrect(points:Int)->String
    func textPlayerCallIncorrect(points:Int)->String
    func textPlayerNoCall(points:Int)->String
    func textPlayerNewCard()->String
    func textAIPass(cardName:String)->String
    func textAIPlay(cardName:String)->String
    func textAICallCorrect(points:Int)->String
    func textAICallIncorrect(points:Int)->String
    func textAINoCall(points:Int)->String
    func textAINewCard()->String
    
    func name()->String
    func iconName()->String
}