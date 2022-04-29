unit K_FCMProfileOther1;
// Other Devices Profile Editor

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_CMCaptDevReg, K_FCMProfileDevice;

type TK_FormCMProfileOther1 = class( TK_FormCMProfileDevice )
    bnSpecial: TButton;
    PnWait: TPanel;
    procedure FormShow          ( Sender: TObject );
    procedure FormCloseQuery    ( Sender: TObject; var CanClose: Boolean );
    procedure CmBDevicesChange  ( Sender: TObject );
    procedure bnSpecialClick    ( Sender: TObject );
    procedure EdProfileNameExit ( Sender: TObject );
  protected
//    PEGroupInd : Integer;

    PEGroupName : string;
    PEProductName: string;
    PEProductCapt: string;
    PEProfileCapt: string;
    PEGroupCapt : string;
    PECDServObj : TK_CMCDServObj;
    PEDeviceNameCaptList : TStringList;
    SkipInheritedFormShow : Boolean;
    procedure SetCurDeviceByNames( );

end; // type TK_FormCMProfileOther = class( TK_FormCMProfileTwain )

var
  K_FormCMProfileOther1: TK_FormCMProfileOther1;

implementation

uses Types,
K_FSFList, K_CM0,
N_Lib0, N_CM1, N_Types, K_CML1F;

{$R *.dfm}


//*****************************  TK_FormCMProfileOther1.SetCurDeviceByNames ***
//  Normalized Devices ComboBox List by Current Profile Names
//
procedure TK_FormCMProfileOther1.SetCurDeviceByNames( );
var
  SearchProductName : string;
  Ind : Integer;
begin
  with CmBDevices do
  begin
    SearchProductName := PEProductCapt;
    PEProfileCapt := PEProductCapt;
    if (PEGroupCapt <> '') and (PEGroupCapt <> PEProductName) then
    begin
      PEProductCapt := PECDServObj.CDSGetDevCaption( PEProductName );
      SearchProductName := PEGroupCapt + ' / ' + PEProductCapt;
      PEProfileCapt := PECDServObj.CDSGetDevProfileCaption( PEProductName );
    end;
    Ind := Items.IndexOf( SearchProductName );
    if Ind = -1 then
    begin
      N_Dump2Str( Format( 'DevSetup Profile select >> Ins PProd="%s"', [SearchProductName] ) );
      Items.InsertObject( 0, SearchProductName, TObject(-2) );
      if PEDeviceNameCaptList = nil then
        PEDeviceNameCaptList := TStringList.Create();
      PEDeviceNameCaptList.Add( PEProductCapt + '=' +  PEProductName );
      Ind := 0;
    end
    else
    if PEDeviceNameCaptList <> nil then
    begin
      SearchProductName := PEDeviceNameCaptList.Values[PEProductCapt];
      if SearchProductName <> '' then
        PEProductName := SearchProductName;
    end;
    ItemIndex := Ind;
  end;
end; // end of TK_FormCMProfileOther1.SetCurDeviceByNames


//****************************************  TK_FormCMProfileOther1.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMProfileOther1.FormShow( Sender: TObject );
// OnShow Handler
var
  Ind : Integer;
  NewProfile0DeviceIsGroup : Boolean;
begin
  if not SkipInheritedFormShow then
  begin
    //*** Prepare CmBDevices.Items
    if K_CMCaptDevCaptsOrderedList = nil then
    begin
      N_CurMemIni.ReadSectionValues( 'RegionDevCapts', K_CMEDAccess.TmpStrings );
      if K_CMEDAccess.TmpStrings.Count > 0 then
        K_CMCDRenameRegistered( K_CMEDAccess.TmpStrings );
      K_CMCaptDevCaptsOrderedList := TStringList.Create;
      K_CMCDGetRegCaptions( K_CMCaptDevCaptsOrderedList );
      K_CMCaptDevCaptsOrderedList.Sort;
    end;

    CmBDevices.Items.Clear;
    CmBDevices.Items.AddStrings( K_CMCaptDevCaptsOrderedList );
  end; // if not SkipInheritedFormShow then

   //*** Init Common Device Controls Except Device List
  Init0(); // TK_FormCMProfileTwain.Init0 is used, nothing special is needed

 //*** Init Common Device Controls by Device List
//  Init1(); // TK_FormCMProfileTwain.Init1 is used, nothing special is needed
  with CmBDevices, TK_PCMTwainProfile(PEPCMDeviceProfile)^ do
  begin
    if PEProfileInd = -1 then
    begin // New Profile Edit;
      CMDPProductName := '';
      CMDPGroupName := '';
    end;


//    PEGroupInd := -1;
    PEGroupName := CMDPGroupName;
    PEProductName := CMDPProductName;
    PEProductCapt := CMDPProductName;
    PEProfileCapt := CMDPProductName;
    PEGroupCapt := '';
    NewProfile0DeviceIsGroup := FALSE;
    if (PEGroupName <> '') then
    begin
      PECDServObj := K_CMCDGetDeviceObjByName( PEGroupName );
      if PECDServObj <> nil then
        PEGroupCapt := PECDServObj.CDSCaption;
      SetCurDeviceByNames();
    end
    else
    begin
      if PEProfileInd <> -1 then
      begin // Existing Profile Edit;
        Ind := Items.IndexOf( CMDPCaption );
        ItemIndex := Ind;
        if Ind = -1 then
          K_CMShowMessageDlg( format( K_CML1Form.LLLProfile1.Caption,
//            'Selected device profile "%s" is corrupted',
            [CMDPCaption] ), mtWarning );
      end
      else
        ItemIndex := -1;
//        ItemIndex := 0;
    end;

//    if CMDPCaption <> '' then
    if (CMDPCaption <> '') and (ItemIndex >= 0) then
      EdProfileName.Text := CMDPCaption
    else
//      EdProfileName.Text := PEProductCapt;
      EdProfileName.Text := PEProfileCapt;

    if (PEProfileInd = -1) and (Items.Count > 0) then
    begin
      PECDServObj := K_CMCDGetDeviceObjByInd( 0 );
      NewProfile0DeviceIsGroup := PECDServObj.IsGroup;
      if not NewProfile0DeviceIsGroup then
        EdProfileName.Text := Items[0];
    end
    else if EdProfileName.Text = '' then
      EdProfileName.Text := Items[ItemIndex];


    if ItemIndex >= 0 then
      AutoProfileNameFlag := NewProfile0DeviceIsGroup or
                             (EdProfileName.Text = PEProductCapt);


//    if (PEProfileInd = -1) and (Items.Count > 0) then
//      EdProfileName.Text := Items[0]
//    EdProfileName.Text := Items[ItemIndex];

    if ([cmpfVideoMain,cmpfVideoAll,cmpfTWAINMain,cmpfTWAINAll,cmpfOtherMain,cmpfOtherAll] * N_CM_LogFlags) <> [] then
    begin
      N_Dump2Str( '   Device Names:' );
      N_Dump2Strings( Items, 5 );
    end;

  end;

  bnSpecial.Enabled := False; // temporary

  CmBDevicesChange( nil ); // Init Current Profile Context

end; // procedure TK_FormCMProfileOther1.FormShow

//**********************************  TK_FormCMProfileOther1.FormCloseQuery ***
//
procedure TK_FormCMProfileOther1.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  CurCmBDevInd : Integer;
begin
  if ModalResult <> mrOK then Exit;

  // PECDServObj <> nill is needed for profile which was created and then device group was removed from CMS
  if (PECDServObj <> nil) and PECDServObj.IsGroup and
    ((PEGroupName = '') or (PEProductName = ''))  then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLProfile2.Caption,
//      'Ñapture device is not selected. Profile will not be saved',
                       mtWarning );
    ModalResult := mrCancel;
    Exit;
  end;

  with CmBDevices, PEPCMDeviceProfile^ do
  begin
    CurCmBDevInd := ItemIndex;
    if ItemIndex >= 0 then
    begin
      CMDPProductName := PEProductName;
      CMDPGroupName := PEGroupName;
      ItemIndex := -1;
    end;
  end; // with CmBDevices, PEPCMDeviceProfile^ do

  inherited;

  if CanClose then
  begin
  // Form is closing
    PEDeviceNameCaptList.Free
  end
  else
  // Dialog is continue
    CmBDevices.ItemIndex := CurCmBDevInd;
end; // TK_FormCMProfileOther1.FormCloseQuery

//********************************  TK_FormCMProfileOther1.CmBDevicesChange ***
//
procedure TK_FormCMProfileOther1.CmBDevicesChange(Sender: TObject);
var
  Ind, WInd : Integer;
  GroupCapt : String;
  GroupDevNames, GroupDevCapts : TStringList;
  GInd : Integer;
  SavedCursor: TCursor;
  PrevProductName : string;

  procedure SelectGroupDevice( out AInd : Integer );
  var
    GroupResCode, i : Integer;
  begin
    with PECDServObj do
    begin
      GroupDevNames := TStringList.Create();
      GroupDevCapts := TStringList.Create();
      PnWait.Caption := 'Please wait ...';
      PnWait.Refresh();
      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      GroupResCode := CDSGetGroupDevNames( GroupDevNames );
      Screen.Cursor := SavedCursor;
      PnWait.Caption := '';
      PnWait.Refresh();

      if GroupResCode <= 0 then
      begin
      // Devices Software problems or empty Devices List
        AInd := -4;
        if PEProfileInd = -1 then // New Profile Edit
          ModalResult := mrCancel;
      end
      else
      begin
      // Select Group Device Name
        if CDSName <> PEGroupName then
          AInd := 0
        else
          AInd := GroupDevNames.IndexOf( PEProductName );

        if GroupDevNames.Count <> 1 then
        begin
          for i := 0 to GroupDevNames.Count -1 do
            GroupDevCapts.Add( CDSGetDevCaption( GroupDevNames[i] ) );

          with TK_FormSelectFromList.Create(Application) do
          begin
            Caption := CDSCaption;
            SelectListBox.Color := $00A2FFFF;
            SetItemsList( GroupDevCapts );
            BFIniSize := Point( 300, 200 );
            BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
            if not SelectElement( AInd ) then
              AInd := -3 // No Group Device Selected
            else
              PEProductName := GroupDevNames[AInd];
          end;
        end
        else
          PEProductName := GroupDevNames[0];
      end; // with PECDServObj do
      GroupDevNames.Free;
      GroupDevCapts.Free;
    end;
  end;

begin

  with CmBDevices do
  begin
    if ItemIndex = -1  then Exit;
    GInd := -2;
    Ind := Integer(Items.Objects[ItemIndex]);
    PECDServObj := nil;
    GroupCapt := Items[ItemIndex];
//    if Integer(Items.Objects[ItemIndex]) = -2 then
    PrevProductName := PEProductName;
    if Ind = -2 then
    begin // previous GroupElement Device Was Selected
      WInd := Pos( '/', GroupCapt );
      if WInd > 0 then
      begin
        PEProductCapt := Copy( GroupCapt, WInd + 2, Length(GroupCapt) );
        PEGroupCapt := Copy( GroupCapt, 1, WInd - 2 );
        Ind := Items.IndexOf( PEGroupCapt );
        if Ind >= 0 then
        begin
          Ind := Integer(Items.Objects[Ind]);
          PECDServObj := K_CMCDGetDeviceObjByInd( Ind );
          PEGroupName := PECDServObj.CDSName;
          PEProductName := PEDeviceNameCaptList.Values[PEProductCapt];
          GInd := -1;
        end;
      end
    end
    else
    begin
      PECDServObj := K_CMCDGetDeviceObjByInd( Ind );
      with PECDServObj do
      begin
        if PECDServObj.CDSIsGroup then
        begin
          if Sender <> nil then
            SelectGroupDevice( GInd );
          if GInd >= 0 then
          begin
            PEGroupName := PECDServObj.CDSName;
            PEGroupCapt := GroupCapt;
          end;
        end
        else
        begin
          PEGroupName := PECDServObj.CDSName;
          PEProductName := PECDServObj.CDSName;
          PEGroupCapt := '';
          PEProductCapt := PECDServObj.CDSGetDevCaption( PEProductName );
          PEProfileCapt := PECDServObj.CDSGetDevProfileCaption( PEProductName );
        end;
      end;
    end;

// GInd values
//  - >= 0 - Group Index,
//  - = -1 - Previouse Group Device was selected
//  - = -2 - Not Group device selected
//  - = -3 - Cancel while Group Device selection
//  - = -4 - selected Group Device Software problems or empty Group Device List
    if (GInd > -2) and (PEProductName <> '') then
      SetCurDeviceByNames();

    N_Dump1Str( format( 'DevSetup Profile select  Result=%d device GrName="%s" ProdName="%s" GrCapt="%s" ProdCapt="%s" ProfCapt="%s"',
                        [GInd,PEGroupName,PEProductName,
                         PEGroupCapt,PEProductCapt,PEProfileCapt] ) );

    if AutoProfileNameFlag then
//      EdProfileName.Text := PEProductCapt;
      EdProfileName.Text := PEProfileCapt;

    if PECDServObj <> nil then
      bnSpecial.Enabled := PECDServObj.ShowSettingsDlg;
    if PrevProductName <> PEProductName then
    begin
      PEPCMDeviceProfile.CMDPDModality := PECDServObj.CDSGetDefaultDevDCMMod(PEProductName); // set modality

      PEDynIconFlag :=  K_CMInitProfileIcons( PEIconsBig, PEIconsSmall );
      if PEDynIconFlag then
      begin // Dynamic Icons
        PEIconInd := PECDServObj.CDSGetDefaultDevIconInd(PEProductName);
        SetIconImage( );
        PEChangeIconFlag := TRUE;
      end;
    end; // if PrevProductName <> PEProductName then

  end; // with CmBDevices do
end; // TK_FormCMProfileOther1.CmBDevicesChange

//**********************************  TK_FormCMProfileOther1.bnSpecialClick ***
//
procedure TK_FormCMProfileOther1.bnSpecialClick(Sender: TObject);
var
  CMDeviceProfile : TK_CMDeviceProfile;
begin
  CMDeviceProfile := PEPCMDeviceProfile^;
  with CMDeviceProfile do
  begin
    CMDPProductName := PEProductName;
    CMDPGroupName := PEGroupName;
  end;
  PECDServObj.CDSSettingsDlg( @CMDeviceProfile );
  PEPCMDeviceProfile^.CMDPStrPar1 := CMDeviceProfile.CMDPStrPar1;
  PEPCMDeviceProfile^.CMDPStrPar2 := CMDeviceProfile.CMDPStrPar2;
end; // TK_FormCMProfileOther1.bnSpecialClick

//*******************************  TK_FormCMProfileOther1.EdProfileNameExit ***
//  Used for check Profile Name auto set mode
//
procedure TK_FormCMProfileOther1.EdProfileNameExit(Sender: TObject);
begin
  if AutoProfileNameFlag then Exit;
//  with CmBDevices do
//    AutoProfileNameFlag := EdProfileName.Text = PEProductCapt;
  AutoProfileNameFlag := EdProfileName.Text = PEProfileCapt;
end; // end of TK_FormCMProfileOther1.EdProfileNameExit

end.
