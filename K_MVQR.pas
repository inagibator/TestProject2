unit K_MVQR;

interface
uses
 K_SCript1, K_UDT1, K_MVObjs, K_DCSpace,
 N_Types;

//********************************
//  MV Query  Interface
//********************************

type TK_MVQFlags = set of (
  K_mvqDupIgnore  // prevents vectors duplicate
);

type TK_MVQRMode = ( K_mrmActVals, K_mrmAllVals );
type TK_MVQECompCond = ( K_mecLT, K_mecLE, K_mecGT, K_mecGE, K_mecEQ );
type TK_MVQVCompCond = set of (
  K_mvcUseTime,    // Use Time Interval to Select Vectors SubSet
  K_mvcUseTable,   // Use Vectors UDTable to Select Vectors SubSet
  K_mvcResCEValue, // Return Current Element Value as CompareVector Result
  K_mvcResCERating // Return Current Element Rating as CompareVector Result
);
type TK_MVQRTime = ( K_mttBegin, K_mttMiddle, K_mttEnd );
type TK_MVQRSSOrder = ( K_mssNoOrder, K_mssAscOrder, K_mssDescOrder );

// Element Values Compare Function
type TK_MVQRECompFunc = function ( Value, Rating : Double ) : Double of object;

// Vectors Compare Function
type TK_MVQRVCompFunc = function ( VInd : Integer ) : Double of object;

type TK_MVQRVectors = class (TObject)
//*** Elements Data Routines Result  Mode
  QRMode : TK_MVQRMode;

//*** Vectors Query Results
  QVNum    : Integer;      // Number of vectors
  QUDTab   : TN_UDArray;   // Array of Vector's Tables (TK_UDMVTable)
  QUDVectors : TN_UDArray; // Array Of Vectors (TK_UDMVVector)
  QVectors : array of TK_MVVector; // Array Of TK_MVVector (TK_UDMVVector.R)
  QAttrs   : array of TK_MVVAttrs; // Array Of Vector Attributes (TK_UDRArray.R)
  QSVA     : array of TK_SpecValsAssistant; // Array Of SpecValues Assistantes

//*** User Code Space
  QCS    : TK_UDDCSpace;
  QCSProjs  : TN_UDArray;   // QCS projections for All Vectors
  QCSBProjs : TN_UDArray;   // QCS back projections for All Vectors

//*** Request Element
  QCurElem  : Integer;     // Current Element in QCS
  QCurEInds : TN_IArray;   // Current Element Vectors Indexes for All Vectors

//*** Request Elements SubSet
  QESS     : TN_IArray;    // Elements SubSet Indexes in QCS
  QESSVInds : array of TN_IArray; // Current SubSet Vectors Indexes

//*** Calculated Vectors Ratings
  QRatings : array of TN_IArray;   // Vector Ratings for All Vectors

//*** Calculated Vectors SubSet
  QVSS   : TN_IArray;   // SubSet of Vectors Indexes

//*** TK_MVQRECompFunc Functions Attribs
//  Func: CompareElemValue
  CompECond  : TK_MVQECompCond; // Compare Element Values Condition
  CompEValue : Double;          // Compared Value
  CompERating : Boolean;        // Compare Rating Flag

//*** TK_MVQRVCompFunc Functions Attribs
//  Func: CompareVector
  CompVCond  : TK_MVQVCompCond; // Compare Vectors Condition
  CompVUDTab : TN_UDBase;       // Compared Vector's Table
  CompVTimeBegin : TDateTime;   // Compare Vectors TimePeriod Start
  CompVTimeEnd   : TDateTime;   // Compare Vectors TimePeriod End
  CompVTimeIsInside : Boolean;  // Vectors TimePeriod Compare Flag

  constructor Create;
  destructor Destroy; override;
//*** Vectors Query Routines
  procedure  Clear;
  function   AddVectors(
      Flags : TK_MVQFlags = [];
      Root : TN_UDBase = nil;
      NamePat : string = '';
      TPBegin : TDateTime = 0;
      TPEnd   : TDateTime = 0;
      IsInside  : Boolean = true ) : Integer;
//*** Set Data Query Attributes Routine's
  procedure SetQCS( CS: TK_UDDCSpace; SVInd : Integer = 0 );
  procedure SetQRMode( RMode : TK_MVQRMode );
  function  SetCurElem( CSElem : Integer ) : Integer;
  procedure SetCurESS( CSElems : TN_IArray; SVInd : Integer = 0 );
  procedure SetCurVSS( RSortMode : TK_MVQRSSOrder = K_mssNoOrder;
                       VCompFunc : TK_MVQRVCompFunc = nil );

  procedure BuildRatings( SVInd : Integer = 0 );

//*** Get Data Routines
  procedure GetVEValues( PData : PDouble; DataStep : Integer = SizeOf(Double) );
  procedure GetVEStrValues( PData: PString;
                           DataStep : Integer = SizeOf(string) );
  procedure GetVERatings( PRating : PDouble; DataStep : Integer = SizeOf(Double)  );
  procedure GetVETStamps( PTime : PDouble; MVQRTime : TK_MVQRTime = K_mttMiddle;
                          DataStep : Integer = SizeOf(Double) );
  procedure GetVETTypes( PTType : PInteger; DataStep : Integer = SizeOf(Integer)  );
  procedure GetVEVInds( PVInds : PInteger; DataStep : Integer = SizeOf(Integer)  );
  function  GetSSElems( VInd : Integer;
                          RSortMode : TK_MVQRSSOrder = K_mssNoOrder;
                          CondFunc: TK_MVQRECompFunc = nil ) : TN_IArray;
  function  GetIndicatorKey( VInd : Integer = 0 ) : string;

//*** TK_MVQECompCond Functions
  function  CompareElemValue( Value, Rating : Double ) : Double;
//*** TK_MVQVCompCond Functions
  function  CompareVector( VInd : Integer ) : Double;

private
  function  VEValueToStr( Value : Double; VInd : Integer ) : string;
  procedure PrepareQVSS();
  function  SetCurSSElem( CSElem: Integer; var VVInds : TN_IArray; SVInd : Integer = 0 ): Integer;
  function  GetTimePeriodEnd( const TP : TK_MVTimePeriod ) : TDateTime;
  function  CompareTimeIntervals(
      TCBegin : TDateTime;
      TCEnd   : TDateTime;
      TBegin : TDateTime = 0;
      TEnd   : TDateTime = 0;
      IsInside   : Boolean = true ) : Boolean;

end; //*** end of type TK_MVQRVectors = record

implementation

uses
  SysUtils, Windows, DateUtils,
  K_VFunc, K_CLib0,
  N_Lib1;

const K_ErrIndex = -1000000;

{*** TK_MVQRVectors ***}

//**************************************** TK_MVQRVectors.Create
//  MVVectors Query Create
//
constructor TK_MVQRVectors.Create;
begin
  Inherited;
  QCurElem := -1;
end; // end of constructor TK_MVQRVectors.Create

//**************************************** TK_MVQRVectors.Destroy
//  MVVectors Query Destroy
//
destructor TK_MVQRVectors.Destroy;
begin
  Clear;
  inherited;
end; // end of destructor TK_MVQRVectors.Destroy

//**************************************** TK_MVQRVectors.Clear
//  MVVectors Query Free Context
//
procedure TK_MVQRVectors.Clear;
var i : Integer;
begin
  QCurEInds := nil;
  QRatings := nil;
  QVectors := nil;
  QUDVectors := nil;
  QAttrs   := nil;
  QUDTab   := nil;
  QVSS     := nil;
  QESS     := nil;
  QCSProjs  := nil;
  QCSBProjs := nil;
  QESSVInds := nil;
  for i := 0 to High(QSVA) do
    QSVA[i].Free;
  QSVA     := nil;
end; // end of procedure TK_MVQRVectors.Clear

//**************************************** TK_MVQRVectors.AddVectors
//  Add MVVectors SubQuery
//
function TK_MVQRVectors.AddVectors(Flags: TK_MVQFlags; Root: TN_UDBase;
  NamePat: string; TPBegin, TPEnd: TDateTime; IsInside: Boolean) : Integer;
var
  VNum, i, j, k : Integer;
  SkipVector : Boolean;
  WESS : TN_IArray;
  WCurElem : Integer;
begin
  Result := -1;
  WESS := QESS;
  if not (Root is TK_UDMVTable) then Exit;
  with TK_UDMVTable(Root) do begin
    VNum := GetSubTreeChildHigh + 1;
    SetLength( QUDVectors, QVNum + VNum );
    SetLength( QVectors, QVNum + VNum );
    SetLength( QAttrs, QVNum + VNum );
    SetLength( QUDTab, QVNum + VNum );
    SetLength( QSVA, QVNum + VNum );
    j := QVNum;
    for i := 0 to VNum - 1 do begin
      QUDVectors[j] := GetUDVector( i );
      SkipVector := false;
      if not (K_mvqDupIgnore in Flags) then begin
        for k := 0 to QVNum + i - 1 do begin
          SkipVector := (QUDVectors[k] = QUDVectors[j]);
          if SkipVector then break;
        end;
        if SkipVector then Continue;
      end;
      QUDTab[j] := Root;
      with TK_PMVVector(TK_UDRArray(QUDVectors[j]).R.P)^ do
        if not CompareTimeIntervals( TimePeriod.SDate,
          GetTimePeriodEnd( TimePeriod ),
          TPBegin, TPEnd, IsInside ) then Continue;
      QVectors[j] := TK_PMVVector(TK_UDRArray(QUDVectors[j]).R.P)^;
      QAttrs[j] := TK_PMVVAttrs(GetUDAttribs( i ).R.P)^;
      QSVA[j] := TK_SpecValsAssistant.Create( TK_UDRArray(QAttrs[j].UDSVAttrs).R );
      Inc(j);
    end;
    SetLength( QUDVectors, j );
    SetLength( QVectors, j );
    SetLength( QAttrs, j );
    SetLength( QUDTab, j );
  end;
// Init Added Vectors Query Context
  k := QVNum;
  QVNum := j;

  WCurElem := QCurElem;
// Init Code Space Context for Added Vectors
  if QCS <> nil then SetQCS( QCS, k );
  Result := 0;
// Init Curremt Element Context for Added Vectors
  if WCurElem >= 0 then Result := SetCurSSElem( WCurElem, QCurEInds, k );
// Init Elements SubSpace Context for Added Vectors
  WESS := QESS;
  if WESS <> nil then
    SetCurESS( WESS, k );
// Init Ratings Context for Added Vectors
  if QRatings <> nil then BuildRatings( k );

end; // end of procedure TK_MVQRVectors.AddVectors

//**************************************** TK_MVQRVectors.BuildRatings
//  Build Array of MVVectors Ratings
//
procedure TK_MVQRVectors.BuildRatings( SVInd : Integer = 0 );
var
  n, i, j : Integer;
  Inds : TN_IArray;
  SInds : TN_IArray;
  WR : TN_IArray;
  WSR : TN_IArray;
  WD : TN_DArray;
  WL, VL : Integer;
  PData : PDouble;
  PRInds : PInteger;

begin
  SetLength( QRatings, QVNum );
  WSR := nil;

  for i := SVInd to QVNum - 1 do begin
// Build Vectors Ratings Loop
    VL := TK_UDDCSSpace(QVectors[i].CSS).PDRA.ALength;
    WL := VL;
    PData := PDouble(QVectors[i].D.P);
    if QESSVInds <> nil then begin
    // Use SubSpace
      WL := Length(QESSVInds);
    // Build Indexes Vector
      SetLength( SInds, WL );
      for j := 0 to WL - 1 do
        SInds[j] := QESSVInds[j][i];

      SetLength( WD, WL );
      K_MoveVectorBySIndex( WD[0], SizeOF(Double),
                          PData^, SizeOF(Double),
                          SizeOF(Double), WL, @SInds[0] );
      PData := @WD[0];
    end;
  // Move Real Values o Buffer Vector
    SetLength( Inds, WL );
    n := K_BuildMVVectorNotSpecValuesIndex( PData, @Inds[0], WL );
    SetLength( WD, n );
    K_MoveVectorBySIndex( WD[0], SizeOF(Double),
                        PData^, SizeOF(Double),
                        SizeOF(Double), n, @Inds[0] );
  // Build Sorted Index
    SetLength( WR, n );
    K_BuildSortedDoubleInds( @WR[0], @WD[0], n, false );
//    K_BuildSortIndex( @WR[0], @WD[0], n, sizeof(Double),
//        0, N_CompareDoubles );

    if Length(SInds) <> 0 then begin
    // Use Sub Set Indexes
    // Build New Indexes in Buffer Indexes Arraay WR
      WSR := Copy( WR );
      SetLength(WR, WL );
      FillChar( WR[0], WL * SizeOf(Integer), $FF );
      K_MoveVectorByDIndex( WR[0], SizeOF(Integer),
                        WSR[0], SizeOF(Integer),
                        SizeOF(Integer), n, @Inds[0] );
      n := WL;
      PRInds := @SInds[0];
    end else
      PRInds := @Inds[0];

  // Init Ratings by -1
    SetLength( QRatings[i], VL );
    FillChar( QRatings[i][0], VL * SizeOf(Integer), $FF );

  // Place Sorted Index to QRatings Vector
    K_MoveVectorByDIndex( QRatings[i][0], SizeOF(Integer),
                        WR[0], SizeOF(Integer),
                        SizeOF(Integer), n, PRInds );
  //*** end of Build QVectors QRatings Loop
  end;
end; // end of procedure TK_MVQRVectors.BuildRatings

//**************************************** TK_MVQRVectors.SetQCS
//  Set Current Query Code Space
//
procedure TK_MVQRVectors.SetQCS( CS: TK_UDDCSpace; SVInd : Integer = 0 );
var
  WVCS : TK_UDDCSpace;
  CurVCS : TK_UDDCSpace;
  CurVCSS : TK_UDDCSSpace;
  i : Integer;
  CurBProj, CurDProj : TN_UDBase;
begin
  CurVCS := nil;
  CurVCSS := nil;
  CurDProj := nil;
  CurBProj := nil;
  SetLength( QCSProjs, QVNum );
  SetLength( QCSBProjs, QVNum );
  QCS := CS;
  for i := SVInd to QVNum - 1 do begin
    if CurVCSS <> QVectors[i].CSS then begin
// Set Cur Vector CS
      CurVCSS := TK_UDDCSSpace(QVectors[i].CSS);
      WVCS := CurVCSS.GetDCSpace;
      if WVCS <> CurVCS then begin
        CurVCS := WVCS;
        if CurVCS <> CS then begin
          CurDProj := K_DCSpaceProjectionGet( CurVCS, CS );
          CurBProj := K_DCSpaceProjectionGet( CS, CurVCS );
        end else begin
          Integer(CurDProj) := 1;
          Integer(CurBProj) := 1;
        end;
      end;
    end;
    QCSProjs[i] := CurDProj;
    QCSBProjs[i] := CurBProj;
  end;
  if SVInd = 0 then begin
    QCurElem := -1;
    QESS := nil;
  end;

end; // end of procedure TK_MVQRVectors.SetQCS

//**************************************** TK_MVQRVectors.SetQRMode
//  Set Current Vectors Element
//
procedure TK_MVQRVectors.SetQRMode( RMode : TK_MVQRMode );
begin
  QRMode := RMode;
end; // end of procedure TK_MVQRVectors.SetQRMode

//**************************************** TK_MVQRVectors.SetCurElem
//  Set Current Vectors Element
//
function TK_MVQRVectors.SetCurElem( CSElem: Integer ): Integer;
begin
  Result := SetCurSSElem( CSElem, QCurEInds );
  QCurElem := CSElem;
end; // end of function TK_MVQRVectors.SetCurElem

//**************************************** TK_MVQRVectors.SetCurESS
//  Set Current Elements SubSet for Calculating Ratings and
//  for GetSSElems Routine Request
//
procedure TK_MVQRVectors.SetCurESS( CSElems: TN_IArray; SVInd : Integer = 0 );
var
  i : Integer;
begin
  SetLength( QESSVInds, Length(CSElems) );
  for i := 0 to High(CSElems) do
    SetCurSSElem( CSElems[i], QESSVInds[i], SVInd );
  if SVInd = 0 then QRatings := nil;
  QESS := CSElems;
end; // end of procedure TK_MVQRVectors.SetCurESS

//**************************************** TK_MVQRVectors.SetCurVSS
//  Set Current Vectors Orders SubSet needed for All Data Request Routines
//  if VCompFunc = nil then CompV... Variables must be set before call to this Rourine
//
procedure TK_MVQRVectors.SetCurVSS( RSortMode : TK_MVQRSSOrder = K_mssNoOrder;
                                    VCompFunc : TK_MVQRVCompFunc = nil );
var
  i, j : Integer;
  Vals : TN_DArray;
//  SortFlag : Integer;
  SInds : TN_IArray;
  Inds : TN_IArray;
  CVal : Double;
begin
  SetLength( Vals, QVNum );
  SetLength( Inds, QVNum );
  if not Assigned(VCompFunc) then VCompFunc := CompareVector;
  j := 0;
  for i := 0 to QVNum - 1 do begin
    CVal := VCompFunc(i);
    if CVal <> K_MVMinVal then begin
      Inds[j] := i;
      Vals[j] := CVal;
      Inc(j);
    end;
  end;
  if RSortMode <> K_mssNoOrder then begin
// Sort Elements Order if Needed
//    if RSortMode <> K_mssAscOrder then
//      SortFlag := 0
//    else
//      SortFlag := N_SortOrder;
    SetLength( SInds, j );
    K_BuildSortedDoubleInds( @SInds[0], @Vals[0], j, RSortMode <> K_mssAscOrder );
//    K_BuildSortIndex( @SInds[0], @Vals[0], j, sizeof(Double),
//      SortFlag, N_CompareDoubles );
    SetLength( QVSS, j );
    K_MoveVectorBySIndex( QVSS[0], SizeOf(Integer),
                        Inds[0], SizeOf(Integer), SizeOf(Integer),
                        j, @SInds[0] );

  end else
    QVSS := Copy( Inds, 0, j );
end; // end of procedure TK_MVQRVectors.SetCurVSS

//**************************************** TK_MVQRVectors.VEValueToStr
//  Convert Data Request Value to string
//
function TK_MVQRVectors.VEValueToStr( Value : Double; VInd : Integer ) : string;
var
  n : Integer;
begin
  with QAttrs[VInd], QSVA[VInd] do begin
    n := IndexOfSpecVal( Value );
    if n >= 0 then                                  // Spec Value
      Result := GetSpecValAttrs( n ).Caption
    else if ValueType.T = K_vdtDiscrete then begin  // Discrete Value
      n := K_IndexOfDoubleInScale( PDouble(RangeValues.P),
                   RangeValues.AHigh, sizeof(Double), Value );
      if (n > 0) then Dec(n)
      else n := 0;
      Result := PString(RangeCaptions.P(n))^
    end else                                        // Continuous Value
      if VFormat <> '' then
        Result := format( VFormat, [Value])
      else
        Result := format('%.*f', [VDPPos, Value]);
  end;
end; // end of procedure TK_MVQRVectors.VEValueToStr

//**************************************** TK_MVQRVectors.GetVEValues
//  Get Data Request Values Vector
//
procedure TK_MVQRVectors.GetVEValues( PData: PDouble;
                           DataStep : Integer = SizeOf(Double) );
var
  CInd, Ind, i : Integer;
begin
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    Ind := QCurEInds[i];
    if (Ind <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (Ind >= 0) ) then begin
      if Ind < 0 then Ind := -Ind - 1;
      PData^ := PDouble(QVectors[i].D.P(Ind))^;
      Inc(TN_BytesPtr(PData), DataStep);
    end;
  end;
end; // end of procedure TK_MVQRVectors.GetVEValues

//**************************************** TK_MVQRVectors.GetVEStrValues
//  Get Data Request Values as Strings Vector
//
procedure TK_MVQRVectors.GetVEStrValues( PData: PString;
                           DataStep : Integer = SizeOf(string) );
var
  CInd, Ind, i : Integer;
begin
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    Ind := QCurEInds[i];
    if (Ind <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (Ind >= 0) ) then begin
      if Ind < 0 then Ind := -Ind - 1;
      PData^ := VEValueToStr( PDouble(QVectors[i].D.P(Ind))^, i );
      Inc(TN_BytesPtr(PData), DataStep);
    end;
  end;
end; // end of procedure TK_MVQRVectors.GetVEStrValues

//**************************************** TK_MVQRVectors.GetVERatings
//  Get Data Request Ratings Vector
//
procedure TK_MVQRVectors.GetVERatings(PRating: PDouble; DataStep: Integer = SizeOf(Double));
var
  CInd, i, Ind : Integer;
begin
  if Length(QRatings) = 0 then BuildRatings;
  if DataStep = 0 then DataStep := SizeOf( Double );
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    Ind := QCurEInds[i];
    if (Ind <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (Ind >= 0) ) then begin
      if Ind < 0 then Ind := -Ind - 1;
      PRating^ := QRatings[i][Ind];
      Inc(TN_BytesPtr(PRating), DataStep);
    end;
  end;
end; // end of procedure TK_MVQRVectors.GetVERatings

//**************************************** TK_MVQRVectors.GetVETStamps
//  Get Data Request Timestamps Vector in years
//
procedure TK_MVQRVectors.GetVETStamps( PTime : PDouble;
                         MVQRTime : TK_MVQRTime = K_mttMiddle;
                         DataStep : Integer = SizeOf(Double) );
var
  CInd, i : Integer;
  SDT, WDT : TDateTime;

begin
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    if (QCurEInds[i] <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (QCurEInds[i] >= 0) ) then begin
      WDT := 0;
      case MVQRTime of
        K_mttBegin  : WDT := QVectors[i].TimePeriod.SDate;
        K_mttMiddle : WDT := ( QVectors[i].TimePeriod.SDate + GetTimePeriodEnd(QVectors[i].TimePeriod) ) / 2;
        K_mttEnd    : WDT := GetTimePeriodEnd(QVectors[i].TimePeriod);
      end;
      SDT := StartOfTheYear(WDT);
      PTime^ := YearOf(WDT) + (WDT - SDT)/(EndOfTheYear(WDT) - SDT);
      Inc(TN_BytesPtr(PTime), DataStep);
    end;
  end;
end; // end of procedure TK_MVQRVectors.GetVETStamps

//**************************************** TK_MVQRVectors.GetVETTypes
//  Get Data Request TimePriod Units Vector
//
procedure TK_MVQRVectors.GetVETTypes( PTType : PInteger; DataStep : Integer = SizeOf(Integer) );
var
  CInd, i : Integer;
begin
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    if (QCurEInds[i] <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (QCurEInds[i] >= 0) ) then begin
      PTType^ := Ord(QVectors[i].TimePeriod.PType);
      Inc(TN_BytesPtr(PTType), DataStep);
    end;
  end;
end; // end of procedure TK_MVQRVectors.GetVETTypes

//**************************************** TK_MVQRVectors.GetVEVInds
//  Get Data Request Vectors Indexes Vector
//
procedure TK_MVQRVectors.GetVEVInds( PVInds: PInteger; DataStep: Integer = SizeOf(Integer) );
var
  CInd, i : Integer;
begin
  PrepareQVSS;
  for CInd := 0 to High(QVSS) do begin
    i := QVSS[CInd];
    if (QCurEInds[i] <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (QCurEInds[i] >= 0) ) then begin
      PVInds^ := i;
      Inc(TN_BytesPtr(PVInds), DataStep);
    end;
  end;

end; // end of procedure TK_MVQRVectors.GetVEVInds

//**************************************** TK_MVQRVectors.GetSSElems
//  Get Elements SubSet - select from Current Elements SubSet QESS
//
function TK_MVQRVectors.GetSSElems( VInd : Integer;
                          RSortMode : TK_MVQRSSOrder = K_mssNoOrder;
                          CondFunc: TK_MVQRECompFunc = nil ): TN_IArray;
var
  CInd, j, i : Integer;
  Vals : TN_DArray;
  SInds, Inds : TN_IArray;
//  SortFlag : Integer;
  Rating : Double;
begin
  SetLength( Vals, Length(QESSVInds) );
  SetLength( Inds, Length(QESSVInds) );
  if not Assigned(CondFunc) then
    CondFunc := CompareElemValue;
  j := 0;
// Calc Condition Function Results Vector
  for i := 0 to High(QESSVInds) do begin
    CInd := QESSVInds[i][VInd];
    if CInd < 0 then Continue;

    Inds[j] := CInd;

    if Length(QRatings) = 0 then
      Rating := -1
    else
      Rating := QRatings[VInd][CInd];

    Vals[j] := CondFunc( PDouble(QVectors[VInd].D.P(CInd))^, Rating );
    if Vals[j] = K_MVMinVal then Continue;
    Inc(j);
  end;
  if RSortMode <> K_mssNoOrder then begin
// Sort Elements Order if Needed
//    if RSortMode <> K_mssAscOrder then
//      SortFlag := 0
//    else
//      SortFlag := N_SortOrder;
    SetLength( SInds, j );
    K_BuildSortedDoubleInds( @SInds[0], @Vals[0], j, RSortMode <> K_mssAscOrder );
//    K_BuildSortIndex( @SInds[0], @Vals[0], j, sizeof(Double),
//      SortFlag, N_CompareDoubles );
    SetLength( Result, j );
    K_MoveVectorBySIndex( Result[0], SizeOf(Integer),
                        Inds[0], SizeOf(Integer), SizeOf(Integer),
                        j, @SInds[0] );

  end else
    Result := Copy( Inds, 0, j );

// Convert to QCS Inds
  for i := 0 to j - 1 do begin
    CInd := PInteger(TK_UDVector(QVectors[VInd].CSS).PDE(Result[i]))^;
    if QCSBProjs[i] = nil then
      CInd := -1
    else if Integer(QCSBProjs[i]) <> 1 then
      CInd := PInteger(TK_UDVector(QCSBProjs[i]).PDE(CInd))^;
    Result[i] := CInd;
  end;

end; // end of function TK_MVQRVectors.GetSSElems

//**************************************** TK_MVQRVectors.GetIndicatorKey
//  Get Indicator Key
//
function TK_MVQRVectors.GetIndicatorKey( VInd: Integer = 0 ): string;
begin
  Result := '';
  if (VInd < 0) or (VInd >= QVNum) then Exit;
  Result := TK_PMVTable(TK_UDRArray(QUDTab[VInd]).R.P).BriefCapt;
end; // end of function TK_MVQRVectors.GetIndicatorKey

//**************************************** TK_MVQRVectors.CompareElemValue
//  Compare Element Value and/or Rating - used in GetSSElems Routine
//
function TK_MVQRVectors.CompareElemValue(Value, Rating: Double): Double;
var
  CValue : Double;
  BResult : Boolean;
begin
  if CompERating then
    CValue := Rating
  else
    CValue := Value;
  BResult := false;
  case CompECond of
    K_mecLT: BResult := CValue < CompEValue;
    K_mecLE: BResult := CValue <= CompEValue;
    K_mecGT: BResult := CValue > CompEValue;
    K_mecGE: BResult := CValue >= CompEValue;
    K_mecEQ: BResult := CValue = CompEValue;
  end;
  if BResult then
    Result := CValue
  else
    Result := K_MVMinVal;
end; // end of function TK_MVQRVectors.CompareElemValue

//**************************************** TK_MVQRVectors.CompareVector
//  Compare Vector - used in SetCurVSS Routine
//
function TK_MVQRVectors.CompareVector( VInd: Integer ): Double;
var
  BResult : Boolean;
  CVal : Double;
  Ind : Integer;
  procedure GetElemInd;
  begin
    Ind := QCurEInds[VInd];
    if (Ind <> K_ErrIndex) and
       ((QRMode = K_mrmAllVals) or (Ind >= 0) ) then begin
      if Ind < 0 then Ind := -Ind - 1;
    end else
      Ind := K_ErrIndex;
  end;

begin
  BResult := true;
  CVal := VInd;
  if K_mvcUseTime in CompVCond then
    with QVectors[VInd] do begin
      CVal := TimePeriod.SDate;
      BResult := CompareTimeIntervals(  TimePeriod.SDate,
          GetTimePeriodEnd( TimePeriod ),
          CompVTimeBegin, CompVTimeEnd, CompVTimeIsInside );
    end;
  if K_mvcUseTable in CompVCond then begin
    BResult := CompVUDTab = QUDTab[VInd];
  end;

  if K_mvcResCEValue in CompVCond then begin
    GetElemInd;
    if (Ind <> K_ErrIndex) then
      CVal := PDouble(QVectors[VInd].D.P(Ind))^
    else
      CVal := K_MVMinVal;
  end;

  if K_mvcResCERating in CompVCond then begin
    GetElemInd;
    if (Ind <> K_ErrIndex) then
      CVal := QRatings[VInd][Ind]
    else
      CVal := K_MVMinVal;
  end;

  if BResult then
    Result := CVal
  else
    Result := K_MVMinVal;

end; // end of function TK_MVQRVectors.CompareVector

//**************************************** TK_MVQRVectors.PrepareQVSS
//  Prepare Vectors SubSet (for Internal Use)
//
procedure TK_MVQRVectors.PrepareQVSS;
//var i : Integer;
begin
  if QVSS = nil then
  SetLength( QVSS, QVNum );
  K_FillIntArrayByCounter( @QVSS[0], QVNum );
//  for i := 0 to QVNum - 1 do QVSS[i] := i;
end; // end of procedure TK_MVQRVectors.PrepareQVSS

//**************************************** TK_MVQRVectors.SetCurSSElem
//  Set Current SubSet Element (for Internal Use)
//
function TK_MVQRVectors.SetCurSSElem( CSElem: Integer; var VVInds : TN_IArray; SVInd : Integer = 0 ): Integer;
var
  CurVCSS : TK_UDDCSSpace;
  CurVCSInd : Integer;
  i  : Integer;
  WVInd, CurVInd : Integer;
  Val : Double;
begin
  Result := 0;
  CurVCSS := nil;
  CurVInd := -1;
  SetLength( VVInds, QVNum );
  for i := SVInd to QVNum - 1 do begin
    if CurVCSS <> QVectors[i].CSS then begin
// Set Cur Vector CS
      CurVCSS := TK_UDDCSSpace(QVectors[i].CSS);
      if Integer(QCSProjs[i]) = 0 then
        CurVCSInd := -1 // No Projection
      else if Integer(QCSProjs[i]) = 1 then
        CurVCSInd := CSElem // Same Code Space
      else
        CurVCSInd := PInteger(TK_UDVector(QCSProjs[i]).PDE(CSElem))^;
      if CurVCSInd >= 0 then
        CurVInd := K_IndexOfIntegerInRArray( CurVCSInd, PInteger(CurVCSS.PDE(0)),
                    CurVCSS.PDRA.ALength )
      else
        CurVInd := -1;
    end;
    WVInd := K_ErrIndex;
    if CurVInd >= 0 then begin
      Val := PDouble(QVectors[i].D.P(CurVInd))^;
      if (Val < K_MVMaxVal) and (Val > K_MVMinVal) then
        WVInd := CurVInd
      else
        WVInd := -CurVInd - 1;
    end;
    VVInds[i] := WVInd;
    if WVInd >= 0 then Inc(Result);
  end;
end; // end of function TK_MVQRVectors.SetCurSSElem

//**************************************** TK_MVQRVectors.GetTimePeriodEnd
//  Get TimePeriod End TDateTime (for Internal Use)
//
function TK_MVQRVectors.GetTimePeriodEnd( const TP : TK_MVTimePeriod ) : TDateTime;
begin
  Result := 0;
  with TP do
    case PType of
      K_tptYear    : // = "год"
        Result := IncYear(SDate, PLength);
      K_tptHYear   : // = "полугодие"
        Result := IncMonth(SDate, PLength*6);
      K_tptQuarter : // = "квартал"
        Result := IncMonth(SDate, PLength*3);
      K_tptMonth   : // = "месяц"
        Result := IncMonth(SDate, PLength);
      K_tpt10Days  : // = "декада"
        Result := IncDay(SDate, PLength * 10);
      K_tptWeek    : // = "неделя"
        Result := IncDay(SDate, PLength * 7);
      K_tptDay     : // = "день"
        Result := IncDay(SDate, PLength);
      K_tptHour    : // = "час"
        Result := IncHour(SDate, PLength);
      K_tptMinute  : // = "минута"
        Result := IncMinute(SDate, PLength);
      K_tptSecond  : // = "секунда"
        Result := IncSecond(SDate, PLength);
      K_tptMSecond : // = "миллисекунда"
        Result := IncMilliSecond(SDate, PLength);
    end;
end; // end of function TK_MVQRVectors.GetTimePeriodEnd

//**************************************** TK_MVQRVectors.CompareTimeIntervals
//  Compare Time Intervals (for Internal Use)
//
function TK_MVQRVectors.CompareTimeIntervals(
      TCBegin : TDateTime;
      TCEnd   : TDateTime;
      TBegin : TDateTime = 0;
      TEnd   : TDateTime = 0;
      IsInside   : Boolean = true ) : Boolean;
var
  EndAllInside, EndInside, BegInside : Boolean;
begin
  EndAllInside := (TEnd = 0);
  BegInside := (TCBegin >= TBegin) and
               (EndAllInside or (TCBegin <= TEnd));
  EndInside := (TCEnd >= TBegin) and
               (EndAllInside or (TCEnd <= TEnd));

  Result := ( BegInside or EndInside ) and
            ( not IsInside or (BegInside and EndInside) );
end; // end of constructor TK_MVQRVectors.CompareTimeIntervals

{*** end of TK_MVQRVectors ***}

end.
