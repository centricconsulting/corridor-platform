using System;
using System.IO;

namespace Corridor.FileManager.Services
{
  public class ArchiveFile
  {

    public void Execute(
      string FilePath,
      string FolderBranch,
      string ArchiveFileName,
      string RejectedRootFolderPath,
      string AcceptedRootFolderPath,
      bool SuccessFlag,
      out string ArchiveFolderPath)
    { 


      // determine where archive target file path
      string ArchiveRootFolderPath = (SuccessFlag) ? AcceptedRootFolderPath : RejectedRootFolderPath;
      string ArchiveFilePath = Path.Combine(ArchiveRootFolderPath, FolderBranch, ArchiveFileName);

      // get the folder path for the archvie target file
      ArchiveFolderPath = Path.GetDirectoryName(ArchiveFilePath);

      // ensure the target director exists
      if (!Directory.Exists(ArchiveFolderPath))
      {
        Directory.CreateDirectory(ArchiveFolderPath);
      }

      // move the file to the archive location
      File.Move(FilePath, ArchiveFilePath);
  
    }
  }
}
