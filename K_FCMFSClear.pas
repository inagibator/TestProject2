unit K_FCMFSClear;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_FNameFr;

type
  TK_FormCMFSClear = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    FileNameFrame: TN_FileNameFrame;
    LbEDDelCount: TLabeledEdit;
    ChBMove: TCheckBox;
    LbEdMovePath: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure ChBMoveClick(Sender: TObject);
    procedure LbEdMovePathClick(Sender: TObject);
  private
    { Private declarations }
    AllCount,
    ProcCount,
    DelCount : Integer;
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;
    SL, SLU : TStringList;
    PathToMove : string;
    procedure OnFileChange();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMFSClear: TK_FormCMFSClear;


implementation

{$R *.dfm}

uses DB, Math,
  K_Clib0, K_CM0, K_Script1, {K_FEText,}
  N_Lib0, N_Lib1, N_ClassRef, K_CML1F;


//****************************************** TK_FormCMFSClear.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMFSClear.FormShow(Sender: TObject);
begin
  inherited;

  LbEDBMediaCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;

  BtStart.Enabled := FALSE;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

  SLU := TStringList.Create;

  SL := TStringList.Create;

  FileNameFrame.AddFileNameToTop( FileNameFrame.mbFileName.Text ); // to set correct OnChange call while manual file name change

  FileNameFrame.OnChange := OnFileChange;
  OnFileChange();

  SavedCursor := Screen.Cursor;
end; // TK_FormCMFSClear.FormShow

//************************************ TK_FormCMFSClear.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMFSClear.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg(
         'Do you really want to break clear files storage?',
                                         mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'ClearFS>> break by user' );
  end;

  SL.Free;

  SLU.Free ;

end; // TK_FormCMFSClear.FormCloseQuery

//************************************** TK_FormCMFSClear.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMFSClear.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError );
var
  i, Ind : Integer;
  WText, ResText : string;
  FName : string;
  RFBPath : string;
  CFBPath : string;
  ResCode : Integer;

label FinExit,AllProcessed;

begin

// Process Slides Loop
  N_Dump1Str( 'ClearFS>> Loop ' + BtStart.Caption );

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
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
        begin
          CheckFinishFlag := FALSE;
          OnFileChange();
          DelCount := 0;
          if ChBMove.Checked then
          begin
            if not K_SelectFolder( 'Select folder', '', PathToMove ) or
               (PathToMove = '') then
            begin
              N_Dump1Str( 'ClearFS>> User cancel folder selection' );
              Exit;
            end;
            PathToMove := IncludeTrailingPathDelimiter(PathToMove);
            LbEdMovePath.Text := PathToMove;
            if mrYes <> K_CMShowMessageDlg(
                        'Do you really want to move extra files to ' + PathToMove + '?',
                                           mtConfirmation ) then
            begin
              N_Dump1Str( 'ClearFS>> User cancel files moving' );
              Exit;
            end;
            N_Dump1Str( 'ClearFS>> Move files to ' + PathToMove );
          end
          else
          begin
            if mrYes <> K_CMShowMessageDlg(
                      'Do you really want to delete extra files?',
                                         mtConfirmation ) then
            begin
              N_Dump1Str( 'ClearFS>> User cancel files deletion' );
              Exit;
            end
          end;

        end;

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtClose.Enabled := FALSE;
//          ChangeFSizeInfoFlag := FALSE;
      end; // End of Start Init (not Continue)


     //////////////////////////////////////
     // Slides Files Check Loop
     //
      Screen.Cursor := crHourglass;

      while TRUE do // Slides Delete Loop
      begin
//        Ind := SL.Count - 1;
        for i := 0 to 9 do
        begin
          if SL.Count = 0 then goto AllProcessed;
          Ind := SL.Count - 1;
          FName := SL[Ind];
          SL.Delete(Ind);
          RFBPath := '';
          Inc(ProcCount);
          ResCode := 0;
          if FName[Length(FName)] = '\' then
          begin // Process Folder (3DImg)
            if not DirectoryExists( FName ) then
            begin
              Inc(DelCount);
              Continue;
            end;

            if ChBMove.Checked then
            begin
              CFBPath := PathToMove + K_Img3DFolder +
                Copy( FName, Length(SlidesImg3DRootFolder) + 1, Length(FName) );
              K_ForceDirPath( CFBPath );
              if not K_CopyFolderFiles( FName, CFBPath, '*.*',
                 [K_cffOverwriteNewer,K_cffOverwriteReadOnly] ) then
              begin
                ResCode := 1;
                N_Dump1Str( 'ClearFS>> Folder copy fails >> ' + FName );
              end
              else
                N_Dump1Str( 'ClearFS>> Folder is copied to >> ' + CFBPath );
            end; // if ChBMove.Checked then

            if ResCode = 0 then
            begin
              SLU.Clear;
              K_DeleteFolderFilesEx( FName, SLU, '*.*', [K_dffRecurseSubfolders,K_dffRemoveReadOnly] );
              if SLU.Count = 0 then
              begin
                N_Dump1Str( 'ClearFS>> Folder is deleted >> ' + FName );
                RFBPath := SlidesImg3DRootFolder;
                FName := FName + '1';
                Inc(DelCount);
              end
              else
              begin
                ResCode := 2;
                N_Dump1Str( 'ClearFS>> Folder Deletion fails >> ' + FName +
                            ':'#13#10 + SLU.Text);
              end;
            end; // if ResCode = 0 then
          end   // Delete Folder (3DImg)
          else
          begin // Process File

            if not FileExists( FName ) then
            begin
              Inc(DelCount);
              Continue;
            end;

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

            if ChBMove.Checked then
            begin
              CFBPath := PathToMove + CFBPath +
                             Copy( FName, Length(RFBPath) + 1, Length(FName) );
              ResCode := K_CopyFile( FName, CFBPath, [K_cffOverwriteNewer,K_cffOverwriteReadOnly] );
              if ResCode <> 0 then
                N_Dump1Str( format( 'ClearFS>> File copy fails %d >> %s', [ResCode, FName] ) )
              else
                N_Dump1Str( 'ClearFS>> File is copied to >> ' + CFBPath );
            end;

            if ResCode = 0 then
            begin
              if K_DeleteFile( FName,[K_dofDeleteReadOnly]) then
              begin
                Inc(DelCount);
                N_Dump1Str( 'ClearFS>> File is deleted >> ' + FName );
              end
              else
                N_Dump1Str( 'ClearFS>> File Deletion fails >> ' + FName );
            end; // if ChBMove.Checked then
          end; // Delete File

          if ResCode = 0 then
            EDARemovePathFolders0(FName, RFBPath);

        end; // for i := 0 to 9 do

        if AllCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / AllCount);
        LbEDDelCount.Text := format( '%d (%d files processing fails)', [ProcCount,ProcCount - DelCount] );
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
      LbEDDelCount.Text := format( '%d (%d files processing fails)', [ProcCount,ProcCount - DelCount] );
      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;

FinExit:
      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := 'Files storage clearing is %s. %d of %d files(s) were processed, %d file(s) processing fails.';

      K_CMShowMessageDlg( format( WText, [ResText, ProcCount, AllCount,
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

//************************************** TK_FormCMFSClear.OnPathChange ***
// Rebuild View after File Change
//
procedure TK_FormCMFSClear.OnFileChange();
var
  FName : string;
begin

  BtStart.Enabled := FALSE;
  FName := FileNameFrame.mbFileName.Text;
  if (FName = '') or not FileExists(FName) then
  begin
    if FName <> '' then
      K_CMShowMessageDlg( format('File "%s" is absent',[FName]), mtWarning );
    SL.Clear();
    AllCount := 0;
    ProcCount := 0;
    Exit;
  end;

  SL.LoadFromFile( FName );

  LbEDBMediaCount.Text := IntToStr( SL.Count );
  AllCount := SL.Count;
  ProcCount := 0;

  if SL.Count = 0 then
  begin
    K_CMShowMessageDlg( format('File "%s" is empty',[FName]), mtWarning );
    Exit;
  end;

  BtStart.Enabled := TRUE;
end; // TK_FormCMFSClear.OnFileChange

//********************************** TK_FormCMFSClear.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSClear.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'FSClearHistory', FileNameFrame.mbFileName );
  N_StringToMemIni( Name + 'State', 'PathToMove', PathToMove );
  N_BoolToMemIni( Name + 'State', 'MoveFlag', ChBMove.Checked );
end; // end of procedure TK_FormCMFSClear.CurStateToMemIni

//********************************** TK_FormCMFSClear.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMFSClear.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'FSClearHistory', FileNameFrame.mbFileName );
  PathToMove := N_MemIniToString( Name + 'State', 'PathToMove', '' );
  LbEdMovePath.Text := PathToMove;
  ChBMove.Checked := N_MemIniToBool( Name + 'State', 'MoveFlag', FALSE );
end; // end of procedure TK_FormCMFSClear.MemIniToCurState

procedure TK_FormCMFSClear.ChBMoveClick(Sender: TObject);
begin
  if ChBMove.Checked and (LbEdMovePath.Text = '') then
    K_CMShowMessageDlg( 'Press "Start" button to select the resulting folder for files move', mtWarning );

end;

procedure TK_FormCMFSClear.LbEdMovePathClick(Sender: TObject);
begin
  K_CMShowMessageDlg( 'Resulting folder will be changed on start', mtWarning );
end;

end.
