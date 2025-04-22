DROP DATABASE IF EXISTS infrawatch;

CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;

#--------EMPRESA E COLABORADORES---------

CREATE TABLE IF NOT EXISTS Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(60) NOT NULL,
    numeroTin VARCHAR(12) NOT NULL,
    status VARCHAR(45) NOT NULL DEFAULT 'ativo', -- fala se a empresa ta ativa ou não
    telefone VARCHAR(15) NOT NULL,
    site VARCHAR(200) NOT NULL,
    CONSTRAINT chkStatus CHECK (status IN ('ativo','ativo'))
);

CREATE TABLE IF NOT EXISTS Endereco (
    idEndereco INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(12) NOT NULL,
    logradouro VARCHAR(60) NOT NULL,
    numero INT NOT NULL,
    bairro VARCHAR(45) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    estado CHAR(3) NOT NULL,
    complemento VARCHAR(200) NOT NULL,
	pais CHAR(2) NOT NULL
);

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
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa),
	CONSTRAINT chknivel CHECK (nivel IN (1, 2, 3))
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
    SO VARCHAR(45) NOT NULL,
    fkEmpresa INT NOT NULL,
    fkEndereco INT, 
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa),
    FOREIGN KEY (fkEndereco) REFERENCES Endereco(idEndereco)
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

CREATE TABLE IF NOT EXISTS ConfiguracaoMonitoramento ( 
    idConfiguracaoMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    unidadeMedida VARCHAR(45) NOT NULL,
    descricao TEXT,
    fkComponente INT NOT NULL,
    limiteAtencao FLOAT NOT NULL,
    limiteCritico FLOAT NOT NULL,
    funcaoPython VARCHAR(70) NOT NULL,
	FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente)
);