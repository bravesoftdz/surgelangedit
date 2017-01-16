unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Menus,
  ActnList, StdActns, Grids;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    ActionList1: TActionList;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    StringGrid1: TStringGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
  private
    { private declarations }
    LastFile: string;
    FileSaved: boolean;
    MaxWidth: integer;
    procedure LoadLanguageFromFile(FileName: string);
    procedure SaveLanguageToFile(FileName: string);
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.MenuItem2Click(Sender: TObject);
begin
  if (LastFile <> '') and (not FileSaved) then
  begin
    case Dialogs.QuestionDlg('Unsaved changes', 'Do you want to save the changes?',
        TMsgDlgType.mtConfirmation, [mrYes, mrNo, mrCancel], '') of
      mrYes: MenuItem6Click(nil);
      mrCancel: exit;
    end;
  end;
  if FileOpen1.Dialog.Execute then
  begin
    LastFile := FileOpen1.Dialog.FileName;
    LoadLanguageFromFile(LastFile);
    FileSaved := True;
  end;
end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
begin
  if FileSaveAs1.Dialog.Execute then
  begin
    LastFile := FileSaveAs1.Dialog.FileName;
    SaveLanguageToFile(LastFile);
    FileSaved := True;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (LastFile <> '') and (not FileSaved) then
    case Dialogs.QuestionDlg('Unsaved changes', 'Do you want to save the changes?',
        TMsgDlgType.mtConfirmation, [mrYes, mrNo, mrCancel], '') of
      mrYes: MenuItem6Click(nil);
      mrNo: CanClose := True;
      mrCancel: CanClose := False;
    end;
end;

procedure TfrmMain.MenuItem6Click(Sender: TObject);
begin
  if LastFile <> '' then
  begin
    SaveLanguageToFile(LastFile);
    FileSaved := True;
  end
  else
    MenuItem3Click(nil);
end;

procedure TfrmMain.StringGrid1EditingDone(Sender: TObject);
begin
  FileSaved := False;
end;

procedure TfrmMain.LoadLanguageFromFile(FileName: string);
var
  s, t: TStringList;
  i: integer;
begin
  MaxWidth := 0;

  StringGrid1.BeginUpdate;
  StringGrid1.RowCount := 1;

  s := TStringList.Create;
  s.LoadFromFile(FileName);
  for i := 0 to s.Count - 1 do
  begin
    t := TStringList.Create;

    if (s[i] = '') or (s[i] = #9) then
      Continue;

    t.CommaText := s[i];

    if t[0] = '//' then
      Continue;

    if t.Count < 2 then
    begin
      ShowMessage('Wrong file format at line ' + IntToStr(i) + '. Exiting...');
      Application.Terminate;
    end;

    StringGrid1.RowCount := StringGrid1.RowCount + 1;
    StringGrid1.Cells[1, StringGrid1.RowCount - 1] := t[0];
    StringGrid1.Cells[2, StringGrid1.RowCount - 1] := t[1];

    if Length(t[0]) > MaxWidth then
      MaxWidth := Length(t[0]);

    t.Free;
  end;
  s.Free;

  StringGrid1.AutoSizeColumns;
  StringGrid1.EndUpdate();
end;

procedure TfrmMain.SaveLanguageToFile(FileName: string);

  function PrettyPrint(s: string): string;
  var
    n, i: integer;
  begin

    n := MaxWidth - Length(s);

    for i:=0 to n do
      s := s + ' ';

    Result := s;
  end;

var
  s: TStringList;
  i: integer;
begin
  s := TStringList.Create;
  for i := 1 to StringGrid1.RowCount - 1 do
    s.AddText(PrettyPrint(StringGrid1.Cells[1, i]) + '"' + StringGrid1.Cells[2, i] + '"');
  s.SaveToFile(FileName);
  s.Free;
end;

end.
