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
        public void TestLandedTitleFilesIntegrity()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);

                List<string> lines = FileLoader
                    .ReadAllLines(FileEncoding.Windows1252, file)
                    .Select(line => GetLineWithoutComments(line))
                    .ToList();

                string content = string.Join(Environment.NewLine, lines);

                int openingBrackets = content.Count(x => x == '{');
                int closingBrackets = content.Count(x => x == '}');

                Assert.AreEqual(openingBrackets, closingBrackets, $"There are mismatching brackets in {fileName}");
            }
        }

        [TestMethod]
        public void TestLocalisationFilesIntegrity()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);

                List<string> lines = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();

                int lineNumber = 0;

                foreach(string completeLine in lines)
                {
                    lineNumber += 1;

                    string line = GetLineWithoutComments(completeLine);

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

        string GetLineWithoutComments(string line)
        {
            if (line.Contains('#'))
            {
                return line.Substring(0, line.IndexOf('#'));
            }

            return line;
        }
    }
}
