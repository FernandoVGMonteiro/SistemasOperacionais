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
        job.id = sistemaOperacional.listaDeJobs.count
        sistemaOperacional.listaDeJobs.append(job)
        
        // Informar que a lista de jobs foi atualizada
        print("Traffic Controller - O job \(job.id) de prioridade \(job.prioridade) foi adicionado a lista de jobs")
        motorDeEventos.pedirParaExecutarJob.onNext(job)
    }
    
    static func marcarJobComoFinalizado(job: Job) {
        job.estado = .finalizado
        job.tempos.finalizacao = sistemaOperacional.retornaCicloDeClockAtual()
        print("Traffic Controller - O job \(job.id) finalizou sua execução")
    }
    
    static func atualizarTemposDoJob(id: Int, tempos: JobTempos, tempoDeUtilizacaoDoProcessador: Int) {
        guard let job = sistemaOperacional.retornarJobPorId(id: id) else { print("Traffic Controller - Job não encontrado"); return }
        job.tempos = tempos
        job.tempos.tempoDeExecucao = tempoDeUtilizacaoDoProcessador
    }
    
    static func passarJobParaFilaDeEntradaSaida(chamada: Chamada) {
        chamada.jobOrigem?.estado = .esperandoES
        Dispatcher.pedirParaAlocarProcessoNoProcessador()
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
        
        guard let job = sistemaOperacional.readyList.jobMaiorPrioridadeMaisAntigaExecucao() else {
            print("JobScheduler - Erro na seleção de um job para ser executado")
            return nil
        }
        
        return job
    }
    
}

// Aloca o processo e decide quanto tempo ele poderá usar o processador
// (aloca, bloqueia, interrompe...)
class Dispatcher {
    
    // Aloca processo que será executado pelo processador
    static func pedirParaAlocarProcessoNoProcessador() {
        
        // Pede ao JobScheduler que escolha um job para ser executado
        guard let job = JobScheduler.escolherProcessoParaExecutar() else { return }

        if sistemaOperacional.cpu.memoria.numeroDeProgramas == maximoDeJobsNoProcessador {
            // Verifica qual o job com menor prioridade no processador
            // e substitui por um job de prioridade maior, se houver
            if job.prioridade.rawValue <= sistemaOperacional.cpu.memoria.prioridadeMaisBaixa!.rawValue {
                return
            }
            
            sistemaOperacional.cpu.desalocarProcessoDeMenorPrioridade()
        }
        
        alocarProcessoNoProcessador(job: job)
    }
    
    // Aloca o processo retornado pelo job scheduler no processador
    private static func alocarProcessoNoProcessador(job: Job) {
        job.estado = .executando
        sistemaOperacional.cpu.alocarProcesso(job: job)
    }
    
}
