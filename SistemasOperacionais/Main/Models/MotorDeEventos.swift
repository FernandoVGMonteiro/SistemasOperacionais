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
    let jobFinalizouExecucao = PublishSubject<Job>()
    let atualizouTempoDoTimeslice = PublishSubject<Int>()
    let fazerPedidoEntradaSaida = PublishSubject<Chamada>()
    let respostaPedidoEntradaSaida = PublishSubject<Chamada>()
    
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
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
        jobFinalizouExecucao.subscribe { job in
            TrafficController.marcarJobComoFinalizado(job: job.element!)
            sistemaOperacional.cpu.proximoProcesso()
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
        atualizouTempoDoTimeslice.subscribe { tempo in
            if tempo.element ?? 0 == tempoMaximoDeTimeslice {
                sistemaOperacional.cpu.proximoProcesso()
                sistemaOperacional.reiniciarTimeslice()
            }
        }.disposed(by: disposeBag)
        
        fazerPedidoEntradaSaida.subscribe { chamada in
            sistemaOperacional.gerenciadorES.criarRequisicao(chamada: chamada.element!)
            TrafficController.passarJobParaFilaDeEntradaSaida(chamada: chamada.element!)
        }.disposed(by: disposeBag)
        
        respostaPedidoEntradaSaida.subscribe { chamada in
            let job = chamada.element!.jobOrigem!
            job.estado = .pronto
            sistemaOperacional.cpu.alocarProcessoEmEsperaES(job: job)
        }.disposed(by: disposeBag)
    }
    
    
}
