using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using McnTests.Entities;
using McnTests.Helpers;

namespace McnTests.Tests
{
    [TestClass]
    public class FormatConventionsTests
    {
        const string cultureFileNamePattern = @"zzz_.*\.txt";
        const string dynastyFileNamePattern = @"99_.*_dynasties\.txt";
        const string landedTitlesFileNamePattern = @"zzz_.*\.txt";
        const string localisationFileNamePattern = @"0_.*\.csv";

        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestFileNamesAndExtensions()
        {
            List<string> culturesFiles = Directory.GetFiles(ApplicationPaths.CulturesDirectory).ToList();
            List<string> dynastiesFiles = Directory.GetFiles(ApplicationPaths.DynastiesDirectory).ToList();
            List<string> landedTitlesFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();
            List<string> localisationFiles = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            culturesFiles.ForEach(file => Assert.IsTrue(Regex.IsMatch(file, cultureFileNamePattern)));
            dynastiesFiles.ForEach(file => Assert.IsTrue(Regex.IsMatch(file, dynastyFileNamePattern)));
            landedTitlesFiles.ForEach(file => Assert.IsTrue(Regex.IsMatch(file, landedTitlesFileNamePattern)));
            localisationFiles.ForEach(file => Assert.IsTrue(Regex.IsMatch(file, localisationFileNamePattern)));
        }

        [TestMethod]
        public void TestTabs()
        {
            List<string> cultureFiles = Directory.GetFiles(ApplicationPaths.CulturesDirectory).ToList();
            List<string> dynastyFiles = Directory.GetFiles(ApplicationPaths.DynastiesDirectory).ToList();
            List<string> landedTitleFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();
            List<string> localisationFiles = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            List<string> allFiles = cultureFiles.Concat(dynastyFiles).Concat(landedTitleFiles).Concat(localisationFiles).ToList();

            foreach (string file in allFiles)
            {
                string content = null;

                using (StreamReader reader = new StreamReader(file, Encoding.GetEncoding(1252), true))
                {
                    content = reader.ReadToEnd();
                }

                Assert.IsFalse(content.Contains("\t"));
            }
        }
    }
}
