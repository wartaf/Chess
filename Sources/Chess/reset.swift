//
//  reset.swift
//  Chess
//
//  Created by Harry Pantaleon on 9/10/22.
//

import Foundation

extension Chess {
    func reset() {
        load(fen: defaultPosition)
    }
}
