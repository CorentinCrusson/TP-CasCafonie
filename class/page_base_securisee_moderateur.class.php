<?php
class page_base_securisee_moderateur extends page_base {

	public function __construct() {
		parent::__construct();
	}
	public function affiche() {
		if(!isset($_SESSION['id']) || !isset($_SESSION['type']))
		{
			echo '<script>document.location.href="Accueil"; </script>';

		}
		else
		{
			if($_SESSION['type']!='1')
			{
				echo '<script>document.location.href="Accueil"; </script>';
			}
			else
			{
				parent::affiche();
			}
		}
	}
	public function affiche_menu() {

		parent::affiche_menu();
		echo '
		<li class="nav-item dropdown">
			<a class="nav-link dropdown-toggle" id="navbarDropdown" role="button" href="" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
			Gestion Article </a>

			<div class="dropdown-menu" aria-labelledby="navbarDropdown">
				<a class="dropdown-item" href="proposerArticle">Proposer un article</a>
				<a class="dropdown-item" href="modifierArticle">Modifier un article</a>					
				<a class="dropdown-item" href="validerArticle">Valider un article</a>
			</div>
			<a class="nav-link dropdown-toggle" id="navbarDropdown" role="button" href="" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
			Gestion Vote </a>
		</li>
		';

	}
}
?>
