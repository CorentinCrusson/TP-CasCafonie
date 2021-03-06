/* -----------------------------------------------------

----------------- CREATE TABLE --------------------------

--------------------------------------------------------
*/

use SIO2_CasCafonie
go


/** 
----------------------------
  TABLE : TYPE INSTITUTION
----------------------------
**/

CREATE TABLE TYPEINSTITUTION (
  code_type_insti int not null,
  lib_type_insti varchar(64) not null,

  CONSTRAINT PK_TYPEINSTITUTION PRIMARY KEY(code_type_insti)
);
go

/** 
----------------------------
  TABLE : INSTITUTION
----------------------------
**/
CREATE TABLE INSTITUTION (
  code_insti int not null IDENTITY(1, 1),
  nom_insti varchar(64) null,
  code_type_insti int null,

  CONSTRAINT PK_INSTITUTION PRIMARY KEY(code_insti),
  CONSTRAINT FK_INSTITUTION_TYPEINSTITUTION FOREIGN KEY (code_type_insti) REFERENCES TYPEINSTITUTION(code_type_insti)
);
go

/** 
----------------------------
  TABLE : R‘LE
----------------------------
**/

CREATE TABLE ROLE (
  code_role int not null,
  lib_role varchar(128) null,
  code_insti int not null,

  CONSTRAINT PK_ROLE PRIMARY KEY(code_role),
  CONSTRAINT FK_ROLE_INSTITUTION FOREIGN KEY (code_insti) REFERENCES INSTITUTION(code_insti)
);
go

/** 
----------------------------
  TABLE : ORGANES
----------------------------
**/

CREATE TABLE ORGANES (
  code_organe int not null,
  lib_organe varchar(32) null,
  nbr_pers_organe int not null,

  CONSTRAINT PK_ORGANES PRIMARY KEY(code_organe)
);
go

/** 
----------------------------
  TABLE : COMPRENDRE
----------------------------
**/

CREATE TABLE COMPRENDRE (
  code_insti int not null,
  code_organe int not null,

  CONSTRAINT PK_COMPRENDRE PRIMARY KEY(code_insti,code_organe),
  CONSTRAINT FK_COMPRENDRE_INSTITUTION FOREIGN KEY (code_insti) REFERENCES INSTITUTION(code_insti),
  CONSTRAINT FK_COMPRENDRE_ORGANES FOREIGN KEY (code_organe) REFERENCES ORGANES(code_organe)
  
);
go

/** 
----------------------------
  TABLE : TEXTE
----------------------------
**/

CREATE TABLE TEXTE(
  code_txt int not null IDENTITY(1, 1),
  titre_txt varchar(256) not null,
  vote_final_txt varchar(32) null,
  promulgation_txt varchar(32) null,
  code_insti int not null
  
  CONSTRAINT PK_TEXTE PRIMARY KEY(code_txt),
  CONSTRAINT FK_TEXTE_INSTITUTION FOREIGN KEY (code_insti) REFERENCES INSTITUTION(code_insti)
  
);
go

/** 
----------------------------
  TABLE : ARTICLE
----------------------------
**/

CREATE TABLE ARTICLE(
  code_txt int not null,
  code_seq_art int not null IDENTITY(1, 1),
  titre_art varchar(64) not null,
  texte_art varchar(8000) not null,

  CONSTRAINT PK_ARTICLE PRIMARY KEY(code_txt,code_seq_art),
  CONSTRAINT FK_ARTICLE_TEXTE FOREIGN KEY (code_txt) REFERENCES TEXTE(code_txt)
  
);
go

/** 
----------------------------
  TABLE : FAIRE REFERENCE
----------------------------
**/

CREATE TABLE FAIRE_REFERENCE(
  code_txt int not null,
  code_seq_art int not null,
  code_txt_1 int not null,
  code_seq_art_1 int not null,

  CONSTRAINT PK_FAIRE_REFERENCE PRIMARY KEY(code_txt,code_seq_art,code_txt_1,code_seq_art_1),
  CONSTRAINT FK_FAIRE_REFERENCE_ARTICLE FOREIGN KEY (code_txt, code_seq_art) REFERENCES ARTICLE(code_txt, code_seq_art),
  CONSTRAINT FK_FAIRE_REFERENCE_ARTICLE_1 FOREIGN KEY (code_txt_1, code_seq_art_1) REFERENCES ARTICLE(code_txt, code_seq_art) 
);
go


/** 
----------------------------
  TABLE : AMENDEMENT
----------------------------
**/

CREATE TABLE AMENDEMENT(
  code_txt int not null,
  code_seq_art int not null,
  code_seq_amend int not null IDENTITY(1, 1),
  lib_amend varchar(64) not null,
  texte_amend varchar(8000) not null,
  date_amend date not null,

  CONSTRAINT PK_AMENDEMENT PRIMARY KEY(code_txt,code_seq_art,code_seq_amend),
  CONSTRAINT FK_AMENDEMENT_ARTICLE FOREIGN KEY (code_txt,code_seq_art) REFERENCES ARTICLE(code_txt,code_seq_art)
  
);
go

/** 
----------------------------
  TABLE : DATE
----------------------------
**/

CREATE TABLE DATE (
  jour_vote date not null,

  CONSTRAINT PK_DATE PRIMARY KEY(jour_vote)  
);
go

/** 
----------------------------
  TABLE : VOTER
----------------------------
**/

CREATE TABLE VOTER(
  code_organe int not null,
  jour_vote date not null,
  code_txt int not null,
  code_seq_art int not null,
  nbr_voix_pour int not null,
  nbr_voix_contre int not null,

  CONSTRAINT PK_VOTER PRIMARY KEY(code_organe, jour_vote, code_txt, code_seq_art), 
  CONSTRAINT FK_VOTER_ORGANES FOREIGN KEY (code_organe) REFERENCES ORGANES(code_organe),
  CONSTRAINT FK_VOTER_DATE FOREIGN KEY (jour_vote) REFERENCES DATE(jour_vote),
  CONSTRAINT FK_VOTER_ARTICLE FOREIGN KEY (code_txt, code_seq_art) REFERENCES ARTICLE(code_txt, code_seq_art) 
  
);
go

CREATE TABLE ROLEWEB (
	code_role_web int not null,
	lib_role_web varchar(64) null,
	
	CONSTRAINT PK_ROLEWEB PRIMARY KEY (code_role_web)
);
go

CREATE TABLE UTILISATEUR (
	code_utilisateur int not null,
	adresse_mail varchar(64) not null,
	password varchar(32) not null,
	code_role_web int null

	CONSTRAINT PK_UTILISATEUR PRIMARY KEY (code_utilisateur)
	CONSTRAINT FK_UTILISATEUR_ROLEWEB FOREIGN KEY (code_role_web) REFERENCES ROLEWEB(code_role_web)
);
go


/* ------------------------------------------------------------------------------------------

------------------------ UTILISATEUR POUR SE CONNECTER A LA BDD --------------------------------------

------------------------------------------------------------------------------------------
*/

CREATE LOGIN adminCafonie
WITH PASSWORD 'adminCafonie'
GO

CREATE USER adminCofonie
FOR LOGIN adminCofonie
GO

EXEC sp_addrolemember 'db_datareader', 'adminCafonie';  
EXEC sp_addrolemember 'db_accessadmin', 'adminCafonie';  
EXEC sp_addrolemember 'db_datawriter', 'adminCafonie';  
EXEC sp_addrolemember 'db_securityadmin', 'adminCafonie';  

/* -------------------------------------------------------------

------------------------ TRIGGERS --------------------------------------

-------------------------------------------------------------
*/


/*
------------------------------------------------------------------
TRIGGER : Un organe ne peut voter que 2 fois pour un mÍme article
------------------------------------------------------------------
*/

CREATE TRIGGER verif_vote_organe_inf_2fois
ON voter
for insert as

declare @nbVoteOrgane int
set @nbVoteOrgane = ( SELECT COUNT(*) 
			FROM voter
			WHERE voter.code_organe = (select code_organe from inserted)
			AND voter.code_txt = (select code_txt from inserted)
			AND voter.code_seq_art = (select code_seq_art from inserted)
		    )

if @nbVoteOrgane > 2
begin
	DELETE FROM voter
	WHERE code_organe = (select code_organe from inserted)
	AND code_txt = (select code_txt from inserted)
	AND code_seq_art = (select code_seq_art from inserted)
  	AND jour_vote = (select jour_vote from inserted)

	print 'Un organe ne peut pas voter plus de deux fois pour un article'
end

/*
---------------------------------------------------------------------------------------
TRIGGER : Un jour de vote ne peut pas Ítre supÈrieur ‡ la date d'aujourd'hui
---------------------------------------------------------------------------------------
*/

CREATE TRIGGER verif_jour_inferieur_datenow
ON date
for insert as

if ( select jour_vote from inserted ) > (SELECT SYSDATETIME() )
begin
	DELETE FROM date
	WHERE jour_vote = ( select jour_vote from inserted )

	print 'Le jour de vote ne peut pas Ítre supÈrieur ‡ la date d aujourd hui '
end

/*
---------------------------------------------------------------------------------------
TRIGGER : Une institution ne peut pas comprendre plus de 2 organes
---------------------------------------------------------------------------------------
*/

CREATE TRIGGER verif_instution_avoir_max_2organe
ON comprendre
for insert as

declare @nbOrgane int
set @nbOrgane = ( SELECT COUNT(*) 
			FROM comprendre
			WHERE code_insti = (select code_insti from inserted)
		    )

if @nbOrgane > 2
begin
	DELETE FROM comprendre
	WHERE code_organe = (select code_organe from inserted)
	AND code_insti = (select code_insti from inserted)

	print 'Une Institution ne peut pas comprendre plus de 2 organes'
end


/*
---------------------------------------------------------------------------------------
TRIGGER : Un article n'a pas ÈtÈ votÈ plus de 4 fois
---------------------------------------------------------------------------------------
*/

CREATE TRIGGER verif_article_vote_4fois
ON voter
for insert as

declare @nbVoteArticle int
set @nbVoteArticle = ( SELECT COUNT(*) 
			FROM voter
			WHERE code_txt = (select code_txt from inserted)
			AND code_seq_art = (select code_seq_art from inserted)
		    )

if @nbVoteArticle > 4
begin
	DELETE FROM voter
	WHERE code_txt = (select code_txt from inserted)
	AND code_seq_art = (select code_seq_art from inserted)
  AND code_organe = (select code_organe from inserted)
  AND jour_vote = (select jour_vote from inserted)

	print 'Un Article ne peut pas Ítre votÈ plus de 4 fois !'
end



/*
---------------------------------------------------------------------------------------
TRIGGER : Une loi ne peut Ítre promulguÈ que si tous les articles qui la composent ont des votes positifs des 2 organes
---------------------------------------------------------------------------------------
*/
CREATE TRIGGER verif_promulg_article_votepositif_2organes
ON texte
for update as

DECLARE @nbVoteOrgane1 int
DECLARE @nbVoteOrgane2 int

DECLARE @code int
DECLARE @codeOrgane1 int
DECLARE @codeOrgane2 int

DECLARE @promulgeTexte int

DECLARE @codeTxt int
DECLARE @codeSeqArt int

SET @codeTxt = ( SELECT code_txt FROM INSERTED )
SET @codeOrgane1 = 0
SET @codeOrgane2 = 0
if(((SELECT vote_final_txt FROM INSERTED)<>(SELECT vote_final_txt FROM deleted)) OR ((SELECT promulgation_txt FROM INSERTED)<>(SELECT promulgation_txt FROM deleted)))
BEGIN
DECLARE cursor_listeOrgane CURSOR
	FOR SELECT code_organe FROM COMPRENDRE WHERE code_insti = (SELECT code_insti FROM inserted )
OPEN cursor_listeOrgane 
FETCH cursor_listeOrgane 
INTO @code

WHILE @@FETCH_STATUS = 0
BEGIN

	if @codeOrgane1 = 0
    SET @codeOrgane1 = @code
	else
		SET @codeOrgane2 = @code
  
	FETCH cursor_listeOrgane 
	INTO @code
END

CLOSE cursor_listeOrgane
DEALLOCATE cursor_listeOrgane

DECLARE cursor_listeArticle CURSOR
	FOR SELECT code_seq_art FROM ARTICLE WHERE code_txt = @codeTxt
OPEN cursor_listeArticle
FETCH cursor_listeArticle
INTO @codeSeqArt

SET @promulgeTexte = 1


WHILE @@FETCH_STATUS = 0 AND @promulgeTexte <> 0
BEGIN

	SET @nbVoteOrgane1 = (SELECT TOP 1 nbr_voix_pour
				FROM voter v    
				WHERE v.code_txt = @codeTxt
				AND v.code_seq_art = @codeSeqArt	
				AND v.code_organe = @codeOrgane1   
        ORDER BY v.jour_vote ASC
        )
	SET @nbVoteOrgane1 = @nbVoteOrgane1 - (SELECT TOP 1 nbr_voix_contre
				FROM voter v 
				WHERE v.code_txt = @codeTxt
  				AND v.code_seq_art = @codeSeqArt	
  				AND v.code_organe = @codeOrgane1 	
          ORDER BY v.jour_vote
  				)
  	if @nbVoteOrgane1 <> ''
    BEGIN
  		SET @nbVoteOrgane2 = (SELECT TOP 1 nbr_voix_pour
  				FROM voter v 
  				WHERE v.code_txt = @codeTxt
  				AND v.code_seq_art = @codeSeqArt	
  				AND code_organe = @codeOrgane2	
          ORDER BY v.jour_vote DESC
  				)
  		SET @nbVoteOrgane2 = @nbVoteOrgane2 - (SELECT TOP 1 nbr_voix_contre
  				FROM voter v 
  				WHERE v.code_txt = @codeTxt
  				AND v.code_seq_art = @codeSeqArt	
  				AND code_organe = @codeOrgane2	
          ORDER BY v.jour_vote DESC
  				)
  		if @nbVoteOrgane2 <> ''

  			if @nbVoteOrgane1 > 0 AND @nbVoteOrgane2 > 0
  				SET @promulgeTexte = 2
  			else
  				print 'Le nombre de -voix pour- doit Ítre supÈrieur au nombre de -voix contre- !'
  		else 
  			print 'Chaque Organe Votant doit avoir au moins votÈ une fois pour chaque article d un texte de Loi!'  
    END
    ELSE
      print 'Chaque Organe Votant doit avoir au moins votÈ une fois pour chaque article d un texte de Loi!'
    
    if @promulgeTexte = 2
      SET @promulgeTexte = 1
    else
      SET @promulgeTexte = 0

  	FETCH cursor_listeArticle
  	INTO @codeSeqArt
  END	

  CLOSE cursor_listeArticle
  DEALLOCATE cursor_listeArticle

  if @promulgeTexte = 0
  begin
  	
  	UPDATE texte
  	SET vote_final_txt = (SELECT vote_final_txt FROM deleted), promulgation_txt = (SELECT promulgation_txt FROM deleted)
  	WHERE code_txt = (SELECT code_txt FROM inserted)
  end
END




/* -----------------------------------------------------------------------

--------------------------- INSERT TABLE --------------------------------------

-----------------------------------------------------------------------
	
USE [SIO2_CasCafonie]
GO

/*
-------------------
   TABLE ROLEWEB
-------------------
*/

INSERT INTO ROLEWEB(code_role_web,lib_role_web) VALUES (1,'SecrÈtaire d …tat')
INSERT INTO ROLEWEB(code_role_web,lib_role_web) VALUES (2,'Greffier')
INSERT INTO ROLEWEB(code_role_web,lib_role_web) VALUES (3,'ModÈrateur')
INSERT INTO ROLEWEB(code_role_web,lib_role_web) VALUES (4,'Monarque')

/*
-------------------
   TABLE UTILISATEUR
-------------------
*/

INSERT INTO UTILISATEUR(code_utilisateur,login,password,code_role_web) VALUES (1,'cristinalorient@gmail.com','be5f28a5f7f765371423d514f06147b2',1) /* secretaire */
INSERT INTO UTILISATEUR(code_utilisateur,login,password,code_role_web) VALUES (2,'jeanmarc@gmail.com','22043b5a5eba81f363218d375fb8e08a',2) /* jeanmarc */
INSERT INTO UTILISATEUR(code_utilisateur,login,password,code_role_web) VALUES (3,'corentincrusson@gmail.com','21232f297a57a5a743894a0e4a801fc3',3) /* admin */
INSERT INTO UTILISATEUR(code_utilisateur,login,password,code_role_web) VALUES (4,'felipesix@gmail.com','df90e13fa7699df8a377946815cf5dc4',4) /* lapin */

/*
-------------------------
  TABLE TYPEINSTITUTION
------------------------
*/

INSERT [dbo].[TYPEINSTITUTION] ([code_type_insti], [lib_type_insti]) VALUES (1, N'exÈcutif                        ')
INSERT [dbo].[TYPEINSTITUTION] ([code_type_insti], [lib_type_insti]) VALUES (2, N'lÈgislatif                      ')
INSERT [dbo].[TYPEINSTITUTION] ([code_type_insti], [lib_type_insti]) VALUES (3, N'judiciaire                      ')
INSERT [dbo].[TYPEINSTITUTION] ([code_type_insti], [lib_type_insti]) VALUES (4, N'vide		                  ')

/*
--------------------
  TABLE INSTITUTION
--------------------
*/

INSERT [dbo].[INSTITUTION] ([code_insti], [nom_insti], [code_type_insti]) VALUES (1, N'PrÈsident                                                                                                                       ', 1)
INSERT [dbo].[INSTITUTION] ([code_insti], [nom_insti], [code_type_insti]) VALUES (2, N'Gouvernement                                                                                                                    ', 1)
INSERT [dbo].[INSTITUTION] ([code_insti], [nom_insti], [code_type_insti]) VALUES (3, N'Parlement                                                                                                                       ', 2)
INSERT [dbo].[INSTITUTION] ([code_insti], [nom_insti], [code_type_insti]) VALUES (4, N'Conseil Constitutionnel                                                                                                         ', 0)
INSERT [dbo].[INSTITUTION] ([code_insti], [nom_insti], [code_type_insti]) VALUES (5, N'Juges                                                                                                                           ', 3)

/*
--------------------
  TABLE ROLE
--------------------
*/

INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (1, N'Peut dissoudre l''AssemblÈe                                                                                                                                                                                                                                     ', 1)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (2, N'Recourir au rÈfÈrendum                                                                                                                                                                                                                                         ', 1)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (3, N'Promulger les lois                                                                                                                                                                                                                                             ', 1)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (4, N'Exercer les pleins pouvoirs en cas de crise                                                                                                                                                                                                                    ', 1)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (5, N'NÈgocier les traitÈs                                                                                                                                                                                                                                           ', 1)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (6, N'DÈfinir la politique de la nation                                                                                                                                                                                                                              ', 2)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (7, N'Conduire la politique de la nation                                                                                                                                                                                                                             ', 2)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (8, N'Voter les lois dans le domaine ÈnumÈrÈ par l''article 34 de la constitutiton                                                                                                                                                                                    ', 3)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (9, N'VÈrifier que les lois adoptÈes par le parlement respectent la constitution                                                                                                                                                                                     ', 4)
INSERT [dbo].[ROLE] ([code_role], [lib_role], [code_insti]) VALUES (10, N'Pouvoir de Sanctionner                                                                                                                                                                                                                                         ', 5)

/*
-----------------
  TABLE ORGANES
-----------------
*/

INSERT [dbo].[ORGANES] ([code_organe], [lib_organe], [nbr_pers_organe]) VALUES (1, N'AssemblÈe Nationale             ', 577)
INSERT [dbo].[ORGANES] ([code_organe], [lib_organe], [nbr_pers_organe]) VALUES (2, N'SÈnat                           ', 321)
INSERT [dbo].[ORGANES] ([code_organe], [lib_organe], [nbr_pers_organe]) VALUES (3, N'Organe Populaire                ', 10)

/*
--------------------
  TABLE COMPRENDRE
--------------------
*/

INSERT [dbo].[COMPRENDRE] ([code_insti], [code_organe]) VALUES (3, 1)
INSERT [dbo].[COMPRENDRE] ([code_insti], [code_organe]) VALUES (3, 2)

/*
--------------------
  TABLE TEXTE
--------------------
*/
SET IDENTITY_INSERT [dbo].[TEXTE] ON 

INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (1, N'LOI 987 - Le DÈconfinement suite au COVID-19', N'ACCEPTE                         ', N'OUI                             ', 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (2, N'Loi de finances rectificative', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (3, N'Loi N∞ 2744', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (4, N'RÈmunÈration des mandataires sociaux des sociÈtÈs cotÈes', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (5, N'Prorogation de líÈtat díurgence sanitaire', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (6, N'Institution d''un systËme universitaire de retraire', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (7, N'La protection patrimoniale des langues rÈgionales et ‡ leur promotion', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (8, N'AmÈlioration de líaccËs ‡ certaines professions des personnes atteintes de maladies chroniques', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (9, N'Modification des modalitÈs de congÈ de deuil pour le dÈcËs díun enfant', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (10, N'Loi relative ‡ la lutte contre le gaspillage et ‡ líÈconomie circulaire.', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (11, N'Loi sur les diverses mesures de justice sociale', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (12, N'Loi amÈliorant líaccËs ‡ la prestation de compensation du handicap', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (13, N'Loi rÈgulant la vie publique', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (14, N'La protection des savoir-faire et des informations commerciales non divulguÈs contre líobtention, líutilisation et la divulgation illicites', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (15, N'Augmentation du pouvoir díachat gr‚ce ‡ la crÈation díun ticket-carburant,', NULL, NULL, 3)
INSERT [dbo].[TEXTE] ([code_txt], [titre_txt], [vote_final_txt], [promulgation_txt], [code_insti]) VALUES (16, N'Loi pour lutter contre la prÈcaritÈ professionnelle des femmes,', NULL, NULL, 3)
SET IDENTITY_INSERT [dbo].[TEXTE] OFF

/*
--------------------
  TABLE ARTICLE
--------------------
*/

SET IDENTITY_INSERT [dbo].[ARTICLE] ON 

INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (1, 1, N'Article 1', N'<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vehicula, magna et mattis dapibus, arcu mi viverra enim, at cursus arcu augue et mi. Duis auctor elementum sapien ac convallis. Nulla facilisi. Phasellus sollicitudin venenatis libero nec bibendum. Vestibulum et rutrum dolor. Curabitur vel sem et massa blandit rhoncus id at arcu. Proin sed dui id turpis accumsan ultrices ac venenatis nunc.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 4, N'Article 1', N'<p>Exon&eacute;ration des sommes vers&eacute;es par le fonds de solidarit&eacute; aux entreprises</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 5, N'Article 2', N'<p>&Eacute;quilibre g&eacute;n&eacute;ral du budget, tr&eacute;sorerie et plafond d&#39;autorisation des emplois</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 6, N'Article 3', N'<p>Budget g&eacute;n&eacute;ral : ouvertures et annulations de cr&eacute;dits</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 7, N'Article 4', N'<p>Comptes sp&eacute;ciaux : ouvertures de cr&eacute;dits</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 8, N'Article 5', N'<p>Exon&eacute;ration d&#39;imp&ocirc;t sur le revenu et de cotisations et contributions sociales de la prime exceptionnelle sp&eacute;cifiquement vers&eacute;e aux agents des administrations publiques mobilis&eacute;s dans le cadre de l&rsquo;&eacute;tat d&rsquo;urgence sanitaire afin de tenir compte de leur surcro&icirc;t de travail significatif durant cette p&eacute;riode</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 9, N'Article 6', N'<p>Rehaussement du plafond d&rsquo;encours maximal de r&eacute;assurance publique d&rsquo;op&eacute;rations d&rsquo;assurance-cr&eacute;dit export de court terme</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 10, N'Article 7', N'<p>Modification du r&eacute;gime d&rsquo;octroi de la garantie de l&rsquo;&Eacute;tat au titre des pr&ecirc;ts consentis par les &eacute;tablissements de cr&eacute;dits et les soci&eacute;t&eacute;s de financement, &agrave; compter du 16 mars 2020 et jusqu&#39;au 31 d&eacute;cembre 2020 inclus, aux entreprises ayant subi un choc brutal en lien avec la crise sanitaire et la contraction de la demande globale</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 11, N'Article 8', N'<p>Augmentation du plafond de garantie par l&#39;&Eacute;tat des emprunts de l&#39;Un&eacute;dic &eacute;mis en 2020</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (2, 12, N'Article 9', N'<p>Garantie par l&#39;&Eacute;tat d&#39;un emprunt de la Collectivit&eacute; de Nouvelle-Cal&eacute;donie octroy&eacute; par l&#39;Agence fran&ccedil;aise de d&eacute;veloppement</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (3, 13, N'Article 1', N'<p>Est autoris&eacute;e la ratification du deuxi&egrave;me protocole additionnel &agrave; la convention europ&eacute;enne d&rsquo;extradition, sign&eacute; &agrave; Strasbourg le 17&nbsp;mars&nbsp;1978, et dont le texte est annex&eacute; &agrave; la pr&eacute;sente loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (3, 14, N'Article 2', N'<p>Est autoris&eacute;e la ratification du troisi&egrave;me protocole additionnel &agrave; la convention europ&eacute;enne d&rsquo;extradition, sign&eacute; &agrave; Strasbourg le 10&nbsp;novembre&nbsp;2010, et dont le texte est annex&eacute; &agrave; la pr&eacute;sente loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (3, 15, N'Article 3', N'<p>Est autoris&eacute;e la ratification du quatri&egrave;me protocole additionnel &agrave; la convention europ&eacute;enne d&rsquo;extradition, sign&eacute; &agrave; Vienne le 20&nbsp;septembre&nbsp;2012, et dont le texte est annex&eacute; &agrave; la pr&eacute;sente loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (4, 16, N'Article Unique', N'<p>L&rsquo;ordonnance n&deg;&nbsp;2019‚??1234 du&nbsp;27&nbsp;novembre&nbsp;2019 relative &agrave; la r&eacute;mun&eacute;ration des mandataires sociaux des soci&eacute;t&eacute;s cot&eacute;es est ratifi&eacute;e.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 17, N'Article 1', N'<p>I.&nbsp;&ndash;&nbsp;(Non modifi&eacute;)&nbsp;</p>

<p>II.&nbsp;&ndash;&nbsp;Avant le dernier alin&eacute;a de l&rsquo;article&nbsp;121-3 du code p&eacute;nal, il est ins&eacute;r&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Pour l&rsquo;application&nbsp;des troisi&egrave;me et quatri&egrave;me alin&eacute;as, il est tenu compte, en cas de catastrophe sanitaire, de l&rsquo;&eacute;tat des connaissances scientifiques au moment des faits.&nbsp;&raquo;</p>

<p>III.&nbsp;&ndash;&nbsp;L&rsquo;ordonnance n&deg;&nbsp;2020‚??303 du&nbsp;25&nbsp;mars&nbsp;2020 portant adaptation de r&egrave;gles de proc&eacute;dure p&eacute;nale sur le fondement de la loi n&deg;&nbsp;2020‚??290 du&nbsp;23&nbsp;mars&nbsp;2020 d&rsquo;urgence pour faire face &agrave; l&rsquo;&eacute;pid&eacute;mie de covid‚??19&nbsp;est&nbsp;ainsi modifi&eacute;e&nbsp;:</p>

<p>1&deg;&nbsp;(nouveau)&nbsp;Le cinqui&egrave;me alin&eacute;a de l&rsquo;article&nbsp;4 est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;:&nbsp;&laquo;&nbsp;Lorsque la d&eacute;tention provisoire d&rsquo;une personne a &eacute;t&eacute; ordonn&eacute;e ou prolong&eacute;e sur le motif pr&eacute;vu au&nbsp;5&deg; et, le cas &eacute;ch&eacute;ant, aux&nbsp;4&deg; et&nbsp;7&deg; de l&rsquo;article&nbsp;144 du m&ecirc;me code, l&rsquo;avocat de la personne mise en examen peut &eacute;galement adresser par courrier &eacute;lectronique au juge d&rsquo;instruction une demande de mise en libert&eacute; si celle‚??ci est motiv&eacute;e par l&rsquo;existence de nouvelles garanties de repr&eacute;sentation de la personne&nbsp;; dans les autres cas, toute demande de mise en libert&eacute; form&eacute;e par &nbsp;courrier &eacute;lectronique est irrecevable&nbsp;; cette irrecevabilit&eacute; est constat&eacute;e par le juge d&rsquo;instruction qui en informe par courrier &eacute;lectronique l&rsquo;avocat et elle n&rsquo;est pas susceptible d&rsquo;appel devant la chambre de l&rsquo;instruction.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;16&nbsp;,&nbsp;il est ins&eacute;r&eacute; un article 16‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;16‚??1.&nbsp;&ndash;&nbsp;&Agrave; compter du&nbsp;11&nbsp;mai&nbsp;2020, la prolongation de plein droit des d&eacute;lais de d&eacute;tention provisoire ou d&rsquo;assignation &agrave; r&eacute;sidence sous surveillance &eacute;lectronique pr&eacute;vue &agrave; l&rsquo;article&nbsp;16 n&rsquo;est plus applicable aux titres de d&eacute;tention dont l&rsquo;&eacute;ch&eacute;ance intervient &agrave; compter de cette date et les d&eacute;tentions ne peuvent &ecirc;tre prolong&eacute;es que par une d&eacute;cision de la juridiction comp&eacute;tente prise apr&egrave;s un d&eacute;bat contradictoire intervenant, le cas &eacute;ch&eacute;ant, selon les modalit&eacute;s pr&eacute;vues &agrave; l&rsquo;article&nbsp;19.</p>

<p>&laquo;&nbsp;Si l&rsquo;&eacute;ch&eacute;ance du titre de d&eacute;tention en cours, r&eacute;sultant des r&egrave;gles de&nbsp;droit commun du code de proc&eacute;dure p&eacute;nale, intervient&nbsp;avant le&nbsp;11&nbsp;juin&nbsp;2020,&nbsp;la juridiction comp&eacute;tente dispose d&rsquo;un d&eacute;lai d&rsquo;un mois&nbsp;&agrave; compter de cette &eacute;ch&eacute;ance pour se prononcer sur sa prolongation, sans qu&rsquo;il en r&eacute;sulte la mise en libert&eacute; de la personne, dont le titre de d&eacute;tention est prorog&eacute; jusqu&rsquo;&agrave; cette d&eacute;cision. Cette prorogation s&rsquo;impute sur la dur&eacute;e de la prolongation d&eacute;cid&eacute;e par la juridiction. En ce qui concerne les d&eacute;lais de d&eacute;tention au cours de l&rsquo;instruction, cette dur&eacute;e est celle pr&eacute;vue par les dispositions de droit commun&nbsp;; toutefois, s&rsquo;il s&rsquo;agit de la derni&egrave;re &eacute;ch&eacute;ance possible, la prolongation peut &ecirc;tre ordonn&eacute;e selon les cas pour les dur&eacute;es pr&eacute;vues &agrave; l&rsquo;article&nbsp;16 de la pr&eacute;sente ordonnance.</p>

<p>&laquo;&nbsp;En ce qui concerne les d&eacute;lais d&rsquo;audiencement, la prolongation peut &ecirc;tre ordonn&eacute;e pour les dur&eacute;es pr&eacute;vues au m&ecirc;me article&nbsp;16, y compris si elle intervient apr&egrave;s le&nbsp;11&nbsp;juin&nbsp;2020.</p>

<p>&laquo;&nbsp;La prolongation de plein droit du d&eacute;lai de d&eacute;tention intervenue au cours de l&rsquo;instruction avant le&nbsp;11&nbsp;mai&nbsp;2020, en application de l&rsquo;article&nbsp;16, n&rsquo;a pas pour effet d&rsquo;allonger la dur&eacute;e maximale totale de la d&eacute;tention en application des dispositions du code de proc&eacute;dure p&eacute;nale, sauf si cette prolongation a port&eacute; sur la derni&egrave;re &eacute;ch&eacute;ance possible.</p>

<p>&laquo;&nbsp;Lorsque la d&eacute;tention provisoire au cours de l&rsquo;instruction a &eacute;t&eacute; prolong&eacute;e de plein droit en application du m&ecirc;me article&nbsp;16 pour une dur&eacute;e de six mois, cette prolongation ne peut maintenir ses effets jusqu&rsquo;&agrave; son terme que par une d&eacute;cision prise par le juge des libert&eacute;s et de la d&eacute;tention selon les modalit&eacute;s pr&eacute;vues &agrave; l&rsquo;article&nbsp;145 du code de proc&eacute;dure p&eacute;nale et, le cas &eacute;ch&eacute;ant, &agrave; l&rsquo;article&nbsp;19 de la pr&eacute;sente ordonnance. La d&eacute;cision doit intervenir au moins trois mois avant le terme de la prolongation. Si une d&eacute;cision de prolongation n&rsquo;intervient pas avant cette date, la personne est remise en libert&eacute; si elle n&rsquo;est pas d&eacute;tenue pour une autre cause.</p>

<p>&laquo;&nbsp;Pour les d&eacute;lais de d&eacute;tention en mati&egrave;re d&rsquo;audiencement, la prolongation&nbsp;de plein droit des d&eacute;lais de d&eacute;tention ou celle d&eacute;cid&eacute;e en application du troisi&egrave;me alin&eacute;a du pr&eacute;sent article a pour effet d&rsquo;allonger la dur&eacute;e maximale totale de la d&eacute;tention possible jusqu&rsquo;&agrave; la date de l&rsquo;audience pr&eacute;vue en application des dispositions du code de proc&eacute;dure p&eacute;nale.</p>

<p>&laquo;&nbsp;Les dispositions du pr&eacute;sent article sont applicables aux assignations &agrave; r&eacute;sidence sous surveillance &eacute;lectronique.&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;(nouveau)&nbsp;Apr&egrave;s l&rsquo;article&nbsp;18, il est ins&eacute;r&eacute; un article&nbsp;18‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;18‚??1.&nbsp;&ndash;&nbsp;Par d&eacute;rogation &agrave; l&rsquo;article&nbsp;148‚??4 du code de proc&eacute;dure p&eacute;nale, la chambre de l&rsquo;instruction peut &ecirc;tre directement saisie d&rsquo;une demande de mise en libert&eacute; lorsque la personne n&rsquo;a pas comparu, dans les deux mois suivant la prolongation de plein droit de la d&eacute;tention provisoire intervenue en application de l&rsquo;article&nbsp;16 de la pr&eacute;sente ordonnance, devant le juge d&rsquo;instruction ou le magistrat par lui d&eacute;l&eacute;gu&eacute;, y compris selon les modalit&eacute;s pr&eacute;vues par l&rsquo;article&nbsp;706‚??71 du code de proc&eacute;dure p&eacute;nale. Le cas &eacute;ch&eacute;ant, la chambre de l&rsquo;instruction statue dans les conditions pr&eacute;vues au premier alin&eacute;a de l&rsquo;article&nbsp;18 de la pr&eacute;sente ordonnance.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 18, N'Article 2', N'<p>1&deg; L&rsquo;article L. 3131‚??15 du code de la sant&eacute; publique est ainsi modifi&eacute; :</p>

<p>1&deg; A Au d&eacute;but du premier alin&eacute;a, est ajout&eacute;e la mention : &laquo; I. &ndash; &raquo; ;</p>

<p>1&deg; Le 1&deg; est ainsi r&eacute;dig&eacute; :</p>

<p>&laquo; 1&deg; R&eacute;glementer ou interdire la circulation des personnes et des v&eacute;hicules et r&eacute;glementer l&rsquo;acc&egrave;s aux moyens de transport et les conditions de leur usage ; &raquo;</p>

<p>2&deg; Le 5&deg; est ainsi r&eacute;dig&eacute; :</p>

<p>&laquo; 5&deg; Ordonner la fermeture provisoire et r&eacute;glementer l&rsquo;ouverture, y compris les conditions d&rsquo;acc&egrave;s et de pr&eacute;sence, d&rsquo;une ou plusieurs cat&eacute;gories d&rsquo;&eacute;tablissements recevant du public ainsi que des lieux de r&eacute;union, en garantissant l&rsquo;acc&egrave;s des personnes aux biens et services de premi&egrave;re n&eacute;cessit&eacute; ; &raquo;</p>

<p>3&deg; La premi&egrave;re phrase du 7&deg; est ainsi r&eacute;dig&eacute;e : &laquo; Ordonner la r&eacute;quisition de toute personne et de tous biens et services n&eacute;cessaires &agrave; la lutte contre la catastrophe sanitaire. &raquo; ;</p>

<p>3&deg; bis (Supprim&eacute;)</p>

<p>4&deg; Apr&egrave;s le 10&deg;, il est ins&eacute;r&eacute; un II ainsi r&eacute;dig&eacute; :</p>

<p>&laquo; II. &ndash; Les mesures pr&eacute;vues aux 3&deg; et 4&deg; du I du pr&eacute;sent article ayant pour objet la mise en quarantaine, le placement et le maintien en isolement ne peuvent viser que les personnes qui, ayant s&eacute;journ&eacute; au cours du mois pr&eacute;c&eacute;dent dans une zone de circulation de l&rsquo;infection, entrent sur le territoire national, arrivent en Corse ou dans l&rsquo;une des collectivit&eacute;s mentionn&eacute;es &agrave; l&rsquo;article 72‚??3 de la Constitution. La liste des zones de circulation de l&rsquo;infection est fix&eacute;e par arr&ecirc;t&eacute; du ministre charg&eacute; de la sant&eacute;. Elle fait l&rsquo;objet d&rsquo;une information publique r&eacute;guli&egrave;re pendant toute la dur&eacute;e de l&rsquo;&eacute;tat d&rsquo;urgence sanitaire.</p>

<p>&laquo; Aux seules fins d&rsquo;assurer la mise en &oelig;uvre des mesures mentionn&eacute;es au premier alin&eacute;a du pr&eacute;sent II, les entreprises de transport ferroviaire, maritime ou a&eacute;rien communiquent au repr&eacute;sentant de l&rsquo;&Eacute;tat dans le d&eacute;partement qui en fait la demande les donn&eacute;es relatives aux passagers concernant les d&eacute;placements mentionn&eacute;s au m&ecirc;me premier alin&eacute;a.</p>

<p>&laquo; Les mesures de mise en quarantaine, de placement et de maintien en isolement peuvent se d&eacute;rouler, au choix des personnes qui en font l&rsquo;objet, &agrave; leur domicile ou dans les lieux d&rsquo;h&eacute;bergement adapt&eacute;.</p>

<p>&laquo; Leur dur&eacute;e initiale ne peut exc&eacute;der quatorze jours. Les mesures peuvent &ecirc;tre renouvel&eacute;es, dans les conditions pr&eacute;vues au III de l&rsquo;article L. 3131‚??17, dans la limite d&rsquo;une dur&eacute;e maximale d&rsquo;un mois. Il y est mis fin avant leur terme lorsque l&rsquo;&eacute;tat de sant&eacute; de l&rsquo;int&eacute;ress&eacute; le permet.</p>

<p>&laquo; Les enfants victimes de violences ne peuvent &ecirc;tre mis en quarantaine, plac&eacute;s ou maintenus en isolement, ou &ecirc;tre amen&eacute;s &agrave; cohabiter dans le m&ecirc;me domicile que l&rsquo;auteur de ces violences lorsque celui-ci est mis en quarantaine, plac&eacute; ou maintenu en isolement, y compris dans le cas o&ugrave; ces violences sont all&eacute;gu&eacute;es. Si l&rsquo;&eacute;viction de l&rsquo;auteur des violences ne peut &ecirc;tre ex&eacute;cut&eacute;e, un lieu d&rsquo;h&eacute;bergement permettant le respect de leur vie priv&eacute;e et familiale leur est attribu&eacute;.</p>

<p>&laquo; Les victimes des violences mentionn&eacute;es &agrave; l&rsquo;article 132‚??80 du code p&eacute;nal, y compris les b&eacute;n&eacute;ficiaires d&rsquo;une ordonnance de protection pr&eacute;vue aux articles 515‚??9 &agrave; 515‚??13 du code civil, ne peuvent &ecirc;tre mises en quarantaine, plac&eacute;es ou maintenues en isolement dans le m&ecirc;me domicile que l&rsquo;auteur des violences, y compris si les violences sont all&eacute;gu&eacute;es. Si l&rsquo;&eacute;viction du conjoint violent ne peut &ecirc;tre ex&eacute;cut&eacute;e, un lieu d&rsquo;h&eacute;bergement permettant le respect de leur vie priv&eacute;e et familiale leur est attribu&eacute;.</p>

<p>&laquo; Dans le cadre des mesures de mise en quarantaine, de placement et de maintien en isolement, il peut &ecirc;tre fait obligation &agrave; la personne qui en fait l&rsquo;objet de :</p>

<p>&laquo; 1&deg; Ne pas sortir de son domicile ou du lieu d&rsquo;h&eacute;bergement o&ugrave; elle ex&eacute;cute la mesure, sous r&eacute;serve des d&eacute;placements qui lui sont sp&eacute;cifiquement autoris&eacute;s par l&rsquo;autorit&eacute; administrative. Dans le cas o&ugrave; un isolement complet de la personne est prononc&eacute;, il lui est garanti un acc&egrave;s aux biens et services de premi&egrave;re n&eacute;cessit&eacute; ainsi qu&rsquo;&agrave; des moyens de communication t&eacute;l&eacute;phonique et &eacute;lectronique lui permettant de communiquer librement avec l&rsquo;ext&eacute;rieur ;</p>

<p>&laquo; 2&deg; Ne pas fr&eacute;quenter certains lieux ou cat&eacute;gories de lieux.</p>

<p>&laquo; Les conditions d&rsquo;application du pr&eacute;sent II sont fix&eacute;es par le d&eacute;cret pr&eacute;vu au premier alin&eacute;a du I, en fonction de la nature et des modes de propagation du virus, apr&egrave;s avis du comit&eacute; de scientifiques mentionn&eacute; &agrave; l&rsquo;article L. 3131‚??19. Ce d&eacute;cret pr&eacute;cise &eacute;galement les conditions dans lesquelles sont assur&eacute;s l&rsquo;information r&eacute;guli&egrave;re de la personne qui fait l&rsquo;objet de ces mesures, la poursuite de la vie familiale, la prise en compte de la situation des mineurs ainsi que le suivi m&eacute;dical qui accompagne ces mesures. &raquo; ;</p>

<p>5&deg; Le dernier alin&eacute;a est ainsi modifi&eacute; :</p>

<p>a) Au d&eacute;but, est ajout&eacute;e la mention : &laquo; III. &ndash; &raquo; ;</p>

<p>b) Les mots : &laquo; des 1&deg; &agrave; 10&deg; &raquo; sont supprim&eacute;s.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 19, N'Article 3', N'<p>L&rsquo;article L.&nbsp;3131‚??17 du code de la sant&eacute; publique est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Au d&eacute;but du premier alin&eacute;a, est ajout&eacute;e la mention&nbsp;: &laquo;&nbsp;I.&nbsp;&ndash;&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;&Agrave; la premi&egrave;re phrase du deuxi&egrave;me alin&eacute;a, les r&eacute;f&eacute;rences&nbsp;: &laquo;&nbsp;1&deg; &agrave;&nbsp;9&deg;&nbsp;&raquo; sont remplac&eacute;es par les r&eacute;f&eacute;rences&nbsp;: &laquo;&nbsp;1&deg;,&nbsp;2&deg; et&nbsp;5&deg; &agrave;&nbsp;9&deg; du&nbsp;I&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;Apr&egrave;s le m&ecirc;me deuxi&egrave;me alin&eacute;a, il est ins&eacute;r&eacute; un&nbsp;II ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Les mesures individuelles ayant pour objet la mise en quarantaine et les mesures de placement et de maintien en isolement sont prononc&eacute;es par d&eacute;cision individuelle motiv&eacute;e du repr&eacute;sentant de l&rsquo;&Eacute;tat dans le d&eacute;partement sur proposition du directeur g&eacute;n&eacute;ral de l&rsquo;agence r&eacute;gionale de sant&eacute;. Cette d&eacute;cision mentionne les voies et d&eacute;lais de recours ainsi que les modalit&eacute;s de saisine du juge des libert&eacute;s et de la d&eacute;tention.</p>

<p>&laquo;&nbsp;Le placement et le maintien en isolement sont subordonn&eacute;s &agrave; la constatation m&eacute;dicale de l&rsquo;infection de la personne concern&eacute;e. Ils sont prononc&eacute;s par le repr&eacute;sentant de l&rsquo;&Eacute;tat dans le d&eacute;partement au vu d&rsquo;un certificat m&eacute;dical.</p>

<p>&laquo;&nbsp;Les mesures mentionn&eacute;es au premier alin&eacute;a du pr&eacute;sent&nbsp;II peuvent &agrave; tout moment faire l&rsquo;objet d&rsquo;un recours par la personne qui en fait l&rsquo;objet devant le juge des libert&eacute;s et de la d&eacute;tention dans le ressort duquel se situe le lieu de sa quarantaine ou de son isolement, en vue de la mainlev&eacute;e de la mesure. Ce juge des libert&eacute;s et de la d&eacute;tention peut &eacute;galement &ecirc;tre saisi par le procureur de la R&eacute;publique territorialement comp&eacute;tent ou se saisir d&rsquo;office &agrave; tout moment. Il statue dans un d&eacute;lai de soixante‚??douze&nbsp;heures par une ordonnance motiv&eacute;e imm&eacute;diatement ex&eacute;cutoire.</p>

<p>&laquo;&nbsp;Les mesures mentionn&eacute;es au m&ecirc;me premier alin&eacute;a ne peuvent &ecirc;tre prolong&eacute;es au&nbsp;del&agrave; d&rsquo;un d&eacute;lai de quatorze&nbsp;jours qu&rsquo;apr&egrave;s avis m&eacute;dical &eacute;tablissant la n&eacute;cessit&eacute; de cette prolongation.</p>

<p>&laquo;&nbsp;Lorsque la mesure interdit toute sortie de l&rsquo;int&eacute;ress&eacute; hors du lieu o&ugrave; la quarantaine ou l&rsquo;isolement se d&eacute;roule, elle ne peut se poursuivre au&nbsp;del&agrave; d&rsquo;un d&eacute;lai de quatorze&nbsp;jours sans que le juge des libert&eacute;s et de la d&eacute;tention, pr&eacute;alablement saisi par le repr&eacute;sentant de l&rsquo;&Eacute;tat dans le d&eacute;partement, ait autoris&eacute; cette prolongation.</p>

<p>&laquo;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat pr&eacute;cise les conditions d&rsquo;application du pr&eacute;sent&nbsp;II. Ce d&eacute;cret pr&eacute;cise &eacute;galement les conditions d&rsquo;information r&eacute;guli&egrave;re de la personne qui fait l&rsquo;objet de ces mesures.&nbsp;&raquo;&nbsp;;</p>

<p>4&deg;&nbsp;Au d&eacute;but du dernier alin&eacute;a, est ajout&eacute;e la mention&nbsp;: &laquo;&nbsp;III.&nbsp;&ndash;&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 20, N'Article 4', N'<p>Conforme</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 21, N'Article 5', N'<p>L&rsquo;article L.&nbsp;3136‚??1 du code de la sant&eacute; publique est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;(nouveau)&nbsp;Apr&egrave;s le quatri&egrave;me alin&eacute;a, il est ins&eacute;r&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Les agents mentionn&eacute;s aux&nbsp;1&deg;,&nbsp;1&deg;&nbsp;bis&nbsp;et&nbsp;1&deg;&nbsp;ter&nbsp;de l&rsquo;article&nbsp;21 du code&nbsp;de proc&eacute;dure p&eacute;nale peuvent constater par proc&egrave;s‚??verbaux les contraventions&nbsp;pr&eacute;vues au troisi&egrave;me alin&eacute;a du pr&eacute;sent article lorsqu&rsquo;elles ne n&eacute;cessitent pas de leur part d&rsquo;actes d&rsquo;enqu&ecirc;te.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Avant le dernier alin&eacute;a, sont ins&eacute;r&eacute;s trois&nbsp;alin&eacute;as ainsi r&eacute;dig&eacute;s&nbsp;:</p>

<p>&laquo;&nbsp;Les agents mentionn&eacute;s aux&nbsp;4&deg;,&nbsp;5&deg; et&nbsp;7&deg; du&nbsp;I de l&rsquo;article L.&nbsp;2241‚??1 du code des transports peuvent &eacute;galement constater par proc&egrave;s‚??verbaux les contraventions pr&eacute;vues au troisi&egrave;me alin&eacute;a du pr&eacute;sent article consistant en la violation des interdictions ou obligations &eacute;dict&eacute;es en application du&nbsp;1&deg; du&nbsp;I de l&rsquo;article L.&nbsp;3131‚??15 du pr&eacute;sent code en mati&egrave;re d&rsquo;usage des services de transport ferroviaire ou guid&eacute; et de transport public routier de personnes, lorsqu&rsquo;elles sont commises dans les v&eacute;hicules et emprises immobili&egrave;res de ces services. Les articles L.&nbsp;2241‚??2, L.&nbsp;2241‚??6 et L.&nbsp;2241‚??7 du code des transports sont applicables.</p>

<p>&laquo;&nbsp;Les agents mentionn&eacute;s au&nbsp;II de l&rsquo;article L.&nbsp;450‚??1 du code de commerce&nbsp;sont habilit&eacute;s &agrave; rechercher et constater les infractions aux mesures prises en application des&nbsp;8&deg; et&nbsp;10&deg; du&nbsp;I de l&rsquo;article L.&nbsp;3131‚??15 du pr&eacute;sent code dans les conditions pr&eacute;vues au livre&nbsp;IV du code de commerce.</p>

<p>&laquo;&nbsp;Les personnes mentionn&eacute;es au&nbsp;11&deg; de l&rsquo;article L.&nbsp;5222‚??1 du code des&nbsp;transports peuvent &eacute;galement constater par proc&egrave;s‚??verbaux les contraventions&nbsp;pr&eacute;vues au troisi&egrave;me alin&eacute;a du pr&eacute;sent article consistant en la violation des interdictions ou obligations &eacute;dict&eacute;es en application du&nbsp;1&deg; du&nbsp;I de l&rsquo;article L.&nbsp;3131‚??15 du pr&eacute;sent code en mati&egrave;re de transport maritime, lorsqu&rsquo;elles sont commises par un passager &agrave; bord d&rsquo;un navire.&nbsp;&raquo;</p>

<p>Article 5&nbsp;bis&nbsp;A&nbsp;(nouveau)</p>

<p>I.&nbsp;&ndash;&nbsp;Pour l&rsquo;ann&eacute;e&nbsp;2020, la p&eacute;riode mentionn&eacute;e au troisi&egrave;me alin&eacute;a de l&rsquo;article L.&nbsp;115‚??3 du code de l&rsquo;action sociale et des familles et au premier alin&eacute;a de l&rsquo;article L.&nbsp;412‚??6 du code des proc&eacute;dures civiles d&rsquo;ex&eacute;cution est prolong&eacute;e jusqu&rsquo;au 10&nbsp;juillet&nbsp;2020 inclus.</p>

<p>II.&nbsp;&ndash;&nbsp;Pour l&rsquo;ann&eacute;e&nbsp;2020, les dur&eacute;es mentionn&eacute;es aux articles L.&nbsp;611‚??1 et L.&nbsp;641‚??8 du code des proc&eacute;dures civiles d&rsquo;ex&eacute;cution sont augment&eacute;es de quatre mois. Pour la m&ecirc;me ann&eacute;e, les dur&eacute;es mentionn&eacute;es aux articles L.&nbsp;621‚??4 et L.&nbsp;631‚??6 du m&ecirc;me code sont augment&eacute;es de deux mois.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 25, N'Article 5', N'<p>I.&nbsp;&ndash;&nbsp;Par d&eacute;rogation &agrave; l&rsquo;article L.&nbsp;1110‚??4 du code de la sant&eacute; publique, aux seules fins de lutter contre la propagation de l&rsquo;&eacute;pid&eacute;mie de covid‚??19 et pour la dur&eacute;e strictement n&eacute;cessaire &agrave; cet objectif ou, au plus, pour une dur&eacute;e de neuf&nbsp;mois &agrave; compter de la publication de la pr&eacute;sente loi, des donn&eacute;es &agrave; caract&egrave;re personnel concernant la sant&eacute; relatives aux personnes atteintes par ce virus et aux personnes ayant &eacute;t&eacute; en contact avec elles peuvent &ecirc;tre trait&eacute;es et partag&eacute;es, le cas &eacute;ch&eacute;ant sans le consentement des personnes int&eacute;ress&eacute;es, dans le cadre d&rsquo;un syst&egrave;me d&rsquo;information cr&eacute;&eacute; par d&eacute;cret en Conseil d&rsquo;&Eacute;tat et mis en &oelig;uvre par le ministre charg&eacute; de la sant&eacute;.&nbsp;Le directeur g&eacute;n&eacute;ral de l&rsquo;union nationale des caisses d&rsquo;assurance maladie mentionn&eacute;e &agrave; l&rsquo;article L.&nbsp;182‚??2 du code de la s&eacute;curit&eacute; sociale peut, en tant que de besoin, fixer les modalit&eacute;s de r&eacute;mun&eacute;ration des professionnels de sant&eacute; conventionn&eacute;s participant &agrave; la collecte des donn&eacute;es n&eacute;cessaires au fonctionnement des syst&egrave;mes d&rsquo;information mis en &oelig;uvre pour lutter contre l&rsquo;&eacute;pid&eacute;mie. La collecte de ces donn&eacute;es ne peut faire l&rsquo;objet d&rsquo;une r&eacute;mun&eacute;ration li&eacute;e au nombre et &agrave; la compl&eacute;tude des donn&eacute;es recens&eacute;es pour chaque personne enregistr&eacute;e. La prorogation du syst&egrave;me d&rsquo;information au&nbsp;del&agrave; de la dur&eacute;e pr&eacute;vue au pr&eacute;sent alin&eacute;a ne peut &ecirc;tre autoris&eacute;e que par la&nbsp;loi.</p>

<p>Le ministre charg&eacute; de la sant&eacute; ainsi que l&rsquo;Agence nationale de sant&eacute; publique, un organisme d&rsquo;assurance maladie et les agences r&eacute;gionales de sant&eacute; peuvent en outre, aux m&ecirc;mes fins et pour la m&ecirc;me dur&eacute;e, &ecirc;tre autoris&eacute;s par d&eacute;cret en Conseil d&rsquo;&Eacute;tat &agrave; adapter les syst&egrave;mes d&rsquo;information existants et &agrave; pr&eacute;voir le partage des m&ecirc;mes donn&eacute;es dans les m&ecirc;mes conditions que celles pr&eacute;vues au premier alin&eacute;a du pr&eacute;sent&nbsp;I.</p>

<p>Les donn&eacute;es &agrave; caract&egrave;re personnel collect&eacute;es par ces syst&egrave;mes d&rsquo;information &agrave; ces fins ne peuvent &ecirc;tre conserv&eacute;es &agrave; l&rsquo;issue de cette dur&eacute;e.</p>

<p>Les donn&eacute;es &agrave; caract&egrave;re personnel concernant la sant&eacute; sont strictement limit&eacute;es au statut virologique ou s&eacute;rologique de la personne &agrave; l&rsquo;&eacute;gard du virus mentionn&eacute; au pr&eacute;sent&nbsp;I ainsi qu&rsquo;&agrave; des &eacute;l&eacute;ments probants de diagnostic clinique et d&rsquo;imagerie m&eacute;dicale, pr&eacute;cis&eacute;s par&nbsp;le d&eacute;cret en Conseil d&rsquo;Etat pr&eacute;vu au pr&eacute;sent&nbsp;I.</p>

<p>Le d&eacute;cret en Conseil d&rsquo;&Eacute;tat pr&eacute;vu au pr&eacute;sent&nbsp;I pr&eacute;cise les&nbsp;modalit&eacute;s d&rsquo;exercice des droits d&rsquo;acc&egrave;s, d&rsquo;information, d&rsquo;opposition et de rectification&nbsp;des personnes concern&eacute;es, atteintes par le virus ou en contact avec celles‚??ci, lorsque leurs donn&eacute;es personnelles sont collect&eacute;es dans ces syst&egrave;mes d&rsquo;information &agrave; l&rsquo;initiative de tiers.</p>

<p>II.&nbsp;&ndash;&nbsp;Les syst&egrave;mes d&rsquo;information mentionn&eacute;s au&nbsp;I ont pour finalit&eacute;s&nbsp;:</p>

<p>1&deg;&nbsp;L&rsquo;identification des personnes infect&eacute;es, par la prescription et la r&eacute;alisation des examens de biologie ou d&rsquo;imagerie m&eacute;dicale pertinents&nbsp;ainsi que par la collecte de leurs r&eacute;sultats, y compris non positifs, ou par la transmission des &eacute;l&eacute;ments probants de diagnostic clinique susceptibles de caract&eacute;riser l&rsquo;infection mentionn&eacute;s au m&ecirc;me&nbsp;I. Elle est renseign&eacute;e par ou sous l&rsquo;autorit&eacute; d&rsquo;un m&eacute;decin ou d&rsquo;un biologiste, dans le respect de leur devoir d&rsquo;information &agrave; l&rsquo;&eacute;gard des patients&nbsp;;</p>

<p>2&deg;&nbsp;L&rsquo;identification des personnes pr&eacute;sentant un risque d&rsquo;infection, par&nbsp;la collecte des informations relatives aux contacts des personnes infect&eacute;es et, le cas &eacute;ch&eacute;ant, par la r&eacute;alisation d&rsquo;enqu&ecirc;tes sanitaires, en pr&eacute;sence notamment&nbsp;de cas group&eacute;s&nbsp;;3&deg;&nbsp;L&rsquo;orientation des personnes infect&eacute;es, et des personnes susceptibles de l&rsquo;&ecirc;tre, en fonction de leur situation, vers des prescriptions m&eacute;dicales&nbsp;d&rsquo;isolement prophylactiques, ainsi que l&rsquo;accompagnement&nbsp;de ces personnes pendant et apr&egrave;s la fin de ces mesures&nbsp;;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 27, N'Article 5 - Suite', N'<p>4&deg;&nbsp;La surveillance &eacute;pid&eacute;miologique aux niveaux national et local, ainsi que la recherche sur le virus et les moyens de lutter contre sa propagation, sous r&eacute;serve, en cas de collecte d&rsquo;informations, de supprimer les nom et pr&eacute;noms des personnes, leur num&eacute;ro d&rsquo;inscription au r&eacute;pertoire national d&rsquo;identification des personnes physiques et leur adresse.</p>

<p>Les donn&eacute;es d&rsquo;identification des personnes infect&eacute;es ne peuvent &ecirc;tre communiqu&eacute;es &agrave; tout tiers, y compris aux personnes ayant &eacute;t&eacute; en contact avec elles, sauf accord expr&egrave;s de la personne.</p>

<p>Sont exclus de ces finalit&eacute;s le d&eacute;veloppement ou le d&eacute;ploiement d&rsquo;une&nbsp;application informatique &agrave; destination du public et disponible sur &eacute;quipement&nbsp;mobile permettant d&rsquo;informer les personnes du fait qu&rsquo;elles ont &eacute;t&eacute; &agrave; proximit&eacute; de personnes diagnostiqu&eacute;es positives au covid‚??19.</p>

<p>III.&nbsp;&ndash;&nbsp;Outre les autorit&eacute;s mentionn&eacute;es au&nbsp;I, le service de sant&eacute; des arm&eacute;es,&nbsp;les communaut&eacute;s professionnelles territoriales de sant&eacute;, les &eacute;tablissements de sant&eacute;, sociaux et m&eacute;dico‚??sociaux, les &eacute;quipes de soins primaires mentionn&eacute;es&nbsp;&agrave; l&rsquo;article L.&nbsp;1411‚??11‚??1 du code de la sant&eacute; publique, les maisons de sant&eacute;, les centres de sant&eacute;, les services de sant&eacute; au travail mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;4622‚??1 du code du travail et les m&eacute;decins prenant en charge les&nbsp;personnes concern&eacute;es, les pharmaciens, les dispositifs d&rsquo;appui &agrave; la coordination&nbsp;des parcours de sant&eacute; complexes pr&eacute;vus &agrave; l&rsquo;article L.&nbsp;6327‚??1 du code de la sant&eacute; publique, les dispositifs sp&eacute;cifiques r&eacute;gionaux pr&eacute;vus &agrave; l&rsquo;article L.&nbsp;6327‚??6 du m&ecirc;me code, les dispositifs d&rsquo;appui existants qui ont vocation &agrave; les int&eacute;grer mentionn&eacute;s au&nbsp;II de l&rsquo;article&nbsp;23 de la loi&nbsp;n&deg;&nbsp;2019‚??774 du&nbsp;24&nbsp;juillet&nbsp;2019 relative &agrave; l&rsquo;organisation et &agrave; la transformation du syst&egrave;me de sant&eacute; ainsi que les laboratoires et services autoris&eacute;s &agrave; r&eacute;aliser les examens de biologie ou d&rsquo;imagerie m&eacute;dicale pertinents sur les personnes concern&eacute;es participent &agrave; la mise en &oelig;uvre de ces syst&egrave;mes d&rsquo;information et peuvent, dans la stricte mesure o&ugrave; leur intervention sert les finalit&eacute;s d&eacute;finies au&nbsp;II du pr&eacute;sent article, avoir acc&egrave;s aux seules donn&eacute;es n&eacute;cessaires &agrave; leur intervention. Les organismes qui assurent l&rsquo;accompagnement social des int&eacute;ress&eacute;s dans le cadre de la lutte contre la propagation de l&rsquo;&eacute;pid&eacute;mie peuvent recevoir les donn&eacute;es strictement n&eacute;cessaires &agrave; l&rsquo;exercice de leur mission. Les personnes ayant acc&egrave;s &agrave; cette base de donn&eacute;es sont soumises au secret professionnel. En cas de r&eacute;v&eacute;lation d&rsquo;une information issue des donn&eacute;es collect&eacute;es dans ce syst&egrave;me d&rsquo;information, elles encourent les peines pr&eacute;vues &agrave; l&rsquo;article&nbsp;226‚??13 du code p&eacute;nal.</p>

<p>III&nbsp;bis&nbsp;(nouveau).&nbsp;&ndash;&nbsp;L&rsquo;inscription d&rsquo;une personne dans le syst&egrave;me de suivi des personnes contacts emporte prescription pour la r&eacute;alisation et le remboursement des tests effectu&eacute;s en laboratoires de biologie m&eacute;dicale, par exception &agrave; l&rsquo;article L.&nbsp;6211‚??8 du code de la sant&eacute; publique, ainsi que pour la d&eacute;livrance de masque en officine.</p>

<p>IV.&nbsp;&ndash;&nbsp;Les modalit&eacute;s d&rsquo;application du pr&eacute;sent article sont fix&eacute;es par les&nbsp;d&eacute;crets en Conseil d&rsquo;&Eacute;tat mentionn&eacute;s&nbsp;au&nbsp;I apr&egrave;s avis public de la Commission&nbsp;nationale de l&rsquo;informatique et des libert&eacute;s. Ces d&eacute;crets en Conseil d&rsquo;&Eacute;tat pr&eacute;cisent notamment, pour chaque autorit&eacute; ou organisme mentionn&eacute; aux&nbsp;I et&nbsp;III, les services ou personnels dont les interventions sont n&eacute;cessaires aux finalit&eacute;s mentionn&eacute;es au&nbsp;II et les cat&eacute;gories de donn&eacute;es auxquelles ils ont acc&egrave;s, la dur&eacute;e de cet acc&egrave;s, les r&egrave;gles de conservation des donn&eacute;es ainsi que les organismes auxquels ils peuvent faire appel, pour leur compte et sous leur responsabilit&eacute;, pour en assurer le traitement, dans la mesure o&ugrave; les finalit&eacute;s mentionn&eacute;es au m&ecirc;me&nbsp;II le justifient, et les modalit&eacute;s encadrant le recours &agrave; la sous‚??traitance.</p>

<p>IV&nbsp;bis&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Le covid‚??19 fait l&rsquo;objet de la transmission obligatoire&nbsp;des donn&eacute;es individuelles &agrave; l&rsquo;autorit&eacute; sanitaire par les m&eacute;decins et les responsables des services et laboratoires de biologie m&eacute;dicale publics et priv&eacute;s pr&eacute;vue &agrave; l&rsquo;article L.&nbsp;3113‚??1 du code de la sant&eacute; publique. Cette transmission est assur&eacute;e au moyen des syst&egrave;mes d&rsquo;information mentionn&eacute;s au pr&eacute;sent article.V.&nbsp;&ndash;&nbsp;(Supprim&eacute;)</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 28, N'Article 7', N'<p>I.&nbsp;&ndash;&nbsp;Le livre&nbsp;VIII de la troisi&egrave;me partie du code de la sant&eacute; publique est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;L&rsquo;article L.&nbsp;3821‚??11 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Au premier alin&eacute;a, la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;n&deg;&nbsp;2020‚??290 du&nbsp;23&nbsp;mars&nbsp;2020 d&rsquo;urgence pour faire face &agrave; l&rsquo;&eacute;pid&eacute;mie de covid‚??19&nbsp;&raquo; est remplac&eacute;e par la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire et compl&eacute;tant ses dispositions&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Au premier alin&eacute;a du&nbsp;3&deg;, la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;deuxi&egrave;me alin&eacute;a&nbsp;&raquo; est remplac&eacute;e par la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;second alin&eacute;a du&nbsp;I&nbsp;&raquo;&nbsp;;</p>

<p>c)&nbsp;(Supprim&eacute;)</p>

<p>2&deg;&nbsp;Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;IV est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;L&rsquo;article L.&nbsp;3841‚??2 est ainsi modifi&eacute;&nbsp;:</p>

<p>&ndash;&nbsp;au premier alin&eacute;a, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;fran&ccedil;aise&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;dans sa r&eacute;daction r&eacute;sultant de la loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire et compl&eacute;tant ses dispositions&nbsp;&raquo;&nbsp;;</p>

<p>&ndash;&nbsp;au premier alin&eacute;a du&nbsp;2&deg;, apr&egrave;s la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;premier alin&eacute;a&nbsp;&raquo;, est ins&eacute;r&eacute;e la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;du&nbsp;I&nbsp;&raquo;&nbsp;;</p>

<p>&ndash;&nbsp;au dernier alin&eacute;a du m&ecirc;me&nbsp;2&deg;, les r&eacute;f&eacute;rences&nbsp;: &laquo;&nbsp;1&deg; &agrave;&nbsp;9&deg;&nbsp;&raquo; sont remplac&eacute;es par les r&eacute;f&eacute;rences&nbsp;: &laquo;&nbsp;1&deg;,&nbsp;2&deg; et&nbsp;5&deg; &agrave;&nbsp;9&deg; du&nbsp;I&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Au premier alin&eacute;a de l&rsquo;article L.&nbsp;3841‚??3, la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;n&deg;&nbsp;2020‚??290&nbsp;du&nbsp;23&nbsp;mars&nbsp;2020 d&rsquo;urgence pour faire face &agrave; l&rsquo;&eacute;pid&eacute;mie de covid‚??19&nbsp;&raquo; est&nbsp;remplac&eacute;e par la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire&nbsp;et compl&eacute;tant ses dispositions&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;(nouveau)&nbsp;L&rsquo;article L.&nbsp;3845‚??1 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Les r&eacute;f&eacute;rences&nbsp;: &laquo;&nbsp;,&nbsp;L.&nbsp;3115‚??7 et L.&nbsp;3115‚??10&nbsp;&raquo; sont remplac&eacute;es par la r&eacute;f&eacute;rence&nbsp;: &laquo;&nbsp;et L.&nbsp;3115‚??7&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Il est ajout&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;L&rsquo;article L.&nbsp;3115‚??10 est applicable en Nouvelle‚??Cal&eacute;donie et en&nbsp;Polyn&eacute;sie fran&ccedil;aise dans sa r&eacute;daction r&eacute;sultant de la loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire et compl&eacute;tant ses dispositions, sous r&eacute;serve des adaptations pr&eacute;vues au pr&eacute;sent chapitre.&nbsp;&raquo;</p>

<p>II&nbsp;(nouveau).&nbsp;&ndash;&nbsp;L&rsquo;article&nbsp;711‚??1 du code p&eacute;nal est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;711‚??1.&nbsp;&ndash;&nbsp;Sous r&eacute;serve des adaptations pr&eacute;vues au pr&eacute;sent titre, les livres&nbsp;Ier&nbsp;&agrave;&nbsp;V sont applicables en Nouvelle‚??Cal&eacute;donie, en Polyn&eacute;sie fran&ccedil;aise et dans les &icirc;les Wallis et Futuna dans leur r&eacute;daction r&eacute;sultant de la loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire et compl&eacute;tant ses dispositions.&nbsp;&raquo;</p>

<p>III&nbsp;(nouveau).&nbsp;&ndash;&nbsp;&Agrave; l&rsquo;article&nbsp;2 de l&rsquo;ordonnance n&deg;&nbsp;2020‚??303 du&nbsp;25&nbsp;mars&nbsp;2020&nbsp;portant&nbsp;adaptation de r&egrave;gles de proc&eacute;dure p&eacute;nale sur le fondement de la loi&nbsp;n&deg;&nbsp;2020‚??290&nbsp;du&nbsp;23&nbsp;mars&nbsp;2020 d&rsquo;urgence pour faire face &agrave; l&rsquo;&eacute;pid&eacute;mie de covid‚??19, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;ordonnance&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;,&nbsp;dans sa r&eacute;daction r&eacute;sultant de la loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prorogeant l&rsquo;&eacute;tat d&rsquo;urgence sanitaire et compl&eacute;tant ses dispositions&nbsp;&raquo;.</p>

<p>IV&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Par d&eacute;rogation au troisi&egrave;me alin&eacute;a du&nbsp;II de l&rsquo;article L.&nbsp;3131‚??15 du code de la sant&eacute; publique, le lieu o&ugrave; est effectu&eacute;e la&nbsp;quarantaine par les personnes entrant dans l&rsquo;une des collectivit&eacute;s mentionn&eacute;es&nbsp;&agrave; l&rsquo;article&nbsp;72‚??3 de la Constitution est d&eacute;cid&eacute; par le repr&eacute;sentant de l&rsquo;&Eacute;tat.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (5, 29, N'Article 8', N'<p>Le&nbsp;4&deg; de l&rsquo;article&nbsp;2 et le&nbsp;3&deg; de l&rsquo;article&nbsp;3 entrent en vigueur &agrave; compter de&nbsp;la publication du d&eacute;cret mentionn&eacute; au&nbsp;m&ecirc;me&nbsp;3&deg;,&nbsp;et au plus tard le&nbsp;15&nbsp;juin&nbsp;2020.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 30, N'Article 1', N'<p>I.&nbsp;&ndash;&nbsp;Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;Ier&nbsp;du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Apr&egrave;s l&rsquo;article L.&nbsp;111‚??2‚??1, il est ins&eacute;r&eacute; un article L.&nbsp;111‚??2‚??1‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;111‚??2‚??1‚??1.&nbsp;&ndash;&nbsp;La Nation affirme solennellement son attachement&nbsp;&agrave; un syst&egrave;me universel de retraite qui, par son caract&egrave;re obligatoire et le choix d&rsquo;un financement par r&eacute;partition, exprime la solidarit&eacute; entre les g&eacute;n&eacute;rations, unies dans un pacte social.</p>

<p>&laquo;&nbsp;La Nation assigne au syst&egrave;me universel de retraite les objectifs suivants&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Un objectif d&rsquo;&eacute;quit&eacute;, afin de garantir aux assur&eacute;s que chaque euro&nbsp;cotis&eacute; ouvre les m&ecirc;mes droits pour tous dans les conditions d&eacute;finies par la loi&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Un objectif de solidarit&eacute;, au sein de chaque g&eacute;n&eacute;ration, notamment&nbsp;par la r&eacute;sorption des &eacute;carts de retraites entre les femmes et les hommes, par la prise en compte des p&eacute;riodes d&rsquo;interruption et de r&eacute;duction d&rsquo;activit&eacute; et&nbsp;de l&rsquo;impact sur la carri&egrave;re des parents de l&rsquo;arriv&eacute;e et de l&rsquo;&eacute;ducation d&rsquo;enfants&nbsp;ou de l&rsquo;aide apport&eacute;e en tant qu&rsquo;aidant, ainsi que par la garantie d&rsquo;une retraite minimale aux assur&eacute;s ayant cotis&eacute; sur de faibles revenus. &Agrave; ce titre,&nbsp;le syst&egrave;me universel de retraite tient compte des situations pouvant conduire&nbsp;certains assur&eacute;s, pour des raisons tenant &agrave; leur handicap, &agrave; leur &eacute;tat de sant&eacute; ou &agrave; leur carri&egrave;re, &agrave; anticiper leur d&eacute;part en retraite&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Un objectif de garantie d&rsquo;un niveau de vie satisfaisant et digne aux retrait&eacute;s et de versement d&rsquo;une retraite en rapport avec les revenus per&ccedil;us pendant la vie active&nbsp;;</p>

<p>&laquo;&nbsp;4&deg;&nbsp;Un objectif de libert&eacute; de choix pour les assur&eacute;s, leur permettant, sous r&eacute;serve d&rsquo;un &acirc;ge minimum, de d&eacute;cider de leur date de d&eacute;part &agrave; la retraite en fonction du montant de leur retraite&nbsp;;</p>

<p>&laquo;&nbsp;5&deg;&nbsp;Un objectif de soutenabilit&eacute; &eacute;conomique et d&rsquo;&eacute;quilibre financier, garanti notamment par des cotisations et contributions &agrave; caract&egrave;re solidaire &eacute;quitablement r&eacute;parties entre les assur&eacute;s comme entre les assur&eacute;s et les employeurs et par la constitution de r&eacute;serves permettant d&rsquo;accompagner les &eacute;volutions d&eacute;mographiques et &eacute;conomiques. &Agrave; ce titre, le pilotage du syst&egrave;me universel de retraite tient compte de l&rsquo;&eacute;volution &agrave; long terme du rapport entre le nombre des actifs et celui des retrait&eacute;s ainsi que des gains de productivit&eacute;&nbsp;;</p>

<p>&laquo;&nbsp;5&deg;&nbsp;bis&nbsp;(nouveau)&nbsp;Un objectif de confiance des jeunes g&eacute;n&eacute;rations dans la garantie de leurs droits &agrave; retraite futurs&nbsp;;</p>

<p>&laquo;&nbsp;6&deg;&nbsp;Un objectif de lisibilit&eacute; des droits constitu&eacute;s par les assur&eacute;s tout au long de leur vie active.</p>

<p>&laquo;&nbsp;Des indicateurs de suivi de ces objectifs sont d&eacute;finis par d&eacute;cret. Ils contribuent au pilotage du syst&egrave;me universel de retraite, dans les conditions pr&eacute;vues au chapitre&nbsp;XI du titre&nbsp;IX du pr&eacute;sent livre.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Le&nbsp;II de l&rsquo;article L.&nbsp;111‚??2‚??1 est abrog&eacute;&nbsp;;</p>

<p>3&deg;&nbsp;Au dernier alin&eacute;a de l&rsquo;article L.&nbsp;111‚??1, les mots&nbsp;: &laquo;&nbsp;allocations vieillesse&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;prestations de retraite&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 31, N'Article 1 Bis', N'<p>La mise en place du syst&egrave;me universel de retraite s&rsquo;accompagne, dans le cadre d&rsquo;une loi de programmation, de m&eacute;canismes permettant de garantir aux personnels enseignants ayant la qualit&eacute; de fonctionnaire et relevant des titres&nbsp;II,&nbsp;III et VI du livre&nbsp;IX du code de l&rsquo;&eacute;ducation une revalorisation de leur r&eacute;mun&eacute;ration leur assurant le versement d&rsquo;une retraite d&rsquo;un montant &eacute;quivalent &agrave; celle per&ccedil;ue par les fonctionnaires appartenant &agrave; des corps comparables de la fonction publique de l&rsquo;&Eacute;tat.</p>

<p>Les personnels enseignants, enseignants‚??chercheurs et chercheurs ayant la qualit&eacute; de fonctionnaire et relevant du titre&nbsp;V du livre&nbsp;IX du code de l&rsquo;&eacute;ducation ou du titre&nbsp;II du livre&nbsp;IV du code de la recherche b&eacute;n&eacute;ficient &eacute;galement, dans le cadre d&rsquo;une loi de programmation, de m&eacute;canismes de revalorisation permettant d&rsquo;atteindre le m&ecirc;me objectif que celui mentionn&eacute; au premier alin&eacute;a du pr&eacute;sent article.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 32, N'Article 2', N'<p>Le livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale est compl&eacute;t&eacute; par un titre&nbsp;IX ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;TITRE&nbsp;IX</p>

<p>&laquo;&nbsp;SYST&Egrave;ME UNIVERSEL DE RETRAITE</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;190‚??1.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;Le syst&egrave;me universel de retraite pr&eacute;vu par le pr&eacute;sent titre est un ensemble de r&egrave;gles de calcul et de conditions de versement des retraites, d&eacute;finies dans le cadre d&rsquo;une organisation, d&rsquo;un financement et d&rsquo;un pilotage unifi&eacute;s et communes &agrave; tous les assur&eacute;s qui exercent une activit&eacute; professionnelle en &eacute;tant soumis &agrave; la l&eacute;gislation fran&ccedil;aise de s&eacute;curit&eacute; sociale.</p>

<p>&laquo;&nbsp;Les r&eacute;gimes mentionn&eacute;s aux articles L.&nbsp;311‚??1 et L.&nbsp;721‚??1 du pr&eacute;sent code, aux articles L.&nbsp;731‚??1 et L.&nbsp;742‚??3 du code rural et de la p&ecirc;che maritime et &agrave; l&rsquo;article L.&nbsp;5551‚??1 du code des transports participent &agrave; la mise en &oelig;uvre du syst&egrave;me universel de retraite.</p>

<p>&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Sous r&eacute;serve des dispositions particuli&egrave;res applicables aux assur&eacute;s mentionn&eacute;s au&nbsp;C du&nbsp;II de l&rsquo;article&nbsp;63 de la loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp; du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; instituant&nbsp;un syst&egrave;me universel de retraite, le syst&egrave;me universel de retraite est applicable&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;&Agrave; partir du&nbsp;1er&nbsp;janvier&nbsp;2022, aux assur&eacute;s n&eacute;s &agrave; compter&nbsp;du&nbsp;1er&nbsp;janvier&nbsp;2004&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;&Agrave; partir du&nbsp;1er&nbsp;janvier&nbsp;2025, aux assur&eacute;s n&eacute;s &agrave; compter&nbsp;du&nbsp;1er&nbsp;janvier&nbsp;1975.</p>

<p>&laquo;&nbsp;III.&nbsp;&ndash;&nbsp;En mati&egrave;re de prestations de retraite, les assur&eacute;s relevant du syst&egrave;me universel de retraite sont r&eacute;gis exclusivement par les dispositions du pr&eacute;sent titre ainsi que par celles des dispositions des livres&nbsp;III, VI et&nbsp;VII du pr&eacute;sent code, du livre&nbsp;VII du code rural et de la p&ecirc;che maritime et de la cinqui&egrave;me partie du code des transports qui leur sont rendues express&eacute;ment applicables.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 33, N'Article 2 Bis', N'<p>Le titre&nbsp;V du livre&nbsp;VI du code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;L&rsquo;article L.&nbsp;652‚??6 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;&Agrave; la premi&egrave;re phrase du premier alin&eacute;a, les mots&nbsp;: &laquo;&nbsp;au financement du r&eacute;gime d&rsquo;assurance vieillesse de base&nbsp;de&nbsp;&raquo; sont remplac&eacute;s par le mot&nbsp;: &laquo;&nbsp;&agrave;&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Apr&egrave;s la m&ecirc;me premi&egrave;re phrase, est ins&eacute;r&eacute;e une phrase ainsi r&eacute;dig&eacute;e&nbsp;:&nbsp;&laquo;&nbsp;Le montant des droits de plaidoirie est fix&eacute; &agrave;&nbsp;13&nbsp;euros.&nbsp;&raquo;&nbsp;;</p>

<p>c)&nbsp;Le deuxi&egrave;me alin&eacute;a est compl&eacute;t&eacute; par les mots&nbsp;: &laquo;&nbsp;dont le taux est fix&eacute;&nbsp;par d&eacute;cret, sur proposition du conseil d&rsquo;administration de la Caisse nationale des barreaux fran&ccedil;ais&nbsp;&raquo;&nbsp;;</p>

<p>d)&nbsp;Apr&egrave;s le mot&nbsp;: &laquo;&nbsp;couvrent&nbsp;&raquo;, la fin du dernier alin&eacute;a est ainsi r&eacute;dig&eacute;e&nbsp;:&nbsp;&laquo;&nbsp;les d&eacute;penses r&eacute;sultant de l&rsquo;article L.&nbsp;653‚??8-1.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;La section&nbsp;5 du chapitre&nbsp;III est compl&eacute;t&eacute;e par un article L.&nbsp;653‚??8‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;653‚??8‚??1.&nbsp;&ndash;&nbsp;La Caisse nationale des barreaux fran&ccedil;ais participe au financement&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;De la cotisation mentionn&eacute;e &agrave; l&rsquo;article L.&nbsp;611‚??2 due par les assur&eacute;s&nbsp;mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;651‚??1 relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;De la cotisation mentionn&eacute;e &agrave; l&rsquo;article L.&nbsp;241‚??3 due par les assur&eacute;s&nbsp;mentionn&eacute;s au&nbsp;19&deg; de l&rsquo;article L.&nbsp;311‚??3 relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Des cotisations mentionn&eacute;es aux articles L.&nbsp;652‚??7 et L.&nbsp;654‚??2 dues par les assur&eacute;s mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;651‚??1 ne relevant pas du II de l&rsquo;article L.&nbsp;190‚??1.</p>

<p>&laquo;&nbsp;Cette participation au financement s&rsquo;applique dans la limite des cotisations d&rsquo;assurance vieillesse dues sur la part du revenu d&rsquo;activit&eacute; inf&eacute;rieure &agrave; trois fois le plafond mentionn&eacute; au 1&deg;&nbsp;de l&rsquo;article L.&nbsp;241‚??3.</p>

<p>&laquo;&nbsp;Le conseil d&rsquo;administration de la Caisse nationale des barreaux fran&ccedil;ais fixe chaque ann&eacute;e la part des cotisations mentionn&eacute;es aux&nbsp;1&deg; &agrave;&nbsp;3&deg; du pr&eacute;sent article prise en charge par la caisse, ainsi que la limite de cette prise en charge.</p>

<p>&laquo;&nbsp;La Caisse nationale des barreaux fran&ccedil;ais verse avant le&nbsp;31&nbsp;mars au Fonds de solidarit&eacute; vieillesse universel le produit des recettes mentionn&eacute;es aux premier et deuxi&egrave;me alin&eacute;as de l&rsquo;article L.&nbsp;652‚??6 qui exc&egrave;de le montant des prises en charge r&eacute;alis&eacute;es en application du pr&eacute;sent article au titre de l&rsquo;exercice pr&eacute;c&eacute;dent.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 34, N'Article 2 Bis', N'<p>Le code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Le titre&nbsp;V du livre&nbsp;III est compl&eacute;t&eacute; par un chapitre&nbsp;VIII ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo; Chapitre VIII</p>

<p>&laquo; Syst&egrave;me universel de retraite</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;358‚??1.&nbsp;&ndash;&nbsp;Les prestations de retraite sont calcul&eacute;es et servies aux assur&eacute;s du r&eacute;gime g&eacute;n&eacute;ral mentionn&eacute;s au&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 dans les conditions pr&eacute;vues au titre&nbsp;IX du livre&nbsp;Ier, sous r&eacute;serve des dispositions du pr&eacute;sent chapitre.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;L&rsquo;article L.&nbsp;381‚??1 est compl&eacute;t&eacute; par un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Le pr&eacute;sent article n&rsquo;est pas applicable aux assur&eacute;s mentionn&eacute;s au&nbsp;II de l&rsquo;article L.&nbsp;190‚??1.&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;Le chapitre&nbsp;II du titre&nbsp;VIII du livre&nbsp;III est compl&eacute;t&eacute; par&nbsp;une section&nbsp;4&nbsp;ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>&laquo; Section 4</p>

<p>&laquo; Agents publics non titulaires</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;382‚??32.&nbsp;&ndash;&nbsp;Les agents contractuels de droit public et les autres agents publics non titulaires ne relevant pas d&rsquo;un r&eacute;gime d&rsquo;assurance vieillesse pr&eacute;vu au livre&nbsp;VII sont affili&eacute;s au r&eacute;gime g&eacute;n&eacute;ral de s&eacute;curit&eacute; sociale pour l&rsquo;ensemble des risques.&nbsp;&raquo;&nbsp;;</p>

<p>4&deg;&nbsp;Au premier alin&eacute;a de l&rsquo;article L.&nbsp;921‚??2‚??1, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;public&nbsp;&raquo;,&nbsp;sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;et les autres agents publics non titulaires ne relevant&nbsp;pas d&rsquo;un autre r&eacute;gime compl&eacute;mentaire obligatoire d&rsquo;assurance vieillesse&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 35, N'Article 4', N'<p>Le code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Le&nbsp;1&deg; de l&rsquo;article L.&nbsp;200‚??1 est compl&eacute;t&eacute; par les mots&nbsp;: &laquo;&nbsp;ainsi que, pour les retraites, les assur&eacute;s mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;611‚??1 relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Le&nbsp;19&deg; de l&rsquo;article L.&nbsp;311‚??3 est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;19&deg;&nbsp;Les avocats salari&eacute;s, sauf pour le risque invalidit&eacute;‚??d&eacute;c&egrave;s et &agrave;&nbsp;l&rsquo;exception des avocats salari&eacute;s&nbsp;ne relevant pas du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1&nbsp;;&nbsp;&raquo;</p>

<p>3&deg;&nbsp;Le titre&nbsp;Ier&nbsp;du livre&nbsp;VI est compl&eacute;t&eacute; par un chapitre&nbsp;VII ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo; Chapitre VII</p>

<p>&laquo; Syst&egrave;me universel de retraite</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;617‚??1.&nbsp;&ndash;&nbsp;Les prestations de retraite sont calcul&eacute;es et servies aux personnes mentionn&eacute;es &agrave; l&rsquo;article L.&nbsp;611‚??1 relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 dans les conditions pr&eacute;vues au titre&nbsp;IX du livre&nbsp;Ier, sous r&eacute;serve des dispositions du pr&eacute;sent chapitre.&nbsp;&raquo;&nbsp;;</p>

<p>4&deg;&nbsp;L&rsquo;article L.&nbsp;631‚??1 est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;631‚??1.&nbsp;&ndash;&nbsp;Le r&eacute;gime d&rsquo;assurance invalidit&eacute;‚??d&eacute;c&egrave;s institu&eacute; par le pr&eacute;sent titre s&rsquo;applique aux travailleurs ind&eacute;pendants mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;611‚??1 qui ne rel&egrave;vent pas des r&eacute;gimes mentionn&eacute;s aux articles L.&nbsp;640‚??1 et L.&nbsp;651‚??1.</p>

<p>&laquo;&nbsp;Les chapitres&nbsp;III &agrave;&nbsp;V du pr&eacute;sent titre s&rsquo;appliquent aux personnes mentionn&eacute;es &agrave; l&rsquo;article L.&nbsp;611‚??1 qui ne rel&egrave;vent ni du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1, ni des r&eacute;gimes mentionn&eacute;s aux articles L.&nbsp;640‚??1 et L.&nbsp;651‚??1.&nbsp;&raquo;&nbsp;;</p>

<p>5&deg;&nbsp;&Agrave; la premi&egrave;re phrase du premier alin&eacute;a de l&rsquo;article L.&nbsp;640‚??1, les mots&nbsp;: &laquo;&nbsp;d&rsquo;assurance vieillesse et invalidit&eacute;‚??d&eacute;c&egrave;s&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;d&rsquo;invalidit&eacute;‚??d&eacute;c&egrave;s et, pour les personnes ne relevant pas du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1, d&rsquo;assurance vieillesse&nbsp;&raquo;&nbsp;;</p>

<p>6&deg;&nbsp;L&rsquo;article L.&nbsp;651‚??1 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Sont ajout&eacute;s les mots&nbsp;: &laquo;&nbsp;et qui ne rel&egrave;vent pas des dispositions du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Il est ajout&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Sont &eacute;galement affili&eacute;s au r&eacute;gime d&rsquo;assurance invalidit&eacute;‚??d&eacute;c&egrave;s de la Caisse nationale des barreaux fran&ccedil;ais les avocats relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 36, N'Article 5', N'<p>Le livre VII du code rural et de la p&ecirc;che maritime est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;La section&nbsp;3 du chapitre&nbsp;II du titre&nbsp;III est compl&eacute;t&eacute;e par une sous‚??section&nbsp;4 ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>&laquo; Sous‚??section 4</p>

<p>&laquo; Syst&egrave;me universel de retraite</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;732‚??64.&nbsp;&ndash;&nbsp;Les prestations de retraite sont calcul&eacute;es et servies aux personnes non salari&eacute;es agricoles mentionn&eacute;es au&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 du code de la s&eacute;curit&eacute; sociale et occup&eacute;es dans les exploitations ou entreprises mentionn&eacute;es &agrave; l&rsquo;article L.&nbsp;722‚??15 et au premier alin&eacute;a de l&rsquo;article L.&nbsp;781‚??31 du pr&eacute;sent code dans les conditions pr&eacute;vues au titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale, sous r&eacute;serve des dispositions de la pr&eacute;sente sous‚??section.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Apr&egrave;s le&nbsp;2&deg; de l&rsquo;article L.&nbsp;742‚??3, il est ins&eacute;r&eacute; un&nbsp;3&deg; ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Le titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale pour les assur&eacute;s mentionn&eacute;s au&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 du m&ecirc;me code.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 38, N'Article 6', N'<p>I.&nbsp;&ndash;&nbsp;Le code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Le titre&nbsp;II du livre&nbsp;VII est ainsi r&eacute;tabli&nbsp;:</p>

<p>&laquo; TITRE II</p>

<p>&laquo;&nbsp;ASSURANCE VIEILLESSE DES FONCTIONNAIRES, MAGISTRATS ET MILITAIRES<br />
RELEVANT DU SYST&Egrave;ME UNIVERSEL DE RETRAITE</p>

<p>&laquo; Chapitre Ier</p>

<p>&laquo; Champ d&rsquo;application</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;721‚??1.&nbsp;&ndash;&nbsp;Sont affili&eacute;s au r&eacute;gime d&rsquo;assurance vieillesse pr&eacute;vu au pr&eacute;sent titre, y compris lorsque les services sont accomplis &agrave; titre accessoire ou en dehors du territoire de la France m&eacute;tropolitaine ou d&rsquo;une des collectivit&eacute;s mentionn&eacute;es &agrave; l&rsquo;article L.&nbsp;751‚??1 ou sont r&eacute;mun&eacute;r&eacute;s en tout ou partie par un organisme de droit priv&eacute;, les agents publics relevant du&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 et des cat&eacute;gories suivantes&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Fonctionnaires relevant de la loi&nbsp;n&deg;&nbsp;83‚??634 du&nbsp;13&nbsp;juillet&nbsp;1983 portant&nbsp;droits et obligations des fonctionnaires&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Fonctionnaires relevant de l&rsquo;article&nbsp;2 de la loi&nbsp;n&deg;&nbsp;53‚??39&nbsp;du&nbsp;3&nbsp;f&eacute;vrier&nbsp;1953&nbsp;relative au d&eacute;veloppement des cr&eacute;dits affect&eacute;s aux d&eacute;penses de fonctionnement&nbsp;des services civils pour l&rsquo;exercice&nbsp;1953 (Pr&eacute;sidence du Conseil)&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Fonctionnaires relevant du cinqui&egrave;me alin&eacute;a de l&rsquo;article&nbsp;8 de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du&nbsp;17&nbsp;novembre&nbsp;1958 relative au fonctionnement des assembl&eacute;es parlementaires&nbsp;;</p>

<p>&laquo;&nbsp;4&deg;&nbsp;Magistrats relevant de l&rsquo;ordonnance n&deg;&nbsp;58‚??1270 du&nbsp;22&nbsp;d&eacute;cembre&nbsp;1958&nbsp;portant loi organique relative au statut de la magistrature&nbsp;;</p>

<p>&laquo;&nbsp;5&deg;&nbsp;Militaires relevant de la quatri&egrave;me partie du code de la d&eacute;fense.</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;721‚??2.&nbsp;&ndash;&nbsp;Le pr&eacute;sent titre ne s&rsquo;applique pas, au titre des activit&eacute;s mentionn&eacute;es aux&nbsp;1&deg; &agrave;&nbsp;3&deg; du pr&eacute;sent article, aux agents publics mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;721‚??1 qui&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Exercent une activit&eacute; professionnelle ind&eacute;pendante ou une activit&eacute; professionnelle salari&eacute;e dans le cadre d&rsquo;un contrat de droit priv&eacute; ou de droit public, &agrave; l&rsquo;exception des militaires sous contrat et des fonctionnaires de l&rsquo;&Eacute;tat et des magistrats d&eacute;tach&eacute;s sur contrat de droit public aupr&egrave;s d&rsquo;une repr&eacute;sentation de l&rsquo;&Eacute;tat &agrave; l&rsquo;&eacute;tranger ou d&rsquo;un &eacute;tablissement d&rsquo;enseignement situ&eacute; &agrave; l&rsquo;&eacute;tranger ou aupr&egrave;s d&rsquo;une administration ou d&rsquo;un &eacute;tablissement public de l&rsquo;&Eacute;tat situ&eacute; dans une collectivit&eacute; d&rsquo;outre‚??mer autre que celles mentionn&eacute;es &agrave; l&rsquo;article L.&nbsp;751‚??1&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Sont d&eacute;tach&eacute;s dans une fonction publique &eacute;lective locale&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Sauf accord international contraire, sont d&eacute;tach&eacute;s aupr&egrave;s d&rsquo;une&nbsp;administration ou d&rsquo;un organisme implant&eacute; sur le territoire d&rsquo;un &Eacute;tat &eacute;tranger&nbsp;ou aupr&egrave;s d&rsquo;un organisme international.</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;721‚??3.&nbsp;&ndash;&nbsp;Les prestations de retraite des personnes mentionn&eacute;es&nbsp;&agrave; l&rsquo;article L.&nbsp;721‚??1 sont calcul&eacute;es et servies dans les conditions pr&eacute;vues au titre&nbsp;IX du livre&nbsp;Ier, sous r&eacute;serve des dispositions du pr&eacute;sent titre.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Le&nbsp;1&deg; de l&rsquo;article L.&nbsp;142‚??1 est compl&eacute;t&eacute; par les mots&nbsp;: &laquo;&nbsp;,&nbsp;notamment au titre du syst&egrave;me universel de retraite, y compris pour les assur&eacute;s mentionn&eacute;s au titre&nbsp;II du livre&nbsp;VII&nbsp;&raquo;.</p>

<p>II.&nbsp;&ndash;&nbsp;Le titre&nbsp;Ier&nbsp;du livre&nbsp;Ier&nbsp;du code des pensions civiles et militaires de retraite est compl&eacute;t&eacute; par un article L.&nbsp;3&nbsp;bis&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;3&nbsp;bis.&nbsp;&ndash;&nbsp;Le pr&eacute;sent code n&rsquo;est pas applicable&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;&Agrave; partir du&nbsp;1er&nbsp;janvier&nbsp;2022 pour les assur&eacute;s n&eacute;s &agrave; compter du&nbsp;1er&nbsp;janvier&nbsp;2004&nbsp;;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 39, N'Article 7', N'<p>I.&nbsp;&ndash;&nbsp;Le code de la s&eacute;curit&eacute; sociale est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;La section&nbsp;10&nbsp;du chapitre&nbsp;Ier&nbsp;du titre&nbsp;VIII du livre&nbsp;III est&nbsp;ainsi&nbsp;r&eacute;tablie&nbsp;:</p>

<p>&laquo;&nbsp;Section 10</p>

<p>&laquo;&nbsp;Autres cat&eacute;gories de salari&eacute;s affili&eacute;s au r&eacute;gime g&eacute;n&eacute;ral<br />
au titre du syst&egrave;me universel de retraite</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;381‚??32.&nbsp;&ndash;&nbsp;Sont affili&eacute;s &agrave; l&rsquo;assurance vieillesse du r&eacute;gime g&eacute;n&eacute;ral de s&eacute;curit&eacute; sociale les assur&eacute;s mentionn&eacute;s au&nbsp;II de l&rsquo;article L.&nbsp;190‚??1 relevant de l&rsquo;une des cat&eacute;gories suivantes&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Les salari&eacute;s r&eacute;gis par le statut particulier mentionn&eacute; &agrave; l&rsquo;article L.&nbsp;2101‚??2 du code des transports&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Les salari&eacute;s r&eacute;gis par le statut particulier de l&rsquo;&eacute;tablissement mentionn&eacute; &agrave; l&rsquo;article L.&nbsp;2142‚??1 du m&ecirc;me code&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Les clercs et employ&eacute;s de notaires mentionn&eacute;s &agrave; l&rsquo;article&nbsp;1er&nbsp;de la loi du&nbsp;12&nbsp;juillet&nbsp;1937 instituant une caisse de retraite et d&rsquo;assistance des clercs de notaires&nbsp;;</p>

<p>&laquo;&nbsp;4&deg;&nbsp;Les salari&eacute;s r&eacute;gis par le statut particulier fix&eacute; par l&rsquo;article&nbsp;47 de la loi n&deg;&nbsp;46‚??628 du 8&nbsp;avril&nbsp;1946 sur la nationalisation de l&rsquo;&eacute;lectricit&eacute; et du gaz&nbsp;;</p>

<p>&laquo;&nbsp;5&deg;&nbsp;Les agents titulaires de la Banque de France&nbsp;;</p>

<p>&laquo;&nbsp;6&deg;&nbsp;Les membres du personnel de l&rsquo;Op&eacute;ra national de Paris engag&eacute;s pour une dur&eacute;e ind&eacute;termin&eacute;e ainsi que pour la p&eacute;riode o&ugrave; leurs contrats les placent &agrave; disposition du th&eacute;&acirc;tre, les personnels artistiques du chant, des ch&oelig;urs, de la danse et de l&rsquo;orchestre, y compris les chefs d&rsquo;orchestre et les artistes de l&rsquo;Atelier lyrique, engag&eacute;s temporairement&nbsp;;</p>

<p>&laquo;&nbsp;7&deg;&nbsp;Les artistes aux appointements et les employ&eacute;s &agrave; traitement fixe de la Com&eacute;die‚??Fran&ccedil;aise&nbsp;;</p>

<p>&laquo;&nbsp;8&deg;&nbsp;Les ouvriers des &eacute;tablissements industriels de l&rsquo;&Eacute;tat&nbsp;;</p>

<p>&laquo;&nbsp;9&deg;&nbsp;Les personnes ayant &eacute;t&eacute; affili&eacute;es avant le 1er&nbsp;septembre&nbsp;2010 au r&eacute;gime de s&eacute;curit&eacute; sociale dans les mines&nbsp;;</p>

<p>&laquo;&nbsp;10&deg;&nbsp;Les employ&eacute;s du Port autonome de Strasbourg&nbsp;;</p>

<p>&laquo;&nbsp;11&deg;&nbsp;Les personnes r&eacute;gies par la loi du&nbsp;18&nbsp;Germinal an&nbsp;X relative &agrave; l&rsquo;organisation des cultes et par l&rsquo;ordonnance du&nbsp;25&nbsp;mai 1844 portant r&egrave;glement pour l&rsquo;organisation du culte isra&eacute;lite&nbsp;;</p>

<p>&laquo;&nbsp;12&deg;&nbsp;Les membres du Conseil &eacute;conomique, social et environnemental.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Apr&egrave;s le&nbsp;4&deg; de l&rsquo;article L.&nbsp;200‚??1, il est ins&eacute;r&eacute; un&nbsp;5&deg; ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;5&deg;&nbsp;Au titre de l&rsquo;assurance vieillesse, les assur&eacute;s relevant des articles L.&nbsp;381‚??32 et L.O.&nbsp;381‚??33.&nbsp;&raquo;</p>

<p>II.&nbsp;&ndash;&nbsp;A.&nbsp;&ndash;&nbsp;Le titre&nbsp;V du livre&nbsp;V de la cinqui&egrave;me partie du code des transports est compl&eacute;t&eacute; par un chapitre&nbsp;VIII ainsi r&eacute;dig&eacute;&nbsp;:</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 40, N'Article 8', N'<p>Apr&egrave;s l&rsquo;article L.&nbsp;190‚??1 du code de la s&eacute;curit&eacute; sociale tel qu&rsquo;il r&eacute;sulte de l&rsquo;article&nbsp;2 de la pr&eacute;sente loi, il est ins&eacute;r&eacute; un chapitre&nbsp;Ier&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Chapitre&nbsp;Ier</p>

<p>&laquo;&nbsp;Calcul de la retraite et modalit&eacute;s de constitution des droits</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??2.&nbsp;&ndash;&nbsp;&Agrave; compter de l&rsquo;&acirc;ge pr&eacute;vu &agrave; l&rsquo;article L.&nbsp;191‚??1, l&rsquo;assur&eacute; a droit, sur sa demande, &agrave; une retraite d&rsquo;un montant &eacute;gal au produit de l&rsquo;ensemble des points inscrits &agrave; son compte personnel de carri&egrave;re, &agrave; la date d&rsquo;effet de sa retraite, par la valeur de service du point fix&eacute;e &agrave; cette date dans les conditions pr&eacute;vues &agrave; l&rsquo;article L.&nbsp;191‚??4.</p>

<p>&laquo;&nbsp;En fonction de l&rsquo;&acirc;ge de l&rsquo;assur&eacute; &agrave; la date d&rsquo;effet de sa retraite, le coefficient d&rsquo;ajustement d&eacute;fini &agrave; l&rsquo;article L.&nbsp;191‚??5 est appliqu&eacute;, le cas &eacute;ch&eacute;ant, &agrave; ce montant.</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??3.&nbsp;&ndash;&nbsp;Les points inscrits au compte personnel de carri&egrave;re s&rsquo;acqui&egrave;rent annuellement au titre&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Des cotisations calcul&eacute;es dans les conditions pr&eacute;vues au&nbsp;1&deg; de l&rsquo;article L.&nbsp;241‚??3 et prises en compte selon les modalit&eacute;s pr&eacute;vues au m&ecirc;me article L.&nbsp;241‚??3, qui permettent d&rsquo;acqu&eacute;rir des points &agrave; hauteur du r&eacute;sultat de la division du montant de ces cotisations par la valeur d&rsquo;acquisition du point fix&eacute;e au titre de l&rsquo;ann&eacute;e consid&eacute;r&eacute;e dans les conditions pr&eacute;vues &agrave; l&rsquo;article L.&nbsp;191‚??4&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Des p&eacute;riodes mentionn&eacute;es aux articles L.&nbsp;195‚??2, L.&nbsp;195‚??3, L.&nbsp;195‚??4&nbsp;et L.&nbsp;196‚??2, selon les modalit&eacute;s pr&eacute;vues aux m&ecirc;mes articles L.&nbsp;195‚??2, L.&nbsp;195‚??3, L.&nbsp;195‚??4 et L.&nbsp;196‚??2&nbsp;;</p>

<p>&laquo;&nbsp;3&deg;&nbsp;Des p&eacute;riodes ayant fait l&rsquo;objet de versement de cotisations dans les conditions pr&eacute;vues aux articles L.&nbsp;194‚??1 &agrave; L.&nbsp;194‚??5, L.&nbsp;723‚??4, L.&nbsp;724‚??11 et L.&nbsp;724‚??15.</p>

<p>&laquo;&nbsp;&Agrave; ces points s&rsquo;ajoutent ceux acquis au titre du&nbsp;II de l&rsquo;article L.&nbsp;192‚??2 et des articles L.&nbsp;195‚??1, L.&nbsp;196‚??1 et L.&nbsp;724‚??14.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 41, N'Article 9', N'<p>I.&nbsp;&ndash;&nbsp;Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale tel qu&rsquo;il r&eacute;sulte de l&rsquo;article&nbsp;8 de la pr&eacute;sente loi est compl&eacute;t&eacute; par un article L.&nbsp;191‚??4 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??4.&nbsp;&ndash;&nbsp;La valeur d&rsquo;acquisition et la valeur de service du point sont revaloris&eacute;es le 1er&nbsp;janvier de chaque ann&eacute;e selon des taux d&eacute;finis dans les conditions suivantes&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;&Agrave; titre transitoire jusqu&rsquo;au&nbsp;31&nbsp;d&eacute;cembre&nbsp;2044, ces deux taux sont fix&eacute;s, selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7, par une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle approuv&eacute;e par d&eacute;cret ou, en l&rsquo;absence de d&eacute;lib&eacute;ration ou en l&rsquo;absence d&rsquo;approbation de celle‚??ci, par d&eacute;cret. Dans ce dernier cas, le d&eacute;cret &eacute;nonce les motifs pour lesquels la d&eacute;lib&eacute;ration ne peut &ecirc;tre approuv&eacute;e. Chacun de ces taux doit &ecirc;tre sup&eacute;rieur &agrave; z&eacute;ro et compris entre l&rsquo;&eacute;volution annuelle des prix hors tabac et l&rsquo;&eacute;volution annuelle du revenu d&rsquo;activit&eacute; moyen par t&ecirc;te, constat&eacute;e par l&rsquo;Institut national de la statistique et des &eacute;tudes &eacute;conomiques selon des modalit&eacute;s de calcul d&eacute;termin&eacute;es par d&eacute;cret en Conseil d&rsquo;&Eacute;tat&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;&Agrave; compter du&nbsp;1er&nbsp;janvier&nbsp;2045, ces deux taux sont &eacute;gaux &agrave; l&rsquo;&eacute;volution&nbsp;annuelle du revenu d&rsquo;activit&eacute; moyen par t&ecirc;te mentionn&eacute;e au&nbsp;1&deg;, sauf si&nbsp;:</p>

<p>&laquo;&nbsp;a)&nbsp;Soit une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle approuv&eacute;e par d&eacute;cret d&eacute;termine des taux diff&eacute;rents selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7&nbsp;;</p>

<p>&laquo;&nbsp;b)&nbsp;Soit en l&rsquo;absence d&rsquo;une d&eacute;lib&eacute;ration mentionn&eacute;e au&nbsp;a&nbsp;ou en l&rsquo;absence d&rsquo;approbation de celle‚??ci, un d&eacute;cret d&eacute;termine des taux diff&eacute;rents selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7. Dans le dernier cas, le d&eacute;cret &eacute;nonce les motifs pour lesquels la d&eacute;lib&eacute;ration ne peut &ecirc;tre approuv&eacute;e.&nbsp;&raquo;</p>

<p>II.&nbsp;&ndash;&nbsp;La valeur d&rsquo;acquisition et la valeur de service du point applicables au titre de l&rsquo;ann&eacute;e&nbsp;2022 sont fix&eacute;es, avant le 30&nbsp;juin&nbsp;2021, par une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle &agrave; un niveau d&eacute;termin&eacute;, au regard des projections de la situation financi&egrave;re des r&eacute;gimes de retraite obligatoires &eacute;tablies par le comit&eacute; d&rsquo;expertise ind&eacute;pendant des retraites mentionn&eacute; &agrave; l&rsquo;article L.&nbsp;19‚??11‚??10 du code de la s&eacute;curit&eacute; sociale sur un horizon de quarante ans, de mani&egrave;re &agrave; garantir l&rsquo;&eacute;quilibre financier du syst&egrave;me de retraite sans diminuer la part des retraites dans le produit int&eacute;rieur brut, appr&eacute;ci&eacute;e selon des modalit&eacute;s fix&eacute;es par d&eacute;cret en Conseil d&rsquo;&Eacute;tat.</p>

<p>Un d&eacute;cret approuve cette d&eacute;lib&eacute;ration ou &eacute;nonce les motifs pour lesquels elle ne peut &ecirc;tre approuv&eacute;e. Dans ce dernier cas ou en l&rsquo;absence de d&eacute;lib&eacute;ration, ces deux valeurs sont fix&eacute;es par d&eacute;cret dans les conditions pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7 du m&ecirc;me code.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 42, N'Article 10', N'<p>I.&nbsp;&ndash;&nbsp;Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale tel qu&rsquo;il r&eacute;sulte des articles&nbsp;8 et&nbsp;9 de la pr&eacute;sente loi est compl&eacute;t&eacute; par un article L.&nbsp;191‚??5 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??5.&nbsp;&ndash;&nbsp;Un coefficient d&rsquo;ajustement est appliqu&eacute; &agrave; proportion de l&rsquo;&eacute;cart, exprim&eacute; en mois entiers, entre l&rsquo;&acirc;ge de l&rsquo;assur&eacute; &agrave; la date de liquidation de sa retraite et l&rsquo;&acirc;ge d&rsquo;&eacute;quilibre applicable &agrave; sa g&eacute;n&eacute;ration. Il&nbsp;minore la retraite de l&rsquo;assur&eacute; qui la liquide avant l&rsquo;&acirc;ge d&rsquo;&eacute;quilibre applicable&nbsp;&agrave; sa g&eacute;n&eacute;ration et majore celle de l&rsquo;assur&eacute; qui la liquide apr&egrave;s cet &acirc;ge.</p>

<p>&laquo;&nbsp;La valeur par mois du coefficient d&rsquo;ajustement est fix&eacute;e par d&eacute;cret.</p>

<p>&laquo;&nbsp;L&rsquo;&acirc;ge d&rsquo;&eacute;quilibre, fix&eacute; par d&eacute;cret et exprim&eacute; en mois entiers, &eacute;volue par g&eacute;n&eacute;ration &agrave; hauteur des deux tiers de l&rsquo;&eacute;volution des pr&eacute;visions d&rsquo;esp&eacute;rance de vie &agrave; la retraite des assur&eacute;s, d&eacute;termin&eacute;es par l&rsquo;Institut national de la statistique et des &eacute;tudes &eacute;conomiques. Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat d&eacute;termine les modalit&eacute;s de calcul permettant de d&eacute;terminer ce ratio.</p>

<p>&laquo;&nbsp;Par d&eacute;rogation aux deuxi&egrave;me et troisi&egrave;me alin&eacute;as du pr&eacute;sent article, une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle peut, selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4, L.&nbsp;19‚??11‚??7, fixer une valeur diff&eacute;rente de celle r&eacute;sultant des deuxi&egrave;me et troisi&egrave;me alin&eacute;as du pr&eacute;sent article&nbsp;:</p>

<p>&laquo;&nbsp;1&deg;&nbsp;Pour la valeur du coefficient d&rsquo;ajustement applicable au titre de l&rsquo;ann&eacute;e consid&eacute;r&eacute;e, sans qu&rsquo;elle puisse &ecirc;tre sup&eacute;rieure ni inf&eacute;rieure d&rsquo;un tiers &agrave; celle d&eacute;finie en application du deuxi&egrave;me alin&eacute;a&nbsp;;</p>

<p>&laquo;&nbsp;2&deg;&nbsp;Pour l&rsquo;&acirc;ge d&rsquo;&eacute;quilibre applicable au titre de la g&eacute;n&eacute;ration consid&eacute;r&eacute;e, sous r&eacute;serve que l&rsquo;&eacute;volution qui en r&eacute;sulte soit nulle ou suive le m&ecirc;me sens sans pouvoir &ecirc;tre sup&eacute;rieure &agrave; l&rsquo;&eacute;volution des pr&eacute;visions d&rsquo;esp&eacute;rance de vie &agrave; la retraite des assur&eacute;s mentionn&eacute;e au troisi&egrave;me alin&eacute;a. Dans ce dernier cas, cette &eacute;volution ne peut pas &ecirc;tre sup&eacute;rieure &agrave; ces pr&eacute;visions.</p>

<p>&laquo;&nbsp;Un d&eacute;cret approuve cette d&eacute;lib&eacute;ration ou &eacute;nonce les motifs pour lesquels elle ne peut &ecirc;tre approuv&eacute;e.&nbsp;&raquo;</p>

<p>II.&nbsp;&ndash;&nbsp;Le conseil d&rsquo;administration de la Caisse nationale de retraite universelle &eacute;met, par une d&eacute;lib&eacute;ration prise avant le 30&nbsp;juin&nbsp;2021, des propositions pour la fixation de l&rsquo;&acirc;ge d&rsquo;&eacute;quilibre pr&eacute;vu &agrave; l&rsquo;article L.&nbsp;191‚??5 du code de la s&eacute;curit&eacute; sociale applicable &agrave; compter de l&rsquo;entr&eacute;e en vigueur du syst&egrave;me universel de retraite, en prenant en compte l&rsquo;&acirc;ge moyen projet&eacute; de d&eacute;part &agrave; la retraite des salari&eacute;s du r&eacute;gime g&eacute;n&eacute;ral hors d&eacute;parts anticip&eacute;s, pour la premi&egrave;re des g&eacute;n&eacute;rations mentionn&eacute;es au&nbsp;A du&nbsp;II de l&rsquo;article&nbsp;63 de la pr&eacute;sente loi, par le comit&eacute; d&rsquo;expertise ind&eacute;pendant des retraites mentionn&eacute; &agrave; l&rsquo;article&nbsp;56 et l&rsquo;&eacute;quilibre financier de long terme du syst&egrave;me universel de retraite.</p>

<p>Au regard des propositions du conseil d&rsquo;administration de la Caisse nationale de retraite universelle, et en prenant en compte les projections du comit&eacute; d&rsquo;expertise ind&eacute;pendant pr&eacute;c&eacute;demment mentionn&eacute;es, un d&eacute;cret fixe cet &acirc;ge d&rsquo;&eacute;quilibre avant le 31&nbsp;ao&ucirc;t&nbsp;2021.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 43, N'Article 11', N'<p>Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale tel qu&rsquo;il r&eacute;sulte des articles&nbsp;8, 9 et&nbsp;10 de la pr&eacute;sente loi est compl&eacute;t&eacute; par un article L.&nbsp;191‚??6 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??6.&nbsp;&ndash;&nbsp;La revalorisation annuelle des retraites servies est effectu&eacute;e, le 1er&nbsp;janvier de chaque ann&eacute;e, en fonction de l&rsquo;&eacute;volution annuelle des prix hors tabac, par application du coefficient mentionn&eacute; &agrave; l&rsquo;article L.&nbsp;161‚??25.</p>

<p>&laquo;&nbsp;Par d&eacute;rogation au premier alin&eacute;a du pr&eacute;sent article, la revalorisation annuelle peut &ecirc;tre effectu&eacute;e selon un coefficient fix&eacute;, selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7, par une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle approuv&eacute;e par d&eacute;cret ou, en l&rsquo;absence de d&eacute;lib&eacute;ration ou en l&rsquo;absence d&rsquo;approbation de celle‚??ci, par d&eacute;cret. Dans ce dernier cas, le d&eacute;cret &eacute;nonce les motifs pour lesquels la d&eacute;lib&eacute;ration ne peut pas &ecirc;tre approuv&eacute;e.</p>

<p>&laquo;&nbsp;Le coefficient fix&eacute; en application du deuxi&egrave;me alin&eacute;a ne peut &ecirc;tre&nbsp;inf&eacute;rieur &agrave; celui pr&eacute;vu au premier alin&eacute;a&nbsp;du pr&eacute;sent article&nbsp;que dans la mesure&nbsp;n&eacute;cessaire au respect de la trajectoire financi&egrave;re mentionn&eacute;e au&nbsp;1&deg; de l&rsquo;article L.&nbsp;19‚??11‚??3. Dans ce cas, il n&rsquo;est rendu applicable que sous r&eacute;serve de sa validation par la loi avant le 1er&nbsp;janvier de l&rsquo;ann&eacute;e consid&eacute;r&eacute;e.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (6, 44, N'Article 11', N'<p>Le chapitre&nbsp;Ier&nbsp;du titre&nbsp;IX du livre&nbsp;Ier&nbsp;du code de la s&eacute;curit&eacute; sociale tel qu&rsquo;il r&eacute;sulte des articles&nbsp;8, 9 et&nbsp;10 de la pr&eacute;sente loi est compl&eacute;t&eacute; par un article L.&nbsp;191‚??6 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;191‚??6.&nbsp;&ndash;&nbsp;La revalorisation annuelle des retraites servies est effectu&eacute;e, le 1er&nbsp;janvier de chaque ann&eacute;e, en fonction de l&rsquo;&eacute;volution annuelle des prix hors tabac, par application du coefficient mentionn&eacute; &agrave; l&rsquo;article L.&nbsp;161‚??25.</p>

<p>&laquo;&nbsp;Par d&eacute;rogation au premier alin&eacute;a du pr&eacute;sent article, la revalorisation annuelle peut &ecirc;tre effectu&eacute;e selon un coefficient fix&eacute;, selon les modalit&eacute;s et dans les limites pr&eacute;vues aux articles L.&nbsp;19‚??11‚??3, L.&nbsp;19‚??11‚??4 et L.&nbsp;19‚??11‚??7, par une d&eacute;lib&eacute;ration du conseil d&rsquo;administration de la Caisse nationale de retraite universelle approuv&eacute;e par d&eacute;cret ou, en l&rsquo;absence de d&eacute;lib&eacute;ration ou en l&rsquo;absence d&rsquo;approbation de celle‚??ci, par d&eacute;cret. Dans ce dernier cas, le d&eacute;cret &eacute;nonce les motifs pour lesquels la d&eacute;lib&eacute;ration ne peut pas &ecirc;tre approuv&eacute;e.</p>

<p>&laquo;&nbsp;Le coefficient fix&eacute; en application du deuxi&egrave;me alin&eacute;a ne peut &ecirc;tre&nbsp;inf&eacute;rieur &agrave; celui pr&eacute;vu au premier alin&eacute;a&nbsp;du pr&eacute;sent article&nbsp;que dans la mesure&nbsp;n&eacute;cessaire au respect de la trajectoire financi&egrave;re mentionn&eacute;e au&nbsp;1&deg; de l&rsquo;article L.&nbsp;19‚??11‚??3. Dans ce cas, il n&rsquo;est rendu applicable que sous r&eacute;serve de sa validation par la loi avant le 1er&nbsp;janvier de l&rsquo;ann&eacute;e consid&eacute;r&eacute;e.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 45, N'Article 1', N'<p>Le second&nbsp;alin&eacute;a de l&rsquo;article L.&nbsp;1 du code du patrimoine est&nbsp;ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Sont ajout&eacute;s les mots&nbsp;: &laquo;&nbsp;et du patrimoine linguistique, constitu&eacute; de la langue fran&ccedil;aise et des langues r&eacute;gionales&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Est ajout&eacute;e une phrase ainsi r&eacute;dig&eacute;e&nbsp;: &laquo;&nbsp;L&rsquo;&Eacute;tat et les collectivit&eacute;s territoriales concourent &agrave; l&rsquo;enseignement, &agrave; la diffusion et &agrave; la promotion de ces langues.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 46, N'Article 2', N'<p>Apr&egrave;s le mot&nbsp;: &laquo;&nbsp;art&nbsp;&raquo;, la fin du&nbsp;5&deg; de l&rsquo;article L.&nbsp;111‚??1 du code du patrimoine est ainsi r&eacute;dig&eacute;e&nbsp;: &laquo;&nbsp;,&nbsp;de l&rsquo;arch&eacute;ologie ou de la connaissance de la langue fran&ccedil;aise et des langues r&eacute;gionales.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 47, N'Article 2 - Bis', N'<p>L&rsquo;article&nbsp;21 de la loi&nbsp;n&deg;&nbsp;94‚??665 du 4&nbsp;ao&ucirc;t 1994 relative &agrave; l&rsquo;emploi de la langue fran&ccedil;aise est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;21.&nbsp;&ndash;&nbsp;Les dispositions de la pr&eacute;sente loi ne font pas obstacle &agrave; l&rsquo;usage des langues r&eacute;gionales et aux actions publiques et priv&eacute;es men&eacute;es en leur faveur.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 48, N'Article 8', N'<p>Les services publics peuvent assurer sur tout ou partie de leur territoire l&rsquo;affichage de traductions de la langue fran&ccedil;aise dans la ou les langues r&eacute;gionales en usage sur les inscriptions et les signal&eacute;tiques appos&eacute;es sur les b&acirc;timents publics, sur les voies publiques de circulation, sur les voies navigables, dans les infrastructures de transport ainsi que dans les principaux supports de communication institutionnelle, &agrave; l&rsquo;occasion de leur installation ou de leur renouvellement.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 49, N'Article 9', N'<p>L&rsquo;article&nbsp;34 du code civil est compl&eacute;t&eacute; par un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Les signes diacritiques des langues r&eacute;gionales sont autoris&eacute;s dans les actes d&rsquo;&eacute;tat civil.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 50, N'Article 11', N'<p>Le Gouvernement remet annuellement au Parlement un rapport relatif &agrave; l&rsquo;accueil, dans les acad&eacute;mies concern&eacute;es, des enfants dont les familles ont fait la demande d&rsquo;un accueil au plus pr&egrave;s possible de leur domicile dans les &eacute;coles maternelles ou classes enfantines en langue r&eacute;gionale.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (7, 51, N'Article 12', N'<p>Le Gouvernement remet annuellement au Parlement un rapport sur les conventions sp&eacute;cifiques conclues entre l&rsquo;&Eacute;tat, des collectivit&eacute;s territoriales et des associations de promotion des langues r&eacute;gionales relatives aux &eacute;tablissements d&rsquo;enseignement de ces langues cr&eacute;&eacute;s selon un statut de droit public ou de droit priv&eacute; et sur l&rsquo;opportunit&eacute; de b&eacute;n&eacute;ficier pour les &eacute;tablissements scolaires associatifs d&eacute;veloppant une p&eacute;dagogie fond&eacute;e sur&nbsp;l&rsquo;usage immersif de la langue r&eacute;gionale de contrats simples ou d&rsquo;association&nbsp;avec l&rsquo;&Eacute;tat.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (8, 52, N'Article 1', N'<p>I.&nbsp;&ndash;&nbsp;Il est institu&eacute; un comit&eacute; d&rsquo;&eacute;valuation des textes encadrant l&rsquo;acc&egrave;s au march&eacute; du travail des personnes atteintes de maladies chroniques.</p>

<p>Ce comit&eacute; vise &agrave; favoriser l&rsquo;&eacute;gal acc&egrave;s au march&eacute; du travail et aux formations professionnelles de toute personne, quel que soit son &eacute;tat de sant&eacute;. Il veille &agrave; ce que les personnes atteintes de maladies chroniques aient, en l&rsquo;absence de motif imp&eacute;rieux de s&eacute;curit&eacute; et de risque pour leur sant&eacute;, acc&egrave;s &agrave; toutes les professions. Il a notamment pour mission&nbsp;:</p>

<p>1&deg;&nbsp;De recenser l&rsquo;ensemble des textes nationaux ou internationaux emp&ecirc;chant l&rsquo;acc&egrave;s &agrave; une formation ou &agrave; un emploi aux personnes atteintes d&rsquo;une maladie chronique&nbsp;;</p>

<p>2&deg;&nbsp;D&rsquo;&eacute;valuer la pertinence de ces textes&nbsp;;</p>

<p>3&deg;&nbsp;De proposer leur actualisation en tenant compte notamment des &eacute;volutions m&eacute;dicales, scientifiques et technologiques&nbsp;;</p>

<p>4&deg;&nbsp;De formuler des propositions visant &agrave; am&eacute;liorer l&rsquo;acc&egrave;s &agrave; certaines professions des personnes souffrant de maladies chroniques.</p>

<p>II.&nbsp;&ndash;&nbsp;Ce comit&eacute; est compos&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;De repr&eacute;sentants de l&rsquo;&Eacute;tat&nbsp;;</p>

<p>2&deg;&nbsp;De deux d&eacute;put&eacute;s et de deux s&eacute;nateurs&nbsp;;</p>

<p>3&deg;&nbsp;De personnalit&eacute;s qualifi&eacute;es choisies en raison de leur comp&eacute;tence dans le champ de la sant&eacute; au travail ainsi que des soins, de l&rsquo;&eacute;pid&eacute;miologie et de la recherche sur les maladies concern&eacute;es&nbsp;;</p>

<p>4&deg;&nbsp;De repr&eacute;sentants d&rsquo;associations de malades ou d&rsquo;usagers du syst&egrave;me de sant&eacute; agr&eacute;&eacute;es d&eacute;sign&eacute;s au titre de l&rsquo;article L.&nbsp;1114‚??1 du code de la sant&eacute; publique.</p>

<p>III.&nbsp;&ndash;&nbsp;La composition, l&rsquo;organisation et le fonctionnement du comit&eacute; sont pr&eacute;cis&eacute;s par d&eacute;cret.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (8, 53, N'Article 2', N'<p>I.&nbsp;&ndash;&nbsp;Nul ne peut &ecirc;tre &eacute;cart&eacute; d&rsquo;une proc&eacute;dure de recrutement ou de l&rsquo;acc&egrave;s &agrave; un stage ou &agrave; une p&eacute;riode de formation au seul motif qu&rsquo;il serait atteint d&rsquo;une maladie chronique, notamment de diab&egrave;te. De m&ecirc;me, ce seul motif ne peut justifier de sanction, de rupture de la relation de travail ou de mesure discriminatoire, directe ou indirecte, notamment en mati&egrave;re de&nbsp;formation, de reclassement, d&rsquo;affectation, de qualification, de classification, de promotion professionnelle, de mutation ou de renouvellement de contrat.</p>

<p>I&nbsp;bis&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Le&nbsp;I ne fait pas obstacle &agrave; des d&eacute;cisions individuelles prises &agrave; la suite d&rsquo;un examen ou d&rsquo;un avis m&eacute;dical, pr&eacute;vues par voie l&eacute;gislative ou r&eacute;glementaire, justifi&eacute;es par les fonctions auxquelles la personne concern&eacute;e pr&eacute;tend, l&rsquo;&eacute;tat des traitements possibles et la s&eacute;curit&eacute; des personnes concern&eacute;es, de leurs coll&egrave;gues ou des tiers &eacute;voluant dans leur environnement de travail.</p>

<p>II.&nbsp;&ndash;&nbsp;Les&nbsp;I et&nbsp;I&nbsp;bis&nbsp;entrent en vigueur deux ans apr&egrave;s la promulgation de la pr&eacute;sente loi.</p>

<p>III&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Sur la base des travaux du comit&eacute; mentionn&eacute; &agrave; l&rsquo;article&nbsp;1er,&nbsp;les restrictions mentionn&eacute;es au&nbsp;I&nbsp;bis&nbsp;du pr&eacute;sent article sont r&eacute;vis&eacute;es au plus tard&nbsp;dans un d&eacute;lai de deux ans &agrave; compter de la promulgation de la pr&eacute;sente loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (8, 54, N'Article 3', N'<p>Au plus tard un an apr&egrave;s la promulgation de la pr&eacute;sente loi, le Gouvernement remet au Parlement un rapport &eacute;valuant les progr&egrave;s r&eacute;alis&eacute;s par le comit&eacute; d&rsquo;&eacute;valuation des textes encadrant l&rsquo;acc&egrave;s au march&eacute; du travail des personnes atteintes de maladies chroniques.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (8, 55, N'Article 4', N'<p>Une campagne de communication publique informant sur le diab&egrave;te et sensibilisant &agrave; l&rsquo;inclusion sur le march&eacute; du travail des personnes atteintes de diab&egrave;te est mise en &oelig;uvre au plus tard deux ans apr&egrave;s la promulgation de la pr&eacute;sente loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (9, 56, N'Article 1', N'<p>Le titre&nbsp;IV du livre&nbsp;Ier&nbsp;de la troisi&egrave;me partie du code du travail est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;La premi&egrave;re phrase de l&rsquo;article L.&nbsp;3141‚??17 est compl&eacute;t&eacute;e par les mots&nbsp;: &laquo;&nbsp;,&nbsp;sans pr&eacute;judice de l&rsquo;article L.&nbsp;3142‚??4‚??1&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Le paragraphe&nbsp;2 de la sous‚??section&nbsp;1 de la section&nbsp;1 du chapitre&nbsp;II est compl&eacute;t&eacute; par un article L.&nbsp;3142‚??4‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;3142‚??4‚??1.&nbsp;&ndash;&nbsp;Une convention ou un accord collectif d&rsquo;entreprise&nbsp;ou, &agrave; d&eacute;faut, une convention ou un accord de branche peut pr&eacute;voir la possibilit&eacute; pour le salari&eacute; de prendre, &agrave; la suite du cong&eacute; mentionn&eacute; au&nbsp;4&deg; de l&rsquo;article L.&nbsp;3142‚??4 ou de la p&eacute;riode d&rsquo;absence pr&eacute;vue &agrave; l&rsquo;article L.&nbsp;1225‚??65‚??1 en cas de d&eacute;c&egrave;s d&rsquo;un enfant, des jours de cong&eacute;s pay&eacute;s l&eacute;gaux et des jours de r&eacute;duction du temps de travail dans la limite des droits acquis, sans que l&rsquo;employeur ne puisse s&rsquo;y opposer.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (9, 57, N'Article 2', N'<p>Le paragraphe&nbsp;3 de la sous‚??section&nbsp;2 de la section&nbsp;4 du chapitre&nbsp;V du titre&nbsp;II du livre&nbsp;II de la premi&egrave;re partie du code du travail est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;&Agrave; l&rsquo;intitul&eacute;, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;enfant&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;d&eacute;c&eacute;d&eacute;&nbsp;ou&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;&Agrave; la premi&egrave;re phrase du premier alin&eacute;a de l&rsquo;article L.&nbsp;1225‚??65‚??1, les mots&nbsp;: &laquo;&nbsp;qui assume la charge d&rsquo;un enfant &acirc;g&eacute; de moins de vingt&nbsp;ans&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;dont l&rsquo;enfant est &acirc;g&eacute; de moins de vingt&nbsp;ans et dont il assume la charge est d&eacute;c&eacute;d&eacute; ou est&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 58, N'Article 1 AAA', N'<p>&Agrave; l&rsquo;article L.&nbsp;110‚??1‚??2 du code de l&rsquo;environnement, apr&egrave;s la deuxi&egrave;me occurrence du mot&nbsp;: &laquo;&nbsp;ressources&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;bas&eacute;e sur l&rsquo;&eacute;coconception&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 59, N'Article 1 AAB', N'<p>&Agrave; la premi&egrave;re phrase de l&rsquo;article&nbsp;L.&nbsp;110‚??1‚??1 du code de l&rsquo;environnement, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;vise&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;&agrave; atteindre une empreinte &eacute;cologique neutre dans le cadre du respect des limites plan&eacute;taires et&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 60, N'Article 1 AA', N'<p>Le&nbsp;1&deg; du&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;La premi&egrave;re phrase est ainsi modifi&eacute;e&nbsp;:</p>

<p>a)&nbsp;Le taux&nbsp;: &laquo;&nbsp;10&nbsp;%&nbsp;&raquo; est remplac&eacute; par le taux&nbsp;: &laquo;&nbsp;15&nbsp;%&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Apr&egrave;s la seconde occurrence du mot&nbsp;: &laquo;&nbsp;r&eacute;duisant&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;de 5&nbsp;%&nbsp;&raquo;&nbsp;;</p>

<p>c)&nbsp;L&rsquo;ann&eacute;e&nbsp;: &laquo;&nbsp;2020&nbsp;&raquo; est remplac&eacute;e par l&rsquo;ann&eacute;e&nbsp;: &laquo;&nbsp;2030&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;L&rsquo;avant‚??derni&egrave;re phrase est supprim&eacute;e.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 61, N'Article 1 AC', N'<p>Apr&egrave;s le&nbsp;4&deg; du&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un&nbsp;4&deg;&nbsp;bis&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;4&deg;&nbsp;bis&nbsp;Tendre vers l&rsquo;objectif de 100&nbsp;% de plastique recycl&eacute; d&rsquo;ici le 1er&nbsp;janvier&nbsp;2025&nbsp;;&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 62, N'Article 1 ADA', N'<p>Le&nbsp;II de l&rsquo;article&nbsp;L.&nbsp;541‚??2‚??1 du code de l&rsquo;environnement est compl&eacute;t&eacute; par deux&nbsp;alin&eacute;as ainsi r&eacute;dig&eacute;s&nbsp;:</p>

<p>&laquo;&nbsp;Les producteurs ou les d&eacute;tenteurs de d&eacute;chets ne peuvent &eacute;liminer ou&nbsp;faire &eacute;liminer leurs d&eacute;chets dans des installations de stockage ou d&rsquo;incin&eacute;ration&nbsp;de d&eacute;chets que s&rsquo;ils justifient qu&rsquo;ils respectent les obligations de tri prescrites au pr&eacute;sent chapitre.</p>

<p>&laquo;&nbsp;Le troisi&egrave;me alin&eacute;a du pr&eacute;sent&nbsp;II n&rsquo;est pas applicable aux r&eacute;sidus de centres de tri.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 63, N'Article 1 AD', N'<p>La sous‚??section&nbsp;2 de la section&nbsp;2 du chapitre&nbsp;Ier&nbsp;du titre&nbsp;IV du livre&nbsp;V du code de l&rsquo;environnement, telle qu&rsquo;elle r&eacute;sulte de l&rsquo;article&nbsp;8 de la pr&eacute;sente loi, est compl&eacute;t&eacute;e par un article&nbsp;L.&nbsp;541‚??10‚??8‚??5 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;541‚??10‚??8‚??5.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;La France se donne pour objectif d&rsquo;atteindre la fin de la mise sur le march&eacute; d&rsquo;emballages en plastique &agrave; usage unique d&rsquo;ici &agrave;&nbsp;2040.</p>

<p>&laquo;&nbsp;Un objectif de r&eacute;duction, un objectif de r&eacute;utilisation et de r&eacute;emploi et un objectif de recyclage sont fix&eacute;s par d&eacute;cret pour la p&eacute;riode 2021‚??2025, puis pour chaque p&eacute;riode cons&eacute;cutive de cinq&nbsp;ans.</p>

<p>&laquo;&nbsp;Une strat&eacute;gie nationale pour la r&eacute;duction, la r&eacute;utilisation, le r&eacute;emploi et le recyclage des emballages en plastique &agrave; usage unique est d&eacute;finie par voie r&eacute;glementaire avant le 1er&nbsp;janvier&nbsp;2022. Cette strat&eacute;gie d&eacute;termine les mesures sectorielles ou de port&eacute;e g&eacute;n&eacute;rale n&eacute;cessaires pour atteindre les objectifs mentionn&eacute;s au deuxi&egrave;me alin&eacute;a du pr&eacute;sent&nbsp;I. Ces mesures peuvent pr&eacute;voir notamment la mobilisation des fili&egrave;res &agrave; responsabilit&eacute; &eacute;largie du producteur et de leurs &eacute;co‚??modulations, l&rsquo;adaptation des r&egrave;gles de mise sur le march&eacute; et de distribution des emballages ainsi que le recours &agrave; d&rsquo;&eacute;ventuels outils &eacute;conomiques.</p>

<p>&laquo;&nbsp;Cette strat&eacute;gie nationale est &eacute;labor&eacute;e et r&eacute;vis&eacute;e en concertation avec les fili&egrave;res industrielles concern&eacute;es, les collectivit&eacute;s territoriales et les associations de consommateurs et de protection de l&rsquo;environnement.</p>

<p>&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;(Supprim&eacute;)&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 64, N'Article 1 AE', N'<p>Avant le dernier alin&eacute;a du&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Afin de lutter contre la pollution des plastiques dans l&rsquo;environnement et de r&eacute;duire l&rsquo;exposition des populations aux particules de plastique, les politiques publiques fixent les actions &agrave; mettre en &oelig;uvre pour atteindre les objectifs mentionn&eacute;s au pr&eacute;sent&nbsp;I, en prenant en compte les enjeux sanitaires, environnementaux et &eacute;conomiques. Elles favorisent la recherche et d&eacute;veloppement, s&rsquo;appuyant chaque fois que cela est possible sur le savoir‚??faire et les ressources ou mati&egrave;res premi&egrave;res locales, et les substituts ou alternatives sains, durables, innovants et solidaires. Elles int&egrave;grent une dimension sp&eacute;cifique d&rsquo;accompagnement dans la reconversion des entreprises concern&eacute;es par les obligations r&eacute;sultant des objectifs mentionn&eacute;s au pr&eacute;sent&nbsp;I. Un rapport d&rsquo;&eacute;valuation est remis au Parlement en m&ecirc;me temps que le plan pr&eacute;vu &agrave; l&rsquo;article&nbsp;L.&nbsp;541‚??11.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 65, N'Article 1 AF', N'<p>I.&nbsp;&ndash;&nbsp;Apr&egrave;s la troisi&egrave;me phrase du&nbsp;1&deg; du&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement, sont ins&eacute;r&eacute;es deux&nbsp;phrases ainsi r&eacute;dig&eacute;es&nbsp;: &laquo;&nbsp;&Agrave; ce titre, la France se dote d&rsquo;une trajectoire nationale visant &agrave; augmenter la part des emballages r&eacute;employ&eacute;s mis en march&eacute; par rapport aux emballages &agrave; usage unique, de mani&egrave;re &agrave; atteindre une proportion de 5&nbsp;% des emballages r&eacute;employ&eacute;s mis en march&eacute; en France en 2023, exprim&eacute;s en unit&eacute; de vente ou &eacute;quivalent unit&eacute; de vente, et de 10&nbsp;% des emballages r&eacute;employ&eacute;s mis en march&eacute; en France en 2027, exprim&eacute;s en unit&eacute; de vente ou &eacute;quivalent unit&eacute; de vente. Les emballages r&eacute;employ&eacute;s doivent &ecirc;tre recyclables.&nbsp;&raquo;</p>

<p>II&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Un observatoire du r&eacute;emploi et de la r&eacute;utilisation est cr&eacute;&eacute;&nbsp;avant le 1er&nbsp;janvier&nbsp;2021. Cet observatoire est charg&eacute; d&rsquo;&eacute;valuer la pertinence&nbsp;des solutions de r&eacute;emploi et de r&eacute;utilisation d&rsquo;un point de vue environnemental&nbsp;et &eacute;conomique, de d&eacute;finir la trajectoire nationale visant &agrave; augmenter la part des&nbsp;emballages r&eacute;utilis&eacute;s et r&eacute;employ&eacute;s mis en march&eacute; par rapport aux&nbsp;emballages &agrave; usage unique et d&rsquo;accompagner, en lien avec les &eacute;co‚??organismes,&nbsp;les exp&eacute;rimentations et le d&eacute;ploiement des moyens n&eacute;cessaires &agrave; l&rsquo;atteinte des objectifs d&eacute;finis dans les cahiers des charges de ces derniers.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 66, N'Article 1 AG', N'<p>Le&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Le&nbsp;7&deg; est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;: &laquo;&nbsp;Dans ce cadre, la&nbsp;mise en d&eacute;charge des d&eacute;chets non dangereux valorisables est progressivement&nbsp;interdite&nbsp;;&nbsp;&raquo;</p>

<p>2&deg;&nbsp;Apr&egrave;s le m&ecirc;me&nbsp;7&deg;, il est ins&eacute;r&eacute; un&nbsp;7&deg;&nbsp;bis&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;7&deg;&nbsp;bis&nbsp;R&eacute;duire les quantit&eacute;s de d&eacute;chets m&eacute;nagers et assimil&eacute;s admis en installation de stockage en 2035 &agrave; 10&nbsp;% des quantit&eacute;s de d&eacute;chets m&eacute;nagers et assimil&eacute;s produits mesur&eacute;es en masse&nbsp;;&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 67, N'Article 1 AH', N'<p>Apr&egrave;s le&nbsp;9&deg; du&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??1 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un&nbsp;10&deg; ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;10&deg;&nbsp;R&eacute;duire le gaspillage alimentaire, d&rsquo;ici 2025, de 50&nbsp;% par rapport &agrave;&nbsp;son niveau de 2015 dans les domaines de la distribution alimentaire et de la restauration collective et, d&rsquo;ici 2030, de 50&nbsp;% par rapport &agrave; son niveau de&nbsp;2015 dans les domaines de la consommation, de la production, de la transformation et de la restauration commerciale.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 68, N'Article 1 B', N'<p>L&rsquo;article&nbsp;L.&nbsp;121‚??4 du code de la consommation est compl&eacute;t&eacute; par un&nbsp;23&deg; ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;23&deg;&nbsp;Dans une publicit&eacute;, de donner l&rsquo;impression, par des op&eacute;rations de promotion coordonn&eacute;es &agrave; l&rsquo;&eacute;chelle nationale, que le consommateur b&eacute;n&eacute;ficie d&rsquo;une r&eacute;duction de prix comparable &agrave; celle des soldes, tels que d&eacute;finis &agrave; l&rsquo;article&nbsp;L.&nbsp;310‚??3 du code de commerce, en dehors de leur p&eacute;riode l&eacute;gale mentionn&eacute;e au m&ecirc;me article&nbsp;L.&nbsp;310‚??3.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 69, N'Article 1', N'<p>I.&nbsp;&ndash;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;L.&nbsp;541‚??9 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un article L.&nbsp;541‚??9‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;541‚??9‚??1.&nbsp;&ndash;&nbsp;Afin d&rsquo;am&eacute;liorer l&rsquo;information des consommateurs, les producteurs et importateurs de produits g&eacute;n&eacute;rateurs de d&eacute;chets informent les consommateurs, par voie de marquage, d&rsquo;&eacute;tiquetage, d&rsquo;affichage ou par tout autre proc&eacute;d&eacute; appropri&eacute;, sur leurs qualit&eacute;s et caract&eacute;ristiques environnementales, notamment l&rsquo;incorporation de mati&egrave;re recycl&eacute;e, l&rsquo;emploi de ressources renouvelables, la durabilit&eacute;, la compostabilit&eacute;, la r&eacute;parabilit&eacute;, les possibilit&eacute;s de r&eacute;emploi, la recyclabilit&eacute; et la pr&eacute;sence de substances dangereuses, de m&eacute;taux pr&eacute;cieux ou de terres rares, en coh&eacute;rence avec le droit de l&rsquo;Union europ&eacute;enne. Ces qualit&eacute;s et caract&eacute;ristiques sont &eacute;tablies en privil&eacute;giant une analyse de l&rsquo;ensemble du cycle de vie des produits. Les&nbsp;consommateurs sont &eacute;galement inform&eacute;s des primes et p&eacute;nalit&eacute;s mentionn&eacute;es&nbsp;&agrave; l&rsquo;article L.&nbsp;541‚??10‚??3 vers&eacute;es par le producteur en fonction de crit&egrave;res de performance environnementale. Les informations pr&eacute;vues au pr&eacute;sent alin&eacute;a doivent &ecirc;tre visibles ou accessibles par le consommateur au moment de l&rsquo;acte d&rsquo;achat. Le producteur ou l&rsquo;importateur est charg&eacute; de mettre les donn&eacute;es relatives aux qualit&eacute;s et caract&eacute;ristiques pr&eacute;cit&eacute;es &agrave; disposition du public par voie &eacute;lectronique, dans un format ais&eacute;ment r&eacute;utilisable et exploitable par un syst&egrave;me de traitement automatis&eacute; sous une forme agr&eacute;g&eacute;e. Un acc&egrave;s centralis&eacute; &agrave; ces donn&eacute;es peut &ecirc;tre mis en place par l&rsquo;autorit&eacute; administrative selon des modalit&eacute;s pr&eacute;cis&eacute;es par d&eacute;cret.</p>

<p>&laquo;&nbsp;Les produits et emballages en mati&egrave;re plastique dont la compostabilit&eacute; ne peut &ecirc;tre obtenue qu&rsquo;en unit&eacute; industrielle ne peuvent porter la mention &ldquo;compostable&rdquo;.</p>

<p>&laquo;&nbsp;Les produits et emballages en mati&egrave;re plastique compostables en compostage domestique ou industriel portent la mention &ldquo;Ne pas jeter dans la nature&rdquo;.</p>

<p>&laquo;&nbsp;Il est interdit de faire figurer sur un produit ou un emballage les mentions &ldquo;biod&eacute;gradable&rdquo;, &ldquo;respectueux de l&rsquo;environnement&rdquo; ou toute autre mention &eacute;quivalente.</p>

<p>&laquo;&nbsp;Lorsqu&rsquo;il est fait mention du caract&egrave;re recycl&eacute; d&rsquo;un produit, il est pr&eacute;cis&eacute; le pourcentage de mati&egrave;res recycl&eacute;es effectivement incorpor&eacute;es.</p>

<p>&laquo;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat fixe les modalit&eacute;s d&rsquo;application du pr&eacute;sent&nbsp;article, notamment la d&eacute;finition des qualit&eacute;s et caract&eacute;ristiques environnementales, les modalit&eacute;s de leur &eacute;tablissement, les cat&eacute;gories de produits concern&eacute;s ainsi que les modalit&eacute;s d&rsquo;information des consommateurs. Un d&eacute;cret, pris apr&egrave;s avis de l&rsquo;Agence nationale de s&eacute;curit&eacute; sanitaire de l&rsquo;alimentation, de&nbsp;l&rsquo;environnement et du travail, identifie les substances dangereuses mentionn&eacute;es&nbsp;au premier alin&eacute;a.&nbsp;&raquo;</p>

<p>I&nbsp;bis.&nbsp;&ndash;&nbsp;Le chapitre&nbsp;II du titre&nbsp;III du livre&nbsp;II de la cinqui&egrave;me partie du code de la sant&eacute; publique est compl&eacute;t&eacute; par un article&nbsp;L.&nbsp;5232‚??5 ainsi r&eacute;tabli&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;5232‚??5.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;Toute personne qui met sur le march&eacute; des produits qui, au terme de leur fabrication, comportent des substances dont&nbsp;l&rsquo;Agence nationale de s&eacute;curit&eacute; sanitaire de l&rsquo;alimentation, de l&rsquo;environnement&nbsp;et du travail qualifie les propri&eacute;t&eacute;s de perturbation endocrinienne d&rsquo;av&eacute;r&eacute;es ou pr&eacute;sum&eacute;es met &agrave; la disposition du public par voie &eacute;lectronique, dans un format ouvert, ais&eacute;ment r&eacute;utilisable et exploitable par un syst&egrave;me de traitement automatis&eacute;, pour chacun des produits concern&eacute;s, les informations permettant d&rsquo;identifier la pr&eacute;sence de telles substances dans ces produits.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 70, N'Article 1 Bis A', N'<p>Le code de la sant&eacute; publique est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;L.&nbsp;1313‚??10, il est ins&eacute;r&eacute; un article L.&nbsp;1313‚??10‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;1313‚??10‚??1.&nbsp;&ndash;&nbsp;Lorsque l&rsquo;Agence nationale de s&eacute;curit&eacute; sanitaire&nbsp;de l&rsquo;alimentation, de l&rsquo;environnement et du travail a &eacute;mis des recommandations&nbsp;sp&eacute;cifiques &agrave; destination des femmes enceintes sur certaines cat&eacute;gories de produits contenant des substances &agrave; caract&egrave;re perturbateur endocrinien, en&nbsp;tenant compte des risques d&rsquo;exposition, le pouvoir r&eacute;glementaire peut imposer&nbsp;aux fabricants des produits concern&eacute;s d&rsquo;y apposer un pictogramme ou&nbsp;d&rsquo;avoir recours &agrave; un autre moyen de marquage, d&rsquo;&eacute;tiquetage ou d&rsquo;affichage.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;(Supprim&eacute;)</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 71, N'Article 1 Bis', N'<p>I.&nbsp;&ndash;&nbsp;Un dispositif d&rsquo;affichage environnemental ou environnemental et social volontaire est institu&eacute;. Il est destin&eacute; &agrave; apporter au consommateur une information relative aux caract&eacute;ristiques environnementales ou aux caract&eacute;ristiques environnementales et au respect de crit&egrave;res sociaux d&rsquo;un bien, d&rsquo;un service ou d&rsquo;une cat&eacute;gorie de biens ou de services, bas&eacute;e principalement sur une analyse du cycle de vie. Les personnes priv&eacute;es ou publiques qui souhaitent mettre en place cet affichage environnemental ou environnemental et social, par voie de marquage, d&rsquo;&eacute;tiquetage ou par tout autre proc&eacute;d&eacute; appropri&eacute;, notamment par une d&eacute;mat&eacute;rialisation fiable, mise &agrave; jour et juste des donn&eacute;es, se conforment &agrave; des dispositifs d&eacute;finis par d&eacute;crets, qui pr&eacute;cisent les cat&eacute;gories de biens et services concern&eacute;es, la m&eacute;thodologie &agrave; utiliser ainsi que les modalit&eacute;s d&rsquo;affichage.</p>

<p>II.&nbsp;&ndash;&nbsp;Une exp&eacute;rimentation est men&eacute;e pour une dur&eacute;e de dix‚??huit&nbsp;mois &agrave; compter de la publication de la pr&eacute;sente loi afin d&rsquo;&eacute;valuer diff&eacute;rentes&nbsp;m&eacute;thodologies et modalit&eacute;s d&rsquo;affichage environnemental ou environnemental&nbsp;et social. Cette exp&eacute;rimentation est suivie d&rsquo;un bilan, qui est transmis au Parlement, comprenant une &eacute;tude de faisabilit&eacute; et une &eacute;valuation socio‚??&eacute;conomique de ces dispositifs. Sur la base de ce bilan, des d&eacute;crets d&eacute;finissent la m&eacute;thodologie et les modalit&eacute;s d&rsquo;affichage environnemental ou environnemental et social s&rsquo;appliquant aux cat&eacute;gories de biens et services concern&eacute;s.</p>

<p>III.&nbsp;&ndash;&nbsp;Le dispositif pr&eacute;vu au&nbsp;I est rendu obligatoire, prioritairement pour le secteur du textile d&rsquo;habillement, dans des conditions relatives &agrave; la nature des produits et &agrave; la taille de l&rsquo;entreprise d&eacute;finies par d&eacute;cret, apr&egrave;s l&rsquo;entr&eacute;e en vigueur d&rsquo;une disposition adopt&eacute;e par l&rsquo;Union europ&eacute;enne poursuivant le m&ecirc;me objectif.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 72, N'Article 2', N'<p>Apr&egrave;s l&rsquo;article&nbsp;L.&nbsp;541‚??9 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un article L.&nbsp;541‚??9‚??2 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;541‚??9‚??2.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;Les producteurs, importateurs, distributeurs ou autres metteurs sur le march&eacute; d&rsquo;&eacute;quipements &eacute;lectriques et &eacute;lectroniques communiquent sans frais aux vendeurs de leurs produits ainsi qu&rsquo;&agrave; toute personne qui en fait la demande l&rsquo;indice de r&eacute;parabilit&eacute; de ces &eacute;quipements ainsi que les param&egrave;tres ayant permis de l&rsquo;&eacute;tablir. Cet indice vise &agrave; informer le consommateur sur la capacit&eacute; &agrave; r&eacute;parer le produit concern&eacute;.</p>

<p>&laquo;&nbsp;Les vendeurs d&rsquo;&eacute;quipements &eacute;lectriques et &eacute;lectroniques ainsi que ceux utilisant un site internet, une plateforme ou toute autre voie de distribution en ligne dans le cadre de leur activit&eacute; commerciale en France informent sans frais le consommateur, au moment de l&rsquo;acte d&rsquo;achat, par voie de marquage, d&rsquo;&eacute;tiquetage, d&rsquo;affichage ou par tout autre proc&eacute;d&eacute; appropri&eacute; de l&rsquo;indice de r&eacute;parabilit&eacute; de ces &eacute;quipements. Le fabricant ou l&rsquo;importateur est charg&eacute; de mettre ces informations &agrave; la disposition du public par voie &eacute;lectronique, dans un format ais&eacute;ment r&eacute;utilisable et exploitable par un syst&egrave;me de traitement automatis&eacute; sous une forme agr&eacute;g&eacute;e. Un acc&egrave;s centralis&eacute; &agrave; ces donn&eacute;es peut &ecirc;tre mis en place par l&rsquo;autorit&eacute; administrative selon des modalit&eacute;s pr&eacute;cis&eacute;es par d&eacute;cret. Le vendeur met &eacute;galement &agrave; la disposition du consommateur les param&egrave;tres ayant permis d&rsquo;&eacute;tablir l&rsquo;indice de r&eacute;parabilit&eacute; du produit, par tout proc&eacute;d&eacute; appropri&eacute;.</p>

<p>&laquo;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat d&eacute;finit les modalit&eacute;s d&rsquo;application du pr&eacute;sent&nbsp;I selon les cat&eacute;gories d&rsquo;&eacute;quipements &eacute;lectriques et &eacute;lectroniques, notamment les crit&egrave;res et le mode de calcul retenus pour l&rsquo;&eacute;tablissement de l&rsquo;indice. Les crit&egrave;res servant &agrave; l&rsquo;&eacute;laboration de l&rsquo;indice de r&eacute;parabilit&eacute; incluent obligatoirement le prix des pi&egrave;ces d&eacute;tach&eacute;es n&eacute;cessaires au bon fonctionnement du produit et, chaque fois que cela est pertinent, la pr&eacute;sence d&rsquo;un compteur d&rsquo;usage visible par le consommateur.</p>

<p>&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;&Agrave; compter du 1er&nbsp;janvier&nbsp;2024, les producteurs ou importateurs de certains produits communiquent sans frais aux vendeurs et &agrave; toute personne qui en fait la demande l&rsquo;indice de durabilit&eacute; de ces produits, et les param&egrave;tres ayant permis de l&rsquo;&eacute;tablir. Cet indice inclut notamment de nouveaux crit&egrave;res tels que la fiabilit&eacute; et la robustesse du produit et vient compl&eacute;ter ou remplacer l&rsquo;indice de r&eacute;parabilit&eacute; pr&eacute;vu au&nbsp;I du pr&eacute;sent article lorsque celui‚??ci existe.</p>

<p>&laquo;&nbsp;Les vendeurs des produits concern&eacute;s ainsi que ceux utilisant un site internet, une plateforme ou toute autre voie de distribution en ligne dans le cadre de leur activit&eacute; commerciale en France informent sans frais le consommateur, au moment de l&rsquo;achat du bien, par voie de marquage, d&rsquo;&eacute;tiquetage, d&rsquo;affichage ou par tout autre proc&eacute;d&eacute; appropri&eacute; de l&rsquo;indice de durabilit&eacute; de ces produits. Le vendeur met &eacute;galement &agrave; disposition du consommateur les param&egrave;tres ayant permis d&rsquo;&eacute;tablir l&rsquo;indice de durabilit&eacute; du produit, par tout proc&eacute;d&eacute; appropri&eacute;.</p>

<p>&laquo;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat fixe la liste des produits et &eacute;quipements concern&eacute;s ainsi que les modalit&eacute;s d&rsquo;application du pr&eacute;sent&nbsp;II.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 73, N'Article 3', N'<p>I.&nbsp;&ndash;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;L.&nbsp;541‚??9 du code de l&rsquo;environnement, il est ins&eacute;r&eacute; un article L.&nbsp;541‚??9‚??3 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Art.&nbsp;L.&nbsp;541‚??9‚??3.&nbsp;&ndash;&nbsp;Tout produit mis sur le march&eacute; &agrave; destination des m&eacute;nages soumis au&nbsp;I de l&rsquo;article&nbsp;L.&nbsp;541‚??10, &agrave; l&rsquo;exclusion des emballages m&eacute;nagers de boissons en verre, fait l&rsquo;objet d&rsquo;une signal&eacute;tique informant le consommateur que ce produit fait l&rsquo;objet de r&egrave;gles de tri.</p>

<p>&laquo;&nbsp;Cette signal&eacute;tique est accompagn&eacute;e d&rsquo;une information pr&eacute;cisant les modalit&eacute;s de tri ou d&rsquo;apport du d&eacute;chet issu du produit. Si plusieurs &eacute;l&eacute;ments du produit ou des d&eacute;chets issus du produit font l&rsquo;objet de modalit&eacute;s de tri diff&eacute;rentes, ces modalit&eacute;s sont d&eacute;taill&eacute;es &eacute;l&eacute;ment par &eacute;l&eacute;ment. Ces informations figurent sur le produit, son emballage ou, &agrave; d&eacute;faut, dans les autres documents fournis avec le produit, sans pr&eacute;judice des symboles appos&eacute;s en application d&rsquo;autres dispositions. L&rsquo;ensemble de cette signal&eacute;tique est regroup&eacute; de mani&egrave;re d&eacute;mat&eacute;rialis&eacute;e et est disponible en ligne pour en faciliter l&rsquo;assimilation et en expliciter les modalit&eacute;s et le sens.</p>

<p>&laquo;&nbsp;L&rsquo;&eacute;co‚??organisme charg&eacute; de cette signal&eacute;tique veille &agrave; ce que l&rsquo;information inscrite sur les emballages m&eacute;nagers et pr&eacute;cisant les modalit&eacute;s de tri ou d&rsquo;apport du d&eacute;chet issu du produit &eacute;volue vers une uniformisation d&egrave;s lors que plus de 50&nbsp;% de la population est couverte par un dispositif harmonis&eacute;.</p>

<p>&laquo;&nbsp;Les conditions d&rsquo;application du pr&eacute;sent article sont pr&eacute;cis&eacute;es par d&eacute;cret en Conseil d&rsquo;&Eacute;tat.&nbsp;&raquo;</p>

<p>II.&nbsp;&ndash;&nbsp;(Supprim&eacute;)</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 74, N'Article 3 Bis', N'<p>Le&nbsp;III de l&rsquo;article&nbsp;18 de la loi&nbsp;n&deg;&nbsp;65‚??557 du 10&nbsp;juillet&nbsp;1965 fixant le statut de la copropri&eacute;t&eacute; des immeubles b&acirc;tis est compl&eacute;t&eacute; par un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;&ndash;&nbsp;d&rsquo;informer les copropri&eacute;taires des r&egrave;gles locales en mati&egrave;re de tri des d&eacute;chets et de l&rsquo;adresse, des horaires et des modalit&eacute;s d&rsquo;acc&egrave;s des d&eacute;chetteries dont d&eacute;pend la copropri&eacute;t&eacute;. Cette information est affich&eacute;e de mani&egrave;re visible dans les espaces affect&eacute;s &agrave; la d&eacute;pose des ordures m&eacute;nag&egrave;res par les occupants de la copropri&eacute;t&eacute; et transmise au moins une fois par an &agrave; ces occupants ainsi qu&rsquo;aux copropri&eacute;taires.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (10, 75, N'Article 4', N'<p>I.&nbsp;&ndash;&nbsp;L&rsquo;article&nbsp;L.&nbsp;111‚??4 du code de la consommation est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;La premi&egrave;re phrase du premier alin&eacute;a est remplac&eacute;e par six&nbsp;phrases ainsi r&eacute;dig&eacute;es&nbsp;: &laquo;&nbsp;Le fabricant ou l&rsquo;importateur de biens meubles informe le vendeur professionnel de la disponibilit&eacute; ou de la non‚??disponibilit&eacute; des pi&egrave;ces d&eacute;tach&eacute;es indispensables &agrave; l&rsquo;utilisation des biens concern&eacute;s et, le cas &eacute;ch&eacute;ant, de la p&eacute;riode pendant laquelle ou de la date jusqu&rsquo;&agrave; laquelle ces pi&egrave;ces sont disponibles sur le march&eacute;. Pour les &eacute;quipements &eacute;lectriques et &eacute;lectroniques et les &eacute;l&eacute;ments d&rsquo;ameublement, lorsque cette information n&rsquo;est pas fournie au vendeur professionnel, les pi&egrave;ces d&eacute;tach&eacute;es indispensables &agrave; l&rsquo;utilisation des biens sont r&eacute;put&eacute;es non disponibles. Les fabricants ou importateurs d&rsquo;&eacute;quipements &eacute;lectriques et &eacute;lectroniques informent les vendeurs de leurs produits ainsi que les r&eacute;parateurs professionnels, &agrave; la demande de ces derniers, du d&eacute;tail des &eacute;l&eacute;ments constituant l&rsquo;engagement de dur&eacute;e de disponibilit&eacute; des pi&egrave;ces d&eacute;tach&eacute;es. Cette information est rendue disponible notamment &agrave; partir d&rsquo;un support d&eacute;mat&eacute;rialis&eacute;. Pour les producteurs d&rsquo;&eacute;quipements &eacute;lectrom&eacute;nagers, de petits &eacute;quipements informatiques et de t&eacute;l&eacute;communications, d&rsquo;&eacute;crans et de moniteurs, les pi&egrave;ces d&eacute;tach&eacute;es doivent &ecirc;tre disponibles pendant une dur&eacute;e fix&eacute;e par d&eacute;cret en Conseil d&rsquo;&Eacute;tat et qui ne peut &ecirc;tre inf&eacute;rieure &agrave; cinq&nbsp;ans &agrave; compter de la date de mise sur le march&eacute; de la derni&egrave;re unit&eacute; du mod&egrave;le concern&eacute;. Ce d&eacute;cret &eacute;tablit la liste des cat&eacute;gories d&rsquo;&eacute;quipements &eacute;lectriques et &eacute;lectroniques et de pi&egrave;ces concern&eacute;s.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Au d&eacute;but de la seconde phrase du m&ecirc;me premier alin&eacute;a, les mots&nbsp;: &laquo;&nbsp;Cette information est d&eacute;livr&eacute;e&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;Ces informations sont d&eacute;livr&eacute;es&nbsp;&raquo; et le mot&nbsp;: &laquo;&nbsp;confirm&eacute;e&nbsp;&raquo; est remplac&eacute; par le mot&nbsp;: &laquo;&nbsp;confirm&eacute;es&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;Au deuxi&egrave;me alin&eacute;a, les mots&nbsp;: &laquo;&nbsp;deux&nbsp;mois&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;quinze&nbsp;jours ouvrables&nbsp;&raquo;&nbsp;;</p>

<p>4&deg;&nbsp;Apr&egrave;s le m&ecirc;me deuxi&egrave;me alin&eacute;a, il est ins&eacute;r&eacute; un alin&eacute;a ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Pour certaines cat&eacute;gories de biens d&eacute;finies par d&eacute;cret, lorsqu&rsquo;une pi&egrave;ce d&eacute;tach&eacute;e indispensable &agrave; l&rsquo;utilisation d&rsquo;un bien disponible sur le march&eacute; peut &ecirc;tre fabriqu&eacute;e par un moyen d&rsquo;impression en trois&nbsp;dimensions et qu&rsquo;elle n&rsquo;est plus disponible sur le march&eacute;, le fabricant ou l&rsquo;importateur de biens meubles doit, sous r&eacute;serve du respect des droits de propri&eacute;t&eacute; intellectuelle et en particulier sous r&eacute;serve du consentement du d&eacute;tenteur de la propri&eacute;t&eacute; intellectuelle, fournir aux vendeurs professionnels ou aux r&eacute;parateurs, agr&eacute;&eacute;s ou non, qui le demandent le plan de fabrication par un moyen d&rsquo;impression en trois&nbsp;dimensions de la pi&egrave;ce d&eacute;tach&eacute;e ou, &agrave; d&eacute;faut, les informations techniques utiles &agrave; l&rsquo;&eacute;laboration de ce plan dont le fabricant dispose.&nbsp;&raquo;</p>

<p>II.&nbsp;&ndash;&nbsp;Le chapitre&nbsp;IV du titre&nbsp;II du livre&nbsp;II du code de la consommation est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;L&rsquo;article&nbsp;L.&nbsp;224‚??67 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Au premier alin&eacute;a, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;automobiles&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;ou de v&eacute;hicules &agrave; deux&nbsp;ou trois&nbsp;roues&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Le troisi&egrave;me alin&eacute;a est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;Les modalit&eacute;s d&rsquo;information du consommateur sont fix&eacute;es par d&eacute;cret.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Est ajout&eacute;e une section&nbsp;16 ainsi r&eacute;dig&eacute;e&nbsp;:</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 76, N'Article 1', N'<p>( Supprim&eacute; )&nbsp;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 77, N'Article 2', N'<p>&Agrave; la premi&egrave;re phase du dernier alin&eacute;a de l&rsquo;article L.&nbsp;821‚??1 du code de la s&eacute;curit&eacute; sociale, les mots&nbsp;: &laquo;&nbsp;est mari&eacute; ou vit maritalement ou est li&eacute; par un pacte civil de solidarit&eacute; et&nbsp;&raquo; sont supprim&eacute;s.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 78, N'Article 3', N'<p>Apr&egrave;s le mot&nbsp;: &laquo;&nbsp;int&eacute;ress&eacute;&nbsp;&raquo;, la fin du premier alin&eacute;a de l&rsquo;article L.&nbsp;821‚??3&nbsp;du code de la s&eacute;curit&eacute; sociale est supprim&eacute;e</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 79, N'Article 4', N'<p>Au premier alin&eacute;a du&nbsp;I de l&rsquo;article L.&nbsp;245‚??1 du code de l&rsquo;action sociale et des familles, apr&egrave;s la premi&egrave;re occurrence du mot&nbsp;: &laquo;&nbsp;d&eacute;cret&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;qui ne peut &ecirc;tre inf&eacute;rieure &agrave; 65 ans&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 80, N'Article 5', N'<p>(Supprim&eacute;)</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (11, 81, N'Article 6', N'<p>I.&nbsp;&ndash;&nbsp;La perte de recettes et la charge pour l&rsquo;&Eacute;tat&nbsp;r&eacute;sultant de la pr&eacute;sente loi&nbsp;sont compens&eacute;es &agrave; due concurrence par la cr&eacute;ation d&rsquo;une taxe additionnelle&nbsp;aux droits mentionn&eacute;s aux articles&nbsp;575 et 575&nbsp;A du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>

<p>II.&nbsp;&ndash;&nbsp;La charge pour les collectivit&eacute;s territoriales&nbsp;r&eacute;sultant de la pr&eacute;sente&nbsp;loi est compens&eacute;e &agrave; due concurrence par la majoration de la dotation globale de fonctionnement et, corr&eacute;lativement pour l&rsquo;&Eacute;tat, par la cr&eacute;ation d&rsquo;une taxe additionnelle aux droits mentionn&eacute;s aux articles&nbsp;575 et&nbsp;575&nbsp;A du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>

<p>III.&nbsp;&ndash;&nbsp;La charge pour les organismes de s&eacute;curit&eacute; sociale r&eacute;sultant de la pr&eacute;sente loi est compens&eacute;e &agrave; due concurrence par la majoration des droits mentionn&eacute;s aux articles&nbsp;575 et&nbsp;575&nbsp;A du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (12, 82, N'Article 1', N'<p>( Supprim&eacute; )</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (12, 83, N'Article 2', N'<p>I.&nbsp;&ndash;&nbsp;(Non modifi&eacute;)</p>

<p>II&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Le Gouvernement remet au Parlement un rapport sur la&nbsp;mise en &oelig;uvre du d&eacute;cret mentionn&eacute; au deuxi&egrave;me alin&eacute;a de l&rsquo;article L.&nbsp;146‚??5&nbsp;du code de l&rsquo;action sociale et des familles, dans un d&eacute;lai de&nbsp;dix‚??huit mois &agrave; compter de&nbsp;l&rsquo;entr&eacute;e en vigueur de ce d&eacute;cret. Ce rapport traite&nbsp;notamment de l&rsquo;&eacute;volution du reste &agrave; charge des personnes ayant d&eacute;pos&eacute; au moins une demande aupr&egrave;s d&rsquo;un fonds d&eacute;partemental de compensation du handicap.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (12, 84, N'Article 3', N'<p>Le chapitre&nbsp;V du titre&nbsp;IV du livre&nbsp;II du code de l&rsquo;action sociale et des familles est ainsi modifi&eacute;&nbsp;:</p>

<p>1&deg;&nbsp;L&rsquo;article&nbsp;L.&nbsp;245‚??5 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Au d&eacute;but, est ajout&eacute;e la mention&nbsp;: &laquo;&nbsp;I.&nbsp;&ndash;&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Il est ajout&eacute; un&nbsp;II ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Le pr&eacute;sident du conseil d&eacute;partemental prend toutes mesures pour v&eacute;rifier les d&eacute;clarations des b&eacute;n&eacute;ficiaires et s&rsquo;assurer de l&rsquo;effectivit&eacute; de l&rsquo;utilisation de l&rsquo;aide qu&rsquo;ils re&ccedil;oivent. Il peut mettre en &oelig;uvre un contr&ocirc;le d&rsquo;effectivit&eacute;, portant sur une p&eacute;riode de r&eacute;f&eacute;rence qui ne peut &ecirc;tre inf&eacute;rieure &agrave; six&nbsp;mois, qui ne peut s&rsquo;exercer que sur les sommes qui ont &eacute;t&eacute; effectivement vers&eacute;es. Toute r&eacute;clamation dirig&eacute;e contre une d&eacute;cision de r&eacute;cup&eacute;ration de l&rsquo;indu a un caract&egrave;re suspensif.&nbsp;&raquo;&nbsp;;</p>

<p>2&deg;&nbsp;Le premier alin&eacute;a de l&rsquo;article&nbsp;L.&nbsp;245‚??6 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;&Agrave; la premi&egrave;re phrase, apr&egrave;s le mot&nbsp;: &laquo;&nbsp;accord&eacute;e&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;: &laquo;&nbsp;,&nbsp;pour une dur&eacute;e d&rsquo;attribution unique et renouvelable,&nbsp;&raquo;&nbsp;;</p>

<p>b)&nbsp;Est ajout&eacute;e une phrase ainsi r&eacute;dig&eacute;e&nbsp;: &laquo;&nbsp;Lorsque le handicap n&rsquo;est pas&nbsp;susceptible d&rsquo;&eacute;voluer favorablement, un droit &agrave; la prestation de compensation&nbsp;du handicap est ouvert sans limitation de dur&eacute;e, sans pr&eacute;judice des r&eacute;visions du plan personnalis&eacute; de compensation qu&rsquo;appellent les besoins de la personne.&nbsp;&raquo;&nbsp;;</p>

<p>3&deg;&nbsp;Le deuxi&egrave;me alin&eacute;a de l&rsquo;article&nbsp;L.&nbsp;245‚??13 est ainsi modifi&eacute;&nbsp;:</p>

<p>a)&nbsp;Les mots&nbsp;: &laquo;&nbsp;la d&eacute;cision attributive de la prestation de compensation ouvre droit au b&eacute;n&eacute;fice des &eacute;l&eacute;ments mentionn&eacute;s aux&nbsp;2&deg;,&nbsp;3&deg;,&nbsp;4&deg; et&nbsp;5&deg; de l&rsquo;article L.&nbsp;245‚??3 et que&nbsp;&raquo; sont supprim&eacute;s&nbsp;;</p>

<p>b)&nbsp;Les mots&nbsp;: &laquo;&nbsp;elle peut sp&eacute;cifier&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;la d&eacute;cision attributive de la prestation de compensation pr&eacute;voit&nbsp;&raquo;&nbsp;;</p>

<p>c)&nbsp;(nouveau)&nbsp;Les mots&nbsp;: &laquo;&nbsp;ces &eacute;l&eacute;ments&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;: &laquo;&nbsp;les &eacute;l&eacute;ments mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;245‚??3&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (12, 85, N'Article 4', N'<p>Un comit&eacute; strat&eacute;gique, dont la composition et les missions sont pr&eacute;cis&eacute;es&nbsp;par d&eacute;cret, est cr&eacute;&eacute; aupr&egrave;s du ministre charg&eacute; des personnes handicap&eacute;es. Ce comit&eacute; est charg&eacute; d&rsquo;&eacute;laborer et de proposer, d&rsquo;une part, des adaptations&nbsp;du droit &agrave; la compensation du handicap r&eacute;pondant aux sp&eacute;cificit&eacute;s des besoins&nbsp;des enfants et, d&rsquo;autre part, des &eacute;volutions des modes de transport des&nbsp;personnes handicap&eacute;es,&nbsp;int&eacute;grant tous les types de mobilit&eacute;s et&nbsp;assurant une gestion logistique et financi&egrave;re int&eacute;gr&eacute;e.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 86, N'Article 1', N'<p>Le code p&eacute;nal est ainsi modifi&eacute;&nbsp;:</p>

<p>(2)1&deg;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;131‚??26‚??1, il est ins&eacute;r&eacute; un article&nbsp;131‚??26‚??2 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(3)&laquo;&nbsp;Art.&nbsp;131‚??26‚??2.&nbsp;&ndash;&nbsp;Par d&eacute;rogation &agrave; l&rsquo;avant‚??dernier alin&eacute;a de l&rsquo;article&nbsp;131‚??26 et &agrave; l&rsquo;article&nbsp;131‚??26‚??1, le prononc&eacute; de la peine compl&eacute;mentaire d&rsquo;in&eacute;ligibilit&eacute; mentionn&eacute;e au&nbsp;2&deg; de l&rsquo;article&nbsp;131‚??26 et &agrave; l&rsquo;article&nbsp;131‚??26‚??1 est obligatoire &agrave; l&rsquo;encontre de toute personne coupable de l&rsquo;une des infractions suivantes&nbsp;:</p>

<p>(4)&laquo;&nbsp;&ndash;&nbsp;les crimes pr&eacute;vus par le pr&eacute;sent code&nbsp;;</p>

<p>(5)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;222‚??33 et 222‚??33‚??2&nbsp;;</p>

<p>(6)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;432‚??10 &agrave;&nbsp;432‚??15, 433‚??1 et&nbsp;433‚??2, 434‚??9, 434‚??9‚??1, 434‚??43‚??1, 435‚??1 &agrave; 435‚??10 et&nbsp;445‚??1 &agrave;&nbsp;445‚??2‚??1, ainsi que le blanchiment de ces d&eacute;lits&nbsp;;</p>

<p>(7)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;313‚??1 et&nbsp;313‚??2, lorsqu&rsquo;ils sont commis en bande organis&eacute;e&nbsp;;</p>

<p>(8)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits d&rsquo;association de malfaiteurs pr&eacute;vus &agrave; l&rsquo;article&nbsp;450‚??1, lorsqu&rsquo;ils ont pour objet la pr&eacute;paration des d&eacute;lits mentionn&eacute;s au troisi&egrave;me alin&eacute;a du pr&eacute;sent article&nbsp;;</p>

<p>(9)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;441‚??2 &agrave; 441‚??6&nbsp;;</p>

<p>(10)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;L.&nbsp;86 &agrave;&nbsp;L.&nbsp;88‚??1, L.&nbsp;91 &agrave;&nbsp;L.&nbsp;104, L.&nbsp;106 &agrave;&nbsp;L.&nbsp;109, L.&nbsp;111, L.&nbsp;113 et&nbsp;L.&nbsp;116 du code &eacute;lectoral&nbsp;;</p>

<p>(11)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;1741 et&nbsp;1743 du code g&eacute;n&eacute;ral des imp&ocirc;ts, lorsqu&rsquo;ils sont commis en bande organis&eacute;e ou lorsqu&rsquo;ils r&eacute;sultent de l&rsquo;un des comportements mentionn&eacute;s aux 1&deg; &agrave;&nbsp;5&deg; de l&rsquo;article&nbsp;L.&nbsp;228 du livre des proc&eacute;dures fiscales, ainsi que le blanchiment de ces d&eacute;lits&nbsp;;</p>

<p>(12)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;L.&nbsp;465‚??1 &agrave;&nbsp;L.&nbsp;465‚??3‚??3 du code mon&eacute;taire et financier&nbsp;;</p>

<p>(13)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;L.&nbsp;113‚??1 du code &eacute;lectoral et&nbsp;11‚??5 de la&nbsp;loi&nbsp;n&deg;&nbsp;88‚??227 du 11&nbsp;mars&nbsp;1988 relative &agrave; la transparence financi&egrave;re de la vie politique&nbsp;;</p>

<p>(14)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;L.&nbsp;241‚??3 et&nbsp;L.&nbsp;242‚??6 du code de commerce&nbsp;;</p>

<p>(15)&laquo;&nbsp;&ndash;&nbsp;les d&eacute;lits pr&eacute;vus aux articles&nbsp;L.O.&nbsp;135‚??1 du code &eacute;lectoral et 26 de la&nbsp;loi&nbsp;n&deg;&nbsp;2013‚??907 du 11&nbsp;octobre&nbsp;2013 relative &agrave; la transparence de la vie publique.</p>

<p>(16)&laquo;&nbsp;Toutefois, la juridiction peut, par une d&eacute;cision sp&eacute;cialement motiv&eacute;e, d&eacute;cider de ne pas prononcer cette peine, en consid&eacute;ration des circonstances de l&rsquo;infraction et de la personnalit&eacute; de son auteur.&nbsp;&raquo;&nbsp;;</p>

<p>(17)2&deg;&nbsp;Le dernier alin&eacute;a des articles&nbsp;432‚??17 et&nbsp;433‚??22 est supprim&eacute;&nbsp;;</p>

<p>(18)3&deg;&nbsp;&Agrave; la fin de l&rsquo;article&nbsp;711‚??1, la r&eacute;f&eacute;rence&nbsp;:&nbsp;&laquo;&nbsp;<a href="https://www.legifrance.gouv.fr/affichTexte.do?cidTexte=JORFTEXT000034104023&amp;categorieLien=cid">loi&nbsp;n&deg;&nbsp;2017‚??258 du 28&nbsp;f&eacute;vrier&nbsp;2017</a>&nbsp;relative &agrave; la s&eacute;curit&eacute; publique&nbsp;&raquo; est remplac&eacute;e par la r&eacute;f&eacute;rence&nbsp;:&nbsp;&laquo;&nbsp;loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pour la r&eacute;gulation de la vie publique&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 87, N'Article 2', N'<p>L&rsquo;article&nbsp;4&nbsp;quater&nbsp;de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du&nbsp;17&nbsp;novembre&nbsp;1958 relative au fonctionnement des assembl&eacute;es parlementaires est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;Art.&nbsp;4&nbsp;quater.&nbsp;&ndash;&nbsp;Chaque assembl&eacute;e, apr&egrave;s consultation de l&rsquo;organe charg&eacute; de la d&eacute;ontologie parlementaire, d&eacute;termine des r&egrave;gles destin&eacute;es &agrave; pr&eacute;venir et &agrave; faire cesser les conflits d&rsquo;int&eacute;r&ecirc;ts entre un int&eacute;r&ecirc;t public et des int&eacute;r&ecirc;ts priv&eacute;s dans lesquels peuvent se trouver des parlementaires.</p>

<p>(3)&laquo;&nbsp;Elle pr&eacute;cise les conditions dans lesquelles chaque d&eacute;put&eacute; ou s&eacute;nateur veille &agrave; faire cesser imm&eacute;diatement ou &agrave; pr&eacute;venir les situations de conflit d&rsquo;int&eacute;r&ecirc;ts dans lesquelles il se trouve ou pourrait se trouver, apr&egrave;s avoir consult&eacute;, le cas &eacute;ch&eacute;ant, l&rsquo;organe charg&eacute; de la d&eacute;ontologie parlementaire &agrave; cette fin.</p>

<p>(4)&laquo;&nbsp;Elle veille &agrave; la mise en &oelig;uvre de ces r&egrave;gles dans les conditions d&eacute;termin&eacute;es par son r&egrave;glement.</p>

<p>(5)&laquo;&nbsp;Elle d&eacute;termine &eacute;galement les modalit&eacute;s de tenue d&rsquo;un registre accessible au public, recensant les cas dans lesquels un parlementaire a estim&eacute; devoir ne pas participer aux travaux du Parlement en raison d&rsquo;une situation de conflit d&rsquo;int&eacute;r&ecirc;ts telle qu&rsquo;elle est d&eacute;finie au premier alin&eacute;a.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 88, N'Article 2 bis A', N'<p>I.&nbsp;&ndash;&nbsp;Les emplois et fonctions pour lesquels le pouvoir de nomination du Pr&eacute;sident de la R&eacute;publique s&rsquo;exerce dans les conditions fix&eacute;es au dernier alin&eacute;a de l&rsquo;article&nbsp;13 de la Constitution sont incompatibles avec le fait d&rsquo;exercer ou d&rsquo;avoir exerc&eacute;, au cours des trois derni&egrave;res ann&eacute;es, les fonctions de dirigeant, de salari&eacute; ou de conseiller d&rsquo;une soci&eacute;t&eacute; contr&ocirc;l&eacute;e, supervis&eacute;e, subordonn&eacute;e ou concern&eacute;e par l&rsquo;institution, l&rsquo;organisme, l&rsquo;&eacute;tablissement ou l&rsquo;entreprise auquel cet emploi ou fonction se rattache.</p>

<p>(2)II.&nbsp;&ndash;&nbsp;Aucune personne exer&ccedil;ant les emplois et fonctions mentionn&eacute;s au&nbsp;I du pr&eacute;sent article ne peut participer &agrave; une d&eacute;lib&eacute;ration concernant une entreprise ou une soci&eacute;t&eacute; contr&ocirc;l&eacute;e, supervis&eacute;e, subordonn&eacute;e ou concern&eacute;e&nbsp;par l&rsquo;institution, l&rsquo;organisme, l&rsquo;&eacute;tablissement ou l&rsquo;entreprise dans laquelle elle a, au cours des trois ann&eacute;es pr&eacute;c&eacute;dant la d&eacute;lib&eacute;ration, exerc&eacute; des fonctions ou d&eacute;tenu un mandat.</p>

<p>(3)Les personnes exer&ccedil;ant les emplois et fonctions mentionn&eacute;s au m&ecirc;me&nbsp;I ne peuvent, directement ou indirectement, d&eacute;tenir d&rsquo;int&eacute;r&ecirc;ts dans une soci&eacute;t&eacute; ou entreprise mentionn&eacute;e audit&nbsp;I.</p>

<p>(4)L&rsquo;article&nbsp;432‚??13 du code p&eacute;nal est applicable aux personnes mentionn&eacute;es au m&ecirc;me&nbsp;I, apr&egrave;s la cessation de leur emploi ou de leur fonction.</p>

<p>(5)Le non‚??respect de cet article&nbsp;est passible des sanctions pr&eacute;vues &agrave; l&rsquo;article&nbsp;432‚??13 du code p&eacute;nal.</p>

<p>(6)Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat fixe le mod&egrave;le de d&eacute;claration d&rsquo;int&eacute;r&ecirc;ts que chaque personne doit d&eacute;poser au moment de sa d&eacute;signation.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 89, N'Article 2 bis', N'<p>L&rsquo;article&nbsp;2 de la&nbsp;loi&nbsp;n&deg;&nbsp;2013‚??907 du 11&nbsp;octobre&nbsp;2013 relative &agrave; la transparence de la vie publique est ainsi modifi&eacute;&nbsp;:</p>

<p>(2)1&deg;&nbsp;Au d&eacute;but du premier alin&eacute;a, est ajout&eacute;e la mention&nbsp;:&nbsp;&laquo;&nbsp;I.&nbsp;&ndash;&nbsp;&raquo;&nbsp;;</p>

<p>(3)2&deg;&nbsp;Il est ajout&eacute; un&nbsp;II ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(4)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat d&eacute;termine les modalit&eacute;s de tenue d&rsquo;un registre accessible au public, recensant les cas dans lesquels un membre du Gouvernement estime ne pas devoir exercer ses attributions en raison d&rsquo;une situation de conflit d&rsquo;int&eacute;r&ecirc;ts, y compris en conseil des ministres.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 90, N'Article 3', N'<p>I.&nbsp;&ndash;&nbsp;Il est interdit &agrave; un membre du Gouvernement de compter parmi les membres de son cabinet&nbsp;:</p>

<p>(2)1&deg;&nbsp;Son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(3)2&deg;&nbsp;Ses parents, enfants, fr&egrave;res et s&oelig;urs ainsi que leur conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(4)3&deg;&nbsp;Ses grands‚??parents, ses petits‚??enfants et les enfants de ses fr&egrave;res et s&oelig;urs&nbsp;;</p>

<p>(5)4&deg;&nbsp;Les parents, enfants et fr&egrave;res et s&oelig;urs de son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin.</p>

<p>(6)La violation de cette interdiction emporte l&rsquo;ill&eacute;galit&eacute; de l&rsquo;acte de nomination et, le cas &eacute;ch&eacute;ant, la cessation de plein droit du contrat.</p>

<p>(7)Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat d&eacute;termine les modalit&eacute;s selon lesquelles le membre du Gouvernement rembourse les sommes vers&eacute;es en violation de cette interdiction.</p>

<p>(8)Aucune restitution des sommes vers&eacute;es ne peut &ecirc;tre exig&eacute;e du collaborateur.</p>

<p>(9)Le fait, pour un membre du Gouvernement, de compter l&rsquo;une des personnes mentionn&eacute;es aux&nbsp;1&deg; &agrave;&nbsp;4&deg; parmi les membres de son cabinet est puni d&rsquo;une peine de trois ans d&rsquo;emprisonnement et de&nbsp;45&nbsp;000&nbsp;&euro; d&rsquo;amende.</p>

<p>(10)II.&nbsp;&ndash;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;10 de la&nbsp;loi&nbsp;n&deg;&nbsp;2013‚??907 du&nbsp;11&nbsp;octobre&nbsp;2013 relative &agrave; la transparence de la vie publique, il est ins&eacute;r&eacute; un&nbsp;article&nbsp;10‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(11)&laquo;&nbsp;Art.&nbsp;10‚??1.&nbsp;&ndash;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat pr&eacute;voit les conditions dans lesquelles une personne de la famille d&rsquo;un membre du Gouvernement, appartenant &agrave; l&rsquo;une des cat&eacute;gories de personnes d&eacute;finies au I de l&rsquo;article&nbsp;3 de la&nbsp;loi&nbsp;n&deg;&nbsp;&nbsp;&nbsp;&nbsp;du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pour la r&eacute;gulation de la vie publique, lorsqu&rsquo;elle est employ&eacute;e au sein d&rsquo;un cabinet minist&eacute;riel, informe sans d&eacute;lai de ce lien familial la Haute&nbsp;Autorit&eacute; pour la transparence de la vie publique et le membre du Gouvernement dont elle est le collaborateur. La Haute Autorit&eacute; peut faire usage du pouvoir d&rsquo;injonction pr&eacute;vu &agrave; l&rsquo;article&nbsp;10 pour faire cesser la situation de conflit d&rsquo;int&eacute;r&ecirc;ts dans laquelle se trouve le collaborateur. Cette information est rendue accessible au public.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 91, N'Article 3 Bis', N'<p>Apr&egrave;s l&rsquo;article&nbsp;8 de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre&nbsp;1958 relative au fonctionnement des assembl&eacute;es parlementaires, il est ins&eacute;r&eacute; un&nbsp;article&nbsp;8&nbsp;bis&nbsp;A ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;Art.&nbsp;8&nbsp;bis&nbsp;A.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;Les d&eacute;put&eacute;s et les s&eacute;nateurs peuvent employer sous contrat de droit priv&eacute; des collaborateurs qui les assistent dans l&rsquo;exercice de leurs fonctions et dont ils sont les employeurs directs.</p>

<p>(3)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Les d&eacute;put&eacute;s et les s&eacute;nateurs b&eacute;n&eacute;ficient, &agrave; cet effet, d&rsquo;un cr&eacute;dit affect&eacute; &agrave; la r&eacute;mun&eacute;ration de leurs collaborateurs.</p>

<p>(4)&laquo;&nbsp;III.&nbsp;&ndash;&nbsp;Le bureau de chaque assembl&eacute;e s&rsquo;assure de la mise en &oelig;uvre d&rsquo;un dialogue social entre les repr&eacute;sentants des parlementaires employeurs et les repr&eacute;sentants des collaborateurs parlementaires.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 92, N'Article 4', N'<p>(1)Apr&egrave;s l&rsquo;article&nbsp;8 de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre 1958 relative au fonctionnement des assembl&eacute;es parlementaires, il est ins&eacute;r&eacute; un article&nbsp;8&nbsp;bis&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;Art.&nbsp;8&nbsp;bis.&nbsp;&ndash;&nbsp;I.&nbsp;&ndash;&nbsp;Il est interdit &agrave; un d&eacute;put&eacute; ou un s&eacute;nateur d&rsquo;employer en tant que collaborateur parlementaire au sens de l&rsquo;article&nbsp;8&nbsp;bis&nbsp;A&nbsp;:</p>

<p>(3)&laquo;&nbsp;1&deg;&nbsp;Son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(4)&laquo;&nbsp;2&deg;&nbsp;Ses parents, enfants, fr&egrave;res et s&oelig;urs ainsi que leur conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(5)&laquo;&nbsp;3&deg;&nbsp;Ses grands‚??parents, ses petits‚??enfants et les enfants de ses fr&egrave;res et s&oelig;urs&nbsp;;</p>

<p>(6)&laquo;&nbsp;4&deg;&nbsp;Les parents, enfants et fr&egrave;res et s&oelig;urs de son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(7)&laquo;&nbsp;5&deg;&nbsp;Son rempla&ccedil;ant et les personnes &eacute;lues sur la m&ecirc;me liste que lui.</p>

<p>(8)&laquo;&nbsp;La violation de cette interdiction emporte de plein droit la cessation du contrat. Cette cessation ne donne lieu &agrave; aucune restitution entre les parties.</p>

<p>(9)&laquo;&nbsp;Le bureau de chaque assembl&eacute;e d&eacute;termine les modalit&eacute;s selon lesquelles le d&eacute;put&eacute; ou le s&eacute;nateur rembourse les sommes vers&eacute;es en vertu des contrats conclus en violation de l&rsquo;interdiction mentionn&eacute;e au pr&eacute;sent I.</p>

<p>(10)&laquo;&nbsp;Le fait, pour un d&eacute;put&eacute; ou un s&eacute;nateur, d&rsquo;employer un collaborateur en m&eacute;connaissance de l&rsquo;interdiction mentionn&eacute;e au pr&eacute;sent I est puni d&rsquo;une peine de trois ans d&rsquo;emprisonnement et de 45&nbsp;000&nbsp;&euro; d&rsquo;amende.</p>

<p>(11)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Le bureau de chaque assembl&eacute;e pr&eacute;voit les conditions dans lesquelles un membre de la famille d&rsquo;un parlementaire appartenant &agrave; l&rsquo;une des cat&eacute;gories de personnes d&eacute;finies au&nbsp;I, lorsqu&rsquo;il est employ&eacute; en tant que collaborateur d&rsquo;un parlementaire, l&rsquo;informe sans d&eacute;lai de ce lien familial et informe &eacute;galement le d&eacute;put&eacute; ou le s&eacute;nateur dont il est le collaborateur. Cette information est rendue accessible au public.&nbsp;&raquo;</p>

<p>&nbsp;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 93, N'Article 5', N'<p>I.&nbsp;&ndash;&nbsp;L&rsquo;article&nbsp;110 de la loi&nbsp;n&deg;&nbsp;84‚??53 du 26&nbsp;janvier 1984 portant dispositions statutaires relatives &agrave; la fonction publique territoriale est ainsi modifi&eacute;&nbsp;:</p>

<p>(2)1&deg;&nbsp;Au d&eacute;but du premier alin&eacute;a, est ajout&eacute;e la mention&nbsp;:&nbsp;&laquo;&nbsp;I.&nbsp;&ndash;&nbsp;&raquo;&nbsp;;</p>

<p>(3)2&deg;&nbsp;Apr&egrave;s le m&ecirc;me premier alin&eacute;a, sont ins&eacute;r&eacute;s huit alin&eacute;as ainsi r&eacute;dig&eacute;s&nbsp;:</p>

<p>(4)&laquo;&nbsp;Toutefois, il est interdit &agrave; l&rsquo;autorit&eacute; territoriale de compter parmi les membres de son cabinet&nbsp;:</p>

<p>(5)&laquo;&nbsp;1&deg;&nbsp;Son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(6)&laquo;&nbsp;2&deg;&nbsp;Ses parents, enfants, fr&egrave;res et s&oelig;urs ainsi que leur conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(7)&laquo;&nbsp;3&deg;&nbsp;Ses grands‚??parents, ses petits‚??enfants et les enfants de ses fr&egrave;res et s&oelig;urs&nbsp;;</p>

<p>(8)&laquo;&nbsp;4&deg;&nbsp;Les parents, enfants et fr&egrave;res et s&oelig;urs de son conjoint, partenaire li&eacute; par un pacte civil de solidarit&eacute; ou concubin&nbsp;;</p>

<p>(9)&laquo;&nbsp;La violation de cette interdiction emporte de plein droit la cessation du contrat.</p>

<p>(10)&laquo;&nbsp;Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat d&eacute;termine les modalit&eacute;s selon lesquelles l&rsquo;autorit&eacute; territoriale rembourse les sommes vers&eacute;es &agrave; un collaborateur employ&eacute; en violation de l&rsquo;interdiction pr&eacute;vue au pr&eacute;sent&nbsp;I.</p>

<p>(11)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Le fait, pour l&rsquo;autorit&eacute; territoriale, d&rsquo;employer un collaborateur en violation de l&rsquo;interdiction pr&eacute;vue au&nbsp;I est puni d&rsquo;une peine de trois ans d&rsquo;emprisonnement et de 45&nbsp;000&nbsp;&euro; d&rsquo;amende.&nbsp;&raquo;&nbsp;;</p>

<p>(12)3&deg;&nbsp;Le deuxi&egrave;me alin&eacute;a est ainsi modifi&eacute;&nbsp;:</p>

<p>(13)a)&nbsp;Au d&eacute;but, est ajout&eacute;e la mention&nbsp;:&nbsp;&laquo;&nbsp;III.&nbsp;&ndash;&nbsp;&raquo;&nbsp;;</p>

<p>(14)b&nbsp;(nouveau))&nbsp;Les mots&nbsp;:&nbsp;&laquo;&nbsp;&agrave; ces emplois&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;:&nbsp;&laquo;&nbsp;aux emplois mentionn&eacute;s au premier alin&eacute;a du&nbsp;I&nbsp;&raquo;.</p>

<p>(15)II.&nbsp;&ndash;&nbsp;Les&nbsp;I et&nbsp;II de l&rsquo;article 110 de la loi n&deg;&nbsp;84‚??53 du&nbsp;26&nbsp;janvier 1984 portant dispositions statutaires relatives &agrave; la fonction publique territoriale, dans leur r&eacute;daction r&eacute;sultant de la pr&eacute;sente loi, sont applicables &agrave; la commune et au d&eacute;partement de Paris et, &agrave; compter du 1er&nbsp;janvier&nbsp;2019, &agrave; la Ville de Paris.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 94, N'Article 6', N'<p>(1)I.&nbsp;&ndash;&nbsp;Lorsque le contrat de travail en cours au jour de la promulgation de la pr&eacute;sente loi m&eacute;conna&icirc;t l&rsquo;article&nbsp;8&nbsp;bis&nbsp;de l&rsquo;ordonnance&nbsp;n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre 1958 relative au fonctionnement des assembl&eacute;es parlementaires dans sa r&eacute;daction r&eacute;sultant de l&rsquo;article&nbsp;4 de la pr&eacute;sente loi, il prend fin de plein droit dans les conditions pr&eacute;vues au pr&eacute;sent&nbsp;I, sous r&eacute;serve du respect des dispositions sp&eacute;cifiques &agrave; la protection de la grossesse et de la maternit&eacute; pr&eacute;vues &agrave; l&rsquo;article L.&nbsp;1225‚??4 du code du travail.</p>

<p>(2)La rupture du contrat constitue un licenciement fond&eacute; sur la pr&eacute;sente loi. Ce motif sp&eacute;cifique constitue une cause r&eacute;elle et s&eacute;rieuse.</p>

<p>(3)Le parlementaire notifie le licenciement &agrave; son collaborateur, par lettre recommand&eacute;e avec demande d&rsquo;avis de r&eacute;ception, dans les deux mois suivant la promulgation de la pr&eacute;sente loi. Il lui remet dans le m&ecirc;me d&eacute;lai les documents pr&eacute;vus aux articles&nbsp;L.&nbsp;1234‚??19 et L.&nbsp;1234‚??20 du code du travail ainsi qu&rsquo;une attestation d&rsquo;assurance ch&ocirc;mage.</p>

<p>(4)Le collaborateur peut exercer le d&eacute;lai de pr&eacute;avis pr&eacute;vu par son contrat ou par la r&egrave;glementation applicable &agrave; l&rsquo;assembl&eacute;e concern&eacute;e.</p>

<p>(5)Le collaborateur b&eacute;n&eacute;ficie des indemnit&eacute;s mentionn&eacute;es aux articles&nbsp;L.&nbsp;1234‚??5, L.&nbsp;1234‚??9 et L.&nbsp;3141‚??28 du code du travail lorsqu&rsquo;il remplit les conditions pr&eacute;vues. Les indemnit&eacute;s sont support&eacute;es par l&rsquo;assembl&eacute;e parlementaire.</p>

<p>(6)Le parlementaire n&rsquo;est pas p&eacute;nalement responsable de l&rsquo;infraction pr&eacute;vue &agrave; l&rsquo;article 8&nbsp;bis&nbsp;de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre&nbsp;1958 pr&eacute;cit&eacute;e lorsque cette infraction est commise pendant le d&eacute;lai de notification et le d&eacute;lai de pr&eacute;avis pr&eacute;vus au pr&eacute;sent I.</p>

<p>(7)II.&nbsp;&ndash;&nbsp;Lorsqu&rsquo;un collaborateur est employ&eacute;, au jour de la promulgation de la pr&eacute;sente loi, en violation du&nbsp;I de l&rsquo;article&nbsp;110 de la loi n&deg;&nbsp;84‚??53 du 26&nbsp;janvier 1984 portant dispositions statutaires relatives &agrave; la fonction publique territoriale, dans sa r&eacute;daction r&eacute;sultant de l&rsquo;article&nbsp;5 de la pr&eacute;sente loi, le contrat prend fin de plein droit dans les conditions pr&eacute;vues au&nbsp;pr&eacute;sent&nbsp;II, sous r&eacute;serve du respect des dispositions sp&eacute;cifiques &agrave; la protection de la grossesse et de la maternit&eacute; pr&eacute;vues &agrave; l&rsquo;article&nbsp;L.&nbsp;1225‚??4 du code du travail.</p>

<p>(8)L&rsquo;autorit&eacute; territoriale notifie le licenciement &agrave; son collaborateur, par lettre recommand&eacute;e avec demande d&rsquo;avis de r&eacute;ception, dans les deux mois suivant la promulgation de la pr&eacute;sente loi. Le collaborateur peut exercer le d&eacute;lai de pr&eacute;avis pr&eacute;vu par la r&egrave;glementation applicable.</p>

<p>(9)L&rsquo;autorit&eacute; territoriale n&rsquo;est pas p&eacute;nalement responsable de l&rsquo;infraction pr&eacute;vue au&nbsp;II de l&rsquo;article&nbsp;110 de la loi n&deg;&nbsp;84‚??53 du&nbsp;26&nbsp;janvier 1984 pr&eacute;cit&eacute;e lorsque cette infraction est commise pendant le d&eacute;lai de notification et le d&eacute;lai de pr&eacute;avis pr&eacute;vus au pr&eacute;sent&nbsp;II.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 95, N'Article 6 Bis', N'<p>(1)I.&nbsp;&ndash;&nbsp;Les collaborateurs parlementaires qui l&rsquo;acceptent peuvent, lorsqu&rsquo;ils font l&rsquo;objet d&rsquo;une proc&eacute;dure de licenciement pour un motif autre que personnel, b&eacute;n&eacute;ficier d&rsquo;un parcours d&rsquo;accompagnement personnalis&eacute;, qui d&eacute;bute par une phase de pr&eacute;‚??bilan, d&rsquo;&eacute;valuation des comp&eacute;tences et d&rsquo;orientation professionnelle en vue de l&rsquo;&eacute;laboration d&rsquo;un projet professionnel.</p>

<p>(2)Ce parcours, dont les modalit&eacute;s sont pr&eacute;cis&eacute;es par d&eacute;cret, comprend notamment des mesures d&rsquo;accompagnement et d&rsquo;appui au projet professionnel, ainsi que des p&eacute;riodes de formation et de travail.</p>

<p>(3)L&rsquo;accompagnement personnalis&eacute; est assur&eacute; par P&ocirc;le emploi, dans des conditions pr&eacute;vues par d&eacute;cret.</p>

<p>(4)I&nbsp;bis&nbsp;(nouveau).&nbsp;&ndash;&nbsp;Le parlementaire employeur est tenu de proposer le b&eacute;n&eacute;fice du dispositif d&rsquo;accompagnement mentionn&eacute; au&nbsp;I &agrave; chaque collaborateur qu&rsquo;il envisage de licencier pour un motif autre que personnel et de l&rsquo;informer par &eacute;crit du motif sur lequel repose la rupture en cas d&rsquo;acceptation par celui‚??ci du dispositif d&rsquo;accompagnement.</p>

<p>(5)L&rsquo;adh&eacute;sion du salari&eacute; au parcours d&rsquo;accompagnement mentionn&eacute; au&nbsp;m&ecirc;me&nbsp;I emporte rupture du contrat de travail.</p>

<p>(6)Cette rupture du contrat de travail, qui ne comporte ni pr&eacute;avis ni indemnit&eacute; compensatrice de pr&eacute;avis, ouvre droit &agrave; l&rsquo;indemnit&eacute; pr&eacute;vue &agrave; l&rsquo;article&nbsp;L.&nbsp;1234‚??9 du code du travail et &agrave; toute indemnit&eacute; conventionnelle ou pr&eacute;vue par la r&eacute;glementation propre &agrave; chaque assembl&eacute;e parlementaire qui aurait &eacute;t&eacute; due au terme du pr&eacute;avis ainsi que, le cas &eacute;ch&eacute;ant, au solde de ce qui aurait &eacute;t&eacute; l&rsquo;indemnit&eacute; compensatrice de pr&eacute;avis en cas de licenciement et apr&egrave;s d&eacute;falcation du versement du parlementaire employeur mentionn&eacute; au&nbsp;III du pr&eacute;sent article.</p>

<p>(7)Les r&eacute;gimes social et fiscal applicables &agrave; ce solde sont ceux applicables aux indemnit&eacute;s compensatrices de pr&eacute;avis.</p>

<p>(8)Un d&eacute;cret d&eacute;finit les d&eacute;lais de r&eacute;ponse du salari&eacute; &agrave; la proposition de l&rsquo;employeur mentionn&eacute;e au premier alin&eacute;a du pr&eacute;sent&nbsp;I&nbsp;bis&nbsp;ainsi que les conditions dans lesquelles le salari&eacute; adh&egrave;re au parcours d&rsquo;accompagnement personnalis&eacute;.</p>

<p>(9)II.&nbsp;&ndash;&nbsp;Le b&eacute;n&eacute;ficiaire du dispositif d&rsquo;accompagnement mentionn&eacute; au&nbsp;I est plac&eacute; sous le statut de stagiaire de la formation professionnelle et per&ccedil;oit, pendant une dur&eacute;e maximale de douze&nbsp;mois, une allocation sup&eacute;rieure &agrave; celle &agrave; laquelle le collaborateur aurait pu pr&eacute;tendre au titre de l&rsquo;allocation d&rsquo;assurance mentionn&eacute;e &agrave; l&rsquo;article L.&nbsp;5422‚??1 du code du travail pendant la m&ecirc;me p&eacute;riode.</p>

<p>(10)Le salaire de r&eacute;f&eacute;rence servant au calcul de cette allocation est le salaire de r&eacute;f&eacute;rence retenu pour le calcul de l&rsquo;allocation d&rsquo;assurance du r&eacute;gime d&rsquo;assurance ch&ocirc;mage mentionn&eacute;e au m&ecirc;me article L.&nbsp;5422‚??1.</p>

<p>(11)Pour b&eacute;n&eacute;ficier de cette allocation, le b&eacute;n&eacute;ficiaire doit justifier d&rsquo;une anciennet&eacute; d&rsquo;au moins douze&nbsp;mois &agrave; la date du licenciement.</p>

<p>(12)Le montant de cette allocation ainsi que les conditions dans lesquelles les r&egrave;gles de l&rsquo;assurance ch&ocirc;mage s&rsquo;appliquent aux b&eacute;n&eacute;ficiaires du dispositif, en particulier les conditions d&rsquo;imputation de la dur&eacute;e d&rsquo;ex&eacute;cution de l&rsquo;accompagnement personnalis&eacute; sur la dur&eacute;e de versement de l&rsquo;allocation d&rsquo;assurance mentionn&eacute;e audit article L.&nbsp;5422‚??1, sont d&eacute;finis par d&eacute;cret.</p>

<p>(13)III.&nbsp;&ndash;&nbsp;Chaque assembl&eacute;e parlementaire contribue, pour le compte du parlementaire employeur, au financement du dispositif d&rsquo;accompagnement mentionn&eacute; au I du pr&eacute;sent article par un versement repr&eacute;sentatif de l&rsquo;indemnit&eacute; compensatrice de pr&eacute;avis, dans la limite de trois mois de salaire major&eacute; de l&rsquo;ensemble des cotisations et contributions obligatoires&nbsp;aff&eacute;rentes. Ce versement est fait aupr&egrave;s de P&ocirc;le emploi, qui recouvre cette contribution pour le compte de l&rsquo;&Eacute;tat.</p>

<p>(14)La d&eacute;termination du montant de ce versement et son recouvrement, effectu&eacute; selon les r&egrave;gles et sous les garanties et sanctions mentionn&eacute;es au premier alin&eacute;a de l&rsquo;article L.&nbsp;5422‚??16 du code du travail, sont assur&eacute;s par P&ocirc;le emploi. Les conditions d&rsquo;exigibilit&eacute; de ce versement sont pr&eacute;cis&eacute;es par d&eacute;cret.</p>

<p>(15)IV.&nbsp;&ndash;&nbsp;Lorsque le parlementaire employeur concern&eacute; n&rsquo;a pas propos&eacute; le dispositif d&rsquo;accompagnement pr&eacute;vu en application du&nbsp;I du pr&eacute;sent article, P&ocirc;le emploi le propose &agrave; l&rsquo;ancien collaborateur parlementaire. Dans ce cas, le parlementaire employeur verse &agrave; P&ocirc;le emploi, qui la recouvre pour le compte de l&rsquo;&Eacute;tat, une contribution &eacute;gale &agrave; deux mois de salaire brut, port&eacute;e &agrave; trois mois lorsque l&rsquo;ancien collaborateur parlementaire adh&egrave;re au dispositif d&rsquo;accompagnement mentionn&eacute; au m&ecirc;me&nbsp;I sur proposition de P&ocirc;le emploi.</p>

<p>(16)La d&eacute;termination du montant de cette contribution et son recouvrement, effectu&eacute; selon les r&egrave;gles et sous les garanties et sanctions mentionn&eacute;es au premier alin&eacute;a de l&rsquo;article L.&nbsp;5422‚??16 du code du travail, sont assur&eacute;s par P&ocirc;le emploi. Les conditions d&rsquo;exigibilit&eacute; de cette contribution sont pr&eacute;cis&eacute;es par d&eacute;cret.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 96, N'Article 7', N'<p>(1)I.&nbsp;&ndash;&nbsp;L&rsquo;indemnit&eacute; repr&eacute;sentative de frais de mandat des d&eacute;put&eacute;s et des s&eacute;nateurs est supprim&eacute;e.</p>

<p>(2)II.&nbsp;&ndash;&nbsp;Au&nbsp;a&nbsp;du&nbsp;3&deg; du&nbsp;II de l&rsquo;article L.&nbsp;136‚??2 du code de la s&eacute;curit&eacute; sociale, les mots&nbsp;:&nbsp;&laquo;&nbsp;l&rsquo;indemnit&eacute; repr&eacute;sentative de frais de mandat, au plus &eacute;gale&nbsp;au montant brut cumul&eacute; des deux&nbsp;premi&egrave;res et vers&eacute;e &agrave; titre d&rsquo;allocation sp&eacute;ciale pour frais par les assembl&eacute;es &agrave; tous leurs membres,&nbsp;&raquo; sont supprim&eacute;s.</p>

<p>(3)III.&nbsp;&ndash;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;4&nbsp;quinquies&nbsp;de l&rsquo;ordonnance&nbsp;n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre&nbsp;1958 relative au fonctionnement des assembl&eacute;es parlementaires, il est ins&eacute;r&eacute; un article 4&nbsp;sexies&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(4)&laquo;&nbsp;Art.&nbsp;4&nbsp;sexies.&nbsp;&ndash;&nbsp;Le bureau de chaque assembl&eacute;e, apr&egrave;s consultation de l&rsquo;organe charg&eacute; de la d&eacute;ontologie parlementaire, d&eacute;finit les conditions dans lesquelles les frais de mandat r&eacute;ellement expos&eacute;s par les d&eacute;put&eacute;s et les s&eacute;nateurs sont directement pris en charge par l&rsquo;assembl&eacute;e dont ils sont membres ou leur sont rembours&eacute;s dans la limite de plafonds qu&rsquo;il d&eacute;termine et sur pr&eacute;sentation de justificatifs de ces frais. Cette prise en charge peut donner lieu au versement d&rsquo;une avance.&nbsp;&raquo;</p>

<p>(5)IV.&nbsp;&ndash;&nbsp;Le second alin&eacute;a du&nbsp;1&deg; de l&rsquo;article&nbsp;81 du code g&eacute;n&eacute;ral des imp&ocirc;ts est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>(6)&laquo;&nbsp;Il en est de m&ecirc;me des frais de mandat rembours&eacute;s dans les conditions pr&eacute;vues &agrave; l&rsquo;article 4&nbsp;sexies&nbsp;de l&rsquo;ordonnance n&deg;&nbsp;58‚??1100 du 17&nbsp;novembre 1958 relative au fonctionnement des assembl&eacute;es parlementaires&nbsp;;&nbsp;&raquo;.</p>

<p>(7)V.&nbsp;&ndash;&nbsp;Les&nbsp;I et&nbsp;II entrent en vigueur le 1er&nbsp;janvier 2018.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 97, N'Article 7 Bis', N'<p>(1)I.&nbsp;&ndash;&nbsp;Au premier alin&eacute;a de l&rsquo;article&nbsp;80&nbsp;undecies&nbsp;du code g&eacute;n&eacute;ral des imp&ocirc;ts, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;pr&eacute;cit&eacute;e&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;:&nbsp;&laquo;&nbsp;,&nbsp;les indemnit&eacute;s de fonction compl&eacute;mentaires vers&eacute;es en vertu d&rsquo;une d&eacute;cision prise par le bureau de chaque assembl&eacute;e&nbsp;&raquo;.</p>

<p>(2)II.&nbsp;&ndash;&nbsp;Le&nbsp;I entre en vigueur le 1er&nbsp;janvier 2018.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (13, 98, N'Article 8', N'<p>(1)I.&nbsp;&ndash;&nbsp;La loi n&deg;&nbsp;88‚??227 du 11&nbsp;mars 1988 relative &agrave; la transparence financi&egrave;re de la vie politique est ainsi modifi&eacute;e&nbsp;:</p>

<p>(2)1&deg;&nbsp;A&nbsp;(nouveau)&nbsp;Le titre&nbsp;II est abrog&eacute;&nbsp;;</p>

<p>(3)1&deg;&nbsp;B&nbsp;(nouveau)&nbsp;&Agrave; l&rsquo;article&nbsp;11, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;partis&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;:&nbsp;&laquo;&nbsp;et groupements&nbsp;&raquo;&nbsp;;</p>

<p>(4)1&deg;&nbsp;C&nbsp;(nouveau)&nbsp;&Agrave; la premi&egrave;re phrase du premier alin&eacute;a, deux fois, au deuxi&egrave;me alin&eacute;a et au&nbsp;2&deg; de l&rsquo;article&nbsp;11‚??1, &agrave; la premi&egrave;re phrase du premier alin&eacute;a et au second alin&eacute;a de l&rsquo;article&nbsp;11‚??2 et aux premi&egrave;re, deuxi&egrave;me et troisi&egrave;me phrases de l&rsquo;article&nbsp;11‚??3, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;parti&nbsp;&raquo;, sont ins&eacute;r&eacute;s les mots&nbsp;:&nbsp;&laquo;&nbsp;ou groupement&nbsp;&raquo;&nbsp;;</p>

<p>(5)1&deg;&nbsp;D&nbsp;(nouveau)&nbsp;&Agrave; la premi&egrave;re phrase du premier alin&eacute;a de l&rsquo;article&nbsp;11‚??1, les mots&nbsp;:&nbsp;&laquo;&nbsp;mentionn&eacute;e &agrave; l&rsquo;article L.&nbsp;52‚??14 du code &eacute;lectoral&nbsp;&raquo; sont supprim&eacute;s&nbsp;;</p>

<p>(6)1&deg;&nbsp;E&nbsp;(nouveau)&nbsp;Au premier alin&eacute;a de l&rsquo;article&nbsp;11‚??4, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;partis&nbsp;&raquo;, sont ins&eacute;r&eacute;s, deux fois, les mots&nbsp;:&nbsp;&laquo;&nbsp;ou groupements&nbsp;&raquo;&nbsp;;</p>

<p>(7)1&deg;&nbsp;&Agrave; l&rsquo;article 11, les mots&nbsp;:&nbsp;&laquo;&nbsp;des fonds&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;:&nbsp;&laquo;&nbsp;l&rsquo;ensemble de leurs ressources, y compris les aides pr&eacute;vues &agrave; l&rsquo;article&nbsp;8,&nbsp;&raquo;&nbsp;;</p>

<p>(8)2&deg;&nbsp;Au&nbsp;2&deg; de l&rsquo;article 11‚??1, les mots&nbsp;:&nbsp;&laquo;&nbsp;tous les dons re&ccedil;us&nbsp;&raquo;&nbsp;sont remplac&eacute;s par les mots&nbsp;:&nbsp;&laquo;&nbsp;l&rsquo;ensemble des ressources re&ccedil;ues&nbsp;&raquo;&nbsp;;</p>

<p>(9)3&deg;&nbsp;Au second alin&eacute;a de l&rsquo;article&nbsp;11‚??2, les mots&nbsp;:&nbsp;&laquo;&nbsp;tous les dons re&ccedil;us&nbsp;&raquo; sont remplac&eacute;s par les mots&nbsp;:&nbsp;&laquo;&nbsp;l&rsquo;ensemble des ressources re&ccedil;ues&nbsp;&raquo;&nbsp;;</p>

<p>(10)4&deg;&nbsp;Apr&egrave;s l&rsquo;article&nbsp;11‚??3, il est ins&eacute;r&eacute; un article&nbsp;11‚??3‚??1 ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(11)&laquo;&nbsp;Art.&nbsp;11‚??3‚??1.&nbsp;&ndash;&nbsp;Les personnes physiques peuvent consentir des pr&ecirc;ts aux partis ou groupements politiques d&egrave;s lors que ces pr&ecirc;ts ne sont pas effectu&eacute;s &agrave; titre habituel.</p>

<p>(12)&laquo;&nbsp;Ces pr&ecirc;ts ne peuvent exc&eacute;der une dur&eacute;e de cinq&nbsp;ans. Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat fixe le plafond et les conditions d&rsquo;encadrement du pr&ecirc;t consenti pour garantir qu&rsquo;il ne constitue pas un don d&eacute;guis&eacute;.</p>

<p>(13)&laquo;&nbsp;Le parti ou groupement politique fournit au pr&ecirc;teur les informations concernant les caract&eacute;ristiques du pr&ecirc;t s&rsquo;agissant du taux d&rsquo;int&eacute;r&ecirc;t applicable, du montant total du pr&ecirc;t, de sa dur&eacute;e, de ses modalit&eacute;s et conditions de remboursement.</p>

<p>(14)&laquo;&nbsp;Le parti ou groupement politique informe le pr&ecirc;teur des cons&eacute;quences li&eacute;es &agrave; la d&eacute;faillance de l&rsquo;emprunteur.</p>

<p>(15)&laquo;&nbsp;Il communique &agrave; la Commission nationale des comptes de campagne et des financements politiques, dans les annexes de ses comptes, un &eacute;tat du&nbsp;remboursement du pr&ecirc;t consenti. Il lui adresse, l&rsquo;ann&eacute;e de sa conclusion, une copie du contrat du pr&ecirc;t.&nbsp;&raquo;&nbsp;;</p>

<p>(16)5&deg;&nbsp;L&rsquo;article&nbsp;11‚??4 est ainsi modifi&eacute;&nbsp;:</p>

<p>(17)aa&nbsp;(nouveau))&nbsp;Au d&eacute;but du premier alin&eacute;a, est ajout&eacute;e une phrase ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>(18)&laquo;&nbsp;Une personne physique peut verser un don &agrave; un parti ou groupement politique si elle est de nationalit&eacute; fran&ccedil;aise ou si elle r&eacute;side en France.&nbsp;&raquo;&nbsp;;</p>

<p>(19)a)&nbsp;Le troisi&egrave;me alin&eacute;a est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>(20)&laquo;&nbsp;Les personnes morales, &agrave; l&rsquo;exception des partis et groupements politiques ainsi que des &eacute;tablissements de cr&eacute;dit et soci&eacute;t&eacute;s de financement ayant leur si&egrave;ge social dans un &Eacute;tat membre de l&rsquo;Union europ&eacute;enne ou partie &agrave; l&rsquo;accord sur l&rsquo;Espace &eacute;conomique europ&eacute;en, ne peuvent consentir des pr&ecirc;ts aux partis et groupements politiques.&nbsp;&raquo;&nbsp;;</p>

<p>(21)b)&nbsp;Le quatri&egrave;me alin&eacute;a est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(22)&laquo;&nbsp;L&rsquo;association de financement ou le mandataire financier d&eacute;livre au donateur un re&ccedil;u pour chaque don ou cotisation. Un d&eacute;cret en Conseil d&rsquo;&Eacute;tat fixe les conditions d&rsquo;&eacute;tablissement, d&rsquo;utilisation et de transmission du re&ccedil;u &agrave; la Commission nationale des comptes de campagne et des financements politiques. Dans les conditions fix&eacute;es par un d&eacute;cret en Conseil d&rsquo;&Eacute;tat pris apr&egrave;s avis de la Commission nationale de l&rsquo;informatique et des libert&eacute;s, le parti ou groupement b&eacute;n&eacute;ficiaire communique chaque ann&eacute;e &agrave; la Commission nationale des comptes de campagne et des financements politiques la liste des personnes ayant consenti &agrave; lui verser un ou plusieurs dons ou cotisations, ainsi&nbsp;que le montant de ceux‚??ci.&nbsp;&raquo;&nbsp;;</p>

<p>(23)c)&nbsp;L&rsquo;avant‚??dernier alin&eacute;a est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>(24)&laquo;&nbsp;Ils ne peuvent recevoir des pr&ecirc;ts d&rsquo;un &Eacute;tat &eacute;tranger ou d&rsquo;une personne morale de droit &eacute;tranger, &agrave; l&rsquo;exception des &eacute;tablissements de cr&eacute;dit ou soci&eacute;t&eacute;s de financement mentionn&eacute;s au troisi&egrave;me alin&eacute;a.&nbsp;&raquo;&nbsp;;</p>

<p>(25)6&deg;&nbsp;L&rsquo;article 11‚??5 est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(26)&laquo;&nbsp;Art.&nbsp;11‚??5.&nbsp;&ndash;&nbsp;Les personnes qui ont vers&eacute; un don ou consenti un pr&ecirc;t &agrave; un ou plusieurs partis ou groupements politiques en violation des articles&nbsp;11‚??3‚??1 et 11‚??4 sont punies de trois ans d&rsquo;emprisonnement et d&rsquo;une amende de 45&nbsp;000&nbsp;&euro;.</p>

<p>(27)&laquo;&nbsp;Les m&ecirc;me peines sont applicables au b&eacute;n&eacute;ficiaire du don ou du pr&ecirc;t consenti&nbsp;:</p>

<p>(28)&laquo;&nbsp;1&deg;&nbsp;Par une personne physique en violation de l&rsquo;article&nbsp;11‚??3‚??1 et du cinqui&egrave;me alin&eacute;a de l&rsquo;article 11‚??4&nbsp;;</p>

<p>(29)&laquo;&nbsp;2&deg;&nbsp;Par une m&ecirc;me personne physique &agrave; un seul parti ou groupement politique en violation du premier alin&eacute;a du m&ecirc;me article&nbsp;11‚??4&nbsp;;</p>

<p>(30)&laquo;&nbsp;3&deg;&nbsp;Par une personne morale, y compris de droit &eacute;tranger, en violation dudit article&nbsp;11‚??4.&nbsp;&raquo;&nbsp;;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (14, 99, N'Article 1', N'<p>(1)Le livre&nbsp;Ier&nbsp;du code de commerce est compl&eacute;t&eacute; par un titre&nbsp;V ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;TITRE V</p>

<p>(3)&laquo;&nbsp;DE LA PROTECTION DU SECRET DES AFFAIRES</p>

<p>(4)&laquo;&nbsp;Chapitre Ier</p>

<p>(5)&laquo;&nbsp;De l&rsquo;objet et des conditions de la protection</p>

<p>(6)&laquo;&nbsp;Section&nbsp;1</p>

<p>(7)&laquo;&nbsp;De l&rsquo;information prot&eacute;g&eacute;e</p>

<p>(8)&laquo;&nbsp;Art.&nbsp;L.&nbsp;151‚??1.&nbsp;&ndash;&nbsp;Est prot&eacute;g&eacute;e au titre du secret des affaires toute information pr&eacute;sentant l&rsquo;ensemble des caract&eacute;ristiques suivantes&nbsp;:</p>

<p>(9)&laquo;&nbsp;1&deg;&nbsp;Elle&nbsp;n&rsquo;est&nbsp;pas,&nbsp;en&nbsp;elle‚??m&ecirc;me&nbsp;ou&nbsp;dans&nbsp;la&nbsp;configuration&nbsp;et&nbsp;l&rsquo;assemblage&nbsp;exacts&nbsp;de&nbsp;ses &eacute;l&eacute;ments, g&eacute;n&eacute;ralement connue ou ais&eacute;ment accessible &agrave; une personne agissant dans un secteur&nbsp;ou un domaine d&rsquo;activit&eacute; traitant habituellement de cette cat&eacute;gorie d&rsquo;information&nbsp;;</p>

<p>(10)&laquo;&nbsp;2&deg;&nbsp;Elle rev&ecirc;t une valeur commerciale parce qu&rsquo;elle est secr&egrave;te&nbsp;;</p>

<p>(11)&laquo;&nbsp;3&deg;&nbsp;Elle fait l&rsquo;objet de la part de son d&eacute;tenteur l&eacute;gitime de mesures de protection raisonnables pour en conserver le secret.</p>

<p>(12)&laquo;&nbsp;Section 2</p>

<p>(13)&laquo;&nbsp;Des d&eacute;tenteurs l&eacute;gitimes du secret des affaires</p>

<p>(14)&laquo;&nbsp;Art.&nbsp;L.&nbsp;151‚??2.&nbsp;&ndash;&nbsp;Est d&eacute;tenteur l&eacute;gitime d&rsquo;un secret des affaires au sens du pr&eacute;sent chapitre celui qui l&rsquo;a obtenu par l&rsquo;un des moyens suivants&nbsp;:</p>

<p>(15)&laquo;&nbsp;1&deg;&nbsp;Une d&eacute;couverte ou une cr&eacute;ation ind&eacute;pendante&nbsp;;</p>

<p>(16)&laquo;&nbsp;2&deg;&nbsp;L&rsquo;observation, l&rsquo;&eacute;tude, le d&eacute;montage ou le test d&rsquo;un produit ou d&rsquo;un objet qui a &eacute;t&eacute; mis &agrave; la&nbsp;disposition&nbsp;du&nbsp;public&nbsp;ou&nbsp;qui&nbsp;est&nbsp;de&nbsp;fa&ccedil;on&nbsp;licite&nbsp;en&nbsp;possession&nbsp;de&nbsp;la&nbsp;personne&nbsp;qui&nbsp;obtient l&rsquo;information&nbsp;;</p>

<p>(17)&laquo;&nbsp;3&deg;&nbsp;L&rsquo;exp&eacute;rience et les comp&eacute;tences acquises de mani&egrave;re honn&ecirc;te dans le cadre de l&rsquo;exercice normal de son activit&eacute; professionnelle.</p>

<p>(18)&laquo;&nbsp;Est &eacute;galement d&eacute;tenteur l&eacute;gitime du secret des affaires au sens du pr&eacute;sent chapitre celui qui peut se pr&eacute;valoir des dispositions de l&rsquo;article L.&nbsp;151‚??6 ou celui qui n&rsquo;a pas obtenu, utilis&eacute; ou&nbsp;divulgu&eacute; ce secret de fa&ccedil;on illicite au sens des articles L.&nbsp;151‚??3 &agrave; L.&nbsp;151‚??5.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (14, 100, N'Article 2', N'<p>Apr&egrave;s le quatri&egrave;me alin&eacute;a de l&rsquo;article L.&nbsp;950‚??1 du code de commerce est ins&eacute;r&eacute; un alin&eacute;a r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;Les articles L.&nbsp;151‚??1 &agrave; L.&nbsp;153‚??2 sont applicables dans leur r&eacute;daction r&eacute;sultant de la loi&nbsp;n&deg;&nbsp;2018‚??&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;du&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;portant transposition de la directive du Parlement europ&eacute;en et du Conseil sur la protection des savoir-faire et des informations commerciales non divulgu&eacute;s contre l&rsquo;obtention, l&rsquo;utilisation et la divulgation illicites.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 101, N'Article 1', N'<p>e titre&nbsp;VI du livre&nbsp;II de la troisi&egrave;me partie du code du travail est compl&eacute;t&eacute; par un chapitre&nbsp;IV ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;Chapitre IV</p>

<p>(3)&laquo;&nbsp;Ticket‚??carburant</p>

<p>(4)&laquo;&nbsp;Section 1</p>

<p>(5)&laquo;&nbsp;Champ d&rsquo;application et mise en place</p>

<p>(6)&laquo;&nbsp;Art.&nbsp;L.&nbsp;3264‚??1.&nbsp;&ndash;&nbsp;Les dispositions du pr&eacute;sent chapitre s&rsquo;appliquent aux employeurs mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;3211‚??1 et aux employeurs du secteur public, lorsque la r&eacute;sidence habituelle ou le lieu de travail du salari&eacute; sont situ&eacute;s hors du ressort territorial d&rsquo;une autorit&eacute; organisatrice de la mobilit&eacute; inclus dans les agglom&eacute;rations de plus de 100&nbsp;000&nbsp;habitants.</p>

<p>(7)&laquo;&nbsp;Art.&nbsp;L.&nbsp;3264‚??2.&nbsp;&ndash;&nbsp;La mise en place des tickets‚??carburant mentionn&eacute;s &agrave; l&rsquo;article L.&nbsp;3264‚??3 et la part contributive de l&rsquo;employeur sont d&eacute;cid&eacute;es&nbsp;:</p>

<p>(8)&laquo;&nbsp;1&deg;&nbsp;Pour les entreprises entrant dans le champ d&rsquo;application de l&rsquo;article L.&nbsp;2242‚??1, par accord entre l&rsquo;employeur et les repr&eacute;sentants d&rsquo;organisations syndicales repr&eacute;sentatives dans l&rsquo;entreprise&nbsp;;</p>

<p>(9)&laquo;&nbsp;2&deg;&nbsp;Pour les autres entreprises, par d&eacute;cision unilat&eacute;rale de l&rsquo;employeur apr&egrave;s consultation du comit&eacute; social et &eacute;conomique.</p>

<p>(10)&laquo;&nbsp;Section 1</p>

<p>(11)&laquo;&nbsp;&Eacute;mission</p>

<p>(12)&laquo;&nbsp;Art.&nbsp;L.&nbsp;3264‚??3.&nbsp;&ndash;&nbsp;Le ticket‚??carburant est un mode de paiement remis par l&rsquo;employeur &agrave; un salari&eacute; pour lui permettre d&rsquo;acquitter tout ou partie des frais engag&eacute;s pour l&rsquo;achat de carburants automobiles ou pour la recharge de v&eacute;hicules &eacute;lectriques ou hybrides rechargeables.</p>

<p>(13)&laquo;&nbsp;Ces tickets sont &eacute;mis&nbsp;:</p>

<p>(14)&laquo;&nbsp;1&deg;&nbsp;Soit par l&rsquo;employeur au profit des salari&eacute;s directement ou par l&rsquo;interm&eacute;diaire du comit&eacute; social et &eacute;conomique&nbsp;;</p>

<p>(15)&laquo;&nbsp;2&deg;&nbsp;Soit par une entreprise sp&eacute;cialis&eacute;e qui les c&egrave;de &agrave; l&rsquo;employeur contre paiement de leur valeur lib&eacute;ratoire et, le cas &eacute;ch&eacute;ant, d&rsquo;une commission.</p>

<p>(16)&laquo;&nbsp;Le nombre de tickets remis au cours du mois ne peut &ecirc;tre sup&eacute;rieur au nombre de jours travaill&eacute;s ce m&ecirc;me mois par le salari&eacute;.</p>

<p>(17)&laquo;&nbsp;Art.&nbsp;L.&nbsp;3264‚??4.&nbsp;&ndash;&nbsp;L&rsquo;&eacute;metteur de tickets‚??carburant ouvre un compte bancaire ou postal sur lequel sont uniquement vers&eacute;s les fonds qu&rsquo;il per&ccedil;oit en contrepartie de la cession de ces tickets.</p>

<p>(18)&laquo;&nbsp;Le montant des versements est &eacute;gal &agrave; la valeur lib&eacute;ratoire des tickets mis en circulation. Les fonds provenant d&rsquo;autres sources, et notamment des commissions &eacute;ventuellement per&ccedil;ues par les &eacute;metteurs, ne peuvent &ecirc;tre vers&eacute;s aux comptes ouverts en application du pr&eacute;sent article.</p>

<p>(19)&laquo;&nbsp;Art.&nbsp;L.&nbsp;3264‚??5.&nbsp;&ndash;&nbsp;Les comptes pr&eacute;vus &agrave; l&rsquo;article L.&nbsp;3264‚??3 sont des comptes de d&eacute;p&ocirc;ts de fonds intitul&eacute;s &laquo;&nbsp;comptes de tickets‚??carburant.</p>

<p>(20)&laquo;&nbsp;Sous r&eacute;serve des dispositions des articles L.&nbsp;3264‚??6 et L.&nbsp;3264‚??7, ils ne peuvent &ecirc;tre d&eacute;bit&eacute;s qu&rsquo;au profit de stations‚??service distribuant du carburant automobile ou permettant la recharge des v&eacute;hicules &eacute;lectriques.</p>

<p>(21)&laquo;&nbsp;Les &eacute;metteurs sp&eacute;cialis&eacute;s mentionn&eacute;s au&nbsp;2&deg; de l&rsquo;article L.&nbsp;3264‚??3, qui n&rsquo;ont pas d&eacute;pos&eacute; &agrave; l&rsquo;avance &agrave; leur compte de tickets‚??carburant le montant de la valeur lib&eacute;ratoire des tickets‚??carburant qu&rsquo;ils c&egrave;dent &agrave; des employeurs, ne peuvent recevoir de ces derniers, en contrepartie de cette valeur, que des versements effectu&eacute;s au cr&eacute;dit de leur compte, &agrave; l&rsquo;exclusion d&rsquo;esp&egrave;ces, d&rsquo;effets ou de valeurs quelconques.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 102, N'Article 2', N'<p>Au premier alin&eacute;a de l&rsquo;article L.&nbsp;3261‚??3 du m&ecirc;me code, apr&egrave;s le mot&nbsp;:&nbsp;&laquo;&nbsp;travail&nbsp;&raquo; sont ins&eacute;r&eacute;s les mots&nbsp;:&nbsp;&laquo;&nbsp;et non pris en charge par des tickets‚??carburant&nbsp;&raquo;.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 103, N'Article 3', N'<p>(1)Le&nbsp;code g&eacute;n&eacute;ral des collectivit&eacute;s territoriales est ainsi&nbsp;modifi&eacute;&nbsp;:</p>

<p>(2)I.&nbsp;&ndash;&nbsp;Le&nbsp;II de l&rsquo;article L.&nbsp;2333‚??64&nbsp;est r&eacute;tabli dans la r&eacute;daction suivante&nbsp;:</p>

<p>(3)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Lorsque la r&eacute;sidence habituelle ou le lieu de travail du salari&eacute; sont situ&eacute;s hors du ressort territorial d&rsquo;une autorit&eacute; organisatrice de la mobilit&eacute; inclus dans les agglom&eacute;rations de plus de 100&nbsp;000&nbsp;habitants, l&rsquo;employeur peut d&eacute;duire du versement d&ucirc; au titre du salari&eacute; la part contributive des titres‚??carburant remis &agrave; ce salari&eacute;.&nbsp;&raquo;</p>

<p>(4)II.&nbsp;&ndash;&nbsp;Le&nbsp;II de l&rsquo;article L.&nbsp;2531‚??2 est r&eacute;tabli&nbsp;dans la r&eacute;daction suivante&nbsp;:</p>

<p>(5)&laquo;&nbsp;II.&nbsp;&ndash;&nbsp;Lorsque la r&eacute;sidence habituelle ou le lieu de travail du salari&eacute; sont situ&eacute;s hors du ressort territorial d&rsquo;une autorit&eacute; organisatrice de la mobilit&eacute; inclus dans les agglom&eacute;rations de plus de 100&nbsp;000&nbsp;habitants, l&rsquo;employeur peut d&eacute;duire du versement d&ucirc; au titre du salari&eacute; la part contributive des titres‚??carburant remis &agrave; ce salari&eacute;.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 104, N'Article 4', N'<p>(1)Apr&egrave;s le&nbsp;19&deg;&nbsp;ter&nbsp;de l&rsquo;article&nbsp;81 du code g&eacute;n&eacute;ral des imp&ocirc;ts, il est ins&eacute;r&eacute; un&nbsp;19&deg;&nbsp;quater&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;19&deg;&nbsp;quater&nbsp;Dans la limite de 15&nbsp;euros par ticket, le compl&eacute;ment de r&eacute;mun&eacute;ration r&eacute;sultant de la contribution de l&rsquo;employeur &agrave; l&rsquo;acquisition par le salari&eacute; des tickets‚??carburant &eacute;mis conform&eacute;ment aux dispositions du&nbsp;chapitre&nbsp;IV du&nbsp;titre&nbsp;VI du livre&nbsp;II de la troisi&egrave;me partie du code du travail,&nbsp;lorsque cette contribution est comprise entre un minimum et un maximum&nbsp;fix&eacute;s par arr&ecirc;t&eacute; du ministre charg&eacute; du budget. La limite d&rsquo;exon&eacute;ration est relev&eacute;e chaque ann&eacute;e dans la m&ecirc;me proportion que la limite sup&eacute;rieure de la premi&egrave;re tranche du bar&egrave;me de l&rsquo;imp&ocirc;t sur le revenu de l&rsquo;ann&eacute;e pr&eacute;c&eacute;dant celle de l&rsquo;acquisition des tickets‚??restaurant et arrondie, s&rsquo;il y a lieu, au centime d&rsquo;euro le plus proche.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 105, N'Article 5', N'<p>(1)Les dispositions de la pr&eacute;sente loi entrent en vigueur le 1er&nbsp;janvier de l&rsquo;ann&eacute;e suivant sa promulgation et sont abrog&eacute;es le 1er&nbsp;janvier de la troisi&egrave;me ann&eacute;e suivant cette m&ecirc;me promulgation.</p>

<p>(2)Vingt mois apr&egrave;s la promulgation de la pr&eacute;sente loi, le Gouvernement remet au Parlement un rapport sur l&rsquo;application de cette m&ecirc;me loi.</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (15, 106, N'Article 6', N'<p>Les pertes de recettes susceptibles de r&eacute;sulter de la pr&eacute;sente loi pour l&rsquo;&Eacute;tat et les organismes de s&eacute;curit&eacute; sociale sont compens&eacute;es &agrave; due concurrence&nbsp;respectivement par la cr&eacute;ation d&rsquo;une taxe additionnelle aux droits mentionn&eacute;s aux articles&nbsp;575 et&nbsp;575&nbsp;A du code g&eacute;n&eacute;ral des imp&ocirc;ts et par la majoration de ces m&ecirc;mes droits.</p>
')
GO
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (16, 107, N'Article 1', N'<p>)&laquo;&nbsp;Apr&egrave;s le&nbsp;VII de l&rsquo;article L.&nbsp;241‚??13 du code de la&nbsp;s&eacute;curit&eacute; sociale, est ins&eacute;r&eacute; un&nbsp;VII&nbsp;bis&nbsp;ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(2)&laquo;&nbsp;VII&nbsp;bis.&nbsp;&ndash;&nbsp;Dans toute entreprise d&rsquo;au moins vingt salari&eacute;s, lorsque l&rsquo;effectif compte en moyenne, sur une ann&eacute;e civile, plus de 20&nbsp;% de salari&eacute;s &agrave; temps partiel, le montant de la r&eacute;duction est diminu&eacute; de 20&nbsp;% au titre des r&eacute;mun&eacute;rations vers&eacute;es cette m&ecirc;me ann&eacute;e.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (16, 108, N'Article 2', N'<p>(1)L&rsquo;article L.&nbsp;3123‚??7 du code du travail est compl&eacute;t&eacute; par deux alin&eacute;as ainsi r&eacute;dig&eacute;s&nbsp;:</p>

<p>(2)&laquo;&nbsp;Lorsque la dur&eacute;e de travail est inf&eacute;rieure &agrave; vingt‚??quatre heures par semaine et sup&eacute;rieure &agrave; quinze heures par semaine, ces heures de travail sont r&eacute;mun&eacute;r&eacute;es &agrave; un taux major&eacute; de 25&nbsp;%.</p>

<p>(3)&laquo;&nbsp;Lorsque la dur&eacute;e de travail est inf&eacute;rieure ou &eacute;gale &agrave; quinze heures par semaine, ou lorsque la dur&eacute;e quotidienne de travail est inf&eacute;rieure &agrave; deux heures, ces heures de travail sont r&eacute;mun&eacute;r&eacute;es &agrave; un taux major&eacute; de 50&nbsp;%.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (16, 109, N'Article 3', N'<p>(1)La section&nbsp;1 du chapitre&nbsp;III du titre&nbsp;II du livre&nbsp;Ier&nbsp;de la troisi&egrave;me partie du&nbsp;m&ecirc;me&nbsp;code est ainsi modifi&eacute;e&nbsp;:</p>

<p>(2)I.&nbsp;&ndash;&nbsp;&Agrave;&nbsp;l&rsquo;article L.&nbsp;3123‚??21, le taux &laquo;&nbsp;10&nbsp;%&nbsp;&raquo; est remplac&eacute; par le taux &laquo;&nbsp;25&nbsp;%&nbsp;&raquo;.</p>

<p>(3)II.&nbsp;&ndash;&nbsp;L&rsquo;article L.&nbsp;3123‚??22 est ainsi modifi&eacute;&nbsp;:</p>

<p>(4)1&deg;&nbsp;Le&nbsp;2&deg; est ainsi r&eacute;dig&eacute;&nbsp;:</p>

<p>(5)&laquo;&nbsp;2&deg;&nbsp;D&eacute;termine la majoration salariale des heures effectu&eacute;es dans le cadre de cet avenant qui ne peut &ecirc;tre inf&eacute;rieure &agrave; 25&nbsp;%&nbsp;;&nbsp;&raquo;&nbsp;;</p>

<p>(6)2&deg;&nbsp;&Agrave; la fin du dernier alin&eacute;a, le taux &laquo;&nbsp;25&nbsp;%&nbsp;&raquo; est&nbsp;remplac&eacute; par le taux &laquo;&nbsp;50&nbsp;%&nbsp;&raquo;.</p>

<p>(7)III.&nbsp;&ndash;&nbsp;Apr&egrave;s le mot&nbsp;: &laquo;&nbsp;est&nbsp;&raquo; la fin de l&rsquo;article L.&nbsp;3123‚??29 est ainsi r&eacute;dig&eacute;e&nbsp;:&nbsp;&laquo;&nbsp;d&rsquo;au moins 25&nbsp;% pour chacune des heures accomplies.&nbsp;&raquo;</p>
')
INSERT [dbo].[ARTICLE] ([code_txt], [code_seq_art], [titre_art], [texte_art]) VALUES (16, 110, N'Article 4', N'<p>(1)Le deuxi&egrave;me alin&eacute;a de l&rsquo;article&nbsp;L. 1243‚??8 du&nbsp;m&ecirc;me&nbsp;code est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e&nbsp;:</p>

<p>(2)&laquo;&nbsp;Lorsque le contrat de travail est &agrave; temps partiel, l&rsquo;indemnit&eacute; est &eacute;gale &agrave; 20&nbsp;% de la r&eacute;mun&eacute;ration totale brute vers&eacute;e au salari&eacute;.&nbsp;&raquo;</p>
')
SET IDENTITY_INSERT [dbo].[ARTICLE] OFF

/*
--------------------
  TABLE DATE
--------------------
*/
INSERT [dbo].[DATE] ([jour_vote]) VALUES (CAST(N'2019-05-08' AS Date))
INSERT [dbo].[DATE] ([jour_vote]) VALUES (CAST(N'2020-05-19' AS Date))
INSERT [dbo].[DATE] ([jour_vote]) VALUES (CAST(N'2020-05-20' AS Date))
INSERT [dbo].[DATE] ([jour_vote]) VALUES (CAST(N'2020-05-21' AS Date))
INSERT [dbo].[DATE] ([jour_vote]) VALUES (CAST(N'2020-05-22' AS Date))

/*
--------------------
  TABLE VOTER
--------------------
*/

INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (1, CAST(N'2019-05-08' AS Date), 6, 30, 60, 30)
INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (1, CAST(N'2020-05-21' AS Date), 1, 1, 50, 20)
INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (2, CAST(N'2020-05-19' AS Date), 6, 30, 20, 50)
INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (2, CAST(N'2020-05-21' AS Date), 1, 1, 50, 20)
INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (2, CAST(N'2020-05-21' AS Date), 6, 30, 60, 45)
INSERT [dbo].[VOTER] ([code_organe], [jour_vote], [code_txt], [code_seq_art], [nbr_voix_pour], [nbr_voix_contre]) VALUES (2, CAST(N'2020-05-22' AS Date), 1, 1, 45, 35)

/*
--------------------
  TABLE AMENDEMENT
--------------------
*/

SET IDENTITY_INSERT [dbo].[AMENDEMENT] ON 

INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (1, 1, 1, N'Le Confinement -  RÈecriture', N'<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam feugiat, arcu eu porttitor vestibulum, magna mauris placerat odio, non ultrices magna magna id arcu. Nulla facilisi. Vivamus porttitor quis arcu ut varius. Suspendisse potenti. Donec at mollis magna, vel suscipit nisi. Ut tincidunt ullamcorper ipsum. Pellentesque pretium rhoncus risus, at malesuada odio fermentum a. Ut sit amet tortor ornare, pretium nibh at, porta urna. In at congue ligula. Pellentesque interdum aliquam tellus condimentum laoreet. Etiam laoreet sit amet lacus vel auctor. Etiam rhoncus velit sed velit iaculis feugiat. Suspendisse ut quam nec risus convallis posuere.</p>

<p>Praesent a lorem ligula. Fusce id tortor aliquet, accumsan ipsum vel, euismod tellus. Phasellus sit amet euismod ante, euismod congue odio. Maecenas ut odio elementum, vehicula ligula vestibulum, aliquet ex. Fusce varius justo a tortor placerat porttitor. Proin sed faucibus magna, eu tempor odio. Mauris condimentum porta ante. Suspendisse potenti. Duis mollis tortor sit amet.</p>
', CAST(N'2020-05-21' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 86, 2, N'CL7 ', N'<p>I. - Le code &eacute;lectoral est ainsi modifi&eacute; :</p>

<p>1&deg; Apr&egrave;s l&#39;article L. 44, il est ins&eacute;r&eacute; un article L. 44-1 ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>Art. L. 44-1.</em>&nbsp;- Ne peuvent faire acte de candidature les personnes dont le bulletin n&deg; 2 du casier judiciaire comporte une mention de condamnation pour l&#39;une des infractions suivantes :</p>

<p>&laquo; 1&deg; Les crimes ;</p>

<p>&laquo; 2&deg; Les d&eacute;lits pr&eacute;vus aux articles 222-27 &agrave; 222-31, 222-33 et 225-5 &agrave; 225-7 du code p&eacute;nal ;</p>

<p>&laquo; 3&deg; Les d&eacute;lits traduisant un manquement au devoir de probit&eacute; pr&eacute;vus &agrave; la section 3 du chapitre II du titre III du livre IV du m&ecirc;me code ;</p>

<p>&laquo; 4&deg; Les d&eacute;lits traduisant une atteinte &agrave; la confiance publique pr&eacute;vus aux articles 441-2 &agrave; 441-6 dudit code ;</p>

<p>&laquo; 5&deg; Les d&eacute;lits de corruption et de trafic d&#39;influence pr&eacute;vus aux articles 433-1, 433-2, 434-9, 434-9-1, 435-1 &agrave; 435-10 et 445-1 &agrave; 445-2-1 du m&ecirc;me code ;</p>

<p>&laquo; 6&deg; Les d&eacute;lits de recel, pr&eacute;vus aux articles 321-1 et 321-2 du m&ecirc;me code, ou de blanchiment, pr&eacute;vus aux articles 324-1 et 324-2 du m&ecirc;me code, du produit, des revenus ou des choses provenant des infractions mentionn&eacute;es aux 1&deg; et 2&deg; du pr&eacute;sent article ;</p>

<p>&laquo; 7&deg; Les d&eacute;lits pr&eacute;vus aux articles L. 86 &agrave; L. 88-1, L. 91 &agrave; L. 100, L. 102 &agrave; L. 104, L. 106 &agrave; L. 109, L. 111, L. 113 et L. 116 du pr&eacute;sent code ;</p>

<p>&laquo; 8&deg; Le d&eacute;lit pr&eacute;vu &agrave; l&#39;article 1741 du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>

<p>&laquo; Un d&eacute;cret en Conseil d&#39;&Eacute;tat fixe les modalit&eacute;s d&#39;application du pr&eacute;sent article. &raquo; ;</p>

<p>2&deg; Le 3&deg; de l&#39;article L. 340 est ainsi r&eacute;tabli :</p>

<p>&laquo; 3&deg; Les personnes dont le bulletin n&deg; 2 du casier judiciaire comporte une mention de condamnation pour l&#39;une des infractions mentionn&eacute;es &agrave; l&#39;article L. 44-1. &raquo; ;</p>

<p>3&deg; Au premier alin&eacute;a de l&#39;article L. 388, la r&eacute;f&eacute;rence : &laquo; n&deg; 2017-286 du 6 mars 2017 tendant &agrave; renforcer les obligations comptables des partis politiques et des candidats &raquo; est remplac&eacute;e par la r&eacute;f&eacute;rence : &laquo; n&deg; du pour la r&eacute;gulation de la vie publique &raquo; ;</p>

<p>4&deg; Au dernier alin&eacute;a de l&#39;article L. 558-11, apr&egrave;s la r&eacute;f&eacute;rence : &laquo; L. 203 &raquo;, sont ins&eacute;r&eacute;s les mots : &laquo; ainsi que le 3&deg; &raquo;.</p>

<p>II. - Le&nbsp;<em>a</em>&nbsp;du 3&deg; du I de l&#39;article 15 de la loi n&deg; 2016-1048 du 1<sup>er</sup>&nbsp;ao&ucirc;t 2016 r&eacute;novant les modalit&eacute;s d&#39;inscription sur les listes &eacute;lectorales est ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>a)</em>&nbsp;Le premier alin&eacute;a est ainsi r&eacute;dig&eacute; :</p>

<p>&laquo; &laquo; I. - Le titre I<sup>er</sup>&nbsp;du livre I<sup>er</sup>&nbsp;du pr&eacute;sent code, dans sa r&eacute;daction r&eacute;sultant de la loi n&deg; 2016-1048 du 1<sup>er</sup>&nbsp;ao&ucirc;t 2016 r&eacute;novant les modalit&eacute;s d&#39;inscription sur les listes &eacute;lectorales, &agrave; l&#39;exception des articles L. 15, L. 15-1, L. 46-1 et L. 66, est applicable &agrave; l&#39;&eacute;lection : &raquo; ; &raquo;.</p>
', CAST(N'2019-07-20' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 86, 3, N'CL72', N'<p>1&deg;Apr&egrave;s l&#39;article L. 44, il est ins&eacute;r&eacute; un article L. 44-1 ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>Art. L. 44-1.</em>&nbsp;- Ne peuvent faire acte de candidature les personnes dont le bulletin n&deg; 2 du casier judiciaire comporte une mention de condamnation pour l&#39;une des infractions suivantes :</p>

<p>&laquo; 1&deg; Les crimes ;</p>

<p>&laquo; 2&deg; Les d&eacute;lits pr&eacute;vus aux articles 222-27 &agrave; 222-31, 222-33 et 225-5 &agrave; 225-7 du code p&eacute;nal ;</p>

<p>&laquo; 3&deg; Les d&eacute;lits traduisant un manquement au devoir de probit&eacute; pr&eacute;vus &agrave; la section 3 du chapitre II du titre III du livre IV du m&ecirc;me code ;</p>

<p>&laquo; 4&deg; Les d&eacute;lits traduisant une atteinte &agrave; la confiance publique pr&eacute;vus aux articles 441-2 &agrave; 441-6 dudit code ;</p>

<p>&laquo; 5&deg; Les d&eacute;lits de corruption et de trafic d&#39;influence pr&eacute;vus aux articles 433-1, 433-2, 434-9, 434-9-1, 435-1 &agrave; 435-10 et 445-1 &agrave; 445-2-1 du m&ecirc;me code ;</p>

<p>&laquo; 6&deg; Les d&eacute;lits de recel, pr&eacute;vus aux articles 321-1 et 321-2 du m&ecirc;me code, ou de blanchiment, pr&eacute;vus aux articles 324-1 et 324-2 du m&ecirc;me code, du produit, des revenus ou des choses provenant des infractions mentionn&eacute;es aux 1&deg; et 2&deg; du pr&eacute;sent article ;</p>

<p>&laquo; 7&deg; Les d&eacute;lits pr&eacute;vus aux articles L. 86 &agrave; L. 88-1, L. 91 &agrave; L. 100, L. 102 &agrave; L. 104, L. 106 &agrave; L. 109, L. 111, L. 113 et L. 116 du pr&eacute;sent code ;</p>

<p>&laquo; 8&deg; Le d&eacute;lit pr&eacute;vu &agrave; l&#39;article 1741 du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>

<p>&laquo; Un d&eacute;cret en Conseil d&#39;&Eacute;tat fixe les modalit&eacute;s d&#39;application du pr&eacute;sent article. &raquo; ;</p>

<p>2&deg; Le 3&deg; de l&#39;article L. 340 est ainsi r&eacute;tabli :</p>

<p>&laquo; 3&deg; Les personnes dont le bulletin n&deg; 2 du casier judiciaire comporte une mention de condamnation pour l&#39;une des infractions mentionn&eacute;es &agrave; l&#39;article L. 44-1. &raquo;</p>
', CAST(N'2019-07-20' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 86, 4, N'CL29', N'<p>I. - Apr&egrave;s l&#39;alin&eacute;a 4, ins&eacute;rer les deux alin&eacute;as suivants :</p>

<p>&laquo; - les violences, pr&eacute;vues aux articles 222-7 &agrave; 222-16-3 ;</p>

<p>&laquo; - les agressions sexuelles autres que le viol, pr&eacute;vues aux articles 222-27 &agrave; 222-31 ; &raquo;.</p>

<p>II. - Apr&egrave;s l&#39;alin&eacute;a 5, ins&eacute;rer les deux alin&eacute;as suivants :</p>

<p>&laquo; - le prox&eacute;n&eacute;tisme, pr&eacute;vu aux articles 225-5 &agrave; 225-7 ;</p>

<p>&laquo; - la discrimination, pr&eacute;vue aux articles 225-1 &agrave; 225-4 et 432-7, notamment &agrave; raison l&#39;origine, du sexe, de la situation de famille, de la grossesse, de l&#39;apparence physique, du patronyme, du lieu de r&eacute;sidence, de l&#39;&eacute;tat de sant&eacute;, du handicap, des caract&eacute;ristiques g&eacute;n&eacute;tiques, des m&oelig;urs, de l&#39;orientation ou identit&eacute; sexuelle, de l&#39;&acirc;ge, des opinions politiques, des activit&eacute;s syndicales, de l&#39;appartenance ou de la non-appartenance, vraie ou suppos&eacute;e, &agrave; une ethnie, une nation, une race ou une religion d&eacute;termin&eacute;e. ; &raquo;.</p>

<p>III. - Apr&egrave;s l&#39;alin&eacute;a 15, ins&eacute;rer l&#39;alin&eacute;a suivant :</p>

<p>&laquo; - les diffamations et injures pr&eacute;sentant un caract&egrave;re raciste, des propos discriminatoires &agrave; caract&egrave;re sexiste ou homophobe et des provocations &agrave; la discrimination, &agrave; la haine ou &agrave; la violence raciales commis publiquement ou par voie de presse, pr&eacute;vues par l&#39;article 24 de la loi du 29 juillet 1881 sur la libert&eacute; de la presse ; &raquo;.</p>
', CAST(N'2019-07-23' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 86, 5, N'CL28', N'<p>&laquo; - les d&eacute;lits de harc&egrave;lement sexuel et de harc&egrave;lement moral pr&eacute;vus aux articles 222-33, 222-33-2, 222-33-2-1 et 222-33-2-2 ; &raquo;</p>
', CAST(N'2019-07-20' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 86, 6, N'CL10', N'<p>&laquo; - les crimes et d&eacute;lits pr&eacute;vus aux cinqui&egrave;me, septi&egrave;me et huiti&egrave;me alin&eacute;as de l&#39;article 24, &agrave; l&#39;article 24&nbsp;<em>bis</em>, aux deuxi&egrave;me et troisi&egrave;me alin&eacute;as de l&#39;article 32 et aux troisi&egrave;me et quatri&egrave;me alin&eacute;as de l&#39;article 33 de la loi du 29 juillet 1881 sur la libert&eacute; de la presse &raquo;.</p>
', CAST(N'2019-07-28' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 87, 7, N'CL10', N'<p>&laquo;&nbsp;conflits d&#39;int&eacute;r&ecirc;ts entre un int&eacute;r&ecirc;t public et des int&eacute;r&ecirc;ts&nbsp;priv&eacute;s dans lesquels peuvent se trouver &raquo;,</p>

<p>les mots :</p>

<p>&laquo; situations de&nbsp;conflit d&#39;int&eacute;r&ecirc;ts entre un int&eacute;r&ecirc;t public et des int&eacute;r&ecirc;ts&nbsp;publics ou priv&eacute;s de nature &agrave; influencer ou &agrave; para&icirc;tre influencer l&#39;exercice ind&eacute;pendant, impartial et objectif des fonctions &raquo;.</p>
', CAST(N'2019-08-01' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 87, 8, N'CL108', N'<p>&laquo; &agrave; &raquo;,</p>

<p>r&eacute;diger ainsi la fin de l&#39;alin&eacute;a 3 :</p>

<p>&laquo; pr&eacute;venir les situations de conflits d&#39;int&eacute;r&ecirc;ts dans lesquelles il pourrait se trouver, apr&egrave;s avoir consult&eacute;, &agrave; cette fin, l&#39;organe charg&eacute; de de la d&eacute;ontologie parlementaire. Elle pr&eacute;cise &eacute;galement les conditions dans lesquelles chaque d&eacute;put&eacute; ou s&eacute;nateur est tenu de faire cesser imm&eacute;diatement les situations de conflits d&#39;int&eacute;r&ecirc;ts av&eacute;r&eacute;es dans lesquelles ils se trouve, apr&egrave;s avoir consult&eacute; l&#39;organe charg&eacute; de la d&eacute;ontologie parlementaire. &raquo;</p>
', CAST(N'2019-08-10' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 88, 9, N'CL63', N'<p>&laquo; III. - A. - Les personnes ayant exerc&eacute; l&#39;activit&eacute; de repr&eacute;sentant d&#39;int&eacute;r&ecirc;t telle que d&eacute;finie au neuvi&egrave;me alin&eacute;a de l&#39;article 18-2 de la loi n&deg; 2013-907 du 11 octobre 2013 relative &agrave; la transparence de la vie publique dans les dix ans pr&eacute;c&eacute;dents ne sauraient &ecirc;tre admises au conseil d&#39;administration ou au conseil scientifique des organismes suivants :</p>

<p>&laquo; - l&#39;Agence fran&ccedil;aise de lutte contre le dopage ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de la concurrence ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de contr&ocirc;le des nuisances a&eacute;roportuaires ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de contr&ocirc;le prudentiel et de r&eacute;solution ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de r&eacute;gulation de la distribution de la presse ;</p>

<p>&laquo; - l&#39;Autorit&eacute; des march&eacute;s financiers ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de r&eacute;gulation des activit&eacute;s ferroviaires et routi&egrave;res ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de r&eacute;gulation des communications &eacute;lectroniques et des postes ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de r&eacute;gulation des jeux en ligne ;</p>

<p>&laquo; - l&#39;Autorit&eacute; de s&ucirc;ret&eacute; nucl&eacute;aire ;</p>

<p>&laquo; - le Comit&eacute; consultatif national d&#39;&eacute;thique pour les sciences de la vie et de la sant&eacute; ;</p>

<p>&laquo; - la Commission nationale d&#39;am&eacute;nagement cin&eacute;matographique ;</p>

<p>&laquo; - la Commission nationale d&#39;am&eacute;nagement commercial ;</p>

<p>&laquo; - la Commission nationale des comptes de campagne et des financements politiques ;</p>

<p>&laquo; - la Commission nationale consultative des droits de l&#39;homme ;</p>

<p>&laquo; - la Commission nationale de contr&ocirc;le des techniques de renseignement ;</p>

<p>&laquo; - la Commission nationale du d&eacute;bat public ;</p>

<p>&laquo; - la Commission nationale de l&#39;informatique et des libert&eacute;s ;</p>

<p>&laquo; - la Commission du secret de la d&eacute;fense nationale ;</p>

<p>&laquo; - le Comit&eacute; d&#39;indemnisation des victimes des essais nucl&eacute;aires ;</p>

<p>&laquo; - la Commission d&#39;acc&egrave;s aux documents administratifs ;</p>

<p>&laquo; - la Commission des participations et des transferts ;</p>

<p>&laquo; - la Commission de r&eacute;gulation de l&#39;&eacute;nergie ;</p>

<p>&laquo; - le Conseil sup&eacute;rieur de l&#39;audiovisuel ;</p>

<p>&laquo; - le Contr&ocirc;leur g&eacute;n&eacute;ral des lieux de privation de libert&eacute; ;</p>

<p>&laquo; - le D&eacute;fenseur des droits ;</p>

<p>&laquo; - la Haute Autorit&eacute; pour la diffusion des &oelig;uvres et la protection des droits sur internet ;</p>

<p>&laquo; - la Haute Autorit&eacute; de sant&eacute; ;</p>

<p>&laquo; - la Haute Autorit&eacute; pour la transparence de la vie publique ;</p>

<p>&laquo; - le Haut Conseil du commissariat aux comptes ;</p>

<p>&laquo; - le Haut Conseil de l&#39;&eacute;valuation de la recherche et de l&#39;enseignement sup&eacute;rieur ;</p>

<p>&laquo; - le M&eacute;diateur national de l&#39;&eacute;nergie ;</p>

<p>&laquo; - le Conseil national de l&#39;Alimentation.</p>

<p>&laquo; B. - La fonction de membre de conseil d&#39;administration d&#39;&eacute;tablissements publics ou de groupements d&#39;int&eacute;r&ecirc;t public est incompatible avec l&#39;exercice de toute fonction dans un conseil d&#39;administration de soci&eacute;t&eacute; commerciale. &raquo;</p>
', CAST(N'2019-08-23' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 96, 10, N'CL25', N'<p>I. - Le livre premier du code g&eacute;n&eacute;ral des imp&ocirc;ts est ainsi modifi&eacute; :</p>

<p>1&deg; L&#39;article 80&nbsp;<em>undecies</em>&nbsp;est abrog&eacute; ;</p>

<p>2&deg; &Agrave; l&#39;intitul&eacute; du A du VI de la premi&egrave;re sous-section de la section II du chapitre premier du titre premier de la premi&egrave;re partie, apr&egrave;s le mot : &laquo; b&eacute;n&eacute;fices &raquo;, sont ins&eacute;r&eacute;s les mots : &laquo; et indemnit&eacute;s &raquo; ;</p>

<p>3&deg; Apr&egrave;s l&#39;article 92 A, il est ins&eacute;r&eacute; un article 92 B ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>Art. 92 B</em>&nbsp;- I. - Pour l&#39;&eacute;tablissement de l&#39;imp&ocirc;t, l&#39;indemnit&eacute; parlementaire et l&#39;indemnit&eacute; de fonction pr&eacute;vues aux articles 1<sup>er</sup>&nbsp;et 2 de l&#39;ordonnance n&deg; 58-1210 du 13 d&eacute;cembre 1958 portant loi organique relative &agrave; l&#39;indemnit&eacute; des membres du Parlement, l&#39;indemnit&eacute; de r&eacute;sidence, l&#39;indemnit&eacute; repr&eacute;sentative de frais de mandat, ainsi que les indemnit&eacute;s vers&eacute;es par les assembl&eacute;es &agrave; certains de leurs membres, en vertu d&#39;une d&eacute;cision du bureau desdites assembl&eacute;es, en raison de l&#39;exercice de fonctions particuli&egrave;res, sont consid&eacute;r&eacute;es comme des revenus assimil&eacute;s aux b&eacute;n&eacute;fices non commerciaux.</p>

<p>&laquo; II. - Le revenu &agrave; retenir dans les bases de l&#39;imp&ocirc;t est constitu&eacute; par l&#39;exc&eacute;dent des indemnit&eacute;s mentionn&eacute;es au I sur les d&eacute;penses n&eacute;cessit&eacute;es par l&#39;exercice de la fonction parlementaire. Le Bureau de chaque assembl&eacute;e d&eacute;finit les limites dans lesquelles les d&eacute;penses expos&eacute;es par les membres du Parlement au titre de leur fonction sont d&eacute;ductibles. &raquo; ;</p>

<p>4&deg; Le&nbsp;<em>a</em>&nbsp;du 1&deg; du 7 de l&#39;article 158 est compl&eacute;t&eacute; par une phrase ainsi r&eacute;dig&eacute;e :</p>

<p>&laquo; L&#39;adh&eacute;sion &agrave; une association de gestion mentionn&eacute;e &agrave; l&#39;article 1649&nbsp;<em>quater</em>&nbsp;I A est obligatoire pour les membres du Parlement au titre des revenus mentionn&eacute;s &agrave; l&#39;article 92 B ; &raquo; ;</p>

<p>5&deg; Apr&egrave;s le II du chapitre I&nbsp;<em>ter</em>&nbsp;du titre premier de la troisi&egrave;me partie, il est ins&eacute;r&eacute; un II&nbsp;<em>bis</em>&nbsp;ainsi r&eacute;dig&eacute; :</p>

<p>&laquo; II&nbsp;<em>bis</em>&nbsp;: Associations agr&eacute;&eacute;es des membres du Parlement</p>

<p>&laquo;&nbsp;<em>Art. 1649</em>&nbsp;quater&nbsp;<em>I A</em><em>.</em>&nbsp;- Les membres du Parlement peuvent cr&eacute;er des associations de gestion charg&eacute;es de s&#39;assurer de la r&eacute;gularit&eacute; des d&eacute;clarations que leur soumettent leurs adh&eacute;rents. &Agrave; cet effet, elles leur demandent tous renseignements et documents utiles de nature &agrave; &eacute;tablir, chaque ann&eacute;e, la concordance, la coh&eacute;rence et la vraisemblance desdites d&eacute;clarations. Ces associations peuvent &ecirc;tre agr&eacute;&eacute;es dans des conditions fix&eacute;es par d&eacute;cret en Conseil d&#39;&Eacute;tat. &raquo;</p>

<p>II. - La perte de recettes pour l&#39;&Eacute;tat est compens&eacute;e &agrave; due concurrence par la cr&eacute;ation d&#39;une taxe additionnelle aux droits mentionn&eacute;s aux articles 575 et 575 A du code g&eacute;n&eacute;ral des imp&ocirc;ts.</p>
', CAST(N'2019-08-10' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (13, 96, 11, N'CL15', N'<p>Apr&egrave;s l&#39;article 4&nbsp;<em>quinquies</em>&nbsp;de l&#39;ordonnance n&deg; 58-1100 du 17 novembre 1958 relative au fonctionnement des assembl&eacute;es parlementaires, il est ins&eacute;r&eacute; un article 4&nbsp;<em>sexies</em>&nbsp;ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>Art. 4</em>&nbsp;sexies. - Chaque assembl&eacute;e parlementaire d&eacute;finit la nature des d&eacute;penses constituant des frais de mandat. Chaque d&eacute;put&eacute; ou s&eacute;nateur per&ccedil;oit mensuellement une avance sur ces d&eacute;penses, dans la limite d&#39;un plafond fix&eacute; par l&#39;assembl&eacute;e dont il rel&egrave;ve. Il tient une comptabilit&eacute; des d&eacute;penses r&eacute;ellement expos&eacute;es et en d&eacute;tient les justificatifs. Cette comptabilit&eacute; est pr&eacute;sent&eacute;e et transmise annuellement par un expert-comptable qui atteste de l&#39;absence de tout &eacute;l&eacute;ment remettant en cause la sinc&eacute;rit&eacute;, la r&eacute;gularit&eacute; et l&#39;image fid&egrave;le des d&eacute;penses ainsi financ&eacute;es.</p>

<p>&laquo; L&#39;exc&eacute;dent des avances sur les d&eacute;penses est revers&eacute; chaque ann&eacute;e au budget de l&#39;assembl&eacute;e concern&eacute;e.</p>

<p>&laquo; Ces comptabilit&eacute;s font l&#39;objet de contr&ocirc;les d&eacute;finis par le bureau de l&#39;Assembl&eacute;e concern&eacute;e.</p>

<p>&laquo; Chaque assembl&eacute;e d&eacute;finit les sanctions applicables en cas de manquement aux obligations r&eacute;sultant du pr&eacute;sent article. &raquo;</p>
', CAST(N'2019-08-13' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 12, N'CE10', N'<p>&laquo; , sous r&eacute;serve de l&#39;application des clauses de confidentialit&eacute; ou de non-concurrence stipul&eacute;es par le contrat de travail. &raquo;</p>
', CAST(N'2020-01-08' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 13, N'CE18', N'<p>&laquo; r&eacute;pr&eacute;hensible &raquo;,</p>

<p>ins&eacute;rer les mots :</p>

<p>&laquo; , une menace ou un pr&eacute;judice graves pour l&#39;int&eacute;r&ecirc;t g&eacute;n&eacute;ral &raquo;.</p>
', CAST(N'2020-01-10' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 14, N'CE29', N'<p>&laquo; s&eacute;curit&eacute; publique &raquo;,</p>

<p>ins&eacute;rer les mots :</p>

<p>&laquo; , des droits et libert&eacute;s fondamentales &raquo;</p>
', CAST(N'2020-01-10' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 15, N'CE22', N'<p>Apr&egrave;s l&#39;alin&eacute;a 11, ins&eacute;rer les sept alin&eacute;as suivant :</p>

<p>&laquo; Ne peut &ecirc;tre prot&eacute;g&eacute;e au titre du secret des affaires toute information relative :</p>

<p>- &agrave; une d&eacute;couverte scientifique qui aurait un impact substantiel b&eacute;n&eacute;fique pour le bien-&ecirc;tre de l&#39;humanit&eacute; et de l&#39;environnement ;</p>

<p>- &agrave; l&#39;impact environnemental et sanitaire de son activit&eacute; ainsi que celles de ses sous-traitants et filiales ;</p>

<p>- aux conditions de travail de ses salari&eacute;s, sa politique de recrutement, de licenciement, de r&eacute;mun&eacute;ration ainsi que celles de ses sous-traitants et filiales ;</p>

<p>- aux relations entretenues par une personne avec ses sous-traitants et filiales ;</p>

<p>- aux informations de nature fiscale relatives &agrave; l&#39;optimisation fiscale, &agrave; l&#39;existence de montages fiscaux ;</p>

<p>- aux informations de toute nature qui permettent d&#39;&eacute;tablir l&#39;existence d&#39;une fraude fiscale ou sociale, d&#39;une &eacute;vasion fiscale, de la commission d&#39;infractions p&eacute;nales, et de financement du terrorisme. &raquo;</p>
', CAST(N'2020-01-09' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 17, N'CE31', N'<p>&laquo; sauf lorsque l&#39;&Eacute;tat, une ou plusieurs associations reconnues d&#39;utilit&eacute; publique, un ou plusieurs syndicats, au nom de l&#39;int&eacute;r&ecirc;t g&eacute;n&eacute;ral, d&eacute;cident de s&#39;y substituer. Ces dispositions sont pr&eacute;cis&eacute;es par un d&eacute;cret en Conseil d&#39;&Eacute;tat. &raquo;</p>
', CAST(N'2020-01-16' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 99, 18, N'CE33', N'<p>Apr&egrave;s l&#39;article L. 311-3 du code des relations entre le public et l&#39;administration, il est ins&eacute;r&eacute; un article L. 311-3-1 A ainsi r&eacute;dig&eacute; :</p>

<p>&laquo;&nbsp;<em>Art. L. 311-3-1 A</em>. - I. - Les rapports des corps d&#39;inspection de l&#39;&Eacute;tat sont librement accessibles aux journalistes titulaires de la carte d&#39;identit&eacute; professionnelle mentionn&eacute;e &agrave; l&#39;article L. 7111-6 du code du travail, et aux associations reconnues d&#39;utilit&eacute; publique. Sur simple demande, ils peuvent &ecirc;tre consultables sur place, ou transmis par voie &eacute;lectronique.</p>

<p>&laquo; Un d&eacute;cret en Conseil d&#39;&Eacute;tat fixe les conditions d&#39;application du pr&eacute;sent I.</p>

<p>&laquo; II. - Le fait d&#39;entraver, d&#39;une mani&egrave;re concert&eacute;e l&#39;exercice du droit d&#39;information mentionn&eacute; au I est puni d&#39;un an d&#39;emprisonnement et de 15 000 euros d&#39;amende. &raquo;</p>
', CAST(N'2020-01-26' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (14, 100, 16, N'CE37', N'<table border="0" cellpadding="2" cellspacing="0">
	<tbody>
		<tr>
			<td>
			<p>La pr&eacute;sente loi entre en vigueur lorsque l&#39;harmonisation sociale et fiscale europ&eacute;enne est effectivement r&eacute;alis&eacute;e.</p>
			</td>
		</tr>
	</tbody>
</table>
', CAST(N'2020-01-18' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (15, 101, 19, N'AS3', N'<p>&laquo; et la valeur qu&#39;ils repr&eacute;sentent ne doit pas &ecirc;tre sup&eacute;rieure au co&ucirc;t des trajets domicile-travail du salari&eacute; sur cette m&ecirc;me p&eacute;riode. &raquo;</p>
', CAST(N'2020-02-14' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (15, 101, 20, N'AS2', N'<p>&Agrave; l&#39;alin&eacute;a 7 substituer aux mots :</p>

<p>&laquo; et la part contributive de l&#39;employeur sont deÃÅcideÃÅes &raquo;</p>

<p>les mots : &laquo; est pr&eacute;vue &raquo;.</p>
', CAST(N'2020-02-14' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (15, 101, 21, N'AS4', N'<p>Apr&egrave;s l&#39;alin&eacute;a 9, ins&eacute;rer l&#39;alin&eacute;a suivant :</p>

<p>&laquo; La part contributive de l&#39;employeur repr&eacute;sente entre 50 % et 80 % de la valeur du ticket-carburant. &raquo;</p>
', CAST(N'2020-02-22' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (16, 107, 22, N'10', N'<p>Supprimer cet article.</p>
', CAST(N'2020-04-02' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (16, 108, 23, N'9', N'<p>Supprimer cet article.</p>
', CAST(N'2020-04-02' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (16, 109, 24, N'15A', N'<p>Supprimer cet article.</p>
', CAST(N'2020-04-10' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (16, 109, 25, N'3JA', N'<p>R&eacute;diger ainsi l&#39;alin&eacute;a 7 : &laquo; III. - Apr&egrave;s la troisi&egrave;me occurrence du mot : &laquo; de &raquo;, la fin de l&#39;article L. 3123-29 est ainsi r&eacute;dig&eacute;e : &laquo; 25 % pour chacune des heures accomplies. &raquo;</p>
', CAST(N'2020-04-21' AS Date))
INSERT [dbo].[AMENDEMENT] ([code_txt], [code_seq_art], [code_seq_amend], [lib_amend], [texte_amend], [date_amend]) VALUES (16, 110, 26, N'37A', N'<p>Supprimer cet article.</p>
', CAST(N'2020-04-19' AS Date))
SET IDENTITY_INSERT [dbo].[AMENDEMENT] OFF
