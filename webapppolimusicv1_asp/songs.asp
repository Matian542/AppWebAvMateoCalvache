<%@ Language="VBScript" CodePage="65001" %>
<%
Option Explicit
Response.Charset = "UTF-8"
%>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' =====================================================================
'  songs.asp - Listado de canciones (página protegida)
' =====================================================================

RequerirSesion

' ---------------------------------------------------------------------
' Una canción puede tener varios artistas (TBL_PLAYER) y estar en varios
' álbumes (TBL_TRACKLIST). Los LEFT JOIN devuelven una fila por cada
' combinación, así que se agrupan aquí para mostrar una fila por canción.
' ---------------------------------------------------------------------
Class Cancion
    Public Id, Nombre, Ruta, Reproducciones
    Public Artistas, Albumes   ' Scripting.Dictionary (sin duplicados)

    Private Sub Class_Initialize()
        Set Artistas = Server.CreateObject("Scripting.Dictionary")
        Set Albumes  = Server.CreateObject("Scripting.Dictionary")
    End Sub

    Private Sub Class_Terminate()
        Set Artistas = Nothing
        Set Albumes  = Nothing
    End Sub

    ' Une los valores del diccionario en un texto separado por comas
    Public Function Lista(dic)
        If dic.Count = 0 Then
            Lista = ""
        Else
            Lista = Join(dic.Keys, ", ")
        End If
    End Function
End Class

Dim cmd, rs, canciones, c, idActual, artista, album, totalReproducciones
Set canciones = Server.CreateObject("Scripting.Dictionary")   ' conserva el orden de inserción
totalReproducciones = 0

Set cmd = CrearComando( _
    "SELECT S.ID_SONG, S.SONG_NAME, S.SONG_PATH, S.PLAYS, " & _
    "       A.ARTIST_NAME, A.ARTIST_LASTNAME, AL.TITLE_ALBUM " & _
    "FROM TBL_SONG S " & _
    "LEFT JOIN TBL_PLAYER P     ON P.ID_SONG   = S.ID_SONG " & _
    "LEFT JOIN TBL_ARTIST A     ON A.ID_ARTIST = P.ID_ARTIST " & _
    "LEFT JOIN TBL_TRACKLIST T  ON T.ID_SONG   = S.ID_SONG " & _
    "LEFT JOIN TBL_ALBUM AL     ON AL.ID_ALBUM = T.ID_ALBUM " & _
    "ORDER BY S.ID_SONG, A.ARTIST_NAME, AL.TITLE_ALBUM")
Set rs = cmd.Execute

Do While Not rs.EOF
    idActual = CLng(rs("ID_SONG"))

    If Not canciones.Exists(idActual) Then
        Set c = New Cancion
        c.Id             = idActual
        c.Nombre         = Nz(rs("SONG_NAME"), "")
        c.Ruta           = ConvertirRuta(rs("SONG_PATH"))
        c.Reproducciones = CLng(Nz(rs("PLAYS"), 0))
        canciones.Add idActual, c
        totalReproducciones = totalReproducciones + c.Reproducciones
    Else
        Set c = canciones(idActual)
    End If

    ' Nombre completo del artista (el apellido puede ser NULL)
    If Not IsNull(rs("ARTIST_NAME")) Then
        artista = Trim(rs("ARTIST_NAME") & " " & Nz(rs("ARTIST_LASTNAME"), ""))
        If Not c.Artistas.Exists(artista) Then c.Artistas.Add artista, True
    End If

    If Not IsNull(rs("TITLE_ALBUM")) Then
        album = rs("TITLE_ALBUM")
        If Not c.Albumes.Exists(album) Then c.Albumes.Add album, True
    End If

    rs.MoveNext
Loop

CerrarRecordset rs
Set cmd = Nothing
CerrarConexion

' ---------------------------------------------------------------------
' Mensaje de confirmación tras una operación del CRUD. Solo se aceptan
' códigos conocidos: nunca se imprime texto recibido por la URL.
' ---------------------------------------------------------------------
Dim aviso, claseAviso
claseAviso = "alert-success"
Select Case Request.QueryString("msg")
    Case "created": aviso = "La canción se creó correctamente."
    Case "updated": aviso = "La canción se actualizó correctamente."
    Case "deleted": aviso = "La canción se eliminó correctamente."
    Case "notfound": aviso = "La canción solicitada no existe.": claseAviso = "alert-error"
    Case "error":   aviso = "No se pudo completar la operación.": claseAviso = "alert-error"
    Case Else:      aviso = ""
End Select

Dim esAdministrador, n, clave, tieneAudio
esAdministrador = EsAdmin()
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic - Song List</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Outfit:wght@500;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <% PintarEncabezado %>

    <main class="container">

        <!-- Banner decorativo con las portadas de PlaylistImages -->
        <section class="hero">
            <div class="hero-text">
                <p class="eyebrow">Catálogo PoliMusic</p>
                <h1 class="hero-title">Song List</h1>
                <p class="hero-sub">Listado de canciones disponibles para reproducir.</p>
                <ul class="stats">
                    <li><strong><%= canciones.Count %></strong> canciones</li>
                    <li><strong><%= totalReproducciones %></strong> reproducciones</li>
                </ul>
            </div>
            <div class="hero-covers" aria-hidden="true">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist1.png" alt="" loading="lazy">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist2.png" alt="" loading="lazy">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist3.png" alt="" loading="lazy">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist4.png" alt="" loading="lazy">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist5.png" alt="" loading="lazy">
            </div>
        </section>

        <% If aviso <> "" Then %>
            <div class="alert <%= claseAviso %>" role="status"><%= H(aviso) %></div>
        <% End If %>

        <section class="panel">
            <div class="panel-head">
                <h2>Song List <span class="muted">· listado de canciones</span></h2>
                <% If esAdministrador Then %>
                    <a class="btn btn-primary" href="song_form.asp">+ Nueva canción</a>
                <% End If %>
            </div>

            <% If canciones.Count = 0 Then %>
                <p class="empty">Todavía no hay canciones registradas.</p>
            <% Else %>
            <div class="table-wrap">
                <table class="song-table">
                    <thead>
                        <tr>
                            <th scope="col" class="col-num">N°</th>
                            <th scope="col">Canción</th>
                            <th scope="col">Artista</th>
                            <th scope="col">Álbum</th>
                            <th scope="col" class="col-plays">Reproducciones</th>
                            <th scope="col">Reproductor</th>
                            <% If esAdministrador Then %><th scope="col" class="col-actions">Acciones</th><% End If %>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    n = 0
                    For Each clave In canciones.Keys
                        Set c = canciones(clave)
                        n = n + 1
                        ' La ruta se usa tal cual; solo se avisa si el archivo no existe
                        tieneAudio = ArchivoExiste(c.Ruta)
                    %>
                        <tr>
                            <td data-label="N°" class="col-num"><%= n %></td>
                            <td data-label="Canción" class="song-name"><%= H(c.Nombre) %></td>
                            <td data-label="Artista"><%
                                If c.Artistas.Count > 0 Then
                                    Response.Write H(c.Lista(c.Artistas))
                                Else
                                    Response.Write "<span class=""muted"">Sin artista</span>"
                                End If
                            %></td>
                            <td data-label="Álbum"><%
                                If c.Albumes.Count > 0 Then
                                    Response.Write H(c.Lista(c.Albumes))
                                Else
                                    Response.Write "<span class=""muted"">Sin álbum</span>"
                                End If
                            %></td>
                            <td data-label="Reproducciones" class="col-plays"><%= c.Reproducciones %></td>
                            <td data-label="Reproductor" class="col-player">
                                <audio controls preload="none" src="<%= H(c.Ruta) %>">
                                    Tu navegador no soporta el elemento de audio.
                                </audio>
                                <% If Not tieneAudio Then %>
                                    <span class="tag-missing">Archivo no disponible</span>
                                <% End If %>
                            </td>
                            <% If esAdministrador Then %>
                            <td data-label="Acciones" class="col-actions">
                                <a class="btn btn-sm btn-secondary" href="song_form.asp?id=<%= c.Id %>">Editar</a>
                                <form method="post" action="song_delete.asp" class="inline-form js-delete-form" data-song="<%= H(c.Nombre) %>">
                                    <input type="hidden" name="id" value="<%= c.Id %>">
                                    <button type="submit" class="btn btn-sm btn-danger">Eliminar</button>
                                </form>
                            </td>
                            <% End If %>
                        </tr>
                    <%
                    Next
                    %>
                    </tbody>
                </table>
            </div>
            <% End If %>
        </section>
    </main>

    <footer class="footer">PoliMusic · Aplicaciones Web Avanzadas</footer>

    <script src="js/app.js"></script>
</body>
</html>
<%
Set canciones = Nothing
%>
