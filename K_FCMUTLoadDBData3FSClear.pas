unit K_FCMUTLoadDBData3FSClear;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_FNameFr;

type
  TK_FormCMUTLoadDBData3FSClear = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    LbEDDelCount: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    DelCount, UsedProcCount : Integer;
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;
    SL, SLU : TStringList;
    FilesListCurFName : string;
    FilesListNum : Integer;
    procedure GetNextFilesList();
    function  SaveClearFSStateToFile() : Boolean;
  public
    { Public declarations }
    FilesListFName : string;
    FilesListPortionCount : Integer;

    AllCount, ProcCount : Integer;
  end;

var
  K_FormCMUTLoadDBData3FSClear: TK_FormCMUTLoadDBData3FSClear;


implementation

{$R *.dfm}

uses DB, Math,
  K_Clib0, K_CM0, K_Script1, K_UDT2, K_CML1F, K_FCMSupport, K_FCMUTLoadDBData3, {K_FEText,}
  N_Lib0, N_Lib1, N_ClassRef;


//****************************************** TK_FormCMFSClear.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMUTLoadDBData3FSClear.FormShow(Sender: TObject);
var
  CurListCount, i, j, UsedCount, ShiftCount : Integer;
begin
  inherited;

  LbEDBMediaCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;

  BtStart.Enabled := FALSE;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

  SLU := TStringList.Create;

  SL := TStringList.Create;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  AllCount := 0;
  FilesListNum := K_CountFolderFiles( ExtractFilePath(FilesListFName),
                                      'UndoFList*.txt', [] );
  N_Dump1Str( format( '3ClearFS>> Files lists number=%d', [FilesListNum] ) );
  CurListCount := 0;
  if FilesListNum > 0 then
  begin
    GetNextFilesList();
    AllCount := FilesListPortionCount * FilesListNum;
    with SL do
    begin
      Clear;
      LoadFromFile(FilesListCurFName);
      if Count = 0 then  // last file is empty
        GetNextFilesList()
      else
        AllCount := AllCount + Count;
      CurListCount := Count;
      N_Dump1Str( format( '3ClearFS>> Last list count=%d, FName=%s', [CurListCount, FilesListCurFName] ) );
    end;
  end; // if FilesListNum > 0 then

  LbEDBMediaCount.Text := IntToStr( AllCount );
  ProcCount := 0;

  if not K_VFLoadIntDataFromTextFile( FilesListFName + 'Counters.dat', K_CMEDAccess.TmpStrings,
                                   [@UsedProcCount,@DelCount] ) then
    K_FormCMSupport.ShowInfo( format( 'Undo media data state load error >> %s',
                                        [N_s] ), 'K_VFLoadIntDataFromTextFile >>' )
  else
    N_Dump1Str( format( '3ClearFS>> Undo copy files is done: %d %d',
                                      [UsedProcCount, DelCount] ) );

  Screen.Cursor := SavedCursor;

  if AllCount = UsedProcCount then
  begin
    K_CMShowMessageDlg( 'All is done', mtWarning );
    Self.Close();
    Exit;
  end;

  if SL.Count = 0 then
  begin
    K_CMShowMessageDlg( format('List "%s" is empty',[FilesListCurFName]), mtWarning );
    Self.Close();
    Exit;
  end;

  ShiftCount := 0;
  UsedCount := UsedProcCount - CurListCount;
  if UsedCount > 0 then
  begin
    GetNextFilesList();
    j := FilesListNum;
    for i := j downto 0 do
    begin
      if UsedCount > FilesListPortionCount then
      begin
        UsedCount := UsedCount - FilesListPortionCount;
        GetNextFilesList();
        Continue;
      end;
      ShiftCount := UsedProcCount;
      UsedProcCount := (FilesListNum + 1) * FilesListPortionCount;
      ProcCount := UsedProcCount - UsedCount;
      ShiftCount := ShiftCount - ProcCount;
      SL.LoadFromFile(FilesListCurFName);
      N_Dump1Str( format( '3ClearFS>> Undo copy files is done: %d %d',
                                      [UsedProcCount, DelCount] ) );
      break;
    end;
  end // if UsedCount > 0 then
  else
  begin
    ShiftCount := UsedProcCount;
  end;

  N_Dump1Str( format( '3ClearFS>> All=%d Proc=%d Use=%d Shift=%d FName=%s', [AllCount, ProcCount, UsedProcCount, ShiftCount, FilesListCurFName] ) );

  BtClose.Enabled := FALSE;
  Screen.Cursor := crHourglass;
  for i := ProcCount + 1 to UsedProcCount do
    SL.Delete(SL.Count - 1);
  Screen.Cursor := SavedCursor;

  ProcCount := ProcCount + ShiftCount;
  LbEDDelCount.Text := format( '%d (%d processing fails)', [ProcCount,ProcCount - DelCount] );

  BtStart.Enabled := TRUE;
  BtClose.Enabled := TRUE;
end; // TK_FormCMFSClear.FormShow

//************************************ TK_FormCMFSClear.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMUTLoadDBData3FSClear.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg(
         'Do you really want to break clear files storage?',
                                         mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( '3ClearFS>> break by user' );
  end;

  SL.Free;

  SLU.Free;

end; // TK_FormCMFSClear.FormCloseQuery

//************************************** TK_FormCMFSClear.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMUTLoadDBData3FSClear.BtStartClick(Sender: TObject);
//type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError );
var
  i, Ind : Integer;
  WText, ResText : string;
  FName : string;
  RFBPath : string;
  CFBPath : string;
  ResCode : Integer;
  HighI   : Integer;

label FinExit,AllProcessed;

begin

// Process Slides Loop
  N_Dump1Str( '3ClearFS>> Loop ' + BtStart.Caption );

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit; //
      end
      else
      begin
        if ProcCount = 0 then
        begin
          if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
          begin
            CheckFinishFlag := FALSE;
    //          DelCount := 0;
            if mrYes <> K_CMShowMessageDlg(
                      '     Do you really want to delete copied files?' + #13#10 +
                      '(Future file copying will start from the beginning)',
                                         mtConfirmation ) then
            begin
              N_Dump1Str( '3ClearFS>> User cancel files deletion' );

              Self.Close();
              Exit;
            end

          end;
          with K_FormCMUTLoadDBData3 do
          begin
    //          K_DeleteFile( MergeCopyFSDataFName );
    //          K_DeleteFile( MergeCopyFSDataCurStateFName );
            MergeCopyFSDataStart := 1;
            MergeCopy2Count := 0;
            MergeCopySCount := 0;
            MergeCopyVCount := 0;
            MergeCopy3Count := 0;
            MergeCopyNFCount := 0;
            SaveCopyFSDataStateToFile( );
          end; // with K_FormCMUTLoadDBData3 do
        end; // if ProcCount = 0 then
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtClose.Enabled := FALSE;
//          ChangeFSizeInfoFlag := FALSE;
      end; // End of Start Init (not Continue)


     //////////////////////////////////////
     // Slides Files Check Loop
     //
      Screen.Cursor := crHourglass;
      HighI := Round(AllCount / 100);
      if HighI < 3 then HighI := 3;
      Dec(HighI);
      while TRUE do // Slides Delete Loop
      begin
        for i := 0 to HighI do
        begin
          if SL.Count = 0 then
          begin
            GetNextFilesList();
            if FilesListNum < 0 then
              goto AllProcessed
            else
            begin
              SL.LoadFromFile(FilesListCurFName);
            end;
          end;
          Ind := SL.Count - 1;
          FName := SL[Ind];
          SL.Delete(Ind);
          Inc(ProcCount);
{
          if UsedProcCount >= ProcCount then
          begin
            Inc(SkipCount);
            Continue;
          end;
}
          RFBPath := '';
          ResCode := 0;
          if FName[Length(FName)] = '\' then
          begin // Process Folder (3DImg)
            if not DirectoryExists( FName ) then
            begin
              Inc(DelCount);
              N_Dump1Str( '3ClearFS>> Folder is absent >> ' + FName );
            end
            else
            begin
              SLU.Clear;
              K_DeleteFolderFilesEx( FName, SLU, '*.*', [K_dffRecurseSubfolders,K_dffRemoveReadOnly] );
              if SLU.Count = 0 then
              begin
                N_Dump1Str( '3ClearFS>> Folder is deleted >> ' + FName );
                RFBPath := SlidesImg3DRootFolder;
                FName := FName + '1';
                Inc(DelCount);
              end
              else
              begin
                ResCode := 2;
                N_Dump1Str( '3ClearFS>> Folder Deletion fails >> ' + FName +
                            ':'#13#10 + SLU.Text);
              end;
            end; // if DirectoryExists then
          end   // Delete Folder (3DImg)
          else
          begin // Process File

            if not FileExists( FName ) then
            begin
              Inc(DelCount);
              N_Dump1Str( '3ClearFS>> File is absent >> ' + FName );
            end
            else
            begin
              if K_StrStartsWith( SlidesMediaRootFolder, FName) then
              begin
                RFBPath := SlidesMediaRootFolder;
                CFBPath := K_VideoFolder;
              end
              else
              begin
                RFBPath := SlidesImgRootFolder;
                CFBPath := K_ImgFolder;
              end;

              if K_DeleteFile( FName,[K_dofDeleteReadOnly]) then
              begin
                Inc(DelCount);
                N_Dump1Str( '3ClearFS>> File is deleted >> ' + FName );
              end
              else
                N_Dump1Str( '3ClearFS>> File Deletion fails >> ' + FName );
            end; // if FileExists then
          end; // Delete File

          if ResCode = 0 then
            EDARemovePathFolders0(FName, RFBPath);

          if not SaveClearFSStateToFile( ) then
            N_Dump1Str( '3ClearFS>> Couldn''t rewrite cur info file ' );

        end; // for i := 0 to HighI do

        if AllCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / AllCount);
//          PBProgress.Position := Round(1000 * (ProcCount + ShiftCount - SkipCount) / AllCount);

        LbEDDelCount.Text := format( '%d (%d files processing fails)', [ProcCount,ProcCount - DelCount] );
//        LbEDDelCount.Text := format( '%d (%d files processing fails)', [ProcCount + ShiftCount - SkipCount,ProcCount + ShiftCount - DelCount - SkipCount] );
        LbEDDelCount.Refresh();

//        sleep(1000);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Delete Loop
   //////////////////////////////////////
      end; // while TRUE do // Slides Delete Loop

AllProcessed:
      if AllCount > 0 then
        PBProgress.Position := Round(1000 * ProcCount / AllCount);
//        PBProgress.Position := Round(1000 * (ProcCount + ShiftCount - SkipCount) / AllCount);
      LbEDDelCount.Text := format( '%d (%d processing fails)', [ProcCount ,ProcCount - DelCount] );
//      LbEDDelCount.Text := format( '%d (%d processing fails)', [ProcCount + ShiftCount - SkipCount,ProcCount + ShiftCount - SkipCount - DelCount] );
      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;
      K_DeleteFile( FilesListFName  + 'Counters.dat'  );

FinExit:
      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := 'Files storage clearing is %s. %d of %d file(s) or 3D folder(s) were processed, %d file(s) or 3D folder(s) processing fails.';

//      K_CMShowMessageDlg( format( WText, [ResText, ProcCount + ShiftCount - SkipCount, AllCount,
//                                  ProcCount + ShiftCount - SkipCount - DelCount] ), mtInformation );
      K_CMShowMessageDlg( format( WText, [ResText, ProcCount , AllCount,
                                          ProcCount - DelCount] ), mtInformation );
      Close();

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMFSClear.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMFSClear.BtStartClick


procedure TK_FormCMUTLoadDBData3FSClear.GetNextFilesList;
begin
  Dec(FilesListNum);
  FilesListCurFName := '';
  if FilesListNum < 0 then Exit;
  if FilesListNum > 0 then
    FilesListCurFName := FilesListFName + IntToStr( FilesListNum )
  else
    FilesListCurFName := FilesListFName;
  FilesListCurFName := FilesListCurFName + '.txt';
end; // procedure TK_FormCMUTLoadDBData3FSClear.GetNextFilesList

function TK_FormCMUTLoadDBData3FSClear.SaveClearFSStateToFile: Boolean;
begin
  Result := K_VFSaveIntDataToTextFile( FilesListFName + 'Counters.dat', K_CMEDAccess.TmpStrings,
         [ProcCount, DelCount] );
end; // function TK_FormCMUTLoadDBData3FSClear.SaveClearFSStateToFile

end.
