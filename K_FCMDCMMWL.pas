unit K_FCMDCMMWL;

// 01.09.2020 MWL release, grid sizing modified

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs, ShlObj, ComCtrls,
  Grids,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF;
type
  TK_FormCMDCMMWL = class(TN_BaseForm)
    bnSearch:     TButton;
    StringGrid1:  TStringGrid;
    DateTimePicker1: TDateTimePicker;
    edPhys:       TEdit;
    ComboBox1:    TComboBox;
    edPatID:      TEdit;
    edPatName:    TEdit;
    Label1:       TLabel;
    Label2:       TLabel;
    Label3:       TLabel;
    Label4:       TLabel;
    bnOK:         TButton;
    DateTimePicker2: TDateTimePicker;
    CheckBox1:    TCheckBox;
    bnClear:      TButton;
    GroupBox1:    TGroupBox;
    Label5:       TLabel;
    Label6:       TLabel;
    Label7:       TLabel;
    Label8:       TLabel;
    StateShape:   TShape;
    LbServerPort: TLabel;
    LbServerName: TLabel;
    LbServerIP:   TLabel;
    LbAppEntity:  TLabel;
    GroupBox2:    TGroupBox;
    StatusBar1:   TStatusBar;
    Label9:       TLabel;
    procedure bnSearchClick   ( Sender: TObject );
    procedure FormShow        ( Sender: TObject );
    procedure CheckBox1Click  ( Sender: TObject );
    procedure bnClearClick    ( Sender: TObject );
    procedure StringGrid1Click( Sender: TObject );
  private
    { Private declarations }
    SavedCursor:             TCursor;
    DCMServerPort:           Integer;
    ServerConnectionIsDone:  Boolean;
    procedure ShowDICOMServerState;
  public
    { Public declarations }
  end;

implementation

uses
  K_CMDCMGLibW, N_Lib0, K_CMDCM, K_FCMDCMSetup;

{$R *.dfm}

//************************************ TK_FormCMDCMMWL.ShowDICOMServerState ***
// Server State painting
//
procedure TK_FormCMDCMMWL.ShowDICOMServerState;
begin
  if ServerConnectionIsDone then
  begin
    StateShape.Pen.Color   := clGreen;
    StateShape.Pen.Color   := clLime;
    StateShape.Pen.Color   := clOlive;
    StateShape.Brush.Color := clGreen;
  end
  else
  begin
    StateShape.Pen.Color   := clGray;
    StateShape.Brush.Color := clGray;
  end;
end; // procedure TK_FormCMDCMMWL.ShowDICOMServerState

//**************************************** TK_FormCMDCMMWL.StringGrid1Click ***
// Click at StringGrid handler, saving Data stored in a cell
//
//     Parameters
// Sender - Event Sender
//
procedure TK_FormCMDCMMWL.StringGrid1Click( Sender: TObject );
begin
  inherited;

  // save text from the checked cell
  K_PutTextToClipboard( StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] );

  // operation info for user
  case StringGrid1.Col of
  0: StatusBar1.Panels.Items[0].Text := 'Patient Name saved to Clipboard';
  1: StatusBar1.Panels.Items[0].Text := 'Patient ID saved to Clipboard';
  2: StatusBar1.Panels.Items[0].Text := 'Patient Sex saved to Clipboard';
  3: StatusBar1.Panels.Items[0].Text := 'Patient DOB saved to Clipboard';
  4: StatusBar1.Panels.Items[0].Text := 'Study UID saved to Clipboard';
  5: StatusBar1.Panels.Items[0].Text := 'Requested Procedure ID saved to Clipboard';
  6: StatusBar1.Panels.Items[0].Text := 'Requested Procedure Description saved to Clipboard';
  7: StatusBar1.Panels.Items[0].Text := 'Modality saved to Clipboard';
  8: StatusBar1.Panels.Items[0].Text := 'Scheduled Procedure Date and Time saved to Clipboard';
  9: StatusBar1.Panels.Items[0].Text := 'Station AET saved to Clipboard';
  10: StatusBar1.Panels.Items[0].Text := 'Performing Physician saved to Clipboard';
  end;
end; // procedure TK_FormCMDCMMWL.StringGrid1Click

//******************************************** TK_FormCMDCMMWL.bnClearClick ***
// Clear button OnClick handler
//
//     Parameters
// Sender - Event Sender
//
procedure TK_FormCMDCMMWL.bnClearClick( Sender: TObject );
begin
  edPhys.Text := '';
  edPatID.Text := '';
  edPatName.Text := '';
end; // procedure TK_FormCMDCMMWL.bnClearClick

//******************************************* TK_FormCMDCMMWL.bnSearchClick ***
// Search button OnClick handler, searching for MWL data
//
//     Parameters
// Sender - Event Sender
//
procedure TK_FormCMDCMMWL.bnSearchClick( Sender: TObject );
var
  IP, scuAet, scpAet:                                   PWideChar;
  buffer:                                               array[0..1023] of WideChar;
  Port, numResult, i, sz, isNull, buflength:            Integer;
  hSrv, inst, Ptr1, Ptr2, Ptr3, Ptr4, Ptr5, Ptr6, Ptr7: PWideChar;
  ret:                                                  Word;
  TempStr:                                              string;
  fs:       TFormatSettings;
  TempTime: TDateTime;

  procedure AutoSizeGridColumn(Grid: TStringGrid; column, min, max: Integer);
    { Set for max and min some minimal/maximial Values}
    { Bei max and min kann eine Minimal- resp. Maximalbreite angegeben werden}
  var
    i: Integer;
    temp: Integer;
    tempmax: Integer;
  begin
    tempmax := 0;
    for i := 0 to (Grid.RowCount - 1) do
    begin
      temp := Grid.Canvas.TextWidth(Grid.cells[column, i]);
      if temp > tempmax then tempmax := temp;
      if tempmax > max then
      begin
        tempmax := max;
        break;
      end;
    end;
    if tempmax < min then tempmax := min;
    Grid.ColWidths[column] := tempmax + Grid.GridLineWidth + 9;
  end;
begin
  Screen.Cursor := crHourGlass;
  numResult := 0; // no records yet

  try

    N_Dump1Str( 'Start MWL' );

    IP     := @N_StringToWide( N_MemIniToString( 'CMS_DCMMWLSettings', 'IP', '' ) )[1];
    Port   := StrToIntDef(     N_MemIniToString( 'CMS_DCMMWLSettings', 'Port', '' ), 0 );
    scpAet := @N_StringToWide( N_MemIniToString( 'CMS_DCMMWLSettings', 'Name', ''  ) )[1];
    scuAet := @N_StringToWide( K_CMDCMSetupCMSuiteAetScu() )[1];

    hSrv := K_DCMGLibW.DLConnectMwlScp(ip, port, scpAet, scuAet);

    if hSrv <> Nil then
    begin
      N_Dump1Str( 'Connect succesfull' );

      if ComboBox1.Text <> 'Any' then
        Ptr1 := @N_StringToWide(ComboBox1.Text)[1]
      else
        Ptr1 := ''; // any

     if CheckBox1.Checked then // date is not used
       Ptr2 := ''
     else // date is used
     begin
       DateTimeToString( TempStr, 'yyyymmdd', DateTimePicker1.Date );
       N_Dump1Str( 'Date entered: '+TempStr );
       Ptr2 := @N_StringToWide(TempStr)[1];
     end;

     if CheckBox1.Checked then // time is not used
       Ptr3 := ''
     else // time is used
     begin
       DateTimeToString(TempStr, 'hhmm', DateTimePicker2.Time);
       N_Dump1Str('Time entered: ' + TempStr);
       Ptr3 := @N_StringToWide(TempStr)[1];
     end;

// Needed pointer value is already defined in scuAet
//     Ptr4 := @N_StringToWide( N_MemIniToString( 'CMS_DCMQRSettings', 'AETSCU', '' ) )[1];
     Ptr4 := scuAet;
     //***** physician and patient details

     if edPhys.Text <> '' then
       Ptr5 := @N_StringToWide(edPhys.Text)[1]
     else
       Ptr5 := '';

     if edPatID.Text <> '' then
       Ptr6 := @N_StringToWide(edPatID.Text)[1]
     else
       Ptr6 := '';

     if edPatName.Text <> '' then
       Ptr7 := @N_StringToWide(edPatName.Text)[1]
     else
       Ptr7 := '';

     // search
     ret := K_DCMGLibW.DLFindMwl(hSrv, Ptr1, Ptr2, Ptr3, Ptr4, Ptr5, Ptr6, Ptr7);
     if ret <> 0 then
     begin
       // error
       K_DCMGLibW.DLGetSrvLastErrorInfo(hSrv, PWideChar(@buffer[0]), @sz);
       N_Dump1Str( 'MWL Error: ' + buffer );
       StatusBar1.Panels.Items[0].Text := N_WideToString(buffer);
     end
     else // found
     begin
       N_Dump1Str( 'Found mwl' );

       numResult := K_DCMGLibW.DLGetMwlResultCount(hSrv); // result count
       StringGrid1.RowCount := numResult+1; // fitting a grid

       // ***** filling a grid
       for i := 0 to numResult-1 do
       begin

         inst := K_DCMGLibW.DLGetMwlResultObject(hSrv, i);
         buflength := sizeof(buffer)-sizeof(buffer[0]);
         sz := buflength;

         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
			   K_DCMGLibW.DLGetValueString(inst, K_CMDCMTPatientsName,
                                           PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[0,i+1] := N_WideToString(buffer); // patient name

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
	       K_DCMGLibW.DLGetValueString(inst, K_CMDCMTPatientID, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[1,i+1] := N_WideToString(buffer); // patient id

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
	       K_DCMGLibW.DLGetValueString(inst, K_CMDCMTPatientsSex, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[2,i+1] := N_WideToString(buffer); // patient sex

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetValueString(inst, K_CMDCMTPatientsBirthDate, PWideChar(@buffer[0]), @sz, @isNull);

         // convert date to StrToDateTime format
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
         fs := TFormatSettings.Create;
{$ELSE}         // Delphi 7 or Delphi 2010
         GetLocaleFormatSettings( GetUserDefaultLCID(), fs );
{$IFEND CompilerVersion >= 26.0}
         fs.DateSeparator := '.';
         fs.ShortDateFormat := 'yyyy.mm.dd';
         fs.TimeSeparator := ':';
         fs.ShortTimeFormat := 'hh:mm';
         fs.LongTimeFormat := 'hh:mm:ss';

         TempStr := N_WideToString(buffer);
         insert('.', TempStr, 5);
         insert('.', TempStr, 8);
         TempTime := StrToDateTime(N_WideToString(TempStr), fs);

         // convert to an output format
         fs.DateSeparator := '.';
         fs.ShortDateFormat := 'dd.mm.yyyy';
         fs.TimeSeparator := ':';
         fs.ShortTimeFormat := 'hh:mm';
         fs.LongTimeFormat := 'hh:mm:ss';

         StringGrid1.Cells[3,i+1] := DateTimeToStr(TempTime, fs); // birthdate

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetValueString(inst, K_CMDCMTStudyInstanceUid, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[4,i+1] := N_WideToString(buffer); // StudyInstanceUid

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetValueString(inst, K_CMDCMTRequestedProcedureId, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[5,i+1] := N_WideToString(buffer); // RequestedProcedureId

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetValueString(inst, K_CMDCMTRequestedProcedureDescription, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[6,i+1] := N_WideToString(buffer); // RequestedProcedureDescription

         sz := buflength;
         N_Dump1Str('Before GetValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetSequenceItemTagValue(inst, K_CMDCMTScheduledProcedureStepSequence, 0, K_CMDCMTModality, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[7,i+1] := N_WideToString(buffer); // modality

         sz := buflength;
         N_Dump1Str('Before GetSequenceItemTagValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetSequenceItemTagValue(inst, K_CMDCMTScheduledProcedureStepSequence, 0, K_CMDCMTScheduledProcedureStepStartDate, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[8,i+1] := N_WideToString(buffer); // ScheduledProcedureStepStartDate

         sz := buflength;
         N_Dump1Str('Before GetSequenceItemTagValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetSequenceItemTagValue(inst, K_CMDCMTScheduledProcedureStepSequence, 0, K_CMDCMTScheduledProcedureStepStartTime, PWideChar(@buffer[0]), @sz, @isNull);

         // convert date to StrToDateTime format
         fs.DateSeparator := '.';
         fs.ShortDateFormat := 'yyyy.mm.dd';
         fs.TimeSeparator := ':';
         fs.ShortTimeFormat := 'hh:mm';
         fs.LongTimeFormat := 'hh:mm:ss';

         StringGrid1.Cells[8,i+1] := StringGrid1.Cells[8,i+1] + ' ' + N_WideToString(buffer); // ScheduledProcedureStepStartTime

         TempStr := StringGrid1.Cells[8,i+1];
         insert('.', TempStr, 5);
         insert('.', TempStr, 8);
         insert(':', TempStr, 14);
         TempTime := StrToDateTime(N_WideToString(TempStr), fs);

         // convert to an output format
         fs.DateSeparator := '.';
         fs.ShortDateFormat := 'dd.mm.yyyy';
         fs.TimeSeparator := ':';
         fs.ShortTimeFormat := 'hh:mm';
         fs.LongTimeFormat := 'hh:mm:ss';

         StringGrid1.Cells[8,i+1] := DateTimeToStr(TempTime, fs);

         sz := buflength;
         N_Dump1Str('Before GetSequenceItemTagValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetSequenceItemTagValue(inst, K_CMDCMTScheduledProcedureStepSequence, 0, K_CMDCMTScheduledStationAETitle, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[9,i+1] := N_WideToString(buffer); // ScheduledStationAETitle

         sz := buflength;
         N_Dump1Str('Before GetSequenceItemTagValue, sz = '+IntToStr(sz));
         K_DCMGLibW.DLGetSequenceItemTagValue(inst, K_CMDCMTScheduledProcedureStepSequence, 0, K_CMDCMTScheduledPerformingPhysiciansName, PWideChar(@buffer[0]), @sz, @isNull);

         StringGrid1.Cells[10,i+1] := N_WideToString(buffer); // ScheduledPerformingPhysiciansName

      end;
    end;

    K_DCMGLibW.DLCloseConnection(hSrv);
		K_DCMGLibW.DLDeleteSrvObject(hSrv);

  end
  else
  begin
    N_Dump1Str( 'MWL, No Connection' );
    StatusBar1.Panels.Items[0].Text := 'Couldn''t Connect';
  end;
    N_Dump1Str( 'Stop MWL' );
    StatusBar1.Panels.Items[0].Text := 'Successful, '+IntToStr(numResult)+' found';

  except
    on E: Exception do
    begin
      N_Dump1Str( E.ClassName + ': ' + E.Message );
    end;
  end;

  // autosizing
  for i := 0 to StringGrid1.ColCount-1 do
    AutoSizeGridColumn(StringGrid1, i, 10, 20*(StringGrid1.Canvas.TextWidth('a')));

  Screen.Cursor := crDefault;
end; // procedure TK_FormCMDCMMWL.bnSearchClick

//****************************************** TK_FormCMDCMMWL.CheckBox1Click ***
// "Any date" CheckBox OnClick handler
//
//     Parameters
// Sender - Event Sender
//
procedure TK_FormCMDCMMWL.CheckBox1Click( Sender: TObject );
begin
  if CheckBox1.Checked then // any date and time
  begin
    DateTimePicker1.Enabled := False;
    DateTimePicker2.Enabled := False;
  end
  else // date is used
  begin
    DateTimePicker1.Enabled := True;
    DateTimePicker2.Enabled := True;
  end;
end; // procedure TK_FormCMDCMMWL.CheckBox1Click

//************************************************ TK_FormCMDCMMWL.FormShow ***
// FormShow handler
//
//     Parameters
// Sender - Event Sender
//
procedure TK_FormCMDCMMWL.FormShow( Sender: TObject );
var
  i: Integer;

  procedure AutoSizeGridColumn(Grid: TStringGrid; column, min, max: Integer);
    { Set for max and min some minimal/maximial Values}
    { Bei max and min kann eine Minimal- resp. Maximalbreite angegeben werden}
  var
    i: Integer;
    temp: Integer;
    tempmax: Integer;
  begin
    tempmax := 0;
    for i := 0 to (Grid.RowCount - 1) do
    begin
      temp := Grid.Canvas.TextWidth(Grid.cells[column, i]);
      if temp > tempmax then tempmax := temp;
      if tempmax > max then
      begin
        tempmax := max;
        break;
      end;
    end;
    if tempmax < min then tempmax := min;
    Grid.ColWidths[column] := tempmax + Grid.GridLineWidth + 9;
  end;

begin
  N_Dump1Str( 'Before MWL FormShow' );

  K_DCMGLibW.DLInitAll(); // dll init

  LbServerName.Caption := N_MemIniToString( 'CMS_DCMMWLSettings', 'Name', ''  );
  LbServerIP.Caption   := N_MemIniToString( 'CMS_DCMMWLSettings', 'IP', ''  );
  DCMServerPort        := N_MemIniToInt( 'CMS_DCMMWLSettings', 'Port', 0 );
  LbServerPort.Caption := '';
  if DCMServerPort <> 0 then
    LbServerPort.Caption := IntToStr(DCMServerPort);
  LbAppEntity.Caption := K_CMDCMSetupCMSuiteAetScu();//

  N_Dump1Str( format( 'TK_FormCMDCMMWL.FormShow MWL settings >> Name=%s IP=%s Port=%s AE=%s',
                [LbServerName.Caption, LbServerIP.Caption, LbServerPort.Caption,
                                                       LbAppEntity.Caption] ) );

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  ServerConnectionIsDone := K_CMDCMServerTestConnection( LbServerIP.Caption,
                     DCMServerPort, LbServerName.Caption, LbAppEntity.Caption, 15, TRUE );
  Screen.Cursor := SavedCursor;

  ShowDICOMServerState();

  bnSearch.Enabled := ServerConnectionIsDone;

  edPhys.Text    := K_CMGetProviderDetails( -1, '(#ProviderSurname#)' );
  edPatID.Text   := K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
  edPatName.Text := K_CMGetPatientDetails( -1, '(#PatientFirstName#)^(#PatientSurname#)' );

  StringGrid1.Cells[0,0] := 'Patient Name';
  StringGrid1.Cells[1,0] := 'Patient ID';
  StringGrid1.Cells[2,0] := 'Patient Sex';
  StringGrid1.Cells[3,0] := 'Patient DOB';
  StringGrid1.Cells[4,0] := 'Study UID';
  StringGrid1.Cells[5,0] := 'Requested Procedure ID';
  StringGrid1.Cells[6,0] := 'Requested Procedure Description';
  StringGrid1.Cells[7,0] := 'Modality';
  StringGrid1.Cells[8,0] := 'Scheduled Procedure Date and Time';
  StringGrid1.Cells[9,0] := 'Station AET';
  StringGrid1.Cells[10,0] := 'Performing Physician';

  // autosizing
  for i := 0 to StringGrid1.ColCount-1 do
    AutoSizeGridColumn(StringGrid1, i, 10, 20*(StringGrid1.Canvas.TextWidth('a')));

  N_Dump1Str( 'After MWL FormShow' );
end; // procedure TK_FormCMDCMMWL.FormShow

end.
