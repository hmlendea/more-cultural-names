using NuciDAL.Repositories;

using DynamicNamesModGenerator.DataAccess.DataObjects;

namespace DynamicNamesModGenerator.Service.ModBuilders.CrusaderKings2
{
    public sealed class CK2ModBuilder : ICK2ModBuilder
    {
        readonly IRepository<LocationEntity> locationRepository;

        public CK2ModBuilder(IRepository<LocationEntity> locationRepository)
        {
            this.locationRepository = locationRepository;
        }
    }
}
