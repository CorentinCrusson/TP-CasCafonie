<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$tab = array();
$mypdo=new mypdo();

if(isset($_POST['id_txt']) and isset($_POST['id_organe']) and isset($_POST['id_article']) and isset($_POST['jour_vote']) )
{
    // exécution de la requête
    $tab['code_txt'] = $_POST['id_txt'];
    $tab['code_organe'] = $_POST['id_organe'];
    $tab['code_seq_art'] = $_POST['id_article'];
    $tab['jour_vote'] = $_POST['jour_vote'];

    $resultat = $mypdo->suppr_vote($tab);
    $data = $resultat;
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
