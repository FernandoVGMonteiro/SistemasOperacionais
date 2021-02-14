//
//  File.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 07/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum ChamadaTipos {
    case entrada
    case saida
}

// Requisição de entrada e saída
class Chamada {
    
    var jobOrigem: Job?
    var dispositivo: Int?
    var tipo: ChamadaTipos?
    var dado: Int?
    var completa: Bool = false
    var sendoTratada: Bool = false
    
}

class GerenciadorEntradaSaida {
    
    // Fila de chamadas separadas por id do dispositivo
    var chamadas = [Int : [Chamada]]()
    var chamadasSendoAtendidas = [Int : [Chamada]]()
    
    // Cria a requisição com o pedido de entrada ou saída
    func criarRequisicao(chamada: Chamada) {
        let dispositivo = sistemaOperacional.disco.resgatarDispositivo(id: chamada.dispositivo!)!

        if chamadas[dispositivo.id] == nil {
            chamadas[dispositivo.id] = [Chamada]()
        }
        chamadas[dispositivo.id]?.append(chamada)
        
        if dispositivo.compartilhado && !(chamadasSendoAtendidas[dispositivo.id]?.count == dispositivo.maxChamadas) {
            if chamadasSendoAtendidas[dispositivo.id]?.count == 0 {
                chamadasSendoAtendidas[dispositivo.id] = [chamada]
            } else {
                chamadasSendoAtendidas[dispositivo.id]?.append(chamada)
            }
            agendarRespostaDeRequisicao(dispositivo: dispositivo, chamada: chamada)
            chamada.sendoTratada = true
        } else if chamadasSendoAtendidas[dispositivo.id] == nil {
            chamadasSendoAtendidas[dispositivo.id] = [chamada]
            agendarRespostaDeRequisicao(dispositivo: dispositivo, chamada: chamada)
            chamada.sendoTratada = true
        }
    }
    
    // Com base no tempo de resposta do dispositivo, agenda sua resposta
    func agendarRespostaDeRequisicao(dispositivo: Dispositivo, chamada: Chamada) {
        Timer.scheduledTimer(withTimeInterval: dispositivo.tempoDeResposta * tempoDeClock, repeats: false, block: { _ in
            if dispositivo.compartilhado {
                self.chamadasSendoAtendidas[dispositivo.id]?.removeAll(where: { $0.jobOrigem?.id == chamada.jobOrigem?.id })
            } else {
                self.chamadasSendoAtendidas[dispositivo.id] = nil
            }
            chamada.completa = true
            self.responderRequisicao(dispositivo: dispositivo, chamada: chamada)
            self.atenderNovaChamadaSePreciso(dispositivo: dispositivo)
        })
    }
    
    // Após atender a chamada, atende a próxima chamada para o mesmo dispositivo, se existir
    func atenderNovaChamadaSePreciso(dispositivo: Dispositivo) {
        if dispositivo.compartilhado {
            if let chamada = chamadas[dispositivo.id]?.first(where: { $0.completa == false && !$0.sendoTratada }) {
                agendarRespostaDeRequisicao(dispositivo: dispositivo, chamada: chamada)
            }
        } else if let chamada = chamadas[dispositivo.id]?.first(where: { $0.completa == false }) {
            agendarRespostaDeRequisicao(dispositivo: dispositivo, chamada: chamada)
        }
    }
    
    // Responde a requisição de entrada/saída para um dispositivo
    func responderRequisicao(dispositivo: Dispositivo, chamada: Chamada) {
        _ = sistemaOperacional.disco.resgatarDispositivo(id: chamada.dispositivo!)
        motorDeEventos.respostaPedidoEntradaSaida.onNext(chamada)
    }
    
}

func dispositivoEntradaSaida(id: Int, tempoDeAcesso: Int, dado: Int, compartilhado: Bool, maxChamadas: Int) -> [Instrucao] {
    var dispositivo = [Instrucao]()
    
    dispositivo.append(Instrucao(instrucao: .DEVICE, argumento: id)) // Identificação do dispositivo
    dispositivo.append(Instrucao(instrucao: .DATA, argumento: tempoDeAcesso))
    dispositivo.append(Instrucao(instrucao: .DATA, argumento: dado))
    dispositivo.append(Instrucao(instrucao: .DATA, argumento: compartilhado ? 1 : 0))
    dispositivo.append(Instrucao(instrucao: .DATA, argumento: compartilhado ? maxChamadas : 1))
    
    return dispositivo
}
