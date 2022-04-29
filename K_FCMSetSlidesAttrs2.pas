unit K_FCMSetSlidesAttrs2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ExtCtrls,
  N_BaseF, N_CM1, N_CM2, N_DGrid, N_Rast1Fr,
  K_CM0, ToolWin, K_FrCMTeethChart1, N_CMREd3Fr;

type TK_FormCMSetSlidesAttrs2 = class( TN_BaseForm )
    BtResetChart: TButton;

    ActionList1: TActionList;
      ResetChart: TAction;
      CloseCancel: TAction;
      SaveSelected: TAction;
      SelectAll: TAction;
      DeselectAll: TAction;
      RotateLeft: TAction;
      RotateRight: TAction;
      Rotate180: TAction;
      FlipHorizontally: TAction;
      DeleteSelected: TAction;

    LbDiagnoses: TLabel;
    MemoDiagnoses: TMemo;

    Button1: TButton;
    Button2: TButton;
    CmBMediaTypes: TComboBox;
    LbMediaType: TLabel;
    ThumbPanel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    LbDTTaken: TLabel;
    DTPTTaken: TDateTimePicker;
    DTPDTaken: TDateTimePicker;
    ChBUseSlideDT: TCheckBox;
    LbAvailable: TLabel;
    LbVAvailable: TLabel;
    LbProcessed: TLabel;
    LbVProcessed: TLabel;
    PnThumbPA: TPanel;
    CMSTeethChartFrame: TK_FrameCMTeethChart1;
    PnFlipRotate: TPanel;
    FlipRotateToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ChBAutoOpen: TCheckBox;
    LbVolt: TLabel;
    EdVoltage: TEdit;
    LbCur: TLabel;
    EdCurrent: TEdit;
    LbExpTime: TLabel;
    EdExpTime: TEdit;
    LbMod: TLabel;
    CmBModality: TComboBox;


    procedure FormShow           ( Sender: TObject );
    procedure ResetChartExecute  ( Sender: TObject );
    procedure SaveSelectedExecute        ( Sender: TObject );
    procedure CloseCancelExecute ( Sender: TObject );
    procedure FormKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SelectAllExecute(Sender: TObject);
    procedure DeselectAllExecute(Sender: TObject);
    procedure DeleteSelectedExecute(Sender: TObject);
    procedure ChBUseSlideDTClick(Sender: TObject);
    procedure RotateLeftExecute(Sender: TObject);
    procedure RotateRightExecute(Sender: TObject);
    procedure Rotate180Execute(Sender: TObject);
    procedure FlipHorizontallyExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure CmBModalityChange(Sender: TObject);
    procedure EdVoltageChange(Sender: TObject);
  private
    { Private declarations }
    SSAAvailableCount: Integer;
    SSAProcessedCount: Integer;

    ShowFormTimer : TTimer;

    procedure SSADrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SSAGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure SSAChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
    procedure ShowAvailableAndProcessed ();
    procedure TimerEvent(Sender: TObject);
  public
    { Public declarations }
    //*** Slide Fieds Vars
    SSASlides: TN_UDCMSArray;
    SSAIniMediaType: Integer;
    SSAThumbsDGrid: TN_DGridArbMatr;
    SSADrawSlideObj: TN_CMDrawSlideObj;
    SSACloseOnMouseUp : Boolean; // needed to wait closing in TK_FormCMSetSlidesAttrs3
    SSADCMAttrs : TK_CMDCMAttrs;

//    procedure CurStateToMemIni (); override;
//    procedure MemIniToCurState (); override;
end; // type TK_FormCMSetSlidesAttrs2 = class( TN_BaseForm )

function  K_CMSetSlidesAttrs( APSlides: TN_PUDCMSlide; ACount : Integer;
                              APDCMAttrs : TK_PCMDCMAttrs;
                              ACaption : string = '';
                              ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                              AIniMediaType : Integer = 0;
                              ASpecECacheCall : Boolean = FALSE ) : Integer; overload;
function  K_CMSetSlidesAttrs( ASlides: TN_UDCMSArray;
                              APDCMAttrs : TK_PCMDCMAttrs;
                              ACaption : string = '';
                              ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                              AIniMediaType : Integer = 0 ) : Integer; overload;
function  K_CMSetSlidesAttrs( ASlidesCount: Integer;
                              APDCMAttrs : TK_PCMDCMAttrs;
                              ACaption : string = '';
                              ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                              AIniMediaType : Integer = 0 ) : Integer; overload;
procedure K_CMInitSetSlidesAttrsForm( AForm : TK_FormCMSetSlidesAttrs2;
                             APSlides: TN_PUDCMSlide; ACount : Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 );
function  K_CMFinSlidesAttrsForm( AForm : TK_FormCMSetSlidesAttrs2 ) : Integer;
//function  K_CMSaveSlidesAfterSetAttrs( ASlidesCount : Integer ) : Integer;
implementation

{$R *.dfm}

uses Types, DateUtils,
  K_Clib0, K_VFunc, K_Parse, K_CM1, K_CML1F,
  N_Types, N_Comp1, N_Lib0, N_Lib1, N_CMMain5F, N_CMResF, N_Gra6;

//****************************************************** K_CMSetSlidesAttrs ***
// Set properties to last added new Slides
//
//    Parameters
// ASlidesCount - number of last added new Slide  to edit properties
// ACaption - form caption
// AIniMediaType - initial Media Type
//
function K_CMSetSlidesAttrs( ASlidesCount: Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer; overload;
begin
  Result := K_CMSetSlidesAttrs( K_CMGetCurSlidesListLastSlides( ASlidesCount ),
                   APDCMAttrs, ACaption, ASSAFlags, AIniMediaType );
end; // function K_CMSetSlidesAttrs

//****************************************************** K_CMSetSlidesAttrs ***
// Set properties to given Slides
//
//    Parameters
// ASlides - Slide whose properties to Edit
// ACaption - form caption
// AIniMediaType - initial Media Type
//
function K_CMSetSlidesAttrs( ASlides: TN_UDCMSArray;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer; overload;
begin
  Result := 0;
  if Length(ASlides) = 0 then Exit;
  Result := K_CMSetSlidesAttrs( @ASlides[0], Length(ASlides), APDCMAttrs,
                                ACaption,
                                ASSAFlags, AIniMediaType );
end;

//********************************************** K_CMInitSetSlidesAttrsForm ***
// Initialize given Set Slides Attributes Form
//
//    Parameters
// AForm    - Set Slides Attrs Form to initialize
// APSlides - pointer to Slides array first element
// ACount - number of elements in Slides array
// ACaption - form caption
// ASkipProcessDate - skip date while change Objects Properties
// AIniMediaType - initial Media Type
//
procedure K_CMInitSetSlidesAttrsForm( AForm : TK_FormCMSetSlidesAttrs2;
                             APSlides: TN_PUDCMSlide; ACount : Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 );
var
  Ind : Integer;
begin
  K_CMEDAccess.RemovedFromCurSlidesSetCount := 0;
  with AForm do
  begin
//    BaseFormInit( nil, '', [fvfCenter] );

    if N_KeyIsDown(VK_CONTROL) and N_KeyIsDown(VK_SHIFT) then
    begin
      BFFlags := [bffToDump1];
      with N_CM_MainForm do
        N_Dump1Str( format( ' N_CM_MainForm pos:L=%d T=%d W=%d H=%d ', [Left,Top,Width,Height] ) );
    end;

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    if ACaption <> '' then
      Caption := ACaption;

    FlipRotateToolBar.Images := N_CM_MainForm.CMMCurBigIcons;

    DTPDTaken.Enabled := not (K_ssafSkipProcessDate in ASSAFlags);
    DTPTTaken.Enabled := DTPDTaken.Enabled;

    ChBUseSlideDT.Enabled := DTPDTaken.Enabled;
    ChBUseSlideDT.Checked := TRUE;

    ChBAutoOpen.Enabled := not (K_ssafSkipAutoOpen in ASSAFlags);
    if ChBAutoOpen.Enabled then
      ChBAutoOpen.Checked := K_CMSlideAutoOpen;

    SetLength( SSASlides, ACount );
    Move( APSlides^, SSASlides[0], ACount * SizeOf(TN_UDCMSlide) );

    SSAIniMediaType := AIniMediaType;

    SSADrawSlideObj := TN_CMDrawSlideObj.Create();
    SSAThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, SSAGetThumbSize );

    with SSAThumbsDGrid do
    begin
      DGEdges := Rect( 3, 3, 3, 3 );
//      DGEdges := Rect( 3, 3, 3, 12 );
      DGGaps  := Point( 6, 0 );

      DGLFixNumCols   := 0;
      DGLFixNumRows   := 1;
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
//      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor := ColorToRGB(clBtnFace);

      DGMarkNormWidth := 3;
      DGMarkNormShift := 2;

      DGMarkBordColor := $800000;
//      DGNormBordColor := $808080;
//      DGNormBordColor := $BBBBBB;
      DGNormBordColor := DGBackColor;

      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGDrawItemProcObj := SSADrawThumb;
      DGChangeItemStateProcObj := SSAChangeThumbState;
      DGNumItems := Length(SSASlides);
      N_Dump2Str( 'UE >> before DGInitRFrame' );
      SSAThumbsDGrid.DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
      N_Dump2Str( 'UE >> after DGInitRFrame' );
      if Length(SSASlides) = 1 then
      begin
        SSAThumbsDGrid.DGMarkSingleItem( 0 );
        N_Dump2Str( 'UE >> after DGMarkSingleItem' );
      end
      else
        SSAChangeThumbState( SSAThumbsDGrid, 0 );
    end; // with ThumbsDGrid do

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

/////////////////////////////////////////////////////
// Code Moved From Form Show to prevent strange behaviour -
// Form stay hidden after ShowModal
//

{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
    ThumbsRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}
    DoubleBuffered := True;
    SSAAvailableCount := Length(SSASlides);
    SSAProcessedCount := 0;
    ShowAvailableAndProcessed();

    N_Dump2Str( 'UE >> before ShowTeethChartState' );
    CMSTeethChartFrame.ShowTeethChartState( 0 );
    N_Dump2Str( 'UE >> after ShowTeethChartState' );

    with CmBMediaTypes do
    begin
      K_CMEDAccess.EDAGetAllMediaTypes( Items );
      ItemIndex := Items.IndexOfObject( TObject(SSAIniMediaType) );
      if ItemIndex < 0 then ItemIndex := 0;
    end;
    MemoDiagnoses.Lines.Text := '';
    DTPDTaken.DateTime := K_CMEDAccess.EDAGetSyncTimestamp();
    DTPTTaken.DateTime := DTPDTaken.DateTime;
    DTPDTaken.MaxDate  := DTPDTaken.DateTime;
//    DTPTTaken.MaxDate  := DTPDTaken.DateTime;
//
/////////////////////////////////////////
    if APDCMAttrs <> nil then
      for Ind := 0 to High(SSASlides) do
        TN_UDCMSlide( SSASlides[Ind] ).SetInitDCMAttrs( APDCMAttrs ); // Set Initial DCM Attrs

    K_CMPrepDialogDCMAttrs( APDCMAttrs, SSADCMAttrs );
{
    if SSADCMAttrs.CMDCMKVP = 0 then
      SSADCMAttrs.CMDCMKVP := K_CMSlideDefDCMKVP;

    if SSADCMAttrs.CMDCMTubeCur = 0 then
      SSADCMAttrs.CMDCMTubeCur := K_CMSlideDefDCMTubeCur;

    if SSADCMAttrs.CMDCMExpTime = 0 then
      SSADCMAttrs.CMDCMExpTime := K_CMSlideDefDCMExpTime;
}

{
    CmBModality.Items.Clear;
    CmBModality.Items.Add('');
    CmBModality.Items.Add(K_CMSlideDefDCMModColorXC);
    CmBModality.Items.Add(K_CMSlideDefDCMModXRayCR);
    CmBModality.Items.Add(K_CMSlideDefDCMModXRayPan);

    if K_CMSlideDefDCMModXRayCR = SSADCMAttrs.CMDCMModality then
      Ind := 2
    else
    begin
      Ind := CmBModality.Items.IndexOf( SSADCMAttrs.CMDCMModality );
      if Ind < 0 then Ind := 0;
    end;
}
    K_FillDICOMModalitiesList( CmBModality.Items );
    Ind := CmBModality.Items.IndexOf( SSADCMAttrs.CMDCMModality );
    if Ind < 0 then Ind := 0;

    CmBModality.ItemIndex := Ind;
    CmBModalityChange( CmBModality );

//    if N_KeyIsDown(VK_CONTROL) and N_KeyIsDown(VK_SHIFT) then
    begin
//      ShowFormTimer := TTimer.Create(nil); !!! Error nobody destroy ShowFormTimer
      ShowFormTimer := TTimer.Create(AForm);
      ShowFormTimer.Interval := 100;
      ShowFormTimer.OnTimer := TimerEvent;
    end;

    FormStyle := fsStayOnTop;
  end;
end; // end of K_CMInitSetSlidesAttrsForm

//************************************************** K_CMFinSlidesAttrsForm ***
// Finalize given Set Slides Attributes Form
//
//    Parameters
// AForm    - Set Slides Attrs Form to initialize
//
function K_CMFinSlidesAttrsForm( AForm : TK_FormCMSetSlidesAttrs2 ) : Integer;
var
  i : Integer;
begin

  with AForm do
  begin
    for i := 0 to High(SSASlides) do
    begin
      TN_UDCMSlide( SSASlides[i] ).ObjAliase := '';
      TN_UDCMSlide( SSASlides[i] ).CMSAutoOpen := ChBAutoOpen.Checked;
    end;
    Result := SSAAvailableCount + SSAProcessedCount;

    SSAThumbsDGrid.Free;
    SSADrawSlideObj.Free;
    if ChBAutoOpen.Enabled then
      K_CMSlideAutoOpen := ChBAutoOpen.Checked;
  end;
end; // end of K_CMFinSlidesAttrsForm
{
//********************************************* K_CMSaveSlidesAfterSetAttrs ***
// Save Slides after Set Slides Attributes Dialog
//
//    Parameters
// ASlidesCount - number of slides to save
//
function K_CMSaveSlidesAfterSetAttrs( ASlidesCount : Integer ) : Integer;
var
  i : Integer;
  PUDCMSlide : TN_PUDCMSlide;
  UDSlide : TN_UDCMSlide;

begin
  Result := ASlidesCount;
  with K_CMEDAccess, CurSlidesList do
  begin
    PUDCMSlide := TN_PUDCMSlide(@List[Count - Result]);

    if 0 = EDACheckFilesAccessBySlidesSet( PUDCMSlide, Result,
           K_CML1Form.LLLFileAccessCheck14.Caption + ' ' + K_CML1Form.LLLPressOkToClose.Caption
//             #13#10'Your objects will be saved in the temporary folder. Press OK to close Media Suite.'
            ) then
    begin
      EDASaveSlidesArray( PUDCMSlide, Result );
      EDASetPatientSlidesUpdateFlag();
    end
    else
    begin
     // Remove Slides From CurSlidesList
      for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
      begin
        UDSlide := TN_UDCMSlide(CurSlidesList[i]);
        N_Dump1Str( 'SSA>> Del from CurSet Slide ID=' + UDSlide.ObjName );
        K_CMDeleteClientMediaFile( UDSlide );
        CurSlidesList.Delete( i );
        UDSlide.UDDelete;
      end; // for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
      Result := 0;
      K_CMSkipSlidesSavingFlag := TRUE;
      K_CMCloseOnFinActionFlag := TRUE;
    end; // for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
  end; // with K_CMEDAccess, CurSlidesList do
end; // end of K_CMSaveSlidesAfterSetAttrs
}

//****************************************************** K_CMSetSlidesAttrs ***
// Set properties to given Slides
//
//    Parameters
// APSlides - pointer to Slides array first element
// ACount - number of elements in Slides array
// ACaption - form caption
// ASkipProcessDate - skip date while change Objects Properties
// AIniMediaType - initial Media Type
// ASpecECacheCall - special call from ECache procedure
//
function K_CMSetSlidesAttrs( APSlides: TN_PUDCMSlide; ACount : Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0;
                             ASpecECacheCall : Boolean = FALSE ) : Integer; overload;
var
  FForm : TK_FormCMSetSlidesAttrs2;
begin
  N_Dump2Str( 'Start K_CMSetSlidesAttrs' );
  Result := 0;
  if (APSlides = nil) or (ACount = 0) then Exit;

  FForm := TK_FormCMSetSlidesAttrs2.Create(Application);

  K_CMInitSetSlidesAttrsForm( FForm,  APSlides, ACount, APDCMAttrs,
                              ACaption, ASSAFlags,
                              AIniMediaType );
  with FForm do
  begin
    if Length(SSASlides) = 1 then
    begin
      N_Dump2Str( 'UE >> before DGMarkSingleItem 2' );
      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      N_Dump2Str( 'UE >> after DGMarkSingleItem 2' )
    end
    else
      SSAChangeThumbState( SSAThumbsDGrid, 0 );

    PnThumbPA.Visible      := not ASpecECacheCall;
    DeleteSelected.Visible := not ASpecECacheCall;
    DeselectAll.Visible    := not ASpecECacheCall;
    SelectAll.Visible      := not ASpecECacheCall;
    CloseCancel.Visible    := not ASpecECacheCall;
    ChBAutoOpen.Visible    := not ASpecECacheCall;

    N_Dump1Str( 'Before TK_FormCMSetSlidesAttrs2.ShowModal' );
    ShowModal;
    N_Dump1Str( 'After TK_FormCMSetSlidesAttrs2.ShowModal' );

    if K_CMD4WAppFinState then Exit; // Application is already finished

    N_CM_MainForm.CMMCurFMainForm.Refresh(); // To Clear Modal Form Window

    Result := K_CMFinSlidesAttrsForm(FForm);

    if not ASpecECacheCall and (Result > 0) then
      Result := K_CMSaveLastInCurSlidesList( Result );
  end; // with FForm do
  N_Dump2Str( 'Fin K_CMSetSlidesAttrs' );
end; // end of K_CMSetSlidesAttrs

//*************************************** TK_FormCMSetSlidesAttrs2.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSetSlidesAttrs2.FormShow(Sender: TObject);
begin
  Self.Refresh();

  N_Dump1Str( 'Fin TK_FormCMSetSlidesAttrs2.FormShow' );

end; // end of TK_FormCMSetSlidesAttrs2.FormShow

//************************************* TK_FormCMSetSlidesAttrs2.TimerEvent ***
// Form Show Handler
//
procedure TK_FormCMSetSlidesAttrs2.TimerEvent(Sender: TObject);
var
  IsAlt : Boolean;
  IsCtrl : Boolean;
  IsShift : Boolean;
begin
  IsAlt := (Windows.GetKeyState(VK_MENU)     and $8000) <> 0;
  IsCtrl := (Windows.GetKeyState(VK_CONTROL) and $8000) <> 0;
  IsShift := (Windows.GetKeyState(VK_SHIFT)  and $8000) <> 0;
  if IsAlt then
  begin
    if IsCtrl then
    begin
      ShowFormTimer.Enabled := FALSE;
      FreeAndNil( ShowFormTimer );
      SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0,
                    SWP_NOMOVE or SWP_NOSIZE );
    end
    else
    if IsShift then
      Self.Refresh();

    if IsCtrl or IsShift then
      N_Dump1Str( format('TK_FormCMSetSlidesAttrs2.TimerEvent Alt=%s Shift=%s Ctrl=%',
                  [N_B2S(IsAlt),N_B2S(IsShift),N_B2S(IsCtrl)] ) );
  end;

end; // end of TK_FormCMSetSlidesAttrs2.TimerEvent

//****************************** TK_FormCMSetSlidesAttrs2.ResetChartExecute ***
// Reset Teeth Chart Action Execute
//
procedure TK_FormCMSetSlidesAttrs2.ResetChartExecute(Sender: TObject);
begin
  CMSTeethChartFrame.ShowTeethChartState( 0 );
end; // end of TK_FormCMSetSlidesAttrs2.ResetChartExecute

//**************************** TK_FormCMSetSlidesAttrs2.SaveSelectedExecute ***
// Form OK Action Execute
//
procedure TK_FormCMSetSlidesAttrs2.SaveSelectedExecute(Sender: TObject);
var
  i, RN, CN, SN : Integer;
  FIndexes : TN_IArray;
  UDCMSlide : TN_UDCMSlide;
  ResDCMAttrs : TK_CMDCMAttrs;
begin
  N_Dump2Str( 'Start TK_FormCMSetSlidesAttrs2.SaveSelectedExecute' );

  K_CMPrepSlideDCMAttrs( @SSADCMAttrs, ResDCMAttrs );
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count = 0 then Exit; // Nothing to do
  // set selected slides attributes
    SN := Count;
    for i := 0 to SN - 1 do
    begin
      UDCMSlide := SSASlides[Integer(List[i])];
      with UDCMSlide, P()^ do
      begin
      // DCM Attrs
        SetInitDCMAttrs( @ResDCMAttrs );
      // Teeth Flags
        CMSTeethFlags := CMSTeethChartFrame.TCFrTeethChartState;
      // Media Type
        with CmBMediaTypes do
          if ItemIndex >=0 then
            CMSMediaType := Integer( CmBMediaTypes.Items.Objects[ItemIndex] );
      // Date Taken
        if not ChBUseSlideDT.Checked then
          CMSDTTaken := DateOf(DTPDTaken.Date) + TimeOf(DTPTTaken.Time);
      // Diagnoses
        CMSDiagn := MemoDiagnoses.Lines.Text;

        ObjAliase := ''; // Clear UDSlide Aliase
        N_Dump2Str( 'SSA>> Set Slide ID=' + ObjName +
                    ' TeethFlags=' + IntToHex( CMSTeethFlags, 16 ) +
                    ' MTypeInd=' + IntToStr( CMSMediaType ) +
                    ' DTaken=' + K_DateTimeToStr( CMSDTTaken ) );
        CMSlideECSFlags  := [cmssfAttribsChanged];
        K_CMEDAccess.EDASaveSlideToECache( UDCMSlide );
        CMSAutoOpen := ChBAutoOpen.Checked;
      end; // with UDCMSlide, P()^ do
    end; // for i := 0 to SN - 1 do
  // Remove selected slides from slides array
    CN := Length(SSASlides);
    RN := CN - SN;
    if RN > 0 then
    begin
      SetLength( FIndexes, RN );
      K_BuildXORIndices( @FIndexes[0], PInteger(@List[0]), Count, CN, true );
      K_MoveVectorBySIndex( SSASlides[0], -1, SSASlides[0], -1, SizeOf(Integer),
                            RN,  @FIndexes[0] );
    end; // if RN > 0 then

    if (RN = 0) and not SSACloseOnMouseUp then
    begin
      CloseCancelExecute(Sender)
    end
    else
    begin

//      DGMarkSingleItem( -1 );

      SetLength( SSASlides, RN );
      SSAAvailableCount := RN;
      Inc( SSAProcessedCount, SN );
      ShowAvailableAndProcessed();


      DGNumItems := RN;

      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set

      ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
    // Clear Some previous Properties
      ResetChartExecute(Sender);
      MemoDiagnoses.Lines.Text := '';
    end; // if RN > 0 then

    SSAChangeThumbState( SSAThumbsDGrid, -1 );
  end; // with SSAThumbsDGrid, DGMarkedList do
  N_Dump2Str( 'Fin TK_FormCMSetSlidesAttrs2.SaveSelectedExecute' );
end; // end of TK_FormCMSetSlidesAttrs2.SaveSelectedExecute

//***************************** TK_FormCMSetSlidesAttrs2.CloseCancelExecute ***
// Form OK Action Execute
//
procedure TK_FormCMSetSlidesAttrs2.CloseCancelExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
end; // end of TK_FormCMSetSlidesAttrs2.CloseCancelExecute

//*********************************** TK_FormCMSetSlidesAttrs2.SSADrawThumb ***
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
procedure TK_FormCMSetSlidesAttrs2.SSADrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if (DGItemsFlags[AInd] = 0) and (Count = 1) then
    begin
      SaveSelected.Enabled   := FALSE;
      DeleteSelected.Enabled := FALSE;
      DeselectAll.Enabled := FALSE;
    end;

    with N_CM_GlobObj do
    begin
      CMStringsToDraw[0] := SSASlides[AInd].GetUName;
      if ChBUseSlideDT.Enabled then
      begin // Use Thumbnail Additional Text Lines for Date and Time
        with SSASlides[AInd].P()^ do
        begin
          CMStringsToDraw[1] := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
          CMStringsToDraw[2] := K_DateTimeToStr( CMSDTTaken, 'hh":"nn":"ss' );
        end;
        SSADrawSlideObj.DrawOneThumb9( SSASlides[AInd],
                                 CMStringsToDraw, 3,
                                 SSAThumbsDGrid, ARect,
                                 DGItemsFlags[AInd] );
      end
      else
      begin

        SSADrawSlideObj.DrawOneThumb2( SSASlides[AInd],
                                       CMStringsToDraw, SSAThumbsDGrid, ARect, 0 );
      end;
    end; // with N_CM_GlobObj do
  end; // with SSAThumbsDGrid, DGMarkedList do
end; // end of TK_FormCMSetSlidesAttrs2.SSADrawThumb

//******************************** TK_FormCMSetSlidesAttrs2.SSAGetThumbSize ***
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
procedure TK_FormCMSetSlidesAttrs2.SSAGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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
end; // procedure TK_FormCMSetSlidesAttrs2.SSAGetThumbSize

//**************************** TK_FormCMSetSlidesAttrs2.SSAChangeThumbState ***
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMSetSlidesAttrs2.SSAChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
var
  i, VideoCount : Integer;
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    VideoCount := 0;
    for i := 0 to Count - 1 do
      if cmsfIsMediaObj in SSASlides[Integer(List[i])].P^.CMSDB.SFlags then
        Inc(VideoCount);
    RotateLeft.Enabled       := (Count > 0) and (VideoCount = 0);
    RotateRight.Enabled      := RotateLeft.Enabled;
    Rotate180.Enabled        := RotateLeft.Enabled;
    FlipHorizontally.Enabled := RotateLeft.Enabled;
    SaveSelected.Enabled   := (Count > 0) and (K_CMSMainUIShowMode <> 1);
    DeleteSelected.Enabled := Count > 0;
    DeselectAll.Enabled := Count > 0;
    SelectAll.Enabled := Count <> Length(SSASlides);
  end;

end; // end of TK_FormCMSetSlidesAttrs2.SSAChangeThumbState

//********************** TK_FormCMSetSlidesAttrs2.ShowAvailableAndProcessed ***
// Show Available and Processed
//
procedure TK_FormCMSetSlidesAttrs2.ShowAvailableAndProcessed;
begin
  LbVAvailable.Caption := IntToStr( SSAAvailableCount );
  LbVProcessed.Caption := IntToStr( SSAProcessedCount );
end; // end of TK_FormCMSetSlidesAttrs2.ShowAvailableAndProcessed

//************************************ TK_FormCMSetSlidesAttrs2.FormKeyDown ***
//  Form Key Down Handler
//
procedure TK_FormCMSetSlidesAttrs2.FormKeyDown( Sender: TObject;
                                       var Key: Word; Shift: TShiftState );
begin
  if not( [ssAlt] = Shift ) then Exit;
  if Key = $4D then
  begin          // Alt + M
    CmBMediaTypes.SetFocus;
    CmBMediaTypes.DroppedDown := true;
  end
  else
  if (Key = $54) and DTPDTaken.Enabled then // Alt + T
  begin
    DTPDTaken.SetFocus;
  end
  else
  if Key = $44 then // Alt + D
  begin
    MemoDiagnoses.SetFocus;
    MemoDiagnoses.SelStart := 0;
    MemoDiagnoses.SelLength := MaxInt;
  end;
end; // end of TK_FormCMSetSlidesAttrs2.FormKeyDown

//******************************* TK_FormCMSetSlidesAttrs2.SelectAllExecute ***
//
procedure TK_FormCMSetSlidesAttrs2.SelectAllExecute(Sender: TObject);
begin
  SSAThumbsDGrid.DGSetAllItemsState( ssmMark );
end; // end of TK_FormCMSetSlidesAttrs2.SelectAllExecute

//***************************** TK_FormCMSetSlidesAttrs2.DeselectAllExecute ***
//
procedure TK_FormCMSetSlidesAttrs2.DeselectAllExecute(Sender: TObject);
begin
  SSAThumbsDGrid.DGSetAllItemsState( ssmUnmark );
end; // end of TK_FormCMSetSlidesAttrs2.DeselectAllExecute

//********************************** TK_FormCMSetSlidesAttrs2.DeleteExecute ***
//
procedure TK_FormCMSetSlidesAttrs2.DeleteSelectedExecute(Sender: TObject);

var
  i, RN, CN, SN : Integer;
  DIndexes : TN_IArray;
  UDSlide : TN_UDCMSlide;

  DelSlides: TN_UDCMSArray;
  DelConf : Boolean;
begin

  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count = 0 then Exit; // Nothing to do
  // set selected slides attributes
    SN := Count;
    RN := Length(SSASlides);
    SetLength( DIndexes, RN );

    SetLength( DelSlides, SN );
    K_MoveVectorBySIndex( DelSlides[0], -1,
                          SSASlides[0], -1, SizeOf(Integer),
                          SN,  PInteger(@(List[0])) );
{ //!! New code Deletion Dlg }
//    FormStyle := fsNormal;
    DelConf := Sender = nil;
    if not DelConf then
      DelConf := K_CMSlidesDelConfirmDlg( @DelSlides[0], SN, FALSE );
//    FormStyle := fsStayOnTop;
    if not DelConf then Exit;
{}//!! New code Deletion Dlg
    for i := 0 to SN - 1 do
    begin
      UDSlide := DelSlides[i];
      K_CMDeleteClientMediaFile( UDSlide );
      N_Dump2Str( 'SSA>> Del Slide ID=' + UDSlide.ObjName );
      K_CMEDAccess.EDARemoveSlide(UDSlide);
    end;
  // Remove selected slides from slides array
    CN := RN;
    RN := CN - SN;
    if RN > 0 then
    begin
      SetLength( DIndexes, RN );
      K_BuildXORIndices( @DIndexes[0], PInteger(@List[0]), SN, CN, TRUE );
      K_MoveVectorBySIndex( SSASlides[0], -1, SSASlides[0], -1, SizeOf(Integer),
                            RN,  @DIndexes[0] );
    end;

  // Remove selected slides from slides array
    SetLength( SSASlides, RN );
    SSAAvailableCount := RN;
    if RN = 0 then
    begin
      if Sender <> nil then
        CloseCancelExecute(Sender)
    end
    else
    begin
//      Inc( SSAProcessedCount, SN );
      ShowAvailableAndProcessed();
      DGNumItems := RN;
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
      ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
      SSAChangeThumbState( SSAThumbsDGrid, -1 );
    end;
  end;

end; // end of TK_FormCMSetSlidesAttrs2.DeleteExecute

procedure TK_FormCMSetSlidesAttrs2.ChBUseSlideDTClick(Sender: TObject);
begin
  DTPDTaken.Enabled := not ChBUseSlideDT.Checked;
  DTPTTaken.Enabled := not ChBUseSlideDT.Checked;
end; // end of TK_FormCMSetSlidesAttrs2.ChBUseDTClick

//****************************** TK_FormCMSetSlidesAttrs2.RotateLeftExecute ***
// Rotate current Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// RotateLeft action OnExecute handler
//
procedure TK_FormCMSetSlidesAttrs2.RotateLeftExecute(Sender: TObject);
var
  SelectedInds : TN_IArray;
  i : Integer;
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count <= 0 then Exit;
    DGGetSelection( SelectedInds );
    for i := 0 to Count - 1 do
      K_CMFlipRotateSlideImage( SSASlides[Integer(List[i])], 90, 0, TRUE );

    DGInitRFrame();
    DGSetSelection( SelectedInds );
  end;

end; // end of TK_FormCMSetSlidesAttrs2.RotateLeftExecute

//***************************** TK_FormCMSetSlidesAttrs2.RotateRightExecute ***
// Rotate current Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// RotateRight action OnExecute handler
//
procedure TK_FormCMSetSlidesAttrs2.RotateRightExecute(Sender: TObject);
var
  SelectedInds : TN_IArray;
  i : Integer;
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count <= 0 then Exit;
    DGGetSelection( SelectedInds );
    for i := 0 to Count - 1 do
      K_CMFlipRotateSlideImage( SSASlides[Integer(List[i])], -90, 0, TRUE );
    DGInitRFrame();
    DGSetSelection( SelectedInds );
  end;

end; // end of TK_FormCMSetSlidesAttrs2.RotateRightExecute

//******************************* TK_FormCMSetSlidesAttrs2.Rotate180Execute ***
// Rotate current Image by 180 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// Rotate180 action OnExecute handler
//
procedure TK_FormCMSetSlidesAttrs2.Rotate180Execute(Sender: TObject);
var
  SelectedInds : TN_IArray;
  i : Integer;
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count <= 0 then Exit;
    DGGetSelection( SelectedInds );
    for i := 0 to Count - 1 do
      K_CMFlipRotateSlideImage( SSASlides[Integer(List[i])], 180, 0, TRUE );
    DGInitRFrame();
    DGSetSelection( SelectedInds );
  end;
end; // end of TK_FormCMSetSlidesAttrs2.Rotate180Execute

//************************ TK_FormCMSetSlidesAttrs2.FlipHorizontallyExecute ***
// Flip current Image Horizontally
//
//     Parameters
// Sender - Event Sender
//
// Rotate180 action OnExecute handler
//
procedure TK_FormCMSetSlidesAttrs2.FlipHorizontallyExecute(
  Sender: TObject);
var
  SelectedInds : TN_IArray;
  i : Integer;
begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
    if Count <= 0 then Exit;
    DGGetSelection( SelectedInds );
    for i := 0 to Count - 1 do
      K_CMFlipRotateSlideImage( SSASlides[Integer(List[i])], 0, N_FlipHorBit, TRUE );
    DGInitRFrame();
    DGSetSelection( SelectedInds );
  end;
end; // end of TK_FormCMSetSlidesAttrs2.FlipHorizontallyExecute

//************************************** TK_FormCMSetSlidesAttrs2.FormClose ***
// Form Close Handler
//
procedure TK_FormCMSetSlidesAttrs2.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  N_Dump2Str( 'Fin TK_FormCMSetSlidesAttrs2.FormClose' );
  CMSTeethChartFrame.FreeFrameObjects();
  ThumbsRFrame.RFFreeObjects();
  inherited;
end; // procedure TK_FormCMSetSlidesAttrs2.FormClose

//****************************** TK_FormCMSetSlidesAttrs2.CmBModalityChange ***
// CmBModality Change Handler
//
procedure TK_FormCMSetSlidesAttrs2.CmBModalityChange(Sender: TObject);
var
  Flag : Boolean;
begin
  SSADCMAttrs.CMDCMModality := CmBModality.Text;
  Flag := CmBModality.ItemIndex > 3;
  LbVolt.Enabled := Flag;
  EdVoltage.Enabled := Flag;
  if not Flag then
    EdVoltage.Text := ''
  else
    EdVoltage.Text := FloatToStr( SSADCMAttrs.CMDCMKVP );

  LbCur.Enabled := Flag;
  EdCurrent.Enabled := Flag;
  if not Flag then
    EdCurrent.Text := ''
  else
    EdCurrent.Text := IntToStr( SSADCMAttrs.CMDCMTubeCur );

  LbExpTime.Enabled := Flag;
  EdExpTime.Enabled := Flag;
  if not Flag then
    EdExpTime.Text := ''
  else
    EdExpTime.Text := IntToStr( SSADCMAttrs.CMDCMExpTime );

end; // TK_FormCMSetSlidesAttrs2.CmBModalityChange

//******************************** TK_FormCMSetSlidesAttrs2.EdVoltageChange ***
// EdVoltage Change Handler
//
procedure TK_FormCMSetSlidesAttrs2.EdVoltageChange(Sender: TObject);
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

begin
  if Sender = EdVoltage then
    ChangeFValue( EdVoltage, SSADCMAttrs.CMDCMKVP )
  else
  if Sender = EdCurrent then
    ChangeValue( EdCurrent, SSADCMAttrs.CMDCMTubeCur )
  else
  if Sender = EdExpTime then
    ChangeValue( EdExpTime, SSADCMAttrs.CMDCMExpTime );

end; // TK_FormCMSetSlidesAttrs2.EdVoltageChange

end.
