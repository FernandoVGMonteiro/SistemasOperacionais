//
//  SegmentMapTable.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 15/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//


class SegmentMapTable {
    
    var segmentos = [Segmento]()
    
    init(segmentos: [Segmento]) {
        self.segmentos = segmentos
    }
    
    func relocarEnderecos(base: Int) -> SegmentMapTable {
        for segmento in segmentos {
            segmento.intervaloDisco = (segmento.intervaloDisco.lowerBound + base)...(segmento.intervaloDisco.upperBound + base)
        }
        return self
    }
    
    func segmento(enderecoDisco: Int) -> (segmento: Segmento?, indice: Int?) {
        for (indice, segmento) in segmentos.enumerated() {
            if segmento.intervaloDisco.contains(enderecoDisco) {
                return (segmento, indice)
            }
        }
        return (nil, nil)
    }
    
    func imprimir() {
        print("\n------ SEGMENTOS ------\n")
        for segmento in segmentos {
            segmento.imprimir()
        }
        print("\n-----------------------\n")
    }
}

class Segmento {
    
    var job: Job?
    var identificador: String // Nome do segmento
    var intervaloDisco: Intervalo // Intervalo do segmento na memória do programa
    var intervaloProcessador: Intervalo? // Intervalo do segmento na memória do programa
    var programaOrigem: Int? // Identificador do programa original
    var permissao: Bool = false // True - Segmento Público / False - Segmento privado
    var ultimaAlocacao: Int = 0 // Última vez que foi alocado no processador
    
    init(identificador: String, intervalo: Intervalo) {
        self.identificador = identificador
        self.intervaloDisco = intervalo
    }
    
    func imprimir() {
        print("Segmento '\(identificador)' - Intervalo: \(intervaloDisco)")
        
    }
    
}
