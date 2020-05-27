using System.Collections.Generic;
using System.Linq;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.Mapping
{
    static class LocationMapping
    {
        internal static Location ToServiceModel(this LocationEntity dataObject)
        {
            Location serviceModel = new Location();
            serviceModel.Id = dataObject.Id;
            serviceModel.GeoNamesId = dataObject.GeoNamesId;
            serviceModel.GameIds = dataObject.GameIds.Select(x => new KeyValuePair<string, string>(x.Game, x.Value)).ToList();
            serviceModel.FallbackLocations = dataObject.FallbackLocations;
            serviceModel.Names = dataObject.Names.ToDictionary(x => x.Language, x => x.Value);

            return serviceModel;
        }

        internal static LocationEntity ToDataObject(this Location serviceModel)
        {
            LocationEntity dataObject = new LocationEntity();
            dataObject.Id = serviceModel.Id;
            dataObject.GeoNamesId = serviceModel.GeoNamesId;
            dataObject.GameIds = serviceModel.GameIds.Select(x => new GameIdEntity(x.Key, x.Value)).ToList();
            dataObject.FallbackLocations = serviceModel.FallbackLocations.ToList();
            dataObject.Names = serviceModel.Names.Select(x => new LocationNameEntity(x.Key, x.Value)).ToList();

            return dataObject;
        }

        internal static IEnumerable<Location> ToServiceModels(this IEnumerable<LocationEntity> dataObjects)
        {
            IEnumerable<Location> serviceModels = dataObjects.Select(dataObject => dataObject.ToServiceModel());

            return serviceModels;
        }

        internal static IEnumerable<LocationEntity> ToEntities(this IEnumerable<Location> serviceModels)
        {
            IEnumerable<LocationEntity> dataObjects = serviceModels.Select(serviceModel => serviceModel.ToDataObject());

            return dataObjects;
        }
    }
}
