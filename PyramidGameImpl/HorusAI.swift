
import Foundation

class HorusAI: SekhmetAI {
    override init(game: PyramidGame) {
        super.init(game: game)
        self.dm.baseLevelDecay = 0.5
        self.bluffProbabilities = [0,100,20,15,55,35]
        self.callBluffProbabilities = [0,75,60,65,60,30,50]
    }
    
    override func name()->String {
        return "Horus"
    }
    
    override func iconName()->String {
        return "HorusFace"
    }
    
    override func observeState(state:UIState) {
        self.time += 5
        switch state {
        case .HumanYesNo:
            for i in 0..<4 {
                rehearse(i)
            }
        case .ModelSelect:
            for i in 0..<4 {
                rehearse(i)
            }
        default: break
        }
    }
    
    
    override func textInitRemember()->String { return "Welcome challenger. Do try to remember the\nfollowing cards." }
    override func textPlayerDoYouHaveA(cardName:String)->String { return "Well, are you holding \(aOrAn(cardName))?" }
    override func textPlayerSelectCard()->String { return "Pick the card. Surely you have not forgotten where\nit was." }
    override func textPlayerCallBase()->String { return "I do not trust you! You are bluffing!" }
    override func textPlayerCallCorrect(points:Int)->String { return "The great Horus was right, as always. I get \(plural(points,"point"))." }
    override func textPlayerCallIncorrect(points:Int)->String { return "You were telling the truth? Interesting. You get \(plural(points,"point"))." }
    override func textPlayerNoCall(points:Int)->String { return "I believe you. You get \(plural(points,"point"))." }
    override func textPlayerNewCard()->String { return "This is your new card. If you hope to beat me, I suggest\nyou remember it well." }
    override func textAIPass(cardName:String)->String { return "It is now my turn. Unfortunately I do not have \(aOrAn(cardName))." }
    override func textAIPlay(cardName:String)->String { return "It is now my turn. I do have \(aOrAn(cardName)).\n\nDo you think I would lie?" }
    override func textAICallCorrectBluff(points:Int)->String { return "I may have been bending the truth a little. You get\n\(plural(points,"point"))." }
    override func textAICallCorrectMistake(points:Int)->String { return "I seem to have misremembered. I will not do\nthat again. You get \(plural(points,"point"))." }
    override func textAICallIncorrect(points:Int)->String { return "I told you I was telling the truth. I get \(plural(points,"point"))." }
    override func textAINoCall(points:Int)->String { return "Very well. I get \(plural(points,"point"))." }
    override func textAINewCard()->String { return "Great. Another beautiful card to add to my collection." }
}
