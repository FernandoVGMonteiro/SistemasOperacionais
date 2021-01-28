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
        #warning("Passar para o motor de eventos")
        sistemaOperacional.cpu.iniciar()
    }
    
    @IBAction func adicionarJobAltaPrioridade(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(
            prioridade: .alta,
            tempoAproximadoDeExecucao: tempoDaContagem(3),
            instrucoes: contador(3)))
    }
    
    @IBAction func adicionarJobMediaPrioridade(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(
            prioridade: .media,
            tempoAproximadoDeExecucao: tempoDaContagem(5),
            instrucoes: contador(5)))
    }
    
    @IBAction func adicionarJobBaixaPrioridade(_ sender: UIButton) {
        motorDeEventos.adicionarJob.onNext(criarJob(
            prioridade: .baixa,
            tempoAproximadoDeExecucao: tempoDaContagem(10),
            instrucoes: contador(10)))
    }
    
    @IBAction func finalizarSimulacao(_ sender: UIButton) {
        #warning("Passar para o motor de eventos")
        sistemaOperacional.cpu.parar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        title = "Simulador"
    }
}
