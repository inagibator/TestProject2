{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit K_DTE1;
// low lewel procedures for Data Tree Editing

interface
uses Windows, Classes, Dialogs, Comctrls, Sysutils,
     K_UDT1, K_UDConst, N_PDTree1, N_ClassRef;

function  N_GetActiveVTree (): TN_VTree;
//procedure N_AddObjList ( VTree: TN_VTree; ObjList: TList; WhereToAdd,
//                                           GetFlags, ShowLevels: integer );
//procedure N_AddOneObj ( VTree: TN_VTree; UObj: TN_UDBase; WhereToAdd: integer );
function K_UpdateObjSubTree( Node, Parent : TN_UDBase): TN_UDBase;
function  K_UpdateObj( var Node : TN_UDBase): Boolean;
function  K_UpdateObjFields( var Node : TN_UDBase): Boolean;
//procedure K_ReplaceNode( CurNode, NewNode, SubTree: TN_UDBase);
function  N_DeleteVNodesList( VNodesList: TList; ErrMesage : string ) : Boolean;
procedure K_AddFromClipBoard ( VTree: TN_VTree; UDClipBoard: TN_UDBase;
                        WhereToAdd : Integer = 2;
                        DirFlags : LongWord = K_fuUseGlobal;
                        EntryFlags : LongWord = K_fuDEDataReplace or K_fuUseGlobal;
                        DescFlags : Int64 = 0 );
procedure K_AddNewObj ( VTree: TN_VTree; udb : TN_UDBase; WhereToAdd: integer );
//function  K_GetSelectedVnode( VTree: TN_VTree ) : TN_VNode;

implementation
uses
  N_Types, N_Lib1, N_PBase, N_PWin, N_MemoFr,
  K_UDC, K_FEText, K_STBuf, K_SBuf, K_IWatch, K_CLib0;

//*********************** Global procedures ********************

//************************************ N_GetSelectedVNode ***
// returns active VTree in N_ActivePage, or nil,
// if N_ActivePage is not TN_DTreePage or there is no VTree
//
function  N_GetActiveVTree (): TN_VTree;
begin
  Result := nil;
  if N_ActivePage = nil then Exit;
  if not (N_ActivePage is TN_DTree1Page) then Exit;
  Result := TN_DTree1Page(N_ActivePage).VTF.VTree;
end; //*** end of function N_GetSelectedVNode

//************************************************ K_UpdateObj ***
// update specified UObj by its text representation in TMemo
//
function K_UpdateObj( var Node : TN_UDBase): Boolean;
begin
  Result := false;
  try
    K_SaveTreeToText( Node,  K_SerialTextBuf );
  except end;
  if K_GetFormTextEdit.EditStrings( K_SerialTextBuf.TextStrings, Node.ObjName ) then
  begin
    Result := true;
    try
      Node := K_LoadTreeFromText( K_SerialTextBuf );
    except
      Result := false;
    end;
  end;
end; //*** end of function K_UpdateObj

//************************************************ K_UpdateObjFields ***
// update specified UObj by its text representation in TMemo
//
function K_UpdateObjFields( var Node : TN_UDBase): Boolean;
begin
  Result := false;
  try
    K_SaveFieldsToText( Node,  K_SerialTextBuf );
  except end;
  if K_GetFormTextEdit.EditStrings( K_SerialTextBuf.TextStrings, Node.ObjName ) then
  begin
    Result := true;
    try
      K_LoadFieldsFromText( Node,  K_SerialTextBuf );
    except
      Result := false;
    end;
    Node.RebuildVNodes(0);
  end;
end; //*** end of function K_UpdateObjFields
{
//************************************************ K_ReplaceNode ***
// Replace CurNode by NewNode in given SubTree
//
procedure K_ReplaceNode( CurNode, NewNode, SubTree: TN_UDBase);
var
  ref : TK_UDRefsRep;
begin
  ref.OldChild := CurNode;
  ref.NewChild := NewNode;
  K_TreeViewsUpdateModeSet;
  K_RSTNAddPair( ref.OldChild, ref.NewChild );
  K_RSTNExecute( SubTree );

  K_TreeViewsUpdateModeClear;
end; //*** end of function K_ReplaceNode
}
//************************************************ K_UpdateObjSubTree ***
// update selected UObj by its text representation in TMemo
//
function K_UpdateObjSubTree( Node, Parent : TN_UDBase): TN_UDBase;
var
  ref : TK_UDRefsRep;
begin
// check if active page, VTree and updating node is selected
  ref.OldChild := Node;
  ref.NewChild := ref.OldChild;
  if K_UpdateObj( ref.NewChild ) and (Parent <> nil) then
  begin
    K_TreeViewsUpdateModeSet;
    K_RSTNAddPair( ref.OldChild, ref.NewChild );
    K_RSTNExecute( Parent );

    K_TreeViewsUpdateModeClear;
  end;
  Result := ref.NewChild;
end; //*** end of function K_UpdateObjSubTree

//************************************************ N_DeleteVNodesList ***
// Delete given list of VNodes and theirs UObj from Parent objects.
//
function N_DeleteVNodesList( VNodesList: TList; ErrMesage : string ) : Boolean;
var
  i, j, k : integer;
  VNode : TN_VNode;
  DelOK, DelCur : Boolean;
begin
  Result := true;
  if VNodesList = nil then Exit;

  K_TreeViewsUpdateModeSet;

  DelOK := true;
  j := 0;
  k := VNodesList.Count - 1;
  for i := 0 to k do // loop along given list of VNodes
  begin
    VNode := TN_VNode(VNodesList.Items[j]);
    DelCur := (VNode.GetParentUObj.DeleteDirEntry( -1, VNode.VNCode ) <= K_DRisOK); // free Dir Entry and delete UObj
    DelOK := DelOK and DelCur;
    if not DelCur then Inc(j);
  end; // for i := 0 to VNodesList.Count-1 do
  if not DelOK then
  begin
    beep;
    K_InfoWatch.AddInfoLine( ErrMesage );
    K_ShowMessage( ErrMesage );
    Result := false;
  end;

  K_TreeViewsUpdateModeClear;

end; //*** end of procedure N_DeleteVNodesList

//************************************************ K_AddFromClipBoard ***
// add nodes from given ClipBoard
// VTree     - VTree with Selected VNode defines adding position
// ClipBoard - given list of objects to add
// WhereToAdd =0 - insert before dir entry defind by Selected VNode
//            =1 - add as last child of dir entry defind by Selected VNoded
//            =2 - add as last sibling of dir entry defind by Selected VNoded
//            =3 - replace dir entry defind by Selected VNode
// GetFlags   - update tree flags
//
procedure K_AddFromClipBoard ( VTree: TN_VTree; UDClipBoard: TN_UDBase;
                        WhereToAdd : Integer = 2;
                        DirFlags : LongWord = K_fuUseGlobal;
                        EntryFlags : LongWord = K_fuDEDataReplace or K_fuUseGlobal;
                        DescFlags : Int64 = 0 );
{
var VNode : TN_VNode;
  DestNode, PosNode : TN_UDBase;
  PosNumber, PosCurSize, StartD, SizeD : Integer;
//  treeMerge : TK_TreeMerge;
  WVNode : TN_VNode;
}
begin

{
  VNode := VTree.GetSelectedVnode(  );
  PosNumber := 0;
  if VNode = nil then begin
    DestNode := VTree.RootUObj;
    if DestNode = nil then Exit;
    WhereToAdd := 1; // add as childs mode
  end else begin
    PosNode := VNode.VNUDObj;
    DestNode := VNode.GetParentUobj;
    PosNumber := DestNode.IndexOfDEField( VNode.VNCode, K_isVCode );
    if WhereToAdd = 1 then DestNode := PosNode; // add as childs
  end;
}
  K_TreeViewsUpdateModeSet;
//*** define selected obj and its dir Entry
{
  StartD := 0;
  SizeD := -1;

  if WhereToAdd = 3 then begin// replace selected
    if (EntryFlags and K_fuDEDataExchange) <> 0 then  begin
    // data exchange mode - replace data started from selected
      StartD := PosNumber;
      SizeD := UDClipBoard.DirLength;
    end else begin
    // structure update mode - replace selected
      WhereToAdd := 0; // insert
      DestNode.RemoveDirEntry( PosNumber );
      SizeD := 0;
    end;
  end;
  PosCurSize := DestNode.DirLength;
}
//*** update tree
{
  treeMerge := TK_TreeMerge.Create;
  treeMerge.updateFlags.AllBits := DescFlags;
  treeMerge.UpdateDir( DestNode, UDClipBoard, StartD, SizeD, 0, -1, DirFlags, EntryFlags );
  treeMerge.Free;
}
{
  if WhereToAdd = 0 then
  begin //*** move inserted nodes if insert mode
    DestNode.MoveEntries( PosNumber, PosCurSize, DestNode.DirLength - PosCurSize );
   //*** Resort TreeNodes after moving if unsorted Mode
    WVNode := DestNode.LastVNode;
    while WVNode <> nil do
    begin
      if (WVNode.VNVFlags and K_fvDirSortedMask) = K_fvDirUnsorted then
        WVNode.ReorderChildTreeNodes( WVNode.VNVFlags );
      WVNode := WVNode.PrevVNUDObjVNode;
    end;
  end;
  DestNode.RebuildVNodes;
  K_TreeViewsUpdateModeClear;
}

end; //*** end of procedure K_AddFromClipBoard

//************************************************ K_AddNewObj ***
// add new TN_UDBase node created using given its class reference index
//
procedure K_AddNewObj ( VTree: TN_VTree; udb : TN_UDBase; WhereToAdd: integer );
var
TmpClipBoard : TN_UDBase;
begin

//  VNode := K_GetSelectedVnode( VTree );
//  if VNode = nil then Exit;
  TmpClipBoard := TN_UDBase.Create;
  TmpClipBoard.AddOneChild( udb );
  K_AddFromClipBoard ( VTree, TmpClipBoard, WhereToAdd, K_fuUseCurrent,
      K_fuUseCurrent or K_fuDEDataReplace or K_fuDEChangeOwner, 0 );
  TmpClipBoard.UDDelete;
end; //*** end of procedure K_AddNewObj

{
//************************************************ K_GetSelectedVnode ***
// get selected VNode from given VTree
//
function K_GetSelectedVnode( VTree: TN_VTree ) : TN_VNode;
label ErrorExit;
begin
  if VTree = nil then goto ErrorExit;
  Result := VTree.Selected;
  if (Result = nil) or
     (Result.VNUDObj = nil) or
     (Result.TreeNode = nil) then
  begin
ErrorExit:
    Result := nil;
    Beep;
  end;
end; //*** end of procedure K_GetSelectedVnode
}
end.
