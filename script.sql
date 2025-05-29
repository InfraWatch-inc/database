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
    fkServidor INT NOT NULL,
    dataHora DATETIME NOT NULL,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
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
('André Muller', 'andre.muller@email.com', '23456789012', 'CPF', 'senha456', 1, 'Analista de Dados', 2, 1);

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

-- Ranier Windows
(2, 'CPU', 'Intel', 1, 'i5-9700K'), -- 4
(2, 'RAM', 'Husky', 1, 'DDR4 16GB'), -- 5
(2, 'HD', 'Adata', 1, 'SSD 500 GB'), -- 6
(2, 'GPU', 'NVIDIA', 1, 'GTX 1050'), -- 7

-- Kaio
(3, 'CPU', 'Intel', 1, 'Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz'), -- 8
(3, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 9
(3, 'HD', 'Adata', 1, 'KINGSTON RBUSNS8154P3512GJ1'), -- 10
(3, 'GPU', 'NVIDIA', 1, 'GeForce MX250'), -- 11

-- Miguel
(4, 'CPU', 'Intel', 1, 'i5-1235U'), -- 12
(4, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 13
(4, 'HD', 'Adata', 1, 'SSD 500 GB'), -- 14

-- Ranier Linux
(5, 'CPU', 'Intel', 1, 'i5-1235U'), -- 15
(5, 'RAM', 'Adata', 1, 'DDR4 16GB'), -- 16
(5, 'HD', 'Adata', 1, 'SSD 512GB'), -- 17

-- Vitória
(6, 'CPU', 'Intel', 1, 'i7-3537U'), -- 18
(6, 'RAM', 'Adata', 1, 'DDR3 12GB'), -- 19
(6, 'HD', 'KINGSTON', 1, 'SSD 500GB'); -- 20



INSERT INTO ConfiguracaoMonitoramento (unidadeMedida, descricao, fkComponente, limiteAtencao, limiteCritico, funcaoPython) VALUES
-- Grigor
('%', 'Uso', 11, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('MHz', 'Frequência', 11, 2000.0, 4000.0, 'psutil.cpu_freq().current'), -- Uso MHz CPU
('%', 'Uso', 12, 75.0, 90.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('Byte', 'Uso Byte', 12, 8000000000, 16000000000, 'psutil.virtual_memory().used'), -- Uso Byte RAM
('%', 'Uso Porcentagem', 13, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('Byte', 'Uso Byte', 13, 500000000000, 1000000000000, 'psutil.disk_usage("/").used'), -- Uso Byte HD

-- Ranier Windows
('%', 'Uso Porcentagem', 4, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem', 6, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('%', 'Uso Porcentagem', 7, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'), -- Uso % GPU
('ºC', 'Temperatura', 7, 60.0, 90.0, 'GPUtil.getGPUs()[numeracao -1].temperature'), -- Temp GPU
('%', 'Uso Porcentagem', 5, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM

-- Kaio
('%', 'Uso Porcentagem', 8, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU	
('%', 'Uso Porcentagem', 10, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('%', 'Uso Porcentagem', 11, 70.0, 90.0, 'round(GPUtil.getGPUs()[numeracao - 1].load * 100, 2)'), -- Uso % GPU
('%', 'Uso Porcentagem', 9, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM


-- Miguel
('%', 'Uso Porcentagem', 11, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem',12, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('%', 'Uso Porcentagem',13, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD


-- Ranier Linux
('%', 'Uso Porcentagem', 4, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem', 6, 85.0, 95.0, 'psutil.disk_usage("/").percent'), -- Uso % HD
('ºC', 'Temperatura', 7, 60.0, 90.0, 'psutil.sensors_temperatures().get("coretemp", [])[numeracao - 1].current'), -- Temp CPU
('%', 'Uso Porcentagem', 5, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM

-- Vitoria
('%', 'Uso Porcentagem', 18, 80.0, 95.0, 'psutil.cpu_percent()'), -- Uso % CPU
('%', 'Uso Porcentagem',19, 80.0, 95.0, 'psutil.virtual_memory().percent'), -- Uso % RAM
('%', 'Uso Porcentagem',20, 85.0, 95.0, 'psutil.disk_usage("/").percent'); -- Uso % HD

#---------------VIEWS SISTEMA---------------------
-- CREATE OR REPLACE VIEW `viewPrimeiroInsights` AS
-- SELECT  idEmpresa,
--         Alerta.dataHora,

--         SUM(CASE WHEN c.componente = 'CPU' THEN 1 ELSE 0 END) AS qtdAlertasCpu,
-- 		SUM(CASE WHEN c.componente = 'GPU' THEN 1 ELSE 0 END) AS qtdAlertasGpu,
-- 		SUM(CASE WHEN c.componente = 'RAM' THEN 1 ELSE 0 END) AS qtdAlertasRam,
-- 		SUM(CASE WHEN c.componente = 'DISCO' THEN 1 ELSE 0 END) AS qtdAlertasDisco,

--         SUM(CASE WHEN c.componente = 'CPU' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdAlertasCpuAtencao,
--         SUM(CASE WHEN c.componente = 'GPU' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdAlertasGpuAtencao,
--         SUM(CASE WHEN c.componente = 'RAM' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdAlertasRamAtencao,
--         SUM(CASE WHEN c.componente = 'DISCO' AND Alerta.nivel = 1 THEN 1 ELSE 0 END) AS qtdAlertasDiscoAtencao,

--         SUM(CASE WHEN c.componente = 'CPU' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdAlertasCpuCritico,
--         SUM(CASE WHEN c.componente = 'GPU' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdAlertasGpuCritico,
--         SUM(CASE WHEN c.componente = 'RAM' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdAlertasRamCritico,
--         SUM(CASE WHEN c.componente = 'DISCO' AND Alerta.nivel = 2 THEN 1 ELSE 0 END) AS qtdAlertasDiscoCritico
-- FROM Alerta
-- JOIN ConfiguracaoMonitoramento ON fkConfiguracaoMonitoramento = idConfiguracaoMonitoramento
-- JOIN Componente as c ON idComponente = fkComponente
-- JOIN Servidor ON fkServidor = idServidor
-- JOIN Empresa ON fkEmpresa = idEmpresa
-- GROUP BY Alerta.dataHora, idEmpresa;

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
    WHEN HOUR(Alerta.dataHora) BETWEEN 6 AND 11 THEN 'Manhã'
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
CREATE PROCEDURE prDashboardProcessos(IN dataInicio DATETIME, IN dataFim DATETIME)
BEGIN
    DECLARE processoCritico VARCHAR(100);
    DECLARE processoAtencao VARCHAR(100);
    DECLARE componenteMaisUsado VARCHAR(50);
    DECLARE periodoAtivo VARCHAR(10);
    DECLARE alertasJson JSON;
    DECLARE consumoJson JSON;

    -- Processo com mais alertas críticos
    SELECT Processo.nome INTO processoCritico
    FROM Alerta
    JOIN Processo ON Alerta.fkProcesso = Processo.idProcesso
    WHERE Alerta.nivel = 2 AND Alerta.DataHora BETWEEN dataInicio AND dataFim
    GROUP BY Processo.nome
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- Processo com mais alertas moderados
    SELECT Processo.nome INTO processoAtencao
    FROM Alerta
    JOIN Processo ON Alerta.fkProcesso = Processo.idProcesso
    WHERE Alerta.nivel = 1 AND Alerta.DataHora BETWEEN dataInicio AND dataFim
    GROUP BY Processo.nome
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- Componente mais utilizado
    SELECT Componente.componente INTO componenteMaisUsado
    FROM Alerta
    JOIN ConfiguracaoMonitoramento ON fkConfiguracaoMonitoramento = idConfiguracaoMonitoramento
    JOIN Componente ON fkComponente = idComponente
    WHERE Componente.componente IN ('CPU', 'GPU', 'RAM') AND Alerta.DataHora BETWEEN dataInicio AND dataFim
    GROUP BY Componente.componente
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- Período mais ativo
    SELECT periodo INTO periodoAtivo FROM (
        SELECT
            CASE
                WHEN HOUR(DataHora) BETWEEN 6 AND 11 THEN 'Manhã'
                WHEN HOUR(DataHora) BETWEEN 12 AND 17 THEN 'Tarde'
                ELSE 'Noite'
            END AS periodo,
            COUNT(*) AS total
        FROM Alerta
        WHERE Alerta.DataHora BETWEEN dataInicio AND dataFim
        GROUP BY periodo
        ORDER BY total DESC
        LIMIT 1
    ) AS subquery;

    -- Alertas por processo e nível em JSON
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'nome', Processo.nome,
            'alertasCritico', SUM(CASE WHEN nivel = 2 THEN 1 ELSE 0 END),
            'alertasAtencao', SUM(CASE WHEN nivel = 1 THEN 1 ELSE 0 END)
        )
    ) INTO alertasJson
    FROM Alerta
    JOIN Processo ON Alerta.fkProcesso = Processo.idProcesso
    WHERE Alerta.DataHora BETWEEN dataInicio AND dataFim
    GROUP BY Processo.nome;

    -- Consumo por processo e por tipo em JSON
    SELECT JSON_OBJECTAGG(tipo, JSON_ARRAYAGG(
        JSON_OBJECT(
            'nome', nome,
            'capturaManha', manha,
            'capturaTarde', tarde,
            'capturaNoite', noite
        )
    )) INTO consumoJson
    FROM (
        SELECT 'cpu' AS tipo, nomeProcesso AS nome,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoCpu END), 0) AS manha,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoCpu END), 0) AS tarde,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoCpu END), 0) AS noite
        FROM Processo
        WHERE dataHora BETWEEN dataInicio AND dataFim
        GROUP BY nomeProcesso
        UNION ALL
        SELECT 'gpu', nomeProcesso,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoGpu END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoGpu END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoGpu END), 0)
        FROM Processo
        WHERE dataHora BETWEEN dataInicio AND dataFim
        GROUP BY nomeProcesso
        UNION ALL
        SELECT 'ram', nomeProcesso,
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 6 AND 11 THEN usoRam END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 12 AND 17 THEN usoRam END), 0),
            ROUND(AVG(CASE WHEN HOUR(dataHora) BETWEEN 18 AND 23 THEN usoRam END), 0)
        FROM Processo
        WHERE dataHora BETWEEN dataInicio AND dataFim
        GROUP BY nomeProcesso
    ) AS consumo;

    -- Resultado final: objeto JSON
    SELECT JSON_OBJECT(
        'processoMaisCritico', processoCritico,
        'processoMaisAtencao', processoAtencao,
        'componenteMaisConsumido', componenteMaisUsado,
        'periodoMaisAtivo', periodoAtivo,
        'dadosProcessosAlertas', alertasJson,
        'dadosProcessosConsumo', consumoJson
    ) AS resultadoDashboard;
END $$
DELIMITER ;