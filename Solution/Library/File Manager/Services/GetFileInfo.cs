using System;
using System.IO;
using System.Security.Cryptography;

namespace Corridor.FileManager.Services
{
  public class GetFileInfo
  {

    public void Execute(
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
      FileHash = GetFileHash(FilePath);
      FileGuid = GetFileGuid();
      FileName = GetFileName(FilePath);
      FolderPath = GetFolderPath(FilePath);
      FolderBranch = GetFolderBranch(FilePath, TrunkFolderPath);
      ArchiveFileName = GetArchiveFileName(FilePath, FileGuid);
      FileCreatedDtm = GetCreateTimestamp(FilePath);
      FileModifiedDtm = GetLastModifiedTimestamp(FilePath);
    }

    /// <summary>File name component of the file specified in the FilePath.</summary>
    /// <returns>Returns the file name with a path.</returns>
    public string GetFileName(string FilePath)
    {
      return System.IO.Path.GetFileName(FilePath);
    }

    /// <summary> File name component of the file specified in the FilePath. </summary>
    /// <returns>Returns the file name with a path.</returns>
    public string GetFileGuid()
    {
      return Guid.NewGuid().ToString().Replace("-", String.Empty).ToString().ToUpper();
    }

    /// <summary> File name component of the file specified in the FilePath. </summary>
    /// <returns>Returns the file name with a path.</returns>
    public string GetFileHash(string FilePath)
    {
      FileStream fs = System.IO.File.OpenRead(FilePath);

      MD5 md5hasher = MD5.Create();
      byte[] hash = md5hasher.ComputeHash(fs);

      md5hasher.Clear();
      fs.Close();

      return BitConverter.ToString(hash).Replace("-", String.Empty).ToUpper();
    }

    /// <summary> File extension of the file specified in the FilePath. </summary>
    /// <returns></returns>
    public string GetFileExtension(string FilePath)
    {
      return System.IO.Path.GetExtension(FilePath);
    }

    /// <summary> File name of the file specified in the FilePath excluding the file extension suffix. </summary>
    /// <returns></returns>
    public string GetFileNameWithoutExtension(string FilePath)
    {
      // note that the extension has a "." prefix
      return System.IO.Path.GetFileNameWithoutExtension(FilePath);
    }

    /// <summary> Unique file name comprised the original file name and the file hash. </summary>
    /// <returns></returns>
    public string GetArchiveFileName(string FilePath, string FileGuid)
    {
      return String.Format("{0}_{1}{2}",
        this.GetFileNameWithoutExtension(FilePath),
        FileGuid, this.GetFileExtension(FilePath));
    }

    /// <summary> Directory component of the file specified in the FilePath. </summary>
    /// <returns></returns>
    public string GetFolderPath(string FilePath)
    {
      return System.IO.Path.GetDirectoryName(FilePath);
    }

    /// <summary> Date and time at which the file was created. </summary>
    /// <returns></returns>
    public DateTime GetCreateTimestamp(string FilePath)
    {
      return System.IO.File.GetCreationTime(FilePath);
    }

    /// <summary> Date and time at which the file was last modified. </summary>
    /// <returns></returns>
    public DateTime GetLastModifiedTimestamp(string FilePath)
    {
      return System.IO.File.GetLastWriteTime(FilePath);
    }


    /// <summary>
    /// Determines the branch (section of the folder path) within the trunk folder path and excluding the file name. 
    /// </summary>
    /// <param name="FilePath"></param>
    /// <param name="TrunkFolderPath"></param>
    /// <returns></returns>
    public string GetFolderBranch(String FilePath, string TrunkFolderPath)
    {
      // determine the file folder path
      string FolderPath = this.GetFolderPath(FilePath);
      string FileName = this.GetFileName(FilePath);

      if (FolderPath.StartsWith(TrunkFolderPath, StringComparison.OrdinalIgnoreCase))
      {
        return FolderPath.Substring(TrunkFolderPath.Length + 1);
      }
      else
      {
        return FilePath;
      }
    }

  }
}
