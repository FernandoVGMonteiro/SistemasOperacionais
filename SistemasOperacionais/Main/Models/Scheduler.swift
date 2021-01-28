//
//  JobScheduler.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Informa ao sistema quais os estados dos processos
class TrafficController {
    
    static func adicionarJob(job: Job) {
        // Atribuir um ID ao job e adicionar a lista de jobs
        job.pcb.id = sistemaOperacional.listaDeJobs.count
        sistemaOperacional.listaDeJobs.append(job)
        
        // Informar que a lista de jobs foi atualizada
        print("Traffic Controller - O job \(job.pcb.id ?? 999) de prioridade \(job.pcb.prioridade) foi adicionado a lista de jobs")
        motorDeEventos.pedirParaExecutarJob.onNext(job)
    }
    
    static func marcarJobComoFinalizado(id: Int?) {
        guard let id = id else { print("Job não encontrado"); return }
        sistemaOperacional.retornarJobPorId(id: id)?.pcb.estado = .finalizado
        print("O job \(id) finalizou sua execução")
    }
    
}

// Políticas de alocação do sistema
enum PoliticasDeAlocacao {
    case porPrioridade
}

// Decide qual processo vai ser alocado conforme as prioridades
class JobScheduler {
    
    // Escolhe o processo que vai ser executado conforme a política do sistema
    // A variável jobNovo diz se é um processo que acabou de chegar ou que já estava em espera
    static func escolherProcessoParaExecutar() -> Job? {
        
        // Verifica se existem jobs prontos para serem executados
        if sistemaOperacional.readyList.count == 0 {
            print("JobScheduler - Não existem jobs na ReadyList que possam ser executados")
            return nil
        }
        
        // Separa os jobs em um dicionário conforma a prioridade de cada um
        let prioridades: [JobPrioridades] = [.alta, .media, .baixa]
        var listaDeProcessosPorPrioridade = [JobPrioridades: [Job]]()
        for prioridade in prioridades {
            listaDeProcessosPorPrioridade[prioridade] = sistemaOperacional.readyList.filter { job in
                return job.pcb.prioridade == prioridade
            }
        }
        
        // Levando em conta a prioridade, retorna o job mais antigo
        for prioridade in prioridades {
            if listaDeProcessosPorPrioridade[prioridade]?.count != 0 {
                let jobMaisAntigo = listaDeProcessosPorPrioridade[prioridade]?
                    .min(by: { a, b in a.pcb.tempos.instanteDeCriacao < b.pcb.tempos.instanteDeCriacao })
                return jobMaisAntigo
            }
        }
        
        print("JobScheduler - Erro na seleção de um job para ser executado")
        return nil
    }
    
}

// Aloca o processo e decide quanto tempo ele poderá usar o processador
// (aloca, bloqueia, interrompe...)
class Dispatcher {
    
    // Aloca processo que será executado pelo processador
    static func pedirParaAlocarProcessoNoProcessador(jobNovo: Job? = nil) {
        
        // Um novo job deve substituir um job em execução caso tenha prioridade maior
        if let jobNovo = jobNovo, let jobEmExecucao = sistemaOperacional.retornarJobEmExecucao() {
            if jobNovo.pcb.prioridade.rawValue > jobEmExecucao.pcb.prioridade.rawValue {
                alocarProcessoNoProcessador(job: jobNovo)
                return
            } else {
                // Caso o job não tenha maior prioridade, não deve substituir o job em execução
                print("Dispatcher - Já existe um job em execução de prioridade maior")
                return
            }
        }
        
        // Pede ao JobScheduler que escolha um job para ser executado
        let possivelJob = JobScheduler.escolherProcessoParaExecutar()
        guard let job = possivelJob else { return }
        alocarProcessoNoProcessador(job: job)
    }
    
    // Aloca o processo retornado pelo job scheduler no processador
    private static func alocarProcessoNoProcessador(job: Job) {
        // Desaloca caso exista um processo em execução
        if let jobEmExecucao = sistemaOperacional.retornarJobEmExecucao() {
            let estadoDoProcesso = sistemaOperacional.cpu.desalocarProcesso()
            jobEmExecucao.pcb.variaveisDeProcesso = estadoDoProcesso
            jobEmExecucao.pcb.estado = .pronto
        }
        
        // Faz a alocação
        job.pcb.estado = .executando
        sistemaOperacional.cpu.alocarProcesso(id: job.pcb.id!, estado: job.pcb.variaveisDeProcesso!)
    }
    
}
