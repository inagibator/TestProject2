unit N_AlignF;
// Align, Move or Resize Marked Components Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Contnrs, Types,
  N_Types, N_Lib1, N_BaseF, N_CompCL, N_Rast1Fr, N_NVtreeFr, N_CompBase;

type TN_UndoCompCoords = record // Undo info for one Component
  ParentComp:  TN_UDCompVis;   // Parent Comp, may be not needed
  Comp:        TN_UDCompVis;   // Comp to Undo
  CompCoords:  TN_CompCoords;  // Comp.CompCoords field
  CompPixRect: TRect;          // Comp.CompIntPixRect field
  CompScopeRect: TRect;        // Comp Scope Rect (usually Parent.CompIntPixRect)
  ParentPixRect: TRect;        // Parent.CompIntPixRect (for Alignment)
end; // type TN_UndoCompCoords = record

type TN_AlignForm = class( TN_BaseForm ) //*****************************
    PageControl: TPageControl;
    tsPosition: TTabSheet;
    tsSize: TTabSheet;
    tsParams: TTabSheet;
    tsGrid: TTabSheet;
    bnUndo: TButton;
    edUndoLevel: TLabeledEdit;
    cbStayOnTop: TCheckBox;
    tsEdit: TTabSheet;
    cbSolid: TCheckBox;
    rgEdit: TRadioGroup;
    rgPositionX: TRadioGroup;
    rgPositionY: TRadioGroup;
    rgSizeX: TRadioGroup;
    rgSizeY: TRadioGroup;
    edScaleXY: TEdit;
    bnFix: TButton;
    bnLeft: TButton;
    bnCenterX: TButton;
    bnRight: TButton;
    bnTop: TButton;
    bnMiddleY: TButton;
    bnBottom: TButton;
    cbFixed: TCheckBox;
    bnEqSpacesX: TButton;
    bnUniformX: TButton;
    bnEqSpacesY: TButton;
    bnUniformY: TButton;
    gbXSize: TGroupBox;
    bnSmallestX: TButton;
    bnLargestX: TButton;
    bnFixedX: TButton;
    gbYSize: TGroupBox;
    bnSmallestY: TButton;
    bnLargestY: TButton;
    bnFixedY: TButton;
    Label1: TLabel;
    edSpaceCoef: TLabeledEdit;
    cbIndex: TCheckBox;

    procedure bnUndoClick        ( Sender: TObject );
    procedure bnFixClick         ( Sender: TObject );
    procedure AlignButtonsClick  ( Sender: TObject );
    procedure cbStayOnTopClick   ( Sender: TObject );
    procedure edUndoLevelKeyDown ( Sender: TObject; var Key: Word;
                                                        Shift: TShiftState );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
  public
    OwnerForm: TN_BaseForm;      // Owner, should be TN_NVTreeForm
    MCAction: TN_RFrameAction;   // MoveComps RasterFrame Action
    UndoInfo: Array of Array of TN_UndoCompCoords;
    PixRects: TN_IRArray;        // current values of Component.CompIntPixRect fields
    EnvPixRects: TRect;          // all PixRects Envelope Rect
    FixedRect: TRect;            // Fixed Rect
    DataChanged: boolean;        // some of Components Rects changed, new Undo Level is needed
    UndoFreeInd: integer;   // first Free Ind in Undo arrays (1<=UndoFreeInd<=UndoMaxInd)
    UndoFilledInd: integer; // Max filled Ind in Undo arrays
    UndoMaxInd: integer;    // Max Ind in Undo arrays (UndoLevel-1)

    procedure CloseSelf ();
    procedure ShowStr   ( AStr: string );
    procedure InitUndo  ();
    function  FillUndoAndPixRects(): boolean;
    procedure UpdateCompCoords ();
    procedure ExecAilgn ( AFunctionTag: integer );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_AlignForm = class( TN_BaseForm )

type TN_RFAMoveComps = class( TN_RFrameAction ) // Move or Resize Components by Cursor
  RFAAlignForm: TN_AlignForm; // Self creator
  RFABase: TPoint;          // saved Cursor CCBuf coords at MouseDown
  RFABaseRects: TN_IRArray; // saved all Rects coords at MouseDown
  RFARectInd: integer;      // Rect Ind near to Cursor at MouseDown
  RFAFlags: integer;        // Cursor position (relative to Rects) Flags at MouseDown

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAMoveComps = class( TN_RFrameAction )

type TN_RFAMarkComps = class( TN_RFrameAction ) // Mark, UnMark Components by Cursor
  RFANVTreeFrame: TN_NVTreeFrame; // VTreeFrame with Marked Components
  Comps: TN_UDCompVisArray;   // all Comps that can be Marked or UnMarked
  PixRects: TN_IRArray; // Comps Rects coords (synchronized with Comps array)
  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAMarkComps = class( TN_RFrameAction )


    //*********** Global Procedures  *****************************

function N_CreateAlignForm ( AOwner: TN_BaseForm ): TN_AlignForm;

var
  N_AlignForm: TN_AlignForm;

implementation
{$R *.dfm}
uses
  Math,
  K_CLib, K_UDT1,
  N_ClassRef, N_Gra0, N_Gra1, N_Lib0, N_Lib2, N_SGComp, N_NVTreeF, N_ME1,
  N_RVCTF, N_MenuF;

//****************  TN_AlignForm class handlers  ******************

procedure TN_AlignForm.bnUndoClick( Sender: TObject );
// Undo last alignment and all moving/resizing after last alignment
// Redo if Shift key is Down
// Clear all Undo Info (except Level=0) if Ctrl key is Down

  procedure RestoreCoords(); // local
  // Restore Coords by UndoInfo[UndoFreeInd] info
  var
    i: integer;
  begin
    for i := 0 to High(UndoInfo[UndoFreeInd]) do // restore coords
    with UndoInfo[UndoFreeInd,i] do
    begin
      Comp.PCCS()^    := CompCoords;
      Comp.CompIntPixRect := CompPixRect;
      PixRects[i]     := CompPixRect;
    end; // for i := 0 to High(UndoInfo[UndoFreeInd]) do // restore coords
  end; // procedure RestoreCoords(); // local

begin //******************* body of TN_AlignForm.bnUndoClick
  ShowStr( '' );

  if N_KeyIsDown( N_VKControl ) then //***** Clear all Undo Info (except Level=0)
  begin
    DataChanged := True;
    UndoFreeInd := 1; // Preserve Level=0
    UndoFilledInd := 0;
    ShowStr( 'Undo info cleared, UndoLevel=' + IntToStr(UndoFreeInd) );
  end else if N_KeyIsDown( N_VKShift ) then //***** Redo by one Level
  begin
    if UndoFreeInd > UndoFilledInd then // no info for Redo
    begin
      ShowStr( 'No Info for Redo, UndoLevel=' + IntToStr(UndoFreeInd) );
      Exit;
    end;

    RestoreCoords();
    Inc( UndoFreeInd );
    ShowStr( 'Redo Align, UndoLevel=' + IntToStr(UndoFreeInd) );
  end else //************************************** Undo by one Level
  begin
    if UndoFreeInd = 0 then // no info for Undo
    begin
      ShowStr( 'Error, UndoLevel=' + IntToStr(UndoFreeInd) );
      Exit;
    end;
    Dec( UndoFreeInd );

    RestoreCoords();

    if UndoFreeInd = 0 then UndoFreeInd := 1; // Level 0 can not be removed
    ShowStr( 'Undo Align, UndoLevel=' + IntToStr(UndoFreeInd) );
  end; // else Undo

  N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_AlignForm.bnUndoClick

procedure TN_AlignForm.bnFixClick( Sender: TObject );
// if (Shift is Up)   - Set FixedRect by First (usually the only one) Marked Component
// if (Shift is Down) - Save current PixRects state to enable Undo (increase Undo Level)
begin
  if N_KeyIsDown( N_VKShift ) then // increase Undo Level
  begin
    DataChanged := True;
    FillUndoAndPixRects();
    UpdateCompCoords(); // for debug, Comp's Coords should not changed
    ShowStr( 'Saved OK, UndoLevel=' + IntToStr(UndoFreeInd) );
  end else // Shift is Up, Set FixedRect
  begin
    FillUndoAndPixRects();
    FixedRect := PixRects[1]; // all done
    ShowStr( UndoInfo[UndoFreeInd,1].Comp.ObjName + ' Comp is Fixed' );
  end;
end; // procedure TN_AlignForm.bnFixClick

procedure TN_AlignForm.AlignButtonsClick( Sender: TObject );
// all Align Buttons OnClick Handler
begin
  ExecAilgn( TComponent(Sender).Tag );
end; // procedure TN_AlignForm.AlignButtonsClick

procedure TN_AlignForm.cbStayOnTopClick( Sender: TObject );
// set StayOnTop Form Style
begin
  if cbStayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end; // procedure TN_AlignForm.cbStayOnTopClick

procedure TN_AlignForm.edUndoLevelKeyDown( Sender: TObject; var Key: Word;
                                                         Shift: TShiftState );
// Resize Undo arrays
begin
  if Key = VK_Return then
  begin
    InitUndo();
    ShowStr( 'Undo Info Resized, UndoLevel=' + IntToStr(UndoFreeInd) );
  end;
end; // procedure TN_AlignForm.edUndoLevelKeyDown

procedure TN_AlignForm.FormClose( Sender: TObject; var Action: TCloseAction);
var
  Ind: integer;
begin
  Inherited;
  N_MEGlobObj.AlignForm := nil; // clear reference to Self

  if N_ActiveVTreeFrame <> nil then
  with TN_NVTreeForm(N_ActiveVTreeFrame.OwnerForm) do
  begin
    tbToggleEditMark.Visible := False; // Set "Mark", not Edit mode
  end;

  if N_ActiveRFrame <> nil then
  with N_ActiveRFrame do
  begin
    Ind := GetGroupInd( N_SMarkCompGName );
    TN_SGBase(RFSGroups.Items[Ind]).SkipActions := False; // enable RFAMarkAction
    Ind := GetGroupInd( N_SMoveCompGName );
    RFSGroups.Delete( Ind ); // Delete MoveComp Group
  end; // with N_ActiveRFrame do

end; // procedure TN_AlignForm.FormClose

//****************  TN_AlignForm class public methods  ************

//***********************************  TN_AlignForm.CloseSelf  ******
// Close Self ProcOfObj
// (used for closing Self in MEVTreeForm and RastVCTForm CloseForm handlers)
//
procedure TN_AlignForm.CloseSelf();
begin
  Close();
end; // end of procedure TN_AlignForm.CloseSelf

//***********************************  TN_AlignForm.ShowStr  ******
// Show given AStr in Owner Form (should be TN_NVTreeForm) StatusBar
//
procedure TN_AlignForm.ShowStr( AStr: string );
begin
  if OwnerForm is TN_NVTreeForm then
    TN_NVTreeForm(OwnerForm).StatusBar.SimpleText := AStr;
end; // procedure TN_AlignForm.ShowStr

//***********************************  TN_AlignForm.InitUndo  ******
// Initialize Undo info by edUndoLevel.Text
//
procedure TN_AlignForm.InitUndo();
var
  i, UndoLevel: integer;
begin
  UndoLevel := StrToInt( edUndoLevel.Text );

  if UndoMaxInd < UndoLevel then // just increase Undo Array
  begin
    SetLength( UndoInfo, UndoLevel );
  end else //********************** decrease Undo Array
  begin
    for i := 1 to UndoLevel-1 do // preserve last (UndoLevel-1) Undo Levels
      UndoInfo[i] := UndoInfo[i+UndoMaxInd-UndoLevel+1];

    UndoFreeInd   := UndoLevel - 1;
    UndoFilledInd := Min( UndoFilledInd, UndoFreeInd );
  end;

  UndoMaxInd := UndoLevel - 1;
end; // end of procedure TN_AlignForm.InitUndo

//***********************************  TN_AlignForm.FillUndoAndPixRects  ******
// Fill Undo info and PixRects array,
// update UndoFreeInd, UndoFilledInd, DataChanged,
// calc PixRects statistics, needed for Alignment (EnvPixRects)
//
function TN_AlignForm.FillUndoAndPixRects(): boolean;
var
  i, NumComps: integer;
  MinLeft, MaxRight, MinTop, MaxBottom: integer;
//  CommonParent, CurParent, FirstComp: TN_UDCompVis;
  CurOwner: TN_UDBase;
  VNodes: TList;
begin
  Result := False;
  ShowStr( '' );

  // Set NumComps fields, check some conditions

  VNodes := N_ActiveVTreeFrame.VTree.MarkedVNodesList;
  NumComps := VNodes.Count;
  if NumComps = 0 then
  begin
//    N_WarnByMessage( 'No Marked Components!' );
    ShowStr( 'No Marked Components!' );
    Exit;
  end;

{
  FirstComp := TN_UDCompVis(TN_VNode(VNodes.Items[0]).VNUDObj);
  if ( FirstComp.Owner is TN_UDCompVis) then
    CommonParent := TN_UDCompVis(FirstComp.Owner)
  else
  begin
//    N_WarnByMessage( 'Bad Parent Component!' );
    ShowStr( 'Bad Parent Component!' );
    Exit;
  end;
}

  //************* prepare Undo level

  if DataChanged then // new Undo Level should be prepared
  begin
    DataChanged := False;

    if UndoFreeInd < UndoMaxInd then // use next Undo level
      Inc( UndoFreeInd )
    else //*************************** free Last Undo Level and use it
    begin
      for i := 1 to High(UndoInfo)-1 do
        UndoInfo[i] := UndoInfo[i+1];

      UndoFreeInd := UndoMaxInd;
    end;

  end; // if DataChanged then // new Undo Level should be prepared

  UndoFilledInd := UndoFreeInd;
  SetLength( UndoInfo[UndoFreeInd], NumComps );
  SetLength( PixRects, NumComps );

{
  with UndoInfo[UndoFreeInd,0] do // zero element is Parent Component
  begin
    Comp := CommonParent;
    CompCoords  := Comp.PCCS()^;
    PixRects[0] := Comp.CompIntPixRect;
    CompPixRect := Comp.CompIntPixRect;
  end;
}

  MinLeft   := MaxInt;
  MaxRight  := -MaxInt;
  MinTop    := MaxInt;
  MaxBottom := -MaxInt;

  for i := 0 to NumComps-1 do // along currently Marked Components
  with TN_VNode(VNodes.Items[i]), UndoInfo[UndoFreeInd,i] do
  begin
    if not (VNUDObj is TN_UDCompVis) then
    begin
//      N_WarnByMessage( 'Not A Component!' );
      ShowStr( 'Not A Component!' );
      Exit;
    end;

    Comp := TN_UDCompVis(VNUDObj);
    CompCoords    := Comp.PCCS()^;
    CompPixRect   := Comp.CompIntPixRect;
    CompScopeRect := Comp.ScopePixRect;
    PixRects[i]   := Comp.CompIntPixRect;

    CurOwner  := TN_UDCompVis(Comp.Owner);
    if CurOwner is TN_UDCompVis then
      ParentPixRect := TN_UDCompVis(CurOwner).CompIntPixRect
    else
      ParentPixRect.Left := N_NotAnInteger;

{
    CurParent  := TN_UDCompVis(Comp.Owner);

    if CurParent <> CommonParent then // not same Parent
    begin
      N_WarnByMessage( 'Not same Parent!' );
      Exit;
    end;
}

    if PixRects[i].Left   < MinLeft   then MinLeft   := PixRects[i].Left;
    if PixRects[i].Right  > MaxRight  then MaxRight  := PixRects[i].Right;
    if PixRects[i].Top    < MinTop    then MinTop    := PixRects[i].Top;
    if PixRects[i].Bottom > MaxBottom then MaxBottom := PixRects[i].Bottom;

  end; // for i := 1 to NumComps do // along currently Marked Components

  EnvPixRects := Rect( MinLeft, MinTop, MaxRight, MaxBottom );
  N_ActiveVTreeFrame.MarkedChanged := False; // clear "MarkedList changed" flag
  Result := True; // Undo info and PixRects array are OK
end; // end of procedure TN_AlignForm.FillUndoAndPixRects

//***********************************  TN_AlignForm.UpdateCompCoords  ******
// Update CompCoords by changed PixRects and Redraw
//
procedure TN_AlignForm.UpdateCompCoords();
var
  i: integer;
begin
  for i := 0 to High(UndoInfo[UndoFreeInd]) do
    with UndoInfo[UndoFreeInd,i] do
      Comp.ChangeCompCoords( PixRects[i], CompScopeRect );

  N_ActiveRFrame.RedrawAllAndShow();
end; // end of procedure TN_AlignForm.UpdateCompCoords

//***********************************  TN_AlignForm.ExecAilgn  ******
// Do Aignment using AFunctionTag variant
// (used in AlignButtonsOnClick handler )
//
procedure TN_AlignForm.ExecAilgn( AFunctionTag: integer );
var
  i, j, Ind, Delta, BaseCoord, FreeSize, Space, X0Y1: integer;
  Size, MaxWidth, MaxHeight, MinWidth, MinHeight: integer;
  BegCenter, EndCenter, Sum, ParentWidthM1, ParentHeightM1: integer;
  CurPos, Step, SpaceCoef: double;
  Str: string;
  CalcStep, ShowStep, FixedLast, SameParentRect: boolean;
  SumSize, Middle: TPoint;
  TmpRect, ParentRect: TRect;
  OrderedPtrs: TN_PIRArray; // Ordered Pointers to PixRects[i] 
begin
  // to avoid warnings:
  CurPos    := 0;
  Step      := 0;
  BegCenter := 0;

  if not FillUndoAndPixRects() then Exit; // some Error

  //***** Prepare for collecting PixRects Statistics

  SumSize := Point(0,0);
  Middle  := Point(0,0);
  Str := edSpaceCoef.Text;
  if Str = '' then SpaceCoef := 0
              else SpaceCoef := N_ScanDouble( Str ) / 100;

  MaxWidth  := -1;
  MinWidth  := MaxInt;
  MaxHeight := -1;
  MinHeight := MaxInt;

  if cbIndex.Checked then // arrange by Index in MarkedList
  begin
    SetLength( OrderedPtrs, Length(PixRects) );
    for i := 0 to High(OrderedPtrs) do
      OrderedPtrs[i] := @PixRects[i];
  end else //*************** arrange by Centers
  begin
    if (AFunctionTag = 11) or (AFunctionTag = 13) then X0Y1 := 0  // by X-Centers
                                                  else X0Y1 := 1; // by Y-Centers
    OrderedPtrs := TN_PIRArray(N_GetSortedPointers( @PixRects[0], Length(PixRects),
                            SizeOf(PixRects[0]), X0Y1, N_CompareIRectCenters ));
  end; // else - arrange by Centers

  for i := 0 to High(PixRects) do // collect PixRects Statistics
  begin
    Size := N_RectWidth( PixRects[i] );
    Inc( SumSize.X, Size );
    if Size > MaxWidth then MaxWidth := Size;
    if Size < MinWidth then MinWidth := Size;

    Size := N_RectHeight( PixRects[i] );
    Inc( SumSize.Y, Size );
    if Size > MaxHeight then MaxHeight := Size;
    if Size < MinHeight then MinHeight := Size;

    Inc( Middle.X, PixRects[i].Left+PixRects[i].Right );
    Inc( Middle.Y, PixRects[i].Top+PixRects[i].Bottom );

  end; // for i := 0 to NumComps-1 do

  SameParentRect := True;
  ParentRect := UndoInfo[UndoFreeInd,0].ParentPixRect;

  for i := 1 to High(UndoInfo[UndoFreeInd]) do
  with UndoInfo[UndoFreeInd,i] do
  begin
    if not N_Same( ParentRect, ParentPixRect ) then
      SameParentRect := False;
  end;

  Middle.X := Round( 0.5 * Middle.X / Length(PixRects) ); // PixRects Everage Center
  Middle.Y := Round( 0.5 * Middle.Y / Length(PixRects) );

  ParentWidthM1  := N_RectWidth( ParentRect ) - 1;
  ParentHeightM1 := N_RectHeight( ParentRect ) - 1;

  TmpRect := FixedRect;
  if (FixedRect.Left = N_NotAnInteger) or           // not given
     (2 <> N_IRectAnd( TmpRect, ParentRect )) then // not inside Parent
    FixedRect := PixRects[0]; // use PixRects[0] as FixedRect

  //***** modes for AFunctionTag = 11, 12 (Equal Spaces along X,Y)
  ShowStep  := N_KeyIsDown( N_VKShift ) and N_KeyIsDown( N_VKControl );
  CalcStep  := ( not N_KeyIsDown( N_VKControl ) ) or
               ( N_KeyIsDown( N_VKShift ) and N_KeyIsDown( N_VKControl ) );
  FixedLast := (not N_KeyIsDown( N_VKShift )) and (not N_KeyIsDown( N_VKControl ));

  //***** Calc New PixRects by current Form Field values (Align Components)

  for i := 0 to High(PixRects) do // change Components Pixel Coords in PixRects
  begin
  case AFunctionTag of

  //******************** Position, Tags 1-6 and 11-14 ************************

    // Left
    1: begin // set Left side of all Comps equal to Left Side of
             //        Fixed or Leftmoust Component
      if cbFixed.Checked then
        BaseCoord := FixedRect.Left
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := ParentRect.Left + Round(ParentWidthM1*SpaceCoef)
        else
          BaseCoord := EnvPixRects.Left; // Aign by Leftmoust comp
      end;

      BaseCoord := Max( BaseCoord, ParentRect.Left ); // force to be inside

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
      begin                   // (move All Comps by same Delta)
        Delta := BaseCoord - EnvPixRects.Left;
        Inc( PixRects[i].Left, Delta );
        Inc( PixRects[i].Right, Delta );
      end else // cbSolid.Checked = False, align all Comps by BaseCoord
      begin
        Inc( PixRects[i].Right, BaseCoord - PixRects[i].Left );
        PixRects[i].Left  := BaseCoord;
      end;

    end; // 1: begin // Left

    // Top
    2: begin // set Top side of all Comps equal to Top Side of
             //        Fixed or Topmoust Component
      if cbFixed.Checked then
        BaseCoord := FixedRect.Top
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := ParentRect.Top + Round(ParentHeightM1*SpaceCoef)
        else
          BaseCoord := EnvPixRects.Top; // Aign by Topmoust comp
      end;

      BaseCoord := Max( BaseCoord, ParentRect.Top ); // force to be inside

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
      begin                   // (move All Comps by same Delta)
        Delta := BaseCoord - EnvPixRects.Top;
        Inc( PixRects[i].Top, Delta );
        Inc( PixRects[i].Bottom, Delta );
      end else // cbSolid.Checked = False, align all Comps by BaseCoord
      begin
        Inc( PixRects[i].Bottom, BaseCoord - PixRects[i].Top );
        PixRects[i].Top  := BaseCoord;
      end;

    end; // 2: begin // Top

    // X-Center
    3: begin // set X-Center of all Comps equal to X-Center of Fixed Component
             //        or to the everage X-center of all components
      if cbFixed.Checked then
        BaseCoord := (FixedRect.Left + FixedRect.Right) div 2
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := (ParentRect.Left + ParentRect.Right) div 2
        else
          BaseCoord := Middle.X; // Aign by everage Center of Marked Comps
      end;

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
        Delta := BaseCoord - (EnvPixRects.Left + EnvPixRects.Right) div 2
      else // cbSolid.Checked = False, align all Comps by BaseCoord
        Delta := BaseCoord - (PixRects[i].Left + PixRects[i].Right) div 2;

      Inc( PixRects[i].Left, Delta );
      Inc( PixRects[i].Right, Delta );
    end; // 3: begin // X-Center

    // Y-Center
    4: begin // set Y-Center of all Comps equal to Y-Center of Fixed Component
             //        or to the everage Y-center of all components
      if cbFixed.Checked then
        BaseCoord := (FixedRect.Top + FixedRect.Bottom) div 2
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := (ParentRect.Top + ParentRect.Bottom) div 2
        else
          BaseCoord := Middle.Y; // Aign by everage Center of Marked Comps
      end;

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
        Delta := BaseCoord - (EnvPixRects.Top + EnvPixRects.Bottom) div 2
      else // cbSolid.Checked = False, align all Comps by BaseCoord
        Delta := BaseCoord - (PixRects[i].Top + PixRects[i].Bottom) div 2;

      Inc( PixRects[i].Top, Delta );
      Inc( PixRects[i].Bottom, Delta );
    end; // 4: begin // Y-Center

    // Right
    5: begin // set Right side of all Comps equal to Right Side of
             //        Fixed or Rightmoust Component
      if cbFixed.Checked then
        BaseCoord := FixedRect.Right
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := ParentRect.Right - Round(ParentWidthM1*SpaceCoef)
        else
          BaseCoord := EnvPixRects.Right; // Aign by Leftmoust comp
      end;

      BaseCoord := Min( BaseCoord, ParentRect.Right ); // force to be inside

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
      begin                   // (move All Comps by same Delta)
        Delta := BaseCoord - EnvPixRects.Right;
        Inc( PixRects[i].Left, Delta );
        Inc( PixRects[i].Right, Delta );
      end else // cbSolid.Checked = False, align all Comps by BaseCoord
      begin
        Inc( PixRects[i].Left, BaseCoord - PixRects[i].Right );
        PixRects[i].Right  := BaseCoord;
      end;

    end; // 5: begin // Right

    // Bottom
    6: begin // set Bottom side of all Comps equal to Bottom Side of
             //        Fixed or Bottommoust Component
      if cbFixed.Checked then
        BaseCoord := FixedRect.Bottom
      else
      begin
        if (Length(PixRects) = 1) or  // only one component Marked
            cbSolid.Checked then      // move All Comps by same Delta
          BaseCoord := ParentRect.Bottom - Round(ParentHeightM1*SpaceCoef)
        else
          BaseCoord := EnvPixRects.Bottom; // Aign by Topmoust comp
      end;

      BaseCoord := Min( BaseCoord, ParentRect.Bottom ); // force to be inside

      if cbSolid.Checked then // Position all Marked Comps as a Solid object
      begin                   // (move All Comps by same Delta)
        Delta := BaseCoord - EnvPixRects.Bottom;
        Inc( PixRects[i].Top, Delta );
        Inc( PixRects[i].Bottom, Delta );
      end else // cbSolid.Checked = False, align all Comps by BaseCoord
      begin
        Inc( PixRects[i].Top, BaseCoord - PixRects[i].Bottom );
        PixRects[i].Bottom  := BaseCoord;
      end;

    end; // 6: begin // Bottom


    // Equal Spaces along X
    11: begin // Position all Comps along X with same X-Spaces between them,
             //  first and last Components remains in same Position,
             //
             // now works only if FreeSize>0
      if Length(PixRects) <= 2 then Break; // Two or less comps, nothing to do
      if not SameParentRect then Break; // Comps have different Parents

      if i = 0 then // define Step and CurPos (execute only once)
      begin
        if CalcStep then // calc Step by FreeSize
        begin
          Sum := 0;
          for j := 1 to High(OrderedPtrs)-1 do
            Inc( Sum, N_RectWidth( OrderedPtrs[j]^ ) );

          FreeSize := OrderedPtrs[High(OrderedPtrs)]^.Left -
                                      OrderedPtrs[0]^.Right + 1 - Sum;
          Step := FreeSize / (Length(PixRects) - 1.0);

          if not FixedLast then // Round Step in Pixels
            Step := Floor( Step );
        end
        else //************ get Step from edSpaceCoef.Text
          Step := SpaceCoef*N_RectWidth( ParentRect );

        if ShowStep then // update edSpaceCoef.Text by calculated Step
          edSpaceCoef.Text := Format( '%.2f', [100*Step/N_RectWidth(ParentRect)] );

        CurPos := OrderedPtrs[0]^.Right + 1;
        Continue;
      end; // if i = 1 then // define Step and CurPos (execute only once)

      if (i = (High(OrderedPtrs)+1)) and           // is last Comp,
                             FixedLast then Break; // do not shift it

      //***** Position all Comps except first and last

      Delta := Round( CurPos + Step - OrderedPtrs[i-1]^.Left );
      Inc( OrderedPtrs[i-1]^.Left,  Delta );
      Inc( OrderedPtrs[i-1]^.Right, Delta );
      CurPos := OrderedPtrs[i-1]^.Right + 1;
    end; // 11: begin // Equal Spaces along X

    // Equal Spaces along Y
    12: begin // Position all Comps along Y with same Y-Spaces between them,
             //  first and last Components remains in same Position,
             //
             // now works only if FreeSize>0
      if Length(PixRects) <= 2 then Break; // Two or less comps, nothing to do
      if not SameParentRect then Break; // Comps have different Parents

      if i = 1 then // define Step and CurPos (execute only once)
      begin
        if CalcStep then // calc Step by FreeSize
        begin
          Sum := 0;
          for j := 1 to High(OrderedPtrs)-1 do
            Inc( Sum, N_RectHeight( OrderedPtrs[j]^ ) );

          FreeSize := OrderedPtrs[High(OrderedPtrs)]^.Top -
                                      OrderedPtrs[0]^.Bottom + 1 - Sum;
          Step := FreeSize / (Length(PixRects) - 1.0);

          if not FixedLast then // Round Step in Pixels
            Step := Floor( Step );
        end
        else //************ get Step from edSpaceCoef.Text
          Step := SpaceCoef*N_RectHeight( ParentRect );

        if ShowStep then // update edSpaceCoef.Text by calculated Step
          edSpaceCoef.Text := Format( '%.2f', [100*Step/N_RectHeight(ParentRect)] );

        CurPos := OrderedPtrs[0]^.Bottom + 1;
        Continue;
      end; // if i = 1 then // define Step and CurPos (execute only once)

      if (i = (High(OrderedPtrs)+1)) and           // is last Comp,
                             FixedLast then Break; // do not shift it

      //***** Position all Comps except first and last

      Delta := Round( CurPos + Step - OrderedPtrs[i-1]^.Top );
      Inc( OrderedPtrs[i-1]^.Top,    Delta );
      Inc( OrderedPtrs[i-1]^.Bottom, Delta );
      CurPos := OrderedPtrs[i-1]^.Bottom +1 ;
    end; // 12: begin // Equal Spaces along Y

    // Uniform along X
    13: begin // Position X-centers of all Comps uniformly along X
      if not SameParentRect then Break; // Comps have different Parents
      if i = 0 then // define first and last Rects position (execute only once)
      begin
        Space := Round( N_RectWidth( ParentRect ) * SpaceCoef ); // Padding

        // position first Rect - OrderedPtrs[0]^
        Delta := ParentRect.Left + Space - OrderedPtrs[0]^.Left;
        Inc( OrderedPtrs[0]^.Left,  Delta );
        Inc( OrderedPtrs[0]^.Right, Delta );
        BegCenter := (OrderedPtrs[0]^.Left + OrderedPtrs[0]^.Right) div 2;

        // position Last Rect - OrderedPtrs[Ind]^
        Ind := High(OrderedPtrs); // Last Rect's Index
        Delta := ParentRect.Right - Space - OrderedPtrs[Ind]^.Right;
        Inc( OrderedPtrs[Ind]^.Left,  Delta );
        Inc( OrderedPtrs[Ind]^.Right, Delta );
        EndCenter := (OrderedPtrs[Ind]^.Left + OrderedPtrs[Ind]^.Right) div 2;

        if Length(PixRects) >= 3 then // at least Three Comps to position
          Step := 1.0*(EndCenter - BegCenter) / (Length(PixRects) - 1);

        Continue;
      end; // if i = 0 then // define first and last Rects position (execute only once)

      if i = (High(OrderedPtrs)+1) then Break; // last Comp is already positioned

      //***** Position all Comps except first and last

      Delta := BegCenter + Round( (i-1)*Step ) -
                           ( (OrderedPtrs[i-1]^.Left + OrderedPtrs[i-1]^.Right) div 2 );
      Inc( OrderedPtrs[i-1]^.Left,  Delta );
      Inc( OrderedPtrs[i-1]^.Right, Delta );
    end; // 13: begin // Uniform along X

    // Uniform along Y
    14: begin // Position Y-centers of all Comps uniformly along Y
      if not SameParentRect then Break; // Comps have different Parents
      if i = 0 then // define first and last Rects position (execute only once)
      begin
        Space := Round( N_RectHeight( ParentRect ) * SpaceCoef ); // Padding

        // position first Rect - OrderedPtrs[0]^
        Delta := ParentRect.Top + Space - OrderedPtrs[0]^.Top;
        Inc( OrderedPtrs[0]^.Top,    Delta );
        Inc( OrderedPtrs[0]^.Bottom, Delta );
        BegCenter := (OrderedPtrs[0]^.Top + OrderedPtrs[0]^.Bottom) div 2;

        // position Last Rect - OrderedPtrs[Ind]^
        Ind := High(OrderedPtrs); // Last Rect's Index
        Delta := ParentRect.Bottom - Space - OrderedPtrs[Ind]^.Bottom;
        Inc( OrderedPtrs[Ind]^.Top,    Delta );
        Inc( OrderedPtrs[Ind]^.Bottom, Delta );
        EndCenter := (OrderedPtrs[Ind]^.Top + OrderedPtrs[Ind]^.Bottom) div 2;

        if Length(PixRects) >= 3 then // at least Three Comps to position
          Step := 1.0*(EndCenter - BegCenter) / (Length(PixRects) - 1);

        Continue;
      end; // if i = 0 then // define first and last Rects position (execute only once)

      if i = (High(OrderedPtrs)+1) then Break; // last Comp is already positioned

      //***** Position all Comps except first and last

      Delta := BegCenter + Round( (i-1)*Step ) -
                           ( (OrderedPtrs[i-1]^.Top + OrderedPtrs[i-1]^.Bottom) div 2 );
      Inc( OrderedPtrs[i-1]^.Top,    Delta );
      Inc( OrderedPtrs[i-1]^.Bottom, Delta );
    end; // 14: begin // Uniform along Y


  //******************** Size, Tags 21-26  *************************

    // by Smallest along X
    21: begin // set X-size of all Comps by X-size of Smallest Component
      PixRects[i].Right := PixRects[i].Left + MinWidth - 1;
    end; // 21: begin // by Smallest along X

    // by Smallest along Y
    22: begin // set Y-size of all Comps by Y-size of Smallest Component
      PixRects[i].Bottom := PixRects[i].Top + MinHeight - 1;
    end; // 22: begin // by Smallest along Y

    // by Largest along X
    23: begin // set X-size of all Comps by X-size of Largest Component
      PixRects[i].Right := PixRects[i].Left + MaxWidth - 1;
    end; // 23: begin // by Largest along X

    // by Largest along Y
    24: begin // set Y-size of all Comps by Y-size of Largest Component
      PixRects[i].Bottom := PixRects[i].Top + MaxHeight - 1;
    end; // 24: begin // by Largest along Y

    // by Fixed.Width
    25: begin // set X-size of all Comps by X-size of Fixed Component
      PixRects[i].Right := PixRects[i].Left + FixedRect.Right - FixedRect.Left;
    end; // 25: begin // by Fixed along X

    // by Fixed.Height
    26: begin // set Y-size of all Comps by Y-size of Fixed Component
      PixRects[i].Bottom := PixRects[i].Top + FixedRect.Bottom - FixedRect.Top;
    end; // 26: begin // by Fixed along Y

  end; // case AFunctionTag of

  end; // for i := 0 to High(PixRects) do // change Components Pixel Coords in PixRects

  //***** Here: PixRects are OK, update CompCoords by updated PixRects

  UpdateCompCoords();
  DataChanged := True; // next time use next Undo Level
  ShowStr( 'Alignment Done, UndoLevel=' + IntToStr(UndoFreeInd) );
end; // procedure TN_AlignForm.ExecAilgn

//***********************************  TN_AlignForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_AlignForm.CurStateToMemIni();
begin
  Inherited;
  N_StringToMemIni( 'N_AlignF', 'edSC', edSpaceCoef.Text );
  N_StringToMemIni( 'N_AlignF', 'edUL', edUndoLevel.Text );
  N_BoolToMemIni  ( 'N_AlignF', 'cbST', cbStayOnTop.Checked );
end; // end of procedure TN_AlignForm.CurStateToMemIni

//***********************************  TN_AlignForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_AlignForm.MemIniToCurState();
begin
  Inherited;
  edSpaceCoef.Text := N_MemIniToString( 'N_AlignF',  'edSC', ' 0' );
  edUndoLevel.Text  := N_MemIniToString( 'N_AlignF', 'edUL',' 10' );
  cbStayOnTop.Checked := N_MemIniToBool( 'N_AlignF', 'cbST' );
end; // end of procedure TN_AlignForm.MemIniToCurState


//****************  TN_RFAMoveComps class methods  *****************
//   TN_RFAMoveComps RFAction is created in N_CreateAlignForm proc

//******************************************** TN_RFAMoveComps.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMoveComps.SetActParams();
begin
  ActName := 'MoveComps';
  inherited;
end; // procedure TN_RFAMoveComps.SetActParams();

//************************************************* TN_RFAMoveComps.Execute ***
// Move or resize given list of components
//
// TN_RFAMoveComps RFAction is created in N_CreateAlignForm proc
//
procedure TN_RFAMoveComps.Execute();
var
  i, ibeg, iend, dx, dy: integer;
  ScaleCoef: double;
  MoveCorner: boolean;
  FP: TPoint;
  BaseRect, NewRect, ParentRect: TRect;
begin
  inherited;
  with ActGroup, ActGroup.RFrame, RFAAlignForm do
  begin

  if N_ActiveVTreeFrame.MarkedChanged then
    if not FillUndoAndPixRects() then Exit; // something wrong

  //*** Here PixRects are OK and correspond to UndoInfo[UndoFreeInd] array

  if CHType = htMouseDown then // LeftClick, set RFABase and RFABaseRects
  begin
    RFABase := CCBuf;
    RFABaseRects := Copy( PixRects );
    Exit;
  end;

  if (CHType = htMouseMove) and not (ssLeft in CMKShift) then // move with
  begin        // buttons Up, set RFAFlags, RFARectInd and Windows Cursor type
    RFARectInd := N_IPointNearIRects( 0, PixRects, CCBuf, 3, RFAFlags );
    N_SetCursorType( RFAFlags );

    if RFARectInd >= 0 then // Show Comp.ObjName
    begin
      with UndoInfo[UndoFreeInd,RFARectInd].Comp do
        ShowString( $3, ObjName + ', ' )
    end; // if RFARectInd >= 0 then // Show Comp.ObjName

    Exit;
  end; // move with buttons Up

  if (CHType = htMouseMove) and (ssLeft in CMKShift) then // change coords
  begin                           // using RFARectInd, RFAFlags (set at last MoseMove) and
                                  // and RFABase, RFABaseRects (set at last MoseDown)
    if RFARectInd = -1 then Exit; // no Comp was choosen, nothing to change

    dx := CCBuf.X - RFABase.X; // X,Y shift values relative to RFABase
    dy := CCBuf.Y - RFABase.Y;

    if (dx = 0) and (dy = 0) then Exit; // to avoid extra redrawing

    if N_KeyIsDown( VK_Shift ) and    // shift allowed only along one Axis AND
          (RFAFlags = $10)       then // Move, not resize mode
    begin
      if Abs(dx) > Abs(dy) then dy := 0
                           else dx := 0;
    end; // if N_KeyIsDown( VK_Shift ) ...

    if rgEdit.ItemIndex = 0 then // Move/Resize one Component (with RFARectInd)
    begin
      ibeg := RFARectInd;
      iend := RFARectInd;
    end else //*******************  Move/Resize all Components
    begin    //                    ( rgEdit.ItemIndex = 1 or 2 )
      ibeg := 0;
      iend := High(UndoInfo[UndoFreeInd]);
    end; // if rgEdit.ItemIndex = 0 then

    for i := ibeg to iend do // along Components to Move/Resize (one or all)
    begin
      // local BaseRect and NewRect are used just to reduce code size
      BaseRect := RFABaseRects[i];
      NewRect := BaseRect;
      ParentRect := UndoInfo[UndoFreeInd,i].ParentPixRect;

      if rgEdit.ItemIndex = 2 then // Scale Position of All Components
      begin          // (Upper Left EnvPixRects corner is considered as Fixed point)
        FP := EnvPixRects.TopLeft; // FP - Fixed Point

        //***** Comments:
        // 1) (RFABase.X + dx) is used instead of CCBuf.X to enable Shift key,
        // 2) Rects Size remains the same, later new modes can be easily
        //    implemented - Scale both Position and Size

        ScaleCoef := ( RFABase.X + dx - FP.X ) / ( RFABase.X - FP.X );
        NewRect.Left := FP.X + Round( (BaseRect.Left-FP.X)*ScaleCoef );
        NewRect.Right := NewRect.Left + BaseRect.Right - BaseRect.Left;

        ScaleCoef := ( RFABase.Y + dy - FP.Y ) / ( RFABase.Y - FP.Y );
        NewRect.Top := FP.Y + Round( (BaseRect.Top-FP.Y)*ScaleCoef );
        NewRect.Bottom := NewRect.Top + BaseRect.Bottom - BaseRect.Top;

      end else //*******************  Move/Resize one or all Components
      begin    //                       ( rgEdit.ItemIndex = 0 or 1 )

        if RFAFlags = $10 then // move Whole Rect
          NewRect := N_RectShift( BaseRect, dx, dy )
        else // move one or two sides (corner)
        begin
          if (RFAFlags and $01) <> 0 then // move Top side
            NewRect.Top := BaseRect.Top + dy;

          if (RFAFlags and $02) <> 0 then // move Right side
            NewRect.Right := BaseRect.Right + dx;

          if (RFAFlags and $04) <> 0 then // move Bottom side
            NewRect.Bottom := BaseRect.Bottom + dy;

          if (RFAFlags and $08) <> 0 then // move Left side
            NewRect.Left := BaseRect.Left + dx;


          MoveCorner := (RFAFlags = $13) or (RFAFlags = $16) or
                        (RFAFlags = $19) or (RFAFlags = $1C);

          if MoveCorner and N_KeyIsDown( VK_Control ) then // preserve NewRect Aspect
          begin
            N_AdjustIRect( NewRect, ParentRect, 1, N_RectAspect( BaseRect ) );

            //***** preserve coords of opposite corner

            if (RFAFlags and $01) <> 0 then // preserve Bottom side
              NewRect := N_RectShift( NewRect, 0, BaseRect.Bottom - NewRect.Bottom );

            if (RFAFlags and $02) <> 0 then // preserve Left side
              NewRect := N_RectShift( NewRect, BaseRect.Left - NewRect.Left, 0 );

            if (RFAFlags and $04) <> 0 then // preserve Top side
              NewRect := N_RectShift( NewRect, 0, BaseRect.Top - NewRect.Top );

            if (RFAFlags and $08) <> 0 then // preserve Right side
              NewRect := N_RectShift( NewRect, BaseRect.Right - NewRect.Right, 0 );

          end; // if MoveCorner and N_KeyIsDown( VK_Control ) then // preserve NewRect Aspect

        end; // else // move one or two sides (corner)



      end; // if rgEdit.ItemIndex = 3 then

      NewRect := N_RectAdjustByMaxRect( NewRect, ParentRect ); // move inside Parent
      PixRects[i] := NewRect; // update PixRects by NewRect

    end; // for i := ibeg to iend do // along Components to Move/Resize

    UpdateCompCoords(); // Update all Components coords
  end; // change coords ( move or resize Component(s) )

  end; // with ActGroup, ActGroup.RFrame, RFAAlignForm do
end; // procedure TN_RFAMoveComps.Execute


//****************  TN_RFAMarkComps class methods  *****************

//********************************* TN_RFAMarkComps.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMarkComps.SetActParams();
begin
  ActName := 'MarkComps';
  inherited;
end; // procedure TN_RFAMarkComps.SetActParams();

//************************************************* TN_RFAMarkComps.Execute ***
// Mark Components in NVTreeFrame by cursor in Rast1Frame, show Comp.ObjName under cursor
// LeftClick        - Select current (under cursor)
// LeftClick+Shift+Ctrl - Enable Marking Children
// LeftClick+Shift  - Enable Marking Parent's Siblings
// LeftClick+Ctrl   - Toggle Marking Comp under cursor
// RightClick       - GetUOjFrame5 menu
// RightClick+Shift - Some Action, assigned to RightClick+Shift
// RightClick+Ctrl  - Some Action, assigned to RightClick+Ctrl
//
// TN_RFAMarkComps RFAction is created in N_ViewUObjAsMap (in N_ME1) proc
//
procedure TN_RFAMarkComps.Execute();
var
  i, NumComps, MaxNumComps, NumFound: integer;
  Names, Path: string;
  FirstTime: boolean;
  CompsRoot, CurChild: TN_UDBase;
  MarkedComp: TN_UDCompVis;
  CurVNode, RootVNode, MarkedVNode: TN_VNode;
  VNodes: TList;
  CompsUnderCursor: TN_UDCompBaseArray;
  Label ProcessCompsRoot;
begin
  inherited;
//  if not N_MEGlobObj.IsProj_VRE then Exit; // a precaution
  if RFANVTreeFrame = nil then Exit; // a precaution

  with ActGroup, ActGroup.RFrame, RFANVTreeFrame do
  begin

//  if (CHType = htMouseDown) and N_KeyIsDown( VK_SHIFT ) then // Skip Mark changing
//    Exit;

  if (CHType = htMouseDown) and ((Char(CKey.CharCode) = 'Q')) then // Mark
  begin
    CompsUnderCursor := nil;
    RVCTreeRoot.AddCompsUnderPoint( CCBuf, CompsUnderCursor );

//    VTree.GetVNodeByPath( RootVNode, VTree.RootUObj.GetPathToObj( RVCTreeRoot ) );
    VTree.GetVNodeByPath( RootVNode, K_GetPathToUObj( RVCTreeRoot, VTree.RootUObj ) );

    VTree.UnMarkAllVNodes();

    Names := '';
    for i := 0 to High(CompsUnderCursor) do
    begin
      Names := Names + CompsUnderCursor[i].ObjName + ',';
//      VTree.GetVNodeByPath( CurVNode,
//        RVCTreeRoot.GetPathToObj(CompsUnderCursor[i]), K_ontObjName, RootVNode );
      VTree.GetVNodeByPath( CurVNode,
                            K_GetPathToUObj( CompsUnderCursor[i], RVCTreeRoot ),
                            K_ontObjName, RootVNode );

//      CurVNode := CompsUnderCursor[i].LastVNode;
      if CurVNode <> nil then
        CurVNode.Mark();
    end; // for i := 0 to High(CompsUnderCursor) do

    VTree.TreeView.Invalidate();
    RedrawAllAndShow();

    if RFShowMarkedNames then
    begin
      if Names <> '' then
        ShowString( $3, 'Marked:' + Names ) // Name(s) of Comp(s) under Cursor
      else
        ShowString( $3, 'No Comps Under Cursor' );
    end;

    Exit;
  end; // if (CHType = htMouseDown) and ((Char(CKey.CharCode) = 'Q')) then // Mark

  end; // with ActGroup, ActGroup.RFrame, RFANVTreeFrame do


  FirstTime := True; // first Pas, check Shift and Ctrl keys while processing LeftClick

  with ActGroup, ActGroup.RFrame, RFANVTreeFrame do
  begin

  if (CHType <> htMouseMove) and (CHType <> htMouseDown) then Exit;

  VNodes := VTree.MarkedVNodesList;

  if MarkedChanged then //***** ReInitialize Comps and PixRects Arrays
  begin
    MarkedChanged := False; // clear flag

    if VNodes.Count = 0 then
    begin
      Comps := nil;
      PixRects := nil;
      Exit;
    end;

    MarkedVNode := TN_VNode(VNodes.Items[0]);
    if not (MarkedVNode.VNUDObj is TN_UDCompVis) then Exit;
    MarkedComp  := TN_UDCompVis(MarkedVNode.VNUDObj);

    if MarkedComp = RFrame.RVCTreeRoot then // init by Children
      CompsRoot := MarkedComp
    else//**************************************************** init by Siblings
      CompsRoot := MarkedVNode.VNParent.VNUDObj;


    ProcessCompsRoot: //***** Process CompsRoot children

    if CurVNode = nil then // a precaution
    begin
//      MarkedChanged := True; // // "MarkedList changed" (for Mark and Move Comps Actions)
//      Exit;
    end; // if CurVNode = nil then

    //***** Fill Comps and PixRects by all CompsRoot Children

    NumComps := 0;
    MaxNumComps := CompsRoot.DirLength(); // some children may be not components
    SetLength( Comps, MaxNumComps );
    SetLength( PixRects, MaxNumComps );

    for i := 0 to MaxNumComps-1 do // along all CompsRoot children
    begin
      CurChild := CompsRoot.DirChild( i );
      if not (CurChild is TN_UDCompVis) then Continue; // skip not Visual Components

      Comps[NumComps] := TN_UDCompVis(CurChild);
      PixRects[NumComps] := TN_UDCompVis(CurChild).CompIntPixRect;
      Inc(NumComps);
    end; // for i := 0 to MaxNumComps-1 do // along all CompsRoot children

    SetLength( Comps, NumComps );   // set real length
    SetLength( PixRects, NumComps );

  end; // if MarkedChanged then //***** ReInitialize Comps and PixRects Arrays

  if Length(PixRects) = 0 then Exit; // nothing todo
  Names := '';
  NumFound := 0; // number of found (under cursor) components

  for i := 0 to High(PixRects) do // check if Cursor is inside some PixRect
  with RFANVTreeFrame.VTree do
  begin
    if 0 <> N_PointInRect( CCBuf, PixRects[i] ) then Continue; // check next rect

    if Names = '' then
      Names := Comps[i].ObjName
    else
      Names := Names + ', ' + Comps[i].ObjName;

    Inc(NumFound);
    if CHType = htMouseMove then Continue; // check next Rect

    if ssLeft in CMKShift then // Left Mouse Button Pressed
    begin
      if ssDouble in CMKShift then // Double Click
      begin
        if Assigned(OnDoubleClickAction) then OnDoubleClickAction( nil );
        Exit;
      end;

      if FirstTime and (ssShift in CMKShift) and (ssCtrl in CMKShift) then // LeftClick+Shift+Ctrl -
//      if FirstTime and N_KeyIsDown( N_VKCapsLock ) then  // temporary CapsLock
      begin // Enable Marking Children (and Select Comp under Cursor or first Child)
        CurChild := Comps[i].DirChild( 0 );
        if CurChild <> nil then
        begin
          AllExpandingMode := True;
//          Path := RootUObj.GetRefPathToObj( CurChild );
          Path := K_GetPathToUObj( CurChild, RootUObj );
          SetPath( Path );
        end;
        CompsRoot := Comps[i];
                                // do not consider Shift and Ctrl Keys
        FirstTime := False;     // while processing LeftClick for new CompsRoot
        goto ProcessCompsRoot;
      end else if FirstTime and (ssShift in CMKShift) then // LeftClick+Shift - Enable
      begin //                   Marking Parent's Siblings (and Select Parent)
//        Path := RootUObj.GetRefPathToObj( Comps[i] );
        Path := K_GetPathToUObj( Comps[i], RootUObj );
        GetVNodeByPath( CurVNode, Path );
        CompsRoot := CurVNode.VNParent.VNParent.VNUDObj; // Childs Dir
        if CompsRoot <> nil then
        begin
//          Path := RootUObj.GetRefPathToObj( CurVNode.VNParent.VNParent.VNUDObj );
          Path := K_GetPathToUObj( CurVNode.VNParent.VNParent.VNUDObj, RootUObj );
          SetPath( Path );
        end;
                                // do not consider Shift and Ctrl Keys
        FirstTime := False;     // while processing LeftClick for new CompsRoot
        goto ProcessCompsRoot;
      end else if FirstTime and (ssCtrl in CMKShift) then // LeftClick+Ctrl - Toggle Marking
      begin
//        Path := RootUObj.GetRefPathToObj( Comps[i] );
        Path := K_GetPathToUObj( Comps[i], RootUObj );
        GetVNodeByPath( CurVNode, Path );
        TreeView.Invalidate; // Invalidate should be called BEFORE Toggle !!!
        CurVNode.Toggle( 0 );
      end else //******** LeftClick - Select first and mark other under Cursor
      begin
        N_ud := RootUObj; // debug
//        Path := RootUObj.GetRefPathToObj( Comps[i] );
        Path := K_GetPathToUObj( Comps[i], RootUObj );
        if NumFound = 1 then
        begin
          SetPath( Path );
        end else // NumFound >= 2 - mark all components under cursor
        begin
          GetVNodeByPath( CurVNode, Path );
          if CurVNode = nil then
            Inc( N_i ) // Error (Path was = '')
          else
            CurVNode.Toggle( 1 );
        end;
      end;

    end; // if ssLeft in CMKShift then // Left Mouse Button Pressed

    AllExpandingMode := False;

    if ssRight in CMKShift then // Right Mouse Button Pressed
    with N_MenuForm.frUObjCommon do
    begin
      UObj := Comps[i];
//      Path := RootUObj.GetRefPathToObj( UObj );
      Path := K_GetPathToUObj( UObj, RootUObj );
      GetVNodeByPath( CurVNode, Path );
      ParentUObj := CurVNode.VNParent.VNUDObj;
      SomeStatusBar.SimpleText := '';

      if N_KeyIsDown( N_VKShift ) then // Shift key is Pressed
      begin
        if Assigned(OnClickShiftAction) then OnClickShiftAction( nil );
      end else if N_KeyIsDown( N_VKControl ) then // Control key is Pressed
      begin
        if Assigned(OnClickCtrlAction) then OnClickCtrlAction( nil );
      end else // both Shift and Control keys are Up, Show PopUp Menu
      begin
       if (GetAsyncKeyState(integer('Z')) and $8000) = 0 then // Z is not pressed
       begin
        SetPopupMenuCaptionsByUObj();
        SomeStatusBar.SimpleText := 'Choose Action for ' + UObj.ObjName;

        with Mouse.CursorPos do
          PopupMenu.Popup( X, Y );
        end;
      end;

    end; // if ssRight in CMKShift then // Right Mouse Button Pressed

  end; // for i := 0 to High(PixRects) do // check if Cursor is inside some PixRect

  if NumFound >= 1 then
  begin
    MarkedChanged := True; // "MarkedList changed" flag

    if RFShowMarkedNames then
    begin
      if NumFound >= 2 then
        Names := '(' + IntToStr(NumFound) + '):' + Names;

      ShowString( $3, Names + '. ' ); // Name(s) of Comp(s) under Cursor
    end;

  end; // if NumFound >= 1 then

  end; // with ActGroup, ActGroup.RFrame do
end; // procedure TN_RFAMarkComps.Execute


    //*********** Global Procedures  *****************************

//********************************************  N_CreateAlignForm  ******
// Create and return new instance of TN_AlignForm
// return nil if Form cannot be created
// AOwner - Owner of created Form
//
function N_CreateAlignForm( AOwner: TN_BaseForm ): TN_AlignForm;
var
  Ind: integer;
  CompGroup: TN_SGBase;
begin
  Result := nil;

  // Component.CompIntPixRect field is correct only after drawing in N_ActiveRFrame!

  if N_ActiveRFrame = nil then
  begin
    N_WarnByMessage( 'No Active RFrame!' );
    Exit;
  end;

  if N_ActiveVTreeFrame = nil then // a precaution, not really needed
  begin
    N_WarnByMessage( 'No Active VTreeFrame!' );
    Exit;
  end;

  with TN_NVTreeForm(N_ActiveVTreeFrame.OwnerForm) do
  begin
    tbToggleEditMark.Visible := True;  // Set "Mark", not Edit mode
    tbToggleEditMark.ImageIndex := 86; // "Mark" Icon

//    if N_KeyIsDown(VK_SHIFT) then  // does not work, why?
//      tbToggleEditMarkClick( nil );
  end; // with TN_NVTreeForm(N_ActiveVTreeFrame.OwnerForm) do

  N_ActiveVTreeFrame.MarkedChanged := True; // force updating PixRects

  Result := TN_AlignForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    PageControl.ActivePageIndex := 0;
    OwnerForm := AOwner;
    UndoFilledInd := -1;
    UndoMaxInd := -1;
    InitUndo();

//    N_ActiveRFrame.ParentForm.AddProcOfObjAction( CloseSelf, Result, 'Close AlignForm' );
    K_GetOwnerBaseForm( N_ActiveRFrame.Owner ).AddProcOfObjAction( CloseSelf, Result, 'Close AlignForm' );

    N_ActiveVTreeFrame.OwnerForm.AddProcOfObjAction( CloseSelf, Result, 'Close AlignForm' );
  end; // with Result do

  N_AlignForm := Result;

  //***** Create Group for moving or resizing Marked components

  with N_ActiveRFrame do
  begin
    Ind := GetGroupInd( N_SMoveCompGName );
    if Ind >= 0 then // Group was already created, set Result.MCAction field
    begin
      CompGroup := TN_SGBase(RFSGroups.Items[Ind]);
      Result.MCAction := TN_RFrameAction(CompGroup.GroupActList.Items[0]);
    end else // create new Group and MoveComps RFrame Action in it
    begin
      CompGroup := TN_SGBase.Create( N_ActiveRFrame );
      RFSGroups.Add( CompGroup );
      CompGroup.GName := N_SMoveCompGName;
      Result.MCAction := CompGroup.SetAction( N_ActMoveComps, 0, -1, 0 );
    end;
//    CompGroup.SkipActions := True; // temporary disable

    TN_RFAMoveComps(Result.MCAction).RFAAlignForm := Result; // ref. to AlignForm
  end; // with N_ActiveRFrame do

end; // function N_CreateAlignForm

Initialization
  N_RFAClassRefs[N_ActMoveComps]  := TN_RFAMoveComps;
  N_RFAClassRefs[N_ActMarkComps]  := TN_RFAMarkComps;

end.
