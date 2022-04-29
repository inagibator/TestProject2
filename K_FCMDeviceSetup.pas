unit K_FCMDeviceSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, ActnList,
  N_Types, N_BaseF,
  K_CM0, K_Script1;

type TK_FormDeviceSetup = class( TN_BaseForm )
    PageControl: TPageControl;

    TSVideo: TTabSheet;
      LbVideo: TLabel;
      LVVideo: TListView;
      BtAddProfileVideo: TButton;
      BtDelProfileVideo: TButton;
      BtEditProfileVideo: TButton;
      BtCopyProfileVideo: TButton;

    TSTWAIN: TTabSheet;
      LbTwain: TLabel;
      LVTWAIN: TListView;
      BtAddProfileTWAIN: TButton;
      BtDelProfileTWAIN: TButton;
      BtEditProfileTWAIN: TButton;
      BtCopyProfileTWAIN: TButton;

    TSOther: TTabSheet;
      LbOther: TLabel;
      LVOther: TListView;
      BtAddProfileOther: TButton;
      BtDelProfileOther: TButton;
      BtEditProfileOther: TButton;
      BtCopyProfileOther: TButton;

    TSOther3D: TTabSheet;
      LbOther3D: TLabel;
      LVOther3D: TListView;
      BtAddProfileOther3D: TButton;
      BtDelProfileOther3D: TButton;
      BtEditProfileOther3D: TButton;
      BtCopyProfileOther3D: TButton;

    BtCancel: TButton;
    BtOK: TButton;
    BtRearrange: TButton;

    TimerContEdit: TTimer;

    ActionList1: TActionList;
      AddProfile: TAction;
      DelProfile: TAction;
      EditProfile: TAction;
      CopyProfile: TAction;
      Rearrange: TAction;

    procedure FormShow           ( Sender: TObject );
    procedure AddProfileExecute  ( Sender: TObject );
    procedure EditProfileExecute ( Sender: TObject );
    procedure DelProfileExecute  ( Sender: TObject );
    procedure CopyProfileExecute(Sender: TObject);
    procedure RearrangeExecute(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure LVTWAINSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    // Current means based on currently visible Tab (Profile, FormClass, ...)
    CurLV:       TListView;   // Current ListView with Profile names
    CurProfiles: TK_UDRArray; // Current UDRArray with all profiles of current type
                              // (one of K_CMEDAccess .TwainProfiles .OtherProfiles or .VideoProfiles)
    CurFormClass:      TN_BaseFormClass;    // Current Form Class for edidting Profile
    CurPDeviceProfile: TK_PCMDeviceProfile; // Pointer to current Profile
                                            // (to one of next (below) three profiles)
    CurTwainProfile : TK_CMTwainProfile;
    CurOtherProfile : TK_CMOtherProfile;
    CurOtherProfile3D : TK_CMOtherProfile3D;
    CurVideoProfile : TK_CMVideoProfile;

    procedure SelectProfilesContext ();
    procedure EditProfileProc  ( ANewProfileFlag : Boolean );
    procedure CheckTabsVisible ();
  public
    { Public declarations }
end; // type TK_FormDeviceSetup = class( TN_BaseForm )

var
  K_FormDeviceSetup: TK_FormDeviceSetup;

implementation

{$R *.dfm}

uses
{$IF SizeOf(Char) = 2}
  AnsiStrings,
{$IFEND}
  K_UDT1, K_Arch, K_FCMProfileDevice, K_FCMProfileTwain, // K_FCMProfileOther, K_FCMProfileVideo,
  K_FCMProfileOther1, K_FCMProfileOther2, K_CMCaptDevReg, K_CM1, K_FCMDeviceLimitWarn, K_CML1F,
  K_FSFList, K_STBuf, K_UDC, K_UDT2, K_FCMDPRearrange,
  N_Lib1, N_CM1, N_CMMain5F, N_CMVideoProfileF, N_CMFPedalSF; // N_CMProfOther1F,


//****************  TK_FormDeviceSetup class handlers  ******************

//********************************************* TK_FormDeviceSetup.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TK_FormDeviceSetup.FormShow( Sender: TObject );

  procedure InitProfileList( AList: TListView; AUDProfiles : TK_UDRArray ); // local
  var
    i: Integer;
  begin
    if AUDProfiles <> nil then
    begin
      for i := 0 to AUDProfiles.AHigh  do
      begin
        with TK_PCMDeviceProfile( AUDProfiles.PDE(i) )^ do
          AList.AddItem( CMDPCaption, nil );
      end;

      if AUDProfiles.ALength > 0 then
      begin
        AList.ItemIndex := 0;
        AList.Selected := AList.Items[0];
      end; // if AUDProfiles.ALength > 0 then begin
    end;
  end; // procedure InitProfileList( AList: TListView; AUDProfiles : TK_UDRArray ); // local

begin //*********** main dody of TK_FormDeviceSetup.FormShow
  inherited;


  CheckTabsVisible();
  if TSTWAIN.TabVisible then
    PageControl.ActivePageIndex := 0 // X-Ray TWAIN tab
  else
    PageControl.ActivePageIndex := 3; // Video tab

//  SelectProfilesContext();

  if TSVideo.TabVisible then
    InitProfileList( LVVideo, K_CMEDAccess.VideoProfiles );

  if TSTWAIN.TabVisible then
    InitProfileList( LVTWAIN, K_CMEDAccess.TwainProfiles );

  if TSOther.TabVisible then
    InitProfileList( LVOther, K_CMEDAccess.OtherProfiles );

  if TSOther.TabVisible then
    InitProfileList( LVOther3D, K_CMEDAccess.OtherProfiles3D );

  SelectProfilesContext();

  CurLV.SetFocus;

  CopyProfile.Visible :=  //K_CMDesignModeFlag   and
                          not K_CMDemoModeFlag and
                          K_CMGAModeFlag       and
                          (K_CMEDAccess.ProfilesSaveMode = K_cmdpServer);
//  Rearrange.Visible   :=  FALSE and K_CMDesignModeFlag;
  Rearrange.Enabled := LVVideo.Items.Count + LVTWAIN.Items.Count + LVOther.Items.Count > 1;
end; // end of TK_FormDeviceSetup.FormShow

//************************************ TK_FormDeviceSetup.AddProfileExecute ***
// Add New TWAIN, Other or Video Profile
//
//     Parameters
// Sender - Event Sender
//
// OnExecute ActionList1.AddProfile Action handler
// used for "Add" buttons on all Tabs
//
procedure TK_FormDeviceSetup.AddProfileExecute( Sender: TObject );
begin
//  SelectProfilesContext();
  EditProfileProc( true );
  Rearrange.Enabled := LVVideo.Items.Count + LVTWAIN.Items.Count + LVOther.Items.Count > 1;
  SelectProfilesContext();
end; // end of procedure TK_FormDeviceSetup.AddProfileScanExecute

//*********************************** TK_FormDeviceSetup.EditProfileExecute ***
// Edit existing TWAIN, Other or Video Profile
//
//     Parameters
// Sender - Event Sender
//
// OnExecute ActionList1.EditProfile Action handler
// used for "Properties" buttons on all Tabs
//
procedure TK_FormDeviceSetup.EditProfileExecute( Sender: TObject );
begin
//  SelectProfilesContext();
  if CurLV.ItemIndex < 0 then Exit;
  EditProfileProc( FALSE );
  CurLV.SetFocus();
end; // end of procedure TK_FormDeviceSetup.EditProfileScanExecute

//************************************ TK_FormDeviceSetup.DelProfileExecute ***
// Delete existing TWAIN, Other or Video Profile
//
//     Parameters
// Sender - Event Sender
//
// OnExecute ActionList1.DeleteProfile Action handler
// used for "Delete" buttons on all Tabs
//
procedure TK_FormDeviceSetup.DelProfileExecute( Sender: TObject );
var
  WItem: TListItem;
  i : Integer;
  PCMDeviceProfile : TK_PCMDeviceProfile;
begin
//  SelectProfilesContext();

  WItem := CurLV.Selected;
  if WItem = nil then Exit;
  // Try to delete Real MediaType
  if mrYes <> K_CMShowMessageDlg( format( K_CML1Form.LLLDelProfile1.Caption,
//        'Are you sure you want to delete this ''%s'' profile?',
                                 [WItem.Caption] ), mtConfirmation ) then Exit;

  N_Dump2Str( 'Profile "' + WItem.Caption + '" del start' );

  // Delete All Devices List Element
  with K_CMEDAccess.ProfilesList do
  begin
    for i := AHigh() downto 0 do
      with TK_PCMDevProfListElem(PDE(i))^ do
      begin
        if (CMDPLEARef <> CurProfiles) or
           (CMDPLEAInd < CurLV.ItemIndex) then Continue;
        if CMDPLEAInd = CurLV.ItemIndex then
          PDRA.DeleteElems(i) // Delete needed element
        else
          Dec(CMDPLEAInd);   // Correct Profile Index
      end;
  end;

//  with CurProfiles.R, PCMDeviceProfile^ do begin
  with CurProfiles.R do
  begin
    PCMDeviceProfile := TK_PCMDeviceProfile(P(CurLV.ItemIndex));
  // Delete Profile Saved Icons
    Include(K_UDOperateFlags, K_udoUNCDeletion);
    with PCMDeviceProfile^, N_FPCBObj do
    begin
      K_CMEDAccess.SavedIcons.DeleteOneChild( CMDPDynBIcon );
      K_CMEDAccess.SavedIcons.DeleteOneChild( CMDPDynSIcon );
      Exclude(K_UDOperateFlags, K_udoUNCDeletion);
      CMDPDelphiAction.Free; // Free profile Action
      if CurProfiles <> K_CMEDAccess.VideoProfiles then
      // For not Video Profiles
        K_CMLimitDevDelProfileFromRTDBContext( PCMDeviceProfile ) // Should be Done before UI Update
      else
      // For Video Profiles - Clear Dental Unit Link if needed
      if CMDPCaption = FPCBDUProfName then
      begin // Clear Dental Unit Link
        N_Dump2Str( 'Clear Profile Dental Unit Device >> ' + FPCBDevices[FPCBDUInd].FPCBName );
        FPCBUnloadDLL( FPCBDUInd ); // free  current Dental Unit DLL
        // Clear Cur Dental Unit
        FPCBDUInd := N_FPCB_None;
        FPCBDUProfName := 'None';
        // Dental Unit Info to IniFile
        N_StringToMemIni( 'CMS_Main', 'DentalUnitProfName', FPCBDUProfName );
        N_IntToMemIni(    'CMS_Main', 'DentalUnitDevInd',   FPCBDUInd );
      end; // if PCMDeviceProfile.CMDPCaption = N_FPCBObj.FPCBDUProfName then
    end; // with PCMDeviceProfile^, N_FPCBObj do

  // Delete Profile
    DeleteElems( CurLV.ItemIndex );
  end;
  N_Dump2Str( 'Profile objects deleted' );

  K_SetChangeSubTreeFlags( CurProfiles );
  K_SetArchiveChangeFlag();

  CurLV.DeleteSelected();
  Dec( N_CM_MainForm.CMMDevGroupInd );

  Rearrange.Enabled := LVVideo.Items.Count + LVTWAIN.Items.Count + LVOther.Items.Count > 1;

  N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
  N_Dump2Str( 'Profile UI updated' );

  with K_CMEDAccess do
//    if StateSaveMode = K_cmetImmediately then
      EDASaveContextsData( [K_cmssSkipSlides] );// Save Contexts
end; // end of procedure TK_FormDeviceSetup.DelProfileExecute


//****************  TK_FormDeviceSetup private methods  ******************

//******************************** TK_FormDeviceSetup.SelectProfilesContext ***
//  Select Current Profiles Context
//
// Set Tabs visibility and variables
//   CurLV, CurProfiles, CurPDeviceProfile, CurFormClass
// by PageControl.ActivePageIndex
//
procedure TK_FormDeviceSetup.SelectProfilesContext();
begin
  CheckTabsVisible(); // Set some Tabs invisible if needed

  case PageControl.ActivePageIndex of

  0: begin //***** TWAIN
    CurLV             := LVTWAIN;
    CurProfiles       := K_CMEDAccess.TwainProfiles;
    CurPDeviceProfile := TK_PCMDeviceProfile(@CurTwainProfile);
    CurFormClass      := TK_FormCMProfileTwain;
//    CurFormClass      := TK_FormCMProfileDevice;
  end;

  1: begin //***** Other
    CurLV             := LVOther;
    CurProfiles       := K_CMEDAccess.OtherProfiles;
    CurPDeviceProfile := TK_PCMDeviceProfile(@CurOtherProfile);
    CurFormClass      := TK_FormCMProfileOther1;
  end;

  2: begin //***** Other 3D
    CurLV             := LVOther3D;
    CurProfiles       := K_CMEDAccess.OtherProfiles3D;
    CurPDeviceProfile := TK_PCMDeviceProfile(@CurOtherProfile3D);
    CurFormClass      := TK_FormCMProfileOther2;
  end;

  3: begin //***** Video
    CurLV             := LVVideo;
    CurProfiles       := K_CMEDAccess.VideoProfiles;
    CurPDeviceProfile := TK_PCMDeviceProfile(@CurVideoProfile);
    CurFormClass      := TN_CMVideoProfileForm;
  end;

  end; // case PageControl.ActivePageIndex of

  DelProfile.Enabled := CurLV.ItemIndex >= 0;
  EditProfile.Enabled := DelProfile.Enabled;
  CopyProfile.Enabled := DelProfile.Enabled;
  if CurLV.ItemIndex < 0 then Exit;

  N_Dump1Str( Format( 'DevSetup Page index = %d', [PageControl.ActivePageIndex] ) );
end; // end of procedure TK_FormDeviceSetup.SelectProfilesContext

//************************************** TK_FormDeviceSetup.EditProfileProc ***
//  Edit existed or create and edit new Profile
//
//    Parameters
//  ANewProfileFlag - =TRUE if new profile should be created (and edited)
//
// Should be called after SelectProfilesContext, which has prepared
//   CurLV, CurProfiles, CurPDeviceProfile, CurFormClass
//
procedure TK_FormDeviceSetup.EditProfileProc( ANewProfileFlag : Boolean );
var
  SavedCursor : TCursor;
  PDeviceProfile: TK_PCMDeviceProfile; // Pointer to current Profile
  ShowLimitationWarning : Boolean;
begin
  if CurProfiles = nil then
  begin
    N_Dump1Str( '!!! Dev context was not init' );
    Exit;
  end;

  // Create one of Editor Forms:
  //   TK_FormCMProfileTwain, TK_FormCMProfileOther or TK_FormCMProfileVideo

  if CurLV = LVOther then
  begin
    if not ANewProfileFlag then
    begin
      PDeviceProfile := TK_PCMDeviceProfile( CurProfiles.PDE(CurLV.ItemIndex) );

      if PDeviceProfile.CMDPGroupName = '' then
      begin
         if not N_CMECDConvProfile( PDeviceProfile ) then // convertion error
         begin
           K_CMShowMessageDlg( K_CML1Form.LLLDelProfile2.Caption,
//             'Bad device Profile. Please delete it and create again.',
                               mtError );
           Exit;
         end;
      end; // if PDeviceProfile.CMDPGroupName = '' then

    end;
  end; // if CurLV = LVOther then

  with TK_FormCMProfileDevice(CurFormClass.Create( Application )) do // Create Editor Form of needed type
  begin
//    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    PEPCMDeviceProfile := CurPDeviceProfile;
    PEUDProfiles := CurProfiles;

    if ANewProfileFlag then // New Profile should be created in Editor Form
      PEProfileInd := -1 // PEProfileInd = -1 can be used as "New Profile" flag in Editor Forms
    else // Edit existed Profile
      PEProfileInd := CurLV.ItemIndex;

    if ShowModal() <> mrOK then Exit; // Show Editor Form (new Profile (if needed) wil be created in it

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;

    Self.Refresh();
    N_CM_MainForm.CMMCurFMainForm.Refresh();

    if not ANewProfileFlag then
    begin
      CurLV.Items[PEProfileInd].Caption := CurPDeviceProfile.CMDPCaption;
//?? 2014-12-15      N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
//PDeviceProfile.CMDPStrPar1 := PDeviceProfile.CMDPStrPar1 + '_test';
    end
    else
    begin // Add Device Profile to List ()
      with CurProfiles, TK_PCMDeviceProfile( PDE(PEProfileInd) )^ do
        CurLV.AddItem( CMDPCaption, nil );

      CurLV.SetFocus();
      CurLV.ItemIndex := CurLV.Items.Count - 1;
    end;

    ShowLimitationWarning := FALSE;
    if CurProfiles <> K_CMEDAccess.VideoProfiles then
      ShowLimitationWarning := not K_CMLimitDevNewProfileToRTDBContext( CurPDeviceProfile );

    N_CM_MainForm.CMMUpdateUIByDeviceProfiles(); //?? 2014-12-15

    if ShowLimitationWarning then
      K_FCMShowDeviceLimitWarning(); // Show Warning

    K_SetChangeSubTreeFlags( CurProfiles );
    K_SetArchiveChangeFlag();

    with K_CMEDAccess do
//      if StateSaveMode = K_cmetImmediately then
      EDASaveContextsData( [K_cmssSkipSlides] ); // Save Contexts

    Screen.Cursor := SavedCursor;

  end; // with TK_FormCMProfileTwain(CurFormClass.Create(Application)) do
{debug code for Belonogov
K_CMCloseOnCurUICloseFlag := TRUE;
K_CMD4WCloseAppByUI := K_CMD4WAppRunByCOMClient;
K_CMCloseOnFinActionFlag := TRUE;
}
end; // end of procedure TK_FormDeviceSetup.EditProfileProc

//************************************* TK_FormDeviceSetup.CheckTabsVisible ***
// Set some Tabs invisible if needed
//
procedure TK_FormDeviceSetup.CheckTabsVisible();
begin
  // visible if not D4WScan
  TSVideo.TabVisible := not K_CMScanDataForD4W;
  // visible only in Professional version or D4WScan
  TSTWAIN.TabVisible := (K_CMSLiRegStatus > K_lrtLight) or K_CMScanDataForD4W;
  // visible only in Professional version and not D4WScan
  TSOther.TabVisible := (K_CMSLiRegStatus > K_lrtLight) and not K_CMScanDataForD4W;
  TSOther3D.TabVisible := (K_CMSLiRegStatus > K_lrtLight) and not K_CMScanDataForD4W;
{
  TSVideo.TabVisible := TRUE;               // always visible
  TSTWAIN.TabVisible := K_CMSLiRegStatus > K_lrtLight; // visible only in Professional version
  TSOther.TabVisible := (K_CMSLiRegStatus > K_lrtLight); // visible only in Professional version
}
end; // end of TK_FormDeviceSetup.CheckTabsVisible

//*********************************** TK_FormDeviceSetup.CopyPorfileExecute ***
// Copy current profile to selected client computers
//
procedure TK_FormDeviceSetup.CopyProfileExecute(Sender: TObject);
var
  i, WInt, DSize, CurCompID, k : Integer;
  CompIDs, SelectedInds, SkipedIDs : TN_IArray;
  UDInstanceInfo : TN_UDBase;
  PData : Pointer;
  ResCode : TK_CMEDResult;
  SK_actUDType, SCurCompID : string;
  IK_actUDType, ProfileTypeCode : Integer; // 0 - TWAIN, 1 - Other, 2 - Video
  CompSavedIcons : TN_UDBase;
  CompProfiles : TK_UDRArray;
  CompProfilesList : TK_UDRArray;
  CompProfileInd : Integer;
  PCompDeviceProfile: TK_PCMDeviceProfile; // Pointer to Client Device Profile
  BIconUDName, SIconUDName, SCompIDField : string;
  FCurPDeviceProfile: TK_PCMDeviceProfile; // Pointer to current Profile

label LLoop1;
begin

  SelectProfilesContext();
  if CurLV.ItemIndex < 0 then Exit;
  FCurPDeviceProfile := CurProfiles.PDE( CurLV.ItemIndex );
  ProfileTypeCode := 0;
  if CurLV = LVOther then ProfileTypeCode := 1
  else
  if CurLV = LVOther3D then ProfileTypeCode := 2
  else
  if CurLV = LVVideo then ProfileTypeCode := 3;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      /////////////////////////////////
      // Prepare Proper Computers List
      //
      with CurDSet1 do
      begin
        // Select all records from Locked Slides Table
        Connection := LANDBConnection;
        if K_CMEDAccess.ProfilesSaveMode = K_cmdpServer then
        begin // K_cmdpServer - use Server Computer Name and ID
          IK_actUDType := Ord(K_actServerUD);
          SQL.Text := 'select ' +
          K_CMENDASServID + ',' +
          K_CMENDASServName +
          ' from ' + K_CMENDBAllServersTable +
          ' where ' + K_CMENDASServName + '<>''' + K_CMSServerClientInfo.CMSClientVirtualName +  '''' +
          ' order by ' + K_CMENDASServID + ' asc';
        end
        else
        begin // K_cmdpClientName or K_cmdpClientIP - use Client Computer Name and ID
        //!!! Not use now
          IK_actUDType := Ord(K_actGInstUD);
          SQL.Text := 'select ' +
          K_CMENDBGAInstsTFGlobID + ',' + K_CMENDBGAInstsTFCName + ',' +
          K_CMENDBGAInstsTFLocalID +
          ' from ' + K_CMENDBGAInstsTable +
          ' where ' + K_CMENDBGAInstsTFLocalID + '=' + IntToStr(ClientAppTypeID) +
                  ' and ' +
                  K_CMENDBGAInstsTFCName + '<>''' + K_CMSServerClientInfo.CMSClientVirtualName +  '''' +
          ' order by ' + K_CMENDBGAInstsTFGlobID + ' asc';
        end;

        Filtered := false;
        Open;
        SetLength(CompIDs, RecordCount);
        if Length(CompIDs) = 0 then
        begin
          Close;
          K_CMShowMessageDlg1( 'Nothing to do',
                               mtInformation, [], '', 5 );
          Exit;
        end;
        First;
        i := 0;
        TmpStrings.Clear;
        while not EOF do
        begin
          SCurCompID := Fields[1].AsString;
          if Trim(SCurCompID) <> '' then
          begin // To exclude "strange" computer records
          // Add computer to list
            CompIDs[i] := Fields[0].AsInteger;
            TmpStrings.Add( Fields[1].AsString );
            Inc(i);
          end;
          Next;
        end;
        Close;
      end; // with CurDSet1 do
      //
      // end of Prepare Proper Computers List
      /////////////////////////////////

      /////////////////////////////////
      // Select Computers to copy
      //
      with K_GetFormSelectFromList( nil, 'CopyProfile' ) do
      begin
        Caption := 'Select Clients to copy profile';
        SetItemsList( TmpStrings, TRUE );
        SetLength( SelectedInds, 0 );

        if Width < 250 then
          Width := 250;

        if not SelectElements( SelectedInds ) or (Length(SelectedInds)=0) then
        begin
          N_Dump1Str( 'TK_FormDeviceSetup.CopyPorfileExecute >> Cancel by user' );
          Exit;
        end;
      end; // with K_GetFormSelectFromList( nil, 'CopyProfile' )
      //
      // end of Select Computers to copy
      /////////////////////////////////

      /////////////////////////
      // Copy Profile Loop
      //
      SetLength(SkipedIDs, Length(SelectedInds));

      SK_actUDType := IntToStr(IK_actUDType);
      N_Dump1Str( 'TK_FormDeviceSetup.CopyPorfileExecute >> Binary Data type code =' + SK_actUDType );


      BIconUDName := FCurPDeviceProfile^.CMDPDynBIcon.ObjName;
      SIconUDName := FCurPDeviceProfile^.CMDPDynSIcon.ObjName;

{!!! Transaction and isolation_level not needed
      with CurSQLCommand1 do
      begin
        CommandText := EDADBIsolationLevelSet(K_tilSerializable);
        Execute;
      end;
{}
      for i := 0 to High(SelectedInds) do
      begin
        N_Dump2Str( 'TK_FormDeviceSetup.CopyPorfileExecute >> Start populate to ' + TmpStrings[SelectedInds[i]] );
        CurCompID := CompIDs[SelectedInds[i]];
        SCurCompID := IntToStr(CurCompID);

{!!! Transaction and isolation_level not needed
        LANDBConnection.BeginTrans;
{}
{
        with CurSQLCommand1 do
        begin
          ExtDataErrorCode := K_eeDBLock;
          Connection := LANDBConnection;
          CommandText := 'LOCK TABLE ' + K_CMENDBAAInstsTable + ' IN EXCLUSIVE MODE;';
          Execute;
        end;
}
        ////////////////////////////////
        // Check if Selected Computer works
        //
        with CurDSet1 do
        begin
          if K_CMEDAccess.ProfilesSaveMode = K_cmdpServer then
            SCompIDField := K_CMENDBAAInstsTFServID
          else //!!! Not use now
            SCompIDField := K_CMENDBAAInstsTFGlobID;
          SQL.Text := 'select Count(*) from '  +  K_CMENDBAAInstsTable +
                      ' where ' + SCompIDField + ' = ' + SCurCompID;
          Open;
          WInt := Fields[0].AsInteger;
          Close;
        end;
        //
        // Check if Selected Computer works
        ////////////////////////////////

        if WInt = 0 then
        begin
        ////////////////////////////////
        // Copy Profile to one Computer
        //

          // Get Client Instance binary data
          UDInstanceInfo := TN_UDBase.Create;
          ResCode := EDAGetOneAppContext( SK_actUDType, SCurCompID, '0', PData, DSize );
          if (DSize > 0) and (ResCode = K_edOK) then
          begin
          //////////////////////////////////////////
          // Copy Profile to existing Profiles Context
          //

        {$IF SizeOf(Char) = 2}
        //////////////////////////////////////////////////////////////
        // Special code to correct wrong DeviceProfile field name in SDT format
        //
            AnsiTextBuf := AnsiStrings.AnsiReplaceStr( PAnsiChar(PData), 'CMÂDProductName', 'CMDPProductName' );
            PData := @AnsiTextBuf[1];
        //
        // end of special code to correct wrong DeviceProfile field name in SDT format
        //////////////////////////////////////////////////////////////
        {$IFEND}

            EDAAnsiTextToString(PData, DSize);

            K_SerialTextBuf.LoadFromText(PChar(PData));
        //K_GetFormTextEdit.EditStrings( K_SerialTextBuf.TextStrings );
        //N_S := PChar(PData);
        //K_GetFormTextEdit.EditText(N_S);
            K_LoadTreeFromText0(UDInstanceInfo, K_SerialTextBuf, TRUE);

          // Add Profile
           // Init Client Device Context
            K_UDCursorGet('CPI:').SetRoot(UDInstanceInfo);
            with K_UDCursorForceDir('CPI:DeviceProfiles') do
            begin
              CompSavedIcons := nil;
              if FCurPDeviceProfile.CMDPDynSIcon <> nil then
                CompSavedIcons := K_UDCursorForceDir('CPI:DeviceProfiles\SavedIcons');

              CompProfiles := nil;
              case ProfileTypeCode of
                0: begin
                  CompProfiles := TK_UDRArray(DirChildByObjName('TwainProfiles'));
                  if CompProfiles = nil then
                  begin
                    CompProfiles := K_CreateUDByRTypeName('TK_CMTwainProfile', 0);
                    CompProfiles.ObjName := 'TwainProfiles';
                    AddOneChild(CompProfiles);
                  end;
                end;
                1:begin
                  CompProfiles := TK_UDRArray(DirChildByObjName('OtherProfiles'));
                  if CompProfiles = nil then
                  begin
                    CompProfiles := K_CreateUDByRTypeName('TK_CMOtherProfile', 0);
                    CompProfiles.ObjName := 'OtherProfiles';
                    AddOneChild(CompProfiles);
                  end;
                end;
                2:begin
                  CompProfiles := TK_UDRArray(DirChildByObjName('OtherProfiles3D'));
                  if CompProfiles = nil then
                  begin
                    CompProfiles := K_CreateUDByRTypeName('TK_CMOtherProfile3D', 0);
                    CompProfiles.ObjName := 'OtherProfiles3D';
                    AddOneChild(CompProfiles);
                  end;
                end;
                3:begin
                  CompProfiles := TK_UDRArray(DirChildByObjName('VideoProfiles'));
                  if CompProfiles = nil then
                  begin
                    CompProfiles := K_CreateUDByRTypeName('TK_CMVideoProfile', 0);
                    CompProfiles.ObjName := 'VideoProfiles';
                    AddOneChild(CompProfiles);
                  end;
                end;
              end; // case ProfileTypeCode of


              CompProfilesList := TK_UDRArray(DirChildByObjName('ProfilesList'));
              if CompProfilesList = nil then
              begin
                CompProfilesList := K_CreateUDByRTypeName('TK_CMDevProfListElem', 0);
                CompProfilesList.ObjName := 'ProfilesList';
                AddOneChild( CompProfilesList );
              end; // if CompProfilesList = nil then


              CompProfileInd := -1;
              // Search Profile with same name
              for k := 0 to CompProfiles.AHigh do
              begin
                PCompDeviceProfile := TK_PCMDeviceProfile(CompProfiles.PDE(k));
                with FCurPDeviceProfile^ do
                  if PCompDeviceProfile.CMDPCaption = CMDPCaption then
                  begin
                    CompProfileInd := k;
                    break;
                  end;
              end;

              if CompProfileInd = -1 then
              begin // Add New Profile
                k := CompProfiles.ALength();
                CompProfiles.ASetLength( k + 1 );
                WInt := CompProfilesList.Alength();
                CompProfilesList.ASetLength(WInt + 1);
                with TK_PCMDevProfListElem(CompProfilesList.PDE(WInt))^ do
                begin
                  CMDPLEAInd := k;
                  K_SetUDRefField( CMDPLEARef, CompProfiles );
                end;
              end
              else // Replace Existing
                k := CompProfileInd;

              PCompDeviceProfile := TK_PCMDeviceProfile(CompProfiles.PDE(k));

              if CompProfileInd <> -1 then
                with PCompDeviceProfile^ do
                begin // Clear icons of existing profile
                  Include(K_UDOperateFlags, K_udoUNCDeletion);
                  CompSavedIcons.DeleteOneChild( CMDPDynBIcon ); //
                  K_SetUDRefField( TN_UDBase(CMDPDynBIcon), nil );

                  CompSavedIcons.DeleteOneChild( CMDPDynSIcon );
                  K_SetUDRefField( TN_UDBase(CMDPDynSIcon), nil );
                  Exclude(K_UDOperateFlags, K_udoUNCDeletion);
                end;

              // Copy values to Client Profile
              case ProfileTypeCode of
                0: TK_PCMTwainProfile(PCompDeviceProfile)^ :=
                                      TK_PCMTwainProfile(FCurPDeviceProfile)^;
                1: TK_PCMOtherProfile(PCompDeviceProfile)^ :=
                                      TK_PCMOtherProfile(FCurPDeviceProfile)^;
                2: TK_PCMOtherProfile3D(PCompDeviceProfile)^ :=
                                      TK_PCMOtherProfile3D(FCurPDeviceProfile)^;
                3: TK_PCMVideoProfile(PCompDeviceProfile)^ :=
                                      TK_PCMVideoProfile(FCurPDeviceProfile)^;
              end; // case ProfileTypeCode of

              with PCompDeviceProfile^ do
              if CMDPDynSIcon <> nil then
              begin // Dynamic (not static) Icons are used
                CMDPDynBIcon.ObjName := CompSavedIcons.BuildUniqChildName( 'Icon44(1)' );
                CompSavedIcons.AddOneChildV( CMDPDynBIcon );
                // Change Icon Object Owner for correct saving to SDT
                CMDPDynBIcon.Owner := CompSavedIcons;
                // Inc RefCounter is needed because this field value was set
                // in "Copy values to Client Profile" by Pascal (not SPL) assignment
                Inc(CMDPDynBIcon.RefCounter);

                CMDPDynSIcon.ObjName := CompSavedIcons.BuildUniqChildName( 'Icon18(1)' );
                CompSavedIcons.AddOneChildV( CMDPDynSIcon );
                // Change Icon Object Owner for correct saving to SDT
                CMDPDynSIcon.Owner := CompSavedIcons;
                // Inc RefCounter is needed because this field value was set
                // in "Copy values to Client Profile" by Pascal (not SPL) assignment
                Inc(CMDPDynSIcon.RefCounter);
              end;
            end; // with K_UDCursorForceDir('CPI:DeviceProfiles') do

            // Save Client Instance binary data
            ResCode := EDASaveOneAppContext( CurDSet1, IK_actUDType, CurCompID, 0,
                                             UDInstanceInfo);
            if ResCode <> K_edOK then
            begin
              N_Dump1Str( 'TK_FormDeviceSetup.CopyPorfileExecute >> Binary Data saving error >> Computer=' + TmpStrings[i] );
            end;

            // Return Icon Objects Owners
            FCurPDeviceProfile^.CMDPDynBIcon.Owner := SavedIcons;
            FCurPDeviceProfile^.CMDPDynSIcon.Owner := SavedIcons;
            UDInstanceInfo.UDDelete();
          //
          // end of Copy Profile to existing Profiles Context
          //////////////////////////////////////////
          end
          else
          begin
            N_Dump1Str( 'TK_FormDeviceSetup.CopyPorfileExecute >> Binary Data is absent' );
            goto LLoop1;
          end;
        //
        // End of Copy Profile to one Computer
        ////////////////////////////////
        end  // if WInt = 0 then
        else // Save Skiped ClientID
          SkipedIDs[i] := CurCompID;

LLoop1: //********
{!!! Transaction and isolation_level not needed
        LANDBConnection.CommitTrans();
{}
      end; // for i := 0 to High(SelectedInds) do

{!!! Transaction and isolation_level not needed
      with CurSQLCommand1 do
      begin
        CommandText := EDADBIsolationLevelDefault();
        Execute;
      end;
{}
      // Return Icon Objects Names
      FCurPDeviceProfile^.CMDPDynBIcon.ObjName := BIconUDName;
      FCurPDeviceProfile^.CMDPDynSIcon.ObjName := SIconUDName;

      // Dump Skiped Computers ID
      SCurCompID := '';
      for i := 0 to High(SkipedIDs) do
      begin
        if SkipedIDs[i] = 0 then break;
        SCurCompID := SCurCompID + ' ' + IntToStr(SkipedIDs[i]);
      end;
      if SCurCompID <> '' then
        N_Dump1Str( format('TK_FormDeviceSetup.CopyPorfileExecute >> Comp IDs %s are skiped',[SCurCompID] ) );
      //
      // end of Copy Profile Loop
      /////////////////////////

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormDeviceSetup.CopyPorfileExecute ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  CurLV.SetFocus();

end; // procedure TK_FormDeviceSetup.CopyPorfileExecute

//************************************* TK_FormDeviceSetup.RearrangeExecute ***
// Rearrange device profiles
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCapRearrangeDP Action handler
//
procedure TK_FormDeviceSetup.RearrangeExecute(Sender: TObject);
var
  SavedCursor : TCursor;
begin
  with TK_FormCMDPRearrange.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    if mrOK = ShowModal then
    begin

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;

      N_CM_MainForm.CMMUpdateUIByDeviceProfiles(); //?? 2014-12-15

      K_SetChangeSubTreeFlags( K_CMEDAccess.ProfilesList );
      K_SetArchiveChangeFlag();

      with K_CMEDAccess do
        EDASaveContextsData( [K_cmssSkipSlides] ); // Save Contexts

      Screen.Cursor := SavedCursor;
    end;
  end;
end; // procedure TK_FormDeviceSetup.RearrangeExecute


procedure TK_FormDeviceSetup.PageControlChange(Sender: TObject);
begin
//  inherited;
  SelectProfilesContext();

end; // procedure TK_FormDeviceSetup.PageControlChange


procedure TK_FormDeviceSetup.LVTWAINSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  DelProfile.Enabled := Selected;
  EditProfile.Enabled := Selected;
  CopyProfile.Enabled := Selected;
end; // procedure TK_FormDeviceSetup.LVTWAINSelectItem

end.
