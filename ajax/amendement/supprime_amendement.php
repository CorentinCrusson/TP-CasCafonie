<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_amend']))
{
	// exécution de la requête
    $resultat = $mypdo->suppr_amendement($_POST['id_amend']);
    $data = $resultat;
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
