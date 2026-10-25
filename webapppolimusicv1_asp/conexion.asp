<%
' =====================================================================
'  conexion.asp
'  Conexión reutilizable a SQL Server (BDD_PoliMusic) mediante ADODB.
'  Se incluye en las demás páginas con la directiva include file.
'  Nota: este archivo NO lleva la directiva Language/CodePage porque
'  solo puede existir una por página y ya la declara la página que
'  lo incluye.
' =====================================================================

' --- Constantes de ADO (equivalentes a adovbs.inc) ---
Const adCmdText     = 1
Const adInteger     = 3
Const adVarChar     = 200
Const adParamInput  = 1
Const adStateOpen   = 1

' --- Cadena de conexión ---
Const CADENA_CONEXION = "Provider=SQLOLEDB;Data Source=127.0.0.1,14333;Initial Catalog=BDD_PoliMusic;User ID=sa;Password=Politecnica1;"

' Objeto de conexión compartido por toda la página
Dim conn
Set conn = Nothing

' ---------------------------------------------------------------------
' Devuelve la conexión abierta. Se abre una sola vez por petición
' (apertura diferida) y se reutiliza en todos los comandos.
' ---------------------------------------------------------------------
Function ObtenerConexion()
    If conn Is Nothing Then
        Set conn = Server.CreateObject("ADODB.Connection")
    End If

    If conn.State <> adStateOpen Then
        On Error Resume Next
        conn.Open CADENA_CONEXION
        If Err.Number <> 0 Then
            Dim detalle
            detalle = Err.Description
            On Error GoTo 0
            MostrarErrorConexion detalle
        End If
        On Error GoTo 0
    End If

    Set ObtenerConexion = conn
End Function

' ---------------------------------------------------------------------
' Crea un ADODB.Command ya asociado a la conexión. Los parámetros se
' agregan después con cmd.Parameters.Append cmd.CreateParameter(...)
' y en el SQL se marcan con "?".
' ---------------------------------------------------------------------
Function CrearComando(sql)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = ObtenerConexion()
    cmd.CommandText = sql
    cmd.CommandType = adCmdText
    Set CrearComando = cmd
End Function

' ---------------------------------------------------------------------
' Cierra un recordset de forma segura.
' ---------------------------------------------------------------------
Sub CerrarRecordset(ByRef rs)
    If IsObject(rs) Then
        If Not rs Is Nothing Then
            If rs.State = adStateOpen Then rs.Close
            Set rs = Nothing
        End If
    End If
End Sub

' ---------------------------------------------------------------------
' Cierra la conexión compartida si está abierta.
' ---------------------------------------------------------------------
Sub CerrarConexion()
    If Not conn Is Nothing Then
        If conn.State = adStateOpen Then conn.Close
        Set conn = Nothing
    End If
End Sub

' ---------------------------------------------------------------------
' Página mínima de error cuando SQL Server no responde.
' ---------------------------------------------------------------------
Sub MostrarErrorConexion(detalle)
    Response.Clear
    Response.Write "<!DOCTYPE html><html lang=""es""><head><meta charset=""UTF-8"">"
    Response.Write "<title>PoliMusic - Error de conexión</title>"
    Response.Write "<link rel=""stylesheet"" href=""css/styles.css""></head>"
    Response.Write "<body class=""page-error""><main class=""error-box"">"
    Response.Write "<h1>No se pudo conectar a la base de datos</h1>"
    Response.Write "<p>Verifica que SQL Server esté en ejecución en 127.0.0.1,14333 y que exista BDD_PoliMusic.</p>"
    Response.Write "<pre>" & Server.HTMLEncode(detalle) & "</pre>"
    Response.Write "<a class=""btn btn-primary"" href=""login.asp"">Reintentar</a>"
    Response.Write "</main></body></html>"
    Response.End
End Sub
%>
