unit CodeToHtml;

interface

uses
  System.Classes, System.SysUtils, Windows,
  TextEditor, TextEditor.Fonts;

type
  TCodeToHtml = class
  public
    class function Convert(ALines: string): string;
  end;

var
  CodeEditor: TTextEditor;
  LightTheme: TStringStream;
  DarkTheme: TStringStream;

implementation

uses
  DelphiAIDev.Utils.OTA;

{ TCodeToHtml }

class function TCodeToHtml.Convert(ALines: string): string;
begin
  if TUtilsOTA.ActiveThemeIsDark then
  begin
    DarkTheme.Position := 0;
    CodeEditor.Highlighter.Colors.LoadFromStream(DarkTheme);
  end
  else
  begin
    LightTheme.Position := 0;
    CodeEditor.Highlighter.Colors.LoadFromStream(LightTheme);
  end;
  CodeEditor.Text := ALines + #13;
//  with TextEditor.ExportToHTML.TTextEditorExportHTML.Create(CodeEditor, CodeEditor.FFonts.Text, '') do
//  try
//    Result := AsText;
//  finally
//    Free;
//  end;
  Result := CodeEditor.TextToHTML();
end;

initialization
  CodeEditor := TTextEditor.Create(nil);
  LightTheme := TStringStream.Create;
  DarkTheme := TStringStream.Create;

  var rs := TResourceStream.Create(HInstance, 'THEMEDARK', RT_RCDATA);
  try
    rs.Position := 0;
    DarkTheme.LoadFromStream(rs);
  finally
    rs.Free;
  end;

  rs := TResourceStream.Create(HInstance, 'THEMELIGHT', RT_RCDATA);
  try
    rs.Position := 0;
    LightTheme.LoadFromStream(rs);
  finally
    rs.Free;
  end;

  rs := TResourceStream.Create(HInstance, 'SYNTAXPASCAL', RT_RCDATA);
  try
    rs.Position := 0;
    CodeEditor.Highlighter.LoadFromStream(rs);
  finally
    rs.Free;
  end;

//  CodeEditor.Highlighter.Colors.LoadFromFile(TUtils.GetFileName('Windows 11 Dark.json'));
//  CodeEditor.Highlighter.LoadFromFile(TUtils.GetFileName('Object Pascal.json'));

finalization
  DarkTheme.Free;
  LightTheme.Free;
  CodeEditor.Free;

end.
