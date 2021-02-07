//
//  MemoriaRAM.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 02/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Está é a memória que será usada pelo processador para executar os processos
class MemoriaRAM: Memoria {
    
    var numeroDeProgramas: Int { return processos.count }
    var processoComPrioridadeMaisBaixa: Job? {
        get {
            return processos.jobMenorPrioridadeMenorTempoDeExecucao()
        }
    }
    var prioridadeMaisBaixa: JobPrioridades? {
        get {
            if numeroDeProgramas == 0 { return nil }
            else {
                return processos.reduce(JobPrioridades.alta) { $0.rawValue < $1.prioridade.rawValue ? $0 : $1.prioridade }
            }
        }
    }
    
    // Programas salvos
    var processos = [Job]()
    
    // Retorna se foi possível alocar o processo
    func alocarProcesso(job: Job) -> Bool {
        print("Memória RAM - Alocando processo: \(job.id)")
        let instrucoes = sistemaOperacional.disco.resgatarPrograma(idPrograma: job.idPrograma)
        
        if let intervalo = carregar(dados: instrucoes) {
            job.intervaloLogico = intervalo
            processos.append(job)
            return true
        } else {
            print("Memoria RAM - A memória está cheia e não comporta mais programas")
            return false
        }
    }
    
    func desalocarProcesso(job: Job, estadoDoProcesso: EstadoDoProcesso?, finalizado: Bool) {
        let _ = deletar(intervalo: job.intervaloLogico)
        if estadoDoProcesso != nil { job.variaveisDeProcesso = estadoDoProcesso! }
        job.estado = finalizado ? .finalizado : .pronto
        processos.removeAll { $0.id == job.id }
        print("Memória RAM - Desalocando processo: \(job.id)")
        imprimir()
    }
    
    func proximoJobParaExecutar(jobAtual: Job?, estado: EstadoDoProcesso) -> Job? {
        jobAtual?.variaveisDeProcesso = estado
        guard let job = processos.jobMaiorPrioridadeMaisAntigaExecucao() else {
            print("Memória RAM - Nenhum job para substituir ")
            return nil
        }
        return job
    }
    
    // Ajusta o contador de instruções com a base do processo que está sendo executado
    func ajustarPcLogico(pc: Int, job: Job) -> Int {
        return pc + (job.intervaloLogico.lowerBound)
    }
    
    // Desfaz o ajuste do contador de instruções com a base do processo que está sendo executado
    func ajustarPcReal(pc: Int, job: Job) -> Int {
        return pc - (job.intervaloLogico.lowerBound)
    }
    
    // Traduz o endereço físico (correspondente ao disco)
    // para o endereço lógico (RAM)
    func traduzirParaEnderecoLogico(enderecoFisico: Int, job: Job) -> Int {
        let enderecoLogico = enderecoFisico
            - job.intervaloFisico.lowerBound
            + (job.intervaloLogico.lowerBound)
        
        return enderecoLogico
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        
        print("\n====== CONTEÚDO DA RAM ======\n")
        
        for processo in processos {
            print(processo.imprimir())
        }
        print("\n============")

        super.imprimir(esconderVazios: false)
    }
    
}
