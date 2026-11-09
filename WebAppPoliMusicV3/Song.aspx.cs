using System;
using System.Configuration;
using System.Data;
using System.IO;

namespace WebAppPoliMusicV3
{
    public partial class Song : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            EntityLayer.PoliMusicV3.User user =
                Session[EntityLayer.PoliMusicV3.Util.Constants.USER]
                as EntityLayer.PoliMusicV3.User;

            if (user == null)
            {
                Response.Redirect("~/Logout.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSongs();
            }
        }

        private void LoadSongs()
        {
            try
            {
                string connectionString =
                    ConfigurationManager.ConnectionStrings[
                        "BDD_PoliMusicConnectionString"].ConnectionString;

                DataTable songs =
                    new BLL.PoliMusicV3.Song(connectionString).Read();

                gvSongs.DataSource = songs;
                gvSongs.DataBind();

                lblCount.Text = songs.Rows.Count.ToString();
                lblMessage.Text = string.Empty;
            }
            catch (Exception ex)
            {
                lblMessage.Text = Server.HtmlEncode(
                    "No se pudieron cargar las canciones: " + ex.Message);
            }
        }

        protected string GetSongUrl(object songPath)
        {
            string path = Convert.ToString(songPath);

            if (string.IsNullOrWhiteSpace(path))
            {
                return string.Empty;
            }

            string fileName =
                Path.GetFileName(path.Replace('\\', '/'));

            string folder =
                ConfigurationManager.AppSettings["songFolderPath"]
                ?? "~/SongFiles/";

            string url = ResolveUrl(
                folder.TrimEnd('/') + "/" +
                Uri.EscapeDataString(fileName));

            return Server.HtmlEncode(url);
        }
    }
}