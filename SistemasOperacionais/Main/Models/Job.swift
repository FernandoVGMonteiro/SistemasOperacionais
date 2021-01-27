//
//  Job.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum JobEstados {
    case inativo // Está aguardando sua submissão
    case pronto // Pronto para executar, aguardando sua vez no processador
    case executando // Está executando no processador
    case esperandoES // Aguardando um dispositivo de entrada ou saída
    case finalizado // Terminou sua execução
}

enum Prioridades: Int {
    case alta = 2
    case media = 1
    case baixa = 0
}

class ProcessControlBlock {
    var id: Int? // Identificação do processo
    var estado: JobEstados = .pronto
    var prioridade: Prioridades = .media
    var registradores = [Int](repeating: 0, count: 16)
    var tempoAproximadoDeExecucao: Int? // Em instruções de clock
    var instanteDeCriacao = Date()
    
    // Variáveis de estado do Processo
    var variaveisDeProcesso: EstadoDoProcesso?
    
    init(prioridade: Prioridades, tempoAproximadoDeExecucao: Int) {
        self.prioridade = prioridade
        self.tempoAproximadoDeExecucao = tempoAproximadoDeExecucao
    }
}

class Job {
    var pcb: ProcessControlBlock!
    var instrucoes: [Instrucao]!
    
    init (pcb: ProcessControlBlock, instrucoes: [Instrucao], memoriaDeDados: [Int] = [Int](repeating: 0, count: 16)) {
        self.pcb = pcb
        self.instrucoes = instrucoes
        self.pcb.variaveisDeProcesso = (0, 0, memoriaDeDados, instrucoes)
    }
}
