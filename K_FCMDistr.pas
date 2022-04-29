unit K_FCMDistr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  N_Types, N_BaseF,
  K_Types;

type
  TK_FormCMDistr = class(TN_BaseForm)
    StatusBar: TStatusBar;
    BtOK: TButton;
    LbShowInfo: TLabel;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msInfo );
  public
    { Public declarations }
    DemoDistrBuildFlag : Boolean;    // Demo Distributive Build Flag
    AttrsSectionName : string;
  end;

var
  K_FormCMDistr: TK_FormCMDistr;

implementation

uses
  K_CLib0, K_CLib, K_Arch, K_UDC, K_CM0,
  N_CM1, N_Lib0, N_Lib1;

{$R *.dfm}

//************************************************* TK_FormCMDistr.ShowDump ***
//
procedure TK_FormCMDistr.ShowDump( const ADumpLine : string; MesStatus : TK_MesStatus = K_msInfo );
begin
  if ADumpLine = '' then Exit;
  StatusBar.SimpleText := ADumpLine;
  if MesStatus <> K_msInfo then K_ShowMessage( ADumpLine );
end; //*** end of procedure TK_FormCMDistr.ShowDump

//************************************************* TK_FormCMDistr.FormShow ***
//
procedure TK_FormCMDistr.FormShow(Sender: TObject);
begin
  inherited;
  Timer.Enabled := true;
end; //*** end of procedure TK_FormCMDistr.FormShow

//*********************************************** TK_FormCMDistr.TimerTimer ***
//
procedure TK_FormCMDistr.TimerTimer(Sender: TObject);
type TN_IntFuncVoid  = function ( ): integer; stdcall;
var
  DFPLScriptExec : TK_DFPLScriptExec;
  PBCParams: TN_PBCParams;
  SL : TStringList;
  Mes : string;
  AddMes : string;
//  ResultPath : string;
  ResultName : string;
  DllHandle: HMODULE; // DLL Windows Handle
  DllFName : string;
  FuncName : AnsiString;
  PFunc : TN_IntFuncVoid;
  LibVer : Integer;

begin
  Timer.Enabled := false;
  // Put Exe Version to Source IniFile
  N_StringToMemIni('CMS_Main', 'BuildInfo', N_CMSVersion );

  // Start Distributive Files Creation
  DFPLScriptExec := TK_DFPLScriptExec.Create;
  DFPLScriptExec.OnShowInfo := ShowDump;
  with N_PBCaller do begin
    SaveParams ( @PBCParams );
    RectProgressBarInit( Self, Rect(5,-23,-6,-20), $00AA00 );
    SBPBProgressBarInit( 'Done ', StatusBar, nil );
    PBCProcOfObj := RectProgressBarDraw;
  end;
  K_SaveCompiledIniSPLFiles();

  SL := TStringList.Create;
  N_CurMemIni.ReadSectionValues( AttrsSectionName, SL );
  if SL.Count = 0 then
  begin
  // Old Distr Interface
    SL.Add( '(#DataFiles#)DFPL_Main.txt TF> *CMSDFPLLib|' );
    if DemoDistrBuildFlag or
    //*** CMS DEMO EXE Build
       N_MemIniToBool( 'CMS_Main', 'DemoMode', false ) then
    begin
      SL.Add( '*CMSDFPLLib|BuildCMSFilesEXEDemo VFE>' );
      ResultName := 'CMSuiteDemo';
    end
//    else if N_MemIniToBool( 'CMS_Main', 'FilesSyncMode', false ) then
    else if N_MemIniToString( 'CMS_Main', 'AppMode', '' ) = 'FilesSync' then
    begin
    //*** CMS FSync EXE Build
      SL.Add( '*CMSDFPLLib|BuildCMSFilesEXEFSync VFE>' );
      ResultName := 'CMSFSync';
    end
    else
    begin
    //*** CMS EXE Build
      SL.Add( '*CMSDFPLLib|BuildCMSFilesEXE VFE>' );
      ResultName := 'CMSuite';
    end;
    DFPLScriptExec.DFPLExecCommandsList( SL, K_mtMacroStart0+K_MVAppDirExe+K_mtMacroFin0+'!DistrFiles\' + ResultName, ResultName );
  end
  else
  begin
  // New Distr Interface
    DFPLScriptExec.DFPLSetMacroList( SL, TRUE );

    SL.Clear;
    SL.Add( '(#ResultPath#) RP>' );
    SL.Add( '(#ResultName#) RI+ *' );
    SL.Add( '(#LIBFile#) TF> *DFPLLib|' );
    SL.Add( '*DFPLLib|(#Script#) VFE>' );
    DFPLScriptExec.DFPLExecCommandsList( SL, '' );
  end;
//  DFPLScriptExec.DFPLExecCommandsList( SL, ResultPath, 'CMSuite' );

  Mes := 'CMS Distributive Files preparing is finished';
  if DFPLScriptExec.CommandWarningsCount > 0 then
    Mes := Mes + ' - ' + IntToStr(DFPLScriptExec.CommandWarningsCount)+ ' warnings or errors were detected!';

  AddMes := '';
  DllFName := DFPLScriptExec.DFPLGetCMListItem( 'COMClientDLL' );
  if DllFName <> '' then
  begin
  // Check COM Client Lib Version
      DllFName := K_ExpandFileName(DllFName);
      DllHandle := Windows.LoadLibrary( @DllFName[1] );
      if DllHandle = 0 then // some error
      begin
        AddMes := 'Error: COMClientLib DLL error: ' + SysErrorMessage( GetLastError() );
      end   // if ECDDllHandle = 0 then // some error
      else
      begin // if ECDDllHandle <> 0 then
        FuncName := 'CMSGetLibVer';
        PFunc := GetProcAddress( DllHandle, @FuncName[1] );
        if not Assigned(PFunc) then // CMSGetLibVer is not loaded
        begin
          AddMes := 'Error: CMSGetLibVer is not loaded';
        end   // if not Assigned(PFunc) then // CMSGetLibVer is not loaded
        else
        begin // if Assigned(PFunc) then
          LibVer := PFunc();
          if LibVer <> K_CMSComLibVer then
            AddMes := format( 'Error: Wrong COMClientLib DLL ver=%d. Needed ver=%d', [LibVer,K_CMSComLibVer] );
        end;  // if Assigned(PFunc) then 
        FreeLibrary( DllHandle );
      end; // if ECDDllHandle <> 0 then

    if AddMes <> '' then
      AddMes := #13#10 + AddMes;

  end; // if DllFName <> '' then

  LbShowInfo.Caption := Mes + AddMes;
  N_Dump1Str( LbShowInfo.Caption );

  SL.Free;
  DFPLScriptExec.Free;

  N_PBCaller.RestoreParams ( @PBCParams );
  BtOK.Enabled := TRUE;

end; //*** end of procedure TK_FormCMDistr.TimerTimer

procedure TK_FormCMDistr.BtOKClick(Sender: TObject);
begin
  Close();
end; // procedure TK_FormCMDistr.BtOKClick

//*********************************************** TK_FormCMDistr.FormCreate ***
//
procedure TK_FormCMDistr.FormCreate(Sender: TObject);
begin
  inherited;
  AttrsSectionName := 'CMSDISTR_DFPL';
end; //*** end of procedure TK_FormCMDistr.FormCreate

end.
