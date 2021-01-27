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
        motorDeEventos.atualizouListaDeJobs.onNext(true)
    }
    
}

// Políticas de alocação do sistema
enum PoliticasDeAlocacao {
    case porPrioridade
}

// Decide qual processo vai ser alocado conforme as prioridades
class JobScheduler {
    
    // Escolhe o processo que vai ser executado conforme a política do sistema
    static func escolherProcessoParaExecutar() -> Job? {
        
        // Verifica se existem jobs prontos para serem executados
        if sistemaOperacional.readyList.count == 0 {
            print("Aviso: Não existem jobs na ReadyList que possam ser executados")
            return nil
        }
        
        // Separa os jobs em um dicionário conforma a prioridade de cada um
        let prioridades: [Prioridades] = [.baixa, .media, .alta]
        var listaDeProcessosPorPrioridade = [Prioridades: [Job]]()
        for prioridade in prioridades {
            listaDeProcessosPorPrioridade[prioridade] = sistemaOperacional.readyList.filter { job in
                return job.pcb.prioridade == prioridade
            }
        }
        
        // Levando em conta a prioridade, retorna o job mais antigo
        for prioridade in prioridades {
            if listaDeProcessosPorPrioridade[prioridade]?.count != 0 {
                let jobMaisAntigo = listaDeProcessosPorPrioridade[prioridade]?.min(by: { a, b in a.pcb.instanteDeCriacao < b.pcb.instanteDeCriacao })
                return jobMaisAntigo
            }
        }
        
        print("Erro: Erro na seleção de um job para ser executado")
        return nil
    }
    
}

// Aloca o processo e decide quanto tempo ele poderá usar o processador
// (aloca, bloqueia, interrompe...)
class Dispatcher {
    
    // Aloca processo que será executado pelo processador
    static func alocaProcessoNoProcessador() {
        // Pede ao JobScheduler que escolha um job para ser executado
        let possivelJob = JobScheduler.escolherProcessoParaExecutar()
        guard let job = possivelJob else {
            return
        }
        
        sistemaOperacional.cpu.alocarProcesso(estado: job.pcb.variaveisDeProcesso!)
    }
    
}
