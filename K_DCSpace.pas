unit K_DCSpace;

interface
uses
  IniFiles, SysUtils, Classes,
  K_CLib0, K_UDT1, K_Script1, K_SParse1, K_SBuf, K_Types,
  N_Types, N_ClassRef;

type TK_LoadUDVectorError = class(Exception);

type TK_DCSpace = packed record // Data Code Space
  Codes   : TK_RArray;
  Names   : TK_RArray;
  Keys    : TK_RArray;
end; // type TK_DCSpace = record
type TK_PDCSpace = ^TK_DCSpace;

type TK_DCEditSpace = packed record // Data Code Space Edit Structure
  PrevIndex : Integer; // Previouse Index Value
  Code   : String;  // Space Code
  Name   : String;  // Space Code Name
  Key    : String;  // Space Code Key
end; // type TK_DCEditSpace = record
type TK_PDCEditSpace = ^TK_DCEditSpace;

type TK_DVector = packed record // Data Vector
  D       : TK_RArray;
end; // type TK_DVector = record
type TK_PDVector = ^TK_DVector;

type TK_DSSVector = packed record // Data Vector Linked to Data Code SubSpace
  D       : TK_RArray;
  CSS     : TN_UDBase;
end; // type TK_DSSVector = record
type TK_PDSSVector = ^TK_DSSVector;

type TK_DSSTable = packed record // Data Vectors Table Linked to Data Code SubSpace
  CSS     : TN_UDBase; // Code SubSpace Reference
  DTCode  : Int64;     // Element Type Code
end; // type TK_DSSTable = record
type TK_PDSSTable = ^TK_DSSTable;

{
type TK_DCSSpace = packed record // Data Code Sub Space
  Comment : string;
  Indexes : TK_RArray;
end; // type TK_DCSSpace = record
type TK_PDCSSpace = ^TK_DCSSpace;
}

type TK_DCodeContext = record
  SpacesRoot1  : TN_UDBase; // Code Spaces Root
  UserRoot    : TN_UDBase; // User Root
end; // type TK_DCodeContext = record
type TK_PDCodeContext = ^TK_DCodeContext;

type TK_CSInfoType = ( K_csiCSCode, K_csiCSName, K_csiCSEntryKey, K_csiSclonKey );
type TK_UDDCSSpace    = class;  // forvard reference
{type} TK_UDSSTable   = class;  // forvard reference
{type} TK_UDVector    = class;  // forvard reference

{type} TK_UDDCSpace   = class( TK_UDRArray ) //*** Code Space object
  constructor Create; override;
  procedure   PascalInit; override;
  function    SelfCount : Integer;
  function    SelfDelete1 : Boolean;
  function    CreateDCSSpace( DCSSpaceName : string = ''; Count : Integer = -1;
                              DCSSpaceAliase : string = '' ) : TK_UDDCSSpace;
  function    GetSSpacesDir : TN_UDBase;
  function    GetAliasesDir : TK_UDSSTable;
  function    IndexByCode( Code : string ) : Integer;
//  procedure   ChangeValue( PDPindex : PInteger; Count : Integer );
//  procedure   CheckDCSS();
  procedure   ChangeDCSSOrder( PDPindex : PInteger; Count : Integer );
  function    RebuildFullCSS( Count : Integer; FCSS : TK_UDDCSSpace = nil ) : TK_UDDCSSpace;
  function    IndexOfCSS( PData : Pointer; Count : Integer ) : TK_UDDCSSpace;
  function    SearchProjByCSS( AUDDCSSpace: TK_UDDCSSpace ): TK_UDVector;
  function    SearchProjByElemIndex( AElemInd : Integer ): TK_UDVector;
  procedure   GetItemsInfo( PResult : PString;
        AInfoType: TK_CSInfoType; Index: Integer;
        ILength : Integer = 1; IStep : Integer = SizeOf(string) );
  function    GetItemInfoPtr( AInfoType: TK_CSInfoType; Index: Integer ): Pstring;
    private
  procedure   AliasesInit;
end; //*** end of type TK_UDDCSpace  = class( TK_UDRArray )

{type} TK_UDVector = class( TK_UDRArray ) //*** Data Vector Object
      public
  constructor Create; override;
//  procedure   Delete( Parent : TN_UDBase = nil ); override;
  function    BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string; override;
  function    SelfDelete : Boolean; virtual;
  function    GetDCSSpace : TK_UDDCSSpace;
  function    PDRA : TK_PRArray; override;
  function    PDE( Ind : Integer ) : Pointer; override;
  function    DP : Pointer; overload;
  function    DP( Ind : Integer ) : Pointer; overload;
  function    IsDCSProjection : Boolean;
  procedure   GetDefaultValue( PDefValue : Pointer );
  procedure   ChangeElemsType( NewElemTypeCode : Int64 ); override;
  procedure   ChangeElemsOrder( PDProj : PInteger; Count : Integer );
  function    ChangeCSS( ACSS : TK_UDDCSSpace ) : Boolean;

end; //*** end of type TK_UDVector  = class( TK_UDRArray )

{type} TK_UDSSTable  = class( TK_UDRArray ) //*** Data Table Root
  constructor Create; override;
  function    CreateDVColumn( DVectorName : string;
                                ElemTypeCode : Int64 = 0;
                                PData : Pointer = nil;
                                SelfTypeCode : Int64 = 0;
                                UDClassInd : Integer = K_UDVectorCI ) : TK_UDVector;
  function    CreateDVector(DVectorName : string;
                                ElemTypeCode : Int64 = 0;
                                PData : Pointer = nil;
                                SelfTypeCode : Int64 = 0;
                                UDClassInd : Integer = K_UDVectorCI ) : TN_UDBase;
end; //*** end of type TK_UDSSTable  = class( TK_UDRArray )

{type} TK_UDDCSSpace  = class( TK_UDVector ) //*** Code SubSpace object
  constructor Create; override;
  destructor  Destroy; override;
  function    SelfDelete : Boolean; override;
//  procedure   PascalInit; override;
  procedure   CreateVectorsDir;
  function    GetDCSpace : TK_UDDCSpace;
  function    GetVectorsDir : TN_UDBase;
  procedure   ChangeDVectorsOrder( PDPindex : PInteger; Count : Integer ); overload;
  procedure   ChangeDVectorsOrder( PConvInds: PInteger; ConvIndsCount : Integer;
                                   PFreeInds: PInteger; FreeIndsCount : Integer;
                                   PInitInds: PInteger; InitIndsCount : Integer ); overload;
  procedure   ChangeValue( PNCSS : PInteger; Count : Integer;
                           ChangeVectors : Boolean = true  );
  procedure   LinkDVector( PDVector : Pointer );
  function    CreateDVector( DVectorName : string; ElemTypeCode : Int64;
                                PData : Pointer = nil;
                                SelfTypeCode : Int64 = 0;
                                UDClassInd : Integer = K_UDVectorCI ) : TK_UDVector;
  function    CreateDTable( DTableName : string;
                            ElemTypeCode : Int64 = 0;
                            TabTypeCode: Int64 = 0;
                            UDClassInd : Integer = K_UDSSTableCI ) : TK_UDSSTable;
  function    IndexByCode( Code : string ) : Integer;
    public
  CodesList : THashedStringList;
end; //*** end of type TK_UDDCSSpace  = class( TK_UDVector )

type  TK_BuildCSSUDVList = class( TObject ) //
  UDVList : TList;
  VCSS : TK_UDDCSSpace;
  destructor Destroy; override;
  function Build( UDRoot : TN_UDBase; ACSS : TK_UDDCSSpace ): TList;
  function BuildCSSUDVList( UDParent : TN_UDBase; var UDChild : TN_UDBase;
    ChildInd : Integer; ChildLevel : Integer; const FieldName : string = '' ) : TK_ScanTreeResult;
end;

type  TK_UDDCSProjFilterItem = class( TK_UDFilterItem ) //
  constructor Create( AExprCode : TK_UDFilterItemExprCode = K_ifcOr);
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDDCSProjFilterItem = class( TK_UDFilterItem )

type  TK_UDDCSProjFilterItem1 = class( TK_UDDCSProjFilterItem ) //
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_UDDCSProjFilterItem = class( TK_UDDCSProjFilterItem )


//function  K_DCEditSpaceDataCreate( UDCSpase : TK_UDRArray ) : TK_RArray;

procedure K_InitDCodeGCont( CurArchive : TN_UDBase = nil );
//*** Code Space Routines
function  K_DCSpaceCreate( NewName : string; NewAliase : string = '' ) : TK_UDDCSpace;
function  K_IndexOfDCSpace( PCodes, PNames, PKeys : Pointer; Count : Integer ) : TK_UDDCSpace;
//function  K_DCSpaceDelete( UDCSpase : TK_UDRArray ) : Boolean;
//*** Code Space Projection Routines
function  K_DCSpaceDefProjNameBuild( UDCSpaceSrc, UDCSpaceDest : TN_UDBase ) : string;
function  K_DCSpaceProjectionGet( UDCSpaceSrc, UDCSpaceDest : TK_UDDCSpace;
                                      ProjUserName : string = '' ) : TK_UDVector;
function  K_DCSpaceProjectionCreate( UDCSpaceSrc, UDCSpaceDest : TK_UDDCSpace;
                                     AAliase : string = '';
                                     AName : string = '' ) : TK_UDVector;
procedure K_DCSpaceProjectionDelete( UDDCSProj : TK_UDDCSSpace );
//*** Code Sub Space Routines
//function  K_DCSSpaceCreate( UDCSpase : TK_UDRArray;
//                    NewName : string  ) : TK_UDRArray;
//procedure K_DCSSpaceChangeDataOrder( UDCSSpase : TK_UDDCSSpace;
//                                  PDCNindex : PInteger; nd : Integer );
//procedure K_DCSSpaceChangeSpaceIndex( UDCSSpase : TK_UDDCSSpace;
//                                  PDCNindex : PInteger; nd : Integer );
function  K_BuildDataProjectionByCSProj( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; UDProj : TK_UDVector ) : Boolean;
function  K_BuildDataProjection0( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; ProjUserName : string = '' ) : Boolean;
function  K_BuildDataProjection( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; var ProjCapacity : Integer; ProjUserName : string = '' ) : Boolean;
procedure K_BuildIndsByConvInds( PNewInds, PSrcInds : PInteger;
                                 DCLeng : Integer; PConvInds : PInteger );
procedure K_BuildCSSProjectionInds( PIndexes, PDCSS : PInteger; DCLeng : Integer;
                            PSCSS : PInteger; SCLeng : Integer; CSLeng : Integer );
function  K_CalcProjectionIndexes( PIndexes : PInteger; Count : Integer ) : Integer;
function  K_BuildDataProjectionBySCodes( PIndexes : PInteger; UDV : TK_UDVector; PSCodes : PString; Count : Integer ) : Integer;
function  K_GetDVectorDType() : TK_ExprExtType;
function  K_GetDSSVectorDType() : TK_ExprExtType;
function  K_GetDSSTableDType() : TK_ExprExtType;
procedure K_ExportUDVector( TS : TStrings; UDVector : TK_UDVector;
              SMFormat : TN_StrMatrFormat = smfTab );
function  K_CreateUDVector( TS : TStrings; CS : TStrings = nil ) : TK_UDVector;
function  K_IfSameProjDst( APCodes : PInteger; ACNum : Integer; ADCSProj : TK_UDVector ) : Integer;


var
//  K_DCodeContext   : TK_DCodeContext;
  K_DCodeContextAlt: TK_DCodeContext;
  K_CurSpacesRoot  : TN_UDBase; // Code Spaces Root

const
//*** CS and CSS  Childs Structure
  K_dcsSSSpacesRInd  = 0; // Space Sub Spaces Root Ind
  K_dcsSEAliasesRInd = 1; // Space Elements Aliases Root Ind
  K_dcsSSVectorsRInd = 0; // Sub Space Vectors Root Index
  K_dcsVSSpaceInd    = 0; // Data Vector Sub Space Index

//*** CS and CSS  Childs Names
  K_dcsSSSpacesName   = 'SubSpaces';
  K_dcsSSSpacesAliase = 'Подпространства';
  K_dcsSEAliasesName   = 'Aliases';
  K_dcsSEAliasesAliase = 'Названия';
  K_dcsSSVectorsName  = 'Vectors';
  K_dcsSSVectorsAliase= 'Вектора';


//*** CS and User Root  Names
  K_DCSpacesRootName = 'DCSpaces';
  K_DCSpacesRootAliase = 'Пространства';

//*** New CS  Names
  K_FDCSpaceNewName = 'DCS';
  K_FDCSpaceNewAliase = 'Untitled';

//*** New CSS  Names
  K_FDCSSpaceNewName = 'DCSS';
  K_FDCSSpaceNewAliase = 'Untitled';

//*** UDVector Export/Import Fields Names
  K_UDVFSelfName   = 'Name';
  K_UDVFSelfAliase = 'Aliase';
  K_UDVFElemType   = 'Type';
  K_UDVFSelfType   = 'SelfType';
  K_UDVFSelfUDType = 'SelfUDType';
  K_UDVFCSUName    = 'CS';
  K_UDVFCSSName    = 'CSSName';
  K_UDVFCSSAliase  = 'CSSAliase';
  K_UDVSDFormat    = 'Format';

implementation

uses Math, Dialogs, Forms, Grids, Controls,
  N_Lib1, N_Lib0,
  K_UDConst, K_VFunc, K_UDT2, {K_FDCSpace, K_FDCSSpace, K_FDCSProj,}
  K_Arch, K_MVObjs, K_UDC, K_CSpace;

var
  K_DVectorDType : TK_ExprExtType;
  K_DSSVectorDType : TK_ExprExtType;
  K_DSSTableDType : TK_ExprExtType;

//*********************************************
//***               Local Routines
//*********************************************


//***************************************** K_DCEditSpaceDataCreate ***
// Create Code Space Object
//
function K_DCEditSpaceDataCreate( UDCSpase : TK_UDRArray ) : TK_RArray;
var
  i, h : Integer;
  PDCSpace : TK_PDCSpace;
  PKeys, PCodes, PNames : PString;
begin
  PDCSpace := TK_PDCSpace( UDCSpase.R.P );
  with PDCSpace^ do begin
    h := Codes.AHigh;
    Result := K_RCreateByTypeName( 'TK_DCEditSpace', h + 1 );
  //*** prepare Result Array
    PCodes := PString( Codes.P );
    PNames := PString( Names.P );
    PKeys := PString( Names.P );
    for i := 0 to h do begin
      with TK_PDCEditSpace( Result.P(i) )^ do begin
        PrevIndex := i;
        Code := PCodes^;  // Space Code
        Name := PNames^;  // Space Code Name
        Name := PKeys^;  // Space Code Key
        Inc( TN_BytesPtr(PCodes), SizeOf(string) );
        Inc( TN_BytesPtr(PNames), SizeOf(string) );
        Inc( TN_BytesPtr(PKeys), SizeOf(string) );
      end;
    end;
  end;
end; // end_of procedure K_DCEditSpaceDataCreate

//*********************************************
//***               Global Routines
//*********************************************

//***************************************** K_InitDCodeGCont ***
// Init Code Space context
//
procedure K_InitDCodeGCont( CurArchive : TN_UDBase = nil );
begin
  K_CurSpacesRoot := nil;
  K_CurUserRoot := nil;
  if CurArchive = nil then CurArchive := K_CurArchive;
  if CurArchive = nil then Exit;
  with CurArchive do begin
    K_CurSpacesRoot :=
            DirChild( IndexOfChildObjName( K_DCSpacesRootName ) );
    if K_CurSpacesRoot = nil then begin
      K_CurSpacesRoot := K_AddArchiveSysDir( K_DCSpacesRootName, K_sftReplace, CurArchive );
      K_CurSpacesRoot.ObjAliase := K_DCSpacesRootAliase;
    end;
  end;

end; // end_of procedure K_InitDCodeGCont

//***************************************** K_DCSpaceCreate ***
// Create Code Space Object
//
function K_DCSpaceCreate( NewName : string; NewAliase : string = '' ) : TK_UDDCSpace;
begin
  Result := TK_UDDCSpace( K_CreateUDByRTypeName( 'TK_DCSpace', 1, K_UDDCSpaceCI ) );
  Result.ObjName := NewName;
  if NewAliase = '' then
    Result.ObjAliase := NewName
  else
    Result.ObjAliase := NewAliase;
  with K_CurSpacesRoot do begin
    AddOneChild( Result );
    K_AddSysObjFlags( K_CurSpacesRoot, Result, K_sftSkipAll );
    SetUniqChildName( Result );
  end;
  Result.AliasesInit;
  K_SetChangeSubTreeFlags( Result, [K_cstfSetDown] );

end; // end_of function K_DCSpaceCreate

//***************************************** K_IndexOfDCSpace ***
// Search for Avaliable DCSpace
//
function K_IndexOfDCSpace( PCodes, PNames, PKeys : Pointer; Count : Integer ) : TK_UDDCSpace;
var
  n, i : Integer;
  Inds : TN_IArray;
  Strs : TN_SArray;
begin
  with K_CurSpacesRoot do
    for i := 0 to DirHigh do begin
      Result := TK_UDDCSpace(DirChild(i));
      if Count <> Result.SelfCount then Continue;
      SetLength( Inds, Count );
      with TK_PDCSpace(Result.R.P)^ do begin
        n := K_SCIndexFromSCodes( @Inds[0],
                    PString(Codes.P), Count,
                    PString(PCodes), Count );
        if n <> Count then Continue;
        SetLength( Strs, Count );
        if (PNames <> nil) then begin
          K_MoveSPLVectorBySIndex( Strs[0], SizeOf(string),
                             PNames^, SizeOf(string),
                             Count, Ord(nptString), [], @Inds[0] );
          if not K_CompareSPLVectors( @Strs[0], SizeOf(string),
             Names.P, SizeOf(string), Count, Ord(nptString) ) then Continue;
        end;
        if (PKeys <> nil) then begin
          K_MoveSPLVectorBySIndex( Strs[0], SizeOf(string),
                             PKeys^, SizeOf(string),
                             Count, Ord(nptString), [], @Inds[0] );
          if not K_CompareSPLVectors( @Strs[0], SizeOf(string),
             Keys.P, SizeOf(string), Count, Ord(nptString) ) then Continue;
        end;
      end;
      Exit;
    end;
  Result := nil;
end; // end_of function K_IndexOfDCSpace

//***************************************** K_DCSpaceDefProjNameBuild
// Build  DCSpaces default projection Name
//
function  K_DCSpaceDefProjNameBuild( UDCSpaceSrc, UDCSpaceDest : TN_UDBase ) : string;
begin
  Result := UDCSpaceDest.ObjName+'-'+UDCSpaceSrc.ObjName+'*';
end; // end_of procedure K_DCSpaceDefProjNameBuild

//***************************************** K_DCSpaceProjectionGet
// Get DCSpaces projection
//
function  K_DCSpaceProjectionGet( UDCSpaceSrc, UDCSpaceDest : TK_UDDCSpace;
                                      ProjUserName : string = '' ) : TK_UDVector;
var
  SearchDir, OwnerDir : TN_UDBase;
  i, h : Integer;
begin
  Result := nil;
// check  DCSpaces
  if (UDCSpaceSrc = nil) or (UDCSpaceDest = nil) then Exit;

// check  Dest DCSpace Full DCSSpace
  SearchDir := UDCSpaceDest.GetSSpacesDir;
  SearchDir := SearchDir.DirChildByObjName( UDCSpaceDest.ObjName ); // No DCSpaces
  if SearchDir = nil then Exit;

  SearchDir := TK_UDDCSSpace(SearchDir).GetVectorsDir;
  if ProjUserName = '' then begin
//*** search main projection
    OwnerDir := UDCSpaceSrc.GetSSpacesDir;
    with SearchDir do begin
      h := DirHigh;
      for i := 0 to h do begin
        Result := TK_UDVector( DirChild(i) );
        if Result.Owner = OwnerDir then Exit;
      end;
      Result := nil;
    end
  end else
//*** search projection by user name
    Result := TK_UDVector( SearchDir.DirChildByObjName( ProjUserName, K_ontObjUName ) );
end; // end_of procedure K_DCSpaceProjectionGet

//***************************************** K_DCSpaceProjectionCreate
// Create Code Spaces Projection
//
function  K_DCSpaceProjectionCreate( UDCSpaceSrc, UDCSpaceDest : TK_UDDCSpace;
                                     AAliase : string = '';
                                     AName : string = ''  ) : TK_UDVector;
var
  UDCSS : TK_UDDCSSpace;
  Minus1 : Integer;
  UDDefProj : TK_UDVector;
  FAliase : string;
begin
//*** Check projection existance
  UDDefProj := K_DCSpaceProjectionGet( UDCSpaceSrc, UDCSpaceDest );
//  if Result <> nil then Exit;
//*** Get Full DCSubSpace from Dest DCSpace for Projections
  UDCSS := UDCSpaceDest.CreateDCSSpace;

  Minus1 := -1;
//*** Create Projection as Dest DCSpace Vector
  if AName = '' then AName := K_DCSpaceDefProjNameBuild( UDCSpaceSrc, UDCSpaceDest );

  Result := UDCSS.CreateDVector( AName, Ord(nptInt), @Minus1 );
  with UDCSS.GetVectorsDir do begin
    AddOneChild( Result ); // add projection to
    SetChangedSubTreeFlag();
  end;
  
  FAliase := AAliase;
  if AAliase = '' then
    FAliase := 'Projection of "'+UDCSpaceSrc.ObjAliase+'" to "'+UDCSpaceDest.ObjAliase+'"';
  Result.ObjAliase := FAliase;
  Result.ImgInd := 17;

  //*** Register Projection as Source DCSpace DCSSpace
  Result.Owner := nil;
  with UDCSpaceSrc.GetSSpacesDir do begin
    AddOneChild( Result );
    if (UDDefProj <> nil) and (AAliase = '') then begin
      Result.ObjAliase := Result.ObjAliase + ' additional';
      SetUniqChildName( Result );
    end;
  end;
  K_SetChangeSubTreeFlags( Result );


end; // end_of procedure K_DCSpaceProjectionCreate

//***************************************** K_DCSpaceProjectionDelete
// Delete Code Spaces Projection
//
procedure K_DCSpaceProjectionDelete( UDDCSProj : TK_UDDCSSpace );
var
  UDVectors : TN_UDBase;
begin
  Include(K_UDOperateFlags, K_udoUNCDeletion);
//*** Delete as Vector from SubSpaces Vectors;
  UDVectors := UDDCSProj.GetDCSSpace.GetVectorsDir;
  K_SetChangeSubTreeFlags( UDVectors );
  K_SetChangeSubTreeFlags( UDDCSProj );
  UDVectors.DeleteOneChild( UDDCSProj );
//*** Delete as SubSpace from Space SubSpaces;
  UDDCSProj.Owner.DeleteOneChild( UDDCSProj );
  Exclude(K_UDOperateFlags, K_udoUNCDeletion);
  K_SetChangeSubTreeFlags( UDDCSProj );

end; // end_of procedure K_DCSpaceProjectionDelete

{
//***************************************** K_DCSSpaceChangeDataOrder
// Change Data Order in Vectors linked to Full DCSubSpace and
//  Rebuild new Full DCSubSpace while DCSpace was changed
//
//  used by DCSpace Editor
//
procedure K_DCSSpaceChangeDataOrder( UDCSSpase : TK_UDDCSSpace;
                                  PDCNindex : PInteger; nd : Integer );
var
  i, h, j : Integer;
  VD : TK_RArray;
//  PInd : PInteger;
begin
//*** change vectors elements order
  with UDCSSpase.GetVectorsDir do begin
    h := DirHigh;
    for i := 0 to h do begin
      with TK_UDVector( DirChild(i) ) do begin
        with PDRA^ do begin
          VD := TK_RArray.CreateByType( DType.All, nd );
          if IsDCSProjection then begin
          //*** If data Vector is DCSPorjection use special initialization
            j := -1;
            VD.SetElems( j );
          end;
          K_MoveSPLVectorBySIndex( VD.P^, 0, P^, K_GetExecTypeSize( DType.All ), nd, DType.All, [],
                                   PDCNindex  );
          ARelease;
        end;
        PDRA^ := VD;
      end;
    end;
  end;
end; // end_of procedure K_DCSSpaceChangeDataOrder

//***************************************** K_DCSSpaceChangeSpaceIndex
// Change DCSubSpace Indexes while DCSpace was changed
//
//  used by DCSpace Editor
//
procedure K_DCSSpaceChangeSpaceIndex( UDCSSpase : TK_UDDCSSpace;
                                  PDCNindex : PInteger; nd : Integer );
var
  ncss, ncs : Integer;
  NSSIndex : TK_RArray;
begin
  with UDCSSpase do begin
    with PDRA^ do begin
      ncss := ALength;
      ncs := GetDCSpace.SelfCount;
  //*** create New DCSubSpace RArray
      NSSIndex := TK_RArray.CreateByType( Ord(nptInt), ncss );
  //*** Build New DCSubSpace Indexes
//      K_SCIndexFromICodes( PInteger(NSSIndex.P),
//                           PInteger(P), ns,
//                           PDCNindex, nd );
      K_BuildCSSProjectionInds( PInteger(NSSIndex.P), PInteger(P), ncss,
                                        PDCNindex, nd, Max(nd,ncs) );
      ARelease;
    end;
    PDRA^ := NSSIndex;
  end;
end; // end_of procedure K_DCSSpaceChangeSpaceIndex
}

//***************************************** K_RebuildCSSByConvIndex
// Change DCSubSpace Indexes while DCSpace was changed
//
//  used by DCSpace Editor
//
procedure K_RebuildCSSByConvIndex( UDCSSpase : TK_UDDCSSpace;
                                  PConvInds : PInteger );
begin
  with UDCSSpase.PDRA^ do
    K_BuildIndsByConvInds( PInteger(P), PInteger(P), ALength, PConvInds );
end; // end_of procedure K_RebuildCSSByConvIndex

//***************************************** K_BuildDataProjectionByCSProj
// Build Data Projection  index from src to dest DCSubSpaces
// Index is 1-st element of array which lenght must not be less
// then length of UDCSSpaceDest
//
function  K_BuildDataProjectionByCSProj( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; UDProj : TK_UDVector ) : Boolean;
var
  UDCSpaceSrc : TK_UDDCSpace;
  UDCSpaceDest : TK_UDDCSpace;
  IBuf : TN_IArray;
  SLength, DLength : Integer;
  PISrc, PIDest : PInteger;

begin
  UDCSpaceSrc := UDCSSpaceSrc.GetDCSpace;
  UDCSpaceDest := UDCSSpaceDest.GetDCSpace;
  Result := false;
  with UDCSSpaceSrc.PDRA^ do begin
    SLength := ALength;
    PISrc := PInteger(P);
  end;
  with UDCSSpaceDest.PDRA^ do begin
    DLength := ALength;
    PIDest := PInteger(P);
  end;

  if (UDProj = nil) and (UDCSpaceSrc <> UDCSpaceDest) then
    UDProj := K_DCSpaceProjectionGet( UDCSpaceSrc, UDCSpaceDest );

  if UDProj <> nil then begin

    if not UDProj.IsDCSProjection or
       (TK_UDDCSSpace(UDProj).GetDCSpace <> UDCSpaceSrc) then Exit;

    SetLength( IBuf, DLength );
    K_MoveVectorBySIndex( IBuf[0], SizeOf(Integer),
                UDProj.DP^, SizeOf(Integer),
                SizeOf(Integer), DLength, PIDest );
    PIDest := @IBuf[0];
  end else if UDCSpaceSrc <> UDCSpaceDest then Exit;

//*** build Data Projection using SSpaces Indexes as Codes
//  ProjCapacity := K_SCIndexFromICodes( PIndex, PIDest, DLength, PISrc, SLength );
  K_BuildCSSProjectionInds( PIndex, PIDest, DLength, PISrc, SLength,
            UDCSpaceSrc.SelfCount );
  Result := true;
  IBuf := nil;
end; // end_of function  K_BuildDataProjectionByCSProj

//***************************************** K_BuildDataProjection0
// Build Data Projection  index from src to dest DCSubSpaces
// Index is 1-st element of array which lenght must not be less
// then length of UDCSSpaceDest
//
function  K_BuildDataProjection0( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; ProjUserName : string = ''  ) : Boolean;

begin
  Result := K_BuildDataProjectionByCSProj( UDCSSpaceSrc, UDCSSpaceDest, PIndex,
        K_DCSpaceProjectionGet( UDCSSpaceSrc.GetDCSpace,
                                UDCSSpaceDest.GetDCSpace, ProjUserName ) );
end; // end_of function  K_BuildDataProjection0

//***************************************** K_BuildDataProjection
// Build Data Projection  index from src to dest DCSubSpaces
// Index is 1-st element of array which lenght must not be less
// then length of UDCSSpaceDest
//
function  K_BuildDataProjection( UDCSSpaceSrc, UDCSSpaceDest : TK_UDDCSSpace;
            PIndex : PInteger; var ProjCapacity : Integer; ProjUserName : string = ''  ) : Boolean;
begin
  Result := K_BuildDataProjection0(UDCSSpaceSrc, UDCSSpaceDest, PIndex, ProjUserName );
  if Result then
    ProjCapacity := K_CalcProjectionIndexes( PIndex, UDCSSpaceDest.PDRA.ALength );
end; // end_of function  K_BuildDataProjection

//************************************************ K_BuildIndsByConvInds
//  Build New CSS by Conversion Indexes
//    NewInds[i] = ConvInds[SrcInds[i]]
//
procedure K_BuildIndsByConvInds( PNewInds, PSrcInds : PInteger;
                                 DCLeng : Integer; PConvInds : PInteger );
begin
  K_MoveVectorBySIndex( PNewInds^, SizeOf(Integer),
                      PConvInds^, SizeOf(Integer), SizeOf(Integer),
                      DCLeng, PSrcInds );
{
  for i := 0 to DCLeng - 1 do begin
    if PSrcInds^ >= 0 then
      PNewInds^ := PInteger(TN_BytesPtr(PConvInds) + PSrcInds^*SizeOf(Integer))^;
    Inc( PSrcInds );
    Inc( PNewInds );
  end;
}
end; //*** procedure K_BuildIndsByConvInds

//************************************************ K_BuildCSSProjectionInds ***
//  Build projection indexes from Dest CSS Indexes to Src Indexes
//    DCSS[i] = SCSS[Indexes[i]]
//
procedure K_BuildCSSProjectionInds( PIndexes, PDCSS : PInteger; DCLeng : Integer;
                            PSCSS : PInteger; SCLeng : Integer; CSLeng : Integer );
var
  i : Integer;
  WPSI : PInteger;
  CSI : TN_IArray;
begin

{
  for i := 0 to High(CSI) do
    CSI[i] := - 1;
  WPSI := PSCSS;
  for i := 0 to SCLeng - 1 do begin
    if WPSI^ >= 0 then
      CSI[WPSI^] := i;
    Inc( WPSI );
  end;
}
  SetLength(CSI, CSLeng);
  K_BuildBackIndex0( PSCSS, SCLeng, @CSI[0], CSLeng );
{
  for i := 0 to High(CSI) do
    CSI[i] := - 1;
  WPSI := PSCSS;
  for i := 0 to SCLeng - 1 do begin
    if WPSI^ >= 0 then
      CSI[WPSI^] := i;
    Inc( WPSI );
  end;
}
  WPSI := PDCSS;
  for i := 0 to DCLeng - 1 do begin
    if WPSI^ >= 0 then
      PIndexes^ := CSI[WPSI^]
    else
      PIndexes^ := WPSI^;
    Inc( WPSI );
    Inc( PIndexes );
  end;
end; //*** procedure K_BuildCSSProjectionInds

//************************************************ K_CalcProjectionIndexes ***
//  Calculate number of "real" (not -1) Indexes
//
function  K_CalcProjectionIndexes( PIndexes : PInteger; Count : Integer ) : Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 1 to Count do begin
    if PIndexes^ >= 0 then
      Inc( Result );
    Inc( TN_BytesPtr(PIndexes), SizeOf(Integer) );
  end;
end; //*** function K_CalcProjectionIndexes

//************************************************ K_BuildDataProjectionBySCodes ***
//  Build Data Projection from UDVector to Layer data using array of Codes
//
function K_BuildDataProjectionBySCodes( PIndexes : PInteger; UDV : TK_UDVector; PSCodes : PString; Count : Integer ) : Integer;
var
  i : Integer;
begin
  Result := 0;
  with UDV.GetDCSSpace do
    for i := 0 to Count - 1 do begin
      PIndexes^ := IndexByCode( PSCodes^ );
      if PIndexes^ >= 0 then Inc(Result);
      Inc( PIndexes );
      Inc( PSCodes );
    end;
end; //*** function K_BuildDataProjectionBySCodes

//************************************************ K_GetAllCSProjections ***
//  returns Array of all CS Projections
//
function K_GetAllCSProjections( SrcDCS, DestDCS : TK_UDDCSpace ) : TN_UDArray;
var
  i, j : Integer;
  UDProj : TN_UDBase;
  FullCSS : TK_UDDCSSpace;
begin
  FullCSS := DestDCS.CreateDCSSpace;
  SetLength( Result, FullCSS.DirLength );
  j := 0;
  for i := 0 to High(Result) do begin
    UDProj := FullCSS.DirChild( i );
    if not TK_UDVector(UDProj).IsDCSProjection or
       (TK_UDDCSSpace(UDProj).GetDCSpace <> SrcDCS) then Continue;
    Result[j] := UDProj;
    Inc(j);
  end;
  SetLength( Result, j );
end; //*** function K_GetAllCSProjections

//*************************************** K_GetDVectorDType
// Get Data Vector record Type Code
//
function  K_GetDVectorDType() : TK_ExprExtType;
begin
  if K_DVectorDType.All = 0 then
    K_DVectorDType := K_GetTypeCodeSafe('TK_DVector');
  Result := K_DVectorDType;
end; //*** end of function K_GetFormCDescrDType

//*************************************** K_GetDSSVectorDType
// Get Data SubSpace Linked Vector record Type Code
//
function  K_GetDSSVectorDType() : TK_ExprExtType;
begin
  if K_DSSVectorDType.All = 0 then
    K_DSSVectorDType := K_GetTypeCodeSafe('TK_DSSVector');
  Result := K_DSSVectorDType;
end; //*** end of function K_GetDSSVectorDType

//*************************************** K_GetDSSTableDType
// Get Data SubSpace Linked Vector record Type Code
//
function  K_GetDSSTableDType() : TK_ExprExtType;
begin
  if K_DSSTableDType.All = 0 then
    K_DSSTableDType := K_GetTypeCodeSafe('TK_DSSTable');
  Result := K_DSSTableDType;
end; //*** end of function K_GetDSSTableDType

//********************************************* K_CreateUDVector0
// Create new Data Vector
//
function K_CreateUDVector0( DVectorName : string; Count : Integer;
                ElemTypeCode : Int64;
                SelfTypeCode : Int64;
                PData : Pointer = nil;
                UDClassInd : Integer = K_UDVectorCI ) : TK_UDVector;
begin
  if SelfTypeCode = 0 then SelfTypeCode := K_GetTypeCodeSafe( 'TK_DVector' ).All;
  Result := TK_UDVector(
        K_CreateUDByRTypeCode( SelfTypeCode, 1, UDClassInd ) );

  with Result do begin
    ObjName := DVectorName;
    with TK_PDVector(R.P)^ do begin
      D := K_RCreateByTypeCode (ElemTypeCode, Count, [K_crfCountUDref]);
      if PData <> nil then
        D.SetElems( PData^ );
    end;
  end;

end; // end_of function K_CreateUDVector0

//********************************************* K_ExportUDVector
// Export UDVector to Text Strings
//
procedure K_ExportUDVector( TS : TStrings; UDVector : TK_UDVector;
              SMFormat : TN_StrMatrFormat = smfTab );
var
 CS : TStringList;
 i : Integer;
 StrMatr: TN_ASArray;
 VDType : TK_ExprExtType;
 Inds : TK_RArray;
 CCodes : TK_RArray;
 CNames : TK_RArray;
 CInd : Integer;
// Wstr : string;

begin
  CS := TStringList.Create;
  with UDVector do begin
    CS.Add(K_UDVFElemType + '=' + K_GetExecTypeName( PDRA.ElemType.All ) );
    CS.Add(K_UDVFSelfType + '=' + K_GetExecTypeName( R.ElemType.All ) );
    CS.Add(K_UDVFSelfUDType + '=' + N_ClassTagArray[CI] );
    CS.Add(K_UDVFSelfName + '=' + ObjName  );
    CS.Add(K_UDVFSelfAliase + '=' + ObjAliase );
    with GetDCSSpace do begin
      Inds := PDRA^;
      CS.Add(K_UDVFCSSName + '=' + ObjName  );
      CS.Add(K_UDVFCSSAliase + '=' + ObjAliase  );
      with GetDCSpace do begin
        with TK_PDCSpace( R.P )^ do begin
          CCodes := Codes;
          CNames := Names;
        end;
        CS.Add(K_UDVFCSUName + '=' + GetUName  );
      end;
    end;
  end;
//  WStr := K_SPLValueToString( SMFormat,
//                   K_GetTypeCodeSafe( 'TN_StrMatrFormat' ) );
//  CS.Add( K_UDVSDFormat + '='+ Copy( WStr, 1, Length(WStr) - 1 ) );
  CS.Add( K_UDVSDFormat + '='+ K_SPLValueToString( SMFormat,
                   K_GetTypeCodeSafe( 'TN_StrMatrFormat' ) ) );
//                   K_GetTypeCodeSafe( 'TK_StringFileFormat' ) ) );
  TS.Add( CS.CommaText );
  SetLength( StrMatr, UDVector.PDRA.ALength );
  N_AdjustStrMatr( StrMatr, 3 );
  VDType := UDVector.PDRA.ElemType;
  for i := 0 to High(StrMatr) do begin
    StrMatr[i, 0] := K_SPLValueToString( UDVector.DP(i)^, VDType );
    CInd := PInteger( Inds.P(i) )^;
    StrMatr[i, 1] := PString( CCodes.P(CInd) )^;
    StrMatr[i, 2] := PString( CNames.P(CInd) )^;
  end;
//  N_SaveStrMatrToStrings( StrMatr, TS, SDFormat );
  N_SaveSMatrToStrings( StrMatr, TS, SMFormat );
  CS.Free;
end; // end_of procedure K_ExportUDVector

//********************************************* K_CreateUDVector
// Creat UDVector and load its fields from Text String
//
function K_CreateUDVector( TS : TStrings; CS : TStrings = nil ) : TK_UDVector;
var
  WS, WSTmp : TStringList;
  i, iBegSMatr : Integer;
  StrMatr: TN_ASArray;
  VDType : TK_ExprExtType;
  WElemType, SelfUDType, SelfName, SelfAliase, SelfType, CSUName,
  CSSName, CSSAliase, SDFName : string;
  SMF : TN_StrMatrFormat;
  DCSpace : TK_UDDCSpace;
  DCSSpace : TK_UDDCSSpace;
  DCSLength : Integer;
  ACodes : TN_SArray;
  AInds : TN_IArray;
  CurInd :Integer;
  LVals :Integer;
  ErrStr : string;

 procedure GetValuesFromList( SL : TStrings );
 var
   WW : string;
 begin
  if WElemType = '' then
    WElemType := WS.Values[K_UDVFElemType];
  if SelfType = '' then
    SelfType := WS.Values[K_UDVFSelfType];
  if SelfUDType = '' then
    SelfUDType := WS.Values[K_UDVFSelfUDType];
  if SelfName = '' then
    SelfName := WS.Values[K_UDVFSelfName];
  if SelfAliase = '' then
    SelfAliase := WS.Values[K_UDVFSelfAliase];
  if CSSName = '' then
    CSSName := WS.Values[K_UDVFCSSName];
  if CSSAliase = '' then
    CSSAliase := WS.Values[K_UDVFCSSAliase];
  if CSUName = '' then
    CSUName := WS.Values[K_UDVFCSUName];
  WW := WS.Values[K_UDVSDFormat];
  if WW <> '' then
    SDFName := WW;
 end;

begin
//*** Parse Command Line
  WS := TStringList.Create;
  WSTmp := TStringList.Create;
//  WS.CommaText := TS[0];

  iBegSMatr := N_GetSectionFromStrings( TS, WSTmp, 'Params' );
  N_s := WSTmp.Text;
  WS.CommaText := WSTmp.Text;
  WSTmp.Free;

  if CS <> nil then
    GetValuesFromList( CS );
  GetValuesFromList( WS );
  if SDFName = '' then
    SMF := smfTab
  else
    K_SPLValueFromString( SMF,
//                   K_GetTypeCodeSafe( 'TK_StringFileFormat' ).All,
                   K_GetTypeCodeSafe( 'TN_StrMatrFormat' ).All,
                   SDFName );
  if CS <> nil then begin
    CS.Clear;
    CS.AddStrings( WS );
  end;

//*** Parse StrMatr
  WS.Clear;
  for i := iBegSMatr to TS.Count - 1 do  WS.Add( TS[i] );

  K_LoadSMatrFromStrings( StrMatr, WS, SMF );

  LVals := Length(StrMatr);

//*** Find CS
  with K_CurSpacesRoot do begin
    DCSpace := nil;
    if CSUName <> '' then
      DCSpace := TK_UDDCSpace( DirChildByObjName( CSUName, K_ontObjUName ) );
    if DCSpace = nil then
      DCSpace  := TK_UDDCSpace( DirChild(0) );
    if DCSpace = nil then
      raise TK_LoadUDVectorError.Create( 'Wrong Code Space Reference' );
    DCSLength := TK_PDCSpace(DCSpace.R.P).Codes.ALength;
  end;

//*** Check Codes
  if LVals > DCSLength then
      raise TK_LoadUDVectorError.Create( 'Vector is larger then Code Space' );

  SetLength( ACodes, Length(StrMatr) );
  for i := 0 to High(StrMatr) do
    ACodes[i] := StrMatr[i,1];

  for i := 0 to High(ACodes) - 1 do begin
    CurInd := K_IndexOfStringInRArray( ACodes[i], @ACodes[i+1], High(ACodes) - i );
    if CurInd <> - 1 then
      raise TK_LoadUDVectorError.Create( 'Same Codes in ['+IntToStr(i)+'] and ['
                                     +IntToStr(i+CurInd+1)+ ']');
  end;

//*** Build CSS Indexes
  SetLength( AInds, LVals );
  for i := 0 to High(AInds) do begin
    CurInd := K_IndexOfStringInRArray( ACodes[i], TK_PDCSpace( DCSpace.R.P ).Codes.P, DCSLength, SizeOf(string) );
    if CurInd = - 1 then
      raise TK_LoadUDVectorError.Create( 'Code '+ACodes[i]+
           ' is absent in Code Space "'+DCSpace.GetUName+'"' );
    AInds[i] := CurInd;
  end;

//*** Search for existing CSS
  CurInd := -1;
  DCSSpace := nil;
  with DCSpace.GetSSpacesDir do
    for i := 0 to DirHigh do begin
      DCSSpace := TK_UDDCSSpace( DirChild(i) );
      if (DCSSpace.ObjName = DCSpace.ObjName) or // skip Full CSS
         (DCSSpace.PDRA.ALength <> LVals)     or // Different Elements Count
         not CompareMem( @AInds[0], DCSSpace.DP, // Different Elements Values
                          LVals * SizeOf(Integer) ) then Continue;
      CurInd := i;
      break;
    end;

//*** Create New CSS
  if CurInd = -1 then begin
    if CSSName = '' then CSSName := K_FDCSpaceNewName;
    DCSSpace := DCSpace.CreateDCSSpace( CSSName, LVals );
    DCSSpace.ObjAliase := CSSAliase;
    Move( AInds[0], DCSSpace.DP^, LVals * SizeOf(Integer) );
  end;

//*** Create UDVector
  VDType := K_GetTypeCodeSafe( WElemType );
  Result := DCSSpace.CreateDVector( SelfName,
                VDType.All, nil, K_GetTypeCodeSafe( SelfType ).All,
                K_GetUObjCIByTagName( SelfUDType ) );
  Result.ObjAliase := SelfAliase;

//*** Load values
  for i := 0 to LVals - 1 do begin
    ErrStr := K_SPLValueFromString( Result.DP(i)^, VDType.All, StrMatr[i,0] );
    if (ErrStr <> '') and
       ( (VDType.DTCode > Ord(nptNoData)) and (Ord(VDType.FD.FDObjType) < Ord(K_fdtEnum)) ) then
//       ((VDType.D.TFlags and K_ffEnumSet) = 0) then
      raise TK_LoadUDVectorError.Create('Wrong V['+ StrMatr[i,2]+
                                                '] value while loading '+ErrStr );
  end;

  WS.Free;
  K_SetChangeSubTreeFlags( Result );

end; // end_of function K_CreateUDVector

//*************************************** K_IfSameProjDst
// Check if given DCSpace Codes projected to the same Element
//
//    Parameters
// APCodes  - pointer to CS Elements codes
// ACNum    - number of codes
// ADCSProj - CS Projection
// Result   - Returns
//#F
//  0 - if all given Elements are projected to the same Actual Element
//  1 - if some given Elements are projected to different Actual Elements
// -1 - if all given Elements are projected to not Actual Elements
//
//#/F
//
function  K_IfSameProjDst( APCodes : PInteger; ACNum : Integer; ADCSProj : TK_UDVector ) : Integer;
var
  i : Integer;
  CurDstInd, CurSrcInd, WInd : Integer;
begin
  Result := 1;
  CurDstInd := -1;
  with ADCSProj.GetDCSSpace.GetDCSpace do
     for i := 1 to ACNum do
     begin
       CurSrcInd := IndexByCode( IntToStr(APCodes^) );
       WInd := PInteger(ADCSProj.PDE(CurSrcInd))^;
       if (CurDstInd >= 0) or (WInd >= 0) then
       begin
       // Current or New Projected Elements are actual - check equivalence
         if CurDstInd < 0 then
           CurDstInd := WInd   // First New Actual Projected Element is found
         else if (WInd >= 0) and (CurDstInd <> WInd)  then
           Exit;               // Current Projected Element is not equal to New
       end;
       Inc(APCodes);
    end;
  Result := 0;
  if CurDstInd < 0 then
    Result := -1; // All given Elements are projected to not Actual Elements
end; //*** end of function K_IfSameProjDst

//*********************************************
//***          end of Global Routines
//*********************************************

{*** TK_UDDCSpace ***}

//********************************************** TK_UDDCSpace.Create ***
//
constructor TK_UDDCSpace.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDDCSpaceCI;
  ImgInd := 15;
end; // end_of constructor TK_UDDCSpace.Create

//********************************************* TK_UDDCSpace.PascalInit
// Pascal R structure Initialization
//
procedure TK_UDDCSpace.PascalInit;
var
  SSRoot : TN_UDBase;
begin
  inherited;
  with TK_PDCSpace( R.P )^ do begin
    Codes := K_RCreateByTypeCode( Ord(nptString) );
    Names := K_RCreateByTypeCode( Ord(nptString) );
    Keys  := K_RCreateByTypeCode( Ord(nptString) );
  end;
  SSRoot := TN_UDBase.Create;
  with AddOneChild( SSRoot ) do begin
    ObjName := K_dcsSSSpacesName;
    ObjAliase := K_dcsSSSpacesAliase;
    K_AddSysObjFlags( Self, SSRoot, K_sftReplace );
  end;

end; // end_of procedure TK_UDDCSpace.PascalInit

//********************************************* TK_UDDCSpace.SelfCount
// Get Code Space SubSpaces Dir
//
function TK_UDDCSpace.SelfCount : Integer;
begin
  Result := TK_PDCSpace(R.P).Codes.ALength;
end; // end_of procedure TK_UDDCSpace.SelfCount

//********************************************** TK_UDDCSpace.SelfDelete ***
//
function TK_UDDCSpace.SelfDelete1  : Boolean;
var
  i, h, CDelta, NVectors : Integer;
  CSS : TK_UDVector;

  function TestVectors (UDCSSpace : TK_UDDCSSpace; MaxRef : Integer; out NumVectors : Integer) : Boolean;
  var
    j,s : Integer;
  begin
    Result := false;
    with UDCSSpace.GetVectorsDir do begin
      NumVectors := DirLength;
      s := NumVectors - 1;
      for j := 0 to s do
        if DirChild(j).RefCounter > MaxRef then Exit;
    end;
    Result := true;
  end;

begin
// Test Aliases
  Result := false;
  with GetAliasesDir do begin
    h := DirHigh;
    for i := 0 to h do
      if DirChild(i).RefCounter > 2 then Exit;
  end;
// Test SubSpaces And It Data Vectors
  with GetSSpacesDir do begin
    h := DirHigh;
    for i := 0 to h do begin
      CSS := TK_UDVector(DirChild(i));
      if CSS.IsDCSProjection then begin
      //*** projection test
         if CSS.RefCounter > 2 then Exit; // projection is used
      end else begin
      //*** CSS test
         if CSS.ObjName = ObjName then
           CDelta := 2    // Special full DCSSpace
         else
           CDelta := 1;   // Ordinary DCSSpace
         if not TestVectors ( TK_UDDCSSpace(CSS), CDelta, NVectors ) or
            ( NVectors + CDelta < CSS.RefCounter ) then Exit; // CSS is used
      end;
    end;
    for i := 0 to h do begin
      CSS := TK_UDVector(DirChild(i));
      if CSS.IsDCSProjection then begin
      //*** projection delete
        K_DCSpaceProjectionDelete( TK_UDDCSSpace(CSS) );
      end;
    end;
  end;
  Include(K_UDOperateFlags, K_udoUNCDeletion);
  K_CurSpacesRoot.DeleteOneChild(Self);
  Exclude(K_UDOperateFlags, K_udoUNCDeletion);
  Result := true;

end; // end_of procedure TK_UDDCSpace.SelfDelete

//********************************************* TK_UDDCSpace.AliasesInit
// Pascal R structure Initialization
//
procedure TK_UDDCSpace.AliasesInit;
var
  SSRoot : TN_UDBase;
begin
  SSRoot := CreateDCSSpace.CreateDTable( K_dcsSEAliasesName, Ord(nptString) );
  with AddOneChild( SSRoot ) do begin
    ObjAliase := K_dcsSEAliasesAliase;
    K_AddSysObjFlags( Self, SSRoot, K_sftReplace );
  end;
  K_SetChangeSubTreeFlags( SSRoot );

end; // end_of procedure TK_UDDCSpace.AliasesInit

//********************************************* TK_UDDCSpace.CreateDCSSpace
// Create new Code SubSpace if needed
//
function TK_UDDCSpace.CreateDCSSpace( DCSSpaceName : string = ''; Count : Integer = -1;
                                      DCSSpaceAliase : string = '' ) : TK_UDDCSSpace;
var
  i, h : Integer;
//  WAliase : string;
  WSSRoot : TN_UDBase;
  FullCSS : Boolean;
begin
  WSSRoot := GetSSpacesDir;
  with WSSRoot do begin
//    WAliase := '';
    FullCSS := false;
    if DCSSpaceName = '' then begin
    //*** Search for special full DCSSpace
        i := IndexOfChildObjName( Self.ObjName );
        if i <> -1 then begin
          Result := TK_UDDCSSpace( DirChild( i ) );
          Exit;
        end else begin
          DCSSpaceName := Self.ObjName;
          DCSSpaceAliase := Self.ObjAliase;
          FullCSS := true;
        end;
    end;
//  else  WAliase := DCSSpaceAliase;
    if Count < 0 then
      h := SelfCount
    else
      h := Count;
  //*** Create Full SubSpace
    Result := TK_UDDCSSpace( K_CreateUDVector0( DCSSpaceName, h,
                Ord(nptInt), K_GetDVectorDType.All, nil, K_UDDCSSpaceCI ) );

    if Count < 0 then begin
  //*** Build Full SubSpace Indexes
      RebuildFullCSS( h, Result );
    end;

    if DCSSpaceAliase = '' then DCSSpaceAliase := DCSSpaceName;
    Result.ObjAliase := DCSSpaceAliase;

  //*** Add New SubSpace to Code Space "SubSpaces"
    AddOneChild( Result );
    SetUniqChildName( Result );
    K_AddSysObjFlags( WSSRoot, Result, K_sftSkipAll );
    if FullCSS then begin
      Result.CreateVectorsDir;
      Result.ObjVFlags[0] := K_fvUseCurrent or K_fvSkipDE; // Hide Full CSS
    end;
    K_SetChangeSubTreeFlags( Result );
  end;

end; // end_of procedure TK_UDDCSpace.CreateDCSSpace

//********************************************* TK_UDDCSpace.GetSSpacesDir
// Get Code Space SubSpaces Dir
//
function TK_UDDCSpace.GetSSpacesDir : TN_UDBase;
begin
  Result := DirChild(K_dcsSSSpacesRInd);
end; // end_of procedure TK_UDDCSpace.GetSSpacesDir

//********************************************* TK_UDDCSpace.GetAliasesDir
// Get Code Space Aliases Dir
//
function TK_UDDCSpace.GetAliasesDir : TK_UDSSTable;
begin
  Result := TK_UDSSTable(DirChild(K_dcsSEAliasesRInd));
end; // end_of function TK_UDDCSpace.GetAliasesDir

//********************************************* TK_UDDCSpace.IndexByCode
// Get DCSpase Index By Code Value
//
function TK_UDDCSpace.IndexByCode( Code : string ) : Integer;
var
  FUDCSS : TK_UDDCSSpace;
begin
  with GetSSpacesDir do
    FUDCSS := TK_UDDCSSpace( DirChildByObjName( Self.ObjName ) );
  if FUDCSS <> nil then
    Result := FUDCSS.IndexByCode( Code )
  else
    with TK_PDCSpace(R.P)^ do
      Result := K_IndexOfStringInRArray( Code, PString(Codes.P), SelfCount );
end; // end_of function TK_UDDCSpace.IndexByCode
{
//********************************************* TK_UDDCSpace.ChangeValue
// Change Order In Self Structure and All SubSpace
// according to specified Data Projection to Space Previouse State
//
procedure TK_UDDCSpace.ChangeValue( PDPindex : PInteger; Count : Integer );
var
  k : Integer;
  WCodes, WNames, WKeys : TN_SArray;
begin
  ChangeDCSSOrder( PDPindex, Count );
  k := SelfCount;
  SetLength( WCodes, k );
  SetLength( WNames, k );
  SetLength( WKeys, k );
  with TK_PDCSpace(R.P)^ do begin
    K_MoveSPLVector( WCodes[0], SizeOf(string), Codes.P^, SizeOf(string), k, Ord(nptString) );
    K_MoveSPLVector( WNames[0], SizeOf(string), Names.P^, SizeOf(string), k, Ord(nptString) );
    K_MoveSPLVector( WKeys[0], SizeOf(string),Keys.P^, SizeOf(string), k, Ord(nptString) );
    Codes.ASetLength( Count );
    Names.ASetLength( Count );
    Keys.ASetLength( Count );
    K_MoveSPLVectorBySIndex( WCodes[0], SizeOf(string), Codes.P^, SizeOf(string), Count, Ord(nptString), [], PDPindex );
    K_MoveSPLVectorBySIndex( WNames[0], SizeOf(string), Names.P^, SizeOf(string), Count, Ord(nptString), [], PDPindex );
    K_MoveSPLVectorBySIndex( WKeys[0], SizeOf(string),Keys.P^, SizeOf(string), Count, Ord(nptString), [], PDPindex );
  end;

end; // end_of procedure TK_UDDCSpace.ChangeValue
}
{
//********************************************* TK_UDDCSpace.CheckDCSS()
//
procedure TK_UDDCSpace.CheckDCSS();
var
  j : Integer;
  WDCSSpace : TK_UDDCSSpace;
begin

  with GetSSpacesDir do begin
    for j := 0 to DirHigh do begin
      WDCSSpace := TK_UDDCSSpace( DirChild(j) );
if WDCSSpace.CodesList <> nil then
WDCSSpace.CodesList := WDCSSpace.CodesList;
    end;
  end;
end; // end_of procedure TK_UDDCSpace.ChangeDCSSOrder
}

//********************************************* TK_UDDCSpace.ChangeDCSSOrder
// Change Order In All SubSpace according to given Data Projection to Space Previouse State
//
procedure TK_UDDCSpace.ChangeDCSSOrder(PDPindex: PInteger; Count: Integer);
var
  k, j : Integer;
  WDCSSpace : TK_UDDCSSpace;
  ConvInds : TN_IArray;
begin

  with GetSSpacesDir do begin
    k := Max(Count, SelfCount);
    SetLength( ConvInds, k );
    K_BuildBackIndex0( PDPindex, Count, @ConvInds[0], k );
    k := DirHigh;
    for j := 0 to k do begin
      WDCSSpace := TK_UDDCSSpace( DirChild(j) );
      if WDCSSpace.ObjName <> Self.ObjName then begin
      //*** odinary SubSpace
        K_RebuildCSSByConvIndex( WDCSSpace, @ConvInds[0] );
        if WDCSSpace.CI = K_UDDCSSpaceCI then // WDCSSpace - may be TK_UDVector if it is Projection
          FreeAndNil( WDCSSpace.CodesList );
//        K_DCSSpaceChangeSpaceIndex( WDCSSpace, PDPindex, Count )
      end else if Count > 0 then begin
      //*** full SubSpace
        WDCSSpace.ChangeDVectorsOrder( PDPindex, Count );
      //*** Rebuild Full SSpace Indexes
        RebuildFullCSS( Count, WDCSSpace );
      end;
    end;
  end;
end; // end_of procedure TK_UDDCSpace.ChangeDCSSOrder

//********************************************* TK_UDDCSpace.RebuildFullDCSS
// Rebuild Full CSS
//
function TK_UDDCSpace.RebuildFullCSS( Count : Integer; FCSS : TK_UDDCSSpace = nil ) : TK_UDDCSSpace;
var
  i : Integer;
  PInd : PInteger;
//  WDCSSpace : TK_UDDCSSpace;
begin
  if FCSS = nil then
    with GetSSpacesDir do
      FCSS := TK_UDDCSSpace( DirChildByObjName( Self.ObjName ) );
  with FCSS.PDRA^ do begin
    ASetLength( Count );
    PInd := PInteger( P );
  end;
  for i := 0 to Count - 1 do begin
    PInd^ := i;
    Inc( PInd );
  end;
  Result := FCSS;
  FreeAndNil( FCSS.CodesList );
end; // end_of procedure TK_UDDCSpace.RebuildFullCSS

//********************************************* TK_UDDCSpace.IndexOfCSS
// Search for CSS with equal Indexes
//
function TK_UDDCSpace.IndexOfCSS( PData: Pointer; Count: Integer ): TK_UDDCSSpace;
var
  i : Integer;
begin
  if Count > 0 then
    with GetSSpacesDir do
      for i := 0 to DirHigh do begin
        Result := TK_UDDCSSpace(DirChild(i));
        if (Result.ObjName <> Self.ObjName)   and // not Full CSS
           (Count = Result.PDRA.ALength)      and // equal length
           CompareMem( Result.DP, PData, Count * SizeOf(Integer) ) then
          Exit;
      end;
  Result := nil;
end; // end_of function TK_UDDCSpace.IndexOfCSS

//********************************************* TK_UDDCSpace.SearchProjByCSS
// Search CSS elements Self Projection
//
//     Parameters
// AUDDCSSpace - SubSpace for which elements Self Projection is needed
// Result - needed Data Projection or nil
//
function TK_UDDCSpace.SearchProjByCSS( AUDDCSSpace: TK_UDDCSSpace ): TK_UDVector;
var
  i, CSSInd, CSProjInd : Integer;
  FullSpace : TN_IArray;
  Count, VCount : Integer;
  CSSInds : PInteger;
  SearchDir : TN_UDBase;
  UDProj  : TN_UDBase;

  function CheckProj( CSProjInds : PInteger ) : Boolean;
  var
    i : Integer;
    UsedCount : Integer;
  begin
    UsedCount := 0;
    for i := 0 to VCount - 1 do
    begin
      CSSInd := CSSInds^;
      Inc(CSSInds);
      CSProjInd := PInteger(TN_BytesPtr(CSProjInds) + CSSInd * SizeOf(Integer))^;
      if CSProjInd = -1 then Continue; // Not Used Projection Element
      Inc(UsedCount);
      if FullSpace[CSProjInd] <> -1 then Continue; // Element Projection Leades to Used Element
      Result := FALSE;
      Exit;
    end;
    Result := UsedCount > 0;
  end; // function CheckProj

begin
  Result := nil;
  if AUDDCSSpace.GetDCSpace <> Self then Exit; // Different DCSpace
  SearchDir := GetSSpacesDir;
  SearchDir := SearchDir.DirChildByObjName( Self.ObjName ); // No DCSpaces
  if SearchDir = nil then Exit;
  SearchDir := TK_UDDCSSpace(SearchDir).GetVectorsDir;

// Fill Full Space Array by "1" in given DCSSpace Elements
  Count := SelfCount();
  SetLength( FullSpace, Count );
  FillChar( FullSpace[0], SizeOf(Integer) * Count, -1 );
  VCount := AUDDCSSpace.PDRA.ALength;
  CSSInds := AUDDCSSpace.DP;
  i := 1;
  K_MoveVectorByDIndex( FullSpace[0], SizeOf(Integer), i, 0, SizeOf(Integer),
                        VCount, AUDDCSSpace.DP );

// Search Proper Projection Loop
  for i := 0 to SearchDir.DirHigh do
  begin
    UDProj := SearchDir.DirChild(i);
    if not TK_UDVector(UDProj).IsDCSProjection then Continue;
    CSSInds := AUDDCSSpace.DP;
    if not CheckProj( TK_UDVector(UDProj).DP ) then Continue;
    Result := TK_UDVector(UDProj);
    Exit;
  end;
end; // end_of function TK_UDDCSpace.SearchProjByCSS

//********************************************* TK_UDDCSpace.SearchProjByCSS
// Search CSS elements Self Projection
//
//     Parameters
// AUDDCSSpace - SubSpace for which elements Self Projection is needed
// Result - needed Data Projection or nil
//
function TK_UDDCSpace.SearchProjByElemIndex( AElemInd : Integer ): TK_UDVector;
var
  i : Integer;
  Count : Integer;
  SearchDir : TN_UDBase;
  UDProj  : TN_UDBase;

begin
  Result := nil;
  SearchDir := GetSSpacesDir;
  SearchDir := SearchDir.DirChildByObjName( Self.ObjName ); // No DCSpaces
  if SearchDir = nil then Exit;
  SearchDir := TK_UDDCSSpace(SearchDir).GetVectorsDir;
  Count := SelfCount();

// Search Proper Projection Loop
  for i := 0 to SearchDir.DirHigh do
  begin
    UDProj := SearchDir.DirChild(i);
    if not TK_UDVector(UDProj).IsDCSProjection then Continue;
    if 0 > K_IndexOfIntegerInRArray( AElemInd, PInteger(TK_UDVector(UDProj).DP), Count ) then Continue;
    Result := TK_UDVector(UDProj);
    Exit;
  end;
end; // end_of function TK_UDDCSpace.SearchProjByCSS

//********************************************* TK_UDDCSpace.TK_UDDCSpace.GetItemsInfo
// Get CS Items Info
//
procedure  TK_UDDCSpace.GetItemsInfo( PResult : PString;
        AInfoType: TK_CSInfoType; Index: Integer;
        ILength : Integer = 1; IStep : Integer = SizeOf(string) );
var
  i, h : Integer;
begin
  h := SelfCount;
  if (Index < 0) then Index := Index + h;
  if (Index < 0) or (Index >= h) then Exit;
  ILength := Index + ILength - 1;
  if ILength >= h then ILength := h - 1;
  for i := Index to ILength do begin
    with TK_PDCSpace(R.P)^ do
      case AInfoType of
      K_csiCSCode:     PResult^ := PString(Codes.P(i))^;
      K_csiCSName:     PResult^ := PString(Names.P(i))^;
      K_csiCSEntryKey: PResult^ := PString(Keys.P(i))^;
      K_csiSclonKey:   PResult^ := PString(Names.P(i))^;
      end; // case ATokenType of
    Inc( TN_BytesPtr(PResult), IStep );
  end;
end; // end_of procedure TK_UDDCSpace.GetItemsInfo

//********************************************* TK_UDDCSpace.GetItemInfoPtr
// Search for CSS with equal Indexes
//
function TK_UDDCSpace.GetItemInfoPtr( AInfoType: TK_CSInfoType; Index: Integer ): PString;
var
  h : Integer;
begin
  Result := @N_NotDefStr;
  h := SelfCount;
  if (Index < 0) or (Index >= h) then Exit;
  with TK_PDCSpace(R.P)^ do
    case AInfoType of
    K_csiCSCode:     Result := PString(Codes.P(Index));
    K_csiCSName:     Result := PString(Names.P(Index));
    K_csiCSEntryKey: Result := PString(Keys.P(Index));
    K_csiSclonKey:   Result := PString(Names.P(Index));
    end; // case AInfoType of
end; // end_of function TK_UDDCSpace.GetItemInfoPtr


{*** end of TK_UDDCSpace ***}

{*** TK_UDDCSSpace ***}

//********************************************** TK_UDDCSSpace.Create ***
//
constructor TK_UDDCSSpace.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDDCSSpaceCI;
  ImgInd := 16;
end; // end_of constructor TK_UDDCSSpace.Create

//********************************************** TK_UDDCSSpace.Create ***
//
destructor TK_UDDCSSpace.Destroy;
begin
  CodesList.Free;
  inherited;
end;

//********************************************** TK_UDDCSSpace.SelfDelete ***
//
function TK_UDDCSSpace.SelfDelete : Boolean;
begin
  Result := false;
  if RefCounter > 1 then Exit; //
  Include(K_UDOperateFlags, K_udoUNCDeletion);
  Owner.DeleteOneChild( Self );
  Exclude(K_UDOperateFlags, K_udoUNCDeletion);
  Result := true;
end; // end_of constructor TK_UDDCSSpace.SelfDelete

{
//********************************************* TK_UDDCSSpace.PascalInit
// Pascal R structure Initialization
//
procedure TK_UDDCSSpace.PascalInit;
var
  VRoot : TN_UDBase;
begin
  inherited;
  VRoot := AddOneChild( TN_UDBase.Create );
  with VRoot do begin
    ObjUFlags[0].EntryFlags := K_fuUseCurrent or K_fuDEDataReplace;
    ObjName := K_dcsSSVectorsName;
    ObjAliase := K_dcsSSVectorsAliase;
    K_AddSysObjFlags( Self, VRoot, K_sftAddUnicRefs );
  end;

end; // end_of procedure TK_UDDCSSpace.PascalInit
}

//********************************************* TK_UDDCSSpace.CreateVectorsDir
// Pascal R structure Initialization
//
procedure TK_UDDCSSpace.CreateVectorsDir;
var
  VRoot : TN_UDBase;
begin
  inherited;
  VRoot := AddOneChild( TN_UDBase.Create );
  with VRoot do begin
    ObjUFlags[0].EntryFlags := K_fuUseCurrent or K_fuDEDataReplace;
    ObjName := K_dcsSSVectorsName;
    ObjAliase := K_dcsSSVectorsAliase;
    K_AddSysObjFlags( Self, VRoot, K_sftAddUniqRefs );
  end;

end; // end_of procedure TK_UDDCSSpace.CreateVectorsDir

//********************************************* TK_UDDCSSpace.GetDCSpace
// Get Code SubSpace  Code Space
//
function TK_UDDCSSpace.GetDCSpace : TK_UDDCSpace;
begin
  Result := nil;
  if Self <> nil then
    Result := TK_UDDCSpace(Owner.Owner);
end; // end_of procedure TK_UDDCSSpace.GetDCSpace

//********************************************* TK_UDDCSSpace.GetVectorsDir
// Get Code SubSpace Vectors Dir
//
function TK_UDDCSSpace.GetVectorsDir : TN_UDBase;
begin
  Result := DirChild(K_dcsSSVectorsRInd);
end; // end_of procedure TK_UDDCSSpace.GetVectorsDir

//***************************************** TK_UDDCSSpace.ChangeDVectorsOrder
//  Change Data Order in Vectors linked to DCSubSpace using
//   data projection to new Dtata Structure
//
procedure TK_UDDCSSpace.ChangeDVectorsOrder( PDPIndex : PInteger; Count : Integer );
var
//  i, h : Integer;
//  UD : TN_UDBase;
  i : Integer;
  CSSUDVList : TK_BuildCSSUDVList;
  UDVList : TList;
begin
//*** change vectors elements order
  CSSUDVList := TK_BuildCSSUDVList.Create;
  UDVList := CSSUDVList.Build( K_CurArchive, Self);
  for i := 0 to UDVList.Count - 1 do
    TK_UDVector(UDVList[i]).ChangeElemsOrder( PDPIndex, Count );

  CSSUDVList.Free;
end; // end_of procedure TK_UDDCSSpace.ChangeDVectorsOrder

procedure TK_UDDCSSpace.ChangeDVectorsOrder( PConvInds: PInteger; ConvIndsCount : Integer;
                          PFreeInds: PInteger; FreeIndsCount : Integer;
                          PInitInds: PInteger; InitIndsCount : Integer );
var
//  i, h : Integer;
//  UD : TN_UDBase;
  i : Integer;
  CSSUDVList : TK_BuildCSSUDVList;
  UDVList : TList;
begin
//*** change vectors elements order
  CSSUDVList := TK_BuildCSSUDVList.Create;
  UDVList := CSSUDVList.Build( K_CurArchive, Self);
  for i := 0 to UDVList.Count - 1 do
    TK_UDVector(UDVList[i]).PDRA.ReorderElems( PConvInds, ConvIndsCount,
                          PFreeInds, FreeIndsCount,
                          PInitInds, InitIndsCount );
  CSSUDVList.Free;
end; // end_of procedure TK_UDDCSSpace.ChangeDVectorsOrder

//********************************************* TK_UDDCSSpace.ChangeValue
// Change Code SubSpace Value
//
procedure TK_UDDCSSpace.ChangeValue( PNCSS: PInteger; Count: Integer;
                                     ChangeVectors : Boolean = true );
var
//  DataProj : TN_IArray;
  FullInds, ConvDataInds, FreeDataInds, InitDataInds : TN_IArray;

begin
{
// Prepare Data projectin for changing Linked Data Vectors
  SetLength( DataProj, Count );
  K_BuildCSSProjectionInds( @DataProj[0], PNCSS, Count,
                            DP, PDRA.ALength,
                            GetDCSpace.SelfCount );
// Prepare Data projection for changing Linked Data Vectors
  if ChangeVectors then
    ChangeDVectorsOrder( @DataProj[0], Count );
}
  if ChangeVectors then begin
    SetLength( FullInds, GetDCSpace.SelfCount );
    K_BuildConvDataIArraysByRACSDims( PNCSS, Count, DP, PDRA.ALength,
                                  @FullInds[0], Length(FullInds),
                                  ConvDataInds, FreeDataInds, InitDataInds );
    ChangeDVectorsOrder( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                      K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                      K_GetPIArray0(InitDataInds), Length(InitDataInds) );
  end;
// Change SubSpace Value
  PDRA.ASetLength( Count );
  Move( PNCSS^, DP^, SizeOf(Integer) * Count );
  FreeAndNil( CodesList );
end; // end_of procedure TK_UDDCSSpace.ChangeValue

//********************************************* TK_UDDCSSpace.LinkDVector
// Link new Data Vector
//
procedure TK_UDDCSSpace.LinkDVector( PDVector : Pointer );
begin
  with TK_PDSSVector(PDVector)^ do begin
    if CSS = Self then Exit;
    K_SetUDRefField( CSS, Self );
    D.ASetLength(Self.PDRA.ALength);
  end;
end; // end_of procedure TK_UDDCSSpace.LinkDVector

//********************************************* TK_UDDCSSpace.CreateDVector
// Create new Data Vector
//
function TK_UDDCSSpace.CreateDVector( DVectorName : string; ElemTypeCode : Int64;
                          PData : Pointer = nil; SelfTypeCode : Int64 = 0;
                          UDClassInd : Integer = K_UDVectorCI ) : TK_UDVector;
begin
  if SelfTypeCode = 0 then SelfTypeCode := K_GetDSSVectorDType.All;
  Result := K_CreateUDVector0( DVectorName, Self.PDRA.ALength,
                ElemTypeCode, SelfTypeCode, PData, UDClassInd );

  LinkDVector( Result.R.P );
  Result.Owner := nil;
end; // end_of procedure TK_UDDCSSpace.CreateDVector

//********************************************* TK_UDDCSSpace.CreateDTable
// Create new Data Vector
//
function TK_UDDCSSpace.CreateDTable( DTableName: string;
                                     ElemTypeCode: Int64 = 0;
                                     TabTypeCode: Int64 = 0;
                                     UDClassInd : Integer = K_UDSSTableCI ): TK_UDSSTable;
begin
  if TabTypeCode = 0 then TabTypeCode:= K_GetDSSTableDType.All;
  Result := TK_UDSSTable(
        K_CreateUDByRTypeCode( TabTypeCode, 1, UDClassInd ) );

  with Result do begin
    with TK_PDSSTable(R.P)^ do begin
      K_SetUDRefField( CSS, Self );
      DTCode := ElemTypeCode;
    end;
    ObjName := DTableName;
  end;

end; // end_of procedure TK_UDDCSSpace.CreateDTable

//********************************************* TK_UDDCSSpace.IndexByCode
// Get DCSSpase Index By Code Value
//
function TK_UDDCSSpace.IndexByCode( Code : string ) : Integer;
var
 i, h : Integer;
 WR : TK_RArray;
begin
  if CodesList = nil then begin
    CodesList := THashedStringList.Create;
    h := PDRA.AHigh;
    WR := TK_PDCSpace(GetDCSpace.R.P).Codes;
    for i := 0 to h do
      CodesList.Add( PString( WR.P( PInteger( DP(i) )^ ) )^ );
  end;
  Result := CodesList.IndexOf(Code);
end; // end_of function TK_UDDCSSpace.IndexByCode

{*** end of TK_UDDCSSpace ***}

{*** TK_UDVector ***}

//********************************************** TK_UDVector.Create ***
//
constructor TK_UDVector.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDVectorCI;
  ImgInd := 40;
end; // end_of constructor TK_UDVector.Create

{
//********************************************** TK_UDVector.Delete ***
//
procedure TK_UDVector.Delete( Parent : TN_UDBase = nil );
var
  VDir : TN_UDBase;
begin
  if (RefCounter <= 2) and not (Self is TK_UDDCSSpace) then begin
    VDir := GetDCSSpace.GetVectorsDir;
    if Parent <> VDir then VDir.DeleteOneChild( Self );
  end;
  if RefCounter >= 1 then  inherited;
end; // end_of constructor TK_UDVector.Delete
}

//************************************** TK_UDVector.BuildID ***
// Build  List Name
//
function TK_UDVector.BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string;
begin
  Result := inherited BuildID( BuildIDFlags );
  if (K_bnfUseObjVType in BuildIDFlags) then
    Result := Result + ':' + K_GetExecTypeName( PDRA.ElemType.All );
end; // end_of function TK_UDVector.BuildID

//********************************************** TK_UDVector.SelfDelete ***
//
function TK_UDVector.SelfDelete : Boolean;
begin
  Result := false;
//??!!  if RefCounter > 2 then Exit; //
  if RefCounter > 1 then Exit; //
  Include(K_UDOperateFlags, K_udoUNCDeletion);
//??!!  GetDCSSpace.GetVectorsDir.DeleteOneChild( Self );
  Owner.DeleteOneChild( Self );
  Exclude(K_UDOperateFlags, K_udoUNCDeletion);
  Result := true;
end; // end_of constructor TK_UDVector.SelfDelete

//********************************************* TK_UDVector.GetDCSSpace
// Get Data Vector Code SubSpace
//
function TK_UDVector.GetDCSSpace : TK_UDDCSSpace;
begin
  if Self = nil then begin
    Result := nil;
    Exit;
  end;
  Result := TK_UDDCSSpace(TK_PDSSVector(R.P).CSS);
//  Result := TK_UDDCSSpace( DirChild(K_dcsVSSpaceInd) );
end; // end_of procedure TK_UDVector.GetDCSSpace

//********************************************* TK_UDVector.PDRA
// Get Data Vector Values RArray
//
function TK_UDVector.PDRA : TK_PRArray;
begin
  Result := @TK_PDVector(R.P).D;
end; // end_of procedure TK_UDVector.PDRA


//********************************************* TK_UDRArray.PDE
// Get Pointer to Array Element
//
function TK_UDVector.PDE( Ind : Integer ) : Pointer;
begin
  Result := DP(Ind);
end; // end_of procedure TK_UDRArray.PDE

//********************************************* TK_UDVector.DP
// Get Data Vector Values RArray[0]
//
function TK_UDVector.DP : Pointer;
begin
  Result := TK_PDVector(R.P).D.P;
end; // end_of procedure TK_UDVector.DP

//********************************************* TK_UDVector.DP
// Get Data Vector Values RArray[0]
//
function TK_UDVector.DP( Ind : Integer ) : Pointer;
begin
  Result := TK_PDVector(R.P).D.P(Ind);
end; // end_of procedure TK_UDVector.DP

//********************************************* TK_UDVector.IsDCSProjection
//  Test if UDVector is DCSProjection
//
function TK_UDVector.IsDCSProjection : Boolean;
begin
  Result := (TK_UDDCSSpace(Self).GetDCSpace.CI = K_UDDCSpaceCI) and
            (TK_PDVector(R.P).D.ElemType.DTCode = Ord(nptInt))
end; // end_of function TK_UDVector.IsDCSProjection


//********************************************* TK_UDVector.GetDefaultValue
//  Get Default Value for Vector
//
procedure TK_UDVector.GetDefaultValue( PDefValue : Pointer );
var
  EType : TK_ExprExtType;
begin
  if IsDCSProjection then
    PInteger(PDefValue)^ := -1
  else
    with PDRA^ do  begin
      EType := ElemType;
      FillChar( PDefValue^, ElemSize, 0 );
      if EType.All = Ord(nptString) then
        PString(PDefValue)^ := '???'
      else if (((EType.All xor Ord(nptDouble)) and K_ffCompareTypesMask) = 0) and
              (R.ElemType.FD.ObjName = 'TK_MVVector') then // TK_MVVector Undef Value
//        with K_IniMVSpecVals do
        with K_CurMVSpecVals do
          PDouble(PDefValue)^ := TK_PMVDataSpecVal(P(AHigh)).Value;
    end;
end; // end_of procedure TK_UDVector.GetDefaultValue

//********************************************* TK_UDVector.ChangeElemsType
//  Change Elements Type
//
procedure TK_UDVector.ChangeElemsType( NewElemTypeCode : Int64 );
var
  VLength : Integer;
begin
  with PDRA^ do begin
   VLength := ALength;
   ARelease;
  end;
  PDRA^ := K_RCreateByTypeCode( NewElemTypeCode, VLength, [K_crfCountUDRef] );
end; // end_of procedure TK_UDVector.ChangeElemsType

//********************************************* TK_UDVector.ChangeElemsOrder
//  Change Elements Order
//
procedure TK_UDVector.ChangeElemsOrder( PDProj : PInteger; Count : Integer );
var
  VD : TK_RArray;
  EType : TK_ExprExtType;
begin
//*** change vectors elements order
  with PDRA^ do begin
    EType := ElemType;
    VD := TK_RArray.CreateByType( EType.All, Count );
    GetDefaultValue( VD.P );
    VD.SetElems( VD.P^ );
    if PDProj <> nil then
      K_MoveSPLVectorBySIndex( VD.P^, -1, P^, -1,
                               Count, EType.All, [], PDProj  )
    else
      K_MoveSPLVector( VD.P^, -1, P^, -1, Alength, EType.All, [] );
    ARelease;
  end;
  K_SetChangeSubTreeFlags( Self );
  PDRA^ := VD;
end; // end_of procedure TK_UDVector.ChangeElemsOrder

//********************************************* TK_UDVector.ChangeCSS
//  Change Elements CSS
//
function TK_UDVector.ChangeCSS( ACSS : TK_UDDCSSpace ) : Boolean;
var
//  DProj : TN_IArray;
  DCount : Integer;
  SCount : Integer;
  FCount : Integer;
  FullInds, ConvDataInds, FreeDataInds, InitDataInds : TN_IArray;
  UDCSpaceDest : TK_UDDCSpace;
  PDInds, PSInds : PInteger;


begin
  Result := false;
  with TK_PDSSVector(R.P)^ do begin
    if (ACSS = nil) or (TK_UDDCSSpace(CSS) = ACSS) then Exit;
    UDCSpaceDest := ACSS.GetDCSpace;
    if TK_UDDCSSpace(CSS).GetDCSpace <> UDCSpaceDest then Exit;
    FCount := UDCSpaceDest.SelfCount;
    SetLength( FullInds, FCount );
    with ACSS.PDRA^ do begin
      PDInds := P;
      DCount := ALength;
    end;

    with TK_UDDCSSpace(CSS).PDRA^ do begin
      PSInds := P;
      SCount := ALength;
    end;

    K_BuildConvDataIArraysByRACSDims( PDInds, DCount, PSInds, SCount,
                                    @FullInds[0], FCount,
                                    ConvDataInds, FreeDataInds, InitDataInds );
    FCount := Length(InitDataInds);
    PDRA^.ReorderElems( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                        K_GetPIArray0(FreeDataInds), Length(FreeDataInds),
                        K_GetPIArray0(InitDataInds), FCount );
    ACSS.LinkDVector( Self.R.P );
    if FCount = 0 then Exit;
    GetDefaultValue( D.P(InitDataInds[0]) );
    if FCount > 1 then
      K_MoveSPLVectorByDIndex( D.P^, D.ElemSize,
                          D.P(InitDataInds[0])^, 0, FCount-1,
                          D.ElemType.All, [], @InitDataInds[1] );
  end;
  Result := true;
  K_SetChangeSubTreeFlags( Self );

{
  DCount := ACSS.PDRA.ALength;
  SetLength( DProj, DCount );
  with TK_PDSSVector(R.P)^ do begin
    if not K_BuildDataProjection( ACSS, TK_UDDCSSpace(CSS), PInteger(@DProj[0]) ) then Exit;
//??!!    with TK_UDDCSSpace(CSS).GetVectorsDir do
//??!!      RemoveDirEntry( IndexOfDEField(Self) );
  end;
  ACSS.LinkDVector( Self.R.P );
  ChangeElemsOrder( @DProj[0], DCount );
  DProj := nil;
  Result := true;
}

end; // end_of procedure TK_UDVector.ChangeCSS

{*** end of TK_UDVector ***}

{*** TK_UDSSTable ***}

//********************************************** TK_UDSSTable.Create ***
//
constructor TK_UDSSTable.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDSSTableCI;
  ImgInd := 31;
end; // end_of constructor TK_UDSSTable.Create

//********************************************** TK_UDSSTable.CreateDVColumn
//
function TK_UDSSTable.CreateDVColumn(DVectorName : string;
                                ElemTypeCode : Int64 = 0;
                                PData : Pointer = nil;
                                SelfTypeCode : Int64 = 0;
                                UDClassInd : Integer = K_UDVectorCI ) : TK_UDVector;
begin
  Result := TK_UDVector( AddOneChild( CreateDVector( DVectorName,
                   ElemTypeCode, PData, SelfTypeCode, UDClassInd ) ) );
  K_SetChangeSubTreeFlags( Result );
end; // end_of function TK_UDSSTable.CreateDVColumn

//********************************************** TK_UDSSTable.CreateDVector
//
function TK_UDSSTable.CreateDVector(DVectorName : string;
                                ElemTypeCode : Int64 = 0;
                                PData : Pointer = nil;
                                SelfTypeCode : Int64 = 0;
                                UDClassInd : Integer = K_UDVectorCI ) : TN_UDBase;
begin
  if TK_PDSSTable(R.P).DTCode <> 0 then
    ElemTypeCode := TK_PDSSTable(R.P).DTCode;
  Result := TK_UDDCSSpace( TK_PDSSTable(R.P).CSS ).CreateDVector( DVectorName,
     ElemTypeCode, PData, SelfTypeCode, UDClassInd );
end; // end_of function TK_UDSSTable.CreateDVector

{*** end of TK_UDSSTable ***}

{*** TK_BuildCSSUDVList ***}

//********************************************** TK_BuildCSSUDVList.Destroy
//
destructor TK_BuildCSSUDVList.Destroy;
begin
  UDVList.Free;
  inherited;
end;

function TK_BuildCSSUDVList.Build(UDRoot: TN_UDBase; ACSS : TK_UDDCSSpace ) : TList;
var i : Integer;
begin
  if UDVList = nil then UDVList := TList.Create;
  UDVList.Clear;
  VCSS := ACSS;
  BuildCSSUDVList(UDRoot.Owner, UDRoot, 0, 0, '' );

  UDRoot.ScanSubTree( BuildCSSUDVList );

  for i := 0 to UDVList.Count - 1 do
    TN_UDBase(UDVList[i]).Marker := 0;
  Result := UDVList;
end;

function TK_BuildCSSUDVList.BuildCSSUDVList(UDParent : TN_UDBase; var UDChild : TN_UDBase;
  ChildInd, ChildLevel: Integer; const FieldName: string): TK_ScanTreeResult;
var
  PCSS : Pointer;
begin
  if ChildInd <> -1 then begin
    if UDChild.Owner = UDParent then begin
      Result := K_tucOK;
      if (UDChild.Marker = 0) and (UDChild is TK_UDVector) then begin
        PCSS := TK_UDRArray(UDChild).GetFieldPointer( 'CSS' );
        if PCSS <> nil then begin
          if VCSS <> TK_UDDCSSpace(PCSS^) then Exit;
          UDChild.Marker := 1;
          UDVList.Add( UDChild );
        end;
      end;
    end else
//*** Not Owner Node (External or Internal)
      Result := K_tucSkipSubTree;
  end else
//*** Skip References inside UDRArray
    Result := K_tucSkipSibling;
end;

{*** end of TK_BuildCSSUDVList ***}

{*** TK_UDDCSProjFilterItem ***}

constructor TK_UDDCSProjFilterItem.Create(AExprCode: TK_UDFilterItemExprCode  = K_ifcOr);
begin
  inherited Create;
  ExprCode := AExprCode;
end;

function TK_UDDCSProjFilterItem.UDFITest(const DE: TN_DirEntryPar): Boolean;
begin
  Result := (DE.Child <> nil)         and
            (DE.Child is TK_UDVector) and
            not (DE.Child is TK_UDDCSSpace);
  if Result then
    Result := TK_UDVector(DE.Child).IsDCSProjection;
end;

{*** end of TK_UDDCSProjFilterItem ***}


{*** TK_UDDCSProjFilterItem1 ***}

function TK_UDDCSProjFilterItem1.UDFITest(const DE: TN_DirEntryPar): Boolean;
begin
  Result := inherited UDFITest( DE ) and
  (TK_UDVector(DE.Child).GetDCSSpace.GetDCSpace = TK_UDDCSSpace(DE.Child).GetDCSpace);
end;
{*** end of TK_UDDCSProjFilterItem1 ***}

end.

