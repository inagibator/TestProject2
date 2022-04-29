unit K_CMDCM;

interface
uses Graphics, Classes, Controls, // Windows, Types,
  K_UDT1, K_CM0, K_CMDCMGLibW,
  N_Types, N_Gra2;

type TK_CMDCMDMedia = packed record
  DDMediaUID  : string; // Info for DICOM attribute SOP Instance UID (0008,0018)
  DDMediaDate : string; // Info for DICOM attribute Content Date (0008,0023) - string format yyymmdd
  DDMediaTime : string; // Info for DICOM attribute Content Time (0008,0033) - string format hhnnss
  DDMediaADate: string; // Info for DICOM attribute Acquisition Date (0008,0022) - string format yyymmdd
  DDMediaATime: string; // Info for DICOM attribute Acquisition Time (0008,0032) - string format hhnnss
  DDMediaKVP  : string; // Info for DICOM attribute KVP (0018,0060) - Peak kilo voltage output of the x-ray generator used (string of chars representing an Integer in base 10)
  DDMediaExpTime      : string; // Info for DICOM attribute ExposureTime (0018,1150) - Time of x-ray exposure in msec (string of chars representing an Integer in base 10)
  DDMediaTubeCurrent  : string; // Info for DICOM attribute X-Ray Tube Current (0018,1151) - X-Ray Tube Current in mA (string of chars representing an Integer in base 10)
  DDMediaRadiationDose: string; // Info for DICOM attribute Radiation Dose ()
  DDMediaExpCMode     : string; // Info for DICOM attribute Exposure Control Mode ()
  DDMediaNum  : string; // Info for DICOM attribute Instance Number (0020,0013) - image series number (always 1 from CMS)
  DDMediaFile : string;
end;
type TK_PCMDCMDMedia = ^TK_CMDCMDMedia;
type TK_CMDCMDMediaArr = array of TK_CMDCMDMedia;

type TK_CMDCMDSeries = record
  DDSeriesUID  : string; // Info for DICOM attribute Series Instance UID (0020,000E)
  DDSeriesDate : string; // Info for DICOM attribute Series Date (0008,0021) - string format yyymmdd
  DDSeriesTime : string; // Info for DICOM attribute Series Time (0008,0031) - string format hhnnss
  DDSeriesMod  : string; // Info for DICOM attribute Series Modality (0008,0060) - 2 chars string - possible values in CMS : 'CR', 'PX', 'XC'
  DDSeriesNum  : string; // Info for DICOM attribute Series Number (0020,0011) - series number in study (always 1 from CMS)
  DDSeriesDescr: string; // Info for DICOM attribute Series Description (,)
  DDMedias     : TK_CMDCMDMediaArr; // image attributes array
  DDMediasCount: Integer; // Number of real Media Info in DDMedias
end;
type TK_PCMDCMDSeries = ^TK_CMDCMDSeries;
type TK_CMDCMDSeriesArr = array of TK_CMDCMDSeries;

type TK_CMDCMDStudy = packed record
// Info for DICOM attribute Referring Physician's Name (0008,0090)
  DDStudyUID   : string; // Info for DICOM attribute Study Instance UID (0020,000D)
  DDStudyDate  : string; // Info for DICOM attribute Study Date (0008,0020) - string format yyymmdd
  DDStudyTime  : string; // Info for DICOM attribute Study Time (0008,0030) - string format hhnnss
  DDStudyDescr : string; // Info for DICOM attribute Study Description
  DDStudyID    : string; // Info for DICOM attribute Study ID (0020,0010)
  DDSeries     : TK_CMDCMDSeriesArr; // Series attributes array
  DDSeriesCount: Integer; // Number of real Series Info in DDMedias
end;
type TK_PCMDCMDStudy = ^TK_CMDCMDStudy;
type TK_CMDCMDStudyArr = array of TK_CMDCMDStudy;

type TK_CMDCMDPatient = packed record
// Info for DICOM attribute Patient's Name (0010,0010)
  DDPatSurname   : string; // Patient Surname
  DDPatFirstname : string; // Patient First name
  DDPatMiddle    : string; // Patient Middle
  DDPatTitle     : string; // Patient title
  DDPatDOB       : string; // Info for DICOM attribute Patient's Birth Date (0010,0030) - string format yyyymmdd
  DDPatSex       : string; // Info for DICOM attribute Patient's Sex (0010,0040) - single char string: "Ì" - male, "F" - female
  DDPatID        : string; // Info for DICOM attribute Patient ID (0010,0020)
  DDStudies      : TK_CMDCMDStudyArr; // Studies attributes array
  DDStudiesCount : Integer; // Number of real Studies Info in DDMedias
end;
type TK_PCMDCMDPatient = ^TK_CMDCMDPatient;
type TK_CMDCMDPatientArr = array of TK_CMDCMDPatient;

{
function K_CMDCMExportOneSlideTest( ASlide : TN_UDCMSlide; AExpDIB : TN_DIBObj; AFName : string ): Integer;
function K_CMDCMImportOneSlideTest( AFName : string ) : Integer;
}
function K_CMDCMGetTagPatientNameValue( APCMSPatData : TK_PCMSAPatientDBData ) : string;
function K_CMDCMDefineSlideSOPClassUID( ASlide : TN_UDCMSlide; AColorFlag : Boolean ) : string;
function K_CMDCMInitSlideModality( ASlide : TN_UDCMSlide; AColorFlag : Boolean ) : string;
function K_CMDCMExportDCMSlideToDCMInst( out ADI : TK_HDCMINST; AExpPixels : Boolean; ASlide: TN_UDCMSlide;
                                AExpDIB : TN_DIBObj; const ADCMAFName : string;
                                DCMStudyUID, DCMStudySID : string; DCMStudyTS : TDateTime;
                                DCMSeriesUID, DCMSeriesSID : string; DCMSeriesTS : TDateTime;
                                DCMSlideUID, DCMSlideSID : string; DCMSlideTS, DCMSlideAcqTS : TDateTime ) : Integer;
function K_CMDCMExportDCMSlideToFile( ASlide: TN_UDCMSlide;
                                AExpDIB : TN_DIBObj; const AFName, ADCMAFName : string;
                                const DCMStudyUID, DCMStudySID : string; DCMStudyTS : TDateTime;
                                const DCMSeriesUID, DCMSeriesSID : string; DCMSeriesTS : TDateTime;
                                const DCMSlideUID, DCMSlideSID : string; DCMSlideTS, DCMSlideAcqTS : TDateTime ) : Integer;
function K_CMDGetDIBAttrs( ADI : TK_HDCMINST;
                           out ABufLength : Integer; out AWidth, AHeight : TN_UInt2;
                           out APixFmt: TPixelFormat; out AExPixFmt: TN_ExPixFmt;
                           out ANumBits: TN_UInt2; ADumpProc : TN_OneStrProcObj = nil ) : Integer;
function K_CMDCMDumpFile( const ADCMFName, AImgFName : string ) : Integer;
function K_CMDCMImportDIB( ADCMFName : string; var AImpDIB : TN_DIBObj; ADI : TK_HDCMINST = nil ) : Integer;

type TK_CMDCMDPatientCheckProc = function ( const APatSurname, APatFirstName, APatCardNum : string;
                                              APatDOB : TDate ) : Integer of object;
function K_CMCreateDCMUDTree( var AUDRoot : TN_UDBase; APPats: TK_PCMDCMDPatient; APatsCount: Integer;
                              APatCheckProc : TK_CMDCMDPatientCheckProc; AProgressProcObj : TN_OneStrProcObj ): Integer;
function K_CMBuildImpDataFromDICOMDIR( const ADCMDIRFName : string; out AImpData : TK_CMDCMDPatientArr ) : Integer;
function K_CMBuildImpDataFromFFList( AFNames : TStrings; out AImpData : TK_CMDCMDPatientArr  ) : Integer;
function K_CMDCMServerTestConnection( const AIP : string; APort : Integer; const AETScp, AETScu : string; ATimeOut : Integer; ASkipEcho : Boolean = FALSE ) : Boolean;
function K_DCMStoreExport( APSlide: TN_PUDCMSlide; ASlidesCount: Integer; AExpPath : string;
                           out AlreadyExistsCount, AOutOfMemoryCount, AErrCount : Integer ) : Integer;
function K_DCMCreateSlideFromInstanceHandle( ADI : TK_HDCMINST; ACurPatID : Integer; const AFName : string ) : TN_UDCMSlide;

type TK_CMDCMStoreFilesThread = class(TThread)
  DCMSSRVIP, DCMSSRVAETScp, DCMSSRVAETScu : WideString;
  DCMSSRVPort : Integer;

  DCMSSrcFName, DCMSDstFName, DCMSPath : string;
  DCMSHSRV : TK_HSRV;
  procedure Execute; override;
  procedure DCMSSyncDump1Str(  );
  procedure DCMSSyncDump2Str(  );
  procedure DCMSSyncGetDCMSettings();
  function  DCMSFileCopyCreate( ) : Boolean;
  procedure DCMSRemoveProcFile( );
  function  DCMSFileCopyStore( ) : Boolean;
  procedure DCMSSyncSetEventStatus();
private
  DCMSDumpStr : string;
  DCMSWBuf : WideString;
  DCMWSC  : WideString;
  DCMDI : TK_HDCMINST;
  DCMStoreRes : Boolean;
  DCMObjName : string;
  DCMPatID : string;
  DCM3DSlice : string;
  DCMSFStream, DCMSRFStream : TFileStream;
  DCMInstUID, DCMClassUID : string;
protected
public
end;

var K_CMDCMStoreFilesThread : TK_CMDCMStoreFilesThread;
    K_CMDCMStoreAutoFlag : Boolean;
    K_CMDCMStoreAutoSkipFlag : Boolean;
    K_CMDCMStoreCommitmentFlag : Boolean;
implementation

uses SysUtils, DateUtils,
     K_CLib0, K_UDT2, K_RImage, K_Script1, K_UDConst, K_CM1, K_FCMDCMSetup,
     N_Lib0, N_Lib1, N_ImLib;

const UID_SOPClass : WideString = '1.2.840.10008.5.1.4.1.1.1.3'; //  Digital_Intra_Oral_X_Ray_Image_Storage_For_Presentation

//*********************************************** K_CMDCMExportOneSlideTest ***
// Export one slide to DICOM
//
//     Parameters
// ASlide  - Slide to export
// AExpDIB - Slide DIB to Export
// AFName  - export file name
// Result - Returns resulting code. 0 - all OK, 1 - is 3D or video
//
function K_CMDCMExportOneSlideTest( ASlide: TN_UDCMSlide;
                                    AExpDIB : TN_DIBObj; AFName : string ) : Integer;
var
  DI : TK_HDCMINST;
  DBUID : string;
  UID_Study, UID_Series, UID_Inst : WideString;
  PatientDBData : TK_CMSAPatientDBData;
  ProviderDBData : TK_CMSAProviderDBData;
  LocationDBData : TK_CMSALocationDBData;

  StudiesUID : TN_SArray;
  StudiesSID : TN_SArray;
  StudiesTS : TN_DArray;

  DCMFNames : TN_SArray;
  AcqTS : TN_DArray;

  WStr : Widestring;
  Str : string;
  PSlide : TN_PCMSlide;
  WDbl : Double;
  WUInt2 : TN_UInt2;
  PixBuffer : TN_BArray;
  PixBufLength : Integer;
  TransferSyntax : WideString;


  procedure AddValueString( ATag : TN_UInt4; const AName : string; const AValue : string; ASkipDump : Boolean = FALSE );
  var
    SStr : string;
  begin
    if ASkipDump then
      SStr := format( '%s=????', [AName] )
    else
      SStr := format( '%s=%s', [AName, AValue] );
    N_Dump2Str( SStr );
    WStr := N_StringToWide( AValue );
    if 0 <> K_DCMGLibW.DLAddValueString( DI, ATag, @WStr[1] ) then
      N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLAddValueString %x %s', [ATag, SStr] ) );
  end; // procedure AddValueString

  procedure AddValueUint16( ATag : TN_UInt4; const AName : string; const AValue : TN_UInt2 );
  var
    SStr : string;
  begin
    SStr := format( '%s=%d', [AName, AValue] );
    N_Dump2Str( SStr );
   	if 0 <> K_DCMGLibW.DLAddValueUint16( DI, ATag, AValue ) then
      N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLAddValueUint16 %x %s', [ATag, SStr] ) );
  end; // procedure AddValueUint16

begin
  N_Dump2Str( 'K_CMDCMExportOneSlideTest start' );

  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  Result := 1;
  PSlide := ASlide.P;
  with  PSlide^ do
  if (cmsfIsMediaObj in CMSDB.SFlags) or
     (cmsfIsImg3DObj in CMSDB.SFlags) or
     (TN_UDCMBSlide(ASlide) is TN_UDCMStudy) then Exit;

  Result := 0;

  with K_CMEDAccess, K_DCMGLibW, PSlide^ do
  begin
    DBUID := K_GetDICOMUIDComponentFromGUID31( EDAGetDBUID() );

    EDASAGetOnePatientInfo( IntToStr( CurPatID ), @PatientDBData, [K_cmsagiSkipLock] );
    EDASAGetOneProviderInfo( IntToStr( CurProvID ), @ProviderDBData, [K_cmsagiSkipLock] );
    EDASAGetOneLocationInfo( IntToStr( CurLocID ), @LocationDBData, [K_cmsagiSkipLock] );
    SetLength( StudiesSID, 1 );
    SetLength( StudiesTS, 1 );

    EDAGetDCMSlideUIDAttrs( @ASlide, 1, DCMFNames, StudiesUID, StudiesSID, StudiesTS, AcqTS );
    EDAGetDCMStudiesUIDAttrs( @ASlide, 1, DCMFNames, StudiesUID, StudiesSID, StudiesTS );
    EDAGetDCMSeriesUIDAttrs( @ASlide, 1, DCMFNames, StudiesUID, StudiesSID, StudiesTS );

    EDAGetDCMStudiesAttrs( @ASlide, 1, StudiesSID, StudiesTS );

//  UID_Study
    UID_Study  := N_StringToWide( format( '%s.%s.1.%s', [CentaurSoftwareUID,DBUID,StudiesSID[0]] ) );
    N_Dump2Str( 'StudyInstanceUid=' + N_WideToString(UID_Study) );
    UID_Series := N_StringToWide( format( '%s.%s.2.%s', [CentaurSoftwareUID,DBUID,ASlide.ObjName] ) );
    N_Dump2Str( 'SeriesInstanceUid=' + N_WideToString(UID_Series) );
    UID_Inst   := N_StringToWide( format( '%s.%s.3.%s', [CentaurSoftwareUID,DBUID,ASlide.ObjName] ) );
    N_Dump2Str( 'SopInstanceUid=' + N_WideToString(UID_Inst) );
    N_Dump2Str( 'SopClassUid=' + N_WideToString(UID_SOPClass) );

    DI := DLCreateInstance( @UID_Study[1], @UID_Series[1], @UID_Inst[1], @UID_SOPClass[1] );
    with PatientDBData do
    begin
      AddValueString( K_CMDCMTPatientsName, 'PatientsName', K_CMDCMGetTagPatientNameValue( @PatientDBData ), not CMS_LogsCtrlAll );
//      AddValueString( K_CMDCMTPatientsName, 'PatientsName', format( '%s^%s^%s^%s', [APSurname,APFirstname,APMiddle,APTitle] ) );

      Str := APCardNum;
      if Str = '' then
      begin
        if CurPatID >= 0 then
          Str := IntToStr(CurPatID)
        else
          Str := IntToStr( 990100 - CurPatID )
      end;
      AddValueString( K_CMDCMTPatientId, 'PatientId', Str );

      if Length(APGender) < 1 then
        APGender := K_CMGetPatientGenderTextByTitle( APTitle );
      AddValueString( K_CMDCMTPatientsSex, 'PatientsSex', Copy( APGender, 1, 1 ), not CMS_LogsCtrlAll );

      if APDOB <> 0 then
      begin
        AddValueString( K_CMDCMTPatientsBirthDate, 'PatientsBirthDate', K_DateTimeToStr( APDOB, 'yyyymmdd' ), not CMS_LogsCtrlAll );
      end
      else
        AddValueString( K_CMDCMTPatientsBirthDate, 'PatientsBirthDate', '19000101', not CMS_LogsCtrlAll );
    end; // with PatientDBData do

   	AddValueString(K_CMDCMTAccessionNumber, 'AccessionNumber', '3456-7' );

    AddValueString( K_CMDCMTStudyDate, 'StudyDate', K_DateTimeToStr( StudiesTS[0], 'yyyymmdd' ) );
    AddValueString( K_CMDCMTStudyTime, 'StudyTime', K_DateTimeToStr( StudiesTS[0], 'hhnnss' ) );

    Str := K_DateTimeToStr( CMSDTTaken, 'yyyymmdd' );
    AddValueString( K_CMDCMTAcquisitionDate, 'AcquisitionDate', Str );

    AddValueString( K_CMDCMTContentDate, 'ContentDate', Str );

    Str := K_DateTimeToStr( CMSDTTaken, 'hhnnss' );
    AddValueString( K_CMDCMTAcquisitionTime, 'AcquisitionTime', Str );

    AddValueString( K_CMDCMTContentTime, 'ContentTime', Str );

    AddValueString( K_CMDCMTInstitutionName, 'InstitutionName', LocationDBData.ALName );

    // StudyDescription should be taken from MWL
    AddValueString( K_CMDCMTStudyDescription, 'StudyDescription', StudiesSID[0] );
    AddValueString( K_CMDCMTStudyId, 'StudyId', StudiesSID[0] );
{
    Str := CMSDB.DCMModality;
    if Str = '' then
    begin
      if not (cmsfGreyScale in CMSDB.SFlags) then
        Str := K_CMSlideDefDCMModColorXC
      else
      begin
        Str := K_CMSlideDefDCMModXRayIO;
//                  Modality := K_CMSlideDefDCMModXRay;
        if CMSMediaType = 4 then
          Str := K_CMSlideDefDCMModXRayPan;
      end;
    end
    else
    if Str = K_CMSlideDefDCMModXRayCR then
      Str := K_CMSlideDefDCMModXRayIO;
}
    Str := K_CMDCMInitSlideModality( ASlide, not (cmsfGreyScale in CMSDB.SFlags) );

    AddValueString( K_CMDCMTModality, 'Modality', Str );

    if (Str = K_CMSlideDefDCMModXRayIO) or (Str = K_CMSlideDefDCMModXRayPan) then
    begin // Add All X-Ray DICOM attributes
      if CMSDB.DCMKVP <> 0 then
      begin
        AddValueString( K_CMDCMTKvp, 'KVP', FloatToStr(CMSDB.DCMKVP) );
      end;

      if CMSDB.DCMExpTime <> 0 then
      begin
        AddValueString( K_CMDCMTExposureTime, 'ExposureTime', IntToStr(CMSDB.DCMExpTime) );
      end;

      if CMSDB.DCMTubeCur <> 0 then
      begin
        AddValueString( K_CMDCMTXrayTubeCurrent, 'TubeCurrent', IntToStr(CMSDB.DCMTubeCur) );
      end;

      if CMSDB.DCMRDose <> 0 then
      begin
        AddValueString( K_CMDCMTImageAndFluroscopyAreaDoseProduct, 'RadiationDose', FloatToStr(CMSDB.DCMRDose) );
      end;

      if CMSDB.DCMECMode <> 0 then
      begin
        Str := 'MANUAL';
        if CMSDB.DCMECMode <> 1 then
          Str := 'AUTOMATIC';
        AddValueString( K_CMDCMTExposureControlMode, 'ExposureControlMode', Str );
      end;
    end; // Add All X-Ray DICOM attributes

    if CMSDB.DCMMnf <> '' then
      AddValueString( K_CMDCMTManufacturer, 'Manufacturer', CMSDB.DCMMnf );

    if CMSDB.DCMMnfMN <> '' then
      AddValueString( K_CMDCMTManufacturersModelName, 'ManufacturersModelName', CMSDB.DCMMnfMN );

    AddValueString( K_CMDCMTPresentationIntentType, 'PresentationIntentType', 'FOR PRESENTATION' );

    // in future should be taken from Slide SeriesID field
    AddValueString( K_CMDCMTSeriesNumber, 'SeriesNumber', '1' );

    WDbl := Round(72 * 100 / 2.54) / 1000;
    if CMSDB.SFlags * [cmsfProbablyCalibrated,cmsfUserCalibrated,cmsfAutoCalibrated] <> [] then
      WDbl := CMSDB.PixPermm;
    Str := FloatToStr( 1/WDbl );
    AddValueString( K_CMDCMTPixelSpacing, 'PixelSpacing', format( '%s\%s',[Str,Str] ) );

    // in future should be taken from Slide SlideID field
    AddValueString( K_CMDCMTInstanceNumber, 'InstanceNumber', '1' );

    AddValueString( K_CMDCMTImageType, 'ImageType', 'DERIVED\PRIMARY' );

    AddValueUint16( K_CMDCMTColumns, 'Columns', AExpDIB.DIBSize.X );

    AddValueUint16( K_CMDCMTRows, 'Rows', AExpDIB.DIBSize.Y );


    WUInt2 := 8;
    PixBufLength := 1;
    if AExpDIB.DIBExPixFmt = epfGray16 then
    begin
      PixBufLength := 2;
      WUInt2 := 16;
    end;
    AddValueUint16( K_CMDCMTBitsAllocated, 'BitsAllocated', WUInt2 );

    AddValueUint16( K_CMDCMTBitsStored, 'BitsStored', WUInt2 );

    AddValueUint16( K_CMDCMTHighBit, 'HighBit', AExpDIB.DIBNumBits - 1 );

    WUInt2 := 1;
    if AExpDIB.DIBPixFmt = pf24bit then
      WUInt2 := 3;

    PixBufLength := PixBufLength * WUInt2 * AExpDIB.DIBSize.X * AExpDIB.DIBSize.Y;

    AddValueUint16( K_CMDCMTSamplesPerPixel, 'SamplesPerPixel', WUInt2 );

    AddValueUint16( K_CMDCMTPixelRepresentation, 'PixelRepresentation', 0 );

    if AExpDIB.DIBPixFmt = pf24bit then
    begin
      AddValueUint16( K_CMDCMTPlanarConfiguration, 'PlanarConfiguration', 0 );
    end;

    AddValueString( K_CMDCMTNumberOfFrames, 'NumberOfFrames', '1' );

    Str := 'RGB';
    if AExpDIB.DIBPixFmt <> pf24bit then
      Str := 'MONOCHROME2';
    AddValueString( K_CMDCMTPhotometricInterpretation, 'PhotometricInterpretation', Str );

    SetLength( PixBuffer, PixBufLength );
    N_DIBPixToDICOMPix( TN_BytesPtr(@PixBuffer[0]), AExpDIB );

    N_Dump2Str( 'AddImageData before' );
    WUInt2 := DLAddImageData( DI, @PixBuffer[0], PixBufLength );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLAddImageData %d', [WUInt2] ) );

    TransferSyntax := K_CMDCMUID_JPEGProcess14SV1TransferSyntax;
    N_Dump2Str( 'ChangeTransferSyntax before' );
    WUInt2 := DLChangeTransferSyntax( DI, @TransferSyntax[1], 100 );
    if 0 <> WUInt2 then
     N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLChangeTransferSyntax [%s] %d', [TransferSyntax, WUInt2] ) );

    N_Dump2Str( 'SaveInstance before ' + AFName );
    WStr := N_StringToWide( AFName );
    WUInt2 := DLSaveInstance( DI, @WStr[1], @TransferSyntax[1] );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLSaveInstance [%s] %d', [TransferSyntax, WUInt2] ) );

    N_Dump2Str( 'DeleteDcmObject before ');
    WUInt2 := DLDeleteDcmObject( DI );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMExportOneSlideTest >> wrong DLDeleteDcmObject %d', [WUInt2] ) );
  end;
  N_Dump2Str( 'K_CMDCMExportOneSlideTest fin' );

end; // function K_CMDCMExportOneSlideTest

//*********************************************** K_CMDCMImportOneSlideTest ***
// Import one slide from DICOM Test
//
//     Parameters
// AFName  - export file name
// Result - Returns resulting code. 0 - all OK, 1 - is 3D or video
//
function K_CMDCMImportOneSlideTest( AFName : string ) : Integer;
var
  DI : TK_HDCMINST;
  WStr : Widestring;
  WUInt2 : TN_UInt2;
  WBuf : WideString;
  sz : Integer;
  IsNil : Integer;

  IWidth, IHeight: TN_UInt2;
  IPixFmt: TPixelFormat;
  IExPixFmt: TN_ExPixFmt;
  INumBits: TN_UInt2;
  IDIB : TN_DIBObj;
  IH : Integer;
  WFName : string;
  PixBuffer : TN_BArray;
  PixBufLength : Integer;

const BufLeng = 1024;

begin

  N_Dump1Str( 'K_CMDCMImportOneSlideTest start ' +  AFName );
  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( 'K_CMDCMDumpFile >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  with K_DCMGLibW do
  begin
    WStr := N_StringToWide( AFName );
    DI := DLCreateInstanceFromFile( @WStr[1], 255 );
    if DI <> nil then
    begin
      SetLength( WBuf, BufLeng );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyInstanceUid' )
      else
        N_Dump2Str( 'StudyInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesInstanceUid' )
      else
        N_Dump2Str( 'SeriesInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SopInstanceUid' )
      else
        N_Dump2Str( 'SopInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSopClassUid, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SopClassUid' )
      else
        N_Dump2Str( 'SopClassUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsName, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsName' )
      else
        N_Dump2Str( 'PatientsName=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientId, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientId' )
      else
        N_Dump2Str( 'PatientID=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsSex, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsSex' )
      else
        N_Dump2Str( 'PatientsSex=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsBirthDate, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsBirthDate' )
      else
        N_Dump2Str( 'PatientsBirthDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );


      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDate, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyDate' )
      else
        N_Dump2Str( 'StudyDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyTime, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyTime' )
      else
        N_Dump2Str( 'StudyTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDate, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesDate' )
      else
        N_Dump2Str( 'SeriesDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesTime, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesTime' )
      else
        N_Dump2Str( 'SeriesTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionDate, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString AcquisitionDate' )
      else
        N_Dump2Str( 'AcquisitionDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTContentDate, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString ContentDate' )
      else
        N_Dump2Str( 'ContentDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString AcquisitionTime' )
      else
        N_Dump2Str( 'AcquisitionTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTContentTime, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString ContentTime' )
      else
        N_Dump2Str( 'ContentTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTInstitutionName, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString InstitutionName' )
      else
        N_Dump2Str( 'InstitutionName=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyId, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyId' )
      else
        N_Dump2Str( 'StudyId=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTModality, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString Modality' )
      else
        N_Dump2Str( 'Modality=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

{
      if CMSDB.DCMKVP <> 0 then
      begin
        AddValueString( K_CMDCMTKvp, 'KVP', FloatToStr(CMSDB.DCMKVP) );
      end;

      if CMSDB.DCMExpTime <> 0 then
      begin
        AddValueString( K_CMDCMTExposureTime, 'ExposureTime', IntToStr(CMSDB.DCMExpTime) );
      end;

      if CMSDB.DCMTubeCur <> 0 then
      begin
        AddValueString( K_CMDCMTXrayTubeCurrent, 'TubeCurrent', IntToStr(CMSDB.DCMTubeCur) );
      end;

      if CMSDB.DCMRDose <> 0 then
      begin
        AddValueString( K_CMDCMTImageAndFluroscopyAreaDoseProduct, 'RadiationDose', FloatToStr(CMSDB.DCMRDose) );
      end;

      if CMSDB.DCMECMode <> 0 then
      begin
        Str := 'MANUAL';
        if CMSDB.DCMECMode <> 1 then
          Str := 'AUTOMATIC';
        AddValueString( K_CMDCMTExposureControlMode, 'ExposureControlMode', Str );
      end;
    end; // Add All X-Ray DICOM attributes
    if CMSDB.DCMMnf <> '' then
      AddValueString( K_CMDCMTManufacturer, 'Manufacturer', CMSDB.DCMMnf );

    if CMSDB.DCMMnfMN <> '' then
      AddValueString( K_CMDCMTManufacturersModelName, 'ManufacturersModelName', CMSDB.DCMMnfMN );
}

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPresentationIntentType, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PresentationIntentType' )
      else
        N_Dump2Str( 'PresentationIntentType=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesNumber' )
      else
        N_Dump2Str( 'SeriesNumber=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPixelSpacing, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PixelSpacing' )
      else
        N_Dump2Str( 'PixelSpacing=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTImagerPixelSpacing, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString ImagePixelSpacing' )
      else
        N_Dump2Str( 'ImagePixelSpacing=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString InstanceNumber' )
      else
        N_Dump2Str( 'InstanceNumber=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

      IWidth := 0;
      if 0 <> DLGetValueUint16( DI, K_CMDCMTColumns, @IWidth, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 Columns' )
      else
        N_Dump2Str( 'Columns=' + IntToStr(IWidth) );

      IHeight := 0;
      if 0 <> DLGetValueUint16( DI, K_CMDCMTRows, @IHeight, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 Rows' )
      else
        N_Dump2Str( 'Rows=' + IntToStr(IHeight) );

      if 0 <> DLGetValueUint16( DI, K_CMDCMTBitsStored, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 BitsStored' )
      else
        N_Dump2Str( 'BitsStored=' + IntToStr(WUInt2) );

      if 0 <> DLGetValueUint16( DI, K_CMDCMTBitsAllocated, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 BitsAllocated' )
      else
        N_Dump2Str( 'BitsAllocated=' + IntToStr(WUInt2) );

      IPixFmt := pfDevice;
      IExPixFmt := epfBMP;
      PixBufLength := 1;
      if WUInt2 = 16 then
      begin
        PixBufLength := 2;
        IPixFmt := pfCustom;
        IExPixFmt := epfGray16;
      end;

      if 0 <> DLGetValueUint16( DI, K_CMDCMTHighBit, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 HighBit' )
      else
        N_Dump2Str( 'HighBit=' + IntToStr(WUInt2) );
      INumBits := WUInt2 + 1;

      if 0 <> DLGetValueUint16( DI, K_CMDCMTSamplesPerPixel, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 SamplesPerPixel' )
      else
        N_Dump2Str( 'SamplesPerPixel=' + IntToStr(WUInt2) );

      if WUInt2 = 3 then
        IPixFmt := pf24bit
      else
      begin
        if IPixFmt <> pfCustom then
        begin
          IPixFmt := pfCustom;
          IExPixFmt := epfGray8;
        end;
      end;
      PixBufLength := PixBufLength * WUInt2 * IWidth * IHeight;

      if 0 <> DLGetValueUint16( DI, K_CMDCMTPixelRepresentation, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 PixelRepresentation' )
      else
        N_Dump2Str( 'PixelRepresentation=' + IntToStr(WUInt2) );

      if IPixFmt = pf24bit then
      begin
        if 0 <> DLGetValueUint16( DI, K_CMDCMTPlanarConfiguration, @WUInt2, @isNil ) then
          N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 PlanarConfiguration' )
        else
          N_Dump2Str( 'PlanarConfiguration=' + IntToStr(WUInt2) );
      end;

      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTNumberOfFrames, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString NumberOfFrames' )
      else
        N_Dump2Str( 'NumberOfFrames=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
{
      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PhotometricInterpretation' )
      else
        N_Dump2Str( 'PhotometricInterpretation=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
}
      N_Dump2Str( 'GetImageData before' );
      if PixBufLength > 0 then
      begin
        SetLength( PixBuffer, PixBufLength );
        WUInt2 := DLGetImageData( DI, @PixBuffer[0], PixBufLength );
        if 0 <>	WUInt2 then
          N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetImageData' )
        else
        begin
          IDIB := TN_DIBObj.Create( IWidth, IHeight, IPixFmt, -1, IExPixFmt, INumBits );
          N_DICOMPixToDIBPix( TN_BytesPtr(@PixBuffer[0]), IDIB );
          WFName := ChangeFileExt( AFName, '_fromDCM.png' );
          IH := N_ImageLib.ILCreateFile( WFName, N_ILFmtPNG ); // Write to File
          N_ImageLib.ILWriteImage( IH, @IDIB.DIBInfo, IDIB.PRasterBytes );
          N_ImageLib.ILClose( IH );
          IDIB.Free;
        end;
      end
      else
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong ImageLength' );
    end // if DI <> nil then
    else
    begin
      Result := 1;
      N_Dump1Str( 'K_CMDCMDumpFile >> CreateInstanceFromFile error' );
    end;

    N_Dump2Str( 'DLDeleteDcmObject before' );
    WUInt2 := DLDeleteDcmObject( DI );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMDumpFile >> wrong DLDeleteDcmObject %d', [WUInt2] ) );

  end; // with K_DCMGLibW do
  N_Dump2Str( 'K_CMDCMImportOneSlideTest fin' );

end; // function K_CMDCMImportOneSlideTest

//******************************************* K_CMDCMGetTagPatientNameValue ***
// Get DICOM PatientName tag value from CMSuite Patient Data
//
//     Parameters
// APCMSPatData  - pointer to CMSuite Patient Data
// Result - Returns resulting DICOM PatientName tag value
//
function K_CMDCMGetTagPatientNameValue( APCMSPatData : TK_PCMSAPatientDBData ) : string;
begin
  with APCMSPatData^ do
    Result := format( '%s^%s^%s^%s', [APSurname,APFirstname,APMiddle,APTitle] );
end; // function K_CMDCMGetTagPatientNameValue

//******************************************* K_CMDCMDefineSlideSOPClassUID ***
// Define Slide SOPClass UID by slide and color image flag
//
//     Parameters
// ASlide     - given slide
// AColorFlag - slide image is color flag
// Result - Returns DICOM SOPClass UID
//
function K_CMDCMDefineSlideSOPClassUID( ASlide : TN_UDCMSlide; AColorFlag : Boolean ) : string;
var
  Str : string;
begin
  with K_CMEDAccess, K_DCMGLibW, ASlide, ASlide.P^ do
  begin
    Str := CMSDB.DCMModality;
    if AColorFlag then
    begin
      if (Str = '') then
      begin // Modality is not define
        if (CMSMediaType = 0) or (CMSMediaType = 3) then
          Result := K_CMDCMUID_VLEndoscopic_SOPClass // MediaType is unasighned or Intraoral Camera
        else
        if (CMSMediaType = 5) then // Digital Photo's
          Result := K_CMDCMUID_SecondaryCapture_SOPClass
        else // Documents or (not Intraoral Camera and not Digital Photo’s)
        if (CMSMediaType = 6) or ((CMSMediaType <> 3) and (CMSMediaType <> 5)) then
          Result := K_CMDCMUID_SecondaryCapture_SOPClass;
      end
      else
      if (Str = K_CMSlideDefDCMModColorXC) then
        Result := K_CMDCMUID_VLPhotographic_SOPClass    // Modality XC
      else if (Str = K_CMSlideDefDCMModColorES) then
        Result := K_CMDCMUID_VLEndoscopic_SOPClass      // Modality ES
      else if (Str = K_CMSlideDefDCMModColorGM) then
        Result := K_CMDCMUID_VLMicroscopic_SOPClass     // Modality GM
      else
        Result := K_CMDCMUID_SecondaryCapture_SOPClass; // Modality not XC,ES,GM
    end   // end of Color Images
    else
    begin // Grey Images
      if Str = '' then
      begin // Modality  is not define
        if (CMSMediaType = 0) then
          Result := K_CMDCMUID_DigitalXRay_SOPClass // MediaType is unasighned
        else
        if (CMSMediaType = 2) then // Intraoral
          Result := K_CMDCMUID_DigitalIntraOralXRay_SOPClass
        else
        if (CMSMediaType = 6) then  // Documents
          Result := K_CMDCMUID_SecondaryCapture_SOPClass
        else
          // not Intraoral and not Documents
        if (CMSMediaType <> 2) and (CMSMediaType <> 6) then
          Result := K_CMDCMUID_DigitalXRay_SOPClass;
      end
      else
      if Str = K_CMSlideDefDCMModXRayIO then
        Result := K_CMDCMUID_DigitalIntraOralXRay_SOPClass // Modality = IO
      else
      if Str = K_CMSlideDefDCMModXRayPan then
        Result := K_CMDCMUID_DigitalXRay_SOPClass // Modality = PX
      else
      if Str = K_CMSlideDefDCMModXRayDX then
        Result := K_CMDCMUID_DigitalXRay_SOPClass // Modality = DX
      else
      if Str = K_CMSlideDefDCMModXRayCR then
        Result := K_CMDCMUID_ComputedRadiography_SOPClass // Modality = CR
      else
      if Str = K_CMSlideDefDCMModXRayCT then
        Result := K_CMDCMUID_CT_SOPClass // Modality = CT
      else
      if Str = K_CMSlideDefDCMModXRayOT then
        Result := K_CMDCMUID_SecondaryCapture_SOPClass // Modality = OT
      else
        Result := K_CMDCMUID_SecondaryCapture_SOPClass;  // Modality <> PX and Modality <> IO
    end; // end of Grey Images
  end; // with K_CMEDAccess, K_DCMGLibW, ASlide, PSlide^ do
end; // function K_CMDCMDefineSlideSOPClassUID

//************************************************ K_CMDCMInitSlideModality ***
// Init Slide DICOM Modality by slide and slide image color flag
//
//     Parameters
// ASlide     - given slide
// AColorFlag - slide image is color flag
// Result - Returns DICOM Modality
//
function K_CMDCMInitSlideModality( ASlide : TN_UDCMSlide; AColorFlag : Boolean ) : string;
begin
{
  '"1=Cephalometric","2=Intraoral","3=Intraoral Camera",' +
  '"4=Panoramic","5=Digital Photo’s","6=Documents"';
}
  with K_CMEDAccess, K_DCMGLibW, ASlide, ASlide.P^ do
  begin
    Result := CMSDB.DCMModality;
    if Result <> '' then Exit;

    if AColorFlag then
    begin
      if (CMSMediaType = 0) or (CMSMediaType = 3) then
        Result := K_CMSlideDefDCMModColorES // MediaType is unasighned or Intraoral Camera
      else
      if (CMSMediaType = 5) then // Digital Photo's
        Result := K_CMSlideDefDCMModXRayOT
      else // Documents or (not Intraoral Camera and not Digital Photo’s)
      if (CMSMediaType = 6) or ((CMSMediaType <> 3) and (CMSMediaType <> 5)) then
        Result := K_CMSlideDefDCMModXRayOT;
    end   // end of Color Images
    else
    begin // Grey Images
      if (CMSMediaType = 0) then
        Result := K_CMSlideDefDCMModXRayDX // MediaType is unasighned
      else
      if (CMSMediaType = 2) then // Intraoral
        Result := K_CMSlideDefDCMModXRayIO
      else
      if (CMSMediaType = 6) then  // Documents
        Result := K_CMSlideDefDCMModXRayOT
      else
        // not Intraoral and not Documents
      if (CMSMediaType <> 2) and (CMSMediaType <> 6) then
        Result := K_CMSlideDefDCMModXRayDX;
    end; // end of Grey Images
  end; // with K_CMEDAccess, K_DCMGLibW, ASlide, PSlide^ do
end; // function K_CMDCMInitSlideModality

//****************************************** K_CMDCMExportDCMSlideToDCMInst ***
// Export one slide to DICOM
//
//     Parameters
// ADI        - resulting DICOM instance descriptor
// AExpPixels - export pixels flag
// ASlide  - Slide to export
// AExpDIB - Slide DIB to Export
// ADCMAFName - MediaSuite storage file with DICOM attributes
// DCMStudyUID  - DICOM study UID
// DCMStudySID  - DICOM study ID
// DCMStudyTS   - DICOM study timestamp
// DCMSeriesUID - DICOM series UID
// DCMSeriesSID - DICOM series ID
// DCMSeriesTS  - DICOM series timestamp
// DCMSlideUID  - DICOM slide UID
// DCMSlideSID  - DICOM slide ID
// DCMSlideTS   - DICOM slide timestamp
// DCMSlideAcqTS  - DICOM slide acquisition timestamp
// Result - Returns resulting code.
//          0 - all OK,
//          1 - is 3D or video,
//          2 - error while opening file with DCM attrs
//          3 - error while attribute is added
//          4 - error while pixel added
//          5 - error while transfer syntax changed
//          > 100 - library initialization error
//
function K_CMDCMExportDCMSlideToDCMInst( out ADI : TK_HDCMINST; AExpPixels : Boolean; ASlide: TN_UDCMSlide;
                                AExpDIB : TN_DIBObj; const ADCMAFName : string;
                                DCMStudyUID, DCMStudySID : string; DCMStudyTS : TDateTime;
                                DCMSeriesUID, DCMSeriesSID : string; DCMSeriesTS : TDateTime;
                                DCMSlideUID, DCMSlideSID : string; DCMSlideTS, DCMSlideAcqTS : TDateTime ) : Integer;
var
  UID_Study, UID_Series, UID_Inst : WideString;
  PatientDBData : TK_CMSAPatientDBData;
//  ProviderDBData : TK_CMSAProviderDBData;
  LocationDBData : TK_CMSALocationDBData;


  WStr : Widestring;
  Str : string;
  PSlide : TN_PCMSlide;
  WDbl : Double;
  WUInt1, WUInt2, WUInt3 : TN_UInt2;
  SamplesForPixel : TN_UInt2;
  PixBuffer : TN_BArray;
  PixBufLength : Integer;
  TransferSyntax: WideString;
  SOPClass : WideString;
//  SOPClassS : string;

  WBuf : WideString;
  sz : Integer;
  IsNil : Integer;

  ResCode : Integer;
  CPatID  : Integer;

const BufLeng = 1024;


label CreateCMSuiteAttrs;

//////////////////////
// Define SOPClass
//
{
  '"1=Cephalometric","2=Intraoral","3=Intraoral Camera",' +
  '"4=Panoramic","5=Digital Photo’s","6=Documents"';
  K_CMSlideDefDCMModColorXC = 'XC'; // DICOM Modality for color
  K_CMSlideDefDCMModXRay    = 'CR'; // obsolete DICOM Modality for X-Ray Computer Radiographi
  K_CMSlideDefDCMModXRayPan = 'PX'; // DICOM Modality for X-Ray Panoramic
  K_CMSlideDefDCMModIO      = 'IO'; // DICOM Modality for X-Ray instead of CR - Computer Radiographi

}
{
  procedure DefineSOPClassUID();
  begin
    with K_CMEDAccess, K_DCMGLibW, ASlide, PSlide^ do
    begin
      Str := CMSDB.DCMModality;
      if AExpDIB.DIBPixFmt = pf24bit then
      begin
        if (Str = '') then
        begin // Modality is not define
          if (CMSMediaType = 0) or (CMSMediaType = 3) then
            SOPClass := K_CMDCMUID_VLEndoscopic_SOPClass // MediaType is unasighned or Intraoral Camera
          else
          if (CMSMediaType = 5) then // Digital Photo's
            SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass
          else // Documents or (not Intraoral Camera and not Digital Photo’s)
          if (CMSMediaType = 6) or ((CMSMediaType <> 3) and (CMSMediaType <> 5)) then
            SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass;
        end
        else
        if (Str = K_CMSlideDefDCMModColorXC) then
          SOPClass := K_CMDCMUID_VLPhotographic_SOPClass    // Modality XC
        else
          SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass; // Modality not XC
      end   // end of Color Images
      else
      begin // Grey Images
        if Str = '' then
        begin // Modality  is not define
          if (CMSMediaType = 0) then
            SOPClass := K_CMDCMUID_DigitalXRay_SOPClass // MediaType is unasighned
          else
          if (CMSMediaType = 2) then // Intraoral
            SOPClass := K_CMDCMUID_DigitalIntraOralXRay_SOPClass
          else
          if (CMSMediaType = 6) then  // Documents
            SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass
          else
            // not Intraoral and not Documents
          if (CMSMediaType <> 2) and (CMSMediaType <> 6) then
            SOPClass := K_CMDCMUID_DigitalXRay_SOPClass;
        end
        else
        if Str = K_CMSlideDefDCMModXRayIO then
          SOPClass := K_CMDCMUID_DigitalIntraOralXRay_SOPClass // Modality = IO
        else
        if Str = K_CMSlideDefDCMModXRayPan then
          SOPClass := K_CMDCMUID_DigitalXRay_SOPClass // Modality = PX
        else
          SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass;  // Modality <> PX and Modality <> IO
      end; // end of Grey Images
    end; // with K_CMEDAccess, K_DCMGLibW, ASlide, PSlide^ do
  end; // procedure DefineSOPClassUID
//
// Define SOPClass
//////////////////////
}
  procedure AddValueString( ATag : TN_UInt4; const AName : string; const AValue : string; ASkipDump : Boolean = FALSE );
  var
    SStr : string;
    PW: PWidechar;
  const WC: WideChar = #0;

  begin
    if ASkipDump then
      SStr := format( '%s=????', [AName] )
    else
      SStr := format( '%s=%s', [AName, AValue] );
    N_Dump2Str( SStr );
    PW := @WC;
    if AValue <> '' then
    begin
      WStr := N_StringToWide( AValue );
      PW := @WStr[1];
    end;
    if 0 <> K_DCMGLibW.DLAddValueString( ADI, ATag, PW ) then
    begin
      ResCode := 3;
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> wrong DLAddValueString %x %s', [ATag, SStr] ) );
    end;
  end; // procedure AddValueString

  procedure AddValueUint16( ATag : TN_UInt4; const AName : string; const AValue : TN_UInt2 );
  var
    SStr : string;
  begin
    SStr := format( '%s=%d', [AName, AValue] );
    N_Dump2Str( SStr );
   	if 0 <> K_DCMGLibW.DLAddValueUint16( ADI, ATag, AValue ) then
    begin
      ResCode := 3;
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> wrong DLAddValueUint16 %x %s', [ATag, SStr] ) );
    end;
  end; // procedure AddValueUint16

begin
  N_Dump2Str( 'K_CMDCMExportDCMSlideToDCMInst start' );

  ADI := nil;
  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  Result := 1;
  PSlide := ASlide.P;

  with K_CMEDAccess, K_DCMGLibW, ASlide, PSlide^ do
  begin
    CPatID := CMSPatID;
    if (cmsfIsMediaObj in CMSDB.SFlags) or
       (cmsfIsImg3DObj in CMSDB.SFlags) or
       (TN_UDCMBSlide(ASlide) is TN_UDCMStudy) then Exit; // precaution

    Result := 0;
    ResCode := 0;

    // Slide have DICOM attrs file
    Str := '';
    if ADCMAFName <> '' then
    begin

      N_Dump2Str( 'Load from ' + ADCMAFName );
      WStr := N_StringToWide( ADCMAFName );
      ADI := DLCreateInstanceFromFile( @WStr[1], 255);
      if ADI = nil then
      begin
        Result := 2;
        N_Dump1Str( 'K_CMDCMExportDCMSlideToDCMInst >> load DCM attrs error' );
        goto CreateCMSuiteAttrs;
      end;

    // Parse SlideUID
      with K_CMEDAccess.TmpStrings do
      begin
        Clear;
        Delimiter := '.';
        DelimitedText := DCMSlideUID;
// deb       Str := '0';
// deb       if (Strings[Count-3] = '3') then
        Str := Strings[Count-2];
      end;
{}
      sz := BufLeng;
      SetLength( WBuf, sz );
      if Str <> '0' then
      begin // Slide was changed after import
        AddValueString( K_CMDCMTSopInstanceUid, 'SopInstanceUid', DCMSlideUID );
//        SOPClass := K_CMDCMUID_SecondaryCapture_SOPClass;
//        SOPClassS := N_WideToString(SOPClass);
//        AddValueString( K_CMDCMTSopClassUid, 'SopClassUid', SOPClassS );
//        AddValueString( K_CMDCMTMediaStorageSopClassUid, 'MSSopClassUid', SOPClassS );
      end   // Slide was changed after import
      else
      begin // Slide was not changed after import
//        DefineSOPClassUID();
//        SOPClassS := N_WideToString(SOPClass);
//        AddValueString( K_CMDCMTSopClassUid, 'SopClassUid', SOPClassS );
//        AddValueString( K_CMDCMTMediaStorageSopClassUid, 'MSSopClassUid', SOPClassS );

        // Get SopInstanceUID
        if 0 <>	 DLGetValueString( ADI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
        begin
          DCMSlideUID := '???';
          N_Dump1Str( 'K_CMDCMExportDCMSlideToDCMInst >> wrong SopInstanceUID' );
        end
        else
          DCMSlideUID := N_WideToString( Copy( WBuf, 1, sz ) );
      end; // Slide was not changed after import

      // Get StudyInstanceUid
      sz := BufLeng;
      if 0 <>	 DLGetValueString( ADI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
      begin
        DCMStudyUID := '???';
        N_Dump1Str( 'K_CMDCMExportDCMSlideToDCMInst >> wrong StudyInstanceUid' );
      end
      else
        DCMStudyUID := N_WideToString( Copy( WBuf, 1, sz ) );

      // Get SeriesInstanceUid
      sz := BufLeng;
      if 0 <>	 DLGetValueString( ADI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
      begin
        DCMSeriesUID := '???';
        N_Dump1Str( 'K_CMDCMExportDCMSlideToDCMInst >> wrong SeriesInstanceUid' );
      end
      else
        DCMSeriesUID := N_WideToString( Copy( WBuf, 1, sz ) );

      // Get SopClassUID
      if 0 <>	 DLGetValueString( ADI, K_CMDCMTSopClassUid, @WBuf[1], @sz, @isNil) then
      begin
        SOPClass := '???';
        N_Dump1Str( 'K_CMDCMExportDCMSlideToDCMInst >> wrong SopClassUID' );
      end
      else
        SOPClass := N_WideToString( Copy( WBuf, 1, sz ) );

      N_Dump1Str( 'SlideToDCMInst (SRC DCM):'  + ADCMAFName + #13#10 +
      'StudyInstanceUid=' + DCMStudyUID + #13#10 +
      'SeriesInstanceUid=' + DCMSeriesUID + #13#10 +
      'SopInstanceUid=' + DCMSlideUID + #13#10 +
      'SopClassUid=' + N_WideToString(SOPClass) );
{}
    end   //  if ADCMAFName <> '' then
    else
    begin //  if ADCMAFName = '' then

CreateCMSuiteAttrs: //*****
//??      EDASAGetOnePatientInfo( IntToStr( CurPatID ), @PatientDBData, [K_cmsagiSkipLock] );
//      EDASAGetOneProviderInfo( IntToStr( CurProvID ), @ProviderDBData, [K_cmsagiSkipLock] );
//      EDASAGetOneLocationInfo( IntToStr( CurLocID ), @LocationDBData, [K_cmsagiSkipLock] );
      EDASAGetOnePatientInfo( IntToStr( CPatID ), @PatientDBData, [K_cmsagiSkipLock] );
//      EDASAGetOneProviderInfo( IntToStr( CMSProvIDModified ), @ProviderDBData, [K_cmsagiSkipLock] );
      EDASAGetOneLocationInfo( IntToStr( CMSLocIDModified ), @LocationDBData, [K_cmsagiSkipLock] );

      SOPClass := K_CMDCMDefineSlideSOPClassUID( ASlide, not (cmsfGreyScale in CMSDB.SFlags) );
//      SOPClass := '1.2.840.10008.5.1.4.1.1.1.3'; //  Digital_Intra_Oral_X_Ray_Image_Storage_For_Presentation

  //  UID_Study
//      N_Dump2Str( 'StudyInstanceUid=' + DCMStudyUID );
//      N_Dump2Str( 'SeriesInstanceUid=' + DCMSeriesUID );
//      N_Dump2Str( 'SopInstanceUid=' + DCMSlideUID );
//      N_Dump2Str( 'SopClassUid=' + N_WideToString(SOPClass) );

      N_Dump1Str( 'SlideToDCMInst:'  + #13#10 +
      'StudyInstanceUid=' + DCMStudyUID + #13#10 +
      'SeriesInstanceUid=' + DCMSeriesUID + #13#10 +
      'SopInstanceUid=' + DCMSlideUID + #13#10 +
      'SopClassUid=' + N_WideToString(SOPClass) );

      UID_Study  := N_StringToWide( DCMStudyUID );
      UID_Series := N_StringToWide( DCMSeriesUID );
      UID_Inst   := N_StringToWide( DCMSlideUID );

      ADI := DLCreateInstance( @UID_Study[1], @UID_Series[1], @UID_Inst[1], @SOPClass[1] );
      with PatientDBData do
      begin
        AddValueString( K_CMDCMTPatientsName, 'PatientsName', K_CMDCMGetTagPatientNameValue( @PatientDBData ), not CMS_LogsCtrlAll );
//        AddValueString( K_CMDCMTPatientsName, 'PatientsName', format( '%s^%s^%s^%s', [APSurname,APFirstname,APMiddle,APTitle] ) );

        Str := APCardNum;
        if Str = '' then
        begin
//??          if CurPatID >= 0 then
          if CPatID >= 0 then
            Str := IntToStr(CurPatID)
          else
            Str := IntToStr( 990100 - CPatID )
//            Str := IntToStr( 990100 - CurPatID )
        end;
        AddValueString( K_CMDCMTPatientId, 'PatientId', Str );

        if Length(APGender) < 1 then
          APGender := K_CMGetPatientGenderTextByTitle( APTitle );
        AddValueString( K_CMDCMTPatientsSex, 'PatientsSex', Copy( APGender, 1, 1 ), not CMS_LogsCtrlAll );

        if APDOB <> 0 then
        begin
          AddValueString( K_CMDCMTPatientsBirthDate, 'PatientsBirthDate', K_DateTimeToStr( APDOB, 'yyyymmdd' ), not CMS_LogsCtrlAll );
        end
        else
          AddValueString( K_CMDCMTPatientsBirthDate, 'PatientsBirthDate', '19000101', not CMS_LogsCtrlAll );
      end; // with PatientDBData do

      AddValueString(K_CMDCMTAccessionNumber, 'AccessionNumber', '' );

      AddValueString( K_CMDCMTStudyDate, 'StudyDate', K_DateTimeToStr( DCMStudyTS, 'yyyymmdd' ) );
      AddValueString( K_CMDCMTStudyTime, 'StudyTime', K_DateTimeToStr( DCMStudyTS, 'hhnnss' ) );

      AddValueString( K_CMDCMTSeriesDate, 'SeriesDate', K_DateTimeToStr( DCMSeriesTS, 'yyyymmdd' ) );
      AddValueString( K_CMDCMTSeriesTime, 'SeriesTime', K_DateTimeToStr( DCMSeriesTS, 'hhnnss' ) );

      AddValueString( K_CMDCMTAcquisitionDate, 'AcquisitionDate', K_DateTimeToStr( DCMSlideAcqTS, 'yyyymmdd' ) );
      AddValueString( K_CMDCMTAcquisitionTime, 'AcquisitionTime', K_DateTimeToStr( DCMSlideAcqTS, 'hhnnss' ) );

      AddValueString( K_CMDCMTInstitutionName, 'InstitutionName', LocationDBData.ALName );

      // StudyDescription should be taken from MWL
//      AddValueString( K_CMDCMTStudyDescription, 'StudyDescription', CMSSourceDescr );
      AddValueString( K_CMDCMTStudyDescription, 'StudyDescription', '' );
      AddValueString( K_CMDCMTStudyId, 'StudyId', DCMStudySID );
{
      Str := CMSDB.DCMModality;
      if Str = '' then
      begin
        if not (cmsfGreyScale in CMSDB.SFlags) then
          Str := K_CMSlideDefDCMModColorXC
        else
        begin
          Str := K_CMSlideDefDCMModXRayIO;
  //                  Modality := K_CMSlideDefDCMModXRay;
          if CMSMediaType = 4 then
            Str := K_CMSlideDefDCMModXRayPan;
        end;
      end
      else
      if Str = K_CMSlideDefDCMModXRayCR then
        Str := K_CMSlideDefDCMModXRayIO;
}

      Str := K_CMDCMInitSlideModality( ASlide, not (cmsfGreyScale in CMSDB.SFlags) );
      AddValueString( K_CMDCMTModality, 'Modality', Str );

      if (Str = K_CMSlideDefDCMModXRayIO) or (Str = K_CMSlideDefDCMModXRayPan) then
      begin // Add All X-Ray DICOM attributes
        if CMSDB.DCMKVP <> 0 then
        begin
          AddValueString( K_CMDCMTKvp, 'KVP', FloatToStr(CMSDB.DCMKVP) );
        end;

        if CMSDB.DCMExpTime <> 0 then
        begin
          AddValueString( K_CMDCMTExposureTime, 'ExposureTime', IntToStr(CMSDB.DCMExpTime) );
        end;

        if CMSDB.DCMTubeCur <> 0 then
        begin
          AddValueString( K_CMDCMTXrayTubeCurrent, 'TubeCurrent', IntToStr(CMSDB.DCMTubeCur) );
        end;

        if CMSDB.DCMRDose <> 0 then
        begin
          AddValueString( K_CMDCMTImageAndFluroscopyAreaDoseProduct, 'RadiationDose', FloatToStr(CMSDB.DCMRDose) );
        end;

        if CMSDB.DCMECMode <> 0 then
        begin
          Str := 'MANUAL';
          if CMSDB.DCMECMode <> 1 then
            Str := 'AUTOMATIC';
          AddValueString( K_CMDCMTExposureControlMode, 'ExposureControlMode', Str );
        end;
      end; // Add All X-Ray DICOM attributes

      if CMSDB.DCMMnf <> '' then
        AddValueString( K_CMDCMTManufacturer, 'Manufacturer', CMSDB.DCMMnf );

      if CMSDB.DCMMnfMN <> '' then
        AddValueString( K_CMDCMTManufacturersModelName, 'ManufacturersModelName', CMSDB.DCMMnfMN );

      AddValueString( K_CMDCMTPresentationIntentType, 'PresentationIntentType', 'FOR PRESENTATION' );

      AddValueString( K_CMDCMTSeriesNumber, 'SeriesNumber', DCMSeriesSID );

      AddValueString( K_CMDCMTInstanceNumber, 'InstanceNumber', DCMSlideSID );

      AddValueString( K_CMDCMTContentDate, 'ContentDate', K_DateTimeToStr( DCMSlideTS, 'yyyymmdd' ) );
      AddValueString( K_CMDCMTContentTime, 'ContentTime', K_DateTimeToStr( DCMSlideTS, 'hhnnss' ) );
    end; //  if ADCMAFName = '' then


    // Add/Replace other Image Attributes
    AddValueString( K_CMDCMTNumberOfFrames, 'NumberOfFrames', '1' );
    AddValueString( K_CMDCMTImageType, 'ImageType', 'DERIVED\PRIMARY' );

    WDbl := Round(72 * 100 / 2.54) / 1000;
    if CMSDB.SFlags * [cmsfProbablyCalibrated,cmsfUserCalibrated,cmsfAutoCalibrated] <> [] then
      WDbl := CMSDB.PixPermm;
//    Str := FloatToStr( 1/WDbl );
    WDbl := Round(1 / WDbl * 10000) / 10000;
    Str := FloatToStr( WDbl );

    AddValueString( K_CMDCMTPixelSpacing, 'PixelSpacing', format( '%s\%s',[Str,Str] ) );

    AddValueUint16( K_CMDCMTColumns, 'Columns', AExpDIB.DIBSize.X );

    AddValueUint16( K_CMDCMTRows, 'Rows', AExpDIB.DIBSize.Y );

    if not AExpPixels then Exit;

    WUInt1 := 8;
    WUInt2 := 8;
    WUInt3 := 7;
    PixBufLength := 1;
    if AExpDIB.DIBExPixFmt = epfGray16 then
    begin
      PixBufLength := 2;
      WUInt1 := 16;
      WUInt2 := 16;
      WUInt3 := 15;
{ 2021-05-28 }
//      if AExpDIB.DIBNumBits < 16 then
//      begin
//        WUInt2 := AExpDIB.DIBNumBits;
//        WUInt3 := AExpDIB.DIBNumBits - 1;
//      end;
{}
    end;
    AddValueUint16( K_CMDCMTBitsAllocated, 'BitsAllocated', WUInt1 );

    AddValueUint16( K_CMDCMTBitsStored, 'BitsStored', WUInt2 );

    AddValueUint16( K_CMDCMTHighBit, 'HighBit', WUInt3  );

    SamplesForPixel := 1;
    if AExpDIB.DIBPixFmt = pf24bit then
      SamplesForPixel := 3;

    AddValueUint16( K_CMDCMTSamplesPerPixel, 'SamplesPerPixel', SamplesForPixel );

    AddValueUint16( K_CMDCMTPixelRepresentation, 'PixelRepresentation', 0 );

    if AExpDIB.DIBPixFmt = pf24bit then
    begin
      AddValueUint16( K_CMDCMTPlanarConfiguration, 'PlanarConfiguration', 0 );
    end;

    Str := 'RGB';
    if AExpDIB.DIBPixFmt <> pf24bit then
    begin
      sz := BufLeng;
      SetLength( WBuf, sz );
      if 0 <>	 DLGetValueString( ADI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @isNil) then
      begin
        sz := 0;
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PhotometricInterpretation' )
      end
      else
      begin // use existing DI PhotometricInterpretation
        Str := '';
        N_Dump2Str( 'Use PhotometricInterpretation=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
      end;
      if sz = 0 then
      begin
        Str := 'MONOCHROME2';
//        AddValueString( K_CMDCMTPhotometricInterpretation, 'PhotometricInterpretation', Str );
      end;
    end; // if AExpDIB.DIBPixFmt <> pf24bit then

    if Str <> '' then
      AddValueString( K_CMDCMTPhotometricInterpretation, 'PhotometricInterpretation', Str );


    PixBufLength := PixBufLength * SamplesForPixel * AExpDIB.DIBSize.X * AExpDIB.DIBSize.Y;
    SetLength( PixBuffer, PixBufLength );
    N_DIBPixToDICOMPix( TN_BytesPtr(@PixBuffer[0]), AExpDIB );

{
    ////////////////////////////////////////////
    // Save DICOM attrs in CMSuite FileStorage
    //
    if K_CMDICOMNewFSFlag then
    begin
      Str := ADCMAFName;
      if Str = '' then
//        Str := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImgPath(ASlide) + K_CMSlideGetDCMAttrsFileName( ObjName );
        Str := ASlide.GetDCMFileName( TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImgPath(ASlide) );
      N_Dump2Str( 'Save DICOM attrs to ' + Str );
      WStr := N_StringToWide( Str );
      TransferSyntax := K_CMDCMUID_LittleEndianExplicitTransferSyntax;
      WUInt2 := DLSaveInstance( ADI, @WStr[1], @TransferSyntax[1] );
      if 0 <> WUInt2 then
        N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> wrong DCMAttrs DLSaveInstance [%s] %d', [TransferSyntax, WUInt2] ) );
    end; // if K_CMDICOMNewFSFlag then
    //
    // Save DICOM attrs in CMSuite FileStorage
    ////////////////////////////////////////////
}
    if ResCode <> 0 then
    begin
      Result := ResCode;
      Exit;
    end;

    N_Dump2Str( 'AddImageData before' );
    WUInt2 := DLAddImageData( ADI, @PixBuffer[0], PixBufLength );
    if 0 <> WUInt2 then
    begin
      Result := 4;
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> wrong DLAddImageData %d', [WUInt2] ) );
      Exit;
    end;
{}
    N_Dump2Str( 'ChangeTransferSyntax before' );
    TransferSyntax := K_CMDCMUID_JPEGProcess14SV1TransferSyntax;
//    TransferSyntax := K_CMDCMUID_RLELosslessTransferSyntax;
//    TransferSyntax := K_CMDCMUID_LittleEndianExplicitTransferSyntax;
    WUInt2 := DLChangeTransferSyntax( ADI, @TransferSyntax[1], 100 );
    if 0 <> WUInt2 then
    begin
      Result := 5;
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToDCMInst >> wrong DLChangeTransferSyntax [%s] %d', [TransferSyntax, WUInt2] ) );
    end;
{}
  end; // with K_CMEDAccess, K_DCMGLibW, PSlide^ do

  N_Dump2Str( 'K_CMDCMExportDCMSlideToDCMInst fin' );

end; // function K_CMDCMExportDCMSlideToDCMInst

//*************************************************** K_CMDCMExportDCMSlideToFile ***
// Export one slide to DICOM
//
//     Parameters
// ASlide  - Slide to export
// AExpDIB - Slide DIB to Export
// AFName  - export file name
// ADCMAFName - DCM attrs file name
// Result - Returns resulting code. 0 - all OK, 1 - is 3D or video, 2 - error while opening file with DCM attrs
//
function K_CMDCMExportDCMSlideToFile( ASlide: TN_UDCMSlide;
                                AExpDIB : TN_DIBObj; const AFName, ADCMAFName : string;
                                const DCMStudyUID, DCMStudySID : string; DCMStudyTS : TDateTime;
                                const DCMSeriesUID, DCMSeriesSID : string; DCMSeriesTS : TDateTime;
                                const DCMSlideUID, DCMSlideSID : string; DCMSlideTS, DCMSlideAcqTS : TDateTime ) : Integer;
var
  DI : TK_HDCMINST;
  WStr, TransferSyntax : Widestring;
  WUInt2 : TN_UInt2;
  DumpFName : string;

label LFreeDI;
begin
  N_Dump2Str( 'K_CMDCMExportDCMSlideToFile start' );

  Result := K_CMDCMExportDCMSlideToDCMInst( DI, TRUE, ASlide, AExpDIB, ADCMAFName,
                                DCMStudyUID, DCMStudySID, DCMStudyTS,
                                DCMSeriesUID, DCMSeriesSID, DCMSeriesTS,
                                DCMSlideUID, DCMSlideSID, DCMSlideTS, DCMSlideAcqTS );

  if Result = 2 then Result := 0; // 2 - is not fatal error

  if Result <> 0then
  begin
    N_Dump1Str( format( 'K_CMDCMExportDCMSlideToFile >> Error %d', [Result] ) );
    if Result > 2 then
      goto LFreeDI;
    Exit;
  end;

  DumpFName := AFName;
  if not K_CMS_LogsCtrlAll then
    DumpFName := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(AFName))) + '????\????';

  with K_DCMGLibW do
  begin
    N_Dump2Str( 'SaveInstance before ' + DumpFName );
//    N_Dump2Str( 'SaveInstance before ' + AFName );

    if not K_ForceFilePath( AFName ) then
      N_Dump1Str( 'K_CMDCMExportDCMSlideToFile >> Force Path error >>' + DumpFName )
    else
    // This code is needed to change resulting file change timestamp
    // (without this code one couldn't define if file is realy changed) 
    if FileExists( AFName ) and not DeleteFile( AFName ) then
      N_Dump1Str( 'K_CMDCMExportDCMSlideToFile >> Delete prev resulting file error >>' + DumpFName );

    TransferSyntax := K_CMDCMUID_JPEGProcess14SV1TransferSyntax;
//    TransferSyntax := K_CMDCMUID_LittleEndianExplicitTransferSyntax;

    WStr := N_StringToWide( AFName );
    WUInt2 := DLSaveInstance( DI, @WStr[1], @TransferSyntax[1] );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToFile >> wrong DLSaveInstance [%s] %d', [TransferSyntax, WUInt2] ) );

LFreeDI: //****
    N_Dump2Str( 'DeleteDcmObject before ');
    WUInt2 := DLDeleteDcmObject( DI );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMExportDCMSlideToFile >> wrong DLDeleteDcmObject %d', [WUInt2] ) );
  end; // with K_CMEDAccess, K_DCMGLibW, PSlide^ do

  N_Dump1Str( 'K_CMDCMExportDCMSlideToFile fin to ' + DumpFName );

end; // function K_CMDCMExportDCMSlideToFile

//******************************************************** K_CMDCMDumpFile ***
// Prepare DIB attributes
//
//     Parameters
// ADI
// ABufLength
// AWidth
// AHeight
// APixFmt
// AExPixFmt
// ANumBits
// ADumpProc - pointer to procedure of object
// Result - Returns resulting code. 0 - all OK, -1 - if ADI = nil, 1 - if DIB attrs have errors
//
function K_CMDGetDIBAttrs( ADI : TK_HDCMINST;
                           out ABufLength : Integer; out AWidth, AHeight : TN_UInt2;
                           out APixFmt: TPixelFormat; out AExPixFmt: TN_ExPixFmt;
                           out ANumBits: TN_UInt2; ADumpProc : TN_OneStrProcObj = nil ) : Integer;
var
  IsNil : Integer;
  IWidth, IHeight: TN_UInt2;
  IPixFmt: TPixelFormat;
  IExPixFmt: TN_ExPixFmt;
  INumBits: TN_UInt2;
  PixBufLength : Integer;
  WUInt2 : TN_UInt2;
  WBuf : WideString;
  sz : Integer;
  BitsAllocated : Integer;

const BufLeng = 100;

begin
  Result := -1;
  if ADI = nil then Exit; // precaution;

  with K_DCMGLibW do
  begin
    IWidth := 0;
    if 0 <> DLGetValueUint16( ADI, K_CMDCMTColumns, @IWidth, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 Columns' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'Columns=' + IntToStr(IWidth) );

    IHeight := 0;
    if 0 <> DLGetValueUint16( ADI, K_CMDCMTRows, @IHeight, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 Rows' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'Rows=' + IntToStr(IHeight) );

    if 0 <> DLGetValueUint16( ADI, K_CMDCMTBitsStored, @WUInt2, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 BitsStored' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'BitsStored=' + IntToStr(WUInt2) );

    if 0 <> DLGetValueUint16( ADI, K_CMDCMTBitsAllocated, @WUInt2, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 BitsAllocated' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'BitsAllocated=' + IntToStr(WUInt2) );
    BitsAllocated := WUInt2;

    IPixFmt := pfDevice;
    IExPixFmt := epfBMP;
    PixBufLength := 1;
    if WUInt2 = 16 then
    begin
      PixBufLength := 2;
      IPixFmt := pfCustom;
      IExPixFmt := epfGray16;
    end;

    if 0 <> DLGetValueUint16( ADI, K_CMDCMTHighBit, @WUInt2, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 HighBit' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'HighBit=' + IntToStr(WUInt2) );
    INumBits := WUInt2 + 1;

    if 0 <> DLGetValueUint16( ADI, K_CMDCMTSamplesPerPixel, @WUInt2, @isNil ) then
      N_Dump1Str( 'K_CMDGetDIBAttrs >> wrong DLGetValueUint16 SamplesPerPixel' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'SamplesPerPixel=' + IntToStr(WUInt2) );

    sz := BufLeng;
    SetLength( WBuf,  BufLeng );
    if 0 <>	 DLGetValueString( ADI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetValueString PhotometricInterpretation' )
    else
    if Assigned(ADumpProc) then
      ADumpProc( 'PhotometricInterpretation=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    if SameText( WBuf, 'PALETTE COLOR' ) and (BitsAllocated = 8) then
      WUInt2 := 3;

    if WUInt2 = 3 then
      IPixFmt := pf24bit
    else
    begin
      if IPixFmt <> pfCustom then
      begin
        IPixFmt := pfCustom;
        IExPixFmt := epfGray8;
      end;
    end;
    PixBufLength := PixBufLength * WUInt2 * IWidth * IHeight;

    if IPixFmt = pf24bit then
    begin
      if 0 <> DLGetValueUint16( ADI, K_CMDCMTPlanarConfiguration, @WUInt2, @isNil ) then
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueUint16 PlanarConfiguration' )
      else
      if Assigned(ADumpProc) then
        ADumpProc( 'PlanarConfiguration=' + IntToStr(WUInt2) );
    end;

  end; // with K_DCMGLibW do

  ABufLength := PixBufLength;
  AWidth    := IWidth;
  AHeight   := IHeight;
  APixFmt   := IPixFmt;
  AExPixFmt := IExPixFmt;
  ANumBits  := INumBits;

  Result := 0;
  if PixBufLength > 0 then Exit;
  Result := 1;

end; // function K_CMDGetDIBAttrs

//******************************************************** K_CMDCMDumpFile ***
// Import one slide from DICOM Test
//
//     Parameters
// ADCMFName - DICOM file name
// AImgFName - Resulting PNG Image file Name
// Result - Returns resulting code. 0 - all OK, 1 - is 3D or video
//
function K_CMDCMDumpFile( const ADCMFName, AImgFName : string ) : Integer;
var
  DI : TK_HDCMINST;
  WUInt2 : TN_UInt2;
  WBuf : WideString;
  sz : Integer;
  IsNil : Integer;

  PixBufLength : Integer;
  IWidth, IHeight: TN_UInt2;
  IPixFmt: TPixelFormat;
  IExPixFmt: TN_ExPixFmt;
  INumBits: TN_UInt2;

  IDIB : TN_DIBObj;

  PixBuffer : TN_BArray;

  RIImLib : TN_RIImLib;
  FileInfo: TK_RIFileEncInfo;

  DIBAtrsRes : Integer;

const BufLeng = 1024;

begin

  N_Dump1Str( 'K_CMDCMDumpFile start ' +  ADCMFName );
  Result := K_CMDCMCreateIntance( ADCMFName, DI );
  if 0 <> Result then Exit;

  with K_DCMGLibW do
  begin
    SetLength( WBuf, BufLeng );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyInstanceUid' )
    else
      N_Dump2Str( 'StudyInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesInstanceUid' )
    else
      N_Dump2Str( 'SeriesInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SopInstanceUid' )
    else
      N_Dump2Str( 'SopInstanceUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSopClassUid, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SopClassUid' )
    else
      N_Dump2Str( 'SopClassUid=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsName, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsName' )
    else
      N_Dump2Str( 'PatientsName=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientId, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientId' )
    else
      N_Dump2Str( 'PatientID=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsSex, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsSex' )
    else
      N_Dump2Str( 'PatientsSex=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsBirthDate, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PatientsBirthDate' )
    else
      N_Dump2Str( 'PatientsBirthDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );


    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDate, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyDate' )
    else
      N_Dump2Str( 'StudyDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyTime, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyTime' )
    else
      N_Dump2Str( 'StudyTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
{}
    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDate, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesDate' )
    else
      N_Dump2Str( 'SeriesDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesTime, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesTime' )
    else
      N_Dump2Str( 'SeriesTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
{}
    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionDate, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString AcquisitionDate' )
    else
      N_Dump2Str( 'AcquisitionDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTContentDate, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString ContentDate' )
    else
      N_Dump2Str( 'ContentDate=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString AcquisitionTime' )
    else
      N_Dump2Str( 'AcquisitionTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTContentTime, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString ContentTime' )
    else
      N_Dump2Str( 'ContentTime=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTInstitutionName, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString InstitutionName' )
    else
      N_Dump2Str( 'InstitutionName=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyId, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString StudyId' )
    else
      N_Dump2Str( 'StudyId=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTModality, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString Modality' )
    else
      N_Dump2Str( 'Modality=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPresentationIntentType, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PresentationIntentType' )
    else
      N_Dump2Str( 'PresentationIntentType=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString SeriesNumber' )
    else
      N_Dump2Str( 'SeriesNumber=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString InstanceNumber' )
    else
      N_Dump2Str( 'InstanceNumber=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPixelSpacing, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PixelSpacing' )
    else
      N_Dump2Str( 'PixelSpacing=' + N_WideToString( Copy( WBuf, 1, sz ) ) );

    DIBAtrsRes := K_CMDGetDIBAttrs( DI, PixBufLength, IWidth, IHeight,
                           IPixFmt, IExPixFmt, INumBits, N_Dump2Str );
    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTNumberOfFrames, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString NumberOfFrames' )
    else
      N_Dump2Str( 'NumberOfFrames=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
{
    sz := BufLeng;
    if 0 <>	 DLGetValueString( DI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @isNil) then
      N_Dump1Str( 'K_CMDCMDumpFile >> wrong DLGetValueString PhotometricInterpretation' )
    else
      N_Dump2Str( 'PhotometricInterpretation=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
}
    if AImgFName <> '' then
    begin
      N_Dump2Str( 'GetImageData before' );
      if DIBAtrsRes = 0 then
      begin
        SetLength( PixBuffer, PixBufLength );
        WUInt2 := DLGetImageData( DI, @PixBuffer[0], PixBufLength );
        if 0 <>	WUInt2 then
          N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetImageData RCode =' + IntToStr(WUInt2) )
        else
        begin
          IDIB := TN_DIBObj.Create( IWidth, IHeight, IPixFmt, -1, IExPixFmt, INumBits );
          N_DICOMPixToDIBPix( TN_BytesPtr(@PixBuffer[0]), IDIB );

          RIImLib := TN_RIImLib.Create;

          FileInfo.RIFileEncType := rietNotDef;
          FileInfo.RIFComprType := rictDefByFileEncType;
          FileInfo.RIFComprQuality := 100;

          RIImLib.RICreateFile( AImgFName, @FileInfo );
          RIImLib.RIAddDIB( IDIB );
          RIImLib.RIClose();
          RIImLib.Free;
          N_Dump2Str( 'K_CMDCMDumpFile >> create >> ' + AImgFName );

          IDIB.Free;
        end;
      end
      else
        N_Dump1Str( 'K_CMDCMDumpFile >> wrong ImageLength' );
    end;

    N_Dump2Str( 'DLDeleteDcmObject before' );
    WUInt2 := DLDeleteDcmObject( DI );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'K_CMDCMDumpFile >> wrong DLDeleteDcmObject %d', [WUInt2] ) );

  end; // with K_DCMGLibW do
  N_Dump2Str( 'K_CMDCMDumpFile fin' );

end; // function K_CMDCMDumpFile

//********************************************************* K_CMDCMImportDIB ***
// Import DIB from DICOM file
//
//     Parameters
// ADCMFName - import file name
// AImpDIB   - resulting DIB
// ADI       - Instance Handle (early recieved from DLL, deault nil )
// Result    - Returns resulting code. 0 - all OK, 1 - something is not OK with DICOM tags,
//          >100 - Library Initialization problems
//          -1 - file is absent
//          -2 - wrong DCM pixels format
//          -3 - out of memory
//
function K_CMDCMImportDIB( ADCMFName : string; var AImpDIB : TN_DIBObj; ADI : TK_HDCMINST = nil ) : Integer;
var
  DI : TK_HDCMINST;
  WStr : Widestring;
  WUInt2 : TN_UInt2;
  WBuf : WideString;
  sz : Integer;
  IsNil : Integer;
  Str : string;
  WPChar : PChar;
  WDbl : Double;

  IWidth, IHeight: TN_UInt2;
  IPixFmt: TPixelFormat;
  IExPixFmt: TN_ExPixFmt;
  INumBits: TN_UInt2;
  PixBuffer : TN_BArray;
  PixBufLength : Integer;
  DIBAtrsRes : Integer;

const BufLeng = 1024;

begin
  N_Dump1Str( 'K_CMDCMImportDIB start ' +  ADCMFName );
  Result := -1;
//  AImpDIB := nil;
  if (ADI = nil) and not FileExists( ADCMFName ) then
  begin
    N_Dump1Str( ' K_CMDCMImportDIB >> File is not Exist and DICOMInstance is empty ' );
    Exit;
  end;

  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( 'K_CMDCMImportDIB >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  with K_DCMGLibW do
  begin
    if ADI <> nil then
      DI := ADI
    else
    begin
      WStr := N_StringToWide( ADCMFName );
      DI := DLCreateInstanceFromFile( @WStr[1], 255 );
    end;
    if DI <> nil then
    begin
      DIBAtrsRes := K_CMDGetDIBAttrs( DI, PixBufLength, IWidth, IHeight,
                           IPixFmt, IExPixFmt, INumBits, N_Dump2Str );
      SetLength( WBuf, BufLeng );
      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTNumberOfFrames, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetValueString NumberOfFrames' )
      else
        N_Dump2Str( 'NumberOfFrames=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
{
      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @isNil) then
        N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetValueString PhotometricInterpretation' )
      else
        N_Dump2Str( 'PhotometricInterpretation=' + N_WideToString( Copy( WBuf, 1, sz ) ) );
}
      N_Dump2Str( 'GetImageData before' );
      if DIBAtrsRes = 0 then
      begin
        // Create DCM Pixels buffer
        try
          SetLength( PixBuffer, PixBufLength );
        except
          Result := -3;
          N_Dump1Str( 'K_CMDCMImportDIB >> Out of memory 2'  );
          Exit;
        end;

        // Get DCM Image Data
        WUInt2 := DLGetImageData( DI, @PixBuffer[0], PixBufLength );
        if 0 <>	WUInt2 then
        begin
          Result := -2;
          N_Dump1Str( format( 'K_CMDCMImportDIB >> wrong DLGetImageData RCode = %d, BufLength = %d', [WUInt2, PixBufLength] ) );
        end
        else
        begin
          // Create proper DIB
          try
            if AImpDIB = nil then // Create New DIBObj
              AImpDIB := TN_DIBObj.Create( IWidth, IHeight, IPixFmt, -1, IExPixFmt, INumBits )
            else // AImpDIB exists, check if it has proper fields
              with AImpDIB do
              begin
                if not ( (DIBSize.X = IWidth)   and (DIBSize.Y = IHeight)     and
                         (DIBPixFmt = IPixFmt)  and (DIBExPixFmt = IExPixFmt) and
                         (DIBNumBits = INumBits) ) then
                PrepEmptyDIBObj( IWidth, IHeight, IPixFmt, -1, IExPixFmt, INumBits ); // Prepare AImpDIB
              end; // with ADstDIB do, else // ADstDIB exists
          except
            Result := -3;
            FreeAndNil(AImpDIB);
            N_Dump1Str( 'K_CMDCMImportDIB >> Out of memory 1'  );
            Exit;
          end;

          // Copy DCM pixels to DIB
          N_DICOMPixToDIBPix( TN_BytesPtr(@PixBuffer[0]), AImpDIB  );

          sz := BufLeng;
          if 0 <>	 DLGetValueString( DI, K_CMDCMTPixelSpacing, @WBuf[1], @sz, @isNil) then
            N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetValueString PixelSpacing' )
          else
          begin
            str := N_WideToString( Copy( WBuf, 1, sz ) );
            N_Dump2Str( 'PixelSpacing=' + str );
            if str = '' then
            begin
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTImagerPixelSpacing, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMDCMImportDIB >> wrong DLGetValueString PixelSpacing' )
              else
              begin
                str := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'ImagePixelSpacing=' + str );
              end;
            end;

            WPChar := StrPos( PChar(str), '\' );
            if WPChar <> nil then
              WPChar^ := #0;

            WDbl := StrToFLoatDef( str, -1);
            if WDbl <> -1 then
            begin
              if WDbl = 0 then // WDbl := 0.3527777777778;
                WDbl := 1 / (Round(72 * 100 / 2.54) / 1000);
              with AImpDIB.DIBInfo.bmi do
              begin
                biXPelsPerMeter := Round(1 / WDbl * 1000);
                biYPelsPerMeter := biXPelsPerMeter;
              end;  
            end; // if WDbl <> -1 then
          end; // Pixel spacing exists
        end; // DLGetImageData OK
      end  // if DIBAtrsRes = 0 then
      else
        N_Dump1Str( 'K_CMDCMImportDIB >> wrong ImageLength' );
    end // if DI <> nil then
    else
    begin
      Result := 1;
      N_Dump1Str( 'K_CMDCMImportDIB >> Instance error 1' );
    end;

    if ADI = nil then
    begin
      N_Dump2Str( 'DLDeleteDcmObject before' );
      WUInt2 := DLDeleteDcmObject( DI );
      if 0 <> WUInt2 then
        N_Dump1Str( format( 'K_CMDCMImportDIB >> wrong DLDeleteDcmObject %d', [WUInt2] ) );
    end
    else
      N_Dump2Str( 'K_CMDCMImportDIB >> External HDCMINST' );
  end; // with K_DCMGLibW do
  N_Dump2Str( 'K_CMDCMImportDIB fin' );

end; // function K_CMDCMImportDIB

//**************************************************** K_CMCreateDCMUDTree ***
// Create DICOM UDViewer UDTree by Patients Data
//
//     Parameters
// AUDRoot    - resulting UDTree Root Node
// APPats     - pointer to Patients Data Array 1-st Item
// APatsCount - number of DICOMDIR Patients Data Array Items
// Result - Returns resulting code
//
function K_CMCreateDCMUDTree( var AUDRoot : TN_UDBase; APPats: TK_PCMDCMDPatient; APatsCount: Integer;
                              APatCheckProc : TK_CMDCMDPatientCheckProc; AProgressProcObj : TN_OneStrProcObj ): Integer;
var
  i1, i2, i3, i4, PatSInd, PatFInd, AllPatCount, AllSlidesCount, ProcSlidesCount : Integer;
  UDPat, UDStudy, UDSeries, UDMedia : TK_UDStringList;

  SPatDOB, SPatDOBY, SPatDOBM, SPatDOBD,
  SDate, SDateY, SDateM, SDateD, STime, STimeH, STimeN, STimeS,
  SPatSex, SPatID,
  SUID, SID, SFIO, SDOB: string;
  DOBDate : TDate;
  PStudies  : TK_PCMDCMDStudy;
  PSeries  : TK_PCMDCMDSeries;
  PMedia  : TK_PCMDCMDMedia;
  PatienIsAbsentFlag : Boolean;
  CurCMSPatID : Integer;
  YY,MM,DD,HH,NN,SS  :Integer;
  WStr : string;
  CurPPats: TK_PCMDCMDPatient;

  procedure ParseDateTime();
  var
    IndT : Integer;
  begin
    SDateY := Copy(SDate, 1, 4);
    SDateM := Copy(SDate, 5, 2);
    SDateD := Copy(SDate, 7, 2);

    YY := StrToIntDef(SDateY,-100);
    MM := StrToIntDef(SDateM,-100);
    DD := StrToIntDef(SDateD,-100);
    SDate := '';
    if (YY <> -100) and (YY >= 1899) and
       (MM <> -100) and (MM >= 1) and (MM <= 12) and
       (DD <> -100) and (DD >= 1) and (DD <= 31) then
      SDate := format( '%s/%s/%s', [SDateD, SDateM, SDateY] );

    STimeH := Copy(STime, 1, 2);
    IndT := 3;
    if (Length(STime) > IndT) and
       ((STime[IndT] < '0') or (STime[IndT] > '9')) then Inc(IndT);
    STimeN := Copy(STime, IndT, 2);
    IndT := IndT + 2;
    if (Length(STime) > IndT) and
       ((STime[IndT] < '0') or (STime[IndT] > '9')) then Inc(IndT);
    STimeS := Copy(STime, IndT, 2);

    HH := StrToIntDef(STimeH,-100);
    NN := StrToIntDef(STimeN,-100);
    SS := StrToIntDef(STimeS,-100);
    STime := '';
    if (HH <> -100) and (HH >= 0) and (HH <= 23) and
       (NN <> -100) and (NN >= 0) and (NN <= 59) and
       (SS <> -100) and (SS >= 0) and (SS <= 59) then
      STime := format( '%s:%s:%s', [STimeH, STimeN, STimeS] );
  end; // ParseDateTime();

begin
  Result := 0;
  if AUDRoot = nil then
    AUDRoot :=  TN_UDBase.Create
  else
    AUDRoot.ClearChilds();

// Calculate All Counts number
  AllSlidesCount := 0;
  CurPPats := APPats;
  for i1 := 0 to APatsCount - 1 do
  begin
    with CurPPats^ do
    begin
      PStudies := @DDStudies[0];
      for i2 := 0 to DDStudiesCount - 1 do
      begin
        with PStudies^ do
        begin
          PSeries := @DDSeries[0];
          for i3 := 0 to DDSeriesCount - 1 do
          begin
            with PSeries^ do
              AllSlidesCount := AllSlidesCount + DDMediasCount;
            Inc(PSeries);
          end; // for i3 := 0 to DDSeriesCount - 1 do
        end; // with PStudies^ do
        Inc(PStudies);
      end; // for i2 := 0 to DDStudiesCount - 1 do
    end; // with APPats^ do
    Inc( CurPPats );
  end; // for i1 := 0 to APatsCount - 1 do


  ProcSlidesCount := 0;

//  UseAddDICOMAttrs := Assigned( N_ImageLib.ILDCMSelectInstance );
//  UseSelectInstance := FALSE;

  ////////////////////////////////////////
  // Create Patient Nodes Loop
  for i1 := 0 to APatsCount - 1 do
  begin
    with APPats^ do
    begin
      SPatDOB := DDPatDOB;
      SPatDOBY := Copy(SPatDOB, 1, 4);
      SPatDOBM := Copy(SPatDOB, 5, 2);
      SPatDOBD := Copy(SPatDOB, 7, 2);
      SPatSex := DDPatSex;
      SPatID := DDPatID;

      // Check Patient
      YY := StrToIntDef(SPatDOBY,-100);
      MM := StrToIntDef(SPatDOBM,-100);
      DD := StrToIntDef(SPatDOBD,-100);
      DOBDate := 0;
      if (YY <> -100) and (YY >= 1899) and
         (MM <> -100) and (MM >= 1) and (MM <= 12) and
         (DD <> -100) and (DD >= 1) and (DD <= 31) then
        DOBDate := EncodeDate( YY, MM, DD );

      CurCMSPatID := APatCheckProc( DDPatSurname, DDPatFirstname, SPatID, DOBDate );
      PatienIsAbsentFlag := CurCMSPatID = 0;

      UDPat := TK_UDStringList.Create();
      UDPat.ImgInd := 102;
      if PatienIsAbsentFlag then
      begin
        UDPat.ImgInd := 108;
        UDPat.ObjFlags := UDPat.ObjFlags or K_fpObjTVSpecMark1;
      end
      else
        UDPat.SL.Add( 'CMSuiteID=' + IntToStr(CurCMSPatID) );

      UDPat.SL.Add( 'Surname=' + DDPatSurname );
      UDPat.SL.Add( 'FirstName=' + DDPatFirstname );
      UDPat.SL.Add( 'Middle=' + DDPatMiddle );
      UDPat.SL.Add( 'Title=' + DDPatTitle );

      UDPat.SL.Add( 'DOB=' + SPatDOB );
      UDPat.SL.Add( 'DOBY=' + SPatDOBY );
      UDPat.SL.Add( 'DOBM=' + SPatDOBM );
      UDPat.SL.Add( 'DOBD=' + SPatDOBD );

      UDPat.SL.Add( 'Sex=' + SPatSex );
      UDPat.SL.Add( 'ID=' + SPatID );

      UDPat.ObjName := IntToStr( i1 );
      UDPat.ObjAliase := format( '%s, %s %s [%s], DOB', [DDPatSurname, DDPatTitle, DDPatFirstName, SPatID] );
      if DOBDate <> 0 then
        UDPat.ObjAliase := format( '%s %s/%s/%s', [UDPat.Objaliase, SPatDOBD, SPatDOBM, SPatDOBY] );
      UDPat.ObjDateTime := DOBDate;
      N_Dump2Str( format('K_CMCreateDCMUDTree >> Patient [%d]'#13#10'%s', [i1, UDPat.SL.Text] ) );

      AUDRoot.AddOneChild( UDPat );
      PStudies := @DDStudies[0];

      for i2 := 0 to DDStudiesCount - 1 do
      begin
        with PStudies^ do
        begin
{ // Not use Prov
          Surname := N_WideToString( DDProvSurname );
          FirstName := N_WideToString( DDProvFirstname );
          Middle := N_WideToString( DDProvMiddle );
          Title := N_WideToString( DDProvTitle );
}
          SDate := DDStudyDate;
          STime := DDStudyTime;
          ParseDateTime();

          SUID := DDStudyUID;
          SID  := DDStudyID;

          UDStudy := TK_UDStringList.Create();
          UDStudy.ImgInd := 36;

          if PatienIsAbsentFlag then
            UDStudy.ObjFlags := UDStudy.ObjFlags or K_fpObjTVDisabled;
          UDStudy.ObjName := IntToStr( i2 );
          WStr := SID;
          if SID = '' then
            WStr := 'Study ' + SDate;
          UDStudy.ObjAliase := WStr;

          WStr := '';
          if (SDate <> '') or (STime <> '' ) then
          begin
            WStr := WStr + '%s %s';
            if SUID <> '' then
              WStr := ','#13#10 + WStr;
          end;
          WStr := '%s' + WStr;
          UDStudy.ObjInfo := Trim( format( WStr, [SUID, SDate, STime] ) );
          UDPat.AddOneChild( UDStudy );
          N_Dump2Str( 'K_CMCreateDCMUDTree >> Study >> ' + UDStudy.ObjInfo );

          PSeries := @DDSeries[0];

          for i3 := 0 to DDSeriesCount - 1 do
          begin
            with PSeries^ do
            begin
//              SeriesMod := N_AnsiToString( DDSeriesMod );

              SDate := DDSeriesDate;
              STime := DDSeriesTime;
              if (SDate = '') or (STime = '') then
              begin
                DDSeriesDate := DDStudyDate;
                SDate := DDSeriesDate;
                DDSeriesTime := DDStudyTime;
                STime := DDSeriesTime;
              end;

              ParseDateTime();

              SUID := DDSeriesUID;
              SID  := DDSeriesNum;

              UDSeries := TK_UDStringList.Create();
              UDSeries.ImgInd := 30;
              if PatienIsAbsentFlag then
                UDSeries.ObjFlags := UDSeries.ObjFlags or K_fpObjTVDisabled;

              UDSeries.ObjName := IntToStr( i3 );
              UDSeries.ObjAliase := format( 'Series %s (%s)',
                                            [SID, DDSeriesMod] );
              WStr := '%s';
              if SUID <> '' then
                WStr := WStr + ','#13#10;
              WStr := WStr + 'Series %s %s %s';
              UDSeries.ObjInfo := Trim( format( WStr, [SUID, SID, SDate, STime] ) );
              UDStudy.AddOneChild( UDSeries );
              N_Dump2Str( 'K_CMCreateDCMDUDTree >> Series >> ' + UDSeries.ObjInfo );

              PMedia := @DDMedias[0];
              for i4 := 0 to DDMediasCount - 1 do
              begin
                Inc(ProcSlidesCount);
                if Assigned( AProgressProcObj ) then
                  AProgressProcObj( format( '%d of %d is done. Please wait ...', [ProcSlidesCount, AllSlidesCount] ) );
//                N_CM_MainForm.CMMFShowString( format( '%d of %d is done. Please wait ...', [ProcSlidesCount, AllSlidesCount] ) );

                with PMedia^ do
                begin
                  // Try Content Date|Time
                  SDate := DDMediaDate;
                  STime := DDMediaTime;

                  if (SDate = '') or (STime = '') then
                  begin
                  // Acquisition Date Time - Next priority
                    SDate := DDMediaADate;
                    STime := DDMediaATime;
                  end;

                  if (SDate = '') or (STime = '') then
                  begin
                  // Use Series Date Time
                    DDMediaDate := DDSeriesDate;
                    SDate := DDMediaDate;
                    DDMediaTime := DDSeriesTime;
                    STime := DDMediaTime;
                    if (SDate = '') or (STime = '') then
                    begin
                    // Use Study Date Time
                      DDMediaDate := DDStudyDate;
                      SDate := DDMediaDate;
                      DDMediaTime := DDStudyTime;
                      STime := DDMediaTime;
                    end;
                  end;

                  ParseDateTime();

                  SUID := DDMediaUID;
                  SID  := DDMediaNum;

                  UDMedia := TK_UDStringList.Create();
                  UDMedia.ImgInd := 103;
                  if not PatienIsAbsentFlag then
                    UDMedia.ObjFlags := UDMedia.ObjFlags or K_fpObjTVAutoCheck;
//                  else
//                    UDMedia.ObjFlags := UDMedia.ObjFlags or (K_fpObjTVAutoCheck or K_fpObjTVChecked) xor (K_fpObjTVAutoCheck or K_fpObjTVChecked);
                  UDMedia.SL.Add( 'Modality=' + DDSeriesMod );
                  UDMedia.SL.Add( 'KVP=' + DDMediaKVP );
                  UDMedia.SL.Add( 'ExposureTime=' + DDMediaExpTime );
                  UDMedia.SL.Add( 'TubeCurrent=' + DDMediaTubeCurrent );
                  UDMedia.SL.Add( 'RadiationDose=' + DDMediaRadiationDose );
                  UDMedia.SL.Add( 'ExposureCtrlMode=' + DDMediaExpCMode );

                  UDMedia.SL.Add( 'Date=' + SDate );
                  UDMedia.SL.Add( 'DateY=' + SDateY );
                  UDMedia.SL.Add( 'DateM=' + SDateM );
                  UDMedia.SL.Add( 'DateD=' + SDateD );

                  UDMedia.SL.Add( 'Time=' + STime );
                  UDMedia.SL.Add( 'TimeH=' + STimeH );
                  UDMedia.SL.Add( 'TimeN=' + STimeN );
                  UDMedia.SL.Add( 'TimeS=' + STimeS );
                  if (SDate <> '') and (STime <> '') then
                    UDMedia.ObjDateTime := EncodeDateTime( StrToInt(SDateY), StrToInt(SDateM), StrToInt(SDateD),
                                                           StrToInt(STimeH), StrToInt(STimeN), StrToInt(STimeS), 0 );

                  UDMedia.SL.Add( 'UID=' + SUID );
                  UDMedia.SL.Add( 'Num=' + SID );
                  UDMedia.Marker := CurCMSPatID;

                  UDMedia.ObjName := 'M'+IntToStr( i4 );
                  UDMedia.ObjAliase := format( 'Image %s (%s)',
                                                [SID, DDSeriesMod] );
                  WStr := '';
                  if (SDate <> '') or (STime <> '' ) then
                  begin
                    WStr := '%s %s';
                    if SUID <> '' then
                      WStr := ','#13#10 + WStr;
                  end;
                  WStr := '%s' + WStr;
                  UDMedia.ObjInfo := Trim( format( WStr, [SUID, SDate, STime] ) );
                  UDSeries.AddOneChild( UDMedia );

                  // Get File Name
                  UDMedia.SL.Add( 'File=' + DDMediaFile );
                  UDMedia.ObjInfo := UDMedia.ObjInfo + ','#13#10 + DDMediaFile;

                end; // with PMedia^ do
                Inc(PMedia);
              end; // for i4 := 0 to DDMediaCount - 1 do

//                if SeriesDescr <> '' then
              UDSeries.ObjAliase := format( '%s (%s)',
                                            [DDSeriesDescr, DDSeriesMod] );
            end; // with PSeries^ do
            Inc(PSeries);
          end; // for i3 := 0 to DDSeriesCount - 1 do

//            if StudyDescr <> '' then
          UDStudy.ObjAliase := DDStudyDescr;

        end; // with PStudies^ do
        Inc(PStudies);
      end; // for i2 := 0 to DDStudiesCount - 1 do

    end; // with APPats^ do
    Inc( APPats );
  end; // for i1 := 0 to APatsCount - 1 do


end; // function K_CMCreateDCMUDTree

//******************************************** K_CMBuildImpDataFromDICOMDIR ***
// Create Patients Data from DICOMDIR
//
//     Parameters
// ADCMDIRFName - file path to DICOMDIR
// AImpData     - Resulting Patients Data Array
// Result - Returns resulting code:
//  0 - all OK,
// -1 - file DICOMDIR is absent
// > 100 - DLL initialization error
//
function K_CMBuildImpDataFromDICOMDIR( const ADCMDIRFName : string; out AImpData : TK_CMDCMDPatientArr ) : Integer;
var
  dcmdirHandle : TK_HDCMDIR;
  hDcmDirPatientRecord, hDcmDirStudyRecord, hDcmDirSeriesRecord,
  hDcmDirFileRecord : TK_HDCMDIRITEM;
  NumPatients, NumStudies, NumSeries, NumFiles : Integer;
  i1, i2, i3, i4, Ind1, Ind2,Ind3, Ind4 : Integer;
  WBuf, WStr : WideString;
  sz : Integer;
  IsNil : Integer;
  DCMFileName, PNGFileName, RootPath, Str: string;
  SL : TStringList;
  DI : TK_HDCMINST;
  WUInt2 : TN_UInt2;
  WBufLength : Integer;
  WWidth, WHeight, WNumBits : TN_UInt2;
  WPixFmt: TPixelFormat;
  WExPixFmt: TN_ExPixFmt;

const BufLeng = 1000;

begin

  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR start' );
  AImpData := nil;
  Result := -1;

  if not FileExists( ADCMDIRFName ) then
  begin
    N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> file is absent >> ' + ADCMDIRFName );
    Exit;
  end;

  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( ' >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  Result := 0;
  RootPath := ExtractFilePath( ADCMDIRFName );
  with K_DCMGLibW do
  begin
    WBuf := N_StringToWide( ADCMDIRFName );
    dcmdirHandle := DLOpenDICOMDIR( @WBuf[1] );
    if dcmdirHandle <> nil then
    begin
      SL := TStringList.Create;
      SL.Delimiter := '^';
      SetLength( WBuf, BufLeng );
      NumPatients := DLDcmDirGetPatientCount(dcmdirHandle);
      N_Dump2Str( format( '>>>>> Patients count=%d', [NumPatients] ) );
      SetLength( AImpData, NumPatients );
      Ind1 := 0;
      for i1 := 0 to NumPatients - 1 do
      begin
        hDcmDirPatientRecord := DLDcmDirGetPatientItem( dcmdirHandle, i1 );
        NumStudies := DLDcmDirGetStudyCount( dcmdirHandle );
        N_Dump2Str( format( '>>>>> Patient=%d Studies=%d', [i1,NumStudies] ) );
        with AImpData[Ind1] do
        begin
          SetLength( DDStudies, NumStudies );
          Ind2 := 0;
          for i2 := 0 to NumStudies - 1 do
          begin
            hDcmDirStudyRecord := DLDcmDirGetStudyItem( dcmdirHandle, i2 );
            NumSeries := DLDcmDirGetSeriesCount( dcmdirHandle );
            N_Dump2Str( format( '>>>>> Study=%d Series=%d', [i2,NumSeries] ) );
            with DDStudies[Ind2] do
            begin
              SetLength( DDSeries, NumSeries );
              Ind3 := 0;
              for i3 := 0 to NumSeries - 1 do
              begin
                hDcmDirSeriesRecord := DLDcmDirGetSeriesItem( dcmdirHandle, i3 );
                NumFiles := DLDcmDirGetFilesCount( dcmdirHandle );
                N_Dump2Str( format( '>>>>> Series=%d Files=%d', [i3,NumFiles] ) );
                with DDSeries[Ind3] do
                begin
                  SetLength( DDMedias, NumFiles );
                  Ind4 := 0;
                  for i4 := 0 to NumFiles - 1 do
                  begin
                    N_Dump2Str( format( '>>>>> File=%d', [i4] ) );
                    hDcmDirFileRecord := DLDcmDirGetFileItem( dcmdirHandle, i4 );
                    with DDMedias[Ind4] do
                    begin
                      sz := BufLeng;
                      if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTReferencedFileId, @WBuf[1], @sz, @isNil ) then
                        N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString ReferencedFileId' )
                      else
                      if sz > 0 then
                      begin
                        DDMediaFile := N_WideToString( Copy( WBuf, 1, sz ) );
                        N_Dump2Str( 'ReferencedFileId=' + DDMediaFile );
                        DDMediaFile := RootPath + DDMediaFile;
                        if not FileExists( DDMediaFile ) then
                          N_Dump1Str( format( 'File "%s" is absent', [DDMediaFile] ) )
                        else
                        begin
                        // Import Attributes
                          WStr := N_StringToWide( DDMediaFile );
                          DI := DLCreateInstanceFromFile( @WStr[1], 255 );
                          if DI = nil then
                            N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> DLCreateInstanceFromFile error' )
                          else
                          begin
                            if 0 <> K_CMDGetDIBAttrs( DI, WBufLength, WWidth, WHeight,
                                                WPixFmt, WExPixFmt, WNumBits, N_Dump2Str ) then
                              N_Dump1Str( 'K_CMDGetDIBAttrs >> error' )
                            else
                            begin
   {// Check DICOMDIR values and corresponding values in DICOM file
                              // Get Study UID
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString StudyInstanceUid' )
                              else
    //                          if sz > 0 then
                              begin
                                DDStudyUID := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'StudyInstanceUid=' + DDStudyUID );
                              end;

                              // Get Study Date
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDate, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString StudyDate' )
                              else
    //                          if sz > 0 then
                              begin
                                DDStudyDate := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'StudyDate=' + DDStudyDate );
                              end;

                              // Get Study Time
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyTime, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString StudyTime' )
                              else
   //                           if sz > 0 then
                              begin
                                DDStudyTime := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'StudyTime=' + DDStudyTime );
                              end;

                              // Get Study Description
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDescription, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString StudyDescription' )
                              else
    //                          if sz > 0 then
                              begin
                                DDStudyDescr := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'StudyDescription=' + DDStudyDescr );
                              end;

                              // Get Study ID
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyId, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString StudyId' )
                              else
    //                          if sz > 0 then
                              begin
                                DDStudyID := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'StudyId=' + DDStudyID );
                              end;
  {}
                              // Get Series UID
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString SeriesInstanceUid' )
                              else
    //                          if sz > 0 then
                              begin
                                DDSeriesUID := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'SeriesInstanceUid=' + DDSeriesUID );
                              end;

                              // Get Series Date
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirSeriesRecord, K_CMDCMTSeriesDate, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDate, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString SeriesDate' )
                              else
    //                          if sz > 0 then
                              begin
                                DDSeriesDate := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'SeriesDate=' + DDSeriesDate );
                              end;

                              // Get Series Time
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirSeriesRecord, K_CMDCMTSeriesTime, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesTime, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString SeriesTime' )
                              else
    //                          if sz > 0 then
                              begin
                                DDSeriesTime := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'SeriesTime=' + DDSeriesTime );
                              end;

                              // Get Series Description
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDescription, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString SeriesTime' )
                              else
    //                          if sz > 0 then
                              begin
                                DDSeriesDescr := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'SeriesTime=' + DDSeriesDescr );
                              end;

                              // Get Instance UID
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString SOPInstanceUid' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaUID := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'MediaUid=' + DDMediaUID );
                              end;

                              // Get Content Date
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTContentDate, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTContentDate, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString ContentDate' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaDate := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'ContentDate=' + DDMediaDate );
                              end;

                              // Get Content Time
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTContentTime, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTContentTime, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetrValueString ContentTime' )
                              else
    //                          if sz > 0 then
                              begin
                                DDSeriesTime := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'ContentTime=' + DDMediaTime );
                              end;

                              // Get Acquisition Date
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTAcquisitionDate, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionDate, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString AcquisitionDate' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaADate := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'AcquisitionDate=' + DDMediaADate );
                              end;

                              // Get Acquisition Time
                              sz := BufLeng;
    //                          if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @isNil) then
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString AcquisitionTime' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaATime := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'AcquisitionTime=' + DDMediaATime );
                              end;

                              // Get KVP
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTKvp, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString KVP' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaKVP := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'KVP=' + DDMediaKVP );
                              end;

                              // Get ExposureTime
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTExposureTime, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString ExposureTime' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaExpTime := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'ExposureTime=' + DDMediaExpTime );
                              end;

                              // Get TubeCurrent
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTXrayTubeCurrent, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString TubeCurrent' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaTubeCurrent := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'TubeCurrent=' + DDMediaTubeCurrent );
                              end;

                              // Get RadiationDose
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTImageAndFluroscopyAreaDoseProduct, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString RadiationDose' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaRadiationDose := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'RadiationDose=' + DDMediaRadiationDose );
                              end;

                              // Get ExposureControlMode
                              sz := BufLeng;
                              if 0 <>	 DLGetValueString( DI, K_CMDCMTExposureControlMode, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString ExposureControlMode' )
                              else
    //                          if sz > 0 then
                              begin
                                DDMediaExpCMode := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'ExposureControlMode=' + DDMediaExpCMode );
                              end;

                              // Get Instance Number
                              sz := BufLeng;
                              if 0 <>	 DLGetDcmDirValueString( hDcmDirFileRecord, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @isNil) then
                                N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString InstanceNumber' )
                              else
                              if sz > 0 then
                              begin
                                DDMediaNum := N_WideToString( Copy( WBuf, 1, sz ) );
                                N_Dump2Str( 'InstanceNumber=' + DDMediaNum );
                              end;
                              Inc(Ind4);
                            end; // if 0 = K_CMDGetDIBAttrs

                            N_Dump2Str( 'DLDeleteDcmObject before' );
                            WUInt2 := DLDeleteDcmObject( DI );
                            if 0 <> WUInt2 then
                              N_Dump1Str( format( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLDeleteDcmObject %d', [WUInt2] ) );

                          end; // if DI <> nil then
                        end; // MediaFile Exists
                      end; //  Get MediaFile
                    end; // with DDPMedias[Ind4] do
                  end; // for i4 := 0 to NumFiles - 1 do
                  SetLength( DDMedias, Ind4 );
                  DDMediasCount := Ind4;
                  if Ind4 <> 0 then
                  begin
                    // Get Series Modality
                    sz := BufLeng;
                    if 0 <>	 DLGetDcmDirValueString( hDcmDirSeriesRecord, K_CMDCMTModality, @WBuf[1], @sz, @isNil) then
                      N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString Modality' )
                    else
                    if sz > 0 then
                    begin
                      DDSeriesMod := N_WideToString( Copy( WBuf, 1, sz ) );
                      N_Dump2Str( 'Modality=' + DDSeriesMod );
                    end;

                    // Get Series Number
                    sz := BufLeng;
                    if 0 <>	 DLGetDcmDirValueString( hDcmDirSeriesRecord, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @isNil) then
                      N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString SeriesNumber' )
                    else
                    if sz > 0 then
                    begin
                      DDSeriesNum := N_WideToString( Copy( WBuf, 1, sz ) );
                      N_Dump2Str( 'SeriesNumber=' + DDSeriesNum );
                    end;

                    Inc(Ind3);
                  end; // if Ind4 <> 0 then
                end; // with DDPSeries[Ind3] do
              end; // for i3 := 0 to NumSeries - 1 do
              SetLength( DDSeries, Ind3 );
              DDSeriesCount := Ind3;
              if Ind3 <> 0 then
              begin
                // Get Study UID
                sz := BufLeng;
                if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
                  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString StudyInstanceUid' )
                else
                if sz > 0 then
                begin
                  DDStudyUID := N_WideToString( Copy( WBuf, 1, sz ) );
                  N_Dump2Str( 'StudyInstanceUid=' + DDStudyUID );
                end;

                // Get Study Date
                sz := BufLeng;
                if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTStudyDate, @WBuf[1], @sz, @isNil) then
                  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString StudyDate' )
                else
                if sz > 0 then
                begin
                  DDStudyDate := N_WideToString( Copy( WBuf, 1, sz ) );
                  N_Dump2Str( 'StudyDate=' + DDStudyDate );
                end;

                // Get Study Time
                sz := BufLeng;
                if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTStudyTime, @WBuf[1], @sz, @isNil) then
                  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString StudyTime' )
                else
                if sz > 0 then
                begin
                  DDStudyTime := N_WideToString( Copy( WBuf, 1, sz ) );
                  N_Dump2Str( 'StudyTime=' + DDStudyTime );
                end;

                // Get Study Description
                sz := BufLeng;
                if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTStudyDescription, @WBuf[1], @sz, @isNil) then
                  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString StudyDescription' )
                else
                if sz > 0 then
                begin
                  DDStudyDescr := N_WideToString( Copy( WBuf, 1, sz ) );
                  N_Dump2Str( 'StudyDescription=' + DDStudyDescr );
                end;

                // Get Study ID
                sz := BufLeng;
                if 0 <>	 DLGetDcmDirValueString( hDcmDirStudyRecord, K_CMDCMTStudyId, @WBuf[1], @sz, @isNil) then
                  N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString StudyId' )
                else
                if sz > 0 then
                begin
                  DDStudyID := N_WideToString( Copy( WBuf, 1, sz ) );
                  N_Dump2Str( 'StudyId=' + DDStudyID );
                end;

                Inc(Ind2);
              end; // if Ind3 <> 0 then
            end; // with DDStudies[Ind2] do
          end; // for i2 := 0 to NumStudies - 1 do
          SetLength( DDStudies, Ind2 );
          DDStudiesCount := Ind2;

          if Ind2 <> 0 then
          begin
            // Get Patient Name
            sz := BufLeng;
            if 0 <>	 DLGetDcmDirValueString( hDcmDirPatientRecord, K_CMDCMTPatientsName, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString PatientsName' )
            else
            if sz > 0 then
            begin
              Str := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'PatientName=' + Str );
              SL.DelimitedText := Str;
              if SL.Count > 0 then
                DDPatSurname := SL[0];
              if SL.Count > 1 then
                DDPatFirstname := SL[1];
              if SL.Count > 2 then
                DDPatMiddle := SL[2];
              if SL.Count > 3 then
                DDPatTitle := SL[3];
            end;

            // Get Patient DOB
            sz := BufLeng;
            if 0 <>	 DLGetDcmDirValueString( hDcmDirPatientRecord, K_CMDCMTPatientsBirthDate, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString PatientsBirthDate' )
            else
            if sz > 0 then
            begin
              DDPatDOB := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'PatientDOB=' + DDPatDOB );
            end;

            // Get Patient Sex
            sz := BufLeng;
            if 0 <>	 DLGetDcmDirValueString( hDcmDirPatientRecord, K_CMDCMTPatientsSex, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetDcmDirValueString PatientsSex' )
            else
            if sz > 0 then
            begin
              DDPatSex := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'PatientSex=' + DDPatSex );
            end;

            // Get Patient ID
            sz := BufLeng;
            if 0 <>	 DLGetDcmDirValueString( hDcmDirPatientRecord, K_CMDCMTPatientId, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR >> wrong DLGetValueString PatientId' )
            else
            if sz > 0 then
            begin
              DDPatID := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'PatientID=' + DDPatID );
            end;

            Inc(Ind1);
          end; // if Ind2 <> 0 then
        end; // with AImpData[Ind1] do
      end; // for i1 := 0 to NumPatients - 1 do
      SetLength( AImpData, Ind1 );
      SL.Free;
    end // if dcmdirHandle <> nil then
    else
    begin // if dcmdirHandle = nil then
      Result := 1;
      N_Dump1Str( 'K_CMBuildImpDataFromDICOMDIR OpenDICOMDIR error' );
    end; // if dcmdirHandle = nil then
    DLCloseDICOMDIR(dcmdirHandle);
  end; // with K_DCMGLibW do

  N_Dump2Str( 'K_CMBuildImpDataFromDICOMDIR fin' );
end; // function K_CMBuildImpDataFromDICOMDIR

//********************************************** K_CMBuildImpDataFromFFList ***
// Create Patients Data from Folders or DICOM Files List
//
//     Parameters
// AFNames  - List of Folders and DICOM Files
// AImpData - Resulting Patients Data Array
// Result - Returns resulting code:
//  0 - all OK,
// > 100 - DLL initialization error
//
function K_CMBuildImpDataFromFFList( AFNames : TStrings; out AImpData : TK_CMDCMDPatientArr  ) : Integer;
var
  PNL, SL : TStringList;
  FName, FExt, FN : string;
  i : Integer;
  PatCount : Integer;
  DI : TK_HDCMINST;
  WBuf, WStr : WideString;

  WBufLength : Integer;
  WWidth, WHeight, WNumBits : TN_UInt2;
  WPixFmt: TPixelFormat;
  WExPixFmt: TN_ExPixFmt;

  IndPat, IndStudy, IndSeries, IndMedia : Integer;
  CountPat : Integer;
  sz : Integer;
  IsNil : Integer;
  NewCap{, PrevCap} : Integer;
  Str: string;

  DPatient : TK_CMDCMDPatient;

  CurUID : string;
  LoadStudy, LoadSeries : Boolean;

  WUInt2 : TN_UInt2;

const BufLeng = 1000;

  function SearchPatient() : Integer;
  var j : Integer;
  begin
    Result := -1;
    for j := 0 to CountPat - 1 do
      if (AImpData[j].DDPatSurname = DPatient.DDPatSurname) and
         (AImpData[j].DDPatFirstname = DPatient.DDPatFirstname) and
         (AImpData[j].DDPatDOB = DPatient.DDPatDOB) and
         (AImpData[j].DDPatID = DPatient.DDPatID) then
      begin
        Result := j;
        Exit;
      end;
  end; // function SearchPatient

  function SearchStudy() : Integer;
  var j : Integer;
  begin
    Result := -1;
    with AImpData[IndPat] do
    for j := 0 to DDStudiesCount - 1 do
      if DDStudies[j].DDStudyUID = CurUID then
      begin
        Result := j;
        Exit;
      end;
  end; // function SearchStudy

  function SearchSeries() : Integer;
  var j : Integer;
  begin
    Result := -1;
    with AImpData[IndPat].DDStudies[IndStudy] do
    for j := 0 to DDSeriesCount - 1 do
      if DDSeries[j].DDSeriesUID = CurUID then
      begin
        Result := j;
        Exit;
      end;
  end; // function SearchSeries


begin
  N_Dump2Str( 'K_CMBuildImpDataFromFFList start' );
  AImpData := nil;

  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    N_Dump1Str( format( 'K_CMBuildImpDataFromFFList >> DLInitAll error %d', [Result] ) );
    Exit;
  end;

  // Build Files List
  SL := TStringList.Create;
  K_CMEDAccess.TmpStrings.Clear;
  for i := 0 to AFNames.Count - 1 do
  begin
    FName := AFNames[i];
    if SysUtils.DirectoryExists(FName) then // Folder
    begin
      K_ScanFilesTree( IncludeTrailingPathDelimiter(FName), K_CMEDAccess.EDASelectDataFiles )
    end
    else // File
      SL.Add( FName );
  end;

  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    FName := K_CMEDAccess.TmpStrings[i];
    FN := UpperCase(ExtractFileName( FName ));
    if FN = 'DICOMDIR' then Continue;
    FExt := ExtractFileExt(FN);
    if (FExt <> '.DCM') and (FExt <> '.DIC') and (FExt <> '') then Continue;
    SL.Add( FName );
  end; // for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do

  Result := 0;
  AImpData := nil;
  PNL := TStringList.Create();
  PNL.Delimiter := '^';

  CountPat := 0;
  with K_DCMGLibW do
  begin
    SetLength( WBuf, BufLeng );
    for i := 0 to SL.Count - 1 do
    begin
      FName := SL[i];
      N_Dump2Str( 'Start ' +  FName );
      WStr := N_StringToWide( FName );
      DI := DLCreateInstanceFromFile( @WStr[1], 255 );
      if DI = nil then
      begin
        N_Dump1Str( 'K_CMBuildImpDataFromFFList >> DLCreateInstanceFromFile error' );
        Continue;
      end;
      if 0 <> K_CMDGetDIBAttrs( DI, WBufLength, WWidth, WHeight,
                          WPixFmt, WExPixFmt, WNumBits, N_Dump2Str ) then
      begin
        N_Dump1Str( 'K_CMDGetDIBAttrs >> error' );
        Continue;
      end;

      // Get Patients Data
      with DPatient do
      begin
        // Clear DPatient
        DDPatSurname   := ''; // Patient Surname
        DDPatFirstname := ''; // Patient First name
        DDPatMiddle    := ''; // Patient Middle
        DDPatTitle     := ''; // Patient title
        DDPatDOB       := ''; // Info for DICOM attribute Patient's Birth Date (0010,0030) - string format yyyymmdd
        DDPatSex       := ''; // Info for DICOM attribute Patient's Sex (0010,0040) - single char string: "Ì" - male, "F" - female
        DDPatID        := ''; // Info for DICOM attribute Patient ID (0010,0020)
        DDStudies      := nil;// Studies attributes array
        DDStudiesCount := 0;  // Number of real Studies Info in DDMedias

        // Get Patient Name
        sz := BufLeng;
        if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsName, @WBuf[1], @sz, @isNil) then
        begin
          N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString PatientsName' );
          Continue;
        end
        else
        if sz > 0 then
        begin
          Str := N_WideToString( Copy( WBuf, 1, sz ) );
          N_Dump2Str( 'PatientName=' + Str );
          PNL.DelimitedText := Str;
          if PNL.Count > 0 then
            DDPatSurname := PNL[0];
          if PNL.Count > 1 then
            DDPatFirstname := PNL[1];
          if PNL.Count > 2 then
            DDPatMiddle := PNL[2];
          if PNL.Count > 3 then
            DDPatTitle := PNL[3];
        end;

        // Get Patient DOB
        sz := BufLeng;
        if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsBirthDate, @WBuf[1], @sz, @isNil) then
        begin
          N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString PatientsBirthDate' );
          Continue;
        end
        else
        if sz > 0 then
        begin
          DDPatDOB := N_WideToString( Copy( WBuf, 1, sz ) );
          N_Dump2Str( 'PatientDOB=' + DDPatDOB );
        end;

        // Get Patient ID
        sz := BufLeng;
        if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientId, @WBuf[1], @sz, @isNil) then
          N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString PatientId' )
        else
        if sz > 0 then
        begin
          DDPatID := N_WideToString( Copy( WBuf, 1, sz ) );
          N_Dump2Str( 'PatientID=' + DDPatID );
        end;

        // Get Patient Sex
        sz := BufLeng;
        if 0 <>	 DLGetValueString( DI, K_CMDCMTPatientsSex, @WBuf[1], @sz, @isNil) then
          N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString PatientsSex' )
        else
        if sz > 0 then
        begin
          DDPatSex := N_WideToString( Copy( WBuf, 1, sz ) );
          N_Dump2Str( 'PatientSex=' + DDPatSex );
        end;
      end; // with DPatient do

      IndPat := SearchPatient();
      if IndPat = -1 then
      begin // Add Patient
        N_Dump2Str( 'Add Patient' );
        IndPat := CountPat;
        Inc(CountPat);
        NewCap  := Length(AImpData);
//        PrevCap := NewCap;
        if K_NewCapacity( CountPat, NewCap ) then
        begin
          SetLength( AImpData, NewCap );
//          FillChar(AImpData[PrevCap], (NewCap - PrevCap) * SizeOf(TK_CMDCMDPatient), 0);
        end;
        AImpData[IndPat] := DPatient;
      end;  // Add Patient

      N_Dump2Str( 'Process Patient Ind=' + IntToStr(IndPat) );

      // Get Study UID
      sz := BufLeng;
      if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @isNil) then
      begin
        N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString StudyInstanceUid' );
      end
      else
//                          if sz > 0 then
      begin
        CurUID := N_WideToString( Copy( WBuf, 1, sz ) );
        N_Dump2Str( 'StudyInstanceUid=' + CurUID  );
      end;

      IndStudy := SearchStudy();
      with AImpData[IndPat] do
      begin
        LoadStudy := FALSE;
        if IndStudy = -1 then
        begin // Add Study
          N_Dump2Str( 'Add Study' );
          IndStudy := DDStudiesCount;
          Inc(DDStudiesCount);
          NewCap  := Length(DDStudies);
//          PrevCap := NewCap;
          if K_NewCapacity( DDStudiesCount, NewCap ) then
          begin
            SetLength(DDStudies, NewCap );
//            FillChar(DDStudies[PrevCap+1], (NewCap - PrevCap) * SizeOf(TK_CMDCMDStudy), 0);
          end;
          DDStudies[IndStudy].DDStudyUID := CurUID;
          LoadStudy := TRUE;
        end;  // Add Study

        N_Dump2Str( 'Process Study Ind=' + IntToStr(IndStudy) );

        with DDStudies[IndStudy] do
        begin
          if LoadStudy then
          begin
            // Get Study Date
            sz := BufLeng;
            if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDate, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString StudyDate' )
            else
            if sz > 0 then
            begin
              DDStudyDate := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'StudyDate=' + DDStudyDate );
            end;

            // Get Study Time
            sz := BufLeng;
            if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyTime, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString StudyTime' )
            else
            if sz > 0 then
            begin
              DDStudyTime := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'StudyTime=' + DDStudyTime );
            end;

            // Get Study Description
            sz := BufLeng;
            if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyDescription, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString StudyDescription' )
            else
            if sz > 0 then
            begin
              DDStudyDescr := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'StudyDescription=' + DDStudyDescr );
            end;

            // Get Study ID
            sz := BufLeng;
            if 0 <>	 DLGetValueString( DI, K_CMDCMTStudyId, @WBuf[1], @sz, @isNil) then
              N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString StudyId' )
            else
            if sz > 0 then
            begin
              DDStudyID := N_WideToString( Copy( WBuf, 1, sz ) );
              N_Dump2Str( 'StudyId=' + DDStudyID );
            end;

         end; // if LoadStudy then

          // Get Series UID
          sz := BufLeng;
          if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @isNil) then
            N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString SeriesInstanceUid' )
          else
          begin
            CurUID := N_WideToString( Copy( WBuf, 1, sz ) );
            N_Dump2Str( 'SeriesInstanceUid=' + CurUID );
          end;

          IndSeries := SearchSeries();
          LoadSeries := FALSE;
          if IndSeries = -1 then
          begin // Add Study
            N_Dump2Str( 'Add Series' );
            IndSeries := DDSeriesCount;
            Inc(DDSeriesCount);
            NewCap  := Length(DDSeries);
//              PrevCap := NewCap;
            if K_NewCapacity( DDSeriesCount, NewCap ) then
            begin
              SetLength(DDSeries, NewCap );
//                FillChar(DDSeries[PrevCap], (NewCap - PrevCap) * SizeOf(TK_CMDCMDSeries), 0);
            end;
            DDSeries[IndSeries].DDSeriesUID := CurUID;
            LoadSeries := TRUE;
          end;  // Add Study

          N_Dump2Str( 'Process Series Ind=' + IntToStr(IndSeries) );

          with DDSeries[IndSeries] do
          begin
            if LoadSeries then
            begin
              // Get Series Date
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDate, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString SeriesDate' )
              else
//                          if sz > 0 then
              begin
                DDSeriesDate := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'SeriesDate=' + DDSeriesDate );
              end;

              // Get Series Time
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesTime, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString SeriesTime' )
              else
//                          if sz > 0 then
              begin
                DDSeriesTime := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'SeriesTime=' + DDSeriesTime );
              end;

              // Get Series Description
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesDescription, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString SeriesTime' )
              else
//                          if sz > 0 then
              begin
                DDSeriesDescr := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'SeriesTime=' + DDSeriesDescr );
              end;

              // Get Series Modality
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTModality, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString Modality' )
              else
              if sz > 0 then
              begin
                DDSeriesMod := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'Modality=' + DDSeriesMod );
              end;

              // Get Series Number
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString SeriesNumber' )
              else
              if sz > 0 then
              begin
                DDSeriesNum := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'SeriesNumber=' + DDSeriesNum );
              end;
            end; // if LoadSeries then

            N_Dump2Str( 'Add Media' );
            IndMedia := DDMediasCount;
            Inc(DDMediasCount);
            NewCap  := Length(DDMedias);
//              PrevCap := NewCap;
            if K_NewCapacity( DDMediasCount, NewCap ) then
            begin
              SetLength(DDMedias, NewCap );
//                FillChar(DDMedias[PrevCap], (NewCap - PrevCap) * SizeOf(TK_CMDCMDMedia), 0);
            end;
            N_Dump2Str( 'Process Media Ind=' + IntToStr(IndMedia) );
            with DDMedias[IndMedia] do
            begin
              DDMediaFile := FName;

            // Load Media Data
              // Get Instance UID
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString SOPInstanceUid' )
              else
//                          if sz > 0 then
              begin
                DDMediaUID := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'MediaUid=' + DDMediaUID );
              end;

              // Get Content Date
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTContentDate, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString ContentDate' )
              else
//                          if sz > 0 then
              begin
                DDMediaDate := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'ContentDate=' + DDMediaDate );
              end;

              // Get Content Time
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTContentTime, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetrValueString ContentTime' )
              else
//                          if sz > 0 then
              begin
                DDSeriesTime := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'ContentTime=' + DDMediaTime );
              end;

              // Get Acquisition Date
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionDate, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString AcquisitionDate' )
              else
//                          if sz > 0 then
              begin
                DDMediaADate := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'AcquisitionDate=' + DDMediaADate );
              end;

              // Get Acquisition Time
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString AcquisitionTime' )
              else
//                          if sz > 0 then
              begin
                DDMediaATime := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'AcquisitionTime=' + DDMediaATime );
              end;

              // Get KVP
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTKvp, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString KVP' )
              else
//                          if sz > 0 then
              begin
                DDMediaKVP := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'KVP=' + DDMediaKVP );
              end;

              // Get ExposureTime
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTExposureTime, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString ExposureTime' )
              else
//                          if sz > 0 then
              begin
                DDMediaExpTime := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'ExposureTime=' + DDMediaExpTime );
              end;

              // Get TubeCurrent
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTXrayTubeCurrent, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString TubeCurrent' )
              else
//                          if sz > 0 then
              begin
                DDMediaTubeCurrent := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'TubeCurrent=' + DDMediaTubeCurrent );
              end;

              // Get RadiationDose
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTImageAndFluroscopyAreaDoseProduct, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString RadiationDose' )
              else
//                          if sz > 0 then
              begin
                DDMediaRadiationDose := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'RadiationDose=' + DDMediaRadiationDose );
              end;

              // Get ExposureControlMode
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTExposureControlMode, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetValueString ExposureControlMode' )
              else
//                          if sz > 0 then
              begin
                DDMediaExpCMode := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'ExposureControlMode=' + DDMediaExpCMode );
              end;

              // Get Instance Number
              sz := BufLeng;
              if 0 <>	 DLGetValueString( DI, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @isNil) then
                N_Dump1Str( 'K_CMBuildImpDataFromFFList >> wrong DLGetDcmDirValueString InstanceNumber' )
              else
              if sz > 0 then
              begin
                DDMediaNum := N_WideToString( Copy( WBuf, 1, sz ) );
                N_Dump2Str( 'InstanceNumber=' + DDMediaNum );
              end;

              N_Dump2Str( 'DLDeleteDcmObject before' );
              WUInt2 := DLDeleteDcmObject( DI );
              if 0 <> WUInt2 then
                N_Dump1Str( format( 'K_CMBuildImpDataFromFFList >> wrong DLDeleteDcmObject %d', [WUInt2] ) );

            end; // with DDMedias[IndMedia] do
          end; // with DDSeries[IndSeries] do
//          end; // if LoadStudy then
        end; // with DDStudies[IndStudy] do
      end; // with AImpData[IndPat] do
    end; // for i := 0 to SL.Count - 1 do
    SetLength( AImpData, CountPat );
  end; // with K_DCMGLibW do

  SL.Free();
  N_Dump1Str( 'K_CMBuildImpDataFromFFList fin' );
end; // function K_CMBuildImpDataFromFFList

//********************************************* K_CMDCMServerTestConnection ***
// Test DICOM Server connection
//
//     Parameters
// AIP   - ip Adress string
// APort - port number
// AETScp - Application Title for SCP
// AETScu - Application Title for SCU
// ASkipEcho - if TRUE then skip echo request to PACS
// Result - returns TRUE if coonection is OK
//
function K_CMDCMServerTestConnection( const AIP : string; APort : Integer; const AETScp, AETScu : string; ATimeOut : Integer; ASkipEcho : Boolean = FALSE ) : Boolean;
var
  hSrv : TK_HSRV;
  WStr1, WStr2, WStr3 : WideString;
  ErrLeng : Integer;
begin
  N_Dump2Str( 'DCMServerTestConnection start' );
  Result := FALSE;
  if (AETScp <> '') and (AIP <> '') then
    with K_DCMGLibW do
    begin
      WStr1 := N_StringToWide(AIP);
      WStr2 := N_StringToWide(AETScp);
      WStr3 := N_StringToWide(AETScu);

      N_T1.Start();
      hSrv := DLConnectEcho( @WStr1[1], APort, @WStr2[1], @WStr3[1], ATimeOut );
      N_T1.Stop();
      Result := hSrv <> nil;
      N_Dump1Str( format( 'DCMServerTestConnection Name=%s IP=%s Port=%d AetScu=%s Done=%s Time=%s',
        [AETScp,AIP,APort,AetScu,N_B2S(Result),N_T1.ToStr()] ) );
      if Result then
      begin
        if not ASkipEcho then
        begin
          if DLEcho(hSrv) <> 0 then
          begin
            SetLength( WStr3, 1024 );
            ErrLeng := 1024;
            DLGetSrvLastErrorInfo( hSrv, @WStr3[1], @ErrLeng );
            SetLength( WStr3, ErrLeng );
            N_Dump1Str( 'DCMServerTestConnection ECHO Error >> ' + WStr3 );
            Result := FALSE;
          end
          else
            N_Dump2Str( 'DCMSerevrTestConnection ECHO success' );
        end; // if not ASkipEcho then
        DLCloseConnection(hSrv);
        DLDeleteSrvObject(hSrv);
      end // if ServerConnectionIsDone then
//      else
//        N_Dump1Str( 'DCMServerTestConnection failes' );
    end // with K_DCMGLibW do
  else
    N_Dump1Str( 'DCMServerTestConnection Connection Attrs are absent' );

end; // function K_CMDCMServerTestConnection

//******************************************************** K_DCMStoreExport ***
// DICOM Store Export
//
//     Parameters
// APSlide      - Pointer to 1-st exported slide in array
// ASlidesCount - number of slides to export
// AlreadyExistsCount - Resulting number of already exists in store buffer files
// AOutOfMemoryCount  - Resulting number of out of memory slides count
// AErrCount          - Resulting number of export error slides count
// Result - returns Exported Slides Count
//
function K_DCMStoreExport( APSlide: TN_PUDCMSlide; ASlidesCount: Integer; AExpPath : string;
                           out AlreadyExistsCount, AOutOfMemoryCount, AErrCount : Integer  ) : Integer;
var
  i, DCMResCode : Integer;
  WDCMFNames, WStudiesUID, WStudiesSID, WSeriesUID, WSeriesSID, WContentUID, WContentSID : TN_SArray;
  WStudiesTS, WSeriesTS, WContentTS, WAcqTS : TN_DArray;
  SlideDIB : TN_DIBObj;
  CurExportPath, FName : string;
//  SQLWhere : string;

  WSlides: TN_UDCMSArray;
  WPSlide: TN_PUDCMSlide;

label LCont;

begin

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    // Get DICOM export attributes
    EDAGetDCMSlideUCAttrs( APSlide, ASlidesCount,
               WDCMFNames, WStudiesUID, WStudiesSID, WStudiesTS,
               WSeriesUID, WSeriesSID, WSeriesTS,
               WContentUID, WContentSID, WContentTS, WAcqTS );

    Result := 0;
    AOutOfMemoryCount := 0;
    AErrCount := 0;
    AlreadyExistsCount := 0;
    SetLength( WSlides, ASlidesCount );
    WPSlide := APSlide;
    if AExpPath <> '' then
      CurExportPath := IncludeTrailingPathDelimiter( AExpPath )
    else
      CurExportPath := K_ExpandFileName( '(#WrkFilesRoot#)' ) + K_CMDCMStoreBufLPath;
    K_ForceDirPath( CurExportPath );

    for i := 0 to ASlidesCount - 1 do
    with  WPSlide^ do
    begin
      FName := format( '%s%s_%d.dcm', [CurExportPath, ObjName, P()^.CMSPatID] );
      if FileExists( FName ) then
      begin
        N_Dump1Str( 'K_DCMStoreExport Already Exists in buffer >> ' + FName );
        Inc(WPSlide);
        Inc(AlreadyExistsCount);
//        Inc(WPSlide);
        Continue;
      end;

      SlideDIB := ExportToDIB([K_bsedSkipConvGrey16To8,K_bsedSkipAnnotations]);
      if SlideDIB = nil then
      begin
        N_Dump1Str( 'K_DCMStoreExport OutOfMemory >> ' + FName );
        Inc(AOutOfMemoryCount);
        Inc(WPSlide);
        Continue;
      end
      else
      begin // SlideDIB <> nil
        try
          // Export to Raster File
          N_Dump2Str( 'K_DCMStoreExport >> before K_CMDCMExportDCMSlideToFile >>' + FName );
          DCMResCode := K_CMDCMExportDCMSlideToFile( WPSlide^, SlideDIB, FName,
                              WDCMFNames[i], WStudiesUID[i], WStudiesSID[i], WStudiesTS[i],
                              WSeriesUID[i], WSeriesSID[i], WSeriesTS[i],
                              WContentUID[i], WContentSID[i], WContentTS[i], WAcqTS[i] );

          N_Dump2Str( 'K_DCMStoreExport >> after K_CMDCMExportDCMSlideToFile' );

          if DCMResCode <> 0 then
          begin
            N_Dump1Str( format( 'K_DCMStoreExport >> K_CMDCMExportDCMSlideToFile file error >> FName="%s" ResCode=%d',
                                [FName,DCMResCode] ) );
            Inc(AErrCount);
            if FileExists(FName) then
              K_DeleteFile( FName ); // Delete bad file
            goto LCont;
          end
          else
          begin
            WSlides[Result] := WPSlide^;
//            WPSlide.CMSDCMFSet := WPSlide.CMSDCMFSet * [K_bsdcmsStore];
            Inc(Result);
          end;
LCont: //******
          Inc(WPSlide);

        except
          on E: Exception do
          begin
            N_Dump1Str( format( 'K_DCMStoreExport Error >> FName="%s" E=', [FName,E.Message]) );
            Inc(AErrCount);
            if FileExists(FName) then
              K_DeleteFile( FName ); // Delete bad file
          end;
        end; // try

        FreeAndNil( SlideDIB );
      end; // SlideDIB <> nil
    end; // with  WPSlide^ do
{
    // Set Corresponding History Event and State
    if Result > 0 then
    begin
      EDASaveSlidesListHistory( @WSlides[0], Result,
          EDABuildHistActionCode( K_shATNotChange,
                                 Ord(K_shNCADICOM),
                                 Ord(K_shNCADCMStore) ) );
      if K_CMEDDBVersion >= 44 then
      begin
        EDABuildSelectSQLBySlidesList( @WSlides[0], Result, @SQLWhere, nil );

        // Set Slides Processed Flags
        with CurSQLCommand1 do
        begin
          // Set "Put to DCM Store buffer" flag - 00000001
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
            K_CMENDBSTFSlideDFlags + ' = ' + K_CMENDBSTFSlideDFlags + ' ^ 3 | 1' +
            ' where ' + SQLWhere;
          Execute;
        end;
      end; // if K_CMEDDBVersion >= 44 then
    end; // if Result > 0 then
}
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
end; // function K_DCMStoreExport

//************************************** K_DCMCreateSlideFromInstanceHandle ***
// Create Slide from DICOM Instance Handle
//
//     Parameters
// ADI - DICOM Instance Handle
// Result - returns created Slide
//
function K_DCMCreateSlideFromInstanceHandle( ADI : TK_HDCMINST; ACurPatID : Integer; const AFName : string ) : TN_UDCMSlide;
var
  ResCode : Integer;
  ImpDIB : TN_DIBObj;
  Str, Str1 : string;
  WCMFName, TransferSyntax, WBufStr : WideString;
  WUInt2 : TN_UInt2;

  SDate, SDateY, SDateM, SDateD, STime, STimeH, STimeN, STimeS : string;
  YY,MM,DD,HH,NN,SS  :Integer;

  function GetTagValue( ATAG : TN_UInt4; const ATagName : string ) : string;
  var
    sz : Integer;
    isNil : Integer;
  begin
    sz := 1024;
    Result := '';
    if 0 <>	 K_DCMGLibW.DLGetValueString( ADI, ATAG, @WBufStr[1], @sz, @isNil) then
      N_Dump1Str( 'K_DCMCreateSlideFromInstanceHandle >> GetTag ' + ATagName )
    else
    begin
      Result := N_WideToString( Copy( WBufStr, 1, sz ) );
      N_Dump2Str( '>>' + ATagName + '=' + Result );
    end;
  end; // function GetTagValue

  procedure ParseDateTime();
  var
    IndT : Integer;
  begin
    SDateY := Copy(Str, 1, 4);
    SDateM := Copy(Str, 5, 2);
    SDateD := Copy(Str, 7, 2);

    YY := StrToIntDef(SDateY,-100);
    MM := StrToIntDef(SDateM,-100);
    DD := StrToIntDef(SDateD,-100);

    SDate := '';
    if (YY <> -100) and (YY >= 1899) and
       (MM <> -100) and (MM >= 1) and (MM <= 12) and
       (DD <> -100) and (DD >= 1) and (DD <= 31) then
      SDate := format( '%s/%s/%s', [SDateD, SDateM, SDateY] );

    STimeH := Copy(Str1, 1, 2);
    IndT := 3;
    if (Length(Str1) > IndT) and
       ((Str1[IndT] < '0') or (Str1[IndT] > '9')) then Inc(IndT);
    STimeN := Copy(Str1, IndT, 2);
    IndT := IndT + 2;
    if (Length(Str1) > IndT) and
       ((Str1[IndT] < '0') or (Str1[IndT] > '9')) then Inc(IndT);
    STimeS := Copy(Str1, IndT, 2);

    HH := StrToIntDef(STimeH,-100);
    NN := StrToIntDef(STimeN,-100);
    SS := StrToIntDef(STimeS,-100);
    STime := '';
    if (HH <> -100) and (HH >= 0) and (HH <= 23) and
       (NN <> -100) and (NN >= 0) and (NN <= 59) and
       (SS <> -100) and (SS >= 0) and (SS <= 59) then
      STime := format( '%s:%s:%s', [STimeH, STimeN, STimeS] );
  end; // ParseDateTime();

begin
  Result := nil;
  ResCode := K_CMDCMImportDIB( '', ImpDIB, ADI );
  if ResCode <> 0 then
  begin
    N_Dump1Str( 'CreateSlideFromInstance >> K_CMDCMImportDIB ResCode=' + IntToStr(ResCode) );
    Exit;
  end;

  Result := K_CMSlideCreateFromDIBObj( ImpDIB, nil );
  if Result = nil then
  begin
    N_Dump1Str( 'CreateSlideFromInstance >> K_CMSlideCreateFromDIBObj error' );
    Exit;
  end;

  with K_DCMGLibW, Result, Result.P()^, CMSDB do
  begin
    SetLength( WBufStr, 1024 );
  // Add Slide attrs from DCM attrs

    CMSPatId := ACurPatID; // Patient ID
    CMSSourceDescr := 'Retrieved from ' + ExtractFileName(AFName);

    DCMModality := GetTagValue( K_CMDCMTModality, 'Modality' );
    if Length(DCMModality) <> 2 then DCMModality := '';

    Str := GetTagValue( K_CMDCMTKvp, 'KVP' );
    if Str <> '' then
    begin
      DCMKVP := StrToFloatDef( Str, 0 );
//      if DCMKVP = K_CMSlideDefDCMKVP then
//        DCMKVP := 0;
    end;

    Str := GetTagValue( K_CMDCMTExposureTime, 'ExposureTime' );
    if Str <> '' then
    begin
      DCMExpTime := StrToIntDef( Str, 0 );
//      if DCMExpTime = K_CMSlideDefDCMExpTime then
//        DCMExpTime := 0;
    end;

    Str := GetTagValue( K_CMDCMTXrayTubeCurrent, 'TubeCurrent' );
    if Str <> '' then
    begin
      DCMTubeCur := StrToIntDef( Str, 0 );
//      if DCMTubeCur = K_CMSlideDefDCMTubeCur then
//        DCMTubeCur := 0;
    end;

//    Str := GetTagValue( K_CMDCMTCommentsOnRadiationDose, 'RadiationDose' );
    Str := GetTagValue( K_CMDCMTImageAndFluroscopyAreaDoseProduct, 'RadiationDose' );
    if Str <> '' then
    begin
      DCMRDose := StrToFloatDef( Str, 0 );
    end;

    Str := GetTagValue( K_CMDCMTExposureControlMode, 'ExposureCtrlMode' );
    if Str <> '' then
    begin
      DCMECMode := 0;
      Str := UpperCase(Str);
      if Str = 'MANUAL' then
        DCMECMode := 1
      else
      if Str = 'AUTOMATIC' then
        DCMECMode := 2;
    end; // if Str <> '' then

    Str := GetTagValue( K_CMDCMTContentDate, 'ContentDate' );
    Str1 := GetTagValue( K_CMDCMTContentTime, 'ContentTime' );
    if (Str1 = '') or (Str = '') then
    begin
      Str := GetTagValue( K_CMDCMTAcquisitionDate, 'AcquisitionDate' );
      Str1 := GetTagValue( K_CMDCMTAcquisitionTime, 'AcquisitionTime' );
      if (Str1 = '') or (Str = '') then
      begin
        Str := GetTagValue( K_CMDCMTSeriesDate, 'SeriesDate' );
        Str1 := GetTagValue( K_CMDCMTSeriesTime, 'SeriesTime' );
        if (Str1 = '') or (Str = '') then
        begin
          Str := GetTagValue( K_CMDCMTStudyDate, 'StudyDate' );
          Str1 := GetTagValue( K_CMDCMTStudyTime, 'StudyTime' );
        end;
      end;
    end;
    ParseDateTime();
    if (SDate <> '') and (STime <> '') then
      CMSDTTaken := EncodeDateTime( YY,MM,DD, HH,NN,SS, 0 );

    K_CMEDAccess.EDAAddSlide( Result );
  // Save DCM Attrs to FileStorage
    DLRemoveTag( ADI, K_CMDCMTPixelData );
    // Name in EmCache
    Str := Result.CMSlideECFName;
    Str[Length(Str) - 4] := 'D';
    WCMFName := N_StringToWide( Str );

    TransferSyntax := K_CMDCMUID_LittleEndianExplicitTransferSyntax;
    WUInt2 := DLSaveInstance( ADI, @WCMFName[1], @TransferSyntax[1] );
    if 0 <> WUInt2 then
      N_Dump1Str( format( 'CreateSlideFromInstance >> DLSaveInstance >> wrong DLSaveInstance [%s] %d >> %s', [TransferSyntax, WUInt2, Str] ) );
  end;
end; // function K_DCMCreateSlideFromInstanceHandle

{*** TK_CMDCMStoreFilesThread ***}

//***************************** TK_CMDCMStoreFilesThread.DCMSFileCopyCreate ***
// Try to lock processing file and copy
//
function TK_CMDCMStoreFilesThread.DCMSFileCopyCreate( ): Boolean;
begin
  Result := FALSE; // DCMSSrcFName, DCMSDstFName

  try
    DCMSFStream := TFileStream.Create(DCMSSrcFName, fmOpenReadWrite);
  except
    DCMSFStream := nil;
    Exit;
  end;

  if DCMSFStream.Size = 0 then
  begin
    FreeAndNil( DCMSFStream );
    K_DeleteFile( DCMSSrcFName );
    Exit;
    
  end; // if DCMSFStream.Size = 0

  DCMSRFStream  := TFileStream.Create(DCMSDstFName, fmCreate);
  DCMSRFStream.CopyFrom( DCMSFStream, 0 );

  FreeAndNil( DCMSRFStream );
  Result := TRUE;

end; // function TK_CMDCMStoreFilesThread.DCMSFileCopyCreate

//****************************** TK_CMDCMStoreFilesThread.DCMSFileCopyStore ***
// Store File Copy
//
function TK_CMDCMStoreFilesThread.DCMSFileCopyStore : Boolean;
var
  WUInt2 : TN_UInt2;
  WStr, WStr1, WTS, WSCN  : WideString;
  ErrStr, SWSC, SWSCN : string;
  Ind, Ind1, BLeng : Integer;
  ResCode : Integer;
  sz : Integer;
  IsNil : Integer;
  SLeng : Integer;
  IPos, IPos1 : Integer;

label DEB;
begin
  Result := FALSE;
  with K_DCMGLibW do
  begin

    WStr := N_StringToWide(DCMSDstFName);
    DCMDI := DLCreateInstanceFromFile( @WStr[1], 255);
    if DCMDI = nil then
    begin
      FreeAndNil(DCMSFStream); // Free DCMSSrcFName
      DCMSDumpStr := 'DCM Load error file ' + DCMSDstFName;
      Synchronize( DCMSSyncDump1Str );
      Exit;
    end;

    DCMInstUID := '';
    if (K_CMEDDBVersion >= 45) and K_CMDCMStoreCommitmentFlag then
    begin // Get SOPInstanceUID
      sz := 99;
      ResCode := DLGetValueString( DCMDI, K_CMDCMTSopInstanceUid, @DCMSWBuf[1], @sz, @isNil);
      if ResCode <>	0 then
      begin
        FreeAndNil(DCMSFStream); // Free DCMSSrcFName
        DCMSDumpStr := 'DCM Could not read SopInstanceUID';
        Synchronize( DCMSSyncDump1Str );
      end
      else
        DCMInstUID := N_WideToString( Copy( DCMSWBuf, 1, sz ) );
    end; // if (K_CMEDDBVersion >= 45) and K_CMDCMStoreCommitmentFlag then

    sz := 99;
    ResCode := DLGetValueString( DCMDI, K_CMDCMTSopClassUid, @DCMSWBuf[1], @sz, @isNil);
    WUInt2 := DLDeleteDcmObject( DCMDI );
    if 0 <> WUInt2 then
    begin
      DCMSDumpStr := format( 'DCM wrong DLDeleteDcmObject  %d', [WUInt2] );
      Synchronize( DCMSSyncDump1Str );
    end;

    if ResCode <>	0 then
    begin
      FreeAndNil(DCMSFStream); // Free DCMSSrcFName
      DCMSDumpStr := 'DCM Could not read SopClassUID';
      Synchronize( DCMSSyncDump1Str );
      Exit;
    end;

    WSCN := Copy( DCMSWBuf, 1, sz );

    if DCMWSC = '' then
{}
      DCMWSC := K_CMDCMUID_ComputedRadiography_SOPClass +'\'+
                K_CMDCMUID_DigitalXRay_SOPClass+'\'+
                K_CMDCMUID_DigitalIntraOralXRay_SOPClass+'\'+
                K_CMDCMUID_CT_SOPClass+'\'+
                K_CMDCMUID_SecondaryCapture_SOPClass+'\'+
                K_CMDCMUID_VLEndoscopic_SOPClass+'\'+
                K_CMDCMUID_VLMicroscopic_SOPClass+'\'+
                K_CMDCMUID_VLPhotographic_SOPClass;
{}
{
      DCMWSC := K_CMDCMUID_DigitalIntraOralXRay_SOPClass +'\'+
                K_CMDCMUID_DigitalXRay_SOPClass+'\'+
                K_CMDCMUID_SecondaryCapture_SOPClass+'\'+
                K_CMDCMUID_VLEndoscopic_SOPClass+'\'+
                K_CMDCMUID_VLPhotographic_SOPClass;
{}

    SWSC  := N_WideToString( DCMWSC );
    SWSCN := N_WideToString( WSCN );
    DCMClassUID := SWSCN;
    Ind1 := 1;
    Ind := 0;
    SLeng := Length(SWSC);
    while TRUE do
    begin
      Ind := N_PosEx( SWSCN, SWSC, Ind1, SLeng );
      if Ind = 0 then break
      else
      begin
        if (Ind  + sz - 1 = SLeng) or (SWSC[Ind + sz] = '\') then break;
        Ind1 := Ind  + sz;
        if Ind1 > SLeng then
        begin
          Ind := 0;
          break;
        end;
      end;
    end; // while TRUE do

    if Ind = 0 then
    begin // Add new SOPClassUID
      DCMWSC := DCMWSC + '\' + WSCN;
      if DCMSHSRV <> nil then
      begin
        DLCloseConnection(DCMSHSRV);
        DLDeleteSrvObject(DCMSHSRV);
        DCMSHSRV := nil;
      end; // if DCMSHSRV <> nil then
    end; // if Ind = 0 then
    
    if (DCMSHSRV = nil) and (DCMSSRVAETScp <> '') and (DCMSSRVIP <> '') then
    begin
      WTS := K_CMDCMUID_JPEGProcess14SV1TransferSyntax+'\'+
             K_CMDCMUID_LittleEndianImplicitTransferSyntax+'\'+
             K_CMDCMUID_LittleEndianExplicitTransferSyntax;
      DCMSHSRV := DLConnectStoreScp( @DCMSSRVIP[1], DCMSSRVPort, @DCMSSRVAETScp[1], @DCMSSRVAETScu[1],
                                     @DCMWSC[1], @WTS[1] );
    end;

    if DCMSHSRV = nil then
    begin // DLConnectStoreScp error
      FreeAndNil(DCMSFStream); // Free DCMSSrcFName
      DCMSDumpStr := format( 'DCM Store connection error for %s | IP=%s Port=%d AetScp=%s AetScu=%s',
                             [DCMSDstFName,DCMSSRVIP,DCMSSRVPort,DCMSSRVAETScp,DCMSSRVAETScu] );
      Synchronize( DCMSSyncDump1Str );
{//DEB
DCMObjName := ExtractFileName(DCMSDstFName);
IPos := Pos( '_', DCMObjName );
DCMPatID := '';
if IPos > 0 then
begin
  DCMPatID := Copy( DCMObjName, IPos + 1, 100);
  DCMObjName := Copy( DCMObjName, 1, IPos - 1 );
end;
DCMStoreRes := TRUE;
DCMSDumpStr := 'Test Events';
Synchronize( DCMSSyncSetEventStatus );
Result := TRUE; // for removing file
{}
    end
    else
    begin
      WStr := N_StringToWide(DCMSDstFName);
      WUInt2 := DLSendFile( DCMSHSRV, @WStr[1] );
//    WUInt2 := DLSendInstance( DCMSHSRV, DI );
      DCMObjName := ExtractFileName(DCMSDstFName);
      IPos := Pos( '_', DCMObjName );

      DCMPatID := '';
      DCM3DSlice := '';
      if IPos > 0 then
      begin
        if IPos < Length(DCMObjName) then
        begin
          DCMPatID := Copy( DCMObjName, IPos + 1, 100);
          IPos1 := Pos( '_', DCMPatID );
          if IPos1 > 0 then
          begin
            DCM3DSlice := Copy( DCMPatID, IPos1 + 1, 100);
            DCMPatID := Copy( DCMPatID, 1, IPos1 - 1);
          end;
        end;
        DCMObjName := Copy( DCMObjName, 1, IPos - 1 );
      end;
      if DCMPatID = '' then
      begin // if  PatID  is not defined
        DCMSDumpStr := format( 'DCM Store FileName=%s',
                               [ExtractFileName(DCMSDstFName)] );
        Synchronize( DCMSSyncDump1Str );
      end;

      Result := WUInt2 = 0;
      if Result then
      begin
        DCMSDumpStr := 'DCM Store file ' + DCMSDstFName;
        DCMStoreRes := TRUE;
        Synchronize( DCMSSyncSetEventStatus );

//        Synchronize( DCMSSyncDump1Str );
      end
      else
      begin
        FreeAndNil(DCMSFStream); // Free DCMSSrcFName
        SetLength( WStr, 1024 );
        BLeng := 1024;
        DLGetSrvLastErrorInfo( DCMSHSRV, @WStr[1], @BLeng );

        SetLength( WStr1, BLeng );
        Move( WStr[1], WStr1[1], BLeng * SizeOf(Char) );
        ErrStr := N_WideToString(WStr1);

        DCMSDumpStr := format( 'DCM Store SendFile error %s >> %s',
                               [DCMSDstFName, ErrStr] );
        DCMStoreRes := FALSE;
        Synchronize( DCMSSyncSetEventStatus );
        Result := TRUE; // for removing file after DCMSFileCopyStore
//        Synchronize( DCMSSyncDump1Str );
      end;
    end;
  end; // with K_DCMGLibW do

end; // procedure TK_CMDCMStoreFilesThread.DCMSFileCopyStore

//***************************** TK_CMDCMStoreFilesThread.DCMSRemoveProcFile ***
// Remove Proccessed File
//
procedure TK_CMDCMStoreFilesThread.DCMSRemoveProcFile;
begin
  if DCMSFStream <> nil then // precaution
  begin
    DCMSFStream.Size := 0;
    FreeAndNil(DCMSFStream);
  end;
  K_DeleteFile( DCMSSrcFName );
end; // procedure TK_CMDCMStoreFilesThread.DCMSRemoveProcFile

//******************************* TK_CMDCMStoreFilesThread.DCMSSyncDump1Str ***
// Synchronized Dump1 string
//
procedure TK_CMDCMStoreFilesThread.DCMSSyncSetEventStatus;
var
  SQLStr : string;
  SFlag : string;
  SCode : Byte;
  IPatID, ISlideID : Integer;
begin
  SQLStr := K_CMENDBSTFSlideID + '=' + DCMObjName;
  if DCMStoreRes then
  begin
    SCode := Ord(K_shNCADCMStore);
    SFlag := '1'; // [K_bsdcmsStore]
  end   // if DCMStoreRes then
  else
  begin // if not DCMStoreRes then
    SCode := Ord(K_shNCADCMStoreErr);
    SFlag := '2'; // [K_bsdcmsStoreErr]
  end;  // if not DCMStoreRes then

  // Save change DICOM status events
  with K_CMEDAccess do
    EDASaveSlidesHistory( SQLStr, EDABuildHistActionCode( K_shATNotChange,
                             Ord(K_shNCADICOM),
                             SCode ) );

  // Update DICOM status
  if K_CMEDDBVersion >= 44 then
  begin
    // Set Slides Processed Flags
    with TK_CMEDDBAccess(K_CMEDAccess).CurSQLCommand1 do
    begin
      // Set "Put to DCM Store buffer" flag - 00000002
      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
        K_CMENDBSTFSlideDFlags + ' = ' + K_CMENDBSTFSlideDFlags + ' & 252 | ' + SFlag +
        ' where ' + SQLStr;
      Execute;
    end;
  end; // if K_CMEDDBVersion >= 44 then

  // Set Patient changed flag for AutoRefresh
  if DCMPatID <> '' then
  begin // set patient change flag
    // get file name
    IPatID := StrToIntDef( DCMPatID, -1 );
    if IPatID <> -1 then
    begin
      SFlag := TK_CMEDDBAccess(K_CMEDAccess).SlidesImgRootFolder +
               K_CMSlideGetPatientFilesPathSegm(IPatID) + '!';
      try
        with TFileStream.Create( SFlag, fmCreate ) do
          Free();
      except
        N_Dump1Str( 'DCM PatID update file create error ' + SFlag );
      end;
    end
    else
      N_Dump1Str( 'DCM PatID error ID=' + DCMPatID );
  end;

  if DCMStoreRes and (DCMInstUID <> '') then
  begin
    ISlideID := StrToIntDef( DCMObjName, 0 );
    if ISlideID = 0 then
    begin
      DCMSDumpStr := format( 'DCM Store strange SlideID=%s', [DCMObjName] );
      Synchronize( DCMSSyncDump1Str );
    end
    else
    // Time shift 5 seconds
      K_CMDCMSlideStoreCommitmentAdd( 5 * 60, ISlideID, DCMInstUID, DCMClassUID );
  end; // if DCMStoreRes and (DCMClassUID <> '') then


  N_Dump1Str( DCMSDumpStr );
end; // procedure TK_CMDCMStoreFilesThread.DCMSSyncSetEventStatus

procedure TK_CMDCMStoreFilesThread.DCMSSyncDump1Str();
begin
  N_Dump1Str( DCMSDumpStr );
end; // procedure TK_CMDCMStoreFilesThread.DCMSSyncDump1Str

//******************************* TK_CMDCMStoreFilesThread.DCMSSyncDump2Str ***
// Synchronized Dump2 string
//
procedure TK_CMDCMStoreFilesThread.DCMSSyncDump2Str();
begin
  N_Dump2Str( DCMSDumpStr );
end; // procedure TK_CMDCMStoreFilesThread.DCMSSyncDump2Str

//************************* TK_CMDCMStoreFilesThread.DCMSSyncGetDCMSettings ***
// Synchronized GetDCMSettings
//
procedure TK_CMDCMStoreFilesThread.DCMSSyncGetDCMSettings();
begin
  if K_CMD4WAppFinState then
  begin
    N_Dump2Str( 'Call DCMSSyncGetDCMSettings after K_CMD4WAppFinState was set' );
    Exit;
  end;

  DCMSSRVIP := N_StringToWide( N_MemIniToString( 'CMS_DCMStoreSettings', 'IP', '' ) );
  DCMSSRVPort := StrToIntDef( N_MemIniToString( 'CMS_DCMStoreSettings', 'Port', '' ), 0 );
  DCMSSRVAETScp := N_StringToWide( N_MemIniToString( 'CMS_DCMStoreSettings', 'Name', ''  ) );
  DCMSSRVAETScu := N_StringToWide( K_CMDCMSetupCMSuiteAetScu() );
{}
  DCMSPath := '';
  if (DCMSSRVIP <> '')     and
     (DCMSSRVPort <> 0)    and
     (DCMSSRVAETScp <> '') then
{}
    DCMSPath := K_ExpandFileName( '(#WrkFilesRoot#)' ) + K_CMDCMStoreBufLPath;
end; // procedure TK_CMDCMStoreFilesThread.DCMSSyncGetDCMSettings

//**************************************** TK_CMDCMStoreFilesThread.Execute ***
// Store DCM Files Thread Execute
//
procedure TK_CMDCMStoreFilesThread.Execute;
var
  F: TSearchRec;
  FPCount, FECount : Integer;

  function SleepAndWaitForTerm( ASecNum : Integer ) : Boolean;
  var i : Integer;
  begin
    Result := TRUE;
    for i := 1 to ASecNum do
    begin
      sleep ( 1000 );
      if Terminated then
        Exit;
    end;
    Result := Terminated;
  end; // function SleepAndWaitForTerm

begin

  while K_DCMGLibW.DLDllHandle = 0 do // Precaution
  begin
    if SleepAndWaitForTerm( 5 ) then Exit;
//    sleep(5000);
//    if Terminated then Exit; // check Terminated at Loop start
  end;

  SetLength( DCMSWBuf, 100 );
  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start

//      if DCMSPath = '' then // get PACS network settings
      Synchronize(DCMSSyncGetDCMSettings);

      if DCMSPath <> '' then
      begin // no empty DCM settings
        FPCount := 0;
        FECount := 0;
        if FindFirst( DCMSPath + '*.dcm', faAnyFile, F ) = 0 then
          repeat
            DCMSSrcFName := DCMSPath + F.Name;
            DCMSDstFName := DCMSPath + ChangeFileExt(F.Name, '' );
            if DCMSFileCopyCreate() then
            begin
              if DCMSFileCopyStore( ) then
                DCMSRemoveProcFile()
              else
                Inc(FECount);

              K_DeleteFile( DCMSDstFName );

              if Terminated then Break; // check Terminated before Sleep

//              sleep(5000); // sleep before next file
              if SleepAndWaitForTerm( 5 ) then Break;
            end;
            Inc(FPCount);
          until FindNext( F ) <> 0;
        FindClose( F );

        if DCMSHSRV <> nil then
          with K_DCMGLibW do
          begin
            DLCloseConnection(DCMSHSRV);
            DLDeleteSrvObject(DCMSHSRV);
            DCMSHSRV := nil;
          end;

        if Terminated then Break; // check Terminated before Sleep

        if FPCount = 0 then
        begin
          if SleepAndWaitForTerm( 10 ) then Break;
          //sleep( 10000 )  // sleep for 10 sec if no files in queue
        end
        else
        if FPCount = FECount then
        begin
          if SleepAndWaitForTerm( 60 ) then Break;
//          sleep( 60000 ); // sleep for 1 min if all files have connection errors
        end;
      end // if DCMSPath <> '' then
//      else
//        sleep(180000); // sleep before next settings test 3 min
    except
      on E: Exception do
      begin
        DCMSDumpStr := 'DCMS> DCMStoreFilesThread exception >> ' + E.Message;
        Synchronize( DCMSSyncDump1Str );
      end;
    end; // try


    if Terminated then Break; // check Terminated before Sleep

    // Sleep before next File Check Loop
    //sleep( 15000 );
    if SleepAndWaitForTerm( 15 ) then Break;

  end; // while TRUE do


end; // procedure TK_CMDCMStoreFilesThread.Execute

{*** end of TK_CMDCMStoreFilesThread ***}

end.
