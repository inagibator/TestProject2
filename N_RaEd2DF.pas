unit N_RaEd2DF;
// Form for Editing 2D RArrays using K_FrRAEdit

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  ComCtrls, Menus, ToolWin, ActnList, StdCtrls,
  K_SCript1, K_FrRAEdit,
  N_Types, N_Lib1, N_Lib2, N_BaseF;


type TN_RAEdit2DForm = class( TN_BaseForm )
    bnOK: TButton;
    bnCancel: TButton;
    bnApply: TButton;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    ToolBar1: TToolBar;
    File1: TMenuItem;
    ToolButton1: TToolButton;
    RAEditFrame: TK_FrameRAEdit;
    StatusBar:   TStatusBar;

    procedure bnApplyClick  ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure bnOKClick     ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

  public
    DataWasChanged:  boolean;
    FRRAControl:     TK_FRAData;
    RaEdGAProcOfObj: TK_RAFGlobalActionProc; // External Global Action

    procedure OnDataApply          ();
    procedure OnCancelToAll        ();
    procedure OnOKToAll            ();
    procedure SetDataChangedFlag   ();
    procedure ClearDataChangedFlag ();

    procedure PrepPopupMenu ();
    procedure ShowString    ( AStr: string );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_RAEdit2DForm = class( TN_BaseForm )

//**************** Other Objects ******************************

type TN_RAEdit2DFuncCont = record // TN_PRAEdit2DForm as Glob Func Context
  RAEDFC: TK_RAEditFuncCont; // Standard context (should be the first field!)
  GEDummy1: integer;
//  GEFUObj: TK_UDRArray;      // UObj to be edited
//  GEFDataTypeName: string;   // Data Record TypeName (e.g. TN_RPanel)
end; // type TN_RAEditFuncCont = record
type TN_PRAEdit2DFuncCont = ^TN_RAEdit2DFuncCont;

    //*********** Global Procedures  *****************************

//**************** External Editors(Viewers) ******************************

type TN_RAFRAEd2DEditor = class( TK_RAFEditor ) // RAEditForm as external Editor(Viewer)
  function  GetText ( var AData; var RAFC: TK_RAFColumn; ACol, ARow: Integer;
                                  PHTextPos: Pointer = nil ): string; override;
  function Edit ( var AData ): Boolean; override;
end; //*** type TN_RAFRAEd2DEditor = class( TK_RAFEditor )

function  N_CreateRAEdit2DForm ( AOwner: TN_BaseForm ): TN_RAEdit2DForm;

function N_GetRAEdit2DForm( ARAFlags: TN_RAEditFlags; var A2DRArray: TK_RArray;
                      AFormDescrName: string; AGAProcOfObj: TK_RAFGlobalActionProc;
                      AUDObj: TK_UDRArray; AOwner: TN_BaseForm ): TN_RAEdit2DForm;

procedure N_EditRAFr2DField  ( var AData; ARAFrame: TK_FrameRAEdit );
function  N_CallRAEdit2DForm ( var AData; APDContext: Pointer ): Boolean;


var
  N_RAEdit2DFuncCont: TN_RAEdit2DFuncCont; // used in N_CallRAEdit2DForm

implementation
uses
  K_CLib,
  N_Lib0, N_RAEditF, N_Comp2;
{$R *.dfm}

//****************  TN_RAEdit2DForm class handlers  ******************

procedure TN_RAEdit2DForm.bnApplyClick( Sender: TObject );
// Change Record content,
begin
  FRRAControl.StoreToSData; // Change source record
  ShowString( '' );

  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaApplyToAll );
end; // procedure TN_RAEdit2DForm.bnApplyClick

procedure TN_RAEdit2DForm.bnCancelClick( Sender: TObject );
// close Self without changing Data
begin
  if N_KeyIsDown( VK_SHIFT ) then
    OnCancelToAll()
  else
    Close();
end; // procedure TN_RAEdit2DForm.bnCancelClick

procedure TN_RAEdit2DForm.bnOKClick( Sender: TObject );
// Call bnApplyClick and Close Self
begin
  bnApplyClick( Sender );

  if N_KeyIsDown( VK_SHIFT) then
    OnOkToAll()
  else
    Close();

  ModalResult := mrOK;
end; // procedure TN_RAEdit2DForm.bnOKClick

procedure TN_RAEdit2DForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_RAEdit2DForm.FormClose


//*********************** TN_RAEdit2DForm public methods  ***************

procedure TN_RAEdit2DForm.OnDataApply();
// RAFrame OnApply handler
begin
  bnApplyClick( nil );
end; // procedure TN_RAEdit2DForm.OnDataApply();

procedure TN_RAEdit2DForm.OnCancelToAll();
// RAFrame OnCancelToAll handler
begin
  Close(); // Close should be executed before RaEdGAProcOfObj !
  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaCancelToAll );
end; // procedure TN_RAEdit2DForm.OnCancelToAll

procedure TN_RAEdit2DForm.OnOKToAll();
// RAFrame OnOKToAll handler
begin
  bnApplyClick( nil );
  if Assigned(RaEdGAProcOfObj) then RaEdGAProcOfObj( Self, K_fgaOKToAll );
  Close(); // Close should be executed before RaEdGAProcOfObj ! //why???
end; // procedure TN_RAEdit2DForm.OnOKToAll

procedure TN_RAEdit2DForm.SetDataChangedFlag();
// update Self Controls after Data was changed
begin
  DataWasChanged := true;
end; // procedure TN_RAEdit2DForm.SetDataChangedFlag

procedure TN_RAEdit2DForm.ClearDataChangedFlag();
// set Self Controls as if Data was not changed yet
begin
  DataWasChanged := false;
end; // procedure TN_RAEdit2DForm.ClearDataChangedFlag

procedure TN_RAEdit2DForm.PrepPopupMenu();
// Prepare PopupMenu Items for current Field
//
// Not really implemented!
begin
  with RAEditFrame do
  begin
//    SetLength( PopupActionGroups, 5 );
//    SetLength( PopupActionGroups[1], 10 ); // prelimenary value

{
var
  FreeAInd, FreeGInd: integer;
  CurFieldInfo: TN_CurRAFrFieldInfo;

  N_GetCurRAFrFieldInfo( RAEditFrame, @CurFieldInfo );

    FreeGInd := 1; // Group Index =0 is reserved for Ext. Editors defined in FormDescr
    FreeAInd := 0;
    if CurFieldInfo.CurPRArray <> nil then // current field is an RArray, Set RArray Related Actions
    begin
      PopupActionGroups[FreeGInd][FreeAInd] := aSESetRArraySize;   Inc(FreeAInd);
      PopupActionGroups[FreeGInd][FreeAInd] := aSESet2DRArraySize; Inc(FreeAInd);
      SetLength( PopupActionGroups[FreeGInd], FreeAInd );
    end; // if PCurRArrayField <> nil then // current field is an RArray

    SetLength( PopupActionGroups, FreeGInd+1 );
}
  end; // with RAEditFrame do
end; // procedure TN_RAEdit2DForm.PrepPopupMenu

procedure TN_RAEdit2DForm.ShowString( AStr: string );
// Show given string AStr in StatusBar
begin
  StatusBar.SimpleText := AStr;
end; // procedure TN_RAEdit2DForm.ShowString

//***********************************  TN_RAEdit2DForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_RAEdit2DForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_RAEdit2DForm.CurStateToMemIni

//***********************************  TN_RAEdit2DForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_RAEdit2DForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_RAEdit2DForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//************* External Editors and related procedures *********************

//****************  TN_RAFRAEd2DEditor class methods  ******************

//**************************************** TN_RAFRAEd2DEditor.GetText
// For TN_TaCell field return TN_TaCell.TCMText
//
function TN_RAFRAEd2DEditor.GetText( var AData; var RAFC: TK_RAFColumn;
                             ACol, ARow: Integer; PHTextPos: Pointer ): string;
var
  CurTypeName: string;
begin
  CurTypeName := K_GetExecTypeName( RAFC.CDType.All );

  if CurTypeName = 'TN_TaCell' then
    Result := TN_PTaCell(@AData)^.TCMText
  else
    Result := Inherited GetText( AData, RAFC, ACol, ARow, PHTextPos );
end; // function TN_RAFRAEd2DEditor.GetText

//**************************************** TN_RAFRAEd2DEditor.Edit
// RAEditForm as external Editor
//
function TN_RAFRAEd2DEditor.Edit( var AData ): Boolean;
begin
  Result := False; // "AData were not changed yet" flag
  N_EditRAFr2DField( AData, RAFrame );
end; //*** procedure TN_RAFRAEd2DEditor.Edit


//********************************************  N_CreateRAEdit2DForm  ******
// Create and return new instance of TN_RAEdit2DForm
// (whithout any particular tuning)
// AOwner - Owner of created Form
//
function N_CreateRAEdit2DForm( AOwner: TN_BaseForm ): TN_RAEdit2DForm;
begin
  Result := TN_RAEdit2DForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    FRRAControl := TK_FRAData.Create( RAEditFrame );
    with FRRAControl do
    begin
      SetOnDataChange( SetDataChangedFlag ); // set OnDataChange event handler
      SetOnClearDataChange( ClearDataChangedFlag ); // set OnClearDataChange event handler
    end;

    ClearDataChangedFlag();
{
    RAEditFrame.OnBeforeFramePopup := PrepPopupMenu;

//    N_s := K_GetExecTypeName( A2DRArray.FEType.All ); // debug
    FRRAControl.PrepMatrixFrame1( [],
            [K_ramColVertical,K_ramShowLRowNumbers,K_ramSkipColsMark,
             K_ramRowEditing,K_ramRowChangeNum,K_ramRowAutoChangeNum,
             K_ramShowLColNumbers,K_ramColEditing,K_ramColChangeNum,
             K_ramColAutoChangeNum], A2DRArray, A2DRArray.ElemType,
             'Table Cells' ); //, @FRRAControl.CDescr );


    //***** Set GlobalAction Handlers:
    RaEdGAProcOfObj := AGAProcOfObj;

    RAEditFrame.OnDataApply   := OnDataApply;
    RAEditFrame.OnCancelToAll := OnCancelToAll;
    RAEditFrame.OnOKToAll     := OnOKToAll;

    RAEditFrame.RebuildGridExecute( nil );

    //***** Fill RAEditFunc Context
    Ind := K_GEFuncs.IndexOfName( 'N_RAEditForm' );
    if Ind >= 0 then
    with TN_PRAEditFuncCont(K_GEFPConts.Items[Ind])^ do
    begin
      GEFUObj := nil;
      GEFDataTypeName := 'TN_TaCell';
    end;
}
  end; // with Result do
end; // function N_CreateRAEdit2DForm

//*******************************************  N_GetRAEdit2DForm  ******
// Get TN_RAEdit2DForm (Create and Initialize)
//
// ARAFlags       - Editing mode flags (now not used)
// ARecord        - Record to be Edited (of type ATypeName)
// ATypeName      - Pascal (same as SPL) ARecord Type Name (e.g. 'TN_CPanel')
// AUDObj         - UDRArray or UDComp with ARecord to Edit
// AFormDescrName - Form Description Name (not needed for components)
// AOwner         - Owner of new RAEdit2DForm
//                  (is needed only if new instance of PRAEditForm is created)
//
function N_GetRAEdit2DForm( ARAFlags: TN_RAEditFlags; var A2DRArray: TK_RArray;
                      AFormDescrName: string; AGAProcOfObj: TK_RAFGlobalActionProc;
                      AUDObj: TK_UDRArray; AOwner: TN_BaseForm ): TN_RAEdit2DForm;
begin
  Result := N_CreateRAEdit2DForm( AOwner );
  with Result do
  begin
    RAEditFrame.OnBeforeFramePopup := PrepPopupMenu;
    RAEditFrame.RLSData.RUDRArray := AUDObj;

{ // Prep Frame without FormDescription:
    FRRAControl.PrepMatrixFrame1( [], 
            [K_ramColVertical,K_ramShowLRowNumbers,K_ramSkipColsMark,
             K_ramRowEditing,K_ramRowChangeNum,K_ramRowAutoChangeNum,
             K_ramShowLColNumbers,K_ramColEditing,K_ramColChangeNum,
             K_ramColAutoChangeNum], A2DRArray, A2DRArray.ElemType,
             'Table Cells' );
}
    FRRAControl.PrepFrameMatrixByFDTypeName( [],
            [K_ramColVertical,K_ramShowLRowNumbers,K_ramSkipColsMark,
             K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum,
             K_ramShowLColNumbers,K_ramColChangeOrder,K_ramColChangeNum,
             K_ramColAutoChangeNum], A2DRArray, A2DRArray.ElemType,
             '?!?', AFormDescrName );

    //***** Set GlobalAction Handlers:
    RaEdGAProcOfObj := AGAProcOfObj;
    RAEditFrame.OnDataApply   := OnDataApply;
    RAEditFrame.OnCancelToAll := OnCancelToAll;
    RAEditFrame.OnOKToAll     := OnOKToAll;

    RAEditFrame.RebuildGridExecute( nil );
  end; // with Result do
end; // end of function N_GetRAEdit2DForm

//*********************************************  N_EditRAFr2DField  ********
// Edit current RArray field of given ARAFrame using TN_RAEdit2DForm,
// is used in External Editor TN_RAFRAEd2DEditor and in N_CallRAEdit2DForm
//
procedure N_EditRAFr2DField( var AData; ARAFrame: TK_FrameRAEdit );
var
  PRAFC: TK_PRAFColumn;
  FormDescrName: string;
  NewRAEdit2DForm: TN_RAEdit2DForm;
  PrevForm: TN_BaseForm;
  CurFieldInfo: TN_CurRAFrFieldInfo;
begin
//  N_RA := TK_RArray(AData); // debug
//  N_s := K_GetExecTypeName( N_RA.FEType.All ); // debug
  N_GetCurRAFrFieldInfo( ARAFrame, @CurFieldInfo );

  if CurFieldInfo.CurPRArray = nil then Exit; // Current Field is not RArray!

  with ARAFrame do
  begin
    if Owner is TN_BaseForm then PrevForm := TN_BaseForm(Owner)
                            else PrevForm := nil;
    PRAFC := @RAFCArray[CurLCol];

    with PRAFC^ do
      FormDescrName := VEArray[CVEInd].EParams;

    if Length(FormDescrName) <= 4 then FormDescrName := '';

    NewRAEdit2DForm := N_GetRAEdit2DForm( N_GetRAFlags( TK_RArray(AData).FEType ),
                               TK_RArray(AData), FormDescrName, RAFGlobalActionProc,
                                                    RLSData.RUDRArray, PrevForm );

    NewRAEdit2DForm.RAEditFrame.DataPath := GetCurCellDataPath();

    with NewRAEdit2DForm, Mouse.CursorPos do
    begin
      Left := X;
      Top  := Y + 16;
    end;

    NewRAEdit2DForm.Caption := PRAFC^.Caption;
    N_PlaceTControl( NewRAEdit2DForm, nil );
    NewRAEdit2DForm.Show();
  end; // with ARAFrame do
end; // function N_EditRAFr2DField

//*********************************************  N_CallRAEdit2DForm  ********
// Standard Function that creates N_RAEdit2DForm and is registered by K_RegGEFunc
// under 'N_RAEdit2DForm' name and uses N_RAEdit2DFuncCont global context
//
// AData      - variable to edit
// APDContext - Pointer to Dynamic Context, that begins
//              by TK_RAEditFuncCont
//
function N_CallRAEdit2DForm( var AData; APDContext: Pointer ): Boolean;
begin
  Result := False;
  with TN_PRAEdit2DFuncCont(APDContext)^ do
    N_EditRAFr2DField( AData, RAEDFC.FRAFrame );
{
var
  FormDescrName: string;
  PRAEdit2DFC: TN_PRAEdit2DFuncCont;
  PRAFC: TK_PRAFColumn;
  NewRAEdit2DForm: TN_RAEdit2DForm;
//  OwnerForm: TN_BaseForm;
begin
  PRAEdit2DFC := TN_PRAEdit2DFuncCont(APDContext);
  with PRAEdit2DFC^ do
  begin
    with RAEDFC.FRAFrame do
      PRAFC := @RAFCArray[CurLCol];

//    OwnerForm := RAEDFC.FOwner;
//    if not (OwnerForm is TN_BaseForm) then OwnerForm := nil;

    with PRAFC^ do
      FormDescrName := VEArray[CVEInd].EParams;

    with TN_RAEditForm(RAEDFC.FRAFrame.Owner) do
    begin
      NewRAEdit2DForm := N_CreateRAEdit2DForm( TK_RArray(AData), FormDescrName,
                                      nil, TN_BaseForm(RAEDFC.FRAFrame.Owner) );
//?      NewRAEdit2DForm.RAEditFrame.DataPath := CurFieldFullName;
      N_PlaceTControl( NewRAEdit2DForm, nil );
      NewRAEdit2DForm.Show();
      NewRAEdit2DForm.SetFocus();
    end; // with TN_RAEditForm(PrevForm) do

  end; // with PRAEditFuncCont^ do
}
end; // function N_CallRAEdit2DForm
{
Initialization
  K_RegRAFEditor( 'NRAFRAEd2DEditor',  TN_RAFRAEd2DEditor );

  K_RegGEFunc( 'N_RAEdit2DForm', N_CallRAEdit2DForm, @N_RAEdit2DFuncCont );
}
end.
