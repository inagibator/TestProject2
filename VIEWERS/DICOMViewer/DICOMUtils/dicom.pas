unit dicom;

{$R-}{$T-}

interface

uses
  SysUtils, Dialogs, Controls, define_types, classes,
  K_CMDCMGLibW, K_CMDCM, N_Lib0, Graphics, N_Types;

{$H+}

procedure clear_dicom_data(var lDICOMdata: TDICOMdata);

function ReadDicomData(AFileName: string; var ADICOMdata: TDICOMdata): Boolean;
function ReadDicomTag(AFileName: string; ATag: integer; var AValue: string): boolean;

function DICOMDateToDate(ADICOMDate: string): string;
function DICOMTimeToTime(ADICOMTime: string): string;

implementation

function DICOMDateToDate(ADICOMDate: string): string;
var
  DateValue: Integer;
begin
  if ADICOMDate.IsEmpty then
    Exit;

  ADICOMDate := ADICOMDate.Replace('-', '');

  Result := ADICOMDate.Substring(6, 2);
  DateValue := ADICOMDate.Substring(4, 2).ToInteger;
  Result := Result + '-' + FormatSettings.ShortMonthNames[DateValue].ToUpper;
  Result := Result + '-' + ADICOMDate.Substring(0, 4);
end;

function DICOMTimeToTime(ADICOMTime: string): string;
begin
  if ADICOMTime.IsEmpty then
    Exit;

  Result := ADICOMTime.Substring(0, 2) + ':' + ADICOMTime.Substring(2, 2)  + ':' + ADICOMTime.Substring(4, 2);
end;

function ReadDicomData(AFileName: string; var ADICOMdata: TDICOMdata): Boolean;
var
  DI: TK_HDCMINST;
  InstanceResult: integer;

  WUInt2: Word;
  WBuf: WideString;
  sz: integer;
  IsNil: integer;

  tmpstr: string;

  IPixFmt: TPixelFormat;
  IExPixFmt: TN_ExPixFmt;
  INumBits, Width, Height: TN_UInt2;
  DIBAtrsRes: integer;

  FloatValue: Extended;
const
  BufLeng = 1024;
begin
  if not Assigned(ADICOMData) then
    ADICOMdata :=  TDICOMData.Create
  else
    clear_dicom_data(ADICOMdata);

  Result := True;

  InstanceResult := K_CMDCMCreateIntance(AFileName, DI);

  if InstanceResult <> 0 then
  begin
    Result := False;
    Exit;
  end;

  ADICOMdata.FileName := AFileName;

  with K_DCMGLibW do
  begin
    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.SerieUID := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTStudyInstanceUid, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.StudyUID := N_WideToString(Copy(WBuf, 1, sz));

    if ADICOMdata.StudyUID.IsEmpty then
      ADICOMdata.StudyUID := 'ANONYMIZED';

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTStudyId, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.StudyID := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTInstitutionName, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.InstitutionName := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTReferringPhysiciansName, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PhysicianName := N_WideToString(Copy(WBuf, 1, sz)).Replace('^', ' ', [rfReplaceAll]);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSeriesDescription, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.SeriesDescription := N_WideToString(Copy(WBuf, 1, sz)).Replace('^', ' ', [rfReplaceAll]);

    if ADICOMdata.SeriesDescription.IsEmpty then
      ADICOMdata.SeriesDescription := 'NO DESCRIPTION';

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTStudyDescription, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.StudyDescription := N_WideToString(Copy(WBuf, 1, sz)).Replace('^', ' ', [rfReplaceAll]);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTModality, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.modality := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTStudyDate, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.StudyDate := StringReplace(N_WideToString(Copy(WBuf, 1, sz)), '-', '', [rfReplaceAll]);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTStudyTime, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.StudyTime := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPatientId, @WBuf[1], @sz, @IsNil) = 0 then
    begin
      ADICOMdata.PatientID := N_WideToString(Copy(WBuf, 1, sz));
      ADICOMdata.PatientIDint := StrToIntDef(Trim(ADICOMdata.PatientID), 0);
    end;

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPatientsName, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PatientName := N_WideToString(Copy(WBuf, 1, sz)).Replace('^', ' ', [rfReplaceAll]);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPatientsBirthDate, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PatientBirthDate := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPatientsSex, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PatientSex := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPatientsAge, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PatientAge := N_WideToString(Copy(WBuf, 1, sz));

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTContentTime, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.ImgTime := N_WideToString(Copy(WBuf, 1, sz)).Replace('.', ':');

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTAcquisitionTime, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.AcqTime := N_WideToString(Copy(WBuf, 1, sz)).Replace('.', ':');

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    DLGetValueUint16(DI, K_CMDCMTLargestImagePixelValue, @ADICOMdata.MaxIntensity, @isNil ); //= 0 then
       //:= StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    ADICOMdata.MinIntensitySet := (DLGetValueUint16(DI, K_CMDCMTSmallestImagePixelValue, @ADICOMdata.MinIntensity, @IsNil) = 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTWindowWidth, @WBuf[1], @sz, @IsNil) = 0 then
    begin
      if Pos('\', N_WideToString(Copy(WBuf, 1, sz))) > 0 then
        tmpstr := N_WideToString(Copy(WBuf, 1, sz)).Substring(0, N_WideToString(Copy(WBuf, 1, sz)).IndexOf('\'))
      else
        tmpstr := N_WideToString(Copy(WBuf, 1, sz));

      if tmpstr.ToUpper.IndexOf('E') > 0 then
      begin
        FloatValue := StrToFloat(tmpstr);
        tmpStr := FloatValue.ToString;
      end;

      ADICOMdata.WindowWidth := StrToIntDef(tmpstr, 0);
    end;

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTWindowCenter, @WBuf[1], @sz, @IsNil) = 0 then
    begin
      if Pos('\', N_WideToString(Copy(WBuf, 1, sz))) > 0 then
        tmpstr := N_WideToString(Copy(WBuf, 1, sz)).Substring(0, N_WideToString(Copy(WBuf, 1, sz)).IndexOf('\'))
      else
        tmpstr := N_WideToString(Copy(WBuf, 1, sz));

      if tmpstr.ToUpper.IndexOf('E') > 0 then
      begin
        FloatValue := StrToFloat(tmpstr);
        tmpStr := FloatValue.ToString;
      end;

      ADICOMdata.WindowCenter := StrToIntDef(tmpstr, 0);
    end;

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTBitsStored, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.Storedbits_per_pixel := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTBitsAllocated, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.Allocbits_per_pixel := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSeriesNumber, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.SeriesNum := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTAcquisitionNumber, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.AcquNum := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTInstanceNumber, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.ImageNum := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPhotometricInterpretation, @WBuf[1], @sz, @IsNil) = 0 then
    begin
      tmpstr := N_WideToString(Copy(WBuf, 1, sz));

      if tmpstr = 'MONOCHROME1' then
        ADICOMdata.monochrome := 1
      else if tmpstr = 'MONOCHROME2' then
        ADICOMdata.monochrome := 2
      else if (length(tmpstr) > 0) and (tmpstr[1] = 'Y') then
        ADICOMdata.monochrome := 4
      else
        ADICOMdata.monochrome := 3;
    end;

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSamplesPerPixel, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.SamplesPerPixel := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTPlanarConfiguration, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.PlanarConfig := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTRescaleSlope, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.IntenScale := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTRescaleIntercept, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.IntenIntercept := StrTointDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTKvp, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.kV := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTXRayTubeCurrent, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.mA := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTRepetitionTime, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.TR := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTEchoTime, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.TE := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSpacingBetweenSlices, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.spacing := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSliceLocation, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.location := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    DIBAtrsRes := K_CMDGetDIBAttrs(DI, ADICOMdata.ImageSz, Width, Height,
                                   IPixFmt, IExPixFmt, INumBits);

    if DIBAtrsRes = 0 then
    begin
      ADICOMdata.XYZdim[1] := Width;
      ADICOMdata.XYZdim[2] := Height;
    end;
//    if DLGetValueString(DI, K_CMDCMTRows, @WBuf[1], @sz, @IsNil) = 0 then
//      ADICOMdata.XYZdim[2] := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);
//
//    SetLength(WBuf, BufLeng);
//    sz := BufLeng;
//
//    if DLGetValueString(DI, K_CMDCMTColumns, @WBuf[1], @sz, @IsNil) = 0 then
//       := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTNumberOfFrames, @WBuf[1], @sz, @IsNil) = 0 then
      ADICOMdata.XYZdim[3] := StrToIntDef(N_WideToString(Copy(WBuf, 1, sz)), 0);

    DLDeleteDcmObject(DI)
  end;
end;

function ReadDicomTag(AFileName: string; ATag: integer; var AValue: string): boolean;
var
  DI: TK_HDCMINST;
  InstanceResult: integer;

  WUInt2: Word;
  WBuf: WideString;
  sz: integer;
  IsNil: integer;
const
  BufLeng = 1024;
begin
  Result := false;

  InstanceResult := K_CMDCMCreateIntance(AFileName, DI);

  if InstanceResult <> 0 then
    Exit;

  with K_DCMGLibW do
  begin
    SetLength(WBuf, BufLeng);
    sz := BufLeng;

    if DLGetValueString(DI, K_CMDCMTSeriesInstanceUid, @WBuf[1], @sz, @IsNil) = 0
    then
    begin
      AValue := N_WideToString(Copy(WBuf, 1, sz));
      Result := True;
    end;

    DLDeleteDcmObject(DI)
  end;
end;

procedure clear_dicom_data(var lDICOMdata: TDICOMdata);
begin
  if not Assigned(lDICOMData) then
    Exit;

  with lDICOMdata do
  begin
    PatientIDInt := 0;
    PatientName := 'NO NAME';
    PatientID := 'NO ID';
    StudyDate := '';
    AcqTime := '';
    ImgTime := '';
    TR := 0;
    TE := 0;
    kV := 0;
    mA := 0;
    Rotate180deg := false;
    MaxIntensity := 0;
    MinIntensity := 0;
    MinIntensitySet := false;
    ElscintCompress := false;
    Float := false;
    ImageNum := 0;
    SiemensInterleaved := 2; // 0=no,1=yes,2=undefined
    SiemensSlices := 0;
    SiemensMosaicX := 1;
    SiemensMosaicY := 1;
    IntenScale := 1;
    intenIntercept := 0;
    SeriesNum := 1;
    AcquNum := 0;
    ImageNum := 1;
    Accession := 1;
    PlanarConfig := 0; // only used in RGB values
    runlengthencoding := false;
    CompressSz := 0;
    CompressOffset := 0;
    SamplesPerPixel := 1;
    WindowCenter := 0;
    WindowWidth := 0;
    monochrome := 2; { most common }
    XYZmm[1] := 1;
    XYZmm[2] := 1;
    XYZmm[3] := 1;
    XYZdim[1] := 1;
    XYZdim[2] := 1;
    XYZdim[3] := 1;
    XYZdim[4] := 1;
    lDICOMdata.XYZori[1] := 0;
    lDICOMdata.XYZori[2] := 0;
    lDICOMdata.XYZori[3] := 0;
    imagestart := 0;
    little_endian := 0;
    Allocbits_per_pixel := 16; // bits
    Storedbits_per_pixel := Allocbits_per_pixel;
    GenesisCpt := false;
    JPEGlosslesscpt := false;
    JPEGlossycpt := false;
    GenesisPackHdr := 0;
    StudyDatePos := 0;
    NamePos := 0;
    RLEredOffset := 0;
    RLEgreenOffset := 0;
    RLEblueOffset := 0;
    RLEredSz := 0;
    RLEgreenSz := 0;
    RLEblueSz := 0;
    Spacing := 0;
    Location := 0;
    // Frames:=1;
    Modality := 'MR';
    serietag := '';
  end;
end;

end.
