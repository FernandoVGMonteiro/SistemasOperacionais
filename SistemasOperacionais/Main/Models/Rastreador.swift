//
//  Rastreador.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 15/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum RastreadorComponente: String {
    case CPU = "Processador"
    case EXPLORADOR = "Explorador de Arquivos"
    case JOB_SCHEDULER = "Job Scheduler"
    case MEMORIA = "Memória"
    case MEMORIA_DETALHES = "Memória (Detalhes)"
    case MEMORIA_DISCO = "Memória Principal"
    case MEMORIA_PROCESSADOR = "Memória do Processador"
    case SEGMENTO = "Segmentos"
    case SHELL = "Interpretador de Comandos"
    case SISTEMA = "Sistema Operacional"
    case TRAFFIC_CONTROLLER = "Traffic Controller"
}

enum RastreadorTipo: String {
    case MENSAGEM = "Mensagem"
    case AVISO = "Aviso"
    case ERRO = "Erro"
}

class Rastreador {

    static var ultimoComponenteRastreado: RastreadorComponente?
    
    static func log(_ tipo: RastreadorTipo, _ componente: RastreadorComponente, _ mensagem: String) {
        // Pular uma linha se mudar o componente rastreado
        var texto = ultimoComponenteRastreado == componente ? "" : "\n"
        texto += "(\(tipo.rawValue)) \(componente): \(mensagem)"
        ultimoComponenteRastreado = componente
        
        print(texto)
    }
    
}

