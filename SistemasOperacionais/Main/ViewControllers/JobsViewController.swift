//
//  JobsViewController.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 16/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class JobsViewController: UIViewController {

    @IBAction func iniciarSimulacao(_ sender: UIButton) {
        motorDeEventos.iniciarSimulacao.onNext(true)
    }
    
    @IBAction func executarPrograma1(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 0, prioridade: .media))
    }
    
    @IBAction func executarPrograma2(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 1, prioridade: .media))
    }
    
    @IBAction func executarPrograma3(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(idPrograma: 2, prioridade: .media))
    }
    
    @IBAction func finalizarSimulacao(_ sender: UIButton) {
        motorDeEventos.finalizarSimulacao.onNext(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        title = "Simulador"
    }
}
