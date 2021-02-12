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
typealias EstadoDoProcesso = (pc: Int, ac: Int)

class CPU {
    
    // Variáveis internas
    private var executador: Timer?
    private var pc: Int = 0 // Contador de instruções
    private var ac: Int = 0 // Acumulador
    private var stop: Bool = true // Indica se o processador está parado
    var cicloDeClock: Int = 0
    
    // A respeito do job em execução
    var jobEmExecucao: Job? = nil
    
    // Timeslice
    var contadorTimeslice: Int = 0
    
    // Memória do processador
    let memoria = MemoriaRAM(tamanho: tamanhoDaRAM)
    
    // Funções públicas
    func iniciar() {
        print("\n====== INICIANDO EXECUÇÃO ======\n")
        iniciarTimerDeExecucao()
    }
    
    func alocarProcesso(job: Job) {
        if memoria.processos.contains(where: { $0.id == job.id }) { print("Processo já está na RAM"); return }
        if memoria.numeroDeProgramas == 0 {
            contadorTimeslice = 0
            
            // Estado do processo
            jobEmExecucao = job
            pc = job.variaveisDeProcesso.pc
            ac = job.variaveisDeProcesso.ac
        }
        if !memoria.alocarProcesso(job: job) {
            print("CPU - Não foi possível alocar o job \(job.id) no processador")
            return
        }
        print("CPU - O job \(job.id) foi alocado no processador")
        memoria.imprimir()
        stop = false
    }
    
    func desalocarProcessoDeMenorPrioridade() {
        guard let jobDeMenorPrioridade = memoria.processoComPrioridadeMaisBaixa
            else { print("CPU - Nenhum programa para desalocar"); return }
        
        // Caso seja o que está sendo executado no momento, salva as variáveis de processo
        var estadoParaSalvar: EstadoDoProcesso? = nil
        if jobEmExecucao?.id == jobDeMenorPrioridade.id {
            estadoParaSalvar = (pc, ac)
        }
        
        print("CPU - O job \(jobDeMenorPrioridade.id) foi desalocado do processador")
        memoria.desalocarProcesso(job: jobDeMenorPrioridade, estadoDoProcesso: estadoParaSalvar, finalizado: false)
    }
    
    func finalizarProcesso() {
        guard let job = jobEmExecucao else { print("CPU - Id de job não encontrado para finalizar"); return }
        print("CPU - O job \(job.id) foi desalocado do processador")
        memoria.desalocarProcesso(job: job, estadoDoProcesso: (pc, ac), finalizado: true)
        stop = true
        jobEmExecucao = nil
        motorDeEventos.jobFinalizouExecucao.onNext(job)
        proximoProcesso()
    }
    
    func proximoProcesso() {
        print("CPU - Troca de processo")
        if let proximoJob = memoria.proximoJobParaExecutar(jobAtual: jobEmExecucao, estado: (pc, ac)) {
            pc = proximoJob.variaveisDeProcesso.pc
            ac = proximoJob.variaveisDeProcesso.ac
            proximoJob.tempos.ultimaExecucao = cicloDeClock
            jobEmExecucao = proximoJob
            stop = false
        }
    }
    
    // Aloca processo que estava esperando dispositivo de Entrada e Saída
    func alocarProcessoEmEsperaES(job: Job) {
        print("CPU - Retorno do job \(job.id) que aguardava entrada e saída")
        if (job.prioridade.rawValue < jobEmExecucao?.prioridade.rawValue ?? 0) { return }
        jobEmExecucao?.variaveisDeProcesso = (pc, ac)
        pc = job.variaveisDeProcesso.pc
        ac = job.variaveisDeProcesso.ac
        job.tempos.ultimaExecucao = cicloDeClock
        job.estado = .pronto
        jobEmExecucao = job
        pc += 1
        stop = false
    }
    func parar() {
        executador?.invalidate()
        print("\n====== PARANDO EXECUÇÃO ======\n")
    }
    
    // Funções internas
    private func imprimirEstado() {
        if !sempreImprimirEstadoDaCPU { return }
        let pc = memoria.ajustarPcLogico(pc: self.pc, job: jobEmExecucao!)
        print(String(format: "CPU - Clock %i - Job %i (Instruções: \(imprimirNumeroDeInstrucoes()) PC: %i / AC: %i / Instrução: %@",
                     cicloDeClock,
                     jobEmExecucao?.id ?? 999,
                     pc,
                     ac,
                     memoria.acessar(posicao: pc).imprimir()))
    }
    
    private func executarInstrucao() {
        let pc = memoria.ajustarPcLogico(pc: self.pc, job: jobEmExecucao!)
        let instrucao = memoria.acessar(posicao: pc)
        decodificarInstrucao(instrucao: instrucao)
    }
    
    func decodificarInstrucao(instrucao: Instrucao) {
        let codigo = instrucao.instrucao
        let argumento = instrucao.argumento
        let endereco = memoria.traduzirParaEnderecoLogico(enderecoFisico: argumento,
                                                          job: jobEmExecucao!)
        
        switch codigo {
        case .JUMP:
            pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!)
        case .JUMP0:
            if ac == 0 {
                pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!)
            } else {
                pc += 1
            }
        case .JUMPN:
            if ac < 0 {
                pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!)
            } else {
                pc += 1
            }
        case .ADD:
            ac += memoria.acessar(posicao: endereco).carregarDado()
            pc += 1
        case .SUB:
            ac -= memoria.acessar(posicao: endereco).carregarDado()
            pc += 1
        case .MULT:
            ac *= memoria.acessar(posicao: endereco).carregarDado()
            pc += 1
        case .DIV:
            ac /= memoria.acessar(posicao: endereco).carregarDado()
            pc += 1
        case .LOAD:
            ac = memoria.acessar(posicao: endereco).carregarDado()
            pc += 1
        case .STORE:
            memoria.alterar(posicao: endereco, dado: ac)
            pc += 1
        case .HALT:
            finalizarProcesso()
        case .GET_DATA:
            let chamada = Chamada()
            chamada.jobOrigem = jobEmExecucao
            chamada.dispositivo = argumento
            chamada.tipo = .entrada
            motorDeEventos.fazerPedidoEntradaSaida.onNext(chamada)
            stop = true
            proximoProcesso()
            break
        case .PUT_DATA:
            let chamada = Chamada()
            chamada.jobOrigem = jobEmExecucao
            chamada.dispositivo = argumento
            chamada.tipo = .saida
            chamada.dado = ac
            motorDeEventos.fazerPedidoEntradaSaida.onNext(chamada)
            stop = true
            proximoProcesso()
            break
        default:
            print("Erro: Instrução inválida \(codigo)")
            break
        }
    }
    
    private func processadorEmEspera() -> Bool {
        return pc >= memoria.tamanho || stop
    }
    
    private func imprimirNumeroDeInstrucoes() -> String {
        return String(format: "%i/%i",
                      jobEmExecucao?.tempos.tempoDeExecucao ?? 0,
                      jobEmExecucao?.tempos.tempoAproximadoDeExecucao ?? 0)
    }
    
    private func iniciarTimerDeExecucao() {
        executador?.invalidate()
        executador = Timer.scheduledTimer(withTimeInterval: tempoDeClock, repeats: true, block: { _ in
            if self.processadorEmEspera() {
                self.memoria.processos.incrementarTempoNoProcessador()
                self.cicloDeClock += 1
                if sempreImprimirEstadoDaCPU {
                    print(String(format: "CPU - Clock %i - Processador em espera", self.cicloDeClock))
                }
                return
            }
            self.cicloDeClock += 1
            self.contadorTimeslice += 1
            self.jobEmExecucao?.tempos.tempoDeExecucao += 1
            self.jobEmExecucao?.tempos.ultimaExecucao = self.cicloDeClock
            self.memoria.processos.incrementarTempoNoProcessador()
            self.imprimirEstado()
            self.executarInstrucao()
            motorDeEventos.atualizouTempoDoTimeslice.onNext(self.contadorTimeslice)
        })
    }
    
}
