using System.Collections.Generic;
using System.IO;
using System.Linq;

using CK2ModTests.Entities;

using Pdoxcl2Sharp;

namespace CK2ModTests.IO
{
    public sealed class LandedTitlesFile : IParadoxRead
    {
        public IList<LandedTitleDefinition> LandedTitles { get; set; }

        public LandedTitlesFile()
        {
            LandedTitles = new List<LandedTitleDefinition>();
        }

        public void TokenCallback(ParadoxParser parser, string token)
        {
            LandedTitleDefinition landedTitle = new LandedTitleDefinition();
            landedTitle.LandedTitle.Id = token;

            LandedTitles.Add(parser.Parse(landedTitle));
        }

        public static IEnumerable<LandedTitle> ReadAllTitles(string fileName)
        {
            LandedTitlesFile landedTitlesFile;
            
            using (FileStream fs = new FileStream(fileName, FileMode.Open))
            {
                landedTitlesFile = ParadoxParser.Parse(fs, new LandedTitlesFile());
            }
            
            return landedTitlesFile.LandedTitles.Select(x => x.LandedTitle);
        }
    }
}
