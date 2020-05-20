<?php
include_once('../class/autoload.php');
$data = array();
$mypdo=new mypdo();
if(isset($_POST['id_txt']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_toutes_les_articles_via_un_texte($_POST['id_txt']);
	if(isset($resultat))
	{
		// résultats
		while($donnees = $resultat->fetch(PDO::FETCH_OBJ)) {
			// je remplis un tableau et mettant le nom de la ville en index pour garder le tri
			$data[$donnees->code_seq_art][] = ($donnees->titre_art);
		}
	}
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
