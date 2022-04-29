unit K_FCMDBRecovery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types,
  K_CLib0;

type
  TK_FormCMDBRecovery = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    LbEDErrCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    BtReport: TButton;
    StatusBar: TStatusBar;
    ChBAddDuplicated: TCheckBox;
    ChBShowWarning: TCheckBox;
    FlistTimer: TTimer;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure BtReportClick(Sender: TObject);
    procedure FlistTimerTimer(Sender: TObject);
  private
    { Private declarations }
    ReportSMatr: TN_ASArray;
    ReportCount : Integer;
    StartMSessionTS : TDateTime;
    SavedCursor: TCursor;
    FilesList : TStringList;
    StudiesFList : TStringList;
    Img3DFList : TStringList;

    CheckLostFilesFlag : Boolean;
    ProcessStudiesFilesFlag : Boolean;
    ProcessImg3DFoldersFlag : Boolean;
    ReportIsNeededFlag : Boolean;
    RecoveryFinishFlag : Boolean;

    SessionIDs : TList;
    PatientIDs : TList;
    SlideIDs   : TList;
    SlideTypes : TList;

    procedure AddRepInfo( APatientInfo, ASlideInfo, AErrInfo : string;
                          ACountErrors : Boolean = FALSE );
    procedure CalcMaxSlideID( AList : TStrings );
  public
    { Public declarations }
    ErrCount, MoveImageCount, MoveVideoCount, MoveImg3DCount, AllCount, RecCount,
    FProcCount, OutOfMemoryCount,
    StudiesCount, MovedBeforeStudiesCount, AddDuplicatedCount  : Integer;
    AddDuplicatedObjectsAsNew : Boolean;
    NewSlideID : Integer;
    FWarnRepCounter  : Integer;
  end;

var
  K_FormCMDBRecovery: TK_FormCMDBRecovery;

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_UDT1, K_UDC, K_UDConst, K_SBuf, K_CM0, K_CM1, K_FCMReportShow, K_Script1, {K_FEText,}
  K_STBuf,
  N_CompBase, N_Comp1, N_Lib1, N_Lib2, N_Video, N_ClassRef, N_CMMain5F, K_CML1F;

const K_BadImg   = 'Bad images';
const K_BadVideo = 'Bad video';
const K_BadImg3D = 'Bad 3D images';

{
//***************************************** TK_FormCMDBRecovery.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMDBRecovery.FormCreate(Sender: TObject);
begin
  inherited;
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
     //////////////////////////////////////
     // Get DB Slides Count
     //
      Filtered := FALSE;
      SQL.Text := 'select Count(*) from ' + K_CMENDBSlidesTable;
      Open;
      RecCount := FieldList[0].AsInteger;
      Close();
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMDBRecovery.FormCreate ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;
//
end; // TK_FormCMDBRecovery.FormCreate
}

//***************************************** TK_FormCMDBRecovery.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMDBRecovery.FormShow(Sender: TObject);
begin
  inherited;
// Code Moved from FormCreate
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
     //////////////////////////////////////
     // Get DB Slides Count
     //
      Filtered := FALSE;
      SQL.Text := 'select Count(*) from ' + K_CMENDBSlidesTable;
      Open();
      RecCount := FieldList[0].AsInteger;
      Close();
{
      if AddDuplicatedObjectsAsNew then
      begin
        SQL.Text := 'select MAX('+ K_CMENDBSTFSlideID +') from ' + K_CMENDBSlidesTable;
        Open();
        NewSlideID := FieldList[0].AsInteger + 1;
        Close();
      end;
}
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMDBRecovery.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;
// end of Code Moved from FormCreate

  BtReport.Enabled := FALSE;
  BtStart.Enabled := FALSE;
  if RecCount > 0 then
    BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]  //'Resume'
  else
    BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';


  FlistTimer.Enabled := TRUE;
  
{ // this code is moved to the FlistTimerTimer
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin

   //////////////////////////////////////
   // Build Media Objects Files List
   //
    TmpStrings.Clear;
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    StatusBar.SimpleText := ' Build image files list ...';
    SkipDataFolder := SlidesImgRootFolder + K_BadImg;
    K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'RF_????????.cmi' );
    StatusBar.SimpleText := ' Build video files list ...';
    SkipDataFolder := SlidesMediaRootFolder + K_BadVideo;
    K_ScanFilesTree( SlidesMediaRootFolder, EDASelectDataFiles, 'MF_????????.*' );
    SkipDataFolder := '';
    FilesList := TStringList.Create;
    FilesList.Assign( TmpStrings );

    TmpStrings.Clear;
    StatusBar.SimpleText := ' Build studies files list ...';
    SkipDataFolder := SlidesImgRootFolder + K_BadImg;
    K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'SF_????????.cma' );
    SkipDataFolder := '';
    StudiesFList := TStringList.Create;
    StudiesFList.Assign( TmpStrings );

    TmpStrings.Clear;
    StatusBar.SimpleText := ' Build 3D images folders list ...';
    SkipDataFolder := SlidesImg3DRootFolder + K_BadImg3D;
    K_ScanFilesTree( SlidesImg3DRootFolder, EDASelectDataFiles, '3F_????????', TRUE );
    SkipDataFolder := '';
    Img3DFList := TStringList.Create;
    Img3DFList.Assign( TmpStrings );

    StatusBar.SimpleText := '';
    Screen.Cursor := SavedCursor;
    AllCount := FilesList.Count + StudiesFList.Count + Img3DFList.Count;

    LbEDBMediaCount.Text := IntToStr( AllCount );
    LbEDProcCount.Text := IntToStr( RecCount );
    PBProgress.Max := 1000;
    PBProgress.Position := 0;
    if AllCount > 0 then
      PBProgress.Position := Round(1000 * RecCount / AllCount);

    AddRepInfo( 'Patient ID', 'File path', 'Error type' );

    // Init Sessions and corresponding Patients List
    SessionIDs := TList.Create;
    SessionIDs.Add( Pointer(CurSessionHistID) );
    PatientIDs := TList.Create;
    SlideIDs   := TList.Create;
    SlideTypes := TList.Create;
    PatientIDs.Add( Pointer(CurPatID) );
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
}
end; // TK_FormCMDBRecovery.FormShow

//***************************************** TK_FormCMDBRecovery.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMDBRecovery.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//var
//  i, j : Integer;

  procedure ClearRecoveryMode();
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
{
      if K_CMEDAMSSQL then
      begin
        CommandText := 'SET IDENTITY_INSERT ' + K_CMENDBSlidesTable + ' OFF';
        Execute;
      end   // if K_CMEDAMSSQL then
      else
      begin // if not K_CMEDAMSSQL then
        if K_CMEDDBVersion < 40 then
        begin
          CommandText := 'ALTER TABLE ' + K_CMENDBSlidesTable +
                         ' MODIFY ' + K_CMENDBSTFSlideID +
                         ' DEFAULT GLOBAL AUTOINCREMENT (10000000)';
          Execute;
          N_Dump1Str( 'RDB>> Restore GLOBAL AUTOINCREMENT' );
        end
      end;
}
      if K_CMEDDBVersion < 40 then
      begin
        CommandText := 'ALTER TABLE ' + K_CMENDBSlidesTable +
                       ' MODIFY ' + K_CMENDBSTFSlideID +
                       ' DEFAULT GLOBAL AUTOINCREMENT (10000000)';
        Execute;
        N_Dump1Str( 'RDB>> Restore GLOBAL AUTOINCREMENT' );
      end   // if K_CMEDDBVersion < 40 then
      else
      begin // if K_CMEDDBVersion >= 40 then
        // Calc by DB existing records
        with CurSlidesDSet do
        begin
          SQL.Text := 'select MAX('+ K_CMENDBSTFSlideID +') from ' + K_CMENDBSlidesTable;
          Open();
          NewSlideID := FieldList[0].AsInteger + 1;
          Close();
        end;

        CommandText := 'ALTER SEQUENCE dba.NextSlideID RESTART WITH ' + IntToStr(NewSlideID);
        Execute;
        N_Dump1Str( 'RDB>> Set NewSlide.NextID=' + IntToStr(NewSlideID) );

        CommandText := 'UPDATE ' + K_CMENDBGlobAttrsTable +
        ' SET ' + K_CMENDBGTFSAFlags + ' = ' + K_CMENDBGTFSAFlags +' ^ 8;';
        Execute;
        N_Dump1Str( 'RDB>> Clear DB recovery mode' );
      end;
    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do

    K_CMSDBRecoveryMode := FALSE;

  end; // procedure ClearRecoveryMode();

begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; // 'Pause'
  if CanClose then
  begin
    if RecoveryFinishFlag then
    begin
      ClearRecoveryMode();
    end;
    if ReportIsNeededFlag and
       ( mrOK = K_CMShowMessageDlg( K_CML1Form.LLLReport9.Caption,
//         'You have unsaved errors report. Press OK to save report data.',
         mtConfirmation, [mbOK, mbCancel] ) ) then
      BtReportClick(Sender);
  end
  else
  begin
    CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLDBRecovery1.Caption,
//      'Do you really want to break DB recovery procedure?',
                        mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'RDB>> Break by user ' );
  end;

  if not CanClose then Exit;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    CurSessionHistID := Integer(SessionIDs[0]);
    CurPatID         := Integer(PatientIDs[0]);

    // Clear CurDSet1 and CurDSet2 use context
    if CurDSet1.Active then CurDSet1.Close;
    if CurDSet2.Active then CurDSet2.Close;
    CurDSet1.Filtered := FALSE;
    CurDSet2.Filtered := FALSE;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  FilesList.Free;
  Img3DFList.Free;
  StudiesFList.Free;
  SessionIDs.Free;
  PatientIDs.Free;
  SlideIDs.Free;
  SlideTypes.Free;

end; // TK_FormCMDBRecovery.FormCloseQuery

//***************************************** TK_FormCMDBRecovery.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMDBRecovery.BtStartClick(Sender: TObject);
var
  FPath1, FPath, FName, FName1, AttrsFName, DuplicatedSlideID,
  FPath2, RPath2, RPath2Suf : string;
  i, DSize : Integer;
  UDDIB1, UDDIB : TN_UDDIB;
  PCMSlide : TN_PCMSlide;
  AttrsSlide : TN_UDCMSlide;
  CMSlide : TN_UDCMSlide;
  CMStudy : TN_UDCMStudy;
  PData : Pointer;
  OpRes : TK_CMEDResult;
  SFSlideID : string;
  SFSlidePatID : string;
  SFSlideCrDate : TDateTime;
  FieldsCtrlFlags : TK_CMEDASelectFieldsFlags;
  FileErrText : string;
  FSize : Integer;
  SPatID: string;
  VFInfo: TN_VideoFileInfo;
  ResText : string;
  HistActCode : Integer;
  BadImgFolder, BadVideoFolder, BadImg3DFolder : string;
  FStream : TFileStream;
  DFile: TK_DFile;
  AttrsState : Integer;
  ParseFileState : Integer;
  ParseSlideType : Integer;   // 0 - Image, 1 - Video, 2 - Img3D, 3 -study
  Check3DRes : Integer;
  DIBOutOfMemory : Boolean;


//label ContLoop, FileError, FinExit;
label ContLoop, ContLoop1, ImgOutOfMemory, ImgFileError, CheckLostFiles, FinExit, FinExit0,
      ProcessStudiesFiles, ContLoop2, ProcessImg3DFolders, ContLoop0;

  function LoadUDDIB( const AFileName : string ) : TN_UDDIB;
  begin
    // Load DIB
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      DIBOutOfMemory := FALSE;
      OpRes := K_edFails;
      Result := nil;
      try
        OpRes := EDASlideDataFromFile( PData, DSize, AFileName, FSize );
        if OpRes <> K_edOK then
          N_Dump1Str( 'RDB>> Image File Error >> ' + ExtDataErrorString )
        else
        begin
          Result := K_CMCreateUDDIBBySData( PData, DSize, EDAFreeBuffer );
{
          N_SerialBuf.LoadFromMem( PData^, DSize );
          Result := TN_UDDIB(K_LoadTreeFromMem(N_SerialBuf));
}
          if Result = nil then
            N_Dump1Str( 'RDB>> Image File "' + AFileName + '" deserialization error' )
          else
          begin
            Result.LoadDIBObj();
            Result.ClassFlags := Result.ClassFlags + K_SkipSelfSaveBit;
          end;
        end;
      except
        on E: Exception do begin
          DIBOutOfMemory := Pos( 'memory', E.Message ) > 0;
          FreeAndNil( Result ); // needed if exception in Result.LoadDIBObj();
          N_Dump1Str( 'RDB>> Image File Error >> ' + E.Message );
        end
      end;
    end;

  end; // function LoadUDDIB

  procedure AddCurrentUDDIB( AUDDIB : TN_UDDIB );
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CMSlide, PCMSlide^ do
    begin
      // Add Current Image
      PutDirChildSafe(K_CMSlideIndCurImg, AUDDIB );

      if  AttrsState <> 1 then
      begin
        // Create MapRoot
        with AUDDIB.DIBObj.DIBInfo.bmi do // Add File UDDIB as MapImage
  //        CreateMapRoot( biWidth, biHeight ).PutDirChildSafe(K_CMSlideMRIndMapImg, AUDDIB );
          CreateMapRoot( biWidth, biHeight );

        // Get DIB Attrs to Slide Fields
        K_CMSlideSetAttrsByDIB( PCMSlide, AUDDIB.DIBObj, FALSE );

        CMSDB.DUnits := TN_CMSlideDUnits(N_MemIniToInt('VObjAttrs',
          'DistanceUnits', 0));
      end;
      // Create Thumbnail
      CreateThumbnail();

    end;
  end; // procedure AddCurrentUDDIB

  procedure SaveSlideToDB();
  begin
          // Save Slide Data
    with TK_CMEDDBAccess(K_CMEDAccess), CurSlidesDSet do
    begin
      Connection := LANDBConnection;

      Connection.BeginTrans;

      ExtDataErrorCode := K_eeDBSelect;
      SQL.Text := 'select ' +
        EDAGetSlideSelectFieldsStr( FieldsCtrlFlags ) +
        ' from ' + EDAGetSlideSelectFromStr( ) +
        ' where ' +  K_CMENDBSTFSlideID + ' = -1'  +
        K_CMEDAGetSlideSelectWhereStr( K_swfSkipFlagsCond );
//        EDAGetSlideSelectWhereStr( K_swfSkipFlagsCond );
      Filtered := false;
      Open;

      ExtDataErrorCode := K_eeDBIns;
      Insert;
      FieldList.Fields[0].AsString := CMSlide.ObjName;
      FieldList.Fields[1].AsInteger := PCMSlide.CMSPatId;
      SlideIDs.Add( TObject(FieldList.Fields[0].AsInteger) );
      SlideTypes.Add( TObject(ParseSlideType) );
      Include( PCMSlide.CMSRFlags, cmsfIsNew );
      CurSlide := CMSlide;
      EDASaveSlideFields();
      EDASaveSlideThumbnail();
      if AttrsState <> 1 then
        EDASaveSlideAttrsToFile( FALSE );
      if K_sffAddMapRootField in FieldsCtrlFlags then
        EDASaveSlideMapRoot();
      UpdateBatch();
      Close();

      with CurSQLCommand1 do
      begin // Remove recoverd object from MarkedAsDeleted Table
        Connection := LANDBConnection;
        CommandText := 'DELETE FROM ' + K_CMENDBDelMarkedSlidesTable +
                       ' WHERE ' + K_CMENDMSlideID + ' = ' + CMSlide.ObjName;
        Execute;
      end;

      Connection.CommitTrans;
      Inc(RecCount);
      if K_CMEDDBVersion >= 13 then
      begin
        HistActCode := EDABuildHistActionCode( K_shATChange, Ord(K_shCADBRecovery), HistActCode );
        EDASaveSlidesListHistory( @CMSlide, 1, HistActCode )
      end;
    end; // with CurSlidesDSet do
  end; // procedure SaveSlideToDB();

  procedure SaveStudyToDB();
  begin
          // Save Slide Data
    with TK_CMEDDBAccess(K_CMEDAccess), CurSlidesDSet do
    begin
      Connection := LANDBConnection;

      EDAStudySavingStart();

      ExtDataErrorCode := K_eeDBSelect;
      SQL.Text := 'select ' +
        EDAGetSlideSelectFieldsStr( [K_sffAddThumbField,K_sffAddStudyOnlyFields] ) +
        ' from ' + EDAGetSlideSelectFromStr( ) +
        ' where ' +  K_CMENDBSTFSlideID + ' = -1'  +
        K_CMEDAGetSlideSelectWhereStr( K_swfSkipFlagsCond );
//        EDAGetSlideSelectWhereStr( K_swfSkipFlagsCond );
      Filtered := false;
      Open;

      ExtDataErrorCode := K_eeDBIns;
      Insert;
      FieldList.Fields[K_CMENDBSTFSlideIDInd].AsString := CMStudy.ObjName;
      FieldList.Fields[K_CMENDBSTFPatIDInd].AsInteger  := PCMSlide.CMSPatId;
      FieldList.Fields[K_CMENDBSTFSlideStudyIDInd].AsInteger   := - CMStudy.CMSStudySampleID;
      FieldList.Fields[K_CMENDBSTFSlideStudyItemInd].AsInteger := CMStudy.CMSStudyItemsCount;
      SlideIDs.Add( TObject(FieldList.Fields[0].AsInteger) );
      SlideTypes.Add( TObject(ParseSlideType) );
      Include( PCMSlide.CMSRFlags, cmsfIsNew );
      CurSlide := TN_UDCMSlide(CMStudy);

      EDAStudySaveFields();
      EDASaveSlideThumbnail();

      UpdateBatch();
      Close();

      EDAStudySavingFinish();

      Inc(RecCount);
      if K_CMEDDBVersion >= 13 then
      begin
        HistActCode := EDABuildHistActionCode( K_shATChange, Ord(K_shCADBRecovery), Ord(K_shRDBCreate) );
        EDASaveSlidesListHistory( @CurSlide, 1, HistActCode )
      end;
    end; // with CurSlidesDSet do
  end; // procedure SaveStudyToDB();

  function ParseSlidePatientID( ) : string;
  var
    WStr : string;
    i1 : Integer;
  begin
    WStr := ExtractFilePath( ExcludeTrailingPathDelimiter(FPath1) );
    WStr := ExtractFileName( ExcludeTrailingPathDelimiter(WStr) );
    i1 := 4;
    while WStr[i1] = '0' do Inc(i1);
    Result := Copy( WStr, i1, 8 );
//    Result := Copy( WStr, 4, 8 );
  end; // function ParseSlidePatientID

  // Returns:
  //  1 - file of new object is found - recovery is needed and possible
  //  0 - file of already recoverd object is found - recovery is not needed
  // -1 - file of already recoverd object is found - recovery is possible if object ID will be changed
  // -2 - wrong slide ID
  // -3 - wrong patient ID
  // -4 - wrong file path structure
  function ParseObjectAttrsByFile( const AFileName : string ) : Integer;
  var
    ExistingObj : Boolean;
    NeededToAddObj : Boolean;
    DumpInfo : string;
    CrDate : TDateTime;
    SysInfoStr : string;
    ExVideoFlag : Boolean;
    ExImg3dFlag : Boolean;
    RestoreInd : Integer;
    WrkID : Integer;
    PathSegmLength, PathLength : Integer;
  begin

    Result := 0;
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    begin
      FPath := AFileName;
      FName := ExtractFileName( FPath );
      ParseSlideType := 0;
      if FName[1] = 'M' then ParseSlideType := 1
      else
      if FName[1] = '3' then ParseSlideType := 2
      else
      if FName[1] = 'S' then ParseSlideType := 3;


      FPath1 := ExtractFilePath( FPath );
      FName1 := ExtractFileName( ExcludeTrailingPathDelimiter(FPath1) );

      // Check Slide ID
      WrkID := StrToIntDef( Copy( FName, 4, 8 ), -1 );
      if WrkID <= 0 then
      begin // Bad Slide ID
        Result := -2;
        AddRepInfo( SFSlidePatID, FPath1, format( 'Object ID=%s is wrong.',
                                            [Copy( FName, 4, 8 )] ), TRUE );
        Exit;
      end;

      SFSlideID := IntToStr( WrkID );

      SFSlidePatID := ParseSlidePatientID();

      // Check Patient ID
      WrkID := StrToIntDef( SFSlidePatID, -1 );
      if (WrkID <= 0) and (WrkID >= -100) then
      begin // Bad Patient ID
        Result := -3;
        AddRepInfo( SFSlidePatID, FPath1, format( 'Object ID=%s Patient is wrong.',
                                                  [SFSlideID] ), TRUE );
        Exit;
      end;

      SFSlideCrDate := K_StrToDateTime( FName1 );

      // Check File Path
      RPath2 := K_CMSlideGetPatientFilesPathSegm( WrkID ) +
                K_CMSlideGetFileDatePathSegm( SFSlideCrDate ) +
                Copy( FName, 1, 3 ) +
                K_CMSlideGetFileIDPathSegm( SFSlideID ) + RPath2Suf +
                ExtractFileExt(FName);
      PathSegmLength := Length(RPath2);
      PathLength := Length(FPath);
      RestoreInd := PathLength - PathSegmLength;
      FPath2 := Copy(FPath, RestoreInd + 1, PathLength - RestoreInd);
      if ( FPath[RestoreInd] <> '\' ) or
         ( FPath2  <> RPath2 ) then
      begin // Bad File Path
        Result := -4;
        AddRepInfo( SFSlidePatID, FPath, format( 'Object path %s differs from %s',
                                                 [FPath2, RPath2] ), TRUE );
        Exit;
      end;

      // Check Object Existance
      Filtered := FALSE;
      Filter := K_CMENDBSTFSlideID + '=' + SFSlideID;
      Filtered := TRUE;
      NeededToAddObj := RecordCount > 0;
      if NeededToAddObj then
      begin
        with CurSlidesDSet do
        begin
          Connection := LANDBConnection;

          ExtDataErrorCode := K_eeDBSelect;
          SQL.Text := 'select ' + K_CMENDBSTFPatID  + ',' +
                                  K_CMENDBSTFSlideDTCr + ',' +
                                  K_CMENDBSTFSlideSysInfo +
            ' from ' + K_CMENDBSlidesTable +
            ' where ' +  K_CMENDBSTFSlideID + '=' + SFSlideID;
          Filtered := false;
          Open;
          SPatID := Fields[0].AsString;
          CrDate := Floor(TDateTimeField(Fields[1]).Value);
          ExistingObj := (SPatID = SFSlidePatID) and
                         (CrDate = SFSlideCrDate);
          if ExistingObj then
          begin
            if Fields[2].IsNull then
              ExistingObj := ParseSlideType = 3
            else
            begin // if not Fields[2].IsNull then
              SysInfoStr := K_CMEDAGetDBStringValue( Fields[2] );
              ExVideoFlag := Pos( 'cmsfIsMediaObj', SysInfoStr ) <> 0;
              ExImg3dFlag := Pos( 'cmsfIsImg3DObj', SysInfoStr ) <> 0;
              ExistingObj := (ExVideoFlag and (ParseSlideType = 1)) or
                             (ExImg3DFlag and (ParseSlideType = 2)) or
                             (not ExVideoFlag and not ExImg3DFlag and (ParseSlideType = 0));
            end;  // if not Fields[2].IsNull then
          end; // if ExistingObj then
          Close();
        end; // with CurSlidesDSet do

        DumpInfo := format( 'RDB>> Object ID=%s exists in start DB >> PatID=%s, Cr=%s Type=%d',
                            [SFSlideID, SPatID, K_DateTimeToStr(CrDate, 'yyyy-mm-dd'),ParseSlideType] );
        N_Dump2Str( DumpInfo );
        if ExistingObj then Exit; // the same Object was found - it is alread recovered
      end; // if ExistingObj then

      RestoreInd := -1;
      if not NeededToAddObj then
      begin
        RestoreInd := SlideIDs.IndexOf( Pointer(StrToInt(SFSlideID)) );
      end;

      if NeededToAddObj or (RestoreInd >= 0) then
      begin // Object Already Exists
        Result := -1;
        if RestoreInd >= 0 then
          N_Dump2Str( format( 'RDB>> Object ID=%s was already recovered >> FPatID=%s, FCr=%s FType=%d',
                              [SFSlideID,SFSlidePatID,
                              // K_DateTimeToStr(SFSlideCrDate, 'yyyy-mm-dd'),
                               FName1,
                               Integer(SlideTypes[RestoreInd])] ) );

        if not AddDuplicatedObjectsAsNew and
           ChBShowWarning.Checked then
          K_CMShowMessageDlg( format( K_CML1Form.LLLDBRecovery2.Caption,
//         'Recovering error from file %s'#13#10 +
//         'Media object with ID=%s was already recovered.'#13#10 +
//         'Please check Media object files structure.',
                                    [AFileName,SFSlideID] ), mtError,
                                    [], FALSE, '', 5 );
        Exit;
      end; // if NeededToAddObj or (RestoreInd >= 0) then
    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    Result := 1;
  end; // function ParseObjectAttrsByFile

  procedure RestoreSlideAttrs( );
  var
    SessionInd : Integer;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      N_Dump1Str( format( 'RDB>> Start Recover Object by File %s', [FName] ) );
      CMSlide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));
      CMSlide.ObjName := SFSlideID;
      PCMSlide := CMSlide.P();
      with CMSlide, PCMSlide^ do
      begin
        CMSDTCreated := SFSlideCrDate;
        CMSDTTaken   := CMSDTCreated;
        CMSDTTaken   := CMSDTCreated;
        CMSDTImgMod  := CMSDTCreated;
        CMSDTMapRootMod := CMSDTCreated;
        CMSDTPropMod := CMSDTCreated;
        CMSProvIDCreated := CurProvID; // Provider ID Created
        CMSProvIDModified := CurProvID; // Provider ID Modified
        CMSLocIDCreated := CurLocID; // Location ID Created
        CMSLocIDModified := CurLocID; // Location ID Modified
        CMSLocIDHost := CurLocID; // Host Location ID
        CMSCompIDCreated := K_CMSServerClientInfo.CMSClientVirtualName;
        CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;


        SPatID := SFSlidePatID;
        CMSPatID := StrToInt( SPatID );
        CMSSourceDescr := 'Restored by Database recovery';
        if FName[1] = 'M' then
          CMSDB.SFlags :=  [cmsfIsMediaObj]
        else
        if FName[1] = '3' then
          CMSDB.SFlags :=  [cmsfIsImg3DObj];

        SessionInd := PatientIDs.IndexOf( Pointer(CMSPatID) );
        if SessionInd = -1 then
        begin
          CurPatID := CMSPatID;
          EDAAddSessionHistRecord();
          PatientIDs.Add( Pointer(CMSPatID) );
          SessionIDs.Add( Pointer(CurSessionHistID) );
        end
        else
          CurSessionHistID := Integer(SessionIDs[SessionInd]);

      end;
    end;
  end; // function RestoreSlideAttrs

  // Returns:
  //  1 - file of new object is found - recovery is needed and possible
  //  0 - file of already recoverd object is found - recovery is not needed
  // -1 - file of already recoverd object is found - recovery is possible if object ID will be changed
  // -2 - wrong slide ID
  // -3 - wrong patient ID
  // -4 - wrong file path structure
  function ParseSlideAttrsByFile( const AFileName : string ) : Integer;
  begin
    Result := ParseObjectAttrsByFile( AFileName );
    if Result < 1 then Exit;

    RestoreSlideAttrs( );
  end; // function ParseSlideAttrsByFile

  // ASlideType: 0 - Image, 1 - Video, 2 - 3D Image
  procedure MoveCorruptedFile( const APath : string; ASlideType : Integer );
  var
    Path1 : string;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin

      if ASlideType = 1 then
      begin
        Path1 := BadVideoFolder + Copy(APath, Length(SlidesMediaRootFolder) + 1, Length(APath) );
        Inc(MoveVideoCount);
      end
      else
      if ASlideType = 2 then
      begin
        Path1 := BadImg3DFolder + Copy(APath, Length(SlidesImg3DRootFolder) + 1, Length(APath) );
        Inc(MoveImg3DCount);
      end
      else
      begin
        Path1 := BadImgFolder + Copy(APath, Length(SlidesImgRootFolder) + 1, Length(APath) );
        Inc(MoveImageCount);
      end;

      if ASlideType < 2 then
        K_ForceFilePath( Path1 );
      if RenameFile( APath, Path1 ) then
        N_Dump1Str( 'RDB>>  Move ' + APath + ' >> ' + Path1 )
      else
        N_Dump1Str( 'RDB>>  Move ' + APath + ' >> ' + Path1 + ' fails' );
    end;
  end; // procedure MoveCorruptedFile

  // Returns:
  //  1 - file of new object is found - recovery is needed and possible
  //  0 - file of already recoverd object is found - recovery is not needed
  // -1 - file of already recoverd object is found - recovery is possible if object ID will be changed
  // -2 - wrong slide ID
  // -3 - wrong patient ID
  // -4 - wrong file path structure
  // -5 - wrong Study Attributes
  // -6 - wrong Study Sample ID
  function ParseStudyAttrsByFile( const AFileName : string ) : Integer;
  var
    SessionInd : Integer;
    i : Integer;
    SItemSlideID : string;
    SStudySampleID : string;
    UDStudySample : TN_UDBase;
    UDStudyItem : TN_UDBase;
    StudyItemInd : Integer;
    SStudyItemInd : string;
    SStudyItemPos : string;
    WInd : Integer;
    LinkInfo : string;
    UDStudyMapRoot : TN_UDBase;
    PUP: TN_POneUserParam;
    SLinkPatID : string;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    begin
      Result := ParseObjectAttrsByFile( AFileName );
      if Result < 1 then Exit;

      N_Dump1Str( format( 'RDB>> Start Recover Study by File %s', [FName] ) );
      CMStudy := TN_UDCMStudy(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMStudyCI));
      PCMSlide := CMStudy.P();
      CMStudy.ObjName := SFSlideID;
      if EDAStudyGetAttrsFromFile( AFileName, SlideStudyInfoUpdateStrings, PCMSlide, @CMStudy.CMSStudySampleID,
                                   @CMStudy.CMSStudyItemsCount ) <> K_edOK then
      begin
        AddRepInfo( SPatID, FPath1, 'Study file load error.', TRUE );
        MoveCorruptedFile(FPath, 0);
        Result := -5;
        Exit;
      end;

      SPatID := SFSlidePatID;

      SStudySampleID := IntToStr(CMStudy.CMSStudySampleID);
      UDStudySample := K_CMEDAccess.ArchStudySamplesLibRoot.DirChildByObjName( SStudySampleID );
      if UDStudySample = nil then
      begin
        AddRepInfo( SPatID, FPath1, 'Study Sample ID=' + SStudySampleID + ' is absent.', TRUE );
        MoveCorruptedFile(FPath, 0);
        Result := -6;
        Exit;
      end;

      K_SaveTreeToMem( UDStudySample.DirChild(K_CMSlideIndMapRoot), N_SerialBuf, false, [K_lsfJoinAllSLSR] );
      UDStudyMapRoot := K_LoadTreeFromMem(N_SerialBuf, [K_lsfJoinAllSLSR]);
      CMStudy.PutDirChildSafe( K_CMSlideIndMapRoot, UDStudyMapRoot );
      CMStudy.InitByMapRoot;

      // Check Study Links
      for i := SlideStudyInfoUpdateStrings.Count - 1 downto 0  do
      begin
      // Check Linked SLide Existance
        SItemSlideID := SlideStudyInfoUpdateStrings.Names[i];
        Filtered := FALSE;
        Filter := K_CMENDBSTFSlideID + '=' + SItemSlideID;
        Filtered := TRUE;
        if RecordCount = 0 then
        begin
        // Slide is Absent
          AddRepInfo( SPatID, FPath1, 'Object ID=' + SItemSlideID + ' linked to study is absent.', TRUE );
          SlideStudyInfoUpdateStrings.Delete(i);
          Continue;
        end;

        SLinkPatID := Fields[1].AsString;
        if SLinkPatID <> SPatID then
        begin
        // Slide is Absent
          AddRepInfo( SPatID, FPath1, 'Object ID=' + SItemSlideID + ' linked to study belongs to patient ID=' + SLinkPatID, TRUE );
          SlideStudyInfoUpdateStrings.Delete(i);
          Continue;
        end;

      // Set Study Item State for Thumbnail Creation
        SStudyItemInd := SlideStudyInfoUpdateStrings.ValueFromIndex[i];
        WInd := Pos( '|', SStudyItemInd );
        if WInd > 0 then
        begin
          SStudyItemPos := Copy( SStudyItemInd, WInd + 1, Length(SStudyItemInd) );
          SStudyItemInd := Copy( SStudyItemInd, 1, WInd - 1 );
        end
        else
          SStudyItemPos := '0';

        StudyItemInd := StrToInt( SStudyItemInd );
        UDStudyItem := UDStudyMapRoot.DirChild( StudyItemInd );
        PUP := N_GetUserParPtr(TN_UDCompBase(UDStudyItem).R, 'NotEmptyItem');
        PByte(PUP.UPValue.P)^ := 1;

      // Prep Link Info for DB saving
        LinkInfo := format( '%s=StudyID="%s" StudyItem="%s"', [SItemSlideID,SFSlideID,SStudyItemInd] );
        if K_CMEDDBVersion >= 39 then
          LinkInfo := format( '%s StudyItemPos="%s"', [LinkInfo,SStudyItemPos] );

        SlideStudyInfoUpdateStrings[i] := LinkInfo;
//        SlideStudyInfoUpdateStrings[i] := SItemSlideID + '=StudyID="' + SFSlideID +
//               '" StudyItem="' + SStudyItemInd + '"' + ' StudyItemPos="' + SStudyItemPos + '"';
      end; // for i := SlideStudyInfoUpdateStrings.Count - 1 downto 0  do

      CMStudy.CreateThumbnail();

      with CMStudy, PCMSlide^ do
      begin
        CMSPatID := StrToInt( SPatID );

        SessionInd := PatientIDs.IndexOf( Pointer(CMSPatID) );
        if SessionInd = -1 then
        begin
          CurPatID := CMSPatID;
          EDAAddSessionHistRecord();
          PatientIDs.Add( Pointer(CMSPatID) );
          SessionIDs.Add( Pointer(CurSessionHistID) );
        end else
          CurSessionHistID := Integer(SessionIDs[SessionInd]);

      end; // with CMStudy, PCMSlide^ do
    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  end; // function ParseStudyAttrsByFile

  procedure RenameCorrespondingFiles( ASkipSrcImgRename : Boolean );
  var
    NewFileNameNum : string;
    OldFileNameNum : string;
    OldFileName1 : string;
    NewSNum : string;
    ResFPath : string;
  begin
    NewSNum := IntToStr(NewSlideID);
    Inc(NewSlideID); // Create ID for next New Slide
    N_Dump1Str( format( 'RDB>> New Object ID=%s will be created from ID=%s >> PatID=%s, Cr=%s',
                         [NewSNum,SFSlideID,SFSlidePatID,
                          K_DateTimeToStr(SFSlideCrDate, 'yyyy-mm-dd')] ) );

    SFSlideID := NewSNum;

    NewFileNameNum := K_CMSlideGetFileIDPathSegm( NewSNum );
    OldFileNameNum := Copy( FName, 4, 8 );

    // Rename Current Files
    ResFPath := FPath1 + Copy( FName, 1, 3 ) + NewFileNameNum + ExtractFileExt(FName);
    RenameFile( FPath, ResFPath );

    // Rename Corresponding Files
    // Atributes File
    OldFileName1 := FPath1 + 'AF_' + OldFileNameNum + '.cma';
    if FileExists( OldFileName1 ) then
      RenameFile( OldFileName1, FPath1 + 'AF_' + NewFileNameNum + '.cma' );

    // Skip Original Image File Rename if Video, 3D or Lost Original Image Files Loop
    // Original Image File
    if not ASkipSrcImgRename and (FName[1] = 'R') then
    begin
      OldFileName1 := FPath1 + 'RF_' + OldFileNameNum + 'r.cmi';
      if FileExists( OldFileName1 ) then
        RenameFile( OldFileName1, FPath1 + 'RF_' + NewFileNameNum + 'r.cmi' );
    end;

    FPath := ResFPath;
    FName := ExtractFileName( FPath );

  end; // procedure RenameCorrespondingFiles

  procedure CheckAttrsFilesExistance();
  var
    ASFlags: TN_CMSlideSFlags;
  begin
    // Check Attrs File Existance
    AttrsFName := FName;
    AttrsFName[1] := 'A';
    AttrsFName := FPath1 + ChangeFileExt( AttrsFName, '.cma' );
    AttrsState := 0;
    if FileExists( AttrsFName ) then
    begin
    // Get Info from Attrs File
      AttrsState := 1;
      FStream := TFileStream.Create( AttrsFName, fmOpenRead );
      K_DFStreamOpen( FStream, DFile, [K_dfoProtected] );
      DSize := DFile.DFPlainDataSize;
      if SizeOf(Char) = 2 then
        DSize := DSize shr 1;
      SetLength( K_CMEDAccess.StrTextBuf, DSize );
      K_DFRead( @K_CMEDAccess.StrTextBuf[1], DFile.DFPlainDataSize, DFile );
      FStream.Free;
      K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );
      AttrsSlide := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
      if AttrsSlide = nil then
      begin
        AttrsState := -1;
        N_Dump1Str( 'RDB>> File is corrupted >> ' + AttrsFName );
        AddRepInfo( SPatID, AttrsFName, 'Attributes file is corrupted.', TRUE );
      end   // if AttrsSlide = nil then
      else
      begin // if AttrsSlide <> nil then
        ASFlags := AttrsSlide.P^.CMSDB.SFlags;
        if ((ASFlags <> [cmsfIsMediaObj]) and (FName[1] = 'M')) or
           ((ASFlags <> [cmsfIsImg3DObj]) and (FName[1] = '3')) then
        begin
          N_Dump1Str( 'RDB>> AttrsFile type is not corresponding to object type');
          FreeAndNil(AttrsSlide);
        end
        else
        begin
          CMSlide.Free;
          CMSlide := AttrsSlide;
          PCMSlide := CMSlide.P();
          N_Dump2Str( 'RDB>> AttrsFile is used');
        end;
      end;  // if AttrsSlide <> nil then
    end; // if FileExists( AttrsFName ) then
  end; // procedure CheckAttrsFilesExistance

begin

// Process Slides Loop
  N_Dump1Str( 'RDB >> ' + BtStart.Caption );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        N_Dump1Str( 'RDB >> Break by user ' );
        Exit;
      end
      else
      begin
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then // 'Start'
        begin
          ReportCount := 1;
          StartMSessionTS := 0;
          RecCount   := 0;
          MoveVideoCount := 0;
          MoveImageCount := 0;
          MoveImg3DCount := 0;
          AddDuplicatedCount := 0;
          ErrCount := 0;
          FProcCount := 0;
          FWarnRepCounter := 0;
          OutOfMemoryCount := 0;
        end;

        if StartMSessionTS = 0 then
          StartMSessionTS := Now();
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtReport.Enabled := FALSE;
        BtClose.Enabled := FALSE;
        N_Dump1Str( format( 'RDB>> Recover by Files AllCount=%d ProcCount=%d',
                              [AllCount, RecCount] ) );
      end;

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      ///////////////////////////////
      // Clear Global Autoincrement
      //
      if not K_CMSDBRecoveryMode then
      begin
        with CurSQLCommand1 do
        begin
          if K_CMEDDBVersion < 40 then
          begin
            N_Dump2Str( 'RDB>> Before clear global autoincrement' );
            CommandText := 'ALTER TABLE ' + K_CMENDBSlidesTable +
                           ' MODIFY ' + K_CMENDBSTFSlideID + ' DEFAULT NULL';
            Execute;
            N_Dump2Str( 'RDB>> After clear global autoincrement' );
          end
          else
          begin
            CommandText := 'UPDATE ' + K_CMENDBGlobAttrsTable +
            ' SET ' + K_CMENDBGTFSAFlags + ' = ' + K_CMENDBGTFSAFlags +' | 8;';
            Execute;
            N_Dump2Str( 'RDB>> Set GlobAttrs.SAFlags 8' );
          end;
        end; // with CurSQLCommand1 do

        N_Dump1Str( 'RDB>> Set DB recovery mode' );
        K_CMSDBRecoveryMode := TRUE;
      end; // if not K_CMSDBRecoveryMode then

      BadImgFolder   := SlidesImgRootFolder + K_BadImg + '\';
      BadVideoFolder := SlidesMediaRootFolder + K_BadVideo + '\';
      BadImg3DFolder := SlidesImg3DRootFolder + K_BadImg3D + '\';

      ///////////////////////////////
      // Select Existing Slides
      //
      Connection := LANDBConnection;

      if (FProcCount = 0) and
          not CheckLostFilesFlag and
          not ProcessStudiesFilesFlag and
//          not ProcessImg3DFoldersFlag and
          ChBAddDuplicated.Checked then
      begin
        AddDuplicatedObjectsAsNew := TRUE;

        // Calc by DB existing records
        SQL.Text := 'select MAX('+ K_CMENDBSTFSlideID +') from ' + K_CMENDBSlidesTable;
        Open();
        NewSlideID := FieldList[0].AsInteger + 1;
        Close();

        // Calc by existing Files
        TmpStrings.Assign( FilesList );
        K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'RF_????????r.cmi' );
        TmpStrings.AddStrings( StudiesFList );
        TmpStrings.AddStrings( Img3DFList );
        CalcMaxSlideID( TmpStrings );
      end;

      ExtDataErrorCode := K_eeDBSelect;
      SQL.Text := 'select ' + K_CMENDBSTFSlideID +
                          ' from ' + K_CMENDBSlidesTable;
      Filtered := FALSE;
      N_Dump2Str( 'RDB>> Before open existing slides set' );
      Open;
      N_Dump2Str( 'RDB>> After open existing slides set' );

      if CheckLostFilesFlag then goto CheckLostFiles;
      if ProcessStudiesFilesFlag then goto ProcessStudiesFiles;
      if ProcessImg3DFoldersFlag then goto ProcessImg3DFolders;

     //////////////////////////////////////
     // Slides Files Check Loop
     //

      StatusBar.SimpleText := ' Database recovery (search unrecovered images and video) ... ';
      CMSlide := nil;
      N_Dump1Str( format( 'RDB>> Loop image and video files %d of %d', [FProcCount, FilesList.Count] ) );
      AddRepInfo( '', 'Recover images and video', '' );
      for i := FProcCount to FilesList.Count - 1 do
      begin
        N_Dump2Str( 'RDB>> Try ' + FilesList[i] );
        ParseFileState := ParseSlideAttrsByFile( FilesList[i] );
        if ParseFileState < 1 then
        begin
          StatusBar.SimpleText := ' Database recovery (search unrecovered images and video) ... ';
          if (ParseFileState = 0) or (ParseFileState <= -2) then goto ContLoop;

          // Object with this ID is exist or already recovered
          if not AddDuplicatedObjectsAsNew then
          begin
            AddRepInfo( SPatID, FPath1, format( 'Object ID=%s was already recovered, bad files structure',
                                                [SFSlideID] ), TRUE );
            goto ContLoop; // Object with File ID was already recovered or has DB record with same ID
          end;

          // Recovered as the object with New ID
          // Rename All Slide File by New ID
          DuplicatedSlideID := SFSlideID;
          RenameCorrespondingFiles( TRUE );
          RestoreSlideAttrs();
          Inc(AddDuplicatedCount);
          AddRepInfo( SPatID, FPath1, format( 'Object ID=%s recovered as %s.',
                                              [DuplicatedSlideID,SFSlideID] ), TRUE );
        end
        else
          N_Dump2Str( 'RDB>> Start Recover data from ' + FName );

        // Check Attrs File Existance
        CheckAttrsFilesExistance();

        with CMSlide, PCMSlide^ do
        begin
          HistActCode := Ord(K_shRDBCreate);
          if FName[1] = 'R' then
          begin //***** Image File
            StatusBar.SimpleText := ' Database recovery (add image) ... ';
            // Load DIB
            UDDIB := LoadUDDIB( FPath );
            if UDDIB <> nil then
            begin
              if AttrsState = 1 then
              begin
              // Check DIB Info and Attrs
                with PCMSlide^ do
                // Check Image Attributes
                if ( (UDDIB.DIBObj.DIBPixFmt = pf24bit) and
                     (cmsfGreyScale in CMSDB.SFlags) ) or
                   ( (UDDIB.DIBObj.DIBPixFmt = pfCustom) and
                     not (cmsfGreyScale in CMSDB.SFlags) ) then
                begin
                  FileErrText := format( 'Current image wrong color format PixFmt=%d ÑolorÂepth=%d . ',
                                         [Ord(UDDIB.DIBObj.DIBPixFmt),UDDIB.DIBObj.DIBNumBits] );
                  FreeAndNil( UDDIB );
                  goto ImgFileError;
                end
                else
                if CMSDB.PixBits <> UDDIB.DIBObj.DIBNumBits then
                begin
                  FileErrText := format( 'Current image wrong ColorDepth %d <> %d. ',
                                         [UDDIB.DIBObj.DIBNumBits,CMSDB.PixBits] );
                  FreeAndNil( UDDIB );
                  goto ImgFileError;
                end
                else
                if ((CMSDB.PixWidth <> UDDIB.DIBObj.DIBSize.X) or
                    (CMSDB.PixHeight <> UDDIB.DIBObj.DIBSize.Y)) and
                   ((CMSDB.PixWidth <> UDDIB.DIBObj.DIBSize.Y) or
                    (CMSDB.PixHeight <> UDDIB.DIBObj.DIBSize.X)) then
                begin
                  FileErrText := format( 'Current image wrong size %dx%d <> %dx%d. ',
                                         [UDDIB.DIBObj.DIBSize.X,UDDIB.DIBObj.DIBSize.Y,
                                          CMSDB.PixWidth,CMSDB.PixHeight] );
                  FreeAndNil( UDDIB );
                  goto ImgFileError;
                end;
              end;
              AddCurrentUDDIB( UDDIB );
              CMSCurImgFSize := FSize;
            end
            else
            begin
            // Load DIB error
              if DIBOutOfMemory then
              begin
ImgOutOfMemory:
                AddRepInfo( SPatID, FPath, 'There is not enough memory to recover', TRUE );
                Inc(OutOfMemoryCount);
                goto ContLoop;
              end;
            // Copy Corrupted to BadImages
              MoveCorruptedFile( FPath, 0 );
            end;

            if (AttrsState < 1) or
               (cmsfHasSrcImg in CMSDB.SFlags) or
               (UDDIB = nil) then
            begin
              FileErrText := 'Current image file is corrupted. ';
              FPath1 := ChangeFileExt( FPath, 'r.cmi' );
              if FileExists( FPath1 ) then
              begin
                UDDIB1 := LoadUDDIB( FPath1 );
                if UDDIB1 = nil then
                begin // Original Error
                  if DIBOutOfMemory then
                  begin
                    FPath := FPath1;
                    goto ImgOutOfMemory;
                  end;
                  MoveCorruptedFile( FPath1, 0 );
                  if UDDIB = nil then
                  begin
                    AddRepInfo( SPatID, FPath1, 'Original image file is corrupted.', TRUE );
                    Dec(ReportCount); // To Clear Last Report Line, needed for ErrCount increment and show
                    FileErrText := 'Current and original image files are corrupted. ';
                    goto ImgFileError;
                  end
                  else
                  begin
                    Include( CMSDB.SFlags, cmsfSaveSrcImg );
                    AddRepInfo( SPatID, FPath1, 'Original image file is corrupted. Original object is unrecoverable, the current object is recovered.', TRUE );
                    HistActCode := Ord(K_shRDBCreateWOOrig);
                  end;
                end   // if UDDIB1 = nil then
                else
                begin // if UDDIB1 <> nil then
                  if UDDIB = nil then
                  begin // Create current from Original
                    RenameFile( FPath1, FPath ); // Move Original to current
                    AddCurrentUDDIB( UDDIB1 );
                    Include( CMSDB.SFlags, cmsfSaveSrcImg );
                    AddRepInfo( SPatID, FPath, 'Current image file is corrupted. Current object is unrecoverable, the original object is recovered.', TRUE );
                    HistActCode := Ord(K_shRDBCreateWOCur);
                  end
                  else
                  begin
                    UDDIB1.Free;
                    Include( CMSDB.SFlags, cmsfHasSrcImg );
                    CMSSrcImgFSize := FSize;
                    Include( GetPMapRootAttrs().MRImgFlags, K_smriRestoreSrcImg );
                  end;
                end; // if UDDIB1 <> nil then
              end // if FileExists( FPath1 ) then
              else
              if AttrsState = 1 then
              begin
                AddRepInfo( SPatID, FPath1, 'Original image file is absent.', TRUE );
                Exclude( CMSDB.SFlags, cmsfHasSrcImg );
              end;
            end; // if (AttrsState < 1) or (cmsfHasSrcImg in CMSDB.SFlags) then

            if UDDIB = nil then
            begin // Recovery Error
ImgFileError:
              AddRepInfo( SPatID, FPath, FileErrText + 'Object is unrecoverable.', TRUE );
              goto ContLoop;
            end;

            if not (cmsfHasSrcImg in CMSDB.SFlags) then
              Include( CMSDB.SFlags, cmsfSaveSrcImg ); // 
            FieldsCtrlFlags := [K_sffAddThumbField,K_sffAddMapRootField];
          end
          else
          begin //***** Video File
            StatusBar.SimpleText := ' Database recovery (add video) ... ';
            CMSDB.MediaFExt := FPath; // Needed for Thumbnail creation
            if AddMediaFile( FPath ) <> 0 then
            begin
              FSize := VFInfo.VFIFileSize;
              AddRepInfo( SPatID, FPath, 'Video file is corrupted. Object is unrecoverable', TRUE );
              N_Dump1Str( 'DB >> Video File Error >> ' + VFInfo.VFISError );
              MoveCorruptedFile( FPath, 1 );
              goto ContLoop;
            end;
            CMSDB.MediaFExt := ExtractFileExt( FName );
            FieldsCtrlFlags := [K_sffAddThumbField];
          end;

          // Save Slide Data
          SaveSlideToDB();
        end; // with CMSlide, PCMSlide^ do

ContLoop:
        FreeAndNil( CMSlide );
        FProcCount := i + 1;
        PBProgress.Position := Round(1000 * FProcCount / FilesList.Count);
        LbEDProcCount.Text := IntToStr( RecCount );
        LbEDProcCount.Refresh();
//        sleep(1000);  // for debug
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // 'Stop'Break Files Loop by PAUSE
      end; // for i := FProcCount to FilesList.Count - 1 do


    //***************************
    // Process Img3D Folders
    //
      if K_CMEDDBVersion >= 34 then
      begin
        FProcCount := 0;

ProcessImg3DFolders:
        N_Dump1Str( 'RDB>> Recover Img 3D' );
        ProcessImg3DFoldersFlag := TRUE;

        HistActCode := Ord(K_shRDBCreate);
        CMSlide := nil;

        N_Dump1Str( format( 'RDB>> Loop 3D files %d of %d', [FProcCount, Img3DFList.Count] ) );
        AddRepInfo( '', 'Recover 3D objects', '' );
        StatusBar.SimpleText := ' Database recovery (search unrecovered 3D objects) ... ';
        for i := FProcCount to Img3DFList.Count - 1 do
        begin
          N_Dump2Str( 'RDB>> Try ' + Img3DFList[i] );
          ParseFileState := ParseSlideAttrsByFile( ExcludeTrailingPathDelimiter(Img3DFList[i]) );
          if ParseFileState < 1 then
          begin
            StatusBar.SimpleText := ' Database recovery (search unrecovered 3D objects) ... ';
            if (ParseFileState = 0) or (ParseFileState <= -2) then goto ContLoop0;
            if not AddDuplicatedObjectsAsNew then
            begin
              AddRepInfo( SPatID, FPath1, format( '3D Object ID=%s was already recovered, bad files structure',
                                                  [SFSlideID] ), TRUE );
              goto ContLoop0; // Object with File ID was already recovered or has DB record with same ID
            end;

            // Rename All Slide File by New ID
            DuplicatedSlideID := SFSlideID;
            RenameCorrespondingFiles( FALSE );
            RestoreSlideAttrs();
            Inc(AddDuplicatedCount);
            AddRepInfo( SPatID, FPath1, format( '3D Object ID=%s recovered as %s.',
                                                [DuplicatedSlideID,SFSlideID] ), TRUE );
          end  // if ParseFileState < 1 then
          else
            N_Dump2Str( 'RDB>> Start Recover 3D data from ' + FName );

          // Save Slide Data
          PCMSlide.CMSDB.MediaFExt := IncludeTrailingPathDelimiter(FPath); // Needed for Restore Thumbnail and Attributes

          Check3DRes := EDACheckSlideImg3DData( PCMSlide.CMSDB.MediaFExt, 2, FName1 );
          if Check3DRes <> 0 then
          begin
            if Check3DRes = 2 then
              AddRepInfo( SPatID, FPath1, format( '3D Object ID=%s is unrecoverable, file %s is absent', [SFSlideID,FName1] ), TRUE );
            if Check3DRes = 3 then
              AddRepInfo( SPatID, FPath1, format( '3D Object ID=%s is unrecoverable, file %s is corrupted', [SFSlideID,FName1] ), TRUE );

            MoveCorruptedFile( FPath, 2 );
            goto ContLoop0;
          end;

        // Check Attrs File Existance
          CheckAttrsFilesExistance();

          StatusBar.SimpleText := ' Database recovery (add 3D object) ... ';
          FieldsCtrlFlags := [K_sffAddThumbField];
          CMSlide.CreateThumbnail();
          K_CMImg3DAttrsInit( PCMSlide );
          PCMSlide.CMSDB.MediaFExt := '';
          HistActCode := Ord(K_shRDBCreate);
          SaveSlideToDB();

ContLoop0:
          FreeAndNil( CMSlide );
          FProcCount := i + 1;
          PBProgress.Position := Round( 1000 * FProcCount / Img3DFList.Count );
          LbEDProcCount.Text := IntToStr( RecCount );
          LbEDProcCount.Refresh();
  //        sleep(1000);
          Application.ProcessMessages();
          if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // 'Stop' Break Files Loop by PAUSE
        end; // for i := FProcCount to Img3DFList.Count - 1 do

      end; // if K_CMEDDBVersion >= 34 then
    //
    // Process Img3D Folders
    //***************************


    ///////////////////////////////
    // Rebuild Existing Slides DataSet
    //
      Close();
      ExtDataErrorCode := K_eeDBSelect;
      SQL.Text := 'select ' + K_CMENDBSTFSlideID +
                           ' from ' + K_CMENDBSlidesTable;
      Filtered := FALSE;
      Open();

      TmpStrings.Clear;
      StatusBar.SimpleText := ' Build original image files list ...';
      SkipDataFolder := SlidesImgRootFolder + K_BadImg;
      K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'RF_????????r.*' );
      SkipDataFolder := '';
      FilesList.Assign( TmpStrings );
      FProcCount := 0;

CheckLostFiles:
    //******************************************************
    // Search for Original Original Images with lost Current Image Files
    //
      N_Dump1Str( 'RDB>> Recover Lost' );
      CheckLostFilesFlag := TRUE;

      CMSlide := nil;
      RPath2Suf := 'r'; // for path control
      N_Dump1Str( format( 'RDB>> Loop lost files %d of %d', [FProcCount, FilesList.Count] ) );
      AddRepInfo( '', 'Recover lost images', '' );
      StatusBar.SimpleText := ' Database recovery (search lost images) ... ';
      for i := FProcCount to FilesList.Count - 1 do
      begin
        N_Dump2Str( 'RDB>> Try ' + FilesList[i] );

        ParseFileState := ParseSlideAttrsByFile( FilesList[i] );

        if ParseFileState < 1 then
        begin
          StatusBar.SimpleText := ' Database recovery (search lost images) ... ';
          if (ParseFileState = 0) or (ParseFileState <= -2) then goto ContLoop1;

          if not AddDuplicatedObjectsAsNew then
          begin
            AddRepInfo( SPatID, FPath1, format( 'Object ID=%s was already recovered, bad files structure',
                                                [SFSlideID] ), TRUE );
            goto ContLoop1; // Object with File ID was already recovered or has DB record with same ID
          end;

          // Rename All Slide File by New ID
          DuplicatedSlideID := SFSlideID;
          RestoreSlideAttrs();
          RenameCorrespondingFiles( TRUE );
          Inc(AddDuplicatedCount);
          AddRepInfo( SPatID, FPath1, format( 'Object ID=%s recovered as %s.',
                                              [DuplicatedSlideID,SFSlideID] ), TRUE );
        end;

        N_Dump2Str( 'RDB>> Start Recover ' + FilesList[i] );
        StatusBar.SimpleText := ' Database recovery (add lost image) ... ';

        // Check Attrs File Existance
        // CheckAttrsFilesExistance(); !!! Skip Attrs because it should not be apply to Original
        AttrsState := 0;

        with CMSlide, PCMSlide^ do
        begin
          StatusBar.SimpleText := ' Database recovery (add lost image) ... ';
          Exclude( CMSDB.SFlags, cmsfHasSrcImg );
          Inc(AllCount);
          // Load DIB
          FPath1 := Copy( FPath, 1, Length(FPath) - 5 ) + '.cmi';
          UDDIB := LoadUDDIB( FPath );
          if UDDIB <> nil then
          begin // Create from original
            RenameFile( FPath, FPath1 ); // Move Original to current
            AddCurrentUDDIB( UDDIB );
            CMSCurImgFSize := FSize;
            Include( CMSDB.SFlags, cmsfSaveSrcImg );
            FieldsCtrlFlags := [K_sffAddThumbField,K_sffAddMapRootField];
            Inc(AllCount);
            HistActCode := Ord(K_shRDBCreateWOCur);
            SaveSlideToDB();
            AddRepInfo( SPatID, FPath, 'Current image file is lost. Current object is unrecoverable, the original object is recovered.', TRUE );
          end
          else
          begin
          // Copy Corrupted to BadImages
            if DIBOutOfMemory then
            begin
              AddRepInfo( SPatID, FPath, 'There is not enough memory to recover', TRUE );
              Inc(OutOfMemoryCount);
              goto ContLoop1;
            end;
            MoveCorruptedFile( FPath, 0 );
            AddRepInfo( SPatID, FPath1, 'Current image file is lost. Original image file is corrupted. Object is unrecoverable.', TRUE );
            goto ContLoop1;
          end;
        end; // with CMSlide, PCMSlide^ do

ContLoop1:
        FreeAndNil( CMSlide );
        FProcCount := i + 1;
        PBProgress.Position := Round(1000 * FProcCount / FilesList.Count );
        LbEDProcCount.Text := IntToStr( RecCount );
        LbEDProcCount.Refresh();
        LbEDBMediaCount.Text := IntToStr( AllCount );
        LbEDBMediaCount.Refresh();
//        sleep(1000);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // 'Pause' Break Files Loop by STOP
      end; // for i := FProcCount to FilesList.Count - 1 do
      RPath2Suf := '';

    //
    // Search for Original Original Image with lost Current Image Files
    //******************************************************

      if K_CMEDDBVersion < 24 then goto FinExit0;


    ///////////////////////////////
    // Rebuild Existing Slides DataSet
    //
      Close();
      ExtDataErrorCode := K_eeDBSelect;
      SQL.Text := 'select ' + K_CMENDBSTFSlideID + ',' + K_CMENDBSTFPatID +
                           ' from ' + K_CMENDBSlidesTable;
      Filtered := FALSE;
      Open();

      FProcCount := 0;

ProcessStudiesFiles:
    //***************************
    // Process Studies Files
    //
      N_Dump1Str( 'RDB>> Recover Studies' );
      ProcessStudiesFilesFlag := TRUE;

      CMStudy := nil;
      MovedBeforeStudiesCount := MoveImageCount;

      N_Dump1Str( format( 'RDB>> Loop studies files  %d of %d', [FProcCount, StudiesFList.Count] ) );
      AddRepInfo( '', 'Recover studies', '' );
      StatusBar.SimpleText := ' Database recovery (search studies) ... ';
      for i := FProcCount to StudiesFList.Count - 1 do
      begin
        N_Dump2Str( 'RDB>> Try ' + StudiesFList[i] );
        ParseFileState := ParseStudyAttrsByFile( StudiesFList[i] );

        if ParseFileState < 1 then
        begin
          StatusBar.SimpleText := ' Database recovery (search studies) ... ';
          if ParseFileState = -1 then
            AddRepInfo( SPatID, FPath1, format( 'Object ID=%s was already recovered, bad files structure',
                                                [SFSlideID] ), TRUE );

        end
        else
        begin
          N_Dump2Str( 'RDB>> Start Saving ' + StudiesFList[i] );
          StatusBar.SimpleText := ' Database recovery (add study) ... ';
          Inc(StudiesCount);
          SaveStudyToDB();
        end;

ContLoop2:
        FreeAndNil( CMStudy );
        FProcCount := i + 1;
        PBProgress.Position := Round(1000 * FProcCount / StudiesFList.Count );
        LbEDProcCount.Text := IntToStr( RecCount );
        LbEDProcCount.Refresh();
        LbEDBMediaCount.Text := IntToStr( AllCount );
        LbEDBMediaCount.Refresh();
//        sleep(1000);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // 'Pause' Break Files Loop by STOP
      end; // for i := 0 to AllCount - 1 do

    //
    // Process Studies Files
    //******************************************************

//      PBProgress.Position := 0;

FinExit0:
      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      RecoveryFinishFlag := TRUE;

FinExit:
      Close();
      BtReport.Enabled := ReportIsNeededFlag;
      BtClose.Enabled := TRUE;
      Screen.Cursor := SavedCursor;

      if RecoveryFinishFlag then
      begin
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
        BtStart.Enabled := FALSE;
        ResText := K_CML1Form.LLLDBRecovery7.Caption  // 'finished';
      end
      else
        ResText := K_CML1Form.LLLDBRecovery6.Caption; // 'stoped';
      StatusBar.SimpleText := '';

      FileErrText :=
         format( K_CML1Form.LLLDBRecovery3.Caption,
//         'Database recovery is %s. %d of %d media objects were recovered.',
         [ResText, RecCount, AllCount] );

      if OutOfMemoryCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery12.Caption,
//                   'there was not enough memory to recover %d object(s)',
                   [FileErrText, OutOfMemoryCount] );

      if AddDuplicatedCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery10.Caption,
//                   '%d duplicated media object(s) were recovered as new',
                   [FileErrText, AddDuplicatedCount] );

      if MovedBeforeStudiesCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery4.Caption,
//                   '%d corrupted image file(s) were moved to %s',
                   [FileErrText, MovedBeforeStudiesCount, BadImgFolder] );

      if MoveVideoCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery5.Caption,
//                   '%d corrupted video file(s) were moved to %s',
                   [FileErrText, MoveVideoCount, BadVideoFolder] );

      if MoveImg3DCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery11.Caption,
//                   '%d corrupted 3D image object(s) were moved to %s',
                   [FileErrText, MoveImg3DCount, BadImg3DFolder] );

      if MoveImageCount - MovedBeforeStudiesCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery9.Caption,
//                   '%d corrupted study file(s) were moved to %s',
                   [FileErrText, MoveImageCount - MovedBeforeStudiesCount,BadImgFolder] );

      if StudiesCount > 0 then
        FileErrText :=
           format( '%s'#13#10#13#10 + K_CML1Form.LLLDBRecovery8.Caption,
//                   '%d studies were recovered',
                   [FileErrText, StudiesCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

      if ReportIsNeededFlag and (BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]) then //'Start'
        BtReportClick(Sender);

      if RecoveryFinishFlag and (OutOfMemoryCount > 0) then // finish recovery
         K_CMShowMessageDlg(
           format( K_CML1Form.LLLDBRecovery13.Caption,
//                   'There was not enough memory to recover %d object(s).'#13#10
//                   'Please close Media Suite and try DB recovery again!',
                   [OutOfMemoryCount] ), mtWarning );

      if not ReportIsNeededFlag and RecoveryFinishFlag then // Close Form
        ModalResult := mrOK;

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'RDB>> Restore Slides by File Exception >> ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
    Close(); // Close Data Set
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMDBRecovery.BtStartClick

//****************************************** TK_FormCMDBRecovery.AddRepInfo ***
// Add Report Info
//
//     Parameters
// APatientInfo - Patien Report Info
// ASlideInfo   - Slide Report Info
// AErrInfo     - Error Report Info
// ACountErrors - Count Errors Flag
//
procedure TK_FormCMDBRecovery.AddRepInfo( APatientInfo, ASlideInfo, AErrInfo : string;
                                           ACountErrors : Boolean = FALSE );
begin
  if ReportCount >= Length(ReportSMatr) then
    SetLength( ReportSMatr, ReportCount + 100 );

  SetLength( ReportSMatr[ReportCount], 3 );

  ReportSMatr[ReportCount][0] := APatientInfo;
  ReportSMatr[ReportCount][1] := ASlideInfo;
  ReportSMatr[ReportCount][2] := AErrInfo;

  Inc(ReportCount);
  if not ACountErrors then Exit;

  N_Dump1Str( 'RDB>> Report ' + APatientInfo + ' >> ' + AErrInfo );
  ReportIsNeededFlag := TRUE;

  Inc(ErrCount);
  LbEDErrCount.Text := IntToStr( ErrCount );
  LbEDErrCount.Refresh();

end; // TK_FormCMDBRecovery.AddRepInfo

//************************************** TK_FormCMDBRecovery.CalcMaxSlideID ***
// Calculate Ìaximal Slide ID
//
procedure TK_FormCMDBRecovery.CalcMaxSlideID( AList : TStrings );
var
  MaxStr : string;
  CurStr : string;
  i : Integer;
begin
  MaxStr := format( '%.8d', [NewSlideID] );
  for i := 0 to AList.Count - 1 do
  begin
    CurStr := ExtractFileName( AList[i] );
    CurStr := Copy( CurStr, 4, 8 );
    if CurStr <= MaxStr then Continue;
    MaxStr := CurStr;
  end;
  NewSlideID := StrToIntDef( MaxStr , NewSlideID );
end; // TK_FormCMDBRecovery.CalcMaxSlideID

//***************************************** TK_FormCMDBRecovery.BtReportClick ***
//  On Button Report Click Handler
//
procedure TK_FormCMDBRecovery.BtReportClick(Sender: TObject);
begin

  with TK_FormCMReportShow.Create(Application) do
  begin
    ReportDataSMatr := Copy( ReportSMatr, 0, ReportCount );
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PrepareRAFrameByDataSMatr( format( K_CML1Form.LLLReport8.Caption,
    // 'DB recovery errors report from %s to %s'
          [K_DateTimeToStr( StartMSessionTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ),
           K_DateTimeToStr( Now(), 'yyyy-mm-dd hh:nn:ss AM/PM' )] ) );
{
         'DB recovery errors report from ' +
            K_DateTimeToStr( StartMSessionTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
        ' to ' +
            K_DateTimeToStr( Now(), 'yyyy-mm-dd hh:nn:ss AM/PM' ) );
}
    FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);

    ShowModal;
  end;
  if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then // 'Start'
    ReportIsNeededFlag := FALSE;
end; // TK_FormCMDBRecovery.BtReportClick

procedure TK_FormCMDBRecovery.FlistTimerTimer(Sender: TObject);
begin
  FlistTimer.Enabled := FALSE;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
   //////////////////////////////////////
   // Build Media Objects Files List
   //
    TmpStrings.Clear;
    StatusBar.SimpleText := ' Build image files list ...';
    SkipDataFolder := SlidesImgRootFolder + K_BadImg;
    K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'RF_????????.cmi' );

    StatusBar.SimpleText := ' Build video files list ...';
    SkipDataFolder := SlidesMediaRootFolder + K_BadVideo;
    K_ScanFilesTree( SlidesMediaRootFolder, EDASelectDataFiles, 'MF_????????.*' );
    SkipDataFolder := '';
    FilesList := TStringList.Create;
    FilesList.Assign( TmpStrings );

    TmpStrings.Clear;
    StatusBar.SimpleText := ' Build studies files list ...';
    SkipDataFolder := SlidesImgRootFolder + K_BadImg;
    K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, 'SF_????????.cma' );
    SkipDataFolder := '';
    StudiesFList := TStringList.Create;
    StudiesFList.Assign( TmpStrings );

    TmpStrings.Clear;
    StatusBar.SimpleText := ' Build 3D images folders list ...';
    SkipDataFolder := SlidesImg3DRootFolder + K_BadImg3D;
    K_ScanFilesTree( SlidesImg3DRootFolder, EDASelectDataFiles, '3F_????????', TRUE );
    SkipDataFolder := '';
    Img3DFList := TStringList.Create;
    Img3DFList.Assign( TmpStrings );

    StatusBar.SimpleText := '';
    AllCount := FilesList.Count + StudiesFList.Count + Img3DFList.Count;

    LbEDBMediaCount.Text := IntToStr( AllCount );
    LbEDProcCount.Text := IntToStr( RecCount );
    PBProgress.Max := 1000;
    PBProgress.Position := 0;
    if AllCount > 0 then
      PBProgress.Position := Round(1000 * RecCount / AllCount);

    AddRepInfo( 'Patient ID', 'File path', 'Error type' );

    // Init Sessions and corresponding Patients List
    SessionIDs := TList.Create;
    SessionIDs.Add( Pointer(CurSessionHistID) );
    PatientIDs := TList.Create;
    SlideIDs   := TList.Create;
    SlideTypes := TList.Create;
    PatientIDs.Add( Pointer(CurPatID) );
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  BtStart.Enabled := TRUE;
  
  Screen.Cursor := SavedCursor;
end; // procedure TK_FormCMDBRecovery.FlistTimerTimer

end.
