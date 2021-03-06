<?php
session_start();
include_once('../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_texte']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_texte_via_id($_POST['id_texte']);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["titre_txt"][] = ($donnees->titre_txt);
    }
    
    $resultat = $mypdo->trouve_toutes_les_articles_via_un_texte($_POST['id_texte']);
    if(isset($resultat))
	{
        while($donnees = $resultat->fetch(PDO::FETCH_OBJ)) {
            $data[$donnees->titre_art][] = ($donnees->texte_art);
        }
    }
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
