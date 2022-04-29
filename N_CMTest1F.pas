unit N_CMTest1F;
// CMS Testing Form #1
// Load DLL - Load DLL test
// 16bitPNG - 16bitPNG test
// Test1    -

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, OleServer, ToolWin, ImgList, ExtCtrls,
  GDIPAPI, GDIPOBJ, Types,
  N_Types, N_Lib1, N_BaseF, N_Gra2;

type TN_CMTest1Form = class( TN_BaseForm )
    bnLoadDLL: TButton;
    StatusBar: TStatusBar;
    bn16bitPNG: TButton;
    bnTest1: TButton;
    Image1: TImage;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

    procedure bnLoadDLLClick  ( Sender: TObject );
    procedure bn16bitPNGClick ( Sender: TObject );
    procedure bnTest1Click    ( Sender: TObject );
  public
    CMT1DIB1: TN_DIBObj;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMTest1Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_CreateCMTest1Form ( AOwner: TN_BaseForm ): TN_CMTest1Form;


implementation
uses
  K_Gra0,
  N_CM1; //, N_CMExtDLL;
{$R *.dfm}

//****************  TN_CMTest1Form class handlers  ******************

//************************************************ TN_CMTest1Form.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_CMTest1Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil( CMT1DIB1 );

  Inherited;
end; // procedure TN_CMTest1Form.FormClose

procedure TN_CMTest1Form.bnLoadDLLClick( Sender: TObject );
var
  ResCode1, ResCode2: integer;
  ErrStr, EDLLFileName: string;
  EDLLHandle:  HMODULE; // DLL Windows Handle
  Ex20cVoidFunc: TN_cdeclIntFuncVoid;
//  IsButtonPressed:  TN_cdecIntFuncVoid;
  IsButtonPressed1: TN_cdeclIntFuncPWChar;
//  IsButtonLongPressAvailable:  TN_cdecIntFuncVoid;
  IsButtonLongPressAvailable1: TN_cdeclIntFuncPWChar;

  Ex20cSquareRootFunc: TN_cdeclDblFuncDbl;
  Ex20cWStringTransformerFunc: TN_cdeclPWCharFuncIntPWChar;
  WStr1, WStr2: WideString;
begin
//  EDLLFileName := 'C:\Tmp\Ex20c.dll';
//  EDLLFileName := 'C:\Tmp\SchickDllInterface_EMU.dll';
//  EDLLFileName := 'C:\Tmp\DelcomDLLInterface_EMU.dll';
//  EDLLFileName := 'C:\Tmp\SoproTouchDLLInterface_EMU.dll';
//  EDLLFileName := 'C:\Tmp\WinusDLLInterface_EMU.dll';

  EDLLFileName := 'SoredexDSD.dll';
  EDLLHandle := Windows.LoadLibrary( @EDLLFileName[1] );
{
  EDLLFileName := 'C:\Delphi_prj\CMS_Last\Petronevich\!OldVersions\SoredexDSDTest 1.5-2011-04-01\SoredexDSD.dll';
  EDLLHandle := Windows.LoadLibrary( @EDLLFileName[1] );

  EDLLFileName := 'C:\Delphi_prj\DTmp\!CMS_DLLsDev\SoredexDSD.dll';
  EDLLHandle := Windows.LoadLibrary( @EDLLFileName[1] );

  EDLLFileName := 'SchickDLLInterface.dll';
  EDLLHandle := Windows.LoadLibrary( @EDLLFileName[1] );

  EDLLFileName := 'C:\Delphi_prj\DTmp\!CMS_DLLsDev\SoredexDSD.dll';
  EDLLFileName := 'C:\Delphi_prj\DTmp\!CMS_DLLsDev\SoredexDSD.dll';

  EDLLFileName := 'C:\Delphi_prj\DTmp\!CMS_DLLsDev\SchickDLLInterface.dll';
  EDLLHandle := Windows.LoadLibrary( @EDLLFileName[1] );
}

  if EDLLHandle = 0 then // some error
  begin
    ErrStr  := SysErrorMessage( GetLastError() );
    N_Dump2Str( 'Error Loading ' + EDLLFileName + ': ' + ErrStr );
    Exit;
  end; // if EDLLHandle = 0 then // some error

  N_Dump2Str( 'TestDLL loaded: ' + EDLLFileName );

  IsButtonLongPressAvailable1 := GetProcAddress( EDLLHandle, 'IsButtonLongPressAvailable' );
  if not Assigned(IsButtonLongPressAvailable1) then
  begin
    N_Dump2Str( 'IsButtonLongPressAvailable is absent in ' + EDLLFileName );
  end;

  WStr1 := '123';
  ResCode1 := -5;
//  ResCode1 := IsButtonLongPressAvailable();
//  ResCode1 := IsButtonLongPressAvailable1( @WStr1[1] );

  IsButtonPressed1 := GetProcAddress( EDLLHandle, 'IsButtonPressed' );
  if not Assigned(IsButtonPressed1) then
  begin
    N_Dump2Str( 'IsButtonPressed is absent in ' + EDLLFileName );
  end;

//  ResCode2 := IsButtonPressed();
  ResCode2 := IsButtonPressed1( @WStr1[1] );
//  StatusBar.SimpleText := Format( 'SchickDllInterface_EMU.dll Result = %d %d', [ResCode1,ResCode2] );
  StatusBar.SimpleText := Format( 'SoproTouchDLLInterface_EMU.dll Result = %d %d', [ResCode1,ResCode2] );
  FreeLibrary( EDLLHandle );
  Exit;


  Ex20cVoidFunc := GetProcAddress( EDLLHandle, 'Ex20cVoid' );
  if not Assigned(Ex20cVoidFunc) then
  begin
    N_Dump2Str( 'Ex20cVoidFunc is absent in ' + EDLLFileName );
  end;

  ResCode1 := Ex20cVoidFunc();

  Ex20cSquareRootFunc := GetProcAddress( EDLLHandle, 'Ex20cSquareRoot' );
  if not Assigned(Ex20cSquareRootFunc) then
  begin
    N_Dump2Str( 'Ex20cSquareRootFunc is absent in ' + EDLLFileName );
  end;

  N_d := Ex20cSquareRootFunc( 16.0 );

  Ex20cWStringTransformerFunc := GetProcAddress( EDLLHandle, 'Ex20cWStringTransformer' );
  if not Assigned(Ex20cWStringTransformerFunc) then
  begin
    N_Dump2Str( 'Ex20cWStringTransformerFunc is absent in ' + EDLLFileName );
  end;

  WStr1 := '123¿¡';
  WStr2 := '0';
  WStr2[1] := Ex20cWStringTransformerFunc( 4, @WStr1[1] )^;

  StatusBar.SimpleText := Format( 'Ex20cVoid Result = %d', [ResCode1] );
  FreeLibrary( EDLLHandle );
end; // procedure TN_CMTest1Form.bnLoadDLLClick

procedure TN_CMTest1Form.bn16bitPNGClick( Sender: TObject );
var
  GDIPlus: TK_GPDIBCodecsWrapper;
  Res: TStatus;
begin
  GDIPlus := TK_GPDIBCodecsWrapper.Create();
  Res := GDIPlus.GPLoadFromFile( 'C:\Delphi_prj\Images\16bits\CMSTD_05_8b.png' );
  N_Dump1Str( Format( '%d,   8b pix fmt - %8X', [integer(Res),GDIPlus.GPFramePixFmt] ));
  Res := GDIPlus.GPLoadFromFile( 'C:\Delphi_prj\Images\16bits\CMSTD_05_16b.png' );
  N_Dump1Str( Format( '%d,  16b pix fmt - %8X', [integer(Res),GDIPlus.GPFramePixFmt] ));

//  inherited;

end; // procedure TN_CMTest1Form.bn16bitPNGClick

procedure TN_CMTest1Form.bnTest1Click( Sender: TObject );
var
  i: integer;
  TmpBitmap1, TmpBitmap2, TmpBitmap3: TBitmap;
  DIBObj1, DIBObj2, DIBObjMask: TN_DIBObj;
  ROP4: DWORD;
  HPal1, HPal2: HPALETTE;
  Pal: TN_LogPalette;
  PalInds, PalVals: TN_IArray;
  Label Start;
begin
  //***** Prepare Image1 for drawing in it (should be done only once)
  TmpBitmap1 := N_CreateEmptyBMP( Image1.Width, Image1.Height, pf24bit );
  Image1.Picture.Graphic := TmpBitmap1; // now TmpBitmap1 can be destroyed
  TmpBitmap1.Free;
  StatusBar.SimpleText := 'Prepare Image1 for drawing';
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Load DIBs
  DIBObj1 := TN_DIBObj.Create( '..\TestData\RedScale24bit.bmp' ); // Red Menu background
  DIBObj2 := TN_DIBObj.Create( '..\TestData\GreenScale24bit.bmp' ); // Green Highlited Items
  DIBObjMask := TN_DIBObj.Create( '..\TestData\GrayScale8bit.bmp' ); // Menu Items Mask

  //***** Show background Red Menu
  N_CopyRect( Image1.Picture.Bitmap.Canvas.Handle, Point(0,0), DIBObj1.DIBOCanv.HMDC, DIBObj1.DIBRect );
  StatusBar.SimpleText := 'Show background Red Menu';
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show Highlited Green Items
  N_CopyRect( Image1.Picture.Bitmap.Canvas.Handle, Point(0,0), DIBObj2.DIBOCanv.HMDC, DIBObj2.DIBRect );
  StatusBar.SimpleText := 'Show Highlited Green Items';
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show Items Mask
  N_CopyRect( Image1.Picture.Bitmap.Canvas.Handle, Point(0,0), DIBObjMask.DIBOCanv.HMDC, DIBObjMask.DIBRect );
  StatusBar.SimpleText := 'Show Items Mask';
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show Two Highlited Green Items
  SetLength( PalInds, 2 ); // two Highlited Items
  PalInds[0] := $90;
  PalInds[1] := $A1;
  TmpBitmap2 := nil; // is really needed before first call!
  N_DrawGraphicMenuItems( Image1.Picture.Bitmap.Canvas.Handle, DIBObj2, DIBObj1, DIBObjMask,
                                                   @PalInds[0], 2, TmpBitmap2 );
  StatusBar.SimpleText := 'Show Two ($90,$A1) Highlited Green Items';
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show another Two Highlited Green Items
  PalInds[0] := $91;
  PalInds[1] := $A2;
  N_DrawGraphicMenuItems( Image1.Picture.Bitmap.Canvas.Handle, DIBObj2, DIBObj1, DIBObjMask,
                                                   @PalInds[0], 2, TmpBitmap2 );
  StatusBar.SimpleText := 'Show another Two ($91,$A2) Highlited Green Items';
  Repaint();
  DIBObj1.Free;
  DIBObj2.Free;
  DIBObjMask.Free;
  TmpBitmap2.Free;
  Exit;
//********************************************************

  Image1.Picture.Bitmap := N_CreateEmptyBMP( Image1.Width, Image1.Height, pf24bit );
  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color := $FF;
    FillRect( Rect( 10,10,60,40) );
  end;
  Repaint;
  Exit;


  DIBObj1 := TN_DIBObj.Create( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
  for i := 0 to 255 do DIBObj1.DIBInfo.PalEntries[i] := i;
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\BlueScale8.bmp' );
  for i := 0 to 255 do DIBObj1.DIBInfo.PalEntries[i] := i shl 8;
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GreenScale8.bmp' );
  for i := 0 to 255 do DIBObj1.DIBInfo.PalEntries[i] := i shl 16;
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\RedScale8.bmp' );
  Exit;

  N_i1 := Windows.SetDIBColorTable( DIBObj1.DibOCanv.HMDC, 0, 256, DIBObj1.DIBInfo.PalEntries[0] );

  SetLength( PalInds, 2 );
  PalInds[0] := 1;
  PalInds[1] := 18;
//  TmpBitmap1 := N_Create1BitBMPby8BitDIB( DIBObj1, @PalInds[0], 2 );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask1.bmp' );
  DIBObj1.Free;
  TmpBitmap1.Free;
  Exit;

  DIBObj1 := TN_DIBObj.Create( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
  SetLength( PalInds, 2 );
  PalInds[0] := 1;
  PalInds[1] := 18;
//  TmpBitmap1 := N_Create1BitBMPby8BitDIB( DIBObj1, @PalInds[0], 2 );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask1.bmp' );
  DIBObj1.Free;
  TmpBitmap1.Free;
  Exit;


  DIBObj1 := TN_DIBObj.Create( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
//  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask3c.bmp' );
  TmpBitmap1 := DIBObj1.CreateBitmap( DIBObj1.DIBRect );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask4a.bmp' );
  TmpBitmap1.Free;

  DIBObj1.DIBInfo.PalEntries[1] := $FF;
  DIBObj1.DIBInfo.PalEntries[3] := $FFFF;
  TmpBitmap1 := DIBObj1.CreateBitmap( DIBObj1.DIBRect );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask4b.bmp' );
  TmpBitmap1.Free;

  N_i1 := Windows.SetDIBColorTable( DIBObj1.DibOCanv.HMDC, 0, 256, DIBObj1.DIBInfo.PalEntries[0] );
  TmpBitmap1 := DIBObj1.CreateBitmap( DIBObj1.DIBRect );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask4c.bmp' );
  TmpBitmap1.Free;

  Exit;


  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask2a.bmp' );

  SetLength( PalVals, 2 );
  PalVals[0] := $FF;
  PalVals[1] := $FFFF;
  N_b := AnimatePalette( TmpBitmap1.Palette, 0, 3, PPaletteEntry(@PalVals[0]) );
//  HPal1 := SelectPalette( TmpBitmap1.Canvas.Handle, TmpBitmap1.Palette, LongBool(1) );

  N_i := RealizePalette( TmpBitmap1.Canvas.Handle );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask2b.bmp' );
  Exit;

  DIBObj1 := TN_DIBObj.Create( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask3a.bmp' );
  DIBObj1.DIBInfo.PalEntries[1] := $FF;
  DIBObj1.DIBInfo.PalEntries[3] := $FFFF;
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask3b.bmp' );
  N_i1 := Windows.SetDIBColorTable( DIBObj1.DibOCanv.HMDC, 0, 256, DIBObj1.DIBInfo.PalEntries[0] );
  DIBObj1.SaveToBMPFormat( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask3c.bmp' );
  Exit;

  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\GrayScale8a.bmp' );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask2a.bmp' );
  SetLength( PalVals, 2 );
  PalVals[0] := $FF;
  PalVals[1] := $FFFF;
  N_b := AnimatePalette( TmpBitmap1.Palette, 0, 3, PPaletteEntry(@PalVals[0]) );
//  HPal1 := SelectPalette( TmpBitmap1.Canvas.Handle, TmpBitmap1.Palette, LongBool(1) );

  N_i := RealizePalette( TmpBitmap1.Canvas.Handle );
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Mask2b.bmp' );
  Exit;

  goto Start;

  //***** Show Normal_Teeths.bmp
  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Normal_Teeths.bmp' );
  Image1.Picture.Graphic := TmpBitmap1;
  TmpBitmap1.Free;
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show Highlighted_Teeths.bmp
  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Highlighted_Teeths.bmp' );
  Image1.Picture.Graphic := TmpBitmap1;
  TmpBitmap1.Free; // is used later
  Repaint();
  N_DelayInSeconds( 1000 );

  Start:
  //***** Show Masks_Teeths8.bmp
  DIBObj1 := TN_DIBObj.Create( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Masks_Teeths8.bmp' );
  N_p := @DIBObj1;
  Image1.Picture.Graphic := N_CreateEmptyBMP(TmpBitmap1.Width, TmpBitmap1.Height, pf1bit );

  TmpBitmap1 := TBitmap.Create;
  TmpBitmap1.LoadFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Masks_Teeths8.bmp' );
//  TmpBitmap1.LoadFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\PANT256.bmp' );
  Image1.Picture.Graphic := TmpBitmap1;
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Show Masks_Teeths8.bmp with changed Palette
  HPal1 := TmpBitmap1.Palette;
  Windows.GetPaletteEntries( HPal1, 0, 256, Pal.palEntries[0] );
//  ZeroMemory( @Pal.palEntries[0], 1024 );
  Pal.palVersion    := $300;
  Pal.palNumEntries := 256;
//  for i := 0 to 255 do
  for i := 0 to 50 do
//    Pal.PalEntries[i] := (i shl 16) or (i shl 8) or i;
    Pal.PalEntries[i] := 255 - i;
//  Pal.palEntries[27] := $FF;
//  Pal.palEntries[13] := $FFFF;
  HPal2 := Windows.CreatePalette( Pal.Header );
  TmpBitmap1.Palette := HPal2;
  TmpBitmap1.SaveToFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Masks_Teeths8aR.bmp' );
  Image1.Picture.Graphic := TmpBitmap1;
  TmpBitmap1.Free;
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Create and show pf1bit mask in TmpBitmap2 with size given by TmpBitmap1
  TmpBitmap2 := N_CreateEmptyBMP(TmpBitmap1.Width, TmpBitmap1.Height, pf1bit );
  with TmpBitmap2.Canvas do
  begin
//    Brush.Color := $FFFFFF;
    Brush.Color := 0;
    FillRect( Rect( 10,10,60,40) );
  end;
  Image1.Picture.Graphic := TmpBitmap2;
//  TmpBitmap2.Free; // will be used later!
  Repaint();
  N_DelayInSeconds( 1000 );


  //***** Draw Highlighted over Normal with Rect( 10, 10, 60, 40) mask in Rect(0,0,200,150)
  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Normal_Teeths.bmp' );
  TmpBitmap3 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Highlighted_Teeths.bmp' );

  // function MakeROP4(foregroundROP, backgroundROP: DWORD): DWORD;

//  ROP4 := MakeROP4( SRCCOPY, SRCCOPY );              // Src in all pixels
//  ROP4 := MakeROP4( PATINVERT, WHITENESS ); // White in Rect( 10,10,60,40), Src in all other pixels
//  ROP4 := MakeROP4( PATINVERT, SRCCOPY );
  ROP4 := MakeROP4( $00AA0029, SRCCOPY ); // Src(TmpBitmap3) in Rect( 10,10,60,40), Dst(TmpBitmap1) in all other pixels

  // TmpBitmap2 consists of 0 in Rect( 10, 10, 60, 40) and of 1 in all other pixels
  N_CopyRectByMask( TmpBitmap1.Canvas.Handle, Point(0,0), TmpBitmap3.Canvas.Handle, Rect(0,0,220,170), TmpBitmap2.Handle, ROP4 );
  Image1.Picture.Graphic := TmpBitmap1;
  TmpBitmap1.Free;
  Repaint();
  N_DelayInSeconds( 1000 );

  //***** Draw Highlighted over Normal in Teeths (27,70) in Rect(0,0,200,150)
  TmpBitmap1 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Normal_Teeths.bmp' );      // Dst
  TmpBitmap3 := N_CreateBMPObjFromFile( 'C:\Delphi_prj\CMS_Last\Karpenkov\Kotov_Pics\Highlighted_Teeths.bmp' ); // Src

  TmpBitmap2 := TBitmap.Create;
  TmpBitmap2.PixelFormat := pf1bit;
  TmpBitmap2.Width  := TmpBitmap1.Width;
  TmpBitmap2.Height := TmpBitmap1.Height;

  ROP4 := MakeROP4( $00AA0029, SRCCOPY ); // Src(TmpBitmap3) in 0 mask pixels, Dst(TmpBitmap1) in 1 mask pixels

  // TmpBitmap2 consists of 0 in Rect( 10, 10, 60, 40) and of 1 in all other pixels
  N_CopyRectByMask( TmpBitmap1.Canvas.Handle, Point(0,0), TmpBitmap3.Canvas.Handle, Rect(0,0,220,170), TmpBitmap2.Handle, ROP4 );
  Image1.Picture.Graphic := TmpBitmap1;
  TmpBitmap1.Free;
  Repaint();

end; // procedure TN_CMTest1Form.bnTest1Click


//****************  TN_CMTest1Form class public methods  ************

//***************************************** TN_CMTest1Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMTest1Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMTest1Form.CurStateToMemIni

//***************************************** TN_CMTest1Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMTest1Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMTest1Form.MemIniToCurState


    //*********** Global Procedures  *****************************

//***************************************************** N_CreateCMTest1Form ***
// Create and return new instance of TN_CMTest1Form
//
//     Parameters
// AOwner - Owner of created Form
// Result - Return created Form
//
function N_CreateCMTest1Form( AOwner: TN_BaseForm ): TN_CMTest1Form;
begin
  Result := TN_CMTest1Form.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  end;
end; // function N_CreateCMTest1Form

end.
