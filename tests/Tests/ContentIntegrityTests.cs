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
    public class ContentIntegrityTests
    {
        const string InvalidQuotesPattern = "(^ *[^_]* = \"[^\"]*$|^ *[^_]* = [^\"]*\"$)";
        const string InvalidSpacingPattern = @"(^.*\ \ .*$|^\ .*$|^.*\ $)";
        const string MissingEquaitySignPattern = "^ *[a-z]* +\"[A-Za-z]*\"$";

        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestLandedTitleFilesIntegrity()
        {
            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.LandedTitlesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

                List<string> lines = FileProvider
                    .ReadAllLines(FileEncoding.Windows1252, file)
                    .ToList();

                List<LandedTitle> landedTitles = LandedTitlesFile
                    .ReadAllTitles(file)
                    .ToList();

                string content = string.Join(Environment.NewLine, lines);

                int openingBrackets = content.Count(x => x == '{');
                int closingBrackets = content.Count(x => x == '}');

                Assert.AreEqual(openingBrackets, closingBrackets, $"There are mismatching brackets in {fileName}");
                AssertLandedTitlesQuotes(lines, file);
                AssertLandedTitlesEqualSigns(lines, file);
                AssertLandedTitleDynamicNames(landedTitles, file);
            }
        }

        [TestMethod]
        public void TestLocalisationFilesIntegrity()
        {
            List<string> files = FileProvider.GetFilesInDirectory(ApplicationPaths.LocalisationDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

                List<string> lines = FileProvider.ReadAllLines(FileEncoding.Windows1252, file).ToList();

                int lineNumber = 0;

                foreach(string line in lines)
                {
                    lineNumber += 1;

                    if (string.IsNullOrWhiteSpace(line))
                    {
                        continue;
                    }

                    string[] fields = line.Split(';');

                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[0]), $"Localisation code is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[1]), $"English localisation is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[2]), $"French localisation is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[3]), $"German localisation is undefined in {fileName} at line {lineNumber}");
                    Assert.IsFalse(string.IsNullOrWhiteSpace(fields[5]), $"Spanish localisation is undefined in {fileName} at line {lineNumber}");
                }
            }
        }

        void AssertLandedTitlesQuotes(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, InvalidQuotesPattern), $"The '{fileName}' file contains invalid quotes, at line {lineNumber}");
            }
        }

        void AssertLandedTitlesEqualSigns(IEnumerable<string> lines, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, MissingEquaitySignPattern), $"The '{fileName}' file has a missing equality sign, at line {lineNumber}");
            }
        }

        void AssertLandedTitleDynamicNames(IEnumerable<LandedTitle> landedTitles, string file)
        {
            string fileName = PathExt.GetFileNameWithoutRootDirectory(file);

            foreach (LandedTitle title in landedTitles)
            {
                Assert.AreEqual(
                    1, landedTitles.Count(x => x.Id == title.Id),
                    $"The '{fileName}' file contains a duplicated landed title '{title.Id}'");

                foreach (string culture in title.DynamicNames.Keys)
                {
                    Assert.IsFalse(
                        Regex.IsMatch(title.DynamicNames[culture], InvalidSpacingPattern),
                        $"The '{fileName}' file contains invalid spacing in the {culture} dynamic name of {title.Id}");
                }

                if (title.Children.Count > 0)
                {
                    AssertLandedTitleDynamicNames(title.Children, file);
                }
            }
        }
    }
}
