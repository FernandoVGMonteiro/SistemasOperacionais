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

class JobsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var comando: UITextField!
    @IBAction func executarComando(_ sender: UIButton) {
        executar(comando: comando.text ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        comando.delegate = self
        comando.becomeFirstResponder()
    }
    
    private func setup() {
        title = "Shell"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        executar(comando: textField.text ?? "")
        return true
    }
    
    func executar(comando: String) {
        motorDeEventos.decodificarComando(comando: comando)
        self.comando.text = ""
    }
}
