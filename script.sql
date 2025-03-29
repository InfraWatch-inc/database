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

CREATE TABLE IF NOT EXISTS captura_servidor_1 (
	cpu1_freq_uso FLOAT,
	cpu1_percent_uso FLOAT,
    ram1_uso FLOAT,
	ram1_percent_uso FLOAT,
	hd_uso FLOAT,
	gpu1_uso FLOAT,
	gpu1_temperatura FLOAT,
	disco2_percent_uso FLOAT,
	disco2_uso_byte FLOAT,
    dtHora DATETIME
);

CREATE TABLE IF NOT EXISTS captura_servidor_2 (
	cpu1_freq_uso FLOAT,
	cpu1_percent_uso FLOAT,
	gpu1_uso FLOAT,
	gpu1_temperatura FLOAT,
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
('SRV-002', 'nuvem', '5678-9101-1234', 'inst-002', 'Windows', 2, 2);

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
(1, 'CPU', 'Intel', 1, 'i7-9700K'),
(1, 'RAM', 'Corsair', 2, 'Vengeance 16GB'),
(1, 'HD', 'Seagate', 1, '1TB'),
(2, 'GPU', 'NVIDIA', 1, 'RTX 3080'),
(2, 'Disco', 'Samsung', 1, 'SSD 1TB');

#GPUtil.getGPUs() ele pega tudo da gpu e depois você escolhe oq vc quer pegar fi
INSERT INTO ConfiguracaoMonitoramento (nome, unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
('CPU', 'Porcentagem', 'Uso da CPU', 1, 80.0, 95.0, 'psutil.cpu_percent()'),
('CPU', 'MHz', 'Frequência da CPU', 1, 2000.0, 4000.0, 'psutil.cpu_freq().current'),
('RAM', 'Porcentagem', 'Uso da Memória RAM', 2, 75.0, 90.0, 'psutil.virtual_memory().percent'),
('RAM', 'Byte', 'Uso da Memória RAM', 2, 8000000000, 16000000000, 'psutil.virtual_memory().used'),
('HD', 'Porcentagem', 'Uso do HD', 3, 85.0, 95.0, 'psutil.disk_usage("/").percent'),
('GPU', 'Porcentagem', 'Uso da GPU', 4, 70.0, 90.0, 'GPUtil.getGPUs()'),
('GPU', 'Celsius', 'Temperatura da GPU', 4, 60.0, 90.0, 'GPUtil.getGPUs()'), # talvez seja gpu.temperature mas não sei se ta correto
('Disco', 'Porcentagem', 'Uso do Disco', 5, 80.0, 95.0, 'psutil.disk_usage("/").percent'),
('Disco', 'Byte', 'Uso do Disco', 5, 500000000000, 1000000000000, 'psutil.disk_usage("/").used');
#GPUtil.getGPUs() ele pega tudo da gpu e depois você escolhe oq vc quer pegar fi
DROP DATABASE IF EXISTS infrawatch;

