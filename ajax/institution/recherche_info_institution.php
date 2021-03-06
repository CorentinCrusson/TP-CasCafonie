<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_institution']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_institution_via_id($_POST['id_institution']);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["titre"][] = ($donnees->nom_insti);
		$data["code_type_insti"][] = ($donnees->code_type_insti);
	}
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
