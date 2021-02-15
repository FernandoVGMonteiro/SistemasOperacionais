//
//  Memoria.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 06/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

enum AdministracaoMemoria {
    case particao
    case segmento
}

class Memoria {
    
    // Variáveis de inicialização
    var tamanho: Int
    var dados: [Instrucao]
    
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
        Rastreador.log(.MENSAGEM, .MEMORIA_DETALHES, "Carregando dados na memória")

        for espaco in espacosLivres {
            if espaco.count >= numeroDeInstrucoes {
                var indice = espaco.lowerBound
                if ajustarEnderecamento {
                    Rastreador.log(.MENSAGEM, .MEMORIA_DETALHES, "Ajustando endereçamento com a base \(indice)")
                }
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
        
        Rastreador.log(.AVISO, .MEMORIA_PROCESSADOR, "A memória está cheia e não comporta mais programas")
        return nil
    }
    
    // Exclui os dados que estavam no intervalo passado e retorna esses dados
    func deletar(intervalo: Intervalo) -> [Instrucao] {
        Rastreador.log(.MENSAGEM, .MEMORIA_DETALHES, "Excluindo dados da memória")
        var memoriaExcluida = [Instrucao]()
        for indice in intervalo {
            memoriaExcluida.append(dados[indice])
            dados[indice] = instrucaoVazia
        }
        return memoriaExcluida
    }
    
    // Ajusta os endereços para endereços absolutos
    private func ajustarEnderecos(dados: [Instrucao], base: Int) -> [Instrucao] {
        return dados.map {
            // Endereços não devem ser ajustados no caso de campos de dados ou dispositivos de ES
            Instrucao(instrucao: $0.instrucao,
                      argumento: $0.argumento + (
                            $0.instrucao != .DATA &&
                            $0.instrucao != .DEVICE &&
                            $0.instrucao != .DEVICE_IN &&
                            $0.instrucao != .DEVICE_OUT &&
                            $0.instrucao != .PUT_DATA &&
                            $0.instrucao != .GET_DATA ? base : 0))
        }
    }
    
    // Imprime o estado da memória
    func imprimir(esconderVazios: Bool = true) {
        Rastreador.log(.MENSAGEM, .MEMORIA, "====== CONTEÚDO DA MEMÓRIA ======")
        
        for (indice, dado) in dados.enumerated() {
            if dado != instrucaoVazia {
                Rastreador.log(.MENSAGEM, .MEMORIA, "Posição: \(indice) / Dado: \(dado.imprimir())")
            }
        }
        
        Rastreador.log(.MENSAGEM, .MEMORIA, "============")
    }

}
