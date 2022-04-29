unit K_Gra1;

interface

uses N_Types, N_Gra6;
{
procedure K_CalcGaussMatr    ( var AMatr : TN_FArray; ADim : Integer; ASigma : Double;
                               AFlags : Integer = 0 );
procedure K_CalcGaussVector  ( var AVector : TN_FArray; ADim : Integer; ASigma : Double );
function  K_ConvMatrByMatr( var ADMatr : TN_FArray;
                            ASMatr : TN_FArray; ASDim : Integer;
                            ACMatr : TN_FArray; ACDim : Integer ) : Integer;
procedure K_CalcLaplasMatr( var ADMatr : TN_FArray; AFactor : Float );
procedure K_Conv2SMby2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold : Float );
procedure K_Conv2SMbyMatr2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer; AThreshold : Float );
procedure K_Conv2SMbySpatialSmoother( APSrcSM, APDstSM: TN_PSMatrDescr;
                                      ACMDim: integer; AThreshold : Float );
procedure K_Conv2SMbyMatrMinMax( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer; ARShift : Float );
}

implementation

uses Math;

{$OPTIMIZATION ON}

//##path K_Delphi\SF\K_clib\K_CLib0.pas\K_CalcGaussMatr
//********************************************************* K_CalcGaussMatr ***
// Calculate Gauss Matrix by given matrix dimension and sigma
//
//     Parameters
// AMatr  - resulting matrix
// ADim   - matrix dimension
// ASigma - Gauss function Sigma factor
// AFlags - matrix build parameter (now if <> 0 then central element set to 0)
//
procedure K_CalcGaussMatr( var AMatr : TN_FArray; ADim : Integer; ASigma : Double;
                           AFlags : Integer = 0 );
var
  MatrixCapacity : Integer;
  i, j, CInd, NInd, HDim : Integer;
  DX, DY, DStep : Integer;
  Sum : Double;
begin
  MatrixCapacity := ADim * ADim;
  if Length(AMatr) < MatrixCapacity then begin
    AMatr := nil;
    SetLength( AMatr, MatrixCapacity );
  end;
  HDim := ADim shr 1;
  ASigma := ASigma * HDim;
  ASigma := 2 * ASigma * ASigma; // Sigma Square

  Sum := 0;
  CInd := 0; // for Delphi warning prevent
  // Calc Matrix Upper/Left Corner
  for i := 0 to HDim do
  begin
    CInd := i * ADim;
    DY := HDim - i;
    for j := CInd to CInd + HDim do
    begin
      DX := CInd + HDim - j;
      AMatr[j] := exp( - (DX*DX + DY*DY) / ASigma );
      Sum := Sum + AMatr[j];
    end;
  end;

  if AFlags <> 0 then begin
  // Clear Matrix Central Element
    j := CInd  + HDim;
    Sum := Sum - AMatr[j];
    AMatr[j] := 0;
  end;

  // Fill Matrix Upper/Right Corner
  for i := 0 to HDim do
  begin
    CInd := i * ADim;
    NInd := CInd + ADim - 1;
    for j := CInd to CInd + HDim - 1 do
    begin
      AMatr[NInd] := AMatr[j];
      Sum := Sum + AMatr[j];
      Dec(NInd);
    end;
  end;

  // Calc Proper Sum
  Sum := Sum + Sum;
  CInd := HDim * ADim;
  for j := CInd to CInd + ADim - 1 do
    Sum := Sum - AMatr[j];

  // Correct Matrix By Sum and fill Matrix Low Half
  NInd := ADim * (ADim - 1);
  DStep := ADim * SizeOf(Float);
  for i := 0 to HDim - 1 do
  begin
    CInd := i * ADim;
    for j := CInd to CInd + ADim - 1 do
      AMatr[j] := AMatr[j] / Sum;
    Move( AMatr[CInd], AMatr[NInd], DStep );
    Dec( NInd, ADim);
  end;

  CInd := HDim * ADim;
  for j := CInd to CInd + ADim - 1 do
    AMatr[j] := AMatr[j] / Sum;

end; // procedure K_CalcGaussMatr

//********************************************************* K_CalcGaussVector ***
// Calculate Gauss Matrix by given matrix dimension and sigma
//
//     Parameters
// AVector  - resulting vector
// ADim   - matrix dimension
// ASigma - Gauss function Sigma factor
//
procedure K_CalcGaussVector( var AVector : TN_FArray; ADim : Integer; ASigma : Double );
var
  MatrixCapacity : Integer;
  i, HDim : Integer;
  Sum : Double;
begin
  MatrixCapacity := ADim;
  if Length(AVector) < MatrixCapacity then begin
    AVector := nil;
    SetLength( AVector, MatrixCapacity );
  end;
  HDim := ADim shr 1;
  ASigma := ASigma * HDim;
  ASigma := 2 * ASigma * ASigma; // Sigma Square

  Sum := 0;
  // Calc Matrix Left Corner
  for i := 0 to HDim do
  begin
    AVector[i] := exp( - (HDim - i) * (HDim - i) / ASigma );
    Sum := Sum + AVector[i];
  end;

  // Fill Matrix Right Corner
  for i := 0 to HDim - 1 do
  begin
    AVector[ADim - i - 1] := AVector[i];
    Sum := Sum + AVector[i];
  end;


  for i := 0 to ADim - 1 do
    AVector[i] := AVector[i] / Sum;
end; // procedure K_CalcGaussVector

//********************************************************* K_ConvMatrByMatr ***
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
function K_ConvMatrByMatr( var ADMatr : TN_FArray;
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

end; // procedure K_ConvMatrByMatr

//********************************************************* K_CalcLaplasMatr ***
// Matrixes convolution
//
//     Parameters
// ADMatr  - resulting matrix
// AFactor - Laplas coeficients factor
//
procedure K_CalcLaplasMatr( var ADMatr : TN_FArray; AFactor : Float );
begin
  SetLength( ADMatr, 9 );
  AFactor := Max( Min( AFactor, 2 ), 0 );
  ADMatr[0] := AFactor - 1;
  ADMatr[1] := - AFactor;
  ADMatr[2] := ADMatr[0];

  ADMatr[3] := ADMatr[1];
  ADMatr[4] := 4;
  ADMatr[5] := ADMatr[1];

  ADMatr[6] := ADMatr[0];
  ADMatr[7] := ADMatr[1];
  ADMatr[8] := ADMatr[2];
end; // procedure K_CalcLaplasMatr

//********************************************************* K_Conv2SMby2DCleaner ***
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands) using 2D cleaner filter
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
//
procedure K_Conv2SMby2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold : Float );
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
end; // procedure K_Conv2SMby2DCleaner

//********************************************************* K_Conv2SMbyMatr2DCleaner ***
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
procedure K_Conv2SMbyMatr2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer; AThreshold : Float );
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

  N_Dump1Str(  'Start K_Conv2SMbyMatr' );

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

               WPCM := APCM + jy*ACMDim*SizeOf(Float);
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
                 WPCM := APCM + jy*ACMDim*SizeOf(Float);
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

               WPCM := APCM + jy*ACMDim*SizeOf(Float);
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
                 WPCM := APCM + jy*ACMDim*SizeOf(Float);
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

                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
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
                     CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
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
end; // procedure K_Conv2SMbyMatr2DCleaner

//********************************************************* K_Conv2SMbySpatialSmoother ***
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
procedure K_Conv2SMbySpatialSmoother( APSrcSM, APDstSM: TN_PSMatrDescr;
                                      ACMDim: integer; AThreshold : Float );
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
end; // procedure K_Conv2SMbySpatialSmoother

//********************************************************* K_Conv2SMbyMatrMinMax ***
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
procedure K_Conv2SMbyMatrMinMax( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer; ARShift : Float );
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


  PCurSrcElem := APCM;
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

//  N_Dump1Str(  'Start K_Conv2SMbyMatr' );
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
                 WS1 := WS1 + PByte(PCurSrcElem)^ * PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
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
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

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
                 WS1 := WS1 + PWord(PCurSrcElem)^ * PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
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
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

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
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
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
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

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
end; // procedure K_Conv2SMbyMatrMinMax

{$OPTIMIZATION OFF}

end.
