<?php

session_start();

include_once('../../class/autoload.php');

$errors         = array();
$data 			= array();
$data['success']=false;

$tab=array();
$mypdo=new mypdo();

$tab['id_txt']=$_POST['id_txt'];
$tab['id_art']=$_POST['id_art'];
$tab['id_org']=$_POST['id_org'];
$tab['nbr_voix_pour']=$_POST['nbr_voix_pour'];
$tab['nbr_voix_contre']=$_POST['nbr_voix_contre'];
$tab['jour_vote']=$_POST['jour_vote'];

$data=$mypdo->create_vote($tab);
echo json_encode($data);
?>
