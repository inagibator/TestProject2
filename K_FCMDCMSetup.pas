unit K_FCMDCMSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask, ComCtrls,
  N_BaseF,
  K_CMDCMDLib, K_CMDCMGLibW;

type TLabeledEditArr = array [0..3] of TLabeledEdit;
type TLabArr = array [0..3] of TLabel;
type TShapeArr = array [0..3] of TShape;
type TIPortArr = array [0..3] of Integer;
type
  TK_FormCMDCMSetup = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    PageControl: TPageControl;
      TSQR: TTabSheet;
      TSGeneral: TTabSheet;
    BtConnect: TButton;
    GBStore: TGroupBox;
    Label8: TLabel;
    ShapeStoreState: TShape;
    LbStoreAetScu: TLabel;
    ChBCommitment: TCheckBox;
    ChBDCMAutoStore: TCheckBox;
    LEStoreIPAddr: TLabeledEdit;
    LEStorePortNum: TLabeledEdit;
    LEStorePACSAet: TLabeledEdit;
    GBQR: TGroupBox;
    Label1: TLabel;
    ShapeQRState: TShape;
    LbQRAetScu: TLabel;
    LEQRIPAddr: TLabeledEdit;
    LEQRPortNum: TLabeledEdit;
    LEQRPACSAet: TLabeledEdit;
    GBSComm: TGroupBox;
    Label3: TLabel;
    ShapeSCommState: TShape;
    LbSCommAetScu: TLabel;
    LESCommIPAddr: TLabeledEdit;
    LESCommPortNum: TLabeledEdit;
    LESCommPACSAet: TLabeledEdit;
    GBMWL: TGroupBox;
    Label5: TLabel;
    ShapeMWLState: TShape;
    LbMWLAetScu: TLabel;
    LEMWLIPAddr: TLabeledEdit;
    LEMWLPortNum: TLabeledEdit;
    LEMWLPACSAet: TLabeledEdit;
    ChBUseSameAttrs: TCheckBox;
    GBAetScu: TGroupBox;
    LEAetStoreSCP: TLabeledEdit;
    LEAetCMSuite: TLabeledEdit;
    procedure LEdPortChange(Sender: TObject);
    procedure BtConnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LEdServerNameChange(Sender: TObject);
    procedure ChBUseSameAttrsClick(Sender: TObject);
  private
    { Private declarations }
    FDCMDLib : TK_CMDCMDLib;
    SkipChange : Boolean;
    ServerConnectionIsDone : Boolean;
    TestConnectionIsDone : Boolean;
    LEQRArr    : TLabeledEditArr;
    LEStoreArr : TLabeledEditArr;
    LESCommArr : TLabeledEditArr;
    LEMWLArr   : TLabeledEditArr;
    LELabAet   : TLabeledEditArr;
    IPortArr   : TIPortArr;
    LabArr     : TLabArr;
    ShapeArr   : TShapeArr;
    procedure ShowConnectionState( AInd : Integer );
    procedure DefConnectionState( ALE : TLabeledEditArr; AInd : Integer);
    procedure CloseConnectionState( );
  public
    { Public declarations }
  end;

var
  K_FormCMDCMSetup: TK_FormCMDCMSetup;

function K_CMDCMSetupDlg() : Boolean;
function K_CMDCMSetupCMSuiteAetScu() : string;

implementation

{$R *.dfm}

uses
{$IF CompilerVersion >= 26.0}
     System.UITypes,
{$IFEND CompilerVersion >= 26.0}
     N_Types, N_Lib1, N_Lib0,
     K_CLib0, K_CM0, K_CMDCM;


/////////////////////////////////////////
// Get CMSuite AetScu Value
function K_CMDCMSetupCMSuiteAetScu() : string;
begin
  Result := N_MemIniToString( 'CMS_DCMAetScu', 'CMSuite', ''  );
  if Result = '' then
    Result := N_MemIniToString( 'CMS_DCMQRSettings', 'AETSCU', '' );
  if Result = '' then Result := 'Mediasuite';
end; // function K_CMDCMSetupAetScu

function K_CMDCMSetupDlg() : Boolean;
//type TRBInds = array[0..2] of Integer;
// Conv SettingsStoreMode To/From RadioButtonsGroup Index
//const ConvToFromDCMSStoreMode: TRBInds = (1,0,2);
{
var
  PI : PInteger;
  PC : PChar;
  S, S1 : string;
{}
begin
{
  S := '1234' + N_S;
  PChar(PI) := @S[1] - 8;
  S1 := S;
  SetLength(S1, 0);
  PC := @S[1];
  PC := @S[2];
  PChar(PI) := @(N_MemIniToString( 'CMS_Main', 'AppMode', 'AAA'  ))[1] - 8;
{}
  K_FormCMDCMSetup := TK_FormCMDCMSetup.Create(Application);
  with K_FormCMDCMSetup do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR, rspfShiftAll] );

    // Get DICOM QR settings store mode
//    RGQRType.ItemIndex := ConvToFromDCMSStoreMode[K_CMDCMSettingsStoreMode];

    // Get DICOM QR Server Attributes from MemIni
    SkipChange := TRUE;
    LEQRPACSAet.Text := N_MemIniToString( 'CMS_DCMQRSettings', 'Name', ''  );
    LEQRIPAddr.Text  := N_MemIniToString( 'CMS_DCMQRSettings', 'IP', ''  );
    LEQRPortNum.Text := N_MemIniToString( 'CMS_DCMQRSettings', 'Port', ''  );

    // Get DICOM Store Server Attributes from MemIni
    LEStorePACSAet.Text := N_MemIniToString( 'CMS_DCMStoreSettings', 'Name', ''  );
    LEStoreIPAddr.Text  := N_MemIniToString( 'CMS_DCMStoreSettings', 'IP', ''  );
    LEStorePortNum.Text := N_MemIniToString( 'CMS_DCMStoreSettings', 'Port', ''  );

    // Get DICOM StoreCommitment Server Attributes from MemIni
    LESCommPACSAet.Text := N_MemIniToString( 'CMS_DCMSCommSettings', 'Name', ''  );
    LESCommIPAddr.Text  := N_MemIniToString( 'CMS_DCMSCommSettings', 'IP', ''  );
    LESCommPortNum.Text := N_MemIniToString( 'CMS_DCMSCommSettings', 'Port', ''  );

    // Get DICOM MWL Server Attributes from MemIni
    LEMWLPACSAet.Text := N_MemIniToString( 'CMS_DCMMWLSettings', 'Name', ''  );
    LEMWLIPAddr.Text  := N_MemIniToString( 'CMS_DCMMWLSettings', 'IP', ''  );
    LEMWLPortNum.Text := N_MemIniToString( 'CMS_DCMMWLSettings', 'Port', ''  );

    // Get DICOM AetScu Attributes from MemIni
    LEAetCMSuite.Text := K_CMDCMSetupCMSuiteAetScu();
    LEAetStoreSCP.Text := N_MemIniToString( 'CMS_DCMAetScu', 'StoreSCP', ''  );
    SkipChange := FALSE;

    LEQRArr[0] := LEQRPACSAet;
    LEQRArr[1] := LEQRIPAddr;
    LEQRArr[2] := LEQRPortNum;
    LEQRArr[3] := LEAetCMSuite;

    LEStoreArr[0] := LEStorePACSAet;
    LEStoreArr[1] := LEStoreIPAddr;
    LEStoreArr[2] := LEStorePortNum;
    LEStoreArr[3] := LEAetCMSuite;

    LESCommArr[0] := LESCommPACSAet;
    LESCommArr[1] := LESCommIPAddr;
    LESCommArr[2] := LESCommPortNum;
    LESCommArr[3] := LEAetStoreSCP;

    LEMWLArr[0] := LEMWLPACSAet;
    LEMWLArr[1] := LEMWLIPAddr;
    LEMWLArr[2] := LEMWLPortNum;
    LEMWLArr[3] := LEAetCMSuite;

    LELabAet[0] := LEAetCMSuite;
    LELabAet[1] := LEAetCMSuite;
    LELabAet[2] := LEAetStoreSCP;
    LELabAet[3] := LEAetCMSuite;

    LabArr[0] := LbQRAetScu;
    LabArr[1] := LbStoreAetScu;
    LabArr[2] := LbSCommAetScu;
    LabArr[3] := LbMWLAetScu;

    ShapeArr[0] := ShapeQRState;
    ShapeArr[1] := ShapeStoreState;
    ShapeArr[2] := ShapeSCommState;
    ShapeArr[3] := ShapeMWLState;

//    RGQRType.Enabled := K_CMGAModeFlag;
//    GBStore.Enabled := K_CMGAModeFlag;
    ChBDCMAutoStore.Enabled := K_CMGAModeFlag;
    ChBDCMAutoStore.Checked := K_CMDCMStoreAutoFlag;
    if ChBCommitment.Enabled then // for future
    begin
      ChBCommitment.Enabled := K_CMGAModeFlag;
      ChBCommitment.Checked := K_CMDCMStoreCommitmentFlag;
    end;

    N_Dump2Str( format( 'K_CMDCMSetupDlg start >> '#13#10 +
      'QR Name=%s IP=%s Port=%s'#13#10 +
      'Store Name=%s IP=%s Port=%s'#13#10 +
      'Comm Name=%s IP=%s Port=%s'#13#10 +
      'MWL Name=%s IP=%s Port=%s'#13#10 +
      'AetScu CMSuite=%s StoreSCP=%s'#13#10 +
      'AutoStore=%s AutoCommitment=%s',
                [LEQRPACSAet.Text, LEQRIPAddr.Text, LEQRPortNum.Text,
                 LEStorePACSAet.Text, LEStoreIPAddr.Text, LEStorePortNum.Text,
                 LESCommPACSAet.Text, LESCommIPAddr.Text, LESCommPortNum.Text,
                 LEMWLPACSAet.Text, LEMWLIPAddr.Text, LEMWLPortNum.Text,
                 LEAetCMSuite.Text,LEAetStoreSCP.Text,
                 N_B2Str(K_CMDCMStoreAutoFlag),N_B2Str(K_CMDCMStoreCommitmentFlag)] ) );

    if LEQRPortNum.Text <> '' then
      IPortArr[0] := StrToIntDef( LEQRPortNum.Text, 0 );
    if LEStorePortNum.Text <> '' then
      IPortArr[1] := StrToIntDef( LEStorePortNum.Text, 0 );
    if LESCommPortNum.Text <> '' then
      IPortArr[2] := StrToIntDef( LEMWLPortNum.Text, 0 );
    if LEMWLPortNum.Text <> '' then
      IPortArr[3] := StrToIntDef( LEMWLPortNum.Text, 0 );

    //LbAppEntity.Caption := K_CMGetDICOMAppEntityName();
    TestConnectionIsDone := FALSE;
    CloseConnectionState();
    Result := ShowModal() = mrOK;

    if FDCMDLib <> nil then
    begin
      FDCMDLib.DDFinishQR();
      FreeAndNil(FDCMDLib);
    end;

    if Result then
    begin
//      if K_CMGAModeFlag then
      begin
//        K_CMDCMSettingsStoreMode := ConvToFromDCMSStoreMode[RGQRType.ItemIndex];
        K_CMDCMStoreAutoFlag := ChBDCMAutoStore.Checked;
        if ChBCommitment.Enabled then
          K_CMDCMStoreCommitmentFlag := ChBCommitment.Checked;
//        N_StringToMemIni( 'CMS_DCMQRSettings', 'AETSCU', LEdScuAet.Text  );
      end;
    // Save DICOM Server Attributes to MemIni
      N_StringToMemIni( 'CMS_DCMQRSettings', 'Name', LEQRPACSAet.Text  );
      N_StringToMemIni( 'CMS_DCMQRSettings', 'IP',   LEQRIPAddr.Text  );
      N_StringToMemIni( 'CMS_DCMQRSettings', 'Port', LEQRPortNum.Text  );
      N_CurMemIni.DeleteKey( 'CMS_DCMQRSettings', 'AETSCU' );

      N_StringToMemIni( 'CMS_DCMStoreSettings', 'Name', LEStorePACSAet.Text  );
      N_StringToMemIni( 'CMS_DCMStoreSettings', 'IP',   LEStoreIPAddr.Text  );
      N_StringToMemIni( 'CMS_DCMStoreSettings', 'Port', LEStorePortNum.Text  );

      N_StringToMemIni( 'CMS_DCMSCommSettings', 'Name', LESCommPACSAet.Text  );
      N_StringToMemIni( 'CMS_DCMSCommSettings', 'IP',   LESCommIPAddr.Text  );
      N_StringToMemIni( 'CMS_DCMSCommSettings', 'Port', LESCommPortNum.Text  );

      N_StringToMemIni( 'CMS_DCMMWLSettings', 'Name', LEMWLPACSAet.Text  );
      N_StringToMemIni( 'CMS_DCMMWLSettings', 'IP',   LEMWLIPAddr.Text  );
      N_StringToMemIni( 'CMS_DCMMWLSettings', 'Port', LEMWLPortNum.Text  );

      N_StringToMemIni( 'CMS_DCMAetScu', 'CMSuite',  LEAetCMSuite.Text );
      N_StringToMemIni( 'CMS_DCMAetScu', 'StoreSCP', LEAetStoreSCP.Text );

      N_Dump1Str( format( 'K_CMDCMSetupDlg Result >> '#13#10 +
      'QR Name=%s IP=%s Port=%s'#13#10 +
      'Store Name=%s IP=%s Port=%s'#13#10 +
      'Comm Name=%s IP=%s Port=%s'#13#10 +
      'MWL Name=%s IP=%s Port=%s'#13#10 +
      'AetScu CMSuite=%s StoreSCP=%s'#13#10 +
      'AutoStore=%s AutoCommitment=%s',
                [LEQRPACSAet.Text, LEQRIPAddr.Text, LEQRPortNum.Text,
                 LEStorePACSAet.Text, LEStoreIPAddr.Text, LEStorePortNum.Text,
                 LESCommPACSAet.Text, LESCommIPAddr.Text, LESCommPortNum.Text,
                 LEMWLPACSAet.Text, LEMWLIPAddr.Text, LEMWLPortNum.Text,
                 LEAetCMSuite.Text,LEAetStoreSCP.Text,
                 N_B2Str(K_CMDCMStoreAutoFlag),N_B2Str(K_CMDCMStoreCommitmentFlag)] ) );
    end; // if ShowModal() = mrOK then
  end; // with K_FormCMDCMSetup do
end; // function K_CMDCMSetupDlg

procedure TK_FormCMDCMSetup.LEdPortChange(Sender: TObject);
var
  WStr : string;
  Ind : Integer;

  procedure SetVal( );
  var
    IPort : Integer;
  begin
    IPort := StrToIntDef( WStr, 0 );
    LEQRArr[2].Text := WStr;
    IPortArr[0] := IPort;
    LEStoreArr[2].Text := WStr;
    IPortArr[1] := IPort;
    LESCommArr[2].Text := WStr;
    IPortArr[2] := IPort;
    LEMWLArr[2].Text := WStr;
    IPortArr[3] := IPort;
  end; // procedure SetVal

begin
  if SkipChange then Exit;

  if ChBUseSameAttrs.Checked then
  begin
    WStr := K_ChangeIntValByStrVal( Ind, TLabeledEdit(Sender).Text );

    SkipChange := TRUE;
    SetVal;
    SkipChange := FALSE;

    TestConnectionIsDone := FALSE;
    CloseConnectionState();
  end   // if ChBUseSameAttrs.Checked then
  else
  begin // if not ChBUseSameAttrs.Checked then
    if (Sender = LEQRPortNum) then
      IPortArr[0] := StrToIntDef( TLabeledEdit(LEQRPortNum).Text, 0 )
    else
    if (Sender = LEStorePortNum) then
      IPortArr[1] := StrToIntDef( TLabeledEdit(LEStorePortNum).Text, 0 )
    else
    if (Sender = LESCommPortNum) then
      IPortArr[2] := StrToIntDef( TLabeledEdit(LESCommPortNum).Text, 0 )
    else
    if (Sender = LEMWLPortNum) then
      IPortArr[3] := StrToIntDef( TLabeledEdit(LEMWLPortNum).Text, 0 );

    if TestConnectionIsDone then
    begin
      if (Sender = LEQRPortNum) then
        DefConnectionState(LEQRArr, 0)
      else
      if (Sender = LEStorePortNum) then
        DefConnectionState(LEStoreArr, 1)
      else
      if (Sender = LESCommPortNum) then
        DefConnectionState(LESCommArr, 2)
      else
      if (Sender = LEMWLPortNum) then
        DefConnectionState(LEMWLArr, 3);

      if (ShapeArr[0].Pen.Color = clGray) and
         (ShapeArr[1].Pen.Color = clGray) and
         (ShapeArr[2].Pen.Color = clGray) and
         (ShapeArr[3].Pen.Color = clGray) then
        TestConnectionIsDone := FALSE;
    end; // if TestConnectionIsDone then
  end; // if not ChBUseSameAttrs.Checked then
end; // procedure TK_FormCMDCMServerAttrs.LEdPortChange

procedure TK_FormCMDCMSetup.BtConnectClick(Sender: TObject);
var
  SavedCursor: TCursor;
  InfoText : string;

  function CompCtrls( ALE1, ALE2 : TLabeledEditArr ) : Boolean;
  begin
    Result :=
       (ALE1[0].Text = ALE2[0].Text) and
       (ALE1[1].Text = ALE2[1].Text) and
       (ALE1[2].Text = ALE2[2].Text) and
       (ALE1[3].Text = ALE2[3].Text);

  end;

begin
{}
//  if not K_CMDICOMNewFlag and (FDCMDLib = nil) then
//    FDCMDLib := TK_CMDCMDLib.Create;

  if not TestConnectionIsDone then
  begin
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
{
    if not K_CMDICOMNewFlag then
    begin
      ServerConnectionIsDone := 0 = FDCMDLib.DDStartQR( LEdServerName.Text, LEdIPAdress.Text, IPortArr[0], LEdScuAet.Text ); //LbAppEntity.Caption )
      if not ServerConnectionIsDone then
        K_CMShowSoftMessageDlg( 'DICOM server connection fails', mtInformation, 4 );
    end
    else
}
    begin
      TestConnectionIsDone := TRUE;
      InfoText := '';
      if ChBUseSameAttrs.Checked then
      begin
        DefConnectionState(LEQRArr, 0);
        if not ServerConnectionIsDone then
          InfoText := 'DICOM QueryRetrive, Store and MWL server connections fail';
//          K_CMShowSoftMessageDlg( 'DICOM server connection fails', mtInformation, 4 );
        ShowConnectionState( 1 );
        ShowConnectionState( 3 );
        if CompCtrls(LEQRArr, LESCommArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[0].Pen.Color <> clGray);
          ShowConnectionState( 2 );
        end
        else
          DefConnectionState(LESCommArr, 2);
        if not ServerConnectionIsDone then
        begin
          if InfoText <> '' then InfoText := InfoText + #13#10;
          InfoText := InfoText + 'DICOM Storage Commitment server connection fails';
        end;
//          K_CMShowSoftMessageDlg( 'DICOM Storage Commitment server connection fails', mtInformation, 4 );
      end
      else
      begin
        DefConnectionState(LEQRArr, 0);
        if not ServerConnectionIsDone then
          InfoText := 'DICOM QueryRetrive server connection fails';
//          K_CMShowSoftMessageDlg( 'DICOM QueryRetrive server connection fails', mtInformation, 4 );


        if CompCtrls(LEQRArr, LEStoreArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[0].Pen.Color <> clGray);
          ShowConnectionState( 1 );
        end
        else
          DefConnectionState(LEStoreArr, 1);
        if not ServerConnectionIsDone then
        begin
          if InfoText <> '' then InfoText := InfoText + #13#10;
          InfoText := InfoText + 'DICOM Store server connection fails';
        end;
//          K_CMShowSoftMessageDlg( 'DICOM Store server connection fails', mtInformation, 4 );
        if CompCtrls(LEQRArr, LESCommArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[0].Pen.Color <> clGray);
          ShowConnectionState( 2 );
        end
        else
        if CompCtrls(LEStoreArr, LESCommArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[1].Pen.Color <> clGray);
          ShowConnectionState( 2 );
        end
        else
          DefConnectionState(LESCommArr, 2);
        if not ServerConnectionIsDone then
        begin
          if InfoText <> '' then InfoText := InfoText + #13#10;
          InfoText := InfoText + 'DICOM Storage Commitment server connection fails';
        end;
//          K_CMShowSoftMessageDlg( 'DICOM Storage Commitment server connection fails', mtInformation, 4 );
        if CompCtrls(LEQRArr, LEMWLArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[0].Pen.Color <> clGray);
          ShowConnectionState( 3 );
        end
        else
        if CompCtrls(LEStoreArr, LEMWLArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[1].Pen.Color <> clGray);
          ShowConnectionState( 3 );
        end
        else
        if CompCtrls(LESCommArr, LEMWLArr) then
        begin
          ServerConnectionIsDone := (ShapeArr[2].Pen.Color <> clGray);
          ShowConnectionState( 3 );
        end
        else
          DefConnectionState(LEMWLArr, 3);
        if not ServerConnectionIsDone then
        begin
          if InfoText <> '' then InfoText := InfoText + #13#10;
          InfoText := InfoText + 'DICOM MWL server connection fails';
        end;
//          K_CMShowSoftMessageDlg( 'DICOM MWL server connection fails', mtInformation, 4 );
      end;
      Screen.Cursor := SavedCursor;
      if InfoText <> '' then
        K_CMShowSoftMessageDlg( InfoText, mtInformation, 4 );

      if (ShapeArr[0].Pen.Color = clGray) and
         (ShapeArr[1].Pen.Color = clGray) and
         (ShapeArr[2].Pen.Color = clGray) and
         (ShapeArr[3].Pen.Color = clGray) then
      begin
        TestConnectionIsDone := FALSE;
      end
    end;
  end
  else
  begin
{
    if not K_CMDICOMNewFlag then
      FDCMDLib.DDFinishQR();
}
    TestConnectionIsDone := FALSE;
    CloseConnectionState();
  end;

end; // procedure TK_FormCMDCMServerAttrs.BtConnectClick

procedure TK_FormCMDCMSetup.FormShow(Sender: TObject);
begin
  PageControl.ActivePage := TSQR;
  TSGeneral.TabVisible := K_CMGAModeFlag;
end; // procedure TK_FormCMDCMSetup.FormShow

procedure TK_FormCMDCMSetup.LEdServerNameChange(Sender: TObject);
var
  WStr : string;
  Ind : Integer;

  function GetInd() : Integer;
  begin
    Result := 0;
    if Sender = LEQRArr[0] then exit;
    Result := 1;
    if Sender = LEStoreArr[0] then exit;
    Result := 2;
    if Sender = LESCommArr[0] then exit;
    Result := 3;
    if Sender = LEMWLArr[0] then exit;
    Result := -1;
    if Sender = LELabAet[0] then exit;
    Result := -2;
    if Sender = LELabAet[2] then exit;
    Result := -3;
  end; // function GetInd

  procedure SetVal( AInd : Integer );
  begin
    LEQRArr[AInd].Text    := WStr;
    LEStoreArr[AInd].Text := WStr;
    LESCommArr[AInd].Text := WStr;
    LEMWLArr[AInd].Text   := WStr;
  end; // procedure SetVal

begin
  if SkipChange then Exit;
  if ChBUseSameAttrs.Checked then
  begin
    WStr := TLabeledEdit(Sender).Text;

    SkipChange := TRUE;

    Ind := GetInd();
    if Ind >= 0 then
       SetVal(0)
    else
    if Ind <= -3 then
       SetVal(1);

    SkipChange := FALSE;
    TestConnectionIsDone := FALSE;
    CloseConnectionState();
  end   // if ChBUseSameAttrs.Checked then
  else
  begin // if not ChBUseSameAttrs.Checked then
    if TestConnectionIsDone then
    begin
      if (Sender = LEQRPACSAet) or (Sender = LEQRIPAddr) then
        DefConnectionState(LEQRArr, 0)
      else
      if (Sender = LEStorePACSAet) or (Sender = LEStoreIPAddr) then
        DefConnectionState(LEStoreArr, 1)
      else
      if (Sender = LESCommPACSAet) or (Sender = LESCommIPAddr) then
        DefConnectionState(LEStoreArr, 2)
      else
      if (Sender = LEMWLPACSAet) or (Sender = LEMWLIPAddr) then
        DefConnectionState(LEStoreArr, 3);

      if (ShapeArr[0].Pen.Color = clGray) and
         (ShapeArr[1].Pen.Color = clGray) and
         (ShapeArr[2].Pen.Color = clGray) and
         (ShapeArr[3].Pen.Color = clGray) then
        TestConnectionIsDone := FALSE;
    end; // if TestConnectionIsDone then
  end;
end; // procedure TK_FormCMDCMSetup.LEdServerNameChange

procedure TK_FormCMDCMSetup.ShowConnectionState( AInd : Integer );
var
  AShape : TShape;
begin
  AShape := ShapeArr[AInd];
  LabArr[AInd].Caption := LELabAet[AInd].Text;
  if ServerConnectionIsDone then
  begin
    AShape.Pen.Color   := clGreen;
    AShape.Pen.Color   := clLime;
    AShape.Pen.Color   := clOlive;
    AShape.Brush.Color := clGreen;
  end   // if ServerConnectionIsDone then
  else
  begin // if not ServerConnectionIsDone then
    AShape.Pen.Color   := clGray;
    AShape.Brush.Color := clGray;
    if not TestConnectionIsDone then
      LabArr[AInd].Caption := '';
  end; // if ServerConnectionIsDone then
end; // procedure TK_FormCMDCMSetup.ShowConnectionState

procedure TK_FormCMDCMSetup.ChBUseSameAttrsClick(Sender: TObject);
var
  WStr : string;
  i : Integer;

  procedure GetVal( AInd : Integer );
  begin
    WStr := LEQRArr[AInd].Text;
    if WStr <> '' then Exit;
    WStr := LEStoreArr[AInd].Text;
    if WStr <> '' then Exit;
    WStr := LESCommArr[AInd].Text;
    if WStr <> '' then Exit;
    WStr := LEMWLArr[AInd].Text;
  end; // procedure GetVal

  procedure SetVal( AInd : Integer );
  begin
    LEQRArr[AInd].Text    := WStr;
    LEStoreArr[AInd].Text := WStr;
    LESCommArr[AInd].Text := WStr;
    LEMWLArr[AInd].Text   := WStr;
  end; // procedure SetVal
begin
  if ChBUseSameAttrs.Checked then
  begin
    TestConnectionIsDone := FALSE;
    CloseConnectionState();
    SkipChange := TRUE;
    for i := 0 to 2 do
    begin
      GetVal( i );
      SetVal( i );
    end;
    SkipChange := FALSE;
  end; // if ChBUseSameAttrs.Checked then
end; // procedure TK_FormCMDCMSetup.ChBUseSameAttrsClick

procedure TK_FormCMDCMSetup.DefConnectionState(ALE: TLabeledEditArr; AInd: Integer);
begin
  ServerConnectionIsDone := FALSE;
  if (ALE[0].Text <> '') and
     (ALE[1].Text <> '')  and
     (IPortArr[AInd] <> 0) and
     (ALE[3].Text <> '' ) then
    ServerConnectionIsDone := K_CMDCMServerTestConnection( ALE[1].Text, IPortArr[AInd], ALE[0].Text, ALE[3].Text, 7, TRUE );

  ShowConnectionState(  AInd );

end; // procedure TK_FormCMDCMSetup.DefConnectionState

procedure TK_FormCMDCMSetup.CloseConnectionState;
begin
  ServerConnectionIsDone := FALSE;
  ShowConnectionState( 0 );
  ShowConnectionState( 1  );
  ShowConnectionState( 2  );
  ShowConnectionState( 3 );
  TestConnectionIsDone := FALSE;
end; // procedure TK_FormCMDCMSetup.CloseConnectionState

end.
