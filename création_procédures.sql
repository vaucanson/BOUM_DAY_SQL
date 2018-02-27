
-- vue de la table stock, renvoyant en plus un bool�en disant si le stock est en-dessous du seuil autoris�
create view stockUnderLimit as
select 
	STOCK.category, STOCK.limit, STOCK.model, STOCK.quantity,
	case when stock.quantity <= stock.limit then 1 else 0 end as isLimitReached
from stock 
go


-- le responsable d'atelier consulte et, si besoin, lance un lot

-- lancement d'un lot�: 
-- * par le responsable d'atelier, sur la base de la consultation du stock
-- * consiste en la cr�ation du lot avec un nombre de pi�ces et un mod�le

alter PROC initBatch 
						@numberOfPiecesAsked smallint, -- le nombre de pi�ces demand�es
						@model varchar(5), -- le mod�le
						@message varchar(50) OUTPUT -- message en sortie
AS

	declare @retour int;
	set @retour = 1;

	insert into batch (date, piecesNumber, state, press, model)
	values (GETDATE(),
			@numberOfPiecesAsked,
			1, -- un lot est cr�� � l'�tat 1
			null, -- un lot n'a pas de presse � sa cr�ation
			@model
	)

	return @retour;
go


-- vue donnant toutes les machines libres
create view freePresses


-- d�marrage d'un lot�:
-- * par le responsable de production
-- * si une presse est libre 
-- * affectation d'une presse au lot

create proc startBatch

-- Lot fini de fabriquer
-- * par le responsable de production, sur un lot dans l'�tat 'd�marr�'
-- * colle une �tiquette sur le tapis, et dit que le lot a lib�r� la machine (= c�d passe le lot en �tat 'lib�r�')

-- � faire automatiquement d�s que toutes les pi�ces d'un lot ont �t� trait�es
create proc endBatch


-- saisie des mesures
-- * par le contr�leur
-- * cr�e une pi�ce avec les quatre mesures saisies

create proc setDimensions -- par Yannick


-- arr�t du lot
-- * par le contr�leur
-- * passage du lot en �tat 'arr�t�' (calcul des moyennes etc.)

create proc stopBatch


-- enregistrement des stocks
-- * par le magasin
-- * ajoute une caisse
create proc addCrate


-- suppression d'une caisse
-- * par le magasin
-- * enl�ve une caisse
create proc removeCrate


-- Cr�ation de mod�le
-- * par le responsable d'application
-- * cr�e un mod�le
create proc addModel


-- Suppression de mod�le
-- * par le responsable d'application
-- * supprime un mod�le
create proc removeModel

-- Cr�ation de presse
-- * par le responsable d'application
-- * cr�e une presse
create proc addPress

-- Suppression de presse
-- * par le responsable d'application
-- * supprime une presse
create proc removePress


-- Modifie un seuil 
-- * par le responsable d'application
-- * modifie un seuil dans la table stock
create proc changeLimit


-- purge la base de donn�es
-- * par le responsable d'application
-- * supprime les lots et pi�ces datant de plus d'un an
create proc piecesCleanUp


