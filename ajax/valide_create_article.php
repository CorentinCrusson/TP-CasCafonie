<?php

session_start();

include_once('../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();


$tab['titre']=$_POST['titre'];
$tab['corps']=$_POST['corps'];
$tab['id_txt']=$_POST['id_txt'];

$data=$mypdo->create_article($tab);
echo json_encode($data);
?>
