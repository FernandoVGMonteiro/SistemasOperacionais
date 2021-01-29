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
    var listaDeJobs = [Job]()
    
    // Propriedade que retorna os jobs que estão prontos para execução
    var readyList: [Job] {
        get {
            listaDeJobs.filter { job in job.pcb.estado == .pronto }
        }
    }
    
    func retornarJobEmExecucao() -> Job? {
        guard let idDoJobEmExecucao = cpu.idDoJobEmExecucao else { return nil }
        return retornarJobPorId(id: idDoJobEmExecucao)
    }
    
    func retornarJobPorId(id: Int) -> Job? {
        return listaDeJobs.first { $0.pcb.id == id }
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
        let tempos = job.pcb.tempos
        let id = job.pcb.id
        let prioridade = job.pcb.prioridade
        let criado = tempos.criadoEm
        let finalizado = tempos.finalizacao
        let previsoExecucao = tempos.tempoAproximadoDeExecucao
        let emProcessamento = tempos.utilizacaoDoProcessador
        let espera = tempos.finalizacao - tempos.criadoEm - tempos.utilizacaoDoProcessador
        
        print("\n\n-> Job \(id) - Prioridade \(prioridade)")
        print("Criado em: \(criado)")
        print("Finalizado em: \(finalizado)")
        print("Tempo previso para execução: \(previsoExecucao)")
        print("Tempo no processador: \(emProcessamento)")
        print("Tempo em espera: \(espera)")
    }
    
    func reiniciarTimeslice() {
        cpu.contadorTimeslice = 0
    }
    
}
