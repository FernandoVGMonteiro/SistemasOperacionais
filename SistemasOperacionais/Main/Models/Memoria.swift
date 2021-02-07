//
//  Memoria.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 06/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

class Memoria {
    
    private(set) var tamanho: Int
    private var dados: [Instrucao]
    
    init(tamanho: Int) {
        self.tamanho = tamanho
        dados = [Instrucao](repeating: instrucaoVazia, count: tamanho)
    }
    
    // Lista dos intervalos livres na memória
    var espacosLivres: [Intervalo] {
        get {
            var espacos = [Intervalo]()
            
            var inicio: Int?
            var fim: Int?
            
            for (indice, dado) in dados.enumerated() {
                if dado == instrucaoVazia {
                    if inicio == nil {
                        inicio = indice
                    }
                    
                    if indice == dados.count - 1 {
                        fim = indice
                        espacos.append(inicio!...fim!)
                    }
                } else {
                    if inicio != nil && fim == nil  && indice != 0{
                        fim = indice - 1
                        espacos.append(inicio!...fim!)
                        inicio = nil
                        fim = nil
                    }
                }
            }
            
            return espacos
        }
    }
    
    // Acessa uma posição da memória
    func acessar(posicao: Int) -> Instrucao {
        return dados[posicao]
    }
    
    // Acessa um conjunto de dados na memória
    func acessar(intervalo: Intervalo) -> [Instrucao] {
        return Array(dados[intervalo.lowerBound...intervalo.upperBound])
    }
    
    func alterar(posicao: Int, dado: Int) {
        dados[posicao].salvarDado(dado)
    }
    
    // Adiciona dados na memória e retorna o intervalo que eles foram adicionados
    func carregar(dados: [Instrucao], ajustarEnderecamento: Bool = false) -> Intervalo? {
        let numeroDeInstrucoes = dados.count
        
        for espaco in espacosLivres {
            if espaco.count >= numeroDeInstrucoes {
                var indice = espaco.lowerBound
                let dadosAjustados = ajustarEnderecamento ? ajustarEnderecos(dados: dados, base: indice) : dados
                for instrucao in dadosAjustados {
                    self.dados[indice] = instrucao
                    indice += 1
                }
                
                let inicioDoPrograma = espaco.lowerBound
                let fimDoPrograma = indice - 1
                return inicioDoPrograma...fimDoPrograma
            }
        }
        
        print("MemoriaRAM - A memória está cheia e não comporta mais programas")
        return nil
    }
    
    // Exclui os dados que estavam no intervalo passado e retorna esses dados
    func deletar(intervalo: Intervalo) -> [Instrucao] {
        var memoriaExcluida = [Instrucao]()
        for indice in intervalo {
            memoriaExcluida.append(dados[indice])
            dados[indice] = instrucaoVazia
        }
        return memoriaExcluida
    }
    
    private func ajustarEnderecos(dados: [Instrucao], base: Int) -> [Instrucao] {
        return dados.map {
            Instrucao(instrucao: $0.instrucao,
                      argumento: $0.argumento + ($0.instrucao != .DATA ? base : 0))
        }
    }
    
    func imprimir(esconderVazios: Bool = true) {
        print("\n====== CONTEÚDO DA MEMÓRIA ======\n")
        
        for (indice, dado) in dados.enumerated() {
            if dado != instrucaoVazia {
                print("Posição: \(indice) / Dado: \(dado.imprimir())")
            }
        }
        
        print("\n============")
    }

}
