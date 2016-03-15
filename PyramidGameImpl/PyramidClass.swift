
import Foundation

class PyramidClass: Model {
    var cardCount = [Int](count:13, repeatedValue: 0)
    
    override init(){
        super.init()
        for i in 1...13{
            let count = generateNewChunk("count")
            count.setSlot("isa", value: "cardcount")
            count.setSlot("cardrank", value: "\(i)")
            count.setSlot("counts", value: "low")
            self.dm.addToDM(count)
        }
    }
    
    // Store a card in the model's hand. Automatically calls storeCard (see below)
    func storeModelCard(card: Card, ndx: Int){
        print(card)
        let cardchunk = generateNewChunk("modelcard")
        cardchunk.setSlot("isa", value: "modelcard")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        cardchunk.setSlot("location",value: "\(ndx)")
        self.dm.addToDM(cardchunk)
        storeCard(card)
    }
    
    // Store any card seen in the game
    func storeCard(card: Card){
        let cardchunk = generateNewChunk("modelcard")
        cardchunk.setSlot("isa", value: "card")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        self.dm.addToDM(cardchunk)
        cardCount[card.rank-1]+=1
        let count = generateNewChunk("count")
        count.setSlot("isa", value: "cardcount")
        count.setSlot("cardrank", value: "\(card.rank)")
        count.setSlot("counts", value: "\(cardCount[card.rank-1] > 2 ? "high" : "low")")
        self.dm.addToDM(count)
    }
    
    // Record if the player did bluff
    func storePlayerBluff(choice: Bool){
        let cardchunk = generateNewChunk("playerbluff")
        cardchunk.setSlot("isa", value: "didbluff")
        cardchunk.setSlot("value", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Record if the player calls a bluff
    func storePlayerBluffCall(choice: Bool) {
        let cardchunk = generateNewChunk("modelbluff")
        cardchunk.setSlot("isa", value: "bluff")
        cardchunk.setSlot("called", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Does the model call bullshit on the player?
    func callBullshit(lastRevealedCard: Card) -> Bool {
        self.buffers["action"] = generateNewChunk("action")
        self.modifyLastAction("isa", value: "userplay")
        self.modifyLastAction("rank", value: String(lastRevealedCard.rank))
        print(self.buffers)
        self.run()
        print(self.buffers)
        print("callBS? \(self.dm.chunks)")
        return self.lastAction("decision")! == "true"
    }
    
    // What action will the model take?
    func getPlay(lastRevealedCard: Card)->Int?{
        self.buffers["action"] = generateNewChunk("action")
        self.modifyLastAction("isa", value: "card")
        self.modifyLastAction("rank", value: String(lastRevealedCard.rank))
        print(self.buffers)
        self.run()
        print(self.buffers)
        switch(self.lastAction("location")!){
        case "0":
            return 0
        case "1":
            return 1
        case "2":
            return 2
        case "3":
            return 3
        case "none":
            print("none")
            return nil
        case "random":
            print("random")
            return Int(arc4random_uniform(4))
        default:
            print("default!!!!")
            return Int(arc4random_uniform(4))
        }
    }
    
}
