function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $.datepicker.setDefaults($.datepicker.regional["fr"]);

  $("#jour_vote").datepicker(
    { changeYear: true, dateFormat: "yy-mm-dd" },
    "setDate",
    $("#jour_vote").val()
  );

  $("#modifvote").submit(function (e) {
    e.preventDefault();

    var myselectTexte = document.getElementById("liste_txt");
    var myselectArticle = document.getElementById("liste_art");
    var myselectOrgane = document.getElementById("liste_org");

    var $url = "./ajax/vote/valide_vote.php";

    var formData = {
      jour_vote: $("#jour_vote").val(),
      nbr_voix_pour: $("#nbr_voix_pour").val(),
      nbr_voix_contre: $("#nbr_voix_contre").val(),
      id_txt: myselectTexte.options[myselectTexte.selectedIndex].value,
      id_art: myselectArticle.options[myselectArticle.selectedIndex].value,
      id_org: myselectOrgane.options[myselectOrgane.selectedIndex].value,
    };
    var filterDataRequest = $.ajax({
      type: "POST",
      url: $url,
      dataType: "json",
      encode: true,
      data: formData,
    });
    filterDataRequest.done(function (data) {
      if (!data.success) {
        var $msg =
          'erreur-></br><ul style="list-style-type :decimal;padding:0 5%;">';
        if (data.errors.message) {
          $x = data.errors.message;
          $msg += "<li>";
          $msg += $x;
          $msg += "</li>";
        }
        if (data.errors.requete) {
          $x = data.errors.requete;
          $msg += "<li>";
          $msg += $x;
          $msg += "</li>";
        }

        $msg += "</ul>";
      } else {
        $msg = "";
        if (data.message) {
          $msg += "</br>";
          $x = data.message;
          $msg += $x;
        }
      }

      $("#ModalRetour").find("p").html($msg);
      $("#ModalRetour").modal();
    });
    filterDataRequest.fail(function (jqXHR, textStatus) {
      if (jqXHR.status === 0) {
        alert("Not connect.n Verify Network.");
      } else if (jqXHR.status == 404) {
        alert("Requested page not found. [404]");
      } else if (jqXHR.status == 500) {
        alert("Internal Server Error [500].");
      } else if (textStatus === "parsererror") {
        alert("Requested JSON parse failed.");
      } else if (textStatus === "timeout") {
        alert("Time out error.");
      } else if (textStatus === "abort") {
        alert("Ajax request aborted.");
      } else {
        alert("Uncaught Error.n" + jqXHR.responseText);
      }
    });
  });
});

function modif_vote(id) {
  $.ajax({
    type: "POST",
    url: "ajax/recherche_info_article.php",
    dataType: "json",
    encode: true,
    data: "id_article=" + id, // on envoie via post l’id
    success: function (retour) {
      $("#modifarticle").show();

      $("#h3").val(retour["h3"]);
      $("#date_deb").val(retour["date_deb"]);
      $("#date_fin").val(retour["date_fin"]);
      $("#corps").val(retour["corps"]);
      CKEDITOR.instances["corps"].setData(retour["corps"]);
    },
    error: function (jqXHR, textStatus) {
      // traitement des erreurs ajax
      if (jqXHR.status === 0) {
        alert("Not connect.n Verify Network.");
      } else if (jqXHR.status == 404) {
        alert("Requested page not found. [404]");
      } else if (jqXHR.status == 500) {
        alert("Internal Server Error [500].");
      } else if (textStatus === "parsererror") {
        alert("Requested JSON parse failed.");
      } else if (textStatus === "timeout") {
        alert("Time out error.");
      } else if (textStatus === "abort") {
        alert("Ajax request aborted.");
      } else {
        alert("Uncaught Error.n" + jqXHR.responseText);
      }
    },
  });
}

function suppr_vote(id_texte, id_article, id_organe, jour_vote) {
  var $url = "ajax/vote/supprime_vote.php";
  var formData = {
    id_texte: id_texte,
    id_article: id_article,
    id_organe: id_organe,
    jour_vote: jour_vote,
  };

  if (confirm("Voulez-vous supprimer ce Vote ?")) {
    alert("Ce vote a été supprimé");
    var filterDataRequest = $.ajax({
      type: "POST",
      url: $url,
      dataType: "json",
      encode: true,
      data: formData,
    });
    filterDataRequest.done(function (data) {
      document.location.reload(true);
    });
    filterDataRequest.fail(function (jqXHR, textStatus) {
      // traitement des erreurs ajax
      if (jqXHR.status === 0) {
        alert("Not connect.n Verify Network.");
      } else if (jqXHR.status == 404) {
        alert("Requested page not found. [404]");
      } else if (jqXHR.status == 500) {
        alert("Internal Server Error [500].");
      } else if (textStatus === "parsererror") {
        alert("Requested JSON parse failed.");
      } else if (textStatus === "timeout") {
        alert("Time out error.");
      } else if (textStatus === "abort") {
        alert("Ajax request aborted.");
      } else {
        alert("Uncaught Error.n" + jqXHR.responseText);
      }
    });
  }
}
