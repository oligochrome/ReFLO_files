using Newtonsoft.Json;  // Installed via Tools > NuGet Package Manager > Manage NuGet Packages for Solutions > Browse
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace ReFLO
{
    class DataDump
    {
        public readonly GameDataPaths Paths;
        public readonly bool DumpDEBUG = false;
        public Encoding Encdr = Encoding.GetEncoding(28591);
        public DataDump(GameDataPaths p, bool Debug = false) { Paths = p; DumpDEBUG = Debug; }
        public object Dump(string specificEntry, string outRoot, bool outputJSON=true, bool fileDecrypted=false)
        {
            FloParser fp = new FloParser(Encoding.GetEncoding(28591));
            Regex invalidCharRGX = new Regex(@"^[\x00-\x1F]");
            Regex baseNameRGX = new Regex(@"[^\\]+$");
    
            string filePath = specificEntry;
            string baseName = baseNameRGX.Match(specificEntry).Value;
            string outFile = outRoot + @"\" + Path.GetFileNameWithoutExtension(filePath) + ".json";
            byte[] data;

            Directory.CreateDirectory(outRoot);
            if (DumpDEBUG) { Console.Error.WriteLine("== DataDump START ==\n\nfilePath = {0}\noutFile = {1}\n\n", filePath, outFile); }
            Console.Error.WriteLine("Reading {0}", baseName);

            // Obtain parsed data first
            if (fileDecrypted == true)
            {
                data = File.ReadAllBytes(filePath);
            }
            else
            {
                switch (baseNameRGX.Match(Path.GetDirectoryName(filePath)).Value)   // Base on directory name
                {
                    case "TextAsset":
                        data = fp.Text(filePath);
                        break;

                    default:
                        switch (Path.GetExtension(filePath)) // Get the extension:
                        {
                            default:
                                Console.Error.WriteLine("WARNING:  Did not program to parse Dir/Ext of {0}", filePath);
                                data = null;
                                break;
                        }
                        break;
                }
            }

            if (data == null) { throw new NullReferenceException("data[] has not been defined"); }

            // Load the parsed data info
            switch (baseName)
            {
                case "obj.bytes":                       //  Manager_219
                    {
                        tableObj tbl = new tableObj { };
                        using (MemoryStream sr = new MemoryStream(data))
                        {
                            using (BinaryReader br = new BinaryReader(sr))
                            {
                                int Entries = br.ReadInt32();
                                if (DumpDEBUG) { Console.Error.WriteLine("Entries: {0}", Entries); }
                                int ii = 0;
                                while (br.BaseStream.Position != br.BaseStream.Length)
                                {
                                    ObjFLO tFlo = new ObjFLO { };
                                    br.ReadUInt32();               // uint index_ref
                                    tFlo.Uniqid = br.ReadUInt32();
                                    int MaxLength = br.ReadByte();
                                    tFlo.Objid = Encdr.GetString(br.ReadBytes(MaxLength));
                                    Match match = invalidCharRGX.Match(tFlo.Objid);
                                    if (match.Success)
                                    {
                                        tFlo.Objid = tFlo.Objid.Substring(1, tFlo.Objid.Length - 1) + br.ReadChar();
                                    }
                                    br.ReadUInt32();               //  unk_Data2 == resActionId? or maybe a coincidence
                                    tFlo.Resid = br.ReadUInt32();  
                                    tFlo.Residicon = br.ReadUInt32();
                                    br.ReadUInt32();             //  resswitchIdHQ == resIdIcon
                                    tFlo.ResActionId = br.ReadUInt32(); 
                                    tFlo.ObjTypeId = br.ReadUInt32();
                                    tFlo.ContentsTypeId = br.ReadUInt32();
                                    tFlo.NameId = br.ReadUInt32();
                                    tFlo.DescriptionId = br.ReadUInt32();
                                    tFlo.CommonParamId = br.ReadUInt32();
                                    tFlo.CharaParamId = br.ReadUInt32();
                                    tFlo.FacillityParamId = br.ReadUInt32();
                                    tFlo.PickParamId = br.ReadUInt32();
                                    tFlo.FurnitureParamId = br.ReadUInt32();
                                    tFlo.GroundParamId = br.ReadUInt32();
                                    tFlo.ObjGroupId = br.ReadUInt32();
                                    tFlo.WeaponParamId = br.ReadUInt32();
                                    tFlo.GuardParamId = br.ReadUInt32();
                                    tFlo.NormalParamId = br.ReadUInt32();
                                    tFlo.ImportantParamId = br.ReadUInt32();
                                    tFlo.SpecialParamId = br.ReadUInt32();
                                    tFlo.SurpriseboxParamId = br.ReadUInt32();
                                    tFlo.GodItemParamId = br.ReadUInt32();

                                    tbl.TableObj.Add(tFlo);
                                    ii += 1;
                                }
                                if (DumpDEBUG) { Console.Error.WriteLine("Total = {0}", ii); }
                            }
                        }
                    File.WriteAllText(outFile, JsonConvert.SerializeObject(tbl, Formatting.Indented));
                    return tbl;
                    break;
                    }
                case "text.bytes":                      //  Manage_63
                    {
                        tableText tbl = new tableText { };
                        using (MemoryStream sr = new MemoryStream(data))
                        {
                            using (BinaryReader br = new BinaryReader(sr))
                            {
                                //  var types = ProtoTableDumper.GetProtoTypes();
                                int Entries = br.ReadInt32();
                                if (DumpDEBUG) { Console.Error.WriteLine("Entries: {0}", Entries); }
                                int ii = 0;
                                while (br.BaseStream.Position != br.BaseStream.Length)
                                {
                                    TextFLO tFlo = new TextFLO { Id = br.ReadUInt32() };
                                    int MaxLength = br.ReadByte();
                                    // Forcefully extending the selected IDs as the entries may be too short
                                    switch (tFlo.Id)
                                    {
                                        case 2851860254:        //  Hunter description
                                            br.ReadByte();
                                            MaxLength = 275;
                                            //tFlo.SkippedChar = 2;
                                            break;

                                        case 2865072796:        //  Magician description
                                            MaxLength = 256;
                                            //tFlo.SkippedChar = 2;
                                            break;
                                    }
                                    tFlo.Value = Encdr.GetString(br.ReadBytes(MaxLength));
                                    Match match = invalidCharRGX.Match(tFlo.Value);
                                    if (match.Success)
                                    {
                                        tFlo.Value = tFlo.Value.Substring(1, tFlo.Value.Length - 1) + br.ReadChar();
                                        //tFlo.SkippedChar = 1;
                                    }
                                    tbl.TableText.Add(tFlo);
                                    ii += 1;
                                }
                                if (DumpDEBUG) { Console.Error.WriteLine("Total = {0}", ii); }
                            }
                        }
                        File.WriteAllText(outFile, JsonConvert.SerializeObject(tbl, Formatting.Indented));
                        return tbl;
                    break;
                    }

                default:
                    throw new KeyNotFoundException("Need to program " + filePath);
                    break;
            }

            /*
            Console.Error.WriteLine(tbl.DumpAll());
            var types = ProtoTableDumper.GetProtoTypes();
            foreach (var t in types)
            {
                Console.Error.WriteLine("t = ", t);
            }

            var name = t.Name.Replace("Table", string.Empty);
            var filename = $"{name}.pb";
            var path = Path.Combine(outRoot, @"db\master\pb\", filename);
            var outpath = Path.Combine(pdf, $"{name}.json");
            if (!File.Exists(path))
            {
                Debug.WriteLine($"Couldn't find proto data file: {name}");
                continue;
            }
            var data = File.ReadAllBytes(path);

            var result = ProtoTableDumper.GetProtoStrings(t, data);
            if (result == null)
            {
                Debug.WriteLine($"Bad conversion for {name}, skipping.");
                continue;
            }
            File.WriteAllLines(outpath, result);

            switch (Path.GetFileName(filePath))
        {
            case "text.bytes":
                byte[] data = fp.Text(filePath);
                tableText tbl = new tableText;
                tbl.
                break;
        }
            */

            if (DumpDEBUG) { Console.Error.WriteLine("== DataDump END ==\n"); }
            return null;
        }
    }
}
