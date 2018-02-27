
-- RÔLES
-- ************************
-- responsable d'atelier
-- responsable de production
-- contrôleur
-- magasin
-- responsable de qualité
-- responsable de l'application
-- *********************************


create role applicationHeadOf;

-- ajoute le droit d'exécution sur la procédure stockée addModel au rôle applicationHeadOf
grant EXECUTE on addModel to applicationHeadOf;

alter role applicationHeadOf add member George;


