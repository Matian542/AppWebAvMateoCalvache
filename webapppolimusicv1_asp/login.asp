<%@ Language="VBScript" CodePage="65001" %>
<%
Option Explicit
Response.Charset = "UTF-8"
%>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' =====================================================================
'  login.asp - Autenticación contra TBL_USER
' =====================================================================

' Si ya hay una sesión activa, no tiene sentido volver a iniciarla
If HaySesion() Then Response.Redirect "songs.asp"

Dim usuario, clave, mensajeError
usuario = ""
mensajeError = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    usuario = Trim(Request.Form("username"))
    clave = Request.Form("password")

    If usuario = "" Or clave = "" Then
        mensajeError = "Ingresa tu usuario y tu contraseña."
    Else
        Dim cmd, rs
        ' Consulta parametrizada: los "?" se reemplazan por los parámetros,
        ' nunca se concatena texto del usuario en el SQL.
        ' COLLATE ..._CS_AS hace que la contraseña distinga mayúsculas.
        Set cmd = CrearComando( _
            "SELECT ID_USER, USERNAME, USER_PHOTO, USER_TYPE " & _
            "FROM TBL_USER " & _
            "WHERE USERNAME = ? AND PASSWORD = ? COLLATE Latin1_General_CS_AS")
        cmd.Parameters.Append cmd.CreateParameter("@usuario", adVarChar, adParamInput, 50, Left(usuario, 50))
        cmd.Parameters.Append cmd.CreateParameter("@clave", adVarChar, adParamInput, 50, Left(clave, 50))
        Set rs = cmd.Execute

        If Not rs.EOF Then
            ' Credenciales correctas: se guardan los datos en la sesión
            Session("ID_USER")    = CLng(rs("ID_USER"))
            Session("USERNAME")   = CStr(rs("USERNAME"))
            Session("USER_PHOTO") = CStr(Nz(rs("USER_PHOTO"), ""))
            Session("USER_TYPE")  = CInt(rs("USER_TYPE"))

            CerrarRecordset rs
            Set cmd = Nothing
            CerrarConexion
            Response.Redirect "songs.asp"
        Else
            mensajeError = "Usuario o contraseña incorrectos."
        End If

        CerrarRecordset rs
        Set cmd = Nothing
    End If
End If

CerrarConexion
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PoliMusic - Iniciar sesión</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Outfit:wght@500;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body class="page-login">

    <main class="login-layout">
        <!-- Panel decorativo con las portadas de PlaylistImages -->
        <section class="login-art" aria-hidden="true">
            <div class="cover-stack">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist1.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist2.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist3.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist4.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist5.png" alt="">
            </div>
            <p class="login-tagline">Tu música, tus listas,<br><span>a un clic.</span></p>
        </section>

        <!-- Formulario de acceso -->
        <section class="login-card">
            <div class="brand brand-lg">
                <span class="brand-mark" aria-hidden="true">
                    <svg viewBox="0 0 24 24" width="26" height="26"><path fill="currentColor" d="M9 18.5A2.5 2.5 0 1 1 6.5 16c.17 0 .34.02.5.05V5.6l12-2.4v12.3A2.5 2.5 0 1 1 16.5 13c.17 0 .34.02.5.05V7.04L9 8.64v9.86z"/></svg>
                </span>
                <span class="brand-name">Poli<strong>Music</strong></span>
            </div>

            <h1>Iniciar sesión</h1>
            <p class="muted">Ingresa con tu cuenta para escuchar el catálogo.</p>

            <% If mensajeError <> "" Then %>
                <div class="alert alert-error" role="alert"><%= H(mensajeError) %></div>
            <% End If %>

            <form method="post" action="login.asp" class="form" autocomplete="on">
                <div class="field">
                    <label for="username">Usuario</label>
                    <input type="text" id="username" name="username" maxlength="50" required autofocus
                           value="<%= H(usuario) %>" placeholder="Tu nombre de usuario">
                </div>
                <div class="field">
                    <label for="password">Contraseña</label>
                    <input type="password" id="password" name="password" maxlength="50" required
                           placeholder="••••••••">
                </div>
                <button type="submit" class="btn btn-primary btn-block">Entrar</button>
            </form>
        </section>
    </main>

    <script src="js/app.js"></script>
</body>
</html>
