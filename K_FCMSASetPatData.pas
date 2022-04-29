unit K_FCMSASetPatData;

interface

uses
  SysUtils, Forms, ComCtrls, StdCtrls, ExtCtrls, Controls, Classes,
  K_CM0,
  N_BaseF, N_Types;

type
  TK_FormCMSASetPatientData = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    LbTitle: TLabel;
    CmBTitle: TComboBox;
    CmBGender: TComboBox;
    LbGender: TLabel;
    LbECardNum: TLabeledEdit;
    LbESurname: TLabeledEdit;
    LbEFirstname: TLabeledEdit;
    LbEMiddle: TLabeledEdit;
    DTPDOB: TDateTimePicker;
    LbDOB: TLabel;
    LbEAge: TLabeledEdit;
    LbDentist: TLabel;
    CmBDentist: TComboBox;
    BtNewProvider: TButton;
    LbEAddr1: TLabeledEdit;
    LbEAddr2: TLabeledEdit;
    LbESuburb: TLabeledEdit;
    LbEPostcode: TLabeledEdit;
    LbEState: TLabeledEdit;
    LbEPhone1: TLabeledEdit;
    LbEPhone2: TLabeledEdit;
    CmBMaleTitle: TComboBox;
    CmBFemaleTitle: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure LbECardNumChange(Sender: TObject);
    procedure DTPDOBChange(Sender: TObject);
    procedure EdMaskDTPEnter(Sender: TObject);
    procedure DTPDOBExit(Sender: TObject);
    procedure BtNewProviderClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CmBTitleChange(Sender: TObject);
    procedure LbEditControlAutoCapitalExit(Sender: TObject);
    procedure LbEditControlAutoCapitalKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LbEditControlAllCapitalExit(Sender: TObject);
    procedure LbEditControlAllCapitalKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
     EdMaskDTP0: TEdit;
     ReadOnly : Boolean;
     function GetAgeStr( TS : TDateTime ) : string;
  public
    { Public declarations }
    PatSID : string;
    SrcDOB : TDateTime;
    SrcEmptyDOB : Boolean;
    function GetGenderIndByTitle( const ATitle : string ) : Integer;
    function GetGenderTextByTitle( const ATitle : string ) : string;
  end;

var
  K_FormCMSASetPatientData: TK_FormCMSASetPatientData;

function  K_CMSASetPatientDataDlg( const APatID : string;
                    APCMSAPatientDBData : TK_PCMSAPatientDBData ) : Boolean;

implementation

{$R *.dfm}
uses Windows, Math, DateUtils, Dialogs,
N_Lib0,
K_CLib0, K_FCMSASetProvData, K_CML1F;

//***************************************************** K_CMSASetPatientDataDlg ***
// Set CMS Standalone Patient Data Dialog
//
//     Parameters
// APatID - Patient Code string
// APCMSAPatientDBData - Provider Data
// Result - Returns FALSE if user do not click OK
//
function  K_CMSASetPatientDataDlg( const APatID : string;
                    APCMSAPatientDBData : TK_PCMSAPatientDBData ) : Boolean;
begin

  with TK_FormCMSASetPatientData.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    if K_CMSMainUIShowMode >= 0 then // Photometry mode
    begin
      LbEAddr1.EditLabel.Caption := 'Ñףללא 4-ץ נוחצמג  ';
      LbEAddr1.Left  := 150; // 72
      LbEAddr1.Width := 150; // 401
    end;

    PatSID := APatID;
    if PatSID = '' then
    begin
      Caption := K_CML1Form.LLLSelPat12.Caption; // 'New Patient';
//!!!      APCMSAPatientDBData.APDOB := 0; // all fields are clear for new patient
      if APCMSAPatientDBData.APProvID = 0 then
        APCMSAPatientDBData.APProvID := StrToIntDef( PString(K_CMEDAccess.ProvidersInfo.R.PME( 0, 1 ))^, -1 );
//      APCMSAPatientDBData.APProvID := 1;
//      APCMSAPatientDBData.APIsLocked := TRUE;
      ReadOnly := FALSE;
    end
    else
    begin
      Caption := K_CML1Form.LLLSelPat13.Caption; // 'Modify Patient';
      if APCMSAPatientDBData.APIsPMSSync then
        Caption := K_CML1Form.LLLSelPat14.Caption; // 'Patient details';
      ReadOnly := not APCMSAPatientDBData.APIsLocked or
                  (K_CMStandaloneMode = K_cmsaLink) or
                  (APCMSAPatientDBData.APIsPMSSync and
                   (K_CMStandaloneMode = K_cmsaHybrid))
    end;

    with CmBGender do // 0
    begin
      ItemIndex := Items.IndexOf( APCMSAPatientDBData.APGender );
//      if ItemIndex = -1 then
//        ItemIndex := Items.Count - 1;
    end;

    CmBGender.Enabled := not ReadOnly;
    LbGender.Enabled  := not ReadOnly;

    with CmBTitle do // 0
    begin
      if Items[Items.Count - 1] <> '' then
        Items.Add( '' );
      ItemIndex := Items.IndexOf( APCMSAPatientDBData.APTitle );
      if ItemIndex = -1 then
        ItemIndex := Items.Count - 1;
    end;
    CmBTitle.Enabled := not ReadOnly;
    LbTitle.Enabled  := not ReadOnly;
    CmBTitleChange(CmBTitle);

    LbECardNum.Text := APCMSAPatientDBData.APCardNum;
    LbECardNum.Enabled := not ReadOnly;

    LbESurname.Text := APCMSAPatientDBData.APSurname;
    LbESurname.Enabled := not ReadOnly;

    LbEFirstname.Text := APCMSAPatientDBData.APFirstname;
    LbEFirstname.Enabled := not ReadOnly;

    LbEMiddle.Text := APCMSAPatientDBData.APMiddle;
    LbEMiddle.Enabled := not ReadOnly;

    SrcDOB := APCMSAPatientDBData.APDOB;
    SrcEmptyDOB := SrcDOB = 0;
    if SrcEmptyDOB then
      SrcDOB := Date();
    DTPDOB.DateTime := SrcDOB;
    DTPDOB.Enabled := not ReadOnly;
    LbDOB.Enabled  := not ReadOnly;

    LbEAge.Text := GetAgeStr( DTPDOB.DateTime ); // Calculate Pat Age
    LbEAge.Enabled  := not ReadOnly;

    with CmBDentist do
    begin
      ItemIndex := K_CMSAFillProvidersList( Items, IntToStr(APCMSAPatientDBData.APProvID) );
      if ItemIndex = -1 then
        ItemIndex := 0;
    end;
    CmBDentist.Enabled := not ReadOnly;
    BtNewProvider.Enabled := not ReadOnly;
    LbDentist.Enabled  := not ReadOnly;

    LbEAddr1.Text := APCMSAPatientDBData.APAddr1;
    LbEAddr1.Enabled := not ReadOnly;

    LbEAddr2.Text := APCMSAPatientDBData.APAddr2;
    LbEAddr2.Enabled := not ReadOnly;

    LbESuburb.Text := APCMSAPatientDBData.APSuburb;
    LbESuburb.Enabled := not ReadOnly;

    LbEPostcode.Text := APCMSAPatientDBData.APPostcode;
    LbEPostcode.Enabled := not ReadOnly;

    LbEState.Text := APCMSAPatientDBData.APState;
    LbEState.Enabled := not ReadOnly;

    LbEPhone1.Text := APCMSAPatientDBData.APPhone1;
    LbEPhone1.Enabled := not ReadOnly;

    LbEPhone2.Text := APCMSAPatientDBData.APPhone2;
    LbEPhone2.Enabled := not ReadOnly;

    BtOK.Visible := not ReadOnly;
    if ReadOnly then
      BtCancel.Caption := BtOK.Caption; //'&OK';

    Result := ShowModal() = mrOK;
    if not Result then Exit;

    APCMSAPatientDBData.APTitle     := CmBTitle.Text;
    APCMSAPatientDBData.APGender    := CmBGender.Text;
    APCMSAPatientDBData.APCardNum   := LbECardNum.Text;
    APCMSAPatientDBData.APSurname   := LbESurname.Text;
    APCMSAPatientDBData.APFirstname := LbEFirstname.Text;
    APCMSAPatientDBData.APMiddle    := LbEMiddle.Text;
    if (DTPDOB.DateTime <> SrcDOB) and (LbEAge.Text <> '') then
      APCMSAPatientDBData.APDOB     := DTPDOB.DateTime;
    with K_CMEDAccess.ProvidersInfo.R, CmBDentist do
      APCMSAPatientDBData.APProvID  := StrToInt( PString(PME( 0, Integer(Items.Objects[ItemIndex])))^ );
//      APCMSAPatientDBData.APProvID  := Integer(Items.Objects[ItemIndex]);

    APCMSAPatientDBData.APAddr1     := LbEAddr1.Text;
    APCMSAPatientDBData.APAddr2     := LbEAddr2.Text;
    APCMSAPatientDBData.APSuburb    := LbESuburb.Text;
    APCMSAPatientDBData.APPostCode  := LbEPostCode.Text;
    APCMSAPatientDBData.APState     := LbEState.Text;
    APCMSAPatientDBData.APPhone1    := LbEPhone1.Text;
    APCMSAPatientDBData.APPhone2    := LbEPhone2.Text;
  end;

end; // function  K_CMSASetPatientDataDlg

//******************************* TK_FormCMSASetPatientData.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSASetPatientData.FormShow(Sender: TObject);
begin
  DTPDOB.Format := N_WinFormatSettings.ShortDateFormat;

  if SrcEmptyDOB then
  begin
    DTPDOB.TabStop := FALSE;
    EdMaskDTP0 := TEdit.Create( Self );
    with EdMaskDTP0 do
    begin
      Color := $00A2FFFF;
      Top  := DTPDOB.Top;
      Width := DTPDOB.Width;
      Height := DTPDOB.Height;
      Left := DTPDOB.Left;
      Parent := Self;
//      Text := '';
      OnEnter := EdMaskDTPEnter;
      Enabled := DTPDOB.Enabled;
      TabOrder := 11;
    end; // with EdMaskDTP0
  end;


end; // procedure TK_FormCMSASetPatientData.FormShow


//******************************* TK_FormCMSASetPatientData.LbECardNumChange ***
// LbECardNum Change Handler
//
procedure TK_FormCMSASetPatientData.LbECardNumChange(Sender: TObject);
const
  Numeric = ['0'..'9'];
  Alpha = ['A'..'Z', 'a'..'z'];
  AlphaNum = Alpha + Numeric;
var
  WStr : string;
  i, j : Integer;
  IncAlphaChars : Boolean;
//  IPatID : Integer;
begin
//
  i := Length(LbECardNum.Text);
  SetLength( WStr, i );
  if i > 0 then
    FillChar( WStr[1], SizeOf(Char)* i, 0 );
  IncAlphaChars := FALSE;
  j := 1;
  for i := 1 to Length(LbECardNum.Text) do
  begin
{$IF SizeOf(Char) = 2}
    if not CharInSet( LbECardNum.Text[i], AlphaNum ) then Continue;
{$ELSE}
    if not (LbECardNum.Text[i] in AlphaNum) then Continue;
{$IFEND}
    WStr[j] := LbECardNum.Text[i];
{$IF SizeOf(Char) = 2}
    IncAlphaChars := IncAlphaChars or not CharInSet(WStr[j], Numeric);
{$ELSE}
    IncAlphaChars := IncAlphaChars or not (WStr[j] in Numeric);
{$IFEND}
    Inc(j);
  end;
  LbECardNum.MaxLength := 9;
  if IncAlphaChars then
  begin
    LbECardNum.MaxLength := 8;
    if Length(WStr) = 9 then
    begin
      WStr[8] := WStr[9];
      SetLength( WStr, 8 );
    end;
  end; // if IncAlphaChars then
{
  if WStr = '' then
  begin
    WStr := PatSID; // Set Patient ID if empty
    IPatID := StrToIntDef( PatSID, 0 );
    if IPatID < -100 then
      WStr := IntToStr( -100 - IPatID );
  end;
}
  LbECardNum.Text := WStr;
end; // procedure TK_FormCMSASetPatientData.LbECardNumChange

//******************************* TK_FormCMSASetPatientData.DTPDOBChange ***
// DTPDOB Change Handler
//
procedure TK_FormCMSASetPatientData.DTPDOBChange(Sender: TObject);
begin
  if DTPDOB.DateTime = 0 then
    DTPDOB.Format := ' '
  else
    DTPDOB.Format := N_WinFormatSettings.ShortDateFormat;
  LbEAge.Text := GetAgeStr(DTPDOB.DateTime); // Calculate Pat Age

end; // procedure TK_FormCMSASetPatientData.DTPDOBChange

//******************************* TK_FormCMSASetPatientData.GetAgeStr ***
// Calculate Age string from given Date Of Birth
//
function TK_FormCMSASetPatientData.GetAgeStr( TS : TDateTime ) : string;
var
  CurDate : TDateTime;
  IResult : Integer;
  Delta  : Integer;
begin
  Result := '0';
  if TS = 0 then Exit;
  CurDate := Date;
  IResult := YearOf(CurDate) - YearOf(TS);
  Delta := MonthOfTheYear(CurDate) - MonthOfTheYear(TS);
  if (Delta < 0) or
     ((Delta = 0) and (DayOfTheMonth(CurDate) < DayOfTheMonth(TS))) then
    Dec(IResult);
//  IResult := Max(0,IResult);
  Result := '';
  if IResult <= 0 then Exit;
  Result := IntToStr(IResult);
end; // function TK_FormCMSASetPatientData.GetAgeStr

//******************************* TK_FormCMSASetPatientData.EdMaskDTPEnter ***
// EdMaskDTP Enter Handler
//
procedure TK_FormCMSASetPatientData.EdMaskDTPEnter(Sender: TObject);
begin
  TControl(Sender).Visible := FALSE;
  DTPDOB.TabStop := TRUE;
  EdMaskDTP0.TabStop := FALSE;
  ActiveControl := DTPDOB;
end; // procedure TK_FormCMSASetPatientData.EdMaskDTPEnter

//******************************* TK_FormCMSASetPatientData.DTPDOBExit ***
// DTPDOB Exit Handler
//
procedure TK_FormCMSASetPatientData.DTPDOBExit(Sender: TObject);
begin
  if not SrcEmptyDOB or
     ((DTPDOB.DateTime <> SrcDOB) and (LbEAge.Text <> '')) then Exit;
  DTPDOB.TabStop := FALSE;
  EdMaskDTP0.Visible := TRUE;
  EdMaskDTP0.TabStop := TRUE;
end; // procedure TK_FormCMSASetPatientData.DTPDOBExit

//******************************* TK_FormCMSASetPatientData.BtNewProviderClick ***
// BtNewProvider Click Handler
//
procedure TK_FormCMSASetPatientData.BtNewProviderClick(Sender: TObject);
var
  CMSAProviderDBData : TK_CMSAProviderDBData;
  ProvSID : string;
begin
  if not K_CMSASetProviderDataDlg( '', @CMSAProviderDBData ) then Exit;

  with K_CMEDAccess, ProvidersInfo.R do
  begin
{
    if (ARowCount = 2) and
       (PString(PME(0, 1))^ = '1') and
       (PString(PME(1, 1))^ = 'Mediasuite') and
       (PString(PME(2, 1))^ = 'Dentist') and
       (PString(PME(3, 1))^ = 'Dr') then
}
    if (ARowCount = 2) then
      ProvSID := PString(PME(0, 1))^
    else
      ProvSID := '';
    EDASASetOneProviderInfo( ProvSID, @CMSAProviderDBData, FALSE );
  end;

  with CmBDentist do
    ItemIndex := K_CMSAFillProvidersList( Items, ProvSID );
end; // procedure TK_FormCMSASetPatientData.BtNewProviderClick

//******************************* TK_FormCMSASetPatientData.FormCloseQuery ***
// FormCloseQuery Event Handler
//
procedure TK_FormCMSASetPatientData.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (ModalResult <> mrOK) or
            (LbESurname.Text <> '') and
            (LbEFirstname.Text <> '');
  if CanClose then Exit;
  if LbESurname.Text = '' then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLSetFIO1.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'Please enter Surname. Press OK to continue.',
                         mtWarning, [mbOK] );
    ActiveControl := LbESurname;
    Exit;
  end;
  K_CMShowMessageDlg1( K_CML1Form.LLLSetFIO2.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//  'Please enter First name. Press OK to continue.',
                       mtWarning, [mbOK] );
  ActiveControl := LbEFirstname;
end; // procedure TK_FormCMSASetPatientData.FormCloseQuery

//******************************* TK_FormCMSASetPatientData.CmBTitleChange ***
// FormCloseQuery Event Handler
//
procedure TK_FormCMSASetPatientData.CmBTitleChange(Sender: TObject);
var
  Ind : Integer;
begin
  Ind := GetGenderIndByTitle( CmBTitle.Text );
//  CmBGender.Enabled := not ReadOnly and (Ind >= 0);
  CmBGender.Enabled := not ReadOnly and (Ind < 0);
  if Ind >= 0 then
    CmBGender.ItemIndex := Ind;
{
Titles List
0=Dr
1=Master
2=Miss
3=Mr
4=Mrs
5=Ms
6=Prof
7=

Gender F should be automatically allocated to the titles Ms, Mrs, Miss
Gender M should be automatically allocated to the titles Mr, Master
}
end; // procedure TK_FormCMSASetPatientData.CmBTitleChange

//******************************* TK_FormCMSASetPatientData.LbEditControlAutoCapitalExit ***
// TEdit Control Auto Capital Exit Handler
//
procedure TK_FormCMSASetPatientData.LbEditControlAutoCapitalExit(Sender: TObject);
begin
  TEdit(Sender).Text := K_CapitalizeWords( Trim( TEdit(Sender).Text ) );
end; // procedure TK_FormCMSASetPatientData.LbEditControlAutoCapitalExit

//******************************* TK_FormCMSASetPatientData.LbEditControlAutoCapitalKeyDown ***
// TEdit Control Auto Capital Key Down Handler
//
procedure TK_FormCMSASetPatientData.LbEditControlAutoCapitalKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_Return then Exit;
  TEdit(Sender).Text := K_CapitalizeWords( Trim( TEdit(Sender).Text ) );
end; // procedure TK_FormCMSASetPatientData.LbEditControlAutoCapitalKeyDown

//******************************* TK_FormCMSASetPatientData.LbEditControlAllCapitalExit ***
// TEdit Control All Capital Exit Handler
//
procedure TK_FormCMSASetPatientData.LbEditControlAllCapitalExit(Sender: TObject);
var
  WStr : string;
begin
  WStr := Trim(TEdit(Sender).Text);
  if Length(WStr) = 0 then Exit;
  CharUpper( @WStr[1] );
  TEdit(Sender).Text := WStr;
end; // procedure TK_FormCMSASetPatientData.LbEditControlAllCapitalExit

//******************************* TK_FormCMSASetPatientData.LbEditControlAllCapitalKeyDown ***
// TEdit Control All Capital Key Down Handler
//
procedure TK_FormCMSASetPatientData.LbEditControlAllCapitalKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_Return then Exit;
  LbEditControlAllCapitalExit(Sender);
end;

//******************************* TK_FormCMSASetPatientData.GetGenderByTitle ***
// Get Gender name by Title
//
//     Parameters
// ATitle - patient title
// Result - Returns patient gender index: 0 - male, 1 - female, -1 - undefined
//          if gender is not defined by title
//
function TK_FormCMSASetPatientData.GetGenderIndByTitle(
                               const ATitle: string): Integer;
begin
  if CmBMaleTitle.Items.IndexOf(ATitle) >= 0 then
     Result := 0
  else
  if CmBFemaleTitle.Items.IndexOf(ATitle) >= 0 then
     Result := 1
  else
     Result := -1;
end;

//******************************* TK_FormCMSASetPatientData.GetGenderByTitle ***
// Get Gender name by Title
//
//     Parameters
// ATitle - patient title
// Result - Returns patient gender name 1-st letter or empty string
//          if gender is not defined by title
//
function TK_FormCMSASetPatientData.GetGenderTextByTitle(
                               const ATitle: string): string;
var
  Ind : Integer;
begin
  Ind := GetGenderIndByTitle( ATitle );
  Result := '';
  if Ind >= 0 then
    Result := CmBGender.Items[Ind];
end;

end.

