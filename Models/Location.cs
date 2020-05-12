using System.Collections.Generic;

namespace DynamicNamesModGenerator.Models
{
    public sealed class Location
    {
        public string Id { get; set; }

        public IDictionary<string, string> Names { get; set; }
    }
}
