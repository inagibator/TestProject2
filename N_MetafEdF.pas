unit N_MetafEdF;
// View, Edit and Print Metafiles

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, Types,
  ActnList, ComCtrls, ToolWin, ImgList,
  N_Types, N_Gra0, N_Gra1, N_Lib1, N_BaseF, N_FNameFr, N_Rast1Fr;

type TN_MetafEdForm = class( TN_BaseForm )
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    View1: TMenuItem;
    Edit1: TMenuItem;
    PageControl: TPageControl;
    tsAttribs: TTabSheet;
    TabSheet2: TTabSheet;
    ActionList1: TActionList;
    actFileLoad: TAction;
    LoadMetafile1: TMenuItem;
    frFileName: TN_FileNameFrame;
    edSizeInPix: TLabeledEdit;
    StatusBar: TStatusBar;
    edSizeInKb: TLabeledEdit;
    edNRecords: TLabeledEdit;
    actEditCopy: TAction;
    actEditPaste: TAction;
    actViewMetafile: TAction;
    CopyToClipboard1: TMenuItem;
    PastefromClipboard1: TMenuItem;
    ViewMetafile1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Debug1: TMenuItem;
    Export1: TMenuItem;
    ExporttoSDMLines1: TMenuItem;
    actFileSave: TAction;
    ToolButton5: TToolButton;
    SaveMetafile1: TMenuItem;
    actExpXMLLines: TAction;
    actViewXML: TAction;
    actImpXMLLines: TAction;
    ViewXMLfile1: TMenuItem;
    Import1: TMenuItem;
    ImportfromXMLlinesfiles1: TMenuItem;
    actExpTxtDump: TAction;
    ExportToText1: TMenuItem;
    aDebCreateATest1EMF: TAction;
    aDebCreateATest2EMF: TAction;
    CreateATest1emf1: TMenuItem;
    CreateATest2emf1: TMenuItem;

      //******************  ActionList handlers  *************************

      //*************** File handlers *************************
    procedure actFileLoadExecute ( Sender: TObject );
    procedure actFileSaveExecute ( Sender: TObject );

      //*************** Edit handlers *************************
    procedure actEditCopyExecute  ( Sender: TObject );
    procedure actEditPasteExecute ( Sender: TObject );

      //*************** View handlers *************************
    procedure actViewMetafileExecute ( Sender: TObject );
    procedure actViewXMLExecute      ( Sender: TObject );

      //*************** Import handlers *************************
    procedure actImpXMLLinesExecute ( Sender: TObject );

      //*************** Export handlers *************************
    procedure actExpXMLLinesExecute ( Sender: TObject );
    procedure actExpTxtDumpExecute  ( Sender: TObject );

      //*************** Debug handlers *************************
    procedure aDebCreateATest1EMFExecute ( Sender: TObject );
    procedure aDebCreateATest2EMFExecute ( Sender: TObject );

      //*************** Other handlers *************************
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    CurMetafile: TMetafile;
    procedure ShowAttribs ();
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_MetafEdForm = class( TN_BaseForm )

function N_GetMetafEdForm( AOwner: TN_BaseForm ): TN_MetafEdForm;

var
  N_EMRNames: array [0..120] of string = ( 'Empty',
  'EMR_HEADER', 'EMR_POLYBEZIER', 'EMR_POLYGON', 'EMR_POLYLINE',
  'EMR_POLYBEZIERTO', 'EMR_POLYLINETO', 'EMR_POLYPOLYLINE',
  'EMR_POLYPOLYGON', 'EMR_SETWINDOWEXTEX', 'EMR_SETWINDOWORGEX',
  'EMR_SETVIEWPORTEXTEX', 'EMR_SETVIEWPORTORGEX', 'EMR_SETBRUSHORGEX',
  'EMR_EOF', 'EMR_SETPIXELV', 'EMR_SETMAPPERFLAGS', 'EMR_SETMAPMODE',
  'EMR_SETBKMODE', 'EMR_SETPOLYFILLMODE', 'EMR_SETROP2', 'EMR_SETSTRETCHBLTMODE',
  'EMR_SETTEXTALIGN', 'EMR_SETCOLORADJUSTMENT', 'EMR_SETTEXTCOLOR',
  'EMR_SETBKCOLOR', 'EMR_OFFSETCLIPRGN', 'EMR_MOVETOEX', 'EMR_SETMETARGN',
  'EMR_EXCLUDECLIPRECT', 'EMR_INTERSECTCLIPRECT', 'EMR_SCALEVIEWPORTEXTEX',
  'EMR_SCALEWINDOWEXTEX', 'EMR_SAVEDC', 'EMR_RESTOREDC', 'EMR_SETWORLDTRANSFORM',
  'EMR_MODIFYWORLDTRANSFORM', 'EMR_SELECTOBJECT', 'EMR_CREATEPEN',
  'EMR_CREATEBRUSHINDIRECT', 'EMR_DELETEOBJECT', 'EMR_ANGLEARC', 'EMR_ELLIPSE',
  'EMR_RECTANGLE', 'EMR_ROUNDRECT', 'EMR_ARC', 'EMR_CHORD', 'EMR_PIE',
  'EMR_SELECTPALETTE', 'EMR_CREATEPALETTE', 'EMR_SETPALETTEENTRIES',
  'EMR_RESIZEPALETTE', 'EMR_REALIZEPALETTE', 'EMR_EXTFLOODFILL', 'EMR_LINETO',
  'EMR_ARCTO', 'EMR_POLYDRAW', 'EMR_SETARCDIRECTION', 'EMR_SETMITERLIMIT',
  'EMR_BEGINPATH', 'EMR_ENDPATH', 'EMR_CLOSEFIGURE', 'EMR_FILLPATH',
  'EMR_STROKEANDFILLPATH', 'EMR_STROKEPATH', 'EMR_FLATTENPATH', 'EMR_WIDENPATH',
  'EMR_SELECTCLIPPATH', 'EMR_ABORTPATH', 'UnKnown', 'EMR_GDICOMMENT', 'EMR_FILLRGN',
  'EMR_FRAMERGN', 'EMR_INVERTRGN', 'EMR_PAINTRGN', 'EMR_EXTSELECTCLIPRGN',
  'EMR_BITBLT', 'EMR_STRETCHBLT', 'EMR_MASKBLT', 'EMR_PLGBLT', 'EMR_SETDIBITSTODEVICE',
  'EMR_STRETCHDIBITS', 'EMR_EXTCREATEFONTINDIRECTW', 'EMR_EXTTEXTOUTA',
  'EMR_EXTTEXTOUTW', 'EMR_POLYBEZIER16', 'EMR_POLYGON16', 'EMR_POLYLINE16',
  'EMR_POLYBEZIERTO16', 'EMR_POLYLINETO16', 'EMR_POLYPOLYLINE16', 'EMR_POLYPOLYGON16',
  'EMR_POLYDRAW16', 'EMR_CREATEMONOBRUSH', 'EMR_CREATEDIBPATTERNBRUSHPT',
  'EMR_EXTCREATEPEN', 'EMR_POLYTEXTOUTA', 'EMR_POLYTEXTOUTW', 'EMR_SETICMMODE',
  'EMR_CREATECOLORSPACE', 'EMR_SETCOLORSPACE', 'EMR_DELETECOLORSPACE', 'EMR_GLSRECORD',
  'EMR_GLSBOUNDEDRECORD', 'EMR_PIXELFORMAT', 'EMR_DRAWESCAPE', 'EMR_EXTESCAPE',
  'EMR_STARTDOC', 'EMR_SMALLTEXTOUT', 'EMR_FORCEUFIMAPPING', 'EMR_NAMEDESCAPE',
  'EMR_COLORCORRECTPALETTE', 'EMR_SETICMPROFILEA', 'EMR_SETICMPROFILEW',
  'EMR_ALPHABLEND', 'EMR_ALPHADIBBLEND', 'EMR_TRANSPARENTBLT', 'EMR_TRANSPARENTDIB',
  'EMR_GRADIENTFILL', 'EMR_SETLINKEDUFIS', 'EMR_SETTEXTJUSTIFICATION' );

var
  N_MetafEdForm: TN_MetafEdForm;

implementation
uses Clipbrd,
     N_Gra2, N_RVCTF, N_MsgDialF, N_ButtonsF;
{$R *.dfm}

      //*************** File handlers *************************

procedure TN_MetafEdForm.actFileLoadExecute( Sender: TObject );
// Load metafile from file
begin
  StatusBar.SimpleText := '';
  CurMetafile.Free;
  CurMetafile := TMetafile.Create();
  CurMetafile.LoadFromFile( frFileName.mbFileName.Text );
  ShowAttribs();
  StatusBar.SimpleText := 'File  "' +
                 ExtractFileName(frFileName.mbFileName.Text) + '"  Loaded OK';
end; // procedure TN_MetafEdForm.actFileLoadExecute

procedure TN_MetafEdForm.actFileSaveExecute( Sender: TObject );
// Save metafile to file
begin
  StatusBar.SimpleText := '';
  if not N_ConfirmOverwriteDlg( frFileName.mbFileName.Text ) then Exit;
  CurMetafile.SaveToFile( frFileName.mbFileName.Text );
  StatusBar.SimpleText := 'File  "' +
                ExtractFileName(frFileName.mbFileName.Text) + '"  Saved OK';
end;

      //*************** Edit handlers *************************

procedure TN_MetafEdForm.actEditCopyExecute( Sender: TObject );
// Copy CurMetafile to Clipboard
begin
  StatusBar.SimpleText := '';
  N_CopyMetafileToClipBoard( CurMetafile );
  StatusBar.SimpleText := 'Copied OK';
end; // procedure TN_MetafEdForm.actEditCopyExecute

procedure TN_MetafEdForm.actEditPasteExecute( Sender: TObject );
// Paste CurMetafile from Clipboard
begin
  if Clipboard.HasFormat( CF_ENHMETAFILE ) then
  begin
    if CurMetafile = nil then CurMetafile := TMetafile.Create;
    CurMetafile.Assign( Clipboard );
    ShowAttribs();
    StatusBar.SimpleText := 'Pasted OK';
  end else
    StatusBar.SimpleText := 'No Metafile in Clipboard';
end; // procedure TN_MetafEdForm.actEditPasteExecute

      //*************** View handlers *************************

procedure TN_MetafEdForm.actViewMetafileExecute( Sender: TObject );
// View CurMetafile
var
  R3Form: TN_RastVCTForm;
  HalfPixX, HalfPixY: double;
begin
  StatusBar.SimpleText := '';
  if CurMetafile = nil then
  begin
    StatusBar.SimpleText := 'No Metafile selected!';
    Exit;
  end;

  R3Form := N_CreateRastVCTForm( Self );
  with R3Form do
  begin
    Left := 0;
    Show();
  end;

  with R3Form.RFrame do
  begin
  
    with CurMetafile do
    begin
    HalfPixX := (0.5 - 1e-6)*Width  / OCanv.CCRSize.X;
    HalfPixY := (0.5 - 1e-6)*Height / OCanv.CCRSize.Y;
//      OCanvMaxURect := FRect( -HalfPixX, -HalfPixY, Width-HalfPixX, Height-HalfPixY );
    N_d := HalfPixX; N_d := HalfPixY;
    end;
//    OCanv.SetIncCoefsAndUCRect( OCanvMaxURect, IRect( OCanv.CCRSize ) );
//!!    VRObjType := vtMetafile;
//!!    VRObj := CurMetafile;
  end;
//  R3Form.RFrame.RBufIsNotReady := False;
  R3Form.RFrame.RedrawAll();
  StatusBar.SimpleText := 'OK';
end; // procedure TN_MetafEdForm.actViewMetafileExecute

procedure TN_MetafEdForm.actViewXMLExecute( Sender: TObject );
// View XML file (as plain text)
begin
//
end; // procedure TN_MetafEdForm.actViewXMLExecute

      //*************** Import handlers *************************

procedure TN_MetafEdForm.actImpXMLLinesExecute( Sender: TObject );
// Import XML lines (in pixel coords) to current metafile
begin
//
end; // procedure TN_MetafEdForm.actImpXMLLinesExecute

      //*************** Export handlers *************************

procedure TN_MetafEdForm.actExpXMLLinesExecute( Sender: TObject );
// Export current metafile to XML lines with pixel coords
begin
{
var
  NPoints: integer;
//Hbmp, HOldbmp: HBitmap;
  Hbmp, HOldbmp: LongWord;
  PixPtr: Pointer;
  VertCoords: TN_IPArray;
  VertTypes: TN_BArray;
  MemDC: HDC;
  PixRect: TRect;
begin
  MemDC := CreateCompatibleDC( 0 );
  Hbmp := 0;
  N_CreateDIBSection( Hbmp, 100, 100, pf1bit, PixPtr );
  HOldbmp := SelectObject( MemDC, Hbmp );
  PixRect := Rect(0,0,100,100);
  BeginPath( MemDC );
  PlayEnhMetafile( MemDC, CurMetafile.Handle, PixRect );
  EndPath( MemDC );
  NPoints := GetPath( MemDC, VertCoords, VertTypes, 0 );
  SetLength( VertCoords, NPoints );
  SetLength( VertTypes, NPoints );
  GetPath( MemDC, VertCoords, VertTypes, NPoints );

  DeleteDC( MemDC );
}
end; // procedure TN_MetafEdForm.actExpXMLLinesExecute

procedure TN_MetafEdForm.actExpTxtDumpExecute( Sender: TObject );
// Dump all EMF Records to Text file
var
  FName: string;
  MF: TN_MetaFile;
  RPtr: TN_BytesPtr;
  i, RType: integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  MF := TN_MetaFile.Create;
  FName := frFileName.GetFileName();
  MF.GetFromFile( FName );
  SL.Add( '  Input File - ' + FName );
  SL.Add( '' );

  with MF.PMFHeader^ do
  begin
    SL.Add( 'rclBounds: ' + N_RectToStr( rclBounds ) );
    SL.Add( 'rclFrame:  ' + N_RectToStr( rclFrame ) );
    SL.Add( 'nRecords:  ' + IntToStr( nRecords ) );
    SL.Add( 'nHandles:  ' + IntToStr( nHandles ) );
    SL.Add( 'szlDevice: ' + N_PointToStr( IPoint(szlDevice) ) );
    SL.Add( 'szlMillim: ' + N_PointToStr( IPoint(szlMillimeters) ) );
    SL.Add( '' );
  end;

  i := 2;
  while True do // loop along Metafile records
  begin
    MF.GetNextRecord( RPtr, RType );
    if RType = -1 then Break;
    SL.Add( Format( '%.3d) RType=%d %s (%d)', [i, RType, N_EMRNames[RType], PEMR(MF.CRPtr)^.nSize ] ) );
    case RType of
    EMR_EXTTEXTOUTW: with PEMRExtTextOut(MF.PMFHeader)^.emrtext do
    begin
//      SL.Add( Format( '   nchars=%d, x=%d, y=%d, offs=%d', [nChars, ptlReference.X, ptlReference.Y, offString] ) );
      SL.Add( Format( '   nchars=%u', [PEMRExtTextOut(MF.PMFHeader)^.emrtext.nChars] ) );

    end;

    end; // case RType of
    Inc(i);
  end; // while True do // loop along Metafile records

  MF.Free;
  FName := ChangeFileExt( FName, '.txt' );
  SL.SaveToFile( FName );
  StatusBar.SimpleText := 'EMF Dump saved to ' + FName;
  SL.Free;
end; // procedure TN_MetafEdForm.actExpTxtDumpExecute

      //*************** Debug handlers *************************

procedure TN_MetafEdForm.aDebCreateATest1EMFExecute( Sender: TObject );
// create test metafiles ATest1.emf in current dir
var
  hmfDC, hmf: HDC;
  SizeRect: TRect;
  L1: TN_IPArray;
  hres: boolean;
  BmpInfo: TBitMapInfo;
//  PixPtr: Pointer;
//  PMessage: TN_BytesPtr;
begin
  FillChar( BmpInfo, Sizeof(BmpInfo), 0 );
  with BmpInfo.bmiHeader do
  begin
    biSize := Sizeof(TBitmapInfoHeader);
    biWidth  := 1;
    biHeight := 1;
    biPlanes := 1;
    biBitCount := 1;
    biCompression := BI_RGB;
    biXPelsPerMeter := 3800;
    biYPelsPerMeter := 3800;
  end;

//  hmemdc := CreateCompatibleDC( 0 );
//  hDibSec := Windows.CreateDIBSection( 0, Bmpinfo, DIB_RGB_COLORS, PixPtr, 0, 0 );
//  Assert( hDibSec <> 0, 'Err!' );
//  hbmpold := SelectObject( hmemdc, hDibSec );
//  Assert( hbmpold <> 0, 'Bad Handle' );

  SizeRect := Rect(0,0,10000,10000); // in 0.01 mm units
  hmfDC := CreateEnhMetaFile( 0, 'ATest1.emf', @SizeRect, nil );
  Assert( hmfDC <> 0, 'Err!' );
// N_WarnByMessage( SysErrorMessage( N_i ) );

  SelectObject( hmfDC, CreateSolidBrush( $FFFF ) );

  SetLength( L1, 3 );
  L1[0] := Point(   0,   48 );
  L1[1] := Point(   0,    0 );
  L1[2] := Point(  96,    0 );
  Polyline( hmfDC, (@L1[0])^, 3 );
  L1[0] := Point(   2,   24 );
  L1[1] := Point(   2,    2 );
  L1[2] := Point(  24,    2 );
  Polyline( hmfDC, (@L1[0])^, 3 );
  L1[0] := Point(   4,   96 );
  L1[1] := Point(   4,    4 );
  L1[2] := Point(  96,    4 );

  Polyline( hmfDC, (@L1[0])^, 3 );

  hmf := CloseEnhMetaFile( hmfDC );
  Assert( hmf <> 0, 'Err!' );
  hres := DeleteEnhMetaFile( hmf );
  Assert( hres, 'Err!' );
  StatusBar.SimpleText := 'File ATest1.emf Created Ok';
end; // procedure TN_MetafEdForm.aDebCreateATest1EMFExecute

procedure TN_MetafEdForm.aDebCreateATest2EMFExecute( Sender: TObject );
// create test metafiles ATest2.emf in current dir
var
  hmfDC, hmf, hPen: HDC;
  BRes: boolean;
  SizeRect: TRect;
  L1: TN_IPArray;
  RgnHandle: HRgn;
begin
  SizeRect := Rect(0,0,10000,10000); // in 0.01 mm units
  hmfDC := CreateEnhMetaFile( 0, 'ATest2.emf', @SizeRect, nil );
  Assert( hmfDC <> 0, 'Err!' );
// N_WarnByMessage( SysErrorMessage( N_i ) );

  hPen := CreatePen( PS_SOLID, 1, $FF00 );
  N_i := SelectObject( hmfDC, hPen );

  SetLength( L1, 3 );

  L1[0] := Point(   0,   48 );
  L1[1] := Point(   0,    0 );
  L1[2] := Point(  96,    0 );
  Polyline( hmfDC, (@L1[0])^, 3 );

  L1[0] := Point(   2,   24 );
  L1[1] := Point(   2,    2 );
  L1[2] := Point(  24,    2 );
  Polyline( hmfDC, (@L1[0])^, 3 );

  RgnHandle := CreateRectRgn( 0, 0, 5000, 5000 );
  N_i := SelectClipRgn( hmfDC, RgnHandle );
  N_i := SelectClipRgn( hmfDC, RgnHandle );
  N_i := SelectClipRgn( hmfDC, RgnHandle );

  L1[0] := Point(   4,   96 );
  L1[1] := Point(   4,    4 );
  L1[2] := Point(  98,    4 );
  Polyline( hmfDC, (@L1[0])^, 3 );

  hmf := CloseEnhMetaFile( hmfDC );
  Assert( hmf <> 0, 'Err!' );
  BRes := DeleteEnhMetaFile( hmf );
  Assert( BRes, 'Err!' );
  StatusBar.SimpleText := 'File ATest2.emf Created Ok';
end; // procedure TN_MetafEdForm.aDebCreateATest2EMFExecute


      //*************** Other handlers *************************

procedure TN_MetafEdForm.FormClose( Sender: TObject;
                                     var Action: TCloseAction );
// On Close event handler - deleete all created objects
begin
  Inherited;
  CurMetafile.Free;
  N_MetafEdForm := nil;
end; // procedure TN_MetafEdForm.FormClose

//***********************************  TN_MetafEdForm.ShowAttribs  ******
// Show metafile Attribs
//
procedure TN_MetafEdForm.ShowAttribs();
var
  MFHeaderSize: integer;
  MFHeader: ENHMETAHEADER;
begin
  MFHeaderSize := GetEnhMetaFileHeader( CurMetafile.Handle, 0, nil );
  Assert( MFHeaderSize > 0, 'Metafile Header Error' );
  GetEnhMetaFileHeader( CurMetafile.Handle, Sizeof(MFHeader), @MFHeader );

  with MFHeader do
  begin
{
    k, DX, DY: integer;
    DX := rclFrame.Right - rclFrame.Left;
    k := szlMillimeters.cx * 100;
    DX := (DX*szlDevice.cx + k div 2) div k;
    DY := rclFrame.Bottom - rclFrame.Top;
    k := szlMillimeters.cy * 100;
    DY := (DY*szlDevice.cy + k div 2) div k;
    N_i1 := CurMetafile.Width;
    N_i2 := CurMetafile.Height;
    edSizeInPix.Text := Format( ' %d %d', [DX, DY] );
}
    with CurMetafile do
      edSizeInPix.Text := Format( 'X:%d, Y:%d', [Width, Height] );

    edSizeInKB.Text  := Format( ' %.1f',  [nBytes/1024] );
    edNRecords.Text  := Format( ' %d',    [nRecords] );
  end; // with MFHeader do
end; // procedure TN_MetafEdForm.ShowAttribs

//***********************************  TN_MetafEdForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_MetafEdForm.CurStateToMemIni();
begin
  Inherited;
    //***** Attribs
  N_ComboBoxToMemIni( 'MetafEdF_frFileName',  frFileName.mbFileName );

end; // end of procedure TN_MetafEdForm.CurStateToMemIni

//***********************************  TN_MetafEdForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_MetafEdForm.MemIniToCurState();
begin
  Inherited;
    //***** Attribs
  N_MemIniToComboBox( 'MetafEdF_frFileName', frFileName.mbFileName );

end; // end of procedure TN_MetafEdForm.MemIniToCurState

//****************** Global procedures **********************

//*********************************************  N_GetMetafEdForm  ******
// create new instance of N_MetafEdForm
//
function N_GetMetafEdForm( AOwner: TN_BaseForm ): TN_MetafEdForm;
begin
  if N_MetafEdForm <> nil then // already opened
  begin
    Result := N_MetafEdForm;
    Result.SetFocus;
    Exit;
  end;

  N_MetafEdForm := TN_MetafEdForm.Create( Application );
  Result := N_MetafEdForm;
  with Result do
  begin
    BaseFormInit( AOwner );
  end;
end; // end of function N_GetMetafEdForm

end.
