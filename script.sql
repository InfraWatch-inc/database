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
    pais CHAR(2) NOT NULL,
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

CREATE TABLE IF NOT EXISTS Processo(
	idProcesso INT PRIMARY KEY AUTO_INCREMENT,
    pid INT NOT NULL,
    nomeProcesso VARCHAR(45) NOT NULL,
    usoCpu FLOAT NOT NULL,
    usoGpu FLOAT NOT NULL,
    usoRam FLOAT NOT NULL,
    fkServidor INT NOT NULL,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

#---------------INSERTS---------------------

INSERT INTO Endereco (cep, logradouro, numero, bairro, cidade, estado, complemento) VALUES 
('70000-000', 'Nguyen Van Linh', 45, 'Hai Chau', 'Da Nang', 'VN', 'Próximo ao Dragon Bridge'),
('50670', 'Linder Höhe', 125, 'Porz', 'Colônia', 'DE', 'Próximo ao Aeroporto de Colônia-Bonn'),
('WC2H 9JQ', 'Shaftesbury Ave', 89, 'Soho', 'Londres', 'UK', 'Próximo ao Palace Theatre');

INSERT INTO Empresa (razaoSocial, numeroTin, telefone, site, pais, fkEndereco) VALUES
('iRender', '112233445566', '(11) 91234-5678', 'https://www.irender.net', 'VN', 1),
('RebusFarm', '223344556677','(49) 98765-4321', 'https://www.rebusfarm.net', 'DE', 2),
('GarageFarm.NET', '334455667788','(44) 99999-8888', 'https://garagefarm.net', 'UK', 3);

INSERT INTO Colaborador (nome, email, documento, tipoDocumento, senha, fkEmpresa, cargo, nivel) 
VALUES 
('João Neto', 'joao.neto@email.com', '12345678901', 'CPF', 'senha123', 1, 'Técnico de Manutenção', 1),
('Carlos Eduardo', 'carlos.eduardo@email.com', '23456789012', 'CPF', 'senha456', 1, 'Analista de Dados', 2),
('Beatriz Moreira', 'beatriz.moreira@email.com', '34567890123', 'CPF', 'senha789', 1, 'COO', 3);

INSERT INTO Servidor (tagName, tipo, uuidPlacaMae, idInstancia, SO, fkEmpresa, fkEndereco) VALUES
('SRV-001', 'fisico', '1234-5678-9101', 'inst-001', 'Linux', 1, 1),
('SRV-002', 'nuvem', 'NBQ5911005111817C8MX00', 'inst-002', 'Windows', 1, 2);

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
('Disco', 'Byte', 'Uso Byte', 10, 500000000000, 1000000000000, 'psutil.disk_usage("/").used'),
('CPU', 'Porcentagem', 'Uso da CPU', 1, 80.0, 95.0, 'psutil.cpu_percent()'),
('CPU', 'MHz', 'Frequência da CPU', 1, 2000.0, 4000.0, 'psutil.cpu_freq().current'),
('RAM', 'Porcentagem', 'Uso da Memória RAM', 2, 75.0, 90.0, 'psutil.virtual_memory().percent'),
('RAM', 'Byte', 'Uso da Memória RAM', 2, 8000000000, 16000000000, 'psutil.virtual_memory().used'),
('HD', 'Porcentagem', 'Uso do HD', 3, 85.0, 95.0, 'psutil.disk_usage("/").percent'),
('GPU', 'Porcentagem', 'Uso da GPU', 4, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'),
('GPU', 'Celsius', 'Temperatura da GPU', 4, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'),
('Disco', 'Porcentagem', 'Uso do Disco', 5, 80.0, 95.0, 'psutil.disk_usage("/").percent'),
('Disco', 'Byte', 'Uso do Disco', 5, 500000000000, 1000000000000, 'psutil.disk_usage("/").used');

#---------------VIEWS---------------------

CREATE OR REPLACE VIEW `viewListagemColaboradores` AS
SELECT idColaborador, nome, email, cargo, documento, idEmpresa FROM Colaborador 
JOIN Empresa ON idEmpresa = fkEmpresa;

SELECT * FROM viewListagemColaboradores WHERE idEmpresa = 1;

CREATE OR REPLACE VIEW `viewListagemServidores` AS
SELECT idServidor, tagName, idInstancia, idEmpresa, 
		(SELECT COUNT(numeracao) FROM Componente as cm
        WHERE cm.componente = 'CPU' and fkServidor = idServidor) as qtdCpu, 
        
        (SELECT COUNT(numeracao) FROM Componente as cm
        WHERE cm.componente = 'GPU' and fkServidor = idServidor) as qtdGpu,
        
        (SELECT AVG(cp.dadoCaptura) FROM ConfiguracaoMonitoramento as cm
        JOIN Componente as c ON fkComponente = idComponente
        JOIN Captura as cp ON cm.idConfiguracaoMonitoramento = cp.idCaptura
        WHERE c.componente = 'GPU' and cm.descricao = 'Temperatura') as tempGpu,
        
        (SELECT AVG(cp.dadoCaptura) FROM ConfiguracaoMonitoramento as cm
        JOIN Componente as c ON fkComponente = idComponente
        JOIN Captura as cp ON cm.idConfiguracaoMonitoramento = cp.idCaptura
        WHERE c.componente = 'CPU' and cm.descricao = 'Temperatura') as tempCpu
FROM Servidor
JOIN Empresa ON idEmpresa = fkEmpresa;

SELECT * FROM viewListagemServidores WHERE idEmpresa = 1;
