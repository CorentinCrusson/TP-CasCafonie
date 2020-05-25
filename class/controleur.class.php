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

	public function retourne_test() {
		$tab;
		$tab['id'] = 'corentincrusson@gmail.com';
		$tab['mp'] = 'admin';
		$tab['categ'] = '3';
		$result = $this->vpdo->connect($tab);
		var_dump($result);
	}

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

	/* ------------------------
	------- Affichage ---------
	--------------------------
	*/

	public function retourne_affichage_texte()
	{
		$retour='<section id="affichageTexteLoi">';
		$max = 300;		
		$nb = 0;
		$result = $this->vpdo->liste_texte_loi_sous_forme_article();
		if ($result != false) {
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
			// parcourir chaque ligne sélectionnée
			{
				
				$resultArticle = $this->vpdo->trouve_toutes_les_articles_via_un_texte($row->code_txt);
				$rowArticle = $resultArticle->fetch ( PDO::FETCH_OBJ );

				$corps = '';

				$nb +=1;
				if($rowArticle!=null)
				{
					$corps = $rowArticle->texte_art;
				}
				
				$corps = substr($corps,0,$max);

				$retour = $retour . '
				<div class="card bg-secondary text-white m-2" >
				<div class="card-body">
					<article>
						<h3 class="card-title">'.$row->titre_txt.'</h3> 
						<div id="summary">
							'.$corps.'
						</div>
						<button class="btn btn-light" type="button" onclick="afficheTexte('.$row->code_txt.')"> Voir le Texte</button>
						<p class="card-text"><i> ';
						if($rowArticle!=null)
						{
							$retour = $retour . $rowArticle->titre_art;
						}
						$retour = $retour .', État Texte : '.$row->vote_final_txt.'</i></p>
					</article>
				</div>
			</div>';
			}
		}
		$retour = $retour .'</section>';
		return $retour;
	}

	public function retourne_affiche_un_texte()
	{
		$retour='<section id="affichageUnTexteLoi" style="display: none;">
		<h3 id="titreTexte"></h3>		 
		<button class="btn btn-secondary" type="button" onClick="retour()"> <- Revenir aux Textes de Loi </button>
		<div id="articleDiv">
		</div>';

		$retour = $retour .'</section>';
		return $retour;
	}

	public function retourne_affichage_amendement()
	{
		$retour='<section id="affichageAmendement">';
		$max = 300;		
		$nb = 0;
		$result = $this->vpdo->liste_amendements();
		if ($result != false) {
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
			// parcourir chaque ligne sélectionnée
			{
				$nb +=1;
				$corps = $row->texte_amend;

				$retour = $retour . '
				<div class="card bg-secondary text-white m-2" >
				<div class="card-body">
					<article>
						<h3 class="card-title">'.$row->lib_amend.'</h3> 
						'.$corps.'
						<p class="card-text"><i> Écrit le '.$row->date_amend.'</i></p>
					</article>
				</div>
			</div>';
			}
		}
		
		$retour = $retour .'</section>';
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
					<th> Voté </th>
					<th> Promulgé </th>
					<th>  </th>
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
							<td>'.$row->promulgation_txt.'</td>
							<td style="text-align: center;"><button type="button" class="btn btn-primary btn-default pull-center"
							value="Modifier" onclick="modif_texte('.$row->code_txt.');">
							<span class="fas fa-edit"></span>
							</button> </td>
							<td style="text-align: center;"><button type="button" class="btn btn-danger btn-default pull-center"
							value="Modifier" onclick="suppr_texte('.$row->code_txt.');">
							<span class="fas fa-trash"></span>
							</button> </td>
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
            		<th>Numéro Article</th>
					<th>Titre</th>				
					<th> Titre Texte Référent </th>
					<th> </th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_articles();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_seq_art.'</td>
							<td>'.$row->titre_art.'</td>
							<td>'.$row->titre_txt.'</td>
							<td style="text-align: center;"><button type="button" class="btn btn-primary btn-default pull-center"
							value="Modifier" onclick="modif_article('.$row->code_seq_art.');">
							<span class="fas fa-edit"></span>
							</button> </td>
							<td style="text-align: center;"><button type="button" class="btn btn-danger btn-default pull-center"
							value="Modifier" onclick="suppr_article('.$row->code_seq_art.');">
							<span class="fas fa-trash"></span>
							</button> </td>
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

	/* - DataTable Amendements - */

	public function retourne_amendements() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="amendementTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th>Numéro Amendement</th>
					<th> Titre</th>					
					<th> Titre Article Référent </th>
					<th> Titre Texte Référent </th>
					<th>Date</th>
					<th> </th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_amendements();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
							$retour = $retour.'<tr>
							<td>'.$row->code_seq_amend.'</td>
							<td>'.$row->lib_amend.'</td>
							<td>'.$row->titre_art.'</td>
							<td>'.$row->titre_txt.'</td>
							<td>'.$row->date_amend.'</td>
							<td style="text-align: center;"><button type="button" class="btn btn-primary btn-default pull-center"
							value="Modifier" onclick="modif_amendement('.$row->code_seq_amend.');">
							<span class="fas fa-edit"></span>
							</button> </td>
							<td style="text-align: center;"><button type="button" class="btn btn-danger btn-default pull-center"
							value="Modifier" onclick="suppr_amendement('.$row->code_seq_amend.');">
							<span class="fas fa-trash"></span>
							</button> </td>

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
            		<th>Titre Texte </th>
					<th>Titre Article </th>	
					<th> Date Vote </th>
					<th> Organe Votant </th>
					<th> Nombre Voix Pour </th>
					<th> Nombre Voix Contre </th>
					<th> </th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_votes();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
						$jour_vote = "'".$row->jour_vote."'";
							$retour = $retour.'<tr>
							<td>'.$row->titre_txt.'</td>
							<td>'.$row->titre_art.'</td>
							<td>'.$row->jour_vote.'</td>
							<td>'.$row->lib_organe.'</td>
							<td>'.$row->nbr_voix_pour.'</td>
							<td>'.$row->nbr_voix_contre.'</td>
							<td style="text-align: center;"><button type="button" class="btn btn-primary btn-default pull-center"
							value="Modifier" onclick="modif_vote('.$row->code_txt.','.$row->code_seq_art.','.$row->code_organe.', '.$jour_vote.');">
							<span class="fas fa-edit"></span>
							</button> </td>
							<td style="text-align: center;"><button type="button" class="btn btn-danger btn-default pull-center"
							value="Modifier" onclick="suppr_vote('.$row->code_txt.','.$row->code_seq_art.','.$row->code_organe.', '.$jour_vote.');">
							<span class="fas fa-trash"></span>
							</button> </td>

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

	/* - DataTable Institutions - */

	public function retourne_institutions() {
		$retour = '';
	    $retour = $retour.'<div class="table-responsive">
	    <table id="institutionTable" class="table table-striped table-bordered" cellspacing="0" >
            <thead>
            	<tr>
            		<th> Nom Institution </th>
					<th> Type Institution </th>	
					<th> </th>
					<th> </th>
            	</tr>  </thead> <tbody>';
		 $result = $this->vpdo->liste_institutions();
		 if ($result != false) {
			 while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
					{
						$lib_type_insti = 'Aucun';
						if($row->code_type_insti != null)
						{							
							$result2 = $this->vpdo->trouve_typeinstitution_via_id($row->code_type_insti);
							$rowTypeInsti = $result2->fetch ( PDO::FETCH_OBJ );
							$lib_type_insti = $rowTypeInsti->lib_type_insti;
						}
						$retour = $retour.'<tr>
						<td>'.$row->nom_insti.'</td> 
						<td>'.$lib_type_insti.'</td>
						<td style="text-align: center;"><button type="button" class="btn btn-primary btn-default pull-center"
						value="Modifier" onclick="modif_institution('.$row->code_insti.');">
						<span class="fas fa-edit"></span>
						</button> </td>
						<td style="text-align: center;"><button type="button" class="btn btn-danger btn-default pull-center"
						value="Modifier" onclick="suppr_institution('.$row->code_insti.');">
						<span class="fas fa-trash"></span>
						</button> </td>

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
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Titre" required>
			</div>
			<div class="form-group">
				<label for="idInsti"> Référence Institution </label>
				<SELECT id="liste_insti" class="form-control" required>
				'.$this->affiche_combo_insti().'
				</SELECT>
			</div>
			<div class="form-group">
				<label for="vote_final"> Vote Final ( Si le texte n\'est pas voté, ne pas remplir ) </label>
				<SELECT id="liste_vote_final_txt" class="form-control">
					<option value=""> Choisir Ici </option>
					<option value="OUI" > OUI </option>
					<option value="EN COURS" > EN COURS </option>
					<option value="NON" > NON </option>
				</SELECT>
			</div>
			<div class="form-group">
				<label for="promulgation"> Promulgation ( Si le texte n\'est pas promulgé, ne pas remplir )</label>
				<SELECT id="liste_promulgation_txt" class="form-control">
				<option value=""> Choisir Ici </option>
				<option value="ACCEPTE" > ACCEPTE </option>
				<option value="EN COURS" > EN COURS </option>
				<option value="REFUSE" > REFUSE </option>
				</SELECT>
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
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Titre" required>
			</div>
			<div class="form-group">
				<label for="corps"> Article </label>
				<textarea class="form-control" rows="5" id="corps" name="corps" placeholder="Corps article" required></textarea>
			</div>
			<div class="form-group">
				<label for="idRef"> Référence </label>
				<SELECT id="liste_txt" class="form-control" onChange="" required>
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
				<SELECT id="liste_txt" class="form-control" onChange="js_change_texte()" required>
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
				<label for="idRef"> Référence </label>
				<SELECT id="liste_txt" class="form-control" onChange="js_change_texte()" required>
				'.$this->affiche_combo_texte().'
				</SELECT>
				'.$this->affiche_combo_article().'
			</div>
			<div class="form-group">
				<label for="idOrg"> Organe Votant </label>
				<SELECT id="liste_org" class="form-control" required>
				'.$this->affiche_combo_organe().'
				</SELECT>
			</div>
			<div class="form-group">
				<label for="id"> Nombre Voix Pour </label>
				<input type="number" class="form-control" id="nbr_voix_pour" name="nbr_voix_pour" min="0" max="500" placeholder="0" required>
			</div>
			<div class="form-group">
				<label for="id"> Nombre Voix Contre </label>
				<input type="number" class="form-control" id="nbr_voix_contre" name="nbr_voix_contre" min="0" max="500" placeholder="0" required>
			</div>
			<div class="form-group">
				<label for="dateVote"> Date du Vote </label>
				<input type="text" class="form-control" id="jour_vote" name="jour_vote" placeholder="Date du Vote" required>
			</div>

			<button type="submit" class="btn btn-success btn-default"><span class="fas fa-power-off"></span>'.$action[3].'</button>
			<button type="button"" class="btn btn-danger btn-default pull-left" ><span class="fas fa-times"></span> Cancel</button>
		</form>';
		return $retour;

	}

	/* - Formulaire Institution - */

	public function retourne_formulaire_institution($action)
	{

		$retour=  '
		<form style='.$action[0].' role="form" id="'.$action[1].'" method="post"><h3>'.$action[2].'</h3>
			
			<div class="form-group">
			<label for="id"> Titre</label>
				<input type="text" class="form-control" id="h3" name="h3" placeholder="Nom Institution" required>
			</div>
			<div class="form-group">
				<label for="idTypeInsti"> Type Institution </label>
				<SELECT id="liste_type_insti" class="form-control" required>
				'.$this->affiche_combo_typeinsti().'
				</SELECT>
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
			$retour = $retour.'<option value=""> Choisir Ici</option>';
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
				 {
						 $retour = $retour."<OPTION value='$row->code_txt'>$row->titre_txt</OPTION>";
				}

		}
		
		return $retour;
	}

	/* - Combo Box Article - */
	public function affiche_combo_article(){

		$retour = '<SELECT id="liste_art" class="form-control" style="display: none" onChange="js_change_art()" > <option value=""> Choisir Ici</option>';

		$retour = $retour.'</SELECT>';
		return $retour;
	}

	/* - Combo Box Organe - */
	public function affiche_combo_organe(){

		$retour = '';

		//Combo Box Departement
		$result = $this->vpdo->liste_organes();
		if ($result != false) {
			$retour = $retour.'<option value=""> Choisir Ici</option>';
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
				 {
						 $retour = $retour."<OPTION value='$row->code_organe'>$row->lib_organe</OPTION>";
				}

		}
		
		return $retour;
	}

	/* - Combo Box Institution - */
	public function affiche_combo_insti(){

		$retour = '';

		//Combo Box Departement
		$result = $this->vpdo->liste_institutions();
		if ($result != false) {
			$retour = $retour.'<option value=""> Choisir Ici</option>';
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
				{
					$retour = $retour."<OPTION value='$row->code_insti'>$row->nom_insti</OPTION>";
				}

		}
		
		return $retour;
	}

	/* - Combo Box TypeInstitution - */
	public function affiche_combo_typeinsti(){

		$retour = '';

		//Combo Box Departement
		$result = $this->vpdo->liste_typeinstitution();
		if ($result != false) {
			$retour = $retour.'<option value=""> Choisir Ici</option>';
			while ( $row = $result->fetch ( PDO::FETCH_OBJ ) )
				 {
						 $retour = $retour."<OPTION value='$row->code_type_insti'>$row->lib_type_insti</OPTION>";
				}

		}
		
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

	/* ----------------------------------
	-------------- FORUM --------------------
	------------------------------------- */

	public function retourne_sujet_forum(){
		$retour = '';

		$retour = $retour.' <h3> Petit Easter Egg pour les Développeurs</h3>
		<br>
		<h5> Je n\'ai pas eu le temps de faire le forum, pour vous consoler voici une petite photo </h5>
		<img class="border circle" src="image/photo_2.jpg" height="400"/>
		<p> <i>Soyez gentil en remplissant mon livret </i> </p>';

		return $retour;
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
