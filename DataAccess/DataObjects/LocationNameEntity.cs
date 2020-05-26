using System.Xml.Serialization;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("Name")]
    public class LocationNameEntity
    {
        public LocationNameEntity()
        {

        }

        public LocationNameEntity(string language, string value)
        {
            Language = language;
            Value = value;
        }
        
        [XmlAttribute("language")]
        public string Language { get; set; }

        [XmlText]
        public string Value { get; set; }
    }
}
