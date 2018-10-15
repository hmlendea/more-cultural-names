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
    public class ModStructureIntegrityTests
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
        public void TestModDirectories()
        {
            Assert.IsTrue(Directory.Exists(ApplicationPaths.CommonDirectory));
            Assert.IsTrue(Directory.Exists(ApplicationPaths.CulturesDirectory));
            Assert.IsTrue(Directory.Exists(ApplicationPaths.DynastiesDirectory));
            Assert.IsTrue(Directory.Exists(ApplicationPaths.LandedTitlesDirectory));
            Assert.IsTrue(Directory.Exists(ApplicationPaths.LocalisationDirectory));
        }

        [TestMethod]
        public void TestModDescriptor()
        {
            Assert.IsTrue(File.Exists(ApplicationPaths.DescriptorFile));

            ModDescriptor descriptor = ModDescriptor.FromFile(ApplicationPaths.DescriptorFile);

            string picturePath = Path.Combine(ApplicationPaths.ModDirectory, descriptor.Picture);

            Assert.IsTrue(File.Exists(picturePath));
            Assert.AreEqual($"mod/{Path.GetFileName(ApplicationPaths.ModDirectory)}", descriptor.Path);
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
        public void TestFileEncodings()
        {
            List<string> landedTitlesFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();

            landedTitlesFiles.ForEach(file => Assert.IsTrue(EncodingChecker.IsWindows1252(file)));
        }
    }
}
