unit K_FCMResampleLarge;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMResampleLarge = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    LbEDURCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    ChBOnlyUnresampled: TCheckBox;
    BtStart: TButton;
    BtReport: TButton;
    LbEDLICount: TLabeledEdit;
    StatusBar: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
    procedure BtReportClick(Sender: TObject);
  private
    { Private declarations }
    AllCount,
    ProcCount,
    LCount,
    URCount : Integer;
    ReportSMatr: TN_ASArray;
    ReportCount : Integer;
    CheckNumSlides : Integer;
    StartMSessionTS : TDateTime;
    SQLCondStr : string;
    SQLFrom : string;
    SQLWhere : string;
    SavedCursor: TCursor;
    ReportIsNeededFlag : Boolean;
    CheckFinishFlag : Boolean;
    procedure AddRepInfo( APatientInfo, ASlideInfo, AResampleInfo : string;
                          ACountReportMode : Integer = 0 );
    procedure GetCommonCountersInfo();
    procedure ShowString( AInfoString : string );
  public
    { Public declarations }
  end;

var
  K_FormCMResampleLarge: TK_FormCMResampleLarge;

implementation

{$R *.dfm}

uses DB, GDIPAPI, Math,
  K_CM0, K_CLib0, K_FCMReportShow, K_Script1, {K_FEText,}
  N_Lib0, N_ClassRef, N_CMMain5F, K_CML1F;

//***************************************** TK_FormCMResampleLarge.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMResampleLarge.FormShow(Sender: TObject);
//var
//  SL : TStringList;
begin
  inherited;

  BtReport.Enabled := FALSE;

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Build Maintenance SQL Conditions
     //
      SQLFrom := ' from ' + K_CMENDBSlidesTable  + ' where ';

      SQLWhere :=  K_CMENDBSlidesTable + '.' + K_CMENDBSTFPatID + ' <> ' + IntToStr(CurPatID) + ' and (' +
                   K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideFlags + ' IS NULL   or  ' +
                   K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideFlags + ' <> 2 )';
      if K_CMEDDBVersion >= 24 then
        SQLWhere := SQLWhere +
          ' and ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideStudyID + ' >= 0';

      SQLCondStr := SQLFrom +
          K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideSFlags + ' & 4 = 0 and ' +
          SQLWhere;

     //////////////////////////////////////
     // Resample Common Info
     //
      GetCommonCountersInfo();

//  if CheckNumSlides = 0 then CheckNumSlides := 10;
      if CheckNumSlides = 0 then
        CheckNumSlides := Min( Round(AllCount/20), 5 );
      if CheckNumSlides = 0 then
        CheckNumSlides := 1;

      ChBOnlyUnresampled.Enabled := FALSE;

     //////////////////////////////////////
     // Set Conv PNG context
     //
      if ProcCount > 0 then
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1] //'Resume'
      else
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
        ChBOnlyUnresampled.Enabled := URCount > 0;
        ChBOnlyUnresampled.Checked := ChBOnlyUnresampled.Enabled;
      end;

      AddRepInfo( 'Patient Info', 'Object ID', 'Resample Info' );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMResampleLarge.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // TK_FormCMResampleLarge.FormShow

//*********************************** TK_FormCMResampleLarge.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMResampleLarge.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLResampleLarge2.Caption,
//      'Do you really want to break check image files size procedure?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  if ReportIsNeededFlag and
     ( mrOK = K_CMShowMessageDlg( K_CML1Form.LLLResampleLarge5.Caption,
//       'You have unsaved resample report. Press OK to save report data.',
       mtConfirmation, [mbOK, mbCancel] ) ) then
    BtReportClick(Sender);

  N_Dump1Str( 'DBResample>> Break by user' );

end; // TK_FormCMResampleLarge.FormCloseQuery

//************************************* TK_FormCMResampleLarge.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMResampleLarge.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError );
var
  SQLText : string;
  SQLStrToProcess : string;
  SQLStrToResample : string;
  i, j : Integer;
  SlidesToProcess : TN_UDCMSArray;
  LockedSlides : TN_UDCMSArray;
  SlidesToResample : TN_UDCMSArray;
  CSlide : TN_UDCMSlide;
  WText, ResText, FileErrText : string;
  DUDCount : Integer;

label ContLoop, FinExit;

  ////////////////////////////////
  // Prepare Slides Set SQL Str
  //
  function PrepSlidesSQLStr( APSlide : TN_PUDCMSlide; ANumSLides : Integer; ACheckImgSize : Boolean ) : string;
  var i : Integer;
  begin
    //  Build Slides List Select Condition
    Result := K_CMENDBSTFSlideID + ' = ' + APSlide^.ObjName;
    for i := 1 to ANumSLides - 1 do
    begin
      Inc( APSlide );
      with APSlide^, P()^ do
        if not ACheckImgSize or (CMSDB.PixWidth * CMSDB.PixHeight <= K_CMImgMaxPixelsSize) then
          Result := Result + ' or ' + K_CMENDBSTFSlideID + ' = ' + APSlide.ObjName;
    end;
  end; // function PrepSlidesSQLStr

begin

// Process Slides Loop
  WText := '';
  if ChBOnlyUnresampled.Checked then
    WText := ' Unresampled Only';
  N_Dump1Str( 'DBResample>> ' + BtStart.Caption + WText  );
  LockedSlides := nil; // precaution
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      N_CM_MainForm.CMMFFreeEdFrObjects();
      if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[2] then //'Pause' then
      begin
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[1]; //'Resume';
        Exit; // 
      end
      else
      begin
        if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then //'Start' then
        begin
          with CurSQLCommand1 do // Prepare Slides Processed Flags
          begin

            if ChBOnlyUnresampled.Checked then
            // Set "Processed" flag to all Except Unrecoverd
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
//                K_CMENDBSTFSlideSFlags + ' = ( CASE WHEN (' + K_CMENDBSTFSlideSFlags + ' & 8) = 8 THEN ' +
//                K_CMENDBSTFSlideSFlags + ' & 243 ELSE (' + K_CMENDBSTFSlideSFlags + ' | 12) ^ 8 END );'
                K_CMENDBSTFSlideSFlags + ' = ( CASE WHEN (' + K_CMENDBSTFSlideSFlags + ' & 8) = 8 THEN ' +
                K_CMENDBSTFSlideSFlags + ' & 251 ELSE (' + K_CMENDBSTFSlideSFlags + ' | 12) ^ 8 END );'
            else
            // Clear all control flags
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
                K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 243;';
            Execute;
          end;

          GetCommonCountersInfo(); // Reset Progress and Counters if START after CONTINUE
          ReportCount := 1;
          StartMSessionTS := 0;
          URCount := 0;
          LCount  := 0;
          CheckFinishFlag := FALSE;
          ReportIsNeededFlag := FALSE;
        end;

        if StartMSessionTS = 0 then
          StartMSessionTS := Now();
        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
        BtReport.Enabled := FALSE;
        BtClose.Enabled := FALSE;
        SavedCursor := Screen.Cursor;
        Screen.Cursor := crHourglass;
//          ChangeFSizeInfoFlag := FALSE;
      end; // End of Start Init (not Continue)


      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;

     //////////////////////////////////////
     // Slides Files Check Loop
     //
      N_Dump1Str( format( 'DBResample>> Loop start >> %d of %d media object(s) is processed, %d of %d image(s) were not resampled.',
                          [ProcCount, AllCount, URCount, LCount] ) );

      while TRUE do // Slides Check Loop
      begin

        //////////////////////////////////////
        // Prepare Unchecked Slides portion
        //
        SQLText := 'select top ' + IntToStr(CheckNumSlides) + ' ' +
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideID      + ' as SlideID,' + // 0
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFPatID        + ' as PatID,' +   // 1
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideDTCr    + ' as DTCr,' +    // 2
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideSysInfo + ' as SysInfo,' +  // 3
    K_CMENDBSlidesTable +'.'+ K_CMENDBSTFSlideSFlags  + ' as SFlags';    // 4

        if K_CMEDDBVersion >= 12 then
          SQLText := // 0        1        2        3           4            5        6
          ' select S.SlideID, S.PatID, S.DTCr, S.SysInfo, Q.PatCardNum, Q.PatCapt, S.SFlags' +
          ' from ( (' + SQLText + SQLCondStr + ') S  LEFT OUTER JOIN ('+
          ' select '+
            K_CMENDAHPatID + ' as PatID,' +
            K_CMENDAHPatCN + ' as PatCardNum,' +
            K_CMENDAHPatCapt + ' as PatCapt' +
          ' from ' + K_CMENDBAllHistPatientsTable + ') Q ' +
          ' on S.PatID = Q.PatID )'
        else
          SQLText := SQLText + SQLCondStr;
//        N_s := SQLText;

        Filtered := false;
        SQL.Text := SQLText;
        Open;
        i := RecordCount;
        if i > 0 then
        begin
        // Build Selected Slides Objects
          SetLength( SlidesToProcess, i );
          First();
          i := 0;
          while not Eof do
          begin
            SlidesToProcess[i] := TN_UDCMSlide(K_CreateUDByRTypeName('TN_CMSlide', 1,
                                               N_UDCMSlideCI));
            with SlidesToProcess[i], P^ do
            begin
              ObjName := FieldList[0].AsString;
              CMSPatID := FieldList[1].AsInteger;
              CMSDTCreated := TDateTimeField(FieldList[2]).Value;
              K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[3]), @CMSDB );
              if K_CMEDDBVersion >= 12 then
                ObjAliase := format( '%s [%s]', [FieldList[5].AsString, FieldList[4].AsString] )
              else
                ObjAliase := 'ID=' + FieldList[1].AsString;
              CMSlideMarker := (FieldList[6].AsInteger and 8) <> 0; // Mark Unresampled
            end;
            Next;
            Inc(i);
          end;
          Close();
        end else
        begin
        // No Slides are Selected - check Loop is finished
          Close();
          Break;
        end;


// CMSDB.PixWidth * CMSDB.PixHeight > K_CMImgMaxPixelsSize
        SetLength( SlidesToResample, i );
        j := 0;
        for i := 0 to High(SlidesToProcess) do
        begin
          CSlide := SlidesToProcess[i];
          with CSlide.P^ do
            if (cmsfIsMediaObj in CMSDB.SFlags) or
               (CMSDB.PixWidth * CMSDB.PixHeight <= K_CMImgMaxPixelsSize) then
            begin
              if CSlide.CMSlideMarker then
                Dec(URCount); // Uresampled Slide is already resampled
              Continue;
            end;
          SlidesToResample[j] := CSlide;
          Inc(j);
        end;

        if j = 0 then
          goto ContLoop;

        SetLength( SlidesToResample, j );
        LCount := LCount + j;
        LbEDLICount.Text := IntToStr( LCount );

        ////////////////////////////////////////////////////////////////////
        // Set ResampleFailsFlag (8) flag for all slides needed to resample

        SQLStrToResample := PrepSlidesSQLStr( @SlidesToResample[0], j, FALSE );

        with CurSQLCommand1 do
        begin
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
            K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 8' +
            ' where ' + SQLStrToResample;
          Execute;
        end;

        //////////////////////////////////////
        //  Lock Slides to prevent deletion
        //
        EDALockSlides( @SlidesToResample[0], j, K_cmlrmCheckFilesLock );

        ///////////////////////////////////////////////
        //  Add Report strings about not locked Slides
        //
        for i := 0 to High(SlidesToResample) do
          with SlidesToResample[i], P^ do
            if not (cmsfIsUsed in CMSRFlags) then
              AddRepInfo( ObjAliase, ObjName, 'is deleting by other user', 2 );

        LockedSlides := Copy(LockResSlides, 0, LockResCount );
        URCount := URCount + (j - LockResCount);

        if LockResCount > 0 then
        begin

          //////////////////////////////////////
          //  Resample Slides
          //
          j :=  K_CMSResampleSlides( @LockedSlides[0], LockResCount, ShowString );

          DUDCount := LockResCount - j;
          URCount := URCount + DUDCount;

          /////////////////////////////////////////////////////////////////
          // Clear ResampleFailsFlag (8) for all slides which are realy resampled

          SQLStrToResample := PrepSlidesSQLStr( @LockedSlides[0], j, DUDCount > 0 );
          with CurSQLCommand1 do
          begin
            CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
              K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 247' +
              ' where ' + SQLStrToResample;
            Execute;
          end;

          //////////////////////////////////////
          //  Unlock Locked SLides
          //
          EDAUnLockSlides( @LockedSlides[0], LockResCount, K_cmlrmCheckFilesLock );

          //////////////////////////////////////
          //  Add Report strings about resampling
          //
          for i := 0 to High(LockedSlides) do
          begin
            CSlide := LockedSlides[i];
            with CSlide, P^ do
            begin
              if (CMSDB.PixWidth * CMSDB.PixHeight <= K_CMImgMaxPixelsSize) then
              begin
                AddRepInfo( ObjAliase, ObjName, 'is resampled', 2 );
                if CSlide.CMSlideMarker then
                  Dec(URCount); // Uresampled Slide is resampled
              end
              else
                AddRepInfo( ObjAliase, ObjName, 'resample problems', 2 );
            end;
          end;
        end; // if LockResCount > 0 then

        LockResCount := 0;
        LbEDURCount.Text := IntToStr( URCount );

ContLoop:
        //////////////////////////////////////////////////
        // Set ProcessedFlag (4) for all processed slides

        SQLStrToProcess := PrepSlidesSQLStr( @SlidesToProcess[0], Length(SlidesToProcess), FALSE );

        with CurSQLCommand1 do
        begin
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
            K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' | 4' +
            ' where ' + SQLStrToProcess;
          Execute;
        end;

        // Delete Slide Objects
        for i := 0 to High(SlidesToProcess) do
          SlidesToProcess[i].UDDelete();
        ProcCount := ProcCount + Length(SlidesToProcess);
        if AllCount > 0 then
          PBProgress.Position := Round(1000 * ProcCount / AllCount);
        LbEDProcCount.Text := IntToStr( ProcCount );
        LbEDProcCount.Refresh();

//        sleep(1000);
        Application.ProcessMessages();
        if BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2] then goto FinExit; // Break Files Loop by PAUSE

   //
   // Slides Files Check Loop
   //////////////////////////////////////
      end; // while TRUE do // Slides Check Loop


      // Clear Slides Processed Flags (4)
      with CurSQLCommand1 do
      begin
        CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
          K_CMENDBSTFSlideSFlags + ' = ' + K_CMENDBSTFSlideSFlags + ' & 251;';
        Execute;
      end;

      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;

      ChBOnlyUnresampled.Enabled := URCount > 0;
      ChBOnlyUnresampled.Checked := ChBOnlyUnresampled.Enabled;

FinExit:
      ShowString( '' );
      Screen.Cursor := SavedCursor;
      BtReport.Enabled := ReportIsNeededFlag;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := K_CML1Form.LLLResampleLarge3.Caption;
//        'Check image files size is %s. %d of %d image(s) were processed, %d of %d were resampled.';


      FileErrText := format( WText, [ResText, ProcCount, AllCount, LCount - URCount, LCount] );

      K_CMShowMessageDlg( FileErrText, mtInformation );

      if ReportIsNeededFlag and (ProcCount = AllCount) then
//      (BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0]) then //'Start') then
        BtReportClick(Sender);

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMResampleLarge.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMResampleLarge.BtStartClick

//*************************************** TK_FormCMResampleLarge.AddRepInfo ***
// Add Report Info
//
//     Parameters
// APatientInfo - Patien Report Info
// ASlideInfo   - Slide Report Info
// AResampleInfo   - Error Report Info
// ACountReportMode - Count Report Mode:
//   0 - skip count report lines and skip dump
//   1 - skip count report lines but dump
//   2 - count report and dump
//
procedure TK_FormCMResampleLarge.AddRepInfo( APatientInfo, ASlideInfo, AResampleInfo : string;
                                             ACountReportMode : Integer = 0 );
begin
  if ReportCount >= Length(ReportSMatr) then
    SetLength( ReportSMatr, ReportCount + 100 );

  SetLength( ReportSMatr[ReportCount], 3 );

  ReportSMatr[ReportCount][0] := APatientInfo;
  ReportSMatr[ReportCount][1] := ASlideInfo;
  ReportSMatr[ReportCount][2] := AResampleInfo;

  Inc(ReportCount);

  if ACountReportMode = 0 then Exit;
  N_Dump1Str( 'DBResample>> Report ' + ASlideInfo + ' >> ' + AResampleInfo );
  if ACountReportMode = 1 then Exit;
  ReportIsNeededFlag := TRUE;
end; // TK_FormCMResampleLarge.AddRepInfo

//************************************ TK_FormCMResampleLarge.BtReportClick ***
//  On Button Report Click Handler
//
procedure TK_FormCMResampleLarge.BtReportClick(Sender: TObject);
begin

  with TK_FormCMReportShow.Create(Application) do
  begin
    ReportDataSMatr := Copy( ReportSMatr, 0, ReportCount );
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PrepareRAFrameByDataSMatr( format( K_CML1Form.LLLResampleLarge4.Caption,
    // 'Check image files size, started at %s'
          [K_DateTimeToStr( StartMSessionTS, 'yyyy-mm-dd hh:nn:ss AM/PM' )] ) );
    FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);

    ShowModal;
  end;

  if BtStart.Caption = K_CML1Form.LLLButtonCtrlTexts.Items[0] then // 'Start' then
    ReportIsNeededFlag := FALSE;

end; // TK_FormCMResampleLarge.BtReportClick

//**************************** TK_FormCMResampleLarge.GetCommonCountersInfo ***
//  Get Common Counters Info
//
procedure TK_FormCMResampleLarge.GetCommonCountersInfo;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    try
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;


     //////////////////////////////////////
     // Maintenance Slides Process DB Info
     //
      SQL.Text := 'select Count(*), ' + K_CMENDBSTFSlideSFlags + ' & 12' +
      SQLFrom + SQLWhere +
      ' group by ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFSlideSFlags + ' & 12;';

// Debug Code to View and Edit SQL
//      N_s := SQL.Text;
//      with TK_FormTextEdit.Create(Application) do
//        EditText( N_s );

      Filtered := FALSE;
      Open;

      ProcCount := 0;
      URCount := 0;
      AllCount := 0;

      while not EOF do
      begin
        AllCount := AllCount + FieldList.Fields[0].AsInteger; // 0 + 1 + 2 + 3
        if FieldList.Fields[1].AsInteger = 4 then // 1
          ProcCount := ProcCount + FieldList.Fields[0].AsInteger
        else
        if FieldList.Fields[1].AsInteger = 8 then // 2
          URCount := URCount + FieldList.Fields[0].AsInteger
        else
        if FieldList.Fields[1].AsInteger = 12 then // 3
        begin
          ProcCount := ProcCount + FieldList.Fields[0].AsInteger;
          URCount := URCount + FieldList.Fields[0].AsInteger;
        end;

        Next();
      end;

      Close();

      LbEDBMediaCount.Text := IntToStr( AllCount );
      LbEDProcCount.Text := IntToStr( ProcCount );
      LbEDURCount.Text := IntToStr( URCount );
      LbEDLICount.Text := '0';
      PBProgress.Max := 1000;
      PBProgress.Position := 0;
      if AllCount > 0 then
        PBProgress.Position := Round(1000 * ProcCount / AllCount);


    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMResampleLarge.GetCommonCountersInfo ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;


end; // TK_FormCMResampleLarge.GetCommonCountersInfo;

//*************************************** TK_FormCMResampleLarge.ShowString ***
//  Get Common Counters Info
//
procedure TK_FormCMResampleLarge.ShowString( AInfoString: string );
begin
  StatusBar.SimpleText := ' ' + AInfoString;
  StatusBar.Refresh();
end; // TK_FormCMResampleLarge.ShowString;

end.
