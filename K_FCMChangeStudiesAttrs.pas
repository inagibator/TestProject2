unit K_FCMChangeStudiesAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList, ComCtrls, ExtCtrls,
  N_Types, N_BaseF, N_CM1, N_CM2, N_DGrid, N_Rast1Fr, N_CMREd3Fr,
  K_CM0;

type TK_FormCMChangeStudiesAttrs = class( TN_BaseForm )

    ActionList1: TActionList;
    CloseCancel: TAction;

    LbDiagnoses: TLabel;
    MemoDiagnoses: TMemo;
    ThumbPanel: TPanel;

    ThumbsRFrame: TN_Rast1Frame;
    BtCancel: TButton;
    Button4: TButton;
    CMStudyFrame: TN_CMREdit3Frame;
    LbDTTaken: TLabel;
    DTPDTaken: TDateTimePicker;
    DTPTTaken: TDateTimePicker;
    GBStudyName: TGroupBox;
    EdStudyName: TEdit;
    GBSudyColor: TGroupBox;
    CmBStudyColor: TComboBox;

    procedure FormShow           ( Sender: TObject );
    procedure CloseCancelExecute ( Sender: TObject );
    procedure FormKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
//    procedure SetValues1Execute(Sender: TObject);
    procedure CmBStudyColorChange(Sender: TObject);
    procedure EdStudyNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    SSAProcessedCount: Integer;
    SSAColors : TN_IArray;
    SSANotes  : TN_SArray;
    SSANames     : TN_SArray;
    SSAPrevInd : Integer;

    procedure SSADrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SSAGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure SSAInitialiseControls();
    procedure SSAChangeThumbState( ADGObj: TN_DGridBase; AInd: integer );
    procedure SSASaveValues();
  public
    { Public declarations }
    //*** Slide Fieds Vars
    SSASlides: TN_UDCMSArray;
    SSAThumbsDGrid: TN_DGridArbMatr;
    SSADrawSlideObj: TN_CMDrawSlideObj;
//    procedure CurStateToMemIni (); override;
//    procedure MemIniToCurState (); override;
end; // type TK_FormCMSetSlidesAttrs = class( TN_BaseForm )

function  K_CMChangeStudiesAttrsDlg( APSlides : TN_PUDCMSlide; ASlidesCount : Integer;
                                    ACaption : string = '' ) : Integer;

var
  K_FormCMChangeStudiesAttrs: TK_FormCMChangeStudiesAttrs;

implementation
{$R *.dfm}
uses Types, Math,
  K_Clib0, K_VFunc, K_FCMReportShow, K_CML1F,
  N_Comp1, N_Lib0, N_Lib1, N_CMMain5F;

//************************************************ K_CMChangeSlidesAttrsDlg ***
// Set properties to given Slides
//
//    Parameters
// APSlides   - pointer to slides array start element to change attributes
// APSlidesCount - slides to change attributes counter
// ACaption - form caption
// AIniMediaType - initial Media Type
//
function K_CMChangeStudiesAttrsDlg( APSlides : TN_PUDCMSlide; ASlidesCount : Integer;
                                ACaption : string = '' ) : Integer;
var
  i : Integer;
  FSaveValues : Boolean;
begin
  Result := 0;
  if ASlidesCount = 0 then Exit;

  K_FormCMChangeStudiesAttrs := TK_FormCMChangeStudiesAttrs.Create( Application );

  with K_FormCMChangeStudiesAttrs do
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
  //
    SetLength( SSAColors, ASlidesCount );
    SetLength( SSANotes, ASlidesCount );
    SetLength( SSANames, ASlidesCount );
    for i := 0 to ASlidesCount - 1 do
    begin
      with SSASlides[i].P()^ do
      begin
        SSAColors[i] := CMSMediaType;
        SSANotes[i] := CMSDiagn;
        SSANames[i] := CMSSourceDescr;
      end;
    end;

  // end of
  //////////////////////////////////

    SSADrawSlideObj := TN_CMDrawSlideObj.Create();
    SSAThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, SSAGetThumbSize );

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

      DGLAddDySize    := 4 + N_CM_ThumbFrameRowHeight * 2; // see DGLItemsAspect
      DGDrawItemProcObj := SSADrawThumb;
      DGChangeItemStateProcObj := SSAChangeThumbState;
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

    with CMStudyFrame do
    begin
      RFrame.RFDebName := Name;
      RFrame.PaintBox.OnDblClick := nil;

      RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
      RFrame.OCanvBackColor := RFrame.DstBackColor;
      RFrame.RFCenterInDst := True;
      RFrame.RFrInitByComp( nil );
      RFrame.aFitInWindowExecute( nil );
    end; // with RFrame do

    with CmBStudyColor do
    begin
      OnDrawItem  := N_CM_MainForm.OnComboBoxColorItemDraw;
      Items.Clear;
      Items.AddStrings( N_CM_MainForm.CMMStudyColorsList );
      ItemIndex := 0;
    end;

    EdStudyName.Text := '';

//    SSAThumbsDGrid.DGMarkSingleItem(0);

    FSaveValues := ShowModal = mrOK;

    SSAThumbsDGrid.DGMarkSingleItem( -1 ); // Unmark all Items - needed to save current Item values
//    SSAInitialiseControls();  // not needed to save current Item values
    if FSaveValues then
      SSASaveValues();
    Result := SSAProcessedCount;

    SSAThumbsDGrid.Free;
    SSADrawSlideObj.Free;
    ThumbsRFrame.RFFreeObjects();
    CMStudyFrame.RFrame.RFFreeObjects();
  end; // with EditRecordForm do

  K_FormCMChangeStudiesAttrs := nil;
end; // end of K_CMChangeSlidesAttrsDlg

//************************************* TK_FormCMChangeSlidesAttrsN2.FormShow ***
// Form Show Handler
//
procedure TK_FormCMChangeStudiesAttrs.FormShow(Sender: TObject);
begin
  inherited;

//  BFDumpCoords( 'TK_FormCMChangeSlidesAttrsN.FormShow 1' );
  SSAProcessedCount := 0;
  MemoDiagnoses.Lines.Text := '';
  SSAThumbsDGrid.DGSetItemState( 0, ssmMark );
  SSAThumbsDGrid.DGSelectItem( 0 );
//  if Length(SSASlides) = 1 then
//    SSAThumbsDGrid.DGSetItemState( 0, ssmMark )
//  else
//    InitialiseControls();
end; // end of TK_FormCMChangeSlidesAttrsN2.FormShow
{
//************************************** TK_FormCMChangeSlidesAttrsN2.SetValues1Execute ***
// Set Values to Selected Action Execute
//
procedure TK_FormCMChangeStudiesAttrs.SetValues1Execute(Sender: TObject);
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
}
//******************************* TK_FormCMChangeSlidesAttrsN2.CloseCancelExecute ***
// Form OK Action Execute
//
procedure TK_FormCMChangeStudiesAttrs.CloseCancelExecute(Sender: TObject);
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
procedure TK_FormCMChangeStudiesAttrs.SSADrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  Flags : Byte;
  LinesCount : Integer;
begin
  if (SSAThumbsDGrid.DGItemsFlags[AInd] = 0) and
     (AInd = SSAPrevInd) then
  begin
  // Save PrevSelected Values Values
    SSANotes[SSAPrevInd] := MemoDiagnoses.Lines.Text;
    SSANames[SSAPrevInd] := Trim(EdStudyName.Text);
    SSAColors[SSAPrevInd] := CmBStudyColor.ItemIndex;

    // Clear Controls
    // Study Name
    EdStudyName.Text := '';
    EdStudyName.Enabled := FALSE;
    // Study Colors
    CmBStudyColor.ItemIndex := 0;
    CmBStudyColor.Enabled := FALSE;
    // Study Notes
    MemoDiagnoses.Lines.Text := '';
    MemoDiagnoses.Enabled := FALSE;

    // Study Picture
    with CMStudyFrame do
    begin
      EdSlide    := nil;
      RFrame.RFrInitByComp( nil );
      RFrame.ShowMainBuf();
    end;

    DTPDTaken.DateTime := Now();
    DTPTTaken.DateTime := 0;

  end;

  Flags := SSAThumbsDGrid.DGItemsFlags[AInd];
  SSADrawSlideObj.CMDSCSelTextBGColor := -1;
  if SSAColors[AInd] <> 0 then
  begin
    Flags := Flags or 2;
    SSADrawSlideObj.CMDSCSelTextBGColor := Integer(N_CM_MainForm.CMMStudyColorsList.Objects[SSAColors[AInd]]);
  end;

  with N_CM_GlobObj do
  begin
    LinesCount := 2;
    CMStringsToDraw[0] := K_CMSlideViewCaption( SSASlides[AInd] );
    CMStringsToDraw[1] := SSANames[AInd];

    SSADrawSlideObj.DrawOneThumb7( SSASlides[AInd],
                                   CMStringsToDraw, LinesCount,
                                   SSAThumbsDGrid, ARect,
                                   Flags );
//    SSADrawSlideObj.DrawOneThumb1( SSASlides[AInd],
//                                   CMStringsToDraw, SSAThumbsDGrid, ARect,
//                                   Flags );
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
procedure TK_FormCMChangeStudiesAttrs.SSAGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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
      AOutSize.X := Min( 2 * AInpSize.Y,
                         Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y ) );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TK_FormCMChangeSlidesAttrsN2.SSAGetThumbSize

//************************ TK_FormCMChangeSlidesAttrsN2.SSAInitialiseControls ***
// Show Available and Processed
//
procedure TK_FormCMChangeStudiesAttrs.SSAInitialiseControls();
var
  CInd : Integer;
//  ObjID : string;
  CurName: string;
  CurColor : Integer;
  CurNoteText : string;
//  LockedCount : Integer;
//  SSource : string;

begin
  with SSAThumbsDGrid, DGMarkedList do
  begin
//    LockedCount   := 0;
    CurName := '';
    CurColor  := 0;
    CurNoteText  := Chr($0D) + Chr($0D) + Chr($0D);
    CInd := -1;
    if DGMarkedList.Count > 0 then
    begin
      CInd := Integer(DGMarkedList[0]);
      // Current Slide Name
      CurName := SSANames[CInd];
      CurColor := SSAColors[CInd];
      CurNoteText := SSANotes[CInd];
    end;

    // Study Picture
    with CMStudyFrame do
    begin
      if CInd <> -1 then
      begin
        EdSlide := SSASlides[CInd];
        RFrame.RVCTFrInit3( EdSlide.GetMapRoot() );
        RFrame.aFitInWindowExecute( nil );
      end
      else
      begin
        EdSlide    := nil;
        RFrame.RFrInitByComp( nil );
        RFrame.ShowMainBuf();
      end;
    end; // with RFrame do

    if CInd <> -1 then
      DTPDTaken.DateTime := SSASlides[CInd].P().CMSDTCreated
    else
      DTPDTaken.DateTime := 0;


    DTPTTaken.DateTime := DTPDTaken.DateTime;

    SSAPrevInd := CInd;

  // Set Controls
    // Study Names
    EdStudyName.Text := CurName;
    EdStudyName.Enabled := TRUE;
    // Study Colors
    CmBStudyColor.ItemIndex := CurColor;
    CmBStudyColor.Enabled := TRUE;
    // Study Notes
    MemoDiagnoses.Lines.Text := CurNoteText;
    MemoDiagnoses.Enabled := TRUE;

  end;

end; // end of TK_FormCMChangeSlidesAttrsN2.SSAInitialiseControls

//************************************** TK_FormCMChangeSlidesAttrsN2.FormKeyDown ***
//  Form Key Down Handler
//
procedure TK_FormCMChangeStudiesAttrs.FormKeyDown( Sender: TObject;
                                       var Key: Word; Shift: TShiftState );
begin
  if not( [ssAlt] = Shift ) then Exit;
  if (Key = $44) and MemoDiagnoses.Enabled then begin // Alt + D
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
procedure TK_FormCMChangeStudiesAttrs.SSAChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
begin
  SSAInitialiseControls();
end; // end of TK_FormCMSetSlidesAttrs.SSAChangeThumbState

//***********************************  TK_FormCMSetSlidesAttrs.SSASaveValues  ******
// Save State to Slides
//
procedure TK_FormCMChangeStudiesAttrs.SSASaveValues;
var
  i  : Integer;
  ChangeAttrsFlag : Boolean;
  UDSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
begin

  for i := 0 to High(SSASlides) do
  begin
    UDSlide := SSASlides[i];
    PCMSlide := UDSlide.P();

    with UDSlide, PCMSlide^  do
    begin

    // Names
      ChangeAttrsFlag := CMSSourceDescr <> SSANames[i];
      CMSSourceDescr := SSANames[i];

    // Colors
      ChangeAttrsFlag := ChangeAttrsFlag or (CMSMediaType <> SSAColors[i]);
      CMSMediaType := SSAColors[i];

    // Notes
      ChangeAttrsFlag := ChangeAttrsFlag or (CMSDiagn <> SSANotes[i]);
      CMSDiagn := SSANotes[i];

      if not ChangeAttrsFlag then Continue;
      // Set Modified Attributes

      CMSDTPropMod := K_CMEDAccess.EDAGetSyncTimestamp();
      CMSProvIDModified := K_CMEDAccess.CurProvID; // Provider ID Modified
      CMSLocIDModified  := K_CMEDAccess.CurLocID; // Location ID Modified
      CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;
      CMSRFlags := CMSRFlags + [cmsfAttribsChanged,cmsfCurImgChanged];
      Inc(SSAProcessedCount);
    end;
  end;

end; // procedure TK_FormCMChangeSlidesAttrsN2.SSASaveValues


//*****************************  TK_FormCMSetSlidesAttrs.CmBStudyColorChange ***
// CmBStudyColor Change Handler
//
procedure TK_FormCMChangeStudiesAttrs.CmBStudyColorChange(Sender: TObject);
begin
  if SSAPrevInd = -1 then Exit;
  SSAColors[SSAPrevInd] := CmBStudyColor.ItemIndex;
  ThumbsRFrame.RedrawAllAndShow();
//  SSAThumbsDGrid.DGDrawItem( SSAPrevInd );
//  ThumbsRFrame.ShowMainBuf();
end; // procedure TK_FormCMChangeStudiesAttrs.CmBStudyColorChange

//******************************  TK_FormCMSetSlidesAttrs.EdStudyNameKeyDown ***
// EdStudyName KeyDown Handler
//
procedure TK_FormCMChangeStudiesAttrs.EdStudyNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if SSAPrevInd = -1 then Exit;
  SSANames[SSAPrevInd] := EdStudyName.Text;
  SSAThumbsDGrid.DGDrawItem( SSAPrevInd );
  ThumbsRFrame.ShowMainBuf();
end; // procedure TK_FormCMChangeStudiesAttrs.EdStudyNameKeyDown

end.
