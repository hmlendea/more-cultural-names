using System.Xml.Serialization;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("GameId")]
    public class GameIdEntity
    {
        public GameIdEntity()
        {

        }

        public GameIdEntity(string game, string value)
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
