unit N_Gra6;
// Pixel Matrixes Convertions Types and Procedures

interface
uses // should not use any own units except N_Types
     Windows, Classes, Types,
     N_Types;

// FlipRotate Flags illustrations:
//
// Positive directions are from left to right and from bottom to top
//   ((0,0) is lower left corner, as in BMP raster)
//
//  0(000)    1(001)     2(010)    3(011)  FlipRotate Flags: decimal(binary)
//
//     *        *        *****     *****
//    **        **         *         *
//     *        *          *         *
//     *        *          *         *
//     *        *         **         **
//   *****    *****        *         *
//
//
//   7(111)    6(110)    5(101)    4(100)  FlipRotate Flags: decimal(binary)
//
//        *    *              *     *
//    *   *    *   *          *     *
//   ******    ******    ******     ******
//        *    *          *   *     *   *
//        *    *              *     *

const
 N_FlipHorBit:   integer = $1; // bit0 - Flip relative to Vertical Axis (reverse resulting Horizontal rows) (after diagonal Flip)
 N_FlipVertBit:  integer = $2; // bit1 - Flip relative to Horizontal Axis (reverse resulting Vertical columns) (after diagonal Flip)
 N_FlipDiagBit:  integer = $4; // bit2 - Flip relative to (0,0)-(1,1) diagonal (Horizontal Rows become Vertical and vica verse)
                               //        (diagonal flip should occure before Hor and Vert Flips)

// N_Rotate90Flags Array is used for rotation by 90 degree CCW convertion:
// if some Matr is described by CurFlags, than rotated by 90 degree CCW
// Matrix will be described by NewFlags := N_Rotate90Flags[CurFlags]
var N_Rotate90Flags: Array [0..7] of integer = ( 5, 7, 4, 6, 1, 3, 0, 2 );

// N_BackwardFlags Array is used for Backward convertion:
// if some Matr is described by CurFlags, than to convert initial state (zero flags)
// Matrix should be converted by N_BackwardFlags[CurFlags]
var N_BackwardFlags: Array [0..7] of integer = ( 0, 1, 2, 3, 4, 6, 5, 7 ); // (6 and 5 are flipped!)

type TN_SMDSElemType = ( // Matrix Sub Element Type
  setInteger, // Sub Element (Byte or Word or DWord) is Integer
  setInt64,   // Sub Element 6 or 8 RGB16 Color
  setFloat,   // Sub Element is Float
  setDouble   // Sub Element is Double
    );

type TN_SMatrDescr = record // SubMatrix Description
  SMDNumX:   integer; // Number of Elements in one Row
  SMDNumY:   integer; // Number of Elements in one Column
  SMDElSize: integer; // Matrix Element Size in Bytes (from 1 to 4 or 8)
  SMDStepX:  integer; // Step in Bytes Along X Axis (between Columns or neighboure elems in Row)
  SMDStepY:  integer; // Step in Bytes Along Y Axis (between Rows or neighboure elems in Column)
  SMDBegIX:  integer; // Initial Submatr index along X Axis
  SMDEndIX:  integer; // Final Submatr index along X Axis
  SMDBegIY:  integer; // Initial Submatr index along Y Axis
  SMDEndIY:  integer; // Final Submatr index along Y Axis
  SMDPBeg: TN_BytesPtr; // Pointer to Beg of Matrix (to Matrix initial element)
  SMDNumBits: integer; // Number of used bits for two bytes elems (in (9..16) range), =8 for one byte elems
  SMDSElemType: TN_SMDSElemType; // Matrix Sub Element Type
end; // type TN_SMatrDescr = record
type TN_PSMatrDescr = ^TN_SMatrDescr;

type TN_ConvSMVars = record // Working Variables needed for SubMatrix Convertion (for 1,2 or 3 SubMatrs)
  WNX:        integer; // X all SubMatr dimension
  WNY:        integer; // Y all SubMatr dimension
  WSrcStepX:  integer; // Signed Src SubMatr Step between elements inside Row (between Columns)
  WSrcStepY:  integer; // Signed Src SubMatr Step between elements inside Column (between Rows)
  WDstStepX:  integer; // Signed Dst SubMatr Step between elements inside Row (between Columns)
  WDstStepY:  integer; // Signed Dst SubMatr Step between elements inside Column (between Rows)
  WPSrcBegX:  TN_BytesPtr; // Pointer to Beg (initial) Src SubMatr Element
  WPDstBegX:  TN_BytesPtr; // Pointer to Beg (initial) Dst SubMatr Element
  WSrc2StepX: integer; // Signed Src2 SubMatr Step between elements inside Row (between Columns)
  WSrc2StepY: integer; // Signed Src2 SubMatr Step between elements inside Column (between Rows)
  WPSrc2BegX: TN_BytesPtr;   // Pointer to Beg (initial) Src2 SubMatr Element
  WSrc3StepX: integer; // Signed Src3 SubMatr Step between elements inside Row (between Columns)
  WSrc3StepY: integer; // Signed Src3 SubMatr Step between elements inside Column (between Rows)
  WPSrc3BegX: TN_BytesPtr;   // Pointer to Beg (initial) Src3 SubMatr Element
end; // type TN_ConvSMVars = record
type TN_PConvSMVars = ^TN_ConvSMVars;

type TN_PixOperationsObj = class( TObject ) // Pixels Operations (Params and Procedures of Object)
  PO_IntOperand: integer; // Operand for XOR Operation
  PO_MinInt:   integer; // Min Integer value
  PO_MaxInt:   integer; // Max Integer value
  PO_MaxAllowedRGBDif: double; // Max Allowed difference between R,G,B values of all Pixels
  PO_RealMaxRGBDif:    double; // Calculated Max difference between R,G,B values
  PO_RGBDifCoefs: Array [0..3] of double;
  PO_SetElemMode:   integer; // Mode used in PO_SetElem, see in PO_SetElem code
  PO_SetElemPValue: Pointer; // Pointer to Value to set in PO_SetElem, see in PO_SetElem code

  procedure PO_XOROneByte    ( APElem: Pointer ); overload;
  procedure PO_XORTwoBytes   ( APElem: Pointer );
  procedure PO_XORThreeBytes ( APElem: Pointer );
  procedure PO_XORFourBytes  ( APElem: Pointer );
  function  PO_RGBDifference ( APElem: Pointer ): boolean;
  procedure PO_XOROneByte    ( APSrc, APDst: Pointer ); overload;
  procedure PO_SHLTwoBytes   ( APElem: Pointer );
  procedure PO_SHRTwoBytes   ( APElem: Pointer );
  procedure PO_CalcMaxWord   ( APElem: Pointer );
  procedure PO_SetElem       ( APElem: Pointer );
  procedure PO_AddTwoBytes   ( APElem: Pointer );
end; // type TN_PixOperationsObj = class( TObject )


//******************** Global Procedures and Functions ***********************

function  N_RotateFRFlags    ( ASrcFRFlags: integer; AAngle: float ): integer;
function  N_FlipRotateCoords ( AXYCoords: TPoint; AFRFlags: integer; ARect: TRect ): TPoint;
procedure N_PrepIntArraySMD  ( APFirstInt: PInteger; ANumInts: integer; APSMatr: TN_PSMatrDescr );

procedure N_Prep1SMWVars ( APSMatr: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
procedure N_Prep2SMWVars ( APSrcSM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
procedure N_Prep3SMWVars ( APSrc1SM, APSrc2SM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
procedure N_Prep4SMWVars ( APSrc1SM, APSrc2SM, APSrc3SM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );

procedure N_CalcNonLinearXLAT1 ( var AXLAT: TN_IArray; ANLCoef: float );
procedure N_CalcNonLinearXLAT2 ( var AXLAT: TN_IArray; ANLCoef: float );

procedure N_Conv1SMProcObj ( APSMatr: TN_PSMatrDescr; AProcObj: TN_OnePtrProcObj );
procedure N_Conv1SMFuncObj ( APSMatr: TN_PSMatrDescr; AFuncObj: TN_OnePtrFuncObj );

//procedure N_Conv1SMToBitMask   ( APSMatr: TN_PSMatrDescr; APBitMaskDescr: TN_PBitMaskDescr;  AColor: Integer );
//procedure N_Conv1SMFromBitMask ( APSMatr: TN_PSMatrDescr; APBitMaskDescr: TN_PBitMaskDescr;  AColor: Integer );

procedure N_Conv2SMCopy      ( APSrcSM, APDstSM: TN_PSMatrDescr; AMode: integer );
procedure N_Conv2SMCopyConv  ( APSrcSM, APDstSM: TN_PSMatrDescr; ARGBMode, AShiftSize: integer; AShiftMode: TN_CopyShiftMode );
procedure N_Conv2SMCopyShift ( APSrcSM, APDstSM: TN_PSMatrDescr; AShiftSize: integer; AShiftMode: TN_CopyShiftMode );
procedure N_Conv2SMProcObj   ( APSrcSM, APDstSM: TN_PSMatrDescr; AProcObj: TN_TwoPtrsProcObj );
procedure N_Conv2SMXLAT      ( APSrcSM, APDstSM: TN_PSMatrDescr; APXLAT: PInteger; AXLATType: integer );
procedure N_Conv2SMToGray    ( APSrcSM, APDstSM: TN_PSMatrDescr );
procedure N_Conv2SMEmboss    ( APSrcSM, APDstSM: TN_PSMatrDescr; ADelta: TPoint; out AMin, AMax: integer );
procedure N_Conv2SMEmboss2   ( APSrcSM, APDstSM: TN_PSMatrDescr; ADelta: TPoint; APXLAT: PInteger );
procedure N_Conv2SMbyMatr    ( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer );
procedure N_Conv2SMbyVector  ( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer );
procedure N_Conv2SMSlow1     ( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer; ABorderMode: TN_FillBorderMode; AConst, ASmoothMode: integer );
procedure N_Conv2SMSlow2     ( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer; ABorderMode: TN_FillBorderMode; AConst, ASmoothMode: integer );
procedure N_Conv2SMAverageFast1 ( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer; ABorderMode: TN_FillBorderMode );

procedure N_Conv2SMMedianCT       ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianHuang    ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianHuangOld ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianSort1    ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianSort1ForPixel ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; X, Y: integer; out med: word );
procedure N_Conv2SMMedianHuangStandart       ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianHuangDelta          ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianHuangBinary         ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
procedure N_Conv2SMMedianHuangBinaryAndDelta ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );

procedure N_Draw2SMbyMask1 ( APDrawSM, APMaskSM: TN_PSMatrDescr; ADrawColor: integer; ADrawMode: integer  );

procedure N_Conv3SMProcObj ( APSrc1SM, APSrc2SM, APDstSM: TN_PSMatrDescr; AProcObj: TN_ThreePtrsProcObj );
procedure N_Conv3SMLinComb ( APSrcSMD: TN_PSMatrDescr; APSM2, APSMRes: Pointer; AAlfa: double );
procedure N_Conv3SMPrepNR1 ( APSrcSMD: TN_PSMatrDescr; APMeanSM, APDeltaSM: Pointer; APCM: PFloat; ACMDim: integer );
procedure N_Conv3SMDoNR1   ( APSrcSMD, APDstSMD: TN_PSMatrDescr; APMeanSM, APDeltaSM: Pointer; APCM: PFloat; ACMDim: integer; ACheckCoef, AMeanCoef: double );

procedure N_Conv4SMProcObj ( APSrc1SM, APSrc2SM, APSrc3SM, APDstSM: TN_PSMatrDescr; AProcObj: TN_FourPtrsProcObj );

function  N_ConvMatrByMatr ( var ADMatr: TN_FArray; ASMatr: TN_FArray; ASDim: Integer; ACMatr: TN_FArray; ACDim: Integer ): Integer;
procedure N_Conv2SMby2DCleaner       ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold: Float );
procedure N_Conv2SMbyMatr2DCleaner   ( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer; AThreshold: Float );
procedure N_Conv2SMbySpatialSmoother ( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold: Float );
procedure N_Conv2SMbyMatrMinMax      ( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer; ARShift: Float );

function  N_GetSMElement ( APSMatr: TN_PSMatrDescr; AIndX, AIndY: integer ): integer;
procedure N_SMToText     ( APSMatr: TN_PSMatrDescr; AFlags: integer; AName: string; AResStrings: TStrings; APUpperLeft: PPoint = nil; APMatrElems: Pointer = nil );
function  N_ArcTangLikeFunc   ( AArg, AFixArg, AFixFunc, AFormFactor: double ): double;
procedure N_CreateArcTangXLAT ( var AXLAT: TN_IArray; AFixInd, AFixFunc, ANumInds: integer; AFormFactor: double );



var
  N_PixOpObj: TN_PixOperationsObj;

  N_9SmoothCoefs: array [0..8] of float = ( 1.0/16, 1.0/8, 1.0/16,
                                            2.0/16, 2.0/8, 2.0/16,
                                            1.0/16, 1.0/8, 1.0/16  );


implementation
uses Math, Sysutils,
  K_CLib0,
  N_Lib0, N_Lib1, N_Gra1;

//******* TN_PixOperationsObj = class methods

//********************************* TN_PixOperationsObj.PO_XOROneByte(1Ptr) ***
// XOR one byte ( APElem^ = APElem^ xor PO_IntOperand )
//
//     Parameters
// APElem - Pointer to One Byte to XOR
//
procedure TN_PixOperationsObj.PO_XOROneByte( APElem: Pointer );
begin
  PByte(APElem)^ := PByte(APElem)^ xor Byte(PO_IntOperand);
end; // procedure TN_PixOperationsObj.PO_XOROneByte(1Ptr)

//************************************** TN_PixOperationsObj.PO_XORTwoBytes ***
// XOR Two Bytes ( APElem^ = APElem^ xor PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Two Bytes to XOR
//
procedure TN_PixOperationsObj.PO_XORTwoBytes( APElem: Pointer );
begin
  PWord(APElem)^ := PWord(APElem)^ xor Word(PO_IntOperand);
end; // procedure TN_PixOperationsObj.PO_XORTwoBytes

//************************************ TN_PixOperationsObj.PO_XORThreeBytes ***
// XOR Three Bytes ( APElem^ = APElem^ xor PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Three Bytes to XOR
//
procedure TN_PixOperationsObj.PO_XORThreeBytes( APElem: Pointer );
begin
  PWord(APElem)^ := PWord(APElem)^ xor Word(PO_IntOperand);
  PByte(TN_BytesPtr(APElem)+2)^ := PByte(TN_BytesPtr(APElem)+2)^ xor PByte(TN_BytesPtr(@PO_IntOperand)+2)^;
end; // procedure TN_PixOperationsObj.PO_XORThreeBytes

//************************************* TN_PixOperationsObj.PO_XORFourBytes ***
// XOR Four Bytes ( APElem^ = APElem^ xor PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Four Bytes to XOR
//
procedure TN_PixOperationsObj.PO_XORFourBytes( APElem: Pointer );
begin
  PInteger(APElem)^ := PInteger(APElem)^ xor PO_IntOperand;
end; // procedure TN_PixOperationsObj.PO_XORFourBytes

//************************************ TN_PixOperationsObj.PO_RGBDifference ***
// Calculate Max difference between R,G,B values of given Pixel
//
//     Parameters
// APElem - Pointer to Three of Four Bytes Pixel
// Result - Return True if max allowed difference is reached and
//          there is no need to check other pixels
//
function TN_PixOperationsObj.PO_RGBDifference( APElem: Pointer ): boolean;
var
  R, G, B, CurRGBDif, CurMaxRGB: integer;
  CurDblRGBDif: double;
begin
  R := PByte(TN_BytesPtr(APElem)+0)^;
  G := PByte(TN_BytesPtr(APElem)+1)^;
  B := PByte(TN_BytesPtr(APElem)+2)^;

  if R < G then
  begin
    if B < R then
    begin
      CurRGBDif := G - B;
      CurMaxRGB := G;
    end else // B >= R, R < G
    begin
      if B < G then
      begin
        CurRGBDif := G - R;
        CurMaxRGB := G;
      end else // B >= G, B >= R, R < G
      begin
        CurRGBDif := B - R;
        CurMaxRGB := B;
      end;
    end;
  end else // R >= G
  begin
    if B < G then
    begin
      CurRGBDif := R - B;
      CurMaxRGB := R;
    end else // B >= G, R >= G
    begin
      if B < R then
      begin
        CurRGBDif := R - G;
        CurMaxRGB := R;
      end else // B >= R, B >= G, R >= G
      begin
        CurRGBDif := B - G;
        CurMaxRGB := B;
      end;
    end;
  end;

  CurDblRGBDif := CurRGBDif * PO_RGBDifCoefs[ CurMaxRGB shr 6 ];
  PO_RealMaxRGBDif := max( PO_RealMaxRGBDif, CurDblRGBDif );
  Result := PO_RealMaxRGBDif > PO_MaxAllowedRGBDif;
end; // procedure TN_PixOperationsObj.PO_RGBDifference

//********************************* TN_PixOperationsObj.PO_XOROneByte(2Ptr) ***
// XOR one byte ( APDst^ = APSrc^ xor PO_IntOperand )
//
//     Parameters
// APSrc - Pointer to Source Byte
// APDst - Pointer to Destination Byte
//
procedure TN_PixOperationsObj.PO_XOROneByte( APSrc, APDst: Pointer );
begin
  PByte(APDst)^ := PByte(APSrc)^ xor Byte(PO_IntOperand);
end; // procedure TN_PixOperationsObj.PO_XOROneByte(2Ptr)

//************************************** TN_PixOperationsObj.PO_SHLTwoBytes ***
// Shift Left Two Bytes ( APElem^ = APElem^ shl PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Two Bytes to shift Left
//
procedure TN_PixOperationsObj.PO_SHLTwoBytes( APElem: Pointer );
begin
  PWord(APElem)^ := PWord(APElem)^ shl PO_IntOperand;
end; // procedure TN_PixOperationsObj.PO_SHLTwoBytes

//************************************** TN_PixOperationsObj.PO_SHRTwoBytes ***
// Shift Right Two Bytes ( APElem^ = APElem^ shr PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Two Bytes to shift Right
//
procedure TN_PixOperationsObj.PO_SHRTwoBytes( APElem: Pointer );
begin
  PWord(APElem)^ := PWord(APElem)^ shr PO_IntOperand;
end; // procedure TN_PixOperationsObj.PO_SHRTwoBytes

//************************************** TN_PixOperationsObj.PO_CalcMaxWord ***
// Calc Max value: PO_MaxInt := Max( PO_MaxInt, PWord(APElem)^ );
//
//     Parameters
// APElem - Pointer to Word element to check
//
procedure TN_PixOperationsObj.PO_CalcMaxWord( APElem: Pointer );
begin
  PO_MaxInt := Max( PO_MaxInt, PWord(APElem)^ );
end; // procedure TN_PixOperationsObj.PO_CalcMaxWord

//****************************************** TN_PixOperationsObj.PO_SetElem ***
// Set given Element by PO_SetElemMode, PO_SetElemPValue
//
//     Parameters
// APElem - Pointer to element to set
//
// PO_SetElemMode:
//   =1 - set one   byte
//   =2 - set two   bytes
//   =3 - set three bytes
//   =4 - set four  bytes
//   =5 - set three bytes Gray RGB8 Color by given one byte (R=G=B) value
//   =6 - set six   bytes Gray RGB16 Color by given two bytes (R=G=B) value
//
// PO_SetElemPValue: Pointer to Value to set
//
procedure TN_PixOperationsObj.PO_SetElem( APElem: Pointer );
begin

  case PO_SetElemMode of

  1: PByte(APElem)^ := PByte(PO_SetElemPValue)^; // set one byte

  2: PWORD(APElem)^ := PWORD(PO_SetElemPValue)^; // set two bytes

  3: begin // set three bytes
       PWORD(APElem)^ := PWORD(PO_SetElemPValue)^;
       PByte(TN_BytesPtr(APElem)+2)^ := PByte(TN_BytesPtr(PO_SetElemPValue)+2)^;
     end; // 3: begin // set three bytes

  4: PInteger(APElem)^ := PInteger(PO_SetElemPValue)^;

  5: begin // set three bytes Gray RGB8 Color by given one byte (R=G=B) value
       PByte(TN_BytesPtr(APElem)+0)^ := PByte(PO_SetElemPValue)^;
       PByte(TN_BytesPtr(APElem)+1)^ := PByte(PO_SetElemPValue)^;
       PByte(TN_BytesPtr(APElem)+2)^ := PByte(PO_SetElemPValue)^;
     end; // 5: begin // set three bytes Gray RGB8 Color by given one byte (R=G=B) value

  6: begin // set six bytes Gray RGB16 Color by given two bytes (R=G=B) value
       PWORD(TN_BytesPtr(APElem)+0)^ := PWORD(PO_SetElemPValue)^;
       PWORD(TN_BytesPtr(APElem)+2)^ := PWORD(PO_SetElemPValue)^;
       PWORD(TN_BytesPtr(APElem)+4)^ := PWORD(PO_SetElemPValue)^;
     end; // 6: begin // set six bytes Gray RGB16 Color by given two bytes (R=G=B) value

  end; // case PO_SetElemMode of

end; // procedure TN_PixOperationsObj.PO_SetElem

//************************************** TN_PixOperationsObj.PO_AddTwoBytes ***
// Add Two Bytes ( APElem^ = APElem^ + PO_IntOperand )
//
//     Parameters
// APElem - Pointer to Two Bytes Operand
//
procedure TN_PixOperationsObj.PO_AddTwoBytes( APElem: Pointer );
begin
  PWord(APElem)^ := Word( PWord(APElem)^ + PO_IntOperand);
end; // procedure TN_PixOperationsObj.PO_AddTwoBytes


//******************** Global Procedures and Functions ***********************

//********************************************************* N_RotateFRFlags ***
// Calculate FlipRotate Flags after Rotation on given AAngle
//
//     Parameters
// ASrcFlags - given FlipRotate Flags to convert by rotation on AAngle
// AAngle    - given rotation Angle in degree
// Result    - Return resulting FlipRotate Flags after rotatation
//
// AAngle is rounded to i*90 value, where i = 0,1,2,3,4
//
function N_RotateFRFlags ( ASrcFRFlags: integer; AAngle: float ): integer;
var
  i90: integer;
begin
  Result := 0;
  i90 := Round( N_Get0360Angle( AAngle ) / 90 );

  case i90 of
    0: Result := ASrcFRFlags; // AAngle = 0
    1: Result := N_Rotate90Flags[ASrcFRFlags]; // 90 degree CCW
    2: Result := ASrcFRFlags xor (N_FlipHorBit or N_FlipVertBit); // 180 degree
    3: Result := N_Rotate90Flags[ASrcFRFlags xor (N_FlipHorBit or N_FlipVertBit)]; // 270 degree CCW
    4: Result := ASrcFRFlags; // AAngle = 0
  end;
end; // function N_RotateFRFlags

//********************************************************* N_RotateFRFlags ***
// Convert given point (X,Y) Coords in given Rect by given Flip Rotate Flags
//
//     Parameters
// AXYCoords - given point (X,Y) coords
// AFRFlags  - given Flip Rotate Flags
// ARect     - given Rect that is transformed by AFRFlags (Source Rect)
// Result    - Return point (X,Y) coords converted by given AFRFlags
//
function N_FlipRotateCoords( AXYCoords: TPoint; AFRFlags: integer; ARect: TRect ): TPoint;
begin
  Result := AXYCoords;

  if  (AFRFlags and N_FlipDiagBit) <> 0 then
  begin
    N_SwapTwoInts( @Result.X, @Result.Y );
    if (AFRFlags and N_FlipHorBit)  = 0 then Result.X := ARect.Bottom - (Result.X - ARect.Top);
    if (AFRFlags and N_FlipVertBit) = 0 then Result.Y := ARect.Right  - (Result.Y - ARect.Left);
  end else // no diagonal flip
  begin
    if (AFRFlags and N_FlipHorBit)  <> 0 then Result.X := ARect.Right  - (Result.X - ARect.Left);
    if (AFRFlags and N_FlipVertBit) <> 0 then Result.Y := ARect.Bottom - (Result.Y - ARect.Top);
  end;
end; // function N_FlipRotateCoords

//******************************************************* N_PrepIntArraySMD ***
// Prepare SubMatrix Description of given Integer array of Pixels
//
//     Parameters
// APFirstInt - Pointer to First Integer
// ANumInts   - Number of integers
// APSMatr    - Pointer to SubMatrix description to prepare
//
procedure N_PrepIntArraySMD( APFirstInt: PInteger; ANumInts: integer; APSMatr: TN_PSMatrDescr );
begin
  with APSMatr^ do
  begin
    SMDNumX   := ANumInts;
    SMDNumY   := 1;
    SMDElSize := 4;
    SMDStepX  := 4;
    SMDStepY  := 4*ANumInts;
    SMDBegIX  := 0;
    SMDEndIX  := ANumInts - 1;
    SMDBegIY  := 0;
    SMDEndIY  := 0;
    SMDPBeg   := TN_BytesPtr(APFirstInt);
  end; // with APSMatr^ do
end; // procedure N_PrepIntArraySMD

//********************************************************** N_Prep1SMWVars ***
// Prepare Working Variables needed for SubMatrix Convertion with one Operand
//
//     Parameters
// APSMatr - Pointer to SubMatrix description
// APWVars - Pointer to TN_ConvSMVars with resulting Variables
//
procedure N_Prep1SMWVars( APSMatr: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
begin
  with APWVars^ do
  begin
    with APSMatr^ do // prepare all needed  variables
    begin
      WNX := SMDEndIX - SMDBegIX;

      if WNX >= 0 then // SMDEndIX >= SMDBegIX
      begin
        WNX := WNX + 1;
        WSrcStepX := SMDStepX;
      end else // SMDEndIX < SMDBegIX
      begin
        WNX := -WNX - 1;
        WSrcStepX := -SMDStepX;
      end;

      WNY := SMDEndIY - SMDBegIY;

      if WNY >= 0 then // SMDEndIY >= SMDBegIY
      begin
        WNY := WNY + 1;
        WSrcStepY := SMDStepY;
      end else // SMDEndIY < SMDBegIY
      begin
        WNY := -WNY - 1;
        WSrcStepY := -SMDStepY;
      end;

      WPSrcBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with APSMatr^ do // prepare all needed  variables

  end; // with APWVars^ do
end; // procedure N_Prep1SMWVars

//********************************************************** N_Prep2SMWVars ***
// Prepare Working Variables needed for SubMatrix Convertion (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APWVars - Pointer to TN_ConvSMVars with resulting Variables
//
procedure N_Prep2SMWVars( APSrcSM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
begin
  with APWVars^ do
  begin

    Assert( abs(APDstSM^.SMDEndIX - APDstSM^.SMDBegIX) =
            abs(APSrcSM^.SMDEndIX - APSrcSM^.SMDBegIX), 'Bad SMD1!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY - APDstSM^.SMDBegIY) =
            abs(APSrcSM^.SMDEndIY - APSrcSM^.SMDBegIY), 'Bad SMD2!' ); // a precaution

    with APSrcSM^ do // prepare WNX, WNY and Src SubMatr related variables
    begin
      WNX := SMDEndIX - SMDBegIX;

      if WNX >= 0 then // SMDEndIX >= SMDBegIX
      begin
        WNX := WNX + 1;
        WSrcStepX := SMDStepX;
      end else // SMDEndIX < SMDBegIX
      begin
        WNX := -WNX - 1;
        WSrcStepX := -SMDStepX;
      end;

      WNY := SMDEndIY - SMDBegIY;

      if WNY >= 0 then // SMDEndIY >= SMDBegIY
      begin
        WNY := WNY + 1;
        WSrcStepY := SMDStepY;
      end else // SMDEndIY < SMDBegIY
      begin
        WNY := -WNY - 1;
        WSrcStepY := -SMDStepY;
      end;

      WPSrcBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ASrcSM do // prepare NX, NY and Src SubMatr related variables

    with APDstSM^ do // prepare Dst SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WDstStepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WDstStepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WDstStepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WDstStepY := -SMDStepY;

      WPDstBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ADstSM do // prepare Dst SubMatr related variables

  end; // with APWVars^ do
end; // procedure N_Prep2SMWVars

//********************************************************** N_Prep3SMWVars ***
// Prepare Working Variables needed for SubMatrix Convertion (three operands)
//
//     Parameters
// APSrc1SM - Pointer to First Source SubMatrix description
// APSrc2SM - Pointer to Second Source SubMatrix description
// APDstSM  - Pointer to Destination SubMatrix description
// APWVars  - Pointer to TN_ConvSMVars with resulting Variables
//
procedure N_Prep3SMWVars( APSrc1SM, APSrc2SM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
begin
  with APWVars^ do
  begin

    Assert( abs(APDstSM^.SMDEndIX  - APDstSM^.SMDBegIX) =
            abs(APSrc1SM^.SMDEndIX - APSrc1SM^.SMDBegIX), 'Bad SMD1!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY  - APDstSM^.SMDBegIY) =
            abs(APSrc1SM^.SMDEndIY - APSrc1SM^.SMDBegIY), 'Bad SMD2!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIX  - APDstSM^.SMDBegIX) =
            abs(APSrc2SM^.SMDEndIX - APSrc2SM^.SMDBegIX), 'Bad SMD3!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY  - APDstSM^.SMDBegIY) =
            abs(APSrc2SM^.SMDEndIY - APSrc2SM^.SMDBegIY), 'Bad SMD4!' ); // a precaution

    with APSrc1SM^ do // prepare WNX, WNY and Src1 SubMatr related variables
    begin
      WNX := SMDEndIX - SMDBegIX;

      if WNX >= 0 then // SMDEndIX >= SMDBegIX
      begin
        WNX := WNX + 1;
        WSrcStepX := SMDStepX;
      end else // SMDEndIX < SMDBegIX
      begin
        WNX := -WNX - 1;
        WSrcStepX := -SMDStepX;
      end;

      WNY := SMDEndIY - SMDBegIY;

      if WNY >= 0 then // SMDEndIY >= SMDBegIY
      begin
        WNY := WNY + 1;
        WSrcStepY := SMDStepY;
      end else // SMDEndIY < SMDBegIY
      begin
        WNY := -WNY - 1;
        WSrcStepY := -SMDStepY;
      end;

      WPSrcBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ASrcSM do // prepare NX, NY and Src SubMatr related variables

    with APSrc2SM^ do // prepare Src2 SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WSrc2StepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WSrc2StepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WSrc2StepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WSrc2StepY := -SMDStepY;

      WPSrc2BegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with APSrc2SM^ do // prepare Src2 SubMatr related variables

    with APDstSM^ do // prepare Dst SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WDstStepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WDstStepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WDstStepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WDstStepY := -SMDStepY;

      WPDstBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ADstSM do // prepare Dst SubMatr related variables

  end; // with APWVars^ do
end; // procedure N_Prep3SMWVars

//********************************************************** N_Prep4SMWVars ***
// Prepare Working Variables needed for SubMatrixes Convertion (four operands)
//
//     Parameters
// APSrc1SM - Pointer to First  Source SubMatrix description
// APSrc2SM - Pointer to Second Source SubMatrix description
// APSrc3SM - Pointer to Third  Source SubMatrix description
// APDstSM  - Pointer to Destination SubMatrix description
// APWVars  - Pointer to TN_ConvSMVars with resulting Variables
//
procedure N_Prep4SMWVars( APSrc1SM, APSrc2SM, APSrc3SM, APDstSM: TN_PSMatrDescr; APWVars: TN_PConvSMVars );
begin
  with APWVars^ do
  begin

    Assert( abs(APDstSM^.SMDEndIX  - APDstSM^.SMDBegIX) =
            abs(APSrc1SM^.SMDEndIX - APSrc1SM^.SMDBegIX), 'Bad SMD1!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY  - APDstSM^.SMDBegIY) =
            abs(APSrc1SM^.SMDEndIY - APSrc1SM^.SMDBegIY), 'Bad SMD2!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIX  - APDstSM^.SMDBegIX) =
            abs(APSrc2SM^.SMDEndIX - APSrc2SM^.SMDBegIX), 'Bad SMD3!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY  - APDstSM^.SMDBegIY) =
            abs(APSrc2SM^.SMDEndIY - APSrc2SM^.SMDBegIY), 'Bad SMD4!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIX  - APDstSM^.SMDBegIX) =
            abs(APSrc3SM^.SMDEndIX - APSrc3SM^.SMDBegIX), 'Bad SMD5!' ); // a precaution

    Assert( abs(APDstSM^.SMDEndIY  - APDstSM^.SMDBegIY) =
            abs(APSrc3SM^.SMDEndIY - APSrc3SM^.SMDBegIY), 'Bad SMD6!' ); // a precaution

    with APSrc1SM^ do // prepare WNX, WNY and Src1 SubMatr related variables
    begin
      WNX := SMDEndIX - SMDBegIX;

      if WNX >= 0 then // SMDEndIX >= SMDBegIX
      begin
        WNX := WNX + 1;
        WSrcStepX := SMDStepX;
      end else // SMDEndIX < SMDBegIX
      begin
        WNX := -WNX - 1;
        WSrcStepX := -SMDStepX;
      end;

      WNY := SMDEndIY - SMDBegIY;

      if WNY >= 0 then // SMDEndIY >= SMDBegIY
      begin
        WNY := WNY + 1;
        WSrcStepY := SMDStepY;
      end else // SMDEndIY < SMDBegIY
      begin
        WNY := -WNY - 1;
        WSrcStepY := -SMDStepY;
      end;

      WPSrcBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ASrcSM do // prepare NX, NY and Src SubMatr related variables

    with APSrc2SM^ do // prepare Src2 SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WSrc2StepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WSrc2StepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WSrc2StepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WSrc2StepY := -SMDStepY;

      WPSrc2BegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with APSrc2SM^ do // prepare Src2 SubMatr related variables

    with APSrc3SM^ do // prepare Src3 SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WSrc3StepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WSrc3StepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WSrc3StepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WSrc3StepY := -SMDStepY;

      WPSrc3BegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with APSrc3SM^ do // prepare Src3 SubMatr related variables

    with APDstSM^ do // prepare Dst SubMatr related variables
    begin
      if SMDEndIX >= SMDBegIX then // SMDEndIX >= SMDBegIX
        WDstStepX := SMDStepX
      else // SMDEndIX < SMDBegIX
        WDstStepX := -SMDStepX;

      if SMDEndIY >= SMDBegIY then // SMDEndIY >= SMDBegIY
        WDstStepY := SMDStepY
      else // SMDEndIY < SMDBegIY
        WDstStepY := -SMDStepY;

      WPDstBegX := SMDPBeg + SMDBegIX*SMDStepX + SMDBegIY*SMDStepY;
    end; // with ADstSM do // prepare Dst SubMatr related variables

  end; // with APWVars^ do
end; // procedure N_Prep4SMWVars

//**************************************************** N_CalcNonLinearXLAT1 ***
// Prepare SubMatrix Description of given Integer array of Pixels
//
//     Parameters
//
procedure N_CalcNonLinearXLAT1( var AXLAT: TN_IArray; ANLCoef: float );
begin

// temporary not implemented
end; // function N_NonLinear01Func1

//**************************************************** N_CalcNonLinearXLAT1 ***
// Prepare SubMatrix Description of given Integer array of Pixels
//
//     Parameters
//
procedure N_CalcNonLinearXLAT2( var AXLAT: TN_IArray; ANLCoef: float );
begin

end; // procedure N_CalcNonLinearXLAT1

//******************************************************** N_Conv1SMProcObj ***
// Convert One SubMatr Elements by given Procedure of Object (one operand)
//
//     Parameters
// APSMatr  - Pointer to SubMatrix description
// AProcObj - given Procedure of Object for one Element convertion
//
// AProcObj usage: AProcObj( APElem );
//
procedure N_Conv1SMProcObj( APSMatr: TN_PSMatrDescr; AProcObj: TN_OnePtrProcObj );
var
  ix, iy: integer;
  PElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
//  PSrcPChar: PAnsiChar;
begin
  if not Assigned( AProcObj ) then Exit; // a precaution
  N_Prep1SMWVars( APSMatr, @WVars );

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PElem := WPSrcBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      AProcObj( PElem );

      PElem := PElem + WSrcStepX; // to next Src Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv1SMProcObj

//******************************************************** N_Conv1SMFuncObj ***
// Convert One SubMatr Elements by given Function of Object (one operand)
//
//     Parameters
// APSMatr  - Pointer to SubMatrix description
// AFuncObj - given Function of Object for one Element convertion. AFuncObj returns
//            True, if convertion loop should be terminated
//
// AFuncObj usage: if AFuncObj( APElem ) then Exit;
//
procedure N_Conv1SMFuncObj( APSMatr: TN_PSMatrDescr; AFuncObj: TN_OnePtrFuncObj );
var
  ix, iy: integer;
  PElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  if not Assigned( AFuncObj ) then Exit; // a precaution
  N_Prep1SMWVars( APSMatr, @WVars );

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PElem := WPSrcBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      if AFuncObj( PElem ) then Exit;

      PElem := PElem + WSrcStepX; // to next Src Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv1SMFuncObj

{
//****************************************************** N_Conv1SMToBitMask ***
// Convert SubMatr Elements to Bit Mask Elements
//
//     Parameters
// APSMatr        - Pointer to SubMatrix description
// APBitMaskDescr - Pointer to Bit Mask DEescription
//
// Memory for BitMask should be already allocated.
//
procedure N_Conv1SMToBitMask( APSMatr: TN_PSMatrDescr; APBitMaskDescr: TN_PBitMaskDescr );
begin
// ...
end; // procedure N_Conv1SMToBitMask

//**************************************************** N_Conv1SMFromBitMask ***
// Convert Bit Mask  Elements to SubMatr Elements
//
//     Parameters
// APSMatr        - Pointer to SubMatrix description
// APBitMaskDescr - Pointer to Bit Mask DEescription
//
procedure N_Conv1SMFromBitMask( APSMatr: TN_PSMatrDescr; APBitMaskDescr: TN_PBitMaskDescr );
begin
// ...
end; // procedure N_Conv1SMFromBitMask
}

//*********************************************************** N_Conv2SMCopy ***
// Convert SubMatr - Copy elements with possible Flip, Rotate and
// possibly SrcElemSize <> DstElemSize  (two operands)
//
//     Parameters
// APSrcSM - Source SubMatrix description
// APDstSM - Destination SubMatrix description
// AMode   - Convertion mode: bit0=0 means that 3,4 bytes Destination SubMatrix
//           is TrueColor and 1,2 Source SubMatrix is Gray; bit0=1 means that
//           Destination SubMatrix has integer elements
//
procedure N_Conv2SMCopy( APSrcSM, APDstSM: TN_PSMatrDescr; AMode: integer );
var
  ix, iy, CaseInd: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  TrueColorMode: boolean;
  WVars: TN_ConvSMVars;
//  PSrcPChar: PAnsiChar;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  // Prepare CaseInd (CaseInd - SrcSize -> DstSize)
  // 0 - 1 -> 1
  // 1 - 1 -> 2   Byte -> Word High Byte
  // 2 - 1 -> 3,4 Byte -> RGB     (mode=0)
  // 3 - 1 -> 4   Byte -> integer (mode=1)

  //21 - 2 -> 1
  // 4 - 2 -> 2
  // 5 - 2 -> 3,4 Word High Byte -> RGB     (mode=0)
  // 6 - 2 -> 4   Word           -> integer (mode=1)

  // 7 - 3 -> 3,4 RGB -> RGB (mode=0)

  // 7 - 4 -> 3 RGB -> RGB (mode=0)
  // 7 - 4 -> 4 RGB -> RGB (mode=0)
  // 8 - 4 -> 4 integer -> integer

  TrueColorMode := (AMode and $01) = 0;

  case APSrcSM^.SMDElSize of
    1: case APDstSM^.SMDElSize of
         1: CaseInd := 0; // 1 -> 1
         2: CaseInd := 1; // 1 -> 2
         3: CaseInd := 2; // 1 -> 3 byte -> RGB (mode=0)
         4: if TrueColorMode then CaseInd := 2  // 1 -> 4 byte -> RGB (mode=0)
                             else CaseInd := 3; // byte -> integer    (mode=1)
         else CaseInd := -1;
       end; // 1: case ADstSM.SMDElSize of

    2: case APDstSM^.SMDElSize of
         1: CaseInd := 21; // 2 -> 1
         2: CaseInd := 4; // 2 -> 2
         3: CaseInd := 5; // 2 -> 3 High(word) -> RGB (mode=0)
         4: if TrueColorMode then CaseInd := 5  // 2 -> 4 High(word) -> RGB (mode=0)
                             else CaseInd := 6; // word -> integer          (mode=1)
         else CaseInd := -1;
       end; // 2: case ADstSM.SMDElSize of

    3: case APDstSM^.SMDElSize of
         3: CaseInd := 7; // 3 -> 3, RGB -> RGB
         4: CaseInd := 7; // 3 -> 4, RGB -> RGB (A byte ignored)
         else CaseInd := -1;
       end; // 3: case ADstSM.SMDElSize of

    4: case APDstSM^.SMDElSize of
         3: CaseInd := 7; // 4 -> 3, RGB -> RGB (A byte ignored)
         4: if TrueColorMode then CaseInd := 7  // 4 -> 4, RGB -> RGB (mode=0) (A byte ignored)
                             else CaseInd := 8; // integer -> integer (mode=1)
         else CaseInd := -1;
       end; // 4: case ADstSM.SMDElSize of

    else CaseInd := -1;
  end; // case APSrcSM^.SMDElSize of

  if CaseInd = -1 then Exit; // a precaution

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    case CaseInd of

    0: begin // 1 -> 1
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=1
        PByte(PDstElem)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 0: begin // 1 -> 1

    1: begin // 1 -> 2
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=2
//        PWord(PDstElem)^ := PByte(PSrcElem)^;
        PByte(PDstElem)^ := PByte(PSrcElem)^;     // Set Low Byte
        PByte(PDstElem + 1)^ := PByte(PSrcElem)^; // Set High Byte

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 1: begin // 1 -> 2

    2: begin // 1 -> 3,4 (byte -> RGB, mode=0)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=3,4
        PByte(PDstElem+0)^ := PByte(PSrcElem)^;
        PByte(PDstElem+1)^ := PByte(PSrcElem)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 2: begin // 1 -> 3,4 (byte -> RGB, mode=0)

    3: begin // 1 -> 4 (byte -> integer, mode=1)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=4
        PInteger(PDstElem)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 3: begin // 1 -> 4 (byte -> integer, mode=1)

    21: begin // 2 -> 1
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=2
        PByte(PDstElem)^ := PByte(PSrcElem + 1)^; // Set from High byte

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 4: begin // 2 -> 2

    4: begin // 2 -> 2
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=2
        PWord(PDstElem)^ := PWord(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 4: begin // 2 -> 2

    5: begin // 2 -> 3,4 (High(word) -> RGB, mode=0)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=3,4
        PByte(PDstElem+0)^ := PByte(PSrcElem+1)^;
        PByte(PDstElem+1)^ := PByte(PSrcElem+1)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem+1)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 5: begin // 2 -> 3,4 (High(word) -> RGB, mode=0)

    6: begin // 2 -> 4 (word -> integer, mode=1)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=4
        PInteger(PDstElem)^ := PWord(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 6: begin // 2 -> 4 (word -> integer, mode=1)

    7: begin // 3,4 -> 3,4 (RGB -> RGB, mode=0)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=3,4  DstElemSize=3,4  copy three bytes
        PWord(PDstElem)^   := PWord(PSrcElem)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem+2)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 7: begin // 3,4 -> 3,4 (RGB -> RGB, mode=0)

    8: begin // 4 -> 4 (integer -> integer, mode=1)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=4, DstElemSize=4
        PInteger(PDstElem)^ := PInteger(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 8: begin // 4 -> 4 (integer -> integer, mode=1)

    end; // case CaseInd of

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMCopy

//******************************************************* N_Conv2SMCopyConv ***
// Convert SubMatr - Copy elements with possible Gray-RGB convertion and
// possible Flip, Rotate (SrcElemSize may be <> DstElemSize, two operands)
//
//     Parameters
// APSrcSM    - Source SubMatrix description
// APDstSM    - Destination SubMatrix description
// ARGBMode   - Convertion mode: bit0=0 means that 3,4,6,8 bytes Destination SubMatrix
//              is TrueColor and 1,2 Source SubMatrix is Gray; bit0=1 means that
//              4 bytes Destination SubMatrix has integer elements
// AShiftSize - abs Shift Size or not used if  AShiftMode=csmShiftAuto1
// AShiftMode - Shift Mode (see TN_CopyShiftMode)
//
procedure N_Conv2SMCopyConv( APSrcSM, APDstSM: TN_PSMatrDescr;
                             ARGBMode, AShiftSize: integer; AShiftMode: TN_CopyShiftMode );
var
  ix, iy, CaseInd, CurElem, Shift2, ShiftSize: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  ConvGrayToRGB: boolean;
  ShiftMode: TN_CopyShiftMode;
  WVars: TN_ConvSMVars;
begin
  //***** List of all Case Inds (CaseInd - SrcSize -> DstSize Comment) :

  //  0 - 1 -> 1   Byte -> Byte without Shifting
  //  1 - 1 -> 1   Byte -> Byte with Shifting
  //  2 - 1 -> 2   Byte -> Word with Shifting
  //  3 - 1 -> 3   Byte -> RGB8  without Shifting
  //  4 - 1 -> 4   Byte -> ARGB8 without Shifting (ARGBMode=0)
  //  5 - 1 -> 4   Byte -> integer with Shifting  (ARGBMode=1)
  //  6 - 1 -> 6   Byte -> RGB16  with Shifting
  //  7 - 1 -> 8   Byte -> ARGB16 with Shifting

  //  8 - 2 -> 1   Gray16 ->  Byte   with Shifting
  //  9 - 2 -> 2   Gray16 -> Gray16  without Shifting
  // 10 - 2 -> 2   Gray16 -> Gray16  with Shifting
  // 11 - 2 -> 3   Gray16 ->  RGB8   with Shifting
  // 12 - 2 -> 4   Gray16 ->  ARGB8  with Shifting (ARGBMode=0)
  // 13 - 2 -> 4   Gray16 -> integer with Shifting (ARGBMode=1)
  // 14 - 2 -> 6   Gray16 ->  RGB16  with Shifting
  // 15 - 2 -> 8   Gray16 -> ARGB16  with Shifting

  // 16 - 3 -> 1   RGB8 -> Gray8(Byte)
  // 17 - 3 -> 2   RGB8 -> Gray16(Word) with Shifting
  // 18 - 3 -> 3   RGB8 -> RGB8
  // 19 - 3 -> 4   RGB8 -> ARGB8
  // 20 - 3 -> 6   RGB8 -> RGB16  with Shifting
  // 21 - 3 -> 8   RGB8 -> ARGB16 with Shifting

  //*16 - 4 -> 1   ARGB8 -> Gray8(Byte)
  //*17 - 4 -> 2   ARGB8 -> Gray16(Word) with Shifting
  //*18 - 4 -> 3   ARGB8 -> RGB8
  // 22 - 4 -> 4   ARGB8 -> ARGB8 (integer -> integer)
  //*20 - 4 -> 6   ARGB8 -> RGB16  with Shifting
  //*21 - 4 -> 8   ARGB8 -> ARGB16 with Shifting

  // 23 - reserved
  // 24 - reserved

  // 25 - 6 -> 1   RGB16 -> Gray8(Byte)  with Shifting
  // 26 - 6 -> 2   RGB16 -> Gray16(Word) with Shifting
  // 27 - 6 -> 3   RGB16 ->   RGB8       with Shifting
  // 28 - 6 -> 4   RGB16 ->  ARGB8       with Shifting
  // 29 - 6 -> 6   RGB16 ->   RGB16      with Shifting
  // 30 - 6 -> 8   RGB16 ->  ARGB16      with Shifting

  // 31 - reserved
  // 32 - reserved

  //*25 - 8 -> 1  ARGB16 -> Gray8(Byte)  with Shifting
  //*26 - 8 -> 2  ARGB16 -> Gray16(Word) with Shifting
  //*27 - 8 -> 3  ARGB16 ->   RGB8       with Shifting
  //*28 - 8 -> 4  ARGB16 ->  ARGB8       with Shifting
  //*29 - 8 -> 6  ARGB16 ->   RGB16      with Shifting
  // 33 - 8 -> 8  ARGB16 ->  ARGB16      with Shifting

  Assert( APSrcSM^.SMDNumBits >= 8, Format( 'APSrcSM^.SMDNumBits=%d', [APSrcSM^.SMDNumBits] ) );
  Assert( APDstSM^.SMDNumBits >= 8, Format( 'APDstSM^.SMDNumBits=%d', [APDstSM^.SMDNumBits] ) );

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  Shift2    := 0; // to avoid warning
  ShiftSize := 0;         // default value for AShiftMode = csmShiftAuto1
  ShiftMode := csmNotDef; // default value for AShiftMode = csmShiftAuto1

  if AShiftMode <> csmShiftAuto1 then
  begin
    ShiftSize := AShiftSize;
    ShiftMode := AShiftMode;
  end;

  ConvGrayToRGB := (ARGBMode and $01) = 0;

  //******************************** Prepare CaseInd, ShiftSize, ShiftMode

  case APSrcSM^.SMDElSize of

    1: begin // APSrcSM^.SMDElSize = 1
         case APDstSM^.SMDElSize of
           1: if ShiftSize = 0 then CaseInd := 0  // 1 -> 1   Byte -> Byte without Shifting
                               else CaseInd := 1; // 1 -> 1   Byte -> Byte with Shifting

           2: CaseInd := 2; // 1 -> 2   Byte -> Word with Shifting
           3: CaseInd := 3; // 1 -> 3   Byte -> RGB8  without Shifting

           4: if ConvGrayToRGB then CaseInd := 4  // Byte -> ARGB8 without Shifting (ARGBMode=0)
                               else CaseInd := 5; // Byte -> integer with Shifting  (ARGBMode=1)

           6: CaseInd := 6; // Byte -> RGB16  with Shifting
           8: CaseInd := 7; // Byte -> ARGB16 with Shifting

           else CaseInd := -1; // error
         end; // case ADstSM.SMDElSize of

         if (AShiftMode = csmShiftAuto1) and
            ( (CaseInd = 2) or (CaseInd = 6) or (CaseInd = 7) ) then // byte -> word
         begin
           ShiftSize := APDstSM^.SMDNumBits - 8;
           Shift2    := max( 0, 8 - ShiftSize );
           ShiftMode := csmShiftLeftOr;
         end;

       end; // 1: begin // APSrcSM^.SMDElSize = 1

    2: begin // APSrcSM^.SMDElSize = 2
         case APDstSM^.SMDElSize of
           1: CaseInd := 8; // 2 -> 1   Gray16 ->  Byte   with Shifting

           2: if AShiftSize = 0 then CaseInd := 9   // Gray16 -> Gray16  without Shifting
                                else CaseInd := 10; // Gray16 -> Gray16  with Shifting

           3: CaseInd := 11; // Gray16 ->  RGB8   with Shifting

           4: if ConvGrayToRGB then CaseInd := 12  // Gray16 ->  ARGB8  with Shifting (ARGBMode=0)
                               else CaseInd := 13; // Gray16 -> integer with Shifting (ARGBMode=1)

           6: CaseInd := 14; // Gray16 ->  RGB16  with Shifting
           8: CaseInd := 15; // Gray16 -> ARGB16  with Shifting

           else CaseInd := -1; // error
         end; // case ADstSM.SMDElSize of

         if (AShiftMode = csmShiftAuto1) then
         begin
           if (CaseInd = 8) or (CaseInd = 11) or (CaseInd = 12) then // word -> byte
           begin
             ShiftSize := APSrcSM^.SMDNumBits - 8;
             ShiftMode := csmShiftRight;
           end else if CaseInd <> 13 then // caseInds=9,10,14,15  word -> word
           begin
             ShiftSize := APSrcSM^.SMDNumBits - APDstSM^.SMDNumBits;

             if ShiftSize < 0 then
             begin
               ShiftSize := -ShiftSize;
               Shift2    := max( 0, 8 - ShiftSize );
               ShiftMode := csmShiftLeftOR;
             end else if ShiftSize > 0 then
               ShiftMode := csmShiftRight
             else // ShiftSize = 0
               ShiftMode := csmNotDef;
           end; // else if CaseInd <> 13 then
         end; // if (AShiftMode = csmShiftAuto1) then

       end; // 2: begin // APSrcSM^.SMDElSize = 2

    3: begin // APSrcSM^.SMDElSize = 3
         case APDstSM^.SMDElSize of
           1: CaseInd := 16; // 3 -> 1   RGB8 -> Gray8(Byte)
           2: CaseInd := 17; // 3 -> 2   RGB8 -> Gray16(Word) with Shifting
           3: CaseInd := 18; // 3 -> 3   RGB8 -> RGB8
           4: CaseInd := 19; // 3 -> 4   RGB8 -> ARGB8
           6: CaseInd := 20; // 3 -> 6   RGB8 -> RGB16  with Shifting
           8: CaseInd := 21; // 3 -> 8   RGB8 -> ARGB16 with Shifting
           else CaseInd := -1; // error
         end; // case ADstSM.SMDElSize of

         if (CaseInd = 17) or (CaseInd = 20) or (CaseInd = 21) then // byte -> word
         begin
           ShiftSize := APDstSM^.SMDNumBits - 8;
           Shift2    := max( 0, 8 - ShiftSize );
           ShiftMode := csmShiftLeftOr;
         end;

       end; // 3: begin // APSrcSM^.SMDElSize = 3

    4: begin // APSrcSM^.SMDElSize = 4
         case APDstSM^.SMDElSize of
           1: CaseInd := 16; // 4 -> 1   ARGB8 -> Gray8(Byte)
           2: CaseInd := 17; // 4 -> 2   ARGB8 -> Gray16(Word) with Shifting
           3: CaseInd := 18; // 4 -> 3   ARGB8 -> RGB8
           4: CaseInd := 22; // 4 -> 4   ARGB8 -> ARGB8 (integer -> integer)
           6: CaseInd := 20; // 4 -> 6   ARGB8 -> RGB16  with Shifting
           8: CaseInd := 21; // 4 -> 8   ARGB8 -> ARGB16 with Shifting

           else CaseInd := -1; // error
         end; // case ADstSM.SMDElSize of

         if (CaseInd = 17) or (CaseInd = 20) or (CaseInd = 21) then // byte -> word
         begin
           ShiftSize := APDstSM^.SMDNumBits - 8;
           Shift2    := max( 0, 8 - ShiftSize );
           ShiftMode := csmShiftLeftOr;
         end;

       end; // 4: begin // APSrcSM^.SMDElSize = 4

    6: begin // APSrcSM^.SMDElSize = 6
         case APDstSM^.SMDElSize of
           1: CaseInd := 25; // 6 -> 1   RGB16 -> Gray8(Byte)  with Shifting
           2: CaseInd := 26; // 6 -> 2   RGB16 -> Gray16(Word) with Shifting
           3: CaseInd := 27; // 6 -> 3   RGB16 ->   RGB8       with Shifting
           4: CaseInd := 28; // 6 -> 4   RGB16 ->  ARGB8       with Shifting
           6: CaseInd := 29; // 6 -> 6   RGB16 ->   RGB16      with Shifting
           8: CaseInd := 30; // 6 -> 8   RGB16 ->  ARGB16      with Shifting

           else CaseInd := -1; // error
         end; // case ADstSM.SMDElSize of

         if (AShiftMode = csmShiftAuto1) then
         begin
           if (CaseInd = 25) or (CaseInd = 27) or (CaseInd = 28) then // word -> byte
           begin
             ShiftSize := APSrcSM^.SMDNumBits - 8;
             ShiftMode := csmShiftRight;
           end else // caseInds=26,29,30  word -> word
           begin
             ShiftSize := APSrcSM^.SMDNumBits - APDstSM^.SMDNumBits;

             if ShiftSize < 0 then
             begin
               ShiftSize := -ShiftSize;
               Shift2    := max( 0, 8 - ShiftSize );
               ShiftMode := csmShiftLeftOR;
             end else if ShiftSize > 0 then
               ShiftMode := csmShiftRight
             else // ShiftSize = 0
               ShiftMode := csmNotDef;
           end; // else if CaseInd <> 13 then
         end; // if (AShiftMode = csmShiftAuto1) then

       end; // 6: begin // APSrcSM^.SMDElSize = 6

    8: case APDstSM^.SMDElSize of
         1: CaseInd := 25; // 8 -> 1  ARGB16 -> Gray8(Byte)  with Shifting
         2: CaseInd := 26; // 8 -> 2  ARGB16 -> Gray16(Word) with Shifting
         3: CaseInd := 27; // 8 -> 3  ARGB16 ->   RGB8       with Shifting
         4: CaseInd := 28; // 8 -> 4  ARGB16 ->  ARGB8       with Shifting
         6: CaseInd := 29; // 8 -> 6  ARGB16 ->   RGB16      with Shifting
         8: CaseInd := 33; // 8 -> 8  ARGB16 ->  ARGB16      with Shifting

         else CaseInd := -1; // error

         if (AShiftMode = csmShiftAuto1) then
         begin
           if (CaseInd = 25) or (CaseInd = 27) or (CaseInd = 28) then // word -> byte
           begin
             ShiftSize := APSrcSM^.SMDNumBits - 8;
             ShiftMode := csmShiftRight;
           end else // caseInds=26,29,33  word -> word
           begin
             ShiftSize := APSrcSM^.SMDNumBits - APDstSM^.SMDNumBits;

             if ShiftSize < 0 then
             begin
               ShiftSize := -ShiftSize;
               Shift2    := max( 0, 8 - ShiftSize );
               ShiftMode := csmShiftLeftOR;
             end else if ShiftSize > 0 then
               ShiftMode := csmShiftRight
             else // ShiftSize = 0
               ShiftMode := csmNotDef;
           end; // else if CaseInd <> 13 then
         end; // if (AShiftMode = csmShiftAuto1) then

       end; // 8: case ADstSM.SMDElSize of

    else CaseInd := -1; // error
  end; // case APSrcSM^.SMDElSize of

  Assert( CaseInd <> -1, 'Bad CaseInd = ' + IntToStr(CaseInd) ); //

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    case CaseInd of

    0: begin // 1 -> 1   Byte -> Byte without Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        PByte(PDstElem)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 0: begin // 1 -> 1   Byte -> Byte without Shifting

    1: begin // 1 -> 1   Byte -> Byte with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PByte(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 1: begin // 1 -> 1   Byte -> Byte with Shifting

    2: begin // 1 -> 2   Byte -> Word with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 2: begin // 1 -> 2   Byte -> Word with Shifting

    3: begin // 1 -> 3   Byte -> RGB8  without Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=3
        PByte(PDstElem+0)^ := PByte(PSrcElem)^;
        PByte(PDstElem+1)^ := PByte(PSrcElem)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 3: begin // 1 -> 3   Byte -> RGB8  without Shifting

    4: begin // 1 -> 4   Byte -> ARGB8 without Shifting (ARGBMode=0)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=3
        PInteger(PDstElem)^ := 0; // clear high byte
        PByte(PDstElem+0)^ := PByte(PSrcElem)^;
        PByte(PDstElem+1)^ := PByte(PSrcElem)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 4: begin // 1 -> 4   Byte -> ARGB8 without Shifting (ARGBMode=0)

    5: begin // 1 -> 4   Byte -> integer with Shifting  (ARGBMode=1)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PInteger(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 5: begin // 1 -> 4   Byte -> integer with Shifting  (ARGBMode=1)

    6: begin // 1 -> 6   Byte -> RGB16  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem+0)^ := CurElem;
        PWORD(PDstElem+2)^ := CurElem;
        PWORD(PDstElem+4)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 6: begin // 1 -> 6   Byte -> RGB16  with Shifting

    7: begin // 1 -> 8   Byte -> ARGB16 with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem+0)^ := CurElem;
        PWORD(PDstElem+2)^ := CurElem;
        PWORD(PDstElem+4)^ := CurElem;
        PWORD(PDstElem+6)^ := 0;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 7: begin // 1 -> 8   Byte -> ARGB16 with Shifting

    8: begin // 2 -> 1   Gray16 ->  Byte   with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PByte(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 8: begin // 2 -> 1   Gray16 ->  Byte   with Shifting

    9: begin // 2 -> 2   Gray16 -> Gray16  without Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        PWORD(PDstElem)^ := PWORD(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 9: begin // 2 -> 2   Gray16 -> Gray16  without Shifting

    10: begin // 2 -> 2   Gray16 -> Gray16  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 10: begin // 2 -> 2   Gray16 -> Gray16  with Shifting

    11: begin // 2 -> 3   Gray16 ->  RGB8   with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PByte(PDstElem+0)^ := CurElem;
        PByte(PDstElem+1)^ := CurElem;
        PByte(PDstElem+2)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 11: begin // 2 -> 3   Gray16 ->  RGB8   with Shifting

    12: begin // 2 -> 4   Gray16 ->  ARGB8  with Shifting (ARGBMode=0)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PInteger(PDstElem+0)^ := 0; // clear high Byte
        PByte(PDstElem+0)^ := CurElem;
        PByte(PDstElem+1)^ := CurElem;
        PByte(PDstElem+2)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 12: begin // 2 -> 4   Gray16 ->  ARGB8  with Shifting (ARGBMode=0)

    13: begin // 2 -> 4   Gray16 -> integer with Shifting (ARGBMode=1)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PInteger(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 13: begin // 2 -> 4   Gray16 -> integer with Shifting (ARGBMode=1)

    14: begin // 2 -> 6   Gray16 ->  RGB16  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem+0)^ := CurElem;
        PWORD(PDstElem+2)^ := CurElem;
        PWORD(PDstElem+4)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 14: begin // 2 -> 6   Gray16 ->  RGB16  with Shifting

  // 15 - 2 -> 8   Gray16 -> ARGB16  with Shifting

    15: begin // 2 -> 8   Gray16 -> ARGB16  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^;

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem+0)^ := CurElem;
        PWORD(PDstElem+2)^ := CurElem;
        PWORD(PDstElem+4)^ := CurElem;
        PWORD(PDstElem+6)^ := 0;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 15: begin // 2 -> 8   Gray16 -> ARGB16  with Shifting

    16: begin // 3 -> 1   RGB8 -> Gray8(Byte)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        PByte(PDstElem)^ := Round( 0.114*PByte(PSrcElem)^   +  // Blue
                                   0.587*PByte(PSrcElem+1)^ +  // Green
                                   0.299*PByte(PSrcElem+2)^ ); // Red

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 16: begin // 3 -> 1   RGB8 -> Gray8(Byte)

    17: begin // 3 -> 2   RGB8 -> Gray16(Word) with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := Round( 0.114*PByte(PSrcElem)^   +  // Blue
                          0.587*PByte(PSrcElem+1)^ +  // Green
                          0.299*PByte(PSrcElem+2)^ ); // Red

        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 17: begin // 3 -> 2   RGB8 -> Gray16(Word) with Shifting

    18: begin // 3 -> 3   RGB8 -> RGB8
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=3,4  DstElemSize=3  copy three bytes
        PWord(PDstElem)^   := PWord(PSrcElem)^;
        PByte(PDstElem+2)^ := PByte(PSrcElem+2)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 18: begin // 3 -> 3   RGB8 -> RGB8

    19: begin // 3 -> 4   RGB8 -> ARGB8
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=3,4  DstElemSize=4  copy three bytes and clear fourth byte
        PWord(PDstElem)^   := PWord(PSrcElem)^;
        PWord(PDstElem+2)^ := PByte(PSrcElem+2)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 19: begin // 3 -> 4   RGB8 -> ARGB8

    20: begin // 3 -> 6   RGB8 -> RGB16  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem)^ := CurElem; // Blue

        CurElem := PByte(PSrcElem+1)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+2)^ := CurElem; // Green

        CurElem := PByte(PSrcElem+2)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+4)^ := CurElem; // Red

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 20: begin // 3 -> 6   RGB8 -> RGB16  with Shifting

    21: begin // 3 -> 8   RGB8 -> ARGB16 with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PByte(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem)^ := CurElem; // Blue

        CurElem := PByte(PSrcElem+1)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+2)^ := CurElem; // Green

        CurElem := PByte(PSrcElem+2)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+4)^ := CurElem; // Red

        PWORD(PDstElem+6)^ := 0; // A value

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 21: begin // 3 -> 8   RGB8 -> ARGB16 with Shifting

    22: begin // 4 -> 4   ARGB8 -> ARGB8 (integer -> integer)
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=4, DstElemSize=4
        PInteger(PDstElem)^ := PInteger(PSrcElem)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 22: begin // 4 -> 4   ARGB8 -> ARGB8 (integer -> integer)

    25: begin // 6 -> 1   RGB16 -> Gray8(Byte)  with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem :=  Round( 0.114*PWORD(PSrcElem)^   +  // Blue
                           0.587*PWORD(PSrcElem+2)^ +  // Green
                           0.299*PWORD(PSrcElem+4)^ ); // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PByte(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 25: begin // 6 -> 1   RGB16 -> Gray8(Byte)  with Shifting

    26: begin // 6 -> 2   RGB16 -> Gray16(Word) with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := Round( 0.114*PWORD(PSrcElem)^   +  // Blue
                          0.587*PWORD(PSrcElem+2)^ +  // Green
                          0.299*PWORD(PSrcElem+4)^ ); // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;

        PWORD(PDstElem)^ := CurElem;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 26: begin // 6 -> 2   RGB16 -> Gray16(Word) with Shifting

    27: begin // 6 -> 3   RGB16 ->   RGB8       with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem)^ := CurElem; // Blue

        CurElem := PWORD(PSrcElem+2)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem+1)^ := CurElem; // Green

        CurElem := PWORD(PSrcElem+4)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem+2)^ := CurElem; // Red

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 27: begin // 6 -> 3   RGB16 ->   RGB8       with Shifting

    28: begin // 6 -> 4   RGB16 ->  ARGB8       with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem)^ := CurElem; // Blue

        CurElem := PWORD(PSrcElem+2)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem+1)^ := CurElem; // Green

        CurElem := PWORD(PSrcElem+4)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PByte(PDstElem+2)^ := CurElem; // Red

        PByte(PDstElem+3)^ := 0; // A value

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 28: begin // 6 -> 4   RGB16 ->  ARGB8       with Shifting

    29: begin // 6 -> 6   RGB16 ->   RGB16      with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem)^ := CurElem; // Blue

        CurElem := PWORD(PSrcElem+2)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+2)^ := CurElem; // Green

        CurElem := PWORD(PSrcElem+4)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+4)^ := CurElem; // Red

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 29: begin // 6 -> 6   RGB16 ->   RGB16      with Shifting

    30: begin // 6 -> 8   RGB16 ->  ARGB16      with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem)^ := CurElem; // Blue

        CurElem := PWORD(PSrcElem+2)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+2)^ := CurElem; // Green

        CurElem := PWORD(PSrcElem+4)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+4)^ := CurElem; // Red

        PWORD(PDstElem+6)^ := 0; // A Value

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 30: begin // 6 -> 8   RGB16 ->  ARGB16      with Shifting

    33: begin // 8 -> 8  ARGB16 ->  ARGB16      with Shifting
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        CurElem := PWORD(PSrcElem)^; // Blue
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem)^ := CurElem; // Blue

        CurElem := PWORD(PSrcElem+2)^; // Green
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+2)^ := CurElem; // Green

        CurElem := PWORD(PSrcElem+4)^; // Red
        case ShiftMode of
        csmShiftRight:  CurElem := CurElem shr ShiftSize;
        csmShiftLeft:   CurElem := CurElem shl ShiftSize;
        csmShiftLeftOr: CurElem := (CurElem shl ShiftSize) or (CurElem shr Shift2);
        end;
        PWORD(PDstElem+4)^ := CurElem; // Red

        PWORD(PDstElem+6)^ := PWORD(PSrcElem+6)^; // A Value (without shifting)

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 33: begin // 8 -> 8  ARGB16 ->  ARGB16      with Shifting

    end; // case CaseInd of

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMCopyConv

//****************************************************** N_Conv2SMCopyShift ***
// Copy Shifted element of Src SubMatr to DstSubMatr
//
//     Parameters
// APSrcSM    - Source SubMatrix description
// APDstSM    - Destination SubMatrix description
// AShiftSize - abs Shift Size
// AShiftMode - Shift Mode (see TN_CopyShiftMode)
//
procedure N_Conv2SMCopyShift( APSrcSM, APDstSM: TN_PSMatrDescr;
                              AShiftSize: integer; AShiftMode: TN_CopyShiftMode );
var
  ix, iy, CaseIndSrc, CaseIndDst, CurElem, OrMask: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  // Prepare CaseIndSrc (CaseIndSrc - SrcSize -> *)
  // 0 - 1,3,4 -> * One byte Src (least byte for RGB8 color pixels)
  // 1 -   2   -> * Two bytes Src

  CaseIndSrc := 0; // to avoid warning
  case APSrcSM^.SMDElSize of
    1,3,4: CaseIndSrc := 0;
      2  : CaseIndSrc := 1;
    else Assert( False, 'Bad Src ElemSize in N_Conv2SMCopyShift' );
  end;

  // Prepare CaseIndDst (CaseIndDst - * -> DstSize)
  // 0 - * -> 1 One byte Dst
  // 1 - * -> 2 Two byte Dst
  // 2 - * -> 3,4 Three or Four byte RGB Dst (R=G=B)

  CaseIndDst := 0; // to avoid warning
  case APDstSM^.SMDElSize of
    1:   CaseIndDst := 0;
    2:   CaseIndDst := 1;
    3,4: CaseIndDst := 2;
    else Assert( False, 'Bad Dst ElemSize in N_Conv2SMCopyShift' );
  end;

  OrMask := K_Masks32[AShiftSize] shr 1; // (e.g. $03 for AShiftSize=2)
  CurElem := 0; // to avoid warning

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      case CaseIndSrc of
      0: CurElem := PByte(PSrcElem)^;
      1: CurElem := PWORD(PSrcElem)^;
      end;

      case AShiftMode of
      csmShiftRight:  CurElem := CurElem shr AShiftSize;
      csmShiftLeft:   CurElem := CurElem shl AShiftSize;
      csmShiftLeftOr: CurElem := (CurElem shl AShiftSize) or (CurElem and OrMask);
      end;

      case CaseIndDst of
      0: PByte(PDstElem)^ := CurElem;
      1: PWORD(PDstElem)^ := CurElem;
      2: begin // set three RGB bytes
           PByte(PDstElem+0)^ := CurElem;
           PByte(PDstElem+1)^ := CurElem;
           PByte(PDstElem+2)^ := CurElem;
         end;
      end;

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMCopyShift

//******************************************************** N_Conv2SMProcObj ***
// Convert SubMatr Elements by given Procedure of Object (two operands)
//
//     Parameters
// APSrcSM  - Pointer to Source SubMatrix description
// APDstSM  - Pointer to Destination SubMatrix description
// AProcObj - given Procedure of Object for one Element convertion
//
// AProcObj usage: AProcObj( APSrcElem, APDstElem );
//
procedure N_Conv2SMProcObj( APSrcSM, APDstSM: TN_PSMatrDescr; AProcObj: TN_TwoPtrsProcObj );
var
  ix, iy: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  if not Assigned( AProcObj ) then Exit; // a precaution
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      AProcObj( PSrcElem, PDstElem );

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv2SMProcObj

//*********************************************************** N_Conv2SMXLAT ***
// Convert SubMatr elements by given XLAT table (two operands)
//
//     Parameters
// APSrcSM   - Pointer to Source SubMatrix description
// APDstSM   - Pointer to Destination SubMatrix description
// APXLAT    - pointer to given integer XLAT Table
// AXLATType - Number of used bytes in one XLAT element (1 or 3)
//
// if Src ElemSize=1 XLAT Table has  256  elements,
// if Src ElemSize=2 XLAT Table has 2**16 elements,
// if Src ElemSize=3,4 XLAT Table has 256 elements (R,G,B values are converted by same XLAT Table),
//
// XLAT element size should be always 4 (integer)
// if AXLATType = 1

procedure N_Conv2SMXLAT( APSrcSM, APDstSM: TN_PSMatrDescr; APXLAT: PInteger; AXLATType: integer );
var
  ix, iy, CaseInd: integer;
  PSrcElem, PDstElem, CurPXLAT: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  if APXLAT = nil then Exit; // a precaution
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  // Prepare CaseInd (CaseInd - SrcSize -> DstSize), AXLATType = 1
  // 0 - 1 -> 1 XLAT(0..255->0..255)
  // 1 - 1 -> 2 XLAT(0..255->0..64K)
  // 2 - 1 -> 3 XLAT(0..255->0..RGB)
  // 3 - 1 -> 4 XLAT(0..255->0..RGB)
  // 4 - 2 -> 1 XLAT(0.. N ->0..255)
  // 5 - 2 -> 2 XLAT(0.. N ->0.. N )
  // 6 - 2 -> 3 XLAT(0.. N ->0..RGB)
  // 7 - 2 -> 4 XLAT(0.. N ->0..RGB)
  // 8 - 3,4 -> 3,4 // convert all three byte chanels by same XLAT Table

  //************************************************ AXLATType = 3
  // 9 - 3,4 -> 3,4 // convert all three byte chanels by three XLAT Tables
                    // one byte for each XLAT Table in one XLAT integer element

  if APSrcSM^.SMDElSize <= 2 then
  begin
    CaseInd := APDstSM^.SMDElSize - 1; // 0 <= CaseInd <= 3

    if APSrcSM^.SMDElSize = 2 then     // 4 <= CaseInd <= 7
      CaseInd := CaseInd + 4;

  end else // APSrcSM^.SMDElSize > 2
  begin
    Assert( APDstSM^.SMDElSize > 2, 'Bad DstSM ElSize!' );

    // 3,4 -> 3,4

    CaseInd := 8;
    if AXLATType = 3 then
      CaseInd := 9;
  end; // else // APSrcSM^.SMDElSize > 2

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    case CaseInd of

    0: begin // 1 -> 1
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=1
        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 0: begin // 1 -> 1

    1: begin // 1 -> 2
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=2
        PWord(PDstElem)^ := PWord( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 1: begin // 1 -> 2

    2: begin // 1 -> 3
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=3
        CurPXLAT := TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2);
        PWord(PDstElem)^   := PWord(CurPXLAT)^;
        PByte(PDstElem+2)^ := PByte(CurPXLAT+2)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 2: begin // 1 -> 3

    3: begin // 1 -> 4
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=1, DstElemSize=4
        PInteger(PDstElem)^ := PInteger( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 3: begin // 1 -> 4

    4: begin // 2 -> 1
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=1
        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PWord(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 4: begin // 2 -> 1

    5: begin // 2 -> 2
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=2
        PWord(PDstElem)^ := PWord( TN_BytesPtr(APXLAT) + (PWord(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 5: begin // 2 -> 2

    6: begin // 2 -> 3
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=3
        CurPXLAT := TN_BytesPtr(APXLAT) + (PWord(PSrcElem)^ shl 2);
        PWord(PDstElem)^   := PWord(CurPXLAT)^;
        PByte(PDstElem+2)^ := PByte(CurPXLAT+2)^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 6: begin // 2 -> 3

    7: begin // 2 -> 4
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=2, DstElemSize=4
        PInteger(PDstElem)^ := PInteger( TN_BytesPtr(APXLAT) + (PWord(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row
    end; // 7: begin // 2 -> 4

    8: begin // 3,4 -> 3,4 one XLAT Table
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=3,4, DstElemSize=3,4 // convert three bytes one by one
                                            // by the same XLAT Table
        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;
        Inc( PSrcElem ); Inc( PDstElem );

        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;
        Inc( PSrcElem ); Inc( PDstElem );

        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX - 2; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX - 2; // to next Dst Element in Row
      end; // for ix := 0 to WNX-1 do // along all elems in cur Row
    end; // 8: begin // 3,4 -> 3,4 one XLAT Table

    9: begin // 3,4 -> 3,4 three XLAT Tables in one integer Array
      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        // SrcElemSize=3,4, DstElemSize=3,4 // convert three bytes one by one
                                            // by three different XLAT Tables
        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + (PByte(PSrcElem)^ shl 2) )^;
        Inc( PSrcElem ); Inc( PDstElem );

        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + 1 + (PByte(PSrcElem)^ shl 2) )^;
        Inc( PSrcElem ); Inc( PDstElem );

        PByte(PDstElem)^ := PByte( TN_BytesPtr(APXLAT) + 2 + (PByte(PSrcElem)^ shl 2) )^;

        PSrcElem := PSrcElem + WSrcStepX - 2; // to next Src Element in Row
        PDstElem := PDstElem + WDstStepX - 2; // to next Dst Element in Row
      end; // for ix := 0 to WNX-1 do // along all elems in cur Row
    end; // 9: begin // 3,4 -> 3,4 three XLAT Tables

    end; // case CaseInd of

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to WNY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv2SMXLAT

//********************************************************* N_Conv2SMToGray ***
// Convert 3 or 4 bytes Color SubMatr to Gray
//
//     Parameters
// APSrcSM - Pointer to Source (Color) SubMatrix description
// APDstSM - Pointer to Destination (Resulting) SubMatrix description
//
// Resulting APDstSM SubMatr can have any Element Size. If its Element Size = 3 or 4
// all three RGB bytes are set to same calculated value
//
procedure N_Conv2SMToGray( APSrcSM, APDstSM: TN_PSMatrDescr );
var
  ix, iy, GrayVal: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  if APSrcSM^.SMDElSize < 3 then Exit; // a precaution

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      GrayVal := Round( 0.114*PByte(PSrcElem)^   +  // Blue
                        0.587*PByte(PSrcElem+1)^ +  // Green
                        0.299*PByte(PSrcElem+2)^ ); // Red

      case APDstSM^.SMDElSize of
        1: PByte(PDstElem)^ := Byte(GrayVal);
//        2: PWord(PDstElem)^ := Word(GrayVal shl 8);
        2:
        begin
          PByte(PDstElem)^ := GrayVal;
          PByte(PDstElem + 1)^ := GrayVal;
        end;
        3,4:
        begin
          PByte(PDstElem+0)^ := Byte(GrayVal);
          PByte(PDstElem+1)^ := Byte(GrayVal);
          PByte(PDstElem+2)^ := Byte(GrayVal);
        end;
      end; // case APDstSM^.SMDElSize of

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMToGray

//********************************************************* N_Conv2SMEmboss ***
// Old variant, not needed
// Emboss Src GrayScale SubMatr (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination (resulting) SubMatrix description
// ADelta  - given X,Y Delta between points to process
// AMinMax - Destination (resulting) SubMatrix Min and Max Elements value (AMinMax.X <= AMinMax.Y)
//
// Both Src and Dst Submatrixes should have same Sizes and can have any Element Size.
// If Src Element Size = 3 or 4 the are converted to Gray
// If Dst Element Size = 3 or 4 all three RGB bytes are set to same calculated value
//
procedure N_Conv2SMEmboss( APSrcSM, APDstSM: TN_PSMatrDescr; ADelta: TPoint;
                                                      out AMin, AMax: integer );
var
  ix, iy, ix2, iy2: integer;
  PSrcElem, PDstElem, PSrcElem2: TN_BytesPtr;
  ResByte, GrayVal1, GrayVal2: Byte;
  OutOfMatrX, OutOfMatrY: boolean;
  WVars: TN_ConvSMVars;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );
  AMin := 255;
  AMax := 0;

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    iy2 := iy + APSrcSM^.SMDBegIY + ADelta.Y;
    OutOfMatrY := (iy2 < 0) or (iy2 >= APSrcSM^.SMDNumY);

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      ix2 := ix + APSrcSM^.SMDBegIX + ADelta.X;
      OutOfMatrX := OutOfMatrY or (ix2 < 0) or (ix2 >= APSrcSM^.SMDNumX);

      ResByte := 128; // value for OutOfMatr = True

      if not OutOfMatrX then // PSrcElem2 is inside whole Matrix
      begin
        PSrcElem2 := PSrcElem + ADelta.X*WSrcStepX + ADelta.Y*WSrcStepY;

        case APSrcSM^.SMDElSize of
          1: ResByte := (255 + PByte(PSrcElem)^ - PByte(PSrcElem2)^) div 2;
//          2: ResByte := (255 + (PWord(PSrcElem)^ shr 8) - (PWord(PSrcElem2)^ shr 8)) div 2;
          2: ResByte := (255 + PByte(PSrcElem + 1)^ - PByte(PSrcElem2 + 1)^) div 2;
          3,4: // TrueColor Source Matrix
          begin
            GrayVal1 := Round( 0.114*PByte(PSrcElem)^   +  // Blue
                               0.587*PByte(PSrcElem+1)^ +  // Green
                               0.299*PByte(PSrcElem+2)^ ); // Red

            GrayVal2 := Round( 0.114*PByte(PSrcElem2)^   +  // Blue
                               0.587*PByte(PSrcElem2+1)^ +  // Green
                               0.299*PByte(PSrcElem2+2)^ ); // Red
            ResByte := (255 + GrayVal1 - GrayVal2) div 2;
          end; // 3,4: // TrueColor Source Matrix
        end; // case APSrcSM^.SMDElSize of
      end; // if not OutOfMatr then // PSrcElem2 is inside whole Matrix

      //***** ResByte is OK, write it to Dst SMatr and calc AMinMax

      case APDstSM^.SMDElSize of
        1: PByte(PDstElem)^ := ResByte;
//        2: PWord(PDstElem)^ := ResByte shl 8;
        2:
        begin
          PByte(PDstElem)^ := ResByte;     // Set Low Byte
          PByte(PDstElem + 1)^ := ResByte; // Set High Byte
        end; // 2 Byte Elem Dst Matrix
        3,4: // TrueColor Dst Matrix
        begin
          PByte(PDstElem)^   := ResByte;
          PByte(PDstElem+1)^ := ResByte;
          PByte(PDstElem+2)^ := ResByte;
        end; // 3,4: // TrueColor Dst Matrix
      end; // case APDstSM^.SMDElSize of

      if ResByte < AMin then AMin := ResByte; // Min Value
      if ResByte > AMax then AMax := ResByte; // Max Value

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMEmboss

//******************************************************** N_Conv2SMEmboss2 ***
// Emboss Src SubMatr
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination (resulting) SubMatrix description
// ADelta  - given X,Y Delta between points to process
// APXLAT  - pointer to given integer XLAT Table of 511 elements in (0,255) range
//
// Short Alrorithm description.
// Let P1, P1 - two such points that current point CP
// is in the middle of (P1,P2) and (P2-P1)=ADelta.
//
// TmpValue = 255 + Value(P2) - Value(P1) (0 <= TmpValue <= 510)
// Resulting Value(CP) = APXLAT^[TmpValue] (0 <= Value(CP) <= 255)
//
// Both Src and Dst Submatrixes should have same Sizes and can have any Element Size.
// If Src Element Size = 3 or 4 elements are converted to Gray
// If Dst Element Size = 3 or 4 all three Dst RGB bytes are set to same calculated value
//
procedure N_Conv2SMEmboss2( APSrcSM, APDstSM: TN_PSMatrDescr; ADelta: TPoint;
                                                              APXLAT: PInteger );
var
  ix, iy, ix1, iy1, ix2, iy2, SrcShift, DstShift : integer;
  TmpValue, ValueCP, ValueP1, ValueP2, dx1, dx2, dy1, dy2: integer;
  PSrcElem, PDstElem, PSrcElem1, PSrcElem2: TN_BytesPtr;
  PResInt: PInteger;
  ResByte: Byte;
  OutOfMatrX1, OutOfMatrY1, OutOfMatrX2, OutOfMatrY2: boolean;
  WVars: TN_ConvSMVars;
begin
  ValueCP := 0; // to avoid warning

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars );

  //***** Used notation:
  // CP - current point, P1, P2 - points to get colors from
  // P1 = CP + (d1x,d1y)
  // P2 = CP + (d2x,d2y)
  // (P2-P1) = ADelta
  // CP = P1 + 0.5*(P2-P1)

  dx1 := abs(ADelta.X) div 2;
  dx2 := abs(ADelta.X) - dx1;

  if ADelta.X > 0 then
    dx1 := - dx1
  else
    dx2 := - dx2;

  dy1 := abs(ADelta.Y) div 2;
  dy2 := abs(ADelta.Y) - dy1;

  if ADelta.Y > 0 then
    dy1 := - dy1
  else
    dy2 := - dy2;

  //***** Here: dx1, dy1, dx2, dy2 are OK

  SrcShift := APSrcSM^.SMDNumBits - 8; // needed only if SMDElSize=2 (Src Image is Gray16)
  DstShift := APDstSM^.SMDNumBits - 8; // needed only if SMDElSize=2 (Dst Image is Gray16)

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    iy1 := iy + APSrcSM^.SMDBegIY + dy1;
    OutOfMatrY1 := (iy1 < 0) or (iy1 >= APSrcSM^.SMDNumY);

    iy2 := iy + APSrcSM^.SMDBegIY + dy2;
    OutOfMatrY2 := (iy2 < 0) or (iy2 >= APSrcSM^.SMDNumY);

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      ix1 := ix + APSrcSM^.SMDBegIX + dx1;
      OutOfMatrX1 := OutOfMatrY1 or (ix1 < 0) or (ix1 >= APSrcSM^.SMDNumX);

      ix2 := ix + APSrcSM^.SMDBegIX + dx2;
      OutOfMatrX2 := OutOfMatrY2 or (ix2 < 0) or (ix2 >= APSrcSM^.SMDNumX);

      //*** ValueCP wil be used as ValueP1 or ValueP2 if P1 or P2 are out of matr

      case APSrcSM^.SMDElSize of
        1: ValueCP := PByte(PSrcElem)^;
        2: ValueCP := PWord(PSrcElem)^ shr SrcShift;
        3,4: // TrueColor Source Matrix
        begin
          ValueCP := Round( 0.114*PByte(PSrcElem)^   +  // Blue
                            0.587*PByte(PSrcElem+1)^ +  // Green
                            0.299*PByte(PSrcElem+2)^ ); // Red
        end; // 3,4: // TrueColor Source Matrix
      end; // case APSrcSM^.SMDElSize of

      ValueP1 := ValueCP;
      if not OutOfMatrX1 then // P1 is inside whole Matrix
      begin
        PSrcElem1 := PSrcElem + dx1*WSrcStepX + dy1*WSrcStepY;

        case APSrcSM^.SMDElSize of
          1: ValueP1 := PByte(PSrcElem1)^;
          2: ValueP1 := PWord(PSrcElem1)^ shr SrcShift;
          3,4: // TrueColor Source Matrix
          begin
            ValueP1 := Round( 0.114*PByte(PSrcElem1)^   +  // Blue
                              0.587*PByte(PSrcElem1+1)^ +  // Green
                              0.299*PByte(PSrcElem1+2)^ ); // Red
          end; // 3,4: // TrueColor Source Matrix
        end; // case APSrcSM^.SMDElSize of
      end; // if not OutOfMatr then // P1 is inside whole Matrix

      ValueP2 := ValueCP;
      if not OutOfMatrX2 then // P2 is inside whole Matrix
      begin
        PSrcElem2 := PSrcElem + dx2*WSrcStepX + dy2*WSrcStepY;

        case APSrcSM^.SMDElSize of
          1: ValueP2 := PByte(PSrcElem2)^;
          2: ValueP2 := PWord(PSrcElem2)^ shr SrcShift;
          3,4: // TrueColor Source Matrix
          begin
            ValueP2 := Round( 0.114*PByte(PSrcElem2)^   +  // Blue
                              0.587*PByte(PSrcElem2+1)^ +  // Green
                              0.299*PByte(PSrcElem2+2)^ ); // Red
          end; // 3,4: // TrueColor Source Matrix
        end; // case APSrcSM^.SMDElSize of
      end; // if not OutOfMatr then // P2 is inside whole Matrix

      //***** Here: ValueP1, ValueP2 are OK

      TmpValue := 255 + ValueP2 - ValueP1; // in [0,510] range
//      if TmpValue < AMin then AMin := TmpValue; // Min Value
//      if TmpValue > AMax then AMax := TmpValue; // Max Value

      if APXLAT <> nil then // conv TmpValue by given APXLAT to ResByte
      begin
        PResInt := APXLAT;
        Inc( PResInt, TmpValue );
        ResByte := Byte(PResInt^);
      end else // APXLAT is not given
        ResByte := TmpValue  div 2; // TmpValue in [0,510], ResByte in [0,255] range

      //***** ResByte in [0,255] is OK, write it to Dst SMatr

      case APDstSM^.SMDElSize of
        1: PByte(PDstElem)^ := ResByte;
        2: PWord(PDstElem)^ := ResByte shl DstShift;
        3,4: // TrueColor Dst Matrix
        begin
          PByte(PDstElem)^   := ResByte;
          PByte(PDstElem+1)^ := ResByte;
          PByte(PDstElem+2)^ := ResByte;
        end; // 3,4: // TrueColor Dst Matrix
      end; // case APDstSM^.SMDElSize of

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMEmboss2

//********************************************************* N_Conv2SMbyMatr ***
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Matrix (coefficients are ready to use, no normalization is needed)
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatr( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  CurCoef: Float;
  WS1, WS2, WS3, SCSUM, AllSCSum: double;
  WVars: TN_ConvSMVars;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr


  PCurSrcElem := TN_BytesPtr(APCM);
  AllSCSum := 0;
  for kx := 1 to ACMDim * ACMDim do
  begin
    AllSCSum := AllSCSum  + PFloat(PCurSrcElem)^;
    PCurSrcElem := PCurSrcElem + SizeOf(Float);
  end;

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

//  N_Dump1Str(  'Start N_Conv2SMbyMatr' );
  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;

    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;

//if  (ix = 759) and (iy = 71) then
//N_i := 0;
//if  (ix = 759) and (iy = 71) then
      case CaseInd of

      0: begin // One byte Element (both Src and Dst)

           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WS1 := WS1 + PByte(PCurSrcElem)^ * PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             PByte(PDstElem)^ := Round( WS1 ); // One byte Dst Element
           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS and SCSUM are OK, calculate Dst element
             PByte(PDstElem)^ := Round( WS1/(AllSCSum-SCSUM) ); // One byte Dst Element
           end;

         end; // 0: begin // One byte Element (both Src and Dst)

      1: begin // Two bytes Element (both Src and Dst)
           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WS1 := WS1 + PWord(PCurSrcElem)^ * PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             PWord(PDstElem)^ := Round( WS1 ); // Two bytes Dst Element
           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PWord(PCurSrcElem)^*CurCoef; // Two bytes Src Element
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS and SCSUM are OK, calculate Dst element
             PWord(PDstElem)^ := Round( WS1/(AllSCSum-SCSUM) ); // Two bytes Dst Element
           end;

         end; // 1: begin // Two bytes Element (both Src and Dst)

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                 WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                 WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             PByte(PDstElem+0)^ := Round( WS1 ); // first  byte of Dst Element
             PByte(PDstElem+1)^ := Round( WS2 ); // second byte of Dst Element
             PByte(PDstElem+2)^ := Round( WS3 ); // third  byte of Dst Element
           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS, WS1, WS2 and SCSUM are OK, calculate Dst element
             PByte(PDstElem+0)^ := Round( WS1/(AllSCSum-SCSUM) ); // first  byte of Dst Element
             PByte(PDstElem+1)^ := Round( WS2/(AllSCSum-SCSUM) ); // second byte of Dst Element
             PByte(PDstElem+2)^ := Round( WS3/(AllSCSum-SCSUM) ); // third  byte of Dst Element
           end;

         end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of
//      if N_b2 then N_T1.SS( 'One loop' );

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows
//  N_Dump1Str(  'Fin N_Conv2SMbyMatr' );

  end; //with WVars do
end; // procedure N_Conv2SMbyMatr

//********************************************************* N_Conv2SMbyVector ***
// Convert (calculated weighted sum) given SubMatr by given Vector of coefficients
// (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Vector (coefficients are ready to use, no normalization is needed)
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyVector( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax, XBufStep: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow, PXBufElem: TN_BytesPtr;
  CurCoef: Float;
  WS1, WS2, WS3, SCSUM, AllSCSum: double;
  WVars: TN_ConvSMVars;
  XBuff1 : TN_FArray;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  PCurSrcElem := TN_BytesPtr(APCM);
  AllSCSum := 0;
  for kx := 1 to ACMDim do
  begin
    AllSCSum := AllSCSum  + PFloat(PCurSrcElem)^;
    PCurSrcElem := PCurSrcElem + SizeOf(Float);
  end;

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepY;

//  N_Dump1Str(  'Start N_Conv2SMbyMatr' );

  // Prepare XBuf Array
  XBufStep := APSrcSM^.SMDEndIX - APSrcSM^.SMDBegIX + 1; // Buffer Length
  if CaseInd = 2 then
  begin
  // Color Image
    SetLength( XBuff1, XBufStep * 3 );
    XBufStep := SizeOf(Float) * 3;
  end
  else
  begin
  // Grey Image
    SetLength( XBuff1, XBufStep );
    XBufStep := SizeOf(Float);
  end;

  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;
    PXBufElem := TN_BytesPtr(@XBuff1[0]);

    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)

        if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        begin
        // All Elems Inside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            WS1 := WS1 + PByte(PCurSrcRow)^*PFloat( TN_BytesPtr(APCM) + jy * SizeOf(Float) )^;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem)^ := WS1; // Float XBuf Element
        end // if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        else
        begin // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then
        // Some Elems Outside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            CurCoef := PFloat( TN_BytesPtr(APCM) + jy * SizeOf(Float) )^;
            ky := iy + jy;
            if (ky < HCMDIM) or (ky > kyMax) then // PCurSrcElem element is out of Matr
            begin
              SCSUM := SCSUM + CurCoef;
            end else // PCurSrcElem element is inside Matr
            begin
              WS1 := WS1 + PByte(PCurSrcRow)^*CurCoef;
            end;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem)^ := WS1/(AllSCSum-SCSUM); // Float XBuf Element
        end; // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then

      end; // 0: begin

      1: begin // Two bytes Element (both Src and Dst)

        if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        begin
        // All Elems Inside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            WS1 := WS1 + PWord(PCurSrcRow)^*PFloat( TN_BytesPtr(APCM) + jy * SizeOf(Float) )^;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem)^ := WS1; // Float XBuf Element
        end // if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        else
        begin // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then
        // Some Elems Outside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            CurCoef := PFloat( TN_BytesPtr(APCM) + jy*SizeOf(Float) )^;
            ky := iy + jy;
            if (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
            begin
              SCSUM := SCSUM + CurCoef;
            end else // PCurSrcElem element is inside Matr
            begin
              WS1 := WS1 + PWord(PCurSrcRow)^*CurCoef;
            end;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem)^ := WS1/(AllSCSum-SCSUM); // Float XBuf Element
        end; // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then

      end; // 1: begin

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

        if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        begin
        // All Elems Inside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            CurCoef := PFloat( TN_BytesPtr(APCM) + jy*SizeOf(Float) )^;
            WS1 := WS1 + PByte(PCurSrcRow+0)^*CurCoef;
            WS2 := WS2 + PByte(PCurSrcRow+1)^*CurCoef;
            WS3 := WS3 + PByte(PCurSrcRow+2)^*CurCoef;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem+0*SizeOf(Float))^ := WS1; // first  Float XBuf Element
          PFloat(PXBufElem+1*SizeOf(Float))^ := WS2; // second Float XBuf Element
          PFloat(PXBufElem+2*SizeOf(Float))^ := WS3; // third  Float XBuf Element
        end // if (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then
        else
        begin // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then
        // Some Elems Outside Loop
          for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
          begin
            CurCoef := PFloat( TN_BytesPtr(APCM) + jy*SizeOf(Float) )^;
            ky := iy + jy;
            if (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
            begin
              SCSUM := SCSUM + CurCoef;
            end else // PCurSrcElem element is inside Matr
            begin
              WS1 := WS1 + PByte(PCurSrcRow+0)^*CurCoef;
              WS2 := WS2 + PByte(PCurSrcRow+1)^*CurCoef;
              WS3 := WS3 + PByte(PCurSrcRow+2)^*CurCoef;
            end;
            PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
          end; // // for jy := 0 to ACMDim-1 do
          PFloat(PXBufElem+0*SizeOf(Float))^ := WS1/(AllSCSum-SCSUM); // first  Float XBuf Element
          PFloat(PXBufElem+1*SizeOf(Float))^ := WS2/(AllSCSum-SCSUM); // second Float XBuf Element
          PFloat(PXBufElem+2*SizeOf(Float))^ := WS3/(AllSCSum-SCSUM); // third  Float XBuf Element
        end; // if (iy < HCMDIM) or (iy > kyMax - ACMDim + 1) then

      end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PXBufElem := PXBufElem + XBufStep; // to next XBuf Element in Row
      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
    end; // for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do

    PXBufElem := TN_BytesPtr(@XBuff1[0]) - HCMDIM*XBufStep;
    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row XBUF
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcElem := PXBufElem;

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
      if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) then
      begin
      // All Elems Inside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
          WS1 := WS1 + PFloat(PCurSrcElem)^*PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PByte(PDstElem)^ := Round( WS1 ); // One byte Dst Element
      end
      else
      begin
      // Some Elems Outside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
         // get Coeff. value for PCurSrcElem Src Matr element
          CurCoef := PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          kx := ix + jx; // real index + HCMDIM
          if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
          begin
            SCSUM := SCSUM + CurCoef;
          end else // PCurSrcElem element is inside Matr
          begin
            WS1 := WS1 + PFloat(PCurSrcElem)^*CurCoef;
          end;

          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PByte(PDstElem)^ := Round( WS1/(AllSCSum-SCSUM) ); // One byte Dst Element
      end;
      end; // 0: begin

      1: begin // Two bytes Element (both Src and Dst)
      if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) then
      begin
      // All Elems Inside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
          WS1 := WS1 + PFloat(PCurSrcElem)^*PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PWord(PDstElem)^ := Round( WS1 ); // One Word Dst Element
      end
      else
      begin
      // Some Elems Outside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
         // get Coeff. value for PCurSrcElem Src Matr element
          CurCoef := PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          kx := ix + jx; // real index + HCMDIM
          if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
          begin
            SCSUM := SCSUM + CurCoef;
          end else // PCurSrcElem element is inside Matr
          begin
            WS1 := WS1 + PFloat(PCurSrcElem)^*CurCoef;
          end;
          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PWord(PDstElem)^ := Round( WS1/(AllSCSum-SCSUM) ); // One Word Dst Element
      end;
      end; // 1: begin

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
      if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) then
      begin
      // All Elems Inside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
         // get Coeff. value for PCurSrcElem Src Matr element
          CurCoef := PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          WS1 := WS1 + PFloat(PCurSrcElem+0*SizeOf(Float))^*CurCoef;
          WS2 := WS2 + PFloat(PCurSrcElem+1*SizeOf(Float))^*CurCoef;
          WS3 := WS3 + PFloat(PCurSrcElem+2*SizeOf(Float))^*CurCoef;
          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PByte(PDstElem+0)^ := Round( WS1 ); // first  byte of Dst Element
        PByte(PDstElem+1)^ := Round( WS2 ); // second byte of Dst Element
        PByte(PDstElem+2)^ := Round( WS3 ); // third  byte of Dst Element
      end
      else
      begin
      // Some Elems Outside Loop
        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
         // get Coeff. value for PCurSrcElem Src Matr element
          CurCoef := PFloat( TN_BytesPtr(APCM) + jx*SizeOf(Float) )^;
          kx := ix + jx; // real index + HCMDIM
          if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
          begin
            SCSUM := SCSUM + CurCoef;
          end else // PCurSrcElem element is inside Matr
          begin
            WS1 := WS1 + PFloat(PCurSrcElem+0*SizeOf(Float))^*CurCoef;
            WS2 := WS2 + PFloat(PCurSrcElem+1*SizeOf(Float))^*CurCoef;
            WS3 := WS3 + PFloat(PCurSrcElem+2*SizeOf(Float))^*CurCoef;
          end;

          PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        PByte(PDstElem+0)^ := Round( WS1/(AllSCSum-SCSUM) ); // first  byte of Dst Element
        PByte(PDstElem+1)^ := Round( WS2/(AllSCSum-SCSUM) ); // second byte of Dst Element
        PByte(PDstElem+2)^ := Round( WS3/(AllSCSum-SCSUM) ); // third  byte of Dst Element
      end;
      end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      PXBufElem := PXBufElem + XBufStep; // to next XBuf Element in Row
    end;

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMbyVector

//********************************************************** N_Conv2SMSlow1 ***
// Smoothing by Median or simple average with different border options, Variant #1
//
//     Parameters
// APSrcSM     - Pointer to Source SubMatrix description
// APDstSM     - Pointer to Destination SubMatrix description
// AApRadius   - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
// ABorderMode - how to treat pixels inside aperture windows but outside of matrix
// AConst      - Fill Constant for ABorderMode=fbmConst
// ASmoothMode - Smooth mode (0-average, 1-median, 2-const)
//
// Very slow variant for testing and comparison purposes
// Only one byte Matrixes are implemented
//
procedure N_Conv2SMSlow1( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer;
                          ABorderMode: TN_FillBorderMode; AConst, ASmoothMode: integer );
var
  WVars: TN_ConvSMVars;
  PCurDstElem: TN_BytesPtr;
  ix, iy, ix1, iy1, ix2, iy2, ix3, iy3, jx, jy, k, k1, NumApPixels: integer;
  Sum, CaseInd, ApSize: integer;
  Buf: TN_IArray;
  Val: byte;
begin
  Val := 0; // to avoid warning
  ApSize := 2*AApRadius + 1;     // ApSize (Aperture Size) is one dimensional size of square apperture
  NumApPixels := ApSize*ApSize;  // Whole number of pixels in Aperture window
  SetLength( Buf, NumApPixels ); // buf for sorting with all elems for current Aperture window

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  Assert( CaseInd=0, 'Conv2SMSlow1: Bad SMDElSize' ); // temporary implemented only for one byte elems
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  with WVars do
  begin

    for iy := 0 to WNY-1 do // along all Rows
    begin
      PCurDstElem := WPDstBegX;
      iy1 := iy - AApRadius;
      iy2 := iy + AApRadius;

      for ix := 0 to WNX-1 do // along all elems in current (iy-th) Row
      begin
        k := 0; // index in Buf array
        ix1 := ix - AApRadius;
        ix2 := ix + AApRadius;

        for jy := iy1 to iy2 do // along all aperture window Rows
        begin
          iy3 := jy; // iy3 is the nearest to jy and always inside SubMatr
          if iy3 < 0    then iy3 := 0;
          if iy3 >= WNY then iy3 := WNY-1;

          for jx := ix1 to ix2 do // along all elems in current (jy-th) aperture window Row
          begin
            ix3 := jx; // ix3 is the nearest to jx and always inside SubMatr
            if ix3 < 0    then ix3 := 0;
            if ix3 >= WNX then ix3 := WNX-1;

            if jx < 0 then // outside SubMatr, to the left
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all, to next elem in aperture window
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (WNX+jx)*APSrcSM^.SMDStepX)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY - (jx+1)*APSrcSM^.SMDStepX)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jx < 0 then // outside SubMatr, to the left

            if jx >= WNX then // outside SubMatr, to the right
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (WNX-1)*APSrcSM^.SMDStepX)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (jx-WNX)*APSrcSM^.SMDStepX)^;
                fbmMirror:      // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (2*WNX-jx-1)*APSrcSM^.SMDStepX)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jx >= WNX then // outside SubMatr, to the right

            if jy < 0 then // outside SubMatr, to the top
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (WNY+jy)*APSrcSM^.SMDStepY)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX - (jy+1)*APSrcSM^.SMDStepY)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jy < 0 then // outside SubMatr, to the top

            if jy >= WNY then // outside SubMatr, to the bottom
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (WNY-1)*APSrcSM^.SMDStepY)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (jy-WNY)*APSrcSM^.SMDStepY)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (2*WNY-jy-1)*APSrcSM^.SMDStepY)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jy >= WNY 0 then // outside SubMatr, to the bottom


            //***** Here: inside SubMatr (0<=jx<WNX), (0<=jy<WNY)

            Val := PByte(WPSrcBegX + (jy)*APSrcSM^.SMDStepY + (jx)*APSrcSM^.SMDStepX )^;

            Buf[k] := Val;
            Inc(k);
          end; // for jx := ix1 to ix2 do // along all elems in current (jy-th) aperture window Row
        end; // for jy := iy1 to iy2 do // along all aperture window Rows

        //***** Here: k is number of elems in Buf

        if ASmoothMode = 0 then // Calc average value (for all Buf elems)
        begin
          Sum := 0;
          for k1 := 0 to k-1 do
            Sum := Sum + Buf[k1];

          PByte(PCurDstElem)^ := Round( 1.0*Sum / k );
        end else if ASmoothMode = 1 then // calc median value (for all Buf elems)
        begin
          N_SortElements( TN_BytesPtr(@Buf[0]), k, SizeOf(integer), 0, N_CompareIntegers );
          PByte(PCurDstElem)^ := Buf[(k-1) div 2];
        end else // ASmoothMode=2, just fill by gray=128 (mainly for checking time)
        begin
          PByte(PCurDstElem)^ := 128;
        end;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // along all elems in current (iy-th) Row

      WPDstBegX := WPDstBegX + WSrcStepY;
    end; // along all Rows
  end; // with WVars do
end; // procedure N_Conv2SMSlow1

//********************************************************** N_Conv2SMSlow2 ***
// Smoothing by Median or simple average with different border options, Variant #2
//
//     Parameters
// APSrcSM     - Pointer to Source SubMatrix description
// APDstSM     - Pointer to Destination SubMatrix description
// AApRadius   - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
// ABorderMode - how to treat pixels inside aperture windows but outside of matrix
// AConst      - Fill Constant for ABorderMode=fbmConst
// ASmoothMode - Smooth mode (0-average, 1-median, 2-fill by AConst)
//
// Faster than Variant #1
// Only one byte Matrixes are implemented
//
procedure N_Conv2SMSlow2( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer;
                          ABorderMode: TN_FillBorderMode; AConst, ASmoothMode: integer );
var
  WVars: TN_ConvSMVars;
  PCurDstElem, PCurDstRow: TN_BytesPtr;
  PCurSrcElem, PCurSrcRow1, PCurSrcRow2, PCurSrcRow3: TN_BytesPtr;
  pBuf: PInteger;
  ix, iy, ix1, iy1, ix2, iy2, ix3, iy3, jx, jy, k, k1, NumApPixels: integer;
  Sum, CaseInd, ApSize: integer;
  Buf: TN_IArray;
  Val: byte;

  procedure CalcOneDstPixel (); // local
  var
    LPCurDstElem: TN_BytesPtr;
    Lk, k1, Sum: integer;
  begin
    LPCurDstElem := PCurDstElem;
    Lk := k;

    if ASmoothMode = 0 then // Calc average value (for all Buf elems)
    begin
      Sum := 0;
      for k1 := 0 to Lk-1 do
        Sum := Sum + Buf[k1];

      PByte(LPCurDstElem)^ := Round( 1.0*Sum / k );
    end else if ASmoothMode = 1 then // calc median value (for all Buf elems)
    begin
      N_SortElements( TN_BytesPtr(@Buf[0]), Lk, SizeOf(integer), 0, N_CompareIntegers );
      PByte(LPCurDstElem)^ := Buf[(Lk-1) div 2];
    end else // ASmoothMode=2, just fill by gray=128 (mainly for checking time)
    begin
      PByte(LPCurDstElem)^ := 128;
    end;

  end; // procedure CalcOneDstPixel (); // local

begin //*************************************** main body of N_Conv2SMSlow2
  Val := 0; // to avoid warning
  ApSize := 2*AApRadius + 1;     // ApSize (Aperture Size) is one dimensional size of square apperture
  NumApPixels := ApSize*ApSize;  // Whole number of pixels in Aperture window
  SetLength( Buf, NumApPixels ); // buf for sorting with all elems for current Aperture window

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  Assert( CaseInd=0, 'Conv2SMSlow1: Bad SMDElSize' ); // temporary implemented only for one byte elems
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  with WVars do
  begin

    //***** Part1 - Calc only border pixels

    for iy := 0 to WNY-1 do // along all Rows
    begin
      iy1 := iy - AApRadius;
      iy2 := iy + AApRadius;

      for ix := 0 to WNX-1 do // along all elems in current (iy-th) Row
      begin
        k := 0; // index in Buf array
        ix1 := ix - AApRadius;
        ix2 := ix + AApRadius;

        for jy := iy1 to iy2 do // along all aperture window Rows
        begin
          iy3 := jy; // iy3 is the nearest to jy and always inside SubMatr
          if iy3 < 0    then iy3 := 0;
          if iy3 >= WNY then iy3 := WNY-1;

          for jx := ix1 to ix2 do // along all elems in current (jy-th) aperture window Row
          begin
            ix3 := jx; // ix3 is the nearest to jx and always inside SubMatr
            if ix3 < 0    then ix3 := 0;
            if ix3 >= WNX then ix3 := WNX-1;

            if jx < 0 then // outside SubMatr, to the left
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all, to next elem in aperture window
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (WNX+jx)*APSrcSM^.SMDStepX)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY - (jx+1)*APSrcSM^.SMDStepX)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jx < 0 then // outside SubMatr, to the left

            if jx >= WNX then // outside SubMatr, to the right
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (WNX-1)*APSrcSM^.SMDStepX)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (jx-WNX)*APSrcSM^.SMDStepX)^;
                fbmMirror:      // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (iy3)*APSrcSM^.SMDStepY + (2*WNX-jx-1)*APSrcSM^.SMDStepX)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jx >= WNX then // outside SubMatr, to the right

            if jy < 0 then // outside SubMatr, to the top
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (WNY+jy)*APSrcSM^.SMDStepY)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX - (jy+1)*APSrcSM^.SMDStepY)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jy < 0 then // outside SubMatr, to the top

            if jy >= WNY then // outside SubMatr, to the bottom
            begin
              case ABorderMode of
                fbmNotFill: Continue; // do not fill at all
                fbmZero:    Val := 0; // fill by Zero
                fbmConst:   Val := AConst; // fill by given Constant
                fbmRepl1:      // fill by Replicating nearest pixel
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (WNY-1)*APSrcSM^.SMDStepY)^;
                fbmReplAll:    // fill by Replicating all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (jy-WNY)*APSrcSM^.SMDStepY)^;
                fbmMirror:     // by Mirroring all pixels
                   Val := PByte(WPSrcBegX + (ix3)*APSrcSM^.SMDStepX + (2*WNY-jy-1)*APSrcSM^.SMDStepY)^;
                else // a precaution
                   Val := 0;
              end; // case ABorderMode of

              Buf[k] := Val;
              Inc(k);
              Continue; // to next elem in aperture window
            end; // if jy >= WNY 0 then // outside SubMatr, to the bottom

            //***** Here: inside SubMatr (0<=jx<WNX), (0<=jy<WNY)
            //            nothing to do in Part1

          end; // for jx := ix1 to ix2 do // along all elems in current (jy-th) aperture window Row
        end; // for jy := iy1 to iy2 do // along all aperture window Rows

        //***** Here: k is number of elems in Buf, all elems in Buf are OK for (ix,iy) pixel
        //      Calc Dst pixel value by Buf

        if k = 0 then Continue; // skip internal pixels
        PCurDstElem := WPDstBegX + (iy)*APDstSM^.SMDStepY + (ix)*APDstSM^.SMDStepX;
        CalcOneDstPixel();

      end; // for ix := 0 to WNX-1 do // along all elems in current (iy-th) Row
    end; // for iy := 0 to WNY-1 do // along all Rows


    //***** Part2 - Calc remaining internal pixels, ( (jx,jy) is always inside submatr)

    PCurDstRow  := WPDstBegX;
    PCurSrcRow1 := WPSrcBegX;

    for iy := AApRadius to WNY-AApRadius-1 do // along all internal Rows
    begin
      PCurSrcRow2 := PCurSrcRow1;
      PCurDstElem := PCurDstRow;

      for ix := AApRadius to WNX-AApRadius-1 do // along all internal elems in current (iy-th) Row
      begin
        PCurSrcRow3 := PCurSrcRow2;
        pBuf := @Buf[0];

        for jy := 0 to ApSize-1 do // along all aperture window Rows
        begin
          PCurSrcElem := PCurSrcRow3;

          for jx := 0 to ApSize-1 do // along all elems in current (jy-th) aperture window Row
          begin
            pBuf^ := Integer(PCurSrcElem^);

            Inc( pBuf, 1 );
            Inc( PCurSrcElem, WSrcStepX );
          end; // for jx := ix1 to ix2 do // along all elems in current (jy-th) aperture window Row

          Inc( PCurSrcRow3, WSrcStepY );
        end; // for jy := iy1 to iy2 do // along all aperture window Rows


        //***** Here: all elems in Buf are OK for (ix,iy) pixel
        //            PCurDstElem is OK
        //            Calc Dst pixel value by Buf

        k := NumApPixels; // number of elems in Buf
        CalcOneDstPixel();

        Inc( PCurSrcRow2, WSrcStepX );
        Inc( PCurDstElem, WDstStepX );
      end; // for ix := AApRadius to WNX-AApRadius-1 do // along all internal elems in current (iy-th) Row

      Inc( PCurSrcRow1, WSrcStepY );
      Inc( PCurDstRow,  WSrcStepY );
    end; // for iy := AApRadius to WNY-AApRadius-1 do // along all internal Rows

  end; // with WVars do
end; // procedure N_Conv2SMSlow2

//*************************************************** N_Conv2SMAverageFast1 ***
// Fast smoothing by simple average with different border options
//
//     Parameters
// APSrcSM     - Pointer to Source SubMatrix description
// APDstSM     - Pointer to Destination SubMatrix description
// AApRadius   - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
// ABorderMode - how to treat pixels inside aperture windows but outside of matrix
//
// Only one byte Matrixes are implemented.
// The following variant of ABorderMode are implemented:
//   fbmNotFill, fbmRepl1, fbmMirror. All other variants ere treated as fbmZero.
//
procedure N_Conv2SMAverageFast1( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer;
                                 ABorderMode: TN_FillBorderMode );
var
  WVars: TN_ConvSMVars;
  PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  PCurDstRow: TN_BytesPtr;
  PCurSrcElemY1, PCurSrcElemY2: TN_BytesPtr;
  PCurSrcRowY1, PCurSrcRowY2: TN_BytesPtr;
  i, ix, iy, ApSize, NumApPixels, CurNumYSize: integer;
  CaseInd, NumElems: integer;
  RevCurNumPix, RevNumApPix: double;
  ColSums: TN_IArray;

  procedure CalcOneRow1Byte(); // local
  // Calc all pixels in One (current) iy-th row, One byte elements
  // The following local variables are used:
  //   PCurDstRow, CurNumYSize, RevCurNumPix and ColSums array
  //
  //   Example: AApSize=5, AApRadius=2, WNX=WNY=10, CurSum=CS
  //
  //       before - NotFill:CS=Sum(ColSums[0-2]), Repl1:CS=Sum(ColSums[0,0,0-2]), fbmMirror:CS=Sum(ColSums[1,0,0-2])
  // kx=0: Pix[0]=CS*Coef,  (Start loop)
  //       NotFill:CS=CS+ColSums[3], Repl1:CS=CS+ColSums[3]-ColSums[0], fbmMirror:CS=CS+ColSums[3]-ColSums[1]
  // kx=1: Pix[1]=CS*Coef,  (Start loop)
  //       NotFill:CS=CS+ColSums[4], Repl1:CS=CS+ColSums[4]-ColSums[0], fbmMirror:CS=CS+ColSums[4]-ColSums[0]
  //
  // kx=2: before CS=Sum(ColSums[0-4]), Pix[2]=CS*Coef, CS=CS+ColSums[5]-ColSums[0] (middle loop)
  // kx=3: before CS=Sum(ColSums[1-5]), Pix[3]=CS*Coef, CS=CS+ColSums[6]-ColSums[1] (middle loop)
  // kx=4: before CS=Sum(ColSums[2-6]), Pix[4]=CS*Coef, CS=CS+ColSums[7]-ColSums[2] (middle loop)
  // kx=5: before CS=Sum(ColSums[3-7]), Pix[5]=CS*Coef, CS=CS+ColSums[8]-ColSums[3] (middle loop)
  // kx=6: before CS=Sum(ColSums[4-8]), Pix[6]=CS*Coef, CS=CS+ColSums[9]-ColSums[4] (middle loop)
  //
  // kx=7: before CS=Sum(ColSums[5-9]), Pix[7]=CS*Coef,  (last loop)
  //       NotFill:CS=CS-ColSums[5], Repl1:CS=CS+ColSums[WNX-1]-ColSums[5], fbmMirror:CS=CS+ColSums[WNX-1]-ColSums[5]
  // kx=8: Pix[8]=CS*Coef, (last loop)
  //       NotFill:CS=CS-ColSums[6], Repl1:CS=CS+ColSums[WNX-1]-ColSums[6], fbmMirror:CS=CS+ColSums[WNX-2]-ColSums[6]
  // kx=9: Pix[9]=CS*Coef, CS remains the same (Last Row) (last loop)
var
  kx, LApSize, LApRadius, LkxLast, LWDstStepX: integer;
  CurSum, LRevCurNumPix: double;
  PCurDstElem: TN_BytesPtr;
  begin //********** main body of local procedure CalcOneRow1Byte
    with WVars do
    begin
    PCurDstElem := PCurDstRow;
    CurSum := 0;

    LApSize := ApSize; // use local variable for optimization
    LApRadius := AApRadius;
    LWDstStepX := WDstStepX;
    LRevCurNumPix := RevCurNumPix;

    //***** Prepare CurSum for initial (zero) pixel in current Dst (iy-th) row

    for kx := 0 to LApRadius do // along first AApRadius+1 elems in ColSums array
    begin
      CurSum := CurSum + ColSums[kx];
    end; // for kx := 0 to AApRadius do // along first AApRadius+1 elems in ColSums array

    //*** Here In ExampleCurSum = sum of ColSums[0,1,2)
    //    Update CurSum for ABorderMode=fbmRepl1 and fbmMirror

    case ABorderMode of
      fbmNotFill: begin end; // do not fill at all, do nothing

      fbmRepl1: begin // fill by Replicating nearest pixel
        CurSum := CurSum + ColSums[0]*LApRadius;
      end; // fbmRepl1: begin // fill by Replicating nearest pixel

      fbmMirror: begin // by Mirroring all pixels
        CurSum := 2*CurSum - ColSums[LApRadius];
      end; // fbmMirror: begin // by Mirroring all pixels

      else begin // fill by Zero, do nothing
      end; // else begin // fill by Zero, do nothing
    end; // case ABorderMode of


    //***** CurSum is OK for initial (zero) pixel in current Dst (iy-th) row
    //      Calc first LApRadius pixels in current Dst (iy-th) row
    //      (first loop in Example, kx=0,1)

    for kx := 0 to LApRadius-1 do // along first LApRadius pixels in current Dst (iy-th) row
    begin
      if ABorderMode = fbmNotFill then // CurSum is sum of (LApRadius+1+kx)*(LApRadius+1+iy) elements
      begin
        NumElems := (LApRadius+1+kx) * CurNumYSize; // CurNumYSize was set in main body
        PByte(PCurDstElem)^ := Round( CurSum / NumElems );
        CurSum := CurSum + ColSums[kx+LApRadius+1]; // update CurSum for next Pixel
      end else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements
      begin
        PByte(PCurDstElem)^ := Round( CurSum*RevNumApPix ); // RevNumApPix=1.0/NumApPixels

        case ABorderMode of
          fbmRepl1: begin // fill by Replicating nearest pixel
            CurSum := CurSum + ColSums[LApRadius+kx+1] - ColSums[0];
          end; // fbmRepl1: begin // fill by Replicating nearest pixel

          fbmMirror: begin // by Mirroring all pixels
            CurSum := CurSum + ColSums[LApRadius+kx+1] - ColSums[LApRadius-kx-1];
          end; // fbmMirror: begin // by Mirroring all pixels

          else begin // fill by Zero, do nothing
          end; // else begin // fill by Zero, do nothing
        end; // case ABorderMode of
      end; // else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements

      Inc( PCurDstElem, WDstStepX ); // to next pixel in Dst current Row
    end; // for kx := 0 to LApRadius-1 do // along first LApRadius pixels in current Dst (iy-th) row


    //***** CurSum is OK for first LApRadius pixel in current (iy-th) row
    //      Calc middle pixels in current Dst (iy-th) row
    //      (middle loop in Example, kx=2,3,4,5,6)

    LkxLast := WNX - LApSize - 1;
    for kx := 0 to LkxLast do // middle pixels in current Dst (iy-th) row
    begin
      PByte(PCurDstElem)^ := Round( CurSum*LRevCurNumPix ); // RevCurNumPix was set in main body
      CurSum := (ColSums[kx+LApSize] - ColSums[kx]) + CurSum;
      Inc( PCurDstElem, LWDstStepX ); // to next pixel in Dst current Row
    end; // for kx := LApRadius to WNX-LApRadius-2 do // middle pixels in current Dst (iy-th) row


    //***** CurSum is OK for WNX-LApRadius pixel in current (iy-th) row
    //      Calc last (LApRadius+1) pixels in current Dst (iy-th) row
    //      (last loop in Example, kx=7,8,9)

    for kx := WNX-LApRadius-1 to WNX-1 do // along last (LApRadius+1) pixels in current Dst (iy-th) row
    begin
      if ABorderMode = fbmNotFill then // CurSum is sum of LApRadius+1+ix elements
      begin
        NumElems := (LApRadius+WNX-kx) * CurNumYSize; // CurNumYSize was set in main body
        PByte(PCurDstElem)^ := Round( CurSum / NumElems );

        if kx <> (WNX-1) then // not last pixel
        begin
          CurSum := CurSum - ColSums[kx-LApRadius]; // update CurSum for next Pixel
        end; // if kx <> (WNX-1) then // not last pixel
      end else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements
      begin
        PByte(PCurDstElem)^ := Round( CurSum*RevNumApPix ); // RevNumApPix=1.0/NumApPixels

        if kx <> (WNX-1) then // not last pixel
        begin
          case ABorderMode of
            fbmNotFill: begin end; // do not fill at all, do nothing

            fbmRepl1: begin // fill by Replicating nearest pixel
              CurSum := CurSum + ColSums[WNX-1] - ColSums[kx-LApRadius];
            end; // fbmRepl1: begin // fill by Replicating nearest pixel

            fbmMirror: begin // by Mirroring all pixels
              CurSum := CurSum + ColSums[2*WNX-LApRadius-kx-2] - ColSums[kx-LApRadius];
            end; // fbmMirror: begin // by Mirroring all pixels

            else begin // fill by Zero, do nothing
            end; // else begin // fill by Zero, do nothing
          end; // case ABorderMode of
        end; // if kx <> (WNX-1) then // not last pixel
      end; // else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements

      Inc( PCurDstElem, WDstStepX ); // to next pixel in Dst current Row
    end; // for kx := WNX-LApRadius-1 to WNX-1 do // along last (LApRadius+1) pixels in current Dst (iy-th) row

    end; // with WVars do
  end; // procedure CalcOneRow1Byte(); // local

  procedure CalcOneRow2Byte(); // local
  // Calc all pixels in One (current) iy-th row, Two bytes elements
  // The following local variables are used:
  //   PCurDstRow, CurNumYSize, RevCurNumPix and ColSums array
  //
  //   Example: AApSize=5, AApRadius=2, WNX=WNY=10, CurSum=CS
  //
  //       before - NotFill:CS=Sum(ColSums[0-2]), Repl1:CS=Sum(ColSums[0,0,0-2]), fbmMirror:CS=Sum(ColSums[1,0,0-2])
  // kx=0: Pix[0]=CS*Coef,  (Start loop)
  //       NotFill:CS=CS+ColSums[3], Repl1:CS=CS+ColSums[3]-ColSums[0], fbmMirror:CS=CS+ColSums[3]-ColSums[1]
  // kx=1: Pix[1]=CS*Coef,  (Start loop)
  //       NotFill:CS=CS+ColSums[4], Repl1:CS=CS+ColSums[4]-ColSums[0], fbmMirror:CS=CS+ColSums[4]-ColSums[0]
  //
  // kx=2: before CS=Sum(ColSums[0-4]), Pix[2]=CS*Coef, CS=CS+ColSums[5]-ColSums[0] (middle loop)
  // kx=3: before CS=Sum(ColSums[1-5]), Pix[3]=CS*Coef, CS=CS+ColSums[6]-ColSums[1] (middle loop)
  // kx=4: before CS=Sum(ColSums[2-6]), Pix[4]=CS*Coef, CS=CS+ColSums[7]-ColSums[2] (middle loop)
  // kx=5: before CS=Sum(ColSums[3-7]), Pix[5]=CS*Coef, CS=CS+ColSums[8]-ColSums[3] (middle loop)
  // kx=6: before CS=Sum(ColSums[4-8]), Pix[6]=CS*Coef, CS=CS+ColSums[9]-ColSums[4] (middle loop)
  //
  // kx=7: before CS=Sum(ColSums[5-9]), Pix[7]=CS*Coef,  (last loop)
  //       NotFill:CS=CS-ColSums[5], Repl1:CS=CS+ColSums[WNX-1]-ColSums[5], fbmMirror:CS=CS+ColSums[WNX-1]-ColSums[5]
  // kx=8: Pix[8]=CS*Coef, (last loop)
  //       NotFill:CS=CS-ColSums[6], Repl1:CS=CS+ColSums[WNX-1]-ColSums[6], fbmMirror:CS=CS+ColSums[WNX-2]-ColSums[6]
  // kx=9: Pix[9]=CS*Coef, CS remains the same (Last Row) (last loop)
var
  kx, LApSize, LApRadius, LkxLast, LWDstStepX: integer;
  CurSum, LRevCurNumPix: double;
  PCurDstElem: TN_BytesPtr;
  begin //********** main body of local procedure CalcOneRow2Byte
    with WVars do
    begin
    PCurDstElem := PCurDstRow;
    CurSum := 0;

    LApSize := ApSize; // use local variable for optimization
    LApRadius := AApRadius;
    LWDstStepX := WDstStepX;
    LRevCurNumPix := RevCurNumPix;

    //***** Prepare CurSum for initial (zero) pixel in current Dst (iy-th) row

    for kx := 0 to LApRadius do // along first AApRadius+1 elems in ColSums array
    begin
      CurSum := CurSum + ColSums[kx];
    end; // for kx := 0 to AApRadius do // along first AApRadius+1 elems in ColSums array

    //*** Here In ExampleCurSum = sum of ColSums[0,1,2)
    //    Update CurSum for ABorderMode=fbmRepl1 and fbmMirror

    case ABorderMode of
      fbmNotFill: begin end; // do not fill at all, do nothing

      fbmRepl1: begin // fill by Replicating nearest pixel
        CurSum := CurSum + ColSums[0]*LApRadius;
      end; // fbmRepl1: begin // fill by Replicating nearest pixel

      fbmMirror: begin // by Mirroring all pixels
        CurSum := 2*CurSum - ColSums[LApRadius];
      end; // fbmMirror: begin // by Mirroring all pixels

      else begin // fill by Zero, do nothing
      end; // else begin // fill by Zero, do nothing
    end; // case ABorderMode of


    //***** CurSum is OK for initial (zero) pixel in current Dst (iy-th) row
    //      Calc first LApRadius pixels in current Dst (iy-th) row
    //      (first loop in Example, kx=0,1)

    for kx := 0 to LApRadius-1 do // along first LApRadius pixels in current Dst (iy-th) row
    begin
      if ABorderMode = fbmNotFill then // CurSum is sum of (LApRadius+1+kx)*(LApRadius+1+iy) elements
      begin
        NumElems := (LApRadius+1+kx) * CurNumYSize; // CurNumYSize was set in main body
        PWORD(PCurDstElem)^ := Round( CurSum / NumElems );
        CurSum := CurSum + ColSums[kx+LApRadius+1]; // update CurSum for next Pixel
      end else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements
      begin
        PWORD(PCurDstElem)^ := Round( CurSum*RevNumApPix ); // RevNumApPix=1.0/NumApPixels

        case ABorderMode of
          fbmRepl1: begin // fill by Replicating nearest pixel
            CurSum := CurSum + ColSums[LApRadius+kx+1] - ColSums[0];
          end; // fbmRepl1: begin // fill by Replicating nearest pixel

          fbmMirror: begin // by Mirroring all pixels
            CurSum := CurSum + ColSums[LApRadius+kx+1] - ColSums[LApRadius-kx-1];
          end; // fbmMirror: begin // by Mirroring all pixels

          else begin // fill by Zero, do nothing
          end; // else begin // fill by Zero, do nothing
        end; // case ABorderMode of
      end; // else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements

      Inc( PCurDstElem, WDstStepX ); // to next pixel in Dst current Row
    end; // for kx := 0 to LApRadius-1 do // along first LApRadius pixels in current Dst (iy-th) row


    //***** CurSum is OK for first LApRadius pixel in current (iy-th) row
    //      Calc middle pixels in current Dst (iy-th) row
    //      (middle loop in Example, kx=2,3,4,5,6)

    LkxLast := WNX - LApSize - 1;
    for kx := 0 to LkxLast do // middle pixels in current Dst (iy-th) row
    begin
      PWORD(PCurDstElem)^ := Round( CurSum*LRevCurNumPix ); // RevCurNumPix was set in main body
      CurSum := (ColSums[kx+LApSize] - ColSums[kx]) + CurSum;
      Inc( PCurDstElem, LWDstStepX ); // to next pixel in Dst current Row
    end; // for kx := LApRadius to WNX-LApRadius-2 do // middle pixels in current Dst (iy-th) row


    //***** CurSum is OK for WNX-LApRadius pixel in current (iy-th) row
    //      Calc last (LApRadius+1) pixels in current Dst (iy-th) row
    //      (last loop in Example, kx=7,8,9)

    for kx := WNX-LApRadius-1 to WNX-1 do // along last (LApRadius+1) pixels in current Dst (iy-th) row
    begin
      if ABorderMode = fbmNotFill then // CurSum is sum of LApRadius+1+ix elements
      begin
        NumElems := (LApRadius+WNX-kx) * CurNumYSize; // CurNumYSize was set in main body
        PWORD(PCurDstElem)^ := Round( CurSum / NumElems );

        if kx <> (WNX-1) then // not last pixel
        begin
          CurSum := CurSum - ColSums[kx-LApRadius]; // update CurSum for next Pixel
        end; // if kx <> (WNX-1) then // not last pixel
      end else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements
      begin
        PWORD(PCurDstElem)^ := Round( CurSum*RevNumApPix ); // RevNumApPix=1.0/NumApPixels

        if kx <> (WNX-1) then // not last pixel
        begin
          case ABorderMode of
            fbmNotFill: begin end; // do not fill at all, do nothing

            fbmRepl1: begin // fill by Replicating nearest pixel
              CurSum := CurSum + ColSums[WNX-1] - ColSums[kx-LApRadius];
            end; // fbmRepl1: begin // fill by Replicating nearest pixel

            fbmMirror: begin // by Mirroring all pixels
              CurSum := CurSum + ColSums[2*WNX-LApRadius-kx-2] - ColSums[kx-LApRadius];
            end; // fbmMirror: begin // by Mirroring all pixels

            else begin // fill by Zero, do nothing
            end; // else begin // fill by Zero, do nothing
          end; // case ABorderMode of
        end; // if kx <> (WNX-1) then // not last pixel
      end; // else // all other cases, CurSum is sum of NumApPixels=ApSize*ApSize elements

      Inc( PCurDstElem, WDstStepX ); // to next pixel in Dst current Row
    end; // for kx := WNX-LApRadius-1 to WNX-1 do // along last (LApRadius+1) pixels in current Dst (iy-th) row

    end; // with WVars do
  end; // procedure CalcOneRow2Byte(); // local

begin //******************************** main body of N_Conv2SMAverageFast1
  ApSize := 2*AApRadius + 1;
  NumApPixels := ApSize*ApSize; // whole number of pixels in aperture windows
  RevNumApPix := 1.0 / NumApPixels; // Reverted NumApPixels (used for fast division by NumApPixels)

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables
  Assert( (APSrcSM^.SMDElSize = APDstSM^.SMDElSize) and (APSrcSM^.SMDElSize <= 2), 'Conv2SMAverageFast1: Bad SMDElSize' );
  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes


  with WVars do
  begin
  // ColSums[i] is an integer Sum of nearest pixels in i-th column for current row
  SetLength( ColSums, WNX );

  //***** Prepare ColSums for initial (zero) pixels Row

  for i := 0 to High(ColSums) do
    ColSums[i] := 0;

  PCurSrcRow := WPSrcBegX;

  case CaseInd of

  0: begin //********************************************** One byte elements

  for iy := 0 to AApRadius do // along first AApRadius+1 rows
  begin
    PCurSrcElem := PCurSrcRow;

    for ix := 0 to WNX-1 do // along all elems in ColSums Array
    begin
      ColSums[ix] := ColSums[ix] + Byte(PCurSrcElem^);
      Inc( PCurSrcElem, WSrcStepX );
    end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

    Inc( PCurSrcRow, WSrcStepY ); // to next Src row
  end; // for iy := 0 to AApRadius do // along first AApRadius+1 rows

  // add to ColSums elements additional values, depended upon ABorderMode

  case ABorderMode of

    fbmNotFill: begin end; // do not fill at all, do nothing

    fbmRepl1: begin // fill by Replicating nearest pixel
      PCurSrcElem := WPSrcBegX;

      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElem^)*AApRadius;
        Inc( PCurSrcElem, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1: begin // fill by Replicating nearest pixel

    fbmMirror: begin // by Mirroring all pixels
      PCurSrcElem := WPSrcBegX + AApRadius*WSrcStepY;

      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := 2*ColSums[ix] - Byte(PCurSrcElem^);
        Inc( PCurSrcElem, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmMirror: begin // by Mirroring all pixels

    else begin // fill by Zero, do nothing
    end; // else begin // fill by Zero, do nothing

  end; // case ABorderMode of


  //***** ColSums elems are OK for initial (zero) pixel Row
  //      Calc first AApRadius Rows
  //      (first loop in Example, iy=0,1)

  case ABorderMode of // set PCurSrcRowY1
    fbmRepl1:  PCurSrcRowY1 := WPSrcBegX;
    fbmMirror: PCurSrcRowY1 := WPSrcBegX + (AApRadius-1)*WSrcStepY;
    else       PCurSrcRowY1 := nil; // PCurSrcRowY1 is not needed
  end; // case ABorderMode of // set PCurSrcRowY1

  PCurSrcRowY2 := WPSrcBegX + (AApRadius+1)*WSrcStepY;
  PCurDstRow := WPDstBegX;

  for iy := 0 to AApRadius-1 do // along first AApRadius Rows
  begin
    CurNumYSize  := AApRadius+1+iy; // used inside CalcOneRow
    RevCurNumPix := 1.0 / (ApSize*CurNumYSize); // used inside CalcOneRow
    CalcOneRow1Byte(); // Calc all pixels in One (current) iy-th row

    //***** Update ColSums elems for next Row

    PCurSrcElemY2 := PCurSrcRowY2;
    PCurSrcElemY1 := PCurSrcRowY1;

    case ABorderMode of

    fbmNotFill: // each ColSums[i] is the sum of (AApRadius+1+iy) elements
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^);
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmNotFill:

    fbmRepl1: // fill by Replicating nearest pixel
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^) - Byte(PCurSrcElemY1^);
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1:

    fbmMirror: // by Mirroring all pixels
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^) - Byte(PCurSrcElemY1^);
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

      Dec( PCurSrcRowY1, WSrcStepY );
    end; // fbmMirror:

    end; // case ABorderMode of

    Inc( PCurSrcRowY2, WSrcStepY ); // needed for all ABorderMode variants
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := 0 to AApRadius-1 do // along first AApRadius Rows


  //***** ColSums elems are OK for first AApRadius pixel Rows
  //      Calc middle Rows
  //      (middle loop in Example, iy=2,3,4,5,6)

  PCurSrcRowY1 := WPSrcBegX; // PCurSrcRowY2 is already OK

  for iy := AApRadius to WNY-AApRadius-2 do // along middle Rows
  begin
    CurNumYSize  := 2*AApRadius+1; // used inside CalcOneRow
    RevCurNumPix := RevNumApPix;    // used inside CalcOneRow, RevNumApPix := 1.0 / NumApPixels
    CalcOneRow1Byte(); // Calc all pixels in One (current) iy-th row

    //***** Update ColSums elems for next Row

    PCurSrcElemY1 := PCurSrcRowY1;
    PCurSrcElemY2 := PCurSrcRowY2;

    for ix := 0 to WNX-1 do // along all elems in ColSums Array
    begin
      ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^) - Byte(PCurSrcElemY1^);
      Inc( PCurSrcElemY1, WSrcStepX );
      Inc( PCurSrcElemY2, WSrcStepX );
    end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

    Inc( PCurSrcRowY1, WSrcStepY );
    Inc( PCurSrcRowY2, WSrcStepY );
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := AApRadius to WNY-AApRadius-2 do // along middle Rows


  //***** ColSums elems are OK for first WNY-AApRadius pixel Rows
  //      Calc last (AApRadius+1) Rows
  //      (last loop in Example, iy=7,8,9)

  // PCurSrcRowY1 is already OK
  PCurSrcRowY2 := WPSrcBegX + (WNY-1)*WSrcStepY;

  for iy := WNY-AApRadius-1 to WNY-1 do // along last (AApRadius+1) pixel Rows
  begin
    CurNumYSize  := AApRadius+WNY-iy; // used inside CalcOneRow
    RevCurNumPix := 1.0 / (ApSize*CurNumYSize); // used inside CalcOneRow
    CalcOneRow1Byte(); // Calc all pixels in One (current) iy-th row

    if iy = (WNY-1) then Break; // Updating ColSums elems is not needed for last Row

    //***** Update ColSums elems for next Row

    PCurSrcElemY2 := PCurSrcRowY2;
    PCurSrcElemY1 := PCurSrcRowY1;

    case ABorderMode of

    fbmNotFill: // each ColSums[i] is the sum of (AApRadius+1+iy) elements
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] - Byte(PCurSrcElemY1^);
        Inc( PCurSrcElemY1, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmNotFill:

    fbmRepl1: // fill by Replicating nearest pixel
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^) - Byte(PCurSrcElemY1^);
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1:

    fbmMirror: // by Mirroring all pixels
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + Byte(PCurSrcElemY2^) - Byte(PCurSrcElemY1^);
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

      Dec( PCurSrcRowY2, WSrcStepY );
    end; // fbmMirror:

    end; // case ABorderMode of

    Inc( PCurSrcRowY1, WSrcStepY ); // needed for all ABorderMode variants
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := WNY-AApRadius-1 to WNY-1 do // along last (AApRadius+1) pixel Rows

  end; // 0: ***************************************** One byte elements

  1: begin //********************************************** Two bytes elements

  for iy := 0 to AApRadius do // along first AApRadius+1 rows
  begin
    PCurSrcElem := PCurSrcRow;

    for ix := 0 to WNX-1 do // along all elems in ColSums Array
    begin
      ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElem)^;
      Inc( PCurSrcElem, WSrcStepX );
    end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

    Inc( PCurSrcRow, WSrcStepY ); // to next Src row
  end; // for iy := 0 to AApRadius do // along first AApRadius+1 rows

  // add to ColSums elements additional values, depended upon ABorderMode

  case ABorderMode of

    fbmNotFill: begin end; // do not fill at all, do nothing

    fbmRepl1: begin // fill by Replicating nearest pixel
      PCurSrcElem := WPSrcBegX;

      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElem)^*AApRadius;
        Inc( PCurSrcElem, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1: begin // fill by Replicating nearest pixel

    fbmMirror: begin // by Mirroring all pixels
      PCurSrcElem := WPSrcBegX + AApRadius*WSrcStepY;

      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := 2*ColSums[ix] - PWORD(PCurSrcElem)^;
        Inc( PCurSrcElem, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmMirror: begin // by Mirroring all pixels

    else begin // fill by Zero, do nothing
    end; // else begin // fill by Zero, do nothing

  end; // case ABorderMode of


  //***** ColSums elems are OK for initial (zero) pixel Row
  //      Calc first AApRadius Rows
  //      (first loop in Example, iy=0,1)

  case ABorderMode of // set PCurSrcRowY1
    fbmRepl1:  PCurSrcRowY1 := WPSrcBegX;
    fbmMirror: PCurSrcRowY1 := WPSrcBegX + (AApRadius-1)*WSrcStepY;
    else       PCurSrcRowY1 := nil; // PCurSrcRowY1 is not needed
  end; // case ABorderMode of // set PCurSrcRowY1

  PCurSrcRowY2 := WPSrcBegX + (AApRadius+1)*WSrcStepY;
  PCurDstRow := WPDstBegX;

  for iy := 0 to AApRadius-1 do // along first AApRadius Rows
  begin
    CurNumYSize  := AApRadius+1+iy; // used inside CalcOneRow
    RevCurNumPix := 1.0 / (ApSize*CurNumYSize); // used inside CalcOneRow
    CalcOneRow2Byte(); // Calc all pixels in One (current) iy-th row

    //***** Update ColSums elems for next Row

    PCurSrcElemY2 := PCurSrcRowY2;
    PCurSrcElemY1 := PCurSrcRowY1;

    case ABorderMode of

    fbmNotFill: // each ColSums[i] is the sum of (AApRadius+1+iy) elements
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^;
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmNotFill:

    fbmRepl1: // fill by Replicating nearest pixel
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^ - PWORD(PCurSrcElemY1)^;
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1:

    fbmMirror: // by Mirroring all pixels
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^ - PWORD(PCurSrcElemY1)^;
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

      Dec( PCurSrcRowY1, WSrcStepY );
    end; // fbmMirror:

    end; // case ABorderMode of

    Inc( PCurSrcRowY2, WSrcStepY ); // needed for all ABorderMode variants
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := 0 to AApRadius-1 do // along first AApRadius Rows


  //***** ColSums elems are OK for first AApRadius pixel Rows
  //      Calc middle Rows
  //      (middle loop in Example, iy=2,3,4,5,6)

  PCurSrcRowY1 := WPSrcBegX; // PCurSrcRowY2 is already OK

  for iy := AApRadius to WNY-AApRadius-2 do // along middle Rows
  begin
    CurNumYSize  := 2*AApRadius+1; // used inside CalcOneRow
    RevCurNumPix := RevNumApPix;    // used inside CalcOneRow, RevNumApPix := 1.0 / NumApPixels
    CalcOneRow2Byte(); // Calc all pixels in One (current) iy-th row

    //***** Update ColSums elems for next Row

    PCurSrcElemY1 := PCurSrcRowY1;
    PCurSrcElemY2 := PCurSrcRowY2;

    for ix := 0 to WNX-1 do // along all elems in ColSums Array
    begin
      ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^ - PWORD(PCurSrcElemY1)^;
      Inc( PCurSrcElemY1, WSrcStepX );
      Inc( PCurSrcElemY2, WSrcStepX );
    end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

    Inc( PCurSrcRowY1, WSrcStepY );
    Inc( PCurSrcRowY2, WSrcStepY );
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := AApRadius to WNY-AApRadius-2 do // along middle Rows


  //***** ColSums elems are OK for first WNY-AApRadius pixel Rows
  //      Calc last (AApRadius+1) Rows
  //      (last loop in Example, iy=7,8,9)

  // PCurSrcRowY1 is already OK
  PCurSrcRowY2 := WPSrcBegX + (WNY-1)*WSrcStepY;

  for iy := WNY-AApRadius-1 to WNY-1 do // along last (AApRadius+1) pixel Rows
  begin
    CurNumYSize  := AApRadius+WNY-iy; // used inside CalcOneRow
    RevCurNumPix := 1.0 / (ApSize*CurNumYSize); // used inside CalcOneRow
    CalcOneRow2Byte(); // Calc all pixels in One (current) iy-th row

    if iy = (WNY-1) then Break; // Updating ColSums elems is not needed for last Row

    //***** Update ColSums elems for next Row

    PCurSrcElemY2 := PCurSrcRowY2;
    PCurSrcElemY1 := PCurSrcRowY1;

    case ABorderMode of

    fbmNotFill: // each ColSums[i] is the sum of (AApRadius+1+iy) elements
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] - PWORD(PCurSrcElemY1)^;
        Inc( PCurSrcElemY1, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmNotFill:

    fbmRepl1: // fill by Replicating nearest pixel
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^ - PWORD(PCurSrcElemY1)^;
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array
    end; // fbmRepl1:

    fbmMirror: // by Mirroring all pixels
    begin
      for ix := 0 to WNX-1 do // along all elems in ColSums Array
      begin
        ColSums[ix] := ColSums[ix] + PWORD(PCurSrcElemY2)^ - PWORD(PCurSrcElemY1)^;
        Inc( PCurSrcElemY1, WSrcStepX );
        Inc( PCurSrcElemY2, WSrcStepX );
      end; // for ix := 0 to WNX-1 do // along all elems in ColSums Array

      Dec( PCurSrcRowY2, WSrcStepY );
    end; // fbmMirror:

    end; // case ABorderMode of

    Inc( PCurSrcRowY1, WSrcStepY ); // needed for all ABorderMode variants
    Inc( PCurDstRow, WDstStepY );
  end; // for iy := WNY-AApRadius-1 to WNY-1 do // along last (AApRadius+1) pixel Rows

  end; // 1: begin **************************************** Two bytes elements

  end; // case CaseInd of

  end; // with WVars do
end; // procedure N_Conv2SMAverageFast1

//********************************************************N_Conv2SMMedianCT ***
// calculation of the filtered matrix with second fast median filers
// Really not implemented and not used, it will require to mutch memory for 16 bit images.
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
procedure N_Conv2SMMedianCT( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
var
 WVars: TN_ConvSMVars;
  HistArray: TN_IArray;
  HistColArray:  TN_AIArray;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  i0, j0, i1, i2, j1, j2, r, c, med, md: integer;
  middle, HCMDIM: integer;
  Val, val1, val2: byte;
  setMedian : Boolean;
begin

  middle := (ACMDim*ACMDim-1) div 2;
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  with WVars do
  begin

   HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

   SetLength(HistArray, 256);
   SetLength(HistColArray, WNX, 256);
   PCurSrcElem :=  WPSrcBegX;

   for j0 := 0 to  WNX-1 do  // along all elems in cur Row
   //for r := -HCMDIM-1 to HCMDIM-1 do
   //for r := 0 to ACMDim - 1 do
   for r := 0 to HCMDIM-1do
   begin

    if (r>=0) and (r<WNY)  then  Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (j0)*APSrcSM^.SMDStepX )^ else Val := 0;
    if (r>=0) and (r<WNY)  then inc(HistColArray[j0][Val]);
   end;

  //WPDstBegX := WPDstBegX + HCMDIM*APSrcSM^.SMDStepY + HCMDIM*APSrcSM^.SMDStepX;
  //PSrcBegX := WPSrcBegX + (HCMDIM+1)*APSrcSM^.SMDStepY + HCMDIM*APSrcSM^.SMDStepX;
  { opredeliaem gistogrammu i medianu dlia pervogo elementa kazdoj stroki }
  for i0 := 0 to WNY-1 do  // along all elems in cur Row
  begin

    PCurDstElem :=  WPDstBegX;

    i1 := i0-HCMDIM;
    i2 := i0+HCMDIM;
    { obnulenie gistogrammy }
    for Val := 0 to 255 do HistArray[Val] := 0;
    { pereschet gistogrammy dlia startovogo elementa row=i0, col=0 }
    for r := i1 to i2 do
      //for c := -HCMDIM to HCMDIM do
      for c := 0 to HCMDIM do
      begin

        if (r>=0) and (r<WNY) and (c>=0) then Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (c)*APSrcSM^.SMDStepX )^ else Val := 0;
        if (r>=0) and (r<WNY) then  inc(HistArray[Val]);
      end;


    { teper' opredeliaem medianu }
    md := 0;
    for Val := 0 to 255 do
    begin
      inc(md, HistArray[Val]);
      if md > middle then
        break;
    end;

    med := Val;
//    delta_l := md - HistArray[Val];
    PByte(PCurDstElem)^ := med;
    PCurDstElem := PCurDstElem + WDstStepX;

    { --- cikl po stolbcam ----- }
    for j0 := 1 to  WNX-1 do
    //for j0 := 1+HCMDIM to  WNX-HCMDIM-1 do
    begin
      j1 := j0-HCMDIM-1;
      j2 := j0+HCMDIM;
      { perexod k sledujushemu stolbcu }
      //for r := i1 to i2 do
      //begin
      r := i1 -1;
        if  (j1 >= 0) and (r >= 0) and (r < WNY) then Val1 := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (j2)*APSrcSM^.SMDStepX )^ else Val1 := 0;
        if  (r >= 0) and  (j2 < WNX) then dec(HistColArray[j2][Val1]);

      r := i2;
        if (j2 < WNX) and (r >= 0) and (r < WNY) then Val2 := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (j2)*APSrcSM^.SMDStepX )^ else Val2 := 0;
        if  (j2 < WNX) and (r < WNY) then inc(HistColArray[j2][Val2]);


      md := 0;  setMedian := False;
      for Val := 0 to 255 do
      begin
        if (j1 >= 0) then dec(HistArray[Val],HistColArray[j1][Val]);
        if (j2 < WNX) then Inc(HistArray[Val],HistColArray[j2][Val]);
        if(setMedian = False) then
        begin
            inc(md, HistArray[Val]); med := Val;
        end;
        if md > middle then   setMedian := True;
      end;
      //end;
      PByte(PCurDstElem)^ := med;
      PCurDstElem := PCurDstElem + WDstStepX;
    end;   // x loop
    WPDstBegX := WPDstBegX + WSrcStepY;
  end; // y loop
  end;
end;// procedure N_Conv2SMMedianCT

//**************************************************** N_Conv2SMMedianHuang ***
// Envelope for Huang fast median filters
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
procedure N_Conv2SMMedianHuang( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
begin
//  N_Conv2SMMedianHuangOld            ( APSrcSM, APDstSM, ACMDim ); // 5-6 sec on BigNoisy(15092011).BMP
//  N_Conv2SMMedianHuangStandart       ( APSrcSM, APDstSM, ACMDim ); // 13 sec on BigNoisy(15092011).BMP
//  N_Conv2SMMedianHuangDelta          ( APSrcSM, APDstSM, ACMDim ); // 3-4 sec on BigNoisy(15092011).BMP
//  N_Conv2SMMedianHuangBinary         ( APSrcSM, APDstSM, ACMDim ); // 4-5 sec on BigNoisy(15092011).BMP
  N_Conv2SMMedianHuangBinaryAndDelta ( APSrcSM, APDstSM, ACMDim ); // 3-4 sec on BigNoisy(15092011).BMP
end; // procedure N_Conv2SMMedianHuang

//************************************************* N_Conv2SMMedianHuangOld ***
// Calculation of the filtered matrix using Huang fast median algorithm
// (was used till CMS Build 3.039)
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
procedure N_Conv2SMMedianHuangOld( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  HistArray: TN_IArray;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  i0, j0, i1, i2, j1, j2, r, c, med, md, dl, Delta_l: integer;
  Middle, HCMDIM: integer;         
  Val: word;
  HistLengthInt: integer;
  HistLengthReal: real;
begin
  //***** Set length of the Histogramm array
  if APSrcSM.SMDNumBits = 8 then
    HistLengthReal := Exp( 8 * ln( 2 )) // means 2^8
  else
    HistLengthReal := Exp( 16 * ln( 2 )); // means 2^16
  HistLengthInt := Trunc( HistLengthReal );

  Middle := ( ACMDim * ACMDim - 1 ) div 2;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

   HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

   SetLength( HistArray, HistLengthInt );

  // Get median for the first element of each row
  for i0 := 0 to WNY - 1 do  // along all elems in cur Row
  begin
    PCurSrcElem :=  WPSrcBegX;
    PCurDstElem :=  WPDstBegX;

    i1 := i0-HCMDIM;
    i2 := i0+HCMDIM;
    // Set histogramm =0
    for Val := 0 to HistLengthInt - 1 do HistArray[ Val ] := 0;
    // Get histogramm for start element row=y, col=0
    for r := i1 to i2 do
      for c := -HCMDIM to HCMDIM do
      begin
        if ( r >= 0 ) and ( r < WNY ) and ( c >= 0 ) then
        begin
          if APSrcSM.SMDNumBits = 8 then // Byte is for 256 elems (2^8)
            Val := PByte(PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                    ( c ) * APSrcSM^.SMDStepX )^
          else // Word is for more then 256 elems
            Val := PWord(PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                    ( c ) * APSrcSM^.SMDStepX )^
        end

        else Val := 0;
        Inc( HistArray[ Val ]);
      end;

    // Get median
    md := 0;
    for Val := 0 to HistLengthInt - 1 do
    begin
      Inc( md, HistArray[ Val ]);
      if md > Middle then
        break;
    end;
    med := Val;
    Delta_l := md - HistArray[ Val ];

    if APSrcSM.SMDNumBits = 8 then
      PByte(PCurDstElem)^ := med // Byte is for 256 elems (2^8)
    else
      PWord(PCurDstElem)^ := med; // Word is for more then 256 elems

    PCurDstElem := PCurDstElem + WDstStepX;

    //***** for cols
    for j0 := 1 to  WNX - 1 do
    begin
      j1 := j0 - HCMDIM - 1;
      j2 := j0 + HCMDIM;
      // next col
      for r := i1 to i2 do
      begin
        if ( j1 >= 0 ) and ( r >= 0 ) and ( r < WNY ) then
        begin
          if APSrcSM.SMDNumBits = 8 then // Byte is for 256 elems (2^8)
            Val := PByte( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( j1 ) * APSrcSM^.SMDStepX )^
          else // Word is for more then 256 elems
            Val := PWord( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( j1 ) * APSrcSM^.SMDStepX )^
        end
        else Val := 0;
        Dec( HistArray[ Val ]);
        if Val < med then Dec( Delta_l );
        if ( j2 < WNX ) and ( r >= 0 ) and ( r < WNY ) then
        begin
          if APSrcSM.SMDNumBits = 8 then
            Val := PByte( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( j2 ) * APSrcSM^.SMDStepX )^
          else
            Val := PWord( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( j2 ) * APSrcSM^.SMDStepX )^
        end
        else Val := 0;
        Inc( HistArray[ Val ]);
        if Val < med then Inc( Delta_l );
      end;

      // update new median
      dl := Delta_l;
      md := med;
      if dl > Middle then
      begin
        while dl > Middle do
        begin
          Dec( md );
          if HistArray[ md ] > 0 then
            dec( dl, HistArray[ md ]);
        end;
      end
      else
      begin
        while dl + HistArray[ md ] <= Middle do
        begin
          if HistArray[ md ] > 0 then
            Inc( dl, HistArray[ md ]);
           Inc( md );
        end;
      end;

      Delta_l := dl;
      med := md;

      if APSrcSM.SMDNumBits = 8 then
        PByte( PCurDstElem )^ := med
      else
        PWord( PCurDstElem )^ := med;

      PCurDstElem := PCurDstElem + WDstStepX;
    end;   // x loop
    WPDstBegX := WPDstBegX + WSrcStepY;
  end; // y loop
  end;
end; // end procedure N_Conv2SMMedianHuangOld

//***************************************************** N_Conv2SMMedianSort1 ***
// Сalculation of the filtered matrix with simple median filters, variant #1, slow
//
//     Parameters:
// APSrcSM   - Pointer to Source SubMatrix description
// APDstSM   - Pointer to Destination SubMatrix description
// AApRadius - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
//
procedure N_Conv2SMMedianSort1( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  iy, j0, r, c, k : integer;
  i1, i2, j1, j2 : integer;
  Buf: TN_IArray;
  Val: word;
  HistLengthInt: integer;
  HistLengthReal, Size: real;

  procedure BubbleSort(var a: TN_IArray); // for sort histogramm
    var
      i,p,n: integer;
      b: boolean;
    begin
      n:= Length( a );
      if n < 2 then Exit;
      repeat
        b:= False;
        Dec( n );
        for i := 0 to n - 1 do
          if a[ i ] < a[ i+1 ] then
          begin
            p:= a[ i+1 ];
            a[ i+1 ] := a[ i ];
            a[ i ] := p;
            b := true;
          end;
      until not b;
    end;

begin
  ACMDim := 2; // to have similar parameters with Huang's median

  if APSrcSM.SMDNumBits = 8 then
    HistLengthReal:= Exp( 8 * ln( 2 ))
  else
    HistLengthReal:= Exp( 16 * ln( 2 ));

  HistLengthInt := Trunc( HistLengthReal );

  SetLength( Buf, HistLengthInt ); // buf for sorting with all elems for current Aperture window

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

  for iy := 0 to WNY - 1 do  // along all elems in cur Row
  begin
    PCurSrcElem :=  WPSrcBegX;
    PCurDstElem :=  WPDstBegX;
    i1 := iy - ACMDim;
    i2 := iy + ACMDim;

    for j0 := 0 to  WNX - 1 do
    begin
      k := 0;
      j1 := j0 - ACMDim;
      j2 := j0 + ACMDim;

      //***** Get histogramm (is called Buf)
      for c := j1 to j2 do
      begin
      for r := i1 to i2 do
      begin
        if ( c >= 0 ) and ( c < WNX ) and ( r >= 0 ) and ( r < WNY ) then
        begin
          if APSrcSM.SMDNumBits = 8 then // Byte for histogramm with 256 (2^8) elems
            Val := PByte( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                    ( c ) * APSrcSM^.SMDStepX )^
          else // Word is for > then 256 elems in a histogramm
            Val := PWord( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( c ) * APSrcSM^.SMDStepX )^;
        end
        else
          Val := 0;

        Buf[ k ] := Val;
        Inc( k );
      end;
      end;

      BubbleSort( Buf ); // Sort histogramm to get median (center of the sorted array)
      Size := k; // Size of the histogramm that is used

      if APSrcSM.SMDNumBits = 8 then
        PByte( PCurDstElem )^ := Buf[ Trunc( Size / 2 )] // Size/2 means center (median)
      else
        PWord( PCurDstElem )^ := Buf[ Trunc( Size / 2 )];

      PCurDstElem := PCurDstElem + WDstStepX;
    end;   // x loop
    WPDstBegX := WPDstBegX + WSrcStepY;
  end; // y loop
  end;
end; // procedure N_Conv2SMMedianSort1

{
//*****************************************************N_Conv2SMMedianHuang ***
// for 8 bit only version
// calculation of the filtered matrix wiath first fast median filers(by Huang)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
procedure N_Conv2SMMedianHuang( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  HistArray: TN_IArray;
  HistColArray:  TN_AIArray;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  i0, j0, i1, i2, j1, j2, r, c, med, md, dl, delta_l: integer;
  middle, HCMDIM: integer;
  Val: byte;
begin

  middle := (ACMDim*ACMDim-1) div 2;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  with WVars do
  begin

   HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

   SetLength(HistArray, 256);
   SetLength(HistColArray, WNX, 256);

//   opredeliaem gistogrammu i medianu dlia pervogo elementa kazdoj stroki
  for i0 := 0 to WNY-1 do  // along all elems in cur Row
  begin
    PCurSrcElem :=  WPSrcBegX;
    PCurDstElem :=  WPDstBegX;

    i1 := i0-HCMDIM;
    i2 := i0+HCMDIM;
//     obnulenie gistogrammy
    for Val := 0 to 255 do HistArray[Val] := 0;
//    pereschet gistogrammy dlia startovogo elementa row=y, col=0
    for r := i1 to i2 do
      for c := -HCMDIM to HCMDIM do
      begin

        if (r>=0) and (r<WNY) and (c>=0) then Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (c)*APSrcSM^.SMDStepX )^ else Val := 0;
        inc(HistArray[Val]);
      end;


//     teper' opredeliaem medianu
    md := 0;
    for Val := 0 to 255 do
    begin
      inc(md, HistArray[Val]);
      if md > middle then
        break;
    end;
    med := Val;
    delta_l := md - HistArray[Val];
    PByte(PCurDstElem)^ := med;
    PCurDstElem := PCurDstElem + WDstStepX;

//     --- cikl po stolbcam -----
    for j0 := 1 to  WNX-1 do
    begin
      j1 := j0-HCMDIM-1;
      j2 := j0+HCMDIM;
//       perexod k sledujushemu stolbcu
      for r := i1 to i2 do
      begin
        if (j1 >= 0) and (r >= 0) and (r < WNY) then Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (j1)*APSrcSM^.SMDStepX )^ else Val := 0;
        dec(HistArray[Val]);
        if Val < med then dec(delta_l);
        if (j2 < WNX) and (r >= 0) and (r < WNY) then Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (j2)*APSrcSM^.SMDStepX )^ else Val := 0;
        inc(HistArray[Val]);
        if Val < med then inc(delta_l);
      end;

//       update new median
      dl := delta_l;
      md := med;
      if dl > middle then
      begin
        while dl > middle do
        begin
          dec(md);
         if HistArray[md] > 0 then
           dec(dl,HistArray[md]);
        end;
      end
      else
      begin
        while dl + HistArray[md] <= middle do
        begin
          if HistArray[md] > 0 then
            inc(dl,HistArray[md]);
           inc(md);
        end;
      end;

      delta_l := dl;
      med := md;

      PByte(PCurDstElem)^ := med;
      PCurDstElem := PCurDstElem + WDstStepX;
    end;   // x loop
    WPDstBegX := WPDstBegX + WSrcStepY;
  end; // y loop
  end;
end; // end procedure N_Conv2SMMedianHuang

//**************************************************** N_Conv2SMMedianSort1 ***
// Сalculation of the filtered matrix with simple median filers, variant #1
//
//     Parameters
// APSrcSM   - Pointer to Source SubMatrix description
// APDstSM   - Pointer to Destination SubMatrix description
// AApRadius - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
//
procedure N_Conv2SMMedianSort1( APSrcSM, APDstSM: TN_PSMatrDescr; AApRadius: integer );
var
  WVars: TN_ConvSMVars;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  NumApPixels, ApSize: integer;
  iy, j0, r, c, k : integer;
  i1, i2, j1, j2 : Integer;
  HCMDIM: integer;
  Buf: TN_IArray;
  Val: byte;
begin
  ApSize := 2*AApRadius + 1; // ApSize (Aperture Size) is one dimensional size of square apperture
  NumApPixels := ApSize*ApSize; // Whole number of pixels in Aperture
  SetLength( Buf, NumApPixels ); // buf for sorting with all elems for current Aperture window

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  with WVars do
  begin

  for iy := 0 to WNY-1 do  // along all elems in cur Row
  begin
    PCurSrcElem :=  WPSrcBegX;
    PCurDstElem :=  WPDstBegX;
    iy1 := iy - AApRadius;
    iy2 := iy + AApRadius;

    for j0 := 0 to  WNX-1 do
    begin
      k := 0;
      j1 := j0-AApRadius;
      j2 := j0+AApRadius;
//      sformirovat' massiv lkz sortirovki
      for c := j1 to j2 do
      begin
      for r := i1 to i2 do
      begin
        if (c >= 0) and (c < WNX) and (r >= 0) and (r < WNY) then
          Val := PByte(PCurSrcElem + (r)*APSrcSM^.SMDStepY + (c)*APSrcSM^.SMDStepX )^
        else
          Val := 0;

        Buf[k] := Val;
        Inc(k);
      end;
      end;

      N_SortElements( TN_BytesPtr(@Buf[0]), ACMDim*ACMDim, SizeOf(integer), 0, N_CompareIntegers );

      PByte(PCurDstElem)^ := Buf[center];
      PCurDstElem := PCurDstElem + WDstStepX;
    end;   // x loop
    WPDstBegX := WPDstBegX + WSrcStepY;
  end; // y loop
  end;
end; // procedure N_Conv2SMMedianSort1
}

//********************************************** N_Conv2SMMedianSortForPixel ***
// Сalculation of the filtered matrix with simple median filters, variant #1,
// only for one pixel
//
//     Parameters:
// APSrcSM   - Pointer to Source SubMatrix description
// APDstSM   - Pointer to Destination SubMatrix description
// AApRadius - Aperture Radius (Size (one dimensional size of square apperture) is 2*AApRadius+1)
// X, Y - coordinates of the pixel
// med - value of the median
//
procedure N_Conv2SMMedianSort1ForPixel( APSrcSM, APDstSM: TN_PSMatrDescr;
                                ACMDim: integer; X, Y: integer; out med: word );
var
  WVars: TN_ConvSMVars;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  iy, j0, r, c, k, WindowSize: integer;
  i1, i2, j1, j2: integer;
  Buf: TN_IArray;
  Val: word;
  HistLengthInt: integer;
  HistLengthReal, Size: real;

  procedure BubbleSort(var a: TN_IArray); // for sort histogramm
    var
      i,p,n: integer;
      b: boolean;
    begin
      n:= Length( a );
      if n < 2 then Exit;
      repeat
        b:= False;
        Dec( n );
        for i := 0 to n - 1 do
          if a[ i ] < a[ i+1 ] then
          begin
            p:= a[ i+1 ];
            a[ i+1 ] := a[ i ];
            a[ i ] := p;
            b := true;
          end;
      until not b;
    end;

begin
  if APSrcSM.SMDNumBits = 8 then
    HistLengthReal:= Exp( 8 * ln( 2 ))
  else
    HistLengthReal:= Exp( 16 * ln( 2 ));

  HistLengthInt := Trunc( HistLengthReal );

  SetLength( Buf, HistLengthInt ); // buf for sorting with all elems for current Aperture window

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

    iy := Y; // setting y coord

    PCurSrcElem :=  WPSrcBegX;
    PCurDstElem :=  WPDstBegX;
    i1 := iy - ACMDim;
    i2 := iy + ACMDim;

    j0 := X; // setting x coord

    k := 0;
    WindowSize := 0;
    j1 := j0 - ACMDim;
    j2 := j0 + ACMDim;

    //***** Get histogramm (is called Buf)
    for c := j1 to j2 do
    begin
    for r := i1 to i2 do
    begin
      if ( c >= 0 ) and ( c < WNX ) and ( r >= 0 ) and ( r < WNY ) then
      begin
        if APSrcSM.SMDNumBits = 8 then // Byte for histogramm with 256 (2^8) elems
          Val := PByte( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                    ( c ) * APSrcSM^.SMDStepX )^
        else // Word is for > then 256 elems in a histogramm
          Val := PWord( PCurSrcElem + ( r ) * APSrcSM^.SMDStepY +
                                                   ( c ) * APSrcSM^.SMDStepX )^;
        Inc( WindowSize );
      end
      else
        Val := 0;

      Buf[ k ] := Val;
      Inc( k );
    end;
    end;

    BubbleSort( Buf ); // Sort histogramm to get median (center of the sorted array)
    Size := WindowSize; // Size of the histogramm that is used

    if APSrcSM.SMDNumBits = 8 then
    begin
      PByte( PCurDstElem )^ := Buf[ Trunc( (Size-1) / 2 )];// Size/2 means center (median)
      med := Buf[ Trunc( (Size-1) / 2 )];
    end
    else
    begin
      PWord( PCurDstElem )^ := Buf[ Trunc( Size / 2 )];
      med := Buf[ Trunc( Size / 2 )];
    end;
  end;
end; // procedure N_Conv2SMMedianSort1ForPixel

//******************************************** N_Conv2SMMedianHuangStandart ***
// calculation of the filtered matrix with first fast median filters (by Huang),
// second version, faster.
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Uses standart algorythm to calculate histogram medians
//
procedure N_Conv2SMMedianHuangStandart( APSrcSM, APDstSM: TN_PSMatrDescr;
                                                              ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  HistArray: TN_IArray;
  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, i: integer;
  Middle, HCMDIM: integer;
  TempLoop1, TempLoop2: integer;

  CaseInd: integer;

  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2: integer;

  Timer: TN_CPUTimer1;
  TimerFlag: Boolean;

procedure CalcOneRow1Byte( i1, i2: integer ); // local, calculating one row for 1 byte elems
// local procedure of N_Conv2SMMedianHuangStandart
var
  Val: Byte;
  k, j, j1, j2: integer;
  TempLoopj1, TempLoopj2: integer;
  begin //********** main body of local procedure CalcOneRow1Byte

  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 255 do HistArray[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PByte( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      // Get median
      md := 0;

      for Val := 0 to 255 do
      begin
        Inc( md, HistArray[Val]);
        if md > Middle then
          break;
      end; // for Val := 0 to 65535 do

      med := Val; // value of an array median

      PByte(PCurDstElem)^ := med; // Byte is for 256 elems (2^8)

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        md := 0;

        for Val := 0 to 255 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PByte(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
        //  if Val < med then Dec(Delta_l);

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
         // if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

          // ***** update new median
        md := 0;

        for Val := 0 to 255 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
         // if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

         // ***** update new median
        md := 0;

        for Val := 0 to 255 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow1Byte(i1, i2: integer); // local

procedure CalcOneRow2Byte( i1, i2: integer ); // local, calculating one row for 2 byte elems
// local procedure of N_Conv2SMMedianHuangStandart
var
  Val: Word;
  k, j, j1, j2: integer;
  TempLoopj1, TempLoopj2: integer;
  begin //********** main body of local procedure CalcOneRow1Byte

  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 65535 do HistArray[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PWord( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      // Get median
      md := 0;

      for Val := 0 to 65535 do
      begin
        Inc( md, HistArray[Val]);
        if md > Middle then
          break;
      end; // for Val := 0 to 65535 do

      med := Val; // value of an array median

      PWord(PCurDstElem)^ := med; // Word is for 2^16 elems
      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;
        Middle := TempMiddle2 div 2;

          // ***** update new median
        md := 0;

        for Val := 0 to 65535 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PWord(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
        end; // for k := i1 to i2 do

          // ***** update new median
        md := 0;

        for Val := 0 to 65535 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
         // if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

         // ***** update new median
        md := 0;

        for Val := 0 to 65535 do
        begin
          Inc( md, HistArray[Val]);
          if md > Middle then
            break;
        end; // for Val := 0 to 65535 do

        med := Val; // value of an array median

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow2Byte(i1, i2: integer); // local

begin //***************************** main body of N_Conv2SMMedianHuangStandart
  TimerFlag := True;
  Timer := TN_CPUTimer1.Create;
  if TimerFlag then // Start timing
  begin
    Timer.Start;
  end;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

    CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes

    HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

    case CaseInd of

    0: begin //********************************************** One byte elements

      SetLength( HistArray, 256 );

      CalcOneRow1Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow1Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

    end; // 0: ***************************************** One byte elements

  1: begin //********************************************** Two bytes elements

      SetLength( HistArray, 65536 );

      CalcOneRow2Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow2Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;
    end; // 1: ***************************************** Two bytes elements

  end;
  end;

  if TimerFlag then // Stop timing
  begin
    Timer.Stop;
//    ShowMessage('Time = '+Timer.ToStr(1));
  end;
end; // procedure N_Conv2SMMedianHuangStandart

//*********************************************** N_Conv2SMMedianHuangDelta ***
// calculation of the filtered matrix with first fast median filters (by Huang),
// second version, faster.
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Uses last histogramm median value to calculate the next one
//
procedure N_Conv2SMMedianHuangDelta( APSrcSM, APDstSM: TN_PSMatrDescr;
                                                              ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  TempLoop1, TempLoop2: integer;
  HCMDIM, i: integer;
  HistArray: TN_IArray;
  CaseInd: integer;
  Timer: TN_CPUTimer1;
  TimerFlag: Boolean;

procedure CalcOneRow1Byte( i1, i2: integer ); // local, calculating one row for 1 byte elems
// used in N_Conv2SMMedianHuangDelta
var
  Val: Byte;
  k, j, j1, j2: integer;
  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2, TempLoopj1, TempLoopj2: integer;

  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, dl, Delta_l: integer;
  Middle: integer;

  begin //********** main body of local procedure CalcOneRow1Byte

  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 255 do HistArray[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PByte( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      // Get median
      md := 0;

      for Val := 0 to 255 do
      begin
        Inc( md, HistArray[Val]);
        if md > Middle then
          break;
      end; // for Val := 0 to 65535 do

      med := Val; // value of an array median
      Delta_l := md - HistArray[Val]; // number of elements that is less than a middle

      PByte(PCurDstElem)^ := med; // Byte is for 256 elems (2^8)


      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow1Byte(i1, i2: integer); // local

procedure CalcOneRow2Byte( i1, i2: integer ); // local, calculating one row for 2 byte elems
// used in N_Conv2SMMedianHuangDelta
var
  Val: Word;
  k, j, j1, j2: integer;
  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2, TempLoopj1, TempLoopj2: integer;

  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, dl, Delta_l: integer;
  Middle: integer;

  //Tempmed: word;
  begin //********** main body of local procedure CalcOneRow1Byte

  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 65535 do HistArray[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PWord( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      // Get median
      md := 0;

      for Val := 0 to 65535 do
      begin
        Inc( md, HistArray[Val] );
        if md > Middle then
          break;
      end; // for Val := 0 to 65535 do

      med := Val; // value of an array median
      Delta_l := md - HistArray[Val]; // number of elements that is less than a middle

      PWord(PCurDstElem)^ := med; // Word is for 2^16 elems

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow2Byte(i1, i2: integer); // local

begin //************************** main body of N_Conv2SMMedianHuangDelta
  TimerFlag := True; // Start timing
  Timer := TN_CPUTimer1.Create;
  if TimerFlag then
  begin
    Timer.Start;
  end;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

    CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes

    HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

    case CaseInd of

    0: begin //********************************************** One byte elements

      SetLength( HistArray, 256 );

      CalcOneRow1Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow1Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

    end; // 0: ***************************************** One byte elements

  1: begin //********************************************** Two bytes elements

      SetLength( HistArray, 65536 );

      CalcOneRow2Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow2Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;
    end; // 1: ***************************************** Two bytes elements

  end;
  end;

  if TimerFlag then // Stop timing
  begin
    Timer.Stop;
//    ShowMessage('Time = '+Timer.ToStr(1));
  end;
end; // procedure N_Conv2SMMedianHuangDelta

//********************************************** N_Conv2SMMedianHuangBinary ***
// calculation of the filtered matrix with first fast median filters (by Huang),
// second version, faster.
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Uses last binary algorythm to calculate histogram medians
//
procedure N_Conv2SMMedianHuangBinary( APSrcSM, APDstSM: TN_PSMatrDescr;
                                                              ACMDim: integer );
var
  WVars: TN_ConvSMVars;
  HistArray: TN_IArray;
  HistArraySmall: TN_IArray;

  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, i: integer;
  Middle, HCMDIM: integer;
  TempLoop1, TempLoop2: integer;

  CaseInd: integer;

  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2: integer;

  Timer: TN_CPUTimer1;
  TimerFlag: Boolean;

procedure CalcOneRow1Byte( i1, i2: integer ); // local, calculating one row for 1 byte elems
// used in N_Conv2SMMedianHuangBinary
var
  Val: Byte;
  k, j, j1, j2, TempVal, TempLoopj1, TempLoopj2: integer;
  begin //********** main body of local procedure CalcOneRow1Byte

    TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 255 do HistArray[Val] := 0;

      for Val := 0 to 15 do HistArraySmall[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PByte( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );

          TempVal := Val div 16; // Temporary histogramm
          Inc( HistArraySmall[TempVal] );

        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      md := 0; // Calculating histogram median for temporary small histogramm
      for TempVal := 0 to 15 do
      begin
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
      TempLoopj2 := (TempVal+1)*16 - 1;
      for Val := TempLoopj1 to TempLoopj2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

      PByte(PCurDstElem)^ := med; // Byte is for 256 elems (2^8)

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;
        Middle := TempMiddle2 div 2;

        md := 0; // Calculating histogram median for temporary small histogramm
        for TempVal := 0 to 15 do
        begin
          inc(md, HistArraySmall[TempVal]);
          if md > Middle then
          begin
            Dec( md, HistArraySmall[TempVal] );
            break;
          end;
        end;

        TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
        TempLoopj2 := (TempVal+1)*16 - 1;
        for Val := TempLoopj1 to TempLoopj2 do
        begin
          inc(md, HistArray[Val]);
          if md > Middle then break;
        end;
        med := Val;

        PByte(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Dec( HistArraySmall[TempVal] );

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for k := i1 to i2 do

      md := 0; // Calculating histogram median for temporary small histogramm
      for TempVal := 0 to 15 do
      begin
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
      TempLoopj2 := (TempVal+1)*16 - 1;
      for Val := TempLoopj1 to TempLoopj2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          //if Val < med then Dec(Delta_l);

          TempVal := Val div 16; // temporary histogramm
          Dec( HistArraySmall[TempVal] );
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;
        Middle := TempMiddle2 div 2;

      md := 0; // Calculating histogram median for temporary small histogramm
      for TempVal := 0 to 15 do
      begin
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
      TempLoopj2 := (TempVal+1)*16 - 1;
      for Val := TempLoopj1 to TempLoopj2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow1Byte(i1, i2: integer); // local

procedure CalcOneRow2Byte( i1, i2: integer ); // local, calculating one row for 2 byte elems
// used in N_Conv2SMMedianHuangBinary
var
  Val: Word;
  k, j, j1, j2, TempVal, TempLoopj1, TempLoopj2: integer;

begin //********** main body of local procedure CalcOneRow2Byte

    TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 65535 do HistArray[Val] := 0;

      for Val := 0 to 4095 do HistArraySmall[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PWord( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );

        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      md := 0; // Calculating histogram median for temporary small histogramm
      for TempVal := 0 to 4095 do
      begin
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
      TempLoopj2 := (TempVal+1)*16 - 1;
      for Val := TempLoopj1 to TempLoopj2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

      PWord(PCurDstElem)^ := med; // Byte is for 256 elems (2^8)

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        md := 0; // Calculating histogram median for temporary small histogramm
        for TempVal := 0 to 4095 do
        begin
          inc(md, HistArraySmall[TempVal]);
          if md > Middle then
          begin
            Dec( md, HistArraySmall[TempVal] );
            break;
          end;
        end;

        TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
        TempLoopj2 := (TempVal+1)*16 - 1;
        for Val := TempLoopj1 to TempLoopj2 do
        begin
          inc(md, HistArray[Val]);
          if md > Middle then break;
        end;
        med := Val;

        PWord(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Dec( HistArraySmall[TempVal] );

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for k := i1 to i2 do

        md := 0; // Calculating histogram median for temporary small histogramm
        for TempVal := 0 to 4095 do
        begin
          inc(md, HistArraySmall[TempVal]);
          if md > Middle then
          begin
            Dec( md, HistArraySmall[TempVal] );
            break;
          end;
        end;

        TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
        TempLoopj2 := (TempVal+1)*16 - 1;
        for Val := TempLoopj1 to TempLoopj2 do
        begin
          inc(md, HistArray[Val]);
          if md > Middle then break;
        end;
        med := Val;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);

          TempVal := Val div 16; // temporary histogramm
          Dec( HistArraySmall[TempVal] );
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        md := 0; // Calculating histogram median for temporary small histogramm
        for TempVal := 0 to 4095 do
        begin
          inc(md, HistArraySmall[TempVal]);
          if md > Middle then
          begin
            Dec( md, HistArraySmall[TempVal] );
            break;
          end;
        end;

        TempLoopj1 := TempVal*16; // Calculating histogram median (uses only one segment of the histogramm)
        TempLoopj2 := (TempVal+1)*16 - 1;
        for Val := TempLoopj1 to TempLoopj2 do
        begin
          inc(md, HistArray[Val]);
          if md > Middle then break;
        end;
        med := Val;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow2Byte(i1, i2: integer); // local

begin //****************************** main body if N_Conv2SMMedianHuangBinary
  TimerFlag := True;
  Timer :=TN_CPUTimer1.Create;
  if TimerFlag then // Start timing
  begin
    Timer.Start;
  end;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

    CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes

    HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

    case CaseInd of

    0: begin //********************************************** One byte elements

      SetLength( HistArray, 256 );

      SetLength( HistArraySmall, 16 );

      CalcOneRow1Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow1Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

    end; // 0: ***************************************** One byte elements

  1: begin //********************************************** Two bytes elements

      SetLength( HistArray, 65536 );

      SetLength( HistArraySmall, 256 );

      CalcOneRow2Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow2Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;
    end; // 1: ***************************************** Two bytes elements

  end;
  end;

  if TimerFlag then // Stop timing
  begin
    Timer.Stop;
//    ShowMessage('Time = '+Timer.ToStr(1));
  end;
end; // procedure N_Conv2SMMedianHuangBinary

//************************************** N_Conv2SMMedianHuangBinaryAndDelta ***
// calculation of the filtered matrix with first fast median filters (by Huang),
// second version, faster.
//
//     Parameters:
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Uses binar algorythm to calculate first histogram median and then the one that
// uses the last median to calculate the next one for others
//
procedure N_Conv2SMMedianHuangBinaryAndDelta( APSrcSM, APDstSM: TN_PSMatrDescr;
                                                              ACMDim: integer );
var
  WVars: TN_ConvSMVars;

  TempLoop1, TempLoop2: integer;
  HCMDIM, i: integer;
  HistArray, HistArraySmall: TN_IArray;

  CaseInd: integer;

  Timer: TN_CPUTimer1;
  TimerFlag: Boolean;

procedure CalcOneRow1Byte( i1, i2: integer ); // local, calculating one row for 1 byte elems
// local procedure of N_Conv2SMMedianHuangBinaryAndDelta
var
  Val: Byte;
  k, j, j1, j2: integer;
  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2, TempLoopj1, TempLoopj2: integer;

  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, dl, Delta_l: integer;
  Middle, TempVal: integer;
  TempLoopSmall1, TempLoopSmall2: integer;

begin //********** main body of local procedure CalcOneRow1Byte
  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 255 do HistArray[Val] := 0;

      for Val := 0 to 15 do HistArraySmall[Val] := 0;

      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PByte( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );

          TempVal := Val div 16; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      md := 0; // Calculate median for the temporary histogramm
      for TempVal := 0 to 15 do
      begin
        //TempVal := Val div 16;
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopSmall1 := TempVal*16; // Calculate actual median using a segment from histogramm
      TempLoopSmall2 := (TempVal+1)*16 - 1;
      for Val := TempLoopSmall1 to TempLoopSmall2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

      Delta_l := md - HistArray[Val]; // number of elements that is less than a middle

      PByte(PCurDstElem)^ := med; // Byte is for 256 elems (2^8)

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);

          Val := PByte( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PByte( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PByte( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow1Byte(i1, i2: integer); // local

procedure CalcOneRow2Byte( i1, i2: integer ); // local, calculating one row for 2 byte elems
// local procedure of N_Conv2SMMedianHuangBinaryAndDelta
var
  Val: Word;
  k, j, j1, j2: integer;
  TempPByte1, TempPByte2: TN_BytesPtr;
  TempStepX, TempStepY, TempMiddle1, TempMiddle2, TempLoopj1, TempLoopj2: integer;

  PCurSrcElem, PCurDstElem: TN_BytesPtr;
  med, md, dl, Delta_l: integer;
  Middle, TempVal: integer;
  TempLoopSmall1, TempLoopSmall2: integer;

begin //********** main body of local procedure CalcOneRow2Byte
  TempMiddle1 := i2-i1+1;

    with WVars do
    begin

      PCurSrcElem :=  WPSrcBegX;
      PCurDstElem :=  WPDstBegX;

      // ***** For start element

      TempStepX := APSrcSM^.SMDStepX;
      TempStepY := APSrcSM^.SMDStepY;

      // Clear histogramm
      for Val := 0 to 65535 do HistArray[Val] := 0;

      for Val := 0 to 255 do HistArraySmall[Val] := 0;


      // Get histogramm for start element row=y, col=0
      for k := i1 to i2 do // k is algorythm window's size to x, from i1 to i2
      begin

        TempPByte1 := PCurSrcElem + k*TempStepY;

        for j := 0 to HCMDIM do // algorythm window's size to y
        begin
          Val := PWord( TempPByte1 + j*TempStepX )^;
          Inc( HistArray[Val] );

          TempVal := Val div 256; // temporary histogramm
          Inc( HistArraySmall[TempVal] );
        end; // for j := 0 to HCMDIM do

      end; // for k := i1 to i2 do

      TempMiddle2 := (i2-i1+1)*(HCMDIM+1);
      Middle := TempMiddle2 div 2; // number of a middle element of an array

      md := 0; // Calculate median for the temporary histogramm
      for TempVal := 0 to 255 do
      begin
        inc(md, HistArraySmall[TempVal]);
        if md > Middle then
        begin
          Dec( md, HistArraySmall[TempVal] );
          break;
        end;
      end;

      TempLoopSmall1 := TempVal*256; // Calculate actual median using a segment from histogram
      TempLoopSmall2 := (TempVal+1)*256 - 1;
      for Val := TempLoopSmall1 to TempLoopSmall2 do
      begin
        inc(md, HistArray[Val]);
        if md > Middle then break;
      end;
      med := Val;

      Delta_l := md - HistArray[Val]; // number of elements that is less than a middle

      PWord(PCurDstElem)^ := med; // Word is for 2^16 elems

      PCurDstElem := PCurDstElem + WDstStepX;

      // ***** For first group of elements

      //***** for cols

      for j := 1 to HCMDIM do // algorythm window's size to y
      begin
        j2 := j+HCMDIM;
        // next col

        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        TempMiddle2 := TempMiddle2+TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord(PCurDstElem)^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := 1 to HCMDIM do

      // ***** Second group of elements

      //***** for cols

      TempLoopj1 := HCMDIM+1;
      TempLoopj2 := WNX-HCMDIM-1;

      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;
        j2 := j+HCMDIM;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;
        TempPByte2 := PCurSrcElem + j2*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin

          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);

          Val := PWord( TempPByte2 + k*TempStepY )^;

          Inc( HistArray[Val]);
          if Val < med then Inc(Delta_l);
        end; // for k := i1 to i2 do

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := TempLoopj1 to TempLoopj2 do

      // ***** Third group of elements

      TempLoopj1 := WNX-HCMDIM;
      TempLoopj2 := WNX-1;

      //***** for cols
      for j := TempLoopj1 to TempLoopj2 do // algorythm window's size to y
      begin
        j1 := j-HCMDIM-1;

        // next col
        TempPByte1 := PCurSrcElem + j1*TempStepX;

        for k := i1 to i2 do // algorythm window's size to x, from i1 to i2
        begin
          Val := PWord( TempPByte1 + k*TempStepY )^;

          Dec( HistArray[Val]);
          if Val < med then Dec(Delta_l);
        end;

        TempMiddle2 := TempMiddle2-TempMiddle1;//(TempMiddle1*j + TempMiddle2) div 2;
        Middle := TempMiddle2 div 2;

        // ***** update new median
        dl := Delta_l;
        md := med;
        if dl > Middle then // correcting number of elements that is less than a middle
          begin
            while dl > Middle do
            begin
              Dec(md);
              if HistArray[md] > 0 then
                dec( dl, HistArray[md] );
              end;
          end
          else
          begin
            while dl + HistArray[md] <= Middle do
            begin
              if HistArray[md] > 0 then
              Inc( dl, HistArray[md] );
              Inc(md);
            end;
          end;

        Delta_l := dl; // applying new values
        med := md;

        PWord( PCurDstElem )^ := med;

        PCurDstElem := PCurDstElem + WDstStepX;
      end; // for j := WNX-HCMDIM to WNX-1 do
    end; // with WVars do
  end; // procedure CalcOneRow2Byte(i1, i2: integer); // local

begin //******************* main body of N_Conv2SMMedianHuangBinaryAndDelta
  TimerFlag := True;
  Timer := TN_CPUTimer1.Create;

  if TimerFlag then // Start timing
  begin
    Timer.Start;
  end;

  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  with WVars do
  begin

    CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes

    HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM

    case CaseInd of

    0: begin //********************************************** One byte elements

      SetLength( HistArray, 256 );

      SetLength( HistArraySmall, 16 );

      CalcOneRow1Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow1Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow1Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

    end; // 0: ***************************************** One byte elements

  1: begin //********************************************** Two bytes elements

      SetLength( HistArray, 65536 );

      SetLength( HistArraySmall, 256 );

      CalcOneRow2Byte( 0, HCMDIM );
      WPDstBegX := WPDstBegX + WSrcStepY;

      for i := 1 to HCMDIM do
      begin
        CalcOneRow2Byte( 0, HCMDIM + i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := HCMDIM + 1;
      TempLoop2 := WNY - HCMDIM - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i-HCMDIM, HCMDIM+i );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;

      TempLoop1 := WNY - HCMDIM;
      TempLoop2 := WNY - 1;
      for i := TempLoop1 to TempLoop2 do
      begin
        CalcOneRow2Byte( i, TempLoop2 );
        WPDstBegX := WPDstBegX + WSrcStepY;
      end;
    end; // 1: ***************************************** Two bytes elements

  end;
  end;

  if TimerFlag then // Stop timing
  begin
    Timer.Stop;
//    ShowMessage('Time = '+Timer.ToStr(1));
  end;

end; // procedure N_Conv2SMMedianHuangBinaryAndDelta





//******************************************************** N_Draw2SMbyMask1 ***
// ElemSize=6,8 not implemented!
//
// Draw given mask to given pixels using given color and mode
// (two operands)
//
//     Parameters
// APDrawSM   - Pointer to Resulting (Draw) Pixels SubMatrix description
// APMaskSM   - Pointer to 8bit Mask SubMatrix description
// ADrawColor - given color to draw
// ADrawMode  - draw mode
//#F
//  0 - SET given color  to  resulting pixels
//  1 - OR  given color with resulting pixels
//  2 - AND given color with resulting pixels
//  3 - XOR given color with resulting pixels
//#/F
//
// Both Resulting and Mask Submatrixes should have same Size.
//
procedure N_Draw2SMbyMask1( APDrawSM, APMaskSM: TN_PSMatrDescr; ADrawColor: integer; ADrawMode: integer  );
var
  ix, iy, CaseInd, Gray16Mask: integer;
  PSrcElem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
  Itmp : Integer;
begin
  N_Prep2SMWVars( APMaskSM, APDrawSM, @WVars ); // prpepare Working Variables
  CaseInd := APDrawSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  Gray16Mask := $0FFFF;
  if CaseInd = 2 then // preserve high bits if SMDNumBits < 16
    Gray16Mask := Gray16Mask shr (16-APDrawSM^.SMDNumBits);

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX;
    PDstElem := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      if PByte(PSrcElem)^ <> 0 then  // Mask elem <> 0 and should be drawn
      begin
        Itmp := PInteger(PDstElem)^;

        case ADrawMode of
        0: Itmp := ADrawColor; // Set
        1: Itmp := Itmp or ADrawColor;
        2: Itmp := Itmp and ADrawColor;
        3: Itmp := Itmp xor ADrawColor;
        end; // case ADrawMode of

        case CaseInd of
        0: PByte(PDstElem)^ := Byte(Itmp); //***** 1 -> 1
        1: begin                           //***** 2 -> 2
             Itmp := Itmp and Gray16Mask; // preserve high bits if SMDNumBits < 16
             PWord(PDstElem)^ := Word(Itmp);
           end; // 1: begin // 2 -> 2
        2: begin                           //***** 3,4 -> 3
             PWord(PDstElem)^   := Word(Itmp);
             PByte(PDstElem+2)^ := PByte((TN_BytesPtr(@Itmp)+2))^;
           end; // 2: begin // 3,4 -> 3
        end; // case CaseInd of
      end; // if PByte(PSrcElem)^ <> 0 then  // Mask elem <> 0 and should be drawn

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Draw2SMbyMask1

//******************************************************** N_Conv3SMProcObj ***
// Convert SubMatr Elements by given Procedure of Object (three operands)
//
//     Parameters
// APSrc1SM  - Pointer to Source SubMatrix 1 description (Thirst Operand)
// APSrc2SM  - Pointer to Source SubMatrix 2 description (Second Operand)
// APDstSM   - Pointer to Destination SubMatrix description
// AProcObj  - given Procedure of Object for one Element convertion
//
// AProcObj usage: AProcObj( APSrc1Elem, APSrc2Elem, APDstElem );
//
procedure N_Conv3SMProcObj( APSrc1SM, APSrc2SM, APDstSM: TN_PSMatrDescr; AProcObj: TN_ThreePtrsProcObj );
var
  ix, iy: integer;
  PSrc1Elem, PSrc2Elem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  if not Assigned( AProcObj ) then Exit; // a precaution
  N_Prep3SMWVars( APSrc1SM, APSrc2SM, APDstSM, @WVars );

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Rows
  begin
    PSrc1Elem := WPSrcBegX;
    PSrc2Elem := WPSrc2BegX;
    PDstElem  := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      AProcObj( PSrc1Elem, PSrc2Elem, PDstElem );

      PSrc1Elem := PSrc1Elem + WSrcStepX;  // to next Src1 Element in Row
      PSrc2Elem := PSrc2Elem + WSrc2StepX; // to next Src2 Element in Row
      PDstElem  := PDstElem  + WDstStepX;  // to next Dst  Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX  := WPSrcBegX  + WSrcStepY;  // to next Src1 Row
    WPSrc2BegX := WPSrc2BegX + WSrc2StepY; // to next Src2 Row
    WPDstBegX  := WPDstBegX  + WDstStepY;  // to next Dst  Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv3SMProcObj

//******************************************************** N_Conv3SMLinComb ***
// Calculate Linear combination of two given SubMatrixes (three operands)
//
//     Parameters
// APSrcSMD - Pointer to SubMatrix1 description
// APSM2    - Pointer to first Element of SubMatrix2
// APSMRes  - Pointer to first Element of Resulting SubMatrix
// AAlfa    - given coefficient for calculating Linear Combination
//
// All three Submatrixes should have same description
//
// ResSubMatrix = Alfa*SubMatrix2 + (1 - Alfa)*SubMatrix1
// Any Element Size is OK
//
procedure N_Conv3SMLinComb( APSrcSMD: TN_PSMatrDescr; APSM2, APSMRes: Pointer; AAlfa: double );
var
  ix, iy, CaseInd, itmp, MaxVal: integer;
  D2, DR: int64;
  Beta: double;
  PElem1, PElem2, PElemR: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  N_Prep1SMWVars( APSrcSMD, @WVars );
  D2 := TN_BytesPtr(APSM2)   - TN_BytesPtr(APSrcSMD^.SMDPBeg);
  DR := TN_BytesPtr(APSMRes) - TN_BytesPtr(APSrcSMD^.SMDPBeg);
  Beta := 1.0 - AAlfa;

  CaseInd := APSrcSMD^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  with WVars do
  begin

  if (CaseInd = 0) or (CaseInd = 2) then // 8 bit per channel (epfGray8 or pf24bit or pf32bit)
  begin

    for iy := 0 to WNY-1 do // along all Src and Dst Rows
    begin
      PElem1 := WPSrcBegX;
      PElem2 := PElem1 + D2;
      PElemR := PElem1 + DR;

      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        itmp := Round( AAlfa*PByte(PElem2+0)^ + Beta*PByte(PElem1+0)^ );
        if itmp < 0   then itmp := 0;
        if itmp > 255 then itmp := 255;
        PByte(PElemR+0)^ := itmp;

        // CaseInd = 1 is not implemened!

        if CaseInd = 2 then // 3,4 bytes, process rest bytes
        begin
          itmp := Round( AAlfa*PByte(PElem2+1)^ + Beta*PByte(PElem1+1)^ );
          if itmp < 0   then itmp := 0;
          if itmp > 255 then itmp := 255;
          PByte(PElemR+1)^ := itmp;

          itmp := Round( AAlfa*PByte(PElem2+2)^ + Beta*PByte(PElem1+2)^ );
          if itmp < 0   then itmp := 0;
          if itmp > 255 then itmp := 255;
          PByte(PElemR+2)^ := itmp;
        end; // if CaseInd = 2 then // 3,4 bytes, process rest bytes

        PElem1 := PElem1 + WSrcStepX; // to next SubMatrix1 Element in Row
        PElem2 := PElem2 + WSrcStepX; // to next SubMatrix2 Element in Row
        PElemR := PElemR + WSrcStepX; // to next Res. SubMatrix Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row

      WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end else //************************************** CaseInd = 1, epfGray16
  begin
    MaxVal := (1 shl APSrcSMD^.SMDNumBits) - 1;

    for iy := 0 to WNY-1 do // along all Src and Dst Rows
    begin
      PElem1 := WPSrcBegX;
      PElem2 := PElem1 + D2;
      PElemR := PElem1 + DR;

      for ix := 0 to WNX-1 do // along all elems in cur Row
      begin
        itmp := Round( AAlfa*PWORD(PElem2+0)^ + Beta*PWORD(PElem1+0)^ );
        if itmp < 0      then itmp := 0;
        if itmp > MaxVal then itmp := MaxVal;
        PWORD(PElemR+0)^ := itmp;

        PElem1 := PElem1 + WSrcStepX; // to next SubMatrix1 Element in Row
        PElem2 := PElem2 + WSrcStepX; // to next SubMatrix2 Element in Row
        PElemR := PElemR + WSrcStepX; // to next Res. SubMatrix Element in Row
      end; // for ix := 0 to NX-1 do // along all elems in cur Row

      WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // else //************************************** CaseInd = 1, epfGray16

  end; // with WVars do
end; // procedure N_Conv3SMLinComb

//*******************************************&&*********** N_Conv3SMPrepNR1 ***
// Prepare for Noise reduction #1 method:
// Calculate from given Matrix two Matrixes - Mean Values and Delta Values
//
//     Parameters
// APSrcSMD  - Pointer to all SubMatrixes description (APSrcSMD^.SMDPBeg points to Source SubMatr)
// APMeanSM  - Pointer to first Element of resulting weighted Mean SubMatr
// APDeltaSM - Pointer to first Element of resulting Delta SubMatr
//              (mean value of Abs. diff. between cur Source and all neghbour Source elems values)
// APCM      - Pointer to first element of Float coefficients Matrix
// ACMDim    - coefficients Matrix Dimension (should be odd)
//
// Float coefficients Matrix should have zero central element.
// Now only Element Size = 1,2 are implemented
//
procedure N_Conv3SMPrepNR1( APSrcSMD: TN_PSMatrDescr; APMeanSM, APDeltaSM: Pointer; // TN_BytesPtr;
                              APCM: PFloat; ACMDim: integer );
var
  ix, iy, jx, jy, kx, ky, ci, CaseInd, HCMDIM, kxMax, kyMax: integer;
  NCoefs, CentralInd, CurMean, CurDelta: integer;
  D1, D2: int64;
  PElemS, PElemM, PElemD, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  OutX, OutY: boolean;
  CurCoef: Float;
  WS1, SCSUM: double;
  SrcVals: TN_IArray;
  WVars: TN_ConvSMVars;
begin
  CurMean := 0; // to avoid warning
  
  N_Prep1SMWVars( APSrcSMD, @WVars );
  D1 := TN_BytesPtr(APMeanSM)  - TN_BytesPtr(APSrcSMD^.SMDPBeg);
  D2 := TN_BytesPtr(APDeltaSM) - TN_BytesPtr(APSrcSMD^.SMDPBeg);

  CaseInd := APSrcSMD^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;
  Assert( CaseInd <= 1, 'N_Conv3SMPrepNR1: Temporary not implemented!' );

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSMD^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSMD^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  CentralInd := HCMDIM*(ACMDim+1); // Index of Central Coefs Matr element

  NCoefs := ACMDim*ACMDim;
  SetLength( SrcVals,  NCoefs ); // Array for neighbour elements values

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src Rows
  begin
    PElemS := WPSrcBegX;
    PElemM := PElemS + D1;
    PElemD := PElemS + D2;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      ci := 0; // initial value of SrcVals and SrcFlags Arrays index

      with APSrcSMD^ do // shift WPSrcBegX to upper left by HCMDIM
        PCurSrcRow := PElemS - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

      //*** just fill SrcVals Array by neighbour elements

      if (ACMDim = 3) and (ix=19) then // debug
        N_i := 1;

      for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
      begin
        PCurSrcElem := PCurSrcRow;
        ky := iy + jy; // real index + HCMDIM
        OutY := (ky < HCMDIM) or (ky > kyMax);

        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
          kx := ix + jx; // real index + HCMDIM
          OutX := (kx < HCMDIM) or (kx > kxMax);

          SrcVals[ci] := -1; // Cur Elem is out of Matrix Flag

          if not (OutY or OutX) then // inside Matr
          begin
            case CaseInd of
            0: begin // One byte Element (both Src and Dst)
                 SrcVals[ci]  := PByte(PCurSrcElem)^;
               end; // 0: begin // One byte Element (both Src and Dst)
            1: begin // Two bytes Element (both Src and Dst)
                 SrcVals[ci]  := PWORD(PCurSrcElem)^;
               end; // 1: begin // Two bytes Element (both Src and Dst)
            end; // case CaseInd of
          end; // if not (OutY or OutX) then // inside Matr

          PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
          Inc( ci );
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

        PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
      end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

      if (ACMDim = 3) and (ix=19) then // debug
        N_i := 1;

      //*** SrcVals Array is OK, calculate weighted mean

      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      SCSUM := 0; // Scipped Coefs. Sum

      for ci := 0 to NCoefs-1 do // Calculate weighted mean value in WS1
      begin
        CurCoef := PFloat(TN_BytesPtr(APCM)+ci*SizeOf(Float))^;

        if SrcVals[ci] < 0 then // Out of Matr
        begin
          SCSUM := SCSUM + CurCoef; // add coef. to sum of unused coefs
        end else //*************** Inside Matr
        begin
          WS1 := WS1 + SrcVals[ci]*CurCoef; // process SrcVals[ci]
        end;
      end; // for ci := 0 to NCoefs-1 do // Calculate weighted mean value in WS1

      case CaseInd of
      0: begin // One byte Element (both Src and Dst)
           CurMean := Byte(Round( WS1/(1.0000001-SCSUM) )); // weighted mean value
           PByte(PElemM)^ := CurMean;
         end; // 0: begin // One byte Element (both Src and Dst)
      1: begin // Two bytes Element (both Src and Dst)
           CurMean := WORD(Round( WS1/(1.0000001-SCSUM) )); // weighted mean value
           PWORD(PElemM)^ := CurMean;
         end; // 1: begin // Two bytes Element (both Src and Dst)
      end; // case CaseInd of

      //***** Calculate  wieghted mean of abs differencies
      //      SCSUM is already OK

      WS1   := 0; // Weighted Sum to calculate (for single or first byte)

      for ci := 0 to NCoefs-1 do // Calculate weighted mean value of abs differences in WS1
      begin
        if SrcVals[ci] >= 0 then // Inside Matr
          WS1 := WS1 + abs( CurMean - SrcVals[ci] ) * PFloat(TN_BytesPtr(APCM)+ci*SizeOf(Float))^;
      end; // for ci := 0 to NCoefs-1 do // Calculate weighted mean value of abs differences WS1

      case CaseInd of
      0: begin // One byte Element (both Src and Dst)
           PByte(PElemD)^ := Byte(Round( WS1/(1.0000001-SCSUM) )); // weighted mean value of abs differences
         end; // 0: begin // One byte Element (both Src and Dst)
      1: begin // Two bytes Element (both Src and Dst)
           PWORD(PElemD)^ := WORD(Round( WS1/(1.0000001-SCSUM) )); // weighted mean value of abs differences
         end; // 1: begin // Two bytes Element (both Src and Dst)
      end; // case CaseInd of

      PElemS := PElemS + WSrcStepX; // to next Source SubMatrix Element in Row
      PElemM := PElemM + WSrcStepX; // to next Delta  SubMatrix Element in Row
      PElemD := PElemD + WSrcStepX; // to next MDelta SubMatrix Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv3SMPrepNR1

//********************************************************** N_Conv3SMDoNR1 ***
// Do Noise Reduction method #1 (Delete Noise from given Matrix)
//
//     Parameters
// APSrcSMD   - Pointer to all SubMatrixes (except Dst) description (APSrcSMD^.SMDPBeg points to Source SubMatr)
// APDstSMD   - Pointer to Resulting SubMatrix description
// APMeanSM   - Pointer to first Element of weighted Mean SubMatr (already calculated)
// APDeltaSM  - Pointer to first Element of Delta SubMatr (already calculated)
//              (mean value of Abs. diff. between cur Source and all neghbour Source elems values)
// APCM       - Pointer to first element of Float coefficients Matrix
// ACMDim     - coefficients Matrix Dimension (usually 3 or 5)
// ACheckCoef - coef. used to Check if element is Noise and should be replaced by mean value
// AMeanCoef  - coef. used to calculate mean value (new value for noisy element)
//
// Float coefficients Matrix should have zero central element
// Now only Element Size = 1,2 are implemented
//
procedure N_Conv3SMDoNR1( APSrcSMD, APDstSMD: TN_PSMatrDescr; APMeanSM, APDeltaSM: Pointer;
                          APCM: PFloat; ACMDim: integer; ACheckCoef, AMeanCoef: double );
var
  ix, iy, jx, jy, kx, ky, ci, CaseInd, HCMDIM, kxMax, kyMax: integer;
  NCoefs, CentralInd, CurVal, CurMean, CurRes, NEVal: integer;
  D1, D2: int64;
  PElemS, PElemM, PElemD, PElemR, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  OutX, OutY: boolean;
  CurCoef: Float;
  WS1, SCSUM, MaxDelta: double;
  WVars: TN_ConvSMVars;
  Label NextAlongX;
begin
//  if ACMDim = 3 then // debug
//    N_i := 1;

  CurVal   := 0; // to avoid warnings
  CurMean  := 0;
  CurRes   := 0;
  NEVal    := 0;
  MaxDelta := 0;

  N_Prep2SMWVars( APSrcSMD, APDstSMD, @WVars );
  D1 := TN_BytesPtr(APMeanSM)  - TN_BytesPtr(APSrcSMD^.SMDPBeg);
  D2 := TN_BytesPtr(APDeltaSM) - TN_BytesPtr(APSrcSMD^.SMDPBeg);

  CaseInd := APSrcSMD^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;
  Assert( CaseInd <= 1, 'N_Conv3SMDoNR1: Temporary not implemented!' );

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSMD^.SMDNumX-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSMD^.SMDNumY-1; // ky > kyMax means out of whole Matr

  CentralInd := HCMDIM*(ACMDim+1); // Index of Central Coefs Matr element
  NCoefs := ACMDim*ACMDim;

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Src and Dst Rows
  begin
    PElemS := WPSrcBegX;
    PElemM := PElemS + D1;
    PElemD := PElemS + D2;
    PElemR := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      case CaseInd of
      0: begin // One byte Element (both Src and Dst)
           CurVal  := PByte(PElemS)^;
           CurMean := PByte(PElemM)^;
           CurRes  := PByte(PElemD)^;
         end; // 0: begin // One byte Element (both Src and Dst)

      1: begin // Two bytes Element (both Src and Dst)
           CurVal  := PWORD(PElemS)^;
           CurMean := PWORD(PElemM)^;
           CurRes  := PWORD(PElemD)^;
         end; // 1: begin // Two bytes Element (both Src and Dst)
      end; // case CaseInd of

//      N_i := integer( PElemR ); // debug
//      if ACMDim = 3 then
//        N_PCAdd( 0, Format( 'ix,y=%d,%d', [ix,iy] ) );
//      if (ACMDim = 5) and (ix=19) then
//        N_i := 1;

      if abs( CurMean - CurVal ) <= ACheckCoef*CurRes then // Cur Delta is small
      begin
        case CaseInd of
        0: begin // One byte Element (both Src and Dst)
             PByte(PElemR)^ := CurVal; // leave current element Value as is
           end; // 0: begin // One byte Element (both Src and Dst)
        1: begin // Two bytes Element (both Src and Dst)
             PWORD(PElemR)^ := CurVal; // leave current element Value as is
           end; // 1: begin // Two bytes Element (both Src and Dst)
        end; // case CaseInd of

        goto NextAlongX;          // goto check next Element
      end; // if abs( CurMean - CurVal ) <= ACheckCoef*CurRes then // Cur Delta is small

      //***** Calculate new PElemS^ Value (Mean value excluding elems with big delta)

      with APSrcSMD^ do // shift WPSrcBegX to upper left by HCMDIM
        PCurSrcRow := PElemS - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

      ci := 0;

      //*** Calculate weighted mean for some (with not too big delta) elements

      WS1   := 0; // Weighted Sum to calculate
      SCSUM := 0; // Scipped Coefs. Sum

      case CaseInd of
      0: begin // One byte Element (both Src and Dst)
           MaxDelta := AMeanCoef*PByte(PElemD)^;
         end; // 0: begin // One byte Element (both Src and Dst)
      1: begin // Two bytes Element (both Src and Dst)
           MaxDelta := AMeanCoef*PWORD(PElemD)^;
         end; // 1: begin // Two bytes Element (both Src and Dst)
      end; // case CaseInd of

      for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
      begin
        PCurSrcElem := PCurSrcRow;
        ky := iy + jy;
        OutY := (ky < HCMDIM) or (ky > kyMax);

        for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
        begin
          kx := ix + jx; // real index + HCMDIM
          OutX := (kx < HCMDIM) or (kx > kxMax);

          if not (OutY or OutX) then // inside Matr
          begin
            case CaseInd of
            0: begin // One byte Element (both Src and Dst)
                 NEVal   := PByte(PCurSrcElem)^; // Neighbour Element Value
               end; // 0: begin // One byte Element (both Src and Dst)
            1: begin // Two bytes Element (both Src and Dst)
                 NEVal   := PWORD(PCurSrcElem)^; // Neighbour Element Value
               end; // 1: begin // Two bytes Element (both Src and Dst)
            end; // case CaseInd of

            if abs( CurMean - NEVal ) <= MaxDelta then // delta is OK, count NEVal
            begin
              CurCoef := PFloat(TN_BytesPtr(APCM)+ci*SizeOf(Float))^;
              WS1     := WS1 + NEVal*CurCoef;
              SCSUM   := SCSUM + CurCoef;
            end; // if abs( CurMean - NEVal ) <= MaxDelta then // delta is OK, count NEVal
          end; // if not (OutY or OutX) then // inside Matr

          PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
          Inc( ci );
        end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

        PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
      end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

      if (ix=6) and (iy=19) then // debug
        N_i := 1;

      case CaseInd of
      0: begin // One byte Element (both Src and Dst)
           if SCSUM = 0 then // all neighbours are bad (too big abs. difference)
             PByte(PElemR)^ := CurMean // use Mean value of all neighbours
           else
             PByte(PElemR)^ := Byte(Round( WS1/SCSUM )); // new value for Current element
         end; // 0: begin // One byte Element (both Src and Dst)
      1: begin // Two bytes Element (both Src and Dst)
           if SCSUM = 0 then // all neighbours are bad (too big abs. difference)
             PWORD(PElemR)^ := CurMean // use Mean value of all neighbours
           else
             PWORD(PElemR)^ := WORD(Round( WS1/SCSUM )); // new value for Current element
         end; // 1: begin // Two bytes Element (both Src and Dst)
      end; // case CaseInd of


      NextAlongX: //********************* goto next Element along X

      PElemS := PElemS + WSrcStepX; // to next Source SubMatrix Element in Row
      PElemM := PElemM + WSrcStepX; // to next Mean   SubMatrix Element in Row
      PElemD := PElemD + WSrcStepX; // to next Delta  SubMatrix Element in Row
      PElemR := PElemR + WDstStepX; // to next Resulting SubMatrix Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv3SMDoNR1

//******************************************************** N_Conv4SMProcObj ***
// Convert SubMatr Elements by given Procedure of Object (four operands)
//
//     Parameters
// APSrc1SM  - Pointer to Source SubMatrix 1 description (Thirst Operand)
// APSrc2SM  - Pointer to Source SubMatrix 2 description (Second Operand)
// APSrc3SM  - Pointer to Source SubMatrix 3 description (Third Operand)
// APDstSM   - Pointer to Destination SubMatrix description
// AProcObj  - given Procedure of Object for one Element convertion
//
// AProcObj usage: AProcObj( APSrc1Elem, APSrc2Elem, APSrc3Elem, APDstElem );
//
procedure N_Conv4SMProcObj( APSrc1SM, APSrc2SM, APSrc3SM, APDstSM: TN_PSMatrDescr; AProcObj: TN_FourPtrsProcObj );
var
  ix, iy: integer;
  PSrc1Elem, PSrc2Elem, PSrc3Elem, PDstElem: TN_BytesPtr;
  WVars: TN_ConvSMVars;
begin
  if not Assigned( AProcObj ) then Exit; // a precaution
  N_Prep4SMWVars( APSrc1SM, APSrc2SM, APSrc3SM, APDstSM, @WVars );

  with WVars do
  begin

  for iy := 0 to WNY-1 do // along all Rows
  begin
    PSrc1Elem := WPSrcBegX;
    PSrc2Elem := WPSrc2BegX;
    PSrc3Elem := WPSrc3BegX;
    PDstElem  := WPDstBegX;

    for ix := 0 to WNX-1 do // along all elems in cur Row
    begin
      AProcObj( PSrc1Elem, PSrc2Elem, PSrc3Elem, PDstElem );

      PSrc1Elem := PSrc1Elem + WSrcStepX;  // to next Src1 Element in Row
      PSrc2Elem := PSrc2Elem + WSrc2StepX; // to next Src2 Element in Row
      PSrc3Elem := PSrc3Elem + WSrc3StepX; // to next Src3 Element in Row
      PDstElem  := PDstElem  + WDstStepX;  // to next Dst  Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX  := WPSrcBegX  + WSrcStepY;  // to next Src1 Row
    WPSrc2BegX := WPSrc2BegX + WSrc2StepY; // to next Src2 Row
    WPSrc3BegX := WPSrc3BegX + WSrc3StepY; // to next Src3 Row
    WPDstBegX  := WPDstBegX  + WDstStepY;  // to next Dst  Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; // with WVars do
end; // procedure N_Conv4SMProcObj

//******************************************************** N_ConvMatrByMatr ***
// Matrixes convolution
//
//     Parameters
// ADMatr - resulting matrix
// ASMatr - source matrix
// ASDim  - source matrix dimension
// ACMatr - convolution matrix
// ACDim  - convolution matrix dimension
// Result - Returns Resulting Matrix Dimension
//
function N_ConvMatrByMatr( var ADMatr : TN_FArray;
                            ASMatr : TN_FArray; ASDim : Integer;
                            ACMatr : TN_FArray; ACDim : Integer ) : Integer;
var
  ksx, kcx, ix,iy, jx, jy, HSDim, HCDim, HDDim : Integer;
  DSum : Double;
//  ASum : Double;
begin

  HSDim := ASDim shr 1;
  HCDim := ACDim shr 1;
  HDDim := HSDim - HCDim;
  Result := HDDim * 2 + 1;
  SetLength( ADMatr, Result * Result );
//  ASum := 0;
  for iy := HCDim to ASDim - 1 - HCDim do
  begin
    for ix := HCDim to ASDim - 1  - HCDim do
    begin
       DSum := 0;
       for jy := 0 to ACDim - 1 do
       begin
         ksx := ix - HCDim + (iy + jy - HCDim) * ASDim;
         kcx := jy * ACDim;
         for jx := 0 to ACDim - 1 do
         begin
           DSum := DSum + ASMatr[jx + ksx] * ACMatr[jx + kcx];
         end;
       end;
//       ASum := ASum + DSum;
       ADMatr[ix - HCDim + (iy  - HCDim) * Result] := DSum;
    end;
  end;
//  for ksx := 0 to High(ADMatr) do
//    ADMatr[ksx] := ADMatr[ksx] / ASum;

end; // procedure N_ConvMatrByMatr

//**************************************************** N_Conv2SMby2DCleaner ***
// Convert given SubMatr using 2D cleaner filter
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - Aperture Dimension (usually 3 or 5)
// AThreshold - 2D cleaner filter threshold (from 0 to 1)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
// Алгоритм заменяет значение каждого пиксела на среднее значение тех его соседей,
// значение которых отличается от данного пиксела не более чем на заданную величину (порог).
// При этом соседи рассматриваются в области, определенной радиусом.
// Благодаря этому низкоуровневый шум размывается, а резкие детали остаются нетронутыми.
//
procedure N_Conv2SMby2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold: Float );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  CentralVal1, CentralVal2, CentralVal3 : Integer;
  WS1, WS2, WS3, SCSUM1, SCSUM2, SCSUM3: double;
  WVars: TN_ConvSMVars;
  WTheshold : Integer;
  YSkipIndsCheck, XSkipIndsCheck : Boolean;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

  AThreshold := Max( 0, Min( 1, AThreshold ) );
  WTheshold  := Round( ($1 shl APSrcSM^.SMDNumBits) * AThreshold );

  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;
    YSkipIndsCheck := (iy >= HCMDIM) and (iy + ACMDim - 1 <= kyMax);
    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM1 := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;
      XSkipIndsCheck := (ix >= HCMDIM) and (ix + ACMDim - 1 <= kxMax);

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 if (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
                 begin // PCurSrcElem element is inside Matr
                   SCSUM1 := SCSUM1 + 1;
                   WS1 := WS1 + PByte(PCurSrcElem)^;
                 end;
                 Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if ( (iy + jy >= HCMDIM) and (iy + jy <= kyMax) ) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   // get Coeff. value for PCurSrcElem Src Matr element

                   if ((ix + jx >= HCMDIM) and (ix + jx <= kxMax)) and
                      (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
                   begin // PCurSrcElem element is inside Matr
                     SCSUM1 := SCSUM1 + 1;
                     WS1 := WS1 + PByte(PCurSrcElem)^;
                   end;

                   Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)

      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 if (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
                 begin // PCurSrcElem element is inside Matr
                   SCSUM1 := SCSUM1 + 1;
                   WS1 := WS1 + PWord(PCurSrcElem)^; // Two bytes Src Element
                 end;
                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if ( (iy + jy >= HCMDIM) and (iy + jy <= kyMax) ) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   // get Coeff. value for PCurSrcElem Src Matr element

                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) and
                      (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
                   begin // PCurSrcElem element is inside Matr
                     SCSUM1 := SCSUM1 + 1;
                     WS1 := WS1 + PWord(PCurSrcElem)^; // Two bytes Src Element
                   end;

                   PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PWord(PDstElem)^ := Round( WS1/SCSUM1 ) // Two bytes Dst Element
           else
             PWord(PDstElem)^ := CentralVal1;
         end; // 1: begin // Two bytes Element (both Src and Dst)

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
           SCSUM2 := 0; // Scipped Coefs. Sum
           SCSUM3 := 0; // Scipped Coefs. Sum
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           CentralVal2 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM + 1)^;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM + 2)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 if (Abs(CentralVal1 - PByte(PCurSrcElem+0)^) <= WTheshold) then
                 begin
                   SCSUM1 := SCSUM1 + 1;
                   WS1 := WS1 + PByte(PCurSrcElem+0)^;
                 end;
                 if (Abs(CentralVal2 - PByte(PCurSrcElem+1)^) <= WTheshold) then
                 begin
                   SCSUM2 := SCSUM2 + 1;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^;
                 end;
                 if (Abs(CentralVal3 - PByte(PCurSrcElem+2)^) <= WTheshold) then
                 begin
                   SCSUM3 := SCSUM3 + 1;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;
                 if (kx >= HCMDIM) and (kx <= kxMax) and
                    (ky >= HCMDIM) and (ky <= kyMax) then
                 begin // PCurSrcElem element is inside Matr
                   if (Abs(CentralVal1 - PByte(PCurSrcElem+0)^) <= WTheshold) then
                   begin
                     SCSUM1 := SCSUM1 + 1;
                     WS1 := WS1 + PByte(PCurSrcElem+0)^;
                   end;
                   if (Abs(CentralVal2 - PByte(PCurSrcElem+1)^) <= WTheshold) then
                   begin
                     SCSUM2 := SCSUM2 + 1;
                     WS2 := WS2 + PByte(PCurSrcElem+1)^;
                   end;
                   if (Abs(CentralVal3 - PByte(PCurSrcElem+2)^) <= WTheshold) then
                   begin
                     SCSUM3 := SCSUM3 + 1;
                     WS3 := WS3 + PByte(PCurSrcElem+2)^;
                   end;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS, WS1, WS2 and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem+0)^ := Round( WS1/SCSUM1 ) // first  byte of Dst Element
           else
             PByte(PDstElem+0)^ := CentralVal1;
           if SCSUM2 <> 0 then
             PByte(PDstElem+1)^ := Round( WS2/SCSUM2 ) // second byte of Dst Element
           else
             PByte(PDstElem+1)^ := CentralVal2;
           if SCSUM3 <> 0 then
             PByte(PDstElem+2)^ := Round( WS3/SCSUM3 ) // third  byte of Dst Element
           else
             PByte(PDstElem+2)^ := CentralVal3;
         end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMby2DCleaner

//************************************************ N_Conv2SMbyMatr2DCleaner ***
//
// Not updated for 16 bin Images! Use N_Conv2SMby2DCleaner as example
//
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands) using 2D cleaner filter
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Matrix
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
// AThreshold - 2D cleaner filter threshold (from 0 to 1)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatr2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer; AThreshold: Float );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  CurCoef: Float;
  CentralVal1, CentralVal2, CentralVal3 : Integer;
  WS1, WS2, WS3, SCSUM1, SCSUM2, SCSUM3: double;
  WVars: TN_ConvSMVars;
  WTheshold : Integer;
  WPCM: TN_BytesPtr;
  YSkipIndsCheck, XSkipIndsCheck : Boolean;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

  N_Dump1Str(  'Start N_Conv2SMbyMatr' );

  AThreshold := Max( 0, Min( 1, AThreshold ) );
  if CaseInd = 1 then
    WTheshold := Round(16384 * AThreshold)
  else
    WTheshold := Round(256 * AThreshold);

  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;
    YSkipIndsCheck := (iy >= HCMDIM) and (iy + ACMDim - 1 <= kyMax);
    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM1 := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;
      XSkipIndsCheck := (ix >= HCMDIM) and (ix + ACMDim - 1 <= kxMax);

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               WPCM := TN_BytesPtr(APCM) + jy*ACMDim*SizeOf(Float);
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 if (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
                 begin // PCurSrcElem element is inside Matr
//                   CurCoef := PFloat( WPCM )^;
                   SCSUM1 := SCSUM1 + PFloat( WPCM )^;
                   WS1 := WS1 + PByte(PCurSrcElem)^ * PFloat( WPCM )^;
                 end;

                 Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
                 Inc( WPCM, SizeOf(Float) );
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 WPCM := TN_BytesPtr(APCM) + jy*ACMDim*SizeOf(Float);
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   // get Coeff. value for PCurSrcElem Src Matr element

                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) and
                      (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
                   begin // PCurSrcElem element is inside Matr
  //                   CurCoef := PFloat( WPCM )^;
                     SCSUM1 := SCSUM1 + PFloat( WPCM )^;
                     WS1 := WS1 + PByte(PCurSrcElem)^ * PFloat( WPCM )^;
                   end;

                   Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
                   Inc( WPCM, SizeOf(Float) );
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)
{}
      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               WPCM := TN_BytesPtr(APCM) + jy*ACMDim*SizeOf(Float);
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 if (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
                 begin // PCurSrcElem element is inside Matr
                   SCSUM1 := SCSUM1 + PFloat( WPCM )^;
                   WS1 := WS1 + PWord(PCurSrcElem)^*PFloat( WPCM )^; // Two bytes Src Element
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 Inc( WPCM, SizeOf(Float) );
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 WPCM := TN_BytesPtr(APCM) + jy*ACMDim*SizeOf(Float);
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   // get Coeff. value for PCurSrcElem Src Matr element

                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) and
                      (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
                   begin // PCurSrcElem element is inside Matr
                     SCSUM1 := SCSUM1 + PFloat( WPCM )^;
                     WS1 := WS1 + PWord(PCurSrcElem)^ * PFloat( WPCM )^; // Two bytes Src Element
                   end;

                   PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                   Inc( WPCM, SizeOf(Float) );
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PWord(PDstElem)^ := Round( WS1/SCSUM1 ) // Two bytes Dst Element
           else
             PWord(PDstElem)^ := CentralVal1;
         end; // 1: begin // Two bytes Element (both Src and Dst)

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
           SCSUM2 := 0; // Scipped Coefs. Sum
           SCSUM3 := 0; // Scipped Coefs. Sum
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           CentralVal2 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM + 1)^;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM + 2)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop

             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 if (Abs(CentralVal1 - PByte(PCurSrcElem+0)^) <= WTheshold) then
                 begin
                   SCSUM1 := SCSUM1 + CurCoef;
                   WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                 end;
                 if (Abs(CentralVal2 - PByte(PCurSrcElem+1)^) <= WTheshold) then
                 begin
                   SCSUM2 := SCSUM2 + CurCoef;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                 end;
                 if (Abs(CentralVal3 - PByte(PCurSrcElem+2)^) <= WTheshold) then
                 begin
                   SCSUM3 := SCSUM3 + CurCoef;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then

             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   // get Coeff. value for PCurSrcElem Src Matr element

                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) then
                   begin // PCurSrcElem element is inside Matr
                     CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                     if (Abs(CentralVal1 - PByte(PCurSrcElem+0)^) <= WTheshold) then
                     begin
                       SCSUM1 := SCSUM1 + CurCoef;
                       WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                     end;
                     if (Abs(CentralVal2 - PByte(PCurSrcElem+1)^) <= WTheshold) then
                     begin
                       SCSUM2 := SCSUM2 + CurCoef;
                       WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                     end;
                     if (Abs(CentralVal3 - PByte(PCurSrcElem+2)^) <= WTheshold) then
                     begin
                       SCSUM3 := SCSUM3 + CurCoef;
                       WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;
                     end;
                   end;

                   PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)


               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS, WS1, WS2 and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem+0)^ := Round( WS1/SCSUM1 ) // first  byte of Dst Element
           else
             PByte(PDstElem+0)^ := CentralVal1;
           if SCSUM2 <> 0 then
             PByte(PDstElem+1)^ := Round( WS2/SCSUM2 ) // second byte of Dst Element
           else
             PByte(PDstElem+1)^ := CentralVal2;
           if SCSUM3 <> 0 then
             PByte(PDstElem+2)^ := Round( WS3/SCSUM3 ) // third  byte of Dst Element
           else
             PByte(PDstElem+2)^ := CentralVal3;
         end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMbyMatr2DCleaner

//********************************************** N_Conv2SMbySpatialSmoother ***
//
// Not updated for 16 bin Images! Use N_Conv2SMby2DCleaner as example
//
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands) using 2D cleaner filter
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
// AThreshold - SpatialSmoother filter threshold (from 0 to 10)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbySpatialSmoother( APSrcSM, APDstSM: TN_PSMatrDescr;
                                      ACMDim: integer; AThreshold: Float );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  CentralVal1, CentralVal2, CentralVal3 : Integer;
  WS1, WS2, WS3, SCSUM1, SCSUM2, SCSUM3: double;
  WVars: TN_ConvSMVars;
  YSkipIndsCheck, XSkipIndsCheck : Boolean;
  Max2, WCoef, WCoef1, WCoef2, WCoef3 : Double;

begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepX - HCMDIM*SMDStepY;


  if CaseInd = 1 then
    Max2 := 16384
  else
    Max2 := 256;

  Max2 := Round(Max2 * Min(1, AThreshold));
  Max2 := Max2 * Max2 + 1;

  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;
    YSkipIndsCheck := (iy >= HCMDIM) and (iy + ACMDim - 1 <= kyMax);
    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM1 := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;
      XSkipIndsCheck := (ix >= HCMDIM) and (ix + ACMDim - 1 <= kxMax);

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop

             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 WCoef := CentralVal1 - PByte(PCurSrcElem)^;
                 WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                 SCSUM1 := SCSUM1 + WCoef;
                 WS1 := WS1 + PByte(PCurSrcElem)^*WCoef;

                 Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) then
                   begin // PCurSrcElem element is inside Matr
                     WCoef := CentralVal1 - PByte(PCurSrcElem)^;
                     WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                     SCSUM1 := SCSUM1 + WCoef;
                     WS1 := WS1 + PByte(PCurSrcElem)^*WCoef;
                   end;

                   Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
  //                 Inc( WPCM, SizeOf(Float) );
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)

      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;

           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop

             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WCoef := CentralVal1 - PWord(PCurSrcElem)^;
                 WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                 SCSUM1 := SCSUM1 + WCoef;
                 WS1 := WS1 + PWord(PCurSrcElem)^*WCoef;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
           // Some Outside Elems Loop

             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin
                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) then
                   begin // PCurSrcElem element is inside Matr
                   // get Coeff. value for PCurSrcElem Src Matr element
                     WCoef := CentralVal1 - PWord(PCurSrcElem)^;
                     WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                     SCSUM1 := SCSUM1 + WCoef;
                     WS1 := WS1 + PWord(PCurSrcElem)^*WCoef;
                   end;

                   PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PWord(PDstElem)^ := Round( WS1/SCSUM1 ) // Two bytes Dst Element
           else
             PWord(PDstElem)^ := CentralVal1;
         end; // 1: begin // Two bytes Element (both Src and Dst)

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
           SCSUM2 := 0; // Scipped Coefs. Sum
           SCSUM3 := 0; // Scipped Coefs. Sum
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           CentralVal2 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM + 1)^;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM  + 2)^;
           if YSkipIndsCheck and XSkipIndsCheck then
           begin
           // All Inside Elems Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WCoef := CentralVal1 - PByte(PCurSrcElem+0)^;
                 WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                 SCSUM1 := SCSUM1 + WCoef;
                 WS1 := WS1 + PByte(PCurSrcElem+0)^*WCoef;

                 WCoef := CentralVal2 - PByte(PCurSrcElem+1)^;
                 WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                 SCSUM2 := SCSUM2 + WCoef;
                 WS2 := WS2 + PByte(PCurSrcElem+1)^*WCoef;

                 WCoef := CentralVal3 - PByte(PCurSrcElem+2)^;
                 WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                 SCSUM3 := SCSUM3 + WCoef;
                 WS3 := WS3 + PByte(PCurSrcElem+2)^*WCoef;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           end // if YSkipIndsCheck and XSkipIndsCheck then
           else
           begin // if not YSkipIndsCheck or not XSkipIndsCheck then
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
               begin
                 for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
                 begin

                   if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) then
                   begin // PCurSrcElem element is inside Matr
                   // get Coeff. value for PCurSrcElem Src Matr element
                     WCoef := CentralVal1 - PByte(PCurSrcElem+0)^;
                     WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                     SCSUM1 := SCSUM1 + WCoef;
                     WS1 := WS1 + PByte(PCurSrcElem+0)^*WCoef;

                     WCoef := CentralVal2 - PByte(PCurSrcElem+1)^;
                     WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                     SCSUM2 := SCSUM2 + WCoef;
                     WS2 := WS2 + PByte(PCurSrcElem+1)^*WCoef;

                     WCoef := CentralVal3 - PByte(PCurSrcElem+2)^;
                     WCoef := (1 - Min(1.0, WCoef * WCoef / Max2));
                     SCSUM3 := SCSUM3 + WCoef;
                     WS3 := WS3 + PByte(PCurSrcElem+2)^*WCoef;
                   end;

                   PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           end; // if YSkipIndsCheck and XSkipIndsCheck then


           //***** Here: Double WS, WS1, WS2 and SCSUM are OK, calculate Dst element
           if SCSUM1 <> 0 then
             PByte(PDstElem+0)^ := Round( WS1/SCSUM1 ) // first  byte of Dst Element
           else
             PByte(PDstElem+0)^ := CentralVal1;
           if SCSUM2 <> 0 then
             PByte(PDstElem+1)^ := Round( WS2/SCSUM2 ) // second byte of Dst Element
           else
             PByte(PDstElem+1)^ := CentralVal2;
           if SCSUM3 <> 0 then
             PByte(PDstElem+2)^ := Round( WS3/SCSUM3 ) // third  byte of Dst Element
           else
             PByte(PDstElem+2)^ := CentralVal3;
         end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMbySpatialSmoother

//*************************************************** N_Conv2SMbyMatrMinMax ***
//
// Not updated for 16 bin Images! Use N_Conv2SMby2DCleaner as example
//
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Matrix (coefficients are ready to use, no normalization is needed)
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatrMinMax( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: PFloat; ACMDim: integer; ARShift: Float );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow: TN_BytesPtr;
  CurCoef: Float;
  WS1, WS2, WS3, SCSUM, AllSCSum: double;
  WVars: TN_ConvSMVars;
  RShift : Float;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  RShift := 255 * ARShift;
  if CaseInd = 1 then RShift := (256 * 256 - 1 ) * ARShift;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr


  PCurSrcElem := TN_BytesPtr(APCM);
  AllSCSum := 0;
  for kx := 1 to ACMDim * ACMDim do
  begin
    AllSCSum := AllSCSum  + PFloat(PCurSrcElem)^;
    PCurSrcElem := PCurSrcElem + SizeOf(Float);
  end;

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepX - HCMDIM*SMDStepY;

//  N_Dump1Str(  'Start N_Conv2SMbyMatr' );
  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;

    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)

           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WS1 := WS1 + PByte(PCurSrcElem)^ * PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

             PByte(PDstElem)^ := Round( Min( Max(WS1 + RShift, 0), 255 ) ); // One byte Dst Element

           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS and SCSUM are OK, calculate Dst element
             PByte(PDstElem)^ := Round( Min( Max((WS1 + RShift)/(AllSCSum-SCSUM), 0), 255 ) ); // One byte Dst Element
           end;

         end; // 0: begin // One byte Element (both Src and Dst)

      1: begin // Two bytes Element (both Src and Dst)
           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 WS1 := WS1 + PWord(PCurSrcElem)^ * PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             PWord(PDstElem)^ := Round( WS1 ); // Two bytes Dst Element
           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PWord(PCurSrcElem)^*CurCoef; // Two bytes Src Element
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS and SCSUM are OK, calculate Dst element
             PWord(PDstElem)^ := Round( WS1/(AllSCSum-SCSUM) ); // Two bytes Dst Element
           end;

         end; // 1: begin // Two bytes Element (both Src and Dst)

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
           if (ix >= HCMDIM) and (ix <= kxMax - ACMDim + 1) and
              (iy >= HCMDIM) and (iy <= kyMax - ACMDim + 1) then // PCurSrcElem element is out of Matr
           begin
           // All Elems Inside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                 WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                 WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             PByte(PDstElem+0)^ := Round( WS1 ); // first  byte of Dst Element
             PByte(PDstElem+1)^ := Round( WS2 ); // second byte of Dst Element
             PByte(PDstElem+2)^ := Round( WS3 ); // third  byte of Dst Element
           end
           else
           begin
           // Some Elems Outside Loop
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;

               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( TN_BytesPtr(APCM) + (jx + jy*ACMDim)*SizeOf(Float) )^;

                 kx := ix + jx; // real index + HCMDIM
                 ky := iy + jy;

                 if (kx < HCMDIM) or (kx > kxMax) or
                    (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
                 begin
                   SCSUM := SCSUM + CurCoef;
                 end else // PCurSrcElem element is inside Matr
                 begin
                   WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             //***** Here: Double WS, WS1, WS2 and SCSUM are OK, calculate Dst element
             PByte(PDstElem+0)^ := Round( WS1/(AllSCSum-SCSUM) ); // first  byte of Dst Element
             PByte(PDstElem+1)^ := Round( WS2/(AllSCSum-SCSUM) ); // second byte of Dst Element
             PByte(PDstElem+2)^ := Round( WS3/(AllSCSum-SCSUM) ); // third  byte of Dst Element
           end;

         end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of
//      if N_b2 then N_T1.SS( 'One loop' );

      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMbyMatrMinMax

//********************************************************** N_GetSMElement ***
// Get one Element Value
//
//     Parameters
// APSMatr - Pointer to SubMatrix description
// AIndX   - X coordinate of needed Element
// AIndY   - Y coordinate of needed Element
// Result  - Return needed Element Value
//
function N_GetSMElement( APSMatr: TN_PSMatrDescr; AIndX, AIndY: integer ): integer;
var
  iy: integer;
  PElem: TN_BytesPtr;
begin
  with APSMatr^ do
  begin
    iy := SMDNumY - AIndY - 1; // All Matrixes are Bottom Up
    PElem := SMDPBeg + iy*SMDStepY + AIndX*SMDStepX;

    case SMDElSize of
      1: Result := PByte(PElem)^;
      2: Result := PWord(PElem)^;
      3: Result := PInteger(PElem)^ and $0FFFFFF;
      4: Result := PInteger(PElem)^;
      else
         Result := -2; // to avoid warning
    end; // case SMDElSize of
  end; // with APSMatr^ do
end; // function N_GetSMElement

//************************************************************** N_SMToText ***
// Add to AResStrings all pixel values of APSMatr, using N_IntToStr
//
//     Parameters
// APSMatr     - Pointer to SubMatrix description
// AFlags      - Format flags, see N_IntToStr (=0 - decimal, <>0 Hex)
// AName       - given Matrix Name to add Header as first string (or '' if not needed)
// AResStrings - Given Strings Object to add SubMatrix content
// APUpperLeft - Pointer to SubMatr Upper Left Pixel Coords (just for Row and Columns numbering),
//               nil means (0, 0) Upper Left Pixel coords
// APMatrElems - Pointer to first Matrix Element,
//               nil means that APSMatr^.SMDPBeg value should be used
//
// One text strings represent one SubMatr pixel Row
//
procedure N_SMToText( APSMatr: TN_PSMatrDescr; AFlags: integer; AName: string;
                      AResStrings: TStrings; APUpperLeft: PPoint = nil; APMatrElems: Pointer = nil );
var
  BegX, EndX, NumX, BegY, EndY, NumY, CurVal: integer;
  i, j, StrOfs, ColWidth, StrSize: integer;
  UpperLeft: TPoint;
  Str, Str1: string;
  WrkSMatr: TN_SMatrDescr;
begin
  WrkSMatr := APSMatr^;

  if APMatrElems <> nil then
    WrkSMatr.SMDPBeg := APMatrElems;

  if (AFlags and $F0) = 0 then // Set second AFlags hex digit by APSMatr.SMDElSize
  begin
    case APSMatr.SMDElSize of
    1: AFlags := AFlags or $10;
    2: AFlags := AFlags or $20;
    3: AFlags := AFlags or $30;
    4: AFlags := AFlags or $30;
    6: AFlags := AFlags or $60;
    8: AFlags := AFlags or $60;
    end; // case APSMatr.SMDElSize of
  end;

  with WrkSMatr do
  begin
    BegX := min( SMDBegIX, SMDEndIX );
    EndX := max( SMDBegIX, SMDEndIX );
    NumX := EndX - BegX + 1;

    BegY := min( SMDBegIY, SMDEndIY );
    EndY := max( SMDBegIY, SMDEndIY );
    NumY := EndY - BegY + 1;

    if APUpperLeft <> nil then
      UpperLeft := APUpperLeft^
    else
      UpperLeft := Point( 0, 0 );

    if AName <> '' then // AName is given, add Header strings
    begin
      AResStrings.Add( Format( '   Matr %s %dx%d, ElemSize=%d, NumBits=%d, SubMatr %dx%d',
                       [AName, SMDNumX, SMDNumY, SMDElSize, SMDNumBits, NumX, NumY] ));
    end;

    with UpperLeft do
      AResStrings.Add( Format( '          Pixels in (%d,%d, %d,%d) Rect:', [X,Y,X+NumX-1,Y+NumY-1] ) );

    CurVal := N_GetSMElement( @WrkSMatr, 0, 0 ); // any indexes are OK
    StrOfs := 6;
    ColWidth := max( 5, Length( N_IntToStr( CurVal, AFlags ) ) + 2 );

    StrSize := StrOfs + ColWidth*NumX;
    SetLength( Str, StrSize );
    FillChar( Str[1], StrSize, ' ' );

    for j := BegX to EndX do // Prepare Header with Columns Indexes
    begin
      Str1 := Format( '%d', [UpperLeft.X+j] );
      move( Str1[1], Str[StrOfs+2+(j-BegX)*ColWidth], Length(Str1) );
    end; // for j := BegX to EndX do // Prepare Header with Columns Indexes
    AResStrings.Add( Str );

    for i := BegY to EndY do // along All Rows
    begin
      FillChar( Str[1], StrSize, ' ' );
      Str1 := Format( '%4d', [UpperLeft.Y+i] ); // Row Index
      move( Str1[1], Str[1], Length(Str1) );

      for j := BegX to EndX do // Prepare Elems values for i-th Row
      begin
        CurVal := N_GetSMElement( @WrkSMatr, j, i );

        Str1 := N_IntToStr( CurVal, AFlags ); // Convert Pixel value to string

        move( Str1[1], Str[StrOfs+2+(j-BegX)*ColWidth], Length(Str1) );
      end; // for j := BegX to EndX do // Prepare Header with Columns Indexes

      AResStrings.Add( Str );
    end; // for i := BegY to EndY do // along All Rows

  end; // with APSMatr^ do
end; // procedure N_SMToText

//******************************************************* N_ArcTangLikeFunc ***
// ArcTangent like function (from X=[0,2] to Y=[0,2])
//
//     Parameters
// AArg     - given argument in [0,2] range
// AFixArg  - given Fixed Argument value in [0,2] range
// AFixFunc - given Fixed Function value in [0,2] range
// AFormFactor - given function Form Factor > 0, in (0,1] range,  =1 means linear function from [0,2] -> [0,2]
// Result      - calculated resulting value in [0,2] range
//
// N_ArcTangLikeFunc( AFixArg ) is always equal to AFixFunc
//
function N_ArcTangLikeFunc( AArg, AFixArg, AFixFunc, AFormFactor: double ): double;
begin
  if AArg < 0 then AArg := 0;
  if AArg > 2 then AArg := 2;
  if (AFixArg <= 0)  or (AFixArg >= 2)  then AFixArg  := 1.0;
  if (AFixFunc <= 0) or (AFixFunc >= 2) then AFixFunc := 1.0;
  if AFormFactor <= 0 then AFormFactor := 1.0;

  if AArg <= AFixArg then // AArg in [0,AFixArg] range
  begin
    Result := AFixFunc * Power( AArg/AFixArg, AFormFactor );
  end else // AArg in (AFixArg,2] range
  begin
    Result := AFixFunc + (2.0 - AFixFunc) * (1.0 - Power( (2.0 - AArg)/(2.0 - AFixArg), AFormFactor ));
  end;
end; // function N_ArcTangLikeFunc

//***************************************************** N_CreateArcTangXLAT ***
// Create XLAT Table, based on N_ArcTangLikeFunc
//
//     Parameters
// AXLAT    - integer XLAT Table (on input and output)
// AFixInd  - given Fixed index value in [0,ANumInds-1] range
// AFixFunc - given Fixed XLAT value (XLAT[AFixInd] = AFixFunc) in (0,255) range
// ANumInds - number of elements in XLAT Table
// AFormFactor - given N_ArcTangLikeFunc function, Form Factor > 0, in (0,1] range
//
// XLAT values are smoothly increased from 0 to 255,
// XLAT[0] = 0, XLAT[AFixInd] = AFixFunc and XLAT[ANumInds-1] = 255
//
procedure N_CreateArcTangXLAT( var AXLAT: TN_IArray; AFixInd, AFixFunc,
                                       ANumInds: integer; AFormFactor: double );
var
  i: integer;
  DArg, DFixArg, DFixFunc: double;
begin
  Assert( ANumInds > 2, 'Bad XLAT Size!' );

  if Length(AXLAT) < ANumInds then SetLength( AXLAT, ANumInds );

  for i := 0 to ANumInds-1 do // along all XLAT elements
  begin
    DArg     := 2.0 * i / (ANumInds-1);       // in [0,2] range
    DFixArg  := 2.0 * AFixInd / (ANumInds-1); // in (0,2) range
    DFixFunc := 2.0 * AFixFunc / 255.0;       // in (0,2) range

    AXLAT[i] := Round( 0.5 * 255 * N_ArcTangLikeFunc( DArg, DFixArg, DFixFunc, AFormFactor ) );
  end; // for i := 0 to ANumInds-1 do // along all XLAT elements
end; // procedure N_CreateArcTangXLAT


procedure example1();
// Основное уравнение линии, проходящей через две точки P1, P2:
// X = P1.X + Alfa*(P2.X-P1.X)
// Y = P1.Y + Alfa*(P2.Y-P1.Y)
// Alfa=0 means (X,Y)=P1, Alfa < 0 means that (X,Y) before P1, Alfa > 1 - after P2

// Нужно решить систему уравнений:

// X = P1.X + Alfa*(P2.X-P1.X) (1)
// Y = P1.Y + Alfa*(P2.Y-P1.Y) (2)
// X = P3.X + Beta*(P4.X-P3.X) (3)
// Y = P3.Y + Beta*(P4.Y-P3.Y) (4)

// относительно точки пересечения (X,Y) и коеф. Alfa, Beta определяющих
// положение точки пересечения (X,Y) относительно отрезков (P1,P2) и (P3,P4)

// From (1),(3):
// P1.X + Alfa*(P2.X-P1.X) = P3.X + Beta*(P4.X-P3.X)
// Alfa = ( (P3.X - P1.X) + Beta*(P4.X-P3.X) ) / (P2.X-P1.X)
// Alfa = ( d31x + Beta*d43x ) / d21x;

// From (2),(4):
// Alfa = ( d31y + Beta*d43y ) / d21y;

// (d31x + Beta*d43x) / d21x = (d31y + Beta*d43y) / d21y;
// (d31x + Beta*d43x) * d21y = (d31y + Beta*d43y) * d21x;
// d31x*d21y + Beta*d43x*d21y = d31y*d21x + Beta*d43y*d21x;
// Beta*(d43x*d21y - d43y*d21x) = d31y*d21x - d31x*d21y;
// Beta := (d31y*d21x - d31x*d21y) / (d43x*d21y - d43y*d21x);

var
  P1, P2, P3, P4: TFPoint;
  d31x, d43x, d21x, d31y, d43y, d21y: double;
  X, Y, Alfa, Beta, Znam: double;
begin
  d31x := P3.X - P1.X;
  d43x := P4.X - P3.X;
  d21x := P2.X - P1.X;

  d31y := P3.Y - P1.Y;
  d43y := P4.Y - P3.Y;
  d21y := P2.Y - P1.Y;

  Znam := (d43x*d21y - d43y*d21x);

  if abs(Znam) < 1.0e-10 then // Parallel Segments
  begin
  end;

  Beta := (d31y*d21x - d31x*d21y) / Znam;

  X := P3.X + Beta*d43x;
  Y := P3.Y + Beta*d43y;

  if abs(d21x) < 1.0e-10 then
    Alfa := (Y - P1.Y)/d21y
  else
    Alfa := (X - P1.X)/d21x;

  N_d := Alfa;
  // X, Y, Alfa, Beta are OK
end; // procedure example1();

procedure example2();
begin

end; // procedure example2();

//   4(100)    5(101)    6(110)    7(111)  FlipRotate Flags decimal(binary)
//
//        *    *              *     *
//    *   *    *   *          *     *
//   ******    ******    ******     ******
//        *    *          *   *     *   *
//        *    *              *     *
//var N_Rotate90Flags: Array [0..7] of integer = ( 6, 4, 7, 5, 2, 0, 3, 1 ); // old var


end.
