unit N_PrintF;
// Print given OCanvas Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF, N_Rast1Fr;

type TN_PrintForm = class( TN_BaseForm )
    PrinterSetupDialog: TPrinterSetupDialog;
    Label1: TLabel;
    lbResolution: TLabel;
    lbPaperSize: TLabel;
    bnPrinterSetup: TButton;
    GroupBox1: TGroupBox;
    edTopMargin: TLabeledEdit;
    edBottomMargin: TLabeledEdit;
    edLeftMargin: TLabeledEdit;
    edRightMargin: TLabeledEdit;
    GroupBox2: TGroupBox;
    edImageWidth: TLabeledEdit;
    edImageHeight: TLabeledEdit;
    cbMaxPossibleSize: TCheckBox;
    cbMantainAspect: TCheckBox;
    bnSetMinMargins: TButton;
    bnPrint: TButton;
    mbHorAlign: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    mbVertAlign: TComboBox;
    Timer: TTimer;
    Bevel1: TBevel;
    bnSetOriginalSize: TButton;

    procedure bnSetMinMarginsClick    ( Sender: TObject );
    procedure cbMaxPossibleSizeClick  ( Sender: TObject );
    procedure cbMantainAspectClick    ( Sender: TObject );
    procedure bnSetOriginalSizeClick  ( Sender: TObject );
    procedure bnPrinterSetupClick     ( Sender: TObject );
    procedure PrinterSetupDialogClose ( Sender: TObject );
    procedure TimerTimer              ( Sender: TObject );
    procedure bnPrintClick            ( Sender: TObject );

    procedure edImageSizeKeyDown ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
    DeviceRes:  TPoint;   // Device (X,Y) resolutions in DPI
    PaperSize:  TDPoint;  // Device (X,Y) Paper Size in millimeters
    MinMargin:  TDPoint;  // Minimal Device (X,Y) Margins in millimeters
    ImageSize:  TDPoint;  // Image (X,Y) Size in millimeters
    PrAreaSize: TDPoint;  // Printable Area Size in millimeters
    Margins:    TFRect;   // Current Margins in millimeters
  public
    SrcRFrame: TN_Rast1Frame; // Source RFrame with Image to Print in RFrame.OCanv
    SrcRect: Trect;        // Rect to print in Canvas Pixels
    Srcmm: TFPoint;        // Original Sizes in mm
    MISecName: string;     // MemIni File Section Name used for saving-restoring Self context

    procedure GetPrinterInfo   (); // Set internal Form fields and show info about Printer
    procedure UpdateFields     ();
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_PrintForm = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

function N_CreatePrintForm ( ARFrame: TN_Rast1Frame; ASrcRect: Trect;
                             ASrcmm: TFPoint; AMISecName: string;
                                          AOwner: TN_BaseForm ): TN_PrintForm;

implementation
uses Printers,
  N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra2;
{$R *.dfm}

//****************  TN_PrintForm class handlers  ******************

procedure TN_PrintForm.bnSetMinMarginsClick( Sender: TObject );
// Set Minimal Margins
begin
  edLeftMargin.Text   := Format( ' %.1f', [MinMargin.X] );
  edRightMargin.Text  := Format( ' %.1f', [MinMargin.X] );
  edTopMargin.Text    := Format( ' %.1f', [MinMargin.Y] );
  edBottomMargin.Text := Format( ' %.1f', [MinMargin.Y] );
  UpdateFields();
end; // procedure TN_PrintForm.bnSetMinMarginsClick

procedure TN_PrintForm.cbMaxPossibleSizeClick( Sender: TObject );
// Update ImageSize after changing "MaxPossible Image Size" flag
begin
  edImageWidth.Enabled  := not cbMaxPossibleSize.Checked;
  edImageHeight.Enabled := not cbMaxPossibleSize.Checked;
  UpdateFields();
end; // procedure TN_PrintForm.cbSizeMaxPossibleClick

procedure TN_PrintForm.cbMantainAspectClick( Sender: TObject );
// Update ImageSize after changing MantainAspect mode
begin
  UpdateFields();
end; // procedure TN_PrintForm.cbMantainAspectClick

procedure TN_PrintForm.bnSetOriginalSizeClick( Sender: TObject );
// Set Original Image Size
begin
  edImageWidth.Text  := Format( ' %.1f', [Srcmm.X] );
  edImageHeight.Text := Format( ' %.1f', [Srcmm.Y] );
  UpdateFields();
end; // procedure TN_PrintForm.bnSetOriginalSizeClick

procedure TN_PrintForm.bnPrinterSetupClick( Sender: TObject );
// Show PrinterSetupDialog
begin
  PrinterSetupDialog.Execute();
end; // procedure TN_PrintForm.bnPrinterSetupClick

procedure TN_PrintForm.PrinterSetupDialogClose( Sender: TObject );
// Setting Current Info about Printer is impossible inside this handler
// because Printer object was not yet changed by Delphi.
// Real setting will take place by Self.GetPrinterInfo() method, which
// would be called from OnTimer event handler (see just bellow)
begin
  Timer.Enabled := True;
end; // procedure TN_PrintForm.PrinterSetupDialogClose

procedure TN_PrintForm.TimerTimer( Sender: TObject );
// Update once Current Info about Printer by Self.GetPrinterInfo() method
begin
  Timer.Enabled := False;
  GetPrinterInfo();
end; // procedure TN_PrintForm.TimerTimer

procedure TN_PrintForm.bnPrintClick( Sender: TObject );
// Do Printing
var
  ImageShift: TDPoint;
  DstRect, PixPageRect: TRect;
  ImageRect: TFRect;
  AffCoefs: TN_AffCoefs4;
begin
  UpdateFields();

  ImageShift.X := 0.5 * mbHorAlign.ItemIndex  * ( PrAreaSize.X - ImageSize.X );
  ImageShift.Y := 0.5 * mbVertAlign.ItemIndex * ( PrAreaSize.Y - ImageSize.Y );
  ImageRect := FRect( ImageSize );
  ImageRect := N_RectShift( ImageRect, ImageShift.X, ImageShift.Y );

  PixPageRect := Rect( 0, 0, Printer.PageWidth-1, Printer.PageHeight-1 );
  AffCoefs := N_CalcAffCoefs4( FRect( PrAreaSize ), FRect( PixPageRect ) );
  DstRect := N_AffConvF2IRect( ImageRect, AffCoefs );

  Printer.BeginDoc;
  N_StretchRect( Printer.Canvas.Handle, DstRect, SrcRFrame.OCanv.HMDC, SrcRect );
  Printer.EndDoc;

{ // debug
  Printer.Canvas.Pen.Width := 1;
  Printer.Canvas.Rectangle( -2,-2,Printer.PageWidth+1,Printer.PageHeight+1 );
  Printer.Canvas.Rectangle( 0,0,Printer.PageWidth-1,Printer.PageHeight-1 );
  Printer.Canvas.Rectangle( 2,2,Printer.PageWidth-3,Printer.PageHeight-3 );
  Printer.Canvas.Rectangle( 0,0,600,600 );
  Printer.Canvas.Rectangle( 600,600,1200,1200 );
}
end; // procedure TN_PrintForm.bnPrintClick

procedure TN_PrintForm.edImageSizeKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
// Update Image Size and Marins if needed
// (edImageWidth, edImageHeight and ed...Margin  OnKeyDown event handler)
begin
  if Key = VK_RETURN then
    UpdateFields();
end; // procedure TN_PrintForm.edImageSizeKeyDown

procedure TN_PrintForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_PrintForm.FormClose

//****************  TN_PrintForm class public methods  ************

//***********************************  TN_PrintForm.GetPrinterInfo  ******
// Get info about Printer, show it and Set internal Form fields by it
// ( set DeviceRes, MinMargin, PrAreaSize, PaperSize )
//
procedure TN_PrintForm.GetPrinterInfo();
begin
  //***** Set Pinter (X,Y) Resolution in device pixels
  DeviceRes.X := GetDeviceCaps( Printer.Handle, LOGPIXELSX );
  DeviceRes.Y := GetDeviceCaps( Printer.Handle, LOGPIXELSY );
  lbResolution.Caption := Format( 'Resolution (X,Y) : %d x %d DPI',
                                             [DeviceRes.X, DeviceRes.Y] );

  //***** Set Pinter (X,Y) Minimal Margins in millimeters
  MinMargin.X := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX ) / DeviceRes.X;
  MinMargin.Y := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY ) / DeviceRes.Y;

  //***** Set Pinter (X,Y) Printeble Area Size in millimeters
  PrAreaSize.X := GetDeviceCaps( Printer.Handle, HORZSIZE );
  PrAreaSize.Y := GetDeviceCaps( Printer.Handle, VERTSIZE );

  //***** Set Pinter (X,Y) Paper Size in millimeters
  PaperSize.X := PrAreaSize.X + 2*MinMargin.X;
  PaperSize.Y := PrAreaSize.Y + 2*MinMargin.Y;
  lbPaperSize.Caption := Format( 'Paper (X,Y) : %.1f x %.1f mm',
                                       [PaperSize.X, PaperSize.Y] );

{  //***** Show Test Strings:
  lbTst1.Caption := 'Delphi Page   X,Y : ' + IntToStr( Printer.PageWidth ) + ' x ' + IntToStr( Printer.PageHeight );

  N_i1 := GetDeviceCaps( Printer.Handle, PHYSICALWIDTH ) - 2*GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX );
  N_i2 := GetDeviceCaps( Printer.Handle, PHYSICALHEIGHT ) - 2*GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY );
  lbTst2.Caption := 'Phisical Size X,Y : ' + IntToStr( N_i1 ) + ' x ' + IntToStr( N_i2 );

  N_i1 := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX );
  N_i2 := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY );
  lbTst3.Caption := 'Phisical Offset X,Y : ' + IntToStr( N_i1 ) + ' x ' + IntToStr( N_i2 );
}
end; // end of procedure TN_PrintForm.GetPrinterInfo

//***********************************  TN_PrintForm.UpdateFields  ******
// Update Image X,Y Size and Margins; set ImageSize, PrAreaSize Margins Form fields
//
procedure TN_PrintForm.UpdateFields();
var
  Str: string;
  Rest: double;
begin
  GetPrinterInfo(); // a precaution

  Str := edLeftMargin.Text  + ' ' + edTopMargin.Text +
         edRightMargin.Text + ' ' + edBottomMargin.Text;
  Margins := N_ScanFRect( Str );

  if Margins.Left   < MinMargin.X then Margins.Left   := MinMargin.X;
  if Margins.Top    < MinMargin.Y then Margins.Top    := MinMargin.Y;
  if Margins.Right  < MinMargin.X then Margins.Right  := MinMargin.X;
  if Margins.Bottom < MinMargin.Y then Margins.Bottom := MinMargin.Y;

  if (Margins.Left + Margins.Right) > PaperSize.X then
  begin
    Margins.Left  := Round(0.5*PaperSize.X) - 1;
    Margins.Right := Round(0.5*PaperSize.X) - 1;
  end;

  if (Margins.Top + Margins.Bottom) > PaperSize.Y then
  begin
    Margins.Top    := Round(0.5*PaperSize.Y) - 1;
    Margins.Bottom := Round(0.5*PaperSize.Y) - 1;
  end;

  edLeftMargin.Text   := Format( ' %.1f', [Margins.Left]   );
  edTopMargin.Text    := Format( ' %.1f', [Margins.Top]    );
  edRightMargin.Text  := Format( ' %.1f', [Margins.Right]  );
  edBottomMargin.Text := Format( ' %.1f', [Margins.Bottom] );

  Str := edImageWidth.Text + ' ' + edImageHeight.Text;
  ImageSize := N_ScanDPoint( Str );

  //***** decrease Image Size by PrAreaSize and Margins
  Rest := PaperSize.X - Margins.Left - Margins.Right;
  if ImageSize.X > Rest then ImageSize.X := Rest;

  Rest := PaperSize.Y - Margins.Top - Margins.Bottom;
  if ImageSize.Y > Rest then ImageSize.Y := Rest;

  if cbMaxPossibleSize.Checked then
  begin
    ImageSize.X := PaperSize.X - Margins.Left - Margins.Right;
    ImageSize.Y := PaperSize.Y - Margins.Top  - Margins.Bottom;
  end;

  if ImageSize.X < 1 then ImageSize.X := 1; // a precaution
  if ImageSize.Y < 1 then ImageSize.Y := 1;

  if cbMantainAspect.Checked then
    ImageSize := N_AdjustSizeByAspect ( aamDecRect, ImageSize,
                                                     N_RectAspect( SrcRect ) );

  edImageWidth.Text  := Format( ' %.1f', [ImageSize.X] );
  edImageHeight.Text := Format( ' %.1f', [ImageSize.Y] );
end; // end of procedure TN_PrintForm.UpdateFields

//***********************************  TN_PrintForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_PrintForm.CurStateToMemIni();
var
  Str: string;
begin
  Inherited;
  Str := edLeftMargin.Text  + ' ' + edTopMargin.Text +
         edRightMargin.Text + ' ' + edBottomMargin.Text +
         edImageWidth.Text  + ' ' + edImageHeight.Text;

  N_StringToMemIni( MISecName, 'MS', Str );
  N_BoolToMemIni(   MISecName, 'MP', cbMaxPossibleSize.Checked );
  N_BoolToMemIni(   MISecName, 'MA', cbMantainAspect.Checked );

  N_IntToMemIni(    MISecName, 'HA', mbHorAlign.ItemIndex );
  N_IntToMemIni(    MISecName, 'VA', mbVertAlign.ItemIndex );
end; // end of procedure TN_PrintForm.CurStateToMemIni

var
  H_Align: Array [0..2] of string = ( 'Left', 'Center', 'Right' );
  V_Align: Array [0..2] of string = ( 'Top',  'Center', 'Bottom' );

//***********************************  TN_PrintForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_PrintForm.MemIniToCurState();
var
  Str: string;
begin
  Inherited;
  Str := N_MemIniToString( MISecName, 'MS', '20 20 20 20 1000 1000' );

  edLeftMargin.Text   := Format( ' %.1f', [N_ScanDouble( Str )]   );
  edTopMargin.Text    := Format( ' %.1f', [N_ScanDouble( Str )]    );
  edRightMargin.Text  := Format( ' %.1f', [N_ScanDouble( Str )]  );
  edBottomMargin.Text := Format( ' %.1f', [N_ScanDouble( Str )] );

  edImageWidth.Text   := Format( ' %.1f', [N_ScanDouble( Str )] );
  edImageHeight.Text  := Format( ' %.1f', [N_ScanDouble( Str )] );

  N_SetMBItems( mbHorAlign,  H_Align, N_MemIniToInt(MISecName, 'HA', 1), -1 );
  N_SetMBItems( mbVertAlign, V_Align, N_MemIniToInt(MISecName, 'HA', 1), -1 );

  cbMaxPossibleSize.Checked := N_MemIniToBool( MISecName, 'MP', True );
  cbMantainAspect.Checked   := N_MemIniToBool( MISecName, 'MA', True );
end; // end of procedure TN_PrintForm.MemIniToCurState

    //*********** Global Procedures  *****************************

//********************************************  N_CreatePrintForm  ******
// Create and return new instance of TN_PrintForm
//
// AOCanv     - Canvas with Image to Print
// ASrcRect   - Rect in Canvas Pixels to print
// AMISecName - MemIni File Section Name used for saving-restoring Self context
// AOwner     - Owner of created Form
//
function N_CreatePrintForm( ARFrame: TN_Rast1Frame; ASrcRect: Trect;
                            ASrcmm: TFPoint; AMISecName: string;
                                           AOwner: TN_BaseForm ): TN_PrintForm;
begin
  Result := TN_PrintForm.Create( Application );
  with Result do
  begin
    SrcRFrame := ARFrame;
    SrcRect   := ASrcRect;
    Srcmm     := ASrcmm;
    MISecName := AMISecName;
    BaseFormInit( AOwner ); // (prev. fields are used in MemIniToCurState!)
//    Printer.Copies := 3;
  end;
end; // function N_CreatePrintForm

end.
