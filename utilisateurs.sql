
-- R�LES
-- ************************
-- responsable d'atelier
-- responsable de production
-- contr�leur
-- magasin
-- responsable de qualit�
-- responsable de l'application
-- *********************************


create role applicationHeadOf;

-- ajoute le droit d'ex�cution sur la proc�dure stock�e addModel au r�le applicationHeadOf
grant EXECUTE on addModel to applicationHeadOf;

alter role applicationHeadOf add member George;


