unit K_FCMFSAnalysis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, IniFiles,
  N_BaseF, N_Types,
  K_CLib0;

type
  TK_FormCMFSAnalysis = class(TN_BaseForm)
    LbEDFilesCount: TLabeledEdit;
    LbEDDBCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    ChBUsePrevious: TCheckBox;
//    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    AllFilesList : THashedStringList;
    ResFilesList : TStringList;
    PrevFilesList: TStringList;
    AbsentFilesList: TStringList;

    FSAnalysisFinishFlag : Boolean;

    PrevPat : Integer;
    PrevDate : TDateTime;

    AllCount, FProcCount : Integer;

  public
    { Public declarations }
  end;

var
  K_FormCMFSAnalysis: TK_FormCMFSAnalysis;

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
procedure TK_FormCMFSAnalysis.FormShow(Sender: TObject);
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

  SavedCursor := Screen.Cursor;

end; // TK_FormCMFStorageClear1.FormShow

//***************************************** TK_FormCMFStorageClear1.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSAnalysis.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin
  CanClose := FSAnalysisFinishFlag or (FProcCount = 0); // 'Stop'
  if not CanClose then
  begin
    CanClose := mrYes = K_CMShowMessageDlg(
      'Do you really want to break files storage analysis?',
                        mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'FSA>> Break by user ' );
  end;

  if not CanClose then Exit;

  AllFilesList.Free;
  ResFilesList.Free;
  PrevFilesList.Free;
  AbsentFilesList.Free;


end; // TK_FormCMFStorageClear1.FormCloseQuery

//***************************************** TK_FormCMFStorageClear1.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSAnalysis.BtStartClick(Sender: TObject);
var
  FPath, FName, FName1 : string;
  i : Integer;
  SQLStr : string;
  LPatPath : string;
  LDTPath : string;
  CMSDB   : TN_CMSlideSDBF;
  ContinueFlag : Boolean;
  FInd : Integer;
  SSlideID : string;

label ContSlidesLoop;


begin

// Process Slides Loop
  N_Dump1Str( 'FSA>> ' + BtStart.Caption );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then
      begin // Stop
        Screen.Cursor := SavedCursor;
        BtClose.Enabled := TRUE;
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        N_Dump1Str( 'FSA>> Stopped by user ' );
        K_CMShowMessageDlg( format('%d media objects were processed',[FProcCount]), mtInformation );
        Exit;
      end
      else
      begin  // Start or Continue
        if AbsentFilesList = nil then
          AbsentFilesList := TStringList.Create;

        Screen.Cursor := crHourglass;
        ContinueFlag := not (BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]);
        if not ContinueFlag then // 'Start'
        begin
          FProcCount := 0;

          //////////////////////////////////////
          // Build Media Objects Files List
          //
          TmpStrings.Clear;
          StatusBar.SimpleText := ' Build image files list ...';

          K_ScanFilesTreeMaxLevel := 4;
          SkipDataFolder := SlidesImgRootFolder + K_BadImg;
          K_ScanFilesTree( SlidesImgRootFolder, EDASelectDataFiles, '*.*' );

          StatusBar.SimpleText := ' Build video files list ...';
          SkipDataFolder := SlidesMediaRootFolder + K_BadVideo;
          K_ScanFilesTree( SlidesMediaRootFolder, EDASelectDataFiles, '*.*' );

          StatusBar.SimpleText := ' Build 3D images folders list ...';
          SkipDataFolder := SlidesImg3DRootFolder + K_BadImg3D;
          K_ScanFilesTree( SlidesImg3DRootFolder, EDASelectDataFiles, '*.*' );

          K_ScanFilesTreeMaxLevel := 0;
          SkipDataFolder := '';

          // Remove Patients Data Actual TimeStamp files
          for i := TmpStrings.Count - 1 downto 0 do
            if TmpStrings[i][Length(TmpStrings[i])] = '!' then
              TmpStrings.Delete(i);


          AllFilesList := THashedStringList.Create;
          AllFilesList.Assign( TmpStrings );
          AllFilesList.Sort();

          StatusBar.SimpleText := '';
          Screen.Cursor := SavedCursor;

          LbEDFilesCount.Text := IntToStr( AllFilesList.Count);
          N_Dump1Str( format( 'FSA>> FilesCount=%d MediaCount=%d',
                                [AllFilesList.Count, AllCount] ) );
        end; // Start

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Enabled := FALSE;

        if ContinueFlag then
          goto ContSlidesLoop;

      end; // Start or Continue


      ///////////////////////////////
      // Select Existing Slides
      //
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
      if AllCount > 0 then
      begin
        PrevPat := -1;
        PrevDate := 0;
        First();
        while not Eof do
        begin
ContSlidesLoop: //**********
          // Slide Processing
          for i := 0 to 9 do
          begin
            if FProcCount = AllCount then break; //

            SSlideID := FieldList[0].AsString;

            if PrevPat <>  Fields[1].AsInteger then
            begin
              LPatPath := K_CMSlideGetPatientFilesPathSegm( Fields[1].AsInteger );
              if AllFilesList.Find( SlidesImgRootFolder + LPatPath + '!', FInd ) then
                AllFilesList.Delete( FInd );
            end;

            if PrevDate <> Fields[2].AsDateTime then
              LDTPath := K_CMSlideGetFileDatePathSegm( Fields[2].AsDateTime );

            K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
            FName1 := '';
            if cmsfIsMediaObj in CMSDB.SFlags then
            // Check Video
              FName := SlidesMediaRootFolder + LPatPath + LDTPath + K_CMSlideGetMediaFileNamePref(SSlideID) + CMSDB.MediaFExt
            else
            if cmsfIsImg3DObj in CMSDB.SFlags then
            begin
            // Check 3D Images
// 2020-07-28 add Capt3DDevObjName <> ''   if CMSDB.Capt3DDevObjName = '' then
// 2020-09-25 add new condition for Dev3D objs
              if (CMSDB.Capt3DDevObjName = '') or (CMSDB.MediaFExt = '') then
                FName := SlidesImg3DRootFolder + LPatPath + LDTPath + K_CMSlideGetImg3DFolderName(SSlideID)
              else
                FName := ''
            end
            else
            begin
              FPath := SlidesImgRootFolder + LPatPath + LDTPath;
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
            end;

            if FName <> '' then
            begin // for all case except Dev3D
              if AllFilesList.Find( FName, FInd ) then
                AllFilesList.Delete( FInd )
              else
                AbsentFilesList.Add( FName );

              if (FName1 <> '') then
              begin
                if AllFilesList.Find( FName1, FInd ) then
                  AllFilesList.Delete( FInd )
                else
                  AbsentFilesList.Add( FName1 );
              end;
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

      BtClose.Enabled := TRUE;
      Screen.Cursor := SavedCursor;

      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      BtStart.Enabled := FALSE;
      StatusBar.SimpleText := '';
      FSAnalysisFinishFlag := TRUE;

      if mrYes = K_CMShowMessageDlg( format('%d extra files and 3D folders were found'#10#13+
                                    '%d absent files and 3D folders were found'#10#13+
                                    'Select Yes if you want to save details',
                                 [AllFilesList.Count,AbsentFilesList.Count]), mtConfirmation ) then
//      if (AllFilesList.Count > 0) or (AbsentFilesList.Count > 0) then
      begin // Save Files List

        with SaveDialog do
        begin
          InitialDir := K_ExpandFileName(N_MemIniToString('CMS_Main',
                                         'LastExportDir', ''));

          Filter := 'File storage analysis results (*.txt)|*.txt|All files (*.*)|*.*';
          FilterIndex := 1;
//          Options := Options + [ofEnableSizing];
          Title := 'Save File Storage analysis results';

          FileName := 'CMFSAnalResults.txt';


          if Execute then
          begin
            N_Dump1Str( format( 'FSA>> Files List Analysis Base Name>> %s', [FileName] ) );
{
            if ChBUsePrevious.Checked and FileExists(FileName) then
            begin
              PrevFilesList := TStringList.Create;
              PrevFilesList.LoadFromFile( FileName );
            end
            else
              K_CMShowMessageDlg( format('File with previous results %s is not found',[FileName]), mtInformation );

            if (PrevFilesList <> nil) and (PrevFilesList.Count > 0) then
            begin
              ResFilesList := TStringList.Create;

              for i := PrevFilesList.Count - 1 downto 0 do
              begin
                FName := PrevFilesList[i];
                if AllFilesList.Find( FName, FInd ) then
                begin
                  AllFilesList.Delete( FInd );
                  PrevFilesList.Delete( i );
                  ResFilesList.Add( FName );
                end;
              end; // for i := PrevFilesList.Count - 1 downto 0 do

              FPath := ExtractFilePath(FileName);
              FName := ExtractFileName(FileName);
              FName1 := ExtractFileExt(FName);
              FName := ChangeFileExt( FName, '' );

              // Save LastOnly extra files list
              LPatPath := FPath + FName + 'LastOnly' + FName1;
              if AllFilesList.Count > 0 then
                AllFilesList.SaveToFile( LPatPath )
              else
                K_DeleteFile( LPatPath );

              // Save PrevOnly extra files list
              LPatPath := FPath + FName + 'PrevOnly' + FName1;
              if PrevFilesList.Count > 0 then
                PrevFilesList.SaveToFile( LPatPath )
              else
                K_DeleteFile( LPatPath );

              // Save reliable extra files list
              if ResFilesList.Count > 0 then
              begin
                ResFilesList.Sort;
                ResFilesList.SaveToFile( FileName )
              end
              else
                K_DeleteFile( FileName );
            end // if (PrevFilesList <> nil) and (PrevFilesList.Count > 0) then
            else
              AllFilesList.SaveToFile( FileName );
}
            if AllFilesList.Count > 0 then
            begin
              AllFilesList.Sort;
              AllFilesList.SaveToFile( ChangeFileExt( FileName, 'Extra.txt' ) );
            end;
            if AbsentFilesList.Count > 0 then
            begin
              AbsentFilesList.Sort;
              AbsentFilesList.SaveToFile( ChangeFileExt( FileName, 'Absent.txt' ) );
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
        ExtDataErrorString := 'FSA>> Restore Slides by File Exception >> ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // try
  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFStorageClear1.BtStartClick


end.
