
-- vue de la table stock, renvoyant en plus un booléen disant si le stock est en-dessous du seuil autorisé
create view stockUnderLimit as
select 
	STOCK.category, STOCK.limit, STOCK.model, STOCK.quantity,
	case when stock.quantity <= stock.limit then 1 else 0 end as isLimitReached
from stock 
go


-- le responsable d'atelier consulte et, si besoin, lance un lot

-- lancement d'un lot : 
-- * par le responsable d'atelier, sur la base de la consultation du stock
-- * consiste en la création du lot avec un nombre de pièces et un modèle

alter PROC initBatch 
						@numberOfPiecesAsked smallint, -- le nombre de pièces demandées
						@model varchar(5), -- le modèle
						@message varchar(50) OUTPUT -- message en sortie
AS

	declare @retour int;
	set @retour = 1;

	if @numberOfPiecesAsked is null or @numberOfPiecesAsked = 0
	BEGIN
		set @message = 'le nombre de pièces doit être renseigné et différent de zéro';
	END
	else if @model is null or @model = ''
	BEGIN
		set @message = 'le modèle doit être renseigné';
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
		set @message = 'le lot a bien été créé';
		set @retour = 0;
	END
	return @retour;
go



-- vue donnant toutes les machines libres
create view freePresses as
select p.id as id
from press p
where p.id not in (
	select distinct press
	from BATCH b
	where b.state = 2
)
go


-- démarrage d'un lot :
-- * par le responsable de production
-- * si une presse est libre 
-- * affectation d'une presse au lot

alter proc startBatch 
						@batch smallint, -- le lot à démarrer
						@press smallint, -- la presse à affecter au lot
						@message varchar(50) OUTPUT -- message en sortie
AS

	declare @retour int; 
	set @retour = 1;

	if @press not in (select * from freePresses)
	BEGIN
		set @message = 'la presse indiquée n''est pas libre';
	END
	else if @batch not in (select id from BATCH where state = 1)
	BEGIN
		set @message = 'le lot indiqué n''est pas en attente de démarrage';
	END
	else
	BEGIN
		update BATCH set 
			press = @press, -- on affecte une presse
			state = 2 -- le lot passe en état 'démarré'
			where id = @batch
		set @message = 'le lot est démarré sur la presse ' + CAST(@press as Char(2));
		set @retour = 0;
	END
	return @retour;
go

-- Lot fini de fabriquer
-- * par le responsable de production, sur un lot dans l'état 'démarré'
-- * colle une étiquette sur le tapis, et dit que le lot a libéré la machine (= càd passe le lot en état 'libéré')

-- à faire automatiquement dès que toutes les pièces d'un lot ont été traitées
create proc endBatch

go
-- saisie des mesures
-- * par le contrôleur
-- * crée une pièce avec les quatre mesures saisies

CREATE PROCEDURE setDimensions @ht numeric, @hl numeric, @bt numeric, @bl numeric, @idBatch smallint, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRY
	if @ht = 0 or @ht is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Champ haut transversal manquant';
		END
	else if @hl = 0 or @hl is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Champ haut longitudinal manquant';
		END
	else if @bt = 0 or @bt is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Champ bas transversal manquant';
		END
	else if @bl = 0 or @bl is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Champ bas longitudinal manquant';
		END
	else if @idBatch = 0 or @idBatch is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Probleme identification du lot';
		END
	else
		BEGIN
			INSERT PIECE
			VALUES(@ht, @hl, @bt, @bl, @idBatch)

			set @codeRet = 0;
			set @message = 'La piece a bien été créée';
		END
END TRY
BEGIN CATCH
	Set @message= 'erreur base de données' + ERROR_MESSAGE() ;
	set @codeRet = 3;
END CATCH
	RETURN @codeRet;

GO


-- arrêt du lot
-- * par le contrôleur
-- * passage du lot en état 'arrêté' (calcul des moyennes etc.)

create proc stopBatch


-- enregistrement des stocks
-- * par le magasin
-- * ajoute une caisse
alter PROCEDURE addCrate @category varchar(10), @model varchar(10), @quantity smallint, @message varchar(50) output
AS
DECLARE @codeRet int;

BEGIN TRY
	if @category is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Field category missing';
		END
	else if @model = '' or @model is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Field model missing';
		END
	else if @quantity = 0 or @quantity is null
		BEGIN
			set @codeRet = 1;
			set @message = 'Field quantity missing or is null';
		END
	else
		BEGIN
			UPDATE STOCK
			SET quantity += @quantity
			WHERE category = @category and model = @model

			set @codeRet = 0;
			set @message = 'Stock has been updated, ' + CAST(@quantity as Char(3)) + 'crates added';
		END
END TRY
BEGIN CATCH
		set @codeRet = 3;
		Set @message= 'erreur base de données : ' + ERROR_MESSAGE() ;
		
END CATCH

RETURN @codeRet;

GO


-- suppression d'une caisse
-- * par le magasin
-- * enlève une caisse
create proc removeCrate


-- Création de modèle
-- * par le responsable d'application
-- * crée un modèle
create proc addModel


-- Suppression de modèle
-- * par le responsable d'application
-- * supprime un modèle
create proc removeModel

-- Création de presse
-- * par le responsable d'application
-- * crée une presse
create proc addPress

-- Suppression de presse
-- * par le responsable d'application
-- * supprime une presse
create proc removePress


-- Modifie un seuil 
-- * par le responsable d'application
-- * modifie un seuil dans la table stock
create proc changeLimit


-- purge la base de données
-- * par le responsable d'application
-- * supprime les lots et pièces datant de plus d'un an
create proc piecesCleanUp


