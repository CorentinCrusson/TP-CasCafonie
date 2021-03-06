<?php

session_start();

include_once('../../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();


$tab['id_texte']=$_POST['id_texte'];
$tab['id_article']=$_POST['id_article'];
$tab['id_organe']=$_POST['id_organe'];
$tab['nbr_voix_pour']=$_POST['nbr_voix_pour'];
$tab['nbr_voix_contre']=$_POST['nbr_voix_contre'];
$tab['jour_vote']=$_POST['jour_vote'];

$data=$mypdo->modif_vote($tab);
echo json_encode($data);
?>
