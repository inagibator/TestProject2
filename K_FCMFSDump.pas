unit K_FCMFSDump;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles,
  N_BaseF, N_Types,
  K_CLib0;

type
  TK_FormCMFSDump = class(TN_BaseForm)
    LbEDFilesCount: TLabeledEdit;
    LbEDDBCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    ChBFileNamesOnly: TCheckBox;
    RGContent: TRadioGroup;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    ExistFilesList : TStringList;
    ImgFilesList : TStringList;
    VideoFilesList : TStringList;
    Img3DFilesList : TStringList;
    ExistedImgFilesCount : Integer;
    ExistedVideoFilesCount : Integer;
    ExistedImg3DFilesCount : Integer;

    FSAnalysisFinishFlag : Boolean;

    AllCount, FProcCount : Integer;

  public
    { Public declarations }
  end;

var
  K_FormCMFSDump: TK_FormCMFSDump;

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_UDT1, K_UDC, K_UDConst, K_SBuf, K_CM0, K_CM1, K_FCMReportShow, K_Script1, {K_FEText,}
  K_STBuf,
  N_CompBase, N_Comp1, N_Lib1, N_Lib2, N_Video, N_ClassRef, N_CMMain5F, K_CML1F;

const K_BadImg   = 'Bad images';
const K_BadVideo = 'Bad video';
const K_BadImg3D = 'Bad 3D images';


//***************************************** TK_FormCMFStorageClear1.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSDump.FormShow(Sender: TObject);
begin
  inherited;

  SavedCursor := Screen.Cursor;

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
     //////////////////////////////////////
     // Get DB Slides Count
     //
      Filtered := FALSE;
      SQL.Text := 'select Count(*) from ' + K_CMENDBSlidesTable;
      Open();
      AllCount := FieldList[0].AsInteger;
      Close();
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMDBRecovery.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

    LbEDDBCount.Text := IntToStr( AllCount );
    LbEDProcCount.Text := '0';
    LbEDFilesCount.Text := '0';
    PBProgress.Max := 1000;
    PBProgress.Position := 0;
  end;

  ExistFilesList := TStringList.Create;
  ImgFilesList   := TStringList.Create;
  VideoFilesList := TStringList.Create;
  Img3DFilesList := TStringList.Create;

  ExistedImgFilesCount   := 0;
  ExistedVideoFilesCount := 0;
  ExistedImg3DFilesCount := 0;

  SavedCursor := Screen.Cursor;

end; // TK_FormCMFStorageClear1.FormShow

//***************************************** TK_FormCMFStorageClear1.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSDump.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin
  CanClose := FSAnalysisFinishFlag or (FProcCount = 0); // 'Stop'
  if not CanClose then
  begin
    CanClose := mrYes = K_CMShowMessageDlg(
      'Do you really want to break files storage dump prepare?',
                        mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'FSD>> Break by user ' );
  end;

  if not CanClose then Exit;

  ExistFilesList.Free;
  ImgFilesList.Free;
  VideoFilesList.Free;
  Img3DFilesList.Free;

end; // TK_FormCMFStorageClear1.FormCloseQuery

//***************************************** TK_FormCMFStorageClear1.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSDump.BtStartClick(Sender: TObject);
var
  FPath, FName, FName1 : string;
  i : Integer;
  SQLStr : string;
  LPatPath : string;
  LDTPath : string;
  CMSDB   : TN_CMSlideSDBF;
  ContinueFlag : Boolean;
  SSlideID : string;
  PrevPat : Integer;
  PrevDate : TDateTime;


label ContSlidesLoop;

  procedure BuildFilesList( const RootFolder, SkipFolder : string );
  var i : Integer;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      TmpStrings.Clear;
      TmpStrings.Sorted := FALSE;
      SkipDataFolder := RootFolder + SkipFolder;
      RelPathStartInd := 1 + Length(RootFolder);
      K_ScanFilesTree( RootFolder, EDASelectDataFiles, '*.*' );

      // Remove Patients Data Actual TimeStamp files
      for i := TmpStrings.Count - 1 downto 0 do
        if TmpStrings[i][Length(TmpStrings[i])] = '!' then
          TmpStrings.Delete(i)
        else
          if ChBFileNamesOnly.Checked then
            TmpStrings[i] := ExtractFileName(TmpStrings[i]);
      TmpStrings.Sort;
    end;
  end; // procedure BuildFilesList

begin

// Process Slides Loop
  N_Dump1Str( 'FSD>> ' + BtStart.Caption );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      PrevPat := -1;
      PrevDate := 0;
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then
      begin // Stop
        Screen.Cursor := SavedCursor;
        BtClose.Enabled := TRUE;
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        N_Dump1Str( 'FSD>> Stopped by user ' );
        K_CMShowMessageDlg( format('%d media objects were processed',[FProcCount]), mtInformation );
        Exit;
      end
      else
      begin  // Start or Continue

        Screen.Cursor := crHourglass;
        ContinueFlag := not (BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]);
        if not ContinueFlag then // 'Start'
        begin
          FProcCount := 0;

          //////////////////////////////////////
          // Build Media Objects Files List
          //
          ExistFilesList.Clear;

          if RGContent.ItemIndex < 2 then
          begin
            K_ScanFilesTreeMaxLevel := 4;

            StatusBar.SimpleText := ' Build image files list ...';
            BuildFilesList( SlidesImgRootFolder, K_BadImg );
            ExistedImgFilesCount := TmpStrings.Count;
            ExistFilesList.Add( format( 'Img Root=%s Count=%d', [SlidesImgRootFolder,ExistedImgFilesCount] ) );
            ExistFilesList.AddStrings( TmpStrings );

            StatusBar.SimpleText := ' Build video files list ...';
            BuildFilesList( SlidesMediaRootFolder, K_BadVideo );
            ExistedVideoFilesCount := TmpStrings.Count;
            ExistFilesList.Add( format( 'Video Root=%s Count=%d', [SlidesMediaRootFolder,ExistedVideoFilesCount] ) );
            ExistFilesList.AddStrings( TmpStrings );

            StatusBar.SimpleText := ' Build 3D images folders list ...';
            BuildFilesList( SlidesImg3DRootFolder, K_BadImg3D );
            ExistedImg3DFilesCount := TmpStrings.Count;
            ExistFilesList.Add( format( 'Img3D Root=%s Count=%d', [SlidesImg3DRootFolder,ExistedImg3DFilesCount] ) );
            ExistFilesList.AddStrings( TmpStrings );

            TmpStrings.Clear;
            TmpStrings.Sorted := FALSE;
            K_ScanFilesTreeMaxLevel := 0;
            SkipDataFolder := '';
            RelPathStartInd := 0;
            StatusBar.SimpleText := '';
            Screen.Cursor := SavedCursor;
          end;

          LbEDFilesCount.Text := IntToStr( ExistFilesList.Count - 3);
          N_Dump1Str( format( 'FSD>> FilesCount=%d MediaCount=%d',
                                [ExistFilesList.Count, AllCount] ) );
        end; // Start

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Enabled := FALSE;

        if ContinueFlag then
          goto ContSlidesLoop;

      end; // Start or Continue


      ///////////////////////////////
      // Select Existing Slides
      //

      if (RGContent.ItemIndex = 0) or (RGContent.ItemIndex = 2) then
      begin
        Connection := LANDBConnection;

        // Existing Slides Loop
        SQLStr := 'select ' +
              K_CMENDBSTFSlideID + ',' +         // 0
              K_CMENDBSTFPatID   + ',' +         // 1
              K_CMENDBSTFSlideDTCr + ',' +       // 2
              K_CMENDBSTFSlideSysInfo;           // 3
        if K_CMEDDBVersion >= 24 then
          SQLStr := SQLStr + ','+ K_CMENDBSTFSlideStudyID;
        SQL.Text := SQLStr + ' from ' + K_CMENDBSlidesTable +
                    ' order by ' + K_CMENDBSTFPatID + ',' + K_CMENDBSTFSlideDTCr + ';';
  //                  ' where (' + K_CMENDBSTFSlideFlags + ' & 0x2) = 0 ' +
  //                  ' order by ' + K_CMENDBSTFPatID + ',' + K_CMENDBSTFSlideDTCr + ';';
        Filtered := false;
        Open;
        AllCount := RecordCount;

        LbEDDBCount.Text := IntToStr( AllCount );

        LPatPath := '';
        LDTPath  := '';

        if AllCount > 0 then
        begin
          First();
          while not Eof do
          begin
  ContSlidesLoop: //**********
            Screen.Cursor := crHourglass;
            // Slide Processing
            for i := 0 to 9 do
            begin
              if FProcCount = AllCount then break; //

              SSlideID := FieldList[0].AsString;

              if not ChBFileNamesOnly.Checked then
              begin
                if PrevPat <>  Fields[1].AsInteger then
                  LPatPath := K_CMSlideGetPatientFilesPathSegm( Fields[1].AsInteger );
                PrevPat := Fields[1].AsInteger;
                if PrevDate <> Fields[2].AsDateTime then
                  LDTPath := K_CMSlideGetFileDatePathSegm( Fields[2].AsDateTime );
                PrevDate := Fields[2].AsDateTime;
              end;

              K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);

              FName1 := '';
              if cmsfIsMediaObj in CMSDB.SFlags then
              // Check Video
                VideoFilesList.Add( LPatPath + LDTPath + K_CMSlideGetMediaFileNamePref(SSlideID) + CMSDB.MediaFExt )
              else
              if cmsfIsImg3DObj in CMSDB.SFlags then
              // Check 3D Images
// 2020-07-28 add Capt3DDevObjName <> '' if CMSDB.Capt3DDevObjName = '' then
// 2020-09-25 add new condition for Dev3D objs
                if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
                  Img3DFilesList.Add( LPatPath + LDTPath + K_CMSlideGetImg3DFolderName(SSlideID) )
              else
              begin
                FPath := LPatPath + LDTPath;
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
                ImgFilesList.Add( FName );
                if FName1 <> '' then
                  ImgFilesList.Add( FName1 );
              end;

              Inc(FProcCount);
              Next();
            end; // for i := 0 to 9 do

            if AllCount > 0 then
              PBProgress.Position := Round(1000 * FProcCount / AllCount);
            LbEDProcCount.Text := IntToStr( FProcCount );
            LbEDProcCount.Refresh();
  //          Sleep(1000);

            Application.ProcessMessages;
            if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then Exit;

          end; // while not Eof do
        end; // if AllCount > 0 then

        Close();
      end;

      BtClose.Enabled := TRUE;
      Screen.Cursor := SavedCursor;

      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      BtStart.Enabled := FALSE;
      StatusBar.SimpleText := '';
      FSAnalysisFinishFlag := TRUE;

      if mrYes = K_CMShowMessageDlg( format('%d Img files, %d Video files, %d Img3D folders were found'#10#13+
                                 '%d Img files, %d Video files, %d Img3D folders are needed'#10#13+
                                 'Select Yes if you want to save details',
                                 [ExistedImgFilesCount,ExistedVideoFilesCount,ExistedImg3DFilesCount,
                                  ImgFilesList.Count,VideoFilesList.Count,Img3DFilesList.Count]), mtConfirmation ) then
      begin // Save Files List

        with SaveDialog do
        begin
          InitialDir := K_ExpandFileName(N_MemIniToString('CMS_Main','LastExportDir', ''));

          Filter := 'File storage analysis results (*.txt)|*.txt|All files (*.*)|*.*';
          FilterIndex := 1;
//          Options := Options + [ofEnableSizing];
          Title := 'Save File Storage Dump results';

          FileName := 'CMFSDump.txt';


          if Execute then
          begin
            N_Dump1Str( format( 'FSD>> Files List Dump Base Name>> %s', [FileName] ) );

            if RGContent.ItemIndex < 2 then
            begin
              ExistFilesList.SaveToFile( ChangeFileExt( FileName, 'Existed.txt' ) );
              ExistFilesList.Clear;
            end;

            if (RGContent.ItemIndex = 0) or (RGContent.ItemIndex = 2) then
            begin
              ImgFilesList.Sort;
              ImgFilesList.Sorted := FALSE;
              ImgFilesList.Insert( 0, format( 'Img Root=%s Count=%d', [SlidesImgRootFolder,ImgFilesList.Count] ) );

              ImgFilesList.Add( format( 'Video Root=%s Count=%d', [SlidesMediaRootFolder, VideoFilesList.Count] ) );
              VideoFilesList.Sort;
              ImgFilesList.AddStrings(VideoFilesList);
              ImgFilesList.Add( format( 'Img3D Root=%s Count=%d', [SlidesImg3DRootFolder,Img3DFilesList.Count] ) );

              Img3DFilesList.Sort;
              ImgFilesList.AddStrings(Img3DFilesList);
              ImgFilesList.SaveToFile( ChangeFileExt( FileName, 'Needed.txt' ) );
            end;
          end; // if Execute then

          Free;
        end; // with SaveDialog do
      end;

      // Close Form
      ModalResult := mrOK;

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'FSD>> Restore Slides by File Exception >> ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // try
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFStorageClear1.BtStartClick


end.
