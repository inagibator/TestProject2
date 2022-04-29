unit K_FCMArchSave;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_Lib0, K_FPathNameFr, K_CM0;

type
  TK_FormCMArchSave = class(TN_BaseForm)
    BtClose: TButton;
    BtStart: TButton;
    Timer: TTimer;
    GBDBState: TGroupBox;
    LbEMCountDB: TLabeledEdit;
    LbEMCountArchived: TLabeledEdit;
    GBArchivingAttrs: TGroupBox;
    LbEMCountToBeArchived: TLabeledEdit;
    FPNFrame: TK_FPathNameFrame;
    LbCopyMedia: TLabel;
    DTPFrom: TDateTimePicker;
    GBArchiving: TGroupBox;
    LbEDProcCount: TLabeledEdit;
    PBProgress: TProgressBar;
    LbInfo: TLabel;
    ChBArchVideo: TCheckBox;
    ChBArchImg3D: TCheckBox;
    BtDeleteFiles: TButton;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure DTPFromChange(Sender: TObject);
    procedure ChBArchVideoClick(Sender: TObject);
    procedure BtDeleteFilesClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;

    // New Vars
    SQLFromWhereStr : string;
    ArchivePath : string;
    ArchCountDB,             // Archived in DB
    ArchCountReal,           // Really Archived
    ArchCount,               // Should be Archived
    ProcCount,               // processed
    RestCountDB,             // Restored from archive in DB
    DBUnDelFilesSlidesCount,
    ProcDelCount,            // processed slides with non-deleted files
    StartDelCount,           // start slides count with non-deleted files
    PeriodInDays : Integer;
    StartInit    : Boolean;
    ProperArchive : Boolean;
    Slide : TN_UDCMSlide;
    LinkFilePath : string;
    LPatPath : string;
    LDTPath : string;
    PrevPat : Integer;
    PrevDate : TDateTime;
    ErrCount : Integer;      // Copy files Errors
    UnDelFilesCount : Integer;   // Delete files Errors
    UnDelFilesSlidesCount : Integer;// Slides with Delete files Errors
    UndelCount : Integer;
    CurT : TN_CPUTimer1;     // Slide Delete files Errors
    ResT : TN_CPUTimer1;
    BtDelFilesInitCapt : string;
    DelFilesProcessFlag : Boolean;
    ArchFPathSegm, SrcFName, SrcFName1 : string;

    procedure CalcArchCountByDate();
    procedure OnArchPathChange();
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMArchSave: TK_FormCMArchSave;

procedure K_CMArchSaveDlg( );

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CLib0, K_Script1, K_CML1F, K_UDT2, {K_FEText,}
  N_Lib1, N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2;

const K_Img   = 'Img\';
const K_Video = 'Video\';
const K_Img3D = 'Img3D\';
const ArchLinkFileName = 'CMSDBLink.dat';


//************************************************************* FDeleteFile ***
//  Delete file and Dump if fail
//
function FDeleteFile( const ASrcFile : string ) : Integer;
begin
  Result := 0;
  if K_DeleteFile( ASrcFile, [K_dofDeleteReadOnly] ) then Exit;
  Result := 1;
  N_Dump1Str( 'ArchSave>> Couldn''t delete ' + ASrcFile );
end; // function FDeleteFile

//****************************************************** FDeleteFolderFiles ***
//  Delete folder files and Dump if fail
//
function FDeleteFolderFiles( const ARootFolder, ADelFolder : string ) : Integer;
begin
  K_CMEDAccess.TmpStrings.Clear();

  K_FormCMArchSave.CurT.Start;
  K_DeleteFolderFilesEx( ARootFolder + ADelFolder, K_CMEDAccess.TmpStrings,
                        '*.*', [K_dffRecurseSubfolders, K_dffRemoveReadOnly] );
  K_FormCMArchSave.CurT.Stop;
  N_Dump1Str( format( 'ArchSave>> Del Slide files from %s Time=%s',
                    [ADelFolder, K_FormCMArchSave.CurT.ToStr()] ) );

  Result := K_CMEDAccess.TmpStrings.Count;
  if Result > 0 then
    N_Dump1Str( 'ArchSave>> Couldn''t delete files '#13#10 + K_CMEDAccess.TmpStrings.Text );

end; // function FDeleteFolderFiles

procedure FDelMediaFiles( const ASrcFName, ASrcFName1 : string);
begin
  with K_FormCMArchSave, TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  begin
    if cmsfIsMediaObj in CMSDB.SFlags then
    begin // Video
      CurT.Start;
      UndelCount := FDeleteFile( SlidesMediaRootFolder + ASrcFName );
      CurT.Stop;
      N_Dump1Str( format( 'ArchSave>> Del Slide Video File=%s Time=%s',
                        [ASrcFName, CurT.ToStr()] ) );
    end
    else // Video
    if cmsfIsImg3DObj in CMSDB.SFlags then
    begin // Img3D
     // 2020-09-25 add new condition for Dev3D objs
      if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
        UndelCount := FDeleteFolderFiles( SlidesImg3DRootFolder, ASrcFName );
    end   // Img3D
    else
    begin // Img
      CurT.Start;
      UndelCount := FDeleteFile( SlidesImgRootFolder + ASrcFName );
      if cmsfHasSrcImg in CMSDB.SFlags then
        UndelCount := UndelCount + FDeleteFile( SlidesImgRootFolder + ASrcFName1 );
      CurT.Stop;
      N_Dump1Str( format( 'ArchSave>> Del Slide Img Files %s Time=%s',
                        [ASrcFName, CurT.ToStr()] ) );
    end; // Img
    UnDelFilesCount := UnDelFilesCount + UndelCount;
    Inc(UnDelFilesSlidesCount);
  end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
end; // procedure FDelMediaFiles


procedure FPrepCopyDelFiles( out ASrcFName, ASrcFName1 : string; var AFPath : string  );
begin
  // N_Dump2Str( 'ArchSave>> Copy media files' );
  // Img Video Img3D
  // ...
  with K_FormCMArchSave, TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  begin
    if PrevPat <>  CMSPatID then
      LPatPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID );

    if PrevDate <> CMSDTCreated then
      LDTPath := K_CMSlideGetFileDatePathSegm( CMSDTCreated );

    if (PrevPat <>  CMSPatID) or (PrevDate <> CMSDTCreated) then
    AFPath := LPatPath + LDTPath;

    PrevDate := CMSDTCreated;
    PrevPat := CMSPatID;

    ASrcFName1 := '';
    if cmsfIsMediaObj in CMSDB.SFlags then // Video
      ASrcFName := AFPath + K_CMSlideGetMediaFileNamePref(ObjName) + CMSDB.MediaFExt
    else
    if cmsfIsImg3DObj in CMSDB.SFlags then // Img3D
      ASrcFName := AFPath + K_CMSlideGetImg3DFolderName(ObjName)
    else
    begin // Img
      ASrcFName := AFPath + K_CMSlideGetCurImgFileName(ObjName);
      if cmsfHasSrcImg in CMSDB.SFlags then
        ASrcFName1 := AFPath + K_CMSlideGetSrcImgFileName(ObjName);
    end; // Img
  end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
end; // procedure FPrepCopyDelFiles

//********************************************************* K_CMArchSaveDlg ***
//  Archiving Dialog
//
procedure K_CMArchSaveDlg( );
begin
//  N_Dump1Str( 'K_CMArchSaveDlg Start' );

  K_FormCMArchSave := TK_FormCMArchSave.Create(Application);
  with K_FormCMArchSave do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_Dump1Str( 'K_CMArchSaveDlg before show' );
    ShowModal();
//    N_Dump1Str( 'K_CMArchSaveDlg after show' );

    K_FormCMArchSave := nil;

    // Save Arch Save State to Global Context
    K_CMEDAccess.EDASaveContextsData(
       [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
        K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
        K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
        K_cmssSkipExtIniInfo,
        K_cmssSaveGlobal2Info] );
  end;
//  N_Dump1Str( 'K_CMArchSaveDlg Fin' );

end; // procedure K_CMUTPrepDBDataDlg

//********************************************** TK_FormCMArchSave.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMArchSave.FormShow(Sender: TObject);
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
  UnDelFilesCount := 0;
  UnDelFilesSlidesCount := 0;
  ArchCountReal := 0;
  ProcDelCount := 0;
  StartDelCount := 0;
  Slide := nil;
  CheckFinishFlag := FALSE;
  CurT := TN_CPUTimer1.Create;
  ResT := TN_CPUTimer1.Create;
  BtDelFilesInitCapt := BtDeleteFiles.Caption;
  DelFilesProcessFlag := FALSE;

  Timer.Enabled := TRUE;

end; // TK_FormCMArchSave.FormShow

//******************************************** TK_FormCMArchSave.TimerTimer ***
//  On Timer Handler
//
procedure TK_FormCMArchSave.TimerTimer( Sender: TObject );
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
    DTPFrom.Enabled := FALSE;
    AllCount := 0; // should be 0 + 1 + 2 + 3
    ArchCountDB := 0; // should be 0 + 1
    DBUnDelFilesSlidesCount := 0;
    RestCountDB := 0;
    CurT.Start;
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
      Filtered := FALSE;

     //////////////////////////////////////
     // Slides DB Info
     //
      SQL.Text := 'select Count(*),'+
                '(CASE ' +
                    'WHEN ' + K_CMENDBSTFSlideThumbnail + ' is null and ('+
                              K_CMENDBSTFSlideSFlags + ' & 16) = 0 then 0 ' +
                    'WHEN ' + K_CMENDBSTFSlideThumbnail + ' is null and ('+
                              K_CMENDBSTFSlideSFlags + ' & 16) <> 0 then 1 ' +
                    'WHEN not(' + K_CMENDBSTFSlideThumbnail + ' is null) and ' +
                       ' Date(' + K_CMENDBSTFSlideDTCr + ') < ' + K_CMENDBSTFSlideDTArch + ' then 2 ' +
                    'WHEN not(' + K_CMENDBSTFSlideThumbnail + ' is null) and ' +
                       ' Date(' + K_CMENDBSTFSlideDTCr + ') = ' + K_CMENDBSTFSlideDTArch + ' then 3 ' +
                    'END) AS TYPE FROM ' + K_CMENDBSlidesTable +
                ' WHERE ' + K_CMENDBSTFSlideStudyID + ' >= 0 ' +
                ' GROUP BY TYPE;';


      Open();
      while not EOF do
      begin
        CurCount := Fields[0].AsInteger;
        CurType  := Fields[1].AsInteger;
        AllCount := AllCount + CurCount; // 0 + 1 + 2 + 3
        case CurType of
        0: ArchCountDB := ArchCountDB + CurCount;
        1: begin
          ArchCountDB := ArchCountDB + CurCount;
          DBUnDelFilesSlidesCount := CurCount;
        end;
        2: RestCountDB := CurCount;
        end;
        Next();
      end; // while not EOF do
      Close;

      LbEMCountDB.Text := IntToStr(AllCount);
      LbEMCountDB.Refresh;

      LbEMCountArchived.Text := format('%d (%d)', [ArchCountDB,
                                                   DBUnDelFilesSlidesCount] );
      LbEMCountArchived.Refresh;
      BtDeleteFiles.Enabled := DBUnDelFilesSlidesCount > 0;
      StartDelCount := DBUnDelFilesSlidesCount;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchSave.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
    CurT.Stop;
    N_Dump1Str( 'ArchSave>> Slides DB Info get Time=' + CurT.ToStr() );

    N_Dump1Str( format( 'ArchSave>> Slides DB all objects (restored) %d (%d), archived (with non-del files) %d (%d)',
                [AllCount, RestCountDB, ArchCountDB, DBUnDelFilesSlidesCount] ) );



    if PeriodInDays = 0 then
      PeriodInDays := 5 * 365;

    DTPFrom.DateTime := Now() - PeriodInDays;
    DTPFromChange(nil);

    StartInit := FALSE;
    if ArchivePath <> '' then
      FPNFrame.AddNameToTop( ArchivePath )
    else
      OnArchPathChange();
    DTPFrom.Enabled := TRUE;
  end  // if StartInit then
  else // if not StartInit then
    CalcArchCountByDate();

  FPNFrame.Enabled := TRUE;
  BtClose.Enabled := TRUE;
  LbInfo.Caption  := '';
  Screen.Cursor := SavedCursor;

  ResT.Stop;
  N_Dump1Str( 'ArchSave>> TimerTimer Time=' + ResT.ToStr() );


end; // procedure TK_FormCMArchSave.TimerTimer

//**************************************** TK_FormCMArchSave.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMArchSave.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2])  //'Pause'
                                   and
              (BtDeleteFiles.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]);

  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( 'Do you really want to break the process?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if ((ProcCount < ArchCount) and not DelFilesProcessFlag)
                        or
     ((ProcDelCount < StartDelCount) and DelFilesProcessFlag) then
    N_Dump1Str( 'ArchSave>> Break by user' );

// Clear Global context and free objects
  if not CheckFinishFlag then
    TK_CMEDDBAccess(K_CMEDAccess).CurDSet2.Close;

  TK_CMEDDBAccess(K_CMEDAccess).LockResCount := 0;
  TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientSlidesUpdateTS();

  Slide.Free;
  CurT.Free;
  ResT.Free;

end; // TK_FormCMArchSave.FormCloseQuery

//***************************************** TK_FormCMArchSave.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMArchSave.BtStartClick(Sender: TObject);
var
  WText, ResText, FileErrText : string;
  SL : TStringList;
  CopyErrCount, PortionStartProcCount : Integer;
  FullDstFName1, PatChangeFName  : string;
  SQLSetNonDelFilesFlag : string;

label FinExit, ContProc;

  function CopySlideThumbnail() : Integer;
  var
    FStream : TFileStream;
    DBStream : TStream;
    DstFName, DstFPathSegm : string;
  begin
    N_Dump2Str( 'ArchSave>> Save slide thumbnail start' );
    FStream := nil;
    DBStream := nil;
    try
      with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
      begin
        if PrevPat <>  CMSPatID then
          LPatPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID );
        PrevPat := CMSPatID;

        if PrevDate <> CMSDTCreated then
          LDTPath := K_CMSlideGetFileDatePathSegm( CMSDTCreated );
        PrevDate := CMSDTCreated;

        if cmsfIsMediaObj in CMSDB.SFlags then      // Video
          DstFPathSegm := K_Video
        else if cmsfIsImg3DObj in CMSDB.SFlags then // Img3D
          DstFPathSegm := K_Img3D
        else                                        // Img
          DstFPathSegm := K_Img;

        CurT.Start;
        DstFName :=  ArchivePath + DstFPathSegm + LPatPath + LDTPath + K_CMSlideGetArchThumbFileName(ObjName);
        FStream :=  TFileStream.Create( DstFName, fmCreate );
        DBStream := CurDSet2.CreateBlobStream( CurDSet2.Fields[8], bmRead );
        FStream.Seek( 0, soFromBeginning );
        DBStream.Seek( 0, soFromBeginning );
        FStream.CopyFrom( DBStream, 0 );
        FreeAndNil( FStream );
        FreeAndNil( DBStream);
        CurT.Stop;
        N_Dump1Str( format( 'ArchSave>> Copy Slide Thumbnail Time=%s',
                            [CurT.ToStr()] ) );
        Result := 0;
//        DelFilesFlag := TRUE;
        N_Dump2Str( 'ArchSave>> Save Slide Thumbnail to ' + DstFName );
      end;
    except
      on E: Exception do
      begin
        N_Dump1Str( format( 'ArchSave>> Save Slide Thumbnail to %s exception:'#13#10' %s', [DstFName,E.Message] ) );
        Result := 1;
        FStream.Free;
        DBStream.Free;
      end;
    end;
  end; // procedure CopySlideThumbnail

  function FCopyFile( const ASrcFile, ADstFile : string ) : Integer;
  var
    ResCode : Integer;
  begin
    ResCode := K_CopyFile( ASrcFile, ADstFile, [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
    Result := 0;
    if ResCode > 0 then
      Result := 1;
    case ResCode of
      0: N_Dump2Str( 'ArchSave>> Copy File ' + ASrcFile );
      3: N_Dump1Str( 'ArchSave>> Couldn''t copy Src doesn''t exist ' + ASrcFile );
      4: N_Dump1Str( 'ArchSave>> Couldn''t copy ' + ASrcFile );
      5: N_Dump1Str( 'ArchSave>> Couldn''t create Dst path ' + ADstFile );
    end;

  end; // function FCopyFile

  function CopyAllMediaFiles() : Integer;
  var
    CopyCount : Integer;
    OK3DFlag : Boolean;
//    Del3DFlag : Boolean;
  begin
    // N_Dump2Str( 'ArchSave>> Copy media files' );
    // Img Video Img3D
    // ...
    FPrepCopyDelFiles( SrcFName, SrcFName1, ArchFPathSegm );
    with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
    begin

      if cmsfIsMediaObj in CMSDB.SFlags then
      begin // Video
        CurT.Start;
        Result := FCopyFile( SlidesMediaRootFolder + SrcFName,  ArchivePath + K_Video + SrcFName );
        CurT.Stop;
        N_Dump1Str( format( 'ArchSave>> Copy Slide Video File=%s Time=%s',
                            [SrcFName, CurT.ToStr()] ) );

        if Result = 0 then
          Result := CopySlideThumbnail();

//        DelFilesFlag := Result = 0;
     end
     else // Video
     if cmsfIsImg3DObj in CMSDB.SFlags then
     begin // Img3D
       Result := 0;
// 2020-07-28 add Capt3DDevObjName <> ''  OK3DFlag := CMSDB.Capt3DDevObjName <> '';
//        Del3DFlag := not OK3DFlag;

// 2020-07-28 add Capt3DDevObjName <> ''  if not OK3DFlag then
// 2020-09-25 add new condition for Dev3D objs
       OK3DFlag := (CMSDB.Capt3DDevObjName <> '') and (CMSDB.MediaFExt <> '');
//       Del3DFlag := not OK3DFlag;
       if not OK3DFlag then
       begin
         CurT.Start;
         OK3DFlag := K_CopyFolderFiles( SlidesImg3DRootFolder + SrcFName, ArchivePath + K_Img3d + SrcFName,
                                  '*.*', [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
         CurT.Stop;
         N_Dump1Str( format( 'ArchSave>> Copy Slide 3D Files from %s Time=%s',
                            [SrcFName, CurT.ToStr()] ) );
         if not OK3DFlag then
         begin
           Result := 1;
           N_Dump1Str( 'ArchSave>> Couldn''t copy ' + SlidesImg3DRootFolder + SrcFName );
         end;
       end // if CMSDB.Capt3DDevObjName = '' then
       else
         N_Dump1Str( format( 'ArchSave>> Archived Slide ID=%s 3D Device=%s',
                            [ObjName, CMSDB.Capt3DDevObjName] ) );

       if OK3DFlag then
         Result := CopySlideThumbnail();

//        DelFilesFlag := (Result = 0) and Del3DFlag;
      end   // Img3D
      else
      begin // Img
        CopyCount := 0;
        CurT.Start;
        Result := FCopyFile( SlidesImgRootFolder + SrcFName, ArchivePath + K_Img + SrcFName );
        if Result = 0 then
          CopyCount := 1;
        if (Result = 0) and (cmsfHasSrcImg in CMSDB.SFlags) then
        begin
          FullDstFName1 := ArchivePath + K_Img + SrcFName1;
          if not FileExists( FullDstFName1 ) then
          begin
            Result := FCopyFile( SlidesImgRootFolder + SrcFName1, FullDstFName1 );
            if Result = 0 then
              CopyCount := 2;
          end;
        end;

        CurT.Stop;
        N_Dump1Str( format( 'ArchSave>> Copy Slide Img Files %s Count=%d AllTime=%s AverageTime=%s',
                            [SrcFName, CopyCount, CurT.ToStr(), CurT.ToStr(CopyCount)] ) );

        if Result = 0 then
          Result := CopySlideThumbnail();

//        DelFilesFlag := Result = 0;
      end; // Img
    end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  end; // function CopyAllMediaFiles


begin
// Process Slides Loop
  DelFilesProcessFlag := FALSE;
  N_Dump1Str( format( 'ArchSave>> Loop %s >> %d of %d media object(s) is processed.',
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
          DTPFrom.Enabled := FALSE;
          PrevPat := -1;
          PrevDate := 0;
          ProcCount := 0;
          ErrCount  := 0;
          UnDelFilesCount := 0;
          UnDelFilesSlidesCount := 0;
          ArchCountReal := 0;
          BtDeleteFiles.Enabled := FALSE;
          CheckFinishFlag := FALSE;

          Slide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));

  //          ChangeFSizeInfoFlag := FALSE;
          SQL.Text := 'select ' +
      K_CMENDBSTFSlideID        + ',' + K_CMENDBSTFPatID        + ',' + // 0, 1
      K_CMENDBSTFSlideDTCr      + ',' + K_CMENDBSTFSlideDTImg   + ',' + // 2, 3
      K_CMENDBSTFSlideDTMapRoot + ',' + K_CMENDBSTFSlideDTProp  + ',' + // 4, 5
      K_CMENDBSTFSlideDTArch    + ',' + K_CMENDBSTFSlideSysInfo + ',' + // 6, 7
      K_CMENDBSTFSlideThumbnail +  SQLFromWhereStr +                    // 8
      ' order by ' + K_CMENDBSTFPatID + ', ' + K_CMENDBSTFSlideDTCr;
          CurT.Start;
          Open();
          CurT.Stop;
          N_Dump1Str( 'ArchSave>> Slides DB select Time=' + CurT.ToStr() );

          if RecordCount > 0 then
          begin

            // CMSuite DB Link file create if needed
            LinkFilePath := ArchivePath + ArchLinkFileName;
            CurT.Start;
            if not FileExists(LinkFilePath) then
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
              begin
                Close;
                BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
                BtClose.Enabled := TRUE;
                FPNFrame.Enabled := TRUE;
                DTPFrom.Enabled := TRUE;
                K_CMShowMessageDlg( {sysout}  FileErrText, mtError );
                Exit;
              end;
            end; // if not FileExists(LinkFilePath) then
            CurT.Stop;
            N_Dump1Str( 'ArchSave>> Archive LinkFile prep Time=' + CurT.ToStr() );
          end; // if RecordCount > 0 then
        end; // if BtStart.Caption = 'Start' then


      end; // if BtStart.Caption <> 'Pause' then

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
      BtClose.Enabled := FALSE;

      LbInfo.Caption  := ' Archiving is in process ... ';
      LbInfo.Refresh;

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;

      ////////////////////////////////////////////////
      //  Slides Check Loop
      //
      ResT.Start;
      PortionStartProcCount := ProcCount;
      while not EOF do
      begin

        with Slide, P^ do
        begin
//          CurT.Start;
          ObjName := FieldList[0].AsString;
          CMSPatID := FieldList[1].AsInteger;
          CMSDTCreated := TDateTimeField(FieldList[2]).Value;
          CMSDTImgMod  := TDateTimeField(FieldList[3]).Value;
          CMSDTMapRootMod := TDateTimeField(FieldList[4]).Value;
          CMSDTPropMod    := TDateTimeField(FieldList[5]).Value;
          CMSArchDate     := TDateTimeField(FieldList[6]).Value;
          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[7]), @CMSDB);
//          DelFilesFlag := FALSE;
          N_Dump2Str( format( 'ArchSave>> Start ID=%s processing.',[ObjName] ) );
//          CurT.Stop;
//          N_Dump1Str( format('ArchSave>> ID=%s Slide Fields get Time=%s', [ObjName,CurT.ToStr()] ) );

          // Set Patient Change View Flag
          if (PrevPat <> CMSPatID) and (PrevPat <> -1) then
          begin
            PatChangeFName := SlidesImgRootFolder + LPatPath + '!';
            K_ForceFilePath( PatChangeFName );
            with TFileStream.Create( PatChangeFName, fmCreate ) do
              Free();
          end;

          CurT.Start;
          EDALockSlides( @Slide, 1, K_cmlrmCheckFilesLock );
          CurT.Stop;
          N_Dump1Str( format( 'ArchSave>> LockSlide ID=%s Time=%s', [ObjName, CurT.ToStr()] ) );

          if LockResCount = 1 then
          begin // Slide was Locked
            CopyErrCount := 0;
            if (Floor(CMSDTCreated - CMSArchDate) = 0) or (CMSDTImgMod > CMSArchDate) then
            begin
            // Copy Media Files and Thumbnail
              CopyErrCount := CopyAllMediaFiles();
            end
            else
            if CMSDTMapRootMod > CMSArchDate then
            begin
            // Copy Thumbnail Only
              CopyErrCount := CopySlideThumbnail();
              if CopyErrCount = 0 then
                FPrepCopyDelFiles( SrcFName, SrcFName1, ArchFPathSegm );
            end
            else
            begin
              FPrepCopyDelFiles( SrcFName, SrcFName1, ArchFPathSegm );
//              DelFilesFlag := TRUE; // Set Delete Files Flag because deletion files from FileStorage if needed
            end;

            if CopyErrCount = 0 then
            begin
// 2020-07-28 add Capt3DDevObjName <> '' if CMSDB.Capt3DDevObjName = '' then
     // 2020-09-25 add new condition for Dev3D objs
              if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
              begin
                if SQLSetNonDelFilesFlag = '' then
                  SQLSetNonDelFilesFlag := ', ' + K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 16';
              end
              else
                SQLSetNonDelFilesFlag := '';

              CurT.Start;
              with CurSQLCommand1 do
              begin // Clear Slide Thumbnail
                CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' set ' +
                  K_CMENDBSTFSlideThumbnail + ' =  NULL, ' +
                  K_CMENDBSTFSlideDTArch + ' = NULL ' +
                  SQLSetNonDelFilesFlag  +
                  ' where ' + K_CMENDBSTFSlideID + ' = ' + ObjName;
                Execute;
              end;
              CurT.Stop;
              N_Dump1Str( 'ArchSave>> Set Slide archived state Time=' + CurT.ToStr() );

              CurT.Start;
              EDASaveSlidesListHistory( @Slide, 1, EDABuildHistActionCode(
                                           K_shATNotChange,
                                           Ord(K_shNCAArchive),
                                           Ord(K_shNCAArchMoveTo) ) );
              CurT.Stop;
              N_Dump1Str( 'ArchSave>> Save Slide statistic Time=' + CurT.ToStr() );

              Inc(ArchCountReal);
            end
            else
              ErrCount := ErrCount + CopyErrCount;

            CurT.Start;
            EDAUnLockSlides( @Slide, 1, K_cmlrmCheckFilesLock );
            CurT.Stop;
            N_Dump1Str( 'ArchSave>> UnlockSlide Time=' + CurT.ToStr() );

// 2020-07-28 add Capt3DDevObjName <> '' if (CopyErrCount = 0) and (CMSDB.Capt3DDevObjName = '') then
     // 2020-09-25 add new condition for Dev3D objs
            if (CopyErrCount = 0) and ((CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '')) then
            begin
              UndelCount := 0;
              FDelMediaFiles( SrcFName, SrcFName1 );
              if UndelCount > 0 then
                Inc(DBUnDelFilesSlidesCount)
              else
              begin // if UndelCount = 0 then
                CurT.Start;
                with CurSQLCommand1 do
                begin // Clear UndelFiles Flag
                  CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' set ' +
                                             K_CMENDBSTFSlideSFlags + '=' + K_CMENDBSTFSlideSFlags + ' & 239' +
                                 ' WHERE ' + K_CMENDBSTFSlideID + ' = ' + ObjName;
                  Execute;
                end;
                CurT.Stop;
                N_Dump1Str( 'ArchSave>> Clear Slide non-deleted files state Time=' + CurT.ToStr() );
              end; // if UndelCount = 0 then
            end; // if (CopyErrCount = 0) and (CMSDB.Capt3DDevObjName = '') then
          end // if LockResCount = 1 then
          else
            N_Dump1Str( 'ArchSave>> Slide is locked by other user' );
        end; // with Slide, P^ do

ContProc: //***** continue processing
        Inc(ProcCount);
        if ArchCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / ArchCount);

        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();

        LbEMCountArchived.Text := format('%d (%d)', [ArchCountDB + ArchCountReal,
                                                     DBUnDelFilesSlidesCount] );
        LbEMCountArchived.Refresh();

//        CurT.Start;
        Next;
//        CurT.Stop;
//        N_Dump1Str( 'ArchSave>> Next Slide Time=' + CurT.ToStr() );

        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE
      end; // while not EOF do

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtStart.Enabled := FALSE;
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;
      BtDeleteFiles.Enabled := DBUnDelFilesSlidesCount > 0;

      Close;


FinExit:
      ResT.Stop;
      StartDelCount := DBUnDelFilesSlidesCount;
      N_Dump1Str( format( 'ArchSave>> Archiving portion=%d AllTime=%s AverageTime=%s',
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

      WText := ' Archiving is %s. %d of %d media object(s) were processed.';

//ProcCount :=10;
//ArchCount := 10;
//ArchCountReal := 10;
//ErrCount := 2;
//UnDelFilesCount := 4;
//UnDelFilesSlidesCount := 2;

      if (ProcCount > ArchCountReal) or
         (ErrCount > 0) or
         (UnDelFilesCount > 0) then
      begin
        WText := WText + #13#10 +
                 ' %d media object(s) were not archived because of copy error(s) or because they were opened by other user(s)!';

        if (ErrCount > 0) or (UnDelFilesCount > 0) then
          WText := WText + #13#10 +
                   ' %d copy file error(s) were detected.';

      end;

      if UnDelFilesCount > 0 then
        WText := WText + #13#10 +
                 ' %d file(s) of archived %d media object(s) were not deleted from file storage.';

      FileErrText := format( WText, [ResText, ProcCount, ArchCount,
                                     ProcCount - ArchCountReal,
                                     ErrCount, UnDelFilesCount,
                                     UnDelFilesSlidesCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

      if CheckFinishFlag then
      begin
        ArchCountDB := ArchCountDB + ArchCountReal;
        ArchCountReal := 0;
      end;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchSave.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMArchSave.BtStartClick


//***************************************** TK_FormCMArchSave.DTPFromChange ***
//  On DTPFrom Change Handler
//
procedure TK_FormCMArchSave.DTPFromChange(Sender: TObject);
begin
  if StartInit then
    CalcArchCountByDate()
  else
    Timer.Enabled := TRUE;

end; // procedure TK_FormCMArchSave.DTPFromChange

//************************************* TK_FormCMArchSave.ChBArchVideoClick ***
//  On DTPFrom Change Handler
//
procedure TK_FormCMArchSave.ChBArchVideoClick(Sender: TObject);
begin
  CalcArchCountByDate();
end; // procedure TK_FormCMArchSave.ChBArchVideoClick

//*********************************** TK_FormCMArchSave.CalcArchCountByDate ***
//  Get Common Counters Info
//
procedure TK_FormCMArchSave.CalcArchCountByDate;
var
  SQLCondStr : string;
begin
  CurT.Start;

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

// 2020-07-28 add Capt3DDevObjName <> ''
//      SQLCondStr := ' not (' + K_CMENDBSTFSlideSysInfo + ' like ''%Capt3D%'')';
//      SQLCondStr := '';
// 2020-09-25 add new condition for Dev3D objs
      SQLCondStr := ' not ((' + K_CMENDBSTFSlideSysInfo + ' like ''%Capt3D%'') or ('+
                                K_CMENDBSTFSlideSysInfo + ' like ''%MediaFExt%''))';
      if not ChBArchImg3D.Checked then
        SQLCondStr := ' not (' + K_CMENDBSTFSlideSysInfo + ' like ''%cmsfIsImg3DObj%'')';
      if not ChBArchVideo.Checked then
      begin
        if SQLCondStr <> '' then
          SQLCondStr := SQLCondStr + ' and ';
        SQLCondStr := SQLCondStr + ' not (' + K_CMENDBSTFSlideSysInfo + ' like ''%cmsfIsMediaObj%'')';
      end;

      if SQLCondStr <> '' then
        SQLCondStr := ' and ' + SQLCondStr;

      SQLFromWhereStr := ' from ' + K_CMENDBSlidesTable +
  //    ' where ' + K_CMENDBSTFSlideDTCr + ' < ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) ) + ' and ' +         // Old
  // BR: DTPFrom.Date - archiving media objects maximal date, so <= condition should be used
  //    ' where ' + K_CMENDBSTFSlideDTCr + ' <= ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) ) + ' and ' +         // Old
      ' where ' + K_CMENDBSTFSlideDTCr + ' < ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) + 1 ) + ' and ' +         // Old
                  K_CMENDBSTFSlideStudyID + ' >= 0 and ' +                                              // not Study
                  '(' + K_CMENDBSTFSlideFlags + ' = 0 or ' + K_CMENDBSTFSlideFlags + ' is null) and ' + // not marked as deleted
                  ' not (' + K_CMENDBSTFSlideThumbnail + ' is null)' +                               // not archived
                  SQLCondStr;

      SQL.Text := 'select Count(*) ' + SQLFromWhereStr;
      Open();
      ArchCount := FieldList.Fields[0].AsInteger;
      Close;

      LbEMCountToBeArchived.Text := IntToStr( ArchCount );
      LbEMCountToBeArchived.Refresh;

      PeriodInDays := Floor( Now() - DTPFrom.Date );
      BtStart.Enabled := ProperArchive and (ArchCount > 0);
//BtStart.Enabled := TRUE;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchSave.CalcArchCountByDate ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

  CurT.Stop;
  N_Dump1Str( 'ArchSave>> CalcArchCountByDate time=' + CurT.ToStr() );
end; // TK_FormCMArchSave.CalcArchCountByDate;

//************************ ************* TK_FormCMArchSave.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMArchSave.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( 'Archive', 'PeriodInDays', PeriodInDays );
  N_StringToMemIni( 'Archive', 'RootFolder', ArchivePath );
end; // procedure TK_FormCMArchSave.CurStateToMemIni

//************************************** TK_FormCMArchSave.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMArchSave.MemIniToCurState;
begin
  inherited;
  PeriodInDays := N_MemIniToInt( 'Archive', 'PeriodInDays', 0 );
  ArchivePath := N_MemIniToString( 'Archive', 'RootFolder', '' );
end; // procedure TK_FormCMArchSave.MemIniToCurState

//************************************** TK_FormCMArchSave.OnArchPathChange ***
// On archive path change
//
procedure TK_FormCMArchSave.OnArchPathChange;
var
  ErrCode : Integer;
  ErrStr : string;
  SL : TStringList;

begin
  if FPNFrame.mbPathName.Text = '' then
  begin
    ProperArchive := FALSE;
    BtStart.Enabled := FALSE;
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
    N_Dump1Str( format( 'Archive LinkFile %s error >> %s', [LinkFilePath,ErrStr] ) );
    K_CMShowMessageDlg( //sysout
      'Not proper archive path is given!!!', mtError );
  end;
  BtStart.Enabled := ProperArchive and (ArchCount > 0);
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMArchSave.OnArchPathChange


procedure TK_FormCMArchSave.BtDeleteFilesClick(Sender: TObject);
var
  WText, ResText, FileErrText : string;
  PortionStartProcCount : Integer;
  SrcFName, SrcFName1 : string;
  FPath : string;

label FinExit;

begin
// Process Slides Loop
  DelFilesProcessFlag := TRUE;
  N_Dump1Str( format( 'ArchSave>> Loop %s >> %d of %d media object(s) is processed.',
                      [BtDeleteFiles.Caption, ProcDelCount, StartDelCount] ) );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    ExtDataErrorCode := K_eeDBSelect;
    Connection := LANDBConnection;
    try

      if BtDeleteFiles.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin // if BtStart.Caption = 'Pause' then
        BtDeleteFiles.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit;
      end   // if BtStart.Caption = 'Pause' then
      else
      begin // if BtStart.Caption <> 'Pause' then
        if BtDeleteFiles.Caption = BtDelFilesInitCapt then //'Delete files'
        begin
          PrevPat := -1;
          PrevDate := 0;
          ProcDelCount := 0;
          ErrCount  := 0;
          UnDelFilesCount := 0;
          UnDelFilesSlidesCount := 0;
          ArchCountReal := 0;
          CheckFinishFlag := FALSE;
          StartDelCount := DBUnDelFilesSlidesCount;

          if Slide = nil then
            Slide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));

  //          ChangeFSizeInfoFlag := FALSE;
          SQL.Text := 'select ' +
      K_CMENDBSTFSlideID + ',' + K_CMENDBSTFPatID + ',' +           // 0, 1
      K_CMENDBSTFSlideDTCr + ',' + K_CMENDBSTFSlideSysInfo +        // 2, 3
      ' from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFSlideSFlags + ' & 16 <> 0';

          CurT.Start;
          Open();
          CurT.Stop;
          N_Dump1Str( 'ArchSave>> Slides DB select Time=' + CurT.ToStr() );
        end; // if BtStart.Caption = 'Start' then


      end; // if BtStart.Caption <> 'Pause' then

      BtDeleteFiles.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
      BtClose.Enabled := FALSE;

      LbInfo.Caption  := ' Files deleting is in process ... ';
      LbInfo.Refresh;

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;

      ////////////////////////////////////////////////
      //  Slides Check Loop
      //
      ResT.Start;
      PortionStartProcCount := ProcDelCount;
      while not EOF do
      begin

        with Slide, P^ do
        begin
          ObjName := FieldList[0].AsString;
          CMSPatID := FieldList[1].AsInteger;
          CMSDTCreated := TDateTimeField(FieldList[2]).Value;
          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
          N_Dump2Str( format( 'ArchSave>> Start ID=%s files deleting.',[ObjName] ) );

          UndelCount := 0;
          FPrepCopyDelFiles( SrcFName, SrcFName1, FPath );
          FDelMediaFiles( SrcFName, SrcFName1);

          if UndelCount = 0 then
          begin
            Dec(DBUnDelFilesSlidesCount);
            with CurSQLCommand1 do
            begin // Clear Slide non-deleted files state
              CurT.Start;
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' set ' +
                K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 239 ' +
                ' where ' + K_CMENDBSTFSlideID + ' = ' + ObjName;
              Execute;
              CurT.Stop;
              N_Dump1Str( 'ArchSave>> Clear Slide non-deleted files state Time=' + CurT.ToStr() );
            end
          end;
        end; // with Slide, P^ do

 
        Inc(ProcDelCount);
        if StartDelCount > 0 then
          PBProgress.Position := Round(1000 * ProcDelCount / StartDelCount);

        LbEDProcCount.Text := IntToStr( ProcDelCount );
        LbEDProcCount.Refresh();

        LbEMCountArchived.Text := format('%d (%d)', [ArchCountDB,
                                                     DBUnDelFilesSlidesCount] );
        LbEMCountArchived.Refresh();

     //   CurT.Start;
        Next;
     //   CurT.Stop;
     //   N_Dump1Str( 'ArchSave>> Next Slide Time=' + CurT.ToStr() );

        Application.ProcessMessages();
        if BtDeleteFiles.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Caption <> 'Pause' - Break Files Loop by PAUSE
      end; // while not EOF do

      BtDeleteFiles.Caption := BtDelFilesInitCapt; // 'Delete files'
      BtDeleteFiles.Enabled := DBUnDelFilesSlidesCount > 0;
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;
      Close;

FinExit:
      ResT.Stop;
      N_Dump1Str( format( 'ArchSave>> Deleting files portion=%d AllTime=%s AverageTime=%s',
                  [ProcDelCount - PortionStartProcCount, ResT.ToStr(),
                   ResT.ToStr(ProcDelCount - PortionStartProcCount)] ) );

      LbInfo.Caption  := '';
      LbInfo.Refresh;

      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := ' Files deleting is %s. %d of %d media object(s) were processed.';

      if UnDelFilesCount > 0 then
        WText := WText + #13#10 +
                 ' %d files of archived %d media objects were not deleted from file storage.';

      FileErrText := format( WText, [ResText, ProcDelCount,
                                     StartDelCount,
                                     UnDelFilesCount,
                                     UnDelFilesSlidesCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMArchSave.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // procedure TK_FormCMArchSave.BtDeleteFilesClick

end.
