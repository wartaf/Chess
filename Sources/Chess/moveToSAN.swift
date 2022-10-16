//
//  moveToSAN.swift
//  Chess
//
//  Created by Harry Pantaleon on 8/14/22.
//

import Foundation

extension Chess {
    func moveToSAN(move: Move, _ sloppy: Bool) -> String {
        var output = ""
        
        if move.flag & BITS.KSIDE_CASTLE.rawValue != 0 {
            output = "O-O"
        } else if move.flag & BITS.QSIDE_CASTLE.rawValue != 0 {
            output = "O-O-O"
        } else {
            //let disambiguator = getDisambiguator( move, sloppy )
            

            if move.flag & (BITS.CAPTURE.rawValue | BITS.EP_CAPTURE.rawValue) != 0 {
                if move.pieceType.type == .Pawn {
                    output += algebraic(i: move.moveFrom).prefix(1)
                }
                output += "x"
            }
            
            output += algebraic(i: move.moveTo)
            
            if move.flag & BITS.PROMOTION.rawValue != 0 {
                output += "=" + (move.promotion?.rawValue.uppercased())!
            }
        }
        
        makeMove(move: move)
        if inCheck() {
            if inCheckmate() {
                output += "#"
            } else {
                output += "+"
            }
        }
        let _ = undoMove()
        return output
    }
    
    func moveFromSAN(san: String) -> Move? {
        // strip off any move decorations: e.g Nf3+?!
        let cleanMove = strippedSAN(san);
        
        //No Sloppy - can add sloppyMove ; see ChessJS
        
        let moves = self.generateMoves()
        let len = moves.count
        for i in 0..<len {
            if cleanMove == moves[i].SAN {
                return moves[i]
            }
        }
        return nil
    }
    
    
    func strippedSAN(_ san: String) -> String {
        return san
            .replacingOccurrences(of: "=", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[+#]?[?!]*$", with: "", options: .regularExpression)
    }
     
    
    func disambiguator(move: Move, sloppy: Bool) -> String {
        print("disambiguator implementation")
        return ""
        
        //var moves = generateMoves()
    }
}
