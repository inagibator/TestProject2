unit N_2DFunc1;
// Two Dimensional functions

interface
uses Windows, Classes, Graphics,
   N_Types, N_Lib0, N_Gra2, N_UDat4;

type TN_2DIntMode   = ( tdimConst, tdimBiLineal, tdimTriLineal, tdimSpline1 );
type TN_VMColorMode = ( vmcmPixValue, vmcmGrayValue );
type TN_MLLabelType = ( mlltInds, mlltValues );
type TN_NormType    = ( ntL1, ntL2, ntLInf );

type TN_VMSideInfo = record // info about one border side
  VMSideIndex:  integer;
  VMSBorderInd: integer;
  VMSIncValues: boolean;
  VMSValue1:    boolean;
end; // type TN_VMSideInfo = record
type TN_VMSidesList = array of TN_VMSideInfo;

type TN_FVMatr = class( TObject ) // 2D Matrix with Float Values
  NX:  integer;
  NY:  integer;
  NXY: integer;
  OutValue: float;
  VM: TN_FArray; // Values are stored by Rows! ( ind := j*NX + i, i=0..NX-1, j=0..NY-1 )

        // Wrk variables for passing params between methods:
  VMCurValue:  double;
  VMIncValues: boolean;
  VMBorderInd: integer; // 0-Top, 1-Right, 2-Bottom, 3-Left

  constructor Create (); overload;
  constructor Create ( ANX, ANY: integer ); overload;
  constructor Create ( ASrcMatr: TN_FVMatr ); overload;
  constructor Create ( PFVal: PFloat; ANX, ANY: integer );  overload;
  constructor Create ( PDVal: PDouble; ANX, ANY: integer ); overload;
  constructor Create ( ARObj: TN_RasterObj; AMode: TN_VMColorMode ); overload;
  destructor  Destroy; override;

  procedure SetSize      ( ANX, ANY: integer );
  procedure Clear        ();
  procedure SetValues    ( ASrcMatr: TN_FVMatr ); overload;
  procedure SetValues    ( PFVal: PFloat; ANX, ANY: integer );  overload;
  procedure SetValues    ( PDVal: PDouble; ANX, ANY: integer ); overload;
  procedure GetValues    ( PFVal: PFloat ); overload;
  procedure GetValues    ( PDVal: PDouble ); overload;
  procedure AddLin1Func  ( AVX0Y0, AStepX, AStepY: double );
  procedure AddLin2Func  ( AVX0Y0, AVXMaxY0, AVX0YMax: double );
  procedure AddParab     ( AExtrCoords: TDPoint; AExtrVal, ACX, ACY: double );
  procedure Add2DExp     ( AExtrCoords: TDPoint; AExtrVal, AInfVal,
                                                 ASigmaX, ASigmaY: double );
  procedure Resample     ( ASrcMatr: TN_FVMatr; AIMode: TN_2DIntMode );
  procedure LinComb      ( ACSelf, ACOp, AAddVal: double; AOpMatr: TN_FVMatr;
                                                         AIMode: TN_2DIntMode );
  function  SelfNorm     ( ANormType: TN_NormType ): double;
  function  DifNorm      ( AOpMatr: TN_FVMatr; ANormType: TN_NormType;
                                               AIMode: TN_2DIntMode ): double;
  procedure AddToStrings    ( ASL: TStrings; AFmt: string );
  procedure GetFromStrings  ( ASL: TStrings; AFirstInd: integer );
  procedure ClipAndLinScale ( AInpMin, AInpMax, AOutMin, AOutMax: double );
  function  GetValue     ( AIMode: TN_2DIntMode; AX, AY: double ): double;
  function  CorrectValue ( AValue: double ): double;
  function  HSideIsOk    ( ASideInd: integer ): boolean;
  function  VSideIsOk    ( ASideInd: integer ): boolean;
  function  GetSidesList ( AValue1, AValue2: double ): TN_VMSidesList;
  procedure AddIsoLine   ( AValue: float; AULines: TN_ULines );
  procedure AddIzoCont   ( AMinValue, AMaxValue: float; AULines: TN_ULines;
                                                      AUConts: TN_UContours );
  function  CreateRaster ( APRangeValue: PDouble; APColor: PInteger;
                                 ANumColors: integer; ARType: TN_RasterType;
                                 APixFmt: TPixelFormat ): TN_RasterObj;
  procedure CreateLabels ( ALabelType: TN_MLLabelType; AFmt: string;
                           APFLabel: TN_BytesPtr; ABytesStep: integer = 4 );
end; // type TN_FVMatr = class( TObject )

type TN_DVMatr = class( TObject ) // 2D Matrix with Double Values
  NX:  integer;
  NY:  integer;
  NXY: integer;
  OutValue: double;
  VM: TN_DArray; // Values are stored by Rows! ( ind := j*NX + i, i=0..NX-1, j=0..NY-1 )

        // Wrk variables for passing params between methods:
  VMCurValue:  double;
  VMIncValues: boolean;
  VMBorderInd: integer; // 0-Top, 1-Right, 2-Bottom, 3-Left

  constructor Create (); overload;
  constructor Create ( ANX, ANY: integer ); overload;
  constructor Create ( PIVal: PInteger; ANX, ANY: integer ); overload;
  constructor Create ( PFVal: PFloat; ANX, ANY: integer );   overload;
  constructor Create ( PDVal: PDouble; ANX, ANY: integer );  overload;
  destructor  Destroy; override;

  procedure SetSize      ( ANX, ANY: integer );
  procedure Clear        ();
  procedure SetValues    ( PIVal: PInteger; ANX, ANY: integer ); overload;
  procedure SetValues    ( PFVal: PFloat; ANX, ANY: integer );   overload;
  procedure SetValues    ( PDVal: PDouble; ANX, ANY: integer );  overload;
  procedure GetValues    ( PIVal: PInteger ); overload;
  procedure GetValues    ( PFVal: PFloat );   overload;
  procedure GetValues    ( PDVal: PDouble );  overload;

  procedure AddLin1Func  ( AVX0Y0, AStepX, AStepY: double );
  procedure AddLin2Func  ( AVX0Y0, AVXMaxY0, AVX0YMax: double );
  procedure AddParab     ( AExtrCoords: TDPoint; AExtrVal, ACX, ACY: double );
  procedure Add2DExp     ( AExtrCoords: TDPoint; AExtrVal, AInfVal,
                                                 ASigmaX, ASigmaY: double );
end; // type TN_DVMatr = class( TObject )

type TN_SplineLineObj = class( TObject ) // Params and ProcOfObj for Splining Lines
  PSplineParams: TN_PSplineLineParams;
  procedure SplineLine( ASrcDC: TN_DPArray; var AResDC: TN_DPArray );
end; // type TN_SplineLineObj = class

type TN_AffConvObj = class( TObject ) // Params and FuncOfObj for AffConv one DPoint
  PAffCoefs4: TN_PAffCoefs4;
  PAffCoefs6: TN_PAffCoefs6;
  PAffCoefs8: TN_PAffCoefs8;
  GivenRect:   TFRect;
  InsideGivenRect: boolean; // convert only inside GivenRect

  function AffConvDP( const ASrcDP: TDPoint; AParams: Pointer = nil ): TDPoint;
end; // type TN_ConvDPObj = class( TObject )

type TN_ArgSegmData = record // Data for one Argument(X or Y) interpolation Segment
  ASDFuncCoefs0Ind: integer; // Func Coefs index for Alfa=0
  ASDFuncCoefs1Ind: integer; // Func Coefs index for Alfa=1
  ASDArgCoefs: TN_DPArray; // Array of X,Alfa pairs for one X interpolation Segment
end; // type TN_ArgSegmData = record
type TN_ArgSegmentsData = Array of TN_ArgSegmData;

type TN_XYPWIConvObj = class( TObject ) // Params and FuncOfObj for X or Y Non Linear
                             // Convertion of one DPoint, based on Piecewise Interpolation
  PWICoordsMode: integer; // What Coord to convert: =0 - Y convertion, =1 - X convertion
  PWIAddAffConv: integer; // Additional Affine convertion: =0 - not needed, =1 - GivenReper <--> N_D100Reper
  PWINumYPoints: integer; // Number of points in each YCoefs ( number of doubles = 2*(PWINumYPoints+3) )

  PWIToNormAffC6:   TN_AffCoefs6; // additional AffCoefs6 convertion from GivenReper to N_D100Reper
  PWIFromNormAffC6: TN_AffCoefs6; // additional AffCoefs6 convertion from N_D100Reper to GivenReper

  PWIXData: TN_ArgSegmentsData; // Array of Data for X interpolation Segments (of PWINumXSegments Size)
  PWIXEnds: TN_DArray; // Array X Ends for calculating XSegm Index (of PWINumXSegments+1 Size)
  PWINumXSegments: integer; // Number of X interpolation Segments
  PWINumYCoefs:    integer; // Number of YCoefs
  PWIPYCoefs:   TN_PDArray; // Array of Pointers to YCoefs (Pointers to Double) (of PWINumYCoefs Size)

  function NLConvPrep ( APParams: PDouble ): integer;
  function NLConvDP   ( const ASrcDP: TDPoint; AParams: Pointer = nil ): TDPoint;
end; // type TN_XYPWIConvObj = class( TObject )

type TN_GeoProjObj = class( TObject ) // Params and FuncOfObj for Projections
    private
  C, Q: double;         // Geo Projections coefs. for all projections
  R1, R2, S1, S2, U1, U2, RO, SIG: double;

  function S  ( B: double): double;
  function N  ( B: double): double;
  function RP ( B: double): double;
  function U  ( B: double): double;

    public
  Scale: double;       // scale in thousands (Scale=10 means 1 : 10 000)
  BS,B1,B2,BN: double; // South, Main1, Main2 and North rect's lattitudes
                       // ( 0 < BS < B1 < B2 < BN )
  LW,L0,LE: double;    // West, Middle and East rect's merredians (LW<L0<LE)
  MRec: TDRect;        // metrical rect's coords in millimeters
  Alfa: double; // Geo Projections coef. for conical1,2 projections and,
      // if Alfa == N_NotADouble  means, that Alfa, C,Q coefs are not calculated

  GPType: integer; // Geo Projection Type :
    // =1 - normal conical 1 (нормальная коническая равнопромежуточная)
    // =2 - normal conical 2 (нормальная коническая равноугольная)
    // =3 - normal cilindrycal Mercator (нормальная цилиндрическая Меркатора)

  ConvMode: integer; // Convertion mode flags:
    //   bit4($010) =0 - convert from degree (B,L or L,B) to metric (X,Y) coords
    //              =1 - convert from metric (X,Y) to degree (B,L or L,B) coords
    //
    //   bit5($020) =0 - first degree coords is B, second is L
    //              =1 - first degree coords is L, second is B
    //
    //   bit6($040) =0 - do not toggle B sign
    //              =1 - toggle B sign
    //

  constructor Create        ();
  procedure SetCoefsByStr   ( AStr: string );
  procedure ConvertLine     ( const InpCoords: TN_DPArray;
                              var OutCoords: TN_DPArray; ConvMode: integer );
  procedure GeoProjConvPrep ( APParams: PDouble );
  function  GeoProjConvDP   ( const ASrcDP: TDPoint; AParams: Pointer = nil ): TDPoint;
end; // type TN_GeoProjObj = class( TObject )


type TN_RectsConvObj = class( TObject ) // Params and FuncOfObj for three Rects
                                        // Non Linear Convertion of one DPoint
  EnvRect: TFRect;
  SrcRect: TFRect;
  DstRect: TFRect;

  function NLConvPrep ( const AEnvRect, ASrcRect, ADstRect: TFRect ): integer;
  function NLConvDP   ( const ASrcDP: TDPoint; AParams: Pointer = nil ): TDPoint;
end; // type TN_RectsConvObj = class( TObject )

type TN_MatrConvObj = class( TObject ) // Params and FuncOfObj for Matr
                                       // Non Linear Convertion of one DPoint
  MNX: integer;    // Matr X Dimension
  MNY: integer;    // Matr Y Dimension
  MatrSrcRect: TFRect; // Matrix Source Rect (instead of PXVals, PYVals)
  PXVals: PFloat;  // Pointer to X Float Values (not needed if MatrSrcRect is given)
  PYVals: PFloat;  // Pointer to Y Float Values (not needed if MatrSrcRect is given)
  PMatr:  PFPoint; // Pointer to Matrix FPoints

  function  SetParams   ( ANX, ANY: integer; AMatrEnvRect: TFRect;
                                             APMatrFPoints: PFPoint ): integer;
  function  CheckParams ( AMode: integer ): integer;
  procedure InitMatr    ();
  procedure ConvMatr    ( AFunc: TN_ConvDPFuncObj );
  function  NLConvDP ( const ASrcDP: TDPoint; AParams: Pointer = nil ): TDPoint;
end; // type TN_MatrConvObj = class( TObject )


    //*********** Global Procedures  *****************************

procedure N_CalcCatRomCoefs ( AT: double; PCoefs: PDOuble );

function  N_GetMatrValue ( PValue: PFloat; ANX, ANY: integer;
                           AIMode: TN_2DIntMode; AX, AY: double ): double; overload;
function  N_GetMatrValue ( PValue: PDouble; ANX, ANY: integer;
                           AIMode: TN_2DIntMode; AX, AY: double ): double; overload;
procedure N_SplineLine   ( APParams: TN_PSplineLineParams; ASrcDC: TN_DPArray;
                                                       var AResDC: TN_DPArray );
function  N_Inverse1     ( APFunc: PDouble; ANumSrc, ANumRes: integer;
                           AArgBeg, AArgStep, AFuncBeg, AFuncStep: double;
                                                 APResArgs: PDouble ) : Integer;
function  N_GetBezierPoint  ( APDPoints: PDPoint; Alfa: double ): TDPoint;

function  N_1DNLConvPower   ( const AArg: double; PCoefs: PDouble ): double;
function  N_XYNLConvPower   ( const AArg: TDPoint; PXCoefs: PDouble; AYFunc: TN_FuncDPD;
                     ANumYCoefs: integer; PYCoefsMin, PYCoefsMax: PDouble ): TDPoint;
function  N_FuncConv20D1    ( const ASrcDP: TDPoint; PParams: Pointer ): TDPoint;

function  N_1DPWIFuncCheck  ( var PCoefs: PDouble ): integer;
function  N_1DPWIFunc       ( const AArg: double; PCoefs: PDouble;
                                              PISInd: PInteger = nil ): double;

implementation
uses Math, SysUTils,
    K_VFunc,
    N_Gra0, N_Gra1, N_Gra3, N_Lib1;


//********** TN_FVMatr class methods  **************

//********************************************** TN_FVMatr.Create() ***
//
constructor TN_FVMatr.Create();
begin
  SetSize( 0, 0 );
end; // end_of constructor TN_FVMatr.Create()

//********************************************** TN_FVMatr.Create(NX,NY) ***
//
constructor TN_FVMatr.Create( ANX, ANY: integer );
begin
  SetSize( ANX, ANY );
//  FillChar( VM[0], NXY*Sizeof(Float), 0 );
end; // end_of constructor TN_FVMatr.Create(NX,NY)

//********************************************** TN_FVMatr.Create(FVMatr) ***
//
constructor TN_FVMatr.Create( ASrcMatr: TN_FVMatr );
begin
  SetValues( ASrcMatr );
end; // end_of constructor TN_FVMatr.Create(FVMatr)

//********************************************** TN_FVMatr.Create(PFloat) ***
//
constructor TN_FVMatr.Create( PFVal: PFloat; ANX, ANY: integer );
begin
  SetValues( PFVal, ANX, ANY );
end; // end_of constructor TN_FVMatr.Create(PFloat)

//********************************************** TN_FVMatr.Create(PDouble) ***
//
constructor TN_FVMatr.Create( PDVal: PDouble; ANX, ANY: integer );
begin
  SetValues( PDVal, ANX, ANY );
end; // end_of constructor TN_FVMatr.Create(PDouble)

//********************************************** TN_FVMatr.Create(ByRaster) ***
//
constructor TN_FVMatr.Create( ARObj: TN_RasterObj; AMode: TN_VMColorMode );
var
  i, j, ind: integer;
begin
  with ARObj do
  begin

  PrepSelfFields(); // RasterObj method
  SetSize( RR.RWidth, RR.RHeight );

  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;

    case AMode of

    vmcmPixValue  : VM[ind] := GetPixelValue( i, j );

    vmcmGrayValue : VM[ind] := N_ConvToGray( GetPixelColor( i, j ) );

    end; // case AMode of
  end; // for j := 0 to NY-1 do, for i := 0 to NX-1 do

  end; // with ARObj do
end; // end_of constructor TN_FVMatr.Create(ByRaster)

//********************************************* TN_FVMatr.Destroy ***
// TN_FVMatr objects should not be deleted while any TN_OCanv objects exists!
//
destructor TN_FVMatr.Destroy;
begin
  VM := nil;
  inherited Destroy;
end; // end_of destructor TN_FVMatr.Destroy

//*********************************************** TN_FVMatr.SetSize ***
// Set Self Size (Self Dimensions) without changing VM values
//
procedure TN_FVMatr.SetSize( ANX, ANY: integer );
begin
  if (NX = ANX) and (NY = ANY) then Exit; // already OK

  Assert( (ANX > 1) and (ANY > 1), 'Bad dim!' );

  NX  := ANX;
  NY  := ANY;
  NXY := NX * NY;
  VM  := nil; // to avoid unneeded data moving
  SetLength( VM, NXY );
end; // procedure TN_FVMatr.SetSize

//*********************************************** TN_FVMatr.Clear ***
// Set all VM elements to 0
//
procedure TN_FVMatr.Clear();
begin
  FillChar( VM[0], NXY*Sizeof(VM[0]), 0 );
end; // procedure TN_FVMatr.Clear

//*********************************************** TN_FVMatr.SetValues(FVMatr) ***
// Make Self a copy of given ASrcMatr
//
procedure TN_FVMatr.SetValues( ASrcMatr: TN_FVMatr );
begin
  SetSize( ASrcMatr.NX, ASrcMatr.NY );
  OutValue := ASrcMatr.OutValue;
  move( ASrcMatr.VM[0], VM[0], NXY*Sizeof(VM[0]) );
end; // procedure TN_FVMatr.SetValues(FVMatr)

//*********************************************** TN_FVMatr.SetValues(PFloat) ***
// Set Self Values by given Floats
//
procedure TN_FVMatr.SetValues( PFVal: PFloat; ANX, ANY: integer );
begin
  SetSize( ANX, ANY );
  move( PFVal^, VM[0], NXY*Sizeof(VM[0]) );
end; // procedure TN_FVMatr.SetValues(PFloat)

//*********************************************** TN_FVMatr.SetValues(PDouble) ***
// Set Self Values by given Doubles
//
procedure TN_FVMatr.SetValues( PDVal: PDouble; ANX, ANY: integer );
var
  i: integer;
begin
  SetSize( ANX, ANY );

  for i := 0 to NXY-1 do
  begin
    VM[i] := PDVal^;
    Inc( PDVal );
  end;
end; // procedure TN_FVMatr.SetValues(PDouble)

//*********************************************** TN_FVMatr.GetValues(PFloat) ***
// Set given Floats by Self Values
//
procedure TN_FVMatr.GetValues( PFVal: PFloat );
begin
  move( VM[0], PFVal^, NXY*Sizeof(VM[0]) );
end; // procedure TN_FVMatr.GetValues(PFloat)

//*********************************************** TN_FVMatr.GetValues(PDouble) ***
// Set given Doubles by Self Values
//
procedure TN_FVMatr.GetValues( PDVal: PDouble );
var
  i: integer;
begin
  for i := 0 to NXY-1 do
  begin
    PDVal^ := VM[i];
    Inc( PDVal );
  end;
end; // procedure TN_FVMatr.GetValues(PDouble)

//********************************************** TN_FVMatr.AddLin1Func ***
// Add to Self Linear Func with given X,Y Steps:
// VM[0,0]=AVX0Y0, VM[ix,iy]=AVX0Y0 + ix*AStepX + iy*AStepY
//
procedure TN_FVMatr.AddLin1Func( AVX0Y0, AStepX, AStepY: double );
var
  i, j, ind: integer;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    VM[ind] := AVX0Y0 + i*AStepX + j*AStepY;
  end;
end; // procedure TN_FVMatr.AddLin1Func

//********************************************** TN_FVMatr.AddLin2Func ***
// Add to Self Linear Func with given values at:
// VM[0,0]=AVX0Y0, VM[NX-1,0]=AVXMaxY0, VM[0,NY-1]=AVX0YMax
//
procedure TN_FVMatr.AddLin2Func( AVX0Y0, AVXMaxY0, AVX0YMax: double );
var
  i, j, ind: integer;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    VM[ind] := AVX0Y0 + (AVXMaxY0-AVX0Y0)*i/(NX-1) + (AVX0YMax-AVX0Y0)*j/(NY-1);
  end;
end; // procedure TN_FVMatr.AddLin2Func

//********************************************** TN_FVMatr.AddParab ***
// Add to Self Parabolic func with given:
// AExtrCoords - Extremum Point Index Coords
// AExtrVal    - Func Value at Extremum Point
// ACX, ACY    - coefs at DX*DX and DY*DY terms
//
procedure TN_FVMatr.AddParab( AExtrCoords: TDPoint; AExtrVal, ACX, ACY: double );
var
  i, j, ind: integer;
  dix, diy: double;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    dix := i - AExtrCoords.X;
    diy := j - AExtrCoords.Y;
    VM[ind] := VM[ind] + AExtrVal + ACX*dix*dix + ACY*diy*diy;
  end;
end; // procedure TN_FVMatr.AddParab

//********************************************** TN_FVMatr.Add2DExp ***
// Add to Self 2D Exponent with given:
//
// AExtrCoords - Extremum Point Index Coords
// AExtrVal    - Exponent Value at Extremum Point
// AInfValue   - Exponent Value at Infinum AExtrValue and ASigma (dispersion)
// ASigmaX, ASigmaY - Sigma (dispersion) X Y Coefs
//
procedure TN_FVMatr.Add2DExp( AExtrCoords: TDPoint; AExtrVal, AInfVal,
                                                    ASigmaX, ASigmaY: double );
var
  i, j, ind: integer;
  dix, diy: double;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    dix := i - AExtrCoords.X;
    diy := j - AExtrCoords.Y;
    VM[ind] := VM[ind] + AInfVal + (AExtrVal-AInfVal)*exp(
               -Sqrt( dix*dix/(ASigmaX*ASigmaX) + diy*diy/(ASigmaY*ASigmaY) ) );
  end;
end; // procedure TN_FVMatr.Add2DExp

//*********************************************** TN_FVMatr.Resample ***
// Fill Self FMatr using interpolated values of given ASrcMatr and
// given AIMode - Interpolation mode
//
procedure TN_FVMatr.Resample( ASrcMatr: TN_FVMatr; AIMode: TN_2DIntMode );
var
  i, j, ind: integer;
  ax, ay: double;
begin
  for j := 0 to NY-1 do // loop along Self Rows
  begin

    for i := 0 to NX-1 do // loop along Self current Row Elements
    begin
      ind := j*NX + i;

      ax := 1.0*i/(NX-1)*(ASrcMatr.NX-1);
      ay := 1.0*j/(NY-1)*(ASrcMatr.NY-1);
      VM[ind] := ASrcMatr.GetValue( AIMode, ax, ay );
    end; // for i := 0 to NX-1 do // loop along current Row Elements

  end; // for j := 0 to NY-1 do // loop along Rows

end; // procedure TN_FVMatr.Resample

//*********************************************** TN_FVMatr.LinComb ***
// Linear Combination of Self and given operand AOpMatr:
// VM[i,j] := ACSelf*VM[i,j] + ACOp*AOpMatr[i,j]
// ( AOpMatr is iterpolated if have not same dimensions)
//
procedure TN_FVMatr.LinComb( ACSelf, ACOp, AAddVal: double; AOpMatr: TN_FVMatr;
                                                         AIMode: TN_2DIntMode );
var
  i, j, ind: integer;
  ax, ay: double;
begin
  if (ACOp = 0) or (AOpMatr = nil) then // use only Self
  begin

    for ind := 0 to NXY-1 do
      VM[ind] := ACSelf*VM[ind] + AAddVal;

  end else if (NX = AOpMatr.NX) and (NY = AOpMatr.NY) then // same dimensions
  begin
    for ind := 0 to NXY-1 do
      VM[ind] := ACSelf*VM[ind] + ACOp*AOpMatr.VM[ind] + AAddVal;
  end else // not same dimensions, interpolation of AOpMatr is needed
  begin

    for j := 0 to NY-1 do // loop along Self Rows
    begin

      for i := 0 to NX-1 do // loop along Self current Row Elements
      begin
        ind := j*NX + i;

        if (i=1) and (j=1) then // debug
          N_i := 1;

        ax := 1.0*i/(NX-1)*(AOpMatr.NX-1);
        ay := 1.0*j/(NY-1)*(AOpMatr.NY-1);
        VM[ind] := ACSelf*VM[ind] + ACOp*AOpMatr.GetValue( AIMode, ax, ay ) + AAddVal;
      end; // for i := 0 to NX-1 do // loop along current Row Elements

    end; // for j := 0 to NY-1 do // loop along Rows

  end; // else // not same dimensions, interpolation of AOpMatr is needed
end; // procedure TN_FVMatr.LinComb

//*********************************************** TN_FVMatr.SelfNorm ***
// Calculate Self Norm of ANormType
//
function TN_FVMatr.SelfNorm( ANormType: TN_NormType ): double;
var
  ind: integer;
begin
  Result := 0;

  case ANormType of

  ntL1: begin //********************* Mean Abs Difference
    for ind := 0 to NXY-1 do
      Result := Result + abs(VM[ind]);

    Result := Result / NXY;
  end; // ntL1: begin

  ntL2: begin //********************* Root Mean Square
    for ind := 0 to NXY-1 do
      Result := Result + VM[ind]*VM[ind];

    Result := sqrt( Result / NXY );
  end; // ntL2: begin

  ntLInf: begin //******************* Max abs Difference
    for ind := 0 to NXY-1 do
      if Result < abs(VM[ind]) then Result := abs(VM[ind]);

  end; // ntLInf: begin

  end; // case ANormType of

end; // function TN_FVMatr.SelfNorm

//*********************************************** TN_FVMatr.DifNorm ***
// Calculate ANormType Norm of difference btween Self and given AOpMatr
//
function TN_FVMatr.DifNorm( AOpMatr: TN_FVMatr; ANormType: TN_NormType;
                                                AIMode: TN_2DIntMode ): double;
var
  ind: integer;
  Delta: double;
  WrkMatr: TN_FVMatr;
begin
  Result := 0;

  if (NX = AOpMatr.NX) and (NY = AOpMatr.NY) then // same dimensions
  begin

    case ANormType of

    ntL1: begin //********************* Mean Abs Difference
      for ind := 0 to NXY-1 do
        Result := Result + abs( VM[ind] - AOpMatr.VM[ind] );

      Result := Result / NXY;
    end; // ntL1: begin

    ntL2: begin //********************* Root Mean Square
      for ind := 0 to NXY-1 do
      begin
        Delta := ( VM[ind] - AOpMatr.VM[ind] );
        Result := Result + Delta*Delta;
      end;

      Result := sqrt( Result / NXY );
    end; // ntL2: begin

    ntLInf: begin //******************* Max abs Difference
      for ind := 0 to NXY-1 do
      begin
        Delta := abs( VM[ind] - AOpMatr.VM[ind] );
        if Result < Delta then Result := Delta;
      end;

    end; // ntLInf: begin

    end; // case ANormType of

  end else //*************************************** different dimensions
  begin    //                       later redesign without creating new FMatr
    WrkMatr := TN_FVMatr.Create( Self );
    WrkMatr.LinComb( 1, -1, 0, AOpMatr, AIMode );
    Result := WrkMatr.SelfNorm( ANormType );
    WrkMatr.Free;
  end;

end; // function TN_FVMatr.DifNorm

//*********************************************** TN_FVMatr.AddToStrings ***
// Add Self to given Strings as Text (by Matr Rows, One Matr Row Strings Item)
//
procedure TN_FVMatr.AddToStrings( ASL: TStrings; AFmt: string );
var
  i, j, ind: integer;
  Str: string;
begin
  ASL.Add( Format( ' NX=%d NY=%d ', [NX,NY] ) );

  for j := 0 to NY-1 do // loop along Rows
  begin

    Str := '';
    for i := 0 to NX-1 do // loop along current Row Elements
    begin
      ind := j*NX + i;
      Str := Str + Format( AFmt, [VM[ind]] ) + ' ';
    end; // for i := 0 to NX-1 do // loop along current Row Elements

    ASL.Add( Str );
  end; // for j := 0 to NY-1 do // loop along Rows
end; // procedure TN_FVMatr.AddToStrings

//*********************************************** TN_FVMatr.GetFromStrings ***
// Get VMatr values from Strings, beginning from AFirstInd index
// (by Matr Rows, One Matr Row Strings Item)
// (Strings can be produced by AddToStrings method)
//
procedure TN_FVMatr.GetFromStrings( ASL: TStrings; AFirstInd: integer );
var
  i, j, ind, RetCode: integer;
  RowSL: TStringList;
begin
  RowSL := TStringList.Create();
  RowSL.Delimiter := ' ';
  RowSL.DelimitedText := ASL[AFirstInd];
  Inc( AFirstInd );

  NX := StrToInt( RowSL.Values['NX'] );
  NY := StrToInt( RowSL.Values['NY'] );
  NXY := NX*NY;
  VM := nil; // to avoid moving unnecessary data while resizing
  SetLength( VM, NXY );
  RowSL.Capacity := NX;

  for j := 0 to NY-1 do // loop along Rows
  begin
    RowSL.DelimitedText := ASL[AFirstInd];
    Inc( AFirstInd );

    for i := 0 to NX-1 do // loop along current Row Elements
    begin
      ind := j*NX + i;
      Val( RowSL[i], VM[ind], RetCode );
    end; // for i := 0 to NX-1 do // loop along current Row Elements

  end; // for j := 0 to NY-1 do // loop along Rows

  RowSL.Free;
end; // procedure TN_FVMatr.GetFromStrings

//********************************************* TN_FVMatr.ClipAndLinScale ***
// Clip and Lineal Scale all Self values
//
procedure TN_FVMatr.ClipAndLinScale( AInpMin, AInpMax, AOutMin, AOutMax: double );
var
  i, j, ind: integer;
  v, c: double;
begin
  c := (AOutMax - AOutMin) / (AInpMax - AInpMin);

  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    v := VM[ind];

    if v < AInpMin then v := AOutMin
    else if v > AInpMax then v := AOutMax
    else v := AOutMin + (v - AInpMin)*c;

    VM[ind] := v;
  end;
end; // procedure TN_FVMatr.ClipAndLinScale

//********************************************** TN_FVMatr.GetValue ***
// Get Value at (X,Y) point, given natural coords (0,NX-1) x (0,NY-1) using
// given AIMode - Interpolation Mode
//
function TN_FVMatr.GetValue( AIMode: TN_2DIntMode; AX, AY: double ): double;
begin
  Result := N_GetMatrValue( PFloat(@VM[0]), NX, NY, AIMode, AX, AY );
{
var
  ix, iy, ind: integer;
  v1, v2, dx, dy: double;
begin

  Result := OutValue;
  if (AX < 0) or (AX > (NX-1)) or (AY < 0) or (AY > (NY-1)) then Exit;

  v1 := Floor( AX );
  dx := AX - v1;
  ix := Round(v1);

  v1 := Floor( AY );
  dy := AY - v1;
  iy := Round(v1);

  ind := iy*NX + ix;

  case AIMode of

  tdimConst: Result := VM[ind]; // return value of nearest matrix node

  tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes
    v1 := dx*VM[ind]    + (1.0-dx)*VM[ind+1];    // horizontal interpolation by two upper nodes
    v2 := dx*VM[ind+NX] + (1.0-dx)*VM[ind+NX+1]; // horizontal interpolation by two lower nodes
    Result := dy*v1 + (1.0-dy)*v2; // // vertical interpolation
  end; // tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes

  tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes
    if dx > dy then // upper right triangle
    begin
      v1 := VM[ind+1]; // base value is value at upper right node
      Result := v1 + (1.0-dx)*(VM[ind] - v1) + dy*(VM[ind+NX+1] - v1);
    end else //******* lower left triangle
    begin
      v1 := VM[ind+NX]; // base value is value at lower left node
      Result := v1 + dx*(VM[ind+NX+1] - v1) + (1.0-dy)*(VM[ind] - v1);
    end;
  end; // tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes

  end; // case AIMode of
}
end; // function TN_FVMatr.GetValue

//********************************************* TN_FVMatr.CorrectValue ***
// Return corrected value: Result is near equal to given AValue, but <> VMatr[i,j]
//
// Later implement more effective algoritm if needed (first save indexes of
// VMatr values near given AValue and then check only them (not all VMatr nodes)
//
function TN_FVMatr.CorrectValue( AValue: double ): double;
var
  i, j, ind: integer;
  Label ChangeAgain;
begin
  Result := AValue;

  ChangeAgain:

  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    if VM[ind] = Result then
    begin
//    N_FEps   = 1.1920928955e-7;   // 1.0+N_FEps  > 1.0 (float precision)
      Result := Result + abs(Result)*N_FEps + 1.0e-30; // Minimal change for float format
      goto ChangeAgain; // check again all VMatr elements
    end;
  end; // for j := 0 to NY-1 do, for i := 0 to NX-1 do
end; // function TN_FVMatr.CorrectValue

//********************************************* TN_FVMatr.HSideIsOk ***
// return True if VMCurValue is stricly inside Hor Side EndValues
// VMBorderInd field is used for setting VMIncValues field if Result is True
//
function TN_FVMatr.HSideIsOk( ASideInd: integer ): boolean;
var
  VLeft, VRight: double;
begin
  Result := True;
  VLeft  := VM[ASideInd];
  VRight := VM[ASideInd+1];

  VMIncValues := (VMBorderInd = 0); // ( VMBorderInd is 0 or 2 )
  if (VLeft  < VMCurValue) and (VMCurValue < VRight) then Exit;

  VMIncValues := not VMIncValues;
  if (VRight < VMCurValue) and (VMCurValue < VLeft)  then Exit;

  Result := False;
end; // function TN_FVMatr.HSideIsOk

//********************************************* TN_FVMatr.VSideIsOk ***
// return True if VMCurValue is stricly inside Vert Side EndValues
// VMBorderInd field is used for setting VMIncValues field if Result is True
//
function TN_FVMatr.VSideIsOk( ASideInd: integer ): boolean;
var
  VTop, VBottom: double;
begin
  Result := True;
  VTop    := VM[ASideInd];
  VBottom := VM[ASideInd+NX];

  VMIncValues := (VMBorderInd = 1); // ( VMBorderInd is 1 or 3 )
  if (VTop  < VMCurValue) and (VMCurValue < VBottom) then Exit;

  VMIncValues := not VMIncValues;
  if (VBottom < VMCurValue) and (VMCurValue < VTop)  then Exit;

  Result := False;
end; // function TN_FVMatr.VSideIsOk

//********************************************* TN_FVMatr.GetSidesList ***
// Return border Sides List (sides with AValue1 or AValue2)
// All List elements are ordered in clockwise direction (from [0,0] node)
//
function TN_FVMatr.GetSidesList( AValue1, AValue2: double ): TN_VMSidesList;
var
  i, j, SideInd, ListInd: integer;
  TwoValues: boolean;

  procedure CheckSide( AVal: double ); // local
  // add one element to Result ( Result[ListInd] ) if needed, Inc ListInd
  // Self.VMBorderInd and SideInd variables are used and should be already set
  var
    SideIsOK: boolean;
  begin
    VMCurValue := AVal;

    if (VMBorderInd = 0) or (VMBorderInd = 2) then
      SideIsOK := HSideIsOk( SideInd )
    else
      SideIsOK := VSideIsOk( SideInd );

    if SideIsOK then
    begin
      if High(Result) < ListInd then
        SetLength( Result, N_NewLength(ListInd+1) );

      with Result[ListInd] do
      begin
        VMSideIndex   := SideInd;
        VMSBorderInd  := VMBorderInd;
        VMSIncValues  := VMIncValues; // was set by HSideIsOk
        VMSValue1     := (AVal = AValue1);
      end;

      Inc( ListInd );
    end; // if SideIsOk then
  end; // procedure CheckSide // local

begin
  SetLength( Result, 20 ); // initial value
  ListInd := 0;
  TwoValues := (AValue1 <> AValue2);

  for i := 0 to NX-2 do // loop along Top VMatr border (from Left to Right)
  begin
    SideInd := i;
    VMBorderInd := 0; // Top border index
    CheckSide( AValue1 );
    if TwoValues then CheckSide( AValue2 );
  end;

  for j := 0 to NY-2 do // loop along Right VMatr border (from Top to Bottom)
  begin
    SideInd := (NX-1) + j*NX;
    VMBorderInd := 1; // Right border index
    CheckSide( AValue1 );
    if TwoValues then CheckSide( AValue2 );
  end;

  for i := 0 to NX-2 do // loop along Bottom VMatr border (from Right to Left)
  begin
    SideInd := (NX*NY-2) - i;
    VMBorderInd := 2; // Bottom border index
    CheckSide( AValue1 );
    if TwoValues then CheckSide( AValue2 );
  end;

  for j := 0 to NY-2 do // loop along Left VMatr border (from Bottom to Top)
  begin
    SideInd := NX*(NY-2) - j*NX;
    VMBorderInd := 3; // Left border index
    CheckSide( AValue1 );
    if TwoValues then CheckSide( AValue2 );
  end;

  SetLength( Result, ListInd );
end; // function TN_FVMatr.GetSidesList

//********************************************** TN_FVMatr.AddIsoLine ***
// Add to given AULines IsoLine Items for given AValue
//
procedure TN_FVMatr.AddIsoLine( AValue: float; AULines: TN_ULines );
var
  i, j, ind: integer;
  VSides, HSides: TN_BArray;
  CurFragm: TN_DPArray;
  HorSide1, IncInds1: boolean;
  VMS: TN_VMSidesList;
  ULinesItem: TN_ULinesItem;
  Label ChangeAgain;

  procedure AddNewItem( ASideInd: integer; AHorSide, AIncInds: boolean ); // local
  // Create and Add New AULines Item (IsoLine fragment) that begins on Side,
  // described by given ASideInd, AHorSide, AIncInds
  var
    CurFragmInd, BegSideInd, SideXInd, SideYInd, PrevSideInd, NumVar: integer;
    VLeft, VRight, VTop, VBottom: double;
    BegHorSide: boolean;
  begin

  NumVar := 0; // to avoid warning
  CurFragmInd := 0; // free index in CurFragm array of DPoints (Start CurFragment)
  BegSideInd := ASideInd; // BegPoint Side Index (for checking end of CurFragment)
  BegHorSide := AHorSide; // BegPoint Side type (for checking end of CurFragment)

  while True do //******************* add points to CurFragm till IsoLine end
  begin
  N_i := NumVar; // to avoid warning

  //***** Here: ASideInd, AHorSide, AIncInds variables are given as params
  //            or just set in previos loop pass

  //***** Add Cur Point to CurFragm

  if CurFragmInd >= 6 then // debug
    N_i := 0;

  if CurFragmInd > High(CurFragm) then // Increase CurFragm if needed
    SetLength( CurFragm, N_NewLength(CurFragmInd+1) );

  SideYInd := ASideInd div NX;  // Set SideXInd, SideYInd by given SideInd
  SideXInd := ASideInd - SideYInd*NX;

  if AHorSide then // add new Point on Horizontal Side
  begin
    VLeft  := VM[ASideInd];
    VRight := VM[ASideInd+1];
    CurFragm[CurFragmInd].X := SideXInd + (VMCurValue-VLeft)/(VRight-VLeft);
    CurFragm[CurFragmInd].Y := SideYInd;
    if CurFragmInd > 0 then HSides[ASideInd] := 1; // set "Sides was processed" flag
  end else //******* add new Point on Vertical Side
  begin
    VTop    := VM[ASideInd];
    VBottom := VM[ASideInd+NX];
    CurFragm[CurFragmInd].X := SideXInd;
    CurFragm[CurFragmInd].Y := SideYInd + (VMCurValue-VTop)/(VBottom-VTop);
    if CurFragmInd > 0 then VSides[ASideInd] := 1; // set "Sides was processed" flag
  end;
  Inc( CurFragmInd ); // prepare for next point

  //***** Check if Cur Point is Last Point in Item
  //      (Same as first or on the VMatr border)

  if (CurFragmInd > 1 ) then // not first CurFragm point, check if CurFragm is finished
  begin
    //***** Check if cur Side is Same as beg Side
    if (BegHorSide = AHorSide) and (BegSideInd = ASideInd) then Break;

    //***** Check if cur Side is on the border

    if AHorSide then // cur Point is on Horizontal Side
    begin
      if (SideYInd = 0) or (SideYInd = (NY-1)) then // cur Point is on Top or Bottom border
      begin
        HSides[BegSideInd] := 1; // not really needed, just a precaution
        Break;
      end;
    end else //******* cur Point is on Vertical Side
    begin
      if (SideXInd = 0) or (SideXInd = (NX-1)) then // cur Point is on Left or Right border
      begin
        VSides[BegSideInd] := 1; // not really needed, just a precaution
        Break;
      end;
    end;
  end; // if (CurFragmInd > 1 ) then // not first CurFragm point

  //***** Analize next cell, set next Side Position
  //      (set SideXInd, SideYInd, HorSide, IncInds variables for next Side)

  PrevSideInd := ASideInd; // ASideInd should be set for next loop pass
  NumVar := 0; // for error checking

  if AHorSide then // cur Point is on Horizontal Side
  begin

    if AIncInds then // analize VMatr Cell lower than current Hor Side
    begin
      // SideInd remains the same   //***** Check lower Left VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := False;
          NumVar  := 1;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd + 1; //***** Check lower Right VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := True;
          NumVar  := 2;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd + NX; //***** Check lower Bottom HSide
      if HSides[ASideInd] = 0 then
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := True;
          NumVar  := 3;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

    end else // analize VMatr Cell higher than current Hor Side (IncInds = False)
    begin
      ASideInd := PrevSideInd - NX;  //***** Check upper Left VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := False;
          NumVar  := 4;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd - NX + 1; //***** Check upper Right VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := True;
          NumVar   := 5;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd - NX; //***** Check upper Upper HSide
      if HSides[ASideInd] = 0 then
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := False;
          NumVar  := 6;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

    end; // end else // analize VMatr Cell higher than current Hor Side
  end else //******* cur Point is on Vertical Side (HorSide = False)
  begin

    if AIncInds then // analize VMatr Cell righter than current Vert Side
    begin
      // SideInd remains the same   //***** Check righter Top HSide
      if HSides[ASideInd] = 0 then
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := False;
          NumVar  := 7;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd + NX;  //***** Check righter Bottom HSide
      if HSides[ASideInd] = 0 then
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := True;
          NumVar  := 8;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd + 1;  //***** Check righter Right VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := True;
          NumVar  := 9;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

    end else // analize VMatr Cell lefter than current Vert Side (IncInds = False)
    begin
      ASideInd := PrevSideInd - 1; //***** Check lefter Top HSide
      if HSides[ASideInd] = 0 then
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := False;
          NumVar  := 10;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd - 1 + NX;
      if HSides[ASideInd] = 0 then  //***** Check lefter Bottom HSide
      begin
        if HSideIsOk( ASideInd ) then
        begin
          AHorSide := True;
          AIncInds := True;
          NumVar  := 11;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          HSides[ASideInd] := 1; // to speed up checking
      end;

      ASideInd := PrevSideInd - 1; //***** Check lefter Left VSide
      if VSides[ASideInd] = 0 then
      begin
        if VSideIsOk( ASideInd ) then
        begin
          AHorSide := False;
          AIncInds := False;
          NumVar  := 12;
          Continue; // add point at ASideInd, AHorSide, AIncInds
        end else
          VSides[ASideInd] := 1; // to speed up checking
      end;

    end; // end else // analize VMatr Cell higher than current Hor Side

  end; // end else //******* cur Point is on Vertical Side

//  Assert( NumVar > 0, 'IzoError!' );
  if NumVar = 0 then Break; // debug!!!
  end; // while True do //******************* add points to CurFragm till IsoLine end

  //***** Here: CurFragm is OK (closed or with ends on VMatr borders)

//  AULines.AddSimpleItem( CurFragm, CurFragmInd ); // New Item created and added (old var)
  ULinesItem.AddPartCoords( CurFragm, 0, CurFragmInd ); // Add new Part
  end; // procedure AddNewItem // local

begin //************************************** body of CalcIsoLine method

  SetLength( CurFragm, 2*(NX+NY) ); // initial size

  SetLength( HSides, NXY );
  FillChar( HSides[0], NXY, 0 );

  SetLength( VSides, NXY );
  FillChar( VSides[0], NXY, 0 );

  for j := 0 to NY-1 do
    HSides[(NX-1) + j*NX] := 1; // mark not existed HSides (a precaution)

  for i := 0 to NX-1 do
    VSides[(NY-1)*NX+i] := 1; // mark not existed VSides (a precaution)

  VMCurValue := CorrectValue( AValue ); // assure that VMCurValue <> VMatr[i,j]

  ULinesItem := TN_ULinesItem.Create( N_DoubleCoords );

  //***** Loop along all VMatr borders

  VMS := GetSidesList( VMCurValue, VMCurValue );

  for i := 0 to High(VMS) do
  with VMS[i] do
  begin
    HorSide1 := (VMSBorderInd = 0) or (VMSBorderInd = 2);
    IncInds1 := (VMSBorderInd = 0) or (VMSBorderInd = 3);

    if HorSide1 then // Hor Side
    begin
      if HSides[VMSideIndex] = 0 then // not already processed
      begin
        AddNewItem( VMSideIndex, HorSide1, IncInds1 );
        HSides[VMSideIndex] := 1;
      end
    end else //******** Vert Side
    begin
      if VSides[VMSideIndex] = 0 then // not already processed
      begin
        AddNewItem( VMSideIndex, HorSide1, IncInds1 );
        VSides[VMSideIndex] := 1;
      end;
    end;
  end;

//  Exit; // debug
  //***** Loop along all other VMatr sides (not processed yet)

  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
//    if ind = 22 then // debug
//      N_i := 0;

    if HSides[ind] = 0 then
    begin
      if HSideIsOk( Ind ) then
        AddNewItem( Ind, True, True )
      else
        HSides[ind] := 1; // to speed up checking
    end;

    if VSides[ind] = 0 then
    begin
      if VSideIsOk( Ind ) then
        AddNewItem( Ind, False, True )
      else
        VSides[ind] := 1; // to speed up checking
    end;

  end; // for j := 0 to NY-1 do, for i := 0 to NX-1 do

  if ULinesItem.INumPoints = 0 then // temporary, to protect colors
  begin
    ULinesItem.CreateSegmItem( DPoint(0, 1.0e5), DPoint(0, 1.1e5), 0 );
  end;

  AULines.ReplaceItemCoords( ULinesItem, -1 ); // Add new Item to ULines

  ULinesItem.Free;

end; // procedure TN_FVMatr.AddIsoLine

//********************************************** TN_FVMatr.AddIzoCont ***
// Add to given AULines IsoLine Items for given AMinValue, AMaxValue,
// assemble them to closed Contour and add created Contour to AUConts
//
procedure TN_FVMatr.AddIzoCont( AMinValue, AMaxValue: float; AULines: TN_ULines;
                                                        AUConts: TN_UContours );
var
  i, BegItem, OuterCode, NumEnds, DCInd, NumPairs: integer;
  CorMinValue, CorMaxValue: float;
  Connect01: boolean;
  DC: TN_DPArray;
  E1, E2: TN_VMSideInfo;
  VMS: TN_VMSidesList;

  procedure AddCoords( ASideInd: integer; AValue: float; AHorSide: boolean ); // local
  // Add one Point coords to DC and inc FreeInd
  var
    SideXInd, SideYInd: integer;
    VLeft, VRight, VTop, VBottom: double;
  begin
    SideYInd := ASideInd div NX;  // Set SideXInd, SideYInd by given ASideInd
    SideXInd := ASideInd - SideYInd*NX;

    if AHorSide then // add new Point on Horizontal Side
    begin
      VLeft  := VM[ASideInd];
      VRight := VM[ASideInd+1];
      DC[DCInd].X := SideXInd + (AValue-VLeft)/(VRight-VLeft);
      DC[DCInd].Y := SideYInd;
    end else //******* add new Point on Vertical Side
    begin
      VTop    := VM[ASideInd];
      VBottom := VM[ASideInd+NX];
      DC[DCInd].X := SideXInd;
      DC[DCInd].Y := SideYInd + (AValue-VTop)/(VBottom-VTop);
    end;
    Inc( DCInd ); // prepare for next point
  end; // procedure AddCoords - local

  procedure ConnectTwoEnds( AEndInd1, AEndInd2: integer ); // local
  // Connect two given Ends
  var
    i: integer;
    HorSide: boolean;
    Value: float;
  begin
    DCInd := 0;
    E1 := VMS[AEndInd1];
    E2 := VMS[AEndInd2];

    if AEndInd1 > AEndInd2 then // last connection (MaxInd->0)
    begin
      if E1.VMSBorderInd >= E2.VMSBorderInd then  // all four corners should
        Inc( E2.VMSBorderInd, 4 )     // be added if E1.VMSBorderInd = E2.VMSBorderInd
    end else // "normal" connection
      if E1.VMSBorderInd > E2.VMSBorderInd then
        Inc( E2.VMSBorderInd, 4 ); // at least upper left corner should be added

    HorSide := (E1.VMSBorderInd = 0) or (E1.VMSBorderInd = 2);
    if E1.VMSValue1 then Value := CorMinValue
                    else Value := CorMaxValue;

    AddCoords( E1.VMSideIndex, Value, HorSide ); // first (End1) point

    for i := E1.VMSBorderInd to E2.VMSBorderInd-1 do // add needed corners
    begin
      if (i = 0) or (i = 4) then // add upper right corner
      begin
        DC[DCInd] := DPoint( NX-1, 0 );
        Inc( DCInd );
      end;

      if (i = 1) or (i = 5) then // add lower right corner
      begin
        DC[DCInd] := DPoint( NX-1, NY-1 );
        Inc( DCInd );
      end;

      if (i = 2) or (i = 6) then // add lower left corner
      begin
        DC[DCInd] := DPoint( 0, NY-1 );
        Inc( DCInd );
      end;

      if (i = 3) or (i = 7) then // add upper left corner
      begin
        DC[DCInd] := DPoint( 0, 0 );
        Inc( DCInd );
      end;

    end; // for i := E1.VMSBorderInd to E2.VMSBorderInd-1 do // add needed corners

    HorSide := (E2.VMSBorderInd and $01) = 0; // True if 0,2,4,6
    if E2.VMSValue1 then Value := CorMinValue
                    else Value := CorMaxValue;

    AddCoords( E2.VMSideIndex, Value, HorSide ); // last (End2) point

    AULines.AddSimpleItem( DC, DCInd ); // segment or polyline between given Ends
  end; // procedure ConnectTwoEnds - local

begin
  BegItem := AULines.WNumItems;

  CorMinValue := CorrectValue( AMinValue ); // assure that CorMinValue <> VMatr[i,j]
  AddIsoLine( CorMinValue, AUlines );

  if CorMinValue >= AMaxValue then AMaxValue := AMaxValue + abs(AMaxValue)*N_FEps;
  CorMaxValue := CorrectValue( AMaxValue ); // assure that CorMaxValue <> VMatr[i,j]
  AddIsoLine( CorMaxValue, AUlines );

  VMS := GetSidesList( CorMinValue, CorMaxValue );
  NumEnds := Length(VMS);
  Assert( NumEnds mod 2 = 0, 'Bad Number of Ends!' ); // NumEnds should be even

  if NumEnds = 0 then // no IsoLines on Borders
  begin
    // check if all border values are in (CorMinValue, CorMaxValue) range:
    if (CorMinValue < VM[0]) and (VM[0] < CorMaxValue) then
      AULines.AddRectItem( FRect( 0, 0, NX-1, NY-1 ) ); // add whole border rect
  end else //*************** if Length(VMS) <> 0
  begin
    SetLength( DC, 6 ); // max possible value
    NumPairs := NumEnds div 2; // number of connections (Pairs of EndPoints to connect)

    //***** Analize E1, E2 (two first Ends) to define which Ends should be
    //      connected and set Connect01 variable

    E1 := VMS[0];
    E2 := VMS[1];

    if E1.VMSValue1 = E2.VMSValue1 then // both Ends belongs to same Value
    begin
      // Connect01 is True if E1 belongs to MinValue and Values are increasing
      //                   or E1 belongs to MaxValue and Values are decreasing
      Connect01 :=      (E1.VMSValue1  and  E1.VMSIncValues) or
                   ((not E1.VMSValue1) and (not E1.VMSIncValues));
    end else // // E1, E2 Ends belongs to different Values and should be connected
      Connect01 := True;

    if Connect01 then // connect 0->1, 2->3, 4->5, ... , (NumEnds-2)->(NumEnds-1)
      for i := 0 to NumPairs-1 do
        ConnectTwoEnds( 2*i, 2*i+1 )
    else // connect 1->2, 3->4, 5->6, ... , (NumEnds-1)->0
    begin
      for i := 0 to NumPairs-2 do
        ConnectTwoEnds( 2*i+1, 2*i+2 );

      ConnectTwoEnds( NumEnds-1, 0 ); // connect last End with first End
    end;
  end; // else // if Length(VMS) <> 0

//  RegCode := 2;
//  AULines.SetRegCodes( BegItem, AULines.WNumItems-BegItem, @RegCode, 1 );

  for i := BegItem to AULines.WNumItems-1 do
    AULines.SetItemThreeCodes( i, i, 2, -1 );

  OuterCode := 0;
  N_UDlinesToUDContours2( OuterCode, 0, AULines, AUConts );

  with AUConts do
  begin
    SetSelfULines( AULines );
    CalcEnvRects();
    WComment := 'Contours from ' + AULines.ObjName + ' layer';
  end;

end; // procedure TN_FVMatr.AddIzoCont

//********************************************** TN_FVMatr.CreateRaster ***
// Create Raster Obj from Self by given RangeValues, Colors and PixelFormat
//
function TN_FVMatr.CreateRaster( APRangeValue: PDouble; APColor: PInteger;
                                 ANumColors: integer; ARType: TN_RasterType;
                                 APixFmt: TPixelFormat ): TN_RasterObj;
var
  i, j, ind, RangeInd: integer;
  WrkPColor: PInteger;

  function GetRangeInd( AValue: float ): integer; // local
  // Get Range Index by given AValue using K_SearchInScale
  begin
    Result := K_IndexOfDoubleInScale( APRangeValue, ANumColors, 8, AValue );
  end; // function GetRangeInd - local

begin
  Result := TN_RasterObj.Create( ARType );
  with Result do
  begin

  RR.RWidth  := NX;
  RR.RHeight := NY;
  RR.RPixFmt := APixFmt;
  if APixFmt = pf8bit then RR.RNumPalColors := ANumColors;
  PrepSelfFields(); // RasterObj method

  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    RangeInd := GetRangeInd( VM[ind] );

    if APixFmt = pf8bit then
      SetPixelValue( i, j, RangeInd )
    else // now only TrueColor mode
    begin
      WrkPColor := APColor;
      Inc( WrkPColor, RangeInd );
      SetPixelValue( i, j, WrkPColor^ )
    end;

  end; // for j := 0 to NY-1 do, for i := 0 to NX-1 do

  if APixFmt = pf8bit then
    SetPalColors( APColor, ANumColors );

  end; // with Result do
end; // function TN_FVMatr.CreateRaster

//********************************************** TN_FVMatr.CreateLabels ***
// Create NX*NY Strings with Node Attributes (by Rows)
// (place for NX*NY Strings should be already allocated)
//
procedure TN_FVMatr.CreateLabels( ALabelType: TN_MLLabelType; AFmt: string;
                                  APFLabel: TN_BytesPtr; ABytesStep: integer );
var
  i, j, ind: integer;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;

    case ALabelType of

    mlltInds: begin
      PString(APFLabel+ind*ABytesStep)^ := Format( AFmt, [i,j] );
    end;

    mlltValues: begin
      PString(APFLabel+ind*ABytesStep)^ := Format( AFmt, [VM[ind]] );
    end;

    end; // case ALabelType of

  end;
end; // procedure TN_FVMatr.CreateLabels


//********** TN_DVMatr class methods  **************

//****************************************************** TN_DVMatr.Create() ***
//
constructor TN_DVMatr.Create();
begin
  SetSize( 0, 0 );
end; // end_of constructor TN_DVMatr.Create()

//************************************************* TN_DVMatr.Create(NX,NY) ***
//
constructor TN_DVMatr.Create( ANX, ANY: integer );
begin
  SetSize( ANX, ANY );
//  FillChar( VM[0], NXY*Sizeof(Float), 0 );
end; // end_of constructor TN_DVMatr.Create(NX,NY)

//********************************************** TN_DVMatr.Create(PInteger) ***
//
constructor TN_DVMatr.Create( PIVal: PInteger; ANX, ANY: integer );
begin
  SetValues( PIVal, ANX, ANY );
end; // end_of constructor TN_DVMatr.Create(PInteger)

//************************************************ TN_DVMatr.Create(PFloat) ***
//
constructor TN_DVMatr.Create( PFVal: PFloat; ANX, ANY: integer );
begin
  SetValues( PFVal, ANX, ANY );
end; // end_of constructor TN_DVMatr.Create(PFloat)

//*********************************************** TN_DVMatr.Create(PDouble) ***
//
constructor TN_DVMatr.Create( PDVal: PDouble; ANX, ANY: integer );
begin
  SetValues( PDVal, ANX, ANY );
end; // end_of constructor TN_DVMatr.Create(PDouble)

//******************************************************* TN_DVMatr.Destroy ***
//
destructor TN_DVMatr.Destroy;
begin
  VM := nil;
  inherited Destroy;
end; // end_of destructor TN_DVMatr.Destroy

//******************************************************* TN_DVMatr.SetSize ***
// Set Self Size (Self Dimensions) without changing VM values
//
procedure TN_DVMatr.SetSize( ANX, ANY: integer );
begin
  if (NX = ANX) and (NY = ANY) then Exit; // already OK

  Assert( (ANX > 1) and (ANY > 1), 'Bad dim!' );

  NX  := ANX;
  NY  := ANY;
  NXY := NX * NY;
  VM  := nil; // to avoid unneeded data moving
  SetLength( VM, NXY );
end; // procedure TN_DVMatr.SetSize

//*********************************************** TN_DVMatr.Clear ***
// Set all VM elements to 0
//
procedure TN_DVMatr.Clear();
begin
  FillChar( VM[0], NXY*Sizeof(VM[0]), 0 );
end; // procedure TN_DVMatr.Clear

//******************************************* TN_DVMatr.SetValues(PInteger) ***
// Set Self Values by given Integers
//
procedure TN_DVMatr.SetValues( PIVal: PInteger; ANX, ANY: integer );
var
  i: integer;
begin
  SetSize( ANX, ANY );

  for i := 0 to NXY-1 do
  begin
    VM[i] := PIVal^;
    Inc( PIVal );
  end;
end; // procedure TN_DVMatr.SetValues(PInteger)

//********************************************* TN_DVMatr.SetValues(PFloat) ***
// Set Self Values by given Floats
//
procedure TN_DVMatr.SetValues( PFVal: PFloat; ANX, ANY: integer );
var
  i: integer;
begin
  SetSize( ANX, ANY );

  for i := 0 to NXY-1 do
  begin
    VM[i] := PFVal^;
    Inc( PFVal );
  end;
end; // procedure TN_DVMatr.SetValues(PFloat)

//******************************************** TN_DVMatr.SetValues(PDouble) ***
// Set Self Values by given Doubles
//
procedure TN_DVMatr.SetValues( PDVal: PDouble; ANX, ANY: integer );
begin
  SetSize( ANX, ANY );
  move( PDVal^, VM[0], NXY*Sizeof(VM[0]) );
end; // procedure TN_DVMatr.SetValues(PDouble)

//******************************************* TN_DVMatr.GetValues(PInteger) ***
// Set given Floats by Self Values
//
procedure TN_DVMatr.GetValues( PIVal: PInteger );
var
  i: integer;
begin
  for i := 0 to NXY-1 do
  begin
    PIVal^ := Round(VM[i]);
    Inc( PIVal );
  end;
end; // procedure TN_DVMatr.GetValues(PInteger)

//********************************************* TN_DVMatr.GetValues(PFloat) ***
// Set given Floats by Self Values
//
procedure TN_DVMatr.GetValues( PFVal: PFloat );
var
  i: integer;
begin
  for i := 0 to NXY-1 do
  begin
    PFVal^ := VM[i];
    Inc( PFVal );
  end;
end; // procedure TN_DVMatr.GetValues(PFloat)

//******************************************** TN_DVMatr.GetValues(PDouble) ***
// Set given Doubles by Self Values
//
procedure TN_DVMatr.GetValues( PDVal: PDouble );
begin
  move( VM[0], PDVal^, NXY*Sizeof(VM[0]) );
end; // procedure TN_DVMatr.GetValues(PDouble)

//*************************************************** TN_DVMatr.AddLin1Func ***
// Add to Self Linear Func with given X,Y Steps:
// VM[0,0]=AVX0Y0, VM[ix,iy]=AVX0Y0 + ix*AStepX + iy*AStepY
//
procedure TN_DVMatr.AddLin1Func( AVX0Y0, AStepX, AStepY: double );
var
  i, j, ind: integer;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    VM[ind] := AVX0Y0 + i*AStepX + j*AStepY;
  end;
end; // procedure TN_DVMatr.AddLin1Func

//*************************************************** TN_DVMatr.AddLin2Func ***
// Add to Self Linear Func with given values at:
// VM[0,0]=AVX0Y0, VM[NX-1,0]=AVXMaxY0, VM[0,NY-1]=AVX0YMax
//
procedure TN_DVMatr.AddLin2Func( AVX0Y0, AVXMaxY0, AVX0YMax: double );
var
  i, j, ind: integer;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    VM[ind] := AVX0Y0 + (AVXMaxY0-AVX0Y0)*i/(NX-1) + (AVX0YMax-AVX0Y0)*j/(NY-1);
  end;
end; // procedure TN_DVMatr.AddLin2Func

//****************************************************** TN_DVMatr.AddParab ***
// Add to Self Parabolic func with given:
// AExtrCoords - Extremum Point Index Coords
// AExtrVal    - Func Value at Extremum Point
// ACX, ACY    - coefs at DX*DX and DY*DY terms
//
procedure TN_DVMatr.AddParab( AExtrCoords: TDPoint; AExtrVal, ACX, ACY: double );
var
  i, j, ind: integer;
  dix, diy: double;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    dix := i - AExtrCoords.X;
    diy := j - AExtrCoords.Y;
    VM[ind] := VM[ind] + AExtrVal + ACX*dix*dix + ACY*diy*diy;
  end;
end; // procedure TN_DVMatr.AddParab

//****************************************************** TN_DVMatr.Add2DExp ***
// Add to Self 2D Exponent with given:
//
// AExtrCoords - Extremum Point Index Coords
// AExtrVal    - Exponent Value at Extremum Point
// AInfValue   - Exponent Value at Infinum AExtrValue and ASigma (dispersion)
// ASigmaX, ASigmaY - Sigma (dispersion) X Y Coefs
//
procedure TN_DVMatr.Add2DExp( AExtrCoords: TDPoint; AExtrVal, AInfVal,
                                                    ASigmaX, ASigmaY: double );
var
  i, j, ind: integer;
  dix, diy: double;
begin
  for i := 0 to NX-1 do
  for j := 0 to NY-1 do
  begin
    ind := j*NX + i;
    dix := i - AExtrCoords.X;
    diy := j - AExtrCoords.Y;
    VM[ind] := VM[ind] + AInfVal + (AExtrVal-AInfVal)*exp(
               -Sqrt( dix*dix/(ASigmaX*ASigmaX) + diy*diy/(ASigmaY*ASigmaY) ) );
  end;
end; // procedure TN_DVMatr.Add2DExp



    //*********** TN_SplineLineObj methods  *****************************

//******************************************* TN_SplineLineObj.SplineLine ***
// Spline given ASrcDC Line into resulting AResDC Line
// can be used with TN_ULines.AddConvertedItems method
//
procedure TN_SplineLineObj.SplineLine( ASrcDC: TN_DPArray; var AResDC: TN_DPArray );
begin
  N_SplineLine( PSplineParams, ASrcDC, AResDC );
end; // procedure TN_SplineLineObj.SplineLine

    //*********** TN_AffConvObj methods  *****************************

//*********************************************** TN_AffConvObj.AffConvDP ***
// Aff Conv one DPoint using Pointer to needed convertion coefs
//
function TN_AffConvObj.AffConvDP( const ASrcDP: TDPoint; AParams: Pointer ): TDPoint;
var
  W: double;
begin
  if InsideGivenRect then  // convert only inside GivenRect
  begin
    if 0 <> N_PointInRect( ASrcDP, GivenRect ) then // skip convertion
    begin
      Result := ASrcDP;
      Exit;
    end;
  end;

  if PAffCoefs4 <> nil then
  with PAffCoefs4^ do
  begin
    Result.X := CX * ASrcDP.X + SX;
    Result.Y := CY * ASrcDP.Y + SY;
  end else if PAffCoefs6 <> nil then
  with PAffCoefs6^ do
  begin
    Result.X := CXX * ASrcDP.X + CXY * ASrcDP.Y + SX;
    Result.Y := CYX * ASrcDP.X + CYY * ASrcDP.Y + SY;
  end else if PAffCoefs8 <> nil then
  with PAffCoefs8^ do
  begin
    W := WX * ASrcDP.X + WY * ASrcDP.Y + 1.0;
    Result.X := ( CXX * ASrcDP.X + CXY * ASrcDP.Y + SX ) / W;
    Result.Y := ( CYX * ASrcDP.X + CYY * ASrcDP.Y + SY ) / W;
  end;
end; // function TN_AffConvObj.AffConvDP


    //*********** TN_XYPWIConvObj methods  *****************************

//******************************************** TN_XYPWIConvObj.NLConvPrep ***
// Check data consistency and Prepare Params for calling NLConvDP method
// (X or Y coord NonLinear Convertion based on N_1DPWIFunc)
// Return 0 if Data are OK or Error number ( >= 1 )
//
// APParams structure:
//    [0] - Decimal Digits flags:
//         DD1 - What Coord to convert: =0 - Y convertion, =1 - X convertion
//         DD2 - Additional convertion: =0 - not needed,   =1 - GivenReper <--> N_D100Reper
//         DD3 - not used
//         DD4 - always = 6 (for consistency check)
//    [1]   - cubic part coef
//    [2,3] - Reserved
//
//    [4-9] - Reper (6 doubles) for additional Affine convertion
//
//    [10..k]   - Pairs of X,Y where X - Argument value, Y - Alfa Value (if (0<=Y<=1)
//                  or 100 + YCoefsIndex
//    [k+1,k+2] - N_DPDelimeter1
//
//    [k+3,N]   - YCoefs0, YCoefs1, ... in N_1DPWIFunc format
//    [N+1,N+2] - N_DPDelimeter1 - end of all YCoefs
//
function TN_XYPWIConvObj.NLConvPrep( APParams: PDouble ): integer;
var
  i, CurNumYPoints, TmpInt, CurXSegmInd, CurAlfaInd, YCoefsInd: integer;
  CurX, CubicPart, XCoefsDD: double;
  PCur: PDouble;
  GivenReper, DefReper: TN_3DPReper;
  Label Cont1;
begin
  PCur := APParams;

  //***** Process DD(4-1)

  TmpInt := Round(PCur^);
  Inc(PCur); // skip DD(4-1)
  PWICoordsMode := TmpInt mod 10;
  PWIAddAffConv := (TmpInt mod 100) div 10;
  TmpInt        := (TmpInt mod 10000) div 1000;
  Result := 1; // Bad Data type
  if TmpInt <> 6 then Exit; // Error

  CubicPart := PCur^;
  if CubicPart = 0 then XCoefsDD := 5000
                   else XCoefsDD := 5010;
  Inc( PCur, 3 ); // skip CubicPart and two reserved doubles
  //***** Process Reper

  PWIToNormAffC6.CXX   := N_NotADouble; // a precaution
  PWIFromNormAffC6.CXX := N_NotADouble; // a precaution

  if PWIAddAffConv = 1 then  // Additional Convertion is needed, Create Coefs by DReper
  begin
    move( PCur^, GivenReper, 6*Sizeof(double) );
    DefReper := N_D100Reper;

    PWIToNormAffC6   := N_CalcAffCoefs6( GivenReper, DefReper );
    N_dp := N_AffConv6D2DPoint( -10, -90, PWIToNormAffC6 ); // debug
    PWIFromNormAffC6 := N_CalcAffCoefs6( DefReper, GivenReper );
    N_dp := N_AffConv6D2DPoint( 0, 0, PWIFromNormAffC6 ); // debug
  end; // if PWIAddAffConv = 1 then  // Additional Convertion is needed, Create Coefs by DReper

  Inc( PCur, 6 ); // skip given Reper

  //***** Process X,YInd(Alfa) pairs

  SetLength( PWIXData, 10 );
  SetLength( PWIXEnds, 10 );

  with PWIXData[0] do
  begin
    SetLength( ASDArgCoefs, 10 );

    ASDArgCoefs[0].Y := XCoefsDD; // XCoefs Falgs

    ASDArgCoefs[1].X := CubicPart; // XBeg
    ASDArgCoefs[1].Y := 0;   // not used

    ASDArgCoefs[2].X := PCur^; // XBeg
    ASDArgCoefs[2].Y := 0;     // initial Alfa value, always = 0
  end; // with PWIXData[0] do

  CurAlfaInd := 3;

  PWIXEnds[0] := PCur^; // XBeg
  Inc( PCur ); // skip XBeg

  Result := 2; // Not YCoefs Ind
  if PCur^ < 100 then Exit;
  PWIXData[0].ASDFuncCoefs0Ind := Round( PCur^ - 100 );
  Inc( PCur ); // skip YCoefs Index

  CurXSegmInd := 0;

  while True do // parse Pairs of X,Alfa(YInd) till N_DPDelimeter1
  begin
    CurX := PCur^;
    Inc( PCur ); // skip X

    if PCur^ >= 100 then // is YCoefs Index for End of CurXSegmInd Segment
    begin
      with PWIXData[CurXSegmInd] do // finish PWIXData[CurXSegmInd]
      begin
        SetLength( ASDArgCoefs, CurAlfaInd+1 ); // final value
        ASDArgCoefs[0].X := CurAlfaInd-1; // number of X points
        ASDArgCoefs[CurAlfaInd].X := CurX;
        ASDArgCoefs[CurAlfaInd].Y := 1.0; // Alfa value for end of Interval, always = 1
        YCoefsInd := Round( PCur^ - 100 );
        ASDFuncCoefs1Ind := YCoefsInd;
      end;

      PWIXEnds[CurXSegmInd+1] := CurX;
      Inc( PCur ); // skip YCoefsInd

      if CompareMem( PCur, @N_DPDelimeter1, SizeOf(TDPoint) ) then // end of X,YInd(Alfa) pairs
      begin
        PWINumXSegments := CurXSegmInd + 1;
        SetLength( PWIXData, PWINumXSegments );
        SetLength( PWIXEnds, PWINumXSegments+1 );

        Inc( PCur, 2 ); // skip N_DPDelimeter1
        goto Cont1;
      end else // Begin next X Segment with same CurX
      begin
        if CurXSegmInd > High( PWIXData ) then
        begin
          SetLength( PWIXData, N_NewLength( CurXSegmInd+1 ) );
          SetLength( PWIXEnds, N_NewLength( CurXSegmInd+2 ) );
        end;

        with PWIXData[CurXSegmInd] do
        begin
          SetLength( ASDArgCoefs, 10 );

          ASDArgCoefs[0].Y := XCoefsDD; // XCoefs Falgs

          ASDArgCoefs[1].X := CubicPart; // XBeg
          ASDArgCoefs[1].Y := 0;   // not used

          ASDArgCoefs[2].X := CurX; // XBeg
          ASDArgCoefs[2].Y := 0;    // initial Alfa value, always = 0

          ASDFuncCoefs0Ind := YCoefsInd;
        end; // with PWIXData[0] do

        CurAlfaInd := 3;
      end;
    end else // PCur^ < 100 - is Alfa Value
    with PWIXData[CurXSegmInd] do
    begin
      Result := 4; // Alfa not in (0-1) interval
      if (PCur^ < 0) or (PCur^ > 1) then Exit; // error
      if CurAlfaInd > High( ASDArgCoefs ) then
        SetLength( ASDArgCoefs, N_NewLength( CurAlfaInd+1 ) );

      ASDArgCoefs[CurAlfaInd].X := CurX;
      ASDArgCoefs[CurAlfaInd].Y := PCur^; // Alfa value
      Inc( CurAlfaInd );
      Inc( PCur ); // to next pair
    end; //  else // PCur^ < 100 - is Alfa Value

  end; // while True do // parse Pairs of X,Alfa(YInd) till N_DPDelimeter1


  Cont1: //*********** N_DPDelimeter1 after X,YInd(Alfa) pairs was found
         //            check and collect given YCoefs

  SetLength( PWIPYCoefs, 100 );
  YCoefsInd := 0;

  while True do // along all YCoefs sets till  N_DPDelimeter1
  begin
    PWIPYCoefs[YCoefsInd] := PCur;
    Result := 10 + YCoefsInd; // Error in YCoefsInd YCoefs
    CurNumYPoints := N_1DPWIFuncCheck( PCur ); // Check Data and update PCur
    if CurNumYPoints <= 0 then Exit; // error
    if CompareMem( PCur, @N_DPDelimeter1, SizeOf(TDPoint) ) then Break; // end of all YCoefs
    Inc( YCoefsInd );
  end; // while True do // along all YCoefs sets till  N_DPDelimeter1

  PWINumYCoefs := YCoefsInd + 1;
  SetLength( PWIPYCoefs, PWINumYCoefs );

  //***** Check if collected YCoefs Inds are correct

  Result := 5; // YCoefs Index out of bounds

  for i := 0 to PWINumXSegments-1 do // along all X Segments
  with PWIXData[i] do
  begin
    if (ASDFuncCoefs0Ind < 0) or (ASDFuncCoefs0Ind >= PWINumYCoefs) or
       (ASDFuncCoefs1Ind < 0) or (ASDFuncCoefs1Ind >= PWINumYCoefs) then Exit; // Error
  end; // for i := 0 to PWINumXSegments-1 do // along all X Segments

  Result := 0; // all is OK
end; // function TN_XYPWIConvObj.NLConvPrep

//********************************************** TN_XYPWIConvObj.NLConvDP ***
// X or Y coord NonLinear Convertion based on N_1DPWIFunc
// Return converted given DPoint (ASrcDP), only one coord (X or Y) is changed
//
// ASrcDP  - Source point coords
// AParams - Additional Params, not used now
//
function TN_XYPWIConvObj.NLConvDP( const ASrcDP: TDPoint; AParams: Pointer ): TDPoint;
var
  ISInd: integer;
  Alfa, X_Arg, Y_Arg, Y_Func: double;
  TmpDP: TDPoint;
begin
  TmpDP := ASrcDP;

  if TmpDP.X > 72 then
    N_i := 1;

  if PWIAddAffConv = 1 then // all coefs are in (0,0,100,100) Rect, AffConv TmpDP
    TmpDP := N_AffConv6D2DPoint( TmpDP.X, TmpDP.Y, PWIToNormAffC6 );

  if PWICoordsMode = 0 then // ASrcDP.X remains the same, ASrcDP.Y should be changed
  begin
    X_Arg := TmpDP.X;
    Y_Arg := TmpDP.Y;
  end else //********************* ASrcDP.Y remains the same, ASrcDP.X should be changed
  begin
    X_Arg := TmpDP.Y;
    Y_Arg := TmpDP.X;
  end;

  //***** Calc Y_Func - new (converted) coord

  if X_Arg <= PWIXEnds[0] then // X_Arg <= XMin
  begin
    Y_Func := N_1DPWIFunc( Y_Arg, PWIPYCoefs[PWIXData[0].ASDFuncCoefs0Ind] );
  end else if X_Arg >= PWIXEnds[PWINumXSegments] then // X_Arg >= XMax
  begin
    Y_Func := N_1DPWIFunc( Y_Arg, PWIPYCoefs[PWIXData[PWINumXSegments-1].ASDFuncCoefs1Ind] );
  end else // X_Arg is inside (XMin, XMax)
  begin
    ISInd := N_BinSegmSearch( TN_BytesPtr(@PWIXEnds[0]), PWINumXSegments+1, SizeOf(Double), X_Arg );
    with PWIXData[ISInd] do
    begin
      Alfa := N_1DPWIFunc( X_Arg, @ASDArgCoefs[0].X );
      Y_Func := (1-Alfa) * N_1DPWIFunc( Y_Arg, PWIPYCoefs[ASDFuncCoefs0Ind] ) +
                   Alfa  * N_1DPWIFunc( Y_Arg, PWIPYCoefs[ASDFuncCoefs1Ind] );
    end; // with PWIXData[ISInd] do
  end; //  else // X_Arg is inside (XMin, XMax)

  if PWICoordsMode = 0 then // ASrcDP.X remains the same, ASrcDP.Y should be changed
    TmpDP.Y := Y_Func
  else //********************* ASrcDP.Y remains the same, ASrcDP.X should be changed
    TmpDP.X := Y_Func;

  if PWIAddAffConv = 1 then // all coefs are in (0,0,100,100) Rect, AffConv TmpDP back
    Result := N_AffConv6D2DPoint( TmpDP.X, TmpDP.Y, PWIFromNormAffC6 )
  else
    Result := TmpDP;
end; // function TN_XYPWIConvObj.NLConvDP


//********** TN_GeoProjObj class methods  **************

const GPRAD = 0.017453293;
const GPA   = 8.181334E-2;

//*************************************************** TN_GeoProjObj.S ***
// Вычисление длины дуги меридиана
// B - дуга меридиана в градусах
//
function TN_GeoProjObj.S( B: double ): double;
var
 SS, cosB, sinB, cosB2: double;
begin
  B := B * GPRAD; // convert to radians
  cosB := cos(B);  sinB := sin(B);  cosB2 := cosB * cosB;
  SS := sinB * cosB * (-32140.4049 + cosB2 * (135.3303 + cosB2 *
                                               (-0.7092 + cosB2 * 0.0042)));
  Result := 6367558.4969 * B + SS;
end; // end of function TN_GeoProjObj.S

//*************************************************** TN_GeoProjObj.N ***
// Вычисление радиуса кривизны первого вертикала
//
function TN_GeoProjObj.N( B: double ): double;
var
  A1: double;
begin
  A1 := GPA * sin(B * GPRAD);
  Result := 6378245.0 / sqrt( 1.0 - (A1*A1) );
end; // end of function TN_GeoProjObj.N

//*************************************************** TN_GeoProjObj.RP ***
// Вычисление радиуса параллели
// B - широта в градусах
//
function TN_GeoProjObj.RP( B: double ): double;
begin
  Result := N(B) * cos(B*GPRAD);
end; // end of function TN_GeoProjObj.RP

//*************************************************** TN_GeoProjObj.U ***
// Вычисление логарифма изометрической широты
//
function TN_GeoProjObj.U( B: double ): double;
var
  B1, D1, D2, D3: double;
begin
  B1 := B/2.0+45.0;
  D1 := tan(B1*GPRAD);
  D2 := GPA*sin(B*GPRAD);
  D3 := (1.0-D2)/(1.0+D2);
  Result := ln(D1) + 0.5*GPA*ln(D3);
end; // end of function TN_GeoProjObj.U

//********************************************* TN_GeoProjObj.Create ***
//
constructor TN_GeoProjObj.Create();
begin
  GPType := 0;
  Alfa := N_NotADouble; // Alfa, Q, C coefs. are not ready
end; //*** end of Constructor TN_GeoProjObj.Create

//********************************************* TN_GeoProjObj.SetCoefsByStr ***
// Set Input GeoProj Coefs by String
//
procedure TN_GeoProjObj.SetCoefsByStr( AStr: string );
var
  WrkStr: string;
begin
  WrkStr := AStr;
  Scale := N_ScanDouble( WrkStr );

  BS := N_ScanDouble( WrkStr ); // ( 0 < BS < B1 < B2 < BN )
  B1 := N_ScanDouble( WrkStr );
  B2 := N_ScanDouble( WrkStr );
  BN := N_ScanDouble( WrkStr );

  LW := N_ScanDouble( WrkStr ); // ( LW < L0 < LE )
  L0 := N_ScanDouble( WrkStr );
  LE := N_ScanDouble( WrkStr );

  GPType := N_ScanInteger( WrkStr ); // 1, 2, 3
// =1 - normal conical 1 (нормальная коническая равнопромежуточная)
// =2 - normal conical 2 (нормальная коническая равноугольная)
// =3 - normal cilindrycal Mercator (нормальная цилиндрическая Меркатора)

  ConvMode := N_ScanInteger( WrkStr ); // Convertion Mode Flags

  Alfa := N_NotADouble; // set "coefs are not calculated flag"
end; // procedure TN_GeoProjObj.SetCoefsByStr

//******************************************* TN_GeoProjObj.ConvertLine ***
// convert Line coords from (B,L) to needed geo projection
// ConvMode - convertion mode flags:
//   bit4($010) =0 - convert from degree (B,L or L,B) to metric (X,Y) coords
//              =1 - convert from metric (X,Y) to degree (B,L or L,B) coords
//
//   bit5($020) =0 - first degree coords is B, second is L
//              =1 - first degree coords is L, second is B
//
//   bit6($040) =0 - do not toggle B sign
//              =1 - toggle B sign
//
// InpCoords and OutCoords can be the same Array
//
procedure TN_GeoProjObj.ConvertLine( const InpCoords: TN_DPArray;
                            var OutCoords: TN_DPArray; ConvMode: integer );
var
  i: integer;
  R1, R2, S1, S2, U1, U2, RO, SIG, W, L, B, X, Y: double;
begin
  if Length(OutCoords) <> Length(InpCoords) then
    SetLength( OutCoords, Length(InpCoords) );

  if Alfa = N_NotADouble then // calc projection coefs
  begin

  case GPType of

  0: begin // not used
  end;

  1: begin //***** normal conical 1
           // нормальная (прямая) коническая равнопромежуточная
           // проекция (эллипсоид Красовского)
    if (B1 = B2) then
    begin
      Alfa := sin( B1 * GPRAD );
      C    := N( B1 ) / tan(  B1 * GPRAD) + S(B1);
    end else // B1 <> B2
    begin
      R1   := RP(B1);  R2 := RP(B2);
      S1   := S(B1);   S2 := S(B2);
      Alfa := (R1 - R2) / (S2 - S1);
      C    := R2 / Alfa + S2;
    end;

    Q := 8.0e+6;

    RO := C - S(BS);
    MRec.Top := (Q - RO) / Scale;
    RO := C - S(BN);
    MRec.Bottom := (Q - RO) / Scale;

    SIG := Alfa * ((LW - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 1: begin // normal conical 1

  2: begin //***** normal conical 2 (нормальная коническая )
           // нормальная (прямая) коническая равнопромежуточная
           // проекция (эллипсоид Красовского)
    R1 := RP(B1);
    U1 := U(B1);
    if B1 <> B2 then
    begin
      R2   := RP(B2);
      U2   := U(B2);
      Alfa := ln(R1/R2)/(U2-U1);
    end else
      Alfa := sin(B1 * GPRAD);

    C := exp(ln(R1/Alfa)+Alfa*U1);
    Q := 8.0E06;

    RO := C * exp(-Alfa * U(BS));
    MRec.Top := (Q - RO) / Scale;
    RO := C * exp(-Alfa * U(BN));
    MRec.Bottom := (Q - RO) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LW - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 2: begin // normal conical 2 (нормальная коническая )

  3: begin //***** normal cilindrycal Mercator
           // нормальная цилиндрическая проекция Меркатора (сфера)
    C := RP( B1 );

    MRec.Left := ( C * LE * GPRAD ) / Scale;
    MRec.Top  := ( C * U( BS ) ) / Scale;

    MRec.Right  := ( C * LW * GPRAD ) / Scale;
    MRec.Bottom := ( C * U( BN ) ) / Scale;
  end; // 3: begin // normal cilindrycal Mercator

  else Assert( False, 'Unknown Projection type' );

  end; // end of case GPType of

  end; // if Alfa = N_NotADouble then // calc projection coefs


  //***** all coefs are OK, convert coords

  case GPType of
  1: begin //*************************** normal conical 1

  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    W := (Q / Scale - (Y+MRec.Top)) *
         (Q / Scale - (Y+MRec.Top))
        + (X+MRec.Left) * (X+MRec.Left);
    B := (C - Scale * sqrt(W)) / 6367558.5;
    OutCoords[i].X := (B + (25184.5 * sin(2*B) + 37.0 * sin(4*B)) * 1.0E-7)
                                                                    / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);
    OutCoords[i].Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end else //*** convert from B,L or L,B to X,Y ( (ConvMode and $010) = 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C - S( B );
    SIG := Alfa * ( L - L0 ) * GPRAD;
    OutCoords[i].X := RO * sin(SIG) / Scale - MRec.Left;
    OutCoords[i].Y := (Q - RO * cos(SIG)) / Scale - MRec.Top;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end;
  end; // 1: begin // normal conical 1

  2: begin //*************************** normal conical 2
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    W := Q / Scale - Y;
    W := W*W + X*X;
    W := ln(C / (W * Scale)) / Alfa;
    B := 2.0 * arctan(exp(W)) - 90.0 * GPRAD;
    OutCoords[i].X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7)
                                                                       / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);
    OutCoords[i].Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C * exp(-Alfa * U(B));
    SIG := Alfa * (L - L0) * GPRAD;
    OutCoords[i].X := RO * sin(SIG) / Scale;
    OutCoords[i].Y := (Q - RO * cos(SIG)) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end; // for i := 0 to High(InpCoords) do
  end; // 2: begin // normal conical 2

  3: begin //*************************** normal cilindrycal Mercator
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    B := Y * Scale / C;
    B := 2.0 * arctan(exp(B)) - 90. * GPRAD;
    OutCoords[i].X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7) /
                                                                      GPRAD;
    OutCoords[i].Y := (X * Scale) / (C * GPRAD);

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                          // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end // for i := 0 to High(InpCoords) do, if
  else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    OutCoords[i].X := ( C * L * GPRAD ) / Scale;
    OutCoords[i].Y := ( C * U( B ) ) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end; // for i := 0 to High(InpCoords) do
  end; // 3: begin // normal cilindrycal Mercator

  end; // case GPType of
end; //*** end of procedure TN_GeoProjObj.ConvertLine

//******************************************* TN_GeoProjObj.GeoProjConvPrep ***
// Prepare Coefs for calling GeoProjConvDP method
//
procedure TN_GeoProjObj.GeoProjConvPrep( APParams: PDouble );
begin
  case GPType of

  0: begin // not used
  end;

  1: begin //***** normal conical 1
           // нормальная (прямая) коническая равнопромежуточная
           // проекция (эллипсоид Красовского)
    if (B1 = B2) then
    begin
      Alfa := sin( B1 * GPRAD );
      C    := N( B1 ) / tan(  B1 * GPRAD) + S(B1);
    end else // B1 <> B2
    begin
      R1   := RP(B1);  R2 := RP(B2);
      S1   := S(B1);   S2 := S(B2);
      Alfa := (R1 - R2) / (S2 - S1);
      C    := R2 / Alfa + S2;
    end;

    Q := 8.0e+6;

    RO := C - S(BS);
    MRec.Top := (Q - RO) / Scale;
    RO := C - S(BN);
    MRec.Bottom := (Q - RO) / Scale;

    SIG := Alfa * ((LW - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 1: begin // normal conical 1

  2: begin //***** normal conical 2 (нормальная коническая )
           // нормальная (прямая) коническая равнопромежуточная
           // проекция (эллипсоид Красовского)
    R1 := RP(B1);
    U1 := U(B1);
    if B1 <> B2 then
    begin
      R2   := RP(B2);
      U2   := U(B2);
      Alfa := ln(R1/R2)/(U2-U1);
    end else
      Alfa := sin(B1 * GPRAD);

    C := exp(ln(R1/Alfa)+Alfa*U1);
    Q := 8.0E06;

    RO := C * exp(-Alfa * U(BS));
    MRec.Top := (Q - RO) / Scale;
    RO := C * exp(-Alfa * U(BN));
    MRec.Bottom := (Q - RO) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LW - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 2: begin // normal conical 2 (нормальная коническая )

  3: begin //***** normal cilindrycal Mercator
           // нормальная цилиндрическая проекция Меркатора (сфера)
    C := RP( B1 );

    MRec.Left := ( C * LE * GPRAD ) / Scale;
    MRec.Top  := ( C * U( BS ) ) / Scale;

    MRec.Right  := ( C * LW * GPRAD ) / Scale;
    MRec.Bottom := ( C * U( BN ) ) / Scale;
  end; // 3: begin // normal cilindrycal Mercator

  else Assert( False, 'Unknown Projection type' );

  end; // end of case GPType of
end; // procedure TN_GeoProjObj.GeoProjConvPrep

//********************************************* TN_GeoProjObj.GeoProjConvDP ***
// X or Y coord NonLinear Convertion based on N_1DPWIFunc
// Return converted given DPoint (ASrcDP), only one coord (X or Y) is changed
//
// ASrcDP  - Source point coords
// AParams - Additional Params, not used now
//
function TN_GeoProjObj.GeoProjConvDP( const ASrcDP: TDPoint; AParams: Pointer ): TDPoint;
var
  W, L, B, X, Y: double;
begin
  case GPType of
  1: begin //*************************** normal conical 1

  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  begin
    X := ASrcDP.X;
    Y := ASrcDP.Y;

    W := (Q / Scale - (Y+MRec.Top)) *
         (Q / Scale - (Y+MRec.Top))
        + (X+MRec.Left) * (X+MRec.Left);
    B := (C - Scale * sqrt(W)) / 6367558.5;
    Result.X := (B + (25184.5 * sin(2*B) + 37.0 * sin(4*B)) * 1.0E-7)
                                                                    / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);

    Result.Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      Result.X := -Result.X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := Result.X;
      Result.X := Result.Y;
      Result.Y := B;
    end;
  end else //*** convert from B,L or L,B to X,Y ( (ConvMode and $010) = 0 )
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := ASrcDP.X;
      B := ASrcDP.Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := ASrcDP.X;
      L := ASrcDP.Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C - S( B );
    SIG := Alfa * ( L - L0 ) * GPRAD;
    Result.X := RO * sin(SIG) / Scale - MRec.Left;
    Result.Y := (Q - RO * cos(SIG)) / Scale - MRec.Top;

    if (ConvMode and $080) = 0 then // toggle Y sign
      Result.Y := -Result.Y;

  end;
  end; // 1: begin // normal conical 1

  2: begin //*************************** normal conical 2
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  begin
    X := ASrcDP.X;
    Y := ASrcDP.Y;

    W := Q / Scale - Y;
    W := W*W + X*X;
    W := ln(C / (W * Scale)) / Alfa;
    B := 2.0 * arctan(exp(W)) - 90.0 * GPRAD;
    Result.X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7)
                                                                       / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);
    Result.Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      Result.X := -Result.X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := Result.X;
      Result.X := Result.Y;
      Result.Y := B;
    end;
  end else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := ASrcDP.X;
      B := ASrcDP.Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := ASrcDP.X;
      L := ASrcDP.Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C * exp(-Alfa * U(B));
    SIG := Alfa * (L - L0) * GPRAD;
    Result.X := RO * sin(SIG) / Scale;
    Result.Y := (Q - RO * cos(SIG)) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      Result.Y := -Result.Y;

  end;
  end; // 2: begin // normal conical 2

  3: begin //*************************** normal cilindrycal Mercator
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  begin
    X := ASrcDP.X;
    Y := ASrcDP.Y;

    B := Y * Scale / C;
    B := 2.0 * arctan(exp(B)) - 90. * GPRAD;
    Result.X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7) /
                                                                      GPRAD;
    Result.Y := (X * Scale) / (C * GPRAD);

    if (ConvMode and $040) <> 0 then // toggle B sign
      Result.X := -Result.X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                          // swap (B,L)
      B := Result.X;
      Result.X := Result.Y;
      Result.Y := B;
    end;
  end // for i := 0 to High(InpCoords) do, if
  else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := ASrcDP.X;
      B := ASrcDP.Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := ASrcDP.X;
      L := ASrcDP.Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    Result.X := ( C * L * GPRAD ) / Scale;
    Result.Y := ( C * U( B ) ) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      Result.Y := -Result.Y;

  end;
  end; // 3: begin // normal cilindrycal Mercator

  end; // case GPType of
end; // function TN_GeoProjObj.GeoProjConvDP


    //*********** TN_RectsConvObj methods  *****************************

//********************************************* TN_RectsConvObj.NLConvPrep ***
// Just store all Rect Coords
//
function TN_RectsConvObj.NLConvPrep( const AEnvRect, ASrcRect,
                                                      ADstRect: TFRect ): integer;
begin
  EnvRect := AEnvRect;
  SrcRect := ASrcRect;
  DstRect := ADstRect;
  Result := 0;
end; // function TN_RectsConvObj.NLConvPrep

//*********************************************** TN_RectsConvObj.NLConvDP ***
// Non Linear Convertion of ASrcDP by Self Tree Rects
// Return converted DPoint
//
// ASrcDP  - Source point coords
// AParams - Additional Params, not used now
//
function TN_RectsConvObj.NLConvDP( const ASrcDP: TDPoint; AParams: Pointer ): TDPoint;
var
  XCoef, YCoef: double;
  PTL, PBL, PTR, PBR: TDPoint;
  EnvTopRight, EnvBotLeft, SrcTopRight, SrcBotLeft, DstTopRight, DstBotLeft: TFPoint;
  Label LeftArea, TopArea, RightArea, BottomArea;

  function LinY( AXArg: double; const AP1, AP2: TFPoint ): double; // local
  // Calc Func(Y) Value for given AXArg on line, given by two points AP1, AP2
  begin
    Result := AP1.Y + (AXArg - AP1.X)*(AP2.Y - AP1.Y)/(AP2.X - AP1.X);
  end; // function LinY - local

  function LinX( AYArg: double; const AP1, AP2: TFPoint ): double; // local
  // Calc Func(X) Value for given AYArg on line, given by two points AP1, AP2
  begin
    Result := AP1.X + (AYArg - AP1.Y)*(AP2.X - AP1.X)/(AP2.Y - AP1.Y);
  end; // function LinX - local

  begin //************************* body of TN_RectsConvObj.NLConvDP
  Result := ASrcDP;

  // Y Axis has Top -> Down direction (as Screen Coords)

  if (ASrcDP.X <= EnvRect.Left) or (ASrcDP.X >= EnvRect.Right) or
     (ASrcDP.Y <= EnvRect.Top)  or (ASrcDP.Y >= EnvRect.Bottom) then Exit; // out of EnvRect

  if (ASrcDP.X >= SrcRect.Left) and (ASrcDP.X <= SrcRect.Right) and
     (ASrcDP.Y >= SrcRect.Top)  and (ASrcDP.Y <= SrcRect.Bottom) then // Inside SrcRect
  begin
    XCoef := (ASrcDP.X - SrcRect.Left) / (SrcRect.Right - SrcRect.Left);
    YCoef := (ASrcDP.Y - SrcRect.Top) / (SrcRect.Bottom - SrcRect.Top);

    Result.X := DstRect.Left + (DstRect.Right - DstRect.Left)*XCoef;
    Result.Y := DstRect.Top  + (DstRect.Bottom - DstRect.Top)*YCoef;
    Exit; // from inside of SrcRect to inside of DstRect
  end; // if ... then // Inside SrcRect

  //***** Here: ASrcDP is inside of EnvRect but outside of SrcRect

  EnvTopRight := FPoint( EnvRect.Right, EnvRect.Top );
  EnvBotLeft  := FPoint( EnvRect.Left,  EnvRect.Bottom );

  if ASrcDP.X <= SrcRect.Left then // Top, Left or Bottom Area
  begin
    PTL.Y := LinY( ASrcDP.X, SrcRect.TopLeft, EnvRect.TopLeft );

    if ASrcDP.Y <= PTL.Y then // Left part of TopArea
    begin
      PTL.X := LinX( ASrcDP.Y, SrcRect.TopLeft, EnvRect.TopLeft );

      SrcTopRight := FPoint( SrcRect.Right, SrcRect.Top );
      PTR.X := LinX( ASrcDP.Y, SrcTopRight, EnvTopRight );

      goto TopArea; // Left part of TopArea
    end else // Middle part of LeftArea or Left part of BottomArea
    begin
      SrcBotLeft := FPoint( SrcRect.Left, SrcRect.Bottom );

      PBL.Y := LinY( ASrcDP.X, SrcBotLeft, EnvBotLeft );

      if ASrcDP.Y >= PBL.Y then // Left part of BottomArea
      begin
        PBL.X := LinX( ASrcDP.Y, SrcBotLeft, EnvBotLeft );

        PBR.X := LinX( ASrcDP.Y, SrcRect.BottomRight, EnvRect.BottomRight );
        goto BottomArea; // Left part of BottomArea
      end else // Middle part of LeftArea
        goto LeftArea;
    end; // else // Middle part of LeftArea or Left part of BottomArea

  end; // if ASrcDP <= SrcRect.Left then // Top, Left or Bottom Area

  if ASrcDP.X >= SrcRect.Right then // Top, Right or Bottom Area
  begin
    SrcTopRight := FPoint( SrcRect.Right, SrcRect.Top );
    PTR.Y := LinY( ASrcDP.X, SrcTopRight, EnvTopRight );

    if ASrcDP.Y <= PTR.Y then // Right part of TopArea
    begin
      PTL.X := LinX( ASrcDP.Y, SrcRect.TopLeft, EnvRect.TopLeft );
      PTR.X := LinX( ASrcDP.Y, SrcTopRight, EnvTopRight );
      goto TopArea; // Right part of TopArea
    end else // Middle part of RightArea or Right part of BottomArea
    begin
      SrcBotLeft := FPoint( SrcRect.Left, SrcRect.Bottom );

      PBR.Y := LinY( ASrcDP.X, SrcRect.BottomRight, EnvRect.BottomRight );

      if ASrcDP.Y >= PBR.Y then // Right part of BottomArea
      begin
        PBR.X := LinX( ASrcDP.Y, SrcRect.BottomRight, EnvRect.BottomRight );

        SrcBotLeft := FPoint( SrcRect.Left, SrcRect.Bottom );
        PBL.X := LinX( ASrcDP.Y, SrcBotLeft, EnvBotLeft );

        goto BottomArea; // Right part of BottomArea
      end else // Middle part of RightArea
        goto RightArea;
    end; // else // Middle part of RightArea or Right part of BottomArea

  end; // if ASrcDP.X >= SrcRect.Right then // Top, Right or Bottom Area

  //***** Here: SrcRect.Left <= ASrcDP.X <= SrcRect.Right,
  //            Middle part of Top or Bottom Area

  if ASrcDP.Y <= SrcRect.Top then // Middle part of Top Area
  begin
    PTL.X := LinX( ASrcDP.Y, SrcRect.TopLeft, EnvRect.TopLeft );

    SrcTopRight := FPoint( SrcRect.Right, SrcRect.Top );
    PTR.X := LinX( ASrcDP.Y, SrcTopRight, EnvTopRight );

    goto TopArea;
  end else // Middle part of Bottom Area
  begin
    PBR.X := LinX( ASrcDP.Y, SrcRect.BottomRight, EnvRect.BottomRight );

    SrcBotLeft := FPoint( SrcRect.Left, SrcRect.Bottom );
    PBL.X := LinX( ASrcDP.Y, SrcBotLeft, EnvBotLeft );

    goto BottomArea;
  end; // else // Middle part of Bottom Area


  LeftArea: //**************** PTL.Y, PBL.Y are OK

    XCoef := (SrcRect.Left - ASrcDP.X)/(SrcRect.Left - EnvRect.Left);
    Result.X := DstRect.Left - XCoef*(DstRect.Left - EnvRect.Left);

    YCoef := (ASrcDP.Y - PTL.Y)/(PBL.Y - PTL.Y);
    DstBotLeft := FPoint( DstRect.Left, DstRect.Bottom );
    PTL.Y := LinY( Result.X, DstRect.TopLeft, EnvRect.TopLeft );
    PBL.Y := LinY( Result.X, DstBotLeft, EnvBotLeft );
    Result.Y := PTL.Y + YCoef*(PBL.Y - PTL.Y);
    Exit;

  TopArea: //**************** PTL.X, PTR.X are OK

    YCoef := (SrcRect.Top - ASrcDP.Y)/(SrcRect.Top - EnvRect.Top);
    Result.Y := DstRect.Top - YCoef*(DstRect.Top - EnvRect.Top);

    XCoef := (ASrcDP.X - PTL.X)/(PTR.X - PTL.X);
    DstTopRight := FPoint( DstRect.Right, DstRect.Top );
    PTL.X := LinX( Result.Y, DstRect.TopLeft, EnvRect.TopLeft );
    PTR.X := LinX( Result.Y, DstTopRight, EnvTopRight );
    Result.X := PTL.X + XCoef*(PTR.X - PTL.X);
    Exit;

  RightArea: //**************** PTR.Y, PBR.Y are OK

    XCoef := (ASrcDP.X - SrcRect.Right)/(EnvRect.Right - SrcRect.Right);
    Result.X := DstRect.Right + XCoef*(EnvRect.Right - DstRect.Right);

    YCoef := (ASrcDP.Y - PTR.Y)/(PBR.Y - PTR.Y);
    DstTopRight := FPoint( DstRect.Right, DstRect.Top );
    PTR.Y := LinY( Result.X, DstTopRight, EnvTopRight );
    PBR.Y := LinY( Result.X, DstRect.BottomRight, EnvRect.BottomRight );
    Result.Y := PTR.Y + YCoef*(PBR.Y - PTR.Y);
    Exit;

  BottomArea: //**************** PBL.X, PBR.X are OK

    YCoef := (ASrcDP.Y - SrcRect.Bottom)/(EnvRect.Bottom - SrcRect.Bottom);
    Result.Y := DstRect.Bottom + YCoef*(EnvRect.Bottom - DstRect.Bottom);

    XCoef := (ASrcDP.X - PBL.X)/(PBR.X - PBL.X);
    DstBotLeft := FPoint( DstRect.Left, DstRect.Bottom );
    PBR.X := LinX( Result.Y, DstRect.BottomRight, EnvRect.BottomRight );
    PBL.X := LinX( Result.Y, DstBotLeft, EnvBotLeft );
    Result.X := PBL.X + XCoef*(PBR.X - PBL.X);

end; // function TN_RectsConvObj.NLConvDP


    //*********** TN_MatrConvObj methods  *****************************

//************************************************ TN_MatrConvObj.SetParams ***
// Set given Params to Self fields and check them
// return 0 if OK or > 0 if Error
//
function TN_MatrConvObj.SetParams( ANX, ANY: integer; AMatrEnvRect: TFRect;
                                             APMatrFPoints: PFPoint ): integer;
begin
  MNX := ANX;
  MNY := ANY;
  MatrSrcRect := AMatrEnvRect;
  PMatr := APMatrFPoints;
  Result := CheckParams( integer(PMatr) );
end; // function TN_MatrConvObj.SetParams

//********************************************** TN_MatrConvObj.CheckParams ***
// Check current Params (Self fields), if AMode = 0 skip checking Matr Values
// return 0 if OK or Result >= 1 if Error
//
function TN_MatrConvObj.CheckParams( AMode: integer ): integer;
var
  ix, iy: integer;
  PCur, PCur1: PFPoint;
begin
  with MatrSrcRect do // check MatrSrcRect
  begin
    Result := 1;
    if Left = N_NotAFloat then Exit; // some precautions

    Result := 2;
    if (Right - Left) <= 0 then Exit;
    if (Bottom - Top) <= 0 then Exit;
  end; // with MatrSrcRect do // check MatrSrcRect

  Result := 3;
  if (MNX <= 1) or (MNY <= 1) then Exit;

  Result := 0; // Ok
  if AMode = 0 then Exit;

  //***** Chect Matr values

  Result := 4;
  if PMatr = nil then Exit;

  Result := 0;
  Exit; // temp!!!

  Result := 5;
  PCur := PMatr;

  for iy := 0 to MNY-1 do
  for ix := 0 to MNX-1 do
  begin
    if ix <> (MNX-1) then // not last column
    begin
      PCur1 := PCur;
      Inc( PCur1, 1 );
      if PCur1^.X <= PCur^.X then Exit;
    end;

    if iy <> (MNY-1) then // not last row
    begin
      PCur1 := PCur;
      Inc( PCur1, MNX );
      if PCur1^.Y <= PCur^.Y then Exit;
    end;

    Inc( PCur );
  end; // for ix := 0 to MNX-2 do for iy := 0 to MNY-2 do

  Result := 0; // Ok
end; // function TN_MatrConvObj.CheckParams

//************************************************* TN_MatrConvObj.InitMatr ***
// Initialize Matrix Values by current Params
// PMatr should point to enough free space
//
procedure TN_MatrConvObj.InitMatr();
var
  ix, iy: integer;
  dx, dy: double;
  PCur: PFPoint;
begin
  with MatrSrcRect do
  begin
    dx := (Right - Left) / (MNX-1);
    dy := (Bottom - Top) / (MNY-1);
  end; // with MatrSrcRect do

  PCur := PMatr;

  for iy := 0 to MNY-1 do
  for ix := 0 to MNX-1 do
  with MatrSrcRect do
  begin
    PCur^ := FPoint( Left + ix*dx, Top + iy*dy );
    Inc( PCur );
  end;
end; // procedure TN_MatrConvObj.InitMatr

//************************************************* TN_MatrConvObj.ConvMatr ***
// Convert Matrix Values by given Convertion function AFunc
//
procedure TN_MatrConvObj.ConvMatr( AFunc: TN_ConvDPFuncObj );
var
  i: integer;
  PCur: PFPoint;
begin
  PCur := PMatr;

  for i := 0 to MNX*MNY-1 do
  begin
    PCur^ := FPoint( AFunc( DPoint( PCur^ ) ) );
    Inc( PCur );
  end; // for i := 0 to MNX*MNY-1 do
end; // procedure procedure TN_MatrConvObj.ConvMatr

//************************************************* TN_MatrConvObj.NLConvDP ***
// Non Linear Convertion of ASrcDP by Self Matrix
// Return converted given DPoint
//
// ASrcDP  - Source point coords
// AParams - Additional Params, not used now
//
function TN_MatrConvObj.NLConvDP( const ASrcDP: TDPoint; AParams: Pointer ): TDPoint;
var
  ix, iy, Ind: integer;
  cx, cy, XCoef, YCoef: double;
  PCur, PCur1: PFloat;
  PM, PM1: PFPoint;
  P1, P2: TDPoint;
begin
  Result := ASrcDP;

  if PXVals <> nil then // use PXVals, PYVals (not fully implemented)
  begin
    PCur := PXVals;
    Inc( PCur, MNX-1 ); // PCur points to XMax
    ix := Round(Floor( (ASrcDP.X - PXVals^) / (PCur^ - PXVals^) ));
    if (ix < 0) or (ix >= (MNX-1)) then Exit; // ASrcDP is out of Matr

    PCur := PYVals;
    Inc( PCur, MNY-1 ); // PCur points to YMax
    iy := Round(Floor( (ASrcDP.Y - PYVals^) / (PCur^ - PYVals^) ));
    if (iy < 0) or (iy >= (MNY-1)) then Exit; // ASrcDP is out of Matr

    PCur := PXVals; Inc( PCur, ix ); // PCur points to XBeg
    PCur1 := PCur;  Inc( PCur1 );
    XCoef := (ASrcDP.X - PCur^) / (PCur1^ - PCur^);

    PCur := PYVals; Inc( PCur, iy ); // PCur points to YBeg
    PCur1 := PCur;  Inc( PCur1 );
    YCoef := (ASrcDP.Y - PCur^) / (PCur1^ - PCur^);
  end else // use MatrSrcRect
  begin
    cx := (MNX-1) * (ASrcDP.X - MatrSrcRect.Left) /
                    (MatrSrcRect.Right - MatrSrcRect.Left);
    ix := Round(Floor( cx ));
    if (ix < 0) or (ix >= (MNX-1)) then Exit; // ASrcDP is out of Matr
    XCoef := cx - ix;

    cy := (MNY-1) * (ASrcDP.Y - MatrSrcRect.Top) /
                    (MatrSrcRect.Bottom - MatrSrcRect.Top);
    iy := Round(Floor( cy ));
    if (iy < 0) or (iy >= (MNY-1)) then Exit; // ASrcDP is out of Matr
    YCoef := cy - iy;
  end;

  //***** Y Axis has Top-->Down direction (as Screen Coords)

  Ind := ix + iy*MNX;
  PM := PMatr; Inc( PM, Ind ); // Pointer to Top Left Matr Cell corner
  PM1 := PM; Inc( PM1, MNX );   // Pointer to Lower Left Matr Cell corner
  P1.X := PM^.X + (PM1^.X - PM^.X)*YCoef; // P1 is on Left Cell Side
  P1.Y := PM^.Y + (PM1^.Y - PM^.Y)*YCoef;

  Inc( PM, 1 ); // Pointer to Top Right Matr Cell corner
  PM1 := PM; Inc( PM1, MNX ); // Pointer to Lower Right Matr Cell corner
  P2.X := PM^.X + (PM1^.X - PM^.X)*YCoef; // P2 is on Right Cell Side
  P2.Y := PM^.Y + (PM1^.Y - PM^.Y)*YCoef;

  Result.X := P1.X + (P2.X - P1.X)*XCoef;
  Result.Y := P1.Y + (P2.Y - P1.Y)*XCoef;
end; // function TN_MatrConvObj.NLConvDP


    //*********** Global Procedures  *****************************

//*************************************************** N_CalcCatRomCoefs ***
// Calculate four Catmull-Rom Coefs in PCoefs[0..3]
//
procedure N_CalcCatRomCoefs( AT: double; PCoefs: PDOuble );
var
  t2, mtm1: double;
begin
  t2 := AT*AT;
  mtm1 := 1.0 - AT;

  PCoefs^ := -AT*mtm1*mtm1;
  Inc( PCoefs );

  PCoefs^ := 2.0 + t2*(3*AT - 5);
  Inc( PCoefs );

  PCoefs^ := AT*(1.0 + 4*AT - 3*t2);
  Inc( PCoefs );

  PCoefs^ := -t2*mtm1;

end; // procedure N_CalcCatRomCoefs

var
  WFVM: Array [0..15] of float;

//************************************************** N_GetMatrValue(Float) ***
// Get Value at (AX,AY) point (AX,AY in natural coords (0,NX-1) x (0,NY-1))
// using given AIMode - Interpolation Mode
//
// PValue   - Pointer to Float Matr[0,0] Value
// ANX, ANY - Matr dimensions

function N_GetMatrValue( PValue: PFloat; ANX, ANY: integer;
                          AIMode: TN_2DIntMode; AX, AY: double ): double;
var
  ix, iy, ind, WVMNX: integer;
  v1, v2, v3, v4, v5, v6, dx, dy: double;
  PV, PVInd, PVUL: PFloat;
  Coefs: Array [0..3] of double;
  Label AnotherMode;
begin
  Result := N_NotADouble; // to avoid warning

  if AX < 0 then AX := 0
  else if AX >= (ANX-1) then AX := (ANX-1)*N_1MDEps;

  if AY < 0 then AY := 0
  else if AY >= (ANY-1) then AY := (ANY-1)*N_1MDEps;

  v1 := Floor( AX );
  dx := AX - v1;
  ix := Round(v1);

  v1 := Floor( AY );
  dy := AY - v1;
  iy := Round(v1);

  ind := iy*ANX + ix;

  if (ix=10) and (iy=0) and (AIMode=tdimSpline1) then // debug
    N_i := 2;

  AnotherMode: //*********

  case AIMode of

  tdimConst: begin  // return value of nearest matrix node
//    Result := VM[ind];
    PV := PValue;
    Inc( PV, ind );
    Result := PV^; // VM[ind]
  end;

  tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes
//    v1 := (1-dx)*VM[ind] + dx*VM[ind+1]; // horizontal interpolation by two upper nodes
    PV := PValue;
    Inc( PV, ind );
    v1 := (1-dx)*PV^;  // PV^ = VM[ind]
    Inc( PV );
    v1 := v1 + dx*PV^; // PV^ = VM[ind+1]

//    v2 := (1-dx)*VM[ind+ANX] + dx*VM[ind+ANX+1]; // horizontal interpolation by two lower nodes
    Inc( PV, ANX );
    v2 := dx*PV^; // PV^ = VM[ind+ANX+1]
    Dec( PV );
    v2 := v2 + (1-dx)*PV^;  // PV^ = VM[ind+ANX]

    Result := (1-dy)*v1 + dy*v2; // vertical interpolation
  end; // tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes

  tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes
    if dx > dy then // upper right triangle
    begin
//      v1 := VM[ind+1]; // base value is value at upper right node
//      Result := v1 + (1.0-dx)*(VM[ind] - v1) + dy*(VM[ind+ANX+1] - v1);
      PV := PValue;
      Inc( PV, ind );
      v2 := PV^;     // PV^ = VM[ind]
      Inc( PV );
      v1 := PV^;     // PV^ = VM[ind+1]
      Inc( PV, ANX );
      v3 := PV^;     // PV^ = VM[ind+1+ANX]
      Result := v1 + (1.0-dx)*(v2 - v1) + dy*(v3 - v1);
    end else // dx <= dy, lower left triangle
    begin
//      v1 := VM[ind+NX]; // base value is value at lower left node
//      Result := v1 + dx*(VM[ind+NX+1] - v1) + (1.0-dy)*(VM[ind] - v1);
      PV := PValue;
      Inc( PV, ind );
      v3 := PV^;     // PV^ = VM[ind]
      Inc( PV, ANX );
      v1 := PV^;     // PV^ = VM[ind+ANX]
      Inc( PV );
      v2 := PV^;     // PV^ = VM[ind+1+ANX]
      Result := v1 + dx*(v2 - v1) + (1.0-dy)*(v3 - v1);
    end;
  end; // tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes

  tdimSpline1: begin // Catmull-Rom interpolation by 4x4 enveloping matrix nodes
//    PVUL := PValue;
    if (ix > 0) and (ix < (ANX-2)) and (iy > 0) and (iy < (ANY-2)) then
    begin // needed 4x4 Matr is inside
      ind := (iy-1)*ANX + ix-1;
      PVUL := PValue;
      Inc( PVUL, ind ); // pointer to Upper Left Corner of 4x4 Matr
      WVMNX := ANX;
    end else // fill and use Wrk WVM 4x4 Matr
    begin
      PVUL := @WFVM[0];
      WVMNX := 4;

      PV   := PValue;
      Inc( PV, ind );
      PVInd := PV;    // both PV and PVInd are used later, PVInd is not changed

      if ANX = 2 then // both Left and Right borders
      begin
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV, ANX-1 ); // Upper Right
        v3 := PV^; Inc( PV );        // Lower Left
        v4 := PV^;                   // Lower Right

        if ANY = 2 then // both Upper and Bottom borders, both Left and Right borders
        begin
          WFVM[0] := 3*v1 - v2 - v3;
          WFVM[1] := 2*v1 - v3;
          WFVM[2] := 2*v2 - v4;
          WFVM[3] := 3*v2 - v1 - v4;

          WFVM[4] := 2*v1 - v2;
          WFVM[5] := v1;
          WFVM[6] := v2;
          WFVM[7] := 2*v2 - v1;

          WFVM[8]  := 2*v3 - v4;
          WFVM[9]  := v3;
          WFVM[10] := v4;
          WFVM[11] := 2*v4 - v3;

          WFVM[12] := 3*v3 - v1 - v4;
          WFVM[13] := 2*v3 - v1;
          WFVM[14] := 2*v4 - v2;
          WFVM[15] := 3*v4 - v2 - v3;
        end else  if iy = 0 then // Upper border, both Left and Right borders
        begin
          WFVM[0] := 3*v1 - v2 - v3;
          WFVM[1] := 2*v1 - v3;
          WFVM[2] := 2*v2 - v4;
          WFVM[3] := 3*v2 - v1 - v4;

          WFVM[4] := 2*v1 - v2;
          WFVM[5] := v1;
          WFVM[6] := v2;
          WFVM[7] := 2*v2 - v1;

          WFVM[8]  := 2*v3 - v4;
          WFVM[9]  := v3;
          WFVM[10] := v4;
          WFVM[11] := 2*v4 - v3;

          PV := PVInd;
          Inc( PV, 2*ANX );
          v5 := PV^;  // Lower Left
          Inc( PV );
          v6 := PV^;  // Lower Right

          WFVM[12] := 2*v5 - v6;
          WFVM[13] := v5;
          WFVM[14] := v6;
          WFVM[15] := 2*v6 - v5;
        end else if iy = (ANY-2) then // Bottom border, both Left and Right borders
        begin
          PV := PVInd;
          Dec( PV, ANX );
          v5 := PV^;  // Upper Left
          Inc( PV );
          v6 := PV^;  // Upper Right

          WFVM[0] := 2*v5 - v6;
          WFVM[1] := v5;
          WFVM[2] := v6;
          WFVM[3] := 2*v6 - v5;

          WFVM[4] := 2*v1 - v2;
          WFVM[5] := v1;
          WFVM[6] := v2;
          WFVM[7] := 2*v2 - v1;

          WFVM[8]  := 2*v3 - v4;
          WFVM[9]  := v3;
          WFVM[10] := v4;
          WFVM[11] := 2*v4 - v3;

          WFVM[12] := 3*v3 - v1 - v4;
          WFVM[13] := 2*v3 - v1;
          WFVM[14] := 2*v4 - v2;
          WFVM[15] := 3*v4 - v2 - v3;
        end else // inside along Y, both Left and Right borders
        begin
          PV := PVInd;
          Dec( PV, ANX );
          v5 := PV^;  // Upper Left
          Inc( PV );
          v6 := PV^;  // Upper Right

          WFVM[0] := 2*v5 - v6;
          WFVM[1] := v5;
          WFVM[2] := v6;
          WFVM[3] := 2*v6 - v5;

          WFVM[4] := 2*v1 - v2;
          WFVM[5] := v1;
          WFVM[6] := v2;
          WFVM[7] := 2*v2 - v1;

          WFVM[8]  := 2*v3 - v4;
          WFVM[9]  := v3;
          WFVM[10] := v4;
          WFVM[11] := 2*v4 - v3;

          PV := PVInd;
          Inc( PV, 2*ANX );
          v5 := PV^;  // Lower Left
          Inc( PV );
          v6 := PV^;  // Lower Right

          WFVM[12] := 2*v5 - v6;
          WFVM[13] := v5;
          WFVM[14] := v6;
          WFVM[15] := 2*v6 - v5;
        end;

      end else if ix = 0 then // Left border
      begin
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV );        // Upper Middle
        v3 := PV^; Inc( PV, ANX-2 ); // Upper Right

        v4 := PV^; Inc( PV );        // Lower Left
        v5 := PV^; Inc( PV );        // Lower Middle
        v6 := PV^;                   // Lower Right

        WFVM[4] := 2*v1 - v2;
        WFVM[5] := v1;
        WFVM[6] := v2;
        WFVM[7] := v3;

        WFVM[8]  := 2*v4 - v5;
        WFVM[9]  := v4;
        WFVM[10] := v5;
        WFVM[11] := v6;

        if ANY = 2 then // both Upper and Bottom borders, Left border
        begin
          WFVM[0] := 3*v1 - v2 - v4;
          WFVM[1] := 2*v1 - v4;
          WFVM[2] := 2*v2 - v5;
          WFVM[3] := 2*v3 - v6;

          WFVM[12] := 3*v4 - v1 - v5;
          WFVM[13] := 2*v4 - v1;
          WFVM[14] := 2*v5 - v2;
          WFVM[15] := 2*v6 - v3;
        end else  if iy = 0 then // Upper border, Left border
        begin
          WFVM[0] := 3*v1 - v2 - v4;
          WFVM[1] := 2*v1 - v4;
          WFVM[2] := 2*v2 - v5;
          WFVM[3] := 2*v3 - v6;

          PV := PVInd;
          Inc( PV, 2*ANX );

          WFVM[13] := PV^; Inc( PV );
          WFVM[14] := PV^; Inc( PV );
          WFVM[15] := PV^;
          WFVM[12] := 2*WFVM[13] - WFVM[14];
        end else if iy = (ANY-2) then // Bottom border, Left border
        begin
          PV := PVInd;
          Dec( PV, ANX );

          WFVM[1] := PV^; Inc( PV );
          WFVM[2] := PV^; Inc( PV );
          WFVM[3] := PV^;
          WFVM[0] := 2*WFVM[1] - WFVM[2];

          WFVM[12] := 3*v4 - v1 - v5;
          WFVM[13] := 2*v4 - v1;
          WFVM[14] := 2*v5 - v2;
          WFVM[15] := 2*v6 - v3;
        end else // inside along Y, Left border
        begin
          PV := PVInd;
          Dec( PV, ANX );

          WFVM[1] := PV^; Inc( PV );
          WFVM[2] := PV^; Inc( PV );
          WFVM[3] := PV^;
          WFVM[0] := 2*WFVM[1] - WFVM[2];

          PV := PVInd;
          Inc( PV, 2*ANX );

          WFVM[13] := PV^; Inc( PV );
          WFVM[14] := PV^; Inc( PV );
          WFVM[15] := PV^;
          WFVM[12] := 2*WFVM[13] - WFVM[14];
        end;

      end else if ix = (ANX-2) then // Right border
      begin
        Dec( PV );
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV );        // Upper Middle
        v3 := PV^; Inc( PV, ANX-2 ); // Upper Right

        v4 := PV^; Inc( PV );        // Lower Left
        v5 := PV^; Inc( PV );        // Lower Middle
        v6 := PV^;                   // Lower Right

        WFVM[4] := v1;
        WFVM[5] := v2;
        WFVM[6] := v3;
        WFVM[7] := 2*v3 - v2;

        WFVM[8]  := v4;
        WFVM[9]  := v5;
        WFVM[10] := v6;
        WFVM[11] := 2*v6 - v5;


        if ANY = 2 then // both Upper and Bottom borders, Right border
        begin
          WFVM[0] := 2*v1 - v4;
          WFVM[1] := 2*v2 - v5;
          WFVM[2] := 2*v3 - v6;
          WFVM[3] := 3*v3 - v2 - v6;

          WFVM[12] := 2*v4 - v1;
          WFVM[13] := 2*v5 - v2;
          WFVM[14] := 2*v6 - v3;
          WFVM[15] := 3*v6 - v3 - v5;
        end else  if iy = 0 then // Upper border, Right border
        begin
          WFVM[0] := 2*v1 - v4;
          WFVM[1] := 2*v2 - v5;
          WFVM[2] := 2*v3 - v6;
          WFVM[3] := 3*v3 - v2 - v6;

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WFVM[12] := PV^; Inc( PV );
          WFVM[13] := PV^; Inc( PV );
          WFVM[14] := PV^;
          WFVM[15] := 2*WFVM[14] - WFVM[13];
        end else if iy = (ANY-2) then // Bottom border, Right border
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WFVM[0] := PV^; Inc( PV );
          WFVM[1] := PV^; Inc( PV );
          WFVM[2] := PV^;
          WFVM[3] := 2*WFVM[2] - WFVM[1];

          WFVM[12] := 2*v4 - v1;
          WFVM[13] := 2*v5 - v2;
          WFVM[14] := 2*v6 - v3;
          WFVM[15] := 3*v6 - v3 - v5;
        end else // inside along Y, Right border
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WFVM[0] := PV^; Inc( PV );
          WFVM[1] := PV^; Inc( PV );
          WFVM[2] := PV^;
          WFVM[3] := 2*WFVM[2] - WFVM[1];

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WFVM[12] := PV^; Inc( PV );
          WFVM[13] := PV^; Inc( PV );
          WFVM[14] := PV^;
          WFVM[15] := 2*WFVM[14] - WFVM[13];
        end;

      end else // inside along X
      begin
        PV := PVInd;
        Dec( PV );

        WFVM[4] := PV^; Inc( PV );
        WFVM[5] := PV^; Inc( PV );
        WFVM[6] := PV^; Inc( PV );
        WFVM[7] := PV^; Inc( PV, ANX-3 );

        WFVM[8]  := PV^; Inc( PV );
        WFVM[9]  := PV^; Inc( PV );
        WFVM[10] := PV^; Inc( PV );
        WFVM[11] := PV^;

        if ANY = 2 then // both Upper and Bottom borders, inside along X
        begin
          WFVM[0] := 2*WFVM[4] - WFVM[8];
          WFVM[1] := 2*WFVM[5] - WFVM[9];
          WFVM[2] := 2*WFVM[6] - WFVM[10];
          WFVM[3] := 2*WFVM[7] - WFVM[11];

          WFVM[12] := 2*WFVM[8]  - WFVM[4];
          WFVM[13] := 2*WFVM[9]  - WFVM[5];
          WFVM[14] := 2*WFVM[10] - WFVM[6];
          WFVM[15] := 2*WFVM[11] - WFVM[7];
        end else  if iy = 0 then // Upper border, inside along X
        begin
          WFVM[0] := 2*WFVM[4] - WFVM[8];
          WFVM[1] := 2*WFVM[5] - WFVM[9];
          WFVM[2] := 2*WFVM[6] - WFVM[10];
          WFVM[3] := 2*WFVM[7] - WFVM[11];

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WFVM[12] := PV^; Inc( PV );
          WFVM[13] := PV^; Inc( PV );
          WFVM[14] := PV^; Inc( PV );
          WFVM[15] := PV^;
        end else if iy = (ANY-2) then // Bottom border, inside along X
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WFVM[0] := PV^; Inc( PV );
          WFVM[1] := PV^; Inc( PV );
          WFVM[2] := PV^; Inc( PV );
          WFVM[3] := PV^;

          WFVM[12] := 2*WFVM[8]  - WFVM[4];
          WFVM[13] := 2*WFVM[9]  - WFVM[5];
          WFVM[14] := 2*WFVM[10] - WFVM[6];
          WFVM[15] := 2*WFVM[11] - WFVM[7];
        end;

        // inside along Y, inside along X case was already processed

      end; // else // inside along X

    end; // end else // fill and use Wrk WVM 4x4 Matr

    // PVUL points to proper 4x4 Matr, it's NX size is WVMNX (4 or ANX)
    // Calc v1 - v4 four points for vertical Interpolation

    N_CalcCatRomCoefs( dx, @Coefs[0] ); // Horizontal Coefs

    PV := PVUL;

    v1 := Coefs[0]*PV^; Inc( PV );
    v1 := v1 + Coefs[1]*PV^; Inc( PV );
    v1 := v1 + Coefs[2]*PV^; Inc( PV );
    v1 := v1 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v1 := 0.5*v1;

    v2 := Coefs[0]*PV^; Inc( PV );
    v2 := v2 + Coefs[1]*PV^; Inc( PV );
    v2 := v2 + Coefs[2]*PV^; Inc( PV );
    v2 := v2 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v2 := 0.5*v2;

    v3 := Coefs[0]*PV^; Inc( PV );
    v3 := v3 + Coefs[1]*PV^; Inc( PV );
    v3 := v3 + Coefs[2]*PV^; Inc( PV );
    v3 := v3 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v3 := 0.5*v3;

    v4 := Coefs[0]*PV^; Inc( PV );
    v4 := v4 + Coefs[1]*PV^; Inc( PV );
    v4 := v4 + Coefs[2]*PV^; Inc( PV );
    v4 := v4 + Coefs[3]*PV^;
    v4 := 0.5*v4;

    N_CalcCatRomCoefs( dy, @Coefs[0] ); // Vertical Coefs

    Result := 0.5*( Coefs[0]*v1 + Coefs[1]*v2 + Coefs[2]*v3 + Coefs[3]*v4 );
  end; // tdimSplain1: begin // Catmull-Rom interpolation by 4x4 enveloping matrix nodes

  end; // case AIMode of
end; // function N_GetMatrValue(Float)

var
  WDVM: Array [0..15] of double;

//************************************************* N_GetMatrValue(Double) ***
// Get Value at (AX,AY) point (AX,AY in natural coords (0,NX-1) x (0,NY-1))
// using given AIMode - Interpolation Mode
//
// PValue   - Pointer to Double Matr[0,0] Value
// ANX, ANY - Matr dimensions

function N_GetMatrValue( PValue: PDouble; ANX, ANY: integer;
                          AIMode: TN_2DIntMode; AX, AY: double ): double;
var
  ix, iy, ind, WVMNX: integer;
  v1, v2, v3, v4, v5, v6, dx, dy: double;
  PV, PVInd, PVUL: PDouble;
  Coefs: Array [0..3] of double;
  Label AnotherMode;
begin
  Result := N_NotADouble; // to avoid warning

  if AX < 0 then AX := 0
  else if AX >= (ANX-1) then AX := (ANX-1)*N_1MDEps;

  if AY < 0 then AY := 0
  else if AY >= (ANY-1) then AY := (ANY-1)*N_1MDEps;

  v1 := Floor( AX );
  dx := AX - v1;
  ix := Round(v1);

  v1 := Floor( AY );
  dy := AY - v1;
  iy := Round(v1);

  ind := iy*ANX + ix;

  if (ix=10) and (iy=0) and (AIMode=tdimSpline1) then // debug
    N_i := 2;

  AnotherMode: //*********

  case AIMode of

  tdimConst: begin  // return value of nearest matrix node
//    Result := VM[ind];
    PV := PValue;
    Inc( PV, ind );
    Result := PV^; // VM[ind]
  end;

  tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes
//    v1 := (1-dx)*VM[ind] + dx*VM[ind+1]; // horizontal interpolation by two upper nodes
    PV := PValue;
    Inc( PV, ind );
    v1 := (1-dx)*PV^;  // PV^ = VM[ind]
    Inc( PV );
    v1 := v1 + dx*PV^; // PV^ = VM[ind+1]

//    v2 := (1-dx)*VM[ind+ANX] + dx*VM[ind+ANX+1]; // horizontal interpolation by two lower nodes
    Inc( PV, ANX );
    v2 := dx*PV^; // PV^ = VM[ind+ANX+1]
    Dec( PV );
    v2 := v2 + (1-dx)*PV^;  // PV^ = VM[ind+ANX]

    Result := (1-dy)*v1 + dy*v2; // vertical interpolation
  end; // tdimBiLineal: begin // BiLineal interpolation by four enveloping matrix nodes

  tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes
    if dx > dy then // upper right triangle
    begin
//      v1 := VM[ind+1]; // base value is value at upper right node
//      Result := v1 + (1.0-dx)*(VM[ind] - v1) + dy*(VM[ind+ANX+1] - v1);
      PV := PValue;
      Inc( PV, ind );
      v2 := PV^;     // PV^ = VM[ind]
      Inc( PV );
      v1 := PV^;     // PV^ = VM[ind+1]
      Inc( PV, ANX );
      v3 := PV^;     // PV^ = VM[ind+1+ANX]
      Result := v1 + (1.0-dx)*(v2 - v1) + dy*(v3 - v1);
    end else // dx <= dy, lower left triangle
    begin
//      v1 := VM[ind+NX]; // base value is value at lower left node
//      Result := v1 + dx*(VM[ind+NX+1] - v1) + (1.0-dy)*(VM[ind] - v1);
      PV := PValue;
      Inc( PV, ind );
      v3 := PV^;     // PV^ = VM[ind]
      Inc( PV, ANX );
      v1 := PV^;     // PV^ = VM[ind+ANX]
      Inc( PV );
      v2 := PV^;     // PV^ = VM[ind+1+ANX]
      Result := v1 + dx*(v2 - v1) + (1.0-dy)*(v3 - v1);
    end;
  end; // tdimTriLineal: begin // TriLineal interpolation by three enveloping matrix nodes

  tdimSpline1: begin // Catmull-Rom interpolation by 4x4 enveloping matrix nodes
//    PVUL := PValue;
    if (ix > 0) and (ix < (ANX-2)) and (iy > 0) and (iy < (ANY-2)) then
    begin // needed 4x4 Matr is inside
      ind := (iy-1)*ANX + ix-1;
      PVUL := PValue;
      Inc( PVUL, ind ); // pointer to Upper Left Corner of 4x4 Matr
      WVMNX := ANX;
    end else // fill and use Wrk WVM 4x4 Matr
    begin
      PVUL := @WDVM[0];
      WVMNX := 4;

      PV   := PValue;
      Inc( PV, ind );
      PVInd := PV;    // both PV and PVInd are used later, PVInd is not changed

      if ANX = 2 then // both Left and Right borders
      begin
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV, ANX-1 ); // Upper Right
        v3 := PV^; Inc( PV );        // Lower Left
        v4 := PV^;                   // Lower Right

        if ANY = 2 then // both Upper and Bottom borders, both Left and Right borders
        begin
          WDVM[0] := 3*v1 - v2 - v3;
          WDVM[1] := 2*v1 - v3;
          WDVM[2] := 2*v2 - v4;
          WDVM[3] := 3*v2 - v1 - v4;

          WDVM[4] := 2*v1 - v2;
          WDVM[5] := v1;
          WDVM[6] := v2;
          WDVM[7] := 2*v2 - v1;

          WDVM[8]  := 2*v3 - v4;
          WDVM[9]  := v3;
          WDVM[10] := v4;
          WDVM[11] := 2*v4 - v3;

          WDVM[12] := 3*v3 - v1 - v4;
          WDVM[13] := 2*v3 - v1;
          WDVM[14] := 2*v4 - v2;
          WDVM[15] := 3*v4 - v2 - v3;
        end else  if iy = 0 then // Upper border, both Left and Right borders
        begin
          WDVM[0] := 3*v1 - v2 - v3;
          WDVM[1] := 2*v1 - v3;
          WDVM[2] := 2*v2 - v4;
          WDVM[3] := 3*v2 - v1 - v4;

          WDVM[4] := 2*v1 - v2;
          WDVM[5] := v1;
          WDVM[6] := v2;
          WDVM[7] := 2*v2 - v1;

          WDVM[8]  := 2*v3 - v4;
          WDVM[9]  := v3;
          WDVM[10] := v4;
          WDVM[11] := 2*v4 - v3;

          PV := PVInd;
          Inc( PV, 2*ANX );
          v5 := PV^;  // Lower Left
          Inc( PV );
          v6 := PV^;  // Lower Right

          WDVM[12] := 2*v5 - v6;
          WDVM[13] := v5;
          WDVM[14] := v6;
          WDVM[15] := 2*v6 - v5;
        end else if iy = (ANY-2) then // Bottom border, both Left and Right borders
        begin
          PV := PVInd;
          Dec( PV, ANX );
          v5 := PV^;  // Upper Left
          Inc( PV );
          v6 := PV^;  // Upper Right

          WDVM[0] := 2*v5 - v6;
          WDVM[1] := v5;
          WDVM[2] := v6;
          WDVM[3] := 2*v6 - v5;

          WDVM[4] := 2*v1 - v2;
          WDVM[5] := v1;
          WDVM[6] := v2;
          WDVM[7] := 2*v2 - v1;

          WDVM[8]  := 2*v3 - v4;
          WDVM[9]  := v3;
          WDVM[10] := v4;
          WDVM[11] := 2*v4 - v3;

          WDVM[12] := 3*v3 - v1 - v4;
          WDVM[13] := 2*v3 - v1;
          WDVM[14] := 2*v4 - v2;
          WDVM[15] := 3*v4 - v2 - v3;
        end else // inside along Y, both Left and Right borders
        begin
          PV := PVInd;
          Dec( PV, ANX );
          v5 := PV^;  // Upper Left
          Inc( PV );
          v6 := PV^;  // Upper Right

          WDVM[0] := 2*v5 - v6;
          WDVM[1] := v5;
          WDVM[2] := v6;
          WDVM[3] := 2*v6 - v5;

          WDVM[4] := 2*v1 - v2;
          WDVM[5] := v1;
          WDVM[6] := v2;
          WDVM[7] := 2*v2 - v1;

          WDVM[8]  := 2*v3 - v4;
          WDVM[9]  := v3;
          WDVM[10] := v4;
          WDVM[11] := 2*v4 - v3;

          PV := PVInd;
          Inc( PV, 2*ANX );
          v5 := PV^;  // Lower Left
          Inc( PV );
          v6 := PV^;  // Lower Right

          WDVM[12] := 2*v5 - v6;
          WDVM[13] := v5;
          WDVM[14] := v6;
          WDVM[15] := 2*v6 - v5;
        end;

      end else if ix = 0 then // Left border
      begin
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV );        // Upper Middle
        v3 := PV^; Inc( PV, ANX-2 ); // Upper Right

        v4 := PV^; Inc( PV );        // Lower Left
        v5 := PV^; Inc( PV );        // Lower Middle
        v6 := PV^;                   // Lower Right

        WDVM[4] := 2*v1 - v2;
        WDVM[5] := v1;
        WDVM[6] := v2;
        WDVM[7] := v3;

        WDVM[8]  := 2*v4 - v5;
        WDVM[9]  := v4;
        WDVM[10] := v5;
        WDVM[11] := v6;

        if ANY = 2 then // both Upper and Bottom borders, Left border
        begin
          WDVM[0] := 3*v1 - v2 - v4;
          WDVM[1] := 2*v1 - v4;
          WDVM[2] := 2*v2 - v5;
          WDVM[3] := 2*v3 - v6;

          WDVM[12] := 3*v4 - v1 - v5;
          WDVM[13] := 2*v4 - v1;
          WDVM[14] := 2*v5 - v2;
          WDVM[15] := 2*v6 - v3;
        end else  if iy = 0 then // Upper border, Left border
        begin
          WDVM[0] := 3*v1 - v2 - v4;
          WDVM[1] := 2*v1 - v4;
          WDVM[2] := 2*v2 - v5;
          WDVM[3] := 2*v3 - v6;

          PV := PVInd;
          Inc( PV, 2*ANX );

          WDVM[13] := PV^; Inc( PV );
          WDVM[14] := PV^; Inc( PV );
          WDVM[15] := PV^;
          WDVM[12] := 2*WDVM[13] - WDVM[14];
        end else if iy = (ANY-2) then // Bottom border, Left border
        begin
          PV := PVInd;
          Dec( PV, ANX );

          WDVM[1] := PV^; Inc( PV );
          WDVM[2] := PV^; Inc( PV );
          WDVM[3] := PV^;
          WDVM[0] := 2*WDVM[1] - WDVM[2];

          WDVM[12] := 3*v4 - v1 - v5;
          WDVM[13] := 2*v4 - v1;
          WDVM[14] := 2*v5 - v2;
          WDVM[15] := 2*v6 - v3;
        end else // inside along Y, Left border
        begin
          PV := PVInd;
          Dec( PV, ANX );

          WDVM[1] := PV^; Inc( PV );
          WDVM[2] := PV^; Inc( PV );
          WDVM[3] := PV^;
          WDVM[0] := 2*WDVM[1] - WDVM[2];

          PV := PVInd;
          Inc( PV, 2*ANX );

          WDVM[13] := PV^; Inc( PV );
          WDVM[14] := PV^; Inc( PV );
          WDVM[15] := PV^;
          WDVM[12] := 2*WDVM[13] - WDVM[14];
        end;

      end else if ix = (ANX-2) then // Right border
      begin
        Dec( PV );
        v1 := PV^; Inc( PV );        // Upper Left
        v2 := PV^; Inc( PV );        // Upper Middle
        v3 := PV^; Inc( PV, ANX-2 ); // Upper Right

        v4 := PV^; Inc( PV );        // Lower Left
        v5 := PV^; Inc( PV );        // Lower Middle
        v6 := PV^;                   // Lower Right

        WDVM[4] := v1;
        WDVM[5] := v2;
        WDVM[6] := v3;
        WDVM[7] := 2*v3 - v2;

        WDVM[8]  := v4;
        WDVM[9]  := v5;
        WDVM[10] := v6;
        WDVM[11] := 2*v6 - v5;


        if ANY = 2 then // both Upper and Bottom borders, Right border
        begin
          WDVM[0] := 2*v1 - v4;
          WDVM[1] := 2*v2 - v5;
          WDVM[2] := 2*v3 - v6;
          WDVM[3] := 3*v3 - v2 - v6;

          WDVM[12] := 2*v4 - v1;
          WDVM[13] := 2*v5 - v2;
          WDVM[14] := 2*v6 - v3;
          WDVM[15] := 3*v6 - v3 - v5;
        end else  if iy = 0 then // Upper border, Right border
        begin
          WDVM[0] := 2*v1 - v4;
          WDVM[1] := 2*v2 - v5;
          WDVM[2] := 2*v3 - v6;
          WDVM[3] := 3*v3 - v2 - v6;

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WDVM[12] := PV^; Inc( PV );
          WDVM[13] := PV^; Inc( PV );
          WDVM[14] := PV^;
          WDVM[15] := 2*WDVM[14] - WDVM[13];
        end else if iy = (ANY-2) then // Bottom border, Right border
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WDVM[0] := PV^; Inc( PV );
          WDVM[1] := PV^; Inc( PV );
          WDVM[2] := PV^;
          WDVM[3] := 2*WDVM[2] - WDVM[1];

          WDVM[12] := 2*v4 - v1;
          WDVM[13] := 2*v5 - v2;
          WDVM[14] := 2*v6 - v3;
          WDVM[15] := 3*v6 - v3 - v5;
        end else // inside along Y, Right border
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WDVM[0] := PV^; Inc( PV );
          WDVM[1] := PV^; Inc( PV );
          WDVM[2] := PV^;
          WDVM[3] := 2*WDVM[2] - WDVM[1];

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WDVM[12] := PV^; Inc( PV );
          WDVM[13] := PV^; Inc( PV );
          WDVM[14] := PV^;
          WDVM[15] := 2*WDVM[14] - WDVM[13];
        end;

      end else // inside along X
      begin
        PV := PVInd;
        Dec( PV );

        WDVM[4] := PV^; Inc( PV );
        WDVM[5] := PV^; Inc( PV );
        WDVM[6] := PV^; Inc( PV );
        WDVM[7] := PV^; Inc( PV, ANX-3 );

        WDVM[8]  := PV^; Inc( PV );
        WDVM[9]  := PV^; Inc( PV );
        WDVM[10] := PV^; Inc( PV );
        WDVM[11] := PV^;

        if ANY = 2 then // both Upper and Bottom borders, inside along X
        begin
          WDVM[0] := 2*WDVM[4] - WDVM[8];
          WDVM[1] := 2*WDVM[5] - WDVM[9];
          WDVM[2] := 2*WDVM[6] - WDVM[10];
          WDVM[3] := 2*WDVM[7] - WDVM[11];

          WDVM[12] := 2*WDVM[8]  - WDVM[4];
          WDVM[13] := 2*WDVM[9]  - WDVM[5];
          WDVM[14] := 2*WDVM[10] - WDVM[6];
          WDVM[15] := 2*WDVM[11] - WDVM[7];
        end else  if iy = 0 then // Upper border, inside along X
        begin
          WDVM[0] := 2*WDVM[4] - WDVM[8];
          WDVM[1] := 2*WDVM[5] - WDVM[9];
          WDVM[2] := 2*WDVM[6] - WDVM[10];
          WDVM[3] := 2*WDVM[7] - WDVM[11];

          PV := PVInd;
          Inc( PV, 2*ANX-1 );

          WDVM[12] := PV^; Inc( PV );
          WDVM[13] := PV^; Inc( PV );
          WDVM[14] := PV^; Inc( PV );
          WDVM[15] := PV^;
        end else if iy = (ANY-2) then // Bottom border, inside along X
        begin
          PV := PVInd;
          Dec( PV, ANX+1 );

          WDVM[0] := PV^; Inc( PV );
          WDVM[1] := PV^; Inc( PV );
          WDVM[2] := PV^; Inc( PV );
          WDVM[3] := PV^;

          WDVM[12] := 2*WDVM[8]  - WDVM[4];
          WDVM[13] := 2*WDVM[9]  - WDVM[5];
          WDVM[14] := 2*WDVM[10] - WDVM[6];
          WDVM[15] := 2*WDVM[11] - WDVM[7];
        end;

        // inside along Y, inside along X case was already processed

      end; // else // inside along X

    end; // end else // fill and use Wrk WVM 4x4 Matr

    // PVUL points to proper 4x4 Matr, it's NX size is WVMNX (4 or ANX)
    // Calc v1 - v4 four points for vertical Interpolation

    N_CalcCatRomCoefs( dx, @Coefs[0] ); // Horizontal Coefs

    PV := PVUL;

    v1 := Coefs[0]*PV^; Inc( PV );
    v1 := v1 + Coefs[1]*PV^; Inc( PV );
    v1 := v1 + Coefs[2]*PV^; Inc( PV );
    v1 := v1 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v1 := 0.5*v1;

    v2 := Coefs[0]*PV^; Inc( PV );
    v2 := v2 + Coefs[1]*PV^; Inc( PV );
    v2 := v2 + Coefs[2]*PV^; Inc( PV );
    v2 := v2 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v2 := 0.5*v2;

    v3 := Coefs[0]*PV^; Inc( PV );
    v3 := v3 + Coefs[1]*PV^; Inc( PV );
    v3 := v3 + Coefs[2]*PV^; Inc( PV );
    v3 := v3 + Coefs[3]*PV^; Inc( PV, WVMNX - 3 );
    v3 := 0.5*v3;

    v4 := Coefs[0]*PV^; Inc( PV );
    v4 := v4 + Coefs[1]*PV^; Inc( PV );
    v4 := v4 + Coefs[2]*PV^; Inc( PV );
    v4 := v4 + Coefs[3]*PV^;
    v4 := 0.5*v4;

    N_CalcCatRomCoefs( dy, @Coefs[0] ); // Vertical Coefs

    Result := 0.5*( Coefs[0]*v1 + Coefs[1]*v2 + Coefs[2]*v3 + Coefs[3]*v4 );
  end; // tdimSplain1: begin // Catmull-Rom interpolation by 4x4 enveloping matrix nodes

  end; // case AIMode of
end; // function N_GetMatrValue(Double)

//****************************************************** N_SplineLine ***
// Convert given ASrcDC Polyline to resulting "Splined" Polyline AResDC
// using Pointer given Params APParams
// ( number of points in AResDC is Length(AResDC) )
//
procedure N_SplineLine( APParams: TN_PSplineLineParams; ASrcDC: TN_DPArray;
                                                    var AResDC: TN_DPArray );
var
  i, j, iMax, ResInd: integer;
  SCoefs: array [0..3] of double;
  CurPoints: array [0..3] of TDPoint;
begin
  iMax := Length(ASrcDC) - 2;
  if iMax = -2 then // empty Src line
  begin
    SetLength( AResDC, 0 );
    Exit; // all done
  end else if iMax = -1 then // one point Src line
  begin
    SetLength( AResDC, 1 );
    AResDC[0] := ASrcDC[0];
    Exit; // all done
  end; // if iMax = -1 then // one point Src line

  with APParams^ do
  begin

  AResDC := nil;

  if SLPType = sltDoNotSpline then
  begin
    AResDC := Copy( ASrcDC, 0, Length(ASrcDC) );
    Exit;
  end;

  //***** Here: Catmull-Rom Spline 

  SetLength( AResDC, (iMax+1)*(SLPNumNewInSegm+1) + 1 );
  ResInd := 0;

  for i := 0 to iMax do // along Src Line Segments
  begin

    if N_Same( ASrcDC[0], ASrcDC[imax+1] ) then // closed line
    begin
      if (i = 0) and (i=iMax) then // one segment Src Line
      begin
        CurPoints[0] := ASrcDC[0];
        CurPoints[1] := ASrcDC[0];
        CurPoints[2] := ASrcDC[1];
        CurPoints[3] := ASrcDC[1];
      end else if (i = 0) then // first Src Line segment
      begin
        CurPoints[0] := ASrcDC[iMax];
        move( ASrcDC[0], CurPoints[1], 3*SizeOf(ASrcDC[0]) );
      end else if (i=iMax) then // last Src Line segment
      begin
        move( ASrcDC[iMax-1], CurPoints[0], 3*SizeOf(ASrcDC[0]) );
        CurPoints[3] := ASrcDC[1];
      end else // internal Src Line segment
        move( ASrcDC[i-1], CurPoints[0], 4*SizeOf(ASrcDC[0]) );
    end else //********************************* not closed line
    begin
      if (i = 0) and (i=iMax) then // one segment Src Line
      begin
        CurPoints[0] := ASrcDC[0];
        CurPoints[1] := ASrcDC[0];
        CurPoints[2] := ASrcDC[1];
        CurPoints[3] := ASrcDC[1];
      end else if (i = 0) then // first Src Line segment
      begin
        CurPoints[0] := ASrcDC[0];
        move( ASrcDC[0], CurPoints[1], 3*SizeOf(ASrcDC[0]) );
      end else if (i=iMax) then // last Src Line segment
      begin
        move( ASrcDC[iMax-1], CurPoints[0], 3*SizeOf(ASrcDC[0]) );
        CurPoints[3] := ASrcDC[iMax+1];
      end else // internal Src Line segment
        move( ASrcDC[i-1], CurPoints[0], 4*SizeOf(ASrcDC[0]) );
    end;

    AResDC[ResInd] := ASrcDC[i]; Inc( ResInd );

    if i = 1 then
      N_i := 1;

    for j := 1 to SLPNumNewInSegm do // along all new points
    begin
      N_CalcCatRomCoefs( j/(SLPNumNewInSegm+1.0), @SCoefs[0] );
      AResDC[ResInd].X := 0.5*( SCoefs[0]*CurPoints[0].X + SCoefs[1]*CurPoints[1].X +
                                SCoefs[2]*CurPoints[2].X + SCoefs[3]*CurPoints[3].X );
      AResDC[ResInd].Y := 0.5*( SCoefs[0]*CurPoints[0].Y + SCoefs[1]*CurPoints[1].Y +
                                SCoefs[2]*CurPoints[2].Y + SCoefs[3]*CurPoints[3].Y );
      Inc( ResInd );
    end; // for j := 0 to SLPNPInSrcSegm-1 do // along all new points

    AResDC[ResInd] := ASrcDC[iMax+1]; // Last Point

  end; // for i := 0 to Length(ASrcDC)-2 do // along Src Line Segments

  end; // with APParams^ do
end; // procedure N_SplineLine


//****************************************************** N_Inverse1 ***
// Вычисление масива аргументов для заданных значений функции
//
// APFunc   - указатель на первое значение исходной функции
// ANumSrc  - количество значений  исходной функции
// ANumRes  - количество требуемых значений аргумента
// AArgBeg, AArgStep   - начальное значение и шаг аргумента исходной функции
// AFuncBeg, AFuncStep - начальное значение и шаг значений функцииЮ для которых
//                       нужно вычислить соответствующие значения аргумента
// APResArgs - указатель на первый элемент выделенного места для результирующих
//             значений аргумента
//
function  N_Inverse1( APFunc: PDouble; ANumSrc, ANumRes: integer;
                      AArgBeg, AArgStep, AFuncBeg, AFuncStep: double;
                                                          APResArgs: PDouble ) : Integer;
var
  SrcInd, ResInd: integer;
  SrcF1, SrcF2, CurFunc: double;
begin
  SrcInd := 0;
  ResInd := 0;
  CurFunc := AFuncBeg;
  SrcF1 := APFunc^; Inc(APFunc);
  SrcF2 := APFunc^; Inc(APFunc);

  while True do
  begin
    if ResInd = ANumRes then Break; // all done

    if SrcInd = (ANumSrc-1) then // out of range
    begin
//      APResArgs^ := N_NotADouble; Inc(APResArgs); Inc(ResInd);
//      Continue;
      Result := ResInd;
      Exit;
    end;

    if ((SrcF1 <= CurFunc) and (CurFunc <= SrcF2)) or
       ((SrcF1 >= CurFunc) and (CurFunc >= SrcF2)) then // Src segment found
    begin
      APResArgs^ := AArgBeg + SrcInd*AArgStep +
                    AArgStep*(CurFunc - SrcF1)/(SrcF2 - SrcF1);

      Inc(APResArgs); Inc(ResInd);
      CurFunc := CurFunc + AFuncStep;
      Continue;
    end; // if (SrcF1 <= CurFunc) and (SrcF2 >= CurFunc) then // Src segment found

    //***** To Check next Src segment

    SrcF1 := SrcF2;
    SrcF2 := APFunc^; Inc(APFunc);
    Inc(SrcInd);

  end; // while True do
  Result := ResInd;
end; // procedure N_Inverse1

//******************************************************** N_GetBezierPoint ***
// Calculate double coords of one point of one segment Bezier curve
//
// APDPoints - pointer to four DPoints (BegPoint, two Control Points and EndPoint)
// Alfa      - needed Point place in a segment in (0,1) =0 - BegPoint, =1 - EndPoint
//
function N_GetBezierPoint( APDPoints: PDPoint; Alfa: double ): TDPoint;
var
  Beta: double;
  P1, P2, P4, P5, P6: TDPoint;
  Ptr1, Ptr2: PDPoint;

  function LinInt( APDP1, APDP2: PDPoint ): TDPoint; // local
  // Linear interpolation between two given points with A;lfa Coef.
  // (Alfa=0 means APDP1^, Alfa=1 means APDP2^)
  begin
    Result.X := APDP2^.X*Alfa + APDP1^.X*Beta;
    Result.Y := APDP2^.Y*Alfa + APDP1^.Y*Beta;
  end; // function LinInt - local

begin //**************************************** body of N_GetBezierPoint
  Beta := 1.0 - Alfa;

  Ptr1 := APDPoints;
  Ptr2 := Ptr1; Inc( Ptr2 );

  P1 := LinInt( Ptr1, Ptr2 ); Inc( Ptr1, 2 ); // on (PB,C1) segment
  P4 := LinInt( Ptr2, Ptr1 ); Inc( Ptr2, 2 ); // on (C1,C2) segment
  P6 := LinInt( Ptr1, Ptr2 );                 // on (C2,PE) segment

  P2 := LinInt( @P1, @P4 );
  P5 := LinInt( @P4, @P6 );
  Result := LinInt( @P2, @P5 );
end; // function N_GetBezierPoint

//********************************************************* N_1DNLConvPower ***
// One Dimensional NonLinear Convertion with one param - Power
//
// PCoefs - Pointer to Convertion Coefs:
//   [0] - ArgMin     - Min Argument value (ArgMin < ArgMax)
//   [1] - ArgMax     - Max Argument value (ArgMin < ArgMax)
//   [2] - FuncArgMin - Func(ArgMin)
//   [3] - FuncArgMax - Func(ArgMax)
//   [4] - ConvNum:   - Convertion number (0 or 1)
//   [5] - PowerCoef  - Power Coef (>0)
//
function N_1DNLConvPower( const AArg: double; PCoefs: PDouble ): double;
var
  IntConvNum: integer;
  PowerCoef, Scale: Double;
  PArgMin, PArgMax, PFAMin, PFAMax: PDouble;
begin
  PArgMin := PCoefs; Inc(PCoefs);
  PArgMax := PCoefs; Inc(PCoefs);
  PFAMin  := PCoefs; Inc(PCoefs);
  PFAMax  := PCoefs; Inc(PCoefs);
  IntConvNum := Round(PCoefs^); Inc(PCoefs);
  PowerCoef := PCoefs^;

  Scale := (PFAMax^-PFAMin^) / (PArgMax^-PArgMin^);

  if AArg <= PArgMin^ then // less than ArgMin
  begin
    if IntConvNum = 0 then // same value as at PArgMin^
      Result := PFAMin^
    else // Liner convertion
      Result := min( PFAMin^, PFAMax^ ) - (AArg - PArgMin^)*Scale;

    Exit;
  end; // if AArg <= PArgMin^ then // less than ArgMin

  if AArg >= PArgMax^ then // greater than ArgMax
  begin
    if IntConvNum = 0 then // same value as at PArgMax^
      Result := PFAMax^
    else // Liner convertion
      Result := max( PFAMin^, PFAMax^ ) + (AArg - PArgMax^)*Scale;

    Exit;
 end; // if AArg >= PArgMax^ then // greater than ArgMax

  if PowerCoef <= 0 then PowerCoef := 1.0; // a precaution

  Result := PFAMin^ + (PFAMax^ - PFAMin^) * Power(
                             (AArg-PArgMin^)/(PArgMax^-PArgMin^), PowerCoef );

end; // function N_1DNLConvPower

//********************************************************* N_XYNLConvPower ***
// Y coord NonLinear Convertion with one X param - Power and two sets of Y Params
//
// PXCoefs - Pointer to X Convertion Coefs:
//   [0] - XMin  (XMin < XMax)
//   [1] - XMax
//   [2] - XPowerCoef
//
// AYFunc     - Y Coord Convertion Function
// ANumYCoefs - Number of YCoefs (in PYCoefsMin and PYCoefsMax, needed by AYFunc)
// PYCoefsMin - Y Coord Convertion Params for XMin
// PYCoefsMax - Y Coord Convertion Params for XMax
//
function N_XYNLConvPower( const AArg: TDPoint; PXCoefs: PDouble; AYFunc: TN_FuncDPD;
                     ANumYCoefs: integer; PYCoefsMin, PYCoefsMax: PDouble ): TDPoint;
var
  i: integer;
  XAlfa, XBeta: double;
  XCoefs, YCoefs: TN_DArray;
  PXMin, PXMax: PDouble;
begin
  PXMin := PXCoefs; Inc(PXCoefs);
  PXMax := PXCoefs; Inc(PXCoefs);

  XCoefs := N_CrDA( [PXMin^, PXMax^, 0, 1, 0, PXCoefs^] );
//  XAlfa := N_1DNLConvPower( (AArg.X - PXMin^)/(PXMax^ - PXMin^), @XCoefs[0] );
  XAlfa := N_1DNLConvPower( AArg.X, @XCoefs[0] );
  XBeta := 1.0 - XAlfa;

  SetLength( YCoefs, ANumYCoefs );

  for i := 0 to ANumYCoefs-1 do // Calc YCoefs Array for AArg.X argument
  begin
    YCoefs[i] := PYCoefsMin^*XBeta + PYCoefsMax^*XAlfa;
    Inc(PYCoefsMin);
    Inc(PYCoefsMax);
  end; // for i := 0 to ANumYCoefs-1 do // Calc YCoefs Array for AArg.X argument

  Result.X := AArg.X;
  Result.Y := AYFunc( AArg.Y, @YCoefs[0] );
end; // function N_XYNLConvPower

//********************************************************* N_FuncConv20D1 ***
// Convert one double point by 20 doubles (#1) (PParams points to them):
//   [0] - always = 20 for checking errors
//   [1] - 0 - Y coords conv., 1 - XCoords conv. (X and Y are swaped)
//   [2] - reserved
//           3-5  - PXCoefs - Pointer to X Convertion Coefs:
//   [3] - XMin  (XMin < XMax)
//   [4] - XMax
//   [5] - XPowerCoef
//          [6] - reserved
//          7-12   - YCoefs for XMin
//   [7] - ArgMin     - Min Argument value (ArgMin < ArgMax)
//   [8] - ArgMax     - Max Argument value (ArgMin < ArgMax)
//   [9] - FuncArgMin - Func(ArgMin)
//  [10] - FuncArgMax - Func(ArgMax)
//  [11] - ConvNum:   - Convertion number (0 or 1)
//  [12] - PowerCoef  - Power Coef (>0)
//          13-18  - YCoefs for XMax
//  ....
//  [19] - always = 20 for checking errors
//
function N_FuncConv20D1( const ASrcDP: TDPoint; PParams: Pointer ): TDPoint;
var
  PD, PXCoefs, PYCoefsXMin, PYCoefsXMax: PDouble;
  SwapXY: boolean;
  ArgDPoint, ResDPoint: TDPoint;
begin
  PD := PDouble(PParams);
  Assert( PD^ = 20, 'Bad[0]Conv20!' );
  Inc( PD, 1 );
  SwapXY := PD^ = 1; Inc( PD, 2 );
  PXCoefs := PD;     Inc( PD, 4 );
  PYCoefsXMin := PD; Inc( PD, 6 );
  PYCoefsXMax := PD; Inc( PD, 6 );
  Assert( PD^ = 20, 'Bad[19]Conv20!' );

  if SwapXY then
  begin
    ArgDPoint.X := ASrcDP.Y;
    ArgDPoint.Y := ASrcDP.X;
    ResDPoint := N_XYNLConvPower( ArgDPoint, PXCoefs, N_1DNLConvPower, 6,
                                                     PYCoefsXMin, PYCoefsXMax );
    Result.X := ResDPoint.Y;
    Result.Y := ResDPoint.X;
  end else
    Result := N_XYNLConvPower( ASrcDP, PXCoefs, N_1DNLConvPower, 6,
                                                     PYCoefsXMin, PYCoefsXMax );
end; // function N_FuncConv20D1

//******************************************************** N_1DPWIFuncCheck ***
// Check Data consistency of N_1DPWIFunc Parameter PCoefs and
//   return number of points in PCoefs
//   or ErrCode < 0 if corrupted.
// On output, PCoefs points to first double after Self Params, including
//   final N_DPDelimeter1 = (123456,0).
//
// (PCoefs description is in the next function comments)
//
function N_1DPWIFuncCheck( var PCoefs: PDouble ): integer;
var
  i, NumPoints, TmpInt: integer;
  PBeg: PDouble;
  PCurDP: TN_BytesPtr;
begin
  Result := -1;

  PBeg := PCoefs;
  NumPoints := Round(PCoefs^);
  Inc( PCoefs ); // skip NumPoints
  TmpInt := Round(PCoefs^);
  Inc( PCoefs, 3 ); // skip DD(4-1), cubic part coef and reserved double
  TmpInt := (TmpInt mod 10000) div 1000;
  if TmpInt <> 5 then Exit;

  N_d := PCoefs^; // debug

  if NumPoints = 0 then // seach till N_DPDelimeter1 and calc NumPoints
  begin
    PCurDP := TN_BytesPtr(PCoefs);

    for i := 0 to 100 do // search for N_DPDelimeter1 (less than 100 points)
    begin
      if CompareMem( PCurDP, @N_DPDelimeter1, SizeOf(TDPoint) ) then // Delimeter found
      begin
        Result := -2;
        Dec( PCurDP, SizeOf(TDPoint) );
        if not CompareMem( PBeg, PCurDP, SizeOf(TDPoint) ) then Exit;
        NumPoints := (PCurDP - TN_BytesPtr(PBeg)) div Sizeof(TDPoint) - 2;
        PBeg^ := NumPoints;
        PCoefs := PDouble(PCurDP);
        PCoefs^ := NumPoints;
        Inc( PCoefs, 4 ); // skip NumPoints, DD(4-1) and N_DPDelimeter1
        Result := NumPoints; // Coefs are OK
        Exit;
      end; // if ... then // Delimeter found

      Inc( PCurDP, SizeOf(TDPoint) );
    end; // for i := 0 to 100 do // search for N_DPDelimeter1

    Result := -3; // N_DPDelimeter1 not found
    Exit;
  end else // NumPoints was given Explicitly
  begin
    Inc( PCoefs, 2*NumPoints );
    N_d := PCoefs^; // debug
    if not CompareMem( PBeg, PCoefs, 2*SizeOf(Double) ) then Exit;
    Inc( PCoefs, 2 ); // skip NumPoints and DD(4-1)
    Result := -4; // no final N_DPDelimeter1
    if not CompareMem( PCoefs, @N_DPDelimeter1, SizeOf(TDPoint) ) then Exit;
    Inc( PCoefs, 2 ); // skip final N_DPDelimeter1
    Result := NumPoints; // Coefs are OK
  end;
end; // function N_1DPWIFuncCheck

//************************************************************* N_1DPWIFunc ***
// OneDimensional Piecewise Interpolation (linear, cubic or mixed)
//
// if PISInd <> nil return used Segment Index (in PISInd^) or
// ISInd = -2 if (AArg < ArgMin) or (NumPoints=1), or ISInd = -1 if Arg > ArgMax
//
// PCoefs - Pointer to Convertion Coefs:
//   [0] - Number of Points in params (>=1) or 0 that means search for N_DPDelimeter1
//   [1] - Decimal Digits flags:
//         DD1 - Extrapolation mode: =0 - Const, =1 - Linear, =2 - Shift
//         DD2 - Interpolation mode: =0 - Piecewise-Linear, =1 - mixed (Linear+Cubic), =2 - not yet
//         DD3 - not used
//         DD4 - always = 5 (for consistency check)
//   [2]   - cubic part coef (in 0-0.5) for mixed mode, used if DD2 =1
//   [3]   - reserved
//   [4+i] - Arg Value (depends on Interpolation mode)
//   [5+i] - FuncValue (depends on Interpolation mode)
//   [last-1] - same as [0] (for consistency check)
//   [last]   - same as [1] (for consistency check)
//   [last+1,2] - N_DPDelimeter1
//
function N_1DPWIFunc( const AArg: double; PCoefs: PDouble;
                                              PISInd: PInteger = nil ): double;
var
  NumPoints, ExtMode, IntMode, TmpInt, ISInd, VertInd: integer;
  Scale, SegmScale, DeltaFunc, CubicPartCoef, DArg: Double;
  A, B, X, XL, XR, XR2, FL, FPL, FR, FPR: Double;
  PArgMin, PArgMax, PArgCur, PFAMin, PFAMax, PFACur: PDouble;
  PBeg, PCur: TN_BytesPtr;
  Label SetISind;

  function OneSegmLinInt( APSegm: TN_BytesPtr ): double; // local
  // Result is Linear interpolation in Segment, given by APSegm
  // APSegm points to Argument of Segment Beg Point
  begin
    DeltaFunc := PDouble(APSegm+24)^ - PDouble(APSegm+8)^;
    SegmScale := DeltaFunc / ( PDouble(APSegm+16)^ - PDouble(APSegm+0)^ );
    Result := PDouble(APSegm+8)^ + ( AArg - PDouble(APSegm+0)^ ) * SegmScale;
  end; // function OneSegmLinInt - local

begin //*************************************** body of N_1DPWIFunc
  Result  := 0; // to avoid warning

  // Get Params from PCoefs into local variables

  NumPoints := Round(PCoefs^); Inc( PCoefs );
  if NumPoints = 0 then // a precaution
  begin
    NumPoints := N_1DPWIFuncCheck( PCoefs );
    Assert( NumPoints >= 1, 'PPCoefs Error1!' );
  end;

  TmpInt  := Round(PCoefs^);   Inc( PCoefs );
  CubicPartCoef := PCoefs^;    Inc( PCoefs, 2 );
  TmpInt  := TmpInt mod 100; // DD1 and DD2
  ExtMode := TmpInt mod 10;
  IntMode := TmpInt div 10;

  if NumPoints <= 1 then // const interpolation and extrapolation (special case)
  begin
    Inc(PCoefs); // Arg Value is not used
    Result := PCoefs^; // Func value for first (and the only) Arg Value
    ISind := -2;
    goto SetISind;
  end else //************** one segment or more (normal case)
  begin
    //***** Set PBeg, PArgMin, PArgMax, PFAMin, PFAMax

    PBeg := TN_BytesPtr(PCoefs); // Points to Argument of first point
    PArgMin := PCoefs;
    PArgMax := PArgMin;
    Inc( PArgMax, 2*(NumPoints-1) );

    Inc( PCoefs );
    PFAMin := PCoefs;
    PFAMax := PFAMin;
    Inc( PFAMax, 2*(NumPoints-1) );

    //***** Check if AArg is outside of (ArgMin, ArgMax) interval

    if AArg <= PArgMin^ then //***** less than ArgMin
    begin
      if ExtMode = 0 then // constant extrapolation (same value as at PArgMin^)
        Result := PFAMin^
      else if ExtMode = 1 then // Liner extrapolation
      begin
        PArgCur := PArgMin;
        Inc( PArgCur, 2 );
        PFACur := PArgCur;
        Inc( PFACur, 1 );
        Scale := (PFACur^-PFAMin^) / (PArgCur^-PArgMin^);
        Result := PFAMin^ - (PArgMin^ - AArg)*Scale;
      end else if ExtMode = 2 then // "Shift" extrapolation
      begin
        Result := PFAMin^ - (PArgMin^ - AArg);
      end else
        Assert( False, 'BadExtMode(Min)!' );

      ISind := -2;
      goto SetISind;
    end; // if AArg <= PArgMin^ then // less than ArgMin

    if AArg >= PArgMax^ then //***** greater than ArgMax
    begin
      if ExtMode = 0 then // constant extrapolation (same value as at PArgMax^)
        Result := PFAMax^
      else if ExtMode = 1 then  // Liner extrapolation
      begin
        PArgCur := PArgMax;
        Inc( PArgCur, -2 );
        PFACur := PArgCur;
        Inc( PFACur, 1 );
        Scale := (PFACur^-PFAMax^) / (PArgCur^-PArgMax^);
        Result := PFAMax^ + (AArg-PArgMax^)*Scale;
      end else if ExtMode = 2 then // "Shift" extrapolation
      begin
        Result := PFAMax^ + (AArg-PArgMax^);
      end else
        Assert( False, 'BadExtMode(Max)!' );

      ISind := -1;
      goto SetISind;
    end; // if AArg >= PArgMax^ then // greater than ArgMax

    //***** Here: PArgMin^ < AArg < PArgMax^ (N_BinSegmSearch can be used)
    //      Calc ISInd - Interpolation Segment Index (AArg is in ISInd)

    if NumPoints = 2 then //************ one Interpolation Segment (to increase speed)
    begin
      ISInd := 0;
    end else if NumPoints = 3 then //*** two Interpolation Segments (to increase speed)
    begin
      PArgCur := PArgMin;
      Inc( PArgCur, 2 );
      if AArg <= PArgCur^ then
        ISInd := 0
      else
        ISInd := 1;
    end else //************************* three or more  Interpolation Segments
    begin
      ISInd := N_BinSegmSearch( TN_BytesPtr(PArgMin), NumPoints, 2*SizeOf(Double), AArg );
    end;

  end; // else // one segment or more (normal case)

  //***** Here: AArg inside ISInd Segment (but may be on any edge)
  //      Calculate Result using IntMode (Interpolation Mode) method

  PCur := PBeg + 2*ISInd*SizeOf(Double); // Points to Argument of ISInd Beg point

  if IntMode = 0 then // Piecewise Linear interpolation
  begin
    Result := OneSegmLinInt( PCur );
  end else if IntMode = 1 then // Piecewise Mixed (Linear-Cubic) interpolation
  begin
    DArg := CubicPartCoef * ( PDouble(PCur+16)^ - PDouble(PCur+0)^ );

    if ((PDouble(PCur+0)^+DArg <= AArg)) and
       ((PDouble(PCur+16)^-DArg >= AArg))   then // AArg is in Linear part of Segment
      Result := OneSegmLinInt( PCur )
    else //*************************************** AArg is in Cubic part of Segment
    begin
      // VertInd - Vertex Index to smooth by cubic polinom
      VertInd := ISInd;
      if PDouble(PCur+16)^-DArg < AArg then // Right part, VertInd = ISind + 1
      begin
       Inc( VertInd );
       Inc( PCur, 16 );
      end;

      if (VertInd = 0) or (VertInd = (NumPoints-1)) then // Last or First Vertex
      begin
        if VertInd <> ISInd then Dec( PCur, 16 ); // prepare for linear interpolation
        Result := OneSegmLinInt( PCur )
      end else // Internal Vertex, smooth by cubic polinom
      begin
        // XL, FL, FPL are Argument, Func, Func' at Left end of cubic part
        // XR, FR, FPR are Argument, Func, Func' at Righr end of cubic part
        //
        //  F = A*X^3 + B*X^2 + C*X + D = D + X*(C + X*(B + X*A));
        //  F(XL) = FL, F'(XL) = FPL, F(XR)=FR, F'(XR) = FPR

        XL := PDouble(PCur+0)^ - CubicPartCoef * (PDouble(PCur+0)^ - PDouble(PCur-16)^);
        XR := CubicPartCoef * (PDouble(PCur+16)^ - PDouble(PCur-16)^);
        X := AArg - XL;

        //*** for Segm before VertInd:
        DeltaFunc := PDouble(PCur+8)^ - PDouble(PCur-8)^;
        FL  := PDouble(PCur+8)^ - CubicPartCoef * DeltaFunc;
        FPL := DeltaFunc / ( PDouble(PCur+0)^ - PDouble(PCur-16)^ ); // SegmScale

        //*** for Segm after VertInd:
        DeltaFunc := PDouble(PCur+24)^ - PDouble(PCur+8)^;
        FR  := PDouble(PCur+8)^ + CubicPartCoef * DeltaFunc;
        FPR := DeltaFunc / ( PDouble(PCur+16)^ - PDouble(PCur+0)^ ); // SegmScale


        B := 3*(FR - FL) - XR*(2*FPL + FPR);
        A := 2*(FL - FR) + XR*(FPL + FPR);
        XR2 := XR*XR;
        B := B / XR2;
        A := (A / XR2) / XR;

        //  C = FPL
        //  D = FL
        //  F = A*X^3 + B*X^2 + C*X + D = D + X*(C + X*(B + X*A));

        Result := FL + X*(FPL + X*(B + X*A));

//    a := ( 2*(F0 - FX0) + X0*(FP0 + FPX0) ) / (X0*X0*X0);
//    b := ( 3*(FX0 - F0) - X0*( 2*FP0  + FPX0) ) / (X0*X0);
//    c := FP0;
//    d := F0;
      end; // else // Internal Vertex, smooth by cubic polinom
    end; // else // AArg is in Cubic part of Segment
  end else
    Assert( False, 'IntMode not Implemented!' );


  SetISind: //****** Result is OK, just set ISind

  if PISInd <> nil then PISInd^ := ISInd;
end; // function N_1DPWIFunc


end.
