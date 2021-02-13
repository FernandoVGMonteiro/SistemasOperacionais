//
//  MotorDeEventos.swift
//  SistemasOperacionais
//
//  Created by Fernando Vicente Grando Monteiro on 24/01/21.
//  Copyright © 2021 Fernando Vicente Grando Monteiro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let motorDeEventos = MotorDeEventos()

class MotorDeEventos {
    
    // Variáveis auxiliares
    let disposeBag = DisposeBag()
    
    // Componentes do Sistema
    let cpu = CPU()
    
    // Eventos
    let iniciarSimulacao = PublishSubject<Bool>()
    let finalizarSimulacao = PublishSubject<Bool>()
    let adicionarJob = PublishSubject<Job>()
    let pedirParaExecutarJob = PublishSubject<Job>()
    let jobFinalizouExecucao = PublishSubject<Job>()
    let atualizouTempoDoTimeslice = PublishSubject<Int>()
    let fazerPedidoEntradaSaida = PublishSubject<Chamada>()
    let respostaPedidoEntradaSaida = PublishSubject<Chamada>()
    
    // Rotinas de Tratamento
    init() {
        iniciarSimulacao.subscribe { sucesso in
            if sucesso.element ?? false {
                sistemaOperacional.cpu.iniciar()
            }
        }.disposed(by: disposeBag)
        
        finalizarSimulacao.subscribe { sucesso in
            if sucesso.element ?? false {
                sistemaOperacional.cpu.parar()
                sistemaOperacional.imprimirRelatorioDaSimulacao()
            }
        }.disposed(by: disposeBag)

        adicionarJob.subscribe { job in
            TrafficController.adicionarJob(job: job.element!)
        }.disposed(by: disposeBag)
        
        pedirParaExecutarJob.subscribe { job in
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
        jobFinalizouExecucao.subscribe { job in
            TrafficController.marcarJobComoFinalizado(job: job.element!)
            sistemaOperacional.cpu.proximoProcesso()
            Dispatcher.pedirParaAlocarProcessoNoProcessador()
        }.disposed(by: disposeBag)
        
        atualizouTempoDoTimeslice.subscribe { tempo in
            if tempo.element ?? 0 == tempoMaximoDeTimeslice {
                sistemaOperacional.cpu.proximoProcesso()
                sistemaOperacional.reiniciarTimeslice()
            }
        }.disposed(by: disposeBag)
        
        fazerPedidoEntradaSaida.subscribe { chamada in
            sistemaOperacional.gerenciadorES.criarRequisicao(chamada: chamada.element!)
            TrafficController.passarJobParaFilaDeEntradaSaida(chamada: chamada.element!)
        }.disposed(by: disposeBag)
        
        respostaPedidoEntradaSaida.subscribe { chamada in
            let job = chamada.element!.jobOrigem!
            job.estado = .pronto
            sistemaOperacional.cpu.alocarProcessoEmEsperaES(job: job)
        }.disposed(by: disposeBag)
        
        inscreverJobs()
    }
    
    // Explorador de Arquivos
    let explorador = ExploradorDeArquivos()
    var arquivoAberto: String?
    
    // Linguagem de Script
    let JOB = PublishSubject<String>()
    let DISK = PublishSubject<String>()
    let DIRECTORY = PublishSubject<String>()
    let CREATE_FOLDER = PublishSubject<String>()
    let DELETE_FOLDER = PublishSubject<String>()
    let CREATE = PublishSubject<String>()
    let DELETE = PublishSubject<String>()
    let LIST = PublishSubject<String>()
    let INFILE = PublishSubject<String>()
    let OUTFILE = PublishSubject<String>()
    let DISKFILE = PublishSubject<String>()
    let RUN = PublishSubject<String>()
    let ENDJOB = PublishSubject<String>()
    let OPEN = PublishSubject<String>()
    let CLOSE = PublishSubject<String>()
    let READ = PublishSubject<String>()
    let WRITE = PublishSubject<String>()
    let LOGIN = PublishSubject<String>()
    let LOGOUT = PublishSubject<String>()
    let IN = PublishSubject<String>()
    let OUT = PublishSubject<String>()

    func inscreverJobs() {
        JOB.subscribe { nome in
            print("Job: \(nome.element!)")
        }.disposed(by: disposeBag)
        
        DISK.subscribe { nome in // Vai para pasta dentro do diretório atual
            self.explorador.irParaDiretorio(nome: nome.element!)
        }.disposed(by: disposeBag)
        
        DIRECTORY.subscribe { nome in // Lista o conteúdo da pasta atual
            self.explorador.diretorioAtual.listar()
        }.disposed(by: disposeBag)
        
        CREATE.subscribe { nome in // Cria novo arquivo
            self.explorador.diretorioAtual.novoArquivo(nome: nome.element!)
        }.disposed(by: disposeBag)
        
        DELETE.subscribe { nome in // Deleta arquivo
            self.explorador.diretorioAtual.excluirArquivo(nome: nome.element!)
        }.disposed(by: disposeBag)
        
        CREATE_FOLDER.subscribe { nome in // Cria nova pasta
            self.explorador.diretorioAtual.novaPasta(nome: nome.element!)
        }.disposed(by: disposeBag)
        
        DELETE_FOLDER.subscribe { nome in // Deleta pasta
            self.explorador.diretorioAtual.excluirPasta(nome: nome.element!)
        }.disposed(by: disposeBag)
        
        LIST.subscribe { nome in // Lista o conteúdo de um arquivo
            self.explorador.diretorioAtual.arquivo(nome: nome.element!)?.listar()
        }.disposed(by: disposeBag)
        
        INFILE.subscribe { nome in
            #warning("TODO - INFILE!")
            print("Função indisponível: INFILE")
        }.disposed(by: disposeBag)
        
        OUTFILE.subscribe { nome in
            #warning("TODO - OUTFILE!")
            print("Função indisponível: OUTFILE")
        }.disposed(by: disposeBag)
        
        DISKFILE.subscribe { nome in
            #warning("TODO - DISKFILE!")
            print("Função indisponível: DISKFILE")
        }.disposed(by: disposeBag)
        
        RUN.subscribe { nome in
            #warning("TODO - RUN!")
            print("Função indisponível: RUN")
        }.disposed(by: disposeBag)
        
        ENDJOB.subscribe { nome in
            #warning("TODO - ENDJOB!")
            print("Função indisponível: ENDJOB")
        }.disposed(by: disposeBag)
        
        OPEN.subscribe { nome in // Abrir um arquivo para edição
            self.arquivoAberto = nome.element!
        }.disposed(by: disposeBag)
        
        CLOSE.subscribe { nome in // Fechar um arquivo
            self.arquivoAberto = nil
        }.disposed(by: disposeBag)
        
        READ.subscribe { _ in // Lista o conteúdo do arquivo que está sendo editado
            guard let arquivoAberto = self.arquivoAberto else  {
                print("Erro! Não há arquivos abertos para serem escritos")
                return
            }
            self.explorador.diretorioAtual.arquivo(nome: arquivoAberto)?.listar()
        }.disposed(by: disposeBag)
        
        WRITE.subscribe { conteudo in // Escreve no arquivo aberto
            guard let arquivoAberto = self.arquivoAberto else  {
                print("Erro! Não há arquivos abertos para serem escritos")
                return
            }
            self.explorador.diretorioAtual.arquivo(nome: arquivoAberto)?.escrever(conteudo: conteudo.element!)
        }.disposed(by: disposeBag)
        
        LOGIN.subscribe { argumento in // Faz login no sistema
            let argumentos = argumento.element!.components(separatedBy: "/")
            if argumentos.count != 2 {
                print("Número inválido de argumentos para fazer login!")
                return
            }
            self.explorador.fazerLogin(usuario: argumentos[0], senha: argumentos[1])
        }.disposed(by: disposeBag)
        
        LOGOUT.subscribe { argumento in // Faz logout do sistema
            self.explorador.usuarioLogado = nil
        }.disposed(by: disposeBag)
        
        IN.subscribe { argumento in
            #warning("TODO - IN!")
            print("Função indisponível: IN")
        }.disposed(by: disposeBag)
        
        OUT.subscribe { argumento in
            #warning("TODO - OUT!")
            print("Função indisponível: OUT")
        }.disposed(by: disposeBag)
        
    }
    
    func decodificarComando(comando: String) {
        if !comando.starts(with: "$LOGIN ") && explorador.usuarioLogado == nil {
            print("Faça login para executar os comandos do shell")
            return
        }
        
        if comando.first != "$" { print("Erro! Comandos devem iniciar com o sinal '$'"); return }
        
        let comandoProcessado = String(comando.dropFirst()).components(separatedBy: " ")
        if comandoProcessado.count < 2 { print("Erro! Comando curto demais"); return }
        
        let code = comandoProcessado[0]
        let argumento = comandoProcessado[1]

        print("\n=> Executando comando: \(comando)\n")
        
        switch code {
        case "JOB":
            JOB.onNext(argumento)
            break
        case "DISK":
            DISK.onNext(argumento)
            break
        case "DIRECTORY":
            DIRECTORY.onNext(argumento)
            break
        case "CREATE":
            CREATE.onNext(argumento)
            break
        case "DELETE":
            DELETE.onNext(argumento)
            break
        case "CREATE_FOLDER":
            CREATE_FOLDER.onNext(argumento)
            break
        case "DELETE_FOLDER":
            DELETE_FOLDER.onNext(argumento)
            break
        case "LIST":
            LIST.onNext(argumento)
            break
        case "INFILE":
            INFILE.onNext(argumento)
            break
        case "OUTFILE":
            OUTFILE.onNext(argumento)
            break
        case "DISKFILE":
            DISKFILE.onNext(argumento)
            break
        case "RUN":
            RUN.onNext(argumento)
            break
        case "ENDJOB":
            ENDJOB.onNext(argumento)
            break
        case "OPEN":
            OPEN.onNext(argumento)
            break
        case "CLOSE":
            CLOSE.onNext(argumento)
            break
        case "WRITE":
            WRITE.onNext(argumento)
            break
        case "READ":
            READ.onNext(argumento)
            break
        case "LOGIN":
            LOGIN.onNext(argumento)
        case "LOGOUT":
            LOGOUT.onNext(argumento)
        case "IN":
            IN.onNext(argumento)
        case "OUT":
            OUT.onNext(argumento)
        default:
            print("Erro! Comando não encontrado!")
        }
    }
    
}
