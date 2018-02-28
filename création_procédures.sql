
----------------PROCEDURE STOCKEES-----------------------

-- vue de la table stock, renvoyant en plus un booléen disant si le stock est en-dessous du seuil autorisé
create view stockUnderLimit as
select 
	STOCK.category, STOCK.limit, STOCK.model, STOCK.quantity,
	case when stock.quantity <= stock.limit then 1 else 0 end as isLimitReached
from stock 
go


-- le responsable d'atelier consulte et, si besoin, lance un lot

-- lancement d'un lot : 
-- * par le responsable d'atelier, sur la base de la consultation du stock
-- * consiste en la création du lot avec un nombre de pièces et un modèle

CREATE PROCEDURE initBatch 
						@numberOfPiecesAsked smallint, -- le nombre de pièces demandées
						@model varchar(5), -- le modèle
						@message varchar(50) OUTPUT -- message en sortie
AS
	declare @codeRet int;

	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				if @numberOfPiecesAsked is null or @numberOfPiecesAsked = 0
					BEGIN
						set @codeRet = 1;
						set @message = 'Le nombre de pièces doit être renseigné et différent de zéro';
						ROLLBACK TRANSACTION;
					END
				else if @model is null or @model = ''
					BEGIN
						set @codeRet = 1;
						set @message = 'Le modèle doit être renseigné';
						ROLLBACK TRANSACTION;
					END
				else
					BEGIN
						insert into batch (date, piecesNumber, state, press, model)
						values (GETDATE(),
								@numberOfPiecesAsked,
								1, -- un lot est créé à l'état 1
								null, -- un lot n'a pas de presse à sa création
								@model
						)
						set @message = 'Le lot a bien été créé';
						set @codeRet = 0;
						COMMIT TRANSACTION
					END
			END TRY
			BEGIN CATCH
				set @codeRet = 3;
				Set @codeRet= 'Erreur base de données : ' + ERROR_MESSAGE() ;
				ROLLBACK TRANSACTION
			END CATCH
		END

return @codeRet;

GO



-- vue donnant toutes les machines libres
CREATE view freePresses as
select p.id as id
from press p
where p.id not in (
	select distinct press
	from BATCH b
	where b.state = 2
)
go


-- démarrage d'un lot :
-- * par le responsable de production
-- * si une presse est libre 
-- * affectation d'une presse au lot

CREATE PROCEDURE startBatch 
						@batch smallint, -- le lot à démarrer
						@press smallint, -- la presse à affecter au lot
						@message varchar(50) OUTPUT -- message en sortie
AS

declare @codeRet int; 
BEGIN TRANSACTION
	BEGIN TRY
		if @press not in (select * from freePresses)
			BEGIN
				set @message = 'la presse indiquée n''est pas libre';
				set @codeRet = 1;
				ROLLBACK TRANSACTION
			END
		else if @batch not in (select id from BATCH where state = 1)
			BEGIN
				set @message = 'le lot indiqué n''est pas en attente de démarrage';
				set @codeRet = 1;
				ROLLBACK TRANSACTION
			END
		else
			BEGIN

				UPDATE BATCH 
				SET press = @press, -- on affecte une presse
					state = 2 -- le lot passe en état 'démarré'
				WHERE id = @batch

				set @message = 'le lot est démarré sur la presse ' + CAST(@press as Char(2));
				set @codeRet = 0;
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
		set @codeRet = 3;
		Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
		ROLLBACK TRANSACTION
	END CATCH

return @codeRet;

GO

-- Lot fini de fabriquer
-- * par le responsable de production, sur un lot dans l'état 'démarré'
-- * colle une étiquette sur le tapis, et dit que le lot a libéré la machine (= càd passe le lot en état 'libéré')

-- à faire automatiquement dès que toutes les pièces d'un lot ont été traitées
CREATE PROCEDURE endBatch 
						@batch smallint, -- le lot à démarrer
						@message varchar(50) OUTPUT -- message en sortie
AS

declare @codeRet int; 
BEGIN TRANSACTION
	BEGIN TRY
		if @batch not in (select id from BATCH where state = 2)
			BEGIN
				set @message = 'le lot indiqué n''est pas en production';
				set @coderet = 1;
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				update BATCH 
					set state = 3
					where id = @batch;
				set @message = 'le lot est arrêté';
				set @codeRet = 0;
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
		set @codeRet = 3;
		Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
		ROLLBACK TRANSACTION
	END CATCH

return @codeRet;
go


-- saisie des mesures
-- * par le contrôleur
-- * crée une pièce avec les quatre mesures saisies

CREATE PROCEDURE setDimensions @ht numeric, @hl numeric, @bt numeric, @bl numeric, @idBatch smallint, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRANSACTION
	BEGIN TRY
		if @ht = 0 or @ht is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Champ haut transversal manquant';
				ROLLBACK TRANSACTION
			END
		else if @hl = 0 or @hl is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Champ haut longitudinal manquant';
				ROLLBACK TRANSACTION
			END
		else if @bt = 0 or @bt is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Champ bas transversal manquant';
				ROLLBACK TRANSACTION
			END
		else if @bl = 0 or @bl is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Champ bas longitudinal manquant';
				ROLLBACK TRANSACTION
			END
		else if @idBatch = 0 or @idBatch is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Probleme identification du lot';
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				INSERT PIECE
				VALUES(@ht, @hl, @bt, @bl, @idBatch)

				set @codeRet = 0;
				set @message = 'La piece a bien été créée';
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
		Set @message= 'erreur base de données' + ERROR_MESSAGE() ;
		set @codeRet = 3;
		ROLLBACK TRANSACTION
	END CATCH

RETURN @codeRet;

GO


-- arrêt du lot
-- * par le contrôleur
-- * passage du lot en état 'arrêté' (calcul des moyennes etc.)
CREATE proc stopBatch 
						@batch smallint, -- le lot à démarrer
						@message varchar(50) OUTPUT -- message en sortie
AS

	declare @codeRet int; 

BEGIN TRANSACTION
	BEGIN TRY
		if @batch not in (select id from BATCH where state = 3)
		BEGIN
			set @message = 'le lot indiqué n''est pas en vérification';
			set @codeRet = 1;
			ROLLBACK TRANSACTION
		END
		else
		BEGIN
			UPDATE BATCH 
			SET state = 4
			WHERE id = @batch;

			set @message = 'le lot est arrêté';
			set @codeRet = 0;
			COMMIT TRANSACTION
		END
	END TRY
	BEGIN CATCH
		set @codeRet = 3;
		Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
		ROLLBACK TRANSACTION
	END CATCH

RETURN @codeRet;

GO


-- enregistrement des stocks
-- * par le magasin
-- * ajoute une caisse
CREATE PROCEDURE addCrate @category varchar(10), @model varchar(10), @quantity smallint, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRANSACTION
	BEGIN TRY
		if @category is null or @category = ''
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ catégorie est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @model = '' or @model is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ modèle est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @quantity = 0 or @quantity is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ quantité est incorrecte';
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				UPDATE STOCK
				SET quantity += @quantity
				WHERE category = @category and model = @model

				set @codeRet = 0;
				set @message = 'Le stock a bien été mis à jour, ' + CAST(@quantity as Char(3)) + 'caisses ont été ajoutées';
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
			set @codeRet = 3;
			Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
			ROLLBACK TRANSACTION	
	END CATCH

RETURN @codeRet;

GO

-- enregistrement des stocks
-- * par le magasin
-- * enlève une caisse
CREATE PROCEDURE removeCrate @category varchar(10), @model varchar(10), @quantity smallint, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRANSACTION
	BEGIN TRY
		if @category is null or @category = ''
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ catégorie est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @model = '' or @model is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ modèle est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @quantity = 0 or @quantity is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ quantité est incorrecte';
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				UPDATE STOCK
				SET quantity -= @quantity
				WHERE category = @category and model = @model

				set @codeRet = 0;
				set @message = 'Le stock a bien été mis à jour, ' + CAST(@quantity as Char(3)) + 'caisses ont été enlevées';
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
			set @codeRet = 3;
			Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
			ROLLBACK TRANSACTION	
	END CATCH

RETURN @codeRet;

GO



-- Création de modèle
-- * par le responsable d'application
-- * crée un modèle
CREATE PROCEDURE addModel @name varchar(5), @diameter float, @littleMin int, @midMin int, @bigMin int, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRANSACTION
	BEGIN TRY
		if @name = '' or @name is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ nom est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @diameter = 0 or @diameter is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ diamètre est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @littleMin = 0 or @littleMin is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ minimum catégorie petite est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @midMin = 0 or @midMin is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ minimum catégorie moyenne est incorrect';
				ROLLBACK TRANSACTION
			END
		else if @bigMin = 0 or @bigMin is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ minimum catégorie grande est incorrect';
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				INSERT MODEL 
				VALUES (@name, @diameter, 1);
			
				INSERT STOCK
				VALUES ('Petit', @name, @littleMin, 0);
			
				INSERT STOCK
				VALUES ('Moyen', @name, @midMin, 0);
			
				INSERT STOCK
				VALUES ('Grand', @name, @bigMin, 0);
			
				SET @codeRet = 1;
				SET @message = 'Le nouveau modèle a bien été ajouté.';
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
		SET @codeRet = 3;
		SET @message = 'Erreur : ' + ERROR_MESSAGE();
		ROLLBACK TRANSACTION
	END CATCH

RETURN @codeRet;

GO


-- Suppression de modèle
-- * par le responsable d'application
-- * supprime un modèle
CREATE PROCEDURE removeModel @name varchar(5), @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRANSACTION
	BEGIN TRY
		if @name = '' or @name is null
			BEGIN
				set @codeRet = 1;
				set @message = 'Le champ nom est incorrect.';
				ROLLBACK TRANSACTION
			END
		else
			BEGIN
				UPDATE MODEL
				SET active = 0
				WHERE name = @name
			
				SET @codeRet = 1;
				SET @message = 'Le modèle a bien été retiré.';
				COMMIT TRANSACTION
			END
	END TRY
	BEGIN CATCH
		SET @codeRet = 3;
		SET @message = 'Erreur : ' + ERROR_MESSAGE();
		ROLLBACK TRANSACTION
	END CATCH

RETURN @codeRet;

GO

-- Création de presse
-- * par le responsable d'application
-- * crée une presse
CREATE PROCEDURE addPress @message varchar(50) output
AS
DECLARE @codeRet int;
BEGIN TRANSACTION
	BEGIN TRY
		INSERT PRESS
		DEFAULT VALUES
		set @codeRet = 0;
		set @message = 'Une nouvelle presse a été créée';
	END TRY
	BEGIN CATCH
			set @codeRet = 3;
			Set @message= 'Erreur base de données : ' + ERROR_MESSAGE() ;
	END CATCH
GO

-- Suppression de presse
-- * par le responsable d'application
-- * supprime une presse
CREATE PROCEDURE removePress @id smallint, @message varchar(50) output
AS
DECLARE @codeRet int;
BEGIN TRY
	UPDATE PRESS
	SET active = 0
	WHERE id = @id

	set @codeRet = 0;
	set @message = 'La presse numéro ' + CAST(@id as Char(2)) + ' a été retirée de la base';
END TRY
BEGIN CATCH
	set @codeRet = 3;
	Set @message= 'Erreur base de données : ' + ERROR_MESSAGE() ;
END CATCH
GO


-- Modifie un seuil 
-- * par le responsable d'application
-- * modifie un seuil dans la table stock
CREATE proc changeLimit
						@model varchar(5), -- le modèle 
						@category varchar(5), -- la catégorie
						@limit smallint, -- la limite à affecter
						@message varchar(50) OUTPUT -- le message de retour
AS
	declare @codeRet int;

BEGIN TRY
	if @model is null or @model = '' or @model not in (select name from model)
	BEGIN
		set @message = 'Le modèle doit être renseigné';
		set @codeRet = 1;
	END
	else if @category is null or @category = '' or @category not in (select name from CATEGORY)
	BEGIN
		set @message = 'La catégorie doit être renseignée';
		set @codeRet = 1;
	END
	else if @category is null or @category = ''
	BEGIN
		set @message = 'La catégorie doit être renseignée';
		set @codeRet = 1;
	END
	else if @limit < 0
	BEGIN
		set @message = 'La limite doit être positive';
		set @codeRet = 1;
	END
	else
		BEGIN
			UPDATE STOCK 
			SET limit = @limit
			WHERE model = @model and category = @category

			set @message = 'Le seuil a bien été mis à jour'
			set @codeRet = 0;
		END
END TRY
	BEGIN CATCH 
		set @codeRet = 3;
		Set @message= 'Erreur base de données : ' + ERROR_MESSAGE() ;
	END CATCH


	RETURN @codeRet;

GO


-- purge la base de données
-- * par le responsable d'application
-- * supprime les lots et pièces datant de plus d'un an
CREATE PROCEDURE pieceCleanUp @message varchar(50) output
AS
DECLARE @codeRet int;
BEGIN TRY
	DELETE FROM PIECE
	WHERE id = (
		SELECT PIECE.id 
		FROM PIECE 
		JOIN BATCH on BATCH.id = PIECE.batch
		WHERE DATEDIFF(DAY, BATCH.date, GETDATE()) > 365)

		set @codeRet = 0;
		set @message = 'Les pièces ont été purgées';
END TRY
BEGIN CATCH
		set @codeRet = 3;
		Set @message= 'Erreur base de données : ' + ERROR_MESSAGE() ;
END CATCH

GO

-- change les seuils de tolerance des pieces
-- * par le responsable d'application
-- * diminue ou augmente les seuils qui determineront si l'appartenance de la piece
CREATE PROCEDURE changeTolerance @name varchar(10), @min decimal(3,2), @max decimal(3,2), @message varchar(50) output
AS
DECLARE @codeRet int;
BEGIN TRANSACTION
BEGIN TRY
	if @name = '' or @name is null
		BEGIN
		SET @codeRet = 1;
		SET @message = 'Le nom est invalide.';
		ROLLBACK TRANSACTION;
		END
	else if @min is null or @min = 0
		BEGIN
		SET @codeRet = 1;
		SET @message = 'Valeur minimale invalide';
		ROLLBACK TRANSACTION;
		END
	else if @max is null or @max = 0
		BEGIN 
		SET @codeRet = 1;
		SET @message = 'Valeur maximale invalide';
		ROLLBACK TRANSACTION;
		END
	else
		BEGIN
		UPDATE CATEGORY
		SET minTolerance = @min 
		WHERE name = @name;

		UPDATE CATEGORY
		SET maxTolerance = @max
		WHERE name = @name;

		SET @codeRet = 0;
		SET @message = 'L''intervalle de Tolérance a bien été mis à jour.';

		COMMIT TRANSACTION;
		END
	END TRY
BEGIN CATCH
	SET @codeRet = 3;
	SET @message = 'Erreur : ' + ERROR_MESSAGE();
	ROLLBACK TRANSACTION;
END CATCH

GO