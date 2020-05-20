<?php
class page_base_securisee_secretaire extends page_base {

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
		<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="#">
				Gestion Textes de Loi
				<b class="caret"></b>
			</a>

			<ul class="dropdown-menu">
				<a class="nav-link"  href="'.$this->path.'/proposerTexte" > Proposer un Texte <span class="sr-only">(current)</span></a></li>
				<a class="nav-link"  href="'.$this->path.'/modifierTexte" > Modifier un Texte <span class="sr-only">(current)</span></a></li>
			</ul>
		</li>
		<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="#">
				Gestion Articles
				<b class="caret"></b>
			</a>

			<ul class="dropdown-menu">
				<a class="nav-link"  href="'.$this->path.'/proposerArticle" > Proposer un Article <span class="sr-only">(current)</span></a></li>
				<a class="nav-link"  href="'.$this->path.'/modifierArticle" > Modifier un Article <span class="sr-only">(current)</span></a></li>
			</ul>
		</li>
		<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="#">
				Gestion Amendements
				<b class="caret"></b>
			</a>

			<ul class="dropdown-menu">
				<a class="nav-link"  href="'.$this->path.'/proposerAmendement" > Proposer un Amendement <span class="sr-only">(current)</span></a></li>
				<a class="nav-link"  href="'.$this->path.'/modifierAmendement" > Modifier un Amendement <span class="sr-only">(current)</span></a></li>
			</ul>
		</li>
		';

	}
}
?>
