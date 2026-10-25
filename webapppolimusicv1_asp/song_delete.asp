<%@ Language="VBScript" CodePage="65001" %>
<%
Option Explicit
Response.Charset = "UTF-8"
%>
<!--#include file="conexion.asp"-->
<!--#include file="funciones.asp"-->
<%
' =====================================================================
'  song_delete.asp - Elimina una canción y sus relaciones
'  Solo administradores y solo por POST (el formulario de songs.asp
'  pide confirmación con JavaScript antes de enviarse).
' =====================================================================

RequerirAdmin

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Response.Redirect "songs.asp"
End If

Dim idCancion
idCancion = Trim(Request.Form("id"))
If Not EsEntero(idCancion) Then Response.Redirect "songs.asp?msg=notfound"

' ---------------------------------------------------------------------
' Ejecuta un DELETE parametrizado por ID_SONG y devuelve las filas
' afectadas, o -1 si hubo un error.
' ---------------------------------------------------------------------
Function BorrarPorCancion(sql, id)
    Dim cmd, filas
    On Error Resume Next
    Set cmd = CrearComando(sql)
    cmd.Parameters.Append cmd.CreateParameter("@id", adInteger, adParamInput, , id)
    cmd.Execute filas
    If Err.Number <> 0 Then
        BorrarPorCancion = -1
    Else
        BorrarPorCancion = filas
    End If
    Err.Clear
    Set cmd = Nothing
End Function

Dim id, ok, filasCancion
id = CLng(idCancion)

' Todo dentro de una transacción: o se borra todo o no se borra nada
Call ObtenerConexion()
conn.BeginTrans

' 1) Primero las tablas que referencian a TBL_SONG (claves foráneas)
ok = (BorrarPorCancion("DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", id) >= 0)
If ok Then ok = (BorrarPorCancion("DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", id) >= 0)
If ok Then ok = (BorrarPorCancion("DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", id) >= 0)

' 2) Luego la canción
If ok Then
    filasCancion = BorrarPorCancion("DELETE FROM TBL_SONG WHERE ID_SONG = ?", id)
    ok = (filasCancion >= 0)
End If

Dim destino
If ok And filasCancion > 0 Then
    conn.CommitTrans
    destino = "songs.asp?msg=deleted"
ElseIf ok Then
    ' No existía la canción: no hay nada que confirmar
    conn.RollbackTrans
    destino = "songs.asp?msg=notfound"
Else
    conn.RollbackTrans
    destino = "songs.asp?msg=error"
End If

CerrarConexion
Response.Redirect destino
%>
