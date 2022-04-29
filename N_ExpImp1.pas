unit N_ExpImp1;
// low level export/import map procedures
// ( Shape, Krlb, TDB, MIF/MID )

interface
uses
  Windows, Classes, Graphics, Messages, Forms, Types, DB, DBTables,  
  K_Script1,
  N_Types, N_Gra0, N_Gra1, K_UDT1, N_UDat4, N_Lib2, N_Comp1; //

type TN_BordLine = record //***** Krlb record (one border line info)
  RC1: integer;      // Left Region Code
  RC2: integer;      // Right Region Code
  NPoints: integer;  // number of points in border between RC1 and RC2 regions
  IndXY: integer;    // index (in XY array) of first point in border line
end;
type TN_BordLines = array of TN_BordLine;

type TN_BordLine2 = record //***** Krlb --> Shape record
  RC1LineInd1: integer;
  RC1LineInd2: integer;
  RC2LineInd1: integer;
  RC2LineInd2: integer;
  Flags: integer;
end;
type TN_BordLines2 = array of TN_BordLine2;

type TN_SortObjPar = record // params of object, which array will be sorted
  LineRC: integer;    // one of Line's Region Code
  EndPoint: TDPoint;  // one of Line's EndPoint coords
  LineInd: integer;   // Line index in BordLines array
  Flags: integer;     // EndPoint and Region Code Flags:
       // bit0 =0 - EndPoint is first point of Line
       // bit0 =1 - EndPoint is Last  point of Line
       // bit1 =0 - LineRC is first Region Code
       // bit1 =1 - LineRC is second Region Code
end;
type TN_SortObjects = array of TN_SortObjPar;
type TN_PSortObjPar = ^TN_SortObjPar;

type TN_ImpDVectDescr = record // Import Data Vector Description
  DVectorType: TN_DVectorType;
  ImpRArray: TK_RArray;
  ImpRAFieldName: string;
  DBFFieldName: string;
end; // type TN_ImpDVectDescr = record
type TN_ImpDVectDescrs = array of TN_ImpDVectDescr;

type TN_WrkImpDVectDescr = record // Wrk Import Data Vector Description
  ImpRAFieldOffset: integer;
  ImpRAFieldSize:   integer;
  DBFFieldOffset:   integer;
  DBFFieldSize:     integer;
end; // type TN_WrkImpDVectDescr = record
type TN_WrkImpDVectDescrs = array of TN_WrkImpDVectDescr;

type TN_ShapeInfo = record // Shape File Info
  SIFileType:   integer; // Shape File Type (Point, Polyline, Polygon, Multipoint)
  SIFileSize:   integer; // Shape File Size in bytes
  SINumRecords: integer; // Whole Number of Records in File
  SINumParts:   integer; // Whole Number of Parts in File
  SINumPoints:  integer; // Whole Number of Points in File
  SIEnvDRect:    TDRect; // File Env Double Rect (Bounds Rect)
end; // type TN_ShapeInfo = record // Shape File Info
type TN_PShapeInfo = ^TN_ShapeInfo;

type TN_ShapeShowFlags = set Of ( ssfSkipDBFHeader,  // Skip showing DBF file Header
                                  ssfSkipDBFRecords, // Skip showing DBF file Header
                                  ssfSkipShape,      // Skip showing info about Shape file (show only DBF related info)
                                  ssfSkipEnvDRect,   // Skip showing info about File and Records Env Rect
                                  ssfSkipSummary,    // Skip showing summary about Shape file
                                  ssfSkipAllCoords,  // Skip showing All Cords (show only Records Headers)
                                  ssfSkipIntCoords   // Skip showing Internal Coords (show only first and last Point)
                                );
var
  N_SkipAllExceptType: TN_ShapeShowFlags = [ ssfSkipDBFHeader, ssfSkipDBFRecords,
                             ssfSkipSummary, ssfSkipAllCoords, ssfSkipIntCoords ];

  N_SkipAllExceptSummary: TN_ShapeShowFlags = [ ssfSkipDBFHeader, ssfSkipDBFRecords,
                                             ssfSkipAllCoords, ssfSkipIntCoords ];

type TN_ShapeImportFlags = set Of ( sifMultiPartItems, // Resulting CObj can be multipart
                                    sifLinesOnly,      // only Polyline Shape file is alowed (not Polygon)
                                    sifConvNXC,        // Conv negative X coords (X := 360 + X)
                                    sifDump1Strings    // Dump resulting strings by N_Dump1Str
                                   );

type TN_SetCodesByTTableProc = procedure( ATable: TTable; ACObj: TN_UCObjLayer; AItemInd: integer );

type TN_ShapeImpParams = record
  SIPPShapeInfo:      TN_PShapeInfo; // pointer to TN_ShapeInfo record to fill (may be nil)
  SIPCObj:            TN_UCObjLayer; // UDPoints or ULines CObj to import (may be nil)
  SIPAffCoefs4:       TN_AffCoefs4;
  SIPSetAllCodesProc: TN_SetCodesByTTableProc; //
  SIPShowFlags:       TN_ShapeShowFlags;
  SIPImportFlags:     TN_ShapeImportFlags;
  SIPOutStrings:      TStrings; // Output strings (may be nil)
  SIPResCode:         Integer;  // Error code as integer
  SIPErrorString:     String;   // Error message
end; // type TN_ShapeImportParams = record
type TN_PShapeImpParams = ^TN_ShapeImpParams;


//************************************* Shape and DBF related procedures *****

procedure N_Reverse4Bytes       ( PInp, POut:  Pointer );
function  N_ShapeTypeToStr      ( AShapeType: integer ): string;
procedure N_AddShapeHeaderInfo  ( ASL: TStrings; AShapeFName: string; AFlags: TN_ShapeShowFlags; APShapeInfo: TN_PShapeInfo = nil );
procedure N_AddDBFHeaderInfo    ( ASL: TStrings; ADBFFName: string; AFlags: TN_ShapeShowFlags );
procedure N_ShowShapeDBFFilesInfo ( AFName: string; AFlags: TN_ShapeShowFlags );
procedure N_SetCodesBySOATO     ( ADBF: TTable; ACObj: TN_UCObjLayer; AItemInd: integer );

procedure N_ImportShape     ( AShapeFName: string; APParams: TN_PShapeImpParams );
procedure N_UDPointsToShape ( UDPoints: TN_UDPoints; ShpFName: string; AffCoefs4: TN_AffCoefs4 );
procedure N_ULinesToShape1  ( ULines: TN_ULines; ShpFName: string; AffCoefs4: TN_AffCoefs4 );
procedure N_ULinesToShape   ( ULines: TN_ULines; ShpFName: string; AShapeType: integer; AffCoefs4: TN_AffCoefs4 );


function  N_KrlbToMem ( KrlbFName, XYFName: string; AffCoefs4: TN_AffCoefs4;
                     var XY: TN_DPArray; var BordLines: TN_BordLines ): integer;
function  N_KrlbToULines ( ULines: TN_ULines; XYFName, KrlbFName: string;
                                            AffCoefs4: TN_AffCoefs4 ): integer;
procedure N_EMFToULines ( ULines: TN_ULines; EMFFName: string;
                             AffCoefs4: TN_AffCoefs4; PlayRectWidth: integer );
procedure N_TdbToUDPoints ( UPoints: TN_UDPoints; FileName, TableName: string;
                                               const AffCoefs4: TN_AffCoefs4 );
procedure N_TdbToULines   ( ULines: TN_ULines; FileName, TableName: string;
                                               const AffCoefs4: TN_AffCoefs4 );
procedure N_TdbToContourCodes( ULines: TN_ULines; FileName, TableName: string );
procedure N_TdbToObjRefs ( BaseCObj: TN_UCObjLayer; RefsCObj: TN_UCObjRefs;
                                                 FileName, TableName: string );
procedure N_TdbToDVector( CObjLayer: TN_UCObjLayer; DVector: TK_UDRArray;
                           FileName, TableName: string; DVectorType: integer );
//procedure N_TdbToObjFields( Layer, LElem: TN_UDBase;
//                          FileName, TableName: string; FieldNum: integer );

//procedure N_DLinesToCBF ( LinesRoot: TN_UDBase;  Flags: integer;
//                CBFFName, SectionName: string; const AffCoefs4: TN_AffCoefs4 );

//procedure N_DLinesToKrlb( LinesDir: TN_UDBase; XYFName, KrlbFName: string;
//                                              const AffCoefs4: TN_AffCoefs4 );

//procedure N_DContoursToShapePolygons( ContoursDir: TN_UDBase;
//                                    ShpFName: string; AffCoefs4: TN_AffCoefs4 );

//procedure N_DLinContsToTdb( LinesRoot, ContoursRoot: TN_UDBase;
//                                   TdbFName: string; AffCoefs4: TN_AffCoefs4 );

//procedure N_DPointsToTdb( PointsRoot: TN_UDBase;
//                                   TdbFName: string; AffCoefs4: TN_AffCoefs4 );

procedure N_SmdToASCII ( SmdFName, ASCIIFName: string);

//function  N_SmdToDLines ( LinesRoot: TN_UDBase; SmdFName: string;
//                        const AffCoefs4: TN_AffCoefs4;
//                        Accuracy: integer; var EnvDRect: TDRect ): integer;

//function  N_SmdToDPoints ( PointsRoot: TN_UDBase; SmdFName: string;
//                        const AffCoefs4: TN_AffCoefs4;
//                        Accuracy: integer; var EnvDRect: TDRect ): integer;
//procedure N_LoadVArray ( Layer: TN_UDBase; FileName, VArrayName: string;
//                                                     VArrayType: integer );

procedure N_SetDVectElem ( PMem: Pointer; ElemStr: string;
                                             DVectorType: TN_DVectorType );
function  N_DBFToRArrays ( DBFFileName: string;
                                ADVectDescrs: TN_ImpDVectDescrs ): integer;

procedure N_ActionImportMIF1 ( APParams: TN_PCAction; AP1, AP2: Pointer );

function  N_ConvRus89ToFOkrug ( ACode: integer ): integer;
function  N_CreateTTableByDBF ( AFileName: string ): TTable;
procedure N_PrepParaBoxesByPoints ( APatPB: TN_UDParaBox; AParent: TN_UDBase; AFont: TObject; AParStr: string; AUDPoints: TN_UDPoints; AIntPar: integer = 0; APTexts: PString = nil );


//************************ Old obsolete Procedures:
procedure N_GetShapeInfo        ( AShapeFName: string; APShapeInfo: TN_PShapeInfo );
procedure N_AddShapeHeaderInfo1 ( SL: TStrings; ShapeFName: string; AFlags: integer );
procedure N_ShapeToASCII        ( ShapeFName, ASCIIFName: string; Accuracy: integer; AFlags: TN_ShapeShowFlags );
procedure N_ShapeToASCII2       ( ShapeFName, ASCIIFName: string; Accuracy: integer );
procedure N_ShapeToUDPoints     ( UDPoints: TN_UDPoints; ShapeFName: string;
                                  const AffCoefs4: TN_AffCoefs4; AMode: integer;
                                  ASetAllCodesProc: TN_SetCodesByTTableProc );
procedure N_ShapeToULines       ( ULines: TN_ULines; ShapeFName: string;
                                  const AffCoefs4: TN_AffCoefs4; Mode: integer );

//************************ End of Old obsolete Procedures

var
  N_EMFRecordsCounter: integer;


{$WARN UNIT_PLATFORM OFF}
implementation
uses SysUtils, StrUtils, Dialogs, Math, Controls, Contnrs, FileCtrl,
  K_VFunc, K_CLib0, K_DCSpace,
  N_Lib0, N_ClassRef, N_Lib1, N_Deb1, N_DBF, //
  N_PlainEdF, N_RichEdF, N_MsgDialF, N_InfoF, N_ME1, N_UDCMap, N_NVTreeFr;


//********************************* Shape and DBF related procedures *****

//*********************************************** procedure N_Reverse4Bytes ***
// Reverse four Bytes in given integer
//
//     Parameters
// PInp - Pointer to source integer
// POut - Pointer to resulting integer with reversed bytes
//
// Used in parsing Shape files. In ESRI documentation (in shapefile.pdf)
// "Little" means Intel bytes order (least byte is first) and "Big" means
// reversed byte order - all bytes "Big" format fields should be reversed.
//
procedure N_Reverse4Bytes( PInp, POut: Pointer );
// write to POut pointer four bytes from PInp pointer in reverse order
// ()
begin
  (TN_BytesPtr(POut))^   := (TN_BytesPtr(PInp)+3)^;
  (TN_BytesPtr(POut)+1)^ := (TN_BytesPtr(PInp)+2)^;
  (TN_BytesPtr(POut)+2)^ := (TN_BytesPtr(PInp)+1)^;
  (TN_BytesPtr(POut)+3)^ := (TN_BytesPtr(PInp))^;
end; // procedure N_Reverse4Bytes

//******************************************************** N_ShapeTypeToStr ***
// Convert given integer Shape type to string Type Name
//
//     Parameters
// AShapeType - Given integer Shape type
// Result     - Return string Type Name
//
function N_ShapeTypeToStr( AShapeType: integer ): string;
begin
  case AShapeType of
    N_ShapeNull:       Result := 'Null Shape'; // 0,  Null Shape Record
    N_ShapePoint:      Result := 'Point';      // 1, Point Shape Record and File
    N_ShapePolyLine:   Result := 'PolyLine';   // 3, PolyLine Shape Record and File
    N_ShapePolygon:    Result := 'Polygon';    // 5, Polygon Shape Record and File
    N_ShapeMultiPoint: Result := 'MultiPoint'; // 8, MultiPoint Shape Record and File
  else
    Result := Format( 'Unknown Type (%d)', [AShapeType] );
  end; // case AShapeType of
end; // function N_ShapeTypeToStr

//**************************************************** N_AddShapeHeaderInfo ***
// Add to given SL (TStrings obj) info lines about given Shape file
//
//     Parameters
// ASL         - given TStrings obj where to add strings
// AShapeFName - Shape file Full Name,
// AFlags      - what info is not needed flags
// APShapeInfo - pointer to Shape file Params struct to fill (may be nil is not needed)
//
procedure N_AddShapeHeaderInfo( ASL: TStrings; AShapeFName: string; AFlags: TN_ShapeShowFlags; APShapeInfo: TN_PShapeInfo = nil );
var
  ShapeTypeStr: string;
  ShapeInfo: TN_ShapeInfo;
  Params: TN_ShapeImpParams;
  Label Fin;
begin
  N_ImportShape( '', @Params ); // fill Params by default values
  Params.SIPPShapeInfo := @ShapeInfo;
  Params.SIPShowFlags  := AFlags;

  N_ImportShape( AShapeFName, @Params ); // fill ShapeInfo record

  with ShapeInfo do
  begin
    if (SIFileType = N_ShapeNoFile) or (SIFileType = N_ShapeBadFile) then
      goto Fin;

    ShapeTypeStr := N_ShapeTypeToStr( SIFileType );
    if ASL <> nil then
      ASL.Add( Format( 'Shape File: "%s" (%s), %.1f Kb, NRecs=%d, NParts=%d, NPoints=%d',
                          [AShapeFName, ShapeTypeStr, 1.0*SIFileSize/1024,
                           SINumRecords, SINumParts, SINumPoints] ) );

    if not (ssfSkipEnvDRect in AFlags) then // add EnvRect info
    begin
      with SIEnvDRect do
        if ASL <> nil then
          ASL.Add( Format( ' EnvRect: ( XMin=%.3e, YMin=%.3e, XMax=%.3e, YMax=%.3e )',
                                         [Left, Top, Right, Bottom] ) );
    end;

  end; // with ShapeInfo do

  Fin: //***********************

  if APShapeInfo <> nil then // fill APShapeInfo^ if needed
    move( ShapeInfo, APShapeInfo^, SizeOf(ShapeInfo) );

end; // procedure N_AddShapeHeaderInfo

//****************************************************** N_AddDBFHeaderInfo ***
// Add to given Strings info about given DBF file header
//
//     Parameters
// ASL       - given TStrings obj where to add strings
// ADBFFName - DBF Full File Name,
// AFlags    - what info is not needed flags (not yet)
//
// Direct DBF file parsing is used without usin TTable object fynctionality
//
procedure N_AddDBFHeaderInfo( ASL: TStrings; ADBFFName: string; AFlags: TN_ShapeShowFlags );
var
  i: integer;
  Fh: File;
  Str, SBuf: string;
  DBF: TN_DBF;
begin
  if not FileExists( ADBFFName ) then Exit;

  AssignFile( Fh, ADBFFName );
  N_i := FileMode;
  FileMode := 0; // set read only mode
  Reset     ( Fh, 1 );
  FileMode := N_i; // rstore previous value

  if FileSize(Fh) < Sizeof(TN_DBFHField) then // needed for dummy empty files
  begin
    Close( Fh );
    Exit;
  end;

  DBF := TN_DBF.Create;

  with DBF do
  begin
    //*** load Header
    BlockRead ( Fh, Header[0], Sizeof(TN_DBFHField) ); // read Header[0]
    SetLength( Header, Round( Header[0].RecPos / Sizeof(TN_DBFHField) ) );
    if Header[0].RecPos > Sizeof(TN_DBFHField) then
      BlockRead ( Fh, Header[1], Header[0].RecPos - Sizeof(TN_DBFHField) - 1 );

    ASL.Add( Format( 'DBF File: "%s", Size (in Kb): %.1f, NumRecords: %d',
                         [ADBFFName, FileSize(Fh)/1024, Header[0].RecCount] ) );

    Str := '';
    for i := 1 to High(Header) do
    begin
      with Header[i] do
      begin
        if FieldPrec = 0 then SBuf := ''
                         else SBuf := '.' + IntToStr( FieldPrec );
        SBuf := Format( '%s %d%s%s,  ',
                              [FieldName, FieldSize, SBuf, FieldType] );

        if Length(Str) + Length(SBuf) < 80 then
          Str := Str + SBuf
        else
        begin
          ASL.Add( Str );
          Str := SBuf;
        end;
      end; // with Header[i] do
    end; // for i := 1 to High(Header) do

    ASL.Add( Str );
  end; // with DBF do

  DBF.Free;
  Close( Fh );
end; // procedure N_AddDBFHeaderInfo

//************************************************* N_ShowShapeDBFFilesInfo ***
// Save to file "!ShapeAndDBFHeaders.txt" info about all Shape and DBF files
// in given Directory
//
//     Parameters
// AFName - any File Name in needed Directory (may be dummy, only path to it is used)
// AFlags - show flags (N_AddDBFHeaderInfo and N_AddShapeHeaderInfo parameter)
//
procedure N_ShowShapeDBFFilesInfo( AFName: string; AFlags: TN_ShapeShowFlags );
var
  i: integer;
  SL: TStringList;
  FAObjList: TObjectList;
  DirName, FName: string;
begin
  Screen.Cursor := crHourGlass;
  DirName := ExtractFilePath( AFName );
  FAObjList := nil;
  N_AddFilesAttribs( DirName + '*.*', 1, FAObjList );
  SL := TStringList.Create;

  for i := 0 to FAObjList.Count-1 do
  with TN_FileAttribs(FAObjList[i]) do
  begin
    N_Dump1Str( 'Strt Processing ' + FullName );

    if UpperCase(ExtractFileExt( FullName )) = '.DBF' then
    begin
      N_AddDBFHeaderInfo( SL, FullName, AFlags );
      SL.Add( '' );
    end;
    if UpperCase(ExtractFileExt( FullName )) = '.SHP' then
    begin
      N_AddShapeHeaderInfo( SL, FullName, AFlags );
      SL.Add( '' );
    end;
  end;

  FAObjList.Free;
  FName := DirName + '!ShapeAndDBFHeaders.txt';
  SL.SaveToFile( FName );
  SL.Free;
  N_StateString.Show( FName + ' Created OK' );
  Screen.Cursor := crDefault;
end; // procedure N_ShowShapeDBFFilesInfo

//*************************************************** N_ShapeHeadersToASCII ***
// Convert given Shape file to ASCII file (convert full info)
//
//     Parameters
// ShapeFName - Source Shape file Name,
// ASCIIFName - Resulting ASCII file Name
// Accuracy   - number of decimal digits in coords representation
// AFlags     - what info is not needed flags
//
procedure N_ShapeHeadersToASCII( ShapeFName, ASCIIFName: string; Accuracy: integer; AFlags: TN_ShapeShowFlags );
begin

end; // procedure N_ShapeHeadersToASCII

//******************************************************* N_SetCodesBySOATO ***
// Set All Codes to given ACObj AItemInd by COATO field in given ADBF Object
//
//     Parameters
// ATable   - given TTable Object used to access needed DBF File
// ACObj    - given ACObj
// AItemInd - given ACObj Item Index
//
// ADBF Objects should be properly positioned on needed Table Record
// Can be used as SIPSetAllCodesProc in importing Shape files procedures
//
procedure N_SetCodesBySOATO( ADBF: TTable; ACObj: TN_UCObjLayer; AItemInd: integer );
//var
//  ACodes: TN_IArray;
begin
//    with DBF.Fields.Fields[i] do
    begin
//      Str := Str + FieldName + '=' + asString + '  ';
    end;

end; // procedure N_SetCodesBySOATO

//*********************************************************** N_ImportShape ***
// Import Shape file to given CObj or to text strings
//
//     Parameters
// AShapeFName - Source Shape file Name
// APParams    - Import Params
//
procedure N_ImportShape( AShapeFName: string; APParams: TN_PShapeImpParams );
var
  Header: array[0..99] of byte;
  SHXRecord, SHPRecordHeader: array[0..7] of byte;

  Content: TN_BArray;
  ContentSize, FileShapeType, RecordShapeType, NumParts, NumPoints: integer;
  i, j, ij, n, ItemInd, NextInt, BegPointInPartInd, FileCode: integer;
  NumPointsInPart, MaxParts, RecordNumber, SHXNumRecords: integer;
  SHPSelfLeng, SHPStreamLeng, SHXSelfLeng, SHXStreamLeng: integer;
  MaxPointsInRecord, MaxPointsInPart, TotalPoints, TotalParts: integer;
  SHXOfs, SHXRecSize: integer;
  ACCSize: integer;
  EnableMultiParts: boolean;
  X,Y: double;
  ACC: TN_DPArray;
  ULines: TN_ULines;
  UDPoints: TN_UDPoints;
  LItem: TN_ULinesItem;
  UseDBF, UseAddStr: boolean;
  ShapeTypeStr, SHXFName: string;
  DBF: TTable;
  CurField: TField;
  Str, TmpName, DBFFileName, FieldTypeStr: string;
  FileEnvDRect, RecordEnvDRect: TDRect;
  FSSHP, FSSHX: TFileStream;
  WrkShowFlags: TN_ShapeShowFlags;
  Label Fin;

  procedure AddStr( AStr: string ); // local
  // add given string to SIPOutStrings and to Dump1 if needed
  begin
    with APParams^ do
    begin
      if SIPOutStrings <> nil then
        SIPOutStrings.Add( AStr );

      if sifDump1Strings in SIPImportFlags then
        N_Dump1Str( AStr );
    end; with APParams^ do
  end; // procedure AddStr - local

  procedure AddErrStr( AStr: string ); // local
  // add given string to Dump2, SIPOutStrings and to Dump1 if needed
  begin
    N_Dump2Str( AStr );
    AddStr( AStr );
  end; // procedure AddErrStr - local

  procedure AddCurItemCodes(); // local
  // Set all codes to current CObj Item if needed and increment ItemInd
  begin
    with APParams^ do
    begin
      if Assigned( SIPSetAllCodesProc ) and (SIPCObj <> nil) then
        SIPSetAllCodesProc( DBF, SIPCObj, ItemInd );

      Inc( ItemInd );
    end; with APParams^ do
  end; // procedure AddCurItemCodes - local

begin
  if AShapeFName = '' then // just initialize APParams^ and exit
  begin
    FillChar( APParams^, SizeOf(APParams^), 0 );
    APParams^.SIPAffCoefs4 := N_DefAffCoefs4; // the only non zero default value
    Exit;
  end; // if AShapeFName = '' then // just initialize APParams^ and exit

  with APParams^ do
  begin

  //***** to awoid warnings and for correct free objects after Fin Label
  UseDBF := False;
  DBF    := nil;
  FSSHP    := nil;
  FSSHX    := nil;
  LItem    := nil;
  ULines   := nil;
  UDPoints := nil;

  //***** add some skip show flags to simplify code
  WrkShowFlags := SIPShowFlags;

  if ssfSkipShape in WrkShowFlags then
    WrkShowFlags := WrkShowFlags + [ssfSkipEnvDRect,ssfSkipSummary,ssfSkipAllCoords,ssfSkipIntCoords];

  if ssfSkipAllCoords in WrkShowFlags then
    WrkShowFlags := WrkShowFlags + [ssfSkipIntCoords];

  UseAddStr := (SIPOutStrings <> nil) or (sifDump1Strings in SIPImportFlags); // to simplify code

  //***** Check Shape file Header

  if not FileExists( AShapeFName ) then
  begin
    SIPResCode := 1;
    SIPErrorString := 'Error: File  "' + AShapeFName + '"  is absent';
    AddErrStr( SIPErrorString );

    if SIPPShapeInfo <> nil then
      SIPPShapeInfo^.SIFileType := N_ShapeNoFile;

    goto Fin;
  end; // if not FileExists( AShapeFName ) then

  FSSHP := TFileStream.Create( AShapeFName, fmOpenRead );
  SHPStreamLeng := FSSHP.Size;

  FSSHP.Read( Header[0], SizeOf(Header) ); // read Shape file Header
  N_Reverse4Bytes( @Header[0],  @FileCode );
  N_Reverse4Bytes( @Header[24], @SHPSelfLeng ); // length in Words, not bytes

  if FileCode <> 9994 then
  begin
    SIPResCode := 2;
    SIPErrorString := Format( 'Error: Bad shp file code=%d (not 9994)!', [FileCode] );
    AddErrStr( SIPErrorString );

    if SIPPShapeInfo <> nil then
      SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

    goto Fin;
  end; // if FileCode <> 9994 then

  if 2*SHPSelfLeng <> SHPStreamLeng then
    AddErrStr( Format( ' Different shp Sizes: Stream=%d, InHeader=%d', [SHPStreamLeng,2*SHPSelfLeng] ) );

  move( Header[32], FileShapeType, 4 );
  ShapeTypeStr := N_ShapeTypeToStr( FileShapeType );

  //***** Check .shx file Header

  SHXFName := ChangeFileExt( AShapeFName, '.shx' );

  if not FileExists( SHXFName ) then
  begin
    SIPResCode := 3;
    SIPErrorString := 'Error: File  "' + SHXFName + '"  is absent';
    AddErrStr( SIPErrorString );

    if SIPPShapeInfo <> nil then
      SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

    goto Fin;
  end; // if not FileExists( SHXFName ) then

  FSSHX := TFileStream.Create( SHXFName, fmOpenRead );
  SHXStreamLeng := FSSHX.Size;

  FSSHX.Read( Header[0], SizeOf(Header) ); // read Shape file Header
  N_Reverse4Bytes( @Header[0], @FileCode );
  N_Reverse4Bytes( @Header[24], @SHXSelfLeng ); // length in Words, not bytes

  if FileCode <> 9994 then
  begin
    SIPResCode := 4;
    SIPErrorString := Format( 'Error: Bad shx file code=%d (not 9994)!', [FileCode] );
    AddErrStr( SIPErrorString );

    if SIPPShapeInfo <> nil then
      SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

    goto Fin;
  end; // if FileCode <> 9994 then

  if 2*SHXSelfLeng <> SHXStreamLeng then
    AddErrStr( Format( ' Different shx Sizes: Stream=%d, InHeader=%d', [SHXStreamLeng,2*SHXSelfLeng] ) );

  //***** Calc Number of Shape Records by shx file size

  SHXNumRecords := (SHXStreamLeng - SizeOf(Header)) div 8;

  //***** Show Shape Main info

  if not (ssfSkipShape in WrkShowFlags) then // Show File Name and Type
    AddStr( ' Input  file: ' + AShapeFName + ', ' +
                              ShapeTypeStr + ' (' + IntToStr(FileShapeType) + '), ' +
                              IntToStr(SHXNumRecords) + ' Records' );

  //***** Show Bounds Rect if needed

  if not (ssfSkipEnvDRect in WrkShowFlags) then // Show Bound Rect
  begin
    move( Header[36], FileEnvDRect, SizeOf(FileEnvDRect) );
    AddStr( Format( ' Box Rect: ( XMin=%g, XMax=%g, YMin=%g, YMax=%g )',
                [ FileEnvDRect.Left, FileEnvDRect.Right, FileEnvDRect.Top,  FileEnvDRect.Bottom ] ) );

    AddStr( '' );
  end; // if not (ssfSkipEnvDRect in WrkShowFlags) then // Show Bound Rect


  //***** Open and Show DBF Header if needed

  UseDBF := not (ssfSkipDBFHeader in WrkShowFlags) or
            not (ssfSkipDBFRecords in WrkShowFlags) or
            Assigned(SIPSetAllCodesProc);

  if UseDBF then // Create DBF TTable objects
    DBF := N_CreateTTableByDBF( ChangeFileExt( AShapeFName, '.dbf' ) );

  if UseDBF and not (ssfSkipDBFHeader in WrkShowFlags) then // Show DBF Header (All fields names and types)
  with DBF do
  begin
    AddStr( Format( 'DBF: RecordCount=%d, RecordSize=%d, NumFields=%d', [RecordCount, RecordSize, FieldCount] ) );

    if SHXNumRecords <> RecordCount then
      AddErrStr( Format( '    Different Number of Records: in DBF=%d, in shx=%d', [RecordCount,SHXNumRecords] ) );

    for i := 1 to FieldCount do // along all fields
    begin
      CurField := Fields.FieldByNumber( i );
      with CurField do
      begin
        case DataType of
          ftString:  FieldTypeStr := 'String';
          ftInteger: FieldTypeStr := 'Integer';
          ftFloat:   FieldTypeStr := 'Float';
        else
          FieldTypeStr := '=' + IntToStr(Integer(DataType));
        end; // case DataType of

        AddStr( Format( '  %02d %9s Size=%02d  %s', [i,FieldTypeStr,DisplayWidth,FieldName] ) );
      end;
    end; // for i := 1 to FieldCount do // along all fields

    AddStr( '' );
  end; // if not (ssfSkipDBFHeader in WrkShowFlags) then // Show DBF Header (All fields names and types)


  //***** Initialize variables

  MaxParts    := 0;
  TotalPoints := 0;
  TotalParts  := 0;
  MaxPointsInRecord := 0;
  MaxPointsInPart   := 0;
  RecordNumber := 0; // to avoid warning
  SetLength( Content, 10000 );
  SetLength( ACC, 1); // used for importing Cobj coords
  ItemInd := 0; // Initial Item Ind value

  //***** Prepare Cobj for importing (if needed)

  if SIPCObj <> nil then // SIPCObj is given
  begin

    if SIPCObj is TN_ULines then
    begin
      ULines := TN_ULines(SIPCObj); // just to simplify code
      LItem := TN_ULinesItem.Create( ULines.WLCType );
      NumPoints := Round( SHPStreamLeng / 16 );                  // approximation
      ULines.InitItems( Min( 1000, SHXNumRecords ), NumPoints ); // approximation
    end; // if SIPCObj is TN_ULines then

    if SIPCObj is TN_UDPoints then
    begin
      UDPoints := TN_UDPoints(SIPCObj); // just to simplify code
      NumPoints := Round( SHPStreamLeng / 16 );                    // approximation
      UDPoints.InitItems( Min( 1000, SHXNumRecords ), NumPoints ); // approximation

      //****** Importing multipart UDPoints Items is not implemented !!!

      if sifMultiPartItems in SIPImportFlags then
      begin
        SIPResCode := 5;
        SIPErrorString := 'Importing multipart UDPoints Items is not implemented!';
        AddErrStr( SIPErrorString );

        if SIPPShapeInfo <> nil then
          SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

        goto Fin;
      end; // if sifMultiPartItems in SIPImportFlags) then

    end; // if SIPCObj is TN_ULines then

  end; // if SIPCObj <> nil then // SIPCObj is given


  //***** Main Loop along all .shx file records (along all shape records)

  for n := 1 to SHXNumRecords do // along all Shape Records
  begin
    N_StateString.Show( Format( 'Importing Shape record %d of %d', [n,SHXNumRecords] ));

    //***** Read and check .shp and .shx records consistancy

    FSSHX.Read( SHXRecord[0], SizeOf(SHXRecord) ); // read shx record
    N_Reverse4Bytes( @SHXRecord[0], @SHXOfs );     // in Words
    N_Reverse4Bytes( @SHXRecord[4], @SHXRecSize ); // in Words
    SHXOfs := 2*SHXOfs; //  conv from Words to Bytes

    FSSHP.Seek( SHXOfs, soFromBeginning );
    FSSHP.Read( SHPRecordHeader[0], SizeOf(SHPRecordHeader) ); // read shp record header
    N_Reverse4Bytes( @SHPRecordHeader[0], @RecordNumber );
    N_Reverse4Bytes( @SHPRecordHeader[4], @ContentSize ); // in Words

    if RecordNumber <> n then // Record Number Error
    begin
      SIPResCode := 6;
      SIPErrorString := Format( 'Record Number Error: SHX=%d, SHP=%d', [n,RecordNumber] );
      AddErrStr( SIPErrorString );

      if SIPPShapeInfo <> nil then
        SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

      Break;
    end; // if RecordNumber <> n then // Record Number Error

    if SHXRecSize <> ContentSize then // Record Size Error
    begin
      SIPResCode := 7;
      SIPErrorString := Format( 'Record Size Error: SHX=%d, SHP=%d', [SHXRecSize,ContentSize] );
      AddErrStr( SIPErrorString );

      if SIPPShapeInfo <> nil then
        SIPPShapeInfo^.SIFileType := N_ShapeBadFile;

      Break;
    end; // if SHXRecSize <> ContentSize then // Record Size Error

    ContentSize := 2*ContentSize; // conv from Words to Bytes

    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + Length(Content) div 2 );

    FSSHP.Read( Content[0], ContentSize ); // read shp record body
    move( Content[0], RecordShapeType, 4 );

    if (RecordShapeType <> N_ShapeNull) and (RecordShapeType <> FileShapeType) then
      AddErrStr( Format( '    Different Shape Types: in Header=%d, in Record=%d', [FileShapeType,RecordShapeType] ) );


    //***** Show DBF record if needed

    if (DBF <> nil) and
       not (ssfSkipDBFRecords in WrkShowFlags) then // Show all DBF Fields values in cur record
    begin
      if n > 1 then // to next DBF record
        DBF.Next;

      Str := Format( 'DBF: Record=%03d ', [n] );

      for i := 0 to DBF.Fields.Count-1 do
        with DBF.Fields.Fields[i] do
        begin
          Str := Str + FieldName + '=' + asString + '  ';
        end;

      AddStr( Str );
    end; // if ... then // Show cur record


    //***** Process current shape record

    case RecordShapeType of

    N_ShapeNull: //******************************* 0, NULL Record
    begin
      Continue;
    end;

    N_ShapePoint: //****************************** 1, One Point Record
    begin
      Inc( TotalPoints );
      Inc( TotalParts );

      MaxParts          := 1;
      MaxPointsInRecord := 1;
      MaxPointsInPart   := 1;

      move( Content[4],  X,  8 );
      move( Content[12], Y,  8 );

      if sifConvNXC in SIPImportFlags then // Conv Negative X Coords (-179 -> +181)
        if X < 0 then
          X := 360 + X;

      ACC[0].X := SIPAffCoefs4.CX*X + SIPAffCoefs4.SX;
      ACC[0].Y := SIPAffCoefs4.CY*Y + SIPAffCoefs4.SY;

      if UDPoints <> nil then
        UDPoints.AddOnePointItem( ACC[0], -1 );

      AddCurItemCodes(); // Set all codes to current CObj Item if needed

      if UseAddStr and not (ssfSkipAllCoords in WrkShowFlags) then
        AddStr( Format( '  Record=%03d  X=%g Y=%g', [n, X, Y] ) );

      Continue;
    end; // N_ShapePoint

    N_ShapePolyLine, //*************************** 3, Polyline Record
    N_ShapePolygon:  //*************************** 5, Polygon Record
    begin
      move( Content[4], RecordEnvDRect, SizeOf(RecordEnvDRect) );
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );

      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );

      MaxParts          := max( MaxParts, NumParts );
      MaxPointsInRecord := max( MaxPointsInRecord, NumPoints );

      ACCSize := NumPoints + 20;
      if Length(ACC) < ACCSize then
        SetLength( ACC, N_NewLength(ACCSize) );

      if LItem <> nil then
        LItem.Init();

      if not (ssfSkipShape in WrkShowFlags) then
        with RecordEnvDRect do
          AddStr( Format( '   Polyline of %d parts, %d points, Box=(%g, %g, %g, %g)',
                              [NumParts, NumPoints, Left, Top, Right, Bottom] ) );

      ij := 0;

      for i := 0 to NumParts-1 do // loop along Parts
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 ); // next part index or not used if last pert

        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        MaxPointsInPart := max( MaxPointsInPart, NumPointsInPart );

        for j := 0 to NumPointsInPart-1 do // loop along Points in current Part
        begin
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)],   X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );

          if sifConvNXC in SIPImportFlags then // Conv Negative X Coords (-179 -> +181)
            if X < 0 then
              X := 360 + X;

          ACC[j].X := SIPAffCoefs4.CX*X + SIPAffCoefs4.SX;
          ACC[j].Y := SIPAffCoefs4.CY*Y + SIPAffCoefs4.SY;

          if (ssfSkipAllCoords in WrkShowFlags) then
            Continue; // skip showing all coords

          if (ssfSkipIntCoords in WrkShowFlags) and (j > 0) and (j < (NumPointsInPart-1)) then
            Continue; // skip showing internal coords

          // n-Record, i-Part, j-Point In Part, ij=Point in Record
          if UseAddStr then
            AddStr( Format( '  %03d %02d %04d (%04d)  %g  %g', [n, i, j, ij, X, Y] ) );

          Inc( ij );
        end; // for j := 0 to NumPointsInPart do

        if LItem <> nil then
          LItem.AddPartCoords( ACC, 0, NumPointsInPart );

        if (ULines <> nil) and (LItem <> nil) and
           not (sifMultiPartItems in SIPImportFlags) then // import all part as separate single part Items
        begin
          ULines.ReplaceItemCoords( LItem, -1,  -1, -1, -1 );
          AddCurItemCodes(); // Set all codes to current CObj Item if needed
          LItem.Init();
        end;

        if not ( (ssfSkipAllCoords in WrkShowFlags) or
                 (ssfSkipIntCoords in WrkShowFlags) ) then
          AddStr( '' ); // records separator
      end; // for i := 0 to NumParts-1 do

      if (ULines <> nil) and (LItem <> nil) and
         (sifMultiPartItems in SIPImportFlags) then // create new Item (multipart if NumParts > 1)
      begin
        ULines.ReplaceItemCoords( LItem, -1,  -1, -1, -1 );
        LItem.Init();
        AddCurItemCodes(); // Set all codes to current CObj Item if needed
      end;

      Continue;
    end; // case N_ShapePolyLine, N_ShapePolygon (3,5): - Polyline or Polygon Record


    N_ShapeMultiPoint: //************************* 8, MultiPoint Record
    begin
      //****** Importing multipart UDPoints Items are not implemented !!!
      move( Content[36], NumPoints,  4 );

      Inc( TotalPoints, NumPoints );
      Inc( TotalParts );

      MaxParts          := 1;
      MaxPointsInRecord := max( MaxPointsInRecord, NumPoints );
      MaxPointsInPart   := max( MaxPointsInPart, NumPoints );

      for i := 0 to NumPoints-1 do // loop along all Points in Record
      begin
        move( Content[40+i*16],   X,  8 );
        move( Content[40+i*16+8], Y,  8 );

        if sifConvNXC in SIPImportFlags then // Conv Negative X Coords (-179 -> +181)
          if X < 0 then
            X := 360 + X;

        ACC[0].X := SIPAffCoefs4.CX*X + SIPAffCoefs4.SX;
        ACC[0].Y := SIPAffCoefs4.CY*Y + SIPAffCoefs4.SY;

        if UDPoints <> nil then
          UDPoints.AddOnePointItem( ACC[0], -1 );

        AddCurItemCodes(); // Set all codes to current CObj Item if needed
      end; // for i := 0 to NumPoints-1 do // loop along all Points in Record

      Continue;
    end; // N_ShapeMultiPoint

    else // Unknown Record Type
      AddErrStr( Format( '    Unknown Record Type =%d', [RecordShapeType] ) );
    end; // case RecordShapeType of


//    if (DBF <> nil) then // to next DBF record
//      DBF.Next;
  end; // for n := 1 to SHXNumRecords do // along all Shape Records

  if SIPCObj <> nil then
    SIPCObj.CalcEnvRects();

  if not (ssfSkipSummary in WrkShowFlags) then // Show Shape coords Summary
  begin
    AddStr( '' );
    AddStr( Format( '  Total Points  = %d', [TotalPoints] ) );
    AddStr( Format( '  Total Parts   = %d', [TotalParts]  ) );
    AddStr( Format( '  Total Records = %d', [RecordNumber]    ) );
    AddStr( '' );
    AddStr( Format( '  Max Parts  in Record = %d', [MaxParts]    ) );
    AddStr( Format( '  Max Points in Record = %d', [MaxPointsInRecord]  ) );
    AddStr( Format( '  Max Points in Part   = %d', [MaxPointsInPart]  ) );
    AddStr( '' );
    AddStr( Format( '  Average Points in Part   = %d',
                                      [Round(1.0*TotalPoints/TotalParts)] ) );
  end; // if not (ssfSkipSummary in WrkShowFlags) then // Show Summary

  //***** Add trailing 'End of file' string if needed

  if not ( (ssfSkipDBFRecords in WrkShowFlags) or
           (ssfSkipAllCoords  in WrkShowFlags) or
           (ssfSkipIntCoords  in WrkShowFlags)  ) then // Show trailing 'End of file' string
  begin
    AddStr( '' );
    AddStr( 'End of file' );
  end; // if not ... then // Show trailing 'End of file' string

  if SIPPShapeInfo <> nil then // fill given ShapeInfo record
  with SIPPShapeInfo^ do
  begin
    SIFileType   := FileShapeType; // Shape File Type (Point, Polyline, Polygon, Multipoint)
    SIFileSize   := SHPStreamLeng; // Shape File Size in bytes
    SINumRecords := SHXNumRecords; // Whole Number of Records in File
    SINumParts   := TotalParts;    // Whole Number of Parts in File
    SINumPoints  := TotalPoints;   // Whole Number of Points in File
    SIEnvDRect   := FileEnvDRect;      // File Env Double Rect (Bounds Rect)
  end; // if SIPPShapeInfo <> nil then // fill given ShapeInfo record

  Fin: //*********************** Free all objects

  if UseDBF then // Free DBF TTable objects
  begin
    DBF.Close;
    DBF.Free;
  end; // if UseDBF then // Free DBF TTable objects

  FSSHP.Free;
  FSSHX.Free;
  LItem.Free;

  end; // with APParams^ do
end; // procedure N_ImportShape

//******************************************************* N_UDPointsToShape ***
// Convert UDPoints to ArcView Point Theme (create shp, shx, dbf files)
//
// UDPoints  - given UDPoints object
// ShpFName  - Shape full file name (with .shp extention),
// AffCoefs4 - affine trnasformation coefs
//
// MultiPoint records are not implemented!
//
procedure N_UDPointsToShape( UDPoints: TN_UDPoints; ShpFName: string; AffCoefs4: TN_AffCoefs4  );
var
  FShpH, FShxH: integer;
  DBF: TN_DBF;
  DataBuf: TK_DataBuf;
  Header: array[0..99] of byte;
  Content: array[0..99] of byte; // without coords
  i, j, k, MaxK, RecordNumber: integer;
  DC: TN_DPArray;
  FileLeng, RecordSize: integer;
  XY: TN_DPArray;
  Fname: string;
  FileEnvDRect: TDRect; // Double Rect, not Float!
  ShpShx: TPoint;
begin
  DBF := TN_DBF.Create;
  DBF.AddField( 'ID',   'N', 8 );
  DBF.AddField( 'Code', 'N', 9 );

  //**************** Create .SHP file and position it after Header
  FShpH := FileCreate( ShpFName );
  FileSeek( FShpH, 100, 0 );

  //**************** Create .SHX file and position it after Header
  Fname := ChangeFileExt( ShpFName, '.shx' );
  FShxH := FileCreate( FName );
  FileSeek( FShxH, 100, 0 );

  RecordNumber := 1; // Shape record number
  SetLength( XY, 1000 );
  FileEnvDRect.Left := N_NotADouble; // set "not initialized" flag (Double!)

  MaxK := UDPoints.WNumItems-1;

  DBF.AddRecords( MaxK+1 );

  for k := 0 to MaxK do // loop along all Items (only One point Items are implemented)
  begin
    SetLength( DC, 1);
    DC[0] := UDPoints.GetPointCoords( k, 0 );

    N_StateString.Show( 'Points to Shape: ', k/(MaxK+1) );

                    //***** form and write SHX record
    j := FileSeek( FShpH, 0, 1 ) div 2; // j is used as tmp integer
    N_Reverse4Bytes( @j, @ShpShx.X ); // Shp record header offset in words
    // RecordSize is Shp record size in words and Shx record size field
    RecordSize := ( 4 + sizeof(TDPoint) ) div 2; // in words
    N_Reverse4Bytes( @RecordSize, @ShpShx.Y ); // ShpShx.Y is used in Shp too
    FileWrite( FShxH, ShpShx, sizeof(ShpShx) ); // write Shx record
    //***** SHX record is OK

                    //***** form and write SHP record Header
    N_Reverse4Bytes( @RecordNumber, @ShpShx.X ); // Shp record number
             // ( ShpShx.Y field is common for Shx records and Shp header )
    FileWrite( FShpH, ShpShx, sizeof(ShpShx) ); // write Shp record header

                    //***** form and write SHP record Content
    j := N_ShapePoint;
    move( j, Content[0], sizeof(integer) ); // Point Record Shape type

    SetLength( XY, 1);
    XY[0].X := AffCoefs4.CX*DC[0].X + AffCoefs4.SX;
    XY[0].Y := AffCoefs4.CY*DC[0].Y + AffCoefs4.SY;
    N_IncEnvRect( FileEnvDRect, XY[0] );

    FileWrite( FShpH, Content[0], 4 ); // Shp record content without one point coords
    FileWrite( FShpH, XY[0], sizeof(TDPoint) ); // one point coords
    //***** SHP record header and content are OK

    DBF.SetCurField( 'ID' );
    DataBuf.IData := k;
    DBF.SetCurFieldValue ( k, DataBuf );
    DBF.SetCurField( 'Code' );
    UDPoints.GetItemTwoCodes( k, 0, DataBuf.IData, N_i );
    DBF.SetCurFieldValue ( k, DataBuf );

    Inc(RecordNumber);
  end; // for k := 0 to MaxK do // loop along all Lines

  //***** Shp and Shx files are OK ecxept of theirs headers.
  //      Prepare and write SHP file header

  FillChar( Header[0], 100, 0 );
  i := 9994; // SHP File Code
  N_Reverse4Bytes( @i, @Header[0] );

  FileLeng := FileSeek( FShpH, 0, 1 ) div 2; // SHP file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  i := 1000; // Shape format Version
  move( i, Header[28], SizeOf(integer) );

  i := N_ShapePoint;
  move( i, Header[32], SizeOf(integer) ); // Point File Shape type

  move( FileEnvDRect, Header[36], SizeOf(FileEnvDRect) );

  FileSeek  ( FShpH, 0, 0 );
  FileWrite ( FShpH, Header[0], 100 ); // write Shape file Header
  FileClose ( FShpH );

  //***** Prepare and write SHX file header (some fields are already OK)

  FileLeng := FileSeek( FShxH, 0, 1 ) div 2; // SHX file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  FileSeek  ( FShxH, 0, 0 );
  FileWrite ( FShxH, Header[0], 100 ); // write Shx (Index) file Header
  FileClose ( FShxH );

  //***** Close DBF file
  Fname := ChangeFileExt( ShpFName, '.dbf' );
  DBF.SaveToFile( Fname );
  DBF.Free;
end; // end of procedure N_UDPointsToShape

//******************************************************** N_ULinesToShape1 ***
// Obsolete, implemented only for sinle part Items
//
// Convert ULines to ArcView Lines Theme (shp, shx, dbf files)
//
// ULines    - given ULines object
// ShpFName  - Shape full file name (with .shp extention),
// AffCoefs4 - affine trnasformation coefs
//
procedure N_ULinesToShape1( ULines: TN_ULines; ShpFName: string; AffCoefs4: TN_AffCoefs4  );
var
  FShpH, FShxH: integer;
  DBF: TN_DBF;
  DataBuf: TK_DataBuf;
  Header: array[0..99] of byte;
  Content: array[0..99] of byte; // without coords
  i, j, k, MaxK, IndXY, NPoints, RecordNumber: integer;
  DC: TN_DPArray;
  FileLeng, RecordSize: integer;
  XY: TN_DPArray;
  Fname: string;
  EnvDRect, FileEnvDRect: TDRect;
  ShpShx: TPoint;
begin
  DBF := TN_DBF.Create;
  DBF.AddField( 'ID',   'N', 8 );
  DBF.AddField( 'Code', 'N', 9 );

  //**************** Create .SHP file and position it after Header
  FShpH := FileCreate( ShpFName );
  FileSeek( FShpH, 100, 0 );

  //**************** Create .SHX file and position it after Header
  Fname := ChangeFileExt( ShpFName, '.shx' );
  FShxH := FileCreate( FName );
  FileSeek( FShxH, 100, 0 );

  RecordNumber := 1; // Shape record number
  SetLength( XY, 1000 );
  FileEnvDRect.Left := N_NotADouble; // set "not initialized" flag

  MaxK := ULines.WNumItems-1;

  DBF.AddRecords( MaxK+1 );

  for k := 0 to MaxK do // loop along all Lines
  begin
    ULines.GetPartDCoords( k, 0, DC );

    N_StateString.Show( 'Lines to Shape: ', k/(MaxK+1) );

    NPoints := Length( DC ); // number points in DLine

                    //***** form and write SHX record
    j := FileSeek( FShpH, 0, 1 ) div 2; // j is used as tmp integer
    N_Reverse4Bytes( @j, @ShpShx.X ); // Shp record header offset in words
    // RecordSize is Shp record size in words and Shx record size field
    RecordSize := ( 48 + NPoints*sizeof(TDPoint) ) div 2; // in words
    N_Reverse4Bytes( @RecordSize, @ShpShx.Y ); // ShpShx.Y is used in Shp too
    FileWrite( FShxH, ShpShx, sizeof(ShpShx) ); // write Shx record
    //***** SHX record is OK

                    //***** form and write SHP record Header
    N_Reverse4Bytes( @RecordNumber, @ShpShx.X ); // Shp record number
             // ( ShpShx.Y field is common for Shx records and Shp header )
    FileWrite( FShpH, ShpShx, sizeof(ShpShx) ); // write Shp record header

                    //***** form and write SHP record Content
    j := 3; // Line Shape type
    move( j, Content[0], sizeof(integer) );

    if Length(XY) < NPoints then SetLength( XY, NPoints + NPoints div 2 );
    EnvDRect.Left := N_NotADouble; // set "not initialized" flag

    for IndXY := 0 to NPoints-1 do // calc XY coords array and EnvDRect
    begin
      XY[IndXY].X := AffCoefs4.CX*DC[IndXY].X + AffCoefs4.SX;
      XY[IndXY].Y := AffCoefs4.CY*DC[IndXY].Y + AffCoefs4.SY;
      N_IncEnvRect( EnvDRect, XY[IndXY] );
    end;
    N_DRectOr( FileEnvDRect, EnvDRect );

    move( EnvDRect, Content[4], sizeof(EnvDRect) );
    j := 1; // num parts
    move( j, Content[36], sizeof(integer) );
    move( NPoints, Content[40], sizeof(integer) );
    j := 0; // index of first point in first (the only) part
    move( j, Content[44], sizeof(integer) );
    FileWrite( FShpH, Content[0], 48 ); // Shp record content without coords
    FileWrite( FShpH, XY[0], NPoints*sizeof(TDPoint) ); // coords
    //***** SHP record header and content are OK

    DBF.SetCurField( 'ID' );
    DataBuf.IData := k;
    DBF.SetCurFieldValue ( k, DataBuf );
    DBF.SetCurField( 'Code' );
//    DataBuf.IData := DLine.CObjCode;
//    DataBuf.IData := ULines.Items[k].CCode;
    ULines.GetItemTwoCodes( k, 0, DataBuf.IData, N_i );
    DBF.SetCurFieldValue ( k, DataBuf );

    Inc(RecordNumber);
{
                    //***** form and write DBF record
    DBF.Append;
    DBF.Fields.Fields[0].asString := IntToStr( k );
//##    DBF.Fields.Fields[1].asString := IntToStr( DLine.CObjTag shr 16 );
//##    DBF.Fields.Fields[2].asString := IntToStr( DLine.CObjTag and $FFFF );
    DBF.Fields.Fields[1].asString := IntToStr( DLine.RC1 );
    DBF.Fields.Fields[2].asString := IntToStr( DLine.RC2 );
//    DBF.Fields.Fields[?].asString := IntToStr( DLine.CObjID );
//    DBF.Fields.Fields[?].asString := IntToStr( DLine.CObjCode );
//    DBF.Fields.Fields[?].asString := DLine.ObjName;
}
  end; // for k := 0 to MaxK do // loop along all Lines

  //***** Shp and Shx files are OK ecxept of theirs headers.
  //      Prepare and write SHP file header

  FillChar( Header[0], 100, 0 );
  i := 9994; // SHP File Code
  N_Reverse4Bytes( @i, @Header[0] );

  FileLeng := FileSeek( FShpH, 0, 1 ) div 2; // SHP file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  i := 1000; // Shape format Version
  move( i, Header[28], SizeOf(integer) );

  i := 3; // Lines Shape type
  move( i, Header[32], SizeOf(integer) );

  move( FileEnvDRect, Header[36], SizeOf(FileEnvDRect) );

  FileSeek  ( FShpH, 0, 0 );
  FileWrite ( FShpH, Header[0], 100 ); // write Shape file Header
  FileClose ( FShpH );

  //***** Prepare and write SHX file header (some fields are already OK)

  FileLeng := FileSeek( FShxH, 0, 1 ) div 2; // SHX file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  FileSeek  ( FShxH, 0, 0 );
  FileWrite ( FShxH, Header[0], 100 ); // write Shx (Index) file Header
  FileClose ( FShxH );

  //***** Close DBF file
  Fname := ChangeFileExt( ShpFName, '.dbf' );
  DBF.SaveToFile( Fname );
  DBF.Free;

//  DBF.Post;
//  DBF.Close;
end; // end of procedure N_ULinesToShape1

//********************************************************* N_ULinesToShape ***
// Convert ULines to ArcView Polyline or Polygon Theme (shp, shx, dbf files)
//
// ULines     - given ULines object
// ShpFName   - Shape full file name (with .shp extention),
// AffCoefs4  - affine trnasformation coefs
// AShapeType - given Shape Type (N_ShapePolyline=3 or N_ShapePolygon=5)
//
procedure N_ULinesToShape( ULines: TN_ULines; ShpFName: string;
                           AShapeType: integer; AffCoefs4: TN_AffCoefs4 );
var
  FShpH, FShxH: integer;
  DBF: TN_DBF;
  DataBuf: TK_DataBuf;
  Header: array[0..99] of byte;
  Content: array[0..99] of byte; // without coords and parts
  PartInds: TN_IArray;
  i, j, k, MaxK, IndXY, RecordNumber, IndDC: integer;
  NPointsInItem, NPointsInPart, NumParts, FirstInd: integer;
  DC: TN_DPArray;
  FileLeng, RecordSize: integer;
  XY: TN_DPArray;
  Fname: string;
  RecordEnvDRect, FileEnvDRect: TDRect; // Double Rect, not Float!
  ShpShx: TPoint;
begin
  DBF := TN_DBF.Create;
  DBF.AddField( 'ID',   'N', 8 );
  DBF.AddField( 'Code', 'N', 9 );

  //**************** Create .SHP file and position it after Header
  FShpH := FileCreate( ShpFName );
  FileSeek( FShpH, 100, 0 );

  //**************** Create .SHX file and position it after Header
  Fname := ChangeFileExt( ShpFName, '.shx' );
  FShxH := FileCreate( FName );
  FileSeek( FShxH, 100, 0 );

  RecordNumber := 1; // Shape record number
  SetLength( XY, 10000 );
  FileEnvDRect.Left := N_NotADouble; // set "not initialized" flag (Double!)

  MaxK := ULines.WNumItems-1;
  DBF.AddRecords( MaxK+1 );

  for k := 0 to MaxK do // loop along all ULines Items
  begin
    N_StateString.Show( 'Lines to Shape: ', k/(MaxK+1) );
    NumParts := ULines.GetNumParts( k ); // number of Parts in k-th Item

    //***** Calc in loop along all Item Parts:
    //          NPointsInItem - whole number of points in all parts
    //          PartInds      - indexes to first point in Part
    //          XY            - final record coords
    //          EnvDRect      - record Env Rect

    NPointsInItem := 0;
    SetLength( PartInds, NumParts );
    RecordEnvDRect.Left := N_NotADouble; // set "not initialized" flag (Double!)

    for i := 0 to NumParts-1 do // along all Item Parts
    begin
      PartInds[i] := NPointsInItem;
      ULines.GetPartInds( k, i, FirstInd, NPointsInPart ); // FirstInd is not used
      Inc( NPointsInItem, NPointsInPart );

      if Length(XY) < NPointsInItem then
        SetLength( XY, NPointsInItem + NPointsInItem div 2 );

      ULines.GetPartDCoords( k, i, DC );

      for IndDC := 0 to NPointsInPart-1 do // calc XY coords array and EnvDRect
      begin
        IndXY := PartInds[i] + IndDC;

        XY[IndXY].X := AffCoefs4.CX*DC[IndDC].X + AffCoefs4.SX;
        XY[IndXY].Y := AffCoefs4.CY*DC[IndDC].Y + AffCoefs4.SY;

        N_IncEnvRect( RecordEnvDRect, XY[IndXY] );
      end; // for IndDC := 0 to NPointsInPart-1 do // calc XY coords array and EnvDRect

    end; // for i := 0 to NParts-1 do // along all Item Parts

    N_DRectOr( FileEnvDRect, RecordEnvDRect ); // current value of File Env Rect

                    //***** form and write SHX record
    j := FileSeek( FShpH, 0, 1 ) div 2; // j is used as tmp integer
    N_Reverse4Bytes( @j, @ShpShx.X ); // Shp record header offset in words
    // RecordSize is Shp record size in words and Shx record size field
    RecordSize := ( 44 + NumParts*SizeOf(integer) + NPointsInItem*sizeof(TDPoint) ) div 2; // in words
    N_Reverse4Bytes( @RecordSize, @ShpShx.Y ); // ShpShx.Y is used in Shp too
    FileWrite( FShxH, ShpShx, sizeof(ShpShx) ); // write Shx record
    //***** SHX record is OK

                    //***** form and write SHP record Header
    N_Reverse4Bytes( @RecordNumber, @ShpShx.X ); // Shp record number
             // ( ShpShx.Y field is common for Shx records and Shp header )
    FileWrite( FShpH, ShpShx, sizeof(ShpShx) ); // write Shp record header

                    //***** form and write SHP record Content
    j := AShapeType; // Shape type, N_ShapePolyline=3 or N_ShapePolygon=5
    move( j, Content[0], sizeof(integer) );

    move( RecordEnvDRect, Content[4], sizeof(RecordEnvDRect) );

    move( NumParts,      Content[36], sizeof(integer) );
    move( NPointsInItem, Content[40], sizeof(integer) );

    FileWrite( FShpH, Content[0],  44 ); // Shp record content without coords and parts
    FileWrite( FShpH, PartInds[0], NumParts*sizeof(integer) ); // parts indexes
    FileWrite( FShpH, XY[0],       NPointsInItem*sizeof(TDPoint) ); // coords
    //***** SHP record header and content are OK

    DBF.SetCurField( 'ID' );
    DataBuf.IData := k;
    DBF.SetCurFieldValue ( k, DataBuf );
    DBF.SetCurField( 'Code' );
    ULines.GetItemTwoCodes( k, 0, DataBuf.IData, N_i );
    DBF.SetCurFieldValue ( k, DataBuf );

    Inc(RecordNumber);
  end; // for k := 0 to MaxK do // loop along all Lines

  //***** Shp and Shx files are OK ecxept of theirs headers.
  //      Prepare and write SHP file header

  FillChar( Header[0], 100, 0 );
  i := 9994; // SHP File Code
  N_Reverse4Bytes( @i, @Header[0] );

  FileLeng := FileSeek( FShpH, 0, 1 ) div 2; // SHP file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  i := 1000; // Shape format Version
  move( i, Header[28], SizeOf(integer) );

  i := AShapeType; // Shape type, N_ShapePolyline=3 or N_ShapePolygon=5
  move( i, Header[32], SizeOf(integer) );

  move( FileEnvDRect, Header[36], SizeOf(FileEnvDRect) );

  FileSeek  ( FShpH, 0, 0 );
  FileWrite ( FShpH, Header[0], 100 ); // write Shape file Header
  FileClose ( FShpH );

  //***** Prepare and write SHX file header (some fields are already OK)

  FileLeng := FileSeek( FShxH, 0, 1 ) div 2; // SHX file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  FileSeek  ( FShxH, 0, 0 );
  FileWrite ( FShxH, Header[0], 100 ); // write Shx (Index) file Header
  FileClose ( FShxH );

  //***** Close DBF file
  Fname := ChangeFileExt( ShpFName, '.dbf' );
  DBF.SaveToFile( Fname );
  DBF.Free;
end; // end of procedure N_ULinesToShape

//************************************************ N_KrlbToMem ***
// read given Krlb data (Tikunov) to memory
//
// KrlbFName  - Krlb file Name,
// XYFName    - XY file Name,
// AffCoefs4  - aff. trnasformation coefs,
//                     Output params:
// XY         - array of double Point coords
// BordLines  - array of Border Lines params
// EnvDRect   - Envelope DRect of all points in XY array (after Aff. convertion)
// MaxRC      - Max Region Code
//
//        KRLB file description:
// nameXY.dat - ASCII file that contains only X Y pairs - all line coords
//              without any additional delimiters,
// krlb.dat   - ASCII file that contains triples - RC1 RC2 NPoints :
//  RC1       - Region Code to the left of line border fragment
//  RC2       - Region Code to the right of line border fragment
//              (Region Code =1 means outer area (Ocean for world map)
//  NPoints   - number of points in line (border fragment)
//    Returns - 0 of OK, -1 if failed
//
function N_KrlbToMem( KrlbFName, XYFName: string; AffCoefs4: TN_AffCoefs4;
                     var XY: TN_DPArray; var BordLines: TN_BordLines ): integer;
var
  FKrlb, FXY: TextFile;
  X,Y: double;
  IndXY, IndBL, RC1, RC2, NPoints: integer;
begin
  Result := -1;
  if not FileExists(KrlbFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + KrlbFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FKrlb, KrlbFName );
  Reset     ( FKrlb );

  SetLength( BordLines, 100 );
  IndXY := 0;
  IndBL := 0;

  while True do
  begin
    if EOF(FKrlb) then Break;
    N_StateString.Show( 'Krlb to Mem: ', 0.1*FilePos(FKrlb)/FileSize(FKrlb) );
    Read( FKrlb, RC1, RC2, NPoints );
    if NPoints = 0 then Break; // same as EOF
    if High(BordLines) < IndBL then SetLength( BordLines, 2*Length(BordLines) );
    BordLines[IndBL].RC1 := RC1;
    BordLines[IndBL].RC2 := RC2;
    BordLines[IndBL].NPoints := NPoints;
    BordLines[IndBL].IndXY := IndXY;
    Inc( IndXY, NPoints );
    Inc(IndBL);
  end;
  Close( FKrlb );
  SetLength( BordLines, IndBL );
  SetLength( XY, IndXY );

  if not FileExists(XYFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + XYFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FXY, XYFName );
  Reset     ( FXY );
  IndXY := 0;

  while True do
  begin
    if EOF(FXY) then Break;
    N_StateString.Show( 'Krlb to Mem: ', 0.1 + 0.9*FilePos(FXY)/FileSize(FXY) );
    Read( FXY, X, Y );
    if IndXY > High(XY) then Break;
    XY[IndXY].X := AffCoefs4.CX*X + AffCoefs4.SX;
    XY[IndXY].Y := AffCoefs4.CY*Y + AffCoefs4.SY;
    Inc(IndXY);
  end;
  Close( FXY );
  Result := 0; // Loaded OK
end; // end of procedure N_KrlbToMem

//************************************************ N_KrlbToULines ***
// convert Krlb (Tikunov) files to TN_ULines CObj Layer
//
// ULines    - resulting Lines Layer,
// XYFName    - XY file Name,
// KrlbFName  - Krlb file Name,
// AffCoefs4  - aff. trnasformation coefs,
//    Returns - 0 of OK, -1 if failed
//
function N_KrlbToULines( ULines: TN_ULines; XYFName, KrlbFName: string;
                                            AffCoefs4: TN_AffCoefs4 ): integer;
var
  i: integer;
  XY: TN_DPArray;
  BordLines: TN_BordLines;
  LItem: TN_ULinesItem;
begin
  LItem := TN_ULinesItem.Create( ULines.WLCType );
//  SetLength( LItem.IRegCodes, 2 );
//  LItem.INumRegCodes := 2;

  ULines.WFlags := ULines.WFlags or N_RCXYBit;
  ULines.InitItems( Length(BordLines), Length(XY) );

  Result := N_KrlbToMem( KrlbFName, XYFName, AffCoefs4, XY, BordLines );
  if Result <> 0 then Exit;

  for i := 0 to High(BordLines) do
  begin
    N_StateString.Show( 'Krlb to Lines: ', i/High(BordLines) );
    LItem.Init();
//    LItem.ICode := i+1;
//    LItem.IRC1  := BordLines[i].RC1;
//    LItem.IRC2  := BordLines[i].RC2;

//    LItem.IRegCodes[0] := BordLines[i].RC1;
//    LItem.IRegCodes[1] := BordLines[i].RC2;
//    LItem.SetThreeCodes( i+1, BordLines[i].RC1, BordLines[i].RC2 );

    LItem.AddPartCoords( XY, BordLines[i].IndXY, BordLines[i].NPoints );
    ULines.ReplaceItemCoords( LItem, -1, i+1, BordLines[i].RC1, BordLines[i].RC2 );
  end;

  ULines.CalcEnvRects();
  ULines.CompactSelf();
  LItem.Free;
  Result := 0; // Loaded OK
end; // end of procedure N_KrlbToULines

type TN_ImpEmfData = record // used as ImpEnhMetaFileProc context
  LItem:      TN_ULinesItem;
  AULines:    TN_ULines;
  AAffCoefs4: TN_AffCoefs4;
  PixCoords:  TN_IPArray;
  Flags:      TN_BArray;
  DC:         TN_DPArray;
  LastEMFRType: integer;
  LastEMFRInd:  integer;
  InsidePath: boolean;
end; // type TN_ImpEmfData = record
type TN_PImpEmfData = ^TN_ImpEmfData;

//************************************************ ImpEnhMetaFileProc ***
// import coords from one metafile record
// used only in N_EMFToULines procedure as EnumEnhMetaFile parametr
// (is called by Windows inside EnumEnhMetaFile WIN API function)
//
// PParams - Pointer to TN_ImpEmfData record
//
function ImpEnhMetaFileProc( hdc: HDC; var ht: THandleTable;
                             var emfr: TEnhMetaRecord; nObj: integer;
                             PParams: Pointer ): integer; stdcall;

  function PlayRecord(): integer; // local
  // Play one EMF record
  begin
    Result := integer( PlayEnhMetaFileRecord( hdc, ht, emfr, nObj ) );
  end; // function PlayRecord(): integer; // local

  procedure ImportPath(); // local
  // Import current Path
  var
    i, DCInd, NPoints: integer;

    procedure AddDCToULines(); // second level local
    // Add line coords in DC to ULines as new Item
    begin
      with TN_PImpEmfData(PParams)^ do
      begin
        LItem.Init();
        LItem.AddPartCoords( DC, 0, DCInd );
        AULines.ReplaceItemCoords( LItem, -1 );
      end; // with TN_PImpEmfData(PParams)^ do
    end; // procedure AddDCToULines(); // second level local

  begin //******************************** body of local Proc ImportPath

  with TN_PImpEmfData(PParams)^ do
  begin
    FlattenPath( hdc );
    NPoints := GetPath( hdc, PixCoords, Flags, 0 );
    if NPoints = 0 then Exit; // empty Path

    if Length(PixCoords) < NPoints then
      SetLength( PixCoords, N_NewLength(NPoints) );
    if Length(Flags) < NPoints then
      SetLength( Flags, N_NewLength(NPoints) );
    GetPath( hdc, PixCoords[0], Flags[0], NPoints );

    DCInd := 0;
    for i := 0 to NPoints-1 do // loop along all points in Path
    begin
      if (Flags[i] = PT_MOVETO) and (DCInd > 0) then // previous line in DC
      begin
        AddDCToULines(); // add previous line
        DCInd := 0;      // begin new line
      end;

      //*** convert current point from PixCoords[i] to DC[DCInd]
      if High(DC) < DCInd then SetLength( DC, N_NewLength(DCInd) );
      DC[DCInd].X := AAffCoefs4.CX*PixCoords[i].X + AAffCoefs4.SX;
      DC[DCInd].Y := AAffCoefs4.CY*PixCoords[i].Y + AAffCoefs4.SY;
      Inc(DCInd);

      if (Flags[i] and PT_CLOSEFIGURE) <> 0 then // close current line
      begin
        DC[DCInd] := DC[0];
        Inc(DCInd);
      end;

    end; // for i := 0 to NPoints-1 do // loop along all points in Path

    if DCInd > 0 then
      AddDCToULines(); // add last (may be the only one) line in Path

  end; // with TN_PImpEmfData(PParams)^ do
  end; // procedure ImportPath(); // local

  function NewPathNeeded( RecType: integer ): boolean;
  // return True if RecType adds coords to Path
  begin
    if ((RecType >=  2) and (RecType <=  8)) or
       ( RecType  = 27)                      or
       ((RecType >= 41) and (RecType <= 47)) or
       ((RecType >= 54) and (RecType <= 56)) or
       ((RecType >= 83) and (RecType <= 92)) or
       ((RecType >= 96) and (RecType <= 97))    then Result := True
                                                else Result := False;
  end; // function NewPathNeeded (local)

begin //********************************** body of N_ImpEnhMetaFileProc

  with TN_PImpEmfData(PParams)^ do
  begin


  if emfr.iType = EMR_HEADER then //*** first record, no specialactions
//  begin collecting Paths
  begin
    Result := PlayRecord();
  end else if not InsidePath and NewPathNeeded( emfr.iType ) then
  begin
    BeginPath( hdc ); // begin myPath
    InsidePath := True;
    Result := PlayRecord();
  end else if (emfr.iType = EMR_BEGINPATH) or // close and import MY Path
              (emfr.iType = EMR_EOF) then
  begin
    if InsidePath then
    begin
      EndPath( hdc );
      ImportPath();
    end;
    Result := PlayRecord();
    InsidePath := True;
  end else if emfr.iType = EMR_ENDPATH then // close and import EMF Path
  begin
    Result := PlayRecord();
    ImportPath();
    InsidePath := False;
  end else // just play next record (may be inside current Path)
  begin
    if emfr.iType = EMR_SETMITERLIMIT then
      Result := 1 // PlayRecord() failed under Win98!
    else
      Result := PlayRecord();
  end;

  LastEMFRType := emfr.iType; // for debug
  Inc(LastEMFRInd);           // for debug

  end; // with TN_PImpEmfData(PParams)^ do
end; // function ImpEnhMetaFileProc

//************************************************ N_EMFToULines ***
// convert EMF file to TN_ULines
//
// ULines     - TN_ULines resulting object
// EMFFName   - EMF file Name,
// AffCoefs4  - aff. trnasformation coefs,
// PlayRectWidth - EMF Playing Rect Width (affects FlattenPath converting precision)
//    Returns - 0 of OK, -1 if failed
//
procedure N_EMFToULines( ULines: TN_ULines; EMFFName: string;
                               AffCoefs4: TN_AffCoefs4; PlayRectWidth: integer );
var
  HeaderSize, PlayRectHeight: integer;
  hmf: HENHMETAFILE;
  EMFHeader: TN_BArray;
  PlayRect, EMFRect: TRect;
  ImpEmfData: TN_ImpEmfData; // ImpEnhMetaFileProc context
  TmpDC: HDC;
begin
  hmf := GetEnhMetafile( PChar(EMFFName) );
  if hmf = 0 then raise Exception.Create( 'Metafile Error1' );

  with ImpEmfData do
  begin
    LItem := TN_ULinesItem.Create( ULines.WLCType );
    ULines.InitItems( 100, 10000 );
    AULines := ULines;
    AAffCoefs4 := AffCoefs4;
    LastEMFRInd := 0;
    InsidePath:= False;
  end; // with TN_PImpEmfData(PParams)^ do

  // PlayRect Size affects Bezier to Lines converting precision (in FlattenPath)
  HeaderSize := GetEnhMetaFileHeader( hmf, 0, nil );
  Setlength( EMFHeader, HeaderSize );
  GetEnhMetaFileHeader( hmf, HeaderSize, PEnhMetaHeader(@EMFHeader[0]) );
  EMFRect := PEnhMetaHeader(@EMFHeader[0])^.rclFrame;
  PlayRectHeight := Round( PlayRectWidth * N_RectAspect(EMFRect) );
  PlayRect := Rect( 0, 0, PlayRectWidth-1, PlayRectHeight-1 );

  TmpDC := CreateCompatibleDC( 0 ); // any Device Context is OK
  N_b := EnumEnhMetaFile( TmpDC, hmf, @ImpEnhMetaFileProc, @ImpEmfData, PlayRect);
  if not N_b then
  begin
    N_IAdd( 'Metafile Error at:' );
    with ImpEmfData do
      N_IAdd( Format( 'Last EMFR Type = %d, Ind = %d', [LastEMFRType, LastEMFRInd]));
  end;

  DeleteDC( TmpDC );
  DeleteEnhMetaFile( hmf );
  ImpEmfData.LItem.Free; // LItem was created in ImpEnhMetaFileProc

  ULines.CalcEnvRects();
  ULines.CompactSelf();
end; // end of procedure N_EMFToULines

//************************************************ N_TdbToUDPoints ***
// convert Tdb file to TN_UDPoints
//
// UPoints    - resulting TN_UDPoints obj
// FileName   - full input file name
// TableName  - TDB Table name
// AffCoefs4  - aff. trnasformation coefs
//
procedure  N_TdbToUDPoints( UPoints: TN_UDPoints; FileName, TableName: string;
                                                const AffCoefs4: TN_AffCoefs4 );
var
  i, Code: integer;
  FTdb: TextFile;
  DP: TDPoint;
  Str, Str2: String;
  label TableNotFound;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  AssignFile( FTdb, FileName );
  Reset( FTdb );

  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Trim(Str) = ''  then Continue; // skip empty Point
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  UPoints.InitItems( 2, 500 );
  i := 0;

  while True do //********** Import "Points" TDB table
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // read Point header
    Str := TrimRight( Str ); // to skip spaces

    if Trim(Str) = ''  then Continue; // skip empty Point
    if Str[1] = '*' then Continue; // skip comment Point

    if Str[1] = 'E' then Break; // end of "Points" TDB table
    if Str[1] = 'C' then Break; // Data Table
    if Str[1] = 'T' then Break; // end of "Points" TDB table

    Code := N_ScanInteger( Str );
    DP   := N_ScanDPoint( Str );
    DP.X := AffCoefs4.CX*DP.X + AffCoefs4.SX;
    DP.Y := AffCoefs4.CY*DP.Y + AffCoefs4.SY;
    UPoints.AddOnePointItem( DP, Code );
//    N_StateString.Show( 'TDB to Points: ' + IntToStr(i) ); // for debug
    Inc(i); N_i := i; // for debug
  end; // while True do //********** Import "Points" TDB table
  UPoints.CalcEnvRects();
  UPoints.CompactSelf();

  finally
  CloseFile( FTdb );
  end; // try
end; // end of procedure N_TdbToUDPoints

//************************************************ N_TdbToULines ***
// convert Tdb file to TN_ULines obj
//
// ULines    - resulting TN_ULines obj,
// FileName  - full input file name
// TableName - TDB Table name
// AffCoefs4 - aff. trnasformation coefs,
//
procedure N_TdbToULines( ULines: TN_ULines; FileName, TableName: string;
                                               const AffCoefs4: TN_AffCoefs4 );
var
  FTdb: TextFile;
  LineCode, LineInd, VertexInd: integer;
  X, Y: double;
  DC: TN_DPArray;
  Str, Str2: String;
  ULinesItem: TN_ULinesItem;
  label TableNotFound;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  AssignFile( FTdb, FileName );
  Reset( FTdb );
  ULinesItem := TN_ULinesItem.Create( ULines.WLCType );

  try
  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Trim(Str) = ''  then Continue; // skip empty line
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  LineInd := 0; // used for showing in StatusBar
  ULines.InitItems( 1000, 20000 );
  SetLength( DC, 1000 );

  while True do //********** Import "lines" TDB table
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // read line header
    Str := TrimRight( Str ); // to skip spaces

    if Trim(Str) = ''  then Continue; // skip empty line
    if Str[1] = '*' then Continue; // skip comment line

    if Str[1] = 'E' then Break; // end of "lines" TDB table
    if Str[1] = 'C' then Break; // Data Table
    if Str[1] = 'T' then Break; // end of "lines" TDB table

    LineCode := N_ScanInteger( Str );
    if LineCode = N_NotAnInteger then  Continue; // skip empty line
    VertexInd := 0;
    ULinesItem.Init();
//    ULinesItem.ICode := LineCode;
//    ULinesItem.SetTwoCodes( 0, LineCode, -1 );

    while True do //***** read coords of one line
    begin
      if EOF(FTdb) then Break;
      ReadLn( FTdb, Str ); // read Vertex Coords or 'End'
      Str := TrimRight( Str ); // to skip spaces

      if Trim(Str) = '' then Continue;  // skip empty lines
      if Str[1] = '*' then Continue; // skip comment line

      if Str[1] = 'T' then Break; // end of "lines" TDB table
      if Str[1] = 'E' then Break; // End of Line

      if High(DC) < VertexInd then
        SetLength( DC, 2*Length(DC) );

      X := N_ScanDouble( Str );
      Y := N_ScanDouble( Str );
      DC[VertexInd].X := AffCoefs4.CX*X + AffCoefs4.SX;
      DC[VertexInd].Y := AffCoefs4.CY*Y + AffCoefs4.SY;
      Inc(VertexInd);
    end; // while True do // read one line coords loop

    ULinesItem.AddPartCoords( DC, 0, VertexInd );
    ULines.ReplaceItemCoords( ULinesItem, -1, LineCode, LineCode, -1 );
//    N_StateString.Show( 'TDB to Lines: ' + IntToStr(LineInd) ); // for debug
    Inc(LineInd); N_i := LineInd; // for debug
  end; // while True do //********** Import "lines" TDB table
  ULines.CalcEnvRects();
  ULines.CompactSelf();

  finally
  CloseFile( FTdb );
  ULinesItem.Free;
  end; // try
end; // end of procedure N_TdbToULines

//********************************************* N_TdbToContourCodes ***
// set RC1, RC2 fields (in arbitrary order) by contours TDB Table
// (contours TDB Table consists of Lines Indexes Lists for each contour code)
//
// ULines    - TN_ULines obj where to set RC1, RC2,
// FileName  - full input file name
// TableName - TDB contours Table name
//      Returns - 0 of OK, -1 if failed
//
procedure N_TdbToContourCodes( ULines: TN_ULines;
                                           FileName, TableName: string );
var
  FTdb: TextFile;
  i, RegCode, LineInd, NumLines, RC1, RC2: integer;
  Str, Str2: String;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  AssignFile( FTdb, FileName );
  Reset( FTdb );

  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Trim(Str) = ''  then Continue; // skip empty line
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  ULines.ClearAllCodes();

  while True do //********** read "contours" TDB table rows
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // read contour code
    Str := Trim( Str ); // to skip spaces

    if Str    = ''  then Continue; // skip empty line
    if Str[1] = ';' then Continue; // skip comment line
    if Str[1] = '*' then Continue; // skip comment line

    if Str[1] = 'T' then Break; // end of "lines" TDB table
    if Str[1] = 'E' then Break; // End of Line
    if Str[1] = 'C' then Break; // Data Table

    RegCode := N_ScanInteger( Str );
    ReadLn( FTdb, Str ); // read line table name (not used)

    while True do //***** read current contour line indexes
    begin
      if EOF(FTdb) then Break;
      ReadLn( FTdb, Str ); // read line index or 'End'
      Str := Trim( Str ); // to skip spaces
      if Str = '' then Continue; // skip empty lines
      if Str[1] = 'E' then Break;
      if Str[1] = ';' then Continue; // skip comment line
      if Str[1] = '*' then Continue; // skip comment line
      LineInd  := N_ScanInteger( Str );
      NumLines := N_ScanInteger( Str );

      for i := LineInd to LineInd-NumLines+1 do // set RegCode to lines group
      with ULines do
      begin
//        Assert( (RCXY[i].X = -1) or (RCXY[i].Y = -1), 'Bad Topology!' );
//        if RCXY[i].X = -1 then RCXY[i].X := RegCode
//                          else RCXY[i].Y := RegCode;
        GetItemTwoCodes( i, 1, RC1, RC2 );
        if RC1 = -1 then RC1 := RegCode
                    else RC2 := RegCode;
        SetItemTwoCodes( i, 1, RC1, RC2 );
      end; // for i := LineIndex to LineIndex-NumLines+1 do

    end; // while True do //***** read current contour line indexes loop
    ReadLn( FTdb, Str ); // skip second 'END'

  end; // while True do //********** read "contours" TDB table rows

  finally
  CloseFile( FTdb );
  end; // try
end; // end of procedure N_TdbToContourCodes

//********************************************* N_TdbToObjRefs ***
// Add to given RefsCObj references to given BaseCObj layer
// from TDB subset table
//
// BaseCObj  - existed CObj Layer
// RefsCObj  - UCObjRefs Layer, where references should be added
// FileName  - full input file name
// TableName - TDB subset Table name
//
procedure N_TdbToObjRefs( BaseCObj: TN_UCObjLayer; RefsCObj: TN_UCObjRefs;
                                                 FileName, TableName: string );
var
  FTdb: TextFile;
  i, ObjInd, NumObjects: integer;
  Str, Str2: String;
  Label EndOfTable;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  N_ROpenFile( FTdb, FileName );

  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Trim(Str) = ''  then Continue; // skip empty line
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  while True do //********** read SubSet TDB table rows
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // read next row
    Str := Trim( Str ); // to skip spaces

    if Str    = ''  then Continue; // skip empty line
    if Str[1] = ';' then Continue; // skip comment line
    if Str[1] = '*' then Continue; // skip comment line

    if Str[1] = 'T' then Break; // end of SubSet TDB table
    if Str[1] = 'C' then Break; // end of SubSet TDB table
    if Str[1] = 'E' then Break; // end of SubSet TDB table

    //*** Str was Code row (not used)
    ReadLn( FTdb, Str ); // read base Table Name (not used)

    RefsCObj.AddLastEmptyItem();

    while True do //***** read Subset indexes
    begin
      ReadLn( FTdb, Str ); // read "Index Count" or 'END'
      Str := Trim( Str ); // to skip spaces
      if Str[1] = 'E' then
      begin
        ReadLn( FTdb, Str ); // read second END and proceed to next subset
        Break;
      end;
      if Str[1] = 'T' then goto EndOfTable;
      if Str[1] = 'C' then goto EndOfTable;
      if Str[1] = ';' then Continue; // skip comment line
      if Str[1] = '*' then Continue; // skip comment line

      ObjInd  := N_ScanInteger( Str );
      NumObjects := N_ScanInteger( Str );

      for i := ObjInd to ObjInd-NumObjects+1 do // create references
      begin
        RefsCObj.AddRef( i );
      end; // for i := ObjInd to ObjInd-Objects+1 do // create references

    end; // while True do //***** read Subset indexes

    EndOfTable:
  end; // while True do //********** read SubSet TDB table rows

  finally
  CloseFile( FTdb );

  with RefsCObj do
  begin
//    if DirHigh() < N_CObjRefsChildInd then DirSetLength( N_CObjRefsChildInd + 1 );
    PutDirChildSafe( N_CObjRefsChildInd, BaseCObj );
    CalcEnvRects();
    CompactSelf();
  end;
  end; // try
end; // end of procedure N_TdbToObjRefs

//********************************************* N_TdbToDVector ***
// Clear given TK_UDRArray contens and fill it with new Values
// from given TDB Table
// Vector elements are sincronized by Item Codes of given CObjLayer
//
// CObjLayer  - used only for DVactor elements ordering
// DVector    - Data Vector to fill
// FileName   - full input file name
// TableName  - TDB Table name
// DVectorType - =0-Integers, =1-Doubles, =2-Strings, =4-FPoints
//
procedure N_TdbToDVector( CObjLayer: TN_UCObjLayer; DVector: TK_UDRArray;
                          FileName, TableName: string; DVectorType: integer );
begin
{
var
  FTdb: TextFile;
  i, ValueInd, ValueCode, IntValue, ArrayLength: integer;
  DblValue: double;
  StrValue: string;
  Str, Str2: String;
  UDVArray: TN_UDBase;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  AssignFile( FTdb, FileName );
  Reset( FTdb );

  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Str    = ''  then Continue; // skip empty line
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  while True do // find Data section of Table (with 'C' as first character)
  begin
    if EOF(FTdb) then raise Exception.Create( 'Column in  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Str    = ''  then Continue; // skip empty line
    if Str[1] = 'C' then Break; // Data section found
  end; // while True do // find Data section of Table

  for i := 0 to ArrayLength-1 do
  begin
    case ArrayType of
    1: TK_UDIArray(UDVArray).V[i]  := 0;   // Integers
    2: TK_UDDArray(UDVArray).V[i]  := 0.0; // Doubles
    3: TK_UDSArray(UDVArray).V[i]  := '';  // Strings
    4: TK_UDIPArray(UDVArray).V[i] := Point(0,0);  // IntPoints
    5: TK_UDDPArray(UDVArray).V[i] := DPoint(0,0); // DblPoints
    end; // case Mode of
  end;

  while True do //***** read CObjCode, Value pairs
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // CObjCode, Value pair or 'END'
    Str := TrimRight( Str ); // to skip spaces
    if Str = '' then Continue; // skip empty lines
    if Str[1] = 'E' then Break;
    if Str[1] = 'T' then Break;
    if Str[1] = 'C' then Break;
    if Str[1] = ';' then Continue; // skip comment line
    if Str[1] = '*' then Continue; // skip comment line

    ValueCode := N_ScanInteger( Str );
    ValueInd := N_GetUObjIndByCode( LElem, ValueCode );
    if ValueInd = -1 then Continue; // not found

    case ArrayType of
    1: begin // Integers
      IntValue  := N_ScanInteger( Str );
      TK_UDIArray(UDVArray).V[ValueInd] := IntValue;
    end; // 1: begin // Integers

    2: begin // Doubles
      DblValue  := N_ScanDouble( Str );
      TK_UDDArray(UDVArray).V[ValueInd] := DblValue;
    end; // 2: begin // Doubles

    3: begin // Strings
      StrValue  := N_ScanToken( Str );
      TK_UDSArray(UDVArray).V[ValueInd] := StrValue;
    end; // 3: begin // Strings

    4: begin // Int Points
      TK_UDIPArray(UDVArray).V[ValueInd] := N_ScanIPoint( Str );
    end; // 4: begin // Int Points

    5: begin // Dbl Points
      TK_UDDPArray(UDVArray).V[ValueInd] := N_ScanDPoint( Str );
    end; // 5: begin // Dbl Points

    end; // case Mode of

  end; // while True do //***** read Code, Value pairs

  finally
  CloseFile( FTdb );
  end; // try
}
end; // end of procedure N_TdbToDVector

{
//********************************************* N_TdbToObjFields ***
// set ObjName, CObjTag, COBjID, RC1,RC2 fields of LElem childs by
// given CObjCode according to Mode parametr
//
// Layer     - Archive Layer, where to create new TN_UDIArray object
// LElem     - Layer Element dir used for sincronization
// FieldNum      - what field to set:
//             =0 - ObjName
//             =1 - CObjCode (not needed here)
//             =2 - CObjTag
//             =3 - CObjID
//             =4 - RC1,RC2 (for Lines only)
// FileName  - full input file name
// TableName - TDB Table name
//      Returns - 0 of OK, -1 if failed
//
procedure N_TdbToObjFields( Layer, LElem: TN_UDBase;
                          FileName, TableName: string; FieldNum: integer );
var
  FTdb: TextFile;
  UObjCode: integer;
  Str, Str2: String;
  UObj: TN_UDDPoint;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  AssignFile( FTdb, FileName );
  Reset( FTdb );

  while True do // find and skip Table header with needed TableName
  begin
    if EOF(FTdb) then raise Exception.Create( 'Table  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Str    = ''  then Continue; // skip empty line
    if Str[1] = 'T' then
    begin
      N_ScanToken( Str );   // skip all before Table Name
      N_ScanInteger( Str ); // skip N1
      N_ScanInteger( Str ); // skip N2
      Str2 := N_ScanToken( Str );
      if Str2 = '0' then Str2 := N_ScanToken( Str ); // skip N3 if N3=0
      if Str2 = TableName then Break; // Needed Table header found
    end; // if Str[1] = 'T' then
  end; // while True do // find and skip Table header loop

  while True do // find Data section of Table (with 'C' as first character)
  begin
    if EOF(FTdb) then raise Exception.Create( 'Column in  "' +
                                               TableName + '"  not found!' );
    ReadLn( FTdb, Str );
    if Str    = ''  then Continue; // skip empty line
    if Str[1] = 'C' then Break; // Data section found
  end; // while True do // find Data section of Table

  while True do //***** read CObjCode and needed Field Value
  begin
    if EOF(FTdb) then Break;
    ReadLn( FTdb, Str ); // CObjCode and Field Value
    Str := TrimRight( Str ); // to skip spaces

    if Str = '' then Continue; // skip empty line
    if Str[1] = 'E' then Break; // end of Data Rows
    if Str[1] = 'T' then Break;
    if Str[1] = 'C' then Break;
    if Str[1] = ';' then Continue; // skip comment line
    if Str[1] = '*' then Continue; // skip comment line

    UObjCode  := N_ScanInteger( Str );
    N_i := UObjCode; UObj := nil; // temp //!!
//!!    UObj := TN_UDDPoint(N_GetUObjByCode( LElem, UObjCode ));
    if UObj = nil then Continue; // UObjCode not found
    Assert( UObj is TN_UDDPoint, 'Should be Point ancestor!' );

    case FieldNum of
    0: UObj.ObjName := N_ScanToken( Str );
    1: Assert( False, 'Nonsens' );
    2: UObj.CObjTag := N_ScanInteger( Str );
    3: UObj.CObjID  := N_ScanInteger( Str );
    4: begin // RC1, RC2
      Assert( (UObj.ClassFlags and $FF) = N_UDDLineCI, 'Should be Line!' );
      TN_UDDLine(UObj).RC1 := N_ScanInteger( Str );
      TN_UDDLine(UObj).RC2 := N_ScanInteger( Str );
    end;
    end; // case FieldNum of

  end; // while True do //***** read Code, Value pairs

  finally
  CloseFile( FTdb );
  end; // try
end; // end of procedure N_TdbToObjFields
}


{
//************************************************ N_DLinesToCBF ***
// convert all childs of UDDLines type of given Dir LinesRoot to CBF
//
// LinesRoot - root dir with DLines objects (at all levels),
// Flags        - converting flags:
//      bit0 = 0 - rewrite output file, =1 - append output file
// CBFFName     - full output file name (with .cbf extention),
// SectionName  - prefix line - name in [...]
// AffCoefs4    - affine trnasformation coefs
//
procedure N_DLinesToCBF( LinesRoot: TN_UDBase; Flags: integer;
            CBFFName, SectionName: string; const AffCoefs4: TN_AffCoefs4 );
var
  FCBF: TextFile;
  i, LineInd, NumDLines: integer;
  X, Y: double;
  UObjList: TN_UDBaseObjList;
  UDLine: TN_UDDLine;
begin
  AssignFile( FCBF, CBFFName );
  if (Flags and $01) = 0 then Rewrite( FCBF )
                         else Append( FCBF );
  WriteLn( FCBF, '[' + SectionName + ']' );

  UObjList := TN_UDBaseObjList.Create( LinesRoot );
  LineInd := 0;
  while True do // calc number of lines to show Progress
  begin
    UDLine := TN_UDDLine( UObjList.GetNext( 0 ) );
    if UDLine = nil then Break; // end of lines
    if (UDLine.ClassFlags and $FF) <> N_UDDLineCI then Continue;
    Inc(LineInd);
  end;
  NumDLines := LineInd;
  UObjList.Free;

  UObjList := TN_UDBaseObjList.Create( LinesRoot );
  LineInd := 0;
  while True do
  begin
    UDLine := TN_UDDLine( UObjList.GetNext( 0 ) );
    if UDLine = nil then Break; // end of lines
    if (UDLine.ClassFlags and $FF) <> N_UDDLineCI then Continue;
    N_StateString.Show( 'Lines to CBF: ', LineInd/NumDLines );

    if LineInd = 0 then
    begin
      WriteLn( FCBF, Format( '%d', [ UDLine.Accuracy ] ) );
      WriteLn( FCBF, '' );
    end;

    WriteLn( FCBF, Format( '%d   %d  %d', [ LineInd,
//##        ((UDLine.CObjTag shr 16) and $FFFF), (UDLine.CObjTag and $FFFF) ] ) );
        UDLine.RC1, UDLine.RC2 ] ) );
    Inc(LineInd);

    for i := 0 to High(UDLine.DC) do
    begin
      X := AffCoefs4.CX*UDLine.DC[i].X + AffCoefs4.SX;
      Y := AffCoefs4.CY*UDLine.DC[i].Y + AffCoefs4.SY;
      WriteLn( FCBF, Format( '%4d %8.*f %8.*f',
               [ i, UDLine.Accuracy, X, UDLine.Accuracy, Y ] ) );
    end; // for i := 0 to High(UDLine.DC) do

    WriteLn( FCBF, 'End' );
    WriteLn( FCBF, '' );

  end; // while True do

  WriteLn( FCBF, ';End of Section [' + SectionName + ']' );
  Close( FCBF );
end; // end of procedure N_DLinesToCBF

//************************************************ N_DLinesToKrlb ***
// convert all childs of UDDLines type of given Dir LinesRoot to Krlb files
// ( RC1,RC2 fields should contain neighbour contours numbers )
//
// LinesDir    - root dir with DLines objects (at all levels),
// XYFName      - full output file name with X,Y coords
// KrlbFName    - full output file name with Krlb data
//                (KRLB is Kontour Left Right Border)
// AffCoefs4    - affine trnasformation coefs
//
procedure N_DLinesToKrlb( LinesDir: TN_UDBase; XYFName, KrlbFName: string;
                                              const AffCoefs4: TN_AffCoefs4 );
var
  FXY, FKrlb: TextFile;
  i, LineInd, NumDLines, RC1, RC2: integer;
  X, Y: double;
  BufStr1, BufStr2: string;
  UDLine: TN_UDDLine;
begin
  AssignFile( FXY, XYFName );
  Rewrite( FXY );

  if KrlbFName <> '' then
  begin
    AssignFile( FKrlb, KrlbFName );
    Rewrite( FKrlb );
  end;

  NumDLines := LinesDir.DirHigh() + 1;

  BufStr1 := '';
  BufStr2 := '';
  for LineInd := 0 to NumDLines-1 do //***** write strings to Krlb and XY files
  begin
    UDLine := TN_UDDLine(LinesDir.DirChild( LineInd ));
    if UDLine = nil then Break; // end of lines
    if (UDLine.ClassFlags and $FF) <> N_UDDLineCI then Continue;
    N_StateString.Show( 'Lines to Krlb: ', LineInd/NumDLines );
    RC1 := UDLine.RC1;
    RC2 := UDLine.RC2;
    BufStr1 := BufStr1 + Format( '%3d %3d %3d   ', [RC1,RC2,Length(UDLine.DC)]);
    if Length(BufStr1) > 40 then
    begin
      if KrlbFName <> '' then WriteLn( FKrlb, BufStr1 );
      BufStr1 := '';
    end;

    for i := 0 to High(UDLine.DC) do //***** write strings to XY.dat file
    begin
      X := AffCoefs4.CX*UDLine.DC[i].X + AffCoefs4.SX;
      Y := AffCoefs4.CY*UDLine.DC[i].Y + AffCoefs4.SY;
      BufStr2 := BufStr2 + Format( '%9.3f %9.3f  ', [X, Y] );

      if Length(BufStr2) > 100 then
      begin
        WriteLn( FXY, BufStr2 );
        BufStr2 := '';
      end;
    end; // for i := 0 to High(UDLine.DC) do

  end; // while True do

  if KrlbFName <> '' then
  begin
    WriteLn( FKrlb, BufStr1 );
    Close( FKrlb );
  end;

  WriteLn( FXY, BufStr2 );
  Close( FXY );
end; // end of procedure N_DLinesToKrlb

//****************************************** N_DContoursToShapePolygons ***
// convert all DContours type children of given RootContours to
//            ArcView Polygons Theme (shp, shx, dbf files)
// RootContours - root dir with DContours objects (at all levels),
// ShpFName     - Shape full file name (with .shp extention),
// AffCoefs4    - affine trnasformation coefs.
//  (file Empty_kp.dbf is used as empty pattern)
//
procedure N_DContoursToShapePolygons( ContoursDir: TN_UDBase;
                                    ShpFName: string; AffCoefs4: TN_AffCoefs4 );
var
  FShpH, FShxH: integer;
  DBF: TN_DBF;
  DataBuf: TK_DataBuf;
  Header: array[0..99] of byte;
  Content: array[0..99] of byte; // without coords
  Parts: TN_IArray;
  i, j, k, MaxK, Ofs, RingPoints, IndXY, RecordNumber: integer;
  FileLeng, RecordSize, AllPoints, NRings: integer;
  XY: TN_DPArray;
  Fname: string;
  FEnvDRect, REnvDRect: TFRect;
  ShpShx: TPoint;
  DContour: TN_UDDContour;
begin

  //**************** Create .SHP file and position it after Header
  FShpH := FileCreate( ShpFName );
  FileSeek( FShpH, 100, 0 );

  //**************** Create .SHX file and position it after Header
  Fname := ChangeFileExt( ShpFName, '.shx' );
  FShxH := FileCreate( FName );
  FileSeek( FShxH, 100, 0 );

//  //**************** Create .DBF file and open it for appending records
//  Fdbf: File;
//  DBF: TTable;
//
//  //****** first, read to memory bufer empty dbf file with needed fields
//  if DbfFName = '' then
//    DbfFname := ExtractFilePath( ShpFName ) + 'Empty_kp.dbf' ;
//  if not FileExists(DbfFname) then
//    DbfFname := ExtractFilePath( Application.ExeName ) + 'Empty_kp.dbf' ;

//  AssignFile( Fdbf, DbfFName );
//  Reset     ( Fdbf, 1 );
//  ContentSize := FileSize(Fdbf);
//  BlockRead ( Fdbf, Content[0], ContentSize );
//  Close     ( Fdbf );

  //****** next, make a copy of it with needed name
//  Fname := Copy( ShpFName, 1, Length(ShpFName)-3 ) + 'dbf';
//  AssignFile ( Fdbf, FName );
//  Rewrite    ( Fdbf, 1 );
//  BlockWrite ( Fdbf, Content[0], ContentSize );
//  Close      ( Fdbf );
  //*** new empty dbf file with needed fields was created

//  DBF := TTable.Create( N_ExpImpForm ); // open just created empty DBF file
//  DBF := TTable.Create( nil ); // open just created empty DBF file
//  DBF.DatabaseName := ExtractFilePath( Fname );
//  DBF.TableName := ExtractFileName( Fname );
//  DBF.TableType := ttDBase;
//  DBF.Open;
//  DBF.Edit; // DBF file is ready for appending

  RecordNumber := 1; // Shape record number
  FEnvDRect.Left := N_NotADouble; // set "not initialized" flag

  MaxK := ContoursDir.DirHigh;

  DBF := TN_DBF.Create;
  DBF.AddField( 'ID',   'N', 8 );
  DBF.AddField( 'Code', 'N', 9 );
  DBF.AddRecords( MaxK+1 );

  for k := 0 to MaxK do // loop along all Lines
  begin
    DContour := TN_UDDContour( ContoursDir.DirChild( k ) );
    if DContour = nil then Break; // all DContours are processed
    N_StateString.Show( 'Contours to Shape Polygons: ', k/(MaxK+1) );
    if (DContour.ClassFlags and $FF) <> N_UDDContourCI then Continue;

    if DContour.CRings[0].RCoords = nil then
    begin
      DContour.EnvRect.Left := N_NotADouble;
      DContour.MakeRCoords; // make RCoords for all rings
    end;

    AllPoints := 0; // number of points in all rings
    for i := 0 to High(DContour.CRings) do
      Inc( AllPoints, Length(DContour.CRings[i].RCoords) );

    if Length(XY) < AllPoints then SetLength( XY, AllPoints );

    NRings := Length(DContour.CRings);
    SetLength( Parts, NRings );

                      //***** form and write SHX record
    Ofs := FileSeek( FShpH, 0, 1 ) div 2; // Shp record header offset in words
    N_Reverse4Bytes( @Ofs, @ShpShx.X );
                    //*** RecordSize is Shp record size in words and
                    //    Shx record size field
    RecordSize := ( 44 + 4*NRings + AllPoints*sizeof(TDPoint) ) div 2; // size in words
    N_Reverse4Bytes( @RecordSize, @ShpShx.Y ); // ShpShx.Y is used in Shp too
    FileWrite( FShxH, ShpShx, sizeof(ShpShx) ); // write Shx record
                    //***** Shx record is OK

                    //***** form and write Shp record Header
    N_Reverse4Bytes( @RecordNumber, @ShpShx.X ); // Shp record number

             // ( ShpShx.Y field is common for Shx records and Shp header )
    FileWrite( FShpH, ShpShx, sizeof(ShpShx) ); // write Shp record header
                    //***** Shp record Header is OK

    REnvDRect.Left := N_NotADouble; // set "not initialized" flag
    IndXY := 0;

    for i := 0 to High(DContour.CRings) do with DContour.CRings[i] do
    begin
      RingPoints := Length( RCoords ); // number points in i-th ring
      Parts[i] := IndXY; // first point of i-th ring

      for j := 0 to RingPoints-1 do // calc XY coords array and EnvDRect
      begin
        XY[IndXY+j].X := AffCoefs4.CX*RCoords[j].X + AffCoefs4.SX;
        XY[IndXY+j].Y := AffCoefs4.CY*RCoords[j].Y + AffCoefs4.SY;
        N_IncEnvRect( REnvDRect, XY[IndXY+j] );
      end;
      Inc( IndXY, RingPoints );
    end; // for i := 0 to High(DContour.Rings) do with DContour.Rings[i] do
    N_FRectOr( FEnvDRect, REnvDRect );

                    //***** form and write SHP record Content
    j := 5; // Polygon Shape type
    move( j, Content[0], sizeof(integer) ); // same for all records
    move( REnvDRect, Content[4], sizeof(REnvDRect) ); // Box
    move( NRings,    Content[36], sizeof(integer) );  // NumParts
    move( AllPoints, Content[40], sizeof(integer) );  // NumPoints
    FileWrite( FShpH, Content[0], 44 ); // record content without Parts and Points

    FileWrite( FShpH, Parts[0], NRings*sizeof(integer) ); // Parts
    FileWrite( FShpH, XY[0], AllPoints*sizeof(TDPoint) ); // Points
                    //***** SHP record header and content are OK

                    //***** form and write DBF record
    DBF.SetCurField( 'ID' );
    DataBuf.IData := k;
    DBF.SetCurFieldValue ( k, DataBuf );
    DBF.SetCurField( 'Code' );
    DataBuf.IData := DContour.CObjCode;
    DBF.SetCurFieldValue ( k, DataBuf );

    Inc(RecordNumber);
//    DBF.Append;
//    DBF.Fields.Fields[0].asString := IntToStr( RecordNumber );
//    DBF.Fields.Fields[1].asString := IntToStr( DContour.CObjCode );
  end; // while True do // loop along all DContour objects in given Tree

  //***** Shp and Shx files are OK ecxept of theirs headers.
  //      Prepare and write Shp file header

  FillChar( Header[0], 100, 0 );
  i := 9994; // SHP File Code
  N_Reverse4Bytes( @i, @Header[0] );

  FileLeng := FileSeek( FShpH, 0, 1 ) div 2; // SHP file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  i := 1000; // Shape format Version
  move( i, Header[28], SizeOf(integer) );

  i := 5; // Polygons Shape type
  move( i, Header[32], SizeOf(integer) );

  move( FEnvDRect, Header[36], SizeOf(FEnvDRect) );

  FileSeek  ( FShpH, 0, 0 );
  FileWrite ( FShpH, Header[0], 100 ); // write Shape file Header
  FileClose ( FShpH );

  //***** Prepare and write Shx file header (some fields are already OK)

  FileLeng := FileSeek( FShxH, 0, 1 ) div 2; // Shx file size in words
  N_Reverse4Bytes( @FileLeng, @Header[24] );

  FileSeek  ( FShxH, 0, 0 );
  FileWrite ( FShxH, Header[0], 100 ); // write Shx (Index) file Header
  FileClose ( FShxH );

  //***** Close DBF file
  Fname := ChangeFileExt( ShpFName, '.dbf' );
  DBF.SaveToFile( Fname );
  DBF.Free;

//  DBF.Post;
//  DBF.Close;
end; // end of procedure N_DContoursToShapePolygons

//************************************************ N_DLinContsToTdb ***
// create TDB Line table from LinesRoot children and,
// if ContoursRoot <> nil, create TDB Contours table from ContoursRoot children
// (RC1,RC2 field of DLines is used as wrk field to store Child index!!)
//
// LinesRoot    - root dir with DLines objects (at all levels),
// ContoursRoot - root dir with DContours objects (at all levels), may be nil,
// TdbFName     - Tdb full file name (with .tdb extention),
// AffCoefs4    - affine trnasformation coefs.
//
procedure N_DLinContsToTdb( LinesRoot, ContoursRoot: TN_UDBase;
                               TdbFName: string; AffCoefs4: TN_AffCoefs4 );
var
  FTdb: TextFile;
  i, k, h, LineInd, NumDLines, KDContours: integer;
  X, Y: double;
  Str: string;
  UObjList: TN_UDBaseObjList;
  DContour: TN_UDDContour;
  UDLine: TN_UDDLine;
  label Fin;
begin

  //**************** Create .TDB file
  AssignFile( FTdb, TdbFName );
  Rewrite( FTdb );
  WriteLn( FTdb, 'T 10004 -1 0 "lines"' );

  UObjList := TN_UDBaseObjList.Create( LinesRoot );
  LineInd := 0;
  while True do //***** just calc number of lines to show Progress
  begin
    UDLine := TN_UDDLine( UObjList.GetNext( 0 ) );
    if UDLine = nil then Break; // end of lines
    if (UDLine.ClassFlags and $FF) <> N_UDDLineCI then Continue;
    Inc(LineInd);
  end;
  NumDLines := LineInd;
  UObjList.Free;

  UObjList := TN_UDBaseObjList.Create( LinesRoot );
  LineInd := 0;

  while True do //***** write "lines' table to TdbFName
  begin
    UDLine := TN_UDDLine( UObjList.GetNext( 0 ) );
    if UDLine = nil then Break; // end of lines
    if (UDLine.ClassFlags and $FF) <> N_UDDLineCI then Continue;
    N_StateString.Show( 'Lines to TDB: ', LineInd/NumDLines );

    WriteLn( FTdb, '    '+IntToStr(LineInd) );
    if ContoursRoot <> nil then
      UDLine.CObjID := LineInd; // for creating references from "contours" table

    Inc(LineInd);

    for i := 0 to High(UDLine.DC) do //***** write coords
    begin
      X := AffCoefs4.CX*UDLine.DC[i].X + AffCoefs4.SX;
      Y := AffCoefs4.CY*UDLine.DC[i].Y + AffCoefs4.SY;
      Str := Format( ' %.*g  %.*g', [UDLine.Accuracy, X, UDLine.Accuracy, Y] );
      WriteLn( FTdb, Str );
    end; // for i := 0 to High(UDLine.DC) do
    WriteLn( FTdb, 'END' ); // END of line

  end; // while True do
  WriteLn( FTdb, 'END' ); // END of "lines" table
  WriteLn( FTdb, '' );
  UObjList.Free;

  if ContoursRoot = nil then goto Fin; // skip creating "contours" table

  WriteLn( FTdb, 'T 10013 -1 0 "contours"' );

  UObjList := TN_UDBaseObjList.Create( ContoursRoot );
  k := 0;
  while True do // loop along all DContours objects in given Tree
  begin         // just calc number of DContours for showing ProgressBar
    DContour := TN_UDDContour( UObjList.GetNext( 0 ) );
    if DContour = nil then Break; // all DContours are processed
    Inc(k);
  end;
  KDContours := k; // number of DContours,
  UObjList.Free;

  UObjList := TN_UDBaseObjList.Create( ContoursRoot );
  k := 0;
  while True do // ***** loop along all DContour objects in given Tree
  begin         // ***** write "contours' table to TdbFName
    DContour := TN_UDDContour( UObjList.GetNext( 0 ) );
    if DContour = nil then Break; // all DContours are processed
    N_StateString.Show( 'Contours to TDB: ', k/KDContours );

    Inc(k);
    if (DContour.ClassFlags and $FF) <> N_UDDContourCI then Continue;
    WriteLn( FTdb, Format( '    %d', [DContour.CObjCode] ) );
    WriteLn( FTdb, '    lines' );

    h := DContour.DirHigh();
    for i := 0 to h do //***** write line indexes
    begin
      UDLine := TN_UDDLine(DContour.DirChild( i ));
      WriteLn( FTdb, Format( ' %d 1', [UDLine.CObjID] ) );
    end; // for i := 0 to High(UDLine.DC) do
    WriteLn( FTdb, 'END' ); // END of references to same lines table
    WriteLn( FTdb, 'END' ); // END of contour
  end; // while True do // loop along all DContour objects in given Tree

  Fin: Close ( FTdb );
end; // end of procedure N_DLinContsToTdb

//************************************************ N_DPointsToTdb ***
// create TDB points table from PointsRoot children
//
// PointsRoot   - root dir with DPoints objects (at all levels),
// TdbFName     - Tdb full file name (with .tdb extention),
// AffCoefs4    - affine trnasformation coefs.
//
procedure N_DPointsToTdb( PointsRoot: TN_UDBase;
                               TdbFName: string; AffCoefs4: TN_AffCoefs4 );
var
  FTdb: TextFile;
  PointInd, NumDPoints: integer;
  X, Y: double;
  UObjList: TN_UDBaseObjList;
  UDPoint: TN_UDDPoint;
begin

  //**************** Create .TDB file
  AssignFile( FTdb, TdbFName );
  Rewrite( FTdb );
  WriteLn( FTdb, 'T 10003 -1 0 "points"' );

  UObjList := TN_UDBaseObjList.Create( PointsRoot );
  PointInd := 0;
  while True do //***** just calc number of lines to show Progress
  begin
    UDPoint := TN_UDDLine( UObjList.GetNext( 0 ) );
    if UDPoint = nil then Break; // end of lines
    if (UDPoint.ClassFlags and $FF) <> N_UDDPointCI then Continue;
    Inc(PointInd);
  end;
  NumDPoints := PointInd;
  UObjList.Free;

  UObjList := TN_UDBaseObjList.Create( PointsRoot );
  PointInd := 0;

  while True do //***** write "points' table to TdbFName
  begin
    UDPoint := TN_UDDPoint( UObjList.GetNext( 0 ) );
    if UDPoint = nil then Break; // end of lines
    if (UDPoint.ClassFlags and $FF) <> N_UDDPointCI then Continue;
    N_StateString.Show( 'Points to TDB: ', PointInd/NumDPoints );
    X := AffCoefs4.CX*UDPoint.BP.X + AffCoefs4.SX;
    Y := AffCoefs4.CY*UDPoint.BP.Y + AffCoefs4.SY;
    WriteLn( FTdb, Format( ' %4d  %9.*g %9.*g',
              [UDPoint.CObjCode, UDPoint.Accuracy, X, UDPoint.Accuracy, Y ] ));
    Inc(PointInd);
  end; // while True do

  WriteLn( FTdb, 'END' ); // END of "points" table
  WriteLn( FTdb, '' );
  UObjList.Free;
  Close ( FTdb );
end; // end of procedure N_DPointsToTdb
}

type TN_TableDescr = record
  LinkToAtrs: integer;
  TableName: array [0..31] of byte;
  ObjType: byte;
  Reserved: short;
end; // type TableDescr = record

type TN_AtrDescr = record
  AtrType: short;
  AtrName: array [0..31] of byte;
end; // type AtrDescr = record

type TN_SinglePoint = record
  X: Single;
  Y: Single;
end; // type TN_SinglePoint = record

type TN_PointDescr = record
  SPoint: TN_SinglePoint;
  Color: short;
  Reserved: short;
  Table: short;
  LinkToTableRecord: integer;
end; // type PointDescr = record

type TN_RegionDescr = record
  Color: short;
  Reserved: short;
  Table: short;
  LinkToTableRecord: integer;
  LinkToBorders: integer;
end; // type RegionDescr = record

type TN_ArcDescr = record
  Color: short;
  Reserved: short;
  BegNode: short;
  EndNode: short;
  Table: short;
  LinkToTableRecord: integer;
  PointsInArc: short;
  LinkToPoints: integer;
end; // type ArcDescr = record

//************************************************ N_SmdGetAttribute ***
// get all or given obj attribute as string:
// AtrInd - needed attribute index:
//            =-1 - get all attributes with theirs names,
//            >=0 - get only one attribute (with AtrInd index) without it's name
// Smd   - whole Smd file in memory
// Table - Table number (>=1, if 0 - no table, no attributes)
// LinkToRecord - offset in Smd array to attributes record
//
function N_SmdGetAttribute( AtrInd: integer; Smd: TN_BArray;
                                      Table, LinkToRecord: integer ): string;
var
  k, VectorElems: integer;
  NumAtrs: short;
  TableDescr:  TN_TableDescr;
  AtrDescr:    TN_AtrDescr;
  LinkToTables: integer;
  PRecord: TN_BytesPtr;
  TmpBytes: array [0..255] of byte;
begin
  Result := '';
  if Table <= 0 then Exit; // no Table, no Table Record
  PRecord :=  TN_BytesPtr(@Smd[LinkToRecord]);
  Inc( PRecord, 2 ); // skip record size (int 2)

  move( Smd[22], LinkToTables,  sizeof(integer) );
  move( Smd[LinkToTables+2+(Table-1)*sizeof(TableDescr)], TableDescr, sizeof(TableDescr) );
  move( Smd[TableDescr.LinkToAtrs], NumAtrs, 2 );

  for k := 0 to NumAtrs-1 do // loop along table attributes description
  begin
    move( Smd[TableDescr.LinkToAtrs+2+k*sizeof(AtrDescr)], AtrDescr, sizeof(AtrDescr) );
    if (k > 0) and (AtrInd = -1) then Result := Result + ', ';
    if AtrInd = -1 then Result := Result + PChar(@AtrDescr.AtrName) + '=';
    case Abs(AtrDescr.AtrType) of
    1: begin //************************************************ Int 2
       if AtrDescr.AtrType > 0 then // scalar attribute
       begin
         if AtrInd = -1 then
           Result := Result + Format( '%d', [TN_PInt2(PRecord)^] )
         else
           Result := Format( '%d', [TN_PInt2(PRecord)^] );
         Inc( PRecord, 2 );
       end else //******************** vector attribute
       begin
       end;
       end; // Int 2

    2: begin //************************************************ Int 4
       if AtrDescr.AtrType > 0 then // scalar attribute
       begin
         if AtrInd = -1 then
           Result := Result + Format( '%d', [PInteger(PRecord)^] )
         else
           Result := Format( '%d', [PInteger(PRecord)^] );
         Inc( PRecord, 4 );
       end else //******************** vector attribute
       begin
       end;
       end; // Int 4

    3: begin //******************************************** Float 4
       end; // Float 4

    4: begin //******************************************** Float 8
       end; // Float 8

    5: begin //********************************************** Int 1
       if AtrDescr.AtrType > 0 then // scalar attribute
       begin
         if AtrInd = -1 then
           Result := Result + Format( '%d', [TN_PByte(PRecord)^] )
         else
           Result := Format( '%d', [TN_PByte(PRecord)^] );
         Inc( PRecord, 1 );
       end else //******************** vector attribute
       begin
         VectorElems := TN_PByte(PRecord)^;
         Inc(PRecord);
         OemToChar( PAnsiChar(PRecord), PChar(@TmpBytes[0]) );
         if AtrInd = -1 then
           Result := Result + '"' + PChar(@TmpBytes[0]) + '"'
         else
           Result := PChar(@TmpBytes[0]);
         Inc( PRecord, VectorElems );
       end;
       end; // Int 1
    else // wrong AtrDescr.AtrType
       Continue;
    end; // case TableDescr.ObjType of

    if k = AtrInd then Exit;

  end; // for k := 0 to NumAtrs-1 do // loop along table attributes description
end; // end of function N_SmdGetAttribute

//************************************************ N_SmdToASCII ***
// convert given Smd file to ASCII file
// SmdFName   - Smd file Name,
// ASCIIFName - ASCII file Name
//
procedure N_SmdToASCII( SmdFName, ASCIIFName: string);
var
  i, j, k, LinkToArc, RegStatInd, NB: integer;
  NumArcsInBord, NumArcsInReg, ArcNum, NumBordersInReg: short;
  TableDescr:  TN_TableDescr;
  AtrDescr:    TN_AtrDescr;
  PointDescr:  TN_PointDescr;
  RegionDescr: TN_RegionDescr;
  ArcDescr:    TN_ArcDescr;
  SPoint:      TN_SinglePoint;
  FSmd: File;
  FASCII: TextFile;
  Smd: TN_BArray;
  SmdSize: integer;
  LinkToNodes, LinkToArcs, LinkToRegions, LinkToPoints, LinkToTables: integer;
  NumNodes, NumArcs, NumRegions, NumPoints, NumTables, NumAtrs: short;
  ObjTypeName, AtrTypeName, SAttributes, SArcs: string;
  RegStat: TN_IArray;

begin //************************************** N_SmdToASCII body
  NB := 1; // base number ( 0 or 1 )

  if not FileExists(SmdFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + SmdFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FSmd, SmdFName ); // open input Shape file
  Reset     ( FSmd, 1 );

  SmdSize := FileSize( FSmd );
  SetLength( Smd, SmdSize );
  BlockRead ( FSmd, Smd[0], SmdSize ); // read whole Smd file

  AssignFile( FASCII, ASCIIFName ); // open output ASCII file
  Rewrite( FASCII );

  //***** write ASCII file Header

  WriteLn( FASCII, ' Input  file: ' + SmdFName );
  WriteLn( FASCII, ' Output file: ' + ASCIIFName );
  WriteLn( FASCII, Format( ' FileSize = %d   %s %d.%d',
                       [SmdSize, PChar(Smd), Smd[4], Smd[5]] ) );
  if NB = 1 then
    WriteLn( FASCII, ' Object numbers begin from 1 (as in SMD)' )
  else
    WriteLn( FASCII, ' Object numbers begin from 0 (numbers are indexes)' );

  move( Smd[06], LinkToNodes,   sizeof(integer) );
  move( Smd[10], LinkToArcs,    sizeof(integer) );
  move( Smd[14], LinkToRegions, sizeof(integer) );
  move( Smd[18], LinkToPoints,  sizeof(integer) );
  move( Smd[22], LinkToTables,  sizeof(integer) );

  move( Smd[LinkToNodes],   NumNodes,   2 );
  move( Smd[LinkToArcs],    NumArcs,    2 );
  move( Smd[LinkToRegions], NumRegions, 2 );
  move( Smd[LinkToPoints],  NumPoints,  2 );
  move( Smd[LinkToTables],  NumTables,  2 );

  WriteLn( FASCII, Format( ' NumNodes  = %5d,  NumArcs = %d,  NumRegions = %d,',
                                          [NumNodes, NumArcs, NumRegions] ) );
  WriteLn( FASCII, Format( ' NumPoints = %5d,  NumTables = %d,',
                                                   [NumPoints, NumTables] ) );
  WriteLn( FASCII, '' );

  WriteLn( FASCII, '     Tables:' ); //******************** Tables *****
  for i := 0 to NumTables-1 do // loop along tables
  begin
    move( Smd[LinkToTables+2+i*sizeof(TableDescr)], TableDescr, sizeof(TableDescr) );

    case TableDescr.ObjType of
    1: ObjTypeName := 'Arc attributes';
    2: ObjTypeName := 'Region attributes';
    3: ObjTypeName := 'Point attributes';
    else
       ObjTypeName := 'Empty';
    end; // case TableDescr.ObjType of
    if ObjTypeName = 'Empty' then Continue;

    move( Smd[TableDescr.LinkToAtrs], NumAtrs, 2 );
    WriteLn( FASCII, Format( 'Table %d:  TableName= "%s", ObjType=%d (%s), NumAttributes=%d',
      [ i+1, PChar(@TableDescr.TableName), TableDescr.ObjType, ObjTypeName, NumAtrs ] ) );

    for j := 0 to NumAtrs-1 do // loop along table attributes description
    begin
      move( Smd[TableDescr.LinkToAtrs+2+j*sizeof(AtrDescr)], AtrDescr, sizeof(AtrDescr) );
      case Abs(AtrDescr.AtrType) of
      1: AtrTypeName := 'Int 2';
      2: AtrTypeName := 'Int 4';
      3: AtrTypeName := 'Float 4';
      4: AtrTypeName := 'Float 8';
      5: AtrTypeName := 'Int 1';
      else
         AtrTypeName := 'Empty';
      end; // case TableDescr.ObjType of
      WriteLn( FASCII, Format( '  Atr %d:  AtrType=%d (%s),  AtrName= "%s"',
             [j+1, AtrDescr.AtrType, AtrTypeName, PChar(@AtrDescr.AtrName) ] ) );
    end; // for j := 0 to NumAtrs-1 do // loop along table attributes description

    WriteLn( FASCII, '' );
  end; // for i := 0 to NumTables-1 do // loop along tables
  WriteLn( FASCII, '' ); //******************** end of Tables *****

  WriteLn( FASCII, '     Points:' );//******************** Points *****
  WriteLn( FASCII, '' );

  for i := 0 to NumPoints-1 do // loop along Points
  begin
    move( Smd[LinkToPoints+2+i*sizeof(PointDescr)], PointDescr, sizeof(PointDescr) );
    SAttributes := N_SmdGetAttribute( -1, Smd, PointDescr.Table, PointDescr.LinkToTableRecord );
    WriteLn( FASCII, Format( 'Point %3d: (%9.5g, %9.5g) Color=%2d, Table=%d (%s)',
              [i+NB, PointDescr.SPoint.X, PointDescr.SPoint.Y, PointDescr.Color,
                                            PointDescr.Table, SAttributes ] ));
  end; // for i := 0 to NumPoints-1 do // loop along Points
  WriteLn( FASCII, '' ); //******************** end of Points *****


  WriteLn( FASCII, '     Regions:' );//******************** Regions *****
  WriteLn( FASCII, '' );

  SetLength( RegStat, 2*NumRegions );
  RegStatInd := 0;

  for i := 0 to NumRegions-1 do // loop along Regions
  begin
    move( Smd[LinkToRegions+2+i*sizeof(RegionDescr)], RegionDescr, sizeof(RegionDescr) );
    SAttributes := N_SmdGetAttribute( -1, Smd, RegionDescr.Table, RegionDescr.LinkToTableRecord );
    WriteLn( FASCII, Format( 'Region %3d:  Color=%2d,  Table=%d (%s)',
         [i+NB, RegionDescr.Color, RegionDescr.Table, SAttributes ] ));

    move( Smd[RegionDescr.LinkToBorders],   NumBordersInReg, 2 );
    move( Smd[RegionDescr.LinkToBorders+2], NumArcsInReg, 2 );
    LinkToArc := RegionDescr.LinkToBorders+4+NumBordersInReg*2; // to first Arc

    for j := 0 to NumBordersInReg-1 do // loop along all borders in cur. region
    begin
      SArcs := Format( '  Border %3d: ', [j+1] );
      move( Smd[RegionDescr.LinkToBorders+4+j*2], NumArcsInBord, 2 );
      for k := 0 to NumArcsInBord-1 do // loop along all arcs in cur. border
      begin
        move( Smd[LinkToArc], ArcNum, 2 );

        if NB = 0 then ArcNum := Abs(ArcNum) - 1;

        Inc( LinkToArc, 2 );
        SArcs := SArcs + IntToStr(ArcNum) + ' ';
      end; // for k := 0 to NumArcs-1 do // loop along all arcs in border
      WriteLn( FASCII, SArcs );
    end; // for j := 0 to NumBorders-1 do // loop along all borders in region
    WriteLn( FASCII, '' );

    if NumBordersInReg >= 2 then // collect statistics about complex regions
    begin
      RegStat[RegStatInd]   := i+NB; // Region Number
      RegStat[RegStatInd+1] := NumBordersInReg;
      Inc( RegStatInd, 2 );
    end;

  end; // for i := 0 to NumRegions-1 do // loop along Regions
  WriteLn( FASCII, '' ); //******************** end of Regions *****

  if RegStatInd > 0 then // output statistics about complex regions
  begin
    WriteLn( FASCII, '     Complex Regions:' ); //********* Complex Regions ***
    for i := 0 to RegStatInd-1 do
    begin
      if (i and $1) <> 0 then Continue;
      WriteLn( FASCII, Format( '(%3d)  Complex Region=%3d,  NumBorders=%2d',
                                [ (i div 2)+1, RegStat[i], RegStat[i+1] ] ) );
    end;
  end; // if RegStatInd > 0 then // output statistics about complex regions
  WriteLn( FASCII, '' );

  WriteLn( FASCII, '     Arcs:' );//******************** Arcs *****
  WriteLn( FASCII, '' );

  for i := 0 to NumArcs-1 do // loop along Arcs
  begin
    move( Smd[LinkToArcs+2+i*sizeof(ArcDescr)], ArcDescr, sizeof(ArcDescr) );
    SAttributes := N_SmdGetAttribute( -1, Smd, ArcDescr.Table, ArcDescr.LinkToTableRecord );
    WriteLn( FASCII, Format( 'Arc %3d:  Color=%2d,  Table=%d (%s)',
         [i+NB, ArcDescr.Color, ArcDescr.Table, SAttributes ] ));

    for j := 0 to ArcDescr.PointsInArc-1 do // loop along all arc points
    begin
      move( Smd[ArcDescr.LinkToPoints+j*sizeof(SPoint)], SPoint, sizeof(SPoint) );
      WriteLn( FASCII, Format( '  Point %3d: (%9.5g, %9.5g)',
                                                [ j+1, Spoint.X, Spoint.Y ] ));
    end; // for j := 0 to ArcDescr.PointsInArc-1 do // loop along all arc points
    WriteLn( FASCII, '' );

  end; // for i := 0 to NumArcs-1 do // loop along Arcs
  WriteLn( FASCII, '' ); //******************** end of Arcs *****
  WriteLn( FASCII, '***** End of Smd file content *****' );

  Close( FSmd );
  Close( FASCII );
end; // end of procedure N_SmdToASCII

{
//************************************************ N_SmdToDLines ***
// convert Smd file to TN_UDDLines type childs in given LinesRoot
//
// LinesRoot   - root dir with DLines objects (at all levels),
// SmdFName    - full input file name (with .smd extention),
// AffCoefs4   - aff. trnasformation coefs,
// Accuracy    - given accuracy of all coords
// EnvDRect    - Envelope DRect (on output, after affine convertion)
//     Returns - 0 of OK, -1 if failed
//
function N_SmdToDLines( LinesRoot: TN_UDBase; SmdFName: string;
                        const AffCoefs4: TN_AffCoefs4;
                        Accuracy: integer; var EnvDRect: TDRect ): integer;
var
  i, j, LinkToArc, SmdSize, RegCode: integer;
  NumArcsInReg, ArcNum, NumBordersInReg: short;
  RegionDescr: TN_RegionDescr;
  ArcDescr:    TN_ArcDescr;
  LinkToNodes, LinkToArcs, LinkToRegions, LinkToPoints, LinkToTables: integer;
  NumNodes, NumArcs, NumRegions, NumPoints, NumTables: short;
  SPoint:      TN_SinglePoint;
  FSmd: File;
  Smd: TN_BArray;
  UDLine: TN_UDDLine;
  SAttributes: string;
begin
  Result := -1;
  if not FileExists(SmdFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + SmdFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FSmd, SmdFName );
  Reset     ( FSmd, 1 );
  EnvDRect.Left := N_NotADouble; // set "not initialized" flag

  SmdSize := FileSize( FSmd );
  SetLength( Smd, SmdSize );
  BlockRead ( FSmd, Smd[0], SmdSize ); // read whole Smd file

  move( Smd[06], LinkToNodes,   sizeof(integer) );
  move( Smd[10], LinkToArcs,    sizeof(integer) );
  move( Smd[14], LinkToRegions, sizeof(integer) );
  move( Smd[18], LinkToPoints,  sizeof(integer) );
  move( Smd[22], LinkToTables,  sizeof(integer) );

  move( Smd[LinkToNodes],   NumNodes,   2 );
  move( Smd[LinkToArcs],    NumArcs,    2 );
  move( Smd[LinkToRegions], NumRegions, 2 );
  move( Smd[LinkToPoints],  NumPoints,  2 );
  move( Smd[LinkToTables],  NumTables,  2 );

  for i := 0 to NumArcs-1 do //*** loop along Arcs and load them as UDLines
  begin
    move( Smd[LinkToArcs+2+i*sizeof(ArcDescr)], ArcDescr, sizeof(ArcDescr) );

    UDLine := TN_UDDLine.Create;
    LinesRoot.AddOneChild( UDLine );

    UDLine.ObjName  := 'L' + IntToStr(i);
//##    UDLine.CObjTag := 0;
    UDLine.RC1 := 0;
    UDLine.RC2 := 0;
    UDLine.Accuracy := Accuracy;
    SetLength( UDLine.DC, ArcDescr.PointsInArc );

    for j := 0 to ArcDescr.PointsInArc-1 do // loop along all arc points
    begin
      move( Smd[ArcDescr.LinkToPoints+j*sizeof(SPoint)], SPoint, sizeof(SPoint) );
      UDLine.DC[j].X := AffCoefs4.CX*SPoint.X + AffCoefs4.SX;
      UDLine.DC[j].Y := AffCoefs4.CY*SPoint.Y + AffCoefs4.SY;
      N_IncEnvRect( EnvDRect, UDLine.DC[j] );
    end; // for j := 0 to ArcDescr.PointsInArc-1 do // loop along all arc points

  end; // for i := 0 to NumArcs-1 do //*** loop along Arcs and load them as UDLines

  //***** set RC1, RC2 fields by Smd's Regions info

  for i := 0 to NumRegions-1 do // loop along Regions
  begin
    move( Smd[LinkToRegions+2+i*sizeof(RegionDescr)], RegionDescr, sizeof(RegionDescr) );
    move( Smd[RegionDescr.LinkToBorders],   NumBordersInReg, 2 );
    move( Smd[RegionDescr.LinkToBorders+2], NumArcsInReg, 2 );
    LinkToArc := RegionDescr.LinkToBorders+4+NumBordersInReg*2; // to first Arc

    SAttributes := N_SmdGetAttribute( 0, Smd, RegionDescr.Table, RegionDescr.LinkToTableRecord );
    RegCode := StrToInt( SAttributes ) and $FFFF;

    for j := 0 to NumArcsInReg-1 do // loop along all arcs in cur. region
    begin
      move( Smd[LinkToArc+j*2], ArcNum, 2 );
      UDLine := TN_UDDLine(LinesRoot.DirChild( Abs(ArcNum)-1 ));

      //***** Sign of ArcNum (arc direction) is not always correct in SMD files!

      if ArcNum > 0 then
      begin
//        if ((UDLine.CObjTag and $FFFF) <> 0) and ((UDLine.CObjTag and $FFFF0000) <> 0) then
//          N_PCAdd( 5, Format( 'ArcNum=%d, RegCode=%d', [ArcNum, RegCode] ));

//        UDLine.CObjTag := UDLine.CObjTag or RegCode;
      end else
      begin
//        if (UDLine.CObjTag and $FFFF0000) <> 0 then
//        if ((UDLine.CObjTag and $FFFF) <> 0) and ((UDLine.CObjTag and $FFFF0000) <> 0) then
//          N_PCAdd( 5, Format( 'ArcNum=%d, RegCode=%d', [ArcNum, RegCode] ));

//        UDLine.CObjTag := UDLine.CObjTag or (RegCode shl 16);
      end;
//##
//      if ((UDLine.CObjTag and $FFFF) <> 0) and
//         ((UDLine.CObjTag and $FFFF0000) <> 0) then
//        Assert( False, 'Bad Topology!' );

//      if (UDLine.CObjTag and $FFFF) = 0 then
//        UDLine.CObjTag := UDLine.CObjTag or RegCode
//      else
//        UDLine.CObjTag := UDLine.CObjTag or (RegCode shl 16);

      if (UDLine.RC1 <> 0) and (UDLine.RC1 <> 0) then // just check error
        Assert( False, 'Bad Topology!' );

      if UDLine.RC1 = 0 then UDLine.RC1 := RegCode
                        else UDLine.RC2 := RegCode;

    end; // for j := 0 to NumArcsInReg-1 do // loop along all arcs in cur. region
  end; // for i := 0 to NumRegions-1 do // loop along Regions

  Close( FSmd );
  Result := 0; // Loaded OK
end; // end of procedure N_SmdToDLines

//************************************************ N_SmdToDPoints ***
// convert Smd file to TN_UDDPoints type childs in given PointsRoot
//
// LinesRoot   - root dir with DLines objects (at all levels),
// SmdFName    - full input file name (with .smd extention),
// AffCoefs4   - aff. trnasformation coefs,
// Accuracy    - given accuracy of all coords
// EnvDRect    - Envelope DRect (on output, after affine convertion)
//     Returns - 0 of OK, -1 if failed
//
function N_SmdToDPoints( PointsRoot: TN_UDBase; SmdFName: string;
                        const AffCoefs4: TN_AffCoefs4;
                        Accuracy: integer; var EnvDRect: TDRect ): integer;
var
  i, SmdSize: integer;
  PointDescr:    TN_PointDescr;
  LinkToNodes, LinkToArcs, LinkToRegions, LinkToPoints, LinkToTables: integer;
  NumNodes, NumArcs, NumRegions, NumPoints, NumTables: short;
  FSmd: File;
  Smd: TN_BArray;
  UDPoint: TN_UDDPoint;
  SAttributes: string;
begin
  Result := -1;
  if not FileExists(SmdFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + SmdFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FSmd, SmdFName );
  Reset     ( FSmd, 1 );
  EnvDRect.Left := N_NotADouble; // set "not initialized" flag

  SmdSize := FileSize( FSmd );
  SetLength( Smd, SmdSize );
  BlockRead ( FSmd, Smd[0], SmdSize ); // read whole Smd file

  move( Smd[06], LinkToNodes,   sizeof(integer) );
  move( Smd[10], LinkToArcs,    sizeof(integer) );
  move( Smd[14], LinkToRegions, sizeof(integer) );
  move( Smd[18], LinkToPoints,  sizeof(integer) );
  move( Smd[22], LinkToTables,  sizeof(integer) );

  move( Smd[LinkToNodes],   NumNodes,   2 );
  move( Smd[LinkToArcs],    NumArcs,    2 );
  move( Smd[LinkToRegions], NumRegions, 2 );
  move( Smd[LinkToPoints],  NumPoints,  2 );
  move( Smd[LinkToTables],  NumTables,  2 );

  for i := 0 to NumPoints-1 do //*** loop along Points and load them as UDPoints
  begin
    move( Smd[LinkToPoints+2+i*sizeof(PointDescr)], PointDescr, sizeof(PointDescr) );

    UDPoint := TN_UDDPoint.Create;
    PointsRoot.AddOneChild( UDPoint );

    UDPoint.ObjName  := 'P' + IntToStr(i);
    UDPoint.CObjTag  := 0;
    UDPoint.Accuracy := Accuracy;
    UDPoint.BP.X := AffCoefs4.CX*PointDescr.SPoint.X + AffCoefs4.SX;
    UDPoint.BP.Y := AffCoefs4.CY*PointDescr.SPoint.Y + AffCoefs4.SY;

    SAttributes := N_SmdGetAttribute( 0, Smd, PointDescr.Table, PointDescr.LinkToTableRecord );
    UDPoint.CObjCode := StrToInt( SAttributes );
  end; // for i := 0 to NumPoints-1 do //*** loop along Points

  Close( FSmd );
  Result := 0; // Loaded OK
end; // end of procedure N_SmdToDPoints


//********************************************* N_LoadVArray ***
// Create  in given Layer directory one of (TN_UD(I,D,S,IP,DP)PArray UObj,
// and load it from file
// (for strings - one per Row, for numbers in any format)
//
// Layer      - Archive Layer, where to create new TN_UDIPArray object
// FileName   - full input file name
// VArrayName - Name for created Array object
// VArrayType - =1-integers, =2-doubles, =3-strings,
//              =4-Int_Points, =5-Dbl_Points, 6-Int_Rects, =7-Dbl_Rects
//
procedure N_LoadVArray( Layer: TN_UDBase; FileName, VArrayName: string;
                                                    VArrayType: integer );
var
  FT: TextFile;
  S: string;
  ValueInd, IX, IY: integer;
  DX, DY: double;
  VArray: TN_UDBase;
begin
  if not FileExists(FileName) then
    raise Exception.Create( 'File  "' + FileName + '"  not found.' );
  try
  AssignFile( FT, FileName );
  Reset( FT );

  VArray := N_GetUObj( Layer, VArrayName );

  case VArrayType of

  1: begin //********************************************* integers
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDIArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDIArray(VArray).V) then
        SetLength( TK_UDIArray(VArray).V, ValueInd + 200 );
      Read( FT, IX );
      TK_UDIArray(VArray).V[ValueInd] := IX;
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDIArray(VArray).V, ValueInd-1 );
    end; // 1: begin // integers

  2: begin //********************************************* doubles
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDDArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDDArray(VArray).V) then
        SetLength( TK_UDDArray(VArray).V, ValueInd + 200 );
      Read( FT, DX );
      TK_UDDArray(VArray).V[ValueInd] := DX;
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDDArray(VArray).V, ValueInd-1 );
    end; // 2: begin // doubles

  3: begin //********************************************* strings
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDSArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDSArray(VArray).V) then
        SetLength( TK_UDSArray(VArray).V, ValueInd + 200 );
      ReadLn( FT, S );
      TK_UDSArray(VArray).V[ValueInd] := S;
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDSArray(VArray).V, ValueInd-1 );
    end; // 3: begin // strings

  4: begin //********************************************* integer points
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDIPArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDIPArray(VArray).V) then
        SetLength( TK_UDIPArray(VArray).V, ValueInd + 200 );
      Read( FT, IX, IY );
      TK_UDIPArray(VArray).V[ValueInd] := Point( IX, IY );
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDIPArray(VArray).V, ValueInd-1 );
    end; // 4: begin // integer points


  5: begin //********************************************* double points
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDDPArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDDPArray(VArray).V) then
        SetLength( TK_UDDPArray(VArray).V, ValueInd + 200 );
      Read( FT, DX, DY );
      TK_UDDPArray(VArray).V[ValueInd] := DPoint( DX, DY );
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDDPArray(VArray).V, ValueInd-1 );
    end; // 5: begin // double points

  6: begin //********************************************* integer Rects
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDIRArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDIRArray(VArray).V) then
        SetLength( TK_UDIRArray(VArray).V, ValueInd + 200 );
      Read( FT, IX, IY );
      TK_UDIRArray(VArray).V[ValueInd].TopLeft := Point( IX, IY );
      Read( FT, IX, IY );
      TK_UDIRArray(VArray).V[ValueInd].BottomRight := Point( IX, IY );
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDIRArray(VArray).V, ValueInd-1 );
    end; // 6: begin // integer Rects

  7: begin //********************************************* double Rects
    if VArray = nil then // do not exists, create it
    begin
      VArray := TK_UDDRArray.Create();
      N_AddUChild( Layer, VArray, VArrayName );
    end;
    ValueInd := 0;
    while True do // read Values one by one (not by rows)
    begin
      if EOF(FT) then Break;
      if ValueInd > High(TK_UDDRArray(VArray).V) then
        SetLength( TK_UDDRArray(VArray).V, ValueInd + 200 );
      Read( FT, DX, DY );
      TK_UDDRArray(VArray).V[ValueInd].TopLeft := DPoint( DX, DY );
      Read( FT, DX, DY );
      TK_UDDRArray(VArray).V[ValueInd].BottomRight := DPoint( DX, DY );
      Inc(ValueInd);
    end; // while True do
    SetLength( TK_UDDRArray(VArray).V, ValueInd-1 );
    end; // 7: begin // double Rects


  end; // case ArrayType of

  finally
  CloseFile( FT );
  end; // try
end; // end of procedure N_LoadVArray
}

//********************************************* N_SetDVectElem ***
// Convert Data vector Element form Text to Binary form
//
// PMem        - Pointer Mem, where to write Element in binary form
// ElemStr     - Data vector Element as string
// DVectorType - 0-integer, 1-float, 2-double, 3-string, 4-FPoint
//
procedure N_SetDVectElem( PMem: Pointer; ElemStr: string;
                                                 DVectorType: TN_DVectorType );
begin
  case DVectorType of
  dvtInteger: PInteger(PMem)^ := N_ScanInteger( ElemStr );
  dvtFloat:   PFloat(PMem)^   := N_ScanDouble( ElemStr );
  dvtDouble:  PDouble(PMem)^  := N_ScanDouble( ElemStr );
  dvtString:  PString(PMem)^  := N_ScanToken( ElemStr );
  dvtFPoint:  PFPoint(PMem)^  := N_ScanFPoint( ElemStr );
  else
    Assert( False, N_GES( 10 ) );
  end; // case DVectorType of
end; // procedure N_SetDVectElem

//********************************************* N_DBFToRArrays ***
// Import from DBF into RArrays given list of DBF Columns
// return 0 if OK
//
// DBFFileName  - DBF File Name
// ADVectDescrs - Array of Vector Descriptions
//
function N_DBFToRArrays( DBFFileName: string;
                                   ADVectDescrs: TN_ImpDVectDescrs ): integer;
var
  i, j, DBFFInd: integer;
  Fh: File;
  DBFRecBuf, ElemStr: string;
  DBF: TN_DBF;
  UDD: TK_UDFieldsDescr;
  PFD: TK_POneFieldExecDescr;
  WrkDescrs: TN_WrkImpDVectDescrs;
begin
  Result := -1;
  if not FileExists( DBFFileName ) then Exit;

  N_ROpenFile( Fh, DBFFileName );
  if FileSize(Fh) < Sizeof(TN_DBFHField) then // needed for dummy empty files
  begin
    Close( Fh );
    Exit;
  end;

  DBF := TN_DBF.Create;
  DBF.LoadHeader( Fh );

  SetLength( DBFRecBuf, DBF.Header[0].RecSize ); // Buf for reading DBF Records
  SetLength( WrkDescrs, Length(ADVectDescrs) );

  for i := 0 to High(ADVectDescrs) do // fill WrkDescrs array
  with ADVectDescrs[i], WrkDescrs[i] do
  begin
    ImpRArray.ASetLengthI( DBF.Header[0].RecCount );
    UDD := TK_UDFieldsDescr( ImpRArray.ElemType.DTCode );
    if Integer(UDD) <= Ord( nptNoData) then Exit;

    with UDD do
      PFD := GetFieldDescrByInd( IndexOfFieldDescr( ImpRAFieldName ) );

    if PFD = nil then Exit;

    ImpRAFieldOffset := PFD^.DataPos;
    ImpRAFieldSize := 4;
    if (DVectorType = dvtDouble) or (DVectorType = dvtFPoint) then
      ImpRAFieldSize := 8;

    if ImpRAFieldSize > PFD^.DataSize then Exit; // Error!

    DBFFInd := DBF.FieldIndexOf( DBFFieldName );
    if DBFFInd = -1 then Exit;

    DBFFieldOffset := DBF.Header[DBFFInd].FieldPos;
    DBFFieldSize   := DBF.Header[DBFFInd].FieldSize;
  end; // for i := 0 to High(ADVectDescrs) do // fill WrkDescrs array

  seek( Fh, DBF.Header[0].RecPos );
  for i := 0 to DBF.Header[0].RecCount-1 do // read and process DBF records
  begin
    BlockRead( Fh, DBFRecBuf, DBF.Header[0].RecSize ); // read next record

    for j := 0 to High(ADVectDescrs) do // set j-th element to all RArrays
    with ADVectDescrs[j], WrkDescrs[j] do
    begin
      ElemStr := Copy( DBFRecBuf, DBFFieldOffset+2, DBFFieldSize );
      N_SetDVectElem( TN_BytesPtr(ImpRArray.P(i)) + ImpRAFieldOffset,
                                                       ElemStr, DVectorType );
    end; // for j := 0 to High(ADVectDescrs) do // set j-th element to all RArrays
  end; // for i := 0 to DBF.Header[0].RecCount-1 do // read and process DBF records

  Close( Fh );
  DBF.Free;
  WrkDescrs := nil;
  Result := 0; // OK flag
end; // procedure N_DBFToRArrays

//**************************************************** N_ActionImportMIF1
// Import MIF-MID file Action 1:
//
// (for using in TN_UDAction under Action Name "ImportMIF1")
//
procedure N_ActionImportMIF1( APParams: TN_PCAction; AP1, AP2: Pointer );
var
  MIFInd, MIDInd, Flags, NumParts, NumPoints, PixSize: integer;
  NumCodeField, NumStrField, Code, NChanel, CDimInd: integer;
  Str, Token, MIFFName, MIDFName, ModeStr: string;
  BaseName, CurName, CObjName, FullName: string;
  DelChar: Char;
  DataRoot, MapRoot, CObjectsRoot: TN_UDBase;
  Maplayer: TN_UDMaplayer;
  UPoints: TN_UDPoints;
  ULines: TN_ULines;
  UDStrings: TK_UDRArray;
  MIFSL, MIDSL, TmpSL: TStringList;
  UDActionComp: TN_UDAction;
  DPoint: TDPoint;
  DCoords: TN_DPArray;
  SomeObj: boolean;
  Label GetNextHeaderRow, GetNextRow, Finish;

  procedure LoadCoords(); // local
  // Load Coords in DCoords Array
  var
    i: integer;
  begin
    SetLength( DCoords, NumPoints );
    for i := 0 to NumPoints-1 do
    begin
      Str := MIFSL[MIFInd+i];
      DCoords[i] := N_ScanDPoint( Str );
      DCoords[i].Y := -DCoords[i].Y;
    end;

    Inc( MIFInd, NumPoints );
  end; // procedure LoadCoords - local

begin //************************************ body of N_ActionImportMIF1
  UPoints   := nil; // to avoid varning
  ULines    := nil; // to avoid varning
  UDStrings := nil; // to avoid varning

  UDActionComp := TN_UDAction(AP1^);

  with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
  begin
    //***** Get Params

    DataRoot := CAUDBase1; // Data and CoordsObjects Root
    MapRoot  := CAUDBase2; // MapLayers Root
    MIFFName := K_ExpandFileName( CAFName1 );      // MIF File Name
    MIDFName := ChangeFileExt( MIFFName, '.mid' ); // MID File Name

    Str := CAParStr1;
    NChanel      := N_ScanInteger( Str ); // Int1
    NumCodeField := N_ScanInteger( Str ); // IPoint1.X
    NumStrField  := N_ScanInteger( Str ); // IPoint1.Y
    CDimInd      := N_ScanInteger( Str ) and $0F; // Flags2

    Flags    := CAFlags1;
    // bits $00000F - Protocol bits (0 - nothing)
    // bits $0000F0 - DrawMode ( bits4-5 of TN_CMapLayer.MLDrawMode (PathMode) )
    // bits $000100 - <>0 - clear DataRoot and MapRoot
    // bits $000200 - <>0 - add to existed CObjLayer, do not create new Map Layer
    // bits $00F000 - Point Sign Shape Flags (Rect, Romb, Ellipse, Plus)
    // bits $0F0000 - Point Sign Size minus 3 (0 means 3 pixels)

    ModeStr  := UpperCase(CAStr1); // 'Points', 'Lines', 'Conts', 'Labels'
    BaseName := CAStr2; // Base Name for Coords Obj and Map Layer
    DelChar  := Char( 9 );

    if (Flags and $0F) > 0 then
    begin
      Str := 'Begin Import from ' + MIFFName;
      N_AddStr( NChanel, '' );
      N_AddStr( NChanel, Str );
      N_CurShowStr( Str );
    end;

    //***** Create needed Objects

    MIFSL := TStringList.Create();
    MIDSL := TStringList.Create();
    TmpSL := TStringList.Create();

    MIFSL.LoadFromFile( MIFFName );
    if FileExists( MIDFName ) then
      MIDSL.LoadFromFile( MIDFName );

    if (Flags and $0100) <> 0 then // clear DataRoot and MapRoot
    begin
      DataRoot.ClearChilds();
      MapRoot.ClearChilds();

      if (Flags and $0F) > 0 then
        N_AddStr( NChanel, 'DataRoot and MapRoot Cleared' );

    end; // if (Flags and $0100) <> 0 then // clear DataRoot and MapRoot

    CObjectsRoot := DataRoot.DirChildByObjName( 'CObjects' );
    if CObjectsRoot = nil then
    begin
//      CObjectsRoot := N_CreateUChild( DataRoot, 'CObjects' );
      CObjectsRoot := TN_UDBase.Create();
      CObjectsRoot.ObjName := N_NotAString;
      CObjectsRoot.ObjName := N_CreateUniqueUObjName( DataRoot, 'CObjects' );
      DataRoot.AddOneChildV( CObjectsRoot );
    end;

    if ModeStr = 'POINTS' then //**************** Create UPoints and MapLayer
    begin
      CObjName := 'P'+BaseName; // UDPoints Name
      UPoints := TN_UDPoints(CObjectsRoot.DirChildByObjName( CObjName ));

      if UPoints = nil then
      begin
        UPoints := TN_UDPoints.Create;
        N_AddUChild( CObjectsRoot, UPoints, CObjName );
      end else
        UPoints.InitItems( 100, 100 );

//      FullName := UPoints.GetRefPath();
      FullName := K_GetPathToUObj( UPoints );

      UPoints.WComment := 'Created from ' + MIFFName;

      CurName := 'ML'+BaseName; // MapLayer Name
      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( CurName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, CurName );
      end;

      with MapLayer.InitMLParams( mltPoints1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLBrushColor := CAColor2;
        PWORD(@MLSShape)^ := (Flags and $0F000) shr 10;
        PixSize := ((Flags and $0F0000) shr 16) + 3;
        MLSSizeXY.X := PixSize;
        MLSSizeXY.Y := PixSize;
        if MLSShape = [] then MLSShape := [sshATriangle];
        K_SetUDRefField( TN_UDBase(MLCObj), UPoints );
      end;
    end; // if ModeStr = 'POINTS' then

    if ModeStr = 'LINES' then //**************** Create ULines and MapLayer
    begin
      CObjName := 'L'+BaseName; // ULines Name
      ULines := TN_ULines(CObjectsRoot.DirChildByObjName( CObjName ));

      if ULines = nil then
      begin
        ULines := TN_ULines.Create1( N_DoubleCoords );
        ULines.WAccuracy := 4;
        N_AddUChild( CObjectsRoot, ULines, CObjName );
      end else
      begin
        if (Flags and $0200) = 0 then // clear DataRoot and MapRoot
          ULines.InitItems( 100, 10000 );
      end;

//      FullName := ULines.GetRefPath();
      FullName := K_GetPathToUObj( ULines );

      if ULines.WComment = '' then
        ULines.WComment := 'Created from ' + MIFFName
      else
        ULines.WComment := ULines.WComment + ' + ' + ExtractFileName( MIFFName );

      CurName := 'ML'+BaseName; // MapLayer Name
      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( CurName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, CurName );
      end;

      with MapLayer.InitMLParams( mltLines1 )^ do
      begin
        MLPenColor   := CAColor1;
        MLBrushColor := CAColor2;
        MLDrawMode := MLDrawMode or (Flags and $030);
        K_SetUDRefField( TN_UDBase(MLCObj), ULines );
      end;
    end; // if ModeStr = 'LINES' then

    if ModeStr = 'LABELS' then //***** Create UPoints, UDStrings and MapLayer
    begin
      CObjName := 'P'+BaseName; // UDPoints Name
      UPoints := TN_UDPoints(CObjectsRoot.DirChildByObjName( CObjName ));

      if UPoints = nil then
      begin
        UPoints := TN_UDPoints.Create;
        N_AddUChild( CObjectsRoot, UPoints, CObjName );
      end else
        UPoints.InitItems( 100, 100 );

//      FullName := UPoints.GetRefPath();
      FullName := K_GetPathToUObj( UPoints );

      UPoints.WComment := 'Created from ' + MIFFName;

      CurName := 'DS'+BaseName; // Strings UDvector Name
      UDStrings := TK_UDRArray(CObjectsRoot.DirChildByObjName( CurName ));

      if UDStrings = nil then
      begin
        UDStrings := K_CreateUDByRTypeName( 'String', 3000 );
        N_AddUChild( DataRoot, UDStrings, CurName );
      end else
        UDStrings.ASetLength( 3000 );

      CurName := 'ML'+BaseName; // MapLayer Name
      MapLayer := TN_UDMapLayer(MapRoot.DirChildByObjName( CurName ));
      if MapLayer = nil then
      begin
        MapLayer := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
        N_AddUChild( MapRoot, MapLayer, CurName );
      end;

      with MapLayer.InitMLParams( mltHorLabels )^ do
      begin
        MLTextColor   := CAColor1;
        K_SetUDRefField( TN_UDBase(MLCObj), UPoints );
        K_SetUDRefField( TN_UDBase(MLDVect1), UDStrings );
      end;
    end; // if ModeStr = 'LABELS' then

    if (Flags and $0F) > 0 then
      N_AddStr( NChanel, 'CObjName: ' + FullName );

    //***** Process MIF Header

    MIFInd := 0;
    MIDInd := 0;

    GetNextHeaderRow: //************************
    Str := MIFSL[MIFInd];
    Inc( MIFInd );
    Token := UpperCase(N_ScanToken( Str ));

    if Token = 'DELIMITER' then // get Delimiter Character DelChar
    begin
      Token := N_ScanToken( Str );
      if Length(Token) > 0 then
        DelChar := Token[1];

      TmpSL.Delimiter := DelChar;
      TmpSL.QuoteChar := '"';

      goto GetNextHeaderRow;
    end; // if Token = 'Delimiter' then // get Delimiter Character DelChar

    if Token <> 'DATA' then goto GetNextHeaderRow;
    SomeObj := False;

    GetNextRow: //************************
    if MIFInd >= (MIFSL.Count) then goto Finish;
    Str := MIFSL[MIFInd];
    Inc( MIFInd );
    Token := UpperCase(N_ScanToken( Str ));

    if (Token = '') or (Token = 'NONE') then goto GetNextRow;

    //***** Process MIF Object ( POINT, PLINE, REGION )

    if Token = 'POINT' then // Point MIF Object
    begin
      DPoint := N_ScanDPoint( Str );
      DPoint.Y := -DPoint.Y;
      SomeObj := True;
    end; // if Token = 'POINT' then // Point Object

    if Token = 'PLINE' then // Polyline MIF Object
    begin
      Token := UpperCase(N_ScanToken( Str ));

      if Token = 'MULTIPLE' then
        NumParts := N_ScanInteger( Str )
      else
        NumParts := 1;

      Assert( NumParts = 1, 'Not Implemented!' );
      NumPoints := N_ScanInteger( Token );
      LoadCoords();
      DPoint := N_CalcPolylineCenter( PDPoint(@DCoords[0]), Length(DCoords) );
      SomeObj := True;
    end; // if Token = 'PLINE' then // Polyline Object

    if Token = 'REGION' then // Region MIF Object
    begin
      NumParts := N_ScanInteger( Str );
      Assert( NumParts = 1, 'Not Implemented!' );

      Str := MIFSL[MIFInd];
      Inc( MIFInd );
      NumPoints := N_ScanInteger( Str );
      LoadCoords();
      DPoint := N_CalcPolylineCenter( PDPoint(@DCoords[0]), Length(DCoords) );
      SomeObj := True;
    end; // if Token = 'REGION' then // Region Object


    //***** Add just red MIF Object as new Item of Coords Object

    if SomeObj then // Some MIF Object was red
    begin

      if ModeStr = 'POINTS' then
      begin
        if NumCodeField >= 1 then
        begin
          TmpSL.DelimitedText := MIDSL[MidInd];
          Str := TmpSL[NumCodeField-1];
          Code := N_ScanInteger( Str );
        end else
          Code := -1;

        UPoints.AddOnePointItem( DPoint );
        UPoints.SetItemTwoCodes( MidInd, CDimInd, Code, -1 );
      end; // if ModeStr = 'POINTS' then

      if ModeStr = 'LINES' then
      begin
        if NumCodeField >= 1 then
        begin
          TmpSL.DelimitedText := MIDSL[MidInd];
          Str := TmpSL[NumCodeField-1];
          Code := N_ScanInteger( Str );
        end else
          Code := -1;

        ULines.AddSimpleItem( DCoords, -1 );
        ULines.SetItemTwoCodes( MidInd, CDimInd, Code, -1 );
      end; // if ModeStr = 'LINES' then

      if ModeStr = 'LABELS' then //*** Labels, Add Point Coords and Label Content
      begin
        UPoints.AddOnePointItem( DPoint );

        if NumStrField >= 1 then
        begin
          TmpSL.DelimitedText := MIDSL[MidInd];
          Str := TmpSL[NumStrField-1];
        end else
          Str := 'Label'+IntToStr(MidInd);

        PString(UDStrings.PDE(MidInd))^ := Str;
      end; // if ModeStr = 'LABELS' then

      Inc( MidInd );
      SomeObj := False;
    end; // if SomeObj then // Some MIF Object was red

    goto GetNextRow; // Process next Object


    Finish: //***** all MIF Objects are processed

    if ModeStr = 'LINES' then //**********************
    begin

    end; // if ModeStr = 'LINES' then

    if ModeStr = 'LABELS' then //*********************
    begin
      UDStrings.ASetLength( MidInd );
    end; // if ModeStr = 'LABELS' then

    //***** All done, Draw created map and delete temporary objects

    if N_ActiveVTreeFrame <> nil then
      N_ActiveVTreeFrame.aViewRefreshFrameExecute( nil );

    MIFSL.Free;
    MIDSL.Free;
    TmpSL.Free;

    if (Flags and $0F) <> 0 then
    begin
      Str := 'End Import from ' + MIFFName;
      N_AddStr( NChanel, Str );
      N_CurShowStr( Str );
    end;

  end; // with APParams^, UDActionComp.PIDP()^, UDActionComp.NGCont do
end; //*** end of procedure N_ActionImportMIF1

var
  N_Rus89ToFOkrug: Array [0..93] of integer =
   ( 8,6,4,6,9,9,9,8,9,2, // 01 - 10
     2,4,4,7,9,4,6,4,6,9, // 11 - 20
     4,6,8,6,7,9,7,7,2,8, // 21 - 30
     1,1,1,8,2,1,1,6,2,1, // 31 - 40
     7,6,4,1,5,1,2,1,7,1, // 41 - 50
     2,4,2,6,6,4,1,4,4,2, // 51 - 60
     8,1,4,4,7,5,1,1,1,6, // 61 - 70
     1,5,4,5,6,1,7,6,4,7, // 71 - 80
     2,6,6,5,7,6,5,2,1,4, // 81 - 90
     7,6,6,6 );           // 11 - 94

//********** Federal Okrug Codes:
// 1	Центральный федеральный округ
// 2	Северо-Западный федеральный округ
// 3	Южный федеральный округ (старый - (новый Южный и Северо-Кавказский))
// 4	Приволжский федеральный округ
// 5	Уральский федеральный округ
// 6	Сибирский федеральный округ
// 7	Дальневосточный федеральный округ
// 8	Южный федеральный округ (новый)
// 9	Северо-Кавказский федеральный округ

//***************************************************** N_ConvRus89ToFOkrug ***
// Convert given Rus89 Code (1-94) To Federal Okrug Code (1-9)
//
//     Parameters
// ACode  - given Rus89 Code (1-94)
// Result - Federal Okrug Code (1-2, 4-9), never returns 3
//
function N_ConvRus89ToFOkrug( ACode: integer ): integer;
begin
  if (ACode < 1) or (ACode > 94) then
    Result := -1
  else
    Result := N_Rus89ToFOkrug[ACode-1];
end; // function N_ConvRus89CodeToFOkrug

//***************************************************** N_CreateTTableByDBF ***
// Create TTable object for working with given DBF file
//
//     Parameters
// AFileName  - given DBF File Name
// Result     - Created TTable object or nil if some errors
//
function N_CreateTTableByDBF( AFileName: string ): TTable;
begin
  Result := TTable.Create( nil );
  Result.DatabaseName := ExtractFilePath( AFileName );
  Result.TableName := ExtractFileName( AFileName );
  Result.TableType := ttDBase;
  Result.Open;

  if Result.State = dsInactive then
  begin
    Result.Free;
    Result := nil;
  end;
end; // function N_CreateTTableByDBF

//************************************************* N_PrepParaBoxesByPoints ***
// Prepare ParaBoxes By given UDPoints
//
//     Parameters
// APatPB     - given TN_UDParaBox Pattern
// AParent    - given Parent of all Resulting TN_UDParaBoxes
// AFont      - given Font ( TN_UDNFont or RArray of TN_PNFont type) used in TextBlock
// AParStr    - given params string (see bellow)
// AIntPar    - given Integer Parametr (see bellow)
// AUDPoints  - given UDPoints CObj Layer
// APTexts    - Pointer to ParaBox Contens
//
// AParStr contains '#' char followed by Federal Okrug code (1-9) or
// just '=' char that means using Item Index as Parabox content or
// DBF full File Name (AIntPar is DBF Field Index >=0) (e.g. '#7' or 'aa.dbf')
//
procedure N_PrepParaBoxesByPoints( APatPB: TN_UDParaBox; AParent: TN_UDBase; AFont: TObject;
         AParStr: string; AUDPoints: TN_UDPoints; AIntPar: integer = 0; APTexts: PString = nil );
var
  i, CDimInd, CSInd, CurPointCode, CurOkrugCode, NeededOkrugCode : integer;
  CurDPCoords: TDPoint;
  CurOTBMText, CurObjName, NeededOkrugCodeStr: string;
  PCurName: Pstring;
  PointsCS: TK_UDDCSpace;
  CurParaBox: TN_UDParaBox;
  DBF: TTable;
begin
  CDimInd := 0;
  DBF := nil; // to avoid warning
  Assert( AUDPoints <> nil, 'AUDPoints=nil' );
  Assert( AUDPoints.CI = N_UDPointsCI, 'Not UDPoints' );
  PointsCS := AUDPoints.GetCS( CDimInd );

  if Length(AParStr) > 6 then
  begin
    if (AParStr[1] <> '#') and (AParStr[1] <> '=') then
    begin
      DBF := N_CreateTTableByDBF( AParStr );
    end; // if (AParStr[1] <> '#') and (AParStr[1] <> '=') then
  end; // if Length(AParStr) > 6 then

  for i := 0 to AUDPoints.WNumItems-1 do // along all given Points
  begin
    CurPointCode := AUDPoints.GetItemFirstCode( i, CDimInd );
    CurDPCoords  := AUDPoints.GetPointCoords( i, 0 );

    if AParStr = '' then // Use APTexts for all ParaBoxes contenet
    begin

      if APTexts <> nil then
      begin
        PCurName := APTexts;
        Inc( PCurName, i );
        CurOTBMText := PCurName^;
      end else // APTexts = nil
        CurOTBMText := 'NoAPTexts';

    end else if AParStr[1] = '#' then // Use Rus89 Name by CurPointCode, but only for given Okrug
    begin
      NeededOkrugCodeStr :=AParStr;
      NeededOkrugCodeStr[1] := ' '; // just to use StrToInt
      NeededOkrugCode := StrToInt( NeededOkrugCodeStr ); // given Okrug, do not use if <= 0

      if NeededOkrugCode > 0 then // NeededOkrugCode is given, check it
      begin
        CurOkrugCode := N_ConvRus89ToFOkrug( CurPointCode );

        if NeededOkrugCode <> 3 then
        begin
          if CurOkrugCode <> NeededOkrugCode then // Skip not needed points
            Continue;
        end else // NeededOkrugCode = 3 - Old Южный, needed codes are 8 or 9
        begin
          if (CurOkrugCode <> 8) and (CurOkrugCode <> 9) then // Skip not needed points
            Continue;
        end;

        //*** Here: CurOkrugCode is OK

        if PointsCS <> nil then
        begin
          CSInd := PointsCS.IndexByCode( IntToStr(CurPointCode) );
          PointsCS.GetItemsInfo( @CurOTBMText, K_csiCSName, CSInd ); // set CurOTBMText
        end else // PointsCS = nil
          CurOTBMText := 'BadPointCode=' + IntToStr(CurPointCode);

        if LeftStr(CurOTBMText, 4 ) = 'респ' then
          CurOTBMText[1] := 'Р'; // conv респ -> Респ

      end; // if NeededOkrugCode > 0 then // NeededOkrugCode is given. check it

    end else if AParStr[1] = '=' then // use Item Index as Parabox content
    begin
      CurOTBMText := Format( 'Ind=%d', [i] );
    end else // AParStr[1] <> '#' or '=', AParStr contains DBF full File Name and DBF Field number
    begin
      CurOTBMText := DBF.Fields.Fields[AIntPar].asString;
      DBF.Next; // to Next DBF Record
    end;

    //*** Here: CurOTBMText is OK, prepare ParaBox

    CurObjName := N_ConvToProperName( CurOTBMText );
    CurParaBox := N_PrepParaBox( APatPB, AParent, CurObjName );
    CurParaBox.FillParaBox1( CurOTBMText, FPoint(CurDPCoords), AFont, $01 ); // $01 means User Coords Type
  end; // for i := 0 to AUDPoints.WNumItems-1 do // along all given Points

end; // procedure N_PrepParaBoxesByPoints


//************************ Old obsolete Procedures

//********************************************************** N_GetShapeInfo ***
// Obsolete (shx file is not use)
//
// Get Info about given Shape file in TN_ShapeInfo record
//
//     Parameters
// AShapeFName - Source Shape file Name,
// APShapeInfo - given pointer to TN_ShapeInfo record to fill
//
procedure N_GetShapeInfo( AShapeFName: string; APShapeInfo: TN_PShapeInfo );
var
  FShape: File;
  Header: array[0..99] of byte;
  Content: TN_BArray;
  ContentSize, FileCode, ShapeType, NumParts, NumPoints: integer;
  RecordNumber, TotalPoints, TotalParts: integer;
begin
  if APShapeInfo = nil then Exit; // a precation

  if not FileExists( AShapeFName ) then
  begin
    APShapeInfo^.SIFileType := N_ShapeNoFile; // File not found
    Exit;
  end;

  AssignFile( FShape, AShapeFName ); // open input Shape file
  Reset     ( FShape, 1 );

  if FileSize( FShape ) < 100 then // needed for dummy small files
  begin
    APShapeInfo^.SIFileType := N_ShapeBadFile; // Bad File
    Close( FShape );
    Exit;
  end;

  BlockRead ( FShape, Header[0], 100 ); // read and check Shape file Header
  N_Reverse4Bytes( @Header[0], @FileCode );

  if FileCode <> 9994 then
  begin
    APShapeInfo^.SIFileType := N_ShapeBadFile; // Bad File
    Close( FShape );
    Exit;
  end;

  APShapeInfo^.SIFileSize := FileSize( FShape );

  move( Header[32], ShapeType, 4 );
  APShapeInfo^.SIFileType := ShapeType;

  move( Header[36], APShapeInfo^.SIEnvDRect, SizeOf(TDRect) );

  TotalPoints := 0;
  TotalParts  := 0;
  RecordNumber := 0; // to avoid warning
  SetLength( Content, 10000 );

  while True do
  begin
    if EOF(FShape) then Break;

    if ( FileSize( FShape ) - FilePos( FShape ) ) < 8 then
    begin
      N_i := 1;
    end;

    BlockRead ( FShape, Header[0], 8 );
    N_Reverse4Bytes( @Header[0], @RecordNumber );
    if RecordNumber = 25 then
      N_i := 1;

    N_Reverse4Bytes( @Header[4], @ContentSize );
    ContentSize := 2*ContentSize; // conv from words to bytes

    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + ContentSize div 2 );

    BlockRead ( FShape, Content[0], ContentSize );
    move( Content[0], ShapeType, 4 );

    case ShapeType of //*********

    N_ShapeNull: //******************************* 0, NULL Record
    begin
      Continue;
    end;

    N_ShapePoint: //****************************** 1, One Point Record
    begin
      Inc( TotalPoints );
      Inc( TotalParts );
      Continue;
    end;

    N_ShapePolyLine: //**************************** 3, Polyline Record
    begin
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      Continue;
    end;

    N_ShapePolygon: //***************************** 5, Polygon Record
    begin
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      Continue;
    end;

    N_ShapeMultiPoint: //************************** 8, MultiPoint Record
    begin
      move( Content[36], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Continue;
    end;

    end; // case ShapeType of

  end; // while True do

  APShapeInfo^.SINumRecords := RecordNumber; // Whole Number of Records in File
  APShapeInfo^.SINumParts   := TotalParts;   // Whole Number of Parts  in File
  APShapeInfo^.SINumPoints  := TotalPoints;  // Whole Number of Points in File

  Close( FShape );
end; // procedure N_GetShapeInfo

//*************************************************** N_AddShapeHeaderInfo1 ***
// Obsolete, simple direct Shape file parsing
//
// add to given SL (TStrings obj) info lines about given Shape file
//
// SL         - SL (TStrings obj) where to add strings
// ShapeFName - Shape file Name,
// AFlags     - what info is needed flags:
//              bit0($01) - EnvRect info is needed
//
procedure N_AddShapeHeaderInfo1( SL: TStrings; ShapeFName: string; AFlags: integer );
var
  ShapeType: integer;
  ShapeTypeStr: string;
  FShape: File;
  Header: array[0..99] of byte;
  EnvDRect: TDRect;
begin
  if not FileExists( ShapeFName ) then Exit;
  AssignFile( FShape, ShapeFName );
  N_i := FileMode;
  FileMode := 0; // set read only mode
  Reset     ( FShape, 1 );
  FileMode := N_i; // rstore previous value
  if FileSize(FShape) < 100 then // needed for dummy empty files
  begin
    Close( FShape );
    Exit;
  end;
  BlockRead( FShape, Header[0], 100 ); // read and check Shape file Header

  move( Header[32], ShapeType, 4 );
  ShapeTypeStr := N_ShapeTypeToStr( ShapeType );

  SL.Add( Format( 'Shape File: "%s" (%s), Size (in Kb): %.1f ',
                     [ShapeFName, ShapeTypeStr, FileSize(FShape)/1024] ) );

  if (AFlags and $01) <> 0 then // add EnvRect info
  begin
    move( Header[36], EnvDRect, SizeOf(EnvDRect) );
    SL.Add( Format( ' EnvRect: ( XMin=%.3e, XMax=%.3e, YMin=%.3e, YMax=%.3e )',
           [EnvDRect.Left, EnvDRect.Right, EnvDRect.Top,  EnvDRect.Bottom] ) );
  end;
  Close( FShape );
end; // procedure N_AddShapeHeaderInfo1

//********************************************************** N_ShapeToASCII ***
// Obsolete (shx file is not use)
//
// Convert given Shape file to ASCII file (convert full info)
//
//     Parameters
// ShapeFName - Source Shape file Name,
// ASCIIFName - Resulting ASCII file Name
// Accuracy   - number of decimal digits in coords representation
// AFlags     - what info is not needed flags
//
procedure N_ShapeToASCII( ShapeFName, ASCIIFName: string; Accuracy: integer; AFlags: TN_ShapeShowFlags );
var
  FShape: File;
  FASCII: TextFile;
  Header:  array[0..99] of byte;
  Content: TN_BArray;
  ContentSize, ShapeType, NumParts, NumPoints: integer;
  i, j, NextInt, BegPointInPartInd, FileCode: integer;
  NumPointsInPart, MaxParts, RecordNumber: integer;
  MaxPointsInRecord, MaxPointsInLine: integer;
  TotalPoints, TotalParts: integer;
  X,Y: double;
  ShapeTypeStr: string;
  DBF: TTable;
  Str, TmpName, DBFFileName: string;
  EnvDRect: TDRect;
  Label Fin;

  procedure AddStr( AStr: string ); // local
  begin
    WriteLn( FASCII, AStr );
    N_Dump1Str( AStr );
  end; // procedure AddStr - local

begin
  if not FileExists(ShapeFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + ShapeFName + '"  is absent.' );
    Exit;
  end;

  AssignFile( FShape, ShapeFName ); // open input Shape file
  Reset     ( FShape, 1 );

  N_i := FileMode;
  AssignFile( FASCII, ASCIIFName ); // open output ASCII file
  Rewrite( FASCII );

  DBF := TTable.Create( nil ); // open accompaning DBF file
  DBF.DatabaseName := ExtractFilePath( ShapeFName );
  TmpName := ExtractFileName( ShapeFName );
  DBFFileName := Copy( TmpName, 1, Length(TmpName)-3 ) + 'dbf';
  DBF.TableName := DBFFileName;
  DBF.TableType := ttDBase;
  DBF.Open;

  BlockRead ( FShape, Header[0], 100 ); // read and check Shape file Header
  N_Reverse4Bytes( @Header[0], @FileCode );
  if FileCode <> 9994 then ShowMessage( 'Error: Bad file code (not 9994)!' );
  move( Header[32], ShapeType, 4 );
  ShapeTypeStr := N_ShapeTypeToStr( ShapeType );

  //***** write ASCII file Header

  AddStr( ' Input  file: ' + ShapeFName + '   ' +
                       ShapeTypeStr + ' (' + IntToStr(ShapeType) + ')' );
//  AddStr( ' Output file: ' + ASCIIFName );

  if not ((ssfSkipShape in AFlags) or (ssfSkipEnvDRect in AFlags)) then // Show Bound Rect
  begin
    move( Header[36], EnvDRect, SizeOf(EnvDRect) );
    AddStr( Format( ' Box Rect: ( XMin=%g, XMax=%g, YMin=%g, YMax=%g )',
                [ EnvDRect.Left, EnvDRect.Right, EnvDRect.Top,  EnvDRect.Bottom ] ) );
    AddStr( '' );
  end; // if not ((ssfSkipShape in AFlags) or (ssfSkipEnvDRect in AFlags)) then // Show Bound Rect

  MaxParts    := 0;
  TotalPoints := 0;
  TotalParts  := 0;
  MaxPointsInRecord := 0;
  MaxPointsInLine   := 0;
  RecordNumber := 0; // to avoid warning
  SetLength( Content, 10000 );
  EnvDRect.Left  := 1;
  EnvDRect.Right := 0; // initialize

  while True do
  begin
    if RecordNumber >= 24 then
    begin
      N_Dump1Str( Format( 'FileSize=%x, Pos=%x', [FileSize(FShape), FilePos(FShape) ] ) );
      N_Dump2Str( Format( 'FileSize=%x, Pos=%x', [FileSize(FShape), FilePos(FShape) ] ) );
    end;

    if EOF(FShape) then Break;
    N_StateString.Show( 'Converting to ASCII: ', FilePos(FShape)/FileSize(FShape));
    BlockRead ( FShape, Header[0], 8 );
    N_Reverse4Bytes( @Header[0], @RecordNumber );
    if RecordNumber = 26 then
      N_i := 1;

    N_Reverse4Bytes( @Header[4], @ContentSize );
    ContentSize := 2*ContentSize; // conv from words to bytes

    if not (ssfSkipShape in AFlags) then
      AddStr( Format( '  Record %d of %d bytes', [RecordNumber, ContentSize] ) );

    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + Length(Content) div 2 );

    if MaxPointsInRecord < ((ContentSize-48) div 16) then
      MaxPointsInRecord := (ContentSize-48) div 16;

    BlockRead ( FShape, Content[0], ContentSize );
    move( Content[0], ShapeType, 4 );

    if not (ssfSkipDBFHeader in AFlags) then // Show all DBF Fields
    begin
      Str := 'DBF: ';
      for i := 0 to DBF.Fields.Count-1 do
        with DBF.Fields.Fields[i] do
        begin
          Str := Str + FieldName + '=' + asString + '  ';
        end;
      AddStr( Str );
    end; // if not (ssfSkipDBF in AFlags) then // Show all DBF Fields

    DBF.Next;

    case ShapeType of //*********

    0://****************************** NULL Record
    begin
      if (ssfSkipShape in AFlags) then Continue;

      AddStr( '           NULL Record' );

      Continue;
    end;

    1://****************************** One Point Record
    begin
      if (ssfSkipShape in AFlags) then Continue;

      AddStr( '           One Point' );
      move( Content[4], X,  8 );
      move( Content[12], Y,  8 );

      AddStr( Format( ' %g %g', [X, Y] ) );

      Inc( TotalPoints );
      Inc( TotalParts );
      Continue;
    end;

    3: //****************************** Polyline Record
    begin
      if (ssfSkipShape in AFlags) then Continue;

      move( Content[4], EnvDRect, SizeOf(EnvDRect) );
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      MaxParts := Max( MaxParts, NumParts );
      AddStr( Format( '   Polyline of %d parts, %d points, '+
                               ' Box=(%g, %g, %g, %g)', [NumParts, NumPoints,
             EnvDRect.Left, EnvDRect.Top, EnvDRect.Right, EnvDRect.Bottom] ) );

      for i := 0 to NumParts-1 do
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 );
        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        Inc(TotalParts);
        if MaxPointsInLine < NumPointsInPart then
          MaxPointsInLine := NumPointsInPart;

        if not (ssfSkipShape in AFlags) then
          AddStr( Format( '     Line %d  Part %d  of %d Points',
                                       [RecordNumber, i+1, NumPointsInPart] ) );

        for j := 0 to NumPointsInPart-1 do
        begin
          if (ssfSkipShape in AFlags) or (ssfSkipAllCoords in AFlags) then
            Continue; // skip all coords

          if ( (ssfSkipIntCoords in AFlags) and (j > 0) and (j < (NumPointsInPart-1)) ) then
            Continue; // skip internal coords

          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)], X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );
          AddStr( Format( ' %d %g %g', [j, X, Y] ) );
        end; // for j := 0 to NumPointsInPart do

        if not ( (ssfSkipShape in AFlags) or (ssfSkipAllCoords in AFlags) or
                 (ssfSkipIntCoords in AFlags) ) then
          AddStr( 'End' );

        AddStr( '' );
      end; // for i := 0 to NumParts-1 do
      Continue;
    end;

    5: //****************************** Polygon Record
    begin
      if (ssfSkipShape in AFlags) then Continue;

      move( Content[4],  EnvDRect, SizeOf(EnvDRect) );
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      MaxParts := Max( MaxParts, NumParts );
      AddStr( Format( '   Polygon of %d ring(s), %d points, ' +
                               ' Box=(%g, %g, %g, %g)', [NumParts, NumPoints,
             EnvDRect.Left, EnvDRect.Top, EnvDRect.Right, EnvDRect.Bottom] ) );
      for i := 0 to NumParts-1 do
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 );

        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        if MaxPointsInLine < NumPointsInPart then
          MaxPointsInLine := NumPointsInPart;

        AddStr( Format( '     Polygon %d  Ring %d  of %d Points',
                                     [RecordNumber, i+1, NumPointsInPart] ) );
        for j := 0 to NumPointsInPart-1 do
        begin
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)], X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );
          AddStr( Format( ' %d %g %g', [j, X, Y] ) );
        end; // for j := 0 to NumPointsInPart do
        AddStr( 'End' );
        AddStr( '' );
      end; // for i := 0 to NumParts-1 do
      Continue;
    end;

    8: //****************************** MultiPoint Record
    begin
      if (ssfSkipShape in AFlags) then Continue;

      move( Content[36], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      AddStr( Format( '           MultiPoint of %d points',
                                                  [NumPoints] ) );
      for i := 0 to NumPoints-1 do
      begin
        move( Content[40+16*i], X,  8 );
        move( Content[40+16*i+8], Y,  8 );
        AddStr( Format( ' %d %g %g', [i, X, Y] ) );
      end; // for i := 0 to NumParts-1 do
      AddStr( 'End' );
      AddStr( '' );
      Continue;
    end;

    end; // case ShapeType of

    ShowMessage( IntToStr(ShapeType) + ', ShapeType is not Implemented!' );
  end; // while True do

  Fin:
  DBF.Close;
  DBF.Free;

  if not ((ssfSkipShape in AFlags) or (ssfSkipSummary in AFlags)) then // Show Summary
  begin
    AddStr( '' );
    AddStr( Format( '  Total Points  = %d', [TotalPoints] ) );
    AddStr( Format( '  Total Parts   = %d', [TotalParts]  ) );
    AddStr( Format( '  Total Records = %d', [RecordNumber]    ) );
    AddStr( '' );
    AddStr( Format( '  Max Parts  in Record = %d', [MaxParts]    ) );
    AddStr( Format( '  Max Points in Record = %d', [MaxPointsInRecord]  ) );
    AddStr( Format( '  Max Points in Part   = %d', [MaxPointsInLine]  ) );
    AddStr( '' );
    AddStr( Format( '  Average Points in Part   = %d',
                                      [Round(1.0*TotalPoints/TotalParts)] ) );
  end; // if not ((ssfSkipShape in AFlags) or (ssfSkipSummary in AFlags)) then // Show Summary

  AddStr( '' );
  AddStr( 'End of file' );

  Close( FShape );
  Close( FASCII );
end; // end of procedure N_ShapeToASCII

//********************************************************* N_ShapeToASCII2 ***
// Obsolete (shx file is not use)
//
// convert given Shape file to ASCII file in compact form (exclude intermediate points)
// ShapeFName - Shape file Name,
// ASCIIFName - ASCII file Name
//
procedure N_ShapeToASCII2( ShapeFName, ASCIIFName: string; Accuracy: integer );
var
  FShape: File;
  FASCII: TextFile;
  Header:  array[0..99] of byte;
  Content: TN_BArray;
  ContentSize, ShapeType, NumParts, NumPoints: integer;
  i, j, NextInt, BegPointInPartInd, FileCode: integer;
  NumPointsInPart, MaxParts, RecordNumber: integer;
  MaxPointsInRecord, MaxPointsInLine: integer;
  TotalPoints, TotalParts: integer;
  X,Y: double;
  ShapeTypeStr: string;
  DBF: TTable;
  Str, TmpName, DBFFileName: string;
  EnvDRect: TDRect;
  Label Fin;
begin
  if not FileExists(ShapeFName) then
  begin
    Beep;
    ShowMessage( 'Error: File  "' + ShapeFName + '"  is absent.' );
    Exit;
  end;
  AssignFile( FShape, ShapeFName ); // open input Shape file
  Reset     ( FShape, 1 );

  N_i := FileMode;
  AssignFile( FASCII, ASCIIFName ); // open output ASCII file
  Rewrite( FASCII );

  DBF := TTable.Create( nil ); // open accompaning DBF file
  DBF.DatabaseName := ExtractFilePath( ShapeFName );
  TmpName := ExtractFileName( ShapeFName );
  DBFFileName := Copy( TmpName, 1, Length(TmpName)-3 ) + 'dbf';
  DBF.TableName := DBFFileName;
  DBF.TableType := ttDBase;
  DBF.Open;

  BlockRead ( FShape, Header[0], 100 ); // read and check Shape file Header
  N_Reverse4Bytes( @Header[0], @FileCode );
  if FileCode <> 9994 then ShowMessage( 'Error: Bad file code (not 9994)!' );
  move( Header[32], ShapeType, 4 );

  case ShapeType of
    1: ShapeTypeStr := 'Point';
    3: ShapeTypeStr := 'Polyline';
    5: ShapeTypeStr := 'Polygon';
  else
    ShapeTypeStr := IntToStr(ShapeType) + ', not Implemented!';
  end; // case ShapeType of

  //***** write ASCII file Header

  WriteLn( FASCII, ' Input  file: ' + ShapeFName + '   ' +
                       ShapeTypeStr + ' (' + IntToStr(ShapeType) + ')' );
  WriteLn( FASCII, ' Output file: ' + ASCIIFName );

  move( Header[36], EnvDRect, SizeOf(EnvDRect) );
  WriteLn( FASCII, Format( ' Box Rect: ( XMin=%g, XMax=%g, YMin=%g, YMax=%g )',
   [ EnvDRect.Left, EnvDRect.Right,
     EnvDRect.Top,  EnvDRect.Bottom ] ) );
  WriteLn( FASCII, '' );

  MaxParts    := 0;
  TotalPoints := 0;
  TotalParts  := 0;
  MaxPointsInRecord := 0;
  MaxPointsInLine   := 0;
  RecordNumber := 0; // to avoid warning
  SetLength( Content, 10000 );
  EnvDRect.Left  := 1;
  EnvDRect.Right := 0; // initialize

  while True do
  begin
    if EOF(FShape) then Break;
    N_StateString.Show( 'Converting to ASCII: ', FilePos(FShape)/FileSize(FShape));
    BlockRead ( FShape, Header[0], 8 );
    N_Reverse4Bytes( @Header[0], @RecordNumber );
    N_Reverse4Bytes( @Header[4], @ContentSize );
    ContentSize := 2*ContentSize; // conv from words to bytes
    WriteLn( FASCII, Format( '  Record %d of %d bytes',
                                            [RecordNumber, ContentSize] ) );
    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + Length(Content) div 2 );
    if MaxPointsInRecord < ((ContentSize-48) div 16) then
      MaxPointsInRecord := (ContentSize-48) div 16;
    BlockRead ( FShape, Content[0], ContentSize );
    move( Content[0], ShapeType, 4 );

    Str := 'DBF: ';
    for i := 0 to DBF.Fields.Count-1 do
    with DBF.Fields.Fields[i] do
    begin
      Str := Str + FieldName + '=' + asString + '  ';
    end;
    WriteLn( FASCII, Str );
    DBF.Next;

    case ShapeType of //*********

    0: //****************************** NULL Record
    begin
      WriteLn( FASCII, '           NULL Record' );
      Continue;
    end;

    1: //****************************** One Point Record
    begin
      WriteLn( FASCII, '           One Point' );
          move( Content[4], X,  8 );
          move( Content[12], Y,  8 );
          WriteLn( FASCII, Format( ' %g %g', [X, Y] ) );
      Inc( TotalPoints );
      Inc( TotalParts );
      Continue;
    end;

    3: //****************************** Polyline Record
    begin
      move( Content[4], EnvDRect, SizeOf(EnvDRect) );
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      MaxParts := Max( MaxParts, NumParts );
      WriteLn( FASCII, Format( '   Polyline of %d parts, %d points, '+
                               ' Box=(%g, %g, %g, %g)', [NumParts, NumPoints,
             EnvDRect.Left, EnvDRect.Top, EnvDRect.Right, EnvDRect.Bottom] ) );

      for i := 0 to NumParts-1 do
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 );
        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        Inc(TotalParts);
        if MaxPointsInLine < NumPointsInPart then
          MaxPointsInLine := NumPointsInPart;

        WriteLn( FASCII, Format( '     Line %d  Part %d  of %d Points',
                                       [RecordNumber, i+1, NumPointsInPart] ) );
        for j := 0 to NumPointsInPart-1 do
        begin
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)], X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );

          if (j = 0) or (j = NumPointsInPart-1) then
            WriteLn( FASCII, Format( ' %d %g %g', [j, X, Y] ) );
        end; // for j := 0 to NumPointsInPart do
//        WriteLn( FASCII, 'End' );
        WriteLn( FASCII, '' );
      end; // for i := 0 to NumParts-1 do
      Continue;
    end;

    5: //****************************** Polygon Record
    begin
      move( Content[4],  EnvDRect, SizeOf(EnvDRect) );
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      Inc( TotalParts, NumParts );
      MaxParts := Max( MaxParts, NumParts );
      WriteLn( FASCII, Format( '   Polygon of %d ring(s), %d points, ' +
                               ' Box=(%g, %g, %g, %g)', [NumParts, NumPoints,
             EnvDRect.Left, EnvDRect.Top, EnvDRect.Right, EnvDRect.Bottom] ) );
      for i := 0 to NumParts-1 do
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 );
        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        if MaxPointsInLine < NumPointsInPart then
          MaxPointsInLine := NumPointsInPart;

        WriteLn( FASCII, Format( '     Polygon %d  Ring %d  of %d Points',
                                     [RecordNumber, i+1, NumPointsInPart] ) );
        for j := 0 to NumPointsInPart-1 do
        begin
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)], X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );

          if (j = 0) or (j = NumPointsInPart-1) then
            WriteLn( FASCII, Format( ' %d %g %g', [j, X, Y] ) );
        end; // for j := 0 to NumPointsInPart do
//        WriteLn( FASCII, 'End' );
        WriteLn( FASCII, '' );
      end; // for i := 0 to NumParts-1 do
      Continue;
    end;

    8: //****************************** MultiPoint Record
    begin
      move( Content[36], NumPoints, 4 );
      Inc( TotalPoints, NumPoints );
      WriteLn( FASCII, Format( '           MultiPoint of %d points',
                                                  [NumPoints] ) );
      for i := 0 to NumPoints-1 do
      begin
        move( Content[40+16*i], X,  8 );
        move( Content[40+16*i+8], Y,  8 );

        if (i = 0) or (i = NumPoints-1) then
          WriteLn( FASCII, Format( ' %d %g %g', [i, X, Y] ) );
      end; // for i := 0 to NumParts-1 do
//      WriteLn( FASCII, 'End' );
      WriteLn( FASCII, '' );
      Continue;
    end;

    end; // case ShapeType of

    ShowMessage( IntToStr(ShapeType) + ', ShapeType is not Implemented!' );
  end; // while True do

  Fin:
  DBF.Close;
  DBF.Free;

  WriteLn( FASCII, '' );
  WriteLn( FASCII, Format( '  Total Points  = %d', [TotalPoints] ) );
  WriteLn( FASCII, Format( '  Total Parts   = %d', [TotalParts]  ) );
  WriteLn( FASCII, Format( '  Total Records = %d', [RecordNumber]    ) );
  WriteLn( FASCII, '' );
  WriteLn( FASCII, Format( '  Max Parts  in Record = %d', [MaxParts]    ) );
  WriteLn( FASCII, Format( '  Max Points in Record = %d', [MaxPointsInRecord]  ) );
  WriteLn( FASCII, Format( '  Max Points in Part   = %d', [MaxPointsInLine]  ) );
  WriteLn( FASCII, '' );
  WriteLn( FASCII, Format( '  Average Points in Part   = %d',
                                    [Round(1.0*TotalPoints/TotalParts)] ) );
  WriteLn( FASCII, '' );
  WriteLn( FASCII, 'End of file' );
  Close( FShape );
  Close( FASCII );
end; // end of procedure N_ShapeToASCII2

//******************************************************** N_ShapeToDPoints ***
// Obsolete (shx file is not use)
//
// Сonvert given Shape file (Point or MultiPoint) to given TN_UDPoints obj
//
//     Parameters
// UDPoints   - given TN_UDPoints CObj (with resulting coords on output)
// ShapeFName - source Shape file Name,
// AffCoefs4  - aff. trnasformation coefs (Shape --> UDPoints coords)
// AMode      - bit0=0 - convert MultiPoint record to one MultiPart UDPoints Item,
//              otherwise (bit0=1) - convert MultiPoint records to several
//              single point Items
//
procedure N_ShapeToUDPoints( UDPoints: TN_UDPoints; ShapeFName: string;
                             const AffCoefs4: TN_AffCoefs4; AMode: integer;
                             ASetAllCodesProc: TN_SetCodesByTTableProc );
var
  FShape: File;
  Header:  array[0..99] of byte;
  Content: TN_BArray;
  ContentSize, ShapeType, FileCode, RecordNumber: integer;
  X,Y: double;
  WrkDP: TDPoint;
begin
  if not FileExists(ShapeFName) then
    raise Exception.Create( 'Error: File  "' + ShapeFName + '"  is absent.' );

  AssignFile( FShape, ShapeFName );
  Reset     ( FShape, 1 );

  try
  BlockRead ( FShape, Header[0], 100 );
  N_Reverse4Bytes( @Header[0], @FileCode );

  if FileCode <> 9994 then
    raise Exception.Create( 'Error: Bad Shape file code (not 9994)!' );

  move( Header[32], ShapeType, 4 );

  if (ShapeType <> 1)  then
    raise Exception.Create( 'Error: Bad ShapeType ' + IntToStr(ShapeType) );

  SetLength( Content, 10000 ); // initial size

  UDPoints.InitItems( 2, 10000 );

  while True do
  begin
    if EOF(FShape) then Break;

    N_StateString.Show( 'Shape to Points: ', FilePos(FShape)/FileSize(FShape));

    BlockRead ( FShape, Header[0], 8 );
    N_Reverse4Bytes( @Header[0], @RecordNumber );
    N_Reverse4Bytes( @Header[4], @ContentSize );

    ContentSize := 2*ContentSize; // conv ContentSize from words to bytes

    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + Length(Content) div 2 );

    BlockRead ( FShape, Content[0], ContentSize );
    move( Content[0], ShapeType, 4 );

    case ShapeType of //*********

    0://****************************** NULL Record
    begin
      Continue; // just skip NULL Record
    end;

    1: //****************************** Point Record
    begin
      move( Content[4],  X,  8 );
      move( Content[12], Y,  8 );

      WrkDP.X := AffCoefs4.CX*X + AffCoefs4.SX;
      WrkDP.Y := AffCoefs4.CY*Y + AffCoefs4.SY;
      UDPoints.AddOnePointItem( WrkDP, RecordNumber+1 );
    end;

    8: //****************************** MultiPoint Record
    begin
      move( Content[4],  X,  8 );
      move( Content[12], Y,  8 );

      WrkDP.X := AffCoefs4.CX*X + AffCoefs4.SX;
      WrkDP.Y := AffCoefs4.CY*Y + AffCoefs4.SY;
      UDPoints.AddOnePointItem( WrkDP, RecordNumber+1 );
    end

    else // Shape Type is not 0, 1 or 8
      raise Exception.Create( 'Error: Bad Record Type ' + IntToStr(ShapeType) );
    end; // case ShapeType of
  end; // while True do

  finally
    Close( FShape );
    UDPoints.CalcEnvRects();
    UDPoints.CompactSelf();
  end; // finally
end; // end of procedure N_ShapeToUDPoints

//************************************************ N_ShapeToULines ***
// Obsolete (shx file is not use)
//
// convert given Shape file (Lines or Polygons) to TN_ULines
//
// ULines    - resulting Lines Layer,
// ShapeFName - Shape file Name,
// AffCoefs4  - aff. trnasformation coefs (Shape --> UDline coords),
// Mode       - convertion mode:
//   bits0-3($00F) - how to treat multiple Parts records:
//                   =0 - each part into separate Item (line)
//                   =1 - all parts into same Item (polyline, polypolygon)
//   bit4($010)) =0 - do not fill RCXY array
//               =1 - fill RCXY array (X=RecordNumber(>=1), Y=-1)
//   bit5($020)) =0 - Lines or Polygons Shape file is OK
//               =1 - only Polygons Shape file is OK
//   bit6($040)) =1 - conv negative X coords (X := 360 + X)
//
procedure N_ShapeToULines( ULines: TN_ULines; ShapeFName: string;
                                const AffCoefs4: TN_AffCoefs4; Mode: integer );
var
  FShape: File;
  Header:  array[0..99] of byte;
  Content: TN_BArray;
  ContentSize, ShapeType, NumParts, NumPoints: integer;
  i, j, NextInt, BegPointInPartInd, FileCode: integer;
  NumPointsInPart, RecordNumber, LineNumber: integer;
  ACCSize: integer;
  EnableMultiParts: boolean;
  X,Y: double;
  ACC: TN_DPArray;
  LItem: TN_ULinesItem;
begin
  LItem := TN_ULinesItem.Create( ULines.WLCType );
//  SetLength( LItem.IRegCodes, 2 );

  if (Mode and $10) <> 0 then // fill RCXY array (X=RecordNumber(>=1), Y=-1)
    ULines.WFlags := ULines.WFlags or N_RCXYBit; // RCXY array exists

  if not FileExists(ShapeFName) then
    raise Exception.Create( 'Error: File  "' + ShapeFName + '"  is absent.' );

//  FileMode := 0; //??
  AssignFile( FShape, ShapeFName );
  Reset     ( FShape, 1 );

  try
  BlockRead ( FShape, Header[0], 100 );
  N_Reverse4Bytes( @Header[0], @FileCode );
  if FileCode <> 9994 then
    raise Exception.Create( 'Error: Bad Shape file code (not 9994)!' );

  move( Header[32], ShapeType, 4 );
  if ((ShapeType <> 3) and (ShapeType <> 5)) or
     ((ShapeType = 3)  and ((Mode and $20) <> 0)) then
    raise Exception.Create( 'Error: Bad ShapeType ' + IntToStr(ShapeType) );

  LineNumber := 0;
  SetLength( Content, 10000 ); // initial size

  NumPoints := Round(FileSize(FShape) / 16);                   // approximation
  ULines.InitItems( Min( 1000, NumPoints div 4 ), NumPoints ); // approximation

  EnableMultiParts := False;
  if (Mode and $F) <> 0 then
    EnableMultiParts := True;

  while True do
  begin
    if EOF(FShape) then Break;
    N_StateString.Show( 'Shape to Lines: ', FilePos(FShape)/FileSize(FShape));

    if RecordNumber = 26 then Break; // debug!!!

    BlockRead ( FShape, Header[0], 8 );
    N_Reverse4Bytes( @Header[0], @RecordNumber );
    N_Reverse4Bytes( @Header[4], @ContentSize );
    ContentSize := 2*ContentSize; // conv from words to bytes

    if ContentSize > Length(Content) then
      SetLength( Content, ContentSize + Length(Content) div 2 );
    BlockRead ( FShape, Content[0], ContentSize );
    move( Content[0], ShapeType, 4 );

    case ShapeType of //*********

    0://********************************** NULL Record
    begin
// just skip
    end;

    3, 5: //****************************** Polyline or Polygon Record
    begin
      move( Content[36], NumParts,  4 );
      move( Content[40], NumPoints, 4 );

      ACCSize := NumPoints + 20;
      if Length(ACC) < ACCSize then
        SetLength( ACC, N_NewLength(ACCSize) );

      LItem.Init();
//      LItem.ICode := RecordNumber;
//      LItem.IRC1  := RecordNumber;
//      LItem.IRC2  := 0; // outer Contour Code = 0
//      LItem.IRegCodes[0] := RecordNumber;
//      LItem.IRegCodes[1] := 0; // outer Contour Code = 0
//      LItem.INumRegCodes := 2;
//      LItem.SetThreeCodes( RecordNumber, RecordNumber, 0 );

      for i := 0 to NumParts-1 do // loop along Parts
      begin
        move( Content[44+4*i], BegPointInPartInd,  4 );
        move( Content[44+4*i+4], NextInt,  4 );
        if i = (NumParts-1) then // last part
          NumPointsInPart := NumPoints - BegPointInPartInd
        else // not last part
          NumPointsInPart := NextInt - BegPointInPartInd;

        for j := 0 to NumPointsInPart-1 do // loop along Points in current Part
        begin
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)],   X,  8 );
          move( Content[44+4*NumParts+16*(j+BegPointInPartInd)+8], Y,  8 );

          if (Mode and $40) <> 0 then // conv negative X coords (-179 -> +181)
            if X < 0 then
              X := 360 + X;

          ACC[j].X := AffCoefs4.CX*X + AffCoefs4.SX;
          ACC[j].Y := AffCoefs4.CY*Y + AffCoefs4.SY;
        end; // for j := 0 to NumPointsInPart do

        LItem.AddPartCoords( ACC, 0, NumPointsInPart );

        if not EnableMultiParts then
        begin

          ULines.ReplaceItemCoords( LItem, -1, RecordNumber, RecordNumber, 0 );
          LItem.Init();
//          LItem.ICode := RecordNumber;
//          LItem.IRC1  := RecordNumber;
//          LItem.IRC2  := 0; // outer Contour Code = 0
//          LItem.IRegCodes[0] := RecordNumber;
//          LItem.IRegCodes[1] := 0; // outer Contour Code = 0
//          LItem.INumRegCodes := 2;
//          LItem.SetThreeCodes( RecordNumber, RecordNumber, 0 );

          Inc(LineNumber);
          N_i := LineNumber; // to avoid warning
        end;

      end; // for i := 0 to NumParts-1 do

      if EnableMultiParts then
      begin
        ULines.ReplaceItemCoords( LItem, -1, RecordNumber, RecordNumber, 0 );
        LItem.Init();
//        LItem.ICode := RecordNumber;
//        LItem.IRC1  := RecordNumber;
//        LItem.IRC2  := 0; // outer Contour Code = 0
//        LItem.IRegCodes[0] := RecordNumber;
//        LItem.IRegCodes[1] := 0; // outer Contour Code = 0
//        LItem.INumRegCodes := 2;
//        LItem.SetThreeCodes( RecordNumber, RecordNumber, 0 );

        Inc(LineNumber);
        N_i := LineNumber; // to avoid warning
      end;
    end // case 3, 5: - Polyline or Polygon Record

    else // Shape Type is not 0, 3, or 5
      raise Exception.Create( 'Error: Bad Record Type ' + IntToStr(ShapeType) );
    end; // case ShapeType of
  end; // while True do

  finally
    Close( FShape );
    ULines.CalcEnvRects();
    ULines.CompactSelf();
    LItem.Free;
  end; // finally
end; // end of procedure N_ShapeToULines



{
Initialization
  N_RegActionProc( 'ImportMIF1', N_ActionImportMIF1 ); // MIF-MID files import
}
end.
