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
    let atualizouListaDeJobs = PublishSubject<Bool>()
    
    // Rotinas de Tratamento
    init() {
        adicionarJob.subscribe { job in
            TrafficController.adicionarJob(job: job.element!)
        }.disposed(by: disposeBag)
        
        atualizouListaDeJobs.subscribe { sucesso in
            if sucesso.element! {
                // If nenhum processo executando
                Dispatcher.alocaProcessoNoProcessador()
            }
        }.disposed(by: disposeBag)
    }
    
    
}
