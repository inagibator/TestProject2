unit K_Types;
// Base Types definitions,
//
// Interface section uses only N_Types and Delphi units
// Implementation section uses nothing

interface

uses N_Types;

type TK_ScanTreeResult = ( K_tucOK, K_tucSkipSubTree, K_tucSkipSibling, K_tucSkipScan,
                           K_tucSkipSiblingRows, K_tucSkipSiblingFields,
                           K_tucSkipFieldsScan, K_tucSkipFieldsSubTree );

type TK_MesStatus = (K_msInfo, K_msWarning, K_msError, K_msDebugInfo );

type TK_MVShowMessageProc  = procedure ( const MessageLine : string; MesStatus : TK_MesStatus = K_msInfo ) of object;

type TK_MVShowProgressProc = procedure ( const MessageLine : string; ProgressStep : Float = -1 ) of object;

type TK_FuncObjBool  = function () : Boolean of object;

type TK_OneIntFuncObjBool  = function ( AInt : Integer ) : Boolean of object;

type TK_MVGetVarInfoProc   = procedure ( AName : string; out PValue : Pointer; out VTypeCode : Int64  ) of object;

type TK_NotifyProc = procedure () of object;

type TK_NotifyStr1Proc = procedure ( AStr : string ) of object;


type TK_GridPos = record
  Col, Row : Integer;
end;

//  Set Object State flags in Objects Collection
type TK_SetObjStateFlags = set of (
  K_ssfMarked,   // Obj should be marked
  K_ssfSelected, // Obj should be selected
  K_ssfCurrent   // Obj should be Current
);

type TK_ObjectArray = array of TObject;

type TK_FormOnActivate = procedure( var param ) of object;

type TK_PrepCompContext = class
  CCPSkipRebuildAttrsFlag : Boolean;
  CCPColorSchemeInd : Integer;
  procedure SetContext(); virtual; abstract;
  procedure BuildSelfAttrs(); virtual;
  procedure BuildHints( var ShowHints : TN_SArray ); virtual;
  procedure PrepFormActivateParams( var Params ); virtual;
end;

type TN_PPDArray = ^TN_DArray;

//***************** stdcall ExtDLL functions types:
type TK_stdcallIntFunc             = function ( ): Integer;  stdcall;
type TK_stdcallIntFuncPtrIntPtrInt = function ( APtr1: Pointer; AInt1: Integer; APtr2: Pointer; AInt2: Integer ): Integer; stdcall;
type TK_stdcallIntFuncPtr4Int2Ptr  = function ( APtr1: Pointer; AInt1,AInt2,AInt3,AInt4: Integer; APtr2,APtr3 : Pointer ): Integer; stdcall;
type TK_stdcallIntFunc3Ptr         = function ( APtr1,APtr2,APtr3 : Pointer ): Integer; stdcall;
type TK_stdcallIntFuncPtrInt2Ptr   = function ( APtr1: Pointer; AInt1: Integer; APtr2,APtr3 : Pointer ): Integer; stdcall;
type TK_stdcallIntFunc4IntPtr      = function ( AInt1,AInt2,AInt3,AInt4: Integer; APtr1: Pointer ): Integer; stdcall;
type TK_stdcallIntFunc4Int2Ptr     = function ( AInt1,AInt2,AInt3,AInt4: Integer; APtr1, APtr2: Pointer ): Integer; stdcall;
type TK_stdcallIntFunc4Int         = function ( AInt1,AInt2,AInt3,AInt4: Integer ): Integer; stdcall;
type TK_stdcallIntFuncPtr          = function ( APtr : Pointer ): Integer; stdcall;
type TK_stdcallIntFunc2Ptr         = function ( APtr1, APtr2: Pointer ): Integer; stdcall;
type TK_stdcallIntFunc2PtrIntPtr   = function ( APtr1, APtr2: Pointer; AInt1: Integer; APtr3 : Pointer ): Integer; stdcall;

implementation

{*** TK_PrepCompContext ***}

//******************************************* TK_PrepCompContext.BuildSelfAttrs
//
procedure TK_PrepCompContext.BuildSelfAttrs;
begin
end; //*** end of TK_PrepCompContext.BuildSelfAttrs

//*********************************************** TK_PrepCompContext.BuildHints
//
procedure TK_PrepCompContext.BuildHints( var ShowHints : TN_SArray );
begin
end; //*** end of TK_PrepCompContext.BuildHints

//***************************************** TK_PrepCompContext.ExecFormActivate
//
procedure TK_PrepCompContext.PrepFormActivateParams( var Params );
begin
end; //*** end of TK_PrepCompContext.PrepFormActivateParams

{*** end of TK_PrepCompContext ***}

end.
