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
