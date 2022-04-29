unit K_FCMIntegrityCheck;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMIntegrityCheck = class(TN_BaseForm)
    LbEDLastDBMTS: TLabeledEdit;
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    LbEDErrCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    ChBOnlyUnrecovered: TCheckBox;
    BtStart: TButton;
    BtReport: TButton;
    ChBRestoreFromThumbnail: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure BtReportClick(Sender: TObject);
  private
    { Private declarations }
    ErrCount, ErrVideoCount, MoveImg3DCount, MoveVideoCount, MoveImageCount : Integer;
    MoveImageBeforStudiesCount : Integer;
    ErrImg3DCount : Integer;
    AllCount,
    ProcCount,
    RecCount,
    DelCount,
    StudyUpdateCount,
    SkipRDBCount : Integer;
    ReportSMatr: TN_ASArray;
    ReportCount : Integer;
    CheckNumSlides : Integer;
    StartMSessionTS : TDateTime;
    SQLCondStr : string;
    SQLFrom : string;
    SQLWhere : string;
    SQLWhere1 : string;
    SavedCursor: TCursor;
    ReportIsNeededFlag : Boolean;
    CheckFinishFlag : Boolean;
    CheckStudiesFlag : Boolean;
    procedure AddRepInfo( APatientInfo, ASlideInfo, AErrInfo : string;
                          ACountErrorsMode : Integer = 0 );
    procedure GetCommonCountersInfo();
  public
    { Public declarations }
  end;

var
  K_FormCMIntegrityCheck: TK_FormCMIntegrityCheck;

implementation

{$R *.dfm}

uses DB, Math,
  K_CM0, K_CLib0, K_FCMReportShow, K_Script1, K_CML1F, {K_FEText,}
  N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2;

const K_BadImg   = 'Bad images';
const K_BadVideo = 'Bad video';
const K_BadImg3D = 'Bad 3D images';

//***************************************** TK_FormCMIntegrityCheck.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMIntegrityCheck.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;

  BtReport.Enabled := FALSE;


  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Build Maintenance SQL Conditions
     //

      if K_CMEnterpriseModeFlag then
        SQLFrom := ' from ' + K_CMENDBSlidesTable + ',' + K_CMENDBLocFilesInfoTable
      else
        SQLFrom := ' from ' + K_CMENDBSlidesTable;
      SQLFrom := SQLFrom + ' where ';

      SQLWhere := ' (' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideFlags + ' <> 2 ' + ' or ' +
                   K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideFlags + ' IS NULL)';
      if K_CMEnterpriseModeFlag then
        SQLWhere := SQLWhere +
          ' and ' + K_CMENDBSlidesTable +       '.' + K_CMENDBSTFSlideID + '=' +
                    K_CMENDBLocFilesInfoTable + '.' + K_CMENDBLFILocSlideID  +
          ' and ' + K_CMENDBLocFilesInfoTable + '.' + K_CMENDBLFILocID + '=' + IntToStr(CurLocID);

      SQLWhere1 := SQLWhere;
      if K_CMEDDBVersion >= 24 then
        SQLWhere := SQLWhere +
          ' and ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideStudyID + ' >= 0' +
          ' and not ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideThumbnail + ' is null ';

      SQLCondStr := SQLFrom +
        K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideSFlags + ' & 1 = 0 and' + SQLWhere;

     //////////////////////////////////////
     // Maintenance Common Info
     //
      GetCommonCountersInfo();

      if CheckNumSlides = 0 then
        CheckNumSlides := Min( Round(AllCount/20), 5 );
      if CheckNumSlides = 0 then
        CheckNumSlides := 1;

      ChBOnlyUnRecovered.Enabled := FALSE;

     //////////////////////////////////////
     // Set Conv PNG context
     //
      if ProcCount > 0 then
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1] //'Resume'
      else
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
        ChBOnlyUnRecovered.Enabled := SkipRDBCount > 0;
        ChBOnlyUnRecovered.Checked := ChBOnlyUnRecovered.Enabled;
      end;

      AddRepInfo( 'Patient ID', 'Object ID', 'Error type' );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMIntegrityCheck.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // TK_FormCMIntegrityCheck.FormShow

//***************************************** TK_FormCMIntegrityCheck.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMIntegrityCheck.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLIntegrityCheck2.Caption,
//      'Do you really want to break maintenance procedure?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if ReportIsNeededFlag and
     ( mrOK = K_CMShowMessageDlg( K_CML1Form.LLLReport9.Caption,
//       'You have unsaved errors report. Press OK to save report data.',
       mtConfirmation, [mbOK, mbCancel] ) ) then
    BtReportClick(Sender);
  if ProcCount < AllCount then
    N_Dump1Str( 'DBICheck>> Break by user' );

end; // TK_FormCMIntegrityCheck.FormCloseQuery

//***************************************** TK_FormCMIntegrityCheck.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMIntegrityCheck.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError,
                                 K_cmicStudyFileAbsent, K_cmicStudyFileCorrupted, K_cmicStudyFileLinkErrors,
                                 K_cmicImg3DError );
var
//  CMSDB  : TN_CMSlideSDBF;   // Slide Fields stored as single DB field
//  ChangeFSizeInfoFlag : Boolean;
  SQLStr, Path1, LPath, {SlideID,} SPatID, FName, FName1: string;
  VFInfo: TN_VideoFileInfo;
  CheckRes, CheckFize, i, j : Integer;
  PImgData : Pointer;
  ImgDSize : Integer;
  Slides : TN_UDCMBSArray;
  LockedSlides : TN_UDCMSArray;
  CurSlideState : TK_CMICSlideState;
  CSlide : TN_UDCMSlide;
  CStudy : TN_UDCMStudy;
  WText, ResText, FileErrText : string;
  BadImgFolder, BadVideoFolder, BadImg3DFolder : string;
  MarkAsDelShowFlag : Boolean;

label FinExit, CheckStudies;

  //////////////////////////////////////
  // Update Maintenance DB Common Info
  //
  procedure UpdateDBCommonInfo( AErrCount : Integer );
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    begin
      SQL.Text := 'select ' +
        K_CMENDBGTFMaintenanceTS + ',' +
        K_CMENDBGTFMaintenanceErr +
        ' from ' + K_CMENDBGlobAttrsTable;
      Filtered := false;
      Open;
      Edit;
      TDateTimeField(FieldList.Fields[0]).Value := EDAGetSyncTimestamp();
      FieldList.Fields[1].AsInteger := AErrCount;
      UpdateBatch;
      Close();
    end;
  end; // procedure UpdateDBCommonInfo

  //////////////////////////////////////
  // Move Corrupted File
  //
  // ASlideType - 0 - Image, 1 - Video, 2 - 3D
  procedure MoveCorruptedFile( const AFPath : string; ASlideType : Integer;
                               ACopyFlag : Boolean = FALSE );
  var
    Path1 : string;
    DumpFlag : Boolean;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      if not FileExists(AFPath) then Exit;
      if ASlideType = 1 then
        Path1 := BadVideoFolder + Copy(AFPath, Length(SlidesMediaRootFolder) + 1, Length(AFPath) )
      else
      if ASlideType = 0 then
        Path1 := BadImgFolder + Copy(AFPath, Length(SlidesImgRootFolder) + 1, Length(AFPath) )
      else
        Path1 := BadImg3DFolder + Copy(AFPath, Length(SlidesImg3DRootFolder) + 1, Length(AFPath) );

      if ASlideType = 2 then
      begin
        if not ACopyFlag then
          DumpFlag := RenameFile( AFPath, Path1 )
        else
          DumpFlag := K_CopyFolderFiles( AFPath, Path1, '*.*' );
      end
      else
      begin
        K_ForceFilePath( Path1 );
        if not ACopyFlag then
          DumpFlag := RenameFile( AFPath, Path1 )
        else
          DumpFlag := 0 = K_CopyFile( AFPath, Path1 );
      end;

      if DumpFlag then
      begin
        N_Dump1Str( 'DBICheck>> File ' + AFPath + ' >> ' + Path1 );
        if ASlideType = 1 then
          Inc(MoveVideoCount)
        else
        if ASlideType = 0 then
          Inc(MoveImageCount)
        else
          Inc(MoveImg3DCount);
      end;
    end;
  end; // procedure MoveCorruptedFile

  //////////////////////////////////////
  // Correct Slide DB State
  //
  procedure CorrectSlideDBState( );
  var
    HistActCode : Integer;
    FieldsCtrlFlags : TK_CMEDASelectFieldsFlags;
  begin
    if K_cmicCurError in CurSlideState then
    begin
      FieldsCtrlFlags := [K_sffAddThumbField,K_sffAddMapRootField];
      HistActCode := Ord(K_shRDBCurImgChng);
    end
    else
    begin
      FieldsCtrlFlags := [K_sffAddMapRootField];
      HistActCode := Ord(K_shRDBSrcImgChng);
    end;

    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin

      with CurSlidesDSet do
      begin
        SQL.Text := 'select ' +
            EDAGetSlideSelectFieldsStr( FieldsCtrlFlags ) +
            ' from ' + EDAGetSlideSelectFromStr( ) +
            ' where ' + K_CMENDBSTFSlideID + ' = ' + CSlide.ObjName;
        Filtered := false;
        Open;

        EDAWaitForCurSlideRWLock( CSlide.ObjName, K_cmlfWrite );
        EDAGetSlideFields( CSlide, FALSE );
        EDAGetSlideMapRoot0( CSlide );
        if K_cmicCurError in CurSlideState then
        begin
          EDAGetSlideCurImage0( CSlide );
          CSlide.CreateThumbnail();
        end;

        with CSlide, P^ do
        begin
          Exclude( CMSDB.SFlags, cmsfHasSrcImg );
          Include( CMSDB.SFlags, cmsfSaveSrcImg );
          CMSDTMapRootMod :=  EDAGetSyncTimestamp();
          Exclude( GetPMapRootAttrs()^.MRImgFlags, K_smriRestoreSrcImg );
        end;

        Edit;

        CurSlide := CSlide;
        EDASaveSlideFields();

        if K_cmicCurError in CurSlideState then
          EDASaveSlideThumbnail();

        EDASaveSlideMapRoot();
        UpdateBatch;
        Close;
        EDALockSlideForRW( CSlide.ObjName, K_cmlfFree);
      end;


      EDASaveSlidesListHistory( @CSlide, 1,
             EDABuildHistActionCode( K_shATChange, Ord(K_shCADBRecovery), HistActCode ) )
    end;
  end; // procedure CorrectSlideDBState

  //////////////////////////////////////
  // Correct Slide DB State
  //
  procedure CorrectSlideDBStateByThumbnail( );
  var
    UDDIB : TN_UDDIB;
    PData : Pointer;
    DSize : Integer;
    RGBDiff : Double;
    TmpDIB : TN_DIBObj;
    SSysInfo : string;
  begin

    with TK_CMEDDBAccess(K_CMEDAccess), CurSlidesDSet do
    begin

      SQL.Text := 'select ' +
          K_CMENDBSTFSlideDTImg      + ',' + K_CMENDBSTFSlideDTMapRoot + ',' +  // 0,1
          K_CMENDBSTFSlideSysInfo    + ',' +                                    // 2
          K_CMENDBSTFSlideCurFSize   + ',' + K_CMENDBSTFSlideSrcFSize  + ',' +  // 3,4
          K_CMENDBSTFSlideThumbnail  + ',' + K_CMENDBSTFSlideMapRoot   + ',' +  // 5,6
          K_CMENDBSTFSlideID +
          ' from ' + EDAGetSlideSelectFromStr( ) +
          ' where ' + K_CMENDBSTFSlideID + ' = ' + CSlide.ObjName;
      Filtered := false;
      Open;

      with CSlide, P^ do
      begin
        K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[2]), @CMSDB ); // SysInfo

//          CMSDB.PixWidth

        EDAGetSlideThumbnail( CSlide );
        UDDIB := CSlide.GetThumbnail();
        CSlide.PutDirChildSafe( K_CMSlideIndCurImg, UDDIB );
        CSlide.PutDirChildSafe( K_CMSlideIndThumbnail, nil );

        with UDDIB, DIBObj, DIBSize, CMSDB do
        begin
         // PixPermm
//            PixPermm

          CSlide.CreateMapRoot( X, Y );

          RGBDiff := GetMaxRGBDif( 0 );

          if RGBDiff <= 0 then // Convert TmpDIB to Gray CurDIB
          begin
            TmpDIB := DIBObj;
            N_Dump2Str( 'SlideDBStateByThumbnail convert to Grey8 start' );
            DIBObj := TN_DIBObj.Create( TmpDIB, 0, pfCustom, -1, epfGray8 );
            TmpDIB.CalcGrayDIB( DIBObj );
            FreeAndNil( TmpDIB );
            PixBits := 8;
            N_Dump2Str( 'SlideDBStateByThumbnail convert to Grey8 fin' );
          end
          else
          begin
            PixBits := 24;
            Exclude( CMSDB.SFlags, cmsfGreyScale );
          end;

          if CMSDB.SFlags * [cmsfProbablyCalibrated,cmsfUserCalibrated,cmsfAutoCalibrated] <> [] then
//            if PixPermm <> Round(72 * 100 / 2.54) / 1000 then
            PixPermm := PixPermm * X / PixWidth;

          DIBInfo.bmi.biXPelsPerMeter := Round(PixPermm * 1000);
          DIBInfo.bmi.biYPelsPerMeter := DIBInfo.bmi.biXPelsPerMeter;
          PixWidth  := X;
          PixHeight := Y;
          BytesSize := DIBObj.DIBInfo.bmi.biSizeImage;
        end; // with UDDIB, DIBObj, DIBSize do



        Exclude( CMSDB.SFlags, cmsfHasSrcImg );
        Include( CMSDB.SFlags, cmsfSaveSrcImg );
        CMSDTMapRootMod :=  EDAGetSyncTimestamp();

        EDAWaitForCurSlideRWLock( CSlide.ObjName, K_cmlfWrite );

        Edit;

        CurSlide := CSlide;

        // Save CurImg
        CSlide.GetCurrentImageSData( PData, DSize );
        K_ForceFilePath( FName );
        EDASlideDataToFile( PData, DSize, FName );

        // Save some fields
        TDateTimeField(FieldList[0]).Value := CMSDTMapRootMod;
        TDateTimeField(FieldList[1]).Value := CMSDTMapRootMod;
        if K_CMEDDBSysInfoSPLDTC.DTCode = 0 then
          K_CMEDDBSysInfoSPLDTC := K_GetExecTypeCodeSafe('TN_CMSlideSDBF');

        SSysInfo := K_SaveSPLDataToText( CMSDB, K_CMEDDBSysInfoSPLDTC.All );
        EDAPutStringFieldValue( FieldList[2], SSysInfo );
        FieldList[3].AsInteger := DSize;
        FieldList[4].AsInteger := 0;
      end; // // with CSlide, P^ do

      // Save Map Root
      EDASaveSlideMapRoot();

      UpdateBatch;
      Close;

      EDALockSlideForRW( CSlide.ObjName, K_cmlfFree);

      EDASaveSlidesListHistory( @CSlide, 1,
             EDABuildHistActionCode( K_shATChange, Ord(K_shCADBRecovery), Ord(K_shRDBCurImgFromThumb) ) )
    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSlidesDSet do

  end; // procedure CorrectSlideDBStateByThumbnail

  //////////////////////////////////////
  // Set Slide Unrecover State
  //
  procedure SetSlideUnrecoverState();
  begin
  // Slide is already locked - Store it as unconverted
    N_Dump1Str( 'DBICheck>> Skip DB Recover >> SlideID=' + CSlide.ObjName );
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin // Mark Slide as UnConverted
      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
        K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 2' +
        ' where ' + K_CMENDBSTFSlideID + ' = ' + CSlide.ObjName;
      Execute;
    end;
    Inc(SkipRDBCount);
  end; // procedure SetSlideUnrecoverState

  //////////////////////////////////////
  // Recover DB Slide State
  // Result - convertion code
  // -1 - File OK - Convertion is needed but it was not done
  //  0 - File OK, convertion is not needed or convertion is done
  //  3 - File corrupted - deserialization error
  //  4 - File corrupted - Load DIB error
  function RecoverDBSlideState : Integer;
  var
    SlideInfo : string;
    SaveGAMode : Boolean;
//    MarkAsUnrecoverFlag : Boolean;

  label LExit;

  begin
    Result := 0;

    SlideInfo := ' >> SlideID=' + CSlide.ObjName;
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      if Byte(CurSlideState) > 2 then
      begin // Try to delete Slide - Video Error or Img3D or Cur+Orig Img Errors
        // Copy Bad Files because they should be deleted during slide deletion
        if (K_cmicVideoError in CurSlideState) then
        begin
        // Copy Video File
          MoveCorruptedFile( FName, 1, TRUE );
        end
        else
        if (K_cmicImg3DError in CurSlideState) then
        begin
        // Copy Video File
          MoveCorruptedFile( FName, 2, TRUE );
        end
        else
        begin
          if (K_cmicCurError in CurSlideState) then
          begin
          // Copy Cur Image File
            MoveCorruptedFile( FName, 0, TRUE );
          end;
          if (K_cmicOrigError in CurSlideState) then
          begin
          // Copy Original Image File
            MoveCorruptedFile( FName1, 0, TRUE );
          end;
          if ChBRestoreFromThumbnail.Checked then
          begin // Restore Current by Thumbnail
            // Prepare Slide CurImg file and correct Slide DB State
            AddRepInfo( SPatID, CSlide.ObjName, 'Object image is restore from thumbnail', 1 );
            CorrectSlideDBStateByThumbnail( );
            Inc( RecCount );
            Exit;
          end;
        end;

        K_CMSCreateDeleteMode := 2; // Set DB Integrity Check Delete Mode for proper Statistic Event Code
        SaveGAMode := K_CMGAModeFlag;
        K_CMGAModeFlag := TRUE;
        GUISilentFlag := TRUE;
        CSlide.RefCounter := 2; // to prevent real slide object deletion
        K_CMSlidesDelete( @CSlide, 1, FALSE, FALSE );
        CSlide.RefCounter := 0; // for future slide object deletion
        GUISilentFlag := FALSE;
        K_CMGAModeFlag := SaveGAMode;
        K_CMSCreateDeleteMode := 0; // Set DB Integrity Check Delete Mode for proper Statistic Event Code

        if LockResCount > 0 then
        begin
          Inc( DelCount );
          CSlide.CMSlideMarker := FALSE;
          AddRepInfo( SPatID, CSlide.ObjName, 'Object unrecoverable (object is deleted)', 1 );
        end
        else
        begin
          SetSlideUnrecoverState();
          Result := -1;
          AddRepInfo( SPatID, CSlide.ObjName, 'Object is still undeleted because it is used by other user now.', 1 );
        end;
        LockResCount := 0;
      end // Try to delete Slide
      else
      begin // Try  to recover slide DB record and files
        EDALockSlides( @CSlide, 1, K_cmlrmDBRecoveryLock );
        if LockResCount = 0 then
        begin // Slide is already locked by other CMS - store it as unconverted
          SetSlideUnrecoverState();
          Result := -1;
          AddRepInfo( SPatID, CSlide.ObjName, 'Object is still unrecovered because it is used by other user now.', 1 );
        end
        else
        begin // recover slide DB record and files
          LockResCount := 0;
          if K_cmicCurError in CurSlideState then
          begin // Correct DB Record: Slide.CMSDB.SFlags, MapRootAttrs, Thumbnail
            MoveCorruptedFile( FName, 0 );
            RenameFile( FName1, FName );
            CorrectSlideDBState( );
            AddRepInfo( SPatID, CSlide.ObjName, 'Current object unrecoverable, îriginal object recovered', 1 );
          end // Correct DB Record: Slide.CMSDB.SFlags, MapRootAttrs, Thumbnail
          else if K_cmicOrigError in CurSlideState then
          begin // Correct DB Record: Slide.CMSDB.SFlags, MapRootAttrs
            MoveCorruptedFile( FName1, 0 );
            CorrectSlideDBState( );
            AddRepInfo( SPatID, CSlide.ObjName, 'Original object unrecoverable, current object recovered', 1 );
          end; // Correct DB Record: Slide.CMSDB.SFlags, MapRootAttrs
          Inc( RecCount );
        end; // Recover slide DB record and files
      end; // Try to recover slide DB record and files
    end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  end; // function RecoverDBSlideState

begin

// Process Slides Loop
  WText := '';
  if ChBOnlyUnRecovered.Checked then
    WText := ' Unrecovered Only';
  N_Dump1Str( 'DBICheck>> ' + BtStart.Caption + WText  );
  LockedSlides := nil; // precaution
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      N_CM_MainForm.CMMFFreeEdFrObjects();
      PImgData := nil;
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit;
//        goto FinExit; // ???
      end
      else
      begin
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
        begin
          with CurSQLCommand1 do // Prepare Slides Processed Flags
          begin
            if ChBOnlyUnRecovered.Checked then
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
                K_CMENDBSTFSlideSFlags + ' = ( CASE WHEN (' + K_CMENDBSTFSlideSFlags + ' & 2) = 2 THEN ' +
                K_CMENDBSTFSlideSFlags + ' & 254 ELSE (' + K_CMENDBSTFSlideSFlags + ' | 3) ^ 2 END );'
            else
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
                K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 252;';
            Execute;
          end;

          GetCommonCountersInfo(); // Reset Progress and Counters if START after CONTINUE
          ReportCount := 1;
          StartMSessionTS := 0;
          SkipRDBCount := 0;
          RecCount := 0;
          DelCount := 0;
          ErrCount := 0;
          ErrVideoCount := 0;
          ErrImg3DCount := 0;
          MoveVideoCount := 0;
          MoveImageCount := 0;
          MoveImg3DCount := 0;
          MoveImageBeforStudiesCount := 0;
          CheckFinishFlag := FALSE;
          ReportIsNeededFlag := FALSE;
          CheckStudiesFlag := FALSE;
        end;

        if StartMSessionTS = 0 then
          StartMSessionTS := Now();
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtReport.Enabled := FALSE;
        BtClose.Enabled := FALSE;
        SavedCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;
//          ChangeFSizeInfoFlag := FALSE;
      end;


      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Slides Files Check Loop
     //
      FillChar(VFInfo, SizeOf(VFInfo), 0);
      BadImgFolder := SlidesImgRootFolder + K_BadImg + '\';
      BadVideoFolder := SlidesMediaRootFolder + K_BadVideo + '\';
      BadImg3DFolder := SlidesImg3DRootFolder + K_BadImg3D + '\';

      N_Dump1Str( format( 'DBICheck>> Loop start >> %d of %d media object(s) is processed, %d media object(s) were skipped to recover.',
                          [ProcCount, AllCount, SkipRDBCount] ) );

      MarkAsDelShowFlag := K_CMMarkAsDelShowFlag;
      K_CMMarkAsDelShowFlag := TRUE;

      ////////////////////////////////////////////////
      //  Slides Check Loop
      //
      while TRUE do
      begin

        //////////////////////////////////////
        // Prepare Unchecked Slides portion
        //
        SQLStr := 'select top ' + IntToStr(CheckNumSlides) + ' ' +
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideID + ',' +         // 0
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFPatID + ',' +           // 1
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideDTCr + ',' +       // 2
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideSysInfo;           // 3
        if K_CMEnterpriseModeFlag then
          SQLStr := SQLStr +
    ',' + K_CMENDBLocFilesInfoTable +'.'+ K_CMENDBLFILocSlideFlags // 4
        else
          SQLStr := SQLStr + ',1';                                 // 4 is always 1
    // Add Thumbnail
        SQLStr := SQLStr + ','+ K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideThumbnail;         // 5

        SQL.Text := SQLStr + SQLCondStr;
        Filtered := false;
        Open;
        i := RecordCount;
        if i > 0 then
        begin
        // Build Selected Slides Objects
          SetLength( Slides, i );
          First();
          i := 0;
          while not Eof do
          begin
            Slides[i] := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1,
                N_UDCMSlideCI));
            with Slides[i], P^ do
            begin
              ObjName := FieldList[0].AsString;
              CMSPatID := FieldList[1].AsInteger;
              CMSDTCreated := TDateTimeField(FieldList[2]).Value;
              K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
//              EDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
              CMSlideMarker := (FieldList[4].AsInteger and 1) <> 0;
              if not (cmsfIsMediaObj in CMSDB.SFlags) and not (cmsfIsImg3DObj in CMSDB.SFlags) then
                EDAGetSlideThumbnail( TN_UDCMSlide(Slides[i]) );
            end;
            Next;
            Inc(i);
          end;
          Close();
        end
        else
        begin
        // No Slides are Selected - check Loop is finished
          Close();
          Break;
        end;

        //////////////////////////////////////
        //  Lock Slides to prevent deletion
        //
        EDALockSlides( TN_PUDCMSlide(@Slides[0]), i, K_cmlrmCheckFilesLock );
        LockedSlides := Copy(LockResSlides, 0, LockResCount );
        LockResCount := 0;
        //////////////////////////////////////
        //  Check Locked SLides
        //
        for i := 0 to High(LockedSlides) do
        begin
          CSlide := LockedSlides[i];
          with CSlide, P^ do
          begin

            SPatID := IntToStr(CMSPatID);
            LPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID ) +
                                 K_CMSlideGetFileDatePathSegm(CMSDTCreated);

            CurSlideState := [];
            if cmsfIsMediaObj in CMSDB.SFlags then
            begin  // Check Video
              FName := SlidesMediaRootFolder + LPath + K_CMSlideGetMediaFileNamePref(ObjName) + CMSDB.MediaFExt;
              if not FileExists( FName ) then
              begin
                AddRepInfo( SPatID, ObjName, 'Object video file is absent', 2 );
                CurSlideState := [K_cmicVideoError];
                Inc(ErrVideoCount);
              end
              else
              begin
              // Check Corruption
                if N_GetVideoFileInfo(FName, @VFInfo) <> 0 then
                begin
                  N_Dump1Str( 'DBICheck>> Video File Error >> ' + VFInfo.VFISError + ' ' +  FName );
                  AddRepInfo( SPatID, ObjName, 'Object video file corrupted', 2 );
                  CurSlideState := [K_cmicVideoError];
                end;
              end;
            end  // Check Video
            else
            if cmsfIsImg3DObj in CMSDB.SFlags then
            begin // Check 3D Images
       // 2020-09-25 add new condition for Dev3D objs
              if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
              begin
                FName := SlidesImg3DRootFolder + LPath + K_CMSlideGetImg3DFolderName(ObjName);
                CheckRes := EDACheckSlideImg3DData( FName, 2, Path1 );
                if CheckRes <> 0 then
                begin
                  if CheckRes = 1 then
                    AddRepInfo( SPatID, ObjName, '3D Object folder is absent', 2 );
                  if CheckRes = 2 then
                    AddRepInfo( SPatID, ObjName, format( '3D Object file %s is absent', [Path1] ), 2 );
                  if CheckRes = 3 then
                    AddRepInfo( SPatID, ObjName, format( '3D Object file %s is corrupted', [Path1] ), 2 );

                  CurSlideState := [K_cmicImg3DError];
                  Inc(ErrImg3DCount);
                end // if CheckRes <> 0 then
              end // if CMSDB.Capt3DDevObjName = '' then
{
 // 2020-07-28 add Capt3DDevObjName <> ''
              if CMSDB.Capt3DDevObjName = '' then
              begin
                FName := SlidesImg3DRootFolder + LPath + K_CMSlideGetImg3DFolderName(ObjName);
                CheckRes := EDACheckSlideImg3DData( FName, 2, Path1 );
                if CheckRes <> 0 then
                begin
                  if CheckRes = 1 then
                    AddRepInfo( SPatID, ObjName, '3D Object folder is absent', 2 );
                  if CheckRes = 2 then
                    AddRepInfo( SPatID, ObjName, format( '3D Object file %s is absent', [Path1] ), 2 );
                  if CheckRes = 3 then
                    AddRepInfo( SPatID, ObjName, format( '3D Object file %s is corrupted', [Path1] ), 2 );

                  CurSlideState := [K_cmicImg3DError];
                  Inc(ErrImg3DCount);
                end // if CheckRes <> 0 then
              end // if CMSDB.Capt3DDevObjName = '' then
}
            end   // Check 3D Images
            else
            begin // Check Image
              Path1 := SlidesImgRootFolder + LPath;
              FName := Path1 + K_CMSlideGetCurImgFileName(ObjName);
//              CheckRes := EDACheckSlideImageData( FName, PImgData, ImgDSize, CheckFize, 0 );
              CheckRes := EDACheckSlideImageData( FName, PImgData, ImgDSize, CheckFize, 1 );
              if CheckRes = 1 then
              begin
                AddRepInfo( SPatID, ObjName, 'Object image file is absent', 2 );
                CurSlideState := [K_cmicCurError];
              end
              else if CheckRes >= 2 then
              begin
                AddRepInfo( SPatID, ObjName, 'Object image file is corrupted', 2 );
                CurSlideState := [K_cmicCurError];
              end;

              if CMSlideMarker and (cmsfHasSrcImg in CMSDB.SFlags) then
              begin  // Check original Image (CMSlideMarker control ability in Enterprise mode)
                FName1 := Path1 + K_CMSlideGetSrcImgFileName(ObjName);
//                CheckRes := EDACheckSlideImageData( FName1, PImgData, ImgDSize, CheckFize, 0 );
                CheckRes := EDACheckSlideImageData( FName1, PImgData, ImgDSize, CheckFize, 1 );
                if CheckRes = 1 then
                begin
                  AddRepInfo( SPatID, ObjName, 'Object original image file is absent', 2 );
                  CurSlideState := CurSlideState + [K_cmicOrigError];
                end
                else if CheckRes >= 2 then
                begin
                  AddRepInfo( SPatID, ObjName, 'Object original image file is corrupted', 2 );
                  CurSlideState := CurSlideState + [K_cmicOrigError];
                end;
              end
              else if K_cmicCurError in CurSlideState then
              begin
              // Add K_cmicDelError to delete slide as unrecoverable if CurImage Error and Original Absent
                CurSlideState := CurSlideState + [K_cmicDelError];
              end;
            end; // Check Image

            CMSlideMarker := TRUE; // mark for control slide deletion
            if (CurSlideState <> []) and not K_CMEnterpriseModeFlag then
              RecoverDBSlideState();

            Inc(ProcCount);
            if AllCount > 0 then
              PBProgress.Position := Round(1000 * ProcCount / AllCount);
            LbEDProcCount.Text := IntToStr( ProcCount );
            LbEDProcCount.Refresh();
          end; // with CSlide, P^ do

        end; // for i := 0 to High(LockedSlides) do

        //////////////////////////////////////
        //  Remove Deleted Slide Objects
        //
        j := 0;
        for i := 0 to High(LockedSlides) do
        begin
           if not LockedSlides[i].CMSlideMarker then Continue;
           LockedSlides[j] := LockedSlides[i];
           Inc(j);
        end; // for i := 0 to High(LockedSlides) do
        SetLength( LockedSlides, j );

        if Length(LockedSlides) > 0 then
        begin

        //////////////////////////////////////
        //  Unlock Locked SLides
        //
          EDAUnLockSlides( @LockedSlides[0], Length(LockedSlides), K_cmlrmCheckFilesLock );

        //////////////////////////////////////
        //  Set Checked Flag to Checked SLides
        //
          //  Build Slides List Select Condition
{
          SQLStr := K_CMENDBSTFSlideID + ' = ' + LockedSlides[0].ObjName;
          for i := 1 to High(LockedSlides) do
            SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + LockedSlides[i].ObjName;
}
          EDABuildSelectSQLBySlidesList( TN_PUDCMSlide(LockedSlides), Length(LockedSlides), @SQLStr, nil );

          // Set Slides Processed Flags
          with CurSQLCommand1 do
          begin
            CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
              K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 1' +
              ' where ' + SQLStr;
            Execute;
          end;

          LockResCount := 0; // to prevent Objects Control Check

        end; // // while TRUE do // Slides Check Loop


        // Delete Slide Objects
        for i := 0 to High(Slides) do
          Slides[i].UDDelete();

        UpdateDBCommonInfo( ErrCount );

//        sleep(500);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Files Check Loop
   //////////////////////////////////////
      end; // while TRUE do // Slides Check Loop

      K_CMMarkAsDelShowFlag := MarkAsDelShowFlag;

      CheckStudiesFlag := TRUE;
      MoveImageBeforStudiesCount := MoveImageCount;
      StudyUpdateCount := 0;

CheckStudies:
      ////////////////////////////////////////////////
      //  Studies Check Loop
      //
      if K_CMEDDBVersion >= 24 then
      while TRUE do // Studies Check Loop
      begin

        //////////////////////////////////////
        // Prepare Unchecked Studies portion
        //
        SQL.Text := 'select top ' + IntToStr(CheckNumSlides) + ' ' +
          EDAGetSlideSelectFieldsStr( [K_sffAddStudyOnlyFields] ) +
          ' from ' + EDAGetSlideSelectFromStr( ) +
          ' where ' + K_CMENDBSTFSlideStudyID + ' < 0 and '  + K_CMENDBSTFSlideSFlags + ' & 1 = 0';
        Filtered := false;
        Open;
        i := RecordCount;
        if i > 0 then
        begin
        // Build Selected Studies Objects
          SetLength( Slides, i );
          First();
          i := 0;
          while not Eof do
          begin
            Slides[i] := TN_UDCMStudy(K_CreateUDByRTypeName( 'TN_CMSlide', 1,
                                                             N_UDCMStudyCI ));

            EDAStudyGetFields( TN_UDCMStudy(Slides[i]), CurDSet2 );
            Next;
            Inc(i);
          end;
          Close();
        end else
        begin
        // No Studies are Selected - check Loop is finished
          Close();
          Break;
        end;

        //////////////////////////////////////
        //  Lock Studies to prevent deletion
        //
        EDALockSlides( TN_PUDCMSlide(@Slides[0]), i, K_cmlrmCheckFilesLock );
        LockedSlides := Copy(LockResSlides, 0, LockResCount );
        LockResCount := 0;

        //////////////////////////////////////
        //  Check Locked Studies
        //
        for i := 0 to High(LockedSlides) do
        begin
          CStudy := TN_UDCMStudy(LockedSlides[i]);
          with CStudy, P^ do
          begin
            SPatID := IntToStr(CMSPatID);
            LPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID ) +
                                 K_CMSlideGetFileDatePathSegm(CMSDTCreated);

            Path1 := SlidesImgRootFolder + LPath;
            FName := Path1 + K_CMStudyGetFileName(ObjName);

            if not FileExists( FName ) then
            begin
              CurSlideState := [K_cmicStudyFileAbsent];
              AddRepInfo( SPatID, ObjName, 'Study file is absent', 2 );
            end
            else
            if K_edFails = EDAStudyGetAttrsFromFile( FName, TmpStrings ) then
            begin
              CurSlideState := [K_cmicStudyFileCorrupted];
              AddRepInfo( SPatID, ObjName, 'Study file is corrupted', 2 );
            end
            else
            begin
              EDAStudyGetLinksInfoFromDB( ObjName, CurDSet3, SlideStudyInfoUpdateStrings );
              TmpStrings.Sort;
              for j := 0 to SlideStudyInfoUpdateStrings.Count - 1 do
              begin
                if TmpStrings.Find( SlideStudyInfoUpdateStrings[j], N_i ) then Continue;
                CurSlideState := [K_cmicStudyFileLinkErrors];
                N_Dump1Str( 'DBICheck>> Study ID=' +ObjName + ' link to Slide ID ' + SlideStudyInfoUpdateStrings[j] + ' item is absent ' );
              end;
              if TmpStrings.Count <> SlideStudyInfoUpdateStrings.Count then
              begin
                CurSlideState := [K_cmicStudyFileLinkErrors];
                N_Dump1Str( format( 'DBICheck>> Study ID=%s file links number=%d DB links number=%d',
                                   [ObjName,TmpStrings.Count,SlideStudyInfoUpdateStrings.Count] ) );
              end;

              if K_cmicStudyFileLinkErrors in CurSlideState  then
                AddRepInfo( SPatID, ObjName, 'Study file links errors', 2 );

            end;

            if CurSlideState <> [] then
            begin
              if (K_cmicStudyFileAbsent in CurSlideState) or
                 (K_cmicStudyFileCorrupted in CurSlideState) then
                EDAStudyGetLinksInfoFromDB( ObjName, CurDSet3, SlideStudyInfoUpdateStrings );

              if not (K_cmicStudyFileAbsent in CurSlideState) then
                MoveCorruptedFile( FName, 0, FALSE );

              EDAStudySaveAttrsToFile( ObjName, Path1, P(),
                                       CStudy.CMSStudySampleID, CStudy.CMSStudyItemsCount,
                                       SlideStudyInfoUpdateStrings );
              Inc(StudyUpdateCount);
            end;

            Inc(ProcCount);
            if AllCount > 0 then
              PBProgress.Position := Round(1000 * ProcCount / AllCount);
            LbEDProcCount.Text := IntToStr( ProcCount );
            LbEDProcCount.Refresh();
          end; // with CSlide, P^ do

        end; // for i := 0 to High(LockedSlides) do

      //////////////////////////////////////
      //  Unlock Locked SLides
      //
        EDAUnLockSlides( @LockedSlides[0], Length(LockedSlides), K_cmlrmCheckFilesLock );

      //////////////////////////////////////
      //  Set Checked Flag to Checked SLides
      //
        //  Build Slides List Select Condition
{
        SQLStr := K_CMENDBSTFSlideID + ' = ' + LockedSlides[0].ObjName;
        for i := 1 to High(LockedSlides) do
          SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + LockedSlides[i].ObjName;
}
        EDABuildSelectSQLBySlidesList( TN_PUDCMSlide(LockedSlides), Length(LockedSlides), @SQLStr, nil );

        // Set Slides Processed Flags
        with CurSQLCommand1 do
        begin
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
            K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 1' +
            ' where ' + SQLStr;
          Execute;
        end;

        // Delete Slide Objects
        for i := 0 to High(Slides) do
          Slides[i].UDDelete();

        UpdateDBCommonInfo( ErrCount ); // not needed because study check has no errors - only warnings

//        sleep(500);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Files Check Loop
   //////////////////////////////////////
      end; // while TRUE do // Studies Check Loop

      SlideStudyInfoUpdateStrings.Clear;

      // Clear Slides Processed Flags
      with CurSQLCommand1 do
      begin
        CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
          K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 254;';
        Execute;

        if K_CMEDDBVersion >= 27 then
          EDAChangeFixStudyDataMode( TRUE );

      end;
      UpdateDBCommonInfo( 0 );
//      PBProgress.Position := 0;

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;

      ChBOnlyUnRecovered.Enabled := SkipRDBCount > 0;
      ChBOnlyUnRecovered.Checked := ChBOnlyUnRecovered.Enabled;

FinExit:
      Screen.Cursor := SavedCursor;
      BtReport.Enabled := ErrCount > 0;
      BtClose.Enabled := TRUE;
      EDAFreeBuffer( PImgData );

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := K_CML1Form.LLLIntegrityCheck3.Caption;
//        ' Integrity check is %s. %d of %d media object(s) were processed, %d file errors were detected.';

      if not K_CMEnterpriseModeFlag then
      begin
        if ErrCount > 0 then
          WText := WText + #13#10 + K_CML1Form.LLLIntegrityCheck4.Caption;
//                 ' %d media object(s) were recovered. %d media object(s) were deleted.';

        if SkipRDBCount > 0 then
          WText := WText + #13#10 + K_CML1Form.LLLIntegrityCheck5.Caption;
//                ' %d media objects(s) were not recovered because they were opened by other user(s)!';

      end;

      FileErrText := format( WText, [ResText, ProcCount, AllCount, ErrCount, RecCount, DelCount, SkipRDBCount] );

      if not K_CMEnterpriseModeFlag then
      begin
        if MoveImageBeforStudiesCount > 0 then
          FileErrText :=
             format( '%s'#13#10 + K_CML1Form.LLLIntegrityCheck6.Caption,
//                     ' %d corrupted image file(s) were moved to %s',
                     [FileErrText, MoveImageBeforStudiesCount, BadImgFolder] );
        if MoveVideoCount > 0 then
          FileErrText :=
             format( '%s'#13#10 + K_CML1Form.LLLIntegrityCheck7.Caption,
//                     ' %d corrupted video file(s) were moved to %s',
                     [FileErrText, MoveVideoCount, BadVideoFolder] );
        if MoveImg3DCount > 0 then
          FileErrText :=
             format( '%s'#13#10 + K_CML1Form.LLLIntegrityCheck9.Caption,
//                     ' %d corrupted 3D object(s) were moved to %s',
                     [FileErrText, MoveImg3DCount, BadImg3DFolder] );
      end;

      if CheckStudiesFlag and (StudyUpdateCount > 0) then
        FileErrText :=
           format( '%s'#13#10 + K_CML1Form.LLLIntegrityCheck8.Caption,
//                     ' %d study file(s) were updated',
                   [FileErrText, StudyUpdateCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

      if ReportIsNeededFlag and (BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]) then //'Start') then
        BtReportClick(Sender);

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMIntegrityCheck.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMIntegrityCheck.BtStartClick

//***************************************** TK_FormCMIntegrityCheck.BtReportClick ***
//  On Button Report Click Handler
//
procedure TK_FormCMIntegrityCheck.BtReportClick(Sender: TObject);
begin

  with TK_FormCMReportShow.Create(Application) do
  begin
    ReportDataSMatr := Copy( ReportSMatr, 0, ReportCount );
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PrepareRAFrameByDataSMatr( format( K_CML1Form.LLLReport7.Caption,
    // 'Maintenance errors report from %s to %s'
          [K_DateTimeToStr( StartMSessionTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ),
           K_DateTimeToStr( Now(), 'yyyy-mm-dd hh:nn:ss AM/PM' )] ) );
{
         'Maintenance errors report from ' +
            K_DateTimeToStr( StartMSessionTS, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
        ' to ' +
            K_DateTimeToStr( Now(), 'yyyy-mm-dd hh:nn:ss AM/PM' ) );
}
    FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);

    ShowModal;
  end;

  if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then // 'Start' then
    ReportIsNeededFlag := FALSE;

end; // TK_FormCMIntegrityCheck.BtReportClick

//****************************************** TK_FormCMIntegrityCheck.AddRepInfo ***
// Add Report Info
//
//     Parameters
// APatientInfo - Patien Report Info
// ASlideInfo   - Slide Report Info
// AErrInfo     - Error Report Info
// ACountErrors - Count Errors Flag
//
procedure TK_FormCMIntegrityCheck.AddRepInfo( APatientInfo, ASlideInfo, AErrInfo : string;
                                              ACountErrorsMode : Integer = 0 );
begin
  if ReportCount >= Length(ReportSMatr) then
    SetLength( ReportSMatr, ReportCount + 100 );

  SetLength( ReportSMatr[ReportCount], 3 );

  ReportSMatr[ReportCount][0] := APatientInfo;
  ReportSMatr[ReportCount][1] := ASlideInfo;
  ReportSMatr[ReportCount][2] := AErrInfo;

  Inc(ReportCount);

  if ACountErrorsMode = 0 then Exit;
  N_Dump1Str( 'DBICheck>> Report ' + ASlideInfo + ' >> ' + AErrInfo );
  if ACountErrorsMode = 1 then Exit;
  Inc(ErrCount);
  LbEDErrCount.Text := IntToStr( ErrCount );
  ReportIsNeededFlag := TRUE;
end; // TK_FormCMIntegrityCheck.AddRepInfo

//***************************************** TK_FormCMIntegrityCheck.GetCommonCountersInfo ***
//  Get Common Counters Info
//
procedure TK_FormCMIntegrityCheck.GetCommonCountersInfo;
var
  DT : TDateTime;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

   //////////////////////////////////////
   // Maintenance Common Info
   //
      SQL.Text := 'select ' +
        K_CMENDBGTFMaintenanceTS + ',' +
        K_CMENDBGTFMaintenanceErr +
        ' from ' + K_CMENDBGlobAttrsTable;
      Filtered := false;
      Open;
      DT := TDateTimeField(FieldList.Fields[0]).Value;
      if DT <> 0 then
        LbEDLastDBMTS.Text := K_DateTimeToStr( DT, 'yyyy"/"mm"/"dd' );
      ErrCount := FieldList.Fields[1].AsInteger;
      LbEDErrCount.Text := IntToStr( ErrCount );
      Close();

     //////////////////////////////////////
     // Maintenance Slides Process DB Info
     //
      SQL.Text := 'select Count(*), ' + K_CMENDBSTFSlideSFlags + ' & 3' +
      SQLFrom + SQLWhere1 +
      ' group by ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideSFlags + ' & 3;';

// Debug Code to View and Edit SQL
//      N_s := SQL.Text;
//      with TK_FormTextEdit.Create(Application) do
//        EditText( N_s );

      Open;

      ProcCount := 0;
      SkipRDBCount := 0;
      AllCount := 0;
      RecCount := 0;
      DelCount := 0;
      while not EOF do
      begin
        AllCount := AllCount + FieldList.Fields[0].AsInteger; // 0 + 1 + 2 + 3
        if FieldList.Fields[1].AsInteger = 1 then // 1 - processed by Integrity check
          ProcCount := ProcCount + FieldList.Fields[0].AsInteger
        else
        if FieldList.Fields[1].AsInteger = 2 then // 2 - marked as unrecoverable
          SkipRDBCount := SkipRDBCount + FieldList.Fields[0].AsInteger
        else
        if FieldList.Fields[1].AsInteger = 3 then // 3 - marked as unrecove and processed by integrity check
        begin
          ProcCount := ProcCount + FieldList.Fields[0].AsInteger;
          SkipRDBCount := SkipRDBCount + FieldList.Fields[0].AsInteger;
        end;

        Next();
      end;

      Close();

      LbEDBMediaCount.Text := IntToStr( AllCount );
      LbEDProcCount.Text := IntToStr( ProcCount );
      PBProgress.Max := 1000;
      PBProgress.Position := 0;
      if AllCount > 0 then
        PBProgress.Position := Round(1000 * ProcCount / AllCount);


    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMIntegrityCheck.GetCommonCountersInfo ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;


end; // TK_FormCMIntegrityCheck.GetCommonCountersInfo;

end.
