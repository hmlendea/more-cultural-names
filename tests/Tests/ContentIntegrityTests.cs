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
    public class ContentIntegrityTests
    {
        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestLocalisationFilesIntegrity()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);

                List<string> content = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();

                int lineNumber = 0;

                foreach(string completeLine in content)
                {
                    lineNumber += 1;

                    string line = completeLine;

                    if (completeLine.Contains('#'))
                    {
                        line = completeLine.Substring(0, completeLine.IndexOf('#'));
                    }

                    if (string.IsNullOrWhiteSpace(line))
                    {
                        continue;
                    }
                    
                    string[] fields = line.Split(';');
                    
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[0]), $"Code is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[1]), $"English is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[2]), $"French is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[3]), $"German is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[5]), $"Spanish is undefined in {fileName} at line {lineNumber}");

                    //Assert.AreEqual(fields[1], fields[2], "French localisation is different from english in {fileName} at line {lineNumber}");
                    //Assert.AreEqual(fields[1], fields[3], "German localisation is different from english in {fileName} at line {lineNumber}");
                    //Assert.AreEqual(fields[1], fields[5], "Spanish localisation is different from english in {fileName} at line {lineNumber}");
                }
            }
        }
    }
}
