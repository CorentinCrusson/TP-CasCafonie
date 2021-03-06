function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $("#modifinstitution").submit(function (e) {
    e.preventDefault();

    var myselectInsti = document.getElementById("liste_insti");

    var $url = "./ajax/institution/valide_institution.php";

    var formData = {
      titre: $("#h3").val(),
      id_type_insti: $("#liste_type_insti option:selected").val(),
      id_insti: $("[name=code_insti]").val(),
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

function modif_institution(id) {
  $.ajax({
    type: "POST",
    url: "ajax/institution/recherche_info_institution.php",
    dataType: "json",
    encode: true,
    data: "id_institution=" + id, // on envoie via post l’id
    success: function (retour) {
      /* Anti Duplication Input Hidden */
      $("input").each(function (index) {
        if ($(this).is("[type=hidden]") == true) {
          $(this).remove();
        }
      });
      $("#modifinstitution").show();

      $("#h3").val(retour["titre"]);
      $("#liste_type_insti").val(retour["code_type_insti"]);

      $("#modifinstitution").append(
        '<input type="hidden" name="code_insti" value="' + id + '"/>'
      );
      $([document.documentElement, document.body]).animate(
        {
          scrollTop: $("#modifinstitution").offset().top,
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

function suppr_institution(id) {
  if (confirm("Voulez-vous supprimer cette Institution ?")) {
    alert("Cette Institution a été supprimé");
    $.ajax({
      type: "POST",
      url: "ajax/institution/supprime_institution.php",
      dataType: "json",
      encode: true,
      data: "id_institution=" + id, // on envoie via post l’id
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
