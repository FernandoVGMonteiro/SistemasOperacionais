//
//  File.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 26/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Variável global para ser usada pelo traffic controller, dispatcher e
let sistemaOperacional = SistemaOperacional()

class SistemaOperacional {
    
    let cpu = CPU()
    let disco = MemoriaDisco(tamanho: tamanhoDoDisco)
    let gerenciadorES = GerenciadorEntradaSaida()
    var listaDeJobs = [Job]()
    
    // Propriedade que retorna os jobs que estão prontos para execução
    var readyList: [Job] {
        get {
            listaDeJobs.filter { job in job.estado == .pronto }
        }
    }
    
    func retornarJobEmExecucao() -> Job? {
        return cpu.jobEmExecucao
    }
    
    func retornarJobPorId(id: Int) -> Job? {
        return listaDeJobs.first { $0.id == id }
    }
    
    func retornaCicloDeClockAtual() -> Int {
        return cpu.cicloDeClock
    }
    
    func imprimirRelatorioDaSimulacao() {
        for job in listaDeJobs {
            imprimirResumoDoJob(job: job)
        }
    }
    
    private func imprimirResumoDoJob(job: Job) {
        let tempos = job.tempos
        let id = job.id
        let idPrograma = job.idPrograma
        let prioridade = job.prioridade
        let criado = tempos.criadoEm
        let finalizado = tempos.finalizacao
        let previsoExecucao = tempos.tempoAproximadoDeExecucao
        let emExecucao = tempos.tempoDeExecucao
        let emProcessamento = tempos.tempoNoProcessador
        let esperaES = tempos.tempoDeEsperaES
        let espera = tempos.finalizacao - tempos.criadoEm - tempos.tempoDeExecucao
        
        print("\n\n-> Job \(id) - Prioridade \(prioridade) - Programa \(idPrograma)")
        print("Criado em: \(criado)")
        print("Finalizado em: \(finalizado)")
        print("Tempo previso para execução: \(previsoExecucao)")
        print("Tempo de execução: \(emExecucao)")
        print("Tempo no processador: \(emProcessamento)")
        print("Tempo de espera Entrada/Saída: \(esperaES)")
        print("Tempo em espera: \(espera)")
    }
    
    func reiniciarTimeslice() {
        cpu.contadorTimeslice = 0
    }
    
}

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
    
    static func passarJobParaFilaDeEntradaSaida(chamada: Chamada) {
        chamada.jobOrigem?.estado = .esperandoES
    }
    
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

// Aloca o processo no processador
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
