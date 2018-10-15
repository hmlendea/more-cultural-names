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
        public void TestFileEncodings()
        {
            List<string> landedTitlesFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();

            landedTitlesFiles.ForEach(file => Assert.IsTrue(EncodingChecker.IsWindows1252(file)));
        }
    }
}
