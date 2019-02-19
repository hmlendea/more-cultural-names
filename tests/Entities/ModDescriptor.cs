using System.Collections.Generic;
using System.IO;
using System.Linq;

using CK2ModTests.Helpers;

namespace CK2ModTests.Entities
{
    public class ModDescriptor
    {
        public string Name { get; set; }

        public string Path { get; set; }

        public List<string> Dependencies { get; set; }

        public List<string> Tags { get; set; }

        public string Picture { get; set; }

        public bool HasPicture => !string.IsNullOrWhiteSpace(Picture);

        public static ModDescriptor FromFile(string path)
        {
            List<string> lines = File.ReadAllLines(ApplicationPaths.DescriptorFile).ToList();
            ModDescriptor descriptor = new ModDescriptor();

            // TODO: Load dependencies and tags
            descriptor.Name = GetStringValue(lines, "name");
            descriptor.Path = GetStringValue(lines, "path");
            descriptor.Picture = GetStringValue(lines, "picture");

            return descriptor;
        }

        static string GetStringValue(List<string> lines, string key)
        {
            string line = lines.FirstOrDefault(x => x.TrimStart().StartsWith(key));

            if (string.IsNullOrWhiteSpace(line))
            {
                return null;
            }

            string value = line
                .Split('=')[1]
                .Trim()
                .Replace("\"", "");

            return value;
        }
    }
}
