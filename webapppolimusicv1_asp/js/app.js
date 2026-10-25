/* =====================================================================
   PoliMusic - Comportamiento del lado del cliente
   1) Confirmación antes de eliminar una canción.
   2) Al reproducir una canción se pausan las demás y se resalta su fila.
   ===================================================================== */
(function () {
    "use strict";

    // -----------------------------------------------------------------
    // 1) Confirmación de borrado
    //    Los formularios de eliminar tienen la clase "js-delete-form" y
    //    el nombre de la canción en data-song.
    // -----------------------------------------------------------------
    var formulariosBorrar = document.querySelectorAll(".js-delete-form");

    Array.prototype.forEach.call(formulariosBorrar, function (form) {
        form.addEventListener("submit", function (evento) {
            var nombre = form.getAttribute("data-song") || "esta canción";
            var mensaje = "¿Seguro que deseas eliminar \"" + nombre + "\"?\n" +
                          "También se quitará de playlists, álbumes y artistas.";
            if (!window.confirm(mensaje)) {
                evento.preventDefault();
            }
        });
    });

    // -----------------------------------------------------------------
    // 2) Un solo reproductor a la vez y fila resaltada
    // -----------------------------------------------------------------
    var reproductores = document.querySelectorAll(".song-table audio");

    function filaDe(audio) {
        return audio.closest ? audio.closest("tr") : null;
    }

    Array.prototype.forEach.call(reproductores, function (audio) {
        audio.addEventListener("play", function () {
            // Pausar cualquier otra canción que esté sonando
            Array.prototype.forEach.call(reproductores, function (otro) {
                if (otro !== audio && !otro.paused) {
                    otro.pause();
                }
                var filaOtro = filaDe(otro);
                if (filaOtro && otro !== audio) {
                    filaOtro.classList.remove("is-playing");
                }
            });

            var fila = filaDe(audio);
            if (fila) {
                fila.classList.add("is-playing");
            }
        });

        // Al pausar o terminar, quitar el resaltado de su fila
        function quitarResaltado() {
            var fila = filaDe(audio);
            if (fila) {
                fila.classList.remove("is-playing");
            }
        }

        audio.addEventListener("pause", quitarResaltado);
        audio.addEventListener("ended", quitarResaltado);
    });
})();
