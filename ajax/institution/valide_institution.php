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
$tab['id_type_insti']=$_POST['id_type_insti'];

$data=$mypdo->modif_institution($tab);
echo json_encode($data);
?>
