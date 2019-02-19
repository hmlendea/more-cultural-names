using System.Collections.Generic;

namespace CK2ModTests.Entities
{
    public class LandedTitle
    {
        public string Id { get; set; }

        public string ParentId { get; set; }

        public IList<LandedTitle> Children { get; set; }

        /// <summary>
        /// Gets or sets the female names.
        /// </summary>
        /// <value>The female names.</value>
        public IList<string> FemaleNames { get; set; }

        /// <summary>
        /// Gets or sets the male names.
        /// </summary>
        /// <value>The male banes.</value>
        public IList<string> MaleNames { get; set; }

        public IDictionary<string, string> DynamicNames { get; set; }

        public string TitleFormOfAddress { get; set; }

        public string TitleLocalisationId { get; set; }

        public string TitleLocalisationFemaleId { get; set; }

        public string TitleLocalisationPrefixId { get; set; }

        public string TitleNameTierId { get; set; }

        public bool UseDynastyTitleNames { get; set; }

        public bool UseShortName { get; set; }

        public LandedTitle()
        {
            Children = new List<LandedTitle>();
            FemaleNames = new List<string>();
            MaleNames = new List<string>();

            DynamicNames = new Dictionary<string, string>();
        }
    }
}
