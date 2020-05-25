using System.Collections.Generic;

namespace DynamicNamesModGenerator.Service.Models
{
    public sealed class Location
    {
        public string Id { get; set; }

        public string GeoNamesId { get; set; }

        public IDictionary<string, string> Names { get; set; }
    }
}
