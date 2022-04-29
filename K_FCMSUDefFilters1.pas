unit K_FCMSUDefFilters1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ExtCtrls, ComCtrls, 
  N_BaseF, N_Types,
  K_CM0, K_FrCMTeethChart1;

type
  TK_FormCMSUDefFilters1 = class(TN_BaseForm)
    GbMediaTypes: TGroupBox;
    CmBMediaTypes: TComboBox;
    GbToothAlloc: TGroupBox;
    BtResetChart: TButton;
    Button2: TButton;
    Button1: TButton;
    ActionList1: TActionList;
    aResetChart: TAction;
    aCLoseOK: TAction;
    aCloseCancel: TAction;
    GBUDFProfiles: TGroupBox;
    CmBUDPNames: TComboBox;
    BtAdd: TButton;
    BtMod: TButton;
    BtDel: TButton;
    GBDates: TGroupBox;
    RBDateAll: TRadioButton;
    RBDateRangeF: TRadioButton;
    RBDateRangeA: TRadioButton;
    LbFrom: TLabel;
    LbTo: TLabel;
    ChBOpenSelectedFlag: TCheckBox;
    aSave: TAction;
    aAdd: TAction;
    aDelete: TAction;
    DTPDTakenFrom: TDateTimePicker;
    DTPDTakenTo: TDateTimePicker;
    CmBRangeF: TComboBox;
    CMSTeethChartFrame: TK_FrameCMTeethChart1;
    procedure FormShow(Sender: TObject);
    procedure aResetChartExecute(Sender: TObject);
    procedure aCLoseOKExecute(Sender: TObject);
    procedure aCloseCancelExecute(Sender: TObject);
    procedure RBDateAllClick(Sender: TObject);
    procedure CmBUDPNamesSelect(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CmBUDPNamesKeyPress(Sender: TObject; var Key: Char);
    procedure aDeleteExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure CmBRangeFChange(Sender: TObject);
  private
    { Private declarations }
//    UDFDatesArray : TN_DArray;
    UDFCurFilterName : string;
    UDFCurFilterAttrs : TK_CMSlideFilterAttrs; // pointer to resulting filtering attributes
    UDFEditNameFlag : Boolean;
    UDFNewProfileFlag : Boolean;
    function  UDFCheckProfileName( const ANewName : string ) : Boolean;
    procedure UDFSaveProfile();
    procedure UDFRebuildProfilesList();
    function  UDFEndOfDay( ADay : TDateTime ): TDateTime;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses DateUtils,
     K_CLib0, K_VFunc, K_Script1,
     N_Lib0, N_Lib1, K_CML1F;

//******************************* TK_FormCMSUDefFilters.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSUDefFilters1.FormShow(Sender: TObject);
//var
//  i : Integer;
begin
  inherited;
{
  UDFDatesArray := K_CMEDAccess.EDAGetPatSlidesDates( TRUE );
  for i := 0 to High(UDFDatesArray) do
    CmBDateR1.Items.Add( K_DateTimeToStr( UDFDatesArray[i], 'dd"/"mm"/"yyyy' ) );
  CmBDateR1.ItemIndex := 0;
  CmBDateR2.Items.Assign( CmBDateR1.Items );
  CmBDateR2.ItemIndex := CmBDateR2.Items.Count - 1;
  CmBDateE.Items.Assign( CmBDateR1.Items );
  CmBDateE.ItemIndex := 0;
  if Length(UDFDatesArray) = 0 then
  begin
    RBDateAll.Enabled := FALSE;
    RBDateRangeF.Enabled := FALSE;
    RBDateRangeA.Enabled := FALSE;
  end;
}
  with CmBMediaTypes do
  begin
    K_CMEDAccess.EDAGetAllMediaTypes( Items );
    Items.InsertObject( 0, 'Any', TObject(K_CMFilterAllMTypesVal) );
    ItemIndex := 0;
  end;

  with CmBUDPNames do
  begin
    N_CurMemIni.ReadSection( 'UserMediaFilters', Items );
    ItemIndex := 0;
    CmBUDPNamesSelect(Sender);
    aDelete.Enabled := CmBUDPNames.Items.Count > 1;
  end;
  N_Dump1Str( 'UDFilter Open' );

end; // end of TK_FormCMSUDefFilters.FormShow

//******************************* TK_FormCMSUDefFilters.ResetChartExecute ***
// Reset Teeth Chart Action Execute
//
procedure TK_FormCMSUDefFilters1.aResetChartExecute(Sender: TObject);
begin
  CMSTeethChartFrame.ShowTeethChartState( 0 );
end; // end of TK_FormCMSUDefFilters.ResetChartExecute

//******************************* TK_FormCMSUDefFilters.CloseOKExecute ***
// Form OK Action Execute
//
procedure TK_FormCMSUDefFilters1.aCLoseOKExecute(Sender: TObject);
begin
  aSaveExecute(Sender);

  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormCMSUDefFilters.CloseOKExecute

//******************************* TK_FormCMSUDefFilters.CloseCancelExecute ***
// Form OK Action Execute
//
procedure TK_FormCMSUDefFilters1.aCloseCancelExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
end; // end of TK_FormCMSUDefFilters.CloseCancelExecute

//******************************* TK_FormCMSUDefFilters.RBDateAllClick ***
// RadioButton Click Handler
//
procedure TK_FormCMSUDefFilters1.RBDateAllClick(Sender: TObject);
begin
  if RBDateAll.Checked then
  begin
    RBDateRangeF.Checked := FALSE;
    RBDateRangeA.Checked := FALSE;
    DTPDTakenFrom.Enabled := FALSE;
    DTPDTakenTo.Enabled := FALSE;
    CmBRangeF.Enabled := FALSE;
  end else
  if RBDateRangeA.Checked then
  begin
    RBDateAll.Checked := FALSE;
    RBDateRangeF.Checked := FALSE;
    DTPDTakenFrom.Enabled := TRUE;
    DTPDTakenTo.Enabled := TRUE;
    CmBRangeF.Enabled := FALSE;
  end else
  if RBDateRangeF.Checked then
  begin
    RBDateAll.Checked := FALSE;
    RBDateRangeA.Checked := FALSE;
    CmBRangeF.Enabled := TRUE;
    DTPDTakenFrom.Enabled := FALSE;
    DTPDTakenTo.Enabled := FALSE;
    CmBRangeFChange(Sender);
  end;
end; // end of TK_FormCMSUDefFilters.RBDateAllClick

//******************************* TK_FormCMSUDefFilters.CmBUDPNamesSelect ***
// Profile Names Combobox Select Handler
//
procedure TK_FormCMSUDefFilters1.CmBUDPNamesSelect(Sender: TObject);
var
  WInt : Integer;
{
  procedure SetDatesCmB( CmB : TComboBox; CDate : Double );
  begin
    WInt := -1 + K_IndexOfValueInSortedRArray( CDate, @UDFDatesArray[0],
                    CmB.Items.Count, SizeOf(Double),
                    N_CFuncs.CompOneDouble );

    if WInt < 0 then WInt := 0;

    CmB.ItemIndex := WInt;
  end;
}
begin
  with CmBUDPNames do
    UDFCurFilterName := Items[ItemIndex];
{
  K_LoadSPLDataFromText(UDFCurFilterAttrs, K_GetTypeCodeSafe( 'TK_CMSlideFilterAttrs' ).All,
       N_MemIniToString( 'UserMediaFilters', UDFCurFilterName,
       '<TK_CMSlideFilterAttrs />' ) );
}
  K_CMEDAccess.EDAGetUserDefineMediaFilter( UDFCurFilterName, @UDFCurFilterAttrs );

  with UDFCurFilterAttrs do
  begin
    with CmBMediaTypes do
    begin
      WInt := Items.IndexOfObject( TObject(UDFCurFilterAttrs.FAMediaType) );
      if WInt < 0 then
        WInt := 0;
      ItemIndex := WInt;
    end;

    CMSTeethChartFrame.ShowTeethChartState( UDFCurFilterAttrs.FATeethFlags );

    ChBOpenSelectedFlag.Checked := FAOpenCount <> 0;

    RBDateAll.Checked := FADateMode  = K_sfdsmDatesAll;
    RBDateRangeA.Checked := FADateMode  = K_sfdsmDatesRange;
    RBDateRangeF.Checked := FADateMode  >= K_sfdsmToday;
    DTPDTakenFrom.Enabled := FALSE;
    DTPDTakenTo.Enabled := FALSE;
    CmBRangeF.Enabled := FALSE;

    if not RBDateAll.Enabled then Exit; // Skip Set Dates COntrols

    if RBDateRangeF.Checked then
    begin
      CmBRangeF.ItemIndex := Ord(FADateMode) - Ord(K_sfdsmToday);
      CmBRangeF.Enabled := TRUE;
      CmBRangeFChange(Sender);
//      SetDatesCmB( CmBDateR1, FADate1 )
    end
    else if RBDateRangeA.Checked then
    begin
      DTPDTakenFrom.Enabled := TRUE;
      DTPDTakenTo.Enabled := TRUE;
      DTPDTakenFrom.Date := FADate1;
      DTPDTakenTo.Date   := FADate2;
//      SetDatesCmB( CmBDateR1, FADate1 );
//      SetDatesCmB( CmBDateR2, FADate2 );
    end;
  end; // with UDFPFilterAttrs^ do

end; // end of TK_FormCMSUDefFilters.CmBUDPNamesSelect

procedure TK_FormCMSUDefFilters1.aAddExecute(Sender: TObject);
begin
  with CmBUDPNames do
  begin
    N_CurMemIni.ReadSection( 'UserMediaFilters', Items );
    Text := 'New Filter';
    UDFCurFilterName := 'New Filter';
    SetFocus();
    SelectAll();
    UDFEditNameFlag := TRUE;
    UDFNewProfileFlag := TRUE;
  end;
end;

procedure TK_FormCMSUDefFilters1.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not UDFEditNameFlag;
  if CanClose then
    N_Dump1Str( 'UDFilter Close' );

end;

procedure TK_FormCMSUDefFilters1.CmBUDPNamesKeyPress(Sender: TObject;
  var Key: Char);
begin
  UDFEditNameFlag := TRUE;
  if Key <> Char(VK_Return) then Exit;
// Change New Profile Name New Name
  UDFCheckProfileName(CmBUDPNames.Text);
end;


function TK_FormCMSUDefFilters1.UDFCheckProfileName( const ANewName: string): Boolean;
var
  NewInd, PrevInd : Integer;
label
  NameDulicated, SaveCurProfile;
begin

  Result := FALSE;
  NewInd := CmBUDPNames.Items.IndexOf(ANewName);
  if UDFNewProfileFlag then
  begin
    if NewInd >= 0 then
    begin
NameDulicated:
      K_CMShowMessageDlg( K_CML1Form.LLLUDViewFilters1.Caption,
//        'This profile name already exists. Please enter a new name',
                         mtWarning );
      CmBUDPNames.SetFocus();
      CmBUDPNames.SelectAll();
    end
    else
    begin
SaveCurProfile:
      UDFCurFilterName := ANewName;
      UDFSaveProfile();
      Result := TRUE;
      N_Dump1Str( 'UDFilter Add=' + UDFCurFilterName );
    end;
  end
  else
  if UDFCurFilterName <> ANewName then
  begin
    if NewInd >= 0 then goto NameDulicated;
    N_CurMemIni.DeleteKey( 'UserMediaFilters', UDFCurFilterName );
    PrevInd := CmBUDPNames.Items.IndexOf(UDFCurFilterName);
    CmBUDPNames.Items.Delete( PrevInd );
    goto SaveCurProfile;
  end
  else
    UDFEditNameFlag := FALSE;

end;

//******************************* TK_FormCMSUDefFilters.UDFSaveProfile ***
// Save Current Profile
//
procedure TK_FormCMSUDefFilters1.UDFSaveProfile();
begin
  // Store Controls To Profile Data
  with UDFCurFilterAttrs do
  begin
    FATeethFlags := CMSTeethChartFrame.TCFrTeethChartState;

    with CmBMediaTypes do
      if ItemIndex >=0 then
        FAMediaType := Integer( CmBMediaTypes.Items.Objects[ItemIndex] );

    FAOpenCount := 0;
    if ChBOpenSelectedFlag.Checked then
      FAOpenCount := 4; // Slide to Open after filter apply Counter

{
    if RBDateAll.Enabled then
    begin
    // Skip Change Filter Dates Attributes if SlidesSet is Empty
      if RBDateAll.Checked then
        FADateMode  := K_sfdsmDatesAll
      else if RBDateRangeF.Checked then
      begin
        FADateMode  := K_sfdsmDatesRange;
        FADate1 := UDFDatesArray[CmBDateR1.ItemIndex]; // Get Date From CmBDateR1 current element
        FADate2 := UDFDatesArray[CmBDateR2.ItemIndex] + 1 - 1 / (24 * 3600 * 1000); // Get Get Date Day Last MSec From CmBDateR2 current element
        if FADate2 < FADate1 then
          FADate2 := FADate1 + 1 - 1 / (24 * 3600 * 1000); // // Get Date Day Last MSec
      end
      else if RBDateRangeA.Checked then
      begin
        FADateMode  := K_sfdsmToday;
        FADate1 := UDFDatesArray[CmBDateE.ItemIndex]; // Get Date From CmBDateE
        FADate2 := FADate1 + 1 - 1 / (24 * 3600 * 1000); // Get Date Day Last MSec
      end;
    end;
}
    if RBDateAll.Checked then
      FADateMode  := K_sfdsmDatesAll
    else if RBDateRangeA.Checked then
    begin
      FADateMode  := K_sfdsmDatesRange;
      FADate1 := Int(DTPDTakenFrom.DateTime);
      FADate2 := UDFEndOfDay(DTPDTakenTo.DateTime);
      if FADate2 < FADate1 then
        FADate2 := UDFEndOfDay(FADate1); // // Get Date Day Last MSec
//      FADate1 := UDFDatesArray[CmBDateR1.ItemIndex]; // Get Date From CmBDateR1 current element
//      FADate2 := UDFDatesArray[CmBDateR2.ItemIndex] + 1 - 1 / (24 * 3600 * 1000); // Get Get Date Day Last MSec From CmBDateR2 current element
    end
    else if RBDateRangeF.Checked then
    begin
      FADateMode  := TK_CMSlideFilterDateSelectMode(Byte(Ord(K_sfdsmToday) + CmBRangeF.ItemIndex));
      FADate1 := DTPDTakenFrom.DateTime;
      FADate2 := DTPDTakenTo.DateTime;
//      FADate1 := UDFDatesArray[CmBDateE.ItemIndex]; // Get Date From CmBDateE
//      FADate2 := FADate1 + 1 - 1 / (24 * 3600 * 1000); // Get Date Day Last MSec
    end;
  end;

//    N_Dump1Str( 'UDFilter Close' );
  N_Dump2Str( 'UDFilter Save=' +
              UDFCurFilterName + ': ' +
              K_CMGetViewFilterDumpStr(@UDFCurFilterAttrs) );

  K_CMEDAccess.EDAPutUserDefineMediaFilter( UDFCurFilterName, @UDFCurFilterAttrs );
{
  N_StringToMemIni( 'UserMediaFilters', UDFCurFilterName,
    K_SaveSPLDataToText( UDFCurFilterAttrs, K_GetTypeCodeSafe( 'TK_CMSlideFilterAttrs' ).All ) );
}
  UDFRebuildProfilesList();

  UDFNewProfileFlag := FALSE;
  UDFEditNameFlag := FALSE;

end; // end of TK_FormCMSUDefFilters.UDFSaveProfile

procedure TK_FormCMSUDefFilters1.aDeleteExecute(Sender: TObject);
var
  PrevInd : Integer;
begin

  if ( mrYes <> K_CMShowMessageDlg( format( K_CML1Form.LLLUDViewFilters2.Caption,
//         'Do you confirm that you really want to delete the "%s"?',
         [UDFCurFilterName] ), mtConfirmation, [mbYes, mbNo] ) ) then Exit;

  N_CurMemIni.DeleteKey( 'UserMediaFilters', UDFCurFilterName );
  PrevInd := CmBUDPNames.Items.IndexOf(UDFCurFilterName);
  CmBUDPNames.Items.Delete( PrevInd );
  if PrevInd = CmBUDPNames.Items.Count then
    PrevInd := PrevInd - 1;
    CmBUDPNames.ItemIndex := PrevInd;
  CmBUDPNamesSelect(nil);
  aDelete.Enabled := CmBUDPNames.Items.Count > 1;
  N_Dump1Str( 'UDFilter Del=' + UDFCurFilterName );

end;

procedure TK_FormCMSUDefFilters1.aSaveExecute(Sender: TObject);
begin
  if (CmBUDPNames.Text <> UDFCurFilterName) or UDFNewProfileFlag then
    UDFCheckProfileName( CmBUDPNames.Text )
  else
    UDFSaveProfile();
end;

procedure TK_FormCMSUDefFilters1.UDFRebuildProfilesList;
begin
  K_SortMemIniSection( N_CurMemIni, 'UserMediaFilters' );
  with CmBUDPNames do
  begin
    N_CurMemIni.ReadSection( 'UserMediaFilters',Items );
    ItemIndex := Items.IndexOf(UDFCurFilterName);
    aDelete.Enabled := Items.Count > 1;
    CmBUDPNamesSelect(nil);
  end;

end;

procedure TK_FormCMSUDefFilters1.CmBRangeFChange(Sender: TObject);
var
  AFADate1, AFADate2 : TDateTime;
begin
  K_CMFilterDatesPrepEInterval( TK_CMSlideFilterDateSelectMode(CmBRangeF.ItemIndex + Ord(K_sfdsmToday)),
                                AFADate1, AFADate2 );
  DTPDTakenFrom.DateTime := AFADate1;
  DTPDTakenTo.DateTime := AFADate2;
end;

function TK_FormCMSUDefFilters1.UDFEndOfDay(ADay: TDateTime): TDateTime;
begin
  Result := Int(ADay) + 1 - 1 / (24 * 3600 * 1000); // // Get Date Day Last MSec
end;

end.
