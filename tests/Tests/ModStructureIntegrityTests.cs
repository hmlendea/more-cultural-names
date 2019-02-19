using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using CK2ModTests.Entities;
using CK2ModTests.Extensions;
using CK2ModTests.Helpers;

namespace CK2ModTests.Tests
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
        public void TestModDescriptor()
        {
            Assert.IsTrue(File.Exists(ApplicationPaths.DescriptorFile), "The mod descriptor file is missing");

            ModDescriptor descriptor = ModDescriptor.FromFile(ApplicationPaths.DescriptorFile);

            if (descriptor.HasPicture)
            {
                string picturePath = Path.Combine(ApplicationPaths.ModDirectory, descriptor.Picture);
                Assert.IsTrue(File.Exists(picturePath), $"The mod picture ({descriptor.Picture}) is missing");
            }

            Assert.AreEqual($"mod/{Path.GetFileName(ApplicationPaths.ModDirectory)}", descriptor.Path, "The mod name defined in the descriptor, and the mod directory name do not match");
        }

        [TestMethod]
        public void AssertEncodings()
        {
            List<string> landedTitlesFiles = FileProvider.GetFilesInDirectory(ApplicationPaths.LandedTitlesDirectory).ToList();

            foreach (string file in landedTitlesFiles)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);
                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();

                int lineNumber = 0;
                foreach (string line in lines)
                {
                    lineNumber += 1;

                    int charNumber = 0;
                    foreach(char c in line)
                    {
                        Assert.IsTrue(EncodingChecker.IsWindows1252(c), $"The '{file}' file contains a non-WINDOWS-1252 character at line {lineNumber}, position {charNumber}");
                    }
                }
            }
        }
    }
}
