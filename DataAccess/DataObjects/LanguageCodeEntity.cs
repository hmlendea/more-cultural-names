using System.Xml.Serialization;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("LanguageCode")]
    public class LanguageCodeEntity
    {
        [XmlAttribute("iso-639-1")]
        public string ISO_639_1 { get; set; }
        
        [XmlAttribute("iso-639-2")]
        public string ISO_639_2 { get; set; }
        
        [XmlAttribute("iso-639-3")]
        public string ISO_639_3 { get; set; }
    }
}
