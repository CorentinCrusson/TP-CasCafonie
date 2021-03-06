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
		<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="#">
				Gestion Institutions
				<b class="caret"></b>
			</a>


			<ul class="dropdown-menu">
				<a class="nav-link"  href="'.$this->path.'/proposerInstitution" > Proposer une Institution <span class="sr-only">(current)</span></a></li>
				<a class="nav-link"  href="'.$this->path.'/modifierInstitution" > Modifier une Institution <span class="sr-only">(current)</span></a></li>
			</ul>
		</li>
		';

	}
}
?>
