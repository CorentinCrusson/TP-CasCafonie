<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$tab =array();
$mypdo=new mypdo();

if(isset($_POST['id_texte']) and isset($_POST['id_organe']) and isset($_POST['id_article']) and isset($_POST['jour_vote']) )
{
    // exécution de la requête
    $tab['code_txt'] = $_POST['id_texte'];
    $tab['code_organe'] = $_POST['id_organe'];
    $tab['code_seq_art'] = $_POST['id_article'];
	$tab['jour_vote'] = $_POST['jour_vote'];
	
	// exécution de la requête
	$resultat = $mypdo->trouve_vote_via_id($tab);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["nbr_vote_pour"][] = ($donnees->nbr_voix_pour);
		$data["nbr_vote_contre"][] = ($donnees->nbr_voix_contre);
	}
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
