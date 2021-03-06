<?php
session_start();
include_once('../../class/autoload.php');
$data = array();
$mypdo=new mypdo();

if(isset($_POST['id_amend']))
{
	// exécution de la requête
	$resultat = $mypdo->trouve_amendement_via_id($_POST['id_amend']);
	if(isset($resultat))
	{
		// résultats
		$donnees = $resultat->fetch(PDO::FETCH_OBJ);
		$data["titre"][] = ($donnees->lib_amend);
		$data["corps"][] = ($donnees->texte_amend);
		$data["date_amend"][] = ($donnees->date_amend);
		$data["id_texte"][] = ($donnees->code_txt);
		$code_txt = ($donnees->code_txt);
		$data["id_article"][] = ($donnees->code_seq_art);
	}

	$resultat = $mypdo->trouve_toutes_les_articles_via_un_texte($code_txt);
	if(isset($resultat))
	{
        while($donnees = $resultat->fetch(PDO::FETCH_OBJ)) {
            $data[$donnees->code_seq_art][] = ($donnees->titre_art);
        }
    }
}
// renvoit un tableau dynamique encodé en json
echo json_encode($data);
?>
