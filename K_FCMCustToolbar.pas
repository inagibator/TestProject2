unit K_FCMCustToolbar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ToolWin, ComCtrls, StdCtrls, K_UDT1, N_BaseF, Menus;

type
  TK_FormCMCustToolbar = class(TN_BaseForm)
    DragTimer: TTimer;
    PnToolbars: TPanel;
    PnBBToolbars: TPanel;
    TBBB1: TToolBar;
    TBBB2: TToolBar;
    VTreeFrame: TN_VTreeFrame;
    PnSBToolbars: TPanel;
    TBSB1: TToolBar;
    TBSB2: TToolBar;
    TBSB3: TToolBar;
    TBSB4: TToolBar;
    ChBSmallButtons: TCheckBox;
    BtOK: TButton;
    BtCancel: TButton;
    TBPopupMenu: TPopupMenu;
    Delete1: TMenuItem;
    Addselectedbefore1: TMenuItem;
    Addselectedafter1: TMenuItem;
    BtDefaults: TButton;
    procedure ToolButtonEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure VTreeFrameEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TreeViewEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ToolBarDragOver(Sender, Source: TObject; X, Y: Integer;
                              State: TDragState; var Accept: Boolean);
    procedure ToolButtonDragOver(Sender, Source: TObject; X, Y: Integer;
                                 State: TDragState; var Accept: Boolean);
    procedure DragTimerTimer(Sender: TObject);
    procedure ToolButtonMouseDown(Sender: TObject; Button: TMouseButton;
                                  Shift: TShiftState; X, Y: Integer);
    procedure ChBSmallButtonsClick(Sender: TObject);
    procedure ToolBarMouseDown(Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
    procedure TBPopupMenuPopup(Sender: TObject);
    procedure AddSelectedBefore1Click(Sender: TObject);
    procedure AddSelectedAfter1Click(Sender: TObject);
    procedure BtDefaultsClick(Sender: TObject);
  private
    { Private declarations }
    ActUDRoot : TN_UDBase;
    CurDragObject : TObject;
    CurActUDObject : TN_UDBase;
    CurActTBObject : TToolButton;
    FSkipSmallButtonsClick : Boolean;
    CurToolBar : TToolBar;
    MaxButtonsCount : Integer;
    UDSRoot : TN_UDBase;

    ActListsIniPref : string;
    SmallButtonsIniPref : string;


    procedure RestoreCurState();
    function  CreateNewToolButton( AParentToolBar : TToolBar ) : TToolButton;
    function  CheckToolbarAccept( ATB: TToolBar ) : Boolean;
    procedure SaveCurState();
    procedure SelectCurrentToolBar( ATB: TToolBar );
    function  CheckActUDObject( ActUDObject : TN_UDBase ) : Boolean;
    procedure GetIniContext();
    procedure ExpandVTreeByUsedActions();
  public
    { Public declarations }
    SLs : array [0..3] of TStringList;
    procedure CTBVTOnMouseDown( AVTreeFrame: TN_VTreeFrame;
                 AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
    procedure CTBVTOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
    procedure CurStateToMemIni (); override;
//    procedure MemIniToCurState (); override;

  end;

type
  TK_ToolButton = class(TToolButton)
end;

var
  K_FormCMCustToolbar: TK_FormCMCustToolbar;

function K_CMCustomizeToolbarDlg( ACustGlobalInd : Integer ) : Boolean;

implementation

{$R *.dfm}

uses ActnList, Math,
K_FCMMain5F, K_CLib0, K_CM0,
N_Types, N_Lib0, N_CMMain5F, N_CMResF, N_Lib1;

function  K_CMCustomizeToolbarDlg( ACustGlobalInd : Integer ) : Boolean;
var
  i : Integer;
  MaximizeWindow : Boolean;
begin

  MaximizeWindow := not IsZoomed( N_CM_MainForm.CMMCurFMainForm.Handle );
  if MaximizeWindow then
    ShowWindow( N_CM_MainForm.CMMCurFMainForm.Handle, SW_SHOWMAXIMIZED );
//    N_CM_MainForm.CMMSetWindowState( 2 );
  K_FormCMCustToolbar := TK_FormCMCustToolbar.Create(Application);
  with K_FormCMCustToolbar do
  begin
    Height := Height + N_CM_MainForm.CMMCurFThumbsRFrame.Height - PnToolbars.Height;

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR, rspfShiftAll] );

// 2019-11-25 SIR 24115
    K_CMPrepIniFileCustToolbarNames( ActListsIniPref, SmallButtonsIniPref );
    N_Dump1Str( format( 'K_CMCustomizeToolbarDlg edit >> %s %s', [SmallButtonsIniPref, ActListsIniPref] ) );

{ this code is moved to K_CMPrepIniFileContNames
    ActListsIniPref := 'CMCustToolbar';
    SmallButtonsIniPref := 'CustToolbarSmallButtons';
    if ACustGlobalInd = 1 then
    begin
      ActListsIniPref := 'G' + ActListsIniPref;
      SmallButtonsIniPref := 'G' + SmallButtonsIniPref;
      Caption := 'Location ' + Caption
    end
    else
    if ACustGlobalInd = 2 then
    begin
      ActListsIniPref := 'GG' + ActListsIniPref;
      SmallButtonsIniPref := 'GG' + SmallButtonsIniPref;
      Caption := 'Global ' + Caption
    end;
}
    // Get Cur State from Ini File to StringLists
    for i := 0 to 3 do
      SLs[i] := TStringList.Create();

    GetIniContext();

    ActUDRoot := TN_UDBase.Create();
    UDSRoot := TN_UDBase.Create();
    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipInlineEdit];
    Result := ShowModal() = mrOK;
    K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsSkipInlineEdit];

    // restrore UDTree References before deletion
    for i := 0 to UDSRoot.DirHigh do
      Inc( UDSRoot.DirChild(i).RefCounter );

    UDSRoot.UDDelete();

    if Result then
    begin
      // Cur State to StringLists
      SaveCurState();
      // Save StringLists to Inifile
      for i := 0 to 3 do
        N_StringsToMemIni( ActListsIniPref + IntToStr(i), SLs[i] );
      // Save Small Buttons Flag to IniFile
      N_BoolToMemIni( 'CMS_Main', SmallButtonsIniPref,  ChBSmallButtons.Checked );
    end; // if ShowModal() = mrOK then

    // Free Objects
    for i := 0 to 3 do
      SLs[i].Free;
    ActUDRoot.UDDelete();
  end;

  if MaximizeWindow then
    ShowWindow( N_CM_MainForm.CMMCurFMainForm.Handle, SW_SHOWNORMAL );

end; // procedure  K_CMCustomizeToolbarDlg

//********************************** TK_FormCMCustToolbar.ToolButtonEndDrag ***
// OnEndDrag event handler for existing ToolButton
//
//     Parameters
// Sender - Dragging ToolButton
// Target - Target Object (ToolBar or ToolButton)
// X,Y    - Cursor coordinates
//
procedure TK_FormCMCustToolbar.ToolButtonEndDrag( Sender, Target: TObject; X,
  Y: Integer );
begin
  if Target <> nil then
    TreeViewEndDrag(Sender, Target, X, Y ) // Do real EndDrag action
  else
    Sender.Free(); // Remove Existing ToolButton if drag out of ToolBar

end; // procedure TK_FormCMCustToolbar.ToolButtonEndDrag

//********************************** TK_FormCMCustToolbar.VTreeFrameEndDrag ***
// OnEndDrag event handler for VTreeFrame
//
//     Parameters
// Sender - Dragging Object ToolButton or New Action
// Target - Target Object (ToolBar or ToolButton)
// X,Y    - Cursor coordinates
//
procedure TK_FormCMCustToolbar.VTreeFrameEndDrag(Sender, Target: TObject; X, Y: Integer);
var i : Integer;
begin
  if CurDragObject is TList then
  begin
    with VTreeFrame, VTree do
    begin
      TreeView.Items.BeginUpdate();
      for i := VTreeFrame.VTree.MarkedVNodesList.Count - 1 downto 0 do
        if not CheckActUDObject( TN_VNode(MarkedVNodesList[i]).VNUDObj ) then
          TN_VNode(MarkedVNodesList[i]).UnMark();
      TreeView.Items.EndUpdate();
      CurDragObject := nil;
    end;
    if Target is TToolBar then
    begin
      CurToolBar := TToolBar(Target);
      AddSelectedAfter1Click(Sender)
    end
    else
    begin
      CurActTBObject := TToolButton(Target);
      AddSelectedBefore1Click(Sender);
    end;
  end
  else
    TreeViewEndDrag(Sender, Target, X, Y ) // Do real EndDrag action
end; // procedure TK_FormCMCustToolbar.VTreeFrameEndDrag

//************************************ TK_FormCMCustToolbar.TreeViewEndDrag ***
// OnEndDrag event handler for TreeView
//
//     Parameters
// Sender - Dragging Object ToolButton or New Action
// Target - Target Object (ToolBar or ToolButton)
// X,Y    - Cursor coordinates
//
procedure TK_FormCMCustToolbar.TreeViewEndDrag(Sender, Target: TObject; X,Y: Integer);
var
  TargetToolBar : TToolBar;
  Ind, i : Integer;
//  NewToolButton : TK_ToolButton;
//  NewToolButton : TToolButton;
  SHint : string;
  SImageInd : Integer;
  SName : string;
  WName : string;
  SrcToolBar : TToolBar;
  SrcInd : Integer;

label LExit;
begin
//  inherited;
//  StatusBar.SimpleText := format( 'Drop Name=%s (X,Y)=(%d,%d)', [TControl(Target).Name,X,Y] );

  TargetToolBar := nil;
  if Target is TToolBar then
    TargetToolBar := TToolBar(Target)
  else
  if Target is TToolButton then
    TargetToolBar := TToolBar(TControl(Target).Parent);

  if TargetToolBar <> nil then
  begin
    Ind := -1;
    if Target is TToolBar then
      Ind := TargetToolBar.ButtonCount
    else
    if Target is TToolButton then
      for i := 0 to TargetToolBar.ButtonCount - 1 do
        if TargetToolBar.Buttons[i] = Target then
        begin
          Ind := i;
          break;
        end;

    N_Dump2Str( format( '!!! Start customizing >> target Toolbar %s TargetInd=%d', [TargetToolBar.Name, Ind] ) );
    SrcInd := 0;
    if CurDragObject is TN_UDBase then
    begin
      with TAction(TN_UDBase(CurDragObject).Marker) do
      begin
        SHint := Hint;
        SImageInd := ImageIndex;
        SName := Name;
      end;

      CreateNewToolButton( TargetToolBar );
      N_Dump2Str( format( 'Src Action %s', [SName] ) );
    end   // if CurDragObject is TN_UDBase then
    else
    begin // if CurDragObject is TToolButton then
      with TToolButton(CurDragObject) do
      begin
        SHint := Hint;
        SImageInd := ImageIndex;
        SName := Name;
        SrcToolBar := TToolBar(Parent);
        if SrcToolBar <> TargetToolBar then
        begin
        // Move to other ToolBar
          Free;
          SrcToolBar.Realign();
          CreateNewToolButton( TargetToolBar );
          N_Dump2Str( format( 'Move %s from %s to %s ',
                              [SName, SrcToolBar.Name, TargetToolBar.Name] ) );
        end   // if SrcToolBar <> TargetToolBar then
        else
        begin // if SrcToolBar = TargetToolBar then
        // Move in the same ToolBar
          for i := 0 to SrcToolBar.ButtonCount - 1 do
            if TargetToolBar.Buttons[i] = CurDragObject then
            begin
              SrcInd := i;
              break;
            end;
          if Ind = TargetToolBar.ButtonCount then
            Ind := Ind - 1;
          N_Dump2Str( format( 'Src Toolbutton SrcInd=%d TargetInd=%d', [SrcInd, Ind] ) );
          if SrcInd = Ind then goto LExit;
        end; // if SrcToolBar = TargetToolBar then
      end;
    end; // if CurDragObject is TToolButton then

    if SrcInd <= Ind then
      for i := SrcInd to Ind - 1  do
      with TargetToolBar.Buttons[i] do
      begin
        N_Dump2Str( format( 'Set Toolbutton [%d] %s << [%d] %s', [i, Name, i+1, TargetToolBar.Buttons[i+1].Name] ) );
        Hint  := TargetToolBar.Buttons[i+1].Hint;
        ImageIndex  := TargetToolBar.Buttons[i+1].ImageIndex;
        WName := TargetToolBar.Buttons[i+1].Name;
        TargetToolBar.Buttons[i+1].Name := '';
        Name  := WName;
      end
    else
    begin // if SrcInd > Ind then
      for i := SrcInd downto Ind + 1  do
      with TargetToolBar.Buttons[i] do
      begin
        N_Dump2Str( format( 'Set Toolbutton [%d] %s << [%d] %s', [i, Name, i-1, TargetToolBar.Buttons[i-1].Name] ) );
        Hint  := TargetToolBar.Buttons[i-1].Hint;
        ImageIndex  := TargetToolBar.Buttons[i-1].ImageIndex;
        WName := TargetToolBar.Buttons[i-1].Name;
        TargetToolBar.Buttons[i-1].Name := '';
        Name  := WName;
      end;
    end;  // if SrcInd > Ind then

//    TargetToolBar.Buttons[Ind].Action  := TAction(TN_UDBase(CurDragObject).Marker);
    N_Dump2Str( format( 'Set Toolbutton [%d] %s << %s', [Ind, TargetToolBar.Buttons[Ind].Name, SName] ) );
    TargetToolBar.Buttons[Ind].Hint := SHint;
    TargetToolBar.Buttons[Ind].ImageIndex := SImageInd;
    TargetToolBar.Buttons[Ind].Name := SName;

    TargetToolBar.Realign();
    SelectCurrentToolBar( TargetToolBar );
  end; // if TargetToolBar <> nil then

LExit:
  CurDragObject  := nil;
end; // procedure TK_FormCMCustToolbar.TreeViewEndDrag

//******************************************* TK_FormCMCustToolbar.FormShow ***
// OnShow event handler
//
//     Parameters
// Sender - Self
//
procedure TK_FormCMCustToolbar.FormShow(Sender: TObject);
var
  UDFolder : TN_UDBase;
  UDFolder1 : TN_UDBase;
  UDFolder2 : TN_UDBase;

  procedure AddUDAction( Act : TAction; ActLRoot : TN_UDBase );
  var
    UDAct : TN_UDBase;
  begin
    UDAct := TN_UDBase.Create();
    UDAct.ObjName   := Act.Name;
    UDAct.ObjAliase := K_CMClearActCaption( Act.Caption );
    UDAct.ObjInfo   := Act.Hint;
    if UDAct.ObjInfo = '' then UDAct.ObjInfo := UDAct.ObjAliase;
    UDAct.ImgInd    := Act.ImageIndex;
    UDAct.Marker    := Integer(Act);
    ActLRoot.InsOneChild( -1, UDAct );
    UDSRoot.InsOneChild( -1, UDAct );
    Dec(UDAct.RefCounter); // To correct show in  TreeView, Should be restored before UDTree destruction
  end;

  procedure AddUDFolder( ALFolderName : string; ActLRoot : TN_UDBase );
  begin
    UDFolder := TN_UDBase.Create();
    UDFolder.ObjName   := ALFolderName;
    UDFolder.ImgInd    := 4;
    ActLRoot.InsertEmptyEntries( -1, 1 );
    ActLRoot.PutDirChild( ActLRoot.DirHigh(), UDFolder );
  end;
begin

// Create Actions Tree View
  AddUDFolder( 'Rotate and Flip', ActUDRoot );

//  AddUDAction( TAction(N_CMResForm.FindComponent('aToolsRotateLeft')), UDFolder );
  AddUDAction( N_CMResForm.aToolsRotateLeft, UDFolder );
  AddUDAction( N_CMResForm.aToolsRotateRight, UDFolder );
  AddUDAction( N_CMResForm.aToolsRotate180, UDFolder );
  AddUDAction( N_CMResForm.aToolsRotateByAngle, UDFolder );
  AddUDAction( N_CMResForm.aToolsFlipHorizontally, UDFolder );
  AddUDAction( N_CMResForm.aToolsFlipVertically, UDFolder );

  AddUDFolder('Convert', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsCropImage, UDFolder );
  AddUDAction( N_CMResForm.aToolsConvTo8, UDFolder );
  AddUDAction( N_CMResForm.aToolsConvToGrey, UDFolder );
  AddUDAction( N_CMResForm.aToolsNegate11, UDFolder );

  AddUDFolder( 'Brightness / Contrast / Gamma', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsBriCoGam, UDFolder );
  AddUDAction( N_CMResForm.aToolsAutoContrast, UDFolder );
  AddUDAction( N_CMResForm.aToolsAutoEqualize, UDFolder );

  AddUDFolder( 'Noise Reduction', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsNoiseSelf, UDFolder );
  AddUDAction( N_CMResForm.aToolsMedian, UDFolder );
  AddUDAction( N_CMResForm.aToolsDespeckle, UDFolder );
  AddUDAction( N_CMResForm.aToolsImgSharp, UDFolder );
  AddUDAction( N_CMResForm.aToolsImgSmooth, UDFolder );

  AddUDFolder( 'Global Image Filters', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsFilterA, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilterB, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilterC, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilterD, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilterE, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilterF, UDFolder );

  AddUDFolder( 'User Image Filters', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsFilter1, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilter2, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilter3, UDFolder );
  AddUDAction( N_CMResForm.aToolsFilter4, UDFolder );

  AddUDFolder( 'Change view, Histogram', ActUDRoot );
  AddUDAction( N_CMResForm.aToolsEmboss, UDFolder );
//  AddUDAction( N_CMResForm.aToolsEmbossAttrs, UDFolder );
  AddUDAction( N_CMResForm.aToolsColorize, UDFolder );
  AddUDAction( N_CMResForm.aToolsIsodens, UDFolder );
  AddUDAction( N_CMResForm.aToolsHistogramm2, UDFolder );

  AddUDFolder( 'Annotations', ActUDRoot );
  UDFolder1 := UDFolder;
  AddUDFolder( 'Measure Annotations', UDFolder1 );
  AddUDAction( N_CMResForm.aObjPolylineM, UDFolder );
  AddUDAction( N_CMResForm.aObjAngleNorm, UDFolder );
  AddUDAction( N_CMResForm.aObjAngleFree, UDFolder );

  AddUDFolder( 'Calibrate Image', UDFolder );
  AddUDAction( N_CMResForm.aObjCalibrate1, UDFolder );
  AddUDAction( N_CMResForm.aObjCalibrateN, UDFolder );
  AddUDAction( N_CMResForm.aObjCalibrateDPI, UDFolder );

  AddUDFolder( 'Annotations', UDFolder1 );
  AddUDAction( N_CMResForm.aObjDot, UDFolder );
  AddUDAction( N_CMResForm.aObjTextBox, UDFolder );

  UDFolder2 := UDFolder;
  AddUDFolder( 'Customizable Text Annotations', UDFolder2 );
  AddUDAction( N_CMResForm.aObjCTA1, UDFolder );
  AddUDAction( N_CMResForm.aObjCTA2, UDFolder );
  AddUDAction( N_CMResForm.aObjCTA3, UDFolder );
  AddUDAction( N_CMResForm.aObjCTA4, UDFolder );

  AddUDAction( N_CMResForm.aObjFreeHand, UDFolder2 );
  AddUDAction( N_CMResForm.aObjPolyline, UDFolder2 );
  AddUDAction( N_CMResForm.aObjRectangleLine, UDFolder2 );
  AddUDAction( N_CMResForm.aObjEllipseLine, UDFolder2 );
  AddUDAction( N_CMResForm.aObjArrowLine, UDFolder2 );
  AddUDAction( N_CMResForm.aObjFLZEllipse, UDFolder2 );

  AddUDAction( N_CMResForm.aObjChangeAttrs, UDFolder1 );
  AddUDAction( N_CMResForm.aObjDelete, UDFolder1 );
  AddUDAction( N_CMResForm.aObjShowHide, UDFolder1 );

  AddUDFolder( 'Edit', ActUDRoot );
  AddUDAction( N_CMResForm.aEditRestOrigImage, UDFolder );
  AddUDAction( N_CMResForm.aEditUndoLast, UDFolder );
  AddUDAction( N_CMResForm.aEditRedoLast, UDFolder );
  AddUDAction( N_CMResForm.aEditUndoRedo, UDFolder );


// Init Toolbars
  TBBB1.Images := TK_FormCMMain5(N_CM_MainForm.CMMCurFMainForm).MainIcons44;
  TBBB2.Images := TBBB1.Images;

  TBSB1.Images := TK_FormCMMain5(N_CM_MainForm.CMMCurFMainForm).MainIcons18;
  TBSB2.Images := TBSB1.Images;
  TBSB3.Images := TBSB1.Images;
  TBSB4.Images := TBSB1.Images;

  // From StringLists to Toolbars - Initiate ToolBars Rebuild
  DragTimer.Enabled := TRUE;


// Init VTeeFrame
  VtreeFrame.CreateVTree( ActUDRoot, K_fvSkipCurrent{ + K_fvDirSortedByObjName}, 4 );
  VTreeFrame.MultiMark := true;
  VTreeFrame.OnMouseDownProcObj := CTBVTOnMouseDown;
  VTreeFrame.OnDoubleClickProcObj := CTBVTOnDoubleClickProcObj;
//  VTreeFrame.OnSelectProcObj := SCSVTFOnSelect;
//  VTreeFrame.OnDoubleClickProcObj := SCSOnDoubleClickProcObj;

//  VtreeFrame.RebuildVTree( ActUDRoot );
  VTreeFrame.VTree.TreeView.Images := TK_FormCMMain5(N_CM_MainForm.CMMCurFMainForm).MainIcons18;
//  VTreeFrame.VTree.TreeView.FullExpand;
//  VTreeFrame.RebuildVTree( ActUDRoot, nil, nil );
  N_MemIniToStrings( 'CMCustToolbarTVState', K_CMEDAccess.TmpStrings );
  VTreeFrame.RebuildVTree( ActUDRoot, nil, K_CMEDAccess.TmpStrings );
//  if K_CMEDAccess.TmpStrings.Count = 0 then
  ExpandVTreeByUsedActions();
end; // procedure TK_FormCMCustToolbar.FormShow

//******************************************* TK_FormCMCustToolbar.FormShow ***
// OnCloseQuery event handler
//
procedure TK_FormCMCustToolbar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//  VTreeFrame.Visible := FALSE;
//  ActUDRoot.UDDelete();
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsSkipInlineEdit];
end; // procedure TK_FormCMCustToolbar.FormCloseQuery

//************************************ TK_FormCMCustToolbar.ToolBarDragOver ***
// OnDragOver event handler for ToolBar
//
//     Parameters
// Sender - Dragging over ToolBar
// Source - Dragging Object (ToolButton or Action)
// X,Y    - Cursor coordinates
// State  - Drag State
// Accept - set TRUE if EndDrag is possible
//
procedure TK_FormCMCustToolbar.ToolBarDragOver( Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean );
begin
//  inherited;
//  StatusBar.SimpleText := format( 'Over Name=%s (X,Y)=(%d,%d)', [TControl(Sender).Name,X,Y] );
  Accept := (CurDragObject <> nil) and
            CheckToolbarAccept( TToolbar(Sender) );
end; // procedure TK_FormCMCustToolbar.ToolBarDragOver

//********************************* TK_FormCMCustToolbar.ToolButtonDragOver ***
// OnDragOver event handler for ToolButton
//
//     Parameters
// Sender - Dragging over ToolButton
// Source - Dragging Object (ToolButton or Action)
// X,Y    - Cursor coordinates
// State  - Drag State
// Accept - set TRUE if EndDrag is possible
//
procedure TK_FormCMCustToolbar.ToolButtonDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
//  inherited;
//  StatusBar.SimpleText := format( 'Over Name=%s (X,Y)=(%d,%d)', [TControl(Sender).Name,X,Y] );
  Accept := (CurDragObject <> nil) and
            CheckToolbarAccept( TToolbar(TToolbutton(Sender).Parent) );
end; // procedure TK_FormCMCustToolbar.ToolButtonDragOver

//************************************ TK_FormCMCustToolbar.CDragTimerTimer ***
// Timer OnTimer event handler
//
procedure TK_FormCMCustToolbar.DragTimerTimer(Sender: TObject);
var
  i, ACount : Integer;
begin
//  inherited;
  DragTimer.Enabled := false;

  if MaxButtonsCount = 0 then
  begin // ToolBars Initiation during form show
    RestoreCurState();
    SelectCurrentToolBar( nil );
  end;

  CurDragObject := nil;
  if not N_KeyIsDown(VK_LBUTTON) then Exit;

  if CurActUDObject <> nil then
  begin
    ACount := 0;
    with VTreeFrame, VTree do
      for i := MarkedVNodesList.Count - 1 downto 0 do
        if CheckActUDObject( TN_VNode(MarkedVNodesList[i]).VNUDObj ) then
          Inc(ACount);
    if ACount > 1 then
    begin
      CurDragObject := VTreeFrame.VTree.MarkedVNodesList;
      VTreeFrame.DragCursor := crMultiDrag
    end
    else
      VTreeFrame.DragCursor := crDrag;
    if CurDragObject <> nil then
      VTreeFrame.BeginDrag( TRUE );
  end
  else
  if CurActTBObject <> nil then
  begin
//    TToolBar((CurActTBObject).Parent).BeginDrag( TRUE );
    CurActTBObject.BeginDrag( TRUE );
    CurDragObject := CurActTBObject;
  end;

  CurActTBObject := nil;
  CurActUDObject := nil;
end; // procedure TK_FormCMCustToolbar.DragTimerTimer

//******************************** TK_FormCMCustToolbar.ToolButtonMouseDown ***
// ToolButton OnMouseDown event handler
//
procedure TK_FormCMCustToolbar.ToolButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  inherited;

  CurActTBObject := TToolButton(Sender);
  SelectCurrentToolBar( TToolBar(CurActTBObject.Parent));
  if not (ssLeft in Shift) then Exit;
  DragTimer.Enabled := TRUE;
  CurActUDObject := nil;

end; // procedure TK_FormCMCustToolbar.ToolButtonMouseDown


//******************************* TK_FormCMCustToolbar.ChBSmallButtonsClick ***
// CheckBox OnClick event handler
//
procedure TK_FormCMCustToolbar.ChBSmallButtonsClick(Sender: TObject);
var
  i, j, k, n, m, t : Integer;

begin
  if FSkipSmallButtonsClick then Exit;

  N_Dump2Str( format( 'Change buttons size Small=%s', [N_B2S(ChBSmallButtons.Checked)] ) );
  SaveCurState();
//N_Dump1Strings(

  // Adopt Action Lists to BigButton ToolBars after SmallButton ToolBars
  if not ChBSmallButtons.Checked then
  begin
    // Maximal Number of Buttons in the ToolBar
    MaxButtonsCount := Round(Int(Max(TBSB1.ClientHeight,TBBB1.ClientHeight) / TBBB1.ButtonHeight));

   ////////////////////
   // Skip Empty Lists
    j := -1;
    k := 0; // Number of not empty Lists
    n := 0; // Number of Actions in all Lists
    m := 0; // Number of Lists with Extra Actions
    t := 0; // Number of Actions in Tail Lists
    for i := 0 to 3 do
    begin
      if SLs[i].Count > 0 then Inc( k );
      if SLs[i].Count > MaxButtonsCount then Inc( m );
      n := n + SLs[i].Count;
      if i > 0 then
        t := t + SLs[i].Count;
      if (SLs[i].Count = 0) and (j = -1) then
        j := i // Fist empty list to move filled lists
      else
      if (SLs[i].Count > 0) and (j <> -1) then
      begin // move not empty list to new position
        SLs[j].Assign(SLs[i]);
        Inc(j);
        SLs[i].Clear;
      end;
    end;

    if (k > 2) or (n > MaxButtonsCount * 2) or (m > 0) then
    begin
      ////////////////////////////////
      // Move Actions to other Lists
      // if number of lists mor then 2, or number of actions large, or there Lists with extra number of Actions
      for i := 0 to 2 do
      begin
        if SLs[i].Count = MaxButtonsCount then Continue
        else
        if SLs[i].Count > MaxButtonsCount then
        begin // if SLs[i].Count > MCount then
        // Move Extra actions to Next Actions List
          for j := SLs[i].Count -1 downto MaxButtonsCount do
          begin
            SLs[i+1].Insert( 0, SLs[i][j] );
            SLs[i].Delete( j );
          end;
        end    // if SLs[i].Count > MCount then
        else
        if (t > MaxButtonsCount) or (i > 0) then
        begin  // if SLs[i].Count < MCount then
        //  Move Actions from Next lists to Current
        // (it is last List or it is first List but number of actions in tail Lists is large)
          for n := i + 1 to 3 do
          begin
            k := MaxButtonsCount - SLs[i].Count;
            if k = 0 then break;
            if k > SLs[n].Count then
              k := SLs[n].Count;
            // Move Actions from n List to Current
            for j := 0 to k - 1 do
            begin
              SLs[i].Add( SLs[n][0] );
              SLs[n].Delete( 0 );
            end;
          end; // for n := i + 1 to 3 do
        end;   // if SLs[i].Count < MaxButtonsCount then
      end; // for i := 0 to 2 do
    end; // if (k > 2) or (n > MaxButtonsCount * 2) or (m > 0) then
    CurToolBar := nil;
  end // if not ChBSmallButtons.Checked then
  else
  begin
    if CurToolBar = TBBB1 then CurToolBar := TBSB1;
    if CurToolBar = TBBB2 then CurToolBar := TBSB2;
  end;

  RestoreCurState();
  SelectCurrentToolBar( CurToolBar );
  N_Dump2Str( 'Change buttons size fin' );

end; // procedure TK_FormCMCustToolbar.ChBSmallButtonsClick

//*********************************** TK_FormCMCustToolbar.ToolBarMouseDown ***
// Delete1 menu item OnClick Handler
//
procedure TK_FormCMCustToolbar.ToolBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SelectCurrentToolBar( TToolBar(Sender));
  CurActTBObject := nil;
end; // procedure TK_FormCMCustToolbar.ToolBarMouseDown

//*************************************** TK_FormCMCustToolbar.Delete1Click ***
// Delete1 menu item OnClick Handler
//
// Delete current ToolButton
//
procedure TK_FormCMCustToolbar.Delete1Click(Sender: TObject);
begin
  CurActTBObject.Free();
  CurActTBObject := nil;
end; // procedure TK_FormCMCustToolbar.Delete1Click

//*********************************** TK_FormCMCustToolbar.TBPopupMenuPopup ***
// TBPopupMenu OnPopup Handler
//
// Calculate if PopUp menu Items are enabled
//
procedure TK_FormCMCustToolbar.TBPopupMenuPopup(Sender: TObject);
var
  i, ProcCount : Integer;
begin
//
  with VTreeFrame.VTree do
  begin
  // Clear Marked List from not available items
    TreeView.Items.BeginUpdate();
    for i := MarkedVNodesList.Count - 1 downto 0 do
      if not CheckActUDObject( TN_VNode(MarkedVNodesList[i]).VNUDObj ) then
        TN_VNode(MarkedVNodesList[i]).UnMark();
    CurDragObject := nil;
    TreeView.Items.EndUpdate();

    ProcCount := 0;
    if CurToolBar <> nil then
    begin
      ProcCount := MaxButtonsCount - CurToolBar.ButtonCount;
      if ProcCount > MarkedVNodesList.Count then
        ProcCount := MarkedVNodesList.Count;
    end;
  end;
  Delete1.Enabled := (CurActTBObject <> nil);
  Addselectedbefore1.Enabled := (ProcCount > 0) and (CurActTBObject <> nil);
  Addselectedafter1.Enabled := (ProcCount > 0);
end; // procedure TK_FormCMCustToolbar.TBPopupMenuPopup

//**************************** TK_FormCMCustToolbar.AddSelectedBefore1Click ***
// Addselectedbefore1 menu item OnClick Handler
//
// Insert selected actions before to current ToolButton
//
procedure TK_FormCMCustToolbar.AddSelectedBefore1Click(Sender: TObject);
var
  i, ProcCount : Integer;
begin
  with VTreeFrame.VTree do
  begin

    ProcCount := MaxButtonsCount - CurToolBar.ButtonCount;
    if ProcCount > MarkedVNodesList.Count then
      ProcCount := MarkedVNodesList.Count;

    for i := 0 to ProcCount - 1 do
    begin
      CurDragObject := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      TreeViewEndDrag( VTreeFrame, CurActTBObject, 0, 0 );
    end;

    TreeView.Items.BeginUpdate();
    for i := ProcCount - 1 downto 0  do
      TN_VNode(MarkedVNodesList[i]).UnMark();
    SetSelectedVNode( nil );
    TreeView.Items.EndUpdate();
  end;
end; // procedure TK_FormCMCustToolbar.AddSelectedBefore1Click

//***************************** TK_FormCMCustToolbar.AddSelectedAfter1Click ***
// Addselectedafter1 menu item OnClick Handler
//
// Add selected actions to the current ToolBar
//
procedure TK_FormCMCustToolbar.AddSelectedAfter1Click(Sender: TObject);
var
  i, ProcCount : Integer;
begin
  with VTreeFrame.VTree do
  begin
    ProcCount := MaxButtonsCount - CurToolBar.ButtonCount;
    if ProcCount > MarkedVNodesList.Count then
      ProcCount := MarkedVNodesList.Count;

    for i := 0 to ProcCount - 1 do
    begin
      CurDragObject := TN_VNode(MarkedVNodesList[i]).VNUDObj;
      TreeViewEndDrag( VTreeFrame, CurToolBar, 0, 0 );
    end;

    TreeView.Items.BeginUpdate();
    for i := ProcCount - 1 downto 0  do
      TN_VNode(MarkedVNodesList[i]).UnMark();
    SetSelectedVNode( nil );
    TreeView.Items.EndUpdate();
  end;

end; // procedure TK_FormCMCustToolbar.AddSelectedAfter1Click

//************************************ TK_FormCMCustToolbar.BtDefaultsClick ***
// Button BtDefaults OnClick Handler
//
// Set default values
//
procedure TK_FormCMCustToolbar.BtDefaultsClick(Sender: TObject);
begin
  N_Dump2Str( 'Set Deafaults Start' );
  SLs[1].Clear;
  SLs[2].Clear;
  SLs[3].Clear;
  N_MemIniToStrings( 'CMCustToolbar', SLs[0] );
  FSkipSmallButtonsClick := TRUE;
  ChBSmallButtons.Checked := FALSE;
  FSkipSmallButtonsClick := FALSE;

  RestoreCurState();
  SelectCurrentToolBar( nil );
  ExpandVTreeByUsedActions();
  N_Dump2Str( 'Set Deafaults Fin' );
end; // procedure TK_FormCMCustToolbar.BtDefaultsClick

//************************************ TK_FormCMCustToolbar.RestoreCurState ***
// Build Current ToolBars using Current State Actions Lists
//
procedure TK_FormCMCustToolbar.RestoreCurState;
var
  NewToolButton : TToolButton;
  NewAct : TAction;
  ActName : string;

  procedure ClearToolbars( APanel : TPanel );
  var
    i,j : Integer;
  begin
    for i := 0 to APanel.ControlCount - 1 do
    begin
      with TToolbar(APanel.Controls[i]) do
      for j := ButtonCount downto 1 do
        Buttons[0].Free;
    end;
  end;

  procedure FillToolbars( APanel : TPanel );
  var
    i, j : Integer;
  begin
    for i := 0 to APanel.ControlCount - 1 do
    begin
      with SLs[i] do
      for j := Count - 1 downto 0 do
      begin
        ActName := Strings[j];
        NewAct := TAction(N_CMResForm.FindComponent( ActName ));
        if NewAct = nil then
          N_Dump1Str( format( '!!!CustToolbar >> action %s not found', [ActName] ) )
        else
        begin
          NewToolButton := CreateNewToolButton( TToolbar(APanel.Controls[i]) );
          NewToolButton.Hint := NewAct.Hint;
          NewToolButton.ImageIndex := NewAct.ImageIndex;
          NewToolButton.Name := NewAct.Name;
        end
      end;
      TToolbar(APanel.Controls[i]).Realign();
    end;
  end;

begin
  N_Dump2Str( 'Rebuild ToolBars Start' );
  ClearToolbars( PnBBToolbars );
  ClearToolbars( PnSBToolbars );
  if ChBSmallButtons.Checked then
  begin

    PnSBToolbars.Visible := TRUE;
    PnBBToolbars.Visible := FALSE;

    FillToolbars( PnSBToolbars );
    MaxButtonsCount := Round(Int(TBSB1.ClientHeight / TBSB1.ButtonHeight));
  end
  else
  begin

    PnBBToolbars.Visible := TRUE;
    PnSBToolbars.Visible := FALSE;

    FillToolbars( PnBBToolbars );
    MaxButtonsCount := Round(Int(TBBB1.ClientHeight / TBBB1.ButtonHeight));
  end;
  N_Dump2Str( 'Rebuild ToolBars Fin MaxButtons=' + IntToStr(MaxButtonsCount) );

end; // procedure TK_FormCMCustToolbar.RestoreCurState

//******************************** TK_FormCMCustToolbar.CreateNewToolButton ***
// Create New ToolBtton on the given ToolBar
//
//     Parameters
// AParentToolBar - given ToolBar to create ToolButton
// Result - Returns new ToolButton
//
function TK_FormCMCustToolbar.CreateNewToolButton( AParentToolBar : TToolBar ) : TToolButton;
begin
  Result := TToolButton.Create(Self);
//    NewToolButton := TK_ToolButton.Create(Self);
  with Result do
  begin
//      SetToolBar(TargetToolBar);
    Enabled := TRUE;
    PopupMenu := TBPopupMenu;
    Parent := AParentToolBar;
    OnDragOver := ToolButtonDragOver;
    OnEndDrag := ToolButtonEndDrag;
    OnMouseDown := ToolButtonMouseDown;
    ShowHint := TRUE;
    Wrap := TRUE;
    Name := 'ToolButton' + IntToStr( AParentToolBar.ButtonCount );
    N_Dump2Str( format( 'New %s TB=%s', [Name, AParentToolBar.Name] ) );
  end;
end; // procedure TK_FormCMCustToolbar.CreateNewToolButton

//********************************* TK_FormCMCustToolbar.CheckToolbarAccept ***
// Check if Toolbar can accept new ToolButton
//
//     Parameters
// ATB - given ToolBar
// Result - Returns TRUE if ToolBar can accept New ToolButton
//
function TK_FormCMCustToolbar.CheckToolbarAccept( ATB: TToolBar ) : Boolean;
var
  AddSize : Integer;
begin
  with ATB do
  begin
    AddSize := ButtonHeight;
    if not (CurDragObject is TToolButton) or
       (TToolButton(CurDragObject).Parent <> ATB) then
      AddSize := AddSize + ButtonHeight;
    Result := (ButtonCount = 0) or
              (Buttons[ButtonCount - 1].Top + AddSize < ClientHeight);
  end;
end; // function TK_FormCMCustToolbar.CheckToolbarAccept

//*************************************** TK_FormCMCustToolbar.SaveCurState ***
// Save Current Toolbars state in the Actions Lists
//
procedure TK_FormCMCustToolbar.SaveCurState;
var
  i,j : Integer;
begin
  for i := 0 to 3 do
    SLs[i].Clear;

  if PnSBToolbars.Visible then
  begin
  // Save Toolbars with Small Buttons
    for i := 0 to PnSBToolbars.ControlCount - 1 do
    begin
      with TToolbar(PnSBToolbars.Controls[i]) do
      for j := 0 to ButtonCount - 1 do
        SLs[i].Add( Buttons[j].Name );
    end;
  end
  else
  begin
  // Save Toolbars with Big Buttons
    for i := 0 to PnBBToolbars.ControlCount - 1 do
    begin
      with TToolbar(PnBBToolbars.Controls[i]) do
      for j := 0 to ButtonCount - 1 do
        SLs[i].Add( Buttons[j].Name );
    end;
  end;

end; // procedure TK_FormCMCustToolbar.SaveCurState

//******************************* TK_FormCMCustToolbar.SelectCurrentToolBar ***
// Select current Toolbar for New Button add
//
//     Parameters
// ATB - given ToolBar
//
procedure TK_FormCMCustToolbar.SelectCurrentToolBar( ATB : TToolBar );
var
  i, m : Integer;
  CurPn: TPanel;
  CTB : TToolBar;
  SearchNext : Boolean;
begin
  if CurToolBar <> nil then
  begin
    N_Dump2Str( format( 'Prev current TB=%s', [CurToolBar.Name] ) );
    CurToolBar.EdgeOuter := esLowered;
    CurToolBar.EdgeInner := esLowered;
//    CurToolBar.Repaint();
    CurToolBar := nil;
  end;

  if (ATB <> nil) and (ATB.ButtonCount < MaxButtonsCount) then
    CurToolBar := ATB
  else
  begin // if (ATB = nil) or (ATB.ButtonCount = MaxButtonsCount)
    CurPn := PnSBToolbars;
    if not ChBSmallButtons.Checked then
      CurPn := PnBBToolbars;
    SearchNext :=  ATB <> nil;

    m := -1;
    for i := 0 to CurPn.ControlCount - 1 do
    begin
      CTB := TToolbar(CurPn.Controls[i]);
      if not SearchNext then
      begin
        if CTB.ButtonCount < MaxButtonsCount then
        begin
          CurToolBar := CTB;
          Break;
        end;
      end
      else
      begin
        if (m = -1) and (CTB.ButtonCount < MaxButtonsCount) then
          m := i;
        if CTB = ATB then SearchNext := FALSE;
      end;
    end; // for i := 0 to CurPn.ControlCount - 1 do

    if (CurToolBar = nil) and (m >= 0) then
      CurToolBar := TToolbar(CurPn.Controls[m]);
  end; // if (ATB = nil) or (ATB.ButtonCount = MaxButtonsCount)

  if CurToolBar <> nil then
  begin
    CurToolBar.EdgeOuter := esRaised;
    CurToolBar.EdgeInner := esRaised;
    N_Dump2Str( format( 'New current TB=%s', [CurToolBar.Name] ) );
//    CurToolBar.Repaint();
  end;

end; // procedure TK_FormCMCustToolbar.SelectCurrentToolBar

//********************************* TK_FormCMCustToolbar.CheckToolbarAccept ***
// Check if UDObject is linked with Action that can be added ToolBar
//
//     Parameters
// ActUDObject - given UDObject
// Result - Returns TRUE if Action linked to given UDObject can be added to ToolBar
//
function TK_FormCMCustToolbar.CheckActUDObject( ActUDObject : TN_UDBase ) : Boolean;
var
  ActName : string;
  ImgInd : Integer;
begin
  Result := (ActUDObject <> nil) and (ActUDObject.Marker <> 0);
  if not Result then Exit;

  with TAction(ActUDObject.Marker) do
  begin
    ActName := TAction(ActUDObject.Marker).Name;
    ImgInd := ImageIndex;
  end;

  Result := (FindComponent(ActName) = nil) and (ImgInd >= 1);
  if Result then
    CurDragObject := ActUDObject;
end; // function TK_FormCMCustToolbar.CheckActUDObject

procedure TK_FormCMCustToolbar.GetIniContext;
var
  i : Integer;
begin
  // Get Cur State from Ini File to StringLists
  for i := 0 to 3 do
    N_MemIniToStrings( ActListsIniPref + IntToStr(i), SLs[i] );

  // Get Small Buttons Flag from IniFile
  FSkipSmallButtonsClick := TRUE;
  ChBSmallButtons.Checked := N_MemIniToBool( 'CMS_Main', SmallButtonsIniPref,  FALSE );
  FSkipSmallButtonsClick := FALSE;
end; // procedure TK_FormCMCustToolbar.GetIniContext

procedure TK_FormCMCustToolbar.ExpandVTreeByUsedActions();
var
  UDFolder1 : TN_UDBase;
  UDFolder : TN_UDBase;
  i, j : Integer;
begin
  for i := 0 to High(SLs) do
  begin
    for j := 0 to SLs[i].Count - 1 do
    begin
      UDFolder := UDSRoot.DirChildByObjName( SLs[i][j] );
      if UDFolder = nil then Continue;
      while TRUE do
      begin
        if UDFolder.LastVNode <> nil then Break;
        UDFolder1 := UDFolder.Owner;
        while TRUE do
        begin
          if UDFolder1.Owner = nil then break;
          if UDFolder1.LastVNode <> nil then
          begin
            if UDFolder1.LastVNode.VNTreeNode.Expanded then break;
            UDFolder1.LastVNode.VNTreeNode.Expanded := TRUE;
          end;
          UDFolder1 := UDFolder1.Owner;
        end; // while TRUE do
      end; // while TRUE do
    end; // for j := 0 to SLs[i].Count - 1 do
  end; // for i := 0 to High(SLs) do
end; // procedure TK_FormCMCustToolbar.ExpandVTreeByUsedActions

//*********************************** TK_FormCMCustToolbar.CTBVTOnMouseDown ***
// TreeView OnMouseDown event handler customization routine
//
procedure TK_FormCMCustToolbar.CTBVTOnMouseDown( AVTreeFrame: TN_VTreeFrame;
  AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState );
begin
  if (AVNode = nil) or
     (AVNode.VNUDObj = nil) or
     (AVNode.VNUDObj.Marker = 0) or
     not (ssLeft in Shift) or
     (ssDouble in Shift) or
     (CurToolBar = nil) then
  begin
    CurActUDObject := nil;
    CurDragObject  := nil;
    DragTimer.Enabled := FALSE;
  end
  else
  begin
    CurActUDObject := AVNode.VNUDObj;
    DragTimer.Enabled := TRUE;
  end;
  CurActTBObject := nil;
end; // procedure TK_FormCMCustToolbar.CTBVTOnMouseDown

//*********************************** TK_FormCMCustToolbar.CTBVTOnMouseDown ***
// TreeView OnDoubleClick event handler customization routine
//
procedure TK_FormCMCustToolbar.CTBVTOnDoubleClickProcObj( AVTreeFrame: TN_VTreeFrame;
                AVNode: TN_VNode; Button: TMouseButton; Shift: TShiftState);
begin
//
  if (AVNode = nil) or
     (AVNode.VNUDObj = nil) or
     (AVNode.VNUDObj.Marker = 0) or
     (Shift <> [ssLeft,ssDouble])  then Exit;

  if CheckActUDObject( AVNode.VNUDObj ) and (CurToolBar <> nil) then
    TreeViewEndDrag( AVTreeFrame, CurToolBar, 0, 0 );
  CurDragObject := nil;
end; // procedure TK_FormCMCustToolbar.CTBVTOnDoubleClickProcObj

//*********************************** TK_FormCMCustToolbar.CurStateToMemIni ***
// Save Current Form State to MemIni
//
procedure TK_FormCMCustToolbar.CurStateToMemIni;
begin
  inherited;
  K_CMEDAccess.TmpStrings.Clear;
  VTreeFrame.VTree.GetExpandedPathStrings( K_CMEDAccess.TmpStrings );
  N_StringsToMemIni  ( 'CMCustToolbarTVState', K_CMEDAccess.TmpStrings );
end; // procedure TK_FormCMCustToolbar.CurStateToMemIni


end.
