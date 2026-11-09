<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="WebAppPoliMusicV3.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - PoliMusic</title>
</head>
<body>
    <h2>PoliMusic - Mateo Calvache</h2>
    <h3>Iniciar sesión</h3>

    <form id="formLogin" runat="server">
        <asp:TextBox ID="txtLogin" runat="server"
            placeholder="Usuario"></asp:TextBox>
        <br />

        <asp:TextBox ID="txtPassword" runat="server"
            TextMode="Password" placeholder="Contraseña"></asp:TextBox>
        <br />

        <asp:Button ID="btnLogin" runat="server"
            Text="Ingresar" OnClick="BtnLogin_Click" />

        <asp:LinkButton ID="LinkButtonNewUser" runat="server"
            OnClick="LinkButtonNewUser_Click">
            Registrar nuevo usuario
        </asp:LinkButton>
        <br />

        <asp:Label ID="lblMessage" runat="server"
            ForeColor="Red"></asp:Label>
    </form>
</body>
</html>