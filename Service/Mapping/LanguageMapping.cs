using System.Collections.Generic;
using System.Linq;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.Mapping
{
    static class LanguageMapping
    {
        internal static Language ToServiceModel(this LanguageEntity dataObject)
        {
            Language serviceModel = new Language();
            serviceModel.Id = dataObject.Id;
            serviceModel.Code = dataObject.Code?.ToServiceModel();
            serviceModel.GameIds = dataObject.GameIds.Select(x => new KeyValuePair<string, string>(x.Game, x.Value)).ToList();

            return serviceModel;
        }

        internal static LanguageEntity ToDataObject(this Language serviceModel)
        {
            LanguageEntity dataObject = new LanguageEntity();
            dataObject.Id = serviceModel.Id;
            dataObject.Code = serviceModel.Code?.ToDataObject();
            dataObject.GameIds = serviceModel.GameIds.Select(x => new GameIdEntity(x.Key, x.Value)).ToList();

            return dataObject;
        }

        internal static IEnumerable<Language> ToServiceModels(this IEnumerable<LanguageEntity> dataObjects)
        {
            IEnumerable<Language> serviceModels = dataObjects.Select(dataObject => dataObject.ToServiceModel());

            return serviceModels;
        }

        internal static IEnumerable<LanguageEntity> ToEntities(this IEnumerable<Language> serviceModels)
        {
            IEnumerable<LanguageEntity> dataObjects = serviceModels.Select(serviceModel => serviceModel.ToDataObject());

            return dataObjects;
        }
    }
}
