
import Foundation

class SekhmetAI: Model, PyramidAI {
    var cardCount = [Int](count:13, repeatedValue: 0)
    let game: PyramidGame
    var bluffProbabilities = [10,90,30,30,65,55]
    var callBluffProbabilities = [10,70,60,65,60,35,50]
    var didLastBluff = false
    
    init(game: PyramidGame){
        self.game = game
        super.init()
        self.dm.baseLevelDecay = 0.7
        for i in 1...13{
            let count = generateNewChunk("count")
            count.setSlot("isa", value: "cardcount")
            count.setSlot("cardrank", value: "\(i)")
            count.setSlot("counts", value: "low")
            self.dm.addToDM(count)
        }
    }
    
    // observe a card in the model's hand. Automatically calls observeCard (see below)
    func observeHandCard(card: Card, ndx: Int){
        print(card.rank, ndx)
        for i in -1...1{
            let upper = max(ndx,(ndx+i))
            let lower = min(ndx,(ndx+i))
            let cardlocation = generateNewChunk("modelcard")
            cardlocation.setSlot("isa", value: "modelcard")
            cardlocation.setSlot("rank",value: "\(card.rank)")
            cardlocation.setSlot("lower",value: "\(lower)")
            cardlocation.setSlot("upper",value: "\(upper)")
            let cardColor = (card.suit-1)/2
            cardlocation.setSlot("color",value:"\(cardColor)")
            self.dm.addToDM(cardlocation)
            self.dm.addToDM(cardlocation)
        }
        observeCard(card)
    }
    
    // observe any card seen in the game
    func observeCard(card: Card){
        cardCount[card.rank-1]+=1
        let count = generateNewChunk("count")
        count.setSlot("isa", value: "cardcount")
        count.setSlot("cardrank", value: "\(card.rank)")
        count.setSlot("counts", value: "\(cardCount[card.rank-1] > 2 ? "high" : "low")")
        self.dm.addToDM(count)
    }
    
    // Record if the player did bluff
    func observePlayerBluff(choice: Bool){
        let cardchunk = generateNewChunk("playerbluff")
        cardchunk.setSlot("isa", value: "playerbluff")
        cardchunk.setSlot("didbluff", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Record if the player calls a bluff
    func observePlayerBluffCall(choice: Bool) {
        let cardchunk = generateNewChunk("modelbluff")
        cardchunk.setSlot("isa", value: "playercalledbluff")
        cardchunk.setSlot("called", value: "\(choice)")
        self.dm.addToDM(cardchunk)
    }
    
    // Does the model call bullshit on the player?
    func callBullshit(lastRevealedCard: Card) -> Bool {
        let bias = self.game.players[.Left]!.score-self.game.players[.Right]!.score
        if ((self.game.players[.Right]!.score-self.game.players[.Left]!.score)>self.game.pyramid.remainingNonBluffPoints()) {
            return makeBluffCallChoice(callBluffProbabilities[0])
        }
        let rank = "\(lastRevealedCard.rank)"
        if let cardChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
            if cardChunk.slotTextValue("counts")! == "high" {
                if let bluffChunk = self.retrieve(["isa":"playerbluff"]) {
                    if (bluffChunk.slotTextValue("didbluff")! == "true"){
                        return makeBluffCallChoice(callBluffProbabilities[1]+bias)
                    }
                    return makeBluffCallChoice(callBluffProbabilities[2]+bias)
                }
                return makeBluffCallChoice(callBluffProbabilities[3]+bias)
            }
        }
        
        if let bluffChunk = self.retrieve(["isa":"playerbluff"]) {
            if (bluffChunk.slotTextValue("didbluff")! == "true"){
                return makeBluffCallChoice(callBluffProbabilities[4]+bias)
            }
            return makeBluffCallChoice(callBluffProbabilities[5]+bias)
        }
        return makeBluffCallChoice(callBluffProbabilities[6]+bias)
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
        let probabilities = bluffProbabilities
        let rank = "\(lastRevealedCard.rank)"
        let bias = self.game.players[.Left]!.score-self.game.players[.Right]!.score
        didLastBluff = true

        if let cardChunk = self.retrieve(["isa":"modelcard","rank":rank]) {
            let color = cardChunk.slotTextValue("color")!
            print("I've retrieved color: \(color), rank: \(rank) ")
            let lower = max(Int(cardChunk.slotTextValue("lower")!)!, 0)
            let upper = min(Int(cardChunk.slotTextValue("upper")!)!,3)
            if let forget = self.retrieve(["isa":"forgetCard","rank":rank,"color":color]){
                print("Forget is \(forget) ")
                if (Int(forget.slotTextValue("location")!)! != lower) && (Int(forget.slotTextValue("location")!)! != upper){
                    let play = (lower+Int(arc4random_uniform(UInt32(1+upper-lower))))
                    print("getPlay lower:\(lower) upper:\(upper) play:\(play)")
                    didLastBluff = false
                    return play
                }
            }else{
                let play = (lower+Int(arc4random_uniform(UInt32(1+upper-lower))))
                print("getPlay lower:\(lower) upper:\(upper) play:\(play)")
                didLastBluff = false
                return play
            }
        }
        
        if ((self.game.players[.Right]!.score-self.game.players[.Left]!.score)>self.game.pyramid.remainingNonBluffPoints()) {
            let play = makeChoice(probabilities[0])
            return play
        }
        if((self.game.players[.Left]!.score-self.game.players[.Right]!.score>self.game.pyramid.remainingBluffPointsAfterStep())){
            let play = makeChoice(probabilities[1])
            return play
        }
        
        if let countChunk = self.retrieve(["isa":"cardcount","cardrank":rank]) {
            if countChunk.slotTextValue("counts")! == "high" {
                let play = makeChoice(probabilities[2]+bias)
                return play
            }
        }
        
        if let bluffChunk = self.retrieve(["isa":"playercalledbluff"]) {
            if bluffChunk.slotTextValue("called")! == "true" {
                let play = makeChoice(probabilities[3]+bias)
                return play
            } else {
                let play = makeChoice(probabilities[4]+bias)
                return play
            }
        } else {
            let play = makeChoice(probabilities[5]+bias)
            return play
        }
    }
    
    func getPlay(lastRevealedCard: Card)->Int? {
        let output = getPlayCard(lastRevealedCard)
        if let unwrappedOutput = output {
            self.forget(self.game.players[.Right]!.hand[unwrappedOutput].rank, ndx: unwrappedOutput, suit: self.game.players[.Right]!.hand[unwrappedOutput].suit)
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
        if let forget = self.retrieve(["isa":"forgetCard", "location":"\(ndx)"]){
            self.dm.addToDM(forget)
        }
    }
    
//    func forget(rank: Int, ndx: Int){
//        for (_, chunk) in self.dm.chunks {
//            if chunk.slotTextValue("isa") == "modelcard" {
//                let chunkRank = chunk.slotTextValue("rank")!
//                let chunkLower = chunk.slotTextValue("lower")!
//                let chunkUpper = chunk.slotTextValue("upper")!
//                if chunkRank == "\(rank)" && (chunkLower == "\(ndx)" || chunkUpper == "\(ndx)") {
//                    //chunk.references = max(chunk.references-self.forgetRate,0)
//                    chunk.fixedActivation = forgetActivation
//                }
//            }
//        }
//    }
    
    func forget(rank: Int, ndx: Int, suit: Int){
        let forgetChunk = generateNewChunk("forgetCard")
        forgetChunk.setSlot("isa", value: "forgetCard")
        forgetChunk.setSlot("rank", value: "\(rank)")
        forgetChunk.setSlot("location", value: "\(ndx)")
        let cardColor = (suit-1)/2
        forgetChunk.setSlot("color", value: "\(cardColor)")
        print("\(forgetChunk)")
        self.dm.addToDM(forgetChunk)
    }
    
    
    func name()->String {
        return "Sekhmet"
    }
    
    func iconName()->String {
        return "SekhmetFace"
    }
    
    func plural(count:Int, _ base:String)->String {
        return "\(count) \(base)\(count==1 ? "" : "s")"
    }
    
    func aOrAn(str:String)->String {
        let c = str[str.startIndex]
        return "a\(c=="a" || c == "8" ? "n" : "") \(str)"
    }
    
    func textInitRemember()->String { return "Welcome mortal! Remember your cards well..." }
    func textPlayerDoYouHaveA(cardName:String)->String { return "Well, human, do you have \(aOrAn(cardName))?" }
    func textPlayerSelectCard()->String { return "Select your card, mortal." }
    func textPlayerCallBase()->String { return "Show me your card! I believe you are bluffing..." }
    func textPlayerCallCorrect(points:Int)->String { return "I was right! I get \(plural(points,"point"))." }
    func textPlayerCallIncorrect(points:Int)->String { return "But you were telling the truth! You get \(plural(points,"point"))." }
    func textPlayerNoCall(points:Int)->String { return "I trust you are not bluffing... for now. You get \(plural(points,"point"))." }
    func textPlayerNewCard()->String { return "This is your new card, mortal. Remember it well." }
    func textAIPass(cardName:String)->String { return "It is now my turn... but I don't have \(aOrAn(cardName))." }
    func textAIPlay(cardName:String)->String { return "It is now my turn! I do have \(aOrAn(cardName)).\n\nDo you think I am bluffing?" }
    func textAICallCorrect(points:Int)->String { return didLastBluff ? textAICallCorrectBluff(points) : textAICallCorrectMistake(points)}
    func textAICallCorrectBluff(points:Int)->String { return "No, you caught me in my lie! You get \(plural(points,"point"))." }
    func textAICallCorrectMistake(points:Int)->String { return "What? I thought I had that card... You get \(plural(points,"point"))." }
    func textAICallIncorrect(points:Int)->String { return "Ha! I was telling the truth! I get \(plural(points,"point"))." }
    func textAINoCall(points:Int)->String { return "Very well, mortal. I get \(plural(points,"point"))." }
    func textAINewCard()->String { return "Now I get a new card." }
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
    func remainingBluffPointsAfterStep()->Int {
        var points = 0
        for (var col = currCol+1; isValidNdx(currRow, col); col++) {
            points += (currRow+1)*2
        }
        for (var offset = 1; rows-offset > currRow; offset++) {
            points += ((rows-offset+1)*offset)*2
        }
        return points
    }
}