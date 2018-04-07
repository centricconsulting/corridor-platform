using System;
using Microsoft.SqlServer.Server;
using Corridor.FileManager.Services;

namespace Corridor.FileManager
{
  public partial class DataProcessor
  {

    [SqlProcedure]
    public static void LoadFileRows(
        string FilePath,
        int AgencyFileKey,
        int ProcessBatchKey,
        string ConnectionString,
        out byte SuccessFlag,
        out DateTime ProcessTimestamp,
        out string ErrorMessage)
    {

      LoadFileRows service = new LoadFileRows();

      service.Execute(
        FilePath,
        AgencyFileKey,
        ProcessBatchKey,
        ConnectionString,
        out SuccessFlag,
        out ProcessTimestamp,
        out ErrorMessage);

    }

    [SqlProcedure]
    public static void GetFileInfo(
      string FilePath, 
      string TrunkFolderPath,
      out string FileHash,
      out string FileGuid,
      out string FileName,
      out string FolderBranch,
      out string FolderPath,
      out string ArchiveFileName,
      out DateTime FileCreatedDtm,
      out DateTime FileModifiedDtm)
    {

      GetFileInfo service = new Services.GetFileInfo();

      service.Execute(
        FilePath,
        TrunkFolderPath,
        out FileHash,
        out FileGuid,
        out FileName,
        out FolderBranch,
        out FolderPath,
        out ArchiveFileName,
        out FileCreatedDtm,
        out FileModifiedDtm
      );
    }

    public static void ArchiveFile(
      string FilePath,
      string FolderBranch,
      string ArchiveFileName,
      string RejectedRootFolderPath,
      string AcceptedRootFolderPath,
      bool SuccessFlag,
      out string ArchiveFolderPath)
    {
      ArchiveFile service = new Services.ArchiveFile();

      service.Execute(
        FilePath,
        FolderBranch,
        ArchiveFileName,
        RejectedRootFolderPath,
        AcceptedRootFolderPath,
        SuccessFlag,
        out ArchiveFolderPath
      );
    }


  }
}
