unit K_CMDCMGLibW;

interface

uses Windows, SysUtils, N_Types;

type TK_HDCMINST = Pointer;
type TK_HDCMDIR = Pointer;
type TK_HDCMDIRITEM = Pointer;
type TK_HSRV = Pointer;
type TK_DCMGLibWrap = class( TObject ) // Object for using wrapdcm.dll
  DLDllHandle: THandle; // wrapdcm.dll Handle (nil if not loaded)
  DLErrorStr:   string; // Error message
//  DLErrorInt:  integer; // Error code
  DLLogFileName: string;  // LogFileName
  DLLogLevel   : Integer; // LogLevel


  ////////////////////////////////////////////////////
  //***** wrapdcm.dll functions:
  DLSetLog:            TN_cdeclProcPtrInt;
  DLInitialize:        TN_cdeclProcVoid;     // ()
  DLFinalize:          TN_cdeclProcVoid;     // ()

  ///////////////////////////////
  // DCM Files API
  DLCreateInstance:    TN_cdeclPtrFunc4Ptr; // ( AStudyInstanceUid, ASeriesInstanceUid, ASopInstanceUid, ASopClassUid: PWideChar ) : TK_HDCMINST
  DLCreateInstanceFromFile: TN_cdeclPtrFuncPtrInt; //( AFileName : PWideChar; ALoadAll : Integer ) : TK_HDCMINST
  DLSaveInstance:      TN_cdeclUInt2Func3Ptr;    // ( PhDs : Pointer; APWchar1, APWchar2 : PWideChar ) : TN_Uint2
  DLDeleteDcmObject:   TN_cdeclUInt2FuncPtr;           // ( PhDs : Pointer ) : TN_Uint2
  DLChangeTransferSyntax : TN_cdeclUInt2Func2PtrInt; // (PhDs : Pointer; const ATS : PWideChar; AQuality : Integer ) : TN_Uint2
  DLAddValueUint16:    TN_cdeclUInt2FuncPtrUIntUInt2; // ( PhDs : Pointer; ATag : TN_UInt4; AValue : TN_UInt2 ) : TN_Uint2
  DLAddValueSint16:    TN_cdeclUInt2FuncPtrUIntInt2;  // ( PhDs : Pointer; ATag : TN_UInt4; AValue : TN_Int2 ) : TN_Uint2
  DLAddValueString:    TN_cdeclUInt2FuncPtrUIntPtr;// ( PhDs : Pointer; ATag : TN_UInt4; const AValue : PWideChar ) : TN_Uint2
  DLAddImageData:      TN_cdeclUInt2Func2PtrUInt;     // ( PhDs, APixelData : Pointer; APixelDataWidthInBytes TN_UInt4 ) : TN_Uint2
  DLRemoveTag:         TN_cdeclUInt2FuncPtrUInt;      // ( PhDs : Pointer; ATag : TN_UInt4 ) : TN_Uint2
  DLGetValueString:    TN_cdeclUInt2FuncPtrUInt3Ptr; // (PhDs : Pointer; ATag : TN_UInt4; const AValue : PWideChar; APtr1, APtr2 : PInteger ) : TN_Uint2
  DLGetSequenceLength: TN_cdeclUInt4FuncPtrUInt; // (PhDs : Pointer; ATag : TN_UInt4 ) : TN_Uint4
  DLGetSequenceItemTagValue: TN_cdeclUInt2FuncPtrUIntIntUInt3Ptr; // (PhDs : Pointer; ATag1 : TN_UInt4; AInt: Integer; ATag2 : TN_UInt4;  const AValue : PWideChar; APtr1, APtr2 : PInteger ) : TN_Uint2
  DLGetValueUint16:    TN_cdeclUInt2FuncPtrUInt2Ptr;  // (PhDs : Pointer; ATag : TN_UInt4; APtr1 : TN_PUint2; APtr2 : PInteger ) : TN_Uint2
  DLGetValueSint16:    TN_cdeclUInt2FuncPtrUInt2Ptr;  // (PhDs : Pointer; ATag : TN_UInt4; const APValue : PWideChar; APtr1 : TN_PInt2; APtr2 : PInteger ) : TN_Uint2
  DLGetTransferSyntax: TN_cdeclUInt2FuncPtrUInt2Ptr; // (PhDs : Pointer; ATag : TN_UInt4; const AValue : PWideChar; APtr : PInteger ) : TN_Uint2
  DLGetImageData:      TN_cdeclUInt2Func2PtrUInt; // ( PhDs, APixelData : Pointer; APixelDataSizeInBytes TN_UInt4 ) : TN_Uint2
  DLGetDsLastErrorInfo:TN_cdeclUInt2Func3Ptr; // ( PhDs : Pointer; const APInfo : PWideChar; APInfoSizeInBytes : PInteger ) : TN_Uint2
  DLGetWindowsDIB: TN_cdeclGetWindowsDIB;
  DLGetDIBSize: TN_cdeclGetDIBSize;

  ///////////////////////////////
  // DICOMDIR API
  DLOpenDICOMDIR:         TN_cdeclPtrFuncPtr; // ( AFileName : PWideChar ) : TK_HDCMDIR;
  DLCloseDICOMDIR:        TN_cdeclProcPtr;       // ( PhDs : Pointer );
  DLDcmDirGetPatientCount:TN_cdeclUIntFuncPtr;   // ( PhDs : Pointer ) : TN_Uint4;
  DLDcmDirGetPatientItem :TN_cdeclPtrFuncPtrInt; // ( PhDs : Pointer; Index : Integer ) : TK_HDCMDIRITEM;
  DLDcmDirGetStudyCount:  TN_cdeclUIntFuncPtr;   // ( PhDs : Pointer ) : TN_Uint4;
  DLDcmDirGetStudyItem:   TN_cdeclPtrFuncPtrInt; // ( PhDs : Pointer; Index : Integer ) : TK_HDCMDIRITEM;
  DLDcmDirGetSeriesCount: TN_cdeclUIntFuncPtr;   // ( PhDs : Pointer ) : TN_Uint4;
  DLDcmDirGetSeriesItem:  TN_cdeclPtrFuncPtrInt; // ( PhDs : Pointer; Index : Integer ) : TK_HDCMDIRITEM;
  DLDcmDirGetFilesCount:  TN_cdeclUIntFuncPtr;   // ( PhDs : Pointer ) : TN_Uint4;
  DLDcmDirGetFileItem:    TN_cdeclPtrFuncPtrInt; // ( PhDs : Pointer; Index : Integer ) : TK_HDCMDIRITEM;
  DLGetDcmDirValueString: TN_cdeclUInt2FuncPtrUInt3Ptr; // (PhDs : Pointer; ATag : TN_UInt4; const AValue : PWideChar; APtr1, APtr2 : PInteger ) : TN_Uint2;
  DLGetDcmDirValueUint16: TN_cdeclUInt2FuncPtrUInt2Ptr; // (PhDs : Pointer; ATag : TN_UInt4; APtr1 : TN_PUint2; APtr2 : PInteger ) : TN_Uint2;

  ///////////////////////////////
  // DICOM COMMON CLEAN UP and SERVICE API
  DLGetSrvLastErrorInfo:TN_cdeclUInt2Func3Ptr; // ( AhQrSession : TK_HSRV const APInfo : PWideChar; APInfoSizeInBytes : PInteger ) : TN_Uint2
  DLCloseConnection:    TN_cdeclUInt2FuncPtr;  // ( AhQrSession : TK_HSRV ) : TN_Uint2
  DLDeleteSrvObject:    TN_cdeclUInt2FuncPtr;  // ( AhQrSession : TK_HSRV ) : TN_Uint2

  ///////////////////////////////
  // DICOM QUERY RETRIEVE API
  DLConnectQrScpFind:     TN_cdeclPtrFuncPtrInt2PtrInt; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar; AModel : Integer ) : TK_HSRV;
  DLConnectQrScpMove:     TN_cdeclPtrFuncPtrInt2PtrInt; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar; AModel : Integer ) : TK_HSRV;
  DLGetQrFindResultObject:TN_cdeclPtrFuncPtrInt; // ( AhQrSession : TK_HSRV; Index : Integer ) : TK_HDCMINST
  DLGetQrFindResultCount: TN_cdeclUInt2FuncPtr;  // ( AhQrSession : TK_HSRV ) : TN_Uint2
  DLFindQr:               TN_cdeclUInt2FuncPtrInt6Ptr; // ( AhQrSession : TK_HSRV; ALevel : Integer; const APatName, APatID, ASudyDate, AetSCU, AMod, ACSNum : PWideChar ) : TN_Uint2;
  DLMove:                 TN_cdeclUInt2FuncPtrInt11Ptr;

  ///////////////////////////////
  // DICOM Echo API
// Belonogov Changeed DLConnectEcho Type???
//  DLConnectEcho : TN_cdeclPtrFuncPWCharInt2PWChar; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar ) : TK_HSRV;
  DLConnectEcho : TN_cdeclPtrFuncPtrInt2PtrInt; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar; AModel : Integer ) : TK_HSRV;
  DLEcho        : TN_cdeclUInt2FuncPtr;  // ( AhQrSession : TK_HSRV ) : TN_Uint2

  ///////////////////////////////
  // DICOM STORE API
  DLConnectStoreScp :     TN_cdeclPtrFuncPtrInt4Ptr; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU, AASynt, ATSynt : PWideChar ) : TK_HSRV;
  DLSendFile:             TN_cdeclUInt2Func2Ptr; // ( AhQrSession : TK_HSRV; const AFName : PWideChar ) : TN_Uint2
  DLSendInstance:         TN_cdeclUInt2Func2Ptr; // ( AhQrSession : TK_HSRV; const ADInst : TK_HDCMINST ) : TN_Uint2

  ///////////////////////////////
  // DICOM Worklist API
  DLConnectMwlScp :     TN_cdeclPtrFuncPtrInt2Ptr; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar ) : TK_HSRV;
  DLFindMwl:            TN_cdeclUInt2Func8Ptr; // ( AhQrSession : TK_HSRV; const AMod, ADate, ATime, AetSCU, APhysician, APatID, APatName : PWideChar ) : TN_Uint2;
  DLGetMwlResultCount:  TN_cdeclUInt2FuncPtr;  // ( AhQrSession : TK_HSRV ) : TN_Uint2
  DLGetMwlResultObject: TN_cdeclPtrFuncPtrInt; // ( AhQrSession : TK_HSRV; Index : Integer ) : TK_HDCMINST

  ///////////////////////////////
  // DICOM MPPS API
  DLConnectMppsScp :  TN_cdeclPtrFuncPtrInt2Ptr; // ( AipSCP : PWideChar; APort : Integer; AetSCP, AetSCU : PWideChar ) : TK_HSRV;
  DLCreateMppsObject: TN_cdeclPtrFunc; // () : TK_HDCMINST
  DLSendMpps:         TN_cdeclUInt2Func2Ptr; // ( AhMppsScp : TK_HSRV; const ADInst : TK_HDCMINST ) : TN_Uint2

  ///////////////////////////////
  // DICOM Storage Commitment API
  DLCreateCommitmentRequest: TN_cdeclPtrFuncPtr;
  DLAddInstanceToCommit: TN_cdeclUInt2Func3Ptr;
  DLConnectStorageCommitmentScp: TN_cdeclPtrFuncPtrInt2Ptr;
  DLSendStorageCommitmentRequest: TN_cdeclUInt2Func2Ptr;

  /////////////////////////////////
  // DICOM Query API
  DLCreateDataset : TN_cdeclPtrFuncVoid;
  DLFindQrByDcmFilter: TN_cdeclUInt2Func2Ptr;


  function DLInitAll    (): Integer;
  function DLFreeAll    (): Integer;


//  function DLExportSlide( ASlide : TN_UDSlide; AFName : string ): Integer;
{
  function DLFreeAll    (): Integer;
  function DLOpenFile   ( AFName: string ): integer;
  function DLOpenStream ( AStream: TStream ): integer;
  function DLCreateFile ( AFName: string; AILFmt: Integer; AOverwrite: Integer = 1 ): integer;
}
end; // type TK_DCMGLibWrap = class( TObject ) // Object for using  wrapdcm.dll


type TK_DCMSCWEBGLib = class( TObject ) // Object for using cmsscweb.dll
  SDLDllHandle: THandle; // cmsscweb.dll Handle (nil if not loaded)
  SDLErrorStr:   string; // Error message
  SDLLogFileName: string;  // LogFileName
  SDLLogLevel   : Integer; // LogLevel

  SDLSetLog:            TN_cdeclProcPtrInt;
  SDLInitialize:        TN_cdeclProcVoid;     // ()
  SDLFinalize:          TN_cdeclProcVoid;     // ()
  SDLSendImageTo:       TN_cdeclInt4Func15PtrUInt2Ptr;

  function SDLInitAll    (): Integer;
  function SDLFreeAll    (): Integer;
end; // TK_DCMSCWEBGLib = class( TObject ) // Object for using cmsscweb.dll

var K_DCMGLibW : TK_DCMGLibWrap;
    K_DCMSCWEBGLib : TK_DCMSCWEBGLib;

function K_CMDCMCreateIntance0( const ADCMFName : string; out ADI : TK_HDCMINST ) : Integer;
function K_CMDCMCreateIntance( const ADCMFName : string; out ADI : TK_HDCMINST ) : Integer;

//uses N_Types
const
  K_CMDCMUID_ComputedRadiography_SOPClass  : WideString = '1.2.840.10008.5.1.4.1.1.1';   //  Computed_Radiography_Image_Storage_For_Presentation
  K_CMDCMUID_DigitalXRay_SOPClass          : WideString = '1.2.840.10008.5.1.4.1.1.1.1'; //  Digital_X_Ray_Image_Storage_For_Presentation
  K_CMDCMUID_DigitalIntraOralXRay_SOPClass : WideString = '1.2.840.10008.5.1.4.1.1.1.3'; //  Digital_Intra_Oral_X_Ray_Image_Storage_For_Presentation
  K_CMDCMUID_CT_SOPClass                   : WideString = '1.2.840.10008.5.1.4.1.1.2';   //  CT_Image_Storage
  K_CMDCMUID_SecondaryCapture_SOPClass     : WideString = '1.2.840.10008.5.1.4.1.1.7';   //  Secondary_Capture_Image_Storage
  K_CMDCMUID_VLEndoscopic_SOPClass         : WideString = '1.2.840.10008.5.1.4.1.1.77.1.1'; // VL_Endoscopic_Image_Storage
  K_CMDCMUID_VLMicroscopic_SOPClass        : WideString = '1.2.840.10008.5.1.4.1.1.77.1.2'; // VL_Microscopic_Image_Storage
  K_CMDCMUID_VLPhotographic_SOPClass       : WideString = '1.2.840.10008.5.1.4.1.1.77.1.4'; // VL_Photographic_Image_Storage
{
CR Computed Radiography Image Storage 1.2.840.10008.5.1.4.1.1.1 Greyscale
CT CT Image Storage 1.2.840.10008.5.1.4.1.1.2 Greyscale 3D
OT 1.2.840.10008.5.1.4.1.1.7 (SecondaryCapture_SOPClass) Any
ES 1.2.840.10008.5.1.4.1.1.77.1.1 (VLEndoscopic_SOPClass) Colour
DX 1.2.840.10008.5.1.4.1.1.1.1 (DigitalXRay_SOPClass) Greyscale
GM VL Microscopic Image Storage 1.2.840.10008.5.1.4.1.1.77.1.2 Colour
}

/////////////////////////////
// DICOM atributes Tags
//
// GROUP 0 (Command set)
/// <summary>
/// Command Set Group Length (0000;0000) UL 1
/// </summary>
  K_CMDCMTCommandSetGroupLength = $00000000;

/// <summary>
/// Affected SOP Class UID (0000;0002) UI 1
/// </summary>
  K_CMDCMTAffectedSopClassUid = $00000002;

/// <summary>
/// Requested SOP Class UID (0000;0003) UI 1
/// </summary>
  K_CMDCMTRequestedSopClassUid = $00000003;

/// <summary>
/// Command Field (0000;0100) US 1
/// </summary>
  K_CMDCMTCommandField = $00000100;

/// <summary>
/// Message ID (0000;0110) US 1
/// </summary>
  K_CMDCMTMessageId = $00000110;

/// <summary>
/// Message ID Being Responded To (0000;0120) US 1
/// </summary>
  K_CMDCMTMessageIdBeingRespondedTo = $00000120;

/// <summary>
/// Move Destination (0000;0600) AE 1
/// </summary>
  K_CMDCMTMoveDestination = $00000600;

/// <summary>
/// Priority (0000;0700) US 1
/// </summary>
  K_CMDCMTPriority = $00000700;

/// <summary>
/// Data Set Type (0000;0800) US 1
/// </summary>
  K_CMDCMTDataSetType = $00000800;

/// <summary>
/// Status (0000;0900) US 1
/// </summary>
  K_CMDCMTStatus = $00000900;

/// <summary>
/// Offending Element (0000;0901) AT 1-n
/// </summary>
  K_CMDCMTOffendingElement = $00000901;

/// <summary>
/// Error Comment (0000;0902) LO 1
/// </summary>
  K_CMDCMTErrorComment = $00000902;

/// <summary>
/// Error ID (0000;0903) US 1
/// </summary>
  K_CMDCMTErrorId = $00000903;

/// <summary>
/// Affected SOP Instance UID (0000;1000) UI 1
/// </summary>
  K_CMDCMTAffectedSopInstanceUid = $00001000;

/// <summary>
/// Requested SOP Instance UID (0000;1001) UI 1
/// </summary>
  K_CMDCMTRequestedSopInstanceUid = $00001001;

/// <summary>
/// Event Type ID (0000;1002) US 1
/// </summary>
  K_CMDCMTEventTypeId = $00001002;

/// <summary>
/// Attribute Identifier List (0000;1005) AT 1-n
/// </summary>
  K_CMDCMTAttributeIdentifierList = $00001005;

/// <summary>
/// Action Type ID (0000;1008) US 1
/// </summary>
  K_CMDCMTActionTypeId = $00001008;

/// <summary>
/// Number of Remaining Sub-Operations (0000;1020) US 1
/// </summary>
  K_CMDCMTNumberOfRemainingSubOperations = $00001020;

/// <summary>
/// Number of Completed Sub-Operations (0000;1021) US 1
/// </summary>
  K_CMDCMTNumberOfCompletedSubOperations = $00001021;

/// <summary>
/// Number of Failed Sub-Operations (0000;1022) US 1
/// </summary>
  K_CMDCMTNumberOfFailedSubOperations = $00001022;

/// <summary>
/// Number of Warning Sub-Operations (0000;1023) US 1
/// </summary>
  K_CMDCMTNumberOfWarningSubOperations = $00001023;

/// <summary>
/// Move Originator Application Entity Title (0000;1030) AE 1
/// </summary>
  K_CMDCMTMoveOriginatorApplicationEntityTitle = $00001030;

/// <summary>
/// Move Originator Message ID (0000;1031) US 1
/// </summary>
  K_CMDCMTMoveOriginatorMessageId = $00001031;

// GROUP 2
/// <summary>
/// Meta Header Group Length (0002;0000) UL 1
/// </summary>
  K_CMDCMTMetaHeaderGroupLength = $00020000;

/// <summary>
/// File Meta Information Version (0002;0001) OB 1
/// </summary>
  K_CMDCMTFileMetaInformationVersion = $00020001;

/// <summary>
/// Media Storage SOP Class UID (0002;0002) UI 1
/// </summary>
  K_CMDCMTMediaStorageSopClassUid = $00020002;

/// <summary>
/// Media Storage SOP Instance UID (0002;0003) UI 1
/// </summary>
  K_CMDCMTMediaStorageSopInstanceUid = $00020003;

/// <summary>
/// Transfer Syntax UID (0002;0010) UI 1
/// </summary>
  K_CMDCMTTransferSyntaxUid = $00020010;

/// <summary>
/// Implementation Class UID (0002;0012) UI 1
/// </summary>
  K_CMDCMTImplementationClassUid = $00020012;

/// <summary>
/// Implementation Version Name (0002;0013) SH 1
/// </summary>
  K_CMDCMTImplementationVersionName = $00020013;

/// <summary>
/// Source Application Entity Title (0002;0016) AE 1
/// </summary>
  K_CMDCMTSourceApplicationEntityTitle = $00020016;

/// <summary>
/// Private Information Creator UID (0002;0100) UI 1
/// </summary>
  K_CMDCMTPrivateInformationCreatorUid = $00020100;

/// <summary>
/// Private Information (0002;0102) OB 1
/// </summary>
  K_CMDCMTPrivateInformation = $00020102;

// GROUP 4
/// <summary>
// GROUP 4 Group Length (0004;0000) UL 1
/// </summary>
  K_CMDCMTGroup4GroupLength = $00040000;

/// <summary>
/// File Set ID (0004;1130) CS 1
/// </summary>
  K_CMDCMTFileSetId = $00041130;

/// <summary>
/// File Set Descriptor File ID (0004;1141) CS 1-8
/// </summary>
  K_CMDCMTFileSetDescriptorFileId = $00041141;

/// <summary>
/// Specific Character Set of File-set Descriptor File (0004;1142) CS 1
/// </summary>
  K_CMDCMTSpecificCharacterSetOfFileSetDescriptorFile = $00041142;

/// <summary>
/// Offset of the First Directory Record of the Root Directory Entity (0004;1200) UL 1
/// </summary>
  K_CMDCMTOffsetOfTheFirstDirectoryRecordOfTheRootDirectoryEntity = $00041200;

/// <summary>
/// Offset of the Last Directory Record of the Root Directory Entity (0004;1202) UL 1
/// </summary>
  K_CMDCMTOffsetOfTheLastDirectoryRecordOfTheRootDirectoryEntity = $00041202;

/// <summary>
/// File-set Consistency Flag (0004;1212) US 1
/// </summary>
  K_CMDCMTFileSetConsistencyFlag = $00041212;

/// <summary>
/// Directory Record Sequence (0004;1220) SQ 1
/// </summary>
  K_CMDCMTDirectoryRecordSequence = $00041220;

/// <summary>
/// Offset of the Next Directory Record (0004;1400) UL 1
/// </summary>
  K_CMDCMTOffsetOfTheNextDirectoryRecord = $00041400;

/// <summary>
/// Record In-use Flag (0004;1410) US 1
/// </summary>
  K_CMDCMTRecordInUseFlag = $00041410;

/// <summary>
/// Offset of Referenced Lower-Level Directory Entity (0004;1420) UL 1
/// </summary>
  K_CMDCMTOffsetOfReferencedLowerLevelDirectoryEntity = $00041420;

/// <summary>
/// Directory Record Type (0004;1430) CS 1
/// </summary>
  K_CMDCMTDirectoryRecordType = $00041430;

/// <summary>
/// Private Record UID (0004;1432) UI 1
/// </summary>
  K_CMDCMTPrivateRecordUid = $00041432;

/// <summary>
/// Reference File ID (0004;1500) CS 1-8
/// </summary>
  K_CMDCMTReferencedFileId = $00041500;

/// <summary>
/// MRDR Directory Record Offset (0004;1504) UL 1
/// </summary>
  K_CMDCMTMrdrDirectoryRecordOffset = $00041504;

/// <summary>
/// Referenced SOP Class UID in File (0004;1510) UI 1
/// </summary>
  K_CMDCMTReferencedSopClassUidInFile = $00041510;

/// <summary>
/// Referenced SOP Instance UID in File (0004;1511) UI 1
/// </summary>
  K_CMDCMTReferencedSopInstanceUidInFile = $00041511;

/// <summary>
/// Referenced Transfer Syntax UID in File (0004;1512) UI 1
/// </summary>
  K_CMDCMTReferencedTransferSyntaxUidInFile = $00041512;

/// <summary>
/// Referenced Related General SOP Class UID in File (0004;151A) UI 1-n
/// </summary>
  K_CMDCMTReferencedRelatedGeneralSopClassUidInFile = $0004151A;

/// <summary>
/// Number of References (0004;1600) UL 1
/// </summary>
  K_CMDCMTNumberOfReferences = $00041600;

    
// GROUP 8
/// <summary>
// GROUP 8 Group Length (0008;0000) UL 1
/// </summary>
  K_CMDCMTGroup8GroupLength = $00080000;

/// <summary>
/// Length to End (Retired) (0008;0001) UL 1
/// </summary>
  K_CMDCMTLengthToEndRetired = $00080001;

/// <summary>
/// Specific Character Set (0008;0005) CS 1-n
/// </summary>
  K_CMDCMTSpecificCharacterSet = $00080005;

/// <summary>
/// Image Type (0008;0008) CS 1-n
/// </summary>
  K_CMDCMTImageType = $00080008;

/// <summary>
/// Recognition Code (Retired) (0008;0010) CS 1
/// </summary>
  K_CMDCMTRecognitionCodeRetired = $00080010;

/// <summary>
/// Instance Creation Date (0008;0012) DA 1
/// </summary>
  K_CMDCMTInstanceCreationDate = $00080012;

/// <summary>
/// Instance Creation Time (0008;0013) TM 1
/// </summary>
  K_CMDCMTInstanceCreationTime = $00080013;

/// <summary>
/// Instance Creator UID (0008;0014) UI 1
/// </summary>
  K_CMDCMTInstanceCreatorUid = $00080014;

/// <summary>
/// SOP Class UID (0008;0016) UI 1
/// </summary>
  K_CMDCMTSopClassUid = $00080016;

/// <summary>
/// SOP Instance UID (0008;0018) UI 1
/// </summary>
  K_CMDCMTSopInstanceUid = $00080018;

/// <summary>
/// Related General SOP Class UID (0008;001A) UI 1-n
/// </summary>
  K_CMDCMTRelatedGeneralSopClassUid = $0008001A;

/// <summary>
/// Original Specialized SOP Class UID (0008;001B) UI 1
/// </summary>
  K_CMDCMTOriginalSpecializedSopClassUid = $0008001B;

/// <summary>
/// Study Date (0008;0020) DA 1
/// </summary>
  K_CMDCMTStudyDate = $00080020;

/// <summary>
/// Series Date (0008;0021) DA 1
/// </summary>
  K_CMDCMTSeriesDate = $00080021;

/// <summary>
/// Acquisition Date (0008;0022) DA 1			
/// </summary>
  K_CMDCMTAcquisitionDate = $00080022;

/// <summary>
/// Content Date (0008;0023) DA 1
/// </summary>
  K_CMDCMTContentDate = $00080023;

/// <summary>
/// Overlay Date (Retired) (0008;0024) DA 1
/// </summary>
  K_CMDCMTOverlayDateRetired = $00080024;

/// <summary>
/// Curve Date (Retired)  K_CMDCMT (0008;0025) DA 1
/// </summary>
  K_CMDCMTCurveDateRetired = $00080025;

/// <summary>
/// Acquisition Datetime (0008;002A) DT 1
/// </summary>
  K_CMDCMTAcquisitionDateTime = $0008002A;

/// <summary>
/// Study Time (0008;0030) TM 1
/// </summary>
  K_CMDCMTStudyTime = $00080030;

/// <summary>
/// Series Time (0008;0031) TM 1
/// </summary>
  K_CMDCMTSeriesTime = $00080031;

/// <summary>
/// Acquisition Time (0008;0032) TM 1
/// </summary>
  K_CMDCMTAcquisitionTime = $00080032;

/// <summary>
/// Content Time (0008;0033) TM 1
/// </summary>
  K_CMDCMTContentTime = $00080033;

/// <summary>
/// Overlay Time (Retired) (0008;0034) TM 1
/// </summary>
  K_CMDCMTOverlayTimeRetired = $00080034;

/// <summary>
/// Curve Time (Retired) (0008;0035) TM 1
/// </summary>
  K_CMDCMTCurveTimeRetired = $00080035;

/// <summary>
/// Data Set Type (Retired) (0008;0040)  K_CMDCMTUS 1
/// </summary>
  K_CMDCMTDataSetTypeRetired = $00080040;

/// <summary>
/// Data Set Subtype (Retired) (0008;0041) LO 1
/// </summary>
  K_CMDCMTDataSetSubtypeRetired = $00080041;

/// <summary>
/// Nuclear Medicine Series Type (Retired) (0008;0042) CS 1
/// </summary>
  K_CMDCMTNuclearMedicineSeriesTypeRetired = $00080042;

/// <summary>
/// Accession Number (0008;0050) SH 1
/// </summary>
  K_CMDCMTAccessionNumber = $00080050;

/// <summary>
/// Query/Retrieve Level (0008;0052) CS 1
/// </summary>
  K_CMDCMTQueryRetrieveLevel = $00080052;

/// <summary>
/// Retrieve AE Title (0008;0054) AE 1-n
/// </summary>
  K_CMDCMTRetrieveAETitle = $00080054;

/// <summary>
/// Instance Availability (0008;0056) CS 1
/// </summary>
  K_CMDCMTInstanceAvailability = $00080056;

/// <summary>
/// Failed SOP Instance UID List (0008;0058) UI 1-n
/// </summary>
  K_CMDCMTFailedSopInstanceUidList = $00080058;

/// <summary>
/// Modality (0008;0060) CS 1
/// </summary>
  K_CMDCMTModality = $00080060;

/// <summary>
/// Modalities in Study (0008;0061) CS 1-n
/// </summary>
  K_CMDCMTModalitiesInStudy = $00080061;

/// <summary>
/// SOP Classes in Study (0008;0062) UI 1-n
/// </summary>
  K_CMDCMTSopClassesInStudy = $00080062;

/// <summary>
/// Conversion Type  K_CMDCMT(0008;0064) CS 1
/// </summary>
  K_CMDCMTConversionType = $00080064;

/// <summary>
/// Presentation Intent Type  K_CMDCMT(0008;0068) CS 1
/// </summary>
  K_CMDCMTPresentationIntentType = $00080068;

/// <summary>
/// Manufacturer  K_CMDCMT(0008;0070) LO 1
/// </summary>
  K_CMDCMTManufacturer = $00080070;

/// <summary>
/// Institution Name  K_CMDCMT(0008;0080) LO 1
/// </summary>
  K_CMDCMTInstitutionName = $00080080;

/// <summary>
/// Institution Address  K_CMDCMT(0008;0081) ST 1
/// </summary>
  K_CMDCMTInstitutionAddress = $00080081;

/// <summary>
/// Institution Code Sequence (0008;0082) SQ 1
/// </summary>
  K_CMDCMTInstitutionCodeSequence = $00080082;

/// <summary>
/// Referring Physician's Name (0008;0090) PN 1
/// </summary>
  K_CMDCMTReferringPhysiciansName = $00080090;

/// <summary>
/// Referring Physician's Address (0008;0092) ST 1
/// </summary>
  K_CMDCMTReferringPhysiciansAddress = $00080092;

/// <summary>
/// Referring Physician's Telephone Numbers (0008;0094) SH 1-n
/// </summary>
  K_CMDCMTReferringPhysiciansTelephoneNumbers = $00080094;

/// <summary>
/// Referring Physician Identification Sequence (0008;0096) SQ 1
/// </summary>summary>
  K_CMDCMTReferringPhysicianIdentificationSequence = $00080096;

/// <summary>
/// Code Value (0008;0100) SH 1
/// </summary>
  K_CMDCMTCodeValue = $00080100;

/// <summary>
/// Coding Scheme Designator (0008;0102) SH 1
/// </summary>
  K_CMDCMTCodingSchemeDesignator = $00080102;

/// <summary>
/// Coding Scheme Version (0008;0103) SH 1
/// </summary>
  K_CMDCMTCodingSchemeVersion = $00080103;

/// <summary>
/// Code Meaning (0008;0104) LO 1
/// </summary>
  K_CMDCMTCodeMeaning = $00080104;

/// <summary>
/// Mapping Resource (0008;0105) CS 1
/// </summary>
  K_CMDCMTMappingResource = $00080105;

/// <summary>
/// Context Group Version (0008;0106) DT 1
/// </summary>
  K_CMDCMTContextGroupVersion = $00080106;

/// <summary>
/// Context Group Local Version (0008;0107) DT 1
/// </summary>
  K_CMDCMTContextGroupLocalVersion = $00080107;

/// <summary>
/// Context Group Extension Flag (0008;010B) CS 1
/// </summary>
  K_CMDCMTContextGroupExtensionFlag = $0008010B;

/// <summary>
/// Coding Scheme UID (0008;010C) UI 1
/// </summary>
  K_CMDCMTCodingSchemeUid = $0008010C;

/// <summary>
/// Context Group Extension Creator UID (0008;010D) UI 1
/// </summary>
  K_CMDCMTContextGroupExtensionCreatorUid = $0008010D;

/// <summary>
/// Context Identifier (0008;010F) CS 1
/// </summary>
  K_CMDCMTContextIdentifier = $0008010F;

/// <summary>
/// Coding Scheme Identification Sequence (0008;0110) SQ 1
/// </summary>
  K_CMDCMTCodingSchemeIdentificationSequence = $00080110;

/// <summary>
/// Coding Scheme Registry (0008;0112) LO 1
/// </summary>
  K_CMDCMTCodingSchemeRegistry = $00080112;

/// <summary>
/// Coding Scheme External ID (0008;0114) ST 1
/// </summary>
  K_CMDCMTCodingSchemeExternalId = $00080114;

/// <summary>
/// Coding Scheme Name (0008;0115) ST 1
/// </summary>
  K_CMDCMTCodingSchemeName = $00080115;

/// <summary>
/// Responsible Organization (0008;0116) ST 1
/// </summary>
  K_CMDCMTResponsibleOrganization = $00080116;

/// <summary>
/// Timezone Offset From UTC (0008;0201) SH 1
/// </summary>
  K_CMDCMTTimeZoneOffsetFromUtc = $00080201;

/// <summary>
/// Network ID (Retired) (0008;1000) AE 1
/// </summary>
  K_CMDCMTNetworkIdRetired = $00081000;

/// <summary>
/// Station Name (0008;1010) SH 1
/// </summary>
  K_CMDCMTStationName = $00081010;

/// <summary>
/// Study Description (0008;1030) LO 1
/// </summary>
  K_CMDCMTStudyDescription = $00081030;

/// <summary>
/// Procedure Code Sequence (0008;1032) SQ 1
/// </summary>
  K_CMDCMTProcedureCodeSequence = $00081032;

/// <summary>
/// Series Description (0008;103E) LO 1
/// </summary>
  K_CMDCMTSeriesDescription = $0008103E;

/// <summary>
/// Institutional Department Name (0008;1040) LO 1
/// </summary>
  K_CMDCMTInstitutionalDepartmentName = $00081040;

/// <summary>
/// Physician(s) of Record (0008;1048) PN 1-n
/// </summary>
  K_CMDCMTPhysiciansOfRecord = $00081048;

/// <summary>
/// Physician(s) of Record Identification Sequence (0008;1049) SQ 1
/// </summary>
  K_CMDCMTPhysiciansOfRecordIdentificationSequence = $00081049;

/// <summary>
/// Performing Physician’s Name (0008;1050) PN 1-n
/// </summary>
  K_CMDCMTPerformingPhysiciansName = $00081050;

/// <summary>
/// Performing Physician Identification Sequence (0008;1052) SQ 1
/// </summary>
  K_CMDCMTPerformingPhysicianIdentificationSequence = $00081052;

/// <summary>
/// Name of Physician(s) Reading Study (0008;1060) PN 1-n
/// </summary>
  K_CMDCMTNameOfPhysiciansReadingStudy = $00081060;

/// <summary>
/// Physician(s) Reading Study Identification Sequence (0008;1062) SQ 1
/// </summary>
  K_CMDCMTPhysiciansReadingStudyIdentificationSequence = $00081062;

/// <summary>
/// Operators' Name (0008;1070) PN 1-n
/// </summary>
  K_CMDCMTOperatorsName = $00081070;

/// <summary>
/// Operator Identification Sequence (0008;1072) SQ 1
/// </summary>
  K_CMDCMTOperatorIdentificationSequence = $00081072;

/// <summary>
/// Admittiing Diagnoses Description (0008;1080) LO 1-n
/// </summary>
  K_CMDCMTAdmittingDiagnosesDescription = $00081080;

/// <summary>
/// Admittiing Diagnoses Code Sedquence (0008;1084) SQ 1
/// </summary>
  K_CMDCMTAdmittingDiagnosisCodeSequence = $00081084;

/// <summary>
/// Manufacturer’s Model Name (0008;1090) LO 1
/// </summary>
  K_CMDCMTManufacturersModelName = $00081090;

/// <summary>
/// Referenced Results Sequence (Retired) (0008;1100) SQ 1
/// </summary>
  K_CMDCMTReferencedResultsSequenceRetired = $00081100;

/// <summary>
///  K_CMDCMTReferenced Study Sequence (0008;1110) SQ 1
/// </summary>
  K_CMDCMTReferencedStudySequence = $00081110;

/// <summary>
///  K_CMDCMTReferenced Performed Procedure Step Sequence (0008;1111) SQ 1
/// </summary>
  K_CMDCMTReferencedPerformedProcedureStepSequence = $00081111;

/// <summary>
/// Referenced Series Sequence (0008;1115) SQ 1
/// </summary>
  K_CMDCMTReferencedSeriesSequence = $00081115;

/// <summary>
/// Referenced Patient Sequence (0008;1120) SQ 1
/// </summary>
  K_CMDCMTReferencedPatientSequence = $00081120;

/// <summary>
/// Referenced Visit Sequence (0008;1125) SQ 1
/// </summary>
  K_CMDCMTReferencedVisitSequence = $00081125;

/// <summary>
/// Referenced Overlay Sequence (Retired)  K_CMDCMT (0008;1130) SQ 1
/// </summary>
  K_CMDCMTReferencedOverlaySequenceRetired = $00081130;

/// <summary>
/// Referenced Waveform Sequence (0008;113A) SQ 1
/// </summary>
  K_CMDCMTReferencedWaveformSequence = $0008113A;

/// <summary>
/// Referenced Image Sequence (0008;1140) SQ 1
/// </summary>
  K_CMDCMTReferencedImageSequence = $00081140;

/// <summary>
/// Referenced Curve Sequence (Retired) (0008;1145) SQ1
/// </summary>
  K_CMDCMTReferencedCurveSequenceRetired = $00081145;

/// <summary>
/// Referenced Instance Sequence (0008;114A) SQ 1
/// </summary>
  K_CMDCMTReferencedInstanceSequence = $0008114A;

/// <summary>
/// Referenced Real World Value Mapping Instance Sequence  K_CMDCMT(0008;114B) SQ 1
/// </summary>
  K_CMDCMTReferencedRealWorldValueMappingInstanceSequence = $0008114B;

/// <summary>
/// Referenced SOP Class UID (0008;1150) UI 1
/// </summary>
  K_CMDCMTReferencedSopClassUid = $00081150;

/// <summary>
/// Referenced SOP Instgance UID (0008;1155) UI 1
/// </summary>
  K_CMDCMTReferencedSopInstanceUid = $00081155;

/// <summary>
/// SOP Classes Supported (0008;115A) UI 1-n
/// </summary>
  K_CMDCMTSopClassesSupported = $0008115A;

/// <summary>
/// Referenced Frame Number (0008;1160) IS 1-n
/// </summary>
  K_CMDCMTReferencedFrameNumber = $00081160;

/// <summary>
/// Transaction UID (0008;1195) UI 1
/// </summary>
  K_CMDCMTTransactionUid = $00081195;

/// <summary>
/// Failure Reason (0008;1197) US 1
/// </summary>
  K_CMDCMTFailureReason = $00081197;

/// <summary>
/// Failed SOP Sequence (0008;1198) SQ 1
/// </summary>
  K_CMDCMTFailedSopSequence = $00081198;

/// <summary>
/// Referenced SOP Sequence (0008;1199) SQ 1
/// </summary>
  K_CMDCMTReferencedSopSequence = $00081199;

/// <summary>
/// Studies Containing Other Referenced Instances Sequence (0008;1200) SQ 1
/// </summary>
  K_CMDCMTStudiesContainingOtherReferencedInstancesSequence = $00081200;

/// <summary>
/// Related Series Sequence (0008;1250) SQ 1
/// </summary>
  K_CMDCMTRelatedSeriesSequence = $00081250;

/// <summary>
/// Lossy Image Compression (Retired)  K_CMDCMT(0008;2110) CS 1
/// </summary>
  K_CMDCMTLossyImageCompressionRetired = $00082110;

/// <summary>
/// Derivation Description (0008;2111) ST 1
/// </summary>
  K_CMDCMTDerivationDescription = $00082111;

/// <summary>
/// Source Image Sequence (0008;2112) SQ 1
/// </summary>
  K_CMDCMTSourceImageSequence = $00082112;

/// <summary>
/// Stage Name (0008;2120) SH 1
/// </summary>
  K_CMDCMTStageName = $00082120;

/// <summary>
/// Stage Number (0008;2122) IS 1
/// </summary>
  K_CMDCMTStageNumber = $00082122;

/// <summary>
/// Number of Stages (0008;2124) IS 1
/// </summary>
  K_CMDCMTNumberOfStages = $00082124;

/// <summary>
/// View Name (0008;2127) SH 1
/// </summary>
  K_CMDCMTViewName = $00082127;

/// <summary>
/// View Number (0008;2128) IS 1
/// </summary>
  K_CMDCMTViewNumber = $00082128;

/// <summary>
/// Number of Event Timers (0008;2129) IS 1
/// </summary>
  K_CMDCMTNumberOfEventTimers = $00082129;

/// <summary>
/// Number of Views In Stage (0008;212A) IS 1
/// </summary>
  K_CMDCMTNumberOfViewsInStage = $0008212A;

/// <summary>
/// Event Elapsed Time(s) (0008;2130) DS 1-n
/// </summary>
  K_CMDCMTEventElapsedTimes = $00082130;

/// <summary>
/// Event Timer Name(s) (0008;2132) LO 1-n
/// </summary>
  K_CMDCMTEventTimerNames = $00082132;

/// <summary>
/// Start Trim (0008;2142) IS 1
/// </summary>
  K_CMDCMTStartTrim = $00082142;

/// <summary>
/// Stop Trim (0008;2143) IS 1
/// </summary>
  K_CMDCMTStopTrim = $00082143;

/// <summary>
/// Recommended Display Frame Rate (0008;2144) IS 1
/// </summary>
  K_CMDCMTRecommendedDisplayFrameRate = $00082144;

/// <summary>
/// Transducer Position (Retired) (0008;2200) CS 1
/// </summary>
  K_CMDCMTRransducerPositionRetired = $00082200;

/// <summary>
/// Transducer Orientation (Retired) (0008;2204) CS 1
/// </summary>
  K_CMDCMTTransducerOrientationRetired = $00082204;

/// <summary>
/// Anatomic Structure (Retired) (0008;2208) CS 1
/// </summary>
  K_CMDCMTAnatomicStructureRetired = $00082208;

/// <summary>
/// Anatomic Region Sequence (0008;2218) SQ 1
/// </summary>
  K_CMDCMTAnatomicRegionSequence = $00082218;

/// <summary>
/// Anatomic Region Modifier Sequence (0008;2220) SQ 1
/// </summary>
  K_CMDCMTAnatomicRegionModifierSequence = $00082220;

/// <summary>
/// Primary Anatomic Structure Sequence (0008;2228) SQ 1
/// </summary>
  K_CMDCMTPrimaryAnatomicStructureSequence = $00082228;

/// <summary>
/// Anatomic Structure; Space or Region Sequence (0008;2229) SQ 1
/// </summary>
  K_CMDCMTAnatomicStructureSpaceOrRegionSequence = $00082229;

/// <summary>
/// Primary Anatomic Structure Modifier Sequence (0008;2230) SQ 1
/// </summary>
  K_CMDCMTPrimaryAnatomicStructureModifierSequence = $00082230;

/// <summary>
/// Transducer Position Sequence (Retired) (0008;2240) SQ 1
/// </summary>
  K_CMDCMTTransducerPositionSequenceRetired = $00082240;

/// <summary>
/// Transducer Position Modifier Sequence (Retired) (0008;2242) SQ 1
/// </summary>
  K_CMDCMTTransducerPositionModifierSequenceRetired = $00082242;

/// <summary>
/// Transducer Orientation Sequence (Retired)  K_CMDCMT (0008;2244) SQ 1
/// </summary>
  K_CMDCMTTransducerOrientationSequenceRetired = $00082244;

/// <summary>
/// Transducer Orientation Modifier Sequence (Retired) (0008;2246) SQ 1
/// </summary>
  K_CMDCMTTransducerOrientationModifierSequenceRetired = $00082246;

/// <summary>
/// Alternate Representation Sequence (0008;3001) SQ 1
/// </summary>
  K_CMDCMTAlternateRepresentationSequence = $00083001;

/// <summary>
/// Irradiation Event UID (0008;3010) UI 1
/// </summary>
  K_CMDCMTIrradiationEventUID = $00083010;

/// <summary>
/// Identifying Comments (Retired)  K_CMDCMT(0008;4000) LT 1
/// </summary>
  K_CMDCMTIdentifyingCommentsRetired = $00084000;


/// <summary>
/// Frame Type (0008;9007) CS 4
/// </summary>
  K_CMDCMTFrameType = $00089007;

/// <summary>
///  K_CMDCMTReferenced Image Evidence Sequence (0008;9092) SQ 1
/// </summary>
  K_CMDCMTReferencedImageEvidenceSequence = $00089092;

/// <summary>
/// Referenced Raw Data Sequence (0008;9121) SQ 1
/// </summary>
  K_CMDCMTReferencedRawDataSequence = $00089121;

/// <summary>
/// Creator-Version UID (0008;9123) UI 1
/// </summary>
  K_CMDCMTCreatorVersionUid = $00089123;

/// <summary>
/// Derivation Image Sequence (0008;9124) SQ 1
/// </summary>
  K_CMDCMTDerivationImageSequence = $00089124;

/// <summary>
/// Source Image Evidence Sequence (0008;9154) SQ 1
/// </summary>
  K_CMDCMTSourceImageEvidenceSequence = $00089154;

/// <summary>
/// Pixel Presentation (0008;9205) CS 1
/// </summary>
  K_CMDCMTPixelPresentation = $00089205;

/// <summary>
/// Volumetric Properties (0008;9206) CS 1
/// </summary>
  K_CMDCMTVolumetricProperties = $00089206;

/// <summary>
/// Volume Based Calculation Technique (0008;9207) CS 1
/// </summary>
  K_CMDCMTVolumeBasedCalculationTechnique = $00089207;

/// <summary>
/// Complex Image Component (0008;9208) CS 1
/// </summary>
  K_CMDCMTComplexImageComponent = $00089208;

/// <summary>
/// Acquisition Contrast (0008;9209) CS 1
/// </summary>
  K_CMDCMTAcquisitionContrast = $00089209;

/// <summary>
/// Derivation Code Sequence (0008;9215) SQ 1
/// </summary>
  K_CMDCMTDerivationCodeSequence = $00089215;

/// <summary>
/// Referenced Grayscale Presentation State Sequence (0008;9237) SQ 1
/// </summary>
  K_CMDCMTReferencedGrayscalePresentationStateSequence = $00089237;

/// <summary>
/// Referenced Other Plane Sequence (0008;9410) SQ 1
/// </summary>
  K_CMDCMTReferencedOtherPlaneSequence = $00089410;

/// <summary>
/// Frame Display Sequence  K_CMDCMT (0008;9458) SQ 1
/// </summary>
  K_CMDCMTFrameDisplaySequence = $00089458;

/// <summary>
/// Recommended Display Frame Rate in Float  K_CMDCMT (0008;9459) FL 1
/// </summary>
  K_CMDCMTRecommendedDisplayFrameRateinFloat = $00089459;

/// <summary>
/// Skip Frame Range Flag        K_CMDCMT(0008;9460) CS 1
/// </summary>
  K_CMDCMTSkipFrameRangeFlag = $00089460;

    
// GROUP 10
/// <summary>
// GROUP 10 Group Length (0010;0000) UL 1
/// </summary>
  K_CMDCMTGroup10GroupLength = $00100000;

/// <summary>
/// Patient's Name (0010;0010) PN 1
/// </summary>
  K_CMDCMTPatientsName = $00100010;

/// <summary>
/// Patient ID (0010;0020) LO 1
/// </summary>
  K_CMDCMTPatientId = $00100020;

/// <summary>
/// Issuer of Patient ID (0010;0021) LO 1
/// </summary>
  K_CMDCMTIssuerOfPatientId = $00100021;

/// <summary>
/// Patient's Birth Date (0010;0030) DA1
/// </summary>
  K_CMDCMTPatientsBirthDate = $00100030;

/// <summary>
/// Patient's Birth Time (0010;0032) TM 1
/// </summary>
  K_CMDCMTPatientsBirthTime = $00100032;

/// <summary>
/// Patient's Sex (0010;0040) CS 1
/// </summary>
  K_CMDCMTPatientsSex = $00100040;

/// <summary>
/// Patient's Insurance Plan Code Sequence (0010;0050) SQ 1
/// </summary>
  K_CMDCMTPatientsInsurancePlanCodeSequence = $00100050;

/// <summary>
/// Patient’s Primary Language Code Sequence (0010;0101) SQ 1
/// </summary>
  K_CMDCMTPatientsPrimaryLanguageCodeSequence = $00100101;

/// <summary>
/// Patient’s Primary Language Code Modifier Sequence (0010;0102) SQ 1
/// </summary>
  K_CMDCMTPatientsPrimaryLanguageCodeModifierSequence = $00100102;

/// <summary>
/// Other Patient IDs (0010;1000) LO 1-n
/// </summary>
  K_CMDCMTOtherPatientIds = $00101000;

/// <summary>
/// Other Patient Names (0010;1001) PN 1-n
/// </summary>
  K_CMDCMTOtherPatientNames = $00101001;

/// <summary>
/// Patient's Birth Name (0010;1005) PN 1
/// </summary>
  K_CMDCMTPatientsBirthName = $00101005;

/// <summary>
/// Patient's Age (0010;1010) AS 1
/// </summary>
  K_CMDCMTPatientsAge = $00101010;

/// <summary>
/// Patient's Size (0010;1020) DS 1
/// </summary>
  K_CMDCMTPatientsSize = $00101020;

/// <summary>
/// Patient's Weight (0010;1030) DS 1
/// </summary>
  K_CMDCMTPatientsWeight = $00101030;

/// <summary>
/// Patient's Address (0010;1040) LO 1
/// </summary>
  K_CMDCMTPatientsAddress = $00101040;

/// <summary>
/// Insurance Plan Identification (Retired) (0010;1050) LO 1-n
/// </summary>
  K_CMDCMTInsurancePlanIdentificationRetired = $00101050;

/// <summary>
/// Patient's Mother's Birth Name (0010;1060) PN 1
/// </summary>
  K_CMDCMTPatientsMothersBirthName = $00101060;

/// <summary>
/// Military Rank (0010;1080) LO 1
/// </summary>
  K_CMDCMTMilitaryRank = $00101080;

/// <summary>
/// Branch of Service (0010;1081) LO 1
/// </summary>
  K_CMDCMTBranchOfService = $00101081;

/// <summary>
/// Medical Record Locator (0010;1090) LO 1
/// </summary>
  K_CMDCMTMedicalRecordLocator = $00101090;

/// <summary>
/// Medical Alerts (0010;2000) LO 1-n
/// </summary>
  K_CMDCMTMedicalAlerts = $00102000;

/// <summary>
/// Contrast Allergies (0010;2110) LO 1-n
/// </summary>
  K_CMDCMTContrastAllergies = $00102110;

/// <summary>
/// Country of Residence (0010;2150) LO 1
/// </summary>
  K_CMDCMTCountryOfResidence = $00102150;

/// <summary>
/// Region of Residence (0010;2152) LO 1
/// </summary>
  K_CMDCMTRegionOfResidence = $00102152;

/// <summary>
/// Patient's Telephone Numbers (0010;2154) SH 1-n
/// </summary>
  K_CMDCMTPatientsTelephoneNumbers = $00102154;

/// <summary>
/// Ethnic Group (0010;2160) SH 1
/// </summary>
  K_CMDCMTEthnicGroup = $00102160;

/// <summary>
/// Occupation (0010;2160) SH 1
/// </summary>
  K_CMDCMTOccupation = $00102180;

/// <summary>
/// Smoking Status (0010;21A0) CS 1
/// </summary>
  K_CMDCMTSmokingStatus = $001021A0;

/// <summary>
/// Additional Patient History (0010;21B0) LT 1
/// </summary>
  K_CMDCMTAdditionalPatientHistory = $001021B0;

/// <summary>
/// Pregnancy Status (0010;21C0) US 1
/// </summary>
  K_CMDCMTPregnancyStatus = $001021C0;

/// <summary>
/// Last Menstrual Date (0010;21D0) DA 1
/// </summary>
  K_CMDCMTLastMenstrualDate = $001021D0;

/// <summary>
/// Patient's Religious Preference (0010;21F0) LO 1
/// </summary>
  K_CMDCMTPatientsReligiousPreference = $001021F0;

/// <summary>
/// Patient Comments (0010;4000) LT 1
/// </summary>
  K_CMDCMTPatientComments = $00104000;

/// <summary>
/// Examined Body Thickness (0010;9431) FL 1
/// </summary>
  K_CMDCMTExaminedBodyThickness = $00109431;

    
// GROUP 12
/// <summary>
// GROUP 12 Group Length (0012;0000) UL 1
/// </summary>
  K_CMDCMTGroup12GroupLength = $00120000;

/// <summary>
/// Clinical Trial Sponsor Name (0012;0010) LO 1
/// </summary>
  K_CMDCMTClinicalTrialSponsorName = $00120010;

/// <summary>
/// Clinical Trial Protocol ID (0012;0020) LO 1
/// </summary>
  K_CMDCMTClinicalTrialProtocolId = $00120020;

/// <summary>
/// Clinical Trial Protocol Name (0012;0021) LO 1
/// </summary>
  K_CMDCMTClinicalTrialProtocolName = $00120021;

/// <summary>
/// Clinical Trial Site ID (0012;0030) LO 1
/// </summary>
  K_CMDCMTClinicalTrialSiteId = $00120030;

/// <summary>
/// Clinical Trial Site Name (0012;0031) LO 1
/// </summary>
  K_CMDCMTClinicalTrialSiteName = $00120031;

/// <summary>
/// Clinical Trial Subject ID (0012;0040) LO 1
/// </summary>
  K_CMDCMTClinicalTrialSubjectId = $00120040;

/// <summary>
/// Clinical Trial Subject Reading ID (0012;0042) LO 1
/// </summary>
  K_CMDCMTClinicalTrialSubjectReadingId = $00120042;

/// <summary>
/// Clinical Trial Time Point ID (0012;0050) LO 1
/// </summary>
  K_CMDCMTClinicalTrialTimePointId = $00120050;

/// <summary>
/// Clinical Trial Time Point Description (0012;0051) ST 1
/// </summary>
  K_CMDCMTClinicalTrialTimePointDescription = $00120051;

/// <summary>
/// Clinical Trial Coordinating Center Name (0012;0060) LO 1
/// </summary>
  K_CMDCMTClinicalTrialCoordinatingCenterName = $00120060;

/// <summary>
/// Patient Identify Removed     (0012;0062) CS 1
/// </summary>
  K_CMDCMTPatientIdentifyRemoved = $00120062;

/// <summary>
/// De-identification Method     (0012;0063) LO 1-n
/// </summary>
  K_CMDCMTDeIdentificationMethod = $00120063;

/// <summary>
/// De-identification Method Code Sequence    (0012;0064) SQ 1
/// </summary>
  K_CMDCMTDeIdentificationMethodCodeSequence = $00120064;

    
// GROUP 18
/// <summary>
// GROUP 18 Group Length (0018;0000) UL 1 
/// </summary>
  K_CMDCMTGroup18GroupLength = $00180000;

/// <summary>
/// Contrast Bolus Agent (0018;0010) LO 1
/// </summary>
  K_CMDCMTContrastBolusAgent = $00180010;

/// <summary>
/// Contrast Bolus Agent Sequence (0018;0012) SQ 1
/// </summary>
  K_CMDCMTContrastBolusAgentSequence = $00180012;

/// <summary>
/// Contrast/Bolus Administration Route Sequence (0018;0014) SQ 1
/// </summary>
  K_CMDCMTContrastBolusAdministrationRouteSequence = $00180014;

/// <summary>
/// Body Part Examined (0018;0015) CS 1
/// </summary>
  K_CMDCMTBodyPartExamined = $00180015;

/// <summary>
/// Scanning Sequence (0018;0020) CS 1-n
/// </summary>
  K_CMDCMTScanningSequence = $00180020;

/// <summary>
/// Sequence Variant (0018;0021) CS 1-n
/// </summary>
  K_CMDCMTSequenceVariant = $00180021;

/// <summary>
/// Scan Options (0018;0022) CS 1-n
/// </summary>
  K_CMDCMTScanOptions = $00180022;

/// <summary>
/// MR Acquisition Type (0018;0023) CS 1
/// </summary>
  K_CMDCMTMRAcquisitionType = $00180023;

/// <summary>
/// Sequence Name (0018;0024) SH 1
/// </summary>
  K_CMDCMTSequenceName = $00180024;

/// <summary>
/// Angio Flag (0018;0025) CS 1
/// </summary>
  K_CMDCMTAngioFlag = $00180025;

/// <summary>
/// Intervention Drug Information Sequence (0018;0026) SQ 1
/// </summary>
  K_CMDCMTInterventionDrugInformationSequence = $00180026;

/// <summary>
/// Intervention Drug Stop Time (0018;0027) TM 1
/// </summary>
  K_CMDCMTInterventionDrugStopTime = $00180027;

/// <summary>
/// Intervention Drug Dose (0018;0028) DS 1
/// </summary>
  K_CMDCMTInterventionDrugDose = $00180028;

/// <summary>
/// Intervention Drug Code Sequence (0018;0029) SQ 1
/// </summary>
  K_CMDCMTInterventionDrugCodeSequence = $00180029;

/// <summary>
/// Additional Drug Sequence (0018;002A) SQ 1
/// </summary>
  K_CMDCMTAdditionalDrugSequence = $0018002A;

/// <summary>
/// Radionuclide (Retired) (0018;0030) LO 1-n
/// </summary>
  K_CMDCMTRadioNuclideRetired = $00180030;

/// <summary>
/// Radiopharmaceutical (0018;0031) LO 1
/// </summary>
  K_CMDCMTRadioPharmaceutical = $00180031;

/// <summary>
/// Energy Window Centerline (Retired) 0018;0032) DS 1
/// </summary>
  K_CMDCMTEnergyWindowCenterlineRetired = $00180032;

/// <summary>
/// Energy Window Total Width (Retired) (0018;0033) DS 1-n
/// </summary>
  K_CMDCMTEnergyWindowTotalWidthRetired = $00180033;

/// <summary>
/// Intervention Drug Name (0018;0034) LO 1
/// </summary>
  K_CMDCMTInterventionDrugName = $00180034;

/// <summary>
/// Intervention Drug Start Time (0018;0035) TM 1
/// </summary>
  K_CMDCMTInterventionDrugStartTime = $00180035;

/// <summary>
/// Intervention Therapy Sequence (0018;0036) SQ 1
/// </summary>
  K_CMDCMTInterventionalTherapySequence = $00180036;

/// <summary>
/// Therapy Type (Retired) (0018;0037) CS 1
/// </summary>
  K_CMDCMTTherapyTypeRetired = $00180037;

/// <summary>
/// Interventional Status (0018;0038) CS 1
/// </summary>
  K_CMDCMTInterventionalStatus = $00180038;

/// <summary>
/// Therapy Description (0018;0039) CS 1
/// </summary>
  K_CMDCMTTherapyDescription = $00180039;

/// <summary>
/// Intervention Description (0018;003A) ST 1
/// </summary>
  K_CMDCMTInterventionDescription = $0018003A;

/// <summary>
/// Cine Rate (0018;0040) IS 1
/// </summary>
  K_CMDCMTCineRate = $00180040;

/// <summary>
/// Slice Thickness (0018;0050) DS 1
/// </summary>
  K_CMDCMTSliceThickness = $00180050;

/// <summary>
/// KVP (0018;0060) DS 1
/// </summary>
  K_CMDCMTKvp = $00180060;

/// <summary>
/// Counts Accumulated (0018;0070) IS 1
/// </summary>
  K_CMDCMTCountsAccumulated = $00180070;

/// <summary>
/// Acquisition Termination Condition (0018;0071) CS 1
/// </summary>
  K_CMDCMTAcquisitionTerminationCondition = $00180071;

/// <summary>
/// Effective Duration (0018;0072) DS 1
/// </summary>
  K_CMDCMTEffectiveDuration = $00180072;

/// <summary>
/// Acquisition Start Condition (0018;0073) CS 1
/// </summary>
  K_CMDCMTAcquisitionStartCondition = $00180073;

/// <summary>
/// Acquisition Start Condition Data (0018;0074) IS 1
/// </summary>
  K_CMDCMTAcquisitionStartConditionData = $00180074;

/// <summary>
/// Acquisition Termination Condition Data (0018;0075) IS 1
/// </summary>
  K_CMDCMTAcquisitionTerminationConditionData = $00180075;

/// <summary>
/// Repetition Time (0018;0080) DS 1
/// </summary>
  K_CMDCMTRepetitionTime = $00180080;

/// <summary>
/// Echo Time (0018;0081) DS 1
/// </summary>
  K_CMDCMTEchoTime = $00180081;

/// <summary>
/// Inversion Time (0018;0082) DS 1
/// </summary>
  K_CMDCMTInversionTime = $00180082;

/// <summary>
/// Number of Averages (0018;0083) DS 1
/// </summary>
  K_CMDCMTNumberOfAverages = $00180083;

/// <summary>
/// Imaging Frequency (0018;0084) DS 1
/// </summary>
  K_CMDCMTImagingFrequency = $00180084;

/// <summary>
/// Imaged Nucleus (0018;0085) SH 1
/// </summary>
  K_CMDCMTImagedNucleus = $00180085;

/// <summary>
/// Echo Numbers (0018;0086) IS 1-n
/// </summary>
  K_CMDCMTEchoNumbers = $00180086;

/// <summary>
/// Magnetic Field Strength (0018;0087) DS 1
/// </summary>
  K_CMDCMTMagneticFieldStrength = $00180087;

/// <summary>
/// Spacing Between Slices (0018;0088) DS 1
/// </summary>
  K_CMDCMTSpacingBetweenSlices = $00180088;

/// <summary>
/// Number of Phase Encoding Steps (0018;0089) IS 1
/// </summary>
  K_CMDCMTNumberOfPhaseEncodingSteps = $00180089;

/// <summary>
/// Data Collection Diameter (0018;0090) DS 1
/// </summary>
  K_CMDCMTDataCollectionDiameter = $00180090;

/// <summary>
/// Echo Train Length (0018;0091) IS 1
/// </summary>
  K_CMDCMTEchoTrainLength = $00180091;

/// <summary>
/// Percent Sampling (0018;0093) DS 1
/// </summary>
  K_CMDCMTPercentSampling = $00180093;

/// <summary>
/// Percent Phase Field of View (0018;0094) DS 1
/// </summary>
  K_CMDCMTPercentPhaseFieldOfView = $00180094;

/// <summary>
/// Pixel Bandwidth (0018;0095) DS 1
/// </summary>
  K_CMDCMTPixelBandwidth = $00180095;

/// <summary>
/// Device Serial Number (0018;1000) LO 1
/// </summary>
  K_CMDCMTDeviceSerialNumber = $00181000;

/// <summary>
/// Device UID (0018;1002) UI 1
/// </summary>
  K_CMDCMTDeviceUID = $00181002;

/// <summary>
/// Plate ID (0018;1004) LO 1
/// </summary>
  K_CMDCMTPlateId = $00181004;

/// <summary>
/// Secondary Capture Device ID (0018;1010) LO 1
/// </summary>
  K_CMDCMTSecondaryCaptureDeviceId = $00181010;

/// <summary>
/// Hardcopy Creation Device ID (0018;1011) LO 1
/// </summary>
  K_CMDCMTHardcopyCreationDeviceId = $00181011;

/// <summary>
/// Date of Secondary Capture (0018;1012) DA 1
/// </summary>
  K_CMDCMTDateOfSecondaryCapture = $00181012;

/// <summary>
/// Time of Secondary Capture (0018;1014) TM 1
/// </summary>
  K_CMDCMTTimeOfSecondaryCapture = $00181014;

/// <summary>
/// Secondary Capture Device Manufacturer (0018;1016) LO 1
/// </summary>
  K_CMDCMTSecondaryCaptureDeviceManufacturer = $00181016;

/// <summary>
/// Hardcopy Device Manufacturer (0018;1017) LO 1
/// </summary>
  K_CMDCMTHardcopyDeviceManufacturer = $00181017;

/// <summary>
/// Secondary Capture Device Manufacturer’s Model Name (0018;1018) LO 1
/// </summary>
  K_CMDCMTSecondaryCaptureDeviceManufacturersModelName = $00181018;

/// <summary>
/// Secondary Capture Device Software Version(s) (0018;1019) LO 1-n
/// </summary>
  K_CMDCMTSecondaryCaptureDeviceSoftwareVersions = $00181019;

/// <summary>
/// Hardcopy Device Software Version (0018;101A) LO 1-n
/// </summary>
  K_CMDCMTHardcopyDeviceSoftwareVersions = $0018101A;

/// <summary>
/// Hardcopy Device Manufacturer's Model Name (0018;101B) LO 1
/// </summary>
  K_CMDCMTHardcopyDeviceManufacturersModelName = $0018101B;

/// <summary>
/// Software Version(s) (0018;1020) LO 1-n
/// </summary>
  K_CMDCMTSoftwareVersions = $00181020;

/// <summary>
/// Video Image Format Acquired (0018;1022) SH 1
/// </summary>
  K_CMDCMTVideoImageFormatAcquired = $00181022;

/// <summary>
/// Digital Image Format Acquired (0018;1023) LO 1
/// </summary>
  K_CMDCMTDigitalImageFormatAcquired = $00181023;

/// <summary>
/// Protocol Name (0018;1030) LO 1
/// </summary>
  K_CMDCMTProtocolName = $00181030;

/// <summary>
/// Contrast/Bolus Route (0018;1040) LO 1
/// </summary>
  K_CMDCMTContrastBolusRoute = $00181040;

/// <summary>
/// Contrast/Bolus Volume (0018;1041) DS 1
/// </summary>
  K_CMDCMTContrastBolusVolume = $00181041;

/// <summary>
/// Contrast/Bolus Start Time (0018;1042) TM 1
/// </summary>
  K_CMDCMTContrastBolusStartTime = $00181042;

/// <summary>
/// Contrast/Bolus Stop Time (0018;1043) TM 1
/// </summary>
  K_CMDCMTContrastBolusStopTime = $00181043;

/// <summary>
/// Contrast/Bolus Total Dose (0018;1044) DS 1
/// </summary>
  K_CMDCMTContrastBolusTotalDose = $00181044;

/// <summary>
/// Syringe Counts (0018;1045) IS 1
/// </summary>
  K_CMDCMTSyringeCounts = $00181045;

/// <summary>
/// Contrast Flow Rate(s) (0018;1046) DS 1-n
/// </summary>
  K_CMDCMTContrastFlowRates = $00181046;

/// <summary>
/// Contrast Flow Duration(s) (0018;1047) DS 1-n
/// </summary>
  K_CMDCMTContrastFlowDurations = $00181047;

/// <summary>
/// Contrast/Bolus Ingredient (0018;1048) CS 1
/// </summary>
  K_CMDCMTContrastBolusIngredient = $00181048;

/// <summary>
/// Contrast/Bolus Ingredient Concentration (0018;1049) DS 1
/// </summary>
  K_CMDCMTContrastBolusIngredientConcentration = $00181049;

/// <summary>
/// Spatial Resolution (0018;1050) DS 1
/// </summary>
  K_CMDCMTSpatialResolution = $00181050;

/// <summary>
/// Trigger Time (0018;1060) DS 1
/// </summary>
  K_CMDCMTTriggerTime = $00181060;

/// <summary>
/// Trigger Source or Type (0018;1061) LO 1
/// </summary>
  K_CMDCMTTriggerSourceOrType = $00181061;

/// <summary>
/// Nominal Interval (0018;1062) IS 1
/// </summary>
  K_CMDCMTNominalInterval = $00181062;

/// <summary>
/// Frame Time (0018;1063) DS 1
/// </summary>
  K_CMDCMTFrameTime = $00181063;

/// <summary>
/// Framing Type (0018;1064) LO 1
/// </summary>
  K_CMDCMTFramingType = $00181064;

/// <summary>
/// Frame Time Vector (0018;1065) DS 1-n
/// </summary>
  K_CMDCMTFrameTimeVectors = $00181065;

/// <summary>
/// Frame Delay (0018;1066) DS 1
/// </summary>
  K_CMDCMTFrameDelay = $00181066;

/// <summary>
/// Image Trigger Delay (0018;1067) DS 1
/// </summary>
  K_CMDCMTImageTriggerDelay = $00181067;

/// <summary>
/// Multiplex Group Time Offset (0018;1068) DS 1
/// </summary>
  K_CMDCMTMultiplexGroupTimeOffset = $00181068;

/// <summary>
/// Trigger Time Offset (0018;1069) DS 1
/// </summary>
  K_CMDCMTTriggerTimeOffset = $00181069;

/// <summary>
/// Synchronization Trigger (0018;106A) CS 1
/// </summary>
  K_CMDCMTSynchronizationTrigger = $0018106A;

/// <summary>
/// Synchronization Channel (0018;106C) US 2
/// </summary>
  K_CMDCMTSynchronizationChannel = $0018106C;

/// <summary>
/// Trigger Sample Position (0018;106E) UL 1
/// </summary>
  K_CMDCMTTriggerSamplePosition = $0018106E;

/// <summary>
/// Radiopharmaceutical Route (0018;1070) LO 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalRoute = $00181070;

/// <summary>
/// Radiopharmaceutical Volume (0018;1071) DS 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalVolume = $00181071;

/// <summary>
/// Radiopharmaceutical Start Time (0018;1072) TM 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalStartTime = $00181072;

/// <summary>
/// Radiopharmaceutical Stop Time (0018;1073) TM 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalStopTime = $00181073;

/// <summary>
/// Radionuclide Total Dose (0018;1074) DS 1
/// </summary>
  K_CMDCMTRadionuclideTotalDose = $00181074;

/// <summary>
/// Radionuclide Half Life (0018;1075) DS 1
/// </summary>
  K_CMDCMTRadionuclideHalfLife = $00181075;

/// <summary>
/// Radionuclide Positron Fraction (0018;1076) DS 1
/// </summary>
  K_CMDCMTRadionuclidePositronFraction = $00181076;

/// <summary>
/// Radiopharmaceutical Specific Activity  K_CMDCMT(0018;1077) DS 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalSpecificActivity = $00181077;

/// <summary>
/// Radiopharmaceutical Start Datetime  (0018;1078) DT 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalStartDatetime = $00181078;

/// <summary>
/// Radiopharmaceutical Stop Datetime  K_CMDCMT(0018;1079) DT 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalStopDatetime = $00181079;

/// <summary>
/// Beat Rejection Flag (0018;1080) CS 1
/// </summary>
  K_CMDCMTBeatRejectionFlag = $00181080;

/// <summary>
/// Low R-R Value (0018;1081) IS 1
/// </summary>
  K_CMDCMTLowRRValue = $00181081;

/// <summary>
/// High R-R Value (0018;1082) IS 1
/// </summary>
  K_CMDCMTHighRRValue = $00181082;

/// <summary>
/// Intervals Acquired (0018;1083) IS 1
/// </summary>
  K_CMDCMTIntervalsAcquired = $00181083;

/// <summary>
/// Intervals Rejected (0018;1084) IS 1
/// </summary>
  K_CMDCMTIntervalsRejected = $00181084;

/// <summary>
/// PVC Rejection (0018;1085) LO 1
/// </summary>
  K_CMDCMTPvcRejection = $00181085;

/// <summary>
/// Skip Beats (0018;1086) IS 1
/// </summary>
  K_CMDCMTSkipBeats = $00181086;

/// <summary>
/// Heart Rate (0018;1088) IS 1
/// </summary>
  K_CMDCMTHeartRate = $00181088;

/// <summary>
/// Cardiac Number of Images (0018;1090) IS 1
/// </summary>
  K_CMDCMTCardiacNumberOfImages = $00181090;

/// <summary>
/// Trigger Window (0018;1094) IS 1
/// </summary>
  K_CMDCMTTriggerWindow = $00181094;

/// <summary>
/// Reconstruction Diameter (0018;1100) DS 1
/// </summary>
  K_CMDCMTReconstructionDiameter = $00181100;

/// <summary>
/// Distance Source to Detector (0018;1110) DS 1
/// </summary>
  K_CMDCMTDistanceSourceToDetector = $00181110;

/// <summary>
/// Distance Source to Patient (0018;1111) DS 1
/// </summary>
  K_CMDCMTDistanceSourceToPatient = $00181111;

/// <summary>
/// Estimated Radiographic Magnification Factor (0018;1114) DS 1
/// </summary>
  K_CMDCMTEstimatedRadiographicMagnificationFactor = $00181114;

/// <summary>
/// Gantry/Detector Tilt (0018;1120) DS 1
/// </summary>
  K_CMDCMTGantryDetectorTilt = $00181120;

/// <summary>
/// Gantry/Detector Slew (0018;1121) DS 1
/// </summary>
  K_CMDCMTGantryDetectorSlew = $00181121;

/// <summary>
/// Table Height (0018;1130) DS 1
/// </summary>
  K_CMDCMTTableHeight = $00181130;

/// <summary>
/// Table Traverse (0018;1131) DS 1
/// </summary>
  K_CMDCMTTableTraverse = $00181131;

/// <summary>
/// Table Motion (0018;1134) CS 1
/// </summary>
  K_CMDCMTTableMotion = $00181134;

/// <summary>
/// Table Vertical Increment (0018;1135) DS 1-n
/// </summary>
  K_CMDCMTTableVerticalIncrement = $00181135;

/// <summary>
/// Table Lateral Increment (0018;1136) DS 1-n
/// </summary>
  K_CMDCMTTableLateralIncrement = $00181136;

/// <summary>
/// Table Longitudinal Increment (0018;1137) DS 1-n
/// </summary>
  K_CMDCMTTableLongitudinalIncrement = $00181137;

/// <summary>
/// Table Angle (0018;1138) DS 1-n
/// </summary>
  K_CMDCMTTableAngle = $00181138;

/// <summary>
/// Table Type (0018;113A) CS 1
/// </summary>
  K_CMDCMTTableType = $0018113A;

/// <summary>
/// Rotation Direction (0018;1140) CS 1
/// </summary>
  K_CMDCMTRotationDirection = $00181140;

/// <summary>
/// Angular Position (0018;1141) DS 1
/// </summary>
  K_CMDCMTAngularPosition = $00181141;

/// <summary>
/// Radial Position (0018;1142) DS 1-n
/// </summary>
  K_CMDCMTRadialPosition = $00181142;

/// <summary>
/// Scan Arc (0018;1143) DS 1
/// </summary>
  K_CMDCMTScanArc = $00181143;

/// <summary>
/// Angular Step (0018;1144) DS 1
/// </summary>
  K_CMDCMTAngularStep = $00181144;

/// <summary>
/// Center of Rotation Offset (0018;1145) DS 1
/// </summary>
  K_CMDCMTCenterOfRotationOffset = $00181145;

/// <summary>
/// Rotation Offset (Retired) (0018;1146) DS 1-n
/// </summary>
  K_CMDCMTRotationOffsetRetired = $00181146;

/// <summary>
/// Field of View Shape (0018;1147) CS 1
/// </summary>
  K_CMDCMTFieldOfViewShape = $00181147;

/// <summary>
/// Field of View Dimension(s) (0018;1149) IS 1-2
/// </summary>
  K_CMDCMTFieldOfViewDimensions = $00181149;

/// <summary>
/// Exposure Time (0018;1150) IS 1
/// </summary>
  K_CMDCMTExposureTime = $00181150;

/// <summary>
/// X-ray Tube Current (0018;1151) IS 1
/// </summary>
  K_CMDCMTXrayTubeCurrent = $00181151;

/// <summary>
/// Exposure (0018;1152) IS 1
/// </summary>
  K_CMDCMTExposure = $00181152;

/// <summary>
/// Exposure in uAs (0018;1153) IS 1
/// </summary>
  K_CMDCMTExposureInUas = $00181153;

/// <summary>
/// Average Pulse Width (0018;1154) DS 1
/// </summary>
  K_CMDCMTAveragePulseWidth = $00181154;

/// <summary>
/// Radiation Setting (0018;1155) CS 1
/// </summary>
  K_CMDCMTRadiationSetting = $00181155;

/// <summary>
/// Rectificaiton Type (0018;1156) CS 1
/// </summary>
  K_CMDCMTRectificationType = $00181156;

/// <summary>
/// Radiation Mode (0018;115A) CS 1
/// </summary>
  K_CMDCMTRadiationMode = $0018115A;

/// <summary>
/// Image and Fluoroscopy Area Dose Product (0018;115E) DS 1
/// </summary>
  K_CMDCMTImageAndFluroscopyAreaDoseProduct = $0018115E;

/// <summary>
/// Filter Type (0018;1160) SH 1
/// </summary>
  K_CMDCMTFilterType = $00181160;

/// <summary>
/// Type of Filters (0018;1161) LO 1-n
/// </summary>
  K_CMDCMTTypeOfFilters = $00181161;

/// <summary>
/// Intensifier Size (0018;1162) DS 1
/// </summary>
  K_CMDCMTIntensifierSize = $00181162;

/// <summary>
/// Imager Pixel Spacing (0018;1164) DS 2
/// </summary>
  K_CMDCMTImagerPixelSpacing = $00181164;

/// <summary>
/// Grid (0018;1166) CS 1-n
/// </summary>
  K_CMDCMTGrid = $00181166;

/// <summary>
/// Generator Power (0018;1170) IS 1
/// </summary>
  K_CMDCMTGeneratorPower = $00181170;

/// <summary>
/// Collimator/grid Name (0018;1180) SH 1
/// </summary>
  K_CMDCMTCollimatorGridName = $00181180;

/// <summary>
/// Collimator Type (0018;1181) CS 1
/// </summary>
  K_CMDCMTCollimatorType = $00181181;

/// <summary>
/// Focal Distance (0018;1182) IS 1-2
/// </summary>
  K_CMDCMTFocalDistance = $00181182;

/// <summary>
/// X Focus Center (0018;1183) DS 1-2
/// </summary>
  K_CMDCMTFocusCenterX = $00181183;

/// <summary>
/// Y Focus Center (0018;1184) DS 1-2
/// </summary>
  K_CMDCMTFocusCenterY = $00181184;

/// <summary>
/// Focal Spot(s) (0018;1190) DS 1-n
/// </summary>
  K_CMDCMTFocalSpots = $00181190;

/// <summary>
/// Anode Target Material (0018;1191) CS 1
/// </summary>
  K_CMDCMTAnodeTargetMaterial = $00181191;

/// <summary>
/// Body Part Thickness (0018;11A0) DS 1
/// </summary>
  K_CMDCMTBodyPartThickness = $001811A0;

/// <summary>
/// Compression Force (0018;11A2) DS 1
/// </summary>
  K_CMDCMTCompressionForce = $001811A2;

/// <summary>
/// Date of Last Calibration (0018;1200) DA 1-n
/// </summary>
  K_CMDCMTDateOfLastCalibration = $00181200;

/// <summary>
/// Time of Last Calibration (0018;1201) TM 1-n
/// </summary>
  K_CMDCMTTimeOfLastCalibration = $00181201;

/// <summary>
/// Convolution Kernel (0018;1210) SH 1-n
/// </summary>
  K_CMDCMTConvolutionKernel = $00181210;

/// <summary>
/// Upper/Lower Pixel Values (Retired) (0018;1240) IS 1-n
/// </summary>
  K_CMDCMTUpperLowerPixelValuesRetired = $00181240;

/// <summary>
/// Actual Frame Duration (0018;1242) IS 1
/// </summary>
  K_CMDCMTActualFrameDuration = $00181242;

/// <summary>
/// Count Rate (0018;1243) IS 1
/// </summary>
  K_CMDCMTCountRate = $00181243;

/// <summary>
/// Preferred Playback Sequence (0018;1244) US 1
/// </summary>
  K_CMDCMTRreferredPlaybackSequencing = $00181244;

/// <summary>
/// Receive Coil Name (0018;1250) SH 1
/// </summary>
  K_CMDCMTReceiveCoilName = $00181250;

/// <summary>
/// Transmit Coil Name (0018;1251) SH 1
/// </summary>
  K_CMDCMTTransmitCoilName = $00181251;

/// <summary>
/// Plate Type (0018;1260) SH 1
/// </summary>
  K_CMDCMTPlateType = $00181260;

/// <summary>
/// Phosphor Type (0018;1261) LO 1
/// </summary>
  K_CMDCMTPhosphorType = $00181261;

/// <summary>
/// Scan Velocity (0018;1300) DS 1
/// </summary>
  K_CMDCMTScanVelocity = $00181300;

/// <summary>
/// Whole body Technique (0018;1301) CS 1-n
/// </summary>
  K_CMDCMTWholeBodyTechnique = $00181301;

/// <summary>
/// Scan Length (0018;1302) IS 1
/// </summary>
  K_CMDCMTScanLength = $00181302;

/// <summary>
/// Acquisition Matrix (0018;1310) US 4
/// </summary>
  K_CMDCMTAcquisitionMatrix = $00181310;

/// <summary>
/// In-plane Phase Encoding Direction (0018;1312) CS 1
/// </summary>
  K_CMDCMTInPlanePhaseEncodingDirection = $00181312;

/// <summary>
/// Flip Angle (0018;1314) DS 1
/// </summary>
  K_CMDCMTFlipAngle = $00181314;

/// <summary>
/// Variable Flip Angle Flag (0018;1315) CS 1
/// </summary>
  K_CMDCMTVariableFlipAngleFlag = $00181315;

/// <summary>
/// SAR (0018;1316) DS 1
/// </summary>
  K_CMDCMTSar = $00181316;

/// <summary>
/// dB/dt (0018;1318) DS 1
/// </summary>
  K_CMDCMTDbdt = $00181318;

/// <summary>
/// Acquisition Device Processing Description (0018;1400) LO 1
/// </summary>
  K_CMDCMTAcquisitionDeviceProcessingDescription = $00181400;

/// <summary>
/// Acquisition Device Processing Code (0018;1401) LO 1
/// </summary>
  K_CMDCMTAcquisitionDeviceProcessingCode = $00181401;

/// <summary>
/// Cassette Orientation (0018;1402) CS 1
/// </summary>
  K_CMDCMTCassetteOrientation = $00181402;

/// <summary>
/// Cassette Size (0018;1403) CS 1
/// </summary>
  K_CMDCMTCassetteSize = $00181403;

/// <summary>
/// Exposures on Plate (0018;1404) US 1
/// </summary>
  K_CMDCMTExposuresOnPlate = $00181404;

/// <summary>
/// Relative X-ray Exposure (0018;1405) IS 1
/// </summary>
  K_CMDCMTRelativeXrayExposure = $00181405;

/// <summary>
/// Column Angulation (0018;1450) DS 1
/// </summary>
  K_CMDCMTColumnAngulation = $00181450;

/// <summary>
/// Tomo Layer Height (0018;1460) DS 1
/// </summary>
  K_CMDCMTTomoLayerHeight = $00181460;

/// <summary>
/// Tomo Angle (0018;1470) DS 1
/// </summary>
  K_CMDCMTTomoAngle = $00181470;

/// <summary>
/// Tomo Time (0018;1480) DS 1
/// </summary>
  K_CMDCMTTomoTime = $00181480;

/// <summary>
/// Tomo Type (0018;1490) CS 1
/// </summary>
  K_CMDCMTTomoType = $00181490;

/// <summary>
/// Tomo Class (0018;1491) CS 1
/// </summary>
  K_CMDCMTTomoClass = $00181491;

/// <summary>
/// Number of tomosynthesis Source Images (0018;1495) IS 1
/// </summary>
  K_CMDCMTNumberOfTomosynthesisSourceImages = $00181495;

/// <summary>
/// Positioner Motion (0018;1500) CS 1
/// </summary>
  K_CMDCMTPositionerMotion = $00181500;

/// <summary>
/// Positioner Type (0018;1508) CS 1
/// </summary>
  K_CMDCMTPositionerType = $00181508;

/// <summary>
/// Positioner Primary Angle (0018;1510) DS 1
/// </summary>
  K_CMDCMTPositionerPrimaryAngle = $00181510;

/// <summary>
/// Positioner Secondary Angle (0018;1511) DS 1
/// </summary>
  K_CMDCMTPositionerSecondaryAngle = $00181511;

/// <summary>
/// Positioner Primary Angle Increment (0018;1520) DS 1-n
/// </summary>
  K_CMDCMTPositionerPrimaryAngleIncrement = $00181520;

/// <summary>
/// Positioner Secondary Angle Increment (0018;1521) DS 1-n
/// </summary>
  K_CMDCMTPositionerSecondaryAngleIncrement = $00181521;

/// <summary>
/// Detector Primary Angle (0018;1530) DS 1
/// </summary>
  K_CMDCMTDetectorPrimaryAngle = $00181530;

/// <summary>
/// Detector Secondary Angle (0018;1531) DS 1
/// </summary>
  K_CMDCMTDetectorSecondaryAngle = $00181531;

/// <summary>
/// Shutter Shape (0018;1600) CS 1-3
/// </summary>
  K_CMDCMTShutterShape = $00181600;

/// <summary>
/// Shutter Left Vertical Edge (0018;1602) IS 1
/// </summary>
  K_CMDCMTShutterLeftVerticalEdge = $00181602;

/// <summary>
/// Shutter Right Vertical Edge (0018;1604) IS 1
/// </summary>
  K_CMDCMTShutterRightVerticalEdge = $00181604;

/// <summary>
/// Shutter Upper Horizontal Edge (0018;1606) IS 1
/// </summary>
  K_CMDCMTShutterUpperHorizontalEdge = $00181606;

/// <summary>
/// Shutter Lower Horizontal Edge (0018;1608) IS 1
/// </summary>
  K_CMDCMTShutterLowerHorizontalEdge = $00181608;

/// <summary>
/// Center of Circular Shutter (0018;1610) IS 2
/// </summary>
  K_CMDCMTCenterOfCircularShutter = $00181610;

/// <summary>
/// Radius of Circular Shutter (0018;1612) IS 1
/// </summary>
  K_CMDCMTRadiusOfCircularShutter = $00181612;

/// <summary>
/// Vertices of the Polygonal Shutter (0018;1620) IS 2-2n
/// </summary>
  K_CMDCMTVerticesOfThePolygonalShutter = $00181620;

/// <summary>
/// Shutter Presentation Value (0018;1622) US 1
/// </summary>
  K_CMDCMTShutterPresentationValue = $00181622;

/// <summary>
/// Shutter Overlay Group (0018;1623) US 1
/// </summary>
  K_CMDCMTShutterOverlayGroup = $00181623;

/// <summary>
/// Shutter Presentation Color CIELab Value (0018;1624) US 3
/// </summary>
  K_CMDCMTShutterPresentationColorCIELabValue = $00181624;

/// <summary>
/// Collimator Shape (0018;1700) CS 1-3
/// </summary>
  K_CMDCMTCollimatorShape = $00181700;

/// <summary>
/// Collimator Left Vertical Edge (0018;1702) IS 1
/// </summary>
  K_CMDCMTCollimatorLeftVerticalEdge = $00181702;

/// <summary>
/// Collimator Right Vertical Edge (0018;1704) IS 1
/// </summary>
  K_CMDCMTCollimatorRightVerticalEdge = $00181704;

/// <summary>
/// Collimator Upper Horizontal Edge (0018;1706) IS 1
/// </summary>
  K_CMDCMTCollimatorUpperHorizontalEdge = $00181706;

/// <summary>
/// Collimator Lower Horizontal Edge (0018;1708) IS 1
/// </summary>
  K_CMDCMTCollimatorLowerHorizontalEdge = $00181708;

/// <summary>
/// Center of Circular Collimator (0018;1710) IS 2
/// </summary>
  K_CMDCMTCenterOfCircularCollimator = $00181710;

/// <summary>
/// Radius of circular Collimator (0018;1712) IS 1
/// </summary>
  K_CMDCMTRadiusOfCircularCollimator = $00181712;

/// <summary>
/// Vertices of the Polygonal Collimator (0018;1720) IS 2-2n
/// </summary>
  K_CMDCMTVerticesOfThePolygonalCollimator = $00181720;

/// <summary>
/// Acquisition Time Synchronized (0018;1800) CS 1
/// </summary>
  K_CMDCMTAcquisitionTimeSynchronized = $00181800;

/// <summary>
/// Time Source (0018;1801) SH 1
/// </summary>
  K_CMDCMTTimeSource = $00181801;

/// <summary>
/// Time Distribution Protocol (0018;1802) CS 1
/// </summary>
  K_CMDCMTTimeDistributionProtocol = $00181802;

/// <summary>
/// NTP Source Address (0018;1803) LO 1
/// </summary>
  K_CMDCMTNtpSourceAddress = $00181803;

/// <summary>
/// Page Number Vector (0018;2001) IS 1-n
/// </summary>
  K_CMDCMTPageNumberVector = $00182001;

/// <summary>
/// Frame Label Vector (0018;2002) SH 1-n
/// </summary>
  K_CMDCMTFrameLabelVector = $00182002;

/// <summary>
/// Frame Primary Angle Vector (0018;2003) DS 1-n
/// </summary>
  K_CMDCMTFramePrimaryAngleVector = $00182003;

/// <summary>
///  K_CMDCMTFrame Secondary Angle Vector (0018;2004) DS 1-n
/// </summary>
  K_CMDCMTFrameSecondaryAngleVector = $00182004;

/// <summary>
/// Slice Location Vector (0018;2005) DS 1-n
/// </summary>
  K_CMDCMTSliceLocationVector = $00182005;

/// <summary>
/// Display Window Label Vector (0018;2006) SH 1-n
/// </summary>
  K_CMDCMTDisplayWindowLabelVector = $00182006;

/// <summary>
/// Nominal Scanned Pixel Spacing (0018;2010) DS 2
/// </summary>
  K_CMDCMTNominalScannedPixelSpacing = $00182010;

/// <summary>
/// Digitizing Device Transport Direction (0018;2020) CS 1
/// </summary>
  K_CMDCMTDigitizingDeviceTransportDirection = $00182020;

/// <summary>
/// Rotation of Scanned Film (0018;2030) DS 1
/// </summary>
  K_CMDCMTRotationOfScannedFilm = $00182030;

/// <summary>
/// IVUS Acquisition (0018;3100) CS 1
/// </summary>
  K_CMDCMTIvusAcquisition = $00183100;

/// <summary>
/// IVUS Pullback Rate (0018;3101) DS 1
/// </summary>
  K_CMDCMTIvusPullbackRate = $00183101;

/// <summary>
/// IVUS Gated Rate (0018;3102) DS 1
/// </summary>
  K_CMDCMTIvusGatedRate = $00183102;

/// <summary>
/// IVUS Pullback Start Frame Number (0018;3103) IS 1
/// </summary>
  K_CMDCMTIvusPullbackStartFrameNumber = $00183103;

/// <summary>
/// IVUS Pullback Stop Frame Number (0018;3104) IS 1
/// </summary>
  K_CMDCMTIvusPullbackStopFrameNumber = $00183104;

/// <summary>
/// Lesion Number (0018;3105) IS 1-n
/// </summary>
  K_CMDCMTLesionNumber = $00183105;

/// <summary>
/// Acquisition Comments (Retired)  K_CMDCMT(0018;4000) LT 1
/// </summary>
  K_CMDCMTAcquisitionCommentsRetired = $00184000;

/// <summary>
/// Output Power (0018;5000) SH 1-n
/// </summary>
  K_CMDCMTOutputPower = $00185000;

/// <summary>
/// Transducer Data (0018;5010) LO 3
/// </summary>
  K_CMDCMTTransducerData = $00185010;

/// <summary>
/// Focus Depth (0018;5012) DS 1
/// </summary>
  K_CMDCMTFocusDepth = $00185012;

/// <summary>
/// Processing Function (0018;5020) LO 1
/// </summary>
  K_CMDCMTProcessingFunction = $00185020;

/// <summary>
/// Postprocessing Function (0018;5021) LO 1
/// </summary>
  K_CMDCMTPostprocessingFunction = $00185021;

/// <summary>
/// Mechanical Index (0018;5022) DS 1
/// </summary>
  K_CMDCMTMechanicalIndex = $00185022;

/// <summary>
/// Bone Thermal Index (0018;5024) DS 1
/// </summary>
  K_CMDCMTBoneThermalIndex = $00185024;

/// <summary>
/// Cranial Thermal Index (0018;5026) DS 1
/// </summary>
  K_CMDCMTCranialThermalIndex = $00185026;

/// <summary>
/// Soft Tissue Thermal Index (0018;5027) DS 1
/// </summary>
  K_CMDCMTSoftTissueThermalIndex = $00185027;

/// <summary>
/// Soft Tissue Focus Thermal Index (0018;5028) DS 1
/// </summary>
  K_CMDCMTSoftTissueFocusThermalIndex = $00185028;

/// <summary>
/// Soft Tissue Surface Thermal Index (0018;5029) DS 1
/// </summary>
  K_CMDCMTSoftTissueSurfaceThermalIndex = $00185029;

/// <summary>
/// Dynamic Range (Retired) (0018;5030) DS 1
/// </summary>
  K_CMDCMTDynamicRangeRetired = $00185030;

/// <summary>
/// Total Gain (Retired) (0018;5040) DS 1
/// </summary>
  K_CMDCMTTotalGainRetired = $00185040;

/// <summary>
/// Depth of Scan Field (0018;5050) IS 1
/// </summary>
  K_CMDCMTDepthOfScanField = $00185050;

/// <summary>
/// Patient Position (0018;5100) CS 1
/// </summary>
  K_CMDCMTPatientPosition = $00185100;

/// <summary>
/// View Position (0018;5101) CS 1
/// </summary>
  K_CMDCMTViewPosition = $00185101;

/// <summary>
/// Projection Eponymous Name Code Sequence (0018;5104) SQ 1
/// </summary>
  K_CMDCMTProjectionEponymousNameCodeSequence = $00185104;

/// <summary>
/// Image Transformation Matrix (0018;5210) DS 6
/// </summary>
  K_CMDCMTImageTransformationMatrix = $00185210;

/// <summary>
/// Image Translation Vector (0018;5212) DS 3
/// </summary>
  K_CMDCMTImageTranslationVector = $00185212;

/// <summary>
/// Sensitivity (0018;6000) DS 1
/// </summary>
  K_CMDCMTSensitivity = $00186000;

/// <summary>
/// Sequence of Ultrasound Regions (0018;6011) SQ 1
/// </summary>
  K_CMDCMTSequenceOfUltrasoundRegions = $00186011;

/// <summary>
/// Region Spatial Format (0018;6012) US 1
/// </summary>
  K_CMDCMTRegionSpatialFormat = $00186012;

/// <summary>
/// Region Data Type (0018;6014) US 1
/// </summary>
  K_CMDCMTRegionDataType = $00186014;

/// <summary>
/// Region Flags (0018;6016) UL 1
/// </summary>
  K_CMDCMTRegionFlags = $00186016;

/// <summary>
/// Region Location Min X0 (0018;6018) UL 1
/// </summary>
  K_CMDCMTRegionLocationMinX0 = $00186018;

/// <summary>
/// Region Location Min Y0 (0018;601A) UL 1
/// </summary>
  K_CMDCMTRegionLocationMinY0 = $0018601A;

/// <summary>
/// Region Location Max X1 (0018;601C) UL 1
/// </summary>
  K_CMDCMTRegionLocationMaxX1 = $0018601C;

/// <summary>
/// Region Location Max Y1 (0018;601E) UL 1
/// </summary>
  K_CMDCMTRegionLocationMaxY1 = $0018601E;

/// <summary>
/// Reference Pixel X0 (0018;6020) SL 1
/// </summary>
  K_CMDCMTReferencePixelX0 = $00186020;

/// <summary>
/// Reference Pixel Y0 (0018;6022) SL 1
/// </summary>
  K_CMDCMTReferencePixelY0 = $00186022;

/// <summary>
/// Physical Units X Direction (0018;6024) US 1
/// </summary>
  K_CMDCMTPhysicalUnitsXDirection = $00186024;

/// <summary>
/// Physical Units Y Direction (0018;5026) US 1
/// </summary>
  K_CMDCMTPhysicalUnitsYDirection = $00186026;

/// <summary>
/// Reference Pixel Physical Value X (0018;6028) FD 1
/// </summary>
  K_CMDCMTReferencePixelPhysicalValueX = $00186028;

/// <summary>
/// Reference Pixel Physical Value Y (0018;602A) FD 1
/// </summary>
  K_CMDCMTReferencePixelPhysicalValueY = $0018602A;

/// <summary>
/// Physical Delta X (0018;602C) FD 1
/// </summary>
  K_CMDCMTPhysicalDeltaX = $0018602C;

/// <summary>
/// Physical Delta Y (0018;602E) FD 1
/// </summary>
  K_CMDCMTPhysicalDeltaY = $0018602E;

/// <summary>
/// Transducer Frequency (0018;6030) UL 1
/// </summary>
  K_CMDCMTTransducerFrequency = $00186030;

/// <summary>
/// Transducer Type (0018;6031) CS 1
/// </summary>
  K_CMDCMTTransducerType = $00186031;

/// <summary>
/// Pulse Repetition Frequency (0018;6032) UL 1
/// </summary>
  K_CMDCMTPulseRepetitionFrequency = $00186032;

/// <summary>
/// Doppler Correction Angle (0018;6034) FD 1
/// </summary>
  K_CMDCMTDopplerCorrectionAngle = $00186034;

/// <summary>
/// Steering Angle (0018;6036) FD 1
/// </summary>
  K_CMDCMTSteeringAngle = $00186036;

/// <summary>
/// Doppler Sample Volume X Position (Retired) (0018;6038) UL 1
/// </summary>
  K_CMDCMTDopplerSampleVolumeXPositionRetired = $00186038;

/// <summary>
/// Doppler Sample Volume X Position (0018;6039) SL 1
/// </summary>
  K_CMDCMTDopplerSampleVolumeXPosition = $00186039;

/// <summary>
/// Doppler Sample Volume Y Position (Retired) (0018;603A) UL 1
/// </summary>
  K_CMDCMTDopplerSampleVolumeYPositionRetired = $0018603A;

/// <summary>
/// Doppler Sample Volume Y Position (0018;603B) SL 1
/// </summary>
  K_CMDCMTDopplerSampleVolumeYPosition = $0018603B;

/// <summary>
/// TM-Line Position X0 (Retired) (0018;603C) UL 1
/// </summary>
  K_CMDCMTTMLinePositionX0Retired = $0018603C;

/// <summary>
/// TM-Line Position X0 (0018;603D) SL 1
/// </summary>
  K_CMDCMTTMLinePositionX0 = $0018603D;

/// <summary>
/// TM-Line Position Y0 (Retired) (0018;603E) UL 1
/// </summary>
  K_CMDCMTTMLinePositionY0Retired = $0018603E;

/// <summary>
/// TM-Line Position Y0 (0018;603F) SL 1
/// </summary>
  K_CMDCMTTMLinePositionY0 = $0018603F;

/// <summary>
/// TM-Line Position X1 (Retired) (0018;6040) UL 1
/// </summary>
  K_CMDCMTTMLinePositionX1Retired = $00186040;

/// <summary>
/// TM-Line Position X1 (0018;6041) SL 1
/// </summary>
  K_CMDCMTTMLinePositionX1 = $00186041;

/// <summary>
/// TM-Line Position Y1 (Retired) (0018;6042) UL 1
/// </summary>
  K_CMDCMTTMLinePositionY1Retired = $00186042;

/// <summary>
/// TM-Line Position Y1 (0018;6043) SL 1
/// </summary>
  K_CMDCMTTMLinePositionY1 = $00186043;

/// <summary>
/// Pixel Component Organization (0018;6044) US 1
/// </summary>
  K_CMDCMTPixelComponentOrganization = $00186044;

/// <summary>
/// Pixel Component Mask (0018;6046) UL 1
/// </summary>
  K_CMDCMTPixelComponentMask = $00186046;

/// <summary>
/// Pixel Component Range Start (0018;6048) UL 1
/// </summary>
  K_CMDCMTPixelComponentRangeStart = $00186048;

/// <summary>
/// Pixel Component Range Stop (0018;604A) UL 1
/// </summary>
  K_CMDCMTPixelComponentRangeStop = $0018604A;

/// <summary>
/// Pixel Component Physical Units (0018;604C) US 1
/// </summary>
  K_CMDCMTPixelComponentPhysicalUnits = $0018604C;

/// <summary>
/// Pixel Component Data Type (0018;604E) US 1
/// </summary>
  K_CMDCMTPixelComponentDataType = $0018604E;

/// <summary>
/// Number of Table Break Points (0018;6050) UL 1
/// </summary>
  K_CMDCMTNumberOfTableBreakPoints = $00186050;

/// <summary>
/// Table of X Break Points (0018;6052) UL 1-n 
/// </summary>
  K_CMDCMTTableOfXBreakPoints = $00186052;

/// <summary>
/// Table of Y Break Points (0018;6054) FD 1-n
/// </summary>
  K_CMDCMTTableOfYBreakPoints = $00186054;

/// <summary>
/// Number of Table Entries (0018;6056) UL 1
/// </summary>
  K_CMDCMTNumberOfTableEntries = $00186056;

/// <summary>
/// Talbe of Pixel Values (0018;6058) UL 1-n
/// </summary>
  K_CMDCMTTableOfPixelValues = $00186058;

/// <summary>
/// Table of Parameter Values (0018;605A) FL 1-n
/// </summary>
  K_CMDCMTTableOfParameterValues = $0018605A;

/// <summary>
/// R Wave Time Vector (0018;6060) FL 1-n
/// </summary>
  K_CMDCMTRWaveTimeVector = $00186060;

/// <summary>
/// Detector Conditions Nominal Flag (0018;7000) CS 1
/// </summary>
  K_CMDCMTDetectorConditionsNominalFlag = $00187000;

/// <summary>
/// Detector Temperature (0018;7001) DS 1
/// </summary>
  K_CMDCMTDetectorTemperature = $00187001;

/// <summary>
/// Detector Type (0018;7004) CS 1
/// </summary>
  K_CMDCMTDetectorType = $00187004;

/// <summary>
/// Detector Configuration (0018;7005) CS 1
/// </summary>
  K_CMDCMTDetectorConfiguration = $00187005;

/// <summary>
/// Detector Description (0018;7006) LT 1
/// </summary>
  K_CMDCMTDetectorDescription = $00187006;

/// <summary>
/// Detector Mode (0018;7008) LT 1
/// </summary>
  K_CMDCMTDetectorMode = $00187008;

/// <summary>
/// Detector ID (0018;700A) SH 1
/// </summary>
  K_CMDCMTDetectorId = $0018700A;

/// <summary>
/// Date of Last Detector Calibration (0018;700C) DA 1
/// </summary>
  K_CMDCMTDateOfLastDetectorCalibration = $0018700C;

/// <summary>
/// Time of Last Detector Calibration (0018;700E) TM 1
/// </summary>
  K_CMDCMTTimeOfLastDetectorCalibration = $0018700E;

/// <summary>
/// Exposures on Detector Since Last Calibration (0018;7010) IS 1
/// </summary>
  K_CMDCMTExposuresOnDetectorSinceLastCalibration = $00187010;

/// <summary>
/// Exposures on Detector Since Manufactured (0018;7011) IS 1
/// </summary>
  K_CMDCMTExposuresOnDetectorSinceManufactured = $00187011;

/// <summary>
/// Detector Time Since Last Exposure (0018;7012) DS 1
/// </summary>
  K_CMDCMTDetectorTimeSinceLastExposure = $00187012;

/// <summary>
/// Detector Active Time (0018;7014) DS 1
/// </summary>
  K_CMDCMTDetectorActiveTime = $00187014;

/// <summary>
/// Detector Activation Offset From Exposure (0018;7016) DS 1
/// </summary>
  K_CMDCMTDetectorActivationOffsetFromExposure = $00187016;

/// <summary>
/// Detector Binning (0018;701A) DS 2 
/// </summary>
  K_CMDCMTDetectorBinning = $0018701A;

/// <summary>
/// Detector Manufacturer Name (0018;702A) LO 1 
/// </summary>
  K_CMDCMTDetectorManufacturerName = $0018702A;

/// <summary>
/// Detector Manufacturer??s Model Name (0018;702B) LO 1 
/// </summary>
  K_CMDCMTDetectorManufacturersModelName = $0018702B;

/// <summary>
/// Detector Element Physical Size (0018;7020) DS 2
/// </summary>
  K_CMDCMTDetectorElementPhysicalSize = $00187020;

/// <summary>
/// Detector Element Spacing (0018;7022) DS 2
/// </summary>
  K_CMDCMTDetectorElementSpacing = $00187022;

/// <summary>
/// Detector Active Shape (0018;7024) CS 1
/// </summary>
  K_CMDCMTDetectorActiveShape = $00187024;

/// <summary>
/// Detector Active Dimension(s) (0018;7026) DS 1-2
/// </summary>
  K_CMDCMTDetectorActiveDimensions = $00187026;

/// <summary>
/// Detector Active Origin (0018;7028) DS 2
/// </summary>
  K_CMDCMTDetectorActiveOrigin = $00187028;

/// <summary>
/// Field of View Origin (0018;7030) DS 2
/// </summary>
  K_CMDCMTFieldOfViewOrigin = $00187030;

/// <summary>
/// Field of View Rotation (0018;7032) DS 1
/// </summary>
  K_CMDCMTFieldOfViewRotation = $00187032;

/// <summary>
/// Field of View Horizontal Flip (0018;7034) CS 1
/// </summary>
  K_CMDCMTFieldOfViewHorizontalFlip = $00187034;

/// <summary>
/// Grid Absorbing Material (0018;7040) LT 1
/// </summary>
  K_CMDCMTGridAbsorbingMaterial = $00187040;

/// <summary>
/// Grid Spacing Material (0018;7041) LT 1
/// </summary>
  K_CMDCMTGridSpacingMaterial = $00187041;

/// <summary>
/// Grid Thickness (0018;7042) DS 1
/// </summary>
  K_CMDCMTGridThickness = $00187042;

/// <summary>
/// Grid Pitch (0018;7044) DS 1
/// </summary>
  K_CMDCMTGridPitch = $00187044;

/// <summary>
/// Grid Aspect Ratio (0018;7046) IS 2
/// </summary>
  K_CMDCMTGridAspectRatio = $00187046;

/// <summary>
/// Grid Period (0018;7048) DS 1
/// </summary>
  K_CMDCMTGridPeriod = $00187048;

/// <summary>
/// Grid Focal Distance (0018;704C) DS 1
/// </summary>
  K_CMDCMTGridFocalDistance = $0018704C;

/// <summary>
/// Filter Material (0018;7050) CS 1-n
/// </summary>
  K_CMDCMTFilterMaterial = $00187050;

/// <summary>
/// Filter Thickness Minimum (0018;7052) DS 1-n
/// </summary>
  K_CMDCMTFilterThicknessMinimum = $00187052;

/// <summary>
/// Filter Thickness Maximum (0018;7054) DS 1-n
/// </summary>
  K_CMDCMTFilterThicknessMaximum = $00187054;

/// <summary>
/// Exposure Control Mode (0018;7060) CS 1
/// </summary>
  K_CMDCMTExposureControlMode = $00187060;

/// <summary>
/// Exposure Control Mode Description (0018;7062) LT 1
/// </summary>
  K_CMDCMTExposureControlModeDescription = $00187062;

/// <summary>
/// Exposure Status (0018;7064) CS 1
/// </summary>
  K_CMDCMTExposureStatus = $00187064;

/// <summary>
/// Phototimer Setting (0018;7065) DS 1
/// </summary>
  K_CMDCMTPhototimerSetting = $00187065;

/// <summary>
/// Exposure Time in uS (0018;8150) DS 1
/// </summary>
  K_CMDCMTExposureTimeInuS = $00188150;

/// <summary>
/// X-Ray Tube Curent in uA (0018;8151) DS 1
/// </summary>
  K_CMDCMTXrayTubeCurrentInuA = $00188151;

/// <summary>
/// Content Qualification (0018;9004) CS 1
/// </summary>
  K_CMDCMTContentQualification = $00189004;

/// <summary>
/// Pulse Sequence Name (0018;9005) SH 1
/// </summary>
  K_CMDCMTPulseSequenceName = $00189005;

/// <summary>
/// MR Imaging Modifier Sequence (0018;9006) SQ 1
/// </summary>
  K_CMDCMTMRImagingModifierSequence = $00189006;

/// <summary>
/// Echo Pulse Sequence (0018;9008) CS 1
/// </summary>
  K_CMDCMTEchoPulseSequence = $00189008;

/// <summary>
/// Inversion Recovery (0018;9009) CS 1
/// </summary>
  K_CMDCMTInversionRecovery = $00189009;

/// <summary>
/// Flow Compensation (0018;9010) CS 1
/// </summary>
  K_CMDCMTFlowCompensation = $00189010;

/// <summary>
/// Multiple Spin Echo (0018;9011) CS 1
/// </summary>
  K_CMDCMTMultipleSpinEcho = $00189011;

/// <summary>
/// Multi-planar Excitation (0018;9012) CS 1
/// </summary>
  K_CMDCMTMultiPlanarExcitation = $00189012;

/// <summary>
/// Phase Contrast (0018;9014) CS 1
/// </summary>
  K_CMDCMTPhaseContrast = $00189014;

/// <summary>
/// Time of Flight Contrast (0018;9015) CS 1
/// </summary>
  K_CMDCMTTimeOfFlightContrast = $00189015;

/// <summary>
/// Spoiling (0018;9016) CS 1
/// </summary>
  K_CMDCMTSpoiling = $00189016;

/// <summary>
/// Steady State Pulse Sequence (0018;9017) CS 1
/// </summary>
  K_CMDCMTSteadyStatePulseSequence = $00189017;

/// <summary>
/// Echo Planar Pulse Sequence (0018;9018) CS 1
/// </summary>
  K_CMDCMTEchoPlanarPulseSequence = $00189018;

/// <summary>
/// Tag Angle First Axis (0018;9019) FD 1
/// </summary>
  K_CMDCMTTagAngleFirstAxis = $00189019;

/// <summary>
/// Magnetization Transfer (0018;9020) CS 1
/// </summary>
  K_CMDCMTMagnetizationTransfer = $00189020;

/// <summary>
/// T2 Preparation (0018;9021) CS 1
/// </summary>
  K_CMDCMTT2Preparation = $00189021;

/// <summary>
/// Blood Signal Nulling DELETED (0018;9022) CS 1  K_CMDCMT//page 26 Adobe part 6 has 2 listings of blood signal nulling
/// </summary>
/// <remarks>
/// DELETED in 2006 changes
/// </remarks>
  K_CMDCMTBloodSignalNullingDeleted = $00189022;

/// <summary>
/// Saturation Recovery (0018;9024) CS 1
/// </summary>
  K_CMDCMTSaturationRecovery = $00189024;

/// <summary>
/// Spectrally Selected Suppressions (0018;9025) CS 1
/// </summary>
  K_CMDCMTSpectrallySelectedSuppressions = $00189025;

/// <summary>
/// Spectrally Selected Excitation (0018;9026) CS 1
/// </summary>
  K_CMDCMTSpectrallySelectedExcitation = $00189026;

/// <summary>
/// Spatial Pre-saturation (0018;9027) CS 1
/// </summary>
  K_CMDCMTSpatialPreSaturation = $00189027;

/// <summary>
/// Tagging (0018;9028) CS 1
/// </summary>
  K_CMDCMTTagging = $00189028;

/// <summary>
/// Oversampling Phase (0018;9029) CS 1
/// </summary>
  K_CMDCMTOverSamplingPhase = $00189029;

/// <summary>
/// Tag Spacing First Dimension (0018;9030) FD 1
/// </summary>
  K_CMDCMTTagSpacingFirstDimension = $00189030;

/// <summary>
/// Geometry of k-Space Traversal (0018;9032) CS 1
/// </summary>
  K_CMDCMTGeometryOfKSpaceTraversal = $00189032;

/// <summary>
/// Segmented k-Space Traversal (0018;9033) CS 1
/// </summary>
  K_CMDCMTSegmentedKSpaceTraversal = $00189033;

/// <summary>
/// Rectilinear Phase Encode Reordering (0018;9034) CS 1
/// </summary>
  K_CMDCMTRectilinearPhaseEncodeReordering = $00189034;

/// <summary>
/// Tag Thickness (0018;9035) FD 1
/// </summary>
  K_CMDCMTTagThickness = $00189035;

/// <summary>
/// Partial Fourier Direction (0018;9036) CS 1
/// </summary>
  K_CMDCMTPartialFourierDirection = $00189036;

/// <summary>
/// Cardiac Synchronization Technique (0018;9037) CS 1
/// </summary>
  K_CMDCMTCardiacSynchronizationTechnique = $00189037;

/// <summary>
/// Receive Coil Manufacturer Name (0018;9041) LO 1
/// </summary>
  K_CMDCMTReceiveCoilManufacturerName = $00189041;

/// <summary>
/// MR Receive Coil Sequence (0018;9042) SQ 1
/// </summary>
  K_CMDCMTMRReceiveCoilSequence = $00189042;

/// <summary>
/// Receive Coil Type (0018;9043) CS 1
/// </summary>
  K_CMDCMTReceiveCoilType = $00189043;

/// <summary>
/// Quadrature Receive Coil (0018;9044) CS 1
/// </summary>
  K_CMDCMTQuadratureReceiveCoil = $00189044;

/// <summary>
/// Multi-Coil Definition Sequence (0018;9045) SQ 1
/// </summary>
  K_CMDCMTMultiCoilDefinitionSequence = $00189045;

/// <summary>
/// Multi-Coil Configuration (0018;9046) LO 1
/// </summary>
  K_CMDCMTMultiCoilConfiguration = $00189046;

/// <summary>
/// Multi-Coil Element Name (0018;9047) SH 1
/// </summary>
  K_CMDCMTMultiCoilElementName = $00189047;

/// <summary>
/// Multi-Coil Element Used (0018;9048) CS 1
/// </summary>
  K_CMDCMTMultiCoilElementUsed = $00189048;

/// <summary>
/// MR Transmit Coil Sequence (0018;9049) SQ 1
/// </summary>
  K_CMDCMTMRTransmitCoilSequence = $00189049;

/// <summary>
/// Transmit Coil Manufacturer Name (0018;9050) LO 1
/// </summary>
  K_CMDCMTTransmitCoilManufacturerName = $00189050;

/// <summary>
/// Transmit Coil Type (0018;9051) CS 1
/// </summary>
  K_CMDCMTTransmitCoilType = $00189051;

/// <summary>
/// Spectral Width (0018;9052) FD 1-2
/// </summary>
  K_CMDCMTSpectralWidth = $00189052;

/// <summary>
/// Chemical Shift Reference (0018;9053) FD 1-2
/// </summary>
  K_CMDCMTChemicalShiftReference = $00189053;

/// <summary>
/// Volume Localization Technique (0018;9054) CS 1
/// </summary>
  K_CMDCMTVolumeLocalizationTechnique = $00189054;

/// <summary>
/// MR Acquisition Frequency Encoding Steps (0018;9058) US 1
/// </summary>
  K_CMDCMTMRAcquisitionFrequencyEncodingSteps = $00189058;

/// <summary>
/// De-coupling (0018;9059) CS 1
/// </summary>
  K_CMDCMTDecoupling = $00189059;

/// <summary>
/// De-coupling Nucleus (0018;9060) CS 1-2
/// </summary>
  K_CMDCMTDecouplingNulceus = $00189060;

/// <summary>
/// De-coupling Frequency (0018;9061) FD 1-2
/// </summary>
  K_CMDCMTDecouplingFrequency = $00189061;

/// <summary>
/// De-coupling Method (0018;9062) CS 1
/// </summary>
  K_CMDCMTDecouplingMethod = $00189062;

/// <summary>
/// De-coupling Chemical Shift Reference (0018;9063) FD 1-2
/// </summary>
  K_CMDCMTDecouplingChemicalShiftReference = $00189063;

/// <summary>
/// k-space Filtering (0018;9064) CS 1
/// </summary>
  K_CMDCMTKSpaceFiltering = $00189064;

/// <summary>
/// Time Domain Filtering (0018;9065) CS 1-2
/// </summary>
  K_CMDCMTTimeDomainFiltering = $00189065;

/// <summary>
/// Number of Zero fills (0018;9066) US 1-2
/// </summary>
  K_CMDCMTNumberOfZeroFills = $00189066;

/// <summary>
/// Baseline Correction (0018;9067) CS 1
/// </summary>
  K_CMDCMTBaselineCorrection = $00189067;

/// <summary>
/// Parallel Reduction Factor In-plane (0018;9069) FD 1
/// </summary>
  K_CMDCMTParallelReductionFactorInPlane = $00189069;

/// <summary>
/// Cardiac R-R Interval Specified (0018;9070) FD 1
/// </summary>
  K_CMDCMTCardiacRRIntervalSpecified = $00189070;

/// <summary>
/// Acquisition Duration (0018;9073) FD 1
/// </summary>
  K_CMDCMTAcquisitionDuration = $00189073;

/// <summary>
/// Frame Acquisition Datetime (0018;9074) DT 1
/// </summary>
  K_CMDCMTFrameAcquisitionDateTime = $00189074;

/// <summary>
/// Diffusion Directionality (0018;9075) CS 1
/// </summary>
  K_CMDCMTDiffusionDirectionality = $00189075;

/// <summary>
/// Diffusion Gradient Direction Sequence (0018;9076) SQ 1
/// </summary>
  K_CMDCMTDiffusionGradientDirectionSequence = $00189076;

/// <summary>
/// Parallel Acquisition (0018;9077) CS 1
/// </summary>
  K_CMDCMTParallelAcquisition = $00189077;

/// <summary>
/// Parallel Acquisition Technique (0018;9078) CS 1
/// </summary>
  K_CMDCMTParallelAcquisitionTechnique = $00189078;

/// <summary>
/// Inversion Times (0018;9079) FD 1-n
/// </summary>
  K_CMDCMTInversionTimes = $00189079;

/// <summary>
/// Metabolite Map Description (0018;9080) ST 1
/// </summary>
  K_CMDCMTMetaboliteMapDescription = $00189080;

/// <summary>
/// Partial Fourier (0018;9081) CS 1
/// </summary>
  K_CMDCMTPartialFourier = $00189081;

/// <summary>
/// Effective Echo Time (0018;9082) FD 1
/// </summary>
  K_CMDCMTEffectiveEchoTime = $00189082;

/// <summary>
/// Metabolite Map Code Sequence (0018;9083) SQ 1
/// </summary>
  K_CMDCMTMetaboliteMapCodeSequence = $00189083;

/// <summary>
/// Chemical Shift Sequence (0018;9084) SQ 1
/// </summary>
  K_CMDCMTChemicalShiftSequence = $00189084;

/// <summary>
/// Cardiac Signal Source (0018;9085) CS 1
/// </summary>
  K_CMDCMTCardiacSignalSource = $00189085;

/// <summary>
/// Diffusion b-value (0018;9087) FD 1
/// </summary>
  K_CMDCMTDiffusionBValue = $00189087;

/// <summary>
/// Diffusion Gradient Orientation (0018;9089) FD 3
/// </summary>
  K_CMDCMTDiffusionGradientOrientation = $00189089;

/// <summary>
/// Velocity Encoding Direction (0018;9090) FD 3
/// </summary>
  K_CMDCMTVelocityEncodingDirection = $00189090;

/// <summary>
/// Velocity Encoding Minimum Value (0018;9091) FD 1
/// </summary>
  K_CMDCMTVelocityEncodingMinimumValue = $00189091;

/// <summary>
/// Number of k-Space trajectories (0018;9093) US 1
/// </summary>
  K_CMDCMTNumberOfKSpaceTrajectories = $00189093;

/// <summary>
/// Coverage of k-Space (0018;9094) CS 1
/// </summary>
  K_CMDCMTCoverageOfKSpace = $00189094;

/// <summary>
/// Spectroscopy Acquisition Phase Rows (0018;9095) UL 1
/// </summary>
  K_CMDCMTSpectroscopyAcquisitionPhaseRows = $00189095;

/// <summary>
/// Transmitter Frequency (0018;9098) FD 1-2
/// </summary>
  K_CMDCMTTransmitterFrequency = $00189098;

/// <summary>
/// Resonant Nucleus (0018;9100) CS 1-2
/// </summary>
  K_CMDCMTResonantNucleus = $00189100;

/// <summary>
/// Frequency Correction (0018;9101) CS 1
/// </summary>
  K_CMDCMTFrequencyCorrection = $00189101;

/// <summary>
/// MR Spectroscopy FOV/Geometry Sequence (0018;9101) SQ 1
/// </summary>
  K_CMDCMTMRSspectroscopyFovGeometrySequence = $00189103;

/// <summary>
/// Slab Thickness (0018;9103) FD 1
/// </summary>
  K_CMDCMTSlabThickness = $00189104;

/// <summary>
/// Slab Orientation (0018;9104) FD 3
/// </summary>
  K_CMDCMTSlabOrientation = $00189105;

/// <summary>
/// Mid Slab Position (0018;9106) FD 3
/// </summary>
  K_CMDCMTMidSlabPosition = $00189106;

/// <summary>
/// MR Spatial Saturation Sequence (0018;9107) SQ 1
/// </summary>
  K_CMDCMTMRSpatialSaturationSequence = $00189107;

/// <summary>
/// MR Timing and Related Parameters Sequence (0018;9112) SQ 1
/// </summary>
  K_CMDCMTMRTimingAndRelatedParametersSequence = $00189112;

/// <summary>
/// MR Echo Sequence (0018;9114) SQ 1
/// </summary>
  K_CMDCMTMREchoSequence = $00189114;

/// <summary>
/// MR Modifier Sequence (0018;9115) SQ 1
/// </summary>
  K_CMDCMTMRModifierSequence = $00189115;

/// <summary>
/// MR Diffusion Sequence (0018;9117) SQ 1
/// </summary>
  K_CMDCMTMRDiffusionSequence = $00189117;

/// <summary>
/// Cardiac Trigger Sequence (0018;9118) SQ 1
/// </summary>
  K_CMDCMTCardiacTriggerSequence = $00189118;

/// <summary>
/// MR Averages Sqeuence (0018;9119) SQ 1
/// </summary>
  K_CMDCMTMRAveragesSequence = $00189119;

/// <summary>
/// MR FOV/Geometry Sequence (0018;9125) SQ 1
/// </summary>
  K_CMDCMTMRFovGeometrySequence = $00189125;

/// <summary>
/// Volume Localization Sequence (0018;9126) SQ 1
/// </summary>
  K_CMDCMTVolumeLocalizationSequence = $00189126;

/// <summary>
/// Spectroscopy Acquisition Data Columns (0018;9127) UL 1
/// </summary>
  K_CMDCMTSpectroscopyAcquisitionDataColumns = $00189127;

/// <summary>
/// Diffusion Anisotropy Type (0018;9147) CS 1
/// </summary>
  K_CMDCMTDiffusionAnisotropyType = $00189147;

/// <summary>
/// Frame Reference Datetime (0018;9151) DT 1
/// </summary>
  K_CMDCMTFrameReferenceDateTime = $00189151;

/// <summary>
/// MR Metabolite Map Sequence (0018;9152) SQ 1
/// </summary>
  K_CMDCMTMRMetaboliteMapSequence = $00189152;

/// <summary>
/// Parallel Reduction Factor out-of-plane (0018;9155) FD 1
/// </summary>
  K_CMDCMTParallelReductionFactorOutOfPlane = $00189155;

/// <summary>
/// Spectroscopy Acquisition Out-of-plane Phase Steps (0018;9159) UL 1
/// </summary>
  K_CMDCMTSpectroscopyAcquisitionOutOfPlanePhaseSteps = $00189159;

/// <summary>
/// Bulk Motion Status (0018;9166) CS 1
/// </summary>
  K_CMDCMTBulkMotionStatus = $00189166;

/// <summary>
/// Parallel Reduction Factor Second In-plane (0018;9168) FD 1
/// </summary>
  K_CMDCMTParallelReductionFactorSecondInPlane = $00189168;

/// <summary>
/// Cardiac Beat rejection Technique (0018;9169) CS 1
/// </summary>
  K_CMDCMTCardiacBeatRejectionTechnique = $00189169;

/// <summary>
/// Respiratory Motion Compensation Technique (0018;9170) CS 1
/// </summary>
  K_CMDCMTRespiratoryMotionCompensationTechnique = $00189170;

/// <summary>
/// Respiratory Signal Source (0018;9171) CS 1
/// </summary>
  K_CMDCMTRespiratorySignalSource = $00189171;

/// <summary>
/// Bulk Motion Compensation Technique (0018;9172) CS 1
/// </summary>
  K_CMDCMTBulkMotionCompensationTechnique = $00189172;

/// <summary>
/// Bulk Motion Signal Source (0018;9173) CS 1
/// </summary>
  K_CMDCMTBulkMotionSignalSource = $00189173;

/// <summary>
/// Applicable Safety Standard Agency (0018;9174) CS 1
/// </summary>
  K_CMDCMTApplicableSafetyStandardAgency = $00189174;

/// <summary>
/// Applicable Safety Standard Description (0018;9175) LO 1
/// </summary>
  K_CMDCMTApplicableSafetyStandardDescription = $00189175;

/// <summary>
/// Operating Mode Sequence (0018;9176) SQ 1
/// </summary>
  K_CMDCMTOperatingModeSequence = $00189176;

/// <summary>
/// Operating Mode Type (0018;9177) CS 1
/// </summary>
  K_CMDCMTOperatingModeType = $00189177;

/// <summary>
/// Operating Mode (0018;9178) CS 1
/// </summary>
  K_CMDCMTOperatingMode = $00189178;

/// <summary>
/// Specific Absorption Rate Definition (0018;9179) CS 1
/// </summary>
  K_CMDCMTSpecificAbsorptionRateDefinition = $00189179;

/// <summary>
/// Gradient Output Type (0018;9180) CS 1
/// </summary>
  K_CMDCMTGradientOutputType = $00189180;

/// <summary>
/// Specific Absorption Rate Value (0018;9181) FD 1
/// </summary>
  K_CMDCMTSpecificAbsorptionRateValue = $00189181;

/// <summary>
/// Gradient Output (0018;9182) FD 1
/// </summary>
  K_CMDCMTGradientOutput = $00189182;

/// <summary>
/// Flow Compensation Direction (0018;9183) CS 1
/// </summary>
  K_CMDCMTFlowCompensationDirection = $00189183;

/// <summary>
/// Tagging Delay (0018;9184) FD 1
/// </summary>
  K_CMDCMTTaggingDelay = $00189184;

/// <summary>
/// Chemical Shifts Minimum Integration Limit in Hz  K_CMDCMT(Retired) (0018;9195) FD 1
/// </summary>
  K_CMDCMTChemicalShiftsMinimumIntegrationLimitInHz = $00189195;

/// <summary>
/// Chemical Shifts Maximum Integration Limit in Hz (0018;9196) FD 1
/// </summary>
  K_CMDCMTChemicalShiftsMaximumIntegrationLimitInHz = $00189196;

/// <summary>
/// MR Velocity Encoding Sequence (0018;9197) SQ 1
/// </summary>
  K_CMDCMTMRVelocityEncodingSequence = $00189197;

/// <summary>
/// First Order Phase Correction (0018;9198) UN  K_CMDCMT\\See Adobe 03-03 page 572  K_CMDCMT"type is 1C"
/// </summary>
  K_CMDCMTFirstOrderPhaseCorrection = $00189198;

/// <summary>
/// Water Referenced Phase Correction (0018;9199) CS 1
/// </summary>
  K_CMDCMTWaterReferencedPhaseCorrection = $00189199;

/// <summary>
/// MR Spectroscopy Acquisition Type (0018;9200) CS 1
/// </summary>
  K_CMDCMTMRSpectroscopyAcquisitionType = $00189200;

/// <summary>
/// Respiratory Cycle Position (0018;9214) CS 1
/// </summary>
  K_CMDCMTRespiratoryCyclePosition = $00189214;

/// <summary>
/// Velocity Encoding Maximum Value (0018;9217) FD 1
/// </summary>
  K_CMDCMTVelocityEncodingMaximumValue = $00189217;

/// <summary>
/// Tag Spacing Second Dimension (0018;9218) SS 1
/// </summary>
  K_CMDCMTTagSpacingSecondDimension = $00189218;

/// <summary>
/// Tag Angle Second Axis (0018;9219) SS 1
/// </summary>
  K_CMDCMTTagAngleSecondAxis = $00189219;

/// <summary>
/// Frame Acquisition Duration (0018;9220) FD 1
/// </summary>
  K_CMDCMTFrameAcquisitionDuration = $00189220;

/// <summary>
/// MR Image Frame Type Sequence (0018;9226) SQ 1
/// </summary>
  K_CMDCMTMRImageFrameTypeSequence = $00189226;

/// <summary>
/// MR Spectroscopy Frame Type Sequence (0018;9227) SQ 1
/// </summary>
  K_CMDCMTMRSpectroscopyFrameTypeSequence = $00189227;

/// <summary>
/// R Acquisition Phase Encoding Steps in-plane (0018;9231) US 1
/// </summary>
  K_CMDCMTMRAcquisitionPhaseEncodingStepsInPlane = $00189231;

/// <summary>
/// MR Acquisition Phase Encoding Steps out-of-plane (0018;9232) US 1
/// </summary>
  K_CMDCMTMRAcquisitionPhaseEncodingStepsOutOfPlane = $00189232;

/// <summary>
/// Spectroscopy Acquisition Phase Columns (0018;9234) UL 1
/// </summary>
  K_CMDCMTSpectroscopyAcquisitionPhaseColumns = $00189234;

/// <summary>
/// Cardiac Cycle Position (0018;9236) CS 1
/// </summary>
  K_CMDCMTCardiacCyclePosition = $00189236;

/// <summary>
/// Specific Absorption Rate Sequence (0018;9239) SQ 1
/// </summary>
  K_CMDCMTSpecificAbsorptionRateSequence = $00189239;

/// <summary>
/// RF Echo Train Length (0018;9240) IS 1
/// </summary>
  K_CMDCMTRFEchoTrainLength = $00189240;

/// <summary>
/// Gradient Echo Train Length (0018;9241) IS 1
/// </summary>
  K_CMDCMTGradientEchoTrainLength = $00189241;

/// <summary>
/// Chemical Shifts Minimum Integration Limit in ppm (0018;9295) FD 1
/// </summary>
  K_CMDCMTChemicalShiftsMinimumIntegrationLimitInPpm = $00189295;

/// <summary>
/// Chemical Shifts Maximum Integration Limit in ppm (0018;9295) FD 1
/// </summary>
  K_CMDCMTChemicalShiftsMaximumIntegrationLimitInPpm = $00189296;

/// <summary>
/// CT Acquisition Type Sequence (0018;9301) SQ 1
/// </summary>
  K_CMDCMTCTAcquisitionTypeSequence = $00189301;

/// <summary>
/// Acquisition Type (0018;9302) CS 1
/// </summary>
  K_CMDCMTAcquisitionType = $00189302;

/// <summary>
/// Tube Angle (0018;9303) FD 1
/// </summary>
  K_CMDCMTTubeAngle = $00189303;

/// <summary>
/// CT Acquisition Details Sequence (0018;9304) SQ 1
/// </summary>
  K_CMDCMTCTAcquisitionDetailsSequence = $00189304;

/// <summary>
/// Revolution Time (0018;9305) FD 1
/// </summary>
  K_CMDCMTRevolutionTime = $00189305;

/// <summary>
/// Single Collimation Width (0018;9306) FD 1
/// </summary>
  K_CMDCMTSingleCollimationWidth = $00189306;

/// <summary>
/// Total Collimation Width (0018;9307) FD 1
/// </summary>
  K_CMDCMTTotalCollimationWidth = $00189307;

/// <summary>
/// CT Table Dynamics Sequence (0018;9308) SQ 1
/// </summary>
  K_CMDCMTCTTableDynamicsSequence = $00189308;

/// <summary>
/// Table Speed (0018;9309) FD 1
/// </summary>
  K_CMDCMTTableSpeed = $00189309;

/// <summary>
/// Table Feed per Rotation (0018;9310) FD 1
/// </summary>
  K_CMDCMTTableFeedPerRotation = $00189310;

/// <summary>
/// Spiral Pitch Factor (0018;9311) FD 1
/// </summary>
  K_CMDCMTSpiralPitchFactor = $00189311;

/// <summary>
/// CT Geometry Sequence (0018;9312) SQ 1
/// </summary>
  K_CMDCMTCTGeometrySequence = $00189312;

/// <summary>
/// Data Collection Center (Patient) (0018;9313) FD 3
/// </summary>
  K_CMDCMTDataCollectionCenterPatient = $00189313;

/// <summary>
/// CT Reconstruction Sequence (0018;9314) SQ 1
/// </summary>
  K_CMDCMTCTReconstructionSequence = $00189314;

/// <summary>
/// Reconstruction Algorithm (0018;9315) CS 1
/// </summary>
  K_CMDCMTReconstructionAlgorithm = $00189315;

/// <summary>
/// Convolution Kernel Group (0018;9316) CS 1
/// </summary>
  K_CMDCMTConvolutionKernelGroup = $00189316;

/// <summary>
/// Reconstruction Field of View (0018;9317) FD 2
/// </summary>
  K_CMDCMTReconstructionFieldOfView = $00189317;

/// <summary>
/// Reconstruction Target Center (Patient) (0018;9318) FD 3
/// </summary>
  K_CMDCMTReconstructionTargetCenterPatient = $00189318;

/// <summary>
/// Reconstruction Angle (0018;9319) FD 1
/// </summary>
  K_CMDCMTReconstructionAngle = $00189319;

/// <summary>
/// Image Filter (0018;9320) SH 1
/// </summary>
  K_CMDCMTImageFilter = $00189320;

/// <summary>
/// CT Exposure Sequence (0018;9321) SQ 1
/// </summary>
  K_CMDCMTCTExposureSequence = $00189321;

/// <summary>
/// Reconstruction Pixel Spacing (0018;9322) FD 2
/// </summary>
  K_CMDCMTReconstructionPixelSpacing = $00189322;

/// <summary>
/// Exposure Modulation Type (0018;9323) CS 1
/// </summary>
  K_CMDCMTExposureModulationType = $00189323;

/// <summary>
/// Estimated Dose Saving (0018;9324) FD 1
/// </summary>
  K_CMDCMTEstimatedDoseSaving = $00189324;

/// <summary>
/// CT X-ray Details Sequence (0018;9325) SQ 1
/// </summary>
  K_CMDCMTCTXrayDetailsSequence = $00189325;

/// <summary>
/// CT Position Sequence (0018;9326) SQ 1
/// </summary>
  K_CMDCMTCTPositionSequence = $00189326;

/// <summary>
/// Table Position (0018;9327) FD 1
/// </summary>
  K_CMDCMTTablePosition = $00189327;

/// <summary>
/// Exposure Time in ms (0018;9328) FD 1
/// </summary>
  K_CMDCMTExposureTimeInMS = $00189328;

/// <summary>
/// CT Image Frame Type Sequence (0018;9329) SQ 1
/// </summary>
  K_CMDCMTCTImageFrameTypeSequence = $00189329;

/// <summary>
/// X-Ray Tube Current in mA (0018;9330) FD 1
/// </summary>
  K_CMDCMTXRayTubeCurrentInMA = $00189330;

/// <summary>
/// Exposure in mAs (0018;9332) FD 1
/// </summary>
  K_CMDCMTExposureInMas = $00189332;

/// <summary>
/// Constant Volume Flag (0018;9333) CS 1
/// </summary>
  K_CMDCMTConstantVolumeFlag = $00189333;

/// <summary>
/// Fluoroscopy Flag (0018;9334) CS 1
/// </summary>
  K_CMDCMTFluoroscopyFlag = $00189334;

/// <summary>
/// Distance Source to Data Collection Center (0018;9335) FD 1
/// </summary>
  K_CMDCMTDistanceSourceToDataCollectionCenter = $00189335;

/// <summary>
/// Contrast/Bolus Agent Number (0018;9337) US 1
/// </summary>
  K_CMDCMTContrastBolusAgentNumber = $00189337;

/// <summary>
/// Contrast/Bolus Ingredient Code Sequence (0018;9338) SQ 1
/// </summary>
  K_CMDCMTContrastBolusIngredientCodeSequence = $00189338;

/// <summary>
/// Contrast Administration Profile Sequence (0018;9340) SQ 1
/// </summary>
  K_CMDCMTContrastAdministrationProfileSequence = $00189340;

/// <summary>
/// Contrast/Bolus Usage Sequence (0018;9341) SQ 1
/// </summary>
  K_CMDCMTContrastBolusUsageSequence = $00189341;

/// <summary>
/// Contrast/Bolus Agent Administered (0018;9342) CS 1
/// </summary>
  K_CMDCMTContrastBolusAgentAdministered = $00189342;

/// <summary>
/// Contrast/Bolus Agent Detected (0018;9343) CS 1
/// </summary>
  K_CMDCMTContrastBolusAgentDetected = $00189343;

/// <summary>
/// Contrast/Bolus Agent Phase (0018;9344) CS 1
/// </summary>
  K_CMDCMTContrastBolusAgentPhase = $00189344;

/// <summary>
/// CTDIvol (0018;9345) FD 1
/// </summary>
  K_CMDCMTCtdiVol = $00189345;

/// <summary>
/// Projection Pixel Calibration Sequence (0018;9401) CS 1
/// </summary>
  K_CMDCMTProjectionPixelCalibrationSequence = $00189401;

/// <summary>
/// Distance Source to Isocenter   (0018;9402) FL 1
/// </summary>
  K_CMDCMTDistanceSourceToIsocenter = $00189402;

/// <summary>
/// Distance Object to Table Top   (0018;9403) FL 1
/// </summary>
  K_CMDCMTDistanceObjectToTableTop = $00189403;

/// <summary>
/// Object Pixel Spacing in Center of Beam   (0018;9404) FL 2
/// </summary>
  K_CMDCMTObjectPixelSpacingInCenterOfBeam = $00189404;

/// <summary>
/// Positioner Position Sequence   (0018;9405) SQ 1
/// </summary>
  K_CMDCMTPositionerPositionSequence = $00189405;

/// <summary>
/// Table Position Sequence   (0018;9406) SQ 1
/// </summary>
  K_CMDCMTTablePositionSequence = $00189406;

/// <summary>
/// Collimator Shape Sequence   (0018;9407) SQ 1
/// </summary>
  K_CMDCMTCollimatorShapeSequence = $00189407;

/// <summary>
/// XA/XRF Frame Characteristics Sequence   (0018;9412) SQ 1
/// </summary>
  K_CMDCMTXAXRFFrameCharacteristicsSequence = $00189412;

/// <summary>
/// Frame Acquisition Sequence    K_CMDCMT(0018;9417) SQ 1
/// </summary>
  K_CMDCMTFrameAcquisitionSequence = $00189417;

/// <summary>
/// X-Ray Receptor Type    K_CMDCMT(0018;9420) CS 1
/// </summary>
  K_CMDCMTXRayReceptorType = $00189420;

/// <summary>
/// Acquisition Protocol Name    K_CMDCMT(0018;9423) LO 1
/// </summary>
  K_CMDCMTAcquisitionProtocolName = $00189423;

/// <summary>
/// Acquisition Protocol Description    K_CMDCMT(0018;9424) LT 1
/// </summary>
  K_CMDCMTAcquisitionProtocolDescription = $00189424;

/// <summary>
/// Contrast/Bolus Ingredient Opaque   (0018;9425) CS 1
/// </summary>
  K_CMDCMTContrastBolusIngredientOpaque = $00189425;

/// <summary>
/// Distance Receptor Plane to Detector Housing  (0018;9426) FL 1
/// </summary>
  K_CMDCMTDistanceReceptorPlaneToDetectorHousing = $00189426;

/// <summary>
///  K_CMDCMTIntensifier Active Shape  (0018;9427) CS 1
/// </summary>
  K_CMDCMTIntensifierActiveShape = $00189427;

/// <summary>
///  K_CMDCMT Intensifier Active Dimension(s)  (0018;9428) FL 1-2
/// </summary>
  K_CMDCMTIntensifierActiveDimensions = $00189428;

/// <summary>
///  K_CMDCMT Physical Detector Size  K_CMDCMT (0018;9429) FL 2
/// </summary>
  K_CMDCMTPhysicalDetectorSize = $00189429;

/// <summary>
///  K_CMDCMT Position of Isocenter Projection  K_CMDCMT (0018;9430) US 2
/// </summary>
  K_CMDCMTPositionOfIsocenterProjection = $00189430;

/// <summary>
///  K_CMDCMT Field of View Sequence      K_CMDCMT(0018;9432) SQ 1
/// </summary>
  K_CMDCMTFieldOfViewSequence = $00189432;

/// <summary>
///  K_CMDCMT Field of View Description      K_CMDCMT(0018;9433) LO 1
/// </summary>
  K_CMDCMTFieldOfViewDescription = $00189433;

/// <summary>
/// Exposure Control Sensing Regions Sequence  (0018;9434) SQ 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionsSequence = $00189434;

/// <summary>
/// Exposure Control Sensing Region Shape  (0018;9435) CS 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionShape = $00189435;

/// <summary>
/// Exposure Control Sensing Region Left Vertical Edge  (0018;9436) SS 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionLeftVerticalEdge = $00189436;

/// <summary>
/// Exposure Control Sensing Region Right Vertical Edge  (0018;9437) SS 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionRightVerticalEdge = $00189437;

/// <summary>
/// Exposure Control Sensing Region Upper Horizontal Edge  K_CMDCMT (0018;9438) SS 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionUpperHorizontalEdge = $00189438;

/// <summary>
/// Exposure Control Sensing Region Lower Horizontal Edge  K_CMDCMT (0018;9439) SS 1
/// </summary>
  K_CMDCMTExposureControlSensingRegionLowerHorizontalEdge = $00189439;

/// <summary>
/// Center of Circular Exposure Control Sensing Region  K_CMDCMT (0018;9440) SS 2
/// </summary>
  K_CMDCMTCenterOfCircularExposureControlSensingRegion = $00189440;

/// <summary>
/// Radius of Circular Exposure Control Sensing Region  K_CMDCMT (0018;9441) US 1
/// </summary>
  K_CMDCMTRadiusOfCircularExposureControlSensingRegion = $00189441;

/// <summary>
/// Vertices of the Polygonal Exposure Control Sensing Region  K_CMDCMT (0018;9442) SS 2
/// </summary>
  K_CMDCMTVerticesOfThePolygonalExposureControlSensingRegion = $00189442;

/// <summary>
/// RETIRED  K_CMDCMT (0018;9445) 
/// </summary>
  K_CMDCMTRETIRED = $00189445;

/// <summary>
/// Column Angulation (Patient)      (0018;9447) FL 1
/// </summary>
  K_CMDCMTColumnAngulation_Patient = $00189447;

/// <summary>
///  K_CMDCMTBeam Angle           (0018;9449) FL 1
/// </summary>
  K_CMDCMTBeamAngle = $00189449;

/// <summary>
///  K_CMDCMTFrame Detector Parameters Sequence      (0018;9451) SQ 1
/// </summary>
  K_CMDCMTFrameDetectorParametersSequence = $00189451;

/// <summary>
///  K_CMDCMTCalculated Anatomy Thickness      (0018;9452) FL 1
/// </summary>
  K_CMDCMTCalculatedAnatomyThickness = $00189452;

/// <summary>
///  K_CMDCMTCalibration Sequence          K_CMDCMT (0018;9455) SQ 1
/// </summary>
  K_CMDCMTCalibrationSequence = $00189455;

/// <summary>
///  K_CMDCMTObject Thickness Sequence          K_CMDCMT (0018;9456) SQ 1
/// </summary>
  K_CMDCMTObjectThicknessSequence = $00189456;

/// <summary>
///  K_CMDCMTPlane Identification          K_CMDCMT (0018;9457) CS 1
/// </summary>
  K_CMDCMTPlaneIdentification = $00189457;

/// <summary>
///  K_CMDCMT Field of View Dimension(s) in Float   (0018;9461) FL 1-2
/// </summary>
  K_CMDCMTFieldOfViewDimensionsInFloat = $00189461;

/// <summary>
/// Isocenter Reference System Sequence   (0018;9462) SQ 1
/// </summary>
  K_CMDCMTIsocenterReferenceSystemSequence = $00189462;

/// <summary>
/// Positioner Isocenter Primary Angle   (0018;9463) FL 1
/// </summary>
  K_CMDCMTPositionerIsocenterPrimaryAngle = $00189463;

/// <summary>
/// Positioner Isocenter Primary Secondary Angle   (0018;9464) FL 1
/// </summary>
  K_CMDCMTPositionerIsocenterPrimarySecondaryAngle = $00189464;

/// <summary>
/// Positioner Isocenter Detector Rotation Angle   (0018;9465) FL 1
/// </summary>
  K_CMDCMTPositionerIsocenterDetectorRotationAngle = $00189465;

/// <summary>
/// Table X Position to Isocenter      (0018;9466) FL 1
/// </summary>
  K_CMDCMTTableXPositionToIsocenter = $00189466;

/// <summary>
/// Table Y Position to Isocenter      (0018;9467) FL 1
/// </summary>
  K_CMDCMTTableYPositionToIsocenter = $00189467;

/// <summary>
/// Table Z Position to Isocenter      (0018;9468) FL 1
/// </summary>
  K_CMDCMTTableZPositionToIsocenter = $00189468;

/// <summary>
/// Table Horizontal Rotation Angle      (0018;9469) FL 1
/// </summary>
  K_CMDCMTTableHorizontalRotationAngle = $00189469;

/// <summary>
/// Table Head Tilt Angle          K_CMDCMT (0018;9470) FL 1
/// </summary>
  K_CMDCMTTableHeadTiltAngle = $00189470;

/// <summary>
/// Table Cradle Tilt Angle          K_CMDCMT (0018;9471) FL 1
/// </summary>
  K_CMDCMTTableCradleTiltAngle = $00189471;

/// <summary>
/// Frame Display Shutter Sequence          K_CMDCMT (0018;9472) SQ 1
/// </summary>
  K_CMDCMTFrameDisplayShutterSequence = $00189472;

/// <summary>
/// Acquired Image Area Dose Product          K_CMDCMT (0018;9473) FL 1
/// </summary>
  K_CMDCMTAcquiredImageAreaDoseProduct = $00189473;

/// <summary>
/// C-arm Positioner Tabletop Relationship      (0018;9474) CS 1
/// </summary>
  K_CMDCMTC_armPositionerTabletopRelationship = $00189474;

/// <summary>
/// X-Ray Geometry Sequence          K_CMDCMT (0018;9476) SQ 1
/// </summary>
  K_CMDCMTXRayGeometrySequence = $00189476;

/// <summary>
/// Irradiation Event Identification Sequence    (0018;9477) SQ 1
/// </summary>
  K_CMDCMTIrradiationEventIdentificationSequence = $00189477;

/// <summary>
/// Contributing Equipment Sequence (0018;A001) 
/// </summary>
  K_CMDCMTContributingEquipmentSequence = $0018A001;

/// <summary>
/// Contribution Date Time (0018;A002)
/// </summary>
  K_CMDCMTContributionDateTime = $0018A002;

/// <summary>
/// Contribution Description (0018;A003) ST 1
/// </summary>
  K_CMDCMTContributionDescription = $0018A003;

    
// GROUP 20
/// <summary>
// GROUP 20 Group Length (0020;0000)
/// </summary>
  K_CMDCMTGroup20GroupLength = $00200000;

/// <summary>
/// Study Instance UID (0020;000D) UI 1
/// </summary>
  K_CMDCMTStudyInstanceUid = $0020000D;

/// <summary>
/// Series Instance UID (0020;000E) UI 1
/// </summary>
  K_CMDCMTSeriesInstanceUid = $0020000E;

/// <summary>
/// Study ID (0020;0010) SH 1
/// </summary>
  K_CMDCMTStudyId = $00200010;

/// <summary>
/// Series Number (0020;0011) IS 1
/// </summary>
  K_CMDCMTSeriesNumber = $00200011;

/// <summary>
/// Acquisition Number (0020;0012) IS 1
/// </summary>
  K_CMDCMTAcquisitionNumber = $00200012;

/// <summary>
/// Instance Number (0020;0013) IS 1
/// </summary>
  K_CMDCMTInstanceNumber = $00200013;

/// <summary>
/// Isotope Number (Retired) (0020;0014) IS 1
/// </summary>
  K_CMDCMTIsotopeNumberRetired = $00200014;

/// <summary>
/// Phase Number (Retired) (0020;0015) IS 1
/// </summary>
  K_CMDCMTPhaseNumberRetired = $00200015;

/// <summary>
/// Interval Number (Retired) (0020;0016) IS 1
/// </summary>
  K_CMDCMTIntervalNumberRetired = $00200016;

/// <summary>
/// Time slot Number (Retired) (0020;0017) IS 1
/// </summary>
  K_CMDCMTTimeSlotNumberRetired = $00200017;

/// <summary>
/// Angle Number (Retired) (0020;0018) IS 1
/// </summary>
  K_CMDCMTAngleNumberRetired = $00200018;

/// <summary>
/// Item Number (0020;0019) IS 1
/// </summary>
  K_CMDCMTItemNumber = $00200019;

/// <summary>
/// Patient Orientation (0020;0020) CS 2
/// </summary>
  K_CMDCMTPatientOrientation = $00200020;

/// <summary>
/// Overlay Number (Retired)   (0020;0022) IS 1
/// </summary>
  K_CMDCMTOverlayNumberRetired = $00200022;

/// <summary>
/// Curve Number (Retired)  K_CMDCMT (0020;0024) IS 1
/// </summary>
  K_CMDCMTCurveNumberRetired = $00200024;

/// <summary>
/// Lookup Table Number (Retired) (0020;0026) IS 1
/// </summary>
  K_CMDCMTLookupTableNumberRetired = $00200026;

/// <summary>
/// Image Position (Retired) (0020;0030) DS 3
/// </summary>
  K_CMDCMTImagePositionRetired = $00200030;

/// <summary>
/// Image Position (Patient) (0020;0032) DS 3
/// </summary>
  K_CMDCMTImagePositionPatient = $00200032;

/// <summary>
/// Image Orientation (Retired) (0020;0035) DS 6
/// </summary>
  K_CMDCMTImageOrientation = $00200035;

/// <summary>
/// Image Orientation (Patient) (0020;0037) DS 6
/// </summary>
  K_CMDCMTImageOrientationPatient = $00200037;

/// <summary>
/// Location (Retired) (0020;0050) DS 1
/// </summary>
  K_CMDCMTLocationRetired = $00200050;

/// <summary>
/// Frame of Reference UID (0020;0052) UI 1
/// </summary>
  K_CMDCMTFrameOfReferenceUid = $00200052;

/// <summary>
/// Laterality (0020;0060) CS 1
/// </summary>
  K_CMDCMTLaterality = $00200060;

/// <summary>
/// Image Laterality (0020;0062) CS 1
/// </summary>
  K_CMDCMTImageLaterality = $00200062;

/// <summary>
/// Image Geometry Type (Retired) (0020;0070) LO 1
/// </summary>
  K_CMDCMTImageGeometryTypeRetired = $00200070;

/// <summary>
/// Masking Image (Retired) (0020;0080) CS 1-n
/// </summary>
  K_CMDCMTMaskingImageRetired = $00200080;

/// <summary>
/// Temporal Position Identifier    K_CMDCMT(0020;0100) IS 1
/// </summary>
  K_CMDCMTTemporalPositionIdentifier = $00200100;

/// <summary>
/// Number of Temporal Positions (0020;0105) IS 1
/// </summary>
  K_CMDCMTNumberOfTemporalPositions = $00200105;

/// <summary>
/// Temporal Resolution (0020;0110) DS 1
/// </summary>
  K_CMDCMTTemporalResolution = $00200110;

/// <summary>
/// Synchronization Frame of Reference UID (0020;0200) UI 1
/// </summary>
  K_CMDCMTSynchronizationFrameOfReferenceUid = $00200200;

/// <summary>
/// Series in Study (Retired)  K_CMDCMT (0020;1000) IS 1
/// </summary>
  K_CMDCMTSeriesInStudyRetired = $00201000;

/// <summary>
/// Acquisition in Series (Retired) (0020;1001) IS 1
/// </summary>
  K_CMDCMTAcquisitionsInSeriesRetired = $00201001;

/// <summary>
/// Images in Acquisition (0020;1002) IS 1
/// </summary>
  K_CMDCMTImagesInAcquisition = $00201002;

/// <summary>
/// Acquisitions in Study (Retired)  K_CMDCMT(0020;1004) IS 1
/// </summary>
  K_CMDCMTAcquisitionsInStudyRetired = $00201004;

/// <summary>
/// Reference (Retired) (0020;1020) CS 1-n
/// </summary>
  K_CMDCMTReferenceRetired = $00201020;

/// <summary>
/// Position Reference Indicator (0020;1040) LO 1
/// </summary>
  K_CMDCMTPositionReferenceIndicator = $00201040;

/// <summary>
/// Slice Location (0020;1041) DS 1
/// </summary>
  K_CMDCMTSliceLocation = $00201041;

/// <summary>
/// Other Study Numbers (Retired)  (0020;1070) IS 1-n
/// </summary>
  K_CMDCMTOtherStudyNumbersRetired = $00201070;

/// <summary>
/// Number of Patient Related Studies (0020;1200) IS 1
/// </summary>
  K_CMDCMTNumberOfPatientRelatedStudies = $00201200;

/// <summary>
/// Number of Patient Related Series (0020;1202) IS 1
/// </summary>
  K_CMDCMTNumberOfPatientRelatedSeries = $00201202;

/// <summary>
/// Number of Patient Related Instances (0020;1204) IS 1
/// </summary>
  K_CMDCMTNumberOfPatientRelatedInstances = $00201204;

/// <summary>
/// Number of Study Related Series (0020;1206) IS 1
/// </summary>
  K_CMDCMTNumberOfStudyRelatedSeries = $00201206;

/// <summary>
/// Number of Study Related Instances (0020;1208) IS 1
/// </summary>
  K_CMDCMTNumberOfStudyRelatedInstances = $00201208;

/// <summary>
/// Number of Series Related Instances (0020;1209) IS 1
/// </summary>
  K_CMDCMTNumberOfSeriesRelatedInstances = $00201209;

/// <summary>
/// Source Image IDs (Retired) (0020;3100 to 31FF)  K_CMDCMTCS 1-n
/// </summary>
  K_CMDCMTSourceImageIdsRetired = $00203100;

/// <summary>
/// Modifying Device ID (Retired) (0020;3401) CS 1
/// </summary>
  K_CMDCMTModifyingDeviceIdRetired = $00203401;

/// <summary>
/// Modified Image ID (Retired) (0020;3402) CS 1
/// </summary>
  K_CMDCMTModifiedImageIdRetired = $00203402;

/// <summary>
/// Modified Image Date (Retired) (0020;3403) DA 1
/// </summary>
  K_CMDCMTModifiedImageDateRetired = $00203403;

/// <summary>
/// Modified Device Manufacturer (Retired) (0020;3404) LO 1
/// </summary>
  K_CMDCMTModifyingDeviceManufacturerRetired = $00203404;

/// <summary>
/// Modified Image Time (Retired) (0020;3405) TM 1
/// </summary>
  K_CMDCMTModifiedImageTimeRetired = $00203405;

/// <summary>
/// Modified Image Description (Retired) (0020;3406) LO 1
/// </summary>
  K_CMDCMTModifiedImageDescriptionRetired = $00203406;

/// <summary>
/// Image Comments (0020;4000) LT 1
/// </summary>
  K_CMDCMTImageComments = $00204000;

/// <summary>
/// Original Image Identification (Retired) (0020;5000) AT 1-n
/// </summary>
  K_CMDCMTOriginalImageIdentificationRetired = $00205000;

/// <summary>
/// Original Image Identification Nomenclature (Retired) (0020;5002) CS 1
/// </summary>
  K_CMDCMTOriginalImageIdentificationNomenclatureRetired = $00205002;

/// <summary>
/// Stack ID (0020;9056) SH 1
/// </summary>
  K_CMDCMTStackId = $00209056;

/// <summary>
/// In-Stack Position Number (0020;9057) UL 1
/// </summary>
  K_CMDCMTInStackPositionNumber = $00209057;

/// <summary>
/// Frame Anatomy Sequence (0020;9071) SQ 1
/// </summary>
  K_CMDCMTFrameAnatomySequence = $00209071;

/// <summary>
/// Frame Laterality (0020;9072) CS 1
/// </summary>
  K_CMDCMTFrameLaterality = $00209072;

/// <summary>
/// Frame Content Sequence (0020;9111) SQ 1
/// </summary>
  K_CMDCMTFrameContentSequence = $00209111;

/// <summary>
/// Plane Position Sequence (0020;9113) SQ 1
/// </summary>
  K_CMDCMTPlanePositionSequence = $00209113;

/// <summary>
/// Plane Orientation Sequence (0020;9116) SQ 1
/// </summary>
  K_CMDCMTPlaneOrientationSequence = $00209116;

/// <summary>
/// Temporal Position Index (0020;9128) UL 1
/// </summary>
  K_CMDCMTTemporalPositionIndex = $00209128;

/// <summary>
/// Cardiac Trigger Delay Time (0020;9153) FD 1
/// </summary>
  K_CMDCMTCardiacTriggerDelayTime = $00209153;

/// <summary>
/// Frame Acquisition Number (0020;9156) US 1
/// </summary>
  K_CMDCMTFrameAcquisitionNumber = $00209156;

/// <summary>
/// Dimension Index Values (0020;9157) UL 1-n
/// </summary>
  K_CMDCMTDimensionIndexValues = $00209157;

/// <summary>
/// Frame Comments (0020;9158) LT 1
/// </summary>
  K_CMDCMTFrameComments = $00209158;

/// <summary>
/// Concatenation UID (0020;9161) UI 1
/// </summary>
  K_CMDCMTConcatenationUid = $00209161;

/// <summary>
/// In-concatenation Number (0020;9162) US 1
/// </summary>
  K_CMDCMTInConcatenationNumber = $00209162;

/// <summary>
/// In-concatenation Total Number (0020;9163) US 1
/// </summary>
  K_CMDCMTInConcatenationTotalNumber = $00209163;

/// <summary>
/// Dimension Organization UID (0020;9164) UI 1
/// </summary>
  K_CMDCMTDimensionOrganizationUid = $00209164;

/// <summary>
/// Dimension Index Pointer (0020;9165) AT 1
/// </summary>
  K_CMDCMTDimensionIndexPointer = $00209165;

/// <summary>
/// Functional Group Pointer (0020;9167) AT 1
/// </summary>
  K_CMDCMTFunctionalGroupPointer = $00209167;

/// <summary>
/// Dimension Index Private Creator (0020;9213) LO 1
/// </summary>
  K_CMDCMTDimensionIndexPrivateCreator = $00209213;

/// <summary>
/// Dimension Organizaiton Sequence (0020;9221) SQ 1
/// </summary>
  K_CMDCMTDimensionOrganizationSequence = $00209221;

/// <summary>
/// Dimension Index Sequence (0020;9222) SQ 1
/// </summary>
  K_CMDCMTDimensionIndexSequence = $00209222;

/// <summary>
/// Concatenation Frame Offset Number (0020;9228) UL 1
/// </summary>
  K_CMDCMTConcatenationFrameOffsetNumber = $00209228;

/// <summary>
/// Functional Group Private Creator (0020;9238) LO 1
/// </summary>
  K_CMDCMTFunctionalGroupPrivateCreator = $00209238;

/// <summary>
/// R_R Interval Time Measured (0020;9251) FD 1
/// </summary>
  K_CMDCMTR_RIntervalTimeMeasured = $00209251;

/// <summary>
/// Respiratory Trigger Sequence (0020;9253) SQ 1
/// </summary>
  K_CMDCMTRespiratoryTriggerSequence = $00209253;

/// <summary>
/// Respiratory Interval Time (0020;9254) FD 1
/// </summary>
  K_CMDCMTRespiratoryIntervalTime = $00209254;

/// <summary>
/// Respiratory Trigger Delay Time (0020;9255) FD 1
/// </summary>
  K_CMDCMTRespiratoryTriggerDelayTime = $00209255;

/// <summary>
/// Respiratory Trigger Delay Threshold (0020;9256) FD 1
/// </summary>
  K_CMDCMTRespiratoryTriggerDelayThreshold = $00209256;

/// <summary>
/// Dimension Description Label    K_CMDCMT(0020;9421) LO 1
/// </summary>
  K_CMDCMTDimensionDescriptionLabel = $00209421;

/// <summary>
/// Patient Orientation in Frame Sequence    K_CMDCMT(0020;9450) SQ 1
/// </summary>
  K_CMDCMTPatientOrientationInFrameSequence = $00209450;

/// <summary>
/// Frame Label        K_CMDCMT (0020;9453) LO 1
/// </summary>
  K_CMDCMTFrameLabel = $00209453;

    
// GROUP 22
/// <summary>
/// Light Path Filter Pass-Through Wavelength (0022;0001) US 1
/// </summary>
  K_CMDCMTLightPathFilterPassThroughWavelength = $00220001;

/// <summary>
/// Light Path Filter Pass Band (0022;0002) US 2
/// </summary>
  K_CMDCMTLightPathFilterPassBand = $00220002;

/// <summary>
/// Image Path Filter Pass-Through Wavelength (0022;0003) US 1
/// </summary>
  K_CMDCMTImagePathFilterPassThroughWavelength = $00220003;

/// <summary>
/// Image Path Filter Pass Band (0022;0004) US 2
/// </summary>
  K_CMDCMTImagePathFilterPassBand = $00220004;

/// <summary>
/// Patient Eye Movement Commanded (0022;0005) CS 1
/// </summary>
  K_CMDCMTPatientEyeMovementCommanded = $00220005;

/// <summary>
/// Patient Eye Movement Command Code Sequence (0022;0006) SQ 1
/// </summary>
  K_CMDCMTPatientEyeMovementCommandCodeSequence = $00220006;

/// <summary>
/// Spherical Lens Power (0022;0007) FL 1
/// </summary>
  K_CMDCMTSphericalLensPower = $00220007;

/// <summary>
/// Cylinder Lens Power (0022;0008) FL 1
/// </summary>
  K_CMDCMTCylinderLensPower = $00220008;

/// <summary>
/// Cylinder Axis (0022;0009) FL 1
/// </summary>
  K_CMDCMTCylinderAxis = $00220009;

/// <summary>
/// Emmetropic Magnification (0022;000A) FL 1
/// </summary>
  K_CMDCMTEmmetropicMagnification = $0022000A;

/// <summary>
/// Intra Ocular Pressure (0022;000B) FL 1
/// </summary>
  K_CMDCMTIntraOcularPressure = $0022000B;

/// <summary>
/// Horizontal Field of View (0022;000C) FL 1
/// </summary>
  K_CMDCMTHorizontalFieldOfView = $0022000C;

/// <summary>
/// Pupil Dilated (0022;000D) CS 1
/// </summary>
  K_CMDCMTPupilDilated = $0022000D;

/// <summary>
/// Degree of Dilation (0022;000E) FL 1
/// </summary>
  K_CMDCMTDegreeOfDilation = $0022000E;

/// <summary>
/// Stereo Baseline Angle (0022;0010) FL 1
/// </summary>
  K_CMDCMTStereoBaselineAngle = $00220010;

/// <summary>
/// Stereo Baseline Displacement (0022;0011) FL 1
/// </summary>
  K_CMDCMTStereoBaselineDisplacement = $00220011;

/// <summary>
/// Stereo Horizontal Pixel Offset (0022;0012) FL 1
/// </summary>
  K_CMDCMTStereoHorizontalPixelOffset = $00220012;

/// <summary>
/// Stereo Vertical Pixel Offset (0022;0013) FL 1
/// </summary>
  K_CMDCMTStereoVerticalPixelOffset = $00220013;

/// <summary>
/// Stereo Rotation (0022;0014) FL 1
/// </summary>
  K_CMDCMTStereoRotation = $00220014;

/// <summary>
/// Acquisition Device Type Code Sequence (0022;0015) SQ 1
/// </summary>
  K_CMDCMTAcquisitionDeviceTypeCodeSequence = $00220015;

/// <summary>
/// Illumination Type Code Sequence (0022;0016) SQ 1
/// </summary>
  K_CMDCMTIlluminationTypeCodeSequence = $00220016;

/// <summary>
/// Light Path Filter Type Stack Code Sequence (0022;0017) SQ 1
/// </summary>
  K_CMDCMTLightPathFilterTypeStackCodeSequence = $00220017;

/// <summary>
/// Image Path Filter Type Stack Code Sequence (0022;0018) SQ 1
/// </summary>
  K_CMDCMTImagePathFilterTypeStackCodeSequence = $00220018;

/// <summary>
/// Lenses Code Sequence (0022;0019) SQ 1
/// </summary>
  K_CMDCMTLensesCodeSequence = $00220019;

/// <summary>
/// Channel Description Code Sequence (0022;001A) SQ 1
/// </summary>
  K_CMDCMTChannelDescriptionCodeSequence = $0022001A;

/// <summary>
/// Refractive State Sequence (0022;001B) SQ 1
/// </summary>
  K_CMDCMTRefractiveStateSequence = $0022001B;

/// <summary>
/// Mydriatic Agent Code Sequence (0022;001C) SQ 1
/// </summary>
  K_CMDCMTMydriaticAgentCodeSequence = $0022001C;

/// <summary>
/// Relative Image Position Code Sequence (0022;001D) SQ 1
/// </summary>
  K_CMDCMTRelativeImagePositionCodeSequence = $0022001D;

/// <summary>
/// Stereo Pairs Sequence (0022;0020) SQ 1
/// </summary>
  K_CMDCMTStereoPairsSequence = $00220020;

/// <summary>
/// Left Image Sequence (0022;0021) SQ 1
/// </summary>
  K_CMDCMTLeftImageSequence = $00220021;

/// <summary>
/// Right Image Sequence (0022;0022) SQ 1
/// </summary>
  K_CMDCMTRightImageSequence = $00220022;
    
// GROUP 28
/// <summary>
// GROUP 28 Group Length (0028;0000)
/// </summary>
  K_CMDCMTGroup28GroupLength = $00280000;

/// <summary>
/// Samples per Pixel (0028;0002) US 1
/// </summary>
  K_CMDCMTSamplesPerPixel = $00280002;

/// <summary>
/// Samples per Pixel Used (0028;0003) US 1
/// </summary>
  K_CMDCMTSamplesPerPixelUsed = $00280003;

/// <summary>
/// Photometric Interpretation (0028;0004) CS 1
/// </summary>
  K_CMDCMTPhotometricInterpretation = $00280004;

/// <summary>
/// Image Dimensions (Retired) (0028;0005) US 1
/// </summary>
  K_CMDCMTImageDimensionsRetired = $00280005;

/// <summary>
/// Planar Configuration (0028;0006) US 1
/// </summary>
  K_CMDCMTPlanarConfiguration = $00280006;

/// <summary>
/// Number of Frames (0028;0008) IS 1
/// </summary>
  K_CMDCMTNumberOfFrames = $00280008;

/// <summary>
/// Frame Increment Pointer (0028;0009) AT 1-n
/// </summary>
  K_CMDCMTFrameIncrementPointer = $00280009;

/// <summary>
/// Frame Dimension Pointer (0028;000A) AT 1-n
/// </summary>
  K_CMDCMTFrameDimensionPointer = $0028000A;

/// <summary>
/// Rows (0028;0010) US 1
/// </summary>
  K_CMDCMTRows = $00280010;

/// <summary>
/// Columns (0028;0011) US 1
/// </summary>
  K_CMDCMTColumns = $00280011;

/// <summary>
/// Planes (0028;0012) US 1
/// </summary>
  K_CMDCMTPlanes = $00280012;

/// <summary>
/// Ultrasound Color Data Present (0028;0014) US 1
/// </summary>
  K_CMDCMTUltrasoundColorDataPresent = $00280014;

/// <summary>
/// Pixel Spacing (0028;0030) DS 2
/// </summary>
  K_CMDCMTPixelSpacing = $00280030;

/// <summary>
/// Zoom Factor (0028;0031) DS 2
/// </summary>
  K_CMDCMTZoomFactor = $00280031;

/// <summary>
/// Zoom Center (0028;0032) DS 2
/// </summary>
  K_CMDCMTZoomCenter = $00280032;

/// <summary>
/// Pixel Aspect Ratio (0028;0034) IS 2
/// </summary>
  K_CMDCMTPixelAspectRatio = $00280034;

/// <summary>
/// Image Format (Retired) (0028;0040) CS 1
/// </summary>
  K_CMDCMTImageFormatRetired = $00280040;

/// <summary>
/// Manipulated Image (Retired) (0028;0050) LO 1-n
/// </summary>
  K_CMDCMTManipulatedImageRetired = $00280050;

/// <summary>
/// Corrected Image (0028;0051) CS 1-n
/// </summary>
  K_CMDCMTCorrectedImage = $00280051;

/// <summary>
/// Compression Code (Retired)(0028;0060) CS 1
/// </summary>
  K_CMDCMTCompressionCodeRetired = $00280060;

/// <summary>
/// Bits Allocated (0028;0100) US 1
/// </summary>
  K_CMDCMTBitsAllocated = $00280100;

/// <summary>
/// Bits Stored (0028;0101) US 1
/// </summary>
  K_CMDCMTBitsStored = $00280101;

/// <summary>
/// High Bit (0028;0102) US 1
/// </summary>
  K_CMDCMTHighBit = $00280102;

/// <summary>
/// Pixel Representation (0028;0103) US 1
/// </summary>
  K_CMDCMTPixelRepresentation = $00280103;

/// <summary>
/// Smallest Valid Pixel Value (Retired) (0028;0104) US or SS 1
/// </summary>
  K_CMDCMTSmallestValidPixelValueRetired = $00280104;

/// <summary>
/// Largest Valid Pixel Value (Retired) (0028;0105) US or SS 1
/// </summary>
  K_CMDCMTLargestValidPixelValueRetired = $00280105;

/// <summary>
/// Smallest Image Pixel Value (0028;0106) US 1
/// </summary>
  K_CMDCMTSmallestImagePixelValue = $00280106;

/// <summary>
/// Largest Image Pixel Value (0028;0107) US 1
/// </summary>
  K_CMDCMTLargestImagePixelValue = $00280107;

/// <summary>
/// Smallest Pixel Value in Series (0028;0108) US 1
/// </summary>
  K_CMDCMTSmallestPixelValueInSeries = $00280108;

/// <summary>
/// Largest Pixel Value in Series (0028;0109) US 1
/// </summary>
  K_CMDCMTLargestPixelValueInSeries = $00280109;

/// <summary>
/// Smallest Image Pixel Value in Plane (0028;0110) US 1
/// </summary>
  K_CMDCMTSmallestImagePixelValueInPlane = $00280110;

/// <summary>
/// Largest Image Pixel Value in Plane (0028;0111) US 1
/// </summary>
  K_CMDCMTLargestImagePixelValueInPlane = $00280111;

/// <summary>
/// Pixel Padding Value (0028;0120) US 1
/// </summary>
  K_CMDCMTPixelPaddingValue = $00280120;

/// <summary>
/// Image Location (Retired) (0028;0200) US 1
/// </summary>
  K_CMDCMTImageLocationRetired = $00280200;

/// <summary>
/// Quality Control Image (0028;0300) CS 1
/// </summary>
  K_CMDCMTQualityControlImage = $00280300;

/// <summary>
/// Burned In Annotation (0028;0301) CS 1
/// </summary>
  K_CMDCMTBurnedInAnnotation = $00280301;

/// <summary>
/// Pixel Spacing Calibration Type     (0028;0402) CS 1
/// </summary>
  K_CMDCMTPixelSpacingCalibrationType = $00280402;

/// <summary>
/// Pixel Spacing Calibration Description     (0028;0404) LO 1
/// </summary>
  K_CMDCMTPixelSpacingCalibrationDescription = $00280404;

/// <summary>
/// Pixel Intensity Relationship (0028;1040) CS 1
/// </summary>
  K_CMDCMTPixelIntensityRelationship = $00281040;

/// <summary>
/// Pixel Intensity Relationship Sign (0028;1041) SS 1
/// </summary>
  K_CMDCMTPixelIntensityRelationshipSign = $00281041;

/// <summary>
/// Window Center (0028;1050) DS 1-n
/// </summary>
  K_CMDCMTWindowCenter = $00281050;

/// <summary>
/// Window Width (0028;1051) DS 1-n
/// </summary>
  K_CMDCMTWindowWidth = $00281051;

/// <summary>
/// Rescale Intercept (0028;1052) DS 1
/// </summary>
  K_CMDCMTRescaleIntercept = $00281052;

/// <summary>
/// Rescale Slope (0028;1053) DS 1
/// </summary>
  K_CMDCMTRescaleSlope = $00281053;

/// <summary>
/// Rescale Type (0028;1054) LO 1
/// </summary>
  K_CMDCMTRescaleType = $00281054;

/// <summary>
/// Window Center Width Explanation (0028;1055) LO 1-n
/// </summary>
  K_CMDCMTWindowCenterWidthExplanation = $00281055;

/// <summary>
/// VOI LUT Function     (0028;1056) CS 1
/// </summary>
  K_CMDCMTVOILUTFunction = $00281056;

/// <summary>
/// Gray Scale (Retired) (0028;1080) CS
/// </summary>
  K_CMDCMTGrayScaleRetired = $00281080;

/// <summary>
/// Recommended Viewing Mode (0028;1090) CS 1
/// </summary>
  K_CMDCMTRecommendedViewingMode = $00281090;

/// <summary>
/// Gray Lookup Table Descriptor (Retired) (0028;1100) US or SS 3
/// </summary>
  K_CMDCMTGrayLookupTableDescriptorRetired = $00281100;

/// <summary>
/// Red Palette Color Lookup Table Descriptor (0028;1101) US 3
/// </summary>
  K_CMDCMTRedPaletteColorLookupTableDescriptor = $00281101;

/// <summary>
/// Green Palette Color Lookup Table Descriptor (0028;1102) US 3
/// </summary>
  K_CMDCMTGreenPaletteColorLookupTableDescriptor = $00281102;

/// <summary>
/// Blue Palette Color Lookup Table Descriptor (0028;1103) US 3
/// </summary>
  K_CMDCMTBluePaletteColorLookupTableDescriptor = $00281103;

/// <summary>
/// Palette Color Lookup Table UID (0028;1199) UI 1
/// </summary>
  K_CMDCMTPaletteColorLookupTableUid = $00281199;

/// <summary>
/// Gray Lookup Table Data (Retired) (0028;1200) US or SS or OW 1  K_CMDCMT1-n 
/// </summary>
  K_CMDCMTGrayLookupTableDataRetired = $00281200;

/// <summary>
/// Red Palette Color Lookup Table Data (0028;1201) OW 1
/// </summary>
  K_CMDCMTRedPaletteColorLookupTableData = $00281201;

/// <summary>
/// Green Palette Color Lookup Table Data (0028;1202) OW 1
/// </summary>
  K_CMDCMTGreenPaletteColorLookupTableData = $00281202;

/// <summary>
/// Blue Palette Color Lookup Table Data (0028;1203) OW 1
/// </summary>
  K_CMDCMTBluePaletteColorLookupTableData = $00281203;

/// <summary>
/// Segmented Red Palette Color Lookup Table Data (0028;1221) OW 1
/// </summary>
  K_CMDCMTSegmentedRedPaletteColorLookupTableData = $00281221;

/// <summary>
/// Segmented Green Palette Color Lookup Table Data (0028;1222) OW 1
/// </summary>
  K_CMDCMTSegmentedGreenPaletteColorLookupTableData = $00281222;

/// <summary>
/// Segmented Blue Palette Color Lookup Table Data (0028;1223) OW 1
/// </summary>
  K_CMDCMTSegmentedBluePaletteColorLookupTableData = $00281223;

/// <summary>
/// Implant Present (0028;1300) CS 1
/// </summary>
  K_CMDCMTImplantPresent = $00281300;

/// <summary>
/// Partial View (0028;1350) CS 1
/// </summary>
  K_CMDCMTPartialView = $002821350;

/// <summary>
/// Partial View Description (0028;1351) ST 1
/// </summary>
  K_CMDCMTPartialViewDescription = $002821351;

/// <summary>
/// Partial View Code Sequence  (0028;1352) SQ 1
/// </summary>
  K_CMDCMTPartialViewCodeSequence = $002821352;

/// <summary>
/// Spatial Locations Preserved   (0028;135A) CS 1
/// </summary>
  K_CMDCMTSpatialLocationsPreserved = $00282135A;

/// <summary>
/// ICC Profile      K_CMDCMT(0028;2000) OB 1
/// </summary>
  K_CMDCMTICCProfile = $00282000;

/// <summary>
/// Lossy Image Compression (0028;2110) CS 1
/// </summary>
  K_CMDCMTLossyImageCompression = $00282110;

/// <summary>
/// Lossy Image Compression Ratio (0028;2112) DS 1-n
/// </summary>
  K_CMDCMTLossyImageCompressionRatio = $00282112;

/// <summary>
/// Lossy Image Compression Method (0028;2114) CS 1-n
/// </summary>
  K_CMDCMTLossyImageCompressionMethod = $00282114;

/// <summary>
/// Modality LUT Sequence (0028;3000) SQ 1
/// </summary>
  K_CMDCMTModalityLutSequence = $00283000;

/// <summary>
/// LUT Descriptor (0028;3002) US or SS 3
/// </summary>
  K_CMDCMTLutDescriptor = $00283002;

/// <summary>
/// LUT Explanation (0028;3003) LO 1
/// </summary>
  K_CMDCMTLutExplanation = $00283003;

/// <summary>
/// Modality LUT Type (0028;3004) LO 1
/// </summary>
  K_CMDCMTModalityLutType = $00283004;

/// <summary>
/// LUT Data (0028;3006) US;SS;OW 1-n
/// </summary>
  K_CMDCMTLutData = $00283006;

/// <summary>
/// VOI LUT Sequence (0028;3010) SQ 1
/// </summary>
  K_CMDCMTVoiLutSequence = $00283010;

/// <summary>
/// Softcopy VOI LUT Sequence (0028;3110) SQ 1
/// </summary>
  K_CMDCMTSoftcopyVoiLutSequence = $00283110;

/// <summary>
/// Image Presentation Comments (Retired) (0028;4000) LT 1
/// </summary>
  K_CMDCMTImagePresentationCommentsRetired = $00284000;

/// <summary>
/// Bi-Plane Acquisition Sequence (0028;5000) SQ 1
/// </summary>
  K_CMDCMTBIPlaneAcquisitionSequence = $00285000;

/// <summary>
/// Representative Frame Number (0028;6010) US 1
/// </summary>
  K_CMDCMTRepresentativeFrameNumber = $00286010;

/// <summary>
/// Frame Numbers of Interest (FOI) (0028;6020) US 1-n
/// </summary>
  K_CMDCMTFrameNumbersOfInterestFoi = $00286020;

/// <summary>
/// Frame(s) of Interest Description (0028;6022) LO 1-n
/// </summary>
  K_CMDCMTFramesOfInterestDescription = $00286022;

/// <summary>
/// Frame of Interest Type (0028;6023) CS 1-n
/// </summary>
  K_CMDCMTFrameOfInterestType = $00286023;

/// <summary>
/// Mask Pointer(s) (Retired) (0028;6030) US 1-n
/// </summary>
  K_CMDCMTMaskPointersRetired = $00286030;

/// <summary>
/// R Wave Pointer (0028;6040) US 1-n
/// </summary>
  K_CMDCMTRWavePointer = $00286040;

/// <summary>
/// Mask Subtraction Sequence (0028;6100) SQ 1
/// </summary>
  K_CMDCMTMaskSubtractionSequence = $00286100;

/// <summary>
/// Mask Operation (0028;6101) CS 1
/// </summary>
  K_CMDCMTMaskOperation = $00286101;

/// <summary>
/// Applicable Frame Range (0028;6102) US 2-2n
/// </summary>
  K_CMDCMTApplicableFrameRange = $00286102;

/// <summary>
/// Mask Frame Numbers (0028;6110) US 1-n
/// </summary>
  K_CMDCMTMaskFrameNumbers = $00286110;

/// <summary>
/// Contrast Frame Averaging (0028;6112) US 1
/// </summary>
  K_CMDCMTContrastFrameAveraging = $00286112;

/// <summary>
/// Mask Sub-pixel Shift (0028;6114) FL 2
/// </summary>
  K_CMDCMTMaskSubPixelShift = $00286114;

/// <summary>
/// TID Offset (0028;6120) SS 1
/// </summary>
  K_CMDCMTTidOffset = $00286120;

/// <summary>
/// Mask Operation Explanation (0028;6190) ST 1
/// </summary>
  K_CMDCMTMaskOperationExplanation = $00286190;

/// <summary>
/// Pixel Data Provider URL  K_CMDCMT(0028;7FE0) UT 1
/// </summary>
  K_CMDCMTPixelDataProviderURL = $00287FE0;


/// <summary>
/// Data Point Rows (0028;9001) UL 1
/// </summary>
  K_CMDCMTDataPointRows = $00289001;

/// <summary>
/// Data Point Columns (0028;9002) UL 1
/// </summary>
  K_CMDCMTDataPointColumns = $00289002;

/// <summary>
/// Signal Domain Columns (0028;9003) CS 1
/// </summary>
  K_CMDCMTSignalDomainColumns = $00299003;

/// <summary>
/// Largest Monochrome Pixel Value (Retired) (0028;9099) US 1
/// </summary>
  K_CMDCMTLargestMonochromePixelValueRetired = $00289099;

/// <summary>
/// Data Representation (0028;9108) CS 1
/// </summary>
  K_CMDCMTDataRepresentation = $00289108;

/// <summary>
/// Pixel Measures Sequence (0028;9110) SQ 1
/// </summary>
  K_CMDCMTPixelMeasuresSequence = $00289110;

/// <summary>
/// Frame VOI LUT Sequence (0028;9132) SQ 1
/// </summary>
  K_CMDCMTFrameVoiLutSequence = $00289132;

/// <summary>
/// Pixel Value Transformation Sequence (0028;9145) SQ 1
/// </summary>
  K_CMDCMTPixelValueTransformationSequence = $00289145;

/// <summary>
/// Signal Domain Rows (0028;9235) CS 1
/// </summary>
  K_CMDCMTSignalDomainRows = $00289235;

/// <summary>
/// Display Filter Percentage  K_CMDCMT(0028;9411) FL 1
/// </summary>
  K_CMDCMTDisplayFilterPercentage = $00289411;

/// <summary>
/// Frame Pixel Shift Sequence  K_CMDCMT(0028;9415) SQ 1
/// </summary>
  K_CMDCMTFramePixelShiftSequence = $00289415;

/// <summary>
/// Subtraction Item ID    K_CMDCMT (0028;9416) US 1
/// </summary>
  K_CMDCMTSubtractionItemID = $00289416;

/// <summary>
/// Pixel Intensity Relationship LUT Sequence    K_CMDCMT (0028;9422) SQ 1
/// </summary>
  K_CMDCMTPixelIntensityRelationshipLUTSequence = $00289422;

/// <summary>
/// Frame Pixel Data Properties Sequence    K_CMDCMT (0028;9443) SQ 1
/// </summary>
  K_CMDCMTFramePixelDataPropertiesSequence = $00289443;

/// <summary>
/// Geometrical Properties    K_CMDCMT(0028;9444) CS 1
/// </summary>
  K_CMDCMTGeometricalProperties = $00289444;

/// <summary>
/// Geometric Maximum Distortion    K_CMDCMT(0028;9445) FL 1
/// </summary>
  K_CMDCMTGeometricMaximumDistortion = $00289445;

/// <summary>
/// Image Processing Applied   (0028;9446) CS 1-n
/// </summary>
  K_CMDCMTImageProcessingApplied = $00289446;

/// <summary>
/// Mask Selection Mode    K_CMDCMT(0028;9454) CS 1
/// </summary>
  K_CMDCMTMaskSelectionMode = $00289454;

/// <summary>
/// LUT Function    K_CMDCMT(0028;9474) CS 1
/// </summary>
  K_CMDCMTLUTFunction = $00289474;

    
// GROUP 32
/// <summary>
// GROUP 32 Group Length (0032;0000) UL1
/// </summary>
  K_CMDCMTGroup32GroupLength = $00320000;

/// <summary>
/// Study Status ID (Retired) (0032;000A) CS 1
/// </summary>
  K_CMDCMTStudyStatusIdRetired = $0032000A;

/// <summary>
/// Study Priority ID (Retired) (0032;000C) CS 1
/// </summary>
  K_CMDCMTStudyPriorityIdRetired = $0032000C;

/// <summary>
/// Study ID Issuer (Retired) (0032;0012) LO 1
/// </summary>
  K_CMDCMTStudyIdIssuerRetired = $00320012;

/// <summary>
/// Study Verified Date (Retired) (0032;0032) DA 1
/// </summary>
  K_CMDCMTStudyVerifiedDateRetired = $00320032;

/// <summary>
/// Study Verified Time (Retired) (0032;0033) TM 1
/// </summary>
  K_CMDCMTStudyVerifiedTimeRetired = $00320033;

/// <summary>
/// Study Read Date (Retired) (0032;0034) DA 1
/// </summary>
  K_CMDCMTStudyReadDateRetired = $00320034;

/// <summary>
/// Study Read Time (Retired) (0032;0035) TM 1
/// </summary>
  K_CMDCMTStudyReadTimeRetired = $00320035;

/// <summary>
/// Scheduled Study Start Date (Retired) (0032;1000) DA 1
/// </summary>
  K_CMDCMTScheduledStudyStartDateRetired = $00321000;

/// <summary>
/// Scheduled Study Start Time (Retired) (0032;1001) TM 1
/// </summary>
  K_CMDCMTScheduledStudyStartTimeRetired = $00321001;

/// <summary>
/// Scheduled Study Stop Date (Retired) (0032;1010) DA 1
/// </summary>
  K_CMDCMTScheduledStudyStopDateRetired = $00321010;

/// <summary>
/// Scheduled Study Stop Time (Retired) (0032;1011) TM 1
/// </summary>
  K_CMDCMTScheduledStudyStopTimeRetired = $00321011;

/// <summary>
/// Scheduled Study Location (Retired) (0032;1020) LO 1
/// </summary>
  K_CMDCMTScheduledStudyLocationRetired = $00321020;

/// <summary>
/// Scheduled Study Location AE Title(s) (Retired) (0032;1021) AE 1-n
/// </summary>
  K_CMDCMTScheduledStudyLocationAETitlesRetired = $00321021;

/// <summary>
/// Reason for Study (Retired) (0032;1030) LO 1
/// </summary>
  K_CMDCMTReasonForStudyRetired = $00321030;

/// <summary>
/// Requesting Physician Identification Sequence (0032;1031) SQ 1
/// </summary>
  K_CMDCMTRequestingPhysicianIdentificationSequence = $00321031;

/// <summary>
/// Requesting Physician (0032;1032) PN 1
/// </summary>
  K_CMDCMTRequestingPhysician = $00321032;

/// <summary>
/// Requesting Service (0032;1033) LO 1
/// </summary>
  K_CMDCMTRequestingService = $00321033;

/// <summary>
/// Study Arrival Date (Retired) (0032;1040) DA 1
/// </summary>
  K_CMDCMTStudyArrivalDateRetired = $00321040;

/// <summary>
/// Study Arrival Time (Retired) (0032;1041) TM 1
/// </summary>
  K_CMDCMTStudyArrivalTimeRetired = $00321041;

/// <summary>
/// Study Completion Date (Retired) (0032;1050) DA 1
/// </summary>
  K_CMDCMTStudyCompletionDateRetired = $00321050;

/// <summary>
/// Study Completion Time (Retired) (0032;1051) TM 1
/// </summary>
  K_CMDCMTStudyCompletionTimeRetired = $00321051;

/// <summary>
/// Study Component Status ID (Retired)  K_CMDCMT(0032;1055) CS 1
/// </summary>
  K_CMDCMTStudyComponentStatusIdRetired = $00321055;

/// <summary>
/// Requested Procedure Description (0032;1060) LO 1
/// </summary>
  K_CMDCMTRequestedProcedureDescription = $00321060;

/// <summary>
/// Requested Procedure Code Sequence (0032;1064) SQ 1
/// </summary>
  K_CMDCMTRequestedProcedureCodeSequence = $00321064;

/// <summary>
/// Requested Contrast Agent (0032;1070) LO 1
/// </summary>
  K_CMDCMTRequestedContrastAgent = $00321070;

/// <summary>
/// Study Comments (0032;4000) LT 1
/// </summary>
  K_CMDCMTStudyComments = $00324000;
    
// GROUP 38
/// <summary>
// GROUP 38 Group Length (0038;0000) UL 1
/// </summary>
  K_CMDCMTGroup38GroupLength = $00380000;

/// <summary>
/// Referenced Patient Alias Sequence (0038;0004) SQ 1
/// </summary>
  K_CMDCMTReferencedPatientAliasSequence = $00380004;

/// <summary>
/// Visit Status ID (0038;0008) CS 1
/// </summary>
  K_CMDCMTVisitStatusId = $00380008;

/// <summary>
/// Admission ID (0038;0010) LO 1
/// </summary>
  K_CMDCMTAdmissionId = $00380010;

/// <summary>
/// Issuer of Admission ID (0038;0011) LO 1
/// </summary>
  K_CMDCMTIssuerOfAdmissionId = $00380011;

/// <summary>
/// Route of Admissions (0038;0016) LO 1
/// </summary>
  K_CMDCMTRouteOfAdmissions = $00380016;

/// <summary>
/// Scheduled Admission Date (Retired)  (0038;001A) DA 1
/// </summary>
  K_CMDCMTScheduledAdmissionDateRetired = $0038001A;

/// <summary>
/// Scheduled Admission Time (Retired)   (0038;001B) TM 1
/// </summary>
  K_CMDCMTScheduledAdmissionTimeRetired = $0038001B;

/// <summary>
/// Scheduled Discharge Date (Retired)   (0038;001C) DA 1
/// </summary>
  K_CMDCMTScheduledDischargeDateRetired = $0038001C;

/// <summary>
/// Scheduled Discharge Time (Retired)  K_CMDCMT(0038;001D) TM 1
/// </summary>
  K_CMDCMTScheduledDischargeTimeRetired = $0038001D;

/// <summary>
///  K_CMDCMTScheduled Patient Institution Residence (Retired)  K_CMDCMT(0038;001E) LO 1
/// </summary>
  K_CMDCMTScheduledPatientInstitutionResidenceRetired = $0038001E;

/// <summary>
/// Admitting Date (0038;0020) DA 1
/// </summary>
  K_CMDCMTAdmittingDate = $00380020;

/// <summary>
/// Admitting Time (0038;0021) TM 1
/// </summary>
  K_CMDCMTAdmittingTime = $00380021;

/// <summary>
/// Discharge Date (Retired) (0038;0030) DA 1
/// </summary>
  K_CMDCMTDischargeDateRetired = $00380030;

/// <summary>
/// Discharge Time (Retired) (0038;0032) TM 1
/// </summary>
  K_CMDCMTDischargeTimeRetired = $00380032;

/// <summary>
/// Discharge Diagnosis Description (Retired) (0038;0040) LO 1
/// </summary>
  K_CMDCMTDischargeDiagnosisDescriptionRetired = $00380040;

/// <summary>
/// Discharge Diagnosis Code Sequence (Retired) (0038;0044) SQ 1
/// </summary>
  K_CMDCMTDischargeDiagnosisCodeSequenceRetired = $00380044;

/// <summary>
/// Special Needs (0038;0050) LO 1
/// </summary>
  K_CMDCMTSpecialNeeds = $00380050;

/// <summary>
/// Pertinent Documents Sequence (0038;0100) SQ 1
/// </summary>
  K_CMDCMTPertinentDocumentsSequence = $00380100;

/// <summary>
/// Current Patient Location (0038;0300) LO 1
/// </summary>
  K_CMDCMTCurrentPatientLocation = $00380300;

/// <summary>
/// Patients Institution Residence (0038;0400) LO 1
/// </summary>
  K_CMDCMTPatientsInstitutionResidence = $00380400;

/// <summary>
/// Patient State (0038;0500) LO 1
/// </summary>
  K_CMDCMTPatientState = $00380500;

/// <summary>
/// Patient Clinical Trial Participation Sequence  K_CMDCMT(0038;0502) SQ 1
/// </summary>
  K_CMDCMTPatientClinicalTrialParticipationSequence = $00380502;

/// <summary>
/// Visit Comments (0038;4000) LT 1
/// </summary>
  K_CMDCMTVisitComments = $00384000;
    
// GROUP 3A
/// <summary>
// GROUP 3A Group Length (003A;0000) UL 1
/// </summary>
  K_CMDCMTGroup3AGroupLength = $003A0000;

/// <summary>
/// Waveform Originality (003A;0004) CS 1
/// </summary>
  K_CMDCMTWaveformOriginality = $003A0004;

/// <summary>
/// Number of Waveform Channels (003A;0005) US 1
/// </summary>
  K_CMDCMTNumberOfWaveformChannels = $003A0005;

/// <summary>
/// Number of Waveform Samples (003A;0010) UL 1
/// </summary>
  K_CMDCMTNumberOfWaveformSamples = $003A0010;

/// <summary>
/// Sampling Frequency (003A;001A) DS 1
/// </summary>
  K_CMDCMTSamplingFrequency = $003A001A;

/// <summary>
/// Multiplex Group Label (003A;0020) SH 1
/// </summary>
  K_CMDCMTMultiplexGroupLabel = $003A0020;

/// <summary>
/// Channel Definition Sequence (003A;0200) SQ 1
/// </summary>
  K_CMDCMTChannelDefinitionSequence = $003A0200;

/// <summary>
/// Waveform Channel Number (003A;0202) IS 1
/// </summary>
  K_CMDCMTWaveformChannelNumber = $003A0202;

/// <summary>
/// Channel Label (003A;0203) SH 1
/// </summary>
  K_CMDCMTChannelLabel = $003A0203;

/// <summary>
/// Channel Status (003A;0205) CS 1-n
/// </summary>
  K_CMDCMTChannelStatus = $003A0205;

/// <summary>
/// Channel Source Sequence (003A;0208) SQ 1
/// </summary>
  K_CMDCMTChannelSourceSequence = $003A0208;

/// <summary>
/// Channel Source Modifiers Sequence (003A;0209) SQ 1
/// </summary>
  K_CMDCMTChannelSourceModifiersSequence = $003A0209;

/// <summary>
/// Source Waveform Sequence (003A;020A) SQ 1
/// </summary>
  K_CMDCMTSourceWaveformSequence = $003A020A;

/// <summary>
/// Channel Derivation Description (003A;020C) LO 1
/// </summary>
  K_CMDCMTChannelDerivationDescription = $003A020C;

/// <summary>
/// Channel Sensitivity (003A;0210) DS 1
/// </summary>
  K_CMDCMTChannelSensitivity = $003A0210;

/// <summary>
/// Channel Sensitivity Units Sequence (003A;0211) SQ 1
/// </summary>
  K_CMDCMTChannelSensitivityUnitsSequence = $003A0211;

/// <summary>
/// Channel Sensitivity Correction Factor (003A;0212) DS 1
/// </summary>
  K_CMDCMTChannelSensitivityCorrectionFactor = $003A0212;

/// <summary>
/// Channel Baseline (003A;0213) DS 1
/// </summary>
  K_CMDCMTChannelBaseline = $003A0213;

/// <summary>
/// Channel Time Skew (003A;0214) DS 1
/// </summary>
  K_CMDCMTChannelTimeSkew = $003A0214;

/// <summary>
/// Channel Sample Skew (003A;0215) DS 1
/// </summary>
  K_CMDCMTChannelSampleSkew = $003A0215;

/// <summary>
/// Channel Offset (003A;0218) DS 1
/// </summary>
  K_CMDCMTChannelOffset = $003A0218;

/// <summary>
/// Waveform Bits Stored (003A;021A) US 1
/// </summary>
  K_CMDCMTWaveformBitsStored = $003A021A;

/// <summary>
/// Filter Low Frequency (003A;0220) DS 1
/// </summary>
  K_CMDCMTFilterLowFrequency = $003A0220;

/// <summary>
/// Filter High Frequency (003A;0221) DS 1
/// </summary>
  K_CMDCMTFilterHighFrequency = $003A0221;

/// <summary>
/// Notch Filter Frequency (003A;0222) DS 1
/// </summary>
  K_CMDCMTNotchFilterFrequency = $003A0222;

/// <summary>
/// Notch Filter Bandwidth (003A;0223) DS 1
/// </summary>
  K_CMDCMTNotchFilterBandwidth = $003A0223;

/// <summary>
/// Multiplexed Audio Channels Description Code Sequence (003A;0300) SQ 1
/// </summary>
  K_CMDCMTMultiplexedAudioChannelsDescriptionCodeSequence = $003A0300;

/// <summary>
/// Channel Identification Code (003A;0301) IS 1
/// </summary>
  K_CMDCMTChannelIdentificationCode = $003A0301;

/// <summary>
/// Channel Mode (003A;0302) CS 1
/// </summary>
  K_CMDCMTChannelMode = $003A0302;
    
// GROUP 40
/// <summary>
// GROUP 40 Group Length (0040;0000) UL 1
/// </summary>
  K_CMDCMTGroup40GroupLength = $00400000;

/// <summary>
/// Scheduled Station AE Title (0040;0001) AE 1-n
/// </summary>
  K_CMDCMTScheduledStationAETitle = $00400001;

/// <summary>
/// Scheduled Procedure Step Start Date (0040;0020) DA 1
/// </summary>
  K_CMDCMTScheduledProcedureStepStartDate = $00400002;

/// <summary>
/// Scheduled Procedure Step Start Time (0040;0003) TM 1
/// </summary>
  K_CMDCMTScheduledProcedureStepStartTime = $00400003;

/// <summary>
/// Scheduled Procedure Step End Date (0040;0004) DA 1
/// </summary>
  K_CMDCMTScheduledProcedureStepEndDate = $00400004;

/// <summary>
/// Scheduled Procedure Step End Time (0040;0005) TM 1
/// </summary>
  K_CMDCMTScheduledProcedureStepEndTime = $00400005;

/// <summary>
/// Scheduled Performing Physician's Name (0040;0006) PN 1
/// </summary>
  K_CMDCMTScheduledPerformingPhysiciansName = $00400006;

/// <summary>
/// Scheduled Procedure Step Description (0040;0007) LO 1
/// </summary>
  K_CMDCMTScheduledProcedureStepDescription = $00400007;

/// <summary>
/// Scheduled Protocol Code Sequence (0040;0008) SQ 1
/// </summary>
  K_CMDCMTScheduledProtocolCodeSequence = $00400008;

/// <summary>
/// Scheduled Procedure Step ID (0040;0009) SH 1
/// </summary>
  K_CMDCMTScheduledProcedureStepId = $00400009;

/// <summary>
/// Stage Code Sequence (0040; 000A) SQ 1 
/// </summary>
  K_CMDCMTStageCodeSequence = $0040000A;

/// <summary>
/// Scheduled Performing Physician Identification Sequence (0040;000B) SQ 1
/// </summary>
  K_CMDCMTScheduledPerformingPhysicianIdentificationSequence = $0040000B;

/// <summary>
/// Scheduled Station Name (0040;0010) SH 1-n
/// </summary>
  K_CMDCMTScheduledStationName = $00400010;

/// <summary>
/// Scheduled Procedure Step Location (0040;0011) SH 1
/// </summary>
  K_CMDCMTScheduledProcedureStepLocation = $00400011;

/// <summary>
/// Pre-Medication (0040;0012) LO 1
/// </summary>
  K_CMDCMTPreMedication = $00400012;

/// <summary>
/// Scheduled Porcedure Step Status (0040;0020) CS 1
/// </summary>
  K_CMDCMTScheduledProcedureStepStatus = $00400020;

/// <summary>
/// Scheduled Procedure Step Sequence (0040;0100) SQ 1
/// </summary>
  K_CMDCMTScheduledProcedureStepSequence = $00400100;

/// <summary>
/// Referenced Non-Image Composite SOP Instance Sequence (0040;0220) SQ 1
/// </summary>
  K_CMDCMTReferencedNonImageCompositeSopInstanceSequence = $00400220;

/// <summary>
/// Performed Station AE Title (0040;0241) AE 1
/// </summary>
  K_CMDCMTPerformedStationAETitle = $00400241;

/// <summary>
/// Performed Station Name (0040;0242) SH 1
/// </summary>
  K_CMDCMTPerformedStationName = $00400242;

/// <summary>
/// Performed Location (0040;0243) SH 1
/// </summary>
  K_CMDCMTPerformedLocation = $00400243;

/// <summary>
/// Performed Procedure Step Start Date (0040;0244) DA 1
/// </summary>
  K_CMDCMTPerformedProcedureStepStartDate = $00400244;

/// <summary>
/// Performed Procedure Step Start Time (0040;0245) TM 1
/// </summary>
  K_CMDCMTPerformedProcedureStepStartTime = $00400245;

/// <summary>
/// Performed Procedure Step End Date (0040;0250) DA 1
/// </summary>
  K_CMDCMTPerformedProcedureStepEndDate = $00400250;

/// <summary>
/// Performed Procedure Step End Time (0040;0251) TM 1
/// </summary>
  K_CMDCMTPerformedProcedureStepEndTime = $00400251;

/// <summary>
/// Performed Procedure Step Status (0040;0252) CS 1
/// </summary>
  K_CMDCMTPerformedProcedureStepStatus = $00400252;

/// <summary>
/// Performed Procedure Step ID (0040;0253) SH 1
/// </summary>
  K_CMDCMTPerformedProcedureStepId = $00400253;

/// <summary>
/// Performed Procedure Step Description (0040;0254) LO 1
/// </summary>
  K_CMDCMTPerformedProcedureStepDescription = $00400254;

/// <summary>
/// Performed Procedure Type Description (0040;0255) LO 1
/// </summary>
  K_CMDCMTPerformedProcedureTypeDescription = $00400255;

/// <summary>
/// Performed Protocol Code Sequence (0040;0260) SQ 1
/// </summary>
  K_CMDCMTPerformedProtocolCodeSequence = $00400260;

/// <summary>
/// Scheduled Step Attributes Sequence (0040;0270) SQ 1
/// </summary>
  K_CMDCMTScheduledStepAttributesSequence = $00400270;

/// <summary>
/// Request Attributes Sequence (0040;0275) SQ 1
/// </summary>
  K_CMDCMTRequestAttributesSequence = $00400275;

/// <summary>
/// Comments on the Performed Procedure Step (0040;0280) ST 1
/// </summary>
  K_CMDCMTCommentsOnThePerformedProcedureStep = $00400280;

/// <summary>
/// Performed Procedure Step Discontinuation Reason Code Sequence (0040;0281) SQ 1
/// </summary>
  K_CMDCMTPerformedProcedureStepDiscontinuationReasonCodeSequence = $00400281;

/// <summary>
/// Quantity Sequence (0040;0293) SQ 1
/// </summary>
  K_CMDCMTQuantitySequence = $00400293;

/// <summary>
/// Quantity (0040;0294) DS 1
/// </summary>
  K_CMDCMTQuantity = $00400294;

/// <summary>
/// Measuring Units Sequence (0040;0295) SQ 1
/// </summary>
  K_CMDCMTMeasuringUnitsSequence = $00400295;

/// <summary>
/// Billing Item Sequence (0040;0296) SQ 1
/// </summary>
  K_CMDCMTBillingItemSequence = $00400296;

/// <summary>
/// Total Time of Fluoroscopy (0040;0300) US 1
/// </summary>
  K_CMDCMTTotalTimeOfFluoroscopy = $00400300;

/// <summary>
/// Total Number of Exposures (0040;0301) US 1
/// </summary>
  K_CMDCMTTotalNumberOfExposures = $00400301;

/// <summary>
/// Entrance Dose (0040;0302) US 1
/// </summary>
  K_CMDCMTEntranceDose = $00400302;

/// <summary>
/// Exposed Area (0040;0303) US 1-2
/// </summary>
  K_CMDCMTExposedArea = $00400303;

/// <summary>
/// Distance Source to Entrance (0040;0306) DS 1
/// </summary>
  K_CMDCMTDistanceSourceToEntrance = $00400306;

/// <summary>
/// Distance Source to Support (Retired) (0040;0307) DS 1
/// </summary>
  K_CMDCMTDistanceSourceToSupportRetired = $00400307;

/// <summary>
/// Exposure Dose Sequence (0040;030E) SQ 1
/// </summary>
  K_CMDCMTExposureDoseSequence = $0040030E;

/// <summary>
/// Comments on Radiation Dose (0040;0310) ST 1
/// </summary>
  K_CMDCMTCommentsOnRadiationDose = $00400310;

/// <summary>
/// X-Ray Output (0040;0312) DS 1
/// </summary>
  K_CMDCMTXRayOutput = $00400312;

/// <summary>
/// Half Value Layer (0040;0314) DS 1
/// </summary>
  K_CMDCMTHalfValueLayer = $00400314;

/// <summary>
/// Organ Dose (0040;0316) DS 1
/// </summary>
  K_CMDCMTOrganDose = $00400316;

/// <summary>
/// Organ Exposed (0040;0318) CS 1
/// </summary>
  K_CMDCMTOrganExposed = $00400318;

/// <summary>
/// Billing Procedure Step Sequence (0040;0320) SQ 1
/// </summary>
  K_CMDCMTBillingProcedureStepSequence = $00400320;

/// <summary>
/// Film Consumption Sequence (0040;0321) SQ 1
/// </summary>
  K_CMDCMTFilmConsumptionSequence = $00400321;

/// <summary>
/// Billing Supplies and Devices Sequence (0040;0324) SQ 1
/// </summary>
  K_CMDCMTBillingSuppliesAndDevicesSequence = $00400324;

/// <summary>
/// Referenced Procedure Step Sequence (Retired) (0040;0330) SQ 1
/// </summary>
  K_CMDCMTReferencedProcedureStepSequenceRetired = $00400330;

/// <summary>
/// Performed Series Sequence (0040;0340) SQ 1
/// </summary>
  K_CMDCMTPerformedSeriesSequence = $00400340;

/// <summary>
/// Comments on the Scheduled Procedure Step (0040;0400) LT 1
/// </summary>
  K_CMDCMTCommentsOnTheScheduledProcedureStep = $00400400;

/// <summary>
/// Protocol Context Sequence (0040;0440) SQ 1
/// </summary>
  K_CMDCMTProtocolContextSequence = $00400440;

/// <summary>
/// Content Item Modifier Sequence (0040;0441) SQ 1
/// </summary>
  K_CMDCMTContentItemModifierSequence = $00400441;

/// <summary>
/// Specimen Accession Number (0040;050A) LO 1
/// </summary>
  K_CMDCMTSpecimenAccessionNumber = $0040050A;

/// <summary>
/// Specimen Sequence (0040;0550) SQ 1
/// </summary>
  K_CMDCMTSpecimenSequence = $00400550;

/// <summary>
/// Specimen Identifier(0040;0551) LO 1
/// </summary>
  K_CMDCMTSpecimenIdentifier = $00400551;

/// <summary>
/// Acquisition Context Sequence (0040;0555) SQ 1
/// </summary>
  K_CMDCMTAcquisitionContextSequence = $00400555;

/// <summary>
/// Acquisition Context Description (0040;0556) ST 1
/// </summary>
  K_CMDCMTAcquisitionContextDescription = $00400556;

/// <summary>
/// Original Attribute Sequence (0040;0561) SQ 1
/// </summary>
//OriginalAttributeSequence = $04000561;

/// <summary>
/// Specimen Type Code Sequence (0040;059A) SQ 1
/// </summary>
  K_CMDCMTSpecimenTypeCodeSequence = $0040059A;

/// <summary>
/// Slide Identifier (0040;06FA) LO 1
/// </summary>
  K_CMDCMTSlideIdentifier = $004006FA;

/// <summary>
/// Image Center Point coordinates Sequence (0040;071A) SQ 1
/// </summary>
  K_CMDCMTImageCenterPointCoordinatesSequence = $0040071A;

/// <summary>
/// X offset in Slide Coordinate System (0040;072A) DS 1
/// </summary>
  K_CMDCMTXOffsetInSlideCoordinateSystem = $0040072A;

/// <summary>
/// Y offset in Slide Coordinate System (0040;073A) DS 1
/// </summary>
  K_CMDCMTYOffsetInSlideCoordinateSystem = $0040073A;

/// <summary>
/// Z offset in Slide Coordinate System (0040;074A) DS 1
/// </summary>
  K_CMDCMTZOffsetInSlideCoordinateSystem = $0040074A;

/// <summary>
/// Pixel Spacing Sequence (0040;08D8)
/// </summary>
  K_CMDCMTPixelSpacingSequence = $004008D8;

/// <summary>
/// Coordinate System Axis Code Sequence (0040;08DA) SQ 1
/// </summary>
  K_CMDCMTCoordinateSystemAxisCodeSequence = $004008DA;

/// <summary>
/// Measurement Units Code Sequence (0040;08EA) SQ 1
/// </summary>
  K_CMDCMTMeasurementUnitsCodeSequence = $004008EA;

/// <summary>
/// Requested Procedure ID (0040;1001) SH 1
/// </summary>
  K_CMDCMTRequestedProcedureId = $00401001;

/// <summary>
/// Reason for the Requested Procedure (0040;1002) LO 1
/// </summary>
  K_CMDCMTReasonForTheRequestedProcedure = $00401002;

/// <summary>
/// Requested Procedure Priority (0040;1003) SH 1
/// </summary>
  K_CMDCMTRequestedProcedurePriority = $00401003;

/// <summary>
/// Patient Transport Arrangements (0040;1004) LO 1
/// </summary>
  K_CMDCMTPatientTransportArrangements = $00401004;

/// <summary>
/// Requested Procedure Location (0040;1005) LO 1
/// </summary>
  K_CMDCMTRequestedProcedureLocaton = $00401005;

/// <summary>
/// Place Order Number/Procedure (Retired) 0040;1006) SH 1
/// </summary>
  K_CMDCMTPlaceOrderNumberProcedureRetired = $00401006;

/// <summary>
/// Filler Order Number/Procedure (Retired) 0040;1007) SH 1
/// </summary>
  K_CMDCMTFillerOrderNumberProcedureRetired = $00401007;

/// <summary>
/// Confidentiality Code (0040;1008) LO 1
/// </summary>
  K_CMDCMTConfidentialityCode = $00401008;

/// <summary>
/// Reporting Priority (0040;1009) SH 1
/// </summary>
  K_CMDCMTReportingPriority = $00401009;

/// <summary>
/// Reason for Requested Procedure Code Sequence (0040;100A) SQ 1
/// </summary>
  K_CMDCMTReasonForRequestedProcedureCodeSequence = $0040100A;

/// <summary>
/// Names of Intended Recipients of Results (0040;1010) PN 1-n
/// </summary>
  K_CMDCMTNamesOfIntendedRecipientsOfResults = $00401010;

/// <summary>
/// Intended Recipients of Results Identification Sequence (0040;1011) SQ 1
/// </summary>
  K_CMDCMTIntendedRecipientsOfResultsIdentificationSequence = $00401011;

/// <summary>
/// Person Identificaiton Code Sequence (0040;1101) SQ 1
/// </summary>
  K_CMDCMTPersonIdentificationCodeSequence = $00401101;

/// <summary>
/// Person's Address (0040;1102) ST 1
/// </summary>
  K_CMDCMTPersonsAddress = $00401102;

/// <summary>
/// Person's Telephone Numbers (0040;1103) LO 1-n
/// </summary>
  K_CMDCMTPersonsTelephoneNumbers = $00401103;

/// <summary>
/// Requested Procedure Comments (0040;1400) LT 1
/// </summary>
  K_CMDCMTRequestedProcedureComments = $00401400;

/// <summary>
/// Reason for the Imaging Service Request (Retired) (0040;2001) LO 1
/// </summary>
  K_CMDCMTReasonForTheImagingServiceRequestRetired = $00402001;

/// <summary>
/// Issue Date of Imaging Service Request (0040;2004) DA 1
/// </summary>
  K_CMDCMTIssueDateOfImagingServiceRequest = $00402004;

/// <summary>
/// Issue Time of Imaging Service Request (0040;2005) TM 1
/// </summary>
  K_CMDCMTIssueTimeOfImagingServiceRequest = $00402005;

/// <summary>
/// Placer Order Number Imaging Service Request (Retired) (0040;2006) SH 1 
/// </summary>
  K_CMDCMTPlacerOrderNumberImagingServiceRequestRetired = $00402006;

/// <summary>
/// Filler Order Number Imaging Service Request (Retired) (0040;2007) SH 1
/// </summary>
  K_CMDCMTFillerOrderNumberImagingServiceRequestRetired = $00402007;

/// <summary>
/// Order Entered By (0040;2008) PN 1
/// </summary>
  K_CMDCMTOrderEnteredBy = $00402008;

/// <summary>
/// Order Enterer's Location (0040;2009) SH 1
/// </summary>
  K_CMDCMTOrderEnterersLocation = $00402009;

/// <summary>
/// Order Callback Phone Number (0040;2010) SH 1
/// </summary>
  K_CMDCMTOrderCallbackPhoneNumber = $00402010;

/// <summary>
/// Placer Order Number Imaging Service Request (0040;2016) LO 1
/// </summary>
  K_CMDCMTPlacerOrderNumberImagingServiceRequest = $00402016;

/// <summary>
/// Filler Order Number Imaging Service Request (0040;2017) LO 1
/// </summary>
  K_CMDCMTFillerOrderNumberImagingServiceRequest = $00402017;

/// <summary>
/// Imaging Service Request Comments (0040;2400) LT 1
/// </summary>
  K_CMDCMTImagingServiceRequestComments = $00402400;

/// <summary>
/// Confidentiality Constraint on Paitent Data Description (0040;3001) LO 1
/// </summary>
  K_CMDCMTConfidentialityConstraintOnPatientDataDescription = $00403001;

/// <summary>
/// General Purpose Scheduled Procedure Step Status (0040;4001) CS 1
/// </summary>
  K_CMDCMTGeneralPurposeScheduledProcedureStepStatus = $00404001;

/// <summary>
/// General Purpose Performed Procedure Step Status (0040;4002) CS 1
/// </summary>
  K_CMDCMTGeneralPurposePerformedProcedureStepStatus = $00404002;

/// <summary>
/// General Purpose Scheduled Procedure Step Priority (0040;4003) CS 1
/// </summary>
  K_CMDCMTGeneralPurposeScheduledProcedureStepPriority = $00404003;

/// <summary>
/// Scheduled Processing Applications Code Sequence (0040;4004) SQ 1
/// </summary>
  K_CMDCMTScheduledProcessingApplicationsCodeSequence = $00404004;

/// <summary>
/// Scheduled Procedure Step Start Date and Time (0040;4005) DT 1
/// </summary>
  K_CMDCMTScheduledProcedureStepStartDateTime = $00404005;

/// <summary>
/// Multiple Copies Flag (0040;4006) CS 1
/// </summary>
  K_CMDCMTMultipleCopiesFlag = $00404006;

/// <summary>
/// Performed Processing Applications Code Sequence (0040;4007) SQ 1
/// </summary>
  K_CMDCMTPerformedProcessingApplicationsCodeSequence = $00404007;

/// <summary>
/// Human Performer Code Sequence (0040;4009) SQ 1
/// </summary>
  K_CMDCMTHumanPerformerCodeSequence = $00404009;

/// <summary>
/// Scheduled Procedure Step Modification Date and Time (0040;4010) DT 1
/// </summary>
  K_CMDCMTScheduledProcedureStepModificationDateTime = $00404010;

/// <summary>
/// Expected Completion Date and Time (0040;4011) DT 1
/// </summary>
  K_CMDCMTExpectedCompletionDateTime = $00404011;

/// <summary>
/// Resulting General Purpose Performed Procedure Steps Sequence (0040;4015) SQ 1
/// </summary>
  K_CMDCMTResultingGeneralPurposePerformedProcedureStepsSequence = $00404015;

/// <summary>
/// Referenced General Purpose Scheduled Procedure Step Sequence (0040;4016) SQ 1
/// </summary>
  K_CMDCMTReferencedGeneralPurposeScheduledProcedureStepSequence = $00404016;

/// <summary>
/// Scheduled Workitem Code Sequence (0040;4018) SQ 1
/// </summary>
  K_CMDCMTScheduledWorkitemCodeSequence = $00404018;

/// <summary>
/// Performed Workitem Code Sequence (0040;4019) SQ 1
/// </summary>
  K_CMDCMTPerformedWorkitemCodeSequence = $00404019;

/// <summary>
/// Input Availability Flag (0040;4020) CS 1
/// </summary>
  K_CMDCMTInputAvailabilityFlag = $00404020;

/// <summary>
/// Input Information Sequence (0040;4021) SQ 1
/// </summary>
  K_CMDCMTInputInformationSequence = $00404021;

/// <summary>
/// Relevant Information Sequence (0040;4022) SQ 1
/// </summary>
  K_CMDCMTRelevantInformationSequence = $00404022;

/// <summary>
/// Referenced General Purpose Scheduled Procedure Step Transaction UID (0040;4023) UI 1
/// </summary>
  K_CMDCMTReferencedGeneralPurposeScheduledProcedureStepTransactionUid = $00404023;

/// <summary>
/// Scheduled Station Name Code Sequence (0040;4025) SQ 1
/// </summary>
  K_CMDCMTScheduledStationNameCodeSequence = $00404025;

/// <summary>
/// Scheduled Station Class Code Sequence (0040;4026) SQ 1
/// </summary>
  K_CMDCMTScheduledStationClassCodeSequence = $00404026;

/// <summary>
/// Scheduled Station Geographic Location Code Sequence (0040;4027) SQ 1
/// </summary>
  K_CMDCMTScheduledStationGeographicLocationCodeSequence = $00404027;

/// <summary>
/// Performed Station Name Code Sequence (0040;4028) SQ 1
/// </summary>
  K_CMDCMTPerformedStationNameCodeSequence = $00404028;

/// <summary>
/// Performed Station Class Code Sequence (0040;4029) SQ 1
/// </summary>
  K_CMDCMTPerformedStationClassCodeSequence = $00404029;

/// <summary>
/// Performed Station Geographic Location Code Sequence (0040;4030) SQ 1
/// </summary>
  K_CMDCMTPerformedStationGeographicLocationCodeSequence = $00404030;

/// <summary>
/// Requested Subsequent Workitem Code Sequence (0040;4031) SQ 1
/// </summary>
  K_CMDCMTRequestedSubsequentWorkitemCodeSequence = $00404031;

/// <summary>
/// Non-DICOM Output Code Sequence (0040;4032) SQ 1
/// </summary>
  K_CMDCMTNonDicomOutputCodeSequence = $00404032;

/// <summary>
/// Output Information Sequence (0040;4033) SQ 1
/// </summary>
  K_CMDCMTOutputInformationSequence = $00404033;

/// <summary>
/// Scheduled Human Performers Sequence (0040;4034) SQ 1
/// </summary>
  K_CMDCMTScheduledHumanPerformersSequence = $00404034;

/// <summary>
/// Actual Human Performers Sequence (0040;4035) SQ 1
/// </summary>
  K_CMDCMTActualHumanPerformersSequence = $00404035;

/// <summary>
/// Human Performer's Organization (0040;4036) LO 1
/// </summary>
  K_CMDCMTHumanPerformersOrganization = $00404036;

/// <summary>
/// Human Performer's Name (0040;4037) PN 1
/// </summary>
  K_CMDCMTHumanPerformersName = $00404037;

/// <summary>
/// Entrance Dose in mGy (0040;8302) DS 1
/// </summary>
  K_CMDCMTEntranceDoseInMgy = $00408302;

/// <summary>
/// Referenced Image Real World Value Mapping Sequence (0040;9094) SQ 1
/// </summary>
  K_CMDCMTReferencedImageRealWorldValueMappingSequence = $00409094;

/// <summary>
/// Real World Value Mapping Sequence (0040;9096) SQ 1
/// </summary>
  K_CMDCMTRealWorldValueMappingSequence = $00409096;

/// <summary>
/// Pixel Value Mapping Code Sequence (0040;9098) SQ 1
/// </summary>
  K_CMDCMTPixelValueMappingCodeSequence = $00409098;

/// <summary>
/// LUT Label (0040;9210) SH 1
/// </summary>
  K_CMDCMTLutLabel = $00409210;

/// <summary>
/// Real World Value Last Value Mapped (0040;9211) US or SS 1
/// </summary>
  K_CMDCMTRealWorldValueLastValueMapped = $00409211;

/// <summary>
/// Real World Value LUT Data (0040;9212) FD 1-n
/// </summary>
  K_CMDCMTRealWorldValueLutData = $00409212;

/// <summary>
/// Real World Value First Value Mapped (0040;9216) US or SS 1
/// </summary>
  K_CMDCMTRealWorldValueFirstValueMapped = $00409216;

/// <summary>
/// Real World Value Intercept (0040;9224) FD 1
/// </summary>
  K_CMDCMTRealWorldValueIntercept = $00409224;

/// <summary>
/// Real World Value Slope (0040;9225) FD 1
/// </summary>
  K_CMDCMTRealWorldValueSlope = $00409225;

/// <summary>
/// Relationship Type (0040;A010) CS 1
/// </summary>
  K_CMDCMTRelationshipType = $0040A010;

/// <summary>
/// Verifying Organization (0040;A027) LO 1
/// </summary>
  K_CMDCMTVerifyingOrganization = $0040A027;

/// <summary>
/// Verification Date Time (0040;A030) DT 1
/// </summary>
  K_CMDCMTVerificationDateTime = $0040A030;

/// <summary>
/// Observation Date Time (0040;A032) DT 1
/// </summary>
  K_CMDCMTObservationDateTime = $0040A032;

/// <summary>
/// Value Type (0040;A040) CS 1
/// </summary>
  K_CMDCMTValueTypes = $0040A040;

/// <summary>
/// Concept Name Code Sequence (0040;A043) SQ 1
/// </summary>
  K_CMDCMTConceptNameCodeSequence = $0040A043;

/// <summary>
/// Continuity Of Content (0040;A050) CS 1
/// </summary>
  K_CMDCMTContinuityOfContent = $0040A050;

/// <summary>
/// Verifying Observer Sequence (0040;A073) SQ 1
/// </summary>
  K_CMDCMTVerifyingObserverSequence = $0040A073;

/// <summary>
/// Verifying Observers Name (004;A075) PN 1
/// </summary>
  K_CMDCMTVerifyingObserverName = $0040A075;

/// <summary>
/// Author Observer Sequence (0040;A078) SQ 1
/// </summary>
  K_CMDCMTAuthorObserverSequence = $0040A078;

/// <summary>
/// Participant Sequence (0040;A07A) SQ 1
/// </summary>
  K_CMDCMTParticipantSequence = $0040A07A;

/// <summary>
/// Custodial Organization Sequence (0040;A07C) SQ 1
/// </summary>
  K_CMDCMTCustodialOrganizationSequence = $0040A07C;

/// <summary>
/// Participation Type (0040;A080) CS 1
/// </summary>
  K_CMDCMTParticipationType = $0040A080;

/// <summary>
/// Participation Datetime (0040;A082) DT 1
/// </summary>
  K_CMDCMTParticipationDatetime = $0040A082;

/// <summary>
/// Observer Type (0040;A084) CS 1
/// </summary>
  K_CMDCMTObserverType = $0040A084;

/// <summary>
/// Verifying Observer Identificaiton Code Sequence (0040;A088) SQ 1
/// </summary>
  K_CMDCMTVerifyingObserverIdentificationCodeSequence = $0040A088;

/// <summary>
/// Equivalent CDA Document Sequence (0040;A090) SQ 1
/// </summary>
  K_CMDCMTEquivalentCDADocumentSequence = $0040A090;

/// <summary>
/// Referenced Waveform Channels (0040;A0B0) US 2-2n
/// </summary>
  K_CMDCMTReferencedWaveformChannels = $0040A0B0;

/// <summary>
/// DateTime (0040;A120) DT 1
/// </summary>
  K_CMDCMTDateTime = $0040A120;

/// <summary>
/// Date (0040;A121) DA 1
/// </summary>
  K_CMDCMTDate = $0040A121;

/// <summary>
/// Time (0040;A122) TM 1
/// </summary>
  K_CMDCMTTime = $0040A122;

/// <summary>
/// Person Name (0040;A123) PN 1
/// </summary>
  K_CMDCMTPersonName = $0040A123;

/// <summary>
/// UID (0040;A124) UI 1
/// </summary>
  K_CMDCMTUid = $0040A124;

/// <summary>
/// Temporal Range Type (0040;A130) CS 1
/// </summary>
  K_CMDCMTTemporalRangeType = $0040A130;

/// <summary>
/// Referenced Sample Positions (0040;A132) UL 1-n
/// </summary>
  K_CMDCMTReferencedSamplePositions = $0040A132;

/// <summary>
/// Referenced Frame Numbers (0040;A136) US 1-n
/// </summary>
  K_CMDCMTReferencedFrameNumbers = $0040A136;

/// <summary>
/// Referenced Time Offsets (0040;A138) DS 1-n
/// </summary>
  K_CMDCMTReferencedTimeOffsets = $0040A138;

/// <summary>
/// Referenced Datetime (0040;A13A) DT 1-n
/// </summary>
  K_CMDCMTReferencedDateTime = $0040A13A;

/// <summary>
/// Text Value (0040;A160) UT 1
/// </summary>
  K_CMDCMTTextValue = $0040A160;

/// <summary>
/// Concept Code Sequence (0040;A168) SQ 1
/// </summary>
  K_CMDCMTConceptCodeSequence = $0040A168;

/// <summary>
/// Purpose of Reference Code Sequence (0040;A170) SQ
/// </summary>
  K_CMDCMTPurposeOfReferenceCodeSequence = $0040A170;

/// <summary>
/// Annotation Group Number (0040;A180) US 1
/// </summary>
  K_CMDCMTAnnotationGroupNumber = $0040A180;

/// <summary>
/// Modifier Code Sequence (0040;A195) SQ 1
/// </summary>
  K_CMDCMTModifierCodeSequence = $0040A195;

/// <summary>
/// Measured Value Sequence (0040;A300) SQ 1
/// </summary>
  K_CMDCMTMeasuredValueSequence = $0040A300;

/// <summary>
/// Numeric Value Qualifier Code Sequence (0040;A301) SQ 1
/// </summary>
  K_CMDCMTNumericValueQualifierCodeSequence = $0040A301;

/// <summary>
/// Numeric Value (0040;A30A) DS 1-n
/// </summary>
  K_CMDCMTNumericValue = $0040A30A;

/// <summary>
/// Predecessor_Documents Sequence (0040;A360) SQ 1
/// </summary>
  K_CMDCMTPredecessorDocumentsSequence = $0040A360;

/// <summary>
/// Referenced Request Sequence (0040;A370) SQ 1
/// </summary>
  K_CMDCMTReferencedRequestSequence = $0040A370;

/// <summary>
/// Performed Procedure Code Sequence (0040;A372) SQ 1
/// </summary>
  K_CMDCMTPerformedProcedureCodeSequence = $0040A372;

/// <summary>
/// Current Requested Procedure Evidence Sequence (0040;A375) SQ 1
/// </summary>
  K_CMDCMTCurrentRequestedProcedureEvidenceSequence = $0040A375;

/// <summary>
/// Pertinent Other Evidence Sequence (0040;A386) SQ 1
/// </summary>
  K_CMDCMTPertinentOtherEvidenceSequence = $0040A385;

/// <summary>
/// HL7 Structured Document Reference Sequence (0040;A390) SQ 1
/// </summary>
  K_CMDCMTHL7StructuredDocumentReferenceSequence = $0040A390;

/// <summary>
/// Completion Flag (0040;A491) CS 1
/// </summary>
  K_CMDCMTCompletionFlag = $0040A491;

/// <summary>
/// Completion Flag Description (0040;A492) LO 1
/// </summary>
  K_CMDCMTCompletionFlagDescription = $0040A492;

/// <summary>
/// Verification Flag (0040;A493) CS 1
/// </summary>
  K_CMDCMTVerificationFlag = $0040A493;

/// <summary>
/// Content Template Sequence (0040;A504) SQ 1
/// </summary>
  K_CMDCMTContentTemplateSequence = $0040A504;

/// <summary>
/// Identical Documents Sequence (0040;A525) SQ 1
/// </summary>
  K_CMDCMTIdenticalDocumentsSequence = $0040A525;

/// <summary>
/// Content Sequence (0040;A730) SQ 1
/// </summary>
  K_CMDCMTContentSequence = $0040A730;

/// <summary>
/// Annotation Sequence (0040;B020) SQ 1
/// </summary>
  K_CMDCMTAnnotationSequence = $0040B020;

/// <summary>
/// Template Identifier (0040;DB00) CS 1
/// </summary>
  K_CMDCMTTemplateIdentifier = $0040DB00;

/// <summary>
/// Template Version (Retired) (0040;DB06) DT 1
/// </summary>
  K_CMDCMTTemplateVersionRetired = $0040DB06;

/// <summary>
/// Template Local Version (Retired) (0040;DB07) DT 1
/// </summary>
  K_CMDCMTTemplateLocalVersionRetired = $0040DB07;

/// <summary>
/// Template Extension Flag (Retired) (0040;DB0B) CS 1
/// </summary>
  K_CMDCMTTemplateExtensionFlagRetired = $0040DB0B;

/// <summary>
/// Template Extension Organization UID (Retired) (0040;DB0C) UI 1
/// </summary>
  K_CMDCMTTemplateExtensionOrganizationUidRetired = $0040DB0C;

/// <summary>
/// Template Extension Creator UID (Retired) (0040;DB0D) UI 1
/// </summary>
  K_CMDCMTTemplateExtensionCreatorUidRetired = $0040DB0D;

/// <summary>
/// Referenced Content Item Identifier (0040;DB73) UL 1-n
/// </summary>
  K_CMDCMTReferencedContentItemIdentifier = $0040DB73;

/// <summary>
/// HL7 Instance Identifier (0040;E001) ST 1
/// </summary>
  K_CMDCMTHL7InstanceIdentifier = $0040E001;

/// <summary>
/// HL7 Document Effective Time (0040;E004) DT 1
/// </summary>
  K_CMDCMTHL7DocumentEffectiveTime = $0040E004;

/// <summary>
/// HL7 Document Type Code Sequence (0040;E006) SQ 1
/// </summary>
  K_CMDCMTHL7DocumentTypeCodeSequence = $0040E006;

/// <summary>
/// Retrieve URI (0040;E010) UT 1
/// </summary>
  K_CMDCMTRetrieveURI = $0040E010;
    
// GROUP 42
/// <summary>
/// Document Title (0042;0010) ST 1
/// </summary>
  K_CMDCMTDocumentTitle = $00420010;

/// <summary>
/// Encapsulated Document (0042;0011) OB 1
/// </summary>
  K_CMDCMTEncapsulatedDocument = $00420011;

/// <summary>
/// MIME Type of Encapsulated Document (0042;0012) LO 1
/// </summary>
  K_CMDCMTMIMETypeOfEncapsulatedDocument = $00420012;

/// <summary>
/// Source Instance Sequence (0042;0013) SQ 1
/// </summary>
  K_CMDCMTSourceInstanceSequence = $00420013;
    
// GROUP 50
/// <summary>
// GROUP 50 Group Length (0050;0000) UL 1
/// </summary>
  K_CMDCMTGroup50GroupLength = $00500000;

/// <summary>
/// Calibration Image (0050;0004) CS 1
/// </summary>
  K_CMDCMTCalibrationImage = $00500004;

/// <summary>
/// Device Sequence (0050;0010) SQ 1
/// </summary>
  K_CMDCMTDeviceSequence = $00500010;

/// <summary>
/// Device Length (0050;0014) DS 1
/// </summary>
  K_CMDCMTDeviceLength = $00500014;

/// <summary>
/// Device Diameter (0050;0016) DS 1
/// </summary>
  K_CMDCMTDeviceDiameter = $00500016;

/// <summary>
/// Device Diameter Units (0050;0017) CS 1
/// </summary>
  K_CMDCMTDeviceDiameterUnits = $00500017;

/// <summary>
/// Device Volume (0050;0018) DS 1
/// </summary>
  K_CMDCMTDeviceVolume = $00500018;

/// <summary>
/// Inter-marker Distance (0050;0019) DS 1
/// </summary>
  K_CMDCMTInterMarkerDistance = $00500019;

/// <summary>
/// Device Description (0050;0020) LO 1
/// </summary>
  K_CMDCMTDeviceDescription = $00500020;

// GROUP 54
/// <summary>
// GROUP 54 Group Length (0054;0000) UL 1
/// </summary>
  K_CMDCMTGroup54GroupLength = $00540000;

/// <summary>
/// Energy Window Vector (0054;0010) US 1-n
/// </summary>
  K_CMDCMTEnergyWindowVector = $00540010;

/// <summary>
/// Number of Energy Windows (0054;0011) US 1
/// </summary>
  K_CMDCMTNumberOfEnergyWindows = $00540011;

/// <summary>
/// Energy Window Information Sequence (0054;0012) SQ 1
/// </summary>
  K_CMDCMTEnergyWindowInformationSequence = $00540012;

/// <summary>
/// Energy Window Range Sequence (0054;0013) SQ 1
/// </summary>
  K_CMDCMTEnergyWindowRangeSequence = $00540013;

/// <summary>
/// Energy Window Lower Limit (0054;0014) DS 1
/// </summary>
  K_CMDCMTEnergyWindowLowerLimit = $00540014;

/// <summary>
/// Energy Window Upper Limit (0054;0015) DS 1
/// </summary>
  K_CMDCMTEnergyWindowUpperLimit = $00540015;

/// <summary>
/// Radiopharmaceutical Information Sequence (0054;0016) SQ 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalInformationSequence = $00540016;

/// <summary>
/// Residual Syringe Counts (0054;0017) IS 1
/// </summary>
  K_CMDCMTResidualSyringeCounts = $00540017;

/// <summary>
/// Energy Window Name (0054;0018) SH 1
/// </summary>
  K_CMDCMTEnergyWindowName = $00540018;

/// <summary>
/// Detector Vector (0054;0020) US 1-n
/// </summary>
  K_CMDCMTDetectorVector = $00540020;

/// <summary>
/// Number of Detectors (0054;0021) US 1
/// </summary>
  K_CMDCMTNumberOfDetectors = $00540021;

/// <summary>
/// Detector Informaiton Sequence (0054;0022) SQ 1
/// </summary>
  K_CMDCMTDetectorInformationSequence = $00540022;

/// <summary>
/// Phase Vector (0054;0030) US 1-n
/// </summary>
  K_CMDCMTPhaseVector = $00540030;

/// <summary>
/// Number of Phases (0054;0031) US 1
/// </summary>
  K_CMDCMTNumberOfPhases = $00540031;

/// <summary>
/// Phase Information Sequence (0054;0032) SQ 1
/// </summary>
  K_CMDCMTPhaseInformationSequence = $00540032;

/// <summary>
/// Number of Frames in Phase (0054;0033) US 1
/// </summary>
  K_CMDCMTNumberOfFramesInPhase = $00540033;

/// <summary>
/// Phase Delay (0054;0036) IS 1
/// </summary>
  K_CMDCMTPhaseDelay = $00540036;

/// <summary>
/// Pause Between Frames (0054;0038) IS 1
/// </summary>
  K_CMDCMTPauseBetweenFrames = $00540038;

/// <summary>
/// Phase Description (0054;0039) CS 1
/// </summary>
  K_CMDCMTPhaseDescription = $00540039;

/// <summary>
/// Rotation Vector (0054;0050) US 1-n
/// </summary>
  K_CMDCMTRotationVector = $00540050;

/// <summary>
/// Number of Rotations (0054;0051) US 1
/// </summary>
  K_CMDCMTNumberOfRotations = $00540051;

/// <summary>
/// Rotation Information Sequence (0054;0052) SQ 1
/// </summary>
  K_CMDCMTRotationInformationSequence = $00540052;

/// <summary>
/// Number of Frames in Rotation (0054;0053) US 1
/// </summary>
  K_CMDCMTNumberOfFramesInRotation = $00540053;

/// <summary>
/// R-R Interval Vector (0054;0060) US 1-n
/// </summary>
  K_CMDCMTRRIntervalVector = $00540060;

/// <summary>
/// Number of R-R Intervals (0054;0061) US 1
/// </summary>
  K_CMDCMTNumberOfRRIntervals = $00540061;

/// <summary>
/// Gated Informaiton Sequence (0054;0062) SQ 1
/// </summary>
  K_CMDCMTGatedInformationSequence = $00540062;

/// <summary>
/// Data Informaiton Sequence (0054;0063) SQ 1
/// </summary>
  K_CMDCMTDataInformationSequence = $00540063;

/// <summary>
/// Time Slot Vector (0054;0070) US 1-n
/// </summary>
  K_CMDCMTTimeSlotVector = $00540070;

/// <summary>
/// Number of Time Slots (0054;0071) US 1
/// </summary>
  K_CMDCMTNumberOfTimeSlots = $00540071;

/// <summary>
/// Time Slot Information Sequence (0054;0072) SQ 1
/// </summary>
  K_CMDCMTTimeSlotInformationSequence = $00540072;

/// <summary>
/// Time Slot Time (0054;0073) DS 1
/// </summary>
  K_CMDCMTTimeSlotTime = $00540073;

/// <summary>
/// Slice Vector (0054;0080) US 1-n
/// </summary>
  K_CMDCMTSliceVector = $00540080;

/// <summary>
/// Number of Slices (0054;0081) US 1
/// </summary>
  K_CMDCMTNumberOfSlices = $00540081;

/// <summary>
/// Angular View Vector (0054;0090) US 1-n
/// </summary>
  K_CMDCMTAngularViewVector = $00540090;

/// <summary>
/// Time Slice Vector (0054;0100) US 1-n
/// </summary>
  K_CMDCMTTimeSliceVector = $00540100;

/// <summary>
/// Number of Time Slices (0054;0101) US 1
/// </summary>
  K_CMDCMTNumberOfTimeSlices = $00540101;

/// <summary>
/// Start Angle (0054;0200) DS 1
/// </summary>
  K_CMDCMTStartAngle = $00540200;

/// <summary>
/// Type of Detector Motion (0054;0202) CS 1
/// </summary>
  K_CMDCMTTypeOfDetectorMotion = $00540202;

/// <summary>
/// Trigger Vector (0054;0210) IS 1-n
/// </summary>
  K_CMDCMTTriggerVector = $00540210;

/// <summary>
/// Number of Triggers in Phase (0054;0211) US 1
/// </summary>
  K_CMDCMTNumberOfTriggersInPhase = $00540211;

/// <summary>
/// View Code Sequence (0054;0220) SQ 1
/// </summary>
  K_CMDCMTViewCodeSequence = $00540220;

/// <summary>
/// View Modifier Code Sequence (0054;0222) SQ 1
/// </summary>
  K_CMDCMTViewModifierCodeSequence = $00540222;

/// <summary>
/// Radionuclide Code Sequence (0054;0300) SQ 1
/// </summary>
  K_CMDCMTRadionuclideCodeSequence = $00540300;

/// <summary>
/// Administration Route Code Sequence (0054;0302) SQ 1
/// </summary>
  K_CMDCMTAdministrationRouteCodeSequence = $00540302;

/// <summary>
/// Radiopharmaceutical Code Sequence (0054;0304) SQ 1
/// </summary>
  K_CMDCMTRadiopharmaceuticalCodeSequence = $00540304;

/// <summary>
/// Calibration Data Sequence (0054;0306) SQ 1
/// </summary>
  K_CMDCMTCalibrationDataSequence = $00540306;

/// <summary>
/// Energy Window Number (0054;0308) US 1
/// </summary>
  K_CMDCMTEnergyWindowNumber = $00540308;

/// <summary>
/// Image ID (0054;0400) SH 1
/// </summary>
  K_CMDCMTImageId = $00540400;

/// <summary>
/// Patient Orientation Code Sequence (0054;0410) SQ 1
/// </summary>
  K_CMDCMTPatientOrientationCodeSequence = $00540410;

/// <summary>
/// Patient Orientation Modifier Code Sequence (0054;0412) SQ 1
/// </summary>
  K_CMDCMTPatientOrientationModifierCodeSequence = $00540412;

/// <summary>
/// Patient Gantry Relationship Code Sequence (0054;0414) SQ 1
/// </summary>
  K_CMDCMTPatientGantryRelationshipCodeSequence = $00540414;

/// <summary>
/// Slice Progression Direction (0054;0500) CS 1
/// </summary>
  K_CMDCMTSliceProgressionDirection = $00540500;

/// <summary>
/// Series Type (0054;1000) CS 2
/// </summary>
  K_CMDCMTSeriesType = $00541000;

/// <summary>
/// Units (0054;1001) CS 1
/// </summary>
  K_CMDCMTUnits = $00541001;

/// <summary>
/// Counts Source (0054;1002) CS 1
/// </summary>
  K_CMDCMTCountsSource = $00541002;

/// <summary>
/// Reprojection Method (0054;1004) CS 1
/// </summary>
  K_CMDCMTReprojectionMethod = $00541004;

/// <summary>
/// Randoms Correction Method (0054;1100) CS 1
/// </summary>
  K_CMDCMTRandomsCorrectionMethod = $00541100;

/// <summary>
/// Attenuation Correction Method (0054;1101) LO 1
/// </summary>
  K_CMDCMTAttenuationCorrectionMethod = $00541101;

/// <summary>
/// Decay Correction (0054;1102) CS 1
/// </summary>
  K_CMDCMTDecayCorrection = $00541102;

/// <summary>
/// Reconstruction Method (0054;1103) LO 1
/// </summary>
  K_CMDCMTReconstructionMethod = $00541103;

/// <summary>
/// Detector Lines of Response Used (0054;1104) LO 1
/// </summary>
  K_CMDCMTDetectorLinesOfResponseUsed = $00541104;

/// <summary>
/// Scatter Correction Method (0054;1105) LO 1
/// </summary>
  K_CMDCMTScatterCorrectionMethod = $00541105;

/// <summary>
/// Axial Acceptance (0054;1200) DS 1
/// </summary>
  K_CMDCMTAxialAcceptance = $00541200;

/// <summary>
/// Axial Mash (0054;1201) IS 2
/// </summary>
  K_CMDCMTAxialMash = $00541201;

/// <summary>
/// Transverse Mash (0054;1202) IS 1
/// </summary>
  K_CMDCMTTransverseMash = $00541202;

/// <summary>
/// Detector Element Size (0054;1203) DS 2
/// </summary>
  K_CMDCMTDetectorElementSize = $00541203;

/// <summary>
/// Coincidence Window Width (0054;1210) DS 1
/// </summary>
  K_CMDCMTCoincidenceWindowWidth = $00541210;

/// <summary>
/// Secondary Counts Type (0054;1220) CS 1-n
/// </summary>
  K_CMDCMTSecondaryCountsType = $00541220;

/// <summary>
/// Frame Reference Time (0054;1300) DS 1
/// </summary>
  K_CMDCMTFrameReferenceTime = $00541300;

/// <summary>
/// Primary (Prompts) Counts ACCUMULATED (0054;1310) IS 1
/// </summary>
  K_CMDCMTPrimaryPromptsCountsAccumulated = $00541310;

/// <summary>
/// Secondary Counts Accumulated (0054;1311) IS 1-n
/// </summary>
  K_CMDCMTSecondaryCountsAccumulated = $00541311;

/// <summary>
/// Slice Sensitivity Factor (0054;1320) DS 1
/// </summary>
  K_CMDCMTSliceSensitivityFactor = $00541320;

/// <summary>
/// Decay Factor (0054;1321) DS 1
/// </summary>
  K_CMDCMTDecayFactor = $00541321;

/// <summary>
/// Dose Calibration Factor (0054;1322) DS 1
/// </summary>
  K_CMDCMTDoseCalibrationFactor = $00541322;

/// <summary>
/// Scatter Fraction Factor (0054;1323) DS 1
/// </summary>
  K_CMDCMTScatterFractionFactor = $00541323;

/// <summary>
/// Dead Time Factor (0054;1324) DS 1
/// </summary>
  K_CMDCMTDeadTimeFactor = $00541324;

/// <summary>
/// Image Index (0054;1330) US 1
/// </summary>
  K_CMDCMTImageIndex = $00541330;

/// <summary>
/// Counts Included (0054;1400) CS 1-n
/// </summary>
  K_CMDCMTCountsIncluded = $00541400;

/// <summary>
/// Dead Time Correction Flag (0054;1401) CS 1
/// </summary>
  K_CMDCMTDeadTimeCorrectionFlag = $00541401;
    
// GROUP 60
/// <summary>
// GROUP 60 Group Length (0060;0000) UL 1
/// </summary>
  K_CMDCMTGroup60GroupLength = $00600000;

/// <summary>
/// Histogram Sequence (0060;3000) SQ 1
/// </summary>
  K_CMDCMTHistogramSequence = $00603000;

/// <summary>
/// Histogram Number of Bins (0060;3002) US 1
/// </summary>
  K_CMDCMTHistogramNumberOfBins = $00603002;

/// <summary>
/// Histogram First Bin Value (0060;3004) US 1
/// </summary>
  K_CMDCMTHistogramFirstBinValue = $00603004;

/// <summary>
/// Histogram Last Bin Value (0060;3006) US 1
/// </summary>
  K_CMDCMTHistogramLastBinValue = $00603006;

/// <summary>
/// Histogram Bin Width (0060;3008) US 1
/// </summary>
  K_CMDCMTHistogramBinWidth = $00603008;

/// <summary>
/// Histogram Explanation (0060;3010) LO 1
/// </summary>
  K_CMDCMTHistogramExplanation = $00603010;

/// <summary>
/// Histogram Data (0060;3020) UL 1-n
/// </summary>
  K_CMDCMTHistogramData = $00603020;
    
// GROUP 70
/// <summary>
// GROUP 70 Group Length (0070;0000) UL 1
/// </summary>
  K_CMDCMTGroup70GroupLength = $00700000;

///<summary>
/// Graphic Annotation Sequence (0070;0001)SQ 1
///</summary>
  K_CMDCMTGraphicAnnotationSequence = $00700001;

///<summary>
/// Graphic Layer (0070;0002) CS 1
///</summary>
  K_CMDCMTGraphicLayer = $00700002;

///<summary>
/// Bounding Box Annotation Units (0070;0003) CS 1
///</summary>
  K_CMDCMTBoundingBoxAnnotationUnits = $00700003;

///<summary>
/// Anchor Point Annotation Units (0070;0004) CS 1
///</summary>
  K_CMDCMTAnchorPointAnnotationUnits = $00700004;

///<summary>
/// Graphic Annotation Units (0070;0005) CS 1
///</summary>
  K_CMDCMTGraphicAnnotationUnits = $00700005;

///<summary>
/// Unformatted Text Value (0070;0006) ST 1
///</summary>
  K_CMDCMTUnformattedTextValue = $00700006;

///<summary>
/// Text Object Sequence (0070;0008) SQ 1
///</summary>
  K_CMDCMTTextObjectSequence = $00700008;

///<summary>
/// Graphic Object Sequence (0070;0009) SQ 1
///</summary>
  K_CMDCMTGraphicObjectSequence = $00700009;

///<summary>
/// Bounding Box Top Left Hand Corner (0070;0010) FL 2
///</summary>
  K_CMDCMTBoundingBoxTopLeftHandCorner = $00700010;

///<summary>
/// Bounding Box Bottom Righ Hand Corner (0070;0011) FL 2
///</summary>
  K_CMDCMTBoundingBoxBottomRightHandCorner = $00700011;

///<summary>
/// Bounding Box Text Horizontal Justificaiton (0070;0012) CS 1
///</summary>
  K_CMDCMTBoundingBoxTextHorizontalJustification = $00700012;

///<summary>
/// Anchor Point (0070;0014) FL 2
///</summary>
  K_CMDCMTAnchorPoint = $00700014;

///<summary>
/// Anchor Point Visibility (0070;0015) CS 1
///</summary>
  K_CMDCMTAnchorPointVisibility = $00700015;

///<summary>
/// Graphic Dimensions (0070;0020) US 1
///</summary>
  K_CMDCMTGraphicDimensions = $00700020;

///<summary>
/// Number of Graphic Points (0070;0021) US 1
///</summary>
  K_CMDCMTNumberOfGraphicPoints = $00700021;

///<summary>
/// Graphic Data (0070;0022) FL 2-n
///</summary>
  K_CMDCMTGraphicData = $00700022;

///<summary>
/// Graphic Type (0070;0023) CS 1
///</summary>
  K_CMDCMTGraphicType = $00700023;

///<summary>
/// Graphic Filled (0070;0024) CS 1
///</summary>
  K_CMDCMTGraphicFilled = $00700024;

///<summary>
/// Image Horizontal Flip (0070;0041) CS 1
///</summary>
  K_CMDCMTImageHorizontalFlip = $00700041;

///<summary>
/// Image Rotation (0070;0042) US 1
///</summary>
  K_CMDCMTImageRotation = $00700042;

///<summary>
/// Displayed Area Top Left Hand Corner (0070;0052) SL 2
///</summary>
  K_CMDCMTDisplayedAreaTopLeftHandCorner = $00700052;

///<summary>
/// Displayed Area Bottom Right Hand Corner (0070;0053) SL 2
///</summary>
  K_CMDCMTDisplayedAreaBottomRightHandCorner = $00700053;

///<summary>
/// Displayed Area Selection Sequence (0070;005A) SQ 1
///</summary>
  K_CMDCMTDisplayedAreaSelectionSequence = $0070005A;

///<summary>
/// Graphic Layer Sequence (0070;0060) SQ 1
///</summary>
  K_CMDCMTGraphicLayerSequence = $00700060;

///<summary>
/// Graphic Layer Order (0070;0062) IS 1
///</summary>
  K_CMDCMTGraphicLayerOrder = $00700062;

///<summary>
/// Graphic Layer Recommended Display Grayscale Value (0070;0066) US 1
///</summary>
  K_CMDCMTGraphicLayerRecommendedDisplayGrayscaleValue = $00700066;

///<summary>
/// Graphic Layer Recommended Display RGB Value (Retired) (0070;0067) US 3
///</summary>
  K_CMDCMTGraphicLayerRecommendedDisplayRgbValueRetired = $00700067;

///<summary>
/// Graphic Layer Description (0070;0068) LO 1
///</summary>
  K_CMDCMTGraphicLayerDescription = $00700068;

///<summary>
/// Content/Presentation Label (0070;0080) CS 1
///</summary>
  K_CMDCMTContentPresentationLabel = $00700080;

///<summary>
/// Content/Presentation Description (0070;0081) LO 1
///</summary>
  K_CMDCMTContentPresentationDescription = $00700081;

///<summary>
/// Presentation Creation Date (0070;0082) DA 1
///</summary>
  K_CMDCMTPresentationCreationDate = $00700082;

///<summary>
/// Presentation Creation Time (0070;0083) TM 1
///</summary>
  K_CMDCMTPresentationCreationTime = $00700083;

///<summary>
/// Presentation Creator's Name (0070;0084) PN 1
///</summary>
  K_CMDCMTPresentationCreatorsName = $00700084;

///<summary>
/// Content Creator’s Identification Code Sequence (0070;0086) SQ 1
///</summary>
  K_CMDCMTContentCreatorsIdentificationCodeSequence = $00700086;

///<summary>
/// Presentation Size Mode (0070;0100) CS 1
///</summary>
  K_CMDCMTPresentationSizeMode = $00700100;

///<summary>
/// Presentation Pixel Spacing (0070;0101) DS 2
///</summary>
  K_CMDCMTPresentationPixelSpacing = $00700101;

///<summary>
/// Presentation Pixel Aspect Ratio (0070;0102) IS 2
///</summary>
  K_CMDCMTPresentationPixelAspectRatio = $00700102;

///<summary>
/// Presentation Pixel Magnification Ratio (0070;0103) FL 1
///</summary>
  K_CMDCMTPresentationPixelMagnificationRatio = $00700103;

/// <summary>
/// Shape Type (0070;0306) CS 1
/// </summary>
  K_CMDCMTShapeType = $00700306;

/// <summary>
/// Registration Sequence (0070;0308) SQ 1
/// </summary>
  K_CMDCMTRegistrationSequence = $00700308;

/// <summary>
/// Matrix Registration Sequence (0070;0309) SQ 1
/// </summary>
  K_CMDCMTMatrixRegistrationSequence = $00700309;

/// <summary>
/// Matrix Sequence (0070;030A) SQ 1
/// </summary>
  K_CMDCMTMatrixSequence = $0070030A;

/// <summary>
/// Frame of Reference Transformation Matrix Type (0070;030C) CS 1
/// </summary>
  K_CMDCMTFrameOfReferenceTransformationMatrixType = $0070030C;

/// <summary>
/// Registration Type Code Sequence (0070;030D) SQ 1
/// </summary>
  K_CMDCMTRegistrationTypeCodeSequence = $0070030D;

/// <summary>
/// Fiducial Description (0070;030F) ST 1
/// </summary>
  K_CMDCMTFiducialDescription = $0070030F;

/// <summary>
/// Fiducial Identifier (0070;0310) SH 1
/// </summary>
  K_CMDCMTFiducialIdentifier = $00700310;

/// <summary>
/// Fiducial Identifier Code Sequence (0070;0311) SQ 1
/// </summary>
  K_CMDCMTFiducialIdentifierCodeSequence = $00700311;

/// <summary>
/// Contour Uncertainty Radius (0070;0312) FD 1
/// </summary>
  K_CMDCMTContourUncertaintyRadius = $00700312;

/// <summary>
/// Used Fiducials Sequence (0070;0314) SQ 1
/// </summary>
  K_CMDCMTUsedFiducialsSequence = $00700314;

/// <summary>
/// Graphic Coordinates Data Sequence (0070;0318) SQ 1
/// </summary>
  K_CMDCMTGraphicCoordinatesDataSequence = $00700318;

/// <summary>
/// Fiducial UID (0070;031A) UI 1
/// </summary>
  K_CMDCMTFiducialUid = $0070031A;

/// <summary>
/// Fiducial Set Sequence (0070;031C) SQ 1
/// </summary>
  K_CMDCMTFiducialSetSequence = $0070031C;

/// <summary>
/// Fiducial Sequence (0070;031E) SQ 1
/// </summary>
  K_CMDCMTFiducialSequence = $0070031E;

/// <summary>
/// Graphic Layer Recommended Display CIELab Value (0070;0401) US 3
/// </summary>
  K_CMDCMTGraphicLayerRecommendedDisplayCIELabValue = $00700401;

/// <summary>
/// Blending Sequence  (0070;0402) SQ 1
/// </summary>
  K_CMDCMTBlendingSequence = $00700402;

/// <summary>
/// Relative Opacity   (0070;0403) FL 1
/// </summary>
  K_CMDCMTRelativeOpacity = $00700403;

/// <summary>
/// Referenced Spatial Registration Sequence   (0070;0404) SQ 1
/// </summary>
  K_CMDCMTReferencedSpatialRegistrationSequence = $00700404;

/// <summary>
/// Blending Position  (0070;0405) CS 1
/// </summary>
  K_CMDCMTBlendingPosition = $00700405;
    
// GROUP 72
/// <summary>
// GROUP 72 Group Length (0072;0000) UL 1
/// </summary>
  K_CMDCMTGroup72GroupLength = $00720000;

///<summary>
/// Hanging Protocol Name (0072;0002)SH 1
///</summary>
  K_CMDCMTHangingProtocolName = $00720002;

///<summary>
/// Hanging Protocol Description (0072;0004)LO 1
///</summary>
  K_CMDCMTHangingProtocolDescription = $00720004;

///<summary>
/// Hanging Protocol Level (0072;0006)CS 1
///</summary>
  K_CMDCMTHangingProtocolLevel = $00720006;

///<summary>
/// Hanging Protocol Creator (0072;0008) LO 1
///</summary>
  K_CMDCMTHangingProtocolCreator = $00720008;

///<summary>
/// Hanging Protocol Creation Datetime (0072;000A) DT 1
///</summary>
  K_CMDCMTHangingProtocolCreationDatetime = $0072000A;

///<summary>
/// Hanging Protocol Definition Sequence (0072;000C) SQ 1
///</summary>
  K_CMDCMTHangingProtocolDefinitionSequence = $0072000C;

///<summary>
/// Hanging Protocol User Identification Code Sequence (0072;000E) SQ 1
///</summary>
  K_CMDCMTHangingProtocolUserIdentificationCodeSequence = $0072000E;

///<summary>
/// Hanging Protocol User Group Name (0072;0010) LO 1
///</summary>
  K_CMDCMTHangingProtocolUserGroupName = $00720010;

///<summary>
/// Source Hanging Protocol Sequence (0072;0012) SQ 1
///</summary>
  K_CMDCMTSourceHangingProtocolSequence = $00720012;

///<summary>
/// Number of Priors Referenced (0072;0014) US 1
///</summary>
  K_CMDCMTNumberOfPriorsReferenced = $00720014;

///<summary>
/// Image Sets Sequence (0072;0020) SQ 1
///</summary>
  K_CMDCMTImageSetsSequence = $00720020;

///<summary>
///  K_CMDCMTImage Set Selector Sequence (0072;0022) SQ 1
///</summary>
  K_CMDCMTImageSetSelectorSequence = $00720022;

///<summary>
/// Image Set Selector Usage Flag (0072;0024) CS 1
///</summary>
  K_CMDCMTImageSetSelectorUsageFlag = $00720024;

///<summary>
/// Selector Attribute (0072;0026) AT 1
///</summary>
  K_CMDCMTSelectorAttribute = $00720026;

///<summary>
/// Selector Value Number (0072;0028) US 1
///</summary>
  K_CMDCMTSelectorValueNumber = $00720028;

///<summary>
/// Time Based Image Sets Sequence (0072;0030) SQ 1
///</summary>
  K_CMDCMTTimeBasedImageSetsSequence = $00720030;

///<summary>
///Image Set Number (0072;0032) US 1
///</summary>
  K_CMDCMTImageSetNumber = $00720032;

///<summary>
/// Image Set Selector Category (0072;0034) CS 1
///</summary>
  K_CMDCMTImageSetSelectorCategory = $00720034;

///<summary>
/// Relative Time (0072;0038) US 2
///</summary>
  K_CMDCMTRelativeTime = $00720038;

///<summary>
/// Relative Time Units (0072;003A) CS 1
///</summary>
  K_CMDCMTRelativeTimeUnits = $0072003A;

///<summary>
///Abstract Prior Value (0072;003C) SS 2
///</summary>
  K_CMDCMTAbstractPriorValue = $0072003C;

///<summary>
///  K_CMDCMTAbstract Prior Code Sequence (0072;003E) SQ 1
///</summary>
  K_CMDCMTAbstractPriorCodeSequence = $0072003E;

///<summary>
/// Image Set Label (0072;0040) LO 1
///</summary>
  K_CMDCMTImageSetLabel = $00720040;

///<summary>
/// Selector Attribute VR (0072;0050) CS 1
///</summary>
  K_CMDCMTSelectorAttributeVR = $00720050;

///<summary>
///Selector Sequence Pointer (0072;0052) AT 1
///</summary>
  K_CMDCMTSelectorSequencePointer = $00720052;

///<summary>
///Selector Sequence Pointer Private Creator (0072;0054) LO 1
///</summary>
  K_CMDCMTSelectorSequencePointerPrivateCreator = $00720054;

///<summary>
///Selector Attribute Private Creator (0072;0056) LO 1
///</summary>
  K_CMDCMTSelectorAttributePrivateCreator = $00720056;

///<summary>
/// Selector AT Value (0072;0060) AT 1-n
///</summary>
  K_CMDCMTSelectorATValue = $00720060;

///<summary>
///Selector CS Value (0072;0062) CS 1-n
///</summary>
  K_CMDCMTSelectorCSValue = $00720062;

///<summary>
///Selector IS Value (0072;0064) IS 1-n
///</summary>
  K_CMDCMTSelectorISValue = $00720064;

///<summary>
///Selector LO Value (0072;0066) LO 1-n
///</summary>
  K_CMDCMTSelectorLOValue = $00720066;

///<summary>
/// Selector LT Value (0072;0068) LT 1-n
///</summary>
  K_CMDCMTSelectorLTValue = $00720068;

///<summary>
///Selector PN Value (0072;006A) PN 1-n
///</summary>
  K_CMDCMTSelectorPNValue = $0072006A;

///<summary>
///Selector SH Value (0072;006C) SH 1-n
///</summary>
  K_CMDCMTSelectorSHValue = $0072006C;

///<summary>
///Selector ST Value (0072;006E) ST 1-n
///</summary>
  K_CMDCMTSelectorSTValue = $0072006E;

///<summary>
/// Selector UT Value (0072;0070) UT 1-n
///</summary>
  K_CMDCMTSelectorUTValue = $00720070;

///<summary>
///Selector DS Value (0072;0072) DS 1-n
///</summary>
  K_CMDCMTSelectorDSValue = $00720072;

///<summary>
///Selector FD Value (0072;0074) FD 1-n
///</summary>
  K_CMDCMTSelectorFDValue = $00720074;

///<summary>
///Selector FL Value (0072;0076) FL 1-n
///</summary>
  K_CMDCMTSelectorFLValue = $00720076;

///<summary>
/// Selector UL Value (0072;0078) UL 1-n
///</summary>
  K_CMDCMTSelectorULValue = $00720078;

///<summary>
///Selector US Value (0072;007A) US 1-n
///</summary>
  K_CMDCMTSelectorUSValue = $0072007A;

///<summary>
///Selector SL Value (0072;007C) SL 1-n
///</summary>
  K_CMDCMTSelectorSLValue = $0072007C;

///<summary>
///Selector SS Value (0072;007E) SS 1-n
///</summary>
  K_CMDCMTSelectorSSValue = $0072007E;

///<summary>
/// Selector Code Sequence Value (0072;0080) SQ 1
///</summary>
  K_CMDCMTSelectorCodeSequenceValue = $00720080;

///<summary>
///Number of Screens (0072;0100) US 1
///</summary>
  K_CMDCMTNumberOfScreens = $00720100;

///<summary>
///Nominal Screen Definition Sequence (0072;0102) SQ 1
///</summary>
  K_CMDCMTNominalScreenDefinitionSequence = $00720102;

///<summary>
/// Number of Vertical Pixels (0072;0104) US 1
///</summary>
  K_CMDCMTNumberOfVerticalPixels = $00720104;

///<summary>
///Number of Horizontal Pixels (0072;0106) US 1
///</summary>
  K_CMDCMTNumberOfHorizontalPixels = $00720106;

///<summary>
/// Display Environment Spatial Position (0072;0108) FD 4
///</summary>
  K_CMDCMTDisplayEnvironmentSpatialPosition = $00720108;

///<summary>
/// Screen Minimum Grayscale Bit Depth (0072;010A) US 1
///</summary>
  K_CMDCMTScreenMinimumGrayscaleBitDepth = $0072010A;

///<summary>
///Screen Minimum Color Bit Depth (0072;010C) US 1
///</summary>
  K_CMDCMTScreenMinimumColorBitDepth = $0072010C;

///<summary>
/// Application Maximum Repaint Time (0072;010E) US 1
///</summary>
  K_CMDCMTApplicationMaximumRepaintTime = $0072010E;

///<summary>
/// Display Sets Sequence (0072;0200) SQ 1
///</summary>
  K_CMDCMTDisplaySetsSequence = $00720200;

///<summary>
/// Display Set Number (0072;0202) US 1
///</summary>
  K_CMDCMTDisplaySetNumber = $00720202;

///<summary>
/// Display Set Label (0072;0203) LO 1
///</summary>
  K_CMDCMTDisplaySetLabel = $00720203;

///<summary>
///Display Set Presentation Group (0072;0204) US 1
///</summary>
  K_CMDCMTDisplaySetPresentationGroup = $00720204;

///<summary>
///Display Set Presentation Group Description (0072;0206) LO 1
///</summary>
  K_CMDCMTDisplaySetPresentationGroupDescription = $00720206;

///<summary>
/// Partial Data Display Handling (0072;0208) CS 1
///</summary>
  K_CMDCMTPartialDataDisplayHandling = $00720208;

///<summary>
///Synchronized Scrolling Sequence (0072;0210) SQ 1
///</summary>
  K_CMDCMTSynchronizedScrollingSequence = $00720210;

///<summary>
///Display Set Scrolling Group (0072;0212) US 2-n
///</summary>
  K_CMDCMTDisplaySetScrollingGroup = $00720212;

///<summary>
///Navigation Indicator Sequence (0072;0214) SQ 1
///</summary>
  K_CMDCMTNavigationIndicatorSequence = $00720214;

///<summary>
///Navigation Display Set (0072;0216) US 1
///</summary>
  K_CMDCMTNavigationDisplaySet = $00720216;

///<summary>
///Reference Display Sets (0072;0218) US 1-n
///</summary>
  K_CMDCMTReferenceDisplaySets = $00720218;

///<summary>
///Image Boxes Sequence (0072;0300) SQ 1
///</summary>
  K_CMDCMTImageBoxesSequence = $00720300;

///<summary>
///Image Box Number (0072;0302)US  K_CMDCMT1
///</summary>
  K_CMDCMTImageBoxNumber = $00720302;

///<summary>
///Image Box Layout Type (0072;0304) CS 1
///</summary>
  K_CMDCMTImageBoxLayoutType = $00720304;

///<summary>
///Image Box Tile Horizontal Dimension (0072;0306)US  K_CMDCMT1
///</summary>
  K_CMDCMTImageBoxTileHorizontalDimension = $00720306;

///<summary>
///Image Box Tile Vertical Dimension (0072;0308) US 1
///</summary>
  K_CMDCMTImageBoxTileVerticalDimension = $00720308;

///<summary>
///Image Box Scroll Direction (0072;0310) CS  K_CMDCMT1
///</summary>
  K_CMDCMTImageBoxScrollDirection = $00720310;

///<summary>
///Image Box Small Scroll Type (0072;0312) CS 1
///</summary>
  K_CMDCMTImageBoxSmallScrollType = $00720312;

///<summary>
///Image Box Small Scroll Amount (0072;0314) US  K_CMDCMT1
///</summary>
  K_CMDCMTImageBoxSmallScrollAmount = $00720314;

///<summary>
///Image Box Large Scroll Type (0072;0316) CS 1
///</summary>
  K_CMDCMTImageBoxLargeScrollType = $00720316;

///<summary>
///Image Box Large Scroll Amount (0072;0318) US  K_CMDCMT1
///</summary>
  K_CMDCMTImageBoxLargeScrollAmount = $00720318;

///<summary>
///Image Box Overlap Priority (0072;0320) CS 1
///</summary>
  K_CMDCMTImageBoxOverlapPriority = $00720320;

///<summary>
///Cine Relative To Real-Time (0072;0330) FD  K_CMDCMT1
///</summary>
  K_CMDCMTCineRelativeToRealTime = $00720330;

///<summary>
///Filter Operations Sequence (0072;0400) SQ 1
///</summary>
  K_CMDCMTFilterOperationsSequence = $00720400;

///<summary>
///Filter By Category (0072;0402) CS 1
///</summary>
  K_CMDCMTFilterByCategory = $00720402;

///<summary>
///Filter By Attribute Presence (0072;0404) CS  K_CMDCMT1
///</summary>
  K_CMDCMTFilterByAttributePresence = $00720404;

///<summary>
///Filter By Operator (0072;0406) CS 1
///</summary>
  K_CMDCMTFilterByOperator = $00720406;

///<summary>
///Blending Operaton Type (0072;0500) CS 1
///</summary>
  K_CMDCMTBlendingOperationType = $00720500;

///<summary>
///Reformatting Operation Type (0072;0510) CS 1
///</summary>
  K_CMDCMTReformattingOperationType = $00720510;

///<summary>
///Reformatting Thickness (0072;0512) FD  K_CMDCMT1
///</summary>
  K_CMDCMTReformattingThickness = $00720512;

///<summary>
///Reformattingi Interval (0072;0514) FD 1
///</summary>
  K_CMDCMTReformattingiInterval = $00720514;

///<summary>
///Reformatting Operation Initial View Direction (0072;0516) CS 1
///</summary>
  K_CMDCMTReformattingOperationInitialViewDirection = $00720516;

///<summary>
///Three D Rendering Type (0072;0520) CS 1-n
///</summary>
  K_CMDCMTThreeDRenderingType = $00720520;

///<summary>
///Sorting Operations Sequence (0072;0600) SQ  K_CMDCMT1
///</summary>
  K_CMDCMTSortingOperationsSequence = $00720600;

///<summary>
///Sort By Category (0072;0602) CS 1
///</summary>
  K_CMDCMTSortByCategory = $00720602;

///<summary>
///Sorting Direction (0072;0604) CS 1
///</summary>
  K_CMDCMTSortingDirection = $00720604;

///<summary>
///Display Set Patient Orientation (0072;0700) CS 2
///</summary>
  K_CMDCMTDisplaySetPatientOrientation = $00720700;

///<summary>
///VOI Type (0072;0702) CS  K_CMDCMT1
///</summary>
  K_CMDCMTVOIType = $00720702;

///<summary>
///Pseudo-Color Type (0072;0704) CS 1
///</summary>
  K_CMDCMTPseudoColorType = $00720704;

///<summary>
///Show Grayscale Inverted (0072;0706) CS 1
///</summary>
  K_CMDCMTShowGrayscaleInverted = $00720706;

///<summary>
///Show Image True Size Flag (0072;0710) CS 1
///</summary>
  K_CMDCMTShowImageTrueSizeFlag = $00720710;

///<summary>
///Show Graphic Annotation Flag (0072;0712) CS 1
///</summary>
  K_CMDCMTShowGraphicAnnotationFlag = $00720712;

///<summary>
///Show Patient Demographics Flag (0072;0714) CS 1
///</summary>
  K_CMDCMTShowPatientDemographicsFlag = $00720714;

///<summary>
///Show Acquisition Techniques Flag (0072;0716) CS  K_CMDCMT1
///</summary>
  K_CMDCMTShowAcquisitionTechniquesFlag = $00720716;

///<summary>
///Display Set Horizontal Justification (0072;0717) CS 1
///</summary>
  K_CMDCMTDisplaySetHorizontalJustification = $00720717;

///<summary>
///Display Set Vertical Justification (0072;0718) CS 1
///</summary>
  K_CMDCMTDisplaySetVerticalJustification = $00720718;

    
// GROUP 88
/// <summary>
// GROUP 88 Group Length (0088;0000) UL 1
/// </summary>
  K_CMDCMTGroup88GroupLength = $00880000;

/// <summary>
/// Storage Media File Set ID (0088;0130) SH 1
/// </summary>
  K_CMDCMTStorageMediaFileSetId = $00880130;

/// <summary>
/// Storage Media File Set UID (0088;0140) UI 1
/// </summary>
  K_CMDCMTStorageMediaFileSetUid = $00880140;

/// <summary>
/// Icon Image Sequence (0088;0200) SQ 1
/// </summary>
  K_CMDCMTIconImageSequence = $00880200;

/// <summary>
/// Topic Title (0088;0904) LO 1
/// </summary>
  K_CMDCMTTopicTitle = $00880904;

/// <summary>
/// Topic Subject (0088;0906) ST 1
/// </summary>
  K_CMDCMTTopicSubject = $00880906;

/// <summary>
/// Topic Author (0088;0910) LO 1
/// </summary>
  K_CMDCMTTopicAuthor = $00880910;

/// <summary>
/// Topic Key Words (0088;0912) LO 1-32
/// </summary>
  K_CMDCMTTopicKeyWords = $00880912;
    
// GROUP 100
/// <summary>
// GROUP 100 Group Length (0100;0000) UL 1
/// </summary>
  K_CMDCMTGroup100GroupLength = $01000000;

/// <summary>
/// SOP Instance Status (0100;0410) CS 1
/// </summary>
  K_CMDCMTSopInstanceStatus = $01000410;

/// <summary>
/// SOP Authorization Date and Time (0100;0420) DT 1
/// </summary>
  K_CMDCMTSopAuthorizationDateTime = $01000420;

/// <summary>
/// SOP Authorization Comment (0100;0424) LT 1
/// </summary>
  K_CMDCMTSopAuthorizationComment = $01000424;

/// <summary>
/// Authorization Equipment Certification Number (0100;0426) LO 1
/// </summary>
  K_CMDCMTAuthorizationEquipmentCertificationNumber = $01000426;
    
// GROUP 400
/// <summary>
// GROUP 400 Group Length (0400;0000) UL 1
/// </summary>
  K_CMDCMTGroup400GroupLength = $04000000;

/// <summary>
/// MAC ID Number (0400;0005) US 1
/// </summary>
  K_CMDCMTMacIdNumber = $04000005;

/// <summary>
/// MAC Calculation Transfer Syntax UID (0400;0010) UI 1
/// </summary>
  K_CMDCMTMacCalculationTransferSyntaxUid = $04000010;

/// <summary>
/// MAC Algorithm (0400;0015) CS 1
/// </summary>
  K_CMDCMTMacAlgorithm = $04000015;

/// <summary>
/// Data Elements Signed (0400;0020) AT 1-n
/// </summary>
  K_CMDCMTDataElementsSigned = $04000020;

/// <summary>
/// Digital Signature UID (0400;0100) UI 1
/// </summary>
  K_CMDCMTDigitalSignatureUid = $04000100;

/// <summary>
/// Digital signature DateTime (0400;0105) DT 1
/// </summary>
  K_CMDCMTDigitalSignatureDateTime = $04000105;

/// <summary>
/// Certificate Type (0400;0110) CS 1
/// </summary>
  K_CMDCMTCertificateType = $04000110;

/// <summary>
/// Certificate of Signer (0400;0115) OB 1
/// </summary>
  K_CMDCMTCertificateOfSigner = $04000115;

/// <summary>
/// Signature (0400;0120) OB 1
/// </summary>
  K_CMDCMTSignature = $04000120;

/// <summary>
/// Certified Timestamp Type (0400;0305) CS 1
/// </summary>
  K_CMDCMTCertifiedTimestampType = $04000305;

/// <summary>
/// Certified Timestamp (0400;0310) OB 1
/// </summary>
  K_CMDCMTCertifiedTimestamp = $04000310;

/// <summary>
/// Digital Signature Purpose Code Sequence (0400;0401) SQ 1
/// </summary>
  K_CMDCMTDigitalSignaturePurposeCodeSequence = $04000401;

/// <summary>
/// Referenced Digital Signature Sequence (0400;0402) SQ 1
/// </summary>
  K_CMDCMTReferencedDigitalSignatureSequence = $04000402;

/// <summary>
/// Referenced SOP Instance MAC Sequenc (0400;0403) SQ 1
/// </summary>
  K_CMDCMTReferencedSOPInstanceMACSequenc = $04000403;

/// <summary>
/// MAC    K_CMDCMT(0400;0404) OB 1
/// </summary>
  K_CMDCMTMAC = $04000404;

/// <summary>
/// Encrypted Attributes Sequence (0400;0500) SQ 1C
/// </summary>
  K_CMDCMTEncryptedAttributesSequence = $04000500;

/// <summary>
/// Encrypted Content Transfer Syntax UID (0400;0510) UI 1
/// </summary>
  K_CMDCMTEncryptedContentTransferSyntaxUid = $04000510;

/// <summary>
/// Encrypted Content (0400;0520) OB 1
/// </summary>
  K_CMDCMTEncryptedContent = $04000520;

/// <summary>
/// Modified Attributes Sequence (0400;0550) SQ 1
/// </summary>
  K_CMDCMTModifiedAttributesSequence = $04000550;

/// <summary>
/// Original Attributes Sequence (0400;0561) SQ 1
/// </summary>
  K_CMDCMTOriginalAttributeSequence = $04000561;
    
/// <summary>
/// Attribute Modification DateTime (0400;0562) DT 1
/// </summary>
  K_CMDCMTAttributeModificationDateTime = $04000562;

/// <summary>
/// Modifying System (0400;0563) LO 1
/// </summary>
  K_CMDCMTModifyingSystem = $04000563;

/// <summary>
/// Source of Previous Values (0400;0564) LO 1
/// </summary>
  K_CMDCMTPreviousValuesSource = $04000564;

/// <summary>
/// Reason for the Attribute Modification (0400;0565) LO 1
/// </summary>
  K_CMDCMTAttributeModificationReason = $04000565;

// GROUP 2000
/// <summary>
// GROUP 2000 Group Length (2000;0000) UL 1
/// </summary>
  K_CMDCMTGroup2000GroupLength = $20000000;

/// <summary>
/// Number of Copies (2000;0010) IS 1
/// </summary>
  K_CMDCMTNumberOfCopies = $20000010;

/// <summary>
/// Printer Configuration Sequence (2000;001E) SQ 1
/// </summary>
  K_CMDCMTPrinterConfigurationSequence = $2000001E;

/// <summary>
/// Print Priority (2000;0020) CS 1
/// </summary>
  K_CMDCMTPrintPriority = $20000020;

/// <summary>
/// Medium Type (2000;0030) CS 1
/// </summary>
  K_CMDCMTMediumType = $20000030;

/// <summary>
/// Film Destination (2000;0040) CS 1
/// </summary>
  K_CMDCMTFilmDestination = $20000040;

/// <summary>
/// Film Session Label (2000;0050) LO 1
/// </summary>
  K_CMDCMTFilmSessionLabel = $20000050;

/// <summary>
/// Memory Allocation (2000;0060) IS 1
/// </summary>
  K_CMDCMTMemoryAllocation = $20000060;

/// <summary>
/// Maximum Memor Allocation (2000;0061) IS 1
/// </summary>
  K_CMDCMTMaximumMemoryAllocation = $20000061;

/// <summary>
/// Color Image Printing Flag (Retired) (2000;0062) CS 1
/// </summary>
  K_CMDCMTColorImagePrintingFlagRetired = $20000062;

/// <summary>
/// Collation Flag (Retired) (2000;0063) CS 1
/// </summary>
  K_CMDCMTCollationFlagRetired = $20000063;

/// <summary>
/// Annotation Flag (Retired) (2000;0065) CS 1
/// </summary>
  K_CMDCMTAnnotationFlagRetired = $20000065;

/// <summary>
/// Image Ovderlay Flag (Retired) (2000;0067) CS 1
/// </summary>
  K_CMDCMTImageOverlayFlagRetired = $20000067;

/// <summary>
/// Presentation LUT Flag (Retired) (2000;0069) CS 1
/// </summary>
  K_CMDCMTPresentationLutFlagRetired = $20000069;

/// <summary>
/// Image Box Presentation LUT Flag (Retired) (2000;006A) CS 1
/// </summary>
  K_CMDCMTImageBoxPresentationLutFlagRetired = $2000006A;

/// <summary>
/// Memory Bit Depth (2000;00A0) US 1
/// </summary>
  K_CMDCMTMemoryBitDepth = $200000A0;

/// <summary>
/// Printing Bit Depth (2000;00A1) US 1
/// </summary>
  K_CMDCMTPrintingBitDepth = $200000A1;

/// <summary>
/// Media Installed Sequence (2000;00A2) SQ1
/// </summary>
  K_CMDCMTMediaInstalledSequence = $200000A2;

/// <summary>
/// Other Media Available Sequence (2000;00A4) SQ 1
/// </summary>
  K_CMDCMTOtherMediaAvailableSequence = $200000A4;

/// <summary>
/// Supported Image Display Formats Sequence (2000;00A8) SQ 1
/// </summary>
  K_CMDCMTSupportedImageDisplayFormatsSequence = $200000A8;

/// <summary>
/// Referenced SOP Instance MAC Sequence (2000;0403) SQ 1
/// </summary>
  K_CMDCMTReferencedSOPInstanceMACSequence = $20000403;

/// <summary>
/// Referenced Film Box Sequence (2000;0500) SQ 1
/// </summary>
  K_CMDCMTReferencedFilmBoxSequence = $20000500;

/// <summary>
/// Referenced Stored Print Sequence (2000;0510) SQ 1
/// </summary>
  K_CMDCMTReferencedStoredPrintSequence = $20000510;
    
// GROUP 2010
/// <summary>
// GROUP 2010 Group Length (2010;0000) UL 1
/// </summary>
  K_CMDCMTGroup2010GroupLength = $20100000;

/// <summary>
/// Image Display Format (2010;0010) ST 1
/// </summary>
  K_CMDCMTImageDisplayFormat = $20100010;

/// <summary>
/// Annotation Display Format ID (2010;0030) CS 1
/// </summary>
  K_CMDCMTAnnotationDisplayFormatId = $20100030;

/// <summary>
/// Film Orientation (2010;0040) CS 1
/// </summary>
  K_CMDCMTFilmOrientation = $20100040;

/// <summary>
/// Film Size ID (2010;0050) CS 1
/// </summary>
  K_CMDCMTFilmSizeId = $20100050;

/// <summary>
/// Printer Resolution ID (2010;0052) CS 1
/// </summary>
  K_CMDCMTPrinterResolutionId = $20100052;

/// <summary>
/// Default Printer Resolution ID (2010;0054) CS 1
/// </summary>
  K_CMDCMTDefaultPrinterResolutionId = $20100054;

/// <summary>
/// Magnification Type (2010;0060) CS 1
/// </summary>
  K_CMDCMTMagnificationType = $20100060;

/// <summary>
/// Smoothing Type (2010;0080) CS 1
/// </summary>
  K_CMDCMTSmoothingType = $20100080;

/// <summary>
/// Default Magnification Type (2010;00A6) CS 1
/// </summary>
  K_CMDCMTDefaultMagnificationType = $201000A6;

/// <summary>
/// Other Magnification Types Available (2010;00A7) CS 1-n
/// </summary>
  K_CMDCMTOtherMagnificationTypesAvailable = $201000A7;

/// <summary>
/// Default Smoothing Type (2010;00A8) CS 1
/// </summary>
  K_CMDCMTDefaultSmoothingType = $201000A8;

/// <summary>
/// Other Smoothing Types Available (2010;00A9) CS 1-n
/// </summary>
  K_CMDCMTOtherSmoothingTypesAvailable = $201000A9;

/// <summary>
/// Border Density (2010;0100) CS 1
/// </summary>
  K_CMDCMTBorderDensity = $20100100;

/// <summary>
/// Empty Image Density (2010;0110) CS 1
/// </summary>
  K_CMDCMTEmptyImageDensity = $20100110;

/// <summary>
/// Min Density (2010;0120) US 1
/// </summary>
  K_CMDCMTMinDensity = $20100120;

/// <summary>
/// Max Density (2010;0130) US 1
/// </summary>
  K_CMDCMTMaxDensity = $20100130;

/// <summary>
/// Trim (2010;0140) CS 1
/// </summary>
  K_CMDCMTTrim = $20100140;

/// <summary>
/// Configuration Information (2010;0150) ST 1
/// </summary>
  K_CMDCMTConfigurationInformation = $20100150;

/// <summary>
/// Configuration Information Description (2010;0152) LT 1
/// </summary>
  K_CMDCMTConfigurationInformationDescription = $20100152;

/// <summary>
/// Maximum Collated Films (2010;0154) IS 1
/// </summary>
  K_CMDCMTMaximumCollatedFilms = $20100154;

/// <summary>
/// Illumination (2010;015E) US 1
/// </summary>
  K_CMDCMTIllumination = $2010015E;

/// <summary>
/// Reflected Ambient Light (2010;0160) US 1
/// </summary>
  K_CMDCMTReflectedAmbientLight = $20100160;

/// <summary>
/// Printer Pixel Spacing (2010;0376) DS 2
/// </summary>
  K_CMDCMTPrinterPixelSpacing = $20100376;

/// <summary>
/// Referenced Film Session Sequence (2010;0500) SQ 1
/// </summary>
  K_CMDCMTReferencedFilmSessionSequence = $20100500;

/// <summary>
/// Referenced Image Box Sequence (2010;0510) SQ 1
/// </summary>
  K_CMDCMTReferencedImageBoxSequence = $20100510;

/// <summary>
/// Referenced Basic Annotation Box Sequence (2010;0520) SQ 1
/// </summary>
  K_CMDCMTReferencedBasicAnnotationBoxSequence = $20100520;

// GROUP 2020
/// <summary>
// GROUP 2020 Group Length (2020;0000) UL 1
/// </summary>
  K_CMDCMTGroup2020GroupLength = $20200000;

/// <summary>
/// Image Position (2020;0010) US 1
/// </summary>
  K_CMDCMTImagePosition = $20200010;

/// <summary>
/// Polarity (2020;0020) CS 1
/// </summary>
  K_CMDCMTPolarity = $20200020;

/// <summary>
/// Requested Image Size (2020;0030) DS 1
/// </summary>
  K_CMDCMTRequestedImageSize = $20200030;

/// <summary>
/// Requested Decimate/Crop Behavior (2020;0040) CS 1
/// </summary>
  K_CMDCMTRequestedDecimateCropBehavior = $20200040;

/// <summary>
/// Requested Resolution ID (2020;0050) CS 1
/// </summary>
  K_CMDCMTRequestedResolutionId = $20200050;

/// <summary>
/// Requested Image Size Flag (2020;00A0) CS 1
/// </summary>
  K_CMDCMTRequestedImageSizeFlag = $202000A0;

/// <summary>
/// Decimate/Crop Result (2020;00A2) CS 1
/// </summary>
  K_CMDCMTDecimateCropResult = $202000A2;

/// <summary>
/// Basic Grayscale Image Sequence (2020;0110) SQ 1
/// </summary>
  K_CMDCMTBasicGrayscaleImageSequence = $20200110;

/// <summary>
/// Basic Color Image Sequence (2020;0111) SQ 1
/// </summary>
  K_CMDCMTBasicColorImageSequence = $20200111;

/// <summary>
/// Referenced Image Overlay Box Sequence (Retired) (2020;0130) SQ 1
/// </summary>
  K_CMDCMTReferencedImageOverlayBoxSequenceRetired = $20200130;

/// <summary>
/// Referenced VOI LUT Box Sequence (Retired) (2020;0140) SQ 1
/// </summary>
  K_CMDCMTReferencedVoiLutBoxSequenceRetired = $20200140;
    
// GROUP 2030
/// <summary>
// GROUP 2030 Group Length (2030;0000) UL 1
/// </summary>
  K_CMDCMTGroup2030GroupLength = $20300000;

/// <summary>
/// Annotation Position (2030;0010) US 1
/// </summary>
  K_CMDCMTAnnotationPosition = $20300010;

/// <summary>
/// Text String (2030;0020) LO 1
/// </summary>
  K_CMDCMTTextString = $20300020;
    
// GROUP 2040
/// <summary>
// GROUP 2040 Group Length (2040;0000) UL 1
/// </summary>
  K_CMDCMTGroup2040GroupLength = $20400000;

/// <summary>
/// Referenced Overlay Plane Sequence (Retired) (2040;0010) SQ 1
/// </summary>
  K_CMDCMTReferencedOverlayPlaneSequenceRetired = $20400010;

/// <summary>
/// Referenced Overlay Plane Groups (Retired) (2040;0011) US 1-99
/// </summary>
  K_CMDCMTReferencedOverlayPlaneGroupsRetired = $20400011;

/// <summary>
/// Overlay Pixel Data Sequence (Retired) (2040;0020) SQ 1
/// </summary>
  K_CMDCMTOverlayPixelDataSequenceRetired = $20400020;

/// <summary>
/// Overlay Magnification Type (Retired) (2040;0060) CS 1
/// </summary>
  K_CMDCMTOverlayMagnificationTypeRetired = $20400060;

/// <summary>
/// Overlay Smoothing Type (Retired) (2040;0070) CS 1
/// </summary>
  K_CMDCMTOverlaySmoothingTypeRetired = $20400070;

/// <summary>
/// Overlay or Image Magnification (Retired) (2040;0072) CS 1
/// </summary>
  K_CMDCMTOverlayOrImageMagnificationRetired = $20400072;

/// <summary>
/// Magnify to Number of Columns (Retired) (2040;0074) US 1
/// </summary>
  K_CMDCMTMagnifyToNumberOfColumnsRetired = $20400074;

/// <summary>
/// Overlay Foreground Density (Retired) (2040;0080) CS 1
/// </summary>
  K_CMDCMTOverlayForegroundDensityRetired = $20400080;

/// <summary>
/// Overlay Background Density (Retired)  (2040;0082) CS 1
/// </summary>
  K_CMDCMTOverlayBackgroundDensityRetired = $20400082;

/// <summary>
/// Overlay Mode (Retired) (2040;0090) CS 1
/// </summary>
  K_CMDCMTOverlayModeRetired = $20400090;

/// <summary>
/// Threshold Density (Retired) (2040;0100) CS 1
/// </summary>
  K_CMDCMTThresholdDensityRetired = $20400100;

/// <summary>
/// Referenced Image Box Sequence RETIRED (2040;0500) SQ 1
/// </summary>
  K_CMDCMTReferencedImageBoxSequenceRetired = $20400500;
    
// GROUP 2050
/// <summary>
// GROUP 2050 Group Length (2050;0000) UL 1
/// </summary>
  K_CMDCMTGroup2050GroupLength = $20500000;

/// <summary>
/// Presentation LUT Sequence (2050;0010) SQ 1
/// </summary>
  K_CMDCMTPresentationLutSequence = $20500010;

/// <summary>
/// Presentation LUT Shape (2050;0020) CS 1
/// </summary>
  K_CMDCMTPresentationLutShape = $20500020;

/// <summary>
/// Referenced Presentation LUT Sequence (2050;0500) SQ 1
/// </summary>
  K_CMDCMTReferencedPresentationLutSequence = $20500500;
    
// GROUP 2100
/// <summary>
// GROUP 2100 Group Length (2100;0000) UL 1
/// </summary>
  K_CMDCMTGroup2100GroupLength = $21000000;

/// <summary>
/// Print Job ID (2100;0010) SH 1
/// </summary>
  K_CMDCMTPrintJobId = $21000010;

/// <summary>
/// Execution Status (2100;0020) CS 1
/// </summary>
  K_CMDCMTExecutionStatus = $21000020;

/// <summary>
/// Execution Status Info (2100;0030) CS 1
/// </summary>
  K_CMDCMTExecutionStatusInfo = $21000030;

/// <summary>
/// Creation Date (2100;0040) DA 1
/// </summary>
  K_CMDCMTCreationDate = $21000040;

/// <summary>
/// Creation Time (2100;0050) TM 1
/// </summary>
  K_CMDCMTCreationTime = $21000050;

/// <summary>
/// Originator (2100;0070) AE 1
/// </summary>
  K_CMDCMTOriginator = $21000070;

/// <summary>
/// Destination AE (2100;0140) AE 1
/// </summary>
  K_CMDCMTDestinationAE = $21000140;

/// <summary>
/// Owner ID (2100;0160) SH 1
/// </summary>
  K_CMDCMTOwnerId = $21000160;

/// <summary>
/// Number of films (2100;0170) IS 1
/// </summary>
  K_CMDCMTNumberOfFilms = $21000170;

/// <summary>
/// Referenced Print Job Sequence (Pull Stored Print) (2100;0500) SQ 1-RI
/// </summary>
  K_CMDCMTReferencedPrintJobSequencePullStoredPrint = $21000500;
    
// GROUP 2110
/// <summary>
// GROUP 2110 Group Length (2110;0000) UL 1
/// </summary>
  K_CMDCMTGroup2110GroupLength = $21100000;

/// <summary>
/// Printer Status (2110;0010) CS 1
/// </summary>
  K_CMDCMTPrinterStatus = $21100010;

/// <summary>
/// Printer Status Info (2110;0020) CS 1
/// </summary>
  K_CMDCMTPrinterStatusInfo = $21100020;

/// <summary>
/// Printer Name (2110;0030) LO 1
/// </summary>
  K_CMDCMTPrinterName = $21100030;

/// <summary>
/// Print queue ID  K_CMDCMT(Retired) (2110;0099) SH 1
/// </summary>
  K_CMDCMTPrintQueueIdRetired = $21100099;
    
// GROUP 2120
/// <summary>
// GROUP 2110 Group Length (2110;0000) UL 1
/// </summary>
  K_CMDCMTGroup2120GroupLength = $21200000;

/// <summary>
/// Queue Status (Retired)(2120;0010) CS 1
/// </summary>
  K_CMDCMTQueueStatusRetired = $21200010;

/// <summary>
/// Print Job Description Sequence (Retired) (2120;0050) SQ 1
/// </summary>
  K_CMDCMTPrintJobDescriptionSequenceRetired = $21200050;

/// <summary>
/// Referenced Print Job Sequence (Retired)(2120;0070) SQ 1
/// </summary>
  K_CMDCMTReferencedPrintJobSequenceRetired = $21200070;
    
// GROUP 2130
/// <summary>
// GROUP 2130 Group Length (2110;0000) UL 1
/// </summary>
  K_CMDCMTGroup2130GroupLength = $21300000;

/// <summary>
/// Print Management Capabilities Sequence (Retired) (2130;0010) SQ 1
/// </summary>
  K_CMDCMTPrintManagementCapabilitiesSequenceRetired = $21300010;

/// <summary>
/// Printer Characteristics Sequence (Retired) (2130;0015) SQ 1
/// </summary>
  K_CMDCMTPrinterCharacteristicsSequenceRetired = $21300015;

/// <summary>
/// Film Box Content Sequence (Retired) (2130;0030) SQ 1 
/// </summary>
  K_CMDCMTFilmBoxContentSequenceRetired = $21300030;

/// <summary>
/// Image Box Content Sequence (Retired) (2130;0040) SQ 1
/// </summary>
  K_CMDCMTImageBoxContentSequenceRetired = $21300040;

/// <summary>
/// Annotation Content Sequence (Retired)(2130;0050) SQ 1
/// </summary>
  K_CMDCMTAnnotationContentSequenceRetired = $21300050;

/// <summary>
/// Image Overlay Box Content Sequence (Retired) (2130;0060) SQ 1
/// </summary>
  K_CMDCMTImageOverlayBoxContentSequenceRetired = $21300060;

/// <summary>
/// Presentation LUT Content Sequence (Retired) (2130;0080) SQ 1
/// </summary>
  K_CMDCMTPresentationLutContentSequenceRetired = $21300080;

/// <summary>
/// Proposed Study Sequence (Retired) (2130;00A0) SQ 1
/// </summary>
  K_CMDCMTProposedStudySequenceRetired = $213000A0;

/// <summary>
/// Original Image Sequence (Retired)(2130;00C0) SQ 1
/// </summary>
  K_CMDCMTOriginalImageSequenceRetired = $213000C0;
    
// GROUP 2200
/// <summary>
/// Label Using Information Extracted From Instances (2200;0001) CS 1
/// </summary>
  K_CMDCMTLabelUsingInformationExtractedFromInstances = $22000001;

/// <summary>
/// Label Text (2200;0002) UT 1
/// </summary>
  K_CMDCMTLabelText = $22000002;

/// <summary>
/// Label Style Selection (2200;0003) CS 1
/// </summary>
  K_CMDCMTLabelStyleSelection = $22000003;

/// <summary>
/// Media Disposition (2200;0004) LT 1
/// </summary>
  K_CMDCMTMediaDisposition = $22000004;

/// <summary>
/// Barcode Value (2200;0005) LT 1
/// </summary>
  K_CMDCMTBarcodeValue = $22000005;

/// <summary>
/// Barcode Symbology (2200;0006) CS 1
/// </summary>
  K_CMDCMTBarcodeSymbology = $22000006;

/// <summary>
/// Allow Media Splitting (2200;0007) CS 1
/// </summary>
  K_CMDCMTAllowMediaSplitting = $22000007;

/// <summary>
/// Include Non-DICOM Objects (2200;0008) CS 1
/// </summary>
  K_CMDCMTIncludeNonDicomObjects = $22000008;

/// <summary>
/// Include Display Application (2200;0009) CS 1
/// </summary>
  K_CMDCMTIncludeDisplayApplication = $22000009;

/// <summary>
/// Preserve Composite Instances After Media Creation (2200;000A) CS 1
/// </summary>
  K_CMDCMTPreserveCompositeInstancesAfterMediaCreation = $2200000A;

/// <summary>
/// Total Number of Pieces of Media Created (2200;000B) US 1
/// </summary>
  K_CMDCMTTotalNumberOfPiecesOfMediaCreated = $2200000B;

/// <summary>
/// Requested Media Application Profile (2200;000C) LO 1
/// </summary>
  K_CMDCMTRequestedMediaApplicationProfile = $2200000C;

/// <summary>
/// Referenced Storage Media Sequence (2200;000D) SQ 1
/// </summary>
  K_CMDCMTReferencedStorageMediaSequence = $2200000D;

/// <summary>
/// Failure Attributes (2200;000E) AT 1-n
/// </summary>
  K_CMDCMTFailureAttributes = $2200000E;

/// <summary>
/// Allow Lossy Compression (2200;000F) CS 1
/// </summary>
  K_CMDCMTAllowLossyCompression = $2200000F;

/// <summary>
/// Request Priority (2200;0020) CS 1
/// </summary>
  K_CMDCMTRequestPriority = $22000020;
    
// GROUP 3002
/// <summary>
/// RT Image Label (3002;0002) SH 1
/// </summary>
  K_CMDCMTRTImageLabel = $30020002;

/// <summary>
/// RT Image Name (3002;0003) LO 1
/// </summary>
  K_CMDCMTRTImageName = $30020003;

/// <summary>
/// RT Image Description (3002;0004) ST 1
/// </summary>
  K_CMDCMTRTImageDescription = $30020004;

/// <summary>
/// Reported Values Origin (3002;000A) CS 1
/// </summary>
  K_CMDCMTReportedValuesOrigin = $3002000A;

/// <summary>
/// RT Image Plane (3002;000C) CS 1
/// </summary>
  K_CMDCMTRTImagePlane = $3002000C;

/// <summary>
/// X-Ray Image Receptor Translation (3002;000D) DS 3
/// </summary>
  K_CMDCMTXRayImageReceptorTranslation = $3002000D;

/// <summary>
/// X-Ray Image Receptor Angle (3002;000E) DS 1
/// </summary>
  K_CMDCMTXRayImageReceptorAngle = $3002000E;

/// <summary>
/// RT Image Orientation (3002;0010) DS 6
/// </summary>
  K_CMDCMTRTImageOrientation = $30020010;

/// <summary>
/// Image Plane Pixel Spacing (3002;0011) DS 2
/// </summary>
  K_CMDCMTImagePlanePixelSpacing = $30020011;

/// <summary>
/// RT Image Position (3002;0012) DS 2
/// </summary>
  K_CMDCMTRTImagePosition = $30020012;

/// <summary>
/// Radiation Machine Name (3002;0020) SH 1
/// </summary>
  K_CMDCMTRadiationMachineName = $30020020;

/// <summary>
/// Radiation Machine SAD (3002;0022) DS 1
/// </summary>
  K_CMDCMTRadiationMachineSad = $30020022;

/// <summary>
/// Radiation Machine SSD (3002;0024) DS 1
/// </summary>
  K_CMDCMTRadiationMachineSsd = $30020024;

/// <summary>
/// RT Image SID (3002;0026) DS 1
/// </summary>
  K_CMDCMTRTImageSid = $30020026;

/// <summary>
/// Source to Reference Object Distance (3002;0028) DS 1
/// </summary>
  K_CMDCMTSourceToReferenceObjectDistance = $30020028;

/// <summary>
/// Fraction Number (3002;0029) IS 1
/// </summary>
  K_CMDCMTFractionNumber = $30020029;

/// <summary>
/// Exposure Sequence (3002;0030) SQ 1
/// </summary>
  K_CMDCMTExposureSequence = $30020030;

/// <summary>
/// Meterset Exposure (3002;0032) DS 1
/// </summary>
  K_CMDCMTMetersetExposure = $30020032;

/// <summary>
/// Diaphragm Position (3002;0034) DS 4
/// </summary>
  K_CMDCMTDiaphragmPosition = $30020034;

/// <summary>
/// Fluence Map Sequence (3002;0040) SQ 1
/// </summary>
  K_CMDCMTFluenceMapSequence = $30020040;

/// <summary>
/// Fluence Data Source (3002;0041) CS 1
/// </summary>
  K_CMDCMTFluenceDataSource = $30020041;

/// <summary>
/// Fluence Data Scale (3002;0042) DS 1
/// </summary>
  K_CMDCMTFluenceDataScale = $30020042;
    
// GROUP 3004
/// <summary>
// GROUP 3004 Group Length (3004;0000) UL 1
/// </summary>
  K_CMDCMTGroup3004GroupLength = $30040000;

/// <summary>
/// DVH Type (3004;0001) CS 1
/// </summary>
  K_CMDCMTDvhType = $30040001;

/// <summary>
/// Dose Units (3004;0002) CS 1
/// </summary>
  K_CMDCMTDoseUnits = $30040002;

/// <summary>
/// Dose Type (3004;0004) CS 1
/// </summary>
  K_CMDCMTDoseType = $30040004;

/// <summary>
/// Dose Comment (3004;0006) LO 1
/// </summary>
  K_CMDCMTDoseComment = $30040006;

/// <summary>
/// Normalization Point (3004;0008) DS 3
/// </summary>
  K_CMDCMTNormalizationPoint = $30040008;

/// <summary>
/// Dose Summation Type (3004;000A) CS 1
/// </summary>
  K_CMDCMTDoseSummationType = $3004000A;

/// <summary>
/// Grid Frame Offset Vector (3004;000C) DS 2-n
/// </summary>
  K_CMDCMTGridFrameOffsetVector = $3004000C;

/// <summary>
/// Dose Grid Scaling (3004;000E) DS 1
/// </summary>
  K_CMDCMTDoseGridScaling = $3004000E;

/// <summary>
/// RT Dose ROI Sequence (3004;0010) SQ 1
/// </summary>
  K_CMDCMTRTDoseRoiSequence = $30040010;

/// <summary>
/// Dose Value (3004;0012) DS 1
/// </summary>
  K_CMDCMTDoseValue = $30040012;

/// <summary>
/// Tissue Heterogeneity Correction (3004;0014) CS 1-3
/// </summary>
  K_CMDCMTTissueHeterogeneityCorrection = $30040014;

/// <summary>
/// DVH Normalization Point (3004;0040) DS 3
/// </summary>
  K_CMDCMTDvhNormalizationPoint = $30040040;

/// <summary>
/// DVH Normalization Dose Value (3004;0042) DS 1
/// </summary>
  K_CMDCMTDvhNormalizationDoseValue = $30040042;

/// <summary>
/// DVH Sequence (3004;0050) SQ 1
/// </summary>
  K_CMDCMTDvhSequence = $30040050;

/// <summary>
/// DVH Dose Scaling (3004;0052) DS 1
/// </summary>
  K_CMDCMTDvhDoseScaling = $30040052;

/// <summary>
/// DVH Volume Units (3004;0054) CS 1
/// </summary>
  K_CMDCMTDvhVolumeUnits = $30040054;

/// <summary>
/// DVH Number of Bins (3004;0056) IS 1
/// </summary>
  K_CMDCMTDvhNumberOfBins = $30040056;

/// <summary>
/// DVH Data (3004;0058) DS 2-2n
/// </summary>
  K_CMDCMTDvhData = $30040058;

/// <summary>
/// DVH Referenced ROI Sequence (3004;0060) SQ 1
/// </summary>
  K_CMDCMTDvhReferencedRoiSequence = $30040060;

/// <summary>
/// DVH ROI Contribution Type (3004;0062) CS 1
/// </summary>
  K_CMDCMTDvhRoiContributionType = $30040062;

/// <summary>
/// DVH Minimum Dose (3004;0070) DS 1
/// </summary>
  K_CMDCMTDvhMinimumDose = $30040070;

/// <summary>
/// DVH Maximum Dose (3004;0072) DS 1
/// </summary>
  K_CMDCMTDvhMaximumDose = $30040072;

/// <summary>
/// DVH Mean Dose (3004;0074) DS 1
/// </summary>
  K_CMDCMTDvhMeanDose = $30040074;
    
// GROUP 3006
/// <summary>
// GROUP 3006 Group Length (3006;0000) UL 1
/// </summary>
  K_CMDCMTGroup3006GroupLength = $30060000;

/// <summary>
/// Structure Set Label (3006;0002) SH 1
/// </summary>
  K_CMDCMTStructureSetLabel = $30060002;

/// <summary>
/// Structure Set Name (3006;0004) LO 1
/// </summary>
  K_CMDCMTStructureSetName = $30060004;

/// <summary>
/// Structure Set Description (3006;0006) ST 1
/// </summary>
  K_CMDCMTStructureSetDescription = $30060006;

/// <summary>
/// Structure Set Date (3006;0008) DA 1
/// </summary>
  K_CMDCMTStructureSetDate = $30060008;

/// <summary>
/// Structure Set Date (3006;0009) TM 1
/// </summary>
  K_CMDCMTStructureSetTime = $30060009;

/// <summary>
/// Referenced Frame of Reference Sequence (3006;0010) SQ 1
/// </summary>
  K_CMDCMTReferencedFrameOfReferenceSequence = $30060010;

/// <summary>
/// RT Referenced Study Sequence (3006;0012) SQ 1
/// </summary>
  K_CMDCMTRTReferencedStudySequence = $30060012;

/// <summary>
/// RT Referenced Series Sequence (3006;0014) SQ 1
/// </summary>
  K_CMDCMTRTReferencedSeriesSequence = $30060014;

/// <summary>
/// Contour Image Sequence (3006;0016) SQ 1
/// </summary>
  K_CMDCMTContourImageSequence = $30060016;

/// <summary>
/// Structure Set ROI Sequence (3006;0020) SQ 1
/// </summary>
  K_CMDCMTStructureSetRoiSequence = $30060020;

/// <summary>
/// ROI Number (3006;0022) IS 1
/// </summary>
  K_CMDCMTRoiNumber = $30060022;

/// <summary>
/// Referenced Frame of Reference UID (3006;0024) UI 1
/// </summary>
  K_CMDCMTReferencedFrameOfReferenceUid = $30060024;

/// <summary>
/// ROI Name (3006;0026) LO 1
/// </summary>
  K_CMDCMTRoiName = $30060026;

/// <summary>
/// ROI Description (3006;0028) ST 1
/// </summary>
  K_CMDCMTRoiDescription = $30060028;

/// <summary>
/// ROI Display Color (3006;002A) IS 3
/// </summary>
  K_CMDCMTRoiDisplayColor = $3006002A;

/// <summary>
/// ROI Volume (3006;002C) DS 1
/// </summary>
  K_CMDCMTRoiVolume = $3006002C;

/// <summary>
/// RT Related ROI Sequence (3006;0030) SQ 1
/// </summary>
  K_CMDCMTRTRelatedRoiSequence = $30060030;

/// <summary>
/// RT ROI Relationship (3006;0033) CS 1
/// </summary>
  K_CMDCMTRTRoiRelationship = $30060033;

/// <summary>
/// ROI Generation Algorithm (3006;0036) CS 1
/// </summary>
  K_CMDCMTRoiGenerationAlgorithm = $30060036;

/// <summary>
/// ROI Generation Description (3006;0038) LO 1
/// </summary>
  K_CMDCMTRoiGenerationDescription = $30060038;

/// <summary>
/// ROI Contour Sequence (3006;0039) SQ 1
/// </summary>
  K_CMDCMTRoiContourSequence = $30060039;

/// <summary>
/// Contour Sequence (3006;0040) SQ 1
/// </summary>
  K_CMDCMTContourSequence = $30060040;

/// <summary>
/// Contour Geometric Type (3006;0042) CS 1
/// </summary>
  K_CMDCMTContourGeometricType = $30060042;

/// <summary>
/// Contour Slab Thickness (3006;0044) DS 1
/// </summary>
  K_CMDCMTContourSlabThickness = $30060044;

/// <summary>
/// Contour Offset Vector (3006;0045) DS 3
/// </summary>
  K_CMDCMTContourOffsetVector = $30060045;

/// <summary>
/// Number of Contour Points (3006;0046) IS 1
/// </summary>
  K_CMDCMTNumberOfContourPoints = $30060046;

/// <summary>
/// Contour Number (3006;0048) IS 1
/// </summary>
  K_CMDCMTContourNumber = $30060048;

/// <summary>
/// Attached Contours (3006;0049) IS 1-n
/// </summary>
  K_CMDCMTAttachedContours = $30060049;

/// <summary>
/// Contour Data (3006;0050) DS 3-3n
/// </summary>
  K_CMDCMTContourData = $30060050;

/// <summary>
/// RT ROI Observations Sequence (3006;0080) SQ 1
/// </summary>
  K_CMDCMTRTRoiObservationsSequence = $30060080;

/// <summary>
/// Observation Number (3006;0082) IS 1
/// </summary>
  K_CMDCMTObservationNumber = $30060082;

/// <summary>
/// Referenced ROI Number (3006;0084) IS 1
/// </summary>
  K_CMDCMTReferencedRoiNumber = $30060084;

/// <summary>
/// ROI Observation Label (3006;0085) SH 1
/// </summary>
  K_CMDCMTRoiObservationLabel = $30060085;

/// <summary>
/// RT ROI Identification Code Sequence (3006;0086) SQ 1
/// </summary>
  K_CMDCMTRTRoiIdentificationCodeSequence = $30060086;

/// <summary>
/// ROI Observation Description (3006;0088) ST 1
/// </summary>
  K_CMDCMTRoiObservationDescription = $30060088;

/// <summary>
/// Related RT ROI Observation Sequence (3006;00A0) SQ 1
/// </summary>
  K_CMDCMTRelatedRTRoiObservationsSequence = $300600A0;

/// <summary>
/// RT ROI Interpreted Type (3006;00A4) CS 1
/// </summary>
  K_CMDCMTRTRoiInterpretedType = $300600A4;

/// <summary>
/// ROI Interpreter (3006;00A6) PN 1
/// </summary>
  K_CMDCMTRoiInterpreter = $300600A6;

/// <summary>
/// ROI Physical Properties Sequence (3006;00B0) SQ 1
/// </summary>
  K_CMDCMTRoiPhysicalPropertiesSequence = $300600B0;

/// <summary>
/// ROI Physical Property (3006;00B2) CS 1
/// </summary>
  K_CMDCMTRoiPhysicalProperty = $300600B2;

/// <summary>
/// ROI Physical Property Value (3006;00B4) DS 1
/// </summary>
  K_CMDCMTRoiPhysicalPropertyValue = $300600B4;

/// <summary>
/// Frame of Reference Relationship Sequence (3006;00C0) SQ 1
/// </summary>
  K_CMDCMTFrameOfReferenceRelationshipSequence = $300600C0;

/// <summary>
/// Related Frame of Reference UID (3006;00C2) UI 1
/// </summary>
  K_CMDCMTRelatedFrameOfReferenceUid = $300600C2;

/// <summary>
/// Frame of Reference Transformaiton Type (3006;00C4) CS 1
/// </summary>
  K_CMDCMTFrameOfReferenceTransformationType = $300600C4;

/// <summary>
/// Frame of Reference Transformation Matrix (3006;00C6) DS 16
/// </summary>
  K_CMDCMTFrameOfReferenceTransformationMatrix = $300600C6;

/// <summary>
/// Frame of Reference Transformation Comment (3006;00C8) LO 1
/// </summary>
  K_CMDCMTFrameOfReferenceTransformationComment = $300600C8;
    
// GROUP 3008
/// <summary>
// GROUP 3008 Group Length (3008;0000) UL 1
/// </summary>
  K_CMDCMTGroup3008GroupLength = $30080000;

/// <summary>
/// Measured Dose Reference Sequence (3008;0010) SQ 1
/// </summary>
  K_CMDCMTMeasuredDoseReferenceSequence = $30080010;

/// <summary>
/// Measured Dose Description (3008;0012) ST 1
/// </summary>
  K_CMDCMTMeasuredDoseDescription = $30080012;

/// <summary>
/// Measured Dose Type (3008;0014) CS 1
/// </summary>
  K_CMDCMTMeasuredDoseType = $30080014;

/// <summary>
/// Measured Dose Value (3008;0016) DS 1
/// </summary>
  K_CMDCMTMeasuredDoseValue = $30080016;

/// <summary>
/// Treatment Session Beam Sequence (3008;0020) SQ 1
/// </summary>
  K_CMDCMTTreatmentSessionBeamSequence = $30080020;

/// <summary>
/// Treatment Session Ion Beam Sequence (3008;0021) SQ 1
/// </summary>
  K_CMDCMTTreatmentSessionIonBeamSequence = $30080021;

/// <summary>
/// Current Fraction Number (3008;0022) IS 1
/// </summary>
  K_CMDCMTCurrentFractionNumber = $30080022;

/// <summary>
/// Treatment Control Point Date (3008;0024) DA 1
/// </summary>
  K_CMDCMTTreatmentControlPointDate = $30080024;

/// <summary>
/// Treatment Control Point Time (3008;0025) TM 1
/// </summary>
  K_CMDCMTTreatmentControlPointTime = $30080025;

/// <summary>
/// Treatment Termination Status (3008;002A) CS 1
/// </summary>
  K_CMDCMTTreatmentTerminationStatus = $3008002A;

/// <summary>
/// Treatment Termination Code (3008;002B) SH 1
/// </summary>
  K_CMDCMTTreatmentTerminationCode = $3008002B;

/// <summary>
/// Treatment Verificaiton Status (3008;002C) CS 1
/// </summary>
  K_CMDCMTTreatmentVerificationStatus = $3008002C;

/// <summary>
/// Referenced Treatment Record Sequence (3008;0030) SQ 1
/// </summary>
  K_CMDCMTReferencedTreatmentRecordSequence = $30080030;

/// <summary>
/// Specified Primary Meterset (3008;0032) DS 1
/// </summary>
  K_CMDCMTSpecifiedPrimaryMeterset = $30080032;

/// <summary>
/// Specified Secondary Meterset (3008;0033) DS 1
/// </summary>
  K_CMDCMTSpecifiedSecondaryMeterset = $30080033;

/// <summary>
/// Delivered Primary Meterset (3008;0036) DS 1
/// </summary>
  K_CMDCMTDeliveredPrimaryMeterset = $30080036;

/// <summary>
/// Delivered Secondary Meterset (3008;0037) DS 1
/// </summary>
  K_CMDCMTDeliveredSecondaryMeterset = $30080037;

/// <summary>
/// Specified Treatment Time (3008;003A) DS 1
/// </summary>
  K_CMDCMTSpecifiedTreatmentTime = $3008003A;

/// <summary>
/// Delivered Treatment Time (3008;003B) DS 1
/// </summary>
  K_CMDCMTDeliveredTreatmentTime = $3008003B;

/// <summary>
/// Control Point Delivery Sequence (3008;0040) SQ 1
/// </summary>
  K_CMDCMTControlPointDeliverySequence = $30080040;

/// <summary>
/// Ion Control Point Delivery Sequence (3008;0041) SQ 1
/// </summary>
  K_CMDCMTIonControlPointDeliverySequence = $30080041;

/// <summary>
/// Specified Meterset (3008;0042) DS 1
/// </summary>
  K_CMDCMTSpecifiedMeterset = $30080042;

/// <summary>
/// Delivered Meterset (3008;0044) DS 1
/// </summary>
  K_CMDCMTDeliveredMeterset = $30080044;

/// <summary>
/// Meterset Rate Set (3008;0045) FL 1
/// </summary>
  K_CMDCMTMetersetRateSet = $30080045;

/// <summary>
/// Meterset Rate Delivered (3008;0046) FL 1
/// </summary>
  K_CMDCMTMetersetRateDelivered = $30080046;

/// <summary>
/// Scan Spot Metersets Delivered (3008;0047) FL 1-n
/// </summary>
  K_CMDCMTScanSpotMetersetsDelivered = $30080047;

/// <summary>
/// Dose Rate Delivered (3008;0048) DS 1
/// </summary>
  K_CMDCMTDoseRateDelivered = $30080048;

/// <summary>
/// Treatment Summary Calculated Dose Reference Sequence (3008;0050) SQ 1
/// </summary>
  K_CMDCMTTreatmentSummaryCalculatedDoseReferenceSequence = $30080050;

/// <summary>
/// Cumulative Dose to Dose Reference (3008;0052) DS 1
/// </summary>
  K_CMDCMTCumulativeDoseToDoseReference = $30080052;

/// <summary>
/// First Treatment Date (3008;0054) DA 1
/// </summary>
  K_CMDCMTFirstTreatmentDate = $30080054;

/// <summary>
/// Most Recent Treatment Date (3008;0056) DA 1
/// </summary>
  K_CMDCMTMostRecentTreatmentDate = $30080056;

/// <summary>
/// Number of Fractions Delivered (3008;005A) IS 1
/// </summary>
  K_CMDCMTNumberOfFractionsDelivered = $3008005A;

/// <summary>
/// Override Sequence (3008;0060) SQ 1
/// </summary>
  K_CMDCMTOverrideSequence = $30080060;

/// <summary>
/// Parameter Sequence Pointer (3008;0061) AT 1
/// </summary>
  K_CMDCMTParameterSequencePointer = $30080061;

/// <summary>
/// Override Parameter Pointer (3008;0062) AT 1
/// </summary>
  K_CMDCMTOverrideParameterPointer = $30080062;

/// <summary>
/// Parameter Item Index (3008;0063) IS 1
/// </summary>
  K_CMDCMTParameterItemIndex = $30080063;

/// <summary>
/// Measured Dose Reference Number (3008;0064) IS 1
/// </summary>
  K_CMDCMTMeasuredDoseReferenceNumber = $30080064;

/// <summary>
/// Parameter Pointer (3008;0065) AT 1
/// </summary>
  K_CMDCMTParameterPointer = $30080065;

/// <summary>
/// Override Reason (3008;0066) ST 1
/// </summary>
  K_CMDCMTOverrideReason = $30080066;

/// <summary>
/// Corrected Parameter Sequence (3008;0068) SQ 1
/// </summary>
  K_CMDCMTCorrectedParameterSequence = $30080068;

/// <summary>
/// Correction Value (3008;006A) FL 1
/// </summary>
  K_CMDCMTCorrectionValue = $3008006A;

/// <summary>
/// Calculated Dose Reference Sequence (3008;0070) SQ 1
/// </summary>
  K_CMDCMTCalculatedDoseReferenceSequence = $30080070;

/// <summary>
/// Calculated Dose Reference Number (3008;0072) IS 1
/// </summary>
  K_CMDCMTCalculatedDoseReferenceNumber = $30080072;

/// <summary>
/// Calculated Dose Reference Description (3008;0074) ST 1
/// </summary>
  K_CMDCMTCalculatedDoseReferenceDescription = $30080074;

/// <summary>
/// Calculated Dose Reference Dose Value (3008;0076) DS 1
/// </summary>
  K_CMDCMTCalculatedDoseReferenceDoseValue = $30080076;

/// <summary>
/// Start Meterset (3008;0078) DS 1
/// </summary>
  K_CMDCMTStartMeterset = $30080078;

/// <summary>
/// End Meterset (3008;007A) DS 1
/// </summary>
  K_CMDCMTEndMeterset = $3008007A;

/// <summary>
/// Referenced Measured Dose Reference Sequence (3008;0080) SQ 1
/// </summary>
  K_CMDCMTReferencedMeasuredDoseReferenceSequence = $30080080;

/// <summary>
/// Referenced Measured Dose Reference Number (3008;0082) IS 1
/// </summary>
  K_CMDCMTReferencedMeasuredDoseReferenceNumber = $30080082;

/// <summary>
/// Referenced Calculated Dose Reference Sequence (3008;0090) SQ 1
/// </summary>
  K_CMDCMTReferencedCalculatedDoseReferenceSequence = $30080090;

/// <summary>
/// Referenced Calculated Dose Reference Number (3008;0092) IS 1
/// </summary>
  K_CMDCMTReferencedCalculatedDoseReferenceNumber = $30080092;

/// <summary>
/// Beam Limiting Device Leaf Pairs Sequence (3008;00A0) SQ 1
/// </summary>
  K_CMDCMTBeamLimitingDeviceLeafPairsSequence = $300800A0;

/// <summary>
/// Recorded Wedge Sequence (3008;00B0) SQ 1
/// </summary>
  K_CMDCMTRecordedWedgeSequence = $300800B0;

/// <summary>
/// Recorded Compensator Sequence (3008;00C0) SQ 1
/// </summary>
  K_CMDCMTRecordedCompensatorSequence = $300800C0;

/// <summary>
/// Recorded Block Sequence (3008;00D0) SQ 1
/// </summary>
  K_CMDCMTRecordedMaticsSequence = $300800D0;

/// <summary>
/// Treatment Summary Measured Dose Reference Sequence (3008;00E0) SQ 1
/// </summary>
  K_CMDCMTTreatmentSummaryMeasuredDoseReferenceSequence = $300800E0;

/// <summary>
/// Recorded Snout Sequence (3008;00F0) SQ 1
/// </summary>
  K_CMDCMTRecordedSnoutSequence = $300800F0;

/// <summary>
/// Recorded Range Shifter Sequence (3008;00F2) SQ 1
/// </summary>
  K_CMDCMTRecordedRangeShifterSequence = $300800F2;

/// <summary>
/// Recorded Lateral Spreading Device Sequence (3008;00F4) SQ 1
/// </summary>
  K_CMDCMTRecordedLateralSpreadingDeviceSequence = $300800F4;

/// <summary>
/// Recorded Range Modulator Sequence (3008;00F6) SQ 1
/// </summary>
  K_CMDCMTRecordedRangeModulatorSequence = $300800F6;

/// <summary>
/// Recorded Source Sequence (3008;0100) SQ 1
/// </summary>
  K_CMDCMTRecordedSourceSequence = $30080100;

/// <summary>
/// Source Serial Number (3008;0105) LO 1
/// </summary>
  K_CMDCMTSourceSerialNumber = $30080105;

/// <summary>
/// Treatment Session Application Setup Sequence (3008;0110) SQ 1
/// </summary>
  K_CMDCMTTreatmentSessionApplicationSetupSequence = $30080110;

/// <summary>
/// Application Setup Check (3008;0116) CS 1
/// </summary>
  K_CMDCMTApplicationSetupCheck = $30080116;

/// <summary>
/// Recorded Brachy Accessory Device Sequence (3008;0120) SQ 1
/// </summary>
  K_CMDCMTRecordedBrachyAccessoryDeviceSequence = $30080120;

/// <summary>
/// Referenced Brachy Accessory Device Number (3008;0122) IS 1
/// </summary>
  K_CMDCMTReferencedBrachyAccessoryDeviceNumber = $30080122;

/// <summary>
/// Recorded Channel Sequence (3008;0130) SQ 1
/// </summary>
  K_CMDCMTRecordedChannelSequence = $30080130;

/// <summary>
/// Specified Channel Total Time (3008;0132) DS 1
/// </summary>
  K_CMDCMTSpecifiedChannelTotalTime = $30080132;

/// <summary>
/// Delivered Channel Total Time (3008;0134) DS 1
/// </summary>
  K_CMDCMTDeliveredChannelTotalTime = $30080134;

/// <summary>
/// Specified Number of Pulses (3008;0136) IS 1
/// </summary>
  K_CMDCMTSpecifiedNumberOfPulses = $30080136;

/// <summary>
/// Delivered Number of Pulses (3008;0138) IS 1
/// </summary>
  K_CMDCMTDeliveredNumberOfPulses = $30080138;

/// <summary>
/// Specified Pulse Repetition Interval (3008;013A) DS 1
/// </summary>
  K_CMDCMTSpecifiedPulseRepetitionInterval = $3008013A;

/// <summary>
/// Delivered Pulse Repetition Interval (3008;013C) DS 
/// </summary>
  K_CMDCMTDeliveredPulseRepetitionInterval = $3008013C;

/// <summary>
/// Recorded Source Applicator Sequence (3008;0140) SQ 1
/// </summary>
  K_CMDCMTRecordedSourceApplicatorSequence = $30080140;

/// <summary>
/// Referenced Source Applicator Number (3008;0142) IS 1
/// </summary>
  K_CMDCMTReferencedSourceApplicatorNumber = $30080142;

/// <summary>
/// Recorded Channel Shield Sequence (3008;0150) SQ 1
/// </summary>
  K_CMDCMTRecordedChannelShieldSequence = $30080150;

/// <summary>
/// Referenced Channel Shield Number (3008;0152) IS 1
/// </summary>
  K_CMDCMTReferencedChannelShieldNumber = $30080152;

/// <summary>
/// Brachy Control Point Delivered Sequence (3008;0160) SQ 1
/// </summary>
  K_CMDCMTBrachyControlPointDeliveredSequence = $30080160;

/// <summary>
/// Safe Position Exit Date (3008;0162) DA 1
/// </summary>
  K_CMDCMTSafePositionExitDate = $30080162;

/// <summary>
/// Safe Position Exit Time (3008;0164) TM 1
/// </summary>
  K_CMDCMTSafePositionExitTime = $30080164;

/// <summary>
/// Safe Position Return Date (3008;0166) DA 1
/// </summary>
  K_CMDCMTSafePositionReturnDate = $30080166;

/// <summary>
/// Safe Position Return Time (3008;0168) TM 1
/// </summary>
  K_CMDCMTSafePositionReturnTime = $30080168;

/// <summary>
/// Current Treatment Status (3008;0200) CS 1
/// </summary>
  K_CMDCMTCurrentTreatmentStatus = $30080200;

/// <summary>
/// Treatment Status Comment (3008;0202) ST 1
/// </summary>
  K_CMDCMTTreatmentStatusComment = $30080202;

/// <summary>
/// Fraction Group Summary Sequence (3008;0220) SQ 1
/// </summary>
  K_CMDCMTFractionGroupSummarySequence = $30080220;

/// <summary>
/// Referenced Fraction Number (3008;0223) IS 1
/// </summary>
  K_CMDCMTReferencedFractionNumber = $30080223;

/// <summary>
/// Fraction Group Type (3008;0224) CS 1
/// </summary>
  K_CMDCMTFractionGroupType = $30080224;

/// <summary>
/// Beam Stopper Position (3008;0230) CS 1
/// </summary>
  K_CMDCMTBeamStopperPosition = $30080230;

/// <summary>
/// Fraction Status Summary Sequence (3008;0240) SQ 1
/// </summary>
  K_CMDCMTFractionStatusSummarySequence = $30080240;

/// <summary>
/// Treatment Date (3008;0250) DA 1
/// </summary>
  K_CMDCMTTreatmentDate = $30080250;

/// <summary>
/// Treatment Time (3008;0251) TM 1
/// </summary>
  K_CMDCMTTreatmentTime = $30080251;
    
// GROUP 300A
/// <summary>
// GROUP 300A Group Length (300A;0000) UL 1
/// </summary>
  K_CMDCMTGroup300AGroupLength = $300A0000;

/// <summary>
/// RT Plan Label (300A;0002) SH 1
/// </summary>
  K_CMDCMTRTPlanLabel = $300A0002;

/// <summary>
/// RT Plan Name (300A;0003) LO 1
/// </summary>
  K_CMDCMTRTPlanName = $300A0003;

/// <summary>
/// RT Plan Description (300A;0004) ST 1
/// </summary>
  K_CMDCMTRTPlanDescription = $300A0004;

/// <summary>
/// RT Plan Date (300A;0006) DA 1
/// </summary>
  K_CMDCMTRTPlanDate = $300A0006;

/// <summary>
/// RT Plan Time (300A;0007) TM 1
/// </summary>
  K_CMDCMTRTPlanTime = $300A0007;

/// <summary>
/// Treatment Protocols (300A;0009) LO 1-n
/// </summary>
  K_CMDCMTTreatmentProtocols = $300A0009;

/// <summary>
/// Plan Intent (300A;000A) CS 1
/// </summary>
  K_CMDCMTPlanIntent = $300A000A;

/// <summary>
/// Treatment Sites (300A;000B) LO 1-n
/// </summary>
  K_CMDCMTTreatmentSites = $300A000B;

/// <summary>
/// RT Plan Geometry (300A;000C) CS 1
/// </summary>
  K_CMDCMTRTPlanGeometry = $300A000C;

/// <summary>
/// Prescription Description (300A;000E) ST 1
/// </summary>
  K_CMDCMTPrescriptionDescription = $300A000E;

/// <summary>
/// Dose Reference Sequence (300A;0010) SQ 1
/// </summary>
  K_CMDCMTDoseReferenceSequence = $300A0010;

/// <summary>
/// Dose Reference Number (300A;0012) IS 1
/// </summary>
  K_CMDCMTDoseReferenceNumber = $300A0012;

/// <summary>
/// Dose Reference UID (300A;0013) UI 1
/// </summary>
  K_CMDCMTDoseReferenceUid = $300A0013;

/// <summary>
/// Dose Reference Structure Type (300A;0014) CS 1
/// </summary>
  K_CMDCMTDoseReferenceStructureType = $300A0014;

/// <summary>
/// Nominal Beam Energy Unit (300A;0015) CS 1
/// </summary>
  K_CMDCMTNominalBeamEnergyUnit = $300A0015;

/// <summary>
/// Dose Reference Description (300A;0016) LO 1
/// </summary>
  K_CMDCMTDoseReferenceDescription = $300A0016;

/// <summary>
/// Dose Reference Point Coordinates (300A;0018) DS 3
/// </summary>
  K_CMDCMTDoseReferencePointCoordinates = $300A0018;

/// <summary>
/// Nominal Prior Dose (300A;001A) DS 1
/// </summary>
  K_CMDCMTNominalPriorDose = $300A001A;

/// <summary>
/// Dose Reference Type (300A;0020) CS 1
/// </summary>
  K_CMDCMTDoseReferenceType = $300A0020;

/// <summary>
/// Constraint Weight (300A;0021) DS 1
/// </summary>
  K_CMDCMTConstraintWeight = $300A0021;

/// <summary>
/// Delivery Warning Dose (300A;0022) DS 1
/// </summary>
  K_CMDCMTDeliveryWarningDose = $300A0022;

/// <summary>
/// Delivery Maximum Dose (300A;0023) DS 1
/// </summary>
  K_CMDCMTDeliveryMaximumDose = $300A0023;

/// <summary>
/// Target Minimum Dose (300A;0025) DS 1
/// </summary>
  K_CMDCMTTargetMinimumDose = $300A0025;

/// <summary>
/// Target Prescription Dose (300A;0026) DS 1
/// </summary>
  K_CMDCMTTargetPrescriptionDose = $300A0026;

/// <summary>
/// Target Maximum Dose (300A;0027) DS 1
/// </summary>
  K_CMDCMTTargetMaximumDose = $300A0027;

/// <summary>
/// Target Underdose Volume Fraction (300A;0028) DS 1
/// </summary>
  K_CMDCMTTargetUnderdoseVolumeFraction = $300A0028;

/// <summary>
/// Organ at Risk Full-volume Dose (300A;002A) DS 1
/// </summary>
  K_CMDCMTOrganAtRiskFullVolumeDose = $300A002A;

/// <summary>
/// Organ at Risk Limit Dose (300A;002B) DS 1
/// </summary>
  K_CMDCMTOrganAtRiskLimitDose = $300A002B;

/// <summary>
/// Organ at Risk Maximum Dose (300A;002C) DS 1
/// </summary>
  K_CMDCMTOrganAtRiskMaximumDose = $300A002C;

/// <summary>
/// Organ at Risk Overdose Volume Fraction (300A;002D) DS 1
/// </summary>
  K_CMDCMTOrganAtRiskOverdoseVolumeFraction = $300A002D;

/// <summary>
/// Tolerance Table Sequence (300A;0040) SQ 1
/// </summary>
  K_CMDCMTToleranceTableSequence = $300A0040;

/// <summary>
/// Tolerance Table Number (300A;0042) IS 1
/// </summary>
  K_CMDCMTToleranceTableNumber = $300A0042;

/// <summary>
/// Tolerance Table Label (300A;0043) SH 1
/// </summary>
  K_CMDCMTToleranceTableLabel = $300A0043;

/// <summary>
/// Gantry Angle Tolerance (300A;0044) DS 1
/// </summary>
  K_CMDCMTGantryAngleTolerance = $300A0044;

/// <summary>
/// Beam Limiting Device Angle Tolerance (300A;0046) DS 1 
/// </summary>
  K_CMDCMTBeamLimitingDeviceAngleTolerance = $300A0046;

/// <summary>
/// Beam Limiting Device Tolerance Sequence (300A;0048) SQ 1
/// </summary>
  K_CMDCMTBeamLimitingDeviceToleranceSequence = $300A0048;

/// <summary>
/// Beam Limiting Device Position Tolerance (300A;004A) DS 1
/// </summary>
  K_CMDCMTBeamLimitingDevicePositionTolerance = $300A004A;

/// <summary>
/// Snout Position Tolerance (300A;004B) FL 1
/// </summary>
  K_CMDCMTSnoutPositionTolerance = $300A004B;

/// <summary>
/// Patient Support Angle Tolerance (300A;004C) DS 1
/// </summary>
  K_CMDCMTPatientSupportAngleTolerance = $300A004C;

/// <summary>
/// Table Top Eccentric Angle Tolerance (300A;004E) DS 1
/// </summary>
  K_CMDCMTTableTopEccentricAngleTolerance = $300A004E;

/// <summary>
/// Table Top Pitch Angle Tolerance (300A;004F) FL 1
/// </summary>
  K_CMDCMTTableTopPitchAngleTolerance = $300A004F;

/// <summary>
/// Table Top Roll Angle Tolerance (300A;0050) FL 1
/// </summary>
  K_CMDCMTTableTopRollAngleTolerance = $300A0050;

/// <summary>
/// Table Top Vertical Position Tolerance (300A;0051) DS 1
/// </summary>
  K_CMDCMTTabletopVerticalPositionTolerance = $300A0051;

/// <summary>
/// Table Top Longitudinal Position Tolerance (300A;0052) DS 1
/// </summary>
  K_CMDCMTTabletopLongitudinalPositionTolerance = $300A0052;

/// <summary>
/// Table Top Lateral Position Tolerance (300A;0053) DS 1
/// </summary>
  K_CMDCMTTableTopLateralPositionTolerance = $300A0053;

/// <summary>
/// RT Plan Relationship (300A;0055) CS 1
/// </summary>
  K_CMDCMTRTPlanRelationship = $300A0055;

/// <summary>
/// Fraction Group Sequence (300A;0070) IS 1
/// </summary>
  K_CMDCMTFractionGroupSequence = $300A0070;

/// <summary>
/// Fraction Group Number (300A;0071) IS 1
/// </summary>
  K_CMDCMTFractionGroupNumber = $300A0071;

/// <summary>
/// Fraction Group Description (300A;0072) LO 1
/// </summary>
  K_CMDCMTFractionGroupDescription = $300A0072;

/// <summary>
/// Number of Fractions Planned (300A;0078) IS 1
/// </summary>
  K_CMDCMTNumberOfFractionsPlanned = $300A0078;

/// <summary>
/// Number of Fraction Pattern Digits Per day (300A;0079) IS 1
/// </summary>
  K_CMDCMTNumberOfFractionPatternDigitsPerDay = $300A0079;

/// <summary>
/// Repeat Fraction Cycle Length (300A;007A) IS 1
/// </summary>
  K_CMDCMTRepeatFractionCycleLength = $300A007A;

/// <summary>
/// Fraction Pattern (300A;007B) LT 1
/// </summary>
  K_CMDCMTFractionPattern = $300A007B;

/// <summary>
/// Number of Beams (300A;0080) IS 1
/// </summary>
  K_CMDCMTNumberOfBeams = $300A0080;

/// <summary>
/// Beam Dose Specification Point (300A;0082) DS 3
/// </summary>
  K_CMDCMTBeamDoseSpecificationPoint = $300A0082;

/// <summary>
/// Beam Dose (300A;0084) DS 1
/// </summary>
  K_CMDCMTBeamDose = $300A0084;

/// <summary>
/// Beam Meterset (300A;0086) DS 1
/// </summary>
  K_CMDCMTBeamMeterset = $300A0086;

/// <summary>
/// Number of Brachy Application Setups (300A;00A0) IS 1
/// </summary>
  K_CMDCMTNumberOfBrachyApplicationSetups = $300A00A0;

/// <summary>
/// Brachy Application Setup Dose Specification Point (300A;00A2) DS 3
/// </summary>
  K_CMDCMTBrachyApplicationSetupDoseSpecificationPoint = $300A00A2;

/// <summary>
/// Brachy Application Setup Dose (300A;00A4) DS 1
/// </summary>
  K_CMDCMTBrachyApplicationSetupDose = $300A00A4;

/// <summary>
/// Beam Sequence (300A;00B0) SQ 1
/// </summary>
  K_CMDCMTBeamSequence = $300A00B0;

/// <summary>
/// Treatment Machine Name (300A;00B2) SH 1
/// </summary>
  K_CMDCMTTreatmentMachineName = $300A00B2;

/// <summary>
/// Primary Dosimeter Unit (300A;00B3) CS 1
/// </summary>
  K_CMDCMTPrimaryDosimeterUnit = $300A00B3;

/// <summary>
/// Source Axis Distance (300A;00B4) DS 1
/// </summary>
  K_CMDCMTSourceAxisDistance = $300A00B4;

/// <summary>
/// Beam Limiting Device Sequence (300A;00B6) SQ 1
/// </summary>
  K_CMDCMTBeamLimitingDeviceSequence = $300A00B6;

/// <summary>
/// RT Beam Limiting Device Type (300A;00B8) CS 1
/// </summary>
  K_CMDCMTRTBeamLimitingDeviceType = $300A00B8;

/// <summary>
/// Source to Beam Limiting Device Distance (300A;00BA) DS 1
/// </summary>
  K_CMDCMTSourceToBeamLimitingDeviceDistance = $300A00BA;

/// <summary>
/// Isocenter To Beam Limiting Device Distance (300A;00BB) FL 1
/// </summary>
  K_CMDCMTIsocenterToBeamLimitingDeviceDistance = $300A00BB;

/// <summary>			
/// Number of Leaf/Jaw Pairs (300A;00BC) IS 1
/// </summary>
  K_CMDCMTNumberOfLeafJawPairs = $300A00BC;

/// <summary>
/// Leaf Position Boundaries (300A;00BE) DS 3-n
/// </summary>
  K_CMDCMTLeafPositionBoundaries = $300A00BE;

/// <summary>
/// Beam Number (300A;00C0) IS 1
/// </summary>
  K_CMDCMTBeamNumber = $300A00C0;

/// <summary>
/// Beam Name (300A;00C2) LO 1
/// </summary>
  K_CMDCMTBeamName = $300A00C2;

/// <summary>
/// Beam Description (300A;00C3) ST 1
/// </summary>
  K_CMDCMTBeamDescription = $300A00C3;

/// <summary>
/// Beam Type (300A;00C4) CS 1
/// </summary>
  K_CMDCMTBeamType = $300A00C4;

/// <summary>
/// Radiation Type (300A;00C6) CS 1
/// </summary>
  K_CMDCMTRadiationType = $300A00C6;

/// <summary>
/// High-Dose Technique Type (300A;00C7) CS 1
/// </summary>
  K_CMDCMTHighDoseTechniqueType = $0300A00C7;

/// <summary>
/// Reference Image Number (300A;00C8) IS 1
/// </summary>
  K_CMDCMTReferenceImageNumber = $300A00C8;

/// <summary>
/// Planned Verificaiton Image Sequence (300A;00CA) SQ 1
/// </summary>
  K_CMDCMTPlannedVerificationImageSequence = $300A00CA;

/// <summary>
/// Imaging Device-Specific Acquisition Parameters (300A;00CC) LO 1-n
/// </summary>
  K_CMDCMTImagingDeviceSpecificAcquisitionParameters = $300A00CC;

/// <summary>
/// Treatment Delivery Type (300A;00CE) CS 1
/// </summary>
  K_CMDCMTTreatmentDeliveryType = $300A00CE;

/// <summary>
/// Number of Wedges (300A;00D0) IS 1
/// </summary>
  K_CMDCMTNumberOfWedges = $300A00D0;

/// <summary>
/// Wedge Sequence (300A;00D1) SQ 1
/// </summary>
  K_CMDCMTWedgeSequence = $300A00D1;

/// <summary>
/// Wedge Number (300A;00D2) IS 1
/// </summary>
  K_CMDCMTWedgeNumber = $300A00D2;

/// <summary>
/// Wedge Type (300A;00D3) CS 1
/// </summary>
  K_CMDCMTWedgeType = $300A00D3;

/// <summary>			
/// Wedge ID (300A;00D4) SH 1
/// </summary>
  K_CMDCMTWedgeId = $300A00D4;

/// <summary>
/// Wedge Angle (300A;00D5) IS 1
/// </summary>
  K_CMDCMTWedgeAngle = $300A00D5;

/// <summary>
/// Wedge Factor (300A;00D6) DS 1
/// </summary>
  K_CMDCMTWedgeFactor = $300A00D6;

/// <summary>
/// Total Wedge Tray Water-Equivalent Thickness (300A;00D7) FL 1
/// </summary>
  K_CMDCMTTotalWedgeTrayWaterEquivalentThickness = $300A00D7;

/// <summary>
/// Wedge Orientation (300A;00D8) DS 1
/// </summary>
  K_CMDCMTWedgeOrientation = $300A00D8;

/// <summary>
/// Isocenter To Wedge Tray Distance (300A;00D9) FL 1
/// </summary>
  K_CMDCMTIsocenterToWedgeTrayDistance = $300A00D9;

/// <summary>
/// Source to Wedge Tray Distance (300A;00DA) DS 1
/// </summary>
  K_CMDCMTSourceToWedgeTrayDistance = $300A00DA;

/// <summary>
/// Wedge Thin Edge Position (300A;00DB) FL 1
/// </summary>
  K_CMDCMTWedgeThinEdgePosition = $300A00DB;

/// <summary>
/// Bolus ID   (300A;00DC) SH 1
/// </summary>
  K_CMDCMTBolusID = $300A00DC;

/// <summary>
/// Bolus Description    K_CMDCMT (300A;00DD) ST 1
/// </summary>
  K_CMDCMTBolusDescription = $300A00DD;

/// <summary>
/// Number of Compensators (300A;00E0) IS 1
/// </summary>
  K_CMDCMTNumberOfCompensators = $300A00E0;

/// <summary>
/// Material ID (300A;00E1) SH 1
/// </summary>
  K_CMDCMTMaterialId = $300A00E1;

/// <summary>
/// Total Compensator Tray Factor (300A;00E2) DS 1
/// </summary>
  K_CMDCMTTotalCompensatorTrayFactor = $300A00E2;

/// <summary>
/// Compensator Sequence (300A;00E3) SQ 1
/// </summary>
  K_CMDCMTCompensatorSequence = $300A00E3;

/// <summary>
/// Compensator Number (300A;00E4) IS 1
/// </summary>
  K_CMDCMTCompensatorNumber = $300A00E4;

/// <summary>
/// Compensator ID (300A;00E5) SH 1
/// </summary>
  K_CMDCMTCompensatorId = $300A00E5;

/// <summary>
/// Source to Compensator Tray Distance (300A;00E6) DS 1
/// </summary>
  K_CMDCMTSourceToCompensatorTrayDistance = $300A00E6;

/// <summary>
/// Compensator Rows (300A;00E7) IS 1
/// </summary>
  K_CMDCMTCompensatorRows = $300A00E7;

/// <summary>
/// Compensator Columns (300A;00E8) IS 1
/// </summary>
  K_CMDCMTCompensatorColumns = $300A00E8;

/// <summary>
/// Compensator Pixel Spacing (300A;00E9) DS 2
/// </summary>
  K_CMDCMTCompensatorPixelSpacing = $300A00E9;

/// <summary>
/// Compensator Position (300A;00EA) DS 2
/// </summary>
  K_CMDCMTCompensatorPosition = $300A00EA;

/// <summary>
/// Compensator Transmission Data (300A;00EB) DS 1-n
/// </summary>
  K_CMDCMTCompensatorTransmissionData = $300A00EB;

/// <summary>
/// Compensator Thickness Data (300A;00EC) DS 1-n
/// </summary>
  K_CMDCMTCompensatorThicknessData = $300A00EC;

/// <summary>
/// Number of Boli (300A;00ED) IS 1
/// </summary>
  K_CMDCMTNumberOfBoli = $300A00ED;

/// <summary>
/// Compensator Type (300A;00EE) CS 1
/// </summary>
  K_CMDCMTCompensatorType = $300A00EE;

/// <summary>
/// Number of Blocks (300A;00F0) IS 1
/// </summary>
  K_CMDCMTNumberOfBlocks = $300A00F0;

/// <summary>
/// Total Block Tray Factor (300A;00F2) DS 1
/// </summary>
  K_CMDCMTTotalBlockTrayFactor = $300A00F2;

/// <summary>
/// Total Block Tray Water-Equivalent Thickness (300A;00F3) FL 1
/// </summary>
  K_CMDCMTTotalBlockTrayWaterEquivalentThickness = $300A00F3;

/// <summary>
/// Block Sequence (300A;00F4) SQ 1
/// </summary>
  K_CMDCMTBlockSequence = $300A00F4;

/// <summary>
/// Block Tray ID (300A;00F5) SH 1 
/// </summary>
  K_CMDCMTBlockTrayId = $300A00F5;

/// <summary>
/// Source to Block Tray Distance (300A;00F6) DS 1
/// </summary>
  K_CMDCMTSourceToBlockTrayDistance = $300A00F6;

/// <summary>
/// Isocenter to Block Tray Distance (300A;00F7) FL 1
/// </summary>
  K_CMDCMTIsocenterToBlockTrayDistance = $300A00F7;

/// <summary>
/// Block Type (300A;00F8) CS 1
/// </summary>
  K_CMDCMTBlockType = $300A00F8;

/// <summary>
/// Accessory Code (300A;00F9) LO 1
/// </summary>
  K_CMDCMTAccessoryCode = $300A00F9;

/// <summary>
/// Block Divergence (300A;00FA) CS 1
/// </summary>
  K_CMDCMTBlockDivergence = $300A00FA;

/// <summary>
/// Block Mounting Position (300A;00FB) CS 1
/// </summary>
  K_CMDCMTBlockMountingPosition = $0300A00FB;

/// <summary>
/// Block Number (300A;00FC) IS 1
/// </summary>
  K_CMDCMTBlockNumber = $300A00FC;

/// <summary>
/// Block Name (300A;00FE) LO 1
/// </summary>
  K_CMDCMTBlockName = $300A00FE;

/// <summary>
/// Block Thickness (300A;0100) DS 1
/// </summary>
  K_CMDCMTBlockThickness = $300A0100;

/// <summary>
/// Block Transmission (300A;0102) DS 1
/// </summary>
  K_CMDCMTBlockTransmission = $300A0102;

/// <summary>
/// Block Number of Points (300A;0104) IS 1
/// </summary>
  K_CMDCMTBlockNumberOfPoints = $300A0104;

/// <summary>
/// Block Data (300A;0106) DS 2-2n
/// </summary>
  K_CMDCMTBlockData = $300A0106;

/// <summary>
/// Applicator Sequence (300A;0107) SQ 1
/// </summary>
  K_CMDCMTApplicatorSequence = $300A0107;

/// <summary>
/// Applicator ID (300A;0108) SH 1
/// </summary>
  K_CMDCMTApplicatorId = $300A0108;

/// <summary>
/// Applicator Type (300A;0109) CS 1
/// </summary>
  K_CMDCMTApplicatorType = $300A0109;

/// <summary>
/// Applicator Description (300A;010A) LO 1
/// </summary>
  K_CMDCMTApplicatorDescription = $300A010A;

/// <summary>
/// Cumulative Dose Reference Coefficient (300A;010C) DS 1
/// </summary>
  K_CMDCMTCumulativeDoseReferenceCoefficient = $300A010C;

/// <summary>
/// Final Cumulative Meterset Weight (300A;010E) DS 1
/// </summary>
  K_CMDCMTFinalCumulativeMetersetWeight = $300A010E;

/// <summary>
/// Number of Control Points (300A;0110) IS 1
/// </summary>
  K_CMDCMTNumberOfControlPoints = $300A0110;

/// <summary>
/// Control Point Sequence (300A;0111) SQ 1
/// </summary>
  K_CMDCMTControlPointSequence = $300A0111;

/// <summary>
/// Control Point Index (300A;0112) IS 1
/// </summary>
  K_CMDCMTControlPointIndex = $300A0112;

/// <summary>
/// Nominal Beam Energy (300A;0114) DS 1
/// </summary>
  K_CMDCMTNominalBeamEnergy = $300A0114;

/// <summary>
/// Dose Rate Set (300A;0115) DS 1
/// </summary>
  K_CMDCMTDoseRateSet = $300A0115;

/// <summary>
/// Wedge Position Sequence (300A;0116) SQ 1
/// </summary>
  K_CMDCMTWedgePositionSequence = $300A0116;

/// <summary>
/// Wedge Position (300A;0118) CS 1
/// </summary>
  K_CMDCMTWedgePosition = $300A0118;

/// <summary>
/// Beam Limiting Device Position Sequence (300A;011A) SQ 1
/// </summary>
  K_CMDCMTBeamLimitingDevicePositionSequence = $300A011A;

/// <summary>
/// Leaf/Jaw Positions (300A;011C) DS 2-2n
/// </summary>
  K_CMDCMTLeafJawPositions = $300A011C;

/// <summary>
/// Gantry Angle (300A;011E) DS 1
/// </summary>
  K_CMDCMTGantryAngle = $300A011E;

/// <summary>
/// Gantry Rotation Direction (300A;011F) CS 1
/// </summary>
  K_CMDCMTGantryRotationDirection = $300A011F;

/// <summary>
/// Beam Limiting Device Angle (300A;0120) DS 1
/// </summary>
  K_CMDCMTBeamLimitingDeviceAngle = $300A0120;

/// <summary>
/// Beam Limiting Device Rotation Direction (300A;0121) CS 1
/// </summary>
  K_CMDCMTBeamLimitingDeviceRotationDirection = $300A0121;

/// <summary>
/// Patient Support Angle (300A;0122) DS 1
/// </summary>
  K_CMDCMTPatientSupportAngle = $300A0122;

/// <summary>
/// Patient Support Rotation Direction (300A;0123) CS 1
/// </summary>
  K_CMDCMTPatientSupportRotationDirection = $300A0123;

/// <summary>
/// Table Top Eccentric Axis Distance (300A;0124) DS 1
/// </summary>
  K_CMDCMTTableTopEccentricAxisDistance = $300A0124;

/// <summary>
/// Table Top Eccentric Angle (300A;0125) DS 1
/// </summary>
  K_CMDCMTTableTopEccentricAngle = $300A0125;

/// <summary>
/// Table Top Eccentric Rotation Direction (300A;0126) CS 1
/// </summary>
  K_CMDCMTTableTopEccentricRotationDirection = $300A0126;

/// <summary>
/// Table Top Vertical Position (300A;0128) DS
/// </summary>
  K_CMDCMTTableTopVerticalPosition = $300A0128;

/// <summary>
/// Table Top Longitudinal Position (300A;0129) DS 1
/// </summary>
  K_CMDCMTTableTopLongitudinalPosition = $300A0129;

/// <summary>
/// Table Top Lateral Position (300A;012A) DS 1
/// </summary>
  K_CMDCMTTableTopLateralPosition = $300A012A;

/// <summary>
/// Isocenter Position (300A;012C) DS 3
/// </summary>
  K_CMDCMTIsocenterPosition = $300A012C;

/// <summary>
/// Surface Entry Point (300A;012E) DS 3
/// </summary>
  K_CMDCMTSurfaceEntryPoint = $300A012E;

/// <summary>
/// Source to Surface Distance (300A;0130) DS 1
/// </summary>
  K_CMDCMTSourceToSurfaceDistance = $300A0130;

/// <summary>
/// Cumulative Meterset Weight (300A;0134) DS 1
/// </summary>
  K_CMDCMTCumulativeMetersetWeight = $300A0134;

/// <summary>
/// Table Top Pitch Angle (300A;0140) FL 1
/// </summary>
  K_CMDCMTTableTopPitchAngle = $300A0140;

/// <summary>
/// Table Top Pitch Rotation Direction (300A;0142) CS 1
/// </summary>
  K_CMDCMTTableTopPitchRotationDirection = $300A0142;

/// <summary>
/// Table Top Roll Angle (300A;0144) FL 1
/// </summary>
  K_CMDCMTTableTopRollAngle = $300A0144;

/// <summary>
/// Table Top Roll Rotation Direction (300A;0146) CS 1
/// </summary>
  K_CMDCMTTableTopRollRotationDirection = $300A0146;

/// <summary>
/// Head Fixation Angle (300A;0148) FL 1
/// </summary>
  K_CMDCMTHeadFixationAngle = $300A0148;

/// <summary>
/// Gantry Pitch Angle  K_CMDCMT(300A;014A) FL 1
/// </summary>
  K_CMDCMTGantryPitchAngle = $300A014A;

/// <summary>
/// Gantry Pitch Rotation Direction (300A;014C) CS 1
/// </summary>
  K_CMDCMTGantryPitchRotationDirection = $300A014C;

/// <summary>
/// Patient Setup Sequence (300A;0180) SQ 1
/// </summary>
  K_CMDCMTPatientSetupSequence = $300A0180;

/// <summary>
/// Patient Setup Number (300A;0182) IS 1
/// </summary>
  K_CMDCMTPatientSetupNumber = $300A0182;

/// <summary>
/// Patient Setup Label (300A;0183) LO 1
/// </summary>
  K_CMDCMTPatientSetupLabel = $300A0183;

/// <summary>
/// Patient Additional Position (300A;0184) LO 1
/// </summary>
  K_CMDCMTPatientAdditionalPosition = $300A0184;

/// <summary>
/// Fixation Device Sequence (300A;0190) SQ 1
/// </summary>
  K_CMDCMTFixationDeviceSequence = $300A0190;

/// <summary>
/// Fixation Device Type (300A;0192) CS 1
/// </summary>
  K_CMDCMTFixationDeviceType = $300A0192;

/// <summary>
/// Fixation Device Label (300A;0194) SH 1
/// </summary>
  K_CMDCMTFixationDeviceLabel = $300A0194;

/// <summary>
/// Fixation Device Description (300A;0196) ST 1
/// </summary>
  K_CMDCMTFixationDeviceDescription = $300A0196;

/// <summary>
/// Fixation Device Position (300A;0198) SH 1
/// </summary>
  K_CMDCMTFixationDevicePosition = $300A0198;

/// <summary>
/// Fixation Device Pitch Angle (300A;0199) FL 1
/// </summary>
  K_CMDCMTFixationDevicePitchAngle = $300A0199;

/// <summary>
/// Fixation Device Roll Angle (300A;019A) FL 1
/// </summary>
  K_CMDCMTFixationDeviceRollAngle = $300A019A;

/// <summary>
/// Shielding Device Sequence (300A;01A0) SQ 1
/// </summary>
  K_CMDCMTShieldingDeviceSequence = $300A01A0;

/// <summary>
/// Shielding Device Type (300A;01A2) CS 1
/// </summary>
  K_CMDCMTShieldingDeviceType = $300A01A2;

/// <summary>
/// Shielding Device Label (300A;01A4) SH 1
/// </summary>
  K_CMDCMTShieldingDeviceLabel = $300A01A4;

/// <summary>
/// Shielding Device Description (300A;01A6) ST 1
/// </summary>
  K_CMDCMTShieldingDeviceDescription = $300A01A6;

/// <summary>
/// Shielding Device Position (300A;01A8) SH 1
/// </summary>
  K_CMDCMTShieldingDevicePosition = $300A01A8;

/// <summary>
/// Setup Technique (300A;01B0) CS 1
/// </summary>
  K_CMDCMTSetupTechnique = $300A01B0;

/// <summary>
/// Setup Technique Description (300A;01B2) ST 1
/// </summary>
  K_CMDCMTSetupTechniqueDescription = $300A01B2;

/// <summary>
/// Setup Device Sequence (300A;01B4) SQ 1
/// </summary>
  K_CMDCMTSetupDeviceSequence = $300A01B4;

/// <summary>
/// Setup Device Type (300A;01B6) CS 1
/// </summary>
  K_CMDCMTSetupDeviceType = $300A01B6;

/// <summary>
/// Setup Device Label (300A;01B8) SH 1
/// </summary>
  K_CMDCMTSetupDeviceLabel = $300A01B8;

/// <summary>
/// Setup Device Description (300A;01BA) ST 1
/// </summary>
  K_CMDCMTSetupDeviceDescription = $300A01BA;

/// <summary>
/// Setup Device Parameter (300A;01BC) DS 1
/// </summary>
  K_CMDCMTSetupDeviceParameter = $300A01BC;

/// <summary>
/// Setup Reference Description (300A;01D0) ST 1
/// </summary>
  K_CMDCMTSetupReferenceDescription = $300A01D0;

/// <summary>
/// Table Top Vertical Setup Displacement (300A;01D2) DS 1
/// </summary>
  K_CMDCMTTableTopVerticalSetupDisplacement = $300A01D2;

/// <summary>
/// Table Top Longitudinal Setup Displacement (300A;01D4) DS 1
/// </summary>
  K_CMDCMTTableTopLongitudinalSetupDisplacement = $300A01D4;

/// <summary>
/// Table Top Lateral Setup Displacement (300A;01D6) DS 1
/// </summary>
  K_CMDCMTTableTopLateralSetupDisplacement = $300A01D6;

/// <summary>
/// Brachy Treatment Technique (300A;0200) CS 1
/// </summary>
  K_CMDCMTBrachyTreatmentTechnique = $300A0200;

/// <summary>
/// Brachy Treatment Type (300A;0202) CS 1
/// </summary>
  K_CMDCMTBrachyTreatmentType = $300A0202;

/// <summary>
/// Treatment Machine Sequence (300A;0206) SQ 1
/// </summary>
  K_CMDCMTTreatmentMachineSequence = $300A0206;

/// <summary>
/// Source Sequence (300A;0210) SQ 1
/// </summary>
  K_CMDCMTSourceSequence = $300A0210;

/// <summary>
/// Source Number (300A;0212) IS 1
/// </summary>
  K_CMDCMTSourceNumber = $300A0212;

/// <summary>
/// Source Type (300A;0214) CS 1
/// </summary>
  K_CMDCMTSourceType = $300A0214;

/// <summary>
/// Source Manufacturer (300A;0216) LO 1
/// </summary>
  K_CMDCMTSourceManufacturer = $300A0216;

/// <summary>
/// Active Source Diameter (300A;0218) DS 1
/// </summary>
  K_CMDCMTActiveSourceDiameter = $300A0218;

/// <summary>
/// Active Source Length (300A;021A) DS 1
/// </summary>
  K_CMDCMTActiveSourceLength = $300A021A;

/// <summary>
/// Source Encapsulation Nominal Thickness (300A;0222) DS 1
/// </summary>
  K_CMDCMTSourceEncapsulationNominalThickness = $300A0222;

/// <summary>
/// Source Encapsulation Nominal Transmission (300A;0224) DS 1
/// </summary>
  K_CMDCMTSourceEncapsulationNominalTransmission = $300A0224;

/// <summary>			
/// Source Isotope Name (300A;0226) LO 1
/// </summary>
  K_CMDCMTSourceIsotopeName = $300A0226;

/// <summary>
/// Source Isotope Half Life (300A;0228) DS 1
/// </summary>
  K_CMDCMTSourceIsotopeHalfLife = $300A0228;

/// <summary>
/// Source Strength Units  (300A;0229) CS 1
/// </summary>
  K_CMDCMTSourceStrengthUnits = $300A0229;

/// <summary>
/// Reference Air Kerma Rate (300A;022A) DS 1
/// </summary>
  K_CMDCMTReferenceAirKermaRate = $300A022A;

/// <summary>
/// Source Strength   (300A;022B) DS 1
/// </summary>
  K_CMDCMTSourceStrength = $300A022B;

/// <summary>
/// Source Strength Reference Date (300A;022C) DA 1
/// </summary>
  K_CMDCMTSourceStrengthReferenceDate = $300A022C;

/// <summary>
/// Source Strength Reference Time (300A;022E) TM 1
/// </summary>
  K_CMDCMTSourceStrengthReferenceTime = $300A022E;

/// <summary>
/// Application Setup Sequence (300A;0230) SQ 1
/// </summary>
  K_CMDCMTApplicationSetupSequence = $300A0230;

/// <summary>
/// Application Setup Type (300A;0232) CS 1
/// </summary>
  K_CMDCMTApplicationSetupType = $300A0232;

/// <summary>
/// Application Setup Number (300A;0234) IS 1
/// </summary>
  K_CMDCMTApplicationSetupNumber = $300A0234;

/// <summary>
/// Application Setup Name (300A;0236) LO 1
/// </summary>
  K_CMDCMTApplicationSetupName = $300A0236;

/// <summary>
/// Application Setup Manufacturer (300A;0238) LO 1
/// </summary>
  K_CMDCMTApplicationSetupManufacturer = $300A0238;

/// <summary>
/// Template Number (300A;0240) IS 1
/// </summary>
  K_CMDCMTTemplateNumber = $300A0240;

/// <summary>
/// Template Type (300A;0242) SH 1
/// </summary>
  K_CMDCMTTemplateType = $300A0242;

/// <summary>
/// Template Name (300A;0244) LO 1
/// </summary>
  K_CMDCMTTemplateName = $300A0244;

/// <summary>
/// Total Reference Air Kerma (300A;0250) DS 1
/// </summary>
  K_CMDCMTTotalReferenceAirKerma = $300A0250;

/// <summary>
/// Brachy Accessory Device Sequence (300A;0260) SQ 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceSequence = $300A0260;

/// <summary>
/// Brachy Accessory Device Number (300A;0262) IS 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceNumber = $300A0262;

/// <summary>
/// Brachy Accessory Device ID (300A;0263) SH 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceId = $300A0263;

/// <summary>
/// Brachy Accessory Device Type (300A;0264) CS 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceType = $300A0264;

/// <summary>
/// Brachy Accessory Device Name (300A;0266) LO 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceName = $300A0266;

/// <summary>
/// Brachy Accessory Device Nominal Thickness (300A;026A) DS 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceNominalThickness = $300A026A;

/// <summary>
/// Brachy Accessory Device Nominal Transmission (300A;026C) DS 1
/// </summary>
  K_CMDCMTBrachyAccessoryDeviceNominalTransmission = $300A026C;

/// <summary>
/// Channel Sequence (300A;0280) SQ 1
/// </summary>
  K_CMDCMTChannelSequence = $300A0280;

/// <summary>
/// Channel Number (300A;0282) IS 1
/// </summary>
  K_CMDCMTChannelNumber = $300A0282;

/// <summary>
/// Channel Length (300A;0284) DS 1
/// </summary>
  K_CMDCMTChannelLength = $300A0284;

/// <summary>
/// Channel Total Time (300A;0286) DS 1
/// </summary>
  K_CMDCMTChannelTotalTime = $300A0286;

/// <summary>
/// Source Movement Type (300A;0288) CS 1
/// </summary>
  K_CMDCMTSourceMovementType = $300A0288;

/// <summary>
/// Number of Pulses (300A;028A) IS 1
/// </summary>
  K_CMDCMTNumberOfPulses = $300A028A;

/// <summary>
/// Pulse Repetition Interval (300A;028C) DS 1
/// </summary>
  K_CMDCMTPulseRepetitionInterval = $300A028C;

/// <summary>
/// Source Applicator Number (300A;0290) IS 1
/// </summary>
  K_CMDCMTSourceApplicatorNumber = $300A0290;

/// <summary>
/// Source Applicator ID (300A;0291) SH 1
/// </summary>
  K_CMDCMTSourceApplicatorId = $300A0291;

/// <summary>
/// Source Applicator Type (300A;0292) CS 1
/// </summary>
  K_CMDCMTSourceApplicatorType = $300A0292;

/// <summary>
/// Source Applicator Name (300A;0294) LO 1
/// </summary>
  K_CMDCMTSourceApplicatorName = $300A0294;

/// <summary>
/// Source Applicator Length (300A;0296) DS 1
/// </summary>
  K_CMDCMTSourceApplicatorLength = $300A0296;

/// <summary>
/// Source Applicator Manufacturer (300A;0298) LO 1
/// </summary>
  K_CMDCMTSourceApplicatorManufacturer = $300A0298;

/// <summary>
/// Source Applicator Wall Nominal Thickness (300A;029C) DS 1
/// </summary>
  K_CMDCMTSourceApplicatorWallNominalThickness = $300A029C;

/// <summary>
/// Source Applicator Wall Nominal Transmission (300A;029E) DS 1
/// </summary>
  K_CMDCMTSourceApplicatorWallNominalTransmission = $300A029E;

/// <summary>
/// Source Applicator Step Size (300A;02A0) DS 1
/// </summary>
  K_CMDCMTSourceApplicatorStepSize = $300A02A0;

/// <summary>
/// Transfer Tube Number (300A;02A2) IS 1
/// </summary>
  K_CMDCMTTransferTubeNumber = $300A02A2;

/// <summary>
/// Transfer Tube Length (300A;02A4) DS 1
/// </summary>
  K_CMDCMTTransferTubeLength = $300A02A4;

/// <summary>
/// Channel Shield Sequence (300A;02B0) SQ 1
/// </summary>
  K_CMDCMTChannelShieldSequence = $300A02B0;

/// <summary>
/// Channel Shield Number (300A;02B2) IS 1
/// </summary>
  K_CMDCMTChannelShieldNumber = $300A02B2;

/// <summary>
/// Channel Shield ID (300A;02B3) SH 1
/// </summary>
  K_CMDCMTChannelShieldId = $300A02B3;

/// <summary>
/// Channel Shield Name (300A;02B4) LO 1
/// </summary>
  K_CMDCMTChannelShieldName = $300A02B4;

/// <summary>
/// Channel Shield Nominal Thickness (300A;02B8) DS 1
/// </summary>
  K_CMDCMTChannelShieldNominalThickness = $300A02B8;

/// <summary>
/// Channel Shield Nominal Transmission (300A;02BA) DS 1
/// </summary>
  K_CMDCMTChannelShieldNominalTransmission = $300A02BA;

/// <summary>
/// Final Cumulative Time Weight (300A;02C8) DS 1
/// </summary>
  K_CMDCMTFinalCumulativeTimeWeight = $300A02C8;

/// <summary>
/// Brachy Control Point Sequence (300A;02D0) SQ 1
/// </summary>
  K_CMDCMTBrachyControlPointSequence = $300A02D0;

/// <summary>
/// Control Point Relative Position (300A;02D2) DS 1
/// </summary>
  K_CMDCMTControlPointRelativePosition = $300A02D2;

/// <summary>
/// Control Point 3D Position (300A;02D4) DS 3
/// </summary>
  K_CMDCMTControlPoint3DPosition = $300A02D4;

/// <summary>
/// Cumulative Time Weight (300A;02D6) DS 1
/// </summary>
  K_CMDCMTCumulativeTimeWeight = $300A02D6;

/// <summary>
/// Compensator Divergence (300A;02E0) CS 1
/// </summary>
  K_CMDCMTCompensatorDivergence = $0300A02E0;

/// <summary>
/// Compensator Mounting Position (300A;02E1) CS 1
/// </summary>
  K_CMDCMTCompensatorMountingPosition = $0300A02E1;

/// <summary>
/// Source to Compensator Distance (300A;02E2) DS 1-n
/// </summary>
  K_CMDCMTSourceToCompensatorDistance = $0300A02E2;

/// <summary>
/// Total Compensator Tray Water-Equivalent Thickness (300A;02E3) FL 1
/// </summary>
  K_CMDCMTTotalCompensatorTrayWaterEquivalentThickness = $0300A02E3;

/// <summary>
/// Isocenter to Compensator Tray Distance (300A;02E4) FL 1
/// </summary>
  K_CMDCMTIsocenterToCompensatorTrayDistance = $0300A02E4;

/// <summary>
/// Compensator Column Offset (300A;02E5) FL 1
/// </summary>
  K_CMDCMTCompensatorColumnOffset = $0300A02E5;

/// <summary>
/// Isocenter to Compensator Distances (300A;02E6) FL 1-n
/// </summary>
  K_CMDCMTIsocenterToCompensatorDistances = $0300A02E6;

/// <summary>
/// Compensator Relative Stopping Power Ratio (300A;02E7) FL 1
/// </summary>
  K_CMDCMTCompensatorRelativeStoppingPowerRatio = $0300A02E7;

/// <summary>
/// Compensator Milling Tool Diameter (300A;02E8) FL 1
/// </summary>
  K_CMDCMTCompensatorMillingToolDiameter = $0300A02E8;

/// <summary>
/// Ion Range Compensator Sequence (300A;02EA) SQ 1
/// </summary>
  K_CMDCMTIonRangeCompensatorSequence = $0300A02EA;

/// <summary>
/// Radiation Mass Number  K_CMDCMT (300A;0302) IS 1
/// </summary>
  K_CMDCMTRadiationMassNumber = $0300A0302;

/// <summary>
/// Radiation Atomic Numbere (300A;0304) IS 1
/// </summary>
  K_CMDCMTRadiationAtomicNumber = $0300A0304;

/// <summary>
/// Radiation Charge State  K_CMDCMT (300A;0306) SS 1
/// </summary>
  K_CMDCMTRadiationChargeState = $0300A0306;

/// <summary>
/// Scan Mode  (300A;0308) CS 1
/// </summary>
  K_CMDCMTScanMode = $0300A0308;

/// <summary>
/// Virtual Source-Axis Distances  K_CMDCMT (300A;030A) FL 2
/// </summary>
  K_CMDCMTVirtualSourceAxisDistances = $0300A030A;

/// <summary>
/// Snout Sequence    K_CMDCMT(300A;030C) SQ 1
/// </summary>
  K_CMDCMTSnoutSequence = $0300A030C;

/// <summary>
/// Snout Positione  K_CMDCMT (300A;030D) FL 1
/// </summary>
  K_CMDCMTSnoutPosition = $0300A030D;

/// <summary>
/// Snout ID    (300A;030F) SH 1
/// </summary>
  K_CMDCMTSnoutID = $0300A030F;

/// <summary>
/// Number of Range Shifters  K_CMDCMT (300A;0312) IS 1
/// </summary>
  K_CMDCMTNumberOfRangeShifters = $0300A0312;

/// <summary>
/// Range Shifter Sequence  K_CMDCMT (300A;0314) SQ 1
/// </summary>
  K_CMDCMTRangeShifterSequence = $0300A0314;

/// <summary>
/// Range Shifter Number  K_CMDCMT(300A;0316) IS 1
/// </summary>
  K_CMDCMTRangeShifterNumber = $0300A0316;

/// <summary>
/// Range Shifter ID  K_CMDCMT (300A;0318) SH 1
/// </summary>
  K_CMDCMTRangeShifterID = $0300A0318;

/// <summary>
/// Range Shifter Type  K_CMDCMT(300A;0320) CS 1
/// </summary>
  K_CMDCMTRangeShifterType = $0300A0320;

/// <summary>
/// Range Shifter Description  K_CMDCMT (300A;0322) LO 1
/// </summary>
  K_CMDCMTRangeShifterDescription = $0300A0322;

/// <summary>
/// Number of Lateral Spreading Devices  K_CMDCMT (300A;0330) IS 1
/// </summary>
  K_CMDCMTNumberOfLateralSpreadingDevices = $0300A0330;

/// <summary>
/// Lateral Spreading Device Sequence  K_CMDCMT (300A;0332) SQ 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceSequence = $0300A0332;

/// <summary>
/// Lateral Spreading Device Number  K_CMDCMT(300A;0334) IS 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceNumber = $0300A0334;

/// <summary>
/// Lateral Spreading Device ID  K_CMDCMT (300A;0336) SH 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceID = $0300A0336;

/// <summary>
/// Lateral Spreading Device Type  K_CMDCMT(300A;0338) CS 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceType = $0300A0338;

/// <summary>
/// Lateral Spreading Device Description  K_CMDCMT (300A;033A) LO 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceDescription = $0300A033A;

/// <summary>
/// Lateral Spreading Device Water Equivalent Thickness  K_CMDCMT (300A;033C) FL 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceWaterEquivalentThickness = $0300A033C;

/// <summary>
/// Number of Range Modulators  K_CMDCMT (300A;0340) IS 1
/// </summary>
  K_CMDCMTNumberOfRangeModulators = $0300A0340;

/// <summary>
/// Range Modulator Sequence  K_CMDCMT (300A;0342) SQ 1
/// </summary>
  K_CMDCMTRangeModulatorSequence = $0300A0342;

/// <summary>
/// Range Modulator Number  K_CMDCMT(300A;0344) IS 1
/// </summary>
  K_CMDCMTRangeModulatorNumber = $0300A0344;

/// <summary>
/// Range Modulator ID  K_CMDCMT (300A;0346) SH 1
/// </summary>
  K_CMDCMTRangeModulatorID = $0300A0346;

/// <summary>
/// Range Modulator Type  K_CMDCMT(300A;0348) CS 1
/// </summary>
  K_CMDCMTRangeModulatorType = $0300A0348;

/// <summary>
/// Range Modulator Description  K_CMDCMT (300A;034A) LO 1
/// </summary>
  K_CMDCMTRangeModulatorDescription = $0300A034A;

/// <summary>
/// Beam Current Modulation ID  K_CMDCMT (300A;034C) SH 1
/// </summary>
  K_CMDCMTBeamCurrentModulationID = $0300A034C;

/// <summary>
/// Patient Support Type  K_CMDCMT (300A;0350) CS 1
/// </summary>
  K_CMDCMTPatientSupportType = $0300A0350;

/// <summary>
/// Patient Support ID  K_CMDCMT (300A;0352) SH 1
/// </summary>
  K_CMDCMTPatientSupportID = $0300A0352;

/// <summary>
/// Patient Support Accessory Code  K_CMDCMT(300A;0354) LO 1
/// </summary>
  K_CMDCMTPatientSupportAccessoryCode = $0300A0354;

/// <summary>
/// Fixation Light Azimuthal Angle  K_CMDCMT (300A;0356) FL 1
/// </summary>
  K_CMDCMTFixationLightAzimuthalAngle = $0300A0356;

/// <summary>
/// Fixation Light Polar Angle  K_CMDCMT (300A;0358) FL 1
/// </summary>
  K_CMDCMTFixationLightPolarAngle = $0300A0358;

/// <summary>
/// Meterset Rate  K_CMDCMT(300A;035A) FL 1
/// </summary>
  K_CMDCMTMetersetRate = $0300A035A;

/// <summary>
/// Range Shifter Settings Sequence  K_CMDCMT (300A;0360) SQ 1
/// </summary>
  K_CMDCMTRangeShifterSettingsSequence = $0300A0360;

/// <summary>
/// Range Shifter Setting  K_CMDCMT (300A;0362) LO 1
/// </summary>
  K_CMDCMTRangeShifterSetting = $0300A0362;

/// <summary>
/// Isocenter To Range Shifter Distance  (300A;0364) FL 1
/// </summary>
  K_CMDCMTIsocenterToRangeShifterDistance = $0300A0364;

/// <summary>
/// Range Shifter Water Equivalent Thickness  K_CMDCMT (300A;0366) FL 1
/// </summary>
  K_CMDCMTRangeShifterWaterEquivalentThickness = $0300A0366;

/// <summary>
///  K_CMDCMTLateral Spreading Device Settings Sequence  K_CMDCMT (300A;0370) SQ 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceSettingsSequence = $0300A0370;

/// <summary>
///  K_CMDCMTLateral Spreading Device Setting  K_CMDCMT (300A;0372) LO 1
/// </summary>
  K_CMDCMTLateralSpreadingDeviceSetting = $0300A0372;

/// <summary>
///  K_CMDCMTIsocenter To Lateral Spreading Device  K_CMDCMT (300A;0374) SQ 1
/// </summary>
  K_CMDCMTIsocenterToLateralSpreadingDeviceDistance = $0300A0374;

/// <summary>
///  K_CMDCMTRange Modulator Settings Sequence  K_CMDCMT (300A;0380) SQ 1
/// </summary>
  K_CMDCMTRangeModulatorSettingsSequence = $0300A0380;

/// <summary>
///  K_CMDCMTRange Modulator Getting Start Value  K_CMDCMT (300A;0382) FL 1
/// </summary>
  K_CMDCMTRangeModulatorGatingStartValue = $0300A0382;

/// <summary>
///  K_CMDCMTRange Modulator Getting Stop Value  K_CMDCMT (300A;0384) FL 1
/// </summary>
  K_CMDCMTRangeModulatorGatingStopValue = $0300A0384;

/// <summary>
///  K_CMDCMTRange Modulator Gating Start Water Equivalent Thickness  K_CMDCMT (300A;0386) FL 1
/// </summary>
  K_CMDCMTRangeModulatorGatingStartWaterEquivalentThickness = $0300A0386;

/// <summary>
///  K_CMDCMTRange Modulator Gating Stop Water Equivalent Thickness  K_CMDCMT (300A;0388) FL 1
/// </summary>
  K_CMDCMTRangeModulatorGatingStopWaterEquivalentThickness = $0300A0388;

/// <summary>
///  K_CMDCMTIsocenter To Range Modulator  K_CMDCMT (300A;038A) FL 1
/// </summary>
  K_CMDCMTIsocenterToRangeModulatorDistance = $0300A038A;

/// <summary>
///  K_CMDCMTScan Spot Tune ID  K_CMDCMT (300A;0390) SH 1
/// </summary>
  K_CMDCMTScanSpotTuneID = $0300A0390;

/// <summary>
///  K_CMDCMTNumber Of Scan Spot Positions  K_CMDCMT (300A;0392) IS 1
/// </summary>
  K_CMDCMTNumberOfScanSpotPositions = $0300A0392;

/// <summary>
///  K_CMDCMTScan Spot Position Map  K_CMDCMT (300A;0394) FL 1-n
/// </summary>
  K_CMDCMTScanSpotPositionMap = $0300A0394;

/// <summary>
///  K_CMDCMTScan Spot Meterset Weights  K_CMDCMT(300A;0396) FL 1-n
/// </summary>
  K_CMDCMTScanSpotMetersetWeights = $0300A0396;

/// <summary>
///  K_CMDCMTScanning Spot Size  K_CMDCMT (300A;0398) FL 2
/// </summary>
  K_CMDCMTScanningSpotSize = $0300A0398;

/// <summary>
///  K_CMDCMTNumber Of Paintings  K_CMDCMT (300A;039A) IS 1
/// </summary>
  K_CMDCMTNumberOfPaintings = $0300A039A;

/// <summary>
///  K_CMDCMTIon Tolerance Table Sequence  K_CMDCMT (300A;03A0) SQ 1
/// </summary>
  K_CMDCMTIonToleranceTableSequence = $0300A03A0;

/// <summary>
///  K_CMDCMTIon Beam Sequence  K_CMDCMT (300A;03A2) SQ 1
/// </summary>
  K_CMDCMTIonBeamSequence = $0300A03A2;

/// <summary>
///  K_CMDCMTIon Beam Limiting Device Sequence  K_CMDCMT (300A;03A4) SQ 1
/// </summary>
  K_CMDCMTIonBeamLimitingDeviceSequence = $0300A03A4;

/// <summary>
///  K_CMDCMTIon Block Sequence  K_CMDCMT (300A;03A6) SQ 1
/// </summary>
  K_CMDCMTIonBlockSequence = $0300A03A6;

/// <summary>
///  K_CMDCMTIon Control Point Sequence  K_CMDCMT (300A;03A8) SQ 1
/// </summary>
  K_CMDCMTIonControlPointSequence = $0300A03A8;

/// <summary>
///  K_CMDCMTIon Wedge Sequence  K_CMDCMT (300A;03AA) SQ 1
/// </summary>
  K_CMDCMTIonWedgeSequence = $0300A03AA;

/// <summary>
///  K_CMDCMTIon Wedge Position Sequence  K_CMDCMT (300A;03AC) SQ 1
/// </summary>
  K_CMDCMTIonWedgePositionSequence = $0300A03AC;

/// <summary>
///  K_CMDCMTReferenced Image Setup Sequence  K_CMDCMT (300A;0401) SQ 1
/// </summary>
  K_CMDCMTReferencedImageSetupSequence = $0300A0401;

/// <summary>
///  K_CMDCMTSetup Image Comment  K_CMDCMT (300A;0402) ST 1
/// </summary>
  K_CMDCMTSetupImageComment = $0300A0402;


    
// GROUP 300C
/// <summary>
// GROUP 300C Group Length (300C;0000) UL 1
/// </summary>
  K_CMDCMTGroup300CGroupLength = $300C0000;

/// <summary>
/// Referenced RT Plan Sequence (300C;0002) SQ 1
/// </summary>
  K_CMDCMTReferencedRTPlanSequence = $300C0002;

/// <summary>
/// Referenced Beam Sequence (300C;0004) SQ 1
/// </summary>
  K_CMDCMTReferencedBeamSequence = $300C0004;

/// <summary>
/// Referenced Beam Number (300C;0006) IS 1
/// </summary>
  K_CMDCMTReferencedBeamNumber = $300C0006;

/// <summary>
/// Referenced Reference Image Number (300C;0007) IS 1
/// </summary>
  K_CMDCMTReferencedReferenceImageNumber = $300C0007;

/// <summary>
/// Start Cumulative Meterset Weight (300C;0008) DS 1
/// </summary>
  K_CMDCMTStartCumulativeMetersetWeight = $300C0008;

/// <summary>
/// End Cumulative Meterset Weight (300C;0009) DS 1
/// </summary>
  K_CMDCMTEndCumulativeMetersetWeight = $300C0009;

/// <summary>
/// Referenced Brachy Application Setup Sequence (300C;000A) SQ 1
/// </summary>
  K_CMDCMTReferencedBrachyApplicationSetupSequence = $300C000A;

/// <summary>
/// Referenced Brachy Application Setup Number (300C;000C) IS 1
/// </summary>
  K_CMDCMTReferencedBrachyApplicationSetupNumber = $300C000C;

/// <summary>
/// Referenced Source Number (300C;000E) IS 1
/// </summary>
  K_CMDCMTReferencedSourceNumber = $300C000E;

/// <summary>
/// Referenced Fraction Group Sequence (300C;0020) SQ 1
/// </summary>
  K_CMDCMTReferencedFractionGroupSequence = $300C0020;

/// <summary>
/// Referenced Fraction Group Number (300C;0022) IS 1
/// </summary>
  K_CMDCMTReferencedFractionGroupNumber = $300C0022;

/// <summary>
/// Referenced Verificaiton Image Sequence (300C;0040) SQ 1
/// </summary>
  K_CMDCMTReferencedVerificationImageSequence = $300C0040;

/// <summary>
/// Referenced Reference Image Sequence (300C;0042) SQ 1
/// </summary>
  K_CMDCMTReferencedReferenceImageSequence = $300C0042;

/// <summary>
/// Referenced Dose Reference Sequence (300C;0050) SQ 1
/// </summary>
  K_CMDCMTReferencedDoseReferenceSequence = $300C0050;

/// <summary>
/// Referenced Dose Reference Number (300C;0051) IS 1
/// </summary>
  K_CMDCMTReferencedDoseReferenceNumber = $300C0051;

/// <summary>
/// Brachy Reference Dose Reference Sequence (300C;0055) SQ 1
/// </summary>
  K_CMDCMTBrachyReferencedDoseReferenceSequence = $300C0055;

/// <summary>
/// Referenced Structure Set Sequence (300C;0060) SQ 1
/// </summary>
  K_CMDCMTReferencedStructureSetSequence = $300C0060;

/// <summary>
/// Referenced Patient Setup Number (300C;006A) IS 1
/// </summary>
  K_CMDCMTReferencedPatientSetupNumber = $300C006A;

/// <summary>
/// Referenced Dose Sequence (300C;0080) SQ 1
/// </summary>
  K_CMDCMTReferencedDoseSequence = $300C0080;

/// <summary>
/// Referenced Tolerance Table Number (300C;00A0) IS 1
/// </summary>
  K_CMDCMTReferencedToleranceTableNumber = $300C00A0;

/// <summary>
/// Reference Bolus Sequence (300C;00B0) SQ 1
/// </summary>
  K_CMDCMTReferencedBolusSequence = $300C00B0;

/// <summary>
/// Referenced Wedge Number (300C;00C0) IS 1
/// </summary>
  K_CMDCMTReferencedWedgeNumber = $300C00C0;

/// <summary>
/// Referenced Compensator Number (300C;00D0) IS 1
/// </summary>
  K_CMDCMTReferencedCompensatorNumber = $300C00D0;

/// <summary>
/// Referenced Block Number (300C;00E0) IS 1
/// </summary>
  K_CMDCMTReferencedMaticsNumber = $300C00E0;

/// <summary>
/// Referenced Control Point Index (300C;00F0) IS 1
/// </summary>
  K_CMDCMTReferencedControlPointIndex = $300C00F0;

/// <summary>
/// Referenced Control Point Sequence (300C;00F2) SQ 1
/// </summary>
  K_CMDCMTReferencedControlPointSequence = $300C00F2;

/// <summary>
/// Referenced Start Control Point Index (300C;00F4) IS 1
/// </summary>
  K_CMDCMTReferencedStartControlPointIndex = $300C00F4;

/// <summary>
/// Referenced Stop Control Point Index (300C;00F6) IS 1
/// </summary>
  K_CMDCMTReferencedStopControlPointIndex = $300C00F6;

/// <summary>
/// Referenced Range Shifter Number (300C;0100) IS 1
/// </summary>
  K_CMDCMTReferencedRangeShifterNumber = $300C0100;

/// <summary>
/// Referenced Lateral Spreading Device Number (300C;0102) IS 1
/// </summary>
  K_CMDCMTReferencedLateralSpreadingDeviceNumber = $300C0102;

/// <summary>
/// Referenced Range Modulator Number (300C;0104) IS 1
/// </summary>
  K_CMDCMTReferencedRangeModulatorNumber = $300C0104;

    
// GROUP 300E
/// <summary>
// GROUP 300E Group Length (300E;0000) UL 1
/// </summary>
  K_CMDCMTGroup300EGroupLength = $300E0000;

/// <summary>
/// Approval Status (300E;0002) CS 1
/// </summary>
  K_CMDCMTApprovalStatus = $300E0002;

/// <summary>
/// Review Date (300E;0004) DA 1
/// </summary>
  K_CMDCMTReviewDate = $300E0004;

/// <summary>
/// Review Time (300E;0005) TM 1
/// </summary>
  K_CMDCMTReviewTime = $300E0005;

/// <summary>
/// Reviewer Name (300E;0008) PN 1
/// </summary>
  K_CMDCMTReviewerName = $300E0008;
    
// GROUP 4000
/// <summary>
// GROUP 4000 Group Length Retired (4000;0000) UL 1
/// </summary>
  K_CMDCMTGroup4000GroupLengthRetired = $40000000;

/// <summary>
/// Arbitrary (Retired) (4000;0010) LT 1
/// </summary>
  K_CMDCMTArbitraryRetired = $40000010;

/// <summary>
/// Comments (Retired) (4000;4000)LT 1
/// </summary>
  K_CMDCMTComments4000Retired = $40004000;
    
// GROUP 4008
/// <summary>
// GROUP 4008 Group Length (4008;0000)UL 1
/// </summary>
  K_CMDCMTGroup4008GroupLength = $40080000;

/// <summary>
/// Results ID (Retired) (4008;0040) SH 1
/// </summary>
  K_CMDCMTResultsIDRetired = $40080040;

/// <summary>
/// Results ID Issuer (Retired) (4008;0042) LO 1
/// </summary>
  K_CMDCMTResultsIdIssuerRetired = $40080042;

/// <summary>
/// Referenced Interpretation Sequence (Retired)(4008;0050) SQ 1
/// </summary>
  K_CMDCMTReferencedInterpretationSequenceRetired = $40080050;

/// <summary>
/// Interpretation Recorded Date (Retired)(4008;0100) DA 1
/// </summary>
  K_CMDCMTInterpretationRecordedDateRetired = $40080100;

/// <summary>
/// Interpretation Recorded Time (Retired)(4008;0101) TM 1
/// </summary>
  K_CMDCMTInterpretationRecordedTimeRetired = $40080101;

/// <summary>
/// Interpretation Recorder (Retired) (4008;0102) PN 1
/// </summary>
  K_CMDCMTInterpretationRecorderRetired = $40080102;

/// <summary>
/// Reference to Recorded Sound (Retired)(4008;0103) LO 1
/// </summary>
  K_CMDCMTReferenceToRecordedSoundRetired = $40080103;

/// <summary>
/// Interpretation Transcription Date (Retired)(4008;0108) DA 1
/// </summary>
  K_CMDCMTInterpretationTranscriptionDateRetired = $40080108;

/// <summary>
/// Interpretation Transcription Time (Retired) (4008;0109) TM 1
/// </summary>
  K_CMDCMTInterpretationTranscriptionTimeRetired = $40080109;

/// <summary>
/// Interpretation Transcriber (Retired)(4008;010A) PN 1
/// </summary>
  K_CMDCMTInterpretationTranscriberRetired = $4008010A;

/// <summary>
/// Interpretation Text (Retired)(4008;010B) ST 1
/// </summary>
  K_CMDCMTInterpretationTextRetired = $4008010B;

/// <summary>
/// Interpretation Author (Retired)(4008;010C) PN 1
/// </summary>
  K_CMDCMTInterpretationAuthorRetired = $4008010C;

/// <summary>
/// Interpretation Approver Sequence (Retired)(4008;0111) SQ 1
/// </summary>
  K_CMDCMTInterpretationApproverSequenceRetired = $40080111;

/// <summary>
/// Interpretation Approval Date (Retired)(4008;0112) DA 1
/// </summary>
  K_CMDCMTInterpretationApprovalDateRetired = $40080112;

/// <summary>
/// Interpretation Approval Time (Retired)(4008;0113) TM 1
/// </summary>
  K_CMDCMTInterpretationApprovalTimeRetired = $40080113;

/// <summary>
/// Physician Approving Interpretation (Retired) (4008;0114) PN 1
/// </summary>
  K_CMDCMTPhysicianApprovingInterpretationRetired = $40080114;

/// <summary>
/// Interpretation Diagnosis Description (Retired)(4008;0115) LT 1
/// </summary>
  K_CMDCMTInterpretationDiagnosisDescriptionRetired = $40080115;

/// <summary>
/// Interpretation Diagnosis Code Sequence (Retired) (4008;0117) SQ 1
/// </summary>
  K_CMDCMTInterpretationDiagnosisCodeSequenceRetired = $40080117;

/// <summary>
/// Results Distribution List Sequence (Retired) (4008;0118) SQ 1
/// </summary>
  K_CMDCMTResultsDistributionListSequenceRetired = $40080118;

/// <summary>
/// Distribution Name (Retired) (4008;0119) PN 1
/// </summary>
  K_CMDCMTDistributionNameRetired = $40080119;

/// <summary>
/// Distribution Address (Retired) (4008;011A) LO 1
/// </summary>
  K_CMDCMTDistributionAddressRetired = $4008011A;

/// <summary>
/// Interpretation ID (Retired) (4008;0200) SH 1
/// </summary>
  K_CMDCMTInterpretationIdRetired = $40080200;

/// <summary>
/// Interpretation ID Issuer (Retired) (4008;0202) LO 1
/// </summary>
  K_CMDCMTInterpretationIdIssuerRetired = $40080202;

/// <summary>
/// Interpretaion Type ID (Retired) (4008;0210) CS 1
/// </summary>
  K_CMDCMTInterpretationTypeIdRetired = $40080210;

/// <summary>
/// Interpretation Status ID (Retired) (4008;0212) CS 1
/// </summary>
  K_CMDCMTInterpretationStatusIdRetired = $40080212;

/// <summary>
/// Impressions (Retired) (4008;0300) ST 1
/// </summary>
  K_CMDCMTImpressionsRetired = $40080300;

/// <summary>
/// Results Comments (Retired) (4008;4000) ST 1
/// </summary>
  K_CMDCMTResultsCommentsRetired = $40084000;
    
// GROUP 4FFE
/// <summary>
/// MAC Parameters Sequence (4FFE;0001) SQ 1
/// </summary>
  K_CMDCMTMacParametersSequenceRetired = $4FFE0001;
    
// GROUP 5$x
// The following are ranges of elements
// Have not yet decided on how to support them
// First question is; are they ever used?

/// <summary>
// GROUP 5000 Group Length (5000;0000)UL 1
/// </summary>
  K_CMDCMTGroup5000GroupLength = $50000000;

/// <summary>
/// Curve Dimensions (Retired) (5000;0005) US 1
/// </summary>
  K_CMDCMTCurveDimensionsRetired = $50000005;

/// <summary>
/// Number of Points (Retired) (5000;0010) US 1
/// </summary>
  K_CMDCMTNumberOfPointsRetired = $50000010;

/// <summary>
/// Type of Data (Retired)(5000;0020) CS 1
/// </summary>
  K_CMDCMTTypeOfDataRetired = $50000020;

/// <summary>
/// Curve Description (Retired) (5000;0022) LO 1
/// </summary>
  K_CMDCMTCurveDescriptionRetired = $50000022;

/// <summary>
/// Axis Units (Retired)(5000;0030) SH 1-n
/// </summary>
  K_CMDCMTAxisUnitsRetired = $50000030;

/// <summary>
/// Axis Labels(Retired)(5000;0040) SH 1-n
/// </summary>
  K_CMDCMTAxisLabelsRetired = $50000040;

/// <summary>
/// Data Value Representation (Retired)(5000;0103) US 1
/// </summary>
  K_CMDCMTDataValueRepresentationRetired = $50000103;

/// <summary>
/// Minimum Coordinate Value (Retired)(5000;0104) US 1-n
/// </summary>
  K_CMDCMTMinimumCoordinateValueRetired = $50000104;

/// <summary>
/// Maximum Coordinate Value (Retired)(5000;0105) US 1-n
/// </summary>
  K_CMDCMTMaximumCoordinateValueRetired = $50000105;

/// <summary>
/// Curve Range (Retired)(5000;0106) SH 1-n
/// </summary>
  K_CMDCMTCurveRangeRetired = $50000106;

/// <summary>
/// Curve Data Descriptor (Retired)(5000;0110) US 1-n
/// </summary>
  K_CMDCMTCurveDataDescriptorRetired = $50000110;

/// <summary>
/// Coordinate Start Value (Retired)(5000;0112) US 1-n
/// </summary>
  K_CMDCMTCoordinateStartValueRetired = $50000112;

/// <summary>
/// coordinate Step Value (Retired)(5000;0114) US 1-n
/// </summary>
  K_CMDCMTCoordinateStepValueRetired = $50000114;

/// <summary>
/// Curve Activation Layer (Retired)(5$x;1001) CS 1
/// </summary>
  K_CMDCMTCurveActivationLayerRetired = $50001001;

/// <summary>
/// Audio Type (Retired) (5000;2000) US 1
/// </summary>
  K_CMDCMTAudioTypeRetired = $50002000;

/// <summary>
/// Audio Sample Format (Retired)(5000;2002) US 1
/// </summary>
  K_CMDCMTAudioSampleFormatRetired = $50002002;

/// <summary>
/// Number of Channels (Retired)(5000;2004) US 1
/// </summary>
  K_CMDCMTNumberOfChannelsRetired = $50002004;

/// <summary>
/// Number of Samples (Retired)(5000;2006) UL 1
/// </summary>
  K_CMDCMTNumberOfSamplesRetired = $50002006;

/// <summary>
/// Sample Rate (Retired)(5000;2008) UL 1
/// </summary>
  K_CMDCMTSampleRateRetired = $50002008;

/// <summary>
/// Total Time (Retired)(5000;200A) UL 1
/// </summary>
  K_CMDCMTTotalTimeRetired = $5000200A;

/// <summary>
/// Audio Sample Data (Retired)(5000;200C) OW 1
/// </summary>
  K_CMDCMTAudioSampleDataRetired = $5000200C;

/// <summary>
/// Audio Comments (Retired)(5000;200E) LT 1
/// </summary>
  K_CMDCMTAudioCommentsRetired = $5000200E;

/// <summary>
/// Curve Label (Retired)(5000;2500) LO 1
/// </summary>
  K_CMDCMTCurveLabelRetired = $50002500;

/// <summary>
/// Referenced Overlay Sequence (Retired)(5000;2600) SQ 1
/// </summary>
  K_CMDCMTReferencedCurveOverlaySequenceRetired = $50002600;

/// <summary>
/// Referenced Overlay Group (Retired)(5000;2610) US 1
/// </summary>
  K_CMDCMTReferencedOverlayGroupRetired = $50002610;

/// <summary>
/// Curve Data (Retired) (5000;3000) OW or OB 1
/// </summary>
  K_CMDCMTCurveDataRetired = $50003000;

    
// GROUP 5200
/// <summary>
/// Shared Functional Groups Sequence (5200;9229) SQ 1
/// </summary>
  K_CMDCMTSharedFunctionalGroupsSequence = $52009229;

/// <summary>
/// Per Frame Functional Groups Sequence (5200;9230) SQ 1
/// </summary>
  K_CMDCMTPerFrameFunctionalGroupsSequence = $52009230;
    
// GROUP 5400

/// <summary>
/// Waveform Sequence (5400;0100) SQ 1
/// </summary>
  K_CMDCMTWaveformSequence = $54000100;


/// <summary>
/// Channel Minimum Value (5400;0110) OB or OW 1
/// </summary>
  K_CMDCMTChannelMinimumValue = $54000110;


/// <summary>
/// Channel Maximum Value (5400;0112) OB or OW 1
/// </summary>
  K_CMDCMTChannelMaximumValue = $54000112;


/// <summary>
/// Waveform Bits Allocated (5400;1004) US 1
/// </summary>
  K_CMDCMTWaveformBitsAllocated = $54001004;


/// <summary>
/// Waveform Sample Interpretation (5400;1006) CS 1
/// </summary>
  K_CMDCMTWaveformSampleInterpretation = $54001006;


/// <summary>
/// Waveform Padding Value (5400;100A) OB or OW 1
/// </summary>
  K_CMDCMTWaveformPaddingValue = $5400100A;


/// <summary>
/// Waveform Data (5400;1010) OB or OW 1
/// </summary>
  K_CMDCMTWaveformData = $54001010;

    
// GROUP 5600
/// <summary>
/// First Order Phase Correction Angle (5600;0010) OF 1
/// </summary>
  K_CMDCMTFirstOrderPhaseCorrectionAngle = $56000010;

/// <summary>
/// Spectroscopy Data (5600;0020) OF 1
/// </summary>
  K_CMDCMTSpectroscopyData = $56000020;
    
// GROUP 6$X
/// <summary>
/// Overlay Rows (6000;0010)-(60FF;0010) US 1
/// </summary>
  K_CMDCMTOverlayRows = $60000010;

/// <summary>
/// Overlay Columns (6000;0011)-(60FF;0011) US 1
/// </summary>
  K_CMDCMTOverlayColumns = $60000011;

/// <summary>
/// Overlay Planes (6000;0012)-(60FF;0012) US 1
/// </summary>
  K_CMDCMTOverlayPlanes = $60000012;

/// <summary>
/// Number of Frames in Overlay (6000;0015)-(60FF;0015) IS 1
/// </summary>
  K_CMDCMTNumberOfFramesInOverlay = $60000015;

/// <summary>
/// Overlay Description (6000;0022)-(60FF;0022) LO 1
/// </summary>
  K_CMDCMTOverlayDescription = $60000022;

/// <summary>
/// Overlay Type (6000;0040)-(60FF;0040) CS 1
/// </summary>
  K_CMDCMTOverlayType = $60000040;

/// <summary>
/// Overlay Subtype (6000;0045)-(60FF;0045) LO 1
/// </summary>
  K_CMDCMTOverlaySubtype = $60000045;

/// <summary>
/// Overlay Origin (6000;0050)-(60FF;0050) SS 2
/// </summary>
  K_CMDCMTOverlayOrigin = $60000050;

/// <summary>
/// Image Frame Origin (6000;0051)-(60FF;0051) US 2
/// </summary>
  K_CMDCMTImageFrameOrigin = $60000051;

/// <summary>
/// Overlay Plane Origin (6000;0052)-(60FF;0052) US 1
/// </summary>
  K_CMDCMTOverlayPlaneOrigin = $60000052;

/// <summary>
/// Compression Code (Retired) (6000;0060)-(60FF;0060) CS 1
/// </summary>
  K_CMDCMTCompressionCode6000Retired = $60000060;

/// <summary>
/// Overlay Bits Allocated (6000;0100)-(60FF;0100) US 1
/// </summary>
  K_CMDCMTOverlayBitsAllocated = $60000100;

/// <summary>
/// Overlay Bits Position (6000;0102)-(60FF;0102) US 1
/// </summary>
  K_CMDCMTOverlayBitPosition = $60000102;

/// <summary>
/// Overlay Format (Retired) (6000;0110)-(60FF;0110) CS 1
/// </summary>
  K_CMDCMTOverlayFormatRetired = $60000110;

/// <summary>
/// Overlay Location (Retired) (6000;0200)-(60FF;0200) US 1
/// </summary>
  K_CMDCMTOverlayLocationRetired = $60000200;

/// <summary>
/// Overlay Activation Layer (6000;1001)-(60FF;1001) CS 1
/// </summary>
  K_CMDCMTOverlayActivationLayer = $60001001;

/// <summary>
/// Overlay Descriptor Gray (Retired) (6000;1100)-(60FF;1100) US 1
/// </summary>
  K_CMDCMTOverlayDescriptorGrayRetired = $60001100;

/// <summary>
/// Overlay Descriptor Red (Retired) (6000;1101)-(60FF;1101) US 1
/// </summary>
  K_CMDCMTOverlayDescriptorRedRetired = $60001101;

/// <summary>
/// Overlay Descriptor Green (Retired) (6000;1102)-(60FF;1102) US 1
/// </summary>
  K_CMDCMTOverlayDescriptorGreenRetired = $60001102;

/// <summary>
/// Overlay Descriptor Blue (Retired) (6000;1103)-(60FF;1103) US 1
/// </summary>
  K_CMDCMTOverlayDescriptorBlueRetired = $60001103;

/// <summary>
/// Overlays Gray (Retired) (6000;1200)-(60FF;1200) US 1
/// </summary>
  K_CMDCMTOverlaysGrayRetired = $60001200;

/// <summary>
/// Overlays Red (Retired) (6000;1201)-(60FF;1201) US 1
/// </summary>
  K_CMDCMTOverlaysRedRetired = $60001201;

/// <summary>
/// Overlays Green (Retired) (6000;1202)-(60FF;1202) US 1
/// </summary>
  K_CMDCMTOverlaysGreenRetired = $60001202;

/// <summary>
/// Overlays Blue (Retired) (6000;1203)-(60FF;1203) US 1
/// </summary>
  K_CMDCMTOverlaysBlueRetired = $60001203;

/// <summary>
/// ROI Area (6000;1301)-(60FF;1301) IS 1
/// </summary>
  K_CMDCMTRoiArea = $60001301;

/// <summary>
/// ROI Mean (6000;1302)-(60FF;1302) DS 1
/// </summary>
  K_CMDCMTRoiMean = $60001302;

/// <summary>
/// ROI Standard Deviation (6000;1303)-(60FF;1303) DS 1
/// </summary>
  K_CMDCMTRoiStandardDeviation = $60001303;

/// <summary>
/// Overlay Label (6000;1500)-(60FF;1500) LO 1
/// </summary>
  K_CMDCMTOverlayLabel = $60001500;

/// <summary>
/// Overlay Data (6000;3000)-(60FF;3000) OW 1
/// </summary>
  K_CMDCMTOverlayData = $60003000;

/// <summary>
/// Comments Group 6000 (Retired) (6000;4000)-(60FF;4000) LT 1
/// </summary>
  K_CMDCMTComments6000Retired = $60004000;

    
// GROUP 7FE0
/// <summary>
// GROUP 7FE0 Group Length (7FE0;0000) UL
/// </summary>
  K_CMDCMTGroup7FE0Length = $7FE00000;

/// <summary>
/// Pixel Data (7FE0;0010) OW
/// </summary>
  K_CMDCMTPixelData = $7FE00010;

    
// GROUP FFFA
/// <summary>
// GROUP FFFA Group Length (FFFA;0000) UL 1
/// </summary>
  K_CMDCMTGroupFffaLength = $FFFA0000;

/// <summary>
/// Digital Signatures Sequence (FFFA;FFFA) SQ 1
/// </summary>
  K_CMDCMTDigitalSignaturesSequence = $FFFAFFFA;
    
// GROUP FFFC
/// <summary>
// GROUP_FFFC_LENGTH (FFFC;0000) UL 1
/// </summary>
  K_CMDCMTGroupFffcLength = $FFFC0000;

/// <summary>
/// Data Set Trailing Padding (FFFC;FFFC) OB 1
/// </summary>
  K_CMDCMTDataSetTrailingPadding = $FFFCFFFC;

    
// SEQUENCE DELIMITERS
/// <summary>
/// Item Delimitation Tag (FFFE;E000)
/// </summary>
  K_CMDCMTItemDelimitationTag = $FFFEE000;

/// <summary>
/// Item Delimitation Item (FFFE;E00D) 
/// </summary>
  K_CMDCMTItemDelimitationItem = $FFFEE00D;

/// <summary>
/// Sequence Delimitation Item (FFFE;E0DD)
/// </summary>
  K_CMDCMTSequenceDelimitationItem = $FFFEE0DD;
//
// end of DICOM atributes Tags
/////////////////////////////

///////////////////////////////
// DICOM Transfer syntax UIDs
//
const
	K_CMDCMUID_LittleEndianImplicitTransferSyntax: WideString = '1.2.840.10008.1.2';
	K_CMDCMUID_LittleEndianExplicitTransferSyntax: WideString = '1.2.840.10008.1.2.1';
	K_CMDCMUID_BigEndianExplicitTransferSyntax: WideString = '1.2.840.10008.1.2.2';
	K_CMDCMUID_JPEGProcess1TransferSyntax: WideString = '1.2.840.10008.1.2.4.50';
	K_CMDCMUID_JPEGProcess2_4TransferSyntax: WideString = '1.2.840.10008.1.2.4.51';
	K_CMDCMUID_JPEGProcess3_5TransferSyntax: WideString = '1.2.840.10008.1.2.4.52';
	K_CMDCMUID_JPEGProcess6_8TransferSyntax: WideString = '1.2.840.10008.1.2.4.53';
	K_CMDCMUID_JPEGProcess7_9TransferSyntax: WideString = '1.2.840.10008.1.2.4.54';
	K_CMDCMUID_JPEGProcess10_12TransferSyntax: WideString = '1.2.840.10008.1.2.4.55';
	K_CMDCMUID_JPEGProcess11_13TransferSyntax: WideString = '1.2.840.10008.1.2.4.56';
	K_CMDCMUID_JPEGProcess14TransferSyntax: WideString = '1.2.840.10008.1.2.4.57';
	K_CMDCMUID_JPEGProcess15TransferSyntax: WideString = '1.2.840.10008.1.2.4.58';
	K_CMDCMUID_JPEGProcess16_18TransferSyntax: WideString = '1.2.840.10008.1.2.4.59';
	K_CMDCMUID_JPEGProcess17_19TransferSyntax: WideString = '1.2.840.10008.1.2.4.60';
	K_CMDCMUID_JPEGProcess20_22TransferSyntax: WideString = '1.2.840.10008.1.2.4.61';
	K_CMDCMUID_JPEGProcess21_23TransferSyntax: WideString = '1.2.840.10008.1.2.4.62';
	K_CMDCMUID_JPEGProcess24_26TransferSyntax: WideString = '1.2.840.10008.1.2.4.63';
	K_CMDCMUID_JPEGProcess25_27TransferSyntax: WideString = '1.2.840.10008.1.2.4.64';
	K_CMDCMUID_JPEGProcess28TransferSyntax: WideString = '1.2.840.10008.1.2.4.65';
	K_CMDCMUID_JPEGProcess29TransferSyntax: WideString = '1.2.840.10008.1.2.4.66';
	K_CMDCMUID_JPEGProcess14SV1TransferSyntax: WideString = '1.2.840.10008.1.2.4.70';
	K_CMDCMUID_JPEGLSLosslessTransferSyntax: WideString = '1.2.840.10008.1.2.4.80';
	K_CMDCMUID_JPEGLSLossyTransferSyntax: WideString = '1.2.840.10008.1.2.4.81';
	K_CMDCMUID_RLELosslessTransferSyntax: WideString = '1.2.840.10008.1.2.5';
	K_CMDCMUID_DeflatedExplicitVRLittleEndianTransferSyntax: WideString = '1.2.840.10008.1.2.1.99';
	K_CMDCMUID_JPEG2000LosslessOnlyTransferSyntax: WideString = '1.2.840.10008.1.2.4.90';
	K_CMDCMUID_JPEG2000TransferSyntax: WideString = '1.2.840.10008.1.2.4.91';
	K_CMDCMUID_MPEG2MainProfileAtMainLevelTransferSyntax: WideString = '1.2.840.10008.1.2.4.100';
	K_CMDCMUID_JPEG2000Part2MulticomponentImageCompressionLosslessOnlyTransferSyntax: WideString = '1.2.840.10008.1.2.4.92';
	K_CMDCMUID_JPEG2000Part2MulticomponentImageCompressionTransferSyntax: WideString = '1.2.840.10008.1.2.4.93';
//
// end of DICOM Transfer syntax UIDs
///////////////////////////////
///

implementation

uses N_Lib0, N_Lib1;

//************************************************ TK_DCMGLibWrap.DLInitAll ***
// Load all wrapdcm.dll entries
//

function TK_DCMGLibWrap.DLInitAll(): integer;

var
  FuncAnsiName: AnsiString;
  DllFName: string;  // DLL File Name
  WStr : WideString;
//DebDICOM : Integer;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    DLErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( DLErrorStr );
    Result := 3; // some entries were not loaded
  end; // procedure ReportError(); // local

begin
  Result := 0;
  if DLDllHandle <> 0 then // wrapdcm.dll already initialized
    Exit;

  DllFName := 'wrapdcm.dll';
  DLErrorStr := '';

//DebDICOM := N_MemIniToInt( 'CMS_UserDeb', 'DebDICOM', -1 );

//  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );

//Result := 2;
//if DebDICOM = 0 then Exit;
  DLDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, DLDllHandle=%X', [DllFName,DLDllHandle] ) );

  if DLDllHandle = 0 then // some error
  begin
    DLErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    N_Dump1Str( DLErrorStr );
    Exit;
  end; // if DLDllHandle = 0 then // some error

//if DebDICOM = 1 then Exit;
  /////////////////////////////////////
  //***** Load wrapdcm.dll functions
  //
  FuncAnsiName := 'SetLog';
  DLSetLog := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSetLog) then ReportError();

  FuncAnsiName := 'Initialize';
  DLInitialize := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLInitialize) then ReportError();

  FuncAnsiName := 'Finalize';
  DLFinalize := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLFinalize) then ReportError();

  ////////////////////////////////////////
  //***** Load DCM functions
  //
  FuncAnsiName := 'CreateInstance';
  DLCreateInstance := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCreateInstance) then ReportError();

  FuncAnsiName := 'CreateInstanceFromFile';
  DLCreateInstanceFromFile := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCreateInstanceFromFile) then ReportError();

  FuncAnsiName := 'SaveInstance';
  DLSaveInstance := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSaveInstance) then ReportError();

  FuncAnsiName := 'DeleteDcmObject';
  DLDeleteDcmObject := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDeleteDcmObject) then ReportError();

  FuncAnsiName := 'ChangeTransferSyntax';
  DLChangeTransferSyntax := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLChangeTransferSyntax) then ReportError();

  FuncAnsiName := 'AddValueUint16';
  DLAddValueUint16 := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLAddValueUint16) then ReportError();

  FuncAnsiName := 'AddValueSint16';
  DLAddValueSint16 := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLAddValueSint16) then ReportError();

  FuncAnsiName := 'AddValueString';
  DLAddValueString := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLAddValueString) then ReportError();

  FuncAnsiName := 'AddImageData';
  DLAddImageData := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLAddImageData) then ReportError();

  FuncAnsiName := 'RemoveTag';
  DLRemoveTag := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLRemoveTag) then ReportError();

  FuncAnsiName := 'GetValueString';
  DLGetValueString := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetValueString) then ReportError();

  FuncAnsiName := 'GetSequenceLength';
  DLGetSequenceLength := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetSequenceLength) then ReportError();

  FuncAnsiName := 'GetSequenceItemTagValue';
  DLGetSequenceItemTagValue := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetSequenceItemTagValue) then ReportError();

  FuncAnsiName := 'GetValueUint16';
  DLGetValueUint16 := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetValueUint16) then ReportError();

  FuncAnsiName := 'GetValueSint16';
  DLGetValueSint16 := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetValueSint16) then ReportError();

  FuncAnsiName := 'GetTransferSyntax';
  DLGetTransferSyntax := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetTransferSyntax) then ReportError();

  FuncAnsiName := 'GetImageData';
  DLGetImageData := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetImageData) then ReportError();

  FuncAnsiName := 'GetWindowsDIB';
  DLGetWindowsDIB := GetProcAddress( DLDllHandle, @FuncAnsiName[1]);
  if not Assigned(DLGetWindowsDIB) then ReportError;

  FuncAnsiName := 'GetWindowsDIBSize';
  DLGetDIBSize := GetProcAddress( DLDllHandle, @FuncAnsiName[1]);
  if not Assigned(DLGetDIBSize) then ReportError;

  ////////////////////////////////////////
  //***** Load DICOMDIR functions
  //
  FuncAnsiName := 'OpenDICOMDIR';
  DLOpenDICOMDIR := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLOpenDICOMDIR) then ReportError();

  FuncAnsiName := 'CloseDICOMDIR';
  DLCloseDICOMDIR := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCloseDICOMDIR) then ReportError();

  FuncAnsiName := 'DcmDirGetPatientCount';
  DLDcmDirGetPatientCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetPatientCount) then ReportError();

  FuncAnsiName := 'DcmDirGetPatientItem';
  DLDcmDirGetPatientItem := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetPatientItem) then ReportError();

  FuncAnsiName := 'DcmDirGetStudyCount';
  DLDcmDirGetStudyCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetStudyCount) then ReportError();

  FuncAnsiName := 'DcmDirGetStudyItem';
  DLDcmDirGetStudyItem := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetStudyItem) then ReportError();

  FuncAnsiName := 'DcmDirGetSeriesCount';
  DLDcmDirGetSeriesCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetSeriesCount) then ReportError();

  FuncAnsiName := 'DcmDirGetSeriesItem';
  DLDcmDirGetSeriesItem := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetSeriesItem) then ReportError();

  FuncAnsiName := 'DcmDirGetFilesCount';
  DLDcmDirGetFilesCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetFilesCount) then ReportError();

  FuncAnsiName := 'DcmDirGetFileItem';
  DLDcmDirGetFileItem := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDcmDirGetFileItem) then ReportError();

  FuncAnsiName := 'GetDcmDirValueString';
  DLGetDcmDirValueString := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetDcmDirValueString) then ReportError();

  FuncAnsiName := 'GetDcmDirValueUint16';
  DLGetDcmDirValueUint16 := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetDcmDirValueUint16) then ReportError();

  FuncAnsiName := 'GetSrvLastErrorInfo';
  DLGetSrvLastErrorInfo := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetSrvLastErrorInfo) then ReportError();

  FuncAnsiName := 'CloseConnection';
  DLCloseConnection := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCloseConnection) then ReportError();

  FuncAnsiName := 'DeleteSrvObject';
  DLDeleteSrvObject := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLDeleteSrvObject) then ReportError();

  FuncAnsiName := 'ConnectQrScpFind';
  DLConnectQrScpFind := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectQrScpFind) then ReportError();

  FuncAnsiName := 'ConnectQrScpMove';
  DLConnectQrScpMove := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectQrScpMove) then ReportError();

  FuncAnsiName := 'GetQrFindResultObject';
  DLGetQrFindResultObject := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetQrFindResultObject) then ReportError();

  FuncAnsiName := 'GetQrFindResultCount';
  DLGetQrFindResultCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetQrFindResultCount) then ReportError();

  FuncAnsiName := 'FindQr';
  DLFindQr := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLFindQr) then ReportError();

  FuncAnsiName := 'Move';
  DLMove := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLMove) then ReportError();

  FuncAnsiName := 'ConnectEcho';
  DLConnectEcho := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectEcho) then ReportError();

  FuncAnsiName := 'Echo';
  DLEcho := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLEcho) then ReportError();

  FuncAnsiName := 'ConnectStoreScp';
  DLConnectStoreScp := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectStoreScp) then ReportError();

  FuncAnsiName := 'SendFile';
  DLSendFile := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSendFile) then ReportError();

  FuncAnsiName := 'SendInstance';
  DLSendInstance := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSendInstance) then ReportError();

  FuncAnsiName := 'ConnectMwlScp';
  DLConnectMwlScp := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectMwlScp) then ReportError();

  FuncAnsiName := 'FindMwl';
  DLFindMwl := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLFindMwl) then ReportError();

  FuncAnsiName := 'GetMwlResultCount';
  DLGetMwlResultCount := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetMwlResultCount) then ReportError();

  FuncAnsiName := 'GetMwlResultObject';
  DLGetMwlResultObject := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLGetMwlResultObject) then ReportError();

  FuncAnsiName := 'ConnectMppsScp';
  DLConnectMppsScp := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectMppsScp) then ReportError();

  FuncAnsiName := 'CreateMppsObject';
  DLCreateMppsObject := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCreateMppsObject) then ReportError();

  FuncAnsiName := 'SendMpps';
  DLSendMpps := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSendMpps) then ReportError();

  FuncAnsiName := 'CreateCommitmentRequest';
  DLCreateCommitmentRequest := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCreateCommitmentRequest) then ReportError();

  FuncAnsiName := 'AddInstanceToCommit';
  DLAddInstanceToCommit := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLAddInstanceToCommit) then ReportError();

  FuncAnsiName := 'ConnectStorageCommitmentScp';
  DLConnectStorageCommitmentScp := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLConnectStorageCommitmentScp) then ReportError();

  FuncAnsiName := 'SendStorageCommitmentRequest';
  DLSendStorageCommitmentRequest := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLSendStorageCommitmentRequest) then ReportError();

  FuncAnsiName := 'CreateDataset';
  DLCreateDataset := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLCreateDataset) then ReportError();

  FuncAnsiName := 'FindQrByDcmFilter';
  DLFindQrByDcmFilter := GetProcAddress( DLDllHandle, @FuncAnsiName[1] );
  if not Assigned(DLFindQrByDcmFilter) then ReportError();

{$R-}

//if DebDICOM = 2 then Exit;
  WStr := N_StringToWide( DLLogFileName );
  if WStr <> '' then
    DLSetLog( @WStr[1], DLLogLevel )
  else
    N_Dump1Str( 'DLSetLog >> LogFile name is empty' );
//if DebDICOM = 3 then Exit;
//Result := 0;
  DLInitialize();
  N_Dump1Str( 'Finish TK_DCMGLibWrap.DLInitAll' );
{$R+}
end; //*** end of function TK_DCMGLibWrap.DLInitAll

//******************************************** TK_DCMGLibWrap.DLFreeAll ***
// Free ImageLibrary.dll
//
function TK_DCMGLibWrap.DLFreeAll(): integer;
begin
  if DLDLLHandle <> 0 then
  begin
    DLFinalize();
    FreeLibrary( DLDLLHandle );
    DLDLLHandle := 0;
  end; // if ILDLLHandle <> 0 then

  Result := 0; // freed OK
end; //*** end of function TK_DCMGLibWrap.DLFreeAll

//*************************************************** K_CMDCMCreateIntance0 ***
// Create DICOM instance for future read attributes
//
//     Parameters
// ADCMFName - DICOM file name
// ADI - DICOM read Instance
// Result - Returns resulting code. -1 - file is absent, 0 - all OK, 1 - instance creation error
//          >100 - library initialization error
//
function K_CMDCMCreateIntance0( const ADCMFName : string; out ADI : TK_HDCMINST ) : Integer;
var
  WStr : Widestring;

begin
  ADI := nil;
  Result := -1;
  if not FileExists( ADCMFName ) then  Exit;

  Result := K_DCMGLibW.DLInitAll();
  if Result <> 0 then
  begin
    Result := Result + 100;
    Exit;
  end;

  with K_DCMGLibW do
  begin
    WStr := N_StringToWide( ADCMFName );
    Result := 1;
    ADI := DLCreateInstanceFromFile( @WStr[1], 255 );
    if ADI <> nil then
      Result := 0;
  end;
end; // function K_CMDCMCreateInstance0


//**************************************************** K_CMDCMCreateIntance ***
// Create DICOM instance for future read attributes
//
//     Parameters
// ADCMFName - DICOM file name
// ADI - DICOM read Instance
// Result - Returns resulting code. -1 - file is absent, 0 - all OK, 1 - instance creation error
//          >100 - library initialization error
//
function K_CMDCMCreateIntance( const ADCMFName : string; out ADI : TK_HDCMINST ) : Integer;
begin
  N_Dump1Str( 'K_CMDCMCreateIntance start ' +  ADCMFName );
  Result := K_CMDCMCreateIntance0( ADCMFName, ADI );
  if Result = 0 then Exit
  else
  if Result = -1 then
    N_Dump1Str( format( 'K_CMDCMCreateIntance >> File %s is absent ', [ADCMFName] ) )
  else
  if Result > 100 then
    N_Dump1Str( format( 'K_CMDCMCreateIntance >> DLInitAll error %d', [Result] ) )
  else
  if Result = 1 then
    N_Dump1Str( 'K_CMDCMCreateIntance >> Instance creation error' );
end; // function K_CMDCMCreateInstance




{*** TK_DCMSCWEBGLib ***}

//********************************************** TK_DCMSCWEBGLib.SDLInitAll ***
// Init cmsscweb.dll
//
function TK_DCMSCWEBGLib.SDLInitAll: Integer;
var
  FuncAnsiName: AnsiString;
  DllFName: string;  // DLL File Name
  WStr : WideString;
//DebDICOM : Integer;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    SDLErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( SDLErrorStr );
    Result := 3; // some entries were not loaded
  end; // procedure ReportError(); // local

begin
  Result := 0;
  if SDLDllHandle <> 0 then // cmsscweb.dll already initialized
    Exit;

  DllFName := 'cmsscweb.dll';
  SDLErrorStr := '';

  SDLDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, SDLDllHandle=%X', [DllFName,SDLDllHandle] ) );

  if SDLDllHandle = 0 then // some error
  begin
    SDLErrorStr := 'Error Loading ' + DllFName + ': ' + SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    N_Dump1Str( SDLErrorStr );
    Exit;
  end; // if DLDllHandle = 0 then // some error

//if DebDICOM = 1 then Exit;
  /////////////////////////////////////
  //***** Load wrapdcm.dll functions
  //
  FuncAnsiName := 'SetLog';
  SDLSetLog := GetProcAddress( SDLDllHandle, @FuncAnsiName[1] );
  if not Assigned(SDLSetLog) then ReportError();

  FuncAnsiName := 'Initialize';
  SDLInitialize := GetProcAddress( SDLDllHandle, @FuncAnsiName[1] );
  if not Assigned(SDLInitialize) then ReportError();

  FuncAnsiName := 'Finalize';
  SDLFinalize := GetProcAddress( SDLDllHandle, @FuncAnsiName[1] );
  if not Assigned(SDLFinalize) then ReportError();

  ////////////////////////////////////////
  //***** Load DCM functions
  //
  FuncAnsiName := 'SendImageTo';
  SDLSendImageTo := GetProcAddress( SDLDllHandle, @FuncAnsiName[1] );
  if not Assigned(SDLSendImageTo) then ReportError();

  WStr := N_StringToWide( SDLLogFileName );
  if WStr <> '' then
    SDLSetLog( @WStr[1], SDLLogLevel )
  else
    N_Dump1Str( 'SDLSetLog >> LogFile name is empty' );
//if DebDICOM = 3 then Exit;
//Result := 0;
  SDLInitialize();
  N_Dump1Str( 'Finish TK_DCMSCWEBGLib.SDLInitAll' );

end; // function TK_DCMSCWEBGLib.SDLInitAll

//******************************************** TK_DCMSCWEBGLib.SDLFreeAll ***
// Free cmsscweb.dll
//
function TK_DCMSCWEBGLib.SDLFreeAll: Integer;
begin
  if SDLDLLHandle <> 0 then
  begin
    SDLFinalize();
    FreeLibrary( SDLDLLHandle );
    SDLDLLHandle := 0;
  end; // if SLDLLHandle <> 0 then

  Result := 0; // freed OK
end; // function TK_DCMSCWEBGLib.SLFreeAll

{*** end of TK_DCMSCWEBGLib ***}

Initialization
  K_DCMGLibW := TK_DCMGLibWrap.Create;
  K_DCMSCWEBGLib := TK_DCMSCWEBGLib.Create;
Finalization
  K_DCMGLibW.DLFreeAll();
  FreeAndNil( K_DCMGLibW );

  K_DCMSCWEBGLib.SDLFreeAll();
  FreeAndNil( K_DCMSCWEBGLib );
end.

