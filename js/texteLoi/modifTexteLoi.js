function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $("#modiftexte").submit(function (e) {
    e.preventDefault();

    var myselectInsti = document.getElementById("liste_insti");

    var $url = "./ajax/texteLoi/valide_texte.php";

    var formData = {
      titre: $("#h3").val(),
      id_insti: myselectInsti.options[myselectInsti.selectedIndex].value,
      id_texte: $("[name=code_txt]").val(),
      vote_final_txt: $("#liste_vote_final_txt option:selected").text(),
      promulgation_txt: $("#liste_promulgation_txt option:selected").text();
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

function modif_texte(id) {
  $.ajax({
    type: "POST",
    url: "ajax/texteLoi/recherche_info_texte.php",
    dataType: "json",
    encode: true,
    data: "id_texte=" + id, // on envoie via post l’id
    success: function (retour) {
      /* Anti Duplication Input Hidden */
    $("input").each(function (index) {
      if ($(this).is("[type=hidden]") == true) {
        $(this).remove();
      }
    });
      $("#modiftexte").show();

      $("#h3").val(retour["titre"]);
      $("#liste_insti").val(retour["code_insti"]);
      $("#liste_vote_final_txt").val(retour["vote_final_txt"]);
      $("#liste_promulgation_txt").val(retour["promulgation_txt"]);
      $("#modiftexte").append(
        '<input type="hidden" name="code_txt" value="' + id + '"/>'
      );
      $([document.documentElement, document.body]).animate(
        {
          scrollTop: $("#modiftexte").offset().top,
        },
        500
      );
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

function suppr_texte(id) {
  if (confirm("Voulez-vous supprimer ce Texte ?")) {
    alert("Ce texte a été supprimé");
    $.ajax({
      type: "POST",
      url: "ajax/texteLoi/supprime_texte.php",
      dataType: "json",
      encode: true,
      data: "id_texte=" + id, // on envoie via post l’id
      success: function (retour) {
        document.location.reload(true);
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
}
