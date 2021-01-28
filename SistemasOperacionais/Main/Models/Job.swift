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

enum JobPrioridades: Int {
    case alta = 2
    case media = 1
    case baixa = 0
}

// Indicadores temporais do processo (usados para avaliar
// a simulação e fornecer parâmetros para a alocação de processo - round-robin)
// Todos os tempos da simulação são dados em ciclos de clock
struct JobTempos {
    var tempoAproximadoDeExecucao = 0
    var criadoEm = sistemaOperacional.retornaCicloDeClockAtual()
    var ultimaAlocacaoNoProcessador = 0
    var utilizacaoDoProcessador = 0
    var finalizacao = 0
}

class ProcessControlBlock {
    var id: Int = 999 // Identificação do processo
    var estado: JobEstados = .pronto
    var prioridade: JobPrioridades = .media
    var registradores = [Int](repeating: 0, count: 16)
    var tempos = JobTempos()
    
    // Variáveis de estado do Processo
    var variaveisDeProcesso: EstadoDoProcesso?
    
    init(prioridade: JobPrioridades, tempoAproximadoDeExecucao: Int) {
        self.prioridade = prioridade
        self.tempos.tempoAproximadoDeExecucao = tempoAproximadoDeExecucao
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
