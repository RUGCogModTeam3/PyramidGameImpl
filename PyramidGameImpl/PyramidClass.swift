
import Foundation

class PyramidClass: Model {
    var cardCount = [Int](count:13, repeatedValue: 0)
    
    override init(){
        super.init()
        for i in 0..<13{
            let count = Chunk(s:"count",m:self)
            count.setSlot("isa", value: "cardcount")
            count.setSlot("cardrank", value: "\(i)")
            count.setSlot("counts", value: "0")
            self.dm.addToDM(count)
        }
    }
    
    // Store a card in the model's hand. Automatically calls storeCard (see below)
    func storeModelCard(card: Card, ndx: Int){
        let cardchunk = Chunk(s:"modelcard",m:self)
        cardchunk.setSlot("isa", value: "modelcard")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        cardchunk.setSlot("location",value: "\(ndx)")
        self.dm.addToDM(cardchunk)
        storeCard(card)
    }
    
    // Store any card seen in the game
    func storeCard(card: Card){
        let cardchunk = Chunk(s:"modelcard",m:self)
        cardchunk.setSlot("isa", value: "card")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        self.dm.addToDM(cardchunk)
        cardCount[card.rank-1]+=1
        let count = Chunk(s:"count",m:self)
        count.setSlot("isa", value: "cardcount")
        count.setSlot("cardrank", value: "\(card.rank)")
        count.setSlot("counts", value: "\(cardCount[card.rank-1])")
        self.dm.addToDM(count)
    }
    
    // Record if the player did bluff
    func storePlayerBluff(choice: Bool){
        let cardchunk = Chunk(s:"playerbluff",m:self)
        cardchunk.setSlot("isa", value: "didbluff")
        cardchunk.setSlot("value", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Record if the player calls a bluff
    func storePlayerBluffCall(choice: Bool) {
        let cardchunk = Chunk(s:"modelbluff",m:self)
        cardchunk.setSlot("isa", value: "bluff")
        cardchunk.setSlot("called", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Does the model call bullshit on the player?
    func callBullshit(lastRevealedCard: Card) -> Bool {
        self.modifyLastAction("userplay", value: String(lastRevealedCard.rank))
        self.run()
        return self.lastAction("decision")! == "true"
    }
    
    // What action will the model take?
    func getPlay(lastRevealedCard: Card)->Int?{
        self.modifyLastAction("card", value: String(lastRevealedCard.rank))
        self.run()
        switch(self.lastAction("location")!){
        case "0":
            return 1
        case "1":
            return 2
        case "2":
            return 3
        case "3":
            return 4
        case "4":
            return nil
        case "5":
            return Int(arc4random_uniform(4))
        default:
            return Int(arc4random_uniform(4))
        }
    }
    
}
