using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using McnTests.Entities;
using McnTests.Helpers;

namespace McnTests.Tests
{
    [TestClass]
    public class ModStructureIntegrityTests
    {
        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestModDirectories()
        {
            Assert.IsTrue(Directory.Exists(ApplicationPaths.CommonDirectory), "The 'common' directory is missing");
            Assert.IsTrue(Directory.Exists(ApplicationPaths.CulturesDirectory), "The 'common/cultures' directory is missing");
            Assert.IsTrue(Directory.Exists(ApplicationPaths.DynastiesDirectory), "The 'common/dynasties' directory is missing");
            Assert.IsTrue(Directory.Exists(ApplicationPaths.LandedTitlesDirectory), "The 'common/landed_titles' directory is missing");
            Assert.IsTrue(Directory.Exists(ApplicationPaths.LocalisationDirectory), "The 'localisation' directory is missing");
        }

        [TestMethod]
        public void TestModDescriptor()
        {
            Assert.IsTrue(File.Exists(ApplicationPaths.DescriptorFile), "The mod descriptor file is missing");

            ModDescriptor descriptor = ModDescriptor.FromFile(ApplicationPaths.DescriptorFile);

            string picturePath = Path.Combine(ApplicationPaths.ModDirectory, descriptor.Picture);

            Assert.IsTrue(File.Exists(picturePath), $"The mod picture ({descriptor.Picture}) is missing");
            Assert.AreEqual($"mod/{Path.GetFileName(ApplicationPaths.ModDirectory)}", descriptor.Path, "The mod name defined in the descriptor, and the mod directory name do not match");
        }

        [TestMethod]
        public void AssertEncodings()
        {
            List<string> landedTitlesFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();

            landedTitlesFiles.ForEach(file => Assert.IsTrue(EncodingChecker.IsWindows1252(file)));

            foreach (string file in landedTitlesFiles)
            {
                Assert.IsTrue(EncodingChecker.IsWindows1252(file));
            }
        }
    }
}
