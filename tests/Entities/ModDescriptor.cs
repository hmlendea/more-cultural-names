using System.Collections.Generic;
using System.IO;
using System.Linq;

using McnTests.Helpers;

namespace McnTests.Entities
{
    public class ModDescriptor
    {
        public string Name { get; set; }

        public string Path { get; set; }

        public List<string> Dependencies { get; set; }

        public List<string> Tags { get; set; }

        public string Picture { get; set; }

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
            string value = lines.FirstOrDefault(x => x.StartsWith(key))
                                .Split('=')[1]
                                .Trim();

            return value.Replace("\"", "");
        }
    }
}