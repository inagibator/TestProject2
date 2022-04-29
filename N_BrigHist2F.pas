unit N_BrigHist2F;
// Brightness Histogramm Form Variant #2

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, ImgList, ActnList, ExtCtrls, StdCtrls,
  K_UDT1, K_Script1,
  N_Types, N_BaseF, N_Gra0, N_Gra1, N_Gra2, N_Rast1Fr,
  N_CM1, N_Lib2, N_BrigHistFr;

type TN_BrigHist2Form = class( TN_BaseForm )
    rgYAxis: TRadioGroup;
    edYValue: TLabeledEdit;
    edBriValue: TLabeledEdit;
    bnClose: TButton;
    BHFrame: TN_BrigHistFrame;
    gbScale: TGroupBox;
    tbYScale: TTrackBar;
    cbAuto: TCheckBox;

    //************************** TN_BrigHist2Form Handlers ***********

    procedure FormActivate ( Sender: TObject ); override;
    procedure RFrameResize ( Sender: TObject );
    procedure FormClose    ( Sender: TObject; var Action: TCloseAction ); override;

    procedure rgYAxisClick   ( Sender: TObject );
    procedure tbYScaleChange ( Sender: TObject );
    procedure bnCloseClick   ( Sender: TObject );
    procedure cbAutoClick    ( Sender: TObject);
    procedure FormKeyDown    ( Sender: TObject; var Key: Word; Shift: TShiftState );

    procedure bn1Click ( Sender: TObject ); // for debug only
    procedure bn2Click ( Sender: TObject ); // for debug only

  public
    SkipSelfCloseFlag : Boolean; // Skip Form CLose by SelfClose() method
    FirstDraw:          Boolean; // First Draw with new Histogramm
    DebXLATtoDraw:    TN_IArray; // XLAT to Draw, for debug only


    procedure RedrawBrighHist2Form ();

    procedure SetDIBObjAndXlat ( ADIBObj: TN_DIBObj; APXLAT: PInteger );
    procedure SetDIBObj        ( ADIBObj: TN_DIBObj );
    procedure SetXLATtoConv    ( APXLATtoConv: PInteger );
    procedure SetXLATtoDraw    ( APXLATtoDraw: PInteger );
    procedure SetBriRange      ( AMinBri, AMaxBri: integer );
    procedure SetCurBrightness ( ABrightness: integer );
    function  GetMaxVisBrightness (): integer;

    procedure SetSkipSelfClose ( AValue : Boolean );
    procedure SelfClose        ();
end; // type TN_BrigHist2Form = class( TN_BaseForm )
type TN_PBrigHist2Form = ^TN_BrigHist2Form;

var
  N_BrigHist2Form: TN_BrigHist2Form;


//****************** Global procedures **********************

procedure N_CreateBrigHist2Form( APBHist2Form: TN_PBrigHist2Form;
                                 AFormCaption: String; AOwner: TN_BaseForm );


implementation
uses math,
  N_Lib0;
{$R *.dfm}


    //************************** TN_BrigHist2Form Handlers ***********

procedure TN_BrigHist2Form.FormActivate( Sender: TObject );
// just call RFrame.OnActivateFrame to set N_ActiveRFrame variable
// (OnActivate Form event handler)
begin
  inherited;
  BHFrame.RFrame.OnActivateFrame();
end; // procedure TN_BrigHist2Form.FormActivate

procedure TN_BrigHist2Form.RFrameResize( Sender: TObject );
// TN_BrigHist2Form.RFrame instance Resize
begin
  BHFrame.RFrameResize( Sender );
end; // procedure TN_BrigHist2Form.RFrameResize

procedure TN_BrigHist2Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  BHFrame.LabelsNFont.Free;
  BHFrame.RFrame.RFFreeObjects();
  N_BrigHist2Form := nil;
  Inherited;
end; // procedure TN_BrigHist2Form.FormClose

procedure TN_BrigHist2Form.rgYAxisClick( Sender: TObject );
begin
  if rgYAxis.ItemIndex = 0 then BHFrame.YAxisUnits := yauAbsNumbers
                           else BHFrame.YAxisUnits := yauPercents;
  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.rgYAxisClick

procedure TN_BrigHist2Form.tbYScaleChange( Sender: TObject );
begin
  if FirstDraw then Exit; // First Draw with new Histogramm, tbYScale.Position was set programmatically

  with BHFrame do
  begin
    if BHFSrcDIB = nil then Exit;
    CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
  end; // with BHFrame do

  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.tbYScaleChange

procedure TN_BrigHist2Form.bnCloseClick( Sender: TObject );
begin
  Close;
end; // procedure TN_BrigHist2Form.bnCloseClick

procedure TN_BrigHist2Form.cbAutoClick( Sender: TObject );
begin
  if cbAuto.Checked then // Auto Scale mode
  begin
    FirstDraw := True;
    tbYScale.Enabled := False;
    BHFrame.CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
    RedrawBrighHist2Form();
//    BHFrame.RedrawRFrame();
  end else // Manual Scale mode
  begin
    FirstDraw := False;
    tbYScale.Enabled := True;
  end;
end; // procedure TN_BrigHist2Form.cbAutoClick

procedure TN_BrigHist2Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Set several values, for debug only
var
  i: integer;
begin
  //!!! Make Test Code Closed for real User
  if not (ssShift in Shift) and not (ssCtrl in Shift) then Exit;

  if Key = Byte('1') then // Set Range
  begin
    SetBriRange( 50, 100 );
  end;

  if Key = Byte('2') then // Set Cur
  begin
    SetCurBrightness( 150 );
  end;

  if Key = Byte('3') then // Set XLATtoDraw
  begin
    SetLength( DebXLATtoDraw, 256 );
    for i := 0 to 255 do
      if i < 100 then DebXLATtoDraw[i] := 0
                 else DebXLATtoDraw[i] := i;

    SetXLATtoDraw( @DebXLATtoDraw[0] );
  end;

  if Key = Byte('4') then // Decrease current Brightnes
  begin
  end;

end; // procedure TN_BrigHist2Form.FormKeyDown

procedure TN_BrigHist2Form.bn1Click( Sender: TObject );
begin
  SetBriRange( 50, 100 );
end; // procedure TN_BrigHist2Form.bn1Click

procedure TN_BrigHist2Form.bn2Click( Sender: TObject );
begin
  SetCurBrightness( 150 );
end; // procedure TN_BrigHist2Form.bn2Click

    //************************** TN_BrigHist2Form Methods ***********

//*********************************** TN_BrigHist2Form.RedrawBrighHist2Form ***
// Draw All (except gradient rect): Histogramm, Brightness Range, current Brightness
//
procedure TN_BrigHist2Form.RedrawBrighHist2Form();
begin
  BHFrame.RedrawRFrame();

  with BHFrame do
  begin
    if (CurBri >= 0) and (BHFSrcDIB <> nil) then // CurBri was given, Draw it
    begin
      edBriValue.Text := Format( ' %d ', [CurBri] );

      if rgYAxis.ItemIndex = 0 then // Absolute number of pixels
        edYValue.Text := Format( '%d', [XLATHist8Values[CurBri8]] )
      else // percents
//        edYValue.Text := Format( '%.2f %%', [100.0*XLATHist8Values[CurBri8]/VisXLATHistValue] ); // 0-100% range
        edYValue.Text := Format( '%.4f %%', [100.0*XLATHist8Values[CurBri8]/MaxXLATHistValue] ); //0-(VisXLATHistValue/MaxXLATHistValue) range

    end else // CurBri not given
    begin
      edYValue.Text   := '';
      edBriValue.Text := '';
    end;

    if FirstDraw then // First Draw with new Histogramm, set tbYScale.Position by VisXLATHistValue
    begin
      tbYScale.Position := Round( 1000.0*Power( 1.0*VisXLATHistValue/MaxXLATHistValue, 0.25 )) - 5;
      FirstDraw := False;
    end; // if FirstDraw then // First Draw with new Histogramm

  end; // with BHFrame do
end; // procedure TN_BrigHist2Form.RedrawBrighHist2Form

//*************************************** TN_BrigHist2Form.SetDIBObjAndXlat ***
// Set DIBObj, XLat and redraw all
//
procedure TN_BrigHist2Form.SetDIBObjAndXlat( ADIBObj: TN_DIBObj; APXLAT: PInteger );
begin
  with BHFrame do
  begin
    BHFrameSetDIBObj( ADIBObj );
    BHFPXLAT8toConv := APXLAT;

    if BHFSrcDIB = nil then Exit;

    CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
  end; // with BHFrame do

  RFrameResize( nil ); // is needed for drawing X axis Labels (they depend upon BHFSrcDIB)
  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.SetDIBObjAndXlat

//********************************************** TN_BrigHist2Form.SetDIBObj ***
// Set DIBObj and redraw all
//
procedure TN_BrigHist2Form.SetDIBObj( ADIBObj: TN_DIBObj );
begin
  with BHFrame do
  begin
    BHFrameSetDIBObj( ADIBObj );

    if BHFSrcDIB = nil then Exit;

    CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
  end; // with BHFrame do

  RFrameResize( nil ); // is needed for drawing X axis Labels (they depend upon BHFSrcDIB)
  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.SetDIBObj

//****************************************** TN_BrigHist2Form.SetXLATtoConv ***
// Set XLAT table to convert caculated Historgramm and redraw all
//
procedure TN_BrigHist2Form.SetXLATtoConv( APXLATtoConv: PInteger );
begin
  with BHFrame do
  begin
    BHFPXLAT8toConv := APXLATtoConv;

    CurBri    := -1;
    CurMinBri := -1;
    CurMaxBri := -1;
    FirstDraw := True;

    if BHFSrcDIB = nil then Exit;

  //  if N_KeyIsDown( VK_SHIFT ) then
  //    N_i := 1;

    PrepXLATHist8Values();
    CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
  end; // with BHFrame do

  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.SetXLATtoConv

//****************************************** TN_BrigHist2Form.SetXLATtoDraw ***
// Just set XLAT table to draw (without any redrawing)
//
procedure TN_BrigHist2Form.SetXLATtoDraw( APXLATtoDraw: PInteger );
begin
  with BHFrame do
  begin
    BHFPXLAT8toDraw := APXLATtoDraw;
  end; // with BHFrame do
end; // procedure TN_BrigHist2Form.SetXLATtoDraw

//******************************************** TN_BrigHist2Form.SetBriRange ***
// Set new Brightenss range and redraw all
//
procedure TN_BrigHist2Form.SetBriRange( AMinBri, AMaxBri: integer );
begin
  with BHFrame do
  begin
    CurMinBri := AMinBri; // Min brightness interval
    CurMaxBri := AMaxBri; // Max brightness interval

    if BHFSrcDIB = nil then Exit;

    CurMinBri8 := CurMinBri shr (BHFSrcDIB.DIBNumBits - 8); // conv to [0,255] range
    CurMaxBri8 := CurMaxBri shr (BHFSrcDIB.DIBNumBits - 8); // conv to [0,255] range

    CalcPolygons( GetMaxVisBrightness() ); // Calc all polygons coords
  end; // with BHFrame do

  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.SetBriRange

//*************************************** TN_BrigHist2Form.SetCurBrightness ***
// Set current Brightenss and redraw all
//
procedure TN_BrigHist2Form.SetCurBrightness( ABrightness: integer );
begin
  with BHFrame do
  begin
    CurBri := ABrightness;
    if BHFSrcDIB = nil then Exit;

    CurBri8 := CurBri shr (BHFSrcDIB.DIBNumBits - 8); // conv to [0,255] range
  end; // with BHFrame do

  RedrawBrighHist2Form();
end; // procedure TN_BrigHist2Form.SetCurBrightness


//************************************ TN_BrigHist2Form.GetMaxVisBrightness ***
// Get Max Visible Brightness (for needed Y scale)
//
function TN_BrigHist2Form.GetMaxVisBrightness(): integer;
var
  ScaleFactor: double;
begin
  if FirstDraw then // First Draw with new Histogramm
  begin
    Result := -1; // Auto scale mode
    Exit;
  end; // if FirstDraw then // First Draw with new Histogramm

  with BHFrame do
  begin
    ScaleFactor := Power( 0.001*(tbYScale.Position+5), 4 ); // ScaleFactor is in (0, 1) range
    Result := max( 5, Round( ScaleFactor*MaxXLATHistValue ) );
  end; // with BHFrame do

//  Result := 0;  // whole Range
end; // function TN_BrigHist2Form.GetMaxVisBrightness

//*************************************** TN_BrigHist2Form.SetSkipSelfClose ***
// Set "Skip Self Closing" flag
//
procedure TN_BrigHist2Form.SetSkipSelfClose( AValue : Boolean );
begin
  if Self = nil then Exit;
  SkipSelfCloseFlag := AValue;
end; // procedure TN_BrigHist2Form.SetSkipSelfClose

//********************************************** TN_BrigHist2Form.SelfClose ***
// Close Self if if closing is alowed by SkipSelfCloseFlag
//
procedure TN_BrigHist2Form.SelfClose( );
begin
  if (Self = nil) or SkipSelfCloseFlag then Exit;
  Close();
end; // procedure TN_BrigHist2Form.SelfClose


//****************** Global procedures **********************

//*************************************************** N_CreateBrigHist2Form ***
// Create TN_BrigHist2Form or prepare already existed Form
//
// ABHFSrcDIB   - Source DIBObj for getting Brightness values
// APBHist2Form - Pointer to variable with PBHist2Form
//                (this variable will be cleared in OnCloseForm handler)
// AFormCaption - Form Caption
// AOwner       - Owner of created PBHist2Form
//
procedure N_CreateBrigHist2Form( APBHist2Form: TN_PBrigHist2Form;
                                 AFormCaption: String; AOwner: TN_BaseForm );
begin
  Assert( APBHist2Form <> nil, 'APBHistForm=nil!' ); // a precaution

  if APBHist2Form^ = nil then // new BrigHist2Form should be created in
  begin                      // given variable, pointed to by APBHistForm
    APBHist2Form^ := TN_BrigHist2Form.Create( Application );

    with APBHist2Form^ do
    begin
      BaseFormInit( AOwner, 'BrigHist2Form', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      ActiveControl := BHFrame.RFrame;
      BFOnCloseActions.AddNewClearVarAction( APBHist2Form );
    end;

  end; // if APBHistForm^ = nil then // new BrigHist2Form should be created in

  with APBHist2Form^ do
  begin
    Caption := AFormCaption;

//  Show();    // is needed for correct working of Realign()
//  Realign(); // is needed for correct RFrame.Width, RFrame.Height

  with BHFrame do
  begin
    YAxisUnits := yauAbsNumbers;

    BHFSrcDIB := nil;
    BHFPXLAT8toConv  := nil;
    HistPolygonSize   := 0;
    BRangePolygonSize := 0;

//    YLabelsLefter := False;
//    DxLeft      := 4;
//    DxLabels    := 6;

    YLabelsLefter := True;
    DxLeft      := 64;
    DxLabels    := -3;

    DxRight     := 3;
    DyBottom    := 18;
    DyGrad      := 5;
    DyGradHist  := 4;
    DyTop       := 3;

    DyTicks     := 4;
    DyLabels    := 6;
    DxTicks     := 1;

    SetLength( BRDWidths, 256 );
    SetLength( BRWidths,  256 );
    SetLength( BRLefts,   256 );

    CurBri    := -1; // not given
    CurMinBri := -1;
    CurMaxBri := -1;

    BackColor      := ColorToRGB( clBtnFace );
    HistColor      := $888888;
    RangeMainColor := $444444;
    RangeBackColor := $EFEFEF;
    CurBriColor    := $0000FF;
    XLATPolygonColor := $00BB00;

    LabelsNFont := TN_UDNFont.Create2( 14, 'Arial' ); // 'Courier New'
    N_SetNFont( LabelsNFont, RFrame.OCanv );

    with RFrame do //***** Init RFrame
    begin
      RFrameResize( nil ); // all previous calls did not work because BrigHist2Form was not ready
      RFCenterInDst  := True;
      DrawProcObj    := RedrawBrighHist2Form;
      OCanvBackColor := -1; // to prevent clear RFrame OCanv Bufer
      OCanv.SetFontAttribs( 0 );

      RedrawAllAndShow();
    end; // with RFrame do //***** Init RFrame

  end; // with BHFrame do

  end; // with APBHist2Form^ do
end; // end of function N_CreateBrigHist2Form


end.



