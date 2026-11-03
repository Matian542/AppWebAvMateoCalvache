using System;
using System.Security.Cryptography;
using System.Text;

namespace WebAppPoliMusicV2.Util
{
    public class Hash
    {
        /// <summary>
        /// Generates a SHA1 hash of the specified input string.
        /// </summary>
        public static string GeneratePasswordHash(string input)
        {
            using (SHA1Managed sha1 = new SHA1Managed())
            {
                byte[] hash = sha1.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder sb = new StringBuilder(hash.Length * 2);
                foreach (byte b in hash)
                {
                    // "X2" = dos caracteres hexadecimales en mayúscula
                    sb.Append(b.ToString("X2"));
                }
                return sb.ToString();
            }
        }

        /// <summary>
        /// Generates a hashed password using PBKDF2 with a random 16-byte salt and 100,000 iterations.
        /// </summary>
        public static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            new RNGCryptoServiceProvider().GetBytes(salt);

            Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000);
            byte[] hash = pbkdf2.GetBytes(20);

            byte[] hashBytes = new byte[36];
            Array.Copy(salt, 0, hashBytes, 0, 16);
            Array.Copy(hash, 0, hashBytes, 16, 20);

            return Convert.ToBase64String(hashBytes);
        }
    }
}