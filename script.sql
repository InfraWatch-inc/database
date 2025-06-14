DROP DATABASE IF EXISTS infrawatch;
CREATE DATABASE IF NOT EXISTS infrawatch;
USE infrawatch;

#--------EMPRESA E COLABORADORES---------

CREATE TABLE IF NOT EXISTS Empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    razaoSocial VARCHAR(60) NOT NULL,
    numeroTin VARCHAR(20) NOT NULL,
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
    estado VARCHAR(45) NOT NULL,
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
	CONSTRAINT chknivel CHECK (nivel IN (1, 2, 3, 4))
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

#---------------MONITORAMENTO---------------------
CREATE TABLE IF NOT EXISTS Alerta(
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    nivel TINYINT NOT NULL, -- 1: Atenção, 2: Crítico
    dataHora DATETIME NOT NULL DEFAULT now(),
    valor FLOAT NOT NULL,
    fkConfiguracaoMonitoramento INT NOT NULL,
    FOREIGN KEY (fkConfiguracaoMonitoramento) REFERENCES ConfiguracaoMonitoramento(idConfiguracaoMonitoramento),
    CONSTRAINT chkNivelAlerta CHECK (nivel IN (1, 2))
);

CREATE TABLE IF NOT EXISTS Processo(
	idProcesso INT PRIMARY KEY AUTO_INCREMENT,
    nomeProcesso VARCHAR(45) NOT NULL,
    usoCpu FLOAT NOT NULL,
    usoGpu FLOAT NOT NULL,
    usoRam FLOAT NOT NULL,
    fkAlerta INT NULL,
    fkServidor INT NOT NULL,
    dataHora DATETIME NOT NULL,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor),
    FOREIGN KEY (fkAlerta) REFERENCES Alerta(idAlerta)
);

#---------------INSERTS---------------------

INSERT INTO Endereco (cep, logradouro, numero, bairro, cidade, estado, complemento, pais) VALUES 
('70000-000', 'Nguyen Van Linh', 45, 'Hai Chau', 'Da Nang', 'VN', 'Próximo ao Dragon Bridge', 'VN'),
('50670', 'Linder Höhe', 125, 'Porz', 'Colônia', 'DE', 'Próximo ao Aeroporto de Colônia-Bonn', 'DE'),
('WC2H 9JQ', 'Shaftesbury Ave', 89, 'Soho', 'Londres', 'UK', 'Próximo ao Palace Theatre', 'UK');

INSERT INTO Empresa (razaoSocial, numeroTin, telefone, site, fkEndereco) VALUES
('iRender', '112233445566', '(11) 91234-5678', 'https://www.irender.net',  1),
('RebusFarm', '223344556677','(49) 98765-4321', 'https://www.rebusfarm.net',  2),
('GarageFarm.NET', '334455667788','(44) 99999-8888', 'https://garagefarm.net', 3);

INSERT INTO Colaborador (nome, email, documento, tipoDocumento, senha, fkEmpresa, cargo, nivel, fkResponsavel) VALUES 
('Ana Moreira', 'ana.moreira@email.com', '34567890123', 'CPF', 'senha789', 1, 'COO', 3, null),
('Pedro Filho', 'pedro.filho@email.com', '12345678901', 'CPF', 'senha123', 1, 'Técnico de Manutenção', 1, 1),
('Andre Muller', 'andre.muller@email.com', '23456789012', 'CPF', 'senha456', 1, 'Analista de Dados', 2, 1),
('Roberto Carlos', 'roberto.carlos@email.com', '23456789033', 'CPF', 'roberto123', 1, 'DevOps', 4, NULL);

SELECT idColaborador, nome, email, nivel, fkEmpresa FROM Colaborador WHERE email = "pedro.filho@email.com" AND senha = "senha123";

INSERT INTO Servidor (tagName, tipo, uuidPlacaMae, idInstancia, SO, fkEmpresa, fkEndereco) VALUES
('Rogirg', 'fisico', '123490EN400015', NULL, 'Windows', 1, 1), -- Grigor
('Reinar', 'fisico', 'NBQ5911005111817C8MX00', NULL, 'Windows', 1, 1), -- Ranier Windows 
('Oiak', 'fisico', 'NBHMY1100D0410065B9Z00', NULL, 'Windows', 1,1), -- KAIO
('Leugim', 'fisico', 'S937NBB6000AHYMB', NULL, 'Windows', 1,1), -- Miguel
('Notlad', 'fisico', '4c4c4544-005a-5910-8042-b4c04f543434', NULL, 'Linux', 1,1), -- Ranier Linux
('Airotiv', 'fisico', '73D90500-5BDB-11E3-89FC-3C07716E634A', NULL, 'Windows', 1,1); -- Vitoria

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Grigor
(1, 'CPU', 'Intel', 1, 'i5-1235U'), -- 1
(1, 'RAM', 'Samsung', 1, 'DDR4 4GB'), -- 2
(1, 'HD', 'Samsung', 1, 'SSD 250GB'), -- 3
(1, 'GPU', 'NVIDIA', 1, 'GTX 1050'); -- 4

SELECT * FROM ConfiguracaoMonitoramento WHERE fkComponente = 4;


INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Ranier Windows
(2, 'CPU', 'Intel', 1, 'i5-9700K'), -- 5
(2, 'RAM', 'Husky', 1, 'DDR4 16GB'), -- 6
(2, 'HD', 'Adata', 1, 'SSD 500 GB'), -- 7
(2, 'GPU', 'NVIDIA', 1, 'GTX 1050'); -- 8

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Kaio
(3, 'CPU', 'Intel', 1, 'Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz'), -- 9
(3, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 10
(3, 'HD', 'Adata', 1, 'KINGSTON RBUSNS8154P3512GJ1'), -- 11
(3, 'GPU', 'NVIDIA', 1, 'GeForce MX250'); -- 12

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Miguel
(4, 'CPU', 'Intel', 1, 'i5-1235U'), -- 13
(4, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 14
(4, 'HD', 'Adata', 1, 'SSD 500 GB'); -- 15

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Ranier Linux
(5, 'CPU', 'Intel', 1, 'i5-1235U'), -- 16
(5, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 17
(5, 'HD', 'Adata', 1, 'SSD 512GB'); -- 18

INSERT INTO Componente (fkServidor, componente, marca, numeracao, modelo) VALUES
-- Vitória
(6, 'CPU', 'Intel', 1, 'i7-3537U'), -- 19
(6, 'RAM', 'Adata', 1, 'DDR3 12GB'), -- 20
(6, 'HD', 'KINGSTON', 1, 'SSD 500GB'); -- 21



INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Grigor
('%', 'Uso', 1, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('MHz', 'Frequência', 1, 2000.0, 4000.0, 'psutil.cpu_freq().current'), -- Uso MHz CPU
('%', 'Uso Porcentagem', 4, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'), -- Uso % GPU
('ºC', 'Temperatura', 4, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'), -- Temp GPU
('%', 'Uso', 2, 75.0, 90.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('Byte', 'Uso Byte', 2, 8000000000, 16000000000, 'psutil.virtual_memory().used'), -- Uso Byte RAM
('%', 'Uso Porcentagem', 3, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('Byte', 'Uso Byte', 3, 500000000000, 1000000000000, 'psutil.disk_usage("/").used'); -- Uso Byte HD

INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Ranier Windows
('%', 'Uso Porcentagem', 4, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem', 6, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('%', 'Uso Porcentagem', 7, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'), -- Uso % GPU
('ºC', 'Temperatura', 7, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'), -- Temp GPU
('%', 'Uso Porcentagem', 5, 80.0, 95.0, 'psutil.virtual_memory().percent'); -- Uso % RAM

INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Kaio
('%', 'Uso Porcentagem', 8, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU	
('%', 'Uso Porcentagem', 10, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('%', 'Uso Porcentagem', 11, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'), -- Uso % GPU
('%', 'Uso Porcentagem', 9, 80.0, 95.0, 'psutil.virtual_memory().percent'); -- Uso % RAM

INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Miguel
('%', 'Uso Porcentagem', 11, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem',12, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('%', 'Uso Porcentagem',13, 85.0, 95.0, 'psutil.disk_usage("/").percent'); -- Uso % HD

INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Ranier Linux
('%', 'Uso Porcentagem', 4, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem', 6, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('ºC', 'Temperatura', 7, 60.0, 90.0, 'psutil.sensors_temperatures().get("coretemp",[])[numeracao-1].current'), -- Temp CPU
('%', 'Uso Porcentagem', 5, 80.0, 95.0, 'psutil.virtual_memory().percent'); -- Uso % RAM

INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Vitoria
('%', 'Uso Porcentagem', 18, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem',19, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('%', 'Uso Porcentagem',20, 85.0, 95.0, 'psutil.disk_usage("/").percent'); -- Uso % HD

-- SIMULACAO DADOS DE ALERTAS 6 MESES 
-- Qtd Alertas p/ dia 2 por - total 360 alertas 

#---------------VIEWS SISTEMA---------------------
CREATE OR REPLACE VIEW `viewPrimeiroInsights` AS
SELECT  
    idEmpresa,
    Alerta.dataHora,
    
    -- Moderados (nível 1)
    SUM(CASE WHEN c.componente = 'CPU' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdCpuModerado,
    SUM(CASE WHEN c.componente = 'GPU' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdGpuModerado,
    SUM(CASE WHEN c.componente = 'RAM' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdRamModerado,
    SUM(CASE WHEN c.componente = 'HD' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdHdModerado,
    SUM(CASE WHEN c.componente = 'SSD' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdSsdModerado,

    -- Críticos (nível 2)
    SUM(CASE WHEN c.componente = 'CPU' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdCpuCritico,
    SUM(CASE WHEN c.componente = 'GPU' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdGpuCritico,
    SUM(CASE WHEN c.componente = 'RAM' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdRamCritico,
    SUM(CASE WHEN c.componente = 'HD' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdHdCritico,
    SUM(CASE WHEN c.componente = 'SSD' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdSsdCritico

FROM Alerta
JOIN ConfiguracaoMonitoramento ON fkConfiguracaoMonitoramento = idConfiguracaoMonitoramento
JOIN Componente AS c ON idComponente = fkComponente
JOIN Servidor ON fkServidor = idServidor
JOIN Empresa ON fkEmpresa = idEmpresa
GROUP BY idEmpresa, Alerta.dataHora;

-- SELECT * FROM viewPrimeiroInsights WHERE dataHora < now() and idEmpresa = 1; -- Aplicar os filtros temporais do período desejado

-- CREATE OR REPLACE VIEW viewKpiInsights AS
-- SELECT  
--     e.idEmpresa,
--     c.componente,
--     COUNT(DISTINCT cfg.idConfiguracaoMonitoramento) AS totalComponentesMonitorados,
--     COUNT(a.idAlerta) AS totalAlertasComponente

-- FROM Alerta a
-- JOIN ConfiguracaoMonitoramento cfg ON a.fkConfiguracaoMonitoramento = cfg.idConfiguracaoMonitoramento
-- JOIN Componente c ON cfg.fkComponente = c.idComponente
-- JOIN Servidor s ON c.fkServidor = s.idServidor
-- JOIN Empresa e ON s.fkEmpresa = e.idEmpresa
-- GROUP BY e.idEmpresa, c.componente;

-- SELECT * FROM viewKpiInsights WHERE idEmpresa = 1 and componente = 'CPU';

-- CREATE OR REPLACE VIEW viewInsightsProcessos AS
-- SELECT 
--     nomeProcesso,
--     ROUND(AVG(usoCpu), 2) AS mediaUsoCpu,
--     ROUND(AVG(usoRam), 2) AS mediaUsoRam,
--     ROUND(AVG(usoGpu), 2) AS mediaUsoGpu
-- FROM Processo
-- JOIN Servidor as s ON Processo.fkServidor = idServidor
-- JOIN Componente as c ON c.fkServidor = idServidor
-- JOIN Empresa as e ON e.idEMpresa = fkEmpresa
-- GROUP BY nomeProcesso
-- ORDER BY 
--     (AVG(usoCpu) + AVG(usoRam) + AVG(usoGpu)) DESC
-- LIMIT 6;

-- SELECT * FROM viewInsightsProcessos;

-- CREATE OR REPLACE VIEW viewAlertasPorContexto AS
-- SELECT 
--     CASE 
--         WHEN EXTRACT(MONTH FROM a.dataHora) BETWEEN 3 AND 5 THEN 'Primavera'
--         WHEN EXTRACT(MONTH FROM a.dataHora) BETWEEN 6 AND 8 THEN 'Verão'
--         WHEN EXTRACT(MONTH FROM a.dataHora) BETWEEN 9 AND 11 THEN 'Outono'
--         ELSE 'Inverno'
--     END AS estacaoAno,
    
-- 	EXTRACT(YEAR FROM a.dataHora) as ano, 
-- 	EXTRACT(MONTH FROM a.dataHora) AS mes,
    
--     CASE 
-- 		WHEN EXTRACT(MONTH FROM a.dataHora) <= 6 THEN '1º Semestre'
-- 		ELSE '2º Semestre'
-- 	END AS semestre,
--     en.estado,
--     en.pais,
--     c.modelo,
--     COUNT(*) AS qtdAlertas

-- FROM Alerta a
-- JOIN ConfiguracaoMonitoramento cm ON a.fkConfiguracaoMonitoramento = cm.idConfiguracaoMonitoramento
-- JOIN Componente c ON cm.fkComponente = c.idComponente
-- JOIN Servidor s ON c.fkServidor = s.idServidor
-- JOIN Endereco en ON s.fkEndereco = en.idEndereco
-- GROUP BY 
--     estacaoAno, mes, semestre, ano,
--     en.estado, en.pais,
--     c.modelo;

-- CREATE OR REPLACE VIEW `viewListagemColaboradores` AS
-- SELECT idColaborador as id, nome, email, cargo, documento, idEmpresa FROM Colaborador 
-- JOIN Empresa ON idEmpresa = fkEmpresa;

-- SELECT * FROM viewListagemColaboradores WHERE idEmpresa = 1;

-- CREATE OR REPLACE VIEW `viewGetColaborador` AS
-- SELECT idColaborador as id, nome, email, documento, tipoDocumento, cargo, nivel FROM Colaborador;

-- SELECT * FROM viewGetColaborador;

CREATE OR REPLACE VIEW `viewGetServidor` AS
SELECT Componente.componente, 
        Componente.numeracao,
        ConfiguracaoMonitoramento.unidadeMedida,
        ConfiguracaoMonitoramento.descricao,
        ConfiguracaoMonitoramento.funcaoPython, 
        ConfiguracaoMonitoramento.idConfiguracaoMonitoramento, 
        Servidor.idServidor, 
        ConfiguracaoMonitoramento.limiteAtencao, 
        ConfiguracaoMonitoramento.limiteCritico,
        Servidor.uuidPlacaMae,
        idEmpresa
FROM Servidor 
JOIN Componente 
ON Servidor.idServidor = Componente.fkServidor 
JOIN ConfiguracaoMonitoramento 
ON ConfiguracaoMonitoramento.fkComponente = Componente.idComponente
JOIN Empresa
ON idEmpresa = fkEmpresa;

-- SELECT * FROM viewGetServidor WHERE uuidPlacaMae = '123490EN400015';

CREATE OR REPLACE VIEW `viewListagemServidores` AS
 SELECT idServidor as id, tagName as nome, idInstancia, idEmpresa, 
 		(SELECT COUNT(numeracao) FROM Componente as cm
         WHERE cm.componente = 'CPU' and fkServidor = idServidor) as qtdCpu, 
        
         (SELECT COUNT(numeracao) FROM Componente as cm
         WHERE cm.componente = 'GPU' and fkServidor = idServidor) as qtdGpu
         
	FROM Servidor
	JOIN Empresa ON idEmpresa = fkEmpresa;

-- SELECT * FROM viewListagemServidores WHERE idEmpresa = 1;

-- view Kaio
CREATE OR REPLACE VIEW `viewGetInformacoesAlertas` AS
SELECT Empresa.idEmpresa AS idEmpresa,
Alerta.DataHora,
DATE_FORMAT(Alerta.DataHora, '%b') AS nomeMes,
Componente.Componente,
Alerta.nivel,
Componente.marca,
  CASE
    WHEN HOUR(Alerta.dataHora) BETWEEN 6 AND 11 THEN 'Manha'
    WHEN HOUR(Alerta.dataHora) BETWEEN 12 AND 17 THEN 'Tarde'
    ELSE 'Noite'
  END AS periodoDia 
  FROM Alerta
        JOIN ConfiguracaoMonitoramento ON fkConfiguracaoMonitoramento = idConfiguracaoMonitoramento
        JOIN Componente ON fkComponente = idComponente 
        JOIN Servidor ON fkServidor = idServidor
        JOIN Empresa ON fkEmpresa = idEmpresa 
        WHERE
        Componente.componente IN  ('CPU', 'GPU') 
        GROUP BY Empresa.idEmpresa, Alerta.dataHora, Componente.componente, Nivel, Componente.marca
        ORDER BY   Alerta.dataHora DESC
       ;


-- Dados dashboard de processos
DELIMITER $$ 
CREATE PROCEDURE prDashboardKPIs(IN dataInicio DATETIME, IN dataFim DATETIME, IN idEmpresa INT)
BEGIN
    DECLARE processoCritico VARCHAR(100) DEFAULT '';
    DECLARE processoAtencao VARCHAR(100) DEFAULT '';
    DECLARE componenteMaisUsado VARCHAR(50) DEFAULT '';
    DECLARE periodoAtivo VARCHAR(20) DEFAULT '';

    SELECT P.nomeProcesso INTO processoCritico
    FROM Processo P
    JOIN Alerta A ON P.fkAlerta = A.idAlerta
    JOIN Servidor S ON P.fkServidor = S.idServidor
    WHERE A.nivel = 2 AND A.DataHora BETWEEN dataInicio AND dataFim
      AND S.fkEmpresa = idEmpresa
    GROUP BY P.nomeProcesso
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    SELECT P.nomeProcesso INTO processoAtencao
    FROM Processo P
    JOIN Alerta A ON P.fkAlerta = A.idAlerta
    JOIN Servidor S ON P.fkServidor = S.idServidor
    WHERE A.nivel = 1 AND A.DataHora BETWEEN dataInicio AND dataFim
      AND S.fkEmpresa = idEmpresa
    GROUP BY P.nomeProcesso
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    SELECT C.componente INTO componenteMaisUsado
    FROM Alerta A
    JOIN ConfiguracaoMonitoramento CM ON A.fkConfiguracaoMonitoramento = CM.idConfiguracaoMonitoramento
    JOIN Componente C ON CM.fkComponente = C.idComponente
    JOIN Servidor S ON C.fkServidor = S.idServidor
    WHERE C.componente IN ('CPU', 'GPU', 'RAM')
      AND A.DataHora BETWEEN dataInicio AND dataFim
      AND S.fkEmpresa = idEmpresa
    GROUP BY C.componente
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    SELECT periodo INTO periodoAtivo FROM (
        SELECT
            CASE
                WHEN HOUR(A.DataHora) BETWEEN 6 AND 11 THEN 'Manha'
                WHEN HOUR(A.DataHora) BETWEEN 12 AND 17 THEN 'Tarde'
                WHEN HOUR(A.DataHora) BETWEEN 18 AND 23 THEN 'Noite'
                ELSE 'Madrugada'
            END AS periodo,
            COUNT(*) AS total
        FROM Alerta A
        JOIN ConfiguracaoMonitoramento CM ON A.fkConfiguracaoMonitoramento = CM.idConfiguracaoMonitoramento
        JOIN Componente C ON CM.fkComponente = C.idComponente
        JOIN Servidor S ON C.fkServidor = S.idServidor
        WHERE A.DataHora BETWEEN dataInicio AND dataFim
          AND S.fkEmpresa = idEmpresa
        GROUP BY periodo
        ORDER BY total DESC
        LIMIT 1
    ) AS subquery;

    SELECT 
        processoCritico AS processoMaisCritico,
        processoAtencao AS processoMaisAtencao,
        componenteMaisUsado AS componenteMaisConsumido,
        periodoAtivo AS periodoMaisAtivo;
END $$ 
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE prDashboardAlertasJSON(IN dataInicio DATETIME, IN dataFim DATETIME, IN idEmpresa INT)
BEGIN
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'nome', nome,
            'alertasCritico', IFNULL(alertasCritico, 0),
            'alertasAtencao', IFNULL(alertasAtencao, 0)
        )
    ) AS dadosProcessosAlertas
    FROM (
        SELECT P.nomeProcesso AS nome,
            SUM(CASE WHEN A.nivel = 2 THEN 1 ELSE 0 END) AS alertasCritico,
            SUM(CASE WHEN A.nivel = 1 THEN 1 ELSE 0 END) AS alertasAtencao
        FROM Processo P
        JOIN Alerta A ON P.fkAlerta = A.idAlerta
        JOIN Servidor S ON P.fkServidor = S.idServidor
        WHERE A.DataHora BETWEEN dataInicio AND dataFim
          AND S.fkEmpresa = idEmpresa
        GROUP BY P.nomeProcesso
    ) AS subAlertas;
END $$ 
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE prDashboardConsumoSimples(IN dataInicio DATETIME, IN dataFim DATETIME, IN idEmpresa INT)
BEGIN
    SELECT tipo, nome, manha, tarde, noite
    FROM (
        SELECT 'cpu' AS tipo, nomeProcesso AS nome,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoCpu ELSE NULL END), 0) AS manha,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoCpu ELSE NULL END), 0) AS tarde,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoCpu ELSE NULL END), 0) AS noite
        FROM Processo P
        JOIN Servidor S ON P.fkServidor = S.idServidor
        WHERE P.dataHora BETWEEN dataInicio AND dataFim
          AND S.fkEmpresa = idEmpresa
        GROUP BY nomeProcesso

        UNION ALL

        SELECT 'gpu', nomeProcesso,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoGpu ELSE NULL END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoGpu ELSE NULL END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoGpu ELSE NULL END), 0)
        FROM Processo P
        JOIN Servidor S ON P.fkServidor = S.idServidor
        WHERE P.dataHora BETWEEN dataInicio AND dataFim
          AND S.fkEmpresa = idEmpresa
        GROUP BY nomeProcesso

        UNION ALL

        SELECT 'ram', nomeProcesso,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoRam ELSE NULL END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoRam ELSE NULL END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoRam ELSE NULL END), 0)
        FROM Processo P
        JOIN Servidor S ON P.fkServidor = S.idServidor
        WHERE P.dataHora BETWEEN dataInicio AND dataFim
          AND S.fkEmpresa = idEmpresa
        GROUP BY nomeProcesso
    ) AS consumo
    ORDER BY tipo, nome;
END $$
DELIMITER ;

-- Miguel
create function p() returns INTEGER DETERMINISTIC NO SQL return @p;

#Alertas por mes de RAM (GRAFICO)


CREATE OR REPLACE VIEW vw_alertas_ram_periodo AS
SELECT 
    DATE_FORMAT(a.dataHora, '%b') AS mes_formatado,
    DATE_FORMAT(a.dataHora, '%Y-%m') AS mes_ordenacao,
    CASE
        WHEN HOUR(a.dataHora) BETWEEN 6 AND 11 THEN 'Manha'
        WHEN HOUR(a.dataHora) BETWEEN 12 AND 17 THEN 'Tarde'
        ELSE 'Noite'
    END AS periodo_dia,
    CASE 
        WHEN a.nivel = 1 THEN 'Moderado'
        WHEN a.nivel = 2 THEN 'Critico'
        ELSE 'Desconhecido'
    END AS tipo_alerta,
    COUNT(*) AS quantidade_alertas
FROM Alerta a
JOIN ConfiguracaoMonitoramento cm ON a.fkConfiguracaoMonitoramento = cm.idConfiguracaoMonitoramento
JOIN Componente c ON cm.fkComponente = c.idComponente
JOIN Servidor s ON c.fkServidor = s.idServidor
JOIN Empresa e ON s.fkEmpresa = e.idEmpresa
WHERE a.dataHora >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
  AND e.idEmpresa = p()
  AND c.componente = 'RAM'
GROUP BY 
    mes_ordenacao,
    mes_formatado,
    periodo_dia,
    tipo_alerta
ORDER BY 
    mes_ordenacao, 
    FIELD(periodo_dia, 'Manha', 'Tarde', 'Noite'),
    tipo_alerta;

-- select * from (select @p:=1)parm, vw_alertas_ram_periodo;

#Alertas por mes de disco (GRAFICO)

CREATE OR REPLACE VIEW vw_alertas_mensais_empresa AS
SELECT 
    DATE_FORMAT(DATE_FORMAT(a.dataHora, '%Y-%m-01'), '%b %Y') AS mes_formatado,
    CASE 
        WHEN a.nivel = 1 THEN 'Moderado'
        WHEN a.nivel = 2 THEN 'Critico'
        ELSE 'Desconhecido'
    END AS tipo_alerta,
    COUNT(*) AS quantidade_alertas
FROM Alerta a
JOIN ConfiguracaoMonitoramento cm ON a.fkConfiguracaoMonitoramento = cm.idConfiguracaoMonitoramento
JOIN Componente c ON cm.fkComponente = c.idComponente
JOIN Servidor s ON c.fkServidor = s.idServidor
JOIN Empresa e ON s.fkEmpresa = e.idEmpresa
WHERE a.dataHora >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
  AND e.idEmpresa = p()
  AND c.componente in ('HD', 'SSD')
GROUP BY mes_formatado, tipo_alerta
ORDER BY STR_TO_DATE(mes_formatado, '%b %Y');

-- select * from Alerta Where fkConfiguracaoMonitoramento = 'psutil.disk_usage("/").percent';

#KPI QTDALERTA RAM

CREATE OR REPLACE VIEW qtdAlertaRAM AS
SELECT 
    MONTH(a.dataHora) AS mes_num,
    MONTHNAME(a.dataHora) AS mes_nome,
    CASE 
        WHEN a.nivel = 1 THEN 'Moderado'
        WHEN a.nivel = 2 THEN 'Critico'
        ELSE 'Desconhecido'
    END AS tipo_alerta,
    COUNT(*) AS totalAlertasRAM
FROM Alerta a
JOIN ConfiguracaoMonitoramento cm ON a.fkConfiguracaoMonitoramento = cm.idConfiguracaoMonitoramento
JOIN Componente c ON cm.fkComponente = c.idComponente
JOIN Servidor s ON c.fkServidor = s.idServidor
JOIN Empresa e ON s.fkEmpresa = e.idEmpresa
WHERE 
    a.dataHora >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    AND e.idEmpresa = p()
    AND c.componente = 'RAM'
GROUP BY mes_num, mes_nome, tipo_alerta
ORDER BY mes_num, tipo_alerta;

SELECT idConfiguracaoMonitoramento FROM ConfiguracaoMonitoramento;

INSERT INTO Alerta (nivel, dataHora, valor, fkConfiguracaoMonitoramento) VALUES
(2, '2024-12-01 21:18:47', 118.23, 10),
(2, '2025-06-03 21:18:47', 91, 12),
(2, '2024-12-02 02:10:47', 104.56, 13),
(2, '2024-12-03 08:23:47', 101.75, 9),
(2, '2024-12-03 04:34:47', 124.62, 7),
(1, '2024-12-03 20:36:47', 93.36, 20),
(2, '2024-12-03 12:58:47', 1000000000025.83, 6),
(2, '2024-12-04 15:04:47', 101.62, 17),
(2, '2024-12-05 04:38:47', 110.87, 7),
(1, '2024-12-05 22:42:47', 87.05, 7),
(1, '2024-12-06 06:51:47', 75.72, 9),
(1, '2024-12-07 12:17:47', 87.95, 25),
(1, '2024-12-07 11:41:47', 79.59, 21),
(1, '2024-12-07 15:43:47', 93.95, 16),
(1, '2024-12-08 07:44:47', 80.33, 19),
(2, '2024-12-09 11:26:47', 121.96, 7),
(2, '2024-12-08 14:17:47', 106.1, 20),
(1, '2024-12-09 17:21:47', 92.66, 13),
(1, '2024-12-10 05:02:47', 80.5, 12),
(1, '2024-12-10 14:14:47', 91.1, 15),
(2, '2024-12-11 02:13:47', 94.14, 14),
(2, '2024-12-11 14:57:47', 121.97, 20),
(1, '2024-12-11 13:10:47', 77.68, 3),
(2, '2024-12-13 08:48:47', 114.93, 16),
(1, '2024-12-13 00:14:47', 85.5, 3),
(1, '2024-12-13 15:10:47', 89.47, 18),
(1, '2024-12-14 07:18:47', 83.91, 15),
(1, '2024-12-15 01:16:47', 76.23, 9),
(2, '2024-12-14 22:13:47', 108.14, 10),
(1, '2024-12-16 00:34:47', 72.67, 14),
(1, '2024-12-16 00:08:47', 83.62, 3),
(2, '2024-12-16 20:38:47', 110.83, 24),
(2, '2024-12-16 13:47:47', 99.64, 22),
(1, '2024-12-18 08:26:47', 60.74, 10),
(1, '2024-12-18 00:41:47', 85.65, 8),
(2, '2024-12-18 20:24:47', 102.06, 20),
(1, '2024-12-18 16:42:47', 94.63, 11),
(1, '2024-12-20 07:15:47', 89.29, 18),
(2, '2024-12-20 11:18:47', 107.86, 18),
(1, '2024-12-20 22:06:47', 61.92, 10),
(2, '2024-12-21 04:34:47', 103.32, 19),
(2, '2024-12-21 14:53:47', 123.1, 25),
(2, '2024-12-22 11:00:47', 4007.84, 2),
(1, '2024-12-22 14:50:47', 73.04, 21),
(2, '2024-12-22 23:46:47', 115.48, 7),
(2, '2024-12-24 10:57:47', 119.13, 11),
(2, '2024-12-23 19:40:47', 111.96, 19),
(2, '2024-12-25 10:24:47', 95.18, 14),
(2, '2024-12-24 17:54:47', 117.59, 16),
(2, '2024-12-25 13:12:47', 104.66, 7),
(1, '2024-12-26 01:54:47', 84.35, 24),
(1, '2024-12-26 16:43:47', 92.41, 22),
(2, '2024-12-26 14:40:47', 102.93, 10),
(1, '2024-12-28 08:58:47', 93.22, 13),
(2, '2024-12-27 15:01:47', 109.47, 22),
(1, '2024-12-29 09:15:47', 85.87, 7),
(1, '2024-12-28 19:46:47', 81.63, 19),
(1, '2024-12-30 10:36:47', 90.12, 17),
(2, '2024-12-29 19:19:47', 103.75, 23),
(2, '2024-12-31 03:10:47', 111.5, 9),
(2, '2024-12-30 17:38:47', 16000000021.54, 4),
(1, '2025-01-01 11:34:47', 82.35, 21),
(1, '2024-12-31 14:23:47', 90.43, 8),
(1, '2025-01-02 01:17:47', 89.39, 25),
(2, '2025-01-01 18:01:47', 116.22, 13),
(2, '2025-01-02 18:03:47', 107.29, 15),
(2, '2025-01-02 13:34:47', 100.39, 23),
(2, '2025-01-03 13:12:47', 95.76, 3),
(2, '2025-01-04 02:25:47', 105.79, 22),
(1, '2025-01-05 09:59:47', 91.35, 1),
(2, '2025-01-04 20:46:47', 118.72, 14),
(2, '2025-01-05 18:32:47', 114.88, 19),
(1, '2025-01-06 10:14:47', 94.09, 22),
(2, '2025-01-06 23:19:47', 107.3, 22),
(1, '2025-01-07 10:42:47', 90.2, 23),
(2, '2025-01-07 14:47:47', 112.16, 11),
(1, '2025-01-08 00:16:47', 87.3, 8),
(2, '2025-01-09 06:45:47', 99.28, 1),
(1, '2025-01-08 15:48:47', 94.52, 18),
(2, '2025-01-09 22:54:47', 91.09, 3),
(2, '2025-01-09 13:34:47', 120.03, 11),
(2, '2025-01-11 02:57:47', 97.42, 7),
(1, '2025-01-11 06:16:47', 83.09, 3),
(1, '2025-01-11 21:54:47', 88.26, 9),
(1, '2025-01-11 21:43:47', 811794300690.37, 6),
(1, '2025-01-13 12:04:47', 92.91, 19),
(2, '2025-01-12 17:10:47', 98.99, 9),
(1, '2025-01-14 10:05:47', 79.57, 14),
(2, '2025-01-13 17:25:47', 102.56, 18),
(2, '2025-01-15 08:12:47', 105.9, 8),
(2, '2025-01-14 15:56:47', 99.81, 5),
(2, '2025-01-15 12:59:47', 111.11, 19),
(1, '2025-01-15 14:15:47', 69.07, 10),
(2, '2025-01-16 13:54:47', 119.31, 1),
(1, '2025-01-16 16:31:47', 86.52, 13),
(2, '2025-01-17 14:28:47', 103.03, 7),
(2, '2025-01-18 06:54:47', 117.81, 5),
(1, '2025-01-18 20:57:47', 76.42, 21),
(2, '2025-01-19 08:50:47', 97.4, 15),
(1, '2025-01-20 09:43:47', 13569748893.56, 4),
(2, '2025-01-20 07:18:47', 1000000000014.0, 6),
(2, '2025-01-21 01:28:47', 115.81, 24),
(2, '2025-01-21 09:11:47', 95.26, 20),
(1, '2025-01-22 10:56:47', 91.25, 15),
(2, '2025-01-21 22:42:47', 16000000006.52, 4),
(1, '2025-01-22 19:24:47', 81.35, 14),
(2, '2025-01-23 02:39:47', 109.46, 1),
(1, '2025-01-23 21:34:47', 75.32, 9),
(2, '2025-01-24 05:19:47', 123.75, 18),
(2, '2025-01-24 17:45:47', 120.67, 19),
(1, '2025-01-24 22:23:47', 80.29, 15),
(1, '2025-01-25 15:11:47', 85.48, 7),
(2, '2025-01-25 17:52:47', 112.73, 10),
(2, '2025-01-27 04:20:47', 111.11, 15),
(2, '2025-01-26 13:32:47', 104.83, 13),
(2, '2025-01-27 21:01:47', 102.63, 5),
(2, '2025-01-28 12:00:47', 106.83, 3),
(1, '2025-01-29 08:09:47', 80.53, 17),
(2, '2025-01-28 18:07:47', 101.4, 9),
(1, '2025-01-30 06:58:47', 87.67, 15),
(1, '2025-01-29 13:17:47', 94.55, 20),
(2, '2025-01-30 20:36:47', 101.66, 11),
(2, '2025-01-31 10:22:47', 120.57, 1),
(1, '2025-01-31 20:30:47', 75.0, 14),
(2, '2025-02-01 09:21:47', 112.25, 16),
(1, '2025-02-01 18:49:47', 80.25, 3),
(1, '2025-02-02 09:01:47', 90.66, 8),
(1, '2025-02-02 22:19:47', 85.53, 20),
(2, '2025-02-02 22:47:47', 114.51, 9),
(1, '2025-02-03 20:31:47', 80.34, 9),
(1, '2025-02-03 18:53:47', 88.22, 8),
(2, '2025-02-05 10:08:47', 1000000000029.77, 6),
(1, '2025-02-05 04:13:47', 66.51, 21),
(1, '2025-02-06 11:07:47', 85.23, 20),
(1, '2025-02-06 04:32:47', 91.58, 13),
(1, '2025-02-07 09:34:47', 3302.93, 2),
(2, '2025-02-06 20:29:47', 4027.37, 2),
(2, '2025-02-08 00:07:47', 1000000000021.55, 6),
(1, '2025-02-07 18:36:47', 12165043482.51, 4),
(1, '2025-02-08 17:59:47', 85.36, 9),
(1, '2025-02-09 08:04:47', 93.01, 25),
(2, '2025-02-10 00:38:47', 109.44, 8),
(2, '2025-02-10 00:33:47', 107.52, 3),
(1, '2025-02-10 22:52:47', 66.73, 10),
(2, '2025-02-10 20:11:47', 107.85, 9),
(2, '2025-02-11 15:03:47', 96.95, 19),
(1, '2025-02-12 11:59:47', 89.56, 18),
(2, '2025-02-12 18:20:47', 123.3, 1),
(2, '2025-02-13 00:30:47', 118.05, 1),
(1, '2025-02-13 21:52:47', 89.39, 15),
(1, '2025-02-14 11:42:47', 94.15, 8),
(1, '2025-02-15 11:51:47', 86.56, 22),
(1, '2025-02-14 13:54:47', 93.39, 13),
(1, '2025-02-15 21:45:47', 94.04, 13),
(1, '2025-02-15 20:05:47', 90.0, 5),
(2, '2025-02-16 22:07:47', 105.53, 17),
(2, '2025-02-17 01:18:47', 108.79, 12),
(1, '2025-02-18 08:42:47', 84.86, 21),
(1, '2025-02-17 20:05:47', 2238.59, 2),
(1, '2025-02-19 02:50:47', 93.98, 12),
(2, '2025-02-18 13:41:47', 120.55, 11),
(1, '2025-02-20 08:58:47', 75.3, 3),
(2, '2025-02-19 23:54:47', 112.19, 19),
(2, '2025-02-20 12:47:47', 105.61, 14),
(2, '2025-02-20 20:22:47', 4028.2, 2),
(1, '2025-02-21 22:49:47', 93.16, 7),
(1, '2025-02-21 21:32:47', 86.66, 25),
(1, '2025-02-23 12:13:47', 72.77, 21),
(2, '2025-02-22 19:59:47', 113.31, 7),
(2, '2025-02-23 19:04:47', 98.09, 16),
(2, '2025-02-24 01:14:47', 109.42, 24),
(2, '2025-02-24 22:19:47', 108.42, 19),
(2, '2025-02-24 19:24:47', 122.19, 13),
(2, '2025-02-26 06:21:47', 113.1, 5),
(1, '2025-02-26 00:30:47', 89.84, 18),
(2, '2025-02-27 01:13:47', 119.84, 22),
(1, '2025-02-26 22:28:47', 12231878863.25, 4),
(2, '2025-02-27 22:37:47', 116.02, 16),
(1, '2025-02-27 23:54:47', 90.15, 20),
(1, '2025-03-01 01:48:47', 85.24, 16),
(1, '2025-03-01 09:39:47', 15575782006.64, 4),
(1, '2025-03-02 06:21:47', 88.19, 11),
(1, '2025-03-01 14:43:47', 83.13, 16),
(1, '2025-03-03 00:40:47', 86.98, 24),
(1, '2025-03-02 19:48:47', 90.81, 25),
(1, '2025-03-04 04:38:47', 87.19, 15),
(2, '2025-03-03 15:35:47', 111.87, 8),
(1, '2025-03-04 22:49:47', 92.22, 15),
(1, '2025-03-05 07:46:47', 94.33, 22),
(1, '2025-03-06 03:43:47', 87.73, 1),
(2, '2025-03-05 23:17:47', 119.5, 16),
(2, '2025-03-07 03:51:47', 108.07, 20),
(2, '2025-03-06 21:16:47', 1000000000021.31, 6),
(1, '2025-03-08 10:46:47', 3344.78, 2),
(1, '2025-03-08 07:20:47', 85.49, 8),
(2, '2025-03-09 07:07:47', 103.58, 9),
(1, '2025-03-08 18:13:47', 90.7, 12),
(2, '2025-03-10 09:17:47', 108.79, 15),
(2, '2025-03-09 14:42:47', 100.25, 21),
(2, '2025-03-11 02:52:47', 99.93, 14),
(2, '2025-03-11 02:04:47', 106.72, 20),
(2, '2025-03-12 02:08:47', 107.94, 9),
(1, '2025-03-11 14:44:47', 93.5, 25),
(1, '2025-03-12 21:58:47', 88.8, 1),
(2, '2025-03-13 06:55:47', 1000000000012.23, 6),
(1, '2025-03-13 13:46:47', 81.39, 24),
(2, '2025-03-14 05:35:47', 110.58, 22),
(2, '2025-03-15 07:57:47', 97.32, 25),
(1, '2025-03-14 13:10:47', 82.08, 7),
(1, '2025-03-15 16:39:47', 80.98, 11),
(1, '2025-03-16 06:14:47', 93.51, 24),
(1, '2025-03-17 10:33:47', 86.46, 8),
(2, '2025-03-17 09:28:47', 107.27, 18),
(1, '2025-03-18 11:15:47', 80.96, 19),
(1, '2025-03-18 07:13:47', 90.54, 20),
(2, '2025-03-18 20:24:47', 95.43, 24),
(2, '2025-03-19 09:41:47', 116.49, 15),
(1, '2025-03-20 08:33:47', 81.15, 9),
(2, '2025-03-19 18:00:47', 101.66, 20),
(2, '2025-03-21 09:42:47', 16000000008.77, 4),
(1, '2025-03-21 07:03:47', 92.69, 19),
(1, '2025-03-22 10:58:47', 86.69, 15),
(2, '2025-03-21 21:14:47', 114.63, 21),
(1, '2025-03-23 12:20:47', 91.09, 18),
(1, '2025-03-22 17:51:47', 78.21, 9),
(1, '2025-03-23 23:38:47', 94.28, 18),
(1, '2025-03-23 16:41:47', 88.47, 10),
(1, '2025-03-24 15:17:47', 89.7, 3),
(1, '2025-03-24 20:03:47', 918746393974.15, 6),
(1, '2025-03-25 13:29:47', 2264.55, 2),
(2, '2025-03-26 00:50:47', 103.34, 5),
(2, '2025-03-27 02:05:47', 118.29, 7),
(2, '2025-03-26 21:08:47', 1000000000004.72, 6),
(1, '2025-03-28 06:06:47', 84.71, 11),
(1, '2025-03-27 22:32:47', 91.43, 19),
(1, '2025-03-28 21:05:47', 85.68, 18),
(2, '2025-03-29 03:52:47', 122.65, 13),
(2, '2025-03-30 05:11:47', 97.95, 16),
(1, '2025-03-30 00:31:47', 89.05, 25),
(1, '2025-03-31 10:00:47', 88.12, 20),
(2, '2025-03-31 02:31:47', 105.09, 17),
(1, '2025-04-01 10:25:47', 504931518696.92, 6),
(1, '2025-03-31 12:56:47', 80.14, 7),
(1, '2025-04-01 14:59:47', 82.37, 19),
(1, '2025-04-02 10:20:47', 86.84, 25),
(2, '2025-04-03 10:25:47', 112.31, 11),
(2, '2025-04-02 13:05:47', 102.11, 10),
(1, '2025-04-03 17:25:47', 82.16, 23),
(2, '2025-04-04 12:02:47', 4017.82, 2),
(1, '2025-04-05 05:36:47', 9985252726.13, 4),
(2, '2025-04-05 10:25:47', 105.26, 18),
(1, '2025-04-05 23:40:47', 93.24, 16),
(1, '2025-04-05 19:44:47', 83.36, 7),
(2, '2025-04-06 14:32:47', 112.78, 21),
(2, '2025-04-06 22:32:47', 116.9, 3),
(2, '2025-04-08 08:47:47', 97.01, 13),
(2, '2025-04-07 16:33:47', 4020.76, 2),
(1, '2025-04-09 02:57:47', 90.75, 17),
(1, '2025-04-09 01:16:47', 83.74, 14),
(2, '2025-04-09 17:09:47', 122.27, 13),
(1, '2025-04-09 16:55:47', 3334.35, 2),
(2, '2025-04-11 01:23:47', 96.32, 20),
(2, '2025-04-10 14:51:47', 92.06, 9),
(1, '2025-04-11 23:12:47', 83.52, 21),
(1, '2025-04-12 03:37:47', 90.79, 25),
(1, '2025-04-12 20:28:47', 15571700094.03, 4),
(2, '2025-04-13 11:11:47', 108.44, 9),
(1, '2025-04-14 05:12:47', 81.75, 7),
(2, '2025-04-13 21:47:47', 109.53, 19),
(1, '2025-04-14 18:05:47', 86.96, 3),
(2, '2025-04-14 22:46:47', 97.21, 18),
(2, '2025-04-15 19:19:47', 93.7, 14),
(1, '2025-04-16 00:13:47', 89.35, 19),
(1, '2025-04-17 02:54:47', 81.88, 1),
(1, '2025-04-16 21:56:47', 84.05, 19),
(2, '2025-04-18 06:16:47', 108.85, 9),
(2, '2025-04-18 01:43:47', 117.41, 8),
(2, '2025-04-19 09:26:47', 119.14, 11),
(1, '2025-04-18 21:50:47', 92.15, 15),
(1, '2025-04-20 08:08:47', 93.94, 25),
(2, '2025-04-20 04:42:47', 116.13, 16),
(1, '2025-04-21 08:41:47', 93.15, 15),
(2, '2025-04-20 20:35:47', 103.43, 11),
(1, '2025-04-22 01:29:47', 93.4, 17),
(2, '2025-04-21 20:26:47', 107.42, 18),
(2, '2025-04-22 16:28:47', 123.79, 1),
(1, '2025-04-23 08:47:47', 86.01, 11),
(1, '2025-04-23 14:07:47', 89.44, 18),
(2, '2025-04-23 21:07:47', 96.63, 20),
(1, '2025-04-24 13:15:47', 81.44, 24),
(2, '2025-04-25 12:12:47', 109.98, 8),
(2, '2025-04-26 06:58:47', 97.65, 10),
(2, '2025-04-26 12:30:47', 114.95, 22),
(2, '2025-04-26 18:41:47', 119.15, 16),
(1, '2025-04-27 01:53:47', 71.73, 14),
(2, '2025-04-28 08:20:47', 122.98, 11),
(2, '2025-04-28 06:12:47', 95.42, 12),
(2, '2025-04-29 05:09:47', 103.97, 17),
(2, '2025-04-29 09:00:47', 16000000010.84, 4),
(2, '2025-04-30 03:26:47', 98.87, 24),
(2, '2025-04-29 20:21:47', 106.74, 23),
(1, '2025-05-01 05:09:47', 78.76, 3),
(1, '2025-05-01 03:10:47', 87.74, 23),
(2, '2025-05-01 18:55:47', 91.55, 3),
(1, '2025-05-01 18:47:47', 87.5, 5),
(1, '2025-05-03 09:46:47', 3799.4, 2),
(2, '2025-05-02 19:03:47', 107.01, 5),
(1, '2025-05-03 20:59:47', 81.67, 15),
(1, '2025-05-03 14:58:47', 88.56, 15),
(2, '2025-05-05 07:56:47', 98.82, 23),
(2, '2025-05-04 20:16:47', 116.48, 13),
(1, '2025-05-05 21:04:47', 71.17, 9),
(2, '2025-05-05 15:19:47', 108.54, 9),
(1, '2025-05-06 18:06:47', 94.03, 18),
(2, '2025-05-06 14:28:47', 1000000000027.03, 6),
(2, '2025-05-08 10:57:47', 104.55, 13),
(2, '2025-05-08 12:02:47', 107.18, 14),
(1, '2025-05-08 23:46:47', 88.71, 10),
(2, '2025-05-09 03:07:47', 113.7, 9),
(2, '2025-05-10 02:29:47', 114.09, 18),
(2, '2025-05-09 15:25:47', 123.66, 1),
(1, '2025-05-11 03:34:47', 63.19, 21),
(2, '2025-05-11 08:07:47', 101.45, 7),
(1, '2025-05-11 13:33:47', 90.26, 19),
(1, '2025-05-12 01:51:47', 75.18, 9),
(2, '2025-05-13 11:24:47', 110.26, 9),
(1, '2025-05-12 15:55:47', 81.76, 10),
(2, '2025-05-14 09:23:47', 97.33, 15),
(1, '2025-05-14 10:10:47', 81.3, 11),
(2, '2025-05-15 06:57:47', 103.58, 14),
(2, '2025-05-14 14:56:47', 114.79, 5),
(2, '2025-05-16 12:39:47', 109.19, 22),
(1, '2025-05-15 14:56:47', 80.19, 17),
(1, '2025-05-17 02:43:47', 85.43, 23),
(1, '2025-05-16 21:36:47', 10738183296.35, 4),
(1, '2025-05-17 17:49:47', 83.63, 14),
(2, '2025-05-17 15:25:47', 4010.79, 2),
(1, '2025-05-18 14:56:47', 697970398852.48, 6),
(2, '2025-05-19 00:23:47', 102.51, 24),
(1, '2025-05-20 02:47:47', 72.14, 10),
(2, '2025-05-19 19:23:47', 16000000029.2, 4),
(2, '2025-05-21 12:38:47', 99.41, 25),
(2, '2025-05-20 16:42:47', 123.34, 8),
(1, '2025-05-22 01:15:47', 92.55, 8),
(2, '2025-05-21 21:28:47', 100.33, 23),
(2, '2025-05-22 19:54:47', 112.67, 12),
(1, '2025-05-22 21:50:47', 8296170448.87, 4),
(1, '2025-05-24 06:22:47', 90.89, 8),
(2, '2025-05-23 13:13:47', 102.17, 20),
(1, '2025-05-25 01:58:47', 86.42, 9),
(2, '2025-05-24 23:00:47', 107.27, 7),
(1, '2025-05-26 10:37:47', 88.12, 14),
(1, '2025-05-25 22:37:47', 86.06, 20),
(2, '2025-05-26 21:08:47', 119.6, 10),
(1, '2025-05-27 10:57:47', 83.54, 17),
(2, '2025-05-28 10:21:47', 108.96, 21),
(1, '2025-05-28 11:16:47', 87.73, 24),
(2, '2025-05-28 21:38:47', 117.11, 20),
(1, '2025-05-29 10:04:47', 556840962102.3, 6),
(1, '2025-05-29 19:04:47', 74.65, 21),
(1, '2025-05-29 17:08:47', 94.1, 18);

INSERT INTO Processo (nomeProcesso, usoCpu, usoGpu, usoRam, fkAlerta, fkServidor, dataHora) VALUES
('Maya', 23.61, 87.96, 61.03, 1, 5, '2024-12-01 21:18:47'),
('Maya', 87.01, 62.36, 92.77, 2, 6, '2024-12-02 02:10:47'),
('Blender', 63.32, 50.66, 95.78, 3, 6, '2024-12-03 08:23:47'),
('Blender', 65.57, 69.13, 72.02, 4, 6, '2024-12-03 04:34:47'),
('Blender', 53.94, 37.48, 76.25, 5, 3, '2024-12-03 20:36:47'),
('Blender', 47.65, 26.85, 51.91, 6, 1, '2024-12-03 12:58:47'),
('Paint 3D', 77.39, 49.43, 72.25, 7, 1, '2024-12-04 15:04:47'),
('Paint 3D', 72.24, 43.36, 56.81, 8, 1, '2024-12-05 04:38:47'),
('Paint 3D', 32.18, 35.11, 60.9, 9, 6, '2024-12-05 22:42:47'),
('Blender', 33.88, 37.5, 71.51, 10, 2, '2024-12-06 06:51:47'),
('Blender', 44.02, 48.54, 69.03, 11, 1, '2024-12-07 12:17:47'),
('Blender', 10.96, 33.8, 70.15, 12, 1, '2024-12-07 11:41:47'),
('Blender', 61.7, 25.37, 81.87, 13, 5, '2024-12-07 15:43:47'),
('Paint 3D', 67.27, 37.18, 90.08, 14, 1, '2024-12-08 07:44:47'),
('Maya', 48.17, 7.93, 52.59, 15, 1, '2024-12-09 11:26:47'),
('Blender', 13.4, 66.06, 63.44, 16, 2, '2024-12-08 14:17:47'),
('Blender', 34.51, 21.77, 85.3, 17, 6, '2024-12-09 17:21:47'),
('Blender', 63.42, 19.56, 60.76, 18, 2, '2024-12-10 05:02:47'),
('Blender', 65.78, 40.02, 59.9, 19, 2, '2024-12-10 14:14:47'),
('Paint 3D', 31.95, 8.6, 79.77, 20, 5, '2024-12-11 02:13:47'),
('Maya', 18.68, 59.99, 65.52, 21, 5, '2024-12-11 14:57:47'),
('Blender', 82.16, 20.8, 54.69, 22, 2, '2024-12-11 13:10:47'),
('Paint 3D', 21.61, 16.76, 59.87, 23, 5, '2024-12-13 08:48:47'),
('Paint 3D', 36.79, 56.18, 70.53, 24, 3, '2024-12-13 00:14:47'),
('Paint 3D', 61.21, 69.07, 75.91, 25, 1, '2024-12-13 15:10:47'),
('Maya', 67.86, 81.84, 88.82, 26, 3, '2024-12-14 07:18:47'),
('Blender', 20.86, 46.89, 89.1, 27, 1, '2024-12-15 01:16:47'),
('Blender', 93.35, 10.76, 93.78, 28, 6, '2024-12-14 22:13:47'),
('Paint 3D', 40.42, 85.81, 60.85, 29, 6, '2024-12-16 00:34:47'),
('Blender', 76.98, 87.48, 57.47, 30, 3, '2024-12-16 00:08:47'),
('Blender', 11.74, 85.77, 78.68, 31, 6, '2024-12-16 20:38:47'),
('Blender', 61.3, 45.58, 92.16, 32, 6, '2024-12-16 13:47:47'),
('Paint 3D', 31.96, 16.58, 72.93, 33, 2, '2024-12-18 08:26:47'),
('Paint 3D', 84.96, 29.84, 69.51, 34, 5, '2024-12-18 00:41:47'),
('Maya', 91.93, 75.57, 91.96, 35, 6, '2024-12-18 20:24:47'),
('Maya', 41.91, 59.53, 55.48, 36, 3, '2024-12-18 16:42:47'),
('Paint 3D', 19.27, 32.66, 97.4, 37, 4, '2024-12-20 07:15:47'),
('Paint 3D', 81.84, 56.14, 81.75, 38, 6, '2024-12-20 11:18:47'),
('Maya', 83.13, 16.73, 52.8, 39, 2, '2024-12-20 22:06:47'),
('Paint 3D', 31.87, 27.89, 77.67, 40, 2, '2024-12-21 04:34:47'),
('Paint 3D', 19.71, 88.24, 65.72, 41, 6, '2024-12-21 14:53:47'),
('Paint 3D', 72.32, 77.94, 81.31, 42, 6, '2024-12-22 11:00:47'),
('Paint 3D', 43.2, 15.9, 92.54, 43, 1, '2024-12-22 14:50:47'),
('Maya', 34.09, 26.71, 79.19, 44, 2, '2024-12-22 23:46:47'),
('Maya', 35.63, 19.1, 96.4, 45, 2, '2024-12-24 10:57:47'),
('Paint 3D', 63.89, 39.1, 69.34, 46, 1, '2024-12-23 19:40:47'),
('Blender', 90.92, 59.43, 87.07, 47, 6, '2024-12-25 10:24:47'),
('Paint 3D', 90.62, 61.86, 51.24, 48, 5, '2024-12-24 17:54:47'),
('Paint 3D', 74.48, 67.37, 74.68, 49, 6, '2024-12-25 13:12:47'),
('Blender', 86.71, 19.85, 96.61, 50, 5, '2024-12-26 01:54:47'),
('Blender', 14.21, 55.47, 79.43, 51, 5, '2024-12-26 16:43:47'),
('Blender', 45.65, 13.39, 85.12, 52, 6, '2024-12-26 14:40:47'),
('Maya', 27.28, 60.69, 95.45, 53, 6, '2024-12-28 08:58:47'),
('Blender', 26.2, 44.49, 63.65, 54, 5, '2024-12-27 15:01:47'),
('Blender', 56.33, 48.42, 83.41, 55, 6, '2024-12-29 09:15:47'),
('Paint 3D', 78.81, 27.96, 84.42, 56, 5, '2024-12-28 19:46:47'),
('Blender', 24.53, 40.29, 83.46, 57, 3, '2024-12-30 10:36:47'),
('Maya', 76.6, 19.06, 51.86, 58, 6, '2024-12-29 19:19:47'),
('Paint 3D', 45.99, 43.17, 78.5, 59, 1, '2024-12-31 03:10:47'),
('Blender', 84.42, 36.84, 71.0, 60, 1, '2024-12-30 17:38:47'),
('Paint 3D', 46.62, 8.03, 60.19, 61, 5, '2025-01-01 11:34:47'),
('Blender', 66.74, 69.94, 58.22, 62, 5, '2024-12-31 14:23:47'),
('Blender', 19.34, 29.14, 95.63, 63, 4, '2025-01-02 01:17:47'),
('Maya', 68.71, 46.71, 84.04, 64, 4, '2025-01-01 18:01:47'),
('Paint 3D', 82.42, 76.59, 60.15, 65, 6, '2025-01-02 18:03:47'),
('Paint 3D', 49.59, 62.62, 59.92, 66, 3, '2025-01-02 13:34:47'),
('Blender', 44.04, 80.77, 51.57, 67, 1, '2025-01-03 13:12:47'),
('Blender', 78.89, 59.89, 55.06, 68, 5, '2025-01-04 02:25:47'),
('Paint 3D', 28.94, 24.94, 82.75, 69, 6, '2025-01-05 09:59:47'),
('Paint 3D', 64.4, 30.91, 68.16, 70, 1, '2025-01-04 20:46:47'),
('Paint 3D', 85.55, 43.3, 62.78, 71, 3, '2025-01-05 18:32:47'),
('Maya', 91.62, 20.06, 61.27, 72, 5, '2025-01-06 10:14:47'),
('Paint 3D', 88.59, 36.51, 64.26, 73, 5, '2025-01-06 23:19:47'),
('Maya', 81.41, 89.61, 88.11, 74, 5, '2025-01-07 10:42:47'),
('Paint 3D', 64.95, 67.01, 90.27, 75, 5, '2025-01-07 14:47:47'),
('Paint 3D', 80.96, 28.34, 77.78, 76, 6, '2025-01-08 00:16:47'),
('Blender', 43.59, 9.14, 95.02, 77, 1, '2025-01-09 06:45:47'),
('Maya', 24.43, 45.27, 92.69, 78, 3, '2025-01-08 15:48:47'),
('Blender', 68.91, 7.84, 69.57, 79, 4, '2025-01-09 22:54:47'),
('Blender', 91.6, 46.94, 86.06, 80, 1, '2025-01-09 13:34:47'),
('Maya', 27.43, 13.33, 46.14, 81, 2, '2025-01-11 02:57:47'),
('Maya', 17.7, 9.06, 90.82, 82, 6, '2025-01-11 06:16:47'),
('Paint 3D', 57.15, 15.56, 61.34, 83, 5, '2025-01-11 21:54:47'),
('Blender', 35.58, 86.97, 94.24, 84, 6, '2025-01-11 21:43:47'),
('Maya', 17.6, 12.52, 71.43, 85, 3, '2025-01-13 12:04:47'),
('Paint 3D', 45.28, 22.76, 74.84, 86, 4, '2025-01-12 17:10:47'),
('Maya', 88.06, 6.66, 92.58, 87, 4, '2025-01-14 10:05:47'),
('Blender', 71.43, 70.14, 77.83, 88, 4, '2025-01-13 17:25:47'),
('Blender', 24.49, 34.23, 71.32, 89, 1, '2025-01-15 08:12:47'),
('Maya', 25.3, 54.57, 53.52, 90, 4, '2025-01-14 15:56:47'),
('Blender', 13.07, 29.04, 96.0, 91, 2, '2025-01-15 12:59:47'),
('Blender', 39.93, 79.05, 46.9, 92, 2, '2025-01-15 14:15:47'),
('Blender', 79.97, 41.55, 56.71, 93, 3, '2025-01-16 13:54:47'),
('Maya', 23.2, 89.01, 47.98, 94, 1, '2025-01-16 16:31:47'),
('Blender', 65.94, 15.03, 69.67, 95, 4, '2025-01-17 14:28:47'),
('Blender', 27.73, 35.01, 49.12, 96, 6, '2025-01-18 06:54:47'),
('Paint 3D', 26.33, 69.09, 84.22, 97, 5, '2025-01-18 20:57:47'),
('Blender', 13.59, 76.79, 59.7, 98, 5, '2025-01-19 08:50:47'),
('Maya', 84.46, 44.97, 83.5, 99, 5, '2025-01-20 09:43:47'),
('Paint 3D', 61.4, 22.79, 53.85, 100, 1, '2025-01-20 07:18:47'),
('Maya', 67.4, 9.38, 68.4, 101, 2, '2025-01-21 01:28:47'),
('Paint 3D', 40.83, 14.63, 79.74, 102, 1, '2025-01-21 09:11:47'),
('Maya', 62.61, 38.83, 63.31, 103, 1, '2025-01-22 10:56:47'),
('Blender', 67.14, 54.95, 63.88, 104, 1, '2025-01-21 22:42:47'),
('Maya', 38.84, 41.51, 96.22, 105, 3, '2025-01-22 19:24:47'),
('Maya', 91.26, 51.36, 61.65, 106, 5, '2025-01-23 02:39:47'),
('Paint 3D', 56.67, 53.42, 64.59, 107, 1, '2025-01-23 21:34:47'),
('Paint 3D', 38.62, 57.05, 61.5, 108, 4, '2025-01-24 05:19:47'),
('Maya', 59.99, 77.88, 52.77, 109, 2, '2025-01-24 17:45:47'),
('Paint 3D', 52.01, 21.44, 73.14, 110, 2, '2025-01-24 22:23:47'),
('Paint 3D', 16.09, 83.61, 74.95, 111, 1, '2025-01-25 15:11:47'),
('Blender', 73.78, 68.56, 80.27, 112, 1, '2025-01-25 17:52:47'),
('Paint 3D', 83.71, 46.35, 85.34, 113, 1, '2025-01-27 04:20:47'),
('Paint 3D', 62.37, 16.13, 96.19, 114, 6, '2025-01-26 13:32:47'),
('Maya', 94.83, 19.81, 52.38, 115, 3, '2025-01-27 21:01:47'),
('Paint 3D', 54.3, 15.5, 71.09, 116, 4, '2025-01-28 12:00:47'),
('Maya', 80.08, 17.4, 82.19, 117, 1, '2025-01-29 08:09:47'),
('Paint 3D', 75.06, 66.13, 97.95, 118, 1, '2025-01-28 18:07:47'),
('Maya', 27.43, 58.28, 74.9, 119, 3, '2025-01-30 06:58:47'),
('Paint 3D', 70.54, 32.69, 80.38, 120, 2, '2025-01-29 13:17:47'),
('Paint 3D', 22.25, 39.39, 68.46, 121, 1, '2025-01-30 20:36:47'),
('Paint 3D', 79.03, 47.05, 73.65, 122, 3, '2025-01-31 10:22:47'),
('Paint 3D', 66.73, 39.82, 86.52, 123, 6, '2025-01-31 20:30:47'),
('Maya', 33.53, 50.78, 68.84, 124, 4, '2025-02-01 09:21:47'),
('Paint 3D', 10.05, 83.16, 68.01, 125, 3, '2025-02-01 18:49:47'),
('Blender', 54.65, 42.74, 63.0, 126, 6, '2025-02-02 09:01:47'),
('Paint 3D', 46.62, 63.5, 82.44, 127, 4, '2025-02-02 22:19:47'),
('Blender', 68.48, 76.36, 92.89, 128, 3, '2025-02-02 22:47:47'),
('Paint 3D', 90.22, 37.42, 75.96, 129, 3, '2025-02-03 20:31:47'),
('Blender', 23.14, 78.62, 63.15, 130, 6, '2025-02-03 18:53:47'),
('Maya', 29.03, 89.39, 78.5, 131, 3, '2025-02-05 10:08:47'),
('Maya', 90.76, 31.12, 75.26, 132, 2, '2025-02-05 04:13:47'),
('Blender', 62.16, 23.58, 91.51, 133, 2, '2025-02-06 11:07:47'),
('Blender', 67.29, 79.01, 97.04, 134, 6, '2025-02-06 04:32:47'),
('Maya', 93.27, 15.5, 55.95, 135, 5, '2025-02-07 09:34:47'),
('Paint 3D', 54.59, 76.18, 95.63, 136, 6, '2025-02-06 20:29:47'),
('Maya', 11.06, 54.6, 68.71, 137, 1, '2025-02-08 00:07:47'),
('Paint 3D', 83.05, 64.73, 91.19, 138, 2, '2025-02-07 18:36:47'),
('Maya', 41.87, 88.49, 61.72, 139, 5, '2025-02-08 17:59:47'),
('Blender', 31.83, 11.72, 83.32, 140, 6, '2025-02-09 08:04:47'),
('Blender', 46.16, 40.84, 68.57, 141, 6, '2025-02-10 00:38:47'),
('Maya', 42.31, 36.95, 96.9, 142, 3, '2025-02-10 00:33:47'),
('Blender', 55.96, 51.12, 55.17, 143, 1, '2025-02-10 22:52:47'),
('Maya', 27.82, 64.33, 57.53, 144, 4, '2025-02-10 20:11:47'),
('Paint 3D', 81.13, 35.88, 66.3, 145, 1, '2025-02-11 15:03:47'),
('Paint 3D', 52.41, 51.53, 92.8, 146, 4, '2025-02-12 11:59:47'),
('Paint 3D', 67.64, 47.74, 85.05, 147, 3, '2025-02-12 18:20:47'),
('Maya', 76.19, 89.07, 84.24, 148, 1, '2025-02-13 00:30:47'),
('Paint 3D', 90.52, 8.44, 64.76, 149, 4, '2025-02-13 21:52:47'),
('Blender', 81.39, 83.03, 53.98, 150, 1, '2025-02-14 11:42:47'),
('Blender', 61.69, 47.11, 67.07, 151, 3, '2025-02-15 11:51:47'),
('Blender', 84.52, 70.36, 45.42, 152, 4, '2025-02-14 13:54:47'),
('Paint 3D', 56.9, 19.88, 46.58, 153, 3, '2025-02-15 21:45:47'),
('Paint 3D', 52.6, 31.58, 95.17, 154, 1, '2025-02-15 20:05:47'),
('Maya', 93.45, 47.76, 56.77, 155, 5, '2025-02-16 22:07:47'),
('Blender', 71.04, 51.78, 58.86, 156, 5, '2025-02-17 01:18:47'),
('Maya', 43.99, 83.27, 67.45, 157, 4, '2025-02-18 08:42:47'),
('Paint 3D', 90.2, 80.14, 93.83, 158, 5, '2025-02-17 20:05:47'),
('Blender', 40.27, 64.17, 95.38, 159, 2, '2025-02-19 02:50:47'),
('Maya', 66.04, 28.83, 66.62, 160, 6, '2025-02-18 13:41:47'),
('Paint 3D', 53.4, 85.22, 56.26, 161, 4, '2025-02-20 08:58:47'),
('Paint 3D', 86.68, 21.87, 95.12, 162, 4, '2025-02-19 23:54:47'),
('Paint 3D', 64.27, 36.36, 49.6, 163, 2, '2025-02-20 12:47:47'),
('Paint 3D', 26.93, 46.11, 77.03, 164, 2, '2025-02-20 20:22:47'),
('Paint 3D', 80.92, 17.08, 46.03, 165, 4, '2025-02-21 22:49:47'),
('Paint 3D', 73.47, 58.23, 83.15, 166, 3, '2025-02-21 21:32:47'),
('Maya', 25.95, 82.6, 81.19, 167, 5, '2025-02-23 12:13:47'),
('Paint 3D', 65.44, 48.42, 64.51, 168, 4, '2025-02-22 19:59:47'),
('Blender', 93.91, 81.79, 55.52, 169, 5, '2025-02-23 19:04:47'),
('Paint 3D', 66.87, 64.18, 50.94, 170, 4, '2025-02-24 01:14:47'),
('Paint 3D', 14.07, 36.94, 53.99, 171, 6, '2025-02-24 22:19:47'),
('Maya', 78.45, 30.33, 48.53, 172, 6, '2025-02-24 19:24:47'),
('Blender', 53.52, 87.36, 88.3, 173, 6, '2025-02-26 06:21:47'),
('Maya', 10.36, 28.01, 57.86, 174, 2, '2025-02-26 00:30:47'),
('Maya', 82.75, 77.83, 86.13, 175, 3, '2025-02-27 01:13:47'),
('Paint 3D', 48.92, 32.54, 85.0, 176, 1, '2025-02-26 22:28:47'),
('Paint 3D', 88.68, 56.01, 84.02, 177, 4, '2025-02-27 22:37:47'),
('Blender', 58.87, 45.21, 74.96, 178, 5, '2025-02-27 23:54:47'),
('Paint 3D', 34.29, 87.47, 51.5, 179, 4, '2025-03-01 01:48:47'),
('Blender', 14.24, 21.46, 88.4, 180, 5, '2025-03-01 09:39:47'),
('Blender', 91.87, 5.04, 82.74, 181, 3, '2025-03-02 06:21:47'),
('Maya', 91.32, 53.69, 47.89, 182, 1, '2025-03-01 14:43:47'),
('Blender', 58.06, 12.45, 52.98, 183, 6, '2025-03-03 00:40:47'),
('Maya', 89.94, 23.32, 61.66, 184, 6, '2025-03-02 19:48:47'),
('Maya', 84.99, 48.19, 86.46, 185, 2, '2025-03-04 04:38:47'),
('Blender', 43.17, 45.34, 80.01, 186, 4, '2025-03-03 15:35:47'),
('Maya', 36.33, 28.37, 89.32, 187, 5, '2025-03-04 22:49:47'),
('Paint 3D', 89.3, 66.0, 85.82, 188, 5, '2025-03-05 07:46:47'),
('Blender', 18.47, 22.03, 83.24, 189, 2, '2025-03-06 03:43:47'),
('Maya', 14.79, 15.21, 74.64, 190, 2, '2025-03-05 23:17:47'),
('Paint 3D', 60.39, 79.45, 53.32, 191, 4, '2025-03-07 03:51:47'),
('Maya', 43.06, 21.86, 86.33, 192, 1, '2025-03-06 21:16:47'),
('Maya', 52.21, 72.6, 76.16, 193, 5, '2025-03-08 10:46:47'),
('Paint 3D', 56.29, 38.31, 92.82, 194, 5, '2025-03-08 07:20:47'),
('Blender', 69.1, 56.07, 65.22, 195, 6, '2025-03-09 07:07:47'),
('Maya', 32.47, 27.6, 92.24, 196, 5, '2025-03-08 18:13:47'),
('Blender', 83.14, 29.82, 92.62, 197, 6, '2025-03-10 09:17:47'),
('Paint 3D', 71.84, 10.44, 86.24, 198, 1, '2025-03-09 14:42:47'),
('Paint 3D', 48.66, 69.06, 54.18, 199, 1, '2025-03-11 02:52:47'),
('Blender', 42.48, 24.42, 96.97, 200, 2, '2025-03-11 02:04:47'),
('Blender', 41.88, 30.79, 47.25, 201, 5, '2025-03-12 02:08:47'),
('Maya', 43.95, 45.73, 87.83, 202, 3, '2025-03-11 14:44:47'),
('Blender', 70.13, 74.85, 92.81, 203, 4, '2025-03-12 21:58:47'),
('Maya', 36.43, 8.73, 91.58, 204, 3, '2025-03-13 06:55:47'),
('Blender', 53.3, 13.65, 62.5, 205, 1, '2025-03-13 13:46:47'),
('Paint 3D', 39.5, 84.26, 56.3, 206, 6, '2025-03-14 05:35:47'),
('Paint 3D', 16.13, 75.72, 54.6, 207, 5, '2025-03-15 07:57:47'),
('Maya', 35.28, 11.76, 81.89, 208, 2, '2025-03-14 13:10:47'),
('Paint 3D', 90.98, 27.71, 75.36, 209, 4, '2025-03-15 16:39:47'),
('Maya', 32.52, 73.59, 84.1, 210, 5, '2025-03-16 06:14:47'),
('Blender', 90.78, 75.4, 60.17, 211, 3, '2025-03-17 10:33:47'),
('Maya', 28.64, 51.44, 64.62, 212, 1, '2025-03-17 09:28:47'),
('Maya', 34.33, 30.58, 65.13, 213, 5, '2025-03-18 11:15:47'),
('Blender', 51.88, 68.94, 70.54, 214, 4, '2025-03-18 07:13:47'),
('Paint 3D', 19.23, 61.52, 47.25, 215, 5, '2025-03-18 20:24:47'),
('Paint 3D', 58.42, 40.13, 86.04, 216, 6, '2025-03-19 09:41:47'),
('Blender', 46.98, 76.22, 82.34, 217, 6, '2025-03-20 08:33:47'),
('Paint 3D', 34.33, 21.0, 74.36, 218, 3, '2025-03-19 18:00:47'),
('Maya', 18.38, 63.09, 51.64, 219, 1, '2025-03-21 09:42:47'),
('Maya', 37.83, 56.63, 70.52, 220, 2, '2025-03-21 07:03:47'),
('Paint 3D', 25.31, 26.8, 76.59, 221, 5, '2025-03-22 10:58:47'),
('Paint 3D', 70.43, 65.24, 93.48, 222, 6, '2025-03-21 21:14:47'),
('Paint 3D', 31.06, 27.74, 58.65, 223, 1, '2025-03-23 12:20:47'),
('Maya', 77.35, 62.96, 59.48, 224, 2, '2025-03-22 17:51:47'),
('Maya', 91.16, 46.31, 72.24, 225, 5, '2025-03-23 23:38:47'),
('Paint 3D', 65.66, 19.57, 86.55, 226, 3, '2025-03-23 16:41:47'),
('Paint 3D', 46.64, 38.32, 49.35, 227, 2, '2025-03-24 15:17:47'),
('Blender', 88.6, 24.85, 90.82, 228, 3, '2025-03-24 20:03:47'),
('Paint 3D', 72.29, 27.72, 93.57, 229, 2, '2025-03-25 13:29:47'),
('Maya', 17.11, 17.26, 92.49, 230, 2, '2025-03-26 00:50:47'),
('Maya', 12.84, 33.7, 94.4, 231, 4, '2025-03-27 02:05:47'),
('Paint 3D', 92.93, 71.0, 85.5, 232, 2, '2025-03-26 21:08:47'),
('Blender', 89.71, 38.94, 89.95, 233, 4, '2025-03-28 06:06:47'),
('Maya', 78.03, 64.31, 75.18, 234, 4, '2025-03-27 22:32:47'),
('Blender', 63.86, 7.79, 89.82, 235, 2, '2025-03-28 21:05:47'),
('Blender', 46.23, 21.66, 49.79, 236, 2, '2025-03-29 03:52:47'),
('Blender', 83.2, 41.71, 57.96, 237, 2, '2025-03-30 05:11:47'),
('Blender', 83.58, 37.6, 56.83, 238, 3, '2025-03-30 00:31:47'),
('Paint 3D', 79.5, 22.83, 69.73, 239, 3, '2025-03-31 10:00:47'),
('Blender', 17.61, 86.9, 49.51, 240, 5, '2025-03-31 02:31:47'),
('Maya', 58.85, 33.7, 88.84, 241, 6, '2025-04-01 10:25:47'),
('Maya', 36.62, 55.68, 73.28, 242, 5, '2025-03-31 12:56:47'),
('Blender', 64.68, 25.77, 60.54, 243, 5, '2025-04-01 14:59:47'),
('Maya', 64.26, 9.71, 52.17, 244, 1, '2025-04-02 10:20:47'),
('Paint 3D', 80.89, 49.12, 69.02, 245, 4, '2025-04-03 10:25:47'),
('Maya', 50.19, 38.94, 45.8, 246, 5, '2025-04-02 13:05:47'),
('Blender', 79.9, 57.92, 93.28, 247, 2, '2025-04-03 17:25:47'),
('Paint 3D', 70.71, 79.58, 91.39, 248, 1, '2025-04-04 12:02:47'),
('Blender', 69.37, 56.69, 76.04, 249, 6, '2025-04-05 05:36:47'),
('Maya', 82.83, 84.17, 54.5, 250, 4, '2025-04-05 10:25:47'),
('Blender', 69.56, 7.96, 62.46, 251, 3, '2025-04-05 23:40:47'),
('Blender', 71.88, 89.22, 71.03, 252, 2, '2025-04-05 19:44:47'),
('Blender', 46.23, 10.87, 52.24, 253, 2, '2025-04-06 14:32:47'),
('Maya', 91.51, 21.15, 51.79, 254, 2, '2025-04-06 22:32:47'),
('Paint 3D', 88.24, 23.35, 88.64, 255, 1, '2025-04-08 08:47:47'),
('Blender', 26.57, 72.3, 58.18, 256, 6, '2025-04-07 16:33:47'),
('Blender', 81.12, 6.58, 62.82, 257, 3, '2025-04-09 02:57:47'),
('Maya', 13.85, 39.56, 49.0, 258, 2, '2025-04-09 01:16:47'),
('Maya', 78.92, 82.1, 57.92, 259, 5, '2025-04-09 17:09:47'),
('Paint 3D', 66.4, 13.23, 78.17, 260, 4, '2025-04-09 16:55:47'),
('Blender', 34.31, 41.21, 79.09, 261, 3, '2025-04-11 01:23:47'),
('Maya', 24.15, 80.64, 80.38, 262, 3, '2025-04-10 14:51:47'),
('Paint 3D', 47.86, 52.68, 63.48, 263, 5, '2025-04-11 23:12:47'),
('Maya', 58.49, 54.51, 92.7, 264, 2, '2025-04-12 03:37:47'),
('Paint 3D', 25.07, 39.48, 96.92, 265, 2, '2025-04-12 20:28:47'),
('Maya', 72.89, 63.2, 96.9, 266, 4, '2025-04-13 11:11:47'),
('Maya', 87.2, 25.82, 49.47, 267, 1, '2025-04-14 05:12:47'),
('Blender', 29.92, 10.73, 57.4, 268, 2, '2025-04-13 21:47:47'),
('Paint 3D', 40.43, 58.2, 55.19, 269, 3, '2025-04-14 18:05:47'),
('Maya', 53.55, 50.44, 47.99, 270, 2, '2025-04-14 22:46:47'),
('Blender', 44.73, 41.69, 62.86, 271, 3, '2025-04-15 19:19:47'),
('Maya', 34.11, 79.68, 94.83, 272, 4, '2025-04-16 00:13:47'),
('Blender', 42.3, 15.79, 52.04, 273, 4, '2025-04-17 02:54:47'),
('Blender', 53.47, 48.23, 67.19, 274, 2, '2025-04-16 21:56:47'),
('Maya', 89.75, 64.63, 61.03, 275, 5, '2025-04-18 06:16:47'),
('Blender', 73.18, 67.99, 54.36, 276, 2, '2025-04-18 01:43:47'),
('Blender', 69.28, 24.5, 53.92, 277, 4, '2025-04-19 09:26:47'),
('Maya', 91.74, 11.4, 45.75, 278, 5, '2025-04-18 21:50:47'),
('Maya', 46.21, 15.64, 89.91, 279, 6, '2025-04-20 08:08:47'),
('Paint 3D', 46.79, 46.76, 96.82, 280, 2, '2025-04-20 04:42:47'),
('Maya', 62.94, 11.22, 81.94, 281, 5, '2025-04-21 08:41:47'),
('Maya', 42.13, 26.05, 92.81, 282, 5, '2025-04-20 20:35:47'),
('Blender', 28.4, 45.21, 47.85, 283, 5, '2025-04-22 01:29:47'),
('Maya', 16.03, 57.48, 58.66, 284, 2, '2025-04-21 20:26:47'),
('Paint 3D', 80.5, 22.19, 61.27, 285, 2, '2025-04-22 16:28:47'),
('Blender', 74.62, 14.42, 75.55, 286, 4, '2025-04-23 08:47:47'),
('Paint 3D', 66.83, 11.44, 82.69, 287, 2, '2025-04-23 14:07:47'),
('Paint 3D', 91.3, 24.83, 62.71, 288, 4, '2025-04-23 21:07:47'),
('Maya', 20.7, 73.72, 70.88, 289, 6, '2025-04-24 13:15:47'),
('Blender', 11.7, 65.16, 60.64, 290, 6, '2025-04-25 12:12:47'),
('Maya', 14.0, 58.81, 67.47, 291, 4, '2025-04-26 06:58:47'),
('Blender', 43.21, 17.95, 71.63, 292, 3, '2025-04-26 12:30:47'),
('Maya', 77.9, 50.56, 79.27, 293, 4, '2025-04-26 18:41:47'),
('Paint 3D', 90.05, 44.38, 62.97, 294, 6, '2025-04-27 01:53:47'),
('Paint 3D', 55.79, 28.05, 55.89, 295, 2, '2025-04-28 08:20:47'),
('Blender', 39.73, 55.47, 75.9, 296, 1, '2025-04-28 06:12:47'),
('Blender', 59.13, 75.14, 80.81, 297, 3, '2025-04-29 05:09:47'),
('Blender', 11.65, 36.78, 49.87, 298, 1, '2025-04-29 09:00:47'),
('Maya', 68.54, 25.96, 77.29, 299, 4, '2025-04-30 03:26:47'),
('Paint 3D', 30.03, 67.47, 50.26, 300, 4, '2025-04-29 20:21:47'),
('Blender', 35.32, 86.8, 48.79, 301, 5, '2025-05-01 05:09:47'),
('Maya', 80.42, 38.31, 55.16, 302, 3, '2025-05-01 03:10:47'),
('Paint 3D', 61.93, 58.21, 92.49, 303, 6, '2025-05-01 18:55:47'),
('Blender', 22.13, 39.13, 59.58, 304, 2, '2025-05-01 18:47:47'),
('Maya', 40.65, 39.07, 93.37, 305, 1, '2025-05-03 09:46:47'),
('Maya', 50.63, 36.21, 79.9, 306, 6, '2025-05-02 19:03:47'),
('Blender', 55.9, 85.52, 49.11, 307, 2, '2025-05-03 20:59:47'),
('Blender', 37.55, 43.0, 82.08, 308, 4, '2025-05-03 14:58:47'),
('Paint 3D', 69.22, 78.45, 94.3, 309, 5, '2025-05-05 07:56:47'),
('Paint 3D', 51.78, 89.01, 93.39, 310, 4, '2025-05-04 20:16:47'),
('Paint 3D', 84.68, 58.57, 49.05, 311, 1, '2025-05-05 21:04:47'),
('Paint 3D', 48.31, 8.38, 75.27, 312, 2, '2025-05-05 15:19:47'),
('Paint 3D', 75.93, 56.76, 90.84, 313, 6, '2025-05-06 18:06:47'),
('Paint 3D', 72.31, 44.7, 91.53, 314, 5, '2025-05-06 14:28:47'),
('Blender', 48.43, 64.92, 93.11, 315, 2, '2025-05-08 10:57:47'),
('Paint 3D', 29.1, 44.88, 48.31, 316, 5, '2025-05-08 12:02:47'),
('Maya', 47.03, 44.79, 97.57, 317, 1, '2025-05-08 23:46:47'),
('Blender', 23.99, 76.46, 79.63, 318, 2, '2025-05-09 03:07:47'),
('Blender', 30.98, 13.87, 78.83, 319, 2, '2025-05-10 02:29:47'),
('Paint 3D', 72.14, 60.7, 46.55, 320, 6, '2025-05-09 15:25:47'),
('Paint 3D', 56.53, 74.87, 50.58, 321, 4, '2025-05-11 03:34:47'),
('Maya', 72.39, 7.97, 70.51, 322, 6, '2025-05-11 08:07:47'),
('Maya', 78.58, 21.1, 63.21, 323, 4, '2025-05-11 13:33:47'),
('Paint 3D', 47.39, 52.87, 47.22, 324, 4, '2025-05-12 01:51:47'),
('Paint 3D', 92.05, 7.68, 52.95, 325, 6, '2025-05-13 11:24:47'),
('Paint 3D', 38.06, 62.23, 50.31, 326, 3, '2025-05-12 15:55:47'),
('Maya', 26.69, 78.0, 49.23, 327, 4, '2025-05-14 09:23:47'),
('Maya', 28.26, 41.58, 80.24, 328, 6, '2025-05-14 10:10:47'),
('Maya', 33.84, 42.07, 56.76, 329, 1, '2025-05-15 06:57:47'),
('Blender', 54.53, 77.02, 68.6, 330, 2, '2025-05-14 14:56:47'),
('Maya', 84.51, 83.93, 93.76, 331, 3, '2025-05-16 12:39:47'),
('Maya', 35.02, 8.56, 62.75, 332, 3, '2025-05-15 14:56:47'),
('Maya', 30.17, 45.84, 49.3, 333, 3, '2025-05-17 02:43:47'),
('Maya', 31.54, 11.23, 60.57, 334, 2, '2025-05-16 21:36:47'),
('Paint 3D', 17.54, 21.06, 49.26, 335, 5, '2025-05-17 17:49:47'),
('Blender', 68.47, 34.27, 55.83, 336, 6, '2025-05-17 15:25:47'),
('Maya', 46.55, 13.39, 53.38, 337, 4, '2025-05-18 14:56:47'),
('Paint 3D', 37.23, 15.22, 54.08, 338, 3, '2025-05-19 00:23:47'),
('Blender', 72.67, 87.43, 96.39, 339, 3, '2025-05-20 02:47:47'),
('Paint 3D', 29.66, 88.97, 72.01, 340, 5, '2025-05-19 19:23:47'),
('Maya', 40.82, 74.21, 85.87, 341, 5, '2025-05-21 12:38:47'),
('Paint 3D', 42.32, 17.04, 64.67, 342, 2, '2025-05-20 16:42:47'),
('Paint 3D', 68.05, 6.83, 51.7, 343, 6, '2025-05-22 01:15:47'),
('Maya', 77.52, 70.43, 75.61, 344, 6, '2025-05-21 21:28:47'),
('Blender', 90.02, 55.05, 71.94, 345, 2, '2025-05-22 19:54:47'),
('Paint 3D', 41.26, 77.54, 65.76, 346, 4, '2025-05-22 21:50:47'),
('Maya', 33.04, 28.9, 47.33, 347, 3, '2025-05-24 06:22:47'),
('Blender', 26.33, 71.44, 90.25, 348, 6, '2025-05-23 13:13:47'),
('Blender', 22.25, 28.95, 90.86, 349, 4, '2025-05-25 01:58:47'),
('Blender', 49.8, 16.68, 67.8, 350, 2, '2025-05-24 23:00:47'),
('Paint 3D', 45.49, 27.11, 52.82, 351, 5, '2025-05-26 10:37:47'),
('Maya', 69.79, 37.19, 69.99, 352, 2, '2025-05-25 22:37:47'),
('Blender', 24.83, 18.84, 74.87, 353, 5, '2025-05-26 21:08:47'),
('Paint 3D', 26.89, 55.93, 57.28, 354, 1, '2025-05-27 10:57:47'),
('Blender', 39.45, 71.48, 82.25, 355, 3, '2025-05-28 10:21:47'),
('Blender', 75.15, 29.74, 87.78, 356, 4, '2025-05-28 11:16:47'),
('Blender', 90.43, 32.34, 84.04, 357, 6, '2025-05-28 21:38:47'),
('Blender', 24.73, 38.82, 89.96, 358, 3, '2025-05-29 10:04:47'),
('Blender', 72.42, 71.07, 94.47, 359, 1, '2025-05-29 19:04:47'),
('Blender', 90.6, 76.41, 96.36, 360, 4, '2025-05-29 17:08:47');




-- SELECT * FROM (select @p:=1)parm, qtdAlertaRAM;
-- SELECT * FROM (SELECT @p := 1) parm, vw_alertas_ram_periodo;
-- select * from (select @p:=1)parm, vw_alertas_mensais_empresa;

-- select * from viewGetInformacoesAlertas where idEmpresa = 1 and DataHora >= date_sub(now(), interval 3 month);

-- CALL prDashboardConsumoSimples(DATE_SUB(NOW(), INTERVAL 6 MONTH), NOW(), 1);
-- CALL prDashboardKPIs(DATE_SUB(NOW(), INTERVAL 6 MONTH), NOW(), 1);

INSERT INTO Alerta (nivel, dataHora, valor, fkConfiguracaoMonitoramento) VALUES
(1, '2024-12-01 13:57:48', 89.35, 8),
(1, '2024-12-02 00:41:50', 44.68, 20),
(2, '2024-12-03 03:14:27', 52.97, 8),
(2, '2024-12-04 05:16:55', 42.38, 20),
(2, '2024-12-05 06:26:54', 37.84, 18),
(2, '2024-12-06 02:09:38', 64.08, 20),
(1, '2024-12-07 16:51:47', 80.67, 18),
(2, '2024-12-08 00:28:53', 33.11, 8),
(2, '2024-12-09 04:00:46', 34.82, 8),
(2, '2024-12-10 05:12:52', 38.31, 8),
(2, '2024-12-11 17:49:02', 81.41, 18),
(1, '2024-12-12 10:07:02', 70.76, 18),
(1, '2024-12-13 04:00:44', 87.88, 20),
(1, '2024-12-14 17:19:12', 38.99, 20),
(1, '2024-12-15 01:45:23', 86.85, 20),
(1, '2024-12-16 15:24:21', 48.13, 18),
(1, '2024-12-17 02:11:05', 47.47, 20),
(1, '2024-12-18 03:11:11', 40.25, 8),
(1, '2024-12-19 01:00:53', 56.62, 20),
(2, '2024-12-20 00:23:13', 81.5, 8),
(2, '2024-12-21 13:32:23', 34.79, 8),
(2, '2024-12-22 03:29:13', 42.4, 20),
(1, '2024-12-23 16:16:53', 85.46, 18),
(2, '2024-12-24 11:05:38', 70.29, 18),
(1, '2024-12-25 04:53:32', 61.28, 20),
(1, '2024-12-26 01:10:35', 69.65, 8),
(2, '2024-12-27 04:04:38', 57.64, 20),
(1, '2024-12-28 16:19:50', 41.84, 18),
(2, '2024-12-29 01:19:39', 71.36, 20),
(2, '2024-12-30 05:49:58', 33.46, 8),
(2, '2024-12-31 05:31:41', 39.1, 8),
(2, '2025-01-01 12:37:27', 48.93, 8),
(1, '2025-01-02 12:50:36', 55.56, 20),
(1, '2025-01-03 05:08:57', 35.42, 18),
(1, '2025-01-04 13:39:44', 40.91, 18),
(1, '2025-01-05 17:56:00', 83.26, 8),
(2, '2025-01-06 01:42:35', 84.01, 8),
(2, '2025-01-07 17:01:01', 39.98, 8),
(2, '2025-01-08 03:44:07', 45.33, 18),
(1, '2025-01-09 07:33:49', 62.19, 20),
(1, '2025-01-10 17:18:57', 67.24, 20),
(2, '2025-01-11 03:58:28', 35.23, 18),
(1, '2025-01-12 01:17:44', 77.47, 8),
(1, '2025-01-13 05:30:13', 32.96, 20),
(2, '2025-01-14 02:36:33', 63.45, 20),
(1, '2025-01-15 01:45:42', 76.77, 18),
(1, '2025-01-16 04:52:31', 76.43, 18),
(2, '2025-01-17 14:09:14', 58.83, 8),
(2, '2025-01-18 06:36:42', 67.72, 18),
(1, '2025-01-19 02:21:04', 54.7, 8),
(2, '2025-01-20 05:13:13', 85.39, 18),
(1, '2025-01-21 15:04:18', 87.34, 20),
(1, '2025-01-22 05:26:08', 68.86, 8),
(2, '2025-01-23 05:26:51', 85.86, 20),
(2, '2025-01-24 00:43:07', 83.34, 20),
(1, '2025-01-25 09:29:15', 37.25, 20),
(1, '2025-01-26 00:29:50', 83.45, 8),
(2, '2025-01-27 13:55:20', 77.98, 8),
(1, '2025-01-28 00:47:06', 49.19, 18),
(2, '2025-01-29 06:32:45', 34.73, 18),
(2, '2025-01-30 04:40:21', 84.67, 20),
(1, '2025-01-31 10:49:05', 30.52, 8),
(2, '2025-02-01 03:57:58', 47.57, 20),
(2, '2025-02-02 02:25:17', 62.51, 18),
(1, '2025-02-03 13:07:29', 84.7, 18),
(2, '2025-02-04 07:05:18', 31.43, 20),
(2, '2025-02-05 03:40:09', 53.98, 20),
(1, '2025-02-06 01:06:02', 59.95, 18),
(2, '2025-02-07 03:54:24', 63.24, 8),
(2, '2025-02-08 03:22:52', 58.83, 18),
(2, '2025-02-09 14:42:03', 40.25, 20),
(2, '2025-02-10 00:02:50', 56.03, 18),
(1, '2025-02-11 17:48:59', 48.58, 18),
(1, '2025-02-12 11:22:17', 70.4, 8),
(2, '2025-02-13 04:50:07', 87.87, 18),
(2, '2025-02-14 13:06:55', 43.19, 20),
(2, '2025-02-15 03:01:21', 32.12, 18),
(1, '2025-02-16 03:25:01', 49.27, 20),
(1, '2025-02-17 02:53:14', 64.61, 18),
(2, '2025-02-18 07:43:42', 60.2, 20),
(2, '2025-02-19 16:55:00', 59.38, 18),
(1, '2025-02-20 11:28:17', 31.46, 20),
(2, '2025-02-21 00:16:49', 32.85, 8),
(2, '2025-02-22 03:13:11', 63.84, 8),
(2, '2025-02-23 02:46:35', 88.24, 8),
(2, '2025-02-24 16:40:18', 64.22, 8),
(1, '2025-02-25 01:33:43', 87.66, 18),
(2, '2025-02-26 00:00:56', 63.97, 8),
(2, '2025-02-27 01:20:29', 55.09, 18),
(1, '2025-02-28 02:57:53', 63.79, 20),
(1, '2025-03-01 05:52:58', 43.14, 8),
(2, '2025-03-02 08:47:44', 67.75, 8),
(2, '2025-03-03 13:20:41', 45.23, 8),
(1, '2025-03-04 07:22:31', 30.41, 18),
(2, '2025-03-05 17:11:27', 74.73, 20),
(2, '2025-03-06 01:41:56', 60.54, 20),
(2, '2025-03-07 02:55:30', 53.35, 20),
(1, '2025-03-08 01:15:58', 46.92, 18),
(2, '2025-03-09 04:36:49', 56.73, 20),
(1, '2025-03-10 13:23:19', 46.29, 8),
(2, '2025-03-11 02:02:56', 73.75, 20),
(1, '2025-03-12 16:12:58', 59.55, 8),
(1, '2025-03-13 06:36:58', 66.75, 18),
(1, '2025-03-14 12:49:19', 75.66, 18),
(1, '2025-03-15 04:22:57', 36.3, 20),
(1, '2025-03-16 01:40:30', 40.78, 18),
(1, '2025-03-17 03:36:11', 81.58, 8),
(1, '2025-03-18 04:34:49', 68.94, 18),
(1, '2025-03-19 04:06:58', 44.53, 8),
(2, '2025-03-20 03:30:30', 88.99, 18),
(1, '2025-03-21 04:24:28', 71.47, 20),
(1, '2025-03-22 11:50:22', 35.93, 20),
(2, '2025-03-23 12:27:04', 46.33, 18),
(2, '2025-03-24 10:00:36', 64.6, 20),
(2, '2025-03-25 00:14:51', 52.65, 20),
(2, '2025-03-26 01:32:40', 46.25, 20),
(1, '2025-03-27 15:52:25', 76.15, 18),
(1, '2025-03-28 05:04:49', 46.04, 20),
(2, '2025-03-29 11:55:57', 48.44, 8),
(2, '2025-03-30 05:26:25', 67.39, 8),
(2, '2025-03-31 02:40:44', 71.98, 8),
(2, '2025-04-01 01:07:03', 66.29, 18),
(2, '2025-04-02 04:52:41', 36.94, 20),
(1, '2025-04-03 14:09:18', 76.45, 18),
(1, '2025-04-04 04:15:05', 48.83, 20),
(1, '2025-04-05 02:26:32', 69.0, 20),
(2, '2025-04-06 10:42:48', 76.74, 20),
(1, '2025-04-07 00:11:56', 51.93, 20),
(2, '2025-04-08 14:59:44', 60.22, 8),
(1, '2025-04-09 07:43:32', 85.8, 8),
(1, '2025-04-10 04:50:20', 81.35, 18),
(2, '2025-04-11 04:33:30', 79.7, 20),
(1, '2025-04-12 01:19:40', 47.34, 8),
(2, '2025-04-13 04:06:13', 70.78, 20),
(2, '2025-04-14 03:12:15', 69.95, 8),
(1, '2025-04-15 04:43:57', 48.38, 18),
(1, '2025-04-16 05:46:08', 88.01, 18),
(2, '2025-04-17 07:48:05', 81.62, 8),
(2, '2025-04-18 14:04:04', 70.19, 20),
(2, '2025-04-19 13:46:43', 84.68, 8),
(1, '2025-04-20 01:30:43', 47.99, 8),
(2, '2025-04-21 15:25:59', 66.81, 18),
(2, '2025-04-22 13:46:56', 64.59, 20),
(1, '2025-04-23 05:21:26', 62.54, 20),
(2, '2025-04-24 03:02:22', 65.34, 20),
(2, '2025-04-25 04:54:14', 42.5, 20),
(2, '2025-04-26 07:14:18', 65.81, 20),
(2, '2025-04-27 01:17:50', 53.47, 18),
(1, '2025-04-28 00:30:49', 82.5, 20),
(1, '2025-04-29 01:03:20', 35.94, 20),
(1, '2025-04-30 00:26:05', 57.16, 20),
(1, '2025-05-01 08:37:38', 70.66, 18),
(1, '2025-05-02 00:01:10', 51.63, 8),
(1, '2025-05-03 01:52:21', 62.29, 18),
(1, '2025-05-04 12:42:49', 30.67, 18),
(2, '2025-05-05 03:39:45', 52.91, 20),
(1, '2025-05-06 00:33:40', 61.01, 20),
(2, '2025-05-07 05:15:14', 60.01, 8),
(2, '2025-05-08 01:42:37', 74.38, 18),
(1, '2025-05-09 11:37:47', 74.1, 20),
(1, '2025-05-10 04:35:52', 30.96, 18),
(1, '2025-05-11 08:19:32', 51.97, 20),
(1, '2025-05-12 06:11:27', 60.61, 20),
(1, '2025-05-13 03:57:31', 58.66, 20),
(1, '2025-05-14 05:40:32', 50.38, 18),
(2, '2025-05-15 02:17:27', 52.65, 18),
(1, '2025-05-16 04:34:36', 79.64, 18),
(2, '2025-05-17 14:36:26', 39.25, 8),
(1, '2025-05-18 03:32:23', 64.0, 18),
(2, '2025-05-19 01:12:14', 53.97, 18),
(2, '2025-05-20 06:05:31', 33.43, 18),
(1, '2025-05-21 15:52:37', 87.94, 18),
(1, '2025-05-22 02:33:53', 69.51, 8),
(1, '2025-05-23 17:25:25', 35.22, 18),
(1, '2025-05-24 05:12:37', 60.32, 8),
(2, '2025-05-25 08:37:51', 35.7, 8),
(1, '2025-05-26 00:28:00', 71.8, 18),
(2, '2025-05-27 02:41:51', 49.35, 18),
(2, '2025-05-28 15:26:53', 72.14, 18),
(2, '2025-05-29 05:42:03', 67.95, 18);


INSERT INTO Processo (nomeProcesso, usoCpu, usoGpu, usoRam, fkAlerta, fkServidor, dataHora) VALUES
('Disco', 22.05, 58.15, 49.1, 349, 1, '2024-05-29 00:00:00'),
('RAM', 46.9, 19.28, 82.62, 350, 1, '2024-05-30 00:00:00'),
('Disco', 80.73, 57.91, 81.64, 351, 1, '2024-05-31 00:00:00'),
('Disco', 87.75, 29.07, 76.77, 352, 1, '2024-06-01 00:00:00'),
('Disco', 52.3, 4.97, 86.75, 353, 1, '2024-06-02 00:00:00'),
('Disco', 51.37, 45.67, 55.42, 354, 1, '2024-06-03 00:00:00'),
('Disco', 12.78, 96.16, 55.16, 355, 1, '2024-06-04 00:00:00'),
('Disco', 4.75, 63.37, 59.28, 356, 1, '2024-06-05 00:00:00'),
('Disco', 90.43, 34.38, 66.49, 357, 1, '2024-06-06 00:00:00'),
('RAM', 82.67, 48.96, 41.82, 358, 1, '2024-06-07 00:00:00'),
('RAM', 86.32, 92.88, 87.66, 359, 1, '2024-06-08 00:00:00'),
('RAM', 72.93, 90.29, 94.6, 360, 1, '2024-06-09 00:00:00'),
('Disco', 32.88, 73.83, 59.73, 361, 1, '2024-06-10 00:00:00'),
('Disco', 9.68, 63.46, 38.32, 362, 1, '2024-06-11 00:00:00'),
('RAM', 19.75, 11.76, 53.81, 363, 1, '2024-06-12 00:00:00'),
('Disco', 33.65, 59.92, 37.98, 364, 1, '2024-06-13 00:00:00'),
('Disco', 28.53, 35.09, 51.39, 365, 1, '2024-06-14 00:00:00'),
('Disco', 60.52, 92.54, 62.68, 366, 1, '2024-06-15 00:00:00'),
('RAM', 15.41, 89.26, 56.25, 367, 1, '2024-06-16 00:00:00'),
('Disco', 82.1, 83.51, 86.81, 368, 1, '2024-06-17 00:00:00'),
('RAM', 2.13, 47.02, 38.62, 369, 1, '2024-06-18 00:00:00'),
('Disco', 6.76, 53.88, 48.3, 370, 1, '2024-06-19 00:00:00'),
('Disco', 37.35, 66.96, 84.33, 371, 1, '2024-06-20 00:00:00'),
('Disco', 56.28, 1.6, 44.11, 372, 1, '2024-06-21 00:00:00'),
('RAM', 67.75, 10.29, 80.42, 373, 1, '2024-06-22 00:00:00'),
('RAM', 41.11, 70.29, 95.87, 374, 1, '2024-06-23 00:00:00'),
('Disco', 40.65, 38.25, 66.59, 375, 1, '2024-06-24 00:00:00'),
('RAM', 48.08, 74.56, 87.02, 376, 1, '2024-06-25 00:00:00'),
('RAM', 50.5, 48.57, 41.32, 377, 1, '2024-06-26 00:00:00'),
('RAM', 31.89, 20.25, 87.56, 378, 1, '2024-06-27 00:00:00'),
('Disco', 87.85, 33.54, 64.68, 379, 1, '2024-06-28 00:00:00'),
('RAM', 91.26, 97.98, 74.63, 380, 1, '2024-06-29 00:00:00'),
('RAM', 91.21, 69.78, 35.08, 381, 1, '2024-06-30 00:00:00'),
('RAM', 17.41, 20.67, 78.16, 382, 1, '2024-07-01 00:00:00'),
('RAM', 37.94, 27.37, 63.12, 383, 1, '2024-07-02 00:00:00'),
('RAM', 3.64, 88.08, 89.13, 384, 1, '2024-07-03 00:00:00'),
('RAM', 45.69, 41.31, 93.19, 385, 1, '2024-07-04 00:00:00'),
('RAM', 53.54, 66.49, 80.2, 386, 1, '2024-07-05 00:00:00'),
('RAM', 90.27, 63.41, 78.1, 387, 1, '2024-07-06 00:00:00'),
('Disco', 12.13, 87.1, 64.62, 388, 1, '2024-07-07 00:00:00'),
('RAM', 43.08, 66.63, 71.48, 389, 1, '2024-07-08 00:00:00'),
('RAM', 57.26, 73.5, 40.19, 390, 1, '2024-07-09 00:00:00'),
('Disco', 48.71, 21.19, 74.41, 391, 1, '2024-07-10 00:00:00'),
('RAM', 95.92, 66.29, 41.88, 392, 1, '2024-07-11 00:00:00'),
('Disco', 16.95, 32.29, 59.02, 393, 1, '2024-07-12 00:00:00'),
('Disco', 86.98, 24.76, 42.65, 394, 1, '2024-07-13 00:00:00'),
('RAM', 37.67, 96.36, 46.42, 395, 1, '2024-07-14 00:00:00'),
('RAM', 11.67, 12.59, 96.78, 396, 1, '2024-07-15 00:00:00'),
('Disco', 53.01, 46.95, 80.15, 397, 1, '2024-07-16 00:00:00'),
('RAM', 60.03, 43.57, 91.18, 398, 1, '2024-07-17 00:00:00'),
('Disco', 16.11, 98.52, 89.05, 399, 1, '2024-07-18 00:00:00'),
('Disco', 76.7, 80.75, 81.34, 400, 1, '2024-07-19 00:00:00'),
('RAM', 78.29, 75.22, 62.75, 401, 1, '2024-07-20 00:00:00'),
('Disco', 14.6, 42.11, 73.57, 402, 1, '2024-07-21 00:00:00'),
('Disco', 80.15, 49.28, 65.74, 403, 1, '2024-07-22 00:00:00'),
('Disco', 29.26, 43.63, 55.18, 404, 1, '2024-07-23 00:00:00'),
('RAM', 31.93, 59.27, 58.37, 405, 1, '2024-07-24 00:00:00'),
('RAM', 12.0, 3.16, 82.72, 406, 1, '2024-07-25 00:00:00'),
('RAM', 11.05, 41.16, 54.08, 407, 1, '2024-07-26 00:00:00'),
('RAM', 34.15, 34.4, 60.14, 408, 1, '2024-07-27 00:00:00'),
('RAM', 10.51, 38.2, 45.29, 409, 1, '2024-07-28 00:00:00'),
('RAM', 11.4, 32.68, 69.23, 410, 1, '2024-07-29 00:00:00'),
('RAM', 5.26, 61.26, 60.4, 411, 1, '2024-07-30 00:00:00'),
('RAM', 72.67, 46.68, 92.35, 412, 1, '2024-07-31 00:00:00'),
('Disco', 68.65, 75.57, 80.86, 413, 1, '2024-08-01 00:00:00'),
('RAM', 50.76, 23.19, 62.26, 414, 1, '2024-08-02 00:00:00'),
('RAM', 18.37, 43.24, 32.27, 415, 1, '2024-08-03 00:00:00'),
('RAM', 42.67, 26.89, 35.43, 416, 1, '2024-08-04 00:00:00'),
('Disco', 68.26, 30.57, 58.3, 417, 1, '2024-08-05 00:00:00'),
('RAM', 18.6, 32.03, 57.75, 418, 1, '2024-08-06 00:00:00'),
('RAM', 3.96, 56.52, 91.21, 419, 1, '2024-08-07 00:00:00'),
('Disco', 84.48, 12.04, 46.39, 420, 1, '2024-08-08 00:00:00'),
('Disco', 5.37, 62.73, 30.5, 421, 1, '2024-08-09 00:00:00'),
('RAM', 67.67, 4.51, 81.13, 422, 1, '2024-08-10 00:00:00'),
('Disco', 90.22, 13.57, 51.16, 423, 1, '2024-08-11 00:00:00'),
('Disco', 10.13, 84.65, 32.08, 424, 1, '2024-08-12 00:00:00'),
('RAM', 84.9, 88.67, 70.31, 425, 1, '2024-08-13 00:00:00'),
('Disco', 6.78, 25.63, 79.64, 426, 1, '2024-08-14 00:00:00'),
('Disco', 23.75, 18.07, 68.6, 427, 1, '2024-08-15 00:00:00'),
('Disco', 9.94, 89.97, 67.37, 428, 1, '2024-08-16 00:00:00'),
('Disco', 97.81, 1.72, 81.1, 429, 1, '2024-08-17 00:00:00'),
('Disco', 29.37, 92.78, 50.91, 430, 1, '2024-08-18 00:00:00'),
('Disco', 62.64, 97.87, 54.23, 431, 1, '2024-08-19 00:00:00'),
('RAM', 88.23, 79.65, 80.68, 432, 1, '2024-08-20 00:00:00'),
('Disco', 9.07, 94.39, 83.36, 433, 1, '2024-08-21 00:00:00'),
('RAM', 16.35, 95.25, 70.52, 434, 1, '2024-08-22 00:00:00'),
('RAM', 24.6, 0.01, 67.07, 435, 1, '2024-08-23 00:00:00'),
('Disco', 77.78, 18.89, 39.92, 436, 1, '2024-08-24 00:00:00'),
('Disco', 99.46, 8.82, 57.94, 437, 1, '2024-08-25 00:00:00'),
('Disco', 14.72, 82.42, 52.81, 438, 1, '2024-08-26 00:00:00'),
('RAM', 43.09, 89.17, 39.6, 439, 1, '2024-08-27 00:00:00'),
('RAM', 26.28, 86.55, 83.5, 440, 1, '2024-08-28 00:00:00'),
('Disco', 53.16, 64.02, 69.57, 441, 1, '2024-08-29 00:00:00'),
('Disco', 56.34, 96.61, 78.94, 442, 1, '2024-08-30 00:00:00'),
('RAM', 49.48, 47.33, 76.39, 443, 1, '2024-08-31 00:00:00'),
('RAM', 95.5, 91.3, 88.07, 444, 1, '2024-09-01 00:00:00'),
('RAM', 79.31, 87.31, 44.63, 445, 1, '2024-09-02 00:00:00'),
('RAM', 79.76, 52.33, 58.72, 446, 1, '2024-09-03 00:00:00'),
('Disco', 88.89, 71.59, 87.94, 447, 1, '2024-09-04 00:00:00'),
('Disco', 3.01, 95.44, 37.75, 448, 1, '2024-09-05 00:00:00'),
('RAM', 0.99, 29.91, 91.81, 449, 1, '2024-09-06 00:00:00'),
('RAM', 79.42, 78.31, 68.45, 450, 1, '2024-09-07 00:00:00'),
('RAM', 94.68, 57.56, 79.49, 451, 1, '2024-09-08 00:00:00'),
('RAM', 92.77, 63.52, 34.51, 452, 1, '2024-09-09 00:00:00'),
('Disco', 32.71, 0.35, 30.23, 453, 1, '2024-09-10 00:00:00'),
('Disco', 67.02, 55.26, 47.01, 454, 1, '2024-09-11 00:00:00'),
('RAM', 65.78, 86.23, 84.25, 455, 1, '2024-09-12 00:00:00'),
('Disco', 59.82, 19.48, 35.13, 456, 1, '2024-09-13 00:00:00'),
('Disco', 15.17, 88.55, 37.67, 457, 1, '2024-09-14 00:00:00'),
('Disco', 30.7, 4.63, 58.29, 458, 1, '2024-09-15 00:00:00'),
('Disco', 88.48, 44.71, 65.36, 459, 1, '2024-09-16 00:00:00'),
('Disco', 75.89, 56.45, 86.54, 460, 1, '2024-09-17 00:00:00'),
('RAM', 69.01, 38.2, 39.29, 461, 1, '2024-09-18 00:00:00'),
('RAM', 50.8, 35.89, 76.28, 462, 1, '2024-09-19 00:00:00'),
('Disco', 85.92, 48.33, 77.09, 463, 1, '2024-09-20 00:00:00'),
('RAM', 56.59, 94.06, 60.34, 464, 1, '2024-09-21 00:00:00'),
('RAM', 89.02, 65.88, 97.77, 465, 1, '2024-09-22 00:00:00'),
('Disco', 60.68, 95.14, 31.29, 466, 1, '2024-09-23 00:00:00'),
('RAM', 83.12, 31.43, 57.65, 467, 1, '2024-09-24 00:00:00'),
('RAM', 57.79, 78.82, 51.51, 468, 1, '2024-09-25 00:00:00'),
('RAM', 7.33, 57.98, 77.23, 469, 1, '2024-09-26 00:00:00'),
('Disco', 57.4, 19.62, 41.23, 470, 1, '2024-09-27 00:00:00'),
('RAM', 34.28, 54.53, 87.1, 471, 1, '2024-09-28 00:00:00'),
('RAM', 86.24, 39.04, 65.04, 472, 1, '2024-09-29 00:00:00'),
('Disco', 43.55, 27.88, 39.59, 473, 1, '2024-09-30 00:00:00'),
('Disco', 94.28, 0.05, 78.64, 474, 1, '2024-10-01 00:00:00'),
('RAM', 92.27, 17.42, 65.92, 475, 1, '2024-10-02 00:00:00'),
('Disco', 15.32, 44.11, 54.45, 476, 1, '2024-10-03 00:00:00'),
('Disco', 46.71, 59.81, 72.83, 477, 1, '2024-10-04 00:00:00'),
('Disco', 39.21, 31.26, 38.58, 478, 1, '2024-10-05 00:00:00'),
('RAM', 0.62, 25.48, 85.48, 479, 1, '2024-10-06 00:00:00'),
('Disco', 65.23, 25.82, 54.75, 480, 1, '2024-10-07 00:00:00'),
('RAM', 64.13, 30.45, 36.92, 481, 1, '2024-10-08 00:00:00'),
('Disco', 61.65, 48.4, 69.13, 482, 1, '2024-10-09 00:00:00'),
('Disco', 41.64, 49.35, 55.16, 483, 1, '2024-10-10 00:00:00'),
('RAM', 9.5, 33.51, 92.66, 484, 1, '2024-10-11 00:00:00'),
('Disco', 9.05, 23.28, 76.36, 485, 1, '2024-10-12 00:00:00'),
('RAM', 82.87, 70.23, 31.0, 486, 1, '2024-10-13 00:00:00'),
('RAM', 56.07, 49.26, 75.25, 487, 1, '2024-10-14 00:00:00'),
('RAM', 12.91, 59.85, 77.86, 488, 1, '2024-10-15 00:00:00'),
('RAM', 49.63, 37.84, 66.07, 489, 1, '2024-10-16 00:00:00'),
('Disco', 42.01, 37.53, 85.24, 490, 1, '2024-10-17 00:00:00'),
('Disco', 78.1, 82.3, 39.93, 491, 1, '2024-10-18 00:00:00'),
('RAM', 62.59, 39.68, 58.13, 492, 1, '2024-10-19 00:00:00'),
('Disco', 92.84, 44.42, 42.42, 493, 1, '2024-10-20 00:00:00'),
('RAM', 27.92, 54.89, 31.37, 494, 1, '2024-10-21 00:00:00'),
('Disco', 16.77, 23.54, 59.0, 495, 1, '2024-10-22 00:00:00'),
('Disco', 29.36, 44.43, 65.64, 496, 1, '2024-10-23 00:00:00'),
('RAM', 77.07, 73.95, 70.6, 497, 1, '2024-10-24 00:00:00'),
('Disco', 28.18, 12.7, 87.5, 498, 1, '2024-10-25 00:00:00'),
('RAM', 67.36, 10.58, 80.73, 499, 1, '2024-10-26 00:00:00'),
('RAM', 64.15, 62.28, 56.59, 500, 1, '2024-10-27 00:00:00'),
('Disco', 77.68, 81.31, 55.08, 501, 1, '2024-10-28 00:00:00'),
('Disco', 42.75, 1.36, 52.58, 502, 1, '2024-10-29 00:00:00'),
('RAM', 57.92, 71.53, 53.47, 503, 1, '2024-10-30 00:00:00'),
('Disco', 54.96, 3.52, 39.12, 504, 1, '2024-10-31 00:00:00'),
('Disco', 14.5, 97.6, 38.29, 505, 1, '2024-11-01 00:00:00'),
('RAM', 87.46, 7.67, 83.86, 506, 1, '2024-11-02 00:00:00'),
('RAM', 16.11, 66.19, 92.88, 507, 1, '2024-11-03 00:00:00'),
('RAM', 81.0, 21.4, 72.14, 508, 1, '2024-11-04 00:00:00'),
('Disco', 76.67, 18.79, 80.61, 509, 1, '2024-11-05 00:00:00'),
('Disco', 71.37, 80.54, 84.85, 510, 1, '2024-11-06 00:00:00'),
('RAM', 0.24, 10.03, 31.2, 511, 1, '2024-11-07 00:00:00'),
('RAM', 46.98, 40.74, 41.19, 512, 1, '2024-11-08 00:00:00'),
('RAM', 75.3, 12.07, 37.29, 513, 1, '2024-11-09 00:00:00'),
('Disco', 41.64, 87.69, 65.95, 514, 1, '2024-11-10 00:00:00'),
('Disco', 9.08, 81.09, 39.67, 515, 1, '2024-11-11 00:00:00'),
('Disco', 39.94, 58.1, 84.44, 516, 1, '2024-11-12 00:00:00'),
('RAM', 48.87, 75.01, 97.15, 517, 1, '2024-11-13 00:00:00'),
('RAM', 69.96, 8.25, 93.96, 518, 1, '2024-11-14 00:00:00'),
('Disco', 60.73, 16.93, 30.79, 519, 1, '2024-11-15 00:00:00'),
('Disco', 93.25, 42.35, 81.99, 520, 1, '2024-11-16 00:00:00'),
('RAM', 30.22, 67.15, 84.01, 521, 1, '2024-11-17 00:00:00'),
('Disco', 93.77, 60.71, 41.73, 522, 1, '2024-11-18 00:00:00'),
('RAM', 91.88, 45.26, 49.74, 523, 1, '2024-11-19 00:00:00'),
('RAM', 52.65, 19.37, 75.26, 524, 1, '2024-11-20 00:00:00'),
('RAM', 51.1, 4.04, 91.66, 525, 1, '2024-11-21 00:00:00'),
('Disco', 52.18, 14.78, 75.42, 526, 1, '2024-11-22 00:00:00'),
('Disco', 90.4, 28.94, 32.28, 527, 1, '2024-11-23 00:00:00'),
('RAM', 61.83, 78.55, 85.63, 528, 1, '2024-11-24 00:00:00'),
('Disco', 68.21, 80.03, 38.22, 529, 1, '2024-11-25 00:00:00'),
('Disco', 32.48, 8.25, 45.23, 530, 1, '2024-11-26 00:00:00'),
('Disco', 14.32, 56.71, 85.16, 531, 1, '2024-11-27 00:00:00'),
('Disco', 68.57, 49.74, 67.77, 532, 1, '2024-11-28 00:00:00'),
('Disco', 48.69, 74.34, 37.43, 533, 1, '2024-11-29 00:00:00'),
('RAM', 59.98, 95.64, 41.54, 534, 1, '2024-11-30 00:00:00'),
('RAM', 19.89, 0.73, 62.1, 535, 1, '2024-12-01 00:00:00');





