using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace CK2ModTests.Helpers
{
    public static class FileProvider
    {
        public static IEnumerable<string> GetFilesInDirectory(string path)
        {
            IEnumerable<string> files = new List<string>();

            if (Directory.Exists(path))
            {
                files = Directory.GetFiles(path);
            }

            return files;
        }
        public static string ReadAllText(FileEncoding encoding, string path, bool loadComments = false)
        {
            string content = null;

            using (StreamReader reader = new StreamReader(path, GetEncoding(encoding), true))
            {
                content = reader.ReadToEnd();
            }

            if (!loadComments)
            {
                // TODO: Implement this
            }

            return content;
        }

        public static IEnumerable<string> ReadAllLines(FileEncoding encoding, string path, bool loadComments = false)
        {
            IList<string> completeLines = new List<string>();

            using (StreamReader reader = new StreamReader(path, GetEncoding(encoding), true))
            {
                string line;

                while ((line = reader.ReadLine()) != null)
                {
                    completeLines.Add(line);
                }
            }

            if (loadComments)
            {
                return completeLines;
            }
            
            IList<string> lines = new List<string>();

            foreach (string completeLine in completeLines)
            {
                string line = completeLine;

                if (line.Contains('#'))
                {
                    line = line.Substring(0, line.IndexOf('#'));
                }

                lines.Add(line);
            }

            return lines;
        }

        private static Encoding GetEncoding(FileEncoding fileEncoding)
        {
            Encoding encoding = null;

            switch (fileEncoding)
            {
                case FileEncoding.Windows1252:
                    encoding = Encoding.GetEncoding(1252);
                    break;
            }

            return encoding;
        }
    }
}
