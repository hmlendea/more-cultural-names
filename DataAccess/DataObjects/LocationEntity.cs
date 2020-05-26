using System.Collections.Generic;
using System.Xml.Serialization;

using NuciDAL.DataObjects;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    public class LocationEntity : EntityBase
    {
        public string GeoNamesId { get; set; }

        [XmlArrayItem("LocationId")]
        public List<string> FallbackLocations { get; set; }

        public List<LocationGameIdEntity> GameIds { get; set; }

        public List<LocationNameEntity> Names { get; set; }
    }
}
