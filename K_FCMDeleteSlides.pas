unit K_FCMDeleteSlides;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types, N_FNameFr;

type
  TK_FormCMDeleteSlides = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    FileNameFrame: TN_FileNameFrame;
    LbEDDelCount: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    AllCount,
    ProcCount,
    DelCount : Integer;
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;
    SL, SLU : TStringList;
    procedure OnFileChange();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMDeleteSlides: TK_FormCMDeleteSlides;


implementation

{$R *.dfm}

uses DB, Math,
  K_CM0, K_Script1, {K_FEText,}
  N_Lib0, N_Lib1, N_ClassRef, K_CML1F;

const SlidePortionCount = 15;

//****************************************** TK_FormCMDeleteSlides.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMDeleteSlides.FormShow(Sender: TObject);
begin
  inherited;

  LbEDBMediaCount.Text := '0';
  LbEDProcCount.Text := '0';
  PBProgress.Max := 1000;
  PBProgress.Position := 0;

  BtStart.Enabled := FALSE;
  BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

  SLU := TStringList.Create;
  SLU.Assign(K_CMEDAccess.UndeletedFileNames.SL);
  K_CMEDAccess.UndeletedFileNames.SL.Clear;

  SL := TStringList.Create;

  FileNameFrame.AddFileNameToTop( FileNameFrame.mbFileName.Text ); // to set correct OnChange call while manual file name change

  FileNameFrame.OnChange := OnFileChange;
  OnFileChange();

  SavedCursor := Screen.Cursor;

end; // TK_FormCMDeleteSlides.FormShow

//************************************ TK_FormCMDeleteSlides.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMDeleteSlides.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
  if not CanClose then
  begin
    CanClose := mrYes = K_CMShowMessageDlg(
         'Do you really want to break deleting?',
                                         mtConfirmation );
    if not CanClose then Exit;
    N_Dump1Str( 'DeleteSlides>> break by user' );
  end;

  SL.Free;

  K_CMEDAccess.UndeletedFileNames.SL.Assign(SLU);
  SLU.Free ;

end; // TK_FormCMDeleteSlides.FormCloseQuery

//************************************** TK_FormCMDeleteSlides.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMDeleteSlides.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError );
var
  i, n : Integer;
  WText, ResText : string;
  SQLStr : string;
  Slides : TN_UDCMSArray;
  SaveGAMode : Boolean;

label FinExit;

begin

// Process Slides Loop
  N_Dump1Str( 'DeleteSlides>> Loop ' + BtStart.Caption   );
  SetLength( Slides, SlidePortionCount );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
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
        end;

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtClose.Enabled := FALSE;
//          ChangeFSizeInfoFlag := FALSE;
      end; // End of Start Init (not Continue)

      Screen.Cursor := crHourglass;

      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Slides Files Check Loop
     //

      while TRUE do // Slides Delete Loop
      begin
        //////////////////////////////////////
        // Prepare Slides to delete portion SQL

        n := 0;
        SQLStr := '';
        while (n < Length(Slides)) and (SL.Count > 0) do
        begin
          if n > 0 then
            SQLStr := SQLStr + ' or ';
          SQLStr := SQLStr + K_CMENDBSTFSlideID + ' = ' + SL[0];
          SL.Delete(0);
          Inc(n);
        end;
        if n = 0 then break;

        N_Dump2Str( format( 'DeleteSlides>> portion src count=%d %s', [n,SQLStr] ) );

        //////////////////////////////////////
        // Select Slides portion to delete
        //
        SQL.Text := 'select ' +
                    K_CMENDBSTFSlideID   + ',' +    // 0
                    K_CMENDBSTFPatID     + ',' +    // 1
                    K_CMENDBSTFSlideDTCr + ',' +    // 2
                    K_CMENDBSTFSlideSysInfo + ',' + // 3
                    K_CMENDBSTFSlideStudyItem +     // 4
                    ' from ' + K_CMENDBSlidesTable +
                    ' where ' + SQLStr;

        Filtered := false;
        Open;

        if RecordCount > 0 then
        begin
          First();
          i := 0;
          SQLStr := '';
          while not Eof do
          begin
            if FieldList[4].AsInteger = 0 then
            begin // not study and not study item
              Slides[i] := TN_UDCMSlide( K_CreateUDByRTypeName('TN_CMSlide', 1,
                                         N_UDCMSlideCI) );
              with Slides[i], P^ do
              begin
                ObjName := FieldList[0].AsString;
                SQLStr := SQLStr + ObjName + ' ';
                CMSPatID := FieldList[1].AsInteger;
                CMSDTCreated := TDateTimeField(FieldList[2]).Value;
                K_CMEDAGetSlideSysFieldsData( EDAGetStringFieldValue(FieldList[3]), @CMSDB);
              end;
              Inc(i);
            end;
            Next;
          end; // if RecordCount > 0 then

          if i > 0 then
          begin
          // Delete Slides
            N_Dump2Str( format( 'DeleteSlides>> portion sel count=%d %s', [i,SQLStr] ) );
            SaveGAMode := K_CMGAModeFlag;
            K_CMGAModeFlag := TRUE;
            GUISilentFlag := TRUE;
            K_CMSlidesDelete( @Slides[0], i, FALSE, TRUE );
            GUISilentFlag := FALSE;
            K_CMGAModeFlag := SaveGAMode;
            N_Dump2Str( format( 'DeleteSlides>> del count=%d', [LockResCount] ) );
            Inc(DelCount,LockResCount); // Increment Deleted Count
            LockResCount := 0;
          end; // if i > 0 then

        end; // if RecordCount > 0 then

        Close();

        ProcCount := ProcCount + n;

        if AllCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / AllCount);
        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();
        LbEDDelCount.Text := format( '%d (%d files were not deleted)', [DelCount,K_CMEDAccess.UndeletedFileNames.SL.Count] );
        LbEDDelCount.Refresh();

//        sleep(1000);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Delete Loop
   //////////////////////////////////////
      end; // while TRUE do // Slides Delete Loop


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

      WText := 'Media objects deleting is %s. %d of %d object(s) were processed, %d object(s) were deleted (%d file(s) were not deleted).';

      K_CMShowMessageDlg( format( WText, [ResText, ProcCount, AllCount, DelCount,
                          K_CMEDAccess.UndeletedFileNames.SL.Count] ), mtInformation );
      Close();

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMDeleteSlides.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMDeleteSlides.BtStartClick

//************************************** TK_FormCMDeleteSlides.OnPathChange ***
// Rebuild View after File Change
//
procedure TK_FormCMDeleteSlides.OnFileChange();
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
  N_Dump1Str( format( 'DeleteSlides>> IDs from file >> %s', [FName] ) );

  BtStart.Enabled := TRUE;
end; // TK_FormCMDeleteSlides.OnFileChange

//********************************** TK_FormCMDeleteSlides.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMDeleteSlides.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'DeleteSlidesHistory', FileNameFrame.mbFileName );
end; // end of procedure TK_FormCMDeleteSlides.CurStateToMemIni

//********************************** TK_FormCMDeleteSlides.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormCMDeleteSlides.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'DeleteSlidesHistory', FileNameFrame.mbFileName );
end; // end of procedure TK_FormCMDeleteSlides.MemIniToCurState

end.
