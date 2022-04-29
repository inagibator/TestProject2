unit K_FCMDCMQR;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  K_CMDCMGLibW,
  N_BaseF, N_Types;

type
  TK_FormCMDCMQR = class(TN_BaseForm)
    BtRetrieve: TButton;
    BtCancel: TButton;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    StateShape: TShape;
    LbServerPort: TLabel;
    LbServerName: TLabel;
    LbServerIP: TLabel;
    LbAppEntity: TLabel;
    GroupBox4: TGroupBox;
    LEdPatName: TLabeledEdit;
    LEdPatID: TLabeledEdit;
    BtSelectAllPatients: TButton;
    BtResetPatients: TButton;
    ListView1: TListView;
    GroupBox5: TGroupBox;
    LbStudyDate: TLabel;
    LbFrom: TLabel;
    DTPStFrom: TDateTimePicker;
    DTPStTo: TDateTimePicker;
    LEdANum: TLabeledEdit;
    LbTo: TLabel;
    ListView2: TListView;
    BtQueryStudies: TButton;
    BtResetStudies: TButton;
    GroupBox1: TGroupBox;
    BtQuerySeries: TButton;
    LEdModality: TLabeledEdit;
    ListView3: TListView;
    BtResetSeries: TButton;
    BtQueryPatients: TButton;
    BtSelectAllStudies: TButton;
    BtSelectAllSeries: TButton;

    procedure DTPStFromChange(Sender: TObject);
    procedure BtQueryPatientsClick(Sender: TObject);
    procedure BtQueryStudiesClick(Sender: TObject);
    procedure BtQuerySeriesClick(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ListView2Click(Sender: TObject);
    procedure ListView3Click(Sender: TObject);
    procedure BtRetrieveClick(Sender: TObject);
    procedure BtResetPatientsClick(Sender: TObject);
    procedure BtResetStudiesClick(Sender: TObject);
    procedure BtResetSeriesClick(Sender: TObject);
    procedure BtSelectAllPatientsClick(Sender: TObject);
    procedure BtSelectAllStudiesClick(Sender: TObject);
    procedure BtSelectAllSeriesClick(Sender: TObject);
  private
    { Private declarations }
    DCMServerPort: Integer;
    DCMImportCount : Integer;
    SavedCursor: TCursor;

    ServerConnectionAttrsIsOK : Boolean;
    ServerConnectionIsDone : Boolean;

    DCMHSRV : TK_HSRV;
    DCMINST : TK_HDCMINST;
    DCMModalites : TStringList;

    WBufStr : WideString;
    PatientIDs : TN_SArray;
    StudyPatientInds : TN_IArray;
    StudyUIDs : TN_SArray;
    SeriesStudyInds : TN_IArray;
    SeriesUIDs : TN_SArray;
    PrevSelPatientsCount, PrevSelStudiesCount : Integer;
    procedure ShowDICOMServerState;
    function  AddValueStringToFilter( ATag : TN_UInt4; const AName, AValue : string ) : Boolean;
    function  AddValueDateToFilter( ATag : TN_UInt4; const AName : string; ADTPFrom, ADTPTo : TDateTimePicker ) : Boolean;
    function  PrepErrStr( AHSRV : TK_HSRV ) : string;
    function  GetTagValue( AINST : TK_HDCMINST; ATAG : TN_UInt4; const ATagName : string ) : string;
    procedure ClearListView( AInt : Integer );
  public
    { Public declarations }
  end;

var
  K_FormCMDCMQR: TK_FormCMDCMQR;

function K_CMDCMQRDlg() : Integer;

implementation

{$R *.dfm}

uses DateUtils,
     K_FCMDCMDImport, K_CM0, K_CLib0, K_CMDCM, K_FCMDCMSetup,
     N_Lib0, N_Lib1, N_ImLib;

// TestCode
function WDLAddValueString( const APtr: Pointer; AUUnt4 : TN_UInt4; APWchar : Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLGetSrvLastErrorInfo( const APtr, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
  PWideChar(APtr1)^ := '*';
  PInteger(Aptr2)^ := 1;
end;
var WideValueStr : WideString;
var WideValueStrInd : Integer;
function WDLGetValueString( const APtr: Pointer; AUUnt4 : TN_UInt4; APWChar, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
var
  WS : WideString;
begin
  Result := 0;
//  WS := WideValueStr;
  WideValueStr := '';
  case AUUnt4 of
  K_CMDCMTPatientId: WideValueStr := '2CT2';
  K_CMDCMTPatientsName: WideValueStr := 'Smith^John^^Mr^';
  K_CMDCMTPatientsBirthDate: WideValueStr := '19750112';
  K_CMDCMTPatientsSex : WideValueStr := 'M';
  K_CMDCMTStudyInstanceUid : WideValueStr := '1.3.6.1.4.1.5962.1.2.2.20040826185059.5457';//'1.2.36.18057620390.12345678901234567890.4.123456789';
  K_CMDCMTStudyDate: WideValueStr := '20200514';
  K_CMDCMTStudyTime: WideValueStr := '120630';
  K_CMDCMTModality: if WideValueStrInd = 0 then
                      WideValueStr := 'CR'
                    else
                      WideValueStr := 'AB';
  K_CMDCMTSeriesInstanceUid : WideValueStr := '1.3.6.1.4.1.5962.1.3.2.1.20040826185059.5457';//'1.2.36.18057620390.12345678901234567890.5.123456789';
  K_CMDCMTSeriesDescription : WideValueStr := 'Computer Radiography';
  end;
  WS := WideValueStr;
  if WideValueStr = '' then
    WS := format( '$%8x', [AUUnt4] );
  Move( WS[1], APWChar^, 2 * Length(WS) );
  PInteger(Aptr1)^ := Length(WS);
  if WideValueStrInd >=1 then
    WideValueStrInd := 0
  else
    WideValueStrInd := 1;
end;
function WDLConnectEcho( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer; ATimeOut : Integer ) : Pointer; cdecl;
begin
  Result := Pointer(1);
end;
function WDLEcho( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLConnectQrScpFind( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer; AInt1 : Integer ) : Pointer; cdecl;
begin
  Result := Pointer(1);
end;
function WDLCreateDataset(): Pointer; cdecl;
begin
  Result := Pointer(2);
end;
function WDLFindQrByDcmFilter( const APtr1, APtr2: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLGetQrFindResultCount( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 2;
end;
function WDLGetQrFindResultObject( const APtr1: Pointer; AInt : Integer ) : Pointer; cdecl;
begin
  Result := Pointer(3);
end;
function WDLDeleteDcmObject( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLDeleteSrvObject( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLCloseConnection( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;

const K_QueryDICOMCodeISO_IR_192 : string = 'ISO_IR 192';
function K_CMDCMQRDlg() : Integer;
begin
{deb code
with K_DCMGLibW do
begin
  DLAddValueString := WDLAddValueString;
  DLGetSrvLastErrorInfo := WDLGetSrvLastErrorInfo;
  DLGetValueString := WDLGetValueString;
  DLConnectEcho := WDLConnectEcho;
  DLEcho := WDLEcho;
  DLConnectQrScpFind := WDLConnectQrScpFind;
  DLCreateDataset := WDLCreateDataset;
  DLFindQrByDcmFilter := WDLFindQrByDcmFilter;
  DLGetQrFindResultCount := WDLGetQrFindResultCount;
  DLGetQrFindResultObject := WDLGetQrFindResultObject;
  DLDeleteDcmObject :=  WDLDeleteDcmObject;
  DLDeleteSrvObject := WDLDeleteSrvObject;
  DLCloseConnection := WDLCloseConnection;
end;
{}

  with TK_FormCMDCMQR.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbServerName.Caption := N_MemIniToString( 'CMS_DCMQRSettings', 'Name', ''  );
    LbServerIP.Caption := N_MemIniToString( 'CMS_DCMQRSettings', 'IP', ''  );
    DCMServerPort := N_MemIniToInt( 'CMS_DCMQRSettings', 'Port', 0 );
    LbServerPort.Caption := '';
    if DCMServerPort <> 0 then
      LbServerPort.Caption := IntToStr(DCMServerPort);
    LbAppEntity.Caption := K_CMDCMSetupCMSuiteAetScu();

    N_Dump1Str( format( 'K_CMDCMQRDlg QR settings >> Name=%s IP=%s Port=%s AE=%s',
                [LbServerName.Caption, LbServerIP.Caption, LbServerPort.Caption, LbAppEntity.Caption] ) );

    ServerConnectionAttrsIsOK := (LbServerName.Caption <> '') and
                                 (LbServerIP.Caption <> '')   and
                                 (DCMServerPort <> 0);

    ServerConnectionIsDone := ServerConnectionAttrsIsOK;
    if ServerConnectionIsDone then
    begin
      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      ServerConnectionIsDone := K_CMDCMServerTestConnection( LbServerIP.Caption, DCMServerPort, LbServerName.Caption, LbAppEntity.Caption, 15, TRUE );
      Screen.Cursor := SavedCursor;
    end;
    ShowDICOMServerState();

//    BtQueryPatients.Enabled := ServerConnectionAttrsIsOK;
    BtQueryPatients.Enabled := ServerConnectionIsDone;

    ListView1.Checkboxes := ServerConnectionIsDone and
                            Assigned( N_ImageLib.ILDCMRetrieve );
    ListView2.Checkboxes := ListView1.Checkboxes;

    ListView3.Checkboxes := ListView2.Checkboxes;
    /////////////////////////////////////
    // Set Query controls
    //
    BtResetPatientsClick( nil );
    BtResetStudiesClick( nil );
    SetLength( WBufStr, 1024);
    DCMModalites := TStringList.Create;

    DCMModalites.CommaText := 'CR,OT,ES,RG,DX,IO,PX,GM,SM,XC';

    N_Dump1Str( 'Before TK_FormCMDCMQR.ShowModal' );
    ShowModal();
    N_Dump1Str( 'After TK_FormCMDCMQR.ShowModal' );

    DCMModalites.Free;
    Result := DCMImportCount;

  end; // with TK_FormCMDCMQR.Create(Application) do

end; // function K_CMDCMQRDlg

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

//*************************************************** K_CMDCMQueryCheckDate ***
// Check Date text representation
//
//    Parameters
// ATimeStr - source Time text representation, on output resulting Time correct
//            text representation
// AHour    - resulting encoded Date Hour
// AMonth   - resulting encoded Date Min
// ADay     - resulting encoded Date Sec
// Result   - Returns TRUE if source text representation is correct, FALSE
//
function K_CMDCMQueryCheckTime( var ATimeStr : string; out AHour, AMin, ASec : Integer ) : Boolean;
var
  WStr : string;
  SHour, SMin, SSec : string;
  WW, NHour, NMin, NSec : Word;
begin
  AHour := 0;
  AMin := 0;
  ASec := 0;
  Result := FALSE;
  if ATimeStr = '' then Exit; // Empty From/To is correct Value
  Result := TRUE;
  WStr := ATimeStr;
  SHour := '';
  if Length(WStr) > 2 then
  begin
    SHour := copy( WStr, 1, Length(WStr) - 2 );
    if Length(SHour) > 2 then
    begin
      Result := FALSE;
      SHour := copy( SHour, 1, 2 );
    end;
    WStr := copy( WStr, Length(WStr) - 3, 4 );
  end;

  SMin := '';
  if Length(WStr) > 2 then
  begin
    SMin := copy( WStr, 1, Length(WStr) - 2 );
    SSec := copy( WStr, Length(WStr) - 1, 2 );
  end
  else
    SMin := WStr;

  DecodeTime( Now(), NHour, NMin, NSec, WW );

  if SHour = '' then
    AHour := NHour
  else
    AHour := StrToIntDef( SHour, 0 );

  if SMin = '' then
    AMin := NMin
  else
  begin
    AMin := StrToIntDef( SMin, NMin );
    if (AMin > 59) or (AMin < 0) then
    begin
      Result := FALSE;
      AMin := NMin
    end;
  end;

  if SSec = '' then
    ASec := NSec
  else
  begin
    ASec := StrToIntDef( SSec, NSec );
    if (ASec > 59) or (ASec < 0) then
    begin
      Result := FALSE;
      ASec := NSec
    end;
  end;
  ATimeStr := format('%.2d%.2d%.2d', [AHour, AMin, ASec] );

end; // function K_CMDCMQueryCheckDate

//************************************ TK_FormCMDCMQR.ShowDICOMServerState ***
// Server State painting
//
procedure TK_FormCMDCMQR.ShowDICOMServerState;
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
end; // procedure TK_FormCMDCMQR.ShowDICOMServerState

//***************************************** TK_FormCMDCMQR.DTPFromChange ***
// DateTimePicker DTPFrom and DTPTo Change event handler
//
procedure TK_FormCMDCMQR.DTPStFromChange(Sender: TObject);
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

end; // procedure TK_FormCMDCMQR.DTPFromChange

function TK_FormCMDCMQR.AddValueStringToFilter( ATag : TN_UInt4; const AName, AValue : string ) : Boolean;
var
  SStr : string;
  WStr : WideString;
  PW: PWidechar;
const WC: WideChar = #0;
begin
  Result := TRUE;
  SStr := format( '%s=%s', [AName, AValue] );
  N_Dump2Str( SStr );
  PW := @WC;
  if AValue <> '' then
  begin
    WStr := N_StringToWide( AValue );
    PW := @WStr[1];
  end;
  if 0 <> K_DCMGLibW.DLAddValueString( DCMINST, ATag, PW ) then
  begin
    Result := FALSE;
    N_Dump1Str( format( 'TK_FormCMDCMQR >> wrong DLAddValueString %x %s', [ATag, SStr] ) );
  end;
end; // procedure TK_FormCMDCMQR.AddValueStringToFilter

function TK_FormCMDCMQR.AddValueDateToFilter( ATag: TN_UInt4; const AName: string; ADTPFrom, ADTPTo: TDateTimePicker): Boolean;
var
  Str : string;
begin
  Str := '';
  if ADTPFrom.Checked then
    Str := K_DateTimeToStr(ADTPFrom.Date,'yyyyMMdd-');
  if ADTPTo.Checked then
  begin
    if Str <> '' then
    begin
      if ADTPFrom.Date = ADTPTo.Date then
        Str := K_DateTimeToStr(ADTPTo.Date,'yyyyMMdd')
      else
        Str := Str + K_DateTimeToStr(ADTPTo.Date,'yyyyMMdd');
    end
    else
      Str := K_DateTimeToStr(ADTPTo.Date,'-yyyyMMdd');
  end;
  Result := AddValueStringToFilter( ATag, AName, Str );
end; // function TK_FormCMDCMQR.AddValueDateToFilter

function TK_FormCMDCMQR.PrepErrStr( AHSRV : TK_HSRV ) : string;
var ErrLeng : Integer;
begin
  ErrLeng := 1024;
  K_DCMGLibW.DLGetSrvLastErrorInfo( AHSRV, @WBufStr[1], @ErrLeng );
  Result := N_WideToString( Copy( WBufStr, 1, ErrLeng ) );
end; // TK_FormCMDCMQR.PrepErrStr

function TK_FormCMDCMQR.GetTagValue( AINST : TK_HDCMINST; ATAG : TN_UInt4; const ATagName : string ) : string;
var
  sz : Integer;
  isNil : Integer;
begin
  sz := 1024;
  Result := '';
  if 0 <>	 K_DCMGLibW.DLGetValueString( AINST, ATAG, @WBufStr[1], @sz, @isNil) then
    N_Dump1Str( 'TK_FormCMDCMQR >> GetTag ' + ATagName  )
  else
  begin
    Result := N_WideToString( Copy( WBufStr, 1, sz ) );
    N_Dump2Str( '>>' + ATagName + '=' + Result );
  end;
end;

procedure TK_FormCMDCMQR.ClearListView( AInt : Integer );
begin
  if AInt = 1 then
  begin
    ListView1.Items.BeginUpdate();
    ListView1.Items.Clear();
    ListView1.Items.EndUpdate();
    BtQueryStudies.Enabled := FALSE;
    BtResetPatients.Enabled := FALSE;
    BtSelectAllPatients.Enabled := FALSE;
    AInt := 2;
  end;

  if AInt = 2 then
  begin
    ListView2.Items.BeginUpdate();
    ListView2.Items.Clear();
    ListView2.Items.EndUpdate();
    BtQuerySeries.Enabled := FALSE;
    BtResetStudies.Enabled := FALSE;
    BtSelectAllStudies.Enabled := FALSE;
    AInt := 3;
  end;

  if AInt = 3 then
  begin
    ListView3.Items.BeginUpdate();
    ListView3.Items.Clear();
    ListView3.Items.EndUpdate();
    BtSelectAllSeries.Enabled := FALSE;
    BtResetSeries.Enabled := FALSE;
    BtRetrieve.Enabled := FALSE;
  end;

end; // TK_FormCMDCMQR.ClearListView

//****************************************** TK_FormCMDCMQR.BtQueryClick ***
// Button BtQuery Click event handler
//
procedure TK_FormCMDCMQR.BtQueryPatientsClick(Sender: TObject);
var
  Str : string;
  WStr1, WStr2, WStr3 : WideString;
  Res : TN_UInt2;
  i, Ind, Ind1, PatNameLeng : Integer;
  Str1 : string;
//  IYear, IMonth, IDay : Integer;
  DI : TK_HDCMINST;

begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  N_Dump2Str( 'BtQueryPatientsClick Start' );
  with K_DCMGLibW do
  begin
    ListView1.Items.BeginUpdate();
    ClearListView( 1 );

    SetLength( PatientIDs, 0 );
    WStr1 := N_StringToWide( LbServerIP.Caption );
    WStr2 := N_StringToWide( LbServerName.Caption );
    WStr3 := N_StringToWide( LbAppEntity.Caption );
    DCMHSRV := DLConnectQrScpFind( @WStr1[1], DCMServerPort, @WStr2[1], @WStr3[1], 0 );
    if DCMHSRV <> nil then
    begin
      N_Dump2Str( '!!!BtQueryPatientsClick Filter start' );
      DCMINST := DLCreateDataset();
      AddValueStringToFilter( K_CMDCMTSpecificCharacterSet, 'SpecificCharacterSet', K_QueryDICOMCodeISO_IR_192 );
      AddValueStringToFilter( K_CMDCMTQueryRetrieveLevel, 'QueryRetrieveLevel', 'PATIENT' );
      AddValueStringToFilter( K_CMDCMTPatientsName, 'PatientsName', LEdPatName.Text );
      AddValueStringToFilter( K_CMDCMTPatientId, 'PatientID', LEdPatID.Text );
      AddValueStringToFilter( K_CMDCMTPatientsBirthDate, 'PatientsBirthDate', '' );
      AddValueStringToFilter( K_CMDCMTPatientsSex, 'PatientsSex', '' );
      N_Dump2Str( '!!!BtQueryPatientsClick Filter fin' );

      Res := DLFindQrByDcmFilter( DCMHSRV, DCMINST );
      N_Dump2Str( '!!!After DLFindQrByDcmFilter' );
      if Res = 0 then
      begin
        Res := DLGetQrFindResultCount( DCMHSRV );
        N_Dump2Str( '!!!After DLGetQrFindResultCount ' + IntToStr(Res) );
        SetLength( PatientIDs, Res );
        for i := 0 to Res - 1 do
        begin
          DI := DLGetQrFindResultObject(DCMHSRV, i);
          with ListView1.Items.Add() do
          begin
            Caption := GetTagValue( DI, K_CMDCMTPatientId, 'PatientID' );
            PatientIDs[i] := Caption;

            Str :=  GetTagValue( DI, K_CMDCMTPatientsName, 'PatientsName' );
            // Get SurName
            PatNameLeng := Length( Str );
            Ind := N_PosEx( '^', Str, 1, PatNameLeng );
            Str1 := '';
            if Ind > 1 then
              Str1 := Copy( Str, 1, Ind - 1 );
            SubItems.Add( Str1 );
            // GetFirstName
            Str1 := '';
            if Ind > 0 then
            begin
              Ind1 := N_PosEx( '^', Str, Ind + 1, PatNameLeng );
              if Ind1 > 0 then
                Str1 := Copy( Str, Ind + 1, Ind1 - Ind - 1 );
            end;
            SubItems.Add( Str1 );

            // GetDOB
            Str :=  GetTagValue( DI, K_CMDCMTPatientsBirthDate, 'PatientsBirthDate' );
{
            if Str <> '' then
            begin
              Str1 := Str;
              if not K_CMDCMQueryCheckDate( Str, IYear, IMonth, IDay ) then
                N_Dump1Str( format( '!!!PatDOB %s >> %s', [Str1,Str] ) );
              Str := K_DateTimeToStr( EncodeDate(IYear, IMonth, IDay), N_WinFormatSettings.ShortDateFormat );
            end;
}
            SubItems.Add( Str );

            // GetGender
            Str := GetTagValue( DI, K_CMDCMTPatientsSex, 'PatientsSex' );
            SubItems.Add( Str );

          end; // with ListView1.Items.Add() do
        end; // for i := 0 to res - 1 do
      end
      else
        N_Dump1Str( format('TK_FormCMDCMQR >> FindQrByDcmFilter Patients Query Error=%d, %s', [Res, PrepErrStr(DCMHSRV) ] ) );
      DLDeleteDcmObject( DCMINST );
      N_Dump2Str( '!!!After DLDeleteDcmObject' );
      DLCloseConnection(DCMHSRV);
      N_Dump2Str( '!!!After DLCloseConnection' );
      DLDeleteSrvObject(DCMHSRV);
      N_Dump2Str( '!!!After DLDeleteSrvObject' );
    end
    else
      N_Dump1Str( 'TK_FormCMDCMQR.QueryPatients >> ConnectQrScpFind fails' );

    ListView1.Items.EndUpdate();
    N_Dump2Str( 'BtQueryPatientsClick Fin ' + IntToStr(ListView1.Items.Count) );
    BtSelectAllPatients.Enabled := ListView1.Items.Count > 0;
    BtResetPatients.Enabled := TRUE;
  end; // with K_DCMGLibW do
  Screen.Cursor := SavedCursor;
end; // procedure TK_FormCMDCMQR.BtQueryPatientsClick

procedure TK_FormCMDCMQR.BtQueryStudiesClick(Sender: TObject);
var
  Str : string;
  WStr1, WStr2, WStr3 : WideString;
  Res : TN_UInt2;
  i, Ind, Ind1, j : Integer;
  DI : TK_HDCMINST;

begin
  N_Dump2Str( 'BtQueryStudiesClick Start' );
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  with K_DCMGLibW do
  begin
    ListView2.Items.BeginUpdate();
    ClearListView( 2 );

    SetLength( StudyUIDs, 0 );
    SetLength( StudyPatientInds, 0 );
    WStr1 := N_StringToWide( LbServerIP.Caption );
    WStr2 := N_StringToWide( LbServerName.Caption );
    WStr3 := N_StringToWide( LbAppEntity.Caption );
    DCMHSRV := DLConnectQrScpFind( @WStr1[1], DCMServerPort, @WStr2[1], @WStr3[1], 0 );
    if DCMHSRV <> nil then
    begin
      for j := 0 to  High( PatientIDs ) do
      begin

        if not ListView1.Items[j].Checked then Continue;

        N_Dump2Str( '!!!BtQueryStudiesClick Filter start' );
        DCMINST := DLCreateDataset();
        AddValueStringToFilter( K_CMDCMTSpecificCharacterSet, 'SpecificCharacterSet', K_QueryDICOMCodeISO_IR_192 );
        AddValueStringToFilter( K_CMDCMTQueryRetrieveLevel, 'QueryRetrieveLevel', 'STUDY' );
        AddValueStringToFilter( K_CMDCMTPatientId, 'PatientID', PatientIDs[j] );
        AddValueStringToFilter( K_CMDCMTAccessionNumber, 'AccessionNum', LEdANum.Text );
        AddValueDateToFilter( K_CMDCMTStudyDate, 'StudyDate', DTPStFrom, DTPStTo );
        AddValueStringToFilter( K_CMDCMTStudyInstanceUid, 'StudyUID', '' );
        AddValueStringToFilter( K_CMDCMTStudyTime, 'StudyTime', '' );
        N_Dump2Str( '!!!BtQueryStudiesClick Filter fin' );

        Res := DLFindQrByDcmFilter( DCMHSRV, DCMINST );
        N_Dump2Str( '!!!After DLFindQrByDcmFilter' );
        if Res = 0 then
        begin
          Res := DLGetQrFindResultCount( DCMHSRV );
          N_Dump2Str( '!!!After DLGetQrFindResultCount ' + IntToStr(Res) );

          Ind1 := Length(StudyUIDs);
          Ind :=  Ind1 + Res;
          SetLength( StudyUIDs, Ind );
          SetLength( StudyPatientInds, Ind );

          for i := 0 to Res - 1 do
          begin
            StudyPatientInds[Ind1] := j;

            DI := DLGetQrFindResultObject(DCMHSRV, i);
            with ListView2.Items.Add() do
            begin
              Caption := PatientIDs[j];

              Str :=  GetTagValue( DI, K_CMDCMTStudyInstanceUid, 'StudyUID' );
              StudyUIDs[Ind1] := Str;
              SubItems.Add( Str );

              // GetStudyDate
              Str :=  GetTagValue( DI, K_CMDCMTStudyDate, 'StudyDate' );
              SubItems.Add( Str );

              // GetStudyTime
              Str := GetTagValue( DI, K_CMDCMTStudyTime, 'StudyTime' );
              SubItems.Add( Str );
            end; // with ListView1.Items.Add() do
            Inc( Ind1 );

          end; // for i := 0 to res - 1 do
        end
        else
          N_Dump1Str( format('TK_FormCMDCMQR >> FindQrByDcmFilter Studies Query PatID=%s Error=%d, %s',
                      [PatientIDs[j], Res, PrepErrStr(DCMHSRV)] ) );
        DLDeleteDcmObject( DCMINST );
        N_Dump2Str( '!!!After DLDeleteDcmObject' );
      end; // for j := 0 to  High( PatientIDs ) do
      DLCloseConnection(DCMHSRV);
      N_Dump2Str( '!!!After DLCloseConnection' );
      DLDeleteSrvObject(DCMHSRV);
      N_Dump2Str( '!!!After DLDeleteSrvObject' );
    end
    else
      N_Dump1Str( 'TK_FormCMDCMQR.QueryStudies >> ConnectQrScpFind fails' );

    ListView2.Items.EndUpdate();
    N_Dump2Str( 'BtQueryStudiesClick Fin ' + IntToStr(ListView2.Items.Count) );
    BtSelectAllStudies.Enabled := ListView2.Items.Count > 0;
    BtResetStudies.Enabled := TRUE;
  end; // with K_DCMGLibW do
  Screen.Cursor := SavedCursor;
end; // procedure TK_FormCMDCMQR.BtQueryStudiesClick

procedure TK_FormCMDCMQR.BtQuerySeriesClick(Sender: TObject);
var
  Str, Str1 : string;
  WStr1, WStr2, WStr3 : WideString;
  Res : TN_UInt2;
  i, Ind, Ind1, j : Integer;
  DI : TK_HDCMINST;

begin
  N_Dump2Str( 'BtQuerySeriesClick Start' );
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  with K_DCMGLibW do
  begin
    ListView3.Items.BeginUpdate();
    ClearListView( 3 );
    SetLength( SeriesUIDs, 0 );
    SetLength( SeriesStudyInds, 0 );
    WStr1 := N_StringToWide( LbServerIP.Caption );
    WStr2 := N_StringToWide( LbServerName.Caption );
    WStr3 := N_StringToWide( LbAppEntity.Caption );
    DCMHSRV := DLConnectQrScpFind( @WStr1[1], DCMServerPort, @WStr2[1], @WStr3[1], 0 );
    if DCMHSRV <> nil then
    begin
      for j := 0 to  High( StudyUIDs ) do
      begin

        if not ListView2.Items[j].Checked then Continue;

        N_Dump2Str( '!!!BtQuerySeriesClick Filter start' );
        DCMINST := DLCreateDataset();
        AddValueStringToFilter( K_CMDCMTSpecificCharacterSet, 'SpecificCharacterSet', K_QueryDICOMCodeISO_IR_192 );
        AddValueStringToFilter( K_CMDCMTQueryRetrieveLevel, 'QueryRetrieveLevel', 'SERIES' );
        AddValueStringToFilter( K_CMDCMTPatientId, 'PatientID', PatientIDs[StudyPatientInds[j]] );
        AddValueStringToFilter( K_CMDCMTStudyInstanceUid, 'StudyUID', StudyUIDs[j] );
        AddValueStringToFilter( K_CMDCMTModality, 'Modality', LEdModality.Text );
        AddValueStringToFilter( K_CMDCMTSeriesInstanceUid, 'SeriesUID', '' );
        AddValueStringToFilter( K_CMDCMTSeriesDescription, 'SeriesDescr', '' );
        N_Dump2Str( '!!!BtQuerySeriesClick Filter fin' );

        Res := DLFindQrByDcmFilter( DCMHSRV, DCMINST );
        N_Dump2Str( '!!!After DLFindQrByDcmFilter' );
        if Res = 0 then
        begin
          Res := DLGetQrFindResultCount( DCMHSRV );
          N_Dump2Str( '!!!After DLGetQrFindResultCount ' + IntToStr(Res) );

          Ind1 := ListView3.Items.Count;
          Ind :=  Ind1 + Res;
          if Ind > Length(SeriesUIDs) then
          begin
            SetLength( SeriesUIDs, Ind );
            SetLength( SeriesStudyInds, Ind );
          end;
          for i := 0 to Res - 1 do
          begin
            DI := DLGetQrFindResultObject(DCMHSRV, i);

            // GetSeriesModality
            Str1 :=  GetTagValue( DI, K_CMDCMTModality, 'Modality' );
            if DCMModalites.IndexOf(Str1) < 0 then
            begin
              N_Dump2Str( 'Skiped Modality=' + Str1 );
              Continue;
            end;
            SeriesStudyInds[Ind1] := j;

            with ListView3.Items.Add() do
            begin
              Caption := StudyUIDs[j];

              Str :=  GetTagValue( DI, K_CMDCMTSeriesInstanceUid, 'SeriesUID' );
              SeriesUIDs[Ind1] := Str;

              // GetSeriesDescr
              Str := GetTagValue( DI, K_CMDCMTSeriesDescription, 'SeriesDescr' );
              SubItems.Add( Str );

              // Add Modality
              SubItems.Add( Str1 );

            end; // with ListView1.Items.Add() do
            Inc( Ind1 );

          end; // for i := 0 to res - 1 do
        end
        else
          N_Dump1Str( format('TK_FormCMDCMQR >> FindQrByDcmFilter Studeis Query PatID=%s Error=%d, %s',
                        [PatientIDs[StudyPatientInds[j]],Res, PrepErrStr(DCMHSRV) ] ) );
        DLDeleteDcmObject( DCMINST );
        N_Dump2Str( '!!!After DLDeleteDcmObject' );
      end; // for j := 0 to  High( StudyUIDs ) do
      DLCloseConnection(DCMHSRV);
      N_Dump2Str( '!!!After DLCloseConnection' );
      DLDeleteSrvObject(DCMHSRV);
      N_Dump2Str( '!!!After DLDeleteSrvObject' );
      with ListView3.Items do
      begin
        SetLength( SeriesUIDs, Count );
        SetLength( SeriesStudyInds, Count );
      end;
    end
    else
      N_Dump1Str( 'TK_FormCMDCMQR.QueryStudies >> ConnectQrScpFind fails' );

    ListView3.Items.EndUpdate();
    N_Dump2Str( 'BtQuerySeriesClick Fin ' + IntToStr(ListView3.Items.Count) );
    BtSelectAllSeries.Enabled := ListView3.Items.Count > 0;
    BtResetSeries.Enabled := TRUE;
  end; // with K_DCMGLibW do
  Screen.Cursor := SavedCursor;
end; // procedure TK_FormCMDCMQR.BtQuerySeriesClick

//**************************************** TK_FormCMDCMQR.ListView2Click ***
// ListView Click event handler
//
procedure TK_FormCMDCMQR.ListView1Click(Sender: TObject);
var
  i : Integer;
  CC: Integer;
begin
  N_Dump2Str( 'ListView1Click Start' );
  BtQueryStudies.Enabled := FALSE;
  if not ListView1.Checkboxes then Exit;

  CC := 0;
  for i := 0 to ListView1.Items.Count - 1 do
    if ListView1.Items[i].Checked then
      Inc(CC);

  BtQueryStudies.Enabled := CC > 0;
  if CC <> PrevSelPatientsCount then
    ClearListView( 2 );

  PrevSelPatientsCount := CC;
  N_Dump2Str( 'ListView1Click fin ' + IntToStr(CC) );

end; // procedure TK_FormCMDCMQR.ListView1Click

procedure TK_FormCMDCMQR.ListView2Click(Sender: TObject);
var
  i : Integer;
  CC: Integer;
begin
  N_Dump2Str( 'ListView2Click Start' );
  BtQuerySeries.Enabled := FALSE;
  if not ListView2.Checkboxes then Exit;

  CC := 0;
  for i := 0 to ListView2.Items.Count - 1 do
    if ListView2.Items[i].Checked then
      Inc(CC);

  BtQuerySeries.Enabled := CC > 0;
  if CC <> PrevSelStudiesCount then
    ClearListView( 3 );

  PrevSelStudiesCount := CC;
  N_Dump2Str( 'ListView2Click fin ' + IntToStr(CC) );

end; // procedure TK_FormCMDCMQR.ListView2Click

procedure TK_FormCMDCMQR.ListView3Click(Sender: TObject);
var
  i : Integer;
begin
  N_Dump2Str( 'ListView3Click Start' );
  BtRetrieve.Enabled := FALSE;
  if not ListView3.Checkboxes then Exit;

  for i := 0 to ListView3.Items.Count - 1 do
    if ListView3.Items[i].Checked then
    begin
      BtRetrieve.Enabled := TRUE;
      break;
    end;
  N_Dump2Str( 'ListView3Click fin ' + N_B2S(BtRetrieve.Enabled) );
end; // procedure TK_FormCMDCMQR.ListView3Click

//*************************************** TK_FormCMDCMQR.BtRetrieveClick ***
// Button BtRetrieve OnClick event handler
//
procedure TK_FormCMDCMQR.BtRetrieveClick(Sender: TObject);
var
  i, Ind : Integer;
begin

  N_Dump2Str( 'BtRetrieveClick Start' );
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    Connection := LANDBConnection;

//////////////////////////////////
// Get Instance Global ID
//
    SQL.Text := 'select 1 ' +
      K_CMENDDCMRQID + ',' +
      K_CMENDDCMRQSPID + ',' +
      K_CMENDDCMRQDPID + ',' +
      K_CMENDDCMRQSTUID + ',' +
      K_CMENDDCMRQSEUID +
      ' from ' + K_CMENDBDCMRQueueTable;
    Filtered := false;
    Open;
    DCMImportCount := 0;
    for i := 0 to ListView3.Items.Count - 1 do
    begin
      if not ListView3.Items[i].Checked then Continue;

      // Put New Query to Queue
      Inc(DCMImportCount);
//      Last;
      Insert;
      Ind := SeriesStudyInds[i];
      N_Dump1Str( format( 'RetrieveQueueAdd CMSPID=%d DCMPID=%s StUID=%s SeUID=%s',
                    [CurPatID,PatientIDs[StudyPatientInds[Ind]],StudyUIDs[Ind],SeriesUIDs[i]] ) );
      FieldList.Fields[1].AsInteger := CurPatID;
      EDAPutStringFieldValue( FieldList.Fields[2], PatientIDs[StudyPatientInds[Ind]] );
      EDAPutStringFieldValue( FieldList.Fields[3], StudyUIDs[Ind] );
      EDAPutStringFieldValue( FieldList.Fields[4], SeriesUIDs[i] );
      UpdateBatch;

    end;
    Close;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

  Close(); // Close dialog
  N_Dump2Str( 'BtRetrieveClick fin' );

end; // procedure TK_FormCMDCMQR.BtRetrieveClick

//****************************************** TK_FormCMDCMQR.BtResetClick ***
// Button BtReset OnClick event handler
//
procedure TK_FormCMDCMQR.BtResetPatientsClick(Sender: TObject);
var   PatientDBData : TK_CMSAPatientDBData;

begin
//  LEdPatSurname.Text := '';
//  LEdPatFirstname.Text := '';;
//  LEdPatID.Text := '';
//  LEdStudyID.Text := '';
//  LEdModality.Text := '';
  with K_CMEDAccess do
    EDASAGetOnePatientInfo( IntToStr( CurPatID ), @PatientDBData, [K_cmsagiSkipLock] );
  with PatientDBData do
  begin
    LEdPatName.Text := K_CMDCMGetTagPatientNameValue( @PatientDBData );
//    LEdPatName.Text := format( '%s^%s^%s^%s', [APSurname,APFirstname,APMiddle,APTitle] );
    LEdPatID.Text := APCardNum;
{
    DTPPatDOBFrom.Checked := FALSE;
    DTPPatDOBTo.Checked := FALSE;
    if APDOB <> 0 then
    begin
      DTPPatDOBFrom.DateTime := APDOB;
//    DTPPatDOBFrom.Checked := TRUE;
      DTPPatDOBTo.DateTime := APDOB;
//    DTPPatDOBTo.Checked := TRUE;
    end; // if APDOB <> 0 then
    DTPPatDOBFrom.OnChange(DTPPatDOBFrom);
    DTPPatDOBTo.OnChange(DTPPatDOBTo);
}
  end; // with PatientDBData do

  ClearListView( 1 );

end; // procedure TK_FormCMDCMQR.BtResetPatientsClick

procedure TK_FormCMDCMQR.BtResetStudiesClick(Sender: TObject);
begin
  DTPStFrom.DateTime := Now();
  DTPStTo.DateTime := Now();

  DTPStFrom.Date := 0;
  DTPStFrom.Checked := FALSE;
  DTPStFrom.OnChange(DTPStFrom);
  DTPStTo.Date := 0;
  DTPStTo.Checked := FALSE;
  DTPStTo.OnChange(DTPStTo);

  LEdANum.Text := '';

  ClearListView( 2 );

end; // procedure TK_FormCMDCMQR.BtResetStudiesClick

procedure TK_FormCMDCMQR.BtResetSeriesClick(Sender: TObject);
begin
  LEdModality.Text := '';
  ClearListView( 3 );
end; // procedure TK_FormCMDCMQR.BtResetSeriesClick

procedure TK_FormCMDCMQR.BtSelectAllPatientsClick(Sender: TObject);
var
  i : Integer;
begin
  BtQueryStudies.Enabled := FALSE;
  if not ListView1.Checkboxes then Exit;
  for i := 0 to ListView1.Items.Count - 1 do
    ListView1.Items[i].Checked := TRUE;
  BtQueryStudies.Enabled := ListView1.Items.Count > 0;
end; // procedure TK_FormCMDCMQR.BtSelectAllPatientsClick

procedure TK_FormCMDCMQR.BtSelectAllStudiesClick(Sender: TObject);
var
  i : Integer;
begin
  BtQuerySeries.Enabled := FALSE;
  if not ListView2.Checkboxes then Exit;
  for i := 0 to ListView2.Items.Count - 1 do
    ListView2.Items[i].Checked := TRUE;
  BtQuerySeries.Enabled := ListView2.Items.Count > 0;
end; // procedure TK_FormCMDCMQR.BtSelectAllStudiesClick

procedure TK_FormCMDCMQR.BtSelectAllSeriesClick(Sender: TObject);
var
  i : Integer;
begin
  BtRetrieve.Enabled := FALSE;
  if not ListView3.Checkboxes then Exit;
  for i := 0 to ListView3.Items.Count - 1 do
    ListView3.Items[i].Checked := TRUE;
  BtRetrieve.Enabled := ListView3.Items.Count > 0;
end; // procedure TK_FormCMDCMQR.BtSelectAllSeriesClick

end.
