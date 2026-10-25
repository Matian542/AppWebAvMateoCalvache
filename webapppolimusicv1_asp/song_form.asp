<%@ Language="VBScript" CodePage="65001" %>
<%
Option Explicit
Response.Charset = "UTF-8"
%>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' =====================================================================
'  song_form.asp - Formulario para crear o editar una canción
'  Solo administradores. Sin "id" = nueva canción; con "id" = edición.
' =====================================================================

RequerirAdmin

Dim idCancion, esEdicion, nombre, ruta, reproducciones
idCancion = Trim(Request.QueryString("id"))
esEdicion = False
nombre = ""
ruta = "~/songFiles/"
reproducciones = 0

If idCancion <> "" Then
    If Not EsEntero(idCancion) Then Response.Redirect "songs.asp?msg=notfound"

    Dim cmd, rs
    Set cmd = CrearComando("SELECT SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@id", adInteger, adParamInput, , CLng(idCancion))
    Set rs = cmd.Execute

    If rs.EOF Then
        CerrarRecordset rs
        Set cmd = Nothing
        CerrarConexion
        Response.Redirect "songs.asp?msg=notfound"
    End If

    esEdicion = True
    nombre = Nz(rs("SONG_NAME"), "")
    ruta = Nz(rs("SONG_PATH"), "")
    reproducciones = CLng(Nz(rs("PLAYS"), 0))

    CerrarRecordset rs
    Set cmd = Nothing
End If

CerrarConexion

' Mensaje de validación enviado por song_save.asp (solo códigos conocidos)
Dim mensajeError
Select Case Request.QueryString("err")
    Case "name":  mensajeError = "El nombre es obligatorio y admite máximo 50 caracteres."
    Case "path":  mensajeError = "La ruta es obligatoria y admite máximo 255 caracteres."
    Case "plays": mensajeError = "Las reproducciones deben ser un número entero mayor o igual a 0."
    Case Else:    mensajeError = ""
End Select

Dim tituloPagina
If esEdicion Then tituloPagina = "Editar canción" Else tituloPagina = "Nueva canción"
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic - <%= tituloPagina %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Outfit:wght@500;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <% PintarEncabezado %>

    <main class="container container-narrow">
        <a class="back-link" href="songs.asp">&larr; Volver a Song List</a>

        <section class="panel form-panel">
            <div class="form-panel-head">
                <img src="SongFilesAndImages_resources/PlaylistImages/default.jpg" alt="" aria-hidden="true">
                <div>
                    <h1><%= tituloPagina %></h1>
                    <p class="muted"><% If esEdicion Then %>Modifica los datos de la canción N.º <%= H(idCancion) %>.<% Else %>Registra una nueva canción en el catálogo.<% End If %></p>
                </div>
            </div>

            <% If mensajeError <> "" Then %>
                <div class="alert alert-error" role="alert"><%= H(mensajeError) %></div>
            <% End If %>

            <form method="post" action="song_save.asp" class="form">
                <input type="hidden" name="id" value="<% If esEdicion Then Response.Write H(idCancion) %>">

                <div class="field">
                    <label for="song_name">Nombre de la canción</label>
                    <input type="text" id="song_name" name="song_name" maxlength="50" required
                           value="<%= H(nombre) %>" placeholder="Ej.: Adventure">
                </div>

                <div class="field">
                    <label for="song_path">Ruta del archivo</label>
                    <input type="text" id="song_path" name="song_path" maxlength="255" required
                           value="<%= H(ruta) %>" placeholder="~/songFiles/bensound-adventure.mp3">
                    <small class="hint">Formato de la base: <code>~/songFiles/archivo.mp3</code>. Los archivos se buscan en <code>SongFilesAndImages_resources/SongFiles/</code>.</small>
                </div>

                <div class="field">
                    <label for="plays">Reproducciones</label>
                    <input type="number" id="plays" name="plays" min="0" max="999999999" step="1" required
                           value="<%= reproducciones %>">
                </div>

                <div class="form-actions">
                    <a class="btn btn-ghost" href="songs.asp">Cancelar</a>
                    <button type="submit" class="btn btn-primary"><% If esEdicion Then %>Guardar cambios<% Else %>Crear canción<% End If %></button>
                </div>
            </form>
        </section>
    </main>

    <script src="js/app.js"></script>
</body>
</html>
