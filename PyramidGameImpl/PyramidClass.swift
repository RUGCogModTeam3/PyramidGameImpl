
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
        for i in -1...1{
            let upper = max(ndx,(ndx+i))
            let lower = min(ndx,(ndx+i))
            let cardlocation = generateNewChunk("modelcard")
            cardlocation.setSlot("isa", value: "modelcard")
            cardlocation.setSlot("rank",value: "\(card.rank)")
            cardlocation.setSlot("lower",value: "\(lower)")
            cardlocation.setSlot("upper",value: "\(upper)")
            self.dm.addToDM(cardlocation)
        }
        storeCard(card)
    }
    
    // Store any card seen in the game
    func storeCard(card: Card){
        //let cardchunk = generateNewChunk("card") //Is there a reason we do this
        //cardchunk.setSlot("isa", value: "card")
        //cardchunk.setSlot("rank",value: "\(card.rank)")
        //self.dm.addToDM(cardchunk)
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
        cardchunk.setSlot("isa", value: "playerbluff")
        cardchunk.setSlot("didbluff", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Record if the player calls a bluff
    func storePlayerBluffCall(choice: Bool) {
        let cardchunk = generateNewChunk("modelbluff")
        cardchunk.setSlot("isa", value: "playercalledbluff")
        cardchunk.setSlot("called", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Does the model call bullshit on the player?
    func callBullshit(lastRevealedCard: Card) -> Bool {
        let rank = "\(lastRevealedCard.rank)"
        if let cardChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
            if cardChunk.slotTextValue("counts")! == "high" {
                return true
            }
        }
        
        if let bluffChunk = self.retrieve(["isa":"playerbluff"]) {
            return bluffChunk.slotTextValue("didbluff")! == "true"
        } else {
            return true
        }
    }
    
    // What action will the model take?
    func getPlay(lastRevealedCard: Card)->Int? {
        let rank = "\(lastRevealedCard.rank)"
        if let cardChunk = self.retrieve(["isa":"modelcard","rank":rank]) {
            let lower = Int(cardChunk.slotTextValue("lower")!)
            let upper = Int(cardChunk.slotTextValue("upper")!)
            if(lower<0){
                return upper
            }else if(upper>3){
                return lower
            }else{
                return arc4random_uniform(lower..upper)
            }
        } else {
            if let countChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
                if countChunk.slotTextValue("counts")! == "high" {
                    return nil
                }
            }
            
            if let bluffChunk = self.retrieve(["isa":"playercalledbluff"]) {
                if bluffChunk.slotTextValue("called")! == "true" {
                    return nil
                } else {
                    return Int(arc4random_uniform(4))
                }
            } else {
                return Int(arc4random_uniform(4))
            }
        }
    }
    
    func retrieve(slots:[String:String])->Chunk? {
        let retrieveChunk = generateNewChunk("retrieve")
        for (slot,value) in slots {
            retrieveChunk.setSlot(slot, value:value)
        }
        let (latency, resultChunk) = dm.retrieve(retrieveChunk)
        self.time += latency
        return resultChunk
    }
    
    func observeState(state:UIState) {
        self.time += 5
        switch state {
        case .HumanYesNo:
            for i in 0..<4 {
                rehearse(i)
            }
        default: break
        }
    }
    
    //Problem: how do you want to rehearse with the different ranges?
    func rehearse(ndx:Int) {
        if let chunk = self.retrieve(["isa":"modelcard", "lower":"\(ndx)", "upper":"\(ndx)"]) {
            self.dm.addToDM(chunk)
        }
    }
}

extension Chunk {
    func slotTextValue(slot: String) -> String? {
        switch slotValue(slot) {
        case let .Some(.Text(s)):
            return s
        default:
            return nil
        }
    }
}
