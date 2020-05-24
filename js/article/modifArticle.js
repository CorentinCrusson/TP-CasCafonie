function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  CKEDITOR.replace("corps");

  $("#modifarticle").submit(function (e) {
    e.preventDefault();

    var myselectTexte = document.getElementById("liste_txt");
    var $url = "./ajax/article/valide_article.php";

    var formData = {
      titre: $("#h3").val(),
      corps: CKEDITOR.instances.corps.getData(),
      id_txt: myselectTexte.options[myselectTexte.selectedIndex].value,
      id_article: $("[name=code_article]").val(),
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

function modif_article(id) {
  $.ajax({
    type: "POST",
    url: "ajax/article/recherche_info_article.php",
    dataType: "json",
    encode: true,
    data: "id_article=" + id, // on envoie via post l’id
    success: function (retour) {
      $("#modifarticle").show();

      $("#h3").val(retour["titre"]);
      $("#corps").val(retour["corps"]);
      CKEDITOR.instances["corps"].setData(retour["corps"]);
      $("#liste_txt").val(retour["id_texte"]);
      $("#modifarticle").append(
        '<input type="hidden" name="code_article" value="' + id + '"/>'
      );
      $([document.documentElement, document.body]).animate(
        {
          scrollTop: $("#modifarticle").offset().top,
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

function suppr_article(id) {
  if (confirm("Voulez-vous supprimer cet Article ?")) {
    alert("Cet article a été supprimé");
    $.ajax({
      type: "POST",
      url: "ajax/article/supprime_article.php",
      dataType: "json",
      encode: true,
      data: "id_article=" + id, // on envoie via post l’id
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
