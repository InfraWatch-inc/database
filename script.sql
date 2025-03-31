DROP DATABASE IF EXISTS infrawatch;

CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;


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
    complemento VARCHAR(200) NOT NULL
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

CREATE TABLE IF NOT EXISTS ConfiguracaoMonitoramento ( 
    idConfiguracaoMonitoramento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    unidadeMedida VARCHAR(45) NOT NULL,
    descricao TEXT,
    fkComponente INT NOT NULL,
    limiteAtencao FLOAT NOT NULL,
    limiteCritico FLOAT NOT NULL,
    funcaoPython VARCHAR(70) NOT NULL,
	FOREIGN KEY (fkComponente) REFERENCES Componente(idComponente)
    
);

#---------------MONITORAMENTO---------------------
CREATE TABLE IF NOT EXISTS Captura(
    idCaptura INT PRIMARY KEY AUTO_INCREMENT,
    dadoCaptura FLOAT NOT NULL,
    dataHora DATETIME NOT NULL DEFAULT now(),
    fkConfiguracaoMonitoramento INT NOT NULL,
    FOREIGN KEY (fkConfiguracaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idConfiguracaoMonitoramento)
);

CREATE TABLE IF NOT EXISTS Alerta(
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    nivel TINYINT NOT NULL, -- 1: Atenção, 2: Crítico
    fkCaptura INT NOT NULL,
    FOREIGN KEY (fkCaptura) REFERENCES Captura(idCaptura),
    CONSTRAINT chkNivelAlerta CHECK (nivel IN (1, 2))
);

#----------------AMBIENTE CAPTURAS-----------------

CREATE TABLE IF NOT EXISTS captura_servidor_1 (
	cpu1_frequencia FLOAT,
	cpu1_uso_porcentagem FLOAT,
    ram1_uso_byte FLOAT,
	ram1_uso_porcentagem FLOAT,
	hd1_uso_porcentagem FLOAT,
	gpu1_uso_porcentagem FLOAT,
	gpu1_temperatura FLOAT,
	disco2_uso_porcentagem FLOAT,
	disco2_uso_byte FLOAT,
    isAlerta TINYINT, -- 0 = false, 1 = true
    CONSTRAINT temAlerta CHECK (nivel IN (0, 1)),
    dtHora DATETIME
);

CREATE TABLE IF NOT EXISTS captura_servidor_2 (
	cpu1_frequencia FLOAT,
	cpu1_uso_porcentagem FLOAT,
    ram1_uso_byte FLOAT,
	ram1_uso_porcentagem FLOAT,
	hd1_uso_porcentagem FLOAT,
	gpu1_uso_porcentagem FLOAT,
	gpu1_temperatura FLOAT,
	disco2_uso_porcentagem FLOAT,
	disco2_uso_byte FLOAT,
    isAlerta TINYINT, -- 0 = false, 1 = true
    CONSTRAINT temAlerta CHECK (nivel IN (0, 1)),
    dtHora DATETIME
);

INSERT INTO Endereco (cep, logradouro, numero, bairro, cidade, estado, complemento) VALUES 
('01001-000', 'Av. Paulista', 1000, 'Bela Vista', 'São Paulo', 'SP', 'Conjunto 101'),
('20040-001', 'Rua da Assembleia', 200, 'Centro', 'Rio de Janeiro', 'RJ', 'Conjunto 5'),
('30130-010', 'Av. Afonso Pena', 1500, 'Centro', 'Belo Horizonte', 'MG', 'Próximo à Praça Sete');

INSERT INTO Empresa (razaoSocial, numeroTin, status, telefone, site, pais, fkEndereco) VALUES
('Tech Solutions LTDA', '123456789012', 'ativo', '(11) 98765-4321', 'https://techsolutions.com', 'BR', 1),
('Inova Indústria S.A.', '987654321098', 'ativo', '(21) 99999-8888', NULL, 'BR', 2),
('Comércio Global', '564738291012', 'inativo', NULL, 'https://comercioglobal.com', 'US', 3);

INSERT INTO Servidor (tagName, tipo, uuidPlacaMae, idInstancia, SO, fkEmpresa, fkEndereco) VALUES
('SRV-001', 'fisico', '1234-5678-9101', 'inst-001', 'Linux', 1, 1),
('SRV-002', 'nuvem', 'NBQ5911005111817C8MX00', 'inst-002', 'Windows', 2, 2);

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
(1, 'CPU', 'Intel', 1, 'i7-9700K'),
(1, 'RAM', 'Corsair', 1, 'Vengeance 16GB'),
(1, 'HD', 'Seagate', 1, '1TB'),
(1, 'GPU', 'NVIDIA', 1, 'RTX 3080'),
(1, 'Disco', 'Samsung', 2, 'SSD 1TB'),
(2, 'CPU', 'Intel', 1, 'i5-9700K'),
(2, 'RAM', 'Husky', 1, 'DDR4 16GB'),
(2, 'HD', 'Seagate', 1, '1TB'),
(2, 'GPU', 'NVIDIA', 1, 'GTX 1050'),
(2, 'Disco', 'Adata', 2, 'SSD 500GB');

INSERT INTO ConfiguracaoMonitoramento (nome, unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
('CPU', '%', 'Uso', 1, 80.0, 95.0, 'psutil.cpu_percent()'),
('CPU', 'MHz', 'Frequência', 1, 2000.0, 4000.0, 'psutil.cpu_freq().current'),
('RAM', '%', 'Uso', 2, 75.0, 90.0, 'psutil.virtual_memory().percent'),
('RAM', 'Byte', 'Uso Byte', 2, 8000000000, 16000000000, 'psutil.virtual_memory().used'),
('HD', '%', 'Uso Porcentagem', 3, 85.0, 95.0, 'psutil.disk_usage("/").percent'),
('GPU', '%', 'Uso Porcentagem', 4, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'),
('GPU', 'ºC', 'Temperatura', 4, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'),
('Disco', '%', 'Uso Porcentagem', 5, 80.0, 95.0, 'psutil.disk_usage("/").percent'),
('Disco', 'Byte', 'Uso Byte', 5, 500000000000, 1000000000000, 'psutil.disk_usage("/").used'),
('CPU', '%', 'Uso Porcentagem', 6, 80.0, 95.0, 'psutil.cpu_percent()'),
('CPU', 'MHz', 'Frequência', 6, 2000.0, 4000.0, 'psutil.cpu_freq().current'),
('RAM', '%', 'Uso Porcentagem', 7, 75.0, 90.0, 'psutil.virtual_memory().percent'),
('RAM', 'Byte', 'Uso Byte', 7, 8000000000, 16000000000, 'psutil.virtual_memory().used'),
('HD', '%', 'Uso Porcentagem', 8, 85.0, 95.0, 'psutil.disk_usage("/").percent'),
('GPU', '%', 'Uso Porcentagem', 9, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'),
('GPU', 'ºC', 'Temperatura', 9, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'),
('Disco', '%', 'Uso Porcentagem', 10, 80.0, 95.0, 'psutil.disk_usage("/").percent'),
('Disco', 'Byte', 'Uso Byte', 10, 500000000000, 1000000000000, 'psutil.disk_usage("/").used');