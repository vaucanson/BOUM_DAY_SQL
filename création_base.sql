-- drop database BOUM_DAY




CREATE DATABASE BOUM_DAY
GO

use BOUM_DAY;
go

--create user david from login boilleau
--create user yannick from login badaroux

--LV0
CREATE TABLE PRESS 
(
id					smallint			PRIMARY KEY 			IDENTITY(1,1),
active				bit,
);
GO

CREATE TABLE MODEL
(
name				varchar(5)			PRIMARY KEY,
diameter			float	NOT NULL,
active				bit,	
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
id					smallint			PRIMARY KEY IDENTITY(1,1),
name				varchar(10)
);
go

--LV1
CREATE TABLE BATCH
(
id 					smallint			PRIMARY KEY IDENTITY(1,1),
date 				smalldatetime NOT NULL,
piecesNumber		smallint NOT NULL,
state 				smallint			FOREIGN KEY (state) REFERENCES BATCH_STATE (id),
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


