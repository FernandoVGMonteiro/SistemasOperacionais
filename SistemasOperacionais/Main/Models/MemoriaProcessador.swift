//
//  MemoriaProcessador.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 02/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Está é a memória que será usada pelo processador para executar os processos
class MemoriaProcessador: Memoria {
    
    var jobEmExecucao: Job? { get { sistemaOperacional.cpu.jobEmExecucao } }
    var segmentoEmExecucao: Segmento? { get { sistemaOperacional.cpu.segmentoEmExecucao } }
    
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
    
    // Segmentos em memória
    var segmentos = [Segmento]()
    
    // Retorna se foi possível alocar o processo
    func alocarProcesso(job: Job) -> Bool {
        let programa = sistemaOperacional.disco.resgatarPrograma(idPrograma: job.idPrograma)
        switch explorador.administracaoMemoria {
        case .particao:
            Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "Memória do Processador - Alocando processo: \(job.id)")
            
            if let intervalo = carregar(dados: programa.instrucoes) {
                job.intervaloLogico = intervalo
                processos.append(job)
                return true
            } else {
                Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "A memória está cheia e não comporta mais programas")
                return false
            }
        // Faz a alocação do primeiro segmento no processador
        case .segmento:
            return segmentFault(job: job, endereco: programa.programa!.base)
        }
    }
    
    override func acessar(posicao: Int) -> Instrucao {
        switch explorador.administracaoMemoria {
        case .particao:
            return super.acessar(posicao: posicao)
        case .segmento:
            return acessarSegmento(endereco: posicao)
        }
    }
    
    func acessarSegmento(endereco: Int) -> Instrucao {
        for segmento in segmentos {
            if segmento.intervaloDisco.contains(endereco) {
                return super.acessar(posicao: endereco
                    - segmento.intervaloDisco.lowerBound
                    + segmento.intervaloProcessador!.lowerBound)
            }
        }
        
        if !segmentFault(job: jobEmExecucao!, endereco: endereco) {
            return instrucaoVazia
        } else {
            return acessarSegmento(endereco: endereco)
        }
    }
    
    func segmentFault(job: Job, endereco: Int) -> Bool {
        let programa = sistemaOperacional.disco.resgatarPrograma(idPrograma: job.idPrograma)
        let segmentMapTable = programa.programa?.segmentMapTable
        let segmento = segmentMapTable!.segmento(enderecoDisco: endereco).segmento!
        
        if let intervalo = carregar(dados: Array(sistemaOperacional.disco.dados[segmento.intervaloDisco])) {
            segmento.intervaloProcessador = intervalo
            segmento.job = job
            segmentos.append(segmento)
            sistemaOperacional.cpu.segmentoEmExecucao = segmento
            return true
        }
        return false
    }
    
    func desalocarProcesso(job: Job, estadoDoProcesso: EstadoDoProcesso?, finalizado: Bool) {
        let _ = deletar(intervalo: job.intervaloLogico)
        if estadoDoProcesso != nil { job.variaveisDeProcesso = estadoDoProcesso! }
        job.estado = finalizado ? .finalizado : .pronto
        processos.removeAll { $0.id == job.id }
        Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "Desalocando processo: \(job.id)")
        imprimir()
    }
    
    func proximoJobParaExecutar(jobAtual: Job?, estado: EstadoDoProcesso) -> Job? {
        jobAtual?.variaveisDeProcesso = estado
        guard let job = processos.jobMaiorPrioridadeMaisAntigaExecucao() else {
            Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "Nenhum job para substituir ")
            return nil
        }
        return job
    }
    
    // Ajusta o contador de instruções com a base do processo que está sendo executado
    func ajustarPcLogico(pc: Int, job: Job, segmento: Segmento?) -> Int {
        switch explorador.administracaoMemoria {
        case .particao:
            return pc + (job.intervaloLogico.lowerBound)
        case .segmento:
            return pc + (segmento!.intervaloProcessador!.lowerBound)
        }
    }
    
    // Desfaz o ajuste do contador de instruções com a base do processo que está sendo executado
    func ajustarPcReal(pc: Int, job: Job, segmento: Segmento?) -> Int {
        switch explorador.administracaoMemoria {
        case .particao:
            return pc - (job.intervaloLogico.lowerBound)
        case .segmento:
            return pc - (segmento!.intervaloProcessador!.lowerBound)
        }
    }
    
    // Traduz o endereço físico (Disco)
    // para o endereço lógico (Processador)
    func traduzirParaEnderecoLogico(enderecoFisico: Int, job: Job, segmento: Segmento?) -> Int {
        let enderecoLogico: Int!
        switch explorador.administracaoMemoria {
        case .particao:
            enderecoLogico = enderecoFisico
                - job.intervaloFisico.lowerBound
                + (job.intervaloLogico.lowerBound)
        case .segmento:
            enderecoLogico = enderecoFisico
                - segmento!.intervaloDisco.lowerBound
                + (segmento!.intervaloProcessador!.lowerBound)
        }
        
        return enderecoLogico
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        
        Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "====== CONTEÚDO DA RAM ======")
        
        for processo in processos {
            Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, processo.imprimir())
        }
        Rastreador.log(.MENSAGEM, .MEMORIA_PROCESSADOR, "============")

        super.imprimir(esconderVazios: false)
    }
    
}
