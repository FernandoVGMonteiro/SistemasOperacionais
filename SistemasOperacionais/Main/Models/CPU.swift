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
typealias EstadoDoProcesso = (pc: Int, ac: Int, dados: [Instrucao])

class CPU {
    
    // Variáveis internas
    private var executador: Timer?
    private var pc: Int = 0 // Contador de instruções
    private var ac: Int = 0 // Acumulador
    private var stop: Bool = true // Indica se o processador está parado
    var cicloDeClock: Int = 0
    
    // A respeito do job em execução
    var tempoDeUtilizacaoDoProcessador: Int = 0
    var idDoJobEmExecucao: Int? = nil
    var temposDoJobEmExecucao: JobTempos? = nil
    
    // Timeslice
    var contadorTimeslice: Int = 0
    
    // Memória do processador
    let memoria = MemoriaRAM()
    
    // Funções públicas
    func iniciar() {
        print("\n====== INICIANDO EXECUÇÃO ======\n")
        iniciarTimerDeExecucao()
    }
    
    func alocarProcesso(id: Int, estado: EstadoDoProcesso, tempos: JobTempos) {
        iniciarTimerDeExecucao()
        if !memoria.alocarProcesso(id: id, instrucoes: estado.dados) {
            print("CPU - Não foi possível alocar o job \(id) no processador")
            return
        }
        print("CPU - O job \(id) foi alocado no processador")
        stop = false
        contadorTimeslice = 0

        // Tempos do processo
        temposDoJobEmExecucao = tempos
        temposDoJobEmExecucao?.ultimaAlocacaoNoProcessador = cicloDeClock
        
        // Estado do processo
        idDoJobEmExecucao = id
        pc = estado.pc
        ac = estado.ac
    }
    
    func desalocarProcesso() -> EstadoDoProcesso? {
        guard let id = idDoJobEmExecucao else { print("CPU - Nenhum programa para desalocar"); return nil }
        executador?.invalidate()
        stop = true
        print("CPU - O job \(id) foi desalocado do processador")
        pedirParaAtualizarTemposDoJob(ajustarTempoDeProcessamento: true)
        memoria.desalocarProcesso(idPrograma: id, idProcesso: 0, pc: pc, ac: ac, finalizado: false)
        idDoJobEmExecucao = nil
        return EstadoDoProcesso(pc, ac, memoria.dados)
    }
    
    func finalizarProcesso() {
        guard let id = idDoJobEmExecucao else { print("CPU - Id de job não encontrado para finalizar"); return }
        print("CPU - O job \(id) foi desalocado do processador")
        pedirParaAtualizarTemposDoJob()
        memoria.desalocarProcesso(idPrograma: id, idProcesso: 0, pc: pc, ac: ac, finalizado: true)
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
        if !sempreImprimirEstadoDaCPU { return }
        print(String(format: "CPU - Clock %i - Job %i (Instruções: \(imprimirNumeroDeInstrucoes()) PC: %i / AC: %i / Instrução: %@",
                     cicloDeClock,
                     idDoJobEmExecucao ?? 999,
                     pc,
                     ac,
                     memoria.dados[pc].imprimir()))
    }
    
    private func executarInstrucao() {
        let instrucao = memoria.dados[pc]
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
            ac += memoria.dados[argumento].carregarDado()
            pc += 1
        case .SUB:
            ac -= memoria.dados[argumento].carregarDado()
            pc += 1
        case .MULT:
            ac *= memoria.dados[argumento].carregarDado()
            pc += 1
        case .DIV:
            ac /= memoria.dados[argumento].carregarDado()
            pc += 1
        case .LOAD:
            ac = memoria.dados[argumento].carregarDado()
            pc += 1
        case .LOADI:
            ac = argumento
            pc += 1
        case .STORE:
            memoria.dados[argumento].salvarDado(ac)
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
        default:
            print("Erro: Instrução inválida \(codigo)")
            break
            
        }
    }
    
    private func processadorEmEspera() -> Bool {
        return pc >= memoria.dados.count || stop
    }
    
    private func imprimirNumeroDeInstrucoes() -> String {
        return String(format: "%i/%i",
                      temposDoJobEmExecucao?.utilizacaoDoProcessador ?? 0,
                      temposDoJobEmExecucao?.tempoAproximadoDeExecucao ?? 0)
    }
    
    private func pedirParaAtualizarTemposDoJob(ajustarTempoDeProcessamento: Bool = false) {
        let temposParaAtualizar = TemposParaAtualizar(
            id: idDoJobEmExecucao,
            tempos: temposDoJobEmExecucao,
            tempoDeProcessamento: temposDoJobEmExecucao?.utilizacaoDoProcessador ?? 0)
        motorDeEventos.pedirParaAtualizarOsTemposDoJob.onNext(temposParaAtualizar)
    }
    
    private func iniciarTimerDeExecucao() {
        executador?.invalidate()
        executador = Timer.scheduledTimer(withTimeInterval: tempoDeClock, repeats: true, block: { _ in
            if self.processadorEmEspera() {
                if sempreImprimirEstadoDaCPU {
                    print(String(format: "CPU - Clock %i - Processador em espera", self.cicloDeClock))
                }
                self.cicloDeClock += 1
                return
            }
            self.cicloDeClock += 1
            self.contadorTimeslice += 1
            self.temposDoJobEmExecucao?.utilizacaoDoProcessador += 1
            self.imprimirEstado()
            self.executarInstrucao()
            motorDeEventos.atualizouTempoDoTimeslice.onNext(self.contadorTimeslice)
        })
    }
    
}
