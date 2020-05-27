using System.Collections.Generic;
using System.Xml.Serialization;

using NuciDAL.DataObjects;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("Language")]
    public class LanguageEntity : EntityBase
    {
        public LanguageCodeEntity Code { get; set; }
        
        public List<GameIdEntity> GameIds { get; set; }

        public List<LocationNameEntity> Names { get; set; }
    }
}
