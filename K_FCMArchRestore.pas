unit K_FCMArchRestore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_Lib0, K_FPathNameFr, K_CM0;

type
  TK_FormCMArchRestore = class(TN_BaseForm)
    BtClose: TButton;
    BtStart: TButton;
    Timer: TTimer;
    GBDBState: TGroupBox;
    LbEMCountDB: TLabeledEdit;
    LbEMCountArchived: TLabeledEdit;
    GBRestoringAttrs: TGroupBox;
    LbEMCountToBeRestored: TLabeledEdit;
    FPNFrame: TK_FPathNameFrame;
    GBRestoring: TGroupBox;
    LbEDProcCount: TLabeledEdit;
    PBProgress: TProgressBar;
    LbInfo: TLabel;
    RGArchRest: TRadioGroup;
    BtRecoverLink: TButton;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure RGArchRestClick(Sender: TObject);
    procedure BtRecoverLinkClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;

    // New Vars
    SQLFromWhereStr1, SQLFromWhereStr2: string;
    ArchivePath : string;
    ArchCountDB,             // Archived in DB
    QueueCountDB,            // Queue in DB
    ArchCountQReal,          // Really Archived included in queue
    ArchCountReal,           // Really Archived
    ArchCount,               // Should be Archived
    ProcCount,               // Processed
    RestCountDB,             // Restored from archive in DB
    RestModeInd : Integer;
    StartInit  : Boolean;
    ProperArchive : Boolean;
    Slide : TN_UDCMSlide;
    LinkFilePath : string;
    LPatPath : string;
    LDTPath : string;
    PrevPat : Integer;
    PrevDate : TDateTime;
    ErrCount : Integer;      // Copy files Errors
    DelErrCount : Integer;   // Delete files Errors
    CurT : TN_CPUTimer1;
    ResT : TN_CPUTimer1;

    procedure OnArchPathChange();
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMArchRestore: TK_FormCMArchRestore;

procedure K_CMArchRestoreDlg( );

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CLib0, K_Script1, K_CML1F, K_UDT2, K_RImage,{K_FEText,}
  N_Lib1, N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2;

const K_Img   = 'Img\';
const K_Video = 'Video\';
const K_Img3D = 'Img3D\';
const ArchLinkFileName = 'CMSDBLink.dat';

procedure K_CMArchRestoreDlg( );
begin
//  N_Dump1Str( 'K_CMArchRestoreDlg Start' );

  K_FormCMArchRestore := TK_FormCMArchRestore.Create(Application);
  with K_FormCMArchRestore do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_Dump1Str( 'K_CMArchRestoreDlg before show' );
    ShowModal();
//    N_Dump1Str( 'K_CMArchRestoreDlg after show' );

    K_FormCMArchRestore := nil;

    // Save Arch Save State to Global Context
    K_CMEDAccess.EDASaveContextsData(
       [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
        K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
        K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
        K_cmssSkipExtIniInfo,
        K_cmssSaveGlobal2Info] );
  end;
//  N_Dump1Str( 'K_CMArchRestoreDlg Fin' );

end; // procedure K_CMUTPrepDBDataDlg



//***************************************** TK_FormCMArchRestore.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMArchRestore.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
  StartInit := TRUE;
  ProperArchive := FALSE;
  FPNFrame.OnChange := OnArchPathChange;
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;
  ProcCount := 0;
  ArchCount := 0;
  ErrCount  := 0;
  DelErrCount := 0;
  ArchCountReal := 0;
  ArchCountQReal := 0;
  Slide := nil;
  CheckFinishFlag := FALSE;
  CurT := TN_CPUTimer1.Create;
  ResT := TN_CPUTimer1.Create;

  Timer.Enabled := TRUE;


end; // TK_FormCMArchRestore.FormShow

//******************************************** TK_FormCMArchRestore.TimerTimer ***
//  On Timer Handler
//
procedure TK_FormCMArchRestore.TimerTimer( Sender: TObject );
var
  AllCount, CurCount, CurType : Integer;
begin
  ResT.Start;
  Timer.Enabled := FALSE;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  LbInfo.Caption  := ' Please wait ... ';
  LbInfo.Refresh;

  BtStart.Enabled := FALSE;
  BtClose.Enabled := FALSE;
  FPNFrame.Enabled := FALSE;

  if StartInit then
  begin
    AllCount := 0;     // should be 0 + 1 + 2 + 3
    ArchCountDB := 0;  // should be 2 + 3
    QueueCountDB := 0; // should be 2
    RestCountDB := 0;  // should be 1
    CurT.Start;
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
      Filtered := FALSE;

     //////////////////////////////////////
     // Slides DB Info
     //
      SQLFromWhereStr1 := ' from ' + K_CMENDBSlidesTable +
                ' where ' + K_CMENDBSTFSlideThumbnail + ' is null';
      SQLFromWhereStr2 := SQLFromWhereStr1 + ' and ' +
                ' not (' + K_CMENDBSTFSlideDTArch + ' is null)'; // This condition should be the same as for case 2 
//        'Date(' + K_CMENDBSTFSlideDTCr + ') < ' + K_CMENDBSTFSlideDTArch;

      SQL.Text := 'select Count(*),' +
                  '(CASE ' +
                      'WHEN not(' + K_CMENDBSTFSlideThumbnail + ' is null) and ' +
                         ' Date(' + K_CMENDBSTFSlideDTCr + ') >= ' + K_CMENDBSTFSlideDTArch + ' then 0 ' +
                      'WHEN not(' + K_CMENDBSTFSlideThumbnail + ' is null) and ' +
                         ' Date(' + K_CMENDBSTFSlideDTCr + ') < ' + K_CMENDBSTFSlideDTArch + ' then 1 ' +
                      'WHEN ' + K_CMENDBSTFSlideThumbnail + ' is null and not ('
                              + K_CMENDBSTFSlideDTArch + ' is null) then 2 ' +
                      'WHEN ' + K_CMENDBSTFSlideThumbnail + ' is null and '
                              + K_CMENDBSTFSlideDTArch + ' is null then 3 ' +
                  ' END) AS TYPE FROM ' + K_CMENDBSlidesTable +
                  ' WHERE ' + K_CMENDBSTFSlideStudyID + ' >= 0 ' +
                  ' GROUP BY TYPE;';

      Open;
      while not EOF do
      begin
        CurCount := Fields[0].AsInteger;
        CurType  := Fields[1].AsInteger;
        AllCount := AllCount + CurCount; // 0 + 1 + 2 + 3
        case CurType of
        1: RestCountDB := RestCountDB + CurCount;
        2: begin
          ArchCountDB := ArchCountDB + CurCount;
          QueueCountDB := CurCount;
        end;
        3: ArchCountDB := ArchCountDB + CurCount;
        end;
        Next();
      end;
      Close;
      LbEMCountDB.Text := IntToStr(AllCount);
      LbEMCountDB.Refresh;

      LbEMCountArchived.Text := format( '%d (%d)', [ArchCountDB,QueueCountDB] );
      LbEMCountArchived.Refresh;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchRestore.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
    CurT.Stop;
    N_Dump1Str( 'ArchRest>> Slides DB Info get Time=' + CurT.ToStr() );

    N_Dump1Str( format( 'ArchRest>> Slides DB all objects %d, archived %d, queue %d',
                [AllCount, ArchCountDB, QueueCountDB] ) );

    RGArchRest.ItemIndex := RestModeInd;

    StartInit := FALSE;

    if ArchivePath <> '' then
      FPNFrame.AddNameToTop( ArchivePath )
    else
      OnArchPathChange();
  end;

  FPNFrame.Enabled := TRUE;
  BtClose.Enabled := TRUE;
  LbInfo.Caption  := '';
  Screen.Cursor := SavedCursor;

  ResT.Stop;
  N_Dump1Str( 'ArchRest>> TimerTimer Time=' + ResT.ToStr() );

end; // procedure TK_FormCMArchRestore.TimerTimer

//**************************************** TK_FormCMArchRestore.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMArchRestore.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( 'Do you really want to break archiving?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if ProcCount < ArchCount then
    N_Dump1Str( 'ArchRest>> Break by user' );

  if not CheckFinishFlag then
    TK_CMEDDBAccess(K_CMEDAccess).CurDSet2.Close;

  TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientSlidesUpdateTS();

  Slide.Free;
  CurT.Free;
  ResT.Free;

end; // TK_FormCMArchRestore.FormCloseQuery

//***************************************** TK_FormCMArchRestore.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMArchRestore.BtStartClick(Sender: TObject);
var
  SQLFromWhereStr, WText, ResText, FileErrText, PatChangeFName : string;
  CopyErrCount : Integer;
  PortionStartProcCount : Integer;
  DT : TDateTime;

label FinExit;

  function RestoreSlideThumbnail() : Integer;
  var
    FStream : TFileStream;
    DBStream : TStream;
    SrcFName, FPath : string;
    CopyThumbFromArchFlag : Boolean;
  begin
    N_Dump2Str( 'ArchRest>> Restore thumbnail start' );
    FStream := nil;
    DBStream := nil;
    try
      with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
      begin
        if cmsfIsMediaObj in CMSDB.SFlags then      // Video
          FPath := K_Video
        else if cmsfIsImg3DObj in CMSDB.SFlags then // Img3D
          FPath := K_Img3D
        else                                        // Img
          FPath := K_Img;

        CurDSet2.Edit;

        //Copy Thumbnail to DB from archive file
        SrcFName :=  ArchivePath + FPath + LPatPath + LDTPath + K_CMSlideGetArchThumbFileName(ObjName);
        CopyThumbFromArchFlag := TRUE;

        ///////////////////////////////////////////
        // 2D Image slides special processing because
        // Slide Thumbnail stored in archive may be not proper
        // because of slide image auto rotate while archived slide
        // is Dismount or Mount from/to some study position
        //
        if FPath = K_Img then
        begin // Image Icon Date - 1 day < MapRoot change date (-1 day - precaution to skip TimeZone and so on
          CopyThumbFromArchFlag := K_GetFileAge( SrcFName ) - 1 >= TDateTimeField(CurDSet2.Fields[6]).Value;
          if not CopyThumbFromArchFlag then
          begin // Rebuild Thumbnail
            CurT.Start;
            // Create Slide New Thumbnail and put it serialized value to blob DB field
            EDPutBlobFieldFromDIB( CurDSet2, CurDSet2.Fields[5],
                                   Slide.CreateThumbnail().DIBObj,
                                   rietJPG, K_CMSlideThumbQuality );
            // Free All Slide TN_UDDIB objects
            Slide.PutDirChildSafe( K_CMSlideIndCurImg, nil );
            Slide.PutDirChildSafe( K_CMSlideIndMapRoot, nil );
            Slide.PutDirChildSafe( K_CMSlideIndThumbnail, nil );
            CurT.Stop;
            N_Dump1Str( format( 'ArchRest>> Thumbnail rebuild ID%s Time=%s',
                              [ObjName, CurT.ToStr()] ) );
          end;
        end; // if FPath = K_Img then

        ///////////////////////////////////////////
        // Copy Slide Thumbnail stored in archive
        // directly to blob DB field
        //
        if CopyThumbFromArchFlag then
        begin
          CurT.Start;
          FStream :=  TFileStream.Create( SrcFName, fmOpenRead );
          DBStream := CurDSet2.CreateBlobStream( CurDSet2.Fields[5], bmWrite );
          FStream.Seek( 0, soFromBeginning );
          DBStream.Seek( 0, soFromBeginning );
          DBStream.CopyFrom( FStream, 0 );
          FreeAndNil( DBStream);
          FreeAndNil( FStream );
          CurT.Stop;
          N_Dump1Str( format( 'ArchRest>> Thumbnail from File=%s Time=%s',
                            [SrcFName, CurT.ToStr()] ) );
        end;

        // Set Now() or DTCr to DTDB
        if RestModeInd = 0 then
          DT := Slide.P.CMSDTCreated
        else
          DT := EDAGetSyncTimestamp();
        TDateTimeField(CurDSet2.Fields[3]).Value := DT;

        with CurDSet2.Fields[7] do
          AsInteger := AsInteger and 239; // clear not del files flag (255 - 16)
        CurT.Start;
        CurDSet2.UpdateBatch(); // Real save changes to DB
        CurT.Stop;
        N_Dump1Str( 'ArchRest>> Set Slide restore state Time=' + CurT.ToStr() );

        Result := 0;
        N_Dump2Str( 'ArchRest>> Restore Slide Thumbnail ID=' + ObjName );
      end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
    except
      on E: Exception do
      begin
        N_Dump1Str( format( 'ArchRest>> Restore Slide Thumbnail from %s exception:'#13#10' %s', [SrcFName,E.Message] ) );
        Result := 1;
        FStream.Free;
        DBStream.Free;
      end;
    end;
  end; // procedure RestoreSlideThumbnail

  function FCopyFile( const ASrcFile, ADstFile : string ) : Integer;
  var
    ResCode : Integer;
  begin
    ResCode := K_CopyFile( ASrcFile, ADstFile, [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
    Result := 0;
    if ResCode > 0 then
      Result := 1;
    case ResCode of
      0: N_Dump2Str( 'ArchRest>> Copy File ' + ASrcFile );
      3: N_Dump1Str( 'ArchRest>> Couldn''t copy Src doesn''t exist ' + ASrcFile );
      4: N_Dump1Str( 'ArchRest>> Couldn''t copy ' + ASrcFile );
      5: N_Dump1Str( 'ArchRest>> Couldn''t create Dst path ' + ADstFile );
    end;
  end; // function FCopyFile

  function FDeleteFile( const ASrcFile : string ) : Integer;
  begin
    Result := 0;
    if K_DeleteFile( ASrcFile, [K_dofDeleteReadOnly] ) then Exit;
    Result := 1;
    N_Dump1Str( 'ArchRest>> Couldn''t delete ' + ASrcFile );
  end; // function FDeleteFile

  function CopyAllMediaFiles() : Integer;
  var
    SrcFName, SrcFName1, FPath : string;
    UndelCount, CopyCount : Integer;
    OK3DFlag : Boolean;
  begin
    // N_Dump2Str( 'ArchRest>> Copy media files' );
    // Img Video Img3D
    // ...
    with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
    begin
      if PrevPat <>  CMSPatID then
        LPatPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID );
      PrevPat := CMSPatID;

      if PrevDate <> CMSDTCreated then
        LDTPath := K_CMSlideGetFileDatePathSegm( CMSDTCreated );
      PrevDate := CMSDTCreated;

      UndelCount := 0;
      FPath := LPatPath + LDTPath;
      if cmsfIsMediaObj in CMSDB.SFlags then
      begin // Video
        SrcFName := FPath + K_CMSlideGetMediaFileNamePref(ObjName) + CMSDB.MediaFExt;
        CurT.Start;
        Result := FCopyFile( ArchivePath + K_Video + SrcFName, SlidesMediaRootFolder + SrcFName );
        CurT.Stop;
        N_Dump1Str( format( 'ArchRest>> Copy Slide Video File=%s Time=%s',
                            [SrcFName, CurT.ToStr()] ) );

        if Result = 0 then
          Result := RestoreSlideThumbnail();

        if Result = 1 then
        begin
          CurT.Start;
          UndelCount := FDeleteFile( SlidesMediaRootFolder + SrcFName );
          CurT.Stop;
          N_Dump1Str( format( 'ArchRest>> Del Slide File=%s Time=%s',
                        [SrcFName, CurT.ToStr()] ) );
        end;
      end
      else // Video
      if cmsfIsImg3DObj in CMSDB.SFlags then
      begin // Img3D
        SrcFName := FPath + K_CMSlideGetImg3DFolderName(ObjName);

// 2020-07-28 add Capt3DDevObjName <> ''  OK3DFlag := CMSDB.Capt3DDevObjName <> '';

// 2020-07-28 add Capt3DDevObjName <> ''  if not OK3DFlag then


// 2020-09-25 add new condition for Dev3D objs
        OK3DFlag := (CMSDB.Capt3DDevObjName <> '') and (CMSDB.MediaFExt <> '');
        if not OK3DFlag then
        begin
          CurT.Start;
          OK3DFlag := K_CopyFolderFiles( ArchivePath + K_Img3d + SrcFName, SlidesImg3DRootFolder + SrcFName,
                                  '*.*', [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
          CurT.Stop;
          N_Dump1Str( format( 'ArchRest>> Copy Slide 3D Files from %s Time=%s',
                              [SrcFName, CurT.ToStr()] ) );
        end;

        if not OK3DFlag then
        begin
          Result := 1;
          N_Dump1Str( 'ArchRest>> Couldn''t copy ' + SlidesImg3DRootFolder + SrcFName );
          K_CMEDAccess.TmpStrings.Clear();
          CurT.Start;
          K_DeleteFolderFilesEx( SlidesImg3DRootFolder + SrcFName, K_CMEDAccess.TmpStrings,
                                '*.*', [K_dffRecurseSubfolders, K_dffRemoveReadOnly] );
          CurT.Stop;
          N_Dump1Str( format( 'ArchRest>> Del Slide 3D Files from %s Time=%s',
                              [SrcFName, CurT.ToStr()] ) );
          UndelCount := K_CMEDAccess.TmpStrings.Count;
          if UndelCount > 0 then
            N_Dump1Str( 'ArchRest>> Couldn''t delete files '#13#10 + K_CMEDAccess.TmpStrings.Text );
        end
        else
        begin
          Result := RestoreSlideThumbnail();
        end;
      end   // Img3D
      else
      begin // Img
        CopyCount := 0;
        CurT.Start;
        SrcFName := FPath + K_CMSlideGetCurImgFileName(ObjName);
        Result := FCopyFile( ArchivePath + K_Img + SrcFName, SlidesImgRootFolder + SrcFName );
        if Result = 0 then
          CopyCount := 1;
        if (Result = 0) and (cmsfHasSrcImg in CMSDB.SFlags) then
        begin
          SrcFName1 := FPath + K_CMSlideGetSrcImgFileName(ObjName);
          Result := FCopyFile( ArchivePath + K_Img + SrcFName1, SlidesImgRootFolder + SrcFName1 );
          if Result = 0 then
            CopyCount := 2;
        end;
        CurT.Stop;
        N_Dump1Str( format( 'ArchRest>> Copy Slide Img Files %s Count=%d AllTime=%s AverageTime=%s',
                            [SrcFName, CopyCount, CurT.ToStr(), CurT.ToStr(CopyCount)] ) );

        if Result = 0 then
          Result := RestoreSlideThumbnail();

        if Result > 0 then
        begin
          CurT.Start;
          UndelCount := FDeleteFile( SlidesImgRootFolder + SrcFName );
          if (cmsfHasSrcImg in CMSDB.SFlags) and FileExists( SlidesImgRootFolder + SrcFName1 ) then
            UndelCount := UndelCount + FDeleteFile( SlidesImgRootFolder + SrcFName1 );
          CurT.Stop;
          N_Dump1Str( format( 'ArchRest>> Del Slide Files %s Time=%s',
                        [SrcFName, CurT.ToStr()] ) );
        end;
      end; // Img

      if UndelCount > 0 then
      begin
        DelErrCount := DelErrCount + UndelCount;
        with CurDSet2.Fields[7] do
          AsInteger := AsInteger or 16; // set not del files flag (255 - 16)
        CurT.Start;
        CurDSet2.UpdateBatch(); // Real save changes to DB
        CurT.Stop;
        N_Dump1Str( 'ArchRest>> Set Slide non-deleted files state Time=' + CurT.ToStr() );
      end;
    end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  end; // procedure CopyAllMediaFiles

begin

// Process Slides Loop
  N_Dump1Str( format( 'ArchRest>> Loop %s >> %d of %d media object(s) is processed.',
                      [BtStart.Caption, ProcCount, ArchCount] ) );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    ExtDataErrorCode := K_eeDBSelect;
    Connection := LANDBConnection;
    try
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin // if BtStart.Caption = 'Pause' then
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit;
      end   // if BtStart.Caption = 'Pause' then
      else
      begin // if BtStart.Caption <> 'Pause' then
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
        begin
          FPNFrame.Enabled := FALSE;
          PrevPat := -1;
          PrevDate := 0;
          ProcCount := 0;
          ErrCount  := 0;
          DelErrCount := 0;
          ArchCountReal := 0;
          ArchCountQReal := 0;

          Slide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));

          case RestModeInd of
          0: SQLFromWhereStr := SQLFromWhereStr1; // All archived restore
          1: SQLFromWhereStr := SQLFromWhereStr2; // Queue archived restore
          end;

          SQL.Text := 'select ' +
      K_CMENDBSTFSlideID + ',' + K_CMENDBSTFPatID + ',' +               // 0, 1
      K_CMENDBSTFSlideDTCr + ',' + K_CMENDBSTFSlideDTArch + ',' +       // 2, 3
      K_CMENDBSTFSlideSysInfo + ',' + K_CMENDBSTFSlideThumbnail + ',' + // 4, 5
      K_CMENDBSTFSlideDTMapRoot + ',' + K_CMENDBSTFSlideSFlags +        // 6, 7
      SQLFromWhereStr +
      ' order by ' + K_CMENDBSTFPatID + ', ' + K_CMENDBSTFSlideDTCr;
          CurT.Start;
          Open();
          CurT.Stop;
          N_Dump1Str( 'ArchRest>> Slides DB select Time=' + CurT.ToStr() );

          RGArchRest.Enabled := FALSE;
          BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        end; // if BtStart.Caption = 'Start' then

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Enabled := FALSE;
      end; // if BtStart.Caption <> 'Pause' then

      LbInfo.Caption  := ' Restoring from archive is in process ... ';
      LbInfo.Refresh;

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;

      ResT.Start;
      PortionStartProcCount := ProcCount;
      ////////////////////////////////////////////////
      //  Slides Check Loop
      //
      while not EOF do
      begin
        with Slide, P^ do
        begin
          ObjName := FieldList[0].AsString;
          CMSPatID := FieldList[1].AsInteger;
          CMSDTCreated := TDateTimeField(FieldList[2]).Value;
          CMSArchDate  := TDateTimeField(FieldList[3]).Value;
          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[4]), @CMSDB);
          N_Dump2Str( format( 'ArchRest>> Start ID=%s processing.',[ObjName] ) );

          // Set Patient Change View Flag
          if (PrevPat <> CMSPatID) and (PrevPat <> -1) then
          begin
            PatChangeFName := SlidesImgRootFolder + LPatPath + '!';
            K_ForceFilePath( PatChangeFName );
            with TFileStream.Create( PatChangeFName, fmCreate ) do
              Free();
          end;

          CopyErrCount := CopyAllMediaFiles();
          if CopyErrCount = 0 then
          begin
            Inc(ArchCountReal);
            if CMSArchDate <> 0 then
              Inc(ArchCountQReal);
            EDASaveSlidesListHistory( @Slide, 1, EDABuildHistActionCode(
                             K_shATNotChange,
                             Ord(K_shNCAArchive),
                             Ord(K_shNCAArchRestFrom) ) );
          end
          else
            ErrCount := ErrCount + CopyErrCount;
        end; // with Slide, P^ do

        Inc(ProcCount);
        if ArchCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / ArchCount);

        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();

        LbEMCountArchived.Text := format( '%d (%d)', [ArchCountDB - ArchCountReal,
                                                      QueueCountDB - ArchCountQReal] );
        LbEMCountArchived.Refresh();

        Next;
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE
      end; // while not EOF do

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtStart.Enabled := FALSE;
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;
      Close;

FinExit:
      ResT.Stop;
      N_Dump1Str( format( 'ArchRest>> Restoring files portion=%d AllTime=%s AverageTime=%s',
                  [ProcCount - PortionStartProcCount, ResT.ToStr(),
                   ResT.ToStr(ProcCount - PortionStartProcCount)] ) );

      // Set Patient Change View Flag
      if LPatPath <> '' then
      begin
        PatChangeFName := SlidesImgRootFolder + LPatPath + '!';
        K_ForceFilePath( PatChangeFName );
        with TFileStream.Create( PatChangeFName, fmCreate ) do
          Free();
      end;

      LbInfo.Caption  := '';
      LbInfo.Refresh;

      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';


      WText := ' Restoring is %s. %d of %d media object(s) were processed.';

//ProcCount := 10;
//ArchCount := 10;
//ArchCountReal := 10;
//DelErrCount := 8;

      if (ProcCount > ArchCountReal) or (DelErrCount > 0) then
        WText := WText + #13#10 +
                 ' %d media objects(s) were not restored because of copy errors!';

      if DelErrCount > 0 then
        WText := WText + #13#10 +
                 ' %d file(s) of not restored media object(s) were not deleted from file storage.';

      FileErrText := format( WText, [ResText, ProcCount, ArchCount, ProcCount - ArchCountReal, DelErrCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchRestore.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMArchRestore.BtStartClick

//************************ ************* TK_FormCMArchRestore.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMArchRestore.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( 'Archive', 'RestModeInd', RestModeInd );
  N_StringToMemIni( 'Archive', 'RootFolder', ArchivePath );
end; // procedure TK_FormCMArchRestore.CurStateToMemIni

//************************************** TK_FormCMArchRestore.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMArchRestore.MemIniToCurState;
begin
  inherited;
  RestModeInd := N_MemIniToInt( 'Archive', 'RestModeInd', 0 );
  ArchivePath := N_MemIniToString( 'Archive', 'RootFolder', '' );
end; // procedure TK_FormCMArchRestore.MemIniToCurState

//************************************** TK_FormCMArchRestore.OnArchPathChange ***
// On archive path change
//
procedure TK_FormCMArchRestore.OnArchPathChange;
var
  ErrCode : Integer;
  ErrStr : string;
  SL : TStringList;

begin
  if FPNFrame.mbPathName.Text = '' then
  begin
    ProperArchive := FALSE;
    BtStart.Enabled := FALSE;
    BtRecoverLink.Enabled := FALSE;
    Exit;
  end;

  ArchivePath := IncludeTrailingPathDelimiter(FPNFrame.mbPathName.Text);
  LinkFilePath := ArchivePath + ArchLinkFileName;
  ProperArchive := (ArchCountDB = 0) and (RestCountDB = 0); // Archive should be empty
  ErrStr := '';
  if FileExists(LinkFilePath) then
  begin
    SL := TStringList.Create;
    ErrStr := K_VFLoadStrings1( LinkFilePath, SL, ErrCode );
    ProperArchive := ErrStr = '';
    if ProperArchive then
    begin
      ProperArchive := SL[0] = K_CMEDAccess.EDAGetDBUID;
      if not ProperArchive then
        ErrStr := 'LinkFile is not linked to this DB';
    end;
    SL.Free;
  end
  else
  if not ProperArchive then
    ErrStr := 'LinkFile is absent';

  if not ProperArchive then
  begin
    BtRecoverLink.Enabled := TRUE;
    N_Dump1Str( format( 'Archive LinkFile %s error >> %s', [LinkFilePath,ErrStr] ) );
    K_CMShowMessageDlg( //sysout
        'Not proper archive path is given!!!', mtError );
  end;
  BtStart.Enabled := ProperArchive and (ArchCount > 0);
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMArchRestore.OnArchPathChange

//************************************ TK_FormCMArchRestore.RGArchRestClick ***
//  RGArchRest Click Handler
//
procedure TK_FormCMArchRestore.RGArchRestClick(Sender: TObject);
begin
  RestModeInd := RGArchRest.ItemIndex;

  case RestModeInd of
  0: ArchCount := ArchCountDB;  // Archived in DB
  1: ArchCount := QueueCountDB; // Queue in DB
  end;

  LbEMCountToBeRestored.Text := IntToStr(ArchCount);
  BtStart.Enabled := ProperArchive and (ArchCount > 0);
//BtStart.Enabled := TRUE;
end; // procedure TK_FormCMArchRestore.RGArchRestClick

//********************************* TK_FormCMArchRestore.BtRecoverLinkClick ***
//  BtRecoverLink Click Handler
//
procedure TK_FormCMArchRestore.BtRecoverLinkClick(Sender: TObject);
var
  FileErrText : string;
  SL : TStringList;
begin

  FileErrText := '';
  if not K_ForceDirPath( ArchivePath ) then
    FileErrText := 'Couldn''t create CMSuite Archive root folder!!!'
  else
  begin
    SL := TStringList.Create;
    SL.Add( K_CMEDAccess.EDAGetDBUID );
    if not K_VFSaveStrings( SL, LinkFilePath, K_DFCreateEncryptedSrc ) then
      FileErrText := 'Couldn''t create CMSuite link archive file. Archiving couldn''t be started!!!';
    SL.Free;
  end;

  if FileErrText <> '' then
    K_CMShowMessageDlg( {sysout}  FileErrText, mtError )
  else
    OnArchPathChange; // for restoring context after link recover
end; // procedure TK_FormCMArchRestore.BtRecoverLinkClick

end.
