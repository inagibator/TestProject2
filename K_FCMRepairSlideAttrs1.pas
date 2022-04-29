unit K_FCMRepairSlideAttrs1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMRepairSlidesAttrs1 = class(TN_BaseForm)
    LbEDBMediaCount: TLabeledEdit;
    LbEDProcCount: TLabeledEdit;
    BtClose: TButton;
    PBProgress: TProgressBar;
    BtStart: TButton;
    StatusBar: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtStartClick(Sender: TObject);
  private
    { Private declarations }
    AllCount,
    ProcCount,
    RCount : Integer;
    CheckNumSlides : Integer;
    SQLFrom : string;
    SQLWhere : string;
    SavedCursor: TCursor;
    CheckFinishFlag : Boolean;
    procedure ShowString( AInfoString : string );
  public
    { Public declarations }
  end;

var
  K_FormCMRepairSlidesAttrs1: TK_FormCMRepairSlidesAttrs1;

implementation

{$R *.dfm}

uses DB, Math,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  AnsiStrings,
{$IFEND CompilerVersion >= 26.0}
  K_CM0, K_CLib0, K_Script1, {K_FEText,}
  N_Lib0, N_ClassRef, N_CMMain5F, K_CML1F;

//************************************ TK_FormCMRepairSlidesAttrs1.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMRepairSlidesAttrs1.FormShow(Sender: TObject);
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
      SQLFrom := ' from ' + K_CMENDBSlidesTable  + ' where ';

      SQLWhere :=  '';
      if K_CMEDDBVersion >= 24 then
        SQLWhere := K_CMENDBSTFSlideStudyID + ' >= 0';

     //////////////////////////////////////
     // Maintenance Slides Process DB Info
     //
      SQL.Text := 'select Count(*) ' + SQLFrom + SQLWhere;
      Filtered := FALSE;
      Open;

      AllCount := Fields[0].AsInteger;;
      Close();

      LbEDBMediaCount.Text := IntToStr( AllCount );
      LbEDProcCount.Text := '0';
      PBProgress.Max := 1000;
      PBProgress.Position := 0;


      if CheckNumSlides = 0 then
        CheckNumSlides := Min( Round(AllCount/20), 20 );
      if CheckNumSlides = 0 then
        CheckNumSlides := 1;

     BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMResampleLarge.FormShow ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // TK_FormCMResampleLarge.FormShow

//****************************** TK_FormCMRepairSlidesAttrs1.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMRepairSlidesAttrs1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BtStart.Caption <> K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'PAUSE';
  if not CanClose then
  begin

    CanClose := mrYes = K_CMShowMessageDlg(
     'Do you really want to break repair attributes procedure?',
                                         mtConfirmation );
    if not CanClose then Exit;
  end;

  N_Dump1Str( 'DBRepairAttrs>> Break by user' );

end; // TK_FormCMResampleLarge.FormCloseQuery

//******************************** TK_FormCMRepairSlidesAttrs1.BtStartClick ***
//  On Button Start Click Handler
//
procedure TK_FormCMRepairSlidesAttrs1.BtStartClick(Sender: TObject);
type TK_CMICSlideState = set of (K_cmicCurError, K_cmicOrigError, K_cmicVideoError, K_cmicDelError );
var
  i : Integer;
  WText, ResText : string;
  SSysInfo, SMapRoot : AnsiString;
  WPos, WPos1, HPos, HPos1 : Integer;
  DSize: Integer;
  PData: Pointer;

const SpixHeight : AnsiString = ' PixHeight=';

label FinExit;

{}
function AnsiPos(const Substr, S: AnsiString): Integer;
var
  P: PAnsiChar;
begin
  Result := 0;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  P := AnsiStrings.AnsiStrPos(PAnsiChar(S), PAnsiChar(SubStr));
{$ELSE}
  P := AnsiStrPos(PAnsiChar(S), PAnsiChar(SubStr));
{$IFEND CompilerVersion >= 26.0}
  if P <> nil then
    Result := Integer(P) - Integer(PAnsiChar(S)) + 1;
end;
{}
begin

// Process Slides Loop
  N_Dump1Str( 'DBRepairAttrs>> ' + BtStart.Caption   );
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
          CheckFinishFlag := FALSE;
          ProcCount := 0;
          RCount    := 0;
        end;

        BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[2]; //'Pause';
        BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[4]; //'Exit';
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
      N_Dump1Str( format( 'DBRepairAttrs>> Loop >> %d of %d media object(s) is processed.',
                          [ProcCount, AllCount] ) );

      while TRUE do // Slides Check Loop
      begin

        //////////////////////////////////////
        // Prepare Unchecked Slides portion
        //
        SQL.Text := 'select top ' + IntToStr(CheckNumSlides) + ' start at ' + IntToStr(ProcCount + 1) + ' ' +
    K_CMENDBSTFSlideID      + ',' + // 0
    K_CMENDBSTFSlideSysInfo + ',' + // 1
    K_CMENDBSTFSlideMapRoot + ' ' + // 2
    SQLFrom + SQLWhere + ' ORDER BY ' + K_CMENDBSTFSlideID;

        Filtered := false;
        i := 0;
        Open;
        if RecordCount > 0 then
        begin
        // Build Selected Slides Objects
          First();
          while not Eof do
          begin
          {$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010) Types and constants
            SSysInfo := Fields[1].AsAnsiString;
          {$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
            SSysInfo := Fields[1].AsString;
          {$IFEND}

            if (AnsiPos( 'cmsfIsMediaObj', SSysInfo ) = 0) and
               (AnsiPos( 'cmsfIsImg3DObj', SSysInfo ) = 0) then
            begin
            // Get MapRoot Text
              EDAGetBlobFieldValue(CurDSet2, Fields[2], PData, DSize);
              SMapRoot := AnsiString(PAnsiString(PData));

              // Compare  Image Width
              WPos := AnsiPos( 'PixWidth=', SSysInfo ) + 9;

              WPos1 := WPos;
              HPos := AnsiPos( 'SRSize="', SMapRoot ) + 8;
              HPos1 := HPos;
              while (SSysInfo[WPos1] = SMapRoot[HPos1]) and
                    (SMapRoot[HPos1] <> ' ') and
                    (SSysInfo[WPos1] <> ' ') do
              begin
                Inc(WPos1);
                Inc(HPos1);
              end;
//              if SSysInfo[WPos1] <> SMapRoot[HPos1] then
              if SSysInfo[WPos1] <> SMapRoot[HPos1] then
              begin // Repair is needed - Width <-> Height

                // Move Correct Width to SysInfo
                HPos1 := HPos;
                WPos1 := WPos;
                while SMapRoot[HPos1] <> ' ' do
                begin
                  SSysInfo[WPos1] := SMapRoot[HPos1];
                  Inc(HPos1);
                  Inc(WPos1);
                end;

                // Move ' PixHeight=' to SysInfo
                Move( SpixHeight[1], SSysInfo[WPos1], Length(SpixHeight) );
                WPos1 := WPos1 + Length(SpixHeight);

                // Move Correct Height to SysInfo
                Inc(HPos1);
                while SMapRoot[HPos1] <> '"' do
                begin
                  SSysInfo[WPos1] := SMapRoot[HPos1];
                  Inc(HPos1);
                  Inc(WPos1);
                end;

                // Save Repaired SysInfo to DB
                Edit;
                {$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010) Types and constants
                  Fields[1].AsAnsiString := SSysInfo;
                {$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
                  Fields[1].AsString := SSysInfo;
                {$IFEND}
                UpdateBatch();

                Inc(RCount); // Increment Repaired Count
                N_Dump2Str( format( 'DBRepairAttrs>> Obj ID=%d is repaired',
                            [Fields[0].AsInteger] ) );
                ShowString( format(' %d object(s) are repaired', [RCount]) );
              end;
            end; // end of Repair

            Next;
            Inc(i);
          end; // while not Eof do

          Close();
        end
        else
        begin
        // No Slides are Selected - check Loop is finished
          Close();
          Break;
        end;

        ProcCount := ProcCount + i;

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


      BtStart.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[0]; //'Start';
      BtClose.Caption := K_CML1Form.LLLButtonCtrlTexts.Items[3]; //'OK';
      CheckFinishFlag := TRUE;

FinExit:
      ShowString( '' );
      Screen.Cursor := SavedCursor;
      BtClose.Enabled := TRUE;

      if CheckFinishFlag then
        ResText := 'finished'
      else
        ResText := 'stopped';

      WText := 'Attributes repairing is %s. %d of %d object(s) were processed, %d object(s) were repaired.';


      K_CMShowMessageDlg( format( WText, [ResText, ProcCount, AllCount, RCount] ), mtInformation );

    except
      on E: Exception do
      begin
        ExtDataErrorString := 'TK_FormCMResampleLarge.BtStartClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;

  end; //  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do

end; // TK_FormCMResampleLarge.BtStartClick

//********************************** TK_FormCMRepairSlidesAttrs1.ShowString ***
//  Get Common Counters Info
//
procedure TK_FormCMRepairSlidesAttrs1.ShowString( AInfoString: string );
begin
  StatusBar.SimpleText := ' ' + AInfoString;
  StatusBar.Refresh();
end; // TK_FormCMResampleLarge.ShowString;

end.
