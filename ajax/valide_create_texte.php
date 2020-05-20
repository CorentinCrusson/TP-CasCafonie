<?php

session_start();

include_once('../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();


$tab['titre']=$_POST['titre'];

$data=$mypdo->create_texte($tab);
echo json_encode($data);
?>
