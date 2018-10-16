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

        const string invalidEqualsSpacingPattern = @"([^\ ]=|=[^\ ]|\ \ =|=\ \ )";
        const string invalidIndentationPattern = @"^\ [^\ ]|^\ \ [^\ ]|^\ \ \ [^\ ]|^(\ \ \ \ )*\ [^\ ]|^(\ \ \ \ )*\ \ [^\ ]|^(\ \ \ \ )*\ \ \ [^\ ]";

        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestCultureFileNamingConventions()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.CulturesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);

                Assert.IsTrue(Regex.IsMatch(file, cultureFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestDynastyFileNamingConventions()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.DynastiesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);
                
                Assert.IsTrue(Regex.IsMatch(file, dynastyFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestLandedTitlesFileNamingConventions()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);
                
                Assert.IsTrue(Regex.IsMatch(file, landedTitlesFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestLocalisationFileNamingConventions()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);
                
                Assert.IsTrue(Regex.IsMatch(file, localisationFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestCultureFilesFormatConventions()
        {
            List<string> cultureFiles = Directory.GetFiles(ApplicationPaths.CulturesDirectory).ToList();
            
            foreach (string file in cultureFiles)
            {
                List<string> lines = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                
                TestTabs(lines, file);
                TestIndentation(lines, file);
                TestEqualsSpacings(lines, file);
            }
        }

        [TestMethod]
        public void TestDynastyFilesFormatConventions()
        {
            List<string> dynastyFiles = Directory.GetFiles(ApplicationPaths.DynastiesDirectory).ToList();
            
            foreach (string file in dynastyFiles)
            {
                List<string> lines = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                
                TestTabs(lines, file);
                TestIndentation(lines, file);
                TestEqualsSpacings(lines, file);
            }
        }

        [TestMethod]
        public void TestLandedTitlesFilesFormatConventions()
        {
            List<string> landedTitlesFiles = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();
            
            foreach (string file in landedTitlesFiles)
            {
                List<string> lines = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                
                TestTabs(lines, file);
                TestIndentation(lines, file);
                TestEqualsSpacings(lines, file);
            }
        }

        [TestMethod]
        public void TestLocalisationFilesFormatConventions()
        {
            List<string> localisationFiles = Directory.GetFiles(ApplicationPaths.LocalisationDirectory).ToList();
            
            foreach (string file in localisationFiles)
            {
                List<string> lines = FileLoader.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                
                TestTabs(lines, file);
            }
        }

        void TestTabs(IEnumerable<string> lines, string file)
        {
            string fileName = Path.GetFileName(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(line.Contains("\t"), $"The '{fileName}' contains tabs, at line {lineNumber}");
            }
        }

        void TestIndentation(IEnumerable<string> lines, string file)
        {
            string fileName = Path.GetFileName(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, invalidIndentationPattern), $"Invalid indentation in the '{fileName}' file, at line {lineNumber}");
            }
        }

        void TestEqualsSpacings(IEnumerable<string> lines, string file)
        {
            string fileName = Path.GetFileName(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, invalidEqualsSpacingPattern), $"Invalid spacing around '=' in the '{fileName}' file, at line {lineNumber}");
            }
        }
    }
}
