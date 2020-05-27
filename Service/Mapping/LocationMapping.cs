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
            serviceModel.GameIds = dataObject.GameIds.ToServiceModels();
            serviceModel.FallbackLocations = dataObject.FallbackLocations;
            serviceModel.Names = dataObject.Names.ToServiceModels();

            return serviceModel;
        }

        internal static LocationEntity ToDataObject(this Location serviceModel)
        {
            LocationEntity dataObject = new LocationEntity();
            dataObject.Id = serviceModel.Id;
            dataObject.GeoNamesId = serviceModel.GeoNamesId;
            dataObject.GameIds = serviceModel.GameIds.ToDataObjects().ToList();
            dataObject.FallbackLocations = serviceModel.FallbackLocations.ToList();
            dataObject.Names = serviceModel.Names.ToDataObjects().ToList();

            return dataObject;
        }

        internal static IEnumerable<Location> ToServiceModels(this IEnumerable<LocationEntity> dataObjects)
        {
            IEnumerable<Location> serviceModels = dataObjects.Select(dataObject => dataObject.ToServiceModel());

            return serviceModels;
        }

        internal static IEnumerable<LocationEntity> ToDataObjects(this IEnumerable<Location> serviceModels)
        {
            IEnumerable<LocationEntity> dataObjects = serviceModels.Select(serviceModel => serviceModel.ToDataObject());

            return dataObjects;
        }
    }
}
