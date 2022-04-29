unit N_StatFunc;
// Statistic and social-economic analysis functions

interface

procedure N_SFAddVElems    ( APV1, APV2: PDouble; ANumElems: integer;
                                         APVRes: PDouble; AC2, ACRes: double );
procedure N_SFMultVElems   ( APV1, APV2: PDouble; ANumElems: integer;
                                         APVRes: PDouble; ACRes: double );
procedure N_SFDivideVElems ( APV1, APV2: PDouble; ANumElems: integer;
                                         APVRes: PDouble; ACRes: double );
procedure N_SFCumSumVElems ( APV1: PDouble; ANumElems: integer;
                                            APVRes: PDouble; ACRes: double );
procedure N_SFAbsVElems    ( APV1: PDouble; ANumElems: integer;
                                            APVRes: PDouble; ACRes: double );
function  N_SFGetSumElems  ( APV1: PDouble; ANumElems: integer ): double;
function  N_SFGetIndOfMax  ( APV1: PDouble; ANumElems: integer ): integer;
function  N_SFGetIndOfInterval ( APVMin: PDouble; ANumElems: integer; AVal: double ): integer;
function  N_SFGetVectorMode( APVXMin, APVXD, APVPlotn: PDouble; ANumElems: integer ): double;
function  N_SFGetDecCoef   ( APVXMin, APVXD, APVW, APVAW: PDouble;
                             ANumElems: integer; AvalPrc: double ): double;

implementation

//*********************************************************** N_SFAddVElems ***
// Add Vector Elems:
//
// VRes[i] := ( V1[i] + AC2*V2[i] ) * ACRes
//
// APV2 = nil means that all Vector elems = 1 ( V2[i] = 1 )
//
procedure N_SFAddVElems( APV1, APV2: PDouble; ANumElems: integer;
                                      APVRes: PDouble; AC2, ACRes: double );
var
  i: integer;
  CurV2: double;
begin
  CurV2 := 1;

  for i := 1 to ANumElems do
  begin
    if APV2 <> nil then
    begin
      CurV2 := APV2^;
      Inc( APV2 );
    end; // if APV2 <> nil then

    APVRes^ := (APV1^ + AC2*CurV2) * ACRes;
    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure N_SFAddVElems

//********************************************************** N_SFMultVElems ***
// Multiply Vector Elems:
//
// VRes[i] :=  V1[i] * V2[i] * ACRes
//
procedure N_SFMultVElems( APV1, APV2: PDouble; ANumElems: integer;
                                      APVRes: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    APVRes^ := APV1^ * APV2^ * ACRes;
    Inc( APV1 );
    Inc( APV2 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure N_SFMultVElems

//******************************************************** N_SFDivideVElems ***
// Divide Vector Elems:
//
// VRes[i] :=  ACRes * V1[i] / V2[i]
//
procedure N_SFDivideVElems( APV1, APV2: PDouble; ANumElems: integer;
                                        APVRes: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    if APV2^ = 0 then
      APVRes^ := 0
    else
      APVRes^ := ACRes * APV1^ / APV2^;

    Inc( APV1 );
    Inc( APV2 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure N_SFDivideVElems

//******************************************************** N_SFCumSumVElems ***
// Calc Vector with Cumulative Sum of Vector Elems:
//
// VRes[i] :=  ACRes * ( Sum( j=0 to i ) V1[j] )
//
procedure N_SFCumSumVElems( APV1: PDouble; ANumElems: integer;
                                           APVRes: PDouble; ACRes: double );
var
  i: integer;
  CumSum: double;
begin
  CumSum := 0;
  for i := 1 to ANumElems do
  begin
    CumSum := CumSum + APV1^;
    APVRes^ := ACRes * CumSum;

    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure N_SFCumSumVElems

//*********************************************************** N_SFAbsVElems ***
// Calc Abs value of Vector Elems:
//
// VRes[i] :=  ACRes * Abs( V1[i] )
//
procedure N_SFAbsVElems( APV1: PDouble; ANumElems: integer;
                                        APVRes: PDouble; ACRes: double );
var
  i: integer;
begin
  for i := 1 to ANumElems do
  begin
    APVRes^ := ACRes * Abs( APV1^ );

    Inc( APV1 );
    Inc( APVRes );
  end; // for i := 1 to ANumElems do
end; // procedure N_SFAbsVElems

//********************************************************* N_SFGetSumElems ***
// Return Sum of given Vector Elems
// Result := Sum( V1[i] )
//
function N_SFGetSumElems( APV1: PDouble; ANumElems: integer ): double;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to ANumElems do
  begin
    Result := Result + APV1^;
    Inc( APV1 );
  end; // for i := 1 to ANumElems do
end; // function N_SFGetSumElems

//********************************************************* N_SFGetIndOfMax ***
// Return Index of Maximal Vector Element
// V1[Result] >= V1[i]
//
function N_SFGetIndOfMax( APV1: PDouble; ANumElems: integer ): integer;
var
  i: integer;
  CurMax: double;
begin
  Result := 0;
  CurMax := APV1^;
  Inc( APV1 );

  for i := 2 to ANumElems do
  begin
    if APV1^ > CurMax then
    begin
      CurMax := APV1^;
      Result := i - 1;
    end;

    Inc( APV1 );
  end; // for i := 1 to ANumElems do
end; // function N_SFGetIndOfMax

//**************************************************** N_SFGetIndOfInterval ***
// Return (Index of Interval + 1) by given AVal
//
// VMin - Vector of Min interval values
//
// VMin[Result-1] <= AVal < VMin[Result-1] (VMin[Result-1] <= AVal if Result=ANumElems)
// Result = 0  if AVal < VMin[0]
//
function N_SFGetIndOfInterval( APVMin: PDouble; ANumElems: integer; AVal: double ): integer;
var
  i: integer;
begin
  Result := 0; // to avoid warning

  for i := 1 to ANumElems do
  begin
    Result := i - 1;
    if AVal < APVMin^ then Break;

    Inc( APVMin );
  end; // for i := 1 to ANumElems do
end; // function N_SFGetIndOfInterval

//******************************************************* N_SFGetVectorMode ***
// Return Vector Mode ( Value with max probabiliti (likehood) )
// (значение, при котором достигается максимум плотности распределения)
//
// APVXMin  - Min Interval Values
// APVXD    - Size of intervals
// APVPlotn - Plotnost' (плотность)
//
function N_SFGetVectorMode( APVXMin, APVXD, APVPlotn: PDouble; ANumElems: integer ): double;
var
  i: integer;
  mk, dmk: double;
begin
  i := N_SFGetIndOfMax( APVPlotn, ANumElems );

  if (i >= 1) and (i < ANumElems) then
  begin
    Inc( APVXMin, i );
    Inc( APVXD, i );
    Inc( APVPlotn, i-1 );

    dmk := APVPlotn^;
    Inc( APVPlotn );
    mk := APVPlotn^;
    Inc( APVPlotn );
    dmk := mk - dmk;

    Result := APVXMin^ + APVXD^ * ( dmk / (dmk + mk - APVPlotn^) );
  end else if i = 0 then // first interval (Спросить у Олега)
  begin
    Result := APVXMin^;
    Inc( APVXMin );
    Result := 0.5*( Result + APVXMin^);
  end else // last interval, i = (ANumElems-1)
  begin
    Inc( APVXMin, ANumElems-2 );
    Result := APVXMin^;
    Inc( APVXMin );
    Result := 0.5*( Result + APVXMin^);
  end;
end; // function N_SFGetVectorMode

//********************************************************** N_SFGetDecCoef ***
// Return Decil Coef by given AvalPrc in percents
// (децильный коэф. для заданного значения в процентах)
//
// ( for AvalPrc = 50 Result is a Median)
//
// APVXMin  - Min Interval Values
// APVXD    - Size of intervals
// APVW     - Chastost' (частость)
// APVAW    - Accumulated Chastost' (накопленные частости)
// AvalPrc  - Given Value in percents
//
function N_SFGetDecCoef( APVXMin, APVXD, APVW, APVAW: PDouble;
                         ANumElems: integer; AvalPrc: double ): double;
var
  i: integer;
  w: double;
begin
  i := N_SFGetIndOfInterval( APVAW, ANumElems, AvalPrc );

  if i = 0 then
    w := 0
  else // i >= 1
  begin
    Inc( APVAW, i-1 );
    w := APVAW^;
  end;

  Inc( APVXMin, i );
  Inc( APVXD, i );
  Inc( APVW, i );

  Result := APVXMin^ + APVXD^ * ( ( AvalPrc - w ) / APVW^ );
end; // function N_SFGetDecCoef


end.
