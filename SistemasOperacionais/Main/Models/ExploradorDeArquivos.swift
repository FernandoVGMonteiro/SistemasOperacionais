//
//  ExploradorDeArquivos.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 13/02/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation

var home = Pasta(nome: "home")
typealias Usuario = (usuario: String, senha: String)

class ExploradorDeArquivos {
    
    // Variáveis internas
    var credenciais = (usuario: "admin", senha: "1234")
    var usuarioLogado: Usuario?
    var indiceDiretorio = 0
    var diretorioAtual = home

    // Variáveis do Shell
    var nomeDaSimulacaoAtual = ""
    var arquivoAberto: String?
    var fitaDeEntrada: Arquivo?
    var fitaDeSaida: Arquivo?
    var prioridade: JobPrioridades = .media
    var administracaoMemoria: AdministracaoMemoria = .particao
    
    func irParaDiretorio(nome: String) {
        if let novaPasta = diretorioAtual.pastas.first(where: { $0.nome == nome }) {
            indiceDiretorio += 1
            diretorioAtual = novaPasta
        } else {
            Rastreador.log(.MENSAGEM, .EXPLORADOR, "Pasta não encontrada '\(nome)'")
        }
    }
    
    func fazerLogin(usuario: String, senha: String) {
        if usuario == credenciais.usuario && senha == credenciais.senha {
            usuarioLogado = (usuario, senha)
            Rastreador.log(.MENSAGEM, .EXPLORADOR, "Usuário logado com sucesso!")
        } else {
            Rastreador.log(.ERRO, .EXPLORADOR, "Não foi possível fazer login! Credenciais inválidas!")
        }
    }
    
}

class Pasta {
    
    var nome: String
    var pastas = [Pasta]()
    var arquivos = [Arquivo]()
    var nomesPastas: [String] {
        get {
            return pastas.map { $0.nome }
        }
    }
    var nomesArquivos: [String] {
        get {
            return arquivos.map { $0.nome }
        }
    }

    init(nome: String) {
        self.nome = nome
    }
    
    func novaPasta(nome: String) {
        pastas.append(Pasta(nome: nome))
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "Pasta criada '\(nome)'")
    }
    
    func excluirPasta(nome: String) {
        if pastas.contains(where: { $0.nome == nome }) {
            pastas.removeAll(where: { $0.nome == nome })
            Rastreador.log(.MENSAGEM, .EXPLORADOR, "Pasta excluída '\(nome)'")
        } else {
            Rastreador.log(.ERRO, .EXPLORADOR, "Pasta não encontrada '\(nome)'")
        }
    }
    
    func arquivo(nome: String) -> Arquivo? {
        return arquivos.first(where: { $0.nome == nome })
    }
    
    func novoArquivo(nome: String) {
        arquivos.append(Arquivo(nome: nome))
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "Arquivo criado '\(nome)'")
    }
    
    func excluirArquivo(nome: String) {
        if arquivos.contains(where: { $0.nome == nome }) {
            arquivos.removeAll(where: { $0.nome == nome })
            Rastreador.log(.MENSAGEM, .EXPLORADOR, "Arquivo excluído '\(nome)'")
        } else {
            Rastreador.log(.ERRO, .EXPLORADOR, "Arquivo não encontrado '\(nome)'")
        }
    }
    
    func listar() {
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "=== Diretório: \(nome) ===")
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "--> Pastas (\(pastas.count)): \(nomesPastas.joined(separator: " / "))")
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "--> Arquivos (\(arquivos.count)): \(nomesArquivos.joined(separator: " / "))")
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "============")
    }
    
}

class Arquivo {
    
    var nome: String
    var conteudo = ""
    var indiceLeituraFita = 0
    
    init(nome: String) {
        self.nome = nome
    }
    
    func listar() {
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "=== Arquivo: \(nome) ===")
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "\(conteudo)")
        Rastreador.log(.MENSAGEM, .EXPLORADOR, "============")
    }
    
    func escrever(conteudo: String) {
        self.conteudo += conteudo
        listar()
    }
    
    func escreverNaFita(conteudo: Int) {
        self.conteudo += String(conteudo)
    }
    
    func lerDaFita() -> Int? {
        if indiceLeituraFita >= conteudo.count {
            Rastreador.log(.ERRO, .EXPLORADOR, "Posição da fita inacessível para leitura")
            return nil
        }
        
        indiceLeituraFita += 1
        return Int(Array(arrayLiteral: conteudo)[indiceLeituraFita])
    }
    
}
