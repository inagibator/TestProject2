unit K_FCMSASelectPat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, ActnList, N_Rast1Fr, Buttons, Types,
  K_CM0,
  N_BaseF, N_Types, N_DGrid;

type
  TK_FormCMSASelectPatient = class(TN_BaseForm)
    BtOK: TButton;
    BtCancel: TButton;
    LbECardNum: TLabeledEdit;
    LbESurname: TLabeledEdit;
    LbEFirstname: TLabeledEdit;
    SGPatients: TStringGrid;
    ActionList1: TActionList;
    aAddPatient: TAction;
    aModifyPatient: TAction;
    aDeletePatient: TAction;
    BtAdd: TButton;
    BtModify: TButton;
    BtDelete: TButton;
    SpeedButton0: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    aReorderPatients: TAction;
    aRestorePatient: TAction;
    aDeletePatientForever: TAction;
    PnThumbs: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LbECardNumChange(Sender: TObject);
    procedure SGPatientsDblClick(Sender: TObject);
    procedure aReorderPatientsExecute(Sender: TObject);
    procedure aAddPatientExecute(Sender: TObject);
    procedure aModifyPatientExecute(Sender: TObject);
    procedure aDeletePatientExecute(Sender: TObject);
    procedure SGPatientsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure aRestorePatientExecute(Sender: TObject);
    procedure aDeletePatientForeverExecute(Sender: TObject);
    procedure SGPatientsTopLeftChanged(Sender: TObject);
  private
    { Private declarations }
    SkipSGSelectCell : Boolean;
    DelPatSID : string;
    procedure BuildFilteredInds();
    procedure BuildReorderedInds();
    procedure RebuildPatientsListView();
    procedure SetSelection();
    function  GetPatientData( APCMSAPatientDBData : TK_PCMSAPatientDBData; ALockOnly : Boolean ) : Boolean;
    procedure DeleteCurPatientInfo();
    procedure RebuildControlsView( ACurPatInd : Integer );
    function  GetCurPatientsInfoIndex( ) : Integer;
    procedure SetCurPatientSyncState( );
  public
    { Public declarations }
    UserSelectedPatSID : string;
    PatSID : string;
    PrevPatSID : string;
    SrcPatSID : string;
    ThumbsDGrid: TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
    OrderedInds : TN_IArray;
    FilteredInds: TN_IArray;
    PatientsOrderStrings: TN_SArray;
    PatientSlidesArray : TN_UDCMSArray;
    SkipUnselectPatControl : Boolean;
    procedure GetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure DrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
    procedure ClearPrevPatSlides();
  end;

var
  K_FormCMSASelectPatient: TK_FormCMSASelectPatient;

function  K_CMSASelectPatientDlg( var APatSID : string; AShowDelFlag : Boolean;
                                  ASkipUnselectPatControl : Boolean ) : Boolean;

implementation

{$R *.dfm}
uses Math,
N_CMMain5F, N_CMResF, N_CM1, N_CM2, N_Comp1, N_Lib0,
K_CLib0, K_Script1, K_VFunc, K_FCMSASetPatData, K_CML1F;

//***************************************************** K_CMSASelectPatientDlg ***
// Set CMS Standalone Patient Data Dialog
//
//     Parameters
// APatSID - Patient ID string
// AShowDelFlag - Show marked as deleted Patients
// Result - Returns FALSE if user do not click OK
//
// If source APatSID value is differed from "", then Patient with given Code
// should be highlighted as selected, else no Patient should be selected.
// Resulting APatID if Result value is TRUE contains Selected Patient Code string
//
function  K_CMSASelectPatientDlg( var APatSID : string; AShowDelFlag : Boolean;
                                  ASkipUnselectPatControl : Boolean ) : Boolean;
var
  StudyOnlyThumbsShowGUIModeFlag : Boolean;
  ShowArchivedSlidesFlag : Boolean;

begin
  StudyOnlyThumbsShowGUIModeFlag := K_CMStudyOnlyThumbsShowGUIModeFlag;
  K_CMStudyOnlyThumbsShowGUIModeFlag := FALSE;
  ShowArchivedSlidesFlag := K_CMShowArchivedSlidesFlag;
  K_CMShowArchivedSlidesFlag := FALSE;

  with TK_FormCMSASelectPatient.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    SrcPatSID := APatSID;
    if AShowDelFlag then
    begin
      BtAdd.Action := aRestorePatient;
      aDeletePatientForever.Enabled := K_CMGAModeFlag;
      BtModify.Action := aDeletePatientForever;
      BtDelete.Visible := False;
      BtOK.Visible := False;
      BtCancel.Caption := BtOK.Caption; // '&OK'
//      ThumbsRFrame.Visible := False;
      SrcPatSID := '';
    end;
    PatSID := SrcPatSID;
    UserSelectedPatSID := SrcPatSID;
    K_CMEDAccess.EDASAGetPatientsInfo( AShowDelFlag );


    aAddPatient.Enabled := K_CMStandaloneMode <> K_cmsaLink;
    if not aAddPatient.Enabled then
       aModifyPatient.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';

    N_Dump1Str( 'SelectPatientDlg Start ID=' + APatSID );
    SkipUnselectPatControl := ASkipUnselectPatControl;
    Result := ShowModal() = mrOK;
    ThumbsRFrame.RFFreeObjects();
    ThumbsDGrid.Free();
//    K_CMEDAccess.EDASAGetPatientsInfo( FALSE ); ???
    K_CMEDAccess.EDASAGetPatientsInfo( AShowDelFlag ); // 2013-08-27
    if Result then
      APatSID := PatSID;
    N_Dump1Str( 'SelectPatientDlg Fin ID=' + APatSID );
  end;
  K_CMStudyOnlyThumbsShowGUIModeFlag := StudyOnlyThumbsShowGUIModeFlag;
  K_CMShowArchivedSlidesFlag := ShowArchivedSlidesFlag;

end; // function K_CMSASelectPatientDlg

//******************************* TK_FormCMSASelectPatient.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSASelectPatient.FormShow(Sender: TObject);
begin
  inherited;

  SGPatients.ColWidths[0] := LbESurname.Left - LbECardNum.Left;
  SGPatients.ColWidths[1] := LbEFirstname.Left - LbESurname.Left;
  SGPatients.ColWidths[2] := SGPatients.Width -
                             SGPatients.ColWidths[0] - SGPatients.ColWidths[1] - 6;

  ThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, GetThumbSize );
  with ThumbsDGrid do
  begin
    DGBaseMatrRFA.ActEnabled := FALSE;
    DGEdges := Rect( 2, 2, 2, 2 );
    DGGaps  := Point( 2, 2 );
    DGScrollMargins := Rect( 8, 8, 8, 8 );

    DGLFixNumCols   := 1;
    DGLFixNumRows   := 0;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;
//    DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
    DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

    DGBackColor     := ColorToRGB( clBtnFace );
    DGMarkBordColor := N_CM_SlideMarkColor;
    DGMarkNormWidth := 2;
    DGMarkNormShift := 2;

    DGNormBordColor := DGBackColor;
    DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
    DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

    DGLAddDySize    := 14; // see DGLItemsAspect   - 2 Text Lines

    DGDrawItemProcObj := DrawThumb;
//    DGExtExecProcObj  := N_CMResForm.ThumbsRFrameExecute;

    ThumbsRFrame.DstBackColor := DGBackColor;
    ThumbsRFrame.RFDebName := 'Thumbs';
    Windows.SetStretchBltMode( ThumbsRFrame.OCanv.HMDC, HALFTONE );
    ThumbsRFrame.RedrawAllAndShow;
  end; // with ThumbsDGrid do

  BuildFilteredInds();

  BuildReorderedInds();

  RebuildPatientsListView();

end; // procedure TK_FormCMSASelectPatient.FormShow

//******************************* TK_FormCMSASelectPatient.FormCloseQuery ***
// Form Close Query Handler
//
procedure TK_FormCMSASelectPatient.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  CurPatInd : Integer;
begin
  if ModalResult = mrOK then
  begin
    CanClose := PatSID <> '';
    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelPat1.Caption,
//      'Patient is not selected. Select Patient before exit.',
                         mtWarning, [mbOK] );
  end
  else
  if (BtAdd.Action = aAddPatient) and
     not SkipUnselectPatControl then
  begin // Existing (not marked as deleted) Patients Dialog
    with K_CMEDAccess, PatientsInfo.R do
    begin
      CurPatInd := K_IndexOfStringInRArray( SrcPatSID,
                                                PME( 0, 1),
                                                ARowCount - 1,
                                                ElemSize * AColCount );
      CanClose := CurPatInd >= 0;
    end;
    if not CanClose then
      K_CMShowMessageDlg( K_CML1Form.LLLSelPat2.Caption,
//      'Current Media Suite Patient was deleted. Select new current Patient.',
                           mtWarning, [mbOK] )
  end;
  ClearPrevPatSlides();

end; // procedure TK_FormCMSASelectPatient.FormCloseQuery

//******************************* TK_FormCMSASelectPatient.LbECardNumChange ***
// Patients Filter Controls Change Handler
//
procedure TK_FormCMSASelectPatient.LbECardNumChange(Sender: TObject);
begin
  if not TLabeledEdit(Sender).Modified then Exit;
  BuildFilteredInds();
  BuildReorderedInds();
  RebuildPatientsListView();
end; // procedure TK_FormCMSASelectPatient.LbECardNumChange

//******************************* TK_FormCMSASelectPatient.SGPatientsDblClick ***
// Patients List Double Click Handler
//
procedure TK_FormCMSASelectPatient.SGPatientsDblClick(Sender: TObject);
begin
  if PatSID = '' then Exit; // precaution
  N_Dump2Str( 'K_FCMSASelectPat.SGPatientsDblClick ID=' + PatSID );
  ModalResult := mrOK;
end; // procedure TK_FormCMSASelectPatient.SGPatientsClick

//**************************************** TK_FormCMSASelectPatient.GetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one field (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of ThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMSASelectPatient.GetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbUDDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with ADGObj do
  begin
    Slide := PatientSlidesArray[AInd];
    ThumbUDDIB := Slide.GetThumbnail();
    ThumbSize := ThumbUDDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TK_FormCMSASelectPatient.GetThumbSize

//************************************** TK_FormCMSASelectPatient.DrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel ad may be not equal to upper left Grid pixel )
//
// Is used as value of ThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMSASelectPatient.DrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  Slide : TN_UDCMSlide;
  LinesCount : Integer;
begin
  with N_CM_GlobObj do
  begin
    Slide := PatientSlidesArray[AInd];

    LinesCount := 0;
    with Slide.P^ do
    begin
      CMStringsToDraw[LinesCount] := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
      Inc(LinesCount);
    end;
    TN_CMDrawSlideObj(nil).DrawOneThumb6( Slide,
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               ADGObj.DGItemsFlags[AInd] );

  end; // with N_CM_GlobObj do
end; // procedure TK_FormCMSASelectPatient.DrawThumb

//***************************** TK_FormCMSASelectPatient.ClearPrevPatSlides ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
procedure TK_FormCMSASelectPatient.ClearPrevPatSlides();
var
  i : Integer;

begin
  if K_CMEDAccess is TK_CMEDDBAccess then
    for i := 0 to High(PatientSlidesArray) do
      PatientSlidesArray[i].UDDelete();

end; // procedure TK_FormCMSASelectPatient.ClearPrevPatSlides

//***************************** TK_FormCMSASelectPatient.BuildFilteredInds ***
// Rebuild Patients Filtered Indexes
//
procedure TK_FormCMSASelectPatient.BuildFilteredInds;
var
  i, j : Integer;
begin
  N_Dump2Str( format('K_FCMSASelectPat.BuildFilteredInds F1=%s F2=%s F3=%s',
              [LbECardNum.Text,LbESurname.Text,LbEFirstname.Text]) );
  with K_CMEDAccess do
  begin
  //
    SetLength( FilteredInds, PatientsInfo.R.ARowCount - 1 );
    j := 0;
    for i := 1 to PatientsInfo.R.ARowCount - 1 do
    begin
      if (LbECardNum.Text <> '') and
          not K_StrStartsWith( LbECardNum.Text, PString(PatientsInfo.R.PME( 1, i ))^, TRUE ) then Continue;
      if (LbESurname.Text <> '') and
          not K_StrStartsWith( LbESurname.Text, PString(PatientsInfo.R.PME( 3, i ))^, TRUE ) then Continue;
      if (LbEFirstname.Text <> '') and
          not K_StrStartsWith( LbEFirstname.Text, PString(PatientsInfo.R.PME( 2, i ))^, TRUE ) then Continue;
      FilteredInds[j] := i;
      Inc(j);
    end;
    SetLength( FilteredInds, j );
  end;
  OrderedInds := Copy(FilteredInds);
end; // procedure TK_FormCMSASelectPatient.BuildFilteredInds;

//***************************** TK_FormCMSASelectPatient.RebuildPatientsListView ***
// Rebuild Patients View
//
procedure TK_FormCMSASelectPatient.RebuildPatientsListView;
var
  i, Ind : Integer;
  GR : TGridRect;
begin
  SkipSGSelectCell := TRUE;

// SGPatients Exception Precation while change SGPatients.RowCount
  FillChar( GR, SizeOf(GR), 0 );
  GR.Right := 2;
  SGPatients.Selection := GR;

  SGPatients.RowCount := Length(OrderedInds);
  SGPatients.Enabled := Length(OrderedInds) <> 0;
  if not SGPatients.Enabled then
  begin
//    PatSID := '';
    SGPatients.Options := SGPatients.Options - [goVertLine];
  end;

  SGPatients.Cells[0,0] := '';
  SGPatients.Cells[1,0] := '';
  SGPatients.Cells[2,0] := '';
  for i := 0 to High(OrderedInds) do
    with K_CMEDAccess, PatientsInfo.R do
    begin
      Ind := OrderedInds[i];
      SGPatients.Cells[0,i] := PString(PME(1, Ind))^; // Card Number
      SGPatients.Cells[1,i] := PString(PME(3, Ind))^; // Surname
      SGPatients.Cells[2,i] := PString(PME(2, Ind))^; // First Name
    end;

  SetSelection();
  SkipSGSelectCell := FALSE;
end; // procedure TK_FormCMSASelectPatient.RebuildPatientsListView;

//***************************** TK_FormCMSASelectPatient.BuildReorderedInds ***
// Rebuild Patients Order Indexes
//
procedure TK_FormCMSASelectPatient.BuildReorderedInds;
var
  i, ICount, ColInd : Integer;
  PtrsArray : TN_PArray;
begin

  PtrsArray := nil;
  ColInd := 0;
  if SpeedButton0.Down then
  begin
    ColInd := 1;
    N_Dump2Str( 'K_FCMSASelectPat.BuildReorderedInds 1' );
  end
  else if SpeedButton1.Down then
  begin
    ColInd := 3;
    N_Dump2Str( 'K_FCMSASelectPat.BuildReorderedInds 2' );
  end
  else if SpeedButton2.Down then
  begin
    ColInd := 2;
    N_Dump2Str( 'K_FCMSASelectPat.BuildReorderedInds 3' );
  end;
  if ColInd = 0 then Exit;

  with K_CMEDAccess do
  begin
  // Get Patient Strings to Order
    ICount := Length(FilteredInds);
    if ICount = 0 then Exit;

  // Reorder By Data
    SetLength( PatientsOrderStrings, ICount );
    with PatientsInfo.R do
      K_MoveSPLVectorBySIndex( PatientsOrderStrings[0], SizeOf(string),
               PString(PME( ColInd, 0 ))^, SizeOf(string) * AColCount(),
               ICount,  Ord(nptString), [], @FilteredInds[0] );

  // Get Patient Strings to Sort Idexes
    PtrsArray := N_GetPtrsArrayToElems( @PatientsOrderStrings[0], ICount, SizeOf(string) );
    N_CFuncs.Offset := 0;
    N_CFuncs.DescOrder := FALSE;
    N_SortPointers( PtrsArray, N_CFuncs.CompOneStr );
    SetLength( OrderedInds, ICount );
    N_PtrsArrayToElemInds( @OrderedInds[0], PtrsArray, @PatientsOrderStrings[0], SizeOf(string) );


  // Get Biuld Patients Real Data Order Indexes
    for i := 0 to High(OrderedInds) do
      OrderedInds[i] := FilteredInds[OrderedInds[i]];

  end;
end; // procedure TK_FormCMSASelectPatient.BuildReorderedInds;

//************************ TK_FormCMSASelectPatient.aReorderPatientsExecute ***
// Reorder Patients List Action Execute
//
procedure TK_FormCMSASelectPatient.aReorderPatientsExecute( Sender: TObject);
begin
  N_Dump2Str( 'K_FCMSASelectPat.aReorderPatients start' );
  BuildReorderedInds();
  RebuildPatientsListView();
end; // procedure TK_FormCMSASelectPatient.aReorderPatientsExecute

//***************************** TK_FormCMSASelectPatient.aAddPatientExecute ***
// Add New Patient Action Execute
//
procedure TK_FormCMSASelectPatient.aAddPatientExecute(Sender: TObject);
var
  CMSAPatientDBData : TK_CMSAPatientDBData;
label SetPatientData;
begin
  inherited;
  N_Dump2Str( 'K_FCMSASelectPat.aAddPatient start' );
  ZeroMemory( @CMSAPatientDBData, SizeOf(TK_CMSAPatientDBData) );
  CMSAPatientDBData.APIsPMSSync := FALSE;
  K_CMEDAccess.EDASAGetProvidersInfo( FALSE ); // Update Current Providers State before Patients Editing

SetPatientData:
  if not K_CMSASetPatientDataDlg( '', @CMSAPatientDBData ) then Exit;
  PatSID := '';
  if (CMSAPatientDBData.APCardNum <> '') and
     (K_edOK <> K_CMEDAccess.EDASACheckPatientCardNum( PatSID, CMSAPatientDBData.APCardNum )) then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat3.Caption,
//    'Patient Card Number is not unique. Type a unique number or clear the Card Number field for auto card number insert.',
                         mtWarning, [mbOK] );
    goto SetPatientData;
  end;

  K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @CMSAPatientDBData, FALSE );

  LbECardNum.Text := '';
  LbESurname.Text := '';
  LbEFirstname.Text := '';
  BuildFilteredInds();

  BuildReorderedInds();

  RebuildPatientsListView();

  ActiveControl := BtOK;

  N_Dump1Str( 'K_FCMSASelectPat.aAddPatient fin ID=' + PatSID );
//
end; // procedure TK_FormCMSASelectPatient.aAddPatientExecute

//***************************** TK_FormCMSASelectPatient.aModifyPatientExecute ***
// Modify Selected Patient Action Execute
//
procedure TK_FormCMSASelectPatient.aModifyPatientExecute(Sender: TObject);
var
  CMSAPatientDBData : TK_CMSAPatientDBData;
  SkipFieldsSet : Boolean;
label SetPatientData;
begin

  if PatSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectPat.aModifyPatient start ID=' + PatSID );
  if not GetPatientData( @CMSAPatientDBData, FALSE ) then Exit;

  K_CMEDAccess.EDASAGetProvidersInfo( FALSE ); // Update Current Providers State before Patients Editing


  if CMSAPatientDBData.APIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) and
     aDeletePatient.Enabled then
  begin
// Rebuild Interface if start modify object
// which was unsync with PMS and now is detected as sync to PMS
    SetCurPatientSyncState();
  end;

  // Free Lock if ReadOnly Mode
  if CMSAPatientDBData.APIsLocked and
     ( (K_CMStandaloneMode = K_cmsaLink) or
       ( CMSAPatientDBData.APIsPMSSync and
         (K_CMStandaloneMode = K_cmsaHybrid) ) ) then
  begin
  // Clear Patient Lock
    K_CMEDAccess.EDASASetOnePatientInfo( PatSID, nil, TRUE );
    CMSAPatientDBData.APIsLocked := FALSE;
  end;

  if (aModifyPatient.Caption <> K_CML1Form.LLLSADialogs6.Caption) and
     not CMSAPatientDBData.APIsLocked then
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat4.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'Selected patient is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );

  K_CMEDAccess.EDASAGetProvidersInfo( FALSE ); // Update Current Providers State before Patients Editing

SetPatientData:
  SkipFieldsSet := not K_CMSASetPatientDataDlg( PatSID, @CMSAPatientDBData );

  if not SkipFieldsSet and
     (K_edOK <> K_CMEDAccess.EDASACheckPatientCardNum( PatSID, CMSAPatientDBData.APCardNum )) then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat3.Caption,
//    'Patient Card Number is not unique. Type a unique number or clear the Card Number field for auto card number insert.',
                         mtWarning, [mbOK] );
    goto SetPatientData;
  end;

  // Change Locked State to Correct Actions after editing
  K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @CMSAPatientDBData, SkipFieldsSet );

  // Rebuild Patients List. Needed even when Patients Data was not changed by user,
  // but it can be changed before by some other user

  BuildFilteredInds();

  BuildReorderedInds();

  RebuildPatientsListView();

  ActiveControl := BtOK;

  N_Dump1Str( 'K_FCMSASelectPat.aModifyPatient fin ID=' + PatSID );
end; // procedure TK_FormCMSASelectPatient.aModifyPatientExecute

//***************************** TK_FormCMSASelectPatient.aDeletePatientExecute ***
// Delete Selected Patient Action Execute
//
procedure TK_FormCMSASelectPatient.aDeletePatientExecute(Sender: TObject);
var
  CMSAPatientDBData : TK_CMSAPatientDBData;
  DataInd : Integer;
  CurPatInd: Integer;
begin
  if PatSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectPat.aDeletePatient start ID=' + PatSID );
  if not GetPatientData( @CMSAPatientDBData, TRUE ) then Exit;

  if CMSAPatientDBData.APIsPMSSync and
     (K_CMStandaloneMode = K_cmsaHybrid) then
  begin
    K_CMEDAccess.EDASASetOnePatientInfo( PatSID, nil, TRUE );

    SetCurPatientSyncState();

    K_CMShowMessageDlg( K_CML1Form.LLLSelPat5.Caption,
//    'This patient couldn''t be deleted. It is linked to corresponding Practice Management System object.',
                           mtWarning, [mbOK] );
    Exit;
  end;

  if not CMSAPatientDBData.APIsLocked then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat6.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This patient is now being edited by other user. Press OK to continue.',
                         mtWarning, [mbOK] );
    Exit;
  end;

  with K_CMEDAccess, PatientsInfo.R do
    CurPatInd := 1 + K_IndexOfStringInRArray( PatSID,
                                              PME( 0, 1),
                                              ARowCount - 1,
                                              ElemSize * AColCount );
  DataInd := SGPatients.Selection.Top;
  if mrYes <> K_CMShowMessageDlg(
      format( K_CML1Form.LLLSelPat7.Caption + #13#10 +
              '                   ' + K_CML1Form.LLLPressYesToProceed.Caption,
//              'Please confirm you wish to delete patient %s %s %s'#13#10 +
//              '                   Select Yes to proceed.',
              [PString(K_CMEDAccess.PatientsInfo.R.PME(4,CurPatInd))^,
               SGPatients.Cells[2,DataInd],
               SGPatients.Cells[1,DataInd]] ),
      mtConfirmation, [mbYes,mbNo] ) then
  begin
    K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @CMSAPatientDBData, TRUE );
    Exit;
  end;
  // Mark Patient as deleted
//  K_CMEDAccess.EDASAMarkPatientAsDel( PatSID );
  K_CMEDAccess.EDASASetClearPatientDelState( PatSID, '1' );

  // Remove Patient from PatientsInfo
  DeleteCurPatientInfo();
  N_Dump1Str( 'K_FCMSASelectPat.aDeletePatient fin ID=' + DelPatSID );
//
end; // procedure TK_FormCMSASelectPatient.aDeletePatientExecute

//***************************** TK_FormCMSASelectPatient.aRestorePatientExecute ***
// Restore Deleted Patient Action Execute
//
procedure TK_FormCMSASelectPatient.aRestorePatientExecute(Sender: TObject);
var
  CMSAPatientDBData : TK_CMSAPatientDBData;
  DelPatFlag : Boolean;
begin
  if PatSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectPat.aRestorePatient start ID=' + PatSID );
  DelPatFlag := K_edOK <> K_CMEDAccess.EDASAGetOnePatientInfo( PatSID, @CMSAPatientDBData, [K_cmsagiLockOnly] );

  if DelPatFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This patient has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSAPatientDBData.APIsLocked then
    // Clear Mark Patient as deleted flag and unlock
    K_CMEDAccess.EDASASetClearPatientDelState( PatSID, '0' )
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat9.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This patient is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;

//  ClearPrevPatSlides();
//  PatientSlidesArray := nil;
  // Remove Patient from PatientsInfo
  UserSelectedPatSID := '';
  DeleteCurPatientInfo();

  ActiveControl := BtCancel;


  N_Dump1Str( 'K_FCMSASelectPat.aRestorePatient fin ID=' + DelPatSID );
end; // procedure TK_FormCMSASelectPatient.aRestorePatientExecute

//***************************** TK_FormCMSASelectPatient.aDeletePatientForeverExecute ***
// Delete Patient forever Action Execute
//
procedure TK_FormCMSASelectPatient.aDeletePatientForeverExecute( Sender: TObject);
var
  DataInd : Integer;
  CurPatInd : Integer;
  CMSAPatientDBData : TK_CMSAPatientDBData;
  DelPatFlag : Boolean;
begin
  if PatSID = '' then Exit; // precaution

  N_Dump1Str( 'K_FCMSASelectPat.aDeletePatientForever start ID=' + PatSID );
  DelPatFlag := K_edOK <> K_CMEDAccess.EDASAGetOnePatientInfo( PatSID, @CMSAPatientDBData, [K_cmsagiLockOnly] );

  if DelPatFlag then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This patient has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
  end
  else
  if CMSAPatientDBData.APIsLocked then
  begin
    if CMSAPatientDBData.APDBFlags = 1 then
    begin
      // Delete Forever
      DataInd := SGPatients.Selection.Top;
      with K_CMEDAccess, PatientsInfo.R do
        CurPatInd := 1 + K_IndexOfStringInRArray( PatSID,
                                                  PME( 0, 1),
                                                  ARowCount - 1,
                                                  ElemSize * AColCount );
      if mrYes <> K_CMShowMessageDlg(
          format( K_CML1Form.LLLSelPat10.Caption + #13#10 +
                  '          ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLPressYesToProceed.Caption,
//                  'Please confirm you wish to permanently delete patient %s %s %s'#13#10 +
//                  '          This action is irreversible. Select Yes to proceed.',
              [PString(K_CMEDAccess.PatientsInfo.R.PME(4,CurPatInd))^,
               SGPatients.Cells[2,DataInd],
               SGPatients.Cells[1,DataInd]] ),
          mtConfirmation, [mbYes,mbNo] ) then
      begin
        K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @CMSAPatientDBData, TRUE );
        Exit;
      end;

      // Mark Patient as deleted and Unlock
      K_CMEDAccess.EDASASetClearPatientDelState( PatSID, '2' );
      K_CMEDAccess.EDASADelOnePatientSlides( PatSID );
    end
    else
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLSelPat11.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//      'This patient has been already restored by other user. Press OK to continue.',
                       mtWarning, [mbOK] );
      // Unlock
      K_CMEDAccess.EDASASetOnePatientInfo( PatSID, @CMSAPatientDBData, TRUE );
    end
  end
  else
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLSelPat9.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//    'This patient is controled by other user now. Press OK to continue.',
                       mtWarning, [mbOK] );
    Exit;
  end;


  // Remove Patient from PatientsInfo
  DeleteCurPatientInfo();

  ActiveControl := BtCancel;

  N_Dump1Str( 'K_FCMSASelectPat.aDeletePatientForever fin ID=' + DelPatSID );
//
end; // procedure TK_FormCMSASelectPatient.aDeletePatientForeverExecute

//***************************** TK_FormCMSASelectPatient.SGPatientsSelectCell ***
// SGPatients SelectCell Handler
//
procedure TK_FormCMSASelectPatient.SGPatientsSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
//var
//  GR : TGridRect;
begin
  if (Length(OrderedInds) = 0) or SkipSGSelectCell then Exit; // Precaution

  N_Dump2Str( format( 'K_FCMSASelectPat.SGPatientsSelectCell x=%d y=%d',[ACol, ARow]) );

  with K_CMEDAccess, PatientsInfo.R do
    PatSID := PString(PME(0, OrderedInds[ARow]))^;

  if PatSID = '' then Exit; // precaution
  UserSelectedPatSID := PatSID;
  SetSelection();
end;

//***************************** TK_FormCMSASelectPatient.SetSelection ***
// Set Patients List New Selection
//
procedure TK_FormCMSASelectPatient.SetSelection;
var
  GR : TGridRect;
  CurPatInd : Integer;
  WSlidesArray : TN_UDCMSArray;
  StudiesCount : Integer;
//  SkipEditDate : Boolean;

begin
  GR.Left := -1;
  GR.Right := -1;
  GR.Bottom := -1;
  GR.Top := -1;
  if UserSelectedPatSID <> PatSID then
    PatSID := UserSelectedPatSID;
  if (PatSID <> '') and (Length(OrderedInds) > 0) then
  begin
    CurPatInd := GetCurPatientsInfoIndex();
    RebuildControlsView( CurPatInd );
    CurPatInd := K_IndexOfIntegerInRArray( CurPatInd,
                                           @OrderedInds[0],
                                           Length(OrderedInds) );
//    if CurPatInd = -1 then CurPatInd := 0; // Else error - List index out of bounds (-1)
{
    with K_CMEDAccess, PatientsInfo.R do
    begin
      CurPatInd := 1 + Max( 0, K_IndexOfStringInRArray( PatSID,
                                                PME( 0, 1),
                                                ARowCount - 1,
                                                ElemSize * AColCount ) );
      PatSID := PString(PME( 0, CurPatInd))^;
      SkipEditDate := (K_CMStandaloneMode = cmsaLink) or
                      ( (K_CMStandaloneMode = cmsaHybrid) and  // not (Synchronized Provider in Hybrid StandaloneMode
                       (PString(PME(7, CurPatInd))^ = '1') );
      aModifyPatient.Caption := K_CML1Form.LLLSADialogs7.Caption; // '&Modify';
      if SkipEditDate then
        aModifyPatient.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';
      aDeletePatient.Enabled := not SkipEditDate and (ArowCount() > 2);
      aRestorePatient.Enabled := not SkipEditDate;
      aDeletePatientForever.Enabled := not SkipEditDate and K_CMGAModeFlag;

      CurPatInd := K_IndexOfIntegerInRArray( CurPatInd, @OrderedInds[0],
                                             Length(OrderedInds) );

    end;
}
    GR.Left := 0;
    GR.Right := 2;
    if CurPatInd = -1 then
    begin// Else error - List index out of bounds (-1)
      GR.Bottom := 0;
      GR.Top := 0;
      PatSID := PString(K_CMEDAccess.PatientsInfo.R.PME( 0, OrderedInds[0]))^;
    end
    else
    begin
      GR.Bottom := CurPatInd;
      GR.Top := CurPatInd;
    end;

    // Scroll List by Selection
    with SGPatients do
    if ( (TopRow > GR.Top) or
         (TopRow + VisibleRowCount < GR.Bottom ) ) then
    begin
      if TopRow + VisibleRowCount < GR.Bottom then
         TopRow := GR.Bottom - VisibleRowCount + 1;
      if TopRow > GR.Top then TopRow := GR.Top;
    end;
{
    if (TopRow > 0) and
       ( (TopRow > GR.Top) or
         (TopRow + VisibleRowCount < GR.Bottom ) ) then
    begin
      if TopRow + VisibleRowCount < GR.Bottom then
         TopRow := GR.Bottom - VisibleRowCount + 1;
      if TopRow > GR.Top then TopRow := GR.Top;
    end;
}
//    SGPatients.Options := SGPatients.Options + [goRowSelect];

    BtOK.Enabled := TRUE;
    aModifyPatient.Enabled := TRUE;
  end
  else
  begin
    aModifyPatient.Enabled := FALSE;
    aDeletePatient.Enabled := FALSE;
    aRestorePatient.Enabled := FALSE;
    aDeletePatientForever.Enabled := FALSE;
    BtOK.Enabled := (BtAdd.Action = aRestorePatient); // State enabled if marked as deleted are processed
//    SGPatients.Selection := GR;
  end;


  if (PrevPatSID <> PatSID) or (PrevPatSID = '') then
  begin
    ClearPrevPatSlides();
    WSlidesArray := nil;
    K_CMEDAccess.EDASAGetPatientSlidesView( PatSID, WSlidesArray );

    if PatSID = '' then
      PatientSlidesArray := nil
    else
    begin
      if Length(WSlidesArray) > 0 then
        K_CMRebuildSlidesArrayByFilter( @WSlidesArray[0], Length(WSlidesArray),
                                        PatientSlidesArray, StudiesCount, nil,
                                        K_CMEDAccess is TK_CMEDDBAccess )
      else
        PatientSlidesArray := nil;
    end;

    PrevPatSID := PatSID;
    ThumbsDGrid.DGNumItems := Length(PatientSlidesArray); // Number of visible Thumbnails
    ThumbsDGrid.DGInitRFrame();
    ThumbsRFrame.RedrawAllAndShow();
  end;


  if SGPatients.Enabled and (SGPatients.Row >= 0) then
  begin
//    SGPatients.Row := GR.Top;
    SGPatients.Options := SGPatients.Options + [goVertLine];
  end;

  SGPatients.Options := SGPatients.Options + [goRowSelect];
  SGPatients.Selection := GR;

end; // procedure TK_FormCMSASelectPatient.SetSelection

//***************************** TK_FormCMSASelectPatient.GetPatientData ***
// Get Patients Data
//
function TK_FormCMSASelectPatient.GetPatientData( APCMSAPatientDBData : TK_PCMSAPatientDBData; ALockOnly : Boolean ) : Boolean;
var
  GIFlags : TK_CMSAGetInfoFlags;
begin
  GIFlags := [];
  if ALockOnly then
    GIFlags := [K_cmsagiLockOnly];
  Result := K_edOK = K_CMEDAccess.EDASAGetOnePatientInfo( PatSID, APCMSAPatientDBData, GIFlags );
  Result := Result and (APCMSAPatientDBData.APDBFlags = 0);
  if Result then Exit;
  // Show Warning
  K_CMShowMessageDlg( K_CML1Form.LLLSelPat8.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//  'This patient has been already deleted by other user. Press OK to continue.',
                       mtWarning, [mbOK] );

  // Remove Patient from PatientsInfo
  DeleteCurPatientInfo();

end; // procedure TK_FormCMSASelectPatient.GetPatientData


//***************************** TK_FormCMSASelectPatient.DeleteCurPatientInfo ***
// Delete Current Patient Info
//
procedure TK_FormCMSASelectPatient.DeleteCurPatientInfo();
begin
  // Remove Patient from PatientsInfo
  with K_CMEDAccess do
    PatientsInfo.R.DeleteRows( OrderedInds[SGPatients.Selection.Top] );

  // Rebuild Patient View
  DelPatSID := PatSID;
  PatSID := '';
  BuildFilteredInds();

  BuildReorderedInds();

  RebuildPatientsListView();
//
end; // procedure TK_FormCMSASelectPatient.DeleteCurPatientInfo


//***************************** TK_FormCMSASelectPatient.GetCurPatientsInfoIndex ***
// Rebuild Controls View by Current Selected Patient
//
function TK_FormCMSASelectPatient.GetCurPatientsInfoIndex() : Integer;
begin
  with K_CMEDAccess, PatientsInfo.R do
  begin
    Result := 1 + Max( 0, K_IndexOfStringInRArray( PatSID,
                                              PME( 0, 1),
                                              ARowCount - 1,
                                              ElemSize * AColCount ) );
    PatSID := PString(PME( 0, Result))^;
  end;
end; // procedure TK_FormCMSASelectPatient.GetCurPatientsInfoIndex;

//***************************** TK_FormCMSASelectPatient.RebuildControlsView ***
// Rebuild Controls View by Current Selected Patient
//
procedure TK_FormCMSASelectPatient.RebuildControlsView( ACurPatInd : Integer );
var
  SkipEditData : Boolean;
begin
  with K_CMEDAccess, PatientsInfo.R do
  begin
    SkipEditData := (K_CMStandaloneMode = K_cmsaLink) or
                    ( (K_CMStandaloneMode = K_cmsaHybrid) and  // not (Synchronized Provider in Hybrid StandaloneMode
                     (PString(PME(7, ACurPatInd))^ = '1') );
    aModifyPatient.Caption := K_CML1Form.LLLSADialogs7.Caption; // '&Modify';
    if SkipEditData then
      aModifyPatient.Caption := K_CML1Form.LLLSADialogs6.Caption; // '&Details';
    aDeletePatient.Enabled := not SkipEditData and (ARowCount() > 2);
    aRestorePatient.Enabled := not SkipEditData;
    aDeletePatientForever.Enabled := not SkipEditData and K_CMGAModeFlag;

  end;
end; // procedure TK_FormCMSASelectPatient.RebuildControlsView;

//***************************** TK_FormCMSASelectPatient.SetCurPatientSyncState ***
// Set Current Patient Synchronized to PMS State
//
procedure TK_FormCMSASelectPatient.SetCurPatientSyncState;
var
  CurPatInd : Integer;

begin
  // Correct PatientsInfo
  CurPatInd := GetCurPatientsInfoIndex(); // Get Current Patient Index
  with K_CMEDAccess, PatientsInfo.R do
    PString(PME(7, CurPatInd))^ := '1';    // Set Current Patient to Index

  // Rebuild Interface
  RebuildControlsView( CurPatInd );
end; // procedure TK_FormCMSASelectPatient.SetCurPatientSyncState;

procedure TK_FormCMSASelectPatient.SGPatientsTopLeftChanged( Sender: TObject );
begin
  inherited;
//
end;

end.
