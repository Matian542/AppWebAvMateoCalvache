<%
' =====================================================================
'  funciones.asp
'  Utilidades comunes: conversión de rutas ASP.NET, comprobación de
'  archivos, codificación HTML, control de sesión/rol y encabezado.
' =====================================================================

Const CARPETA_RECURSOS = "SongFilesAndImages_resources/"
Const FOTO_USUARIO_DEFECTO = "SongFilesAndImages_resources/UserImages/default.jpg"

' ---------------------------------------------------------------------
' Convierte una ruta en formato ASP.NET ("~/songFiles/x.mp3") a la ruta
' real dentro del sitio. No distingue mayúsculas/minúsculas.
'   ~/songFiles/  ->  SongFilesAndImages_resources/SongFiles/
'   ~/userImages/ ->  SongFilesAndImages_resources/UserImages/
' ---------------------------------------------------------------------
Function ConvertirRuta(ruta)
    Dim r
    r = Trim(Nz(ruta, ""))
    r = Replace(r, "~/songFiles/", CARPETA_RECURSOS & "SongFiles/", 1, -1, vbTextCompare)
    r = Replace(r, "~/userImages/", CARPETA_RECURSOS & "UserImages/", 1, -1, vbTextCompare)
    ConvertirRuta = r
End Function

' ---------------------------------------------------------------------
' Indica si un archivo existe físicamente dentro del sitio.
' Usa Server.MapPath + Scripting.FileSystemObject.
' ---------------------------------------------------------------------
Function ArchivoExiste(rutaRelativa)
    Dim fso, rutaFisica
    ArchivoExiste = False
    If Len(rutaRelativa) = 0 Then Exit Function

    On Error Resume Next
    ' MapPath falla con rutas inválidas o con "..": en ese caso se
    ' considera que el archivo no existe
    rutaFisica = Server.MapPath(rutaRelativa)
    If Err.Number = 0 Then
        Set fso = Server.CreateObject("Scripting.FileSystemObject")
        ArchivoExiste = fso.FileExists(rutaFisica)
        Set fso = Nothing
    End If
    Err.Clear
    On Error GoTo 0
End Function

' ---------------------------------------------------------------------
' Devuelve la ruta de la foto de usuario; si el archivo no existe se
' usa UserImages/default.jpg.
' ---------------------------------------------------------------------
Function FotoUsuario(rutaBD)
    Dim ruta
    ruta = ConvertirRuta(rutaBD)
    If ArchivoExiste(ruta) Then
        FotoUsuario = ruta
    Else
        FotoUsuario = FOTO_USUARIO_DEFECTO
    End If
End Function

' ---------------------------------------------------------------------
' Reemplaza Null/Empty por un valor por defecto.
' ---------------------------------------------------------------------
Function Nz(valor, porDefecto)
    If IsNull(valor) Or IsEmpty(valor) Then
        Nz = porDefecto
    Else
        Nz = valor
    End If
End Function

' ---------------------------------------------------------------------
' Codifica texto para mostrarlo en HTML de forma segura (evita XSS).
' ---------------------------------------------------------------------
Function H(texto)
    H = Server.HTMLEncode(CStr(Nz(texto, "")))
End Function

' ---------------------------------------------------------------------
' Valida que un texto sea un entero positivo (solo dígitos). Se usa en
' lugar de IsNumeric, que acepta valores como "1e3" o "&H10".
' ---------------------------------------------------------------------
Function EsEntero(texto)
    Dim re
    Set re = New RegExp
    re.Pattern = "^\d{1,9}$"
    EsEntero = re.Test(CStr(Nz(texto, "")))
    Set re = Nothing
End Function

' ---------------------------------------------------------------------
' Control de sesión y rol
' ---------------------------------------------------------------------
Function HaySesion()
    HaySesion = Not IsEmpty(Session("ID_USER"))
End Function

Function EsAdmin()
    EsAdmin = False
    If HaySesion() Then EsAdmin = (CInt(Nz(Session("USER_TYPE"), 0)) = 1)
End Function

' Si no hay sesión, envía al login
Sub RequerirSesion()
    If Not HaySesion() Then
        Response.Redirect "login.asp"
    End If
End Sub

' Si no es administrador, envía al listado (validación en el servidor)
Sub RequerirAdmin()
    RequerirSesion
    If Not EsAdmin() Then
        Response.Redirect "songs.asp"
    End If
End Sub

Function NombreRol()
    If EsAdmin() Then
        NombreRol = "Administrador"
    Else
        NombreRol = "Usuario normal"
    End If
End Function

' ---------------------------------------------------------------------
' Encabezado común de las páginas internas: logo, saludo, foto, rol y
' botón para cerrar sesión.
' ---------------------------------------------------------------------
Sub PintarEncabezado()
    Dim claseRol
    If EsAdmin() Then claseRol = "role-admin" Else claseRol = "role-user"
%>
<header class="topbar">
    <a class="brand" href="songs.asp" aria-label="PoliMusic - inicio">
        <span class="brand-mark" aria-hidden="true">
            <svg viewBox="0 0 24 24" width="22" height="22"><path fill="currentColor" d="M9 18.5A2.5 2.5 0 1 1 6.5 16c.17 0 .34.02.5.05V5.6l12-2.4v12.3A2.5 2.5 0 1 1 16.5 13c.17 0 .34.02.5.05V7.04L9 8.64v9.86z"/></svg>
        </span>
        <span class="brand-name">Poli<strong>Music</strong></span>
    </a>

    <div class="user-box">
        <img class="user-photo" src="<%= H(FotoUsuario(Session("USER_PHOTO"))) %>" alt="Foto de <%= H(Session("USERNAME")) %>" width="44" height="44">
        <div class="user-info">
            <span class="user-greeting">Bienvenido, <strong><%= H(Session("USERNAME")) %></strong></span>
            <span class="role-badge <%= claseRol %>"><%= NombreRol() %></span>
        </div>
        <a class="btn btn-ghost btn-sm" href="logout.asp">Cerrar sesión</a>
    </div>
</header>
<%
End Sub
%>
