//
//  MemoriaRAM.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 02/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Dados guardados de um programa que está sendo executado
struct ProgramaEmExecucao {
    
    var idPrograma: Int
    var idProcesso: Int
    var intervaloFisicoOcupado: Intervalo
    var intervaloLogicoOcupado: Intervalo
    
    init(idPrograma: Int, idProcesso: Int, intervaloLogicoOcupado: Intervalo, intervaloFisicoOcupado: Intervalo) {
        self.idPrograma = idPrograma
        self.idProcesso = idProcesso
        self.intervaloLogicoOcupado = intervaloLogicoOcupado
        self.intervaloFisicoOcupado = intervaloFisicoOcupado
    }
}

// Está é a memória que será usada pelo processador para executar os processos
class MemoriaRAM: Memoria {
    
    // Programas salvos
    var processos = [ProgramaEmExecucao]()
    
    // Retorna se foi possível alocar o processo
    func alocarProcesso(id: Int) -> Bool {
        let job = sistemaOperacional.retornarJobPorId(id: id)!
        let instrucoes = sistemaOperacional.disco.resgatarPrograma(idPrograma: job.pcb.idPrograma)
        
        if let intervalo = carregar(dados: instrucoes) {
            processos.append(ProgramaEmExecucao(
                idPrograma: id,
                idProcesso: gerarIdDoProcesso(idPrograma: id),
                intervaloLogicoOcupado: intervalo,
                intervaloFisicoOcupado: job.pcb.intervaloFisico))
            return true
        } else {
            print("Memoria RAM - A memória está cheia e não comporta mais programas")
            return false
        }
    }
    
    func desalocarProcesso(idPrograma: Int, idProcesso: Int, pc: Int, ac: Int, finalizado: Bool) -> [Instrucao]? {
        if let intervalo = processos.first(where: { $0.idPrograma == idPrograma && $0.idProcesso == idProcesso })?.intervaloLogicoOcupado {
            let memoriaAtualizada = deletar(intervalo: intervalo)
            let estadoDoProcesso = EstadoDoProcesso(pc, ac)
            let jobParaAtualizar = sistemaOperacional.retornarJobPorId(id: idPrograma)!
            jobParaAtualizar.pcb.variaveisDeProcesso = estadoDoProcesso
            jobParaAtualizar.pcb.estado = finalizado ? .finalizado : .pronto
            return memoriaAtualizada
        } else {
            print("Memória RAM - Processo não encontrado")
            return nil
        }
    }
    
    // Traduz o endereço físico (correspondente ao disco)
    // para o endereço lógico (RAM)
    func traduzirParaEnderecoLogico(enderecoFisico: Int, idPrograma: Int) -> Int {
        let processo = processos.first { $0.idPrograma == idPrograma }!
        let enderecoLogico = enderecoFisico
            - processo.intervaloFisicoOcupado.lowerBound
            + processo.intervaloLogicoOcupado.lowerBound
        
        return enderecoLogico
    }

    // Verifica se já existe processos do mesmo programa alocado,
    // Caso exista, gera ids de processo sequencialmente
    private func gerarIdDoProcesso(idPrograma: Int) -> Int {
        return processos.filter { $0.idPrograma == idPrograma }.count
    }
    
}
