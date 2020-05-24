<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_article']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_article_via_id($_POST['id_article']);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["titre"][] = ($donnees->titre_art);
		$data["corps"][] = ($donnees->texte_art);
		$data["id_texte"][] = ($donnees->code_txt);
	}
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
