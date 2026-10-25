<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  logout.asp - Cierra la sesión del usuario y vuelve al login
' =====================================================================
Option Explicit
Response.Charset = "UTF-8"

Session.Contents.RemoveAll
Session.Abandon
Response.Redirect "login.asp"
%>
