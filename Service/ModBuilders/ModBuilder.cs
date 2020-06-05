using System.IO;

using NuciDAL.Repositories;

using DynamicNamesModGenerator.Configuration;
using DynamicNamesModGenerator.DataAccess.DataObjects;

namespace DynamicNamesModGenerator.Service.ModBuilders
{
    public abstract class ModBuilder : IModBuilder
    {
        public virtual string Game { get; protected set; }

        protected string OutputDirectoryPath => Path.Combine(outputSettings.ModOutputDirectory, Game);

        protected readonly IRepository<LanguageEntity> languageRepository;
        protected readonly IRepository<LocationEntity> locationRepository;

        protected readonly OutputSettings outputSettings;

        public ModBuilder(
            IRepository<LanguageEntity> languageRepository,
            IRepository<LocationEntity> locationRepository,
            OutputSettings outputSettings)
        {
            this.languageRepository = languageRepository;
            this.locationRepository = locationRepository;

            this.outputSettings = outputSettings;
        }

        public virtual void Build()
        {

        }
    }
}
