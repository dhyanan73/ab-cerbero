unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, VCLTee.TeCanvas;

type
  TfrmMain = class(TForm)
    grdMain: TGridPanel;
    panMain: TPanel;
    panSettings: TPanel;
    cmdChangeStatus: TButton;
    lblStatusTitle: TLabel;
    panStatus: TPanel;
    lblStatus: TLabel;
    cmdTest: TButton;
    cmdExit: TBitBtn;
    panCommands: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    _IsActive: boolean;
    procedure _SetIsActive(const aNewValue: boolean);
    function _GetIsActive: boolean;
  public
    property IsActive: boolean Read _GetIsActive Write _SetIsActive;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  IsActive := false;

end;

function TfrmMain._GetIsActive: boolean;
begin

  Result := _IsActive;

end;

procedure TfrmMain._SetIsActive(const aNewValue: boolean);
begin

  if aNewValue then
  begin
    Align := alClient;
    BorderIcons := [];
    BorderStyle := bsNone;
    FormStyle := fsStayOnTop;
    WindowState := wsMaximized;
    grdMain.ColumnCollection[0].Value := 25;
    grdMain.ColumnCollection[1].Value := 50;
    grdMain.ColumnCollection[2].Value := 25;
    grdMain.RowCollection[0].Value := 25;
    grdMain.RowCollection[1].Value := 50;
    grdMain.RowCollection[2].Value := 25;
  end
  else
  begin
    Align := alNone;
    BorderIcons := [biSystemMenu,biMinimize];
    BorderStyle := bsSingle;
    FormStyle := TFormStyle.fsNormal;
    WindowState := wsNormal;
    grdMain.ColumnCollection[0].Value := 0;
    grdMain.ColumnCollection[1].Value := 100;
    grdMain.ColumnCollection[2].Value := 0;
    grdMain.RowCollection[0].Value := 0;
    grdMain.RowCollection[1].Value := 100;
    grdMain.RowCollection[2].Value := 0;
  end;

  _IsActive := aNewValue;

end;

end.
