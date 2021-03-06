<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_texte']))
{
	// exécution de la requête
    $resultat = $mypdo->suppr_texte($_POST['id_texte']);
    $data = $resultat;
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
