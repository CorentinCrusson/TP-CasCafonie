function afficheTexte(id) {
  var sectionTxt = document.getElementById("affichageTexteLoi");
  sectionTxt.style.display = "none";

  $.ajax({
    type: "POST",
    url: "ajax/recherche_info_texte_article.php",
    dataType: "json",
    encode: true,
    data: "id_texte=" + id, // on envoie via post l’id

    success: function (retour) {
      $("#articleDiv").empty();
      $("#affichageUnTexteLoi").css("display", "block");
      $("#titreTexte").text(retour["titre_txt"]);

      $.each(retour, function (index, value) {
        if (index != "titre_txt") {
          $("#articleDiv").append(
            "<div class='card bg-secondary text-white m-2' > <div class='card-body'><article> <h3 class='card-title'>" +
              index +
              "</h3>" +
              value +
              "</article></div></div>"
          );
        }
      });
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

function retour() {
  var sectionAutre = document.getElementById("affichageUnTexteLoi");
  var sectionTxt = document.getElementById("affichageTexteLoi");
  sectionAutre.style.display = "none";
  sectionTxt.style.display = "block";
}
