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
    case dispositivoES
}

struct Dispositivo {
    var id: Int = 0
    var intervalo: Intervalo = 0...0
    var tempoDeResposta: TimeInterval = 0
    var dados = [Instrucao]()
}

// Informações do arquivo salvo em memória como endereços ocupados...
struct Programa {
    
    var id: Int
    var tipo: TipoArquivo
    var base: Int
    var limite: Int
    var tempoDeExecucao: Int = 0
    
    func imprimir() -> String {
        return "Programa \(id) (\(tipo)) - Alocado em disco \(base) - \(limite) - Tempo de Execução: \(tempoDeExecucao)"
    }
}

// Este é o disco de memória, acessos a ele contam como Entrada/Saída
class MemoriaDisco: Memoria {
    
    var arquivos = [Programa]()
    
    override init(tamanho: Int) {
        super.init(tamanho: tamanho)
        carregarNovoPrograma(dados: contador(5), tempoDeExecucao: tempoDaContagem(5))
        carregarNovoPrograma(dados: contadorComES(5), tempoDeExecucao: tempoDaContagem(5) + 1)
        carregarNovoPrograma(dados: dispositivoEntradaSaida(id: 0, tempoDeAcesso: 10, dado: 0), tempoDeExecucao: 10)
        carregarNovoPrograma(dados: dispositivoEntradaSaida(id: 1, tempoDeAcesso: 10, dado: 7), tempoDeExecucao: 10)
        imprimir()
    }
    
    func carregarNovoPrograma(dados: [Instrucao], tempoDeExecucao: Int) {
        if let intervalo = carregar(dados: dados, ajustarEnderecamento: true) {
            arquivos.append(Programa(
                id: arquivos.count,
                tipo: self.dados[intervalo.lowerBound].instrucao == .DEVICE ? .dispositivoES : .programa,
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
    
    func resgatarArquivo(id: Int) -> Programa? {
        guard let arquivo = arquivos.first(where: { $0.id == id }) else { print("Disco - Programa não encontrado"); return nil }
        return arquivo
    }
    
    func resgatarDispositivo(id: Int) -> Dispositivo? {
        guard let inicioDispositivo = dados.firstIndex(where: { $0.instrucao == .DEVICE && $0.argumento == id }) else {
            print("Disco - Dispositivo não encontrado")
            return nil
        }
        
        return Dispositivo(
            id: dados[inicioDispositivo].argumento,
            intervalo: inicioDispositivo...(inicioDispositivo + 2),
            tempoDeResposta: TimeInterval(dados[inicioDispositivo + 1].argumento),
            dados: Array(dados[inicioDispositivo...(inicioDispositivo + 2)]))
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        print("\n====== CONTEÚDO DO DISCO ======\n")
        
        for arquivo in arquivos {
            print(arquivo.imprimir())
        }
        
        print("\n============")
        super.imprimir()
    }
    
}
