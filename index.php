<?php
	session_start();

	include_once('class/autoload.php');
	$site = connexsecurise();
	$controleur=new controleur();
	$request = strtolower($_SERVER['REQUEST_URI']);
	$params = explode('/', trim($request, '/'));
 	$params = array_filter($params);

	$_SESSION["KCFINDER"] = array("disabled" => false);
	if (!isset($params[3]))
	{

		$params[3]='accueil';
	}
	switch ($params[3]) {

		case 'accueil' :
			$site->titre='Accueil';
			$site->js='imgResponsive';

			$site->right_sidebar=$controleur->retourne_monarque();
			
			$site->left_sidebar=$controleur->retourne_actualites();
			$site->affiche();
			break;
		case 'textesloi':
			$site->titre='Textes de Loi';
			$site->js='texteLoi';
			
			$site->left_sidebar=$controleur->retourne_texte_loi();
			$site->affiche();
			break;
		
		case 'amendements':
			$site->titre='Amendements';
			$site->js='amendements';
				
			$site->left_sidebar=$controleur->retourne_amendements();
			$site->affiche();
			break;

		case 'nousconnaitre':
			$site->titre='Nous Connaitre';
				
			$site->left_sidebar=$controleur->retourne_nousconnaitre();
			$site->affiche();
			break;
		case 'forum':
			$site->titre='Forum';

			$site->left_sidebar=$controleur->retourne_sujet_forum();
			$site->affiche();
			break;

			case 'proposerarticle':
				$site->titre='Création Article';
				$site->js='article/createArticle';
	
				$site->js='jquery.validate.min';
				$site->js='messages_fr';
				$site->js='tooltipster.bundle.min';
				$site->js='jquery-ui.min';
				$site->js='datepicker-fr';
				$site->js='jquery.dataTables.min';
				$site->js='dataTables.bootstrap4.min';
				$site->js='all';
	
				$site->css='dataTables.bootstrap4.min';
				$site->css='jquery-ui.min';
				$site->css='jquery-ui.theme.min';
				$site->css='tooltipster.bundle.min';
				$site->css='all';
				$site->css='tooltipster-sideTip-Light.min';
	
				echo "<script src='js/ckeditor/ckeditor.js'></script>\n";
	
				$site->right_sidebar=$site->rempli_right_sidebar();
				$site->left_sidebar=$controleur->retourne_formulaire_article(['""','createarticle','Création Article','Créer']);
				$site->left_sidebar=$controleur->retourne_modal_message();
				$site->affiche();
				break;
	
			case 'modifierarticle':
				$site->titre='Modifier Article';
				$site->js='article/modifArticle';
	
				$site->js='jquery.validate.min';
				$site->js='messages_fr';
				$site->js='tooltipster.bundle.min';
				$site->js='jquery-ui.min';
				$site->js='datepicker-fr';
				$site->js='jquery.dataTables.min';
				$site->js='dataTables.bootstrap4.min';
				$site->js='all';
	
				$site->css='dataTables.bootstrap4.min';
				$site->css='jquery-ui.min';
				$site->css='jquery-ui.theme.min';
				$site->css='tooltipster.bundle.min';
				$site->css='all';
				$site->css='tooltipster-sideTip-Light.min';
				$site->css='fontawesome.min';
	
				echo "<script src='js/ckeditor/ckeditor.js'></script>\n";
	
				$site->right_sidebar=$site->rempli_right_sidebar();
				$site->left_sidebar=$controleur->retourne_article_journaliste();
				$site->left_sidebar=$controleur->retourne_formulaire_article(['"display: none;"','modifarticle','Modification Article','Modifier']);
				$site->left_sidebar=$controleur->retourne_modal_message();
				$site->affiche();
				break;
		case 'vote':
			$site->titre="Vote";

			$site->left_sidebar=$controleur->retourne_stats_vote();
			break;

		case 'connexion' :
			$site->titre='Connexion';
			$site->js='jquery.validate.min';
			$site->js='jquery.tooltipster.min';
			$site->js='messages_fr';
			$site->js='tooltipster.bundle.min';
			$site->js='connexion';
			$site->js='fontawesome.min';
			$site->js='all';

			$site->css='tooltipster.bundle.min';
			$site->css='all';
			$site->css='fontawesome.min';
			$site->css='tooltipster-sideTip-light.min';

			$site-> left_sidebar=$controleur->retourne_formulaire_login();
			$site-> left_sidebar=$controleur->retourne_modal_message();
			$site->affiche();
			break;

		case 'deconnexion' :
			$_SESSION=array();
			session_destroy();

			echo '<script> document.location.href="./Accueil"; </script>';
			break;

		default:
			$site->titre='Accueil';
			$site-> right_sidebar=$site->rempli_right_sidebar();
			$site-> left_sidebar='<img src="'.$site->path.'/image/erreur-404.png" alt="Erreur de liens">';
			$site->affiche();
			break;
	}

	function connexsecurise() {
		$retour;

		if(!isset($_SESSION['id']) || !isset($_SESSION['type']))
		{
			$retour = new page_base();

		}
		else
		{
			if($_SESSION['type']=='3')
			{
				$retour = new page_base_securisee_moderateur();
			}
			if($_SESSION['type']=='2')
			{
				$retour = new page_base_securisee_greffier();
			}
			if($_SESSION['type']=='1')
			{
				$retour = new page_base_securisee_secretaire();
			}			
		}
		return $retour;	
	}


?>
