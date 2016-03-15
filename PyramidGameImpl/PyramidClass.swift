
import Foundation

class PyramidClass: Model {
    var cardCount = [Int](count:13, repeatedValue: 0)
    
    override init(){
        super.init()
        for i in 1...13{
            var count = Chunk(s:"count",m:self)
            count.setSlot("isa", value: "cardcount")
            count.setSlot("cardrank", value: "\(i)")
            count.setSlot("counts", value: "0")
            self.dm.addToDM(count)
        }
    }
    
    func storeModelCard(card: Card){
        let cardchunk = Chunk(s:"modelcard",m:self)
        cardchunk.setSlot("isa", value: "modelcard")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        cardchunk.setSlot("location",value: "\(card.rank)")
        self.dm.addToDM(cardchunk)
        
    }
    
    func storeCard(card: Card){
        let cardchunk = Chunk(s:"modelcard",m:self)
        cardchunk.setSlot("isa", value: "card")
        cardchunk.setSlot("rank",value: "\(card.rank)")
        self.dm.addToDM(cardchunk)
        cardCount[card.rank]+=1
        let count = Chunk(s:"count",m:self)
        count.setSlot("isa", value: "cardcount")
        count.setSlot("cardrank", value: "\(card.rank)")
        count.setSlot("counts", value: "\(cardCount[card.rank])")
        self.dm.addToDM(count)
    }
    
    func storeBluff(param: String, choice: String){
        if(param == "player"){
            let cardchunk = Chunk(s:"playerbluff",m:self)
            cardchunk.setSlot("isa", value: "didbluff")
            cardchunk.setSlot("value", value: choice)
            self.dm.addToDM(cardchunk)
        }else{
            let cardchunk = Chunk(s:"modelbluff",m:self)
            cardchunk.setSlot("isa", value: "bluff")
            cardchunk.setSlot("called", value: choice)
            self.dm.addToDM(cardchunk)
        }
    }
    
    //func callBullshit() -> Bool {
      //  return arc4random_uniform(2) == 1
    //}
    
    func callBullshit() -> Bool{
        return self.lastAction("decision")! == "yes"
    }
    
    func getPlay()->Int?{
        switch(self.lastAction("location")!){
        case ("0"):
            return 1
        case ("1"):
            return 2
        case ("2"):
            return 3
        case ("3"):
            return 4
        case ("4"):
            return nil
        case ("5"):
            return Int(arc4random_uniform(4))
        default:
            return Int(arc4random_uniform(4))
        }
    }
    
    func inputPlay(card: Card, param: String){
        var action: String
        if(param=="userplay"){
            action = "userplay"
        }else{
            action = "card"
        }
        self.modifyLastAction(action, value: String(card.rank))
    }
    
}
