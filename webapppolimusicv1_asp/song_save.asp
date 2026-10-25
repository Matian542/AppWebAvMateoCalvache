<%@ Language="VBScript" CodePage="65001" %>
<%
Option Explicit
Response.Charset = "UTF-8"
%>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' =====================================================================
'  song_save.asp - Guarda una canción (INSERT o UPDATE en TBL_SONG)
'  Solo administradores y solo por POST.
' =====================================================================

RequerirAdmin

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Response.Redirect "songs.asp"
End If

Dim idCancion, nombre, ruta, reproducciones, urlFormulario
idCancion      = Trim(Request.Form("id"))
nombre         = Trim(Request.Form("song_name"))
ruta           = Trim(Request.Form("song_path"))
reproducciones = Trim(Request.Form("plays"))

' Si viene un id que no es numérico, la petición no es válida
If idCancion <> "" And Not EsEntero(idCancion) Then
    Response.Redirect "songs.asp?msg=notfound"
End If

' URL de regreso al formulario cuando falla la validación
urlFormulario = "song_form.asp?"
If idCancion <> "" Then urlFormulario = urlFormulario & "id=" & idCancion & "&"

' --- Validación en el servidor (no se confía solo en el HTML) ---
If nombre = "" Or Len(nombre) > 50 Then Response.Redirect urlFormulario & "err=name"
If ruta = "" Or Len(ruta) > 255 Then Response.Redirect urlFormulario & "err=path"
If reproducciones = "" Then reproducciones = "0"
If Not EsEntero(reproducciones) Then Response.Redirect urlFormulario & "err=plays"

Dim cmd, filasAfectadas, destino

If idCancion = "" Then
    ' INSERT: ID_SONG es IDENTITY, por eso no se envía
    Set cmd = CrearComando("INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?)")
    cmd.Parameters.Append cmd.CreateParameter("@nombre", adVarChar, adParamInput, 50, nombre)
    cmd.Parameters.Append cmd.CreateParameter("@ruta", adVarChar, adParamInput, 255, ruta)
    cmd.Parameters.Append cmd.CreateParameter("@plays", adInteger, adParamInput, , CLng(reproducciones))
    cmd.Execute filasAfectadas
    destino = "songs.asp?msg=created"
Else
    ' UPDATE de la canción indicada
    Set cmd = CrearComando("UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?")
    cmd.Parameters.Append cmd.CreateParameter("@nombre", adVarChar, adParamInput, 50, nombre)
    cmd.Parameters.Append cmd.CreateParameter("@ruta", adVarChar, adParamInput, 255, ruta)
    cmd.Parameters.Append cmd.CreateParameter("@plays", adInteger, adParamInput, , CLng(reproducciones))
    cmd.Parameters.Append cmd.CreateParameter("@id", adInteger, adParamInput, , CLng(idCancion))
    cmd.Execute filasAfectadas

    ' Si no se actualizó ninguna fila, la canción ya no existe
    If filasAfectadas = 0 Then
        destino = "songs.asp?msg=notfound"
    Else
        destino = "songs.asp?msg=updated"
    End If
End If

Set cmd = Nothing
CerrarConexion
Response.Redirect destino
%>
