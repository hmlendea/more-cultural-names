using NuciDAL.Repositories;

using DynamicNamesModGenerator.DataAccess.DataObjects;

namespace DynamicNamesModGenerator.Service.ModBuilders
{
    public abstract class ModBuilder : IModBuilder
    {
        public virtual string Game { get; protected set; }

        protected readonly IRepository<LanguageEntity> languageRepository;
        protected readonly IRepository<LocationEntity> locationRepository;

        public ModBuilder(
            IRepository<LanguageEntity> languageRepository,
            IRepository<LocationEntity> locationRepository
        )
        {
            this.languageRepository = languageRepository;
            this.locationRepository = locationRepository;
        }

        public virtual void Build()
        {

        }
    }
}
