using System.Collections.Generic;
using System.Linq;

using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.Models;

namespace DynamicNamesModGenerator.Service.Mapping
{
    static class GameIdMapping
    {
        internal static GameId ToServiceModel(this GameIdEntity dataObject)
        {
            GameId serviceModel = new GameId();
            serviceModel.Game = dataObject.Game;
            serviceModel.Id = dataObject.Id;

            return serviceModel;
        }

        internal static GameIdEntity ToDataObject(this GameId serviceModel)
        {
            GameIdEntity dataObject = new GameIdEntity();
            dataObject.Game = serviceModel.Game;
            dataObject.Id = serviceModel.Id;

            return dataObject;
        }

        internal static IEnumerable<GameId> ToServiceModels(this IEnumerable<GameIdEntity> dataObjects)
        {
            IEnumerable<GameId> serviceModels = dataObjects.Select(dataObject => dataObject.ToServiceModel());

            return serviceModels;
        }

        internal static IEnumerable<GameIdEntity> ToDataObjects(this IEnumerable<GameId> serviceModels)
        {
            IEnumerable<GameIdEntity> dataObjects = serviceModels.Select(serviceModel => serviceModel.ToDataObject());

            return dataObjects;
        }
    }
}
