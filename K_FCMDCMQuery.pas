unit K_FCMDCMQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  N_BaseF, N_Types,
  K_CMDCMDLib;

type
  TK_FormCMDCMQuery = class(TN_BaseForm)
    ListView2: TListView;
    BtRetrieve: TButton;
    BtCancel: TButton;
    BtQuery: TButton;

    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    StateShape: TShape;
    LbServerPort: TLabel;
    LbServerName: TLabel;
    LbServerIP: TLabel;
    LbAppEntity: TLabel;

    GroupBox2: TGroupBox;
    LEdPatSurname: TLabeledEdit;
    LEdPatFirstname: TLabeledEdit;
    LEdPatID: TLabeledEdit;
    LEdStudyID: TLabeledEdit;
    LEdModality: TLabeledEdit;

    LbFrom: TLabel;
    DTPFrom: TDateTimePicker;

    LbTo: TLabel;
    DTPTo: TDateTimePicker;
    BtReset: TButton;
    CmBHistory: TComboBox;
    ScrollBar1: TScrollBar;

    procedure DTPFromChange(Sender: TObject);
    procedure BtQueryClick(Sender: TObject);
    procedure ListView2Click(Sender: TObject);
    procedure BtRetrieveClick(Sender: TObject);
    procedure BtResetClick(Sender: TObject);
  private
    { Private declarations }
    DCMDLib : TK_CMDCMDLib;
    DMCImportedCount : Integer;
    PQueryPatient: TK_PCMDCMQPatient;
    PatCount: Integer;
    //
    PatName : WideString;
    PatID   : AnsiString;
    StudyID : AnsiString;
    Modality: AnsiString;
    DateStart: AnsiString;
    DateFin: AnsiString;
    SavedCursor: TCursor;

    QInds : TN_IArray;
    
  public
    { Public declarations }
  end;

var
  K_FormCMDCMQuery: TK_FormCMDCMQuery;

function K_CMDCMQueryDlg() : Integer;

implementation

{$R *.dfm}

uses DateUtils,
     K_FCMDCMDImport, K_CM0, K_CLib0,
     N_Lib0, N_Lib1, N_ImLib;

function K_CMDCMQueryDlg() : Integer;
var
  DCMServerPort: Integer;
  FDCMDLib : TK_CMDCMDLib;
  ServerConnectionIsDone : Boolean;
begin

  FDCMDLib := TK_CMDCMDLib.Create;

  with TK_FormCMDCMQuery.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbServerName.Caption := N_MemIniToString( 'CMS_DCMQRSettings', 'Name', ''  );
    LbServerIP.Caption := N_MemIniToString( 'CMS_DCMQRSettings', 'IP', ''  );
    DCMServerPort := N_MemIniToInt( 'CMS_DCMQRSettings', 'Port', 0 );
    LbServerPort.Caption := '';
    if DCMServerPort <> 0 then
      LbServerPort.Caption := IntToStr(DCMServerPort);
    LbAppEntity.Caption := K_CMGetDICOMAppEntityName();

    N_Dump1Str( format( 'PACS settings >> Name=%s IP=%s Port=%s AE=%s',
                [LbServerName.Caption, LbServerIP.Caption, LbServerPort.Caption, LbAppEntity.Caption] ) );

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    ServerConnectionIsDone := 0 = FDCMDLib.DDStartQR( LbServerName.Caption, LbServerIP.Caption, DCMServerPort,
                                   LbAppEntity.Caption );
    Screen.Cursor := SavedCursor;
    if ServerConnectionIsDone then
    begin
      StateShape.Pen.Color   := clGreen;
      StateShape.Pen.Color   := clOlive;
      StateShape.Brush.Color := clGreen;
    end
    else
    begin
      StateShape.Pen.Color   := clGray;
      StateShape.Brush.Color := clGray;
    end;

    BtQuery.Enabled := ServerConnectionIsDone;
    DCMDLib := FDCMDLib;

    ListView2.Checkboxes := ServerConnectionIsDone and
                            Assigned( N_ImageLib.ILDCMRetrieve );

    DTPFrom.DateTime := Now();
    DTPTo.DateTime := Now();
    BtRetrieve.Enabled := FALSE;
{
    ListView2.Checkboxes := TRUE;
    ListView2.AllocBy := 3;
    with ListView2.Items.Add(), PQueryPatient^ do
    begin
      Caption := '1251';
      SubItems.Add( 'Smith' );
      SubItems.Add( 'Jone' );
      SubItems.Add( K_DateTimeToStr( EncodeDate(1952, 10, 9), N_WinFormatSettings.ShortDateFormat ) );
      SubItems.Add( 'M' );
      N_Dump2Str( format( '%d DCMQ  >> %s,%s',
                      [0,Caption,SubItems.DelimitedText] ) );
    end;
    with ListView2.Items.Add(), PQueryPatient^ do
    begin
      Caption := '1251';
      SubItems.Add( 'Smith' );
      SubItems.Add( 'Kate' );
      SubItems.Add( K_DateTimeToStr( EncodeDate(1975, 2, 17), N_WinFormatSettings.ShortDateFormat ) );
      SubItems.Add( 'F' );
      N_Dump2Str( format( '%d DCMQ  >> %s,%s',
                      [1,Caption,SubItems.DelimitedText] ) );
    end;
    with ListView2.Items.Add(), PQueryPatient^ do
    begin
      Caption := '1564';
      SubItems.Add( 'Ковалев' );
      SubItems.Add( 'Александр' );
      SubItems.Add( K_DateTimeToStr( EncodeDate(1951, 12, 18), N_WinFormatSettings.ShortDateFormat ) );
      SubItems.Add( 'M' );
      N_Dump2Str( format( '%d DCMQ  >> %s,%s',
                      [2,Caption,SubItems.DelimitedText] ) );
    end;
{}
    DTPFrom.Date := 0;
    DTPFrom.Checked := FALSE;
    DTPFrom.OnChange(DTPFrom);
    DTPTo.Date := 0;
    DTPTo.Checked := FALSE;
    DTPTo.OnChange(DTPTo);
    ShowModal();
    Result := DMCImportedCount;

  end; // with TK_FormCMDCMQuery.Create(Application) do

  FDCMDLib.DDFinishQR();
  FDCMDLib.Free;

end; // function K_CMDCMQueryDlg

//*************************************************** K_CMDCMQueryCheckDate ***
// Check Date text representation
//
//    Parameters
// ADateStr - source Date text representation, on output resulting Date correct
//            text representation
// AYear    - resulting encoded Date Year
// AMonth   - resulting encoded Date Month
// ADay     - resulting encoded Date Day
// Result   - Returns TRUE if source text representation is correct, FALSE
//
function K_CMDCMQueryCheckDate( var ADateStr : string; out AYear, AMonth, ADay : Integer ) : Boolean;
var
  WStr : string;
  SYear, SMonth, SDay : string;
  WW, NYear, NMonth, NDay : Word;
begin
  AYear := 0;
  AMonth := 0;
  ADay := 0;
  Result := FALSE;
  if ADateStr = '' then Exit; // Empty From/To is correct Value
  Result := TRUE;
  WStr := ADateStr;
  SYear := '';
  if Length(WStr) > 4 then
  begin
    SYear := copy( WStr, 1, Length(WStr) - 4 );
    if Length(SYear) > 4 then
    begin
      Result := FALSE;
      SYear := copy( SYear, 1, 4 );
    end;
    WStr := copy( WStr, Length(WStr) - 3, 4 );
  end;

  SMonth := '';
  if Length(WStr) > 2 then
  begin
    SMonth := copy( WStr, 1, Length(WStr) - 2 );
    SDay := copy( WStr, Length(WStr) - 1, 2 );
  end
  else
    SDay := WStr;

  DecodeDateFully( Now(), NYear, NMonth, NDay, WW );

  if SYear = '' then
    AYear := NYear
  else
  begin
    AYear := StrToIntDef( SYear, 0 );
    if Length(SYear) < 4 then
      AYear := 2000 + AYear;
  end;

  if SMonth = '' then
    AMonth := NMonth
  else
  begin
    AMonth := StrToIntDef( SMonth, NMonth );
    if (AMonth > 12) or (AMonth <= 0) then
    begin
      Result := FALSE;
      AMonth := NMonth
    end;
  end;

  ADay := StrToIntDef( SDay, 1 );
  NDay := DaysInAMonth(AYear, AMonth);
  if ADay < 1 then
  begin
    Result := FALSE;
    ADay := 1;
  end
  else
  if ADay > NDay then
  begin
    Result := FALSE;
    ADay := NDay;
  end;
  ADateStr := format('%.4d%.2d%.2d', [AYear, AMonth, ADay] );

end; // function K_CMDCMQueryCheckDate

//***************************************** TK_FormCMDCMQuery.DTPFromChange ***
// DateTimePicker DTPFrom and DTPTo Change event handler
//
procedure TK_FormCMDCMQuery.DTPFromChange(Sender: TObject);
begin
  with TDateTimePicker(Sender) do
  if not Checked then
  begin
//    Date := 0;
    Format := ' ';
    Checked := FALSE;
  end
  else
  begin
    if Date < 1 then
      Date := Now();
    Format := 'dd/MM/yyyy';
  end;

end; // procedure TK_FormCMDCMQuery.DTPFromChange

//****************************************** TK_FormCMDCMQuery.BtQueryClick ***
// Button BtQuery Click event handler
//
procedure TK_FormCMDCMQuery.BtQueryClick(Sender: TObject);
var
  QueryPars: TK_CMDCMQueryPars;
  WStr : string;
  i,j : Integer;
  IYear, IMonth, IDay : Integer;
  QueryIsDone: Boolean;
  SN, FN :string;
  QFirstName : string;
  QSurname, QID, QDOB, QGender : string;

begin
  // Name format <Surname>^<Firstname>^<Middle>^<Title>^<Suffix>
  SN := LEdPatSurname.Text;
  FN := LEdPatFirstname.Text;
  WStr := '';
  if (SN <> '') or (FN <> '') then
  begin
    SetLength( WStr, Length(SN) + Length(FN) + 5 );
    i := 0;
    if SN <> '' then
    begin // Add Sirname
      i := Length(SN);
      move( SN[1], WStr[1], i * SizeOf(Char) );
    end;

    if (i = 0) or (WStr[i] <> '*') then
    begin // Add * to Sirname
      Inc(i);
      WStr[i] := '*';
    end; // Add '*' after to Sirname

    if FN <> '' then
    begin // Add First Name

      WStr[i+1] := '^';
      move( FN[1], WStr[i+2], Length(FN) * SizeOf(Char) );
      i := i + Length(FN) + 1;

      if WStr[i] <> '*' then
      begin // Add '*' after First name
        Inc(i);
        WStr[i] := '*';
      end;
    end; // if FN <> '' then

    SetLength( WStr, i );

  end; // if (SN <> '') or (FN <> '') then

  PatName :=   N_StringToWide( WStr );
  PatID :=     N_StringToAnsi( LEdPatID.Text );
  StudyID :=   N_StringToAnsi( LEdStudyID.Text );
  Modality :=  N_StringToAnsi( LEdModality.Text );

  DateStart := '';
  if DTPFrom.Date > 1 then
    DateStart := N_StringToAnsi( K_DateTimeToStr( DTPFrom.Date, 'yyyyMMdd' ) );
  DateFin := '';
  if DTPTo.Date > 1 then
    DateFin := N_StringToAnsi( K_DateTimeToStr( DTPTo.Date, 'yyyyMMdd' ) );

  N_Dump1Str( format( 'DCMQuery >> ID=%s Name=%s Study=%s Mod=%s S=%s F=%s',
                      [PatID,PatName,StudyID,Modality,DateStart,DateFin] ) );

  ZeroMemory( @QueryPars, SizeOf(QueryPars) );
  if PatName <> '' then
    QueryPars.DQPatNamePattern := @PatName[1];
  if PatID <> '' then
    QueryPars.DQPatIDPattern := @PatID[1];
  if StudyID <> '' then
    QueryPars.DQStudyIDPattern := @StudyID[1];
  if Modality <> '' then
    QueryPars.DQModalityPattern := @Modality[1];
  if DateStart <> '' then
    QueryPars.DQDateStart := @DateStart[1];
  if DateFin <> '' then
    QueryPars.DQDateFin := @DateFin[1];


  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  PatCount := 0;
  QueryIsDone := (DCMDLib.DDQuery( QueryPars, PQueryPatient, PatCount ) = 0) and
                 (PatCount > 0);
  Screen.Cursor := SavedCursor;

// Rebuild Query Patients List
  BtRetrieve.Enabled := FALSE;
  ListView2.Items.BeginUpdate();
  ListView2.Items.Clear();

  if QueryIsDone then
  begin
    SetLength( QInds, PatCount );
    ListView2.AllocBy := PatCount;
    j := 0;
    for i := 0 to PatCount - 1 do
    begin
      with PQueryPatient^ do
      begin
        QID        := N_AnsiToString(DQPatID);
        QSurname   := N_WideToString(DQPatSurname);
        QFirstName := N_WideToString(DQPatFirstName);
        QDOB       := N_AnsiToString(DQPatDOB);
        QGender    := N_AnsiToString(DQPatGender);
{
        // Additional Firstname pattern Check
        if (FN <> '') and (QFirstName <> '') and
             not K_CheckTextPattern( UpperCase(QFirstName), UpperCase(FN) + '*', FALSE ) then
        // Patient Firstname does not match Pattern - do not add patient to ListView
            N_Dump2Str( format( '%d DCMQ skiped by Firstname >> %s,%s,%s,%s,%s,%s',
                          [i, QID, QSurname, QFirstName, N_WideToString(DQPatMiddle),
                           QDOB, QGender] ) )
}
        // Additional Surname and Firstname pattern Check
        if ((SN <> '') AND (SN <> '*') AND
            ((QSurname = '')  OR
            ((QSurname <> '') AND NOT K_CheckTextPattern( UpperCase(QSurname), UpperCase(SN), FALSE ))))
                                      OR
           ((FN <> '') AND (FN <> '*') AND
            ((QFirstName = '') OR
            ((QFirstName <> '') and not K_CheckTextPattern( UpperCase(QFirstName), UpperCase(FN), FALSE )))) then
        // Patient Firstname does not match Surname or FirstName Pattern - do not add patient to ListView
            N_Dump2Str( format( '%d DCMQ skiped >> %s,%s,%s,%s,%s,%s',
                                [i, QID, QSurname, QFirstName, N_WideToString(DQPatMiddle),
                                 QDOB, QGender] ) )
        else
        begin
        // Add Patient to ListView
          QInds[j] := i;
          Inc(j);

          // Fill ListView Item
          with ListView2.Items.Add() do
          begin
            Caption := QID;
            SubItems.Add( QSurname );
            SubItems.Add( QFirstName );
            if QDOB <> '' then
            begin
              WStr := QDOB;
              if not K_CMDCMQueryCheckDate( QDOB, IYear, IMonth, IDay ) then
                N_Dump1Str( format( '!!!PatDOB %s >> %s', [WStr,QDOB] ) );
              QDOB := K_DateTimeToStr( EncodeDate(IYear, IMonth, IDay), N_WinFormatSettings.ShortDateFormat );
            end;
            SubItems.Add( QDOB );
            SubItems.Add( QGender );
            N_Dump2Str( format( '%d DCMQ *added >> %s,%s',
                                [i,Caption,SubItems.DelimitedText] ) );
          end; // with ListView2.Items.Add() do
        end; // Add Patient to ListView
      end; // with PQueryPatient^ do
      Inc(PQueryPatient);
    end; // for i := 0 to PatCount - 1 do // Queried Patients Loop

  end; // if QueryIsDone then

  ListView2.Items.EndUpdate();

end; // procedure TK_FormCMDCMQuery.BtQueryClick

//**************************************** TK_FormCMDCMQuery.ListView2Click ***
// ListView Click event handler
//
procedure TK_FormCMDCMQuery.ListView2Click(Sender: TObject);
var
  i : Integer;
begin
  BtRetrieve.Enabled := FALSE;
  if not ListView2.Checkboxes then Exit;

  for i := 0 to ListView2.Items.Count - 1 do
    if ListView2.Items[i].Checked then
    begin
      BtRetrieve.Enabled := TRUE;
      break;
    end;
end; // procedure TK_FormCMDCMQuery.ListView2Click

//*************************************** TK_FormCMDCMQuery.BtRetrieveClick ***
// Button BtRetrieve OnClick event handler
//
procedure TK_FormCMDCMQuery.BtRetrieveClick(Sender: TObject);
var
  Inds : TN_IArray;
  i, Count : Integer;
  PRPatient : TK_PCMDCMDPatientIn;
  PatRCount : Integer;
  ImpCount : Integer;
  WStr : string;
begin
  SetLength( Inds, ListView2.Items.Count );
  Count := 0;
  for i := 0 to ListView2.Items.Count - 1 do
    if ListView2.Items[i].Checked then
    begin
      Inds[Count] := QInds[i];
      WStr := WStr + ' ' + IntToStr( Inds[Count] );
      Inc(Count);
    end;
 // Call Import Dialog

  N_Dump1Str( format( 'DCMRetrieve >> Inds=%s', [WStr] ) );

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  if (DCMDLib.DDRetrieve( @Inds[0], Count, PRPatient, PatRCount ) = 0) and
                          (PatCount > 0) then
  begin
    Screen.Cursor := SavedCursor;
    ImpCount :=  K_CMDCMSlidesImport( PRPatient, PatRCount, DCMDLib );
    DMCImportedCount := DMCImportedCount + ImpCount;
  end;
  Screen.Cursor := SavedCursor;

end; // procedure TK_FormCMDCMQuery.BtRetrieveClick


//****************************************** TK_FormCMDCMQuery.BtResetClick ***
// Button BtReset OnClick event handler
//
procedure TK_FormCMDCMQuery.BtResetClick(Sender: TObject);
begin
  LEdPatSurname.Text := '';
  LEdPatFirstname.Text := '';;
  LEdPatID.Text := '';
  LEdStudyID.Text := '';
  LEdModality.Text := '';

  DTPFrom.Checked := FALSE;
  DTPFromChange(DTPFrom);

  DTPTo.Checked := FALSE;
  DTPFromChange(DTPTo);

  BtRetrieve.Enabled := FALSE;
  ListView2.Items.BeginUpdate();
  ListView2.Items.Clear();
  ListView2.Items.EndUpdate();

end; // procedure TK_FormCMDCMQuery.BtResetClick

end.
