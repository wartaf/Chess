//
//  Model.swift
//  Chess
//
//  Created by Harry Pantaleon on 8/6/22.
//

import Foundation

extension Chess{
    public struct ChessPiece: Equatable {//: Identifiable {
        //let id = UUID()
        public var type: PieceType
        public var color: PieceColor
        
        public init (type: PieceType, color: PieceColor) {
            self.type = type
            self.color = color
        }
        
        public static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
            return lhs.type.rawValue == rhs.type.rawValue && lhs.color.rawValue == rhs.color.rawValue
        }
    }
    
    public enum PieceType: String{
        case King = "K", Queen = "Q", Rook = "R", Bishop = "B", Knight = "N", Pawn = "P"
    }
    
    public enum PieceColor: String {
        case white = "w", black = "b"
    }
    
    public enum Rank: Int{
        case rank1 = 7
        case rank2 = 6
        case rank3 = 5
        case rank4 = 4
        case rank5 = 3
        case rank6 = 2
        case rank7 = 1
        case rank8 = 0
    }

    public enum BITS: Int {
        case NORMAL = 1
        case CAPTURE = 2
        case BIG_PAWN = 4
        case EP_CAPTURE = 8
        case PROMOTION = 16
        case KSIDE_CASTLE = 32
        case QSIDE_CASTLE = 64
    }
    
    public struct Move{
        public let moveFrom: Int
        public let moveTo: Int
        public let pieceType: ChessPiece
        public let color: PieceColor? = nil
        public let flag: Int
        public var promotion: PieceType? = nil
        public var captured: PieceType? = nil
        
        var SAN: String {
            
            func algebraic(i: Int) -> String {
                let fileLetter = Array("abcdefgh")
                return "\(fileLetter[getFile(i)])\(8 - getRank(i).rawValue)"
            }
            func getFile(_ boardOffset: Int) -> Int {
                return boardOffset & 15
            }
            func getRank(_ boardOffset: Int) -> Rank {
                return Rank(rawValue: boardOffset >> 4)!
            }
            
            var output = ""
            
            if self.flag & BITS.KSIDE_CASTLE.rawValue != 0 {
                output = "O-O"
            } else if self.flag & BITS.QSIDE_CASTLE.rawValue != 0 {
                output = "O-O-O"
            } else {
                //let disambiguator = getDisambiguator( move, sloppy )
                
                if self.pieceType.type != .Pawn {
                    output += self.pieceType.type.rawValue.uppercased() //+ disambiguator(move: move, sloppy: sloppy)
                }
                 
                if self.flag & (BITS.CAPTURE.rawValue | BITS.EP_CAPTURE.rawValue) != 0 {
                    if self.pieceType.type == .Pawn {
                        output += algebraic(i: self.moveFrom).prefix(1)
                    }
                    output += "x"
                }
                
                output += algebraic(i: self.moveTo)
                
                if self.flag & BITS.PROMOTION.rawValue != 0 {
                    output += "=" + (self.promotion?.rawValue.uppercased())!
                }
            }
            /*
            makeMove(move: move)
            if inCheck() {
                if inCheckmate() {
                    output += "#"
                } else {
                    output += "+"
                }
            }
            let _ = undoMove()
             */
            return output
        }
    }
}
