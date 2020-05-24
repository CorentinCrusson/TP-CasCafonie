<?php

session_start();

include_once('../../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();


$tab['titre']=$_POST['titre'];
$tab['id_insti']=$_POST['id_insti'];
$tab['code_texte']=$_POST['code_texte'];
$tab['vote_final_txt']=$_POST['vote_final_txt'];
$tab['promulgation_txt']=$_POST['promulgation_txt'];

$data=$mypdo->modif_texte($tab);
echo json_encode($data);
?>
