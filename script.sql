DROP DATABASE IF EXISTS infrawatch;

CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;

-- VITÓRIA EU JA VOU ADIANTAR PARTE DA MODELAGEM AQ EM RELACAO ÁS TABELAS E ATRIBUTOS
-- VOCE VAI TER QUE LIGAR AS FK's, ADD OS CHECKS E GERAR ALGUNS INSERTS 
-- PODE SER QUE EU JÁ TENHA MUDADO ISSO EM ALGUMAS PARTES

--------EMPRESA E COLABORADORES---------

CREATE TABLE IF NOT EXISTS Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(60) NOT NULL,
    numeroTin VARCHAR(12),
    status ENUM('ativo', 'inativo'), -- fala se a empresa ta ativa ou não
    telefone VARCHAR(15),
    site VARCHAR(200),
    pais CHAR(2),
    fkEndereco NOT NULL
);


CREATE TABLE IF NOT EXISTS Endereco (
    idEndereco INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(12),
    logradouro VARCHAR(60) NOT NULL,
    numero INT NOT NULL,
    bairro VARCHAR(45) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    estado CHAR(3) NOT NULL,
    fkEmpresa INT NOT NULL UNIQUE,
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);

CREATE TABLE IF NOT EXISTS Colaborador (
    idColaborador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    documento VARCHAR(15) NOT NULL UNIQUE,
    tipoDocumento VARCHAR(15) NOT NULL,
    senha TEXT NOT NULL,
    dtCadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fkResponsavel INT,
    fkEmpresa INT NOT NULL,
    cargo VARCHAR(45) NOT NULL,
    nivel TINYINT NOT NULL,
    FOREIGN KEY (fkResponsavel) REFERENCES Colaborador(idColaborador),
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);

-----------SERVIDORES------------

CREATE TABLE IF NOT EXISTS Servidor (
    idServidor INT PRIMARY KEY AUTO_INCREMENT,
    tagName VARCHAR(45) NOT NULL,
    tipo ENUM('nuvem', 'fisico') NOT NULL,
    uuidPlacaMae VARCHAR(45) NOT NULL UNIQUE,
    idInstancia VARCHAR(45) UNIQUE,
    status ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
    dtCadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sistemaOperacional VARCHAR(45) NOT NULL,
    fkEmpresa INT NOT NULL,
    fkEndereco INT, -- nn add a referencia 
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);


CREATE TABLE IF NOT EXISTS Componente (
    idComponente INT AUTO_INCREMENT,
    fkServidor INT NOT NULL,
    componente VARCHAR(45) NOT NULL,
    marca VaRCHAR(45) NOT NULL,
    numeracao TINYINT NOT NULL,
    modelo VARCHAR(45) NOT NULL,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS ConfiguracaoMonitoramento ( -- FAZ ESSA TABELA PRA MIM HEHE
    idOpcaoMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    unidadeMedida VARCHAR(45) NOT NULL,
    descricao TEXT
);

----------------AMBIENTE CAPTURAS-----------------
CREATE TABLE IF NOT EXISTS captura_serrvidor_1 ( -- FAZ A TABELA DE CAPTURA E APERTA TBM PFVR TMJ
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    uso INT NOT NULL,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES opcaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);


INSERT INTO Empresa (razaoSocial, numeroTin, status, telefone, site, pais) VALUES ('Empresa 1', '123456789', 'ativo', '123456789', 'www.empresa1.com', 'BR');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('CPU', 'Porcentagem', 'Uso da CPU');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('RAM', 'Porcentagem', 'Uso da Memória RAM');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('GPU', 'Porcentagem', 'Uso da GPU');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('GPU', 'Porcentagem', 'Uso da VRAM');