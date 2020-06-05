using System;
using System.Collections.Generic;
using System.Linq;

using NuciDAL.Repositories;

using DynamicNamesModGenerator.Configuration;
using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Mapping;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.ModBuilders.CrusaderKings2
{
    public sealed class CK2ModBuilder : ModBuilder
    {
        public override string Game => "CK2HIP";

        public CK2ModBuilder(
            IRepository<LanguageEntity> languageRepository,
            IRepository<LocationEntity> locationRepository,
            OutputSettings outputSettings)
            : base(languageRepository, locationRepository, outputSettings)
        {
        }

        public override void Build()
        {
            IEnumerable<Location> locations = locationRepository.GetAll().ToServiceModels();
            IEnumerable<Language> languages = languageRepository.GetAll().ToServiceModels();

            foreach (Location location in locations.Where(x => x.GameIds.Any(y => y.Game == Game)))
            {
                foreach (GameId locationGameId in location.GameIds.Where(x => x.Game == Game))
                {
                    Console.WriteLine($"{locationGameId.Id} = {{");

                    foreach (LocationName name in location.Names)
                    {
                        Language language = languages.First(x => x.Id == name.LanguageId);

                        foreach (GameId languageGameId in language.GameIds.Where(x => x.Game == Game))
                        {
                            Console.WriteLine($"    {languageGameId.Id} = \"{name.Value}\"");
                        }
                    }

                    Console.WriteLine($"}}");
                }
            }
        }
    }
}
