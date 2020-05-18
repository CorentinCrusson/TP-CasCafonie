<?php
class mypdo extends PDO{

    private $PARAM_hote='MSI\SQLEXPRESS'; // le chemin vers le serveur
    private $PARAM_utilisateur='adminCafonie';//'adminCafonie'; // nom d'utilisateur pour se connecter
    private $PARAM_mot_passe='adminCafonie';//'adminCafonie'; // mot de passe de l'utilisateur pour se connecter
    private $PARAM_nom_bd='SIO2_CasCafonie';
    private $connexion;
    public function __construct() {
    	try {

    		//$this->connexion = new PDO('mysql:host='.$this->PARAM_hote.';dbname='.$this->PARAM_nom_bd, $this->PARAM_utilisateur, $this->PARAM_mot_passe,array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
			//$this->connexion = new PDO('sqlsrv:Server='.$this->PARAM_hote.';Database='.$this->PARAM_nom_bd, $this->PARAM_utilisateur, $this->PARAM_mot_passe);
			$this->connexion = new PDO('sqlsrv:Server='.$this->PARAM_hote.';Database='.$this->PARAM_nom_bd, $this->PARAM_utilisateur, $this->PARAM_mot_passe,array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));
    	}
    	catch (PDOException $e)
    	{
    		echo 'hote: '.$this->PARAM_hote.' '.$_SERVER['DOCUMENT_ROOT'].'<br />';
    		echo 'Erreur : '.$e->getMessage().'<br />';
    		echo 'N° : '.$e->getCode();
    		$this->connexion=false;
    		//echo '<script>alert ("pbs acces bdd");</script>)';
    	}
    }
    public function __get($propriete) {
    	switch ($propriete) {
    		case 'connexion' :
    			{
    				return $this->connexion;
    				break;
    			}
    	}
    }

    public function connect($tab)
        {
			$tab["id"] = str_replace("%40","@",$tab["id"]);
        	$requete="SELECT TOP 1 * FROM utilisateur WHERE login='".$tab["id"]."' AND password='".MD5($tab["mp"])."' AND code_role_web=".$tab["categ"].";";
			$result=$this->connexion->query($requete);

        	if ($result)
        	{
        		return $result;
        	}
        	return null;
		}
		
	public function liste_texte_loi() {
		$requete='select t.id,t.titre_txt,t.vote_final_txt FROM texte t';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
		  return null;
	}

	public function liste_amendements() {
		$requete='select am.code_seq_amend,am.lib_amend,am.date_amend,a.titre_art FROM amendement am,article a 
		WHERE am.code_seq_art = a.code_seq_art';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
      	return null;
	}

	public function liste_sujet_forum() {
		$requete='SELECT id, auteur, titre, date_derniere_reponse FROM forum_sujets ORDER BY date_derniere_reponse DESC';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{
      		return $result;
     	}
      	return null;
	}

}
?>
