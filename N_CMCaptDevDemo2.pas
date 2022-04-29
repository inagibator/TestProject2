unit N_CMCaptDevDemo2;
// TN_CMCDServObjDemo2 (Demo Device without Capturing Form) implementation

interface
uses Windows, Classes, Forms, Graphics, StdCtrls, ExtCtrls,
     K_CM0, K_CMCaptDevReg,
     N_Types, N_EdStrF;  


type TN_CMCDServObjDemo2 = class( TK_CMCDServObj )
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: THandle; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code
  CDSSlidesArray: TN_UDCMSArray; // Resulting Slides
  CDSTimer: TTimer;
  CDSTimerCounter: integer; // Timer events Counter
  CDSPProfile: TK_PCMDeviceProfile; // Pointer to Device Profile
  CDSStrEditForm: TN_StrEditForm;

  function  CDSGetGroupDevNames     ( AGroupDevNames: TStrings ): Integer; override;
  function  CDSGetDevProfileCaption ( ADevName : string ): string; override;
  function  CDSGetDevCaption        ( ADevName : string ): string; override;
  procedure CDSStartCaptureImages   ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure CDSSettingsDlg          ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure CDSOnTimerExecute       ( ASender: TObject );
end; // end of type TN_CMCDServObjDemo2 = class( TK_CMCDServObj )

var
  N_CMCDServObjDemo2: TN_CMCDServObjDemo2;

implementation

uses SysUtils, Dialogs,
  K_CLib0,
  N_Gra2, N_Lib1, N_CM1, N_Lib0;

//********************************* TN_CMCDServObjDemo2.CDSGetGroupDevNames ***
// Get E2V Device Name
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObjDemo2.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  AGroupDevNames.Add( 'Demo2 Device type 1' );
  AGroupDevNames.Add( 'Demo2 Device type 2' );
  AGroupDevNames.Add( 'Demo2 Device type 3' );
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObjDemo2.CDSGetGroupDevNames

//************************************ TN_CMCDServObjDemo2.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TN_CMCDServObjDemo2.CDSGetDevCaption( ADevName: string ): string;
begin
  Result := ADevName;
end; // procedure TN_CMCDServObjDemo2.CDSGetDevCaption

//***************************** TN_CMCDServObjDemo2.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TN_CMCDServObjDemo2.CDSGetDevProfileCaption( ADevName: string ) : string;
begin
  Result := CDSGetDevCaption( ADevName );
end; // procedure TN_CMCDServObjDemo2.CDSGetDevProfileCaption

//********************* procedure TN_CMCDServObjDemo2.CDSStartCaptureImages ***
// Capture Images by Demo Device and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Is called from CMResForm.NewOtherOnExecuteHandler
//    CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
//
procedure TN_CMCDServObjDemo2.CDSStartCaptureImages( APDevProfile: TK_PCMDeviceProfile );
begin
  CDSPProfile := APDevProfile;
  SetLength( CDSSlidesArray, 0 );
  CDSTimer := TTimer.Create( nil );
  CDSTimerCounter := 0;
  CDSTimer.OnTimer := CDSOnTimerExecute;
  CDSTimer.Interval := 200;
  CDSTimer.Enabled := True;

  CDSStrEditForm := N_ShowNotModalWarning ( 'Capturing, Please wait ...', 'Warning Message', 300 );
end; // procedure TN_CMCDServObjDemo2.CDSStartCaptureImages

//************************************** TN_CMCDServObjDemo2.CDSSettingsDlg ***
procedure TN_CMCDServObjDemo2.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
begin
end; // procedure TN_CMCDServObjDemo2.CDSSettingsDlg

//*********************************** TN_CMCDServObjDemo2.CDSOnTimerExecute ***
// OnTimer Event Handler
//
//     Parameters
// ASender - Event Sender
//
procedure TN_CMCDServObjDemo2.CDSOnTimerExecute( ASender: TObject );
var
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  TestDIBParams: TN_TestDIBParams;
begin
  CDSTimer.Enabled := False;
  Inc( CDSTimerCounter );

  if CDSTimerCounter = 5 then // Create Slide
  begin
    N_CreateTestDIB8( 1, @TestDIBParams );
    TestDIBParams.TDPIndsColor  := -1;
    TestDIBParams.TDPWidth      := 500;
    TestDIBParams.TDPHeight     := 500;
//        TestDIBParams.TDPString := format( 'Captured %d from %s ',
//                                    [CurNum, APDevProfile.CMDPProductName] );
    CapturedDIB := N_CreateTestDIB8( 0, @TestDIBParams );

    NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @(CDSPProfile^.CMAutoImgProcAttrs) );
    NewSlide.SetAutoCalibrated();
    NewSlide.ObjAliase := IntToStr( 1 );

    with NewSlide.P()^ do
    begin
      CMSSourceDescr := CDSPProfile^.CMDPCaption;
      NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
      CMSMediaType := CDSPProfile^.CMDPMTypeID;
    end;

    K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

    SetLength( CDSSlidesArray, 1 );
    CDSSlidesArray[0] := NewSlide;
  end; // if CDSTimerCounter = 5 then // Create Slides

  if CDSTimerCounter > 15 then // All Slides are captured
  begin
    CDSTimer.Free;
    K_CMSlidesSaveScanned3( CDSPProfile, CDSSlidesArray );

    CDSStrEditForm.Close;
    CDSStrEditForm.Release;
    Exit;
  end; // if CDSTimerCounter > 15 then // All Slides are captured

  CDSTimer.Enabled := True;
end; // procedure TN_CMCDServObjDemo2.CDSOnTimerExecute


Initialization

  // Create and Register Demo Device Service Object
  N_CMCDServObjDemo2 := TN_CMCDServObjDemo2.Create( N_CMECD_Demo2Dev_Name );

  with K_CMCDRegisterDeviceObj( N_CMCDServObjDemo2 ) do
  begin
    CDSCaption := 'Demo2';
    IsGroup := True;
//    ShowSettingsDlg := True;
    NotModalCapture := True;
  end;
end.
