unit K_FRunDFPLScript;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList, ComCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_Lib0, N_FNameFr, N_BaseF, N_Lib2, N_Types,
  K_Script1, K_CLib0, K_CLib, K_Types, K_FPathNameFr, ExtCtrls;

type TK_DFPLFileDirElem = packed record
  ScriptName : string;
  ParamsName : string;
  RIniFileName   : string;
  RIniFileEncodeFlag : Byte;
  RIniFileSaveFlag : Byte;
end;

type
  TK_FormRunDFPLScript = class(TN_BaseForm)
    ActionList1: TActionList;
    RunDFPL: TAction;
    ReloadDFPLScripts: TAction;
    StatusBar: TStatusBar;
    GBScript: TGroupBox;
    BtRun: TButton;
    CmBScripts: TComboBox;
    GBIniParams: TGroupBox;
    ChBEncriptIni: TCheckBox;
    ChBSkipSaveIni: TCheckBox;
    EdIniName: TEdit;
    Label1:  TLabel;
    DstPathNameFrame: TK_FPathNameFrame;
    Panel1: TPanel;
    DFPLFileFrame: TN_FileNameFrame;
    BtPrep: TButton;
    BtSetParams: TButton;
    SetScriptParams: TAction;
    GBSrcContext: TGroupBox;
    SrcIniFileFrame: TN_FileNameFrame;
    SrcPathNameFrame: TK_FPathNameFrame;
    CmBPackDist: TComboBox;
    LbPackDistr: TLabel;
    GBDstContext: TGroupBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RunDFPLExecute(Sender: TObject);
    procedure ReloadDFPLScriptsExecute(Sender: TObject);
    procedure CmBScriptsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormShow(Sender: TObject);
    procedure SetScriptParamsExecute(Sender: TObject);
  private
    { Private declarations }
    WUnit : TK_UDUnit;
    CurFileName   : string;
    CurScriptName : string;
    DFPLScriptExecute : TK_DFPLScriptExec;
    MemTextFragms : TN_MemTextFragms;
    CurRunScript : TStringList;
    CurScriptParams : TStringList;
    CurDFPLDir : TStringList;
    DFPLStateChanged : Boolean;
    PBCParams: TN_PBCParams;
    CurDirElem : TK_DFPLFileDirElem;

    procedure SaveDFPLState;
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
    procedure OnScriptFileChange( );
    procedure ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msInfo );
  end;

var
  K_FormRunDFPLScript: TK_FormRunDFPLScript;
function K_GetFormRunDFPLScript( AOwner : TN_BaseForm = nil ) : TK_FormRunDFPLScript;

implementation

uses N_Lib1, N_ClassRef,
  K_Arch, K_Sparse1, {K_IWatch, }K_FEText;

{$R *.dfm}

function K_GetFormRunDFPLScript( AOwner : TN_BaseForm = nil ) : TK_FormRunDFPLScript;
begin
  Result := TK_FormRunDFPLScript.Create(Application);
//  Result.BaseFormInit( AOwner );
  Result.BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
end;

//***********************************  TK_FormRunDFPLScript.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormRunDFPLScript.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'DFPLPathsHistory', DstPathNameFrame.mbPathName );
//  N_ComboBoxToMemIni( 'DFPLFilesHistory', DFPLFileFrame.mbFileName ); // Move to Script Execute Code
  N_ComboBoxToMemIni( 'DFPLSrcPathsHistory', SrcPathNameFrame.mbPathName );
  N_ComboBoxToMemIni( 'DFPLSrcIniFilesHistory', SrcIniFileFrame.mbFileName );
  N_StringToMemIni( Name, 'DFPLScriptCapt', CurScriptName );
  N_IntToMemIni( Name, 'PackMode', CmBPackDist.ItemIndex );
end; // end of procedure TK_FormRunDFPLScript.CurStateToMemIni

//***********************************  TK_FormRunDFPLScript.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormRunDFPLScript.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'DFPLPathsHistory', DstPathNameFrame.mbPathName );
  N_MemIniToComboBox( 'DFPLFilesHistory', DFPLFileFrame.mbFileName );
  N_MemIniToComboBox( 'DFPLSrcPathsHistory', SrcPathNameFrame.mbPathName );
  N_MemIniToComboBox( 'DFPLSrcIniFilesHistory', SrcIniFileFrame.mbFileName );
  CurScriptName := N_MemIniToString( Name, 'DFPLScriptCapt', CurScriptName );
  CmBPackDist.ItemIndex := N_MemIniToInt( Name, 'PackMode', 0 );
end; // end of procedure TK_FormRunDFPLScript.MemIniToCurState


//************************************************ TK_FormRunDFPLScript.FormCreate
//
procedure TK_FormRunDFPLScript.FormCreate(Sender: TObject);
begin
  inherited;
  DstPathNameFrame.SelectCaption := 'Выбор результирующего пути';
  WUnit := nil;
  DFPLFileFrame.OnChange := OnScriptFileChange;
  DFPLScriptExecute := TK_DFPLScriptExec.Create;
  DFPLScriptExecute.OnShowInfo := ShowDump;
  with N_PBCaller do begin
    SaveParams ( @PBCParams );
    RectProgressBarInit( Self, Rect(5,-23,-6,-20), $00AA00 );
    SBPBProgressBarInit( 'Выполнено ', StatusBar, nil );
    PBCProcOfObj := RectProgressBarDraw;
//    PBCProcOfObj := SBPBProgressBarDraw;
  end;
  MemTextFragms := TN_MemTextFragms.Create;
  MemTextFragms.MTCreateParams := K_DFCreatePlain;
  CurRunScript := TStringList.Create;
  CurScriptParams := TStringList.Create;
  SetScriptParams.Enabled := false;
end; //*** end of procedure TK_FormRunDFPLScript.FormCreate

//************************************************ TK_FormRunDFPLScript.FormCloseQuery
//
procedure TK_FormRunDFPLScript.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  inherited;

  SaveDFPLState;

  DFPLScriptExecute.Free;
  CurRunScript.Free;
  CurScriptParams.Free;
  MemTextFragms.Free;
  N_PBCaller.RestoreParams ( @PBCParams );
end; //*** end of procedure TK_FormRunDFPLScript.FormCloseQuery

//************************************************ TK_FormRunDFPLScript.FormClose
//
procedure TK_FormRunDFPLScript.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
// for call N_BaseForm.FormClose while form is closed
end; //*** end of procedure TK_FormRunDFPLScript.FormClose

//************************************************ TK_FormRunDFPLScript.FormShow
//
procedure TK_FormRunDFPLScript.FormShow(Sender: TObject);
begin
  OnScriptFileChange();
end; //*** end of procedure TK_FormRunDFPLScript.FormShow

//************************************************ TK_FormRunDFPLScript.FormShow
//
procedure TK_FormRunDFPLScript.SaveDFPLState;
begin
  if DFPLStateChanged and
     (MessageDlg( 'Сохранить изменения в файле '+CurFileName+'?',
                  mtConfirmation, mbOKCancel, 0 ) = mrOk) then
    MemTextFragms.SaveToVFile( CurFileName, K_DFCreatePlain );
  DFPLStateChanged := false;
end; //*** end of procedure TK_FormRunDFPLScript.FormShow


//************************************************ TK_FormRunDFPLScript.RunSPLExecute
//
procedure TK_FormRunDFPLScript.RunDFPLExecute(Sender: TObject);
var
  InstallPath : string;
  CInd, PInd  : Integer;
  CParams     : TStrings;
  Info : string;
  MesStatus : TK_MesStatus;
begin
  InstallPath := DstPathNameFrame.mbPathName.Text;

  if CmBScripts.ItemIndex = -1 then begin
    ShowDump( 'Не задан набор команд', K_msError );
    Exit;
  end;

  CInd := MemTextFragms.MTFragmsList.IndexOf( CurDirElem.ScriptName );
  if CInd = -1 then begin
    ShowDump( 'Отсутствует набор команд - ' + CurDirElem.ScriptName, K_msError );
    Exit;
  end;

  PInd := -1;
  if SetScriptParams.Enabled then begin
    PInd := MemTextFragms.MTFragmsList.IndexOf( CurDirElem.ParamsName );
    if PInd = -1 then begin
      ShowDump( 'Отсутствует набор параметров - ' + CurDirElem.ParamsName, K_msError );
      Exit;
    end;
  end;

  if InstallPath = '' then begin
    ShowDump( 'Не задан результирующий путь', K_msError );
    Exit;
  end;

  InstallPath := K_ExpandFileNameByDirPath( K_MVAppDirExe,
              IncludeTrailingPathDelimiter( InstallPath ) );

  if not K_ForceDirPathDlg( InstallPath ) then
  begin
    ShowDump( 'Не удалось создать путь ' + InstallPath, K_msWarning );
    Exit;
  end;

  CurRunScript.Assign( TStrings( MemTextFragms.MTFragmsList.Objects[CInd] ) );

  CParams := nil;
  if  PInd  <> -1 then begin
    CurScriptParams.Assign( TStrings( MemTextFragms.MTFragmsList.Objects[PInd] ) );
    CParams := CurScriptParams;
    if CmBPackDist.ItemIndex >= 0 then
      with CmBPackDist do
        CurScriptParams.Add( 'PackDistrMode=' + CmBPackDist.Items[ItemIndex] );
  end;

  ShowDump( 'Начато выполнение набора команд "'+CurDirElem.ScriptName+'"' );
  DFPLScriptExecute.DFPLSetSrcContext( SrcIniFileFrame.mbFileName.Text,
                                   SrcPathNameFrame.mbPathName.Text );
  DFPLScriptExecute.DFPLSetMacroList( CParams );
  DFPLScriptExecute.CommandWarningsCount := 0;
  DFPLScriptExecute.DFPLExecCommandsList( CurRunScript, InstallPath, EdIniName.Text,
                                  ChBEncriptIni.Checked, ChBSkipSaveIni.Checked );

  if DFPLScriptExecute.CommandWarningsCount > 0 then begin
    Info := ', обнаружено ' + IntToStr(DFPLScriptExecute.CommandWarningsCount)+ ' ошибок или предупреждений';
    MesStatus := K_msWarning;
  end else begin
    Info := '';
    MesStatus := K_msInfo;
  end;
//  ShowDump( 'Завершено выполнение набора команд "'+CurDirElem.ScriptName+'"'+Info, MesStatus );
  ShowDump( 'Завершено выполнение набора команд'+Info, MesStatus );
end; //*** end of procedure TK_FormRunDFPLScript.RunDFPLExecute

//************************************************ TK_FormRunDFPLScript.PrepUnitExecute
//
procedure TK_FormRunDFPLScript.ReloadDFPLScriptsExecute(Sender: TObject);
begin
  OnScriptFileChange();
end; //*** end of procedure TK_FormRunDFPLScript.PrepUnitExecute

//************************************************ TK_FormRunDFPLScript.OnScriptFileChange
//
procedure TK_FormRunDFPLScript.OnScriptFileChange( );
var
  i : Integer;
begin
  with MemTextFragms do begin

    SaveDFPLState;

    Clear;
    CurFileName := DFPLFileFrame.mbFileName.Text;
    if not AddFromVFile( CurFileName ) then begin
      ShowDump( 'Файл ' + CurFileName + ' не найден', K_msError );
      Exit;
    end;
    CmBScripts.Items.Clear;
    CmBScripts.ItemIndex := -1;
    if CurFileName = '' then Exit;

    i := MTFragmsList.IndexOf( 'DFPLFileDir' );
    if i = -1 then begin
      ShowDump( 'Отсутствует каталог скриптов', K_msError );
      Exit;
    end;

    CurDFPLDir := TStringList(MTFragmsList.Objects[i]);
    for i := 0 to CurDFPLDir.Count - 1 do
      CmBScripts.Items.Add( CurDFPLDir.Names[i] );

    with CmBScripts do begin
      ItemIndex := Items.IndexOf( CurScriptName );
      if ItemIndex = -1 then ItemIndex := 0;
    end;

    CmBScriptsChange(nil);
  end;
  DFPLScriptExecute.CallMemTextFragms := MemTextFragms.MTFragmsList;
  N_ComboBoxToMemIni( 'DFPLFilesHistory', DFPLFileFrame.mbFileName );

end; //*** end of procedure TK_FormRunDFPLScript.OnScriptFileChange

//************************************************ TK_FormRunDFPLScript.ShowDump
//
procedure TK_FormRunDFPLScript.ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msInfo );
begin
  if ADumpLine = '' then Exit;
  StatusBar.SimpleText := ADumpLine;
  if MesStatus <> K_msInfo then K_ShowMessage( ADumpLine );
  N_Dump1Str( ADumpLine );
//  K_InfoWatch.AddInfoLine( ADumpLine, MesStatus );
end; //*** end of procedure TK_FormRunDFPLScript.ShowDump

//************************************************ TK_FormRunDFPLScript.CmBScriptsChange
//
procedure TK_FormRunDFPLScript.CmBScriptsChange(Sender: TObject);
begin
  with CmBScripts do
    if ItemIndex <> -1 then begin
      CurScriptName := Items[ItemIndex];
      if K_SPLValueFromString( CurDirElem, K_GetTypeCode( 'TK_DFPLFileDirElem' ).All,
                               CurDFPLDir.ValueFromIndex[ItemIndex] ) <> '' then begin
        ShowDump( 'Ошибка в каталоге DFPL - ' + CurDFPLDir[ItemIndex], K_msError );
        Exit;
      end;
      SetScriptParams.Enabled := (CurDirElem.ParamsName <> '') and (CurDirElem.ParamsName <> '*');
      EdIniName.Text := CurDirElem.RIniFileName;
      ChBEncriptIni.Checked := CurDirElem.RIniFileEncodeFlag <> 0;
      ChBSkipSaveIni.Checked := CurDirElem.RIniFileSaveFlag <> 0;
    end;
end; //*** end of procedure TK_FormRunDFPLScript.CmBScriptsChange

//************************************************ TK_FormRunDFPLScript.SetScriptParamsExecute
//
procedure TK_FormRunDFPLScript.SetScriptParamsExecute(Sender: TObject);
var
  PInd : Integer;
begin
  with MemTextFragms do begin
    PInd := MTFragmsList.IndexOf( CurDirElem.ParamsName );
    if PInd = -1 then begin
      ShowDump( 'Отсутствует набор параметров - ' + CurDirElem.ParamsName, K_msError );
      Exit;
    end;
    if K_GetFormTextEdit.EditStrings( TStrings( MemTextFragms.MTFragmsList.Objects[PInd] ),
         'Параметры скрипта' ) then
      DFPLStateChanged := true;
  end;
end; //*** end of procedure TK_FormRunDFPLScript.SetScriptParamsExecute

end.
