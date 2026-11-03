using System;
using System.Configuration;
using System.Data;
using System.IO;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // El usuario se guardó en sesión en Login.aspx
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user == null)
            {
                // Sin sesión: se cierra la autenticación y se vuelve al Login
                Response.Redirect("Logout.aspx", true);
                return;
            }

            if (!Page.IsPostBack)
            {
                lblUserName.Text = Server.HtmlEncode(user.UserName);
                lblRole.Text = (user.UserType == Util.Constants.ID_USER_ADMIN) ? "Administrador" : "Usuario normal";
                imgUser.ImageUrl = GetUserPhoto(user.Photo);
                LoadSongs();
            }
        }

        private void LoadSongs()
        {
            try
            {
                DataTable dtSongs = new BLL.Song(strConnString).Read();
                gvSongs.DataSource = dtSongs;
                gvSongs.DataBind();

                int totalPlays = 0;
                foreach (DataRow row in dtSongs.Rows)
                {
                    totalPlays += (row["PLAYS"] == DBNull.Value) ? 0 : Convert.ToInt32(row["PLAYS"]);
                }
                lblCount.Text = dtSongs.Rows.Count.ToString();
                lblPlays.Text = totalPlays.ToString();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error loading songs: " + ex.Message;
            }
        }

        /// <summary>
        /// Convierte la ruta de la base (por ejemplo "~/songFiles/bensound-adventure.mp3")
        /// en una URL del sitio. Si el archivo no existe, el reproductor lo marca como no disponible.
        /// </summary>
        protected string GetSongUrl(object songPath)
        {
            string path = Convert.ToString(songPath);
            if (path == string.Empty)
            {
                return string.Empty;
            }
            return ResolveUrl(path);
        }

        /// <summary>
        /// Devuelve la foto del usuario o la imagen por defecto si no tiene o no existe en el servidor.
        /// </summary>
        private string GetUserPhoto(string photo)
        {
            string defaultPhoto = "~/UserImages/default.jpg";
            if (string.IsNullOrEmpty(photo))
            {
                return defaultPhoto;
            }
            try
            {
                return File.Exists(Server.MapPath(photo)) ? photo : defaultPhoto;
            }
            catch (Exception)
            {
                return defaultPhoto;
            }
        }
    }
}