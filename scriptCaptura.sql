DROP DATABASE IF EXISTS Captura;
CREATE DATABASE IF NOT EXISTS Captura;
USE Captura;


CREATE TABLE IF NOT EXISTS Captura(
    idCaptura INT PRIMARY KEY AUTO_INCREMENT,
    dadoCaptura FLOAT NOT NULL,
    dataHora DATETIME NOT NULL DEFAULT now(),
    fkConfiguracaoMonitoramento INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Alerta(
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    nivel TINYINT NOT NULL, -- 1: Atenção, 2: Crítico
    dataHora DATETIME NOT NULL DEFAULT now(),
    valor FLOAT NOT NULL,
    fkConfiguracaoMonitoramento INT NOT NULL,
    CONSTRAINT chkNivelAlerta CHECK (nivel IN (1, 2))
);

CREATE TABLE IF NOT EXISTS Processo(
	idProcesso INT PRIMARY KEY AUTO_INCREMENT,
    nomeProcesso VARCHAR(45) NOT NULL,
    usoCpu FLOAT NOT NULL,
    usoGpu FLOAT NOT NULL,
    usoRam FLOAT NOT NULL,
    fkServidor INT NOT NULL,
    dataHora DATETIME NOT NULL
);