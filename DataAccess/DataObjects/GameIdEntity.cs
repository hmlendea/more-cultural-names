using System.Xml.Serialization;

namespace DynamicNamesModGenerator.DataAccess.DataObjects
{
    [XmlType("GameId")]
    public class GameIdEntity
    {
        public GameIdEntity()
        {

        }

        public GameIdEntity(string game, string gameLocationId)
        {
            Game = game;
            Id = gameLocationId;
        }
        
        [XmlAttribute("game")]
        public string Game { get; set; }

        [XmlText]
        public string Id { get; set; }
    }
}
