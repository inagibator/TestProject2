unit K_FDCSProj;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ToolWin, ActnList, ImgList,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_FrRaEdit, K_Script1, K_DCSpace,
  N_Types, N_BaseF, N_Lib1, Menus, ExtCtrls;

type
  TK_FormDCSProjection = class(TN_BaseForm)
    EdID     : TEdit;
    EdComment: TEdit;

    LbID       : TLabel;
    LbProj     : TLabel;
    LbDestSpace: TLabel;
    LbSrcSpace : TLabel;
    LbComment  : TLabel;

    BBtnAdd: TBitBtn;
    BBtnDel: TBitBtn;

    BtCancel: TButton;
    BtOK    : TButton;
    Button1 : TButton;

    K_FrameRAEditS: TK_FrameRAEdit;
    K_FrameRAEditD: TK_FrameRAEdit;

    CmBSListS: TComboBox;
    CmBSListD: TComboBox;
    CmBPList : TComboBox;

    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;

    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;

    ActionList1: TActionList;
    SaveCurDCSProj  : TAction;
    CreateCurDCSProj: TAction;
    CLose           : TAction;
    BuildByRProj    : TAction;
    AddItems        : TAction;
    DelItems        : TAction;
    RenameDCSProj   : TAction;
    DeleteCurDCProj : TAction;

    procedure BBtnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

    procedure CmBSListSSelect(Sender: TObject);
    procedure CmBSListDSelect(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SaveCurDCSProjExecute(Sender: TObject);
    procedure CreateCurDCSProjExecute(Sender: TObject);
    procedure BuildByRProjExecute(Sender: TObject);
    procedure EdCommentChange(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure CmBPListSelect(Sender: TObject);
    procedure CLoseExecute(Sender: TObject);
    procedure AddItemsExecute(Sender: TObject);
    procedure DelItemsExecute(Sender: TObject);
    procedure RenameDCSProjExecute(Sender: TObject);
  private
    { Private declarations }
    IniCaption : string;
    DDType : TK_ExprExtType;
    FormDescr2, FormDescr : TK_UDRArray;
    RAFCArray2, RAFCArray : TK_RAFCArray;
    FrDescr2, FrDescr : TK_RAFrDescr;
    AModeFlags : TK_RAModeFlagSet;
    DataSaveModalState : word;
    ProjWasCreated : Boolean;

    CurUDCSpaceSrc : TK_UDDCSpace;
    CurUDCSpaceDest : TK_UDDCSpace;
    CurUDCSProj : TK_UDVector;
    CurUDCSIndexS : Integer;
    CurUDCSIndexD : Integer;
    CurUDCPIndex, InitUDCPIndex  : Integer;
    ShowFormMode : Boolean;

  public
    { Public declarations }
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    OnGlobalAction : TK_RAFGlobalActionProc;
    procedure AddChangeDataFlag;
    procedure ClearChangeDataFlag;
    function  SaveDataIfNeeded : Boolean;
    function  SaveDataToCurDCSProj : Boolean;
    procedure ClearDCSProj;
    procedure PrepareDCSProjShow( UDCSProj : TK_UDVector );
    procedure PrepareDCSpaceSShow( UDCSpace : TK_UDDCSpace );
    procedure PrepareProjList( ShowInd : Integer = -2 );
    procedure PrepareDCSpaceDShow( UDCSpace : TK_UDDCSpace );
  end;


function  K_GetFormDCSProjection( AOwner: TN_BaseForm ) : TK_FormDCSProjection;
function  K_EditDCSProj(UDCSProj : TK_UDVector; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil ) : Boolean;

var
  K_FormDCSProjection: TK_FormDCSProjection;

implementation

uses Grids, Math, inifiles,
  N_ButtonsF,
  K_UDT1, K_Arch, K_RaEdit, K_VFunc, K_FUDRename, K_Types;

{$R *.dfm}


function  K_GetFormDCSProjection( AOwner: TN_BaseForm ) : TK_FormDCSProjection;
begin
  if K_FormDCSProjection = nil then begin
    K_FormDCSProjection := TK_FormDCSProjection.Create(Application);
    K_FormDCSProjection.BaseFormInit( AOwner );
  end;
  Result := K_FormDCSProjection;
end;

function  K_EditDCSProj(UDCSProj : TK_UDVector; AOwner: TN_BaseForm = nil;
              AOnGlobalAction : TK_RAFGlobalActionProc = nil ) : Boolean;
begin
  with K_GetFormDCSProjection( AOwner ) do begin
    CurUDCSProj := UDCSProj;
    CurUDCSpaceSrc := TK_UDDCSSpace(CurUDCSProj).GetDCSpace;
    CurUDCSpaceDest := CurUDCSProj.GetDCSSpace.GetDCSpace;
    OnGlobalAction := AOnGlobalAction;
    ShowModal;
    Result := ResultDataWasChanged;
  end;
end;

procedure TK_FormDCSProjection.AddChangeDataFlag;
begin
  inherited;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  SaveCurDCSProj.Enabled := true;
  DataWasChanged := true;
end;

procedure TK_FormDCSProjection.BBtnAddClick(Sender: TObject);
var
  GRS, GRD : TGridRect;
  IndS, IndD, leng : Integer;
begin
  if not BBtnAdd.Enabled then Exit;
  GRS := K_FrameRAEditS.SGrid.Selection;
  GRS.Top := Max( GRS.Top, 1 );
  GRD := K_FrameRAEditD.SGrid.Selection;
  GRD.Top := Max( GRD.Top, 1 );
  IndS := GRS.Top - 1;
  IndD := GRD.Top - 1;
  with K_FrameRAEditD do begin
    leng := Length(DataPointers);
    while (IndS < GRS.Bottom) and (IndD < leng) do begin // move data
        DataPointers[IndD][0] :=
          K_FrameRAEditS.DataPointers[IndS][0];
        DataPointers[IndD][1] :=
          K_FrameRAEditS.DataPointers[IndS][1];
      Inc(IndS);
      Inc(IndD);
      AddChangeDataFlag;
    end;
    SGrid.Invalidate;
  end;
end;

procedure TK_FormDCSProjection.ClearChangeDataFlag;
begin
//  inherited;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  SaveCurDCSProj.Enabled := false;
  DataWasChanged := false;
  ProjWasCreated := false;
end;

procedure TK_FormDCSProjection.FormCreate(Sender: TObject);
begin

  ClearChangeDataFlag;
  IniCaption := Caption;
//*** prepare editing
  FormDescr := K_CreateSPLClassByName( 'TK_FormDCSSpace', [] );
//*** Prepare Source Space Frame
  DDType := K_GetTypeCodeSafe( 'TK_DCEditSpace1' );

//  Inc( DDType.D.TFlags, K_ffArray ); //??
  AModeFlags := [K_ramColVertical, K_ramReadOnly, K_ramSkipResizeWidth, K_ramSkipResizeHeight,
                 K_ramOnlyEnlargeSize, K_ramSkipRowMoving];
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray, @FrDescr, AModeFlags, DDType, FormDescr );

  K_FrameRAEditS.SetGridInfo( AModeFlags, RAFCArray, FrDescr, 0,  nil,
                                                  nil, nil );

//*** Prepare Dest Space Frame
  FormDescr2 := K_CreateSPLClassByName( 'TK_FormDCSSpace2', [] );

  DDType := K_GetTypeCodeSafe( 'TK_DCEditSpace2' );
  K_RAFColsPrepByRADataFormDescr(
      RAFCArray2, @FrDescr2, AModeFlags, DDType, FormDescr2 );

  K_FrameRAEditD.SetGridInfo( AModeFlags, RAFCArray2, FrDescr2, 0, nil,
                                                  nil, nil );
  K_FrameRAEditD.OnDataChange := AddChangeDataFlag;
  CurUDCSpaceSrc := nil;
  CurUDCSpaceDest := nil;
  CurUDCSProj := nil;
end;

function TK_FormDCSProjection.SaveDataIfNeeded : Boolean;
var
  res : Word;
begin
  res := DataSaveModalState;
  if DataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
           mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (res = mrYes) and
       not SaveDataToCurDCSProj then
      res := mrCancel
    else if (res = mrNo) and ProjWasCreated then begin
      K_DCSpaceProjectionDelete( TK_UDDCSSpace(CurUDCSProj) );
    end;
  end;
  Result := (res <> mrCancel);
end;

procedure TK_FormDCSProjection.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  K_FrameRAEditD.FreeContext;
  K_FrameRAEditS.FreeContext;
  FormDescr.Free;
  FormDescr2.Free;
  K_FreeSPLData( FrDescr, K_GetFormCDescrDType.All );
  K_FreeSPLData( FrDescr2, K_GetFormCDescrDType.All );
  K_FreeColumnsDescr( RAFCArray );
  K_FreeColumnsDescr( RAFCArray2 );
  K_FormDCSProjection := nil;
end;

//***********************************  TK_FormDCSProjection.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSProjection.CurStateToMemIni();
begin
  inherited;
  N_IntToMemIni( Name, 'DCSIndS', CmBSListS.ItemIndex );
  N_IntToMemIni( Name, 'DCSIndD', CmBSListD.ItemIndex );
  N_IntToMemIni( Name, 'DCPInd', CmBPList.ItemIndex );

end; // end of procedure TK_FormDCSProjection.CurStateToMemIni

//***********************************  TK_FormDCSProjection.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TK_FormDCSProjection.MemIniToCurState();
begin
  inherited;
  CurUDCSIndexS := N_MemIniToInt( Name, 'DCSIndS', -1 );
  CurUDCSIndexD := N_MemIniToInt( Name, 'DCSIndD', -1 );
  InitUDCPIndex := N_MemIniToInt( Name, 'DCPInd', -1 );
end; // end of procedure TK_FormDCSProjection.MemIniToCurState

function TK_FormDCSProjection.SaveDataToCurDCSProj: Boolean;
var
  SCodes : TK_RArray;
  SArray : TN_SArray;
  i, h : Integer;
begin
  with K_FrameRAEditD, CurUDCSProj do begin
    h := CurUDCSpaceDest.SelfCount;
    SetLength( SArray, h );
    SCodes := TK_PDCSpace( CurUDCSpaceSrc.R.P ).Codes;
    for i := 0 to h - 1 do begin
      if DataPointers[i][0] = nil then
        SArray[i] := ''
      else
        SArray[i] := PString(DataPointers[i][0])^;
    end;
    K_SCIndexFromSCodes( PInteger(DP),
          @SArray[0], h,
          PString(SCodes.P), SCodes.ALength );
    ObjAliase := EdComment.Text;
  end;
  CurUDCSProj.RebuildVNodes(1);
  ClearChangeDataFlag;
  if Assigned(OnGlobalAction) then OnGlobalAction( Self, K_fgaOK );
  K_SetChangeSubTreeFlags( CurUDCSProj );
  ResultDataWasChanged := true;
  Result := true;
end;

procedure TK_FormDCSProjection.FormShow(Sender: TObject);
begin
//  K_FrameRAEdit.RebuildGridExecute(Sender);
  K_CurSpacesRoot.BuildChildsList(CmBSlistS.Items, K_ontObjUName);
  CmBSlistS.ItemIndex := -1;
  CurUDCSIndexS := -1;
  CmBSlistS.Text := '';

  CmBSlistD.Items.Assign(CmBSlistS.Items);
  CmBSlistD.ItemIndex := -1;
  CurUDCSIndexD := -1;
  CmBSlistD.Text := '';

  CurUDCPIndex := -1;
  InitUDCPIndex := -1;

  K_FrameRAEditS.SetGridLRowsNumber(  0 );
  K_FrameRAEditS.SGrid.Invalidate;

  K_FrameRAEditD.SetGridLRowsNumber(  0 );
  K_FrameRAEditD.SGrid.Invalidate;

  AddItems.Enabled := false;
  DelItems.Enabled := false;
  RenameDCSProj.Enabled := false;
  SaveCurDCSProj.Enabled := false;
  CreateCurDCSProj.Enabled := false;

  EdComment.Text := '';
  ClearChangeDataFlag;
  DataSaveModalState := mrNone;
  ResultDataWasChanged := false;

  if (CurUDCSpaceSrc = nil) then begin
    MemIniToCurState;
    CurUDCSpaceSrc := TK_UDDCSpace( K_CurSpacesRoot.DirChild( CurUDCSIndexS ) );
    CurUDCSIndexS := -1;
    CurUDCSpaceDest := TK_UDDCSpace( K_CurSpacesRoot.DirChild( CurUDCSIndexD ) );
    CurUDCSIndexD:= -1;

  end;

//*** Init Src/Dest Spaces
  ShowFormMode := true;
  if (CurUDCSpaceSrc <> nil) then begin
    with K_CurSpacesRoot do
      CmBSlistS.ItemIndex := IndexOfDEField(CurUDCSpaceSrc);
    CurUDCSpaceSrc := nil;
    if CmBSlistS.ItemIndex <> -1 then
      CmBSListSSelect(nil);
  end;

  ShowFormMode := false;
  if (CurUDCSpaceDest <> nil) then begin
    with K_CurSpacesRoot do
      CmBSlistD.ItemIndex := IndexOfDEField(CurUDCSpaceDest);
    CurUDCSpaceDest := nil;
    if CmBSlistD.ItemIndex <> -1 then
      CmBSListDSelect(nil);
  end;
  if (CurUDCSIndexD = -1) and (CurUDCSIndexS = -1) then
    PrepareProjList;

end;

procedure TK_FormDCSProjection.CmBSListSSelect(Sender: TObject);

begin
  if SaveDataIfNeeded then begin
    CurUDCSIndexS := CmBSlistS.ItemIndex;
    if Sender <> nil then begin // clear current Projection if select new Space
//    CurUDCSProj := nil;
      ClearDCSProj;
    end;

    with CmBSlistS do
      if ItemIndex <> -1 then
        PrepareDCSpaceSShow( TK_UDDCSpace( Items.Objects[ItemIndex] ) );
  end else begin
    CmBSlistS.ItemIndex := CurUDCSIndexS;
  end;

end;

procedure TK_FormDCSProjection.CmBSListDSelect(Sender: TObject);
begin
  if SaveDataIfNeeded then begin
    CurUDCSIndexD := CmBSlistS.ItemIndex;
    if Sender <> nil then begin // clear current Projection if select new Space
//    CurUDCSProj := nil;
      ClearDCSProj;
    end;

    with CmBSlistD do
      if ItemIndex <> -1 then
        PrepareDCSpaceDShow( TK_UDDCSpace( Items.Objects[ItemIndex] ) );
  end else begin
    CmBSlistD.ItemIndex := CurUDCSIndexD;
  end;

end;

procedure TK_FormDCSProjection.PrepareDCSProjShow( UDCSProj : TK_UDVector );
begin
  if (CurUDCSProj = UDCSProj) and
     (UDCSProj <> nil) then Exit;
//  ClearDCSProj;
  CurUDCSProj := UDCSProj;
  AddItems.Enabled := true;
  DelItems.Enabled := true;
  RenameDCSProj.Enabled := true;
  DeleteCurDCProj.Enabled := true;
  BuildByRProj.Enabled :=
      (K_DCSpaceProjectionGet( CurUDCSpaceDest, CurUDCSpaceSrc ) <> nil);
  with CurUDCSProj do begin
    EdComment.Enabled := true;
    EdComment.Text := ObjAliase;
    EdID.Text := ObjName;
//      PIndex := PInteger(Indexes.P);
    K_FrameRAEditD.SetDataPointersFromColumnRArrays(
      TK_PDCSpace(CurUDCSpaceSrc.R.P).Codes,
      PInteger(DP), PDRA.ALength, 0, 0, 2  );
  end;
//  DataSaveModalState := mrNone;
  ClearChangeDataFlag;
//  K_FrameRAEditD.SGrid.Invalidate;
  K_FrameRAEditD.RebuildGridInfo;
end;

procedure TK_FormDCSProjection.ClearDCSProj;
begin
  AddItems.Enabled := false;
  DelItems.Enabled := false;
  RenameDCSProj.Enabled := false;
  BuildByRProj.Enabled := false;
  DeleteCurDCProj.Enabled := false;
  CurUDCSProj := nil;
  EdComment.Text := '';
  EdComment.Enabled := false;
  EdID.Text := '';
  CreateCurDCSProj.Enabled := false;
  K_FrameRAEditD.ClearDataPointers(0, 0, 2, 0 );
  DataSaveModalState := mrNone;
  ClearChangeDataFlag;
  K_FrameRAEditD.SGrid.Invalidate;
end;

procedure TK_FormDCSProjection.PrepareProjList( ShowInd : Integer = -2 );
var
  WSSRoot, WDSSD : TN_UDBase;
  i, h : Integer;
  UDProj : TK_UDVector;
begin
  CmBPList.Items.Clear;
  CmBPList.Text := '';
  CmBPList.Enabled := false;
//  CreateCurDCSProj.Enabled := false;
  ClearDCSProj;
  if ShowFormMode            or
     (CurUDCSpaceDest = nil) or
//     (CurUDCSpaceSrc  = nil) or
//     (CurUDCSpaceDest = CurUDCSpaceSrc) then Exit;
     (CurUDCSpaceSrc  = nil) then Exit;
  CreateCurDCSProj.Enabled := true;

{
  with CurUDCSpaceDest.GetSSpacesDir do //*** Search for special full DCSSpace
    WDSSD := DirChild(IndexOfChildObjName( CurUDCSpaceDest.ObjName ));
  if WDSSD = nil then Exit;
  WSSRoot := CurUDCSpaceSrc.GetSSpacesDir;
  with TK_UDDCSSpace(WDSSD).GetVectorsDir do begin
    h := DirHigh;
    for i := 0 to h do begin
      UDProj := TK_UDVector(DirChild(i));
      if UDProj.Owner <> WSSRoot then continue;
      CmBPList.Items.AddObject( UDProj.ObjAliase, UDProj );
    end;
    UDProj := TK_UDVector(DirChild(InitUDCPIndex));
    if UDProj = nil then InitUDCPIndex := -1;
  end;
}
  with CurUDCSpaceDest.GetSSpacesDir do //*** Search for special full DCSSpace
    WDSSD := DirChild(IndexOfChildObjName( CurUDCSpaceDest.ObjName ));
  if WDSSD = nil then Exit;
  WSSRoot := CurUDCSpaceSrc.GetSSpacesDir;
  with TK_UDDCSSpace(WDSSD).GetVectorsDir do begin
    h := DirHigh;
    for i := 0 to h do begin
      UDProj := TK_UDVector(DirChild(i));
      if UDProj.Owner <> WSSRoot then continue;
      CmBPList.Items.AddObject( UDProj.ObjAliase, UDProj );
    end;
    UDProj := TK_UDVector(DirChild(InitUDCPIndex));
    if UDProj = nil then InitUDCPIndex := -1;
  end;

  if ShowInd = -2 then begin
    ShowInd := InitUDCPIndex;
    if ShowInd = -1 then ShowInd := 0;
  end else if ShowInd = -1 then
    ShowInd := CmBPList.Items.Count - 1;
  CmBPList.ItemIndex := ShowInd;
  CmBPList.Enabled := true;
  InitUDCPIndex := -1;
  CmBPListSelect(nil);

end;

procedure TK_FormDCSProjection.PrepareDCSpaceDShow( UDCSpace : TK_UDDCSpace );
begin
  if (UDCSpace = nil) or
     (CurUDCSpaceDest = UDCSpace) then Exit;
  CurUDCSpaceDest := UDCSpace;
  with TK_PDCSpace(CurUDCSpaceDest.R.P)^ do begin
//*** prepare editing
    K_FrameRAEditD.SetGridLRowsNumber( Codes.ALength );

    K_FrameRAEditD.SetDataPointersFromColumnRArrays(
                          Codes, nil, -1, 0, 2, 2 );
  end;
  K_FrameRAEditD.SGrid.Invalidate;
  PrepareProjList;
//  PrepareDCSProjShow( K_DCSpaceProjectionGet( CurUDCSpaceSrc, CurUDCSpaceDest ) );
end;

procedure TK_FormDCSProjection.PrepareDCSpaceSShow( UDCSpace : TK_UDDCSpace );
begin
  if (UDCSpace = nil) or
     (CurUDCSpaceSrc = UDCSpace) then Exit;
  CurUDCSpaceSrc := UDCSpace;
  with TK_PDCSpace(CurUDCSpaceSrc.R.P)^ do begin
//*** prepare editing
    K_FrameRAEditS.SetGridLRowsNumber( Codes.ALength );

    K_FrameRAEditS.SetDataPointersFromColumnRArrays(
                          Codes, nil, -1 );
  end;
  K_FrameRAEditS.RebuildGridInfo;
  K_FrameRAEditS.SGrid.Invalidate;

  PrepareProjList;
//  PrepareDCSProjShow( K_DCSpaceProjectionGet( CurUDCSpaceSrc, CurUDCSpaceDest ) );

end;

procedure TK_FormDCSProjection.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
end;


procedure TK_FormDCSProjection.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SaveDataIfNeeded;
  if not CanClose then Exit;
  CurUDCSpaceSrc := nil;
  CurUDCSpaceDest := nil;
  CurUDCSProj := nil;
end;

procedure TK_FormDCSProjection.SaveCurDCSProjExecute(Sender: TObject);
begin
  if not DataWasChanged then Exit;
  SaveDataToCurDCSProj;
end;

procedure TK_FormDCSProjection.CreateCurDCSProjExecute(Sender: TObject);
var
  NName, NAliase : string;
begin
  with CurUDCSpaceSrc.GetSSpacesDir do begin
    NAliase := BuildUniqChildName(
      CurUDCSpaceSrc.GetUName+' > '+CurUDCSpaceDest.GetUName,
      nil, K_ontObjAliase );
    NName := BuildUniqChildName( K_DCSpaceDefProjNameBuild( CurUDCSpaceSrc, CurUDCSpaceDest ) );
  end;
  if not K_EditNameAndAliase(  NAliase, NName ) then Exit;
  K_DCSpaceProjectionCreate( CurUDCSpaceSrc, CurUDCSpaceDest, NAliase, NName );
  PrepareProjList( -1 );
  ProjWasCreated := true;
  K_CurSpacesRoot.RebuildVNodes();
  AddChangeDataFlag;
end;

procedure TK_FormDCSProjection.EdCommentChange(Sender: TObject);
var Ind : Integer;
begin
  Ind := CmBPList.ItemIndex;
  if Ind = -1 then Exit;
  CmBPList.ItemIndex := -1;
  CmBPList.Items[Ind] := EdComment.Text;
  CmBPList.ItemIndex := Ind;
  AddChangeDataFlag;
end;

procedure TK_FormDCSProjection.BuildByRProjExecute(Sender: TObject);
var
 RProj : TK_UDVector;
 i, h, IndD : Integer;
begin
  AddChangeDataFlag;
  RProj := K_DCSpaceProjectionGet( CurUDCSpaceDest, CurUDCSpaceSrc );
  h := RProj.PDRA.AHigh;
//*** build Dest Data pointers using RProjection
  with K_FrameRAEditD do begin
    for i := 0 to h do begin
      IndD := PInteger(RProj.DP(i))^;
      DataPointers[IndD][0] :=
        K_FrameRAEditS.DataPointers[i][0];
      DataPointers[IndD][1] :=
        K_FrameRAEditS.DataPointers[i][1];
    end;
    SGrid.Invalidate;
  end;

end;

procedure TK_FormDCSProjection.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
end;

procedure TK_FormDCSProjection.CmBPListSelect(Sender: TObject);
begin
  if SaveDataIfNeeded then begin
    CurUDCPIndex := CmBPList.ItemIndex;
    with CmBPList do
      if CurUDCPIndex <> -1 then
        PrepareDCSProjShow( TK_UDVector(CmBPList.Items.Objects[CurUDCPIndex]) );
  end else begin
    CmBPList.ItemIndex := CurUDCPIndex;
  end;

end;

procedure TK_FormDCSProjection.CLoseExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TK_FormDCSProjection.AddItemsExecute(Sender: TObject);
var
  GRS, GRD : TGridRect;
  IndS, IndD, leng : Integer;
begin
  if not BBtnAdd.Enabled then Exit;
  GRS := K_FrameRAEditS.SGrid.Selection;
  GRS.Top := Max( GRS.Top, 1 );
  GRD := K_FrameRAEditD.SGrid.Selection;
  GRD.Top := Max( GRD.Top, 1 );
  IndS := GRS.Top - 1;
  IndD := GRD.Top - 1;
  with K_FrameRAEditD do begin
    leng := Length(DataPointers);
    while (IndS < GRS.Bottom) and (IndD < leng) do begin // move data
        DataPointers[IndD][0] :=
          K_FrameRAEditS.DataPointers[IndS][0];
        DataPointers[IndD][1] :=
          K_FrameRAEditS.DataPointers[IndS][1];
      Inc(IndS);
      Inc(IndD);
      AddChangeDataFlag;
    end;
    SGrid.Invalidate;
  end;
end;

procedure TK_FormDCSProjection.DelItemsExecute(Sender: TObject);
var
  GR : TGridRect;
  LPos1, LPos2 : TK_GridPos;
begin
  if not BBtnDel.Enabled then Exit;
  with K_FrameRAEditD do begin
    GR := SGrid.Selection;
    GR.Top := Max( GR.Top, 1 );
    GR.Left := Max( GR.Left, 1 );
    LPos1 := ToLogicPos(GR.Left, GR.Top);
    LPos2 := ToLogicPos(GR.Right, GR.Bottom);
    Dec( Lpos2.Row, LPos1.Row - 1 );
    if Lpos2.Row > 0 then begin
      ClearDataPointers( 0, LPos1.Row, 2, Lpos2.Row );
      AddChangeDataFlag;
      SGrid.Invalidate;
    end;
  end;
end;

procedure TK_FormDCSProjection.RenameDCSProjExecute(Sender: TObject);
var Ind : Integer;
begin
  if K_EditUDNameAndAliase(  CurUDCSProj ) then begin
    with CurUDCSpaceSrc.GetSSpacesDir do begin
      SetUniqChildName( CurUDCSProj );
      SetUniqChildName( CurUDCSProj, K_ontObjAliase );
    end;
    if not ProjWasCreated  and Assigned(OnGlobalAction) then
      OnGlobalAction( Self, K_fgaOK );
    EdID.Text := CurUDCSProj.ObjName;
    EdComment.Text := CurUDCSProj.GetUName;
    Ind := CmBPList.ItemIndex;
    CmBPList.ItemIndex := -1;
    CmBPList.Items[Ind] := EdComment.Text;
    CmBPList.ItemIndex := Ind;
    K_SetChangeSubTreeFlags( CurUDCSProj );
  end;

end;

end.
