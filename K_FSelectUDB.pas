unit K_FSelectUDB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls,
  K_UDT1, K_UDT2,
  N_BaseF, ToolWin;

//##/*
type
  TK_FormSelectUDB = class( TN_BaseForm )
    VTreeFrame: TN_VTreeFrame;
    PnSelect: TPanel;
    BtOK: TButton;
    BtCancel: TButton;
    PnSaveAs: TPanel;
    BtOK1: TButton;
    BtCansel1: TButton;
    EdObjName: TEdit;
    LbObjName: TLabel;
    LbObjType: TLabel;
    CmBObjType: TComboBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
//    function  GetMarkedVNodesList(  ) : TList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    { Private declarations }
  public
    procedure Init0();
  private
//    SelectFilter : TK_UDFilter;
    TestDEProc : TK_TestDEFunc;
    procedure OnAction( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                        Button: TMouseButton; Shift: TShiftState );
    procedure OnSelect( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                        Button: TMouseButton; Shift: TShiftState );
    procedure PrepareVtree( ARootNode : TN_UDBase;
                const APath : string = '';
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  );
    procedure SetSelectPath( const APath : string = '' );
//    procedure ClearVTreeFilter( );
    function  SelectDE( var DE : TN_DirEntryPar;
                SFilterFunc : TK_TestDEFunc = nil;
//                SFilter : TK_UDFilter = nil;
                const capt : string = '' ) : Boolean;
  public
    { Public declarations }
  end; //*** end   TK_FormSelectUDB = class(TForm)
//##*/

type TK_UDTreeSelect = class (TObject)
//  View
  FPrevRootUDNode : TN_UDBase; // Previous UDRoot
  FRootPath : string; // Saved Root Path
  FMarkedPathList   : TStringList; // Marked Nodes List
  FExpandedPathList : TStringList; // Expanded Nodes List
  FSelectFFunc  : TK_TestDEFunc; // Select UDNodes Test Func
  FShowFFunc    : TK_TestDEFunc; // Show UDNodes Test Func
  FShowToolBar  : Boolean;       // Show ViewForm ToolBar Flag
  FMultiMark  : Boolean;         // TreeView MultiMark Flag
  FMaxVLevel    : integer;       // Maximal UDTree View Level
  FVChildsFlags : integer;       // VTree Show Childs Flgs
  FVFlagsNum    : integer;       // UDNodes Self ViewFlags Index
  FSelectedDE   : TN_DirEntryPar;// Selected UDNode DirEntryParams
  constructor Create();
  destructor  Destroy(); override;
  procedure InitViewStateFromVTreeFrame( AVTF : TN_VTreeFrame; ANewRootPath : string = '' );
  procedure InitViewStateFromIniFile( IniNamePrefix : string );
  procedure SaveViewStateToIniFile  ( IniNamePrefix : string );
  procedure SetSelected( ASPath : string; ASelUDNode : TN_UDBase;
                             ARootUDNode : TN_UDBase );
  function  GetSelectedPath( ) : string;
  function  SelectUDB( var ASelUDNode : TN_UDBase; ARootUDNode : TN_UDBase;
                       ACaption : string; ADefaultUDRoot : TN_UDBase = nil ) : Boolean;
end;

var
  K_FormSelectUDB: TK_FormSelectUDB;
  K_SelectedPath: string;

function  K_SelectUDB( RootNode : TN_UDBase; const APath : string = '';
                SFilterFunc   : TK_TestDEFunc = nil;
                defnode : TN_UDBase = nil; const capt : string = '';
                AShowToolBar : Boolean = true;
                AMultiMark  : Boolean = false;
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  ) : TN_UDBase;

function  K_SelectDEOpen( var DE : TN_DirEntryPar; RootNode : TN_UDBase;
                const APath : string = '';
                ASFilterFunc : TK_TestDEFunc = nil;
//                SFilter : TK_UDFilter = nil;
                const capt : string = '';
                AShowToolBar : Boolean = true;
                AMultiMark  : Boolean = false;
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  ) : Boolean;


procedure K_SelectVTreePrepare( RootNode : TN_UDBase;
                const APath : string = '';
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  );

function  K_SelectDE( var DE : TN_DirEntryPar; ASFilterFunc : TK_TestDEFunc = nil;
                const  capt : string = '' ) : Boolean;

implementation

{$R *.DFM}

uses
  N_ButtonsF, N_ClassRef, N_Types;


//**************************************** TK_FormSelectUDB.OnAction ***
// Select Action node call from VTreeFrame event handler
//
procedure TK_FormSelectUDB.OnAction( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                        Button: TMouseButton; Shift: TShiftState );
var DE : TN_DirEntryPar;
begin
  AVNode.GetDirEntry( DE );
  if not Assigned(TestDEProc) or TestDEProc( DE ) then
  begin
    Close;
    ModalResult := mrOK;
  end;
end; // end of TK_FormSelectUDB.OnAction

//**************************************** TK_FormSelectUDB.OnSelect ***
// Select node call from VTreeFrame event handler
//
procedure TK_FormSelectUDB.OnSelect( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
                        Button: TMouseButton; Shift: TShiftState );
var DE : TN_DirEntryPar;
begin
  AVNode.GetDirEntry( DE );
  if not Assigned(TestDEProc) or TestDEProc( DE ) then
  begin
    EdObjName.Text := DE.Child.ObjName;
    BtOK1.Enabled := true;
    BtOK.Enabled := true;
  end
  else
  begin
    AVNode.UnMark();
    BtOK1.Enabled := false;
    BtOK.Enabled := false;
  end;
end; // end of TK_FormSelectUDB.OnSelect

//********************************************* TK_FormSelectUDB.PrepareVtree ***
//  prepear VTree
//
procedure TK_FormSelectUDB.PrepareVtree( ARootNode : TN_UDBase;
                const APath : string = '';
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil   );
begin
  with VTreeFrame.VTree do begin
    RootUObj   := ARootNode;
    VTFlags    := AVChildsFlags;
    VTDepth    := AVLevel;
    VTFlagsNum := AVFlagsNum;
    VTTestDEFunc := AFilterFunc;
    TreeView.ReadOnly := (VTFlags and K_fvTreeViewTextEdit) = 0;
  end;
  VTreeFrame.MultiMark := true;
  PnSaveAs.Visible := false;
//  Frame.OnActionProc := K_VTFOnAction;
//  Frame.OnSelectProc := K_VTFOnSelect;
  VTreeFrame.VTree.RebuildView( ARootNode, nil, nil );
  SetSelectPath( APath );
end; // end of TK_FormSelectUDB.PrepareVtree

//********************************************* TK_FormSelectUDB.SetSelectPath ***
//  Set New Path in Open VTree
//
procedure TK_FormSelectUDB.SetSelectPath( const APath : string = '' );
begin
  K_SelectedPath := Copy( APath, 1, Length(APath) - Abs(VTreeFrame.VTree.SetPath( APath, true )) );
end; // end of TK_FormSelectUDB.SetSelectPath
{
//********************************************* TK_FormSelectUDB.GetMarkedVNodesList ***
//  get marked vnodes list
//
function  TK_FormSelectUDB.GetMarkedVNodesList(  ) : TList;
begin

  if VTreeFrame.VTree <> nil then
    Result := VTreeFrame.VTree.MarkedVNodesList
  else
    Result := nil;
end; // end of TK_FormSelectUDB.GetMarkedVNodesList
}
{
//********************************************* TK_FormSelectUDB.ClearVtreeFilter ***
//  clear VTree Filter
//
procedure TK_FormSelectUDB.ClearVTreeFilter( );
begin
  if Frame.VTree <> nil then
  begin
    Frame.VTree.TestDE := nil;
//    Frame.VTree.FFilter := nil;
  end;
end; // TK_FormSelectUDB.ClearVTreeFilter
}

//********************************************* TK_FormSelectUDB.SelectVNode ***
//  select node form start routine
//
function TK_FormSelectUDB.SelectDE( var DE : TN_DirEntryPar;
                SFilterFunc : TK_TestDEFunc = nil;
                const capt : string = '' ) : Boolean;
begin

  TestDEProc := SFilterFunc;

  if capt <> '' then
    Caption := capt;
  VTreeFrame.TreeView.Invalidate;
  ShowModal;
  Result := false;
//  if (ModalResult = mrOK) and (Frame.VTree.Selected <> nil) then
  if (ModalResult = mrOK) then
  begin
    if (VTreeFrame.VTree.Selected <> nil) then begin
      K_SelectedPath := VTreeFrame.VTree.Selected.GetSelfVTreePath( );
      VTreeFrame.VTree.Selected.GetDirEntry( DE );
      if not Assigned(TestDEProc) or TestDEProc( DE ) then
        Result := true;
    end else begin
      DE.Child := nil;
      Result := true;
    end;
  end;
  TestDEProc := nil;

end; // end of TK_FormSelectUDB.SelectDE

//********************************************* TK_FormSelectUDB.FormClose
//
procedure TK_FormSelectUDB.FormClose( Sender: TObject;
                                      var Action: TCloseAction );
begin
  inherited;
  K_FormSelectUDB := nil;
end; // end of TK_FormSelectUDB.FormClose

//********************************************* TK_FormSelectUDB.Init0 ***
//
procedure TK_FormSelectUDB.Init0;
begin
//  BaseFormInit( nil );
  BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  VtreeFrame.CreateVTree;
  VTreeFrame.OnActionProcObj := OnAction;
  VTreeFrame.OnSelectProcObj := OnSelect;
  VTreeFrame.MultiMark := true;
  PnSaveAs.Visible := false;
end; // procedure TK_FormSelectUDB.Init0;

//********************************************* K_SelectUDB ***
//  select node form start routine
//
function K_SelectUDB( RootNode : TN_UDBase; const APath : string = '';
                SFilterFunc   : TK_TestDEFunc = nil;
                defnode : TN_UDBase = nil; const capt : string = '';
                AShowToolBar : Boolean = true;
                AMultiMark  : Boolean = false;
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  ) : TN_UDBase;
var DE : TN_DirEntryPar;
begin
  Result := defnode;
  DE.Child := nil;
  if K_SelectDEOpen( DE, RootNode, APath, SFilterFunc, capt, AShowToolBar, AMultiMark,
                     AVChildsFlags, AVLevel, AVFlagsNum, AFilterFunc ) then
    Result := DE.Child;
end; // end of K_SelectUDB

//********************************************* K_SelectDEOpen ***
//  select node form start routine
//
function K_SelectDEOpen( var DE : TN_DirEntryPar; RootNode : TN_UDBase;
                const APath : string = '';
                ASFilterFunc : TK_TestDEFunc = nil;
//                SFilter : TK_UDFilter = nil;
                const capt : string = '';
                AShowToolBar : Boolean = true;
                AMultiMark  : Boolean = false;
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil ) : Boolean;
var
  RootPath : string;
begin
  RootPath := APath;
//  if (APath = '') and (DE.Child <> nil) then begin
//    RootPath := RootNode.GetRefPathToObj( DE.Child );
//    if RootPath = '' then
//      RootPath := RootNode.GetPathToObj( DE.Child );
//  end;
  if APath = '' then
    RootPath := K_GetPathToUObj( DE.Child, RootNode );

  K_SelectVTreePrepare( RootNode, RootPath, AVChildsFlags, AVLevel, AVFlagsNum, AFilterFunc );
  K_FormSelectUDB.ToolBar1.Visible := AShowToolBar;
  K_FormSelectUDB.ToolBar1.Visible := false;
  K_FormSelectUDB.VTreeFrame.MultiMark := AMultiMark;
  Result := K_SelectDE( DE, ASFilterFunc, capt);
end; // end of K_SelectDEOpen

//********************************************* K_SelectDE ***
//  select node form start routine
//
function K_SelectDE( var DE : TN_DirEntryPar; ASFilterFunc : TK_TestDEFunc = nil;
                const  capt : string = '' ) : Boolean;
begin
  if K_FormSelectUDB <> nil then
    Result := K_FormSelectUDB.SelectDE( DE, ASFilterFunc, capt )
  else
    Result := false;
end; // end of K_SelectDE
//********************************************* K_SelectVTreePrepare ***
//  select node form start routine
//
procedure K_SelectVTreePrepare( RootNode : TN_UDBase;
                const APath : string = '';
                AVChildsFlags : integer = 0;
                AVLevel       : integer = 0;
                AVFlagsNum    : integer = 0;
                AFilterFunc   : TK_TestDEFunc = nil  );
begin
  if (K_FormSelectUDB = nil)                                 or
     (K_FormSelectUDB.VTreeFrame.VTree = nil)                     or
     (K_FormSelectUDB.VTreeFrame.VTree.RootUObj <> RootNode )     or
     (K_FormSelectUDB.VTreeFrame.VTree.VTFlags  <> AVChildsFlags) or
     (K_FormSelectUDB.VTreeFrame.VTree.VTDepth  <> AVLevel)       or
     (K_FormSelectUDB.VTreeFrame.VTree.VTFlagsNum <> AVFlagsNum) or
     (PInt64(@@K_FormSelectUDB.VTreeFrame.VTree.VTTestDEFunc)^ <> PInt64(@@AFilterFunc)^) then
  begin
   if K_FormSelectUDB = nil then
   begin
     K_FormSelectUDB := TK_FormSelectUDB.Create( Application );
     K_FormSelectUDB.Init0();
   end;
   K_FormSelectUDB.PrepareVtree( RootNode, APath, AVChildsFlags,
                                 AVLevel, AVFlagsNum, AFilterFunc );
  end else
    K_FormSelectUDB.SetSelectPath( APath );
end; // end of K_SelectVTreePrepare


{*** TK_UDTreeSelect ***}

//********************************************* TK_UDTreeSelect.Create ***
//
constructor TK_UDTreeSelect.Create;
begin
  inherited;
//  FShowToolBar :=  true;
  FMarkedPathList   := TStringList.Create(); // Marked Nodes List
  FExpandedPathList := TStringList.Create(); // Expanded Nodes List

end; // end of TK_UDTreeSelect.Create

//********************************************* TK_UDTreeSelect.Destroy ***
//
destructor TK_UDTreeSelect.Destroy;
begin
  FMarkedPathList.Free;
  FExpandedPathList.Free;
  inherited;
end; // end of TK_UDTreeSelect.Destroy

//********************************************* TK_UDTreeSelect.InitViewStateFromVTreeFrame ***
//
procedure TK_UDTreeSelect.InitViewStateFromVTreeFrame( AVTF: TN_VTreeFrame;
                                                       ANewRootPath : string = '' );
begin
  FRootPath := AVTF.FrGetCurState( FMarkedPathList, FExpandedPathList );
  if ANewRootPath <> '' then FRootPath := FRootPath;
end; // end of TK_UDTreeSelect.InitViewStateFromVTreeFrame

//********************************************* TK_UDTreeSelect.InitViewStateFromIniFile ***
//
procedure TK_UDTreeSelect.InitViewStateFromIniFile( IniNamePrefix: string );
begin
  FRootPath := K_GetVTreeStateFromMemIni( FMarkedPathList, FExpandedPathList,
                                          IniNamePrefix );
end; // end of TK_UDTreeSelect.InitViewStateFromIniFile

//********************************************* TK_UDTreeSelect.SaveViewStateToIniFile ***
//
procedure TK_UDTreeSelect.SaveViewStateToIniFile( IniNamePrefix: string );
begin
  K_SaveVTreeStateToMemIni( FMarkedPathList, FExpandedPathList,
                            FRootPath, IniNamePrefix );

end; // end of TK_UDTreeSelect.SaveViewStateToIniFile

//********************************************* TK_UDTreeSelect.SetSelected ***
//
procedure TK_UDTreeSelect.SetSelected( ASPath : string; ASelUDNode : TN_UDBase;
                                           ARootUDNode : TN_UDBase );
var
  LC : Integer;
begin
  if (ARootUDNode <> nil) and (FPrevRootUDNode <> ARootUDNode) then begin
    FExpandedPathList.Clear;
    FMarkedPathList.Clear;
    FPrevRootUDNode := ARootUDNode;
  end;
//  if (ASPath = '') and (ASelUDNode <> nil) then begin
//    ASPath := FPrevRootUDNode.GetRefPathToObj( ASelUDNode );
//    if ASPath = '' then
//      ASPath := FPrevRootUDNode.GetPathToObj( ASelUDNode );
//  end;
  if ASPath = '' then
    ASPath := K_GetPathToUObj( ASelUDNode, FPrevRootUDNode );
  if ASPath = '' then Exit;
  LC := FMarkedPathList.Count - 1;
  if LC >= 0 then
    FMarkedPathList[LC] := ASPath
  else
    FMarkedPathList.Add(ASPath);
  FExpandedPathList.Insert( 0, ASPath );
end; // end of TK_UDTreeSelect.SetSelected

//********************************************* TK_UDTreeSelect.GetSelectedPath ***
//
function TK_UDTreeSelect.GetSelectedPath( ) : string;
var
  LC : Integer;
begin
  Result := '';
  LC := FMarkedPathList.Count - 1;
  if LC >= 0 then
    Result := FMarkedPathList[LC];
end; // end of TK_UDTreeSelect.GetSelectedPath


//********************************************* TK_UDTreeSelect.SelectUDB ***
//
function TK_UDTreeSelect.SelectUDB( var ASelUDNode : TN_UDBase; ARootUDNode : TN_UDBase;
                                    ACaption: string; ADefaultUDRoot : TN_UDBase = nil ): Boolean;
begin
 with TK_FormSelectUDB.Create( Application ) do
 begin
   Init0();
   with VTreeFrame, VTree do
   begin
   // Set VTree Parameters
     VTTestDEFunc  := FShowFFunc;        // Show UDNodes Test Func
     MultiMark := FMultiMark;          // VTreeFrame MultiMark Flag
     VTDepth     := FMaxVLevel;        // Maximal UDTree View Level
     VTFlags     := FVChildsFlags;     // VTree Show Childs Flgs
     VTFlagsNum  := FVFlagsNum;        // UDNodes Self ViewFlags Index
     ToolBar1.Visible := FShowToolBar; // Show ViewForm ToolBar Flag

   // Set new selected to saved View Context
     SetSelected( '', ASelUDNode, ARootUDNode );

   // Set VTree View Context
     FrSetCurState( FRootPath, FMarkedPathList,
                    FExpandedPathList, ADefaultUDRoot, FPrevRootUDNode );

   // Call Select Dialogue
     FSelectedDE.Child := ASelUDNode;
     Result := SelectDE( FSelectedDE, FSelectFFunc, ACaption );
     if Result then
       ASelUDNode := FSelectedDE.Child;

   // Save VTree View Context
     FRootPath := FrGetCurState( FMarkedPathList, FExpandedPathList );
   end;
 end;
end; // end of TK_UDTreeSelect.SelectUDB

{*** end of TK_UDTreeSelect ***}

end.
