//
//  Instrucao.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum Instrucoes: String {
    case JUMP = "JUMP"
    case JUMP0 = "JUMP0"
    case JUMPN = "JUMPN"
    case ADD = "ADD"
    case SUB = "SUB"
    case MULT = "MULT"
    case DIV = "DIV"
    case LOAD = "LOAD"
    case LOADI = "LOADI"
    case STORE = "STORE"
    case HALT = "HALT"
    case GET_DATA = "GET_DATA"
    case PUT_DATA = "PUT_DATA"
    case LOAD_PLUS_ONE = "LOAD_PLUS_ONE"
    case STORE_PLUS_ONE = "STORE_PLUS_ONE"
}

class Instrucao {
    init(instrucao: Instrucoes, argumento: Int) {
        self.instrucao = instrucao
        self.argumento = argumento
    }
    
    var instrucao: Instrucoes
    var argumento: Int
    
    func imprimir() -> String {
        String(format: "%@ - %i", instrucao.rawValue, argumento)
    }
}
