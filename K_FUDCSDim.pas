unit K_FUDCSDim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Menus, ActnList, ComCtrls, ToolWin, ImgList, ExtCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_UDT1, K_Script1, K_FrRaEdit, K_CSpace, K_FrUDList,
  K_FrCSDim1, K_FrCSDim2,
  N_BaseF, N_Lib1, N_Types;

type
  TK_FormUDCSDim = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;

    ActionList1: TActionList;
    CreateCSDim  : TAction;
    ApplyCurCSDim: TAction;
    RenameCSDim  : TAction;
    CloseAction  : TAction;


    MainMenu1    : TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;

    EdID: TEdit;

    Panel1: TPanel;
    CSDFrameUDList: TK_FrameUDList;
    CmBIndsType: TComboBox;

    LbID  : TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;

    FrameCDSetInds: TK_FrameCSDim1;
    FrameCSDim: TK_FrameCSDim2;

    EdCDim: TEdit;

    BBDelAll: TButton;
    BBAddAll: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure CreateCSDimExecute(Sender: TObject);
    procedure ApplyCurCSDimExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure RenameCSDimExecute(Sender: TObject);
    procedure CmBIndsTypeChange(Sender: TObject);
  private
    { Private declarations }
    DataSaveModalState : word;
    SelShowToolBar : Boolean;
    CDSFilter : TK_UDFilter;
    IniCaption : string;
    FCDS : TK_FrameCSDim1;
    GActionType : TK_RAFGlobalAction;
  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    SelectObjsUDRoot : TN_UDBase;
    CurUDCSDim   : TK_UDCSDim;
    CurUDCDim    : TK_UDCDim;
    CurUDCSDimRoot : TN_UDBase;
    FCDIType : TK_CDRType;
    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure SetCSDim( ACDIType : TK_CDRType; PInds : PInteger;
                         IndsCount : Integer );
    procedure ShowCSDim( UCSDim : TN_UDBase );
    function  SaveDataToCurCSDim : Boolean;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
//    function  SelectUDNode( var UDSelectObj : TN_UDBase; SFilter : TK_UDFilter;
//                            SelCaption : string ) : Boolean;
  end;

function  K_GetFormUDCSDim( AOwner: TN_BaseForm ) : TK_FormUDCSDim;
function  K_EditUDCSDim( UDCSDim : TK_UDCSDim; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;

var K_UDCSDimEditCont : TK_RAEditFuncCont;
function K_EditUDCSDimFunc( var UCSDim; PDContext: Pointer ) : Boolean;

implementation

uses Math, Grids, inifiles,
  K_FSelectUDB, K_UDT2, K_Arch, K_RaEdit, K_CLib, K_FUDRename,
  N_ClassRef, N_ME1, N_ButtonsF;

{$R *.dfm}



//***********************************  K_EditUDCSDimFunc
// function which is registered as Code Dimention Indexes Editor
//
function K_EditUDCSDimFunc( var UCSDim; PDContext: Pointer ) : Boolean;
begin
  with TK_PRAEditFuncCont(PDContext)^ do
  Result := K_EditUDCSDim( TK_UDCSDim(UCSDim), FOwner, FOnGlobalAction, FNotModalShow );
end; // end of K_EditUDCSDimFunc

//***********************************  K_GetFormUDCSDim
// Create Code Dimention Indexes Editor Form
//
function K_GetFormUDCSDim( AOwner: TN_BaseForm ) : TK_FormUDCSDim;
begin
  Result := TK_FormUDCSDim.Create(Application);
  Result.BaseFormInit( AOwner );
end; // end of K_GetFormUDCSDim

//***********************************  K_EditUDCSDim
// Code Dimention Indexes Editor
//
function K_EditUDCSDim( UDCSDim : TK_UDCSDim; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false ) : Boolean;
begin
  with K_GetFormUDCSDim( AOwner ) do begin
    CurUDCSDim := UDCSDim;
    OnGlobalAction := AOnGlobalAction;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of K_EditUDCSDim

//***********************************  TK_FormUDCSDim.FormShow
// Form Show Handler
//
procedure TK_FormUDCSDim.FormShow(Sender: TObject);
begin
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;

  CreateCSDim.Enabled := true;
  ApplyCurCSDim.Enabled := false;

  if CurUDCSDim = nil then
    CSDFrameUDList.InitByPathIndex
  else
    CSDFrameUDList.AddUDObjToTop( CurUDCSDim );

  GActionType := K_fgaNone;
  ClearChangeDataFlag;
end; // end of TK_FormUDCSDim.FormShow

//***********************************  TK_FormUDCSDim.AddChangeDataFlag
// Change Controls after Data Changing
//
procedure TK_FormUDCSDim.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  ApplyCurCSDim.Enabled := true;
end; // end of TK_FormUDCSDim.AddChangeDataFlag

//***********************************  TK_FormUDCSDim.ClearChangeDataFlag
// Change Controls after Data Saving
//
procedure TK_FormUDCSDim.ClearChangeDataFlag;
begin
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  ApplyCurCSDim.Enabled := false;
end; // end of TK_FormUDCSDim.ClearChangeDataFlag

//***********************************  TK_FormUDCSDim.BtCancelClick
// Button Cancel Click Handler
//
procedure TK_FormUDCSDim.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of TK_FormUDCSDim.BtCancelClick

//***********************************  TK_FormUDCSDim.BtOKClick
// Button OK Click Handler
//
procedure TK_FormUDCSDim.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormUDCSDim.BtOKClick

//***********************************  TK_FormUDCSDim.FormCreate
// Form Create Handler
//
procedure TK_FormUDCSDim.FormCreate(Sender: TObject);
begin
  ClearChangeDataFlag;
  IniCaption := Caption;
  CurUDCSDim := nil;

  K_GetTypeCodeSafe( 'TK_CDRType' ).FD.GetFieldsDefValueList(
                          CmbIndsType.Items );
  CmbIndsType.Items.Delete(CmbIndsType.Items.Count - 1);

  CSDFrameUDList.SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCSDimCI ) );
  CSDFrameUDList.SelCaption := 'Выбор объекта';
  CSDFrameUDList.SelButtonHint := 'Выбор объекта';
  CSDFrameUDList.SelShowToolBar := true;
  CSDFrameUDList.FRUDListRoot := K_CurArchive;
  CSDFrameUDList.UDObj := nil;
  CSDFrameUDList.OnUDObjSelect := ShowCSDim;

  FrameCDSetInds.SetOnDataChange( AddChangeDataFlag );
  FrameCSDim.SetOnDataChange( AddChangeDataFlag );

  SelShowToolBar := false;
  CDSFilter := TK_UDFilter.Create;
  CDSFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );
  SelectObjsUDRoot := K_CurArchive;
end; // end of TK_FormUDCSDim.FormCreate

//***********************************  TK_FormUDCSDim.ShowCSDim
// Show new Code Dimension Indices
//
procedure TK_FormUDCSDim.SetCSDim( ACDIType : TK_CDRType; PInds : PInteger;
                                   IndsCount : Integer );
begin
  FCDIType := ACDIType;
  if FCDIType = K_cdrSSet then begin
    FCDS := FrameCDSetInds;
    FrameCSDim.Visible := false;
  end else begin
    FCDS := FrameCSDim;
    FrameCDSetInds.Visible := false;
  end;
  BBAddAll.Visible := FCDS = FrameCDSetInds;
  BBDelAll.Visible := BBAddAll.Visible;
  FCDS.Visible := true;
  FCDS.ShowCDimInds( FCDIType, PInds, IndsCount, CurUDCDim );
end; // end of TK_FormUDCSDim.SetCSDim

//***********************************  TK_FormUDCSDim.ShowCSDim
// Show new Code Dimension Indices
//
procedure TK_FormUDCSDim.ShowCSDim( UCSDim : TN_UDBase );
begin
  if not SaveDataIfNeeded then Exit;
  CurUDCSDim := TK_UDCSDim (UCSDim);
  Caption := CurUDCSDim.GetUName + ' - ' + IniCaption;
  EdID.Text := CurUDCSDim.ObjName;
  CurUDCSDimRoot := CSDFrameUDList.UDParent;
  if CurUDCSDimRoot = nil then CurUDCSDimRoot := UCSDim.Owner;
  FrameCDSetInds.ReadOnlyMode := K_CheckIfUDCSDimIsFull(CurUDCSDim);
  CmBIndsType.Enabled := not FrameCDSetInds.ReadOnlyMode;
  with CurUDCSDim, R, TK_PCSDimAttrs(PA)^ do begin
    CurUDCDim := TK_UDCDim(CDim);
    RenameCSDim.Enabled := not FrameCDSetInds.ReadOnlyMode;
    SetCSDim( CDIType, P, ALength );
  end;
  EdCDim.Text := CurUDCDim.GetUName();
  CmBIndsType.ItemIndex := -1;
  CmBIndsType.ItemIndex := Ord(FCDIType);
  ClearChangeDataFlag;
end; // end of TK_FormUDCSDim.ShowCSDim

//***********************************  TK_FormUDCSDim.SaveDataToCurCSDim
// Change CDimInds Object State
//
function TK_FormUDCSDim.SaveDataToCurCSDim: Boolean;
var
  NInds : TN_IArray;
begin
  FCDS.GetCSDim( NInds );
  TK_PCSDimAttrs(TK_UDRArray(CurUDCSDim).R.PA).CDIType := FCDIType;
  CurUDCSDim.ChangeValue( @NInds[0], Length(NInds),
    mrYes = MessageDlg( 'Изменять ли согласовано связанные данные?',
       mtConfirmation, [mbYes, mbNo], 0) );
  Result := true; //
  ResultDataWasChanged := true;
  ClearChangeDataFlag;
//  CurUDCSDim.RebuildVNodes(1);
//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
  GActionType := K_fgaOK;

end; // end of procedure TK_FormUDCSDim.SaveDataToCurCSDim

//***********************************  TK_FormUDCSDim.SaveDataIfNeeded
// Check if Data Saving is Needed
//
function TK_FormUDCSDim.SaveDataIfNeeded : Boolean;
var res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurCSDim then res := mrCancel
    else begin
{
      if (res = mrNo) and
         (CurUDCDSIndex = -1) then
        with CurUDCDim.GetCDSUDRoot do
          DeleteDirEntry( DirHigh );
}
    end;
  end;
  Result := (res <> mrCancel);
end; // end of TK_FormUDCSDim.SaveDataIfNeeded

{
//***********************************  TK_FormUDCSDim.SelectUDNode
// Select UDCSDim Parent and UDCDim objects
//
function TK_FormUDCSDim.SelectUDNode( var UDSelectObj : TN_UDBase;
                                     SFilter : TK_UDFilter;
                                     SelCaption : string  ) : Boolean;
var
  DE : TN_DirEntryPar;
  RootPath : string;
begin
   //*** Select New CSDim Root
  RootPath := '';
  if UDSelectObj <> nil then begin
    RootPath := K_CurArchive.GetRefPathToObj( UDSelectObj );
    if RootPath = '' then
      RootPath := K_CurArchive.GetPathToObj( UDSelectObj );
  end;
  Result := K_SelectDEOpen( DE, K_CurArchive, RootPath, SFilter, SelCaption, SelShowToolBar );
  if Result then UDSelectObj := DE.Child;
end; // end of procedure TK_FormUDCSDim.SelectUDNode
}

//***********************************  TK_FormUDCSDim.CreateCSDimExecute
// Create New TK_UDCSDim object Action Handler
//
procedure TK_FormUDCSDim.CreateCSDimExecute( Sender: TObject );
var
  NName, NAliase : string;
  UDCDim, UDCSDRoot : TN_UDBase;
begin
  UDCSDRoot := CurUDCSDimRoot;
  if not K_SelectUDNode( UDCSDRoot, SelectObjsUDRoot, nil,
                            'Выбор каталога для сохранения объекта', false  ) then Exit;
//  if not SelectUDNode( CurUDCSDimRoot, nil, 'Выбор каталога для сохранения объекта' ) then Exit;
//  Application.ProcessMessages; //?? is it realy needed 2010-04-14 
  UDCDim := CurUDCDim;
  if not K_SelectUDNode( TN_UDBase(UDCDim), SelectObjsUDRoot, CDSFilter.UDFTest,
                            'Выбор объекта "Измерение"', true  ) then Exit;
//  if not SelectUDNode( TN_UDBase(CurUDCDim), CDSFilter, 'Выбор объекта "Измерение"' ) then Exit;

  //*** Select New CSDim Root
  with UDCSDRoot do begin
    NAliase := BuildUniqChildName( UDCDim.GetUName+' '+IntToStr(DirHigh), nil, K_ontObjAliase );
    NName := BuildUniqChildName( K_FCSDimNewName );
  end;
  
  if not K_EditNameAndAliase(  NAliase, NName ) then Exit;
  if not SaveDataIfNeeded  then Exit;

  CSDFrameUDList.AddUDObjToTop( TK_UDCDim(UDCDim).CreateCSDim( NName, -1, NAliase, UDCSDRoot ) );

  UDCSDRoot.RebuildVNodes;
  AddChangeDataFlag;
end; // end of TK_FormUDCSDim.CreateCSDimExecute

//***********************************  TK_FormUDCSDim.ApplyCurCSDimExecute
// Apply Action Handler
//
procedure TK_FormUDCSDim.ApplyCurCSDimExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  SaveDataToCurCSDim;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;
end; // end of TK_FormUDCSDim.ApplyCurCSDimExecute

//***********************************  TK_FormUDCSDim.FormCloseQuery
// Form Close Query Handler
//
procedure TK_FormUDCSDim.FormCloseQuery( Sender: TObject;
                                        var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  CurUDCDim := nil;
  CurUDCSDim := nil;
end; // end of TK_FormUDCSDim.FormCloseQuery

//***********************************  TK_FormUDCSDim.FormClose
// Form Close Handler
//
procedure TK_FormUDCSDim.FormClose( Sender: TObject;
                                   var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  CDSFilter.Free;
end; // end of TK_FormUDCSDim.FormClose

//***********************************  TK_FormUDCSDim.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCSDim.CurStateToMemIni();
begin
  inherited;
  N_StringsToMemIni ( Name+'CDS', CSDFrameUDList.PathList );
end; // end of TK_FormUDCSDim.CurStateToMemIni

//***********************************  TK_FormUDCSDim.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormUDCSDim.MemIniToCurState();
begin
  inherited;
  N_MemIniToStrings( Name+'CDS', CSDFrameUDList.PathList );
end; // end of TK_FormUDCSDim.MemIniToCurState

//***********************************  TK_FormUDCSDim.CloseExecute
// Close Form Action Handler
//
procedure TK_FormUDCSDim.CloseActionExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end; // end of TK_FormUDCSDim.CloseExecute

//***********************************  TK_FormUDCSDim.RenameCSDimExecute
// Rename Current UDCSDim Object Action Handler
//
procedure TK_FormUDCSDim.RenameCSDimExecute(Sender: TObject);
begin
  if K_EditUDNameAndAliase(  CurUDCSDim ) then begin
    with CurUDCSDimRoot do begin
      SetUniqChildName( CurUDCSDim );
      SetUniqChildName( CurUDCSDim, K_ontObjAliase );
    end;
    EdID.Text := CurUDCSDim.ObjName;
    CSDFrameUDList.RebuildTopUDObjName;
    CurUDCSDim.RebuildVNodes(1);
    if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
  end;

end; // end of TK_FormUDCSDim.RenameCSDimExecute

//***********************************  TK_FormUDCSDim.CmBIndsTypeChange
// CSDim Type ComboBox Change Handler
//
procedure TK_FormUDCSDim.CmBIndsTypeChange(Sender: TObject);
var
//  BInds : TN_IArray;
//  CInds : TN_IArray;
//  i, n : Integer;
  NInds : TN_IArray;
  NCount : Integer;
begin
  if Ord(FCDIType) = CmBIndsType.ItemIndex then Exit;
  FCDS.GetCSDim( NInds );
  NCount := CurUDCDim.ConvCDIndsType( FCDIType, @NInds[0],
                        Length(NInds), TK_CDRType(CmBIndsType.ItemIndex) );
  SetCSDim( TK_CDRType(CmBIndsType.ItemIndex), @NInds[0], NCount );
  AddChangeDataFlag;
{
  if FCDSFlags = K_cdrBag then begin
    NCount := CurUDCDim.SelfCount;
    SetLength( BInds, NCount );
    FillChar( BInds[0], NCount * SizeOf(Integer), 0 );
    SetLength( NInds, NCount );
    FCDS.GetCSDim( CInds );
    NCount := 0;
    for i := 0 to High(CInds) do begin
      n := CInds[i];
      if (n >= 0) and (BInds[n] = 0) then begin
        BInds[n] := 1;
        NInds[NCount] := n;
        Inc( NCount );
      end;
    end;
  end else begin
    FCDS.GetCSDim( NInds );
    NCount := Length( NInds );
  end;
  SetCSDim( TK_CDRType(CmBIndsType.ItemIndex), @NInds[0], NCount );
  AddChangeDataFlag;
}
end; // end of TK_FormUDCSDim.CmBIndsTypeChange

end.
