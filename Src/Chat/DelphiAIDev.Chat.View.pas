unit DelphiAIDev.Chat.View;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  System.Classes,
  System.JSON,
  System.Threading,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  System.ImageList,
  Vcl.ImgList,
  DockForm,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Buttons,
  Clipbrd,
  DelphiAIDev.Types,
  DelphiAIDev.Consts,
  DelphiAIDev.Chat,
  DelphiAIDev.Settings,
  DelphiAIDev.ModuleCreator,
  DelphiAIDev.DefaultsQuestions.PopupMenu,
  DelphiAIDev.Chat.ProcessResponse,
  HTMLUn2,
  HtmlView,
  HtmlGlobals,
  MarkdownProcessor,
  MarkdownUtils,
  MarkdownCodeCollector;

type
  TDelphiAIDevChatView = class(TDockableForm)
    ImageList1: TImageList;
    pMenuMemoReturn: TPopupMenu;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    SelectAll1: TMenuItem;
    pnBack: TPanel;
    pnBackQuestion: TPanel;
    mmQuestion: TMemo;
    N1: TMenuItem;
    Splitter1: TSplitter;
    pnWait: TPanel;
    ShapeWait: TShape;
    pnWaitCaption: TPanel;
    pMenuCurrentAI: TPopupMenu;
    Gemini1: TMenuItem;
    ChatGPT1: TMenuItem;
    pnBackStatusBar: TPanel;
    lbCurrentAI: TLabel;
    StatusBar1: TStatusBar;
    pnCommands: TPanel;
    btnCopy: TSpeedButton;
    btnInsertAtCursor: TSpeedButton;
    btnMoreActions: TSpeedButton;
    ShapeCommands: TShape;
    btnSend: TButton;
    pMenuMoreActions: TPopupMenu;
    SaveContentToFile1: TMenuItem;
    btnCreateNewUnit: TSpeedButton;
    Clear1: TMenuItem;
    N2: TMenuItem;
    WordWrap1: TMenuItem;
    pnBackConfigurableButtons: TPanel;
    btnUseCurrentUnitCode: TButton;
    btnCodeOnly: TButton;
    btnDefaultsQuestions: TButton;
    pMenuQuestions: TPopupMenu;
    btnCleanAll: TSpeedButton;
    Groq1: TMenuItem;
    HtmlViewer1: THtmlViewer;
    pMenuCodeActions: TPopupMenu;
    Copytoclipboard1: TMenuItem;
    Insert1: TMenuItem;
    Createnewunit1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure cBoxSizeFontKeyPress(Sender: TObject; var Key: Char);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSendClick(Sender: TObject);
    procedure mmQuestionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCopyClick(Sender: TObject);
    procedure btnInsertAtCursorClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure mmQuestionChange(Sender: TObject);
    procedure mmQuestionKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure lbCurrentAIClick(Sender: TObject);
    procedure Gemini1Click(Sender: TObject);
    procedure pMenuCurrentAIPopup(Sender: TObject);
    procedure btnMoreActionsClick(Sender: TObject);
    procedure SaveContentToFile1Click(Sender: TObject);
    procedure btnCreateNewUnitClick(Sender: TObject);
    procedure btnUseCurrentUnitCodeClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WordWrap1Click(Sender: TObject);
    procedure btnCodeOnlyClick(Sender: TObject);
    procedure btnDefaultsQuestionsClick(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure btnCleanAllClick(Sender: TObject);
    procedure HtmlViewer1ObjectClick(Sender, Obj: TObject;
      const OnClick: ThtString);
    procedure Copytoclipboard1Click(Sender: TObject);
    procedure Insert1Click(Sender: TObject);
    procedure Createnewunit1Click(Sender: TObject);
  private
    FChat: TDelphiAIDevChat;
    FSettings: TDelphiAIDevSettings;
    FProcessResponse: TDelphiAIDevChatProcessResponse;
    FPopupMenuQuestions: TDelphiAIDevDefaultsQuestionsPopupMenu;
    FbtnUseCurrentUnitCodeWidth: Integer;
    FbtnCodeOnlyWidth: Integer;
    FbtnDefaultsQuestionsWidth: Integer;
    FQuestionOnShow: string;
    procedure FillMemoReturnWithFile;
    procedure SaveMemoReturnInFile;
    procedure InitializeRichEditReturn;
    procedure ProcessSend;
    procedure AddResponseSimple(const AString: string);
    procedure Last;
    function GetSelectedTextOrAllFromReturn: string;
    function GetSelectedTextOrAllOrAbort: string;
    procedure WaitingFormOFF;
    procedure WaitingFormON;
    procedure ConfLabelCurrentAI;
    procedure ConfScreenOnShow;
    procedure ChangeUseCurrentUnitCode;
    procedure ChangeCodeOnly;
    procedure AddItemsPopupMenuQuestion;
    procedure DoProcessClickInItemDefaultQuestions(ACodeOnly: Boolean; AQuestion: string);
    procedure ProcessWordWrap;
    procedure ConfScreenOnCreate;
    procedure ValidateRegistrationOfSelectedAI;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property QuestionOnShow: string write FQuestionOnShow;
  end;

var
  DelphiAIDevChatView: TDelphiAIDevChatView;

procedure RegisterSelf;
procedure Unregister;
procedure DelphiAIDevChatViewShowDockableForm;

implementation

uses
  DeskUtil,
  DelphiAIDev.Utils,
  DelphiAIDev.Utils.OTA;

{$R *.dfm}

const
  UseCurrentUnitCode_ImageIndex_OFF = 0;
  UseCurrentUnitCode_ImageIndex_ON = 1;
  CodeOnly_ImageIndex_OFF = 2;
  CodeOnly_ImageIndex_ON = 3;

procedure RegisterSelf;
begin
  if(not Assigned(DelphiAIDevChatView))then
    DelphiAIDevChatView := TDelphiAIDevChatView.Create(nil);

  if(@RegisterFieldAddress <> nil)then
    RegisterFieldAddress(DelphiAIDevChatView.Name, @DelphiAIDevChatView);

  RegisterDesktopFormClass(TDelphiAIDevChatView, DelphiAIDevChatView.Name, DelphiAIDevChatView.Name);
end;

procedure Unregister;
begin
  if(@UnRegisterFieldAddress <> nil)then
    UnRegisterFieldAddress(@DelphiAIDevChatView);
  FreeAndNil(DelphiAIDevChatView);
end;

procedure DelphiAIDevChatViewShowDockableForm;
begin
  ShowDockableForm(DelphiAIDevChatView);
  FocusWindow(DelphiAIDevChatView);
end;

constructor TDelphiAIDevChatView.Create(AOwner: TComponent);
begin
  inherited;
  DeskSection := Self.Name;
  AutoSave := True;
  SaveStateNecessary := True;

  FChat := TDelphiAIDevChat.Create;
  FSettings := TDelphiAIDevSettings.GetInstance;
//  FProcessResponse := TDelphiAIDevChatProcessResponse.Create(mmReturn);
  FProcessResponse := TDelphiAIDevChatProcessResponse.Create(HtmlViewer1);
  FPopupMenuQuestions := TDelphiAIDevDefaultsQuestionsPopupMenu.Create;
  FQuestionOnShow := '';

  Self.ConfScreenOnCreate;
  Self.FillMemoReturnWithFile;
end;

procedure TDelphiAIDevChatView.Createnewunit1Click(Sender: TObject);
var
  LText: string;
begin
  LText := SourceCodeCollection.GetString(SourceCodeCollection.Selected);
  if not LText.IsEmpty then
    TDelphiAIDevModuleCreator.New.CreateNewUnit(LText);
end;

destructor TDelphiAIDevChatView.Destroy;
begin
  Self.SaveMemoReturnInFile;
  FPopupMenuQuestions.Free;
  FProcessResponse.Free;
  FChat.Free;
  inherited;
end;

procedure TDelphiAIDevChatView.FormShow(Sender: TObject);
begin
  Self.ConfScreenOnShow;
  Self.InitializeRichEditReturn;
  Self.ProcessWordWrap;
  Self.AddItemsPopupMenuQuestion;
  TUtils.MemoFocusOnTheEnd(mmQuestion);
end;

procedure TDelphiAIDevChatView.FormActivate(Sender: TObject);
begin
  Self.ConfLabelCurrentAI;

  if not FQuestionOnShow.Trim.IsEmpty then
  begin
    mmQuestion.Lines.Clear;
    mmQuestion.Lines.Add(FQuestionOnShow);
    FQuestionOnShow := '';
  end;
end;

procedure TDelphiAIDevChatView.ConfScreenOnCreate;
begin
//  mmReturn.Lines.Clear;
  HtmlViewer1.Clear;

  pnWait.Visible := False;
  FbtnUseCurrentUnitCodeWidth := btnUseCurrentUnitCode.Width;
  FbtnCodeOnlyWidth := btnCodeOnly.Width;
  FbtnDefaultsQuestionsWidth := btnDefaultsQuestions.Width;

  ShapeCommands.Left := 0;
  ShapeCommands.Top := 0;
  ShapeCommands.Width := ShapeCommands.Parent.Width;
  ShapeCommands.Height := ShapeCommands.Parent.Height;
end;

procedure TDelphiAIDevChatView.ConfScreenOnShow;
begin
  TUtilsOTA.IDEThemingAll(TDelphiAIDevChatView, Self);
  btnMoreActions.Font.Color := TUtilsOTA.ActiveThemeColorDefault;

  Self.Constraints.MinWidth := 200;
  Self.Constraints.MinHeight := 300;
end;

procedure TDelphiAIDevChatView.AddItemsPopupMenuQuestion;
begin
  FPopupMenuQuestions
    .ProcessClickInItem(DoProcessClickInItemDefaultQuestions)
    .CreateMenus(pMenuQuestions);
end;

procedure TDelphiAIDevChatView.DoProcessClickInItemDefaultQuestions(ACodeOnly: Boolean; AQuestion: string);
begin
  if ACodeOnly then
    btnCodeOnly.ImageIndex := CodeOnly_ImageIndex_ON
  else
    btnCodeOnly.ImageIndex := CodeOnly_ImageIndex_OFF;

  mmQuestion.Lines.Add(AQuestion);
end;

procedure TDelphiAIDevChatView.mmQuestionChange(Sender: TObject);
begin
  if mmQuestion.Lines.Count >= 7 then
    mmQuestion.ScrollBars := ssVertical
  else
    mmQuestion.ScrollBars := ssNone;
end;

procedure TDelphiAIDevChatView.mmQuestionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift)and(Key = VK_RETURN) then
  begin
    btnSend.Click;
    Key := 0;
  end
end;

procedure TDelphiAIDevChatView.mmQuestionKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift)and(Key = 65) then
  begin
    mmQuestion.SelectAll;
    Key := 0;
  end;
end;

procedure TDelphiAIDevChatView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.WaitingFormOFF;
end;

procedure TDelphiAIDevChatView.FormResize(Sender: TObject);
var
  LWidth: Integer;
const
  CAPTION_UseCurrentUnitCode = 'Use current unit code in query';
  CAPTION_CodeOnly = 'Code only';
  CAPTION_DefaultsQuestions = 'Questions';
begin
  if Self.Width > 620 then
  begin
    btnUseCurrentUnitCode.Caption := CAPTION_UseCurrentUnitCode;
    btnUseCurrentUnitCode.Width := FbtnUseCurrentUnitCodeWidth;
    btnUseCurrentUnitCode.ImageAlignment := TImageAlignment.iaLeft;

    btnCodeOnly.Caption := CAPTION_CodeOnly;
    btnCodeOnly.Width := FbtnCodeOnlyWidth;
    btnCodeOnly.ImageAlignment := TImageAlignment.iaLeft;

    btnDefaultsQuestions.Caption := CAPTION_DefaultsQuestions;
    btnDefaultsQuestions.Width := FbtnDefaultsQuestionsWidth;
    btnDefaultsQuestions.ImageAlignment := TImageAlignment.iaLeft;
  end
  else
  begin
    LWidth := btnSend.Width;
    if Self.Width < 405 then
      LWidth := 24;

    btnUseCurrentUnitCode.Caption := '';
    btnUseCurrentUnitCode.Width := LWidth;
    btnUseCurrentUnitCode.ImageAlignment := TImageAlignment.iaCenter;

    btnCodeOnly.Caption := '';
    btnCodeOnly.Width := LWidth;
    btnCodeOnly.ImageAlignment := TImageAlignment.iaCenter;

    btnDefaultsQuestions.Caption := '';
    btnDefaultsQuestions.Width := LWidth;
    btnDefaultsQuestions.ImageAlignment := TImageAlignment.iaCenter;
  end;
end;

procedure TDelphiAIDevChatView.FillMemoReturnWithFile;
begin
  if(FileExists(TUtils.GetPathFileChat))then
//    mmReturn.Lines.LoadFromFile(TUtils.GetPathFileChat)
    HtmlViewer1.LoadFromFile(TUtils.GetPathFileChat)
end;

procedure TDelphiAIDevChatView.SaveMemoReturnInFile;
begin
//  mmReturn.Lines.SaveToFile(TUtils.GetPathFileChat);{ TODO : save lines to file }
end;

procedure TDelphiAIDevChatView.SelectAll1Click(Sender: TObject);
begin
  HtmlViewer1.SelectAll;
//  mmReturn.SelectAll;
end;

procedure TDelphiAIDevChatView.cBoxSizeFontKeyPress(Sender: TObject; var Key: Char);
begin
  if not(CharInSet(Key, ['0'..'9', #8]))then
    Key := #0;
end;

procedure TDelphiAIDevChatView.Cut1Click(Sender: TObject);
begin
  HtmlViewer1.CopyToClipboard;
//  mmReturn.CutToClipboard;
end;

procedure TDelphiAIDevChatView.Copy1Click(Sender: TObject);
begin
//  mmReturn.CopyToClipboard;
  HtmlViewer1.CopyToClipboard;
end;

procedure TDelphiAIDevChatView.Copytoclipboard1Click(Sender: TObject);
begin
  Clipboard.AsText := SourceCodeCollection.GetString(SourceCodeCollection.Selected);
end;

procedure TDelphiAIDevChatView.Paste1Click(Sender: TObject);
begin
//  mmReturn.PasteFromClipboard;{ TODO : paste from clipboard }
end;

procedure TDelphiAIDevChatView.btnUseCurrentUnitCodeClick(Sender: TObject);
begin
  Self.ChangeUseCurrentUnitCode;
end;

procedure TDelphiAIDevChatView.btnDefaultsQuestionsClick(Sender: TObject);
begin
  pMenuQuestions.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TDelphiAIDevChatView.ChangeUseCurrentUnitCode;
begin
  if btnUseCurrentUnitCode.ImageIndex = UseCurrentUnitCode_ImageIndex_OFF then
    btnUseCurrentUnitCode.ImageIndex := UseCurrentUnitCode_ImageIndex_ON
  else
    btnUseCurrentUnitCode.ImageIndex := UseCurrentUnitCode_ImageIndex_OFF;
end;

procedure TDelphiAIDevChatView.btnCodeOnlyClick(Sender: TObject);
begin
  Self.ChangeCodeOnly;
end;

procedure TDelphiAIDevChatView.ChangeCodeOnly;
begin
  if btnCodeOnly.ImageIndex = CodeOnly_ImageIndex_OFF then
    btnCodeOnly.ImageIndex := CodeOnly_ImageIndex_ON
  else
    btnCodeOnly.ImageIndex := CodeOnly_ImageIndex_OFF;
end;

procedure TDelphiAIDevChatView.btnSendClick(Sender: TObject);
begin
  Self.ProcessSend;
end;

procedure TDelphiAIDevChatView.ProcessSend;
var
  LTask: ITask;
  LQuestion: string;
begin
  if mmQuestion.Lines.Text.Trim.IsEmpty then
    TUtils.ShowMsgAndAbort('No questions have been added', mmQuestion);

  Self.ValidateRegistrationOfSelectedAI;

//  mmReturn.Lines.Clear;
  HtmlViewer1.Clear;
  Self.WaitingFormON;

  LQuestion := FSettings.LanguageQuestions.GetLanguageDefinition;

  if btnUseCurrentUnitCode.ImageIndex = UseCurrentUnitCode_ImageIndex_ON then
    LQuestion := TUtilsOTA.GetSelectedBlockOrAllCodeUnit.Trim + sLineBreak;

  if btnCodeOnly.ImageIndex = CodeOnly_ImageIndex_ON then
    LQuestion := LQuestion + FSettings.LanguageQuestions.GetMsgCodeOnly;

  LQuestion := LQuestion + mmQuestion.Lines.Text;

  LTask := TTask.Create(
    procedure
    begin
      try
        try
          FChat.ProcessSend(LQuestion);
        except
          on E: Exception do
            TThread.Synchronize(nil,
              procedure
              begin
                Self.AddResponseSimple('Unable to perform processing.' + sLineBreak + TUtils.GetExceptionMessage(E));
                Abort;
              end);
        end;

        TThread.Synchronize(nil,
          procedure
          begin
//            mmReturn.Lines.BeginUpdate;
            try
              //Optional use of one of the following lines
              // preprocess markdown to html
              var md := TMarkdownProcessor.CreateDialect(mdTxtMark);
              try
//              FProcessResponse.AddResponseComplete(FChat.Response);
                var lines := TStringList.Create;
                SourceCodeCollection.Clear;
                lines.Text := md.process(FChat.Response.Text);
                if TUtilsOTA.ActiveThemeIsDark then
                  lines.Text := '<html><head><style>body{color: #fff; background: #2d2d2d;}</style></head><body>'+
                    lines.Text + '</body></html>'
                else
                  lines.Text := '<html><head><style>body{color: #000; background: #fff;}</style></head><body>'+
                    lines.Text + '</body></html>';

                FProcessResponse.AddResponseComplete(lines);
                lines.Free;
              finally
                md.Free;
              end;

              Self.Last;
              //Self.AddResponseSimple(FChat.Response.Text);
            finally
//              mmReturn.Lines.EndUpdate;
            end;
          end);
      finally
        TThread.Synchronize(nil,
          procedure
          begin
            Self.WaitingFormOFF;
          end);
      end;
    end);
  LTask.Start;
end;

procedure TDelphiAIDevChatView.ValidateRegistrationOfSelectedAI;
const
  MSG = '"%s" for IA %s not specified in settings.' + sLineBreak + sLineBreak +
    'Access menu > AI Developer > Settings';
begin
  case FSettings.AIDefault of
    TC4DAIsAvailable.Gemini:
    begin
      if FSettings.BaseUrlGemini.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['Base URL', 'Gemini']));

      if FSettings.ModelGemini.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['Model', 'Gemini']));

      if FSettings.ApiKeyGemini.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['API Key', 'Gemini']));
    end;
    TC4DAIsAvailable.OpenAI:
    begin
      if FSettings.BaseUrlOpenAI.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['Base URL', 'ChatGPT']));

      if FSettings.ModelOpenAI.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['Model', 'ChatGPT']));

      if FSettings.ApiKeyOpenAI.Trim.IsEmpty then
        TUtils.ShowMsgAndAbort(Format(MSG, ['API Key', 'ChatGPT']));
    end;
  end;
end;

procedure TDelphiAIDevChatView.AddResponseSimple(const AString: string);
begin
  Self.Last;
//  mmReturn.SelAttributes.Color := TUtilsOTA.ActiveThemeColorDefault;
//  mmReturn.SelAttributes.Style := [];
//  mmReturn.Lines.Add(AString);
  Self.Last;
end;

////Add line-by-line response to color where Delphi code is
//procedure TDelphiAIDevChatView.AddResponseComplete(const AStrings: TStrings);
//var
//  LLineNum: Integer;
//  LLineStr: string;
//  LCodeStarted: Boolean;
//begin
//  mmReturn.Lines.Clear;
//  mmReturn.SelAttributes.Color := TUtilsOTA.ActiveThemeColorDefault;
//  mmReturn.SelAttributes.Style := [];
//
//  LCodeStarted := False;
//  for LLineNum := 0 to Pred(AStrings.Count) do
//  begin
//    LLineStr := AStrings[LLineNum].TrimRight;
//
//    if not LCodeStarted then
//    begin
//      if TUtils.CodeIdMarkBeginCode(LLineStr) then
//      begin
//        LCodeStarted := True;
//        Continue;
//      end;
//    end;
//
//    if LLineStr.Trim = TConsts.MARK_END then
//    begin
//      LCodeStarted := False;
//      mmReturn.SelAttributes.Color := TUtilsOTA.ActiveThemeColorDefault;
//      Continue;
//    end;
//
//    if LCodeStarted then
//    begin
//      if (FSettings.ColorHighlightCodeDelphiUse) and (FSettings.ColorHighlightCodeDelphi <> clNone) then
//        mmReturn.SelAttributes.Color := FSettings.ColorHighlightCodeDelphi
//      else
//        mmReturn.SelAttributes.Color := TUtilsOTA.ActiveThemeForCode;
//    end
//    else
//      mmReturn.SelAttributes.Color := TUtilsOTA.ActiveThemeColorDefault;
//
//    //Optional use of one of the following lines
//    //mmReturn.Lines.Add(LLineStr);
//    Self.AddResponseLine(LLineStr); //.Replace(TConsts.MARK_BEGIN_PASCAL2, '', [rfReplaceAll, rfIgnoreCase])
//  end;
//  Self.Last;
//end;
//
////Bold in words between Backtick
//procedure TDelphiAIDevChatView.AddResponseLine(const ALineStr: string);
//const
//  BACKTICK = '`';
//var
//  i: Integer;
//  LCurrentLetter: Char;
//  LNextLetter: Char;
//  LLineStarted: Boolean;
//  LCodeStarted: Boolean;
//begin
//  if not ALineStr.Contains(BACKTICK) then
//  begin
//    mmReturn.Lines.Add(IFThen(ALineStr.IsEmpty, ' ', ALineStr));
//    Exit;
//  end;
//
//  LLineStarted := False;
//  LCodeStarted := False;
//  for i := 0 to ALineStr.Length do
//  begin
//    LCurrentLetter := ALineStr[i];
//    LNextLetter := ALineStr[Succ(i)];
//
//    if not LCodeStarted then
//    begin
//      if(LCurrentLetter = BACKTICK)and(LNextLetter <> BACKTICK)then
//      begin
//        LCodeStarted := True;
//        Continue;
//      end;
//    end;
//
//    if(LCurrentLetter = BACKTICK)and(LNextLetter <> BACKTICK)then
//    begin
//      LCodeStarted := False;
//      mmReturn.SelAttributes.Style := [];
//      Continue;
//    end;
//
//    SendMessage(mmReturn.Handle, WM_VSCROLL, SB_BOTTOM, 0);
//    if LCodeStarted then
//      mmReturn.SelAttributes.Style := [fsBold]
//    else
//      mmReturn.SelAttributes.Style := [];
//
//    if LLineStarted then
//      mmReturn.SelText := LCurrentLetter
//    else
//    begin
//      mmReturn.Lines.Add('');
//      mmReturn.SelText := LCurrentLetter;
//
//      LLineStarted := True;
//    end;
//    SendMessage(mmReturn.Handle, WM_VSCROLL, SB_BOTTOM, 0);
//  end;
//  mmReturn.SelText := ' ';
//  SendMessage(mmReturn.Handle, WM_VSCROLL, SB_BOTTOM, 0);
//end;

procedure TDelphiAIDevChatView.WaitingFormON;
begin
  pnWait.Visible := False;
//  TUtils.CenterPanel(pnWait, mmReturn);
  TUtils.CenterPanel(pnWait, HtmlViewer1);
  pnWait.Visible := True;
end;

procedure TDelphiAIDevChatView.WordWrap1Click(Sender: TObject);
begin
  Self.ProcessWordWrap;
end;

procedure TDelphiAIDevChatView.ProcessWordWrap;
begin
//  if WordWrap1.Checked then
//    mmReturn.ScrollBars := ssVertical
//  else
//    mmReturn.ScrollBars := ssBoth;
end;

procedure TDelphiAIDevChatView.WaitingFormOFF;
begin
  pnWait.Visible := False;
end;

procedure TDelphiAIDevChatView.Last;
begin
//  SendMessage(mmReturn.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  SendMessage(HtmlViewer1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TDelphiAIDevChatView.lbCurrentAIClick(Sender: TObject);
begin
  pMenuCurrentAI.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TDelphiAIDevChatView.GetSelectedTextOrAllFromReturn: string;
begin
//  if not mmReturn.SelText.Trim.IsEmpty then
  if not HtmlViewer1.SelText.Trim.IsEmpty then
  begin
    var LText := '';
    // fix non-breaking space and replace with regular space returned by HtmlViewer
    for var i := 1 to Length(HtmlViewer1.SelText) do
    begin
      if HtmlViewer1.SelText[i] = WideChar($A0) then
        LText := LText + ' '
      else
        LText := LText + HtmlViewer1.SelText[i];
    end;
    Result := UTF8Encode(LText) // mmReturn.SelText
  end
  else
    Result := HtmlViewer1.SelHtml;// mmReturn.Lines.Text;
end;

function TDelphiAIDevChatView.GetSelectedTextOrAllOrAbort: string;
begin
  Result := Self.GetSelectedTextOrAllFromReturn;
  if Result.Trim.IsEmpty then
    TUtils.ShowMsgAndAbort('There is no data to be used in this action');
end;

procedure TDelphiAIDevChatView.HtmlViewer1ObjectClick(Sender, Obj: TObject;
  const OnClick: ThtString);
var
  I: Integer;
begin
  // OnClick contains the index of SourceCodeCollection which holds the raw source code
  I := OnClick.ToInteger;
  if SourceCodeCollection.GetCount >= I then
    SourceCodeCollection.Select(I-1);
//    Clipboard.AsText := SourceCodeCollection.GetString(I-1);
  pMenuCodeActions.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TDelphiAIDevChatView.btnInsertAtCursorClick(Sender: TObject);
var
 LText: string;
begin
  LText := Self.GetSelectedTextOrAllOrAbort;
  TUtilsOTA.DeleteBlockTextSelectedInEditor;
  TUtilsOTA.InsertBlockTextIntoEditor(LText);
end;

procedure TDelphiAIDevChatView.btnCopyClick(Sender: TObject);
var
 LText: string;
begin
  LText := Self.GetSelectedTextOrAllOrAbort;
  Clipboard.AsText := LText;
end;

procedure TDelphiAIDevChatView.btnCreateNewUnitClick(Sender: TObject);
var
 LText: string;
begin
  LText := Self.GetSelectedTextOrAllOrAbort;
  TDelphiAIDevModuleCreator.New.CreateNewUnit(LText);
end;

procedure TDelphiAIDevChatView.SaveContentToFile1Click(Sender: TObject);
var
  LFileName: string;
begin
  Self.GetSelectedTextOrAllOrAbort;

  LFileName := TUtils.GetFileName('rtf');
//  mmReturn.Lines.SaveToFile(LFileName);
  TUtils.ShowV('File saved successfully');
end;

procedure TDelphiAIDevChatView.Clear1Click(Sender: TObject);
begin
//  mmReturn.Lines.Clear;
  HtmlViewer1.Clear;
end;

procedure TDelphiAIDevChatView.btnMoreActionsClick(Sender: TObject);
begin
  pMenuMoreActions.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TDelphiAIDevChatView.InitializeRichEditReturn;
begin
//  mmReturn.SelAttributes.Name := 'Courier New';
//  mmReturn.SelAttributes.Size := 10;

  if TUtilsOTA.ActiveThemeIsDark then
  begin
//    mmReturn.Color := $004A4136;
//    mmReturn.SelAttributes.Color := clWhite;
  end
  else
  begin
//    mmReturn.Color := clWindow;
//    mmReturn.SelAttributes.Color := clWindowText;
  end;
end;

procedure TDelphiAIDevChatView.Insert1Click(Sender: TObject);
var
  LText: string;
begin
  LText := SourceCodeCollection.GetString(SourceCodeCollection.Selected);
  if not LText.IsEmpty then
  begin
    TUtilsOTA.DeleteBlockTextSelectedInEditor;
    TUtilsOTA.InsertBlockTextIntoEditor(LText);
  end;
end;

procedure TDelphiAIDevChatView.pMenuCurrentAIPopup(Sender: TObject);
begin
  Gemini1.Checked := False;
  ChatGPT1.Checked := False;
  Groq1.Checked := False;
  case FSettings.AIDefault of
    TC4DAIsAvailable.Gemini:
      Gemini1.Checked := True;
    TC4DAIsAvailable.OpenAI:
      ChatGPT1.Checked := True;
    TC4DAIsAvailable.Groq:
      Groq1.Checked := True;
  end;
end;

procedure TDelphiAIDevChatView.ConfLabelCurrentAI;
begin
  lbCurrentAI.Caption := FSettings.AIDefault.ToString;

  case FSettings.AIDefault of
    TC4DAIsAvailable.Gemini:
      lbCurrentAI.Hint := FSettings.ModelGemini;
    TC4DAIsAvailable.OpenAI:
      lbCurrentAI.Hint := FSettings.ModelOpenAI;
    TC4DAIsAvailable.Groq:
      lbCurrentAI.Hint := FSettings.ModelGroq;
  end;

  lbCurrentAI.Repaint;
  Self.Repaint;
end;

procedure TDelphiAIDevChatView.Gemini1Click(Sender: TObject);
var
  LTag: Integer;
begin
  //*SEVERAL
  LTag := TMenuItem(Sender).Tag;
  if not(LTag in [0, 1, 2])then
    Exit;

  FSettings.AIDefault := TC4DAIsAvailable(LTag);
  FSettings.SaveData;
  Self.ConfLabelCurrentAI;
end;

procedure TDelphiAIDevChatView.btnCleanAllClick(Sender: TObject);
begin
  mmQuestion.Lines.Clear;
//  mmReturn.Lines.Clear;
  HtmlViewer1.Clear;
end;

initialization

finalization
  Unregister;

end.
