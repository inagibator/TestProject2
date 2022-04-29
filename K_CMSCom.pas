unit K_CMSCom;
// CMS COM server API
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, StdVcl, Forms, ExtCtrls,
  K_SBuf0, K_CM0, K_CMSCom_TLB, K_Script1,
  N_Gra2;

type

  TD4WCMServer = class(TTypedComObject, ID4WCMServer)
//  TD4WCMServer = class(TAutoObject, ID4WCMServer)
    destructor Destroy(); override;
    procedure  Initialize; override;
  private
    CurCodePage : Integer;
    ProtStr : string;
    UseFilteringInfoFlag : Boolean;
    FilteringInfo : TK_CMSlideFilterAttrs;
    SBuf : TN_SerialBuf0;
    function SetInfo( AText : string; AUDTable : TK_UDRArray ) : HResult;
    function DumpTabInfo( const ATabInfo: string; ATabName : string ): Boolean;
    function IsAppReady( ): Boolean;
//    function CheckFormModal( AForm : TForm ) : Boolean;
    function WCheckReady( ASkipProviderCheck : Boolean = FALSE ): HResult;
    function WCheckFilesPath( const AFilesPath : string ): HResult;
    function WGetSlideByID( ASlideID: Integer; AObjType : Integer;
                                     out ASlide : TN_UDCMBSlide;
                                     out APSlide : TN_PCMSlide ): HResult;
    function WPrepSlideDIBFile( const AFilePath : string;
              ASlide : TN_UDCMBSlide;
              var AMaxWidth, AMaxHeight : Integer;
              AFileFormat : Integer;
              AViewCont : Integer;
              AViewConv : Integer ) : HResult;
  protected
//  public for debug
    function SetCurContext( APatientID, AProviderID,
                            ALocationID: Integer ): HResult; stdcall;
    function SetLocationsInfo( const ALocationsInfo: WideString ): HResult; stdcall;
    function SetPatientsInfo ( const APatientsInfo: WideString ): HResult; stdcall;
    function SetProvidersInfo( const AProvidersInfo: WideString ): HResult; stdcall;
    function SetWindowState(AWinState: Integer): HResult; stdcall;
    function SetCurContextEx( APatientID, AProviderID, ALocationID,
                              ATeethRightSet, ATeethLeftSet: Integer ): HResult; stdcall;
    function GetPatientMediaCounter( APatID: Integer;
                              out AMediaCounter: OleVariant ): HResult; stdcall;
    function GetWindowHandle( out AWinHandle: OleVariant ): HResult; stdcall;
    function SetIniInfo( const AIniInfo: WideString ): HResult; stdcall;
    function GetServerInfo( AServerCode: Integer;
               out AServerInfo: OleVariant ): HResult; stdcall;
    function ExecUICommand( AComCode: Integer;
               const AComInfo: WideString ): HResult; stdcall;
    function SetCodePage(ACodePageID: Integer): HResult; stdcall;
    function StartSession(AStartCode: Integer): HResult; stdcall;

    /////////////////////////////// Get Slides Atributes, Thumbnails and Raster files
    function GetSlidesAttrs( APatID, AMode: Integer; const AFields: WideString;
                             out ARData: OleVariant ): HResult; stdcall;
    function GetSlidesThumbnails( const AMObjIDs: WideString; AMode: Integer;
                                  out ASThumbs: OleVariant ): HResult; stdcall;
    function GetSlideImageFile( ASlideID: Integer; var AMaxWidth, AMaxHeight: OleVariant;
                                AFileFormat, AViewCont: Integer;
                                const AFileName: WideString): HResult; stdcall;

    /////////////////////////////// High Resolution Preview
    function HPSetCurContext( APatientID, AProviderID,
                              ALocationID: Integer ): HResult; stdcall;
    function HPSetVisibleIcons( const AMObjIDs: WideString;
      AMode: Integer ): HResult; stdcall;
    function HPViewMediaObject( const AViewID: WideString ): HResult; stdcall;
    /////////////////////////////// WEB API
    function WGetUserAttrs( const ALogin, APassword: WideString;
                            out AUserData: OleVariant ): HResult; stdcall;
    function WSetCurrentUser( AUserID: Integer ): HResult; stdcall;
    function WGetMediaTypes( out AData: OleVariant): HResult; stdcall;
    function WSetPatientFilter( const ACardNum, ASurname, AFirstName: WideString;
                                AOrder, ASelCode: Integer;
                                out APatCount: OleVariant ): HResult; stdcall;
    function WGetPatientsData( AStartNum, ACount: Integer;
                               out AData: OleVariant ): HResult; stdcall;
    function WGetPatObjAttrs( APatientID, ASelCode: Integer;
                              out AData: OleVariant ): HResult; stdcall;
    function WGetSlidesThumbFiles( APatientID: Integer; const ASlideIDs,
                                   AThumbPath: WideString ): HResult; stdcall;
    function WSetCurrentPatient( APatientID: Integer ): HResult; stdcall;
    function WGetSlideImageFile( ASlideID: Integer; var AMaxWidth,
              AMaxHeight: OleVariant; AFileFormat, AViewCont, AViewConv: Integer;
             const AFilePath: WideString ): HResult; stdcall;
    function WGetSlideStudyFile( ASlideID: Integer; var AMaxWidth,
                     AMaxHeight: OleVariant; AFileFormat: Integer;
                     const AFilePath: WideString; out AItemsRefs: OleVariant ): HResult; stdcall;
    function WGetSlideVideoFile( ASlideID: Integer;
                                 const AFilePath: WideString ): HResult; stdcall;
  end;

///////////////
// SIR #27353
type
  TTypedComObjectFactoryCMSCloud = class(TTypedComObjectFactory)
  protected
    function GetProgID: string; override;
  end;
// SIR #27353
///////////////

implementation

uses ComServ, SysUtils, Controls, Variants,
  K_UDT1, K_UDC, K_CLib0, K_CLib, K_Arch, K_VFunc, K_CM1, K_CMWEBBase, K_RImage,
  N_Types, N_Lib0, N_Lib1, N_CMMain5F, N_CM1, N_CMResF, N_Comp1;

const
  CMS_Object_Wrong_ID             : LongWord = $A0000201; // Media Object wrong ID
  CMS_Object_HasNo_Image          : LongWord = $A0000202; // Media Object has no Image representation
  CMS_Create_Image_OutOffMemory   : LongWord = $A0000203; // Not enough memory to create Image
  CMS_Create_Image_Internal_Error : LongWord = $A0000204; // Image Creation Error

//**************************************************** TD4WCMServer.SetInfo ***
// Set CMS text info to ID Table
//
//     Parameters
// AText  - info text
// AUDTable - IDB info table
//
function TD4WCMServer.SetInfo( AText: string; AUDTable: TK_UDRArray ) : HResult;
begin
  Result := E_INVALIDARG;
  if K_CMSSetUDTableInfo( AText, AUDTable ) then
    Result := S_OK;
end; //*** end of TD4WCMServer.SetInfo

//************************************************* TD4WCMServer.IsAppReady ***
// Check if application is ready to recieve data
//
//     Parameters
// Result - Returns TRUE if server is ready to recieve Data
//
function TD4WCMServer.IsAppReady(): Boolean;
begin
  Result := (K_CMEDAccess <> nil) and K_CMEDAccess.AccessReady;
end; //*** end of TD4WCMServer.IsAppReady

//************************************************ TD4WCMServer.WCheckReady ***
// Check if CMS WEB is Ready
//
function TD4WCMServer.WCheckReady( ASkipProviderCheck : Boolean = FALSE ): HResult;
begin
  Result := S_OK;
  if K_CMEDDBVersion < 31 then
  begin
    N_Dump1Str( 'WEB >> CMS DB Version = ' + IntToStr(K_CMEDDBVersion) );
    LongWord(Result) := WCMS_Init_Error;
  end
  else
  if limdCMWEB in K_CMSLiRegModDisable then
  begin
    N_Dump1Str( 'WEB >> Support is locked by license' );
    LongWord(Result) := WCMS_Init_Error;
  end
  else
  if K_CMSAppStartContext.CMASState <> K_cmasOK then
  begin // may be not needed
    N_Dump1Str( 'WEB >> CMS Initialization Error' );
    LongWord(Result) := WCMS_Init_Error;
  end
  else
  if not ASkipProviderCheck and (K_CMWEBCOMProviderID = 0) then
  begin
    N_Dump1Str( 'WEB >> User is absent' );
    LongWord(Result) := WCMS_User_Absent;
  end
  else
  if (K_CMSAppStartContext.CMASMode = K_cmamWait) or
     IsAppReady() then Exit;
  LongWord(Result) := 2;
  N_Dump1Str( 'WEB >> CMS is not Ready' );
end; // function TD4WCMServer.WCheckReady


//******************************************** TD4WCMServer.WCheckFilesPath ***
// Check given files path
//
function TD4WCMServer.WCheckFilesPath( const AFilesPath : string ): HResult;
begin
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  if DirectoryExists( AFilesPath ) then Exit;
  N_Dump1Str( 'WEB >> Invalid Path' );
  LongWord(Result) := WCMS_FilesPath_Invalid;
end; // function TD4WCMServer.WCheckFilesPath

//********************************************** TD4WCMServer.WGetSlideByID ***
// Get Slide given by ID
//
function TD4WCMServer.WGetSlideByID( ASlideID: Integer; AObjType : Integer;
                                     out ASlide : TN_UDCMBSlide;
                                     out APSlide : TN_PCMSlide ): HResult;
var
  i : Integer;
  SID : string;
  FObjType : Integer;
  PSlide : TN_PCMSlide;
begin
  ASlide := nil;
  SID := IntToStr(ASlideID);
  with K_CMEDAccess do
    for i := 0 to CurSlidesList.Count -1 do
    begin
      if TN_UDCMBSlide(CurSlidesList[i]).ObjName <> SID then Continue;
      ASlide := TN_UDCMBSlide(CurSlidesList[i]);
      Break;
    end;

  LongWord(Result) := WCMS_Patient_Absent;
  if ASlide = nil then
  begin
    N_Dump1Str( 'WEB >> Slide is absent' );
    Exit;
  end;

  PSlide := ASlide.P();
  FObjType := 0;
  if ASlide is TN_UDCMStudy then
    FObjType := 2
  else
  if cmsfIsMediaObj in PSlide.CMSDB.SFlags then
    FObjType := 1;

  LongWord(Result) := WCMS_Wrong_Object_Type;
  if FObjType <> AObjType then
  begin
    N_Dump1Str( format( 'WEB >> Given Slide Type %d <> %d', [FObjType,AObjType] ) );
    Exit;
  end;

  APSlide := PSlide;
  Result := S_OK;
end; // function TD4WCMServer.WGetSlideByID

//****************************************** TD4WCMServer.WPrepSlideDIBFile ***
// Prepare Slide DIB and File
//
function TD4WCMServer.WPrepSlideDIBFile( const AFilePath : string;
              ASlide : TN_UDCMBSlide;
              var AMaxWidth, AMaxHeight : Integer;
              AFileFormat : Integer;
              AViewCont : Integer;
              AViewConv : Integer ) : HResult;
var
  FName: string;
  ExportFlags : TK_CMBSlideExportToDIBFlags;
  FFileExt : string;
  FileFormat   : Integer;
{
  RIEncodingInfo : TK_RIFileEncInfo;
  ExportFlags : TK_CMBSlideExportToDIBFlags;
  FFileExt : string;
  DIBObj : TN_DIBObj;
}
begin

  ExportFlags := [];
  case TK_WCMSMediaObjViewCont(AViewCont) of
    wcmcSkipAnnot: ExportFlags := [K_bsedSkipAnnotations];
    wcmcOriginal : ExportFlags := [K_bsedExportOriginal];
  end;

  FileFormat := 0;
  case TK_WCMSMediaObjFileFormat(AFileFormat) of
    wcmfJPG : // JPEG
    begin
      FFileExt := 'jpg';
      FileFormat := Ord(rietJPG);
    end;
    wcmfPNG:	// PNG
    begin
      FFileExt := 'png';
      FileFormat := Ord(rietPNG);
    end;
    wcmfTIFF:	// TIF
    begin
      FFileExt := 'tif';
      FileFormat := Ord(rietTIF);
    end;
    wcmfBMP:  // BMP
    begin
      FFileExt := 'bmp';
      FileFormat := Ord(rietBMP);
    end;
  end;
  FName := AFilePath + 'F' + ASlide.ObjName + '.' + FFileExt;

  Result := S_OK;

  if 0 <> K_CMPrepSlideDIBFile( FName, ASlide,
                    AMaxWidth, AMaxHeight, FileFormat, ExportFlags ) then
    Result := S_FALSE;
{
  K_RIObj.RIClearFileEncInfo( @RIEncodingInfo );
  RIEncodingInfo.RIFileEncType := rietNotDef;

  case TK_WCMSMediaObjFileFormat(AFileFormat) of
    wcmfJPG : 	// JPEG
    begin
      FFileExt := 'jpg';
      RIEncodingInfo.RIFileEncType := rietJPG;
    end;
    wcmfPNG:	// PNG
    begin
      FFileExt := 'png';
      RIEncodingInfo.RIFileEncType := rietPNG;
    end;
    wcmfTIFF:	// TIF
    begin
      FFileExt := 'tif';
      RIEncodingInfo.RIFileEncType := rietTIF;
    end;
    wcmfBMP:	  // BMP
    begin
      FFileExt := 'bmp';
      RIEncodingInfo.RIFileEncType := rietBMP;
    end;
  end;

// Check Memory for Image Loading if needed
//!!! check here because MapImage and CurImage are created in EDACheckSlideMedia in ExtDB Mode

  if not K_CMSCheckMemForSlide1( TN_UDCMSlide(ASlide) ) then
  begin
    N_Dump1Str( 'WEB >> CheckMemForSlide >> Out of memory' );
    Result := S_FALSE;
    Exit;
  end;

  if (K_CMEDAccess.EDACheckSlideMedia( TN_UDCMSlide(ASlide) ) = K_edFails) then
  begin
    N_Dump1Str( 'WEB >> CheckSlideFile >> Error' );
    Result := S_FALSE;
    Exit;
  end;

  ExportFlags := [];
  case TK_WCMSMediaObjViewCont(AViewCont) of
    wcmcSkipAnnot: ExportFlags := [K_bsedSkipAnnotations];
    wcmcOriginal : ExportFlags := [K_bsedExportOriginal];
  end;

  DIBObj := ASlide.ExportToDIB( ExportFlags, AMaxWidth, AMaxHeight );
  if DIBObj = nil then
  begin
    Result := S_FALSE;
    N_Dump1Str( 'WEB >> ExportToDIB >> Out of memory' );
    Exit;
  end;

  AMaxWidth  := DIBObj.DIBSize.X;
  AMaxHeight := DIBObj.DIBSize.Y;

  FName := AFilePath + 'F' + ASlide.ObjName + '.' + FFileExt;
  if K_RIObj.RISaveDIBToFile( DIBObj, FName, @RIEncodingInfo ) <> rirOK then
  begin
    N_Dump1Str( format( 'WEB >> RISaveDIBToFile "%s" fails K_RIObj=%s', [FName, K_RIObj.ClassName] ) );
    Result := S_FALSE;
  end;

  DIBObj.Free;
}
end; // function WPrepSlideDIBFile

{
//************************************************* TD4WCMServer.CheckFormModal ***
// Check if given Form is opened in Modal Mode
//
//     Parameters
// AForm  - given Form
// Result - Returns TRUE if given Form is opened in Modal Mode
//
function TD4WCMServer.CheckFormModal( AForm : TForm ): Boolean;
begin
  Result := (AForm <> nil) and (fsModal in AForm.FormState);
end; //*** end of TD4WCMServer.CheckFormModal
{}

//************************************************ TD4WCMServer.DumpTabInfo ***
// Dump Given Table Info
//
//     Parameters
// ATabInfo - Table new Content (string)
// ATabName - name of Table
// Result - Returns TRUE if server is ready to recieve Table Data
//
function TD4WCMServer.DumpTabInfo( const ATabInfo: string; ATabName : string ): Boolean;
var
  SL : TStringList;
begin
//  Result := IsAppReady( ) and not K_CMD4WWaitApplyDataFlag;
  Result := IsAppReady( ) and (K_CMD4WWaitApplyDataCount = 0);

  ProtStr := 'D4W >> ' + ATabName + ' >> L=' + IntToStr( Length(ATabInfo) );
  if Result then
    ProtStr := ProtStr + ' Done'
  else
    ProtStr := ProtStr + ' Save Request';

  K_CMSPCAddCOMServer ( ProtStr );
//  K_CMSPCAddCOMServer ( Copy( ATabInfo, 1, 100 ) );
//  K_CMSPCAddCOMServer ( ATabInfo );
  SL := TStringList.Create;
  SL.Text := ATabInfo;
  N_Dump1Strings ( SL, 3 );
  SL.Free;
end; //*** end of TD4WCMServer.DumpTabInfo

//********************************************** TD4WCMServer.SetCurContext ***
// Set CMS current View/Edit context
//
//     Parameters
// APatientID  - current Patient new ID
// AProviderID - current Provider new ID
// ALocationID - current Location new ID
// Result - Returns function COM resulting code.
//
// If any given ID (Patient, Provider, Location) is equal to -1 then previous context value should be used.
// Call to SetCurContext(-1,-1,-1) does not change CMS View/Edit context.
//
function TD4WCMServer.SetCurContext( APatientID, AProviderID,
                                     ALocationID: Integer ): HResult;
var
  PSlideFilterAttrs : TK_PCMSlideFilterAttrs;
  AppReady : Boolean;
  WStr : string;
//  CheckECache : Boolean;
  SkipChangeContextMode : Boolean;
  StoreNewContext : Boolean;

const
  IgnoreWarning = 'Ignore because of [CMS_UserMain].AutoPatChangeOff mode';

begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetCurContext' );
    Result := S_FALSE;
    Exit;
  end;

//K_InfoWatch.AddInfoLine( 'TD4WCMServer.SetCurContext' );
  ProtStr := ' Pt=' + IntToStr(APatientID)  +
             ' Pr=' + IntToStr(AProviderID) +
             ' Lc=' + IntToStr(ALocationID) + ' >> ';
  N_Dump1Str   ( 'D4W >> Start SetCurContext' + ProtStr );

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  Result := S_OK;
  K_CMD4WCNewPatientID := -1; // clear by Client
  K_CMD4WSkipCMSAwakeFlag := FALSE; // Clear Skip CMS Awake Flag


//  K_CMD4WSetCurDataContext := TRUE;
  K_CMSAppStartContext.CMASMode := K_cmamCOMVEUI;

//  if IsAppReady( ) and not K_CMD4WWaitApplyDataFlag then begin


  if K_CMSAppStartContext.CMAInitNotComplete then
  begin
    N_Dump1Str( '***** Do init on VEUI after Files Access mode' );
    N_CM_MainForm.FormShow( Application );
  end;

  if K_CMEDAccess <> nil then
  begin
    if APatientID = -1 then
      APatientID  := K_CMEDAccess.CurPatID;

    if AProviderID = -1 then
      AProviderID := K_CMEDAccess.CurProvID;

    if ALocationID = -1 then
      ALocationID := K_CMEDAccess.CurLocID;
  end
  else
  begin
  // Needed to prevent Errors if start with "-1" context values
    if APatientID = -1 then
      APatientID  := 0;

    if AProviderID = -1 then
      AProviderID := 0;

    if ALocationID = -1 then
      ALocationID := 0;
  end;

  AppReady := IsAppReady( );

  // Set Skip Change Context Mode
  SkipChangeContextMode := FALSE;
  if AppReady then
    SkipChangeContextMode := N_MemIniToBool( 'CMS_UserMain', 'AutoPatChangeOff', FALSE );

//  Needed for relaunching closed VEUI
  K_CMD4WCNewProviderID := AProviderID;
  K_CMD4WCNewLocationID := ALocationID;
  if AppReady and (K_CMD4WWaitApplyDataCount = 0) then
  begin
  // Server is ready to change context
    if not SkipChangeContextMode or
       (N_CM_MainForm.CMMCurFMainForm = nil) then
    begin
      WStr := K_CMD4WApplyNewContextInfo();
      if WStr <> '' then
        ProtStr := ProtStr + 'ApplyInfo:' + WStr + ' >> ';
    end;

    if N_CM_MainForm.CMMCurFMainForm = nil then
    begin
    // VEUI Form is closed - apply given context
      ProtStr := ProtStr + 'Main VEUI Form is closed, Context will be applied after VEUI relaunch';
      K_CMD4WCNewPatientID := APatientID;
      K_CMD4WUseFilteringInfoFlag := UseFilteringInfoFlag;
      if K_CMD4WUseFilteringInfoFlag then
        K_CMD4WSlideFilterAttrs := FilteringInfo;
      Result := 2;
      N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServLaunchVEUI, TRUE );
      K_CMEDAccess.AccessReady := FALSE;
    end
    else
    if not SkipChangeContextMode then
    begin
    // VEUI Form is opened - apply given context
      ProtStr := ProtStr + 'Done';
      if UseFilteringInfoFlag then
        PSlideFilterAttrs := @FilteringInfo
      else
        PSlideFilterAttrs := nil;

      K_CMSCLLContextFromEDAPPL( ALocationID, AProviderID, APatientID );
      try
        K_CMSetCurSessionContext1( APatientID, AProviderID, ALocationID,
                                               PSlideFilterAttrs );
      except
        on E: Exception do begin
          ProtStr := ProtStr + ' >> Error >> ' + E.Message;
        end;
      end;
    end // if not SkipChangeContextMode then
    else
      ProtStr := ProtStr + IgnoreWarning;
  end   // if AppReady and (K_CMD4WWaitApplyDataCount = 0) then
  else
  begin // if not AppReady or (K_CMD4WWaitApplyDataCount > 0) then
  // Server is not ready - store new context attributes to use it later if it is permitted
    StoreNewContext := TRUE;
    if not AppReady then
      ProtStr := ProtStr + 'Server is not ready, Context will be applied during Server initialization'
    else
    begin
      if not SkipChangeContextMode then
        ProtStr := ProtStr + 'Server is waiting for action finish'
      else
      begin
        ProtStr := ProtStr + IgnoreWarning;
        StoreNewContext := FALSE;
      end;
    end;

    if StoreNewContext then
    begin
      K_CMD4WCNewPatientID  := APatientID;
      K_CMD4WUseFilteringInfoFlag := UseFilteringInfoFlag;
      if K_CMD4WUseFilteringInfoFlag then
        K_CMD4WSlideFilterAttrs := FilteringInfo;
      Result := 2;
    end;
{
    if K_CMD4WNewPatMode > 0 then
    begin
    // reply Server is busy (in Modal dialog with previous Patient Slides)
      ProtStr := ProtStr + 'Server is busy - Context is not applied';
    end;
}
  end; // if not AppReady or (K_CMD4WWaitApplyDataCount > 0) then
  N_Dump1Str   ( 'D4W >> ' + ProtStr );
end; //*** end of TD4WCMServer.SetCurContext

//******************************************** TD4WCMServer.SetCurContextEx ***
// Set CMS current View/Edit context extended
//
//     Parameters
// APatientID  - current Patient new ID
// AProviderID - current Provider new ID
// ALocationID - current Location new ID
// ATeethRightSet - current filtering new Right side Teeth set
// ATeethLeftSet  - current filtering new Left side Teeth set
// Result - Returns function COM resulting code.
//
// If any given ID (Patient, Provider, Location) is equal to -1 then previous context value should be used.
//
function TD4WCMServer.SetCurContextEx( APatientID, AProviderID, ALocationID,
                                       ATeethRightSet, ATeethLeftSet: Integer ): HResult;
begin
  UseFilteringInfoFlag := TRUE;
  FilteringInfo.FATeethFlags := ATeethLeftSet;
  FilteringInfo.FATeethFlags := (FilteringInfo.FATeethFlags shl 32) or ATeethRightSet;
  FilteringInfo.FAMediaType := -2;
  Result := SetCurContext( APatientID, AProviderID, ALocationID );
  UseFilteringInfoFlag := FALSE;
end; //*** end of TD4WCMServer.SetCurContextEx

//******************************************* TD4WCMServer.SetLocationsInfo ***
// Set All registered in D4W Locations Info
//
//     Parameters
// ALocationsInfo - All Locations needed info
// Result - Returns function COM resulting code.
//
// Locations Info string is Tab delimited Table. Each Table Row contains single
// Location attributes. First Table Row contains Location attributes identifiers:
//#F
//    LocationID  LocationTitle
//#/F
//
function TD4WCMServer.SetLocationsInfo( const ALocationsInfo: WideString ): HResult;
var
  FInfo : string;
  AppReady : Boolean;
begin
//K_InfoWatch.AddInfoLine( 'SetLocationsInfo' );
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetLocationsInfo' );
    Result := S_FALSE;
    Exit;
  end;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  CurCodePage := N_NeededCodePage;
  AppReady := IsAppReady( );
  if not AppReady and (K_CMD4WCurCodePage <> 0) then
    N_NeededCodePage := K_CMD4WCurCodePage;
  FInfo := N_WideToString(ALocationsInfo);
  N_NeededCodePage := CurCodePage;

  if AppReady and (K_CMD4WWaitApplyDataCount = 0) then
  begin
    N_Dump2Str   ( 'D4W >> SetLocationsInfo' );
    Result := SetInfo( FInfo, K_CMEDAccess.LocationsInfo );
    if Result = S_OK then
      K_CMEDAccess.UpdatePPLFlagsSet := K_CMEDAccess.UpdatePPLFlagsSet + [K_uliLocations];
  end
  else
  begin
    K_CMD4WLocationsInfo := FInfo;
    Result := 2;
  end;
end; //*** end of TD4WCMServer.SetLocationsInfo

//******************************************** TD4WCMServer.SetPatientsInfo ***
// Set All registered in D4W Patients Info
//
//     Parameters
// APatientsInfo - All Patients needed info
// Result - Returns function COM resulting code.
//
// Patients Info string is Tab delimited Table. Each Table Row contains single
// Patient attributes. First Table Row contains Patient attributes identifiers:
//#F
//    PatientID PatientFirstName PatientSurname PatientGender PatientDOB
//#/F
//
function TD4WCMServer.SetPatientsInfo( const APatientsInfo: WideString ): HResult;
var
  FInfo : string;
  AppReady : Boolean;
begin
//K_InfoWatch.AddInfoLine( 'SetPatientsInfo' );
  if K_CMD4WAppFinState then begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetPatientsInfo' );
    Result := S_FALSE;
    Exit;
  end;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  CurCodePage := N_NeededCodePage;
  AppReady := IsAppReady( );
  if not AppReady and (K_CMD4WCurCodePage <> 0) then
    N_NeededCodePage := K_CMD4WCurCodePage;
  FInfo := N_WideToString(APatientsInfo);
  N_NeededCodePage := CurCodePage;

  if AppReady and (K_CMD4WWaitApplyDataCount = 0) then
  begin
    N_Dump2Str   ( 'D4W >> SetPatientsInfo' );
    K_CMS_LogsCtrlAll := CMS_LogsCtrlAll;
    Result := SetInfo( FInfo, K_CMEDAccess.PatientsInfo );
    if Result = S_OK then
    begin
      K_CMD4WApplyPatientRuntimeInfo();
      K_CMEDAccess.UpdatePPLFlagsSet := K_CMEDAccess.UpdatePPLFlagsSet + [K_uliPatients];
    end;
    K_CMS_LogsCtrlAll := TRUE;
  end
  else
  begin
    K_CMD4WPatientsInfo := FInfo;
    Result := 2;
  end;
end; //*** end of TD4WCMServer.SetPatientsInfo

//********************************************** TD4WCMServer.ProvidersInfo ***
// Set All registered in D4W Providers Info
//
//     Parameters
// AProvidersInfo - All Providers needed info
// Result - Returns function COM resulting code.
//
// Providers Info string is Tab delimited Table. Each Table Row contains single
// Provider attributes. First Table Row contains Provider attributes identifiers:
//#F
//    ProviderID ProviderFirstName ProviderSurname ProviderTitle
//#/F
//
function TD4WCMServer.SetProvidersInfo( const AProvidersInfo: WideString ): HResult;
var
  FInfo : string;
  AppReady : Boolean;
begin
//K_InfoWatch.AddInfoLine( 'SetProvidersInfo' );
  if K_CMD4WAppFinState then begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetProvidersInfo' );
    Result := S_FALSE;
    Exit;
  end;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  CurCodePage := N_NeededCodePage;
  AppReady := IsAppReady( );
  if not AppReady and (K_CMD4WCurCodePage <> 0) then
    N_NeededCodePage := K_CMD4WCurCodePage;
  FInfo := N_WideToString(AProvidersInfo);
  N_NeededCodePage := CurCodePage;

  if AppReady and (K_CMD4WWaitApplyDataCount = 0) then
  begin
    N_Dump2Str   ( 'D4W >> SetProvidersInfo' );
    K_CMS_LogsCtrlAll := CMS_LogsCtrlAll;
    Result := SetInfo( FInfo, K_CMEDAccess.ProvidersInfo );
    K_CMS_LogsCtrlAll := TRUE;
    if Result = S_OK then
      K_CMEDAccess.UpdatePPLFlagsSet := K_CMEDAccess.UpdatePPLFlagsSet + [K_uliProviders];
  end
  else
  begin
    K_CMD4WProvidersInfo := FInfo;
    Result := 2;
  end;
end; //*** end of TD4WCMServer.SetProvidersInfo

//********************************************* TD4WCMServer.SetWindowState ***
// Set CMS Main Window State
//
//     Parameters
// AWinState  - new Main Window State:
//#F
// -1 - hide,
//  0 - normal,
//  1 - minimized,
//  2 - maximized,
//#/F
// Result - Returns function COM resulting code.
//
function TD4WCMServer.SetWindowState(AWinState: Integer): HResult;
var
  AppReady : Boolean;
  ProtStr : string;
  UICommandFlags : TK_CMUICommandFlags;
{
  CurShowCommand : Integer;
const
  ShowCommands: array[0..3] of Integer =
    (SW_HIDE, SW_SHOWNORMAL, SW_SHOWMINIMIZED, SW_SHOWMAXIMIZED);
}
label LExit;
begin
  if K_CMD4WAppFinState then begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetWindowState' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str   ( 'D4W >> TD4WCMServer.SetWindowState start' );

  ProtStr := 'ERR';

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  Result := S_OK;
  if AWinState <> -1 then
  begin
    AWinState := AWinState and 3;
    if (AWinState > Ord(High(TWindowState))) or
       (AWinState < Ord(Low(TWindowState))) then
    Result := E_INVALIDARG;
  end;

  if Result <> E_INVALIDARG then
  begin
    AppReady := IsAppReady( ) and (K_CMD4WWaitApplyDataCount = 0);
    UICommandFlags := [K_uicAddToBuffer];
    ProtStr := ' BUF';
    if AppReady then
    begin
      if K_CMD4WCNewPatientID > 0 then
      begin
        // Try to awake
        if not K_CMD4WSkipCMSAwakeFlag then
        begin // Launch VEUI
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServLaunchVEUI, TRUE );
          K_CMEDAccess.AccessReady := FALSE;
        end // Launch VEUI
        else
        begin // Awake is skiped
          ProtStr := ' awake is skiped';
          Result := S_FALSE;
          goto LExit;
        end
      end
      else
      begin
        UICommandFlags := [];
        ProtStr := ' EXEC';
      end;
    end; // if AppReady then

    Result := K_ExecUICommand( 3, IntToStr(AWinState), UICommandFlags );
  end;
LExit: //********
  N_Dump1Str ( 'D4W >> Set Window State to ' + IntToStr(AWinState) + ProtStr +
                        ' Res=$' + IntToHex( Result, 8 )  );
end; // function TD4WCMServer.SetWindowState

//**************************************************** TD4WCMServer.Destroy ***
//
destructor TD4WCMServer.Destroy;
var
//  Action: TCloseAction;
  i : Integer;
  WComp : TComponent;
  WStr : string;
  ModalFormsExist : Boolean;
begin

  if ComServer = nil then Exit; // It is possible if D4W linked to already started CMS and was finished (it is possible in XP only)

  try
    N_Dump1Str   ( 'D4W >> TD4WCMServer.Destroy start ' );
//    Action := caNone;
    ProtStr := 'Client linked to running CMS clear COM Interface ';

    K_CMD4WSkipCloseUI := FALSE;

    // Try to Restore Standalone Mode
    WStr := N_MemIniToString('CMS_Main', 'StandaloneGUIKey', '');
    K_CMStandaloneGUIMode :=
      (WStr <> '')                                        and
      ((WStr = '*') or (K_CMDParams.IndexOf(WStr) >= 0) ) and
      ( not(K_CMEDAccess is TK_CMEDDBAccess) or
        (K_CMEDDBVersion >= 19) ); // Check if Stand Alone is able on current DB Version

    if (ComServer.ObjectCount = 1) and
       (K_CMD4WAppRunByCOMClient or K_CMStandaloneGUIMode) then
    begin
      if IsAppReady( ) then
      begin
      ////////////////////////////////////////
      //  Try to Close Open Modal Forms
      //
        ModalFormsExist := FALSE;
        try
          for i := Application.ComponentCount - 1 downto 0 do
          begin
            WComp := Application.Components[i];
            if not (WComp is TForm)                    or
               not (fsModal in TForm(WComp).FormState) or
               (TForm(WComp).ModalResult = mrCancel) then Continue;
//               not (WComp <> N_CM_MainForm ) then Continue;
            N_Dump1Str( 'D4W >> close Modal Form ' + TForm(WComp).Name );
            TForm(WComp).Close;
            ModalFormsExist := TRUE;
//            Application.ProcessMessages();
          end;
        except
          on E: Exception do begin
            N_Dump1Str   ( 'D4W >> CMS modal windows closing except >> ' + E.Message );
          end;
        end;
    {}
        if K_CMD4WAppFinState then
          N_Dump1Str   ( 'D4W >> CMS is closing -> TD4WCMServer.Destroy' )
        else
        begin
          if ModalFormsExist and                  // Some Modal Forms are closed
            (K_CMD4WWaitApplyDataCount > 0) then  // Some Actions were activate
          begin
            N_Dump1Str( 'D4W >> Try CMSuite close later' );
            K_CMCloseOnFinActionFlag := TRUE; //to close N_CM_MainForm in finish action code 
//            N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE, 5 );
          end
          else
          try
            N_Dump1Str   ( 'D4W >> Before N_CM_MainForm.Close');
            N_CM_MainForm.Close();
            N_Dump1Str   ( 'D4W >> After N_CM_MainForm.Close');
          except
            on E: Exception do begin
              N_Dump1Str   ( 'D4W >> CMS N_CM_MainForm closing exception >> ' + E.Message );
            end;
          end;
        end; // if not K_CMD4WAppFinState then
      end;
      ProtStr := 'CMSuite Stop';
    end;

    N_Dump1Str( 'D4W >> ' + ProtStr );
//  TT.Free;
    inherited;
// for Server Start Waiting
  except
    on E: Exception do begin
      N_Dump1Str   ( 'D4W >> TD4WCMServer.Destroy except >> ' + E.Message );
    end;
  end;

  K_CMD4WAppRunByCOMClient := FALSE;
  K_CMSAppStartContext.CMASMode := K_cmamCOMVEUI; // needed if COMServer is closed inside CMS initialization
//  K_CMD4WSetCurDataContext := TRUE;
  SBuf.Free;

end; //*** end of TD4WCMServer.Destroy

//************************************************* TD4WCMServer.Initialize ***
//
procedure TD4WCMServer.Initialize;
begin
  N_Dump1Str   ( 'D4W >> TD4WCMServer.Initialize start ' );
//  K_CMD4WAppRunByCOMClient := not IsAppReady( ); // Set D4W Client Start Flag
  K_CMD4WAppRunByCOMClient := TRUE; // Set D4W Client Start Flag
  ProtStr := 'CMSuite Run';
//  if not K_CMD4WAppRunByCOMClient then
//    ProtStr := 'Client is linked to running CMS';

//  K_CMD4WSetCurDataContext := FALSE; // for Server Start Waiting
//!!! may be it is not needed
  K_CMSAppStartContext.CMASMode := K_cmamWait; // for Server Start Waiting if some other Start Mode was set before COM server creation


  N_Dump2Str( 'D4W >> ' + ProtStr );

  K_CMStandaloneGUIMode := FALSE;

  SBuf := TN_SerialBuf0.Create();

  inherited;
end; //*** end of TD4WCMServer.Initialize

//*************************************** TD4WCMServer.GetPatientMediaCount ***
// Get given Patient Media Objects Counter
//
//     Parameters
// APatID  - given patient ID
// AMediaCount - resulting media objects counter
// Result - Returns function COM resulting code.
//
function TD4WCMServer.GetPatientMediaCounter( APatID: Integer;
                                      out AMediaCounter: OleVariant ): HResult;
var
  SavedPat : Integer;
  SCount : Integer;
begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> GetPatientMediaCounter' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str   ( 'D4W >> TD4WCMServer.GetPatientMediaCounter start ' );

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  ProtStr := 'Get Patient Media Counter - ';
  if (K_CMEDAccess = nil) or (not K_CMEDAccess.AccessReady) then
  begin
    N_Dump1Str ( 'D4W >> ' + ProtStr + 'not ready' );
    Result := E_PENDING;
    Exit;
  end;
  SavedPat := K_CMEDAccess.CurSlidesSelectAttrs.SSPatID;
  K_CMEDAccess.CurSlidesSelectAttrs.SSPatID := APatID;
  if K_CMEDAccess.EDACalcBySlidesSelectAttrs( SCount ) <> K_edOK then
  begin
    AMediaCounter := 0;
    ProtStr := 'D4W >> ' + ProtStr + K_CMEDAccess.ExtDataErrorString;
    Result := E_ABORT;
  end
  else
  begin
    AMediaCounter := SCount;
    ProtStr := 'D4W >> ' + ProtStr + IntToStr(SCount);
    Result := S_OK;
  end;
  N_Dump1Str ( ProtStr );
  K_CMEDAccess.CurSlidesSelectAttrs.SSPatID  := SavedPat;
end; //*** end of TD4WCMServer.GetPatientMediaCount

//******************************************** TD4WCMServer.GetWindowHandle ***
// Get CMS Main Window Handle
//
//     Parameters
// AWinHandle - CMS Main Window Handle as Integer
// Result - Returns function COM resulting code.
//
function TD4WCMServer.GetWindowHandle( out AWinHandle: OleVariant ): HResult;
begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> GetWindowHandle' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str   ( 'D4W >> TD4WCMServer.GetWindowHandle start ' );
  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  if N_CM_MainForm.CMMCurFMainForm = nil then
  begin
    if N_CM_MainForm.CMMCurFHPMainForm = nil then
      AWinHandle := N_CM_MainForm.Handle
    else
      AWinHandle := N_CM_MainForm.CMMCurFHPMainForm.Handle;
  end
  else
    AWinHandle := N_CM_MainForm.CMMCurFMainForm.Handle;
  Result := S_OK;
end; //*** end of TD4WCMServer.GetWindowHandle

//************************************************* TD4WCMServer.SetIniInfo ***
// Set CMSuite Application Properties by Info in Ini-File Format
//
//     Parameters
// AIniInfo - text with CMSuite Application Properties in Ini-File Format
// Result   - Returns function COM resulting code.
//
// CMSuite Application Modes should be in Ini-File Format:
//#F
//[IniSectionName1]
//<PropertyName1>=<PropertyValue>
//...
//<PropertyNameN>=<PropertyValue>
//
//...
//
//[IniSectionNameK]
//<PropertyName1>=<PropertyValue>
//...
//<PropertyNameN>=<PropertyValue>
//#/F
//
function TD4WCMServer.SetIniInfo( const AIniInfo: WideString ): HResult;
var
  SInitInfo : string;
begin
  if K_CMD4WAppFinState then begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> SetIniInfo' );
    Result := S_FALSE;
    Exit;
  end;
  N_Dump1Str   ( 'D4W >> TD4WCMServer.SetIniInfo start ' );
  Result := S_OK;
  SInitInfo := N_WideToString(AIniInfo);
  DumpTabInfo( SInitInfo, 'Ini Info' );
  // Set Modes To Ini
//!!  K_CMEDASetIniInfo( SInitInfo );
end; //*** end of TD4WCMServer.SetIniInfo

//********************************************** TD4WCMServer.GetServerInfo ***
// Get CMS Server Info String
//
//     Parameters
// AServerCode - CMS Server Info Code
//#F
// -2 - CMS WEB API Version (as integer)
// -1 - CMS Com Library Version (as integer)
//  0 - CMS Build Info (as string)
//  1 - get CMSClientLib Log File Name
//  2 - get Server State
//  3 - get Server Licenses Counter
//  4 - get Server Active Instances Counter
//#/F
// AServerInfo - CMS Server Info as Variant string
// Result - Returns function COM resulting code.
//
function TD4WCMServer.GetServerInfo( AServerCode: Integer;
                                     out AServerInfo: OleVariant ): HResult;
var
  LogStr : string;
  Int : Integer;
  AppReady : Boolean;
begin
// Application shouldn't start initialization before fist GetServerInfo comes

  if K_CMD4WAppFinState then begin
    N_Dump1Str( 'D4W >> CMS is closing -> GetServerInfo' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str( 'D4W >> TD4WCMServer.GetServerInfo start ' );
  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  Result := S_OK;
  case AServerCode of
  -2 : begin
       LogStr      := IntToStr( K_WEBCMSAPIVer );
       AServerInfo := K_WEBCMSAPIVer;
     end;
  -1 : begin
       LogStr      := IntToStr( K_CMSComLibVer );
       AServerInfo := K_CMSComLibVer;
     end;
   0 : begin
       LogStr      := K_CMSSBuildNum;
       AServerInfo := LogStr;
     end;
   1 : begin
       LogStr      := '';
       AServerInfo := LogStr;
     end;
   2 : begin
       AppReady := IsAppReady();
{
       LogStr      := 'READY';
       if AppReady and
         (N_CM_MainForm.CMMCurFMainForm = nil) then
       begin
         if N_CM_MainForm.CMMCurFHPMainForm = nil then
           LogStr      := 'SLEEP'
         else
           LogStr      := 'PREVIEW'
       end
       else
       if not AppReady or (K_CMD4WWaitApplyDataCount > 0) then
         LogStr      := 'BUSY';
}
       if AppReady then
       begin
         LogStr := 'READY';
         if N_CM_MainForm.CMMCurFMainForm = nil then
         begin
           if N_CM_MainForm.CMMCurFHPMainForm = nil then
           begin
             if K_CMSAppStartContext.CMASMode = K_cmamCOMFSAccess then
               LogStr := 'FSACCESS'
             else
               LogStr := 'SLEEP'
           end
           else // if N_CM_MainForm.CMMCurFHPMainForm <> nil then
             LogStr := 'HPREADY';
         end
         else
         if K_CMD4WWaitApplyDataCount > 0 then
           LogStr := 'BUSY';
       end
       else // if N_CM_MainForm.CMMCurFMainForm <> nil then
       if K_CMEDAccess <> nil then
         LogStr := 'NOTREADY'
       else
         LogStr := 'NOTINIT';

       AServerInfo := LogStr;
     end;
   3 : begin
       Int := K_CMGetSecadmLicount();
       AServerInfo := Int;
     end;

   4 : begin
       Int := K_CMGetRunCount();
       AServerInfo := Int;
     end;
  else
    AServerInfo := 0;
    Result := E_INVALIDARG;
  end;
  N_Dump1Str( 'D4W >> Get Server Info['+IntToStr(AServerCode)+'] - ' + LogStr );
//  K_CMSPCAddCOMServer ( 'D4W >> Get Server Info['+IntToStr(AServerCode)+'] - ' + LogStr );
end; //*** end of TD4WCMServer.GetServerInfo

//********************************************** TD4WCMServer.ExecUICommand ***
// Execute CMS UI Command
//
//     Parameters
// AComCode - CMS UI Command Code:
//#F
//  0 - Select Media Object in CMS Main Window Thumbnailes Frame (add to selected)
//      AComInfo - string with Media Object ID
//  1 - Unselect Media Object in CMS Main Window Thumbnailes Frame (remove from selected)
//      AComInfo - string with Media Object ID
//  2 - Execute GUI Action
//      AComInfo - GUI Action Name:
//        MediaClearSelection  - Clear Media Objects Selection in CMS Main Window Thumbnailes Frame
//        MediaOpen            - Open Media Object selected in CMS Main Window Thumbnailes Frame
//        CMSClose             - Close CMS Application (needed for close CMS after Modal Window Close)
//  3 - Set Window State
//      AComInfo - string with Window State Code
//  4 - Copy/Move Patient Slides
//      AComInfo - <SrcPatID>,<DstPatID>,<CopyMode>
//#/F
// AComInfo - CMS GUI Command Info
// Result - Returns function COM resulting code.
//
function TD4WCMServer.ExecUICommand( AComCode: Integer;
                                     const AComInfo: WideString ): HResult;
var
  ProtStr : string;
  UICommandFlags : TK_CMUICommandFlags;
  CMSCloseCommandFlag : Boolean;

label LExit;

begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> ExecUICommand  Code=' + IntToStr(AComCode) +
                            ' Info=' + AComInfo );
    Result := S_FALSE;
    Exit;
  end;

  if N_CM_MainForm = nil then
  begin
    N_Dump1Str   ( 'D4W >> CMS is not ready for UICommand -> ExecUICommand  Code=' + IntToStr(AComCode) +
                            ' Info=' + AComInfo );
    Result := E_UNEXPECTED;
    Exit;
  end;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  N_Dump1Str( format( 'D4W >> ExecUICommand >> Ready=%s Close=%s WC=%d PatID=%d Code=%d Info=%s',
   [N_B2S(IsAppReady()),
    N_B2S(N_CM_MainForm.CMMCurFMainForm = nil),
    K_CMD4WWaitApplyDataCount,
    K_CMD4WCNewPatientID,
    AComCode, AComInfo] ) );


  CMSCloseCommandFlag := (AComCode = 2) and (AComInfo = 'CMSClose');

  UICommandFlags := [];
  ProtStr := ' EXEC';
  if not CMSCloseCommandFlag then
  begin
    if not IsAppReady() or // if CMS is not ready or is Buisy
       (K_CMD4WWaitApplyDataCount > 0) then
    begin
      UICommandFlags := [K_uicAddToBuffer];
      ProtStr := ' BUF';
    end // Buffered Command
    else
    if N_CM_MainForm.CMMCurFMainForm = nil then
    begin
      if ( (N_CM_MainForm.CMMCurFHPMainForm <> nil) or
           (K_CMD4WCNewPatientID > 0) ) and
         (AComCode <= 2) then
      begin
      // Main Interface Form (VEUI) is closed - launch VEUI before command execution
        if not K_CMD4WSkipCMSAwakeFlag then
        begin // Launch VEUI
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServLaunchVEUI, TRUE );
          K_CMEDAccess.AccessReady := FALSE;
          UICommandFlags := [K_uicAddToBuffer];
          ProtStr := ' BUF';
        end // Launch VEUI
        else
        begin // Awake is skiped
          ProtStr := ' awake is skiped';
          Result := S_FALSE;
          goto LExit;
        end

      end
      else
      begin //??? needed if D4W attempt to use ExecUI before VEUI interface is launched
        N_Dump1Str ( 'D4W >> !!! VEUI Interface is not launched' );
        UICommandFlags := [K_uicAddToBuffer];
        ProtStr := ' BUF';
      end; // if N_CM_MainForm.CMMCurFMainForm = nil then
    end; // if N_CM_MainForm.CMMCurFMainForm = nil then
  end; // if not CMSCloseCommandFlag then

  if CMSCloseCommandFlag and
     not (K_uicAddToBuffer in UICommandFlags) then
    Include( UICommandFlags, K_uicLastCommand ); // Add K_uicLastCommand for immediate (not buffered) close 

  Result := K_ExecUICommand( AComCode, AComInfo, UICommandFlags );
LExit: //******
  N_Dump1Str ( 'D4W >> Exec UI Command Code=' + IntToStr(AComCode) +
                        ' Info=' + AComInfo + ProtStr + ' Res=$' + IntToHex( Result, 8 ) );
end; //*** end of TD4WCMServer.ExecUICommand

//********************************************** TD4WCMServer.SetCodePage ***
// Define Code Page for string convertion
//
//     Parameters
// ACodePageID - CMS Code Page
//#F
// -1 - CMS Com Library Version (as integer)
//  0 - CMS Build Info (as string)
//  1 - get CMSClientLib Log File Name
//  2 - get Server Modal Dialog State
//#/F
// AServerInfo - CMS Server Info as Variant string
// Result - Returns function COM resulting code.
//
function TD4WCMServer.SetCodePage(ACodePageID: Integer): HResult;
begin
//  N_NeededCodePage := ACodePageID;
  N_Dump1Str( 'D4W >> TD4WCMServer.SetCodePage start ' );
  K_CMD4WCurCodePage := ACodePageID;
  Result := S_OK;
end; //*** end of TD4WCMServer.SetCodePage

//*********************************************** TD4WCMServer.StartSession ***
// Start Sesssion (open DB connection for files access - not dialog mode)
//
//    Parameters
// AStartCode - Session Start Code
// Result     - Returns operation resulting code:
//#F
// S_OK                           (0x0) - Indicates that Session was started
// S_FALSE                        (0x1) - Indicates that Session is already started
// E_FAIL                  (0x80004005) - DB coonection fails
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_INVALIDARG            (0x80070057) - Wrong User ID
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.StartSession( AStartCode: Integer ): HResult;
var
  ReopenConnectionFlag : Boolean;
begin
  Result := S_OK;
  if (K_CMSAppStartContext.CMASMode <> K_cmamWait) and (K_CMSAppStartContext.CMASMode <> K_cmamSleep)  then
    Result := S_FALSE
  else
  begin
    ReopenConnectionFlag := K_CMSAppStartContext.CMASMode = K_cmamSleep;
    case AStartCode of
      0 : K_CMSAppStartContext.CMASMode := K_cmamCOMWEB;
      1 : K_CMSAppStartContext.CMASMode := K_cmamCOMFSAccess;
    else
      Result := E_INVALIDARG;
    end;
    if (Result <> E_INVALIDARG) and ReopenConnectionFlag then
    begin
      if not K_CMReopenDBConnection() then
        Result := E_FAIL;
    end;
  end;
  N_Dump1Str( format( 'D4W >> TD4WCMServer.StartSession S=%d R=%x', [AStartCode,Result] ) );
end; // function TD4WCMServer.StartSession

//********************************************* TD4WCMServer.GetSlidesAttrs ***
// Get Patient Media Objects attributes
//
//     Parameters
// APatID  - patient ID
// AMode   - select Media Objects type (0 - actual, 1 - marked as deleted, 2 - all)
// AFields - TAB delimited fields names to get
// ARData  - resulting Media Objects attributes serialized data
// Result - Returns function COM resulting code.
//
// Media Objects serialized data is ByteArray. First 4 bytes contains integer number of
// resulting Media Objects. Each Media Object attributes serialized as the sequence of
// serialized fields which have the same order as fields names in AFields.
//
//
//#F
//            Possible Fileds Info
// Name           Type    Comment
// ObjID	        Integer	Object identifier
// ObjType	      Integer	Object type code: 0 - Image, 1 - Video, 2 - Study
// DateTaken	    string	Object taken date (dd.mm.yyyy)
// TimeTaken	    string	Object taken time (hh:nn:ss)
// TeethLeftSet	  Integer	Object "left" teeth numbering designation (appendix A)
// TeethRightSet	Integer	Object "right" teeth numbering designation (appendix A)
// TeethSetCapt   string  Object teeth numbering caption
// MediaTypeID	  Integer	Object media type identifier
// MediaTypeName  Integer	Object media type name
// Source	        string	Object  source description
// Diagn	        string	Object  Diagnoses
// ObjStudyID	    Integer	Bigger than 0 - object study ID for objects linked to studies
//                        Less than 0 - for studies,
//                        0 - for objects not linked to studies,
// PixWidth	      Integer	Image and Video objects width in pixels
// PixHeight	    Integer	Image and Video objects height in pixels
// PixColorDepth	Integer	Image and Video objects color depth (8 - 16 for grey, 24 for color)
// VideoDuration	Float	  Video objects duration in seconds
// VideoFExt      string	Video objects file extension
// ModifyDate	    string	Object modify date (dd.mm.yyyy)
// ModifyTime	    string	Object modify time (hh:nn:ss)
//#/F
//
function TD4WCMServer.GetSlidesAttrs(APatID, AMode: Integer;
  const AFields: WideString; out ARData: OleVariant): HResult;
var
  BinData : Variant;
  SL : TStringList;
  SFields : string;
begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> GetSlidesAttrs' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str   ( 'D4W >> TD4WCMServer.GetSlidesAttrs start ' );

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  // Get Slide Attrs to SBuffer
  SFields := N_WideToString(AFields);

  SL := TStringList.Create();
  SL.Delimiter := #9;
  SL.DelimitedText := SFields;
  SBuf.Init();
  if not K_CMPutSlidesAttrsToSBuf( APatID, AMode, SL, SBuf ) then
  begin
    N_Dump1Str( 'D4W >> GetSlidesAttrs Connection Error' );
    Result := E_UNEXPECTED;
  end
  else
  begin
    N_Dump1Str ( format( 'D4W >> GetSlidesAttrs PatID=%d RDataSize=%d'#13#10'%s',
                         [APatID, SBuf.OfsFree, SFields] ) );
    if SBuf.OfsFree > 0 then
    begin
      DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
      ARData := BinData;
      Result := S_OK;
    end
    else
      Result := S_FALSE;
  end;
  SL.Free();
end; // function TD4WCMServer.GetSlidesAttrs

//**************************************** TD4WCMServer.GetSlidesThumbnails ***
// Get Thumbnails by Media Objects IDs List
//
//     Parameters
// AMobjIDs - Tab delimited string with source Media Objects IDs
// AMode    - select Media Objects type (0 - actual, 1 - marked as deleted, 2 - all)
// ASThumbs - resulting Media Objects thumbnails serialized data
// Result - Returns function COM resulting code.
//
// Thumbnails serialized data is ByteArray which containes the same number
// of fragments as in source Media Objects IDs array. First 4 bytes of each fragment
// contains integer with thumbnail byte length. Fragment tail bytes contains
// thumbnail data. If some slide given in Slides IDs array is absent then
// thumbnail byte length should be equal 0.
//
function TD4WCMServer.GetSlidesThumbnails(const AMobjIDs: WideString;
  AMode: Integer; out ASThumbs: OleVariant): HResult;
var
//  BTest
//  i : Integer;
  BinData : Variant;
  SL : TStringList;
begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> GetSlidesThumbnails' );
    Result := S_FALSE;
    Exit;
  end;

  N_Dump1Str   ( 'D4W >> TD4WCMServer.GetSlidesThumbnails start ' );

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  SBuf.Init();
  SL := TStringList.Create;
  SL.Delimiter := #9;
  SL.DelimitedText := N_WideToString( AMobjIDs );

  // Get Thumbnails to SBuffer
  if not K_CMPutSlidesThumbnailsToSBuf( SL, AMode, SBuf ) then
  begin
    N_Dump1Str( 'D4W >> GetSlidesThumbnails Connection Error' );
    Result := E_UNEXPECTED;
  end
  else
  begin
    N_Dump1Str ( format( 'D4W >> GetSlidesThumbnails SCount=%d RDataSize=%d',
                         [SL.Count, SBuf.OfsFree] ) );

    DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
    ASThumbs := BinData;
    Result := S_OK;
  end;

  SL.Free();

end; // function TD4WCMServer.GetSlidesThumbnails

//****************************************** TD4WCMServer.GetSlideImageFile ***
// Get given slide Image file
//
//     Parameters
// ASlideID   - Source Slide ID
// AMaxWidth  - Media Object image maximal width on input, if =0 then image
//              original width will be used, resulting Image real width will be
//              defined automatically using Media Object image aspect
//              and will be returned on output
// AMaxHeight - Media Object image maximal height on input, if =0 then image
//              original height will be used, resulting Image real height will be
//              defined automatically using Media Object image aspect
//              and will be returned on output
// AFileFormat - resulting Image file format code: junior decimal number is format type
//               (1 - bmp, 3 - jpg, 4 - tif, 5 - png), the two next decimal numbers
//               coding jpg quality from 01 to 99, if not set then highest quality 100
//               will be used
// AFileCont   - resulting Image file content code:
//#F
//  0 - last image state with annotations
//  1 - last image state without annotations
//  2 - image original state without annotations
//#/F
// AFileName   - Resulting file full Name including Path
// Result      - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Given Media Object Image File was created
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// CMS_Object_Wrong_ID            (0xA0000201) - Given Media Object has no Image represantation
// CMS_Object_HasNo_Image         (0xA0000202) - Given Media Object has no Image represantation
// CMS_Create_Image_OutOffMemory  (0xA0000203) - Ther is not enough memory to create image
// CMS_Create_Image_Internal_Error(0xA0000204) - Create Image internal error
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.GetSlideImageFile( ASlideID: Integer; var AMaxWidth,
                  AMaxHeight: OleVariant; AFileFormat, AViewCont: Integer;
                  const AFileName: WideString ): HResult;
var
  FileName : string;
  MaxWidth, MaxHeight : Integer;
  SLides: TN_UDCMSArray;
  ExportFlags : TK_CMBSlideExportToDIBFlags;
  ResCode : Integer;
begin
  Result := S_OK;
  try
    FileName := N_WideToString(AFileName);
    MaxWidth  := AMaxWidth;
    MaxHeight := AMaxHeight;
    N_Dump1Str( format( 'D4W >> TD4WCMServer.GetSlideImageFile Start SlideID=%d %dx%d F=%d C=%d >> %s',
                        [ASlideID,MaxWidth,MaxHeight,AFileFormat,AViewCont,
                         FileName] ) );

    if K_CMEDAccess = nil then
    begin
      Result := 2;
      N_Dump1Str('D4W >> GetSlideImageFile server is not ready' );
      Exit;
    end;

    TK_CMEDDBAccess(K_CMEDAccess).EDAGetUDCMSlidesByID0( @ASlideID, 1, SLides );
    if Length(SLides) = 0 then
    begin
      LongWord(Result) := CMS_Object_Wrong_ID;
      N_Dump1Str('D4W >> GetSlideImageFile wrong SlideID' );
      Exit;
    end;

    ExportFlags := [];
    case TK_WCMSMediaObjViewCont(AViewCont) of
      wcmcSkipAnnot: ExportFlags := [K_bsedSkipAnnotations];
      wcmcOriginal : ExportFlags := [K_bsedExportOriginal];
    end;

    ResCode := K_CMPrepSlideDIBFile( FileName, SLides[0],
                      MaxWidth, MaxHeight, AFileFormat, ExportFlags );
    if SLides[0].Marker = 1 then
      SLides[0].UDDelete();
    if 0 <> ResCode then
    begin
      case ResCode of
      1: LongWord(Result) := CMS_Object_HasNo_Image;
      2: LongWord(Result) := CMS_Create_Image_OutOffMemory;
      3,4,5: LongWord(Result) := CMS_Create_Image_Internal_Error;
      end;
      Exit;
    end
    else
    begin
      AMaxWidth  := MaxWidth;
      AMaxHeight := MaxHeight;

      N_Dump1Str ( format( 'D4W >> TD4WCMServer.GetSlideImageFile Fin %dx%d',
                           [MaxWidth,MaxHeight] ) );
    end;
  except
    on E: Exception do begin
      Result := HResult($8000FFFF);
      N_Dump1Str   ( 'D4W >> TD4WCMServer.GetSlideImageFile except >> ' + E.Message );
    end;
  end;
end; // function TD4WCMServer.GetSlideImageFile

//******************************************** TD4WCMServer.HPSetCurContext ***
// Set CMS HR Preview current context
//
//     Parameters
// APatientID  - current Patient new ID
// AProviderID - current Provider new ID
// ALocationID - current Location new ID
// Result - Returns function COM resulting code.
//
// If any given ID (Patient, Provider, MediaType) is equal to -1 then previous context value should be used.
// Call to SetCurContext(-1,-1,-1) does not change CMS HR Preview context.
//
// If CMS HR Preview window is opened and APatientID differs from current Patient
// then CMS HR Preview window will be closed. If CMS HR Preview window is closed
// then current context will be store to use when CMS HR Preview window will be
// opend by HPViewMediaObject.
//
// Should be called just after Patient is changed in D4W user interface.
//
function TD4WCMServer.HPSetCurContext( APatientID, AProviderID, ALocationID: Integer): HResult;
begin
  Result := S_OK;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  N_Dump1Str   ( 'D4W >> TD4WCMServer.HPSetCurContext start ' );
  if K_CMEDAccess <> nil then
  begin
    if APatientID = -1 then
      APatientID  := K_CMEDAccess.CurPatID;

    if AProviderID = -1 then
      AProviderID := K_CMEDAccess.CurProvID;

    if ALocationID = -1 then
      ALocationID := K_CMEDAccess.CurLocID;
  end;

  if N_CM_MainForm <> nil then
  begin
    if (N_CM_MainForm.CMMCurFHPMainForm <> nil) and (K_CMD4WHPNewPatientID <> APatientID) then
    begin
      K_CMCloseCurUIFlag := TRUE;
      N_CM_MainForm.CMMCurFHPMainForm.Close();
    end;
  end;


  K_CMD4WHPNewPatientID   := APatientID;  // D4W HP New Patient ID
  K_CMD4WHPNewProviderID  := AProviderID; // D4W HP New Provider ID
  K_CMD4WHPNewLocationID  := ALocationID; // D4W HP New Location ID
  K_CMD4WHPFilmStripIDs   := ''; // D4W Slides IDs list to show in HP Film Strip
  K_CMD4WHPOpenInVEMode   := 0;  // D4W open CMS in View/Edit mode from HP
  K_CMD4WHPViewSlideID    := ''; // D4W Slide ID to show in High Resolution Mode
  N_Dump1Str( format( 'D4W >> HPSetCurContext PatID=%d ProvID=%d LocID=%d', [APatientID,AProviderID,ALocationID] ) );
end; // function TD4WCMServer.HPSetCurContext

//****************************************** TD4WCMServer.HPSetVisibleIcons ***
// Set Media Objects icons set visible in HR Preview window film strip
//
//     Parameters
// AMobjIDs - Tab delimited string with source Media Objects IDs
// AMode    - open CMS View/Edit interface mode
//#F
// 0 - open only current selected Media Object,
// 1 - open all Media Objects in HR Preview window film strip
//#/F
// Result   - Returns function COM resulting code.
//
// Given Media Objects IDs are only stored for future use when HR Preview window will
// be shown or its content will be changed after HPViewMediaObject.
//
// Should be called just after media objects visible icons set is changed in D4W user interface.
//
function TD4WCMServer.HPSetVisibleIcons( const AMObjIDs: WideString;
                                         AMode: Integer ): HResult;
begin
  Result := S_OK;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  K_CMD4WHPFilmStripIDs := N_WideToString(AMObjIDs);  // D4W Slides IDs list to show in HP Film Strip
  if AMode <> 1 then AMode := 0;
  K_CMD4WHPOpenInVEMode := AMode; // D4W open CMS in View/Edit mode from HP
  K_CMD4WHPViewSlideID  := '';  // D4W Slide ID to show in High Resolution Mode
  N_Dump1Str( format( 'D4W >> HPSetVisibleIcons M=%d IDs=%s', [AMode,K_CMD4WHPFilmStripIDs] ) );
end; // function TD4WCMServer.HPSetVisibleIcons

//****************************************** TD4WCMServer.HPViewMediaObject ***
// Set current Media Object shown in high resolution
//
//     Parameters
// AViewID - Media Object to show in high resolution ID
// Result   - Returns function COM resulting code.
//
// HR Preview window will be shown or its content will be changed and given Media Object
// will become visible in high resolution mode.
//
// Should be called just after click on media object icon in D4W user interface.
//
function TD4WCMServer.HPViewMediaObject( const AViewID: WideString): HResult;

begin
  if K_CMD4WAppFinState then
  begin
    N_Dump1Str   ( 'D4W >> CMS is closing -> HPViewMediaObject' );
    Result := S_FALSE;
    Exit;
  end;

  if K_CMAutoCloseLastActTS <> 0 then
    K_CMAutoCloseLastActTS := Now(); // Correct Last Action TS

  K_CMD4WHPViewSlideID := N_WideToString(AViewID);  // D4W Slide ID to show in High Resolution Mode

  K_CMSAppStartContext.CMASMode := K_cmamCOMHPUI;

  if K_CMSAppStartContext.CMAInitNotComplete then
  begin
    N_Dump1Str( '***** Do init on HPUI after Files Access mode' );
    N_CM_MainForm.FormShow( Application );
  end;

  if (N_CM_MainForm = nil) or (N_CM_MainForm.CMMCurFHPMainForm = nil) then
    K_CMD4WHPFilmStripPrevIDs := '*'; // needed to Slides Rebiuild while HR Preview Form 1-st show

//N_Dump1Str( format( 'D4W >> HPViewMediaObject *=%s **=%s', [K_CMD4WHPFilmStripPrevIDs,K_CMD4WHPFilmStripIDs] ) );

  N_Dump1Str( format( 'D4W >> HPViewMediaObject ID=%s', [N_WideToString(AViewID)] ) );
  if IsAppReady() and (K_CMD4WWaitApplyDataCount = 0) then
  begin
  // Server is ready change HR Interface Context
{ // 30-11-2013
    Result := S_OK;
    K_CMSwithToHPUI()
}
    if (N_CM_MainForm.CMMCurFHPMainForm <> nil) then
    begin // Change Immediately
      Result := S_OK;
      N_Dump2Str( 'D4W >> HPViewMediaObject >> SwithToHPUI' );
      N_CM_MainForm.CMMLaunchHPUI();
    end   // Change Immediately
    else
    begin // Launch Action By timer
      Result := 2;
      K_CMEDAccess.AccessReady := FALSE;
      N_Dump2Str( 'D4W >> HPViewMediaObject >> SwithToHPUI by buffer Action' );
      N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServLaunchHPUI, TRUE );
    end;
  end
  else
  begin
    Result := 2;
    N_Dump2Str( 'D4W >> HPViewMediaObject buffered' );
  end;

end; // function TD4WCMServer.HPViewMediaObject

//********************************************** TD4WCMServer.WGetUserAttrs ***
// Set WEB CMS current User by Login and Password
//
//    Parameters
// ALogin	     	  - User login
// APassword	    - User password
// AWCMSProvAttrs - Resulting Current User Attributes
// Result         - Returns operation resulting code:
//#F
// S_OK                           (0x0) - Indicates that User with given Login
//                                        and Password is found and set as
//                                        current
// S_FALSE                        (0x1) - Indicates that Login and/or Password
//                                        are wrong
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - Specified Use is absent
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetUserAttrs( const ALogin, APassword: WideString;
                                     out AUserData: OleVariant ): HResult;
var
  BinData : Variant;
  SLogin, SPassword : string;
  ProvID : Integer;
begin
  SLogin := N_WideToString(ALogin);
  SPassword := N_WideToString(APassword);
  N_Dump1Str( format( 'WEB >> WSetCurrentUser Start LN=%s PW=%s',
                              [SLogin,SPassword] ) );

  Result := WCheckReady( TRUE );
  if Result <> S_OK then Exit;

  SBuf.Init();
  ProvID := K_CMPutProviderAttrsToSBuf( SLogin, SPassword, SBuf );

  if ProvID = -1 then
  begin
    HResult(Result) := E_UNEXPECTED;
    N_Dump1Str( 'WEB >> Connection Error' );
  end
  else
  if ProvID = 0 then
  begin
    LongWord(Result) := WCMS_User_Absent;
    N_Dump1Str( 'WEB >> User is absent' );
  end
  else
  begin
    DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
    AUserData := BinData;
    N_Dump2Str( format( 'WEB >> WSetCurrentUser Fin ProvID=%d RDataSize=%d',
                        [ProvID, SBuf.OfsFree] ) );
  end;
end; // function TD4WCMServer.WGetUserAttrs

//******************************************** TD4WCMServer.WSetCurrentUser ***
// Set WEB CMS current User by ID
//
//    Parameters
// AUserID	- User ID
// Result         - Returns operation resulting code:
//#F
// S_OK                           (0x0) - Indicates that User with given ID is
//                                        set as current
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// E_INVALIDARG            (0x80070057) - Wrong User ID
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WSetCurrentUser( AUserID: Integer ): HResult;
begin
  N_Dump1Str( format( 'WEB >> WSetCurrentUser Start ID=%d',
                              [AUserID] ) );
  Result := WCheckReady( TRUE );
  if Result <> S_OK then Exit;

  if (AUserID > -101) and (AUserID <= 0) then
    Result := E_INVALIDARG
  else
  begin
    K_CMWEBCOMProviderID := AUserID;
    K_CMSAppStartContext.CMASMode := K_cmamCOMWEB;
  end;
  N_Dump2Str( 'WEB >> WSetCurrentUser Fin' );

end; // function TD4WCMServer.WSetCurrentUser

//********************************************* TD4WCMServer.WGetMediaTypes ***
// Get Current Media Types serialised data as bytes array
//
//     Parameters
// AData - Media Types Data resulting data
// Result   - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that MediaTypes
//                                        data was get
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetMediaTypes(out AData: OleVariant): HResult;
var
  SL : TStrings;
  BinData : Variant;
  i : Integer;

begin
  N_Dump1Str( 'WEB >> WGetMediaTypes Start' );
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  SL := K_CMEDAccess.EDAGetAllMediaTypes0();
  SBuf.Init();
  SBuf.AddRowInt( SL.Count );
  for i := 0 to SL.Count - 1 do
  begin
    SBuf.AddRowInt( Integer(SL.Objects[i]) );
    SBuf.AddRowString( SL[i] );
  end;
  DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
  AData := BinData;

  N_Dump2Str ( format( 'WEB >> WGetMediaTypes Fin MCount=%d RDataSize=%d',
                       [SL.Count, SBuf.OfsFree] ) );
end; // function TD4WCMServer.WGetMediaTypes

//****************************************** TD4WCMServer.WSetPatientFilter ***
// Set Patients filter for future get attributes by WGetPatientsData
//
//     Parameters
// ACardNum   - Patients Card Number start chars
// ASurname   - Patients Surname start chars
// AFirstName - Patients First Name start chars
// AOrder     - Patient resulting data order code:
//#F
//  0 - ascending by Patient Card Number
//  1 - descending by Patient Card Number
//  2 - ascending by Patient Surname
//  3 - descending by Patient Surname
//  4 - ascending by Patient Name
//  5 - descending by Patient Name
//#/F
// ASelCode   - select patients code:
//#F
//  0 - select only actual patients
//  1 - select marked as deleted patients
//  2 - select all patients
//#/F
// APartCount - resulting patients number after filter apply
// Result     - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that Patients selection
//                                        filter was set
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
// -1                      (0xFFFFFFFF) - Unknown exception was raised.
//#/F
//
function TD4WCMServer.WSetPatientFilter( const ACardNum, ASurname, AFirstName: WideString;
                                         AOrder, ASelCode: Integer;
                                         out APatCount: OleVariant ): HResult;
var
  FPatFilterCount : Integer;
begin
  N_Dump1Str( format( 'WEB >> WSetPatientFilter Start CN=%s SN=%s FN=%s Ord=%d T=%d',
                              [N_WideToString(ACardNum),N_WideToString(ASurname),
                               N_WideToString(AFirstName), AOrder, ASelCode] ) );
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  K_CMWEBPatOrderSQL := TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientsOrderSQL( AOrder );
  K_CMWEBPatWhereSQL := TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientsWhereSQL( ASelCode,
                                                          N_WideToString(ACardNum),
                                                          N_WideToString(ASurname),
                                                          N_WideToString(AFirstname) );
  APatCount := 0;
  try
    TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientsFilteredCount( K_CMWEBPatWhereSQL,
                                                               FPatFilterCount );
    APatCount := FPatFilterCount;
  except
    on E: Exception do begin
      N_Dump1Str   ( 'WEB >> Get Filtered Patients Count >> ' + E.Message );
      Result := E_UNEXPECTED;
    end;
  end;
  N_Dump2Str( 'WEB >> WSetPatientFilter Fin Count=' + IntToStr(FPatFilterCount) );
end; // function TD4WCMServer.WSetPatientFilter

//******************************************* TD4WCMServer.WGetPatientsData ***
// Get Patients data given portion from patients set defined by WSetPatientFilter
//
//     Parameters
// AStartNum - starting patient
// ACount    - patients number
// AData     - selected patients serialized attributes as bytes array
// Result    - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that Patients data
//                                        portion was get
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetPatientsData( AStartNum, ACount: Integer;
                                        out AData: OleVariant ): HResult;
var
  BinData : Variant;
  RCount : Integer;
  N_Dump:   TN_OneStrProcObj;   // Dump one String to Dump1 channel
begin
  N_Dump1Str( format( 'WEB >> WGetPatientsData Start S=%d C=%d',
                              [AStartNum,ACount] ) );
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  SBuf.Init();
  RCount := K_CMPutPatientsAttrsToSBuf( K_CMWEBPatWhereSQL, K_CMWEBPatOrderSQL,
                                        AStartNum, ACount, SBuf );
  N_Dump := N_Dump2Str;
  if RCount = -1 then
  begin
    N_Dump := N_Dump1Str;
    Result := E_UNEXPECTED;
  end
  else
  begin
    DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
    AData := BinData;
  end;
  N_Dump( format( 'WEB >> WGetPatientsData Fin RCount=%d RDataSize=%d',
                       [RCount, SBuf.OfsFree] ) );

end; // function TD4WCMServer.WGetPatientsData

//******************************************** TD4WCMServer.WGetPatObjAttrs ***
// Get given Patient media objects serialized attributes as bytes array
//
//     Parameters
// APatientID - current patient ID
// ASelCode   - select media objects code:
//#F
//  0 - select only actual media objects
//  1 - select marked as deleted media objects
//  2 - select all media objects
//#/F
// Result   - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that media objects
//                                        attributes were get
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// S_FAILS                        (0x1) - Patient with given ID is absent
//                                        or has no media objects
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetPatObjAttrs( APatientID, ASelCode: Integer;
                                       out AData: OleVariant ): HResult;
var
  BinData : Variant;
  SL : TStringList;
begin
  N_Dump1Str( format( 'WEB >> WGetPatObjAttrs Start PatID=%d', [APatientID] ) );
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  SL := TStringList.Create();
  SL.Add( 'ObjID' );
  SL.Add( 'ObjType' );
  SL.Add( 'MediaTypeID' );
  SL.Add( 'Diagn' ); // !!!
  SL.Add( 'TeethLeftSet' );
  SL.Add( 'TeethRightSet' );
  SL.Add( 'TeethSetCapt' );
  SL.Add( 'DateTaken' );
  SL.Add( 'PixWidth' );
  SL.Add( 'PixHeight' );
  SL.Add( 'VideoDuration' );
  SL.Add( 'VideoFExt' );
  SL.Add( 'ObjStudyID' );
  SBuf.Init();

  try
    if not K_CMPutSlidesAttrsToSBuf( APatientID, ASelCode, SL, SBuf ) then
    begin
      N_Dump1Str( 'WEB >> WGetPatObjAttrs Connection Error' );
      Result := E_UNEXPECTED;
    end
    else
    begin
      N_Dump1Str ( format( 'WEB >> WGetPatObjAttrs RDataSize=%d'#13#10'%s',
                           [SBuf.OfsFree, SL.Text] ) );
      if SBuf.OfsFree > 0 then
      begin
        DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
        AData := BinData;
      end
      else
        Result := S_FALSE;
    end;
  except
    on E: Exception do
    begin
      N_Dump1Str('WEB >> WGetPatObjAttrs  >> ' + E.Message);
      Result := E_UNEXPECTED;
    end;
  end;

  SL.Free();
  N_Dump2Str( 'WEB >> WGetPatObjAttrs Fin' );
end; // function TD4WCMServer.WGetPatObjAttrs

//*************************************** TD4WCMServer.WGetSlidesThumbFiles ***
// Get given slides Thubnails files
//
//     Parameters
// APatientID - patient ID for Thubnails data access optimization (if <= 0) then
//              no optimization is used
// ASlideIDs  - Tab delimited string with Slides IDs
// AThumbPath - Path for resulting Thumbnails Files
// Result     - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that media objects
//                                        attributes were get
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// WCMS_FilesPath_Invalid  (0xA0000002) - AThumbPath is absent
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetSlidesThumbFiles( APatientID: Integer;
                           const ASlideIDs, AThumbPath: WideString ): HResult;
var
  SL : TStringList;
  ResCount : Integer;
  ThumbPath : string;
begin
  ThumbPath := IncludeTrailingPathDelimiter( N_WideToString(AThumbPath) );
  N_Dump1Str( format( 'WEB >> WGetSlidesThumbFiles Start PatID=%d >> %s', [APatientID,ThumbPath] ) );

  Result := WCheckFilesPath( ThumbPath );
  if Result <> S_OK then Exit;

  SL := TStringList.Create;
  SL.Delimiter := #9;
  SL.DelimitedText := N_WideToString( ASlideIDs );

  try
    ResCount := K_CMPutSlideThumbnailsToFiles( SL, 2, ThumbPath );
    if ResCount < 0 then
    begin
      N_Dump1Str( 'WEB >> WGetSlidesThumbFiles Connection Error' );
      Result := E_UNEXPECTED;
    end;
  except
    on E: Exception do
    begin
      N_Dump1Str('WEB >> WGetSlidesThumbFiles  >> ' + E.Message);
      Result := E_UNEXPECTED;
    end;
  end;

  SL.Free();
  N_Dump2Str( 'WEB >> WGetSlidesThumbFiles Fin' );

end; // function TD4WCMServer.WGetSlidesThumbFiles

//***************************************** TD4WCMServer.WSetCurrentPatient ***
// Set Current Patient for Patient media objects access optimization
//
//     Parameters
// APatientID - current patient ID
// Result   - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that current Patient
//                                        was set
// S_FAILS                        (0x1) - Patient with given ID is absent
//                                        or has no media objects
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WSetCurrentPatient( APatientID: Integer ): HResult;
var
  SetContexResult : Integer;
begin
  N_Dump1Str( format( 'WEB >> WSetCurrentPatient Start PatID=%d', [APatientID] ) );
  Result := WCheckReady( );
  if Result <> S_OK then Exit;

  SetContexResult := K_CMSetCurSessionContext( APatientID, K_CMWEBCOMProviderID,
                                               K_CMWEBCOMLocationID );
  if SetContexResult < 0 then
  begin
  end;
  K_CMWEBCOMPatientID := APatientID;
  N_Dump2Str( 'WEB >> WSetCurrentPatient Fin' );
end; // function TD4WCMServer.WSetCurrentPatient

//***************************************** TD4WCMServer.WGetSlideImageFile ***
// Get given slide Image file
//
//     Parameters
// ASlideID   - Source Slide ID
// AMaxWidth  - Media Object resulting file maximal width, if =0 then use image
//              original width, else Image real width will be defined automatically
//              not larger then AMaxWidth and Image original width using
//              original aspect and AMaxHeight and set on output
// AMaxHeight - Media Object resulting file maximal height, if =0 then use image
//              original height, else Image real height will be defined automatically
//              not larger then AMaxHeight and Image original height using
//              original aspect and AMaxWidth and set on output
// AFileFormat - resulting Image file format code (0 - jpg, 1 - png, 2 - tif, 3 - bmp)
// AFileCont   - resulting Image file content code:
//#F
//  0 - last image state with annotations
//  1 - last image state without annotations
//  2 - image original state without annotations
//#/F
// AFileView   - resulting Image file content view effects:
//#F
//  0 - without visual effects
//  1 - with emboss effect
//  2 - with colorize effect
//#/F
// AFilePath   - Path for resulting Image File
// Result      - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that given media object
//                                        file was created
// S_FALSE                        (0x1) - Given Media Object data couldn't be access now
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WSetCurrentUser
// WCMS_FilesPath_Invalid  (0xA0000002) - AFilePath is absent
// WCMS_Patient_Absent     (0xA0000003) - Patient was not set by WSetCurrentPatient
// WCMS_Wrong_Object_Type  (0xA0000004) - Given Media Object is not Image
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetSlideImageFile(ASlideID: Integer; var AMaxWidth,
  AMaxHeight: OleVariant; AFileFormat, AViewCont, AViewConv: Integer;
  const AFilePath: WideString): HResult;
var
  FilePath : string;
  Slide : TN_UDCMBSlide;
  PSlide : TN_PCMSlide;
  MaxWidth, MaxHeight : Integer;
begin
  FilePath := IncludeTrailingPathDelimiter( N_WideToString(AFilePath) );
  MaxWidth  := AMaxWidth;
  MaxHeight := AMaxHeight;
  N_Dump1Str( format( 'WEB >> WGetSlideImageFile Start SlideID=%d %dx%d F=%d C=%d V=%d >> %s',
                      [ASlideID,MaxWidth,MaxHeight,AFileFormat,AViewCont,
                       AViewConv,FilePath] ) );

  Result := WCheckFilesPath( FilePath );
  if Result <> S_OK then Exit;

  Result := WGetSlideByID( ASlideID, 0, Slide, PSlide );
  if Result <> S_OK then Exit;

  Result := WPrepSlideDIBFile( FilePath, Slide, MaxWidth, MaxHeight,
                                  AFileFormat, AViewCont, AViewConv );
  AMaxWidth  := MaxWidth;
  AMaxHeight := MaxHeight;

  N_Dump2Str ( format( 'WEB >> WGetSlideImageFile Fin %dx%d',
                       [MaxWidth,MaxHeight] ) );
end; // function TD4WCMServer.WGetSlideImageFile

//***************************************** TD4WCMServer.WGetSlideStudyFile ***
// Get given slide Study file and active areas info
//
//     Parameters
// ASlideID   - Source Slide ID
// AMaxWidth  - Media Object resulting file maximal width, if =0 then use image
//              original width, else Image real width will be defined automatically
//              not larger then AMaxWidth and Image original width using
//              original aspect and AMaxHeight and set on output
// AMaxHeight - Media Object resulting file maximal height, if =0 then use image
//              original height, else Image real height will be defined automatically
//              not larger then AMaxHeight and Image original height using
//              original aspect and AMaxWidth and set on output
// AFileFormat - resulting Image file format code (0 - jpg, 1 - png, 2 - tif, 3 - bmp)
// AFilePath   - Path for resulting Study File
// AItemsRefs  - Study items active zones serialized info as bytes array
// Result      - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that given media object
//                                        file was created
// S_FALSE                        (0x1) - Given Media Object data couldn't be access now
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WCMSSetCurrentUser
// WCMS_FilesPath_Invalid  (0xA0000002) - AFilePath is absent
// WCMS_Patient_Absent     (0xA0000003) - Patient was not set by WSetCurrentPatient
// WCMS_Wrong_Object_Type  (0xA0000004) - Given Media Object is not Study
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetSlideStudyFile(ASlideID: Integer; var AMaxWidth,
  AMaxHeight: OleVariant; AFileFormat: Integer;
  const AFilePath: WideString; out AItemsRefs: OleVariant): HResult;
var
  FilePath : string;
  Slide : TN_UDCMBSlide;
  PSlide : TN_PCMSlide;
  BinData : Variant;
  MapRoot : TN_UDBase;
  ItemSlide : TN_UDBase;
  Item : TN_UDBase;
  i, j : Integer;
  ObjRefArr : TK_WCMSStudyObjRefArr;
  PixRect : TRect;
  MaxWidth, MaxHeight : Integer;
begin
  FilePath := IncludeTrailingPathDelimiter( N_WideToString(AFilePath) );
  MaxWidth  := AMaxWidth;
  MaxHeight := AMaxHeight;
  N_Dump1Str( format( 'WEB >> WGetSlideStudyFile Start SlideID=%d %dx%d F=%d >> %s',
                      [ASlideID,MaxWidth,MaxHeight,AFileFormat,FilePath] ) );

  Result := WCheckFilesPath( FilePath );
  if Result <> S_OK then Exit;

  Result := WGetSlideByID( ASlideID, 2, Slide, PSlide );
  if Result <> S_OK then Exit;

  Result := WPrepSlideDIBFile( FilePath, Slide, MaxWidth, MaxHeight,
                                  AFileFormat, 0, 0 );
  if Result <> S_OK then Exit;

  // prepare study map structure
  MapRoot := Slide.GetMapRoot();
  SetLength( ObjRefArr, MapRoot.DirLength() );
  j := 0;
  for i := 0 to MapRoot.DirHigh() do
  begin
    Item := MapRoot.DirChild(i);
    ItemSlide := K_CMStudyGetOneSlideByItem( Item );
    if ItemSlide = nil then Continue;
    with ObjRefArr[j] do
    begin
//      PixRect := TN_UDCMBSlide(ItemSlide).GetThumbnail().CompOuterPixRect;
      PixRect := TN_UDPanel(Item.DirChild(0)).CompOuterPixRect;
      WCMSRefLeft   := PixRect.Left;
      WCMSRefTop    := PixRect.Top;
      WCMSRefRight  := PixRect.Right;
      WCMSRefBottom := PixRect.Bottom;
      WCMSRefMObjID := StrToInt(ItemSlide.ObjName); // Media Object ID
    end;
    Inc(j);
  end;

  // Serialized Items Refs
  SBuf.Init();
  SBuf.AddRowInt( j );
  for i := 0 to j - 1 do
    with ObjRefArr[i] do
    begin
      SBuf.AddRowInt( WCMSRefLeft );
      SBuf.AddRowInt( WCMSRefTop );
      SBuf.AddRowInt( WCMSRefRight );
      SBuf.AddRowInt( WCMSRefBottom );
      SBuf.AddRowInt( WCMSRefMObjID );
    end;


  DynArrayToVariant(BinData, SBuf.GetDataToBArray(), TypeInfo(TK_BArray));
  AItemsRefs := BinData;
  AMaxWidth  := MaxWidth;
  AMaxHeight := MaxHeight;

  N_Dump2Str ( format( 'WEB >> WGetSlideStudyFile Fin %dx%d ICount=%d RDataSize=%d',
                       [MaxWidth,MaxHeight,j, SBuf.OfsFree] ) );
end; // function TD4WCMServer.WGetSlideStudyFile

//***************************************** TD4WCMServer.WGetSlideVideoFile ***
// Get given slide Study file and active areas info
//
//     Parameters
// ASlideID   - Source Slide ID
// AFilePath  - Path for resulting VideoFile File
// Result     - Returns function COM resulting code.
//#F
// S_OK                           (0x0) - Indicates that given media object
//                                        file was created
// S_FALSE                        (0x1) - Given Media Object is absent
// S_NOTREADY                     (0x2) - Indicates that CMS server is not ready,
//                                        should try again later
// WCMS_Init_Error         (0xA0000000) - CMS Initialization Error
// WCMS_User_Absent        (0xA0000001) - User was not set by WCMSSetCurrentUser
// WCMS_FilesPath_Invalid  (0xA0000002) - AFilePath is absent
// WCMS_Patient_Absent     (0xA0000003) - Patient was not set by WSetCurrentPatient
// WCMS_Wrong_Object_Type  (0xA0000004) - Given Media Object is not Video
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - COM Server is not responded
// E_UNEXPECTED            (0x8000FFFF) - Indicates unexpected COM error.
//#/F
//
function TD4WCMServer.WGetSlideVideoFile( ASlideID: Integer;
                                          const AFilePath: WideString ): HResult;
var
  FilePath : string;
  Slide : TN_UDCMBSlide;
  PSlide : TN_PCMSlide;
  VFName : string;
  CopyRes : Integer;
begin
  FilePath := IncludeTrailingPathDelimiter( N_WideToString(AFilePath) );
  N_Dump1Str( format( 'WEB >> WGetSlideVideoFile Start SlideID=%d >> %s',
                      [ASlideID,FilePath] ) );

  Result := WCheckFilesPath( FilePath );
  if Result <> S_OK then Exit;

  Result := WGetSlideByID( ASlideID, 1, Slide, PSlide );
  if Result <> S_OK then Exit;

  VFName :=  TN_UDCMSlide(Slide).GetMediaFileName( K_CMEDAccess.SlidesClientMediaRootFolder +
                                                    Slide.GetFilesPathSegm() );
  CopyRes := -1;
  if K_CMPrepSlideMediaFile( TN_UDCMSlide(Slide), VFName, false ) then
  begin
    CopyRes := K_CopyFile( VFName, FilePath + 'F' + Slide.ObjName + PSlide.CMSDB.MediaFExt );
    if CopyRes >= 3 then
    begin
      Result := E_UNEXPECTED;
      N_Dump1Str( format( 'WEB >> WGetSlideVideoFile File Copy Error ResCode=%d', [CopyRes] ) );
      Exit;
    end;
  end
  else
    Result := E_UNEXPECTED; // some problems with files storage

  N_Dump2Str( 'WEB >> WGetSlideVideoFile Fin Copy ResCode=' + IntToStr(CopyRes) );
end; // function TD4WCMServer.WGetSlideVideoFile

///////////////
// SIR #27353
function TTypedComObjectFactoryCMSCloud.GetProgID: string;
begin
  Result := inherited GetProgID;
  if Result <> '' then Result := Result + K_CMSSBuildNum; //K_CMSSBuildNum is CMS version number, this makes ProgID unique for each CMS version
end; // function TTypedComObjectFactoryCMSCloud.GetProgID
// SIR #27353
///////////////

initialization
{}
//  TAutoObjectFactory.Create(ComServer, TD4WCMServer, Class_D4WCMServer,
//  TTypedComObjectFactory.Create( ComServer, TD4WCMServer, Class_D4WCMServer,
//                                 ciSingleInstance, tmApartment );

///////////////
// SIR #27353
  TTypedComObjectFactoryCMSCloud.Create( ComServer, TD4WCMServer, Class_D4WCMServer,
                                    ciSingleInstance, tmApartment );
// SIR #27353
///////////////
//    ciMultiInstance, tmApartment);

  ComServer.UIInteractive := false; // Server Aplication Termination by User Permition
  K_CMD4WComServerExists := TRUE;   // Is needed to check if ComServer exists in current Application Build

{}
end.
