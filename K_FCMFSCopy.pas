unit K_FCMFSCopy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_Lib0, K_FPathNameFr, K_CM0;

type
  TK_FormCMFSCopy = class(TN_BaseForm)
    BtClose: TButton;
    BtStart: TButton;
    Timer: TTimer;
    GBCopyAttrs: TGroupBox;
    LbEMCountToBeCopied: TLabeledEdit;
    FPNFrame: TK_FPathNameFrame;
    LbCopyMedia: TLabel;
    DTPFrom: TDateTimePicker;
    GBArchiving: TGroupBox;
    LbEDProcCount: TLabeledEdit;
    PBProgress: TProgressBar;
    LbInfo: TLabel;
    ChBCopyVideo: TCheckBox;
    ChBCopyImg3D: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure DTPFromChange(Sender: TObject);
    procedure ChBCopyVideoClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;

    // New Vars
    SQLFromWhereStr : string;
    CopyPath : string;
    CopyCountReal,           // Really Archived
    CopyCount,               // Should be Archived
    ProcCount,               // processed
    ProcDelCount,            // processed slides with non-deleted files
    PeriodInDays : Integer;
    StartInit    : Boolean;

    Slide : TN_UDCMSlide;
    LPatPath : string;
    LDTPath : string;
    PrevPat : Integer;
    PrevDate : TDateTime;
    ErrCount : Integer;      // Copy files Errors
    CurT : TN_CPUTimer1;     // Slide Delete files Errors
    ResT : TN_CPUTimer1;     // Slide Delete files Errors
    DelFilesProcessFlag : Boolean;
    CopyFPathSegm, SrcFName, SrcFName1, SrcFName2 : string;

    procedure CalcCopyCountByDate();
    procedure OnArchPathChange();
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMFSCopy: TK_FormCMFSCopy;

procedure K_CMFSCopyDlg( );

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CLib0, K_Script1, K_CML1F, K_UDT2, {K_FEText,}
  N_Lib1, N_Comp1, N_Video, N_ClassRef, N_CMMain5F, N_Gra2;

const K_Img   = 'Img\';
const K_Video = 'Video\';
const K_Img3D = 'Img3D\';



procedure FPrepCopyDelFiles( out ASrcFName, ASrcFName1, ASrcFName2 : string; var AFPath : string  );
begin
  // N_Dump2Str( 'CopyFS>> Copy media files' );
  // Img Video Img3D
  // ...
  with K_FormCMFSCopy, TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  begin
    if PrevPat <>  CMSPatID then
      LPatPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID );

    if PrevDate <> CMSDTCreated then
      LDTPath := K_CMSlideGetFileDatePathSegm( CMSDTCreated );

    if (PrevPat <>  CMSPatID) or (PrevDate <> CMSDTCreated) then
    AFPath := LPatPath + LDTPath;

    PrevDate := CMSDTCreated;
    PrevPat := CMSPatID;
    ASrcFName2 := '';
    ASrcFName1 := '';
    if cmsfIsMediaObj in CMSDB.SFlags then // Video
      ASrcFName := AFPath + K_CMSlideGetMediaFileNamePref(ObjName) + CMSDB.MediaFExt
    else
    if cmsfIsImg3DObj in CMSDB.SFlags then // Img3D
    begin
     // 2020-09-25 add new condition for Dev3D objs
     if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
       ASrcFName := AFPath + K_CMSlideGetImg3DFolderName(ObjName)
    end
    else
    begin // Img
      if CMSStudyID < 0 then
      begin // Copy Study File
        ASrcFName := AFPath + K_CMStudyGetFileName(ObjName);
      end
      else
      begin
        ASrcFName := AFPath + K_CMSlideGetCurImgFileName(ObjName);
        if cmsfHasSrcImg in CMSDB.SFlags then
          ASrcFName1 := AFPath + K_CMSlideGetSrcImgFileName(ObjName);
        ASrcFName2 := AFPath + K_CMSlideGetDCMAttrsFileName( ObjName );
      end;
    end; // Img
  end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
end; // procedure FPrepCopyDelFiles

//*********************************************************** K_CMFSCopyDlg ***
//  File Storage Copy Dialog
//
procedure K_CMFSCopyDlg( );
begin
  N_Dump1Str( 'K_CMFSCopyDlg Start' );

  K_FormCMFSCopy := TK_FormCMFSCopy.Create(Application);
  with K_FormCMFSCopy do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_Dump1Str( 'K_CMArchSaveDlg before show' );
    ShowModal();
//    N_Dump1Str( 'K_CMArchSaveDlg after show' );

    K_FormCMFSCopy := nil;

  end;
  N_Dump1Str( 'K_CMFSCopyDlg Fin' );

end; // procedure K_CMUTPrepDBDataDlg

//********************************************** TK_FormCMFSCopy.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSCopy.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
  StartInit := TRUE;
  FPNFrame.OnChange := OnArchPathChange;
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;
  ProcCount := 0;
  CopyCount := 0;
  ErrCount  := 0;
  CopyCountReal := 0;
  ProcDelCount := 0;
  Slide := nil;
  CheckFinishFlag := FALSE;
  CurT := TN_CPUTimer1.Create;
  ResT := TN_CPUTimer1.Create;
  DelFilesProcessFlag := FALSE;

  Timer.Enabled := TRUE;

end; // TK_FormCMFSCopy.FormShow

//******************************************** TK_FormCMFSCopy.TimerTimer ***
//  On Timer Handler
//
procedure TK_FormCMFSCopy.TimerTimer( Sender: TObject );
begin
//  ResT.Start;
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
//    AllCount := 0; // should be 0 + 1 + 2 + 3

//    N_Dump1Str( format( 'CopyFS>> Slides DB all objects %d, copied %d',
//                [AllCount, CopyCountDB] ) );



    if PeriodInDays = 0 then
      PeriodInDays := 5;

    DTPFrom.DateTime := Now() - PeriodInDays;
    DTPFromChange(nil);

    StartInit := FALSE;
    if CopyPath <> '' then
      FPNFrame.AddNameToTop( CopyPath )
    else
      OnArchPathChange();
    DTPFrom.Enabled := TRUE;
  end  // if StartInit then
  else // if not StartInit then
    CalcCopyCountByDate();

  FPNFrame.Enabled := TRUE;
  BtClose.Enabled := TRUE;
  LbInfo.Caption  := '';
  Screen.Cursor := SavedCursor;

//  ResT.Stop;
//  N_Dump1Str( 'CopyFS>> TimerTimer Time=' + ResT.ToStr() );


end; // procedure TK_FormCMFSCopy.TimerTimer

//**************************************** TK_FormCMFSCopy.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSCopy.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]);  //'Pause'

  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( 'Do you really want to break the process?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if ProcCount < CopyCount then
    N_Dump1Str( 'CopyFS>> Break by user' );

// Clear Global context and free objects
  if not CheckFinishFlag then
    TK_CMEDDBAccess(K_CMEDAccess).CurDSet2.Close;

  Slide.Free;
  CurT.Free;
  ResT.Free;

end; // TK_FormCMFSCopy.FormCloseQuery

//***************************************** TK_FormCMFSCopy.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSCopy.BtStartClick(Sender: TObject);
var
  WText, ResText, FileErrText : string;
  CopyErrCount, PortionStartProcCount : Integer;
  FullDstFName1, PatChangeFName  : string;

label FinExit, ContProc;

  function FCopyFile( const ASrcFile, ADstFile : string ) : Integer;
  var
    ResCode : Integer;
  begin
    ResCode := K_CopyFile( ASrcFile, ADstFile, [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
    Result := 0;
    if ResCode > 0 then
      Result := 1;
    case ResCode of
      0: N_Dump2Str( 'CopyFS>> Copy File ' + ASrcFile );
      3: N_Dump1Str( 'CopyFS>> Couldn''t copy Src doesn''t exist ' + ASrcFile );
      4: N_Dump1Str( 'CopyFS>> Couldn''t copy ' + ASrcFile );
      5: N_Dump1Str( 'CopyFS>> Couldn''t create Dst path ' + ADstFile );
    end;

  end; // function FCopyFile

  function CopyAllMediaFiles() : Integer;
  var
    CopyCount : Integer;
    OK3DFlag  : Boolean;
//    Del3DFlag : Boolean;
  begin
    // N_Dump2Str( 'CopyFS>> Copy media files' );
    // Img Video Img3D
    // ...
    FPrepCopyDelFiles( SrcFName, SrcFName1, SrcFName2, CopyFPathSegm );
    with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
    begin

      if cmsfIsMediaObj in CMSDB.SFlags then
      begin // Video
        CurT.Start;
        Result := FCopyFile( SlidesMediaRootFolder + SrcFName,  CopyPath + K_Video + SrcFName );
        CurT.Stop;
        N_Dump1Str( format( 'CopyFS>> Copy Slide Video File=%s Time=%s',
                            [SrcFName, CurT.ToStr()] ) );

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
//        Del3DFlag := not OK3DFlag;
        if not OK3DFlag then
        begin
          CurT.Start;
          OK3DFlag := K_CopyFolderFiles( SlidesImg3DRootFolder + SrcFName, CopyPath + K_Img3d + SrcFName,
                                  '*.*', [K_cffOverwriteReadOnly,K_cffOverwriteNewer] );
          CurT.Stop;
          N_Dump1Str( format( 'CopyFS>> Copy Slide 3D Files from %s Time=%s',
                             [SrcFName, CurT.ToStr()] ) );
          if not OK3DFlag then
          begin
            Result := 1;
            N_Dump1Str( 'CopyFS>> Couldn''t copy ' + SlidesImg3DRootFolder + SrcFName );
          end;
        end;
//        DelFilesFlag := (Result = 0) and Del3DFlag;
      end   // Img3D
      else
      begin // Img
        CopyCount := 0;
        CurT.Start;
{
        if CMSStudyID < 0 then
        begin // Copy Study File
        end
        else
}
        begin
          Result := FCopyFile( SlidesImgRootFolder + SrcFName, CopyPath + K_Img + SrcFName );
          if Result = 0 then
            CopyCount := 1;

          if (Result = 0) then
          begin
            if (cmsfHasSrcImg in CMSDB.SFlags) then
            begin
              FullDstFName1 := CopyPath + K_Img + SrcFName1;
              Result := FCopyFile( SlidesImgRootFolder + SrcFName1, FullDstFName1 );
              if Result = 0 then
                CopyCount := 2;
            end;
            if SrcFName2 <> '' then
            begin
              if FileExists(SlidesImgRootFolder + SrcFName2) then
              begin
                FullDstFName1 := CopyPath + K_Img + SrcFName2;
                Result := FCopyFile( SlidesImgRootFolder + SrcFName2, FullDstFName1 );
                if Result = 0 then
                  Inc(CopyCount);
              end;
            end; // if SrcFName2 <> '' then
          end;
        end;
        CurT.Stop;
        N_Dump1Str( format( 'CopyFS>> Copy Slide Img Files %s Count=%d AllTime=%s AverageTime=%s',
                            [SrcFName, CopyCount, CurT.ToStr(), CurT.ToStr(CopyCount)] ) );

//        DelFilesFlag := Result = 0;
      end; // Img
    end; // with TK_CMEDDBAccess(K_CMEDAccess), Slide, P^ do
  end; // function CopyAllMediaFiles


begin
// Process Slides Loop
  DelFilesProcessFlag := FALSE;
  N_Dump1Str( format( 'CopyFS>> Loop %s >> %d of %d media object(s) is processed.',
                      [BtStart.Caption, ProcCount, CopyCount] ) );
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
          CopyCountReal := 0;
          CheckFinishFlag := FALSE;

          Slide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));

  //          ChangeFSizeInfoFlag := FALSE;
          SQL.Text := 'select ' +
      K_CMENDBSTFSlideID        + ',' + K_CMENDBSTFPatID  + ',' + // 0, 1
      K_CMENDBSTFSlideDTCr      + ',' + // 2
      K_CMENDBSTFSlideSysInfo   + ',' + // 3
      K_CMENDBSTFSlideStudyID   +       // 4
      SQLFromWhereStr +
      ' order by ' + K_CMENDBSTFPatID + ', ' + K_CMENDBSTFSlideDTCr;
          N_s :=  SQL.Text;
          CurT.Start;
          Open();
          CurT.Stop;
          N_Dump1Str( 'CopyFS>> Slides DB select Time=' + CurT.ToStr() );

          if RecordCount > 0 then
          begin
            if not K_ForceDirPath( CopyPath ) then
            begin
              Close;
              BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
              BtClose.Enabled := TRUE;
              FPNFrame.Enabled := TRUE;
              DTPFrom.Enabled := TRUE;
              K_CMShowMessageDlg( {sysout}  'Couldn''t create Copy root folder!!!', mtError );
              Exit;
            end;
          end; // if RecordCount > 0 then
        end; // if BtStart.Caption = 'Start' then


      end; // if BtStart.Caption <> 'Pause' then

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
      BtClose.Enabled := FALSE;

      LbInfo.Caption  := ' Copying is in process ... ';
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
//          CurT.tart;
          ObjName := FieldList[0].AsString;
          CMSPatID := FieldList[1].AsInteger;
          CMSDTCreated := TDateTimeField(FieldList[2]).Value;
          K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
          CMSStudyID := FieldList[4].AsInteger;
//          DelFilesFlag := FALSE;
          N_Dump2Str( format( 'CopyFS>> Start ID=%s processing.',[ObjName] ) );
//          CurT.Stop;
//          N_Dump1Str( format('CopyFS>> ID=%s Slide Fields get Time=%s', [ObjName,CurT.ToStr()] ) );


          CopyErrCount := CopyAllMediaFiles();
          if CopyErrCount = 0 then
          begin
            Inc(CopyCountReal);
          end
          else
            ErrCount := ErrCount + CopyErrCount;

        end; // with Slide, P^ do

ContProc: //***** continue processing
        Inc(ProcCount);
        if CopyCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / CopyCount);

        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();

//        CurT.Start;
        Next;
//        CurT.Stop;
//        N_Dump1Str( 'CopyFS>> Next Slide Time=' + CurT.ToStr() );

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
      N_Dump1Str( format( 'CopyFS>> Copying portion=%d AllTime=%s AverageTime=%s',
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

      WText := ' Copying is %s. %d of %d media object(s) were processed.';

//ProcCount :=10;
//CopyCount := 10;
//CopyCountReal := 10;
//ErrCount := 2;
//UnDelFilesCount := 4;
//UnDelFilesSlidesCount := 2;

      if (ProcCount > CopyCountReal) or
         (ErrCount > 0) then
      begin
        WText := WText + #13#10 +
                 ' %d media object(s) were not copied because of copy error(s)!';

        if (ErrCount > 0) then
          WText := WText + #13#10 +
                   ' %d copy file error(s) were detected.';

      end;


      FileErrText := format( WText, [ResText, ProcCount, CopyCount,
                                     ProcCount - CopyCountReal,
                                     ErrCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

      if CheckFinishFlag then
      begin
        CopyCountReal := 0;
      end;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMFSCopy.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFSCopy.BtStartClick


//***************************************** TK_FormCMFSCopy.DTPFromChange ***
//  On DTPFrom Change Handler
//
procedure TK_FormCMFSCopy.DTPFromChange(Sender: TObject);
begin
  if StartInit then
    CalcCopyCountByDate()
  else
    Timer.Enabled := TRUE;

end; // procedure TK_FormCMFSCopy.DTPFromChange

//************************************* TK_FormCMFSCopy.ChBCopyVideoClick ***
//  On DTPFrom Change Handler
//
procedure TK_FormCMFSCopy.ChBCopyVideoClick(Sender: TObject);
begin
  CalcCopyCountByDate();
end; // procedure TK_FormCMFSCopy.ChBCopyVideoClick

//*********************************** TK_FormCMFSCopy.CalcCopyCountByDate ***
//  Get Common Counters Info
//
procedure TK_FormCMFSCopy.CalcCopyCountByDate;
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
      if not ChBCopyImg3D.Checked then
        SQLCondStr := ' not (' + K_CMENDBSTFSlideSysInfo + ' like ''%cmsfIsImg3DObj%'')';
      if not ChBCopyVideo.Checked then
      begin
        if SQLCondStr <> '' then
          SQLCondStr := SQLCondStr + ' and ';
        SQLCondStr := SQLCondStr + ' not (' + K_CMENDBSTFSlideSysInfo + ' like ''%cmsfIsMediaObj%'')';
      end;

      if SQLCondStr <> '' then
        SQLCondStr := ' and ((' + K_CMENDBSTFSlideSysInfo + ' is null) or (' + SQLCondStr + ') )';

      SQLFromWhereStr := ' from ' + K_CMENDBSlidesTable +
  //    ' where ' + K_CMENDBSTFSlideDTCr + ' < ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) ) + ' and ' +         // Old
  // BR: DTPFrom.Date - archiving media objects maximal date, so <= condition should be used
  //    ' where ' + K_CMENDBSTFSlideDTCr + ' <= ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) ) + ' and ' +         // Old
      ' where ' + K_CMENDBSTFSlideDTCr + ' >= ' + EDADBDateTimeToSQL( Floor(DTPFrom.Date) ) + ' and ' +         // Old
 //                 K_CMENDBSTFSlideStudyID + ' >= 0 and ' +                                              // not Study
                  '(' + K_CMENDBSTFSlideFlags + ' = 0 or ' + K_CMENDBSTFSlideFlags + ' is null) and ' + // not marked as deleted
                  ' not (' + K_CMENDBSTFSlideThumbnail + ' is null)' +                             // not archived
                  SQLCondStr;

      SQL.Text := 'select Count(*) ' + SQLFromWhereStr;
      Open();
      CopyCount := FieldList.Fields[0].AsInteger;
      Close;

      LbEMCountToBeCopied.Text := IntToStr( CopyCount );
      LbEMCountToBeCopied.Refresh;

      PeriodInDays := Floor( Now() - DTPFrom.Date );
      BtStart.Enabled := (CopyCount > 0);
//BtStart.Enabled := TRUE;
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMFSCopy.CalcCopyCountByDate ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

  CurT.Stop;
  N_Dump1Str( format( 'CopyFS>> CalcCopyCountByDate=%d time=%s', [CopyCount, CurT.ToStr()] ) );
end; // TK_FormCMFSCopy.CalcCopyCountByDate;

//************************ ************* TK_FormCMFSCopy.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSCopy.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( 'FSCopy', 'PeriodInDays', PeriodInDays );
  N_StringToMemIni( 'FSCopy', 'RootFolder', CopyPath );
end; // procedure TK_FormCMFSCopy.CurStateToMemIni

//************************************** TK_FormCMFSCopy.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSCopy.MemIniToCurState;
begin
  inherited;
  PeriodInDays := N_MemIniToInt( 'FSCopy', 'PeriodInDays', 0 );
  CopyPath := N_MemIniToString( 'FSCopy', 'RootFolder', '' );
end; // procedure TK_FormCMFSCopy.MemIniToCurState

//************************************** TK_FormCMFSCopy.OnArchPathChange ***
// On archive path change
//
procedure TK_FormCMFSCopy.OnArchPathChange;
var
  ErrStr : string;

begin
  if FPNFrame.mbPathName.Text = '' then
  begin
    BtStart.Enabled := FALSE;
    Exit;
  end;

  CopyPath := IncludeTrailingPathDelimiter(FPNFrame.mbPathName.Text);
  ErrStr := '';

  BtStart.Enabled := (CopyCount > 0);
//BtStart.Enabled := TRUE;

end; // procedure TK_FormCMFSCopy.OnArchPathChange

end.
