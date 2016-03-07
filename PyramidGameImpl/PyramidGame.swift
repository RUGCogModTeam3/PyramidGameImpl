//import Foundation
#if os(Linux)
    import Glibc
    import SwiftShims
#else
    import Darwin
#endif

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

func cs_arc4random_uniform(upperBound: UInt32) -> UInt32 {  
    #if os(Linux)
        return _swift_stdlib_arc4random_uniform(upperBound)
    #else
        return arc4random_uniform(upperBound)
    #endif
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in 0..<count - 1 {
            let j = Int(cs_arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class Card : CustomStringConvertible {
   let rank: Int
   let suit: Int

   init(rank:Int, suit:Int) {
      self.rank = rank
      self.suit = suit
   }

   var description:String {
      return "(\(rank),\(suit))"
   }
}

class Deck {
   var cards = [Card]()

   init(numRanks: Int, numSuits: Int) {
      for rank in 1...numRanks {
         for suit in 1...numSuits {
            cards.append(Card(rank:rank, suit:suit))
         }
      }
   }

   func shuffle() {
      cards.shuffleInPlace()
   }

   func dealCard() -> Card? {
      return cards.popLast()
   }

   func returnCard(card:Card) {
      cards.append(card)
   }

   func replaceCard(card:Card) -> Card {
      returnCard(card)
      shuffle()
      return dealCard()!
   }
}

class Pyramid : CustomStringConvertible {
   private class PyramidCard {
      var card: Card
      var isFlipped: Bool = false

      init(card:Card) {
         self.card = card
      }
   }

   private var cards = [[PyramidCard]]()
   let rows:Int
   var currRow:Int = 0
   var currCol:Int = -1

   init(rows:Int, deck:Deck) {
      self.rows = rows
      for row in 0..<rows {
         var pyramidRow = [PyramidCard]()
         for var col = 0; isValidNdx(row, col); col += 1 {
            let card = deck.dealCard()!
            pyramidRow.append(PyramidCard(card:card))
         }
         cards.append(pyramidRow)
      }
   }

   func isValidNdx(row:Int, _ col:Int) -> Bool {
      return row >= 0 && col >= 0 && col <= rows-row-1
   }

   func getCard(row: Int, _ col: Int) -> Card? {
      if !isValidNdx(row, col) || !cards[row][col].isFlipped {
         return nil
      }
      return cards[row][col].card
   }

   func flipCard() -> Card? {
      currCol += 1
      if !isValidNdx(currRow, currCol) {
         currRow += 1
         currCol = 0
      }
      if !isValidNdx(currRow, currCol) {
         currRow -= 1
         return nil
      }
      cards[currRow][currCol].isFlipped = true
      return cards[currRow][currCol].card
   }

   func getLastFlippedCard() -> Card {
      return cards[currRow][currCol].card
   }

   func rowValue() -> Int {
      return currRow+1
   }

   var description:String {
      return cards.reverse().map {
         $0.map{
            if $0.isFlipped {
               return $0.card.description
            } else {
               return "_\($0.card.description)_"
            }
         }.joinWithSeparator(",")
      }.joinWithSeparator("\n")
   }
}

enum Side {
   case Left, Right

   func otherSide() -> Side {
      switch self {
      case .Left: return .Right
      case .Right: return .Left
      }
   }
}

class PyramidGame {
   enum PyramidHalfState {
      case CardSelect, CallBullshit(cardNdx:Int), Finished
   }

   var players = [Side: Player]()
   var halfStates = [Side: PyramidHalfState]()
   var deck:Deck
   var handSize:Int
   var pyramid:Pyramid

   init(deck:Deck, pyramid:Pyramid, handSize:Int) {
      self.deck = deck
      self.pyramid = pyramid
      self.handSize = handSize

      self.players[.Left] = Player(game:self, deck:deck, handSize:handSize)
      self.players[.Right] = Player(game:self, deck:deck, handSize:handSize)

      self.halfStates[.Left] = .Finished
      self.halfStates[.Right] = .Finished
   }

   convenience init(numRanks:Int, numSuits:Int, pyramidRows:Int, handSize:Int) {
      let d = Deck(numRanks:numRanks, numSuits:numSuits)
      d.shuffle()
      let p = Pyramid(rows:pyramidRows, deck:d)

      self.init(deck:d, pyramid:p, handSize:handSize)
   }

   func nextTurn() -> Card? {
      switch (halfStates[.Left]!, halfStates[.Right]!) {
         case (.Finished, .Finished): break
         default: return nil
      }
      let result = pyramid.flipCard()
      if let _ = result {
         halfStates[.Left] = .CardSelect
         halfStates[.Right] = .CardSelect
      }
      return result
   }

   func selectCard(side:Side, ndx:Int?) -> Bool {
      switch halfStates[side]! {
      case .CardSelect:
         if let actualNdx = ndx {
            if actualNdx < 0 || actualNdx >= handSize {
               return false
            }
            halfStates[side] = .CallBullshit(cardNdx:actualNdx)
         } else {
            halfStates[side] = .Finished
         }
         return true
      default:
         return false
      }
   }

   func callBullshit(side:Side, call:Bool) -> Bool {
      switch halfStates[side]! {
      case let .CallBullshit(ndx):
         if !call {
            players[side]!.score += pyramid.rowValue()
         } else {
            let winningSide = (players[side]!.hand[ndx].rank == pyramid.getLastFlippedCard().rank) ? side : side.otherSide()
            players[winningSide]!.score += 2*pyramid.rowValue()
         }
         halfStates[side] = .Finished
         players[side]!.hand[ndx] = self.deck.dealCard()!
         return true
      default:
         return false
      }
   }
}

class Player {
   var score: Int = 0
   var hand = [Card]()
   let game:PyramidGame

   init(game:PyramidGame, deck:Deck, handSize:Int) {
      self.game = game
      for _ in 1...handSize {
         hand.append(deck.dealCard()!)
      }
   }
}

//var game = PyramidGame(numRanks:10, numSuits:4, pyramidRows:3, handSize:4)
//for _ in 1...7 {
//   print("\(game.pyramid)")
//   print("lScore: \(game.players[.Left]!.score)\t rScore: \(game.players[.Right]!.score)")
//   print("game.nextTurn: \(game.nextTurn())")
//   print("lHand: \(game.players[.Left]!.hand)")
//   print("rHand: \(game.players[.Right]!.hand)")
//   let s = game.selectCard(.Left, ndx:0) && game.selectCard(.Right, ndx:0) && game.callBullshit(.Left, call:true) && game.callBullshit(.Right, call:true)
//   print("----- success: \(s) -----")
//}
