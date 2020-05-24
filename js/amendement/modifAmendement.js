function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $.datepicker.setDefaults($.datepicker.regional["fr"]);

  $("#date_amend").datepicker(
    { changeYear: true, dateFormat: "yy-mm-dd" },
    "setDate",
    $("#date_amend").val()
  );
  CKEDITOR.replace("corps");

  $("#modifamendement").submit(function (e) {
    e.preventDefault();

    var $url = "./ajax/amendement/valide_amendement.php";

    var formData = {
      titre: $("#h3").val(),
      corps: CKEDITOR.instances.corps.getData(),
      date_amend: $("#date_amend").val(),
      id_texte: $("#liste_txt option:selected").val(),
      id_article: $("#liste_art option:selected").val(),
      id_amend: $("[name=code_seq_amend]").val(),
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

function modif_amendement(id) {
  $.ajax({
    type: "POST",
    url: "ajax/amendement/recherche_info_amendement.php",
    dataType: "json",
    encode: true,
    data: "id_amend=" + id, // on envoie via post l’id
    success: function (retour) {
      /* Anti Duplication Input Hidden */
      $("input").each(function (index) {
        if ($(this).is("[type=hidden]") == true) {
          $(this).remove();
        }
      });
      $("#modifamendement").show();

      $("#h3").val(retour["titre"]);
      $("#date_amend").val(retour["date_amend"]);
      $("#corps").val(retour["corps"]);
      CKEDITOR.instances["corps"].setData(retour["corps"]);
      $("#liste_txt").val(retour["id_texte"]);
      $("#liste_art").fadeIn();
      $.each(retour, function (index, value) {
        // pour chaque noeud JSON
        // on ajoute l option dans la liste
        if (
          index != "titre" &&
          index != "corps" &&
          index != "date_amend" &&
          index != "id_texte" &&
          index != "id_article"
        ) {
          $("#liste_art").append(
            "<option value=" + index + ">" + value + "</option>"
          );
        }
      });
      $("#liste_art").val(retour["id_article"]);
      $("#modifamendement").append(
        '<input type="hidden" name="code_seq_amend" value="' + id + '"/>'
      );
      $([document.documentElement, document.body]).animate(
        {
          scrollTop: $("#modifamendement").offset().top,
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

function suppr_amendement(id) {
  if (confirm("Voulez-vous supprimer cet Amendement ?")) {
    alert("Cet amendement a été supprimé");
    $.ajax({
      type: "POST",
      url: "ajax/amendement/supprime_amendement.php",
      dataType: "json",
      encode: true,
      data: "id_amend=" + id, // on envoie via post l’id
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
