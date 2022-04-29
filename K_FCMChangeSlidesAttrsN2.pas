unit K_FCMChangeSlidesAttrsN2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ExtCtrls,
  N_Types, N_BaseF, N_CM1, N_CM2, N_DGrid, N_Rast1Fr,
  K_CM0, K_FrCMTeethChart1;

type TK_FormCMChangeSlidesAttrsN2 = class( TN_BaseForm )
    BtResetChart: TButton;

    ActionList1: TActionList;
    ResetChart: TAction;
    CloseCancel: TAction;
    ShowLocsInfo: TAction;

    LbDiagnoses: TLabel;
    MemoDiagnoses: TMemo;

    CmBMediaTypes: TComboBox;
    LbMediaType: TLabel;
    ThumbPanel: TPanel;

    ThumbsRFrame: TN_Rast1Frame;
    GBDetails: TGroupBox;
    LbColorDepth: TLabel;
    LbVColorDepth: TLabel;
    LbSize: TLabel;
    LbVSize: TLabel;
    LbSource: TLabel;
    LbVSource: TLabel;
    LbDuration: TLabel;
    LbVDuration: TLabel;
    LbObjID: TLabel;
    LbVObjID: TLabel;
    LbDims: TLabel;
    LbDims3D: TLabel;
    LbVDims: TLabel;
    ShowHistory: TAction;
    Button3: TButton;
    BtCancel: TButton;
    BtLocs: TButton;
    Button4: TButton;
    CMSTeethChartFrame: TK_FrameCMTeethChart1;
    LbVDurationFormat: TLabel;
    LbDateTaken: TLabel;
    DTPDTaken: TDateTimePicker;
    BtDTReset: TButton;
    ChBUseDT: TCheckBox;
    LbDICOM: TLabel;
    LbDCMState: TLabel;
    LbVolt: TLabel;
    LbCur: TLabel;
    LbExpTime: TLabel;
    LbMod: TLabel;
    EdVoltage: TEdit;
    EdCurrent: TEdit;
    EdExpTime: TEdit;
    CmBModality: TComboBox;

    procedure FormShow           ( Sender: TObject );
    procedure ResetChartExecute  ( Sender: TObject );
//    procedure SetValuesExecute        ( Sender: TObject );
    procedure CloseCancelExecute ( Sender: TObject );
    procedure FormKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SetValues1Execute(Sender: TObject);
    procedure ChBMTypeClick(Sender: TObject);
    procedure ShowHistoryExecute(Sender: TObject);
    procedure ShowLocsInfoExecute(Sender: TObject);
    procedure ChBUseDTClick(Sender: TObject);
    procedure DTPDTakenChange(Sender: TObject);
    procedure BtDTResetClick(Sender: TObject);
    procedure EdVoltageChange(Sender: TObject);
    procedure CmBModalityChange(Sender: TObject);
  private
    { Private declarations }
    SSAProcessedCount: Integer;
    SSAGroupUpdateStateFlag : Boolean;
    SSAMTypes : TN_IArray;
    SSADiagnoses : TN_SArray;
    SSATeethCharts : TN_I64Array;
    SSAPrevInd : Integer;
    SSADates  : TN_IArray; // Slides Cur DateTaken values
    SSAIDates : TN_IArray; // Slides Initial DateTaken Date Values
    SSADCMAttrs: array of TK_CMDCMAttrs;

    procedure SSADrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SSAGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure SSAInitialiseControls();
    procedure SSAChangeThumbState( ADGObj: TN_DGridBase; AInd: integer );
  public
    { Public declarations }
    //*** Slide Fieds Vars
    SSASlides: TN_UDCMSArray;
    SSAThumbsDGrid: TN_DGridArbMatr;
    SSADrawSlideObj: TN_CMDrawSlideObj;
//    procedure CurStateToMemIni (); override;
//    procedure MemIniToCurState (); override;
    procedure SSASaveValues();
end; // type TK_FormCMSetSlidesAttrs = class( TN_BaseForm )

function  K_CMChangeSlidesAttrsDlg( APSlides : TN_PUDCMSlide; ASlidesCount : Integer;
                                    ACaption : string = '' ) : Integer;
procedure K_DumpCSADlgCoords ( APrefix: string );

var
  K_FormCMChangeSlidesAttrsN2: TK_FormCMChangeSlidesAttrsN2;

implementation
{$R *.dfm}
uses Types, Math,
  K_Clib0, K_VFunc, K_FCMReportShow,
  N_Comp1, N_Lib0, N_Lib1, K_CML1F;

//************************************************ K_CMChangeSlidesAttrsDlg ***
// Set properties to given Slides
//
//    Parameters
// APSlides   - pointer to slides array start element to change attributes
// APSlidesCount - slides to change attributes counter
// ACaption - form caption
// AIniMediaType - initial Media Type
//
function K_CMChangeSlidesAttrsDlg( APSlides : TN_PUDCMSlide; ASlidesCount : Integer;
                                ACaption : string = '' ) : Integer;
var
  NumReadOnly, i : Integer;
  FSaveValues : Boolean;
begin
  Result := 0;
  if ASlidesCount = 0 then Exit;

  K_FormCMChangeSlidesAttrsN2 := TK_FormCMChangeSlidesAttrsN2.Create( Application );

  with K_FormCMChangeSlidesAttrsN2 do
  begin
//Close();
//Exit;
//    BFFlags := [bffToDump1];
//    BFDumpControl := ThumbsRFrame;
//    BFDumpControl := ThumbPanel;

//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 1a' );

//    Realign();
//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 1b' );

    if ACaption <> '' then
      Caption := ACaption;
    SetLength( SSASlides, ASlidesCount );
    Move( APSlides^, SSASlides[0], SizeOf(TN_UDCMSlide) * ASlidesCount );

  //////////////////////////////////
  // Show ReadOnly Info if needed
    SetLength( SSAMTypes, ASlidesCount );
    SetLength( SSADiagnoses, ASlidesCount );
    SetLength( SSATeethCharts, ASlidesCount );
    SetLength( SSADates, ASlidesCount );
    SetLength( SSAIDates, ASlidesCount );
    SetLength( SSADCMAttrs, ASlidesCount );
    NumReadOnly := 0;
    for i := 0 to ASlidesCount - 1 do
    begin
      with SSASlides[i].P()^ do
      begin
        if not (cmsfIsLocked in CMSRFlags ) then
          Inc(NumReadOnly);
        SSAMTypes[i] := CMSMediaType;
        SSATeethCharts[i] := CMSTeethFlags;
        SSADiagnoses[i] := CMSDiagn;
        SSADates[i] := Trunc(CMSDTTaken);
        SSAIDates[i] := CMSDB.IniDTTaken;
        SSADCMAttrs[i].CMDCMModality := CMSDB.DCMModality;
        SSADCMAttrs[i].CMDCMKVP := CMSDB.DCMKVP;
        SSADCMAttrs[i].CMDCMExpTime := CMSDB.DCMExpTime;
        SSADCMAttrs[i].CMDCMTubeCur := CMSDB.DCMTubeCur;
      end;
    end;

    if NumReadOnly > 0 then
      K_CMShowMessageDlg(format( K_CML1Form.LLLChangeSlideAttrs.Caption,
//            ' %d Object(s) are opened in readonly mode.',
            [NumReadOnly]), mtInformation);
  // end of Show ReadOnly Info if needed
  //////////////////////////////////

    SSADrawSlideObj := TN_CMDrawSlideObj.Create();
    SSAThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, SSAGetThumbSize );
    SSAThumbsDGrid.DGChangeItemStateProcObj := SSAChangeThumbState;

//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 2' );

    with SSAThumbsDGrid do
    begin
      DGEdges := Rect( 2, 2, 2, 2 );
      DGGaps  := Point( 2, 2 );
      DGScrollMargins := Rect( 8, 8, 8, 8 );

      DGLFixNumCols   := 0;
      DGLFixNumRows   := 1;
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
//      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor
      DGMultiMarking  := False; //

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 14; // see DGLItemsAspect

      DGDrawItemProcObj := SSADrawThumb;
      DGNumItems := Length(SSASlides);
      SSAPrevInd := -1;
//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 3' );
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 4' );
//      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      ThumbsRFrame.DstBackColor := DGBackColor;
    end; // with ThumbsDGrid do

//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 5' );

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

//    BFDumpCoords( 'K_CMChangeSlidesAttrsDlg 10' );

{Remove DTaken control - user can select future date}
//{$IF CompilerVersion >= 26.0} // Delphi >= XE5
//    DTPDTaken.MaxDate  := K_CMEDAccess.EDAGetSyncTimestamp();
//{$ELSE}         // Delphi 7 and 2010
//    DTPDTaken.MaxDate := Trunc(K_CMEDAccess.EDAGetSyncTimestamp()) + 1 + 1 / (24 * 60 * 60);;
//{$IFEND CompilerVersion >= 26.0}

    FSaveValues := ShowModal = mrOK;
    SSAThumbsDGrid.DGMarkSingleItem( -1 ); // Unmark all Items - needed to save current Item values
    SSAInitialiseControls();

    if FSaveValues then
      SSASaveValues();
    Result := SSAProcessedCount;

    SSAThumbsDGrid.Free;
    SSADrawSlideObj.Free;
    CMSTeethChartFrame.FreeFrameObjects();
    ThumbsRFrame.RFFreeObjects();
  end; // with EditRecordForm do

  K_FormCMChangeSlidesAttrsN2 := nil;
end; // end of K_CMChangeSlidesAttrsDlg

//****************************************************** K_DumpCSADlgCoords ***
// Set properties to given Slides
//
procedure K_DumpCSADlgCoords( APrefix: string );
begin
  if K_FormCMChangeSlidesAttrsN2 <> nil then
  with K_FormCMChangeSlidesAttrsN2 do
  begin
    BFDumpCoords( APrefix );
    N_DumpTControl( '     ThumbPanel', ThumbPanel );
    N_DumpTControl( '      GBDetails', GBDetails );
  end;
end; // procedure K_DumpCSADlgCoords


procedure ChangeValue( ED : TEdit; var Val : Integer );
var
  WInt : Integer;
  WStr, WStr1 : string;
begin
  if not ED.Enabled then Exit;
  WStr1 := Trim(ED.Text);
  WInt := StrToIntDef( WStr1, Val );
  if WInt < 0 then WInt := -WInt;
  Val := WInt;
  WStr := IntToStr( WInt );
  if WStr <> WStr1 then
    ED.Text := WStr;
end; // procedure ChangeValue

procedure ChangeFValue( ED : TEdit; var Val : Double );
var
  WF : Double;
  WStr, WStr1 : string;
begin
  if not ED.Enabled then Exit;
  WStr1 := Trim(ED.Text);
  WF := Val;
  WF := StrToFloatDef( WStr1, WF );
  if WF < 0 then WF := -WF;
  Val := WF;
  WStr := FloatToStr( WF );
  if WStr <> WStr1 then
    ED.Text := WStr;
end; // procedure ChangeFValue

//************************************* TK_FormCMChangeSlidesAttrsN2.FormShow ***
// Form Show Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.FormShow(Sender: TObject);
begin
  inherited;

{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
  ThumbsRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}
  DoubleBuffered := True;

//  BFDumpCoords( 'TK_FormCMChangeSlidesAttrsN.FormShow 1' );
  SSAProcessedCount := 0;
  ShowLocsInfo.Visible := K_CMEnterpriseModeFlag;
//  ShowHistory.Visible := K_CMEDAccess is TK_CMEDDBAccess;
//  BFDumpCoords( 'TK_FormCMChangeSlidesAttrsN.FormShow 2' );
  CMSTeethChartFrame.ShowTeethChartState( 0 );
//  BFDumpCoords( 'TK_FormCMChangeSlidesAttrsN.FormShow 3' );
  with CmBMediaTypes do begin
    K_CMEDAccess.EDAGetAllMediaTypes( Items );
    ItemIndex := 0;
  end;
  MemoDiagnoses.Lines.Text := '';

  K_FillDICOMModalitiesList( CmBModality.Items );
//  CmBModalityChange(CmBModality);

  SSAThumbsDGrid.DGSetItemState( 0, ssmMark );
  SSAThumbsDGrid.DGSelectItem( 0 );
//  if Length(SSASlides) = 1 then
//    SSAThumbsDGrid.DGSetItemState( 0, ssmMark )
//  else
//    InitialiseControls();
//   LbDICOM.Visible := K_CMDICOMVisible();;
//   LbDCMState.Visible := LbDICOM.Visible;
  SSAInitialiseControls();

end; // end of TK_FormCMChangeSlidesAttrsN2.FormShow

//******************************** TK_FormCMChangeSlidesAttrsN2.ResetChartExecute ***
// Reset Teeth Chart Action Execute
//
procedure TK_FormCMChangeSlidesAttrsN2.ResetChartExecute(Sender: TObject);
begin
  CMSTeethChartFrame.ShowTeethChartState( 0 );
end; // end of TK_FormCMChangeSlidesAttrsN2.ResetChartExecute


//************************************** TK_FormCMChangeSlidesAttrsN2.SetValues1Execute ***
// Set Values to Selected Action Execute
//
procedure TK_FormCMChangeSlidesAttrsN2.SetValues1Execute(Sender: TObject);
var
  i  : Integer;
  ChangeAttrsFlag : Boolean;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
begin
  with SSAThumbsDGrid, DGMarkedList do begin
    if (Count = 0) then Exit; // Nothing to do

  // set selected slides attributes
    for i := 0 to Count - 1 do begin
      UDSlide := SSASlides[Integer(List[i])];
      PCMSlide := UDSlide.P();
      with UDSlide, PCMSlide^  do begin
//1        if not (cmsfIsLocked in CMSRFlags) then Continue; // precaution
//2        if (cmsfSkipSlideEdit in CMSRFlags) then Continue; // precaution
        if not (cmsfIsLocked in CMSRFlags) or (cmsfSkipSlideEdit in CMSRFlags) then Continue; // precaution
        ChangeAttrsFlag := FALSE;
      // Teeth Flags
        if CMSTeethFlags <> CMSTeethChartFrame.TCFrTeethChartState then begin
          GetCMSUndoBuf( );
          CMSTeethFlags := CMSTeethChartFrame.TCFrTeethChartState;
          ChangeAttrsFlag := TRUE;
        end;
      // Media Type
        with CmBMediaTypes do
          if CMSMediaType <> Integer( CmBMediaTypes.Items.Objects[ItemIndex] ) then begin
            GetCMSUndoBuf( );
            if ItemIndex >=0 then
              CMSMediaType := Integer( CmBMediaTypes.Items.Objects[ItemIndex] )
            else
              CMSMediaType := 0;
            ChangeAttrsFlag := TRUE;
          end;
      // Diagnoses
        if CMSDiagn <> MemoDiagnoses.Lines.Text then begin
          GetCMSUndoBuf( );
          CMSDiagn := MemoDiagnoses.Lines.Text;
          ChangeAttrsFlag := TRUE;
        end;
        if not ChangeAttrsFlag then Continue;
        // Set Modified Attributes
        if not (cmssfAttribsChanged in CMSlideECSFlags) then
          Inc(SSAProcessedCount);

//        CMSDTPropMod := Now();
        CMSDTPropMod := K_CMEDAccess.EDAGetSyncTimestamp();
        CMSProvIDModified := K_CMEDAccess.CurProvID; // Provider ID Modified
        CMSLocIDModified  := K_CMEDAccess.CurLocID; // Location ID Modified
        CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;
        Include( CMSRFlags, cmsfAttribsChanged ); // Needed for ECach Only
        Include( CMSlideECSFlags, cmssfAttribsChanged ); // Set Slide Changing FLag for ECache

        if (cmsfIsMediaObj in CMSDB.SFlags) or
           (CMSlideEdState <> K_edsFullAccess)  then Continue; //  Skip Saving To ECache Atributes Changes for Video Slides

        K_CMEDAccess.EDASaveSlideToECache( UDSlide );
        Include( CMSlideECSFlags, cmssfAttribsChanged ); // Set Slide Mark as changed  for  future saving
      end;
    end;

  end;
end; // end of TK_FormCMChangeSlidesAttrsN2.SetValues1Execute

//******************************* TK_FormCMChangeSlidesAttrsN2.CloseCancelExecute ***
// Form OK Action Execute
//
procedure TK_FormCMChangeSlidesAttrsN2.CloseCancelExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
end; // end of TK_FormCMChangeSlidesAttrsN2.CloseCancelExecute

//************************************ TK_FormCMSetSlidesAttrs.SSADrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of SSAThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMChangeSlidesAttrsN2.SSADrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  WStr : string;

begin
  if (SSAThumbsDGrid.DGItemsFlags[AInd] = 0) and
     (AInd = SSAPrevInd) then
  begin
  //////////////////////////////////
  // Save PrevSelected Values Values
    SSATeethCharts[SSAPrevInd] := CMSTeethChartFrame.TCFrTeethChartState;
    with CmBMediaTypes do
      SSAMTypes[SSAPrevInd] := Integer( CmBMediaTypes.Items.Objects[ItemIndex] );
    SSADiagnoses[SSAPrevInd] := MemoDiagnoses.Lines.Text;
    SSADates[SSAPrevInd] := Trunc(DTPDTaken.Date);
//    SSAIDates[SSAPrevInd] := Trunc(SSASlides[SSAPrevInd].P.CMSDTTaken);
//    if SSAIDates[SSAPrevInd] = SSADates[SSAPrevInd] then
//      SSAIDates[SSAPrevInd] := 0;

    CmBModalityChange(CmBModality);
    SSADCMAttrs[SSAPrevInd].CMDCMModality := CmBModality.Text;
    SSADCMAttrs[SSAPrevInd].CMDCMKVP := StrToFloatDef( EdVoltage.Text, 0 );
    SSADCMAttrs[SSAPrevInd].CMDCMTubeCur := StrToIntDef( EdCurrent.Text, 0 );
    SSADCMAttrs[SSAPrevInd].CMDCMExpTime := StrToIntDef( EdExpTime.Text, 0 );

  ////////////////////
  // Clear Controls
    SSAPrevInd := -1;
    ShowLocsInfo.Enabled := FALSE;
    ShowHistory.Enabled := FALSE;
    CMSTeethChartFrame.TCFrReadOnlyMode := FALSE;
    CMSTeethChartFrame.ShowTeethChartState( 0 );
    CMSTeethChartFrame.TCFrReadOnlyMode := TRUE;
    CmBMediaTypes.ItemIndex := -1;
    MemoDiagnoses.Lines.Text := '';
    ResetChart.Enabled := FALSE;
    MemoDiagnoses.Enabled := FALSE;
    CmBMediaTypes.Enabled := FALSE;
    LbDateTaken.Font.Color := clGrayText;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    DTPDTaken.Date := 0;
{$ELSE}         // Delphi 7 and 2010
  // needed to add some time because of TDateTimePicker error in Delphi 7
    DTPDTaken.Date := 0 + 1 / (24 * 60 * 60);
{$IFEND CompilerVersion >= 26.0}
    DTPDTaken.Enabled := FALSE;
    BtDTReset.Enabled := FALSE;
    ChBUseDT.Enabled  := FALSE;

    CmBModality.Text := '';
//    SSADCMAttrs[SSAPrevInd].CMDCMKVP := StrToFloatDef( EdVoltage.Text, 0 );
//    SSADCMAttrs[SSAPrevInd].CMDCMTubeCur := StrToIntDef( EdCurrent.Text, 0 );
//    SSADCMAttrs[SSAPrevInd].CMDCMExpTime := StrToIntDef( EdExpTime.Text, 0 );

    LbSize.Visible := FALSE;
    LbVSize.Visible := FALSE;
    LbDims.Visible := FALSE;
    LbDims3D.Visible := FALSE;
    LbVDims.Visible := FALSE;
    LbObjID.Visible := FALSE;
    LbVObjID.Visible := FALSE;
    LbSource.Visible := FALSE;
    LbVSource.Visible := FALSE;
    LbDuration.Visible := FALSE;
    LbVDuration.Visible := FALSE;
    LbColorDepth.Visible := FALSE;
    LbVColorDepth.Visible := FALSE;

    LbDiagnoses.Enabled := FALSE;
    LbMediaType.Enabled := FALSE;
{
    LbVObjID.Caption := '';
    LbVDims.Caption := '';

    LbVColorDepth.Caption := '';

    LbVSize.Caption := '';

    LbVSource.Caption := '';


    LbVDuration.Visible := FALSE;
    LbDuration.Visible := FALSE;
}
  end; //   if (SSAThumbsDGrid.DGItemsFlags[AInd] = 0) and  (AInd = SSAPrevInd) then


  with N_CM_GlobObj do
  begin
//    CMStringsToDraw[0] := SSASlides[AInd].GetUName;
    WStr := '';
//1    if not (cmsfIsLocked in SSASlides[AInd].P.CMSRFlags) then
//2    if (cmsfSkipSlideEdit in SSASlides[AInd].P.CMSRFlags) then
    with SSASlides[AInd].P^ do
      if not (cmsfIsLocked in CMSRFlags) or
         (cmsfSkipSlideEdit in CMSRFlags) then
        WStr := ' [R]';
    CMStringsToDraw[0] := K_CMSlideViewCaption( SSASlides[AInd] ) + WStr;
    SSADrawSlideObj.DrawOneThumb1( SSASlides[AInd],
                                   CMStringsToDraw, SSAThumbsDGrid, ARect,
                                   SSAThumbsDGrid.DGItemsFlags[AInd] );
//    SSADrawSlideObj.DrawOneThumb2( SSASlides[AInd],
//                                   CMStringsToDraw, SSAThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TK_FormCMChangeSlidesAttrsN2.SSADrawThumb

//********************************* TK_FormCMSetSlidesAttrs.SSAGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of SSAThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMChangeSlidesAttrsN2.SSAGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := SSASlides[AInd];
    ThumbDIB  := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TK_FormCMChangeSlidesAttrsN2.SSAGetThumbSize

//************************ TK_FormCMChangeSlidesAttrsN2.SSAInitialiseControls ***
// Show Available and Processed
//
procedure TK_FormCMChangeSlidesAttrsN2.SSAInitialiseControls();
var
  i, CInd : Integer;
  ObjID : string;
  SetMTypeCount, SetTeethCount, SetDiagnCount : Integer;
  CurTeethFlags: Int64;
  CurMTypeCode : Integer;
  CurDiagnText : string;
  CurDate : Integer;
  CurIDate : Integer;
  CurModality:  string; // DICOM Modality
  CurKVP     :  Double; // DICOM KVP - Peak kilo voltage output of the x-ray generator used (0018,0060)
  CurExpTime : Integer; // DICOM ExposureTime - Time of x-ray exposure in msec   (0018,1150)
  CurTubeCur : Integer; // DICOM Integer TubeCurrent - X-Ray Tube Current in mA  (0018,1151)
//  LockedCount : Integer;
  SkipEditCount : Integer;
  SSource : string;
  SWidth, SHeight, SDepth, SPixBits : Integer;
  SBytesSize : Int64;
  SDuration : Float;
  SWidthCount, SHeightCount, SDepthCount, SPixBitsCount, SBytesSizeCount,
  SSourceCount, SDurationCount, SDurationVisCount : Integer;
  ChangeValuesEnableFlag : Boolean;

  SDICOMStoreCount : Integer;
  SDICOMStore : TK_CMBSlideDCMState;

begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    SetMTypeCount := 0;
    SetTeethCount := 0;
    SetDiagnCount := 0;
//    LockedCount   := 0;
    SkipEditCount := 0;
    CurTeethFlags := -1;
    CurMTypeCode  := -1;
    CurDiagnText  := Chr($0D) + Chr($0D) + Chr($0D);
    CurDate := 0;
    CurIDate := 0;
    CurModality := ''; // DICOM Modality
    CurKVP :=  0; // DICOM KVP - Peak kilo voltage output of the x-ray generator used (0018,0060)
    CurExpTime := 0; // DICOM ExposureTime - Time of x-ray exposure in msec   (0018,1150)
    CurTubeCur := 0; // DICOM Integer TubeCurrent - X-Ray Tube Current in mA  (0018,1151)

    SWidth         := 0;
    SHeight        := 0;
    SDepth         := 0;
    SPixBits       := 0;
    SBytesSize     := 0;
    SSource        := '';
    SDuration      := 0;
    SWidthCount       := 0;
    SHeightCount      := 0;
    SDepthCount       := 0;
    SPixBitsCount     := 0;
    SBytesSizeCount   := 0;
    SSourceCount      := 0;
    SDurationCount    := 0;
    SDurationVisCount := 0;
    CInd := -1;
    LbDICOM.Visible := K_CMDICOMVisible() and (K_CMEDDBVersion >= 44);
    LbDCMState.Visible := LbDICOM.Visible;
    SDICOMStoreCount := 0;
    SDICOMStore := [];

    for i := 0 to Count - 1 do
    begin
      CInd := Integer(List[i]);
      with SSASlides[CInd], P()^  do
      begin
      // Current Slide Teeth Flags
        ObjID := ObjName;

        if CurTeethFlags <> SSATeethCharts[CInd] then
        begin
          CurTeethFlags := SSATeethCharts[CInd];
          Inc(SetTeethCount);
        end;
      // Current Slide Media Type
        if CurMTypeCode <> SSAMTypes[CInd] then
        begin
          CurMTypeCode := SSAMTypes[CInd];
          Inc(SetMTypeCount);
        end;
      // Current Slide Diagnoses
        if CurDiagnText <> SSADiagnoses[CInd] then
        begin
          CurDiagnText := SSADiagnoses[CInd];
          Inc(SetDiagnCount);
        end;

      // Current Slide Date Taken
        if CurDate <> SSADates[CInd] then
        begin
          CurDate := SSADates[CInd];
          CurIDate := SSAIDates[CInd];
        end;

        if CurModality <>  SSADCMAttrs[CInd].CMDCMModality then // DICOM Modality
          CurModality := SSADCMAttrs[CInd].CMDCMModality;

        if CurKVP <>  SSADCMAttrs[CInd].CMDCMKVP then // DICOM KVP
          CurKVP := SSADCMAttrs[CInd].CMDCMKVP;

        if CurExpTime <>  SSADCMAttrs[CInd].CMDCMExpTime then // DICOM Expouser Time
          CurExpTime := SSADCMAttrs[CInd].CMDCMExpTime;

        if CurTubeCur <>  SSADCMAttrs[CInd].CMDCMTubeCur then // DICOM Tube Current
          CurTubeCur := SSADCMAttrs[CInd].CMDCMTubeCur;

//1        if cmsfIsLocked in CMSRFlags then
//1          Inc( LockedCount );
//2        if cmsfSkipSlideEdit in CMSRFlags then
//2          Inc( SkipEditCount );
        if not (cmsfIsLocked in CMSRFlags) or
           (cmsfSkipSlideEdit in CMSRFlags) or
           (cmsfSkipChangesSave in CMSRFlags) then
          Inc( SkipEditCount );

        if CMSDB.PixWidth = 0 then SetAttrsByCurImgParams( FALSE );

        if CMSDB.PixWidth <> SWidth then
        begin
          SWidth := CMSDB.PixWidth;
          Inc(SWidthCount);
        end;
        if CMSDB.PixHeight <> SHeight then
        begin
          SHeight := CMSDB.PixHeight;
          Inc(SHeightCount);
        end;
        if CMSDB.PixDepth <> SDepth then
        begin
          SDepth := CMSDB.PixDepth;
          Inc(SDepthCount);
        end;
        if CMSDB.PixBits <> SPixBits then
        begin
          SPixBits := CMSDB.PixBits;
          Inc(SPixBitsCount);
        end;
        if CMSDB.BytesSize <> SBytesSize then
        begin
          SBytesSize := CMSDB.BytesSize;
          Inc(SBytesSizeCount);
        end;
        if CMSSourceDescr <> SSource then
        begin
          SSource := CMSSourceDescr;
          Inc(SSourceCount);
        end;
        if CMSDB.MDuration <> 0 then
          Inc(SDurationVisCount);

        if CMSDB.MDuration <> SDuration then
        begin
          SDuration := CMSDB.MDuration;
          Inc(SDurationCount);
        end;

        if LbDICOM.Visible then
        begin
          if SDICOMStore <> CMSDCMFSet then
          begin
            SDICOMStore := CMSDCMFSet;
            Inc(SDICOMStoreCount);
          end;
        end;

      end; // with SSASlides[CInd], P()^  do
    end; // for i := 0 to Count - 1 do
{
    if ((SSAPrevInd <> -1) and (SSAPrevInd <> CInd)) then
    begin
      SSATeethCharts[SSAPrevInd] := CMSTeethChartFrame.TCFrTeethChartState;
      with CmBMediaTypes do
        SSAMTypes[SSAPrevInd] := Integer( CmBMediaTypes.Items.Objects[ItemIndex] );
      SSADiagnoses[SSAPrevInd] := MemoDiagnoses.Lines.Text;
    end;
}
    SSAPrevInd := CInd;


  //Check Common Values
  // Current Slide Teeth Flags
    if (SetTeethCount = 0) or (SetTeethCount > 1) then
      CurTeethFlags := 0;

  // Current Slide Media Type
    if SetMTypeCount > 1 then
      CurMTypeCode := -1;

  // Current Slide Diagnoses
    if (SetDiagnCount = 0) or (SetDiagnCount > 1) then
      CurDiagnText := '';

    if (SetDiagnCount = 0) or (SetDiagnCount > 1) then
      CurDiagnText := '';

  // Set Controls
    ChangeValuesEnableFlag := (Count > 0) and (SkipEditCount < Count);
    ShowLocsInfo.Enabled := Count > 0;
    ShowHistory.Enabled := Count > 0;

    if ShowHistory.Enabled then
    begin
   // Teeth Flags
      CMSTeethChartFrame.TCFrReadOnlyMode := FALSE;
      CMSTeethChartFrame.ShowTeethChartState( CurTeethFlags );
    // Media Type
      with CmBMediaTypes do
        CmBMediaTypes.ItemIndex := Items.IndexOfObject( TObject(CurMTypeCode) );
    // Diagnoses
      MemoDiagnoses.Lines.Text := CurDiagnText;

    // Date Taken
      LbDateTaken.Font.Color := clWindowText;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
      DTPDTaken.Date := CurDate;
{$ELSE}         // Delphi 7 and 2010
  // needed to add some time because of TDateTimePicker error in Delphi 7
      DTPDTaken.Date := CurDate + 1 / (24 * 60 * 60);
{$IFEND CompilerVersion >= 26.0}
      DTPDTaken.Enabled := ChBUseDT.Checked;
      BtDTReset.Enabled := DTPDTaken.Enabled and (CurIDate <> 0);
      ChBUseDT.Enabled := TRUE;

      with CmBModality do
        CmBModality.ItemIndex := Items.IndexOf( CurModality );
      CmBModalityChange( CmBModality );
      ChangeFValue( EdVoltage, CurKVP );
      ChangeValue( EdCurrent, CurTubeCur );
      ChangeValue( EdExpTime, CurExpTime );
    end; // if ShowHistory.Enabled then

    CMSTeethChartFrame.TCFrReadOnlyMode := not ChangeValuesEnableFlag;
    ResetChart.Enabled := ChangeValuesEnableFlag;
    MemoDiagnoses.Enabled := ChangeValuesEnableFlag;
    CmBMediaTypes.Enabled := ChangeValuesEnableFlag;

    LbColorDepth.Visible := TRUE;
    LbVColorDepth.Visible := TRUE;
    LbSize.Visible := SBytesSize > 0;
    LbVSize.Visible := TRUE;
    LbSource.Visible := TRUE;
    LbVSource.Visible := TRUE;
    LbObjID.Visible := TRUE;
    LbVObjID.Visible := TRUE;
    LbDims.Visible := SDepth = 0;
    LbDims3D.Visible := SDepth > 0;
    LbVDims.Visible := TRUE;

    LbDiagnoses.Enabled := TRUE;
    LbMediaType.Enabled := TRUE;

    LbVObjID.Caption := '';
    if Count = 1 then
      LbVObjID.Caption := ObjID;

    LbVDims.Caption := '';
    if (SWidthCount = 1) and (SHeightCount = 1) then
    begin
      LbVDims.Caption := format( '%d x %d', [SWidth, SHeight] );
      if (SDepth > 0) and (SDepthCount = 1) then
        LbVDims.Caption := LbVDims.Caption + format( ' x %d', [SDepth] );
    end;

    LbDims.Visible := SDepth = 0;
    LbDims3D.Visible := SDepth > 0;

    LbVColorDepth.Caption := '';
    if SPixBitsCount = 1 then
      LbVColorDepth.Caption := IntToStr( SPixBits );

    LbVSize.Caption := '';
    if SBytesSizeCount = 1 then
      LbVSize.Caption := N_DataSizeToString( SBytesSize );

    LbVSource.Caption := '';
    if SSourceCount = 1 then
      LbVSource.Caption := SSource;

    LbVDuration.Visible := (SDurationVisCount > 0) and
                           (SDurationVisCount = Count);
    LbDuration.Visible := LbVDuration.Visible;
    LbVDuration.Caption := '';
    if LbVDuration.Visible and (SDurationCount = 1) then
       LbVDuration.Caption :=  format( LbVDurationFormat.Caption, [SDuration] );

    // DICOM
    LbDCMState.Caption := '';
    if LbDICOM.Visible and (SDICOMStoreCount > 0) then
    begin // SDICOMStoreCount
      if K_bsdcmsStore in SDICOMStore then
        LbDCMState.Caption := 'Store, '
      else
      if K_bsdcmsStoreErr in SDICOMStore then
        LbDCMState.Caption := 'Store error, ';

      if K_bsdcmsComm in SDICOMStore then
        LbDCMState.Caption := LbDCMState.Caption + 'Commitment request, '
      else
      if K_bsdcmsCommErr in SDICOMStore then
        LbDCMState.Caption := LbDCMState.Caption + 'Commitment request error, ';

      if K_bsdcmsCommExists in SDICOMStore then
        LbDCMState.Caption := LbDCMState.Caption + 'PACS exists, '
      else
      if K_bsdcmsCommAbsent in SDICOMStore then
        LbDCMState.Caption := LbDCMState.Caption + 'PACS absent, ';

      if K_bsdcmsImport in SDICOMStore then
        LbDCMState.Caption := LbDCMState.Caption + 'Imported from PACS';
        
      with LbDCMState do
      if Caption[Length(Caption)] = ' ' then
        Caption := Copy( Caption, 1, Length(Caption) - 2 );
    end; // LbDICOM.Visible
//       format( '%.1f sec' , [SDuration] );
  end;

end; // end of TK_FormCMChangeSlidesAttrsN2.SSAInitialiseControls

//******************************** TK_FormCMChangeSlidesAttrsN2.FormKeyDown ***
//  Form Key Down Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.FormKeyDown( Sender: TObject;
                                       var Key: Word; Shift: TShiftState );
begin
  if not( [ssAlt] = Shift ) then Exit;
  if (Key = $4D) and CmBMediaTypes.Enabled then
  begin // Alt + M
    CmBMediaTypes.SetFocus;
    CmBMediaTypes.DroppedDown := true;
{
  end else if Key = $54 then begin // Alt + T
//    DTPDTaken.SetFocus;
  end else if Key = $50 then begin // Alt + P
//    if not CmBProvider.Enabled then Exit;
//    CmBProvider.SetFocus;
//    CmBProvider.DroppedDown := true;
  end else if Key = $4C then begin // Alt + L
//    if not CmBLocation.Enabled then Exit;
//    CmBLocation.SetFocus;
//    CmBLocation.DroppedDown := true;
}
  end
  else
  if (Key = $44) and MemoDiagnoses.Enabled then
  begin // Alt + D
    MemoDiagnoses.SetFocus;
    MemoDiagnoses.SelStart := 0;
    MemoDiagnoses.SelLength := MaxInt;
  end;
end; // end of TK_FormCMChangeSlidesAttrsN2.FormKeyDown
{
//***********************************  TK_FormCMSetSlidesAttrs.CurStateToMemIni  ***
//
procedure TK_FormCMSetSlidesAttrs.CurStateToMemIni();
begin
  inherited;
end; // end of TK_FormCMSetSlidesAttrs.CurStateToMemIni

//***********************************  TK_FormCMSetSlidesAttrs.MemIniToCurState  ******
//
procedure TK_FormCMSetSlidesAttrs.MemIniToCurState();
begin
  inherited;
end; // end of TK_FormCMSetSlidesAttrs.MemIniToCurState
}
//***********************************  TK_FormCMSetSlidesAttrs.SSAChangeThumbState  ******
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMChangeSlidesAttrsN2.SSAChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
begin
  if SSAGroupUpdateStateFlag then Exit;
  SSAInitialiseControls();
end; // end of TK_FormCMSetSlidesAttrs.SSAChangeThumbState

procedure TK_FormCMChangeSlidesAttrsN2.ChBMTypeClick(Sender: TObject);
begin
  SSAInitialiseControls();
end; // procedure TK_FormCMChangeSlidesAttrsN2.ChBMTypeClick

procedure TK_FormCMChangeSlidesAttrsN2.ShowHistoryExecute(Sender: TObject);
var
  ReportDetailes, WStr : string;
  RepAtttrs : TK_CMHistRepAtttrs;
  UDCMSlide : TN_UDCMSlide;
  FReportDataSMatr: TN_ASArray;
  i, j, k : Integer;
  VideoFlag : Boolean;
  VideoExt : string;
  PCMSlideHist : TN_PCMSlideHist;

begin
  UDCMSlide := nil;
  with SSAThumbsDGrid do
    if DGSelectedInd >= 0 then
      UDCMSlide := SSASlides[DGSelectedInd];

  if UDCMSlide = nil then Exit;

  if K_CMEDDBVersion < 13 then
  begin
    K_CMSlideHistoryShowDlg( UDCMSlide );
    Exit;
  end;

  RepAtttrs.HRFlags := [K_srfAllSlideActs,K_srfSASaveResCurSession];

  RepAtttrs.HRPatID := '';

  RepAtttrs.HRProvID := '';

  RepAtttrs.HRLocID := '';

  with K_CMEDAccess, UDCMSlide, P^ do
  begin
    if K_CMEDAccess is TK_CMEDDBAccess then
    begin
      RepAtttrs.HRSlideID := ObjName;

      RepAtttrs.HRStartTS := CMSDTCreated;
      RepAtttrs.HRFinTS   := EDAGetSyncTimestamp();

      K_CMHistReportCreate( FReportDataSMatr, RepAtttrs );



      // Rebuild Result StrMatr
      for i := 0 to High(FReportDataSMatr) do
      begin
        FReportDataSMatr[i][2] := FReportDataSMatr[i][4];
        FReportDataSMatr[i][3] := FReportDataSMatr[i][5];
        FReportDataSMatr[i][4] := FReportDataSMatr[i][6];
        FReportDataSMatr[i][5] := FReportDataSMatr[i][7];
        SetLength( FReportDataSMatr[i], 6 );
      end;
    end
    else
    begin
    // Statistics in Demo Mode
      SetLength( FReportDataSMatr, 1 );
      SetLength( FReportDataSMatr[0], 6 );
      FReportDataSMatr[0][0] := K_CML1Form.LLLReportHeaderTexts.Items[0]; //'Date';
      FReportDataSMatr[0][1] := K_CML1Form.LLLReportHeaderTexts.Items[1]; //'Time';
      FReportDataSMatr[0][2] := K_CML1Form.LLLReportHeaderTexts.Items[4]; //'User';
      FReportDataSMatr[0][3] := K_CML1Form.LLLReportHeaderTexts.Items[5]; //'Action';
      FReportDataSMatr[0][4] := K_CML1Form.LLLReportHeaderTexts.Items[6]; //'PC name';
      FReportDataSMatr[0][5] := K_CML1Form.LLLReportHeaderTexts.Items[7]; //'Location';
    end;

  // Add Current Statistics
//    WStr := 'Patient: %-20s Image Object ID: %s';
    WStr := K_CML1Form.LLLReport4.Caption;
    VideoExt := '';
    VideoFlag := cmsfIsMediaObj in CMSDB.SFlags;
    if VideoFlag  then
    begin
//      WStr := 'Patient: %-20s Video Object ID: %s';
      WStr := K_CML1Form.LLLReport5.Caption;
      VideoExt := UpperCase(Copy(CMSDB.MediaFExt, 2, 5));
    end;

    ReportDetailes := format( WStr,
        [K_CMGetPatientDetails(CMSPatId, K_CMENPTCommonPatientDetails1), UDCMSlide.ObjName]);
//    ReportDetailes := format('Patient: %-20s %s Object ID: %s',
//        [K_CMGetPatientDetails(CMSPatId), WStr, UDCMSlide.ObjName ]);

    j := Length(FReportDataSMatr);
    k := CMSHist.ALength();
    if k > 0 then
    begin
    // Add Current History
      SetLength( FReportDataSMatr, j + k );

      for i := 0 to k - 1 do
      begin
        PCMSlideHist := CMSHist.P(i);
        SetLength( FReportDataSMatr[j], 6 );
        with PCMSlideHist^ do
        begin
          //***** Date
          FReportDataSMatr[j][0] := K_DateTimeToStr( SHistActTS, 'dd.mm.yyyy' );

          //***** Time
          FReportDataSMatr[j][1] := K_DateTimeToStr( SHistActTS, 'hh:nn:ss AM/PM' );

          //***** User
          FReportDataSMatr[j][2] := K_CMGetProviderDetails( SHistProvID );

          //***** Action
          FReportDataSMatr[j][3] := EDAGetHistActionText( SHistActCode, FALSE,
                                                           TRUE, VideoExt, '' );
          //***** PC name
          FReportDataSMatr[j][4] := K_CMSServerClientInfo.CMSClientVirtualName;

          //***** Location
          FReportDataSMatr[j][5] := K_CMGetLocationDetails( SHistLocID );

        end;
        Inc(j);
      end;
    end
    else
    if K_CMEDAccess is TK_CMEDDBAccess then
    begin
    // Skip Current Session Events
      if FReportDataSMatr[j - 1][3] = K_CMSHistNCActTexts[Ord(K_shNCAStartSession)] then
      begin
        Dec(j);
        if FReportDataSMatr[j - 1][3] = K_CMSHistNCActTexts[Ord(K_shNCACMSStart)] then
          Dec(j);
        SetLength( FReportDataSMatr, j );
      end;
    end;
  end;

  // Show Report
  with TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ReportDataSMatr := FReportDataSMatr;
    PrepareRAFrameByDataSMatr( ReportDetailes );
    FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
    FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);
    ShowModal;
  end;

end; // procedure TK_FormCMChangeSlidesAttrsN2.ShowHistoryExecute

//***********************************  TK_FormCMSetSlidesAttrs.SSASaveValues  ******
// Save State to Slides
//
procedure TK_FormCMChangeSlidesAttrsN2.SSASaveValues;
var
  i  : Integer;
  ChangeAttrsFlag : Boolean;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
  ActCodeDTChange, ActCodeDTReset, ActCodeProps : Integer;
  IDate : Integer;
begin

  ActCodeProps   :=  K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAProps), Ord(K_shPropDiagn) );
  ActCodeDTChange :=  K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAProps), Ord(K_shPropDTChange) );
  ActCodeDTReset  :=  K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAProps), Ord(K_shPropDTReset) );

  for i := 0 to High(SSASlides) do
  begin
    UDSlide := SSASlides[i];
    PCMSlide := UDSlide.P();
    UDSlide.Marker := 0;
    with UDSlide, PCMSlide^  do
    begin
//1        if not (cmsfIsLocked in CMSRFlags) then Continue; // precaution
//2        if (cmsfSkipSlideEdit in CMSRFlags) then Continue; // precaution
      if not (cmsfIsLocked in CMSRFlags) or (cmsfSkipSlideEdit in CMSRFlags) then Continue; // precaution
      ChangeAttrsFlag := FALSE;

    // Teeth Flags
      if CMSTeethFlags <> SSATeethCharts[i] then
      begin
        GetCMSUndoBuf( );
        CMSTeethFlags := SSATeethCharts[i];
        UDSlide.Marker := ActCodeProps;
        ChangeAttrsFlag := TRUE;
      end;

    // Media Type
      if CMSMediaType <> SSAMTypes[i] then begin
        GetCMSUndoBuf( );
        CMSMediaType := SSAMTypes[i];
        UDSlide.Marker := ActCodeProps;
        ChangeAttrsFlag := TRUE;
      end;

    // Diagnoses
      if CMSDiagn <> SSADiagnoses[i] then
      begin
        GetCMSUndoBuf( );
        CMSDiagn := SSADiagnoses[i];
        UDSlide.Marker := ActCodeProps;
        ChangeAttrsFlag := TRUE;
      end;

    // Dates
      if CMSDB.IniDTTaken <> SSAIDates[i] then
      begin
        GetCMSUndoBuf( );
        CMSDB.IniDTTaken := SSAIDates[i];
        if CMSDB.IniDTTaken = 0 then
        begin
//          K_CMEDAccess.EDAAddHistActionToSlideBuffer(UDSlide, ActCodeDTReset );
          UDSlide.Marker := ActCodeDTReset;
        end;
        ChangeAttrsFlag := TRUE;
      end;

      IDate := Trunc(CMSDTTaken);
      if IDate <> SSADates[i] then
      begin
        GetCMSUndoBuf( );
        CMSDTTaken := CMSDTTaken - IDate + SSADates[i];
        if CMSDB.IniDTTaken <> 0 then
        begin
//          K_CMEDAccess.EDAAddHistActionToSlideBuffer(UDSlide, ActCodeDTChange );
          UDSlide.Marker := ActCodeDTChange;
        end;
        ChangeAttrsFlag := TRUE;
      end;

      if CMSDB.DCMModality <> SSADCMAttrs[i].CMDCMModality then
      begin
        CMSDB.DCMModality := SSADCMAttrs[i].CMDCMModality;
        ChangeAttrsFlag := TRUE;
      end;

      if CMSDB.DCMKVP <> SSADCMAttrs[i].CMDCMKVP then
      begin
        CMSDB.DCMKVP := SSADCMAttrs[i].CMDCMKVP;
        ChangeAttrsFlag := TRUE;
      end;

      if CMSDB.DCMTubeCur <> SSADCMAttrs[i].CMDCMTubeCur then
      begin
        CMSDB.DCMTubeCur := SSADCMAttrs[i].CMDCMTubeCur;
        ChangeAttrsFlag := TRUE;
      end;

      if CMSDB.DCMExpTime <> SSADCMAttrs[i].CMDCMExpTime then
      begin
        CMSDB.DCMExpTime := SSADCMAttrs[i].CMDCMExpTime;
        ChangeAttrsFlag := TRUE;
      end;

      if not ChangeAttrsFlag then Continue;
      // Set Modified Attributes

      CMSDTPropMod := K_CMEDAccess.EDAGetSyncTimestamp();
      CMSProvIDModified := K_CMEDAccess.CurProvID; // Provider ID Modified
      CMSLocIDModified  := K_CMEDAccess.CurLocID; // Location ID Modified
      CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;
      Include( CMSRFlags, cmsfAttribsChanged ); // Needed for ECach Only
{
      if (CMSlideEdState <> K_edsFullAccess)  then Continue; //  Skip Saving To ECache Atributes Changes for Video Slides
      Include( CMSlideECSFlags, cmssfAttribsChanged ); // Set Slide Changing FLag for ECache

      if (cmsfIsMediaObj in CMSDB.SFlags) or
         (CMSlideEdState <> K_edsFullAccess)  then Continue; //  Skip Saving To ECache Atributes Changes for Video Slides

      K_CMEDAccess.EDASaveSlideToECache( UDSlide );
      Include( CMSlideECSFlags, cmssfAttribsChanged ); // Set Slide Mark as changed  for  future saving
}
      Inc(SSAProcessedCount);
    end;
  end;

end; // procedure TK_FormCMChangeSlidesAttrsN2.SSASaveValues

//***********************************  TK_FormCMSetSlidesAttrs.ShowLocsInfoExecute  ******
// Show Locations Info Handler (used if EnterpriseMode only)
//
procedure TK_FormCMChangeSlidesAttrsN2.ShowLocsInfoExecute(Sender: TObject);
var
  i, j, k, m, n : Integer;
  SQLText : string;
  SavedCursor: TCursor;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
//  CurImgTS : TDateTime;
  QInd : Integer;
  LocIDs : TN_IArray;
  SkipInds : TN_IArray;

begin

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  with SSAThumbsDGrid, DGMarkedList  do
  begin
    UDSlide := SSASlides[Integer(List[0])];
    PCMSlide := UDSlide.P();
  end;

  with TK_CMEDDBAccess(K_CMEDAccess),
       TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow0' );
    BaseFormInit( nil, 'K_FormCMReportShow0', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    try
      SetLength( ReportDataSMatr, 20 );
      SetLength( ReportDataSMatr[0], 2 );
      ReportDataSMatr[0][0] := 'Status';
      ReportDataSMatr[0][1] := 'Location';

    ////////////////////////////
    // Add Host Info
    //
      SetLength( ReportDataSMatr[1], 2 );
      ReportDataSMatr[1][0] := 'Host';
      ReportDataSMatr[1][1] := K_CMGetLocationDetails( PCMSlide.CMSLocIDHost );
      i := 2;
//      BaseFormInit ( nil ); // ???? повтор???

    ////////////////////////////
    // Add Queued Info
    //
      SQLText := format( 'select distinct ' +  K_CMENDBSFQDstLocID +
        ' from '  + K_CMENDBSyncFilesQueryTable +
        ' where ' + K_CMENDBSFQSlideID + '=%s or ' +
                   K_CMENDBSFQPatID + '=%d', [UDSlide.ObjName, PCMSlide.CMSPatID] );

      with CurDSet1 do
      begin
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;

        j := RecordCount;
        QInd := 0;
        if j > 0 then
        begin
          QInd := i;
          SetLength( LocIDs, j );
          if j + i > Length(ReportDataSMatr) then
            SetLength( ReportDataSMatr, j + i );
          First;
          while not EOF do
          begin
            SetLength( ReportDataSMatr[i], 2 );
            ReportDataSMatr[i][0] := 'Queued';
            j := FieldList.Fields[0].AsInteger;
            LocIDs[i - QInd] := j;
            ReportDataSMatr[i][1] := K_CMGetLocationDetails( j );
            Inc(i);
            Next;
          end;
          Close;
        end;
      end;
      // Get  Selected Data

    ////////////////////////////
    // Add Sync Info
    //
{
      CurImgTS := PCMSlide.CMSDTImgMod;
      if (UDSlide.CMSlideEdState <> K_edsFullAccess) or
         not (cmsfIsLocked in PCMSlide.CMSRFlags)    or
         (cmsfSkipSlideEdit in PCMSlide.CMSRFlags) then
      begin
        with CurDSet1 do
        begin
          Connection := LANDBConnection;
          ExtDataErrorCode := K_eeDBSelect;
          SQL.Text :=
          'select ' + K_CMENDBSTFSlideDTImg +
          ' from ' + K_CMENDBSlidesTable +
          ' where ' + K_CMENDBSTFSlideID + '=' + UDSlide.ObjName;
          Filtered := false;
          Open;
          CurImgTS := FieldList.Fields[0].AsDateTime;
          Close;
        end;
      end;

      SQLText := 'select ' +
        'S.' + K_CMENDBLFALocID + ',' +
        'Q.' + K_CMENDBLFILocSlideTS +
        ' from (select '  + K_CMENDBLFALocID + ' from ' + K_CMENDBLocsFAccessTable +
        ') S LEFT OUTER JOIN (SELECT ' +
        K_CMENDBLFILocID + ',' + K_CMENDBLFILocSlideTS +
        ' from ' + K_CMENDBLocFilesInfoTable +
        ' where ' + K_CMENDBLFILocSlideID + '=' + UDSlide.ObjName +
        ') Q on S.' + K_CMENDBLFALocID + ' = Q.' + K_CMENDBLFILocID;

      with CurDSet1 do
      begin
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        j := RecordCount;
        k := 0;
        if j > 0 then
        begin
          if j + i > Length(ReportDataSMatr) then
            SetLength( ReportDataSMatr, j + i );
          SetLength( SkipInds, Length(LocIDs) );
          First;
          while not EOF do
          begin
            SetLength( ReportDataSMatr[i], 2 );
            j := FieldList.Fields[0].AsInteger;
            if FieldList.Fields[1].IsNull or
               (FieldList.Fields[1].AsDateTime < CurImgTS) then
              ReportDataSMatr[i][0] := 'Not synchronized'
            else
            begin
              ReportDataSMatr[i][0] := 'Synchronized';
              if Length(LocIDs) > 0 then
              begin
                m := K_IndexOfIntegerInRArray( j, @LocIDs[0], Length(LocIDs) );
                if m >= 0 then
                begin
                  SkipInds[k] := m + QInd;
                  Inc(k);
                end;
              end;
            end;
            ReportDataSMatr[i][1] := K_CMGetLocationDetails( j );
            Inc(i);
            Next;
          end;
          Close;
        end;
      end;
}
      SQLText := 'select ' +
        'Q.' + K_CMENDBLFALocID + 
        ' from ' + K_CMENDBLocFilesInfoTable + ' Q, ' + K_CMENDBSlidesTable + ' S ' +
        ' where Q.' + K_CMENDBLFILocSlideID + '=' + UDSlide.ObjName +
        ' and Q.' + K_CMENDBLFILocSlideID + '=S.' +  K_CMENDBSTFSlideID +
        ' and Q.' + K_CMENDBLFILocSlideTS + '=S.' +  K_CMENDBSTFSlideDTImg;

      with CurDSet1 do
      begin
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        j := RecordCount;
        k := 0;
        if j > 0 then
        begin
          if j + i > Length(ReportDataSMatr) then
            SetLength( ReportDataSMatr, j + i );
          SetLength( SkipInds, Length(LocIDs) );
          First;
          while not EOF do
          begin
            SetLength( ReportDataSMatr[i], 2 );
            j := FieldList.Fields[0].AsInteger;
            ReportDataSMatr[i][0] := 'Synchronized';
            if Length(LocIDs) > 0 then
            begin
              m := K_IndexOfIntegerInRArray( j, @LocIDs[0], Length(LocIDs) );
              if m >= 0 then
              begin
                SkipInds[k] := m + QInd;
                Inc(k);
              end;
            end;
            ReportDataSMatr[i][1] := K_CMGetLocationDetails( j );
            Inc(i);
            Next;
          end;
          Close;
        end;
      end;

      if k > 0 then
      begin // Clear Queued
        m := QInd;
        n := 0;
        for j := QInd to High (ReportDataSMatr) do
        begin
          if (n < k) and (SkipInds[n] = j) then Continue;
          Inc(n);
          ReportDataSMatr[m] := ReportDataSMatr[j];
          Inc(m);
        end;

      end;
      SetLength( ReportDataSMatr, i - k );
      PrepareRAFrameByDataSMatr( 'Locations status for Object ID: ' + UDSlide.ObjName );

      Screen.Cursor := SavedCursor;

      ShowModal;
    except
      on E: Exception do
      begin
        raise Exception.Create('ShowLocsInfoExecute Report  ERROR >> ' + E.Message);
      end;
    end;
  end;
end; // procedure TK_FormCMChangeSlidesAttrsN2.ShowLocsInfoExecute


//****************************** TK_FormCMChangeSlidesAttrsN2.ChBUseDTClick ***
// ChBUseDT Click Event Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.ChBUseDTClick(Sender: TObject);
begin
  DTPDTaken.Enabled := ChBUseDT.Checked;
  BtDTReset.Enabled := ChBUseDT.Checked and (SSAIDates[SSAPrevInd] <> 0);
end; // procedure TK_FormCMChangeSlidesAttrsN2.ChBUseDTClick

//**************************** TK_FormCMChangeSlidesAttrsN2.DTPDTakenChange ***
// DTPDTaken Change Event Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.DTPDTakenChange(Sender: TObject);
begin
  if SSAPrevInd = -1 then Exit; // precaution
  SSADates[SSAPrevInd] := Trunc(DTPDTaken.Date);
  SSAIDates[SSAPrevInd] := Trunc(SSASlides[SSAPrevInd].P.CMSDTTaken);
  if SSAIDates[SSAPrevInd] = SSADates[SSAPrevInd] then
    SSAIDates[SSAPrevInd] := 0;
  BtDTReset.Enabled := SSAIDates[SSAPrevInd] <> 0;

end; // procedure TK_FormCMChangeSlidesAttrsN2.DTPDTakenChange

procedure TK_FormCMChangeSlidesAttrsN2.BtDTResetClick(Sender: TObject);
begin
  if SSAPrevInd = -1 then Exit; // precaution
  SSADates[SSAPrevInd] := SSAIDates[SSAPrevInd];
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  DTPDTaken.Date := SSADates[SSAPrevInd];
{$ELSE}         // Delphi 7 and 2010
  // needed to add some time because of TDateTimePicker error in Delphi 7
  DTPDTaken.Date := SSADates[SSAPrevInd] + 1 / (24 * 60 * 60);
{$IFEND CompilerVersion >= 26.0}
  SSAIDates[SSAPrevInd] := 0;
  BtDTReset.Enabled := FALSE;
end;

//******************************** TK_FormCMSetSlidesAttrs2.EdVoltageChange ***
// EdVoltage Change Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.EdVoltageChange(Sender: TObject);
{
var
  WInt : Integer;
  WStr, WStr1 : string;

  procedure ChangeValue( ED : TEdit; var Val : Integer );
  begin
    if not ED.Enabled then Exit;
    WStr1 := Trim(ED.Text);
    WInt := StrToIntDef( WStr1, Val );
    if WInt < 0 then WInt := -WInt;
    Val := WInt;
    WStr := IntToStr( WInt );
    if WStr <> WStr1 then
      ED.Text := WStr;
  end;

  procedure ChangeFValue( ED : TEdit; var Val : Double );
  var
    WF : Double;
  begin
    if not ED.Enabled then Exit;
    WStr1 := Trim(ED.Text);
    WF := Val;
    WF := StrToFloatDef( WStr1, WF );
    if WF < 0 then WF := -WF;
    Val := WF;
    WStr := FloatToStr( WF );
    if WStr <> WStr1 then
      ED.Text := WStr;
  end;
}
begin
  if Sender = EdVoltage then
    ChangeFValue( EdVoltage, SSADCMAttrs[SSAPrevInd].CMDCMKVP )
  else
  if Sender = EdCurrent then
    ChangeValue( EdCurrent, SSADCMAttrs[SSAPrevInd].CMDCMTubeCur )
  else
  if Sender = EdExpTime then
    ChangeValue( EdExpTime, SSADCMAttrs[SSAPrevInd].CMDCMExpTime );

end; // TK_FormCMChangeSlidesAttrsN2.EdVoltageChange

//****************************** TK_FormCMChangeSlidesAttrsN2.CmBModalityChange ***
// CmBModality Change Handler
//
procedure TK_FormCMChangeSlidesAttrsN2.CmBModalityChange(Sender: TObject);
var
  Flag : Boolean;
begin
  if SSAPrevInd < 0 then exit;
  if CmBModality.ItemIndex = -1 then CmBModality.ItemIndex := 0;
  SSADCMAttrs[SSAPrevInd].CMDCMModality := CmBModality.Text;

  Flag := CmBModality.ItemIndex > 3;
  LbVolt.Enabled := Flag;
  EdVoltage.Enabled := Flag;
  if not Flag then
    EdVoltage.Text := ''
  else
    EdVoltage.Text := FloatToStr( SSADCMAttrs[SSAPrevInd].CMDCMKVP );

  LbCur.Enabled := Flag;
  EdCurrent.Enabled := Flag;
  if not Flag then
    EdCurrent.Text := ''
  else
    EdCurrent.Text := IntToStr( SSADCMAttrs[SSAPrevInd].CMDCMTubeCur );

  LbExpTime.Enabled := Flag;
  EdExpTime.Enabled := Flag;
  if not Flag then
    EdExpTime.Text := ''
  else
    EdExpTime.Text := IntToStr( SSADCMAttrs[SSAPrevInd].CMDCMExpTime );

end; // TK_FormCMChangeSlidesAttrsN2.CmBModalityChange

end.
