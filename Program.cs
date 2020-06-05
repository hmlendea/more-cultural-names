using System;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

using NuciDAL.Repositories;

using DynamicNamesModGenerator.Configuration;
using DynamicNamesModGenerator.DataAccess.DataObjects;
using DynamicNamesModGenerator.Service.ModBuilders;
using DynamicNamesModGenerator.Service.ModBuilders.CrusaderKings2;

namespace DynamicNamesModGenerator
{
    public class Program
    {
        /// <summary>
        /// The entry point of the program, where the program control starts and ends.
        /// </summary>
        /// <param name="args">CLI arguments</param>
        public static void Main(string[] args)
        {
            IConfiguration config = LoadConfiguration();

            DataStoreSettings dataStoreSettings = new DataStoreSettings();
            OutputSettings outputSettings = new OutputSettings();

            config.Bind(nameof(DataStoreSettings), dataStoreSettings);
            config.Bind(nameof(OutputSettings), outputSettings);

            IServiceProvider serviceProvider = new ServiceCollection()
                .AddSingleton(dataStoreSettings)
                .AddSingleton(outputSettings)
                .AddSingleton<IRepository<LanguageEntity>>(s => new XmlRepository<LanguageEntity>(dataStoreSettings.LanguageStorePath))
                .AddSingleton<IRepository<LocationEntity>>(s => new XmlRepository<LocationEntity>(dataStoreSettings.TitleStorePath))
                .AddSingleton<IModBuilder, ImperatorRomeModBuilder>()
                .BuildServiceProvider();
            
            IModBuilder ck2Builder = serviceProvider.GetService<IModBuilder>();
            ck2Builder.Build();
        }
        
        static IConfiguration LoadConfiguration()
        {
            return new ConfigurationBuilder()
                .AddJsonFile("appsettings.json", true, true)
                .Build();
        }
    }
}
