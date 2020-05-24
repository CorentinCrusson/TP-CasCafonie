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
$tab['id_texte']=$_POST['id_texte'];
$tab['id_article']=$_POST['id_article'];


$data=$mypdo->modif_article($tab);
echo json_encode($data);
?>
