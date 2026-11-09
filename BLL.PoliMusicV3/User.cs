using System.Data;

namespace BLL.PoliMusicV3
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
            return new DAL.PoliMusicV3.User(strConnectionString)
                .Save(user);
        }

        public DataTable Read()
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .Read();
        }

        public int Update(EntityLayer.PoliMusicV3.User user)
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .Update(user);
        }

        public int Delete(int id)
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .Delete(id);
        }

        public DataTable AuthenticateUser(string login, string password)
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .AuthenticateUser(login, password);
        }

        public int CheckExistUser(string userName)
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .CheckExistUser(userName);
        }

        public int CheckExistEmail(string email)
        {
            return new DAL.PoliMusicV3.User(strConnectionString)
                .CheckExistEmail(email);
        }

        public string ValidationsDuplicated(
            EntityLayer.PoliMusicV3.User user)
        {
            if (CheckExistUser(user.UserName) != 0)
            {
                return "Username already registered!";
            }

            if (CheckExistEmail(user.Email) != 0)
            {
                return "Email already used!.";
            }

            return string.Empty;
        }
    }
}