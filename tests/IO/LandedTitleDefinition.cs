using System;
using System.Collections.Generic;
using System.Linq;

using CK2ModTests.Entities;
using CK2ModTests.Extensions;

using Pdoxcl2Sharp;

namespace CK2ModTests.IO
{
    public sealed class LandedTitleDefinition : IParadoxRead, IParadoxWrite
    {
        public LandedTitle LandedTitle { get; set; }

        public LandedTitleDefinition()
        {
            LandedTitle = new LandedTitle();
        }
        
        public void TokenCallback(ParadoxParser parser, string token)
        {
            if (token[1] == '_') // Like e_something or c_something
            {
                LandedTitleDefinition landedTitle = new LandedTitleDefinition();
                landedTitle.LandedTitle.ParentId = LandedTitle.Id;
                landedTitle.LandedTitle.Id = token;

                LandedTitle.Children.Add(parser.Parse(landedTitle).LandedTitle);
                return;
            }

            switch (token)
            {
                // TODO: Implement these
                case "allow":
                case "assimilate":
                case "caliphate":
                case "capital":
                case "coat_of_arms":
                case "color":
                case "color2":
                case "controls_religion":
                case "creation_requires_capital":
                case "culture":
                case "dignity":
                case "gain_effect":
                case "graphical_culture":
                case "has_top_de_jure_capital":
                case "holy_order":
                case "holy_site":
                case "independent":
                case "landless":
                case "location_ruler_title":
                case "mercenary_type":
                case "mercenary":
                case "monthly_income":
                case "pagan_coa":
                case "pirate":
                case "primary":
                case "purple_born_heirs":
                case "religion":
                case "strength_growth_per_century":
                case "tribe":
                    parser.ReadInsideBrackets((p) => { });
                    throw new FormatException($"Disallowed landed title token '{token}'");

                case "dynasty_title_names":
                    LandedTitle.UseDynastyTitleNames = parser.ReadBool();
                    break;

                case "female_names":
                    LandedTitle.FemaleNames = parser.ReadStringList();
                    break;

                case "foa":
                    LandedTitle.TitleFormOfAddress = parser.ReadString();
                    break;

                case "male_names":
                    LandedTitle.MaleNames = parser.ReadStringList();
                    break;

                case "name_tier":
                    LandedTitle.TitleNameTierId = parser.ReadString();
                    break;

                case "short_name":
                    LandedTitle.UseShortName = parser.ReadBool();
                    break;

                case "title":
                    LandedTitle.TitleLocalisationId = parser.ReadString();
                    break;

                case "title_female":
                    LandedTitle.TitleLocalisationFemaleId = parser.ReadString();
                    break;

                case "title_prefix":
                    LandedTitle.TitleLocalisationPrefixId = parser.ReadString();
                    break;

                default:
                    string stringValue = parser.ReadString();
                    int intValue;

                    if (!int.TryParse(stringValue, out intValue))
                    {
                        LandedTitle.DynamicNames.AddOrUpdate(token, stringValue);
                    }

                    break;
            }
        }
        
        public void Write(ParadoxStreamWriter writer)
        {
            List<KeyValuePair<string, string>> sortedDynamicNames = LandedTitle.DynamicNames.ToList().OrderBy(x => x.Key).ToList();

            foreach(var dynamicName in sortedDynamicNames)
            {
                writer.WriteLine(dynamicName.Key, dynamicName.Value, ValueWrite.Quoted);
            }

            foreach (LandedTitle landedTitle in LandedTitle.Children)
            {
                LandedTitleDefinition landedTitleDefinition = new LandedTitleDefinition
                {
                    LandedTitle = landedTitle
                };

                writer.Write(landedTitle.Id, landedTitleDefinition);
            }
        }
    }
}
