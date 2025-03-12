DROP DATABASE IF EXISTS infrawatch;

CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;

--------GESTÃO DE EMPRESA E COLABORADORES---------

CREATE TABLE IF NOT EXISTS Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(60) NOT NULL,
    numeroTin VARCHAR(12),
    status ENUM('ativo', 'inativo'),
    telefone VARCHAR(15),
    site VARCHAR(200),
    pais CHAR(2)
);


CREATE TABLE IF NOT EXISTS Endereco (
    idEndereco INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(12),
    logradouro VARCHAR(60) NOT NULL,
    numero INT,
    bairro VARCHAR(45) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    estado CHAR(3) NOT NULL,
    idEmpresa INT NOT NULL UNIQUE,
    FOREIGN KEY (idEmpresa) REFERENCES Empresa(idEmpresa)
);


CREATE TABLE IF NOT EXISTS Cargo (
    idCargo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    descricao TEXT
)

CREATE TABLE IF NOT EXISTS Colaborador (
    idColaborador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    documento VARCHAR(15) NOT NULL UNIQUE,
    tipoDocumento VARCHAR(15) NOT NULL,
    senha TEXT NOT NULL,
    dtCadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fkResponsavel INT,
    fkCargo INT,
    fkEmpresa INT,
    FOREIGN KEY (fkResponsavel) REFERENCES Colaborador(idColaborador),
    FOREIGN KEY (fkCargo) REFERENCES Cargo(idCargo),
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);



--------GESTÃO DE SERVIDORES E ALERTAS---------



CREATE TABLE IF NOT EXISTS Servidor (
    idServidor INT PRIMARY KEY AUTO_INCREMENT,
    tagName VARCHAR(45) NOT NULL,
    tipo ENUM('nuvem', 'fisico'),
    uuidPlacaMae VARCHAR(45) NOT NULL UNIQUE,
    idInstancia VARCHAR(45) UNIQUE,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo',
    dtCadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SO VARCHAR(45) NOT NULL,
    fkEmpresa INT,
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);


CREATE TABLE IF NOT EXISTS Componente (
    idComponente INT AUTO_INCREMENT,
    fkServidor INT NOT NULL,
    nome VARCHAR(45) NOT NULL,
    descricao TEXT,
    tipoComponente VARCHAR(45) NOT NULL,
    CONSTRAINT pkComponente PRIMARY KEY (idComponente, fkServidor),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE IF NOT EXISTS opcaoMonitoramento (
    idOpcaoMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    unidadeMedida VARCHAR(45) NOT NULL,
    descricao TEXT
);


CREATE TABLE IF NOT EXISTS Config (
    fkComponente INT NOT NULL,
    fkOpcaoMonitoramento INT NOT NULL,
    fkServidor INT NOT NULL,
    limite INT NOT NULL,
    CONSTRAINT pkConfig PRIMARY KEY (fkComponente, fkOpcaoMonitoramento, fkServidor),
    FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente),
    FOREIGN KEY (fkOpcaoMonitoramento) REFERENCES opcaoMonitoramento(idOpcaoMonitoramento),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);


CREATE TABLE IF NOT EXISTS Alerta (
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