unit K_FCMFSRecovery1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMFSRecovery1 = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDErrCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    LbEDProcCount: TLabeledEdit;
    B1: TButton;
    B2: TButton;
    B3: TButton;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure BtReportClick(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
    procedure B1Click(Sender: TObject);
    procedure B2Click(Sender: TObject);
    procedure B3Click(Sender: TObject);
  private
    { Private declarations }
    ReportSMatr: TN_ASArray;
    ReportCount : Integer;
    StartMSessionTS : TDateTime;
    SavedCursor: TCursor;
    FilesList : TStringList;
    BreakFlag : Boolean;

    ReportIsNeededFlag : Boolean;

    BaseFilesPath : string;

    ProcCount, ErrCount, AllCount : Integer;
  public
    { Public declarations }
    CreateAtributeFilesFlag : Boolean;
    CheckRecoverFilesDuplicateCheckFlag : Boolean;
    UseMarkedAsDeletedFlag : Boolean;
    CheckDateFolderFlag : Boolean;
    CheckPatientFolderFlag : Boolean;
  end;

var
  K_FormCMFSRecovery1: TK_FormCMFSRecovery1;

implementation

{$R *.dfm}

uses
  IniFiles,
  K_CML1F, K_CLib0, K_CM0, K_FCMReportShow, K_Script1,
  N_Comp1, N_Lib0, N_ClassRef;

var K_StrFName : string;
procedure K_StrAddToFile( const AStr : string );
var
  F: TextFile;
begin
  if K_StrFName = '' then Exit;
  try
    Assign( F, K_StrFName );
    if not FileExists( K_StrFName ) then
      Rewrite( F )
    else
      Append( F );
    WriteLn( F, AStr );
    Flush( F );
    Close( F );
  except
  end;
end; // K_StrAddToFile

procedure K_FileClear( );
var
  F: TextFile;
begin
  try
    Assign( F, K_StrFName );
    Rewrite( F );
    Close( F );
  except
  end;
end; // K_FileClear

//***************************************** TK_FormCMDBRecovery.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSRecovery1.FormShow(Sender: TObject);
begin
  inherited;
// Code Moved from FormCreate

  LbEDBMediaCount.Text := '0';
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;

end; // TK_FormCMDBRecovery.FormShow

//***************************************** TK_FormCMDBRecovery.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSRecovery1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FilesList.Free;
end; // TK_FormCMDBRecovery.FormCloseQuery

//***************************************** TK_FormCMDBRecovery.BtStartClick ***
//  On Button Start Click Handler
//
// File storage report:
// RelativePath FileName FileSize FilePlainSize FileCheckSum CorruptedFlag
//
procedure TK_FormCMFSRecovery1.BtStartClick(Sender: TObject);
var
  FPath  : string;
  FPath1 : string;
  FName  : string;
  i, DSize : Integer;
  UDDIB : TN_UDDIB;
  PData : Pointer;
  FileInfo : string;
  SFileCRC : string;
  FResult : Boolean;
  FExt : string;
  ProtectedFile : Boolean;

//label ContLoop, FileError, FinExit;
label ContLoop, ContLoop1, ImgFileError, CheckLostFiles, FinExit, FinExit0;

begin

// Process Slides Loop
  N_Dump1Str( 'RFS >> Start' );
  if not K_CMImportFolderSelectDlg( BaseFilesPath, 'Select File Storage Root' ) then
  begin
    StatusBar.SimpleText := 'File storage folder was not selected';
    Exit;
  end;
  with K_CMEDAccess do
  begin
   //////////////////////////////////////
   // Build Media Objects Files List
   //
    TmpStrings.Clear;
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    StatusBar.SimpleText := ' Build files list ...';

    BaseFilesPath := IncludeTrailingPathDelimiter(BaseFilesPath);
    K_StrFName := BaseFilesPath + 'FSReport'+ K_DateTimeToStr( Now(), 'yyyy.mm.dd_hh-nn-ss' ) + '.txt';
    K_FileClear( );

    SkipDataFolder := BaseFilesPath + 'Bad *';
    K_ScanFilesTree( BaseFilesPath, EDASelectDataFiles );
    FilesList := TStringList.Create;
    FilesList.Assign( TmpStrings );

    StatusBar.SimpleText := '';
    Screen.Cursor := SavedCursor;
    AllCount := FilesList.Count;

    LbEDBMediaCount.Text := IntToStr( AllCount );

    N_Dump1Str( format( 'RFS>> Files dump start AllCount=%d Path= ',
                          [AllCount, BaseFilesPath] ) );

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    StatusBar.SimpleText := ' File storage dump ... ';
    ErrCount := 0;
    ProcCount := 0;
    for i := 1 to AllCount do
    begin
      if BreakFlag then Break;
      FPath := FilesList[i-1];
      N_Dump2Str( 'RFS>> Try ' + FPath );
      FName := ExtractFileName(FPath);
      FPath1 := ExtractFilePath(FPath);
      FPath1 := Copy( FPath1, Length(BaseFilesPath) + 1, Length(FPath1) - Length(BaseFilesPath) );

      if K_StrStartsWith( 'FSReport', FName ) then Continue;
      SFileCRC := '-';
      FileInfo := '';
      FResult := K_DFOpen( FPath, ExtDFile, [] );
      if FResult then
      begin
        DSize := ExtDFile.DFPlainDataSize;
        if Length(BlobBuf) < DSize then
        begin
          BlobBuf := nil;
          SetLength(BlobBuf, DSize);
        end;

      // Check File Content
        ProtectedFile := (DSize >= 0) and
                         (DSize < ExtDFile.DFSize);
        PData := @BlobBuf[0];
        FResult := K_DFReadAll( PData, ExtDFile );
        if FResult then
        begin
          if ProtectedFile then
            SFileCRC := IntToHex(ExtDFile.DFPlainDataCRC, 8)
          else
            SFileCRC := IntToHex(N_AdlerChecksum( PData, DSize ), 8);

          FExt := ExtractFileExt(FPath);
          if not ProtectedFile  and
             (Length(FExt) = 4) and (FExt[2] = 'c') and (FExt[3] = 'm') then
          begin
          // Check Image, Study and AddAttrs files (*.cmi or *.cma) Content
            FResult := K_edOK = EDAUncompressData( PData, DSize );
            if FResult then
            begin
              if FExt[4] = 'i' then
              begin
                UDDIB := K_CMCreateUDDIBBySData( PData, DSize, EDAFreeBuffer );
                FResult := UDDIB <> nil;
                if not FResult then
                  FileInfo := 'Corrupted'
                else
                  UDDIB.Free;
              end; // if not ProtectedFile and *.cmi then
            end
            else
              FileInfo := 'Uncompress error';
          end; // if not ProtectedFile and (*.cmi or *.cma)
        end; // if K_DFReadAll( PData, ExtDFile )
      end; // if K_DFOpen( FPath, ExtDFile, [] )

      if ExtDFile.DFErrorCode <> K_dfrOK then
        FileInfo := K_DFGetErrorString( ExtDFile.DFErrorCode );

      if not FResult then
        Inc(ErrCount);

      // FPath FName FSize CRC Details
      K_StrAddToFile( format( '%s'#9'%s'#9'%d'#9'%d'#9'%s'#9'%s',
         [FPath1, FName, ExtDFile.DFSize, DSize, SFileCRC, FileInfo] ) );

      ProcCount := i;
      PBProgress.Position := Round(1000 * ProcCount / AllCount);
      LbEDErrCount.Text := IntToStr( ErrCount );
      LbEDProcCount.Text := IntToStr( ProcCount );
      LbEDProcCount.Refresh();
      Application.ProcessMessages();
    end; // for i := 1 to AllCount do

  end; // with K_CMEDAccess do
  BreakFlag := FALSE;
  StatusBar.SimpleText := '';
  Screen.Cursor := SavedCursor;

  K_CMShowMessageDlg( format( '%d of %d files were processed, %d errors were found, report %s is created',
                              [ProcCount, AllCount, ErrCount, K_StrFName] ), mtInformation );

end; // TK_FormCMDBRecovery.BtStartClick

//***************************************** TK_FormCMDBRecovery.BtReportClick ***
//  On Button Report Click Handler
//
procedure TK_FormCMFSRecovery1.BtReportClick(Sender: TObject);
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

procedure TK_FormCMFSRecovery1.BtCloseClick(Sender: TObject);
begin
  BreakFlag := TRUE;
end;

//********************************************* TK_FormCMDBRecovery.B1Click ***
//  On Button B1 Click Handler
//
// Process Files AllGood report:
// RelativePath FileSize FilePlainSize FileName FileCheckSum
//
// Creates AllGood1 and AllGood2 reports
//
// AllGood1:
// RelativePath FileSize FilePlainSize FileName FileCheckSum FileID(RF_<SlideID>[r])
//
// AllGood2: Slide ID  Pairs with equal CheckSum
// FileID1(RF_<SlideID>[r]) FileID2(RF_<SlideID>[r])
//
procedure TK_FormCMFSRecovery1.B1Click(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  WFName : string;
  SL, SL1, SL2, SL3, SL4, SL5, SL6 : TStringList;
  Ind, i  : Integer;
  SCheck, SCheckPrev, CurStr, RFName, RFNamePrev : string;

  function GetRFName() : string;
  var
    i1 : Integer;
  begin
    i1 := Length(CurStr) - 9 - 4 - 11;
    if i1 > 1 then
    begin
      if CurStr[i1] <> #9 then Dec(i1);
      Inc(i1);
    end
    else
      i1 := 1;
    Result := '';
    if (CurStr[i1+1] <> 'F')   or
       (CurStr[i1+2] <> '_') then Exit;
    i := 11;
    if CurStr[i1 + 11] = 'r' then i := 12;
    Result := Copy( CurStr, i1, i  );
  end;

begin
  OpenDialog := TOpenDialog.Create( Application );
  with OpenDialog do
  begin
    Options := Options + [ofEnableSizing];
    Title := 'Select AllGood file';
    WFName := '';
    if Execute  then
      WFName := FileName;
    Free;
  end;
  if WFName = '' then Exit;
  SL := TStringList.Create;
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  SL3 := TStringList.Create;
  SL4 := TStringList.Create;
  SL5 := TStringList.Create;
  SL6 := TStringList.Create;
  SL.LoadFromFile( WFName );

  for Ind := 0 to SL.Count - 1 do
  begin
    CurStr := SL[Ind];
    RFName := GetRFName();
    if RFName = '' then Continue;
    SCheck := Copy( CurStr, Length(CurStr) - 7, 8 );
    SL3.Add( SCheck );
    SL4.Add( RFName );
    SL5.AddObject( SCheck + '_' + RFName, TObject(Ind) );
  end;

  SL5.Sort();


  SCheckPrev := '';
  RFNamePrev := '';
  i := 0;
  while i < SL5.Count do
  begin
  // Get SCheck
    Ind := Integer(SL5.Objects[i]);
    CurStr := SL[Ind];
    SCheck := SL3[Ind];
    RFName := SL4[Ind];
    Inc(i);

    if SCheck = SCheckPrev then
    begin
    // Check File Name
      if RFName <> RFNamePrev then
      begin
      // Add Line To Duplicates
        SL2.Add( RFNamePrev + #9 + RFName );
        RFNamePrev := RFName;
        SL1.Add( CurStr +  #9 + RFNamePrev );
      end
      else
        SL6.Add( CurStr +  #9 + RFName );
      Continue;
    end;
  // New Check Sum
    RFNamePrev := RFName;
    SCheckPrev := SCheck;
    SL1.Add( CurStr +  #9 + RFNamePrev );
  end;

  SL1.SaveToFile( ChangeFileExt( WFName, '1.txt' ) );
  if SL2.Count > 0 then
    SL2.SaveToFile( ChangeFileExt( WFName, '2.txt' ) );
  if SL6.Count > 0 then
    SL6.SaveToFile( ChangeFileExt( WFName, '3.txt' ) );

  SL.Free;
  SL1.Free;
  SL2.Free;
  SL3.Free;
  SL4.Free;
  SL5.Free;
  SL6.Free;
end;

//********************************************* TK_FormCMDBRecovery.B2Click ***
//  On Button B2 Click Handler
//
// Process Files AllGood1 report:
// RelativePath FileSize FilePlainSize FileName FileCheckSum FileID(RF_<SlideID>[r])
//
// Creates AllGood1_ER, AllGood1_PR, AllGood1_CI and AllGood1_S reports
//
// AllGood1_ER: List of CMI-files which path structure do not corresponds to DB INFO
// FileID(RF_<SlideID>[r]) ErrDescription
// where ErrDescription:
// "absent in DB",
// date <FileDateFolder> <> <Corresponding Folder by DB>
// patient <FilePatientFolder> <> <Corresponding Folder by DB>
//
// AllGood1_PR: DB Patients ID objects counter report
// PatientID(PX_<Patient ID>) PatDBObjsCounter PatFilesCounter
//
// AllGood1_CI: Copy info is used for real files copy by B3Click util
// <FileRecoverRelativePath>=<FileStorageRelativePath>
//
// AllGood1_S: source AllGood1 strings correspoding to AllGood1_ER
// RelativePath FileSize FilePlainSize FileName FileCheckSum FileID(RF_<SlideID>[r])
//
procedure TK_FormCMFSRecovery1.B2Click(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  WFName : string;
  WFName0 : string;
  SQLText : string;
  SL, SL0, SL1, SL2, SL3, SL4 : TStringList;
  Ind, Ind1, Ind2, i : Integer;
  CurStr, RFName, FName, SID, FPath, FPath1, Sample, RPath, RPath1, RPath2 : string;
  PatSCounts, PatFCounts : TN_IArray;

  label FinProc1, FinLoop1;
begin
  OpenDialog := TOpenDialog.Create( Application );
  with OpenDialog do
  begin
    Options := Options + [ofEnableSizing];
    Title := 'Select AllGood1 file';
    WFName := '';
    if Execute  then
      WFName := FileName;

    if CheckRecoverFilesDuplicateCheckFlag then
    begin
      Title := 'Select Existing File Storage files list file';
      WFName0 := '';
      if Execute  then
        WFName0 := FileName;
    end;
    
    Free;
  end;
  if WFName = '' then Exit;



  SL := TStringList.Create;
  SL1 := TStringList.Create;
  SL2 := TStringList.Create;
  SL3 := TStringList.Create;
  SL4 := THashedStringList.Create;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDACheckDBConnection(CurSlidesDSet.Connection);
{
    SQLText := 'select '+ K_CMENDBSTFPatID+ ', count(*) ' +
      ' from ' + EDAGetSlideSelectFromStr( ) +
      ' where ' + K_CMENDBSTFSlideFlags + '=0' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL' +
      ' group by ' + K_CMENDBSTFPatID;
}
    SQLText := 'select '+ K_CMENDBSTFPatID+ ', count(*) ' +
      ' from ' + EDAGetSlideSelectFromStr( );
    if not UseMarkedAsDeletedFlag then
      SQLText := SQLText + ' where ' + K_CMENDBSTFSlideFlags + '=0' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL';
    SQLText := SQLText + ' group by ' + K_CMENDBSTFPatID;

    CurSlidesDSet.SQL.Text := SQLText;
    CurSlidesDSet.Filtered := false;
    CurSlidesDSet.Open;
    Ind := CurSlidesDSet.RecordCount;
    SetLength( PatSCounts, Ind );
    SetLength( PatFCounts, Ind );
    CurSlidesDSet.First();
    for i := 0 to Ind - 1 do
    begin
      SL4.Add( CurSlidesDSet.Fields[0].AsString );
      PatSCounts[i] := CurSlidesDSet.Fields[1].AsInteger;
      CurSlidesDSet.Next();
    end;

    CurSlidesDSet.Close;

{
    CurSlidesDSet.SQL.Text := 'select ' +
      EDAGetSlideSelectFieldsStr( [K_sffAddMapRootField] ) +
      ' from ' + EDAGetSlideSelectFromStr( ) +
      ' where ' + K_CMENDBSTFSlideFlags + '=0' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL';
}
    SQLText := 'select ' +
      EDAGetSlideSelectFieldsStr( [K_sffAddMapRootField] ) +
      ' from ' + EDAGetSlideSelectFromStr( );
    if not UseMarkedAsDeletedFlag then
      SQLText := SQLText + ' where ' + K_CMENDBSTFSlideFlags + '=0' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL';

    CurSlidesDSet.SQL.Text := SQLText;
    CurSlidesDSet.Filtered := false;
    CurSlidesDSet.Open;
  end;

  SL0 := nil;
  if WFName0 <> '' then
  begin
    SL0 := TStringList.Create;
    SL0.LoadFromFile( WFName0 );
    for i := 0 to SL0.Count - 1 do
      SL0[i] := ExtractFileName(SL0[i]);
  end;

  SL.LoadFromFile( WFName );
  LbEDBMediaCount.Text := IntToStr( SL.Count );
  for Ind := 0 to SL.Count - 1 do
  begin
    CurStr := SL[Ind];
    i := Length(CurStr);

    Ind1 := i - 7;
    if CurStr[i] = 'r' then
      Dec(Ind1);
    // Remove Zeros
    SID := Copy( CurStr, Ind1, 8 );
    SID := IntToStr( StrToInt( SID ) );

    Ind1 := Ind1 - 3;
    RFName := Copy( CurStr, Ind1, 12 );

    Ind1 := Ind1 - 11;
    Ind2 := Ind1;
    while CurStr[Ind2] <> #9 do Dec(Ind2);
    FName := Copy( CurStr, Ind2 + 1, Ind1 - Ind2 );

  // Select from DB
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      CurSlidesDSet.Filtered := FALSE;
      CurSlidesDSet.Filter := K_CMENDBSTFSlideID + ' = ' + SID;
      CurSlidesDSet.Filtered := TRUE;
      if CurSlidesDSet.RecordCount = 0 then
      begin
        SL2.Add( format( '%s absent in DB',[RFName] ) );
        SL3.Add(CurStr);
        Continue;
      end;
      // Select Slide Fields
      CurSlide := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1, N_UDCMSlideCI));
      EDAGetSlideFields( CurSlide, TRUE );
      EDAGetSlideMapRoot0(CurSlide);

    // Parse Path
      Ind1 := Pos( #9, CurStr );
      if Ind1 > 1 then
        FPath := Copy( CurStr, 1, Ind1 - 1 )
      else
        FPath := '';

      // Check Date and Patient Folders
      if CheckDateFolderFlag then
      begin
        if Ind1 > 1 then
        begin
          Ind1 := Length(FPath) - 1;
          while (Ind1 >= 1) and (FPath[Ind1] <> '\') do Dec(Ind1);
        end
        else
          Ind1 := -1;

        if Ind1 >= 0 then
        begin
          FPath1 := Copy( FPath, Ind1 + 1, 10 );
          Sample := K_DateTimeToStr(CurSlide.P.CMSDTCreated, 'yyyy-mm-dd' );
        end
        else
          FPath1 := '';

        if (FPath1 = '') or (FPath1 <> Sample) then
        begin
          SL2.Add( format( '%s date "%s" <> %s',[RFName, FPath1, Sample] ) );
          SL3.Add(CurStr);
          goto FinLoop1;
        end
        else
        if CheckPatientFolderFlag then
        begin
        // Parse and check Patient
          FPath1 := '';
          Ind2 := Ind1 - 1;
          if Ind2 >= 1 then
          begin
            while FPath[Ind2] <> '\' do Dec(Ind2);
            Inc(Ind2);
            Ind1 := Ind1 - Ind2;
            Sample := format('PX_%.3d', [CurSlide.P.CMSPatID]);
//            i := Length(Sample);
//            FPath1 := Copy( FPath, Ind2, i );
            if Ind1 > 0 then
              FPath1 := Copy( FPath, Ind2, Ind1 );
          end
          else
            Ind1 := 0;

          if (Ind1 < i) or
             (FPath1 <> Sample) or
             ((Ind1 > i) and (FPath[Ind2+i] <> '_')) then
          begin
            SL2.Add( format( '%s patient "%s" <> %s',[RFName, FPath1, Sample] ) );
            SL3.Add(CurStr);
            goto FinLoop1;
          end;
        end;
      end;

      // Check duplicates in existing files List
      if SL0 <> nil then
      begin
        Ind1 := SL0.IndexOf( RFName + '.cmi' );
        if Ind1 >= 0 then
        begin
          SL2.Add( format( '%s already exists',[RFName] ) );
          SL3.Add(CurStr);
          goto FinLoop1;
        end;
      end;

      // Create Slide Attrs File in DB Files Storage
      RPath1 := CurSlide.GetFilesPathSegm();
      RPath := SlidesImgRootFolder + RPath1;
      RPath2 := CurSlide.GetAttrsFileName( RPath );

      if not FileExists( RPath2 ) then
      begin
        Ind1 := SL4.IndexOf( IntToStr(CurSlide.P.CMSPatID) );
        Inc(PatFCounts[Ind1]);

        if CreateAtributeFilesFlag then
        begin
          EDAForceFilePath( RPath, TRUE, FALSE );
          CurSlide.SaveAttrsToFile( CurSlide.GetAttrsFileName( RPath ), FALSE );
        end;
      end;

      SL1.Add( RPath1 + RFName + '.cmi=' + FPath + FName );

FinLoop1:
      FreeAndNil( CurSlide );
      PBProgress.Position := Round(1000 * (Ind + 1) / SL.Count);
      LbEDProcCount.Text := IntToStr( Ind + 1 );
      Application.ProcessMessages();
      if BreakFlag then goto FinProc1;

    end;

  end;

  SL1.SaveToFile( ChangeFileExt( WFName, '_CI.txt' ) );
  if SL2.Count > 0 then
    SL2.SaveToFile( ChangeFileExt( WFName, '_ER.txt' ) );

  if SL3.Count > 0 then
    SL3.SaveToFile( ChangeFileExt( WFName, '_S.txt' ) );
  for i := 0 to High(PatFCounts) do
    SL4[i] := format( 'PX_%s'#9'%d'#9'%d', [SL4[i], PatSCounts[i], PatFCounts[i] ] );
  SL4.SaveToFile( ChangeFileExt( WFName, '_PR.txt' ) );

FinProc1:
  BreakFlag := FALSE;
  StatusBar.SimpleText := '';
  Screen.Cursor := SavedCursor;

  SL.Free;
  SL0.Free;
  SL1.Free;
  SL2.Free;
  SL3.Free;
  SL4.Free;
end;

//********************************************* TK_FormCMDBRecovery.B3Click ***
//  On Button B3 Click Handler
//
// Copy recovered files to file storage by  AllGood1_CI Info:
// <FileRecoverRelativePath>=<FileStorageRelativePath>
//
procedure TK_FormCMFSRecovery1.B3Click(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  WFName, Mes : string;
  SL : TStringList;
  Ind : Integer;
  FPath, FPath1, RPath, RPath1 : string;

  label FinProc1, FinLoop1;
begin
  OpenDialog := TOpenDialog.Create( Application );
  with OpenDialog do
  begin
    Options := Options + [ofEnableSizing];
    Title := 'Select file';
    WFName := '';
    if Execute  then
      WFName := FileName;
    Free;
  end;
  if WFName = '' then Exit;

  FPath1 := ExtractFilePath(WFName);
  RPath1 := TK_CMEDDBAccess(K_CMEDAccess).SlidesImgRootFolder;
  if mrNo = K_CMShowMessageDlg( format( 'Files *.cmi will by copied'#13#10 +
                              'from %s'#13#10 +
                              'to   %s'#13#10 +
                              'Continue?',
                              [FPath1, RPath1] ),
                              mtConfirmation, [mbYes, mbNo] ) then Exit;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  SL := TStringList.Create;
  SL.LoadFromFile( WFName );
  LbEDBMediaCount.Text := IntToStr( SL.Count );
  ErrCount := 0;
  ProcCount:= 0;
  for Ind := 0 to SL.Count - 1 do
  begin
    RPath := RPath1 + SL.Names[Ind];
    FPath := FPath1 + SL.ValueFromIndex[Ind];

    case K_CopyFile( FPath, RPath, [] ) of
    0 : begin Inc(ProcCount); goto FinLoop1; end;
    1:  Mes := format( 'Read only destination file'#13#10 +
               '  %s'#13#10' is found. Continue?', [RPath] );
    2:  Mes := format( 'Newer destination file'#13#10 +
               '  %s'#13#10' is found. Continue?', [RPath] );
    3:  Mes := format( 'Source file '#13#10 +
               '  %s'#13#10' is not found. Continue?', [FPath] );
    4:  Mes := format( 'Couldn''t copy file'#13#10 +
               '  %s'#13#10' Continue?', [FPath] );
    5:  Mes := format( 'Couldn''t create path'#13#10 +
               '  %s'#13#10' Continue?', [ExtractFilePath(RPath)] );
    end;
    Inc(ErrCount);

    if mrNo = K_CMShowMessageDlg( Mes, mtConfirmation, [mbYes, mbNo] ) then goto FinProc1;

FinLoop1:
    PBProgress.Position := Round(1000 * ProcCount / SL.Count);
    LbEDProcCount.Text := IntToStr( ProcCount );
    LbEDErrCount.Text := IntToStr( ErrCount );
    Application.ProcessMessages();
    if BreakFlag then Break;
  end; // for Ind := 0 to SL.Count - 1 do

FinProc1:
  BreakFlag := FALSE;
  StatusBar.SimpleText := '';
  Screen.Cursor := SavedCursor;

  K_CMShowMessageDlg( format( '%d of %d files were copied (%d errors)',
                              [ProcCount, SL.Count, ErrCount] ), mtInformation );

  SL.Free;
end;

end.
