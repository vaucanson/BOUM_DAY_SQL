

--drop database BOUM_DAY




CREATE DATABASE BOUM_DAY
GO



use BOUM_DAY;
go

--LV0
CREATE TABLE PRESS 
(
id					smallint			PRIMARY KEY 			IDENTITY(1,1)
);
GO

CREATE TABLE MODEL
(
name				varchar(5)			PRIMARY KEY,
diameter			float	NOT NULL	
);
GO

CREATE TABLE CATEGORY
(
name				varchar(5)			PRIMARY KEY,
minTolerance		decimal(3,2) NOT NULL,		
maxTolerance		decimal(3,2) NOT NULL
);
GO

CREATE TABLE BATCH_STATE
(
name				varchar(10)			PRIMARY KEY,
);
go

--LV1
CREATE TABLE BATCH
(
id 					smallint			PRIMARY KEY IDENTITY(1,1),
date 				datetime NOT NULL,
piecesNumber		smallint NOT NULL,
state 				varchar(10)			FOREIGN KEY (state) REFERENCES BATCH_STATE (name),
press				smallint			FOREIGN KEY (press) REFERENCES PRESS (id),
model				varchar(5)			FOREIGN KEY (model) REFERENCES MODEL (name)
);

CREATE TABLE STOCK
(
category 			varchar(5)			FOREIGN KEY (category) REFERENCES CATEGORY(name),
model 				varchar(5)			FOREIGN KEY (model) REFERENCES MODEL(name),
limit				smallint NOT NULL,
quantity			int,

PRIMARY KEY (category, model)
);

--LV2
CREATE TABLE PIECE
(
id 					smallint			PRIMARY KEY IDENTITY(1,1),
ht					decimal(5,3) NOT NULL,
hl					decimal(5,3) NOT NULL,
bt					decimal(5,3) NOT NULL,
bl					decimal(5,3) NOT NULL,
batch 				smallint			FOREIGN KEY (batch) REFERENCES BATCH(id)
)


--REMPLISSAGE DE TABLE

INSERT INTO BATCH_STATE 
VALUES ('lancé')
GO
INSERT BATCH_STATE 
VALUES ('démarré')
GO
INSERT  BATCH_STATE 
VALUES ('libéré')
GO
INSERT  BATCH_STATE 
VALUES ('arrêté')
GO



