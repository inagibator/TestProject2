unit K_FUDCDCor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ToolWin, ActnList, ImgList, Menus, ExtCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_FrRaEdit, K_Script1, K_FrCSDim2, K_FrCSDim1, K_CSpace,
  K_FSelectUDB, K_UDT1, K_FCSDim, K_FrUDList,
  N_Types, N_BaseF, N_Lib1, K_FrCDCor;

type
  TK_FormUDCDCor = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;

    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;

    ActionList1: TActionList;
    CreateUDCDCor: TAction;
    ApplyUDCDCor: TAction;
    DeleteUDCDCor: TAction;
    CLoseAction    : TAction;
    RenameUDCDCor: TAction;
    ChangePrimCSDim: TAction;

    EdID: TEdit;
    LbID: TLabel;
    Panel1: TPanel;
    FUDList: TK_FrameUDList;
    FrameCDCor: TK_FrameCDCor;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EdPrimCDimName: TEdit;
    EdSecCDimName: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ToolButton2: TToolButton;
    ReplaceSecCDim: TAction;
    Label1: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    N5: TMenuItem;
    Label7: TLabel;
    RebuildAllFrames: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure BtOKClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplyUDCDCorExecute(Sender: TObject);
    procedure CreateUDCDCorExecute(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure CLoseActionExecute(Sender: TObject);
    procedure RenameUDCDCorExecute(Sender: TObject);
    procedure ChangePrimCSDimExecute(Sender: TObject);
    procedure ReplaceSecCDimExecute(Sender: TObject);
    procedure RebuildAllFramesExecute(Sender: TObject);
  private
    { Private declarations }
    IniCaption : string;
    DataSaveModalState : word;
    ProjWasCreated : Boolean;

//    SelShowToolBar : Boolean;
    SelfPrimInds      : TN_IArray;

    CDimAndIndsFilter : TK_UDFilter;
    CDimFilter : TK_UDFilter;

    FormCSDim : TK_FormCSDim;

    GActionType : TK_RAFGlobalAction;

//    procedure PrimUDCSDimReady( Sender : TObject; ActionType : TK_RAFGlobalAction );
    function  PrimUDCSDimReady( Sender : TObject; ActionType: TK_RAFGlobalAction ) : Boolean;
//    function  SelectUDNode( var UDSelectObj : TN_UDBase; SFilter : TK_UDFilter;
//                            SelCaption : string ) : Boolean;
    procedure ShowPrimCSDimEditForm( UpdateInds : Boolean = false );

  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    SelectObjsUDRoot : TN_UDBase;

    CurUDCDimSec   : TK_UDCDim;
    CurUDCDimPrim  : TK_UDCDim;
    CurUDCSDimPrim : TK_UDCSDim;
    CurUDCDCor    : TK_UDCDCor;
    CurUDCDRRoot   : TN_UDBase;


    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
    function  SaveDataToCurUDCDCor : Boolean;
    procedure ShowUDCDCor( UDCDCor : TN_UDBase );
    procedure SetSelectObjsUDRoot( ASelectObjsUDRoot : TN_UDBase );

  end;


function  K_GetFormUDCDCor( AOwner: TN_BaseForm ) : TK_FormUDCDCor;
function  K_EditUDCDCor( UDCDIRel : TK_UDCDCor; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;


var K_UDCDCorEditCont : TK_RAEditFuncCont;
function K_EditUDCDCorFunc( var UDCDCor; PDContext: Pointer ) : Boolean;

implementation

uses Grids, Math, inifiles,
  N_ClassRef, N_ButtonsF,
  K_UDT2, K_Arch, K_RaEdit, K_CLib, K_VFunc, K_FUDRename;

{$R *.dfm}


//***********************************  K_EditUDCDCorFunc
// function which is registered as Code Dimentions Relation Editor
//
function K_EditUDCDCorFunc( var UDCDCor; PDContext: Pointer ) : Boolean;
begin
  with TK_PRAEditFuncCont(PDContext)^ do
  Result := K_EditUDCDCor( TK_UDCDCor(UDCDCor), FOwner,
                                FOnGlobalAction, FNotModalShow );
end; // end of K_EditUDCDCorFunc

//***********************************  K_GetFormUDCDCor
// Get Edit Form
//
function  K_GetFormUDCDCor( AOwner: TN_BaseForm ) : TK_FormUDCDCor;
begin
  Result := TK_FormUDCDCor.Create(Application);
  Result.BaseFormInit( AOwner );
end; // end of K_GetFormUDCDCor

//***********************************  K_EditUDCDCor
// Edit CDims Relation Object
//
function  K_EditUDCDCor( UDCDIRel : TK_UDCDCor; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;
begin
  with K_GetFormUDCDCor( AOwner ) do begin
    CurUDCDCor := UDCDIRel;
//    CurUDCDimSec := TK_UDDCSSpace(CurUDCDCor).GetDCSpace;
//    CurUDCDimPrim := CurUDCDCor.GetDCSSpace.GetDCSpace;
    OnGlobalAction := AOnGlobalAction;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of K_EditUDCDCor

//***********************************  TK_FormUDCDCor.AddChangeDataFlag
// Change COntrols after Data Change
//
procedure TK_FormUDCDCor.AddChangeDataFlag;
begin
  inherited;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  ApplyUDCDCor.Enabled := true;
  DataWasChanged := true;
end; // end of TK_FormUDCDCor.AddChangeDataFlag

//***********************************  TK_FormUDCDCor.ClearChangeDataFlag
// Change Controls after Data Save
//
procedure TK_FormUDCDCor.ClearChangeDataFlag;
begin
//  inherited;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  ApplyUDCDCor.Enabled := false;
  DataWasChanged := false;
  ProjWasCreated := false;
end; // end of TK_FormUDCDCor.ClearChangeDataFlag

//***********************************  TK_FormUDCDCor.FormCreate
// Form Create Handler
//
procedure TK_FormUDCDCor.FormCreate(Sender: TObject);
begin
  inherited;
  ClearChangeDataFlag;
  IniCaption := Caption;

  CDimAndIndsFilter := TK_UDFilter.Create;
  CDimAndIndsFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  CDimAndIndsFilter.AddItem( TK_UDCSDimTypeFilterItem.Create( K_cdrSSet ) );

  CDimFilter := TK_UDFilter.Create;
  CDimFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );

  FrameCDCor.SetOnDataChange ( AddChangeDataFlag );

  FUDList.SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDCorCI ) );
  FUDList.SelCaption := 'Выбор отношения';
  FUDList.SelButtonHint := 'Выбор отношения';
  FUDList.SelShowToolBar := true;
  FUDList.FRUDListRoot := K_CurArchive;
  FUDList.UDObj := nil;
  FUDList.OnUDObjSelect := ShowUDCDCor;

  CurUDCDimSec := nil;
  CurUDCDimPrim := nil;
  CurUDCDCor := nil;

  SelectObjsUDRoot := K_CurArchive;
end; // end of TK_FormUDCDCor.FormCreate

//***********************************  TK_FormUDCDCor.SaveDataIfNeeded
// Test if Data Saveing is needed
//
function TK_FormUDCDCor.SaveDataIfNeeded : Boolean;
var
  res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurUDCDCor then
      res := mrCancel
    else if (res = mrNo) and ProjWasCreated then begin
//      K_DCSpaceProjectionDelete( TK_UDDCSSpace(CurUDCDCor) );
    end;
  end;
  Result := (res <> mrCancel);
end; // end of TK_FormUDCDCor.SaveDataIfNeeded

//***********************************  TK_FormUDCDCor.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCDCor.CurStateToMemIni();
begin
  inherited;
  N_StringsToMemIni ( Name+'CDS', FUDList.PathList );
end; // end of TK_FormUDCDCor.CurStateToMemIni

//***********************************  TK_FormUDCDCor.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCDCor.MemIniToCurState();
begin
  inherited;
  N_MemIniToStrings( Name+'CDS', FUDList.PathList );
end; // end of TK_FormUDCDCor.MemIniToCurState

//***********************************  TK_FormUDCDCor.SaveDataToCurUDCDCor
// Save Data To Relation Object
//
function TK_FormUDCDCor.SaveDataToCurUDCDCor: Boolean;
var
  NInds : TN_IArray;
  Count : Integer;
begin
  FrameCDCor.GetSecCSDim( NInds );
  with CurUDCDCor, R, TK_PCDCorAttrs(PA)^ do begin
    Count := Length(NInds);
    if ChangePrimCSDim.Enabled then begin
      with GetPrimRACSDim do begin
        ASetLength( Count );
        if Count > 0 then
          SetElems( SelfPrimInds[0], false );
      end;
      SecCSDim.ASetLength( Count );
    end;
    if Count > 0 then
      SecCSDim.SetElems( NInds[0], false );
    K_SetRACSDimCDim( SecCSDim, CurUDCDimSec );
    ClearAInfo;
  end;
  ClearChangeDataFlag;
//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
  GActionType := K_fgaOK;
  ResultDataWasChanged := true;
  Result := true;
end; // end of TK_FormUDCDCor.SaveDataToCurUDCDCor

//***********************************  TK_FormUDCDCor.CurStateToMemIni  ******
// Form Show Handler
//
procedure TK_FormUDCDCor.FormShow(Sender: TObject);
begin
  RenameUDCDCor.Enabled := false;
  ApplyUDCDCor.Enabled := false;

  if CurUDCDCor = nil then
    FUDList.InitByPathIndex
  else
    FUDList.AddUDObjToTop( CurUDCDCor );

  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;
  GActionType := K_fgaNone;

end; // end of TK_FormUDCDCor.FormShow

//***********************************  TK_FormUDCDCor.ShowUDCDCor
// Show new Code Dimensions Relation
//
procedure TK_FormUDCDCor.ShowUDCDCor( UDCDCor : TN_UDBase );
var
  PrimRACSDim : TK_RArray;
  Count : Integer;
begin
  if not SaveDataIfNeeded then Exit;
  CurUDCDCor := TK_UDCDCor(UDCDCor);
  RenameUDCDCor.Enabled := true;
  DeleteUDCDCor.Enabled := true;
  Caption := CurUDCDCor.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCDCor.ObjName;
  CurUDCDRRoot := FUDList.UDParent;
  if CurUDCDRRoot = nil then CurUDCDRRoot := CurUDCDCor.Owner;
  with CurUDCDCor, R, TK_PCDCorAttrs(PA)^ do begin
    PrimRACSDim := GetPrimRACSDim;
    Count := SecCSDim.ALength;
    CurUDCDimPrim := K_GetRACSDimCDim(PrimRACSDim);
    EdPrimCDimName.Text := CurUDCDimPrim.GetUName;
    CurUDCDimSec := K_GetRACSDimCDim(SecCSDim);
    EdSecCDimName.Text := CurUDCDimSec.GetUName;
    FrameCDCor.ShowCDCorInfo( CurUDCDimPrim, PrimRACSDim.P, CurUDCDimSec, SecCSDim.P,
                             SecCSDim.ALength );
    ChangePrimCSDim.Enabled := (PrimRACSDim = PrimCSDim);
    if ChangePrimCSDim.Enabled then begin
    //*** Individual PrimRACSDim
      CurUDCSDimPrim := nil;
      SetLength( SelfPrimInds, Count );
      if Count > 0 then
        Move( PrimRACSDim.P^, SelfPrimInds[0], Count * SizeOf(Integer) );
    end else
    //*** Common PrimUDCSDim
      TObject(CurUDCSDimPrim) := PrimCSDim;
  end;
  ClearChangeDataFlag;

end; // end of TK_FormUDCDCor.ShowUDCDCor

//***********************************  TK_FormUDCDCor.FormCloseQuery
// Form CLose Query Handler
//
procedure TK_FormUDCDCor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  if FormCSDim <> nil then
    FormCSDim.ClearChangeDataFlag;
  CDimAndIndsFilter.Free;
  CDimFilter.Free;
//  CurUDCDimSec := nil;
//  CurUDCDimPrim := nil;
//  CurUDCDCor := nil;
end; // end of TK_FormUDCDCor.FormCloseQuery

//***********************************  TK_FormUDCDCor.ApplyUDCDCorExecute
// Apply Data Action Handler
//
procedure TK_FormUDCDCor.ApplyUDCDCorExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  SaveDataToCurUDCDCor;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;
end; // end of TK_FormUDCDCor.ApplyUDCDCorExecute

//***********************************  TK_FormUDCDCor.CreateUDCDCorExecute
// Create New Object Action Handler
//
procedure TK_FormUDCDCor.CreateUDCDCorExecute(Sender: TObject);
var
  NName, NAliase : string;
  RootNode, SecUDCDim, PrimUDCDim, PrimUDCDimOrCSDim : TN_UDBase;
  BuildSelfPrimInds : Boolean;
begin
//*** Select Root Node
  RootNode := CurUDCDRRoot;
  if not K_SelectUDNode( RootNode, SelectObjsUDRoot, nil,
                         'Выбор каталога для сохранения объекта', false  ) then Exit;
//  Application.ProcessMessages; //?? is it realy needed 2010-04-14
  PrimUDCDimOrCSDim := CurUDCSDimPrim;
  if PrimUDCDimOrCSDim = nil then
    PrimUDCDimOrCSDim := CurUDCDimPrim;

//*** Select Primary CDim or CDimInds
  if not K_SelectUDNode( PrimUDCDimOrCSDim, SelectObjsUDRoot, CDimAndIndsFilter.UDFTest,
                         'Целевой набор элементов - выбор целевого измерения или готового набор', true  ) then Exit;
//  if not SelectUDNode( UDCDimOrCSDim, CDimAndIndsFilter,
//     'Целевой набор элементов - выбор целевого измерения или готового набор' ) then Exit;
  BuildSelfPrimInds := PrimUDCDimOrCSDim is TK_UDCDim;
  if BuildSelfPrimInds  then
     PrimUDCDim := PrimUDCDimOrCSDim
  else
     PrimUDCDim := K_GetRACSDimCDim( TK_UDRArray(PrimUDCDimOrCSDim).R );

//  Application.ProcessMessages; //?? is it realy needed 2010-04-14

//*** Select Secondary CDim or CDimInds
  SecUDCDim := CurUDCDimSec;
  if not K_SelectUDNode( SecUDCDim, SelectObjsUDRoot, CDimFilter.UDFTest,
                         'Набор элементов связи - выбор измерения для установления связи', true  ) then Exit;
  if SecUDCDim = nil then  SecUDCDim := PrimUDCDim;

//  if not SelectUDNode( TN_UDBase(CurUDCDimSec), CDimFilter,
//     'Набор элементов связи - выбор измерения для установления связи' ) then Exit;

//*** Select New CSDim Root
  with RootNode do begin
    NAliase := BuildUniqChildName( K_BuildUDCDCorDefAliase(
                        PrimUDCDim, SecUDCDim), nil, K_ontObjAliase );
    NName := BuildUniqChildName( K_BuildUDCDCorDefName(
                        PrimUDCDim, SecUDCDim ) );
  end;

//*** Edit ObjName and ObjAliases
  if not K_EditNameAndAliase(  NAliase, NName ) then Exit;

//*** Check if Saving previous Relation Needed
  if not SaveDataIfNeeded  then Exit;

//*** Create New CDim Relation
  CurUDCDCor := TK_UDCDCor.CreateAndInit( NName, PrimUDCDimOrCSDim,
                                TK_UDCDim(SecUDCDim), NAliase, RootNode );

  FUDList.AddUDObjToTop( CurUDCDCor, RootNode );

//  Application.ProcessMessages;

  if BuildSelfPrimInds then
    ShowPrimCSDimEditForm( true );

  RootNode.RebuildVNodes;
  AddChangeDataFlag;
  ProjWasCreated := true;
end; // end of TK_FormUDCDCor.CreateUDCDCorExecute

//***********************************  TK_FormUDCDCor.BtCancelClick
// Button Cancel Click Handler
//
procedure TK_FormUDCDCor.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of TK_FormUDCDCor.BtCancelClick

//***********************************  TK_FormUDCDCor.BtOKClick
// Button OK Click Handler
//
procedure TK_FormUDCDCor.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormUDCDCor.BtOKClick

//***********************************  TK_FormUDCDCor.CLoseActionExecute
// Close Form Action Handler
//
procedure TK_FormUDCDCor.CLoseActionExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormUDCDCor.CLoseActionExecute

//***********************************  TK_FormUDCDCor.RenameUDCDCorExecute
// Rename Object Action Handler
//
procedure TK_FormUDCDCor.RenameUDCDCorExecute(Sender: TObject);
//var Ind : Integer;
begin
  if K_EditUDNameAndAliase(  CurUDCDCor ) then begin
    with CurUDCDRRoot do begin
      SetUniqChildName( CurUDCDCor );
      SetUniqChildName( CurUDCDCor, K_ontObjAliase );
    end;
    EdID.Text := CurUDCDCor.ObjName;
    FUDList.RebuildTopUDObjName;
    CurUDCDCor.RebuildVNodes(1);
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
  end;

end; // end of TK_FormUDCDCor.RenameUDCDCorExecute

//***********************************  TK_FormUDCDCor.PrimUDCSDimReady
// Select UDCSDim Parent and UDCDim objects
//
//procedure TK_FormUDCDCor.PrimUDCSDimReady( Sender : TObject; ActionType: TK_RAFGlobalAction );
function TK_FormUDCDCor.PrimUDCSDimReady( Sender : TObject; ActionType: TK_RAFGlobalAction ) : Boolean;
var
  ConvSecInds, NInds, SecCSDim, NSecCSDim  : TN_IArray;
  NCount, Count : Integer;
  PSInds, PNInds : PInteger;
begin
  Result := true;
  if (ActionType <> K_fgaCancelToAll) and
     (ActionType <> K_fgaNone) then begin
// Convert Secondary Indices According to New Primary Indices
   // Prepare Secondary Inds Convertion Inds

    Count := Length(SelfPrimInds);
    PSInds := nil;
    if Count > 0 then
      PSInds := @SelfPrimInds[0];

    FormCSDim.GetCurCSDim( NInds );
    NCount := Length(NInds);
    SetLength( ConvSecInds, NCount );

    if NCount > 0 then begin
      CurUDCDimPrim.BuildCDIndToIndsRInds( @ConvSecInds[0],
                                   @NInds[0], NCount, PSInds, Count );
    end;
    // Convert Secondary Inds By Convertion Inds

    FrameCDCor.GetSecCSDim( SecCSDim );
    Count := Length(SecCSDim);
    PSInds := nil;
    if Count > 0 then
      PSInds := @SecCSDim[0];

    SetLength( NSecCSDim, NCount );
    if NCount > 0 then begin
      FillChar( NSecCSDim[0], NCount * SizeOf(Integer), -1 );
      K_MoveVectorBySIndex( NSecCSDim[0], SizeOf(Integer),
                          PSInds^, SizeOf(Integer), SizeOf(Integer),
                          NCount, @ConvSecInds[0] );
      PNInds := @NInds[0];
      PSInds := @NSecCSDim[0];
      SelfPrimInds := Copy( NInds, 0, NCount );
    end else begin
      PSInds := nil;
      PNInds := nil;
      SelfPrimInds := nil;
    end;
    // Show New State
    FrameCDCor.ShowCDCorInfo( CurUDCDimPrim, PNInds,
                             CurUDCDimSec, PSInds, NCount );
    AddChangeDataFlag;
  end;
  if (ActionType <> K_fgaApplyToAll) then
    FormCSDim := nil;
end; // end of TK_FormUDCDCor.PrimUDCSDimReady


//***********************************  TK_FormUDCDCor.ShowPrimCSDimEditForm
// Show Primary CSDim Edit Form
//
procedure TK_FormUDCDCor.ShowPrimCSDimEditForm( UpdateInds : Boolean = false );
var
  PPrimInds : PInteger;
  PrimIndsCount : Integer;
begin
  if FormCSDim = nil then begin
    FormCSDim := K_GetFormCSDim( Self );
    UpdateInds := true;
  end;
  with FormCSDim do begin
    SkipCreationCall := true;
    OnGlobalAction := PrimUDCSDimReady;
    if not Visible then Show;
    if UpdateInds then begin
      PPrimInds := nil;
      PrimIndsCount := Length(SelfPrimInds);
      if PrimIndsCount > 0 then
        PPrimInds := @SelfPrimInds[0];
      ShowCSDim( CurUDCDimPrim,
        TK_PCSDimAttrs(CurUDCDCor.GetPrimRACSDim.PA).CDIType,
        PPrimInds, PrimIndsCount, true, '' );
    end;
  end;
end; // end of procedure TK_FormUDCDCor.ShowPrimCSDimEditForm

//***********************************  TK_FormUDCDCor.ChangePrimCSDimExecute
// Show Primary CSDim Edit Form
//
procedure TK_FormUDCDCor.ChangePrimCSDimExecute(Sender: TObject);
begin
  ShowPrimCSDimEditForm;
end; // end of procedure TK_FormUDCDCor.ChangePrimCSDimExecute

//***********************************  TK_FormUDCDCor.ReplaceSecCDimExecute
// Show Primary CSDim Edit Form
//
procedure TK_FormUDCDCor.ReplaceSecCDimExecute(Sender: TObject);
var
  SecUDCDim : TK_UDCDim;
  NInds : TN_IArray;
  Count : Integer;
begin

//*** Select Secondary CDim or CDimInds
  SecUDCDim := CurUDCDimSec;
  if not K_SelectUDNode( TN_UDBase(SecUDCDim), SelectObjsUDRoot, CDimFilter.UDFTest,
         'Выбор связанного измерения', true )  then Exit;
  if SecUDCDim = nil then SecUDCDim := CurUDCDimPrim;
  CurUDCDimSec := SecUDCDim;
  EdSecCDimName.Text := CurUDCDimSec.GetUName;
  with CurUDCDCor, R, TK_PCDCorAttrs(PA)^ do begin
    FrameCDCor.GetSecCSDim( NInds );
    Count := Length(NInds);
    if Count > 0 then
      FillChar( NInds[0], Count * SizeOf(Integer), -1 );
    FrameCDCor.ShowCDCorInfo( CurUDCDimPrim, GetPrimRACSDim.P, CurUDCDimSec,
                              K_GetPIArray0(NInds), Count );
  end;
  AddChangeDataFlag;
end; // end of procedure TK_FormUDCDCor.ReplaceSecCDimExecute

//***********************************  TK_FormUDCDCor.SetSelectObjsUDRoot
// Set Select Objs UDRoot
//
procedure TK_FormUDCDCor.SetSelectObjsUDRoot( ASelectObjsUDRoot: TN_UDBase );
begin
  SelectObjsUDRoot := ASelectObjsUDRoot;
  FUDList.FRUDListRoot := SelectObjsUDRoot;
end; // end of TK_FormUDCDCor.SetSelectObjsUDRoot

//***********************************  TK_FormUDCDCor.RebuildAllFramesExecute
// Rebuild Frames View
//
procedure TK_FormUDCDCor.RebuildAllFramesExecute(Sender: TObject);
begin
  FrameCDCor.K_FrameRAEditPrim.RebuildGridExecute(Sender);
  FrameCDCor.K_FrameRAEditSec.RebuildGridExecute(Sender);
end; // end of TK_FormUDCDCor.RebuildAllFramesExecute

end.
