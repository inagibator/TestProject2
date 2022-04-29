unit K_FCMExportSlidesAll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_Lib0, K_FPathNameFr, K_CM0;

type
  TK_FormCMExportSlidesAll = class(TN_BaseForm)
    BtClose: TButton;
    BtStart: TButton;
    Timer: TTimer;
    GBDBState: TGroupBox;
    LbEMCountDB: TLabeledEdit;
    GBArchivingAttrs: TGroupBox;
    LbEMCountToBeExported: TLabeledEdit;
    FPNFrame: TK_FPathNameFrame;
    GBArchiving: TGroupBox;
    LbEDProcCount: TLabeledEdit;
    PBProgress: TProgressBar;
    LbInfo: TLabel;
    GBFormat: TGroupBox;
    RBJPEG: TRadioButton;
    RBBMP: TRadioButton;
    RBPNG: TRadioButton;
    RBDICOMDIR: TRadioButton;
    GBFtypes: TGroupBox;
    RBMod: TRadioButton;
    RBOrig: TRadioButton;
    RBOrigMod: TRadioButton;
    RadioButton5: TRadioButton;
    ChBDate: TCheckBox;
    ChBAnnot: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure ChBAnnotClick(Sender: TObject);
    procedure RBBMPClick(Sender: TObject);
    procedure RBOrigClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;

    // New Vars
    SQLFromWhereStr : string;
    SQLCondStr : string;
    ExportPath : string;
    ExpAnnotMode : Boolean;
    ExpDateMode: Boolean;
    ExpModeInd,
    Exp2DFormatInd,
    ExpCountDB,             // exported in DB
    ExpCountReal,           // Really exported
    ExpCount,               // Should be exported
    ExpErrCount,
    ProcCount,              // processed
    SlideID : Integer;
    StartInit    : Boolean;
    ProperResumeFile : Boolean;
    Slide : TN_UDCMSlide;
    ResumeFilePath : string;
    LPatPath : string;
    DPatPath : string;
    LDTPath : string;
    PrevPat : Integer;
    PrevDate : TDateTime;
    CurT : TN_CPUTimer1;     // Slide Delete files Errors
    ResT : TN_CPUTimer1;
    ArchFPathSegm, SrcFName, DstFName : string;
    SL : TStringList;
    ExportDIBFlags : TK_CMBSlideExportToDIBFlags;
    ML : TStrings;
    FilesCount : Integer;

    procedure CalcExpCounter();
    procedure OnArchPathChange();
    function  SlideIDGet ( var ProperResumeFile : Boolean) : string;
    function  SlideIDSave () : Boolean;
    procedure DisableActions;
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMExportSlidesAll: TK_FormCMExportSlidesAll;

procedure K_CMExportSlidesAllDlg( );

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CLib0, K_Script1, K_CML1F, K_UDT2, K_RImage, {K_FEText,}
  N_Lib1, N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2;

const K_Img   = 'Img\';
const K_Video = 'Video\';
const K_Img3D = 'Img3D\';
const ResumeFileName = 'Resume.txt';
const K_Orig = '_ORG';
const K_Mod  = '_MOD';



procedure FPrepExpFiles( var AFPath : string  );
begin
  // N_Dump2Str( 'ExpAll>> Copy media files' );
  // Img Video Img3D
  // ...
  with K_FormCMExportSlidesAll, TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  begin
    if PrevPat <>  CMSPatID then
    begin
      LPatPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID );
      K_CMEDAccess.EDAGetPatientMacroInfo( CMSPatID, ML );
      DPatPath := TrimLeft( K_StringMListReplace( K_CMENPTNExportAllPName, ML, K_ummRemoveMacro ) );
      if DPatPath <> '\' then
        DPatPath := ' ' + DPatPath;
      DPatPath := IntToStr(CMSPatID) + DPatPath;
//      DPatPath := IntToStr(CMSPatID) + TrimLeft( ' ' + K_StringMListReplace( K_CMENPTNExportAllPName, ML, K_ummRemoveMacro ) );
    end;

    if PrevDate <> CMSDTCreated then
      LDTPath := K_CMSlideGetFileDatePathSegm( CMSDTCreated );

    if (PrevPat <>  CMSPatID) or (PrevDate <> CMSDTCreated) then
    AFPath := LPatPath + LDTPath;

    PrevDate := CMSDTCreated;
    PrevPat := CMSPatID;
{
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
}
  end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
end; // procedure FPrepExpFiles

//******************************************************** K_CMExportAllDlg ***
//  Archiving Dialog
//
procedure K_CMExportSlidesAllDlg( );
begin
//  N_Dump1Str( 'K_CMArchSaveDlg Start' );

  K_CMEDAccess.EDANotGAGlobalToCurState();
  K_FormCMExportSlidesAll := TK_FormCMExportSlidesAll.Create(Application);
  with K_FormCMExportSlidesAll do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_Dump1Str( 'K_CMArchSaveDlg before show' );
    ML := TStringList.Create;

    ShowModal();
    ML.Free();
//    N_Dump1Str( 'K_CMArchSaveDlg after show' );

    K_FormCMExportSlidesAll := nil;

    K_CMEDAccess.EDANotGAGlobalToMemIni();
    // Save Arch Save State to Global Context
    K_CMEDAccess.EDASaveContextsData(
       [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
        K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
        K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
        K_cmssSkipExtIniInfo,
        K_cmssSaveGlobal2Info] );
  end;

end; // procedure K_CMExportSlidesAllDlg

//********************************************** TK_FormCMExportSlidesAll.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMExportSlidesAll.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
  StartInit := TRUE;
  ProperResumeFile := FALSE;
  FPNFrame.OnChange := OnArchPathChange;
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;
  ProcCount := 0;
  ExpCount := 0;
  ExpErrCount  := 0;
  ExpCountReal := 0;
  FilesCount := 0;
  Slide := nil;
  CheckFinishFlag := FALSE;
  CurT := TN_CPUTimer1.Create;
  ResT := TN_CPUTimer1.Create;

  ProperResumeFile := TRUE;
  SlideIDGet( ProperResumeFile );

  case Exp2DFormatInd of
  0 : RBBMP.Checked := TRUE;
  1 : RBJPEG.Checked := TRUE;
  2 : RBPNG.Checked := TRUE;
  end;

  case ExpModeInd of
  0 : RBOrig.Checked := TRUE;
  1 : RBMod.Checked := TRUE;
  2 : RBOrigMod.Checked := TRUE;
  end;

  ChBDate.Checked := ExpDateMode;
  ChBAnnot.Checked := ExpAnnotMode;

  DisableActions();

  Timer.Enabled := TRUE;

end; // TK_FormCMExportSlidesAll.FormShow

//******************************************** TK_FormCMExportSlidesAll.TimerTimer ***
//  On Timer Handler
//
procedure TK_FormCMExportSlidesAll.TimerTimer( Sender: TObject );
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
    AllCount := 0; // should be 0 + 1 + 2 + 3
    ExpCountDB := 0; // should be 0 + 1
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
                    'WHEN ' + K_CMENDBSTFSlideID + ' <= ' + IntToStr( SlideID ) +
                          ' then 0 ' +
                    'WHEN ' + K_CMENDBSTFSlideID + ' > ' + IntToStr( SlideID ) +
                          ' then 1 ' +
                    'END) AS TYPE FROM ' + K_CMENDBSlidesTable +
                ' WHERE ' + K_CMENDBSTFSlideStudyID + ' >= 0 ' +
                ' GROUP BY TYPE;';


      Open();
      while not EOF do
      begin
        CurCount := Fields[0].AsInteger;
        CurType  := Fields[1].AsInteger;
        AllCount := AllCount + CurCount; // 0 + 1
        case CurType of
        0: ExpCountDB := ExpCountDB + CurCount;
        end;
        Next();
      end; // while not EOF do
      Close;

      LbEMCountDB.Text := IntToStr(AllCount);
      LbEMCountDB.Refresh;

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMExportSlidesAll.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
    CurT.Stop;
    N_Dump1Str( 'ExpAll>> Slides DB Info get Time=' + CurT.ToStr() );

    N_Dump1Str( format( 'ExpAll>> Slides DB all objects  %d exported %d',
                [AllCount, ExpCountDB] ) );


    CalcExpCounter();

    CurT.Start;
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
      Connection := LANDBConnection;

      SQLFromWhereStr :=
           'DROP TABLE IF EXISTS SlidesExpData;' + #10 +
           'CREATE LOCAL TEMPORARY TABLE SlidesExpData ' +
                       '(SlideID int, PatID int, DTCr datetime, SysInfo long varchar) NOT TRANSACTIONAL;' + #10 +
              'INSERT SlidesExpData (SlideID, PatID, DTCr, SysInfo)' +
//                        '(SlideID int, PatID int, DTCr datetime, SysInfo long varchar, Thumbnail image) NOT TRANSACTIONAL;' + #10 +
//             'INSERT SlidesExpData (SlideID, PatID, DTCr, SysInfo, Thumbnail)' +
             ' SELECT ' +
            K_CMENDBSTFSlideID        + ',' + K_CMENDBSTFPatID        + ',' + // 0, 1
            K_CMENDBSTFSlideDTCr      + ',' + K_CMENDBSTFSlideSysInfo +       // 2, 3
//            K_CMENDBSTFSlideDTCr      + ',' + K_CMENDBSTFSlideSysInfo + ',' + // 2, 3
//            K_CMENDBSTFSlideThumbnail +
            SQLFromWhereStr + SQLCondStr +
            ' order by ' + K_CMENDBSTFSlideID + ';';

      CommandText := SQLFromWhereStr;                                   // 4
      Execute;

    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    CurT.Stop;
    N_Dump1Str( 'ExpAll>> Slides Data prep Time=' + CurT.ToStr() );

    StartInit := FALSE;
    if ExportPath <> '' then
      FPNFrame.AddNameToTop( ExportPath )
    else
      OnArchPathChange();
  end;  // if StartInit then

  FPNFrame.Enabled := TRUE;
  BtClose.Enabled := TRUE;
  LbInfo.Caption  := '';
  Slide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));
  Screen.Cursor := SavedCursor;

  ResT.Stop;
  N_Dump1Str( 'ExpAll>> TimerTimer Time=' + ResT.ToStr() );


end; // procedure TK_FormCMExportSlidesAll.TimerTimer

//**************************************** TK_FormCMExportSlidesAll.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMExportSlidesAll.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]) or
              (ProcCount = ExpCount);  // 'Pause'  or Finish

  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( 'Do you really want to break the process?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if (ProcCount < ExpCount) then
    N_Dump1Str( 'ExpAll>> Break by user' );

// Clear Global context and free objects
  if not CheckFinishFlag then
    TK_CMEDDBAccess(K_CMEDAccess).CurDSet2.Close;

  TK_CMEDDBAccess(K_CMEDAccess).LockResCount := 0;
//  TK_CMEDDBAccess(K_CMEDAccess).EDAGetPatientSlidesUpdateTS();

  Slide.Free;
  CurT.Free;
  ResT.Free;
  SL.Free;

  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    CommandText := 'DROP TABLE IF EXISTS SlidesExpData;';
    Execute;
  end;

end; // TK_FormCMExportSlidesAll.FormCloseQuery

//***************************************** TK_FormCMExportSlidesAll.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMExportSlidesAll.BtStartClick(Sender: TObject);
var
  WText, ResText, FileErrText : string;
  PortionStartProcCount : Integer;
  RCode : Integer;
  FResult : Boolean;
  RIEncodingInfo : TK_RIFileEncInfo;
  OrigExists, CurExists : Boolean;
  SlideDIB : TN_DIBObj;
  ExpCode : TK_RIResult;
  ExpExt : string;
  WFName : string;

const PortionMax = 10;

label FinExpLoop, FinExit, ContLoop, ErrResumeFile, FinExitStart;

  function CopySlideThumbnail() : Integer;
  var
    FStream : TFileStream;
    DBStream : TStream;
  begin
    N_Dump2Str( 'ExpAll>> Save slide thumbnail start' );
    FStream := nil;
    DBStream := nil;
    try
      with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^, CurBlobDSet do
      begin
        DstFName := DstFName + '.jpg';
        CurT.Start;
        if K_ForceFilePath( DstFName ) then
        begin
          FStream :=  TFileStream.Create( DstFName, fmCreate );
          Connection := LANDBConnection;
          SQL.Text :=
      'select ' + K_CMENDBSTFSlideThumbnail + ' ' +
      ' from ' +  K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFSlideID+ '=' + IntToStr(SlideID) +';';
          Open();
          DBStream := CurBlobDSet.CreateBlobStream( CurBlobDSet.Fields[0], bmRead );
          FStream.Seek( 0, soFromBeginning );
          DBStream.Seek( 0, soFromBeginning );
          FStream.CopyFrom( DBStream, 0 );
          FreeAndNil( FStream );
          FreeAndNil( DBStream);
          Close();
        end;
        CurT.Stop;
        N_Dump1Str( format( 'ExpAll>> Save Slide Thumbnail %s >> Time=%s',
                            [DstFName, CurT.ToStr()] ) );
        Result := 0;
//        DelFilesFlag := TRUE;
  //      N_Dump2Str( 'ExpAll>> Save Slide Thumbnail to ' + DstFName );
      end;
    except
      on E: Exception do
      begin
        N_Dump1Str( format( 'ExpAll>> Save Slide Thumbnail to %s exception:'#13#10' %s', [DstFName,E.Message] ) );
        Result := 1;
        FStream.Free;
        DBStream.Free;
      end;
    end;
  end; // procedure CopySlideThumbnail

  function FCopyFile( const ASrcFile, ADstFile : string ) : Integer;
  begin
    RCode := K_CopyFile( ASrcFile, ADstFile, [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
    Result := 0;
    if RCode > 0 then
      Result := 1;
    case RCode of
      0: N_Dump2Str( 'ExpAll>> Copy File ' + ASrcFile );
      3: N_Dump1Str( 'ExpAll>> Couldn''t copy Src doesn''t exist ' + ASrcFile );
      4: N_Dump1Str( 'ExpAll>> Couldn''t copy ' + ASrcFile );
      5: N_Dump1Str( 'ExpAll>> Couldn''t create Dst path ' + ADstFile );
    end;

  end; // function FCopyFile


begin
// Process Slides Loop
  N_Dump1Str( format( 'ExpAll>> Loop %s >> %d of %d media object(s) is processed.',
                      [BtStart.Caption, ProcCount, ExpCount] ) );

  RIEncodingInfo.RIFileEncType := rietJPG;
  RIEncodingInfo.RIFComprQuality := 100;
  ExpExt := '.jpg';
  
  if RBBMP.Checked then
  begin
    RIEncodingInfo.RIFileEncType := rietBMP;
    ExpExt := '.bmp';
  end
  else
  if RBPNG.Checked then
  begin
    RIEncodingInfo.RIFileEncType := rietPNG;
    ExpExt := '.png';
  end;

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
          ProcCount := 0;
          ExpErrCount  := 0;
          ExpCountReal := 0;
          CheckFinishFlag := FALSE;
        end; // if BtStart.Caption = 'Start' then

  //          ChangeFSizeInfoFlag := FALSE;

      end; // if BtStart.Caption <> 'Pause' then

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
      BtClose.Enabled  := FALSE;
      GBFtypes.Enabled := FALSE;
      GBFormat.Enabled := FALSE;

      LbInfo.Caption  := ' Exporting is in process ... ';
      LbInfo.Refresh;

      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;

      ////////////////////////////////////////////////
      //  Slides Check Loop
      //
ContLoop: //*****
      PortionStartProcCount := ProcCount;
{
      SQLFromWhereStr := ' from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFSlideID + ' > ' + IntToStr(SlideID) + ' and ' +         // Old
                  K_CMENDBSTFSlideStudyID + ' >= 0 ' + ' and ' +
                  ' not (' + K_CMENDBSTFSlideThumbnail + ' is null)' +                                           // not Study
                  SQLCondStr;

      SQL.Text := 'select top ' + IntToStr(PortionMax) + ' ' +
  K_CMENDBSTFSlideID        + ',' + K_CMENDBSTFPatID        + ',' + // 0, 1
  K_CMENDBSTFSlideDTCr      + ',' + K_CMENDBSTFSlideSysInfo + ',' + // 2, 3
  K_CMENDBSTFSlideThumbnail +                                       // 4
  SQLFromWhereStr + ' order by ' + K_CMENDBSTFSlideID;
}
      SQL.Text :=
      'select top ' + IntToStr(PortionMax) + ' ' +
      ' SlideID, PatID, DTCr, SysInfo from SlidesExpData' +
//      ' SlideID, PatID, DTCr, SysInfo, Thumbnail from SlidesExpData' +
      ' where SlideID > ' + IntToStr(SlideID) +';';

      CurT.Start;
      Open();
      CurT.Stop;
      N_Dump1Str( 'ExpAll>> Slides DB select Time=' + CurT.ToStr() );
      if RecordCount = 0 then goto FinExitStart;
      while not EOF do
      begin

        with Slide, P^ do
        begin
          ObjName := FieldList[0].AsString;
          CMSPatID := FieldList[1].AsInteger;
          CMSDTCreated := TDateTimeField(FieldList[2]).Value;
          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
          N_Dump2Str( format( 'ExpAll>> Start ID=%s processing.',[ObjName] ) );

          SlideID := StrToIntDef(ObjName,-1);
{
          CurT.Start;
//          EDALockSlides( @Slide, 1, K_cmlrmCheckFilesLock );
          EDALockSlides( @Slide, 1, K_cmlrmEditImgLock );
          CurT.Stop;
          N_Dump1Str( format( 'ExpAll>> LockSlide ID=%s Time=%s', [ObjName, CurT.ToStr()] ) );

          if LockResCount = 0 then
          begin
            N_Dump1Str( 'ExpAll>> Slide is locked by other user' );
            goto FinExpLoop;
          end;
}
          ///////////////////////////
          // Export Slide
          //
          Inc(ExpCountReal);
          FPrepExpFiles( ArchFPathSegm );
   //       ASrcFName1 := '';
          if cmsfIsMediaObj in CMSDB.SFlags then // Video
          begin
            SrcFName := K_CMSlideGetMediaFileNamePref(ObjName) + CMSDB.MediaFExt;
            DstFName := ExportPath + K_Video + DPatPath;
            if ChBDate.Checked then
              DstFName := DstFName + LDTPath;
            DstFName := DstFName + Copy( SrcFName, 4, 12 );
            SrcFName := ArchFPathSegm + SrcFName;

            CurT.Start;
            RCode := FCopyFile( SlidesMediaRootFolder + SrcFName, DstFName );
            CurT.Stop;
            N_Dump1Str( format( 'ExpAll>> Copy Slide Video %s>>%s Time=%s Code=%d',
                                [SrcFName, DstFName, CurT.ToStr(), RCode] ) );
            if RCode > 0 then
              Inc(ExpErrCount);
            if RCode = 1 then
            begin
              DstFName := Copy( DstFName, 1, Length(DstFName) - 4 );
              CopySlideThumbnail();
            end
          end
          else
          if cmsfIsImg3DObj in CMSDB.SFlags then // Img3D
          begin
            SrcFName := K_CMSlideGetImg3DFolderName(ObjName);
            DstFName := ExportPath + K_Img3D + DPatPath;
            if ChBDate.Checked then
              DstFName := DstFName + LDTPath;
            DstFName := DstFName + Copy( SrcFName, 4, 9 );
            SrcFName := SlidesImg3DRootFolder + ArchFPathSegm + SrcFName;

            FResult := DirectoryExists( SrcFName );
            if FResult then
            begin
              CurT.Start;
              FResult := K_CopyFolderFiles( SrcFName, DstFName,
                                      '*.*', [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
              CurT.Stop;
              N_Dump1Str( format( 'ExpAll>> Copy Slide 3D Files %s>>%s Time=%s R=%s',
                                [SrcFName, DstFName, CurT.ToStr(), N_B2S(FResult)] ) );
            end;

            if not FResult then
            begin
              Inc(ExpErrCount);
              RCode := 1;
              N_Dump1Str( 'ExpAll>> Couldn''t copy ' + SlidesImg3DRootFolder + SrcFName );
              if not DirectoryExists( DstFName ) then
              begin
                DstFName := Copy( DstFName, 1, Length(DstFName) - 1 );
                CopySlideThumbnail();
              end;
            end;

          end
          else
          begin // Img
            SrcFName := K_CMSlideGetCurImgFileName(ObjName);
            WFName := ExportPath + K_Img + DPatPath;
            if ChBDate.Checked then
              WFName := WFName + LDTPath;
            WFName := WFName + Copy( SrcFName, 4, 8 );
            DstFName := WFName;
            CurExists := FileExists( SlidesImgRootFolder + ArchFPathSegm + SrcFName );
            OrigExists := TRUE;
            if cmsfHasSrcImg in CMSDB.SFlags then
              OrigExists := FileExists( SlidesImgRootFolder + ArchFPathSegm + K_CMSlideGetSrcImgFileName(ObjName) );

            ExportDIBFlags := [];
            if not ChBAnnot.Checked then
              ExportDIBFlags := [K_bsedSkipAnnotations];
            if RBPNG.Checked then
              ExportDIBFlags := ExportDIBFlags + [K_bsedSkipConvGrey16To8];

            if not CurExists and
              (not OrigExists or not (cmsfHasSrcImg in CMSDB.SFlags)) then
            begin // Export Thumbnail - no image files in  file storage
              N_Dump1Str( 'ExpAll>> Export file is absent >> ' + SlidesImgRootFolder + SrcFName );
              CopySlideThumbnail();
              Inc(ExpErrCount);
            end
            else
            if ((RBOrig.Checked or RBOrigMod.Checked) and (CurExists or OrigExists) ) or
               (RBMod.Checked and not RBOrigMod.Checked and not CurExists and OrigExists and (cmsfHasSrcImg in CMSDB.SFlags)) then
            begin // Export Original
              CurT.Start;
              SlideDIB := ExportToDIB( ExportDIBFlags + [K_bsedExportOriginal] );
              CurT.Stop;
              if SlideDIB <> nil then
              begin
                N_Dump2Str( format( 'ExpAll>> Create orig DIB Time=%s',
                            [CurT.ToStr()] ) );
                DstFName := WFName + K_ORIG + ExpExt;
                if not K_ForceFilePath( DstFName ) then
                begin
                  N_Dump1Str( 'ExpAll>> Create Path fails >> for file ' + DstFName );
                  Inc(ExpErrCount);
                end
                else
                begin
                  CurT.Start;
                  ExpCode := K_RIObj.RISaveDIBToFile( SlideDIB, DstFName, @RIEncodingInfo );
                  CurT.Stop;
                  N_Dump2Str( format( 'ExpAll>> Save orig DIB Time=%s',
                            [CurT.ToStr()] ) );
                  if ExpCode <> rirOK then
                  begin
                    Inc(ExpErrCount);
                    if FileExists( DstFName ) then
                      K_DeleteFile( DstFName );
                    N_Dump1Str( format( 'ExpAll>> Save orig DIB fails >> %s',
                            [DstFName] ) );
                  end;
                end;
                FreeAndNil( SlideDIB );
              end
              else
              begin
                N_Dump1Str( 'ExpAll>> ExportToDIB ORIG fails >> SlideID=' + ObjName );
                Inc(ExpErrCount);
              end;
            end;

            if (RBMod.Checked or RBOrigMod.Checked) and CurExists then
            begin // Export Modified
              CurT.Start;
              SlideDIB := ExportToDIB( ExportDIBFlags );
              CurT.Stop;
              if SlideDIB <> nil then
              begin
                N_Dump2Str( format( 'ExpAll>> Create mod DIB Time=%s',
                            [CurT.ToStr()] ) );
                DstFName := WFName + K_MOD + ExpExt;
                if not K_ForceFilePath( DstFName ) then
                begin
                  N_Dump1Str( 'ExpAll>> Create Path fails >> for file ' + DstFName );
                  Inc(ExpErrCount);
                end
                else
                begin
                  CurT.Start;
                  ExpCode := K_RIObj.RISaveDIBToFile( SlideDIB, DstFName, @RIEncodingInfo );
                  CurT.Stop;
                  N_Dump2Str( format( 'ExpAll>> Save mod DIB Time=%s >> %s',
                            [CurT.ToStr(), DstFName] ) );
                  if ExpCode <> rirOK then
                  begin
                    Inc(ExpErrCount);
                    if FileExists( DstFName ) then
                      K_DeleteFile( DstFName );
                    N_Dump1Str( format( 'ExpAll>> Save mod DIB fails >> %s',
                            [DstFName] ) );
                  end;
                end;

                FreeAndNil( SlideDIB );
              end
              else
              begin
                N_Dump1Str( 'ExpAll>> ExportToDIB mod fails >> SlideID=' + ObjName );
                Inc(ExpErrCount);
              end;
            end;

          end; // Img
          // Free Slide MapRoot, Current and original images
          PutDirChild(K_CMSlideIndMapRoot, nil);
          PutDirChild(K_CMSlideIndCurImg, nil);
          PutDirChild(K_CMSlideIndSrcImg, nil);
          PutDirChild(K_CMSlideIndThumbnail, nil);

        end; // with Slide, P^ do
{
        CurT.Start;
//        EDAUnLockSlides( @Slide, 1, K_cmlrmCheckFilesLock );
        EDAUnLockSlides( @Slide, 1, K_cmlrmEditImgLock );
        CurT.Stop;
        N_Dump1Str( 'ExpAll>> UnlockSlide Time=' + CurT.ToStr() );
}
        //
        // Export Slide
        ///////////////////////////

FinExpLoop: //*****
        // CMSuite Resume file save
        CurT.Start;
        if not FileExists(ResumeFilePath) then
        begin
          FileErrText := '';
          if not K_ForceDirPath( ExportPath ) then
            FileErrText := 'Couldn''t create Export root folder!!!'
          else
          begin
            if not SlideIDSave() then
              FileErrText := 'Couldn''t create Resume file. Exporting couldn''t be started!!!';
          end;

ErrResumeFile: //*****
          if FileErrText <> '' then
          begin
            Close;
            BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
            BtClose.Enabled := TRUE;
            FPNFrame.Enabled := TRUE;
            GBFtypes.Enabled := TRUE;
            GBFormat.Enabled := TRUE;
            K_CMShowMessageDlg( {sysout}  FileErrText, mtError );
            Exit;
          end;
        end // if not FileExists(ResumeFilePath) then
        else
          if not SlideIDSave() then
          begin
            FileErrText := 'Couldn''t rewrite Resume file. Exporting couldn''t be continued!!!';
            goto ErrResumeFile;
          end;
        CurT.Stop;
        N_Dump1Str( 'ExpAll>> Resume File prep Time=' + CurT.ToStr() );

        Inc(ProcCount);
        if ExpCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / ExpCount);

        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();

//        CurT.Start;
        Next;
//        CurT.Stop;
//        N_Dump1Str( 'ExpAll>> Next Slide Time=' + CurT.ToStr() );

        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE
      end; // while not EOF do
      goto ContLoop;

FinExitStart: //****
      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtStart.Enabled := FALSE;
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;

      Close;

FinExit: //*****

      ResT.Stop;
      if ProcCount - PortionStartProcCount > 0 then
        N_Dump1Str( format( 'ExpAll>> Export portion=%d AllTime=%s AverageTime=%s',
                    [ProcCount - PortionStartProcCount, ResT.ToStr(),
                     ResT.ToStr(ProcCount - PortionStartProcCount)] ) );

      LbInfo.Caption  := '';
      LbInfo.Refresh;

      Screen.Cursor := SavedCursor;
      BtClose.Enabled  := TRUE;
      GBFtypes.Enabled := TRUE;
      GBFormat.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := ' Exporing is %s. %d of %d media object(s) were processed.';
{
      if (ProcCount > ExpCountReal) or
         (ExpErrCount > 0) then
      begin
        WText := WText + #13#10 +
' %d media object(s) were not exported because of source image files are absent or export error(s)';
' or because they were opened by other user(s)!';

        if (ExpErrCount > 0)then
          WText := WText + #13#10 +
                   ' %d exporting source image files are absent or export error(s).';

      end;
}
      if (ExpErrCount > 0)then
        WText := WText + #13#10 +
                 ' %d exporting source image files are absent or export error(s).';

{
      FileErrText := format( WText, [ResText, ProcCount, ExpCount,
                                     ProcCount - ExpCountReal + ExpErrCount,
                                     ExpErrCount] );
}
      FileErrText := format( WText, [ResText, ProcCount, ExpCount, ExpErrCount] );
      K_CMShowMessageDlg( FileErrText, mtInformation );

      if CheckFinishFlag then
      begin
        ExpCountDB := ExpCountDB + ExpCountReal;
        ExpCountReal := 0;
      end;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMExportSlidesAll.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMExportSlidesAll.BtStartClick

//********************************* TK_FormCMExportSlidesAll.CalcExpCounter ***
//  Get Common Counters Info
//
procedure TK_FormCMExportSlidesAll.CalcExpCounter;
begin
  CurT.Start;

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

// 2020-09-25 add new condition for Dev3D objs
      SQLCondStr := ' and not ((' + K_CMENDBSTFSlideSysInfo + ' like ''%Capt3D%'') or (('+
                                      K_CMENDBSTFSlideSysInfo + ' like ''%MediaFExt%'')  and not (' +
                                      K_CMENDBSTFSlideSysInfo + ' like ''%cmsfIsMediaObj%'')))';

      SQLFromWhereStr := ' from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFSlideID + ' > ' + IntToStr(SlideID) + ' and ' +         // Old
                  K_CMENDBSTFSlideStudyID + ' >= 0 ' +                                              // not Study
                  SQLCondStr;

      SQL.Text := 'select Count(*) ' + SQLFromWhereStr;
      Open();
      ExpCount := FieldList.Fields[0].AsInteger;
      Close;

      LbEMCountToBeExported.Text := IntToStr( ExpCount );
      LbEMCountToBeExported.Refresh;

      BtStart.Enabled := ProperResumeFile and (ExpCount > 0);
//BtStart.Enabled := TRUE;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMExportSlidesAll.CalcExpCounter ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

  CurT.Stop;
  N_Dump1Str( 'ExpAll>> CalcExpCounter time=' + CurT.ToStr() );
end; // TK_FormCMExportSlidesAll.CalcExpCounter`

//************************************* TK_FormCMExportSlidesAll.ChBArchVideoClick ***
//  On DTPFrom Change Handler
//
procedure TK_FormCMExportSlidesAll.ChBAnnotClick(Sender: TObject);
begin
//  CalcArchCountByDate();
  if Sender = ChBAnnot then
    ExpAnnotMode := ChBAnnot.Checked
  else
  if Sender = ChBDate then
    ExpDateMode := ChBDate.Checked;

end; // procedure TK_FormCMExportSlidesAll.ChBArchVideoClick

//************************ ************* TK_FormCMExportSlidesAll.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMExportSlidesAll.CurStateToMemIni;
begin
  inherited;
  N_Dump1Str( format( 'ExpAll>> CurStateToMemIni >> R=%s M=%d F=%d A=%s D=%s', [ExportPath,
       ExpModeInd, Exp2DFormatInd, N_B2S(ExpAnnotMode), N_B2S(ExpDateMode)] ) );
  N_StringToMemIni( 'ExportAll', 'RootFolder', ExportPath );
  N_IntToMemIni( 'ExportAll', 'ExpModeInd', ExpModeInd );
  N_IntToMemIni( 'ExportAll', 'Exp2DFormatInd', Exp2DFormatInd );
  N_BoolToMemIni( 'ExportAll', 'ExpAnnotMode', ExpAnnotMode );
  N_BoolToMemIni( 'ExportAll', 'ExpDateMode', ExpDateMode );
end; // procedure TK_FormCMExportSlidesAll.CurStateToMemIni

//************************************** TK_FormCMExportSlidesAll.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMExportSlidesAll.MemIniToCurState;
begin
  inherited;
  ExportPath := N_MemIniToString( 'ExportAll', 'RootFolder', '' );
  ExpModeInd := N_MemIniToInt( 'ExportAll', 'ExpModeInd', 0 );
  Exp2DFormatInd := N_MemIniToInt( 'ExportAll', 'Exp2DFormatInd', 0 );
  ExpAnnotMode := N_MemIniToBool( 'ExportAll', 'ExpAnnotMode', FALSE );
  ExpDateMode := N_MemIniToBool( 'ExportAll', 'ExpDateMode', FALSE );
  N_Dump1Str( format( 'ExpAll>> MemIniToCurState >> R=%s M=%d F=%d A=%s D=%s', [ExportPath,
       ExpModeInd, Exp2DFormatInd, N_B2S(ExpAnnotMode), N_B2S(ExpDateMode)] ) );
end; // procedure TK_FormCMExportSlidesAll.MemIniToCurState

//******************************* TK_FormCMExportSlidesAll.OnArchPathChange ***
// On archive path change
//
procedure TK_FormCMExportSlidesAll.OnArchPathChange;
var
  ErrStr : string;
begin
  if FPNFrame.mbPathName.Text = '' then
  begin
    ProperResumeFile := FALSE;
    BtStart.Enabled := FALSE;
    Exit;
  end;

  ExportPath := IncludeTrailingPathDelimiter(FPNFrame.mbPathName.Text);
  ProperResumeFile := (ExpCountDB = 0); // Resume file should be empty
  ErrStr := SlideIDGet( ProperResumeFile );
{
  ErrStr := '';
  if FileExists(ResumeFilePath) then
  begin
    if SL = nil then
      SL := TStringList.Create;
    ErrStr := K_VFLoadStrings1( ResumeFilePath, SL, ErrCode );
    ProperResumeFile := ErrStr = '';
    if ProperResumeFile then
    begin
      ProperResumeFile := SL[1] = K_CMEDAccess.EDAGetDBUID;
      if not ProperResumeFile then
        ErrStr := 'Resume file is not linked to this DB'
      else
      begin
        SlideID := StrToIntDef( SL[0], -1);
//        TimerTimer(nil);
      end;
      if SlideID < 0 then
      begin
        SlideID := 0;
        ErrStr := 'Resume file is wrong';
      end
    end;
  end
  else
  if not ProperResumeFile then
    ErrStr := 'Resume file is absent';
}
  if not ProperResumeFile then
  begin
    N_Dump1Str( format( 'Export resume file %s error >> %s', [ResumeFilePath,ErrStr] ) );
    K_CMShowMessageDlg( //sysout
      'Not proper archive path is given!!!', mtError );
  end;
  BtStart.Enabled := ProperResumeFile and (ExpCount > 0);
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMExportSlidesAll.OnArchPathChange

{
  ResumeFilePath := ExportPath + ResumeFileName;
  ProperResumeFile := (ExpCountDB = 0); // Resume file should be empty
  ErrStr := '';
  if FileExists(ResumeFilePath) then
  begin
    if SL = nil then
      SL := TStringList.Create;
    ErrStr := K_VFLoadStrings1( ResumeFilePath, SL, ErrCode );
    ProperResumeFile := ErrStr = '';
    if ProperResumeFile then
    begin
      ProperResumeFile := SL[1] = K_CMEDAccess.EDAGetDBUID;
      if not ProperResumeFile then
        ErrStr := 'Resume file is not linked to this DB'
      else
      begin
        SlideID := StrToIntDef( SL[0], -1);
//        TimerTimer(nil);
      end;
      if SlideID < 0 then
      begin
        SlideID := 0;
        ErrStr := 'Resume file is wrong';
      end
    end;
  end
  else
  if not ProperResumeFile then
    ErrStr := 'Resume file is absent';

  if not ProperResumeFile then
  begin
    N_Dump1Str( format( 'Export resume file %s error >> %s', [ResumeFilePath,ErrStr] ) );
    K_CMShowMessageDlg( //sysout
      'Not proper archive path is given!!!', mtError );
  end;
  BtStart.Enabled := ProperResumeFile and (ExpCount > 0);
}
//************************************ TK_FormCMExportSlidesAll.SlideIDSave ***
// Get SlideID from resume file
//
function TK_FormCMExportSlidesAll.SlideIDGet ( var ProperResumeFile : Boolean) : string;
var
  ErrCode : Integer;
begin
  Result := '';
  ResumeFilePath := ExportPath + ResumeFileName;
  if FileExists(ResumeFilePath) then
  begin
    if SL = nil then
      SL := TStringList.Create;
    Result := K_VFLoadStrings1( ResumeFilePath, SL, ErrCode );
    ProperResumeFile := Result = '';
    if ProperResumeFile then
    begin
      ProperResumeFile := SL[1] = K_CMEDAccess.EDAGetDBUID;
      if not ProperResumeFile then
        Result := 'Resume file is not linked to this DB'
      else
      begin
        SlideID := StrToIntDef( SL[0], -1);
      end;
      if SlideID < 0 then
      begin
        SlideID := 0;
        ProperResumeFile := FALSE;
        Result := 'Resume file is wrong';
      end
    end;
  end
  else
  if not ProperResumeFile then
    Result := 'Resume file is absent';
end; // function TK_FormCMExportSlidesAll.SlideIDGet

//************************************ TK_FormCMExportSlidesAll.SlideIDSave ***
// Save SlideID in resume file
//
function TK_FormCMExportSlidesAll.SlideIDSave () : Boolean;
begin
  if SL = nil then
  begin
    SL := TStringList.Create;
    SL.Add( '' );
    SL.Add( '' );
  end;

  SL[0] := IntToStr( SlideID );
  if SL[1] = '' then
    SL[1] := K_CMEDAccess.EDAGetDBUID;
  Result := K_VFSaveStrings( SL, ResumeFilePath, K_DFCreateEncryptedSrc );
end; // function TK_FormCMExportSlidesAll.SlideIDSave

//************************************ TK_FormCMExportSlidesAll.RBBMPClick ***
//
procedure TK_FormCMExportSlidesAll.RBBMPClick(Sender: TObject);
begin
  if Sender <> RBJPEG then
    RBJPEG.Checked := FALSE;
  if Sender <> RBBMP then
    RBBMP.Checked := FALSE;
  if Sender <> RBPNG then
    RBPNG.Checked := FALSE;
  Exp2DFormatInd := TControl(Sender).Tag;

end; // procedure TK_FormCMExportSlidesAll.RBBMPClick

procedure TK_FormCMExportSlidesAll.RBOrigClick(Sender: TObject);
begin
  if Sender <> RBOrig then
    RBOrig.Checked := FALSE;
  if Sender <> RBMod then
    RBMod.Checked := FALSE;
  if Sender <> RBOrigMod then
    RBOrigMod.Checked := FALSE;
  ExpModeInd := TControl(Sender).Tag;
  DisableActions();
end; // procedure TK_FormCMExportSlidesAll.RBOrigClick(

procedure TK_FormCMExportSlidesAll.DisableActions;
begin
  ChBAnnot.Enabled := ExpModeInd >= 1;
  if not ChBAnnot.Enabled then
    ChBAnnot.Checked := FALSE;
end; // procedure TK_FormCMExportSlidesAll.DisableActions

end.
