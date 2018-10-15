using System.Collections.Generic;
using System.IO;
using System.Text;

namespace McnTests.Helpers
{
    public static class FileLoader
    {
        public static string ReadAllText(FileEncoding encoding, string path)
        {
            using (StreamReader reader = new StreamReader(path, GetEncoding(encoding), true))
            {
                return reader.ReadToEnd();
            }
        }

        public static IEnumerable<string> ReadAllLines(FileEncoding encoding, string path)
        {
            IList<string> lines = new List<string>();

            using (StreamReader reader = new StreamReader(path, GetEncoding(encoding), true))
            {
                string line;

                while ((line = reader.ReadLine()) != null)
                {
                    lines.Add(line);
                }
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
