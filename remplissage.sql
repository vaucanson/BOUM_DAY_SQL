

-- REMPLISSAGE


INSERT PRESS
VALUES (1)

GO

INSERT MODEL
VALUES ('XB500', 15, 1)
INSERT MODEL
VALUES ('XB600', 25, 1)
INSERT MODEL
VALUES ('XB700', 35, 1)
GO

INSERT CATEGORY
VALUES ('Petit', -0.1, -0.01)
INSERT CATEGORY
VALUES ('Moyen', -0.05, +0.05)
INSERT CATEGORY
VALUES ('Grand', +0.01, +0.1)
GO

INSERT INTO BATCH_STATE 
VALUES ('Lancé')
INSERT BATCH_STATE 
VALUES ('Démarré')
INSERT  BATCH_STATE 
VALUES ('Libéré')
INSERT  BATCH_STATE 
VALUES ('Arrêté')
GO

INSERT BATCH
VALUES('27/02/2018', 30, 1, 1, 'XB500')
INSERT BATCH
VALUES('27/02/2018', 40, 2,  1, 'XB600')
INSERT BATCH
VALUES('27/02/2018', 50, 3,  1, 'XB700' )
GO

INSERT STOCK
VALUES ('Petit', 'XB500', 20, 50)
INSERT STOCK
VALUES ('Moyen', 'XB500', 20, 50)
INSERT STOCK
VALUES ('Grand', 'XB500', 20, 50)
INSERT STOCK
VALUES ('Petit', 'XB600', 20, 20)
INSERT STOCK
VALUES ('Moyen', 'XB600', 20, 12)
INSERT STOCK
VALUES ('Grand', 'XB600', 20, 50)
INSERT STOCK
VALUES ('Petit', 'XB700', 40, 10)
INSERT STOCK
VALUES ('Moyen', 'XB700', 40, 20)
INSERT STOCK
VALUES ('Grand', 'XB700', 40, 30)
GO

INSERT PIECE
VALUES (14.98, 15.00, 15.05, 15.01, 1)
INSERT PIECE
VALUES (25.05, 25.00, 25.00, 25.01, 1)
INSERT PIECE
VALUES (35.00, 35.05, 34.95, 35.00, 1)
INSERT PIECE
VALUES (14.98, 15.00, 15.05, 15.01, 2)
INSERT PIECE
VALUES (25.05, 25.00, 25.00, 25.01, 2)
INSERT PIECE
VALUES (35.00, 35.05, 34.95, 35.00, 2)
INSERT PIECE
VALUES (14.98, 15.00, 15.05, 15.01, 3)
INSERT PIECE
VALUES (25.05, 25.00, 25.00, 25.01, 3)
INSERT PIECE
VALUES (35.00, 35.05, 34.95, 35.00, 3)
GO
