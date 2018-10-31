using System.IO;

using McnTests.Helpers;

namespace McnTests.Extensions
{
    /// <summary>
    /// Path extensions.
    /// </summary>
    public static class PathExt
    {
        public static string GetFileNameWithoutRootDirectory(string path)
        {
            string result = path;

            if (path.StartsWith(ApplicationPaths.RootDirectory))
            {
                result = path.Replace(ApplicationPaths.RootDirectory, "");
            }

            if (result.StartsWith('/') ||
                result.StartsWith('\\'))
            {
                result = result.Substring(1);
            }

            return result;
        }
    }
}
