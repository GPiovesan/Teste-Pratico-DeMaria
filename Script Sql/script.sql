-- Database: "Piovesan"

DROP DATABASE "Piovesan";

CREATE DATABASE "Piovesan"
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'Portuguese_Brazil.1252'
       LC_CTYPE = 'Portuguese_Brazil.1252'
       CONNECTION LIMIT = -1;

CREATE TABLE IF NOT EXISTS tb_permissions(
	ID SERIAL PRIMARY KEY NOT NULL,
	DESCRICAO VARCHAR(30) NOT NULL,
	NIVEL INT NOT NULL					-- NIVEL DE ACESSO NO SISTEMA
);
INSERT INTO tb_permissions(DESCRICAO, NIVEL) VALUES('DEV','0'); -- PERMISSÕES DE DEV (GERAL)
INSERT INTO tb_permissions(DESCRICAO, NIVEL) VALUES('SINDICO','1'); -- TESTE PARA USUÁRIO COM ACESSO RESTRITO
INSERT INTO tb_permissions(DESCRICAO, NIVEL) VALUES('USER','2'); -- TESTE PARA USUÁRIO COM ACESSO RESTRITO

CREATE TABLE IF NOT EXISTS tb_users_config(
	ID SERIAL PRIMARY KEY NOT NULL,		-- ID DO MORADOR CADASTRADO (QUE SERÁ ACHADO BASEADO EM SEU CPF! CPF > ID > ID(USER_CONFIG))
	PASS VARCHAR(30) NOT NULL,			-- SENHA DE LOGIN (ACHAR UM MÉTODO SEGURO PARA ARMAZENAR SENHAS)
	ID_permissions INT NOT NULL,		-- QUAL O NIVEL DE PERMISSÃO NO SISTEMA
	FOREIGN KEY(ID_permissions) REFERENCES tb_permissions (ID)
);

CREATE TABLE IF NOT EXISTS tb_uf(
	ID SERIAL PRIMARY KEY NOT NULL,
	DESCRICAO VARCHAR(10),				-- PADRONIZAR OS ESTADOS PARA EVITAR A REPETIÇÃO
	UNIQUE(DESCRICAO)
);

INSERT INTO tb_uf (DESCRICAO)VALUES
('RO'),
('AC'),
('AM'),
('RR'),
('PA'),
('AP'),
('TO'),
('MA'),
('PI'),
('CE'),
('RN'),
('PB'),
('PE'),
('AL'),
('SE'),
('BA'),
('MG'),
('ES'),
('RJ'),
('SP'),
('PR'),
('SC'),
('RS'),
('MS'),
('MT'),
('GO'),
('DF');

CREATE TABLE IF NOT EXISTS tb_cidades(
	ID SERIAL PRIMARY KEY NOT NULL,
	DESCRICAO VARCHAR(10),
	UNIQUE(DESCRICAO)
)

CREATE TABLE IF NOT EXISTS tb_condominio (     -- REGISTRO DE DADOS DO CONDOMINIO
	ID SERIAL PRIMARY KEY NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	ID_uf INT NOT NULL,
	Cidade VARCHAR(50) NOT NULL,
	Rua VARCHAR(50) NOT NULL,
	Numero VARCHAR(50) NOT NULL,
	Capacidade INT NOT NULL,
	CNPJ VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	Telefone VARCHAR(20) NOT NULL,
	FOREIGN KEY(ID_uf) REFERENCES tb_uf(ID)
);
	
CREATE TABLE IF NOT EXISTS tb_condomino(       -- REGISTRO DOS CONDOMINOS
	ID SERIAL PRIMARY KEY NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Bloco VARCHAR(10) NOT NULL,
	Numero VARCHAR(10) NOT NULL,
	Complemento VARCHAR(50) NOT NULL,
	CPF VARCHAR(15) NOT NULL,		-- SERÁ UTILIZADO O CPF PARA REALIZAR LOGIN!
	RG VARCHAR(15) NOT NULL,
	Telefone VARCHAR(20) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	ID_Condominio INT NOT NULL,
	ID_User_Config INT NOT NULL,
	FOREIGN KEY(ID_Condominio) REFERENCES tb_condominio (ID),
	FOREIGN KEY(ID_User_Config) REFERENCES tb_users_config(ID)
);
--INSERT INTO tb_condomino(Nome, Bloco, Numero, Complemento, CPF, RG, Telefone, Email, ID_condominio)
--VALUES ('Gabriel Piovesan de Luna Cabrera', '1','10','5° Andar', '462.986.768-64', '38.142.721-3', '(12)98107-6884', 'bieldeluna@gmail.com', 9);

CREATE TABLE IF NOT EXISTS tb_asmb_config(	-- CONFIGURAÇÕES GERAIS DA ASSEMBLEIA
	Data_Asmb DATE NOT NULL,		-- A DATA QUE IRÁ SER ABERTA AS VOTAÇÕES
	Horario VARCHAR(10) NOT NULL,	
	Nome_representante VARCHAR(50) NOT NULL, -- NOME DO REPRESENTANTE DA ASSEMBLEIA? TOPICO?
	Notificacao_Ativa BOOLEAN NOT NULL, 		-- DISPARAR NOTIFICAÇÃO NOS CELULARES DOS CONDOMINOS?
	Notificacao_Detalhes VARCHAR(50) NOT NULL	-- DESCRIÇÃO PARA APARECER NA NOTIFICAÇÃO
);

CREATE TABLE IF NOT EXISTS tb_asmb_config_voto(
	ID SERIAL PRIMARY KEY NOT NULL,
	DESCRICAO VARCHAR(20) NOT NULL, --DESCRIÇÃO QUE IRÁ APARECER NA TELA DE CONF DE TÓPICO (EX: MUDAR FACHADA DO CONDOMINIO NECESSITA DE 100% DE VOTOS A FAVOR)
	PercentAprovacao INT NOT NULL --PORCENTAGEM DE VOTOS NECESSÁRIOS PARA A APROVAÇÃO (CADA TIPO DE TÓPICO NECESSITA DE UMA PORCENTAGEM DIFERENTE PARA SER APROVADO)
);

CREATE TABLE IF NOT EXISTS tb_asmb_topico( 	-- TÓPICOS A SEREM VOTADOS PELOS CONDOMINOS
	ID SERIAL PRIMARY KEY NOT NULL,
	ID_condominio INT NOT NULL,			-- TÓPICO DE QUAL CONDOMINIO
	Titulo VARCHAR(50) NOT NULL,		-- TITULO DO TÓPICO
	Descricao VARCHAR(50) NOT NULL,		-- DESCRIÇÃO DO TÓPICO (PORQUE TAL QUESTÃO ESTÁ EM VOTAÇÃO ETC)
	ID_asbm_config_voto INT NOT NULL,	-- COMO ESTÁ CONFIGURADO A PORCENTAGEM DE VOTOS P/ APROVAÇÃO DO TÓPICO
	VT_FAVOR INT,						-- \\\\
	VT_CONTRA INT, 						-- CONTAGEM DE VOTOS
	VT_NEUTRO INT,						-- ////
	FOREIGN KEY(ID_condominio) REFERENCES tb_condominio (ID),
	FOREIGN KEY(ID_asbm_config_voto) REFERENCES tb_asmb_config_voto(ID)
);


CREATE TABLE IF NOT EXISTS tb_asmb_hist_topico(		-- HISTORICO DE VOTAÇÕES PARA CONTROLE DE VOTOS
	ID SERIAL PRIMARY KEY NOT NULL,
	ID_condominio INT NOT NULL,			-- PERTENCE A QUAL CONDOMINIO
	ID_topico INT NOT NULL,				-- \\\\
	ID_condomino INT NOT NULL,			-- CONTROLE DE QUAL MORADOR VOTOU, QUAL TOPICO E QUAL VOTO FOI
	ID_tipo_voto INT NOT NULL,			-- ////
	Comentario VARCHAR(100),			-- PARA COMENTARIOS DO COMDOMINO SOBRE O TÓPICO
	FOREIGN KEY(ID_condominio) REFERENCES tb_condominio (ID),
	FOREIGN KEY(ID_topico) REFERENCES tb_asmb_topico (ID),
	FOREIGN KEY(ID_condomino) REFERENCES tb_condomino (ID)
);

CREATE TABLE IF NOT EXISTS tb_asmb_tipo_voto(		-- ASSIMILAÇÃO DE TIPO DE VOTOS
	ID SERIAL PRIMARY KEY NOT NULL,
	Descricao VARCHAR(15) NOT NULL
);
INSERT INTO tb_asmb_tipo_voto(Descricao) VALUES ('FAVOR');
INSERT INTO tb_asmb_tipo_voto(Descricao) VALUES ('CONTRA');



-- 					FUNÇÕES DO BANCO                    --

CREATE OR REPLACE FUNCTION insertCidade(_Cidade VARCHAR(50))
RETURNS VOID AS
$$
begin
	INSERT INTO tb_cidades (DESCRICAO)
	SELECT _Cidade
	WHERE NOT EXISTS (
	SELECT DESCRICAO FROM tb_cidades WHERE DESCRICAO = _Cidade
	);
end
$$
language plpgsql;

CREATE OR REPLACE FUNCTION insertCondominio(_Nome VARCHAR(50), _Uf INT, _Cidade INT, _Rua VARCHAR(50), _Numero VARCHAR(50), _Capacidade VARCHAR(50), _CNPJ VARCHAR(50), _Email VARCHAR(50), _Telefone VARCHAR(50))
RETURNS VOID AS
$$
begin
	INSERT INTO tb_condominio (_Nome, _Uf, _Cidade, _Rua, _Numero, _Capacidade, _CNPJ, _Email, _Telefone)
	SELECT _Nome, _Uf, _Cidade, _id_uf, _Rua, _Numero, _Capacidade, _CNPJ, _Email, _Telefone
	WHERE NOT EXISTS (
    SELECT Nome FROM tb_condominio WHERE Nome = _Nome
end
$$
language plpgsql;

CREATE OR REPLACE FUNCTION CadastrarCondominio(_Nome VARCHAR(50), _Uf INT, _Cidade VARCHAR(50), _Rua VARCHAR(50), _Numero VARCHAR(50), _Capacidade VARCHAR(50), _CNPJ VARCHAR(50), _Email VARCHAR(50), _Telefone VARCHAR(50))
RETURNS VOID AS	
$$
begin
	PERFORM insertCidade(_Cidade);
	PERFORM insertCondominio(_Nome, (SELECT id FROM tb_uf WHERE descricao = _Uf), (SELECT id from tb_cidades where descricao = _Cidade), _Rua, _Numero, _Capacidade, _CNPJ, _Email, _Telefone);
end
$$
language plpgsql;
