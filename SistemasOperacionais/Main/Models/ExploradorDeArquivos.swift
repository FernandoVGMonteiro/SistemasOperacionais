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
    
    var credenciais = (usuario: "admin", senha: "1234")
    var usuarioLogado: Usuario?
    var indiceDiretorio = 0
    var diretorioAtual = home
    
    func irParaDiretorio(nome: String) {
        if let novaPasta = diretorioAtual.pastas.first(where: { $0.nome == nome }) {
            indiceDiretorio += 1
            diretorioAtual = novaPasta
        } else {
            print("Explorador - Pasta não encontrada '\(nome)'")
        }
    }
    
    func fazerLogin(usuario: String, senha: String) {
        if usuario == credenciais.usuario && senha == credenciais.senha {
            usuarioLogado = (usuario, senha)
            print("Explorador - Usuário logado com sucesso!")
        } else {
            print("Explorador - Não foi possível fazer login! Credenciais inválidas!")
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
        print("Explorador - Pasta criada '\(nome)'")
    }
    
    func excluirPasta(nome: String) {
        if pastas.contains(where: { $0.nome == nome }) {
            pastas.removeAll(where: { $0.nome == nome })
            print("Explorador - Pasta excluída '\(nome)'")
        } else {
            print("Explorador - Pasta não encontrada '\(nome)'")
        }
    }
    
    func arquivo(nome: String) -> Arquivo? {
        return arquivos.first(where: { $0.nome == nome })
    }
    
    func novoArquivo(nome: String) {
        arquivos.append(Arquivo(nome: nome))
        print("Explorador - Arquivo criado '\(nome)'")
    }
    
    func excluirArquivo(nome: String) {
        if arquivos.contains(where: { $0.nome == nome }) {
            arquivos.removeAll(where: { $0.nome == nome })
            print("Explorador - Arquivo excluído '\(nome)'")
        } else {
            print("Explorador - Arquivo não encontrado '\(nome)'")
        }
    }
    
    func listar() {
        print("\n=== Diretório: \(nome) ===\n")
        print("--> Pastas (\(pastas.count)): \(nomesPastas.joined(separator: " / "))")
        print("--> Arquivos (\(arquivos.count)): \(nomesArquivos.joined(separator: " / "))\n")
        print("============\n")
    }
    
}

class Arquivo {
    
    var nome: String
    var conteudo = ""
    
    init(nome: String) {
        self.nome = nome
    }
    
    func listar() {
        print("\n=== Arquivo: \(nome) ===\n")
        print("\(conteudo)\n")
        print("============\n")
    }
    
    func escrever(conteudo: String) {
        self.conteudo += conteudo
        listar()
    }
    
}
