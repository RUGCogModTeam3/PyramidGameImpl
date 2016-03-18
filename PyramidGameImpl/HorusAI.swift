
import Foundation

class HorusAI: SekhmetAI {
    override func name()->String {
        return "Horus"
    }
    
    override func iconName()->String {
        return "HorusFace"
    }
    
    override func textInitRemember()->String { return "Hello. Remember these cards, if you can." }
    override func textPlayerDoYouHaveA(cardName:String)->String { return "Hmm. Do you have a \(cardName)?" }
    override func textPlayerSelectCard()->String { return "Choose your card." }
    override func textPlayerCallBase()->String { return "That cannot be right. I believe you are bluffing." }
    override func textPlayerCallCorrect(points:Int)->String { return "I was correct, as expected. I get \(points) points." }
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
