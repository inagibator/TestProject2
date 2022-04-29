unit K_FrUDList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ActnList,
  K_FSelectUDB, K_UDT1;

type
  TK_FrameUDList = class(TFrame)
    CmB: TComboBox;
    UDIcon: TImage;
    BtTreeSelect: TButton;
    ActionList1: TActionList;
    SelectUDObj: TAction;
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    function  GetRootPathToObj( AUDObj: TN_UDBase ) : string;
    procedure AddUDObjToTop( TopUDObj : TN_UDBase; TopUDParent: TN_UDBase = nil );
    procedure RebuildTopUDObjName;
    procedure SelectUDObjExecute(Sender: TObject);
    procedure InitByPathIndex( Ind : Integer = -1 );
    procedure CmBSelect(Sender: TObject);
    procedure RebuildPathList;
    procedure SetNewSelected( NewSelPath : string );
    procedure CmBDblClick(Sender: TObject);
    procedure CmBKeyDown( Sender: TObject; var Key: Word;
                          Shift: TShiftState );
  private
    { Private declarations }
    DE : TN_DirEntryPar;
    SkipCmBSelctHandle : Boolean;
    UDTS : TK_UDTreeSelect;
    procedure SetUDRoot( UDRoot : TN_UDBase );
    procedure SetShowToolBar( AShowToolBar : Boolean );
  public
    { Public declarations }
// History List Context
    MaxListSize : Integer;
    PathList : TStringList;
// Selection Context
    FRUDListRootPath : string;
//    FRUDListRoot : TN_UDBase;
    SFilter : TK_UDFilter;
    SelButtonHint : string;
    SelCaption : string;
//    SelShowToolBar : Boolean;
// Current Selected Context
    UDParent : TN_UDBase;
    UDObj : TN_UDBase;
    OnUDObjSelect : procedure ( UDSelected : TN_UDBase ) of object;

    property FRUDListRoot : TN_UDBase write SetUDRoot;
    property SelShowToolBar : Boolean write SetShowToolBar;
  end;

implementation

uses
  N_Lib1, N_Types, N_ButtonsF,
  K_UDConst, K_UDT2;

{$R *.dfm}
//**************************************** TK_FrameUDList.Create
//
constructor TK_FrameUDList.Create( AOwner: TComponent );
begin
  inherited;
  PathList := TStringList.Create;
  SFilter := TK_UDFilter.Create;
  MaxListSize := 20;
  UDTS := TK_UDTreeSelect.Create;
  UDTS.FSelectFFunc := SFilter.UDFTest;
end; // end of TK_FrameUDList.Create

//**************************************** TK_FrameUDList.Destroy
//
destructor TK_FrameUDList.Destroy;
begin
  PathList.Free;
  SFilter.Free;
  UDTS.Free;
  inherited;
end; // end of TK_FrameUDList.Destroy

//**************************************** TK_FrameUDList.GetRootPathToObj
// Set new Selected UDObject
//
function TK_FrameUDList.GetRootPathToObj( AUDObj: TN_UDBase ) : string;
begin
//  Result := UDTS.FPrevRootUDNode.GetRefPathToObj( AUDObj );
//  if Result = '' then
//    Result := UDTS.FPrevRootUDNode.GetPathToObj( AUDObj );
  Result := K_GetPathToUObj( AUDObj, UDTS.FPrevRootUDNode );
  assert(Result <> '', 'TK_FrameUDList - could not get path top object');
end; // end of TK_FrameUDList.GetRootPathToObj

//**************************************** TK_FrameUDList.AddUDObjToTop
// Set new Selected UDObject
//
procedure TK_FrameUDList.AddUDObjToTop( TopUDObj: TN_UDBase; TopUDParent: TN_UDBase = nil );
begin
  DE.Child := TopUDObj;
  DE.Parent := TopUDParent;
//*** Build path to UDObj
  SetNewSelected( GetRootPathToObj( TopUDObj ) );
end; // end of TK_FrameUDList.AddUDObjToTop

//**************************************** TK_FrameUDList.RebuildTopUDObjName
// Set new Selected UDObject
//
procedure TK_FrameUDList.RebuildTopUDObjName;
var
  WRPath : string;
begin
  if UDObj = nil then Exit;
  WRPath := GetRootPathToObj(UDObj);
  PathList[0] := WRPath;
  CmB.Items[0] := UDObj.GetUName;
  SkipCmBSelctHandle := CmB.ItemIndex <> 0;
  CmB.ItemIndex := 0;
end; // end of TK_FrameUDList.RebuildTopUDObjName

//**************************************** TK_FrameUDList.RebuildPathList
// Set new Selected UDObject
//
procedure TK_FrameUDList.RebuildPathList;
var
  WInd, i : Integer;
  L : TList;
begin
  CmB.Items.Clear;
  L := TList.Create;
  i := 0;
  while i < PathList.Count do begin
    WInd := UDTS.FPrevRootUDNode.GetDEByRPath( PathList[i], DE );
    if (WInd < 0) or (L.IndexOf(DE.Child) <> -1) then
      PathList.Delete(i)
    else begin
      L.Add(DE.Child);
      CmB.Items.Add( DE.Child.GetUName);
      Inc(i);
    end;
  end;
  L.Free;
  CmB.ItemIndex := 0;
end; // end of RebuildPathList

//**************************************** TK_FrameUDList.SetNewSelected
// Set new Selected UDObject
//
procedure TK_FrameUDList.SetNewSelected( NewSelPath: string );
begin
  UDParent := DE.Parent;
  UDObj := DE.Child;
  N_AddUniqStrToTop( PathList, NewSelPath, MaxListSize );
  if UDIcon.Visible then
    N_ButtonsForm.IconsList.GetBitmap(UDObj.ImgInd, UDIcon.Picture.Bitmap);
  RebuildPathList;
  if Assigned(OnUDObjSelect) then OnUDObjSelect(UDObj);
end; // end of TK_FrameUDList.SetNewSelected

//**************************************** TK_FrameUDList.SelectUDObjExecute
// Select UDObject from UDTree
//
procedure TK_FrameUDList.SelectUDObjExecute(Sender: TObject);
var
  WRPath : string;
begin
  if UDTS.FPrevRootUDNode = nil then begin //*** Build Root
    if FRUDListRootPath <> K_udpAbsPathCursorName then
      UDTS.FPrevRootUDNode := K_UDCursorGetObj( FRUDListRootPath );
    if UDTS.FPrevRootUDNode = nil then UDTS.FPrevRootUDNode := K_CurArchive;
    if UDTS.FPrevRootUDNode = nil then begin
      if FRUDListRootPath = K_udpAbsPathCursorName then
        UDTS.FPrevRootUDNode := K_MainRootObj
      else
        UDTS.FPrevRootUDNode := K_ArchsRootObj;
    end;
  end;
  if PathList.Count > 0 then
    WRPath := PathList[0]
  else
    WRPath := '';
{
  if (WRPath = '') and (UDObj <> nil) then WRPath := GetRootPathToObj( UDObj );
  if K_SelectDEOpen( DE, UDTS.FPrevRootUDNode, WRPath, SFilter.UDFTest, SelCaption, UDTS.FShowToolBar ) then
    SetNewSelected( K_SelectedPath );
}
  UDTS.SetSelected( WRPath, UDObj, nil );
  if UDTS.SelectUDB( UDObj, nil, SelCaption ) then
    SetNewSelected( UDTS.GetSelectedPath );


end; // end of TK_FrameUDList.SelectUDObjExecute

//**************************************** TK_FrameUDList.InitByPathIndex
// Set Current Selected
//
procedure TK_FrameUDList.InitByPathIndex( Ind : Integer = -1 );
var
  Path: string;
  PathPos : Integer;
begin
  if Ind = -1 then begin
    Ind := 0;
    RebuildPathList;
  end;

  if SelButtonHint <> '' then
    BtTreeSelect.Hint := SelButtonHint;
  if Ind < PathList.Count then
    Path := PathList[Ind]
  else
    Path := '';
  if Path = '' then begin
    UDObj := nil;
    UDParent := nil;
    Exit;
  end;

  PathPos := UDTS.FPrevRootUDNode.GetDEByRPath( Path, DE );
  if PathPos < 0 then begin
    UDObj := nil;
    UDParent := nil;
    CmB.Items.Add( '?' );
    CmB.ItemIndex := 0;
  end else
    SetNewSelected( Path );

end; // end of TK_FrameUDList.InitByPathIndex

//**************************************** TK_FrameUDList.CmBSelect
//
procedure TK_FrameUDList.CmBSelect(Sender: TObject);
begin
  if not SkipCmBSelctHandle then
    InitByPathIndex( CmB.ItemIndex );
  SkipCmBSelctHandle := false;
end; // end of TK_FrameUDList.CmBSelect

//**************************************** TK_FrameUDList.CmBDblClick
//
procedure TK_FrameUDList.CmBDblClick(Sender: TObject);
begin
  SelectUDObjExecute(Sender);
end; // end of TK_FrameUDList.CmBDblClick

//**************************************** TK_FrameUDList.CmBKeyDown
//
procedure TK_FrameUDList.CmBKeyDown( Sender: TObject; var Key: Word;
                                     Shift: TShiftState );
begin  if Key = VK_RETURN then
    SelectUDObjExecute(Sender);
end; // end of TK_FrameUDList.CmBKeyDown

//**************************************** TK_FrameUDList.SetUDRoot
//
procedure TK_FrameUDList.SetUDRoot( UDRoot : TN_UDBase );
begin
  UDTS.FPrevRootUDNode := UDRoot;
end; // end of TK_FrameUDList.SetUDRoot

//**************************************** TK_FrameUDList.SetShowToolBar
//
procedure TK_FrameUDList.SetShowToolBar( AShowToolBar : Boolean );
begin
  UDTS.FShowToolBar := AShowToolBar;
end; // end of TK_FrameUDList.SetShowToolBar

end.
