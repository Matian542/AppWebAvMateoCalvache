using System.Data;
using System.Data.SqlClient;

namespace WebAppPoliMusicV2.DAL
{
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Lista las canciones con sus artistas (TBL_PLAYER + TBL_ARTIST) y álbumes
        /// (TBL_TRACKLIST + TBL_ALBUM) agrupados en una sola fila por canción.
        /// </summary>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            string sentence =
                "SELECT s.[ID_SONG], s.[SONG_NAME], s.[SONG_PATH], ISNULL(s.[PLAYS], 0) AS [PLAYS], " +
                "  ISNULL((SELECT STRING_AGG(x.[NAME], ', ') WITHIN GROUP (ORDER BY x.[NAME]) " +
                "          FROM (SELECT DISTINCT a.[ARTIST_NAME] + ISNULL(' ' + a.[ARTIST_LASTNAME], '') AS [NAME] " +
                "                FROM [TBL_PLAYER] p INNER JOIN [TBL_ARTIST] a ON a.[ID_ARTIST] = p.[ID_ARTIST] " +
                "                WHERE p.[ID_SONG] = s.[ID_SONG]) x), '-') AS [ARTISTS], " +
                "  ISNULL((SELECT STRING_AGG(y.[TITLE], ', ') WITHIN GROUP (ORDER BY y.[TITLE]) " +
                "          FROM (SELECT DISTINCT al.[TITLE_ALBUM] AS [TITLE] " +
                "                FROM [TBL_TRACKLIST] t INNER JOIN [TBL_ALBUM] al ON al.[ID_ALBUM] = t.[ID_ALBUM] " +
                "                WHERE t.[ID_SONG] = s.[ID_SONG]) y), '-') AS [ALBUMS] " +
                "FROM [TBL_SONG] s " +
                "ORDER BY s.[ID_SONG]";

            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sentence, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public int Save(string songName, string songPath, int plays)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG]([SONG_NAME], [SONG_PATH], [PLAYS]) VALUES(@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    cmd.Parameters.AddWithValue("@PLAYS", plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Update(int idSong, string songName, string songPath, int plays)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [SONG_NAME] = @SONG_NAME, [SONG_PATH] = @SONG_PATH, [PLAYS] = @PLAYS " +
                                      "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    cmd.Parameters.AddWithValue("@PLAYS", plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina la canción y sus relaciones dentro de una transacción:
        /// si alguna sentencia falla no se borra nada.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                SqlTransaction tx = con.BeginTransaction();
                try
                {
                    string[] sentences = new string[]
                    {
                        "DELETE FROM [TBL_PLAYLIST_SONG] WHERE [ID_SONG] = @ID_SONG",
                        "DELETE FROM [TBL_TRACKLIST] WHERE [ID_SONG] = @ID_SONG",
                        "DELETE FROM [TBL_PLAYER] WHERE [ID_SONG] = @ID_SONG",
                        "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG"
                    };
                    int rows = 0;
                    foreach (string sentence in sentences)
                    {
                        using (SqlCommand cmd = new SqlCommand(sentence, con, tx))
                        {
                            cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                            rows = cmd.ExecuteNonQuery();
                        }
                    }
                    tx.Commit();
                    return rows;
                }
                catch
                {
                    tx.Rollback();
                    throw;
                }
            }
        }
    }
}