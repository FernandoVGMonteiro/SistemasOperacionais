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
        carregarNovoPrograma(nome: "Programa Teste 0", dados: teste0(), tempoDeExecucao: 45)
        carregarNovoPrograma(nome: "Programa Teste 1", dados: teste1(), tempoDeExecucao: 107)
        carregarNovoPrograma(nome: "Programa Teste 2", dados: teste2(), tempoDeExecucao: 195)
        carregarNovoPrograma(nome: "Programa Teste 3", dados: teste3(), tempoDeExecucao: 48)
        carregarNovoPrograma(nome: "Contador com ES Fim", dados: contadorComESFim(5), tempoDeExecucao: 19, segmentMapTable: smtContadorComESFim)
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
            Rastreador.log(.ERRO, .MEMORIA_DISCO, "Não foi possível carregar em disco")
        }
    }
    
    func resgatarPrograma(idPrograma: Int) -> (programa: Programa?, instrucoes: [Instrucao]) {
        guard let programa = arquivos.first(where: { $0.id == idPrograma })
            else {
                Rastreador.log(.ERRO, .MEMORIA_DISCO, "Programa \(idPrograma) não encontrado")
                return (nil, [])
        }
        return (programa, acessar(intervalo: programa.base...programa.limite))
    }
    
    func resgatarArquivo(id: Int) -> Programa? {
        guard let arquivo = arquivos.first(where: { $0.id == id }) else {
            Rastreador.log(.ERRO, .MEMORIA_DISCO, "Programa não encontrado")
            return nil
        }
        return arquivo
    }
    
    func resgatarDispositivo(id: Int) -> Dispositivo? {
        guard let inicioDispositivo = dados.firstIndex(where: { $0.instrucao == .DEVICE && $0.argumento == id }) else {
            Rastreador.log(.ERRO, .MEMORIA_DISCO, "Dispositivo não encontrado")
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
        Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, "=== PROGRAMAS EM DISCO ===")
        for programa in programas {
            Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, "Programa \(programa.id) - \(programa.nome)")
        }
        Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, "==========================")
    }
    
    override func imprimir(esconderVazios: Bool = true) {
        Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, "====== CONTEÚDO DO DISCO ======")
        
        for arquivo in arquivos {
            Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, arquivo.imprimir())
            if let smt = arquivo.segmentMapTable {
                smt.imprimir()
            }
        }
        
        Rastreador.log(.MENSAGEM, .MEMORIA_DISCO, "============")
        super.imprimir()
    }
    
}
