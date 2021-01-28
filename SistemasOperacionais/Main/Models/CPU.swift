//
//  MVN.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Descreve o estado do processo no processador, permitindo que
// um processo possa ser desalocado e posteriormente realocado
// conservando o estado em que estava sua execução
typealias EstadoDoProcesso = (pc: Int, ac: Int, memoriaDados: [Int], memoriaInstrucoes: [Instrucao])

class CPU {
    
    // Variáveis internas
    private var executador: Timer?
    private var pc: Int = 0 // Contador de instruções
    private var ac: Int = 0 // Acumulador
    private var stop: Bool = true // Indica se o processador está parado
    private var cicloDeClock: Int = 0
    
    // A respeito do job em execução
    var idDoJobEmExecucao: Int? = nil
    
    #warning("TODO - Timeslice")
    // Variáveis de Timeslice
    private var contadorTimeslice: Int = 0
    private var maximoTempoTimeslice: Int = 10 // Tempo máximo do Timeslice em ciclos de clock
    
    // Memória do processadore
    private var memoriaDados = [Int](repeating: 0, count: 16)
    private var memoriaInstrucoes = [Instrucao]()
    
    // Variáveis de controle
    var tempoDeClock: TimeInterval = 0.5 // Em segundos
    
    // Funções públicas
    func iniciar() {
        executador = Timer.scheduledTimer(withTimeInterval: tempoDeClock, repeats: true, block: { _ in
            if self.processadorEmEspera() {
                print(String(format: "CPU - Clock %i - Processador em espera", self.cicloDeClock))
                self.cicloDeClock += 1
                return
            }
            self.imprimirEstado()
            self.executarInstrucao()
            self.cicloDeClock += 1
        })
    }
    
    func alocarProcesso(id: Int, estado: EstadoDoProcesso) {
        print("O job \(id) foi alocado no processador")
        idDoJobEmExecucao = id
        pc = estado.pc
        ac = estado.ac
        memoriaDados = estado.memoriaDados
        memoriaInstrucoes = estado.memoriaInstrucoes
        stop = false
    }
    
    func desalocarProcesso() -> EstadoDoProcesso {
        stop = true
        print("O job \(idDoJobEmExecucao ?? 999) foi desalocado do processador")
        idDoJobEmExecucao = nil
        return EstadoDoProcesso(pc, ac, memoriaDados, memoriaInstrucoes)
    }
    
    func finalizarProcesso() {
        guard let id = idDoJobEmExecucao else { print("CPU - Id de job não encontrado para finalizar"); return }
        stop = true
        idDoJobEmExecucao = nil
        motorDeEventos.jobFinalizouExecucaoId.onNext(id)
    }
    
    func parar() {
        executador?.invalidate()
        print("\n====== PARANDO EXECUÇÃO ======\n")
    }
    
    // Funções internas
    private func imprimirEstado() {
        print(String(format: "CPU (Job \(idDoJobEmExecucao ?? 999)) - Clock %i - (%@) PC: %i / AC: %i / Instrução: %@",
                     cicloDeClock,
                     tempoDeSimulacao(),
                     pc,
                     ac,
                     memoriaInstrucoes[pc].imprimir()))
    }
    
    private func executarInstrucao() {
        let instrucao = memoriaInstrucoes[pc]
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
            } else {
                pc += 1
            }
        case .JUMPN:
            if ac < 0 {
                pc = argumento
            } else {
                pc += 1
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
        case .LOADI:
            ac = argumento
            pc += 1
        case .STORE:
            memoriaDados[argumento] = ac
            pc += 1
        case .HALT:
            finalizarProcesso()
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
    
    private func processadorEmEspera() -> Bool {
        return pc >= memoriaInstrucoes.count || stop
    }
    
}
