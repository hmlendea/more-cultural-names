using System;
using System.Collections.Generic;
using System.Linq;

using NuciDAL.Repositories;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Mapping;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.ModBuilders.CrusaderKings2
{
    public sealed class CK2ModBuilder : ICK2ModBuilder
    {
        readonly IRepository<LanguageEntity> languageRepository;
        readonly IRepository<LocationEntity> locationRepository;

        public CK2ModBuilder(
            IRepository<LanguageEntity> languageRepository,
            IRepository<LocationEntity> locationRepository
        )
        {
            this.languageRepository = languageRepository;
            this.locationRepository = locationRepository;
        }

        public void Build()
        {
        }
    }
}
