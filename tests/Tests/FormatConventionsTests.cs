using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using CK2ModTests.Entities;
using CK2ModTests.Extensions;
using CK2ModTests.Helpers;
using CK2ModTests.IO;

namespace CK2ModTests.Tests
{
    [TestClass]
    public class FormatConventionsTests
    {
        const string cultureFileNamePattern = @"zzz_.*\.txt";
        const string dynastyFileNamePattern = @"99_.*_dynasties\.txt";
        const string landedTitlesFileNamePattern = @"0_.*\.txt";
        const string localisationFileNamePattern = @"0_.*\.csv";

        const string invalidEqualsSpacingPattern = @"([^\ ]=|=[^\ ]|\ \ =|=\ \ )";
        const string invalidIndentationPattern = @"^\ [^\ ]|^\ \ [^\ ]|^\ \ \ [^\ ]|^(\ \ \ \ )*\ [^\ ]|^(\ \ \ \ )*\ \ [^\ ]|^(\ \ \ \ )*\ \ \ [^\ ]";
        const string trailingWhitespacePattern = @"\s+$";

        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestCultureFileNamingConventions()
        {
            if (!Directory.Exists(ApplicationPaths.CulturesDirectory))
            {
                return;
            }

            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.CulturesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

                Assert.IsTrue(Regex.IsMatch(file, cultureFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestDynastyFileNamingConventions()
        {
            if (!Directory.Exists(ApplicationPaths.DynastiesDirectory))
            {
                return;
            }

            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.DynastiesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);
                
                Assert.IsTrue(Regex.IsMatch(file, dynastyFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestLandedTitlesFileNamingConventions()
        {
            if (!Directory.Exists(ApplicationPaths.LandedTitlesDirectory))
            {
                return;
            }

            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.LandedTitlesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);
                
                Assert.IsTrue(Regex.IsMatch(file, landedTitlesFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestLocalisationFileNamingConventions()
        {
            if (!Directory.Exists(ApplicationPaths.LocalisationDirectory))
            {
                return;
            }

            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);
                
                Assert.IsTrue(Regex.IsMatch(file, localisationFileNamePattern), $"The '{fileName}' file's name does not respect the conventions");
            }
        }

        [TestMethod]
        public void TestCultureFilesFormatConventions()
        {
            if (!Directory.Exists(ApplicationPaths.CulturesDirectory))
            {
                return;
            }

            List<string> cultureFiles = FileProvider.GetFilesInDirectory(ApplicationPaths.CulturesDirectory).ToList();
            
            foreach (string file in cultureFiles)
            {
                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                List<string> fullLines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file, true).ToList();
                
                AssertIndentation(lines, file);
                AssertTrailingWhitespaces(fullLines, file);
                AssertRepeatedBlankLines(fullLines, file);
                AssertSpacingsAroundEquals(lines, file);
            }
        }

        [TestMethod]
        public void TestDynastyFilesFormatConventions()
        {
            List<string> dynastyFiles = FileProvider.GetFilesInDirectory(ApplicationPaths.DynastiesDirectory).ToList();
            
            foreach (string file in dynastyFiles)
            {
                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                List<string> fullLines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file, true).ToList();
                
                AssertIndentation(lines, file);
                AssertTrailingWhitespaces(fullLines, file);
                AssertRepeatedBlankLines(fullLines, file);
                AssertSpacingsAroundEquals(lines, file);
            }
        }

        [TestMethod]
        public void TestLandedTitlesFilesFormatConventions()
        {
            List<string> landedTitlesFiles = FileProvider.GetFilesInDirectory(ApplicationPaths.LandedTitlesDirectory).ToList();
            
            foreach (string file in landedTitlesFiles)
            {
                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                List<string> fullLines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file, true).ToList();

                List<LandedTitle> landedTitles = LandedTitlesFile
                    .ReadAllTitles(file)
                    .ToList();
                
                AssertIndentation(lines, file);
                AssertTrailingWhitespaces(fullLines, file);
                AssertRepeatedBlankLines(fullLines, file);
                AssertSpacingsAroundEquals(lines, file);
            }
        }

        [TestMethod]
        public void TestLocalisationFilesFormatConventions()
        {
            List<string> localisationFiles = FileProvider.GetFilesInDirectory(ApplicationPaths.LocalisationDirectory).ToList();
            
            foreach (string file in localisationFiles)
            {
                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();
                List<string> fullLines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file, true).ToList();
                
                AssertIndentation(lines, file);
                AssertTrailingWhitespaces(fullLines, file);
                AssertRepeatedBlankLines(fullLines, file);
            }
        }

        void AssertIndentation(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(line.Contains("\t"), $"The '{fileName}' contains tabs, at line {lineNumber}");
                Assert.IsFalse(Regex.IsMatch(line, invalidIndentationPattern), $"Invalid indentation in the '{fileName}' file, at line {lineNumber}");
            }
        }

        void AssertTrailingWhitespaces(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, trailingWhitespacePattern), $"The '{fileName}' file contains trailing whitespaces , at line {lineNumber}");
            }
        }

        void AssertSpacingsAroundEquals(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, invalidEqualsSpacingPattern), $"Invalid spacing around '=' in the '{fileName}' file, at line {lineNumber}");
            }
        }

        void AssertRepeatedBlankLines(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach(string line in lines)
            {
                lineNumber += 1;

                bool lastWasBlank = false;
                bool currentIsBlank = string.IsNullOrWhiteSpace(line);

                if (currentIsBlank && lineNumber > 1)
                {
                    if (string.IsNullOrWhiteSpace(lines.ElementAt(lineNumber - 2)))
                    {
                        lastWasBlank = true;
                    }
                }

                Assert.IsFalse(currentIsBlank && lastWasBlank, $"The '{fileName}' file contains repeated blank lines, at line {lineNumber}");
            }
        }

        void AssertLandedTitleDynamicNames(IEnumerable<LandedTitle> landedTitles, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            foreach (LandedTitle title in landedTitles)
            {
                Assert.IsTrue(
                    title.DynamicNames.Keys.SequenceEqual(title.DynamicNames.Keys.OrderBy(x => x)),
                    $"The '{fileName}' file contains unsorted dynamic names for {title.Id}");

                if (title.Children.Count > 0)
                {
                    AssertLandedTitleDynamicNames(title.Children, file);
                }
            }
        }
    }
}
