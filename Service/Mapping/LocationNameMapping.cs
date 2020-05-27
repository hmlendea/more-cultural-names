using System.Collections.Generic;
using System.Linq;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.Mapping
{
    static class LocationNameMapping
    {
        internal static LocationName ToServiceModel(this LocationNameEntity dataObject)
        {
            LocationName serviceModel = new LocationName();
            serviceModel.LanguageId = dataObject.LanguageId;
            serviceModel.Value = dataObject.Value;

            return serviceModel;
        }

        internal static LocationNameEntity ToDataObject(this LocationName serviceModel)
        {
            LocationNameEntity dataObject = new LocationNameEntity();
            dataObject.LanguageId = serviceModel.LanguageId;
            dataObject.Value = serviceModel.Value;

            return dataObject;
        }

        internal static IEnumerable<LocationName> ToServiceModels(this IEnumerable<LocationNameEntity> dataObjects)
        {
            IEnumerable<LocationName> serviceModels = dataObjects.Select(dataObject => dataObject.ToServiceModel());

            return serviceModels;
        }

        internal static IEnumerable<LocationNameEntity> ToDataObjects(this IEnumerable<LocationName> serviceModels)
        {
            IEnumerable<LocationNameEntity> dataObjects = serviceModels.Select(serviceModel => serviceModel.ToDataObject());

            return dataObjects;
        }
    }
}
