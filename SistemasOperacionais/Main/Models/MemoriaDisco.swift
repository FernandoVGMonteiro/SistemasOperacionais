//
//  Memoria.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 01/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

enum TipoArquivo {
    case programa
    case dados
}

// Arquivos podem conter dados ou programas para serem executados
struct Arquivo {
    
    // Informações sobre o arquivo
    var id: Int = 999
    var tipo: TipoArquivo?
    
    // Privacidade
    var publico: Bool = true
    var acessoPermitido = [Int]() // Id dos arquivos que podem acessar
    
    // Conteúdo
    var conteudo = [Instrucoes]()
    
}

// Este é o disco de memória, acessos a ele contam como Entrada/Saída
class MemoriaDisco {
    
    var tamanho: Int { get { conteudo.count } }
    var conteudo = [Instrucoes]()
    var tempoDeAcesso = 2 // Em ciclos de clock
    
}
