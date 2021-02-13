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
    var ultimaExecucao = 0
    var tempoDeEsperaES = 0
    var tempoDeExecucao = 0
    var tempoNoProcessador = 0
    var finalizacao = 0
}

class Job {
    var id: Int = 999
    
    // Programa / arquivo referente ao job
    var idPrograma: Int
    
    // Estado do processo
    var estado: JobEstados = .pronto
    var prioridade: JobPrioridades = .media
    
    var tempos = JobTempos()
    
    // Intervalos ocupados no disco e na RAM
    var intervaloFisico: Intervalo = 999...999
    var intervaloLogico: Intervalo = 999...999
    
    // Variáveis de estado do Processo
    var variaveisDeProcesso: EstadoDoProcesso = (0, 0)
    
    init (idPrograma: Int, prioridade: JobPrioridades, intervaloFisico: Intervalo) {
        self.idPrograma = idPrograma
        self.prioridade = prioridade
        self.intervaloFisico = intervaloFisico
        self.tempos.tempoAproximadoDeExecucao
            = sistemaOperacional.disco.resgatarArquivo(id: idPrograma)?.tempoDeExecucao ?? 0
    }
    
    func imprimir() -> String {
        return "Programa: \(id) - Endereço Lógico: \(intervaloLogico) - Endereço físico: \(intervaloFisico)"
    }
}

extension Array where Element: Job {
    
    // Escolhe um job dentro da lista com maior prioridade e que foi executado por último
    func jobMaiorPrioridadeMaisAntigaExecucao() -> Job? {
        
        // Separa os jobs em um dicionário conforma a prioridade de cada um
        let prioridades: [JobPrioridades] = [.alta, .media, .baixa]
        var listaDeProcessosPorPrioridade = [JobPrioridades: [Job]]()
        for prioridade in prioridades {
            listaDeProcessosPorPrioridade[prioridade] = self.filter { job in
                return job.prioridade == prioridade && job.estado != .esperandoES
            }
        }
        
        // Levando em conta a prioridade, retorna o job mais antigo
        for prioridade in prioridades {
            if listaDeProcessosPorPrioridade[prioridade]?.count != 0 {
                let jobMaisAntigo = listaDeProcessosPorPrioridade[prioridade]?
                    .min(by: { a, b in a.tempos.ultimaExecucao < b.tempos.ultimaExecucao })
                return jobMaisAntigo
            }
        }
        
        return nil
    }
    
    func jobMenorPrioridadeMenorTempoDeExecucao() -> Job? {
        
        // Separa os jobs em um dicionário conforma a prioridade de cada um
        let prioridades: [JobPrioridades] = [.baixa, .media, .alta]
        var listaDeProcessosPorPrioridade = [JobPrioridades: [Job]]()
        for prioridade in prioridades {
            listaDeProcessosPorPrioridade[prioridade] = self.filter { job in
                return job.prioridade == prioridade && job.estado != .esperandoES
            }
        }
        
        // Levando em conta a prioridade, retorna o job mais antigo
        for prioridade in prioridades {
            if listaDeProcessosPorPrioridade[prioridade]?.count != 0 {
                let jobMaisAntigo = listaDeProcessosPorPrioridade[prioridade]?
                    .min(by: { a, b in a.tempos.tempoNoProcessador < b.tempos.tempoNoProcessador })
                return jobMaisAntigo
            }
        }
        
        return nil
    }
    
    func incrementarTempoNoProcessador() {
        for job in self {
            if job.estado == .esperandoES {
                job.tempos.tempoDeEsperaES += 1
            }
            job.tempos.tempoNoProcessador += 1
        }
    }
    
}
