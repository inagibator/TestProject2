unit K_GifFile;
// GIF format control Classes and routines

interface

uses
  WinProcs,        { Imports RGB }
  WinTypes,        { Imports TBitmapInfoHeader }
  Classes,         { Imports TList }
  Controls,        { Imports Cursor values }
  Dialogs,         { Imports ShowMessage }
  Forms,           { Imports Screen }
  Graphics,        { Imports TColor }
  SysUtils,        { Imports UpperCase }
  Types;


// Описания вспомогательных классов

type
  TColorItem = packed record      { one item a a color table }
    Red: byte;
    Green: byte;
    Blue: byte;
  end; { TColorItem }

  RColorTable = packed record
    Count: Integer;                      { Actual number of colors }
    Colors: packed array[0..255] of TColorItem;  { the color table }
  end; { TColorTable }

  RFastColorTable = record
    Colors: array[0..255] of TColor;
  end; { RFastColorTable }

  TColorTable = class(TObject)
  private
    function  GetCount: Integer;
    procedure SetCount(NewValue: Integer);
  public
    CT: RColorTable;
    FCT: RFastColorTable;
    constructor Create(NColors: Word);
    procedure AdjustColorCount;
    procedure CompactColors;
    function  GetColor(Index: Byte): TColor;
    function  GetColorIndex(Color: TColor): Integer;

    property Count: Integer read GetCount write SetCount;
  end; { TColorTable }

const
  CR    = #13;     { carriage return character }
  LF    = #10;     { linefeed character }
  Space = #32;     { space character }
  Tab   = #9;      { Tab character }
  CRLF  = CR + LF;

type
   TBigByteArray = class(TObject)
   private
      FAddress: Pointer;
      FCount: Longint;
      function  GetVal(index: Longint): Byte;
      procedure SetVal(index: Longint; value: Byte);
   public
      constructor Create(N: Longint);
      constructor Dim(N: Longint);
      constructor ReadBinary(var F: File);
      destructor  Destroy; override;

      procedure Append(appendarray: TBigByteArray);
      procedure Clear;
      function  Copy: TBigByteArray;
      function  EqualTo(OtherArray: TBigByteArray): Boolean;
      procedure FillWith(Value: Byte);
      procedure FindMax(var i: Longint; var max: Byte);
      procedure FindMinMax(var min, max: Byte);
      {procedure GetMeanAndSigma(var Mean, sd: Single);}
      function  Max: Byte;
      function  Min: Byte;
      {procedure MultiplyWith(Factor: Single);}
      {procedure ReDim(NewSize: Longint);}
      {procedure SortAscending;}
      procedure Subtract(other: TBigByteArray);
      {function  Sum: Single;}
      procedure WriteBinary( var F: File );

      property Address: Pointer read FAddress;
      property Count: Longint read FCount;
      property Value[i: Longint]: Byte read GetVal write SetVal; default;
   end; { TBigByteArray }

   TByteArray2D = class(TObject)
   { Not TBigByteArray as ancestor because that would make it impossible
   to declare a new default array property. It also hides the Count property,
   so it is more difficult to mistakenly use it as a TBigByteArray }
   private
      Values: TBigByteArray;
      FCount1, FCount2: Longint;
      function  GetTotalCount: Longint;
      function  GetVal(i1, i2: Longint): Byte;
      procedure SetVal(i1, i2: Longint; value: Byte);
   public
      constructor Create(N1, N2: Longint);
      destructor  Destroy; override;
      constructor Dim(N1, N2: Longint);
      constructor ReadBinary(var F: File);

      procedure Clear;
      function  Copy: TByteArray2D;
      {procedure CopyRow(RowNo: Longint; var Row: TBigByteArray);}
      function  CopyRow(RowNo: Longint): TBigByteArray;
      procedure FindMax(var i1, i2: Longint; var max: Byte);
      procedure FindMinMax(var min, max: Byte);
      function  Max: Byte;
      function  Min: Byte;
      procedure MirrorX;
      procedure MirrorY;
      {procedure MultiplyWith( Factor: Single);}
      procedure SetRow(ColNo: Integer; RowValues: TBigByteArray);
      {function  Sum: Single;}
      function  SumColumns: TBigByteArray;
      procedure Transpose;
      procedure WriteBinary( var F: File );

      property TotalCount: Longint read GetTotalCount;
      property Count1: Longint read FCount1;
      property Count2: Longint read FCount2;
      property Value[i, j: Longint]: Byte read GetVal write SetVal; default;
   end; { TByteArray2D }

procedure ReDim(var AnArray: TBigByteArray; NewSize: Longint);

// Описание класса GIFFile

const
  { image descriptor bit masks }
  idLocalColorTable    = $80;    { set if a local color table follows }
  idInterlaced         = $40;    { set if image is interlaced }
  idSort               = $20;    { set if color table is sorted }
  idReserved           = $0C;    { reserved - must be set to $00 }
  idColorTableSize     = $07;    { size of color table as above }
  ExtensionIntroducer: Byte = Ord('!');
  ImageSeparator: Byte = Ord(',');
  Trailer: Byte        = Ord(';'); { indicates the end of the GIF data stream }

  { logical screen descriptor packed field masks }
  lsdGlobalColorTable = $80;  { set if global color table follows L.S.D. }
  lsdColorResolution = $70;   { Color resolution - 3 bits }
  lsdSort = $08;              { set if global color table is sorted - 1 bit }
  lsdColorTableSize = $07;    { size of global color table - 3 bits }
                              { Actual size = 2^value+1    - value is 3 bits }

  CodeTableSize = 4096;

  CodeMask: array[0..12] of Word = (  { bit masks for use with Next code }
  0, $0001, $0003, $0007, $000F,
     $001F, $003F, $007F, $00FF,
     $01FF, $03FF, $07FF, $0FFF);

type
  TGraphicFileType = (BMP, GIF, unknown);
  { Who knows JPG and others will be available some day }

  TDecodeRecord = record
    BitsLeft     : Integer;   { bits left in byte }
    CurrByte     : Longint;   { the current byte }
    CurrentY     : Integer;   { current screen locations }
    InterlacePass: Integer;   { interlace pass number }

    LZWCodeSize  : Byte;      { minimum size of the LZW codes in bits }
    CurrCodeSize : Integer;   { Current size of code in bits }
    ClearCode    : Integer;   { Clear code value }
    EndingCode   : Integer;   { ending code value }
    HighCode     : Word;      { highest code that does not require decoding }
  end; { TDecodeRecord }

  EGifException = class(Exception)
  end;

  TGifHeader = packed record
    Signature: array[0..2] of char; { contains 'GIF' }
    Version: array[0..2] of char;   { '87a' or '89a' }
  end; { TGifHeader }

  TLogicalScreenDescriptor = packed record
    ScreenWidth: word;              { logical screen width }
    ScreenHeight: word;             { logical screen height }
    PackedFields: byte;             { packed fields - see below }
    BackGroundColorIndex: byte;     { index to global color table }
    AspectRatio: byte;              { actual ratio = (AspectRatio + 15) / 64 }
  end; { TLogicalScreenDescriptor }

  TImageDescriptor = packed record
    {Separator: byte;      { fixed value of ImageSeparator }
    { I (RPS) think it's awkward to consider the separator char a
      part of the Image Descriptor, therefore commented it out }
    ImageLeftPos: word;   { Column in pixels in respect to left edge of logical screen }
    ImageTopPos: word;    { row in pixels in respect to top of logical screen }
    ImageWidth: word;     { width of image in pixels }
    ImageHeight: word;    { height of image in pixels }
    PackedFields: byte;   { see below }
  end; { TImageDescriptor }

  // Дополнительные блоки GIF-файла

  TExtensionType = (etGCE, etPTE, etAPPE, etCE);

  TDisposalMethod = (dmNone, dmNotDispose, dmRestoreBackgroundColor,
                     dmRestorePrevious, dm4, dm5, dm6, dm7);

  TGraphicControlExtension = packed record
    {Introducer: byte;}      { always $21 }
    {ExtensionLabel: byte;}  { always $F9 }
    BlockSize: byte;         { should be 4 }
    PackedFields: Byte;
    DelayTime: Word;         { in centiseconds }
    TransparentColorIndex: Byte;
    Terminator: Byte;
  end; { TGraphicControlExtension }

  TPlainTextExtension = packed record
    {Introducer: byte;}      { always $21 }
    {ExtensionLabel: byte;}  { always $01 }
    BlockSize: byte;         { should be 12 }
    Left, Top, Width, Height: Word;
    CellWidth, CellHeight: Byte;
    TextFGColorIndex,
    TextBGColorIndex: Byte;
    PlainTextData: TStringList;
  end; { TPlainTextExtension }

  TApplicationExtension = packed record
    {Introducer: byte;}      { always $21 }
    {ExtensionLabel: byte;}  { always $FF }
    BlockSize: Byte;         { should be 11 }
    ApplicationIdentifier: array[1..8] of Byte;
    AppAuthenticationCode: array[1..3] of Byte;
    AppData: TStringList;
  end; { TApplicationExtension }

  TExtensionRecord = record
    case ExtensionType: TExtensionType of
      etGCE: (GCE: TGraphicControlExtension);
      etPTE: (PTE: TPlainTextExtension);
      etAPPE: (APPE: TApplicationExtension);
      etCE: (Comment: TStringList);
  end; { TExtensionRecord }

  TExtension = class
    ExtRec: TExtensionRecord;
    destructor Destroy; override;
  end; { TExtension }
  { declared as class to make storage in a TList possible }

  TExtensionList = class(TList)
    destructor Destroy; override;
  end; { TExtensionList }

  TByteBuffer = class
  private
    FTotalSize: Longint;
    SL: TStringList;
    CurrString: String;
    CurrLength: Integer;
    CurrStringNo: Integer;
    NextByte: Integer;
    function GetString(Index: Longint): String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddByte(ByteVal: Byte);
    procedure AddString(NewString: String);
    procedure Clear;
    procedure DeleteLastByte;
    procedure Finish;
    function  FirstByte: Byte;
    function  GetNextByte: Byte;
    function  LastByte: Byte;
    procedure Reset;
    function  StringCount: Integer;

    property  Strings[Index: Longint]: String read GetString;
    property  TotalSize: Longint read FTotalSize;
  end; { TByteBuffer }

  TCodeTable = class
    Suffix,
    Prefix: Array[1..CodeTableSize] of Word;
    CodeSize: Byte; { number of bits necessary to encode }
    TableFull: Boolean;
    FirstSlot,
    NextSlot: Word; { index where next string will be stored }
    procedure AddEntry(NewPrefix, NewSuffix: Integer);
    procedure Clear(StartingCodeSize: Byte);
    function  IsInTable(PixelString: TByteBuffer;
                        var PrevFoundIndex,
                            FoundIndex: Integer): Boolean;
  end; { TCodeTable }

  TEncodedBytes = class
    Value: TByteBuffer;   { contains the encoded bytes }
    UsedBits: Byte;
    CurrentByte: Longint; { not byte or even integer, to accommodate 'overflow' }
    constructor Create;
    procedure AppendCode(CodeValue, CodeSize: Integer);
    procedure Finish(EndCode: Word; CodeSize: Byte);
  end; { TEncodedBytes }

function CheckType(Filename: String): TGraphicFileType;
{ Finds out whether the file is a gif or bmp (or unknown) file }

function NextLineNo(LineNo, ImageHeight: Integer;
                    var InterlacePass: Integer): Integer;
{ Returns the next line number for an interlaced image }

type
  TGifFile = class;
  TGifSubImage = class(TObject)
  private
    LZWCodeSize: Byte;
    CompressedRasterData: TByteBuffer;

    FGifFile: TGifFile;
    FBitmap: TBitmap;
    FDisposalMethod: TDisposalMethod;
    FExtensions: TExtensionList;
    FIsTransparent: Boolean;
    { property acess methods }
    function  GetAnimateInterval: Word;
    function  GetBGColor: TColor;
    procedure SetAnimateInterval(NewValue: Word);
    procedure SetExtensions(NewValue: TExtensionList);
    { other private methods }
    procedure DecodeStatusbyte;
    procedure ReadImageDescriptor(Stream: TStream);
    procedure ReadLocalColorMap(Stream: TStream);
    procedure ReadRasterData(Stream: TStream);
    procedure DecodeRasterData;
    procedure LoadFromStream(Stream: TStream);

    procedure WriteImageDescriptor(Stream: TStream);
    procedure WriteLocalColorMap(Stream: TStream);
    procedure EncodeRasterdata;
    procedure WriteRasterData(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  public
    ImageDescriptor: TImageDescriptor;
    Interlaced: Boolean;
    HasLocalColorMap: Boolean;
    BitsPerPixel: Byte;
    Pixels: TByteArray2D;
    LocalColorMap: TColorTable;

    constructor Create(NColors: Word; Parent: TGifFile);
    constructor CreateEmpty;
    destructor Destroy; override;

    function  AsBitmap: TBitmap;
    procedure EncodeStatusbyte;
    function  TransparentColor: TColor;
    function  TransparentColorIndex: Integer;

    property  AnimateInterval: Word
              read GetAnimateInterval
              write SetAnimateInterval;
    property  BackgroundColor: TColor
              read GetBGColor;
    property  Extensions: TExtensionList
              read FExtensions
              write SetExtensions;
    property  DisposalMethod: TDisposalMethod
              read FDisposalMethod;
    property  IsTransparent: Boolean
              read FIsTransparent;
  end; { TGifSubImage }

  TGifFile = class(TObject)
  private
    procedure DecodeStatusByte;
    procedure ReadExtensionBlocks(Stream: TStream;
                                  var SeparatorChar: Char;
                                  var Extensions: TExtensionList);
    procedure ReadSignature(Stream: TStream);
    procedure ReadScreenDescriptor(Stream: TStream);
    procedure ReadGlobalColorMap(Stream: TStream);

    procedure EncodeGifFile;
    procedure EncodeStatusByte;
    procedure WriteSignature(Stream: TStream);
    procedure WriteScreenDescriptor(Stream: TStream);
    procedure WriteGlobalColorMap(Stream: TStream);
  public
    Header: TGifHeader;
    ScreenDescriptor: TLogicalScreenDescriptor;
    HasGlobalColorMap: Boolean;
    GlobalColorMap: TColorTable;
    BitsPerPixel: Byte;
    SubImages: TList;
    constructor Create;
    destructor Destroy; override;
    procedure AddBitmap(Bitmap: TBitmap);
    function  AsBitmap: TBitmap;
    function  GetSubImage(Index: Integer): TGifSubImage;
    procedure LoadFromFile(filename: String);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(filename: String);
    procedure SaveToStream(Stream: TStream);
  end; { TGifFile }

type
  TGifBitmap = class(TBitmap)
  public
    procedure LoadFromStream(Stream: TStream); override;
  end; { TGifBitmap }


procedure DrawTransparent(DestCanvas: TCanvas; X, Y: smallint;
                          SrcBitmap: TBitmap; AColor: TColor);
{ Draws SrcBitmap on the DestCanvas, with AColor as transparent color.
Subroutine was posted by Leif L. in Borland's Delphi.Graphics newsgroup
and is thankfully used }

procedure GrabScreen(const SourceRect: TRect; Bitmap: TBitmap);
{ Captures what's on the screen in the SourceRect rectangle into
the Bitmap bitmap.
Posted in Borland's Delphi.Graphics newsgroup by Nick Hodges;
he refers to Mike Scott as the creator }

//const // I changed Const by var. Is it OK?? (Nikita, 04.06.2002)
var
  DrawingTransparent: Boolean = False;


implementation
uses
  N_Types{, N_Lib1};
(***** methods of TCodeTable *****)

procedure TCodeTable.Clear(StartingCodeSize: Byte);
var i: Integer;
begin { TCodeTable.Clear }
  for i := 1 to CodeTableSize
  do begin
    Suffix[i] := 0;
    Prefix[i] := 0;
  end;
  CodeSize := StartingCodeSize;
  FirstSlot := 1 shl (CodeSize-1) + 2;
  NextSlot := FirstSlot;
  TableFull := False;
end;  { TCodeTable.Clear }

procedure TCodeTable.AddEntry(NewPrefix, NewSuffix: Integer);
begin { TCodeTable.AddEntry }
  Prefix[NextSlot] := NewPrefix;
  Suffix[NextSlot] := NewSuffix;
  Inc(NextSlot);
  if NextSlot = 4096
  then TableFull := True
  else
    if NextSlot > (1 shl CodeSize)
    then Inc(CodeSize)
end;  { TCodeTable.AddEntry }

function TCodeTable.IsInTable(PixelString: TByteBuffer;
                              var PrevFoundIndex,
                                  FoundIndex: Integer): Boolean;
var
  Found: Boolean;
  Pixel: Byte;
  TryIndex: Integer;
begin { TCodeTable.IsInTable }
  if PrevFoundIndex < FirstSlot
  then TryIndex := FirstSlot
  else TryIndex := PrevFoundIndex + 1;
  Pixel := PixelString.LastByte;
  Found := False;
  while not Found
        and (TryIndex < NextSlot)
  do begin
    Found := (Prefix[TryIndex] = PrevFoundIndex) and
             (Suffix[TryIndex] = Pixel);
    Inc(TryIndex)
  end;
  if Found
  then begin
    Dec(TryIndex);
    PrevFoundIndex := TryIndex;
    FoundIndex := TryIndex;
  end;
  Result := Found;
end;  { TCodeTable.IsInTable }

(***** end of methods of TCodeTable *****)
(***** TExtension and TExtensionList *****)

destructor TExtension.Destroy;
begin { TExtension.Destroy }
  case ExtRec.ExtensionType of
    etPTE:  ExtRec.PTE.PlainTextData.Free;
    etAPPE: ExtRec.APPE.AppData.Free;
    etCE:   ExtRec.Comment.Free;
  end;
  inherited Destroy;
end;  { TExtension.Destroy }

destructor TExtensionList.Destroy;
var
  ExtNo: Integer;
  Ext: TExtension;
begin { TExtensionList.Destroy }
  for ExtNo := Count downto 1
  do begin
    Ext := Self[ExtNo-1];
    Remove(Ext);
    Ext.Free;
  end;
  inherited Destroy;
end;  { TExtensionList.Destroy }

(***** end of TExtension and TExtensionList *****)
(***** methods of TByteBuffer *****)

constructor TByteBuffer.Create;
begin { TByteBuffer.Create }
  inherited Create;
  SL := TStringlist.Create;
  CurrString := '';
  CurrLength := 0;
  FTotalSize := 0;
end;  { TByteBuffer.Create }

destructor TByteBuffer.Destroy;
begin { TByteBuffer.Destroy }
  SL.Free;
  inherited Destroy;
end;  { TByteBuffer.Destroy }

procedure TByteBuffer.AddByte(ByteVal: Byte);
begin { TByteBuffer.AddByte }
  if CurrLength = 255
  then begin
    SL.Add(CurrString);
    CurrString := '';
    CurrLength := 0;
  end;
  CurrString := CurrString + Chr(ByteVal);
  Inc(CurrLength);
  Inc(FTotalSize);
end;  { TByteBuffer.AddByte }

procedure TByteBuffer.AddString(NewString: String);
begin { TByteBuffer.AddString }
  SL.Add(NewString);
  FTotalSize := FTotalSize + Length(NewString);
end;  { TByteBuffer.AddString }

procedure TByteBuffer.Clear;
begin { TByteBuffer.Clear }
  SL.Free;
  SL := TStringlist.Create;
  CurrString := '';
  CurrLength := 0;
  FTotalSize := 0;
end;  { TByteBuffer.Clear }

procedure TByteBuffer.DeleteLastByte;
begin { TByteBuffer.DeleteLastByte }
  if CurrLength = 0
  then begin
    CurrString := SL[SL.Count-1];
    SL.Delete(SL.Count-1);
    CurrLength := Length(CurrString);
  end;
  System.Delete(CurrString, CurrLength, 1);
  Dec(CurrLength);
  Dec(FTotalSize);
end;  { TByteBuffer.DeleteLastByte }

procedure TByteBuffer.Finish;
begin { TByteBuffer.AddString }
  SL.Add(CurrString);
end;  { TByteBuffer.AddString }

function TByteBuffer.FirstByte: Byte;
var FirstString: String;
begin { TByteBuffer.FirstByte }
  if SL.Count = 0
  then FirstString := CurrString
  else FirstString := SL[SL.Count-1];
  Result := Ord(FirstString[1]);
end;  { TByteBuffer.FirstByte }

function TByteBuffer.GetString(Index: Longint): String;
begin { TByteBuffer.GetString }
  Result := SL[Index-1];
end;  { TByteBuffer.GetString }

function TByteBuffer.GetNextByte: Byte;
begin { TByteBuffer.GetNextByte }
  if NextByte > Length(CurrString)
  then begin
    Inc(CurrStringNo);
    CurrString := Strings[CurrStringNo];
    NextByte := 1;
  end;
  Result := Ord(CurrString[NextByte]);
  Inc(NextByte);
end;  { TByteBuffer.GetNextByte }

function TByteBuffer.LastByte: Byte;
begin { TByteBuffer.LastByte }
  Result := Ord(CurrString[Length(CurrString)]);
end;  { TByteBuffer.LastByte }

procedure TByteBuffer.Reset;
begin { TByteBuffer.Reset }
  CurrStringNo := 1;
  CurrString := Strings[1];
  NextByte := 1;
end;  { TByteBuffer.Reset }

function TByteBuffer.StringCount: Integer;
begin { TByteBuffer.StringCount }
  Result := SL.Count;
end;  { TByteBuffer.StringCount }

(***** methods of TEncodedBytes *****)

constructor TEncodedBytes.Create;
begin { TEncodedBytes.Create }
  inherited Create;
  CurrentByte := 0;
  UsedBits := 0;
  Value := TByteBuffer.Create;
end;  { TEncodedBytes.Create }

procedure TEncodedBytes.AppendCode(CodeValue, CodeSize: Integer);
{ Adds the compression code to the bit stream }
var NewByte: Longint;
begin { TEncodedBytes.AppendCode }
  CurrentByte := CurrentByte + (Longint(CodeValue) shl UsedBits);
  UsedBits := UsedBits+CodeSize;
  while UsedBits >= 8
  do begin
    NewByte := CurrentByte shr 8;
    CurrentByte := CurrentByte and $ff;
    Value.AddByte(CurrentByte);
    CurrentByte := NewByte;
    UsedBits := UsedBits - 8;
  end
end;  { TEncodedBytes.AppendCode }

procedure TEncodedBytes.Finish(EndCode: Word; CodeSize: Byte);
begin { TEncodedBytes.Finish }
  AppendCode(EndCode, CodeSize);
  if UsedBits <> 0
  then Value.AddByte(CurrentByte);
  Value.Finish;
end;  { TEncodedBytes.Finish }

(***** end of methods of TEncodedBytes *****)

function CheckType(Filename: String): TGraphicFileType;
{ Finds out whether the file is a gif or bmp (or unknown) file }
var
  GraphicFile: File;
  Ext, TestStr: String; n: Integer;
begin { CheckType }
  Ext := ExtractFileExt(Filename);
  AssignFile(GraphicFile, Filename);
  Reset(GraphicFile, 1);
  try
    if UpperCase(Ext) = '.BMP'
    then begin
{$ifdef ver80}
      TestStr[0] := Chr(2);
{$else}
      SetLength(TestStr, 2);
{$endif ver80}
      BlockRead(GraphicFile, TestStr[1], 2);
      if UpperCase(TestStr) = 'BM'
      then Result := BMP
      else Result := unknown
    end
    else if UpperCase(Ext) = '.GIF'
    then begin
{$ifdef ver80}
      TestStr[0] := Chr(3);
{$else}
      SetLength(TestStr, 3);
{$endif ver80}
      BlockRead(GraphicFile, TestStr[1], 3, n);
      if UpperCase(TestStr) = 'GIF'
      then Result := GIF
      else Result := unknown
    end
    else Result := unknown;
  finally
    CloseFile(GraphicFile);
  end;
end;  { CheckType }

function NextLineNo(LineNo, ImageHeight: Integer;
                    var InterlacePass: Integer): Integer;
{ Interlace support }
begin { NextLineNo }
  Result := LineNo + 8;  //** skip warning line
  case InterlacePass of
//**    1: Result := LineNo + 8;
//**    2: Result := LineNo + 8;
    3: Result := LineNo + 4;
    4: Result := LineNo + 2;
  end;
  if Result >= ImageHeight then
  begin
    Inc(InterLacePass);
    case InterLacePass of
      2: Result := 4;
      3: Result := 2;
      4: Result := 1;
    end;
  end;
end; { NextLineNo }

procedure DrawTransparent(DestCanvas: TCanvas; X, Y: smallint;
                          SrcBitmap: TBitmap; AColor: TColor);
{ Draws SrcBitmap on the DestCanvas, with AColor as transparent color.
Subroutine was posted by Leif L. in Borland's Delphi.Graphics newsgroup
and is thankfully used }
var
  ANDBitmap, ORBitmap: TBitmap;
  CM: TCopyMode;
  Src: TRect;
begin { DrawTransparent }
  DrawingTransparent := True;
  ANDBitmap := nil;
  ORBitmap := nil;
  try
    ANDBitmap := TBitmap.Create;
    ORBitmap := TBitmap.Create;
    Src  := Bounds(0, 0, SrcBitmap.Width, SrcBitmap.Height);
    with ORBitmap
    do begin
      Width := SrcBitmap.Width;
      Height := SrcBitmap.Height;
      Canvas.Brush.Color := clBlack;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.BrushCopy(Src, SrcBitmap, Src, AColor);
    end;
    with ANDBitmap
    do begin
      Width := SrcBitmap.Width;
      Height := SrcBitmap.Height;
      Canvas.Brush.Color := clWhite;
      Canvas.CopyMode := cmSrcInvert;
      Canvas.BrushCopy(Src, SrcBitmap, Src, AColor);
    end;
    with DestCanvas
    do begin
      CM := CopyMode;
      CopyMode := cmSrcAnd;
      Draw(X, Y, ANDBitmap);
      CopyMode := cmSrcPaint;
      Draw(X, Y, ORBitmap);
      CopyMode := CM;
    end;
  finally
    ANDBitmap.Free;
    ORBitmap.Free;
  end;
  DrawingTransparent := False;
end;  { DrawTransparent }

procedure GrabScreen(const SourceRect: TRect; Bitmap: TBitmap);
{ Captures what's on the screen in the SourceRect rectangle into
the bitmap }
var ScreenCanvas: TCanvas ;
begin { GrabScreen }
  ScreenCanvas := TCanvas.Create;
  try
    ScreenCanvas.Handle := GetDC(0);
    try
      Bitmap.Width := SourceRect.Right - SourceRect.Left;
      Bitmap.Height := SourceRect.Bottom - SourceRect.Top;
      Bitmap.Canvas.CopyRect( Rect(0, 0, Bitmap.Width, Bitmap.Height),
                              ScreenCanvas, SourceRect);
    finally
      ReleaseDC( 0, ScreenCanvas.Handle);
      ScreenCanvas.Handle := 0;
    end;
  finally
    ScreenCanvas.Free;
  end;
end;  { GrabScreen }

function PaletteToDIBColorTable(Pal: HPalette;
                 var ColorTable: array of TRGBQuad): Integer;
{ This function was found in the Graphics unit but it is not exported.
  It's modified: ByteSwapColors is not called because a TRGBQuad
  has the same physical layout as TColor }
begin { PaletteToDIBColorTable }
  Result := 0;
  if (Pal = 0) or
     (GetObject(Pal, sizeof(Result), @Result) = 0) or
     (Result = 0)
  then Exit;
  if Result > High(ColorTable)+1
  then Result := High(ColorTable)+1;
  GetPaletteEntries(Pal, 0, Result, ColorTable);
end;  { PaletteToDIBColorTable }

{$ifdef UseScanlines}
procedure BitmapToPixelmatrix8bpp(Bitmap: TBitmap;
                                  var ColorTable: TColorTable;
                                  var Pixels: TByteArray2D);
{ Converts the pixels of a TBitmap into a matrix of pixels (PixelArray)
and constructs the Color table in the same process.
This '8bpp' variant makes use of the ScanLine property of TBitmap
(appl. since Delphi 3.0) AND assumes 1 pixel =1 byte (8 bits per pixel) }
var
  i, j: Integer;
  SL: PByteArray;
  PaletteIndex: Byte;
  PixelValRGBQuad: TRGBQuad;
  PixelVal: TColor absolute PixelValRGBQuad;
  ColorIndex: Integer;
  ColorQuadTable: array[0..255] of TRGBQuad;
begin { BitmapToPixelmatrix8bpp }
  ColorTable.Count := 0;
  PaletteToDIBColorTable(Bitmap.Palette, ColorQuadTable);
  with Bitmap
  do begin
    Pixels := TByteArray2D.Create(Width, Height);
    ShowProgress(0);
    for j := 1 to Height
    do begin
      SL := Bitmap.Scanline[j-1];
      for i := 1 to Width
      do begin
        PaletteIndex := SL[i-1];
        PixelValRGBQuad := ColorQuadTable[PaletteIndex];
        ColorIndex := ColorTable.GetColorIndex(PixelVal);
        if ColorIndex = -1
        then begin
          ColorTable.FCT.Colors[ColorTable.Count] := PixelVal;
          ColorIndex := ColorTable.Count;
          ColorTable.Count := ColorTable.Count + 1; { no check on > 256 yet }
        end;
        Pixels[i, j] := ColorIndex;
      end;
      ShowProgress(j/Height)
    end;
  end; { with }
  ColorTable.AdjustColorCount;
  ColorTable.CompactColors;
end;  { BitmapToPixelmatrix8bpp }
{$endif UseScanlines}

procedure BitmapToPixelmatrix(Bitmap: TBitmap;
                              var ColorTable: TColorTable;
                              var Pixels: TByteArray2D);
{ Converts the pixels of a TBitmap into a matrix of pixels (PixelArray)
and constructs the Color table in the same process. }
var
  H: HDC;
  i, j: Integer;
  PixelVal: TColor;
  PrevPixelVal: TColor;
  ColorIndex: Integer;
begin { BitmapToPixelmatrix }
  ColorTable := TColorTable.Create(0);
{$ifdef UseScanlines}
  if Bitmap.PixelFormat in [pf15bit, pf16bit, pf24bit, pf32bit]
  then begin
    Bitmap.PixelFormat := pf8bit;
    ShowMessage('Warning: the bitmap color depth is more than 8 bits per pixel'
      +#13+#10+'This is now converted to 8 bits per pixel');
  end;
  if Bitmap.PixelFormat = pf8bit
  then begin
    BitmapToPixelmatrix8bpp(Bitmap, ColorTable, Pixels);
    Exit;
  end;
{$endif UseScanlines}

//** skip warning - LongWord(...
  LongWord(PrevPixelVal) := $FFFFFFFF;
//  PrevPixelVal := $FFFFFFFF;
  ColorIndex := -1; //** skip warning
  with Bitmap
  do begin
    //ShowProgress(0);
    Pixels := TByteArray2D.Create(Width, Height);
    for j := 1 to Height
    do begin
      H := Bitmap.Canvas.Handle; { within the loop becuase ShowProgress
                                   corrupts this handle }
      for i := 1 to Width
      do begin
        {PixelVal := Canvas.Pixels[i-1, j-1];}
        PixelVal := GetPixel(H, i-1, j-1);
        if PixelVal <> PrevPixelVal
        then begin
          ColorIndex := ColorTable.GetColorIndex(PixelVal);
          if ColorIndex = -1
          then begin
            ColorTable.FCT.Colors[ColorTable.Count] := PixelVal;
            ColorIndex := ColorTable.Count;
            ColorTable.Count := COlorTable.Count + 1; { no check on > 256 yet }
          end;
          PrevPixelVal := PixelVal;
        end;
        Pixels[i, j] := ColorIndex;
      end;
      //ShowProgress(j/Height);
    end;
  end; { with }
  ColorTable.AdjustColorCount;
  ColorTable.CompactColors;
end;  { BitmapToPixelmatrix }


procedure MakeFlat(PixelMatrix: TByteArray2D;
                   Interlaced: Boolean;
                   var PixelArray: TBigByteArray);
{ Convert a matrix of pixels into a linear array of pixels,
taking interlacing into account if necessary }
var
  InterlacePass: Integer;
  i, j, Index, LineNo: Longint;
begin { MakeFlat }
  InterlacePass := 1;
  with PixelMatrix
  do begin
    PixelArray := TBigByteArray.Create(Count1 * Count2);
    Index := 1;
    LineNo := 0;
    for j := 1 to Count2
    do begin
      for i := 1 to Count1
      do begin
        PixelArray[Index] := PixelMatrix[i, LineNo+1];
        Inc(Index);
      end;
      if not Interlaced
      then Inc(LineNo)
      else LineNo := NextLineNo(LineNo, Count2, InterlacePass);
    end;
  end; { with }
end;  { MakeFlat }

procedure WriteColor(Stream: TStream; Color: TColor);
var r, g, b: Byte;
begin { WriteColor }
  r := (Color shr 4) and $FF;
  g := (Color shr 2) and $FF;
  b := Color and $FF;
  Stream.Write(r, 1);
  Stream.Write(g, 1);
  Stream.Write(b, 1);
end;  { WriteColor }

(***** TGifSubImage *****)

constructor TGifSubImage.Create(NColors: Word; Parent: TGifFile);
begin { TGifSubImage.Create }
  inherited Create;
  FGifFile := Parent;
  FExtensions := TExtensionList.Create;
  CompressedRasterData := TByteBuffer.Create;
  Pixels := TByteArray2D.Create(0, 0);
  ImageDescriptor.ImageLeftPos := 0;
  ImageDescriptor.ImageTopPos := 0;
  ImageDescriptor.ImageWidth := 0;
  ImageDescriptor.ImageHeight := 0;
  ImageDescriptor.PackedFields := 0;
  HasLocalColorMap := False;
  Interlaced := False;
  case NColors of
    2: BitsPerPixel := 1;
    4: BitsPerPixel := 2;
    8: BitsPerPixel := 3;
    16: BitsPerPixel := 4;
    32: BitsPerPixel := 5;
    64: BitsPerPixel := 6;
    128: BitsPerPixel := 7;
    256: BitsPerPixel := 8;
    else raise EGifException.Create('Number of colors ('+IntToStr(NColors)+') wrong; must be a power of 2');
  end;  { case }
  LZWCodeSize := BitsPerPixel;
  if LZWCodeSize = 1
  then Inc(LZWCodeSize);
  {TColorTable_Create(LocalColorMap, NColors);}
  LocalColormap := TColorTable.Create(NColors);
  EncodeStatusByte;
end;  { TGifSubImage.Create }

constructor TGifSubImage.CreateEmpty;
begin { TGifSubImage.CreateEmpty }
  inherited Create;
end;  { TGifSubImage.CreateEmpty }

destructor TGifSubImage.Destroy;
begin { TGifSubImage.Destroy }
  LocalColormap.Free;
  Pixels.Free;
  CompressedRasterData.Free;
  FExtensions.Free;
  FBitmap.Free;
  inherited Destroy;
end;  { TGifSubImage.Destroy }

(***** TGifSubImage: end of constructors/desctructors *****)
(***** TGifSubImage: property access methods *****)

function TGifSubImage.GetAnimateInterval: Word;
{ Returns the delay time between this (sub)image and the next one.
In centiseconds! }
var ExtNo: Integer;
    Extension: TExtension;
begin { TGifSubImage.GetAnimateInterval }
  if Extensions.Count = 0
  then Result := 0
  else begin
    Result := 0;
    for ExtNo := 1 to Extensions.Count
    do begin
      Extension := Extensions[ExtNo-1];
      if Extension.Extrec.ExtensionType = etGCE
      then Result := Extension.ExtRec.GCE.DelayTime;
    end;
  end;
end;  { TGifSubImage.GetAnimateInterval }

function TGifSubImage.GetBGColor: TColor;
var
  Index: Integer;
begin { TGifSubImage.GetBGColor }
  Index := FGifFile.ScreenDescriptor.BackGroundColorIndex;
  if HasLocalColormap
  then Result := LocalColormap.GetColor(index)
  else Result := FGifFile.GlobalColorMap.GetColor(index)
end;  { TGifSubImage.GetBGColor }

procedure TGifSubImage.SetAnimateInterval(NewValue: Word);
{ Sets the delay time between this (sub)image and the next one.
In centiseconds! }
var ExtNo: Integer;
    Extension: TExtension;
begin { TGifSubImage.SetAnimateInterval }
  if Extensions.Count <> 0
  then begin
    for ExtNo := 1 to Extensions.Count
    do begin
      Extension := Extensions[ExtNo-1];
      if Extension.Extrec.ExtensionType = etGCE
      then Extension.ExtRec.GCE.DelayTime := NewValue;
    end;
  end;
end;  { TGifSubImage.SetAnimateInterval }

procedure TGifSubImage.SetExtensions(NewValue: TExtensionList);
var
  ExtNo: Integer;
  Ext: TExtension;
begin { TGifSubImage.SetExtensions }
  FExtensions := NewValue;

  FDisposalMethod := dmNone;
  FIsTransparent := False;
  if Extensions <> nil
  then for ExtNo := 1 to Extensions.Count
  do begin
    Ext := Self.Extensions[ExtNo-1];
    case Ext.ExtRec.ExtensionType of
    etGCE: begin
           FDisposalMethod := TDisposalMethod((Ext.ExtRec.GCE.PackedFields shr 2) and $07);
           FIsTransparent := (Ext.ExtRec.GCE.PackedFields and $01) <> 0;
           end;
    etPTE:  ;
    etAPPE: ;
    etCE:   ;
    end;
  end;
end;  { TGifSubImage.SetExtensions }

(***** TGifSubImage: end of property access methods *****)

function TGifSubImage.AsBitmap: TBitmap;
var Stream: TMemoryStream;
begin { TGifSubImage.AsBitmap }
  if FBitmap = nil
  then begin
    Stream := TMemoryStream.Create;
    try
      SaveToStream(Stream);
      FBitmap := TBitmap.Create;
      FBitmap.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
  Result := FBitmap;
end;  { TGifSubImage.AsBitmap }

function TGifSubImage.TransparentColor: TColor;
var
  Found: Boolean;
  ExtNo: Integer;
  Ext: TExtension;
  index: Byte;
begin { TGifSubImage.TransparentColor }
  Found := False;
  ExtNo := 1;
  Ext := nil; //** skip warning
  while not Found and (ExtNo <= Extensions.Count)
  do begin
    Ext := Extensions[ExtNo-1];
    Found := (Ext.ExtRec.ExtensionType = etGCE) and
             ((Ext.ExtRec.GCE.PackedFields and $01) <> 0);
    Inc(ExtNo);
  end;
  if not Found
  then Result := -1
  else begin
    index := Ext.ExtRec.GCE.TransparentColorIndex;
    if HasLocalColormap
    then Result := LocalColormap.GetColor(index)
    else Result := FGifFile.GlobalColormap.GetColor(index)
  end;
end;  { TGifSubImage.TransparentColor }

function TGifSubImage.TransparentColorIndex: Integer;
var
  Found: Boolean;
  ExtNo: Integer;
  Ext: TExtension;
begin { TGifSubImage.TransparentColorIndex }
  Found := False;
  ExtNo := 1;
  Ext := nil; //** skip warning
  while not Found and (ExtNo <= Extensions.Count)
  do begin
    Ext := Extensions[ExtNo-1];
    Found := (Ext.ExtRec.ExtensionType = etGCE) and
             ((Ext.ExtRec.GCE.PackedFields and $01) <> 0);
    Inc(ExtNo);
  end;
  if not Found
  then Result := -1
  else Result := Ext.ExtRec.GCE.TransparentColorIndex;
end;  { TGifSubImage.TransparentColorIndex }

(***** read routines *****)

procedure TGifSubImage.DecodeStatusByte;
begin { TGifSubImage.DecodeStatusByte }
  with ImageDescriptor
  do begin
    HasLocalColorMap := (PackedFields and idLocalColorTable) = idLocalColorTable;
    Interlaced := (ImageDescriptor.PackedFields and idInterlaced) = idInterlaced;
    BitsPerPixel := 1 + ImageDescriptor.PackedFields and $07;
    LocalColorMap.Count := 1 shl BitsPerPixel;
  end;
end;  { TGifSubImage.DecodeStatusByte }

procedure TGifSubImage.ReadImageDescriptor(Stream: TStream);
begin { TGifSubImage.ReadImageDescriptor }
  Stream.Read(ImageDescriptor, SizeOf(ImageDescriptor));
  DecodeStatusByte;
end;  { TGifSubImage.ReadImageDescriptor }

procedure TGifSubImage.ReadLocalColorMap(Stream: TStream);
begin { TGifSubImage.ReadLocalColorMap }
  if HasLocalColorMap
  then
    with LocalColorMap
    do Stream.Read(CT.Colors[0], Count*SizeOf(TColorItem));
end;  { TGifSubImage.ReadLocalColorMap }

procedure TGifSubImage.ReadRasterData(Stream: TStream);
var
  NewString: String;
  BlokByteCount: Byte;
  ReadBytes: Integer;
begin { TGifSubImage.ReadRasterData }
  Stream.Read(LZWCodeSize, 1);
  Stream.Read(BlokByteCount, 1);
  while (BlokByteCount <> 0) and not (Stream.Position >= Stream.Size)
  do begin
{$ifdef ver80}
    NewString[0] := Chr(BlokByteCount);
{$else}
    SetLength(NewString, BlokByteCount);
{$endif ver80}
    ReadBytes := Stream.Read(NewString[1], BlokByteCount);
    if ReadBytes < BlokByteCount
    then
  {$ifdef ver80}
      NewString[0] := Chr(ReadBytes)
  {$else}
      SetLength(NewString, ReadBytes)
  {$endif ver80}
    else Stream.Read(BlokByteCount, 1);
    CompressedRasterData.AddString(NewString);
  end;
end;  { TGifSubImage.ReadRasterData }

procedure InitCompressionStream(InitLZWCodeSize: Byte;
                                var DecodeRecord: TDecodeRecord);
begin { InitCompressionStream }
  with DecodeRecord
  do begin
    LZWCodeSize := InitLZWCodeSize;
    if not (LZWCodeSize in [2..9])    { valid code sizes 2-9 bits }
    then raise EGifException.Create('Bad code Size');
    CurrCodeSize := succ(LZWCodeSize);
    ClearCode := 1 shl LZWCodeSize;
    EndingCode := succ(ClearCode);
    HighCode := pred(ClearCode);      { highest code not needing decoding }
    BitsLeft := 0;
    CurrentY := 0;
    InterlacePass := 1;
  end;
end;  { InitCompressionStream }

function NextCode(CompressedRasterData: TByteBuffer;
                  var DecodeRecord: TDecodeRecord): word;
{ returns a code of the proper bit size }
var LongResult: Longint;
begin { NextCode }
  with DecodeRecord
  do begin
    if BitsLeft = 0 then       { any bits left in byte ? }
    begin                      { any bytes left }
      CurrByte := CompressedRasterData.GetNextByte;   { get a byte }
      BitsLeft := 8;                 { set bits left in the byte }
    end;
    LongResult := CurrByte shr (8 - BitsLeft); { shift off any previously used bits}
    while CurrCodeSize > BitsLeft do          { need more bits ? }
    begin
      CurrByte := CompressedRasterData.GetNextByte;      { get another byte }
      LongResult := LongResult or (CurrByte shl BitsLeft);
                                 { add the remaining bits to the return value }
      BitsLeft := BitsLeft + 8;               { set bit counter }
    end;
    BitsLeft := BitsLeft - CurrCodeSize;      { subtract the code size from bitsleft }
    Result := LongResult and CodeMask[CurrCodeSize];{ mask off the right number of bits }
  end;
end;  { NextCode }

procedure UpdateBitsPerPixel(const ColorCount: Integer;
                             var BitsPerPixel: Byte);
begin { UpdateBitsPerPixel }
  while ColorCount > 1 shl BitsPerPixel
  do Inc(BitsPerPixel)
end;  { UpdateBitsPerPixel }

procedure TGifSubImage.DecodeRasterData;
{ decodes the LZW encoded raster data }
var
  SP: integer; { index to the decode stack }
  DecodeStack: array[0..CodeTableSize-1] of byte;
               { stack for the decoded codes }
  DecodeRecord: TDecodeRecord;
  Prefix: array[0..CodeTableSize-1] of integer; { array for code prefixes }
  Suffix: array[0..CodeTableSize-1] of integer; { array for code suffixes }
  LineBytes: TBigByteArray;
  CurrBuf: word;  { line buffer index }

  procedure DecodeCode(var Code: word);
  { decodes a code and puts it on the decode stack }
  begin { DecodeCode }
    while Code > DecodeRecord.HighCode do
            { rip thru the prefix list placing suffixes }
    begin                    { onto the decode stack }
      DecodeStack[SP] := Suffix[Code]; { put the suffix on the decode stack }
      inc(SP);                         { increment decode stack index }
      Code := Prefix[Code];            { get the new prefix }
    end;
    DecodeStack[SP] := Code;           { put the last code onto the decode stack }
    Inc(SP);                           { increment the decode stack index }
  end;  { DecodeCode }

  procedure PopStack;
  { pops off the decode stack and puts into the line buffer }
  begin { PopStack }
    with DecodeRecord do
    while SP > 0 do
    begin
      dec(SP);
      LineBytes[CurrBuf] := DecodeStack[SP];
      inc(CurrBuf);
      if CurrBuf > ImageDescriptor.ImageWidth       { is the line full ? }
      then begin
        if ImageDescriptor.ImageHeight > 200
        then //ShowProgress((CurrentY+1)/ImageDescriptor.ImageHeight);
        //Application.ProcessMessages;
        Pixels.SetRow(CurrentY+1, LineBytes);
        { addition of one necessary because CurrentY is
          zero-based while ImagePixels is one-based }
        if not InterLaced
        then Inc(CurrentY)
        else CurrentY := NextLineNo(CurrentY, ImageDescriptor.ImageHeight,
                                              InterlacePass);
        CurrBuf := 1;
      end;
    end; { while SP > 0 }
  end;  { PopStack }

  procedure CheckSlotValue(var Slot, TopSlot: Word; var MaxVal: Boolean);
  begin { CheckSlotValue }
    if Slot >= TopSlot then      { have reached the top slot for bit size }
    begin                        { increment code bit size }
      if DecodeRecord.CurrCodeSize < 12 then  { new bit size not too big? }
      begin
        TopSlot := TopSlot shl 1;  { new top slot }
        inc(DecodeRecord.CurrCodeSize)       { new code size }
      end else
        MaxVal := True;       { Must check next code is a start code }
    end;
  end;  { CheckSlotValue }

var
  TempOldCode, OldCode: word;
  Code, C: word;
  MaxVal: boolean;
  Slot     : Word;     { position that the next new code is to be added }
  TopSlot  : Word;     { highest slot position for the current code size }
begin { TGifSubImage.DecodeRasterData }
  InitCompressionStream(LZWCodeSize, DecodeRecord); { Initialize decoding parameters }
  CompressedRasterData.Reset;
  LineBytes := TBigByteArray.Create(ImageDescriptor.ImageWidth);
  OldCode := 0;
  SP := 0;
  CurrBuf := 1;
  MaxVal := False;
  try
  try
    C := NextCode(CompressedRasterData, DecodeRecord);  { get the initial code - should be a clear code }
    while C <> DecodeRecord.EndingCode do  { main loop until ending code is found }
    begin
      if C = DecodeRecord.ClearCode then   { code is a clear code - so clear }
      begin
        DecodeRecord.CurrCodeSize := DecodeRecord.LZWCodeSize + 1;  { reset the code size }
        Slot := DecodeRecord.EndingCode + 1;           { set slot for next new code }
        TopSlot := 1 shl DecodeRecord.CurrCodeSize;    { set max slot number }
        while C = DecodeRecord.ClearCode do
          C := NextCode(CompressedRasterData, DecodeRecord);
            { read until all clear codes gone - shouldn't happen }
        if C = DecodeRecord.EndingCode then
          raise EGifException.Create('Bad code');     { ending code after a clear code }
        if C >= Slot then { if the code is beyond preset codes then set to zero }
          C := 0;
        OldCode := C;
        DecodeStack[SP] := C;   { output code to decoded stack }
        inc(SP);                { increment decode stack index }
      end else   { the code is not a clear code or an ending code so  }
      begin      { it must be a code code - so decode the code }
        Code := C;
        if Code < Slot then     { is the code in the table? }
        begin
          DecodeCode(Code);            { decode the code }
          if Slot <= TopSlot then
          begin                        { add the new code to the table }
            Suffix[Slot] := Code;      { make the suffix }
            Prefix[Slot] := OldCode;   { the previous code - a link to the data }
            inc(Slot);                 { increment slot number }
            CheckSlotValue(Slot, TopSlot, MaxVal);
            OldCode := C;              { set oldcode }
          end;
        end else
        begin  { the code is not in the table }
          if Code <> Slot then
            raise EGifException.Create('Bad code'); { so error out }
            { the code does not exist so make a new entry in the code table
              and then translate the new code }
          TempOldCode := OldCode;  { make a copy of the old code }
          while OldCode > DecodeRecord.HighCode { translate the old code and }
          do begin                              { place it on the decode stack }
            DecodeStack[SP] := Suffix[OldCode]; { do the suffix }
            OldCode := Prefix[OldCode];         { get next prefix }
          end;
          DecodeStack[SP] := OldCode;  { put the code onto the decode stack }
                                    { but DO NOT increment stack index }
              { the decode stack is not incremented because we are }
              { only translating the oldcode to get the first character }
          if Slot <= TopSlot then
          begin   { make new code entry }
            Suffix[Slot] := OldCode;       { first char of old code }
            Prefix[Slot] := TempOldCode;   { link to the old code prefix }
            inc(Slot);                     { increment slot }
            CheckSlotValue(Slot, TopSlot, MaxVal);
          end;
          DecodeCode(Code); { now that the table entry exists decode it }
          OldCode := C;     { set the new old code }
        end;
      end; { else (if code < slot) }
      PopStack;  { the decoded string is on the decode stack; put in linebuffer }
      C := NextCode(CompressedRasterData, DecodeRecord);  { get the next code and go at is some more }
      if (MaxVal = True) and (C <> DecodeRecord.ClearCode) then
        raise EGifException.Create('Code size overflow');
      MaxVal := False;
    end; { while C <> EndingCode }
  except
    on E: EListError do;
    on E: EStringListError do;
  end;
  finally
  LineBytes.Free;
  end;
end;  { TGifSubImage.DecodeRasterData }

procedure TGifSubImage.LoadFromStream(Stream: TStream);
begin { TGifSubImage.LoadFromStream }
  ReadImageDescriptor(Stream);
  ReadLocalColorMap(Stream);
  Pixels.Free;
  Pixels := TByteArray2D.Create(ImageDescriptor.ImageWidth,
                                ImageDescriptor.ImageHeight);
  ReadRasterData(Stream);
  DecodeRasterData;
end;  { TGifSubImage.LoadFromStream }

(***** write routines *****)

procedure AppendPixel(var PixelString: TByteBuffer;
                      Pixels: TBigByteArray;
                      var NextPixelNo: Longint);
begin { AppendPixel }
  PixelString.AddByte(Pixels[NextPixelNo]);
  Inc(NextPixelNo);
end;  { AppendPixel }

procedure GoBackPixel(var PixelString: TByteBuffer;
                      var NextPixelNo: Longint);
begin { GoBackPixel }
  PixelString.DeleteLastByte;
  Dec(NextPixelNo);
end;  { GoBackPixel }

procedure TGifSubImage.EncodeStatusbyte;
begin { TGifSubImage.EncodeStatusbyte }
  with ImageDescriptor
  do begin
    PackedFields := 0;
    if HasLocalColorMap
    then PackedFields := PackedFields or idLocalColorTable;
    if Interlaced
    then PackedFields := PackedFields or idInterlaced;
    if HasLocalColorMap
    then PackedFields := PackedFields or (BitsperPixel-1);
  end;
end;  { TGifSubImage.EncodeStatusbyte }

procedure TGifSubImage.WriteImageDescriptor(Stream: TStream);
var OldStatusByte: Byte;
begin { TGifSubImage.WriteImageDescriptor }
  OldStatusByte := ImageDescriptor.PackedFields;
  EncodeStatusByte;
//** skip warning  {
  if ImageDescriptor.PackedFields <> OldStatusByte
  then ShowMessage('PackedFields value has been changed');
//** skip warning    }
  Stream.Write(ImageDescriptor, SizeOf(ImageDescriptor));
end;  { TGifSubImage.WriteImageDescriptor }

procedure TGifSubImage.WriteLocalColorMap(Stream: TStream);
begin { TGifSubImage.WriteLocalColorMap }
  if HasLocalColorMap
  then
    with LocalColorMap
    do Stream.Write(CT.Colors[0], Count*SizeOf(TColorItem))
end;  { TGifSubImage.WriteLocalColorMap }

procedure TGifSubImage.EncodeRasterdata;
var
  PixelArray: TBigByteArray;
  CodeTable: TCodeTable;
  ClearCode: Word;
  EndCode: Word;
  FirstPixel: Byte;
  OldCode, Code: Integer;
  PixelString: TByteBuffer;
  NextPixelNo: Longint;
  Found: Boolean;
  PrevFoundIndex, FoundIndex: Integer;
  EncodedBytes: TEncodedBytes;
begin { TGifSubImage.EncodeRasterdata }
  MakeFlat(Pixels, Interlaced, PixelArray);
  CodeTable := TCodeTable.Create;
  CodeTable.Clear(LZWCodeSize+1);
  PixelString := TByteBuffer.Create;
  ClearCode := 1 shl LZWCodeSize;
  EndCode := ClearCode + 1;
  EncodedBytes := TEncodedBytes.Create;
  EncodedBytes.AppendCode(ClearCode, CodeTable.CodeSize);
  NextPixelNo := 1;
  FirstPixel := PixelArray[NextPixelNo];
  EncodedBytes.AppendCode(FirstPixel, CodeTable.CodeSize);
  OldCode := FirstPixel;
  Inc(NextPixelNo);
  //ShowProgress(0);
  repeat
    PixelString.Clear;
    AppendPixel(PixelString, PixelArray, NextPixelNo);
    CodeTable.AddEntry(OldCode, PixelString.FirstByte);
    Found := True;
    PrevFoundIndex := PixelString.FirstByte;
    while Found and (NextPixelNo <= PixelArray.Count)
    do begin
      AppendPixel(PixelString, PixelArray, NextPixelNo);
      Found := CodeTable.IsInTable(PixelString, PrevFoundIndex, FoundIndex)
    end;
    if not Found
    then begin
      GoBackPixel(PixelString, NextPixelNo);
      Code := PrevFoundIndex
    end
    else Code := FoundIndex;
    EncodedBytes.AppendCode(Code, CodeTable.CodeSize);
    if CodeTable.TableFull and (NextPixelNo <= PixelArray.Count)
    then begin
      EncodedBytes.AppendCode(ClearCode, CodeTable.CodeSize);
      CodeTable.Clear(LZWCodeSize+1);
      FirstPixel := PixelArray[NextPixelNo];
      EncodedBytes.AppendCode(FirstPixel, CodeTable.CodeSize);
      OldCode := FirstPixel;
      Inc(NextPixelNo);
      //ShowProgress(NextPixelNo/PixelArray.Count);
    end
    else OldCode := Code;
  until (NextPixelNo > PixelArray.Count);
  EncodedBytes.Finish(EndCode, CodeTable.CodeSize);
  CompressedRasterData := EncodedBytes.Value;
  PixelString.Free;
  CodeTable.Free;
  EncodedBytes.Free;
  PixelArray.Free;
  //ShowProgress(1);
end;  { TGifSubImage.EncodeRasterdata }

procedure TGifSubImage.WriteRasterData(Stream: TStream);
var
  StringNo: Integer;
  Block: String;
  BlokByteCount: Byte;
begin { TGifSubImage.WriteRasterData }
  Stream.Write(LZWCodeSize, 1);
  for StringNo := 1 to CompressedRasterData.StringCount
  do begin
    Block := CompressedRasterData.Strings[StringNo];
    BlokByteCount := Length(Block);
    Stream.Write(BlokByteCount, 1);
    Stream.Write(Block[1], BlokByteCount);
  end;
  BlokByteCount := 0;
  Stream.Write(BlokByteCount, 1);
end;  { TGifSubImage.WriteRasterData }

procedure TGifSubImage.SaveToStream(Stream: TStream);
{ Saves it as a .bmp! }

  procedure CreateBitHeader(Image: TGifSubImage;
                            var bmHeader: TBitmapInfoHeader);
  { This routine takes the values from the GIF image
    descriptor and fills in the appropriate values in the
    bit map header struct. }
  begin { CreateBitHeader }
    with BmHeader do
    begin
      biSize           := Sizeof(TBitmapInfoHeader);
      biWidth          := Image.ImageDescriptor.ImageWidth;
      biHeight         := Image.ImageDescriptor.ImageHeight;
      biPlanes         := 1;            {Arcane and rarely used}
      biBitCount       := 8;            {Hmmm Should this be hardcoded ?}
      biCompression    := BI_RGB;       {Sorry Did not implement compression in this version}
      biSizeImage      := 0;            {Valid since we are not compressing the image}
      biXPelsPerMeter  :=143;           {Rarely used very arcane field}
      biYPelsPerMeter  :=143;           {Ditto}
      biClrUsed        := 0;            {all colors are used}
      biClrImportant   := 0;            {all colors are important}
    end;
  end;  { CreateBitHeader }

var
  BitFile: TBitmapFileHeader;
  BmHeader: TBitmapInfoHeader; {File Header for bitmap file}
  i: integer;
  Line: integer;
  ch: char;
  x: integer;
  LineBytes: TBigByteArray;
begin { TGifSubImage.SaveToStream }
  with BitFile do begin
    with ImageDescriptor do
    bfSize := (3*255) + Sizeof(TBitmapFileHeader) +
              Sizeof(TBitmapInfoHeader) + (Longint(ImageHeight)*
                                           Longint(ImageWidth));
    bfReserved1 := 0; {not currently used}
    bfReserved2 := 0; {not currently used}
    bfOffBits := (4*256)+ Sizeof(TBitmapFileHeader)+
                          Sizeof(TBitmapInfoHeader);
  end;
  CreateBitHeader(Self, bmHeader);
  {Write the file header}
  with Stream do begin
    Position:=0;
    ch:='B';
    Write(ch,1);
    ch:='M';
    Write(ch,1);
    Write(BitFile.bfSize,sizeof(BitFile.bfSize));
    Write(BitFile.bfReserved1,sizeof(BitFile.bfReserved1));
    Write(BitFile.bfReserved2,sizeof(BitFile.bfReserved2));
    Write(BitFile.bfOffBits,sizeof(BitFile.bfOffBits));
    {Write the bitmap image header info}
    Write(BmHeader,sizeof(BmHeader));
    {Write the BGR palete information to this file}
    if HasLocalColorMap then {Use the local color table}
    begin
      for i:= 0 to 255 do
      begin
        Write(LocalColormap.CT.Colors[i].Blue,1);
        Write(LocalColormap.CT.Colors[i].Green,1);
        Write(LocalColormap.CT.Colors[i].Red,1);
        Write(ch,1); {Bogus palette entry required by windows}
      end;
    end else {Use the global table}
    begin
      with FGifFile do
      for i := 0 to 255 do
      begin
        Write(GlobalColormap.CT.Colors[i].Blue,1);
        Write(GlobalColormap.CT.Colors[i].Green,1);
        Write(GlobalColormap.CT.Colors[i].Red,1);
        Write(ch,1); {Bogus palette entry required by windows}
      end;
    end;
    for Line := ImageDescriptor.ImageHeight downto 1
    do begin
 {Use reverse order since gifs are stored top to bottom.
  Bmp file need to be written bottom to top}
      LineBytes := Pixels.CopyRow(Line);
      x := ImageDescriptor.ImageWidth;
      Write(LineBytes.Address^, x);
      ch := chr(0);
      while (x and 3) <> 0 do { Pad up to 4-byte boundary with zeroes }
      begin
        Inc(x);
        Write(ch, 1);
      end;
      LineBytes.Free;
      if ImageDescriptor.ImageHeight > 500
      then // ShowProgress(1-(Line-1)/ImageDescriptor.ImageHeight);
    end;
    Position := 0; { reset memory stream}
  end;
end;  { TGifSubImage.SaveToStream }

(***** end of TGifSubImage *****)

(***** TGifFile *****)

constructor TGifFile.Create;
begin { TGifFile.Create }
  inherited Create;
  Header.Signature := 'GIF';
  Header.Version := '87a';
  with ScreenDescriptor do
    begin
      ScreenWidth := 0;
      ScreenHeight := 0;
      PackedFields := 0;
      BackGroundcolorIndex := 0;
      AspectRatio := 0
    end;
  HasGlobalColorMap := True;
  BitsPerPixel := 1;  { arbitrary; other choices would be 4 or 8 }
  GlobalColorMap := TColorTable.Create(0);
  SubImages := TList.Create;
end;  { TGifFile.Create }

destructor TGifFile.Destroy;
var
  SubImageNo: Integer;
  SubImage: TGifSubImage;
begin { TGifFile.Destroy }
  GlobalColormap.Free;
  for SubImageNo := 1 to SubImages.Count
  do begin
    SubImage := SubImages[SubImageNo-1];
    SubImage.Free;
  end;
  SubImages.Free;
  inherited Destroy;
end;  { TGifFile.Destroy }

(***** end of constructor and destructor *****)
(***** property access methods *****)

(*function TGifFile.GetBGColor: TColor;
var BGCI: Byte;
begin { TGifFile.GetBGColor }
  BGCI := ScreenDescriptor.BackGroundColorIndex;
  Result := GlobalColorMap.GetColor(BGCI);
end;  { TGifFile.GetBGColor }*)

(***** end of property access methods *****)

procedure TGifFile.AddBitmap(Bitmap: TBitmap);
var NewSubImage: TGifSubImage;
begin { TGifFile.AddBitmap }
  NewSubImage := TGifSubImage.CreateEmpty;
  NewSubImage.FBitmap := Bitmap;
  SubImages.Add(NewSubImage);
end;  { TGifFile.AddBitmap }

(*function TGifFile.AnimateInterval: Word;
var SubImage: TGifSubImage;
    SubImageNo: Integer;
    Interval: Word;
begin { TGifFile.AnimateInterval }
  if SubImages.Count < 2
  then Result := 0
  else begin
    Result := 0;
    for SubImageNo := 1 to SubImages.Count
    do begin
      SubImage := SubImages[SubImageNo-1];
      Interval := SubImage.AnimateInterval;
{$ifdef debug}
      if Interval = 0
      then WarningMessage('Multiple subimages; no animation time interval found');
      if (Result <> 0) and (Result <> Interval)
      then WarningMessage('Multiple subimages; animation time intervals not equal');;
{$endif debug}
      if Interval <> 0
      then Result := Interval
    end;
  end;
end;  { TGifFile.AnimateInterval }*)

function TGifFile.AsBitmap: TBitmap;
var Stream: TMemoryStream;
begin { TGifFile.AsBitmap }
  Stream := TMemoryStream.Create;
  try
    TGifSubImage(Self.SubImages[0]).SaveToStream(Stream);
    Result := TBitmap.Create;
    Result.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;  { TGifFile.AsBitmap }

function TGifFile.GetSubImage(Index: Integer): TGifSubImage;
begin
  Result := SubImages[Index-1]
end;  { TGifFile.GetSubImage }

(***** Read routines *****)

procedure TGifFile.ReadSignature(Stream: TStream);
begin { TGifFile.ReadSignature }
  Stream.Read(Header, SizeOf(TGifHeader));
  if (Header.Version <> '87a') and (Header.Version <> '89a') and
     (Header.Version <> '87A') and (Header.Version <> '89A')
  then raise EGifException.Create('Gif Version must be 87a or 89a');
end;  { TGifFile.ReadSignature }

procedure TGifFile.DecodeStatusByte;
var
  ColorResolutionBits: Byte;
begin { TGifFile.DecodeStatusByte }
  HasGlobalColorMap := (ScreenDescriptor.PackedFields and lsdGlobalColorTable) = lsdGlobalColorTable;  { M=1 }
  ColorResolutionbits := 1 + (ScreenDescriptor.PackedFields and lsdColorResolution) shr 4;
  N_i := ColorResolutionbits;
  {GlobalColorMap.Count := 1 shl ColorResolutionbits;}
  BitsPerPixel := 1 + ScreenDescriptor.PackedFields and $07;
  GlobalColorMap.Count := 1 shl BitsPerPixel;
end;  { TGifFile.DecodeStatusByte }

procedure TGifFile.ReadScreenDescriptor(Stream: TStream);
begin { TGifFile.ReadScreenDescriptor }
  Stream.Read(ScreenDescriptor, SizeOf(ScreenDescriptor));
  DecodeStatusByte;
end;  { TGifFile.ReadScreenDescriptor }

procedure TGifFile.ReadGlobalColorMap(Stream: TStream);
begin { TGifFile.ReadGlobalColorMap }
  if HasGlobalColorMap
  then
    with GlobalColorMap
    do Stream.Read(CT.Colors[0], Count*SizeOf(TColorItem));
end;  { TGifFile.ReadGlobalColorMap }

procedure TGifFile.ReadExtensionBlocks(Stream: TStream;
                                       var SeparatorChar: Char;
                                       var Extensions: TExtensionList);
{ The '!' has already been read before calling }

  procedure ReadDataBlocks(Stream: TStream; var Data: TStringList);
  { data not yet stored }
  var
    BlockSize: Byte;
    NewString: String;
  begin { ReadDataBlocks }
    Data := TStringlist.Create;
    repeat
      Stream.Read(BlockSize, 1);
      if BlockSize <> 0
      then begin
    {$ifdef ver80}
        NewString[0] := Chr(BlockSize);
    {$else}
        SetLength(NewString, BlockSize);
    {$endif ver80}
        Stream.Read(NewString[1], BlockSize);
        Data.Add(NewString);
      end;
    until BlockSize = 0;
  end;  { ReadDataBlocks }

var
  NewExtension: TExtension;
  ExtensionLabel: Byte;
begin { TGifFile.ReadExtensionBlocks }
  Extensions := TExtensionList.Create;
  while SeparatorChar = '!'
  do begin
    NewExtension := TExtension.Create;
    Extensions.Add(NewExtension);
    Stream.Read(ExtensionLabel, 1);
    with NewExtension.ExtRec do
    case ExtensionLabel of
      $F9: ExtensionType := etGCE;  { graphic control extension }
      $FE: ExtensionType := etCE;   { comment extension }
      $01: ExtensionType := etPTE;  { plain text extension }
      $FF: ExtensionType := etAPPE; { application extension }
      else raise EGifException.Create('Unrecognized extension block.'+
                 #13+#10 + 'Code = $' + IntToHex(ExtensionLabel, 2));
    end; { case }
    with NewExtension.ExtRec do
    case ExtensionLabel of
      $F9: Stream.Read(GCE, SizeOf(GCE));
      $FE: ReadDataBlocks(Stream, Comment);
      $01: begin
             Stream.Read(PTE, SizeOf(PTE)-SizeOf(PTE.PlainTextData));
             ReadDataBlocks(Stream, PTE.PlainTextData);
           end;
      $FF: begin
             Stream.Read(APPE, SizeOf(APPE)-SizeOf(APPE.AppData));
             ReadDataBlocks(Stream, APPE.AppData);
           end;
    end; { case }
    Stream.Read(SeparatorChar, 1);
  end;
end;  { TGifFile.ReadExtensionBlocks }

procedure TGifFile.LoadFromFile(filename: String);
var
  Stream: TMemoryStream;
begin { TGifFile.LoadFromFile }
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(filename);
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;  { TGifFile.LoadFromFile }

procedure TGifFile.LoadFromStream(Stream: TStream);
var
  SeparatorChar: Char;
  NewSubImage: TGifSubimage;
  Extensions: TExtensionList;
  OldStreamPosition: Longint;
begin { TGifFile.LoadFromStream }
  Screen.Cursor := crHourGlass;
  try
    Stream.Position := 0;
    OldStreamPosition := 0;
    ReadSignature(Stream);
    ReadScreenDescriptor(Stream);
    ReadGlobalColorMap(Stream);
    Stream.Read(SeparatorChar, 1);
    while (SeparatorChar <> ';') and not (Stream.Position >= Stream.Size)
          and not (Stream.Position = OldStreamPosition)
    do begin
      OldStreamPosition := Stream.Position;
      ReadExtensionBlocks(Stream, SeparatorChar, Extensions);
      if SeparatorChar = ','
      then begin
        NewSubImage := TGifSubImage.Create(GlobalColormap.Count, Self);
        NewSubImage.Extensions.Free;
        NewSubImage.Extensions := Extensions;
        NewSubImage.LoadFromStream(Stream);
        SubImages.Add(NewSubImage);
        if not (Stream.Position >= Stream.Size)
        then Stream.Read(SeparatorChar, 1)
        else SeparatorChar := ';'
      end
      else Extensions.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;  { TGifFile.LoadFromStream }

(***** write routines *****)

procedure TGifFile.EncodeGifFile;
{ Encodes the subimages which are (all) not yet encoded (just stored as
  bitmaps) }
var
  SubImage: TGifSubImage;
  Colormap: TColorTable;
  Pixels: TByteArray2D;
  SubImageNo: Integer;
begin { TGifFile.EncodeGifFile }
  for SubImageNo := 1 to SubImages.Count
  do begin
    SubImage := SubImages[SubImageNo-1];
    BitmapToPixelmatrix(SubImage.FBitmap, Colormap, Pixels);
    SubImages.Remove(SubImage);
    SubImage.Free;
    SubImage := TGifSubImage.Create(Colormap.Count, Self);
    SubImages.Add(SubImage);
    if GlobalColormap.Count = 0
    then GlobalColormap := Colormap
    else begin
      SubImage.HasLocalColorMap := True;
      SubImage.LocalColormap := Colormap;
    end;
    UpdateBitsPerPixel(GlobalColormap.Count, BitsPerPixel);
    SubImage.EncodeStatusByte;
    SubImage.Pixels.Free;
    SubImage.Pixels := Pixels;
    SubImage.ImageDescriptor.ImageWidth := Pixels.Count1;
    SubImage.ImageDescriptor.ImageHeight := Pixels.Count2;
    if ScreenDescriptor.ScreenWidth < Pixels.Count1
    then ScreenDescriptor.ScreenWidth := Pixels.Count1;
    if ScreenDescriptor.ScreenHeight < Pixels.Count2
    then ScreenDescriptor.ScreenHeight := Pixels.Count2;
    EncodeStatusByte;
  end;
end;  { TGifFile.EncodeGifFile }

procedure TGifFile.EncodeStatusByte;
var
  ColorResolutionBits: Byte;
begin { TGifFile.EncodeStatusByte }
  with ScreenDescriptor
  do begin
    PackedFields := 0;
    if HasGlobalColorMap
    then PackedFields := PackedFields + lsdGlobalColorTable;
    case GlobalColorMap.Count of
      2: ColorResolutionBits := 1;
      4: ColorResolutionBits := 2;
      8: ColorResolutionBits := 3;
      16: ColorResolutionBits := 4;
      32: ColorResolutionBits := 5;
      64: ColorResolutionBits := 6;
      128: ColorResolutionBits := 7;
      256: ColorResolutionBits := 8;
      else raise EGifException.Create('unexpected number of colors')
    end;
    PackedFields := PackedFields + (ColorResolutionBits-1) shl 4;
    PackedFields := PackedFields + (BitsPerPixel-1);
  end;
end;  { TGifFile.EncodeStatusByte }

procedure TGifFile.WriteSignature(Stream: TStream);
begin { TGifFile.WriteSignature }
  Stream.Write(Header, SizeOf(TGifHeader));
end;  { TGifFile.WriteSignature }

procedure TGifFile.WriteScreenDescriptor(Stream: TStream);
begin { TGifFile.WriteScreenDescriptor }
  EncodeStatusByte;
  Stream.Write(ScreenDescriptor, SizeOf(ScreenDescriptor));
end;  { TGifFile.WriteScreenDescriptor }

procedure TGifFile.WriteGlobalColorMap(Stream: TStream);
begin { TGifFile.WriteGlobalColorMap }
  if HasGlobalColorMap
  then
    with GlobalColorMap
    do Stream.Write(CT.Colors[0], Count*SizeOf(TColorItem))
end;  { TGifFile.WriteGlobalColorMap }

procedure TGifFile.SaveToFile(filename: String);
var
  Stream: TMemoryStream;
begin { TGifFile.SaveToFile }
  Stream := TMemoryStream.Create;
  SaveToStream(Stream);
  Stream.SaveToFile(filename);
  Stream.Free;
end;  { TGifFile.SaveToFile }

procedure TGifFile.SaveToStream(Stream: TStream);
var
  ImageSeparator: Char;
  ImageNo: Integer;
  SubImage: TGifSubimage;
begin { TGifFile.SaveToStream }
  Screen.Cursor := crHourGlass;
  if not Assigned(GetSubImage(1).FGifFile)
  then EncodeGifFile;
  WriteSignature(Stream);
  WriteScreenDescriptor(Stream);
  WriteGlobalColorMap(Stream);
  ImageSeparator := ',';
  for ImageNo := 1 to SubImages.Count
  do begin
    Stream.Write(ImageSeparator, 1);
    SubImage := SubImages[ImageNo-1];
    if SubImage.CompressedRasterData.TotalSize = 0
    then SubImage.EncodeRasterdata;
    SubImage.WriteImageDescriptor(Stream);
    SubImage.WriteLocalColorMap(Stream);
    SubImage.WriteRasterData(Stream);
  end;
  ImageSeparator := ';';
  Stream.Write(ImageSeparator, 1);
  Screen.Cursor := crDefault;
end;  { TGifFile.SaveToStream }

(***** end of methods of TGifFile *****)

(***** TGifBitmap *****)

procedure TGifBitmap.LoadFromStream(Stream: TStream);
{ Reads TGifBitmap from a (GIF) stream; necessary to make
  TPicture.RegisterFileFormat work }
var
  aGif: TGifFile;
  aStream: TMemoryStream;
begin { TGifBitmap.LoadFromStream }
  aGif := TGifFile.Create;
  try
    aGif.LoadFromStream(Stream);
    aStream := TMemoryStream.Create;
    try
      aGif.GetSubImage(1).SaveToStream(aStream);
      inherited LoadFromStream(aStream);
    finally
      aStream.Free;
    end;
  finally
    aGif.Free;
  end;
end;  { TGifBitmap.LoadFromStream }

(***** end of methods of TGifBitmap *****)

function DecodeColor(Color: TColor): TColorItem;
begin { DecodeColor }
  Result.Blue   := (Color shr 16) and $FF;
  Result.Green := (Color shr 8) and $FF;
  Result.Red  := Color and $FF;
end;  { DecodeColor }

function EncodeColorItem(r, g, b: Byte): TColorItem;
begin { EncodeColorItem }
  Result.Red := r;
  Result.Green := g;
  Result.Blue := b;
end;  { EncodeColorItem }

(***** RColorTable *****)

procedure TColorTable_CreateBW(var CT: RColorTable);
begin { TColorTable_CreateBW }
  CT.Count := 2;
  CT.Colors[0] := EncodeColorItem(0, 0, 0);
  CT.Colors[1] := EncodeColorItem($FF, $FF, $FF);
end;  { TColorTable_CreateBW }

procedure TColorTable_Create16(var CT: RColorTable);
begin { TColorTable_Create16 }
  CT.Count := 16;
  CT.Colors[ 0] := EncodeColorItem($00, $00, $00); { black }
  CT.Colors[ 1] := EncodeColorItem($80, $00, $00); { maroon }
  CT.Colors[ 2] := EncodeColorItem($00, $80, $00); { darkgreen }
  CT.Colors[ 3] := EncodeColorItem($80, $80, $00); { army green }
  CT.Colors[ 4] := EncodeColorItem($00, $00, $80); { dark blue }
  CT.Colors[ 5] := EncodeColorItem($80, $00, $80); { purple }
  CT.Colors[ 6] := EncodeColorItem($00, $80, $80); { blue green }
  CT.Colors[ 7] := EncodeColorItem($80, $80, $80); { dark gray }
  CT.Colors[ 8] := EncodeColorItem($C0, $C0, $C0); { light gray }
  CT.Colors[ 9] := EncodeColorItem($FF, $00, $00); { red }
  CT.Colors[10] := EncodeColorItem($00, $FF, $00); { green }
  CT.Colors[11] := EncodeColorItem($FF, $FF, $00); { yellow }
  CT.Colors[12] := EncodeColorItem($00, $00, $FF); { blue }
  CT.Colors[13] := EncodeColorItem($FF, $00, $FF); { magenta }
  CT.Colors[14] := EncodeColorItem($00, $FF, $FF); { lt blue green }
  CT.Colors[15] := EncodeColorItem($FF, $FF, $FF); { white }
end;  { TColorTable_Create16 }

procedure TColorTable_Create256(var CT: RColorTable);
var ColorNo: Byte;
begin { TColorTable_Create256 }
  CT.Count := 256;
  for ColorNo := 0 to 255
  do CT.Colors[ColorNo] := EncodeColorItem(ColorNo, ColorNo, ColorNo);
end;  { TColorTable_Create256 }

(***** TColorTable *****)

constructor TColorTable.Create(NColors: Word);
begin { TColorTable.Create }
  inherited Create;
  case NColors of
    0, 2: TColorTable_CreateBW(CT);
    16: TColorTable_Create16(CT);
    256: TColorTable_Create256(CT);
  end;
  CT.Count := NColors;
end;  { TColorTable.Create }

procedure TColorTable.AdjustColorCount;
begin { TColorTable.AdjustColorCount }
  if CT.Count > 2
  then if CT.Count <= 4
  then CT.Count := 4
  else if CT.Count <= 8
  then CT.Count := 8
  else if CT.Count <= 16
  then CT.Count := 16
  else if CT.Count <= 32
  then CT.Count := 32
  else if CT.Count <= 64
  then CT.Count := 64
  else if CT.Count <= 128
  then CT.Count := 128
  else if CT.Count < 256
  then CT.Count := 256;
end;  { TColorTable.AdjustColorCount }

procedure TColorTable.CompactColors;
var
  i: integer;
begin { TColorTable.CompactColors }
  for i := 0 to CT.Count-1
  do CT.Colors[i] := DecodeColor(FCT.Colors[i]);
end;  { TColorTable.CompactColors }

function TColorTable.GetColor(Index: Byte): TColor;
begin
  with CT.Colors[Index]
  do Result :=  Blue shl 16 + Green shl 8 + Red;
end;

function TColorTable.GetColorIndex(Color: TColor): Integer;
begin { GetColorIndex }
  Result := CT.Count - 1;
  while Result >= 0
  do begin
    if Color = FCT.Colors[Result]
    then exit
    else Dec(Result);
  end;
end;  { TColorTable.GetColorIndex }

function TColorTable.GetCount: Integer;
begin
  Result := CT.Count;
end;  { TColorTable.GetCount }

procedure TColorTable.SetCount(NewValue: Integer);
begin
  CT.Count := NewValue;
end;  { TColorTable.SetCount }

type
   EIndexOutOfBounds = class(Exception);
   ENotEnoughMemory = class(Exception);

procedure Error(msg: String);
begin
   raise Exception.Create(msg);
end;

procedure AddToAddress(var P: Pointer; Count: Longint);
begin { AddToAddress }
{$ifdef ver80}
  if Count > 64000
  then heapunit.AddToAddress(P, Count)
  else P := Pointer(Longint(P)+Count);
{$else}
  P := Pointer(Longint(P)+Count);
{$endif}
end;  { AddToAddress }

procedure ReDim(var AnArray: TBigByteArray; NewSize: Longint);
var Result: TBigByteArray;
    TotalSize: Longint;
begin { TBigByteArray.ReDim }
  TotalSize := AnArray.Count * SizeOf(Byte);
  Result := TBigByteArray.Create(NewSize);
  Move(AnArray.FAddress^, Result.FAddress^, TotalSize);
  AnArray.Free;
  AnArray := Result;
end;  { TBigByteArray.ReDim }

(***** methods of TBigByteArray *****)

constructor TBigByteArray.Create(N: Longint);
{ Creates one dimensional array }
var
   TotalSize: Longint;
   ErrorMessage: String;
begin { TBigByteArray.Create }
   inherited create;
   FCount := N;
   TotalSize := Longint(Count) * SizeOf(Byte);
{$ifdef ver80}
   BigGetMem(FAddress, TotalSize);
{$else}
   GetMem(FAddress, TotalSize);
{$endif}
   if (Address = nil) and (TotalSize <> 0)
   then begin
      ErrorMessage :=
        'error in TBigByteArray.create: '+
        'Not enough contiguous memory available' + CRLF +
        ' requested memory block: '+ IntToStr(TotalSize) +' bytes'{+ CRLF +
        ' largest memory block: '+ IntToStr(maxavail) +' bytes'+ CRLF +
        ' total free memory: '+ IntToStr(memavail) +' bytes'};
      raise ENotEnoughMemory.Create(ErrorMessage)
   end;
end;  { TBigByteArray.Create }

destructor TBigByteArray.Destroy;
{ Disposes array }
var
   TotalSize: Longint;
begin { TBigByteArray.Destroy }
   TotalSize := Count * SizeOf(Byte);
{$ifdef ver80}
   BigFreeMem(FAddress, TotalSize);
{$else}
   FreeMem(FAddress, TotalSize);
{$endif ver80}
   FCount := 0;
   inherited Destroy;
end;  { TBigByteArray.Destroy }

constructor TBigByteArray.Dim(N: Longint);
{ Creates one dimensional array, sets values to zero }
begin { TBigByteArray.Dim }
   Create(N);
   Clear;
end;  { TBigByteArray.Dim }

(***** end of constructors and destructors *****)

(***** field access methods *****)

function TBigByteArray.GetVal(index: Longint): Byte;
{ Gets value of array element }
var
   p: Pointer;
   value: Byte;
begin { TBigByteArray.GetVal }
   if (index < 1) or (index > Count)
   then raise EIndexOutOfBounds.Create('Dynamic array index out of bounds');
   p := Address;
   AddToAddress(p, (index-1) * SizeOf(Byte));
   Move(p^, value, SizeOf(Byte));
   GetVal := value;
end;  { TBigByteArray.GetVal }

procedure TBigByteArray.SetVal(index: Longint; value: Byte);
{ Sets value of array element }
var
   p: Pointer;
begin { TBigByteArray.SetVal }
   if (index < 1) or (index > Count)
   then raise EIndexOutOfBounds.Create('Dynamic array index out of bounds');
   p := FAddress;
   AddToAddress(p, (index-1) * SizeOf(Byte));
   Move(value, p^, SizeOf(Byte));
end;  { TBigByteArray.SetVal }

(***** end of the field access methods *****)

procedure TBigByteArray.Append(AppendArray: TBigByteArray);
{ Append AppendArray at the end of 'self'.
Note that the implementation can be a lot optimized for speed
by moving blocks of memory in stead of one element at a time }
var TempArray: TBigByteArray;
    i: Longint;
begin { TBigByteArray.Append }
   TempArray := Self.Copy;
   Self.Free;
   TBigByteArray.Create(Count + appendarray.Count);
   for i := 1 to Count
   do Self[i] := TempArray[i];
   for i := 1 to AppendArray.Count
   do Self[Count+i] := AppendArray[i];
   TempArray.Free;
end;  { TBigByteArray.Append }

(*function TBigByteArray.Average: Single;
var sum: Single;
    i, N: Longint;
begin { TBigByteArray.Average }
   sum := 0;
   N := 0;
   for i := 1 to count
   do begin
     if Value[i] <> NoValue
     then begin
       Inc(N);
       sum := sum + Value[i];
     end;
   end;
   if N <> 0
   then Average := sum / N
   else Average := NoValue
end;  { TBigByteArray.Average }*)

procedure TBigByteArray.Clear;
{ Assigns zero to all elements }
var
   TotalSize: Longint;
begin { TBigByteArray.Clear }
   TotalSize := Count * SizeOf(Byte);
{$ifdef ver80}
   BigFillChar(FAddress, TotalSize, chr(0));
{$else}
   FillChar(FAddress^, TotalSize, chr(0));
{$endif ver80}
end;  { TBigByteArray.Clear }

function TBigByteArray.Copy: TBigByteArray;
{ Creates a copy of the array }
begin { TBigByteArray.Copy }
   Result := TBigByteArray.Create(Count);
{$ifdef ver80}
   BigMove(FAddress, Result.FAddress, Count * SizeOf(Byte));
{$else}
   Move(FAddress^, Result.FAddress^, Count * SizeOf(Byte));
{$endif ver80}
end;  { TBigByteArray.Copy }

function TBigByteArray.EqualTo(OtherArray: TBigByteArray): Boolean;
var index: Longint;
begin { TBigByteArray.EqualTo }
  Result := True;
  if Count <> OtherArray.Count
  then Result := False
  else begin
    Index := 1;
    while (Result = True) and (index <= Count)
    do begin
      if GetVal(Index) <> OtherArray[Index]
      then Result := False
      else Inc(Index);
    end
  end;
end;  { TBigByteArray.EqualTo }

procedure TBigByteArray.FillWith(Value: Byte);
var i: Longint;
begin { TBigByteArray.FillWith }
   for i := 1 to Count
   do Self[i] := Value;
end;  { TBigByteArray.FillWith }

procedure TBigByteArray.FindMax(var i: Longint; var max: Byte);
var j: Longint;
    value: Byte;
begin { TBigByteArray.FindMax }
   max := 0;
   for j := 1 to Count
   do begin
      value := GetVal(j);
      if value > max
      then begin
         i := j;
         max := value;
      end;
   end;
end;  { TBigByteArray.FindMax }

procedure TBigByteArray.FindMinMax(var min, max: Byte);
var j: Longint;
    value: Byte;
begin { TBigByteArray.FindMinMax }
   min := 255;
   max := 0;
   for j := 1 to Count
   do begin
      value := GetVal(j);
      if value < min
      then min := value;
      if value > max
      then max := value;
   end;
end;  { TBigByteArray.FindMinMax }

(*procedure TBigByteArray.GetMeanAndSigma(var Mean, sd: Single);
{ calculates mean and standard deviation of elements }
var
  i, N: longint;
  value, Sum, SumOfSquares, MeanOfSquares: single;
begin { TBigByteArray.GetMeanAndSigma }
  SumOfSquares := 0;
  Sum := 0;
  N := 0;
  for i := 1 to Count
  do begin
    value := GetVal(i);
    if Value <> NoValue
    then begin
      Inc(N);
      Sum := Sum + value;
      SumOfSquares := SumOfSquares + sqr(value);
    end;
  end;
  if N = 0
  then begin
    Mean := NoValue;
    Sd := NoValue;
  end
  else begin
    Mean := Sum / N;
    MeanOfSquares := SumOfSquares / N;
    if (MeanOfSquares - Sqr(Mean)) < 0  { should only be possible }
    then sd := 0                    {in case of rounding off errors }
    else sd := Sqrt( MeanOfSquares - Sqr(Mean) );
  end
end;  { TBigByteArray.GetMeanAndSigma }*)

function TBigByteArray.Max: Byte;
var maximum: Byte;
    i: Longint;
begin { TBigByteArray.Max }
   maximum := 0;
   for i := 1 to count
   do if Value[i] > maximum
      then maximum := Value[i];
   Max := maximum;
end;  { TBigByteArray.Max }

function TBigByteArray.Min: Byte;
var minimum, v: Byte;
    i: Longint;
begin { TBigByteArray.Min }
   minimum := 255;
   for i := 1 to count
   do begin
      v := Value[i];
      if v < minimum
      then minimum := v;
   end;
   Min := minimum;
end;  { TBigByteArray.Min }

(*procedure TBigByteArray.MultiplyWith(Factor: Single);
{ Multiplies all elements values with factor }
var i: Longint;
    v: Single;
begin { TBigByteArray.MultiplyWith }
   for i := 1 to Count
   do begin
      v := Value[i];
      if v <> NoValue
      then Value[i] := v * Factor;
   end;
end;  { TBigByteArray.MultiplyWith }*)

constructor TBigByteArray.ReadBinary(var F: File);
{ reads TBigByteArray from untyped file }
var
   size, result: longint;
   wresult: Integer;
begin { TBigByteArray.ReadBinary }
   BlockRead(F, FCount, SizeOf(FCount), wresult);
   Create(Count);
   size := Count * SizeOf(Byte);
{$ifdef ver80}
   BigBlockRead(F, FAddress^, size, result);
{$else}
   BlockRead(F, FAddress^, size, result);
{$endif ver80}
   if size <> result
   then Error('Error in TBigByteArray.ReadBinary: ' +
              'read number of bytes <> size');
end;  { TBigByteArray.ReadBinary }

(*procedure TBigByteArray.ReDim(NewSize: Longint);
var SelfCopy: TBigByteArray;
    TotalSize: Longint;
begin { TBigByteArray.ReDim }
  TotalSize := Count * SizeOf(Byte);
  SelfCopy := Self.Copy;
  Self.Free;
  Create(NewSize);
  Move(SelfCopy.FAddress^, FAddress^, TotalSize);
  SelfCopy.Free;
end;  { TBigByteArray.ReDim }*)

(*
procedure TBigByteArray.SortAscending;
{ sorts the array ascending; may also be used for more than one-dimensional
dynamicarrays }

   PROCEDURE store_tree( root: nodepointer;
                         destination: TBigByteArray;
                         VAR currentindex: longint);
   BEGIN { store_tree }
      IF root <> Nil
      THEN BEGIN
         store_tree(root^.ltree, destination, currentindex);
         destination[currentindex] := root^.value;
         Inc(currentindex);
         store_tree(root^.rtree, destination, currentindex);
      END;
   END;  { store_tree }

VAR tree: avltreetype;
    i: longint;
    newvalue, treeval: nodepointer;
begin { TBigByteArray.SortAscending }
   tree.init;
   FOR i := 1 TO Count
   DO BEGIN
      tree.insert(Value[i]);
      {progressproc(0.8*i/nr_of_elements);}
      { Not up to 100% because tree.done requires some time too }
      { Tested: progressproc can take 50% of total time! }
   END;
   i := 1; { must be a var-parameter for store_tree }
   store_tree(tree.root, self, i);
   tree.done;
   {progressproc(1);}
end;  { TBigByteArray.SortAscending }
*)

procedure TBigByteArray.Subtract(other: TBigByteArray);
{ Subtracts the values of 'other' from the values of 'self' }
var i: Longint;
begin { TBigByteArray.Subtract }
   for i := 1 to Count
   do SetVal(i, Self[i] - other[i])
end;  { TBigByteArray.Subtract }

(*function TBigByteArray.Sum: Single;
{ Returns the sum of the values of the elements }
var i: Longint;
    s: Single;
begin { TBigByteArray.Sum }
   s := 0;
   for i := 1 to Count
   do if GetVal(i) <> NoValue
      then s := s + GetVal(i);
   Sum := s;
end;  { TBigByteArray.Sum }*)

procedure TBigByteArray.WriteBinary( var F: File );
{ writes TBigByteArray to untyped file }
var
   size, result: longint;
   wresult: Integer;
begin { TBigByteArray.WriteBinary }
   size := SizeOf(FCount);
   BlockWrite(F, FCount, size, wresult);
   size := Count * SizeOf(Byte);
{$ifdef ver80}
   BigBlockWrite(F, FAddress^, size, result);
{$else}
   BlockWrite(F, FAddress^, size, result);
{$endif ver80}
   if size <> result
   then Error('Error in TBigByteArray.WriteBinary: ' +
              'written number of bytes <> size');
end;  { TBigByteArray.WriteBinary }

(***** end of TBigByteArray *****)

constructor TByteArray2D.Create(N1, N2: Longint);
begin { TByteArray2D.Create }
  inherited Create;
  values := TBigByteArray.Create(N1*N2);
  FCount1 := N1;
  FCount2 := N2;
end;  { TByteArray2D.Create }

destructor TByteArray2D.Destroy;
begin { TByteArray2D.Destroy }
  Values.Free;
  FCount1 := 0;
  FCount2 := 0;
  inherited Destroy;
end;  { TByteArray2D.Destroy }

constructor TByteArray2D.Dim(N1, N2: Longint);
begin { TByteArray2D.Dim }
  inherited Create;
  values := TBigByteArray.Dim(N1*N2);
  FCount1 := N1;
  FCount2 := N2;
end;  { TByteArray2D.Dim }

(***** end of constructors and destructors *****)

procedure TByteArray2D.Clear;
{ Assigns zero to all elements }
begin { TByteArray2D.Clear }
   Values.Clear;
end;  { TByteArray2D.Clear }

function TByteArray2D.Copy: TByteArray2D;
begin { TByteArray2D.Copy }
   Result := TByteArray2D.Create(Count1, Count2);
{$ifdef ver80}
   BigMove(Values.FAddress, Result.Values.FAddress, Values.Count * SizeOf(Byte));
{$else}
   Move(Values.FAddress^, Result.Values.FAddress^, Values.Count * SizeOf(Byte));
{$endif ver80}
end;  { TByteArray2D.Copy }

function TByteArray2D.CopyRow(RowNo: Longint): TBigByteArray;
var
  FSource: Pointer;
begin { TByteArray2D.CopyRow }
  Result := TBigByteArray.Create(Count1);
  FSource := Values.FAddress;
  AddToAddress(FSource, ((RowNo-1)*Count1)*SizeOf(Byte) );
{$ifdef ver80}
  BigMove(FSource, Result.FAddress, Count1*SizeOf(Byte));
{$else}
  Move(FSource^, Result.FAddress^, Count1*SizeOf(Byte));
{$endif ver80}
end;  { TByteArray2D.CopyRow }

function TByteArray2D.GetTotalCount: Longint;
begin
   Result := Values.Count;
end;

function TByteArray2D.GetVal(i1, i2: Longint): Byte;
begin
   Result := Values[i1+(i2-1)*Count1];
end;

procedure TByteArray2D.SetVal(i1, i2: Longint; value: Byte);
begin
   Values[i1+(i2-1)*Count1] := Value;
end;

procedure TByteArray2D.FindMax(var i1, i2: Longint; var max: Byte);
var i: Longint;
begin
   Values.FindMax(i, max);
   i1 := (i-1) mod Count1 + 1;
   i2 := (i-1) div Count1 + 1;
end;

procedure TByteArray2D.FindMinMax(var min, max: Byte);
begin
   Values.FindMinMax(min, max);
end;

function TByteArray2D.Max: Byte;
begin
   Result := Values.Max;
end;

function TByteArray2D.Min: Byte;
begin
   Result := Values.Min;
end;

procedure TByteArray2D.MirrorX;
{ Inverses order of elements in y-direction }
var SelfCopy: TByteArray2D;
    ix, iy: longint;
begin { TByteArray2D.MirrorX }
   SelfCopy := Self.Copy;
   Self.Free;
   TByteArray2D.Create(SelfCopy.Count1, SelfCopy.Count2);
   for ix := 1 to Count1
   do for iy := 1 to Count2
      do Self[ix, iy] := SelfCopy[Count1-ix+1, iy];
   SelfCopy.Free;
end;  { TByteArray2D.MirrorX }

procedure TByteArray2D.MirrorY;
{ Inverses order of elements in x-direction }
var SelfCopy: TByteArray2D;
    ix, iy: longint;
begin { TByteArray2D.MirrorY }
   SelfCopy := Self.Copy;
   Self.Free;
   TByteArray2D.Create(SelfCopy.Count1, SelfCopy.Count2);
   for ix := 1 to Count1
   do for iy := 1 to Count2
      do Self[ix, iy] := SelfCopy[ix, Count2-iy+1];
   SelfCopy.Free;
end;  { TByteArray2D.MirrorY }

(*procedure TByteArray2D.MultiplyWith( Factor: Single);
begin { TByteArray2D.MultiplyWith }
   Values.MultiplyWith( Factor);
end; { TByteArray2D.MultiplyWith }*)

constructor TByteArray2D.ReadBinary( var F: File );
{ reads TByteArray2D from untyped fyle }
var
   size, result: longint;
   wresult: Integer;
begin { TByteArray2D.ReadBinary }
   BlockRead( F, FCount1, SizeOf(FCount1), wresult );
   BlockRead( F, FCount2, SizeOf(FCount2), wresult );
   Create( Count1, Count2);
   size := TotalCount * SizeOf( Byte);
{$ifdef ver80}
   BigBlockRead(F, Values.FAddress^, size, result);
{$else}
   BlockRead(F, Values.FAddress^, size, result);
{$endif}
   if size <> result
   then Error('Error in TByteArray2D.ReadBinary: ' +
              'read number of bytes <> size');
end;  { TByteArray2D.ReadBinary }

procedure TByteArray2D.SetRow(ColNo: Integer; RowValues: TBigByteArray);
var
  RowSize: Longint;
  InsertAddress: Pointer;
begin { TByteArray2D.SetRow }
  if (ColNo < 1) or (ColNo > Count2)
  then raise EIndexOutOfBounds.Create('Dynamic array index out of bounds');
  if RowValues.Count <> Count1
  then Error('Row doesn''t have equal number of elements as Matrix row');
  RowSize := Count1*SizeOf(Byte);
  InsertAddress := Values.FAddress;
  AddToAddress(InsertAddress, (ColNo-1)*RowSize);
  Move(RowValues.FAddress^, InsertAddress^, RowSize);
end;  { TByteArray2D.SetRow }

(*function TByteArray2D.Sum: Byte;
begin
end;*)

function TByteArray2D.SumColumns: TBigByteArray;
var sum: Byte;
    Row, Column: Longint;
begin { TByteArray2D.SumColumns }
  Result := TBigByteArray.Create(FCount1);
  for Row := 1 to FCount1
  do begin
    sum := 0;
    for Column := 1 to FCount2
    do begin
      sum := sum + Self[Row, Column];
    end;
    Result[Row] := sum;
  end;
end;  { TByteArray2D.SumColumns }

procedure TByteArray2D.Transpose;
{ Inverts rows and columns }
var SelfCopy: TByteArray2D;
    i1, i2: longint;
begin { TByteArray2D.Transpose }
   SelfCopy := Self.Copy;
   Self.Free;
   TByteArray2D.Create(SelfCopy.Count2, SelfCopy.Count1);
   for i1 := 1 to Count1
   do for i2 := 1 to Count2
      do Self[i1, i2] := SelfCopy[i2, i1];
   SelfCopy.Free;
end;  { TByteArray2D.Transpose }

procedure TByteArray2D.WriteBinary( var F: File );
{ writes TByteArray2D to untyped file }
var
   size, result: longint;
   wresult: Integer;
begin { TByteArray2D.WriteBinary }
   BlockWrite( F, FCount1, SizeOf(FCount1), wresult );
   BlockWrite( F, FCount2, SizeOf(FCount2), wresult );
   size := TotalCount * SizeOf( Byte);
{$ifdef ver80}
   BigBlockWrite( F, Values.FAddress^, size, result );
{$else}
   BlockWrite( F, Values.FAddress^, size, result );
{$endif}
   if size <> result
   then Error('Error in TByteArray2D.WriteBinary: ' +
              'written number of bytes <> size')
end;  { TByteArray2D.WriteBinary }

(***** end of TByteArray2D *****)


end.
