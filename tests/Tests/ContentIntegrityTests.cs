using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

using Microsoft.VisualStudio.TestTools.UnitTesting;

using McnTests.Entities;
using McnTests.Helpers;
using McnTests.IO;

namespace McnTests.Tests
{
    [TestClass]
    public class ContentIntegrityTests
    {
        const string InvalidQuotesPattern = "(^ *[^_]* = \"[^\"]*$|^ *[^_]* = [^\"]*\"$)";
        const string InvalidSpacingPattern = @"(^.*\ \ .*$|^\ .*$|^.*\ $)";

        [TestInitialize]
        public void SetUp()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        }

        [TestMethod]
        public void TestLandedTitleFilesIntegrity()
        {
            List<string> files = Directory.GetFiles(ApplicationPaths.LandedTitlesDirectory).ToList();

            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);

                List<string> lines = FileLoader
                    .ReadAllLines(FileEncoding.Windows1252, file)
                    .Select(line => GetLineWithoutComments(line))
                    .ToList();

                List<LandedTitle> landedTitles = LandedTitlesFile
                    .ReadAllTitles(file)
                    .ToList();

                string content = string.Join(Environment.NewLine, lines);

                int openingBrackets = content.Count(x => x == '{');
                int closingBrackets = content.Count(x => x == '}');

                Assert.AreEqual(openingBrackets, closingBrackets, $"There are mismatching brackets in {fileName}");
                AssertLandedTitlesQuotes(lines, file);
                AssertLandedTitleDynamicNames(landedTitles, file);
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
            string fileName = Path.GetFileName(file);

            int lineNumber = 0;
            foreach (string line in lines)
            {
                lineNumber += 1;

                Assert.IsFalse(Regex.IsMatch(line, InvalidQuotesPattern), $"The '{fileName}' file contains invalid quotes, at line {lineNumber}");
            }
        }

        void AssertLandedTitleDynamicNames(IEnumerable<LandedTitle> landedTitles, string file)
        {
            string fileName = Path.GetFileName(file);

            foreach (LandedTitle title in landedTitles)
            {
                Assert.AreEqual(
                    1, landedTitles.Count(x => x.Id == title.Id),
                    $"The '{fileName}' file contains a duplicated landed title '{title.Id}'");

                Assert.IsTrue(
                    title.DynamicNames.Keys.SequenceEqual(title.DynamicNames.Keys.OrderBy(x => x)),
                    $"The '{fileName}' file contains unsorted dynamic names for {title.Id}");

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
