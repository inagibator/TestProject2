unit K_CMSLLL;
//CMS GUI multilingual support - Base Interface Texts File generator

interface
uses
K_Clib, N_Lib2;

procedure K_PrepAllUITextFragms( var AMTF : TN_MemTextFragms );
function K_PrepUITextsFiles( const ANewLLLFName : string;
                             const APrevLLLFName : string;
                             const AModLLLFName : string;
                             const ADelLLLFName : string ) : Integer;

implementation
uses Classes, Dialogs, SysUtils,
  K_CLib0, K_UDT2,
// Units with GUI Texts
  N_CMResF,
  K_CML1F,
  K_CML3F,
  K_FEText,
  K_FPathNameFr,
  K_FCMPrint1,
  N_IconSelF,
  K_FCMDeviceSetup,
  K_FCMUndoRedo,
  K_FCMCaptButDelay,
  K_FCMSDrawAttrs,
  K_FSFCombo,
  K_FCMSTextAttrs,
  K_FCMSEmbAttrs,
  K_FCMSIsodensity,
  K_FCMSRotateByAngle,
  K_FCMPrefEdit,
  N_BrigHist2F,
  K_FCMECacheProc,
  K_FCMSBriCoGam1,
  K_FCMSFPathChange,
  K_FCMSFilesHandlingE,
  K_FCMRegister,
  K_FCMSlideIcon,
  K_FCMProfileDevice,
  K_FCMProfileSetting,
  K_FCMAltShiftMEnter,
  K_FCMSCalibrate,
  K_FCMSCalibrate1,
  K_FCMImport,
  K_FCMSlideIcons,
  K_FFontAttrs,
  N_CMFPedalSF,
  K_FCMRegCode,
  N_CMVideoProfileF,
  K_FCMDeviceSetupEnter,
  K_FCMImportReverse,
  K_FCMImportPPL,
  N_CMAboutF,
  K_FCMSelectLocation,
  K_FCMSFilesHandling,
  K_FCMEFSyncProc,
  K_FCMImportReverseEnter,
  K_FCMGAdmSettings,
  K_FCMGAdmEnter,
  K_FCMEFSyncInfo,
  K_FCMReportShow,
  K_FCMReports1,
  K_FCMDelObjsHandling,
  N_CMOther2F,
  K_FCMIntegrityCheck,
  K_FCMSysInfo,
  K_FCMDBRecovery,
  K_FCMResampleLarge,
  K_FCMSAModeSetup,
  K_FCMSupport,
  K_FCMSZoomMode,
  K_FCMSFlashlightAttrs,
  K_FCMSFlashlightModeAttrs,
  K_FCMSetSlidesAttrs2,
  K_FCMChangeSlidesAttrsN2,
  K_FCMProfileOther1,
  N_CMCaptDev5F,
  N_CMCaptDev3SF,
  N_CMCaptDev4F,
  N_CMCaptDev6aF,
  K_FrCMTeethChart1,
  K_FCMImportChngAttrs,
  K_FCMSUDefFilters1,
  K_FCMMain5F,
  K_FCMSASetProvData,
  K_FCMSASelectLoc,
  K_FCMSASelectPat,
  K_FCMSASetPatData,
  K_FCMSysSetup,
//  N_CMCaptDev7F,
  N_CMCaptDev7SF,
  N_CMCaptDev7aF,
  K_FCMProfileTwain,
  K_FCMRemoteClientSetup,
  K_FCMExportSlides,
  K_FCMExportPPL,
  K_FCMSASelectProv,
  N_CMVideo2F,
  N_CML1F,
  N_CML2F,
  K_FCMImgFilterProcAttrs,
  K_FCMImgProfileProcAttrs,
  K_FSFList,
  K_FCMSharpSmooth,
  K_FCMLinkCLFSetup,
  K_FCMStudyTemplateSelect,
  K_FCMSelectMaxPictSize,
  K_FCMFixStudyDataWarn,
  K_FCMDeviceLimitWarn,
//Excluded
  K_FrRAEdit
;

type TK_TComponentClass = class of TComponent;
//type TK_TComponentClassArray = array of TK_TComponentClass; // dynamic Array of TComponents Class
var
{$IF CompilerVersion >= 26.0} // !!! this code is added 2021-02-02 because N_CMCaptDev5F is not compiled in D7
K_FCompIncludeTypes : array [0..80] of TK_TComponentClass = (
{$ELSE}
K_FCompIncludeTypes : array [0..79] of TK_TComponentClass = (
{$IFEND CompilerVersion < 26.0}
//  Not Included in current version
//      Entreprise
//  TK_FormCMEFSyncProc,
//  TK_FormCMEFSyncInfo,
//  TK_FormCMSFilesHandlingE,
//  TK_FormCMSelectLoc,
//      Import after convertion
//  TK_FormCMImport,
//  TK_FormCMImportReverseEnter,
//  TK_FormCMImportReverse,
//  TK_FormCMImportChngAttrs,
//
//       Support Procedures Should be changed later
//  TK_FormCMIntegrityCheck,
//  TK_FormCMDBRecovery,
//  TK_FormCMResampleLarge
//
  TN_CMResForm,
  TK_CML1Form,
  TK_CML3Form,
  TK_FormCMMain5,
//     Global Admin
  TK_FormCMGAdmSettings,
  TK_FormCMGAdmEnter,
//     System Setup
  TK_FormCMAltShiftMEnter,
  TK_FormCMSysSetup,
//     Standalone System
  TK_FormCMSAModeSetup,
  TK_FormCMImportPPL,
  TK_FormCMExportPPL,
//     Files handling
  TK_FormCMSFPathChange,
  TK_FormCMSFilesHandling,
  TK_FormCMFixStudyDataWarn,
//
  TK_FormCMDelObjsHandling,
//     Standalone System User
  TK_FormCMSASelectProvider,
  TK_FormCMSASetProviderData,
  TK_FormCMSASelectPatient,
  TK_FormCMSASetPatientData,
  TK_FormCMSASelectLocation,
//     Registration
  TK_FormCMRegister,
  TK_FormCMRegCode,
//
  TK_FormCMSysInfo,
  TK_FormCMLinkCLFSetup,
  TK_FormCMSIsodensity,
  TK_FormCMSEmboss,
  TK_FPathNameFrame,
  TK_FormCMPrint1,
  TK_FormCMUndoRedo,
  TK_FormCMSRotateByAngle,
  TK_FormCMSDrawAttrs,
  TK_FormCMSTextAttrs,
  TK_FormTextEdit,
  TK_FormPrefEdit,
  TN_BrigHist2Form,
  TK_FormCMECacheProc,
  TK_FormCMSBriCoGam1,
//     Devices and Profiles Setup ...
  TK_FormCMDeviceSetupEnter,
  TK_FormDeviceSetup,
  TK_FormCMProfileDevice,
  TK_FormCMProfileSetting,
  TN_CMFPedalSetupForm,
  TK_FormCMProfileTwain,
  TK_FormCMProfileOther1,
  TK_FormCMCaptButDelay,
  TN_IconSelectionForm,
//
  TK_FormCMSlideIcon,
  TK_FormCMSlideIcons,
  TK_FormFontAttrs,
  TN_CMVideoProfileForm,
  TN_CMAboutForm,
  TK_FormCMReportShow,
  TK_FormCMReports1,
  TN_CMOther2Form,
  TK_FormCMSZoomMode,
  TK_FormCMSFlashlightAttrs,
  TK_FormCMSFlashlightModeAttrs,
  TK_FormCMSetSlidesAttrs2,
  TK_FormCMChangeSlidesAttrsN2,
{$IF CompilerVersion >= 26.0} // !!! this code is added 2021-02-02 because N_CMCaptDev5F is not compiled in D7
  TN_CMCaptDev5Form,
{$IFEND CompilerVersion >= 26.0}
  TN_CMCaptDev3Form,
  TN_CMCaptDev4Form,
  TN_CMCaptDev6aForm,
  TK_FrameCMTeethChart1,
  TK_FormCMSUDefFilters1,
  TK_FormCMSCalibrate,
  TK_FormCMSCalibrate1,
  TN_CMCaptDev7Form,
  TN_CMCaptDev7aForm,
  TK_FormCMRemoteClientSetup,
  TK_FormCMExportSlides,
  TN_CMVideo2Form,
  TN_CML1Form,
  TN_CML2Form,
  TK_FormCMImgFilterProcAttrs,
  TK_FormCMImgProfileProcAttrs,
  TK_FormSelectFromList,
  TK_FormCMSharpSmooth,
  TK_FormCMStudyTemplateSelect,
  TK_FormCMSelectMaxPictSize,
  TK_FormCMProfileLimitWarn
);

K_FCompExludeTypes : array [0..0] of TK_TComponentClass = (
nil
//  TK_FrameRAEdit
);

//********************************************* K_PrepAllUITextFragms ***
// Prepare All User Interface Text Fragments
//
//     Parameters
// AMTF - TextFragms to place Interface Texts
//
// If on input AMTF is nil then new TextFragms object will be created
//
procedure K_PrepAllUITextFragms( var AMTF : TN_MemTextFragms );
var
  i : Integer;
  WComp : TComponent;
  FreeExcludeCompTypeNames : Boolean;
begin

// Create New CMS Base Lang Strings
  if AMTF = nil then
    AMTF := TN_MemTextFragms.Create;

  WComp :=  CreateMessageDialog('', mtWarning, [mbOk, mbCancel, mbAbort, mbRetry, mbIgnore,mbAll, mbNoToAll, mbYesToAll,mbYes, mbNo]);
  K_GetFFCompTexts( AMTF, WComp );
  WComp.Free;

  FreeExcludeCompTypeNames := K_FFExcludeCompTypeNames = nil;
  if K_FFExcludeCompTypeNames = nil then
  begin
    K_FFExcludeCompTypeNames := TStringList.Create();
    for i := 0 to High(K_FCompExludeTypes) do
      if K_FCompExludeTypes[i] <> nil then
        K_FFExcludeCompTypeNames.Add( K_FCompExludeTypes[i].ClassName );
    K_FFExcludeCompTypeNames.Sort();
  end;

  for i := 0 to High(K_FCompIncludeTypes) do
  begin
    try
      WComp :=  K_FCompIncludeTypes[i].Create( nil );
      K_GetFFCompTexts( AMTF, WComp );
      WComp.Free;
    except
    end;
  end;

  if FreeExcludeCompTypeNames then
    FreeAndNil( K_FFExcludeCompTypeNames );

end; // procedure K_PrepAllUITextFragms

//******************************************************* K_PrepUITextsFiles ***
// Prepare All User Interface Text Files
//
//     Parameters
// ANewLLLFName  - file name for current english UI texts to save
// APrevLLLFName - file name with previouse english UI texts to compare
// AModLLLFName  - file name for modified or new english UI texts only to translate to other languages
// ADelLLLFName  - file name for deleted english UI texts only to remove from UI texts in other languages
// Result - Returns resulting code
//#F
//   0 - resulting file with current english UI texts was created
//   1 - previouse file with english UI texts was loaded and previuose UI texts are equal to current
//   3 - file with new and modified UI texts only was created (UI texts to delete are not found)
//   5 - file with UI texts to delete only was created (new and modified UI texts are not found)
//   7 - files new and modified UI texts only and file with UI texts to delete only were created
//#/F
//
// New Interface texts file, file with added and updated texts and file with removed texts will be created
//
function K_PrepUITextsFiles( const ANewLLLFName : string;
                             const APrevLLLFName : string;
                             const AModLLLFName : string;
                             const ADelLLLFName : string ) : Integer;
var
  ARLData : TN_MemTextFragms;
  ASLData : TN_MemTextFragms;
  AULData : TN_MemTextFragms;
begin
// Create New CMS Base Lang File
  Result := 0;
  ARLData := TN_MemTextFragms.Create;
  K_PrepAllUITextFragms( ARLData );
  K_PrepLangTexts( ARLData );

  ARLData.SaveToVFile( ANewLLLFName, K_DFCreatePlain );

  ASLData := TN_MemTextFragms.CreateFromVFile( APrevLLLFName );
  if ASLData.MTFragmsList.Count > 0 then
  Result := 1;

  AULData := nil;
  if Result = 1 then
  begin
  // Create Base Lang File with Texts to Updates in translated texts
    AULData := TN_MemTextFragms.Create;

    K_GetLangTextsCompareStrings( ASLData, ARLData, AULData, FALSE );
    AULData.SaveToVFile( AModLLLFName, K_DFCreatePlain );
    if AULData.MTFragmsList.Count > 0 then
      Result := Result + 2;

  // Create Base Lang File with Texts to Remove from translated texts
    AULData.Clear;
    K_GetLangTextsCompareStrings( ARLData, ASLData, AULData, TRUE );
    AULData.SaveToVFile( ADelLLLFName, K_DFCreatePlain );
    if AULData.MTFragmsList.Count > 0 then
      Result := Result + 4;
  end;

  ARLData.Free;
  ASLData.Free;
  AULData.Free;

end; // procedure K_PrepUITextsFiles



end.
