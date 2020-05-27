using System.Collections.Generic;

namespace DynamicNamesModGenerator.Service.Models
{
    public sealed class Location
    {
        public string Id { get; set; }

        public string GeoNamesId { get; set; }

        public IEnumerable<GameId> GameIds { get; set; }

        public IEnumerable<string> FallbackLocations { get; set; }

        public IEnumerable<LocationName> Names { get; set; }
    }
}
