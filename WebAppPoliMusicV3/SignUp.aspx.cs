using System;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Net.Mail;
using System.Text.RegularExpressions;

namespace WebAppPoliMusicV3
{
    public partial class SignUp : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSumbit_Click(object sender, EventArgs e)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;

            string userName = txtUserName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            if (string.IsNullOrWhiteSpace(userName) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                lblMessage.Text =
                    "Completa usuario, correo y contraseña.";
                return;
            }

            if (!Regex.IsMatch(userName, @"^[a-zA-Z0-9._-]+$"))
            {
                lblMessage.Text =
                    "El usuario solo admite letras sin tildes, " +
                    "números, punto, guion y guion bajo.";
                return;
            }

            if (password != txtConfirmPassword.Text)
            {
                lblMessage.Text = "Las contraseñas no coinciden.";
                return;
            }

            if (!IsValidEmail(email))
            {
                lblMessage.Text = "El correo electrónico no es válido.";
                return;
            }

            string birthday = string.Empty;

            if (!string.IsNullOrWhiteSpace(txtBirthDate.Text))
            {
                DateTime birthDate;

                if (!DateTime.TryParseExact(
                    txtBirthDate.Text.Trim(),
                    "dd/MM/yyyy",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out birthDate))
                {
                    lblMessage.Text =
                        "La fecha debe tener formato dd/MM/yyyy.";
                    return;
                }

                birthday = birthDate.ToString("yyyy-MM-dd");
            }

            string connectionString =
                ConfigurationManager.ConnectionStrings[
                    "BDD_PoliMusicConnectionString"].ConnectionString;

            string imageFolder =
                ConfigurationManager.AppSettings["userPhotoPath"];

            string extension = fupPhoto.HasFile
                ? Path.GetExtension(fupPhoto.FileName).ToLowerInvariant()
                : ".jpg";

            EntityLayer.PoliMusicV3.User user =
                new EntityLayer.PoliMusicV3.User
                {
                    UserName = userName,
                    Email = email,
                    Birthday = birthday,
                    UserType =
                        EntityLayer.PoliMusicV3.Util.Constants.ID_USER_NORMAL,
                    Photo = imageFolder + userName + extension
                };

            BLL.PoliMusicV3.User business =
                new BLL.PoliMusicV3.User(connectionString);

            string message = business.ValidationsDuplicated(user);

            if (!string.IsNullOrEmpty(message))
            {
                lblMessage.Text = message;
                return;
            }

            FileManagement files = new FileManagement();

            if (fupPhoto.HasFile)
            {
                message = files.SaveImageOnServer(
                    fupPhoto, imageFolder, userName);
            }
            else
            {
                message = files.SaveDefaultImageOnServer(
                    imageFolder, userName);
            }

            if (!string.IsNullOrEmpty(message))
            {
                lblMessage.Text = message;
                return;
            }

            user.Password =
                EntityLayer.PoliMusicV3.Util.Hash
                    .GeneratePasswordHash(password);

            int result = business.Save(user);

            if (result > 0)
            {
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text =
                    "Usuario registrado correctamente. " +
                    "Ya puedes iniciar sesión.";
            }
            else
            {
                lblMessage.Text = "No se pudo registrar el usuario.";
            }
        }

        public static bool IsValidEmail(string email)
        {
            try
            {
                MailAddress address = new MailAddress(email);
                return address.Address == email;
            }
            catch (FormatException)
            {
                return false;
            }
        }
    }
}