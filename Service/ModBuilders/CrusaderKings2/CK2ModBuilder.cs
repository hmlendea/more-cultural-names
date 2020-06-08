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
    public sealed class CK2ModBuilder : ModBuilder, ICK2ModBuilder
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
            List<Localisation> localisations = GetLocalisations();

            Dictionary<string, List<Localisation>> localisationsByLocation = localisations
                .GroupBy(x => x.LocationId)
                .OrderBy(x => x.Key)
                .ToDictionary(x => x.Key, x => x.ToList());

            foreach (string locationId in localisationsByLocation.Keys)
            {
                Console.WriteLine($"{locationId} = {{");

                foreach (Localisation localisation in localisationsByLocation[locationId])
                {
                    Console.WriteLine($"    {localisation.LanguageId} = \"{localisation.Name}\"");
                }

                Console.WriteLine($"}}");
            }
        }
    }
}
