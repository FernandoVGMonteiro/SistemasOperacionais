//
//  Programas.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Retorna um programinha que carrega um valor inicial e subtrai
// uma unidade até alcançar o valor zero, simulando um contador.
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

func contadorComES(_ contagem: Int) -> [Instrucao] {
    return [
        Instrucao(instrucao: .LOAD, argumento: 6),          // 0
        Instrucao(instrucao: .PUT_DATA, argumento: 0),      // 1
        Instrucao(instrucao: .JUMP0, argumento: 5),         // 2
        Instrucao(instrucao: .SUB, argumento: 7),           // 3
        Instrucao(instrucao: .JUMP, argumento: 2),          // 4
        Instrucao(instrucao: .HALT, argumento: 0),          // 5
        Instrucao(instrucao: .DATA, argumento: contagem),   // 6
        Instrucao(instrucao: .DATA, argumento: 1),          // 7
    ]
}

// Seu tempo de execução pode ser calculado por Tempo = 3 * Contagem + 4
func tempoDaContagem(_ contagem: Int) -> Int {
    return 3 * contagem + 3
}

// Criador de jobs para facilitar a simulação
func criarJob(idPrograma: Int, prioridade: JobPrioridades) -> Job {
    let programa = sistemaOperacional.disco.resgatarArquivo(id: idPrograma)!
    return Job(idPrograma: idPrograma,
               prioridade: prioridade,
               intervaloFisico: programa.base...programa.limite)
}
