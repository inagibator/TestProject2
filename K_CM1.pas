unit K_CM1;
// CMS additional code - Routines
interface
uses Classes, ADODB,
N_Types, N_Lib0,
K_SBuf0, K_UDT1, K_CM0;

function  K_CMSpecAccessDBDataSet( AConnectionID : Integer ) : TADOQuery;
function  K_CMPutSlideThumbnailsToFiles( ASIDs : TStrings; ASelCode : Integer;
                                         const AFilesPath : string ) : Integer;
function  K_CMPutSlidesThumbnailsToSBuf( ASIDs : TStrings; ASelCode : Integer;
                                        ASBuf : TN_SerialBuf0 ) : Boolean;
function  K_CMPutSlidesAttrsToSBuf( APatID, ASelCode : Integer; AttrsList : TStrings;
                                    ASBuf : TN_SerialBuf0 ) : Boolean;
function  K_CMPutPatientsAttrsToSBuf( const ASQLFilter, ASQLOrder : string;
                                      AStartInd, ACount : Integer;
                                      ASBuf : TN_SerialBuf0 ) : Integer;
function  K_CMPutProviderAttrsToSBuf( const ALogin, APassword : string;
                                      ASBuf : TN_SerialBuf0 ) : Integer;
function  K_CMGetSecadmLicount() : Integer;
function  K_CMGetRunCount() : Integer;

function  K_CMClearFlipFlagsInOneProfilesSet( AUDContextRoot : TN_UDBase ) : Boolean;

//////////////////////////////////////
//  CMScan mode utils
//
type TK_CMVideoFileNameRebuildFunc = function( const ANewPath, AOldName : string ) : string;
function  K_CMScanChangeVideoFileNameInSlideSerializedAttrs(
                            var ASLideAttrsBuf : string;
                            var ASizeInChars : Integer;
                            const ANewVideoPath : string;
                            ACopyFileFlag : Boolean ) : Integer;

function  K_CMScanGetCurDataPath() : string;
function  K_CMScanDecompressOrCopyTasksFile( const ASFName, ARFName,
                                       ADumpPref, ADumpInfo : string ) : Boolean;
procedure K_CMScanProcessClientTasks();
function  K_CMScanRebuildCommonInfoFile( ) : Boolean;
function  K_CMScanSetNewDataPath( ANewPath : string; ASkipRedirectPath : Boolean;
                                  APathWasChanged : Boolean  ) : Boolean;
function  K_CMScanRemoveTask( const ADumpPrfix, ATaskSFileName, ATaskRFileName,
                              ATaskRFolderName : string; AWrkStrings : TStrings;
                              AT1:  TN_CPUTimer1;
                              ADump1, ADump2 : TN_OneStrProcObj ) : Boolean;

function  K_CMScanGetFileCopyReport( const AFName : string; AFSize : Integer;
                                    ACPUTimer : TN_CPUTimer1 ) : string;
function  K_CMSaveLastInCurSlidesList( ASlidesCount : Integer ) : Integer;

/////////////////////// Device Types Limitation
function  K_CMLimitDevUseTypeNameValidation() : Boolean;
function  K_CMLimitDevGetProfileTypeName( APDevProfile : Pointer ) : string;
function  K_CMLimitDevValidateTypeName( APDevProfile : Pointer ) : Boolean;
//procedure K_CMGetValidDevProfileTypeNames( AValidDPList : TStrings );
function  K_CMLimitDevProfilesToRTDBContext() : Integer;
function  K_CMLimitDevNewProfileToRTDBContext( APDevProfile : Pointer ) : Boolean;
procedure K_CMLimitDevDelProfileFromRTDBContext( APDevProfile : Pointer );
procedure K_CMLimitDevGetAllProfilesReport( AReport : TStrings );
procedure K_CMDCMSlideStoreCommitmentAdd( ASecTimeShift, ASlideID : Integer; AInstUID, AClassUID : string );

/////////////////////// Image 3D
const K_CMImg3DDLLName  = 'CMS3DCaller.dll';// CMS 3DViewer Caller DLL file name
const K_CMImg3DCallName:  AnsiString = 'CallCMS3D';      // CMS 3DViewer Caller DLL call entry name
      K_CMImg3DCallNameA: AnsiString = 'CallCMS3DA';      // CMS 3DViewer Caller DLL call entry name
      K_CMImg3DCallNameW: AnsiString = 'CallCMS3DW';      // CMS 3DViewer Caller DLL call entry name
var   K_CMImg3DDllHandle: THandle;          // CMS 3DViewer Caller DLL Handle (nil if not loaded)
type  TK_CMImg3DCallFuncA = function ( APImportFolder, APResFolder: PAnsiChar ): Integer; stdcall;
type  TK_CMImg3DCallFuncW = function ( APImportFolder, APResFolder: PWideChar ): Integer; stdcall;
var   K_CMImg3DCallFunc   : TK_CMImg3DCallFuncA;
var   K_CMImg3DCallFuncW  : TK_CMImg3DCallFuncW;
function  K_CMImg3DCall( const ACMSFolder : string; const AImportFolder : string = '' ) : Integer;
procedure K_CMImg3DViewsFListPrep( AFilesList : TStrings;
                   const A3DSlideID, ASlideBasePath : string );
procedure K_CMImg3DViewAnnotsContPrep( );
procedure K_CMImg3DViewAnnotsContFree( );
procedure K_CMImg3DViewAnnotsImport( AUDSlide : TN_UDCMSlide; AFName : string;
                                     APixPermm : Float );
function  K_CMImg3DViewsFlistImport( AFilesList : TStrings;
                         const A3DSlideID, ASlideBasePath : string;
                         ABeforeImportProc : TN_OneStrProcObj = nil ) : Integer;
function  K_CMImg3DAttrsInit( APCMSlide : Pointer ): Boolean;
function  K_CMImg3DTmpFilesClear( const ATmpFilesPath : string ): Integer;
procedure K_CMImg3DImport( const AImport3DFolder : string; const ASourceDescr : string = '' );
procedure K_CMDev3DCreateSlide( APProfile : TK_PCMOtherProfile; const ADev3DObjFolder : string;
                                AThumbDIBObj : TObject;
                                AWidth, AHeight, ADepth, APixSize : Integer );

function  K_CMFilesEmailingBySelfClient( const ASubject : string; AFilesList : TStrings ) : Boolean;
function  K_CMPrepSlideDIBFile( const AFileName : string;
              ASlide : TN_UDCMBSlide;
              var AMaxWidth, AMaxHeight : Integer;
              AFileFormat : Integer;
              AExportToDIBFlags : TK_CMBSlideExportToDIBFlags ) : Integer;

procedure K_CMRemoveOldDump1Data( ABoundDate : TDateTime );
procedure K_CMRemoveOldDumpSCUData( ABoundDate : TDateTime );
procedure K_CMRemoveOldDumpSCDData( ABoundDate : TDateTime );
procedure K_CMRemoveOldDumpWrapDCMData( ABoundDate : TDateTime );
function  K_CMRemoveOldDumpMonths( ) : Double;
procedure K_CMRemoveOldDumpAllData( );
procedure K_CMRemoveOldDump2ExceptFiles( );
procedure K_CMRemoveOldDump2HaltFiles( );

// Study Templates Unload Flags
type TK_CMStTempUnloadFlags = set of (
  K_sttUnloadPosAttrDetails, // Unload Flip/Rotate and TeeyhChart Info details
  K_sttSkipUnloadTemlateID );// Skip unload Template ID (for user unloading built in smaples)

procedure K_CMStudyTemplateUnloadDescr( AUDTemplate : TN_UDBase; ASL : TStrings;
                                        AUnloadFlags : TK_CMStTempUnloadFlags = [] );
function  K_CMStudyTemplatePrepSampleMapRoot( out ASampleUDMapRoot : TN_UDBase ) : Boolean;
function  K_CMStudyTemplatePrepStubImgUDFolder( out AStubImgUDFolder : TN_UDBase ) : Boolean;
function  K_CMStudyTemplateLoadDescr( AUDTemplate : TN_UDBase; ASL : TStrings;
                                      AIgnoreSelfIDs : Boolean;
                                      AOrderInds : TN_IArray = nil;
                                      AFlipRotateCodes : TN_IArray = nil;
                                      ASampleUDMapRoot : TN_UDBase = nil;
                                      AStubImgUDFolder : TN_UDBase = nil ) : Boolean;

procedure K_CMLoadUserStrings();
procedure K_CMSaveUserStrings();
function  K_CMGetUserString( const AUStrName : string ) : string;
procedure K_CMSetUserString(const AUStrName, AUStrValue : string);

const K_BadImg   = 'Bad images';
const K_BadVideo = 'Bad video';
const K_BadImg3D = 'Bad 3D images';

type TK_CMFSBuildFilesListFlags = set of ( // Build FilesList Flags Set
  K_fsbflUseRelFName,  // use relative File name Flag
  K_fsbflUseExtrFName  // use extract File name Flag
);
procedure K_CMFSBuildOneFList( const ARootFolderName, ASkipFolderName : string;
                                   AFlags : TK_CMFSBuildFilesListFlags );
procedure K_CMFSBuildExistedFLists( AImgFL, AVideoFL, AImg3DFL: TStrings;
                                       AFlags : TK_CMFSBuildFilesListFlags );
type TK_CMFSBuildNeededProc = procedure ( AllCount, CurCount : Integer ) of Object;
procedure K_CMFSBuildNeededFLists( AImgFL, AVideoFL, AImg3DFL: TStrings;
                                   AAImgFL, AAVideoFL, AAImg3DFL: TStrings;
                                   AFlags : TK_CMFSBuildFilesListFlags;
                                   ADSet : TADOQuery;
                                   AProgressProc : TK_CMFSBuildNeededProc );

procedure K_CMFSCompNeededExistedFLists( AExistedFL, ANeededFL : TStringList;
                                     AProgressProc : TK_CMFSBuildNeededProc );
procedure K_CMInitMouseMoveRedraw();
function  K_CMExport3DObj( ASlide : TN_UDCMSlide; const ARPath, ASPath : string;
                          var ARCount, AAllCount : Integer; var ASize : Int64 ) : Integer;


implementation

uses Windows, SysUtils, DB, Forms, Math, StrUtils, Dialogs, Controls, Contnrs,
  N_Lib1, N_CM1, N_Gra0, N_Gra2, N_Gra6, N_CMSendMailF, N_CMMain5F, N_Comp1, N_Lib2,
  N_CompCL, N_CompBase, N_Comp2, N_CMResF,
  K_CLib0, K_STBuf, K_UDC, K_UDT2, K_Script1, K_RImage,K_CMCaptDevReg, K_CML1F,
  K_CMDCMGLibW;

//************************************************* K_CMSpecAccessDBDataSet ***
// Get DB Data Set object for retreiving Slides Attributes
//
//     Parameters
// Result - Returns Data Set object
//
function K_CMSpecAccessDBDataSet( AConnectionID : Integer ) : TADOQuery;
var
  ExtPars : string;
  ConStr : string;
  Connected : Boolean;
begin
  N_Dump2Str('DB>> K_CMSpecAccessDBDataSet start ' + IntToStr(AConnectionID) );
  if K_CMEDAccess <> nil then
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    if LANDBConnection.Connected then
    begin
      N_Dump2Str('DB>> K_CMSpecAccessDBDataSet use CurBlobDSet' );
      Result := CurBlobDSet;
      Result.Connection := LANDBConnection;
      Exit;
    end;
  end;

  Result := nil;
  if AConnectionID = - 1 then
  begin
    N_Dump1Str('DB>> K_CMSpecAccessDBDataSet Error ConID = -1' );
    Exit;
  end;

  if K_CMAddDBConnection = nil then
  begin
    N_Dump2Str('DB>> K_CMSpecAccessDBDataSet create AddDBConnection' );
    K_CMAddDBConnection := TADOConnection.Create(Application);
    K_CMAddDBConnection.LoginPrompt := false;
    K_CMAddADOQuery := TADOQuery.Create(Application);
    K_CMAddADOQuery.Connection := K_CMAddDBConnection;
    K_CMAddADOCommand := TADOCommand.Create(Application);
    K_CMAddADOCommand.Connection := K_CMAddDBConnection;
  end;

  Result := K_CMAddADOQuery;
  Connected := K_CMAddDBConnection.Connected;
  if Connected and (K_CMAddDBConnectionID = AConnectionID) then
  begin
    N_Dump2Str('DB>> K_CMSpecAccessDBDataSet use ready AddDBConnection' );
    Exit // Additional Connection is ready
  end
  else
  if Connected then
  begin  // Reconnection is needed
    N_Dump1Str( format( 'DB>> K_CMSpecAccessDBDataSet Reconnection ConID %d -> %d',
                        [K_CMAddDBConnectionID,AConnectionID] ) );
    K_CMAddDBConnection.Connected := FALSE;
  end;

  K_CMAddDBConnectionID := AConnectionID;
  // Connect Additional Connection
  try
    N_Dump2Str('DB>> K_CMSpecAccessDBDataSet AddDBConnection open' );
    // Save Cur ExtProperties
    ExtPars := N_MemIniToString('CMSDB', 'ExtProperties', '');
    // Set ExtProperties for not counted conection
    if K_CMAddDBConnectionID = 1 then
      N_StringToMemIni('CMSDB', 'ExtProperties', 'UID=cms_web_api;PWD=cmsweb;DSN=CMSImg' )
    else
      N_StringToMemIni('CMSDB', 'ExtProperties', 'UID=cms_ent_view;PWD=cms;DSN=CMSImg' );
    // Get and use Connection String build by using current ExtProperties
    ConStr := K_CMDBGetConnectionString();
    K_CMAddDBConnection.ConnectionString := ConStr;
    // Restore prevoiuse ExtProperties
    N_StringToMemIni('CMSDB', 'ExtProperties', ExtPars );
    // Open Additional Connection
    K_CMAddDBConnection.Open();
  except
    on E: Exception do
    begin
      ExtPars := 'AddDBConnection >> ' + E.Message + #13#10 + ConStr;
      N_Dump1Str(ExtPars);
      Result := nil;
    end;
  end;

end; // function K_CMSpecAccessDBDataSet

//******************************************* K_CMPutSlideThumbnailsToFiles ***
// Get Thumbnails by Slide IDs List and put to files
//
//     Parameters
// ASIDs    - source Slides IDs Strings
// ASelCode - selected code: 0 - actual, 1 - marked as deleted, 2 - all
// ASBuf    - resulting slides thumbnails serialized data
// Result   - Returns resulting Thumbnails File or -1 if connection errors
//
// Thumbnails serialized data is ByteArray which containes the same number
// of fragments as in source Slides IDs array. First 4 bytes of each fragment
// contains integer with thumbnail byte length. Fragment tail bytes contains
// thumbnail data. If some slide given in Slides IDs array is absent then
// thumbnail byte length should be equal 0.
//
function  K_CMPutSlideThumbnailsToFiles( ASIDs : TStrings; ASelCode : Integer;
                                         const AFilesPath : string ) : Integer;
var
  i, DSize: Integer;
  SQLStr: string;
  SelFlags : TK_CMEDASelectWhereFlags;
  Stream: TStream;
  FStream : TFileStream;
  DataSet : TADOQuery;
  FName : string;
  EmptyDIBObj : TN_DIBObj;
  RIEncodingInfo : TK_RIFileEncInfo;

begin

  Result := ASIDs.Count;
  N_Dump2Str('DB>> K_CMPutSlideThumbnailsToFiles start ' + IntToStr(Result) );
  if Result = 0 then Exit;

  DataSet := K_CMSpecAccessDBDataSet( -1 );
  if DataSet = nil then
  begin
    Result := -1;
    N_Dump1Str('DB>> K_CMPutSlideThumbnailsToFiles ConnectionError' );
  end;

  if Result <= 0 then Exit;

  EmptyDIBObj := nil;

  try
    SQLStr := K_CMENDBSTFSlideID + ' = ' + ASIDs[0];
    for i := 1 to Result - 1 do
      SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + ASIDs[i];
    N_Dump2Str('DB>> K_CMPutSlideThumbnailsToFiles IDs:'#13#10 + SQLStr );


    SelFlags := K_swfSkipAllDel;
    if ASelCode = 1 then
      SelFlags :=  K_swfOnlyMarkedAsDel
    else if ASelCode = 2 then
      SelFlags :=  K_swfSkipFlagsCond;

    with DataSet do
    begin

      SQL.Text := 'select ' + K_CMENDBSTFSlideID + ',' + K_CMENDBSTFSlideThumbnail +
        ' from ' + K_CMENDBSlidesTable +
        ' where (' +  SQLStr + ')' +
                K_CMEDAGetSlideSelectWhereStr( SelFlags );

      Filtered := FALSE;
      Open;
      for i := 0 to Result - 1 do
      begin
        Filter := K_CMENDBSTFSlideID + ' = ' + ASIDs[i];
        Filtered := TRUE;
        FName := AFilesPath + 'I' + ASIDs[i] + '.jpg';
        FStream := TFileStream.Create( FName, fmCreate);
        if (RecordCount > 0) and not Fields[1].IsNull  then
        begin
          Stream := CreateBlobStream(Fields[1], bmRead);
          FStream.CopyFrom( Stream, 0 );
          Stream.Free;
        end // if RecordCount > 0 then
        else
        begin // if RecordCount = 0 then
          if EmptyDIBObj = nil then
            EmptyDIBObj := K_CMBSlideCreateThumbnailDIBByAspect( 1 );
          with K_RIObj do
          begin
            RIClearFileEncInfo( @RIEncodingInfo );
            RIEncodingInfo.RIFileEncType := rietJPG;
            RIEncodingInfo.RIFComprQuality := K_CMSlideThumbQuality;
            // Save Image
            if RISaveDIBToStream( EmptyDIBObj, FStream, @RIEncodingInfo ) = rirOK then
              N_Dump2Str( ' DB>> Save ThumbDIB To File Size =' + IntToStr(FStream.Size) ) // TMP DUMP DATA SIZE
            else
              raise Exception.Create( 'RISaveDIBToStream Error K_RIObj=' + ClassName );
          end; // with K_RIObj do
        end; // if RecordCount = 0 then

        DSize := FStream.Size;
        FStream.Free;

        N_Dump2Str( format( 'DB>> K_CMPutSlidesThumbnailsToSBuf ID=%s DSize=%d',
                            [ASIDs[i],DSize] ) );

        Filtered := FALSE;

      end; // for i := 0 to Result - 1 do
      Close();
    end; // with CurBlobDSet do

    EmptyDIBObj.Free;

    N_Dump2Str('DB>> K_CMPutSlideThumbnailsToFiles fin');
  except
    on E: Exception do
    begin
//      SL.Free();
      SQLStr := 'K_CMPutSlideThumbnailsToFiles >> ' + E.Message;
      N_Dump1Str(SQLStr);
      raise Exception.Create(SQLStr);
    end;
  end;
end; // procedure K_CMPutSlideThumbnailsToFiles

//******************************************* K_CMPutSlidesThumbnailsToSBuf ***
// Get Thumbnails by Slide IDs List ant put to SBuf
//
//     Parameters
// ASIDs    - source Slides IDs Strings
// ASelCode - selected code: 0 - actual, 1 - marked as deleted, 2 - all
// ASBuf    - resulting slides thumbnails serialized data
// Result   - Returns FALSE if connection errors are detected
//
// Thumbnails serialized data is ByteArray which containes the same number
// of fragments as in source Slides IDs array. First 4 bytes of each fragment
// contains integer with thumbnail byte length. Fragment tail bytes contains
// thumbnail data. If some slide given in Slides IDs array is absent then
// thumbnail byte length should be equal 0.
//
function K_CMPutSlidesThumbnailsToSBuf( ASIDs : TStrings; ASelCode : Integer;
                                       ASBuf : TN_SerialBuf0 ) : Boolean;
var
  i, DSize, SlidesCount: Integer;
  SQLStr: string;
  SelFlags : TK_CMEDASelectWhereFlags;
  Stream: TStream;
  PData : PByte;
  DataSet : TADOQuery;

begin
  Result := TRUE;
  SlidesCount := ASIDs.Count;
  N_Dump2Str('DB>> K_CMPutSlidesThumbnailsToSBuf start ' + IntToStr(SlidesCount) );
  if SlidesCount = 0 then Exit;

  DataSet := K_CMSpecAccessDBDataSet( 0 );
  if DataSet = nil then
  begin
    Result := FALSE;
    SlidesCount := 0;
    N_Dump1Str('DB>> K_CMPutSlidesThumbnailsToSBuf ConnectionError' );
  end;
  ASBuf.AddRowInt( SlidesCount );

  if SlidesCount = 0 then Exit;

  try
    SQLStr := K_CMENDBSTFSlideID + ' = ' + ASIDs[0];
    for i := 1 to SlidesCount - 1 do
    begin
      SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + ASIDs[i];
    end;
    N_Dump2Str('DB>> K_CMPutSlidesThumbnailsToSBuf IDs:'#13#10 + SQLStr );


    SelFlags := K_swfSkipAllDel;
    if ASelCode = 1 then
      SelFlags :=  K_swfOnlyMarkedAsDel
    else if ASelCode = 2 then
      SelFlags :=  K_swfSkipFlagsCond;

    with DataSet do
    begin

      SQL.Text := 'select ' + K_CMENDBSTFSlideID + ',' + K_CMENDBSTFSlideThumbnail +
        ' from ' + K_CMENDBSlidesTable +
        ' where (' +  SQLStr + ')' +
                K_CMEDAGetSlideSelectWhereStr( SelFlags );
//                EDAGetSlideSelectWhereStr( SelFlags );

      Filtered := FALSE;
      Open;

      for i := 0 to SlidesCount - 1 do
      begin
        Filter := K_CMENDBSTFSlideID + ' = ' + ASIDs[i];
        Filtered := TRUE;
        DSize := 0;
        if (RecordCount > 0) and not Fields[1].IsNull then
        begin
          Stream := CreateBlobStream(Fields[1], bmRead);
          DSize := Stream.Size;
          ASBuf.AddRowInt( DSize );
          if DSize > 0 then
          begin
            ASBuf.IncCapacity( DSize );
            PData := ASBuf.PFree();
            Stream.Read( PData^, DSize ); // Plain or Encrypted Data
            ASBuf.ShiftFreeOffset( DSize );
          end;
          Stream.Free;
        end // if RecordCount > 0 then
        else
          ASBuf.AddRowInt( DSize );
        N_Dump2Str( format( 'DB>> K_CMPutSlidesThumbnailsToSBuf ID=%s DSize=%d',
                            [ASIDs[i],DSize] ) );

        Filtered := FALSE;
      end;

      Close();
    end; // with CurBlobDSet do
//    SL.Free();
    N_Dump2Str('DB>> K_CMPutSlidesThumbnailsToSBuf fin');
  except
    on E: Exception do
    begin
//      SL.Free();
      SQLStr := 'K_CMPutSlidesThumbnailsToSBuf >> ' + E.Message;
      N_Dump1Str(SQLStr);
      raise Exception.Create(SQLStr);
    end;
  end;
end; // procedure K_CMPutSlidesThumbnailsToSBuf

//************************************************ K_CMPutSlidesAttrsToSBuf ***
// Get Slide Attributes given by Patient and select code and put to SBuf
//
//     Parameters
// APatID    - Patient ID
// ASelCode  - selected code: 0 - actual, 1 - marked as deleted, 2 - all
// AttrsList - needed attributes list
// ASBuf     - resulting slides attributes serialized data
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
// ModifyDate	    string	Object modify date (dd.mm.yyyy) - not done
// ModifyTime	    string	Object modify time (hh:nn:ss)   - not done
//#/F
// Result - Returns FALSE if connection errors are detected
//
function K_CMPutSlidesAttrsToSBuf( APatID, ASelCode : Integer; AttrsList : TStrings;
                                  ASBuf : TN_SerialBuf0 ) : Boolean;
var
  i, RCount, StudyID, ObjType: Integer;
  SQLFields, SQLFrom: string;
  SelFlags : TK_CMEDASelectWhereFlags;
  DT : TDateTime;
  StudyIDFieldInd, MTNameFieldInd, StudyItemPosFieldInd, CurFieldInd : Integer;
  CMSDB : TN_CMSlideSDBF;
  CurAttrName : string;
  TeethLeftSet, TeethRightSet : Integer;
  WI64 : Int64;
  DataSet : TADOQuery;
  AddSlide : Boolean;
  RCountBufShift : Integer;
begin
  Result := TRUE;
  N_Dump2Str('DB>> K_CMPutSlidesAttrsToSBuf start' + #13#10 + AttrsList.CommaText);

  DataSet := K_CMSpecAccessDBDataSet( 0 );
  if DataSet = nil then
  begin
    Result := FALSE;
    N_Dump1Str('DB>> K_CMPutSlidesAttrsToSBuf ConnectionError' );
    Exit;
  end;

  SelFlags := K_swfSkipAllDel;
  if ASelCode = 1 then
    SelFlags :=  K_swfOnlyMarkedAsDel
  else if ASelCode = 2 then
    SelFlags :=  K_swfSkipFlagsCond;

  // Prepare SQL
  SQLFields := 'select ' +
    'A.'+ K_CMENDBSTFSlideID + ',' +          //0
    'A.'+ K_CMENDBSTFSlideDTTaken + ',' +     //1
    'A.'+ K_CMENDBSTFSlideTeethLeft + ',' +   //2
    'A.'+ K_CMENDBSTFSlideTeethRight + ',' +  //3
    'A.'+ K_CMENDBSTFSlideMTypeID + ',' +     //4
    'A.'+ K_CMENDBSTFSlideSrcDescr + ',' +    //5
    'A.'+ K_CMENDBSTFSlideDiagnoses + ',' +   //6
    'A.'+ K_CMENDBSTFSlideSysInfo;            //7

  CurFieldInd := 8;

  StudyIDFieldInd := -1;
  if K_CMEDDBVersion >= 24 then
  begin
    SQLFields := SQLFields + ',' + 'A.'+ K_CMENDBSTFSlideStudyID; //8
    StudyIDFieldInd := CurFieldInd;
    Inc(CurFieldInd);
  end;

  StudyItemPosFieldInd := -1;
  if K_CMEDDBVersion >= 39 then
  begin
    SQLFields := SQLFields + ',' + 'A.'+ K_CMENDBSTFSlideStudyItemPos; //9
    StudyItemPosFieldInd := CurFieldInd;
    Inc(CurFieldInd);
  end;


  SQLFrom := ' from ' + K_CMENDBSlidesTable + ' A ';
  MTNameFieldInd := -1;
  if AttrsList.IndexOf( 'MediaTypeName' ) >= 0 then
  begin
    SQLFields := SQLFields + ',P.' + K_CMENDBMTFMTypeTitle; //9
    SQLFrom := SQLFrom + ' JOIN ' + K_CMENDBMTypesTable + ' P' +
    ' ON (A.' + K_CMENDBSTFSlideMTypeID + '=P.' + K_CMENDBMTFMTypeID + ')';

    MTNameFieldInd := CurFieldInd;
  end;

  try
    with  DataSet do
    begin
      // Select Data
      CurAttrName := SQLFields + SQLFrom +
          ' where (A.' +  K_CMENDBSTFPatID + '=' + IntToStr(APatID) + ')' +
                  K_CMEDAGetSlideSelectWhereStr( SelFlags, 'A.' );
//                  EDAGetSlideSelectWhereStr( SelFlags, 'A.' );
      if K_CMEDDBVersion >= 41 then
        CurAttrName := CurAttrName + ' and not (' + 'A.'+ K_CMENDBSTFSlideThumbnail +
                       ' is null)';

      N_Dump2Str( 'DB>> K_CMPutSlidesAttrsToSBuf SQL=:'#13#10 + CurAttrName );

      SQL.Text := CurAttrName;

      Filtered := FALSE;
      Open;

      RCount := RecordCount;
      RCountBufShift := ASBuf.OfsFree;
      ASBuf.AddRowInt( RCount );
      N_Dump2Str( 'DB>> K_CMPutSlidesAttrsToSBuf RCount=' + IntToStr(RCount) );

      if RCount > 0 then
      begin
        First();

        // Selected Slides Loop
        while not Eof do
        begin
          K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[7]), @CMSDB); // SysInfo
          AddSlide := TRUE;
          if not K_CMDesignModeFlag           and
             (cmsfIsImg3DObj in CMSDB.SFlags) and
             ( (K_CMSLiRegStatus <> K_lrtComplex) or
               (limdImg3D in K_CMSLiRegModDisable) ) then
          begin
            AddSlide := FALSE;
            N_Dump2Str( 'DB>> K_CMPutSlidesAttrsToSBuf skip 3D slide ID=' + FieldList[0].AsString );
          end;

          if AddSlide                                   and
            (K_CMEDDBVersion >= 39)                     and
            (FieldList[StudyIDFieldInd].AsInteger > 0 ) and
            (FieldList[StudyItemPosFieldInd].AsInteger > 0) then
          begin
            AddSlide := FALSE;
            N_Dump2Str( 'DB>> K_CMPutSlidesAttrsToSBuf skip invisible slide ID=' + FieldList[0].AsString );
          end;

          if AddSlide then
          begin // Add Slide Attributes
            DT := 0;
            TeethLeftSet := -1;
            TeethRightSet := -1;
            StudyID := -1;

            // Attrs Loop
            for i := 0 to AttrsList.Count - 1 do
            begin
              CurAttrName := AttrsList[i];
              if CurAttrName = 'ObjID' then
              begin
                ASBuf.AddRowInt( FieldList[0].AsInteger );
              end
              else
              if (CurAttrName = 'DateTaken') or (CurAttrName = 'TimeTaken') then
              begin
                if DT = 0 then
                begin
                  DT := TDateTimeField(FieldList[1]).Value;
                  ASBuf.AddRowDouble( DT );
                end
              end
              else
              if CurAttrName = 'TeethLeftSet' then
              begin
                if TeethLeftSet = -1 then
                  TeethLeftSet := FieldList[2].AsInteger;
                ASBuf.AddRowInt( TeethLeftSet );
              end
              else
              if CurAttrName = 'TeethRightSet' then
              begin
                if TeethRightSet = -1 then
                  TeethRightSet := FieldList[3].AsInteger;
                ASBuf.AddRowInt( TeethRightSet );
              end
              else
              if CurAttrName = 'TeethSetCapt' then
              begin
                if TeethLeftSet = -1 then
                  TeethLeftSet := FieldList[2].AsInteger;
                if TeethRightSet = -1 then
                  TeethRightSet := FieldList[3].AsInteger;
                WI64 := TeethLeftSet; // Left Teeth Flags
                ASBuf.AddRowString( K_CMSTeethChartStateToText( (WI64 shl 32) or TeethRightSet ) );
              end
              else
              if CurAttrName = 'MediaTypeID' then
              begin
                ASBuf.AddRowInt( FieldList[4].AsInteger );
              end
              else
              if CurAttrName = 'MediaTypeName' then
              begin
                ASBuf.AddRowString( FieldList[MTNameFieldInd].AsString );
              end
              else
              if CurAttrName = 'Source' then
              begin
                ASBuf.AddRowString( FieldList[5].AsString );
              end
              else
              if CurAttrName = 'Diagn' then
              begin
                ASBuf.AddRowString( FieldList[6].AsString );
              end
              else
              if CurAttrName = 'ObjStudyID' then
              begin
                if StudyID < 0 then
                begin
                  StudyID := 0;
                  if K_CMEDDBVersion >= 24 then
                    StudyID := FieldList[StudyIDFieldInd].AsInteger;
                end;
                ASBuf.AddRowInt( StudyID );
              end
              else
              if CurAttrName = 'ObjType' then
              begin
                if StudyID < 0 then
                begin
                  StudyID := 0;
                  if K_CMEDDBVersion >= 24 then
                    StudyID := FieldList[StudyIDFieldInd].AsInteger;
                end;

                ObjType := 0;
                if StudyID < 0 then
                  ObjType := 2   // Study
                else
                if cmsfIsMediaObj in CMSDB.SFlags then
                  ObjType := 1   // Media Slide
                else
                if cmsfIsImg3DObj in CMSDB.SFlags then
                  ObjType := 3;  // 3D Slide
                ASBuf.AddRowInt( ObjType );
              end
              else
              if CurAttrName = 'PixWidth' then
              begin
                ASBuf.AddRowInt( CMSDB.PixWidth );
              end
              else
              if CurAttrName = 'PixHeight' then
              begin
                ASBuf.AddRowInt( CMSDB.PixHeight );
              end
              else
              if CurAttrName = 'PixColorDepth' then
              begin
                ASBuf.AddRowInt( CMSDB.PixBits );
              end
              else
              if CurAttrName = 'VideoDuration' then
              begin
                ASBuf.AddRowFloat( CMSDB.MDuration );
              end
              else
              if CurAttrName = 'VideoFExt' then
              begin
                ASBuf.AddRowString( CMSDB.MediaFExt );
              end
            end; // for i := 0 to AttrsList.Count - 1 do
          end // if AddSlide then
          else
            Dec(RCount); // Decr Result Count if slide is skiped

          Next();
        end; // while not Eof do

        PInteger(@ASBuf.Buf1[RCountBufShift])^ := RCount;
      end; // if RCount > 0 then

      Close();
    end; // with  CurBlobDSet do

    N_Dump2Str('DB>> K_CMPutSlidesAttrsToSBuf fin');
  except
    on E: Exception do
    begin
      SQLFields := 'K_CMPutSlidesAttrsToSBuf >> ' + E.Message;
      N_Dump1Str(SQLFields);
      raise Exception.Create(SQLFields);
    end;
  end;
end; // procedure K_CMPutSlidesAttrsToSBuf

//********************************************** K_CMPutPatientsAttrsToSBuf ***
// Get Patients Attributes and put to SBuf
//
//     Parameters
// ASQLFilter - SQL WHERE close
// ASQLOrder  - SQL ORDER close
// AStart     - select start record index
// ACount     - select recoreds count
// ASBuf      - resulting patients attributes serialized data
// Result     - Returns number of patients selected or -1 if connection errors are detected
//
function K_CMPutPatientsAttrsToSBuf( const ASQLFilter, ASQLOrder : string;
                                     AStartInd, ACount : Integer;
                                     ASBuf : TN_SerialBuf0 ) : Integer;
var
  WInt: Integer;
  SQLStr: string;
  SGender: string;
  DataSet : TADOQuery;

begin
  N_Dump2Str( format('DB>> K_CMPutPatientsAttrsToSBuf start S=%d C=%d',
              [AStartInd, ACount] ) );
  DataSet := K_CMSpecAccessDBDataSet( -1 ); //
  if DataSet = nil then
  begin
    Result := -1;
    N_Dump1Str('DB>> K_CMPutPatientsAttrsToSBuf ConnectionError' );
    Exit;
  end;

  try
    with DataSet do
    begin

      SQLStr := '';
      if ACount > 0 then
        SQLStr := ' TOP ' + IntToStr(ACount);
      if AStartInd > 0 then
        SQLStr := SQLStr + ' START AT ' + IntToStr(AStartInd + 1);

      SQLStr := 'select ' + SQLStr + ' ' +
        K_CMENDAPID      + ',' + K_CMENDAPBridgeID  + ',' + // 0 1
        K_CMENDAPCardNum + ',' + K_CMENDAPTitle     + ',' + // 2 3
        K_CMENDAPSurname + ',' + K_CMENDAPFirstname + ',' + // 4 5
        K_CMENDAPMiddle  + ',' + K_CMENDAPDOB       + ',' + // 6 7
        K_CMENDAPGender +                                   // 8
        ' from ' + K_CMENDBAllPatientsTable;

      SQL.Text := SQLStr + ASQLFilter + ASQLOrder;

      Filtered := FALSE;
      Open;

      Result := RecordCount;
      ASBuf.AddRowInt( Result );
      First();
      while not EOF do
      begin
        ASBuf.AddRowInt( FieldList[1].AsInteger );
        ASBuf.AddRowString( FieldList[2].AsString );
        ASBuf.AddRowString( FieldList[3].AsString );
        ASBuf.AddRowString( FieldList[4].AsString );
        ASBuf.AddRowString( FieldList[5].AsString );
        ASBuf.AddRowString( FieldList[6].AsString );
        ASBuf.AddRowDouble( FieldList[7].AsDateTime );
        WInt := 0;
        SGender := UpperCase(FieldList[8].AsString);
        if (Length(SGender) >= 1) and (SGender[1] = 'F') then
          WInt := 1;
        ASBuf.AddRowInt( WInt );
        Next();
      end;
      Close();
    end; // with CurBlobDSet do
    N_Dump2Str('DB>> K_CMPutPatientsAttrsToSBuf fin');
  except
    on E: Exception do
    begin
      SQLStr := 'K_CMPutPatientsAttrsToSBuf >> ' + E.Message;
      N_Dump1Str(SQLStr);
      raise Exception.Create(SQLStr);
    end;
  end;
end; // function K_CMPutPatientsAttrsToSBuf

//********************************************** K_CMPutPatientsAttrsToSBuf ***
// Get Patients Attributes and put to SBuf
//
//     Parameters
// ALogin     - user login
// APassowrd  - user password
// ASBuf      - resulting patients attributes serialized data
// Result   - Returns
//#F
// =0 if wrong Login or Password,
// =-1 if get attributes problem,
// =Provider ID  if OK
//#/F
//
function K_CMPutProviderAttrsToSBuf( const ALogin, APassword : string;
                                     ASBuf : TN_SerialBuf0 ) : Integer;
var
  DataSet : TADOQuery;
  ErrStr: string;

  SQLIDFName : string;
  ProviderDBData : TK_CMSAProviderDBData;
  LockFlags : TK_CMSAGetInfoFlags;
  SProvID : string;

begin
  N_Dump2Str( format('DB>> K_CMPutProviderAttrsToSBuf start L=%s P=%s',
                               [ALogin, APassword] ) );
  DataSet := K_CMSpecAccessDBDataSet( 1 );
  if DataSet = nil then
  begin
    Result := -1;
    N_Dump1Str('DB>> K_CMPutProviderAttrsToSBuf ConnectionError' );
    Exit;
  end;

  try
    if K_CMEDDBVersion >= 31 then
    begin
      Result := 0;
      with DataSet do
      begin
        SQL.Text := 'select ' +
            K_CMENDAUBridgeID + ',' + K_CMENDAUTitle     + ',' +   // 0, 1                              // 3
            K_CMENDAUSurname  + ',' + K_CMENDAUFirstname + ',' +   // 2, 3
            K_CMENDAUMiddle   + ',' + K_CMENDAUAuthorities +       // 4, 5
          ' from ' + K_CMENDBAllProvidersTable +
          ' where (' + K_CMENDAUFlags + ' & 1) = 0' +
          ' and '    + K_CMENDAUEncLP + ' = ''' +
                            K_EncodeLoginPassword(ALogin, APassword) + '''';

        Filtered := false;
        Open;
        if RecordCount > 0 then
        begin
          First;
          Result := Fields[0].AsInteger;
          ASBuf.AddRowInt( Result );                // ID
          ASBuf.AddRowString( Fields[1].AsString ); // Title
          ASBuf.AddRowString( Fields[2].AsString ); // Surname
          ASBuf.AddRowString( Fields[3].AsString ); // Firstname
          ASBuf.AddRowString( Fields[4].AsString ); // Middle
        end;

        Close;
      end; // with DataSet do

      N_Dump2Str('DB>> K_CMPutProviderAttrsToSBuf fin ProvID=' + IntToStr(Result) );
    end   // if K_CMEDDBVersion >= 31 then
    else
    begin // if K_CMEDDBVersion < 31 then
    //////////////////////////////////////////
    //  select Provider ID to Result
    //  special case for debug only !!!
      Result := -101;
    //  select Provider ID
    //////////////////////////////////////////

      SProvID := IntToStr(Result);
      if K_CMEDDBVersion >= 22 then
        SQLIDFName := K_CMENDAUBridgeID
      else
        SQLIDFName := K_CMENDAUID;

      LockFlags := [];
      if K_edOK = K_CMDBGetOneProviderInfo( DataSet, SQLIDFName, -1,
                                            SProvID, @ProviderDBData, LockFlags ) then
      begin
        ASBuf.AddRowInt( Result );
        ASBuf.AddRowString( ProviderDBData.AUTitle );
        ASBuf.AddRowString( ProviderDBData.AUSurname );
        ASBuf.AddRowString( ProviderDBData.AUFirstname );
        ASBuf.AddRowString( ProviderDBData.AUMiddle );
      end
      else
      begin
        SProvID := SProvID + ' absent';
        Result := 0;
      end;
      N_Dump2Str('DB>> K_CMPutProviderAttrsToSBuf fin ProvID=' + SProvID);
    end;  // if K_CMEDDBVersion < 31 then
  except
    on E: Exception do
    begin
      ErrStr := 'K_CMPutPatientsAttrsToSBuf >> ' + E.Message;
      N_Dump1Str(ErrStr);
      raise Exception.Create(ErrStr);
    end;
  end;
end; // function K_CMPutProviderAttrsToSBuf

//**************************************************** K_CMGetSecadmLicount ***
// Get Licenses Counter
//
//     Parameters
// Result - Returns
//#F
// =-1 trial version,
// =-2 if DB access Error
// =Licenses Counter
//#/F
//
function K_CMGetSecadmLicount() : Integer;
var
  DataSet : TADOQuery;
begin
  N_Dump2Str( 'DB>> K_CMGetSecadmLicount start' );
  DataSet := K_CMSpecAccessDBDataSet( 1 );
  if DataSet = nil then
  begin
    Result := -2;
    N_Dump1Str('DB>> K_CMGetSecadmLicount ConnectionError' );
    Exit;
  end;


  try
    with DataSet do
    begin
      SQL.Text := 'begin'#10'select secadm.sec_get_licount();'#10'end';
      Open;
      Result := FieldList.Fields[0].AsInteger;
      N_Dump2Str( 'DB>> K_CMGetSecadmLicount LI=' + IntToStr(Result) );
      Close;
    end;
  except
    on E: Exception do begin
      Result := -2;
      N_Dump1Str( 'K_CMGetSecadmLicount >> ' + E.Message );
    end;
  end;
end; // function K_CMGetSecadmLicount

//********************************************************* K_CMGetRunCount ***
// Get CMS run Instances Counter
//
//     Parameters
// Result - Returns
//#F
// =-1 DB access Errors
// =CMS run Instances Counter
//#/F
//
function K_CMGetRunCount() : Integer;
var
  DataSet : TADOQuery;
  CDTime : TDateTime;
begin
  N_Dump2Str( 'DB>> K_CMGetRunCount start' );
  DataSet := K_CMSpecAccessDBDataSet( 1 );
  if DataSet = nil then
  begin
    Result := -1;
    N_Dump1Str('DB>> K_CMGetRunCount ConnectionError' );
    Exit;
  end;

  try
    with DataSet do
    begin
        // Check Active Instances Table for other Active
      SQL.Text := 'select ' +
              K_CMENDBAAInstsTFActTS + ',' + K_CMENDBAAInstsTFActFlags +
              ' from ' + K_CMENDBAAInstsTable;

      Filtered := false;
      Open;
      Result := 0;
      CDTime := Now();
      First;
      while not Eof do
      begin
        if not K_CMDBCheckAppInstanceLostRecord( DataSet, 0, 1, CDTime ) then  // Active CMS
          Inc(Result);
        Next;
      end;
      Close;
      N_Dump2Str( 'DB>> K_CMGetRunCount RC=' + IntToStr(Result) );
    end;
  except
    on E: Exception do begin
      Result := -1;
      N_Dump1Str( 'K_CMGetRunCount >> ' + E.Message );
    end;
  end;
end; // function K_CMGetSecadmLicount



//************************************** K_CMClearFlipFlagsInOneProfilesSet ***
// Clear Flip Flags in One Profiles Set given by Binary Context Root
//
//     Parameters
// AUDContextRoot - Binary Context Root
// Result         - Returns TRUE if Profiles Set is really changed
//
function K_CMClearFlipFlagsInOneProfilesSet( AUDContextRoot : TN_UDBase ) : Boolean;
var
  UDProfilesRoot : TK_UDRArray;
  PCMDeviceProfile: TK_PCMDeviceProfile;
  i, n, k, j : Integer;
begin
  Result := FALSE;
  UDProfilesRoot := TK_UDRArray(AUDContextRoot.GetObjByRPath( 'DeviceProfiles\OtherProfiles' ));
  if UDProfilesRoot = nil then Exit;

  N_Dump2Str( 'Clear Flip flags start' );

  n := UDProfilesRoot.ALength;
  k := 0;
  j := 0;
  if n > 0 then
  for i := 0 to UDProfilesRoot.AHigh do
  begin
    PCMDeviceProfile := UDProfilesRoot.PDE(i);
    with PCMDeviceProfile^ do
    begin
      if CMDPGroupName <> N_CMECD_Duerr_Name then Continue;
      Inc(k);
      if CMAutoImgProcAttrs.CMAIPFlags * [K_aipfFlipHor,K_aipfFlipVert] <> [] then
      begin
        Inc(j);
        CMAutoImgProcAttrs.CMAIPFlags := CMAutoImgProcAttrs.CMAIPFlags - [K_aipfFlipHor,K_aipfFlipVert];
        N_Dump1Str( format( 'Clear Flip flags in %s ', [CMDPCaption] ) );
      end;
    end;
  end;
  Result := j > 0;
//  N_Dump1Str( format( 'Clear Flip flags fin >> %d Duerr of %d set profiles were found, %d were cleared', [k,n,j] ) );
  N_Dump1Str( format( 'Clear Flip flags fin >> %d of %d Duerr of %d All set profiles were cleared', [j,k,n] ) );
end; // function K_CMClearFlipFlagsInOneProfilesSet

//*********************** K_CMScanChangeVideoFileNameInSlideSerializedAttrs ***
// CMScan Set New Data Path
//
//    Parameters
// ASLideSerAttrs - Slide Serialized Attrs Text buffer
// ASizeInChars   - Slide Serialized Attrs size in chars
// ANewVideoPath  - Video Files new Path
// ACopyFileFlag  - Copy Video Files Flag
// Result         - Returns 0-bit=1 if name was really changed,
//                  1-bit=1 if copy or decompress error
//
function K_CMScanChangeVideoFileNameInSlideSerializedAttrs(
                            var ASLideAttrsBuf : string;
                            var ASizeInChars : Integer;
                            const ANewVideoPath : string;
                            ACopyFileFlag : Boolean ) : Integer;
var
  InfoPos : Integer;
  InfoPos1 : Integer;
  VideoFName, VideoFName1 : string;
  NameDelta : Integer;
begin
  InfoPos := Pos( 'MediaFExt=', ASLideAttrsBuf ) + 10;
  Result := 0;
  if ASLideAttrsBuf[InfoPos] = '"' then
  begin
    Inc(InfoPos);
    InfoPos1 := PosEx( '"', ASLideAttrsBuf, InfoPos )
  end
  else
    InfoPos1 := PosEx( ' ', ASLideAttrsBuf, InfoPos );

  // Change VideoFile Name and Replace it in Slide A-File
  VideoFName := Copy( ASLideAttrsBuf, InfoPos, InfoPos1 - InfoPos );
  VideoFName1 := ANewVideoPath + ExtractFileName(VideoFName);
  if VideoFName <> VideoFName1 then
  begin // Change File Name
    Result := 1;
    NameDelta := Length(VideoFName1) - Length(VideoFName);
    if NameDelta > 0 then
    begin
      if NameDelta + ASizeInChars > Length(ASLideAttrsBuf) then
        SetLength( ASLideAttrsBuf, NameDelta + ASizeInChars );
      Move( ASLideAttrsBuf[InfoPos1], ASLideAttrsBuf[InfoPos1 + NameDelta],
                                             ASizeInChars - InfoPos1 + 1 );
      Move( VideoFName1[1], ASLideAttrsBuf[InfoPos], Length(VideoFName1) );
    end   // if NameDelta > 0 then
    else
    begin // if NameDelta <= 0 then
      Move( VideoFName1[1], ASLideAttrsBuf[InfoPos], Length(VideoFName1) );
      if NameDelta < 0 then
        Move( ASLideAttrsBuf[InfoPos1], ASLideAttrsBuf[InfoPos1 + NameDelta],
                                                ASizeInChars - InfoPos1 + 1 );
    end; // if NameDelta <= 0 then

    ASizeInChars := ASizeInChars + NameDelta;
  end; // if VideoFName <> VideoFName1 then

  if not ACopyFileFlag then
  begin
    if Result = 1 then
      N_Dump1Str( format( '!!!Replace Video FileName %s >> %s', [VideoFName, VideoFName1] ) )
  end
  else  // if ACopyFileFlag then
  if not K_CMScanDecompressOrCopyTasksFile( VideoFName, VideoFName1,
                            'ChangeVideoFileName', 'Video' ) then
    Result := Result + 2;

end; // K_CMScanChangeVideoFileNameInSlideSerializedAttrs

//************************************************** K_CMScanGetCurDataPath ***
// Get Current Scan Data Path
//
// AddClientNameFlag - AddClientName
//
function K_CMScanGetCurDataPath( ) : string;
begin
  Result := '';
  if (K_CMScanClientName = '') then Exit;
  if (K_CMScanDataPath <> '') then
    Result := K_CMScanDataPath
  else
  if K_CMScanDataPathOnClientPCAuto and
     (K_CMScanDataPathAuto <> '') then
    Result := K_CMScanDataPathAuto;
end; // function K_CMScanGetCurDataPath

//********************************************* K_CMScanDecompressOrCopyTasksFile ***
// CMScan Set New Data Path
//
//    Parameters
// ASFName - compressed file name
// ARFName - decompressed file name
// ADumpPref  - dump prefix
// ADumpInfo  - dump file info
// Result         - Returns FALSE on decopress error
//
function K_CMScanDecompressOrCopyTasksFile( const ASFName, ARFName,
                                      ADumpPref, ADumpInfo : string ) : Boolean;
var
  CopyRes : Integer;
  ASFZName : string;
  FSize : array [0..1] of Integer;
begin
  Result := TRUE;
  ASFZName := ASFName + '.z';
  if FileExists( ASFZName ) then
  begin // Decompress File
    if K_vfcrOK <> K_VFCopyFile1( ASFZName, ARFName,
                                  [K_vfcDecompressSrc,K_vfcOverwriteNewer],@FSize[0] ) then
    begin
      N_Dump1Str( format( '%s >> Decompress %s Error %s',
                         [ADumpPref,ADumpInfo,ASFZName] ) );
      Result := FALSE;
    end
    else
    begin
      N_Dump2Str( format( '%s >> Decompress %s from %s (%d) to %s (%d)',
                         [ADumpPref,ADumpInfo,ASFZName,FSize[0],ARFName,FSize[1]] ) );
    end;
    K_DeleteFile( ASFZName );
  end
  else
  if ASFName <> ARFName then
  begin // Copy File
    CopyRes := K_CopyFile( ASFName, ARFName );
    if CopyRes = 0 then
      N_Dump1Str( format( '%s Copy %s from %s to %s', [ADumpPref,ADumpInfo,ASFName,ARFName] ) )
    else
    if CopyRes >= 4 then
    begin
      Result := FALSE;
      N_Dump1Str( format( '%s Copy %s ErrorCode=%d >> from %s to %s',
                         [ADumpPref,ADumpInfo,CopyRes,ASFName,ARFName] ) );
    end;
  end;
end; // function K_CMScanDecompressOrCopyTasksFile

//********************************************** K_CMScanProcessClientTasks ***
// Process CMScan Client Tasks before onECacheCheck
//
procedure K_CMScanProcessClientTasks();
var
  i, j, AFilesCount : Integer;
  CurSFile, CurRFile, ClientRootPath, SlideFName, ECachePath : string;
  SL : TStringList;
  CurTaskFolder: string;       // Task Folder name
  FSCount : Integer;
  TranspFileName : string;
  CurSlideAFName : string;
  DFile: TK_DFile;
  DSize : Integer;
  InfoPos : Integer;
  VideoFName, VideoFName1 : string;
  TaskState : string;
  CopyRes, ImgFNameInd, ImgFNameInd1 : Integer;
  CurScanDataPath : string;

Label RemoveTask;
begin

  // Check if CMScan Data process is needed - Precaution
  CurScanDataPath  := K_CMScanGetCurDataPath();
//  if (K_CMScanClientName = '') or
//     (K_CMScanDataPath = '') then Exit;
  if CurScanDataPath = '' then Exit;

// Change algorithm if K_CMScanClientBaseDataPathFlag is needed

  // Check if Transport to New path mode is doing by CMScan - Precaution
  N_Dump1Str( 'K_CMScanProcessClientTasks start ClientBased=' +
                                       N_B2S(K_CMScanDataPathOnClientPC) );
//  TranspFileName := K_CMScanDataPath + K_CMScanClientName + '.~';
  TranspFileName := CurScanDataPath + K_CMScanClientName + '.~';
  if FileExists( TranspFileName ) then
  begin
  // Precaution
    N_Dump1Str( 'K_CMScanProcessClientTasks >> Switch to new path is in process' );
    Exit;
  end;


  // Check if CMScan Data Folder exists - Precaution
//  ClientRootPath := K_CMScanDataPath + K_CMScanClientName + '\';
  ClientRootPath := CurScanDataPath + K_CMScanClientName + '\';
  if not DirectoryExists( ClientRootPath ) then
  begin
  // Precaution
    N_Dump1Str( 'K_CMScanProcessClientTasks >> Absent Client Root Folder =' + ClientRootPath  );
    Exit;
  end;

  K_CMEDAccess.TmpStrings.Clear;
  K_ScanFilesTree( ClientRootPath, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'S???????????????.txt' );
  SL := TStringList.Create;
  SL.Sorted := FALSE;
  SL.Assign( K_CMEDAccess.TmpStrings );
  SL.Sort();

//  ECachePath := K_ExpandFileName( '(#CMECacheFiles#)' );
  ECachePath := K_CMGetECacheFilesPath();

  for i := 0 to SL.Count - 1 do
  begin
  // Scan Tasks Loop
    CurSFile := ClientRootPath + SL[i];
    K_CMEDAccess.TmpStrings.Clear;
    N_Dump1Str( 'K_CMScanProcessClientTasks >> Start Task process S-File=' + CurSFile  );
    if not K_VFLoadStrings ( K_CMEDAccess.TmpStrings, CurSFile ) then
    begin
      N_Dump1Str( 'K_CMScanProcessClientTasks >> Load S-File Error =' + CurSFile  );
      Continue;
    end;

    TaskState := K_CMEDAccess.TmpStrings.Values['IsTerm'];
    if N_S2B( TaskState ) then Continue;

    if TaskState = K_CMScanTaskIsStopped then
    begin // Set Terminated State to Stopped Task
      K_CMEDAccess.TmpStrings.Values['IsTerm'] := 'FALSE';
      if not K_VFSaveStrings( K_CMEDAccess.TmpStrings, CurSFile, K_DFCreatePlain ) then
      begin
        N_Dump1Str( 'K_CMScanProcessClientTasks >> Rebuild S-File Error >> ' + CurSFile  );
        Continue;
      end;
    end;

    CurRFile := CurSFile;
    CurRFile[Length(CurRFile) - 19] := 'R'; // Syymmddhhnnsszzz.txt >> Ryymmddhhnnsszzz.txt
    if not FileExists( CurRFile ) then
    begin
      N_Dump1Str( 'K_CMScanProcessClientTasks >> R-File is absent >> ' + CurRFile  );
      goto RemoveTask;
    end;

    CurTaskFolder := CurRFile;
    CurTaskFolder[Length(CurTaskFolder) - 19] := 'F';
    CurTaskFolder := ChangeFileExt( CurTaskFolder, '' ) + '\';

    K_CMEDAccess.TmpStrings.Clear;
    if not K_VFLoadStrings ( K_CMEDAccess.TmpStrings, CurRFile ) then
    begin
      N_Dump1Str( 'K_CMScanProcessClientTasks >> Load R-File Error >> ' + CurRFile  );
      Continue;
    end;
    if K_CMEDAccess.TmpStrings.Values['IsDone'] <> 'TRUE' then Continue;

    if K_CMScanDataPathOnClientPC then goto RemoveTask; // Skip Restore Restore Scan Results to EmCache

    FSCount := StrToIntDef(K_CMEDAccess.TmpStrings.Values['ScanCount'], 0);
    if FSCount > 0 then
    begin // Empty Task
    // Move FSCount Slides to ECache
      K_CMEDAccess.TmpStrings.Clear;
      K_ScanFilesTree( CurTaskFolder, K_CMEDAccess.EDAScanFilesTreeSelectFile, 'F*_*_*_*_A.ecd' );
      N_Dump1Str( format( 'K_CMScanProcessClientTasks >> Process Task Slide Files T=%d F=%d', [FSCount, K_CMEDAccess.TmpStrings.Count] )  );
      AFilesCount := Min( K_CMEDAccess.TmpStrings.Count, FSCount );
      for j := 0 to AFilesCount - 1 do
      begin
        SlideFName := K_CMEDAccess.TmpStrings[j];
        N_Dump1Str( 'K_CMScanProcessClientTasks >> Process Slide File=' + SlideFName  );
        CurSlideAFName := CurTaskFolder + SlideFName;
        if not K_DFOpen( CurSlideAFName, DFile, [K_dfoProtected] ) then
        begin
          N_Dump1Str( format( 'K_CMScanProcessClientTasks >> Open Slide File error="%s" File=%s',
                      [K_DFGetErrorString(DFile.DFErrorCode),CurSlideAFName] ) );
          Continue;
        end;

        DSize := DFile.DFPlainDataSize;
        if SizeOf(Char) = 2 then
          DSize := DSize shr 1;
        if Length(K_CMEDAccess.StrTextBuf) < DSize then
          SetLength( K_CMEDAccess.StrTextBuf, DSize );
        if not K_DFReadAll( @K_CMEDAccess.StrTextBuf[1], DFile ) then
        begin
          N_Dump1Str( format( 'K_CMScanProcessClientTasks >> Read Slide File error="%s" File=%s',
                      [K_DFGetErrorString(DFile.DFErrorCode),CurSlideAFName] ) );
          Exit;
        end;

        InfoPos := Pos( 'cmsfIsMediaObj', K_CMEDAccess.StrTextBuf );
        if InfoPos > 0 then
        begin  // Copy Video to ECache and Change VideoFile Path
          if 2 <= K_CMScanChangeVideoFileNameInSlideSerializedAttrs( K_CMEDAccess.StrTextBuf,
                                               DSize, ECachePath, TRUE ) then
          begin
            N_Dump1Str( 'K_CMScanProcessClientTasks >> Video File Error' );
            Exit;
          end;

          // Save Slide A-File to ECache
          K_DFWriteAll( ECachePath + SlideFName, K_DFCreateProtected,
                        @K_CMEDAccess.StrTextBuf[1], DSize * SizeOf(Char) );
          N_Dump1Str( format( 'K_CMScanProcessClientTasks >> Copy Video %s >> %s', [VideoFName, VideoFName1] ) );
        end   // Copy Video to ECache and Change VideoFile Path
        else
        begin // Copy Image to ECache

        // Copy Slide Image File
          ImgFNameInd := Length(CurSlideAFName);
          CurSlideAFName[ImgFNameInd - 4] := 'R';

          SlideFName := ECachePath + SlideFName;
          ImgFNameInd1 := Length(SlideFName);
          SlideFName[ImgFNameInd1 - 4] := 'R';

          if not K_CMScanDecompressOrCopyTasksFile( CurSlideAFName, SlideFName,
                            'K_CMScanProcessClientTasks', 'CurImg' ) then
            Exit;

        // Try to copy Slide Original Image File
          CurSlideAFName[ImgFNameInd - 4] := 'S';
          SlideFName[ImgFNameInd1 - 4] := 'S';
          if not K_CMScanDecompressOrCopyTasksFile( CurSlideAFName, SlideFName,
                            'K_CMScanProcessClientTasks', 'SrcImg' ) then
            Exit;

        // Copy Slide A-file
          CurSlideAFName[ImgFNameInd - 4] := 'S';
          SlideFName[ImgFNameInd1 - 4] := 'A';
          CopyRes := K_CopyFile( CurSlideAFName, SlideFName );
          if CopyRes >= 3 then
          begin
            N_Dump1Str( format( 'K_CMScanProcessClientTasks >> Copy Slide File error="%d" File=%s',
                       [CopyRes,CurSlideAFName] ) );
            Exit;
          end;
        end; // Copy Image to ECache
      end; // for j := 0 to AFilesCount - 1 do
    end; // if FSCount > 0 then // empty Task

RemoveTask:
    // Remove Task;
    N_Dump1Str( 'K_CMScanProcessClientTasks RemoveTask S-file=' + ExtractFileName(CurSFile) );
    K_DeleteFolderFiles( CurTaskFolder );
    RemoveDir( CurTaskFolder );
    K_DeleteFile( CurRFile );
    K_DeleteFile( CurSFile );

  end; // for i := 0 to SL.Count - 1 do

  if K_CMScanDataPathOnClientPC then
  begin // Clear ScanData Local Folder
    K_DeleteFolderFiles( K_CMScanDataLocPath + K_CMScanClientName + '\' );
  end; // if K_CMScanClientBaseDataPathFlag then

  SL.Free;
  N_Dump2Str( 'K_CMScanProcessClientTasks fin' );

end; // procedure K_CMScanProcessClientTasks

//******************************************* K_CMScanRebuildCommonInfoFile ***
// CMScan Rebuild Common Info File
//
function K_CMScanRebuildCommonInfoFile( ) : Boolean;
var
  i: Integer;
  FInfoName : string;
  ScanDataPath : string;
begin
  Result := FALSE;
  ScanDataPath := K_CMScanGetCurDataPath();
  if ScanDataPath = '' then Exit;

  FInfoName := ScanDataPath + K_CMScanCommonInfoFileName;
  N_Dump2Str( 'DB>> K_CMScanRebuildCommonInfoFile >> ' + FInfoName );

  ////////////////////////////////////////
  // Add MediaTypes for CMScan
  //
  // Add Media Types
  with K_CMEDAccess do
  begin
    TmpStrings.Clear;
    TmpStrings.Add( '[MediaTypes]' );
    for i := 0 to AllMediaTypes.Count - 1 do
    begin
      TmpStrings.Add( format( '%d=%s',
         [Integer(AllMediaTypes.Objects[i]),AllMediaTypes[i] ] ) );
    end;

    TmpStrings.Add( '' );
    TmpStrings.Add( '[Common]' );
    TmpStrings.Add( 'Skip16bitMode=' + N_B2S(K_CMSSkip16bitMode) );
    TmpStrings.Add( 'RImageType=' + IntToStr(K_CMSRImageType) );
    TmpStrings.Add( 'ScanDataVersion=' + IntToStr(K_CMScanDataVersion) );
    TmpStrings.Add( 'CMSBuildNumber=' + N_CMSVersion );

    // Needed to build Video File Name optimization (to skip Video Slide ECache A-file rebuild before saving after Processing Dlg)
    if not K_CMScanDataPathOnClientPC then
      TmpStrings.Add( 'ScanDataPath=' + K_CMScanDataPath )     // Server based path
    else
      TmpStrings.Add( 'ScanDataPath=' + K_CMScanDataLocPath ); // Client based path


    N_Dump2Str( ExtractFileName(FInfoName) + ':' );
    N_Dump2Strings( TmpStrings, 5);
    N_Dump2Str( '' );

    Result := K_VFSaveStrings( TmpStrings, FInfoName, K_DFCreatePlain );
    if not Result then
      N_Dump2Str( 'DB>> K_CMScanRebuildCommonInfoFile >> Error ' );
  end; // with K_CMEDAccess do

end; // function K_CMScanRebuildCommonInfoFile

//************************************************** K_CMScanSetNewDataPath ***
// CMScan Set New Data Path
//
//    Parameters
// ANewPath - new Scan Data Path
// ASkipRedirectPath - Skip Redirect Path Flag
// Result - Returns TRUE if new path is OK
//
function K_CMScanSetNewDataPath( ANewPath : string; ASkipRedirectPath : Boolean;
                                 APathWasChanged : Boolean  ) : Boolean;
begin
  Result := TRUE;
  if ANewPath <> '' then
  begin
    N_Dump1Str( format( 'Try K_CMScanSetNewDataPath "%s" >> "%s" ClientBase=%s',
                        [K_CMScanDataPath, ANewPath, N_B2S(K_CMScanDataPathOnClientPC) ] ) );
//    if DirectoryExists( K_CMScanDataPath ) then
    if not K_CMScanDataPathOnClientPC then
    begin
      N_T1.Start();
      Result := DirectoryExists( ANewPath );
      N_T1.Stop();
      if N_T1.DeltaCounter >= K_CMScanNetworkMaxDelay * N_CPUFrequency then
      begin
        N_Dump2Str( 'K_CMScanSetNewDataPath >> Too slow DirectoryExists, Delay=' + N_T1.ToStr() );
        Result := FALSE;
        Exit;
      end;

      if Result then
      begin
      // New ScanDataPath Folder exists - delete Redirect File in the new place (if exists)
  //      K_DeleteFile( K_CMScanDataPath + K_CMScanPathRedirectFileName )
        K_DeleteFile( ANewPath + K_CMScanPathRedirectFileName );
        N_Dump2Str( 'K_CMScanSetNewDataPath >> New Path Exists' );
      end
      else
      begin
      // Create new ScanDataPath Folder
        N_T1.Start();
        Result := K_ForceDirPath( ANewPath );
        N_T1.Stop();
        if not Result then Exit;
        if N_T1.DeltaCounter >= K_CMScanNetworkMaxDelay * N_CPUFrequency then
        begin
          N_Dump2Str( 'K_CMScanSetNewDataPath >> Too slow ForceDir, Delay=' + N_T1.ToStr() );
          Result := FALSE;
          Exit;
        end;
        N_Dump2Str( 'K_CMScanSetNewDataPath >> New Path Force OK' );
      end;

      if not ASkipRedirectPath and APathWasChanged then
      begin
        K_CMScanDataPathOld := K_CMScanDataPath
      end
      else
        K_CMScanDataPathOld := '';

      K_CMScanDataPath := ANewPath;
//      K_CMScanWasInstalled := K_CMScanIsInstalled;
      K_CMScanWasInstalled := TRUE; // is needed for fast K_CMScanDataPath check in EDASetActiveTimeStamp

      if K_CMScanDataPathOld <> '' then
      begin
        // Create Redirect File in the old ScanDataPath Folder
        K_CMEDAccess.TmpStrings.Text := K_CMScanDataPath;
        K_VFSaveStrings( K_CMEDAccess.TmpStrings,
                         K_CMScanDataPathOld + K_CMScanPathRedirectFileName,
                         K_DFCreatePlain );
      end;

      // Save CommonInfoFile in new exchange folder
      K_CMScanRebuildCommonInfoFile();
    end   // if not K_CMScanDataPathOnClientPC then
    else
    begin // if K_CMScanDataPathOnClientPC then
      K_CMScanDataPath := ANewPath;
      K_CMScanDataPathOld := '';
      K_CMScanWasInstalled := TRUE; // is needed for fast check in EDASetActiveTimeStamp
      K_CMScanDataPathLost := TRUE; // is needed for fast check in EDASetActiveTimeStamp if_CMScanDataPathOnClientPCAuto = TRUE
//      K_CMScanWasInstalled := K_CMScanIsInstalled; // is needed for fast K_CMScanDataPath check in EDASetActiveTimeStamp
    end;
  end   // if ANewPath <> '' then
  else
  begin // if ANewPath '' then
    K_CMScanDataPath := '';
    K_CMScanDataPathOld := '';
    K_CMScanWasInstalled := FALSE;
    if K_CMScanDataPathOnClientPCAuto then
    begin // Scan Data Path is on client PC and should be auto detected
      K_CMScanDataPathAuto := '';  // Auto detected Client PC CMScan Exchange Folder
      K_CMScanDataPathAutoSInd := 0;  // Auto detected Client PC CMScan Exchange Folder Search Index
      N_Dump1Str( 'K_CMScanSetNewDataPath ScanDataPath is on Client PC, Auto Detect' );
    end   // if K_CMScanDataPathOnClientPCAuto then
    else
    begin // Clear Client Scan Data Mode
      N_Dump1Str( 'K_CMScanSetNewDataPath Clear ScanDataPath' );
    end;
  end; // if ANewPath '' then
  K_CMScanIsInstalled := FALSE;
end; // procedure K_CMScanSetNewDataPath

//****************************************************** K_CMScanRemoveTask ***
// Remove current task files
//
//    Parameters
// ADumpPrfix     - DumpPrefix
// ATaskSFileName - Task S-File Name
// ATaskRFileName - Task R-File Name
// ATaskRFolderName - Task Results Folder Name
// Result - Returns TRUE if all Task Files are removed
//
function K_CMScanRemoveTask( const ADumpPrfix, ATaskSFileName, ATaskRFileName,
                             ATaskRFolderName : string; AWrkStrings : TStrings;
                             AT1:  TN_CPUTimer1;
                             ADump1, ADump2 : TN_OneStrProcObj ) : Boolean;
var
  RemoveRes : string;
begin
  ADump1( ADumpPrfix + ' RemoveTask >> start S-file=' + ExtractFileName(ATaskSFileName) );
  Result := TRUE;
  AT1.Start();
  RemoveRes := '';
  if DirectoryExists( ATaskRFolderName ) then
  begin
    AWrkStrings.Clear;
    K_DeleteFolderFilesEx( ATaskRFolderName, AWrkStrings );
    Result := AWrkStrings.Count = 0;
    if not Result then
      ADump1( ADumpPrfix + ' RemoveTask >> Result Files Delete Errors:'#13#10 + AWrkStrings.Text )
    else
    begin
      Result := RemoveDir( ATaskRFolderName );
      if not Result then
        ADump1( ADumpPrfix + ' RemoveTask >> Results Folder Remove Error >> ' + ATaskRFolderName );
    end;
    if Result then RemoveRes := 'D';
  end;

  if Result then
  begin
    if FileExists( ATaskRFileName ) then
    begin
      Result := K_DeleteFile( ATaskRFileName, [K_dofSkipStoreUndelNames] );
      if Result then RemoveRes := RemoveRes + '+R';
    end;

    if not Result then
      ADump1( ADumpPrfix + ' RemoveTask >> R-file Delete Error ' + ATaskRFileName )
    else
    begin
      if FileExists( ATaskSFileName ) then
      begin
        Result := K_DeleteFile( ATaskSFileName, [K_dofSkipStoreUndelNames] );
        if Result then RemoveRes := RemoveRes + '+S';
      end;
      if not Result then
        ADump1( ADumpPrfix + ' RemoveTask >> S-file Delete Error ' + ATaskSFileName )
    end;
  end;

  AT1.Stop();
  ADump2( format( ADumpPrfix + ' RemoveTask >> "%s" fin Time=%s Errors=%s S-file=%s',
                  [RemoveRes, AT1.ToStr(), N_B2S(not Result),ATaskSFileName] ) );

end; // procedure K_CMScanRemoveTask

//*********************************************** K_CMScanGetFileCopyReport ***
// Get file copy report
//
//     Parameters
// AFName - file name
// AFSize - file size
// ACPUTimer - CPU timer
//
function K_CMScanGetFileCopyReport( const AFName : string; AFSize : Integer;
                                    ACPUTimer : TN_CPUTimer1 ) : string;
begin
  Result :=  format( '%s Size=%d Time=%s Speed=%.3f KB/Sec',
                [AFName, AFSize, ACPUTimer.ToStr(),
                 AFSize / 1024 / ACPUTimer.DeltaCounter * N_CPUFrequency] )
end; // function  K_CMScanGetFileCopyReport

//********************************************* K_CMSaveLastInCurSlidesList ***
// Save last given Slides in Curren Slides List
//
//    Parameters
// ASlidesCount - number of last slides to save
//
function K_CMSaveLastInCurSlidesList( ASlidesCount : Integer ) : Integer;
var
  i : Integer;
  PUDCMSlide : TN_PUDCMSlide;
  UDSlide : TN_UDCMSlide;

begin
  N_Dump1Str( format( 'K_CMSaveLastInCurSlidesList  Count=%d', [ASlidesCount] ) );
  Result := ASlidesCount;
  with K_CMEDAccess, CurSlidesList do
  begin
    PUDCMSlide := TN_PUDCMSlide(@List[Count - Result]);

    if 0 = EDACheckFilesAccessBySlidesSet( PUDCMSlide, Result,
           K_CML1Form.LLLFileAccessCheck14.Caption + ' ' + K_CML1Form.LLLPressOkToClose.Caption
//             #13#10'Your objects will be saved in the temporary folder. Press OK to close Media Suite.'
            ) then
    begin
      EDASaveSlidesArray( PUDCMSlide, Result );
      EDASetPatientSlidesUpdateFlag();
    end
    else
    begin
     // Remove Slides From CurSlidesList
      for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
      begin
        UDSlide := TN_UDCMSlide(CurSlidesList[i]);
        N_Dump1Str( 'SSA>> Del from CurSet Slide ID=' + UDSlide.ObjName );
        K_CMDeleteClientMediaFile( UDSlide );

        CurSlidesList.Delete( i );
        UDSlide.UDDelete;
      end; // for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
      Result := 0;
      K_CMSkipSlidesSavingFlag := TRUE;
      K_CMCloseOnFinActionFlag := TRUE;
    end; // for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
  end; // with K_CMEDAccess, CurSlidesList do
end; // end of K_CMSaveLastInCurSlidesList

//*************************************** K_CMLimitDevUseTypeNameValidation ***
// Check if Device Profile Type Name Validation is Needed
//
//     Parameters
// Result - Returns TRUE if Device Profile Type Name Validation is Needed
//
function K_CMLimitDevUseTypeNameValidation() : Boolean;
begin
  Result := (K_CMSLiRegValidDevTypesList <> nil);
end; // K_CMLimitDevUseTypeNameValidation

//****************************************** K_CMLimitDevGetProfileTypeName ***
// Get Device Profile Type Name for Check Device Types Number
//
//     Parameters
// APDevProfile - pointer to device profile
// Result - Returns Device Type Name for Check Device Types Number
//
function K_CMLimitDevGetProfileTypeName( APDevProfile : Pointer ) : string;
begin
  with TK_PCMDeviceProfile(APDevProfile)^ do
  if CMDPGroupName = '' then // TWAIN
    Result := 'TW_' + CMDPProductName
  else                       // Other X-Ray
    Result := 'OT_' + K_CMCDGetDeviceObjByName( CMDPGroupName ).CDSName;

end; // K_CMLimitDevGetProfileTypeName

//******************************************** K_CMLimitDevValidateTypeName ***
// Validate Device Profile Type Name
//
//     Parameters
// APDevProfile - pointer to device profile
// Result - Returns TRUE if Device Type Name is Valid
//
function K_CMLimitDevValidateTypeName( APDevProfile : Pointer ) : Boolean;
var
  DevTypeName : string;
begin
//  Result := (K_CMSLiRegValidDevTypesList = nil) or (K_CMSLiRegValidDevTypesList.Count = 0);
//  if Result then Exit; // precaution
  DevTypeName := K_CMLimitDevGetProfileTypeName( APDevProfile );
  Result := K_CMSLiRegValidDevTypesList.IndexOf(DevTypeName) >= 0;
end; // K_CMLimitDevGetProfileTypeName

//***************************************** K_CMGetValidDevProfileTypeNames ***
// Get Valid Device Profile Type Names
//
//     Parameters
// AValidDPList - on result Valid Device Profile Type Names list
//
procedure K_CMGetValidDevProfileTypeNames( AValidDPList : TStrings );
begin
  N_Dump2Str('DB>> K_CMGetValidDevProfileTypeNames start');
  if (AValidDPList = nil)                  or
     not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 32) then Exit; // precaution

  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    with CurDSet1 do
    begin
      Connection := LANDBConnection;
      ExtDataErrorCode := K_eeDBSelect;

      // *** Select Active Instances Valid Type Names
      SQL.Text := 'select D.' + K_CMENDADPTName +
        ' from ' + K_CMENDBAllDevProfileTypesTable + ' D,' +
                   K_CMENDBActInstDevProfilesTable + ' V' +
        ' where V.' + K_CMENDAInstRTID + ' = ' + IntToStr(AppRTID) +
           ' and D.' + K_CMENDADPTDI + ' = V.' +  K_CMENDAInstDevTID;
      Filtered := false;
      Open;
      AValidDPList.Clear;
      while not EOF do
      begin
        AValidDPList.Add( K_CMEDAGetDBStringValue( Fields[0] ) );
        Next();
      end;
      Close;
      N_Dump2Strings( AValidDPList, 5 );
    end; // with CurDSet1 do
    N_Dump2Str('DB>> K_CMGetValidDevProfileTypeNames fin');
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMGetValidDevProfileTypeNames >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMGetValidDevProfileTypeNames

//*************************************** K_CMLimitDevProfilesToRTDBContext ***
// Set Device Profile Types Info to Runtime DB Context
//
//     Parameters
// Result - Returns Device Types Extra Limit number
//
function K_CMLimitDevProfilesToRTDBContext() : Integer;
var
  i, DevCount : Integer;
  UDDevices : TK_UDRArray;
  PCMDevProfListElem : TK_PCMDevProfListElem;
  PCMDeviceProfile : TK_PCMDeviceProfile;
  SQLStr : string;
begin
  N_Dump2Str('DB>> K_CMLimitDevProfilesToRTDBContext start');
  Result := 0;

  FreeAndNil( K_CMSLiRegValidDevTypesList ); // Clear Types Validation Context

  if (K_CMSLiRegDevLimit = 0)              or
     not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 32) then Exit; // precaution

  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    DevCount := ProfilesList.ALength();
    if DevCount = 0 then Exit; // Nothing to do
    //
    TmpStrings.Clear;
    for i := 0 to DevCount - 1 do
    begin
      PCMDevProfListElem := TK_PCMDevProfListElem(ProfilesList.PDE(i));
      UDDevices := TK_UDRArray(PCMDevProfListElem.CMDPLEARef);
      if (UDDevices = K_CMEDAccess.VideoProfiles) then Continue;

      PCMDeviceProfile := UDDevices.PDE(PCMDevProfListElem.CMDPLEAInd);
      TmpStrings.Add( '<profile TN="' +
                      K_CMLimitDevGetProfileTypeName( PCMDeviceProfile ) + '" />' );
    end; // for i := 0  to High(Inds) do

    if TmpStrings.Count = 0 then Exit; //

    SQLStr := '<profiles>' +
      Copy( StrTextBuf, 1, K_GetStringsToBuf( StrTextBuf, TmpStrings, 0, TmpStrings.Count, TRUE, Chr($0A) ) )
            + '</profiles>';

    N_Dump2Str('DB>> cms_ReplaceCurDevProfilesInfo XML:>> '#13#10 + SQLStr );

    with CurStoredProc1 do
    begin
      Connection := LANDBConnection;
      ProcedureName := 'dba.cms_ReplaceCurDevProfilesInfo';
      Parameters.Clear;
      with Parameters.AddParameter do
      begin // 0
        Name := '@AppRTID';
        Direction := pdInput;
        DataType := ftInteger;
        Value := AppRTID;
      end;
      with Parameters.AddParameter do
      begin  // 1
        Name := '@MaxDevCount';
        Direction := pdInput;
        DataType := ftInteger;
        Value := K_CMSLiRegDevLimit;
      end;
      with Parameters.AddParameter do
      begin  // 2
        Name := '@xml_data';
        Direction := pdInput;
        DataType := ftString;
        Value := N_StringToAnsi(SQLStr);
      end;
      with Parameters.AddParameter do
      begin  // 3
        Name := '@ExtraCount';
        Direction := pdOutput;
        DataType := ftInteger;
        Value := Result;
      end;
      ExecProc;
      Result := Parameters[3].Value;
    end; // with CurStoredProc1 do


    if Result > 0 then
    begin // Extra Limit Types are detected - Set Types Validation Context
      if K_CMSLiRegValidDevTypesList = nil then
        K_CMSLiRegValidDevTypesList := TStringList.Create();
      K_CMGetValidDevProfileTypeNames( K_CMSLiRegValidDevTypesList );
      N_Dump2Str( 'New Valid Device Type Names:' );
      N_Dump2Strings( K_CMSLiRegValidDevTypesList, 5 );
    end
    else
      FreeAndNil( K_CMSLiRegValidDevTypesList );

    N_Dump1Str('DB>> K_CMLimitDevProfilesToRTDBContext fin >> ExtraCount=' + IntToStr(Result) );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMLimitDevProfilesToRTDBContext >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMLimitDevProfilesToRTDBContext

//************************************* K_CMLimitDevNewProfileToRTDBContext ***
// Add New Device Profile Type to Runtime DB Context
//
//     Parameters
// APDevProfile - New Device Profile
// Result - Returns TRUE on success
//
function K_CMLimitDevNewProfileToRTDBContext( APDevProfile : Pointer ) : Boolean;
var
  SkipNewFlag : Integer;
  DevProfileTypeName : string;
begin
  N_Dump2Str('DB>> K_CMLimitDevNewProfileToRTDBContext start');
  Result := TRUE;
  if (K_CMSLiRegDevLimit = 0)              or
     not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 32) then Exit; // precaution

  DevProfileTypeName := K_CMLimitDevGetProfileTypeName( APDevProfile  );
  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    SkipNewFlag := 0;
    with CurStoredProc1 do
    begin
      Connection := LANDBConnection;
      ProcedureName := 'dba.cms_AddNewDevProfile';
      Parameters.Clear;
      with Parameters.AddParameter do
      begin // 0
        Name := '@AppRTID';
        Direction := pdInput;
        DataType := ftInteger;
        Value := AppRTID;
      end;
      with Parameters.AddParameter do
      begin  // 1
        Name := '@MaxDevCount';
        Direction := pdInput;
        DataType := ftInteger;
        Value := K_CMSLiRegDevLimit;
      end;
      with Parameters.AddParameter do
      begin  // 2
        Name := '@DevTypeName';
        Direction := pdInput;
        DataType := ftString;
        Value := N_StringToAnsi(DevProfileTypeName);
      end;
      with Parameters.AddParameter do
      begin  // 3
        Name := '@SkipNewFlag';
        Direction := pdOutput;
        DataType := ftInteger;
        Value := SkipNewFlag;
      end;
      ExecProc;
      SkipNewFlag := Parameters[3].Value;
      Result := SkipNewFlag = 0;
    end;

    // Add Type Name to Valid Type Names List if needed

    if Result then
    begin // Type is Valid - correct Types Validation Context if Exists
       if (K_CMSLiRegValidDevTypesList <> nil) and
          (K_CMSLiRegValidDevTypesList.IndexOf(DevProfileTypeName) < 0) then
       begin
         K_CMSLiRegValidDevTypesList.Add(DevProfileTypeName);
         N_Dump2Str( 'New Valid Device Type Names:' );
         N_Dump2Strings( K_CMSLiRegValidDevTypesList, 5 );
       end;
    end
    else  // if Result then
    begin // if not Result then
      if K_CMSLiRegValidDevTypesList = nil then
      begin // Extra Limit Type - Create Types Validation Context
        K_CMSLiRegValidDevTypesList := TStringList.Create();
        K_CMGetValidDevProfileTypeNames( K_CMSLiRegValidDevTypesList );
        N_Dump2Str( 'New Valid Device Type Names:' );
        N_Dump2Strings( K_CMSLiRegValidDevTypesList, 5 );
      end
    end;  // if not Result then

    N_Dump1Str( format( 'DB>> K_CMLimitDevNewProfileToRTDBContext fin >> %s Valid=%s',
                        [DevProfileTypeName, N_B2S(Result)] ) );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMLimitDevNewProfileToRTDBContext >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMLimitDevNewProfileToRTDBContext

//*********************************** K_CMLimitDevDelProfileFromRTDBContext ***
// Delete Device Profile Type from Runtime DB Context
//
procedure K_CMLimitDevDelProfileFromRTDBContext( APDevProfile : Pointer );
var
  DevProfileTypeName : string;
begin
  N_Dump2Str('DB>> K_CMLimitDevDelProfileFromRTDBContext start');
  if (K_CMSLiRegDevLimit = 0)              or
     not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 32) then Exit; // precaution

  DevProfileTypeName := K_CMLimitDevGetProfileTypeName( APDevProfile  );
  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    with CurStoredProc1 do
    begin
      Connection := LANDBConnection;
      ProcedureName := 'dba.cms_DeleteDevProfile';
      Parameters.Clear;
      with Parameters.AddParameter do
      begin // 0
        Name := '@AppRTID';
        Direction := pdInput;
        DataType := ftInteger;
        Value := AppRTID;
      end;
      with Parameters.AddParameter do
      begin  // 1
        Name := '@DevTypeName';
        Direction := pdInput;
        DataType := ftString;
        Value := N_StringToAnsi(DevProfileTypeName);
      end;
      ExecProc;
    end;

    if (K_CMSLiRegValidDevTypesList <> nil)  then
      K_CMLimitDevProfilesToRTDBContext(); // Rebuild Device Limitation Runtime DB Context

    N_Dump1Str('DB>> K_CMLimitDevDelProfileFromRTDBContext fin >> ' + DevProfileTypeName );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMLimitDevDelProfileFromRTDBContext >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMLimitDevDelProfileFromRTDBContext

//**************************************** K_CMLimitDevGetAllProfilesReport ***
// Get All Device Profiles Report
//
//     Parameters
// AReport - All Device Profiles Report strings
//
procedure K_CMLimitDevGetAllProfilesReport( AReport : TStrings );
var
  PCName, NewPCName, TypesInfo : string;
  RTID, NewRTID : Integer;
begin
  N_Dump2Str('DB>> K_CMLimitDevGetAllProfilesReport start');
  AReport.Clear();
  if not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 32) then Exit; // precaution

  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    with CurDSet1 do
    begin
      Connection := LANDBConnection;
      ExtDataErrorCode := K_eeDBSelect;

      // *** Select Active Instances Valid Type Names
      SQL.Text := 'select D.' + K_CMENDBGAInstsTFCName  + ',' +
                        ' V.' + K_CMENDADPTName  + ',' +
                        ' W.' + K_CMENDAInstRTID +
        ' from ' + K_CMENDBActInstDevProfilesTable + ' W,' +
                   K_CMENDBAllDevProfileTypesTable + ' V,' +
                   K_CMENDBAAInstsTable            + ' N,' +
                   K_CMENDBGAInstsTable            + ' D'  +
        ' where N.' + K_CMENDBAAInstsTFGlobID + ' = D.' + K_CMENDBGAInstsTFGlobID +
          ' and W.' + K_CMENDAInstRTID + ' = N.' +  K_CMENDBAAInstsTFActRTID +
          ' and V.' + K_CMENDADPTDI + ' = W.' +  K_CMENDAInstDevTID +
          ' order by W.' + K_CMENDAInstRTID +
                  ', D.' + K_CMENDBGAInstsTFCName;
//          ' order by D.' + K_CMENDBGAInstsTFCName;
      Filtered := false;
      Open;

      TypesInfo := '';
      RTID := 0;
      while not EOF do
      begin
        NewPCName := K_CMEDAGetDBStringValue( Fields[0] );
        NewRTID   := Fields[2].AsInteger;
//        if PCName <> NewPCName then
        if RTID <> NewRTID then
        begin
          PCName := NewPCName;
          RTID := NewRTID;
//          if Length(TypesInfo) > 0 then
//          if not SameText(TypesInfo,'') then
          if TypesInfo <> '' then
            AReport.Add( TypesInfo ); // Add previouse report string
          // Start New report string
          TypesInfo := NewPCName + ' - ' + K_CMEDAGetDBStringValue( Fields[1] );
        end
        else
          TypesInfo := TypesInfo + ', ' + K_CMEDAGetDBStringValue( Fields[1] );
        Next();
      end;

      AReport.Add( TypesInfo ); // Add last report string
      Close;

    end; // with CurDSet1 do
    N_Dump2Str('DB>> K_CMLimitDevGetAllProfilesReport fin');
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMLimitDevGetAllProfilesReport >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMLimitDevGetAllProfilesReport

//****************************************** K_CMDCMSlideStoreCommitmentAdd ***
// Add Slide Store Commitment to queue
//
//     Parameters
// ASecTimeShift - queue elment time shift in seconds
// ASlideID      - slide ID
// AInstUID      - slide DICOM SOPInstance UID
// AInstUID      - slide DICOM SOPClass UID
//
procedure K_CMDCMSlideStoreCommitmentAdd( ASecTimeShift, ASlideID : Integer; AInstUID, AClassUID : string  );
var
  Res : Integer;
begin
  N_Dump2Str('DB>> K_CMDCMSlideStoreCommitmentAdd start');

  if not (K_CMEDAccess is TK_CMEDDBAccess) or
     (K_CMEDDBVersion < 45) then Exit; // precaution

  with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
  try

    Connection := LANDBConnection;
    ProcedureName := 'dba.cms_AddToDCMComQueueTable';
    Parameters.Clear;
    with Parameters.AddParameter do
    begin // 0
      Name := '@ASecTimeShift';
      Direction := pdInput;
      DataType := ftInteger;
      Value := ASecTimeShift;
    end;
    with Parameters.AddParameter do
    begin  // 1
      Name := '@ASID';
      Direction := pdInput;
      DataType := ftInteger;
      Value := ASlideID;
    end;
    with Parameters.AddParameter do
    begin  // 2
      Name := '@AInstUID';
      Direction := pdInput;
      DataType := ftString;
      Value := N_StringToAnsi(AInstUID);
    end;
    with Parameters.AddParameter do
    begin  // 3
      Name := '@AClassUID';
      Direction := pdInput;
      DataType := ftString;
      Value := N_StringToAnsi(AClassUID);
    end;
    with Parameters.AddParameter do
    begin  // 4
      Name := '@AddFlag';
      Direction := pdOutput;
      DataType := ftInteger;
      ExecProc;
      Res := Value;
    end;

    N_Dump1Str('DB>> K_CMDCMSlideStoreCommitmentAdd fin >> ' + IntToStr( Res ) );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'K_CMDCMSlideStoreCommitmentAdd >> ' + E.Message;
      EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // K_CMDCMSlideStoreCommitmentAdd


//*********************************************************** K_CMImg3DCall ***
// Call CMS 3D Viewer
//
//     Parameters
// AResFolder    - folder with 3D Image files
// AImportFolder - folder to import 3D Image data
// Result - Returns resulting Code: 0 - OK, -1 - Load DLL problems, >0 3DV - error code
//
function K_CMImg3DCall( const ACMSFolder : string; const AImportFolder : string = '' ) : Integer;
var
  FImportFolderA, FCMSFolderA : AnsiString;
  FImportFolderW, FCMSFolderW : WideString;
  AName : AnsiString;
  WStr : string;
begin
{//debug}
//  if not N_CMResForm. aDebSkip3DViewCall.Checked then
  if N_CMResForm.aDebSkip3DViewCall.Checked then
  begin
    Result := 0;
    if mrYes <> K_CMShowMessageDlg( '3D viewer emulation, (Yes - OK result, No - Error result)', mtConfirmation ) then
      Result := 9999;
    Exit;
  end;

  if not Assigned(K_CMImg3DCallFunc) and not Assigned(K_CMImg3DCallFuncW) then
  begin
    if K_CMImg3DDllHandle = 0 then
    begin
      K_CMImg3DDllHandle := Windows.LoadLibrary( @K_CMImg3DDLLName[1] );
      N_Dump1Str( Format( '3D> After Windows.LoadLibrary %s, ILDllHandle=%X', [K_CMImg3DDLLName,K_CMImg3DDllHandle] ) );

      if K_CMImg3DDllHandle = 0 then // some error
      begin
        Result := -1; // Windows.LoadLibrary failed
        K_CMShowMessageDlg( 'Error Loading ' + K_CMImg3DDLLName + ': ' + SysErrorMessage( GetLastError() ), mtError );
        Exit;
      end; // if ILDllHandle = 0 then // some error
    end; // if K_CMImg3DDllHandle = 0 then

    K_CMImg3DCallFuncW := GetProcAddress( K_CMImg3DDllHandle, @K_CMImg3DCallNameW[1] );
    K_CMImg3DCallFunc  := GetProcAddress( K_CMImg3DDllHandle, @K_CMImg3DCallNameA[1] );
    AName := K_CMImg3DCallNameA;
    if not Assigned(K_CMImg3DCallFunc) then
    begin
      K_CMImg3DCallFunc := GetProcAddress( K_CMImg3DDllHandle, @K_CMImg3DCallName[1] );
      AName := K_CMImg3DCallName;
    end;
    N_Dump1Str( format( '3D> DLL Entries %s=%s %s=%s',
                [K_CMImg3DCallNameW,N_B2S(Assigned(K_CMImg3DCallFuncW)),
                 AName,N_B2S(Assigned(K_CMImg3DCallFunc))] ) );
    if not Assigned(K_CMImg3DCallFuncW) and not Assigned(K_CMImg3DCallFunc) then
    begin
      Result := -2; // needed entry is not found
      N_Dump1Str( '3D> DLL Entries are not found' );
      K_CMShowMessageDlg( 'Error using ' + K_CMImg3DDLLName, mtError );
      Exit;
    end; // if not Assigned(K_CMImg3DCallFunc) then
  end; // if not Assigned(K_CMImg3DCallFunc) then
{}//debug

  WStr := '3D> call folders:'#13#10'     ' + ACMSFolder;
  if AImportFolder <> '' then
    WStr := WStr + #13#10'     ' + AImportFolder;
  N_Dump1Str( WStr );

  if Assigned(K_CMImg3DCallFuncW) then
  begin
    FImportFolderW := '';
    if AImportFolder <> '' then
      FImportFolderW := N_StringToWide( ExcludeTrailingPathDelimiter(AImportFolder) );

    FCMSFolderW := N_StringToWide( ExcludeTrailingPathDelimiter(ACMSFolder) );

    Result := K_CMImg3DCallFuncW( PWideChar(FCMSFolderW), PWideChar(FImportFolderW) );
  end
  else
  begin
    FImportFolderA := '';
    if AImportFolder <> '' then
      FImportFolderA := N_StringToAnsi( ExcludeTrailingPathDelimiter(AImportFolder) );

    FCMSFolderA := N_StringToAnsi( ExcludeTrailingPathDelimiter(ACMSFolder) );

    Result := K_CMImg3DCallFunc( PAnsiChar(FCMSFolderA), PAnsiChar(FImportFolderA) );
  end;
  N_Dump1Str( '3D> Viewer ResCode=' + IntToStr(Result) );

{//debug
Result := 0;
// Create 3D Image Resulting Data
K_CopyFolderFiles( 'C:\Delphi_prj_new\DTmp\!3DTest\', AResFolder + K_CMS3DImgResFolder );
{}//debug

end; // function K_CMImg3DCall

//************************************************* K_CMImg3DViewsFListPrep ***
// Prepare 3D Image Views files list
//
//     Parameters
// A3DSlide - 3D Slide ID to Import 2D views
// ASlideBasePath - base path to Import 2D views
// Result - Returns number of imported views
//
procedure K_CMImg3DViewsFListPrep( AFilesList : TStrings;
                   const A3DSlideID, ASlideBasePath : string );
var
  F: TSearchRec;
  ResPath : string;
begin
  // Prepare 2D views files List
  ResPath := ASlideBasePath + K_CMS3DImgResFolder;
  N_Dump2Str( 'K_CMImg3DViewsFListPrep start from ' + ResPath );
  AFilesList.Clear;
  if FindFirst( ResPath + '*.png', faAnyFile, F ) = 0 then
    repeat
      if (F.Name[1] = '.') or
         ((F.Attr and faDirectory) <> 0) or
         SameText( F.Name, K_CMS3DImgResThumbFile ) then Continue;
      AFilesList.Add( F.Name );
    until FindNext( F ) <> 0;

  FindClose( F );
  N_Dump2Str( 'K_CMImg3DViewsFListPrep fin Count=' + IntToStr(AFilesList.Count) );

end; // procedure K_CMImg3DViewsFListPrep

//*****************************************************************************
// 3D Annotations Import context
//
var
  K_3DAMLineDTCode : Integer;
  K_3DAAngleDTCode : Integer;
  K_3DATextDTCode  : Integer;
  K_3DASL, K_3DAML1, K_3DAML2, K_3DAML3, K_3DAML4 : TStringList;
  K_3DAUDRoot : TN_UDBase;

//********************************************* K_CMImg3DViewAnnotsContPrep ***
// 3D Image View Annotations prepare context
//
procedure K_CMImg3DViewAnnotsContPrep( );
begin
  if K_3DASL <> nil then Exit;
  K_3DASL := TStringList.Create;

  K_3DAML1 := TStringList.Create;
  K_3DAML1.Add( 'MLine=<TK_3DMLine ImgInd=14 ElemCount=1 ' );
  K_3DAML1.Add( 'MLine=<TK_3DMLine ImgInd=14 ElemCount=1 ' );
  K_3DAML1.Add( 'Angle=<TK_3DAngle ImgInd=14 ElemCount=1 ' );
  K_3DAML1.Add( 'Text=<TK_3DText ImgInd=14 ElemCount=1 ' );

  K_3DAML4 := TStringList.Create;
  K_3DAML4.Add( 'MLine=</TK_3DMLine>' );
  K_3DAML4.Add( 'Angle=</TK_3DAngle>' );
  K_3DAML4.Add( 'LCoords= </LCoords>' );
  K_3DAML4.Add( 'ACoords= </ACoords>' );

  K_3DAML2 := TStringList.Create;
  K_3DAML2.Add( 'LCoords=<LCoords TypeName=TFPoint ElemCount=2 CompactArray=1 >' );
  K_3DAML2.Add( 'ACoords=<ACoords TypeName=TFPoint ElemCount=3 CompactArray=1 >' );

  K_3DAML3 := TStringList.Create;
  K_3DAML3.Add( 'quot="' );

  K_3DAUDRoot := TN_UDBase.Create;

  K_3DAMLineDTCode := K_GetTypeCode( 'TK_3DMLine' ).DTCode;
  K_3DAAngleDTCode := K_GetTypeCode( 'TK_3DAngle' ).DTCode;
  K_3DATextDTCode  := K_GetTypeCode( 'TK_3DText' ).DTCode;

end; // procedure K_CMImg3DViewAnnotsContPrep

//********************************************* K_CMImg3DViewAnnotsContFree ***
// 3D Image View Annotations free context
//
procedure K_CMImg3DViewAnnotsContFree( );
begin
  FreeAndNil(K_3DASL);
  FreeAndNil(K_3DAML1);
  FreeAndNil(K_3DAML2);
  FreeAndNil(K_3DAML3);
  FreeAndNil(K_3DAML4);
  K_3DAUDRoot.UDDelete();
  K_3DAUDRoot := nil;
end; // procedure K_CMImg3DViewAnnotsContFree

//*********************************************** K_CMImg3DViewAnnotsImport ***
// 3D Image View Annotations import
//
//     Parameters
//
procedure K_CMImg3DViewAnnotsImport( AUDSlide : TN_UDCMSlide; AFName : string;
                                     APixPermm : Float );
type TK_3DMLine = packed record
  LineColor : Integer;
  LineWidth : Integer;
  Coords : TK_RArray// ArrayOf TFPoint;
end;
type TK_P3DMLine = ^TK_3DMLine;

type TK_3DAngle = TK_3DMLine;

type TK_3DFontStyle  = Set of (
  K_3DFSBold,
  K_3DFSItalic,
  K_3DFSUnderline,
  K_3DFSStrike
);

type TK_3DText = packed record
  BasePoint : TFPoint;
  TextColor : Integer; // Color;
  FontPixSize : Integer;
  FontFace  : string;
  FontStyle : TK_3DFontStyle;
  Value : string;
end;
TK_P3DMText = ^TK_3DText;

var
  WStr : string;
  j, n, WInt : Integer;
  UDAnnot : TK_UDRArray;
  TextComp      : TN_UDParaBox;
  PUPar         : TN_POneUserParam;
  POneTextBlock : TN_POneTextBlock;
  VObjCompRoot  : TN_UDCompVis;
  LineComp      : TN_UDPolyline;
  PCoord : PFloat;
  PPoint, PPoint2 : PFPoint;
  ArcComp : TN_UDArc;
  CurColor : Integer;
  FPoint : TFPoint;

begin

  WStr := K_VFLoadStrings1( AFName, K_3DASL, WInt );
  if WStr <> '' then
  begin
    N_Dump1Str( format( '3DViewAnnotsImport >> Annot File read error >> %s >> %s ', [AFName,WStr] ) );
    Exit;
  end;

  N_Dump2Str( format( '3DViewAnnotsImport >> from file >> %s :'#13#10'%s', [AFName,K_3DASL.Text] ) );

  // Conv text to proper SDT
  K_SListMListReplace( K_3DASL, K_3DAML1, K_ummSaveMacro, '<', ' ' );
  K_SListMListReplace( K_3DASL, K_3DAML4, K_ummSaveMacro, '</', '>' );
  K_SListMListReplace( K_3DASL, K_3DAML2, K_ummSaveMacro, '<', '>' );

  N_Dump2Str( format( '3DViewAnnotsImport >> conv to SDT:'#13#10'%s', [K_3DASL.Text] ) );

//  K_3DASL.Text := K_StringMListReplace( K_3DASL.Text, K_3DAML1, K_ummSaveMacro, nil, '<', ' ' );
//  K_3DASL.Text := K_StringMListReplace( K_3DASL.Text, K_3DAML4, K_ummSaveMacro, nil, '</', '>' );
//  K_3DASL.Text := K_StringMListReplace( K_3DASL.Text, K_3DAML2, K_ummSaveMacro, nil, '<', '>' );
  K_3DASL.Add(
'<DFI CurF=20071229 NDPT=20071229 ArrLength=4>'#13#10+
'TK_3DMLine 20071229 20071229'#13#10+
'TK_3DAngle 20071229 20071229'#13#10+
'TK_3DFontStyle 20071229 20071229'#13#10+
'TK_3DText 20071229 20071229'#13#10+
'</DFI *S*P*L*>' );

  // Load SDT to binary
  K_SerialTextBuf.LoadFromText(K_3DASL.Text);
  K_LoadTreeFromText0(K_3DAUDRoot, K_SerialTextBuf, TRUE);
  K_3DASL.Clear;
  CurColor := 0;

  with AUDSlide.P.CMSDB do
  for j := 0 to K_3DAUDRoot.DirHigh do
  begin
    UDAnnot := TK_UDRArray(K_3DAUDRoot.DirChild(j));
    VObjCompRoot := nil;
    with UDAnnot,PDRA^ do
    begin
      if FEType.DTCode = K_3DAMLineDTCode then
      begin // Import MLine
        N_Dump2Str( '3DViewAnnotsImport >> Line' );
        VObjCompRoot := AUDSlide.AddNewMeasurement('MLine');
        LineComp := TN_UDPolyline(VObjCompRoot.DirChild(1));
        TextComp := TN_UDParaBox(VObjCompRoot.DirChild(2));

        with TK_P3DMLine(P)^, Coords do
        begin
          // Import Line Coords
          PCoord := LineComp.PSP.CPolyline.CPCoords.P();
          Pointer(PPoint) := PCoord;
          move( P()^, PCoord^, SizeOf(TFPoint) * 2 );
          for n := 0 to 2 * 2 - 1 do
          begin
            PCoord^ := PCoord^ + 100;
            Inc(PCoord);
          end;

          // Line Color
          CurColor := LineColor;

          // Line Width
          PUPar := K_CMGetVObjPAttr( VObjCompRoot, 'LineWidth' );
          PFloat(PUPar.UPValue.P)^ := LineWidth;

          // Set Line Length Text
          AUDSlide.RebuildMLineTexts(VObjCompRoot);

          // Set Line Length Text Box
          with TextComp.PSP^, CCompBase, CCoords.BPCoords do
          begin
            CBSkipSelf := 0;

            X := PPoint.X;
            Y := PPoint.Y;
            Inc(PPoint);
            X := (X + PPoint.X) / 2 + 1;
            Y := (Y + PPoint.Y) / 2 + 1;
          end; // with TextComp.PSP^, CCoords.BPCoords do

          K_CMVobjSetFontSizeAuto( TextComp, PixHeight );
        end; // with TK_P3DMLine(P)^, Coords do
      end // if FEType.DTCode = K_3DAMLineDTCode then
      else
      if FEType.DTCode = K_3DAAngleDTCode then
      begin // Import Angle
        N_Dump2Str( '3DViewAnnotsImport >> Angle' );
        VObjCompRoot := AUDSlide.AddNewMeasurement('NAngle');
        LineComp := TN_UDPolyline(VObjCompRoot.DirChild(2));
        ArcComp := TN_UDArc(VObjCompRoot.DirChild(1));
        TextComp := TN_UDParaBox(VObjCompRoot.DirChild(3));
        with TK_P3DMLine(P)^, Coords do
        begin
          // Import Line Coords
          PCoord := LineComp.PSP.CPolyline.CPCoords.P();
          move( P()^, PCoord^, SizeOf(TFPoint) * 3 );
          for n := 0 to 2 * 3 - 1 do
          begin
            PCoord^ := PCoord^ + 100;
            Inc(PCoord);
          end;

          // Build Angle Arc and Text Value

          // Set  Line Pix Coords to calculate Angle
          SetLength( LineComp.UDPBufPixCoords, 3 );
          move( P()^, LineComp.UDPBufPixCoords[0], SizeOf(TFPoint) * 3 );
          for n := 0 to 2 do
            with LineComp.UDPBufPixCoords[n] do
            begin
              X := X * PixWidth / 100;
              Y := Y * PixHeight / 100;
            end;
          // Ñalculate Angle, and init Arc and Angle Text
          K_CMSVObjNAngleRebuild( LineComp, ArcComp, TextComp, nil);

          with ArcComp.PSP^, CCompBase, CCoords, CArc do
          if CArcBegAngle > CArcEndAngle then
          begin // Resulting Angl > 180 - switch coords Line end coords and Rebuild
            with LineComp, PSP.CPolyline do
            begin
              PPoint := CPCoords.P(0);
              FPoint := PPoint^;
              PPoint2 := CPCoords.P(2);
              PPoint^ := PPoint2^;
              PPoint2^ := FPoint;

              FPoint := UDPBufPixCoords[0];
              UDPBufPixCoords[0] := UDPBufPixCoords[2];
              UDPBufPixCoords[2] := FPoint;
            end; // with LineComp, PSP.CPolyline do

            // Ñalculate Angle, and init Arc and Angle Text
            K_CMSVObjNAngleRebuild( LineComp, ArcComp, TextComp, nil);
          end; // if CArcBegAngle > CArcEndAngle then


          K_CMVobjSetFontSizeAuto( TextComp, PixHeight );

          // Angle Line Color
          CurColor := LineColor;

          //Set Line Width
          PUPar := K_CMGetVObjPAttr( VObjCompRoot, 'LineWidth' );
          PFloat(PUPar.UPValue.P)^ := LineWidth;

        end; // with TK_P3DMLine(P)^, Coords do
      end // if FEType.DTCode = K_3DAAngleDTCode then
      else
      if FEType.DTCode = K_3DATextDTCode then
      begin // Import Text
        N_Dump2Str( '3DViewAnnotsImport >> Text' );
        with TK_P3DMText(P)^ do
        begin
          VObjCompRoot := AUDSlide.AddNewMeasurement('Dot');
          // Prepare Base Point User coords proper value
          BasePoint.X := BasePoint.X + 100;
          BasePoint.Y := BasePoint.Y + 100;

          // Set Dot Sigh Coords
          LineComp := TN_UDPolyline(VObjCompRoot.DirChild(1));
          with LineComp.PSP.CPolyline.CPCoords do
          begin
            PFPoint(P(0))^ := BasePoint;
            PFPoint(P(1))^ := BasePoint;
          end;

          // Set Dor Text attrs
          TextComp := TN_UDParaBox(VObjCompRoot.DirChild(2));

          with TextComp.PSP^, CCoords, CParaBox do
          begin
            POneTextBlock := CPBTextBlocks.P();

            // Prepare and Set Text
            WStr := K_StringMListReplace( Value, K_3DAML3, K_ummSaveMacro, nil, '&', ';' );
            POneTextBlock.OTBMText := WStr;

            // Set Font Attrs
            with TN_PNFont(K_GetPVRArray(POneTextBlock.OTBNFont).P())^ do
            begin
              if FontFace <> '' then
                NFFaceName  := FontFace;
              if FontPixSize <> 0 then
              begin
                NFLLWHeight := FontPixSize;
                NFBold := 0;
                NFWin.lfItalic := 0;
                NFWin.lfUnderline := 0;
                NFWin.lfStrikeOut := 0;
                if K_3DFSBold in FontStyle then
                  NFBold := 1;
                if K_3DFSItalic in FontStyle then
                  NFWin.lfItalic := 1;
                if K_3DFSUnderline in FontStyle then
                  NFWin.lfUnderline := 1;
                if K_3DFSStrike in FontStyle then
                  NFWin.lfStrikeOut := 1;
              end
              else
                K_CMVobjSetFontSizeAuto( TextComp, PixHeight );

              // Init Dot Sign Size by Font Height
              K_CMVobjSetDotSizeByFontHeight( VObjCompRoot, NFLLWHeight );

            end; // with TN_PNFont(K_GetPVRArray(POneTextBlock.OTBNFont).P())^ do
          end; // with TextComp.PSP^, CCoords, CParaBox do

          // Init Dot Text Position
          K_CMVobjInitDotTextPos( TextComp, BasePoint.X, BasePoint.Y,
                                  PixWidth, PixHeight );
          // Dot Color
          CurColor := TextColor;

        end; // with TK_P3DMText(P)^ do
      end; // if FEType.DTCode = K_3DATextDTCode then

      // Set Annotation MainColor and SelectedColor
      if VObjCompRoot <> nil then
      begin
        PUPar := K_CMGetVObjPAttr( VObjCompRoot, 'MainColor' );
        PInteger(PUPar.UPValue.P)^ := CurColor;
        K_CMChangeVObjSelectedColor(VObjCompRoot, CurColor);
      end
      else
        N_Dump1Str( format( '3DViewAnnotsImport >> Unknown Annot Type >> %s,  file >> %s ', [FEType.FD.ObjName, AFName] ) );
    end; // with UDAnnot,PDRA^ do
  end; // Annotation Import Loop >> for j := 0 to UDRoot.DirHigh do

  K_3DAUDRoot.ClearChilds();
  AUDSlide.CreateThumbnail();

end; // procedure K_CMImg3DViewAnnotsImport

function K_DIBResampleByResFunc( ADIBSrc : TN_DIBObj; APixPerMX, APixPerMY : Integer ) : TN_DIBObj;
begin
  Result := ADIBSrc;
end; // function K_DIBResampleByResFunc

//*********************************************** K_CMImg3DViewsFlistImport ***
// Import 3D Image Views after 3DViewer call
//
//     Parameters
// A3DSlide - 3D Slide ID to Import 2D views
// ASlideBasePath - base path to Import 2D views
// ABeforeImportProc - show Progress while importing 2D views procedure
// Result - Returns number of imported views
//
function K_CMImg3DViewsFlistImport( AFilesList : TStrings;
                         const A3DSlideID, ASlideBasePath : string;
                         ABeforeImportProc : TN_OneStrProcObj = nil ) : Integer;


var
  FName, ResPath, FAnnotName : string;
  i : Integer;
{}
//  WInt, j, n, PixPerM : Integer;
  WInt, j, PixPerM, PixPerMX : Integer;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
  WLength : Integer;
  ChangeResMode : Integer;
  CurImg : TN_UDDIB;
  ChangeECacheMode : Integer;
  SaveIconIsNeeded : Boolean;
  AppRTID : Integer;
{}
//  MTypeID : Integer;
//  MTypesList : TStrings;
begin
  // Import Existing 2D views
  Result := AFilesList.Count;
  if Result = 0 then Exit;

  ResPath := ASlideBasePath + K_CMS3DImgResFolder;
  Result := K_CMSlidesImportFromFilesList( AFilesList, ResPath,
                             '##%s from 3D ID=' + A3DSlideID,
                             nil, ABeforeImportProc );

  // Save imported slides
  if Result > 0 then
  begin
{
    MTypesList := K_CMEDAccess.EDAGetAllMediaTypes0();
    MTypeID := MTypesList.IndexOf( 'Computer Tomography' );
    if MTypeID = -1 then
      K_CMEDAccess.EDAddNewMediaType( MTypeID, 'Computer Tomography' )
    else
      MTypeID := Integer(MTypesList.Objects[MTypeID]);
    // Set CT media type
    for i := K_CMEDAccess.CurSlidesList.Count -1 downto K_CMEDAccess.CurSlidesList.Count - Result do
      TN_UDCMSlide(K_CMEDAccess.CurSlidesList[i]).P().CMSMediaType := MTypeID;
}
{ !!! new code: apply resolution and annotations}
    WLength := Length( ' from 3D ID=' + A3DSlideID );

    // Prepare Annotations Import Context
    K_CMImg3DViewAnnotsContPrep( );

    AppRTID := -1;
    if K_CMEDAccess is TK_CMEDDBAccess then
      AppRTID := TK_CMEDDBAccess(K_CMEDAccess).AppRTID;

    // View Calibration and Annotations Loop
    for i := K_CMEDAccess.CurSlidesList.Count -1 downto K_CMEDAccess.CurSlidesList.Count - Result do
    begin
      UDSlide := TN_UDCMSlide(K_CMEDAccess.CurSlidesList[i]);
      PCMSlide := UDSlide.P();
      ChangeECacheMode := 0;

      with PCMSlide^ do
      begin
        SaveIconIsNeeded := FALSE;
        ChangeResMode := 0;

        FName := Copy( CMSSourceDescr, 1, Length(CMSSourceDescr) - WLength );
        // Import Calibration Info
        WInt := Length(FName);
        if FName[WInt - 10] = '_' then
          ChangeResMode := 1
        else
        if FName[WInt - 16] = '_' then
          ChangeResMode := 2;

        if ChangeResMode <> 0 then
        begin
          PixPerM := 0;
          for j := WInt - 9 to  WInt - 4 do
            if (FName[j] >= '0') and (FName[j] <= '9') then
            begin
              PixPerM := 10 * PixPerM + StrToInt(FName[j]);
//              Inc(n);
            end
            else
            begin
              N_Dump1Str( format( 'K_CMImg3DViewsFlistImport >> Bad resolution %d PixPerM in %s', [PixPerM,FName] ) );
              break;
            end;

          if ChangeResMode = 2 then
          begin
          // X and Y resolutions are specified
            PixPerMX := 0;
            for j := WInt - 15 to  WInt - 10 do
              if (FName[j] >= '0') and (FName[j] <= '9') then
              begin
                PixPerMX := 10 * PixPerMX + StrToInt(FName[j]);
  //              Inc(n);
              end
              else
              begin
                N_Dump1Str( format( 'K_CMImg3DViewsFlistImport >> Bad X-resolution %d PixPerM in %s', [PixPerM,FName] ) );
                break;
              end;

            if (PixPerM > 0) and (PixPerMX > 0) and (PixPerMX <> PixPerM) then
            begin
              CurImg := UDSlide.GetCurrentImage();
              CurImg.DIBObj := K_DIBResampleByResFunc( CurImg.DIBObj, PixPerMX, PixPerM );
              PixPerM := Min(PixPerMX, PixPerM);
              with CurImg.DIBObj, CMSDB do
              begin
                PixWidth := DIBSize.X;
                PixHeight := DIBSize.Y;
              end; // with CurImg.DIBObj, CMSDB do
              // Save CurImage to EmCache
              ChangeECacheMode := 2;
              SaveIconIsNeeded := TRUE;
            end; // if (PixPerM > 0) and (PixPerMX > 0) and (PixPerMX <> PixPerM) then

          end; // if ChangeResMode = 2 then

          if PixPerM > 0 then // View has calibration info
          begin // Set Slide calibration info
            CMSDB.PixPermm := PixPerM / 1000;
            CMSDB.SFlags := CMSDB.SFlags - [cmsfProbablyCalibrated] + [cmsfAutoCalibrated];
            if ChangeECacheMode = 0 then
              ChangeECacheMode := 1;
            N_Dump1Str( format( 'K_CMImg3DViewsFlistImport >> Resolution %d PixPerM in %s', [PixPerM,FName] ) );
          end; // Set Slide calibration info
        end; // if ChangeResMode <> 0 then

        // Import View Annotations
        FAnnotName := ChangeFileExt( FName, '.txt' );
        FName := ResPath + FAnnotName;
        if FileExists( FName ) then // Import Annotations
        begin
          K_CMImg3DViewAnnotsImport( UDSlide, FName, CMSDB.PixPermm );
          SaveIconIsNeeded := FALSE;
          if ChangeECacheMode = 0 then
            ChangeECacheMode := 1;
        end
        else
          N_Dump1Str( 'K_CMImg3DViewsFlistImport >> Annot File not found >> ' + FName );

      end; // with PCMSlide^ do

      if ChangeECacheMode > 0 then
      begin
        if SaveIconIsNeeded then
          UDSlide.CreateThumbnail();
        UDSlide.ECacheSave( AppRTID, ChangeECacheMode );
      end; // if ChangeECacheMode > 0 then

    end; // for i := K_CMEDAccess.CurSlidesList.Count ...
    // View Calibration and Annotations Loop

    // Free Annotations Import Context
    K_CMImg3DViewAnnotsContFree( );
{}
    Result := K_CMSaveLastInCurSlidesList( Result );

  end; // if Result > 0 then

  // remove Views Files
  for i := 0 to AFilesList.Count - 1 do
  begin
    FName := ResPath + AFilesList[i];
    DeleteFile( FName );                          // Delete View Image File
    DeleteFile( ChangeFileExt( FName, '.txt' ) ); // Delete View Annotations File
  end;

  N_Dump2Str( 'K_CMImg3DViewsFlistImport fin Count=' + IntToStr(Result) );

end; // function K_CMImg3DViewsFlistImport

{
//**************************************************** K_CMImg3DViewsImport ***
// Import 3D Image Views after 3DViewer call
//
//     Parameters
// A3DSlide - 3D Slide ID to Import 2D views
// ASlideBasePath - base path to Import 2D views
// ABeforeImportProc - show Progerss while importing 2D views procedure
// Result - Returns number of imported views
//
function K_CMImg3DViewsImport( const A3DSlideID, ASlideBasePath : string ) : Integer;
var
  SL : TStringList;
begin
  // Import Existing 2D views

  // Build 2D views files  List
  SL := TStringList.Create();
  K_CMImg3DViewsFListPrep( SL, A3DSlideID, ASlideBasePath );
  Result :=  K_CMImg3DViewsFlistImport( SL, A3DSlideID, ASlideBasePath );
  SL.Free;
end; // function K_CMImg3DViewsImport
}

//**************************************************** K_CMImg3DViewsImport ***
// Import 3D Image Views after 3DViewer call
//
//     Parameters
// APCMSlide - 3D Slide attributes pointer
// Result - Returns '' if attributes are imported else returns file error read info.
//
function K_CMImg3DAttrsInit( APCMSlide : Pointer ): Boolean;
var
  ErrStr, InfoStr, InfoFName : string;
  ErrCode : Integer;
label LExit;
begin
  with TN_PCMSlide(APCMSlide)^, CMSDB do
  begin
    InfoFName := MediaFExt + K_CMS3DImgResFolder + K_CMS3DImgResInfoFile;
    K_CMEDAccess.TmpStrings.Clear();
    ErrStr := K_VFLoadStrings1( InfoFName, K_CMEDAccess.TmpStrings, ErrCode );
    Result := ErrStr = '';
    if not Result then
    begin
      N_Dump2Str( format( 'K_CMImg3DAttrsInit file %s >> %s', [InfoFName,ErrStr] ) );
      goto LExit;
    end;
    if K_CMEDAccess.TmpStrings.Count = 0 then
    begin
      N_Dump2Str( format( 'K_CMImg3DAttrsInit file %s >> is empty', [InfoFName] ) );
      Result := FALSE;
      goto LExit;
    end;

    InfoStr := K_CMEDAccess.TmpStrings.Values['DateTaken'];
    if InfoStr <> '' then
      CMSDTTaken := K_StrToDateTime( InfoStr );

    InfoStr := K_CMEDAccess.TmpStrings.Values['Width'];
    if InfoStr <> '' then
      PixWidth := StrToIntDef(  InfoStr, PixWidth );

    InfoStr := K_CMEDAccess.TmpStrings.Values['Height'];
    if InfoStr <> '' then
      PixHeight := StrToIntDef(  InfoStr, PixHeight );

    InfoStr := K_CMEDAccess.TmpStrings.Values['PixBits'];
    if InfoStr <> '' then
      PixBits := StrToIntDef(  InfoStr, PixBits );

    InfoStr := K_CMEDAccess.TmpStrings.Values['Depth'];
    if InfoStr <> '' then
      PixDepth := StrToIntDef(  InfoStr, PixDepth );

LExit: //***********
    K_CMEDAccess.Int64Data := 0;
    K_ScanFilesTree( MediaFExt, K_CMEDAccess.EDACalcFilesSize, '*.*' );
    BytesSize := K_CMEDAccess.Int64Data;
//    BytesSize := (PixBits shr 3) * PixDepth * PixWidth * PixHeight;
  end;
end; // function K_CMImg3DAttrsInit


//************************************************** K_CMImg3DTmpFilesClear ***
// Remove 3D image temporary files
//
//     Parameters
// ATmpFilesPath - path to new 3D image temporary files to delete
// Result - Returns -1 if empty path, -2 if path doesn't exist, else undeleted files number
//
function K_CMImg3DTmpFilesClear( const ATmpFilesPath : string ): Integer;
var
  DeleteTaskFileName : string;
begin
  Result := -1;
  if ATmpFilesPath = '' then Exit;
  Result := -2;
  if not DirectoryExists( ATmpFilesPath ) then Exit;

  N_Dump2Str( format( 'DB>> K_CMImg3DTmpFilesClear "%s" start', [ATmpFilesPath] ) );
  K_CMEDAccess.TmpStrings.Clear();
  K_DeleteFolderFilesEx( ATmpFilesPath, K_CMEDAccess.TmpStrings );
  Result := K_CMEDAccess.TmpStrings.Count;
  if Result > 0 then
  begin
    DeleteTaskFileName := format( 'DT_%s.txt', [K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' )] );
    N_Dump1Str( 'DB>> K_CMImg3DTmpFilesClear couldn''t delete:'#13#10 +
                K_CMEDAccess.TmpStrings.Text + '!!Clear files task will be created >> ' + DeleteTaskFileName );
    // Prepare Delete Files Task
    K_CMEDAccess.TmpStrings.Text := ATmpFilesPath;
    K_CMEDAccess.TmpStrings.SaveToFile( TK_CMEDDBAccess(K_CMEDAccess).SlidesImg3DRootFolder + DeleteTaskFileName );
    Exit;
  end;

  RemoveDir( ATmpFilesPath );
  // Remove All Parent SubTree if needed
  if TK_CMEDDBAccess(K_CMEDAccess).SlidesImg3DRootFolder <> '' then
    K_CMEDAccess.EDARemovePathFolders0( ExcludeTrailingPathDelimiter(ATmpFilesPath),
              TK_CMEDDBAccess(K_CMEDAccess).SlidesImg3DRootFolder );
end; // function K_CMImg3DTmpFilesClear

//********************************************************* K_CMImg3DImport ***
// Import 3D Image from files
//
//     Parameters
// Sender - Event Sender
//
procedure K_CMImg3DImport( const AImport3DFolder : string; const ASourceDescr : string = '' );
var
  Slide3D : TN_UDCMSlide;
  InfoFName{, InfoStr} : string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo : string;
begin
  Slide3D := K_CMSlideCreateForImg3DObject();
  Slide3D.CreateThumbnail(); // create TMP  thubmnail
  K_CMEDAccess.EDAAddSlide( Slide3D );
  with Slide3D, P()^ do
  begin
    N_CM_MainForm.CMMSetUIEnabled( FALSE );

    N_CM_MainForm.CMMCurFMainForm.Hide();

    ResCode := K_CMImg3DCall( CMSDB.MediaFExt, AImport3DFolder );

    if K_CMD4WAppFinState then
    begin
      N_Dump1Str( '3D> !!! CMSuite is terminated' );
      Application.Terminate;
      Exit;
    end;

    N_CM_MainForm.CMMCurFMainFormSkipOnShow := TRUE;
    N_CM_MainForm.CMMCurFMainForm.Show();

    N_CM_MainForm.CMMSetUIEnabled( TRUE );

    if ResCode = 0 then
    begin
    // Rebuild Thumbnail
      CreateThumbnail(); // create TMP  thubmnail
      K_CMImg3DAttrsInit( P() );

      CMSSourceDescr := ASourceDescr;
      if CMSSourceDescr = '' then
        CMSSourceDescr := ExtractFileName(ExcludeTrailingPathDelimiter(AImport3DFolder));

      // Rebuild 3D slide ECache
      CMSlideECSFlags := [cmssfAttribsChanged];
      K_CMEDAccess.EDASaveSlideToECache( Slide3D );

      // Save 3D object
      K_CMEDAccess.EDASaveSlidesArray( @Slide3D, 1 );

      // Import and Save 2D views
      InfoFName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
                                       K_CMSlideGetImg3DFolderName( Slide3D.ObjName );
      CurSlidesNum := N_CM_MainForm.CMMImg3DViewsImportAndShowProgress( Slide3D.ObjName, InfoFName );
      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

      N_CM_MainForm.CMMFRebuildVisSlides();
      N_CM_MainForm.CMMFDisableActions( nil );

      AddViewsInfo := K_CML1Form.LLLImg3D1.Caption; // ' 3D object is imported'
      if CurSlidesNum > 0 then
        AddViewsInfo := format( K_CML1Form.LLLImg3D2.Caption,
                               //  '3D object and %s',
                         [format( K_CML1Form.LLLImg3D3.Caption,
        //                ' %d 3D views are imported'
                               [CurSlidesNum] )] );
      N_CM_MainForm.CMMFShowStringByTimer( AddViewsInfo );
    end   // if ResCode = 0 then
    else
    begin // if ResCode <> 0 then
      // Remove New Slide
      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        CurSlidesList.Delete(CurSlidesList.Count - 1);
        EDAClearSlideECache( Slide3D );
      end;

      Slide3D.UDDelete();
    end;
  end; // with Slide3D, P()^ do

end; // procedure K_CMImg3DImport

//**************************************************** K_CMDev3DCreateSlide ***
// Import 3D Image from files
//
//     Parameters
// APProfile       - Pointer to device profile
// ADev3DObjFolder - path to 3D object data in devise files storage
// AThumbDIBObj    - 3D object thumbnail DIB (150x150)
// AWidth          - object width  (1-st dimension)
// AHeight         - object height (2-nd dimension)
// ADepth          - object depth  (3-d dimension)
// APixSize        - object pixel bits size
//
procedure K_CMDev3DCreateSlide( APProfile : TK_PCMOtherProfile; const ADev3DObjFolder : string;
                                AThumbDIBObj : TObject;
                                AWidth, AHeight, ADepth, APixSize : Integer );
var
  Slide3D : TN_UDCMSlide;
begin

  Slide3D := K_CMSlideCreateForImg3DObject( TRUE );
  if AThumbDIBObj is TN_DIBObj then
    Slide3D.SetThumbnailByDIB( TN_DIBObj(AThumbDIBObj) )
  else
  begin
    Slide3D.CreateThumbnail(); // create TMP  thubmnail
    N_Dump1Str( 'K_CMDev3DCreateSlide ThmubObj is not DIB' );
  end;

  K_CMEDAccess.EDAAddSlide( Slide3D );
  with Slide3D, P()^ do
  begin
    CMSDB.MediaFExt := ADev3DObjFolder;
    CMSSourceDescr  := APProfile.CMDPCaption;
    CMSDB.Capt3DDevObjName := APProfile.CMDPGroupName;
    CMSDB.PixWidth  := AWidth;
    CMSDB.PixHeight := AHeight;
    CMSDB.PixDepth  := ADepth;
    CMSDB.PixBits   := APixSize;
    CMSlideECSFlags := [cmssfAttribsChanged];
  end; // with Slide3D, P()^ do
  K_CMEDAccess.EDASaveSlideToECache( Slide3D );
  K_CMEDAccess.EDASaveSlidesArray( @Slide3D, 1 );
  K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.CMMFDisableActions( nil );
  N_CM_MainForm.CMMFShowStringByTimer( '3D object is captured' );
end; // function K_CMDev3DCreateSlide

//******************************************* K_CMFilesEmailingBySelfClient ***
// Email given files by Self Email Client
//
//     Parameters
// ASubject   - email subject
// AFilesList - files paths list to attach
// Result     - Returns TRUE if Email is success fully send, FALSE if some problems are detected
//
function K_CMFilesEmailingBySelfClient( const ASubject : string; AFilesList : TStrings ) : Boolean;
var
  RetCode : Integer;
begin
  N_Dump2Str( 'K_CMFilesEmailingBySelfClient start' );
  Result := FALSE;
  if (AFilesList = nil) or (AFilesList.Count = 0) then
    Exit;

//  N_Dump2Str( 'K_CMFilesEmailingBySelfClient before N_CMSendMail' );
  try
    RetCode := N_CMSendMail( ASubject, AFilesList );
  except
    on E: Exception do
    begin
      RetCode := -1000;
      N_Dump1Str( 'Err>> K_CMFilesEmailingBySelfClient >> ' + E.Message );
    end;
  end;
  N_Dump2Str( 'K_CMFilesEmailingBySelfClient after N_CMSendMail RetCode=' + IntToStr(RetCode) );
//  RetCode := -10000;
  if RetCode = 0 then
    Result := TRUE
  else if RetCode < 0 then
  begin
    if RetCode = -10000 then
    // 'The secure connection cannot be established as Open SSL is not installed on your PC.'#13#10+
    // '             Please install Open SSL and repeat the operation.'
      K_CMShowMessageDlg1( K_CML1Form.LLLEmail5.Caption, mtWarning )
    else
    // ' Emailing internal exception'
      K_CMShowMessageDlg1( K_CML1Form.LLLEmail1.Caption, mtWarning )
  end
  else if RetCode = 1 then
  // ' Emailing was aborted by user'
    N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLEmail2.Caption )
  else
  // ' Emailing failure'
    K_CMShowMessageDlg1( K_CML1Form.LLLEmail3.Caption, mtWarning );

  N_Dump2Str( 'K_CMFilesEmailingBySelfClient Fin' );

end; // function K_CMFilesEmailingBySelfClient

//**************************************************** K_CMPrepSlideDIBFile ***
// Prepare Slide DIB File
//
//     Parameters
// AFileName   - Path for resulting Image File
// ASlide      - Slide object
// AMaxWidth   - Media Object resulting file maximal width, if =0 then use image
//               original width, else resulting Image width will be defined automatically
//               not larger then AMaxWidth and Object Image original width using
//               original Object Image aspect and AMaxHeight and set on output
// AMaxHeight  - Media Object resulting file maximal height, if =0 then use Object Image
//               original height, else resulting Image height will be defined automatically
//               not larger then AMaxHeight and Object Image original height using
//               original Object Image aspect and AMaxWidth and set on output
// AFileFormat - resulting Image file format code: junior decimal number (1 - bmp, 3 - jpg, 4 - tif, 5 - png)
//               the two next decimal numbers coding jpg quality from 01 to 99, 00 means quality 100
// AExportToDIBFlags - Export to DIB flags
// Result      - Returns resulting code:
//#F
// (0x0) - Indicates that given media object file was created
// (0x1) - Given Slide is not image
// (0x2) - CMS has not enough memory
// (0x3) - File storage error
// (0x4) - Export to DIB error
// (0x5) - Save to file error
//#/F
//
function K_CMPrepSlideDIBFile( const AFileName : string;
              ASlide : TN_UDCMBSlide;
              var AMaxWidth, AMaxHeight : Integer;
              AFileFormat : Integer;
              AExportToDIBFlags : TK_CMBSlideExportToDIBFlags ) : Integer;
var
  RIEncodingInfo : TK_RIFileEncInfo;
  DIBObj : TN_DIBObj;
  PCMSlide : TN_PCMSlide;
  JPGQuality : Integer;
begin

  Result := S_OK;
  PCMSlide := ASlide.P;
  if (ASlide is TN_UDCMStudy) and (ASlide.Marker <> 0) then
  begin // Marker is
    N_Dump1Str( 'K_CMPrepSlideDIBFile >> Study of not current patient' );
    Result := 1;
    Exit;
  end
  else
  if (cmsfIsMediaObj in PCMSlide.CMSDB.SFlags) or
     (cmsfIsImg3DObj in PCMSlide.CMSDB.SFlags)  then
  begin
    N_Dump1Str( 'K_CMPrepSlideDIBFile >> Slide has no DIB' );
    Result := 1;
    Exit;
  end;

// Check Memory for Image Loading if needed
//!!! check here because MapImage and CurImage are created in EDACheckSlideMedia in ExtDB Mode
  if not K_CMSCheckMemForSlide1( TN_UDCMSlide(ASlide) ) then
  begin
    N_Dump1Str( 'K_CMPrepSlideDIBFile >> CheckMemForSlide >> Out of memory' );
    Result := 2;
    Exit;
  end;

  if (K_CMEDAccess.EDACheckSlideMedia( TN_UDCMSlide(ASlide), TRUE ) = K_edFails) then
  begin
    N_Dump1Str( 'K_CMPrepSlideDIBFile >> CheckSlideFile >> Error' );
    Result := 3;
    Exit;
  end;

  DIBObj := ASlide.ExportToDIB( AExportToDIBFlags, AMaxWidth, AMaxHeight );
  if DIBObj = nil then
  begin
    Result := 4;
    N_Dump1Str( 'K_CMPrepSlideDIBFile >> ExportToDIB error' );
    Exit;
  end;

  AMaxWidth  := DIBObj.DIBSize.X;
  AMaxHeight := DIBObj.DIBSize.Y;

  K_RIObj.RIClearFileEncInfo( @RIEncodingInfo );
  RIEncodingInfo.RIFileEncType := TK_RIFileEncType(AFileFormat Mod 10);
  if RIEncodingInfo.RIFileEncType = rietJPG then
  begin
    JPGQuality := Round(AFileFormat / 10) mod 100;
    if JPGQuality > 0 then
      RIEncodingInfo.RIFComprQuality := JPGQuality;
  end;

  if K_RIObj.RISaveDIBToFile( DIBObj, AFileName, @RIEncodingInfo ) <> rirOK then
  begin
    N_Dump1Str( format( 'K_CMPrepSlideDIBFile >> RISaveDIBToFile "%s" fails K_RIObj=%s', [AFileName, K_RIObj.ClassName] ) );
    Result := 5;
  end;

  DIBObj.Free;

end; // function K_CMPrepSlideDIBFile

//*************************************************** K_CMRemoveOldDumpData ***
// Remove Old Dump Data (is used for all types of dump)
//
//     Parameters
// ABoundDate  - all dump data older then given TimeStamp should be removed
// AFileName   - Dump file name
// ASearchSStr - search context for string with timestamp
// ATSStartInd - TimeStamp start Char index
// ATSLength   - Length of TimeStamp text
// ATSFormat   - TimeStamp format
// ACompDateFlag - if TRUE then binary TimeStamp should be compared, else TimeStamp text should be compared
// Result      - Returns string for resulting dump message
//
function K_CMRemoveOldDumpData( ABoundDate : TDateTime; const AFileName : string;
                                const ASearchSStr : string; ATSStartInd, ATSLength : Integer;
                                const ATSFormat : string; ACompDateFlag : Boolean ) : string;
var
  SL,SL1 : TStringList;
  WStr, StartDump : string;
  Ind, TSLeng, WTSleng, SourceCount, LastProcInd : Integer;
  CurDate : TDateTime;
  SCurDate, SBoundTS, SFistRemainingDump, SLastRemovedDump : string;
  FStream : TFileStream;
  FMStream : TMemoryStream;

const
  FistrPortionSize = 1024 * 1024;
  LastPortionSize = 1024 * 1024 * 100;


  function SearchNextPortion() : Boolean;
  begin
    Result := TRUE;
    if ASearchSStr <> '' then
      Ind := K_SearchInStrings( SL, ASearchSStr, Ind, 0, FALSE, FALSE, TRUE );
    if (Ind < 0) or (Ind >= SL.Count) then
    begin
      Ind := SourceCount; // Remove all Flag
      Result := FALSE;  // Nothing was found
      Exit;
    end;

    WStr := SL[Ind];
    WTSleng := TSleng;
    if TSLeng = 0 then
      WTSLeng := PosEx( 'L', WStr, ATSStartInd + ATSLength ) - ATSStartInd - 2;
    SCurDate := TrimRight( Copy( WStr, ATSStartInd, WTSLeng ) );
    if StartDump = '' then StartDump := SCurDate;
    SFistRemainingDump := SCurDate;
  end; // function SearchNextPortion

  procedure RemoveOldLines();
  var i : Integer;
  begin
    if (Ind > 3) and (LastProcInd <> 0) then // Precation - skip to remove first empty strings and if no start dump info found
    begin
      SL1 := TStringList.Create;
      if Ind > LastProcInd then
        Ind := LastProcInd;
      for i := Ind  to SL.Count - 1 do
        SL1.Add( SL[i] );
      N_SaveStringsToAnsiFile( AFileName, SL1 );
//      N_SaveStringsToAnsiFile( AFileName + '.txt', SL1 );
      SL1.Free;
      Result := format( 'from %s, last removed portion %s, first remaining portion %s', [StartDump, SLastRemovedDump, SFistRemainingDump] );
    end //  if Ind > 3 then
    else
      N_Dump2Str( 'Dump data is not removed' );

  end; // procedure RemoveOldLines

begin
  Result := '';

  if not FileExists( AFileName ) then Exit; // recaution
  try
    FStream := TFileStream.Create( AFileName, fmOpenRead );
  except
    on E: Exception do
    begin
      N_Dump1Str( format( 'K_CMRemoveOldDumpData "%s" FileStream create error >> %s', [AFileName,E.Message] ) );
      Exit;
    end; // on E: Exception do
  end;

  TSLeng := 0;
  if not ACompDateFlag then
  begin
    TSLeng := ATSLength;
    SBoundTS := FormatDateTime( ATSFormat, ABoundDate );
  end
  else
    SBoundTS := DateTimeToStr(ABoundDate);

  N_Dump2Str( 'Try to remove Dump data before ' + SBoundTS );

  StartDump := '';
  SL := TStringList.Create;
//  SL.LoadFromFile( AFileName );
  N_Dump2Str( format( 'File %s size %d', [AFileName,FStream.Size] ) );

  if FStream.Size > LastPortionSize then
  begin // File is too big - analize last 100 MB
  // Parse Date of file start portion
    FMStream := TMemoryStream.Create();
    FMStream.SetSize( FistrPortionSize );
    FMStream.CopyFrom( FStream, FistrPortionSize );
    FMStream.Seek( 0, soBeginning );
    SL.LoadFromStream( FMStream );
    SearchNextPortion();
    N_Dump2Str( format( 'Found start date %s, continue search in last 100 MB', [StartDump] ) );
    FMStream.Free;
  // Prepare to Load Last 100 MB
    FStream.Seek(  -LastPortionSize, soEnd );
  end;
  SL.LoadFromStream( FStream );
  FStream.Free;

  Ind := 0;
  SCurDate := '';
  SFistRemainingDump := '';
  SLastRemovedDump := '';

  SourceCount := SL.Count;
  LastProcInd := 0;
  while TRUE do
  begin
    if not SearchNextPortion() then
    begin
      RemoveOldLines();
      Break;
    end;

    LastProcInd := Ind;

    if ACompDateFlag then // wrong DatTime format
    begin
      CurDate := StrToDateTimeDef( SCurDate, 0 );
      if CurDate = 0 then // wrong DatTime format
      begin
        SL.Add( format('K_CMRemoveOldDump1Data >> wrong DateTime format >> %s', [SCurDate] ) );
        N_Dump2Str( SL[SL.Count-1] );
      end
      else
      if CurDate >= ABoundDate then
      begin // Finish search
//        CurDate := 0; // Remove is Needed flag
        RemoveOldLines();
        Break;
      end // if CurDate >= ABoundDate then
      else
        N_Dump2Str( 'Remove ' + SCurDate );
    end
    else
    begin
      if SCurDate >= SBoundTS then
      begin // Finish search
//        SCurDate := ''; // Remove is Needed flag
        RemoveOldLines();
        Break;
      end // if CurDate >= ABoundDate then
      else
        N_Dump2Str( 'Remove ' + SCurDate );
    end;
    SLastRemovedDump := SCurDate;
    Inc(Ind);
  end; // while TRUE do

  SL.Free;
end; // procedure K_CMRemoveOldDumpData

//************************************************** K_CMRemoveOldDump1Data ***
// Remove Old Dump1 Data
//
//     Parameters
// ABoundDate - all dump data older then given TimeStamp should be removed
//
procedure K_CMRemoveOldDump1Data( ABoundDate : TDateTime );
var
  WStr : string;
begin
  N_Dump2Str( 'K_CMRemoveOldDump1Data Start' );

  WStr := K_CMRemoveOldDumpData( ABoundDate, N_LogChannels[N_Dump1LCInd].LCFullFName,
                                 '*** New log portion at ', 24, 12, '', TRUE );
  if WStr <> '' then
    N_Dump1Str( '***** Remove Old Logs ' + WStr );

  N_Dump2Str( 'K_CMRemoveOldDump1Data fin' );
end; // procedure K_CMRemoveOldDump1Data

//************************************************ K_CMRemoveOldDumpSCUData ***
// Remove Old CMScan Upload Dump Data
//
//     Parameters
// ABoundDate - all dump data older then given TimeStamp should be removed
//
procedure K_CMRemoveOldDumpSCUData( ABoundDate : TDateTime );
var
  WStr : string;
begin
  WStr := ChangeFileExt(N_LogChannels[N_Dump1LCInd].LCFullFName, 'SCU.txt' );
  if not FileExists( WStr ) then Exit;

  N_Dump2Str( 'K_CMRemoveOldDumpSCUData Start ' );


  WStr := K_CMRemoveOldDumpData( ABoundDate, WStr,
                                 '****************** Upload Session Start ', 41, 23,
                                 'yyyy-mm-dd_hh":"nn":"ss.zzz', FALSE );
  if WStr <> '' then
    N_Dump1Str( '***** Remove Old SCU Logs ' + WStr );

  N_Dump2Str( 'K_CMRemoveOldDumpSCUData fin' );
end; // procedure K_CMRemoveOldDumpSCUData

//************************************************ K_CMRemoveOldDumpSCDData ***
// Remove Old CMScan Download Dump Data
//
//     Parameters
// ABoundDate - all dump data older then given TimeStamp should be removed
//
procedure K_CMRemoveOldDumpSCDData( ABoundDate : TDateTime );
var
  WStr : string;
begin
  WStr := ChangeFileExt(N_LogChannels[N_Dump1LCInd].LCFullFName, 'SCD.txt' );
  if not FileExists( WStr ) then Exit;

  N_Dump2Str( 'K_CMRemoveOldDumpSCDData Start ' );

  WStr := K_CMRemoveOldDumpData( ABoundDate, WStr,
                                 '****************** Download Session Start ', 43, 23,
                                 'yyyy-mm-dd_hh":"nn":"ss.zzz', FALSE );
  if WStr <> '' then
    N_Dump1Str( '***** Remove Old SCD Logs ' + WStr );

  N_Dump2Str( 'K_CMRemoveOldDumpSCDData fin' );
end; // procedure K_CMRemoveOldDumpSCDData

//******************************************** K_CMRemoveOldDumpWrapDCMData ***
// Remove Old WrapDCM.dll Upload Dump Data
//
//     Parameters
// ABoundDate - all dump data older then given TimeStamp should be removed
//
procedure K_CMRemoveOldDumpWrapDCMData( ABoundDate : TDateTime );
var
  WStr : string;
begin
  WStr := K_DCMGLibW.DLLogFileName;
  if not FileExists( WStr ) then Exit;
  K_DCMGLibW.DLFreeAll();
  N_Dump2Str( 'K_CMRemoveOldDumpWrapDCMData Start ' );


  WStr := K_CMRemoveOldDumpData( ABoundDate, WStr,
                                 '', 1, 23,
                                 'yyyy-mm-dd hh":"nn":"ss.zzz', FALSE );
  if WStr <> '' then
    N_Dump1Str( '***** Remove Old WrapDCM Logs ' + WStr );

  N_Dump2Str( 'K_CMRemoveOldDumpWrapDCMData fin' );
end; // procedure K_CMRemoveOldDumpWrapDCMData

//********************************************** K_CMRemoveOldDumpBoundDate ***
// Remove Old Dumps Bound in months
//
//     Parameters
// Result - returns bound in months
//
function K_CMRemoveOldDumpMonths() : Double;
begin
  Result := N_MemIniToDbl( 'CMS_Main', 'LogsKeepPeriodInMonths', 1 );
  Result := N_MemIniToDbl( 'CMS_UserMain', 'LogsKeepPeriodInMonths', Result );
end; // function K_CMRemoveOldDumpMonths

//********************************************** K_CMRemoveOldDumpBoundDate ***
// Remove Old Dumps Bound Date
//
//     Parameters
// Result - returns bound date
//
function K_CMRemoveOldDumpBoundDate() : TDateTime;
begin

  Result := Now() - 365 / 12 * K_CMRemoveOldDumpMonths();
end; // function K_CMRemoveOldDumpBoundDate


//************************************************ K_CMRemoveOldDumpAllData ***
// Remove Old Dumps Data for All CMS applications (CMSite, CMScan, CMSupport)
//
procedure K_CMRemoveOldDumpAllData( );
var
  BoundDate : TDateTime;
begin
  BoundDate := K_CMRemoveOldDumpBoundDate();
  K_CMRemoveOldDump1Data( BoundDate );
  K_CMRemoveOldDumpSCDData( BoundDate );
  K_CMRemoveOldDumpSCUData( BoundDate );
  K_CMRemoveOldDumpWrapDCMData( BoundDate );
end; // procedure K_CMRemoveOldDumpAllData

//************************************************** K_CMRemoveOldDump2Data ***
// Remove Old Dump2 Files or Folders
//
//     Parameters
// ABoundDate - all dump data older then given TimeStamp should be removed
//
function K_CMRemoveOldDump2Files( ABoundDate : TDateTime; const ADFilesNamePat, ACompDateFormat : string; ARemoveFolder : Boolean ) : Integer;
var
  SBoundDate, BasePath, FCompName, CurFName : string;
  i : Integer;

begin
  SBoundDate := N_GetDateTimeStr1( ABoundDate );
  if ARemoveFolder then
  N_Dump2Str( 'Try to remove Dump2 Files Start from ' + SBoundDate );
  FCompName := format( ACompDateFormat, [SBoundDate] );
  K_ScanFilesTreeMaxLevel := 1;
  K_CMEDAccess.TmpStrings.Clear;
  BasePath := ExtractFilePath(N_LogChannels[N_Dump1LCInd].LCFullFName);
//  K_ScanFilesTree( BasePath, K_CMEDAccess.EDASelectDataFiles, '*.*' );
  K_ScanFilesTree( BasePath, K_CMEDAccess.EDAScanFilesTreeSelectFile, ADFilesNamePat );
  K_ScanFilesTreeMaxLevel := 0;
  Result := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    CurFName := K_CMEDAccess.TmpStrings[i];
    if CurFName < FCompName then
    begin
      N_Dump1Str( '***** Remove ' + CurFName );
      CurFName := BasePath + CurFName;
//CurFName := CurFName + '1';
      if ARemoveFolder then
      begin
        K_DeleteFolderFiles( CurFName );
        RemoveDir( ExcludeTrailingPathDelimiter( CurFName ) );
      end
      else
        K_DeleteFile( CurFName );

      Inc(Result);
    end; // if CurFName < FCompName then

  end; // for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do

end; // procedure K_CMRemoveOldDump2Files

//******************************************* K_CMRemoveOldDump2ExceptFiles ***
// Remove Old Dump2 files created when CMS exception is happened
// for All CMS applications (CMSite, CMScan, CMSupport)
//
procedure K_CMRemoveOldDump2ExceptFiles( );
var
  i : Integer;

begin
  N_Dump2Str( 'K_CMRemoveOldDump2ExceptFiles Start' );

  i := K_CMRemoveOldDump2Files( K_CMRemoveOldDumpBoundDate(),
         '????_??_??-??_??_??', '%s\', TRUE );
  if i > 0 then
    N_Dump1Str( format( '***** Remove %d Old Dump Folders', [i] ) );

  N_Dump2Str( 'K_CMRemoveOldDump2ExceptFiles Fin' );
end; // procedure K_CMRemoveOldDump2ExceptFiles

//********************************************* K_CMRemoveOldDump2HaltFiles ***
// Remove Old Dump2 files created when CMS applications are halted
// for All CMS applications (CMSite, CMScan, CMSupport)
//
procedure K_CMRemoveOldDump2HaltFiles( );
var
  FName : string;
  i : Integer;

begin
  N_Dump2Str( 'K_CMRemoveOldDump2HaltFiles Start' );

  FName := ExtractFileName( N_LogChannels[N_Dump2LCInd].LCFullFName );
  FName := Copy( FName, 1, Length(FName) - Length('.txt') );

  i := K_CMRemoveOldDump2Files( K_CMRemoveOldDumpBoundDate(),
                                FName + '????_??_??-??_??_??.txt',
                                FName + '%s.txt', FALSE );
  if i > 0 then
    N_Dump1Str( format( '***** Remove %d Old ErrLog Files', [i] ) );

  N_Dump2Str( 'K_CMRemoveOldDump2HaltFiles Fin' );
end; // procedure K_CMRemoveOldDump2HaltFiles

//******************************************** K_CMStudyTemplateUnloadDescr ***
// Unload Study Template Description to Strings
//
//     Parameters
// AUDTemplate  - Study Template Root UDBase
// ASL          - Resulting Strings with Study Template Decription
// AUnloadFlags - Study Template Unload Flags
//
procedure K_CMStudyTemplateUnloadDescr( AUDTemplate : TN_UDBase; ASL : TStrings;
                                        AUnloadFlags : TK_CMStTempUnloadFlags = [] );
var
  i : Integer;
  MapRoot : TN_UDBase;
  Item : TN_UDBase;
  ItemThumb : TN_UDBase;
  FlipRotateFlags : Byte;
  TeethChart : Int64;
  STeethChart : string;
  SFlipRotate : string;
  SStubImg : string;
  PUP: TN_POneUserParam;
  STemplateID : string;
  WStr : string;
begin
  ASL.Clear;
  MapRoot := AUDTemplate.DirChild(K_CMSlideIndMapRoot);

  STemplateID := '';
  if not (K_sttSkipUnloadTemlateID in AUnloadFlags) then
    STemplateID := format( ' ID="%s"', [AUDTemplate.ObjName] );

  with TN_UDCompVis(MapRoot).PCCS()^.SRSize do
  begin
    WStr := format( 'Caption="%s"', [AUDTemplate.ObjAliase] );
    if AUDTemplate.ObjInfo <> '' then
      WStr := WStr + format( ' Info="%s"', [AUDTemplate.ObjInfo] );
    ASL.Add( format( '<CMStudyTemplate%s %s Width="%g" Height="%g">',
           [STemplateID, WStr, X, Y] ) );
  end;

  for i := 0 to MapRoot.DirHigh do
  begin
    Item := MapRoot.DirChild(i);

    SFlipRotate := '';
    PUP := N_GetUserParPtr( TN_UDCompBase(Item).R, 'FlipRotateFlags' );
    if PUP <> nil then
    begin
      FlipRotateFlags := PByte(PUP.UPValue.P)^;
      if FlipRotateFlags <> 0 then
      begin
        if not (K_sttUnloadPosAttrDetails in AUnloadFlags) then
          SFlipRotate := format( ' FlipRotateC="%d"',[FlipRotateFlags] )
        else
        begin
          case FlipRotateFlags of
          1: SFlipRotate := 'H';
          2: SFlipRotate := 'V';
          3: SFlipRotate := 'R2';
          4: SFlipRotate := 'R1,H';
          5: SFlipRotate := 'R1';
          6: SFlipRotate := 'R3';
          7: SFlipRotate := 'R1,V';
          end; // case FlipRotateFlags of
          SFlipRotate := format( ' FlipRotate="%s"', [SFlipRotate] );
        end;
      end
    end;

    STeethChart := '';
    PUP := N_GetUserParPtr( TN_UDCompBase(Item).R, 'TeethFlags' );
    if (PUP <> nil) then
    begin
      TeethChart := PInt64(PUP.UPValue.P)^;
      if TeethChart <> 0 then
      begin
        if not (K_sttUnloadPosAttrDetails in AUnloadFlags) then
          STeethChart := format( ' TeethChartC="%d"', [TeethChart] )
        else
          STeethChart := format( ' TeethChart="%s"',
                                  [K_CMSTeethChartStateToText(TeethChart)]);
      end;
    end;

    SStubImg := '';
//    with Item.DirChild(0).DirChild(0).DirChild(0) do
//      if ObjName <> 'EmptyImgStub' then
//        SStubImg := format( ' StubImgName="%s"', [ObjName] );
    with Item do
    begin
      ItemThumb := DirChild(IndexOfChildObjName( 'ImagePanel' )).DirChild(0).DirChild(0); // Image Thumbnaile
      if ItemThumb.ObjName <> 'EmptyImgStub' then
        SStubImg := format( ' StubImgName="%s"', [ItemThumb.ObjName] );
    end;

    with TN_UDCompVis(Item).PCCS()^ do
    ASL.Add( format( '<POS ID="%s" Left="%g" Top="%g" Width="%g" Height="%g"%s%s%s />',
               [Item.ObjName,BPCoords.X,BPCoords.Y,SRSize.X,SRSize.Y,
                SStubImg, SFlipRotate, STeethChart] ) );
  end;

  ASL.Add( '</CMStudyTemplate>' );
end; // procedure K_CMStudyTemplateUnloadDescr

//************************************** K_CMStudyTemplatePrepSampleMapRoot ***
// Prepare Sample MapRoot for Study Template Creation
//
//     Parameters
// ASampleUDMapRoot - resulting Sample Map Root UDBase
// Result - Returns TRUE if success
//
function  K_CMStudyTemplatePrepSampleMapRoot( out ASampleUDMapRoot : TN_UDBase ) : Boolean;
begin
//  ASampleUDMapRoot := K_CMEDAccess.ArchStudySamplesLibRoot.Owner;
  ASampleUDMapRoot := K_CMEDAccess.ArchStudySamplesInitLibRoot.Owner;
  ASampleUDMapRoot := ASampleUDMapRoot.DirChildByObjName( 'StudySampleBlanks' );
  if ASampleUDMapRoot <> nil then
  begin
    ASampleUDMapRoot := ASampleUDMapRoot.DirChildByObjName('EmptyStudySample');
    if ASampleUDMapRoot <> nil then
      ASampleUDMapRoot := ASampleUDMapRoot.DirChildByObjName('MapRoot');
  end;
  Result := ASampleUDMapRoot <> nil;
  if Result then Exit;
  N_Dump1Str( 'K_CMStudyTemplatePrepSampleMapRoot >> Sample MapRoot is nil' );
end; // K_CMStudyTemplatePrepSampleMapRoot

//************************************ K_CMStudyTemplatePrepStubImgUDFolder ***
// Prepare Stub Images for Study Template Creation
//
//     Parameters
// AStubImgUDFolder - resulting Sample Map Root UDBase
// Result      - Returns TRUE if loading is successful
//
function  K_CMStudyTemplatePrepStubImgUDFolder( out AStubImgUDFolder : TN_UDBase ) : Boolean;
begin
//  AStubImgUDFolder := K_CMEDAccess.ArchStudySamplesLibRoot.Owner.DirChildByObjName( 'StubImages' );
  AStubImgUDFolder := K_CMEDAccess.ArchStudySamplesInitLibRoot.Owner.DirChildByObjName( 'StubImages' );
  Result := AStubImgUDFolder <> nil;
  if Result then Exit;
  N_Dump1Str( 'K_CMStudyTemplatePrepStubImgUDFolder >> StubImages UDRoot is nil' );
end; // K_CMStudyTemplatePrepStubImgUDFolder

//********************************************** K_CMStudyTemplateLoadDescr ***
// Load Study Template Description from Strings
//
//     Parameters
// AUDTemplate - Study Template Root UDBase
// ASL         - Strings with Study Template Decription
// AIgnoreSelfIDs - if TRUE created template Items ObjName will be '0', '1', ..., 'N'
//                  else source Items ObjName will be used
// AOrderInds  - Template Resulting Positions Order array
// AFlipRotateCodes - Template Resulting FlipRotate Codes array (AFlipRotateCodes[i] = -1 means that XML FlipRotate Info should be used)
// ASampleUDMapRoot - Sample Map Root UDBase
// AStubImgUDFolder - Stub Images Root Folder
// Result      - Returns TRUE if loading is successful
//
function  K_CMStudyTemplateLoadDescr( AUDTemplate : TN_UDBase; ASL : TStrings;
                                      AIgnoreSelfIDs : Boolean;
                                      AOrderInds : TN_IArray = nil;
                                      AFlipRotateCodes : TN_IArray = nil;
                                      ASampleUDMapRoot : TN_UDBase = nil;
                                      AStubImgUDFolder : TN_UDBase = nil ) : Boolean;
var
  XMLUDRoot, XMLUDPos : TK_UDStringList;
  TemplateWidth, TemplateHeight, MinTLeft, MaxTWidth, MinTTop, MaxTHeight : Float;
  i, j, n, k : Integer;
  ItemThumbRootNum : Integer;
  PosRect : TFRect;
  WrongDataFlag : Boolean;
//  MainParent, NMPR, SMPIR, NMPIR, Thumbnail, WrkUDBase, UDDIB: TN_UDBase;
  ResUDMapRoot, SampleUDPos, CurUDPos, Thumbnail, StubUDDIB : TN_UDBase;
  WStr : string;
  TeethChart : Int64;
  FlipRotate : Integer;
  PUP: TN_POneUserParam;
begin
  Result := FALSE;
  // Atempt to define ASampleUDMapRoot
  if (ASampleUDMapRoot = nil) and
      not K_CMStudyTemplatePrepSampleMapRoot( ASampleUDMapRoot ) then Exit;

  // Atempt to define AStubImgUDFolder
  if (AStubImgUDFolder = nil) and
     not K_CMStudyTemplatePrepStubImgUDFolder( AStubImgUDFolder ) then Exit;

  // Load XML to Special UDTree
  XMLUDRoot := TK_UDStringList.Create;

  with K_SerialTextBuf do
  begin
    TextStrings.Clear;
    TextStrings.AddStrings( ASL );
    InitLoad1();
  end;

  K_ParseXMLFromTextBuf( XMLUDRoot );

  // Parse XML UDTree
  AUDTemplate.ClearChilds();

  if XMLUDRoot.ObjName =  'CMStudyTemplate'  then
  begin
//   ASL.Add( format( '<CMStudyTemplate ID="%s" Caption="%s" Width="%g" Height="%g">',
    AUDTemplate.ObjName := XMLUDRoot.SL.Values['ID'];
    AUDTemplate.ObjAliase := XMLUDRoot.SL.Values['Caption'];
    AUDTemplate.ObjInfo := XMLUDRoot.SL.Values['Info'];
    TemplateWidth  := StrToFloatDef( XMLUDRoot.SL.Values['Width'], 0 );
    TemplateHeight := StrToFloatDef( XMLUDRoot.SL.Values['Height'], 0 );
    n := XMLUDRoot.DirHigh;
    if AOrderInds <> nil then
      n := High( AOrderInds );

    // Create Sample MapRoot and Sample Position
    ResUDMapRoot := N_CreateSubTreeClone( ASampleUDMapRoot ); // Resulting UDMapRoot

   // Prepare Position UDTree Clone
    K_UDCursorGet('@Tmp:').SetRoot( ResUDMapRoot );
    SampleUDPos := ResUDMapRoot.DirChild( 0 ); // Position Sample

    AUDTemplate.AddOneChildV( ResUDMapRoot ); // Add Position UDMapRoot

    MinTLeft   := 100000;
    MaxTWidth  := 0;
    MinTTop    := 100000;
    MaxTHeight := 0;

    WrongDataFlag := FALSE;
    for i := 0 to n do
    begin
      j := i;
      if AOrderInds <> nil then
        j := AOrderInds[i];
      XMLUDPos := TK_UDStringList( XMLUDRoot.DirChild( j ) );

      if XMLUDPos = nil then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d is not found', [j] ) );
        WrongDataFlag := TRUE;
        Continue;
      end
      else
      if XMLUDPos.ObjName <> 'POS' then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d is not Pos description %s=%s',
                             [j, XMLUDPos.ObjName, XMLUDPos.SL.Text ] ) );
        WrongDataFlag := TRUE;
        Continue;
      end;


      PosRect.Left := StrToFloatDef( XMLUDPos.SL.Values['Left'], -1000 );
      if PosRect.Left = -1000 then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong Left', [j] ) );
        WrongDataFlag := TRUE;
        Continue;
      end;

      PosRect.Top := StrToFloatDef( XMLUDPos.SL.Values['Top'], -1000 );
      if PosRect.Top = -1000 then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong Top', [j] ) );
        WrongDataFlag := TRUE;
        Continue;
      end;

      PosRect.Right := StrToFloatDef( XMLUDPos.SL.Values['Width'], -1000 );
      if PosRect.Right = -1000 then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong Width', [j] ) );
        WrongDataFlag := TRUE;
        Continue;
      end;

      PosRect.Bottom := StrToFloatDef( XMLUDPos.SL.Values['Height'], -1000 );
      if PosRect.Bottom = -1000 then
      begin
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong Height', [j] ) );
        WrongDataFlag := TRUE;
        Continue;
      end;

      MinTLeft   := Min( MinTLeft, PosRect.Left );
      MinTTop    := Min( MinTTop, PosRect.Top );
      MaxTWidth  := Max( MaxTWidth, PosRect.Left + PosRect.Right );
      MaxTHeight := Max( MaxTHeight, PosRect.Top + PosRect.Bottom );

      ResUDMapRoot.RefPath := '@Tmp:';
      CurUDPos := N_CreateSubTreeClone( SampleUDPos ); // New Mounts Pattern Item Root

      // Define Item ID
      CurUDPos.ObjName := '';
      if not AIgnoreSelfIDs then
        CurUDPos.ObjName := XMLUDPos.SL.Values['ID'];

      if CurUDPos.ObjName = '' then
        CurUDPos.ObjName := IntToStr( j );

      CurUDPos.ObjALiase := 'Item' + CurUDPos.ObjName;

      with TN_UDCompVis(CurUDPos).PCCS()^ do // Set New Item TopLeft in Pixels
      begin
        BPCoords := PosRect.TopLeft; // FPoint( ItemsRects[ir].IRS.TopLeft );
        SRSize   := PosRect.BottomRight; // FPoint( ItemsRects[ir].IRS.Size );
      end; // with TN_UDCompVis(CurUDPos).PCCS()^ do // Set New Item TopLeft in Pixels

      // Define Position Order Index text
      ItemThumbRootNum := CurUDPos.IndexOfChildObjName( 'ImagePanel' );
      with TN_UDParaBox( CurUDPos.DirChild(ItemThumbRootNum).DirChild(2) ).PISP()^ do
        TN_POneTextBlock(CPBTextBlocks.P).OTBMText := IntToStr( i + 1 );

      // Define Stub Image
      WStr := XMLUDPos.SL.Values['StubImgName'];
      if WStr <> '' then
      begin
        StubUDDIB := AStubImgUDFolder.DirChildByObjName( WStr );
        if StubUDDIB <> nil then
          CurUDPos.DirChild(ItemThumbRootNum).DirChild(0).PutDirChildSafe( 0, StubUDDIB )
        else
        begin
          N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d StubImage "%s" is absent', [j,WStr] ) );
          WrongDataFlag := TRUE;
        end;
      end;

      ResUDMapRoot.AddOneChildV( CurUDPos );

      // Define Position Teeth Chart
      PUP := N_GetUserParPtr( TN_UDCompBase(CurUDPos).R, 'TeethFlags' );
      if PUP <> nil then
      begin
        TeethChart := 0;
        WStr := XMLUDPos.SL.Values['TeethChartC'];
        if WStr <> '' then
        begin // Use TeethChartC
          TeethChart := StrToInt64Def( WStr, -1 );
          if TeethChart = -1 then
          begin
            N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong TeethChartC=%s', [j, WStr] ) );
            WrongDataFlag := TRUE;
          end;
        end
        else
        begin
          WStr := XMLUDPos.SL.Values['TeethChart'];
          if WStr <> '' then // Use TeethChart
            TeethChart := K_CMSTeethChartTextToState( WStr, ',' );
        end;

        if TeethChart > 0 then
          PInt64(PUP.UPValue.P)^ := TeethChart
      end // if PUP <> nil then
      else
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d TeethChart is absent', [j] ) );

      // Define Position Flip|Rotate
      PUP := N_GetUserParPtr( TN_UDCompBase(CurUDPos).R, 'FlipRotateFlags' );
      if PUP <> nil then
      begin
        if (AFlipRotateCodes <> nil) and (AFlipRotateCodes[j] <> -1) then
          FlipRotate := AFlipRotateCodes[j]
        else
        begin // if (AFlipRotateCodes = nil) or (AFlipRotateCodes[j] = -1) then
          FlipRotate := 0;
          WStr := XMLUDPos.SL.Values['FlipRotateC'];
          if WStr <> '' then
          begin // Use FlipRotateC
            FlipRotate := StrToIntDef( WStr, -1 );
            if FlipRotate = -1 then
            begin
              N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d wrong FlipRotateC=%s', [j, WStr] ) );
              WrongDataFlag := TRUE;
            end;
          end   // Use FlipRotateC
          else
          begin // Check FlipRotateA
            WStr := XMLUDPos.SL.Values['FlipRotate'];
            if WStr <> '' then // Use FlipRotate
            begin
              k := 1;
              while k <= Length(WStr) do
              begin
                case WStr[k] of
                  'R':
                  begin
                    if k < Length(WStr) then // Precaution
                    begin
                      Inc(k);
                      FlipRotate := N_RotateFRFlags ( FlipRotate, (Ord(WStr[k]) - Ord('0')) * 90 );
                    end;
                  end;
                  'H': FlipRotate := FlipRotate xor N_FlipHorBit;
                  'V': FlipRotate := FlipRotate xor N_FlipVertBit;
                end;
                Inc(k);
              end; // while i <= Length(WStr) do
            end; // if WStr <> '' then // Use FlipRotateA
          end; // Check FlipRotateA
        end; // if (AFlipRotateCodes = nil) or (AFlipRotateCodes[j] = -1) then

        if FlipRotate > 0 then
          PByte(PUP.UPValue.P)^ := FlipRotate;

      end // if PUP <> nil then
      else
        N_Dump1Str( format( 'K_CMStudyTemplateLoadDescr Pos Number=%d TeethChart is absent', [j] ) );


    end; // for i := 0 to n - 1 do


//    AUDTemplate.AddOneChildV( ResUDMapRoot ); // Add Position UDMapRoot

    // Set MapRoot size
    if (TemplateWidth = 0) or (TemplateWidth < MaxTWidth ) then // Auto Width Calc
      TemplateWidth := MinTLeft + MaxTWidth;

    if (TemplateHeight = 0) or (TemplateHeight < MaxTHeight ) then // Auto Height Calc
      TemplateHeight := MinTTop + MaxTHeight;

    with TN_UDCompVis(ResUDMapRoot).PCCS()^.SRSize do
    begin
      X := TemplateWidth;
      Y := TemplateHeight;
    end;

    ResUDMapRoot.RemoveDirEntry(0); // Remove Sample UDPos

    // Add New Sample Thumbnail
    j := K_CMSlideThumbSize;
    K_CMSlideThumbSize := K_CMSlideThumbSize * 2;
    Thumbnail := K_CMBSlideCreateThumbnailUDDIB(
      K_CMBSlideCreateThumbnailDIBByMapRoot( TN_UDCompVis(ResUDMapRoot) ) );
    K_CMSlideThumbSize := j;
    AUDTemplate.InsOneChild( 0, Thumbnail);
    AUDTemplate.AddChildVNodes( 0 );

    Result := not WrongDataFlag;

  end; // if XMLUDRoot.ObjName =  'CMStudyTemplate'  then  // proper file format

  // Free Objects
  XMLUDRoot.UDDelete();

end; // function  K_CMStudyTemplateLoadDescr

//************************************************ K_CMStudyTemplateRebuild ***
// Rebuild Study Template Description from Strings
//
//     Parameters
// AUDTemplate - Study Template Root UDBase
// ASL         - Strings with Study Template Decription
// ASampleUDMapRoot - Sample Map Root UDBase
// AStubImgUDFolder - Stub Images Root Folder
// Result      - Returns TRUE if loading is successful
//
function K_CMStudyTemplateRebuild( AUDTemplate : TN_UDBase; ASL : TStrings;
                                   ASampleUDMapRoot : TN_UDBase = nil;
                                   AStubImgUDFolder : TN_UDBase = nil ) : Boolean;
var
  WStr : string;
  OrderIndsBuf, FlipRotateCodesBuf, FlipRotateInfoBuf  : TN_IArray;
  OrderInds, FlipRotateCodes : TN_IArray;
  i, FRCount, OrderIndsCount, PosCount : Integer;
begin
  PosCount := ASL.Count - 2;
  // Prepare Buffers
  SetLength(OrderIndsBuf,PosCount);
  SetLength(FlipRotateCodesBuf,PosCount);
  SetLength(FlipRotateInfoBuf,PosCount * 2);

  // Prepare AOrderInds
  WStr := N_MemIniToString( 'StudyTemplatesPosOrder', AUDTemplate.ObjName, '' );
  OrderInds := nil;
  if WStr <> '' then
  begin
    N_Dump2Str( 'Order:' + WStr );
    OrderIndsCount := N_ScanIArray( WStr, OrderIndsBuf );
    OrderInds := Copy( OrderIndsBuf, 0, OrderIndsCount );
  end; // if WStr <> '' then

  // Prepare AFlipRotateCodes
  FlipRotateCodes := nil;
  WStr := N_MemIniToString( 'StudyTemplatesPosFlipRotate', AUDTemplate.ObjName, '' );
  if WStr <> '' then
  begin
    N_Dump2Str( 'FlipRotate:' + WStr );
    FRCount := N_ScanIArray( WStr, FlipRotateInfoBuf );
                                     {number of positions}
    FillChar( FlipRotateCodesBuf[0], PosCount * SizeOf(Integer), - 1 );
    i := 0;
    while i < FRCount do
    begin
      FlipRotateCodesBuf[FlipRotateInfoBuf[i]] := FlipRotateInfoBuf[i+1];
      Inc(i, 2);
    end;
    FlipRotateCodes := FlipRotateCodesBuf;
  end; // if WStr <> '' then

  Result := K_CMStudyTemplateLoadDescr( AUDTemplate, ASL, FALSE, OrderInds, FlipRotateCodes,
                              ASampleUDMapRoot, AStubImgUDFolder );
end; // function K_CMStudyTemplateRebuild

//***************************************************** K_CMLoadUserStrings ***
// Load User Strings from DB
//
procedure K_CMLoadUserStrings();
begin
  K_CMEDAccess.EDANotGAGlobalToCurState();
end;

//***************************************************** K_CMLoadUserStrings ***
// Save User Strings to DB
//
procedure K_CMSaveUserStrings();
begin
  K_CMEDAccess.EDANotGAGlobalToMemIni1();
end;

//***************************************************** K_CMLoadUserStrings ***
// Get User String Value by given User String Name
//
//     Parameters
// AUStrName - User String Name
// Result    - Returns User String Value
//
function  K_CMGetUserString( const AUStrName : string ) : string;
begin
  Result := N_MemIniToString( 'CMS_USettings', AUStrName, '' );
end; // function  K_CMGetUserString

//****************************************************** K_CMLoadUserString ***
// Set new Value to string with given User String Name
//
//     Parameters
// AUStrName  - User String Name
// AUStrValue - User String Value
//
procedure K_CMSetUserString( const AUStrName, AUStrValue : string );
begin
  N_StringToMemIni( 'CMS_USettings', AUStrName, AUStrValue );
end; // procedure K_CMSetUserStrings


//***************************************************** K_CMFSBuildOneFList ***
// Build one files list by given CMSuite Files Storage Root Folder
//
//     Parameters
// ARootFolderName - Root folder Name
// ASkipFolderName - Skip Folder Name
// AFlags          - build list flags
//
procedure K_CMFSBuildOneFList( const ARootFolderName, ASkipFolderName : string;
                                   AFlags : TK_CMFSBuildFilesListFlags );
var
  i : Integer;
begin
  K_ScanFilesTreeMaxLevel := 4;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    TmpStrings.Clear;
    TmpStrings.Sorted := FALSE;
    SkipDataFolder := ARootFolderName + ASkipFolderName;
    RelPathStartInd := 0;
    if K_fsbflUseRelFName in AFlags then
      RelPathStartInd := 1 + Length(ARootFolderName);
    K_ScanFilesTree( ARootFolderName, EDASelectDataFiles, '*.*' );

    // Remove Patients Data Actual TimeStamp files
    for i := TmpStrings.Count - 1 downto 0 do
      if TmpStrings[i][Length(TmpStrings[i])] = '!' then
        TmpStrings.Delete(i)
      else
        if K_fsbflUseExtrFName in AFlags then
          TmpStrings[i] := ExtractFileName(TmpStrings[i]);
    RelPathStartInd := 0;
    SkipDataFolder := '';
  end;
  K_ScanFilesTreeMaxLevel := 0;
end; // procedure K_CMFSBuildOneFList

//***************************************************** K_CMFSBuildOneFList ***
// Build CMSuite Files Storage Existed Files List
//
//     Parameters
// AImgFL   - Img and studies files list
// AVideoFL - Video files list
// AImg3DFL - Img3D folders list
// AFlags   - build list flags
//
procedure K_CMFSBuildExistedFLists( AImgFL, AVideoFL, AImg3DFL: TStrings;
                                AFlags : TK_CMFSBuildFilesListFlags );
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    K_CMFSBuildOneFList( SlidesImgRootFolder, K_BadImg, AFlags );
    TmpStrings.Sort;
    AImgFL.Clear();
    AImgFL.AddStrings(TmpStrings);

    K_CMFSBuildOneFList( SlidesMediaRootFolder, K_BadVideo, AFlags );
    TmpStrings.Sort;
    if AVideoFL <> AImgFL then
    begin
      AVideoFL.Clear();
      AVideoFL.AddStrings(TmpStrings);
    end
    else
      AImgFL.AddStrings(TmpStrings);

    K_CMFSBuildOneFList( SlidesImg3DRootFolder, K_BadImg3D, AFlags );
    TmpStrings.Sort;
    if AImg3DFL <> AImgFL then
    begin
      AImg3DFL.Clear();
      AImg3DFL.AddStrings(TmpStrings);
    end
    else
      AImgFL.AddStrings(TmpStrings);

    TmpStrings.Sorted := FALSE;

  end;
end; // procedure K_CMFSBuildExistedFLists

//************************************************* K_CMFSBuildNeededFLists ***
// Build CMSuite Files Storage Needed Files List
//
//     Parameters
// AImgFL    - Img and studies files list
// AVideoFL  - Video files list
// AImg3DFL  - Img3D folders list
// AAImgFL   - Archived Img and studies files list
// AAVideoFL - Archived Video files list
// AAImg3DFL - Archived Img3D folders list
// AFlags    - build list flags
// ADSet     - ADO data set to select media objects
// AProgressProc - procedure of object to show progress
//
procedure K_CMFSBuildNeededFLists( AImgFL, AVideoFL, AImg3DFL: TStrings;
                                   AAImgFL, AAVideoFL, AAImg3DFL: TStrings;
                                   AFlags : TK_CMFSBuildFilesListFlags;
                                   ADSet : TADOQuery;
                                   AProgressProc : TK_CMFSBuildNeededProc );
var
  FPath, FName, FName1 : string;
  SQLStr : string;
  LPatPath : string;
  LDTPath : string;
  PrevPat : Integer;
  PrevDate : TDateTime;
  AllCount, FProcCount : Integer;
  i : Integer;
  CMSDB   : TN_CMSlideSDBF;
  SSlideID : string;
  FImgFL: TStrings;

label ContSlidesLoop;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), ADSet do
  begin
    // Existing Slides Loop
    SQLStr := 'select ' +
          K_CMENDBSTFSlideID   + ',' +       // 0
          K_CMENDBSTFPatID     + ',' +       // 1
          K_CMENDBSTFSlideDTCr + ',' +       // 2
          K_CMENDBSTFSlideSysInfo;           // 3
    if K_CMEDDBVersion >= 24 then
      SQLStr := SQLStr + ','+ K_CMENDBSTFSlideStudyID;   // 4
    if K_CMEDDBVersion >= 41 then
      SQLStr := SQLStr + ','+ K_CMENDBSTFSlideThumbnail; // 5
    SQL.Text := SQLStr + ' from ' + K_CMENDBSlidesTable +
                ' order by ' + K_CMENDBSTFPatID + ',' + K_CMENDBSTFSlideDTCr + ';';
//                  ' where (' + K_CMENDBSTFSlideFlags + ' & 0x2) = 0 ' +
//                  ' order by ' + K_CMENDBSTFPatID + ',' + K_CMENDBSTFSlideDTCr + ';';
    Filtered := false;
    Open;
    AllCount := RecordCount;

    FProcCount := 0;
    LPatPath := '';
    LDTPath  := '';

    if AllCount > 0 then
    begin
      PrevPat := -1000000000;
      PrevDate := 0;
      First();
      while not Eof do
      begin
ContSlidesLoop: //**********
//        Screen.Cursor := crHourglass;
        // Slide Processing
        for i := 0 to 9 do
        begin
          if FProcCount = AllCount then break; //

          SSlideID := FieldList[0].AsString;
//if SSlideID = '46817' then
//SSlideID := '46817';

          if not (K_fsbflUseExtrFName in AFlags) then
          begin
            if (PrevPat <>  Fields[1].AsInteger) or (LPatPath = '') then
              LPatPath := K_CMSlideGetPatientFilesPathSegm( Fields[1].AsInteger );

            if PrevDate <> Fields[2].AsDateTime then
              LDTPath := K_CMSlideGetFileDatePathSegm( Fields[2].AsDateTime );
          end;

          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);

          FName1 := '';
          if cmsfIsMediaObj in CMSDB.SFlags then
          begin // Video
            FName := '';
            if not (K_fsbflUseExtrFName in AFlags) and not (K_fsbflUseRelFName in AFlags) then
              FName := SlidesMediaRootFolder;
            FName := FName + LPatPath + LDTPath + K_CMSlideGetMediaFileNamePref(SSlideID) + CMSDB.MediaFExt;
            if (K_CMEDDBVersion >= 41) and (FieldList[5].IsNull) then
              AAVideoFL.Add( FName )
            else
              AVideoFL.Add( FName );
          end
          else
          if cmsfIsImg3DObj in CMSDB.SFlags then
          begin // 3D Image
// 2020-07-28 add Capt3DDevObjName <> ''  if CMSDB.Capt3DDevObjName = '' then
// 2020-09-25 add new condition for Dev3D objs
            if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
            begin
              FName := '';
              if not (K_fsbflUseExtrFName in AFlags) and not (K_fsbflUseRelFName in AFlags) then
                FName := SlidesImg3DRootFolder;
              FName := FName + LPatPath + LDTPath + K_CMSlideGetImg3DFolderName(SSlideID);
              if (K_CMEDDBVersion >= 41) and (FieldList[5].IsNull) then
                AAImg3DFL.Add( FName )
              else
                AImg3DFL.Add( FName );
            end
          end
          else
          begin // Image or study
            FPath := '';
            if not (K_fsbflUseExtrFName in AFlags) and not (K_fsbflUseRelFName in AFlags) then
              FPath := SlidesImgRootFolder;
            FPath := FPath + LPatPath + LDTPath;
            if (K_CMEDDBVersion >= 24) and (Fields[4].AsInteger < 0) then
            // Study
              FName := FPath + K_CMStudyGetFileName(SSlideID)
            else
            begin
            // Image
              FName := FPath + K_CMSlideGetCurImgFileName(SSlideID);
              if cmsfHasSrcImg in CMSDB.SFlags then
                FName1 := FPath + K_CMSlideGetSrcImgFileName(SSlideID);
            end; // Image
            FImgFL := AImgFL;
            if (K_CMEDDBVersion >= 41) and (FieldList[5].IsNull) then
             FImgFL := AAImgFL;

            FImgFL.Add( FName );
            if FName1 <> '' then
              FImgFL.Add( FName1 );
          end;

          Inc(FProcCount);
          Next();
        end; // for i := 0 to 9 do
        if Assigned(AProgressProc) then
          AProgressProc( AllCount, FProcCount );
      end; // while not Eof do
    end; // if AllCount > 0 then

    Close();
  end; // with TK_CMEDDBAccess(K_CMEDAccess), ADSet do
end; // procedure K_CMFSBuildNeededFLists

//******************************************* K_CMFSCompNeededExistedFLists ***
// Compare CMSuite Files Storage Needed and Existed File Lists
//
//     Parameters
// AExistedFL - existed files list on input extra files on output
// ANeededFL  - needed  files list on input missing files on output
// AProgressProc - procedure of object to show progress
//
procedure K_CMFSCompNeededExistedFLists( AExistedFL, ANeededFL : TStringList;
                                     AProgressProc : TK_CMFSBuildNeededProc );
var
  AllCount, FProcCount, FInd, i : Integer;
  WasSorted : Boolean;
begin
  AllCount := ANeededFL.Count;
  FProcCount := 0;
  WasSorted := AExistedFL.Sorted;
  if not WasSorted then
    AExistedFL.Sort();
  for i := AllCount - 1 downto 0 do
  begin
    if AExistedFL.Find( ANeededFL[i], FInd ) then
    begin
      AExistedFL.Delete( FInd );
      ANeededFL.Delete( i );
    end;
    Inc(FProcCount);
    if Assigned(AProgressProc) and ((FProcCount mod 10) = 0) then
      AProgressProc( AllCount, FProcCount );
  end; // for i := AllCount - 1 := 0 downto 0 do
  if not WasSorted then
    AExistedFL.Sorted := FALSE;
end; // procedure K_CMFSCompNeededExistedFLists

//************************************************* K_CMInitMouseMoveRedraw ***
// Initialized MouseMoveRedraw by Location
//
procedure K_CMInitMouseMoveRedraw();
var
  IUMouseState : string;
begin
  N_Dump2Str( 'K_CMInitMouseMoveRedraw start' );
  if K_CMEDAccess.CurLocID = -1 then Exit; // precation
  IUMouseState := N_MemIniToString( 'CMIUMouseState', IntToStr(K_CMEDAccess.CurLocID), '' );
  N_Dump1Str( 'K_CMInitMouseMoveRedraw >> ' + IUMouseState );

  if K_CMVUIMode and (IUMouseState = '') then
  begin // Init  MouseMove settings for WEB mode
    K_CMEDAccess.TmpStrings.CommaText := N_MemIniToString( 'CMS_UserMain', 'MouseDelayList', '0.2,0.4,0.6,0.8,1.0' );
    IUMouseState := '1|' + K_CMEDAccess.TmpStrings[0];
    N_Dump1Str( 'K_CMInitMouseMoveRedraw >> Init by ' + IUMouseState );
  end;

  if (IUMouseState = '') or (IUMouseState[1] = '0') then
    K_CMSkipMouseMoveRedraw := 0
  else
  begin
    K_CMSkipMouseMoveRedraw := 2;
    K_CMRedrawObject.InitCheckAttrsByTime(
        StrToFloat( Copy( IUMouseState, 3, Length(IUMouseState) ) ),
        0.9 );
  end;
end; // procedure K_CMInitMouseMoveRedraw

//******************************************* K_CMFSCompNeededExistedFLists ***
// Export one 3D object DICOM layer files to specified folder
//
//     Parameters
// ASlide    - exported slide
// ARPath    - resulting folder
// ARCount   - resulting real export Counter
// AAllCount - resulting all export Counter
// ASize     - resulting copy files size
// Result    - Returns 0 - OK, 1 - not proper Export Data Path inside 3D object
//
function K_CMExport3DObj( ASlide : TN_UDCMSlide; const ARPath, ASPath : string;
                          var ARCount, AAllCount : Integer; var ASize : Int64 ) : Integer;
var
  FPath : string;
  Folder3D : string;
  JL : TObjectList;
  RCount, Res, i : Integer;
  FSize : Int64;

begin
  FPath := IncludeTrailingPathDelimiter(ARPath);
  Result := 1;
  Folder3D := ASPath + 'SrcFiles\';
  if not DirectoryExists( Folder3D ) then
    Exit
  else
  if DirectoryExists( Folder3D + 'Data\' ) then
  begin
    Folder3D := Folder3D + 'Data\';
    JL := N_CreateFilesList( Folder3D + '*.*' );
    JL.OwnsObjects := FALSE;
    if JL.Count = 1 then
    begin
      with TN_FileAttribs( JL[0] ) do
        if (AttrFlags and faDirectory) <> 0 then
        begin
          Folder3D := IncludeTrailingPathDelimiter(FullName);
          JL.Free;
        end
        else
        begin
          JL.Free;
          Exit;
        end;
    end   // if JL.Count = 1 then
    else
    begin // if JL.Count <> 1 then
      JL.Free;
      Exit;
    end;  // if JL.Count <> 1 then
  end; // if DirectoryExists( Folder3D + 'Data\' ) then

  // Clear Dest Files
  Result := 0;
  K_DeleteFolderFiles( FPath );

  // Prepare Src Files
  JL := N_CreateFilesList( Folder3D + '*.*' );
  JL.OwnsObjects := FALSE;

  // Copy files loop
  RCount := 0;
  FSize := 0;
  for i := 0 to JL.Count-1 do
  with TN_FileAttribs( JL[i] ) do
  begin
    if (AttrFlags and faDirectory) <> 0 then Continue;

    // Copy current level file
    Res := K_CopyFile( FullName, FPath + ExtractFileName(FullName) );
    if Res = 0 then
    begin
      Inc( RCount );
      FSize := FSize + BSize;
    end
    else
    begin
      if not CMS_LogsCtrlAll then
        FullName := '';
      N_Dump1Str( format( 'K_CMExport3DObj copy error %d >> %s',[Res,FullName] ) );
    end;
  end; // for, with
  ARCount   := ARCount + RCount;
  AAllCount := AAllCount + JL.Count;
  ASize     := ASize + FSize;
  JL.Free;
end; // function K_CMExport3DObj

//Finalization
{
K_3DASL.Free;
K_3DAML1.Free;
K_3DAML2.Free;
K_3DAML3.Free;
K_3DAUDRoot.UDDelete();
}
end.
