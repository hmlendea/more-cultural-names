using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;

namespace CK2ModTests.Helpers
{
    public static class EncodingChecker
    {
        static readonly List<char> windows1252chars;

        static EncodingChecker()
        {
            string charsetFilePath = Path.Combine(ApplicationPaths.TestDataDirectory, "windows1252chars.txt");

            windows1252chars = FileProvider.ReadAllText(FileEncoding.Windows1252, charsetFilePath).ToCharArray().ToList();
        }

        public static bool IsWindows1252(string path)
        {
            string content = null;

            using (StreamReader reader = new StreamReader(path, Encoding.GetEncoding(1252), true))
            {
                content = reader.ReadToEnd();
            }

            foreach (char c in content)
            {
                if (!IsWindows1252(c))
                {
                    return false;
                }
            }

            return true;
        }

        public static bool IsWindows1252(char c)
        {
            if (!windows1252chars.Contains(c))
            {
                return false;
            }

            return true;
        }
    }
}