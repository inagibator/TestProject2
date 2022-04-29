unit K_MVMap0;

//************************************
// MV Map Data Representation Objects
//************************************
interface

uses
  Classes, Windows, Grids, Graphics,
  K_DCSpace, K_Script1, K_UDT1, K_MVObjs, K_Types,
  N_Types, N_BaseF;

//************************************
// MV Map Description - Map VComponent/Data Correspondece
//************************************
type TK_MVMPEPCoordType0 = ( // Map Page Element Position Coords Type
  K_pctPixels,  // = 'Абсолютные пиксельные' - Absolute pixels
  K_pctRPixels, // = 'Пиксельное смещение относительно правой/нижней границы' Pixels Shift from Right/Bottom
  K_pctRelative // = 'Относительные' Relative Part of Page
  );
type TK_MVMPEPCoordType = packed record
    case Integer of
      0: ( T : TK_MVMPEPCoordType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVMPEPCoordType = record

type TK_MVMPageElemPos = packed record   // Page Element Position
  LeftType : TK_MVMPEPCoordType;// Left Coords Type
  Left     : Double;          // Left
  TopType : TK_MVMPEPCoordType;// Top Coords Type
  Top     : Double;          // Top
  RightType : TK_MVMPEPCoordType;// Right Coords Type
  Right     : Double;          // Right
  BottomType : TK_MVMPEPCoordType;// Bottom Coords Type
  Bottom     : Double;          // Bottom
end; //*** end of type TK_MVMPageElemPos = record
type TK_PMVMPageElemPos = ^TK_MVMPageElemPos;

type TK_MVMLayerConvAttrs = packed record   // Map Layer Conv Attributes
  LName         : string; // Map Layer Name
  CoordsFName   : string; // Coords File Name
  LegendDOMName : string; // Layer Legend DOM Name
  LegendPos     : TK_MVMPageElemPos; // Layer Legend Position
  LegendStyle   : string; // Legend Style Attributes - commasepareted list
end; //*** end of type TK_MVMLayerConvAttrs = record
type TK_PMVMLayerConvAttrs = ^TK_MVMLayerConvAttrs;

type TK_MVMapConvAttrs = packed record   // Map Conv Attributes for single Scale
  Width         : Integer; // Page Pixel Width
  Height        : Integer; // Page Pixel Height
  HeaderDOMName : string; // Page Header DOM Name
  HeaderPos     : TK_MVMPageElemPos; // Page Header Position
  MapDOMName    : string; // Page Map DOM Name
  MapPos        : TK_MVMPageElemPos; // Page Map Position
  MapBGFName    : string; // Map Background File Name
  LConvAttrs    : TK_RArray; // Layers Conv Attrs : ArrayOf TK_MVMLayerConvAttrs
end; //*** end of type TK_MVMapConvAttrs = record
type TK_PMVMapConvAttrs = ^TK_MVMapConvAttrs;

type TK_MVMapDescr = packed record   //*** Map Description (*TK_UDMVMapDescr*)
  UDMScreenComp   : TN_UDBase; // Map Screen VComponent
  UDMPrintComps   : TK_RArray; // Map Print VComponents List - ArrayOf TN_UDBase;
  UDMPrintInd     : Integer;   // Map Print VComponents List Index
  UDVCTreeParams  : TN_UDBase; // Map VComponent VCTreeParams Reference
// United Regions Control Attributes (used for Russia SF poligons)
  UDURegsCSS      : TN_UDBase; // United Regions CSS
  UDURegsConstCSS : TN_UDBase; // United Regions Constituents CSS (Regions with same codes as United)
  UDURegsProj     : TN_UDBase; // United Regions on its Constituents Projection
// WEB Scale Maps Convertion Attributes
  ScaleConvAttrs  : TK_RArray; // Map Conv Attrs for All Scales : ArrayOf TK_MVMapConvAttrs
// United Regions Groups Control Attributes (used for Russia FO borders)
  UDMapVisUPars   : TN_UDBase; // Map Layers Visibility Control Params
  UDRegCtrlUPNames: TN_UDBase; // UserParams Names in UDMapVisUPars. UDVector based on Regions CSS. If Region from UDVector is in Data Vector then corresponding user parameter should be set to 1 else to 0
end; //*** end of type TK_MVMapDescr = record
type TK_PMVMapDescr = ^TK_MVMapDescr;

type TK_UDMVMapDescr = class( TK_UDMVWBase )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
end; //*** end of type TK_UDMVMapDescr  = class( TK_UDMVWBase )

type TK_MVMLDataCorr = packed record   //Map/Data Correspondence Attrs
  MLDCCapt : string; // Map/Data Correspondence Caption
  TCSS     : TN_UDBase; // Target Data CSS Reference
  DCSPM     : TN_UDBase; // Data DCS to Map DCS Projection
end; //*** end of type TK_MVMLDataCorr = record
type TK_PMVMLDataCorr = ^TK_MVMLDataCorr;

type TK_MVMLCommonDescr = packed record   //Map Layer Description Common Part
  MLRTypeName : string;    // Map Layer RA Type Name
  MDCorrAttrs : TK_RArray; // Map/Data Correspondence Attrs : ArrayOf TK_MVMLDataCorr;
  VCTLInd     : Integer;   // Layer Index in TN_PVCTreeParams
  UDPrompts   : TN_UDBase; // Layer Elements Prompts UDVector of String Reference (can be undefined)
  UDCapts     : TN_UDBase; // Layer Elements Captions UDVector of String Reference (can be undefined)
  UDValues    : TN_UDBase; // Layer Elements Values UDVector of String Reference (can be undefined)
  UDVAttrs    : TN_UDBase; // Layer Elements View Attributes UDVector of Color Reference
  UDVisFlags  : TN_UDBase; // Layer Elements Visibility UDVector of Bytes Reference
end; //*** end of type TK_MVMLCommonDescr = record
type TK_PMVMLCommonDescr = ^TK_MVMLCommonDescr;

type TK_UDMVMLDescr = class( TK_UDMVWBase )
  function RebuildLayerAttrs( RMLayer : TK_RArray;
                              PMVVAttrs : TK_PMVVAttrs = nil;
                              ASkipRebuildAttrsFlag : Boolean = false;
                              ColorsSchemeInd : Integer = -1;
                              ColorSchemes : TK_RArray = nil ) : Boolean; virtual; abstract;
end; //*** end of type TK_UDMVMLDescr = class( TK_UDMVWBase )

type TK_MVMLDColorFill = packed record   //*** Map Color Fill Layer Description (*TK_UDMVMLDColorFill*)
  MLRTypeName : string;    // Map Layer RA Type Name
  MDCorrAttrs : TK_RArray; // Map/Data Correspondence Attrs : ArrayOf TK_MVMLDataCorr;
  VCTLInd     : Integer;   // Layer Index in TN_PVCTreeParams
  UDPrompts   : TN_UDBase; // Layer Elements Prompts UDVector of String Reference (can be undefined)
  UDCapts     : TN_UDBase; // Layer Elements Captions UDVector of String Reference (can be undefined)
  UDValues    : TN_UDBase; // Layer Elements Values UDVector of String Reference (can be undefined)
  UDColors    : TN_UDBase; // Layer Elements Values UDVector of Color Reference
  UDVisFlags  : TN_UDBase; // Layer Elements Visibility UDVector of Bytes Reference
// end of TK_MVMLCommonDescr
end; //*** end of type TK_MVMLayerDescr = record
type TK_PMVMLDColorFill = ^TK_MVMLDColorFill;

type TK_UDMVMLDColorFill = class( TK_UDMVMLDescr )
  constructor Create; override;
  function RebuildLayerAttrs( RMLayer : TK_RArray;
                              PMVVAttrs : TK_PMVVAttrs = nil;
                              ASkipRebuildAttrsFlag : Boolean = false;
                              ColorsSchemeInd : Integer = -1;
                              AColorSchemes : TK_RArray = nil ) : Boolean; override;
end; //*** end of type TK_UDMVMLDColorFill = class( TK_UDMVMLDescr  )

//************************************
// MV Web Map Cartograms
//************************************
type TK_MVWebCartWin = packed record   //*** Web Map Cartogram Window (*TK_UDMVWCartWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Attributes
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  WCWUDMapDescr   : TN_UDBase; // Map Description Reference (TK_UDMVMapDescr)
  PageCaption : string;       // Layer Elements Captions UDVector of String Reference (can be undefined)
end; //*** end of type TK_MVWebCartWin = record
type TK_PMVWebCartWin = ^TK_MVWebCartWin;

type TK_UDMVWCartWin = class( TK_UDMVWBase )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function    AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function    SelfCopy( CopyPar : TK_CopySubTreeFlags = [] ) : TN_UDBase; override;
  procedure   RebuildMapAttrs( PMVVAttrs : TK_PMVVAttrs = nil;
                               ASkipRebuildAttrsFlag : Boolean = false;
                               ColorsSchemeInd : Integer = -1;
                               ColorSchemes : TK_RArray = nil  );
  function    GetLayerUDVector( LayerInd : Integer ) : TN_UDBase;
  function    GetLayerUDVAttrs( LayerInd : Integer ) : TN_UDBase;
  function    GetLayerPMVRCSAttrs( LayerInd : Integer ) : TK_PMVRCSAttrs;
  function    GetCorUDMVWCartWinObj(  ) : TK_UDMVWLDiagramWin;
end; //*** end of type TK_UDMVWCartWin  = class( TK_UDMVWBase )

type TK_MVWebCartGroupWin = packed record   //*** Web Map Cartogram Group Window (*TK_UDMVWCartGroupWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Attributes
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  MVWinName  : string;    // Maps Virtual Window Attributes Name
end; //*** end of type TK_MVWebCartWin = record
type TK_PMVWebCartGroupWin = ^TK_MVWebCartGroupWin;

type TK_UDMVWCartGroupWin = class( TK_UDMVWBase )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function    AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function    DeleteSubTreeChild( Index : Integer ) : Boolean; override;
end; //*** end of type TK_UDMVWCartGroupWin  = class( TK_UDMVWBase )

type TK_MVCLCommon = packed record   //Web Map Cartogram Layer Common
  UDMLDescr   : TN_UDBase; // Map Layer Description Reference (TK_UDMVMapDescr)
  DCSP  : TN_UDBase; // Data DCS to Map DCS Projection
  LegHeader : string; // Legend Header
  LegFooter : string; // Legend Footer
  // Legend Element Layout Attrs
  LERowNum : Integer; // Legend Rows Number (=0 auto defined)
  LEColNum : Integer; // Legend Columns Number (=0 auto defined)
end; //*** end of type TK_MVCLCommon = record
type TK_PMVCLCommon = ^TK_MVCLCommon;

type TK_MVCartLayer1 = packed record   //*** Web Map Cartogram Layer for single Vector (*TK_UDMVWCartWin*)
  UDMLDescr : TN_UDBase; // Map Layer Description Reference (TK_UDMVMLDescr)
  DCSPML    : TN_UDBase; // Data DCS to Map DCS Projection
  LegHeader : string; // Legend Header
  LegFooter : string; // Legend Footer
  // Legend Element Layout Attrs
  LERowNum : Integer; // Legend Rows Number (=0 auto defined)
  LEColNum : Integer; // Legend Columns Number (=0 auto defined)
// end of type TK_MVCLCommon
  UDMVVector : TN_UDBase; // Data Vector Reference (TK_UDMVVector)
  UDMVVAttrs : TN_UDBase; // View Attrs Reference (TK_UDMVVAttrs)
  AttrsInd   : Integer;   // Index in TK_MVVAttrs Array of UDMVVAttrs
  CLUDMVTable  : TN_UDBase; // (Not Used Now) Data Vector Table Reference (TK_UDMVTable) - for Vector and Attribs Editing
end; //*** end of type TK_MVCartLayer1 = record
type TK_PMVCartLayer1 = ^TK_MVCartLayer1;

type TK_UDMVWCartLayer = class( TK_UDMVWBase )
  constructor Create; override;
end; //*** end of type TK_UDMVWCartLayer  = class( TK_UDMVWBase )

type TK_PrepCartCompContext = class(TK_PrepCompContext)
  CCPColorSchemes : TK_RArray;
  CCPRAMVAttrs : TK_RArray;
  CCPUDMVWCartWin : TK_UDMVWCartWin;
  CCPUDColorMask : TK_UDVector;
  constructor Create;
  destructor  Destroy; override;
  procedure SetContext(); override;
  procedure BuildSelfAttrs(); override;
  procedure BuildHints( var ShowHints : TN_SArray ); override;
  procedure PrepFormActivateParams( var Params ); override;
end;

function  K_MVMCartogramCreate( BaseMap : TN_UDBase ) : TK_UDRArray;
procedure K_BuildWCartsCompsJoin( WCarts : TK_RArray; VCList : TStrings );
procedure K_BuildWCartsCompsIntersection( WCarts : TK_RArray; VCList : TStrings );
function  K_CheckWCartsCompsIdentity( WCarts : TK_RArray ): Boolean;
procedure K_ViewMVWCart( UDMVWCart : TN_UDBase; AOwner: TN_BaseForm;
                         ColorSchemeInd : Integer; ColorSchemes : TK_RArray );

implementation

uses
  SysUtils, Dialogs, Math,
  K_CLib0, K_CLib, K_IMVDar, K_VFunc, K_FViewComp, K_IndGlobal, K_UDT2,
  N_ME1, N_ClassRef, N_RVCTF, N_CompBase, N_Rast1Fr, N_Lib2;

{*** TK_UDMVMapDescr ***}

//********************************************** TK_UDMVMapDescr.Create
//
constructor TK_UDMVMapDescr.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVMapDescrCI;
  ImgInd := 74;
end;

//********************************************** TK_UDMVMapDescr.CanAddChildByPar
//
function TK_UDMVMapDescr.CanAddChildByPar(AddPar: Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdMLDColorFills : Result := true;
  else
    Result := false;
  end;
end;

{*** end of TK_UDMVMapDescr ***}

{*** TK_UDMVMLDColorFill ***}
//********************************************** TK_UDMVMLDColorFill.Create
//
constructor TK_UDMVMLDColorFill.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVMLDColorFillCI;
  ImgInd := 75;
end;

{
//********************************************** TK_UDMVMLDColorFill.RebuildLayerAttrs
//
function TK_UDMVMLDColorFill.RebuildLayerAttrs( RMLayer : TK_RArray ) : Boolean;
var
  MVVector : TK_UDVector;
  PWData : PDouble;
  PData : PDouble;
  PScale : PDouble;
  ScaleHigh : Integer;
  WData : TN_DArray;
  SWInds : TN_IArray;
  WInds : TN_IArray;
  WColors : TN_IArray;
  WSValues : TN_SArray;
  CIndexes : TN_IArray;
  UDDataSSpace, UDCLSSpace : TK_UDDCSSpace;
  LegNElems, MLeng, DLeng : Integer;
  MapParams : TK_UDRArray;
  PVCTreeParams : TN_PVCTreeParams;
  i, n : Integer;
  SVA : TK_SpecValsAssistant;
  PMVVAttrs : TK_PMVVAttrs;
  PMVCartLayer1 : TK_PMVCartLayer1;
  PMVMLDColorFill : TK_PMVMLDColorFill;
  AbsValColor : Integer;
  AbsValText : string;
  RangeText : string;
  WList : TStringList;
  IWW : Integer;
  SWW : string;

label LExit;
begin
  Result := false;
  if K_GetExecTypeName( RMLayer.ElemType.All ) <> 'TK_MVCartLayer1' then begin
    ShowMessage( 'Неверный тип слоя картограммы' );
    Exit;
  end;
  PMVCartLayer1 := TK_PMVCartLayer1(RMLayer.P);
  with PMVCartLayer1^ do begin
    if (UDMVVAttrs = nil) or not UDMVVAttrs.IsSPLType('TK_MVVAttrs') then begin
      ShowMessage( 'Не заданы атрибуты вектора' );
      Exit;
    end;
    PMVMLDColorFill := TK_PMVMLDColorFill(R.P);
    PMVVAttrs := TK_PMVVAttrs(TK_UDRArray(UDMVVAttrs).R.P(AttrsInd));
    with PMVMLDColorFill^, PMVVAttrs^ do begin
      MVVector := TK_UDVector(UDMVVector);
      PData := PDouble( MVVector.DP );
      UDDataSSpace := MVVector.GetDCSSpace;
      if AnSECSS <> nil then begin
      //*** Build Data SubArray if Analisys CSS Exists
        DLeng := TK_UDDCSSpace(AnSECSS).PDRA.ALength;
        SetLength( CIndexes, DLeng );
        if not K_BuildDataProjection( UDDataSSpace, TK_UDDCSSpace(AnSECSS), @CIndexes[0], nil ) then Exit;
        SetLength( WData, DLeng );
        PData := @WData[0];
        K_MoveVectorBySIndex( WData[0], SizeOf(Double),
                             MVVector.DP^, SizeOf(Double), SizeOf(Double),
                             DLeng, @CIndexes[0] );
        UDDataSSpace := TK_UDDCSSpace(AnSECSS);
      end;

      DLeng := UDDataSSpace.PDRA.ALength;
      SetLength( WInds, DLeng );
      PScale := PDouble(RangeValues.P);
      ScaleHigh := RangeValues.AHigh;
      SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
      SetLength( SWInds, SVA.ScaleHigh + 1 );
      PWData := PData;
    //*** Build Scale Indexes Vector:
    //  n < 0  - SpecialValues Index - 1
    //  n >= 0 - RangeColors Index
      for i := 0 to DLeng - 1 do begin
        n := SVA.GetSpecValInd( PWData^ );
        if n >= 0 then begin
    //*** Spec Value
          WInds[i] := -n - 1;
          SWInds[n] := 1;  // Used Special Value Flag
          Inc(PWData);
          Continue;
        end;
    //*** Not Spec Value
        n := K_IndexOfDoubleInScale( PScale, ScaleHigh, sizeof(Double), PWData^ );
        if (n > 0) and (ValueType.T = K_vdtDiscrete) then Dec(n);
        WInds[i] := n;
        Inc(PWData);
      end;

      if (UDColors = nil) or not (UDColors is TK_UDVector) then begin
        ShowMessage( 'Отсутствует вектор цвета' );
        goto LExit;
      end;

    //*** Build Colors Vector:
      SetLength( WColors, DLeng );
      for i := 0 to High(WColors) do begin
        n := WInds[i];
        if n < 0 then // Spec Value
          WColors[i] := SVA.GetSpecValAttrs( -n + 1 ).Color
        else          // Ordinary Value
          WColors[i] := PInteger( RangeColors.P(n) )^;
      end;

    //*** Set Map Colors from Colors Vector:
      UDCLSSpace := TK_UDVector(UDColors).GetDCSSpace;
      MLeng := UDCLSSpace.PDRA^.ALength;
      SetLength( CIndexes, MLeng );
      for i := 0 to MLeng - 1 do CIndexes[i] := -1; // set CIndexes with absent values flag
      if K_BuildDataProjection( UDDataSSpace, UDCLSSpace, @CIndexes[0], TK_UDVector(DCSP) ) then begin
        K_MoveVectorBySIndex( TK_UDVector(UDColors).DP^, SizeOf( Integer ),
                         WColors[0], SizeOf( Integer ), SizeOf( Integer ),
                               MLeng, @CIndexes[0] );
      end;
    //*** Set Map Colors with Absent Values
      AbsValColor := SVA.GetSpecValAttrs( AbsDCSESVIndex ).Color;
      for i := 0 to MLeng - 1 do begin
        if CIndexes[i] >= 0 then Continue;
        PInteger(TK_UDVector(UDColors).DP(i))^ := AbsValColor;
        SWInds[AbsDCSESVIndex] := 1;  // Used Special Value Flag
      end;

      if (UDValues <> nil) and (UDValues is TK_UDVector) then begin
    //*** Set Text Values Vector:
        UDCLSSpace := TK_UDVector(UDValues).GetDCSSpace;
        MLeng := UDCLSSpace.PDRA^.ALength;
        SetLength( CIndexes, MLeng );
        for i := 0 to MLeng - 1 do CIndexes[i] := -1; // set CIndexes with absent values flag
        if K_BuildDataProjection( UDDataSSpace, UDCLSSpace, @CIndexes[0], TK_UDVector(DCSP) ) then begin
          SetLength( WSValues, DLeng );
          PWData := PData;
          WList := TStringList.Create;
          WList.Add('Units='+TK_PMVVector(MVVector.R.P).Units);
          WList.Add('Name=');
          WList.Add('Range=');
          WList.Add('Value=');
          for i := 0 to High(WSValues) do begin
            if ElemCapts <> nil then begin
              IWW := PInteger(UDDataSSpace.DP(i))^;
              SWW := PString(TK_UDVector(ElemCapts).DP(IWW))^;
              WList[1] := 'Name='+SWW;
//              WList[1] := 'Name='+PString(TK_UDVector(ElemCapts).DP( PInteger(UDDataSSpace.DP(i))^ ))^;
            end;
            n := WInds[i];
            if n < 0 then // Spec Value
              RangeText := SVA.GetSpecValAttrs( -n + 1 ).Caption
            else     // Ordinary Value
              RangeText := PString(RangeCaptions.P(n))^;
            WList[2] := 'Range='+RangeText;
            if n >= 0 then begin // Ordinary  Value
              if VFormat <> '' then
                RangeText := format( VFormat, [PWData^])
              else
                RangeText := format('%.*f', [VDPPos, PWData^]);
            end;
            WList[3] := 'Value='+RangeText;
            WSValues[i] := K_StringMListReplace(
              PureValToTextPat, WList, K_ummRemoveMacro );
            Inc(PWData);
          end;
          WList.Free;
          K_MoveSPLVectorBySIndex( TK_UDVector(UDValues).DP^, SizeOf(string),
                              WSValues[0], SizeOf(string), MLeng,
                              Ord(nptString), [K_mdfFreeDest], @CIndexes[0] );
        end;
    //*** Set Values Texts with Absent Values
        AbsValText := SVA.GetSpecValAttrs( AbsDCSESVIndex ).Caption;
        for i := 0 to MLeng - 1 do begin
          if CIndexes[i] >= 0 then Continue;
          PString(TK_UDVector(UDValues).DP(i))^ := AbsValText;
          SWInds[AbsDCSESVIndex] := 1;  // Used Special Value Flag
        end;
      end;

      MapParams := TK_UDRArray(TK_PMVMapDescr(TK_UDRArray(Owner).R.P).UDVCTreeParams);
      if MapParams = nil then begin
        ShowMessage( 'Отсутствует набор параметров' );
        goto LExit;
      end;
      PVCTreeParams := TN_PVCTreeParams(MapParams.R.P);
      with PVCTreeParams^ do
        with TN_PCTLVar1( TN_PVCTreeLayer( PVCTreeParams.VCTLayers.P(VCTLInd)).VCTLParams.P )^ do begin
          V1LegendHeaderText := LegHeader;
          V1LegendFooterText := LegFooter;

          LegNElems := SVA.ScaleHigh + 1 + RangeColors.ALength;
          V1LegElemColors.ASetLength(LegNElems);
          V1LegElemTexts.ASetLength(LegNElems);

        //***  Add SpecValues Before Main Scale
          LegNElems := 0;
          for i := 0 to SVA.ScaleHigh do
            with SVA.GetSpecValAttrs( i )^ do begin
              if ( (SWInds[i] <> 0) or ( K_svlAlways in LegShowFlags.T ) ) and
                 not ( K_svlAfter in LegShowFlags.T ) then begin
                PInteger(V1LegElemColors.P(LegNElems))^ := Color;
                PString(V1LegElemTexts.P(LegNElems))^ := Caption;
                Inc(LegNElems);
              end;
            end;
        //*** Add Main Scale
          for i := 0 to RangeColors.AHigh do begin
            PInteger(V1LegElemColors.P(LegNElems))^ := PInteger(RangeColors.P(i))^;
            PString(V1LegElemTexts.P(LegNElems))^ := PString(RangeCaptions.P(i))^;
            Inc(LegNElems);
          end;

        //***  Add SpecValues After Main Scale
          for i := 0 to SVA.ScaleHigh do
            with SVA.GetSpecValAttrs( i )^ do
              if ( (SWInds[i] <> 0) or ( K_svlAlways in LegShowFlags.T ) ) and
                 ( K_svlAfter in LegShowFlags.T ) then begin
                PInteger(V1LegElemColors.P(LegNElems))^ := Color;
                PString(V1LegElemTexts.P(LegNElems))^ := Caption;
                Inc(LegNElems);
              end;
          V1LegElemColors.ASetLength(LegNElems);
          V1LegElemTexts.ASetLength(LegNElems);
        end;
    end;
  end;
LExit:
  SVA.Free;
end;
}

//********************************************** TK_UDMVMLDColorFill.RebuildLayerAttrs
//
function TK_UDMVMLDColorFill.RebuildLayerAttrs( RMLayer : TK_RArray;
                                                PMVVAttrs : TK_PMVVAttrs = nil;
                                                ASkipRebuildAttrsFlag : Boolean = false;
                                                ColorsSchemeInd : Integer = -1;
                                                AColorSchemes : TK_RArray = nil ) : Boolean;
var
  MVVector : TK_UDVector;
  PData : PDouble;
  WData : TN_DArray;
  SWInds : TN_IArray;
  WColors : TN_IArray;
  WSValues : TN_SArray;
  CIndexes : TN_IArray;
  CVIndexes : TN_IArray;
  UDDataSSpace, UDCLSSpace, UDVisSSpace : TK_UDDCSSpace;
  LegNElems, MLeng, DLeng : Integer;
  MapParams : TK_UDRArray;
  PVCTreeParams : TN_PVCTreeParams;
  i : Integer;
  SVA : TK_SpecValsAssistant;
//  PMVVAttrs : TK_PMVVAttrs;
  PMVCartLayer1 : TK_PMVCartLayer1;
  PMVMLDColorFill : TK_PMVMLDColorFill;
  AbsValColor : Integer;
  AbsValText : string;

  PTextValues, PUPNames : PString;
  PUPNCSSInds, PDataCSSInds : PInteger;
  PUPData : PByte;
  PUP: TN_POneUserParam;

label LExit;
begin
  Result := false;
  if K_GetExecTypeName( RMLayer.ElemType.All ) <> 'TK_MVCartLayer1' then begin
    K_ShowMessage( 'Неверный тип слоя картограммы' );
    Exit;
  end;
  PMVCartLayer1 := TK_PMVCartLayer1(RMLayer.P);
  with PMVCartLayer1^ do begin
    if PMVVAttrs = nil then begin
      if (UDMVVAttrs = nil) or not UDMVVAttrs.IsSPLType('TK_MVVAttrs') then begin
        K_ShowMessage( 'Не заданы атрибуты вектора' );
        Exit;
      end;
      PMVVAttrs := TK_PMVVAttrs(TK_UDRArray(UDMVVAttrs).R.P(AttrsInd));
    end;
    PMVMLDColorFill := TK_PMVMLDColorFill(R.P);
    with PMVMLDColorFill^, PMVVAttrs^ do begin
      if (UDColors = nil) or not (UDColors is TK_UDVector) then begin
        K_ShowMessage( 'Отсутствует вектор цвета' );
        goto LExit;
      end;

      UDVisSSpace := nil;
      if (UDVisFlags <> nil) and
         (UDURegVisCSS <> nil) then
      // Build Visibility Vector
        with TK_UDRArray(UDVisFlags) do begin
          MLeng := PDRA.ALength;
          UDVisSSpace := TK_UDVector(UDVisFlags).GetDCSSpace;
          SetLength( CIndexes, MLeng );
          for i := 0 to MLeng - 1 do CIndexes[i] := -1; // set CIndexes with absent values flag
          if K_BuildDataProjectionByCSProj( TK_UDDCSSpace(UDURegVisCSS),
                 UDVisSSpace, @CIndexes[0], TK_UDVector(DCSPML) ) then begin
            FillChar( PDE(0)^, MLeng, 0 );         // Set Invisible Flags to All
            i := 255;                              // Set Visible Flags to Visible
            K_MoveVectorBySIndex( TK_UDVector(UDVisFlags).DP^, SizeOf( Byte ),
                                  i, 0, SizeOf( Byte ),
                                  MLeng, @CIndexes[0] );
          end;
        end;

      MVVector := TK_UDVector(UDMVVector);
      if not ASkipRebuildAttrsFlag then
//        K_RebuildMVAttribs( PMVVAttrs^, TK_PMVVector(MVVector.R.P).D,
        K_RebuildMVAttribs( PMVVAttrs^, TK_PMVVector(MVVector.R.P),
                            ColorsSchemeInd, AColorSchemes );

      PData := PDouble( MVVector.DP );
      UDDataSSpace := MVVector.GetDCSSpace;
      if AnSECSS <> nil then begin
      //*** Build Data SubArray if CSS for Data analysis Exists
        DLeng := TK_UDDCSSpace(AnSECSS).PDRA.ALength;
        SetLength( CIndexes, DLeng );
        if not K_BuildDataProjectionByCSProj( UDDataSSpace, TK_UDDCSSpace(AnSECSS), @CIndexes[0], nil ) then Exit;
        SetLength( WData, DLeng );
        PData := @WData[0];
        K_MoveVectorBySIndex( WData[0], SizeOf(Double),
                              MVVector.DP^, SizeOf(Double), SizeOf(Double),
                              DLeng, @CIndexes[0] );
        UDDataSSpace := TK_UDDCSSpace(AnSECSS);
      end;

      DLeng := UDDataSSpace.PDRA.ALength;
      SetLength( WColors, DLeng );
      PTextValues := nil;
      if (UDValues <> nil) and (UDValues is TK_UDVector) then begin
        SetLength( WSValues, DLeng );
        PTextValues := @WSValues[0];
      end;
      SVA := nil;
      K_BuildMVVElemsVAttribs( PData, DLeng, PMVVAttrs,
                  UDDataSSpace.DP, PTextValues, nil,
                  @WColors[0], @SWInds, @SVA, TK_PMVVector(MVVector.R.P).Units );

      // Apply Group Colors Change Info
      if (K_GroupRegDCSInd >= 0) and
         (K_GroupRegDCSProj <> nil) and
         (UDDataSSpace.GetDCSpace() = K_GroupRegDCSpace) then
      begin
        SetLength( CVIndexes, DLeng );
        // Set CVIndexes by Proj Data
        K_MoveVectorBySIndex( CVIndexes[0], SizeOf( Integer ),
                             TK_UDVector(K_GroupRegDCSProj).DP^, SizeOf( Integer ),
                             SizeOf( Integer ), DLeng, UDDataSSpace.DP );

        // Change Colors
        for i := 0 to DLeng - 1 do
          if CVIndexes[i] <> K_GroupRegDCSInd then
            WColors[i] := K_GroupRegColor;
      end;

      if SVA = nil then begin
        SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
        SetLength( SWInds, SVA.ScaleHigh + 1 );
      end;
    //*** Set Map Colors from Colors Vector:
      UDCLSSpace := TK_UDVector(UDColors).GetDCSSpace;
      MLeng := UDCLSSpace.PDRA^.ALength;
      SetLength( CIndexes, MLeng );
      for i := 0 to MLeng - 1 do CIndexes[i] := -1; // set CIndexes with absent values flag
      if K_BuildDataProjectionByCSProj( UDDataSSpace, UDCLSSpace, @CIndexes[0], TK_UDVector(DCSPML) ) then begin
        K_MoveVectorBySIndex( TK_UDVector(UDColors).DP^, SizeOf( Integer ),
                         WColors[0], SizeOf( Integer ), SizeOf( Integer ),
                               MLeng, @CIndexes[0] );
      end;

    //*** Set Colors Vector to Visibility Vector corresponding indexes
      if UDVisSSpace <> nil then begin
        SetLength( CVIndexes, MLeng );
        K_BuildDataProjectionByCSProj( UDVisSSpace, UDCLSSpace, @CVIndexes[0], nil );
      end;

    //*** Set Map Colors with Absent Values
      AbsValColor := SVA.GetSpecValAttrs( AbsDCSESVIndex ).Color;
      for i := 0 to MLeng - 1 do begin
//        if CIndexes[i] >= 0 then Continue;
        if (CIndexes[i] >= 0) or        // Map Element has corresponding Data Element
           ( (UDVisSSpace <> nil) and   // Map Element is not visible
             (CVIndexes[i] >= 0)  and
             (PByte((TN_BytesPtr(TK_UDVector(UDVisFlags).DP) + CVIndexes[i]))^ = 0) ) then Continue;
        PInteger(TK_UDVector(UDColors).DP(i))^ := AbsValColor;
        SWInds[AbsDCSESVIndex] := 1;  // Used Special Value Flag
      end;

      if PTextValues <> nil then begin
    //*** Set Text Values Vector:
        UDCLSSpace := TK_UDVector(UDValues).GetDCSSpace;
        MLeng := UDCLSSpace.PDRA^.ALength;
        SetLength( CIndexes, MLeng );
        for i := 0 to MLeng - 1 do CIndexes[i] := -1; // set CIndexes with absent values flag
        if K_BuildDataProjectionByCSProj( UDDataSSpace, UDCLSSpace, @CIndexes[0], TK_UDVector(DCSPML) ) then begin
          K_MoveSPLVectorBySIndex( TK_UDVector(UDValues).DP^, SizeOf(string),
                              WSValues[0], SizeOf(string), MLeng,
                              Ord(nptString), [K_mdfFreeDest], @CIndexes[0] );
        end;

      //*** Set Texts Vector to Visibility Vector corresponding indexes
        if UDVisSSpace <> nil then begin
          SetLength( CVIndexes, MLeng );
          K_BuildDataProjectionByCSProj( UDVisSSpace, UDCLSSpace, @CVIndexes[0], nil );
        end;

      //*** Set Values Texts with Absent Values
        AbsValText := SVA.GetSpecValAttrs( AbsDCSESVIndex ).Caption;
        for i := 0 to MLeng - 1 do begin
//          if CIndexes[i] >= 0 then Continue;
          if (CIndexes[i] >= 0) or        // Map Element has corresponding Data Element
             ( (UDVisSSpace <> nil) and   // Map Element is not visible
               (CVIndexes[i] >= 0)  and
               (PByte((TN_BytesPtr(TK_UDVector(UDVisFlags).DP) + CVIndexes[i]))^ = 0) ) then Continue;
          PString(TK_UDVector(UDValues).DP(i))^ := AbsValText;
          SWInds[AbsDCSESVIndex] := 1;  // Used Special Value Flag
        end;
      end;

      with TK_PMVMapDescr(TK_UDRArray(Owner).R.P)^ do
      begin

        if (UDMapVisUPars <> nil) and (UDRegCtrlUPNames <> nil) then
        begin // Map Layers Visibility Control
          with TK_UDVector(UDRegCtrlUPNames) do
          begin
            PUPNames := PDE(0);
            PUPNCSSInds := GetDCSSpace().PDE(0);
            PDataCSSInds := UDDataSSpace.PDE(0);
            DLeng := UDDataSSpace.PDRA.ALength;
            for i := 0 to PDRA.AHigh do
            begin
              PUP := N_GetUserParPtr( TK_UDRarray(UDMapVisUPars).R, PUPNames^ );
              if PUP <> nil then
              begin
              // Parameter with given Name Exists - Set UPValue
                PUPData := PUP^.UPValue.P;
                if -1 = K_IndexOfIntegerInRArray( PUPNCSSInds^,  PDataCSSInds, DLeng ) then
                  PUPData^ := 0  // Element is absent in Data Vector
                else
                  PUPData^ := 1; // Element exists in Data Vector
              end;
              Inc(PUPNCSSInds);
              Inc(PUPNames);
            end;
          end;

        end;

        MapParams := TK_UDRArray(UDVCTreeParams);
        if MapParams = nil then begin
          K_ShowMessage( 'Отсутствует набор параметров' );
          goto LExit;
        end;

      end;

      // Map Legend Build
      PVCTreeParams := TN_PVCTreeParams(MapParams.R.P);
//      with PVCTreeParams^ do
      with TN_PCTLVar1( TN_PVCTreeLayer( PVCTreeParams.VCTLayers.P(VCTLInd)).VCTLParams.P )^ do
      begin
        V1LegendHeaderText := LegHeader;
        V1LegendFooterText := LegFooter;

        LegNElems := SVA.ScaleHigh + 1 + RangeColors.ALength;
        V1LegElemColors.ASetLength(LegNElems);
        V1LegElemTexts.ASetLength(LegNElems);

      //***  Add SpecValues Before Main Scale
        LegNElems := 0;
        for i := 0 to SVA.ScaleHigh do
          with SVA.GetSpecValAttrs( i )^ do begin
            if ( (SWInds[i] <> 0) or ( K_svlAlways in LegShowFlags.T ) ) and
               not ( K_svlAfter in LegShowFlags.T ) then begin
              PInteger(V1LegElemColors.P(LegNElems))^ := Color;
              PString(V1LegElemTexts.P(LegNElems))^ := Caption;
              Inc(LegNElems);
            end;
          end;
      //*** Add Main Scale
        for i := 0 to RangeColors.AHigh do begin
          PInteger(V1LegElemColors.P(LegNElems))^ := PInteger(RangeColors.P(i))^;
          PString(V1LegElemTexts.P(LegNElems))^ := PString(RangeCaptions.P(i))^;
          Inc(LegNElems);
        end;

      //***  Add SpecValues After Main Scale
        for i := 0 to SVA.ScaleHigh do
          with SVA.GetSpecValAttrs( i )^ do
            if ( (SWInds[i] <> 0) or ( K_svlAlways in LegShowFlags.T ) ) and
               ( K_svlAfter in LegShowFlags.T ) then begin
              PInteger(V1LegElemColors.P(LegNElems))^ := Color;
              PString(V1LegElemTexts.P(LegNElems))^ := Caption;
              Inc(LegNElems);
            end;
        V1LegElemColors.ASetLength(LegNElems);
        V1LegElemTexts.ASetLength(LegNElems);
      end;

    end;
  end;
LExit:
  SVA.Free;
end;

{*** end of TK_UDMVMLDColorFill ***}

{*** TK_UDMVWCartWin ***}

//********************************************** TK_UDMVWCartWin.Create
//
constructor TK_UDMVWCartWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWCartWinCI;
  ImgInd := 67;
end;

//********************************************** TK_UDMVWCartWin.CanAddChildByPar
//
function TK_UDMVWCartWin.CanAddChildByPar(AddPar: Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdMVVectors : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVWCartWin.AddChildToSubTree
//
function TK_UDMVWCartWin.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
var
  ObjSysType : TK_MVDARSysType;
  i,h,j,k,m,n: Integer;
  UDMapDescr : TN_UDBase;
  MCSS, VCSS : TK_UDDCSSpace;
  CorrAttrs : TK_RArray;
  MLDescr : TN_UDBase;
  DataCorr : TK_MVMLDataCorr;
  DProj : TN_IArray;
  DLeng : Integer;
  MLayer  : TN_UDBase;
  Folder, MVTable : TN_UDBase;
  FInd : Integer;
  PMVWebCartWin : TK_PMVWebCartWin;

begin
  Result := true;
  if PDE = nil then Exit;
  Result := false;
  with PDE^ do begin
    ObjSysType := K_MVDarGetUserNodeType( Child );
    if not CanAddChildByPar( Ord(ObjSysType) ) then Exit;
//*** Place New Layer Using Vector
    PMVWebCartWin := TK_PMVWebCartWin(R.P);
    UDMapDescr := PMVWebCartWin.WCWUDMapDescr;
//*** Search for Available Layer Description
    VCSS := TK_UDVector(Child).GetDCSSpace;
    h := UDMapDescr.DirHigh;
    for i := 0 to h do begin
      MLDescr := UDMapDescr.DirChild(i);
      with TK_PMVMLCommonDescr(TK_UDRArray(MLDescr).R.P)^ do begin
        CorrAttrs := MDCorrAttrs;
        MCSS := TK_UDVector(UDVAttrs).GetDCSSpace;
        DLeng := MCSS.PDRA.ALength;
        k := CorrAttrs.AHigh;
        for j := 0 to k do begin
          DataCorr := TK_PMVMLDataCorr(CorrAttrs.P(j))^;
          SetLength( DProj, DLeng );
          if K_BuildDataProjectionByCSProj( VCSS, MCSS, @DProj[0], TK_UDVector(DataCorr.DCSPM) ) and
             (K_CalcProjectionIndexes( @DProj[0], DLeng ) > 0) then begin
   //*** Available Layer Description is found - search if this layer is already used
            Result := true;
            m := -1;
            for n := 0 to DirHigh do
              if TK_PMVCartLayer1(TK_UDRArray(DirChild(n)).R.P).UDMLDescr = MLDescr then
                m := n;
            if m < 0 then begin // Add New Map Layer
              m := DirLength;
              AddOneChildV( K_CreateUDByRTypeName( MLRTypeName, 1, K_UDMVWCartLayerCI ) );
            end;
            MLayer := DirChild(m);
            MLayer.ObjAliase := Child.ObjAliase;
            K_SetChildUniqNames( Self, MLayer, K_msdWCartLayers );
            MLayer.RebuildVNodes();
            with TK_PMVCartLayer1(TK_UDRArray(MLayer).R.P)^ do begin
              if UDMVVector = Child then Exit; // Same MVVector
              if m = 0 then
              //*** Init Cartogram Captions
                with TK_PMVVector(TK_UDRArray(Child).R.P)^ do begin
                  PMVWebCartWin.FullCapt := FullCapt;
                  PMVWebCartWin.BriefCapt := BriefCapt;
                  PMVWebCartWin.PageCaption := FullCapt;
                  PMVWebCartWin.Title := FullCapt;
                  if ObjAliase = '' then ObjAliase := FullCapt;
                end;
              //*** Fill MLayer Fields
              K_SetUDRefField( UDMLDescr, MLDescr );
              K_SetUDRefField( DCSPML, DataCorr.DCSPM );
              K_SetUDRefField( UDMVVector, Child );
              MVTable := Parent.Owner;
              K_SetUDRefField( UDMVVAttrs, MVTable.DirChild(1).DirChild(DirIndex) );
              if (MVTable.DirChild(0) <> UDMVVector.Owner) and
                 (MVTable.DirChild(1) <> UDMVVAttrs.Owner) then begin
              //*** Select Owner Table
                Folder := UDMVVector.Owner.Owner;
                FInd := Folder.DirChild(0).IndexOfDEField(UDMVVector);
                if Folder.DirChild(1).DirChild(FInd) <> UDMVVAttrs then begin
//!! Close lines because of closing K_SetUDRefField( CLUDMVTable, MVTable );
//!!                  Folder := UDMVVAttrs.Owner.Owner;
//!!                  FInd := Folder.DirChild(1).IndexOfDEField(UDMVVAttrs);
//!!                  if Folder.DirChild(0).DirChild(FInd) <> UDMVVector then FInd := -1;
                end;
//!!                if FInd <> -1 then MVTable := Folder;
              end;
//              K_SetUDRefField( CLUDMVTable, MVTable );
            end;
            Exit;
          end; // end if Map/Data projection is build and not empty
        end; // end for loop - check MLDescription Map/Data Correspondence Attrs
      end; // end with MLDescription
    end; // end for loop - check MapDescription Layers
  end; // end with Adding DE
end;

//********************************************** TK_UDMVWCartWin.SelfCopy
//
function TK_UDMVWCartWin.SelfCopy(CopyPar: TK_CopySubTreeFlags): TN_UDBase;
var
  i, h : Integer;
begin
  Result := Self;
  if CopyPar = [] then Exit;
  Result := Clone;
  h := DirHigh;
  for i := 0 to h do
    Result.AddOneChildV( DirChild(i).Clone );
end;

//********************************************** TK_UDMVWCartWin.RebuildMapAttrs
//
procedure TK_UDMVWCartWin.RebuildMapAttrs( PMVVAttrs : TK_PMVVAttrs = nil;
                                           ASkipRebuildAttrsFlag : Boolean = false;
                                           ColorsSchemeInd : Integer = -1;
                                           ColorSchemes : TK_RArray = nil  );
var
  i, h : Integer;
  MapParams : TK_UDRArray;
begin
  with TK_PMVWebCartWin(R.P)^ do begin
    MapParams := TK_UDRArray(TK_PMVMapDescr(TK_UDMVMapDescr(WCWUDMapDescr).R.P).UDVCTreeParams);
    if MapParams = nil then begin
      K_ShowMessage( 'Отсутствует набор параметров' );
      Exit;
    end;
    TN_PVCTreeParams(MapParams.R.P).VCTHeaderText := PageCaption;
  end;
  h := DirHigh;
  for i := 0 to h do
    with TK_UDMVWCartLayer(DirChild(i)) do
      TK_UDMVMLDescr(TK_PMVCLCommon(R.P).UDMLDescr).RebuildLayerAttrs( R, PMVVAttrs,
                                            ASkipRebuildAttrsFlag, ColorsSchemeInd, ColorSchemes );
end;

//********************************************** TK_UDMVWCartWin.GetLayerUDVector
//
function TK_UDMVWCartWin.GetLayerUDVector( LayerInd: Integer ): TN_UDBase;
begin
  Result := DirChild( LayerInd );
  if Result <> nil then
    Result := TK_PMVCartLayer1(TK_UDMVWCartLayer(Result).R.P).UDMVVector;
end;

//********************************************** TK_UDMVWCartWin.GetLayerUDVAttrs
//
function TK_UDMVWCartWin.GetLayerUDVAttrs( LayerInd: Integer ): TN_UDBase;
begin
  Result := DirChild( LayerInd );
  if Result <> nil then
    Result := TK_PMVCartLayer1(TK_UDMVWCartLayer(Result).R.P).UDMVVAttrs;
end;

//********************************************** TK_UDMVWCartWin.GetLayerPMVRCSAttrs
//  Get Pointer to Layer MV Representations Common Attributes Depended from CS
//
function TK_UDMVWCartWin.GetLayerPMVRCSAttrs( LayerInd : Integer ) : TK_PMVRCSAttrs;
var
  UDCA : TK_UDRArray;
begin
  Result := nil;
  UDCA := TK_UDVector(GetLayerUDVector(LayerInd)).GetDCSSpace.GetDCSpace;
  if UDCA <> nil then begin
    UDCA := TK_UDRArray( K_GetMVDarSysFolder( K_msdMVRCSAFolder, UDCA ).DirChild(0) );
    if UDCA <> nil then
       Result := TK_PMVRCSAttrs(UDCA.R.P);
  end;

end;

//********************************************** TK_UDMVWCartWin.GetLayerPMVRCSAttrs
//  Get corresponding TK_UDMVWLDiagramWin Object
//
function TK_UDMVWCartWin.GetCorUDMVWCartWinObj(  ) : TK_UDMVWLDiagramWin;
var
  UDChild : TN_UDBase;
  UDRoot : TN_UDBase;
  i : Integer;
begin
  Result := nil;
  UDRoot := Self.Owner.Owner;
  for i := 0 to UDRoot.DirHigh do
  begin
    UDChild := UDRoot.DirChild( i );
    if UDChild is TK_UDMVWLDiagramWin then
    begin
      Result := TK_UDMVWLDiagramWin(UDChild);
      break;
    end;
  end;
end;

{*** end of TK_UDMVWCartWin ***}

{*** TK_UDMVWCartLayer ***}

//********************************************** TK_UDMVWCartLayer.CanAddChildByPar
//
constructor TK_UDMVWCartLayer.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWCartLayerCI;
  ImgInd := 24;
end;
{*** end of TK_UDMVWCartLayer ***}

{*** TK_PrepCartCompContext ***}

//********************************************** TK_PrepCartCompContext.BuildSelfAttrs
//
procedure TK_PrepCartCompContext.BuildSelfAttrs;
begin
  K_RFreeAndCopy( CCPRAMVAttrs,  CCPRAMVAttrs, [K_mdfCopyRArray] );
end; // end of TK_PrepCartCompContext.BuildSelfAttrs

//********************************************** TK_PrepCartCompContext.Create
//
constructor TK_PrepCartCompContext.Create;
begin
  inherited;
end; // end of TK_PrepCartCompContext.Create

//********************************************** TK_PrepCartCompContext.Destroy
//
destructor TK_PrepCartCompContext.Destroy;
begin
  CCPRAMVAttrs.ARelease;
  inherited;
end; // end of TK_PrepCartCompContext.Destroy

//********************************************** TK_PrepCartCompContext.SetContext
//
procedure TK_PrepCartCompContext.SetContext;
begin
  if (CCPUDMVWCartWin = nil) then Exit;
  CCPUDMVWCartWin.RebuildMapAttrs( TK_PMVVAttrs(CCPRAMVAttrs.P),
                      CCPSkipRebuildAttrsFlag, CCPColorSchemeInd, CCPColorSchemes );
end; // end of TK_PrepCartCompContext.SetContext

//*************************************** TK_PrepCartCompContext.BuildMapHints
//
//
procedure TK_PrepCartCompContext.BuildHints( var ShowHints : TN_SArray );
var
  VectorHints : TN_SArray;
  CSpaceHints : TN_SArray;
  CSSpace, MapCS : TK_UDDCSSpace;
  FullInds : TN_IArray;
  FullCSCount : Integer;
  MapCSCount : Integer;
  i, j : Integer;
  WCSCaptions : PString;
  SVA : TK_SpecValsAssistant;
  AbsValText : string;
  PMVVAttrs : TK_PMVVAttrs;
  UDVector : TN_UDBase;
  RCount : Integer;
  PCSCaptions : Pointer;
  UDVCapts : TK_UDVector;
  CSpace : TK_UDDCSpace;
begin

  SVA := nil;
  PMVVAttrs := TK_PMVVAttrs(CCPRAMVAttrs.P);
  if PMVVAttrs = nil then
    PMVVAttrs := TK_UDRArray(CCPUDMVWCartWin.GetLayerUDVAttrs(0)).R.P;
  UDVector := CCPUDMVWCartWin.GetLayerUDVector(0);

  with TK_UDVector(UDVector), TK_PMVVector(R.P)^ do begin
     RCount := D.ALength;
     SetLength( VectorHints, RCount );
     CSSpace := GetDCSSpace;
     CSpace := CSSpace.GetDCSpace;
     FullCSCount := CSpace.SelfCount;
     K_BuildMVVElemsVAttribs( DP, RCount,
                  PMVVAttrs,
                  {PCSSInds} CSSpace.DP, {PTextValues} nil,
                  {NamedTextValues} @VectorHints[0], nil,
                  {SWInds} nil, {PSVA} @SVA, {Units} Units );
     SetLength( FullInds, FullCSCount );
     K_BuildFullIndex( CSSpace.DP, RCount, @FullInds[0], FullCSCount, K_BuildFullBackIndexes );
     SetLength( CSpaceHints, FullCSCount );
   // Set Data CSpace Hints Vector By Full Data CSpace Element Captions
     UDVCapts := TK_UDVector( PMVVAttrs.ElemCapts );
     if UDVCapts <> nil then
       PCSCaptions := UDVCapts.DP
     else
       PCSCaptions := TK_PDCSpace(CSpace.R.P).Names.P;
     WCSCaptions := PCSCaptions;
     with PMVVAttrs^ do begin
       if SVA = nil then
         SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
       AbsValText := SVA.GetSpecValAttrs( AbsDCSESVIndex ).Caption;
     end;
     for i := 0 to FullCSCount - 1 do begin
       j := FullInds[i];
       if j < 0 then
         CSpaceHints[i] := WCSCaptions^ + ' - ' + AbsValText
       else
         CSpaceHints[i] := VectorHints[j];
       Inc(WCSCaptions);
     end;
   // Set Map CSpace Hints Vector By Data CSpace Element Captions
     MapCS := TK_UDDCSSpace(TK_PMVCLCommon(TK_UDMVWCartLayer(CCPUDMVWCartWin.DirChild(0)).R.P).DCSP);
     MapCSCount := MapCS.PDRA.ALength;
     SetLength( ShowHints, MapCSCount );
     K_MoveSPLVectorBySIndex( ShowHints[0], SizeOf(string), CSpaceHints[0], SizeOf(string),
                         MapCSCount, Ord(nptString), [K_mdfFreeDest], MapCS.DP );
     if (CCPUDColorMask = nil) or (TN_UDBase(CCPUDColorMask) is TK_UDRef) then Exit;
     // Mask Hints for Blank Regions
     for i := 0 to MapCSCount - 1 do
     begin
       if PInteger(CCPUDColorMask.PDE(i))^ <> -1 then
         ShowHints[i] := '';
     end;
  end;
  SVA.Free;
end; //*** end of TK_PrepCartCompContext.BuildMapHints

//********************************************** TK_PrepCartCompContext.ExecFormActivate
//
procedure TK_PrepCartCompContext.PrepFormActivateParams( var Params );
begin
  TN_UDBase(Params) := CCPUDMVWCartWin;
end; //*** end of TK_PrepCartCompContext.PrepFormActivateParams

{*** end of TK_PrepCartCompContext ***}

{*** TK_UDMVWCartGroupWin ***}

//********************************************** TK_UDMVWCartGroupWin.Create
//
constructor TK_UDMVWCartGroupWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWCartGroupWinCI;
  ImgInd := 68;
end;

//********************************************** TK_UDMVWCartGroupWin.CanAddChildByPar
//
function TK_UDMVWCartGroupWin.CanAddChildByPar(AddPar: Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdWebCartWins : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVWCartGroupWin.AddChildToSubTree
//
function TK_UDMVWCartGroupWin.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
begin
  Result := inherited AddChildToSubTree( PDE, CopyPar);
  if Result and (PDE <> nil) then begin
    with TK_PMVWebCartGroupWin(R.P)^ do
      if (DirLength = 1) and (MVWinName = '') then
        MVWinName := TK_PMVWebCartWin(TK_UDRarray(PDE.Child).R.P).VWinName;
  end;
end;

//********************************************** TK_UDMVWCartGroupWin.DeleteSubTreeChild
//
function TK_UDMVWCartGroupWin.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  Result := inherited DeleteSubTreeChild(Index);
  if Result then begin
    with TK_PMVWebCartGroupWin(R.P)^ do
      if (DirLength = 0) then MVWinName := '';
  end;
end;

{*** end of TK_UDMVWCartGroupWin ***}

//***************************************** K_MVMCartogramCreate
// Cartogram Create
//
function K_MVMCartogramCreate( BaseMap : TN_UDBase ) : TK_UDRArray;
begin
  Result := K_CreateUDByRTypeName( 'TK_MVWebCartWin', 1, K_UDMVWCartWinCI );
  with TK_PMVWebCartWin(TK_UDRArray(Result).R.P)^ do begin
    K_SetUDRefField( WCWUDMapDescr, BaseMap );
  end;
end; // end_of function K_MVMCartogramCreate

//***************************************** K_BuildWCartsCompsJoin
//
procedure K_BuildWCartsCompsJoin( WCarts : TK_RArray; VCList : TStrings );
var
 i, h, j, n : Integer;
 VComp : TN_UDBase;
begin
  h := WCarts.AHigh;
  for i := 0 to h do begin
    with TK_PMVMapDescr(TK_UDRArray(TK_PMVWebCartWin(TK_PUDRArray(WCarts.P(i))^.R.P).WCWUDMapDescr).R.P)^ do begin
      n := UDMPrintComps.AHigh;
      for j := 0 to n do begin
        VComp := TN_PUDBase(UDMPrintComps.P(j))^;
        if VCList.IndexOfObject(VComp) = -1 then
          VCList.AddObject( VComp.GetUName, VComp )
      end;
    end;
  end;
end; // end_of procedure K_BuildWCartsCompsJoin

//***************************************** K_BuildWCartsCompsIntersection
//
procedure K_BuildWCartsCompsIntersection( WCarts : TK_RArray; VCList : TStrings );
var
 i, h, j, n, k : Integer;
 VComp : TN_UDBase;
 Checks : array of Boolean;
begin
  VCList.CLear;
  h := WCarts.AHigh;
  if h < 0 then Exit;
  with TK_PMVMapDescr(TK_UDRArray(TK_PMVWebCartWin(TK_PUDRArray(WCarts.P)^.R.P).WCWUDMapDescr).R.P)^ do begin
    n := UDMPrintComps.AHigh;
    SetLength( Checks, n+1 );
    for j := 0 to n do begin
      VComp := TN_PUDBase(UDMPrintComps.P(j))^;
      if VCList.IndexOfObject(VComp) = -1 then
        VCList.AddObject( VComp.GetUName, VComp )
    end;
  end;
  for i := 1 to h do begin
    with TK_PMVMapDescr(TK_UDRArray(TK_PMVWebCartWin(TK_PUDRArray(WCarts.P(i))^.R.P).WCWUDMapDescr).R.P)^ do begin
      n := UDMPrintComps.AHigh;
      for j := 0 to VCList.Count -1 do Checks[j] := false;
      for j := 0 to n do begin
        VComp := TN_PUDBase(UDMPrintComps.P(j))^;
        k := VCList.IndexOfObject(VComp);
        if k >= 0 then Checks[k] := true;
      end;
// Clear Not Used List Elements
      for j := VCList.Count -1 downto 0 do
        if not Checks[j] then VCList.Delete(j);
    end;
  end;
end; // end_of procedure K_BuildWCartsCompsIntersection

//***************************************** K_CheckWCartsCompsIdentity
//
function K_CheckWCartsCompsIdentity( WCarts : TK_RArray ): Boolean;
var
 i, h, j, n, k, m : Integer;
 VComp : TN_UDBase;
 Checks : array of Boolean;
 MapDesr, WMapDescr : TN_UDBase;
 VCList : TStringList;
begin
  Result := false;
  h := WCarts.AHigh;
  if h < 0 then Exit;
  VCList := TStringList.Create;
  MapDesr := TK_PMVWebCartWin(TK_PUDRArray(WCarts.P)^.R.P).WCWUDMapDescr;
  with TK_PMVMapDescr(TK_UDRArray(MapDesr).R.P)^ do begin
    m := UDMPrintComps.AHigh;
    SetLength( Checks, m + 1 );
    for j := 0 to m do begin
      VComp := TN_PUDBase(UDMPrintComps.P(j))^;
      if VCList.IndexOfObject(VComp) = -1 then
        VCList.AddObject( VComp.GetUName, VComp )
    end;
  end;
  for i := 1 to h do begin
    WMapDescr := TK_PMVWebCartWin(TK_PUDRArray(WCarts.P(i))^.R.P).WCWUDMapDescr;
    if MapDesr = WMapDescr then Continue;
    with TK_PMVMapDescr(TK_UDRArray(WMapDescr).R.P)^ do begin
      n := UDMPrintComps.AHigh;
      if n <> m then Exit; // Not Identical VComps List
      for j := 0 to VCList.Count -1 do Checks[j] := false;
      for j := 0 to n do begin
        VComp := TN_PUDBase(UDMPrintComps.P(j))^;
        k := VCList.IndexOfObject(VComp);
        if k >= 0 then
          Checks[k] := true
        else
          Exit; // Not Identical VComps List
      end;
// Check List Identity
      for j := VCList.Count -1 downto 0 do
        if not Checks[j] then Exit;
    end;
  end;
  Result := true;
  VCList.Free;
end; // end_of function K_CheckWCartsCompsIdentity

//***************************************** K_ViewMVWCart
//
procedure K_ViewMVWCart( UDMVWCart : TN_UDBase; AOwner: TN_BaseForm;
                         ColorSchemeInd : Integer; ColorSchemes : TK_RArray );
var
  Map: TN_UDBase;
  CVForm : TK_FormViewComp;
begin
  if (UDMVWCart = nil) or not (UDMVWCart is TK_UDMVWCartWin) then Exit;
  with TK_UDMVWCartWin( UDMVWCart ) do begin
    RebuildMapAttrs( nil, false, ColorSchemeInd, ColorSchemes );
//    Map := TK_PMVMapDescr(TK_UDRArray(TK_PMVWebCartWin(R.P).UDMapDescr).R.P).UDMScreenComp;
    Map := TN_PUDBase(TK_PMVMapDescr(TK_UDRArray(TK_PMVWebCartWin(R.P).WCWUDMapDescr).R.P).UDMPrintComps.P)^;
  CVForm := TK_FormViewComp( K_SearchOpenedForm( TK_FormViewComp, 'MVDarMap', AOwner ) );
  if CVForm = nil then
    CVForm := K_CreateVCForm( AOwner, 'MVDarMap' );

  with CVForm do begin
    if PrepCompContextObj = nil then
      PrepCompContextObj := TK_PrepCartCompContext.Create;
    with TK_PrepCartCompContext(PrepCompContextObj) do
      CCPUDMVWCartWin := TK_UDMVWCartWin(UDMVWCart);
    ShowComponent( [], UDMVWCart.GetUName, TN_UDCompVis(Map) );
  end;

//    N_ViewCompFull2( Map, 'Картограмма', AOwner );
//!!    N_ViewCompFull( TN_UDCompVis(Map), @N_MEGlobObj.RastVCTForm,
//!!                                 AOwner, UDMVWCart.GetUName );
  end;
end; // end_of function K_ViewMVWCart

end.
