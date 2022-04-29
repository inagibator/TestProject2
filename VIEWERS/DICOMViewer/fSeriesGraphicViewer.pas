unit fSeriesGraphicViewer;

{$R-}

interface

uses SysUtils, Windows, Classes, Graphics, Forms,
  Controls, ExtCtrls, StdCtrls, Buttons, define_types, dicom,
  ComCtrls, Menus, Dialogs, JPEG, Clipbrd, ToolWin,
  Winapi.Messages, N_BaseF,
  K_CMDCMGLibW, N_Lib0,
  System.IOUtils,
  N_Types;

const
  kRadCon = pi / 180;
  kMaxECAT = 512;
  gInc: integer = 0;

var
  gMouseDown: boolean = false;

type
  palentries = array [0 .. 255] of TPaletteEntry;
  palindices = array [0 .. 255] of word;

  TSeriesGraphicViewer = class(TN_BaseForm)
    MainMenu1: TMainMenu;
    OptionsSettingsMenu: TMenuItem;
    OptionsImgInfoItem: TMenuItem;
    N2: TMenuItem;
    Lowerslice1: TMenuItem;
    Higherslice1: TMenuItem;
    SelectZoom1: TMenuItem;
    ContrastAutobalance1: TMenuItem;
    CopyItem: TMenuItem;
    EditMenu: TMenuItem;
    Timer1: TTimer;
    StudyMenu: TMenuItem;
    Previous1: TMenuItem;
    Next1: TMenuItem;
    Mosaic1: TMenuItem;
    N1x11: TMenuItem;
    N2x21: TMenuItem;
    N3x31: TMenuItem;
    N4x41: TMenuItem;
    Other1: TMenuItem;
    Smooth1: TMenuItem;
    Overlay1: TMenuItem;
    None1: TMenuItem;
    White1: TMenuItem;
    Black1: TMenuItem;
    ContrastSuggested1: TMenuItem;
    ContrastCTPresets1: TMenuItem;
    Bone1: TMenuItem;
    Chest1: TMenuItem;
    Lung1: TMenuItem;
    ScrollBox1: TScrollBox;
    Image: TImage;
    // procedure decompressJPEG24x (lFilename: string; var lOutputBuff: ByteP0; lImageVoxels,lImageStart{gECATposra[lSlice]}: integer);

    procedure RescaleInit;
    procedure RescaleClear;
    function RescaleFromBuffer(lIn: integer): integer;
    function RescaleToBuffer(lIn: integer): integer;
    procedure FreeBackupBitmap;
    procedure UpdatePalette(lApply: boolean; lWid0ForSlope: integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure OptionsImgInfoItemClick(Sender: TObject);
    procedure Lowerslice1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LoadColorScheme(lStr: string; lScheme: integer);
    procedure DetermineZoom;
    procedure AutoMaximise;
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure SelectZoom1Click(Sender: TObject);
    procedure ContrastAutobalance1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure DICOMImageRefreshAndSize;
    procedure SetDimension(lInPGHt, lInPGWid, lInBits: integer; lInBuff: ByteP0;
      lUseWinCenWid: boolean);

    function VxlVal(X, Y: integer; lRGB_greenOnly: boolean): integer;
    procedure Vxl(X, Y: integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure N1x11Click(Sender: TObject);
    procedure Smooth1Click(Sender: TObject);
    procedure None1Click(Sender: TObject);
    procedure ContrastSuggested1Click(Sender: TObject);
    procedure CTpreset(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    FLastDown, gSelectOrigin: TPoint;
    // gMagRect,gSelectRect: TRect;
    gRra, gGra, gBra: array [0 .. 255] of byte;
    gECATslices: integer;
    gECATposra, gECATszra: array [1 .. kMaxECAT] of longint;

    gAbort: boolean;
  public
    FFileName, gFilePath: string;
  public
    gDynStr: string;
    BackupBitmap: TBitmap;
    gSelectRect, gMagRect, gLine: TRect;
    gLineLenMM: double;
    gMultiFirst, gMultiLast, gMultiRow, gMultiCol, g100pctImageWid,
      g100pctImageHt { ,gMaxRGB,gMinRGB,gMinHt,gMinWid } : integer;
    gFastCheck, gSmooth, gImgOK, FDICOM: boolean;
    gBuff16: SmallIntP0;
    gBuff16x: Wordp0;
    gBuff8, gBuff24: ByteP0;
    gDicomData: TDICOMData;
    gIntenScaleInt, gIntenInterceptInt: integer;
    gIntRescale: boolean;
    gStringList: TStringList;
    gVideoSpeed, gBuff24sz, gBuff8sz, gBuff16sz, gCustomPalette: integer;
    // gRaw16Min,gRaw16Max,
    gFileListSz, gCurrentPosInFileList, gWinCen, gWinWid, gSlice, gnSLice,
      gXStart, gStartSlope, gStartCen, gYStart, gImgMin, gImgMax, gImgCen,
      gImgWid, gWinMin, gWinMax, gWHite, gBlack, gScheme, gZoomPct, gPro,
      gScale: integer;
    gContrastStr: string;
    gFastSlope, gFastCen: integer;
    { Public declarations }
    procedure OverlayData;
    function LoadData(lFileName: string; lAnalyze, lECAT, l2dImage,
      lRaw: boolean): boolean;
    procedure LoadFileList;
    procedure ReleaseDICOMmemory;
    procedure DisplayImage(lUpdateCon, lForceDraw: boolean;
      lSlice, lInWinWid, lInWincen: integer);
    procedure HdrShow;
    procedure RefreshZoom;

    PROCEDURE ShowMagnifier(CONST X, Y: integer); // requires backup bitmap

    function SliceCount: Integer;
    procedure ShowSlice(ASliceIndex: Integer);

    procedure PositionImage;

    procedure Scale16to8bit(lWinCen, lWinWid: integer); overload;
    procedure Scale16to8bit(lWinCen, lWinWid: integer; var ABuff: Bytep0); overload;

    function IsViewerActive: Boolean;
  public
    destructor Destroy; override;
  end;

var
  SeriesGraphicViewer: TSeriesGraphicViewer;

implementation

uses fDICOMViewer;

var
  gMaxRGB, gMinRGB, gMinHt, gMinWid: integer;
{$R *.DFM}

procedure TSeriesGraphicViewer.OverlayData;
var
  lZOomPct, lMultiSlice, lRowPos, lColPos, lDiv, lFOntSpacing, lSpace, lRow,
    lSlice, lCol: integer;
  lMultiSliceInc: single;

  ValueIndex, DateValue: integer;
  DateValueStr: string;
begin
  //if None1.checked then
  //  exit;
  if gSmooth then
    lZOomPct := gZoomPct
  else
    lZOomPct := 100;
  if gMultiCol > 0 then
    lDiv := gMultiCol
  else
    lDiv := 1;
  case (Image.Picture.Width div lDiv) of
    0 .. 63:
      lFOntSpacing := 8;
    64 .. 127:
      lFOntSpacing := 8; // 9;
    128 .. 255:
      lFOntSpacing := 9; // 10;
    256 .. 511:
      lFOntSpacing := 10; // 12;
    512 .. 767:
      lFOntSpacing := 12; // 14;
  else
    lFOntSpacing := 14; // 26;
  end;

  Image.Canvas.Font.Name := 'MS Sans Serif';
  Image.Canvas.Brush.style := bsClear;
  Image.Canvas.Font.Size := lFOntSpacing;
 // if White1.checked then
    Image.Canvas.Font.Color := gMaxRGB;
 // else
 //   Image.Canvas.Font.Color := gMinRGB;
//  if ((gMultiRow > 1) or (gMultiCol > 1)) and (gMultiRow > 0) and (gMultiCol > 0)
//  then
//  begin
//    lMultiSliceInc := (gMultiLast - gMultiFirst) /
//      ((gMultiRow * gMultiCol) - 1);
//    if lMultiSliceInc < 1 then
//      lMultiSliceInc := 1;
//    lMultiSlice := 0;
//    for lRow := 0 to (gMultiRow - 1) do
//    begin
//      lRowPos := 6 + (lRow * (((gDicomData.XYZdim[2]) * lZOomPct) div 100));
//      for lCol := 0 to (gMultiCol - 1) do
//      begin
//        lColPos := 6 + (lCol * (((gDicomData.XYZdim[1]) * lZOomPct) div 100));
//        lSlice := gMultiFirst + round(lMultiSliceInc * (lMultiSlice)) - 1;
//        // showmessage(inttostr(lColPos)+':'+inttostr(lROwPos));
//        if (gDicomData.XYZdim[3] > 1) then
//        begin
//          if (lSlice < gDicomData.XYZdim[3]) then
//          begin
//            if (lRow = 0) and (lCol = 0) then
//              Image.Canvas.TextOut(lColPos, lRowPos, inttostr(lSlice + 1) + ':'
//                + extractfilename(FFileName))
//            else
//              Image.Canvas.TextOut(lColPos, lRowPos, inttostr(lSlice + 1))
//
//          end
//        end
//        else if (lSlice < gFileListSz) and (lSlice >= 0) then
//          Image.Canvas.TextOut(lColPos, lRowPos, inttostr(lSlice + 1) + ':' +
//            (gStringList.Strings[lSlice]));
//        inc(lMultiSlice);
//      end; // for lROw
//    end; // for lCol.
//  end
//  else // not multislice mosaic
//    Image.Canvas.TextOut(6, 6, extractfilename(FFileName));
  lSpace := 6;

  with gDicomData do
  begin
    if not PatientName.IsEmpty then
    begin
      Image.Canvas.TextOut(6, lSpace, PatientName);
      lSpace := lSpace + 8 + lFOntSpacing;
    end;

    if not PatientID.IsEmpty then
    begin
      Image.Canvas.TextOut(6, lSpace, PatientID);
      lSpace := lSpace + 8 + lFOntSpacing;
    end;

    if not PatientBirthDate.IsEmpty then
      DateValueStr := DICOMDateToDate(PatientBirthDate);

    if not PatientAge.IsEmpty then
      if DateValueStr.IsEmpty then
        DateValueStr := PatientAge
      else
        DateValueStr := DateValueStr + ' (' + PatientAge + ')';

    if not PatientSex.IsEmpty then
      if DateValueStr.IsEmpty then
        DateValueStr := PatientSex
      else
        DateValueStr := DateValueStr + ' ' + PatientSex;

    if not DateValueStr.IsEmpty then
    begin
      Image.Canvas.TextOut(6, lSpace, DateValueStr);
      lSpace := lSpace + 8 + lFOntSpacing;
    end;

    if not SeriesDescription.IsEmpty then
    begin
      Image.Canvas.TextOut(6, lSpace, SeriesDescription);
      lSpace := lSpace + 8 + lFOntSpacing;
    end;
  end;
end;

procedure TSeriesGraphicViewer.RefreshZoom;
// redraws the image to the correct size, minimizes flicker
begin
//  LockWindowUpdate((Self.Owner as TDICOMViewer).Handle);
  if gBuff24sz > 0 then
    SetDimension(g100pctImageHt, g100pctImageWid, 24, gBuff24, false)
  else if gBuff16sz > 0 then
    Scale16to8bit(gWinCen, gWinWid)
  else if (gBuff8sz > 0) then
  begin
    SetDimension(g100pctImageHt, g100pctImageWid, 8, gBuff8, true);
  end
  else
  begin
    (Owner as TDICOMViewer).StatusBar.Panels[1].text := inttostr(gZoomPct) + '%';
    Image.Height := round((Image.Picture.Height * gZoomPct) div 100);
    Image.Width := round((Image.Picture.Width * gZoomPct) div 100);
    Image.refresh;
//    LockWindowUpdate(0);
    exit;
  end;
  if gDicomData.Allocbits_per_pixel < 9 then
  begin
    if (gWinWid >= maxint) then
    begin
      gContrastStr := 'Window Cen/Wid: ' + inttostr(gWinCen) + '/inf';
    end
    else
    begin
      gContrastStr := 'Window Cen/Wid: ' + inttostr(gWinCen) + '/' +
        inttostr(gWinWid)
    end;
  end;
  (Owner as TDICOMViewer).StatusBar.Panels[1].text := inttostr(gZoomPct) + '%';

  //Application.ProcessMessages;


  DICOMImageRefreshAndSize;

//  LockWindowUpdate(0);
  PositionImage;
end;

procedure TSeriesGraphicViewer.DICOMImageRefreshAndSize;
// Checks image scale and redraws the image
var
  OldHorz, OldVert: integer;
begin
//  if gSmooth then
//  begin
//    Image.Height := Image.Picture.Height;
//    Image.Width := Image.Picture.Width;
//  end
//  else
//  begin
  Image.Height := round((Image.Picture.Height * gZoomPct) div 100);
  Image.Width := round((Image.Picture.Width * gZoomPct) div 100);

  OverlayData;
  Image.refresh;
//  end;
end;

procedure TSeriesGraphicViewer.FreeBackupBitmap;
// release dynamic memory used for magnifying glass
begin
  if BackupBitmap <> nil then
  begin
    BackupBitmap.free;
    BackupBitmap := nil;
  end;
  gMagRect := Rect(0, 0, 0, 0);
end;

procedure TSeriesGraphicViewer.ReleaseDICOMmemory;
// release dynamic memory allocation
begin
  FreeBackupBitmap;
  if (gBuff24sz > 0) then
  begin
    freemem(gBuff24);
    gBuff24sz := 0;
  end;
  if (gBuff16sz > 0) then
  begin
    freemem(gBuff16);
    gBuff16sz := 0;
  end;
  if (gBuff8sz > 0) then
  begin
    freemem(gBuff8);
    gBuff8sz := 0;
  end;
//  if red_table_size > 0 then
//  begin
//    freemem(red_table);
//    red_table_size := 0;
//  end;
//  if green_table_size > 0 then
//  begin
//    freemem(green_table);
//    green_table_size := 0;
//  end;
//  if blue_table_size > 0 then
//  begin
//    freemem(blue_table);
//    blue_table_size := 0;
//  end;
  gCustomPalette := 0;
  gECATslices := 0;
end;

procedure ShellSort(first, last: integer;
  var lPositionRA { ,lIndexRA } : longintP; lIndexRA: DWordP;
  var lRepeatedValues: boolean);
{ Shell sort chuck uses this- see 'Numerical Recipes in C' for similar sorts. }
{ less memory intensive than recursive quicksort }
label
  555;
const
  tiny = 1.0E-5;
  aln2i = 1.442695022;
var
  n, t, nn, m, lognb2, l, k, j, i, s: integer;
begin
{$R-}
  lRepeatedValues := false;
  n := abs(last - first + 1);
  lognb2 := trunc(ln(n) * aln2i + tiny);
  m := last;
  for nn := 1 to lognb2 do
  begin
    m := m div 2;
    k := last - m;
    for j := 1 to k do
    begin
      i := j;
    555: { <- LABEL }
      l := i + m;
      if lIndexRA[lPositionRA[l]] = lIndexRA[lPositionRA[i]] then
      begin

        // showmessage(inttostr(lIndexRA[lPositionRA[l]] shr 24 and 255 )+'-'+inttostr(lIndexRA[lPositionRA[l]] shr 16 and 255 )+'-'+inttostr(lIndexRA[lPositionRA[l]] and 65535 ) );
        lRepeatedValues := true;
        exit;
      end;
      if lIndexRA[lPositionRA[l]] < lIndexRA[lPositionRA[i]] then
      begin
        // swap values for i and l
        t := lPositionRA[i];
        lPositionRA[i] := lPositionRA[l];
        lPositionRA[l] := t;
        i := i - m;
        if (i >= 1) then
          goto 555;
      end
    end
  end
{$R+}
end; (* *)

procedure TSeriesGraphicViewer.LoadFileList;
// Searches for other DICOM images in the same folder (so user can cycle through images
var
  lSearchRec: TSearchRec;
  lName, lFilenameWOPath, lExt: string;
  lSz: integer;
  lDICM: boolean;
  lIndex: DWord;
  lInc, lItems: longint; // vixen
  lDicomData: TDIcomData; // vixen
  lRepeatedValues, lHdrOK, lImgOK: boolean; // vixen
  lFileName, lDynStr, lFoldername: String; // vixen
  lStringList: TStringList; // vixen
  lTimeD: DWord;
  lIndexRA: DWordP;
  lPositionRA { ,lIndexRA } : longintP; // vixen

  CurSerieUID: string;
  i: Integer;

  DI: TK_HDCMINST;
  InstanceResult: integer;

  WUInt2: Word;
  WBuf: WideString;
  sz: Integer;
  IsNil: Integer;

  FullNames: Boolean;

  DicomDataList: array of TDICOMdata;

  function IsDICOM(AFileName: string): Boolean;
  var
    FP: file;
    lDICMcode: integer;
  begin
    Result := false;
    if ('.DCM' = ExtractFileExt(AFileName)) then
      Result := true;

    if ('.DCM' <> ExtractFileExt(AFileName)) then
    begin
      Filemode := 0;
      AssignFile(FP, AFileName);
      try
        Filemode := 0; // read only - might be CD
        Reset(FP, 1);

        if FileSize(FP) <= 132 then Exit;

        Seek(FP, 128);
        BlockRead(FP, lDICMcode, 4);

        Result := (lDICMcode = 1296255300);
      finally
        CloseFile(FP);
      end; // try..finally open file
      Filemode := 2; // read/write
    end; // Ext <> DCM
  end;

  procedure ScanForFiles(AFileList: TStringList; const APath: string);
  var
    FileName, Dir: string;
  begin
    for FileName in TDirectory.GetFiles(APath) do
      if IsDICOM(FileName) then
        AFileList.Add(FileName);

    for Dir in TDirectory.GetDirectories(APath) do
      ScanForFiles(AFileList, Dir);
  end;

  function FindDicomData(AFileName: string): TDICOMdata;
  var
    i: Integer;
  begin
    for i := 0 to Length(DicomDataList) - 1 do
      if SameText(AFileName, DicomDataList[i].FileName) then
      begin
        Result := DicomDataList[i];
        Break;
      end;
  end;
const
  BufLeng = 1024;
begin
{$R-}
//  lFilenameWOPath := extractfilename(FFileName);
//  lExt := ExtractFileExt(FFileName);
//
//  if length(lExt) > 0 then
//    for lSz := 1 to length(lExt) do
//      lExt[lSz] := upcase(lExt[lSz]);

  if not (gDicomData.PatientName.IsEmpty) then
  begin // real DICOM file
//    if (Assigned(Self.Owner) and (Self.Owner is TDICOMViewer)) AND
//     (not (Self.Owner as TDICOMViewer).Study.InitialDir.IsEmpty) then
//    begin
//      ScanForFiles(gStringList, (Self.Owner as TDICOMViewer).Study.InitialDir);
//      FullNames := True;
//    end
//    else
//    begin
//      if FindFirst(gFilePath + '*.*', faAnyFile - faSysFile - faDirectory,
//        lSearchRec) = 0 then
//      begin
//        repeat
//          lExt := AnsiUpperCase(ExtractFileExt(lSearchRec.Name));
//          lName := AnsiUpperCase(lSearchRec.Name);
//          if (lSearchRec.Size > 1024) and (lName <> 'DICOMDIR') then
//          begin
//            if IsDICOM(gFilePath + lSearchRec.Name) then
//              gStringList.Add(lSearchRec.Name); { }
//          end; // FileSize > 512
//        until (FindNext(lSearchRec) <> 0);
//        Filemode := 2;
//      end; // some files found
//      SysUtils.FindClose(lSearchRec);
//    end;
//
//    lFoldername := extractfiledir(FFileName);
//
//    for i := gStringList.Count - 1 downto 0 do
//    begin
//      if FullNames then
//        lFileName := gStringList[i]
//      else
//        lFileName := IncludeTrailingPathDelimiter(lFoldername) + gStringList[i];
//
//      lDicomData := TDICOMData.Create;
//      ReadDicomData(lFileName, lDicomData);
//      lDicomData.FileName := lFileName;
//
//      //read_dicom_data( { true } false, false { not verbose } , true, true,
//      //    true, true, false, lDicomData, lHdrOK, lImgOK, lDynStr, lFileName);
//
//      if not SameText(Self.gDicomData.SerieUID, lDicomData.SerieUID) then
//        gStringList.Delete(i)
//      else
//      begin
////        if (Self.gDicomData.SeriesNum = lDicomData.SeriesNum) AND
////           (Self.gDicomData.ImageNum = lDicomData.ImageNum) then
////           gStringList.Delete(i)
////        else
////        begin
//          SetLength(DicomDataList, Length(DicomDataList)+1);
//          DicomDataList[Length(DicomDataList)-1] := lDicomData;
////        end;
//      end;
//    end;

    if gStringList.Count > 0 then
    begin
      { start vixen }
      lItems := gStringList.Count;
      getmem(lIndexRA, lItems * sizeof( { longint } DWord));
      getmem(lPositionRA, lItems * sizeof(longint));

      lTimeD := GetTickCount;

      for lInc := lItems downto 1 do
      begin
        if FullNames then
          lFileName := gStringList[lInc - 1]
        else
          lFileName := lFoldername + pathdelim + gStringList.Strings[lInc - 1];

       lDicomData := (gStringList.Objects[lInc-1] as TDICOMData); //FindDicomData(lFileName);
        // showmessage(lFilename);
       // ReadDicomData(lFileName, lDicomData);
        //read_dicom_data( { true } false, false { not verbose } , true, true,
        //  true, true, false, lDicomData, lHdrOK, lImgOK, lDynStr, lFileName);
        // if lDicomData.SiemensMosaicX <> 1 then showmessage(lFilename+' '+inttostr(lDicomData.SiemensMosaicX));
        //Application.ProcessMessages;

//        if not SameText(Self.gDicomData.SerieUID, lDicomData.SerieUID) then
//        begin
//          gStringList.Delete(lInc-1);
//          lItems := gStringList.Count;
//          getmem(lIndexRA, lItems * sizeof( { longint } DWord));
//          getmem(lPositionRA, lItems * sizeof(longint));
//          Continue;
//        end;

        lIndex := ((lDicomData.PatientIDInt and 65535) shl 32) +
          ((lDicomData.SeriesNum and 255) shl 24) +
          ((lDicomData.AcquNum and 255) shl 16) + lDicomData.ImageNum;
        lIndexRA[lInc] := lIndex;
        lPositionRA[lInc] := lInc;
      end;

//      for lInc := lItems to 1 do
//      begin
//        lFileName := lFoldername + pathdelim + gStringList.Strings[lInc - 1];
//
//        // showmessage(lFilename);
//        {InstanceResult := K_CMDCMCreateIntance(lFileName, DI);
//
//        if InstanceResult <> 0 then
//          Continue;
//
//        with K_DCMGLibW do
//        begin
//          SetLength(WBuf, BufLeng);
//          sz := BufLeng;
//
//          if DLGetValueString(DI, K_CMDCMTPatientId, @WBuf[1], @sz, @isNil) <> 0 then
//            Continue
//          else
//            lDicomData.PatientIDInt := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz )), -1);
//
//          if DLGetValueString(DI, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @isNil) <> 0 then
//            Continue
//          else
//            lDicomData.SeriesNum := N_WideToString(Copy(WBuf, 1, sz )).ToInteger;
//
//          if DLGetValueString(DI, K_CMDCMTAcquisitionNumber, @WBuf[1], @sz, @isNil) <> 0 then
//            Continue
//          else
//            lDicomData.AcquNum := N_WideToString(Copy(WBuf, 1, sz )).ToInteger;
//
//          if DLGetValueString(DI, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @isNil) <> 0 then
//            Continue
//          else
//            lDicomData.ImageNum := N_WideToString(Copy(WBuf, 1, sz )).ToInteger;
//
//          DLDeleteDcmObject(DI)
//        end;
//                }
//        read_dicom_data( { true } false, false { not verbose } , true, true,
//        true, true, false, lDicomData, lHdrOK, lImgOK, lDynStr, lFileName);
//        // if lDicomData.SiemensMosaicX <> 1 then showmessage(lFilename+' '+inttostr(lDicomData.SiemensMosaicX));
//        Application.ProcessMessages;
//
//        lIndex := ((lDicomData.PatientIDInt and 65535) shl 32) +
//          ((lDicomData.SeriesNum and 255) shl 24) +
//          ((lDicomData.AcquNum and 255) shl 16) + lDicomData.ImageNum;
//        lIndexRA[lInc] := lIndex;
//        lPositionRA[lInc] := lInc;
//      end;

      lTimeD := GetTickCount - lTimeD; // 70 ms
      // Showmessage(inttostr(lItems)+'  '+inttostr(lTimeD)+'x');

      ShellSort(1, lItems, lPositionRA, lIndexRA, lRepeatedValues);
      // for lInc := 1 to lItems do
      // showmessage(inttostr(lPositionRA[lInc])+' = ' +  inttostr(lIndexRA[lPositionRA[lInc]]));

      if not lRepeatedValues then
      begin
        lStringList := TStringList.Create;
        for lInc := 1 to lItems do
          lStringList.Add(gStringList[lPositionRA[lInc] - 1]);
        // [lInc-1] := gStringList[lPositionRA[lInc]-1]; //place items in correct order
        for lInc := 1 to lItems do
          gStringList[lInc - 1] := lStringList[lInc - 1];
        // put sorted items into correct list
        lStringList.free;
      end
      else
        gStringList.Sort; // repeated index - sort name by filename instead
      // sort stringlist based on indexRA
      freemem(lPositionRA);
      freemem(lIndexRA);
      { end vixen }
      for lSz := (gStringList.Count - 1) downto 0 do
      begin
        if gStringList.Strings[lSz] = lFilenameWOPath then
          gCurrentPosInFileList := lSz;
      end;
    end;
    gFileListSz := gStringList.Count;
  end; // NamePos > 0    *)
  if (gStringList.Count > 1) then
  begin
    StudyMenu.enabled := true;
  end;
{$R+}
end; (* *)

(* old primitive->
  procedure TMDIChild.LoadFileList;
  //Searches for other DICOM images in the same folder (so user can cycle through images
  var
  lSearchRec: TSearchRec;
  lName,lFilenameWOPath,lExt : string;
  lSz,lDICMcode: integer;
  lDICM: boolean;
  FP: file;
  begin
  lFilenameWOPath := extractfilename(FFilename);
  lExt := ExtractFileExt(FFileName);
  if length(lExt) > 0 then
  for lSz := 1 to length(lExt) do
  lExt[lSz] := upcase(lExt[lSz]);
  if (gDicomData.NamePos > 0) then begin //real DICOM file
  if FindFirst(gFilePath+'*.*', faAnyFile-faSysFile-faDirectory, lSearchRec) = 0 then begin
  repeat
  lExt := AnsiUpperCase(extractfileext(lSearchRec.Name));
  lName := AnsiUpperCase(lSearchRec.name);
  if (lSearchRec.Size > 1024)and (lName <> 'DICOMDIR') then begin
  lDICM := false;
  if ('.DCM' = lExt) then lDICM := true;
  if ('.DCM'<>  lExt) then begin
  Filemode := 0;
  AssignFile(fp, gFilePath+lSearchRec.Name);
  Filemode := 0; //read only - might be CD
  Reset(fp, 1);
  Seek(FP,128);
  BlockRead(fp, lDICMcode, 4);
  if lDICMcode = 1296255300 then lDICM := true;
  CloseFile(fp);
  Filemode := 2; //read/write
  end; //Ext <> DCM
  if lDICM then
  gStringList.Add(lSearchRec.Name);{}
  end; //FileSize > 512
  until (FindNext(lSearchRec) <> 0);
  Filemode := 2;
  end; //some files found
  SysUtils.FindClose(lSearchRec);
  gStringlist.Sort;
  if gStringlist.Count > 0 then begin
  for lSz := (gStringList.count-1) downto 0 do begin
  if gStringList.Strings[lSz] = lFilenameWOPath then gCurrentPosInFileList := lSz;
  end;
  end;
  gFileListSz := gStringList.count;
  end; //NamePos > 0 *)
(* if (gStringlist.Count > 1) then begin
  StudyMenu.enabled := true;
  end;
  end;(* *)

procedure TSeriesGraphicViewer.RescaleClear;
// resets slope/intercept for image brightness/contrast (e.g. to convert stored image intensity to Hounsfield units)
begin
  gIntenScaleInt := 1;
  gIntenInterceptInt := 0;
  gIntRescale := true;
end;

procedure TSeriesGraphicViewer.RescaleInit;
// updates slope/intercept for image brightness/contrast (e.g. to convert stored image intensity to Hounsfield units)
var
  lS, lI: single;
  lSi, lIi: integer;
begin
  RescaleClear;
  if gDicomData.IntenScale = 0 then
    gDicomData.IntenScale := 1;
  lS := gDicomData.IntenScale;
  lI := gDicomData.IntenIntercept;
  lSi := round(lS);
  lIi := round(lI);
  if (lS = lSi) and (lI = lIi) then
  begin
    gIntenScaleInt := lSi;
    gIntenInterceptInt := lIi;
    gIntRescale := true;
  end
  else
    gIntRescale := false;
end;

function TSeriesGraphicViewer.RescaleFromBuffer(lIn: integer): integer;
// converts image brightness to Hounsfield units using Slope and Intercept
// Output := (StoredImageIntensity*Slope)+zero_intercpet
begin
  if gIntRescale then
    result := round((lIn * gIntenScaleInt) + gIntenInterceptInt)
  else
    result := round((lIn * gDicomData.IntenScale) + gDicomData.IntenIntercept);

end;

function TSeriesGraphicViewer.RescaleToBuffer(lIn: integer): integer;
// converts Hounsfield units to Stored image intensity using Slope and Intercept
// Output := (HounsfieldUnit / Slope)-zero_intercpet
begin
  result := round((lIn - gDicomData.IntenIntercept) / gDicomData.IntenScale);
  // ChayMarch2003
  // result := round((lIn/gDICOMdata.IntenScale)- gDICOMdata.intenIntercept);
end;

procedure TSeriesGraphicViewer.Scale16to8bit(lWinCen, lWinWid: integer; var ABuff: Bytep0);
// Given a 16-bit input, this generates an 8-bit output, based on user's contrast/brightness settings
// Uses integer multiplication for fast computations on old CPUs
var
  lStartTime, lEndTime: DWord;
  lRngi, lMinVal, lMaxVal, lInt, lInc, lRange, i, lScaleShl10, lSz, min16,
    max16, lCen, lWid: integer;
  lBuff: ByteP0;
  lBuffx: ByteP0;
  value: SmallInt;
  Size: integer;
begin
{$R-}
  if gBuff16 = nil then
    exit;

  Size := gDicomData.XYZdim[1] * gDicomData.XYZdim[2];

  gDicomData.Maxintensity := 32768;

  if gDicomData.Maxintensity > 32767 then
  begin
    // if  then there will be wrap around if read as signed value
    i := 0;
    while i < (Size) do
    begin
      if gBuff16[i] >= 0 then
        gBuff16[i] := gBuff16[i] - 32768
      else
        gBuff16[i] := 32768 + gBuff16[i];
      i := i + 1;
    end;
    gDicomData.MinIntensitySet := false;
  end; // prevent image wrapping > 32767{}

  value := gBuff16[0];
  max16 := value;
  min16 := value;
  i := 0;
  while i < (Size) do
  begin
    value := gBuff16[i];
    if value < min16 then
      min16 := value;
    if value > max16 then
      max16 := value;
    i := i + 1;
  end;
  // showmessage(inttostr(min16)+'....'+inttostr(max16));
//
//   gImgMin := min16;
//   gImgMax := max16;
//  if (gDicomData.IntenScale * max16) < 1 then
//  begin
//    gDicomData.IntenScale := 1;
//  end; // prevents images from being underscaled
//  // showmessage(floattostr(gDICOMdata.IntenScale*max16)+'  ='+inttostr(min16)+'..'+inttostr(max16));
  if { (min16 < 0) and (gDICOMdata.MinIntensity >min16) } gDicomData.MinIntensitySet
  then
    min16 := gDicomData.MinIntensity;
  gImgMin := RescaleFromBuffer(min16);
  gImgMax := RescaleFromBuffer(max16);
  gImgWid := gImgMax - gImgMin;
  gImgCen := gImgMin + ((gImgWid) shr 1);

  if lWinWid < 0 then
  begin // autocontrast
    gWinMin := gImgMin;
    gWinMax := gImgMax;
    gWinCen := gImgCen;
    gWinWid := gImgWid;
    gFastCen := gImgCen;
  end;

  gWinCen := lWinCen;
  gWinWid := lWinWid;

  //lCen := RescaleToBuffer(lWinCen);
  // showmessage(inttostr(lWinCen));
  //lWid := abs(trunc((lWinWid / gDicomData.IntenScale) / 2));
  min16 := Smallint(Round((lWinCen - 0.5 - (lWinWid - 1) / 2)));
  max16 := Smallint(Round((lWinCen - 0.5 + (lWinWid - 1) / 2)));
  gWinMin := min16;
  gWinMax := max16;
  lSz := (g100pctImageWid * g100pctImageHt);
  //getmem(ABuff, lSz { width * height } );
  lSz := lSz - 1;
  lRange := (max16 - min16);

  if (lRange = 0) or (trunc((1024 / lRange) * 255) = 0) then
  begin
    if lWinWid > 1024 then
    begin
      for i := 0 to lSz do
        ABuff[i] := 128;

    end
    else
    begin
      for i := 0 to lSz do
        if gBuff16[i] < lWinCen then
          ABuff[i] := 0
        else
          ABuff[i] := 255;
    end;
  end
  else
  begin
    lScaleShl10 := trunc((1024 / lRange) * 255);
{$R-}
      for i := 0 to lSz do
      begin

        if gBuff16[i] < min16 then
          ABuff[i] := 0
        else if gBuff16[i] > max16 then
          ABuff[i] := 255
        else
          ABuff[i] := (((gBuff16[i]) - min16) * lScaleShl10) shr 10;
      end;
{$R+}
    end;
{$R+}
end;

procedure TSeriesGraphicViewer.Scale16to8bit(lWinCen, lWinWid: integer);
// Given a 16-bit input, this generates an 8-bit output, based on user's contrast/brightness settings
// Uses integer multiplication for fast computations on old CPUs
var
  lStartTime, lEndTime: DWord;
  lRngi, lMinVal, lMaxVal, lInt, lInc, lRange, i, lScaleShl10, lSz, min16,
    max16, lCen, lWid: integer;
  lBuff: ByteP0;
  lBuffx: ByteP0;
begin
{$R-}
  // TDICOMViewer(Owner).StatusBar.Panels[3].text := 'ax'+inttostr(random(888));

  if gBuff16 = nil then
    exit;
  gWinCen := lWinCen;
  gWinWid := lWinWid;
  if Self.Active then
  begin
    gContrastStr := 'Window Center/Width: ' + inttostr(lWinCen) + '/' +
      inttostr(lWinWid) { +':'+inttostr(round(lSlopeReal)) };
    TDICOMViewer(Owner).StatusBar.Panels[4].text := gContrastStr;

    // gContrastStr := 'ABBA: '+floattostr(gDICOMdata.IntenIntercept)+'/'+floattostr(gDICOMdata.IntenScale){+':'+inttostr(round(lSlopeReal))};
    // TDICOMViewer(Owner).StatusBar.Panels[3].text := gContrastStr;

  end;
  // showmessage(floattostr(gDICOMdata.Intenscale));
  // gDICOMdata.Intenscale := 1;

  lCen := RescaleToBuffer(lWinCen);
  // showmessage(inttostr(lWinCen));
  lWid := abs(trunc((lWinWid / gDicomData.IntenScale) / 2));
  min16 := lCen - lWid;
  max16 := lCen + lWid;
  gWinMin := min16;
  gWinMax := max16;
  lSz := (g100pctImageWid * g100pctImageHt);
  getmem(lBuffx, lSz { width * height } );
  lSz := lSz - 1;
  lRange := (max16 - min16);
  // TDICOMViewer(Owner).StatusBar.Panels[0].text := inttostr(value)+'tx'+inttostr(random(888));
  lStartTime := GetTickCount;
  // value = range
  if (lRange = 0) or (trunc((1024 / lRange) * 255) = 0) then
  begin
    if lWinWid > 1024 then
    begin
      for i := 0 to lSz do
        lBuffx[i] := 128;

    end
    else
    begin
      for i := 0 to lSz do
        if gBuff16[i] < lWinCen then
          lBuffx[i] := 0
        else
          lBuffx[i] := 255;
    end;
  end
  else
  begin
    lScaleShl10 := trunc((1024 / lRange) * 255);
    // value = range,Scale = 255/range
    (*
      if lSz > 131070  then begin //large image: make a look up table  x2 speedup
      //Using this code speeds up rescaling slightly, but not well tested...
      lMinVal := RescaleToBuffer(gImgMin)-1; //gRaw16Min;//
      lMaxVal := RescaleToBuffer(gImgMax)+1; //gRaw16Max;//
      lRngi := ROund(lMaxVal-lMinVal);
      getmem(lBuff, lRngi+1);  //+1 if the only values are 0,1,2 the range is 2, but there are 3 values!
      //max16 := max16-2;
      for lInc := (lRngi) downto 0 do begin
      lInt := lInc+lMinVal; //32 bit math fastest
      if lInt < min16 then
      lBuff[lInc] := 0 //0
      else if lInt > max16 then
      lBuff[lInc] := 255
      else
      lBuff[lInc] :=  (((lInt)-min16) * lScaleShl10)  shr 10;
      end;
      lInc := 1;
      for i := 0 to lSz do
      lbuffx[i] := lBuff[gBuff16[i]-lMinVal] ;
      freemem(lBuff);
      end else *) begin // if lSz -> use look up table for large images
{$R-}
      for i := 0 to lSz do
      begin

        if gBuff16[i] < min16 then
          lBuffx[i] := 0
        else if gBuff16[i] > max16 then
          lBuffx[i] := 255
        else
          lBuffx[i] := (((gBuff16[i]) - min16) * lScaleShl10) shr 10;
        // NOTE: integer maths increases speed x7!
        // lbuff[i] := (Trunc(255*((gBuff16[i])-min16) / (value)));
      end;
{$R+}
    end; // if lSz ,,large image  .. else ...
  end; // lRange > 0
  // self.caption :=('update(ms): '+inttostr(GetTickCount-lStartTime)); //70 ms
 // SetDimension(g100pctImageHt, g100pctImageWid, 8, lBuffx, false);
  //DICOMImageRefreshAndSize;
  //freemem(lBuffx);
{$R+}
end;

function TSeriesGraphicViewer.VxlVal(X, Y: integer; lRGB_greenOnly: boolean): integer;
// Reports the intensity of a voxel at location X/Y
// If lRGB_greenOnly = TRUE, then the RRGGBB value #112233 will be #22 (useful for estimating approximate brightness at a voxel
// If lRGB_greenOnly = TRUE, then the RRGGBB value #112233 will be #112233 (actual RGB value)
var
  lVxl, lVxl24: integer;
begin
{$R-}
  result := 0;
  lVxl := (Y * g100pctImageWid) + X; // rel20 Wid not Ht
  lVxl24 := (Y * g100pctImageWid * 3) + (X * 3);
  if (gBuff16sz > 0) and (lVxl >= 0) and (lVxl < gBuff16sz) then
    result := RescaleFromBuffer(gBuff16[lVxl])
  else if (gBuff8sz > 0) and (lVxl >= 0) and (lVxl < gBuff8sz) then
    result := gBuff8[lVxl]
  else if (gBuff24sz > 0) and (lVxl24 >= 0) and (lVxl24 < gBuff24sz) then
  begin
    if lRGB_greenOnly then
      result := (gBuff24[lVxl24 + 1]) { green }
    else
      result := gBuff24[lVxl24 + 2] { blue } + (gBuff24[lVxl24 + 1] shl 8)
      { green } + (gBuff24[lVxl24] shl 16) { red };
  end;
{$R+}
end;

procedure TSeriesGraphicViewer.Vxl(X, Y: integer);
// Reports Brightness of voxel under the cursor
begin
  if (gBuff8sz > 0) or (gBuff16sz > 0) then
    TDICOMViewer(Owner).StatusBar.Panels[0].text := inttostr(VxlVal(X, Y, false))
  else if (gBuff24sz > 0) then
    TDICOMViewer(Owner).StatusBar.Panels[0].text := '#' +
      Format('%*.*x', [6, 6, VxlVal(X, Y, false)])
  else
    TDICOMViewer(Owner).StatusBar.Panels[0].text := '';
end;


{$R-}
procedure TSeriesGraphicViewer.SetDimension(lInPGHt, lInPGWid, lInBits: integer;
  lInBuff: ByteP0; lUseWinCenWid: boolean);
// Draws a graphic using the values in lInBuff
// Contains the nested procedure ScaleStretch, that resizes the image using linear interpolation (minimizing jaggies)
var
  lBuff: ByteP0;
  lPGwid, lPGHt, lBits: integer;
  procedure ScaleStretch(lSrcHt, lSrcWid: integer; lInXYRatio: single);
  var
    lKScale: byte;
    lrRA, lbRA, lgRA: array [0 .. 255] of byte;
    // lBuff: ByteP0;
    lPos, xP, yP, yP2, xP2, t, z, z2, iz2, w1, w2, w3, w4, lTopPos, lBotPos,
      lINSz, lDstWidM, { lDstWid,lDstHt, } X, Y, lLT, lLB, lRT, lRB: integer;
    lXRatio, lYRatio: single;
  begin
    yP := 0;
    lXRatio := lInXYRatio;
    lYRatio := lInXYRatio;
    lINSz := lSrcWid * lSrcHt;
    lPGwid := { round } round(lSrcWid * lXRatio); // *lZoom;
    lPGHt := { round } round(lSrcHt * lYRatio); // *lZoom;
    lKScale := 1;
    xP2 := ((lSrcWid - 1) shl 15) div (lPGwid - 1);
    yP2 := ((lSrcHt - 1) shl 15) div (lPGHt - 1);
    lPos := 0;
    lDstWidM := lPGwid - 1;
    if lBits = 24 then
    begin
      getmem(lBuff, lPGHt * lPGwid * 3);
      lINSz := lINSz * 3; // 24bytesperpixel
      for Y := 0 to lPGHt - 1 do
      begin
        xP := 0;
        lTopPos := lSrcWid * (yP shr 15) * 3; // top row
        if yP shr 16 < lSrcHt - 1 then
          lBotPos := lSrcWid * (yP shr 15 + 1) * 3 // bottom column
        else
          lBotPos := lTopPos;
        z2 := yP and $7FFF;
        iz2 := $8000 - z2;
        X := 0;
        while X < lPGwid do
        begin
          t := (xP shr 15) * 3;
          if ((lBotPos + t + 6) > lINSz) or ((lTopPos + t) < 0) then
          begin
            lBuff[lPos] := 0;
            inc(lPos); // reds
            lBuff[lPos] := 0;
            inc(lPos); // greens
            lBuff[lPos] := 0;
            inc(lPos); // blues
          end
          else
          begin
            z := xP and $7FFF;
            w2 := (z * iz2) shr 15;
            w1 := iz2 - w2;
            w4 := (z * z2) shr 15;
            w3 := z2 - w4;
            lBuff[lPos] := (lInBuff[lTopPos + t] * w1 + lInBuff[lTopPos + t + 3]
              * w2 + lInBuff[lBotPos + t] * w3 + lInBuff[lBotPos + t + 3] *
              w4) shr 15;
            inc(lPos); // reds
            lBuff[lPos] :=
              (lInBuff[lTopPos + t + 1] * w1 + lInBuff[lTopPos + t + 4] * w2 +
              lInBuff[lBotPos + t + 1] * w3 + lInBuff[lBotPos + t + 4] *
              w4) shr 15;
            inc(lPos); // greens
            lBuff[lPos] :=
              (lInBuff[lTopPos + t + 2] * w1 + lInBuff[lTopPos + t + 5] * w2 +
              lInBuff[lBotPos + t + 2] * w3 + lInBuff[lBotPos + t + 5] *
              w4) shr 15;
            inc(lPos); // blues
          end;
          inc(xP, xP2);
          inc(X);
        end; // inner loop
        inc(yP, yP2);
      end;
    end
    else if gCustomPalette > 0 then
    begin // <>24bits,custompal
      lBits := 24;
      for Y := 0 to 255 do
      begin
        lrRA[Y] := gRra[Y];
        lgRA[Y] := gGra[Y];
        lbRA[Y] := gBra[Y];
      end;
      getmem(lBuff, lPGHt * lPGwid * 3);
      for Y := 0 to lPGHt - 1 do
      begin
        xP := 0;
        lTopPos := lSrcWid * (yP shr 15); // Line1
        if yP shr 16 < lSrcHt - 1 then
          lBotPos := lSrcWid * (yP shr 15 + 1) // Line2
        else
          lBotPos := lTopPos; // lSrcWid *(yP shr 15);
        z2 := yP and $7FFF;
        iz2 := $8000 - z2;
        X := 0;
        while X < lPGwid do
        begin
          t := xP shr 15;
          if ((lBotPos + t + 2) > lINSz) or ((lTopPos + t { -1 } ) < 0) then
          begin
            lLT := 0;
            lRT := 0;
            lLB := 0;
            lRB := 0;
          end
          else
          begin
            lLT := lInBuff[lTopPos + t];
            lRT := lInBuff[lTopPos + t + 1];
            lLB := lInBuff[lBotPos + t];
            lRB := lInBuff[lBotPos + t + 1];
          end;
          z := xP and $7FFF;
          w2 := (z * iz2) shr 15;
          w1 := iz2 - w2;
          w4 := (z * z2) shr 15;
          w3 := z2 - w4;
          lBuff[lPos] := (lrRA[lLT] * w1 + lrRA[lRT] * w2 + lrRA[lLB] * w3 +
            lrRA[lRB] * w4) shr 15;
          inc(lPos);
          lBuff[lPos] := (lgRA[lLT] * w1 + lgRA[lRT] * w2 + lgRA[lLB] * w3 +
            lgRA[lRB] * w4) shr 15;
          inc(lPos);
          lBuff[lPos] := (lbRA[lLT] * w1 + lbRA[lRT] * w2 + lbRA[lLB] * w3 +
            lbRA[lRB] * w4) shr 15;
          inc(lPos);
          inc(xP, xP2);
          inc(X);
        end; // inner loop
        inc(yP, yP2);
      end;
    end
    else
    begin // <>24bits,custompal
      getmem(lBuff, lPGHt * lPGwid { *3 } );
      for Y := 0 to lPGHt - 1 do
      begin
        xP := 0;
        lTopPos := lSrcWid * (yP shr 15); // Line1
        if yP shr 16 < lSrcHt - 1 then
          lBotPos := lSrcWid * (yP shr 15 + 1) // Line2
        else
          lBotPos := lTopPos; // lSrcWid *(yP shr 15);
        z2 := yP and $7FFF;
        iz2 := $8000 - z2;
        // for x:=0 to lDstWid-1 do begin
        X := 0;
        while X < lPGwid do
        begin
          t := xP shr 15;
          if ((lBotPos + t + 2) > lINSz) or ((lTopPos + t { -1 } ) < 0) then
          begin
            lLT := 0;
            lRT := 0;
            lLB := 0;
            lRB := 0;
          end
          else
          begin
            lLT := lInBuff[lTopPos + t { +1 } ];
            lRT := lInBuff[lTopPos + t { +2 } + 1];
            lLB := lInBuff[lBotPos + t { +1 } ];
            lRB := lInBuff[lBotPos + t { +2 } + 1];
          end;
          z := xP and $7FFF;
          w2 := (z * iz2) shr 15;
          w1 := iz2 - w2;
          w4 := (z * z2) shr 15;
          w3 := z2 - w4;
          lBuff[lPos] := (lLT * w1 + lRT * w2 + lLB * w3 + lRB * w4) shr 15;
          inc(lPos);
          inc(xP, xP2);
          inc(X);
        end; // inner loop
        inc(yP, yP2);
      end;
    end; // <>24bits,custompal
  end;

var
  // lStartTime, lEndTime: DWord;
  lBufferUsed: boolean;
  PixMap: pointer;
  Bmp: TBitmap;
  hBmp: HBITMAP;
  BI: PBitmapInfo;
  BIH: TBitmapInfoHeader;
  lSlope, lScale: single;
  lPixmapInt, lBuffInt: integer;
  ImagoDC: hDC;
  lByteRA: array [0 .. 255] of byte;
  lRow: pRGBTripleArray;
  lWinScaleShl16, lWinC, lWinW, lMinPal, lMaxPal, lL, lTemp, lHt, lWid, i, j,
    lScanLineSz, lScanLineSz8: integer;

  bmpinfo: tagBITMAPINFO;
begin
//  gLine.Left := -666;
//  gLineLenMM := 0;
//  FreeBackupBitmap;
//  lScale := gZoomPct / 100;
//  lBits := lInBits;
//  { rotate }
//
//  if (lScale = 1) or (not gSmooth) then
//  begin
//    lPGwid := lInPGWid;
//    lPGHt := lInPGHt;
//    lBuff := @lInBuff^;
//    lBufferUsed := false;
//  end
//  else
//  begin
//    lBufferUsed := true;
//    ScaleStretch(lInPGHt, lInPGWid, lScale);
//  end;
//  if (lBits = 24) { or (lBits = 25) } then
//  begin
//    if (Self.gDicomData.RLERedSz <> 0) or
//      (Self.gDicomData.SamplesPerPixel > 1) or
//      (Self.gCustomPalette > 0) then
//    begin
//      lWinC := gWinCen;
//      lWinW := gWinWid;
//      // lStartTime := GetTickCount;
//      if ((lWinC = 127) and (lWinW = 255)) or (lWinW = 0) then
//        // scaling not required
//      else
//      begin
//        if not lBufferUsed then
//        begin
//          getmem(lBuff, lPGHt * lPGwid * 3);
//          CopyMemory(pointer(lBuff), pointer(lInBuff), lPGHt * lPGwid * 3);
//          lBufferUsed := true;
//        end;
//        lWinScaleShl16 := 1 shl 16;
//        lWinScaleShl16 := round(lWinScaleShl16 * (256 / lWinW));
//        for lL := 0 to 255 do
//        begin // lookup buffer for scaling
//          lTemp := lL - lWinC;
//          lTemp := (lTemp * lWinScaleShl16);
//          lTemp := lTemp div 65536;
//          lTemp := 128 + lTemp;
//          if lTemp < 0 then
//            lTemp := 0
//          else if lTemp > 255 then
//            lTemp := 255;
//          lByteRA[lL] := lTemp;
//        end;
//        j := (lPGwid * lPGHt * 3) - 1;
//        for lL := 0 to j do
//        begin
//          lBuff[lL] := lByteRA[lBuff[lL]];
//
//        end;
//      end; // scaling required
//      // self.caption :=('update(ms): '+inttostr(GetTickCount-lStartTime)); //70 ms
//    end;
////    Bmp := TBitmap.Create;
////    lL := 0;
////    TRY
////      Bmp.PixelFormat := pf24bit;
////      Bmp.Width := lPGwid;
////      Bmp.Height := lPGHt;
////      if lBuff <> nil then
////      begin
//        // if VertFlipItem.checked then
//        // J := BMP.Height-1
//        // else
////        j := 0;
////        REPEAT
////          lRow := Bmp.Scanline[j];
//          { if HorFlipItem.checked then begin
//            FOR i := BMP.Width-1 downto 0 DO BEGIN
//            WITH lRow[i] DO BEGIN
//            rgbtRed    := lBuff[lL];
//            inc(lL);
//            rgbtGreen := lBuff[lL];
//            inc(lL);
//            rgbtBlue  := lBuff[lL];
//            inc(lL);
//            END //with row
//            END;  //for width
//            end else begin //horflip { }
////          FOR i := 0 TO Bmp.Width - 1 DO
////          BEGIN
////            WITH lRow[i] DO
////            BEGIN
////              rgbtRed := lBuff[lL];
////              inc(lL);
////              rgbtGreen := lBuff[lL];
////              inc(lL);
////              rgbtBlue := lBuff[lL];
////              inc(lL);
////            END // with row
////          END; // for width
//          // end; //horflip
//          // if VertFlipItem.checked then
//          // Dec(J)
//          // else
////          inc(j)
////        UNTIL (j < 0) or (j >= Bmp.Height); // for J
////      end;
////      Image.Picture.Graphic := Bmp;
////    FINALLY
////      Bmp.free;
////    END;
//
//    bmpinfo.bmiHeader.biSize := sizeof(bmpinfo);
//    bmpinfo.bmiHeader.biWidth       := 801;
//    bmpinfo.bmiHeader.biHeight      := -801;
//    bmpinfo.bmiHeader.biPlanes      :=  1;
//    bmpinfo.bmiHeader.biBitCount    :=  24;
//    bmpinfo.bmiHeader.biCompression :=  BI_RGB;
//    bmpinfo.bmiHeader.biSizeImage   :=  0;
//
//    StretchDIBits(Image.Canvas.Handle, 0, 0, 801, 801, 0, 0, 801, 801, @gBuff24[0], bmpinfo, DIB_RGB_COLORS, SRCCOPY);
//
//    if (lBufferUsed) then // alpha1415ABBA: required
//      freemem(lBuff);
//    exit;
//  end; // 24bit
//{$P-,S+,W+,R-}
end;

PROCEDURE TSeriesGraphicViewer.ShowMagnifier(CONST X, Y: integer);
// Shows a magnifier over one region of the image, saves old region a BackupBitmap
VAR
  AreaRadius: integer;
  Magnification: integer;
  xActual, yActual { ,lMagArea } : integer;
BEGIN
  if BackupBitmap = nil then
    exit;
  xActual := round((X * Image.Picture.Height) / Image.Height);
  yActual := round((Y * Image.Picture.Width) / Image.Width);

  if (xActual < 0) or (yActual < 0) or (xActual > Image.Picture.Width) or
    (yActual > Image.Picture.Height) then
    exit;
  if (not gSmooth) and (gZoomPct <> 0) then
    AreaRadius := (50 * 100) div gZoomPct
  else
    AreaRadius := 50;
  Magnification := { round((30*2) / (100)) } AreaRadius * 2;
  // round(( (( gZoomPct div 50)+1) * 100)  /gZoomPct * AreaRadius);
  if (gMagRect.Left <> gMagRect.Right) then
  begin
    Image.Picture.Bitmap.Canvas.CopyRect(gMagRect, BackupBitmap.Canvas,
      // [anme]
      gMagRect);
  end;
  gMagRect := Rect(xActual - Magnification, yActual - Magnification,
    xActual + Magnification, yActual + Magnification);
  Image.Picture.Bitmap.Canvas.CopyRect(gMagRect, BackupBitmap.Canvas, // [anme]
    Rect(xActual - AreaRadius, yActual - AreaRadius, xActual + AreaRadius,
    yActual + AreaRadius));
  Image.refresh;
END;

procedure TSeriesGraphicViewer.ShowSlice(ASliceIndex: Integer);
var
  FileName: string;
begin
  if (gDicomData.XYZdim[3] > 1) then
  begin
    DisplayImage(false, false, ASliceIndex, gWinWid, gWinCen);
    gSlice := ASliceIndex;
  end
  else
  if (gStringList.Count > 0) then
  begin
    if (Assigned(Self.Owner) and (Self.Owner is TDICOMViewer)) AND
       (not (Self.Owner as TDICOMViewer).Study.InitialDir.IsEmpty) then
      FileName := gStringList[ASliceIndex-1]
    else
      FileName := gFilePath + gStringList.Strings[ASliceIndex-1];

    LoadData(FileName, false, false, false, false);
    gCurrentPosInFileList := ASliceIndex;
  end;

  AutoMaximise;
end;

function TSeriesGraphicViewer.SliceCount: Integer;
begin
  if (gDicomData.XYZdim[3] > 1) then
    Result := gDicomData.XYZdim[3]
  else
    Result := gStringList.Count;
end;

{ ShowMagnifier }

procedure FireLUT(lIntensity, lTotal: integer; var lR, lG, lB: integer);
// Generates a 'hot metal' style color lookup table
var
  l255scale: integer;
begin
  l255scale := round(lIntensity / lTotal * 255);
  lR := (l255scale - 52) * 3;
  if lR < 0 then
    lR := 0
  else if lR > 255 then
    lR := 255;
  lG := (l255scale - 108) * 2;
  if lG < 0 then
    lG := 0
  else if lG > 255 then
    lG := 255;
  case l255scale of
    0 .. 55:
      lB := (l255scale * 4);
    56 .. 118:
      lB := 220 - ((l255scale - 55) * 3);
    119 .. 235:
      lB := 0;
  else
    lB := ((l255scale - 235) * 10);
  end; { case }
  if lB < 0 then
    lB := 0
  else if lB > 255 then
    lB := 255;
end;

procedure TSeriesGraphicViewer.LoadColorScheme(lStr: string; lScheme: integer);
// Loads a color lookup tabel from disk.
// Lookup tables can either be in Osiris format (TEXT) or ImageJ format (BINARY: 768 bytes)
const
  UNIXeoln = chr(10);
var
  lF: textfile;
  lBuff: ByteP0;
  lFdata: file;
  lCh: char;
  lNumStr: String;
  lRi, lGi, lBi, lZ: integer;
  lByte, lIndex, lRed, lBlue, lGreen: byte;
  lType, lIndx, lLong, lR, lG, lB: boolean;
  procedure ResetBools;
  begin
    lType := false;
    lIndx := false;
    lR := false;
    lG := false;
    lB := false;
    lNumStr := '';
  end;

begin
  gScheme := lScheme;
  if lScheme < 3 then
  begin // AUTOGENERATE LUT 0/1/2 are internally generated: do not read from disk
    case lScheme of
      0:
        for lZ := 0 to 255 do
        begin // 1: low intensity=white, high intensity = black
          gRra[lZ] := 255 - lZ;
          gGra[lZ] := 255 - lZ;
          gBra[lZ] := 255 - lZ;
        end;
      2:
        for lZ := 0 to 255 do
        begin // Hot metal LUT
          FireLUT(lZ, 255, lRi, lGi, lBi);
          gRra[lZ] := lRi;
          gGra[lZ] := lGi;
          gBra[lZ] := lBi;
        end;
    else
      for lZ := 0 to 255 do
      begin // 1: low intensity=black, high intensity = white
        gRra[lZ] := lZ;
        gGra[lZ] := lZ;
        gBra[lZ] := lZ;

      end;
    end; // case
    gMaxRGB := (gRra[255] + (gGra[255] shl 8) + (gBra[255] shl 16));
    gMinRGB := (gRra[0] + (gGra[0] shl 8) + (gBra[0] shl 16));
    exit;
  end; // AUTOGENERATE LUT
  lIndex := 0;
  lRed := 0;
  lGreen := 0;
  if gCustomPalette > 0 then
    exit;
  if not fileexists(lStr) then
    exit;
  AssignFile(lFdata, lStr);
  Filemode := 0;
  Reset(lFdata, 1);
  lZ := FileSize(lFdata);
  if (lZ = 768) or (lZ = 800) or (lZ = 970) then
  begin
    getmem(lBuff, 768);
    Seek(lFdata, lZ - 768);
    BlockRead(lFdata, lBuff^, 768);
    CloseFile(lFdata);
    for lZ := 0 to 255 do
    begin
      // lZ := (lIndex);
      gRra[lZ] := lBuff[lZ];
      gGra[lZ] := lBuff[lZ + 256];
      gBra[lZ] := lBuff[lZ + 512];
    end;

    { write output ->
      filemode := 1;
      lZ := 256;
      AssignFile(lFData, 'C:\Documents and Settings\Chris\My Documents\imagen\smash.lut');
      Rewrite(lFData,1);
      BlockWrite(lFdata, lBuff[0], lZ);   //red
      BlockWrite(lFdata, lBuff[2*lZ], lZ); //blue
      BlockWrite(lFdata, lBuff[lZ], lZ); //green
      //BlockWrite(lFdata, lBuff^, lZ);
      CloseFile(lFData);

      {end write output }

    freemem(lBuff);
    gMaxRGB := (gRra[255] + (gGra[255] shl 8) + (gBra[255] shl 16));
    gMinRGB := (gRra[0] + (gGra[0] shl 8) + (gBra[0] shl 16));

    exit;

  end;
  CloseFile(lFdata);
  lLong := false;
  AssignFile(lF, lStr);
  Filemode := 0;
  Reset(lF);
  ResetBools;
  for lByte := 0 to 255 do
  begin
    gRra[lByte] := 0;
    gGra[lByte] := 0;
    gBra[lByte] := 0;
  end;

  (* Start PaintShopProConverter
    lNumStr := '';
    lCh := ' ';
    while (not EOF(lF)) and (lCh <> kCR) and (lCh <> UNIXeoln) do begin
    read(lF,lCh); //header signatur JASC-PAL
    lNumStr := lNumStr + lCh;
    end;
    lCh := ' ';
    while (not EOF(lF)) and (lCh <> kCR) and (lCh <> UNIXeoln) do begin
    read(lF,lCh); //jasc header version 0100
    lNumStr := lNumStr + lCh;
    end;
    lCh := ' ';
    while (not EOF(lF)) and (lCh <> kCR) and (lCh <> UNIXeoln) do begin
    read(lF,lCh); //jasc header index items, e.g. 256
    lNumStr := lNumStr + lCh;
    end;
    //            showmessage(lNumStr);
    for lIndex := 0 to 255 do begin
    for lZ := 1 to 3 do begin
    lNumStr := '';
    repeat
    read(lF,lCh);
    if lCh in ['0'..'9'] then
    lNumStr := lNumStr + lCh;
    until (lNumStr <> '') and (not (lCh in ['0'..'9']));
    case lZ of
    1: gGra[lIndex] := strtoint(lNumStr);
    2: grra[lIndex] := strtoint(lNumStr);
    else gBra[lIndex] := strtoint(lNumStr);

    end; //case lZ
    end; //for lZ r,g,b loops

    end; //for lIndex 0..255 loops
    lIndex := 0;
    filemode := 1;
    lZ := 256;
    AssignFile(lFData, 'C:\Documents and Settings\Chris\My Documents\imagen\newlut.lut');
    Rewrite(lFData,1);
    BlockWrite(lFdata, gRra[1], lZ);   //red
    BlockWrite(lFdata, gGra[1], lZ); //blue
    BlockWrite(lFdata, gBra[1], lZ); //green
    //BlockWrite(lFdata, lBuff^, lZ);
    CloseFile(lFData);
    exit;
    (*end - PaintShopPro format *)

  (* begin Osiris format reader *)

  // if EOF(lF) then
  // do not start reading
  // else repeat
  while not EOF(lF) do
  begin
    read(lF, lCh);
    if lCh = '*' then // comment character
      while (not EOF(lF)) and (lCh <> kCR) and (lCh <> UNIXeoln) do
        read(lF, lCh);
    if (lCh = 'L') or (lCh = 'l') then
    begin
      lType := true;
      lLong := true;
    end; // 'l'
    if (lCh = 's') or (lCh = 'S') then
    begin
      lType := true;
      lLong := false;
    end; // 's'
    if lCh in ['0' .. '9'] then
      lNumStr := lNumStr + lCh;
    // note on next line: revised 9/9/2003: will read final line of text even if EOF instead of EOLN for final index
    if ((not(lCh in ['0' .. '9'])) or (EOF(lF))) and (length(lNumStr) > 0) then
    begin // not a number = space??? try to read number string
      if not lIndx then
      begin
        lIndex := strtoint(lNumStr);
        lIndx := true;
      end
      else
      begin // not index
        if lLong then
          lByte := trunc(strtoint(lNumStr) / 256)
        else
          lByte := strtoint(lNumStr);
        if not lR then
        begin
          lRed := lByte;
          lR := true;
        end
        else if not lG then
        begin
          lGreen := lByte;
          lG := true;
        end
        else if not lB then
        begin
          lBlue := lByte;
          // if (lIndex > 253) then showmessage(inttostr(lIndex));
          lB := true;
          gRra[lIndex] := lRed;
          gGra[lIndex] := lGreen;
          gBra[lIndex] := lBlue;
          // if lIndex = 236 then showmessage(inttostr(lBlue));
          ResetBools;
        end;
      end;
      lNumStr := '';
    end;
  end;
  // until EOF(lF); //not eof
  (* end osiris reader *)
  { write as ImageJ format
    filemode := 1;
    lZ := 256;
    AssignFile(lFData, 'C:\Documents and Settings\Chris\My Documents\imagen\cortex.lut');
    Rewrite(lFData,1);
    BlockWrite(lFdata, gRra[1], lZ);   //red
    BlockWrite(lFdata, gGra[1], lZ); //blue
    BlockWrite(lFdata, gBra[1], lZ); //green
    CloseFile(lFData);
    {end write }
  gMaxRGB := (gRra[255] + (gGra[255] shl 8) + (gBra[255] shl 16));
  gMinRGB := (gRra[0] + (gGra[0] shl 8) + (gBra[0] shl 16));
  CloseFile(lF);
  Filemode := 2;
end;

procedure TSeriesGraphicViewer.FormClose(Sender: TObject; var Action: TCloseAction);
// release dynamic memory
begin
  gDynStr := '';

  gSelectRect := Rect(0, 0, 0, 0);
  gSelectOrigin.X := -1;

  TDICOMViewer(Owner).ColUpdate;
  FreeAndNil(gStringList); // rev20

  ReleaseDICOMmemory;

  TDICOMViewer(Owner).Study.OnSeriesViewerChange(nil, nil);
end;

procedure TSeriesGraphicViewer.FormCreate(Sender: TObject);
// Initialize form
var
  i: integer;
begin
  gDicomData := TDICOMData.Create;

  gSmooth := True;
  Smooth1.checked := gSmooth;
  gMultiRow := 1;
  gMultiCol := 1;
  BackupBitmap := nil;
  gScheme := 1;
  gWinCen := 0;
  gWinWid := 0;
  gStringList := TStringList.Create;
  gFileListSz := 0;
  gCurrentPosInFileList := -1;
  gBuff16sz := 0;
  gVideoSpeed := 0;
  gBuff8sz := 0;
  FFileName := '';
  gContrastStr := '';
  gDicomData.Allocbits_per_pixel := 0;
  gCustomPalette := 0;
  gMinHt := 10;
  gMinWid := 10;
  gDicomData.XYZdim[1] := 0;
  gDicomData.XYZdim[2] := 0;
  g100pctImageWid := 0;
  g100pctImageHt := 0;
  gZoomPct := 100;

  // for i := 0 to MainMenu1.Items.Count - 1 do
  //TDICOMViewer(Owner).MainMenu1.Merge(MainMenu1);

  // for lInc := 0 to 255 do
  // gRGBquadRA[lInc].rgbReserved := 0;
end;

procedure TSeriesGraphicViewer.FormDestroy(Sender: TObject);
begin
  if Assigned(Self.Owner) and
     (Self.Owner is TDICOMViewer) then
    (Self.Owner as TDICOMViewer).Study.Series.ExtractPair(Self.gDicomData.SerieUID);

  inherited;
end;

procedure TSeriesGraphicViewer.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if StudyMenu.Enabled then
    if Key = '=' then
      Previous1Click(Next1)
    else
    if Key = '-' then
      Previous1Click(Previous1);
end;

destructor TSeriesGraphicViewer.Destroy;
begin
  ReleaseDICOMmemory;

  inherited;
end;

procedure TSeriesGraphicViewer.DetermineZoom;
// Work out scale of image.
// Can scale image to fit the form size
var
  lHZoom: single;
  lZoom, lZOomPct: integer;
begin
  if (not TDICOMViewer(Owner).btnBestFit.Down) then
    exit;

  lHZoom := (ClientWidth) / g100pctImageWid;

  if ((ClientHeight) / g100pctImageHt) < lHZoom then
    lHZoom := ((ClientHeight) / g100pctImageHt);

  lZOomPct := trunc(100 * lHZoom);

  if lZOomPct < 11 then
    lZoom := 10 // .5 zoom
  else if lZOomPct > 500 then
    lZoom := 500
  else
    lZoom := lZOomPct;

  gZoomPct := lZoom;
end;

procedure TSeriesGraphicViewer.AutoMaximise;
// Rescales image to fit form
var
  lZoom: integer;
begin
  if (not TDICOMViewer(Owner).btnBestFit.Down) or (g100pctImageHt < 1) or
    (g100pctImageWid < 1) then
    exit;

  lZoom := gZoomPct;
  DetermineZoom;
  if lZoom <> gZoomPct then
  begin
    RefreshZoom;
    TDICOMViewer(Owner).trackZoomSlider.Position := lZoom;
  end;
end;

function FSize(lFName: String): longint;
var
  infp: file;
begin
  Assign(infp, lFName);
  Filemode := 0; // Read only
  Reset(infp, 1);

  result := FileSize(infp);
  CloseFile(infp);
  Filemode := 2;
end;

function TSeriesGraphicViewer.LoadData(lFileName: string; lAnalyze, lECAT, l2dImage, lRaw: boolean): boolean;
  function FindDicomData: TDICOMData;
  var
    i: integer;
    CurDICOMData: TDICOMData;
  begin
    for i := 0 to gStringList.Count - 1 do
      if SameText(TDICOMData(gStringList.Objects[i]).FileName, lFileName) then
      begin
        Result := TDICOMData(gStringList.Objects[i]);
        Break;
      end;
  end;
// Loads and displays a medical image, also searches for other DICOM images in the same folder as the image you have opened
// This latter feature allows the user to quickly cycle between successive images
var
  lHdrOK: boolean;
  lAllocSLiceSz, lS: integer;
  lExt: string;
  JPG: TJPEGImage;
  Stream: TmemoryStream;
  Bmp: TBitmap;
  lImage: TImage;
begin
  ReleaseDICOMmemory;
  RescaleClear;
  gFilePath := extractfilepath(lFileName);
  FDICOM := true;
  gScheme := 1;
  gSlice := 1;
  LoadColorScheme('', gScheme); // load Black and white
  result := true;
  gImgOK := false;
  FFileName := lFileName;
  gAbort := true;
  if not fileexists(lFileName) then
  begin
    result := false;
    showmessage('Unable to find the file: ' + lFileName);
    exit;
  end;
  Self.Caption := extractfilename(lFileName);
  lExt := UpperCase(ExtractFileExt(FFileName));
  if (l2dImage) or ('.JPG' = lExt) or ('.JPEG' = lExt) or ('.BMP' = lExt) then
  begin
    FDICOM := false;
    if ('.JPG' = lExt) or ('.JPEG' = lExt) then
    begin
      { JPEGOriginal := TJPEGImage.Create;
        TRY
        JPEGOriginal.LoadFromFile(FFilename);
        Image.Picture.Graphic := JPEGOriginal
        FINALLY
        JPEGOriginal.Free
        END; }
      // the following longer method makes sure the user can save the JPEG file...
      { Stream := TMemoryStream.Create;
        try
        Stream.LoadFromFile(FFilename);
        Stream.Seek(0, soFromBeginning);
        Jpg := TJPEGImage.Create;
        try
        Jpg.LoadFromStream(Stream);
        BMP := TBitmap.create;
        try
        BMP.Height := JPG.Height;
        BMP.Width := JPG.Width;
        BMP.PixelFormat := pf24bit;
        BMP.Canvas.Draw(0,0, JPG);
        Image.Picture.Graphic := BMP;
        finally
        BMP.Free;
        end;
        finally
        JPG.Free;
        end;
        finally
        Stream.Free;
        end;{ }
      // next bit allows contrast adjustable JPEG images....
      Stream := TmemoryStream.Create;
      try
        Stream.LoadFromFile(FFileName);
        Stream.Seek(0, soFromBeginning);
        JPG := TJPEGImage.Create;
        try
          JPG.LoadFromStream(Stream);
          gDicomData.XYZdim[1] := JPG.Width;
          gDicomData.XYZdim[2] := JPG.Height;
          Image.Width := JPG.Width;
          Image.Height := JPG.Height;

          { BMP := TBitmap.create;
            try
            BMP.Height := JPG.Height;
            BMP.Width := JPG.Width;
            BMP.PixelFormat := pf24bit;
            BMP.Canvas.Draw(0,0, JPG);
            Image.Picture.Graphic := BMP;
            finally
            BMP.Free;
            end; }
        finally
          JPG.free;
        end;
      finally
        Stream.free;
      end;

      gDicomData.SamplesPerPixel := 3;
      gDicomData.Storedbits_per_pixel := 8;
      gDicomData.Allocbits_per_pixel := 8;
      gDicomData.ImageStart := 0;
      g100pctImageWid := gDicomData.XYZdim[1];
      g100pctImageHt := gDicomData.XYZdim[2];
      gDicomData.XYZdim[3] := 1;
      gECATposra[1] := 0;
      // CloseFile(infp); //we will read this file directly
      lAllocSLiceSz := (gDicomData.XYZdim[1] * gDicomData.XYZdim[2]);
      // 24bits per pixel: number of voxels in each colour plane
      gBuff24sz := lAllocSLiceSz * 3;
      getmem(gBuff24, lAllocSLiceSz * 3);
      //decompressJPEG24(FFileName, gBuff24, lAllocSLiceSz, gECATposra[1], Image);
      TDICOMViewer(Owner).ColUpdate;
      DetermineZoom;
      SetDimension(gDicomData.XYZdim[2], gDicomData.XYZdim[1], 24,
        gBuff24, false);
      DICOMImageRefreshAndSize;
      Image.refresh;
      FDICOM := true;
      gImgMin := 0;
      gImgMax := 255;
      gWinMin := 0;
      gWinMax := 255;

      { }
      // ?? what if gDICOMdata.monochrome = 4 -> is YcBcR photometric interpretation dealt with by the JPEG comrpession or not? I have never seen such an image, so I guess this is an impossible combination
      // Reset(infp, 1); //other routines expect this to be left open

    end
    else
      Image.Picture.Bitmap.LoadFromFile(FFileName);
    // if Image.Picture.Bitmap.PixelFormat = pf8 then
    gDicomData.SamplesPerPixel := 3;
    gDicomData.Storedbits_per_pixel := 8;
    gDicomData.Allocbits_per_pixel := 8;
    gDicomData.ImageStart := 54;
    gDicomData.XYZdim[1] := Image.Picture.Width;
    gDicomData.XYZdim[2] := Image.Picture.Height;
    g100pctImageWid := gDicomData.XYZdim[1];
    g100pctImageHt := gDicomData.XYZdim[2];
    Image.Width := Image.Picture.Width;
    Image.Height := Image.Picture.Height;
    gDicomData.XYZdim[3] := 1;
    if Self.WindowState <> wsMaximized then
    begin
      Self.ClientHeight := gDicomData.XYZdim[2];
      Self.ClientWidth := (gDicomData.XYZdim[1]);
    end;
    TDICOMViewer(Owner).ColUpdate;
    ContrastAutobalance1.enabled := false;
    OptionsImgInfoItem.enabled := false;
    gImgOK := true;
    AutoMaximise;
    Image.refresh;
    exit;
  end;
  FDICOM := true;

  gDicomData := FindDicomData;

  if not SameText(gDicomData.FileName, lFileName) then
    Exit
  else
  begin
    lHdrOK := True;
    gImgOK := True;
  end;

  gDicomData.little_endian := 1;

  if gDicomData.monochrome = 1 then
    gScheme := 0
  else
    gScheme := 1;

  LoadColorScheme('', gScheme); // load Black and white

  gWinCen := 0;
  gWinWid := 0;

  Lowerslice1.enabled := gDicomData.XYZdim[3] > 1;
  Higherslice1.enabled := gDicomData.XYZdim[3] > 1;
  Mosaic1.enabled := gDicomData.XYZdim[3] > 1;
  if Self.WindowState <> wsMaximized then
  begin
    //Self.ClientHeight := gDicomData.XYZdim[2];
    //Self.ClientWidth := (gDicomData.XYZdim[1]);
  end;
  if (gDicomData.RLERedSz > 0) or (gDicomData.SamplesPerPixel > 1) or
    (gCustomPalette > 0) then
  begin
    gDicomData.WindowCenter := 127;
    gDicomData.WindowWidth := 255;
    gImgMin := 0;
    gImgMax := 255;
    gWinCen := gDicomData.WindowCenter;
    gWinWid := 0; // gDICOMdata.WindowWidth;
    gFastCen := 128;
    gFastSlope := 128;
  end;
  gAbort := false;
  Overlay1.enabled := true;
  gSlice := 0;
  { force a new image to be displayed - so gSlice should be different from displayimage requested slice }
  DisplayImage(true, true, 1, gDicomData.WindowWidth, gDicomData.WindowCenter);
  Screen.Cursor := crDefault;

  TDICOMViewer(Owner).StatusBar.Panels[5].text := 'id:s:a:i ' +
    inttostr(gDicomData.PatientIDInt) + ':' + inttostr(gDicomData.SeriesNum) +
    ':' + inttostr(gDicomData.AcquNum) + ':' + inttostr(gDicomData.ImageNum);

end;

procedure TSeriesGraphicViewer.FileExitItemClick(Sender: TObject);
begin
  TDICOMViewer(Owner).FileExitItemClick(Sender);
end;

procedure TSeriesGraphicViewer.HdrShow;
var
  lLen, lI: integer;
  lStr: string;
begin
//  if not FDICOM then
//    exit;
//
//  Memo1.Lines.Clear;
//  // Memo1.lines.add(inttostr(gDicomData.ImageStart));
//  lLen := length(gDynStr);
//  if lLen > 0 then
//  begin
//    lStr := '';
//    for lI := 1 to lLen do
//    begin
//      if gDynStr[lI] <> kCR then
//        lStr := lStr + gDynStr[lI]
//      else
//      begin
//        Memo1.Lines.Add(lStr);
//        lStr := '';
//      end;
//    end;
//    Memo1.Lines.Add(lStr);
//  end; // lLen > 0
end;

procedure TSeriesGraphicViewer.OptionsImgInfoItemClick(Sender: TObject);
begin
  TDICOMViewer(Owner).btnDICOMHeader.Down := not TDICOMViewer(Owner).btnDICOMHeader.Down;
  TDICOMViewer(Owner).btnDICOMHeader.Click;
end;
(*
  procedure TMDIChild.decompressJPEG24x (lFilename: string; var lOutputBuff: ByteP0; lImageVoxels,lImageStart{gECATposra[lSlice]}: integer);
  var
  Stream: Tmemorystream;
  Jpg: TJPEGImage;

  TmpBmp: TPicture;
  lImage: Timage;
  lRow:  pRGBTripleArray;
  lHt0,lWid0,lInc,i,j: integer;
  begin
  try
  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(lFilename);
  Stream.Seek(lImageStart, soFromBeginning);
  try
  Jpg := TJPEGImage.Create;
  Jpg.LoadFromStream(Stream);
  //lImage.Create(Image);


  Image.Height := JPG.Height;
  Image.Width := JPG.Width;



  //Image.Picture.Graphic:=JPG;
  //Image.Picture.Assign(jpg);
  Image.Picture.Bitmap.Assign(jpg);
  {Image.Picture.Bitmap.Height := JPG.Height;
  Image.Picture.Bitmap.Width := JPG.Width;
  Image.Picture.Bitmap.PixelFormat := pf24bit;
  {}
  //lImageVoxels = (JPG.Height*JPG.Width);
  lWid0 := JPG.Width-1;
  lHt0 := JPG.Height-1;
  lInc := (3*lImageVoxels)-1; //*3 because 24-bit, -1 since index is from 0
  //showmessage(inttostr(lWid0)+'@'+inttostr(lHt0));
  FOR j := lHt0-1 DOWNTO 0 DO BEGIN
  lRow := Image.Picture.Bitmap.ScanLine[j];
  //lRow := TmpImage.Picture.Bitmap.Scanline[j];
  FOR i := lWid0 downto 0 DO BEGIN
  lOutputBuff[lInc] := (lRow[i].rgbtBlue) and 255;//lRow[i].rgbtRed;
  lOutputBuff[lInc-1] := (lRow[i].rgbtGreen) and 255;//lRow[i].rgbtRed;
  lOutputBuff[lInc-2] := (lRow[i].rgbtRed) and 255;//lRow[i].rgbtRed;
  dec(lInc,3);
  END; //for i.. each column
  END; //for j...each row
  {}
  //lImage.Free;
  //TmpBmp.Create;
  //TmpBmp.Graphic := Jpg;
  //TmpBmp.Free;
  finally //try..finally
  Jpg.Free;
  end;
  finally
  Stream.Free;
  end; //try..finally
  end; *)


procedure TSeriesGraphicViewer.DisplayImage(lUpdateCon, lForceDraw: boolean;
  lSlice, lInWinWid, lInWincen: integer);
// Draws an image: can create mosaics (showing multiple slices simultaneously)
var
  DI: TK_HDCMINST;
  InstanceResult: integer;
  PixBuffer : array of uint16;
  k: Integer;
  WUInt2: Word;
  WBuf: WideString;
  sz: Integer;
  IsNil: Integer;
  UseEzDICOM: Boolean;

  lWinCen, lWinWid, Hd: integer;
  lStartTime: DWord;
  lLookup16, lCompressLine16: SmallIntP0;
  lMultiBuff, CptBuff, lBuff, TmpBuff: ByteP0;
  lPtr: pointer;
  lRow: pRGBTripleArray;
  lCptPos, lFullSz, lCompSz, lTmpPos, lTmpSz, lLastPixel: longint;
  lMultiSliceInc: single;
  lTime, lMultiMaxSlice, lMultiFullRowSz, lMultiCol, lMultiRow, lMultiStart,
    lMultiLineSz, lMultiSliceSz, lMultiColSz, lnMultiRow, lMultiSlice,
    lnMultiCol, lnMultiSlice: integer;
  lSmall: word; // smallint;
  l16Signed, l16Signed2: smallint;
  lFileName: string;
  infp: file;
  max16: longint;
  min16: longint;
  lShort: ShortInt;
  lCptVal, lRunVal, lByte2, lByte: byte;
  lLineLen, { lScaleShl10, } lL, j, Size, lScanLineSz, lBufEntries, lLine,
    lImgPos, lLineStart, lLineEnd, lPos, value, lInc, lCol, lXdim,
    lStoreSliceVox, lImageStart, lAllocSLiceSz, lStoreSliceSz, i, I12: integer;
  lY, lCb, lCr, lR, lG, lB: integer;
  hBmp: HBITMAP;
  BI: PBitmapInfo;
  BIH: TBitmapInfoHeader;
  Bmp: TBitmap;
  ImagoDC: hDC;
  PixMap: pointer;
  PPal: PLogPalette;

  SmallestPixelValue, LargestPixelValue: Integer;
  WindowCenter, WindowWidth: Extended;
  PixelRepresentation: Word;
  PixelPaddingValue: Smallint;
  RescaleIntercept, RescaleSlope: Integer;
  y: integer;

  bitmap: TBitmap;

  bmpinfo: tagBITMAPINFO;
begin
{$R-}
  lMultiColSz := 1;
  lMultiLineSz := 1;
  if lUpdateCon then
  begin
    gFastSlope := 128;
    gFastCen := 128;
    UpdatePalette(false, 0);
    if gDicomData.Allocbits_per_pixel > 8 then
    begin
      gFastSlope := 512 { 256 }; { CONTRAST change here }
      gFastCen := 512 { 256 }; { CONTRAST change here }
    end;
  end;
  lFileName := FFileName;
  lWinWid := lInWinWid;
  lWinCen := lInWincen;
  if (lWinWid < 0) { and (gUseRecommendedContrast) } and true and
    (gDicomData.WindowWidth <> 0) then
  begin // autocontrast
    lWinWid := gDicomData.WindowWidth;
    lWinCen := gDicomData.WindowCenter;
  end;
  if (not lUpdateCon) and (gSlice = lSlice) { and (gScheme = lScheme) } and
    (lWinCen = gWinCen) and (lWinWid = gWinWid) then
    exit; { no change: delphi sends two on change commands each time a slider changes: this wastes a lot of display time }
  gImgMin := 0;
  gImgMax := 0;
  if (gDicomData.SamplesPerPixel > 1) or (gDicomData.RLERedSz > 0) then
    gImgMax := 255;
  gImgCen := 0;
  gImgWid := 0;
  gWinMin := gImgMin;
  gWinMax := gImgMax;
  gWinCen := lWinCen;
  gWinWid := lWinWid;
  if (not gImgOK) or (gAbort) then
    exit;
  if lSlice < 1 then
    lSlice := 1;
  g100pctImageWid := gDicomData.XYZdim[1];
  g100pctImageHt := gDicomData.XYZdim[2];

  gSlice := lSlice;

  InstanceResult := K_CMDCMCreateIntance(lFileName, DI);

  ReleaseDICOMmemory;

  gBuff24sz := K_DCMGLibW.DLGetDIBSize(DI);
  GetMem(gBuff24, gBuff24sz);

  WUInt2 := K_DCMGLibW.DLGetWindowsDIB(DI, lInWinWid, lInWincen, @gBuff24[0], gBuff24sz);

  Size := gDicomData.XYZdim[1] * gDicomData.XYZdim[2];

  value := gBuff24[0];
  max16 := value;
  min16 := value;
  i := 0;
  while i < (Size) do
  begin
    value := gBuff24[i];
    if value < min16 then
      min16 := value;
    if value > max16 then
      max16 := value;
    i := i + 1;
  end;
  gImgMin := min16;
  gImgMax := max16;
  gWinMin := min16;
  gWinMax := max16;
  gImgWid := gImgMax - gImgMin;
  gImgCen := gImgMin + ((gImgWid) shr 1);
  if lWinWid < 0 then
  begin // autocontrast
    gWinMin := gImgMin;
    gWinMax := gImgMax;
    gWinWid := gImgWid;
    gWinCen := gImgCen;
  end;

  Image.Width := gDicomData.XYZdim[1];
  Image.Height := gDicomData.XYZdim[2];

  Image.Visible := True;

  bmpinfo.bmiHeader.biSize        := sizeof(bmpinfo);
  bmpinfo.bmiHeader.biWidth       := Image.Width;
  bmpinfo.bmiHeader.biHeight      := -Image.Height;
  bmpinfo.bmiHeader.biPlanes      := 1;
  bmpinfo.bmiHeader.biBitCount    := 24;
  bmpinfo.bmiHeader.biCompression :=BI_RGB;
  bmpinfo.bmiHeader.biSizeImage   := 0;

  StretchDIBits(Image.Canvas.Handle, 0, 0, Image.Width, Image.Height, 0, 0, Image.Width, Image.Height, @gBuff24[0], bmpinfo, DIB_RGB_COLORS, SRCCOPY);
{$P-,S+,W+,R+}
end;

{

procedure ConvertBitmapToGrayscale2(const Bmp: TBitmap);

type
  TRGBArray = array[0..32767] of TRGBTriple;
  PRGBArray = ^TRGBArray;
var
  x, y, Gray: Integer;
  Row: PRGBArray;
begin
  Bmp.PixelFormat := pf24Bit;
  for y := 0 to Bmp.Height - 1 do
  begin
    Row := Bmp.ScanLine[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      Gray           := (Row[x].rgbtRed + Row[x].rgbtGreen + Row[x].rgbtBlue) div 3;
      Row[x].rgbtRed := Gray;
      Row[x].rgbtGreen := Gray;
      Row[x].rgbtBlue := Gray;
    end;
  end;
end;
}


procedure TSeriesGraphicViewer.Lowerslice1Click(Sender: TObject);
var
  lSlice: integer;
begin
  gMultiCol := 1;
  gMultiRow := 1;
  if (Sender as TMenuItem).tag = 1 then
  begin { increment }
    if gSlice >= gDicomData.XYZdim[3] then
      lSlice := 1
    else
      lSlice := gSlice + 1;
  end
  else
  begin
    if gSlice > 1 then
      lSlice := gSlice - 1
    else
      lSlice := gDicomData.XYZdim[3];
  end;
  TDICOMViewer(Owner).trackSliceSlider.Position := lSlice;
  //TDICOMViewer(Owner).SliceSliderChange(nil);
end;

procedure TSeriesGraphicViewer.FormActivate(Sender: TObject);
begin
  TDICOMViewer(Owner).ColUpdate;
  AutoMaximise;
end;

procedure TSeriesGraphicViewer.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
// Respond to user clicking on image: ZOOM, CHANGE CONTRAST, etc depending on tool
var
  lX, lY: integer;
  lSlopeReal: single;
begin
  if (ssShift in Shift) and (ssCtrl in Shift) then
  begin
    gMouseDown := true;

    Image.Canvas.Pen.Mode := pmCopy;
    Image.Canvas.Pen.Color := clwhite;
    if (BackupBitmap = nil) then
    begin
      BackupBitmap := TBitmap.Create;
      BackupBitmap.Assign(Image.Picture.Bitmap);
    end;
    if not gSmooth then
    begin
      lX := (X * 100) div gZoomPct;
      lY := (Y * 100) div gZoomPct;
    end
    else
    begin
      lX := X;
      lY := Y;
    end;
    if (abs(lX - gLine.Right) < 5) and (abs(lY - gLine.Bottom) < 5) then
    begin
      gLine.Right := gLine.Left;
      gLine.Bottom := gLine.Top;
      gLine.Left := -666;
      exit
    end;
    if (abs(lX - gLine.Left) < 5) and (abs(lY - gLine.Top) < 5) then
    begin
      gLine.Left := -666;
      ImageMouseMove(Sender, Shift, X, Y);
      exit
    end;
    gLine.Left := -666;
    gLine.Right := lX;
    gLine.Bottom := lY;
    ImageMouseMove(Sender, Shift, X, Y);
    exit;
  end;
  if (Button = mbLeft) and (ssCtrl { Shift } in Shift) then
  begin
    Screen.Cursor := crDrag;
    gMouseDown := true;
    lX := round((X * Image.Picture.Height) / Image.Height);
    lY := round((Y * Image.Picture.Width) / Image.Width);
    // lX := ((X * 100) div gZoomPct);
    // lY := ((Y * 100) div gZoomPct);
    gSelectOrigin.X := lX;
    gSelectOrigin.Y := lY;
  end
  else if (Button = mbLeft) and (ssAlt in Shift) then
  begin
    Screen.Cursor := crHandPoint;
    GetCursorPos(FLastDown);
    gMouseDown := true;
  end
  else if (Button = mbLeft) and (ssShift in Shift) then
  begin
    if (BackupBitmap = nil) then
    begin
      { if gPalUpdated then begin
        lSlice := gSlice;
        gSlice := 0;  //force redraw
        DisplayImage(false,true,lSlice,gWinWid,gWinCen);
        end; dsa }
      BackupBitmap := TBitmap.Create;
      BackupBitmap.Assign(Image.Picture.Bitmap);
    end;
    FLastDown := Point(-1, -1);
    gMouseDown := true;
    ShowMagnifier(X, Y); { }
  end
  else if (Button = mbLeft) and (FDICOM)
  { and (gCustomPalette = 0) and (gDicomdata.SamplesPerPixel = 1) } then
  begin
    FLastDown := Point(-1, -1);
    if gBuff16sz > 0 then
    begin
      if (gImgMax - gImgMin) > 0 then
        gFastCen := round(((gWinCen - gImgMin) / (gImgMax - gImgMin)) *
          1024 { 512 } )
      else
        gFastCen := 512;
      if gWinWid > 0 then
        lSlopeReal := (gImgMax - gImgMin) / gWinWid
      else
        lSlopeReal := 666;
      gFastSlope := round((arctan(lSlopeReal) / kRadCon) / 0.0878);

    end
    else
    begin
      gFastCen := gWinCen;
      if gWinWid > 0 then
        lSlopeReal := 255 / gWinWid
      else
        lSlopeReal := 45;
      gFastSlope := round((arctan(lSlopeReal) / kRadCon) / 0.352059);
    end;

    gXStart := X;
    gYStart := Y;
    gStartSlope := gFastSlope;
    gStartCen := gFastCen;
    gMouseDown := true;
  end;
end;

procedure TSeriesGraphicViewer.UpdatePalette(lApply: boolean; lWid0ForSlope: integer);
// Refresh Contrast/Brightness
var
  lMin, lMax: integer;
  lSlopeReal: single;
begin
  if (gDicomData.Allocbits_per_pixel > 8) and (gBuff24sz = 0) { 16-BITPALETTE }
  then
  begin
    if not lApply then
      Exit;

    RefreshZoom;
    Exit;
  end;
  if lWid0ForSlope = 0 then
  begin
    lSlopeReal := gFastSlope * 0.352059;
    lSlopeReal := sin(lSlopeReal * kRadCon) / cos(lSlopeReal * kRadCon);
    if lSlopeReal <> 0 then
    begin
      lMax := round(128 / lSlopeReal);
      lMin := gFastCen - lMax;
      lMax := gFastCen + lMax;
    end
    else
    begin
      lMin := 0;
      lMax := 0;
    end;
  end
  else
  begin // lWid0ForSlope
    lMin := gFastCen - (lWid0ForSlope shr 1);
    lMax := lMin + lWid0ForSlope;
    lSlopeReal := 255 / lWid0ForSlope;
    gFastSlope := round((arctan(lSlopeReal) / kRadCon) / 0.352059);
  end;
  if (gDicomData.Allocbits_per_pixel < 9) or (gDicomData.RLERedSz > 0) then
  begin
    gWinCen := (gFastCen);
    if ((lMax - lMin) > maxint) or ((lMin = 0) and (lMax = 0)) then
    begin
      gContrastStr := Format('Window Cen/Wid: %d/inf', [gFastCen]);
      gWinWid := maxint;
    end
    else
    begin
      gContrastStr := Format('Window Cen/Wid: %d/%d', [gFastCen, (lMax - lMin)]);
      gWinWid := (lMax - lMin);
    end;
  end;
  if gBuff8sz > 0 then
  begin
    SetDimension(g100pctImageHt, g100pctImageWid, 8, gBuff8, true);
    DICOMImageRefreshAndSize;
  end
  else if gBuff24sz > 0 then
  begin
    // fargo
    SetDimension(g100pctImageHt, g100pctImageWid, 24, gBuff24, true);
    DICOMImageRefreshAndSize;
  end;
end;

procedure TSeriesGraphicViewer.ImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
// Respond to user moving image: typically show image intensity under the mouse
var
  lMsgStr: string;
  lLineWidmm, lLineHtmm, lLineLenMM: double;
  lTextL, lTextT, lTextWid, lTextHt, lLineWid, lLineHt, lX, lY, lWid: integer;
  lSlopeReal: single;
  pt: TPoint;

  NewWinWid, NewWinCen: integer;
begin
  if not gMouseDown then
  begin
    lX := ((X * 100) div gZoomPct);
    lY := ((Y * 100) div gZoomPct);
    Vxl(lX, lY);
    exit;
  end;
  if (ssShift in Shift) and (ssCtrl in Shift) then
  begin
    if (gMagRect.Left <> gMagRect.Right) then
      Image.Picture.Bitmap.Canvas.CopyRect(gMagRect, BackupBitmap.Canvas, gMagRect);

    if not gSmooth then
    begin
      lX := (X * 100) div gZoomPct;
      lY := (Y * 100) div gZoomPct;
    end
    else
    begin
      lX := X;
      lY := Y;
    end;
    gLine.Left := lX;
    gLine.Top := lY;
    lLineWid := abs(gLine.Left - gLine.Right);
    lLineHt := abs(gLine.Top - gLine.Bottom);
    if gSmooth then
    begin
      lLineWid := ((lLineWid * 100) div gZoomPct);
      lLineHt := ((lLineHt * 100) div gZoomPct);
    end;
    lLineHtmm := lLineHt * gDicomData.XYZmm[2];
    lLineWidmm := lLineWid * gDicomData.XYZmm[1];
    lLineLenMM := sqrt(sqr(lLineWidmm) + sqr(lLineHtmm));
    gLineLenMM := lLineLenMM;
    lMsgStr := floattostrf(lLineLenMM, ffFixed, 8, 2) + 'mm';
    lTextWid := Image.Canvas.TextWidth(lMsgStr);
    lTextHt := Image.Canvas.TextHeight(lMsgStr);
    if gLine.Left < gLine.Right then
      gMagRect.Left := gLine.Left
    else
      gMagRect.Left := gLine.Right;
    if gLine.Top < gLine.Bottom then
      gMagRect.Top := gLine.Top
    else
      gMagRect.Top := gLine.Bottom;
    if (abs(gLine.Left - gLine.Right)) > (lTextWid + 10) then
    begin
      lTextL := gMagRect.Left +
        (((abs(gLine.Left - gLine.Right)) - lTextWid) div 2);
    end
    else
      lTextL := gMagRect.Left;
    if (abs(gLine.Top - gLine.Bottom)) > (lTextHt + 10) then
      lTextT := gMagRect.Top +
        (((abs(gLine.Top - gLine.Bottom)) - lTextHt) div 2)
    else if gMagRect.Top > 14 then
      lTextT := gMagRect.Top - 14
    else
      lTextT := gLine.Bottom + 2;
    if gLine.Left < gLine.Right then
    begin
      gMagRect.Left := gLine.Left - 1;
      gMagRect.Right := gLine.Right + 1 + lTextWid;
    end
    else
    begin
      gMagRect.Left := gLine.Right - 1;
      gMagRect.Right := gLine.Left + 1 + lTextWid;
    end;
    if gLine.Top < gLine.Bottom then
    begin
      gMagRect.Top := gLine.Top - 15;
      gMagRect.Bottom := gLine.Bottom + 15;
    end
    else
    begin
      gMagRect.Top := gLine.Bottom - 14;
      gMagRect.Bottom := gLine.Top + 14;
    end;
    Image.Canvas.MoveTo(gLine.Right, gLine.Bottom);
    Image.Canvas.LineTo(gLine.Left, gLine.Top);
    Image.Canvas.Brush.style := bsClear;
    { if gOverlayColor = 1 then begin
      Image.Canvas.Font.Color := 0;
      Image.Canvas.Brush.Color := clWhite;
      end else begin
      abba } Image.Canvas.Font.Color := $FFFFFF;
    Image.Canvas.Brush.Color := clBlack;
    // end;
    Image.Canvas.TextOut(lTextL, lTextT, lMsgStr);
    exit;
  end;
  if (ssCtrl in Shift) then
  begin
    Image.Canvas.DrawFocusRect(gSelectRect);
    lX := round((X * Image.Picture.Height) / Image.Height);
    lY := round((Y * Image.Picture.Width) / Image.Width);
    if gSelectOrigin.X < 1 then
    begin
      gSelectOrigin.X := lX;
      gSelectOrigin.Y := lY;
    end;
    if lX < gSelectOrigin.X then
    begin
      gSelectRect.Right := gSelectOrigin.X;
      gSelectRect.Left := lX;
    end
    else
    begin
      gSelectRect.Right := lX;
      gSelectRect.Left := gSelectOrigin.X;
    end;
    if lY < gSelectOrigin.Y then
    begin
      gSelectRect.Bottom := gSelectOrigin.Y;
      gSelectRect.Top := lY;
    end
    else
    begin
      gSelectRect.Bottom := (lY);
      gSelectRect.Top := gSelectOrigin.Y
    end;
    Image.Canvas.DrawFocusRect(gSelectRect);
  end
  else if { (ssLeft In Shift) gMouseDown and } (FLastDown.X >= 0) then
  begin
    GetCursorPos(pt);
    ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position +
      FLastDown.Y - pt.Y;
    ScrollBox1.HorzScrollBar.Position := ScrollBox1.HorzScrollBar.Position +
      FLastDown.X - pt.X;
    FLastDown := pt;
  end
  else if (BackupBitmap <> nil) then
  begin
    ShowMagnifier(X, Y);
  end
  else if gBuff24sz > 0 then
  begin

    lX := X - gXStart;
    lY := Y - gYStart;
    gXStart := X;
    gYStart := Y;

    NewWinCen := lX + TDICOMViewer(Owner).seWinCenEdit.value;
    NewWinWid := lY + TDICOMViewer(Owner).seWinWidEdit.value;

//    if ((lX + gStartSlope) > 1024) then
//      gFastSlope := 1024
//    else if ((lX + gStartSlope) < 1) then
//      gFastSlope := 1
//    else
//      gFastSlope := lX + gStartSlope;
//    lSlopeReal := gFastSlope * 0.0878 { 0.175781 {CONTRAST change here };
//    lWid := trunc((gImgMax - gImgMin) / (sin(lSlopeReal * kRadCon) /
//      cos(lSlopeReal * kRadCon)));
//    lY := Y - gYStart;
//    if ((gStartCen + lY) > 1024) then
//      gFastCen := 1024
//    else if ((lY + gStartCen) < 0) then
//      gFastCen := 0
//    else
//      gFastCen := gStartCen + lY; { }
//    lY := round(((gFastCen / 1024) * (gImgMax - gImgMin)) + gImgMin);
    { CONTRAST change here: /n where n is amount of mouse movement }
    if NewWinCen > 0 then
      TDICOMViewer(Owner).seWinCenEdit.value := NewWinCen;
    if NewWinWid > 0 then
      TDICOMViewer(Owner).seWinWidEdit.value := NewWinWid;
//    if lWid >= 0 then
//      TDICOMViewer(Owner).seWinWidEdit.value := lWid;
//    if lY >= 0 then
//      TDICOMViewer(Owner).seWinCenEdit.value := lY;

    DisplayImage(True, True, gSlice, TDICOMViewer(Owner).seWinWidEdit.value, TDICOMViewer(Owner).seWinCenEdit.value);
    RefreshZoom;
  end
  else
  begin
    lX := X - gXStart;
    if ((lX + gStartSlope) > 255) then
      gFastSlope := 255
    else if ((lX + gStartSlope) < 0) then
      gFastSlope := 0
    else
      gFastSlope := lX + gStartSlope;
    lY := Y - gYStart;
    if ((gStartCen + lY) > 255) then
      gFastCen := 255
    else if ((lY + gStartCen) < 0) then
      gFastCen := 0
    else
      gFastCen := gStartCen + lY;
    UpdatePalette(true, 0);
    TDICOMViewer(Owner).StatusBar.Panels[4].text := gContrastStr;
  end;
end;

procedure TSeriesGraphicViewer.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
// Respond to user releasing mouse: Response depends on tool.
// For area contrast tool, the image intensity in the selected rectangle is evaluated, and the contrast adjust accordingly
  procedure MinMaxRect(var lIn: integer; lMaxPlus1: integer);
  begin
    if lIn < 0 then
      lIn := 0;
    if lIn >= lMaxPlus1 then
      lIn := lMaxPlus1 - 1;
  end;

var
  lWinWid, lWinCen, lVal, lMin, lMax, lCol, lRow: integer;
begin
  FLastDown := Point(-1, -1);
  Screen.Cursor := crDefault;
  if (gSelectRect.Left <> gSelectRect.Right) and
    (gSelectRect.Top <> gSelectRect.Bottom) then
  begin
    Image.Canvas.DrawFocusRect(gSelectRect);
    if gSmooth then
    begin
      gSelectRect.Left := ((gSelectRect.Left * 100) div gZoomPct);
      gSelectRect.Top := ((gSelectRect.Top * 100) div gZoomPct);
      gSelectRect.Right := ((gSelectRect.Right * 100) div gZoomPct);
      gSelectRect.Bottom := ((gSelectRect.Bottom * 100) div gZoomPct);
    end;
    MinMaxRect(gSelectRect.Left, g100pctImageWid);
    MinMaxRect(gSelectRect.Top, g100pctImageHt);
    MinMaxRect(gSelectRect.Right, g100pctImageWid);
    MinMaxRect(gSelectRect.Bottom, g100pctImageHt);
    lMin := VxlVal((gSelectRect.Left), ((gSelectRect.Top)), true);
    lMax := lMin;
    for lCol := gSelectRect.Left to gSelectRect.Right do
    begin
      for lRow := gSelectRect.Top to gSelectRect.Bottom do
      begin
        lVal := VxlVal(lCol, lRow, true);
        if lVal < lMin then
          lMin := lVal;
        if lVal > lMax then
          lMax := lVal;
      end; // row
    end; // column
    gSelectRect := Rect(0, 0, 0, 0);
    gSelectOrigin.X := -1;
    lWinWid := lMax - lMin; // max now = windowwid
    lWinCen := lMin + (lWinWid shr 1);
    gWinWid := lWinWid;
    gWinCen := lWinCen;
    gFastCen := lWinCen;
    if gBuff16sz > 0 then
    begin
      RefreshZoom;
    end
    else
    begin
      if lWinWid = 0 then
        lWinWid := 1;
      UpdatePalette(true, lWinWid);
    end;
  end
  else if (BackupBitmap <> nil) then
  begin // magnifier was on
    Image.Picture.Graphic := BackupBitmap; // Restore base image
    BackupBitmap.free;
    BackupBitmap := nil;
    Image.refresh;
  end
  else if (gMouseDown) and (gBuff24sz > 0) then
  begin
    TDICOMViewer(Owner).seWinCenEdit.value := gWinCen;
    TDICOMViewer(Owner).seWinWidEdit.value := gWinWid;

  end;
  gMouseDown := false;
end;

function TSeriesGraphicViewer.IsViewerActive: Boolean;
begin
  Result := ((Self.Owner as TDICOMViewer).pnlSerieViewerHolder = Self.Parent);
end;

procedure TSeriesGraphicViewer.SelectZoom1Click(Sender: TObject);
begin
  if TDICOMViewer(Owner).trackZoomSlider.enabled then
    TDICOMViewer(Owner).trackZoomSlider.SetFocus
//  else if TDICOMViewer(Owner).SchemeDrop.enabled then
//    TDICOMViewer(Owner).SchemeDrop.SetFocus;
end;

procedure TSeriesGraphicViewer.btn1Click(Sender: TObject);
begin
  inherited;
  ShowMessage(gDynStr);
end;

procedure TSeriesGraphicViewer.ContrastAutobalance1Click(Sender: TObject);
begin
  TDICOMViewer(Owner).btnAutoBal.Click;
end;

procedure TSeriesGraphicViewer.FormResize(Sender: TObject);
begin
  // if (TDICOMViewer(Owner).BestFitItem.checked) {and (not gZoomSlider)} then
  PositionImage;
  AutoMaximise;
end;

procedure TSeriesGraphicViewer.CopyItemClick(Sender: TObject);
var
  MyFormat: word;
  AData: THandle;
  APalette: HPalette;
begin
//  ///if (Memo1.Visible) and (gDynStr <> '') then
//  begin
//    ClipBoard.AsText := gDynStr;
//    exit;
//  end;
  if (Self.Image.Picture.Bitmap = nil) or
    (Self.Image.Picture.Width < 1) or
    (Self.Image.Picture.Height < 1) then
    exit;

  Self.Image.Picture.Bitmap.SaveToClipBoardFormat
    (MyFormat, AData, APalette);
  ClipBoard.SetAsHandle(MyFormat, AData);
end;

procedure TSeriesGraphicViewer.Timer1Timer(Sender: TObject);
var
  lSlice: integer;
begin
  if gDicomData.XYZdim[3] > 1 then
  begin
    lSlice := gSlice;

    if gSlice >= gDicomData.XYZdim[3] then
      lSlice := 1
    else
      Inc(lSlice);

    DisplayImage(false, false, lSlice, gWinWid, gWinCen);
    (Owner as TDICOMViewer).trackSliceSlider.Position := gSlice;

  end
  else
  if (gFileListSz > 0) then
  begin
    if (gCurrentPosInFileList = gFileListSz) then
      gCurrentPosInFileList := 0
    else
      Inc(gCurrentPosInFileList);

    (Owner as TDICOMViewer).trackSliceSlider.Position := gCurrentPosInFileList;

    {if gCurrentPosInFileList = (gFileListSz-1) then
      gCurrentPosInFileList := 0
    else
      Inc(gCurrentPosInFileList);

    LoadData(gFilePath + gStringList.Strings[gCurrentPosInFileList], false, false, false, false);
    AutoMaximise;
    TDICOMViewer(Owner).ColUpdate;}
  end
  else
  begin
    Timer1.enabled := false;

    gVideoSpeed := 0;
    (Owner as TDICOMViewer).btnVideo.Caption := '0';
  end;
end;

procedure TSeriesGraphicViewer.PositionImage;
begin
  if Self.Image.Width <= Self.ScrollBox1.Width then
  begin
    if Self.ScrollBox1.HorzScrollBar.Visible then
      Self.ScrollBox1.HorzScrollBar.Position := 0;

    Self.Image.Left := (Self.ScrollBox1.Width div 2) - (Self.Image.Width div 2);
  end
  else
  begin
    //Self.HorzScrollBar.Position := 0;
    Self.Image.Left := 0;
    Self.ScrollBox1.Refresh;
  end;

  if Self.Image.Height < Self.ScrollBox1.Height then
  begin
    if Self.ScrollBox1.VertScrollBar.Visible then
      Self.ScrollBox1.VertScrollBar.Position := 0;

    Self.Image.Top := (Self.ScrollBox1.Height div 2) - (Self.Image.Height div 2);
  end
  else
  begin
    //Self.ScrollBox1.VertScrollBar.Position := 0;
    Self.Image.Top := 0;
    Self.ScrollBox1.Refresh;
  end;
end;

procedure TSeriesGraphicViewer.Previous1Click(Sender: TObject);
begin
  gMultiCol := 1;
  gMultiRow := 1;

  with Self do
  begin
    if (Sender as TMenuItem).tag = 1 then
    begin // increment
      gCurrentPosInFileList := gCurrentPosInFileList + 1;
    end
    else
      gCurrentPosInFileList := gCurrentPosInFileList - 1;

    if (gCurrentPosInFileList >= gFileListSz) then
      gCurrentPosInFileList := 0;
    if (gCurrentPosInFileList < 0) then
      gCurrentPosInFileList := gFileListSz - 1;

    LoadData(gFilePath + gStringList.Strings[gCurrentPosInFileList], false,
             false, false, false);

    TDICOMViewer(Owner).ColUpdate;
    AutoMaximise;
  end;
end;

procedure TSeriesGraphicViewer.N1x11Click(Sender: TObject);
// Draw a mosaic image, with several slices
var
  lSize: integer;
begin
  lSize := (Sender as TMenuItem).tag;
  Timer1.enabled := false;
  gVideoSpeed := 0;
  TDICOMViewer(Owner).btnVideo.Caption := '0';
  if lSize < 5 then
  begin
    gMultiCol := lSize;
    gMultiRow := lSize;
    gMultiFirst := 1;
    gMultiLast := gDicomData.XYZdim[3];
    lSize := gSlice;
    gSlice := 0; // force redraw
    DisplayImage(false, false, lSize, gWinWid, gWinCen);
    AutoMaximise;
  end;
//  else
//  begin
//    MultiSliceForm.gMaxMultiSlices := gDicomData.XYZdim[3];
//    MultiSliceForm.ShowModal;
//    gMultiCol := MultiSliceForm.ColEdit.value;
//    gMultiRow := MultiSliceForm.RowEdit.value;
//    gMultiFirst := MultiSliceForm.FirstEdit.value;
//    gMultiLast := MultiSliceForm.LastEdit.value;
//    lSize := gSlice;
//    gSlice := 0; // force redraw
//    DisplayImage(false, false, lSize, gWinWid, gWinCen);
//    AutoMaximise;
//  end;
end;

procedure TSeriesGraphicViewer.Smooth1Click(Sender: TObject);
begin
  Smooth1.checked := not Smooth1.checked;
  gSmooth := Smooth1.checked;
  RefreshZoom;
end;

procedure TSeriesGraphicViewer.None1Click(Sender: TObject);
begin
  (Sender as TMenuItem).checked := true;
  RefreshZoom;
end;

procedure TSeriesGraphicViewer.ContrastSuggested1Click(Sender: TObject);
begin
  if TDICOMViewer(Owner).btnContrast.enabled then
    TDICOMViewer(Owner).btnContrast.Click;
end;

procedure TSeriesGraphicViewer.CTpreset(Sender: TObject);
begin
  TDICOMViewer(Owner).ContrastPreset((Sender as TMenuItem).tag);
end;


end.
