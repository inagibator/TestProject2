unit K_RAEdit;
//{$WARN SYMBOL_PLATFORM OFF}

interface
uses Windows, Classes, Grids, Types, Graphics, StdCtrls, ComCtrls, Controls,
  N_Types, N_Lib1,
  K_FSelectUDB, K_parse, K_UDT1, K_Script1, K_FrRAEdit;

type TK_RAFFNamePars = record
  InitDir : string;
  InitWDir : string;
  ColumnName : string;
  RelPathFlag : Boolean;
  ColumnInd : Integer;
  FilePathFlag : Boolean;
  HistoryName : string;
end;

type TK_RAFColorDialogEditor = class( TK_RAFEditor1 ) // ***** Color Field Editor
  function Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFColorDialogEditor = class( TK_RAFEditor )

type TK_RAFColorViewer = class( TK_RAFViewer ) // ***** Color Field Viewer
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; Canvas : TCanvas ); override;
end; //*** type TK_RAFColorViewer = class( TK_RAFViewer )

type TK_RAFSwitchEnablingViewer = class( TK_RAFViewer ) // ***** Color Array Field Editor
  SwitchColumnName : string;
  DisabledMinVal : Integer;
  DisabledMaxVal : Integer;
  CCol, CRow : Integer;
  RV : TK_RAFViewer;

  destructor Destroy; override;
  procedure SetContext( const Data ); override;
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; Canvas : TCanvas ); override;
  function  IfUseViewer( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
end; //*** type TK_RAFSwitchEnablingViewer = class( TK_RAFViewer )

type TK_RAFColorArrayViewer = class( TK_RAFViewer ) // ***** Color Array Field Viewer
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; Canvas : TCanvas ); override;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
     PHTextPos : Pointer = nil ): string; override;
end; //*** type TK_RAFColorArrayViewer = class( TK_RAFViewer )

type TK_RAFUDRAViewer = class( TK_RAFViewer ) // ***** Color Array Field Viewer
  RV : TK_RAFViewer;
  destructor Destroy; override;
  procedure SetContext( const Data ); override;
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; Canvas : TCanvas ); override;
  function  IfUseViewer( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
end; //*** type TK_RAFColorArrayViewer = class( TK_RAFViewer )

type TK_RAFUDRAEditor = class( TK_RAFEditor1 ) // ***** UDBase Field Editor
  RE : TK_RAFEditor;
  destructor Destroy; override;
  procedure SetContext( const Data ); override;
  function  Edit( var Data ) : Boolean; override;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
end; //*** type TK_RAFUDRAEditor = class( TK_RAFEditor1 )

type TK_RAFUDRefViewer = class( TK_RAFViewer ) // ***** UDBase Field  Viewer
//*** Static Context
  RootPath : string;
//*** end of Static Context

  Root : TN_UDBase;
  ObjNameType  : TK_UDObjNameType;
  ShowFullPath : Boolean;
  constructor Create; override;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
            PHTextPos : Pointer = nil ): string; override;
  procedure SetContext( const Data ); override;
end; //*** type TK_RAFUDRefViewer = class( TK_RAFViewer )

type TK_RAFUDRefViewer1 = class( TK_RAFUDRefViewer ) // ***** UDBase Field  Viewer
  constructor Create; override;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
            PHTextPos : Pointer = nil ): string; override;
//  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
//                Rect: TRect; State: TGridDrawState; ACanvas : TCanvas ); override;
end; //*** type TK_RAFUDRefViewer1 = class( TK_RAFUDRefViewer )

type TK_RAFUDRefEditor = class( TK_RAFEditor1 ) // ***** UDBase Field Editor
//*** Static Context
//  RootPath : string;
//*** end of Static Context

//  Root : TN_UDBase;
  SFilter : TK_UDFilter;
//  ShowToolBar : Boolean;
//  DE : TN_DirEntryPar;
  UDTS : TK_UDTreeSelect;
  constructor Create; override;
  function   Edit( var Data ) : Boolean; override;
  procedure  SetContext( const Data ); override;
  destructor Destroy; override;
end; //*** type TK_RAFUDRefEditor = class( TK_RAFEditor1 )

type TK_RAFUDRefEditor1 = class( TK_RAFUDRefEditor ) // ***** UDBase Field Editor
  procedure  SetContext( const Data ); override;
end; //*** type TK_RAFUDRefEditor1 = class( TK_RAFUDRefEditor )

type TK_RAFUDRARefEditor = class( TK_RAFUDRefEditor ) // ***** UDBase Field Editor
  procedure  SetContext( const Data ); override;
end; //*** type TK_RAFUDRefEditor = class( TK_RAFEditor1 )

type TK_RAFExtCmBEditor = class( TK_RAFEditor1 ) // ***** External ComboBox Field Editor
  CmB : TComboBox;
  PData : Pointer;
  ECol, ERow : Integer;
  PRAFC: ^TK_RAFColumn;
  // FSEInds : TN_IArray;
  PSEInds : PInteger;
  SEIndsCount : Integer;
  DataSize : Integer;
  DropListDown : Boolean;

  destructor Destroy; override;
  procedure PosControl;
  function  Edit( var Data ) : Boolean; override;
  procedure OnKeyDownH( Sender: TObject; var Key: Word; Shift: TShiftState ); virtual;
  procedure OnExitH( Sender: TObject ); virtual;
  procedure OnDropDownH( Sender: TObject ); virtual;
  procedure OnChangeH( Sender: TObject ); virtual;
  procedure OnItemIndexChange; virtual;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
  procedure Hide; override;
end; //*** type TK_RAFExtCmBEditor = class( TK_RAFEditor )

type TK_RAFFNameCmBEditor = class( TK_RAFExtCmBEditor ) // ***** File Name ComboBox Editor
{
  Params : <IniPathInfo> <HistoryName>
    IniPathInfo : [.][&]|*|<FilePath>|#<ColumnName>
    начальный символ = '.' - в поле сохран€етс€ относительный путь (необ€зательный признак)
    следующий символ = '&' - редактор обеспечивает выбор пути (а не файла) (необ€зательный признак)
    следующий символ = '*' - базовый путь отсутствует
    следующий символ = '#' - остальные символы <IniPathInfo> им€ колонки фрейма в которой задан базовый путь
    иначе - остальные символы <IniPathInfo> базовый путь, который может мсодержать макроперменные
}
  RFNP : TK_RAFFNamePars;
  ListIndex : Integer;
  function  Edit( var Data ) : Boolean; override;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
  procedure OnChangeH( Sender: TObject ); override;
  procedure SetContext( const Data ); override;
end; //*** type TK_RAFFNameCmBEditor = class( TK_RAFExtCmBEditor )


type TK_RAFDateTimePicEditor = class( TK_RAFEditor1 ) // ***** External DateTime Field Editor By DateTimePicker
  DTP : TDateTimePicker;
  PData : Pointer;
  ECol, ERow : Integer;
  FDateMode   : TDTDateMode;
  FFormat     : string;
  FMinDate, FMaxDate : TDate;
  SkipExit : Boolean;
  constructor Create; override;
  destructor Destroy; override;
  procedure SetContext( const Data ); override;
  procedure PosControl;
  function  Edit( var Data ) : Boolean; override;
  procedure OnKeyDownH( Sender: TObject; var Key: Word; Shift: TShiftState ); virtual;
  procedure OnExitH( Sender: TObject ); virtual;
  procedure OnChangeH( Sender: TObject ); virtual;
  procedure OnChangeMode( Sender: TObject ); virtual;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
  procedure Hide; override;
end; //*** type TK_RAFDateTimePicEditor = class( TK_RAFEditor1 )

type TK_RAFSArrayEditor = class( TK_RAFEditor1 ) // ***** TK_SArray Field Editor
  function Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFSArrayEditor = class( TK_RAFEditor1 )

type TK_RAFRecViewer = class( TK_RAFViewer ) // ***** Field-Record  Viewer
//*** Static Context
  FieldsList : TN_SArray;
//*** end of Static Context
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
               PHTextPos : Pointer = nil ): string; override;
  procedure SetContext( const Data ); override;
end; //*** type TK_RAFRecViewer = class( TK_RAFViewer )

type TK_RAFFNameEditor = class( TK_RAFEditor1 ) // ***** File Name Editor
  InitDir : string;
  FileFilter : string;
  procedure  SetContext( const Data ); override;
  function   Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFFNameEditor = class( TK_RAFEditor1 )

type TK_RAFFNameEditor1 = class( TK_RAFEditor1 ) // ***** File Name Editor
{
  Params : <IniPathInfo> <HistoryName> <FileFilter>
    IniPathInfo : [.][&]|*|<FilePath>|#<ColumnName>
    начальный символ = '.' - в поле сохран€етс€ относительный путь (необ€зательный признак)
    следующий символ = '&' - редактор обеспечивает выбор пути (а не файла) (необ€зательный признак)
    следующий символ = '*' - базовый путь отсутствует
    следующий символ = '#' - остальные символы <IniPathInfo> им€ колонки фрейма в которой задан базовый путь
    иначе - остальные символы <IniPathInfo> базовый путь, который может содержать макроперменные
}
  RFNP : TK_RAFFNamePars;
  FileFilter : string;
  procedure  SetContext( const Data ); override;
  function   Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFFNameEditor1 = class( TK_RAFEditor1 )

//type TK_RAFFPathEditor = class( TK_RAFFNameEditor ) // ***** File Path Editor
type TK_RAFFNameViewer1 = class( TK_RAFViewer ) // ***** File Name Viewer
{
  Params : <IniPathInfo>
    IniPathInfo : [!][@][.][&]|*|<FilePath>|#<ColumnName>
    начальный символ = '!' - отображаетс€ полный путь (необ€зательный признак)
    следующий символ = '@' - полный путь отображаетс€ без макроподстановки (необ€зательный признак)
    следующий символ = '.' - в поле сохран€етс€ относительный путь (необ€зательный признак)
    следующий символ = '&' - редактор обеспечивает выбор пути (а не файла) (необ€зательный признак)
    следующий символ = '*' - базовый путь отсутствует
    следующий символ = '#' - остальные символы <IniPathInfo> им€ колонки фрейма в которой задан базовый путь
    иначе - остальные символы <IniPathInfo> базовый путь, который может мсодержать макроперменные
}
  RFNP : TK_RAFFNamePars;
  ShowAbsPathFlag : Boolean;
  ShowPathMacrosFlag : Boolean;
//  InitDir : string;
//  InitWDir : string;
//  ColumnName : string;
//  ColumnInd : Integer;
//  RelPathFlag : Boolean;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
               PHTextPos : Pointer = nil ): string; override;
  procedure SetContext( const Data ); override;
end; //*** type TK_RAFFNameEditor1 = class( TK_RAFEditor1 )

type TK_RAFUDEditor = class( TK_RAFEditor1 ) // ***** UDBase Instance Editor
  FEdInd : Integer;
  RE : TK_RAFEditor;
  destructor Destroy; override;
  function   Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFFNameEditor = class( TK_RAFEditor1 )

type TK_RAFUDCSProjEditor = class( TK_RAFUDRefEditor ) // ***** UDCSProj Editor
  constructor Create; override;
end; //*** type TK_RAFUDCSProjEditor = class( TK_RAFUDRefEditor )

type TK_RAFUDCSProjEditor1 = class( TK_RAFUDRefEditor ) // ***** SelfToSelf UDCSProj Editor1
  constructor Create; override;
end; //*** type TK_RAFUDCSProjEditor1 = class( TK_RAFUDRefEditor )

type TK_RAFVArrayEditor = class( TK_RAFEditor1 ) // Toggle VArray type as external Editor
  RE : TK_RAFUDRARefEditor;
  function Edit ( var AData ): Boolean; override;
  destructor Destroy; override;
end; //*** type TK_RAFVArrayEditor = class( TK_RAFEditor1 )

type TK_RAFNFontViewer = class( TK_RAFViewer ) // ***** Field-Record  Viewer
//*** Static Context
  UndefText : string;
//*** end of Static Context
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
               PHTextPos : Pointer = nil ): string; override;
  procedure SetContext( const Data ); override;
end; //*** type TK_RAFNFontViewer = class( TK_RAFViewer )

//*** Global UDRefEditor Context
var
K_RAFUDRefDefPathObj : TN_UDBase;

implementation

uses Forms, Dialogs, SysUtils, Math, StrUtils,
  K_UDC, K_CLib0, K_Arch, K_FEText, K_UDT2, K_UDConst,
  K_Types, K_IFunc, K_DCSpace, K_VFunc,
  N_CLassRef, N_ButtonsF, N_Lib0, N_Lib2;

procedure K_RAFFNameGetDirContext0( var RFNP : TK_RAFFNamePars; AInitDir : string = '' );
begin
  with RFNP do begin
    if AInitDir = '' then
      InitDir := K_RAFEDParsTokenizer.nextToken( true)
    else
      InitDir := AInitDir;
    ColumnInd := -1;

    RelPathFlag := (InitDir <> '') and (InitDir[1] = '.');
    if RelPathFlag then
      InitDir := Copy( InitDir, 2, Length( InitDir ) );

    FilePathFlag := (InitDir <> '') and (InitDir[1] = '&');
    if FilePathFlag then
      InitDir := Copy( InitDir, 2, Length( InitDir ) );

    if (InitDir <> '') and (InitDir[1] = '#') then begin
      ColumnName := Copy( InitDir, 2, Length( InitDir ) );
      InitDir := '';
      InitWDir := '';
      RelPathFlag := true;
    end else begin
      if InitDir = '*' then InitDir := '';
      InitWDir := K_ExpandFileName( InitDir );
      if InitWDir = '' then InitWDir := K_ExpandFileName( '(#'+K_MVAppDirExe+'#)' );
      InitWDir := K_OptimizePath( InitWDir );
    end;

    HistoryName := K_RAFEDParsTokenizer.nextToken( true);
    if HistoryName = '*' then HistoryName := '';
  end;
end;

function K_RAFFNameRAColContext( var RFNP : TK_RAFFNamePars; RAFrame : TK_FrameRAEdit; LRow : Integer ) : Boolean;
begin
  with RFNP do begin
    Result := (RAFrame <> nil) and (ColumnName <> '');
    if Result then
      with RAFrame do begin
        if ColumnInd = -1 then
          ColumnInd := IndexOfColumn(ColumnName);
        RelPathFlag := ColumnInd <> -1;
        if RelPathFlag then
          InitWDir := IncludeTrailingPathDelimiter( K_ExpandFileName(PString(DataPointers[LRow][ColumnInd])^) );
      end;
  end;
end;

function K_RAFFNameExpand( var RFNP : TK_RAFFNamePars; WFName : string ) : string;
begin
  with RFNP do begin
    Result := WFName;
    if not K_IfExpandedFileName( Result ) then begin
      if RelPathFlag or
         (Result = '') then
        Result := InitWDir + Result
      else
        Result := K_ExpandFileName( Result );
    end;
  end;
end;

function K_RAFFNameBuildDirs( var RFNP : TK_RAFFNamePars;
                              SrcFName : string; out WWDir : string ) : string;
var
  EMInd : Integer;
begin
  with RFNP do begin
    WWDir := InitWDir;
    Result := InitDir;
    if (Length(SrcFName) > 1) and (SrcFName[2] = '#') then begin
      EMInd := PosEx( '#', SrcFName, 3 );
      if EMInd > 0 then begin
        Inc( EMInd, 1 );
        if not K_StrStartsWith( SrcFName, Result, true, EMInd ) then begin
    // Rebuild Base
          Result := Copy( SrcFName, 1, EMInd );
          WWDir := K_ExpandFileName( Result );
        end;
      end;
    end;
  end;
end;

function K_RAFFNamePreResult( var RFNP : TK_RAFFNamePars; WFName : string;
                              SrcFName : string = '' ) : string;
var
  WWDir : string;
  WIDir : string;
begin
  with RFNP do begin
    WIDir := K_RAFFNameBuildDirs( RFNP, SrcFName, WWDir );

    Result := K_ExtractRelativePath( WWDir, WFName );
    if not K_IfExpandedFileName( Result ) and not RelPathFlag then begin
      if FilePathFlag          and
        (Pos('\',WIDir) = 0) and
        (Pos('\',Result) = 0) then Result := '\' + Result;
      Result := WIDir+Result;
    end;
  end;
end;

function K_RAFFNameHistoryRebuild( HistoryName, WFName : string ) : string;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  N_MemIniToStrings( HistoryName, SL );
  N_AddUniqStrToTop( SL, WFName, 0 );
  N_StringsToMemIni( HistoryName, SL );
  SL.Free;
end;


{*** TK_RAFColorViewer ***}

//**************************************** TK_RAFColorViewer.DrawCell
//
//
procedure TK_RAFColorViewer.DrawCell(var Data; var RAFC : TK_RAFColumn;
                                ACol, ARow : Integer; Rect: TRect;
                                State: TGridDrawState; Canvas: TCanvas);
begin

  with RAFC do
//    if (CDType.DTCode = Ord(nptColor)) then begin
    if ((CDType.All xor Ord(nptColor)) and K_ffCompareTypesMask) = 0 then begin
      CFillColor := Integer(data);
      Include( ShowEditFlags, K_racUseFillColor );
    end;
  inherited DrawCell( Data, RAFC, ACol, ARow, Rect, State, Canvas );
end; //*** procedure TK_RAFColorViewer.DrawCell

{*** end of TK_RAFColorViewer ***}

{*** TK_RAFColorDialogEditor ***}

//**************************************** TK_RAFColorDialogEditor.Edit
//
//
function TK_RAFColorDialogEditor.Edit(var Data ) : Boolean;
//var
//  ColorDialog : TColorDialog;
begin
  with RAFrame do
    Result := K_SelectColorDlg( TColor(Data) ) and
              not (K_racReadOnly in RAFCArray[CurLCol].ShowEditFlags);
{
  ColorDialog := TColorDialog.Create( Application );
  ColorDialog.Color := TColor(Data);
  with RAFrame do
    if ColorDialog.Execute and
       not (K_racReadOnly in RAFCArray[CurLCol].ShowEditFlags) then begin
      TColor(Data) := ColorDialog.Color;
      Result := true;
    end else
      Result := false;

  ColorDialog.Free;
}
end; //*** procedure TK_RAFColorDialogEditor.Edit

{*** end of TK_RAFColorDialogEditor ***}


{*** TK_RAFUDRefViewer ***}

constructor TK_RAFUDRefViewer.Create;
begin
  inherited;
  ObjNameType  := K_ontObjName;
  ShowFullPath := false;
end;

//**************************************** TK_RAFUDRefViewer.GetText
//
//
function TK_RAFUDRefViewer.GetText(var Data; var RAFC: TK_RAFColumn;
                   ACol, ARow : Integer;
               PHTextPos : Pointer = nil ): string;
begin
  SetTextShift;
  if RAFrame.SGrid.Cells[ACol, ARow] <> '' then
    Result := RAFrame.SGrid.Cells[ACol, ARow]
  else begin //*** Build RPath value
    if Root = nil then begin //*** Build Root
      if RootPath <> '' then
        Root := K_UDCursorGetObj( RootPath );
      if Root = nil then Root := K_CurArchive;
      if Root = nil then Root := K_ArchsRootObj;
    end;
    Result := '';
    if (TN_UDBase(Data) <> nil) then begin
      if ShowFullPath then
//        Result := ExcludeTrailingPathDelimiter( Root.GetPathToObj( TN_UDBase(Data), ObjNameType ) )
        Result := K_GetPathToUObj( TN_UDBase(Data), Root, ObjNameType )
      else
        Result := TN_UDBase(Data).GetUName(ObjNameType);
    end;
    if Result = '' then Result := '*';
//    RAFrame.SGrid.Cells[ACol, ARow] := Result;
  end;
  if PHTextPos <> nil then
    TK_CellPos((PHTextPos)^) := K_ppUpLeft;
end;

//**************************************** TK_RAFUDRefViewer.SetContext
//
//
procedure TK_RAFUDRefViewer.SetContext(const Data);

begin
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    RootPath := nextToken( true );
    if RootPath = '*' then RootPath := '';
    if hasMoreTokens( true ) then begin
      ObjNameType := TK_UDObjNameType(StrToIntDef( nextToken( true ), 0 ));
      if hasMoreTokens( true ) and (nextToken( true ) <> '0') then
        ShowFullPath := true;
    end;
  end;
end; //*** procedure TK_RAFUDRefViewer.SetContext

{*** end of TK_RAFUDRefViewer ***}

{*** TK_RAFUDRefViewer1 ***}

constructor TK_RAFUDRefViewer1.Create;
begin
  inherited;
  ObjNameType  := K_ontObjUName;
end;

//**************************************** TK_RAFUDRefViewer1.GetText
//
//
function TK_RAFUDRefViewer1.GetText(var Data; var RAFC: TK_RAFColumn;
                   ACol, ARow : Integer;
               PHTextPos : Pointer = nil ): string;
begin
  with N_ButtonsForm do begin
    IconInd := 0;
    TextShift := 0;
    if (TN_UDBase(Data) <> nil) then begin
      IconInd := TN_UDBase(Data).GetIconIndex;
{
      if (IconsList <> nil)          and
         (IconInd > 0)             and
         (IconInd < IconsList.Count) then
        TextShift := IconsList.Width + 2
}
    end;
  end;
  Result := inherited GetText( Data, RAFC, ACol, ARow, PHTextPos );
end;

{
procedure TK_RAFUDRefViewer1.DrawCell(var Data; var RAFC: TK_RAFColumn;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState;
  ACanvas: TCanvas);
//var
//  ImgInd : Integer;
//  NoImageDraw : Boolean;
begin
  with N_ButtonsForm do begin
    inherited;
    if TextShift = 0 then Exit;
    IconsList.Draw( ACanvas, Rect.Left + 1,
        Rect.Top + (Rect.Bottom - Rect.Top - IconsList.Height) shr 1, ImgInd);
  end;
end;
}

{*** end of TK_RAFUDRefViewer1 ***}

{*** TK_RAFUDRefEditor ***}

constructor TK_RAFUDRefEditor.Create;
begin
  inherited;
  SFilter := TK_UDFilter.Create;
  UDTS := TK_UDTreeSelect.Create;
//  UDTS.FShowToolBar := false;
//  ShowToolBar := true;
end;

//**************************************** TK_RAFUDRefEditor.Edit
//
//
function TK_RAFUDRefEditor.Edit(var Data): Boolean;
var
//  RPath : string;
  WN : TN_UDBase;
//  WRefPath : string;
  WType : TK_ExprExtType;
begin

  if UDTS.FPrevRootUDNode = nil then begin //*** Build Root
    if UDTS.FRootPath <> K_udpAbsPathCursorName then
      UDTS.FPrevRootUDNode := K_UDCursorGetObj( UDTS.FRootPath );
    if UDTS.FPrevRootUDNode = nil then UDTS.FPrevRootUDNode := K_CurArchive;
    if UDTS.FPrevRootUDNode = nil then begin
      if UDTS.FRootPath = K_udpAbsPathCursorName then
        UDTS.FPrevRootUDNode := K_MainRootObj
      else
       UDTS.FPrevRootUDNode := K_ArchsRootObj;
    end;
  end;

  with RAFrame, RAFCArray[CurLCol] do begin
//    RPath := SGrid.Cells[CurGCol, CurGRow];
    if (TN_UDBase( Data ) = nil)          or
       not (TObject( Data ) is TN_UDBase) or
       (TN_UDBase( Data ).CI = K_UDRefCI) then
      WN := K_RAFUDRefDefPathObj
    else
      WN := TN_UDBase( Data );
{
    if WN <> nil then begin
//*** Build path to UDObj
      WRefPath := UDTS.FPrevRootUDNode.RefPath;
      RPath := UDTS.FPrevRootUDNode.GetRefPathToObj( WN );
      UDTS.FPrevRootUDNode.RefPath := WRefPath;
      if RPath = '' then
        RPath := UDTS.FPrevRootUDNode.GetPathToObj( WN )
    end else
      RPath := '';
}
    UDTS.FSelectFFunc := SFilter.UDFTest;
    Result := UDTS.SelectUDB( WN, nil, Caption );
//    Result := K_SelectDEOpen( DE, UDTS.FPrevRootUDNode, RPath, SFilter.UDFTest, Caption, false, ShowToolBar );
//    WN := DE.Child;
    if Result then begin
      WType := K_GetExecDataTypeCode(Data, CDType );
      if WType.D.TFlags = K_ffArray then begin
        TK_RArray(Data).ARelease;
        TN_UDBase(Data) := nil;
      end;
      K_SetUDRefField( TN_UDBase(Data), WN,
                       (WType.D.CFlags and K_ccCountUDRef) <> 0 );
      Result := true;
      SGrid.Cells[CurGCol, CurGRow] := ''; // for SGrid.DrawCell
    end;

  end;
end; //*** procedure TK_RAFUDRefEditor.Edit

//**************************************** TK_RAFUDRefEditor.SetContext
//
//
procedure TK_RAFUDRefEditor.SetContext( const Data );
var
  WNum, Code : Integer;
begin
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    UDTS.FRootPath := nextToken( true );
// check if ShowToolBar is Set
    Val( UDTS.FRootPath, WNum, Code );
    if Code = 0 then begin
      UDTS.FShowToolBar := (WNum <> 0);
      UDTS.FRootPath := nextToken( true );
    end;
  end;
end; //*** procedure TK_RAFUDRefEditor.SetContext

destructor TK_RAFUDRefEditor.Destroy;
begin
  SFilter.Free;
  UDTS.Free;
  inherited;
end;

{*** end of TK_RAFUDRefEditor ***}


{*** TK_RAFUDRefEditor1 ***}

procedure TK_RAFUDRefEditor1.SetContext(const Data);
var
 Ind : Integer;
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    while hasMoreTokens( true ) do begin
      Ind := K_GetUObjCIByTagName( nextToken( true ), false );
      if Ind <> -1 then
        SFilter.AddItem( TK_UDFilterClassSect.Create( Ind ) );
    end;
  end;

end;

{*** end of TK_RAFUDRefEditor1 ***}

{*** TK_RAFUDRARefEditor ***}

procedure TK_RAFUDRARefEditor.SetContext(const Data);
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    while hasMoreTokens( true ) do begin
      SFilter.AddItem( TK_UDFilterExtType.Create(
            K_GetTypeCodeSafe( nextToken( true ) ).All ) );
    end;
  end;

end;

{*** end of TK_RAFUDRARefEditor ***}

{*** TK_RAFExtCmBEditor ***}

//**************************************** TK_RAFExtCmBEditor.Destroy
//
destructor TK_RAFExtCmBEditor.Destroy;
begin
  CmB.Free;
  inherited;
end; //*** destructor TK_RAFExtCmBEditor.Destroy

//**************************************** TK_RAFExtCmBEditor.PosControl
//
procedure TK_RAFExtCmBEditor.PosControl;
var
  GRect : TRect;
begin
  with CmB do begin
    ECol := RAFRame.CurGCol;
    ERow := RAFRame.CurGRow;
    GRect := RAFRame.SGrid.CellRect(ECol, ERow);
    Top := GRect.Top + 2;
    Left := GRect.Left + 3;
    Width := GRect.Right - GRect.Left;
    Visible := true;
    DroppedDown := DropListDown;
    SetFocus;
  end;
end; //*** procedure TK_RAFExtCmBEditor.PosControl

//**************************************** TK_RAFExtCmBEditor.Edit
//
function TK_RAFExtCmBEditor.Edit(var Data ) : Boolean;
var
  Ind : Integer;
begin
  Result := false;
  PosControl;
  PData := Pointer(@Data);
  Ind := 0;
  with CmB, PRAFC^ do begin
    Move( PData^, Ind, DataSize);
    if Length(VEArray[CVEInd].SEInds) > 0 then
      Ind := K_IndexOfIntegerInRArray( Ind, @VEArray[CVEInd].SEInds[0], Items.Count );
//    if (Ind >= 0) and (Ind < Items.Count) then
    if (Ind < Items.Count) then
      ItemIndex := Ind;
  end;
end; //*** procedure TK_RAFExtCmBEditor.Edit

//**************************************** TK_RAFExtCmBEditor.CanUseEditor
//
function TK_RAFExtCmBEditor.CanUseEditor(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
begin
  Result := inherited CanUseEditor( ACol, ARow, RAFC );
  if CmB = nil then begin
    CmB := TComboBox.Create( RAFRame.Owner );
    with CmB do begin
      Parent := RAFrame;
      Style := csDropDownList;
      with RAFC, CDType do begin
//        FSEInds := VEArray[CVEInd].SEInds;
        PSEInds := K_GetPIArray0( VEArray[CVEInd].SEInds );
        SEIndsCount := Length( VEArray[CVEInd].SEInds );
        if (DTCode > Ord(nptNoData)) and
           (FD.FDObjType = K_fdtEnum) then  begin
          FD.GetFieldsDefValueList( Items, PSEInds, SEIndsCount );
          DataSize := FD.FDRecSize;
          DropDownCount := Min(Items.Count, 32);
        end;
      end;
      OnKeyDown := OnKeyDownH;
      OnChange := OnChangeH;
      OnDropDown := OnDropDownH;
      OnExit := OnExitH;
      Visible := false;
      DropListDown := true;

    end;
    PRAFC := @RAFC;
  end;

end; //*** function TK_RAFExtCmBEditor.CanUseEditor

//**************************************** TK_RAFExtCmBEditor.Hide
//  OnExit Handler
//
procedure TK_RAFExtCmBEditor.Hide;
begin
  inherited;
  if CmB <> nil then OnExitH( nil );
end; //*** function TK_RAFExtCmBEditor.Hide

//**************************************** TK_RAFExtCmBEditor.OnExitH
//  OnExit Handler
//
procedure TK_RAFExtCmBEditor.OnExitH(Sender: TObject);
begin
  CmB.Visible := false;
  RAFRame.SGrid.SetFocus;
end; //*** procedure TK_RAFExtCmBEditor.OnExitH

//**************************************** TK_RAFExtCmBEditor.OnKeyDownH
//  OnKeyDown Handler
//
procedure TK_RAFExtCmBEditor.OnKeyDownH( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  FinishEdit : Boolean;
begin
  FinishEdit := false;
  case Key of
  VK_RETURN:
    begin
      OnChangeH(Sender);
      FinishEdit := true;
    end;
  VK_ESCAPE:
    FinishEdit := true;
  VK_SHIFT:
    CmB.DroppedDown := true;
  end;
  if FinishEdit then OnExitH(Sender);
end; //*** procedure TK_RAFExtCmBEditor.OnKeyDownH

//**************************************** TK_RAFExtCmBEditor.OnChangeH
//  OnChange Handler
//
procedure TK_RAFExtCmBEditor.OnChangeH(Sender: TObject);
begin
  with PRAFC^, PRAFC.CDType do
    if (DTCode > Ord(nptNoData)) and
       (FD.FDObjType = K_fdtEnum) then OnItemIndexChange;
end;

//**************************************** TK_RAFExtCmBEditor.OnItemIndexChange
//  On ItemIndex Change
//
procedure TK_RAFExtCmBEditor.OnItemIndexChange;
var
  Ind : Integer;
begin
  with CmB do
    if (ItemIndex <> -1) then begin
      Ind := ItemIndex;
//      if FSEInds <> nil then Ind := FSEInds[Ind];
      if PSEInds <> nil then
        Ind := PInteger(TN_BytesPtr(PSEInds)+Ind*SizeOf(Integer))^;
      if CompareMem( PData, @Ind, DataSize ) then Exit;
      Move( Ind, PData^, DataSize);
      RAFRame.AddChangeDataFlag;
    end;
end;

//**************************************** TK_RAFExtCmBEditor.OnDropDownH
//  OnDropDown Handler
//
procedure TK_RAFExtCmBEditor.OnDropDownH(Sender: TObject);
begin
  with CmB, PRAFC^ do
    if K_racEnumSwitch in ShowEditFlags then begin
      if ItemIndex < Items.Count - 1 then
        ItemIndex := ItemIndex + 1
      else
        ItemIndex := 0;
      OnChangeH(Sender);
    end;
end; //*** procedure TK_RAFExtCmBEditor.OnDropDownH

{*** end of TK_RAFExtCmBEditor ***}

{*** TK_RAFFNameCmBEditor ***}

function TK_RAFFNameCmBEditor.Edit(var Data): Boolean;
var
  WFName : string;
begin
  K_RAFFNameRAColContext( RFNP, RAFrame, RAFrame.CurLRow );

  WFName := K_RAFFNameExpand( RFNP, PString(@Data)^ );
  ListIndex := CmB.Items.IndexOf( WFName );
  if ListIndex < 0 then ListIndex := 0;
  Result := inherited Edit( ListIndex );
  PData := @Data;
end;

function TK_RAFFNameCmBEditor.CanUseEditor(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
var i : Integer;
begin
  if RFNP.HistoryName = '' then
    Result := false
  else
    Result := inherited CanUseEditor( ACol, ARow, RAFC );
  DataSize := 4;
  DropListDown := true;
  if not Result then Exit;
  N_MemIniToStrings( RFNP.HistoryName, CmB.Items );
  if not RFNP.RelPathFlag then
    for i := 0 to CmB.Items.Count - 1 do
      CmB.Items[i] := K_RAFFNameExpand( RFNP, CmB.Items[i] );
end;

procedure TK_RAFFNameCmBEditor.OnChangeH(Sender: TObject);
var
  WFName : string;
begin
  with CmB do
    if ItemIndex <> -1 then begin
      WFName := K_RAFFNamePreResult( RFNP, K_RAFFNameExpand(RFNP, CmB.Items[ItemIndex]) );
      if PString(PData)^ = WFName then Exit;
      PString(PData)^ := WFName;
      with RAFRame do if Assigned(OnDataChange) then OnDataChange();
      K_RAFFNameHistoryRebuild( RFNP.HistoryName, WFName );
    end;
end;

procedure TK_RAFFNameCmBEditor.SetContext(const Data);
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    K_RAFFNameGetDirContext0( RFNP );
  end;
end;

{*** end of TK_RAFFNameCmBEditor ***}

{*** TK_RAFDateTimePicEditor ***}

//**************************************** TK_RAFDateTimePicEditor.Create
//
constructor TK_RAFDateTimePicEditor.Create;
begin
  FDateMode := dmUpDown;
end; //*** destructor TK_RAFDateTimePicEditor.Create

//**************************************** TK_RAFDateTimePicEditor.Destroy
//
destructor TK_RAFDateTimePicEditor.Destroy;
begin
  DTP.Free;
  inherited;
end; //*** destructor TK_RAFDateTimePicEditor.Destroy

//**************************************** TK_RAFDateTimePicEditor.SetContext
//
procedure TK_RAFDateTimePicEditor.SetContext( const Data );
var
  SL : TStringList;
  Ind : Integer;
begin
  SL := TStringList.Create;
  SL.CommaText := PString(@Data)^;
//  Byte(FDateMode) := Byte(StrToIntDef( SL.Values['DateMode'], 1 ));
//  FFormat := SL.Values['Format'];
//  Ind := SL.IndexOfName('MinDate');
  Byte(FDateMode) := Byte(StrToIntDef( K_GetStringsValueByName( SL, 'DateMode' ), 1 ));
  FFormat := K_GetStringsValueByName( SL, 'Format' );
  Ind := K_IndexOfStringsName( SL, 'MinDate' );
  if Ind >= 0 then
    FMinDate := K_StrToDateTime( SL.ValueFromIndex[Ind] );
//  Ind := SL.IndexOfName('MaxDate');
  Ind := K_IndexOfStringsName( SL, 'MaxDate' );
  if Ind >= 0 then
    FMaxDate := K_StrToDateTime( SL.ValueFromIndex[Ind] );
end; //*** procedure TK_RAFDateTimePicEditor.SetContext

//**************************************** TK_RAFDateTimePicEditor.PosControl
//
procedure TK_RAFDateTimePicEditor.PosControl;
var
  GRect : TRect;
begin
  ECol := RAFRame.CurGCol;
  ERow := RAFRame.CurGRow;
  with DTP do begin
    GRect := RAFRame.SGrid.CellRect(ECol, ERow);
    Top := GRect.Top + 2;
    Left := GRect.Left + 3;
    Width := GRect.Right - GRect.Left;
    Visible := true;
//    DroppedDown := DropListDown;
    SetFocus;
  end;
end; //*** procedure TK_RAFDateTimePicEditor.PosControl

//**************************************** TK_RAFDateTimePicEditor.Edit
//
function TK_RAFDateTimePicEditor.Edit(var Data ) : Boolean;
begin
  Result := false;
  PosControl;
  PData := Pointer(@Data);
  if Double(Data) = 0 then begin
    TDateTime(Data) := Now();
    OnChangeH( nil );
  end;
  with DTP do
    DateTime := TDateTime(Data)
end; //*** procedure TK_RAFDateTimePicEditor.Edit

//**************************************** TK_RAFDateTimePicEditor.CanUseEditor
//
function TK_RAFDateTimePicEditor.CanUseEditor(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
begin
  Result := inherited CanUseEditor( ACol, ARow, RAFC );
  if DTP = nil then begin
    DTP := TDateTimePicker.Create( RAFRame.Owner );
    with DTP do begin
      Parent := RAFrame;
      Anchors := Anchors + [akRight];
      DateMode := FDateMode;
      if RAFC.CDType.DTCode = Ord(nptTDate) then begin
        Kind := dtkDate;
        Format := 'dd.MM.yyyy';
      end else begin
//        Kind := dtkTime;
        Kind := dtkDate;
        Format := 'dd.MM.yyyy HH:mm:ss';
      end;
      MinDate := FMinDate;
      MaxDate := FMaxDate;
      if FFormat <> '' then Format := FFormat;

      OnKeyDown := OnKeyDownH;
      OnChange  := OnChangeH;
      OnExit    := OnExitH;
      Visible   := false;
    end;
  end;

end; //*** function TK_RAFDateTimePicEditor.CanUseEditor

//**************************************** TK_RAFDateTimePicEditor.Hide
//  OnExit Handler
//
procedure TK_RAFDateTimePicEditor.Hide;
begin
  inherited;
  if DTP <> nil then OnExitH( nil );
end; //*** function TK_RAFDateTimePicEditor.Hide

//**************************************** TK_RAFDateTimePicEditor.OnExitH
//  OnExit Handler
//
procedure TK_RAFDateTimePicEditor.OnExitH(Sender: TObject);
begin
  if not SkipExit then begin
    DTP.Visible := false;
    RAFRame.SGrid.SetFocus;
  end else begin
    SkipExit := false;
    with RAFrame.Timer do begin
      Interval := 20;
      Enabled := true;
      OnTimer := OnChangeMode;
    end;
  end;
end; //*** procedure TK_RAFDateTimePicEditor.OnExitH

//**************************************** TK_RAFDateTimePicEditor.OnKeyDownH
//  OnKeyDown Handler
//
procedure TK_RAFDateTimePicEditor.OnKeyDownH( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  FinishEdit : Boolean;
begin
  FinishEdit := false;
  case Key of

  VK_SHIFT:
    with DTP do  begin
      SkipExit := true;
      Kind := dtkDate;
      if DateMode = dmComboBox then
        DateMode := dmUpDown
      else
        DateMode := dmComboBox;
    end;
  VK_CONTROL:
    with DTP do begin
      SkipExit := true;
      DateMode := dmUpDown;
      if Kind = dtkDate then
        Kind := dtkTime
      else
        Kind := dtkDate;
    end;

  VK_RETURN:
    begin
      OnChangeH(Sender);
      FinishEdit := true;
    end;
  VK_ESCAPE:
    FinishEdit := true;
  end;
  if FinishEdit then OnExitH(Sender);
end; //*** procedure TK_RAFDateTimePicEditor.OnKeyDownH

//**************************************** TK_RAFDateTimePicEditor.OnChangeH
//  OnChange Handler
//
procedure TK_RAFDateTimePicEditor.OnChangeH(Sender: TObject);
begin
  PDateTime(PData)^ := DTP.DateTime;
  RAFRame.AddChangeDataFlag;
end; //*** procedure TK_RAFDateTimePicEditor.OnChangeH

//**************************************** TK_RAFDateTimePicEditor.OnChangeMode
//  OnChange Mode Handler
//
procedure TK_RAFDateTimePicEditor.OnChangeMode(Sender: TObject);
begin
  with RAFrame.Timer do begin
    Enabled := false;
    OnTimer := nil;
  end;
  DTP.Visible := true;
  DTP.SetFocus;
  Edit( PData^ );
end; //*** procedure TK_RAFDateTimePicEditor.OnChangeMode

{*** end of TK_RAFDateTimePicEditor ***}

{*** TK_RAFSwitchEnablingViewer ***}

destructor TK_RAFSwitchEnablingViewer.Destroy;
begin
  RV.Free;
  inherited;
end;

procedure TK_RAFSwitchEnablingViewer.DrawCell(var Data;
  var RAFC: TK_RAFColumn; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState; Canvas: TCanvas);
begin
  if RV <> nil then begin
    RV.RAFrame := RAFrame;
    RV.DrawCell(Data, RAFC, ACol, ARow, Rect, State, Canvas );
  end else
   inherited;

end;

function TK_RAFSwitchEnablingViewer.IfUseViewer(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
var
  PData : Pointer;
  IntData : Integer;
begin
  Result := false;
  if CCol = -1 then begin
    CCol := RAFrame.IndexOfColumn( SwitchColumnName );
  end;
  if CCol >= 0 then begin
    PData := RAFrame.DataPointers[CRow][CCol];
    if PData = nil  then Exit;
    IntData := (PInteger(PData)^ and $FF);
    if (K_racCDisabled in RAFC.ShowEditFlags) <>
       ( (IntData >= DisabledMinVal) and
         (IntData <= DisabledMaxVal) )then begin
      if K_racCDisabled in RAFC.ShowEditFlags then
        Exclude( RAFC.ShowEditFlags, K_racCDisabled)
      else
        Include( RAFC.ShowEditFlags, K_racCDisabled);
      RAFrame.SGrid.Invalidate;
    end;
  end;
  if RV <> nil then
    Result := RV.IfUseViewer(ACol, ARow, RAFC);
end;

procedure TK_RAFSwitchEnablingViewer.SetContext(const Data);
var
 ExtVInd : Integer;
 RVContext : string;

begin
  inherited;
  CCol := -1;
  CRow := 0;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
//*** Switch Enabling Column Name
    SwitchColumnName := nextToken( true );
    if hasMoreTokens( true ) then begin
//*** Switch Min Disabling Value
      DisabledMinVal := StrToIntDef( nextToken( true ), 0 );
      if hasMoreTokens( true ) then begin
//*** Switch Max Disabling Value
        DisabledMaxVal := StrToIntDef( nextToken( true ), DisabledMinVal );
        if hasMoreTokens( true ) then begin
//*** Self Column Viewer
          ExtVInd := K_RAFViewers.IndexOfName( nextToken( true ) );
          if ExtVInd <> -1 then begin
            RV := TK_RAFViewerClass(K_RAFViewers.Objects[ExtVInd]).Create;
            RVContext := Copy( string(Data), CPos, TLength );
            RV.SetContext( RVContext );
          end;
        end;
      end;
    end;
  end;
end;

{*** end of TK_RAFSwitchEnablingViewer ***}

{*** TK_RAFColorArrayViewer ***}

procedure TK_RAFColorArrayViewer.DrawCell(var Data; var RAFC: TK_RAFColumn;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState;
  Canvas: TCanvas);
var
  BrushSave : TBrushRecall;
  PenSave   : TPenRecall;
  WC, i, MX, h : Integer;
  RW, RR : Double;

begin
  BrushSave := TBrushRecall.Create( Canvas.Brush );
  PenSave := TPenRecall.Create( Canvas.Pen );
  with RAFC, TK_RArray(Data) do begin
    if (CDType.DTCode <> Ord(nptColor)) or
       (CDType.D.TFLags <> K_ffArray)   or
       (ALength = 0) then begin
      inherited;
      Exit;
    end;
    MX := Rect.Right;
    RW := (Rect.Right - Rect.Left) / ALength;
    h := AHigh;
    Canvas.Pen.Color := CFontColor;
    Rect.Right := Rect.Left;
    RR := Rect.Left;
    for i := 0 to h do begin
      WC := PInteger(P(i))^;
      if WC < 0 then WC := RAFrame.SGrid.Color;
      if RW < 3 then
        Canvas.Pen.Color := WC;
      Canvas.Brush.Color := WC;
      RR := RR + RW;
      Rect.Right := Round( RR );
      if i = h then Rect.Right := MX;
      Canvas.Rectangle(Rect);
      Rect.Left := Rect.Right - 1;
//      Inc(Rect.Left, RW);
    end;
  end;

  BrushSave.Free;
  PenSave.Free;

end;

function TK_RAFColorArrayViewer.GetText(var Data; var RAFC: TK_RAFColumn;
                    ACol, ARow : Integer;
                    PHTextPos : Pointer = nil ): string;
begin
  if TK_RArray(Data).ALength = 0 then
    Result := inherited GetText(Data, RAFC, ACol, ARow, PHTextPos )
  else
    Result := '';
end;

{*** end of TK_RAFColorArrayViewer ***}

{*** TK_RAFUDRAViewer ***}

destructor TK_RAFUDRAViewer.Destroy;
begin
  RV.Free;
  inherited;
end;

procedure TK_RAFUDRAViewer.DrawCell(var Data; var RAFC: TK_RAFColumn; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState; Canvas: TCanvas);
var
  WDType : TK_ExprExtType;
  WasDrawn : Boolean;

begin
  WasDrawn := false;
  if (TK_UDRArray(Data) <> nil) then begin
    with TK_UDRArray(Data), RAFC do begin
      if K_IsUDRArray(TK_UDRArray(Data)) then begin
        WDType := CDType;
//        CDType := R.ElemType;
//        CDType.D.TFlags := CDType.D.TFlags or K_ffArray;
        CDType := R.ArrayType;
        if (RV <> nil) then begin
          RV.RAFrame := RAFrame;
          RV.DrawCell(R, RAFC, ACol, ARow, Rect, State, Canvas );
        end else
          inherited DrawCell(R, RAFC, ACol, ARow, Rect, State, Canvas );
        CDType := WDType;
        WasDrawn := true;
      end;
    end;
  end;
  if not WasDrawn then inherited;
end;

function TK_RAFUDRAViewer.IfUseViewer(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
begin
  Result := inherited IfUseViewer(ACol, ARow, RAFC);
  if RV <> nil then
    Result := RV.IfUseViewer(ACol, ARow, RAFC);
end;

procedure TK_RAFUDRAViewer.SetContext(const Data);
var
 ExtVInd : Integer;
 RVContext : string;

begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    if hasMoreTokens( true ) then begin
//*** Self Column Viewer
      ExtVInd := K_RAFViewers.IndexOfName( nextToken( true ) );
      if ExtVInd <> -1 then begin
        RV := TK_RAFViewerClass(K_RAFViewers.Objects[ExtVInd]).Create;
        RVContext := Copy( string(Data), CPos, TLength );
        RV.SetContext( RVContext );
      end;
    end;
  end;
end;

{*** end of TK_RAFUDRAViewer ***}

{*** TK_RAFUDRAEditor ***}

destructor TK_RAFUDRAEditor.Destroy;
begin
  RE.Free;
  inherited;
end;

function TK_RAFUDRAEditor.Edit(var Data): Boolean;
var
  WDType : TK_ExprExtType;
  WasEdited : Boolean;
begin
  Result := false;
  WasEdited := false;
  if (TK_UDRArray(Data) <> nil) then begin
    with RAFRame.RAFCArray[RAFRame.CurLCol], TK_UDRArray(Data) do begin
      if K_IsUDRArray(TK_UDRArray(Data)) then begin
        WDType := CDType;
//        CDType := R.ElemType;
//        CDType.D.TFlags := CDType.D.TFlags or K_ffArray;
        CDType := R.ArrayType;
        if RE <> nil then begin
          RE.RAFrame := RAFrame;
          Result := RE.Edit(R);
        end else
          Result := inherited Edit(R);
        if Result then begin
          K_SetChangeSubTreeFlags( TN_UDBase(Data) );
//          K_SetArchiveChangeFlag;
        end;
        CDType := WDType;
        WasEdited := true;
      end;
    end;
  end;
  if not WasEdited then
    Result := inherited Edit( Data );
end;

function TK_RAFUDRAEditor.CanUseEditor(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
begin
  Result := inherited CanUseEditor(ACol, ARow, RAFC);
  if RE <> nil then
    Result := RE.CanUseEditor(ACol, ARow, RAFC);
end;

procedure TK_RAFUDRAEditor.SetContext(const Data);
var
 ExtVInd : Integer;
 REContext : string;

begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    if hasMoreTokens( true ) then begin
//*** Self Column Viewer
      ExtVInd := K_RAFEditors.IndexOfName( nextToken( true ) );
      if ExtVInd <> -1 then begin
        RE := TK_RAFEditorClass(K_RAFEditors.Objects[ExtVInd]).Create;
        REContext := Copy( string(Data), CPos, TLength );
        RE.SetContext( REContext );
      end;
    end;
  end;
end;

{*** end of TK_RAFUDRAEditor ***}

{*** TK_RAFSArrayEditor ***}

function TK_RAFSArrayEditor.Edit(var Data): Boolean;
var
  SL : TStringList;
  i, h : Integer;
begin
  SL := TStringList.Create;
  with TK_RArray(Data), RAFRame.RAFCArray[RAFRame.CurLCol] do begin
    if (CDType.D.TFlags and K_ffArray) = 0 then begin
// prepare StringList from String
      h := -2;
      SL.Text := string(Data);
    end else begin
// prepare StringList from Array
      h := AHigh;
      for i := 0 to h do
        SL.Add(PString(TK_RArray(Data).P(i))^);
    end;

// Edit StringList
    if K_GetFormTextEdit.EditStrings( SL, Caption ) then begin
      Result := true;
      if h = -2 then begin
// Save StringList To String
        string(Data) := copy( SL.Text, 1, Length(SL.Text) - 2 );
      end else begin
        if (h = -1) and (SL.Count <> 0) then
          TK_RArray(Data) := K_RCreateByTypeCode( Ord(nptString), 1 );
        ASetLength( SL.Count );
        h := AHigh;
// Save StringList To Array
        for i := 0 to h do
          PString(TK_RArray(Data).P(i))^ := SL.Strings[i];
      end;
    end else
      Result := false;
  end;
  SL.Free;
end;

{*** end of TK_RAFSArrayEditor ***}

{*** TK_RAFRecViewer ***}

function TK_RAFRecViewer.GetText(var Data; var RAFC: TK_RAFColumn; ACol,
  ARow: Integer; PHTextPos : Pointer = nil ): string;
begin
  with RAFC.CDType do
    if ( Length(FieldsList) > 0 ) and
       ( DTCode > Ord(nptNoData) ) then
      Result := FD.FieldsListToString( Data, FieldsList )
    else
      Result := inherited GetText(Data, RAFC, ACol, ARow, PHTextPos );
end;

procedure TK_RAFRecViewer.SetContext(const Data);
var
  WSTK : TK_Tokenizer;
  SL : TStringList;
  i :Integer;
begin
  inherited;
  WSTK := TK_Tokenizer.Create(string(Data));
  SL := TStringList.Create;
  while WSTK.hasMoreTokens() do
    SL.Add( WSTK.nextToken( true ) );
  SetLength( FieldsList, SL.Count );
  for i := 0 to High(FieldsList) do
    FieldsList[i] := SL.Strings[i];
  SL.Free;
  WSTK.Free;
end;

{*** end of TK_RAFRecViewer ***}

{*** TK_RAFFNameEditor ***}

function TK_RAFFNameEditor.Edit(var Data): Boolean;
var
  OpenDialog: TOpenDialog;
  WFName : string;
begin
  OpenDialog := TOpenDialog.Create( Application );
  if InitDir = '' then
    InitDir := K_GetDirPath( '' );
  with RAFrame, OpenDialog do begin
    WFName := string(Data);

    InitialDir := InitDir;

    Filter := FileFilter;
    FilterIndex := 1;
    FileName := WFName;
    Options := Options + [ofEnableSizing];
    if Execute and
       not (K_racReadOnly in RAFCArray[CurLCol].ShowEditFlags) then begin
      string(Data) := ExtractRelativePath( InitDir, FileName );
      Result := true;
    end else
      Result := false;
  end;
  OpenDialog.Free;
end;

procedure TK_RAFFNameEditor.SetContext(const Data);
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
    InitDir := nextToken( true);
    if InitDir = '*' then InitDir := '';
    InitDir := K_ExpandFileName( InitDir );
    hasMoreTokens(true);
    FileFilter := Copy( Text, CPos, TLength );
  end;

end;
{*** end of TK_RAFFNameEditor ***}

{*** TK_RAFFNameEditor1 ***}

function TK_RAFFNameEditor1.Edit(var Data): Boolean;
var
  OpenDialog: TOpenDialog;
  WFName : string;
  WDir : string;
  ReadOnlyMode : Boolean;
begin
  OpenDialog := TOpenDialog.Create( Application );
//*** Init Base Dir by another Frame Field
  if RAFrame <> nil then begin
    K_RAFFNameRAColContext( RFNP, RAFrame, RAFrame.CurLRow );
    with RAFrame do
      ReadOnlyMode := (K_racReadOnly in RAFCArray[CurLCol].ShowEditFlags);
  end else
    ReadOnlyMode := false;

  with OpenDialog, RFNP do begin

  //*** Prepare Dir and File
    WFName := K_RAFFNameExpand( RFNP, PString(@Data)^ );

    if FilePathFlag then
      WFName := IncludeTrailingPathDelimiter( WFName )+'!';

    WDir := ExtractFilePath( WFName );
    WFName := ExtractFileName( WFName );
    while not DirectoryExists( WDir ) do
      WDir := ExtractFilePath( ExcludeTrailingPathDelimiter(WDir) );

    Filter := FileFilter;
    FilterIndex := 1;
    InitialDir := WDir;
    FileName := WFName;
    Options := Options + [ofEnableSizing];
    if Execute and
       not ReadOnlyMode then begin
      WFName := K_RAFFNamePreResult( RFNP, FileName, PString(@Data)^ );
      if FilePathFlag then
        WFName := ExcludeTrailingPathDelimiter( ExtractFilePath( WFName ) );
      string(Data) := WFName;

      if HistoryName <> '' then // Save FName to History
        K_RAFFNameHistoryRebuild( HistoryName, WFName );

      Result := true;
    end else
      Result := false;
  end;
  OpenDialog.Free;
end;

procedure TK_RAFFNameEditor1.SetContext(const Data);
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( PString(@Data)^ );
    K_RAFFNameGetDirContext0( RFNP );
    hasMoreTokens(true);
    FileFilter := Copy( Text, CPos, TLength );
  end;

end;
{*** end of TK_RAFFNameEditor1 ***}


{*** TK_RAFFNameViewer1 ***}

function TK_RAFFNameViewer1.GetText(var Data; var RAFC: TK_RAFColumn; ACol,
  ARow: Integer; PHTextPos : Pointer = nil ): string;
var
  LPos : TK_GridPos;
  WWDir : string;
begin
  with RAFC.CDType do begin
    Result := inherited GetText(Data, RAFC, ACol, ARow, PHTextPos );
    with RFNP do begin
      if not RelPathFlag then begin
        // Field Contains Abs Path
        if Result = '' then
          Result := '*'
        else if not ShowAbsPathFlag then begin
          // Show Rel Path
          if ColumnName <> '' then begin
            LPos := RAFrame.ToLogicPos( ACol, ARow );
            K_RAFFNameRAColContext( RFNP, RAFrame, LPos.Row );
            WWDir := InitWDir;
          end else
            K_RAFFNameBuildDirs( RFNP, PString(@Data)^, WWDir );

          Result := K_ExtractRelativePath( WWDir, K_ExpandFileName( Result ) );
        end else if not ShowPathMacrosFlag then
          // Show Abs Expanded Path
          Result := K_ExpandFileName( Result );
      end else begin
        // Field Contains Rel Path
        if ShowAbsPathFlag then begin
          // Show Abs Path
          if not ShowPathMacrosFlag then
            // Show Abs Expanded Path
            Result := InitWDir + Result
          else
            // Show Macros Path
            Result := InitDir + Result;
        end;
      end;
    end;
  end;
end;

procedure TK_RAFFNameViewer1.SetContext(const Data);
var
  AInitDir : string;
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( PString(@Data)^ );
    AInitDir := K_RAFEDParsTokenizer.nextToken( true);
    if AInitDir = '' then AInitDir := '*';
    ShowAbsPathFlag := (AInitDir[1] = '!');
    if ShowAbsPathFlag then
      AInitDir := Copy( AInitDir, 2, Length( AInitDir ) );

    ShowPathMacrosFlag := (AInitDir[1] = '@');
    if ShowPathMacrosFlag then
      AInitDir := Copy( AInitDir, 2, Length( AInitDir ) );
    K_RAFFNameGetDirContext0( RFNP, AInitDir );
  end;
end;

{*** end of TK_RAFFNameViewer1 ***}

{*** TK_RAFUDEditor ***}

destructor TK_RAFUDEditor.Destroy;
begin
  RE.Free;
  inherited;
end;

function TK_RAFUDEditor.Edit(var Data): Boolean;
var
  EdInd : Integer;
begin
  Result := false;
  if TN_UDBase(Data) = nil then Exit;
    FEdInd := -1;
    EdInd := K_RAFEditors.IndexOfName( N_ClassTagArray[(TN_UDBase(Data).CI)] );
    if (EdInd <> -1) then begin
      if (RE = nil) then FEdInd := -1; // First Editor Call
      if (RE <> nil) and (EdInd <> FEdInd) then FreeAndNil(RE);
      if (RE = nil) then
        RE := TK_RAFEditorClass(K_RAFEditors.Objects[EdInd]).Create;
      RE.RAFrame := RAFrame;
      Result := RE.Edit( Data );
      FEdInd := EdInd;
    end;
end;
{*** end of TK_RAFUDEditor ***}

{*** TK_RAFUDCSProjEditor ***}

constructor TK_RAFUDCSProjEditor.Create;
begin
  inherited;
  SFilter.AddItem( TK_UDDCSProjFilterItem.Create );
end;

{*** end of TK_RAFUDCSProjEditor ***}

{*** TK_RAFUDCSProjEditor1 ***}

constructor TK_RAFUDCSProjEditor1.Create;
begin
  inherited;
  SFilter.AddItem( TK_UDDCSProjFilterItem1.Create );
end;

{*** end of TK_RAFUDCSProjEditor1 ***}
{
}


{*** TK_RAFVArrayEditor ***}

//**************************************** TK_RAFVArrayEditor.Destroy
//
destructor TK_RAFVArrayEditor.Destroy;
begin
  RE.Free;
  inherited;
end; //*** destructor TK_RAFVArrayEditor.Destroy

//**************************************** TN_RAFVArrayEditor.Edit
// Toggle VArray between external UDRArray and embedded RArray forms
//
function TK_RAFVArrayEditor.Edit(var AData): Boolean;
var
  UDR: TK_UDRArray;
  RObj: TK_RArray;
  EPars : string;
  DTCode : Integer;
begin
  Result := False;

  with RAFrame, RAFCArray[CurLCol] do begin
    if (CDType.D.TFLags and K_ffVArray) = 0 then Exit; // not VArray

    if TObject(AData) is TK_UDRArray then begin // Create new RArray by existed UDRArray
      UDR := TK_UDRArray(AData);
      TObject(AData) := nil;
      K_RFreeAndCopy( TK_RArray(AData), UDR.R, [K_mdfFreeAndFullCopy] );
      Result := True;
      SGrid.Cells[CurGCol, CurGRow] := ''; // for SGrid.DrawCell call
    end else begin // Set ref to UDRArray and copy Existed RArray content to it if needed
      RObj := TK_RArray(AData);
      if RE = nil then begin
        RE := TK_RAFUDRARefEditor.Create;
        if RObj = nil then
          DTCode := CDType.DTCode
        else
          DTCode := RObj.ElemSType;
        EPars := K_udpAbsPathCursorName;
        if DTCode > 0 then
          EPars := EPars + ' ' + K_GetExecTypeName( DTCode );
        RE.SetContext( EPars );
        RE.RAFrame := RAFrame;
        K_RAFUDRefDefPathObj := RAFrame.RLSData.RUDRArray;
      end;
      Result := RE.Edit( AData );
    end; // else // Set ref to UDRArray
  end;

end; //*** procedure TN_RAFVArrayEditor.Edit

{*** end of TK_RAFVArrayEditor ***}

{*** TK_RAFNFontViewer ***}

function TK_RAFNFontViewer.GetText(var Data; var RAFC: TK_RAFColumn; ACol,
  ARow: Integer; PHTextPos: Pointer): string;
begin
  if TObject(Data) = nil then begin
    Result := UndefText;
    if Result = '' then
      Result := 'not defined';
  end else if (TObject(Data) is TN_UDBase) or
          ((TObject(Data) is TK_RArray) and
           (TK_RArray(Data).ElemSType <> N_SPLTC_NFont)) then
    inherited GetText( Data, RAFC, ACol, ARow, PHTextPos )
  else
    with TN_PNFont(TK_RArray(Data).P)^ do
      Result := NFFaceName + ', ' + FloatToStr(NFLLWHeight) + ' ...';
end;

procedure TK_RAFNFontViewer.SetContext(const Data);
begin
  inherited;
  with K_RAFEDParsTokenizer do begin
    setSource( string(Data) );
//*** Switch Enabling Column Name
    UndefText := nextToken( true );
    if UndefText = '' then
      UndefText := 'not defined';
  end;

end;
{*** end of TK_RAFNFontViewer ***}

end.
