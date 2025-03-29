DROP DATABASE IF EXISTS infrawatch;

CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;

-- VITÓRIA EU JA VOU ADIANTAR PARTE DA MODELAGEM AQ EM RELACAO ÁS TABELAS E ATRIBUTOS
-- VOCE VAI TER QUE LIGAR AS FK's, ADD OS CHECKS E GERAR ALGUNS INSERTS 
-- PODE SER QUE EU JÁ TENHA MUDADO ISSO EM ALGUMAS PARTES
-- FIII VE SE TA CERTO ANTES DE FAZER QUALQUER COISA 

#--------EMPRESA E COLABORADORES---------

CREATE TABLE IF NOT EXISTS Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(60) NOT NULL,
    numeroTin VARCHAR(12),
    status ENUM('ativo', 'inativo'), -- fala se a empresa ta ativa ou não
    telefone VARCHAR(15),
    site VARCHAR(200),
    pais CHAR(2)
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

-- FIZ ESSE ALTER TABLE PQ NAO TEM COMO CRIAR UMA TABELA COM UMA FK DE UMA TABELA QUE AINDA NÃO FOI CRIADA
ALTER TABLE Empresa ADD COLUMN fkEndereco INT NOT NULL,
ADD CONSTRAINT fkEndereco
FOREIGN KEY (fkEndereco) REFERENCES Endereco(idEndereco);

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

#-----------SERVIDORES------------

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
    idComponente INT PRIMARY KEY AUTO_INCREMENT,
    fkServidor INT NOT NULL,
    componente VARCHAR(45) NOT NULL,
    marca VaRCHAR(45) NOT NULL,
    numeracao TINYINT NOT NULL,
    modelo VARCHAR(45) NOT NULL,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS ConfiguracaoMonitoramento ( -- FAZ ESSA TABELA PRA MIM HEHE -- EU FIZ HEHE
    idOpcaoMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    unidadeMedida VARCHAR(45) NOT NULL,
    descricao TEXT,
    fkComponente INT NOT NULL,
    limiteAtencao FLOAT NOT NULL,
    limiteCritico FLOAT NOT NULL,
    funcaoPython VARCHAR(70) NOT NULL,
	FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente)
    
);

#----------------AMBIENTE CAPTURAS-----------------
CREATE TABLE IF NOT EXISTS captura_servidor_1 ( -- FAZ A TABELA DE CAPTURA E APERTA TBM PFVR TMJ
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    uso INT NOT NULL,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS captura_servidor_2 ( -- NÃO SEI SE TA CERTA PQ EU NAO ENTENDIIIIIII
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    cpu2_freq_uso FLOAT,
	cpu2_percent_uso FLOAT,
	ram2_percent_uso FLOAT,
	hd2_uso FLOAT,
	gpu2_uso FLOAT,
	gpu2_temperatura FLOAT,
	disco3_percent_uso FLOAT,
	disco3_uso_byte FLOAT,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS captura_servidor_3 ( -- CONTINUO NÃO ENTENDENDOOOOOOOO
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    cpu3_freq_uso FLOAT,
	cpu3_percent_uso FLOAT,
	ram3_percent_uso FLOAT,
	hd3_uso FLOAT,
	gpu3_uso FLOAT,
	gpu3_temperatura FLOAT,
	disco4_percent_uso FLOAT,
	disco4_uso_byte FLOAT,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS captura_servidor_4 ( -- SE TIVER TOTSLMENTE ERRADO IGNORAAA
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    cpu4_freq_uso FLOAT,
	cpu4_percent_uso FLOAT,
	ram4_percent_uso FLOAT,
	hd4_uso FLOAT,
	gpu4_uso FLOAT,
	gpu4_temperatura FLOAT,
	disco5_percent_uso FLOAT,
	disco5_uso_byte FLOAT,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS captura_servidor_5 ( -- CONTINUO NÃO ENTENDENDOOOOOOOO
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    cpu5_freq_uso FLOAT,
	cpu5_percent_uso FLOAT,
	ram5_percent_uso FLOAT,
	hd5_uso FLOAT,
	gpu5_uso FLOAT,
	gpu5_temperatura FLOAT,
	disco6_percent_uso FLOAT,
	disco6_uso_byte FLOAT,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS captura_servidor_6 ( -- EU JURO QUE TENTEI ENTENDER :(
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    cpu6_freq_uso FLOAT,
	cpu6_percent_uso FLOAT,
	ram6_percent_uso FLOAT,
	hd6_uso FLOAT,
	gpu6_uso FLOAT,
	gpu6_temperatura FLOAT,
	disco7_percent_uso FLOAT,
	disco7_uso_byte FLOAT,
    dtHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);


# FI NÃO ENTENDI ESSA ÚLTIMA AÍ PQ TA DIFERENTE DA MODELAGEM ENTÃO EU VOU FAZER A QUE TA NA MODELAGEM AQUI EMBAIXO - SORRY POR NÃO ENTENDER - UM BEIJO DA DIVA ;)
CREATE TABLE IF NOT EXISTS captura_servidor_n (
idCaptura INT PRIMARY KEY AUTO_INCREMENT,
cpu1_freq_uso FLOAT,
cpu1_percent_uso FLOAT,
ram1_percent_uso FLOAT,
hd1_uso FLOAT,
gpu1_uso FLOAT,
gpu1_temperatura FLOAT,
disco2_percent_uso FLOAT,
disco2_uso_byte FLOAT,
dataHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Empresa (razaoSocial, numeroTin, status, telefone, site, pais) VALUES ('Empresa 1', '123456789', 'ativo', '123456789', 'www.empresa1.com', 'BR');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('CPU', 'Porcentagem', 'Uso da CPU');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('RAM', 'Porcentagem', 'Uso da Memória RAM');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('GPU', 'Porcentagem', 'Uso da GPU');
INSERT INTO OpcaoMonitoramento (nome, unidadeMedida, descricao) VALUES ('GPU', 'Porcentagem', 'Uso da VRAM');DROP DATABASE IF EXISTS infrawatch;

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