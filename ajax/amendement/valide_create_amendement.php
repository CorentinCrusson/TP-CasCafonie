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
$tab['id_txt']=$_POST['id_txt'];
$tab['id_art']=$_POST['id_art'];

$data=$mypdo->create_amendement($tab);
echo json_encode($data);
?>
