using System;
using System.Collections.Generic;
using System.Linq;

using NuciDAL.Repositories;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Mapping;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.ModBuilders.CrusaderKings2
{
    public sealed class ImperatorRomeModBuilder : ModBuilder
    {
        public override string Game => "ImperatorRome";

        public ImperatorRomeModBuilder(
            IRepository<LanguageEntity> languageRepository,
            IRepository<LocationEntity> locationRepository
        ) : base(languageRepository, locationRepository)
        {
        }

        public override void Build()
        {
            List<Localisation> localisations = GetLocalisations();

            Console.WriteLine("l_english:");

            foreach(Localisation localisation in localisations
                .OrderBy(x => int.Parse(x.LocationId)))
            {
                Console.WriteLine($"  PROV{localisation.LocationId}_{localisation.LanguageId}:0 \"{localisation.Name}\"");
            }
        }

        List<Localisation> GetLocalisations()
        {
            IEnumerable<Location> locations = locationRepository.GetAll().ToServiceModels();
            IEnumerable<Language> languages = languageRepository.GetAll().ToServiceModels();

            List<Localisation> localisations = new List<Localisation>();

            foreach (Location location in locations.Where(x => x.GameIds.Any(y => y.Game == Game)))
            {
                foreach (GameId locationGameId in location.GameIds.Where(x => x.Game == Game))
                {
                    foreach (LocationName name in location.Names)
                    {
                        Language language = languages.First(x => x.Id == name.LanguageId);

                        foreach (GameId languageGameId in language.GameIds.Where(x => x.Game == Game))
                        {
                            Localisation localisation = new Localisation();
                            localisation.LocationId = locationGameId.Id;
                            localisation.LanguageId = languageGameId.Id;
                            localisation.Name = name.Value;

                            localisations.Add(localisation);
                        }
                    }
                }
            }

            return localisations;
        }
    }
}
