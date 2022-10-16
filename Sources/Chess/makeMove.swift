//
//  ChessMakeMove.swift
//  Chess
//
//  Created by Harry Pantaleon on 8/6/22.
//

import Foundation


extension Chess{
    public func makeMove(move: Move) {
        let us = activeColor
        let them = toggleColor(activeColor)
        push(move: move)
        
        board[move.moveTo] = board[move.moveFrom]
        board[move.moveFrom] = nil
        
        /* if ep capture, remove the captured pawn */
        if move.flag & BITS.EP_CAPTURE.rawValue != 0 {
            if activeColor == .black {
                board[move.moveTo - 16] = nil
            } else {
                board[move.moveTo + 16] = nil
            }
        }
        
        /* if pawn promotion, replace with new piece */
        if move.flag & BITS.PROMOTION.rawValue != 0 {
            board[move.moveTo] = ChessPiece(type: move.promotion!, color: us)
        }
        
        /* if we moved the king */
        if board[move.moveTo]!.type == .King {
            kingsPosition[board[move.moveTo]!.color] = move.moveTo
            
            /* if we castled, move the rook next to the king */
            if move.flag & BITS.KSIDE_CASTLE.rawValue != 0{
                let castlingTo = move.moveTo - 1
                let castlingFrom = move.moveTo + 1
                board[castlingTo] = board[castlingFrom]
                board[castlingFrom] = nil
            } else if move.flag & BITS.QSIDE_CASTLE.rawValue != 0 {
                let castlingTo = move.moveTo + 1
                let castlingFrom = move.moveTo - 2
                board[castlingTo] = board[castlingFrom]
                board[castlingFrom] = nil
            }
            
            castlingRights[us] = 0
        }
        
        /* turn off castling if rook move */
        if castlingRights[us] != 0 {
            let len = rooksPosition[us]!.count
            var i = 0
            while i < len {
                defer { i = i + 1 }
                if move.moveFrom == rooksPosition[us]![i]["square"] && castlingRights[us]! & rooksPosition[us]![i]["flag"]! != 0 {
                    castlingRights[us] = castlingRights[us]! ^ rooksPosition[us]![i]["flag"]!
                    break
                }
            }
        }
        
        /* turn off castling if we capture a rook */
        if (castlingRights[them] != 0) {
            let len = rooksPosition[us]!.count
            var i = 0
            while i < len {
                defer { i = i + 1 }
                if move.moveTo == rooksPosition[them]![i]["square"] && castlingRights[them]! & rooksPosition[them]![i]["flag"]! != 0 {
                    castlingRights[them] = castlingRights[them]! ^ rooksPosition[them]![i]["flag"]!
                    break
                }
            }
        }
        
        /* if big pawn move, update the en passant square */
        if move.flag & BITS.BIG_PAWN.rawValue != 0 {
            if activeColor == .black {
                enPassant = move.moveTo - 16
            } else {
                enPassant = move.moveTo + 16
            }
        } else {
            enPassant = -1
        }

        /* reset the 50 move counter if a pawn is moved or a piece is captured */
        if move.pieceType.type == .Pawn {
            halfMove = 0
        } else if (move.flag & (BITS.CAPTURE.rawValue | BITS.EP_CAPTURE.rawValue) != 0) {
            halfMove = 0
        } else {
            halfMove = halfMove + 1
        }
        
        if (activeColor == .black) {
            moveNumber = moveNumber + 1
        }
        
        activeColor = toggleColor(activeColor)
    }
    
    //move('Nxb7')      <- where 'move' is a case-sensitive SAN string
    public func makeMove (SAN: String) {
        if let move = moveFromSAN(san: SAN) {
            makeMove(move: move)
        }
        return
    }
    
    public func makeMove (from: String, to: String, promotion: PieceType?) {
        let moves = generateMoves()
        var moveValue: Move?
        
        /* convert the pretty move object to an ugly move object */
        let len = moves.count
        for i in 0..<len {
            let m = moves[i]
            if from == algebraic(i: m.moveFrom) && to == algebraic(i: m.moveTo) {
                if let prom = m.promotion {
                    if prom == promotion {
                        moveValue = m
                        break
                    }
                } else {
                    moveValue = m
                    break
                }
                
            }
        }
        
        /* failed to find move */
        if let m = moveValue {
            makeMove(move: m)
        }
        return
    }
    
    public func undoMove() -> Move?{
        guard let old = history.popLast() else { return nil }
        
        let move = old.move
        kingsPosition = old.kingsPosition
        activeColor = old.turn
        castlingRights = old.castlingRights
        enPassant = old.enPassant
        halfMove = old.halfMove
        moveNumber = old.moveNumber
        
        let us = activeColor
        let them = toggleColor(activeColor)
        
        board[move.moveFrom] = board[move.moveTo]
        board[move.moveFrom] = move.pieceType
        board[move.moveTo] = nil
        
        if move.flag & BITS.CAPTURE.rawValue != 0 {
            board[move.moveTo] = ChessPiece(type: move.captured!, color: them)
        } else if move.flag & BITS.EP_CAPTURE.rawValue != 0 {
            var index = 0
            if us == .black {
                index = move.moveTo - 16
            } else {
                index = move.moveTo + 16
            }
            board[index] = ChessPiece(type: .Pawn, color: them)
        }
        
        if move.flag & (BITS.KSIDE_CASTLE.rawValue | BITS.QSIDE_CASTLE.rawValue) != 0 {
            var castlingTo = -1, castlingFrom = -1
            if move.flag & BITS.KSIDE_CASTLE.rawValue != 0 {
                castlingTo = move.moveTo + 1
                castlingFrom = move.moveTo - 1
            } else if move.flag & BITS.QSIDE_CASTLE.rawValue != 0 {
                castlingTo = move.moveTo - 2
                castlingFrom = move.moveTo + 1
            }
            
            board[castlingTo] = board[castlingFrom]
            board[castlingFrom] = nil
        }
        return move
    }
}
