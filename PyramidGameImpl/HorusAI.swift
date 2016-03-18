
import Foundation

class HorusAI: SekhmetAI {
    override func name()->String {
        return "Horus"
    }
    
    override func iconName()->String {
        return "HorusFace"
    }
    
    override func textInitRemember()->String { return "Welcome challenger. Do try to remember the following cards." }
    override func textPlayerDoYouHaveA(cardName:String)->String { return "well, are you holding a \(cardName)?" }
    override func textPlayerSelectCard()->String { return "Pick the card. Surely you have not forgotten where it was." }
    override func textPlayerCallBase()->String { return "I do not trust you! You are bluffing." }
    override func textPlayerCallCorrect(points:Int)->String { return "The great Horos was right as always. I get \(points) points." }
    override func textPlayerCallIncorrect(points:Int)->String { return "You were telling the truth? Interesting. You get \(points) points." }
    override func textPlayerNoCall(points:Int)->String { return "I believe you. You get \(points) points." }
    override func textPlayerNewCard()->String { return "This is your new card. If you hope to beat me, I suggest you remember it well." }
    override func textAIPass(cardName:String)->String { return "It is now my turn. Unfortunately I do not have a \(cardName)." }
    override func textAIPlay(cardName:String)->String { return "It is now my turn. I do have a \(cardName).\n\nSurely, you believe me?" }
    override func textAICallCorrect(points:Int)->String { return "Hmm. You caught me in my lie. You get \(points) points." }
    override func textAICallIncorrect(points:Int)->String { return "I told you I was telling the truth. I get \(points) points." }
    override func textAINoCall(points:Int)->String { return "Very well. I get \(points) points." }
    override func textAINewCard()->String { return "Now I get a new card." }
}
