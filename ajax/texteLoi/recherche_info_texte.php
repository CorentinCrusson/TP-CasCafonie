<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_texte']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_texte_via_id($_POST['id_texte']);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["titre"][] = ($donnees->titre_txt);
		$data["code_insti"][] = ($donnees->code_insti);
		$data["vote_final_txt"][] = ($donnees->vote_final_txt);
		$data["promulgation_txt"][] = ($donnees->promulgation_txt);
	}
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
