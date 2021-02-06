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
    case STORE = "STORE"
    case HALT = "HALT"
    case GET_DATA = "GET_DATA"
    case PUT_DATA = "PUT_DATA"
    case DATA = "DATA"
    case EMPTY = "EMPTY"
}

let instrucaoVazia = Instrucao(instrucao: .EMPTY, argumento: 0)

struct Instrucao: Equatable {
    init(instrucao: Instrucoes, argumento: Int) {
        self.instrucao = instrucao
        self.argumento = argumento
    }
    
    var instrucao: Instrucoes
    var argumento: Int
    
    static func == (primeira: Instrucao, segunda: Instrucao) -> Bool {
        return primeira.instrucao == segunda.instrucao && primeira.argumento == segunda.argumento
    }
    
    func imprimir() -> String {
        String(format: "%@ - %i", instrucao.rawValue, argumento)
    }
    
    mutating func salvarDado(_ novoDado: Int) {
        if instrucao != .DATA { print("Aviso: Alteração de argumento de instrução executável") }
        argumento = novoDado
    }
    
    func carregarDado() -> Int {
        if instrucao != .DATA { print("Aviso: Carregando de argumento de instrução executável") }
        return argumento
    }
}
