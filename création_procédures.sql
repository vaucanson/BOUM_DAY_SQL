
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

	insert into batch (date, piecesNumber, state, press, model)
	values (GETDATE(),
			@numberOfPiecesAsked,
			1, -- un lot est créé à l'état 1
			null, -- un lot n'a pas de presse à sa création
			@model
	)

	return @retour;
go


-- vue donnant toutes les machines libres
create view freePresses


-- démarrage d'un lot :
-- * par le responsable de production
-- * si une presse est libre 
-- * affectation d'une presse au lot

create proc startBatch

-- Lot fini de fabriquer
-- * par le responsable de production, sur un lot dans l'état 'démarré'
-- * colle une étiquette sur le tapis, et dit que le lot a libéré la machine (= càd passe le lot en état 'libéré')

-- à faire automatiquement dès que toutes les pièces d'un lot ont été traitées
create proc endBatch


-- saisie des mesures
-- * par le contrôleur
-- * crée une pièce avec les quatre mesures saisies

create proc setDimensions -- par Yannick


-- arrêt du lot
-- * par le contrôleur
-- * passage du lot en état 'arrêté' (calcul des moyennes etc.)

create proc stopBatch


-- enregistrement des stocks
-- * par le magasin
-- * ajoute une caisse
create proc addCrate


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


