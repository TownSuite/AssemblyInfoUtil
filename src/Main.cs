using System;
using System.IO;
using System.Text;

namespace TownSuite.AssemblyInfoUtil
{

	enum FileType
	{
		cs=1,
		vb=2,
		csproj=3,
		vbproj=4		
	}

	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class AssemblyInfoUtil
	{
		private static int incParamNum = 0;

		private static string fileName = "";
		
		private static string versionStr = null;

		private static FileType theType =  FileType.cs;

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			for (int i = 0; i < args.Length; i++) {
				if (args[i].StartsWith("-inc:")) {
					string s = args[i].Substring("-inc:".Length);
					incParamNum = int.Parse(s);
				}
				else if (args[i].StartsWith("-set:")) {
					versionStr = args[i].Substring("-set:".Length);
				}
				else
					fileName = args[i];
			}

			if (Path.GetExtension(fileName).ToLower() == ".vb")
				theType =  FileType.vb;
			else if (Path.GetExtension(fileName).ToLower() == ".vbproj")
				theType = FileType.vbproj;
			else if (Path.GetExtension(fileName).ToLower() == ".csproj" || Path.GetExtension(fileName).ToLower() == ".props")
				theType = FileType.csproj;

			if (fileName == "") {
				System.Console.WriteLine("Usage: AssemblyInfoUtil <path to AssemblyInfo.cs or AssemblyInfo.vb file> [options]");
				System.Console.WriteLine("Options: ");
				System.Console.WriteLine("  -set:<new version number> - set new version number (in NN.NN.NN.NN format)");
				System.Console.WriteLine("  -inc:<parameter index>  - increases the parameter with specified index (can be from 1 to 4)");
				return;
			}

			if (!File.Exists(fileName)) {
				System.Console.WriteLine("Error: Can not find file \"" + fileName + "\"");
				return;
			}

			System.Console.Write("Processing \"" + fileName + "\"...");
			StreamReader reader = new StreamReader(fileName);
            StreamWriter writer = new StreamWriter(fileName + ".out");
			String line;

			while ((line = reader.ReadLine()) != null) {
				line = ProcessLine(line);
				writer.WriteLine(line);
			}
			reader.Close();
			writer.Close();

			File.Delete(fileName);
			File.Move(fileName + ".out", fileName);
			System.Console.WriteLine("Done!");
		}


		private static string ProcessLine(string line) {
			if (theType == FileType.vb) {
				line = ProcessLinePart(line, "<Assembly: AssemblyVersion(\"");
				line = ProcessLinePart(line, "<Assembly: AssemblyFileVersion(\"");
			} 
			else if (theType == FileType.cs) {
				line = ProcessLinePart(line, "[assembly: AssemblyVersion(\"");
				line = ProcessLinePart(line, "[assembly: AssemblyFileVersion(\"");
			}
			else if (theType == FileType.csproj || theType == FileType.vbproj)
			{
				line = ProcessLinePart(line, "<Version>");
				line = ProcessLinePart(line, "<AssemblyVersion>");
				line = ProcessLinePart(line, "<FileVersion>");
			}
			return line;
		}

		private static string ProcessLinePart(string line, string part) {
			int spos = line.IndexOf(part);
			if (spos >= 0) {
				spos += part.Length;
				int epos = line.IndexOf('"', spos);
				if(epos == -1)
				{
					epos = line.IndexOf('<', spos);
				}
				string oldVersion = line.Substring(spos, epos - spos);
				string newVersion = "";
				bool performChange = false;

				if (incParamNum > 0) {
					string[] nums = oldVersion.Split('.');
					if (nums.Length >= incParamNum && nums[incParamNum - 1] != "*") {
						Int64 val = Int64.Parse(nums[incParamNum - 1]);
						val++;
						nums[incParamNum - 1] = val.ToString();
						newVersion = nums[0]; 
						for (int i = 1; i < nums.Length; i++) {
							newVersion += "." + nums[i];
						}
						performChange = true;
					}

				}
				else if (versionStr != null) {
					newVersion = versionStr;
					performChange = true;
				}

				if (performChange) {
					StringBuilder str = new StringBuilder(line);
					str.Remove(spos, epos - spos);
					str.Insert(spos, newVersion);
					line = str.ToString();
				}
			} 
			return line;
		}
	}
}
