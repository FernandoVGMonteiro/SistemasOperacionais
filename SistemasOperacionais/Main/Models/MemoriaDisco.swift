//
//  Memoria.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 01/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum TipoArquivo {
    case programa
    case dados
    case driverES
}

// Informações do arquivo salvo em memória como endereços ocupados...
struct Arquivo {
    
    var id: Int
    var tipo: TipoArquivo
    var base: Int
    var limite: Int
    var tempoDeExecucao: Int = 0
    
    func imprimir() -> String {
        return "Arquivo \(id) (\(tipo)) - Alocado em disco \(base) - \(limite) - Tempo de Execução: \(tempoDeExecucao)"
    }
}

// Este é o disco de memória, acessos a ele contam como Entrada/Saída
class MemoriaDisco: Memoria {
    
    var arquivos = [Arquivo]()
//    var tempoDeAcesso = 2 // Em ciclos de clock
    
    override init(tamanho: Int) {
        super.init(tamanho: tamanho)
        carregarNovoPrograma(dados: contador(5), tempoDeExecucao: tempoDaContagem(5))
        carregarNovoPrograma(dados: contador(10), tempoDeExecucao: tempoDaContagem(10))
        carregarNovoPrograma(dados: contador(15), tempoDeExecucao: tempoDaContagem(15))
        imprimir()
    }
    
    func carregarNovoPrograma(dados: [Instrucao], tempoDeExecucao: Int) {
        if let intervalo = carregar(dados: dados, ajustarEnderecamento: true) {
            arquivos.append(Arquivo(
                id: arquivos.count,
                tipo: .programa,
                base: intervalo.lowerBound,
                limite: intervalo.upperBound,
                tempoDeExecucao: tempoDeExecucao))
        } else {
            print("Disco - Não foi possível carregar em disco")
        }
    }
    
    func resgatarPrograma(idPrograma: Int) -> [Instrucao] {
        guard let programa = arquivos.first(where: { $0.id == idPrograma })
            else { print("Disco - Programa \(idPrograma) não encontrado"); return [] }
        return acessar(intervalo: programa.base...programa.limite)
    }
    
    func resgatarArquivo(id: Int) -> Arquivo? {
        guard let arquivo = arquivos.first(where: { $0.id == id }) else { print("Disco - Arquivo não encontrado"); return nil }
        return arquivo
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        print("\n====== CONTEÚDO DA MEMÓRIA ======\n")
        
        for arquivo in arquivos {
            print(arquivo.imprimir())
        }
        
        print("\n============")
        super.imprimir()
    }
    
}
