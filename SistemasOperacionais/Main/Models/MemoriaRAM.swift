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
    var intervaloOcupado: ClosedRange<Int>
    
    init(idPrograma: Int, idProcesso: Int, intervaloOcupado: ClosedRange<Int>) {
        self.idPrograma = idPrograma
        self.idProcesso = idProcesso
        self.intervaloOcupado = intervaloOcupado
    }
}

// Está é a memória que será usada pelo processador para executar os processos
class MemoriaRAM {
    
    // Programas salvos
    var processos = [ProgramaEmExecucao]()
    
    // Dados carregados na memória do processador
    var dados = [Instrucao](repeating: Instrucao(instrucao: .EMPTY, argumento: 0), count: tamanhoDaRAM)
    
    // Lista dos intervalos livres na memória
    var espacosLivres: [ClosedRange<Int>] {
        get {
            var espacos = [ClosedRange<Int>]()
            
            var inicio: Int?
            var fim: Int?
            
            for (indice, dado) in dados.enumerated() {
                if dado == instrucaoVazia {
                    if inicio == nil {
                        inicio = indice
                    }
                    
                    if indice == dados.count - 1 {
                        fim = indice
                        espacos.append(inicio!...fim!)
                    }
                } else {
                    if inicio != nil && fim == nil  && indice != 0{
                        fim = indice - 1
                        espacos.append(inicio!...fim!)
                        inicio = nil
                        fim = nil
                    }
                }
            }
            
            return espacos
        }
    }
    
    // Retorna se foi possível alocar o processo
    func alocarProcesso(id: Int, instrucoes: [Instrucao]) -> Bool {
        let numeroDeInstrucoes = instrucoes.count
        
        for espaco in espacosLivres {
            if espaco.count >= numeroDeInstrucoes {
                // Alocar o programa na memória do processador
                var indice = espaco.lowerBound
                for instrucao in instrucoes {
                    dados[indice] = instrucao
                    indice += 1
                }
                
                // Armazenar informações do programa
                let inicioDoPrograma = espaco.lowerBound
                let fimDoPrograma = indice
                processos.append(ProgramaEmExecucao(
                    idPrograma: id,
                    idProcesso: gerarIdDoProcesso(idPrograma: id),
                    intervaloOcupado: inicioDoPrograma...fimDoPrograma))
                return true
            }
        }
        
        print("MemoriaRAM - A memória está cheia e não comporta mais programas")
        return false
    }
    
    func desalocarProcesso(idPrograma: Int, idProcesso: Int, pc: Int, ac: Int, finalizado: Bool) {
        if let intervalo = processos.first(where: { $0.idPrograma == idPrograma && $0.idProcesso == idProcesso })?.intervaloOcupado {
            // Esvazia a memória RAM dentro do intervalo daquele processo
            // e passa seu conteúdo para o as informações do job
            var memoriaAtualizada = [Instrucao]()
            for indice in intervalo {
                memoriaAtualizada.append(dados[indice])
                dados[indice] = instrucaoVazia
            }
            
            let estadoDoProcesso = EstadoDoProcesso(pc, ac, memoriaAtualizada)
            let jobParaAtualizar = sistemaOperacional.retornarJobPorId(id: idPrograma)!
            jobParaAtualizar.pcb.variaveisDeProcesso = estadoDoProcesso
            jobParaAtualizar.pcb.estado = finalizado ? .finalizado : .pronto
        } else {
            print("Memória RAM - Processo não encontrado")
        }
    }

    // Verifica se já existe processos do mesmo programa alocado,
    // Caso exista, gera ids de processo sequencialmente
    private func gerarIdDoProcesso(idPrograma: Int) -> Int {
        return processos.filter { $0.idPrograma == idPrograma }.count
    }
    
}
