<?php
class page_base_securisee_greffier extends page_base {

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
			if($_SESSION['type']!='2')
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
			Gestion Vote </a>
		</li>
		';

	}
}
?>
