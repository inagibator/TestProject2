unit K_FCMUTSetDBContexts;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, ComCtrls;

type
  TK_FormCMUTSetDBContexts = class(TN_BaseForm)
    BtRun: TButton;
    BtExit: TButton;
    GBToolbar: TGroupBox;
    GBToolBarSettings: TGroupBox;
    LbLocations: TLabel;
    CmBLocations: TComboBox;
    ChBToAllLocations: TCheckBox;
    GBToolbarUse: TGroupBox;
    LbUseType: TLabel;
    CmBUseType: TComboBox;
    ChBToAllProviders: TCheckBox;
    procedure BtRunClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ChBToAllLocationsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    ProvidersIDList : TList;
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMUTSetDBContexts: TK_FormCMUTSetDBContexts;

procedure K_CMSetDBContextsDlg( );

implementation

{$R *.dfm}
uses DB,
  N_Types, N_Lib1, K_FEText,
  K_CLib0, K_CM0, K_Script1, K_CLib, K_CML1F, K_FCMGAdmEnter;

{ TK_FormCMReports }

procedure  K_CMSetDBContextsDlg( );
begin

  K_CMGAModeFlag := TRUE;
  if K_CMEDAccess is TK_CMEDDBAccess then
    K_CMGAModeFlag := TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafEGAMode], 1 ) = K_edOK;

  if not K_CMGAModeFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLGAEnter2.Caption,
//        'Global administration mode is set by another CMS user.' + Chr($0D) + Chr($0A) +
//        '               Please try again later.',
       mtWarning );
    Exit;
  end;

  with TK_FormCMUTSetDBContexts.Create(Application) do
  begin
//    BaseFormInit ( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    ShowModal;
  end;

  K_CMEDAccess.EDAClearGAMode();
end; // procedure  K_CMSetDBContextsDlg( );

//*************************************** TK_FormCMUTSetDBContexts.FormShow ***
// FormShow Handler
//
procedure TK_FormCMUTSetDBContexts.FormShow(Sender: TObject);
var
  ObjsInfo : TK_RArray;
  InfoList : TStrings;
  i, ObjID : Integer;

begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDASAGetLocationsInfo( FALSE );
    EDASAGetProvidersInfo( FALSE );

    ProvidersIDList := TList.Create;
    if ProvidersInfo <> nil then
    begin
      ObjsInfo := ProvidersInfo.R;
      for i := 1 to ObjsInfo.ARowCount - 1 do
      begin
        ObjID := StrToIntDef( PString(ObjsInfo.PME(0, i))^, -1 );
        if (ObjID < 0) and (ObjID > -100) then Continue; // precaution
        ProvidersIDList.Add( TObject(ObjID) );
      end;
    end;

    InfoList := CmBLocations.Items;
    InfoList.Clear;
    if LocationsInfo <> nil then
    begin
      ObjsInfo := LocationsInfo.R;
      for i := 1 to ObjsInfo.ARowCount - 1 do
      begin
        ObjID := StrToIntDef( PString(ObjsInfo.PME(0, i))^, -1 );
        if (ObjID < 0) and (ObjID > -100) then Continue; // precaution
        InfoList.AddObject( K_CMGetLocationDetails( ObjID ), TObject(ObjID) );
      end;
    end;

    BtRun.Enabled := FALSE;

    if CmBLocations.Items.Count >= 1 then
      CmBLocations.ItemIndex := 0;

  end;

end; // TK_FormCMUTSetDBContexts.FormShow

//************************************* TK_FormCMUTSetDBContexts.BtRunClick ***
// BtRun Click Handler
//
procedure TK_FormCMUTSetDBContexts.BtRunClick(Sender: TObject);
var
  i, Ind : Integer;
  DSize: Integer;
  PData: Pointer;
  ID : Integer;
  SL,CSL : TStringList;
  RCode : TK_CMEDResult;
  WrongCount : Integer;
  WStr0, WStr : string;
  ShowResultsFlag : boolean;

label LExit, LExit1;
begin
  if not ChBToAllLocations.Checked and not ChBToAllProviders.Checked then
  begin
    K_CMShowMessageDlg( //sysout
        ' Nothing to do ', mtInformation );
    Exit;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    //////////////////////////////////////
    // Copy Cust Toolbar  Location context
    if ChBToAllLocations.Checked then
    begin
      ShowResultsFlag := FALSE;
      CSL := nil;
      WrongCount := 0;

      ID := Integer(CmBLocations.Items.Objects[CmBLocations.ItemIndex]);

      RCode := EDAGetOneAppContext( IntToStr(Ord(K_actLocIni)), IntToStr(ID),
                                     '0', PData, DSize );
      if (RCode <> K_edOK) then
      begin
        K_CMShowMessageDlg( //sysout
            ' Something is wrong with access to source location context!!!', mtWarning );
        N_Dump1Str( format( 'SetDBContexts>> Source Location ID=%d Wrong >> ErrCode=%d', [ID, Ord(RCode)] ) );
        Exit;
      end;

      SL := TStringList.Create;
      if DSize > 0 then
      begin
        EDAAnsiTextToString(PData, DSize);
        SL.Text := PChar(PData);
      end;

      if (SL.Count = 0) or (SL.IndexOfName('GCustToolbarSmallButtons') < 0) then
      begin
        K_CMShowMessageDlg( //sysout
            ' Location has no Toolbar context!!!', mtWarning );
        goto LExit;
      end;

      K_CMEDADFPLExec := TK_DFPLScriptExec.Create; // DFPL Script Processor for contexts processing

      K_CMEDADFPLExec.SrcIniFile := K_CMEDADefaultMemIni;
      K_CMEDADFPLExec.DstIniFile := K_CMEDAMemIniFile;

//with  K_GetFormTextEdit( nil ) do
//  EditStrings( SL, 'source', FALSE, TRUE );
                                  
      K_CMEDADefaultMemIni.SetStrings(SL);

      CSL := TStringList.Create;
      CSL.Text := 'GCMCustToolbar0 --'#13#10+
                  'GCMCustToolbar0 =+ *'#13#10+
                  'GCMCustToolbar1 --'#13#10+
                  'GCMCustToolbar1 =+ *'#13#10+
                  'GCMCustToolbar2 --'#13#10+
                  'GCMCustToolbar2 =+ *'#13#10+
                  'GCMCustToolbar3 --'#13#10+
                  'GCMCustToolbar3 =+ *'#13#10+
                  'CMS_Main -  GCustToolbarSmallButtons'#13#10+
                  'CMS_Main =+ GCustToolbarSmallButtons';

      for i := 0 to CmBLocations.Items.Count - 1 do
      begin
        if i = CmBLocations.ItemIndex then Continue;

        // Get Resulting Location context
        ShowResultsFlag := TRUE;
        ID := Integer(CmBLocations.Items.Objects[i]);
        RCode := EDAGetOneAppContext( IntToStr(Ord(K_actLocIni)), IntToStr(ID),
                                       '0', PData, DSize );
        if (RCode <> K_edOK) then
        begin
          N_Dump1Str( format( 'SetDBContexts>> Location read ID=%d Wrong >> ErrCode=%d', [ID, Ord(RCode)] ) );
          Inc(WrongCount);
          Continue;
        end;

        SL.Clear;
        if DSize > 0 then
        begin
          EDAAnsiTextToString(PData, DSize);
          SL.Text := PChar(PData);
//with  K_GetFormTextEdit( nil ) do
//  EditStrings( SL, 'before', FALSE, TRUE );
        end;

        K_CMEDAMemIniFile.SetStrings(SL);

        // Copy Cust Toolbar Data to Result Location Context
        K_CMEDADFPLExec.DFPLDoCommandsList0( CSL, FALSE );

        // Save Resulting Location context
        SL.Clear;
        K_CMEDAMemIniFile.GetStrings(SL);
//with  K_GetFormTextEdit( nil ) do
//  EditStrings( SL, 'after', FALSE, TRUE );

        DSize := EDAStringsToAnsiText(SL, PData);
        RCode := EDASaveOneAppContext0( CurDSet1, Ord(K_actLocIni), ID, 0, PData, DSize );
        if RCode <> K_edOK then
        begin
          N_Dump1Str( format( 'SetDBContexts>> Location save ID=%d Wrong >> ErrCode=%d', [ID, Ord(RCode)] ) );
          Inc(WrongCount);
          Continue;
        end;

      end; // for i := 0 to CmBLocations.Items.Count - 1 do


LExit: // *****
      SL.Free;
      CSL.Free;
      K_CMEDADFPLExec.DstIniFile := nil;
      K_CMEDADFPLExec.SrcIniFile := nil;
      FreeAndNil( K_CMEDADFPLExec );
      if ShowResultsFlag then
        K_CMShowMessageDlg( //sysout
              format(' Toolbar context is applied to %d location(s).'#13#10 +
                     '           %d location(s) is(are) failed.',
                     [CmBLocations.Items.Count - 1 - WrongCount,WrongCount] ), mtWarning );
      ModalResult := mrOK;
    end; // if ChBToAllLocations.Checked then

    //////////////////////////////////////
    // Copy Cust Toolbar Provider use context
    if ChBToAllProviders.Checked then
    begin
      SL := TStringList.Create;
      WrongCount := 0;
      WStr0 := IntToStr(CmBUseType.ItemIndex);
      WStr := 'UseCustToolbarGlobal=' + WStr0;
      for i := 0 to ProvidersIDList.Count - 1 do
      begin
        ID := Integer(ProvidersIDList[i]);
        RCode := EDAGetOneAppContext( IntToStr(Ord(K_actProvIni)), IntToStr(ID),
                                       '0', PData, DSize );
        if (RCode <> K_edOK) then
        begin
          Inc(WrongCount);
          N_Dump1Str( format( 'SetDBContexts>> Provider read ID=%d Wrong >> ErrCode=%d', [ID, Ord(RCode)] ) );
          Continue;
        end;

        SL.Clear;
        if DSize > 0 then
        begin
          EDAAnsiTextToString(PData, DSize);
          SL.Text := PChar(PData);
        end;

        // Change Provider Context
        Ind := SL.IndexOfName('UseCustToolbarGlobal');
        if Ind >= 0 then
          SL.ValueFromIndex[Ind] := WStr0 // UseCustToolbarGlobal= exists
        else
        begin // if Ind < 0 then
          Ind := SL.IndexOf('[CMS_Main]');
          if Ind >= 0 then
            SL.Insert( Ind + 1, WStr )  // [CMS_Main] exists
          else
          begin
             SL.Insert( 0, '[CMS_Main]' );
             if SL.Count > 1 then
             begin // Context is not empty
               SL.Insert( 1, WStr );
               SL.Insert( 2, '' )
             end
             else
             begin // Context is empty
               SL.Add( WStr );
               SL.Add( '' );
             end;
          end;
        end; // if RCode < 0 then

        // Save provider context
        DSize := EDAStringsToAnsiText(SL, PData);
        RCode := EDASaveOneAppContext0( CurDSet1, Ord(K_actProvIni), ID, 0, PData, DSize );
        if RCode <> K_edOK then
        begin
          N_Dump1Str( format( 'SetDBContexts>> Provider save ID=%d Wrong >> ErrCode=%d', [ID, Ord(RCode)] ) );
          Inc(WrongCount);
          Continue;
        end;
      end; // for i := 0 to ProvidersIDList.Count - 1 do


LExit1: // *****
      SL.Free;

      K_CMShowMessageDlg( //sysout
              format(' Toolbar context use mode is applied to %d dentist(s).'#13#10 +
                     '              %d dentist(s) is(are) failed.',
                     [ProvidersIDList.Count - WrongCount,WrongCount] ), mtWarning );
      ModalResult := mrOK;
    end; // if ChBToAllProviders.Checked then

  end; // with TK_CMEDDBAccess(K_CMEDAccess) do


end; // TK_FormCMUTSetDBContexts.BtRunClick

//******************************* TK_FormCMUTSetDBContexts.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMUTSetDBContexts.CurStateToMemIni;
begin
  inherited;
end; // TK_FormCMUTSetDBContexts.CurStateToMemIni

//******************************* TK_FormCMUTSetDBContexts.MemIniToCurState ***
// Load Self Size and Position from N_Forms section, BFSelfName string
//
procedure TK_FormCMUTSetDBContexts.MemIniToCurState;
begin
  inherited;
end; // TK_FormCMUTSetDBContexts.TK_FormCMUTSetDBContexts

//************************* TK_FormCMUTSetDBContexts.ChBToAllLocationsClick ***
// ChBToAllLocation and ChBToAllProviders Click Handler
//
procedure TK_FormCMUTSetDBContexts.ChBToAllLocationsClick(Sender: TObject);
begin
  BtRun.Enabled := (ChBToAllLocations.Checked and (CmBLocations.Items.Count > 1)) or
                   (ChBToAllProviders.Checked and (ProvidersIDList.Count > 0));
end; // procedure TK_FormCMUTSetDBContexts.ChBToAllLocationsClick

//********************************* TK_FormCMUTSetDBContexts.FormCloseQuery ***
// FormCloseQuery Handler
//
procedure TK_FormCMUTSetDBContexts.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;
  FreeAndNil(ProvidersIDList);
end; // procedure TK_FormCMUTSetDBContexts.FormCloseQuery

end.
