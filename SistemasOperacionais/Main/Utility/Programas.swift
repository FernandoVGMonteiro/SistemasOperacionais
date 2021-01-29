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
        Instrucao(instrucao: .LOADI, argumento: 1),
        Instrucao(instrucao: .STORE, argumento: 0),
        Instrucao(instrucao: .LOADI, argumento: contagem),
        Instrucao(instrucao: .JUMP0, argumento: 6),
        Instrucao(instrucao: .SUB, argumento: 0),
        Instrucao(instrucao: .JUMP, argumento: 3),
        Instrucao(instrucao: .HALT, argumento: 0)
    ]
}

// Seu tempo de execução pode ser calculado por Tempo = 3 * Contagem + 4
func tempoDaContagem(_ contagem: Int) -> Int {
    return 3 * contagem + 5
}

// Criador de jobs para facilitar a simulação
func criarJob(prioridade: JobPrioridades, tempoAproximadoDeExecucao: Int, instrucoes: [Instrucao]) -> Job {
    return Job(pcb: ProcessControlBlock(prioridade: prioridade, tempoAproximadoDeExecucao: tempoAproximadoDeExecucao), instrucoes: instrucoes)
}
