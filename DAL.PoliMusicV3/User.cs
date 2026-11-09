using System.Data;
using System.Data.SqlClient;

namespace DAL.PoliMusicV3
{
    public class User
    {
        private readonly string strConnectionString;

        public User(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(EntityLayer.PoliMusicV3.User user)
        {
            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                string columns =
                    "[USERNAME], [PASSWORD], [EMAIL], [USER_TYPE]";
                string values =
                    "@USERNAME, @PASSWORD, @EMAIL, @USER_TYPE";

                cmd.Parameters.AddWithValue("@USERNAME", user.UserName);
                cmd.Parameters.AddWithValue("@PASSWORD", user.Password);
                cmd.Parameters.AddWithValue("@EMAIL", user.Email);
                cmd.Parameters.AddWithValue("@USER_TYPE", user.UserType);

                if (!string.IsNullOrEmpty(user.Birthday))
                {
                    columns += ", [BIRTHDAY]";
                    values += ", @BIRTHDAY";
                    cmd.Parameters.AddWithValue("@BIRTHDAY", user.Birthday);
                }

                if (!string.IsNullOrEmpty(user.Photo))
                {
                    columns += ", [USER_PHOTO]";
                    values += ", @USER_PHOTO";
                    cmd.Parameters.AddWithValue("@USER_PHOTO", user.Photo);
                }

                cmd.CommandText = "INSERT INTO [TBL_USER] (" +
                    columns + ") VALUES (" + values + ")";

                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public int CheckExistUser(string userName)
        {
            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText =
                    "SELECT [ID_USER] FROM [TBL_USER] " +
                    "WHERE [USERNAME] = @USERNAME";

                cmd.Parameters.AddWithValue("@USERNAME", userName);

                con.Open();
                object result = cmd.ExecuteScalar();

                return result == null ? 0 : (int)result;
            }
        }

        public int CheckExistEmail(string email)
        {
            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText =
                    "SELECT [ID_USER] FROM [TBL_USER] " +
                    "WHERE [EMAIL] = @EMAIL";

                cmd.Parameters.AddWithValue("@EMAIL", email);

                con.Open();
                object result = cmd.ExecuteScalar();

                return result == null ? 0 : (int)result;
            }
        }

        public DataTable Read()
        {
            DataTable dtUser = new DataTable();

            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText =
                    "SELECT [ID_USER], [USERNAME], [PASSWORD], " +
                    "[EMAIL], [BIRTHDAY], [USER_PHOTO], [USER_TYPE] " +
                    "FROM [TBL_USER]";

                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dtUser);
                }
            }

            return dtUser;
        }

        public int Update(EntityLayer.PoliMusicV3.User user)
        {
            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                string sentence =
                    "UPDATE [TBL_USER] SET " +
                    "[USERNAME] = @USERNAME, " +
                    "[USER_TYPE] = @USER_TYPE, " +
                    "[EMAIL] = @EMAIL";

                cmd.Parameters.AddWithValue("@ID_USER", user.ID);
                cmd.Parameters.AddWithValue("@USERNAME", user.UserName);
                cmd.Parameters.AddWithValue("@USER_TYPE", user.UserType);
                cmd.Parameters.AddWithValue("@EMAIL", user.Email);

                if (!string.IsNullOrEmpty(user.Password))
                {
                    sentence += ", [PASSWORD] = @PASSWORD";
                    cmd.Parameters.AddWithValue("@PASSWORD", user.Password);
                }

                if (!string.IsNullOrEmpty(user.Birthday))
                {
                    sentence += ", [BIRTHDAY] = @BIRTHDAY";
                    cmd.Parameters.AddWithValue("@BIRTHDAY", user.Birthday);
                }

                if (!string.IsNullOrEmpty(user.Photo))
                {
                    sentence += ", [USER_PHOTO] = @USER_PHOTO";
                    cmd.Parameters.AddWithValue("@USER_PHOTO", user.Photo);
                }

                sentence += " WHERE [ID_USER] = @ID_USER";
                cmd.CommandText = sentence;

                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public int Delete(int idUserName)
        {
            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText =
                    "DELETE FROM [TBL_USER] WHERE [ID_USER] = @ID_USER";

                cmd.Parameters.AddWithValue("@ID_USER", idUserName);

                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public DataTable AuthenticateUser(string login, string password)
        {
            DataTable dtUser = new DataTable();

            using (SqlConnection con =
                new SqlConnection(strConnectionString))
            using (SqlCommand cmd = con.CreateCommand())
            {
                cmd.CommandText =
                    "SELECT [ID_USER], [USERNAME], [PASSWORD], " +
                    "[EMAIL], [BIRTHDAY], [USER_PHOTO], [USER_TYPE] " +
                    "FROM [TBL_USER] " +
                    "WHERE [USERNAME] = @USERNAME " +
                    "AND [PASSWORD] = @PASSWORD";

                cmd.Parameters.AddWithValue("@USERNAME", login);
                cmd.Parameters.AddWithValue("@PASSWORD", password);

                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dtUser);
                }
            }

            return dtUser;
        }
    }
}