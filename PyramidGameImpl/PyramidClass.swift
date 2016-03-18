
import Foundation

class PyramidClass: Model {
    var cardCount = [Int](count:13, repeatedValue: 0)
    let game: PyramidGame
    let forgetRate = 5
    
    init(game: PyramidGame){
        self.game = game
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
        print(card.rank, ndx)
        for i in -1...1{
            let upper = max(ndx,(ndx+i))
            let lower = min(ndx,(ndx+i))
            let cardlocation = generateNewChunk("modelcard")
            cardlocation.setSlot("isa", value: "modelcard")
            cardlocation.setSlot("rank",value: "\(card.rank)")
            cardlocation.setSlot("lower",value: "\(lower)")
            cardlocation.setSlot("upper",value: "\(upper)")
            self.dm.addToDM(cardlocation)
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
        if ((self.game.players[.Right]!.score-self.game.players[.Left]!.score)>self.game.pyramid.remainingNonBluffPoints()) {
            return false
        }
        let rank = "\(lastRevealedCard.rank)"
        if let cardChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
            if cardChunk.slotTextValue("counts")! == "high" {
                if let bluffChunk = self.retrieve(["isa":"playerbluff"]) {
                    if (bluffChunk.slotTextValue("didbluff")! == "true"){
                        return makeBluffCallChoice(80)
                    }
                    return makeBluffCallChoice(60)
                }
                return makeBluffCallChoice(65)
            }
        }
        
        if let bluffChunk = self.retrieve(["isa":"playerbluff"]) {
            if (bluffChunk.slotTextValue("didbluff")! == "true"){
                return makeBluffCallChoice(65)
            }
            return makeBluffCallChoice(35)
        }
        
        //TODO
        return makeBluffCallChoice(50)
    }
    
    func makeChoice(bluffProbability: Int)-> Int?{
        if(Int(arc4random_uniform(100))<bluffProbability){
            return Int(arc4random_uniform(4))
        }
        return nil
    }
    
    func makeBluffCallChoice(bluffProbability: Int)-> Bool{
        if(Int(arc4random_uniform(100))<bluffProbability){
            return true
        }
        return false
    }
    
    // What action will the model take?
    //func getPlay(lastRevealedCard: Card, modelScore: Int, playerScore: Int)->Int? {
    func getPlayCard(lastRevealedCard: Card)->Int? {
        let rank = "\(lastRevealedCard.rank)"
        let bias = self.game.players[.Left]!.score-self.game.players[.Right]!.score
        if ((self.game.players[.Right]!.score-self.game.players[.Left]!.score)>self.game.pyramid.remainingNonBluffPoints()) {
            return nil
        }
        if let cardChunk = self.retrieve(["isa":"modelcard","rank":rank]) {
            let lower = max(Int(cardChunk.slotTextValue("lower")!)!, 0)
            let upper = min(Int(cardChunk.slotTextValue("upper")!)!,3)
            let play = (lower+Int(arc4random_uniform(UInt32(1+upper-lower))))
            print("getPlay lower:\(lower) upper:\(upper) play:\(play)")
            return play
        }
        if let countChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
            if countChunk.slotTextValue("counts")! == "high" {
                let play = makeChoice(25+bias)
                return play
            }
        }
        if let bluffChunk = self.retrieve(["isa":"playercalledbluff"]) {
            if bluffChunk.slotTextValue("called")! == "true" {
                let play = makeChoice(35+bias)
                return play
            } else {
                let play = makeChoice(80+bias)
                return play
            }
        } else {
            let play = makeChoice(50+bias)
            return play
        }
    }
    
    func getPlay(lastRevealedCard: Card)->Int?{
        let output = getPlayCard(lastRevealedCard)
        if let unwrappedOutput = output {
            self.forget(self.game.players[.Right]!.hand[unwrappedOutput].rank, ndx: unwrappedOutput)
        }
        return output
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
        if let chunk = self.retrieve(["isa":"modelcard", "lower":"\(ndx)"]) {
            self.dm.addToDM(chunk)
        }
        if let chunk = self.retrieve(["isa":"modelcard", "upper":"\(ndx)"]) {
            self.dm.addToDM(chunk)
        }
    }
    
    func forget(rank: Int, ndx: Int){
        for (_, chunk) in self.dm.chunks {
            if chunk.slotTextValue("isa") == "modelcard" {
                let chunkRank = chunk.slotTextValue("rank")!
                let chunkLower = chunk.slotTextValue("lower")!
                let chunkUpper = chunk.slotTextValue("upper")!
                if chunkRank == "\(rank)" && (chunkLower == "\(ndx)" || chunkUpper == "\(ndx)") {
                    chunk.references = max(chunk.references-self.forgetRate,0)
                }
            }
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

extension Pyramid {
    func remainingNonBluffPoints()->Int {
        var points = 0
        for (var col = currCol; isValidNdx(currRow, col); col++) {
            points += currRow+1
        }
        for (var offset = 1; rows-offset > currRow; offset++) {
            points += (rows-offset+1)*offset
        }
        return points
    }
}
