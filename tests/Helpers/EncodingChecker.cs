using System.IO;
using System.Text;
using System.Linq;

namespace McnTests.Helpers
{
    public static class EncodingChecker
    {
        const string windows1252chars = " \r\n\t!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ";

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