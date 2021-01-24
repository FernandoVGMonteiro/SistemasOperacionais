//
//  MVN.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

class CPU {
    
    // Variáveis internas
    private var executador: Timer?
    private var pc: Int = 0 // Contador de instruções
    private var ac: Int = 0 // Acumulador
    private var stop: Bool = true // Indica se o processador está parado
    private var cicloDeClock: Int = 0
    private var memoriaDados = [2]
    private var programa = programa1
    
    // Variáveis de controle
    var imprimirEstadoACadaExecucao = true
    var tempoDeClock: TimeInterval = 1 // Em segundos
    
    // Funções públicas
    func iniciar() {
        print("\n====== INICIANDO EXECUÇÃO (\(tempoDeSimulacao())) ======\n")
        executador = Timer.scheduledTimer(withTimeInterval: tempoDeClock, repeats: true, block: { _ in
            self.imprimirEstado()
            self.executarInstrucao()
            self.cicloDeClock += 1
        })
    }
    
    func parar() {
        executador?.invalidate()
        print("\n====== PARANDO EXECUÇÃO ======\n")
    }
    
    // Funções internas
    private func imprimirEstado() {
        print(String(format: "CPU - Clock %i - (%@) PC: %i / AC: %i / Instrução: %@",
                     cicloDeClock,
                     tempoDeSimulacao(),
                     pc,
                     ac,
                     programa[pc].imprimir()))
    }
    
    private func executarInstrucao() {
        if pc >= programa.count {
            print("Erro: Tentando acessar um programa que já atingiu seu final")
            return
        }
        let instrucao = programa[pc]
        decodificarInstrucao(instrucao: instrucao)
    }
    
    func decodificarInstrucao(instrucao: Instrucao) {
        let codigo = instrucao.instrucao
        let argumento = instrucao.argumento
        
        switch codigo {
        case .JUMP:
            pc = argumento
        case .JUMP0:
            if ac == 0 {
                pc = argumento
            }
        case .JUMPN:
            if ac < 0 {
                pc = argumento
            }
        case .ADD:
            ac += memoriaDados[argumento]
            pc += 1
        case .SUB:
            ac -= memoriaDados[argumento]
            pc += 1
        case .MULT:
            ac *= memoriaDados[argumento]
            pc += 1
        case .DIV:
            ac /= memoriaDados[argumento]
            pc += 1
        case .LOAD:
            ac = memoriaDados[argumento]
            pc += 1
        case .STORE:
            memoriaDados[argumento] = ac
            pc += 1
        case .HALT:
            parar()
        case .GET_DATA:
            // TODO
            break
        case .PUT_DATA:
            // TODO
            break
        case .LOAD_PLUS_ONE:
            // TODO
            break
        case .STORE_PLUS_ONE:
            // TODO
            break
        }
    }
    
}
