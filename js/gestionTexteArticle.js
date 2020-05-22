function js_change_texte() {
  var myselect = document.getElementById("liste_txt");

  //$("#liste_art").empty(); //vide la combo box
  $.ajax({
    type: "POST",
    url: "ajax/recherche_article.php",
    dataType: "json",
    encode: true,
    data: "id_txt=" + myselect.options[myselect.selectedIndex].value, // on envoie via post l’id
    success: function (retour) {
      $("#liste_art").fadeIn();
      $.each(retour, function (index, value) {
        // pour chaque noeud JSON
        // on ajoute l option dans la liste
        $("#liste_art").append(
          "<option value=" + value + ">" + index + "</option>"
        );
      });
      $("#liste_art").focus();
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
