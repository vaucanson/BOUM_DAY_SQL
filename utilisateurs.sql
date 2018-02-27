
-- R�LES
-- ************************
-- responsable d'atelier
-- responsable de production
-- contr�leur
-- magasin
-- responsable de qualit�
-- responsable de l'application
-- *********************************

--resp_application
--resp_production1
--resp_production2
--resp_atelier1
--resp_atelier2
--controleur1 - 2 - 3
--magasinier1 - 2 - 3
--resp_qualit�1 - 2

--mdp = login



-- UTILISATEURS
create user user_resp_app from login resp_application;
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
create user user_resp_qualit1 from login resp_qualit�1;
create user user_resp_qualit2 from login resp_qualit�2;




-- R�LES

create role applicationHeadOf;

-- ajoute le droit d'ex�cution sur la proc�dure stock�e addModel au r�le applicationHeadOf
grant EXECUTE on addModel to applicationHeadOf;

alter role applicationHeadOf add member user_resp_app;

