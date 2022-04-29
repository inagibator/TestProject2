unit K_FCMFSACopy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_Lib0, K_FPathNameFr, K_CM0, N_FNameFr;

type
  TK_FormCMFSACopy = class(TN_BaseForm)
    BtClose: TButton;
    BtStart: TButton;
    SSPNFrame: TK_FPathNameFrame;
    GBArchiving: TGroupBox;
    LbEDProcCount: TLabeledEdit;
    PBProgress: TProgressBar;
    LbInfo: TLabel;
    DSPNFrame: TK_FPathNameFrame;
    CLFNFrame: TN_FileNameFrame;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }

    // New Vars
    CopyCount : Integer;               // Should be Archived
    SSCopyPath, DSCopyPath : string;
    CList : TStringList;
    procedure OnSSPathChange();
    procedure OnDSPathChange();
    procedure OnCLFNChange();
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMFSACopy: TK_FormCMFSACopy;

procedure K_CMFSACopyDlg( );

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CLib0, K_Script1, K_CML1F, K_UDT2, {K_FEText,}
  N_Lib1, N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2, K_FCMFSCopy;



//*********************************************************** K_CMFSCopyDlg ***
//  File Storage Copy Dialog
//
procedure K_CMFSACopyDlg( );
begin
  N_Dump1Str( 'K_CMFSACopyDlg Start' );

  K_FormCMFSACopy := TK_FormCMFSACopy.Create(Application);
  with K_FormCMFSACopy do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_Dump1Str( 'K_CMArchSaveDlg before show' );
    ShowModal();
//    N_Dump1Str( 'K_CMArchSaveDlg after show' );

    K_FormCMFSACopy := nil;

  end;
  N_Dump1Str( 'K_CMFSACopyDlg Fin' );

end; // procedure K_CMUTPrepDBDataDlg

//********************************************** TK_FormCMFSACopy.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSACopy.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;
  CList := TStringList.Create;
  SSPNFrame.OnChange := OnSSPathChange;
  DSPNFrame.OnChange := OnDSPathChange;
  CLFNFrame.OnChange := OnCLFNChange;
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;
  CopyCount := 0;
  SSPNFrame.OnChange;
  DSPNFrame.OnChange;
  CLFNFrame.OnChange;
end; // TK_FormCMFSACopy.FormShow


//**************************************** TK_FormCMFSACopy.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSACopy.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
// Clear Global context and free objects
  CList.Free;

end; // TK_FormCMFSACopy.FormCloseQuery

//***************************************** TK_FormCMFSACopy.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSACopy.BtStartClick(Sender: TObject);
var
  CopyFErrCount, CopyRCount, CopyErrCount : Integer;
  i, CInd : Integer;
  WStr, SS, DS : string;

 label EFormat;
  function FCopyFile( const ASrcFile, ADstFile : string ) : Integer;
  var
    ResCode : Integer;
  begin
    ResCode := K_CopyFile( ASrcFile, ADstFile, [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
    Result := 0;
    if ResCode > 0 then
      Result := 1;
    case ResCode of
      0: N_Dump2Str( 'CopyFSA>> Copy File ' + ASrcFile );
      3: N_Dump1Str( 'CopyFSA>> Couldn''t copy Src doesn''t exist ' + ASrcFile );
      4: N_Dump1Str( 'CopyFSA>> Couldn''t copy ' + ASrcFile );
      5: N_Dump1Str( 'CopyFSA>> Couldn''t create Dst path ' + ADstFile );
    end;

  end; // function FCopyFile

begin

  LbInfo.Caption  := ' Copying is in process ... ';
  LbInfo.Refresh;
  CopyErrCount := 0;
  CopyFErrCount := 0;
  CopyRCount := 0;
  for i := 0 to CList.Count - 1 do
  begin
  // Pars List String
    WStr := CList[i];
    if WStr = '' then Continue; // skip empty string
    CInd := Pos( ' ', WStr );
    if CInd = 0 then
    begin
EFormat: //*****
      Inc(CopyFErrCount);
      N_Dump1Str( 'CopyFSA>> Wrong list string forvard>> ' + WStr );
      Continue;
    end;
    SS := Copy( WStr, 1, CInd - 1 );
    DS := Copy( WStr, CInd + 1, Length(WStr) );
    if (DS = '') or ( SS = '' ) then goto EFormat;
    if FCopyFile(SSCopyPath + SS, DSCopyPath + DS) <> 0 then
      Inc(CopyErrCount)
    else
      Inc(CopyRCount);
    if CopyCount > 0 then
      PBProgress.Position := Round(1000 * (i+1) / CopyCount);

  end;
  WStr := format( 'All %d lines are processed. %d lines have wrong format.'#13#10+
                  '%d files are copied. %d files are not copied. All details in log',
                  [CopyCount,CopyFErrCount,CopyRCount,CopyErrCount]);
  K_CMShowMessageDlg( WStr, mtInformation );
  LbInfo.Caption  := ' Copying is finished ';
  LbInfo.Refresh;

end; // TK_FormCMFSACopy.BtStartClick


//************************ ************* TK_FormCMFSACopy.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSACopy.CurStateToMemIni;
begin
  inherited;
  N_ComboBoxToMemIni( 'CLFNFrame', CLFNFrame.mbFileName );
  N_ComboBoxToMemIni( 'SSPNFrame', SSPNFrame.mbPathName );
  N_ComboBoxToMemIni( 'DSPNFrame', DSPNFrame.mbPathName );
end; // procedure TK_FormCMFSACopy.CurStateToMemIni

//************************************** TK_FormCMFSACopy.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSACopy.MemIniToCurState;
begin
  inherited;
  N_MemIniToComboBox( 'CLFNFrame', CLFNFrame.mbFileName );
  N_MemIniToComboBox( 'SSPNFrame', SSPNFrame.mbPathName );
  N_MemIniToComboBox( 'DSPNFrame', DSPNFrame.mbPathName );

end; // procedure TK_FormCMFSACopy.MemIniToCurState

//************************************** TK_FormCMFSACopy.OnSSPathChange ***
// On Source segment path change
//
procedure TK_FormCMFSACopy.OnSSPathChange;
begin
  SSCopyPath := SSPNFrame.mbPathName.Text;

  if (SSCopyPath = '') or not DirectoryExists(SSCopyPath) then
  begin
    BtStart.Enabled := FALSE;
    SSCopyPath := '';
    Exit;
  end;

  SSCopyPath := IncludeTrailingPathDelimiter(SSCopyPath);

  BtStart.Enabled := (CopyCount > 0) and (DSCopyPath <> '');
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMFSACopy.OnSSPathChange

//************************************** TK_FormCMFSACopy.OnDSPathChange ***
// On Dest segment path change
//
procedure TK_FormCMFSACopy.OnDSPathChange;
begin
  if DSPNFrame.mbPathName.Text = '' then
  begin
    BtStart.Enabled := FALSE;
    Exit;
  end;

  DSCopyPath := IncludeTrailingPathDelimiter(DSPNFrame.mbPathName.Text);

  BtStart.Enabled := (CopyCount > 0) and (SSCopyPath <> '');
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMFSACopy.OnDSPathChange

//************************************** TK_FormCMFSACopy.OnCLFNChange ***
// On Dest segment path change
//
procedure TK_FormCMFSACopy.OnCLFNChange;
begin
  CopyCount := 0;
  if CLFNFrame.mbFileName.Text = '' then
  begin
    BtStart.Enabled := FALSE;
    Exit;
  end;

  CList.LoadFromFile(CLFNFrame.mbFileName.Text);

  CopyCount := CList.Count;

  BtStart.Enabled := (CopyCount > 0)    and
                     (SSCopyPath <> '') and
                     (DSCopyPath <> '');
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMFSACopy.OnCLFNChange

end.
