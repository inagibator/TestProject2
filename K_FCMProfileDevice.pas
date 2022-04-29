unit K_FCMProfileDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls,
  K_Script1, K_CM0, ActnList;

type TK_FormCMProfileDevice = class( TN_BaseForm )
    LbPofileName: TLabel;
    LbDevice: TLabel;
    EdProfileName: TEdit;
    CmBDevices: TComboBox;
    GBIconShortCut: TGroupBox;
    LbToolbarIcon: TLabel;
    LbShortcut: TLabel;
    IconImage: TImage;
    BtChangeIcon: TButton;
    CmBShortcuts: TComboBox;
    BtCancel: TButton;
    BtOK: TButton;
    BtAuto: TButton;
    BtSet: TButton;
    LbMediaType: TLabel;
    CmBMediaTypes: TComboBox;

    procedure FormShow             ( Sender: TObject );
    procedure FormCloseQuery       ( Sender: TObject; var CanClose: Boolean );
    procedure ChangeIconExecute    ( Sender: TObject );
    procedure EdProfileNameKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure EdProfileNameExit    ( Sender: TObject );
    procedure CmBDevicesChange     ( Sender: TObject );
    procedure BtAutoClick          ( Sender: TObject );
    procedure BtSetClick           ( Sender: TObject );
  private
    { Private declarations }
  //*** Select Icon Context

    SkipProfileNameCheckFlag : Boolean;

    procedure SaveProfile0( );
    function  CheckProfileName( ) : Boolean;

  protected
    AutoProfileNameFlag : Boolean;
    PEIconsBig   : TImageList;
    PEIconsSmall : TImageList;
    PEDynIconFlag : Boolean;
    PEIconInd    : Integer;
    PEChangeIconFlag : Boolean;
    procedure Init0();
    procedure Init1();
    procedure Init2();
    procedure SetIconImage( );
    function  SelectProfileIcon( var AImgInd: Integer ): Boolean;

  public
    PEUDProfiles : TK_UDRArray;   // Archive Profiles Table
    PEProfileInd : Integer;       // Archive Profiles Table Index
    PEPCMDeviceProfile : TK_PCMDeviceProfile;
end; // type TK_FormCMProfileDevice = class( TN_BaseForm )

var
  K_FormCMProfileDevice: TK_FormCMProfileDevice;

implementation

{$R *.dfm}
uses
  Math,
  K_UDT1, K_Arch, K_FCMProfileSetting, K_FCMImgProfileProcAttrs, K_CML1F,
  N_Types, N_Lib0, N_Comp1, N_CM1, N_CMMain5F, N_IconSelF, N_CMResF;

const
  K_CMNewProfileName = 'New capture device profile';

//********************************************  TK_FormCMProfileDevice.Init0 ***
//  Init Profile show context common to TWAIN and Video
//
procedure TK_FormCMProfileDevice.Init0();
var
  Ind : Integer;
begin
  with PEPCMDeviceProfile^ do
  begin
  // Prepare Profile
    if PEProfileInd = -1 then
    begin // New Profile
      CMDPCaption := K_CMNewProfileName;
      CMDPShortCut := 'None';
      CMDPImageIndex := K_CMDevIconsSInd;
      CMDPDynSIcon := nil;
      CMDPDynBIcon := nil;
      CMDPDLLInd   := 0;
      CMDPDelphiAction := nil;
      FillChar( CMAutoImgProcAttrs, SizeOf(CMAutoImgProcAttrs), 0 );
      CMDPMTypeID := 0;
      CMDPProductName := '';
      CMDPGroupName := '';
      CMDPStrPar1 := '';
      CMDPStrPar2 := '';
      CMDPDModality := '';
      CMDPDKVP     := 0;
      CMDPDExpTime := 0;
      CMDPDTubeCur := 0;
    end
    else                     // Existing Profile
      K_MoveSPLData( PEUDProfiles.PDE(PEProfileInd)^,
                     PEPCMDeviceProfile^, PEUDProfiles.R.ElemType, [] );

    // Dump Cur Opened Profile
    N_Dump1Str( Format( 'DevSetup Profile Open 0 >> GName=%s GInd=%d PProd="%s" PCapt="%s" PShortCut="%s" IInd=%d MT=%d GN=%s S1=%s S2=%s AIP="%s" %s',
                   [PEUDProfiles.ObjName,PEProfileInd,CMDPProductName,CMDPCaption,
                    CMDPShortCut,CMDPImageIndex,CMDPMTypeID,
                    CMDPGroupName,CMDPStrPar1,CMDPStrPar2,
                    K_CMGetAutoImgProcAttrsDumpText(@CMAutoImgProcAttrs),
                    K_CMPrepDICOMProfileSettingsDump(TK_PCMDCMAttrs(@CMDPDModality))] ) );

    K_CMGetStaticIconsLists( PEIconsBig, PEIconsSmall );
    PEIconInd := CMDPImageIndex;

  // Prepare Profile Controls
    SetIconImage( );
    with CmBShortcuts do
    begin
      Items.Assign( K_CMUnUsedShortCuts );
      Ind := Items.IndexOf( CMDPShortCut );
      if (CMDPShortCut <> '') and (Ind < 0) then
        Items.Insert( 0, CMDPShortCut );
      ItemIndex := Items.IndexOf( CMDPShortCut );
    end;

    with CmBMediaTypes do
    begin
      K_CMEDAccess.EDAGetAllMediaTypes( Items );
      ItemIndex := Items.IndexOfObject( TObject(CMDPMTypeID) );
    end;

  end
end; // end of TK_FormCMProfileDevice.Init0()

//********************************************  TK_FormCMProfileDevice.Init1 ***
//  Init Profile show context common to TWAIN and Video after device list Init
//
procedure TK_FormCMProfileDevice.Init1();
var
  Ind : Integer;

begin
  with CmBDevices, TK_PCMTwainProfile(PEPCMDeviceProfile)^ do
  begin
    if PEProfileInd = -1 then
    begin // New Profile Edit;
      CMDPProductName := '';
      CMDPGroupName := '';
    end;

    if (CMDPProductName <> '') then
    begin
      Ind := Items.IndexOf( CMDPProductName );
      if Ind = -1 then
      begin
        N_Dump1Str( Format( 'DevSetup Profile Open 1 >> Ins PProd="%s"', [CMDPProductName] ) );
        Items.InsertObject( 0, CMDPProductName, TObject(CMDPDLLInd) );
        Ind := 0;
      end;
      ItemIndex := Ind;
//      ItemIndex := Items.IndexOf( CMDPProductName );
    end
    else
    begin
      if PEProfileInd <> -1 then
      begin // New Profile Edit;
        Ind := Items.IndexOf( CMDPCaption );
        ItemIndex := Ind;
        if Ind = -1 then
          K_CMShowMessageDlg( format( K_CML1Form.LLLDevProfile1.Caption,
//              'Selected device profile "%s" is corrupted',
              [CMDPCaption] ), mtWarning );
      end
      else
        ItemIndex := 0;
    end;
    EdProfileName.Text := CMDPCaption;

    if (PEProfileInd = -1) and (Items.Count > 0) then
      EdProfileName.Text := Items[0]
    else if EdProfileName.Text = '' then
      EdProfileName.Text := Items[ItemIndex];

    if ItemIndex >= 0 then
      AutoProfileNameFlag := EdProfileName.Text = Items[ItemIndex];

//    if (PEProfileInd = -1) and (Items.Count > 0) then
//      EdProfileName.Text := Items[0]
//    EdProfileName.Text := Items[ItemIndex];

    if ([cmpfVideoMain,cmpfVideoAll,cmpfTWAINMain,cmpfTWAINAll,cmpfOtherMain,cmpfOtherAll] * N_CM_LogFlags) <> [] then
    begin
      N_Dump2Str( '   Device Names:' );
      N_Dump2Strings( Items, 5 );
    end;

  end;
end; // end of TK_FormCMProfileDevice.Init1()

//********************************************  TK_FormCMProfileDevice.Init2 ***
//  Init Devices ComboBox List by Allowed Devices List
//
procedure TK_FormCMProfileDevice.Init2();
begin
end; // end of TK_FormCMProfileDevice.Init2()

//************************************** TK_FormCMProfileDevice.SetIconImage ***
//
procedure TK_FormCMProfileDevice.SetIconImage( );
var
  PECIcon : TIcon;
begin
  PECIcon := TIcon.Create;
  PEIconsBig.GetIcon( PEIconInd, PECIcon );
  IconImage.Picture.Icon := PECIcon;
  PECIcon.Free;

end; // end of TK_FormCMProfileDevice.SetIconImage

//******************************** TK_FormCMProfileDevice.SelectProfileIcon ***
// Select Icon Index
//
//     Parameters
// AImgInd - Icon index in ImageList
// Result  - Returns TRUE if Icon is selected
//
function TK_FormCMProfileDevice.SelectProfileIcon( var AImgInd: Integer ): Boolean;
//var
//  IconItemInfo: TN_IconItemInfo;
begin

  with N_CMResForm do
  begin

    with N_CreateIconSelectionForm( N_CM_MainForm.CMMCurFMainForm, 510, 335 ) do
    begin
      Caption := K_CML1Form.LLLSelectProfileIcons.Caption; // 'Select Device Icon';
      ISFDGrid.DGMarkNormWidth := 3;
      ISFDGrid.DGLItemsByRows := TRUE;

      if not PEDynIconFlag then // Some Static Icons if Dynamic Icons are absent
        ISFAddIconsRange(N_CM_MainForm.CMMCurBigIcons, K_CMDevIconsSInd, K_CMDevIconsFInd)
      else // All Dynamic Icons (Static Icons not used)
        ISFAddIconsRange(DynIcons44, 0, DynIcons44.Count - 1);

      ISFInit();

      if PEDynIconFlag then
      begin
        ISFDGrid.DGMarkSingleItem( AImgInd ); // Mark Init Item (initial view)
        ISFDGrid.DGScrollToItem( AImgInd );
      end;

      Result := ShowModal() = mrOK; // Show Icon Selection Form
      if not Result then
        Exit;

      with ISFDGrid, ISFIconsArray[DGSelectedInd] do
      begin
//        IconItemInfo := ISFIconsArray[DGSelectedInd];
        AImgInd := IIIIconInd;
      end;
    end; // with N_CreateIconSelectionForm( Self ) do
  end; // with N_CMResForm
end; // end of function TK_FormCMProfileDevice.SelectProfileIcon

//*****************************************  TK_FormCMProfileDevice.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMProfileDevice.FormShow( Sender: TObject );
//label TWAINError, TWAINFin;
begin
  //*** Init Common Device Controls Except Device List
  Init0();

  //***  Init Possible TWAIN List
  K_CMBuildTwainDevicesList( CmBDevices.Items );

{
  with TN_TWGlobObj.Create() do begin
    TWGOpenDSManager( @Application.Handle );
    if TWGRetCode <> 0 then begin
TWAINError:
      K_CMShowMessageDlg( 'TWAIN Error detected >> '#13#10 +
                         '"' + TWGErrorStr  + '".', mtWarning );
      goto TWAINFin;
    end;

    TWGGetDataSources( CmBDevices.Items );
//    if TWGRetCode <> 0 then goto TWAINError;
TWAINFin:
    Free;
  end; // with N_TWGlobObj do
}
  //*** Init Common Device Controls by Device List
  Init1();

    // Dump Cur Opened Profile
  with PEPCMDeviceProfile^ do
    N_Dump1Str( Format( 'DevSetup Profile Form Set >> GName=%s GInd=%d PProd="%s" ProdInd=%d PCapt="%s" PShortCut="%s" IInd=%d MT=%s',
                   [PEUDProfiles.ObjName,PEProfileInd,CmBDevices.Text,CmBDevices.ItemIndex,
                    EdProfileName.Text,
                    CmBShortcuts.Text,PEIconInd,CmBMediaTypes.Text] ) );
end; // end of TK_FormCMProfileDevice.FormShow

//***********************************  TK_FormCMProfileDevice.ChangeIconExecute ***
//
procedure TK_FormCMProfileDevice.ChangeIconExecute(Sender: TObject);
begin
//  if K_CMSelectProfileIcons( PEIconsBig, PEIconsSmall, PEIconInd, PEDynIconFlag ) then
  PEDynIconFlag := K_CMInitProfileIcons( PEIconsBig, PEIconsSmall );
  if SelectProfileIcon( PEIconInd ) then
  begin
    SetIconImage( );
    PEChangeIconFlag := TRUE;
  end;
end; // end of TK_FormCMProfileDevice.ChangeIconExecute

//***********************************  TK_FormCMProfileDevice.SaveProfile0 ***
//  Prepare Profile saving context common to Twain and Video
//
procedure TK_FormCMProfileDevice.SaveProfile0( );
begin
  with PEPCMDeviceProfile^, K_CMEDAccess do
  begin
    CMDPCaption := EdProfileName.Text;

    with CmBMediaTypes do
      if ItemIndex >= 0 then
        CMDPMTypeID := Integer(Items.Objects[ItemIndex]);

    with CmBShortcuts do
      CMDPShortCut := Items[ItemIndex];
    if CMDPShortCut = 'None' then  CMDPShortCut := '';

    if PEChangeIconFlag then
    begin
      CMDPImageIndex := PEIconInd;

    // not needed to use K_SetUDRefField to set profile copy PEPCMDeviceProfile^ Icon fields
    // because reference to UDIcon is in real profile and it will be deleted
    // while profile copy data is copied to real profile in PEUDProfiles.PDE(PEProfileInd)^
      Include(K_UDOperateFlags, K_udoUNCDeletion);
      SavedIcons.DeleteOneChild( CMDPDynBIcon ); //
      CMDPDynBIcon := nil;

      SavedIcons.DeleteOneChild( CMDPDynSIcon );
      CMDPDynSIcon := nil;
      Exclude(K_UDOperateFlags, K_udoUNCDeletion);

      if PEDynIconFlag then
      begin
    // not needed to use K_SetUDRefField to set profile copy PEPCMDeviceProfile^ Icon fields
    // because reference to UDIcon is in real profile and it will be deleted
    // while profile copy data is copied to real profile in PEUDProfiles.PDE(PEProfileInd)^
        CMDPDynBIcon := N_CreateUDDIB( PEIconsBig, PEIconInd, K_CMDynTranspColor,
                           SavedIcons.BuildUniqChildName( 'Icon44(1)' ) );
        SavedIcons.AddOneChildV( CMDPDynBIcon );


        CMDPDynSIcon := N_CreateUDDIB( PEIconsSmall, PEIconInd, K_CMDynTranspColor,
                           SavedIcons.BuildUniqChildName( 'Icon18(1)' ) );
        SavedIcons.AddOneChildV( CMDPDynSIcon );
      end;
    end; // if PEChangeIconFlag then
  end;
end; // end of TK_FormCMProfileDevice.SaveProfile0

//***********************************  TK_FormCMProfileDevice.FormCloseQuery ***
//
procedure TK_FormCMProfileDevice.FormCloseQuery(Sender: TObject;
                                             var CanClose: Boolean);
var
  AddNewProfileFlag : Boolean;
  NewProfileInd : Integer;
begin
  if ModalResult <> mrOK then Exit;


  with CmBDevices, TK_PCMTwainProfile(PEPCMDeviceProfile)^ do
  begin
    if EdProfileName.Text = '' then
      EdProfileName.Text := Items[ItemIndex];
    if EdProfileName.Text = '' then
      EdProfileName.Text := K_CMNewProfileName;

    // Correct User Defined Caption
    EdProfileName.Text := Trim( Copy( EdProfileName.Text, 1, 40 ) );

    CanClose := CheckProfileName();
    if not CanClose then Exit;

    if (CMDPProductName = '') and
       (Items.Count = 0)      then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLDevProfile2.Caption,
//      'Capture devices are not found. Profile will not be saved',
                          mtWarning );
      ModalResult := mrCancel;
      Exit;
    end;

    AddNewProfileFlag := PEProfileInd < 0;
    PEDynIconFlag := PEDynIconFlag or (not AddNewProfileFlag and (CMDPDynSIcon <> nil));

    SaveProfile0();

    if ItemIndex >= 0 then
    begin
      CMDPProductName := Items[ItemIndex];
      CMDPDLLInd := Integer(Items.Objects[ItemIndex]);
    end;

    if AddNewProfileFlag then
    begin
      PEProfileInd := PEUDProfiles.ALength;
      PEUDProfiles.R.ASetLength( PEProfileInd + 1 );
    end;
    K_MoveSPLData( PEPCMDeviceProfile^,
                   PEUDProfiles.PDE(PEProfileInd)^, PEUDProfiles.R.ElemType,
                   [K_mdfFreeAndFullCopy] );

    with PEPCMDeviceProfile^ do
      N_Dump1Str( Format( 'DevSetup Profile Save >> GName=%s GInd=%d PProd="%s" PCapt="%s" PShortCut="%s" IInd=%d MT=%d GN=%s S1=%s S2=%s AIP="%s" %s',
                     [PEUDProfiles.ObjName,PEProfileInd,CMDPProductName,CMDPCaption,
                      CMDPShortCut,CMDPImageIndex,CMDPMTypeID,
                      CMDPGroupName,CMDPStrPar1,CMDPStrPar2,
                      K_CMGetAutoImgProcAttrsDumpText(@CMAutoImgProcAttrs),
                      K_CMPrepDICOMProfileSettingsDump(TK_PCMDCMAttrs(@CMDPDModality))] ) );

    if AddNewProfileFlag then
    begin
      // Add New All Devices List Element
      with K_CMEDAccess.ProfilesList do
      begin
      { Insert to List top
        PDRA.InsertElems(0);
        Inc( N_CM_MainForm.CMMDevGroupInd );
      {}
      { Add to List bottom }
        NewProfileInd := PDRA.ALength();
        PDRA.InsertElems();
      {}
        with TK_PCMDevProfListElem(PDE(NewProfileInd))^ do
        begin
          CMDPLEAInd := PEProfileInd;
          K_SetUDRefField( CMDPLEARef, PEUDProfiles );
        end;
      end;
//?? 2014-12-15      N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
    end;

//?? 2014-12-15    K_SetChangeSubTreeFlags( PEUDProfiles );
//?? 2014-12-15    K_SetArchiveChangeFlag();

    with PEPCMDeviceProfile^ do // Add strings to Protocol
    begin
      if AddNewProfileFlag then
        N_Dump2Str( 'Profile "' + CMDPCaption + '" added' )
      else
        N_Dump2Str( 'Profile "' + CMDPCaption + '" changed' );

      N_Dump2Str( '     (Device Name "' + CMDPProductName + '")' );
    end;

  end;
end; // end of TK_FormCMProfileDevice.FormCloseQuery

//*****************************  TK_FormCMProfileDevice.EdProfileNameKeyDown ***
// Used for check Profile Name duplication routine
//
procedure TK_FormCMProfileDevice.EdProfileNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
//  VK_RETURN : EdProfileNameExit(Sender);
  VK_RETURN : CheckProfileName();
  end;
end; // end of TK_FormCMProfileDevice.EdProfileNameKeyDown

//********************************  TK_FormCMProfileDevice.EdProfileNameExit ***
//  Used for check Profile Name auto set mode
//
procedure TK_FormCMProfileDevice.EdProfileNameExit(Sender: TObject);
begin
  with CmBDevices do
  begin
    AutoProfileNameFlag := EdProfileName.Text = '';
    if not AutoProfileNameFlag and (ItemIndex >= 0) then
      AutoProfileNameFlag := EdProfileName.Text = Items[ItemIndex];
  end;
end; // end of TK_FormCMProfileDevice.EdProfileNameExit

//*********************************  TK_FormCMProfileDevice.CheckProfileName ***
//  Check Profile Name duplication routine
//
function TK_FormCMProfileDevice.CheckProfileName( ) : Boolean;
var
  i : Integer;
  WProfileName : string;
begin
//  Check Profile Caption
  Result := true;
  if SkipProfileNameCheckFlag then begin
    SkipProfileNameCheckFlag := false;
    Exit;
  end;

  WProfileName := EdProfileName.Text;
  for i := 0 to PEUDProfiles.AHigh do
    if i <> PEProfileInd then
      with TK_PCMDeviceProfile( PEUDProfiles.PDE(i) )^ do
        if WProfileName = CMDPCaption then
        begin
          K_CMShowMessageDlg( format( K_CML1Form.LLLDevProfile3.Caption,
      //     'The ''%s'' profile already exists.'#13#10 +
      //                'Please enter another name.',
                              [EdProfileName.Text] ), mtWarning );
          EdProfileName.SetFocus();
          Result := FALSE;
          Exit;
        end;
end; // end of TK_FormCMProfileDevice.CheckProfileName

//*********************************  TK_FormCMProfileDevice.CmBDevicesChange ***
//
procedure TK_FormCMProfileDevice.CmBDevicesChange(Sender: TObject);
begin
  with CmBDevices do
  if AutoProfileNameFlag then
    EdProfileName.Text := Items[ItemIndex];
end; // end of TK_FormCMProfileDevice.CmBDevicesChange

//*********************************  TK_FormCMProfileDevice.BtAutoClick ***
//
procedure TK_FormCMProfileDevice.BtAutoClick(Sender: TObject);
begin
  K_CMImgProfileProcAttrsDlg( @PEPCMDeviceProfile.CMAutoImgProcAttrs, '' );
end; // end of TK_FormCMProfileDevice.BtAutoClick

procedure TK_FormCMProfileDevice.BtSetClick(Sender: TObject);
begin
  K_CMProfileSettingDlg(
        PEPCMDeviceProfile.CMAutoImgProcAttrs.CMAIPResolution,
        PEPCMDeviceProfile.CMDPCaption, IconImage,
        TK_PCMDCMAttrs(@PEPCMDeviceProfile.CMDPDModality) );
end;

end.
