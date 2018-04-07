using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Data.Linq;
using System.Data;

namespace Corridor.FileManager.Services
{
  public class ConvertColumnToAttribute
  {


    // create the class level lists
    public List<FileFormatAttribute> AttributeList = new List<FileFormatAttribute>();
    public List<FileFormatTranslate> TranslateList = new List<FileFormatTranslate>();   

    public delegate string GetColumnValueFunction(int ColumnIndex, ProcessErrors errors);
    public delegate void SetAttributeValueFunction(string AttributeName, object AttributeValue);

    public string ConnectionString { get; set; }
    public string FileFormatCode { get; set; }

    public ConvertColumnToAttribute(string ConnectionString, string FileFormatCode)
    {
      this.ConnectionString = ConnectionString;
      this.FileFormatCode = FileFormatCode;

      LoadAttributeList();
      LoadTranslateList();
    }

    public void Execute(
      GetColumnValueFunction GetColumnValue,
      SetAttributeValueFunction SetAttributeValue,
      out DateTime ProcessDtm,
      out bool SuccessFlag,
      out string ErrorMessage
    )
    {

      ProcessErrors errors = new ProcessErrors();
      ProcessDtm = DateTime.Now;

      foreach (FileFormatAttribute attribute in this.AttributeList)
      {

        try
        {

          // get the raw value based on column position
          string ColumnValue = GetColumnValue(attribute.ColumnIndex, errors);
          string CleanColumnValue = string.IsNullOrWhiteSpace(ColumnValue) ? null : ColumnValue.Trim();

          // assign a working value for transformation purposes
          string WorkingValue = CleanColumnValue;

          // work through transformation logic
          // only if the column value is not null
          if (WorkingValue != null)
          {
            // apply regex if applicable
            if (!string.IsNullOrWhiteSpace(attribute.ExtractRegex))
            {
              WorkingValue = ExtractText(WorkingValue, attribute, errors);
            }

            // assign translated value if applicable
            if (TranslateList.Exists(x => 
              x.AttributeName.Equals(attribute.AttributeName, 
              StringComparison.CurrentCultureIgnoreCase)))
            { 
              WorkingValue = GetTranslatedValue(WorkingValue, attribute, errors);
            }

            // if after all the transformation, the final working value is null
            // use the original value providing transform default = true
            if (string.IsNullOrWhiteSpace(WorkingValue)
              && attribute.TransformDefaultFlag)
            {
              // reassign the working value to the original value
              WorkingValue = CleanColumnValue;
            }
          }

          // turn on the critical flag if a required value is not present
          if (attribute.RequiredFlag && string.IsNullOrWhiteSpace(WorkingValue))
          {
            errors.Add(attribute.AttributeName, 
              "The attribute is missing but is required.", true);
          }

          // assign values to individual output elements
          // only necessary if value is null
          if (WorkingValue != null)
          {
            SetAttributeValue(attribute.AttributeName, WorkingValue);
          }

        }
        catch (Exception e)
        {
          ErrorMessage = "Code Error: " + e.Message +
          ((e.InnerException != null) ? e.InnerException.Message : String.Empty);

          errors.Add(attribute.AttributeName, ErrorMessage, true);
        }
      }

      // write the results of processing
      SuccessFlag = (errors.CriticalErrorCount == 0);

      int ErrorLength = errors.Length;

      if (ErrorLength > 2000)
      {
        ErrorMessage = errors.ToString().Substring(0, 2000);
      }
      else
      {
        ErrorMessage = (ErrorLength == 0) ? null : errors.ToString();
      }      
    }

    public string GetTranslatedValue(string Value, FileFormatAttribute attribute, ProcessErrors errors)
    {
    
      string EvaluatedValue = Value.Trim();

      // return null if the value is empty
      if (string.IsNullOrWhiteSpace(EvaluatedValue)) return null;

      // get a matching translate object
      FileFormatTranslate t = TranslateList.Find(x =>
        x.AttributeName.Equals(attribute.AttributeName, StringComparison.CurrentCultureIgnoreCase)
        && x.AttributeValue.Equals(EvaluatedValue, StringComparison.CurrentCultureIgnoreCase));
        
      if(t != null)
      {
        return t.TranslateValue;
      }
      else
      {

        errors.Add(attribute.AttributeName, string.Format(
          "Expected but could not find a translation for \"{0}\"", EvaluatedValue));

        return null;
      }

    }

    public string ExtractText(string Text, FileFormatAttribute attribute, ProcessErrors errors)
    {

      string EvaluatedText = Text.Trim();
      
      // return null if the text is empty
      if (string.IsNullOrWhiteSpace(EvaluatedText)) return null;
     

      Match m = new Regex(attribute.ExtractRegex, RegexOptions.IgnoreCase).Match(EvaluatedText);
      String value = (m != null) ? m.Value.Trim() : (string)null;

      if (value != null)
      {
        return value;
      }
      else
      {

        errors.Add(attribute.AttributeName, string.Format(
          "The regex pattern \"{0}\" applied to the source value {1} did not return a match.",
          attribute.ExtractRegex, EvaluatedText));

        return null;        
      }
    }

    public object ConvertToDataType(string Value, FileFormatAttribute attribute, ProcessErrors errors)
    {

      // first handle empty or null values
      if (string.IsNullOrWhiteSpace(Value)) return null;

      // consider typed values
      switch (attribute.AttributeDataType.ToLower())
      {

        case "text":

          if (attribute.AttributeMaxLength != null && Value.Length > (int)attribute.AttributeMaxLength)
          {
            return Value.Substring(0, (int)attribute.AttributeMaxLength);
          }
          else
          {
            return Value;
          }

        case "timestamp":


          DateTime retval;
          if (DateTime.TryParse(Value, out retval))
          {
            return retval.ToString("yyyy-MM-dd hh:mm:ss tt");
          }
          else
          {
            errors.Add(attribute.AttributeName, string.Format(
              "The value provide \"{0}\" does not match the expected '{1}' format.",
              Value, attribute.AttributeDataType.ToLower()));

            return null;
          }

        case "number":

          Decimal retval2;
          if (Decimal.TryParse(Value, out retval2))
          {
            return retval2;
          }
          else
          {
            errors.Add(attribute.AttributeName, string.Format(
              "The value provide \"{0}\" does not match the expected '{1}' format.",
              Value, attribute.AttributeDataType.ToLower()));

            return null;
          }

        case "integer":

          int retval3;
          if (int.TryParse(Value, out retval3))
          {
            return retval3;
          }
          else
          {
            errors.Add(attribute.AttributeName, string.Format(
              "The value provide \"{0}\" does not match the expected '{1}' format.",
              Value, attribute.AttributeDataType.ToLower()));

            return null;
          }

        case "boolean":

          bool retval4;
          if (bool.TryParse(Value, out retval4))
          {
            return retval4;
          }
          else
          {
            errors.Add(attribute.AttributeName, string.Format(
              "The value provide \"{0}\" does not match the expected '{1}' format.",
              Value, attribute.AttributeDataType.ToLower()));

            return null;
          }

        default:

          errors.Add(attribute.AttributeName, string.Format(
            "The attribute format '{0}' is invalid.",
            attribute.AttributeDataType.ToLower()));

          return null;

      }
    }


    public void LoadAttributeList()
    {
      using (SqlConnection connection = new SqlConnection(this.ConnectionString))
      {

        connection.Open();

        string sql = @"dbo.get_attribute_detail";

        using (SqlCommand command = new SqlCommand(sql, connection))
        {
          // add the file format parameter
          command.CommandType = CommandType.StoredProcedure;

          SqlParameter FileFormatCodeParam = new SqlParameter(
            "@file_format_code", SqlDbType.VarChar, 20)
          {
            Value = this.FileFormatCode
          };

          command.Parameters.Add(FileFormatCodeParam);

          SqlDataReader reader = command.ExecuteReader();
          while (reader.Read())
          {
            FileFormatAttribute attribute = new FileFormatAttribute
            {
              AttributeName = reader["attribute_name"].ToString(),
              ColumnIndex = (int)reader["column_index"],
              ExtractRegex = reader["extract_regex"].ToString(),
              AttributeDataType = reader["attribute_data_type"].ToString(),
              AttributeMaxLength = (reader["attribute_max_length"] == DBNull.Value) ? (int?)null : (int?)reader["attribute_max_length"],
              RequiredFlag = (bool)reader["required_ind"],
              TransformDefaultFlag = (bool)reader["transform_default_ind"]
            };

            this.AttributeList.Add(attribute);

          }
        }
        connection.Close();
      }
    }

    /// <summary>
    /// loads the class level translate list
    /// </summary>
    public void LoadTranslateList()
    {
      using (SqlConnection connection = new SqlConnection(this.ConnectionString))
      {

        connection.Open();
        string sql = @"dbo.get_translate_detail";

        using (SqlCommand command = new SqlCommand(sql, connection))
        {

          command.CommandType = CommandType.StoredProcedure;

          // add the file format parameter
          SqlParameter FileFormatCodeParam = new SqlParameter(
            "@file_format_code", SqlDbType.VarChar, 20)
          {
            Value = this.FileFormatCode
          };

          command.Parameters.Add(FileFormatCodeParam);

          SqlDataReader reader = command.ExecuteReader();
          while (reader.Read())
          {
            FileFormatTranslate attribute = new FileFormatTranslate
            {
              AttributeName = reader["attribute_name"].ToString(),
              AttributeValue = reader["attribute_value"].ToString(),
              TranslateValue = reader["translated_value"].ToString()
            };

            this.TranslateList.Add(attribute);

          }
        }
        connection.Close();
      }
    }

  }
}
