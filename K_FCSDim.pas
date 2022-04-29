unit K_FCSDim;

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
  TK_FormCSDim = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;
    BtCreate: TButton;

    ActionList1: TActionList;
    ApplyCurCSDim: TAction;
    CloseAction  : TAction;
    CreateCSDim  : TAction;

    Panel1: TPanel;
    CmBIndsType: TComboBox;
    LbIndsType: TLabel;

    FrameCDSetInds: TK_FrameCSDim1;
    FrameCSDim: TK_FrameCSDim2;
    BBAddAll: TButton;
    BBDelAll: TButton;
    Label2: TLabel;
    EdCDim: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure ApplyCurCSDimExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure CmBIndsTypeChange(Sender: TObject);
    procedure CreateCSDimExecute(Sender: TObject);
  private
    { Private declarations }
    CDimFilter : TK_UDFilter;
    IniCaption : string;
    DataSaveModalState : word;
    FCDS : TK_FrameCSDim1;
    GActionType : TK_RAFGlobalAction;
    CreateRAFlags : TK_CreateRAFlags;

    PRACSDim : TK_PRArray;
    FRACSDim : TK_RArray;

    CurUDCDim : TK_UDCDim;
    FCDIType : TK_CDRType;

  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    SkipCreationCall : Boolean;

    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure SetCSDim( ACDIType : TK_CDRType; PInds : PInteger;
                         IndsCount : Integer );
    procedure ShowCSDim( UDCDim : TK_UDCDim;
                      ACDIType : TK_CDRType;
                      PInds : PInteger; IndsCount : Integer;
                      SkipTypeChange : Boolean; ACaption : string = '' );
    procedure ShowRACSDim( var ARACSDim : TK_RArray; ACaption : string = '' );
    procedure ShowRACSDim0;
    function  SaveDataToCurCSDim : Boolean;
    procedure GetCurCSDim( var CSDim : TN_IArray );
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
  end;

function  K_GetFormCSDim( AOwner: TN_BaseForm ) : TK_FormCSDim;
function  K_EditCSDim( var ARACSDim : TK_RArray; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false; ACreateRAFlags : TK_CreateRAFlags = [] ) : Boolean;

var K_CSDimEditCont : TK_RAEditFuncCont;
function K_EditCSDimFunc( var ARADInds; PDContext: Pointer ) : Boolean;

implementation

uses Math, Grids, inifiles,
  K_FSelectUDB, K_UDT2, K_Arch, K_RaEdit, K_CLib, K_FUDRename, K_VFunc,
  N_ClassRef, N_ME1, N_ButtonsF;

{$R *.dfm}


//***********************************  K_GetFormCSDim
// Create Code Dimention Indexes Editor Form
//
function K_GetFormCSDim( AOwner: TN_BaseForm ) : TK_FormCSDim;
begin
  Result := TK_FormCSDim.Create(Application);
  Result.BaseFormInit( AOwner );
end; // end of K_GetFormCSDim

//***********************************  K_EditCSDim
// Code Dimention Indexes Editor
//
function K_EditCSDim( var ARACSDim : TK_RArray; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil;
              ANotModalShow : Boolean = false; ACreateRAFlags : TK_CreateRAFlags = [] ) : Boolean;
begin
  with K_GetFormCSDim( AOwner ) do begin
    PRACSDim := @ARACSDim;
    FRACSDim := ARACSDim;
    OnGlobalAction := AOnGlobalAction;
    CreateRAFlags := ACreateRAFlags;
    if ANotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; // end of K_EditCSDim

//***********************************  K_EditCSDimFunc
// function which is registered as Code Dimention Indexes Editor
//
function K_EditCSDimFunc( var ARADInds; PDContext: Pointer ) : Boolean;
var
 ACreateRAFlags : TK_CreateRAFlags;
begin
  with TK_PRAEditFuncCont(PDContext)^ do begin
    ACreateRAFlags := [];
    if (FDType.D.CFlags and K_ccCountUDRef) <> 0 then ACreateRAFlags := [K_crfCountUDRef];
    Result := K_EditCSDim( TK_RArray(ARADInds), FOwner,
                          FOnGlobalAction, FNotModalShow, ACreateRAFlags );
  end;
end; // end of K_EditCSDimFunc

//***********************************  TK_FormCSDim.FormShow
// Form Show Handler
//
procedure TK_FormCSDim.FormShow(Sender: TObject);
begin
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;

  ApplyCurCSDim.Enabled := false;

  ShowRACSDim0;
//  ClearChangeDataFlag;
  GActionType := K_fgaNone;
end; // end of TK_FormCSDim.FormShow

//***********************************  TK_FormCSDim.AddChangeDataFlag
// Change Controls after Data Changing
//
procedure TK_FormCSDim.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  ApplyCurCSDim.Enabled := true;
end; // end of TK_FormCSDim.AddChangeDataFlag

//***********************************  TK_FormCSDim.ClearChangeDataFlag
// Change Controls after Data Saving
//
procedure TK_FormCSDim.ClearChangeDataFlag;
begin
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  ApplyCurCSDim.Enabled := false;
end; // end of TK_FormCSDim.ClearChangeDataFlag

//***********************************  TK_FormCSDim.BtCancelClick
// Button Cancel Click Handler
//
procedure TK_FormCSDim.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrCancel;
  GActionType := K_fgaNone;
end; // end of TK_FormCSDim.BtCancelClick

//***********************************  TK_FormCSDim.BtOKClick
// Button OK Click Handler
//
procedure TK_FormCSDim.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormCSDim.BtOKClick

//***********************************  TK_FormCSDim.FormCreate
// Form Create Handler
//
procedure TK_FormCSDim.FormCreate(Sender: TObject);
begin
  ClearChangeDataFlag;
  IniCaption := Caption;
  K_GetTypeCodeSafe( 'TK_CDRType' ).FD.GetFieldsDefValueList(
                          CmbIndsType.Items );
  CmbIndsType.Items.Delete(CmbIndsType.Items.Count - 1);

  FrameCDSetInds.SetOnDataChange( AddChangeDataFlag );
  FrameCSDim.SetOnDataChange( AddChangeDataFlag );

  CDimFilter := TK_UDFilter.Create;
  CDimFilter.AddItem( TK_UDFilterClassSect.Create( K_UDCDimCI ) );

end; // end of TK_FormCSDim.FormCreate

//***********************************  TK_FormCSDim.SetCSDim
// Set new Code Dimension Indices
//
procedure TK_FormCSDim.SetCSDim( ACDIType : TK_CDRType; PInds : PInteger;
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
end; // end of TK_FormCSDim.SetCSDim

//***********************************  TK_FormCSDim.ShowCSDim
// Show new Code Dimension Indices
//
procedure TK_FormCSDim.ShowCSDim( UDCDim : TK_UDCDim;
                      ACDIType : TK_CDRType;
                      PInds : PInteger; IndsCount : Integer;
                      SkipTypeChange : Boolean; ACaption : string = ''  );
begin
  CurUDCDim := UDCDim;
  if ACaption <> '' then
    Caption := ACaption + ' - ' + IniCaption;
  SetCSDim( ACDIType, PInds, IndsCount );
  EdCDim.Text := UDCDim.GetUName();
  FRACSDim := nil;
  PRACSDim := nil;
  CmBIndsType.Visible := not SkipTypeChange;
  LbIndsType.Visible := not SkipTypeChange;
  BtCreate.Visible := not SkipTypeChange;
  CreateCSDim.Enabled := false;
  ClearChangeDataFlag;
  SkipCreationCall := true;
end; // end of TK_FormCSDim.ShowCSDim

//***********************************  TK_FormCSDim.ShowRACSDim
// Show new Code Dimension Indices
//
procedure TK_FormCSDim.ShowRACSDim( var ARACSDim : TK_RArray; ACaption : string = '' );
begin
  if not SaveDataIfNeeded then Exit;
  if ACaption <> '' then
    Caption := ACaption + ' - ' + IniCaption;
  PRACSDim := @ARACSDim;
  FRACSDim := ARACSDim;
  SkipCreationCall := false;
end; // end of TK_FormCSDim.ShowRACSDim

//***********************************  TK_FormCSDim.ShowRACSDim0
// Show new Code Dimension Indices
//
procedure TK_FormCSDim.ShowRACSDim0;
begin
  ClearChangeDataFlag;
  CmBIndsType.Enabled := FRACSDim = nil;
  CreateCSDim.Enabled := CmBIndsType.Enabled and not SkipCreationCall;
  if FRACSDim <> nil then begin
    with FRACSDim, TK_PCSDimAttrs(PA)^ do begin
      CurUDCDim := TK_UDCDim(CDim);
      SetCSDim( CDIType, P, ALength );
    end;
    CmBIndsType.Visible := true;
    CmBIndsType.ItemIndex := -1;
    CmBIndsType.ItemIndex := Ord(FCDIType);
  end else if not SkipCreationCall then
    CreateCSDimExecute(nil);

  EdCDim.Text := CurUDCDim.GetUName();

end; // end of TK_FormCSDim.ShowRACSDim0

//***********************************  TK_FormCSDim.SaveDataToCurCSDim
// Change CDimInds Object State
//
function TK_FormCSDim.SaveDataToCurCSDim: Boolean;
var
  NInds : TN_IArray;
  Count : Integer;
begin
  if FRACSDim <> nil then begin
    FCDS.GetCSDim( NInds );
    Count := Length( NInds );
    with FRACSDim do begin
      ASetLength( Count );
      TK_PCSDimAttrs(PA).CDIType := FCDIType;
      if Count > 0 then
        Move( NInds[0], P^, Length( NInds ) * SizeOf(Integer) );
    end;
    if PRACSDim <> nil then PRACSDim^ := FRACSDim;
  end;
  Result := true; //
  ResultDataWasChanged := true;
  ClearChangeDataFlag;
  GActionType := K_fgaOK;
//  if Assigned(OnGlobalAction) then OnGlobalAction( K_fgaOK );
end; // end of procedure TK_FormCSDim.SaveDataToCurCSDim

//***********************************  TK_FormCSDim.GetCurCSDim
// Get Current CSDim State
//
procedure TK_FormCSDim.GetCurCSDim( var CSDim : TN_IArray );
begin
  FCDS.GetCSDim( CSDim );
end; // end of procedure TK_FormCSDim.GetCurCSDim

//***********************************  TK_FormCSDim.SaveDataIfNeeded
// Check if Data Saving is Needed
//
function TK_FormCSDim.SaveDataIfNeeded : Boolean;
var res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurCSDim then res := mrCancel;
  end;
  Result := (res <> mrCancel);
end; // end of TK_FormCSDim.SaveDataIfNeeded

//***********************************  TK_FormCSDim.ApplyCurCSDimExecute
// Apply Action Handler
//
procedure TK_FormCSDim.ApplyCurCSDimExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  SaveDataToCurCSDim;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaApplyToAll );
  GActionType := K_fgaNone;

end; // end of TK_FormCSDim.ApplyCurCSDimExecute

//***********************************  TK_FormCSDim.FormCloseQuery
// Form Close Query Handler
//
procedure TK_FormCSDim.FormCloseQuery( Sender: TObject;
                                        var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, GActionType );
  CurUDCDim := nil;
  FRACSDim := nil;
  CDimFilter.Free;
end; // end of TK_FormCSDim.FormCloseQuery

//***********************************  TK_FormCSDim.CloseExecute
// Close Form Action Handler
//
procedure TK_FormCSDim.CloseActionExecute(Sender: TObject);
begin
  if not (fsModal in FormState)	then Close;
  ModalResult := mrOK;
end; // end of TK_FormCSDim.CloseExecute

//***********************************  TK_FormCSDim.CmBIndsTypeChange
// CSDim Type ComboBox Change Handler
//
procedure TK_FormCSDim.CmBIndsTypeChange(Sender: TObject);
var
//  BInds : TN_IArray;
//  CInds : TN_IArray;
//  i, n : Integer;
  NInds : TN_IArray;
  NCount : Integer;
  PInds : PInteger;
begin
  if Ord(FCDIType) = CmBIndsType.ItemIndex then Exit;
  FCDS.GetCSDim( NInds );
  PInds := K_GetPIArray0( NInds );
  NCount := CurUDCDim.ConvCDIndsType( FCDIType, PInds, Length(NInds),
                                     TK_CDRType(CmBIndsType.ItemIndex) );
  SetCSDim( TK_CDRType(CmBIndsType.ItemIndex), PInds, NCount );
  AddChangeDataFlag;
end; // end of TK_FormCSDim.CmBIndsTypeChange

//***********************************  TK_FormCSDim.CreateCSDimExecute
// Create CSDim Action Handler
//
procedure TK_FormCSDim.CreateCSDimExecute(Sender: TObject);
var
  NewCDim : TN_UDBase;
begin
  NewCDim := nil;
  if not K_SelectUDNode( NewCDim, K_CurArchive, CDimFilter.UDFTest,
                                       'Выбор измерения', true  ) then Exit;
  if not SaveDataIfNeeded  then Exit;
  FRACSDim := K_CreateRACSDim( TK_UDCDim(NewCDim), K_cdrList, CreateRAFlags );
  ShowRACSDim0;
  AddChangeDataFlag;
end; // end of TK_FormCSDim.CreateCSDimExecute

end.
