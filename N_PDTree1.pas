unit N_PDTree1;
// DTree Page (Base Page with VTreeFrame and Info Frame)

interface
uses Forms, Stdctrls, Controls, Classes, Comctrls, Extctrls,
     N_PBase, K_UDT1;

type TFrameClass = class of TFrame;

type TN_DTree1Page = class( TN_BasePage ) // Base Page with TreeView and Frame
      public
    VTF: TN_VTreeFrame;
    Frame: TFrame;
    FrameList: TList;
    Splitter: TSplitter;
    ViewVariant: integer;
//    OnMouseDownProc:   procedure( DTree1Page: TN_DTree1Page; Node: TTreeNode;
//            EventType: integer; Button: TMouseButton; Shift: TShiftState );
//    OnDoubleClickProc: procedure( DTree1Page: TN_DTree1Page; Node: TTreeNode;
//            EventType: integer; Button: TMouseButton; Shift: TShiftState );
  constructor Create( PageName: string; AParentUData: TN_UDBase;
                             AFrame: TFrame;
                             AVFlags, AVlevel, AVFlagsNum: integer  ); reintroduce;
  destructor Destroy; override;
  procedure  SetViewVariant ( NewViewVar: integer );
  procedure UpdatePageOnEndDock (); override;
  procedure PageActivate (); override;
  procedure VTFOnMouseDown_ShowNode( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
end; //*** end of type TN_DTree1Page = class( TN_BasePage )

//***************** TN_VTreeFrame event handlers **********************

procedure N_VTFOnMouseDown_ShowNode( AParent: TWinControl; Node: TTreeNode;
            EventType: integer; Button: TMouseButton; Shift: TShiftState );

procedure N_VTFOnSelect_Close( AParent: TWinControl; Node: TTreeNode;
            EventType: integer; Button: TMouseButton; Shift: TShiftState );

//****************** Other global procedures **********************

procedure N_ResetRefsToTreeNodes ( ATV: TTreeView );
procedure N_AdjustFrame( var DstFrame: TFrame; SrcFrame: TFrame );

//****************** Global variables **********************
const
//****** DTreePage view params
K_fDTPViewMask          = $03;
K_fDTPViewVTree         = $01;
K_fDTPViewMemo          = $02;
K_fDTPViewHSplit        = $04;

implementation
uses Math, Sysutils, Graphics, Dialogs,
     N_Types, N_Lib1, N_MemoFr, N_Memo2Fr;

//********** TN_DTree1Page class methods  **************

//******************************************** TN_DTree1Page.Create ***
// create DTree1Page with new TreeView, given Root obj and Frame type
// AFlags - TreeView creation flags:
//
//
constructor TN_DTree1Page.Create( PageName: string; AParentUData: TN_UDBase;
                                            AFrame: TFrame;
                                            AVFlags, AVlevel, AVFlagsNum: integer );
var
 DEFunc : TK_TestDEFunc;
begin
  inherited Create( Application ); // create TForm with TN_BasePage event handlers
  Caption := PageName;
  VTF := TN_VTreeFrame.Create( Self );
  DEFunc := nil;
  VTF.VTree := TN_VTree.Create( VTF.TreeView, AParentUData, AVFlags,
                                          AVLevel, AVFlagsNum, DEFunc );
  VTF.OnMouseDownProcObj := VTFOnMouseDown_ShowNode;

  FrameList := TList.Create;
  Frame := AFrame;       // add given frame obj
  Frame.Parent := self;
  FrameList.Add( Frame );

  Splitter := TSplitter.Create( self );
  Splitter.Parent := self;

  SetViewVariant( K_fDTPViewVTree or K_fDTPViewMemo );
end; // end_of constructor TN_DTree1Page.Create

//******************************************** TN_DTree1Page.Destroy ***
//
destructor TN_DTree1Page.Destroy;
var
  i: integer;
begin
  VTF.Free;
  VTF := nil;
  for i := 0 to FrameList.Count-1 do TFrame(FrameList.Items[i]).Free;
  FrameList.Free;
  Splitter.Free;
  inherited Destroy;
end; // end_of destructor TN_DTree1Page.Destroy

//**************************************** TN_DTree1Page.SetViewVariant ***
//    01 - show TreeView
//    02 - show Frame
//                    (03 - show both)
//    04 - 0-Vetical Splitter,  1-Horizontal Splitter
//
procedure TN_DTree1Page.SetViewVariant( NewViewVar: integer );
begin
//  self.Visible := False;
  ViewVariant := NewViewVar;
  VTF.Visible := True;
  VTF.Align   := alNone;
  Splitter.Align   := alNone;
  Splitter.Visible := False;
  Splitter.Width  := 3;
  Splitter.Height := 3;
  Frame.Align   := alNone;
  Frame.Visible := False;

  if (NewViewVar and K_fDTPViewMask) = K_fDTPViewVTree then // show TreView only
  begin
    VTF.Align := alClient;
//    self.Visible := True;
    Repaint;
    Exit;
  end;

  Splitter.Visible := True; // common settings
  Frame.Visible    := True;
  VTF.Width  := Min( self.Width div 2, 150 );
  VTF.Height := Min( self.Height div 2, 150 );

  if (NewViewVar and 04) = K_fDTPViewHSplit then //****** Horizontal Splitter
  begin
    VTF.Align := alTop;
    Splitter.Top   := VTF.Height + 5;
    Splitter.Align := alTop;
    Frame.Top      := Splitter.Top + 5;
  end
  else //*************************** Vertical splitter
  begin
    VTF.Align := alLeft;
    Splitter.Left  := VTF.Width + 5;
    Splitter.Align := alLeft;
    Frame.Left     := Splitter.Left + 5;
  end;

  Frame.Align := alClient;
//  self.Visible := True;
  Repaint;
end; //***** end of procedure TN_DTree1Page.SetViewVariant

//************************************* TN_DTree1Page.UpdatePageOnEndDock ***
// update references to TTreeNodes, that are changed while docking
//
procedure TN_DTree1Page.UpdatePageOnEndDock();
begin
//  if VTF.VTree <> nil then
    N_ResetRefsToTreeNodes( VTF.VTree.TreeView );
end; // end of TN_DTree1Page.UpdatePageOnEndDock

//********************************************** TN_DTree1Page.PageActivate ***
// set N_ActivePage := self, N_ActiveVTree := self.TreeView
// and update Page Caption
// ( is called from TN_BasePage.FormActivate event handler)
//
procedure TN_DTree1Page.PageActivate();
begin
  inherited;
  if VTF <> nil then
    N_ActiveVTree := VTF.VTree;
end; // end of procedure TN_DTree1Page.PageActivate

//********************************************** TN_DTree1Page.VTFOnMouseDown_ShowNode ***
// show Node Attributes and User Data
// (implementation of TN_VTreeFrame OnMouseDownProc)
//
procedure TN_DTree1Page.VTFOnMouseDown_ShowNode( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
var
  TS: TStrings;
  UData: TN_UDBase;
  AObj: TObject;
  DTree1Page: TN_DTree1Page;
begin
  DTree1Page := TN_DTree1Page(AVTreeFrame.Owner);
  TS := TN_MemoFrame(DTree1Page.Frame).Memo.Lines;
  TS.Clear;

  AObj := AVNode.VNUDObj;
  if not (AObj is TN_UDBase) then
  begin
    ShowMessage( 'ERROR:  Node.Data is not of TN_UDBase type!' );
    Exit;
  end;
  UData := TN_UDBase(AObj);

//  TS.Add( Format( 'Node adr, ref= %.7x %.7x ', // debug
//          [ integer(Node), integer(TN_VNode(Node.Data).TreeNode) ] ) );

  if UData <> nil then
  begin
    if not (UData is TN_UDBase) then
      ShowMessage( 'ERROR:  UData is not of TN_UDataBase type!' )
    else
      AVNode.SaveToStrings( TS, 0 );
  end;
end; // end of procedure TN_DTree1Page.VTFOnMouseDown_ShowNode

//****************** Global procedures **********************

//***************** TN_VTreeFrame event handlers **********************

//**************************************** N_VTFOnMouseDown_ShowNode ***
// show Node Attributes and User Data
// (implementation of TN_VTreeFrame OnMouseDownProc)
//
procedure N_VTFOnMouseDown_ShowNode( AParent: TWinControl; Node: TTreeNode;
            EventType: integer; Button: TMouseButton; Shift: TShiftState );
var
  TS: TStrings;
  UData: TN_UDBase;
  AObj: TObject;
  DTree1Page: TN_DTree1Page;
  VNode : TN_VNode;
begin
  DTree1Page := TN_DTree1Page(AParent);
  TS := TN_MemoFrame(DTree1Page.Frame).Memo.Lines;
  TS.Clear;
  AObj := TObject(Node.Data);
  if not (AObj is TN_VNode) then
  begin
    ShowMessage( 'ERROR:  Node.Data is not of TN_VNode type!' );
    Exit;
  end;
  VNode := TN_VNode(AObj);
  AObj := VNode.VNUDObj;
  if not (AObj is TN_UDBase) then
  begin
    ShowMessage( 'ERROR:  Node.Data is not of TN_UDBase type!' );
    Exit;
  end;
  UData := TN_UDBase(AObj);

//  TS.Add( Format( 'Node adr, ref= %.7x %.7x ', // debug
//          [ integer(Node), integer(TN_VNode(Node.Data).TreeNode) ] ) );

  if UData <> nil then
  begin
    if not (UData is TN_UDBase) then
      ShowMessage( 'ERROR:  UData is not of TN_UDataBase type!' )
    else
      VNode.SaveToStrings( TS, 0 );
  end;
end; // end of procedure N_VTFOnMouseDown_ShowNode

//**************************************** N_VTFOnSelect_Close ***
// close Parent Page after some node was selected
// (implementation of TN_VTreeFrame OnMouseDownProc)
//
procedure N_VTFOnSelect_Close( AParent: TWinControl; Node: TTreeNode;
            EventType: integer; Button: TMouseButton; Shift: TShiftState );
begin
  if AParent is TForm then TForm(AParent).Close;
end; // end of procedure N_VTFOnSelect_Close

//****************** Other global procedures **********************

//****************************************** N_ResetRefsToTreeNodes ***
// reset references to TTreeNodes (they are changed while docking)
//
procedure N_ResetRefsToTreeNodes( ATV: TTreeView );
var
  TNode: TTreeNode;
  VNPar: TN_VNode;
begin
  if ATV.Items.Count >= 1 then
  begin
    TNode := ATV.Items[0];
    repeat
      VNPar := TN_VNode(TNode.Data);
      if VNPar.VNTreeNode <> TNode then VNPar.VNTreeNode := TNode;
      TNode := TNode.GetNext;
    until (TNode = nil) or (TNode.Data = nil);
  end;
end; // end of procedure N_ResetRefsToTreeNodes

procedure N_AdjustFrame( var DstFrame: TFrame; SrcFrame: TFrame );
begin
  DstFrame.Top    := SrcFrame.Top;
  DstFrame.Left   := SrcFrame.Left;
  DstFrame.Width  := SrcFrame.Width;
  DstFrame.Height := SrcFrame.Height;
  DstFrame.Align  := SrcFrame.Align;
  DstFrame.Visible := SrcFrame.Visible;
end;

end.
