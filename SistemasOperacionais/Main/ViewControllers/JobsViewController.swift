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
    
    var cpu = CPU()

    @IBAction func iniciarSimulacao(_ sender: UIButton) {
        cpu.iniciar()
    }
    
    @IBAction func finalizarSimulacao(_ sender: UIButton) {
        cpu.parar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        title = "Simulador"
        marcarInicioDaSimulacao()
    }
}
