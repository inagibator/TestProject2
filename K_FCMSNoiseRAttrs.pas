unit K_FCMSNoiseRAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CM0, K_UDT1, K_CLib0;

type TK_FormCMSNoiseRAttrs = class(TN_BaseForm)
    Timer: TTimer;

    BtCancel: TButton;
    BtOK    : TButton;
    BtApply: TButton;
    LbThresh1: TLabel;
    LbThresh2: TLabel;
    TBThresh1: TTrackBar;
    TBThresh2: TTrackBar;
    bnTest: TButton;
    Label1: TLabel;
    LbSigma: TLabel;
    CmBDepth: TComboBox;
    EdSigmaVal: TEdit;
    LbTimeInfo: TLabel;
    TBSigma: TTrackBar;
    EdThreshold1Val: TEdit;
    EdThreshold2Val: TEdit;
    CmBFilterType: TComboBox;

    procedure TBThresh1Change ( Sender: TObject );
    procedure BtApplyClick    ( Sender: TObject );
    procedure TimerTimer      ( Sender: TObject );
    procedure TBDepthChange   ( Sender: TObject );
    procedure bnTestClick     ( Sender: TObject );
    procedure TBSigmaChange(Sender: TObject);
    procedure EdSigmaValKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure EdThreshold1ValKeyPress(Sender: TObject; var Key: Char);
    procedure CmBDepthChange(Sender: TObject);
  private
    SkipRebuild : Boolean;
    SkipApply   : Boolean;
    LSFSigma : TK_LineSegmFunc;
    LSFThresh : TK_LineSegmFunc;

    NRDepth : Integer;
    NRSigma : Double;
    NRThresh1 : Double;
    NRThresh2 : Double;

    PrevPosition1 : Integer;
    PrevTrackBar1 : TObject;
    PrevPosition2 : Integer;
    PrevTrackBar2 : TObject;

//    DoApplyAfter: Boolean;
    DoOKAfter: Boolean;
    ApplyOKWait: Boolean;
    PrevSigmaPosition : Integer;
//    PrevSmoothTypeIndex : Integer;
  public
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    MeanMatr:  TN_BArray;
    DeltaMatr: TN_BArray;
    NRCoefs: TN_FArray;

    procedure CalcMeanDeltaMatr ();
  end; // type TK_FormCMSNoiseRAttrs = class(TN_BaseForm)

var
  K_FormCMSNoiseRAttrs: TK_FormCMSNoiseRAttrs;

function K_CMSNoiseRedDlg( ) : Boolean;

implementation

uses Math,
  N_Gra3, N_Lib0, N_CompBase, N_Lib1, N_CMMain5F, N_Gra6;

{$R *.dfm}
{$OPTIMIZATION ON}
//********************************************************* N_Conv2SMbyMatr ***
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
procedure N_Conv2SMbyMatr2DCleaner( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer; AThreshold : Float );
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
//      N_b2 := (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY);
//      if N_b2 then N_T1.Start();
//      if (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY) then N_T1.Start();

      case CaseInd of

{ slow
      0: begin // One byte Element (both Src and Dst)
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               // get Coeff. value for PCurSrcElem Src Matr element
               CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) then
               begin // PCurSrcElem element is inside Matr
                 SCSUM1 := SCSUM1 + CurCoef;
                 WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           PByte(PDstElem)^ := Round( WS1/SCSUM1 ); // One byte Dst Element
         end; // 0: begin // One byte Element (both Src and Dst)
{}
{ slow optimize pointer
      0: begin // One byte Element (both Src and Dst)
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

//             ky := iy + jy;
             if (iy + jy >= HCMDIM) and (iy + jy <= kyMax) then
             begin
               WPCM := APCM + jy*ACMDim*SizeOf(Float);
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( WPCM )^;

//                 kx := ix + jx; // real index + HCMDIM
                 if (ix + jx >= HCMDIM) and (ix + jx <= kxMax) then
                 begin // PCurSrcElem element is inside Matr
                   SCSUM1 := SCSUM1 + CurCoef;
                   WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
                 end;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 Inc( WPCM, SizeOf(Float) );
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             end;
             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           PByte(PDstElem)^ := Round( WS1/SCSUM1 ); // One byte Dst Element
         end; // 0: begin // One byte Element (both Src and Dst)
{}
{ quick
      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           kx := ix + ACMDim-1; // real index + HCMDIM
           ky := iy + ACMDim-1;

           if (ix >= HCMDIM) and (kx <= kxMax) and
              (iy >= HCMDIM) and (ky <= kyMax) then
           begin
             for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
             begin
               PCurSrcElem := PCurSrcRow;
               WPCM := APCM + jy*ACMDim*SizeOf(Float);
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element
                 CurCoef := PFloat( WPCM )^;

                 SCSUM1 := SCSUM1 + CurCoef;
                 WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;

                 PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
                 Inc( WPCM, SizeOf(Float) );
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

               PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
             end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

             //***** Here: Double WS and SCSUM are OK, calculate Dst element
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ); // One byte Dst Element
           end;
         end; // 0: begin // One byte Element (both Src and Dst)
{}
{ Init optimized }
      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
//if (iy = 0) and (ix = 2) then
//SCSUM1 := 0;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             if YSkipIndsCheck or
                ( (iy + jy >= HCMDIM) and (iy + jy <= kyMax) ) then
             begin
               WPCM := APCM + jy*ACMDim*SizeOf(Float);
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 if ( XSkipIndsCheck or
                      ((ix + jx >= HCMDIM) and (ix + jx <= kxMax)) ) and
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

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
//if SCSUM1 = 0 then
//  SCSUM1 := 1;
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)
{}
{ Init
      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               // get Coeff. value for PCurSrcElem Src Matr element
               CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) and
                  (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
               begin // PCurSrcElem element is inside Matr
                 SCSUM1 := SCSUM1 + CurCoef;
                 WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           PByte(PDstElem)^ := Round( WS1/SCSUM1 ); // One byte Dst Element
         end; // 0: begin // One byte Element (both Src and Dst)
{}
      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               // get Coeff. value for PCurSrcElem Src Matr element

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) and
                  (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
               begin // PCurSrcElem element is inside Matr
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 SCSUM1 := SCSUM1 + CurCoef;
                 WS1 := WS1 + PWord(PCurSrcElem)^*CurCoef; // Two bytes Src Element
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
                                             WSrcStepY * HCMDIM)^+ 1;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^ + 2;
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
                 CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;
                 if (Abs(CentralVal1 - PWord(PCurSrcElem+0)^) <= WTheshold) then
                 begin
                   SCSUM1 := SCSUM1 + CurCoef;
                   WS1 := WS1 + PByte(PCurSrcElem+0)^*CurCoef;
                 end;
                 if (Abs(CentralVal2 - PWord(PCurSrcElem+1)^) <= WTheshold) then
                 begin
                   SCSUM2 := SCSUM2 + CurCoef;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^*CurCoef;
                 end;
                 if (Abs(CentralVal3 - PWord(PCurSrcElem+2)^) <= WTheshold) then
                 begin
                   SCSUM3 := SCSUM3 + CurCoef;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^*CurCoef;
                 end;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
//      if N_b2 then N_T1.SS( 'One loop' );

//if ix = 253 then
//N_i := 254;
      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
//if iy = 253 then
//N_i := 254;
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows
  N_Dump1Str(  'Fin N_Conv2SMbyMatr' );

  end; //with WVars do
end; // procedure N_Conv2SMbyMatr2DCleaner

//********************************************************* N_Conv2SMbyMatr2DCleaner0 ***
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands) using 2D cleaner filter
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
// AThreshold - 2D cleaner filter threshold (from 0 to 1)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatr2DCleaner0( APSrcSM, APDstSM: TN_PSMatrDescr; ACMDim: integer; AThreshold : Float );
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
//      N_b2 := (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY);
//      if N_b2 then N_T1.Start();
//      if (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY) then N_T1.Start();

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
//if (iy = 0) and (ix = 2) then
//SCSUM1 := 0;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             if YSkipIndsCheck or
                ( (iy + jy >= HCMDIM) and (iy + jy <= kyMax) ) then
             begin
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 // get Coeff. value for PCurSrcElem Src Matr element

                 if ( XSkipIndsCheck or
                      ((ix + jx >= HCMDIM) and (ix + jx <= kxMax)) ) and
                    (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
                 begin // PCurSrcElem element is inside Matr
//                   CurCoef := PFloat( WPCM )^;
                   SCSUM1 := SCSUM1 + 1;
                   WS1 := WS1 + PByte(PCurSrcElem)^;
                 end;

                 Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
//if SCSUM1 = 0 then
//  SCSUM1 := 1;
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)
{}
{ Init
      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               // get Coeff. value for PCurSrcElem Src Matr element
               CurCoef := PFloat( APCM + (jx + jy*ACMDim)*SizeOf(Float) )^;

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) and
                  (Abs(CentralVal1 - PByte(PCurSrcElem)^) <= WTheshold) then
               begin // PCurSrcElem element is inside Matr
                 SCSUM1 := SCSUM1 + CurCoef;
                 WS1 := WS1 + PByte(PCurSrcElem)^*CurCoef;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
           PByte(PDstElem)^ := Round( WS1/SCSUM1 ); // One byte Dst Element
         end; // 0: begin // One byte Element (both Src and Dst)
{}
      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               // get Coeff. value for PCurSrcElem Src Matr element

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) and
                  (Abs(CentralVal1 - PWord(PCurSrcElem)^) <= WTheshold) then
               begin // PCurSrcElem element is inside Matr
                 SCSUM1 := SCSUM1 + 1;
                 WS1 := WS1 + PWord(PCurSrcElem)^; // Two bytes Src Element
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
                                             WSrcStepY * HCMDIM)^+ 1;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^ + 2;
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
                 if (Abs(CentralVal1 - PWord(PCurSrcElem+0)^) <= WTheshold) then
                 begin
                   SCSUM1 := SCSUM1 + 1;
                   WS1 := WS1 + PByte(PCurSrcElem+0)^;
                 end;
                 if (Abs(CentralVal2 - PWord(PCurSrcElem+1)^) <= WTheshold) then
                 begin
                   SCSUM2 := SCSUM2 + 1;
                   WS2 := WS2 + PByte(PCurSrcElem+1)^;
                 end;
                 if (Abs(CentralVal3 - PWord(PCurSrcElem+2)^) <= WTheshold) then
                 begin
                   SCSUM3 := SCSUM3 + 1;
                   WS3 := WS3 + PByte(PCurSrcElem+2)^;
                 end;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
//      if N_b2 then N_T1.SS( 'One loop' );

//if ix = 253 then
//N_i := 254;
      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
//if iy = 253 then
//N_i := 254;
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows
  N_Dump1Str(  'Fin N_Conv2SMbyMatr' );

  end; //with WVars do
end; // procedure N_Conv2SMbyMatr2DCleaner0

//********************************************************* N_Conv2SMbyMatr ***
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands) using 2D cleaner filter
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Matrix
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
// AThreshold - SpatialSmoother filter threshold (from 0 to 10)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatrSpatialSmoother( APSrcSM, APDstSM: TN_PSMatrDescr;
                                          ACMDim: integer;
                                          AThreshold : Float );
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

  N_Dump1Str(  'Start N_Conv2SMbyMatr' );

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
//      N_b2 := (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY);
//      if N_b2 then N_T1.Start();
//      if (ix = APSrcSM^.SMDBegIX) and (iy = APSrcSM^.SMDBegIY) then N_T1.Start();

      case CaseInd of

{ Init optimized }
      0: begin // One byte Element (both Src and Dst)
//           PCurSrcElem := PCurSrcRow + WSrcStepY * HCMDIM;
           CentralVal1 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             if YSkipIndsCheck or
                ( (iy + jy >= HCMDIM) and (iy + jy <= kyMax) ) then
             begin
               for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
               begin
                 if ( XSkipIndsCheck or
                      ((ix + jx >= HCMDIM) and (ix + jx <= kxMax)) ) then
                 begin // PCurSrcElem element is inside Matr
//if CentralVal1 - PByte(PCurSrcElem)^ <> 0 then
//N_i := 0;
                   WCoef := (1 - Min(1.0, (CentralVal1 - PByte(PCurSrcElem)^) * (CentralVal1 - PByte(PCurSrcElem)^) / Max2));
                   SCSUM1 := SCSUM1 + WCoef;
                   WS1 := WS1 + PByte(PCurSrcElem)^*WCoef;
                 end;

                 Inc( PCurSrcElem, WSrcStepX ); // to next Src Element in Row
//                 Inc( WPCM, SizeOf(Float) );
               end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             end; // if (iy + jy >= HCMDIM) and (iy + jy <= kyMax)

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

           //***** Here: Double WS and SCSUM are OK, calculate Dst element
//if SCSUM1 = 0 then
//  SCSUM1 := 1;
           if SCSUM1 <> 0 then
             PByte(PDstElem)^ := Round( WS1/SCSUM1 ) // One byte Dst Element
           else
             PByte(PDstElem)^ := CentralVal1;
         end; // 0: begin // One byte Element (both Src and Dst)
{}
      1: begin // Two bytes Element (both Src and Dst)
           CentralVal1 := PWord(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin
               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;

               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) then
               begin // PCurSrcElem element is inside Matr
               // get Coeff. value for PCurSrcElem Src Matr element
                 WCoef := (1 - Min(1.0, (CentralVal1 - PWord(PCurSrcElem)^) * (CentralVal1 - PWord(PCurSrcElem)^) / Max2));
                 SCSUM1 := SCSUM1 + WCoef;
                 WS1 := WS1 + PWord(PCurSrcElem)^*WCoef;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
                                             WSrcStepY * HCMDIM)^+ 1;
           CentralVal3 := PByte(PCurSrcRow + WSrcStepX * HCMDIM +
                                             WSrcStepY * HCMDIM)^ + 2;
           for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
           begin
             PCurSrcElem := PCurSrcRow;

             for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
             begin

               kx := ix + jx; // real index + HCMDIM
               ky := iy + jy;
               if (kx >= HCMDIM) and (kx <= kxMax) and
                  (ky >= HCMDIM) and (ky <= kyMax) then
               begin // PCurSrcElem element is inside Matr
               // get Coeff. value for PCurSrcElem Src Matr element
                 WCoef := (1 - Min(1.0, (CentralVal1 - PByte(PCurSrcElem+0)^) * (CentralVal1 - PByte(PCurSrcElem+0)^) / Max2));
                 SCSUM1 := SCSUM1 + WCoef;
                 WS1 := WS1 + PWord(PCurSrcElem+0)^*WCoef;

                 WCoef := (1 - Min(1.0, (CentralVal2 - PByte(PCurSrcElem+1)^) * (CentralVal2 - PByte(PCurSrcElem+1)^) / Max2));
                 SCSUM2 := SCSUM2 + WCoef;
                 WS1 := WS1 + PWord(PCurSrcElem+1)^*WCoef;

                 WCoef := (1 - Min(1.0, (CentralVal1 - PByte(PCurSrcElem+2)^) * (CentralVal1 - PByte(PCurSrcElem+2)^) / Max2));
                 SCSUM2 := SCSUM2 + WCoef;
                 WS2 := WS2 + PWord(PCurSrcElem+2)^*WCoef;
               end;

               PCurSrcElem := PCurSrcElem + WSrcStepX; // to next Src Element in Row
             end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row

             PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
           end; // for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows

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
//      if N_b2 then N_T1.SS( 'One loop' );

//if ix = 253 then
//N_i := 254;
      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
    end; // for ix := 0 to NX-1 do // along all elems in cur Row

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
//if iy = 253 then
//N_i := 254;
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows
  N_Dump1Str(  'Fin N_Conv2SMbyMatr' );

  end; //with WVars do
end; // procedure N_Conv2SMbyMatrSpatialSmoother
{$OPTIMIZATION OFF}

//********************************************** N_CalcDIB2SM2DCleanerMatr ***
// Calculate Smoothed Matrix from Source DIB by given coefficients Matrix using 2D Cleaner Filter
//
//     Parameters
// ADIBObj  - source DIB object
// ADstMatr - resulting smoothed Matrix
// APCM     - Pointer to first element of Float coefficients Matrix
// ACMDim   - coefficients Matrix Dimension ( should be odd (3,5,7,...) )
// AThreshold - 2D cleaner filter threshold (from 0 to 1)
//
procedure N_CalcDIB2SM2DCleanerMatr( ADIBObj : TN_DIBObj; var ADstMatr: TN_BArray;
                                     APCM: PFloat; ACMDim: integer;
                                     AThreshold : Float );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIBObj.PrepSMatrDescr( @SrcSM );
  ADIBObj.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMbyMatr2DCleaner( @SrcSM, @DstSM, TN_BytesPtr(APCM), ACMDim, AThreshold );
end; // procedure N_CalcDIB2SM2DCleanerMatr

//********************************************** N_CalcDIB2SM2DCleanerMatr ***
// Calculate Smoothed Matrix from Source DIB by given coefficients Matrix using 2D Cleaner Filter
//
//     Parameters
// ADIBObj  - source DIB object
// ADstMatr - resulting smoothed Matrix
// ACMDim   - coefficients Matrix Dimension ( should be odd (3,5,7,...) )
// AThreshold - 2D cleaner filter threshold (from 0 to 1)
//
procedure N_CalcDIB2SM2DCleanerMatr0( ADIBObj : TN_DIBObj; var ADstMatr: TN_BArray;
                                     ACMDim: integer;
                                     AThreshold : Float );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIBObj.PrepSMatrDescr( @SrcSM );
  ADIBObj.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMbyMatr2DCleaner0( @SrcSM, @DstSM, ACMDim, AThreshold );
end; // procedure N_CalcDIB2SM2DCleanerMatr

//********************************************** N_CalcDIB2SMSpatialSmootherMatr ***
// Calculate Smoothed Matrix from Source DIB by given coefficients Matrix using 2D Cleaner Filter
//
//     Parameters
// ADIBObj  - source DIB object
// ADstMatr - resulting smoothed Matrix
// APCM     - Pointer to first element of Float coefficients Matrix
// ACMDim   - coefficients Matrix Dimension ( should be odd (3,5,7,...) )
// AThreshold - SpatialSmoother filter threshold (from 0 to 1)
//
procedure N_CalcDIB2SMSpatialSmootherMatr( ADIBObj : TN_DIBObj; var ADstMatr: TN_BArray;
                                     APCM: PFloat; ACMDim: integer;
                                     AThreshold : Float );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIBObj.PrepSMatrDescr( @SrcSM );
  ADIBObj.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMbyMatrSpatialSmoother( @SrcSM, @DstSM, ACMDim, AThreshold );
end; // procedure N_CalcDIB2SMSpatialSmootherMatr

//******************************************************** K_CMSNoiseRedDlg ***
// Create and Show Noise Reduction Form in modal mode,
// update Current Image if OK was pressed
//
function K_CMSNoiseRedDlg( ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
       TK_FormCMSNoiseRAttrs.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Color := clBtnFace;
    Result := ShowModal() = mrOK;

    with EdSlide.GetCurrentImage do begin
      if SavedDIB <> DIBObj then
        SavedDIB.Free;
      if Result then begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
      end else begin
       // Cancel Changes
        NewDIB.Free;
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;

    EmbDIB1.Free;
    LSFSigma.Free;
    LSFThresh.Free;

  end; // with TK_FormCMSNoiseRAttrs.Create(Application), ...
end; // function K_CMSNoiseRedDlg

//************************************* TK_FormCMSNoiseRAttrs.TBDepthChange ***
// Update NRDepth, NRSigmaby and calculate NRCoefs matrix
//
procedure TK_FormCMSNoiseRAttrs.TBDepthChange( Sender: TObject );
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    if SkipRebuild or
       ((PrevTrackBar1 = Sender) and (PrevPosition1 = TTrackBar(Sender).Position)) or
       (csLButtonDown in TControl(Sender).ControlState) then Exit;
//       (EdSlide.CMSShowWaitStateFlag and
//        (csLButtonDown in TControl(Sender).ControlState)) then Exit;

    PrevTrackBar1 := Sender;
    PrevPosition1 := TTrackBar(Sender).Position;

    NRSigma := LSFSigma.Arg2Func( TBSigma.Position );
  //  N_PCAdd( 0, Format( 'Depth1=%d', [NRDepth] ) );

//    if EdSlide.CMSShowWaitStateFlag then
    CMMFShowHideWaitState( TRUE );

    // Recalc all needed if Depth or Sigma is changed
    CalcMeanDeltaMatr();
  //  N_PCAdd( 0, Format( 'Depth2=%d', [NRDepth] ) );

    CMMFShowHideWaitState( FALSE );

    TBThresh1Change( nil ); // Calc NewDIB by MeanMatr, DeltaMatr
//    if EdSlide.CMSShowWaitStateFlag then
  end;
end; // procedure TK_FormCMSNoiseRAttrs.TBDepthChange

//*********************************** TK_FormCMSNoiseRAttrs.TBThresh1Change ***
// Update NRThresh1,2, convert (Reduce Noise) SavedDIB to NewDIB,
// rebuild and show Map Image
//
// MeanMatr and DeltaMatr should be already OK
//
// TBThresh1 and TBThresh2 OnChange handler
//
procedure TK_FormCMSNoiseRAttrs.TBThresh1Change( Sender: TObject );
var
  SrcSMD, DstSMD: TN_SMatrDescr;
  SenderIsProperTB : Boolean;

begin

  with N_CM_MainForm, CMMFActiveEdFrame do begin
    SenderIsProperTB := (Sender <> nil) and (Sender is TTrackBar);
{
    if SkipRebuild or
       ( SenderIsProperTB and
         ( ((PrevTrackBar2 = Sender) and
            (PrevPosition2 = TTrackBar(Sender).Position)) or
           (EdSlide.CMSShowWaitStateFlag and
           (csLButtonDown in TControl(Sender).ControlState)))) then Exit;
}

    if SenderIsProperTB then
    begin
      NRThresh1 := LSFThresh.Arg2Func( TBThresh1.Position );
      EdThreshold1Val.Text := format( '%6.2f', [NRThresh1] );

      NRThresh2 := LSFThresh.Arg2Func( TBThresh2.Position );
      EdThreshold2Val.Text := format( '%6.2f', [NRThresh2] );

      if SkipRebuild                      or
         ((PrevTrackBar2 = Sender) and
            (PrevPosition2 = TTrackBar(Sender).Position)) then Exit;
    end;


    if SenderIsProperTB then begin
      PrevTrackBar2 := Sender;
      PrevPosition2 := TTrackBar(Sender).Position;
    end;



    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    LbTimeInfo.Caption := 'Please wait ...';
    LbTimeInfo.Refresh();

    NewDIB.PrepSMatrDescr( @DstSMD );
    SavedDIB.PrepSMatrDescr( @SrcSMD );
    if CmBFilterType.ItemIndex = 0 then
    begin


    //  N_i1 := integer( SrcSMD.SMDPBeg );
    //  N_i2 := integer( DstSMD.SMDPBeg );

    //  N_s := Format( 'S=%.1f, Dim=%d, C1=%.1f, C2=%.1f', [NRSigma,NRDepth,NRThresh1,NRThresh2] );
    //  N_PCAdd( 0, 'a ' + N_s );

      N_T1.Start;
      N_Conv3SMDoNR1( @SrcSMD, @DstSMD, TN_BytesPtr(@MeanMatr[0]), TN_BytesPtr(@DeltaMatr[0]),
                          @NRCoefs[0], NRDepth, NRThresh1, NRThresh2 );
      N_T1.Stop;
      LbTimeInfo.Caption := N_T1.ToStr( SavedDIB.DIBSize.X * SavedDIB.DIBSize.Y ) +
                            ' per pixel';
    //  N_PCAdd( 0, 'b ' + N_s );
    end
    else
    begin

      N_CalcGaussMatr( NRCoefs, NRDepth, NRSigma );
      N_T1.Start;
      if CmBFilterType.ItemIndex = 1 then
        N_Conv2SMbyMatr2DCleaner0( @SrcSMD, @DstSMD, NRDepth, NRThresh1 )
//        N_CalcDIB2SM2DCleanerMatr0( SavedDIB, MeanMatr, NRDepth, NRThresh1 )
      else
      if CmBFilterType.ItemIndex = 2 then
        N_Conv2SMbyMatr2DCleaner( @SrcSMD, @DstSMD, TN_BytesPtr(@NRCoefs[0]), NRDepth, NRThresh1 )
//        N_CalcDIB2SM2DCleanerMatr( SavedDIB, MeanMatr, @NRCoefs[0], NRDepth, NRThresh1 )
      else
        N_Conv2SMbyMatrSpatialSmoother( @SrcSMD, @DstSMD, NRDepth, NRThresh1 );
//        N_CalcDIB2SMSpatialSmootherMatr( SavedDIB, MeanMatr, @NRCoefs[0], NRDepth, NRThresh1 );
      N_T1.Stop;
//      SavedDIB.CalcLinCombDIB( NewDIB, @MeanMatr[0], 1 );

      LbTimeInfo.Caption := N_T1.ToStr( SavedDIB.DIBSize.X * SavedDIB.DIBSize.Y ) +
                            ' per pixel';
    end;

    LbTimeInfo.Refresh();

    EdSlide.RebuildMapImageByDIB( NewDIB, nil, @EmbDIB1 );
    RFrame.RedrawAllAndShow();

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );

    CMMFRefreshActiveEdFrameHistogram( NewDIB );
  end;

  SkipRebuild := FALSE;

//  N_AppShowString( Format( 'S=%.1f, Dim=%d, C1=%.1f, C2=%.1f', [NRSigma,NRDepth,NRThresh1,NRThresh2] ) ); // for Debug

end; // procedure TK_FormCMSNoiseRAttrs.TBThresh1Change

//************************************** TK_FormCMSNoiseRAttrs.BtApplyClick ***
// Calculate MeanMatr, DeltaMatr and call TBThresh1Change
//
// BtApply OnClick handler
//
procedure TK_FormCMSNoiseRAttrs.BtApplyClick( Sender: TObject );
begin
  if SkipApply then Exit;
  SkipApply := TRUE;

  with N_CM_MainForm, CMMFActiveEdFrame do begin
    if SavedDIB <> EdSlide.GetCurrentImage.DIBObj then
      SavedDIB.Free;

    SavedDIB := NewDIB;
    NewDIB := TN_DIBObj.Create( SavedDIB );

    CalcMeanDeltaMatr();

    TBThresh1Change( Sender ); // Calc NewDIB by MeanMatr, DeltaMatr

  end;

//??  Application.ProcessMessages; //??
  SkipApply := FALSE;
end; // procedure TK_FormCMSNoiseRAttrs.BtApplyClick

//**************************************** TK_FormCMSNoiseRAttrs.TimerTimer ***
// Calculate MeanMatr, DeltaMatr and call TBThresh1Change
//
// TTimer OnTimer handler.
// Timer is needed to show Self before all calculations will be finished
//
procedure TK_FormCMSNoiseRAttrs.TimerTimer( Sender: TObject );
var
  WSigma : Double;
  WSharpDepth : Integer;

begin
  Timer.Enabled := FALSE;

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

    SkipRebuild := FALSE;
    SkipApply := FALSE;

    if NewDIB = nil then
    begin
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      NewDIB := TN_DIBObj.Create( SavedDIB );
    end;

    WSigma := LSFSigma.Arg2Func( TBSigma.Position );
    with CmBDepth do
      WSharpDepth := StrToInt(Items[ItemIndex]);
    if (WSharpDepth <> NRDepth)  or
       (Abs(WSigma-NRSigma) > 0.01 ) or
       (CmBFilterType.ItemIndex = 0) then
    begin
      NRSigma := WSigma;
      NRDepth := WSharpDepth;
      CalcMeanDeltaMatr();
    end;
    EdSigmaVal.Text := format( '%6.2f', [NRSigma] );


    TBThresh1Change( Sender ); // Calc NewDIB by MeanMatr, DeltaMatr


  end;
//  bnTestClick( Sender ); // debug

end; // procedure TK_FormCMSNoiseRAttrs.TimerTimer

procedure TK_FormCMSNoiseRAttrs.bnTestClick( Sender: TObject );
// Recalculate all (to stop in debugger if needed) and add to Log test data
var
  i: integer;
  SL: TStringList;
  SrcSMD, DstSMD: TN_SMatrDescr;
begin

  N_CM_MainForm.CMMFShowHideWaitState( TRUE );

  for i := 0 to NRDepth*NRDepth-1 do
  begin
    N_LCAdd( 0, Format( '%.7g, i=%d, x,y=%d,%d', [NRCoefs[i], i, i mod NRDepth, i div NRDepth] ));
  end;


  CalcMeanDeltaMatr();

  TBThresh1Change( Sender ); // Calc NewDIB by MeanMatr, DeltaMatr

  SL := TStringList.Create;
  N_LCAdd( 0, Format( 'NRSigma=%.1f, NRDepth=%d, NRThresh1=%.1f, NRThresh2=%.1f',
                       [NRSigma,NRDepth,NRThresh1,NRThresh2] ));

  SavedDIB.PrepSMatrDescr( @SrcSMD );
  NewDIB.PrepSMatrDescr( @DstSMD );
  N_SMToText( @SrcSMD, 0, 'Source', SL, nil, nil );
  N_SMToText( @SrcSMD, 0, 'Mean',   SL, nil, @MeanMatr[0] );
  N_SMToText( @SrcSMD, 0, 'Delta',  SL, nil, @DeltaMatr[0] );
  N_SMToText( @DstSMD, 0, 'Result', SL, nil, nil );

  N_LCAdd( 0, SL.Text );

  SL.Free;

  N_CM_MainForm.CMMFShowHideWaitState( FALSE );

end; // procedure TK_FormCMSNoiseRAttrs.bnTestClick


//********************************* TK_FormCMSNoiseRAttrs.CalcMeanDeltaMatr ***
// Calc MeanMatr and DeltaMatr by SavedDIB
// (used in BtApplyClick and TimerTimer methods)
//
procedure TK_FormCMSNoiseRAttrs.CalcMeanDeltaMatr();
var
  MatrSize: integer;
  SelfSMD: TN_SMatrDescr;
begin

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
  //if EdSlide.CMSShowWaitStateFlag then
    CMMFShowHideWaitState( TRUE );

    N_T1.Start;
    LbTimeInfo.Caption := 'Please wait ...';
    LbTimeInfo.Refresh();

    SavedDIB.PrepSMatrDescr( @SelfSMD, @MatrSize );

    N_CalcGaussMatr( NRCoefs, NRDepth, NRSigma, 1 );

    if Length(MeanMatr) < MatrSize then
    begin
      SetLength( MeanMatr,  MatrSize );
      SetLength( DeltaMatr, MatrSize );
    end;

    N_Conv3SMPrepNR1( @SelfSMD, TN_BytesPtr(@MeanMatr[0]), TN_BytesPtr(@DeltaMatr[0]),
                      @NRCoefs[0], NRDepth );

    N_T1.Stop;
    LbTimeInfo.Caption := N_T1.ToStr( SavedDIB.DIBSize.X * SavedDIB.DIBSize.Y ) +
                          ' per pixel';
    LbTimeInfo.Refresh();

  //  if EdSlide.CMSShowWaitStateFlag then
    CMMFShowHideWaitState( TRUE );
  end;
end; // procedure TK_FormCMSNoiseRAttrs.CalcMeanDeltaMatr


procedure TK_FormCMSNoiseRAttrs.TBSigmaChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      EdSigmaVal.Text := format( '%6.2f', [LSFSigma.Arg2Func( TBSigma.Position )] );
      if SkipRebuild                          or
         (PrevSigmaPosition = TBSigma.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBSigma)            and
         (csLButtonDown in TControl(Sender).ControlState)) then Exit;
    end;

    PrevSigmaPosition := TBSigma.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end;

procedure TK_FormCMSNoiseRAttrs.EdSigmaValKeyPress(Sender: TObject;
  var Key: Char);
var
  WSigma : Double;
begin
  if (Key <> Chr(VK_RETURN)) or SkipRebuild  then Exit;
  SkipRebuild := TRUE;
  WSigma := StrToFloatDef( Trim(EdSigmaVal.Text), NRSigma );
  TBSigma.Position := Round( LSFSigma.Func2Arg( WSigma ) );

  Timer.Enabled := TRUE;

end;


procedure TK_FormCMSNoiseRAttrs.FormShow(Sender: TObject);
begin
  // Create LineSegmFunctions
  LSFSigma  := TK_LineSegmFunc.Create( [0, 0.1,  2500, 0.5,  5000, 1.5,  7500, 5,  10000, 20] );
//  LSFThresh := TK_LineSegmFunc.Create( [0, 1.1,  10000, 7] ); // same for TBThresh1,2
  LSFThresh := TK_LineSegmFunc.Create( [0, 0,  10000, 7] ); // same for TBThresh1,2

  SkipRebuild := TRUE;
  SkipApply := TRUE;

  // Initialize Values

  NRSigma := 2;
  TBSigma.Position := Round( LSFSigma.Func2Arg( NRSigma ) );
  EdSigmaVal.Text := format( '%6.2f', [NRSigma] );
  NRSigma := -1;

  with CmBDepth do
    ItemIndex := Items.IndexOf(IntToStr(5));
  NRDepth := -1;


  // Initialize Controls
  NRThresh1 := 0.5;
  TBThresh1.Position := Round( LSFThresh.Func2Arg( NRThresh1 ) );

  NRThresh2 := 2.1;
  TBThresh2.Position := Round( LSFThresh.Func2Arg( NRThresh2 ) );

  Timer.Enabled := TRUE;

end;

procedure TK_FormCMSNoiseRAttrs.BtOKClick(Sender: TObject);
//var
//  VKR : Char;
begin

  if not ApplyOKWait then
  begin
//    VKR := Chr(VK_RETURN);
//    LbEdConvFactorKeyPress( Sender, VKR );
  end;
  DoOKAfter := ApplyOKWait;

end;


procedure TK_FormCMSNoiseRAttrs.EdThreshold1ValKeyPress(Sender: TObject;
  var Key: Char);

begin
  if (Key <> Chr(VK_RETURN)) or SkipRebuild  then Exit;
//  SkipRebuild := TRUE;

  NRThresh1 := StrToFloatDef( Trim(EdThreshold1Val.Text), NRThresh1 );
  TBThresh1.Position := Round( LSFThresh.Func2Arg( NRThresh1 ) );

  NRThresh2 := StrToFloatDef( Trim(EdThreshold2Val.Text), NRThresh2 );
  TBThresh2.Position := Round( LSFThresh.Func2Arg( NRThresh2 ) );

end;

procedure TK_FormCMSNoiseRAttrs.CmBDepthChange(Sender: TObject);
begin
  if (Sender <> nil) and SkipRebuild then Exit;
  case CmBFilterType.ItemIndex of
    0: begin // Old Filter
      TBThresh2.Enabled := TRUE;
      EdThreshold2Val.Enabled := TRUE;
    end;
    1,2,3: begin // 2D Cleaner
      TBThresh2.Enabled := FALSE;
      EdThreshold2Val.Enabled := FALSE;
    end;
  end;
  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end;

end.
