using System;
using System.Data;
using System.Data.SqlClient;
using System.Xml;
using System.Xml.Linq;
using Excel = Microsoft.Office.Interop.Excel;
using System.Runtime.InteropServices;

namespace Corridor.FileManager.Services
{
  public class LoadFileRows
  {

    public const string TableName = "dbo.agency_file_row";
    public const int SupportedColumnCount = 40;

    public string ConnectionString { get; set; }
    public string FilePath { get; set; }
    public int AgencyFileKey { get; set; }
    public int ProcessBatchKey { get; set; }

    public void Execute(
        string FilePath,
        int AgencyFileKey,
        int ProcessBatchKey,
        string ConnectionString,
        out byte SuccessFlag,
        out DateTime ProcessTimestamp,
        out string ErrorMessage)
    {

      this.ConnectionString = ConnectionString;
      this.FilePath = FilePath;

      SuccessFlag = 1;
      ErrorMessage = String.Empty;
      ProcessTimestamp = DateTime.Now;

      try
      {
        string[,] CellValues = GetCellValuesFromExcel();
        DataTable dt = GetLoadedDataTable(CellValues);
        SaveData(dt);

        SuccessFlag = 1;
      }
      catch (Exception e)
      {
        // capture the error message
        ErrorMessage = e.Message;
        if (e.InnerException != null)
        {
          ErrorMessage = ErrorMessage + e.InnerException.Message;
        }

        SuccessFlag = 0;
      }
    }

    public void SaveData(DataTable dt)
    {

      using (SqlConnection connection = new SqlConnection(this.ConnectionString))
      using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connection))
      {
        connection.Open();

        bulkCopy.DestinationTableName = LoadFileRows.TableName;
        bulkCopy.WriteToServer(dt);

        connection.Close();
      }
    }

    public DataTable GetEmptyDataTable()
    {

      string query = string.Format("SELECT X.* FROM {0} X WHERE 1=0", LoadFileRows.TableName);

      using (SqlConnection connection = new SqlConnection(this.ConnectionString))
      using (SqlCommand cmd = new SqlCommand(query, connection))
      {
        connection.Open();

        DataTable dt = new DataTable();
        dt.Load(cmd.ExecuteReader());

        connection.Close();
        return dt;
      }
    }

    public string[,] GetCellValuesFromExcel()
    {
      Excel.Application ExcelApp = null;
      Excel.Workbook Workbook = null;
      Excel.Worksheet Worksheet = null;

      string[,] CellValues = null;

      try
      {
        // start the Excel application
        ExcelApp = new Excel.Application();
        if (ExcelApp.EnableEvents) ExcelApp.EnableEvents = false;

        // open the Workbook
        Workbook = ExcelApp.Workbooks.Open(this.FilePath);
        Worksheet = (Excel.Worksheet)Workbook.Worksheets[1];

        // return cell values for the first sheet
        CellValues = GetCellValuesFromRange(
          Worksheet.UsedRange,
          LoadFileRows.SupportedColumnCount);

      }
      catch (Exception e)
      {

        Marshal.FinalReleaseComObject(Worksheet);

        if (Workbook != null) Workbook.Close();
        Marshal.FinalReleaseComObject(Workbook);

        if (ExcelApp != null) ExcelApp.Quit();
        Marshal.FinalReleaseComObject(ExcelApp);

        throw e;
      }
      finally
      {

        Marshal.FinalReleaseComObject(Worksheet);

        if (Workbook != null) Workbook.Close();
        Marshal.FinalReleaseComObject(Workbook);

        if (ExcelApp != null) ExcelApp.Quit();
        Marshal.FinalReleaseComObject(ExcelApp);
      }

      return CellValues;
    }

    public DataTable GetLoadedDataTable(string[,] CellValues)
    {

      DataTable dt = null;


      dt = this.GetEmptyDataTable();
      DataRow dr = null;

      // determine the width of the array
      int RowCount = CellValues.GetLength(0);
      int ColumnCount = CellValues.GetLength(1);

      // start on 2nd row because first row is 
      // assumed to be the the header
      int RowNum = 1;

      while (RowNum <= RowCount)
      {

        dr = dt.NewRow();
        PrepareDataRow(dr, RowNum);

        for (int ColNum = 1; ColNum <= ColumnCount; ColNum++)
        {
          // assign the correct column
          AssignDataRowColumn(dr, ColNum,
            CellValues[RowNum - 1, ColNum - 1]);

        }

        // add the row to the data table
        dt.Rows.Add(dr);

        // increment the row          
        RowNum++;
      }

      return dt;
    }

    public string[,] GetCellValuesFromRange(Excel.Range Range, int MaxColumnCount)
    {
      int RowCount = Range.Rows.Count;
      int ColumnCount = Range.Columns.Count;

      if (ColumnCount > MaxColumnCount) ColumnCount = MaxColumnCount;

      string[,] CellValues = new string[RowCount, ColumnCount];

      Excel.Range Cell = null;

      try
      {
        for (int row = 1; row <= RowCount; row++)
        {
          for (int col = 1; col <= ColumnCount; col++)
          {
            Cell = (Excel.Range)Range[row, col];
            CellValues[row - 1, col - 1] = (string)Cell.Text;
          }
        }
      }
      catch (Exception e)
      {
        Marshal.FinalReleaseComObject(Cell);
        throw e;
      }
      finally
      {
        Marshal.FinalReleaseComObject(Cell);
      }

      return CellValues;

    }

    public void AssignDataRowColumn(DataRow dr, int CurrentColumn, string Value)
    {
      // only populate the value is not blank or whitespace
      if (!string.IsNullOrWhiteSpace(Value))
      {
        string ValueColumn = string.Format("column{0}", CurrentColumn.ToString("00"));
        dr[ValueColumn] = Value.Trim();
      }
    }

    public void PrepareDataRow(DataRow dr, int CurrentRow)
    {
      DateTime CurrentTime = DateTime.Now;

      dr["agency_file_key"] = this.AgencyFileKey;

      dr["row_index"] = (CurrentRow);
      dr["column_header_ind"] = (CurrentRow == 1) ? 1 : 0;

      dr["process_batch_key"] = this.ProcessBatchKey;
      dr["create_timestamp"] = CurrentTime;
      dr["modify_timestamp"] = CurrentTime;


    }

  }
}
