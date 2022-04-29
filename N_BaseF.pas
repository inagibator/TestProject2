unit N_BaseF;
// Base Form class

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, Types,
  N_Types, N_Lib1, ExtCtrls;

//type TN_BFFlags = Set Of ( bffSkipBFResize );
// bffSkipBFResize - skip TN_BaseForm FormCanResize and FormResize handlers

type TN_BaseForm = class( TForm )
    BFMinBRPanel: TPanel;

    procedure FormClose     ( Sender: TObject; var Action: TCloseAction ); virtual;
    procedure BFFormCanResize ( Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean); virtual;
    procedure FormResize    ( Sender: TObject); virtual;
    procedure OwnWndProc    ( var Msg: TMessage );
    procedure FormDeactivate(Sender: TObject); virtual;
    procedure FormActivate(Sender: TObject); virtual;
    procedure FormCreate(Sender: TObject);

  public
    BFSelfOwnerForm:    TN_BaseForm; // Self Owner Form (set in BaseFormInit method)
    BFOwnedFormsCounter:    integer; // Number of Forms, owned by Self (whose Owner is Self)
    BFDisableActions: TN_ActListObj; // Actions to disabled in OnCloseForm handler
    BFOnCloseActions: TN_ActListObj; // Actions to process in OnCloseForm handler
    BFSelfName:        string;  // Name for saving Self Position in MemIni
    BFObjects:    TN_AObjects;  // any Objects for Self customizing
    BFVFlags: TN_FormVisFlags;  // Form Visual Flags
    BFFormMinSize:     TPoint;  // Form Minimal Size without ScrollBars
    BFFormSBWidths:    TPoint;  // Form's ScrollBars Widths
    BFFormMaxRect:      TRect;  // Form Max Rect
    BFSectionName:     string;  // Ini file Section Name where to store Form Size and position
    BFFlags:       TN_BFFlags;  // Form Init and Resize Flags
    BFFlags1: TN_RectSizePosFlags; // Form Init and Resize Flags for first showing (no coords in ini file)
    BFFlags2: TN_RectSizePosFlags; // Form Init and Resize Flags for not first showing (coords exists in ini file)
    BFDumpControl:   TControl;  // any TControl, which coords should be dumped
    BFIniPos:          TPoint;  // Form Initial Position in Pixels
    BFIniSize:         TPoint;  // Form Initial Size in Pixels (for 96 DPI)

    BFIsClosing:               Boolean; // Form is closing - skip activate|deactivate events after form is closed
    BFSkipDeactivateTOPMOST:   Boolean; // Window TOPMOST on Deactivate was already done - skip Window TOPMOST
    BFSkipActivateOnTOPMOST:   Boolean; // Window TOPMOST on Deactivate is doing now - skip OnActivate
    BFAppDeactivateWasChanged: Boolean; // Application OnDeactivate handler was already changed on form activation
    BFPrevDeactivate:     TNotifyEvent; // previouse Application Deactivate event handler
    procedure CurArchiveChanged  (); virtual;
    procedure CurStateToMemIni   (); virtual;
    procedure MemIniToCurState   (); virtual;
    procedure AddClearVarAction  ( APVar: Pointer;
                        ActionOwner: TN_BaseForm = nil; VarName: string = '' );
    procedure AddProcOfObjAction ( AProcObj: TN_ProcObj;
                        ActionOwner: TN_BaseForm = nil; ProcName: string = '' );
    procedure BFInitSelfFields  ();
    procedure BaseFormInit (); overload; // obsolete, should not be used!
    procedure BaseFormInit      ( AOwner: TN_BaseForm; ASelfName : string = '';
                                  AFVlags: TN_FormVisFlags = [] ); overload;
    procedure BaseFormInit      ( AOwner: TN_BaseForm; ASelfName : string;
                                    AFlags1, AFlags2: TN_RectSizePosFlags ); overload;
    procedure BFFixControlsCoords ();
    procedure BFSetSelfSizePos    ();
    procedure BFChangeSelfSize  ( ANeededSize: TPoint );
    procedure BFDumpStr         ( AStr: string );
    procedure BFDumpCoords      ( APrefix: string );
    function  BFAP              (): string;
    procedure CloseOwnedForms   ();
end; // type TN_BaseForm = class( TForm )
type TN_PBaseForm = ^TN_BaseForm;
type TN_BaseFormClass = class of TN_BaseForm;

const
  N_EnableAlignConst  = True;
  N_DisableAlignConst = False;

var
  N_BaseFormStayOnTop : Integer = 0; // All base forms Stay on Top Flag
                                     // 0 - no special action
                                     // 1 - set window TOPMOST on FormActivate only
                                     // 2 - set window TOPMOST on FormActivate and FormDeactivate
  N_BaseFormBorderIcons : TBorderIcons = [biSystemMenu, biMinimize, biMaximize];
implementation
uses
  math,
  K_CLib, K_CLib0,
  N_Lib0, N_Gra0, N_Gra1; //{, N_InfoF, N_Deb1, N_CMTstDelphiF};
{$R *.dfm}

//****************  TN_BaseForm class handlers  ******************

//*************************************************** TN_BaseForm.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - on input ans output, is set to caFree to destroy Self after closing
//
// OnClose Self handler
//
procedure TN_BaseForm.FormClose( Sender: TObject; var Action: TCloseAction );
var
  i, MaxI: integer;
  NEVar : TNotifyEvent;
  CurForm : TN_BaseForm;
  PrevForm : TN_BaseForm;
begin
  BFDumpStr( 'TN_BaseForm.FormClose Start' );
  BFIsClosing := TRUE; // Set Self closing flag to skip Activate|Deactivate events

////////////////////////////////////////////////
// Check if Application Deactivate Handler was
// replaced by Self.FormDeactivate
//
  if BFAppDeactivateWasChanged then
  begin
    NEVar := FormDeactivate;
    // if Application.Ondeactivate was replaced by BaseForm.FormDeactivate
    if TMethod(Application.OnDeactivate).Code = TMethod(NEVar).Code then
    begin
    // Seach Closing Form Position in opened BaseForms sequence
      PrevForm := nil;
      CurForm := TN_BaseForm(TMethod(Application.OnDeactivate).Data);
      while CurForm <> Self do
      begin
      // Step to next Form
        PrevForm := CurForm;
        CurForm := TN_BaseForm(TMethod(CurForm.BFPrevDeactivate).Data);
      end;

      // Form is found - remove Self.FormDeactivate reference from opened BaseForms sequence
      if PrevForm = nil then
      begin // Restore Application OnDeactivate
        Application.OnDeactivate := BFPrevDeactivate;
        N_Dump2Str( 'Application.OnDeactivate is restored from ' + BFSelfName );
      end
      else
      begin // Change Previous form BFPrevDeactivate
        PrevForm.BFPrevDeactivate := BFPrevDeactivate;
        N_Dump2Str( format( '%s.BFPrevDeactivate is changed from %s',
                             [PrevForm.BFSelfName,BFSelfName] ) );
      end;
    end; // if TMethod(NEVar1).Code = TMethod(NEVar2).Code then
  end; // if Assigned(BFPrevDeactivate) then
//
// Check if Application Deactivate Handler was
// replaced by Self.FormDeactivate
////////////////////////////////////////////////

  Action := caFree; // destroy Self after closing
  CurStateToMemIni();

  for i := 0 to High(BFObjects) do
    BFObjects[i].Free;

  FreeAndNil( BFObjects );

  if BFDisableActions <> nil then
  begin
    MaxI := BFDisableActions.Count-1;
    for i := 0 to MaxI do // disable all actions in BFDisableActions List
      with TN_BaseActionObj(BFDisableActions.Items[i]) do
      begin
//        N_s := ActName; // to see ActionName in debugger
        Enabled := False;
      end;

//    N_PCAdd( 7, 'BFDA: Form:' + Self.Name + ''#$0D#$0A + BFDisableActions.ALOToStr() ); // debug
    FreeAndNil( BFDisableActions );
  end; // if BFDisableActions <> nil then

//  N_s1 := Name;                  // debug
//  N_s2 := '';                    // debug
//  if BFSelfOwnerForm <> nil then   // debug
//    N_s2 := BFSelfOwnerForm.Name;  // debug

  N_ExecAndDestroy( BFOnCloseActions );

//  if BFSelfOwnerForm <> nil then   // debug
//    N_s2 := BFSelfOwnerForm.Name;  // debug

  Assert( (BFOwnedFormsCounter = 0), 'BFOwnedFormsCounter <> 0!' );
//  if BFOwnedFormsCounter <> 0 then  // debug
//    N_s := Name;                  // debug

  if BFSelfOwnerForm <> nil then
    Dec( BFSelfOwnerForm.BFOwnedFormsCounter );

  WindowProc := WndProc; // restore original handler if it was changed
  BFDumpStr( 'TN_BaseForm.FormClose Finish' );
end; // procedure TN_BaseForm.FormClose

//********************************************* TN_BaseForm.BFFormCanResize ***
// Now just dump self coords
//
//     Parameters
// Sender - Event Sender
//
//
// OnCanResize Self handler
//
procedure TN_BaseForm.BFFormCanResize( Sender: TObject; var NewWidth,
                                     NewHeight: Integer; var Resize: Boolean );
var
  Str: string;
begin
  Str := Format( 'BFOnCanResize: Params=%d %d %s, %s; ',
                                  [NewWidth,NewHeight,N_B2S(Resize), BFAP()] );
  BFDumpStr( Str );
//  BFDumpStr( Format( 'BFOnCanResize: %d, %d', [Self.Left, Self.Top] ) );

//  if BFDumpControl <> nil then
//    with BFDumpControl do
//      Str := Str + Format( 'DCTL=%d %d', [Left, Top] );

  N_i2 := Constraints.MinWidth;
end; // procedure TN_BaseForm.BFFormCanResize

//************************************************** TN_BaseForm.FormResize ***
// Now just dump self coords
//
//     Parameters
// Sender - Event Sender
//
//
// OnResize Self handler
//
procedure TN_BaseForm.FormResize( Sender: TObject );
var
  Str: string;
begin
  Str := 'BFOnResize: ' + BFAP();
//  N_Dump1Str( Str );

//  if BFDumpControl <> nil then
//    with BFDumpControl do
//      Str := Str + Format( ' DCTL=%d %d', [Left, Top] );

  N_i2 := Constraints.MinWidth;
  BFDumpStr( Str );
end; // procedure TN_BaseForm.FormResize

//************************************************** TN_BaseForm.OwnWndProc ***
// Own Window Proc that can be used instead of standart Self.WindowProc
//
//     Parameters
// Msg - Windows Message
//
// If OwnWndProc is assigned to Self.WindowProc, then standard WndProc
// will be called for all keys except Arrow and Tab
//
//#F
// Messages to skip (Arrow and Tab keys messages):
//     Msg    WParam
//  0000B02E 00000025  (25,26,27,28) Arrow Keys
//  0000B005 00000025  (25,26,27,28)
//
//  0000B02E 00000009  Tab Key
//  0000B005 00000009
//  0000B006 00000009
//#/F
//
procedure TN_BaseForm.OwnWndProc( var Msg: TMessage );
begin
  if (Msg.Msg and $00FF00) <> $00B000 then
    WndProc( Msg )
  else if ((Msg.WParam < $25) or (Msg.WParam > $28)) and (Msg.WParam <> $09) then
    WndProc( Msg );
end; // procedure TN_BaseForm.OwnWndProc


//****************  TN_BaseForm class public methods  ************

//******************************************* TN_BaseForm.CurArchiveChanged ***
// Should be called just after current Archive was changed
//
// Is empty in base class.
//
procedure TN_BaseForm.CurArchiveChanged();
begin
//
end; // procedure TN_BaseForm.CurArchiveChanged

//******************************************** TN_BaseForm.CurStateToMemIni ***
// Save Current Self Coords
//
procedure TN_BaseForm.CurStateToMemIni();
begin
  BFDumpStr( Format( 'Start BFCurStateToMemIni: Sec=%s, Self=%s, Capt=%s',
                                      [BFSectionName, BFSelfName, Caption] ) );

  N_ControlToMemIni( BFSectionName, BFSelfName, Self );
end; // end of procedure TN_BaseForm.CurStateToMemIni

//******************************************** TN_BaseForm.MemIniToCurState ***
// Load Self Size and Position from BFSectionName section, BFSelfName string
//
procedure TN_BaseForm.MemIniToCurState();
begin
  if N_NewBaseForm then // new variant, temporary
  begin
    if not Self.AlignDisabled then Exit; // Exit if in Align Enabled mode
    BFDumpStr( 'Start BFMemIniToCurState:' );
    BFSetSelfSizePos();
  end else // old variant, temporary
  begin
    // Try to set Self size and position from N_Forms section, BFSelfName string
    N_MemIniToControl( 'N_Forms', BFSelfName, Self );
    N_MakeFormVisible( Self, BFVFlags );
  end;
end; // end of procedure TN_BaseForm.MemIniToCurState

//******************************************* TN_BaseForm.AddClearVarAction ***
// Add "Clear given Variable" Action to needed lists
//
//     Parameters
// APVar       - given Pointer to some Variable, that shoud be cleared
//               in Self.CloseForm method
// ActionOwner - Owner of created ClearVar Action
// VarName     - Variable Name (mainly for viewing in debugger)
//
// New ClearVarAction is created and added to:
//#F
//   1) Self.BFOnCloseActions
//   2) ActionOwner.OwnedActions if ActionOwner <> nil
//#/F
//
procedure TN_BaseForm.AddClearVarAction( APVar: Pointer;
                                    ActionOwner: TN_BaseForm; VarName: string );
var
 ClearVarActObj: TN_ClearVarActObj;
begin
  if Self = nil then Exit;

  ClearVarActObj := TN_ClearVarActObj.Create( APVar );
  with ClearVarActObj do
    ActName := ActName + VarName;

  BFOnCloseActions.AddGivenAction( ClearVarActObj );

  if ActionOwner <> nil then
    ActionOwner.BFDisableActions.AddGivenAction( ClearVarActObj );
end; // end of procedure TN_BaseForm.AddClearVarAction

//****************************************** TN_BaseForm.AddProcOfObjAction ***
// Add "call Procedure Of Object" Action to needed lists
//
//     Parameters
// AProcObj    - given Procedure Of Object, that shoud be cleared
//               in Self.CloseForm method
// ActionOwner - Owner of created ClearVar Action
// AProcName   - Procedure Of Object Name (mainly for viewing in debugger)
//
// New ProcOfObjAction is created and added to:
//#F
//   1) Self.BFOnCloseActions
//   2) ActionOwner.OwnedActions if ActionOwner <> nil
//#/F
//
procedure TN_BaseForm.AddProcOfObjAction( AProcObj: TN_ProcObj;
                                   ActionOwner: TN_BaseForm; ProcName: string );
var
 ProcOfObjActObj: TN_ProcOfObjActObj;
begin
  if Self = nil then Exit;

  ProcOfObjActObj := TN_ProcOfObjActObj.Create( AProcObj );
  with ProcOfObjActObj do
    ActName := ActName + ProcName;

  BFOnCloseActions.AddGivenAction( ProcOfObjActObj );

  if ActionOwner <> nil then
    ActionOwner.BFDisableActions.AddGivenAction( ProcOfObjActObj );
end; // end of procedure TN_BaseForm.AddProcOfObjAction

//******************************************** TN_BaseForm.BFInitSelfFields ***
// Initialize Self Fileds if they are not already set
//
// Initialize the following self fields:
// BFSelfName,    BFVFlags,      BFFormMinSize, BFFormSBWidths,
// BFFormMaxRect, BFSectionName, BFFlags
//
procedure TN_BaseForm.BFInitSelfFields();
var
  MinDelta, MaxDelta, SavedRange, MinClientHeight, MinClientWidth: integer;
begin
  if Self = nil then Exit; // may be not needed

  // BFFlags field could be set before call to BFInitSelfFields();
  if BFFlags = [] then // Use Default value
    BFFlags := N_DefBFFlags;

  // BFFormMaxRect field could be set before call to BFInitSelfFields();
  if BFFormMaxRect.Right = 0 then // Use Default value
    BFFormMaxRect := N_AppWAR;

  // BFSectionName field could be set before call to BFInitSelfFields();
  if BFSectionName = '' then // Use Default value
    BFSectionName := 'N_Forms';

  // BFSelfName field could be set before call to BFInitSelfFields();
  if BFSelfName = '' then
    BFSelfName := Self.Name;

//  BFSelfName := 'aaCMTstDelphiF'; // temporary for debug


  //***** Calc BFFormMinSize for current Computer settings

  BFFlags := BFFlags + [bffSkipBFResize]; // skip code in OnResize and OnCanResize handlers (if any)

  DisableAlign(); // to avoid changing lower right corner anchored controls coords
                  // because of changing ScrollBars visibility


  with HorzScrollBar do // get Vertical additional Size (FormHeight-ClientHeight):
                        // MinDelta - without HorzScrollBar, Delta - with it
  begin
//    BFDumpStr( 'BFInitSelfFields 1 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    if IsScrollBarVisible() then // Horizontal ScrollBar is Visible
    begin
      MaxDelta := Height - ClientHeight;
//      BFDumpStr( 'BFInitSelfFields 2 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      Visible := False; // temporary hide Horizontal ScrollBar
//      BFDumpStr( 'BFInitSelfFields 3 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      MinDelta := Height - ClientHeight;
      Visible := True;  // restore
//      BFDumpStr( 'BFInitSelfFields 4 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    end else //******************** Horizontal ScrollBar is NOT Visible
    begin
      MinDelta := Height - ClientHeight;
      SavedRange := Range;
//      BFDumpStr( 'BFInitSelfFields 5 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      Range := ClientWidth + 1; // temporary increase Range to make Horizontal ScrollBar visible
//      BFDumpStr( 'BFInitSelfFields 6 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      MaxDelta := Height - ClientHeight;
      Range := SavedRange; // restore
//      BFDumpStr( 'BFInitSelfFields 7 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    end; // else // Horizontal ScrollBar is NOT Visible
  end; // with HorzScrollBar do // get Vertical additional Size

  MinClientHeight  := BFMinBRPanel.Top + BFMinBRPanel.Height;
  BFFormMinSize.Y  := MinClientHeight + MinDelta;
  BFFormSBWidths.Y := MaxDelta - MinDelta; // Horizontal ScrollBar Width
  BFDumpStr( Format( 'BFInitSelfFields 10 MinDeltaY=%d MaxDeltaY=%d (%d)', [MinDelta,MaxDelta,BFFormSBWidths.Y] ));

  with VertScrollBar do // get Horizontal additional Size (FormWidth-ClientWidth):
                        // MinDelta - without VertScrollBar, Delta - with it
  begin
    if IsScrollBarVisible() then // Vertical ScrollBar is Visible
    begin
      MaxDelta := Width - ClientWidth;
      Visible  := False; // temporary hide Vertical ScrollBar
      MinDelta := Width - ClientWidth;
      Visible  := True; // restore
    end else //******************** Vertical ScrollBar is NOT Visible
    begin
      MinDelta := Width - ClientWidth;
      SavedRange := Range;
      Range := ClientHeight + 1; // temporary increase Range to make Vertical ScrollBar visible
      MaxDelta := Width - ClientWidth;
      Range := SavedRange; // restore
    end; // else // Horizontal ScrollBar is NOT Visible
  end; // with VertScrollBar do // get Horizontal additional Size:

  MinClientWidth   := BFMinBRPanel.Left + BFMinBRPanel.Width;
  BFFormMinSize.X  := MinClientWidth + MinDelta;
  BFFormSBWidths.X := MaxDelta - MinDelta; // Vertical ScrollBar Width
  BFDumpStr( Format( 'BFInitSelfFields 11 MinDeltaX=%d MaxDeltaX=%d (%d)', [MinDelta,MaxDelta,BFFormSBWidths.X] ));

  BFFlags := BFFlags - [bffSkipBFResize]; // restore normal value

  if not N_NewBaseForm then // old variant, temporary
    EnableAlign(); // restore old variant normal value

end; // procedure TN_BaseForm.BFInitSelfFields

//********************************************* TN_BaseForm.BaseFormInit(0) ***
// Initialize Self as Base Form (without Params, obsolete, should not be used!)
//
procedure TN_BaseForm.BaseFormInit();
var
  MinDelta, MaxDelta, SavedRange, MinClientHeight, MinClientWidth: integer;
  RectExists: boolean;
  FormNeededSize: TPoint;
  FormNeededRect: TRect;
begin
//  BFSelfName := 'aaCMTstDelphiF'; // temporary for debug

  // BFFlags field could be set before call to BaseFormInit();
  if BFFlags = [] then // Use Default value
    BFFlags := N_DefBFFlags;

  // BFFormMaxRect field could be set before call to BaseFormInit();
  if BFFormMaxRect.Left = BFFormMaxRect.Right then // Use Default value
    BFFormMaxRect := N_AppWAR;

  // BFSectionName field could be set before call to BaseFormInit();
  if BFSectionName = '' then // Use Default value
    BFSectionName := 'N_Forms';


  //***** Calc BFFormMinSize for current Computer settings
  BFFlags := BFFlags + [bffSkipBFResize]; // skip code in OnResize and OnCanResize handlers

  DisableAlign(); // to avoid changing lower right corner anchored controls coords
                  // because of changing ScrollBars visibility


  with HorzScrollBar do // get Vertical additional Size (FormHeight-ClientHeight):
                        // MinDelta - without HorzScrollBar, Delta - with it
  begin
//BFDumpStr( 'BFInitSelfFields 1 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    if IsScrollBarVisible() then // Horizontal ScrollBar is Visible
//    if HorzScrollBar.Visible then // Horizontal ScrollBar is Visible
    begin
      MaxDelta := Height - ClientHeight;
//BFDumpStr( 'BFInitSelfFields 2 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      Visible := False; // temporary hide Horizontal ScrollBar
    BFDumpStr( 'BFInitSelfFields 3 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      MinDelta := Height - ClientHeight;
      Visible := True;  // restore
    BFDumpStr( 'BFInitSelfFields 4 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    end else //******************** Horizontal ScrollBar is NOT Visible
    begin
      MinDelta := Height - ClientHeight;
      SavedRange := Range;
    BFDumpStr( 'BFInitSelfFields 5 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      Range := ClientWidth + 1; // temporary increase Range to make Horizontal ScrollBar visible
    BFDumpStr( 'BFInitSelfFields 6 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
      MaxDelta := Height - ClientHeight;
      Range := SavedRange; // restore
    BFDumpStr( 'BFInitSelfFields 7 ' + N_B2S(IsScrollBarVisible()) + N_B2S(Visible) );
    end; // else // Horizontal ScrollBar is NOT Visible
  end; // with HorzScrollBar do // get Vertical additional Size

  MinClientHeight  := BFMinBRPanel.Top + BFMinBRPanel.Height;
  BFFormMinSize.Y  := MinClientHeight + MinDelta;
  BFFormSBWidths.Y := MaxDelta - MinDelta;
    BFDumpStr( Format( 'BFInitSelfFields 10 MinDeltaY=%d MaxDeltaY=%d (%d)', [MinDelta,MaxDelta,BFFormSBWidths.Y] ));

  with VertScrollBar do // get Horizontal additional Size (FormWidth-ClientWidth):
                        // MinDelta - without VertScrollBar, Delta - with it
  begin
    if IsScrollBarVisible() then // Vertical ScrollBar is Visible
    begin
      MaxDelta := Width - ClientWidth;
      Visible  := False; // temporary hide Vertical ScrollBar
      MinDelta := Width - ClientWidth;
      Visible  := True; // restore
    end else //******************** Vertical ScrollBar is NOT Visible
    begin
      MinDelta := Width - ClientWidth;
      SavedRange := Range;
      Range := ClientHeight + 1; // temporary increase Range to make Vertical ScrollBar visible
      MaxDelta := Width - ClientWidth;
      Range := SavedRange; // restore
    end; // else // Horizontal ScrollBar is NOT Visible
  end; // with VertScrollBar do // get Horizontal additional Size:

  MinClientWidth   := BFMinBRPanel.Left + BFMinBRPanel.Width;
  BFFormMinSize.X  := MinClientWidth + MinDelta;
  BFFormSBWidths.X := MaxDelta - MinDelta;
    BFDumpStr( Format( 'BFInitSelfFields 11 MinDeltaX=%d MaxDeltaX=%d (%d)', [MinDelta,MaxDelta,BFFormSBWidths.X] ));

  Exit; // temp for debug

  //***** Here: BFFormMinSize is OK, calc FormNeededRect

  RectExists := N_MemIniToRect( BFSectionName, '1'+BFSelfName, FormNeededRect );

  if not RectExists then // Form Pos and Size were not saved to Ini file before
    FormNeededRect := N_RectMake( N_RectCenter( BFFormMaxRect ), BFFormMinSize,
                                                           DPoint( 0.5, 0.5 ) );
  // FormNeededRect could be saved at different FontSize and ScreenSize.
  // Adjust retrieved FormNeededRect if needed

  FormNeededRect := N_RectAdjustByMaxRect( FormNeededRect, BFFormMaxRect );
  FormNeededSize.X := N_RectWidth( FormNeededRect );
  FormNeededSize.Y := N_RectHeight( FormNeededRect );

  //*** Here: BFFormMinSize and FormNeededRect are OK, change Self Size

  BFChangeSelfSize( FormNeededSize );
  BFFlags := BFFlags - [bffSkipBFResize];

end; // procedure TN_BaseForm.BaseFormInit(0)

//***************************************** TN_BaseForm.BaseFormInit(1Flag) ***
// Initialize Self as Base Form (with one Flag param)
//
//     Parameters
// AOwner    - given BaseForm, that is Owner of Self
// ASelfName -
// AFVlags   -
//
procedure TN_BaseForm.BaseFormInit( AOwner: TN_BaseForm;
                                    ASelfName : string = '';
                                    AFVlags: TN_FormVisFlags = [] );
var
  ProcOfObjActObj: TN_ProcOfObjActObj;
  CloseFormActObj: TN_CloseFormActObj;
begin
  if Self = nil then Exit;

  if ASelfName <> '' then BFSelfName := ASelfName;
  BFVFlags := AFVlags;

  if N_NewBaseForm then // new variant, temporary
  begin
    BFInitSelfFields();
  end else // old variant, temporary
  begin
    if BFSelfName = '' then BFSelfName := Self.Name;
  end;

  BFDumpStr( Format( 'Start BaseFormInit 1Flag (SN=%s):', [BFSelfName] ));

  BFDisableActions := TN_ActListObj.Create; // Actions to disabled in OnCloseForm handler
  BFOnCloseActions := TN_ActListObj.Create; // Actions to process in OnCloseForm handler
  MemIniToCurState(); // set Self fields from Ini file

  // enable saving Self state to Ini file at any time in N_SaveCurStateToMemIni() procedure
  ProcOfObjActObj := TN_ProcOfObjActObj.Create( CurStateToMemIni );
  ProcOfObjActObj.ActName := 'CurStateToMemIni: ' + Name + ', ' + Caption;
  BFDisableActions.AddGivenAction( ProcOfObjActObj );
  N_SaveAllToMemIni.AddGivenAction( ProcOfObjActObj );
//  BFDumpStr( 'From BFInit, Form:' + Self.Name + ' ProcOfObjActObj.ActToStr=' + ProcOfObjActObj.ActToStr );

  // enable processing Self.CurArchiveChanged method each time when Archive changed
  ProcOfObjActObj := TN_ProcOfObjActObj.Create( CurArchiveChanged );
  ProcOfObjActObj.ActName := 'CurArchiveChanged';
  BFDisableActions.AddGivenAction( ProcOfObjActObj );
  N_CurArchChanged.AddGivenAction( ProcOfObjActObj );

  // enable closing Self in AOwner OnClose handler
  if AOwner <> nil then
  begin
    CloseFormActObj := TN_CloseFormActObj.Create( Self );
    BFDisableActions.AddGivenAction( CloseFormActObj );
    AOwner.BFOnCloseActions.AddGivenAction( CloseFormActObj );
    BFSelfOwnerForm := AOwner;
    Inc(AOwner.BFOwnedFormsCounter);
  end;

end; // end of procedure TN_BaseForm.BaseFormInit(1Flag)

//**************************************** TN_BaseForm.BaseFormInit(2Flags) ***
// Initialize Self as Base Form (with two Flags params)
//
//     Parameters
// AOwner    - given BaseForm, that is Owner of Self
// ASelfName -
// AFlags1   -
// AFlags2   -
//
procedure TN_BaseForm.BaseFormInit( AOwner: TN_BaseForm;
                                    ASelfName : string;
                                    AFlags1, AFlags2: TN_RectSizePosFlags );
var
  ProcOfObjActObj: TN_ProcOfObjActObj;
  CloseFormActObj: TN_CloseFormActObj;
begin
  BFDumpStr( 'Start BaseFormInit 2Flags');
  if Self = nil then Exit;
  K_SetFFCompCurLangTexts( Self ); // Replace Control's Captions from Language file
  DefaultMonitor := dmDesktop;

  if ASelfName <> '' then BFSelfName := ASelfName;
  BFFlags1 := AFlags1;
  BFFlags2 := AFlags2;

  BFInitSelfFields();

  BFDumpStr( Format( 'BaseFormInit: Self Name=%s', [BFSelfName] ));

  BFDisableActions := TN_ActListObj.Create; // Actions to disabled in OnCloseForm handler
  BFOnCloseActions := TN_ActListObj.Create; // Actions to process in OnCloseForm handler

  BFDumpStr( 'BaseFormInit: Before MemIniToCurState'); // debug for Soredex Form
  MemIniToCurState(); // set Self fields from Ini file
  BFDumpStr( 'BaseFormInit: After MemIniToCurState');  // debug for Soredex Form

  // enable saving Self state to Ini file at any time in N_SaveCurStateToMemIni() procedure
  ProcOfObjActObj := TN_ProcOfObjActObj.Create( CurStateToMemIni );
  ProcOfObjActObj.ActName := 'CurStateToMemIni: ' + Name + ', ' + Caption;
  BFDisableActions.AddGivenAction( ProcOfObjActObj );
  N_SaveAllToMemIni.AddGivenAction( ProcOfObjActObj );
  BFDumpStr( 'From BFInit, Form:' + Self.Name + ' ProcOfObjActObj.ActToStr=' + ProcOfObjActObj.ActToStr );

  // enable processing Self.CurArchiveChanged method each time when Archive changed
  ProcOfObjActObj := TN_ProcOfObjActObj.Create( CurArchiveChanged );
  ProcOfObjActObj.ActName := 'CurArchiveChanged';
  BFDisableActions.AddGivenAction( ProcOfObjActObj );
  N_CurArchChanged.AddGivenAction( ProcOfObjActObj );

  // enable closing Self in AOwner OnClose handler
  if AOwner <> nil then
  begin
    CloseFormActObj := TN_CloseFormActObj.Create( Self );
    BFDisableActions.AddGivenAction( CloseFormActObj );
    AOwner.BFOnCloseActions.AddGivenAction( CloseFormActObj );
    BFSelfOwnerForm := AOwner;
    Inc(AOwner.BFOwnedFormsCounter);
  end;

end; // end of procedure TN_BaseForm.BaseFormInit(2Flags)

//***************************************** TN_BaseForm.BFFixControlsCoords ***
// Fix TopLeft coords of BottmRight aligned controls
//
procedure TN_BaseForm.BFFixControlsCoords();
var
  i: integer;
  FName: string;
begin
  if (bffToDump1 in BFFlags) or N_OtherDevices then
    N_Dump1Str( 'Start BFFixControlsCoords NumComps=' + IntToStr(ComponentCount) );

  try //***** is used to check if Exception will occure inside loop
      //      caused by Win API SetWindowPos function

  for i := 0 to ComponentCount-1 do // along all Components
  begin
//    if i = 1 then N_d := N_d1 / 0.0; // to debug exception

    if Components[i] = nil then Continue;
    if not( Components[i] is TControl) then Continue; // Skip

    with TControl(Components[i]) do
    begin
      if bffToDump1 in BFFlags then
        N_Dump1Str( Format( 'CompInd=%d, Name=%s, Anchors=%x', [i,Name,Byte(Anchors)] ) );

      if akRight in Anchors then // Control is changing while Form Resize along X
      begin
        if akLeft in Anchors then // fix Control's Width (Left remains the same)
        begin
          Width := Width + 1;
          Width := Width - 1;
        end else //***************** fix Control's Left (Width remains the same)
        begin
          Left := Left + 1;
          Left := Left - 1;
        end;
      end; // if akRight in Anchors then // Control is changing while Form Resize along X

      if akBottom in Anchors then // Control is changing while Form Resize along Y
      begin
        if akTop in Anchors then // fix Control's Height (Top remains the same)
        begin
          Height := Height + 1;
          Height := Height - 1;
        end else //***************** fix Control's Top (Height remains the same)
        begin
          Top := Top + 1;
          Top := Top - 1;
        end;
      end; // if akBottom in Anchors then // Control is changing while Form Resize along Y

    end; // with TControl(Components[i]) do
  end; // for i := 0 to ComponentCount-1 do // along all Components

  except // try //***** is used to check if Exception will occure inside loop
    on E: Exception do
    begin
      N_Dump1Str( '*** Win API SetWindowPos function error occured!' );
      FName := K_ExpandFileName( '(##Exe#)' + '!SetWindowPosErrorOccured.txt' );
      N_WriteTextFile ( FName, 'Error flag' );

      raise E.Create( E.Message );
    end; // on E: Exception do
  end; // except // try //***** is used to check if Exception will occure inside loop

  if (bffToDump1 in BFFlags) or N_OtherDevices then
    N_Dump1Str( 'Finish BFFixControlsCoords NumComps=' + IntToStr(ComponentCount) );
end; // procedure TN_BaseForm.BFFixControlsCoords

//******************************************** TN_BaseForm.BFSetSelfSizePos ***
// Set Self Size and Position after Creation (considering info in MemIni)
//
// The following Self fields are used and should be OK:
// BFVFlags, BFSectionName, BFSelfName, BFFormMinSize, BFFormMaxRect.
// Also [BFSectionName].BFSelfName variable in MemIni is used
//
// Usually is called from TN_BaseForm.MemIniToCurState();
//
procedure TN_BaseForm.BFSetSelfSizePos();
var
  InpSize, InpPos, NeededTopLeft, NeededSize: TPoint;
  EnvRect, WrkRect: TRect;

  procedure DumpPosition( APrefix: string ); // local
  begin
    if not (bffDumpPos in BFFlags) then Exit;

    N_Dump1Str( Format( '%s InpSize=%d,%d InpPos=%d,%d NeededSize=%d,%d NeededTopLeft=%d,%d TopLeft=%d,%d WidthHeight=%d,%d    ',
                       [APrefix, InpSize.X, InpSize.Y, InpPos.X, InpPos.Y,
                                 NeededSize.X, NeededSize.Y, NeededTopLeft.X, NeededTopLeft.Y,
                                 Left, Top, Width, Height] ) );
  end; // procedure DumpPosition(); // local

begin
  BFDumpStr( 'Start BFSetSelfSizePos:' );

  //***** Set NeededTopLeft, NeededSize for ini file or from Self BFIniSize, BFIniPos fields

  if N_MemIniToRect2( BFSectionName, BFSelfName, InpPos, InpSize ) then // coords exists
  begin
    N_CalcRectSizePos( InpSize, InpPos, BFFlags2, NeededSize, NeededTopLeft );
    DumpPosition( 'From ini:' );
  end else // no BFSelfName variable in BFSectionName Section of ini file
  begin
    InpSize := BFIniSize;
    if InpSize.X = 0 then InpSize.X := BFFormMinSize.X;
    if InpSize.Y = 0 then InpSize.Y := BFFormMinSize.Y;

    InpPos  := BFIniPos;
    N_CalcRectSizePos( InpSize, InpPos, BFFlags1, NeededSize, NeededTopLeft );
    DumpPosition( 'Initial:' );
  end; // else (no coords in ini file)

  //***** Set proper NeededSize if not yet

  if (NeededSize.X = N_NotAnInteger) or (NeededSize.X <= 0) then
    NeededSize.X := BFFormMinSize.X;

  if (NeededSize.Y = N_NotAnInteger) or (NeededSize.Y <= 0) then
    NeededSize.Y := BFFormMinSize.Y;

  if not ((BorderStyle = bsSizeable) or (BorderStyle = bsSizeToolWin)) then // not Resizeable
    NeededSize := BFFormMinSize;

  BFChangeSelfSize( NeededSize ); // NeededSize could be corrected in BFChangeSelfSize

  //***** Self Size was set, Set Self Position

  if Left <> NeededTopLeft.X then Left := NeededTopLeft.X;
  if Top  <> NeededTopLeft.Y then Top  := NeededTopLeft.Y;

  DumpPosition( 'Final:' );
  BFDumpStr( 'Finish BFSetSelfSizePos' );

  Exit;


  // Cacl WrkRect in the middle of BFFormMaxRect
  WrkRect := N_RectSetPos( 4, BFFormMaxRect, N_ZIRect, Width, Height );

  if NeededTopLeft.X = N_NotAnInteger then // not given in MemIni
    NeededTopLeft.X := WrkRect.Left;

  if NeededTopLeft.Y = N_NotAnInteger then // not given in MemIni
    NeededTopLeft.Y := WrkRect.Top;

  if fvfCenter in BFVFlags then // should be in the middle of BFFormMaxRect
    NeededTopLeft := WrkRect.TopLeft;

  // Make Self visible in BFFormMaxRect

  EnvRect := BFFormMaxRect;

  //***** if not fvfWhole Form can be only partially visible,
  //      but it can never be higher then Top border

  if not (fvfWhole in BFVFlags) then // Form can be only partially (at least 100 pixels) visible
  begin
    // Form should never be vivsible on some other monitor of of BFFormMaxRect
    if EnvRect.Left   = N_WholeWAR.Left   then EnvRect.Left   := EnvRect.Left   - (Width-100);
//    if EnvRect.Top    = N_WholeWAR.Top    then EnvRect.Top    := EnvRect.Top    - (Height-100);
    if EnvRect.Right  = N_WholeWAR.Right  then EnvRect.Right  := EnvRect.Right  + (Width-100);
    if EnvRect.Bottom = N_WholeWAR.Bottom then EnvRect.Bottom := EnvRect.Bottom + (Height-100);
  end; // if not (fvfWhole in BFVFlags) then // Form can be only partially (at least 100 pixels) visible

  WrkRect := N_RectMake( NeededTopLeft, Width, Height );
  WrkRect := N_RectAdjustByMaxRect( WrkRect, EnvRect );

  if Left <> WrkRect.Left then Left := WrkRect.Left;
  if Top  <> WrkRect.Top  then Top  := WrkRect.Top;

  BFDumpStr( 'Finish BFSetSelfSizePos Old' );
end; // procedure TN_BaseForm.BFSetSelfSizePos

//******************************************** TN_BaseForm.BFChangeSelfSize ***
// Change Self Size
//
// BFFormMinSize, BFFormMaxRect and BFFormSBWidths should be OK
//
procedure TN_BaseForm.BFChangeSelfSize( ANeededSize: TPoint );
var
  NewWidth1, NewWidth2, NewHeight1, NewHeight2: integer;
  Str: string;
  FormMaxSize: TPoint;
  EnableAlignX, EnableAlignY: boolean;

  procedure DumCoords2( APrefix: string ); // local
  // just dump some coords using BFDumpStr
  begin
    Str := Format( '  %s %s,', [APrefix, BFAP()] );

//    if BFDumpControl <> nil then
//      with BFDumpControl do
//        Str := Str + Format( ' DCTL=%d %d', [Left, Top] );

    BFDumpStr( Str );
  end; // procedure DumCoords2(); // local

  procedure LowLevelSetSize( AEnableAlign: boolean; ASizeX, ASizeY: integer ); // local
  // Set Align mode and Self Size if not already
  // Note that Windows, sometimes, set it's own size instead of given!
  // e.g. assignment Main5Form.Heigth:=400 results in Main5Form.Heigth=583 for unknown reasons!
  begin
    if (ASizeX <= 0) and (ASizeY <= 0) then Exit; // nothing todo

    //*** Set Align mode if needed
    if Self.AlignDisabled then // now in AlignDisabled mode
    begin
      if AEnableAlign then EnableAlign();
    end else // Self.AlignDisabled = False, now in AlignEnabled mode
    begin
      if not AEnableAlign then DisableAlign();
    end;

    //*** Set Size if needed, sometimes not works! (see comments above)
    if (ASizeX > 0) and (Self.Width  <> ASizeX) then Self.Width  := ASizeX;
    if (ASizeY > 0) and (Self.Height <> ASizeY) then Self.Height := ASizeY;
  end; // procedure LowLevelSetSize

begin //***************************** main body of TN_BaseForm.BFChangeSelfSize
  BFDumpStr( Format( 'Start BFChangeSelfSize to (%d,%d):', [ANeededSize.X,ANeededSize.Y] ));

  //***** Check which mode should be used - Enable or Disable Align

  //***** Set  NeededSize <= BFFormMaxSize
  FormMaxSize := N_RectSize( BFFormMaxRect );
  ANeededSize.X := min( ANeededSize.X, FormMaxSize.X );
  ANeededSize.Y := min( ANeededSize.Y, FormMaxSize.Y );

  DumCoords2( '*** 1 ***' );

  if (BFFormMinSize.X <= FormMaxSize.X) and (BFFormMinSize.Y <= FormMaxSize.Y) then
  begin // Form Size can be set to MinSize, because it is <= FormMaxSize.
        // Set first Form Size to MinSize, than Enable Align and increase it to NeededSize.
        // (NeededSize is changed so that MinSize <= NeededSize <= MaxSize )
        // Form Remains in Enable Align mode after return
        // and can be scaled in (MinSize,MaxSize) interval
    LowLevelSetSize( N_DisableAlignConst, BFFormMinSize.X, BFFormMinSize.Y );
    DumCoords2( '2a' );

    VertScrollBar.Visible := False;
    HorzScrollBar.Visible := False;
    DumCoords2( '3a' );

    BFFixControlsCoords();
    DumCoords2( '4a' );
    EnableAlign();
    DumCoords2( '5a' );

    //***** Set  NeededSize >= BFFormMinSize
    ANeededSize.X := max( ANeededSize.X, BFFormMinSize.X );
    ANeededSize.Y := max( ANeededSize.Y, BFFormMinSize.Y );
    // Here: MinSize <= NeededSize <= MaxSize
    LowLevelSetSize( N_EnableAlignConst, ANeededSize.X, ANeededSize.Y );
    DumCoords2( '6a' );

    Constraints.MinWidth  := BFFormMinSize.X;
    Constraints.MinHeight := BFFormMinSize.Y;
    DumCoords2( 'Finish1 BFChangeSelfSize' );
  end else // Some Form Size (X or Y) cannot be set to MinSize, because it is > FormMaxSize
  begin    // Three cases should be considered:
           //   1) (BFFormMinSize.X >  FormMaxSize.X) and (BFFormMinSize.Y >  FormMaxSize.Y)
           //   2) (BFFormMinSize.X >  FormMaxSize.X) and (BFFormMinSize.Y <= FormMaxSize.Y)
           //   3) (BFFormMinSize.X <= FormMaxSize.X) and (BFFormMinSize.Y >  FormMaxSize.Y)

    if (BFFormMinSize.X > FormMaxSize.X) and (BFFormMinSize.Y > FormMaxSize.Y) then // Case 1)
    begin // Form is only partialy visible along both X and Y.
          // (roughly speaking - Big Form on Small Monitor)
          // Set Disable Align mode and set any NeededSize
          // (NeededSize here is always < BFFormMaxSize)
          // Form can be resized (in Disable Align mode) in (0,MaxSize) interval
      LowLevelSetSize( N_DisableAlignConst, ANeededSize.X, ANeededSize.Y );
      DumCoords2( 'Case 1) - 1' );

      // Set Form Canvas size to Form MinSize
      HorzScrollBar.Range := BFMinBRPanel.Left + BFMinBRPanel.Width;
      VertScrollBar.Range := BFMinBRPanel.Top  + BFMinBRPanel.Height;
    end; // if (BFFormMinSize.X > FormMaxSize.X) and (BFFormMinSize.Y > FormMaxSize.Y) then // Case 1)

    if (BFFormMinSize.X > FormMaxSize.X) and (BFFormMinSize.Y <= FormMaxSize.Y) then // Case 2)
    begin // Form is only partialy visible along X and is fully visible along Y.
          // (roughly speaking - Landscape Form on Portrait Monitor)

      // First set Disable Align mode and set Form Size to (ANeededSize.X, BFFormMinSize.Y)
      // Here: ANeededSize.X < BFFormMinSize.X and BFFormMinSize.Y <= FormMaxSize.Y

      LowLevelSetSize( N_DisableAlignConst, ANeededSize.X, BFFormMinSize.Y );
      DumCoords2( 'Case 2) - 2' );

      // Set Form Canvas size to Form MinSize
      HorzScrollBar.Range := BFMinBRPanel.Left + BFMinBRPanel.Width;
      VertScrollBar.Range := BFMinBRPanel.Top  + BFMinBRPanel.Height;
      DumCoords2( 'Case 2) - 3' );

      // Increase Form Height in Align mode
      BFFixControlsCoords(); // fix coords before call to EnableAlign
      EnableAlign(); // note, that EnableAlign increase Form Width by BFFormSBWidths.X!
      Height := max( ANeededSize.Y, BFFormMinSize.Y ); // Set needed Form Height
      Width  := Width - BFFormSBWidths.X; // compensate Form Width increase caused by EnableAlign
      DisableAlign(); // Form will be visible in Disable Align mode
      VertScrollBar.Range := BFMinBRPanel.Top  + BFMinBRPanel.Height; // Set needed Form Canvas Height
    end; // if (BFFormMinSize.X > FormMaxSize.X) and (BFFormMinSize.Y <= FormMaxSize.Y) then // Case 2)

    if (BFFormMinSize.X <= FormMaxSize.X) and (BFFormMinSize.Y > FormMaxSize.Y) then // Case 3)
    begin // Form is only partialy visible along Y and is fully visible along X.
          // (roughly speaking - Portrait Form on Landscape Monitor)

      // First set Disable Align mode and set Form Size to (BFFormMinSize.X, ANeededSize.Y)
      // Here: ANeededSize.Y < BFFormMinSize.Y and BFFormMinSize.X <= FormMaxSize.X
      LowLevelSetSize( N_DisableAlignConst, BFFormMinSize.X, ANeededSize.Y );
      DumCoords2( 'Case 3) - 2' );

      // Set Form Canvas size to Form MinSize
      HorzScrollBar.Range := BFMinBRPanel.Left + BFMinBRPanel.Width;
      VertScrollBar.Range := BFMinBRPanel.Top  + BFMinBRPanel.Height;
      DumCoords2( 'Case 2) - 3' );

      // Increase Form Width in Align mode
      BFFixControlsCoords(); // fix coords before call to EnableAlign
      EnableAlign(); // note, that EnableAlign increase Form Height by BFFormSBWidths.Y!
      Width  := max( ANeededSize.X, BFFormMinSize.X ); // Set needed Form Width
      Height := Height - BFFormSBWidths.Y; // compensate Form Height increase caused by EnableAlign
      DisableAlign(); // Form will be visible in Disable Align mode
      HorzScrollBar.Range := BFMinBRPanel.Left + BFMinBRPanel.Width;
    end; // if (BFFormMinSize.X <= FormMaxSize.X) and (BFFormMinSize.Y > FormMaxSize.Y) then // Case 3)

    DumCoords2( 'Finish2 BFChangeSelfSize' );
  end; // else - Some Form Size (X or Y) cannot be set to MinSize, because it is > FormMaxSize

  Exit;

  //*** Below are two portions of old code, probably not needed

  // portion 1 Old code, now assignment "ScrollBar.Visible := False;" is used:
    //***** Create One Pixel Visible Panel in Lower Right Corner of BFMinBRPanel
    //      otherwise Scrollbars will not appear
{
    BRPanel := TPanel.Create( Self );
    with BRPanel do
    begin
      Parent := Self;
      BevelOuter := bvNone;
      Caption := ''; // possibly to diminish flicker, may be not needed
      Color := Self.Color;
      Left   := BFMinBRPanel.Left + BFMinBRPanel.Width  - 1;
      Top    := BFMinBRPanel.Top  + BFMinBRPanel.Height - 1;
      Width  := 1;
      Height := 1;
    end; // with BRPanel do
}

  // portion 2 Old code:
  //*** Size Changes wil be made by one or two Steps along X and Y
  //    If (CurSize < NeededSize) all changes should be in DisableAlign mode
  //    If (CurSize > NeededSize) all changes should be in EnableAlign mode
  //    EnableAlign(X,Y)=True means that Step1 should be made in EnableAlign mode
  //    Align mode in Step2 should be always Not AlignMode in Step1


  //*** Calc needed Horizontal changes:
  //    EnableAlignX - Align Mode for Step1 (for Step2 - NOT EnableAlignX)
  //    NewWidth1, NewWidth2 - final Widths after Step1 and Step2

  if Self.Width < BFFormMinSize.X then
  begin
    EnableAlignX := False;

    if ANeededSize.X <= BFFormMinSize.X then // one Step along X is needed
    begin
      NewWidth1 := ANeededSize.X;
      NewWidth2 := 0; // "Step2 is not needed" flag
    end else //******************************** two Steps along X are needed
    begin
      NewWidth1 := BFFormMinSize.X;
      NewWidth2 := ANeededSize.X;
    end;
  end else if Self.Width > BFFormMinSize.X then
  begin
    EnableAlignX := True;

    if ANeededSize.X >= BFFormMinSize.X then // one Step along X is needed
    begin
      NewWidth1 := ANeededSize.X;
      NewWidth2 := 0; // "Step2 is not needed" flag
    end else //******************************** two Steps along X are needed
    begin
      NewWidth1 := BFFormMinSize.X;
      NewWidth2 := ANeededSize.X;
    end;
  end else // Self.Width = BFFormMinSize.X, one Step along X is needed
  begin
    if ANeededSize.X >= Self.Width then // Increase in Enable Align mode
      EnableAlignX := True
    else // ANeededSize.X < Self.Width, Decrease in Disable Align mode
      EnableAlignX := False;

    NewWidth1 := ANeededSize.X;
    NewWidth2 := 0; // "Step2 is not needed" flag
  end; // else // Self.Width = BFFormMinSize.X


  //*** Calc needed Vertical changes:
  //    EnableAlignY - Align Mode for Step1 (for Step2 - NOT EnableAlignY)
  //    NewHeight1, NewHeight2 - final Heights after Step1 and Step2

  if Self.Height < BFFormMinSize.Y then
  begin
    EnableAlignY := False;

    if ANeededSize.Y <= BFFormMinSize.Y then // one Step along Y is needed
    begin
      NewHeight1 := ANeededSize.Y;
      NewHeight2 := 0; // "Step2 is not needed" flag
    end else //******************************** two Steps along Y are needed
    begin
      NewHeight1 := BFFormMinSize.Y;
      NewHeight2 := ANeededSize.Y;
    end;
  end else if Self.Height > BFFormMinSize.Y then
  begin
    EnableAlignY := True;

    if ANeededSize.Y >= BFFormMinSize.Y then // one Step along Y is needed
    begin
      NewHeight1 := ANeededSize.Y;
      NewHeight2 := 0; // "Step2 is not needed" flag
    end else //******************************** two Steps along Y are needed
    begin
      NewHeight1 := BFFormMinSize.Y;
      NewHeight2 := ANeededSize.Y;
    end;
  end else // Self.Height = BFFormMinSize.Y, one Step along Y is needed
  begin
    if ANeededSize.Y >= Self.Height then // Increase in Enable Align mode
      EnableAlignY := True
    else // ANeededSize.Y < Self.Height, Decrease in Disable Align mode
      EnableAlignY := False;

    NewHeight1 := ANeededSize.Y;
    NewHeight2 := 0; // "Step2 is not needed" flag
  end; // else // Self.Height = BFFormMinSize.Y


  //***** Make calculated X,Y changes using
  //      EnableAlignX, NewWidth1,  NewWidth2
  //      EnableAlignY, NewHeight1, NewHeight2

  DumCoords2( '1' );

  if (EnableAlignX = EnableAlignY) then // same Align mode for X and Y changes
  begin
    LowLevelSetSize( EnableAlignX, NewWidth1, NewHeight1 ); // set NewWidth1, NewHeight1
    DumCoords2( '2' );
    LowLevelSetSize( not EnableAlignX, NewWidth2, NewHeight2 ); // set NewWidth2, NewHeight2
    DumCoords2( '3' );
  end else // (EnableAlignX <> EnableAlignY), different Align mode for X and Y changes
  begin
    LowLevelSetSize( EnableAlignX, NewWidth1, Self.Height ); // set NewWidth1 only
    DumCoords2( '4' );
    LowLevelSetSize( not EnableAlignX, NewWidth2, NewHeight1 ); // set NewWidth2, NewHeight1
    DumCoords2( '5' );
    LowLevelSetSize( EnableAlignX, 0, NewHeight2 );; // set NewHeight2 only
    DumCoords2( '6' );
  end; // else // (EnableAlignX <> EnableAlignY), different Align mode for X and Y changes

//  EnableAlign(); // debug!!!
//  HorzScrollBar.Range := ClientWidth;
//  VertScrollBar.Range := ClientHeight;


  //***** Set final Align mode (for future Form Resize)

  if (Self.Width  < BFFormMinSize.X) or
     (Self.Height < BFFormMinSize.Y)    then DisableAlign()
                                        else EnableAlign();

  HorzScrollBar.Range := ClientWidth;
  VertScrollBar.Range := ClientHeight;

end; // procedure TN_BaseForm.BFChangeSelfSize

//*************************************************** TN_BaseForm.BFDumpStr ***
// Low level Dump string
//
//     Parameters
// AStr - given string to dump
//
// Dump given AStr to Dump1 or to Dump2 depending upon BFFlags
//
procedure TN_BaseForm.BFDumpStr( AStr: string );
begin
  if bffToDump1 in BFFlags then N_Dump1Str( AStr );
  if bffToDump2 in BFFlags then N_Dump2Str( AStr );
end; // procedure TN_BaseForm.BFDumpStr

//************************************************ TN_BaseForm.BFDumpCoords ***
// Dump several coords (for debug only)
//
//     Parameters
// APrefix - given prefix - prefix before dumped strings
//
// Example: APrefix: A=T SB=(0,0 F,F) FS=(501,789 495,750) MS=(491,750)
//
procedure TN_BaseForm.BFDumpCoords( APrefix: string );
begin
  BFDumpStr( APrefix + ' ' + BFAP() );
end; // procedure TN_BaseForm.BFDumpCoords

//******************************************************** TN_BaseForm.BFAP ***
// get current Align Params as a string (for dumping)
//
// Resultin string description:
// Example: A=T SB=(0,0 F,F) FS=(501,789 495,750) MS=(491,750)
// A=T                  - Current Align mode is True (EnableAlign)
// SB=(0,0 F,F)         - ScrollBars Range (X,Y) and Visibility (for X,for Y)
// FS=(501,789 495,750) - Form Width, Height, ClientWidth, ClientHeight
// MS=(491,750)         - Minimal Form Size calculated by BFMinBRPanel
//
function TN_BaseForm.BFAP(): string;
var
  MinSize: TPoint;
begin
  with BFMinBRPanel do
    MinSize := Point( Left+Width, Top+Height );

  Result := Format( 'A=%s SB=(%d,%d %s,%s) FS=(%d,%d %d,%d) MS=(%d,%d)',
              [N_B2S(not Self.AlignDisabled),
               HorzScrollBar.Range, VertScrollBar.Range,
//               N_B2S(HorzScrollBar.Visible), N_B2S(VertScrollBar.Visible),
               N_B2S(HorzScrollBar.IsScrollbarVisible()), N_B2S(VertScrollBar.IsScrollbarVisible()),
               Self.Width, Self.Height, Self.ClientWidth, Self.ClientHeight,
               MinSize.X, MinSize.Y] );

  if BFDumpControl <> nil then
    with BFDumpControl do
      Result := Result + Format( ' DC=(%d,%d %d,%d)', [Left, Top, Width, Height] );
end; // function TN_BaseForm.BFAP

//********************************************* TN_BaseForm.CloseOwnedForms ***
// Close all Forms, Owned by Self
//
procedure TN_BaseForm.CloseOwnedForms();
var
  i, MaxI: integer;
  ActObj: TObject;
begin
  if Self = nil then Exit;

  N_s := Name; // debug
  with BFOnCloseActions do
  begin
    MaxI := Count-1;

    for i := 0 to MaxI do
    begin
      ActObj := TObject(Items[i]);
      N_s1 := TN_BaseActionObj(ActObj).ActName; // debug
      if ActObj is TN_CloseFormActObj then
      with TN_CloseFormActObj(ActObj) do
      begin
        N_i := 0;
        if FormToClose is TForm then N_i := 1;
        N_s2 := FormToClose.Name; // debug
//        N_ADS( Format( 'COF: S1=%s, S2=%s, S3=%s', [N_s, N_s1, N_s2] ), N_i ); // debug
        FormToClose.Close();
      end;
    end; // for i := 0 to MaxI do

  end; // with BFOnCloseActions do
end; // end of procedure TN_BaseForm.CloseOwnedForms

//********************************************** TN_BaseForm.FormDeactivate ***
// Set StayOnTop Style to Self on Deactivate
//
//     Parameters
// Sender - Event Sender
//
// OnActivate and OnDeactivate Self handler
//
procedure TN_BaseForm.FormDeactivate(Sender: TObject);
var
  WStr : string;
begin
  if Sender = Application then
    WStr := 'Application'
  else
    WStr := 'BaseForm';
  BFDumpStr( format( '%s.OnDeactivate Start >> %s M=%d', [WStr,BFSelfName,N_BaseFormStayOnTop] ) );
//  N_Dump2Str( format( '%s.OnDeactivate Start >> %s M=%d', [WStr,BFSelfName,N_BaseFormStayOnTop] ) );

  if not BFIsClosing            and
     Assigned(BFPrevDeactivate) and
     (Sender = Application)  then
    BFPrevDeactivate(Sender); // Call Previouse Deactivate (for Application Deactivate Handler Call)

  if BFIsClosing                or
     (N_BaseFormStayOnTop <> 2) or
     BFSkipDeactivateTOPMOST    or
     not BFAppDeactivateWasChanged then Exit;

  N_Dump2Str( WStr + '.OnDeactivate do TOPMOST >> ' + BFSelfName );

  BFSkipActivateOnTOPMOST := TRUE;
  SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0,
                SWP_NOMOVE or SWP_NOSIZE );

  BFSkipActivateOnTOPMOST := FALSE;

  BFSkipDeactivateTOPMOST := TRUE;
  BFDumpStr( WStr + '.OnDeactivate fin >> ' + BFSelfName );
//  N_Dump2Str( WStr + '.OnDeactivate fin >> ' + BFSelfName )
end; // procedure TN_BaseForm.FormDeactivate

//************************************************ TN_BaseForm.FormActivate ***
// Set StayOnTop Style to Self on Activate
//
//     Parameters
// Sender - Event Sender
//
// OnActivate and OnActivate Self handler
//
procedure TN_BaseForm.FormActivate(Sender: TObject);
begin
//  N_Dump2Str( format( 'BaseForm.OnActivate Start >> %s M=%d',  [BFSelfName,N_BaseFormStayOnTop] ) );
  BFDumpStr( format( 'BaseForm.OnActivate Start >> %s M=%d',  [BFSelfName,N_BaseFormStayOnTop] ) );
  if (N_BaseFormStayOnTop = 0) or not Visible or BFIsClosing or BFSkipActivateOnTOPMOST then Exit;

  N_Dump2Str( format( 'BaseForm.OnActivate do TOPMOST >> %s M=%d A=%s',  [BFSelfName,N_BaseFormStayOnTop,N_B2S(BFAppDeactivateWasChanged)] ) );
  if (N_BaseFormStayOnTop = 2) and not BFAppDeactivateWasChanged  then
  begin
  // Save Application previouse Deactivate handler
    BFPrevDeactivate := Application.OnDeactivate;
  // Set Self Deactivate handler to Application
    Application.OnDeactivate := FormDeactivate;
    BFAppDeactivateWasChanged := TRUE;
  end;

//  if N_BaseFormStayOnTop = 1 then
// Set always TOPMOST because sometimes activating Window is needed to be pushed on TOP
    SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0,
                  SWP_NOMOVE or SWP_NOSIZE );

  BFSkipDeactivateTOPMOST := FALSE;
  BFDumpStr( 'BaseForm.OnActivate fin >> ' + BFSelfName );
//  N_Dump2Str( 'BaseForm.OnActivate fin >> ' + BFSelfName )
end; // procedure TN_BaseForm.FormActivate

//************************************************ TN_BaseForm.FormActivate ***
// Set System buttons
//
//     Parameters
// Sender - Event Sender
//
// OnCreate Self handler
//
procedure TN_BaseForm.FormCreate(Sender: TObject);
begin
  Self.BorderIcons := N_BaseFormBorderIcons;
end; // procedure TN_BaseForm.FormCreate

Initialization
  N_AddStrToFile( 'N_BaseF Initialization' );

end.
