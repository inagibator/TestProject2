unit N_CMVideoProfileF;
//*****  Video Device Profile Editor Form

// 19.11.18 - still pin check fixed

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ActiveX, Dialogs, ExtCtrls, StdCtrls, Types,
  K_FCMProfileDevice,
  N_Types, N_Video, N_Video4, N_Lib1, N_CMVideoProfileSF;

type TN_CMVideoProfileForm = class( TK_FormCMProfileDevice )
  bnCameraProp:      TButton;
  bnVideoFormat:     TButton;
  cbCaptButDLL:      TComboBox;
  cbDentUnitDLL:     TComboBox;
  lbCaptButSupport:  TLabel;
  BtPreviewPin:      TButton;
  BtStillPin:        TButton;
  lbDentUnitSupport: TLabel;

  procedure FormShow           ( Sender: TObject );
  procedure FormCloseQuery     ( Sender: TObject; var CanClose: Boolean );
  procedure bnCameraPropClick  ( Sender: TObject );
  procedure bnVideoFormatClick ( Sender: TObject );
  procedure CmBCameraButtonChange ( Sender: TObject );
  procedure CmBDentUnitChange     ( Sender: TObject );
  procedure BtSetClick         ( Sender: TObject );
  procedure BtPreviewPinClick  ( Sender: TObject );
  procedure BtStillPinClick    ( Sender: TObject );

  // functions for enable / disable buttons
  function InitPreviewPin(): Boolean;
  function InitStillPin():   Boolean;
    procedure CmBDevicesChange(Sender: TObject);

public
  DriverStreamSize: TPoint; // Stream resolution, set by Driver dialog
  CMVPVideoCapt:    TN_VideoCaptObj; // main Video Capturing Object
  CMVPVideoCapt4:   TN_VideoCaptObj4; // main Video Capturing Object for Mode 2, 3
end; // type TN_CMVideoProfileForm = class( TK_FormCMProfileTwain )

implementation

{$R *.dfm}

uses
  DirectShow9, DirectDraw,
  K_CM0,
  N_Lib0, N_CM1, K_FSFList, N_CMFPedalSF, N_CML2F;

//****************************************** TN_CMVideoProfileForm.FormShow ***
// Show Video Profile Form
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.FormShow( Sender: TObject );
var
  IError, cbInd, SavedFPCBInd, i: integer;
  StringTemp: string;

  procedure AddCameraButton( AFPCBInd: integer ); // local
  // Add AFPCBInd CameraButton Device Name to cbCaptButDLL.Items and
  // set cbCaptButDLL.ItemIndex if it is equal to SavedFPCBInd
  begin
    with N_FPCBObj.FPCBDevices[ AFPCBInd ] do
    begin
      cbInd := cbCaptButDLL.Items.Add( FPCBName );  // AFPCBInd-th Device Name
      cbCaptButDLL.Items.Objects[ cbInd ] := TObject( AFPCBInd ); // index in FPCBDevices array

      if AFPCBInd = SavedFPCBInd then // Set Item Index
        cbCaptButDLL.ItemIndex := cbInd;
    end; // with N_FPCBObj.FPCBDevices[AFPCBInd] do
  end; // procedure AddCameraButton - local

  procedure AddDentalUnit( AFPCBInd: integer ); // local
  // Add AFPCBInd CameraButton Device Name to cbDentUnitDLL.Items and
  // set cbDentUnitDLL.ItemIndex if it is equal to N_FPCBObj.FPCBDUInd and
  // profile name is equal to N_FPCBObj.FPCBDUProfName
  begin
    with N_FPCBObj.FPCBDevices[ AFPCBInd ] do
    begin
      cbInd := cbDentUnitDLL.Items.Add( FPCBName );  // AFPCBInd-th Device Name
      cbDentUnitDLL.Items.Objects[ cbInd ] := TObject( AFPCBInd ); // index in FPCBDevices array

      if (N_FPCBObj.FPCBDUProfName = PEPCMDeviceProfile^.CMDPCaption) and
         (N_FPCBObj.FPCBDUInd = AFPCBInd) then
        cbDentUnitDLL.ItemIndex := cbInd; // Set Item Index, may be N_FPCB_None if Dental Unit should not be used
    end; // with N_FPCBObj.FPCBDevices[AFPCBInd] do
  end; // procedure AddDentalUnit - local

begin //************************* TN_CMVideoProfileForm.FormShow main body
  N_Dump2Str('Start TN_CMVideoProfileForm.FormShow, CMDPStrPar2 = ' +
                                               PEPCMDeviceProfile^.CMDPStrPar2);
  //*** Init Common Device Controls Except Device List
  Init0();
  //***  Init Possible Video Devices List
  N_DSEnumFilters( CLSID_VideoInputDeviceCategory, '', CmBDevices.Items, IError );

  // N_CML2Form.LLLNotPluggedIn1_c = 'DirectShow Error detected >> '
  if IError <> 0 then
    K_CMShowMessageDlg( N_CML2Form.LLLDirectShowError1.Caption + IntToStr( IError ), mtWarning );

  //*** Init Common Device Controls by Device List
  Init1();

  //*** Init Video specific Controls (cbCaptButDLL)
  //    now same choice (all Camera Button devices) for all capturing devices

  with TK_PCMVideoProfile( PEPCMDeviceProfile )^ do
  begin
    SavedFPCBInd := N_CMConvCBToFPCBInd( CMCaptButDLLInd ); // used in AddCameraButton

    // fill cbCaptButDLL items and set ItemIndex by SavedFPCBInd

    AddCameraButton( N_FPCB_None );
    AddCameraButton( N_FPCB_SoproTouch );
    AddCameraButton( N_FPCB_SchickUSB );
    AddCameraButton( N_FPCB_SchickUSBCam4 );
    AddCameraButton( N_FPCB_Winus100D );
    AddCameraButton( N_FPCB_Win100DBDA );
    AddCameraButton( N_FPCB_MultiCam );
    AddCameraButton( N_FPCB_Keystrokes );
    AddCameraButton( N_FPCB_QI );
    AddCameraButton( N_FPCB_MediaCamPlus );
    AddCameraButton( N_FPCB_ActeonSopro );
    AddCameraButton( N_FPCB_MediaCamPro );
  end; // with TK_PCMVideoProfile(PEPCMDeviceProfile)^ do

  if cbCaptButDLL.ItemIndex = -1 then // Show "None" if not defined
    cbCaptButDLL.ItemIndex := 0;

  // fill cbDentUnitDLL items and set ItemIndex by N_FPCBObj.FPCBDUInd and N_FPCBObj.FPCBDUProfName

  AddDentalUnit( N_FPCB_None );
  AddDentalUnit( N_FPCB_DUPCS );    // Dental Unit - Planmeca Compact Serial
  AddDentalUnit( N_FPCB_DUSirona ); // Dental Unit - Sirona
  AddDentalUnit( N_FPCB_DUSiUCOM );

  if cbDentUnitDLL.ItemIndex = -1 then // Show "None" if not defined
    cbDentUnitDLL.ItemIndex := 0;

  with TK_PCMVideoProfile(PEPCMDeviceProfile)^ do // initialize new Profile
  begin
    if PEProfileInd = -1 then // Is New Profile
    begin
      CMVCMode        := K_cvcmStillImage;
      CMPreviewMode   := 1; // One preview Window in Still Images mode
      CMNumClicksInd  := 0; // NumClicks Groupbox Item Index (0 - Two Clicks, 1 - Single Click)
      CMCaptButDLLInd := 0; // Camera Buttons DLL Index in N_FPCBObj.FPCBDevices (= 0 means no buttons)
    end;
  end; // with PEPCMDeviceProfile^ do // initialize new Profile

  DriverStreamSize.X := -1; // "not defined" flag

  if ( PEPCMDeviceProfile.CMDPStrPar1 = '' ) then // Default Mode
    PEPCMDeviceProfile.CMDPStrPar1 := '1';

  // Disable / Enable buttons
  if Not( InitPreviewPin()) then BtPreviewPin.Enabled := False;
  if Not( InitStillPin())   then BtStillPin.Enabled := False;

  N_Dump2Str( 'TN_CMVideoProfileForm.FormShow before, CMDPStrPar2 = ' +
                                              PEPCMDeviceProfile^.CMDPStrPar2 );
  if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) < 8 then
  begin
    if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) = 7 then
    begin
      StringTemp := '0';
      StringTemp[1] := PEPCMDeviceProfile^.CMDPStrPar2[5];
      PEPCMDeviceProfile^.CMDPStrPar2[5] := PEPCMDeviceProfile^.CMDPStrPar2[7];
      PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2 +
                                                                  StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[8] := StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[7] := '0';
    end;
    // set initial parameters
    // CMDStrPar2 =
    // - Flip
    // - Capture Button usage
    // - Camera Button Threshold
    // - Still Pin usage
    // - Filter
    // - Renderer
    StringTemp := '00000100';

    if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) <> 8 then
      for i := Length( PEPCMDeviceProfile^.CMDPStrPar2 ) + 1 to 8 do
        PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2
                                                                + StringTemp[i];
  end;
  N_Dump2Str( 'TN_CMVideoProfileForm.FormShow after, CMDPStrPar2 = ' +
                                              PEPCMDeviceProfile^.CMDPStrPar2 );
end; // procedure TN_CMVideoProfileForm.FormShow

//************************************ TN_CMVideoProfileForm.FormCloseQuery ***
// Show Video Profile Form
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.FormCloseQuery( Sender: TObject;
                                                        var CanClose: Boolean );
var
  MediaType: PAMMediaType;
  VSCC: TVideoStreamConfigCaps;
  i, j, NumCaps, CapsSize, NewDUInd, ResCode: integer;
  WrkSL: TStringList;
  WrkIndex, WrkWidth, WrkHeight: integer;
  WrkString, NameString, TempStr: string;
  label StopEnum, StopSearch;
begin
  inherited;

  if not CanClose then Exit;
  if ModalResult <> mrOK then Exit;

  with TK_PCMVideoProfile( PEUDProfiles.PDE( PEProfileInd ))^ do
  begin
    if DriverStreamSize.X = -1 then
    begin
      if CMVResolution = '' then
      begin

        if PEPCMDeviceProfile.CMDPStrPar1 = '1' then
          CMVResolution := ' 640 x 480' // default value for new profiles
        else
        begin
          CMVPVideoCapt4 := TN_VideoCaptObj4.Create;
          CMVPVideoCapt4.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
          CMVPVideoCapt4.VCOPrepInterfaces2();


          with CMVPVideoCapt4 do
          begin
            if VCOIVideoCaptFilter = Nil then
              Exit;

          if Not( Assigned( VCOIStreamConfig )) then
          begin// just for case
            VCOCoRes := VCOICaptGraphBuilder.FindInterface(
                   @PIN_CATEGORY_CAPTURE, @MEDIATYPE_Video, VCOIVideoCaptFilter,
                                        IID_IAMStreamConfig, VCOIStreamConfig );
            if Not( Succeeded( VCOCoRes )) then
              Exit;// Interface StreamConfig not found
          end;

          VCOCoRes := VCOIStreamConfig.GetNumberOfCapabilities( NumCaps,
                                                                     CapsSize );
          if VCOCheckRes( 77 ) then
            Exit;

          WrkSL := TStringList.Create;
          WrkSL.Sorted := True;
          WrkSL.Duplicates := dupIgnore; // ignore duplicated Strings (a precaution)

          if NumCaps > 0 then
          begin
            i := 0;
            // for i := 0 to NumCaps - 1 do // along all capabilities
            while True do//VCOCoRes <> S_FALSE do
            begin
              VCOCoRes := VCOIStreamConfig.GetStreamCaps( i, MediaType, VSCC );
              if ( VCOCoRes = S_OK ) then
              begin
                // get i-th Capability
                Inc(i);

              // ***** Add checking pbFormat type (may be VideoInfoHeader2!?)

              with MediaType^, PVideoInfoHeader( pbFormat )^.bmiHeader do
              begin
                N_Dump1Str('i = ' + IntToStr(i) + ', Res. = ' +
                        IntToStr( biWidth ) + 'x' + IntToStr( abs( biHeight )));

                if ( biWidth > 0 ) and ( abs( biHeight )  > 0 ) then

                  if ( IsEqualGUID(VCONeededVideoCMST, NilGUID ) or // any subtype is OK
                                  IsEqualGUID( VCONeededVideoCMST,
                                                                 SubType )) then
                    WrkSL.Add( Format( '%4d x %d', [ biWidth,
                                                             abs( biHeight )]));

              end;

              N_DSDeleteMediaType( MediaType ); // delete MediaType record allocated by DirectShow

            end
            else
              goto StopEnum;
          end; // for i := 0 to NumCaps-1 do // along all capabilities
        end
        else
        begin
          VCOCoRes := VCOIStreamConfig.GetFormat( MediaType );
          with MediaType^ do
            with PVideoInfoHeader( pbFormat )^.bmiHeader do
              begin
                WrkSL.Add( Format( '%4d x %d', [ biWidth, abs( biHeight )]));
              end;
              N_Dump2Str(
                 'VFW Test: Inside Null NumCaps section of VCOEnumVideoSizes' );
            end;

            StopEnum:

            N_Dump2Str('VFW Test: Inside VCOEnumVideoSizes, NumCaps=' +
                                                           IntToStr( NumCaps ));

            NameString := StringReplace( VCOVCaptDevName, ' ', '_',
                                                               [rfReplaceAll] );
            NameString := StringReplace( NameString, '-', '_', [rfReplaceAll] );
            CMVPVideoCapt4.VCOUnableResolutions := TStringList.Create; // create list of unable resolutions
            WrkString := N_MemIniToString( 'CMS_UserDeb', NameString, '' ); // reading from string of resolutions from ini

            //***** adding list of unable resolutions from ini-file
            WrkHeight := 0;

            if WrkString <> '' then
            begin
              while WrkHeight <> -1234567890 do // if there are some unable resolutions
              begin
                WrkHeight := N_ScanInteger( WrkString );
                WrkWidth := N_ScanInteger( WrkString );
                VCOUnableResolutions.Add( Format( ' %d x %d', [ WrkHeight,
                                                                   WrkWidth ]));
              end;

            for i := 0 to VCOUnableResolutions.Count - 1 do
              begin
              WrkIndex := WrkSL.IndexOf( VCOUnableResolutions[i] );
              if WrkIndex <> -1 then
              WrkSL.Delete( WrkIndex );
              end;
            end;

            //***** adding list of unable resolutions for WDM
            if NameString = 'WDM_2860_Capture' then
            begin
              WrkString := N_WDM_2860_Capture;
              WrkHeight := 0;

              while WrkHeight <> -1234567890 do // if there are some unable resolutions
              begin
                WrkHeight := N_ScanInteger( WrkString );
                WrkWidth := N_ScanInteger( WrkString );
                VCOUnableResolutions.Add( Format( ' %d x %d', [ WrkHeight,
                                                                   WrkWidth ]));
              end;

              //***** disabling resolutions
              for i := 0 to VCOUnableResolutions.Count - 1 do
                begin
                WrkIndex := WrkSL.IndexOf( VCOUnableResolutions[i] );
                if WrkIndex <> -1 then
                  WrkSL.Delete( WrkIndex );
              end;
            end;

            FreeAndNil(VCOUnableResolutions);

            if PEPCMDeviceProfile.CMDPStrPar1 = '3' then // for Mode 3, the first resolution that is bigger then the screen's one
            begin
              for j := 0 to WrkSL.Count - 1 do
              begin
                TempStr := WrkSL[ j ];

                DriverStreamSize.X := N_ScanInteger( TempStr );
                N_ScanToken( TempStr );
                DriverStreamSize.Y := N_ScanInteger( TempStr );

                if ( DriverStreamSize.X >= Screen.Width ) and ( DriverStreamSize.Y >= Screen.Height ) then
                   //and (( DriverStreamSize.X / DriverStreamSize.Y ) = 4/3 ) then

                goto StopSearch;
            end;

            TempStr := WrkSL[ WrkSL.Count-1 ];
            DriverStreamSize.X := N_ScanInteger( TempStr );
            N_ScanToken( TempStr );
            DriverStreamSize.Y := N_ScanInteger( TempStr );


            end
            else // for other modes
            begin

              // ***** Search for 4/3 resolution
              for j := 0 to WrkSL.Count - 1 do
              begin
                TempStr := WrkSL[ j ];

                DriverStreamSize.X := N_ScanInteger( TempStr );
                N_ScanToken( TempStr );
                DriverStreamSize.Y := N_ScanInteger( TempStr );

                if ( DriverStreamSize.X >= 640 ) and ( DriverStreamSize.X <= 1024 )
                     and (( DriverStreamSize.X / DriverStreamSize.Y ) = 4/3 ) then

                goto StopSearch;
              end;

              // ***** Search for resolution that is larger then 640 x ...
              for j := 0 to WrkSL.Count - 1 do
              begin
                TempStr := WrkSL[ j ];

                DriverStreamSize.X := N_ScanInteger( TempStr );
                N_ScanToken( TempStr );
                DriverStreamSize.Y := N_ScanInteger( TempStr );

                if ( DriverStreamSize.X >= 640 ) then
                  goto StopSearch;
              end;

              // ***** Just in case there is no resolution that is larger then
              // 640 x ..., just pick the largest one.
              TempStr := WrkSL[ WrkSL.Count-1 ];
              DriverStreamSize.X := N_ScanInteger( TempStr );
              N_ScanToken( TempStr );
              DriverStreamSize.Y := N_ScanInteger( TempStr );

            end; // else

            StopSearch:

            WrkSL.Free;

            CMVResolution := Format( '%4d x %d', [ DriverStreamSize.X,
                                                         DriverStreamSize.Y ] );
            N_Dump1Str( 'Resolution: '+ CMVResolution );
          end;
        end;
      end;
    end // default resolution set
    else
    begin
      CMVResolution := Format( '%4d x %d', [DriverStreamSize.X,
                                                          DriverStreamSize.Y] );
    end;

    CMCaptButDLLInd := 100 + N_GetComboBoxObjInt( cbCaptButDLL ); // + 100 means new variant
    N_i := CMCaptButDLLInd;

   with N_FPCBObj do // Process Dental Unit info
   begin
     NewDUInd := N_GetComboBoxObjInt( cbDentUnitDLL );

     if NewDUInd >= 0 then // temporary/ later remove
     begin

       if NewDUInd >= 1 then // Some Dental Unit was choosen
       begin
         FPCBDUProfName := EdProfileName.Text;
         N_StringToMemIni( 'CMS_Main', 'DentalUnitProfName', FPCBDUProfName );
         N_IntToMemIni(    'CMS_Main', 'DentalUnitDevInd',   NewDUInd );
       end else // No Dental Unit
       begin
         FPCBDUProfName := 'None';
         N_StringToMemIni( 'CMS_Main', 'DentalUnitProfName', FPCBDUProfName );
         N_IntToMemIni(    'CMS_Main', 'DentalUnitDevInd',   N_FPCB_None );
       end;

       N_Dump1Str( Format( 'New Dental Unit Info: "%s" %d %d', [FPCBDUProfName,NewDUInd,FPCBDUInd] ) );

       if NewDUInd <> FPCBDUInd then // Dental Unit changed
       begin
         FPCBUnloadDLL( FPCBDUInd ); // free previous Dental Unit

         FPCBDUInd := 0; // to prevent calling DU functions from FPCBGetDUState while initialization
         ResCode := FPCBLoadDLL( NewDUInd ); // init new Dental Unit

         if ResCode <> 0 then // some errors
         begin
           FPCBDUInd := N_FPCB_None;
           FPCBUnloadDLL( NewDUInd );
         end else // ResCode = 0, all ok
           FPCBDUInd := NewDUInd; // FPCBGetDUState can be called now

       end; // if NewDUInd >= 1 then // Some Dental Unit was choosen

     end; // if NewDUInd <> FPCBDUInd then // Dental Unit changed

   end; // with N_FPCBObj do // Process Dental Unit info

  end; // with TK_PCMVideoProfile(PEUDProfiles.PDE(PEProfileInd))^ do

  FreeAndNil( CMVPVideoCapt );
  FreeAndNil( CMVPVideoCapt4 );

  N_Dump1Str( 'Selected Mode ' + PEPCMDeviceProfile^.CMDPStrPar1 );
end; // procedure TK_FormCMProfileVideo.FormCloseQuery

//********************************* TN_CMVideoProfileForm.bnCameraPropClick ***
// Show Video Capturing Device Dialog, provided by installed Drived
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// bnCameraProp OnClick Handler ("Camera Properties" button)
//
procedure TN_CMVideoProfileForm.bnCameraPropClick( Sender: TObject );
var
  CoRes:         HResult;
  WindowCaption: WideString;
  StreamConfig:  IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  Pages:         CAUUID;
begin
  N_Dump1Str( 'Started bnCameraPropClick' );

  if CMVPVideoCapt <> Nil then
  if CMVPVideoCapt.VCOVCaptDevName <> CmBDevices.Text then
  begin
    N_Dump1Str( 'Device was changed!' );
    FreeAndNil(CMVPVideoCapt);
  end;

  if CMVPVideoCapt = Nil then
  begin
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
    N_s1 := TK_PCMVideoProfile( PEPCMDeviceProfile )^.CMVResolution;

    CMVPVideoCapt.VCOSetVideoSize(
    TK_PCMVideoProfile( PEPCMDeviceProfile )^.CMVResolution, DriverStreamSize );
  end;

  with CMVPVideoCapt do
  begin

  N_i := VCOIError;

  VCOIError := 91;
  if VCOIVideoCaptFilter = Nil then Exit;

  // Find object that contains properties
  CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_CAPTURE,
     @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig, StreamConfig );

  if SUCCEEDED( CoRes ) then // Interface StreamConfig found
  begin
    // Find properties
    CoRes := StreamConfig.QueryInterface( ISpecifyPropertyPages,
                                                                PropertyPages );

    if SUCCEEDED( CoRes ) then // Interface PropertyPages found
    begin
      // Properties array
      PropertyPages.GetPages( Pages );
      PropertyPages := Nil;

      // Show modal form
      WindowCaption := VCOVCaptDevName + ' (1)'; // 'Properties' token will be added!
      OleCreatePropertyFrame( Self.Handle, 0, 0, PWideChar( WindowCaption ),
                      1, @StreamConfig, Pages.cElems, Pages.pElems, 0, 0, Nil );

      // Clean
      StreamConfig := Nil;
      CoTaskMemFree( Pages.pElems );
    end; // if SUCCEEDED(CoRes) then // Interface PropertyPages found
  end; // if SUCCEEDED(CoRes) then // Interface StreamConfig found

  VCOIError := 0;
  VCOSetVideoSize( '', DriverStreamSize );
  end; // with CMVPVideoCapt do
end; // procedure TN_CMVideoProfileForm.bnCameraPropClick

//******************************** TN_CMVideoProfileForm.bnVideoFormatClick ***
// Show StreamConfig Dialog, provided by installed Drived
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// bnVideoFormat OnClick Handler ("Video Format" button)
//
procedure TN_CMVideoProfileForm.bnVideoFormatClick( Sender: TObject );
begin
  N_Dump1Str( 'Started bnVideoFormatClick' );

  if CMVPVideoCapt <> Nil then
  if CMVPVideoCapt.VCOVCaptDevName <> CmBDevices.Text then
  begin
    N_Dump1Str( 'Device was changed!' );
    FreeAndNil(CMVPVideoCapt);
  end;

  if CMVPVideoCapt = Nil then
  begin
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
  end;

  with CMVPVideoCapt do
  begin
    VCOShowFilterDialog( VCOIVideoCaptFilter, Self.Handle );
  end; // with CMVPVideoCapt do

end; // procedure TN_CMVideoProfileForm.bnVideoFormatClick

//***************************** TN_CMVideoProfileForm.CmBCameraButtonChange ***
// Change Camera Button Device
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.CmBCameraButtonChange( Sender: TObject );
begin
  CmBDevicesChange( Sender ); // TK_FormCMProfileDevice method

  FreeAndNil( CMVPVideoCapt );
end; // procedure TN_CMVideoProfileForm.CmBCameraButtonChange

//********************************* TN_CMVideoProfileForm.CmBDentUnitChange ***
// Change Dental Unit Device
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.CmBDentUnitChange( Sender: TObject );
begin
  cbCaptButDLL.ItemIndex := 0;
end; // procedure TN_CMVideoProfileForm.CmBDentUnitChange

//********************************* TN_CMVideoProfileForm.CmBDevicesChange ***
// Change device
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.CmBDevicesChange( Sender: TObject );
var
  StringTemp: string;
  i: Integer;
begin
  inherited;
  if CMVPVideoCapt <> Nil then
  if CMVPVideoCapt.VCOVCaptDevName <> CmBDevices.Text then
  begin
    N_Dump1Str( 'Device was changed!' );
    FreeAndNil(CMVPVideoCapt);
  end;

  if CMVPVideoCapt = Nil then
  begin
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
  end;

  // Disable / Enable buttons
  if Not( InitPreviewPin()) then BtPreviewPin.Enabled := False
    else BtPreviewPin.Enabled := True;

  if Not( InitStillPin())   then BtStillPin.Enabled := False
    else BtStillPin.Enabled := True;

  N_Dump2Str( 'TN_CMVideoProfileForm.FormShow before, CMDPStrPar2 = ' +
                                              PEPCMDeviceProfile^.CMDPStrPar2 );
  if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) < 8 then
  begin
    if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) = 7 then
    begin
      StringTemp := '0';
      StringTemp[1] := PEPCMDeviceProfile^.CMDPStrPar2[5];
      PEPCMDeviceProfile^.CMDPStrPar2[5] := PEPCMDeviceProfile^.CMDPStrPar2[7];
      PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2 +
                                                                  StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[8] := StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[7] := '0';
    end;
    // set initial parameters
    // CMDStrPar2 =
    // - Flip
    // - Capture Button usage
    // - Camera Button Threshold
    // - Still Pin usage
    // - Filter
    // - Renderer
    StringTemp := '00000100';

    if Length( PEPCMDeviceProfile^.CMDPStrPar2 ) <> 8 then
      for i := Length( PEPCMDeviceProfile^.CMDPStrPar2 ) + 1 to 8 do
        PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2
                                                                + StringTemp[i];
  end;
end; // procedure TN_CMVideoProfileForm.CmBDevicesChange

//**************************************** TN_CMVideoProfileForm.BtSetClick ***
// Edit Settings
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// BtSet OnClick Handler ("Settings ..." button)
//
procedure TN_CMVideoProfileForm.BtSetClick( Sender: TObject );
var
  i, IMode, CurMode: Integer;
  CurProductName, CurVideoMode, StringTemp: string;
  SettingsForm: TN_CMVideoProfileSForm;
begin
  N_Dump1Str( 'Start Video Profile Settings Form' );

  N_Dump2Str('TN_CMVideoProfileForm.BtSetClick before, CMDPStrPar2 = ' +
                                               PEPCMDeviceProfile^.CMDPStrPar2);
  if Length(PEPCMDeviceProfile^.CMDPStrPar2) < 8 then
  begin
    if Length(PEPCMDeviceProfile^.CMDPStrPar2) = 7 then
    begin
      StringTemp := '0';
      StringTemp[1] := PEPCMDeviceProfile^.CMDPStrPar2[5];
      PEPCMDeviceProfile^.CMDPStrPar2[5] := PEPCMDeviceProfile^.CMDPStrPar2[7];
      PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2 +
                                                                  StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[8] := StringTemp[1];
      PEPCMDeviceProfile^.CMDPStrPar2[7] := '0';
    end;
    // set initial parameters
    // CMDStrPar2 =
    // - Flip
    // - Capture Button usage
    // - Camera Button Threshold
    // - Still Pin usage
    // - Filter
    // - Renderer
    StringTemp := '00000100';

    if Length(PEPCMDeviceProfile^.CMDPStrPar2) <> 8 then
      for i := Length(PEPCMDeviceProfile^.CMDPStrPar2) + 1 to 8 do
        PEPCMDeviceProfile^.CMDPStrPar2 := PEPCMDeviceProfile^.CMDPStrPar2
                                                                + StringTemp[i];
  end;
  N_Dump2Str('TN_CMVideoProfileForm.BtSetClick after, CMDPStrPar2 = ' +
                                               PEPCMDeviceProfile^.CMDPStrPar2);

  if BtStillPin.Enabled = False then // if there is no still pin
    PEPCMDeviceProfile^.CMDPStrPar2[4] := '2';
  N_Dump2Str(
       'TN_CMVideoProfileForm.BtSetClick after CMDPStrPar2[4], CMDPStrPar2 = ' +
                                               PEPCMDeviceProfile^.CMDPStrPar2);

  SettingsForm := TN_CMVideoProfileSForm.Create( Application );
  with SettingsForm do
  begin
    BaseFormInit( Self, 'VideoSettingsForm', [ rspfMFRect,rspfCenter ],
                                                  [ rspfAppWAR,rspfShiftAll ] );
    PVProfile := TK_PCMVideoProfile(PEPCMDeviceProfile);
    PVEnableKeystrokes := ( N_FPCB_Keystrokes =
                                          N_GetComboBoxObjInt( cbCaptButDLL ) );

    if N_GetComboBoxObjInt( cbDentUnitDLL ) = N_FPCB_DUSirona then // process 'SironaActivateModeS', 'SironaCloseModeS'
    begin
      // Prepare Form before ShowModal();
      // Prepare cbActivateMode, cbCloseMode CheckBoxes

      cbActivateMode.Enabled := ( 3 = N_MemIniToInt( 'CMS_UserMain', 'SironaActivateMode', 3 ) );
      if cbActivateMode.Enabled then cbActivateMode.Checked := ( 1 = N_MemIniToInt( 'CMS_Main', 'SironaActivateModeS', 0 ) );

      cbCloseMode.Enabled    := ( 3 = N_MemIniToInt( 'CMS_UserMain', 'SironaCloseMode',    3 ) );
      if cbCloseMode.Enabled then cbCloseMode.Checked := ( 1 = N_MemIniToInt( 'CMS_Main', 'SironaCloseModeS', 0 ) );

      ShowModal();

      // Update all needed variables after ShowModal(); by values in cbActivateMode, cbCloseMode CheckBoxes
      // Save SironaActivateModeS, FPCBDUActivateMode  and  SironaCloseModeS, FPCBDUCloseMode

      if cbActivateMode.Enabled then
      begin
        CurMode := 0;   if cbActivateMode.Checked then CurMode := 1;
        N_IntToMemIni( 'CMS_Main', 'SironaActivateModeS', CurMode ); // save SironaActivateModeS
        N_FPCBObj.FPCBDUActivateMode := CurMode;
        N_Dump2Str( Format( 'Set SironaActivateMode = %d', [CurMode] ) );
      end;

      if cbCloseMode.Enabled then
      begin
        CurMode := 0;   if cbCloseMode.Checked then CurMode := 1;
        N_IntToMemIni( 'CMS_Main', 'SironaCloseModeS', CurMode ); // save SironaCloseModeS
        N_FPCBObj.FPCBDUCloseMode := CurMode;
        N_Dump2Str( Format( 'Set SironaCloseMode = %d', [CurMode] ) );
      end;

    end else // No link to Sirona Dental Unit
    begin
      cbActivateMode.Enabled := False;
      cbCloseMode.Enabled := False;

      ShowModal();
    end;

  end; // with SettingsForm do

  Exit;


  with TK_FormSelectFromList.Create( Application ) do
  begin
    Caption := N_CML2Form.LLLVideoModeCaption.Caption;
    SelectListBox.Color := $00A2FFFF;
    SetItemsList( Nil );
    CurListBox.Items.Clear();
    CurListBox.Items.Add( N_CML2Form.LLLVideoModeName1.Caption );
    CurListBox.Items.Add( N_CML2Form.LLLVideoModeName2.Caption );
    CurListBox.Items.Add( N_CML2Form.LLLVideoModeName3.Caption );

    BFIniSize := Point( 100, 150 );
    BaseFormInit( Nil, 'VideoModeForm', [ rspfMFRect,rspfCenter ],
                                                  [ rspfAppWAR,rspfShiftAll ] );

    CurProductName := CmBDevices.Text;

    with PEPCMDeviceProfile^  do
    begin
      // if the new Mode is selected then we should delete the last Mode resolution
      TK_PCMVideoProfile( PEPCMDeviceProfile )^.CMVResolution := '';

      CurVideoMode := CMDPStrPar1;
      IMode := 0; // Video mode 1

      if CurVideoMode = '2' then // Video mode 2
        IMode := 1
      else if CurVideoMode = '3' then // Video mode 3
        IMode := 2;

      if not SelectElement( IMode ) then Exit;

      case IMode of
      0 : CMDPStrPar1 := '1';
      1 : CMDPStrPar1 := '2';
      2 : CMDPStrPar1 := '3';
      end; // case IMode of

    end; // with PEPCMDeviceProfile^  do
  end; // with TK_FormSelectFromList.Create( Application ) do

end; // procedure TN_CMVideoProfileForm.BtSetClick

//********************************* TN_CMVideoProfileForm.BtPreviewPinClick ***
// Preview Pin properties
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.BtPreviewPinClick( Sender: TObject );
var
  CoRes:         HResult;
  WindowCaption: WideString;
  StreamConfig:  IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  CAUUID :       TagCAUUID;
begin
  if CMVPVideoCapt <> Nil then
  if CMVPVideoCapt.VCOVCaptDevName <> CmBDevices.Text then
  begin
    N_Dump1Str( 'Device was changed!' );
    FreeAndNil(CMVPVideoCapt);
  end;

  if CMVPVideoCapt = Nil then // just for case
  begin
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
  end;

  with CMVPVideoCapt do
  begin

  VCOIError := 91;
  if VCOIVideoCaptFilter = Nil then Exit;


  // Search for preview pin
  CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_PREVIEW,
               @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, IID_IAMStreamConfig,
                                                                 StreamConfig );
  if CoRes <> NOERROR then
  Begin
    CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_PREVIEW,
     @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig, StreamConfig );
    if CoRes = S_OK then
    Begin
      // Get properties
      CoRes := StreamConfig.QueryInterface( ISpecifyPropertyPages,
                                                                PropertyPages );
      if CoRes = S_OK Then
      Begin
        CoRes := PropertyPages.GetPages( CAUUID );
        if ( CoRes = S_OK ) and ( CAUUID.cElems > 0 ) then
        Begin // Show modal form
          WindowCaption := VCOVCaptDevName + ' (3)'; // 'Properties' token will be added!
          OleCreatePropertyFrame( Self.Handle, 0, 0, PWideChar( WindowCaption ),
                    1, @StreamConfig, Cauuid.cElems, Cauuid.pElems, 0, 0, Nil );
          CoTaskMemFree( CAUUID.pElems );
        End;
        PropertyPages := Nil;
      End;
      StreamConfig := Nil;
    End;
  End;

  VCOIError := 0;

  end; // with CMVPVideoCapt do
end;// procedure TN_CMVideoProfileForm.BtPreviewPinClick

//*********************************** TN_CMVideoProfileForm.BtStillPinClick ***
// Still Pin properties
//
//     Parameters:
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
procedure TN_CMVideoProfileForm.BtStillPinClick( Sender: TObject );
var
  CoRes:         HResult;
  WindowCaption: WideString;
  StreamConfig:  IAMStreamConfig;
  PropertyPages: ISpecifyPropertyPages;
  CAUUID :       TagCAUUID;
begin
  N_Dump1Str('BtStillPinClick start');

  if CMVPVideoCapt <> Nil then
  if CMVPVideoCapt.VCOVCaptDevName <> CmBDevices.Text then
  begin
    N_Dump1Str( 'Device was changed!' );
    FreeAndNil(CMVPVideoCapt);
  end;

  if CMVPVideoCapt = Nil then // just in case
  begin
    N_Dump1Str('CMVPVideoCapt = Nil start');
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    N_Dump1Str('After CMVPVideoCapt := TN_VideoCaptObj.Create;');
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    N_Dump1Str('Before CMVPVideoCapt.VCOPrepInterfaces();');
    CMVPVideoCapt.VCOPrepInterfaces();
    N_Dump1Str('After CMVPVideoCapt.VCOPrepInterfaces();');
  end;

  with CMVPVideoCapt do
  begin

  N_Dump1Str('with CMVPVideoCapt do start');

  VCOIError := 91;
  if VCOIVideoCaptFilter = Nil then Exit;

  N_Dump1Str('Before VCOICaptGraphBuilder.FindInterface');

  // Search for pin, no interleaved, because it is only about graphics
  CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_STILL,
     @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig, StreamConfig );
  N_Dump1Str('After VCOICaptGraphBuilder.FindInterface');

  if CoRes = S_OK then
  Begin
  N_Dump2Str( 'Finded Interface STILL_PIN OK' );
    N_Dump1Str('Before StreamConfig.QueryInterface');
    CoRes := StreamConfig.QueryInterface( ISpecifyPropertyPages,
                                                                PropertyPages );
    if CoRes = S_OK Then
    Begin
      N_Dump1Str('PropertyPages.GetPages( CAUUID );');
      CoRes := PropertyPages.GetPages( CAUUID );
      if ( CoRes = S_OK ) and ( CAUUID.cElems > 0 ) then
      Begin // Show form
        N_Dump1Str('if ( CoRes = S_OK ) and ( CAUUID.cElems > 0 ) then started');

        WindowCaption := VCOVCaptDevName + ' (4)'; // 'Properties' token will be added!
        N_Dump1Str('Before OleCreatePropertyFrame');
        OleCreatePropertyFrame( Self.Handle, 0, 0, PWideChar( WindowCaption ),
                    1, @StreamConfig, Cauuid.cElems, Cauuid.pElems, 0, 0, Nil );
        N_Dump1Str('After OleCreatePropertyFrame');
        CoTaskMemFree( CAUUID.pElems );
        N_Dump1Str('After CoTaskMemFree( CAUUID.pElems );');
      End;
      PropertyPages := Nil;
    End;
    StreamConfig := Nil;
  End;

  N_Dump1Str('After if CoRes = S_OK then');

  VCOIError := 0;
  end; // with CMVPVideoCapt do

  N_Dump1Str('BtStillPinClick end');
end; // procedure TN_CMVideoProfileForm.BtStillPinClick

//************************************ TN_CMVideoProfileForm.InitPreviewPin ***
// Try to find Preview Pin
//
function TN_CMVideoProfileForm.InitPreviewPin(): Boolean;
var
  CoRes:        HResult;
  StreamConfig: IAMStreamConfig;
begin
  Result := False;
   if CMVPVideoCapt = Nil then // just for case
  begin
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
  end;

  with CMVPVideoCapt do
  begin

  VCOIError := 91;
  if VCOIVideoCaptFilter = Nil then Exit;

  // Search for pin
  CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_PREVIEW,
               @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, IID_IAMStreamConfig,
                                                                 StreamConfig );
  if CoRes <> NOERROR then
  begin
    CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_PREVIEW,
     @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig, StreamConfig );
    if CoRes = S_OK then
      Result := True
    else
      Result := False;

  end
  else
    Result := False;

  StreamConfig := Nil;
  end;
end; // function TN_CMVideoProfileForm.InitPreviewPin(): Boolean;

//************************************** TN_CMVideoProfileForm.InitStillPin ***
// Try to find Still Pin
//
function TN_CMVideoProfileForm.InitStillPin(): Boolean;
var
  CoRes:        HResult;
  StreamConfig: IAMStreamConfig;
begin
  Result := False;
  N_Dump1Str('Still Pin search - 1');
   if CMVPVideoCapt = Nil then // just for case
  begin
    N_Dump1Str('Still Pin search - 2');
    CMVPVideoCapt := TN_VideoCaptObj.Create;
    CMVPVideoCapt.VCOVCaptDevName := CmBDevices.Text; // Capturing Device Name
    CMVPVideoCapt.VCOPrepInterfaces();
  end;

  with CMVPVideoCapt do
  begin

  N_Dump1Str('Still Pin search - 3');

  VCOIError := 91;
  if VCOIVideoCaptFilter = Nil then Exit;

  N_Dump1Str('Still Pin search - 4');

  // Search for still pin, no interleaved media type, because still pin is for graphics only
  CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_STILL,
               @MEDIATYPE_Interleaved, VCOIVideoCaptFilter, IID_IAMStreamConfig,
                                                                 StreamConfig );
  if CoRes <> NOERROR then
  begin
    N_Dump1Str('Still Pin search - 5');
    CoRes := VCOICaptGraphBuilder.FindInterface( @PIN_CATEGORY_STILL,
     @MEDIATYPE_Video, VCOIVideoCaptFilter, IID_IAMStreamConfig, StreamConfig );
    if CoRes = S_OK then
      Result := True
    else
      Result := False;

  end
  else
    Result := False;

  StreamConfig := Nil;
  end;

  N_Dump1Str('Still Pin search result - '+BoolToStr(Result));

end; // function TN_CMVideoProfileForm.InitStillPin

end.
