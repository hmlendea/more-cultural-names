using System.Collections.Generic;

namespace DynamicNamesModGenerator.Service.Models
{
    public sealed class Location
    {
        public string Id { get; set; }

        public string GeoNamesId { get; set; }

        public IList<KeyValuePair<string, string>> GameIds { get; set; }

        public IList<string> FallbackLocations { get; set; }

        public IDictionary<string, string> Names { get; set; }
    }
}
