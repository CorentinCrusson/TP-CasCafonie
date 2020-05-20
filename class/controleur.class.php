<?php
class controleur {

		private $vpdo;
		private $db;
		public function __construct() {
			$this->vpdo = new mypdo ();
			$this->db = $this->vpdo->connexion;
		}
		public function __get($propriete) {
			switch ($propriete) {
				case 'vpdo' :
					{
						return $this->vpdo;
						break;
					}
				case 'db' :
					{

						return $this->db;
						break;
					}
			}
		}

	/* ----------------------
	--- Rubrique "Accueil" ---
	------------------------ */

	/* - Carousel - */
	public function retourne_actualites()
	{
		$retour='';
		$retour = $retour.'<div class="actualites"> <h3> Actualités </h3><div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
		
	    <ol class="carousel-indicators">
	    <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
	    <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
	    <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
	    </ol>
	    <div class="carousel-inner">
			<div class="carousel-item active">
				<img class="d-block w-100" src="https://urlz.fr/cFXz">
				<div class="carousel-caption d-none d-md-block">
					<h5>Le Coronavirus fait ravage</h5>
					<p>Étant en plein période pédimie nous prenons des mesures .. </p>
				</div>
			</div>
			<div class="carousel-item">
				<img class="d-block w-100" src="https://urlz.fr/cFXn">
				<div class="carousel-caption d-none d-md-block">
					<h5>L\'État actuel de notre déconfinement </h5>
					<p>Nous prenons les précautions nécessaires .. </p>
				</div>
			</div>
			<div class="carousel-item">
				<img class="d-block w-100" src="https://urlz.fr/cFXx">
				<div class="carousel-caption d-none d-md-block">
					<h5>L\'Écologie doit être maintenu</h5>
					<p>Nous mettons en place des moyens drastiques afin d\'apporter des nouvelles choses à l\'environnement </p>
				</div>
			</div>
			</div>
	    <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
	    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
	    <span class="sr-only">Previous</span>
	    </a>
	    <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
	    <span class="carousel-control-next-icon" aria-hidden="true"></span>
	    <span class="sr-only">Next</span>
	    </a>
	    </div></div>';
        return $retour;
	}

	/* - Photo Monarque - */
	public function retourne_monarque() {
		$retour='';
		$retour = $retour.'<div class="monarque border"> <h3> Le Monarque </h3>
		<div class="container">
		<img src="image/monarque_avatar.jpg" alt="Le Monarque" class="imageMonarque">
		<div class="overlay">
			<div class="textMonarque"> Notre grand monarque règne sur ce pays .. accompagnée de son institution égalitaire et sans bavure </div>
		</div>
	    </div>';
        return $retour;
	}

	/*  -------------------------
	--------- DATATABLES --------
	--------------------------- */

	/* - DataTable Textes Loi - */

	public function retourne_textes_loi() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="texteLoiTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th>Numéro Texte</th>
            		<th>Titre</th>
					<th>Vote</th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_texte_loi();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_txt.'</td>
							<td>'.$row->titre_txt.'</td>
							<td>'.$row->vote_final_txt.'</td>
							</tr>';
					}

			}		

		$retour = $retour.'</tbody>
		</table>
		</div>';
        return $retour;
	}

	/* - DataTable Articles - */

	public function retourne_articles() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="articleTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th>Numéro Amendement</th>
					<th>Titre</th>					
					<th> Titre Article </th>
					<th>Date</th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_amendements();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_seq_amend.'</td>
							<td>'.$row->lib_amend.'</td>
							<td>'.$row->date_amend.'</td>
							<td>'.$row->titre_art.'</td>
							</tr>';
					}

		} else {
			$retour. '<tr class="odd">
			<td valign="top" colspan="3" class="dataTables_empty">
				Aucune donnée n\'a été importée
			</td>
			</tr>';
		}
	}

	/* - DataTable Amendements - */

	public function retourne_amendements() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="amendementTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th>Numéro Amendement</th>
					<th>Titre</th>					
					<th> Titre Article </th>
					<th>Date</th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_amendements();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_seq_amend.'</td>
							<td>'.$row->lib_amend.'</td>
							<td>'.$row->date_amend.'</td>
							<td>'.$row->titre_art.'</td>
							</tr>';
					}

		} else {
			$retour. '<tr class="odd">
			<td valign="top" colspan="3" class="dataTables_empty">
				Aucune donnée n\'a été importée
			</td>
			</tr>';
		}		

		$retour = $retour.'</tbody>
		</table>
		</div>';
        return $retour;
	}

	/* - DataTable Votes - */

	public function retourne_votes() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="voteTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th>Numéro Amendement</th>
					<th>Titre</th>					
					<th> Titre Article </th>
					<th>Date</th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_amendements();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_seq_amend.'</td>
							<td>'.$row->lib_amend.'</td>
							<td>'.$row->date_amend.'</td>
							<td>'.$row->titre_art.'</td>
							</tr>';
					}

		} else {
			$retour. '<tr class="odd">
			<td valign="top" colspan="3" class="dataTables_empty">
				Aucune donnée n\'a été importée
			</td>
			</tr>';
		}		

		$retour = $retour.'</tbody>
		</table>
		</div>';
        return $retour;
	}

	/* ------------------------------------
	--- Rubrique " Nous Connaître " ---
	------------------------------------ */

	public function retourne_nousconnaitre() {
		$retour='';
		$retour = $retour.'<div class="nousConnaitre"> <h3> Nous Connaitre </h3>
		<p> <b> L\'État de Cafonie</b> est un pays de 20 habitants et oui ça en fait du monde ! </p>
		<img src="image/image_pays"/>
		
	    </div>';
        return $retour;
	}

	/* ------------------------------------
	--- Rubrique " Espace Membre " ---
	------------------------------------ */

	public function retourne_formulaire_login() {
		$retour = '
				<div class="modal fade" id="myModal" role="dialog" style="color:#000;">
					<div class="modal-dialog">
						<div class="modal-content">
							<div class="modal-header">
								<h4 class="modal-title"><span class="fas fa-lock"></span> Formulaire de connexion</h4>
								<button type="button" class="close" data-dismiss="modal" aria-label="Close" ">
									  <span aria-hidden="true">&times;</span>
								</button>
							  </div>
							<div class="modal-body">
								<form role="form" id="login" method="post">
									<div class="form-group">
										<label for="id"><span class="fas fa-user"></span> Adresse Mail </label>
										<input type="email" class="form-control" id="id" name="id" placeholder="xxx@gouv.fr">
									</div>
									<div class="form-group">
										<label for="mp"><span class="fas fa-eye"></span> Mot de passe</label>
										<input type="password" class="form-control" id="mp" name="mp" placeholder="Mot de passe">
									</div>
									<div class="form-group">
										<label class="radio-inline"><input type="radio" name="rblogin" id="rbj" value="rbj">Secrétaire d\'État</label>
										<label class="radio-inline"><input type="radio" name="rblogin" id="rbr" value="rbr">Greffier</label>
										<label class="radio-inline"><input type="radio" name="rblogin" id="rba" value="rba">Modérateur</label>
										<label class="radio-inline"><input type="radio" name="rblogin" id="rbo" value="rba">Monarque</label>
									</div>
									<button type="submit" class="btn btn-success btn-block" class="submit"><span class="fas fa-power-off"></span> Login</button>
								</form>
							</div>
							<div class="modal-footer">
								<button type="button"  class="btn btn-danger btn-default pull-left" data-dismiss="modal" ><span class="fas fa-times"></span> Cancel</button>
							</div>
						</div>
					</div>
				</div>';
	
				return $retour;
	}

	/* ------------------------------------------
	--- Function pour retourner un Message Modal ---
	-------------------------------------------- */

	public function retourne_modal_message()
	{
		$retour='
		<div class="modal fade" id="ModalRetour" role="dialog" style="color:#000;">
			<div class="modal-dialog">
				<div class="modal-content">
				<div class="modal-header">
        				<h4 class="modal-title"><span class="fas fa-info-circle"></span> INFORMATIONS</h4>
        				<button type="button" class="close" data-dismiss="modal" aria-label="Close" onclick="hd();">
          					<span aria-hidden="true">&times;</span>
        				</button>
      				</div>
		       		<div class="modal-body">
						<div class="alert alert-info">
							<p></p>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" onclick="hdModalRetour();" >Close</button>
					</div>
				</div>
			</div>
		</div>
		';
		return $retour;
	}

	/* ------------------------------------
	---- Formulaires Créér / Modifier ----
	------------------------------------ */

	/* - Formulaire Texte de Loi - */

	public function retourne_formulaire_texte($action)
	{

		$retour=  '
		<form style='.$action[0].' role="form" id="'.$action[1].'" method="post"><h3>'.$action[2].'</h3>
			<div class="form-group">
				<label for="id"> Titre</label>
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Titre">
			</div>

			<button type="submit" class="btn btn-success btn-default"><span class="fas fa-power-off"></span>'.$action[3].'</button>
			<button type="button" class="btn btn-danger btn-default pull-left" ><span class="fas fa-times"></span> Cancel</button>
		</form>';
		return $retour;

	}

	/* - Formulaire Articles - */

	public function retourne_formulaire_article($action)
	{

		$retour=  '
		<form style='.$action[0].' role="form" id="'.$action[1].'" method="post"><h3>'.$action[2].'</h3>
			<div class="form-group">
				<label for="id"> Titre</label>
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Titre">
			</div>
			<div class="form-group">
				<label for="corps"> Article </label>
				<textarea class="form-control" rows="5" id="corps" name="corps" placeholder="Corps article"></textarea>
			</div>
			<div class="form-group">
				<label for="idRef"> Référence </label>
				<SELECT id="liste_txt" onChange="" >
				'.$this->affiche_combo_texte().'
				</SELECT>
			</div>

			<button type="submit" class="btn btn-success btn-default"><span class="fas fa-power-off"></span>'.$action[3].'</button>
			<button type="button"" class="btn btn-danger btn-default pull-left" ><span class="fas fa-times"></span> Cancel</button>
		</form>';
		return $retour;

	}

	/* - Formulaire Amendements - */

	public function retourne_formulaire_amendement($action)
	{

		$retour=  '
		<form style='.$action[0].' role="form" id="'.$action[1].'" method="post"><h3>'.$action[2].'</h3>
			<div class="form-group">
				<label for="id"> Libellé </label>
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Libellé">
			</div>
			<div class="form-group">
				<label for="corps"> Amendement </label>
				<textarea class="form-control" rows="5" id="corps" name="corps" placeholder="Corps Amendement"></textarea>
			</div>
			<div class="form-group">
				<label for="dateAmend"> Date Amendement </label>
				<input type="text" class="form-control" id="date_amend" name="date_amend" placeholder="Date Amendement">
			</div>
			<div class="form-group">
				<label for="idRef"> Référence </label>
				<SELECT id="liste_txt" onChange="js_change_texte()" >
				'.$this->affiche_combo_texte().'
				</SELECT>
				'.$this->affiche_combo_article().'
			</div>

			<button type="submit" class="btn btn-success btn-default"><span class="fas fa-power-off"></span>'.$action[3].'</button>
			<button type="button"" class="btn btn-danger btn-default pull-left" ><span class="fas fa-times"></span> Cancel</button>
		</form>';
		return $retour;

	}

	/* - Formulaire Votes - */

	public function retourne_formulaire_vote($action)
	{

		$retour=  '
		<form style='.$action[0].' role="form" id="'.$action[1].'" method="post"><h3>'.$action[2].'</h3>
			<div class="form-group">
				<label for="id"> Titre</label>
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Titre">
			</div>
			<div class="form-group">
				<label for="corps"> Article </label>
				<textarea class="form-control" rows="5" id="corps" name="corps" placeholder="Corps article"></textarea>
			</div>
			<div class="form-group">
				<label for="idRef"> Référence </label>
				<SELECT id="liste_txt" onChange="js_change_texte()" >
				'.$this->affiche_combo_texte().'
				</SELECT>
				'.$this->affiche_combo_article().'
			</div>

			<button type="submit" class="btn btn-success btn-default"><span class="fas fa-power-off"></span>'.$action[3].'</button>
			<button type="button"" class="btn btn-danger btn-default pull-left" ><span class="fas fa-times"></span> Cancel</button>
		</form>';
		return $retour;

	}

	/* -------------------------------------------
	-------------- COMBO BOX ----------------------
	--------------------------------------------- */

	/* - Combo Box Texte - */
	public function affiche_combo_texte(){

		$retour = '';

		//Combo Box Departement
		$result = $this->vpdo->liste_texte_loi();
		if ($result != false) {
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
				 {
						 $retour = $retour."<OPTION value='$row->code_txt'>$row->titre_txt</OPTION>";
				}

		}
		
		return $retour;
	}

	/* - Combo Box Article - */
	public function affiche_combo_article(){

		$retour = '<SELECT id="liste_art" style="display: none" onChange="js_change_art()" >';

		$retour = $retour.'</SELECT>';
		return $retour;
	}

	/* -------------------------------------------
	--- Rubrique Caché " Vote " renvoyant du Json ---
	--------------------------------------------- */

	public function retourne_stats_vote()
	{
		$retour = array();

		$result = $this->vpdo->liste_vote_par_article();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
						$retour2 = array(
							"code_art" => $row->code_seq_art,
							"nbr_voix_pour" => $row->nbr_voix_pour,
							"nbr_voix_contre" => $row->nbr_voix_contre
						);
						
						array_push($retour,$retour2);
					}
		}

		echo json_encode($retour);
	}

	/* - Génération de Mot de Passe - */

	public function genererMDP ($longueur = 8){
		// initialiser la variable $mdp
		$mdp = "";

		// Définir tout les caractères possibles dans le mot de passe,
		// Il est possible de rajouter des voyelles ou bien des caractères spéciaux
		$possible = "2346789bcdfghjkmnpqrtvwxyzBCDFGHJKLMNPQRTVWXYZ&#@$*!";

		// obtenir le nombre de caractères dans la chaîne précédente
		// cette valeur sera utilisé plus tard
		$longueurMax = strlen($possible);

		if ($longueur > $longueurMax) {
			$longueur = $longueurMax;
		}

		// initialiser le compteur
		$i = 0;

		// ajouter un caractère aléatoire à $mdp jusqu'à ce que $longueur soit atteint
		while ($i < $longueur) {
			// prendre un caractère aléatoire
			$caractere = substr($possible, mt_rand(0, $longueurMax-1), 1);

			// vérifier si le caractère est déjà utilisé dans $mdp
			if (!strstr($mdp, $caractere)) {
				// Si non, ajouter le caractère à $mdp et augmenter le compteur
				$mdp .= $caractere;
				$i++;
			}
		}

		// retourner le résultat final
		return $mdp;
	}


}

?>
