<?php

session_start();

include_once('../../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();


$tab['titre']=$_POST['titre'];
$tab['corps']=$_POST['corps'];
$tab['date_amend']=$_POST['date_amend'];
$tab['id_texte']=$_POST['id_texte'];
$tab['id_article']=$_POST['id_article'];
$tab['id_amend']=$_POST['id_amend'];

$data=$mypdo->modif_amendement($tab);
echo json_encode($data);
?>
