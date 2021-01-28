//
//  MotorDeEventos.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let motorDeEventos = MotorDeEventos()

class MotorDeEventos {
    
    // Variáveis auxiliares
    let disposeBag = DisposeBag()
    
    // Componentes do Sistema
    let cpu = CPU()
    
    // Eventos
    let iniciarSimulacao = PublishSubject<Bool>()
    let finalizarSimulacao = PublishSubject<Bool>()
    let adicionarJob = PublishSubject<Job>()
    let pedirParaExecutarJob = PublishSubject<Job>()
    let pedirParaAtualizarOsTemposDoJob = PublishSubject<TemposParaAtualizar>()
    let jobFinalizouExecucaoId = PublishSubject<Int>()
    
    // Rotinas de Tratamento
    init() {
        iniciarSimulacao.subscribe { sucesso in
            if sucesso.element ?? false {
                sistemaOperacional.cpu.iniciar()
            }
        }.disposed(by: disposeBag)
        
        finalizarSimulacao.subscribe { sucesso in
            if sucesso.element ?? false {
                sistemaOperacional.cpu.parar()
                sistemaOperacional.imprimirRelatorioDaSimulacao()
            }
        }.disposed(by: disposeBag)

        adicionarJob.subscribe { job in
            TrafficController.adicionarJob(job: job.element!)
        }.disposed(by: disposeBag)
        
        pedirParaExecutarJob.subscribe { job in
            Dispatcher.pedirParaAlocarProcessoNoProcessador(jobNovo: job.element)
        }.disposed(by: disposeBag)
        
        pedirParaAtualizarOsTemposDoJob.subscribe { temposParaAtualizar in
            guard
                let id = temposParaAtualizar.element?.id,
                let tempos = temposParaAtualizar.element?.tempos,
                let tempoDeProcessamento = temposParaAtualizar.element?.tempoDeProcessamento else {
                print("Motor de Eventos - Não foi possível atualizar os tempos do job"); return }
            TrafficController.atualizarTemposDoJob(
                id: id,
                tempos: tempos,
                tempoDeUtilizacaoDoProcessador: tempoDeProcessamento)
        }.disposed(by: disposeBag)
        
        jobFinalizouExecucaoId.subscribe { id in
            TrafficController.marcarJobComoFinalizado(id: id.element)
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
    }
    
    
}
