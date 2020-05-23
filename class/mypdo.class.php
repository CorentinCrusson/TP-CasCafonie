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
	
	/* - Connexion Utilisateur ( Espace Membre ) */

    public function connect($tab)
        {
			$tab["id"] = str_replace("%40","@",$tab["id"]);
			$tab['mp'] = md5($tab['mp']);

        	$requete='SELECT * FROM utilisateur WHERE login='.$this->connexion->quote($tab['id']) .' AND password='.$this->connexion->quote($tab['mp']).' AND code_role_web='.$this->connexion->quote($tab['categ']).';';
			$result=$this->connexion->query($requete);

        	if ($result)
        	{
				if($result->fetchColumn()==1)
				{
					return $result;
				}
        	}
        	return null;
		}

	/* - Texte de Loi - */

	public function create_texte($tab)
	{
		$errors         = array();
	    $data 			= array();
	  
        $requete='INSERT into texte(titre_txt,code_insti) values('
		.$this->connexion ->quote($tab['titre']) .','
		.$this->connexion ->quote($tab['id_insti']).'
		);';

       $nblignes=$this->connexion -> exec($requete);
      if ($nblignes !=1)
      {
        $errors['requete']='Pas de insert de Texte :'.$requete;
      }



      if ( ! empty($errors)) {
        $data['success'] = false;
        $data['errors']  = $errors;
      } else {

        $data['success'] = true;
        $data['message'] = 'Création Texte ok!';
      }
      return $data;
	}

	public function modif_texte()
	{
		$errors         = array();
		$data 			= array();
		
    	$requete='update texte'
    	.'set titre_txt='.$this->connexion ->quote($tab['titre']) .','
    	.'id_insti='.$this->connexion ->quote($tab['id_insti']) .','
 		.' where id='.$tab['id_txt'] .';'; 
		$nblignes=$this->connexion -> exec($requete);
		if ($nblignes !=1)
		{
			$errors['requete']='Pas de modifications de Texte :'.$requete;
		}



    	if ( ! empty($errors)) {
    		$data['success'] = false;
    		$data['errors']  = $errors;
    	} else {

    		$data['success'] = true;
    		$data['message'] = 'Modification Texte ok!';
    	}
    	return $data;
	}
		
	public function liste_texte_loi() {
		$requete='SELECT code_txt,titre_txt,vote_final_txt,promulgation_txt FROM texte';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
		
		 return null;
	}	

	public function liste_texte_loi_sous_forme_article() {
		$requete='SELECT code_txt,titre_txt,vote_final_txt  FROM texte';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
		
		 return null;
	}	

	public function trouve_texte_via_id($id)
	{
		$requete= 'SELECT * FROM texte WHERE code_txt = '.$id;

		$result=$this->connexion->query($requete);
		if ($result)
		{
			return ($result);
		}
		return null;
	}

	/* - Articles - */	

	public function create_article($tab)
	{
	  $errors         = array();
      $data 			= array();
      $corps=utf8_encode($tab['corps']);
        $requete='INSERT into article(code_txt,titre_art,texte_art) values('
        .$this->connexion ->quote($tab['id_txt']) .','
        .$this->connexion ->quote($tab['titre']) .','
		.$this->connexion ->quote($corps) .'
		);';

       $nblignes=$this->connexion -> exec($requete);
      if ($nblignes !=1)
      {
        $errors['requete']='Pas de insert d\'article :'.$requete;
      }



      if ( ! empty($errors)) {
        $data['success'] = false;
        $data['errors']  = $errors;
      } else {

        $data['success'] = true;
        $data['message'] = 'Création article ok!';
      }
      return $data;
	}

	public function liste_articles()
	{
		$requete='SELECT a.code_seq_art, a.titre_art, t.titre_txt FROM article a, texte t WHERE a.code_txt = t.code_txt';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
		
		 return null;
	}

	public function trouve_toutes_les_articles_via_un_texte($id)
	{
		$requete= 'SELECT code_seq_art, titre_art,texte_art FROM article WHERE code_txt = '.$id;

		$result=$this->connexion->query($requete);
		if ($result)
		{
			return ($result);
		}
		return null;
	}

	/* - Amendements - */

	public function create_amendement($tab)
	{
		$errors         = array();
		$data 			= array();
		$corps=utf8_encode($tab['corps']);
			$requete='INSERT into amendement(code_txt,code_seq_art,lib_amend,texte_amend,date_amend) values('
			.$this->connexion ->quote($tab['id_txt']) .','
			.$this->connexion ->quote($tab['id_art']) .','
			.$this->connexion ->quote($tab['titre']) .','
			.$this->connexion ->quote($corps) .','
			.$this->connexion ->quote($tab['date_amend']) .'
			);';

		$nblignes=$this->connexion -> exec($requete);
		if ($nblignes !=1)
		{
			$errors['requete']='Pas de insert d\'amendement :'.$requete;
		}



		if ( ! empty($errors)) {
			$data['success'] = false;
			$data['errors']  = $errors;
		} else {

			$data['success'] = true;
			$data['message'] = 'Création Amendement ok!';
		}
		return $data;
	}

	public function liste_amendements() {
		$requete='SELECT am.code_seq_amend,am.lib_amend,am.date_amend,a.titre_art,am.texte_amend FROM amendement am,article a 
		WHERE am.code_seq_art = a.code_seq_art';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
      	return null;
	}

	/* - Votes - */

	public function create_vote($tab)
	{
		$errors         = array();
		$data 			= array();
		$dateOk = true;

		/* -- On vérifie d'abord si la date donnée existe -- */
		$requete = 'SELECT COUNT(*) from date where jour_vote ='.$tab['jour_vote'];
		$res=$this->connexion->query($requete);
		if ($res->fetchColumn() != 0)
		{	
			/* -- Si NON on insert d'abord la date -- */
			$requete='INSERT INTO date(jour_vote) VALUES ('
				.$this->connexion->quote($tab['jour_vote']).'
				);';

			$nblignes=$this->connexion->exec($requete);
			if ($nblignes !=1)
			{
				$dateOk= false;
				$errors['requete']='Pas de insert de Date :'.$requete.' Lignes : '.strval($aff);
			}
		}

		if($dateOk)
		{
			/* -- On insert après si date OK -- */
			$requete='INSERT into voter(code_organe,jour_vote,code_txt,code_seq_art,nbr_voix_pour,nbr_voix_contre) values('
			.$this->connexion ->quote($tab['id_org']) .','
			.$this->connexion ->quote($tab['jour_vote']) .','
			.$this->connexion ->quote($tab['id_txt']) .','
			.$this->connexion ->quote($tab['id_art']) .','
			.$this->connexion ->quote($tab['nbr_voix_pour']) .','
			.$this->connexion ->quote($tab['nbr_voix_contre']) .'
			);';

			$nblignes=$this->connexion -> exec($requete);
			if ($nblignes !=1)
			{
				$errors['requete']='Pas de insert de Vote :'.$requete;
			}
		}



		if ( ! empty($errors)) {
			$data['success'] = false;
			$data['errors']  = $errors;
		} else {

			$data['success'] = true;
			$data['message'] = 'Création Vote ok!';
		}
		return $data;
	}

	public function modif_vote($tab)
	{
		$errors         = array();
    	$data 			= array();
		$corps=utf8_encode($tab['corps']);
			$requete='update vote '
			.'set code_organe ='.$this->connexion ->quote($tab['titre']) .','
			.'jour_vote='.$this->connexion ->quote($tab['jour_vote']) .','
			.'code_txt='.$this->connexion ->quote($tab['code_txt']) .','
			.'corps='.$this->connexion ->quote($corps)
			.' where id='.$_SESSION['id_article'] .';'; 
		$nblignes=$this->connexion -> exec($requete);
		if ($nblignes !=1)
		{
			$errors['requete']='Pas de modifications de vote :'.$requete;
		}



    	if ( ! empty($errors)) {
    		$data['success'] = false;
    		$data['errors']  = $errors;
    	} else {

    		$data['success'] = true;
    		$data['message'] = 'Modification article ok!';
    	}
    	return $data;
    }

	public function liste_votes()
	{
		$requete='SELECT t.titre_txt,a.titre_art,v.jour_vote,o.lib_organe,v.nbr_voix_pour,v.nbr_voix_contre FROM voter v, texte t, article a,organes o
		WHERE t.code_txt = v.code_txt AND a.code_seq_art = v.code_seq_art AND o.code_organe = v.code_organe';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
		
		 return null;
	}
	
	public function liste_vote_par_article()
	{
		$requete='SELECT DISTINCT code_seq_art,nbr_voix_pour,nbr_voix_contre,jour_vote  FROM voter ORDER BY jour_vote';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{
      		return $result;
     	}
      	return null;
	}

	/* - Organes - */
	public function liste_organes()
	{
		$requete='SELECT code_organe,lib_organe FROM organes';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
      	return null;
	}

	/* - Institutions - */
	public function liste_institutions()
	{
		$requete='SELECT code_insti,nom_insti FROM institution';

      	$result=$this->connexion->query($requete);
      	if ($result)
      	{

      		return $result;
     	}
      	return null;
	}

	/* - Forum - */

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
