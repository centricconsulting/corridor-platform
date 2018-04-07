using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Corridor.FileManager.Services
{
  public class ProcessErrors
  {
    private StringBuilder _ErrorMessages = new StringBuilder();

    public int ErrorCount { get; private set; }
    public int CriticalErrorCount { get; private set; }

    public int Length { get { return _ErrorMessages.Length; } }

    public void Add(string AttributeName, string ErrorMessage)
    {
      Add(ErrorMessage, AttributeName, false);
    }

    public void Add(string AttributeName, string ErrorMessage, bool Critical)
    {
      this.ErrorCount++;
      if (Critical) CriticalErrorCount++;

      // insert a carriage return
      if (this.ErrorCount > 0) this._ErrorMessages.Append("\r\n");

      string Message = null;
      if (Critical)
      {
        Message = string.Format("CRITICAL!! {0}: {1}", AttributeName, ErrorMessage);
      }
      else
      {
        Message = string.Format("{0}: {1}", AttributeName, ErrorMessage);
      }


      this._ErrorMessages.AppendLine(Message);
    }

    public override string ToString()
    {

      if (this.ErrorCount == 0) return null;

      string Declaration = string.Format("Encountered {0} critical and {1} non-critical error(s).\r\n",
        this.CriticalErrorCount.ToString(), (this.ErrorCount - this.CriticalErrorCount).ToString());

      return new StringBuilder(Declaration).AppendLine(this._ErrorMessages.ToString()).ToString();
    }

  }

  public class FileFormatTranslate
  {
    public string AttributeName { get; set; }
    public string AttributeValue { get; set; }
    public string TranslateValue { get; set; }
  }

  public class FileFormatAttribute
  {
    public string AttributeName { get; set; }
    public int ColumnIndex { get; set; }
    public string ExtractRegex { get; set; }
    public string AttributeDataType { get; set; }
    public int? AttributeMaxLength { get; set; }
    public bool RequiredFlag { get; set; }
    public bool TransformDefaultFlag { get; set; }
  }

}
