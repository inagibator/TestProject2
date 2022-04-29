unit N_RAEditF;
// Form for Editing Components and any other Pascal records in memory with
// ability to peform given actions while editing (e.g. Map redrawing)
// based on TK_FrameRAEdit

// TN_CompStructType     = ( cstNotAComp,  cstSetParams, cstUserParams,
// TN_PenStyleFields     = packed record // Pen Flags as several Fields
// TN_RAEditForm         = class( TN_BaseForm ) //***** RArray Edit Form

// TN_RAFRAEditEditor    = class( TK_RAFEditor ) // RAEditForm as external Editor(Viewer)
// TN_RAFUDRefEditor     = class( TK_RAFEditor ) // UObjFrame.PopupMenu Actions as external Editor
       // TN_RAFVArrayEditor    = class( TK_RAFEditor ) // UObjFrame.PopupMenu Actions as external Editor
// TN_RAFUserParamEditor = class( TK_RAFEditor ) // User Parameter Editor(Viewer)
// TN_RAFCharCodesEditor = class( TK_RAFEditor ) // String as Char Codes Editor
// TN_RAFPA2SPEditor     = class( TK_RAFEditor ) // Point Attr #2 Specific Params Editor(Viewer)
// TN_RAFPenStyleEditor  = class( TK_RAFEditor ) // Windows Pen Style (Flags) Editor(Viewer)
// TN_RAFTableStrEditor  = class( TK_RAFEditor ) // Table of strings Editor as external Editor
// TN_RAFMSScalEditor    = class( TK_RAFEditor ) // MS Scalar external Editor(Viewer)
// TN_RAFMSPointEditor   = class( TK_RAFEditor ) // MS Point external Editor(Viewer)
// TN_RAFMSRectEditor    = class( TK_RAFEditor ) // MS Rect external Editor(Viewer)

// TN_RAEditFuncCont     = record // TN_PRAEditForm as Glob Func Context

interface
uses
  Windows, Messages, Controls, Classes, Forms, StdCtrls, inifiles, Types, Grids,
  Graphics, ComCtrls, ToolWin, Menus, ActnList,
  K_UDT1, K_SCript1, K_FrRAEdit,
  N_Types, N_Lib1, N_Lib2, N_BaseF, N_Rast1Fr, N_UDCMap, N_CompBase,
  ExtCtrls;

// Component structure currently beeing edited:
type TN_CompStructType = ( cstNotAComp,  cstSetParams, cstUserParams,
                           cstComParams, cstLayout, cstCoords, cstPanel,
                           cstIndParams, cstExpParams );

type TN_PenStyleFields = packed record // Pen Flags as several Fields
  PFFType:     byte;
  PFFStyle:    byte;
  PFFEndCap:   byte;
  PFFLineJoin: byte;
end; // type TN_PenStyleFields = packed record

type TN_RAEditForm = class( TN_BaseForm ) //***** RArray Edit Form
    RAEditFrame: TK_FrameRAEdit;
    bnCancel: TButton;           
    bnOK: TButton;
    bnApply: TButton;
    ToolBarOwn: TToolBar;
    StatusBar: TStatusBar;
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    View1: TMenuItem;
    miOther: TMenuItem;
    ToolBarArray: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    FormActions: TActionList;
    ToolBarComp: TToolBar;
    tbCompSetParams: TToolButton;
    tbCompLayout: TToolButton;
    aDebToggleStatDyn: TAction;
    aCompSetParams: TAction;
    aCompLayoutParams: TAction;
    aCompCoordsParams: TAction;
    aCompIndivParams: TAction;
    aCompPanelParams: TAction;
    tbCompCoords: TToolButton;
    tbCompPanel: TToolButton;
    tbCompIndParams: TToolButton;
    ToolButton11: TToolButton;
    aSECopyFullFieldName: TAction;
    aAEFillRArray: TAction;
    aAESetRArraySize: TAction;
    aViewFieldInfo: TAction;
    aViewFieldInfo1: TMenuItem;
    aCompUserParams: TAction;
    tbCompUserParams: TToolButton;
    CompMMI: TMenuItem;
    EditCompSettings1: TMenuItem;
    EditCompUserParams1: TMenuItem;
    EditCompLayout1: TMenuItem;
    EditCompCoords1: TMenuItem;
    EditCompPanel1: TMenuItem;
    N5: TMenuItem;
    aCompViewExecute: TAction;
    ExecuteComponent1: TMenuItem;
    N3: TMenuItem;
    aViewEditObjInfo: TAction;
    ViewEditObjInfo1: TMenuItem;
    aDebEditCompSPLText: TAction;
    aDebClearSelfRTI: TAction;
    miDebug: TMenuItem;
    oggleStatDynParams1: TMenuItem;
    ViewComponentSPLText1: TMenuItem;
    ClearSelfRTI1: TMenuItem;
    aCompCommonParams: TAction;
    tbCompComParams: TToolButton;
    bnSetUObj: TToolButton;
    cbApplyToMarked: TCheckBox;
    aDebTmpAction1: TAction;
    aDebAction11: TMenuItem;
    aDebTmpAction2: TAction;
    aDebTmpAction3: TAction;
    mpAction21: TMenuItem;
    mpAction31: TMenuItem;
    N6: TMenuItem;
    aSESetCSAndCSCode: TAction;
    aSESetUObj: TAction;
    aEdCopySelected: TAction;
    aEdPasteInsteadOfSelected: TAction;
    aEdPasteAndFillAllSelected: TAction;
    aEdClearSelected: TAction;
    aEdDestroySelectedRecords: TAction;
    aEdCreateNewRecords: TAction;
    aEdPasteInsideSelected: TAction;
    CopySelectedToClipboard1: TMenuItem;
    PasteInsideSelected1: TMenuItem;
    PasteInsteadOfSelected1: TMenuItem;
    PasteInsideSelected2: TMenuItem;
    ClearSelectedFields1: TMenuItem;
    N1: TMenuItem;
    CreateNewRecords1: TMenuItem;
    DestroySelectedRecords1: TMenuItem;
    CopyFullFieldName1: TMenuItem;
    SetCSorCSCodes1: TMenuItem;
    SetUObjbySelectedUObj1: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    aAESetRArraysSizes: TAction;
    aCompExportParams: TAction;
    aEdCreateExportParams: TAction;
    N2: TMenuItem;
    aEdCreateSetParams: TAction;
    aEdCreateUserParams: TAction;
    tbCompExpParams: TToolButton;
    aEdCreatePanelParams: TAction;
    aIESetTableSize: TAction;
    ToolButton10: TToolButton;
    tbIndEdit1: TToolButton;
    tbIndEdit2: TToolButton;
    aAESet2DRArraySize: TAction;
    aAEFill2DRArray: TAction;
    tbIndFieldEd1: TToolButton;
    aIEView2DRArray: TAction;
    aCompViewAsSrcText: TAction;
    aCompViewInExtBrowser: TAction;
    aCompViewInMSWord: TAction;
    aCompViewSetCurAux: TAction;
    aCompViewByCurAux: TAction;
    aCompViewMain: TAction;
    aCompViewPictFromFile: TAction;
    ViewComponentAsGDIPicture1: TMenuItem;
    N4: TMenuItem;
    SetComponentAuxViewer1: TMenuItem;
    aCompViewPictInMem: TAction;
    aCompViewHTMLFile: TAction;
    aSEImportUDTable: TAction;
    aSEExportUDTable: TAction;
    ImportUDTable1: TMenuItem;
    ExportUDTable1: TMenuItem;
    EditComponentCommonParams1: TMenuItem;
    ComponentExportParams1: TMenuItem;
    aCompViewInMSExcel: TAction;
    miEditCompIndividualParams: TMenuItem;
    ArrayEdit1: TMenuItem;
    aAEEditAs1DRArray: TAction;
    aAEEditAs2DRArray: TAction;
    SetRArraySize1: TMenuItem;
    Set2DRArrayDimensions1: TMenuItem;
    SetAllRArraysSizes1: TMenuItem;
    FillRArraybyTestData1: TMenuItem;
    Fill2DRArraybyTestData1: TMenuItem;
    N7: TMenuItem;
    aAEEditAs1DRArray1: TMenuItem;
    EditAs2DRArray1: TMenuItem;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    aViewObjHelp: TAction;
    ViewObjectHelp1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    CreateComponentSettings1: TMenuItem;
    CreateComponentUserParams1: TMenuItem;
    CreateComponentPanelParams1: TMenuItem;
    CreateComponentExportParams1: TMenuItem;
    N10: TMenuItem;
    ToolButton15: TToolButton;

    //***************  FormActionList Handlers  ******************

//    procedure WMEraseBkgnd ( var m: TWMEraseBkgnd ); message WM_ERASEBKGND;

    //****************** Component View Actions ***************************
    procedure aCompViewExecuteExecute   ( Sender: TObject );
    procedure aCompViewMainExecute      ( Sender: TObject );
    procedure aCompViewByCurAuxExecute  ( Sender: TObject );
    procedure aCompViewSetCurAuxExecute ( Sender: TObject );

    //****************** Component Params Actions *************************
    procedure aCompSetParamsExecute    ( Sender: TObject );
    procedure aCompUserParamsExecute   ( Sender: TObject );
    procedure aCompExportParamsExecute ( Sender: TObject );
    procedure aCompCommonParamsExecute ( Sender: TObject );
    procedure aCompLayoutParamsExecute ( Sender: TObject );
    procedure aCompCoordsParamsExecute ( Sender: TObject );
    procedure aCompPanelParamsExecute  ( Sender: TObject );
    procedure aCompIndivParamsExecute  ( Sender: TObject );

    //****************** Edit Actions *************************************
    procedure aEdCopySelectedExecute            ( Sender: TObject );
    procedure aEdPasteInsteadOfSelectedExecute  ( Sender: TObject );
    procedure aEdPasteInsideSelectedExecute     ( Sender: TObject );
    procedure aEdPasteAndFillAllSelectedExecute ( Sender: TObject );
    procedure aEdClearSelectedExecute           ( Sender: TObject );

    procedure aEdCreateNewRecordsExecute        ( Sender: TObject );
    procedure aEdDestroySelectedRecordsExecute  ( Sender: TObject );

    procedure aEdCreateSetParamsExecute         ( Sender: TObject );
    procedure aEdCreateUserParamsExecute        ( Sender: TObject );
    procedure aEdCreatePanelParamsExecute       ( Sender: TObject );
    procedure aEdCreateExportParamsExecute      ( Sender: TObject );

    //****************** Array Edit Actions *******************************
    procedure aAESetRArraySizeExecute   ( Sender: TObject );
    procedure aAESet2DRArraySizeExecute ( Sender: TObject );
    procedure aAESetRArraysSizesExecute ( Sender: TObject );
    procedure aAEFillRArrayExecute      ( Sender: TObject );
    procedure aAEFill2DRArrayExecute    ( Sender: TObject );
    procedure aAEEditAs1DRArrayExecute  ( Sender: TObject );
    procedure aAEEditAs2DRArrayExecute  ( Sender: TObject );

    //****************** Special Edit Actions *****************************
    procedure aSECopyFullFieldNameExecute ( Sender: TObject );
    procedure aSESetCSAndCSCodeExecute    ( Sender: TObject );
    procedure aSESetUObjExecute           ( Sender: TObject );
    procedure aSEImportUDTableExecute     ( Sender: TObject );
    procedure aSEExportUDTableExecute     ( Sender: TObject );

    //****************** Individual Edit Actions **************************
    procedure aIESetTableSizeExecute ( Sender: TObject );
    procedure aIEView2DRArrayExecute ( Sender: TObject );

    //****************** View Actions *************************************
    procedure aViewFieldInfoExecute   ( Sender: TObject );
    procedure aViewEditObjInfoExecute ( Sender: TObject );
    procedure aViewObjHelpExecute     ( Sender: TObject );

    //****************** Debug Actions ************************************
    procedure aDebToggleStatDynExecute   ( Sender: TObject );
    procedure aDebEditCompSPLTextExecute ( Sender: TObject );
    procedure aDebClearSelfRTIExecute    ( Sender: TObject );
    procedure aDebTmpAction1Execute      ( Sender: TObject );
    procedure aDebTmpAction2Execute      ( Sender: TObject );
    procedure aDebTmpAction3Execute      ( Sender: TObject );

    procedure bnApplyClick  ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure bnOKClick     ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
    CurFieldName:      string;
    CurFieldIndex:     Integer;
    CurFieldTypeName:  string;
    CurFieldUObj:      TN_UDBase;   // only if Field is UDBase or VArray
    CurFieldTypeCode:  TK_ExprExtType;
    CurFieldTypeIsDynamic: boolean; // only if Field is RArray or VArray
//    CurVArrayIsUDBase:     boolean; // only if Field is VArray
    PCurFieldDescr:    TK_PRAFColumn;
    PCurFieldInBuf:    Pointer;
    PCurRArrayField:   TK_PRArray; // nil or equal to PCurFieldInBuf

    PRecord:         Pointer;
    RecordTypeName:  string;  // SPL and Pascal Data Type Name (e.g. TN_CPanel)
    RecordTypeCode : TK_ExprExtType;
    RecordRAFlags:   TN_RAEditFlags;
    CompTypeName: string;
//    CompTypeCode : TK_ExprExtType;

    StaticParams: boolean;
    CompStructType: TN_CompStructType;
    CurRArray: TK_RArray; // Static (Comp.R) or Dynamic (Comp.DynPar) Component RArray
    StatOrDynStr: string; // 'Static' or 'Dynamic' string for showing in StatusBar
    RAModeFlags: TK_RAModeFlagSet;
  public
    CurFieldFullName: string;
    RecordUObj: TK_UDRArray; // Record Container (UDRArray or nil)
    FormDescr: TK_UDRArray; // if it was created in InitFormDescr
                //  (FormDescr.Owner = nil), it should be deleted in FormClose
    DataWasChanged: boolean;
    RedrawRFrame:   boolean;
    FRRAControl:    TK_FRAData;
    RaEdGAProcOfObj: TK_RAFGlobalActionProc;  // External Global Action
    UpValsInfo: TN_UpdateValsInfo;

    procedure OnDataApply          ();
    procedure OnCancelToAll        ();
    procedure OnOKToAll            ();
    procedure SetDataChangedFlag   ();
    procedure ClearDataChangedFlag ();
    procedure PrepareFrame     ( AFormDescrName: string; IsArray: boolean = False );
    procedure PrepToolBarArray ( AIsVisible: boolean );
    procedure SetFrameByStructType ();
    procedure UpdateUObj       ( AUObj: TK_UDRArray );

    procedure InitByTypeName   ( AAFormDescrName: string = '' );
    procedure GetCurFieldInfo  ();
    procedure PrepPopupMenu    ();
    procedure PrepCompScalarStruct ();
    procedure ShowString       ( AStr: string );
    procedure TuneViewers      ();

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_RAEditForm = class( TN_BaseForm )
type TN_PRAEditForm = ^TN_RAEditForm;


//**************** External Editors(Viewers) ******************************

type TN_RAFRAEditEditor = class( TK_RAFEditor ) // RAEditForm as external Editor and Viewer
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
//  procedure DrawCell ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
//                Rect: TRect; State: TGridDrawState; Canvas: TCanvas ); override;
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFRAEditEditor = class( TK_RAFEditor )

{
type TN_RAFVArrayEditor = class( TK_RAFEditor ) // Toggle VArray type as external Editor
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFVArrayEditor = class( TK_RAFEditor )
}

type TN_RAFUDRefEditor = class( TK_RAFEditor ) // UObjFrame.PopupMenu Actions as external Editor
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFUDRefEditor = class( TK_RAFEditor )

type TN_RAFUserParamEditor = class( TK_RAFEditor ) // User Parameter Editor(Viewer)
  function  GetText  ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  procedure DrawCell ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                Rect: TRect; State: TGridDrawState; Canvas: TCanvas ); override;
  procedure ConvFromString ( AResultText: string; var AData );
  function  Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFUserParamEditor = class( TK_RAFEditor )

type TN_RAFCharCodesEditor = class( TK_RAFEditor ) // String as Char Codes Editor
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFCharCodesEditor = class( TK_RAFEditor )

type TN_RAFValsInStrEditor = class( TK_RAFEditor ) // Values in String Editor
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFValsInStrEditor = class( TK_RAFEditor )

type TN_RAFPA2SPEditor = class( TK_RAFEditor ) // Point Attr #2 Specific Params Editor and Viewer
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFPA2SPEditor = class( TK_RAFEditor )

type TN_RAFPenStyleEditor = class( TK_RAFEditor ) // Windows Pen Style (Flags) Editor and Viewer
  PPenStyle: PInteger;
  PFF: TN_PenStyleFields;
  function PenStyleGlobAct( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFPenStyleEditor = class( TK_RAFEditor )

type TN_RAFTableStrEditor = class( TK_RAFEditor ) // Table of strings Editor as external Editor
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFTableStrEditor = class( TK_RAFEditor )

type TN_RAFMSScalEditor = class( TK_RAFEditor ) // MS Scalar external Editor and Viewer
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  procedure ConvFromString ( AResultText: string; var AData );
  function  Edit ( var AData ) : Boolean; override;
end; //*** type TN_RAFMSScalEditor = class( TK_RAFEditor )

type TN_RAFMSPointEditor = class( TK_RAFEditor ) // MS Point external Editor and Viewer
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  procedure ConvFromString ( AResultText: string; var AData );
  function  Edit ( var AData ) : Boolean; override;
end; //*** type TN_RAFMSPointEditor = class( TK_RAFEditor )

type TN_RAFMSRectEditor = class( TK_RAFEditor ) // MS Rect external Editor and Viewer
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  procedure ConvFromString ( AResultText: string; var AData );
  function  Edit ( var AData ) : Boolean; override;
end; //*** type TN_RAFMSRectEditor = class( TK_RAFEditor )


//**************** Other Objects ******************************

type TN_RAEditFuncCont = record // TN_PRAEditForm as Glob Func Context
  RAEDFC: TK_RAEditFuncCont; // Standard context (should be the first field!)
  GEDummy1: integer;
//  GEFUObj: TK_UDRArray;      // UObj to be edited
//  GEFDataTypeName: string;   // Data Record TypeName (e.g. TN_RPanel)
end; // type TN_RAEditFuncCont = record
type TN_PRAEditFuncCont = ^TN_RAEditFuncCont;


    //*********** Global Procedures  *****************************

function N_CreateRAEditForm ( AOwner: TN_BaseForm ): TN_RAEditForm;

function N_GetRAEditForm ( ARAFlags: TN_RAEditFlags; PRAEditForm: TN_PRAEditForm;
                    var ARecord; ATypeName: string; AFormDescrName: string = '';
                    AGAProcOfObj: TK_RAFGlobalActionProc = nil;
          AUDObj: TK_UDRArray = nil; AOwner: TN_BaseForm = nil ): TN_RAEditForm;

function N_CallRAEditForm ( var AData; APDContext: Pointer ): Boolean;

procedure N_EditRAFrameField ( var AData; ARAFrame: TK_FrameRAEdit );


var
  N_RAEditFuncCont: TN_RAEditFuncCont;

implementation
{$R *.dfm}
uses
  Math, Dialogs, SysUtils, Clipbrd, Variants, ComObj,
  K_Sparse1, K_RAEdit, K_CLib0, K_CLib, K_FSelectUDB,
  K_DCSpace, K_FDCSpace, K_FCSDBlock, K_FCSDim,
  N_ClassRef, N_Gra0, N_Gra1, N_ME1, N_Comp1, N_NVTreeFr, N_UObjFr, N_Deb1,
  N_CompCL, N_ButtonsF, N_InfoF, N_EdStrF, N_PlainEdF, N_NVTreeF, N_MsgDialF,
  N_Lib0, N_Comp2, N_Comp3, N_GCont, N_RVCTF, N_EdParF, N_RaEd2DF, N_HelpF,
  N_VVEdBaseF, N_VScalEd1F, N_VPointEd1F, N_VRectEd1F, N_MenuF, N_Color1F;


    //***************  TN_RAEdit FormActionList Handlers  ********************

{
//**************************************** TN_RAEditForm.WMEraseBkgnd ***
// prevent processing Windows message EraseBkgnd (Erase Background)
// ( can be used because whole Frame is redrawn manualy,
//   if absent - causes flicker while updating (redrawing) Frame )
//
procedure TN_RAEditForm.WMEraseBkgnd( var m: TWMEraseBkgnd );
begin
  m.Result := LRESULT(False); // disable drawing background
//  m.Result := LRESULT(True); // enable drawing background (default value)
end; // end of procedure TN_RAEditForm.WMEraseBkgnd
}
    //****************** Component View Actions ***

procedure TN_RAEditForm.aCompViewExecuteExecute( Sender: TObject );
// Execute Current component
begin
  if RecordUObj is TN_UDCompBase then
    with N_MEGlobObj.NVGlobCont do
    begin
      ShowString( '' );
      ExecuteRootComp( RecordUObj, [], ShowString, Self );
    end;
end; // procedure TN_RAEditForm.aCompViewExecuteExecute

procedure TN_RAEditForm.aCompViewMainExecute( Sender: TObject );
// View the result of Current Component By Main Viewer
// ( View GDI Pict in Memory, HTML File by Delphi Browser, MS Office Document by MS Office )
begin
  N_ViewCompMain( RecordUObj, ShowString, Self );
end; // procedure TN_RAEditForm.aCompViewMainExecute

procedure TN_RAEditForm.aCompViewByCurAuxExecute( Sender: TObject );
// View Current Component By Current Aux Viewer (set in aCompViewSetCurAux Action)
var
  FName: string;
  PRVCTForm: TN_PRastVCTForm;
  PTextEdForm: TN_PPlainEditorForm;
  ExpFlags: TN_CompExpFlags;
begin
  if not (RecordUObj is TN_UDCompBase) then Exit; // not a Component

  with TN_UDCompBase(RecordUObj), N_MEGlobObj do
  begin

    //***** RecordUObj should be exported to File before Viewing
    aCompViewExecuteExecute( nil );

    FName := NVGlobCont.GCMainFileName; // to reduce code size
    if FName = '' then Exit; // a precaution

    ExpFlags := GetExpFlags();

    if cefGDIFile in ExpFlags then // View Picture File
    begin

      if CompPictViewerInd = 0 then // View Pict File by Own Viewer
      begin
        if N_KeyIsDown( N_VKShift ) then // View in separate Window
          PRVCTForm := nil
        else // View in already opened Window (if any) or create new Window
          PRVCTForm := @RastVCTForm;

        N_GetMERastVCTForm( PRVCTForm, Self );

        with PRVCTForm^ do
        begin
          ShowPictFile( FName );
          Show();
        end; // with PRVCTForm^ do
      end; // if CurCompPictViewerInd = 0 then // View Pict File by Own Viewer

      Exit;
    end;

    if cefTextFile in ExpFlags then // View Text (HTML, SVG, ...) File
    begin

      if CompTextViewerInd = 0 then // View Text Document in Ext. Browser
      begin
        K_ShellExecute( 'open', FName );
      end; // View Text Document in Ext. Browser

      if CompTextViewerInd = 1 then // View Text Document in MS Word
      begin
//        K_ShellExecute( 'open', N_PathToWord, -1, nil, FName );
        N_ViewFileInMSWord( FName );
      end; // View Text Document in MS Word

      if CompTextViewerInd = 2 then // View Text Document in Text Editor (View Source Text)
      begin

        if N_KeyIsDown( N_VKShift ) then // View in separate Window
          PTextEdForm := nil
        else // View in already opened Window (if any) or create new Window
          PTextEdForm := @PlainEdForm;

        N_GetMEPlainEditorForm( PTextEdForm, Self );

        with PTextEdForm^ do
        begin
          OpenFileAsText( FName );
          Show();
        end;

      end; // View Text Document in Text Editor (View Source Text)

      Exit;
    end; // if cefTextFile in ExpFlags then // View Text (HTML, SVG, ...) File

  end; // with TN_UDCompBase(RecordUObj), N_MEGlobObj do

end; // procedure TN_RAEditForm.aCompViewByCurAuxExecute

procedure TN_RAEditForm.aCompViewSetCurAuxExecute( Sender: TObject );
// Set Current Aux Viewer and View Current Component By it
var
  ExpFlags: TN_CompExpFlags;
begin
  if not (RecordUObj is TN_UDCompBase) then Exit; // not a Component

  with TN_UDCompBase(RecordUObj), N_MEGlobObj do
  begin
    ExpFlags := GetExpFlags();

    if cefGDIFile in ExpFlags then //************ Set Picture File Aux Viewer
    begin
      CompPictViewerInd := 0; // the only Viewer
      aCompViewByCurAuxExecute( nil );
    end else if cefGDIFile in ExpFlags then //*** Set Text Document Aux Viewer
    begin
      with N_CreateEditParamsForm( 200 ) do
      begin
        AddFixComboBox( 'Aux Document Viewer:', N_CompTextViewerNames, CompTextViewerInd );

        ShowSelfModal();

        if OKPressed then
        begin
          CompTextViewerInd := EPControls[0].CRInt;
          aCompViewByCurAuxExecute( nil );
        end;
        Release; // Free EditParamsForm
      end; // with N_CreateEditParamsForm( 200 ) do
    end; // else - Set Text Document Aux Viewer

    TuneViewers();
  end; // with TN_UDCompBase(RecordUObj), N_MEGlobObj do
end; // procedure TN_RAEditForm.aCompViewSetCurAuxExecute


    //****************** Component Params Actions *******************

procedure TN_RAEditForm.aCompSetParamsExecute( Sender: TObject );
// Edit Component's SetParams RArray
begin
  PrepToolBarArray ( True );

  PRecord := @TN_PRCompBase(CurRArray.P())^.CSetParams;
  RecordTypeName := K_sccArray + ' TN_OneSetParam';
  RAEditFrame.DataPath := 'CSetParams';

  PrepareFrame( 'TN_SetParamsFormDescr', True );

  CompStructType := cstSetParams;
  ShowString( StatOrDynStr + ', Settings List' );
  tbCompSetParams.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompSetParamsExecute

procedure TN_RAEditForm.aCompUserParamsExecute( Sender: TObject );
// Edit Component's UserParams RArray
begin
  PrepToolBarArray ( True );

  PRecord := @TN_PRCompBase(CurRArray.P())^.CCompBase.CBUserParams;
  RecordTypeName := K_sccArray + ' TN_OneUserParam';
  RAEditFrame.DataPath := 'CCompBase.CBUserParams';

  PrepareFrame( 'TN_UserParamsFormDescr', True );

  CompStructType := cstUserParams;
  ShowString( StatOrDynStr + ', User' );
  tbCompUserParams.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompUserParamsExecute

procedure TN_RAEditForm.aCompExportParamsExecute( Sender: TObject );
// Edit Component's Export Params
begin
  PrepToolBarArray ( True );

  PRecord := @TN_PRCompBase(CurRArray.P())^.CCompBase.CBExpParams;
  RecordTypeName := K_sccArray + ' TN_ExpParams';
  RAEditFrame.DataPath := 'CCompBase.CBExpParams';

  PrepareFrame( 'TN_ExpParamsFormDescr', True );

  CompStructType := cstExpParams;
  ShowString( StatOrDynStr + ', Export Params' );
  tbCompExpParams.Down := True; // is needed only for first call
  TuneViewers();
end; // procedure TN_RAEditForm.aCompExportParamsExecute

procedure TN_RAEditForm.aCompCommonParamsExecute( Sender: TObject );
// Edit Component's Common Params
begin
  PrepCompScalarStruct();
  PrepareFrame( 'TN_RCompBaseFormDescr' );
  CompStructType := cstComParams;
  ShowString( StatOrDynStr + ', Common' );
  tbCompComParams.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompCommonParamsExecute

procedure TN_RAEditForm.aCompLayoutParamsExecute( Sender: TObject );
// Edit Visual Component's Layout
begin
  PrepCompScalarStruct();
  CompStructType := cstLayout;
  ShowString( StatOrDynStr + ', Layout' );
  tbCompLayout.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompLayoutParamsExecute

procedure TN_RAEditForm.aCompCoordsParamsExecute( Sender: TObject );
// Edit Visual Component's Coords
begin
  PrepCompScalarStruct();
  PrepareFrame( 'TN_RCoordsFormDescr' );
  CompStructType := cstCoords;
  ShowString( StatOrDynStr + ', Coords' );
  tbCompCoords.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompCoordsParamsExecute

procedure TN_RAEditForm.aCompPanelParamsExecute( Sender: TObject );
// Edit Visual Component's Panel Params
begin
  PrepToolBarArray ( True );

  PRecord := @TN_PRCompVis(CurRArray.P())^.CPanel;
  RecordTypeName := K_sccArray + ' TN_CPanel';
  RAEditFrame.DataPath := 'CPanel';

  PrepareFrame( 'TN_CPanelFormDescr', True );

  CompStructType := cstPanel;
  ShowString( StatOrDynStr + ', Panel' );
  tbCompPanel.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompPanelParamsExecute

procedure TN_RAEditForm.aCompIndivParamsExecute( Sender: TObject );
// Edit Component's Individual Params
begin
  PrepCompScalarStruct();

  case RecordUObj.CI of

  N_UDPanelCI:      PrepareFrame( 'TN_CPanelFormDescr' );
//  N_UDTextRowCI:    PrepareFrame( 'TN_RTextRowFormDescr' );
  N_UDTextBoxCI:    PrepareFrame( 'TN_RTextBoxFormDescr' );
  N_UDParaBoxCI:    PrepareFrame( 'TN_RParaBoxFormDescr' );
  N_UDLegendCI:     PrepareFrame( 'TN_RLegendFormDescr' );
  N_UDNLegendCI:    PrepareFrame( 'TN_RNLegendFormDescr' );
  N_UDPictureCI:    PrepareFrame( 'TN_RPictureFormDescr' );
  N_UDDIBCI:        PrepareFrame( 'TN_RDIBFormDescr' );
  N_UDDIBRectCI:    PrepareFrame( 'TN_RDIBRectFormDescr' );
  N_UDFileCI:       PrepareFrame( 'TN_RFileFormDescr' );
  N_UDActionCI:     PrepareFrame( 'TN_RActionFormDescr' );

  N_UDPolylineCI:   PrepareFrame( 'TN_RPolylineFormDescr' );
  N_UDArcCI:        PrepareFrame( 'TN_RArcFormDescr' );
  N_UDSArrowCI:     PrepareFrame( 'TN_RSArrowFormDescr' );
  N_UD2DSpaceCI:    PrepareFrame( 'TN_R2DSpaceFormDescr' );
  N_UDAxisTicsCI:   PrepareFrame( 'TN_RAxisTicsFormDescr' );
  N_UDTextMarksCI:  PrepareFrame( 'TN_RTextMarksFormDescr' );
  N_UDAutoAxisCI:   PrepareFrame( 'TN_RAutoAxisFormDescr' );
  N_UD2DFuncCI:     PrepareFrame( 'TN_R2DFuncFormDescr' );
  N_UDIsoLinesCI:   PrepareFrame( 'TN_RIsoLinesFormDescr' );
  N_UD2DLinHistCI:  PrepareFrame( 'TN_R2DLinHistFormDescr' );
  N_UDLinHistAuto1CI: PrepareFrame( 'TN_RLinHistAuto1FormDescr' );
  N_UDPieChartCI:   PrepareFrame( 'TN_RPieChartFormDescr' );
  N_UDTableCI:      PrepareFrame( 'TN_RTableFormDescr' );
  N_UDCompsGridCI:  PrepareFrame( 'TN_RCompsGridFormDescr' );

  N_UDQUery1CI:     PrepareFrame( 'TN_RQuery1FormDescr' );
  N_UDQUery2CI:     PrepareFrame( 'TN_RQuery2FormDescr' );
  N_UDIteratorCI:   PrepareFrame( 'TN_RIteratorFormDescr' );
  N_UDCreatorCI:    PrepareFrame( 'TN_RCreatorFormDescr' );
  N_UDNonLinConvCI: PrepareFrame( 'TN_RNonLinConvFormDescr' );
  N_UDDynPictCreatorCI: PrepareFrame( 'TN_RDynPictCreatorFormDescr' );
  N_UDTextFragmCI:  PrepareFrame( 'TN_RTextFragmFormDescr' );
  N_UDWordFragmCI:  PrepareFrame( 'TN_RWordFragmFormDescr' );
  N_UDExcelFragmCI: PrepareFrame( 'TN_RExcelFragmFormDescr' );
  N_UDExpCompCI:    PrepareFrame( 'TN_RExpCompFormDescr' );

  N_UDMapLayerCI: begin
    case TN_UDMapLayer(RecordUObj).PISP()^.MLType of
      mltPoints1:     PrepareFrame( 'TN_RMapPointsLayerFormDescr' );
      mltComponents:  PrepareFrame( 'TN_RMapPointsLayerFormDescr' );
      mltLines1:      PrepareFrame( 'TN_RMapLinesLayerFormDescr' );
      mltConts1:      PrepareFrame( 'TN_RMapContsLayerFormDescr' );
      mltHorLabels:   PrepareFrame( 'TN_RMapLabelsLayerFormDescr' );
      mltCurveLabels: PrepareFrame( 'TN_RMapLabelsLayerFormDescr' );
      else
        PrepareFrame( 'TN_RMapPointsLayerFormDescr' );
    end; // case TN_CMapLayer(ARecord).MLType of
  end; // N_UDMapLayerCI: begin


  N_UDCalcUParamsCI: begin
    // Correct fields, set by PrepCompScalarStruct():
    PRecord := @TN_PRCalcUParams(CurRArray.P())^.CCalcUParams.CVElems;
    RecordTypeName := K_sccArray + ' TN_CalcUParamsElem';
    RAEditFrame.DataPath := 'CCalcUParams.CVElems';

    PrepareFrame( 'TN_CalcUParamsElemFormDescr', True );
  end; // N_UDCalcUParamsCI: begin

  end; // case RecordUObj.CI of

  CompStructType := cstIndParams;
  ShowString( StatOrDynStr + ', Individual' );
  tbCompIndParams.Down := True; // is needed only for first call
end; // procedure TN_RAEditForm.aCompIndivParamsExecute


    //****************** Edit Actions ********************************

procedure TN_RAEditForm.aEdCopySelectedExecute( Sender: TObject );
// Copy Content of Selected Fields to Clipboard
begin
  RAEditFrame.CopyToClipBoardExecute( Sender );
end; // procedure TN_RAEditForm.aEdCopySelectedExecute

procedure TN_RAEditForm.aEdPasteInsteadOfSelectedExecute( Sender: TObject );
// Paste Clipboard Content Instead of Selected Fields
// if Number of Recods with Sected Fields is less then Number of records in
//   Cilpboard, additional Records are created after selected
// if Number of Recods with Sected Fields ss bigger then Number of records in
//   Cilpboard, additional Records are destroyed
begin
  K_RAFClipBoard.Flags := [K_sdmReplaceSelectedRowsOnly];
  RAEditFrame.PasteFromClipBoardExecute( Sender );
end; // procedure TN_RAEditForm.aEdPasteInsteadOfSelectedExecute

procedure TN_RAEditForm.aEdPasteInsideSelectedExecute( Sender: TObject );
// Paste Clipboard Content Inside of Selected Fields
// if Number of Recods with Sected Fields is less then Number of records in
//   Cilpboard, additional Records are skiped
// Number of Records before and after Action is always the same
begin
  K_RAFClipBoard.Flags := [K_sdmReplaceSelectedRowsOnly,K_sdmFixSelectedRowsNumber];
  RAEditFrame.PasteFromClipBoardExecute( Sender );
end; // procedure TN_RAEditForm.aEdPasteInsideSelectedExecute

procedure TN_RAEditForm.aEdPasteAndFillAllSelectedExecute( Sender: TObject );
// Substitute Content of All Selected Fields by Clipboard Content
// Repeat Clipboard Content if needed
begin
  K_RAFClipBoard.Flags := [K_sdmReplaceSelectedRowsOnly,K_sdmFillSelectedRows];
  RAEditFrame.PasteFromClipBoardExecute( Sender );
end; // procedure TN_RAEditForm.aEdPasteAndFillAllSelectedExecute

procedure TN_RAEditForm.aEdClearSelectedExecute( Sender: TObject );
// Clear Content of Selected Fields by default values (usually by zeros)
begin
  RAEditFrame.ClearSelectedExecute( Sender );
end; // procedure TN_RAEditForm.aEdClearSelectedExecute

procedure TN_RAEditForm.aEdCreateNewRecordsExecute( Sender: TObject );
// Add one New Record or, if Shift pressed, Ask about number of new records,
// Create and Insert them before Selected Fields or
// Add them as last records if Records Header is selected
var
  BegInd, NumInds : Integer;
  NumIndsStr: string;
begin
  if N_KeyIsDown( VK_Shift ) then // Insert New Records
  begin
    RAEditFrame.GetSelectSection( True, BegInd, NumInds ); // Only BegInd is used
    NumIndsStr := '1';
    if N_EditString( NumIndsStr, 'Enter number of New Records:' ) then
    begin
      NumInds := N_ScanInteger( NumIndsStr );
      RAEditFrame.FrInsertRows( BegInd, NumInds ); // BegInd = 0 means adding records
    end;
  end else //*********************** Add one New (last) Record
    RAEditFrame.FrInsertRows( 0, 1 );

end; // procedure TN_RAEditForm.aEdCreateNewRecordsExecute

procedure TN_RAEditForm.aEdDestroySelectedRecordsExecute( Sender: TObject );
// Destroy All Records that contain Selected Fields
var
  BegInd, NumInds, ShowInd : Integer;
begin
  // BegInd=0 means FieldNames column; BegInd=1 - zero Array element
  RAEditFrame.GetSelectSection( True, BegInd, NumInds );

  if NumInds = -1 then // No Selection
  begin
    ShowString( 'No Selected Records!' );
    Exit;
  end;
  ShowInd := Max( 0, BegInd-1 );
  if N_MessageDlg( Format( 'Are You sure to Destroy records from %d to %d? ',
                           [ShowInd, BegInd+NumInds-2] ),
                           mtConfirmation, mbOKCancel, 0 ) = mrOK then
    RAEditFrame.FrDeleteRows( BegInd, NumInds );
end; // procedure TN_RAEditForm.aEdDestroySelectedRecordsExecute

procedure TN_RAEditForm.aEdCreateSetParamsExecute( Sender: TObject );
// Create Static SetParams
begin
  TN_PRCompBase(RecordUObj.R.P())^.CSetParams :=
                                 K_RCreateByTypeName( 'TN_OneSetParam', 1 );
  aCompSetParams.Visible := True;
  aEdCreateSetParams.Visible := False;
  aCompSetParamsExecute( nil );
end; // procedure TN_RAEditForm.aEdCreateSetParamsExecute

procedure TN_RAEditForm.aEdCreateUserParamsExecute( Sender: TObject );
// Create Static User Params
begin
  TN_PRCompBase(RecordUObj.R.P())^.CCompBase.CBUserParams :=
                                 K_RCreateByTypeName( 'TN_OneUserParam', 1 );
  aCompUserParams.Visible  := True;
  aEdCreateUserParams.Visible := False;
  aCompUserParamsExecute( nil );
end; // procedure TN_RAEditForm.aEdCreateUserParamsExecute

procedure TN_RAEditForm.aEdCreatePanelParamsExecute( Sender: TObject );
// Create Static Panel Params
begin
  if not (RecordUObj is TN_UDCompVis) then
  begin
    ShowString( 'Is not Visual Component!' );
    Exit;
  end;

  TN_UDCompVis(RecordUObj).PCPanelS(); // Create Static CPanel RArray
  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaApplyToAll ); // Redraw if needed

  aCompPanelParams.Visible  := True;
  aEdCreatePanelParams.Visible := False;
  aCompPanelParamsExecute( nil );
end; // procedure TN_RAEditForm.aEdCreatePanelParamsExecute

procedure TN_RAEditForm.aEdCreateExportParamsExecute( Sender: TObject );
// Create Static Export Params
begin
  N_CreateExpParams( TN_UDCompBase(RecordUObj) );

  aCompExportParams.Visible := True;
  aEdCreateExportParams.Visible := False;
  aCompExportParamsExecute( nil );
end; // procedure TN_RAEditForm.aEdCreateExportParamsExecute


    //****************** Array Edit Actions *******************************

procedure TN_RAEditForm.aAESetRArraySizeExecute( Sender: TObject );
// Set New Size for RArray in current field or Root RArray
var
  SizeStr: string;
  OldSize, NewSize: integer;
begin
  GetCurFieldInfo();

  if PCurRArrayField = nil then // current field is not an RArray, check Root Record Type
  begin
    if not N_IsRArray( RecordTypeName ) then Exit; // Root Record is also not RArray

    //***** Here: Change size of Root RArray

    OldSize := RAEditFrame.GetDataBufRow();
    SizeStr := IntToStr( OldSize );

    if N_EditString( SizeStr, 'Enter New RArray Size :', 250 ) then // New Size was Entered
    begin
      NewSize := N_ScanInteger( SizeStr );
      if (NewSize = N_NotAnInteger) or (NewSize <= 0) then Exit;

      if NewSize > OldSize then
        RAEditFrame.FrInsertRows( 0, NewSize - OldSize )
      else if NewSize < OldSize then
        RAEditFrame.FrDeleteRows( NewSize+1, OldSize-NewSize );

      ShowString( 'RArray Size Set To ' + IntToStr( NewSize ) );
    end; // if N_EditString( SizeStr, 'Enter New RArray Size :', 250 ) then // New Size was Entered

{ // old var
    PRArray := @FRRAControl.BufData; // at first, PRArray is Pointer to Bufer RArray

    if PRArray^ = nil then // current field is RArray but = nil
      SizeStr := '-1'
    else
      SizeStr := IntToStr( PRArray^.ALength() );

    if N_EditString( SizeStr, 'Enter New RArray Size :', 250 ) then // New Size was Entered
    begin
      NewSize := N_ScanInteger( SizeStr );
      if (NewSize = N_NotAnInteger) or (NewSize <= 0) then Exit;

      if PRArray^ <> nil then // there may be something to save
      begin
        if PRArray^.ALength() >= 1 then
          FRRAControl.StoreToSData; // Apply all changes, if any
      end;

      PRArray := TK_PRArray(PRecord); // now, PRArray is Pointer to Source RArray

      if PRArray^ = nil then // RArray was not created yet
      begin
        if RecordTypeCode.DTCode = Ord(nptNotDef) then Exit; // arrayOf Undef cannot be created
        PRArray^ := K_RCreateByTypeCode( RecordTypeCode.All, NewSize );
        PRArray^.InitElems( 0, NewSize );
      end else // PRArray^ exists
        PRArray^.ASetLengthI( NewSize );

      FRRAControl.SetNewData( PRArray^ ); // update RAFrame by PRArray^ with changed size
      ShowString( 'RArray Size Set To ' + IntToStr( NewSize ) );
    end; // if N_EditString( SizeStr, 'Enter New RArray Size :', 250 ) then // New Size was Entered
}
    Exit; // all done
  end; // if PCurRArrayField = nil then // current field is not an RArray, check Root Record Type

  //***** Here: Current field is RArray, Change it's size

  if PCurRArrayField^ = nil then // current field is RArray but = nil
    SizeStr := '-1'
  else
    SizeStr := IntToStr( PCurRArrayField^.ALength() );

  if N_EditString( SizeStr, 'Enter RArray Size :', 250 ) then // New Size was Entered
  begin
    NewSize := N_ScanInteger( SizeStr );
    if NewSize = N_NotAnInteger then Exit;

    if PCurRArrayField^ = nil then // RArray was not created yet
    begin
      if CurFieldTypeCode.DTCode = Ord(nptNotDef) then Exit; // arrayOf Undef cannot be created
      PCurRArrayField^ := K_RCreateByTypeCode( CurFieldTypeCode.All, 0 );
    end;

    PCurRArrayField^.ASetLengthI( NewSize );

    RAEditFrame.SGrid.Invalidate();
    ShowString( 'RArray Size Set To ' + IntToStr( NewSize ) );
  end;
end; // procedure TN_RAEditForm.aAESetRArraySizeExecute

procedure TN_RAEditForm.aAESet2DRArraySizeExecute( Sender: TObject );
// Set 2D RArray Dimensions for Current or Root RArray
var
  SizeStr: string;
  OldSizeX, OldSizeY, NewSizeX, NewSizeY: integer;
begin
  GetCurFieldInfo();

  if PCurRArrayField = nil then // current field is not an RArray, check Root Record Type
  begin
    if not N_IsRArray( RecordTypeName ) then Exit; // Root Record is also not RArray

    //***** Here: Change size of Root RArray

    OldSizeX := RAEditFrame.GetDataBufCol();
    OldSizeY := RAEditFrame.GetDataBufRow();
    SizeStr := Format( '%d %d', [OldSizeX, OldSizeY] );

    if N_EditString( SizeStr, 'Enter 2D RArray NX NY :', 300 ) then // New Size was Entered
    begin
      NewSizeX := N_ScanInteger( SizeStr );
      if (NewSizeX = N_NotAnInteger) or (NewSizeX <= 0) then Exit;

      if NewSizeX > OldSizeX then
        RAEditFrame.FrInsertCols( 0, NewSizeX - OldSizeX )
      else if NewSizeX < OldSizeX then
        RAEditFrame.FrDeleteCols( NewSizeX+1, OldSizeX-NewSizeX );

      NewSizeY := N_ScanInteger( SizeStr );
      if (NewSizeY = N_NotAnInteger) or (NewSizeY <= 0) then Exit;

      if NewSizeY > OldSizeY then
        RAEditFrame.FrInsertRows( 0, NewSizeY - OldSizeY )
      else if NewSizeY < OldSizeY then
        RAEditFrame.FrDeleteRows( NewSizeY+1, OldSizeY-NewSizeY );

      ShowString( Format( '2D RArray NX NY Set To  %d %d ', [NewSizeX, NewSizeY] ) );
    end;

    Exit;
  end; // if PCurRArrayField = nil then // current field is not an RArray, check Root Record Type

  //***** Here: Current field is RArray, Change it's size

  if PCurRArrayField^ = nil then // current field is RArray but = nil
    SizeStr := '-1 -1'
  else
  begin
//    NewSizeX := PCurRArrayField^.HCol + 1;
//    NewSizeY := PCurRArrayField^.ALength() div NewSizeX;
    PCurRArrayField^.ALength( NewSizeX, NewSizeY );
    SizeStr := Format( '%d %d', [NewSizeX, NewSizeY] );
  end;

  if N_EditString( SizeStr, 'Enter 2D RArray NX NY :', 300 ) then // New Size was Entered
  begin

    NewSizeX := N_ScanInteger( SizeStr );
    if (NewSizeX = N_NotAnInteger) or (NewSizeX <= 0) then Exit;
    NewSizeY := N_ScanInteger( SizeStr );
    if (NewSizeY = N_NotAnInteger) or (NewSizeY <= 0) then Exit;

    if PCurRArrayField^ = nil then // RArray was not created yet
    begin
      if CurFieldTypeCode.DTCode = Ord(nptNotDef) then Exit; // arrayOf Undef cannot be created
      PCurRArrayField^ := K_RCreateByTypeCode( CurFieldTypeCode.All, 0 );
      PCurRArrayField^.ASetLength( NewSizeX, NewSizeY, True );
    end else
      PCurRArrayField^.ASetLength( NewSizeX, NewSizeY );

    RAEditFrame.SGrid.Invalidate();
    ShowString( Format( '2D RArray NX NY Set To  %d %d ', [NewSizeX, NewSizeY] ) );

  end; // if N_EditString( SizeStr, 'Enter 2D RArray NX NY :', 300 ) then // New Size was Entered

end; // procedure TN_RAEditForm.aAESetRArray2DDimsExecute

procedure TN_RAEditForm.aAESetRArraysSizesExecute( Sender: TObject );
// Set New Size for all child RArrays of current RArray
// Not implemented!
var
  SizeStr: string;
  NewSize: integer;
  label NotAnRArray;
begin
  GetCurFieldInfo();

  if PCurRArrayField = nil then goto NotAnRArray;

  //***** Here: Current field is RArray, Change it's size

  if PCurRArrayField^ = nil then // current field is RArray but = nil
    SizeStr := '-1'
  else
    SizeStr := IntToStr( PCurRArrayField^.ALength() );

  if N_EditString( SizeStr, 'Enter RArray Size :', 250 ) then // New Size was Entered
  begin
    NewSize := N_ScanInteger( SizeStr );
    if NewSize = N_NotAnInteger then Exit;

    if PCurRArrayField^ = nil then // RArray was not created yet
    begin
      if CurFieldTypeCode.DTCode = Ord(nptNotDef) then Exit; // arrayOf Undef cannot be created
      PCurRArrayField^ := K_RCreateByTypeCode( CurFieldTypeCode.All, NewSize );
      PCurRArrayField^.InitElems( 0, NewSize );
    end else
      PCurRArrayField^.ASetLengthI( NewSize );

//    FRRAControl.StoreToSData; // Change source record ??
    RAEditFrame.SGrid.Invalidate();
    ShowString( 'RArray Size Set To ' + IntToStr( NewSize ) );
  end;
  Exit;

  NotAnRArray: //*****************
  ShowString( 'Is not An RArray of RArrays!');
end; // procedure TN_RAEditForm.aAESetRArraysSizesExecute

procedure TN_RAEditForm.aAEFillRArrayExecute( Sender: TObject );
// Fill Current or Root RArray (of Numbers, Colors or Strings) by Test Data
// using N_FillNumRArray, N_FillColRArray or N_FillStrRArray procedures
// (RArray size always remains the same, use aEditSetRArraySize if needed)
//
var
  TypeClass, EditResult, CurLength: integer;
  RArrayToFill: TK_RArray;
  Label PrepareParams, CancelFilling, FilledOk, NothingToFill;

  function GetTypeNameClass( ATypeName : string ): integer; // local
  // Return: 1 for Array of Numbers, 2 - of Colors, 3 - of Strings
  begin
    if (ATypeName = 'arrayof Bool1')   or (ATypeName = 'arrayof Byte') or
       (ATypeName = 'arrayof Integer') or (ATypeName = 'arrayof Float') or
       (ATypeName = 'arrayof Double') then
      Result := 1  // Array of Numbers
    else if ATypeName = 'arrayof Color' then
      Result := 2  // Array of Colors
    else if ATypeName = 'arrayof String' then
      Result := 3  // Array of String
    else if ATypeName = 'arrayof TN_UDBase' then
      Result := -1  // Array of TN_UDBase
    else
      Result := -1; // some other type
  end; // function GetTypeNameClass // local

begin //************************ body of TN_RAEditForm.aEditFillRArrayExecute
  GetCurFieldInfo();
  TypeClass := GetTypeNameClass( CurFieldTypeName );

  if TypeClass >= 1 then // Current field is RArray of proper type, fill it
  begin
    if PCurRArrayField^ = nil then goto NothingToFill;
    RArrayToFill := PCurRArrayField^;
    goto PrepareParams;
  end; // if TypeClass >= 1 then // Current field is RArray of proper type, fill it

  //***** Check Root Record type

  TypeClass := GetTypeNameClass( RecordTypeName );
  if TypeClass >= 1 then // Root record is RArray of proper type, fill it
  begin
    RArrayToFill := FRRAControl.BufData;
    goto PrepareParams;
  end; // if TypeClass >= 1 then // Root record is RArray of proper type, fill it

  NothingToFill :
  ShowString( 'Nothing to fill!' );
  Exit; // nothing to fill

  PrepareParams: //********************************
  CurLength := RArrayToFill.ALength();

  with N_MEGlobObj do
  begin

  if TypeClass = 1 then //************** Prepare Params for filling Numbers
  with RAFillNumParams do
  begin
    if FNRBegIndex < 0 then FNRBegIndex := 0;
    if FNRBegIndex >= CurLength then FNRBegIndex := CurLength - 1;
    FNRNumValues := CurLength - FNRBegIndex;

    EditResult := N_GetRAEditForm( [], nil, RAFillNumParams, 'TN_RAFillNumParams',
                                    'TN_RAFillNumParamsFormDescr' ).ShowModal();
    if EditResult <> mrOK then
      goto CancelFilling;

    if FNRBegIndex < 0 then FNRBegIndex := 0; // check again after user input
    if FNRBegIndex >= CurLength then FNRBegIndex := CurLength - 1;

    if (FNRNumValues+FNRBegIndex) > CurLength then // preserve current Length
      FNRNumValues := CurLength - FNRBegIndex;

    N_FillNumRArray( RArrayToFill, @RAFillNumParams );

    goto FilledOk;
  end; // if TypeClass = 1 then // Prepare Params for filling Numbers

  if TypeClass = 2 then //************* Prepare Params for filling Colors
  with RAFillColParams do
  begin
    if FCRBegIndex < 0 then FCRBegIndex := 0;
    if FCRBegIndex >= CurLength then FCRBegIndex := CurLength - 1;
    FCRNumValues := CurLength - FCRBegIndex;

    EditResult := N_GetRAEditForm( [], nil, RAFillColParams, 'TN_RAFillColParams',
                                    'TN_RAFillColParamsFormDescr' ).ShowModal();
    if EditResult <> mrOK then
      goto CancelFilling;

    if FCRBegIndex < 0 then FCRBegIndex := 0; // check again after user input
    if FCRBegIndex >= CurLength then FCRBegIndex := CurLength - 1;

    if (FCRNumValues+FCRBegIndex) > CurLength then // preserve current Length
      FCRNumValues := CurLength - FCRBegIndex;

    N_FillColRArray( RArrayToFill, @RAFillColParams );

    goto FilledOk;
  end; // if TypeClass = 2 then // Prepare Params for filling Colors

  if TypeClass = 3 then //************* Prepare Params for filling Strings
  with RAFillStrParams do
  begin
    if FSRBegIndex < 0 then FSRBegIndex := 0;
    if FSRBegIndex >= CurLength then FSRBegIndex := CurLength - 1;
    FSRNumStrings := CurLength - FSRBegIndex;

    EditResult := N_GetRAEditForm( [], nil, RAFillStrParams, 'TN_RAFillStrParams',
                                    'TN_RAFillStrParamsFormDescr' ).ShowModal();
    if EditResult <> mrOK then
      goto CancelFilling;

    if FSRBegIndex < 0 then FSRBegIndex := 0; // check again after user input
    if FSRBegIndex >= CurLength then FSRBegIndex := CurLength - 1;

    if (FSRNumStrings+FSRBegIndex) > CurLength then // preserve current Length
      FSRNumStrings := CurLength - FSRBegIndex;

    N_FillStrRArray( RArrayToFill, @RAFillStrParams );

    goto FilledOk;
  end; // if TypeClass = 3 then //******** Prepare Params for filling Strings

  if TypeClass = 4 then //***** Set needed Length and fill array by marked UDObjects
  begin


    goto FilledOk;
  end; // if TypeClass = 3 then //******** Prepare Params for filling Strings

  end; // with N_MEGlobObj do

  CancelFilling: //**********************************
  ShowString( '' );
  Exit;

  FilledOk: //***************************************
  FRRAControl.StoreToSData; // Change source record
  RAEditFrame.SGrid.Invalidate();
  ShowString( 'RArray Filled OK' );
end; // procedure TN_RAEditForm.aAEFillRArrayExecute

procedure TN_RAEditForm.aAEFill2DRArrayExecute( Sender: TObject );
// Fill Current or Root 2D RArray (of Numbers or Strings) by Test Data
// RArray size always remains the same (use aEditSet2DRArraySize if needed)
var
  EditResult: integer;
  RArrayToFill: TK_RArray;
  Label CancelFilling, FilledOk, NothingToFill;

begin //************************ body of TN_RAEditForm.aEditFillRArrayExecute
  GetCurFieldInfo();

  if PCurRArrayField = nil then // current field is not an RArray, check Root Record Type
  begin
    if not N_IsRArray( RecordTypeName ) then goto NothingToFill; // Root Record is also not RArray

    RArrayToFill := FRRAControl.BufData;
  end else // PCurRArrayField <> nil
    RArrayToFill := PCurRArrayField^;

  with N_MEGlobObj, RAFill2DNumParams do
  begin
    EditResult := N_GetRAEditForm( [], nil, RAFill2DNumParams, 'TN_2DRAFillNumParams',
                                    'TN_2DRAFillNumParamsFormDescr' ).ShowModal();
    if EditResult <> mrOK then
      goto CancelFilling;

    N_Fill2DRArray( RArrayToFill, @RAFill2DNumParams );

    goto FilledOk;
  end; // with N_MEGlobObj, RAFill2DNumParams do

  CancelFilling: //**********************************
  ShowString( '' );
  Exit;

  FilledOk: //***************************************
  FRRAControl.StoreToSData; // Change source record
  RAEditFrame.SGrid.Invalidate();
  ShowString( '2D RArray Changed OK' );
  Exit;

  NothingToFill : //*********************************
  ShowString( 'Nothing to fill!' );
end; // procedure TN_RAEditForm.aAEFill2DRArrayExecute

procedure TN_RAEditForm.aAEEditAs1DRArrayExecute( Sender: TObject );
// Edit Root RArray as 1D RArray
begin
  aAEEditAs1DRArray.Visible := False;
  aAEEditAs2DRArray.Visible := True;
  RAEditFrame.Constraints.MinWidth := 230;

  FRRAControl.FreeContext();
  RAModeFlags := RAModeFlags - [K_ramShowLColNumbers,K_ramColChangeOrder,
                                K_ramColChangeNum,K_ramColAutoChangeNum,K_ramSkipResizeWidth];
//      K_ramColChangeNum,K_ramColAutoChangeNum,K_ramSkipResizeWidth]; //???  K_ramRowChangeOrder

  FRRAControl.PrepFrame1( [], RAModeFlags, PRecord^, RecordTypeCode, '' );
end; // procedure TN_RAEditForm.aAEEditAs1DRArrayExecute

procedure TN_RAEditForm.aAEEditAs2DRArrayExecute( Sender: TObject );
// Edit Root RArray as 2D RArray
begin
  aAEEditAs1DRArray.Visible := True;
  aAEEditAs2DRArray.Visible := False;
  RAEditFrame.Constraints.MinWidth := 300;

  FRRAControl.FreeContext();
  RAModeFlags := RAModeFlags + [K_ramShowLColNumbers,K_ramColChangeOrder,
                                K_ramColChangeNum,K_ramColAutoChangeNum,K_ramSkipResizeWidth];

  FRRAControl.PrepMatrixFrame1( [], RAModeFlags, TK_PRArray(PRecord)^, RecordTypeCode, '' );
end; // procedure TN_RAEditForm.aAEEditAs2DRArrayExecute


    //****************** Special Edit Actions *****************************

procedure TN_RAEditForm.aSECopyFullFieldNameExecute( Sender: TObject );
// Copy to Clipboard FullName of current field (may be used in SetParams)
begin
  GetCurFieldInfo();
  Clipboard.AsText := CurFieldFullName;
end; // procedure TN_RAEditForm.aSECopyFullFieldNameExecute

procedure TN_RAEditForm.aSESetCSAndCSCodeExecute( Sender: TObject );
// Set CodeSpace or CS Code(s) in current field(s) by Selected Items in TK_FormDCSpace
var
  i, CSFirstInd, CSNumInds, SelfFirstInd, SelfNumInds, NewSize: integer;
  CSUObj: TN_UDBase;
  UDCSpace: TK_UDDCSpace;
  GR: TGridRect;
  ResRArray: TK_RArray;
  PSrc: TK_PRarray;
begin
  // Get Info from TK_FormDCSpace: CSUObj, CSFirstInd, CSNumInds

  K_GetDCSpaceSelection( CSUObj, CSFirstInd, CSNumInds );
  UDCSpace := TK_UDDCSpace(CSUObj);

  if CSUObj = nil then // TK_FormDCSpace is not opened yet, Show it
  begin
    K_ShowDCSpace();
    ShowString( 'Choose CS Item' );
    Exit;
  end;


  if CSNumInds = 0 then
  begin
    ShowString( 'CS Item(s) not Selected!' );
    Exit;
  end;

  ShowString( Format( 'Res(%s): %d, %d', [CSUObj.ObjAliase, CSFirstInd, CSNumInds] ) ); // debug

  // Get info from Self RAEditFrame: SelfFirstInd, SelfNumInds

  GR := RAEditFrame.SGrid.Selection;
  GR.Top := Max( GR.Top, 1 );
  SelfFirstInd := GR.Top - 1;
  SelfNumInds := Max( GR.Bottom, 1 ) - GR.Top + 1;

  GetCurFieldInfo();
  if PCurFieldDescr = nil then
  begin
    ShowString( 'No Selected Items!' );
    Exit;
  end;

  with PCurFieldDescr^ do
  if (CurFieldTypeName = 'TN_UDBase') and
     (VEArray[CVEInd].EParams = 'CSUObj') then // set one CodeSpace UObj (CSNumInds is not used)
  begin
    TN_PUDBase(PCurFieldInBuf)^ := CSUObj;
    RAEditFrame.Sgrid.Invalidate();
  end else if (CurFieldTypeName = 'String') and
              (VEArray[CVEInd].EParams = 'CSCode') then // set one CS Item Code (CSNumInds is not used)
  begin
    UDCSpace.GetItemsInfo( PString(PCurFieldInBuf), K_csiCSCode, CSFirstInd );
    RAEditFrame.Sgrid.Invalidate();
  end else if (CurFieldName = 'UPValue') and
              (CurFieldTypeName = 'arrayof TN_CodeSpaceItem') and
              (PCurRArrayField^.ALength() = 1) then // set one CS Item Code in UserParam (of TN_CodeSpaceItem type)
  begin
    with TN_PCodeSpaceItem(PCurRArrayField^.P)^ do
    begin
      ItemCS := UDCSpace;
      UDCSpace.GetItemsInfo( @ItemCode, K_csiCSCode, CSFirstInd );
    end;
    RAEditFrame.Sgrid.Invalidate();
  end else if (CurFieldTypeName = 'TN_CodeSpaceItem') then // set both: CS and Code
  begin
    if (SelfNumInds = 1) and (CSNumInds = 1) then // set one CS Item
    begin
      with TN_PCodeSpaceItem(PCurFieldInBuf)^ do
      begin
        ItemCS := UDCSpace;
        UDCSpace.GetItemsInfo( @ItemCode, K_csiCSCode, CSFirstInd );
      end;
      RAEditFrame.Sgrid.Invalidate();
    end else // substitute all selected Self CS Items by all selected in TK_FormDCSpace
    begin
      if not (RecordTypeName = 'arrayof TN_CodeSpaceItem') then
      begin
        ShowString( 'Not an arrayof TN_CodeSpaceItem!' );
        Exit;
      end;

      PSrc := TK_PRarray(PRecord); // Pointer to Source RArray
      FRRAControl.StoreToSData(); // Update Source RArray by it's current state in RAEditFrame

      NewSize := PSrc^.ALength + CSNumInds - SelfNumInds;
      ResRArray := K_RCreateByTypeName( 'TN_CodeSpaceItem', NewSize, [] ); // not count UDRef!

      for i := 0 to SelfFirstInd-1 do // copy to ResRArray all Items before Items selected in Self
        TN_PCodeSpaceItem(ResRArray.P(i))^ := TN_PCodeSpaceItem(PSrc^.P(i))^;

      for i := SelfFirstInd to SelfFirstInd+CSNumInds-1 do // add all Items selected in TK_FormDCSpace
      with TN_PCodeSpaceItem(ResRArray.P(i))^ do
      begin
        ItemCS := UDCSpace;
        UDCSpace.GetItemsInfo( @ItemCode, K_csiCSCode, CSFirstInd+i-SelfFirstInd );
      end;

      for i := SelfFirstInd+CSNumInds to NewSize-1 do // copy all Items after Items selected in Self
        TN_PCodeSpaceItem(ResRArray.P(i))^ := TN_PCodeSpaceItem(PSrc^.P(i+SelfNumInds-CSNumInds))^;

      PSrc^.ARelease();
      PSrc^ := ResRArray; // substitute Source RArray by new one
      FRRAControl.SetNewData( PSrc^ ); // update RAFrame by new Source RArray
      RAEditFrame.SelectRect( 1, SelfFirstInd+1, 1, SelfFirstInd+CSNumInds ); // set new Selection
    end;
  end; // else if (CurFieldTypeName = 'TN_CodeSpaceItem') then // set both: CS and Code

end; // procedure TN_RAEditForm.aSESetCSAndCSCodeExecute

procedure TN_RAEditForm.aSESetUObjExecute( Sender: TObject );
// Set UObject in current field by  Selected UObj in N_ActiveVTreeFrame
var
  ASelected: TN_VNode;
begin
  GetCurFieldInfo();
  if CurFieldTypeName <> 'TN_UDBase' then
  begin
    ShowString( 'Current field is not UObject!' );
    Exit;
  end;

  if N_ActiveVTreeFrame = nil then
  begin
    ShowString( 'UObjects Tree Form is not Opened!' );
    Exit;
  end;

  ASelected := N_ActiveVTreeFrame.VTree.Selected;
  if ASelected = nil then
  begin
    ShowString( 'UObject is not Selected!' );
    Exit;
  end;

  TN_PUDBase(PCurFieldInBuf)^ := ASelected.VNUDObj;

  RAEditFrame.Sgrid.Invalidate();
  ShowString( 'Current UObject Set OK!' );
end; // procedure TN_RAEditForm.aSESetUObjExecute

procedure TN_RAEditForm.aSEImportUDTableExecute( Sender: TObject );
// Import UDTable From Excel or Word (Word is not implemented)
var
  NRows, NCols: integer; // ix, iy,
  Str: string;
  OLEServer, SRange: Variant;
  UDTable: TN_UDTable;
begin
  ShowString( '' );
  try
    OLEServer := GetActiveOleObject( 'Excel.Application' );
  except
    ShowString( 'Excel not found!' );
    Exit;
  end;

  SRange := OLEServer.Selection; // Selected Range

  if VarIsEmpty(SRange) then
  begin
    ShowString( 'No Selection!' );
    Exit;
  end;


  NCols := SRange.Columns.Count;
  NRows := SRange.Rows.Count;
  Str := Format( 'Cols=%d, Rows=%d', [NCols,NRows] );

  if not (RecordUObj is TN_UDTable) then Exit; // a precaution

  UDTable := TN_UDTable(RecordUObj); // to reduce code
  with UDTable, UDTable.PISP()^ do
  begin
    bnApplyClick( nil );
    SetTableSize( cptStatic, NCols, NRows );
    FRRAControl.SetNewData( PRecord^ );
    RAEditFrame.RebuildGridInfo();
  end; // with UDTable, UDTable.PISP()^ do


  OLEServer := UnAssigned();
  ShowString( Str );
//  ShowString( 'Imported OK!' );
end; // procedure TN_RAEditForm.aSEImportUDTableExecute

procedure TN_RAEditForm.aSEExportUDTableExecute( Sender: TObject );
// Export UDTable To Excel or Word (Word is not implemented)
begin
//
end; // procedure TN_RAEditForm.aSEExportUDTableExecute


    //****************** Individual Edit Actions ****************************

procedure TN_RAEditForm.aIESetTableSizeExecute( Sender: TObject );
// Set Table Dimensions for Table Component
var
  NumCols, NumRows: integer;
  Str: string;
  UDTable: TN_UDTable;
begin
  if not (RecordUObj is TN_UDTable) then Exit; // a precaution

  FRRAControl.StoreToSData();

  bnApplyClick( nil );

  UDTable := TN_UDTable(RecordUObj);
  with UDTable, UDTable.PISP()^ do
  begin
    NumCols := TaCols.ALength();
    NumRows := TaRows.ALength();
    Str := Format( ' %d %d', [NumCols, NumRows] );

    if N_EditString( Str, 'Enter NumColumns NumRows: ' ) then
    begin
      NumCols := N_ScanInteger( Str );
      NumRows := N_ScanInteger( Str );
      SetTableSize(  cptStatic, NumCols, NumRows );
      DebCellsInit(); // debug
      FRRAControl.SetNewData( PRecord^ );
      RAEditFrame.RebuildGridInfo();
    end; // if N_EditString( Str, 'Enter Number of Table Columns and Rows: ' ) then

  end; // with UDTable, UDTable.PIDP()^ do

  bnApplyClick( nil );
end; // procedure TN_RAEditForm.aIESetTableSizeExecute

procedure TN_RAEditForm.aIEView2DRArrayExecute( Sender: TObject );
// View current Field as 2D RArray
begin
  GetCurFieldInfo();
  // not implemented
end; // procedure TN_RAEditForm.aIEView2DRArrayExecute


    //****************** View Actions ********************************

procedure TN_RAEditForm.aViewFieldInfoExecute( Sender: TObject );
// View Info about current RAFrame Field (mainly for debug)
var
  Str: string;
  SL: TStrings;
begin
  N_GetTextEditorForm( Self, SL );

  if RecordUObj = nil then Str := 'Not defined'
                      else Str := RecordUObj.ObjName;

  SL.Add( 'RecordUObj Name  : ' + Str );
  SL.Add( 'RecordType Name  : ' + RecordTypeName );
  SL.Add( 'Prev Field Name  : ' + RAEditFrame.DataPath );

  if N_IsRArray( RecordTypeName ) then
    SL.Add( Format( 'Number of Root elems: %d',
                                          [FRRAControl.BufData.ALength()] ) );
  SL.Add( '' );

  with RAEditFrame do
    SL.Add( Format( 'CurLCol, CurLRow   : %d, %d', [CurLCol, CurLRow] ) );

  GetCurFieldInfo();

  if CurFieldTypeName <> '' then // Cur field exists
  begin
    SL.Add( 'CurField      Name : ' + CurFieldName );

    Str :=  'CurField Type Name : ' + CurFieldTypeName;
    if CurFieldTypeIsDynamic then Str := Str + ' (Dynamic)';
    SL.Add( Str );

    SL.Add( 'CurField Full Name : ' + CurFieldFullName );

    if PCurRArrayField <> nil then // Cur Field is RArray or VArray
    begin
      N_AddRArrayInfo( PCurRArrayField^, SL );
    end;

    if CurFieldUObj <> nil then // Cur Field UObj exist (TN_UDBase or VArray)
    begin
//      SL.Add( 'CurField UObj Path : ' + CurFieldUObj.GetRefPath() );
      SL.Add( 'CurField UObj Path : ' + K_GetPathToUObj( CurFieldUObj ) );
    end;

  end; // if CurFieldTypeName <> '' then // Cur field exists

  SL.Add( '' );

  if PCurFieldDescr <> nil then
  begin
//    N_i2 := Sizeof(TK_RAColumnFlagSet); // debug = 4!
//    Str := 'Not yet ...';
    N_ET := K_GetTypeCodeSafe( 'TK_RAFColumn' );
    Str := K_SPLValueToString( PCurFieldDescr^,
                        K_GetTypeCodeSafe( 'TK_RAFColumn' ), [K_svsShowName] );
    SL.Add( Str );
    SL.Add( '' );
  end;

  with TN_PlainEditorForm(N_MEGlobObj.TextEdForm) do
  begin
    actButtonsExecute( nil );
    actWordWrap.Checked := True;
    actWordWrapExecute( nil );
    Buttons1.Checked := False;
    Memo.ReadOnly := True;
  end;

end; // procedure TN_RAEditForm.aViewFieldInfoExecute

procedure TN_RAEditForm.aViewEditObjInfoExecute( Sender: TObject );
// Show/Edit RecordUObj Info
var
  InfoStr: string;
begin
  if RecordUObj = nil then Exit;
  InfoStr := RecordUObj.ObjInfo;

  if not N_EditString( InfoStr, 'Edit Obj Info :' ) then Exit;
  RecordUObj.ObjInfo := InfoStr;
  ShowString( 'Obj Info set OK' );
end; // procedure TN_RAEditForm.aViewEditObjInfoExecute

procedure TN_RAEditForm.aViewObjHelpExecute( Sender: TObject );
// View Help about RecordUObj
var
  FileName, TopicName: string;
begin
  N_GetUDBaseHelpTopic( RecordUObj, FileName, TopicName );

  if FileName <> '' then
    N_ShowHelp( FileName, TopicName, Self )
  else
    ShowString( 'Help File Not Found!' );
end; // procedure TN_RAEditForm.aViewObjHelpExecute


    //****************** Other Actions *******************************

    //****************** Debug Actions ********************************

procedure TN_RAEditForm.aDebToggleStatDynExecute( Sender: TObject );
// Toggle boolean variable StaticParams
// and set CurRArray to Static or Dynamic Params
// is used also in Form initialization

  procedure SetStatic(); // local (it is called twice)
  begin
    CurRArray := RecordUObj.R;
    aDebToggleStatDyn.ImageIndex := 57;
    aDebToggleStatDyn.Caption := 'View Dynamic Params';
    StatOrDynStr := 'Static Params';
  end; // procedure SetStatic(); // local (it is called twice)

begin
  StaticParams := not StaticParams; // Toggle boolean StaticParams

  if StaticParams then // current Params are Static
  begin
    SetStatic();
  end else //************ current Params are Dynamic
  begin
    CurRArray := TN_UDCOmpBase(RecordUObj).DynPar;
    if CurRArray <> nil then // Dyn Params exists
    begin
      aDebToggleStatDyn.ImageIndex := 58;
      aDebToggleStatDyn.Caption := 'View/Edit Static Params';
      StatOrDynStr := 'Dynamic Params';
    end else // DynParams were not created yet, return to Static Params
    begin
      StaticParams := True;
      SetStatic();
      StatOrDynStr := 'Only Static Params';
    end;
  end;

  SetFrameByStructType(); // rebuild Frame by new CurRArray
end; // procedure TN_RAEditForm.aDebToggleStatDynExecute

procedure TN_RAEditForm.aDebEditCompSPLTextExecute( Sender: TObject );
// View Component SPL Text
var
  SL: TStrings;
  CompSPLUnit: TK_UDUnit;
  PEdForm: TN_PBaseForm;
  Label Fail;
begin
  if not (RecordUObj is TN_UDCompBase) then goto Fail;
  N_MEGlobObj.PSPLUnitToUpdate := @TN_UDCompBase(RecordUObj).SPLUnit;
  CompSPLUnit := N_MEGlobObj.PSPLUnitToUpdate^;
  if CompSPLUnit = nil then goto Fail;

  PEdForm := @N_MEGlobObj.TextEdForm;
  N_GetTextEditorForm( PEdForm, Self, SL );
  SL.Text := CompSPLUnit.SL.Text;

  with TN_PlainEditorForm(PEdForm^) do
    ApplyProcObj := N_MEGlobObj.UpdateSPLUnit;

  Exit;

  Fail: //********************
  ShowString( 'SPL Unit is not defined' );
end; // procedure TN_RAEditForm.aDebViewCompSPLTextExecute

procedure TN_RAEditForm.aDebClearSelfRTIExecute( Sender: TObject );
// Clear Self RTI
begin
  if not (RecordUObj is TN_UDCompBase) then Exit;
  TN_UDCompBase(RecordUObj).ClearSelfRTI();
  ShowString( 'Self RTI Cleared OK' );
end; // procedure TN_RAEditForm.aDebClearSelfRTIExecute

procedure TN_RAEditForm.aDebTmpAction1Execute( Sender: TObject );
// Tmp Action 1
begin
  ShowString( 'Tmp Action 1' );
  GetCurFieldInfo();

  with PCurFieldDescr^ do
  if PCurFieldDescr <> nil then
    ShowString( 'EdUserPar: ' + VEArray[CVEInd].EParams );

//  ShowString( IntToStr(Integer(bnTest1.Visible)) );
//  ShowString( IntToStr(Integer(bnTest1.Index)) );
end; // procedure TN_RAEditForm.aDebTmpAction1Execute

procedure TN_RAEditForm.aDebTmpAction2Execute( Sender: TObject );
// Tmp Action 2
begin
//  inherited;

end; // procedure TN_RAEditForm.aDebTmpAction2Execute

procedure TN_RAEditForm.aDebTmpAction3Execute( Sender: TObject );
// Tmp Action 3
begin
//  inherited;

end; // procedure TN_RAEditForm.aDebTmpAction3Execute


//******************** TN_RAEditForm event handlers  ***********************

procedure TN_RAEditForm.bnApplyClick( Sender: TObject );
// Change Record content,
// if ApplyToMarked flag is set, change current field in all Marked UObjects
var
  NumChanged: Integer;
  PSrcField: Pointer;
  MarkedUObjects: TN_UDArray;
begin
//  N_PCAdd( 4, Format( 'bnApplyClick_1 %d', [Length(RAEditFrame.DataPointers)] ) );
  N_p := RAEditFrame.DataPointers;
  MarkedUObjects := nil;
  FRRAControl.StoreToSData; // Change source record
  UpdateUObj( RecordUObj ); // needed for some types (LogFont, UDNFont, MapLayer, ...)
  GetCurFieldInfo();

  if RecordUObj is TN_UDCompBase then
    if (CurFieldName = 'CCompBase.CBSPLGlobals' ) or
       (CurFieldName = 'CCompBase.CBUserParams' ) or
       (CurFieldName = 'CTextBox.TBMacroText' )   or
       (CurFieldName = 'CTextRow.TRText' )
      then FreeAndNil( TN_UDCompBase(RecordUObj).SPLUnit );

  ShowString( '' );

  //*** Check if all Marked UObjects in N_ActiveVTreeFrame should be updated

  if (cbApplyToMarked.Checked or UpValsInfo.ApplyToAll ) and
    (N_ActiveVTreeFrame <> nil) and
    (CurFieldIndex <> -1) then
  begin
    MarkedUObjects := N_CreateArrayOfUDBase(
                                   N_ActiveVTreeFrame.VTree.MarkedVNodesList );
    PSrcField := FRRAControl.GetSrcFieldPointer();

    NumChanged := N_SetUDRArraysField( PSrcField^, @MarkedUObjects[0],
       Length(MarkedUObjects), CurFieldFullName, CurFieldTypeCode, @UpValsInfo );

    ShowString( IntToStr(NumChanged) + '  UObject(s) changed' );
  end; // if cbApplyToMarked.Checked then

  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaApplyToAll );
end; // procedure TN_RAEditForm.bnApplyClick

procedure TN_RAEditForm.bnCancelClick( Sender: TObject );
// close Self without changing Data
begin
  if N_KeyIsDown( VK_SHIFT ) then
    OnCancelToAll()
  else
    Close();
end; // procedure TN_RAEditForm.bnCancelClick

procedure TN_RAEditForm.bnOKClick( Sender: TObject );
// Call bnApplyClick and Close Self
begin
  GetCurFieldInfo(); // debug;
  bnApplyClick( Sender );

  if N_KeyIsDown( VK_SHIFT) then
    OnOkToAll()
  else
    Close();
    
  ModalResult := mrOK;
end; // procedure TN_RAEditForm.bnOKClick

procedure TN_RAEditForm.FormClose( Sender: TObject; var Action: TCloseAction );
// OnClose event handler
begin
  Inherited;
//  N_PCAdd( 4, Format( 'N_RAEditF Close1 %d', [Length(RAEditFrame.DataPointers)] ) );
  FRRAControl.Free;
  
//  N_PCAdd( 4, Format( 'N_RAEditF Close2 %d', [Length(RAEditFrame.DataPointers)] ) );
  if FormDescr <> nil then
    if FormDescr.Owner = nil // Self is FormDescr Owner
      then FormDescr.UDDelete;
end; // procedure TN_RAEditForm.FormClose


//*********************** TN_RAEditForm public methods  ***************

procedure TN_RAEditForm.OnDataApply();
// RAFrame OnApply handler
begin
  bnApplyClick( nil );
end; // procedure TN_RAEditForm.OnDataApply();

procedure TN_RAEditForm.OnCancelToAll();
// RAFrame OnCancelToAll handler
begin
  if not (BFSelfOwnerForm is TN_RAEditForm) then // First TN_RAEditForm in chain
    Close(); // Close should be executed before RaEdGAProcOfObj (or now it not needed?)

  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaCancelToAll );
end; // procedure TN_RAEditForm.OnCancelToAll

procedure TN_RAEditForm.OnOKToAll();
// RAFrame OnOKToAll handler
begin
//  N_PCAdd( 4, Format( 'N_RAEditF OnOKToAll_0 %d', [Length(RAEditFrame.DataPointers)] ) );
  bnApplyClick( nil );

//  N_PCAdd( 4, Format( 'N_RAEditF OnOKToAll_1 %d', [Length(RAEditFrame.DataPointers)] ) );
  if not (BFSelfOwnerForm is TN_RAEditForm) then // First TN_RAEditForm in chain
    Close(); // Close should be executed before RaEdGAProcOfObj  (or now it not needed?)
    
//  N_PCAdd( 4, Format( 'N_RAEditF OnOKToAll_3 %d', [Length(RAEditFrame.DataPointers)] ) );
  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaOKToAll );
//  N_PCAdd( 4, Format( 'N_RAEditF OnOKToAll_2 %d', [Length(RAEditFrame.DataPointers)] ) );
end; // procedure TN_RAEditForm.OnOKToAll

procedure TN_RAEditForm.SetDataChangedFlag();
// update Self Controls after Data was changed
begin
  DataWasChanged := true;
end; // procedure TN_RAEditForm.SetDataChangedFlag

procedure TN_RAEditForm.ClearDataChangedFlag();
// set Self Controls as if Data was not changed yet
begin
  DataWasChanged := false;
end; // procedure TN_RAEditForm.ClearDataChangedFlag

procedure TN_RAEditForm.PrepareFrame( AFormDescrName: string; IsArray: boolean );
// Prepare Frame for Editing some Component Struct, pointed to by PRecord
// ( PRecord, RecordTypeName and StaticParams variables should be already set )
var
  ModeFlags: TK_RAModeFlagSet;
begin
  ModeFlags := [K_ramFillFrameWidth, K_ramAutoApply, K_ramRowChangeOrder];
//                K_ramSkipResizeWidth, K_ramSkipResizeHeight];
  PrepToolBarArray( IsArray );
  if IsArray then ModeFlags := ModeFlags + [K_ramRowChangeNum, K_ramRowAutoChangeNum];

  RecordTypeCode := K_GetExecTypeCodeSafe( RecordTypeName );
  if StaticParams then
    RecordTypeCode.D.CFlags := RecordTypeCode.D.CFlags or K_ccCountUDRef;

  RecordTypeCode.D.TFlags := RecordTypeCode.D.TFlags or K_ffArray;

  FormDescr.Free;
  FormDescr := K_CreateSPLClassByName( AFormDescrName, [] );
  FRRAControl.FreeContext();
  FRRAControl.PrepFrameByFormDescr( [], ModeFlags, PRecord^, RecordTypeCode,
                                                              '', FormDescr );
 // is needed because of Delphi Error in calculating StatusBar.Top:
  StatusBar.Top := Self.Top + Self.Height - StatusBar.Height;
end; // procedure TN_RAEditForm.PrepareFrame

procedure TN_RAEditForm.PrepToolBarArray( AIsVisible: boolean );
// Set ToolBarArray visibility by given AIsVisible
begin
  if ToolBarArray.Visible = AIsVisible then Exit; // already OK

  if AIsVisible then // make ToolBarArray Vsibile
  begin
    ToolBarArray.Visible := True;
    RAEditFrame.Height := RAEditFrame.Height - ToolBarArray.Height;
  end else //********** make ToolBarArray InVsibile
  begin
    ToolBarArray.Visible := False;
    RAEditFrame.Height := RAEditFrame.Height + ToolBarArray.Height;
  end;

end; // procedure TN_RAEditForm.PrepToolBarArray

procedure TN_RAEditForm.SetFrameByStructType();
// Set Frame by Struct Type in CompStructType variable
begin
  case CompStructType of
    cstSetParams:  aCompSetParamsExecute( nil );
    cstUserParams: aCompUserParamsExecute( nil );

    cstComParams:  aCompCommonParamsExecute( nil );
    cstLayout:     aCompLayoutParamsExecute( nil );
    cstCoords:     aCompCoordsParamsExecute( nil );
    cstPanel:      aCompPanelParamsExecute( nil );
    cstIndParams:  aCompIndivParamsExecute( nil );

    cstExpParams:  aCompExportParamsExecute( nil );
  end; // case AFrameInd of
end; // procedure TN_RAEditForm.SetFrameByStructType

procedure TN_RAEditForm.UpdateUObj( AUObj: TK_UDRArray );
// Update given UObj according to its Type
begin
  case AUObj.CI() of
    N_UDMapLayerCI: TN_UDMapLayer(AUObj).SetIconIndex();
    N_UDLogFontCI:  TN_UDLogFont(AUObj).ClearWinHandle();
    N_UDNFontCI:    TN_UDNFont(AUObj).DeleteWinHandle();
  end; // case AUObj.CI() of
end; // procedure TN_RAEditForm.UpdateUObj

procedure TN_RAEditForm.InitByTypeName( AAFormDescrName: string );
// Create FormDescr as UDBase by given AAFormDescrName,
// initialize FRRAControl and RAEditFrame
//
// ( FormDescr is Form field, because it should be deleted in FormClose)
var
 FDTypeName: string;
// ModeFlags: TK_RAModeFlagSet;
 EditAsArray, MatrMode: boolean;
 WrkRArray: TK_RArray;

  procedure PrepFraControl( AAAFormDescrName: string ); // local, just to reduce code size
  begin
//    EditAsArray := False;
    EditAsArray := True;
    if (AAAFormDescrName = 'TN_OneNonLinConvFormDescr') or
       (AAAFormDescrName = 'TN_PointAttr1FormDescr') or
       (AAAFormDescrName = 'TN_SclonOneTokenFormDescr') or
       (AAAFormDescrName = 'TN_VCTreeParamsFormDescr') then EditAsArray := True;

    if EditAsArray then
    begin
      RAModeFlags := [K_ramFillFrameWidth, K_ramShowLRowNumbers, K_ramRowChangeOrder,
                      K_ramRowChangeNum, K_ramRowAutoChangeNum, K_ramAutoApply];
      PrepToolBarArray( True );
    end else
      RAModeFlags := [K_ramFillFrameWidth, K_ramAutoApply, K_ramSkipResizeWidth];

    FormDescr.Free;
    FormDescr := K_CreateSPLClassByName( AAAFormDescrName, [] );
    FRRAControl.PrepFrameByFormDescr( [], RAModeFlags, PRecord^,
                                               RecordTypeCode, '', FormDescr );
  end; // procedure PrepFraControl - local

begin //***** body of TN_RAEditForm.InitByTypeName

  if RecordTypeName = 'TN_LogFont' then //****************** LogFont UDRArray record
  begin
    PrepFraControl( 'TN_LogFontEdForm' );
  end
  else if RecordTypeName = (K_sccArray + ' TN_NFont') then // New Font record
  begin
    PrepFraControl( 'TN_NFontFormDescr' );
//  end
//  else if RecordTypeName = (K_sccArray + ' TN_SetParamInfo') then // Component SetParams
//  begin
//    PrepFraControl( 'TN_SetParamEdForm' );
  end else if AAFormDescrName <> '' then // given FormDescr Name
  begin
    PrepFraControl( AAFormDescrName );
  end else
  begin //******************************* no special Form Description
    FDTypeName := K_GetDefaultFDTypeName( RecordTypeCode.All );

    if (K_GetTypeCode( FDTypeName ).DTCode <> -1) then
      PrepFraControl( FDTypeName ) // use FormDescr with default name
    else //************************** create default FormDescr
    begin
      RAModeFlags := [K_ramFillFrameWidth, K_ramAutoApply, K_ramSkipResizeWidth];
      if Copy( RecordTypeName, 1, Length(K_sccArray) ) = K_sccArray then
      begin
        RAModeFlags := [K_ramFillFrameWidth, K_ramShowLRowNumbers, K_ramRowChangeOrder,
         K_ramRowChangeNum, K_ramRowAutoChangeNum, K_ramAutoApply, K_ramColVertical];

        WrkRArray := TK_PRArray(PRecord)^;
        MatrMode := False;

        if WrkRArray <> nil then
          if WrkRArray.HCol >=1 then
            MatrMode := True;

        if MatrMode then // Edit as 2D RArray
         aAEEditAs2DRArrayExecute( nil )
        else //************ Edit as 1D RArray
         aAEEditAs1DRArrayExecute( nil );

      end else // not RArray
        FRRAControl.PrepFrame1( [], RAModeFlags, PRecord^, RecordTypeCode, '' );
    end;
  end;
end; // procedure TN_RAEditForm.InitByTypeName

procedure TN_RAEditForm.GetCurFieldInfo();
// Get all needed Info about current Field
var
  TmpInd: integer;
begin
    //***** Initialize variables:
  CurFieldName     := '';
  CurFieldTypeName := '';
  CurFieldFullName := '';
  CurFieldTypeCode.DTCode := -1;
  CurFieldTypeIsDynamic := False;
  PCurFieldDescr  := nil;
  PCurFieldInBuf  := nil;
  PCurRArrayField := nil;
  CurFieldUObj    := nil;
  CurFieldIndex   := RAEditFrame.CurLCol;

  TmpInd := RAEditFrame.CurLRow;
  if (CurFieldIndex <= -1) or (TmpInd <= -1) then Exit; // now current field

  PCurFieldDescr := @RAEditFrame.RAFCArray[CurFieldIndex];
  PCurFieldInBuf := RAEditFrame.DataPointers[TmpInd][CurFieldIndex];

  CurFieldName := RAEditFrame.RAFCArray[CurFieldIndex].Name;
  CurFieldTypeCode := RAEditFrame.RAFCArray[CurFieldIndex].CDType;

  if CurFieldTypeCode.DTCode = Ord(nptUDRef) then // Current Field is TN_UDBase
    CurFieldUObj := TN_PUDBase(PCurFieldInBuf)^;

  if (CurFieldTypeCode.D.TFlags and K_ffArray) <> 0 then // Current Field is RArray
  begin
    PCurRArrayField := TK_PRArray(PCurFieldInBuf);

    if PCurRArrayField^ <> nil then // get real Code of Dynamic RArray (if DTCode = nptNotDef)
    begin
      if CurFieldTypeCode.D.TCode = ord(nptNotDef) then
        CurFieldTypeIsDynamic := True; // mainly for debug and for showing Info about Cur Field

      CurFieldTypeCode := PCurRArrayField^.ElemType;
      CurFieldTypeCode.D.TFlags := CurFieldTypeCode.D.TFlags or K_ffArray;
    end;
  end; // if (CurFieldTypeCode.D.TFlags and K_ffArray) <> 0 then // Current Field is RArray

  if (CurFieldTypeCode.D.TFlags and K_ffVArray) <> 0 then // Current Field is VArray
  begin
    if PObject(PCurFieldInBuf)^ is TN_UDBase then // VArray is reference to TN_UDBase
    begin
      CurFieldUObj := TN_PUDBase(PCurFieldInBuf)^;

      if CurFieldUObj is TK_UDRArray then // VArray is reference to TK_UDRArray
      begin
        PCurRArrayField := @TK_UDRArray(CurFieldUObj).R;

        if PCurRArrayField^ <> nil then // get real Code of Dynamic RArray (if DTCode = nptNotDef)
        begin
          if CurFieldTypeCode.D.TCode = ord(nptNotDef) then
            CurFieldTypeIsDynamic := True; // mainly for debug and for showing Info about Cur Field

          CurFieldTypeCode := PCurRArrayField^.ElemType;
          CurFieldTypeCode.D.TFlags := CurFieldTypeCode.D.TFlags or K_ffVArray;
        end;
      end; // if CurFieldUObj is TK_PUDRArray then // VArray is reference to TK_UDRArray
    end else //*************************************** VArray is RArray
    begin
      PCurRArrayField := TK_PRArray(PCurFieldInBuf);
      CurFieldUObj := nil; // can be used to check VArray variant (UDBase or RArray)

      if PCurRArrayField^ <> nil then // get real Code of Dynamic RArray (if DTCode = nptNotDef)
      begin
        if CurFieldTypeCode.D.TCode = ord(nptNotDef) then
          CurFieldTypeIsDynamic := True; // mainly for debug and for showing Info about Cur Field

        CurFieldTypeCode := PCurRArrayField^.ElemType;
        CurFieldTypeCode.D.TFlags := CurFieldTypeCode.D.TFlags or K_ffArray;
      end;
    end;

  end; // if (CurFieldTypeCode.D.TFlags and K_ffArray) <> 0 then // Current Field is RArray

  CurFieldTypeName := K_GetExecTypeName( CurFieldTypeCode.All );
  CurFieldFullName := RAEditFrame.GetCellDataPath( CurFieldIndex, TmpInd );
end; // procedure TN_RAEditForm.GetCurFieldInfo

procedure TN_RAEditForm.PrepPopupMenu();
// Prepare PopupMenu Items for current Field
//
// Not fully implemented
var
  FreeAInd, FreeGInd: integer;
begin
  GetCurFieldInfo();
  with RAEditFrame do
  begin
    SetLength( PopupActionGroups, 5 ); // Number of Action Groups

    // Zero Length Action Group (hear - PopupActionGroups[0]) means Group with standart Actions

    SetLength( PopupActionGroups[1], 10 ); // prelimenary value

    FreeGInd := 1; // Group Index =0 is reserved for Ext. Editors defined in FormDescr
    FreeAInd := 0;

    PopupActionGroups[FreeGInd][FreeAInd] := aViewFieldInfo;  Inc(FreeAInd);

    if PCurRArrayField <> nil then // current field is an RArray, Set RArray Related Actions
    begin
      PopupActionGroups[FreeGInd][FreeAInd] := aAESetRArraySize;   Inc(FreeAInd);
      PopupActionGroups[FreeGInd][FreeAInd] := aAESet2DRArraySize; Inc(FreeAInd);
    end; // if PCurRArrayField <> nil then // current field is an RArray

    SetLength( PopupActionGroups[FreeGInd], FreeAInd );

    SetLength( PopupActionGroups, FreeGInd+1 );
  end; // with RAEditFrame do

end; // procedure TN_RAEditForm.PrepPopupMenu

procedure TN_RAEditForm.PrepCompScalarStruct();
// Prepare for editing any of Component Scalar (Static or Dynamic) Struct
// Scalar Structs are: Layout, Common Params, Coords, Panel, Individual Params
// Vector Structs are: SetParams, UserParams, Export Params
begin
  PrepToolBarArray ( False ); // Hide Array related ToolBar

  // CurRArray variable was set to Static or Dynamic Params in
  //            aDebToggleStatDynExecute method
  PRecord := @CurRArray;
  RecordTypeName := CompTypeName;
  RAEditFrame.DataPath := '';
end; // procedure TN_RAEditForm.PrepCompScalarStruct

procedure TN_RAEditForm.ShowString( AStr: string );
// Show given string AStr in StatusBar
begin
  StatusBar.SimpleText := AStr;
end; // procedure TN_RAEditForm.ShowString

procedure TN_RAEditForm.TuneViewers();
// Set Viewers Visibility, Captions and Image Indexes
var
  ExpFlags: TN_CompExpFlags;
begin
  aCompViewExecute.Visible   := False;
  aCompViewMain.Visible      := False;
  aCompViewByCurAux.Visible  := False;
  aCompViewSetCurAux.Visible := False;

  ExpFlags := TN_UDCompBase(RecordUObj).GetExpFlags();

  if cefExec in ExpFlags then aCompViewExecute.Visible := True;

  if (cefGDI in ExpFlags) or (cefTextFile in ExpFlags) or
     (cefWordDoc in ExpFlags) or (cefExcelDoc in ExpFlags)  then
  begin
    aCompViewMain.Visible := True;

    if cefGDI in ExpFlags then
      aCompViewMain.ImageIndex := aCompViewPictInMem.ImageIndex
    else if cefTextFile in ExpFlags then
      aCompViewMain.ImageIndex := aCompViewHTMLFile.ImageIndex
    else if cefWordDoc in ExpFlags then
      aCompViewMain.ImageIndex := aCompViewInMSWord.ImageIndex
    else if cefExcelDoc in ExpFlags then
      aCompViewMain.ImageIndex := aCompViewInMSExcel.ImageIndex;

  end; // if (cefGDI in ExpFlags) or (cefTextFile in ExpFlags) then

  if (cefGDIFile in ExpFlags) or (cefTextFile in ExpFlags) then
  with N_MEGlobObj do
  begin
    aCompViewByCurAux.Visible  := True;
    aCompViewSetCurAux.Visible := True;

    if cefGDIFile in ExpFlags then
    with N_CompPictViewerActions[CompPictViewerInd] do
    begin
      aCompViewByCurAux.Caption    := Caption;
      aCompViewByCurAux.ImageIndex := ImageIndex;
    end else
    with N_CompTextViewerActions[CompTextViewerInd] do
    begin
      aCompViewByCurAux.Caption    := Caption;
      aCompViewByCurAux.ImageIndex := ImageIndex;
    end;

  end; // if (cefGDIFile in ExpFlags) or (cefTextFile in ExpFlags) then

end; // procedure TN_RAEditForm.TuneViewers

//***********************************  TN_RAEditForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_RAEditForm.CurStateToMemIni();
begin
  Inherited;
  N_IntToMemIni( 'N_RaEdF', 'StructType', Ord(CompStructType) );
end; // end of procedure TN_RAEditForm.CurStateToMemIni

//***********************************  TN_RAEditForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_RAEditForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_RAEditForm.MemIniToCurState


//************* External Editors and related procedures *********************


//****************  TN_RAFRAEditEditor class methods  ******************

//********************************************** TN_RAFRAEditEditor.GetText ***
// For TN_CodeSpaceItem fields return Item Name and CS Name in brackets
//
function TN_RAFRAEditEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
var
  PNFont: TN_PNFont;
begin
  if RAFC.CDType.DTCode = N_SPLTC_NFont then // NFont VArray
  begin
    Result := 'Empty';
    if TObject(AData) = nil then Exit;

    if TObject(AData) is TK_UDRarray then
    begin
      PNFont := TN_PNFont(TK_UDRarray(AData).R.P());
      IconInd := TK_UDRarray(AData).ImgInd;
      TextShift := 18;
    end else
    begin
      Assert( TObject(AData) is TK_Rarray, 'Bad AData' );
      PNFont := TN_PNFont(TK_Rarray(AData).P());
      IconInd := 0;
      TextShift := 0;
    end;

    if PNFont = nil then Exit;

    with PNFont^ do
      Result := Format( '%s, %.1f pt', [NFFaceName, NFLLWHeight] );

  end else // not some special type
    Result := Inherited GetText( AData, RAFC, ACol, ARow, PHTextPos );

//var
//  CurTypeName: string;
//  CurTypeName := K_GetExecTypeName( RAFC.CDType.All );
//  if CurTypeName = 'TN_CodeSpaceItem' then
//    Result := N_CSItemAsStr( TN_PCodeSpaceItem(@AData) );
end; // function TN_RAFRAEditEditor.GetText

{
//****************************************** TN_RAFRAEditEditor.DrawCell ***
// overloaded variant for Own User Parameter Editor
// just change CFillColor field for RArrays of Color with one element
//
procedure TN_RAFRAEditEditor.DrawCell( var AData; var RAFC: TK_RAFColumn;
                                       ACol, ARow : Integer; Rect: TRect;
                                       State: TGridDrawState; Canvas: TCanvas);
begin
  inherited DrawCell( AData, RAFC, ACol, ARow, Rect, State, Canvas );
end; //*** procedure TN_RAFRAEditEditor.DrawCell
}

//************************************************* TN_RAFRAEditEditor.Edit ***
// RAEditForm as external Editor
//
function TN_RAFRAEditEditor.Edit( var AData ): Boolean;
begin
  Result := False; // "AData were not changed yet" flag
  N_EditRAFrameField( AData,  RAFrame );
end; //*** procedure TN_RAFRAEditEditor.Edit

{
//****************  TN_RAFVArrayEditor class methods  ******************

//**************************************** TN_RAFVArrayEditor.Edit
// Toggle VArray between external UDRArray and embedded RArray forms
//
function TN_RAFVArrayEditor.Edit( var AData ): Boolean;
var
  AObj: TObject;
  UDR: TK_UDRArray;
  UObj: TN_UDBase;
  RObj: TK_RArray;
begin
  Result := False;

  with RAFrame do
   if (RAFCArray[CurLCol].CDType.D.TFLags and K_ffVArray) = 0 then Exit; // not VArray

  AObj := TObject(AData);

  if AObj is TK_UDRArray then // Create new RArray by existed UDRArray
  begin
    UDR := TK_UDRArray(AObj);
    TObject(AData) := nil;
    K_MoveSPLData( UDR.R, AData, UDR.R.GetArrayType(), [K_mdfFreeAndFullCopy] );
    Result := True;
  end else // Set ref to UDRArray and copy Existed RArray content to it if needed
  begin
    if not (AObj is TK_RArray) then Exit; // a precaution
    RObj := TK_RArray(AObj);

    UObj := K_SelectUDB( K_CurArchive, '', nil, nil, 'Select UDRArray' );
    if not (UObj is TK_UDRArray) then Exit;
    UDR := TK_UDRArray(UObj);

    if RObj <> nil then
      if UDR.R.GetElemType().DTCode <> RObj.GetElemType().DTCode then Exit;

    TObject(AData) := UDR;
    Result := True;

    if RObj <> nil then
      if mrYes = N_MessageDlg( 'Copy current RArray content to ' + UDR.ObjName +
                               ' ?', mtCustom, mbYesNo, 0 ) then
      K_MoveSPLData( RObj, UDR.R, RObj.GetArrayType(), [K_mdfFreeAndFullCopy] );

    RObj.Free;
  end; // else // Set ref to UDRArray

end; //*** procedure TN_RAFVArrayEditor.Edit
}

//****************  TN_RAFUDRefEditor class methods  ******************

//************************************************** TN_RAFUDRefEditor.Edit ***
// Show UObjFrame.PopupMenu and execute choosen Action
//
function TN_RAFUDRefEditor.Edit( var AData ): Boolean;
var
  UObj: TN_UDBase;
  IsUDBase: boolean;
  WrkStatusBar: TStatusBar;
  OwnerForm: TN_BaseForm;
  ADataType: TK_ExprExtType;
begin
  Result := False;

  //*** Check Data consistancy (a precaution)

  if Pointer(AData) = nil then Exit;
  with RAFrame do
  begin
   IsUDBase  := False;
   ADataType := RAFCArray[CurLCol].CDType;

   if (ADataType.D.TFlags and K_ffVArray) <> 0 then // is VArray
   begin
     if TObject(AData) is TN_UDBase then
       IsUDBase := True;
   end;

   if not IsUDBase then // not VArray
     IsUDBase := ADataType.DTCode = Ord(nptUDRef);

   if not IsUDBase then Exit;
  end; // with RAFrame do

  UObj := TN_UDBase(AData);
//  if K_msdUndef <> K_MVDarGetUserNodeType( UObj ) then Exit; // MVDar Object

  //*** Data consistancy is OK, set WrkStatusBar and OwnerForm

  OwnerForm := K_GetOwnerBaseForm( RAFrame );

  if OwnerForm is TN_RAEditForm then // is called from TN_RAEditForm
    WrkStatusBar := TN_RAEditForm(OwnerForm).StatusBar
  else
    WrkStatusBar := nil;

  N_ShowUObjActionsMenu( UObj, WrkStatusBar, OwnerForm );
end; //*** procedure TN_RAFUDRefEditor.Edit


//****************  TN_RAFUserParamEditor class methods  ******************

var // TN_RAFUserParamEditor class Data (UPNames and UPTypes should be Synchronous!):
  UPNames: array [0..14] of string = (
           'string', 'double',   'float', 'integer', 'Color', 'byte', '',
           'UDRef',  'Boolean4', 'Float Point', 'Float Rect', '',
           'Time Series', 'Data Block', 'Codes SubDim' );
  UPTypes: array [0..14] of string = (
           'string', 'double', 'float', 'integer', 'Color',  'byte', '',
           'TN_UDBase', 'TN_Boolean4',  'TFPoint', 'TFRect', '',
           'TN_TimeSeriesUP', 'DataBlock', 'CSDim' );

//******************************************* TN_RAFUserParamEditor.GetText ***
// overloaded variant for Own User Parameter Editor:
// for one elements RArrays show content of theirs element,
// for other arrays show type and number of elements
//
function TN_RAFUserParamEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
var
  NumElems, NX, NY: integer;
  UPType: TN_UserParamType;
  ElemTypeName: string;
  CurRArray: TK_RArray;
  SavedType: TK_ExprExtType;
begin
  CurRArray := TK_RArray(AData);
  Result := 'not defined'; // representation for not initialized User Parameter
  if CurRArray = nil then Exit;

  N_GetUserParInfo ( CurRArray, UPType, NumElems );

  if UPType = uptBase then // Array of Base Type
  begin
    ElemTypeName := K_GetExecTypeName( CurRArray.ElemType.All );

    if NumElems = 1 then // scalar value, show it
    begin
      with RAFC do
      begin
        SavedType := CDType;
        CDType := CurRArray.ElemType; // change temporary for inherited GetText
        Result := inherited GetText( CurRArray.P()^, RAFC, ACol, ARow );
        CDType := SavedType; // restore
      end; // with RAFC do
    end else // Array of two or more elements, show Number of elements and type
    begin
      CurRArray.ALength( NX, NY );
      if NX = 1 then // 1D vector
        Result := Format( '%d %s', [NumElems, ElemTypeName+'s'] )
      else // NX > 1 - 2D matrix
        Result := Format( '%d x %d %s', [NX, NY, ElemTypeName+'s'] );
    end;
  end else // some special Type
  begin
    case UPType of
      uptTimeSeries: Result := 'TimeSeries';
      uptDataBlock:  Result := 'Data Block';
      uptCSDim:      Result := 'Codes SubDim';
      uptBoolean4: if PInteger(CurRArray.P())^ = 0 then Result := 'False'
                                                   else Result := 'True';
    else
      Result := 'Not Defined';
    end; // case UPType of
  end; // else // some special Type
end; // function TN_RAFUserParamEditor.GetText

//****************************************** TN_RAFUserParamEditor.DrawCell ***
// overloaded variant for Own User Parameter Editor
// just change CFillColor field for RArrays of Color with one element
//
procedure TN_RAFUserParamEditor.DrawCell( var AData; var RAFC : TK_RAFColumn;
                                ACol, ARow : Integer; Rect: TRect;
                                State: TGridDrawState; Canvas: TCanvas);
var
  NumElems, CurValue, SavedColor: integer;
  SavedBitMask: LongWord;
  CurRArray: TK_RArray;
  SavedShowEditFlags: TK_RAColumnFlagSet;
begin
  CurRArray := TK_RArray(AData);

  if CurRArray <> nil then
  begin
    NumElems := CurRArray.ALength();

    if (NumElems = 1) and (CurRArray.ElemType.DTCode = Ord(nptColor)) then // Color
    with RAFC do
    begin
      SavedColor := CFillColor;
      SavedShowEditFlags := ShowEditFlags;

      CFillColor := PInteger(CurRArray.P)^; // used in inherited DrawCell as current Color
      Include( ShowEditFlags, K_racUseFillColor );

      // AData is not correct, but does not matter
      inherited DrawCell( AData, RAFC, ACol, ARow, Rect, State, Canvas );

      CFillColor := SavedColor;
      ShowEditFlags := SavedShowEditFlags;
      Exit;
    end;

    if (NumElems = 1) and (CurRArray.ElemSType = N_SPLTC_Boolean4) then // Boolean
    with RAFC do
    begin
      SavedShowEditFlags := ShowEditFlags;
      SavedBitMask := BitMask;
      Include( ShowEditFlags, K_racShowCheckBox );
      BitMask := $FFFFFFFF;
      CurValue := PInteger(CurRArray.P())^;

      inherited DrawCell( CurValue, RAFC, ACol, ARow, Rect, State, Canvas );

      BitMask := SavedBitMask;
      ShowEditFlags := SavedShowEditFlags;
      Exit;
    end;

  end; // if CurRArray <> nil then

  // AData is not correct, but does not matter
  inherited DrawCell( AData, RAFC, ACol, ARow, Rect, State, Canvas );

end; //*** procedure TN_RAFUserParamEditor.DrawCell

//************************************ TN_RAFUserParamEditor.ConvFromString ***
// Finish Editing - convert Scalar UserParam value from String
// (is used as RAFrame.OnInlineEditorExit procedure of object)
//
procedure TN_RAFUserParamEditor.ConvFromString( AResultText: string; var AData );
begin
  with TK_RArray(AData) do
    K_SPLValueFromString( P()^, ElemType.All, AResultText );

  RAFrame.AddChangeDataFlag;
end; // procedure TN_RAFUserParamEditor.ConvFromString

//********************************************** TN_RAFUserParamEditor.Edit ***
// one User Parameter Editor as external Editor
//
function TN_RAFUserParamEditor.Edit( var AData ): Boolean;
var
  TypeInd, NumElems: integer;
  Str: string;
  SelectedUObj, CurUObj: TN_UDBase;
  UPType: TN_UserParamType;
  CurRArray: TK_RArray;
  OwnerForm: TN_BaseForm;
  PRAFC: TK_PRAFColumn;

  procedure CreateAndOrEditDataBlock(); // local
  // Create if needed and Edit AData as DataBlock
  begin
    with K_GetFormCSDBlock( OwnerForm ) do
    begin
      ShowRACSDBlock( TK_RArray(AData) );
      Show();
    end; // with K_GetFormCSDBlock( OwnForm ) do
  end; // procedure CreateAndOrEditDataBlock(); // local

  procedure CreateAndOrEditCSDim(); // local
  // Create if needed and Edit AData as Codes SubDim
  begin
    with K_GetFormCSDim( OwnerForm ) do
    begin
      ShowRACSDim( TK_RArray(AData), '' );
      Show();
    end; // with K_GetFormCSDBlock( OwnForm ) do
  end; // procedure CreateAndOrEditCSDim(); // local

begin
  Result := False;
  OwnerForm := K_GetOwnerBaseForm( RAFrame );

  with RAFrame do
  begin
  if (CurLRow < 0) or (CurLCol < 0 ) then Exit; // a precaution

  if TK_RArray(AData) = nil then // User Parameter is not created, create it
  begin
    TypeInd := N_GetEnumIndex( UPNames, 1, 'User Parameter Types :', 'Enter New Type' );
    if TypeInd = -1 then Exit; // User Parameter type was not choosen

    if UPTypes[TypeInd] = 'DataBlock' then
    begin
      CreateAndOrEditDataBlock();
      Exit; // All done
    end else if UPTypes[TypeInd] = 'CSDim' then
    begin
      CreateAndOrEditCSDim();
      Exit; // All done
    end else if UPTypes[TypeInd] = '' then // separator
    begin
      Exit;
    end else  // all other types except DataBlock and CSDim
      TK_RArray(AData) := K_RCreateByTypeName( UPTypes[TypeInd], 1, [] );

    SGrid.Invalidate();
  end; // if PFieldInBuf^ = nil then // User Parameter is not created, create it

  //***** User Parameter exists, edit it

  PRAFC := @RAFCArray[CurLCol];
  if (PRAFC^.CDType.D.TFlags and K_ffArray) = 0 then Exit; // a precaution

  CurRArray := TK_RArray(AData);
  N_GetUserParInfo( CurRArray, UPType, NumElems );

  if UPType = uptDataBlock then // Data Block
    CreateAndOrEditDataBlock()
  else if UPType = uptCSDim then // Codes SubDimension
    CreateAndOrEditCSDim()
  else if UPType = uptBase then // SPL Base type
  with CurRArray do
  begin
    if NumElems = 1 then // use Inline or special scalar Editor
    begin
      if ElemType.DTCode = Ord(nptUDRef) then // is UDBase, use N_SelectUDBase
      begin
        CurUObj := TN_PUDBase(P())^;
        if CurUObj = nil then
          CurUObj := RLSData.RUDRArray;

        SelectedUObj := N_SelectUDBase( CurUObj, 'Select UDBase' );

        if SelectedUObj <> nil then // some UObj was selected, set UDref to It
          TN_PUDBase(P())^ := SelectedUObj;
      end else if ElemType.DTCode = Ord(nptColor) then // is Color, use N_ModalEditColor
      begin
        PInteger(CurRArray.P())^ := N_ModalEditColor( PInteger(CurRArray.P())^ );
        SGrid.Invalidate();
      end else // all other SPL base types except UDBase and Color
      begin
        OnInlineEditorExit := ConvFromString;
        Str := GetText( AData, PRAFC^, 0, 0 ); // only first two params are used
        CallInlineTextEditor( Str );
      end;

    end else // NumElems > 1, use New RAEditForm
      N_EditRAFrameField( AData, RAFrame );
  end else if UPType = uptBoolean4 then // Boolean4, toggle 0-1 Value
  begin
    if PInteger(CurRArray.P())^ = 0 then PInteger(CurRArray.P())^ := 1
                                    else PInteger(CurRArray.P())^ := 0;
    SGrid.Invalidate;
    Result := True;
  end else // unknown type
    Exit;

  end; // with RAFrame do
end; //*** procedure TN_RAFUserParamEditor.Edit


//****************  TN_RAFCharCodesEditor class methods  ******************

//**************************************** TN_RAFCharCodesEditor.Edit
// String as Char Codes Editor
//
function TN_RAFCharCodesEditor.Edit( var AData ): Boolean;
var
  i, IndInRow, IntChar, CurSize: integer;
  OwnerForm: TN_BaseForm;
  TmpStr, CurStr, HexCodeStr: string;
  SL: TStringList;
begin
  Result := False;

  with RAFrame do
   if not (RAFCArray[CurLCol].CDType.DTCode = Ord(nptString)) then Exit; // a precaution

  OwnerForm := K_GetOwnerBaseForm( RAFrame );
  SL := TStringList.Create();
  TmpStr := String(AData);
  CurStr := '';
  IndInRow := 0;

  for i := 1 to Length(TmpStr) do // convert Characters to Codes
  begin
    IntChar := Integer(TmpStr[i]);
    if (IntChar = $0A) or (IntChar = $0D) then
      CurStr := CurStr + '¶'
    else
      CurStr := CurStr + TmpStr[i];

    CurStr := CurStr + Format( '$%.2X ', [IntChar] );

    if (IndInRow >= 11) or (IntChar = $0A) then // to next row
    begin
      IndInRow := 0;
      SL.Add( CurStr );
      CurStr := '';
    end else // to next token in row
      Inc( IndInRow );

  end; // for i := 1 to Length(TmpStr) do // convert Characters to Codes

  if CurStr <> '' then SL.Add( CurStr );
  TmpStr := SL.Text;

  if N_EditText( TmpStr, OwnerForm ) then // text was changed
  begin
    SetLength( CurStr, Length(TmpStr) div 2 ); // prelimenary max possible size
    CurSize := 0;

    for i := 1 to Length(TmpStr)-1 do // along all chars in Row
    begin
      if (TmpStr[i] = '$') and (TmpStr[i+1] <> '$') then // Hex Char Code
      begin
        HexCodeStr := LowerCase( Copy( TmpStr, i+1, 2 ) );
        Inc(CurSize);
        HexToBin( @HexCodeStr[1], @CurStr[CurSize], 1 ); // two Hex digits to Char
      end;
    end; // for i := 1 to Length(TmpStr)-1 do // along all chars in Row

    SetLength( CurStr, CurSize ); // final real size
    String(AData) := CurStr;
  end;

  SL.Free;
end; //*** procedure TN_RAFCharCodesEditor.Edit


//****************  TN_RAFValsInStrEditor class methods  ******************

//**************************************** TN_RAFValsInStrEditor.Edit
// Values in String Editor:
// Call Scalar, Point or Rect Visual Editor for editing 1,2,4 Tokens in String
//
function TN_RAFValsInStrEditor.Edit( var AData ): Boolean;
var
  FirstToken, NumTokens, Accuracy: integer;
  Str, TmpEdStr: string;
  CurDRect: TDRect;
//  OwnerForm: TN_BaseForm;
  ParamsForm: TN_EditParamsForm;
  VVEdForm: TN_VVEdBaseForm;
begin
  Result := False;

  with RAFrame do
   if not (RAFCArray[CurLCol].CDType.DTCode = Ord(nptString)) then Exit; // a precaution

  TmpEdStr := String(AData);

  ParamsForm := N_CreateEditParamsForm( 400 );
  with ParamsForm do
  begin
    Caption := ' Choose Tokens to Edit:';
    AddLEdit( 'Source String:', 350, TmpEdStr ); // for info only

    AddHistComboBox( 'First(>=1) NumTokens Accuracy:', 'ValsInStrHist' );
    EPControls[1].CRFlags := [ctfActiveControl, ctfExitOnEnter];

    ShowSelfModal();

    Str := EPControls[1].CRStr;
    FirstToken := N_ScanInteger( Str );
    NumTokens  := N_ScanInteger( Str );
    Accuracy   := N_ScanInteger( Str );

    Release; // Free ParamsForm

    if (ModalResult <> mrOK) or (FirstToken <= 0) or
       (NumTokens < 1) or (NumTokens > 4) or
       (Accuracy = N_NotAnInteger) then  Exit;
  end; // with ParamsForm do

  if NumTokens = 3 then NumTokens := 2; // a precation;

  case NumTokens of
    1: VVEdForm := TN_VScalEd1Form.Create( Application );
    2: VVEdForm := TN_VPointEd1Form.Create( Application );
    4: VVEdForm := TN_VRectEd1Form.Create( Application );
    else
      VVEdForm := nil; // to avoid warning
  end; // case NumTokens of

//  CurDRect :=

  with VVEdForm do
  begin
    ValueType := ovtDouble;
    InitVVEdForm2( @CurDRect, NumTokens, 'ValsInStr',
                                             K_GetOwnerBaseForm( RAFrame ) );
    Show();

  end; // with VVEdForm do


  String(AData) := TmpEdStr;
end; //*** procedure TN_RAFValsInStrEditor.Edit


//****************  TN_RAFPA2SPEditor class methods  ******************

var // PA2SPNames array is syncro with N_PA2SPTypes array and to TN_PointAttr2Type-1 indexes
  PA2SPNames: array [0..7] of string = ('Stroke Shape', 'Round Rect', 'Ellipse Arc',
                  'Regular Polygon Arc', 'Text Row', 'Picture', 'Arrow', 'Polyline' );

//**************************************** TN_RAFPA2SPEditor.GetText
// overloaded variant for Point Attr 2 Specific Params Editor:
// show Element type name
//
function TN_RAFPA2SPEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
var
  i: integer;
  ElemTypeName: string;
  CurRArray: TK_RArray;
begin
  CurRArray := TK_RArray(AData);

  Result := 'not defined'; // representation for not initialized User Parameter
  if CurRArray = nil then Exit;

  ElemTypeName := K_GetExecTypeName( CurRArray.ElemType.All );

  for i := 0 to High(N_PA2SPTypes) do
  begin
    if ElemTypeName = N_PA2SPTypes[i] then
    begin
      Result := PA2SPNames[i] + ' ...';
      Exit;
    end;
  end; // for i := 0 to High(N_PA2SPTypes) do
end; // function TN_RAFPA2SPEditor.GetText

//**************************************** TN_RAFPA2SPEditor.Edit
// one Point Attr #2 Specific Parameters Editor as external Editor
//
function TN_RAFPA2SPEditor.Edit( var AData ): Boolean;
var
  TypeInd: integer;
  OwnerForm: TN_BaseForm;
  PElemInBuf: TN_PPointAttr2;
  TmpEl: TN_PointAttr2;
begin
  Result := False;
  OwnerForm := K_GetOwnerBaseForm( RAFrame );
  if not (OwnerForm is TN_RAEditForm) then Exit; // is called not from TN_RAEditForm

  with RAFrame, TN_RAEditForm(OwnerForm) do
  begin
    if (CurLRow < 0) or (CurLCol < 0 ) then Exit; // a precaution
    if RecordTypeName <> 'arrayof TN_PointAttr2' then Exit; // a precaution
//    GetCurFieldInfo();

    if TK_RArray(AData) = nil then // Special Parameters are not created, create them
    begin
      PElemInBuf := FRRAControl.GetBufRecPointer();
      TmpEl := PElemInBuf^;

      TypeInd := N_GetEnumIndex( PA2SPNames, 1, 'Shape Types :', 'Enter New Type' );
      if TypeInd = -1 then Exit; // Shape type was not choosen

      PElemInBuf^.PAType := TN_PointAttr2Type(TypeInd+1);
      TK_RArray(AData) := K_RCreateByTypeName( N_PA2SPTypes[TypeInd], 1, [] );
      SGrid.Invalidate();
    end // if PFieldInBuf^ = nil then // User Parameter is not created, create it
    else
      N_EditRAFrameField( AData, RAFrame );

  end; // with RAFrame, TN_RAEditForm(PrevForm) do

  //***** Special Parameters exist, edit them

//  N_EditRAFrameField( AData, RAFrame );
end; //*** procedure TN_RAFPA2SPEditor.Edit


//****************  TN_RAFPenStyleEditor class methods  ******************

//**************************************** TN_RAFPenStyleEditor.PenStyleGlobAct
// Global Action Proc of Obj for Pen Style Editor
//
function TN_RAFPenStyleEditor.PenStyleGlobAct( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;
begin
  with PFF do
    PPenStyle^ := PFFStyle or (PFFEndCap shl 8) or
                              (PFFLineJoin shl 12) or (PFFType shl 16);

  Result := RAFrame.RAFGlobalActionProc( RAFrame, ActionType );
end; // procedure TN_RAFPenStyleEditor.PenStyleGlobAct

//**************************************** TN_RAFPenStyleEditor.Edit
// Pen Style (Windows Path Drawing Flags) Editor as external Editor
//
function TN_RAFPenStyleEditor.Edit( var AData ): Boolean;
var
  IntFlags: integer;
  OwnerForm: TN_BaseForm;
  NewRAEditForm: TN_RAEditForm;
begin
  Result := False;
  OwnerForm := K_GetOwnerBaseForm( RAFrame );

  PPenStyle := PInteger(@AData); // for changing AData in PenStyleGlobAct
  IntFlags := integer(AData);

  PFF.PFFType     := (IntFlags and $F0000) shr 16;
  PFF.PFFStyle    := (IntFlags and $F);
  PFF.PFFEndCap   := (IntFlags and $F00)  shr 8;
  PFF.PFFLineJoin := (IntFlags and $F000) shr 12;

  NewRAEditForm := N_GetRAEditForm( [], nil, PFF,
                              'TN_PenStyleFields', 'TN_PenStyleFieldsFormDescr',
                                  PenStyleGlobAct, nil, OwnerForm );

  with NewRAEditForm, Mouse.CursorPos do
  begin
    Left := X;
    Top  := Y + 16;
  end;

  NewRAEditForm.Caption := 'Drawing Flags';
  N_PlaceTControl( NewRAEditForm, nil );
  NewRAEditForm.Show();

end; //*** procedure TN_RAFPenStyleEditor.Edit


//****************  TN_RAFTableStrEditor class methods  ******************

//**************************************** TN_RAFTableStrEditor.Edit
// Table of strings Editor as external Editor
//
function TN_RAFTableStrEditor.Edit( var AData ): Boolean;
var
  NewRAEditForm: TN_RAEditForm;
begin
  Result := False;
  Exit;

  NewRAEditForm := nil;
  NewRAEditForm.Caption := 'Table of Strings';
  N_PlaceTControl( NewRAEditForm, nil );
  NewRAEditForm.Show();
end; //*** procedure TN_RAFTableStrEditor.Edit


//****************  TN_RAFMSScalEditor class methods  ******************

//********************************************** TN_RAFMSScalEditor.GetText ***
// overloaded variant for Measured Size Scalar Viewer and Editor
//
// Return Scalar Size and Unit as string
//
function TN_RAFMSScalEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
begin
  Result := 'Not Defined';
  if not N_SameDTCodes( RAFC.CDType, K_GetTypeCodeSafe( 'TN_MScalSize' ) ) then Exit; // error

  with TN_MScalSize(AData) do
    Result := Format( '%g %s', [N_FToDbl(MSSValue), N_MSizeUnitNames[Ord(MSUnit)] ] );
end; // function TN_RAFMSScalEditor.GetText

//*************************************** TN_RAFMSScalEditor.ConvFromString ***
// Finish Editing - convert value and units type From String
// (is used as RAFrame.OnInlineEditorExit procedure of object)
//
procedure TN_RAFMSScalEditor.ConvFromString( AResultText: string; var AData );
begin
  with TN_MScalSize(AData) do
  begin
    MSSValue := N_ScanFloat( AResultText );
    MSUnit   := N_StrToMSizeUnit( AResultText );
  end; // with TN_MScalSize(AData) do

  RAFrame.AddChangeDataFlag;
end; // procedure TN_RAFMSScalEditor.ConvFromString

//************************************************* TN_RAFMSScalEditor.Edit ***
// Measured Size Editor as external Editor
//
function TN_RAFMSScalEditor.Edit( var AData ) : Boolean;
var
  Str: string;
begin
  Result := False;
  with RAFrame do
  begin
    OnInlineEditorExit := ConvFromString;
//    PCurData := TN_PMScalSize(@AData);
    Str := GetText( AData, RAFCArray[CurLCol], 0, 0 ); // only first two params are used
    CallInlineTextEditor( Str );
  end; // with RAFrame do
end; //*** procedure TN_RAFMSScalEditor.Edit


//****************  TN_RAFMSPointEditor class methods  ******************

//********************************************* TN_RAFMSPointEditor.GetText ***
// overloaded variant for Measured Size Point Viewer and Editor
//
// Return Point Sizes and Units as string
//
function TN_RAFMSPointEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
begin
  Result := 'Not Defined';
  if not N_SameDTCodes( RAFC.CDType, K_GetTypeCodeSafe( 'TN_MPointSize' ) ) then Exit; // error

  with TN_MPointSize(AData) do
  begin
    if MSXUnit = MSYUnit then // Same Units
      Result := Format( '%g %g %s', [N_FToDbl(MSPValue.X),  N_FToDbl(MSPValue.Y),
                                     N_MSizeUnitNames[Ord(MSYUnit)] ] )
    else // Not same Units, show them all
      Result := Format( '%g %s, %g %s', [
        N_FToDbl(MSPValue.X),   N_MSizeUnitNames[Ord(MSXUnit)],
        N_FToDbl(MSPValue.Y),    N_MSizeUnitNames[Ord(MSYUnit)] ] )
  end; // with TN_MPointSize(AData) do

end; // function TN_RAFMSPointEditor.GetText

//************************************** TN_RAFMSPointEditor.ConvFromString ***
// Finish Editing - convert value and units type From String
// (is used as RAFrame.OnInlineEditorExit procedure of object)
//
procedure TN_RAFMSPointEditor.ConvFromString( AResultText: string; var AData );
var
  RetCode: integer;
  SL: TStringList;
begin
  with TN_MPointSize(Adata) do
  begin
    FillChar( Adata, SizeOf(TN_MPointSize), 0 ); // Set Default values

    SL := TStringList.Create();
    SL.Delimiter := ' ';
    SL.DelimitedText := AResultText; // Split AResultText by tokens

    if SL.Count <= 2 then // Units and some values are not given (a precaution)
    begin
      MSPValue := N_ScanFPoint( AResultText );
    end else if SL.Count = 3 then // Same Unit (last token) for All Rect Values
    begin
      MSPValue := N_ScanFPoint( AResultText );
      MSXUnit  := N_StrToMSizeUnit( SL.Strings[2] );
      MSYUnit  := MSXUnit;
    end else // each value has own Unit
    begin
      Val( SL.Strings[0], MSPValue.X, RetCode );
      MSXUnit := N_StrToMSizeUnit( SL.Strings[1] );

      Val( SL.Strings[2], MSPValue.Y, RetCode );
      MSYUnit := N_StrToMSizeUnit( SL.Strings[3] );
    end; // else // each value has own Unit

    SL.Free;
  end; // with TN_MPointSize(Adata) do

  RAFrame.AddChangeDataFlag;
end; // procedure TN_RAFMSPointEditor.ConvFromString

//************************************************ TN_RAFMSPointEditor.Edit ***
// Measured Size Point Editor as external Editor
//
function TN_RAFMSPointEditor.Edit( var AData ) : Boolean;
var
  Str: string;
begin
  Result := False;
  with RAFrame do
  begin
    OnInlineEditorExit := ConvFromString;
    Str := GetText( AData, RAFCArray[CurLCol], 0, 0 ); // only first two params are used
    CallInlineTextEditor( Str );
  end; // with RAFrame do
end; //*** procedure TN_RAFMSPointEditor.Edit


//****************  TN_RAFMSRectEditor class methods  ******************

//********************************************** TN_RAFMSRectEditor.GetText ***
// overloaded variant for Measured Size Rect Viewer and Editor
//
// Return Rect Sizes and Units as string
//
function TN_RAFMSRectEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
begin
  Result := 'Not Defined';
  if not N_SameDTCodes( RAFC.CDType, K_GetTypeCodeSafe( 'TN_MRectSize' ) ) then Exit; // error

  with TN_MRectSize(AData) do
  begin
    if (MSLeftUnit = MSTopUnit) and
       (MSLeftUnit = MSRightUnit) and
       (MSLeftUnit = MSBottomUnit)  then // All Units are the Same
      Result := Format( '%g %g %g %g  %s', [N_FToDbl(MSRValue.Left),  N_FToDbl(MSRValue.Top),
          N_FToDbl(MSRValue.Right), N_FToDbl(MSRValue.Bottom), N_MSizeUnitNames[Ord(MSBottomUnit)] ] )
    else // Some Units are NOT the same, show them all
      Result := Format( '%g %s, %g %s, %g %s, %g %s', [
        N_FToDbl(MSRValue.Left),   N_MSizeUnitNames[Ord(MSLeftUnit)],
        N_FToDbl(MSRValue.Top),    N_MSizeUnitNames[Ord(MSTopUnit)],
        N_FToDbl(MSRValue.Right),  N_MSizeUnitNames[Ord(MSRightUnit)],
        N_FToDbl(MSRValue.Bottom), N_MSizeUnitNames[Ord(MSBottomUnit)] ] )
  end; // with TN_MRectSize(AData) do

end; // function TN_RAFMSRectEditor.GetText

//*************************************** TN_RAFMSRectEditor.ConvFromString ***
// Finish Editing - convert value and units type From String
// (is used as RAFrame.OnInlineEditorExit procedure of object)
//
procedure TN_RAFMSRectEditor.ConvFromString( AResultText: string; var AData );
var
  RetCode: integer;
  SL: TStringList;
begin
  with TN_MRectSize(Adata) do
  begin
    FillChar( Adata, SizeOf(TN_MRectSize), 0 ); // Set Default values

    SL := TStringList.Create();
    SL.Delimiter := ' ';
    SL.DelimitedText := AResultText; // Split AResultText by tokens

    if SL.Count <= 4 then // Units and some values are not given (a precaution)
    begin
      MSRValue := N_ScanFRect( AResultText );
    end else if SL.Count = 5 then // Same Unit (last token) for All Rect Values
    begin
      MSRValue := N_ScanFRect( AResultText );
      MSLeftUnit   := N_StrToMSizeUnit( SL.Strings[4] );
      MSTopUnit    := MSLeftUnit;
      MSRightUnit  := MSLeftUnit;
      MSBottomUnit := MSLeftUnit;
    end else // each value has own Unit
    begin
      Val( SL.Strings[0], MSRValue.Left, RetCode );
      MSLeftUnit := N_StrToMSizeUnit( SL.Strings[1] );

      Val( SL.Strings[2], MSRValue.Top, RetCode );
      MSTopUnit := N_StrToMSizeUnit( SL.Strings[3] );

      Val( SL.Strings[4], MSRValue.Right, RetCode );
      MSRightUnit := N_StrToMSizeUnit( SL.Strings[5] );

      Val( SL.Strings[6], MSRValue.Bottom, RetCode );
      MSBottomUnit := N_StrToMSizeUnit( SL.Strings[7] );
    end; // else // each value has own Unit

    SL.Free;
  end; // with PCurData^ do

  RAFrame.AddChangeDataFlag;
end; // procedure TN_RAFMSRectEditor.ConvFromString

//************************************************* TN_RAFMSRectEditor.Edit ***
// Measured Size Rect Editor as external Editor
//
function TN_RAFMSRectEditor.Edit( var AData ) : Boolean;
var
  Str: string;
begin
  Result := False;
  with RAFrame do
  begin
    OnInlineEditorExit := ConvFromString;
    Str := GetText( AData, RAFCArray[CurLCol], 0, 0 ); // only first two params are used
    CallInlineTextEditor( Str );
  end; // with RAFrame do
end; //*** procedure TN_RAFMSRectEditor.Edit


//********************************  Global procedures  ********************

//****************************************************** N_CreateRAEditForm ***
// Create and return new instance TN_RAEditForm
// (whithout any particular tuning)
//
function N_CreateRAEditForm( AOwner: TN_BaseForm ): TN_RAEditForm;
begin
  Result := TN_RAEditForm.Create( Application );
  with Result do
  begin
//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    FRRAControl := TK_FRAData.Create( RAEditFrame );
    with FRRAControl do
    begin
      SetOnDataChange( SetDataChangedFlag ); // set OnDataChange event handler
      SetOnClearDataChange( ClearDataChangedFlag ); // set OnClearDataChange event handler
    end;

    ClearDataChangedFlag();
    RedrawRFrame := True;
    miDebug.Visible := (medfDebInInterface in N_MEGlobObj.MEDebFlags);

    N_CompPictViewerActions[0] := aCompViewPictFromFile;

    N_CompTextViewerActions[0] := aCompViewInExtBrowser;
    N_CompTextViewerActions[1] := aCompViewInMSWord;
    N_CompTextViewerActions[2] := aCompViewAsSrcText;
  end; // with Result do
end; // function N_CreateRAEditForm

//*******************************************  N_GetRAEditForm  ******
// Get RAEditForm (Create it if neeeded or ReInitialize)
//
// ARAFlags       - Editing mode flags
// PRAEditForm    - pointer to existing RAEditForm, pointer to nil or nil
// ARecord        - Record to be Edited (of type ATypeName)
// ATypeName      - Pascal (same as SPL) ARecord Type Name (e.g. 'TN_CPanel')
//                  (not used for not zero RArray and VArray fields)
// AFormDescrName - Form Description Name (not needed for Components)
// AGAProcOfObj   - Global ProcOfObject
// AUDObj         - UDRArray or UDComp with ARecord to Edit or nil
// AOwner         - Owner of new RAEditForm
//                  (is needed only if new instance of PRAEditForm is created)
//
function N_GetRAEditForm( ARAFlags: TN_RAEditFlags; PRAEditForm: TN_PRAEditForm;
                          var ARecord; ATypeName: string; AFormDescrName: string;
                          AGAProcOfObj: TK_RAFGlobalActionProc;
                      AUDObj: TK_UDRArray; AOwner: TN_BaseForm ): TN_RAEditForm;
var
  CurLeft, CurTop: integer;
  IsArray: boolean;
  NewRAEditForm: TN_RAEditForm;
  PCompVis: TN_PRCompVis;
begin
  CurLeft := -10000; // to check if CurLeft was set from previous Form
  CurTop  := 0;      // to avoid warning

  // Check if previous RAEditForm (PRAEditForm^) should be closed

  if PRAEditForm <> nil then
  begin
    if PRAEditForm^ <> nil then
    begin
      if not (AOwner is TN_RAEditForm) then // Save position and close Form
      begin
        CurLeft := PRAEditForm^.Left;
        CurTop  := PRAEditForm^.Top;
        PRAEditForm^.Close();
      end;
    end;
  end; // if PRAEditForm <> nil then

  NewRAEditForm := N_CreateRAEditForm( AOwner );

  if PRAEditForm <> nil then
  begin
    PRAEditForm^ := NewRAEditForm;
    // PRAEditForm^ variable should be cleared in NewRAEditForm.OnClose handler:
    NewRAEditForm.AddClearVarAction( PRAEditForm, nil, 'Clear_PRAEditForm' );
  end; // if PRAEditForm <> nil then

  Result := NewRAEditForm;
  with Result do // tune just created Form
  begin
    // set Form Fields
    if CurLeft <> -10000 then // in CurLeft,Top vars are closed Form Position
    begin
      Left := CurLeft;
      Top := CurTop;
    end;

    RAEditFrame.OnBeforeFramePopup := PrepPopupMenu;

    //********************** Hide all Actions, that can be invisible

    CompMMI.Visible := False; // Comp Main Menu Item

    aCompSetParams.Visible    := False;
    aCompUserParams.Visible   := False;
    aCompExportParams.Visible := False;
    aCompCommonParams.Visible := False;
    aCompLayoutParams.Visible := False;
    aCompCoordsParams.Visible := False;
    aCompPanelParams.Visible  := False;
    aCompIndivParams.Visible  := False;

    aEdCreateSetParams.Visible   := False;
    aEdCreateUserParams.Visible  := False;
    aEdCreatePanelParams.Visible := False;
    aEdCreateExportParams.Visible   := False;

    aDebToggleStatDyn.Visible := False;

    tbIndEdit1.Visible    := False;
    tbIndEdit2.Visible    := False;
    tbIndFieldEd1.Visible := False;

    aAEEditAs1DRArray.Visible := False;
    aAEEditAs2DRArray.Visible := False;

    //***** Common settings

    RecordUObj := AUDObj;
    RAEditFrame.RLSData.RUDRArray := AUDObj;

    //***** Tune Form differently if AUDObj is a Component or Not

    if (AUDObj is TN_UDCompBase) and (@AUDObj.R = @ARecord) then // some Component
    begin
      //***** Common part for Both Visual and NonVisual Components

      CompMMI.Visible := True; // Comp Main Menu Item

      CompTypeName := ATypeName;

      CompStructType := TN_CompStructType( N_MemIniToInt( 'N_RaEdF',
                                           'StructType', Ord(cstIndParams) ) );
      aCompIndivParams.Visible  := True;
      aDebToggleStatDyn.Visible := True;

      if AUDObj is TN_UDTable then tbIndEdit1.Action := aIESetTableSize;

      with TN_UDCompBase(AUDObj).PSP()^ do
      begin
        if CSetParams.ALength() > 0             then aCompSetParams.Visible  := True;
        if CCompBase.CBUserParams.ALength() > 0 then aCompUserParams.Visible := True;
        if CCompBase.CBExpParams.ALength()  > 0 then aCompExportParams.Visible  := True;
      end;

      aCompCommonParams.Visible := True;

      if  (CompStructType = cstNotAComp) or
         ((CompStructType = cstSetParams)  and not aCompSetParams.Visible)  or
         ((CompStructType = cstUserParams) and not aCompUserParams.Visible) or
         ((CompStructType = cstExpParams)  and not aCompExportParams.Visible)   then
        CompStructType := cstIndParams;

      TuneViewers(); // Set Component Viewers Visibility, Captions and Image Indexes

      //***** Specific code for Visual and NonVisual Components

      if AUDObj is TN_UDCompVis then // Visual Component
      begin
        PCompVis := TN_UDCompVis(AUDObj).PSP();

        aCompCoordsParams.Visible := True;

        if PCompVis^.CPanel.ALength() > 0 then
          aCompPanelParams.Visible := True
        else
          if CompStructType = cstPanel then CompStructType := cstIndParams;

        if (AUDObj is TN_UDPanel) and (CompStructType = cstIndParams) then
          CompStructType := cstPanel;

        aEdCreatePanelParams.Visible := not aCompPanelParams.Visible;
      end else // AUDObj is NOT Visual Component
      begin
        aCompViewExecute.Visible := True;
        aEdCreatePanelParams.Visible := False;

        if (CompStructType >= cstLayout) and (CompStructType <= cstPanel) then
          CompStructType := cstIndParams;
      end;

      //***** Special settings for CompBase and Panel Components
      //      (they have no Individual Params)

      if AUDObj.CI() = N_UDCompBaseCI then
      begin
        if CompStructType = cstIndParams then CompStructType := cstUserParams;
        aCompIndivParams.Visible := False;
      end;

      if AUDObj.CI() = N_UDPanelCI then
      begin
        if CompStructType = cstIndParams then CompStructType := cstCoords;
        aCompIndivParams.Visible := False;
      end;

      //***** Check if some individual Actions should be Visible

      aSEImportUDTable.Visible := False;
      aSEExportUDTable.Visible := False;
      if AUDObj is TN_UDTable then // UDTable Component
      begin
        aSEImportUDTable.Visible := True;
        aSEExportUDTable.Visible := True;
      end;

      //***** Set Create ... Comp Params Actions visibility (Except Panel)
      aEdCreateSetParams.Visible  := not aCompSetParams.Visible;
      aEdCreateUserParams.Visible := not aCompUserParams.Visible;
      aEdCreateExportParams.Visible  := not aCompExportParams.Visible;

      StaticParams := False;            // set Editing Static Params and
      aDebToggleStatDynExecute( nil );  // rebuild Frame by FormDescrInd
    end else //***************************** AUDObj is not a Component
    begin
      //***** Store info about root Record (that should be edited)

      N_s := ATypeName; // debug
      PRecord        := @ARecord;
      RecordTypeName := ATypeName;
      RecordRAFlags  := ARAFlags;
      RecordTypeCode := N_GetSPLTypeCode( RecordRAFlags, RecordTypeName );
      N_SPLT := RecordTypeCode; // debug

      //***** Set PRecord to @UDRArray.P if VArray is TK_UDRArray

      if (RecordTypeCode.D.TFlags and K_ffVArray) <> 0 then // is VArray
      begin
        if TObject(ARecord) is TK_UDRArray then // UDRArray form of VArray
          PRecord := @(TK_UDRArray(ARecord).R);
      end;

      ToolBarComp.Visible := False;
      RAEditFrame.Height := RAEditFrame.Height + ToolBarComp.Height;
      IsArray := ( (RecordTypeCode.D.TFlags and K_ffArray)  <> 0 ) or
                 ( (RecordTypeCode.D.TFlags and K_ffVArray) <> 0 );
      PrepToolBarArray( IsArray );

      InitByTypeName( AFormDescrName );
      CompStructType := cstNotAComp; // can be used as "not a Component" flag
    end; // else - not a component

    //***** Set GlobalAction Handlers:

    RaEdGAProcOfObj := AGAProcOfObj;

    RAEditFrame.OnDataApply   := OnDataApply;
    RAEditFrame.OnCancelToAll := OnCancelToAll; // works not correct for K_... form, called in modal mode?
    RAEditFrame.OnOKToAll     := OnOKToAll;     // works not correct for K_... form, called in modal mode?

//    RAEditFrame.RebuildGridExecute( nil ); //?

    // если RAEditFrame имеет больше двух колонок и фрейм не помещается на экране,
    // то RAEditFrame.Height неправильно вычисляется (оказывается больше чем нужно)
    // и в результате кнопки налезают на последнюю строку матрицы

//    if RAEditFrame.Height > 640 then RAEditFrame.Height := 640;
//    AUDObj.SetChangedSubTreeFlag();
    if AUDObj <> nil then K_SetChangeSubTreeFlags( AUDObj );
    
{
    //***** Fill RAEditFunc Context
    Ind := K_GEFuncs.IndexOfName( 'N_RAEditForm' );
    if Ind >= 0 then
    with TN_PRAEditFuncCont(K_GEFPConts.Items[Ind])^ do
    begin
      GEDummy1 := 1234; // debug
    end;
}
  end; // with Result do
end; // end of function N_GetRAEditForm

//*********************************************  N_CallRAEditForm  ********
// Standard Function that creates N_RAEditForm and is registered by K_RegGEFunc
// under 'N_RAEditForm' name and uses N_RAEditFuncCont global context
//
// AData      - variable to edit
// APDContext - Pointer to Dynamic Context, that begins
//              by TK_RAEditFuncCont

function N_CallRAEditForm( var AData; APDContext: Pointer ): Boolean;
begin
  Result := False;
  with TN_PRAEdit2DFuncCont(APDContext)^ do
    N_EditRAFrameField( AData, RAEDFC.FRAFrame );
end; // function N_CallRAEditForm

//*********************************************  N_EditRAFrameField  ********
// Edit current field of given ARAFrame using TN_RAEditForm.
// If AData is RArray of one element, edit this element (not RArray).
// Is used in: TN_RAFRAEditEditor, TN_RAFUserParamEditor and N_CallRAEditForm
//
procedure N_EditRAFrameField( var AData; ARAFrame: TK_FrameRAEdit );
var
  PRAFC: TK_PRAFColumn;
  FormDescrName, CurFieldTypeName: string;
  NewRAEditForm: TN_RAEditForm;
  PrevForm: TN_BaseForm;
begin
  with ARAFrame do
  begin
    if Owner is TN_BaseForm then PrevForm := TN_BaseForm(Owner)
                            else PrevForm := nil;
    PRAFC := @RAFCArray[CurLCol];

    with PRAFC^ do
      FormDescrName := VEArray[CVEInd].EParams;

    if Length(FormDescrName) <= 4 then FormDescrName := '';

    CurFieldTypeName := K_GetExecTypeName( PRAFC^.CDType.All );
    
//    NewRAEditForm := N_GetRAEditForm( [], nil,
    NewRAEditForm := N_GetRAEditForm( N_GetRAFlags( PRAFC^.CDType ), nil,
                                      AData, CurFieldTypeName, FormDescrName,
                                      RAFGlobalActionProc, RLSData.RUDRArray, PrevForm );

    NewRAEditForm.RAEditFrame.DataPath := GetCurCellDataPath();

    with NewRAEditForm, Mouse.CursorPos do
    begin
      Left := X;
      Top  := Y + 16;
    end;

    NewRAEditForm.Caption := PRAFC^.Caption;
    N_PlaceTControl( NewRAEditForm, nil );
    NewRAEditForm.Show();
  end; // with ARAFrame do
end; // function N_EditRAFrameField


Initialization
  // External Editors:
  K_RegRAFEditor( 'NRAFRAEditEditor',    TN_RAFRAEditEditor );
//  K_RegRAFEditor( 'RAFVArrayEditor',     TN_RAFVArrayEditor );
  K_RegRAFEditor( 'NRAFUDRefEditor',     TN_RAFUDRefEditor );
  K_RegRAFEditor( 'NRAFUserParamEditor', TN_RAFUserParamEditor );
  K_RegRAFEditor( 'NRAFCharCodesEditor', TN_RAFCharCodesEditor );
  K_RegRAFEditor( 'NRAFValsInStrEditor', TN_RAFValsInStrEditor );
  K_RegRAFEditor( 'NRAFPA2SPEditor',     TN_RAFPA2SPEditor );
  K_RegRAFEditor( 'NRAFPenStyleEditor',  TN_RAFPenStyleEditor );
  K_RegRAFEditor( 'NRAFTableStrEditor',  TN_RAFTableStrEditor );
  K_RegRAFEditor( 'NRAFMSScalEditor',    TN_RAFMSScalEditor );
  K_RegRAFEditor( 'NRAFMSPointEditor',   TN_RAFMSPointEditor );
  K_RegRAFEditor( 'NRAFMSRectEditor',    TN_RAFMSRectEditor );

  // External Viewers:
  K_RegRAFViewer( 'NRAFRAEditEditor',    TN_RAFRAEditEditor );
  K_RegRAFViewer( 'NRAFUserParamEditor', TN_RAFUserParamEditor );
  K_RegRAFViewer( 'NRAFCharCodesEditor', TN_RAFCharCodesEditor );
  K_RegRAFViewer( 'NRAFValsInStrEditor', TN_RAFValsInStrEditor );
  K_RegRAFViewer( 'NRAFPA2SPEditor',     TN_RAFPA2SPEditor );
  K_RegRAFViewer( 'NRAFPenStyleEditor',  TN_RAFPenStyleEditor );
  K_RegRAFViewer( 'NRAFMSScalEditor',    TN_RAFMSScalEditor );
  K_RegRAFViewer( 'NRAFMSPointEditor',   TN_RAFMSPointEditor );
  K_RegRAFViewer( 'NRAFMSRectEditor',    TN_RAFMSRectEditor );

  K_RegGEFunc( 'N_RAEditForm', N_CallRAEditForm, @N_RAEditFuncCont );

end.
