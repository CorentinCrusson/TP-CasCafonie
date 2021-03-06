function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $("#modifvote").submit(function (e) {
    e.preventDefault();

    var $url = "./ajax/vote/valide_vote.php";

    var formData = {
      id_texte: $("[name=code_texte]").val(),
      id_article: $("[name=code_seq_art]").val(),
      id_organe: $("[name=code_organe]").val(),
      jour_vote: $("[name=jour_vote_input]").val(),
      nbr_voix_pour: $("#nbr_voix_pour").val(),
      nbr_voix_contre: $("#nbr_voix_contre").val(),
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

function modif_vote(id_texte, id_article, id_organe, jour_vote) {
  var $url = "ajax/vote/recherche_info_vote.php";
  var formData = {
    id_texte: id_texte,
    id_article: id_article,
    id_organe: id_organe,
    jour_vote: jour_vote,
  };
  var filterDataRequest = $.ajax({
    type: "POST",
    url: $url,
    dataType: "json",
    encode: true,
    data: formData,
  });
  filterDataRequest.done(function (retour) {
    /* Anti Duplication Input Hidden */
    $("input").each(function (index) {
      if ($(this).is("[type=hidden]") == true) {
        $(this).remove();
      }
    });
    $("#modifvote").show();

    $("#nbr_voix_pour").val(retour["nbr_vote_pour"]);
    $("#nbr_voix_contre").val(retour["nbr_vote_contre"]);

    $("#liste_txt").removeAttr("required");
    $("#liste_art").removeAttr("required");
    $("#liste_txt").parent().hide();
    $("#liste_org").removeAttr("required");
    $("#liste_org").parent().hide();
    $("#jour_vote").removeAttr("required");
    $("#jour_vote").parent().hide();

    //jour_vote = "'" + jour_vote + "'";

    $("#modifvote").append(
      '<input type="hidden" name="code_texte" value="' + id_texte + '"/>'
    );
    $("#modifvote").append(
      '<input type="hidden" name="code_seq_art" value="' + id_article + '"/>'
    );
    $("#modifvote").append(
      '<input type="hidden" name="code_organe" value="' + id_organe + '"/>'
    );

    $("#modifvote").append(
      '<input type="hidden" name="jour_vote_input" value="' + jour_vote + '"/>'
    );
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
