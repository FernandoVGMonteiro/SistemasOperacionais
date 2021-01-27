//
//  Utility.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

var dataDeInicio: Date?

func marcarInicioDaSimulacao() {
    dataDeInicio = Date()
    print("\n====== INICIANDO EXECUÇÃO (\(tempoDeSimulacao())) ======\n")
}

func tempoDeSimulacao() -> String {
    guard let dataDeInicio = dataDeInicio else {
        print("Erro: A simulação ainda não começou")
        return ""
    }
    let intervalo = Date().timeIntervalSince(dataDeInicio)
    return formatarData(data: Date(timeInterval: intervalo, since: Calendar.current.startOfDay(for: Date())))
}

func formatarData(data: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter.string(from: data)
}

