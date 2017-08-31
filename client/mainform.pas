unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, DB, FileUtil, LConvEncoding, Forms, Controls,
  Graphics, Dialogs, StdCtrls, DBGrids, ActnList,
  ComCtrls, ExtCtrls, Menus, Clipbrd, Buttons, LCLProc, uSettingsForm, uRunUtils, uRawDataSet, Types, Grids;

type

  { TMainSearchForm }

  TMainSearchForm = class(TForm)
    acSearchEditFocus: TAction;
    acDownToListing: TAction;
    acAppEnd: TAction;
    acOpenDirectory: TAction;
    acCommander: TAction;
    acEdit: TAction;
    acTerminal: TAction;
    acCopyPath: TAction;
    acHelp: TAction;
    acShowAdvanced: TAction;
    acSettings: TAction;
    acDs: TAction;
    acShowHidePathColumn: TAction;
    btnSearch: TButton;
    Button1: TButton;
    btSettings: TButton;
    chNormalize: TCheckBox;
    edPath: TEdit;
    edWhere: TEdit;
    edTag: TEdit;
    HeaderPanel: TPanel;
    lblPath: TLabel;
    lblWhere: TLabel;
    lblTag: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    acRun: TAction;
    ActionList: TActionList;
    ResultDBGrid: TDBGrid;
    AdvancedPanel: TPanel;
    ResultDBGridIcon: TDBGrid;
    ResultPopUpMenu: TPopupMenu;
    SearchEdit: TEdit;
    Shape1: TShape;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    StatusBar: TStatusBar;
    Timer1: TTimer;
    procedure acAppEndExecute(Sender: TObject);
    Procedure acAppEndUpdate(Sender: TObject);
    Procedure acCopyPathExecute(Sender: TObject);
    Procedure acCopyPathUpdate(Sender: TObject);
    Procedure acCommanderExecute(Sender: TObject);
    Procedure acCommanderUpdate(Sender: TObject);
    procedure acDownToListingUpdate(Sender: TObject);
    Procedure acDsExecute(Sender: TObject);
    Procedure acEditExecute(Sender: TObject);
    Procedure acEditUpdate(Sender: TObject);
    Procedure acHelpExecute(Sender: TObject);
    Procedure acNormalizeExecute(Sender: TObject);
    Procedure acOpenDirectoryExecute(Sender: TObject);
    Procedure acOpenDirectoryUpdate(Sender: TObject);
    procedure acRunExecute(Sender: TObject);
    procedure acSearchEditFocusExecute(Sender: TObject);
    procedure acDownToListingExecute(Sender: TObject);
    Procedure acSettingsExecute(Sender: TObject);
    Procedure acShowAdvancedExecute(Sender: TObject);
    Procedure acShowHidePathColumnExecute(Sender: TObject);
    Procedure acTerminalExecute(Sender: TObject);
    Procedure acTerminalUpdate(Sender: TObject);
    Procedure btnSearchClick(Sender: TObject);
    Procedure FormResize(Sender: TObject);
    Procedure IdleTimer1Timer(Sender: TObject);
    procedure ResultDBGridDblClick(Sender: TObject);
    procedure acRunUpdate(Sender: TObject);
    Procedure ResultDBGridIconDrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ResultDBGridKeyDown(Sender: TObject; var Key: word);
    procedure SearchEditChange(Sender: TObject);
    Procedure SearchEditKeyPress(Sender: TObject; Var Key: char);
  private
    FAutoQuery: Integer;
    FDelay: Integer;
    FPath: String;
    FShowFile: Boolean;
    FTag: String;
    FWhere : String;
    FKeepOpen: Boolean;
    Procedure ResizeResultGridColumn;
    Procedure SetAutoQuery(AValue: Integer);
    Procedure SetDelay(AValue: Integer);
    Procedure SetKeepOpen(Const aValue: Boolean);
    procedure SetPath(aPath: string);
    Procedure SetShowFile(Const aValue: Boolean);
    procedure SetTag(aTag: string);
    Procedure SetWhere(AValue: string);
    Procedure AppDeactivate(Sender: TObject);

  public
    Constructor Create(TheOwner: TComponent); override;
    procedure Search(const force: Boolean);

    property Path: string read FPath write SetPath;
    property Tag: string read FTag write SetTag;
    property Where: string read FWhere write SetWhere;
    Property AutoQuery: Integer Read FAutoQuery Write SetAutoQuery;
    Property Delay: Integer Read FDelay Write SetDelay;
    Property KeepOpen: Boolean Read FKeepOpen Write SetKeepOpen;
    Property ShowFile: Boolean Read FShowFile Write SetShowFile;
  end;

var
  MainSearchForm: TMainSearchForm;

implementation

uses shortcutHelpForm, uTools, uMainDataModule, LCLType;

{$R *.lfm}

{ TMainSearchForm }

Procedure TMainSearchForm.SearchEditChange(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

Procedure TMainSearchForm.SearchEditKeyPress(Sender: TObject; Var Key: char);
Begin
  if key = char(VK_RETURN) then
  begin
    Search(true);
    if DM.SQLQueryResult.RecordCount > 0 then
       ResultDBGrid.SetFocus;
  End;
end;

Procedure TMainSearchForm.SetPath(aPath: string);
begin
  FPath := aPath;
  edPath.Text := aPath;
  StatusBar.Panels[2].Text := FPath;
end;

Procedure TMainSearchForm.SetShowFile(Const aValue: Boolean);
Begin
  If FShowFile = aValue Then Exit;
  FShowFile := aValue;
End;

Procedure TMainSearchForm.SetAutoQuery(AValue: Integer);
Begin
  If FAutoQuery = AValue Then Exit;
  FAutoQuery := AValue;
End;

Procedure TMainSearchForm.ResizeResultGridColumn;
Begin
  if ResultDBGrid.Columns[1].Visible then
  begin
    ResultDBGrid.Columns[0].Width := ResultDBGrid.Width Div 2;
    ResultDBGrid.Columns[1].Width := ResultDBGrid.Width Div 2;
  End
  else
    ResultDBGrid.Columns[0].Width := ResultDBGrid.Width;
End;

Procedure TMainSearchForm.SetDelay(AValue: Integer);
Begin
  If FDelay = AValue Then Exit;
  FDelay := AValue;
  Timer1.Interval := AValue;
End;

Procedure TMainSearchForm.SetKeepOpen(Const aValue: Boolean);
Begin
  FKeepOpen := aValue;

  if not FKeepOpen then
    Application.OnDeactivate := @AppDeactivate
  else
    Application.OnDeactivate := nil;
End;

Procedure TMainSearchForm.SetTag(aTag: string);
Begin
  FTag := aTag;
  edTag.Text := aTag;
  StatusBar.Panels[3].Text := 'tag: ' + FTag;
End;

Procedure TMainSearchForm.Search(Const force: Boolean);
var
  lSearchTerm: string;
Begin
  if FPath <> edPath.Text then
     Path := edPath.Text;

  if FTag <> edTag.Text then
     Tag := edTag.Text;

  if FWhere <> edWhere.Text then
     Where := edWhere.Text;

  StatusBar.Panels[0].Text := '';
  StatusBar.Panels[1].Text := '';

    if (Length(SearchEdit.Text) >= AutoQuery) or force then
    begin
      if SearchEdit.Text <> '' then
      begin
        lSearchTerm := SearchEdit.Text;
        if chNormalize.Checked then
        begin
          lSearchTerm := NormalizeTerm(lSearchTerm);
          lSearchTerm := StringReplace(lSearchTerm, ' ', '* ', [rfReplaceAll, rfIgnoreCase]);
          lSearchTerm := Trim(lSearchTerm + '*');
        end;
      End;

      //If FPath <> '' Then
      //  StatusBar.Panels[2].Text := FPath;
      //
      //If FTag <> '' Then
      //  StatusBar.Panels[3].Text := FTag;

      StatusBar.Panels[0].Text := 'searching "' + lSearchTerm + '"...';

      DM.DBSearch(lSearchTerm, FPath, FTag);

      StatusBar.Panels[0].Text := lSearchTerm;
      StatusBar.Panels[1].Text := 'Found: ' + DM.SQLQueryCount.FieldByName('cnt').AsString;
    end
    else
    begin
      DM.SQLQueryResult.Close;
      StatusBar.Panels[0].Text := 'min chars of query: ' + IntToStr(AutoQuery);
    End;

    ResizeResultGridColumn;
End;

Procedure TMainSearchForm.SetWhere(AValue: string);
Begin
  If FWhere = AValue Then Exit;
  FWhere := AValue;
  edTag.Text := AValue;
  StatusBar.Panels[4].Text := 'Where: ' + AValue;
End;

Procedure TMainSearchForm.AppDeactivate(Sender: TObject);
Begin
  Self.Close;
End;

Constructor TMainSearchForm.Create(TheOwner: TComponent);
Begin
  Inherited Create(TheOwner);

  //ResultDBGridIcon.AutoFillColumns := True;
  //ResultDBGrid.AutoFillColumns := True;
  ResultDBGrid.Columns[1].Visible := ShowFile;
End;



Procedure TMainSearchForm.ResultDBGridDblClick(Sender: TObject);
begin
  acRun.Execute;
end;

Procedure TMainSearchForm.acRunUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0);
end;

Procedure TMainSearchForm.ResultDBGridIconDrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  bmpImage: TPicture;
  lIconName, lTag: string;
Begin
  lTag := ResultDBGridIcon.DataSource.DataSet.FieldByName('tag').AsString;
  if lTag <> '' then
  begin
    lIconName := GetEnvironmentVariable('HOME') + '/.mlocate.icons/' + lTag + '.png';

    if FileExists(lIconName) then
    with ResultDBGridIcon.Canvas do
    begin
      fillRect(rect);
      bmpImage := TPicture.Create;
      try
        if FileExists(lIconName) then
          bmpImage.LoadFromFile(lIconName)
        else
          bmpImage.Clear;

        Draw(Rect.Left+2, Rect.Top+2, bmpImage.Bitmap);
        //Column.Width := MainGridIcon.DefaultRowHeight;
      finally
        bmpimage.Free;
      end;
    end;
  End;
end;

Procedure TMainSearchForm.ResultDBGridKeyDown(Sender: TObject; Var Key: word);
begin
  if Key = 13 then
    acRun.Execute;
end;

Procedure TMainSearchForm.acRunExecute(Sender: TObject);
begin
  if DM.isAnnex and (settingsForm.AnnexCmd <> '') then
    RunUtils.RunSync(settingsForm.AnnexCmd, settingsForm.AnnexParams, DM.getDir, DM.getPath, '');

  RunUtils.RunAsync(DM.getCommand, '%p', DM.getDir, DM.getPath, '');
  if not FKeepOpen then
    MainSearchForm.Close;
end;

Procedure TMainSearchForm.acDownToListingUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := SearchEdit.Focused and (DM.SQLQueryResult.RecordCount > 0);
end;

Procedure TMainSearchForm.acDsExecute(Sender: TObject);
Var
  lDialog: TRawDataSet;
Begin
  lDialog := TRawDataSet.Create(self);
  try
    lDialog.ShowModal;
  Finally
    lDialog.Free;
  End;
end;

Procedure TMainSearchForm.acEditExecute(Sender: TObject);
Begin
  if DM.getPath <> '' then
  Begin
    RunUtils.RunAsync(settingsForm.EditorCmd, settingsForm.EditorParams, DM.getDir, DM.getPath, '');
  End;
end;

Procedure TMainSearchForm.acEditUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0)
        and (DM.getPath <> '') and (settingsForm.EditorCmd <> '');
end;

Procedure TMainSearchForm.acHelpExecute(Sender: TObject);
var
  i: Integer;
  lShortcutHelpFrm: TshortcutHelpFrm;
  lHint, lShortCut: String;
Begin
  lShortcutHelpFrm := TshortcutHelpFrm.Create(self);
  try
    lShortcutHelpFrm.TextMemo.Lines.Clear;

    for i := 0 to ActionList.ActionCount - 1 do
    begin
      lHint := (ActionList.Actions[i] as TAction).Hint;
      lShortCut := ShortCutToText((ActionList.Actions[i] as TAction).ShortCut);

      if lShortCut <> '' then
         lShortcutHelpFrm.TextMemo.Lines.Append(lShortCut + ' : ' + lHint);
    end;

    lShortcutHelpFrm.ShowModal;
  Finally
    lShortcutHelpFrm.Free;
  End;
end;

Procedure TMainSearchForm.acNormalizeExecute(Sender: TObject);
Begin
  // acNormalize.Checked := not acNormalize.Checked;
  //sbNormalize.down := acNormalize.Checked;
  //sbNormalize.AllowAllUp := not acNormalize.Checked;
end;

Procedure TMainSearchForm.acOpenDirectoryExecute(Sender: TObject);
Begin
  if DM.getDir <> '' then
  Begin
    RunUtils.RunAsync(settingsForm.FilemanagerCmd, settingsForm.FilemanagerParams, DM.getDir, '', '');
  End;
end;

Procedure TMainSearchForm.acOpenDirectoryUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0)
        and (DM.getPath <> '') and (settingsForm.FilemanagerCmd <> '');
end;

Procedure TMainSearchForm.acAppEndExecute(Sender: TObject);
begin
  Self.Close;
end;

Procedure TMainSearchForm.acAppEndUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := not FKeepOpen;
end;

Procedure TMainSearchForm.acCopyPathExecute(Sender: TObject);
Begin
  Clipboard.AsText := DM.getPath;
end;

Procedure TMainSearchForm.acCopyPathUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0)
        and (DM.getPath <> '');
end;

Procedure TMainSearchForm.acCommanderExecute(Sender: TObject);
Begin
  if DM.getDir <> '' then
  Begin
    RunUtils.RunAsync(settingsForm.CommanderCmd, settingsForm.CommanderParams, DM.getDir, DM.getPath, '');
  End;
end;

Procedure TMainSearchForm.acCommanderUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0)
        and (DM.getPath <> '') and (settingsForm.CommanderCmd <> '');
end;

Procedure TMainSearchForm.acSearchEditFocusExecute(Sender: TObject);
begin
  SearchEdit.SetFocus;
end;

Procedure TMainSearchForm.acDownToListingExecute(Sender: TObject);
begin
  ResultDBGrid.SetFocus;
  DM.SQLQueryResult.First;
end;

Procedure TMainSearchForm.acSettingsExecute(Sender: TObject);
Begin
  settingsForm.ShowModal;
end;

Procedure TMainSearchForm.acShowAdvancedExecute(Sender: TObject);
Begin
  AdvancedPanel.Visible := not AdvancedPanel.Visible;
  StatusBar.Visible := not StatusBar.Visible;
end;

Procedure TMainSearchForm.acShowHidePathColumnExecute(Sender: TObject);
Begin
  ResultDBGrid.Columns[1].Visible := not ResultDBGrid.Columns[1].Visible;
  ResizeResultGridColumn;
end;

Procedure TMainSearchForm.acTerminalExecute(Sender: TObject);
Begin
  if DM.getDir <> '' then
  Begin
    RunUtils.RunAsync(settingsForm.TerminalCmd, settingsForm.TerminalParams, DM.getDir, '', '');
  End;
end;

Procedure TMainSearchForm.acTerminalUpdate(Sender: TObject);
Begin
  (Sender as TAction).Enabled := (DM.SQLQueryResult.RecordCount > 0)
        and (DM.getPath <> '') and (settingsForm.TerminalCmd <> '');
end;

Procedure TMainSearchForm.btnSearchClick(Sender: TObject);
Begin
  Search(true);
end;

Procedure TMainSearchForm.FormResize(Sender: TObject);
Begin
  ResizeResultGridColumn;
end;

Procedure TMainSearchForm.IdleTimer1Timer(Sender: TObject);
Begin
  Timer1.Enabled := false;
  Search(false);
end;

end.
