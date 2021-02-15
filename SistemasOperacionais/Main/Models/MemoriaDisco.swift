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
    var dado = 0
    var compartilhado: Bool = false
    var maxChamadas: Int = 1
    var dados = [Instrucao]()
}

// Informações do arquivo salvo em memória como endereços ocupados...
struct Programa {
    
    var id: Int
    var nome: String
    var tipo: TipoArquivo
    var base: Int
    var limite: Int
    var tempoDeExecucao: Int = 0
    var segmentMapTable: SegmentMapTable?
    
    func imprimir() -> String {
        return "Programa \(id) (\(tipo)) - Alocado em disco \(base) - \(limite) - Tempo de Execução: \(tempoDeExecucao)"
    }
}

// Este é o disco de memória, acessos a ele contam como Entrada/Saída
class MemoriaDisco: Memoria {
    
    var arquivos = [Programa]()
    
    override init(tamanho: Int) {
        super.init(tamanho: tamanho)
        carregarNovoPrograma(nome: "Contador 5", dados: contador(5), tempoDeExecucao: 18)
        carregarNovoPrograma(nome: "Contador 10", dados: contador(10), tempoDeExecucao: 33)
        carregarNovoPrograma(nome: "Contador 15", dados: contador(15), tempoDeExecucao: 48)
        carregarNovoPrograma(nome: "Contador com ES Inicio", dados: contadorComESInicio(5), tempoDeExecucao: 19)
        carregarNovoPrograma(nome: "Contador com ES Fim", dados: contadorComESFim(5), tempoDeExecucao: 19, segmentMapTable: smtContadorComESFim)
        carregarNovoPrograma(nome: "Contador com Fita", dados: contadorComFita(5), tempoDeExecucao: 24)
        carregarNovoPrograma(nome: "Dispositivo 0",
                             dados: dispositivoEntradaSaida(id: 0,
                                                            tempoDeAcesso: 10,
                                                            dado: 2,
                                                            compartilhado: false,
                                                            maxChamadas: 1),
                             tempoDeExecucao: 10)
        imprimir()
    }
    
    func carregarNovoPrograma(nome: String, dados: [Instrucao], tempoDeExecucao: Int, segmentMapTable: SegmentMapTable? = nil) {
        if let intervalo = carregar(dados: dados, ajustarEnderecamento: true) {
            arquivos.append(Programa(
                id: arquivos.count,
                nome: nome,
                tipo: self.dados[intervalo.lowerBound].instrucao == .DEVICE ? .dispositivoES : .programa,
                base: intervalo.lowerBound,
                limite: intervalo.upperBound,
                tempoDeExecucao: tempoDeExecucao,
                segmentMapTable: segmentMapTable?.relocarEnderecos(base: intervalo.lowerBound)))
        } else {
            print("Disco - Não foi possível carregar em disco")
        }
    }
    
    func resgatarPrograma(idPrograma: Int) -> (programa: Programa?, instrucoes: [Instrucao]) {
        guard let programa = arquivos.first(where: { $0.id == idPrograma })
            else { print("Disco - Programa \(idPrograma) não encontrado"); return (nil, []) }
        return (programa, acessar(intervalo: programa.base...programa.limite))
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
            dado: dados[inicioDispositivo + 4].argumento,
            compartilhado: dados[inicioDispositivo + 3].argumento == 1,
            maxChamadas: dados[inicioDispositivo + 4].argumento,
            dados: Array(dados[inicioDispositivo...(inicioDispositivo + 5)]))
    }
    
    func imprimirProgramas() {
        let programas = arquivos.filter { $0.tipo == .programa }
        print("\n=== PROGRAMAS EM DISCO ===\n")
        for programa in programas {
            print("Programa \(programa.id) - \(programa.nome)")
        }
        print("\n==========================")
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        print("\n====== CONTEÚDO DO DISCO ======\n")
        
        for arquivo in arquivos {
            print(arquivo.imprimir())
            if let smt = arquivo.segmentMapTable {
                smt.imprimir()
            }
        }
        
        print("\n============")
        super.imprimir()
    }
    
}
