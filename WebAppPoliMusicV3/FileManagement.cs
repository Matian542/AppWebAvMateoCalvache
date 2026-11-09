using System;
using System.Configuration;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    public class FileManagement : Page
    {
        public string SaveImageOnServer(
            FileUpload fileUpload, string strFolder, string newFileName)
        {
            try
            {
                if (!fileUpload.HasFile)
                {
                    return "Image is required!";
                }

                string contentType = fileUpload.PostedFile.ContentType;

                if (contentType != "image/jpeg" &&
                    contentType != "image/jpg" &&
                    contentType != "image/png")
                {
                    return "Only JPEG or PNG files are accepted!";
                }

                string extension =
                    Path.GetExtension(fileUpload.FileName).ToLowerInvariant();

                if (extension != ".jpg" &&
                    extension != ".jpeg" &&
                    extension != ".png")
                {
                    return "Only JPEG or PNG files are accepted!";
                }

                if (fileUpload.PostedFile.ContentLength > 10485760)
                {
                    return "The image must be 10 MB or smaller!";
                }

                string folder = Server.MapPath(strFolder);
                Directory.CreateDirectory(folder);

                string fileName = string.IsNullOrEmpty(newFileName)
                    ? Path.GetFileNameWithoutExtension(fileUpload.FileName)
                    : newFileName;

                string destination = Path.Combine(
                    folder, Path.GetFileName(fileName) + extension);

                fileUpload.SaveAs(destination);

                return string.Empty;
            }
            catch (Exception ex)
            {
                return "The image could not be uploaded: " + ex.Message;
            }
        }

        public string SaveDefaultImageOnServer(
            string strFolder, string newFileName)
        {
            try
            {
                string folder = Server.MapPath(strFolder);
                string source = Path.Combine(folder, "default.jpg");

                if (!File.Exists(source))
                {
                    return "The default.jpg image was not found!";
                }

                string destination = Path.Combine(
                    folder, Path.GetFileName(newFileName) + ".jpg");

                File.Copy(source, destination, true);

                return string.Empty;
            }
            catch (Exception ex)
            {
                return "The default image could not be copied: " + ex.Message;
            }
        }

        public string SaveSongOnServer(
            FileUpload fileUpload, string strFolder, string newFileName)
        {
            try
            {
                if (!fileUpload.HasFile)
                {
                    return "Select a song file first!";
                }

                string contentType = fileUpload.PostedFile.ContentType;

                if (contentType != "audio/mpeg" &&
                    contentType != "audio/mpeg3" &&
                    contentType != "audio/mp3")
                {
                    return "The selected file must be an MP3!";
                }

                string extension =
                    Path.GetExtension(fileUpload.FileName).ToLowerInvariant();

                if (extension != ".mp3")
                {
                    return "Only .mp3 extensions are allowed!";
                }

                string configuredLimit =
                    ConfigurationManager.AppSettings["maxSongLength"];

                int maxFileSize = string.IsNullOrEmpty(configuredLimit)
                    ? 52428800
                    : Convert.ToInt32(configuredLimit);

                if (fileUpload.PostedFile.ContentLength > maxFileSize)
                {
                    return "Maximum song size: " +
                        (maxFileSize / 1024) + " KB.";
                }

                string folder = Server.MapPath(strFolder);
                Directory.CreateDirectory(folder);

                string fileName = string.IsNullOrEmpty(newFileName)
                    ? Path.GetFileNameWithoutExtension(fileUpload.FileName)
                    : newFileName;

                string destination = Path.Combine(
                    folder, Path.GetFileName(fileName) + extension);

                fileUpload.SaveAs(destination);

                return string.Empty;
            }
            catch (Exception ex)
            {
                return "The song could not be uploaded: " + ex.Message;
            }
        }
    }
}