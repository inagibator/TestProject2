unit K_FCMSDrawAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Rast1Fr,
  K_CM0, K_UDT1;

type
  TK_FormCMSDrawAttrs = class(TN_BaseForm)
    CmBLineWidth: TComboBox;
    BtCancel: TButton;
    BtOK    : TButton;
    LbUnit  : TLabel;
    LbColor : TLabel;
    ColorBox: TColorBox;
    BtFont: TButton;
    PnColor: TPanel;
    ChBMLineDisplay: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure LbEColorKeyDown( Sender: TObject; var Key: Word;
                               Shift: TShiftState );
    procedure CmBLineWidthDrawItem( Control: TWinControl; Index: Integer;
                                    Rect: TRect; State: TOwnerDrawState );
    procedure CmBLineWidthChange(Sender: TObject);
    procedure BtFontClick(Sender: TObject);
    procedure PnColorClick(Sender: TObject);
    procedure ChBMLineDisplayClick(Sender: TObject);
  private
    { Private declarations }
//    procedure SetArrowAttrs( AUDArrow : TN_UDBase; AInd : Integer = -1 );
  public
    { Public declarations }
    RFrame : TN_Rast1Frame;
    CUDMeasure : TN_UDBase;
    PUPColor: TN_POneUserParam;
    PUPLineWidth: TN_POneUserParam;
    PrevColor : TColor;
    PrevLineWidthIndex : Integer;
    MLineDisplayMode : Integer;
//    FontAttrs : TN_NFont;       // Font Attributes
//    PFont : TN_PNFont;
  end;

var
  K_FormCMSDrawAttrs: TK_FormCMSDrawAttrs;

function K_CMSlideDrawAttrsDlg( AUDMeasure : TN_UDBase; ARFrame : TN_Rast1Frame ) : Boolean;

implementation

uses Math,
  N_Types, N_Gra2, N_CompBase, N_Lib0, N_Lib1,
  K_CLib0;

{$R *.dfm}

function K_CMSlideDrawAttrsDlg( AUDMeasure : TN_UDBase; ARFrame : TN_Rast1Frame ) : Boolean;
var
  UDCommonAttrs : TN_UDCompBase;
  CWidth : FLoat;
begin
  with TK_FormCMSDrawAttrs.Create(Application) do
  begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CUDMeasure := AUDMeasure;
    RFrame := ARFrame;
    PnColor.ParentBackground := FALSE; // is need for controls wich Color property will be changed by program
    Result := ShowModal() = mrOK;
    if Result then
    begin

      if PUPColor <> nil then
        PColor(PUPColor.UPValue.P)^ := PnColor.Color;
//        with ColorBox do
//          PColor(PUPColor.UPValue.P)^ := Selected;

      with CmBLineWidth, Items do
      begin
        CWidth := Float( Objects[ItemIndex] );
        if PUPLineWidth <> nil then
          PFloat(PUPLineWidth.UPValue.P)^ := CWidth;
        if CUDMeasure.ObjName[1] = 'A' then
        begin
//          SetArrowAttrs( CUDMeasure );
//          SetArrowAttrs( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'Arrow' ) );
        end;
      end;

      UDCommonAttrs := TN_UDCompBase( K_CMEDAccess.ArchMLibRoot.DirChildByObjName( 'CommonAttrs' ) );
      // Save New LineWidth to Common Attrs
      PUPLineWidth := N_GetUserParPtr( UDCommonAttrs.R, 'LineWidth' );
      if PUPLineWidth <> nil then
        PFloat(PUPLineWidth.UPValue.P)^ := CWidth;
      N_DblToMemIni( 'VObjAttrs', 'LineWidth', '%g', CWidth );

      // Save New Color to Common Attrs
      PUPColor := N_GetUserParPtr( UDCommonAttrs.R, 'MainColor' );
      PColor(PUPColor.UPValue.P)^ := PnColor.Color;
      N_StringToMemIni( 'VObjAttrs', 'LineColor', N_ColorToHTMLHex( ColorToRGB(PnColor.Color) ) );
{
      with ColorBox do begin
        if PUPColor <> nil then
          PColor(PUPColor.UPValue.P)^ := Selected;

        N_StringToMemIni( 'VObjAttrs', 'LineColor', N_ColorToHTMLHex(Selected) );
//        N_IntToMemIni( 'VObjAttrs', 'LineColor', Selected );
      end;
}
{ 20.01.2010 Skip Saving Vector Objects Attributes
(because it is time consuming and implicit to user)
      with K_CMEDAccess do
        if StateSaveMode = K_cmetImmediately then
//          EDASaveContextsData( [K_cmssSkipSlides] );// Save Contexts
            EDASaveContextsData( // Save Contexts - only provider to make saving faster
                       [K_cmssSkipSlides, K_cmssSkipAppBinInfo,
                        K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
                        K_cmssSkipLocationInfo, K_cmssSkipExtIniInfo] );
{}
    end
    else
    begin
    // Cancel Changes
      if MLineDisplayMode >= 0 then
        K_CMSetMLineInterimTextsDisplayMode( CUDMeasure, MLineDisplayMode <> 0 );

      if PUPColor <> nil then
      begin
        PColor(PUPColor.UPValue.P)^ := PrevColor;
        K_CMChangeVObjSelectedColor( CUDMeasure, PrevColor );
      end;

      with CmBLineWidth, Items do
        CWidth := Float( Objects[PrevLineWidthIndex] );

      if PUPLineWidth <> nil then
        PFloat(PUPLineWidth.UPValue.P)^ := CWidth;

//      if CUDMeasure.ObjName[1] = 'A' then
//        SetArrowAttrs( CUDMeasure, PrevLineWidthIndex );

      RFrame.RedrawAllAndShow();
    end;
  end;
end;

procedure TK_FormCMSDrawAttrs.FormShow(Sender: TObject);
var
  LWidth, CWidth : FLoat;
  i : Integer;
  WStr : string;
begin
  inherited;
  MLineDisplayMode := K_CMGetMLineInterimTextsDisplayMode( CUDMeasure );
  ChBMLineDisplay.Visible := MLineDisplayMode >= -1;
  ChBMLineDisplay.Enabled := MLineDisplayMode >= 0;
  ChBMLineDisplay.Checked := MLineDisplayMode <> 0;


//  PUPColor := N_GetUserParPtr( TN_UDCompBase(CUDMeasure).R, 'MainColor' );
  PUPColor := K_CMGetVObjPAttr( CUDMeasure, 'MainColor' );

  if PUPColor <> nil then
  begin
//    ColorBox.Selected := PColor(PUPColor.UPValue.P)^;
//    PrevColor := ColorBox.Selected;
    PnColor.Color := PColor(PUPColor.UPValue.P)^;
    PrevColor := PnColor.Color;
  end;

// Build Widths ComboBox
  with CmBLineWidth, Items do
  begin
    CommaText :=  N_MemIniToString( 'CMS_Main', 'VObjLineWidth', '0.1,0.3,0.8,1.5,3.0,4.5,6.0' );
    for i := 0 to Count - 1 do
    begin
      WStr := Trim( Strings[i] );
      Strings[i] := WStr + ' pt';
      LWidth := StrToFloatDef( WStr, 1 + i * 1.5 );
      Objects[i] := TObject(LWidth);
    end;
    ItemIndex := 0;

//    PUPLineWidth := N_GetUserParPtr( TN_UDCompBase(CUDMeasure).R, 'LineWidth' );
    PUPLineWidth := K_CMGetVObjPAttr( CUDMeasure, 'LineWidth' );
    if PUPLineWidth <> nil then begin
      CWidth := PFloat(PUPLineWidth.UPValue.P)^;
      ItemIndex := IndexOfObject( TObject(CWidth) );
      if ItemIndex = -1 then ItemIndex := 0;
      PrevLineWidthIndex := ItemIndex;
    end;
{
    POneTextBlock := TN_UDParaBox(CUDAnnot).PSP.CParaBox.CPBTextBlocks.P();
    with POneTextBlock^ do begin
      MemoText.Lines.Text := OTBMText;
      PrevText := OTBMText;
      PFont := K_GetPVRArray( OTBNFont ).P();
      if PFont <> nil then begin
        FontAttrs := PFont^;
        PrevFontAttrs := FontAttrs;
      end;
    end;
}
  end;

end;

procedure TK_FormCMSDrawAttrs.LbEColorKeyDown(Sender: TObject; var Key: Word;
                           Shift: TShiftState);
begin
  if Key = VK_Return then ModalResult := mrOK;
end;

procedure TK_FormCMSDrawAttrs.CmBLineWidthDrawItem( Control: TWinControl;
                      Index: Integer; Rect: TRect; State: TOwnerDrawState );
var
  LRect: TRect;
  Str : string;
  TextSize : TSize;
  CY, LW : Float;
begin
  with CmBLineWidth, Items do begin
    LRect := Rect;
    CY := (LRect.Top + LRect.Bottom) / 2;
    Str := Items[Index];
    TextSize := Canvas.TextExtent(Str);

    LRect.Left := LRect.Left + 5;
    LRect.Right := LRect.Left + 55;
    LW := Min( Float(Objects[Index]), 0.7 * (LRect.Bottom - LRect.Top) );

    LRect.Top    := Floor(CY - LW / 2);
    LRect.Bottom :=  Ceil(CY + LW / 2);

    N_HDCRectDraw( Canvas.Handle, Rect, $FFFFFF );
    Canvas.TextRect( Rect, LRect.Right + 5, Round(CY - TextSize.cy / 2), Str );
    N_HDCRectDraw( Canvas.Handle, LRect, 0 );
  end;
end;

procedure TK_FormCMSDrawAttrs.CmBLineWidthChange(Sender: TObject);
var
  CWidth : FLoat;
begin

  if PUPColor <> nil then
    PColor(PUPColor.UPValue.P)^ := PnColor.Color;
//    with ColorBox do
//      PColor(PUPColor.UPValue.P)^ := Selected;
  with CmBLineWidth, Items do
    CWidth := Float( Objects[ItemIndex] );
  if PUPLineWidth <> nil then
    PFloat(PUPLineWidth.UPValue.P)^ := CWidth;

//  if CUDMeasure.ObjName[1] = 'A' then
//    SetArrowAttrs( CUDMeasure );

  RFrame.RedrawAllAndShow();

end;
{
procedure TK_FormCMSDrawAttrs.SetArrowAttrs( AUDArrow: TN_UDBase; AInd : Integer = -1 );
var
  K : Double;
  MinBorderWidth   : Double;
  MinLineWidth     : Double;
  MinArrowWidth    : Double;
  MinLinesNearPos  : Double;
  MinLinesOuterPos : Double;
  MaxBorderWidth   : Double;
  MaxLineWidth     : Double;
  MaxArrowWidth    : Double;
  MaxLinesNearPos  : Double;
  MaxLinesOuterPos : Double;

begin

with CmBLineWidth, Items do begin
  // Set Arrow Attributes
  if AInd = -1 then AInd := ItemIndex;
  K :=  AInd / (Count - 1);
  MinBorderWidth   := N_MemIniToDbl( 'CMSArrowAttrs', 'MinBorderWidth',   0.1 );
  MinLineWidth     := N_MemIniToDbl( 'CMSArrowAttrs', 'MinLineWidth',     3 );
  MinArrowWidth    := N_MemIniToDbl( 'CMSArrowAttrs', 'MinArrowWidth',    6 );
  MinLinesNearPos  := N_MemIniToDbl( 'CMSArrowAttrs', 'MinLinesNearPos',  6 );
  MinLinesOuterPos := N_MemIniToDbl( 'CMSArrowAttrs', 'MinLinesOuterPos', 6 );
  MaxBorderWidth   := N_MemIniToDbl( 'CMSArrowAttrs', 'MaxBorderWidth',   0.8 );
  MaxLineWidth     := N_MemIniToDbl( 'CMSArrowAttrs', 'MaxLineWidth',     8 );
  MaxArrowWidth    := N_MemIniToDbl( 'CMSArrowAttrs', 'MaxArrowWidth',    24 );
  MaxLinesNearPos  := N_MemIniToDbl( 'CMSArrowAttrs', 'MaxLinesNearPos',  24 );
  MaxLinesOuterPos := N_MemIniToDbl( 'CMSArrowAttrs', 'MaxLinesOuterPos', 24 );

  MinBorderWidth := MinBorderWidth + (MaxBorderWidth - MinBorderWidth) * K;
  MinLineWidth := MinLineWidth + (MaxLineWidth - MinLineWidth) * K;
  MinArrowWidth := MinArrowWidth + (MaxArrowWidth - MinArrowWidth) * K;
  MinLinesNearPos := MinLinesNearPos + (MaxLinesNearPos - MinLinesNearPos) * K;
  MinLinesOuterPos := MinLinesOuterPos + (MaxLinesOuterPos - MinLinesOuterPos) * K;
  with TN_UDSArrow(AUDArrow.DirChild(1)).PSP.CSArrow do begin
    SAWidths.X := MinLineWidth;
    SAWidths.Y := MinArrowWidth;
    SALengths.X := MinLinesNearPos;
    SALengths.Y := MinLinesOuterPos;
    TN_PContAttr(SAAttribs.P).CAPenWidth := MinBorderWidth;
  end;
end;
end;
}
procedure TK_FormCMSDrawAttrs.BtFontClick(Sender: TObject);
begin
{
  if not N_EditNFont( @FontAttrs, Self, @CurColor ) then Exit;
  if PFont <> nil then
    PFont^ := FontAttrs;
  RFrame.RedrawAllAndShow();
}
end;

procedure TK_FormCMSDrawAttrs.PnColorClick(Sender: TObject);
var
  AColor : TColor;
begin
  AColor := PnColor.Color;
  if not K_SelectColorDlg( AColor ) then Exit;
  PnColor.Color := AColor;
  if PUPColor = nil then Exit;
  PColor(PUPColor.UPValue.P)^ := PnColor.Color;
  K_CMChangeVObjSelectedColor( CUDMeasure, AColor );

  RFrame.RedrawAllAndShow();
end;

procedure TK_FormCMSDrawAttrs.ChBMLineDisplayClick(Sender: TObject);
begin
  K_CMSetMLineInterimTextsDisplayMode( CUDMeasure, ChBMLineDisplay.Checked );
  RFrame.RedrawAllAndShow();
end;

end.
