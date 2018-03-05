
--mdp des utilisateurs = login


-- CRÉATION DES UTILISATEURS
create user user_resp_app from login resp_appli;
create user user_resp_prod1 from login resp_production1;
create user user_resp_prod2 from login resp_production2;
create user user_resp_atel1 from login resp_atelier1;
create user user_resp_atel2 from login resp_atelier2;
create user user_controleur1 from login controleur1;
create user user_controleur2 from login controleur2;
create user user_controleur3 from login controleur3;
create user user_magasinier1 from login magasinier1;
create user user_magasinier2 from login magasinier2;
create user user_magasinier3 from login magasinier3;
create user user_resp_qualit1 from login resp_qualité1;
create user user_resp_qualit2 from login resp_qualité2;


-- CRÉATION DES RÔLES
create role applicationHeadOf; -- le responsable d'application
create role productionHeadOf; -- le responsable de production
create role workshopHeadOf; -- le responsable d'atelier
create role controller; -- le contrôleur
create role storeKeeper; -- le magasinier
create role qualityHeadOf; -- le responsable de la qualité
create role everyBody;

-- AFFECTATIONS DES DROITS AUX RÔLES
grant SELECT on getRoles to everyBody;
grant SELECT on stockUnderLimit to workshopHeadOf;
grant EXECUTE on initBatch to applicationHeadOf;
grant SELECT on freePresses to productionHeadOf;
grant EXECUTE on startBatch to productionHeadOf;
grant EXECUTE on endBatch to productionHeadOf;
grant EXECUTE on setDimensions to controller;
grant EXECUTE on stopBatch to controller;
grant EXECUTE on addCrate to storeKeeper;
grant EXECUTE on addModel to applicationHeadOf;
grant EXECUTE on removeModel to applicationHeadOf;
grant EXECUTE on addPress to applicationHeadOf;
grant EXECUTE on removePress to applicationHeadOf;
grant EXECUTE on changeLimit to applicationHeadOf;
grant EXECUTE on pieceCleanUp to applicationHeadOf;

-- AFFECTATION DES USERS AUX RÔLES
alter role applicationHeadOf add member user_resp_app;
alter role productionHeadOf add member user_resp_prod1;
alter role productionHeadOf add member user_resp_prod2;
alter role workshopHeadOf add member user_resp_atel1;
alter role workshopHeadOf add member user_resp_atel2;
alter role controller add member user_controleur1;
alter role controller add member user_controleur2;
alter role controller add member user_controleur3;
alter role storeKeeper add member user_magasinier1;
alter role storeKeeper add member user_magasinier2;
alter role storeKeeper add member user_magasinier3;
alter role qualityHeadOf add member user_resp_qualit1;
alter role qualityHeadOf add member user_resp_qualit2;

-- TOUT LE MONDE A LE RÔLE EVERYBODY
alter role everyBody add member user_resp_app;
alter role everyBody add member user_resp_prod1;
alter role everyBody add member user_resp_prod2;
alter role everyBody add member user_resp_atel1;
alter role everyBody add member user_resp_atel2;
alter role everyBody add member user_controleur1;
alter role everyBody add member user_controleur2;
alter role everyBody add member user_controleur3;
alter role everyBody add member user_magasinier1;
alter role everyBody add member user_magasinier2;
alter role everyBody add member user_magasinier3;
alter role everyBody add member user_resp_qualit1;
alter role everyBody add member user_resp_qualit2;


-- POUR NOS TESTS
