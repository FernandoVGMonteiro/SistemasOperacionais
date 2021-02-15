//
//  Programas.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Programa 1: Chegada em 0 / Ocupação média da memória
// Baixo tempo de execução / Muita entrada e saída
func teste0() -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 12),         // 0
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 1
        Instrucao(instrucao: .SUB, argumento: 11),          // 2
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 3
        Instrucao(instrucao: .JUMP, argumento: 1),          // 4
        Instrucao(instrucao: .LOAD, argumento: 13),         // 5
        Instrucao(instrucao: .JUMP0, argumento: 10),        // 6
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 7
        Instrucao(instrucao: .SUB, argumento: 11),          // 8
        Instrucao(instrucao: .JUMP, argumento: 6),          // 9
        Instrucao(instrucao: .HALT, argumento: 0),          // 10
        Instrucao(instrucao: .DATA, argumento: 1),          // 11
        Instrucao(instrucao: .DATA, argumento: 5),          // 12
        Instrucao(instrucao: .DATA, argumento: 5),          // 13
    ]
}

// Programa 1: Chegada em 20 / Ocupação baixa da memória
// Tempo de execução relativamente alto / Pouca entrada e saída
func teste1() -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 11),         // 0
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 1
        Instrucao(instrucao: .SUB, argumento: 10),          // 2
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 3
        Instrucao(instrucao: .JUMP, argumento: 1),          // 4
        Instrucao(instrucao: .LOAD, argumento: 12),         // 5
        Instrucao(instrucao: .JUMP0, argumento: 9),         // 6
        Instrucao(instrucao: .SUB, argumento: 10),          // 7
        Instrucao(instrucao: .JUMP, argumento: 6),          // 8
        Instrucao(instrucao: .HALT, argumento: 0),          // 9
        Instrucao(instrucao: .DATA, argumento: 1),          // 10
        Instrucao(instrucao: .DATA, argumento: 3),          // 11
        Instrucao(instrucao: .DATA, argumento: 30),         // 12
    ]
}

// Programa 2: Chegada 20 / Ocupação maior da memória
// Alto tempo de processamento / Pouquíssimas operações ES
func teste2() -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 15),         // 0
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 1
        Instrucao(instrucao: .SUB, argumento: 14),          // 2
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 3
        Instrucao(instrucao: .JUMP, argumento: 1),          // 4
        Instrucao(instrucao: .LOAD, argumento: 16),         // 5
        Instrucao(instrucao: .JUMP0, argumento: 9),         // 6
        Instrucao(instrucao: .SUB, argumento: 14),          // 7
        Instrucao(instrucao: .JUMP, argumento: 6),          // 8
        Instrucao(instrucao: .LOAD, argumento: 17),         // 9
        Instrucao(instrucao: .JUMP0, argumento: 13),        // 10
        Instrucao(instrucao: .SUB, argumento: 14),          // 11
        Instrucao(instrucao: .JUMP, argumento: 10),         // 12
        Instrucao(instrucao: .HALT, argumento: 0),          // 13
        Instrucao(instrucao: .DATA, argumento: 1),          // 14
        Instrucao(instrucao: .DATA, argumento: 2),          // 15
        Instrucao(instrucao: .DATA, argumento: 30),         // 16
        Instrucao(instrucao: .DATA, argumento: 30),         // 17
    ]
}

// Programa 3: Chegada em 40 / Ocupação baixa da memória
// Tempo de execução médio / Bastante entrada e saída
func teste3() -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 11),         // 0
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 1
        Instrucao(instrucao: .SUB, argumento: 10),          // 2
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 3
        Instrucao(instrucao: .JUMP, argumento: 1),          // 4
        Instrucao(instrucao: .LOAD, argumento: 12),         // 5
        Instrucao(instrucao: .JUMP0, argumento: 9),         // 6
        Instrucao(instrucao: .SUB, argumento: 10),          // 7
        Instrucao(instrucao: .JUMP, argumento: 6),          // 8
        Instrucao(instrucao: .HALT, argumento: 0),          // 9
        Instrucao(instrucao: .DATA, argumento: 1),          // 10
        Instrucao(instrucao: .DATA, argumento: 5),          // 11
        Instrucao(instrucao: .DATA, argumento: 15),         // 12
    ]
}

// Retorna um programinha que carrega um valor inicial e subtrai
// uma unidade até alcançar o valor zero, simulando um contador.
// tempo = contagem * 3 + 3
func contador(_ contagem: Int) -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 5),          // 0
        Instrucao(instrucao: .JUMP0, argumento: 4),         // 1
        Instrucao(instrucao: .SUB, argumento: 6),           // 2
        Instrucao(instrucao: .JUMP, argumento: 1),          // 3
        Instrucao(instrucao: .HALT, argumento: 0),          // 4
        Instrucao(instrucao: .DATA, argumento: contagem),   // 5
        Instrucao(instrucao: .DATA, argumento: 1),          // 6
    ]
}

// Igual ao programa anterior, porém, a cada contagem grava o valor
// do acumulador em uma fita perfurada.
// tempo = contagem * 4 + 3
func contadorComFita(_ contagem: Int) -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 6),          // 0
        Instrucao(instrucao: .PUT_DATA, argumento: 0),      // 1
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 2
        Instrucao(instrucao: .SUB, argumento: 7),           // 3
        Instrucao(instrucao: .JUMP, argumento: 1),          // 4
        Instrucao(instrucao: .HALT, argumento: 0),          // 5
        Instrucao(instrucao: .DATA, argumento: contagem),   // 6
        Instrucao(instrucao: .DATA, argumento: 1),          // 7
    ]
}


// Igual ao programa anterior, porém, antes da contagem executa
// uma chamada para um dispositivo de saída.
// tempo (sem contar a saída) = contagem * 3 + 4
func contadorComESInicio(_ contagem: Int) -> [Instrucao] {
    let contagem = 5
    return [
        Instrucao(instrucao: .LOAD, argumento: 6),          // 0
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 1
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 2
        Instrucao(instrucao: .SUB, argumento: 7),           // 3
        Instrucao(instrucao: .JUMP, argumento: 2),          // 4
        Instrucao(instrucao: .HALT, argumento: 0),          // 5
        Instrucao(instrucao: .DATA, argumento: contagem),   // 6
        Instrucao(instrucao: .DATA, argumento: 1),          // 7
    ]
}


// Igual ao programa anterior, porém, a operação de entrada
// e saída é realizada ao final da contagem
// tempo (sem contar a saída) = contagem * 3 + 4
func contadorComESFim(_ contagem: Int) -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 6),          // 0
        Instrucao(instrucao: .JUMP0, argumento: 4),         // 1
        Instrucao(instrucao: .SUB, argumento: 7),           // 2
        Instrucao(instrucao: .JUMP, argumento: 1),          // 3
        Instrucao(instrucao: .DEVICE_OUT, argumento: 0),    // 4
        Instrucao(instrucao: .HALT, argumento: 0),          // 5
        Instrucao(instrucao: .DATA, argumento: contagem),   // 6
        Instrucao(instrucao: .DATA, argumento: 1),          // 7
    ]
}

let smtContadorComESFim = SegmentMapTable(segmentos: [
    Segmento(identificador: "Preparação", intervalo: 0...0),
    Segmento(identificador: "Contagem", intervalo: 1...3),
    Segmento(identificador: "Operação Saída + Finalização", intervalo: 4...5),
    Segmento(identificador: "Dados", intervalo: 6...7),
])

// Criador de jobs para facilitar a simulação
func criarJob(idPrograma: Int, prioridade: JobPrioridades) -> Job {
    let programa = sistemaOperacional.disco.resgatarArquivo(id: idPrograma)!
    return Job(idPrograma: idPrograma,
               prioridade: prioridade,
               intervaloFisico: programa.base...programa.limite)
}

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
    case DEVICE_IN = "DEVICE_IN"
    case DEVICE_OUT = "DEVICE_OUT"
    case DATA = "DATA"
    case EMPTY = "EMPTY"
    case DEVICE = "DEVICE"
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
        if instrucao != .DATA { Rastreador.log(.AVISO, .CPU, "Alteração de argumento de instrução executável") }
        argumento = novoDado
    }
    
    func carregarDado() -> Int {
        if instrucao != .DATA { Rastreador.log(.AVISO, .CPU, "Carregando de argumento de instrução executável") }
        return argumento
    }
}
