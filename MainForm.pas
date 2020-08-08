unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, VCLTee.TeCanvas, Vcl.Mask;

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
    panLock: TPanel;
    grdLock: TGridPanel;
    txtCode: TMaskEdit;
    panLockCommands: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure txtCodeChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cmdTestClick(Sender: TObject);
    procedure cmdChangeStatusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    _IsActive: boolean;
    _RegErrMsgShowed: boolean;
    procedure _SetIsActive(const aNewValue: boolean);
    function _GetIsActive: boolean;
    procedure _SetAutoStart(const aNewValue: boolean);
    function _GetAutoStart: boolean;
    procedure _AdjustUIByAutoStart;
    function _GetActivationCommand: string;
  public
    property IsActive: boolean Read _GetIsActive Write _SetIsActive;
    property AutoStart: boolean Read _GetAutoStart Write _SetAutoStart;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.MaskUtils
  , Registry
  , System.UITypes;

const
  CERBERO_REGISTRY_KEY = 'cerbero\start';
  CERBERO_ACTIVATION_PARAM = 'lock';

{ TfrmMain }

procedure TfrmMain.cmdChangeStatusClick(Sender: TObject);
begin

  AutoStart := not AutoStart;
  _RegErrMsgShowed := false;

end;

procedure TfrmMain.cmdTestClick(Sender: TObject);
begin

  IsActive := true;

end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin

  _AdjustUIByAutoStart;

  if IsActive then
    txtCode.SetFocus;

  _RegErrMsgShowed := false;

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  CanClose := not IsActive;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  IsActive := (Trim(LowerCase(ParamStr(1))) = LowerCase(CERBERO_ACTIVATION_PARAM));

end;

procedure TfrmMain.FormShow(Sender: TObject);
begin

//  _RegErrMsgShowed := false;

end;

procedure TfrmMain.txtCodeChange(Sender: TObject);
begin

  if txtCode.EditText.Replace('_', '').Length = txtCode.MaxLength then
  begin
    Hide;
    IsActive := false;
    Close;
  end;

end;

procedure TfrmMain._AdjustUIByAutoStart;
begin

  if (not Visible) or IsActive then
    Exit;

  if AutoStart then
  begin
    cmdChangeStatus.Caption := 'DISATTIVA';
    cmdChangeStatus.Font.Color := clRed;
    lblStatus.Caption := 'ATTIVATO';
    lblStatus.Font.Color := clGreen;
  end
  else
  begin
    cmdChangeStatus.Caption := 'ATTIVA';
    cmdChangeStatus.Font.Color := clGreen;
    lblStatus.Caption := 'DISATTIVATO';
    lblStatus.Font.Color := clRed;
  end;


end;

function TfrmMain._GetActivationCommand: string;
var
  aEXEPathFileName: string;

begin

  aEXEPathFileName := ExcludeTrailingPathDelimiter(ParamStr(0));
  Result := Format('"%s" %s', [aEXEPathFileName, CERBERO_ACTIVATION_PARAM]);

end;

function TfrmMain._GetAutoStart: boolean;
var
  aRegistry: TRegistry;
  aRegValue: string;
  aValue: string;

begin

    Result := false;
    aValue := Trim(LowerCase(_GetActivationCommand));

    try
      aRegistry := TRegistry.Create(KEY_ALL_ACCESS);
      try
        aRegistry.RootKey := HKEY_LOCAL_MACHINE;
        if aRegistry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', false) then
        begin
          try
            aRegValue := Trim(LowerCase(aRegistry.ReadString(CERBERO_REGISTRY_KEY)));
            Result := (aValue = aRegValue);
          finally
            aRegistry.CloseKey;
          end;
        end
        else
        begin
          if not _RegErrMsgShowed then
          begin
            MessageDlg('Accesso al registry non consentito. Devi eseguire il programma come amministratore.', mtError,
                        [mbOk], 0, mbOk);
            _RegErrMsgShowed := true;
          end;
        end;
      finally
        FreeAndNil(aRegistry);
      end;
    except
      on E: Exception do
      begin
        Result := false;
        if not _RegErrMsgShowed then
        begin
          MessageDlg(E.Message, mtError, [mbOk], 0, mbOk);
          _RegErrMsgShowed := true;
        end;
      end;
    end;

end;

function TfrmMain._GetIsActive: boolean;
begin

  Result := _IsActive;

end;

procedure TfrmMain._SetAutoStart(const aNewValue: boolean);
var
  aRegistry: TRegistry;
  aValue: string;

begin

  if AutoStart = aNewValue then
    Exit;

  try
    aRegistry := TRegistry.Create(KEY_ALL_ACCESS);
    try
      aRegistry.RootKey := HKEY_LOCAL_MACHINE;
      if aRegistry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true) then
      begin
        try
          if aNewValue then
          begin
            aValue := _GetActivationCommand;
            aRegistry.WriteString(CERBERO_REGISTRY_KEY, aValue);
          end
          else
            aRegistry.WriteString(CERBERO_REGISTRY_KEY, '');
        finally
          aRegistry.CloseKey;
        end;
        end
      else
      begin
        if not _RegErrMsgShowed then
        begin
          MessageDlg('Accesso al registry non consentito. Devi eseguire il programma come amministratore.', mtError,
                      [mbOk], 0, mbOk);
          _RegErrMsgShowed := true;
        end;
      end;
    finally
      FreeAndNil(aRegistry);
    end;
  except
    on E: Exception do
        if not _RegErrMsgShowed then
        begin
          MessageDlg(E.Message, mtError, [mbOk], 0, mbOk);
          _RegErrMsgShowed := true;
        end;
  end;

  _AdjustUIByAutoStart;

end;

procedure TfrmMain._SetIsActive(const aNewValue: boolean);
begin

  LockWindowUpdate(Handle);

  try
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
      panSettings.Visible := false;
      panLock.Visible := true;
      if Visible then
        txtCode.SetFocus;
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
      panSettings.Visible := true;
      panLock.Visible := false;
      _AdjustUIByAutoStart
    end;
  finally
    LockWindowUpdate(0);
  end;

  _IsActive := aNewValue;

end;

end.
