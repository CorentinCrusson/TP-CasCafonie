function hdModalRetour() {
  $("#ModalRetour").modal("hide");

  document.location.reload(true); //Reload la page sans recharcher le cache ( permettant donc d'avoir une page plus fluide )
}

$(document).ready(function () {
  $.datepicker.setDefaults($.datepicker.regional["fr"]);
  $("#date_deb").datepicker(
    { changeYear: true, dateFormat: "yy-mm-dd" },
    "setDate",
    $("#date_deb").val()
  );
  $("#date_fin").datepicker(
    { changeYear: true, dateFormat: "yy-mm-dd" },
    "setDate",
    $("#date_fin").val()
  );
  CKEDITOR.replace("corps");

  $("#modifarticle").submit(function (e) {
    e.preventDefault();
    var $url = "./ajax/valide_article.php";

    var formData = {
      titre: $("#h3").val(),
      date_deb: $("#date_deb").val(),
      date_fin: $("#date_fin").val(),
      corps: CKEDITOR.instances.corps.getData(),
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
