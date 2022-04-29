unit K_FCMSTextAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF, N_Comp2, N_Lib2, N_Lib0, N_CompCL, N_Rast1Fr,
  K_CM0, K_UDT1;

type
  TK_FormCMSTextAttrs = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;

    LbText: TLabel;
    MemoText: TMemo;
    BtFont: TButton;
    BtTextShow: TButton;

    procedure LbEColorKeyDown( Sender: TObject; var Key: Word;
                               Shift: TShiftState );
    procedure BtFontClick(Sender: TObject);
    procedure BtFontClick1(Sender: TObject);
    procedure BtTextShowClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RFrame : TN_Rast1Frame;
    CUDAnnotRoot, CUDAnnot : TN_UDBase;
    PUPColor: TN_POneUserParam;
    CurColor : TColor;
    FontAttrs : TN_NFont;       // Font Attributes
    PrevFontAttrs : TN_NFont;   // Font Attributes
    PFont : TN_PNFont;
    POneTextBlock : TN_POneTextBlock;
    FontRSize : Double;
    PrevFontRSize : Double;
    DotPos, DotPosDelta : TFPoint;
    PrevBPos : TFPoint;
    SlidePixHeight : Integer;

    procedure CalcFontRsize();
    procedure ShowText();
    procedure SetDotTextPos();
  end;

var
  K_FormCMSTextAttrs: TK_FormCMSTextAttrs;

function K_CMSlideTextAttrsDlg( ARFrame : TN_Rast1Frame; out AEmptyTextFlag : Boolean;
                                ASkipAnnotShow : Boolean;
                                AUDAnnot : TN_UDBase; AUDAnnotRoot : TN_UDBAse = nil ) : Boolean;

implementation

uses
  K_SCript1, K_FFontAttrs,
  N_Gra2, N_CompBase, N_Lib1, N_Comp1, N_CMMain5F, K_CML1F, N_CMREd3Fr;

{$R *.dfm}

function K_CMSlideTextAttrsDlg( ARFrame : TN_Rast1Frame; out AEmptyTextFlag : Boolean;
                                ASkipAnnotShow : Boolean;
                                AUDAnnot : TN_UDBase; AUDAnnotRoot : TN_UDBAse = nil ) : Boolean;
var
  UDCommonAttrs : TN_UDCompBase;
  UDTextComp : TN_UDCompBase;
  FreeForm : Boolean;
  i : Integer;
  PUPFontRSize: TN_POneUserParam;
  PrevText : string;
  PrevColor : TColor;

  procedure SetFontAttrs( );
  begin
    if UDTextComp = nil then Exit;
    with K_FormCMSTextAttrs do
    begin
    // Save New Font Attributes to Pattern Text Component
      POneTextBlock := TN_UDParaBox(UDTextComp).PSP.CParaBox.CPBTextBlocks.P();
      with POneTextBlock^ do
        PFont := K_GetPVRArray( OTBNFont ).P();
      if PFont <> nil then
      begin
        PFont^ := FontAttrs;

         // Save Font RSize
        if (PUPFontRSize <> nil) and (FontRSize <> 0) then
        begin
          PUPFontRSize := K_CMGetVObjPAttr(UDTextComp, 'FontRSize');
          if PUPFontRSize <> nil then
          with PUPFontRSize.UPValue do
            PDouble(P)^ := FontRSize;
        end; //  if (PUPFontRSize <> nil) and (FontRSize <> 0) then
      end; // if PFont <> nil then
    end;
  end;

begin
  AEmptyTextFlag := FALSE;
  K_FormCMSTextAttrs := TK_FormCMSTextAttrs.Create(Application);
  with K_FormCMSTextAttrs do
  begin
    RFrame := ARFrame;
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    CUDAnnot := AUDAnnot;
    CUDAnnotRoot := AUDAnnotRoot;
    if CUDAnnotRoot = nil then
      CUDAnnotRoot := CUDAnnot;
// Code from FormShow
    MemoText.Enabled := (CUDAnnotRoot = CUDAnnot) or ((CUDAnnotRoot.ObjName[1] = 'D') and (CUDAnnotRoot.ObjName[3] = 't'));
    BtTextShow.Enabled := MemoText.Enabled;
    BtTextShow.Visible := not ASkipAnnotShow;
    if ASkipAnnotShow then
      BtFont.OnClick := BtFontClick1;

//    PUPColor := N_GetUserParPtr( TN_UDCompBase(CUDAnnotRoot).R, 'MainColor' );
    PrevColor := 0;
    PUPColor := K_CMGetVObjPAttr( CUDAnnotRoot, 'MainColor' );
    if PUPColor <> nil then
    begin
      CurColor := PColor(PUPColor.UPValue.P)^;
      PrevColor := CurColor;
    end;

    SlidePixHeight := 0;
    if (RFrame <> nil) and (RFrame.Parent is TN_CMREdit3Frame) then
      SlidePixHeight := TN_CMREdit3Frame(RFrame.Parent).EdSlide.P.CMSDB.PixHeight;
    FontRSize := 0;
    PUPFontRSize := nil;
    POneTextBlock := TN_UDParaBox(CUDAnnot).PSP.CParaBox.CPBTextBlocks.P();
    with POneTextBlock^ do
    begin
      MemoText.Lines.Text := OTBMText;
      PrevText := OTBMText;
      PFont := K_GetPVRArray(OTBNFont).P();
      if PFont <> nil then
      begin
        FontAttrs := PFont^;
        PrevFontAttrs := FontAttrs;
        PUPFontRSize := K_CMGetVObjPAttr(CUDAnnot, 'FontRSize');
        if PUPFontRSize <> nil then
          with PUPFontRSize.UPValue do
            FontRSize := PDouble(P)^
        else
        if SlidePixHeight > 0 then // Init Font RSize
          FontRSize := FontAttrs.NFLLWHeight / SlidePixHeight;
      end;
    end;
    PrevFontRSize := FontRSize;
    if CUDAnnotRoot.ObjName[1] = 'D' then
    begin
      PrevBPos := TN_UDParaBox(CUDAnnot).PSP.CCoords.BPCoords;
      DotPos := PFPoint(TN_UDPolyline(CUDAnnotRoot.DirChild(1)).PSP.CPolyline.CPCoords.P(0))^;
      DotPosDelta.X := DotPos.X - PrevBPos.X;
      DotPosDelta.Y := DotPos.Y - PrevBPos.Y;
    end;

    FreeForm := FALSE;
    if not BtTextShow.Enabled then
    begin
      BtFontClick(nil);
// end of Code from FormShow
      Result := TRUE;
      FreeForm := TRUE;
    end
    else
    begin
      Result := ShowModal() = mrOK;
      N_CM_MainForm.CMMCurFMainForm.Refresh();
//      N_CM_MainForm.ThumbsRFrame.Refresh();
//      N_CM_MainForm.EdFramesPanel.Refresh();
    end;

    if Result then
    begin
      // Save Color to Editing Annotation
      if PUPColor <> nil then
        PColor(PUPColor.UPValue.P)^ := CurColor;

      // Save Text to Editing Annotation
      POneTextBlock.OTBMText := MemoText.Lines.Text;

      // Check if Text is empty
      AEmptyTextFlag := TRUE;
      for i := 1 to Length(POneTextBlock.OTBMText) do
        case POneTextBlock.OTBMText[i] of
          #10, #13, ' ': Continue;
        else
          AEmptyTextFlag := FALSE;
          Break;
        end;

      // Save Font Attrs to Editing Annotation
      if PFont <> nil then
        PFont^ := FontAttrs;

      // Define Font RSize
      CalcFontRsize();

      // Save Font RSize to Editing Text Annotation
      if (PUPFontRSize <> nil) and (FontRSize <> 0) then
        with PUPFontRSize.UPValue do
          PDouble(P)^ := FontRSize;

      if CUDAnnotRoot <> CUDAnnot then
      begin // Measure Annotation
       // Save New Color to Common Attrs for Measure Annotation
        UDCommonAttrs := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'CommonAttrs' ) );
        PUPColor := N_GetUserParPtr( UDCommonAttrs.R, 'MainColor' );
        if PUPColor <> nil then
          PColor(PUPColor.UPValue.P)^ := CurColor;
        N_StringToMemIni( 'VObjAttrs', 'LineColor', N_ColorToHTMLHex(CurColor) );
{
        if CUDAnnotRoot.ObjName[1] = 'D' then
        begin // Dot annotation
          SetDotTextPos();
        end; // if CUDAnnotRoot.ObjName[1] = 'D' then
}
      end;   // Measure Annotation

     // Save New Attributes to Text Pattern Component
      UDTextComp := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'Text' ) );
      if UDTextComp <> nil then
      begin
      // Save New Color to Pattern Text Component
        PUPColor := K_CMGetVObjPAttr( UDTextComp, 'MainColor' );
        if PUPColor <> nil then
          PColor(PUPColor.UPValue.P)^ := CurColor;
      end; // if UDTextComp <> nil then
      SetFontAttrs( );

      // Save New Font Attributes to other Pattern Text Components
      UDTextComp := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'MLine' ).DirChildByObjName( 'Text' ) );
      SetFontAttrs( );

      UDTextComp := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'NAngle' ).DirChildByObjName( 'Text' ) );
      SetFontAttrs( );

      UDTextComp := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'FAngle' ).DirChildByObjName( 'Text' ) );
      SetFontAttrs( );

      UDTextComp := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'Dot' ).DirChildByObjName( 'Text' ) );
      SetFontAttrs( );

      // Save Current Color and Font Atributes to Text annotation attrs in MemIni
      N_StringToMemIni( 'VObjAttrs', 'TextColor', N_ColorToHTMLHex(CurColor) );

      N_SPLValToMemIni( 'VObjAttrs', 'Font', FontAttrs, N_SPLTC_NFont );
      if FontRSize <> 0 then
        N_DblToMemIni( 'VObjAttrs', 'FontRSize', '%g', FontRSize );

    end // Set new Values
    else
    begin // Restore previous Values
      if PUPColor <> nil then
      begin
        PColor(PUPColor.UPValue.P)^ := PrevColor;
        K_CMChangeVObjSelectedColor( CUDAnnotRoot, PrevColor );
      end;
      if PFont <> nil then
        PFont^ := PrevFontAttrs;

      POneTextBlock.OTBMText := PrevText;

      if CUDAnnotRoot.ObjName[1] = 'D' then
      begin
        TN_UDParaBox(CUDAnnot).PSP.CCoords.BPCoords := PrevBPos;
        K_CMVobjSetDotSizeByFontHeight( CUDAnnotRoot, PrevFontAttrs.NFLLWHeight );
      end;
      RFrame.RedrawAllAndShow();
    end; // Restore previous Values
    if FreeForm then
      Free;
  end; // with TK_FormCMSTextAttrs ... do
  K_FormCMSTextAttrs := nil;
end;

procedure TK_FormCMSTextAttrs.LbEColorKeyDown(Sender: TObject; var Key: Word;
                           Shift: TShiftState);
begin
  if Key = VK_Return then ModalResult := mrOK;
end;


procedure TK_FormCMSTextAttrs.BtFontClick(Sender: TObject);
var
  WPColor : PColor;
begin
  WPColor := nil;
  if BtTextShow.Enabled or ((CUDAnnotRoot.ObjName[1] = 'D') and
                            (CUDAnnotRoot.ObjName[3] = 'F')) then
    WPColor := @CurColor;

  K_FontAttrsDlg( [K_fadHideSample], @FontAttrs, WPColor,
                            nil, ShowText,
                            K_CML1Form.LLLObjEdit3.Caption );  // 'Text attributes' )
  ShowText();

//                            @WText[1], ShowText, 'Text attributes' );
//  if not N_EditNFont( @FontAttrs, Self, @CurColor ) then Exit;
//  ShowText();
end;

procedure TK_FormCMSTextAttrs.BtFontClick1(Sender: TObject);
var
  WText : string;
begin
  WText := MemoText.Lines.Text;
  K_FontAttrsDlg( [], @FontAttrs, @CurColor,
                            @WText[1], nil,
                            K_CML1Form.LLLObjEdit3.Caption );// 'Text attributes' );

end;

procedure TK_FormCMSTextAttrs.BtTextShowClick(Sender: TObject);
begin
  POneTextBlock.OTBMText := MemoText.Lines.Text;
  RFrame.RedrawAllAndShow();
end;

procedure TK_FormCMSTextAttrs.CalcFontRsize();
begin
  if PrevFontRSize <> 0 then // Recalc Font RSize
    FontRSize := PrevFontRSize * FontAttrs.NFLLWHeight / PrevFontAttrs.NFLLWHeight
  else
  if SlidePixHeight > 0 then // Init Font RSize
    FontRSize := FontAttrs.NFLLWHeight / SlidePixHeight;
end; // procedure TK_FormCMSTextAttrs.CalcFontRsize

procedure TK_FormCMSTextAttrs.ShowText;
begin
  if PUPColor <> nil then
    PColor(PUPColor.UPValue.P)^ := CurColor;
  if PFont <> nil then
    PFont^ := FontAttrs;
  K_CMChangeVObjSelectedColor( CUDAnnotRoot, CurColor );
  if CUDAnnotRoot.ObjName[1] = 'D' then
  begin
    CalcFontRsize();
    SetDotTextPos();
  end;
  RFrame.RedrawAllAndShow();
end; // procedure TK_FormCMSTextAttrs.ShowText

procedure TK_FormCMSTextAttrs.SetDotTextPos();
begin
  // Change Dot sixe by new Font Height
  K_CMVobjSetDotSizeByFontHeight( CUDAnnotRoot, FontAttrs.NFLLWHeight );

  // Shift Text Vertical Position by new Font Height
  if SlidePixHeight > 0 then // Change Dot Text Pos
  begin
    with TN_UDParaBox(CUDAnnot).PSP.CCoords.BPCoords do
    begin
      Y := DotPos.Y - DotPosDelta.Y * FontAttrs.NFLLWHeight / PrevFontAttrs.NFLLWHeight;
      X := DotPos.X - DotPosDelta.X * FontAttrs.NFLLWHeight / PrevFontAttrs.NFLLWHeight;
    end; // with TN_UDParaBox(CUDAnnot).PSP.CCoords.BPCoords do
  end; // if SlidePixHeight > 0 then
end; // procedure TK_FormCMSTextAttrs.SetDotTextPos

end.
