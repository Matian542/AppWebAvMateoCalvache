<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="SignUp.aspx.cs"
    Inherits="WebAppPoliMusicV3.SignUp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Registro - PoliMusic</title>
</head>
<body>
    <h2>PoliMusic - Mateo.Calvache</h2>
    <h3>Registrar nuevo usuario</h3>

    <form id="formSignUp" runat="server">
        <div>
            Usuario*:<br />
            <asp:TextBox ID="txtUserName" runat="server" />
            <br /><br />

            Correo electrónico*:<br />
            <asp:TextBox ID="txtEmail" runat="server" />
            <br /><br />

            Contraseña*:<br />
            <asp:TextBox ID="txtPassword" runat="server"
                TextMode="Password" />
            <br /><br />

            Confirmar contraseña*:<br />
            <asp:TextBox ID="txtConfirmPassword" runat="server"
                TextMode="Password" />
            <br /><br />

            Fecha de nacimiento (dd/MM/yyyy):<br />
            <asp:TextBox ID="txtBirthDate" runat="server" />
            <br /><br />

            Foto:<br />
            <asp:FileUpload ID="fupPhoto" runat="server" />
            <br /><br />

            <asp:Button ID="btnSumbit" runat="server"
                Text="Registrarse" OnClick="btnSumbit_Click" />
            <br /><br />

            <asp:HyperLink ID="lnkLogin" runat="server"
                NavigateUrl="~/Login.aspx">
                Volver al inicio de sesión
            </asp:HyperLink>
            <br /><br />

            <asp:Label ID="lblMessage" runat="server"
                ForeColor="Red" Font-Bold="true" />
        </div>
    </form>
</body>
</html>