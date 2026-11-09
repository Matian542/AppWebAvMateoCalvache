using System;
using System.Configuration;
using System.Data;
using System.Web.Security;

namespace WebAppPoliMusicV3
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = string.Empty;
            }
        }

        protected void BtnLogin_Click(object sender, EventArgs e)
        {
            string login = txtLogin.Text.Trim();
            string password = txtPassword.Text;

            if (string.IsNullOrEmpty(login) ||
                string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Escribe tu usuario y contraseña.";
                return;
            }

            string connectionString =
                ConfigurationManager.ConnectionStrings[
                    "BDD_PoliMusicConnectionString"].ConnectionString;

            string passwordHash =
                EntityLayer.PoliMusicV3.Util.Hash
                    .GeneratePasswordHash(password);

            DataTable dtUser =
                new BLL.PoliMusicV3.User(connectionString)
                    .AuthenticateUser(login, passwordHash);

            if (dtUser == null || dtUser.Rows.Count == 0)
            {
                lblMessage.Text = "Usuario o contraseña incorrectos.";
                return;
            }

            DataRow row = dtUser.Rows[0];

            EntityLayer.PoliMusicV3.User user =
                new EntityLayer.PoliMusicV3.User
                {
                    ID = Convert.ToInt32(row["ID_USER"]),
                    UserName = row["USERNAME"].ToString(),
                    Email = row["EMAIL"].ToString(),
                    Birthday = row["BIRTHDAY"].ToString(),
                    Photo = row["USER_PHOTO"].ToString(),
                    UserType = Convert.ToInt32(row["USER_TYPE"])
                };

            Session[EntityLayer.PoliMusicV3.Util.Constants.USER] = user;

            FormsAuthentication.RedirectFromLoginPage(login, false);
        }

        protected void LinkButtonNewUser_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/SignUp.aspx");
        }
    }
}