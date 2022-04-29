unit K_FCMCreateStudyFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMCreateStudyFiles = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    LbEDFilesCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    AllCount,
    ProcCount,
    StudyFileCreateCount : Integer;
    CheckNumSlides : Integer;
    StartMSessionTS : TDateTime;
    SavedCursor: TCursor;
    procedure GetCommonCountersInfo();
  public
    { Public declarations }
    StudyFilesCreationIsFinished : Boolean;
  end;

var
  K_FormCMCreateStudyFiles: TK_FormCMCreateStudyFiles;

function K_CMSCreateStudyFilesDlg() : Boolean;

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CM0, K_CLib0, K_FCMReportShow, K_Script1, {K_FEText,}
  N_ClassRef, N_CMMain5F, K_CML1F;

//************************************************ K_CMSCreateStudyFilesDlg ***
//  Open Study Files Creation Dialog
//
//     Parameters
// Result - Returns TRUE if files were created for all DB studies
//
function K_CMSCreateStudyFilesDlg() : Boolean;
begin
  with TK_FormCMCreateStudyFiles.Create( Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    ShowModal();
    Result := StudyFilesCreationIsFinished;
  end;
end; // function K_CMSCreateStudyFilesDlg

//************************************** TK_FormCMCreateStudyFiles.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMCreateStudyFiles.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;


  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Build Maintenance SQL Conditions
     //


     //////////////////////////////////////
     // Maintenance Common Info
     //
      GetCommonCountersInfo();

      if CheckNumSlides = 0 then
        CheckNumSlides := Min( Round(AllCount/20), 5 );
      if CheckNumSlides = 0 then
        CheckNumSlides := 1;

     //////////////////////////////////////
     // Set Conv PNG context
     //
      if ProcCount > 0 then
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1] //'Resume'
      else
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMCreateStudyFiles.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // TK_FormCMCreateStudyFiles.FormShow

//***************************************** TK_FormCMCreateStudyFiles.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMCreateStudyFiles.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLCreateStudyFiles3.Caption,
//      'Do you really want to break study files creation procedure?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  N_Dump1Str( 'SFCreate>> Break by user' );

end; // TK_FormCMCreateStudyFiles.FormCloseQuery

//***************************************** TK_FormCMCreateStudyFiles.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMCreateStudyFiles.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError,
                                 K_cmicStudyFileAbsent, K_cmicStudyFileCorrupted, K_cmicStudyFileLinkErrors );
var
//  CMSDB  : TN_CMSlideSDBF;   // Slide Fields stored as single DB field
//  ChangeFSizeInfoFlag : Boolean;
  SQLStr, Path1, LPath, {SlideID,} SPatID, FName: string;
  i : Integer;
  PImgData : Pointer;
  Slides : TN_UDCMBSArray;
  LockedSlides : TN_UDCMSArray;
  CStudy : TN_UDCMStudy;
  ResText, FileErrText : string;

label FinExit;

begin

// Process Slides Loop
  N_Dump1Str( 'SFCreate>> ' + BtStart.Caption   );
  LockedSlides := nil; // precaution
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      N_CM_MainForm.CMMFFreeEdFrObjects();
      PImgData := nil;
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit;
//        goto FinExit; ???
      end
      else
      begin
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
        begin
          with CurSQLCommand1 do // Prepare Slides Processed Flags
          begin
          // Clear 00000011 bits
            CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +   // 0xFC
                K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 252;';
            Execute;
          end;

          GetCommonCountersInfo(); // Reset Progress and Counters if START after CONTINUE
          StartMSessionTS := Now();
          StudyFilesCreationIsFinished := FALSE;
          StudyFileCreateCount := 0;
        end;

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtClose.Enabled := FALSE;
        SavedCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;
//          ChangeFSizeInfoFlag := FALSE;
      end;


      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

      ////////////////////////////////////////////////
      //  Studies Check Loop
      //
      while TRUE do //
      begin

        //////////////////////////////////////
        // Prepare Unchecked Studies portion
        //
        SQL.Text := 'select top ' + IntToStr(CheckNumSlides) + ' ' +
          EDAGetSlideSelectFieldsStr( [K_sffAddStudyOnlyFields] ) +
          ' from ' + EDAGetSlideSelectFromStr( ) +
          ' where ' + K_CMENDBSTFSlideStudyID + ' < 0 and '  + K_CMENDBSTFSlideSFlags + ' & 1 = 0';
        Filtered := false;
        Open;
        i := RecordCount;
        if i > 0 then
        begin
        // Build Selected Studies Objects
          SetLength( Slides, i );
          First();
          i := 0;
          while not Eof do
          begin
            Slides[i] := TN_UDCMStudy(K_CreateUDByRTypeName('TN_CMSlide', 1,
                N_UDCMStudyCI));

            EDAStudyGetFields( TN_UDCMStudy(Slides[i]), CurDSet2 );
            Next;
            Inc(i);
          end;
          Close();
        end else
        begin
        // No Studies are Selected - check Loop is finished
          Close();
          Break;
        end;

        //////////////////////////////////////
        //  Lock Studies to prevent deletion
        //
        EDALockSlides( TN_PUDCMSlide(@Slides[0]), i, K_cmlrmCheckFilesLock );
        LockedSlides := Copy(LockResSlides, 0, LockResCount );
        LockResCount := 0;
        //////////////////////////////////////
        //  Check Locked Studies
        //
        for i := 0 to High(LockedSlides) do
        begin
          CStudy := TN_UDCMStudy(LockedSlides[i]);
          with CStudy, P^ do
          begin
            SPatID := IntToStr(CMSPatID);
            LPath := K_CMSlideGetPatientFilesPathSegm( CMSPatID ) +
                                 K_CMSlideGetFileDatePathSegm(CMSDTCreated);

            Path1 := SlidesImgRootFolder + LPath;
            FName := Path1 + K_CMStudyGetFileName(ObjName);

            if not FileExists( FName ) then
            begin
              EDAStudyGetLinksInfoFromDB( ObjName, CurDSet3, SlideStudyInfoUpdateStrings );
              EDAStudySaveAttrsToFile( ObjName, Path1, P(),
                                       CStudy.CMSStudySampleID, CStudy.CMSStudyItemsCount,
                                       SlideStudyInfoUpdateStrings );
              N_Dump2Str( format( 'SFCreate>> File %s is created', [FName] ) );
              Inc(StudyFileCreateCount);
              LbEDFilesCount.Text := IntToStr( StudyFileCreateCount );
              LbEDFilesCount.Refresh();
            end;

            Inc(ProcCount);
            if AllCount > 0 then
              PBProgress.Position := Round(1000 * ProcCount / AllCount);
            LbEDProcCount.Text := IntToStr( ProcCount );
            LbEDProcCount.Refresh();
          end; // with CSlide, P^ do

        end; // for i := 0 to High(LockedSlides) do

      //////////////////////////////////////
      //  Unlock Locked SLides
      //
        EDAUnLockSlides( @LockedSlides[0], Length(LockedSlides), K_cmlrmCheckFilesLock );

      //////////////////////////////////////
      //  Set Checked Flag to Checked SLides
      //
        //  Build Slides List Select Condition
{
        SQLStr := K_CMENDBSTFSlideID + ' = ' + LockedSlides[0].ObjName;
        for i := 1 to High(LockedSlides) do
          SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + LockedSlides[i].ObjName;
}
        EDABuildSelectSQLBySlidesList( TN_PUDCMSlide(LockedSlides), Length(LockedSlides), @SQLStr, nil );

        // Set Slides Processed Flags
        with CurSQLCommand1 do
        begin
          // Set Processed flag 00000001
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
            K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 1' +
            ' where ' + SQLStr;
          Execute;
        end;

        // Delete Slide Objects
        for i := 0 to High(Slides) do
          Slides[i].UDDelete();

//        sleep(500);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Files Check Loop
   //////////////////////////////////////
      end; // while TRUE do // Slides Check Loop

      SlideStudyInfoUpdateStrings.Clear; //!!! 2013-10-16 needed to clear for correct future use


      // Clear Slides Processed Flags 00000001
      with CurSQLCommand1 do
      begin
        CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' + // 0xFE
          K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 254;';
        Execute;
      end;

//      PBProgress.Position := 0;

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      StudyFilesCreationIsFinished := TRUE;

FinExit:
      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;
      EDAFreeBuffer( PImgData );

      if StudyFilesCreationIsFinished then
        ResText := 'finished'
      else
        ResText := 'stopped';

      FileErrText := format( K_CML1Form.LLLCreateStudyFiles2.Caption,
//    ' Study files creation is %s. %d of %d media object(s) were processed, %d study file(s) were created.'
        [ResText, ProcCount, AllCount, StudyFileCreateCount] );


      K_CMShowMessageDlg( FileErrText, mtInformation );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMCreateStudyFiles.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMCreateStudyFiles.BtStartClick

//***************************************** TK_FormCMCreateStudyFiles.GetCommonCountersInfo ***
//  Get Common Counters Info
//
procedure TK_FormCMCreateStudyFiles.GetCommonCountersInfo;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     // Maintenance Studies Process DB Info
     //
      SQL.Text := 'select Count(*), ' + K_CMENDBSTFSlideSFlags + ' & 3' +
      ' from ' + K_CMENDBSlidesTable + ' where ' + K_CMENDBSTFSlideStudyID + ' < 0' +
      ' group by ' + K_CMENDBSTFSlideSFlags + ' & 3;';

// Debug Code to View and Edit SQL
//      N_s := SQL.Text;
//      with TK_FormTextEdit.Create(Application) do
//        EditText( N_s );

      Open;

      ProcCount := 0;
      AllCount := 0;
      while not EOF do
      begin
        AllCount := AllCount + FieldList.Fields[0].AsInteger; // 0 + 1 + 2 + 3
        if FieldList.Fields[1].AsInteger = 1 then // 1
          ProcCount := ProcCount + FieldList.Fields[0].AsInteger;

        Next();
      end;

      Close();

      LbEDBMediaCount.Text := IntToStr( AllCount );
      LbEDProcCount.Text := IntToStr( ProcCount );
      PBProgress.Max := 1000;
      PBProgress.Position := 0;
      if AllCount > 0 then
        PBProgress.Position := Round(1000 * ProcCount / AllCount);


    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMCreateStudyFiles.GetCommonCountersInfo ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;


end; // TK_FormCMCreateStudyFiles.GetCommonCountersInfo;

end.
