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
    let adicionarJob = PublishSubject<Job>()
    let pedirParaExecutarJob = PublishSubject<Job>()
    let jobFinalizouExecucaoId = PublishSubject<Int>()
    
    // Rotinas de Tratamento
    init() {
        adicionarJob.subscribe { job in
            TrafficController.adicionarJob(job: job.element!)
        }.disposed(by: disposeBag)
        
        pedirParaExecutarJob.subscribe { job in
            Dispatcher.pedirParaAlocarProcessoNoProcessador(jobNovo: job.element)
        }.disposed(by: disposeBag)
        
        jobFinalizouExecucaoId.subscribe { id in
            TrafficController.marcarJobComoFinalizado(id: id.element)
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
    }
    
    
}
