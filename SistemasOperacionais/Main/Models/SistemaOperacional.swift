//
//  File.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 26/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

// Variável global para ser usada pelo traffic controller, dispatcher e
let sistemaOperacional = SistemaOperacional()

class SistemaOperacional {
    
    let cpu = CPU()
    var listaDeJobs = [Job]()
    
    // Propriedade que retorna os jobs que estão prontos para execução
    var readyList: [Job] {
        get {
            listaDeJobs.filter { job in job.pcb.estado == .pronto }
        }
    }

}
