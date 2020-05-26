using System.Xml.Serialization;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("GameId")]
    public class LocationGameIdEntity
    {
        public LocationGameIdEntity()
        {

        }

        public LocationGameIdEntity(string game, string value)
        {
            Game = game;
            Value = value;
        }
        
        [XmlAttribute("game")]
        public string Game { get; set; }

        [XmlText]
        public string Value { get; set; }
    }
}
