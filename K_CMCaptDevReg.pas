unit K_CMCaptDevReg;
// All Capturing Devices Base Class Object

interface

uses Classes, Forms, Controls,  K_CM0, N_Types;

//********************************************************** TK_CMCDServObj ***
// Capture Devices Service Object
//
type TK_CMCDServObj = class
  CDSName : string;
  CDSCaption : string;
  CDSIsGroup : Boolean;
  CDSShowSettingsDlg : Boolean;
  CDSNotModalCapture : Boolean;
// Capture to Study attrs
//  CDSStudyCaptDlg  : TForm;
//  CDSStudyCaptDlgCtrlsPanel : TControl;
  constructor Create( const ACDSName : string );
  function  CDSGetGroupDevNames( AGroupDevNames : TStrings ) : Integer; virtual;
  function  CDSGetDevCaption( ADevName : string ) : string; virtual;
  function  CDSGetDevProfileCaption( ADevName : string ) : string; virtual;
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                              var ASlidesArray : TN_UDCMSArray ); virtual;
  procedure CDSStartCaptureImages( APDevProfile: TK_PCMDeviceProfile ); virtual;
  procedure CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile ); virtual;
  procedure CDSSetDevProfilebyGInd( APDevProfile: TK_PCMDeviceProfile; AGInd : Integer ); virtual;
// Capture to Study
{
  function  CDSStartCaptureToStudy( APDevProfile: TK_PCMDeviceProfile;
                out ACaptDlg : TForm; out ACaptDlgCPanel : TControl;
                out ACaptSeriesRoutine : TN_ProcObj;
                out ACaptAutoStartRoutine : TN_ProcObj ) : TK_CMStudyCaptState; virtual;
}
  function  CDSStartCaptureToStudy( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ) : TK_CMStudyCaptState; virtual;
  function  CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; virtual;
  function  CDSGetDefaultDevIconInd( const AProductName : string ) : Integer; virtual;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; virtual;
public
  property IsGroup : Boolean read CDSIsGroup write CDSIsGroup;
  property ShowSettingsDlg : Boolean read CDSShowSettingsDlg write CDSShowSettingsDlg;
  property NotModalCapture : Boolean read CDSNotModalCapture write CDSNotModalCapture;
end;

function  K_CMCDRegisterDeviceObj( ADevServObj : TK_CMCDServObj ) : TK_CMCDServObj;
function  K_CMCDGetDeviceObjByInd( ADevObjInd : Integer ) : TK_CMCDServObj;
function  K_CMCDGetDeviceObjByName( const AServObjName : string ) : TK_CMCDServObj;
function  K_CMCDGetDeviceObj( APDevProfile: TK_PCMDeviceProfile ) : TK_CMCDServObj;
procedure K_CMCDGetRegCaptions( ADevCaptions : TStrings );
procedure K_CMCDGetRegCaptions3D( ADevCaptions : TStrings );
procedure K_CMCDRenameRegistered( ARenameCaptsList : TStrings );

var
  K_CMCaptDevsList : TStringList;
  K_CMCaptDevsRenameFlag   : Boolean;
  K_CMCaptDevCaptsOrderedList : TStringList;
  K_CMCaptDevCaptsOrdered3DList : TStringList;

function N_CMECDConvProfile( APDevProfile: TK_PCMDeviceProfile ) : Boolean;

implementation

uses  N_CM1;

////////////////////////////////////////////
// Capture Device Service Object Order List
//
//var K_CMCaptDevsOrderArray : array [0..2] of string = ( 'Product3', 'Product2', 'Product1' );

{*** TK_CMCDServObj ***}

//**************************************************** TK_CMCDServObj.Create ***
// Create Capture Device Service Object
//
//     Parameters
// ACDSName - Capture Device Service Object Name
//
// Capture Device Service Object Name is stored in CMS Data Base in Device profile
//
constructor TK_CMCDServObj.Create( const ACDSName: string );
begin
  CDSName := ACDSName;
  CDSCaption := ACDSName;
end; // constructor TK_CMCDServObj.Create

//**************************************** TK_CMCDServObj.CDSGetGroupDevNames ***
// Get Group Capture Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill by Devices Names
// Result         - Returns number of Capture Devices in resulting Strings or -1
//                  if some problems with device software are detected
//
// Fill given Strings object with Gruop Devices Names.
//
function  TK_CMCDServObj.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  Result := -1;
  AGroupDevNames.Clear;
end; // procedure TK_CMCDServObj.CDSGetGroupDevNames

//**************************************** TK_CMCDServObj.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TK_CMCDServObj.CDSGetDevCaption( ADevName : string ) : string;
begin
  Result := CDSCaption;
  if IsGroup then
    Result := ADevName;
end; // procedure TK_CMCDServObj.CDSGetDevCaption

//**************************************** TK_CMCDServObj.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TK_CMCDServObj.CDSGetDevProfileCaption( ADevName : string ) : string;
begin
  Result := CDSGetDevCaption( ADevName );
//    Result := Result + ' / ' + CDSGetDevCaption( ADevName );
end; // procedure TK_CMCDServObj.CDSGetDevProfileCaption

//**************************************** TK_CMCDServObj.CDSCaptureImages ***
// Get Group Capture Devices Names
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Fill given Strings object with Gruop Devices Names.
//
procedure TK_CMCDServObj.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray : TN_UDCMSArray );
begin
end; // procedure TK_CMCDServObj.CDSCaptureImages

//**************************************** TK_CMCDServObj.CDSCaptureImages ***
// Get Group Capture Devices Names
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Fill given Strings object with Gruop Devices Names.
//
procedure TK_CMCDServObj.CDSStartCaptureImages( APDevProfile: TK_PCMDeviceProfile );
begin
end; // procedure TK_CMCDServObj.CDSCaptureImages

//************************************************** TK_CMCDServObj.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - pointer to device profile record
//
procedure TK_CMCDServObj.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile);
begin

end; // procedure TK_CMCDServObj.CDSSettingsDlg

//*********************************** TK_CMCDServObj.CDSSetDevProfilebyGInd ***
// Set profile attributes Using Device Group Index
//
//     Parameters
// APDevProfile - pointer to device profile record
//
procedure TK_CMCDServObj.CDSSetDevProfilebyGInd( APDevProfile: TK_PCMDeviceProfile; AGInd : Integer);
begin

end; // procedure TK_CMCDServObj.CDSSetDevProfilebyGInd
{
//*********************************** TK_CMCDServObj.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// ACaptDlg - resulting Device Capture Form (should be nil if not Modal Capture mode)
// ACaptDlgCPanel - resulting Device Capture Form Panel with controls which should be enabled in Capture to Study Dlg
// ACaptSeriesRoutine - resulting Capture series by device UI routine
// ACaptAutoStartRoutine - resulting Capture Auto start routine
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TK_CMCDServObj.CDSStartCaptureToStudy( APDevProfile: TK_PCMDeviceProfile;
                out ACaptDlg: TForm; out ACaptDlgCPanel: TControl;
                out ACaptSeriesRoutine : TN_ProcObj;
                out ACaptAutoStartRoutine : TN_ProcObj ): TK_CMStudyCaptState;
begin
  ACaptDlg := nil;
  ACaptDlgCPanel := nil;
  ACaptSeriesRoutine := nil;
  ACaptAutoStartRoutine := nil;
  Result := K_cmscNon;
end; // function TK_CMCDServObj.CDSStartCaptureToStudy
}
//*********************************** TK_CMCDServObj.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TK_CMCDServObj.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
begin
  with AStudyDevCaptAttrs do
  begin
    CMSDCDDlg       := nil;    // Device CMS Capture Dlg (should be nil if not Modal Capture mode)
    CMSDCDDlgCPanel := nil; // Device CMS Capture Dlg Panel with Controls which should be visible in Capture to Study Dlg
    CMSDCDLaunchDevUIProc    := nil; // Capture to Study using Device Self UI (not Device CMS Capture Dlg) procedure of object
    CMSDCDCaptureSlideProc   := nil; // Capture One Slide procedure of object for CaptureToStudy (outer) AutoTake, if nil then inner (device) AutoTake is implemented
    CMSDCDCaptureDisableProc := nil; // Device CMS Capture Dlg disable procedure of object
    CMSDCDCaptureEnableProc := nil; // Device CMS Capture Dlg enable  procedure of object
    CMSDCDAutoTakeStateGetFunc := nil; // Device CMS Capture Dlg AutoTake get state (should be set to nil if AutoTake is device built-in)
    CMSDCDAutoTakeStateSetProc := nil; // Device CMS Capture Dlg AutoTake set state (should be set to nil if AutoTake is device built-in)
  end;
  Result := K_cmscNon;
end; // function TK_CMCDServObj.CDSStartCaptureToStudy

//*************************************** TK_CMCDServObj.CDSOpenDev3DViewer ***
// Open device 3D viewer
//
//     Parameters
// ADev3D - pointer to device profile record
// Result - Returns 0 if OK, -1 - if device is not 3D
//
function TK_CMCDServObj.CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer;
begin
  Result := -1;
end; // procedure TK_CMCDServObj.CDSOpenDev3DViewer

//********************************** TK_CMCDServObj.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TK_CMCDServObj.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 0;
end; // function TK_CMCDServObj.CDSGetDefaultDevIconInd

//*********************************** TK_CMCDServObj.CDSGetDefaultDevDCMMod ***
// Get Device default DICOM Modality by Profile Product Name
//
//     Parameters
// AProductName - device Product name
// Result - Returns device DICOM Modality (or '' if is not defined)
//
function TK_CMCDServObj.CDSGetDefaultDevDCMMod( const AProductName : string): string;
begin
  Result := '';
end; // function TK_CMCDServObj.CDSGetDefaultDevDCMMod

{*** end of TK_CMCDServObj ***}

//************************************************** K_CMCDRegisterDeviceObj ***
// Register Capture Devices Service Object
//
//     Parameters
// ADevServObj - given Devices Service Object to register
// Result - Returns given Devices Service Object
//
function  K_CMCDRegisterDeviceObj( ADevServObj : TK_CMCDServObj ) : TK_CMCDServObj;
begin
  Result := ADevServObj;
  if ADevServObj = nil then Exit; // precaution
  if K_CMCaptDevsList = nil then
    K_CMCaptDevsList :=  TStringList.Create;
  K_CMCaptDevsList.AddObject( ADevServObj.CDSName, ADevServObj );
end; // procedure K_CMCDRegisterDeviceObj

//************************************************ K_CMCDGetDeviceObjByInd ***
// Get Capture Devices Object by Device Profile
//
//     Parameters
// AGroupName - Product Group Name
// AProdName  - Product Name
// Result - Returns selected object or nil
//
function  K_CMCDGetDeviceObjByInd( ADevObjInd : Integer ) : TK_CMCDServObj;
begin
  Result := nil;
  if K_CMCaptDevsList = nil then Exit; // precaution
  if (ADevObjInd < 0) or (ADevObjInd >= K_CMCaptDevsList.Count) then Exit;
  Result := TK_CMCDServObj(K_CMCaptDevsList.Objects[ADevObjInd]);
end; // function K_CMCDGetDeviceObjByInd

//************************************************ K_CMCDGetDeviceObjByNames ***
// Get Capture Devices Object by Device Profile
//
//     Parameters
// AServObjName - Capture Device Service Object Name
// Result - Returns selected object or nil
//
function K_CMCDGetDeviceObjByName( const AServObjName : string ) : TK_CMCDServObj;
var
  Ind : Integer;
begin
  Result := nil;
  if K_CMCaptDevsList = nil then Exit; // precaution
  Ind := K_CMCaptDevsList.IndexOf( AServObjName );
  Result := K_CMCDGetDeviceObjByInd( Ind );
end; // function K_CMCDGetDeviceObjByName

//************************************************** K_CMCDGetDeviceObj ***
// Get Capture Devices Object by Device Profile
//
//     Parameters
// APDevProfile - pointer to device profile record
// Result - Returns selected object or nil
//
function K_CMCDGetDeviceObj( APDevProfile: TK_PCMDeviceProfile ) : TK_CMCDServObj;
begin
  Result := K_CMCDGetDeviceObjByName( APDevProfile.CMDPGroupName );
end; // procedure K_CMCDGetDeviceObj

//************************************************** K_CMCDGetRegCaptions3D ***
// Get Registered Capture Device Objects Captions Strings
//
//     Parameters
// ADevCaptions - Strings Object to Rebuild
//
procedure K_CMCDGetRegCaptions0( ADevCaptions : TStrings; AOrderArray : array of string );
var
  i : Integer;
  Ind : Integer;
  SL : TStringList;
begin
  ADevCaptions.Clear;
  if K_CMCaptDevsList = nil then Exit;

// Sort Device Objects if needed
  if not K_CMCaptDevsList.Sorted then
    K_CMCaptDevsList.Sort();

// Create Device List
  SL := TStringList.Create;
  for i := 0 to K_CMCaptDevsList.Count - 1 do
  begin
    with TK_CMCDServObj(K_CMCaptDevsList.Objects[i]) do
      SL.AddObject( CDSCaption, TObject(i) );
  end;

// Build ordered List
  for i := Low(AOrderArray) to High(AOrderArray) do
  begin
    if K_CMCaptDevsList.Find( AOrderArray[i], Ind ) then
      ADevCaptions.AddObject( SL[Ind], SL.Objects[Ind] );
  end;

  SL.Free;
end; // procedure K_CMCDGetRegCaptions0

//************************************************** K_CMCDGetRegCaptions ***
// Get Registered Capture Device Objects Captions Strings
//
//     Parameters
// ADevCaptions - Strings Object to Rebuild
//
procedure K_CMCDGetRegCaptions( ADevCaptions : TStrings );
{
var
  i : Integer;
  Ind : Integer;
  SL : TStringList;
}
begin
  K_CMCDGetRegCaptions0( ADevCaptions, K_CMCaptDevsOrderArray );
{
  ADevCaptions.Clear;
  if K_CMCaptDevsList = nil then Exit;

// Sort Device Objects if needed
  if not K_CMCaptDevsList.Sorted then
    K_CMCaptDevsList.Sort();

// Create Device List
  SL := TStringList.Create;
  for i := 0 to K_CMCaptDevsList.Count - 1 do
  begin
    with TK_CMCDServObj(K_CMCaptDevsList.Objects[i]) do
      SL.AddObject( CDSCaption, TObject(i) );
  end;

// Build ordered List
  for i := Low(K_CMCaptDevsOrderArray) to High(K_CMCaptDevsOrderArray) do
  begin
    if K_CMCaptDevsList.Find( K_CMCaptDevsOrderArray[i], Ind ) then
      ADevCaptions.AddObject( SL[Ind], SL.Objects[Ind] );
  end;

  SL.Free;
}
end; // procedure K_CMCDGetRegCaptions

//************************************************** K_CMCDGetRegCaptions3D ***
// Get Registered Capture Device Objects Captions Strings
//
//     Parameters
// ADevCaptions - Strings Object to Rebuild
//
procedure K_CMCDGetRegCaptions3D( ADevCaptions : TStrings );
{
var
  i : Integer;
  Ind : Integer;
  SL : TStringList;
}
begin
  K_CMCDGetRegCaptions0( ADevCaptions, K_CMCaptDevsOrderArray3D );
{
  ADevCaptions.Clear;
  if K_CMCaptDevsList = nil then Exit;

// Sort Device Objects if needed
  if not K_CMCaptDevsList.Sorted then
    K_CMCaptDevsList.Sort();

// Create Device List
  SL := TStringList.Create;
  for i := 0 to K_CMCaptDevsList.Count - 1 do
  begin
    with TK_CMCDServObj(K_CMCaptDevsList.Objects[i]) do
      SL.AddObject( CDSCaption, TObject(i) );
  end;

// Build ordered List
  for i := Low(K_CMCaptDevsOrderArray3D) to High(K_CMCaptDevsOrderArray3D) do
  begin
    if K_CMCaptDevsList.Find( K_CMCaptDevsOrderArray[i], Ind ) then
      ADevCaptions.AddObject( SL[Ind], SL.Objects[Ind] );
  end;

  SL.Free;
}
end; // procedure K_CMCDGetRegCaptions3D

//************************************************** K_CMCDRenameRegistered ***
// Change Registered Capture Device Captions by given rename list
//
//     Parameters
// ARenameCaptsList - Strings with rename list of <OldName>=<NewName>
//
procedure K_CMCDRenameRegistered( ARenameCaptsList : TStrings );
var
  i : Integer;
  Ind : Integer;
  SL : TStringList;
begin
  if(K_CMCaptDevsList = nil) or K_CMCaptDevsRenameFlag or
    (ARenameCaptsList = nil) or (ARenameCaptsList.Count = 0) then Exit; // Precaution

  // Create Device Ordered List
  SL := TStringList.Create;
  K_CMCDGetRegCaptions(SL);
  SL.Sort();

  // Change Captions Loop
  for i := 0 to ARenameCaptsList.Count - 1 do
  begin
    if not SL.Find( ARenameCaptsList.Names[i], Ind ) then Continue;
    with TK_CMCDServObj(K_CMCaptDevsList.Objects[Integer(SL.Objects[Ind])]) do
      CDSCaption := ARenameCaptsList.ValueFromIndex[i];
  end;

  // Create 3D Device Ordered List
  SL.Sorted := FALSE;
  K_CMCDGetRegCaptions3D(SL);
  SL.Sort();

  // Change 3D Captions Loop
  for i := 0 to ARenameCaptsList.Count - 1 do
  begin
    if not SL.Find( ARenameCaptsList.Names[i], Ind ) then Continue;
    with TK_CMCDServObj(K_CMCaptDevsList.Objects[Integer(SL.Objects[Ind])]) do
      CDSCaption := ARenameCaptsList.ValueFromIndex[i];
  end;

  SL.Free;
  K_CMCaptDevsRenameFlag := TRUE;

end; // procedure K_CMCDRenameRegistered

//******************************************************* N_CMECDConvProfile ***
// Convert old Capture Device Profile to new
//
//     Parameters
// APDevProfile - pointer to device profile record
//
function N_CMECDConvProfile( APDevProfile: TK_PCMDeviceProfile ) : Boolean;
begin
  Result := FALSE;
end; // function N_CMECDConvProfile


end.

