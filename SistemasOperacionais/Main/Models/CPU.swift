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
    
    // A respeito dos programas em execução
    var jobEmExecucao: Job? = nil
    var segmentoEmExecucao: Segmento? = nil
    
    // Timeslice
    var contadorTimeslice: Int = 0
    
    // Memória do processador
    let memoria = MemoriaProcessador(tamanho: tamanhoDaRAM)
    
    // Funções públicas
    func iniciar() {
        Rastreador.log(.MENSAGEM, .CPU, "====== INICIANDO EXECUÇÃO - \(explorador.nomeDaSimulacaoAtual) ======")
        iniciarTimerDeExecucao()
    }
    
    func alocarProcesso(job: Job) {
        if memoria.processos.contains(where: { $0.id == job.id }) { Rastreador.log(.AVISO, .CPU, "Processo já está na RAM"); return }
        if memoria.numeroDeProgramas == 0 {
            contadorTimeslice = 0
            
            // Estado do processo
            jobEmExecucao = job
            pc = job.variaveisDeProcesso.pc
            ac = job.variaveisDeProcesso.ac
        }
        if !memoria.alocarProcesso(job: job) {
            Rastreador.log(.AVISO, .CPU, "Não foi possível alocar o job \(job.id) no processador")
            return
        }
        Rastreador.log(.MENSAGEM, .CPU, "O job \(job.id) foi alocado no processador")
        memoria.imprimir()
        stop = false
    }
    
    func desalocarProcessoDeMenorPrioridade() {
        guard let jobDeMenorPrioridade = memoria.processoComPrioridadeMaisBaixa
            else { Rastreador.log(.AVISO, .CPU, "Nenhum programa para desalocar"); return }
        
        // Caso seja o que está sendo executado no momento, salva as variáveis de processo
        var estadoParaSalvar: EstadoDoProcesso? = nil
        if jobEmExecucao?.id == jobDeMenorPrioridade.id {
            estadoParaSalvar = (pc, ac)
        }
        
        Rastreador.log(.MENSAGEM, .CPU, "O job \(jobDeMenorPrioridade.id) foi desalocado do processador")
        memoria.desalocarProcesso(job: jobDeMenorPrioridade, estadoDoProcesso: estadoParaSalvar, finalizado: false)
    }
    
    func finalizarProcesso() {
        guard let job = jobEmExecucao else { Rastreador.log(.ERRO, .CPU, "Id de job não encontrado para finalizar"); return }
        Rastreador.log(.MENSAGEM, .CPU, "O job \(job.id) foi desalocado do processador")
        memoria.desalocarProcesso(job: job, estadoDoProcesso: (pc, ac), finalizado: true)
        stop = true
        jobEmExecucao = nil
        motorDeEventos.jobFinalizouExecucao.onNext(job)
        proximoProcesso()
    }
    
    func alocarProcessoEmEsperaES(job: Job) {
        Rastreador.log(.MENSAGEM, .CPU, "Retorno do job \(job.id) que aguardava entrada e saída")
        if (job.prioridade.rawValue < jobEmExecucao?.prioridade.rawValue ?? 0) { return }
        jobEmExecucao?.variaveisDeProcesso = (pc, ac)
        pc = job.variaveisDeProcesso.pc
        ac = job.variaveisDeProcesso.ac
        job.tempos.ultimaExecucao = cicloDeClock
        job.estado = .pronto
        jobEmExecucao = job
        avancarPc()
        stop = false
    }

    func proximoProcesso() {
        Rastreador.log(.MENSAGEM, .CPU, "Troca de processo")
        if let proximoJob = memoria.proximoJobParaExecutar(jobAtual: jobEmExecucao, estado: (pc, ac)) {
            pc = proximoJob.variaveisDeProcesso.pc
            ac = proximoJob.variaveisDeProcesso.ac
            proximoJob.tempos.ultimaExecucao = cicloDeClock
            jobEmExecucao = proximoJob
            stop = false
        }
    }
    
    func parar() {
        executador?.invalidate()
        Rastreador.log(.MENSAGEM, .CPU, "====== PARANDO EXECUÇÃO - \(explorador.nomeDaSimulacaoAtual) ======")
    }
    
    // Funções internas
    private func imprimirEstado() {
        if !sempreImprimirEstadoDaCPU { return }
        let pc = memoria.ajustarPcLogico(pc: self.pc, job: jobEmExecucao!, segmento: segmentoEmExecucao)
        Rastreador.log(.MENSAGEM, .CPU, String(format: "Clock %i - Job %i (Instruções: %@ PC: %i / AC: %i / Instrução: %@",
                     cicloDeClock,
                     jobEmExecucao?.id ?? 999,
                     imprimirNumeroDeInstrucoes(),
                     pc,
                     ac,
                     memoria.acessar(posicao: pc).imprimir()))
    }
    
    private func decodificarInstrucao(instrucao: Instrucao) {
        let codigo = instrucao.instrucao
        let argumento = instrucao.argumento
        var endereco = argumento
        if explorador.administracaoMemoria == .particao {
            endereco = memoria.traduzirParaEnderecoLogico(enderecoFisico: argumento,
                                                              job: jobEmExecucao!,
                                                              segmento: segmentoEmExecucao)
        }
        
        switch codigo {
        case .JUMP:
            pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!, segmento: segmentoEmExecucao)
        case .JUMP0:
            if ac == 0 {
                pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!, segmento: segmentoEmExecucao)
            } else {
                avancarPc()
            }
        case .JUMPN:
            if ac < 0 {
                pc = memoria.ajustarPcReal(pc: endereco, job: jobEmExecucao!, segmento: segmentoEmExecucao)
            } else {
                avancarPc()
            }
        case .ADD:
            ac += memoria.acessar(posicao: endereco).carregarDado()
            avancarPc()
        case .SUB:
            ac -= memoria.acessar(posicao: endereco).carregarDado()
            avancarPc()
        case .MULT:
            ac *= memoria.acessar(posicao: endereco).carregarDado()
            avancarPc()
        case .DIV:
            ac /= memoria.acessar(posicao: endereco).carregarDado()
            avancarPc()
        case .LOAD:
            ac = memoria.acessar(posicao: endereco).carregarDado()
            avancarPc()
        case .STORE:
            memoria.alterar(posicao: endereco, dado: ac)
            avancarPc()
        case .HALT:
            finalizarProcesso()
        case .GET_DATA:
            if let conteudo = explorador.fitaDeEntrada?.lerDaFita() {
                ac = conteudo
            } else {
                Rastreador.log(.ERRO, .CPU, "Não foi possível recuperar o dado da fita perfurada")
            }
            avancarPc()
        case .PUT_DATA:
            explorador.fitaDeSaida?.escreverNaFita(conteudo: ac)
            avancarPc()
            break
        case .DEVICE_IN:
            let chamada = Chamada()
            chamada.jobOrigem = jobEmExecucao
            chamada.dispositivo = argumento
            chamada.tipo = .entrada
            motorDeEventos.fazerPedidoEntradaSaida.onNext(chamada)
            stop = true
            proximoProcesso()
            break
        case .DEVICE_OUT:
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
            Rastreador.log(.ERRO, .CPU, "Instrução inválida \(codigo)")
            break
        }
    }
    
    private func avancarPc() {
        switch explorador.administracaoMemoria {
        case .particao:
            pc += 1
        case .segmento:
            break
        }
    }
    
    private func executarInstrucao() {
        var pc = self.pc
        if explorador.administracaoMemoria == .particao {
            pc = memoria.ajustarPcLogico(pc: self.pc, job: jobEmExecucao!, segmento: segmentoEmExecucao)
        }
        let instrucao = memoria.dados[pc]
        decodificarInstrucao(instrucao: instrucao)
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
//            if self.cicloDeClock == 0 {
//                motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 0, prioridade: explorador.prioridade))
//            } else if self.cicloDeClock == 20 {
//                motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 1, prioridade: explorador.prioridade))
//                motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 2, prioridade: explorador.prioridade))
//            } else if self.cicloDeClock == 40 {
//                motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 3, prioridade: explorador.prioridade))
//            }
            if self.processadorEmEspera() {
                self.memoria.processos.incrementarTempoNoProcessador()
                self.cicloDeClock += 1
                if sempreImprimirEstadoDaCPU {
                    Rastreador.log(.MENSAGEM, .CPU, String(format: "Clock %i - Processador em espera", self.cicloDeClock))
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
