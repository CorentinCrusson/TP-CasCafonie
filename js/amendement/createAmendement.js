function hdModalRetour() {
  $("#ModalRetour").modal("hide");
}

$(document).ready(function () {
  $.datepicker.setDefaults($.datepicker.regional["fr"]);

  $("#date_amend").datepicker(
    { changeYear: true, dateFormat: "yy-mm-dd" },
    "setDate",
    $("#date_amend").val()
  );
  CKEDITOR.replace("corps");

  $("#createamendement").submit(function (e) {
    e.preventDefault();

    var myselectTexte = document.getElementById("liste_txt");
    var myselectArticle = document.getElementById("liste_art");
    var $url = "./ajax/valide_create_amendement.php";

    var formData = {
      titre: $("#h3").val(),
      corps: CKEDITOR.instances.corps.getData(),
      date_amend: $("#date_amend").val(),
      id_txt: myselectTexte.options[myselectTexte.selectedIndex].value,
      id_art: myselectArticle.options[myselectArticle.selectedIndex].value,
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
      hdModalRetour();
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
