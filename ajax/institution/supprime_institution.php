<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_institution']))
{
	// exécution de la requête
    $resultat = $mypdo->suppr_institution($_POST['id_institution']);
    $data = $resultat;
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
