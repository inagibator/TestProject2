unit K_FCMStudyCapt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_Types, N_BaseF, N_CMREd3Fr,
  K_CM0, K_UDT1;

type
  TK_FormCMStudyCapt = class(TN_BaseForm)
    CMStudyFrame: TN_CMREdit3Frame;
    PnDevCtrlsParent: TPanel;
    BtExit: TButton;
    LaunchTimer: TTimer;
    StatusBar: TStatusBar;
    BtPreview: TButton;
    ChBAutoTake: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure RFramePaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure LaunchTimerTimer(Sender: TObject);
    procedure BtPreviewClick(Sender: TObject);
  private
    { Private declarations }
    LaunchDeviceFlag     : Boolean;
    LaunchPreviewFlag    : Boolean;
    LaunchAutoTakeFlag   : Boolean;
    PreviewSlide         : TN_UDCMSlide; // Slide to Preview by timer
    LastSavedCaptStartPos: Integer;      // Last Saved Capture Study Start Position
    DeviceDlgMemIniState : string;
    procedure CaptStudyContinue();
  public
    CurStudyItemIndex    : Integer;
    DeviceUIWasDisabled  : Boolean;      // Device UI was disabled Flag
    CaptureToLastPosition: Boolean;      // Capture to Last Study Position Flag
    CaptureToLastPositionShowWarning: Boolean;      // Capture to Last Study Position Show Warning Flag
    AutoTakeIfContinueCapt: Boolean;     // needed to restore AutoTake if continue capturing
    UnConditionalClose   : Boolean;      // Unconditional Self Close Flag
    // Needed for deletion slides captured after capturing in last position
//    UnCondCloseDelListInd:Integer;       // Unconditional Self Close Del Slides List Count
//    UnCondCloseLastSlideAliase: string;  // Unconditional Self Close Last Added Slide Aliase

    ReplaceLastSlideMode : Boolean;      // is Set after Slide is added to current position
    StudyPrevAddItem     : TN_UDBase;    // Last Added Slide Item
    StudyPrevAddSlide    : TN_UDCMSlide; // Last Added Slide, should be saved before next Slide is added
    StudyPrevAddLinkInfo : string;       // Last Added Slide Link info to Study
    PrevStudyDelSlide    : TN_UDCMSlide; // Last Added Slide, should be saved before next Slide is added
    SlidesToDelete       : TList;
    procedure CaptStudyAddSlideDataSavingPrep( ASlide : TN_UDCMSlide );
    procedure CaptStudyPrevAddDataSave();
    procedure CaptStudyRemovePrevAddedSlide( ASlide : TN_UDCMSlide );
    procedure CaptStudyPreviewSlide( ASlide : TN_UDCMSlide );
    procedure CaptStudyAutoTakeTry( );

  end;

var
  K_FormCMStudyCapt: TK_FormCMStudyCapt;

implementation

{$R *.dfm}

uses Contnrs,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  System.Types,
{$IFEND CompilerVersion >= 26.0}
N_Lib1, N_SGComp, N_CMMain5F, K_FCMStudyCaptSlide;

//********************************************* TK_FormCMStudyCapt.FormShow ***
// OnShow Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.FormShow(Sender: TObject);
var
  HeightDelta : Integer;
begin
  inherited;

//  BtExit.Enabled := K_CMStudyCaptAttrs.CMSDCDDlg <> nil;
  LaunchDeviceFlag := TRUE; // Launch Device after select start position

  BtPreview.Enabled := K_CMStudyCaptState <> K_cmscSkipPreview;

  if not Assigned(K_CMStudyCaptAttrs.CMSDCDCaptureSlideProc) then
  begin
    HeightDelta := BtPreview.Top - ChBAutoTake.Top;
    ChBAutoTake.Visible := FALSE;
    if not BtPreview.Enabled then
      BtPreview.Visible := FALSE;

    PnDevCtrlsParent.Top := PnDevCtrlsParent.Top + HeightDelta;
    PnDevCtrlsParent.Height := PnDevCtrlsParent.Height - HeightDelta;
    CMStudyFrame.Height := CMStudyFrame.Height + HeightDelta;
  end
  else
    ChBAutoTake.Checked := TRUE;


  if K_CMStudyCaptAttrs.CMSDCDDlg <> nil then
  begin
    LaunchDeviceFlag := FALSE; // Launch Self Device dialog
    if K_CMStudyCaptAttrs.CMSDCDDlgCPanel <> nil then
    begin
      HeightDelta := K_CMStudyCaptAttrs.CMSDCDDlgCPanel.Height - PnDevCtrlsParent.Height;
      if HeightDelta > 0 then
      begin
        CMStudyFrame.Height := CMStudyFrame.Height - HeightDelta;
        PnDevCtrlsParent.Top := PnDevCtrlsParent.Top  - HeightDelta;
        PnDevCtrlsParent.Height := PnDevCtrlsParent.Height + HeightDelta;
//        BtExit.Top := BtExit.Top - (HeightDelta shr 1)
      end;
      K_CMStudyCaptDevDlgCPanelParent := K_CMStudyCaptAttrs.CMSDCDDlgCPanel.Parent;
      K_CMStudyCaptAttrs.CMSDCDDlgCPanel.Parent :=  PnDevCtrlsParent;
    end; // if K_CMStudyCaptAttrs.CMSDCDDlgCPanel <> nil then

    // Store Previous Coords for future Restore Dlg State in MemIni
    DeviceDlgMemIniState := N_MemIniToString( 'N_Forms', K_CMStudyCaptAttrs.CMSDCDDlg.BFSelfName );

    // Move Device Ctrl Dlg out of screen  and show
    K_CMStudyCaptAttrs.CMSDCDDlg.Left := N_WholeWAR.Right + 100;
    K_CMStudyCaptAttrs.CMSDCDDlg.Top  := N_WholeWAR.Bottom + 100;
    N_Dump1Str( 'K_FormCMStudyCapt.FormShow before CMSDCDDlg=' + K_CMStudyCaptAttrs.CMSDCDDlg.Name + ' show' );
    K_CMStudyCaptAttrs.CMSDCDDlg.Show();
  end; // if K_CMStudyCaptAttrs.CMSDCDDlg <> 0 then

  with CMStudyFrame do
  begin
    RFrame.RFDebName := Name;
    RFrame.PaintBox.OnDblClick := nil;
    EdVObjsGroup := TN_SGComp.Create( RFrame );
    with EdVObjsGroup do
    begin
      GName := 'VOGroup';
      PixSearchSize := 15;
      SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
                 $04;  // do redraw actions loop witout objects
    end;
    RFrame.RFSGroups.Add( EdVObjsGroup );

//    UDStudy := TN_UDCMStudy(N_CM_MainForm.CMMFActiveEdFrame.EdSlide);
    EdSlide := N_CM_MainForm.CMMFActiveEdFrame.EdSlide;
    RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
    RFrame.OCanvBackColor := RFrame.DstBackColor;
    RFrame.RFCenterInDst := True;
    RFrame.RVCTFrInit3( EdSlide.GetMapRoot() );
    RFrame.aFitInWindowExecute( nil );
    RebuildStudySearchList();

    // Select single Study Item
    with TN_UDCMStudy(EdSlide) do
    begin
      K_CMEDAccess.EDAStudyCaptStartPosGet( TN_UDCMStudy(EdSlide) );
      UnSelectAll();
      CurStudyItemIndex := CMSStudyCaptStartPos;
      LastSavedCaptStartPos :=  CMSStudyCaptStartPos;
      SelectItemByIndex( CurStudyItemIndex );
    end;

    RFrame.RedrawAllAndShow();
  end; // with CMStudyFrame do


//  StatusBar.SimpleText := ' Select study start position to continue capture';

  K_CMShowMessageDlgByTimer( ' Select study start position to continue capture', mtInformation, TRUE, [], TRUE, '', 1 );
//  LaunchTimer.Enabled := TRUE;

  K_CMStudyCaptImgConfirmDlgCoords.Left := -1000;
//
  SlidesToDelete := TList.Create;

  BtPreview.Enabled := FALSE;

end; // procedure TK_FormCMStudyCapt.FormShow

//********************************** TK_FormCMStudyCapt.RFramePaintBoxMouse ***
// RFramePaintBox OnMouseDown handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.RFramePaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item, PrevItem : TN_UDBase;
  WStr : string;
begin
  inherited;
  with CMStudyFrame, TN_UDCMStudy(EdSlide), EdVObjsGroup, OneSR do
  begin
    N_Dump2Str( 'K_FormCMStudyCapt Cur Item start select' );
    if not (ssLeft in Shift) or (SRType = srtNone) then Exit;

    // Clear UnConditionalClose State
    CaptStudyContinue();

    if LaunchDeviceFlag Then
      LaunchTimer.Enabled := TRUE;
    WStr := '';
    PrevItem := nil;
    if CMSSelectedCount > 0 then
    begin
      PrevItem := CMSSelectedItems[0];
      WStr := PrevItem.ObjName;
    end;

    Item := TN_UDBase(SComps[SRCompInd].SComp);
    if PrevItem <> Item then
    begin
      if PrevItem <> nil then
        UnSelectItem( PrevItem );
      SelectItem( Item );
      CurStudyItemIndex := GetItemIndex(Item );
      CMSStudyCaptStartPos := CurStudyItemIndex;
      RFrame.RedrawAllAndShow();
    end;

    N_Dump2Str( format( 'K_FormCMStudyCapt select item prev=%s new=%s',
                        [WStr, Item.ObjName] ) );
  end; // with CMStudyFrame, EdVObjsGroup, OneSR do

end; // procedure TK_FormCMStudyCapt.RFramePaintBoxMouseDown

//*************************************** TK_FormCMStudyCapt.FormCloseQuery ***
// OnCloseQuery Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//  CanClose := (K_CMStudyCaptAttrs.CMSDCDDlg <> nil) or (K_CMStudyCaptModeState = -1);
  CanClose := BtExit.Enabled or UnConditionalClose;
  if not CanClose then Exit;
  N_Dump2Str( 'K_FormCMStudyCapt >> Close start' );

  // may be actual for the case CaptureToLastPosition is TRUE and Timer is enabled)
  LaunchTimer.Enabled := FALSE;

  // Save Last added Slide and Link it to Study
  CaptStudyPrevAddDataSave();

  with CMStudyFrame, TN_UDCMStudy(EdSlide) do
  begin
    // Clear Empty Position Selection
    if K_CMStudyGetOneSlideByItem( CMSSelectedItems[0] ) = nil then
      UnSelectItem( CMSSelectedItems[0] );

    // Save Study Capture Start Position
    if LastSavedCaptStartPos <> CMSStudyCaptStartPos then
    begin
      K_CMEDAccess.EDAStudyCaptStartPosSavingPrep( TN_UDCMStudy(EdSlide) );
      K_CMEDAccess.EDAStudySavingFinish();
    end;
    
    UnSelectAll();
  end; // with CMStudyFrame, TN_UDCMStudy(EdSlide) do

end; // procedure TK_FormCMStudyCapt.FormCloseQuery


//******************************************** TK_FormCMStudyCapt.FormClose ***
// OnClose Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.FormClose(Sender: TObject;
  var Action: TCloseAction );
var
  i : Integer;
begin
  // Close Preview window if Opened
  if K_FormCMStudyCaptSlide <> nil then
    K_FormCMStudyCaptSlide.Close();

  K_FormCMStudyCapt := nil;

  if K_CMStudyCaptState >= K_cmscOK then
  begin
    N_Dump1Str( 'K_FormCMStudyCapt SelfClose' );
    if K_CMStudyCaptAttrs.CMSDCDDlg <> nil then
    begin
      if K_CMStudyCaptAttrs.CMSDCDDlgCPanel <> nil then
      begin
        K_CMStudyCaptAttrs.CMSDCDDlgCPanel.Parent := K_CMStudyCaptDevDlgCPanelParent;
        K_CMStudyCaptAttrs.CMSDCDDlgCPanel := nil;
      end;
      K_CMStudyCaptState := K_cmscStudyCaptDlgIsClosed;
      K_CMStudyCaptAttrs.CMSDCDDlg.Close();

      // Restore Previous Dlg Coords in MemIni
      N_StringToMemIni( 'N_Forms', K_CMStudyCaptAttrs.CMSDCDDlg.BFSelfName, DeviceDlgMemIniState );

      K_CMStudyCaptAttrs.CMSDCDDlg := nil;
    end
    else // No Device Dlg is opened - precaution
      K_CMStudyCaptState := K_cmscNon;
  end // if K_CMStudyCaptModeState = 0 then
  else // Caption is finished by Device
    K_CMStudyCaptState := K_cmscNon;

  // Delete all Slides which should be deleted
  if SlidesToDelete.Count > 0 then
    N_Dump2Str( 'K_FormCMStudyCapt Delete Removed Objects' );
  for i := 0 to SlidesToDelete.Count - 1 do
  begin
    N_Dump2Str( 'Delete ' + TN_UDBase(SlidesToDelete[i]).ObjName );
    TN_UDBase(SlidesToDelete[i]).UDDelete();
  end;
  SlidesToDelete.Free;

  // Rebuild Active Frame and Thumbnails Frame View
  N_CM_MainForm.CMMFActiveEdFrame.RFrame.RedrawAllAndShow();
  N_CM_MainForm.CMMCurFThumbsRFrame.RedrawAllAndShow();

  inherited;

end; // procedure TK_FormCMStudyCapt.FormClose

//************************************* TK_FormCMStudyCapt.LaunchTimerTimer ***
// LaunchTimer OnTimer handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.LaunchTimerTimer(Sender: TObject);
begin

  // Disabled Device capturing after use last position
  if CaptureToLastPosition then
    StatusBar.SimpleText := ' Select study start position to continue capture'
  else
    StatusBar.SimpleText := '';

  if CaptureToLastPosition and Assigned(K_CMStudyCaptAttrs.CMSDCDCaptureDisableProc) then
  begin
  // do not disable Timer if CaptureToLastPosition is TRUE to disable device UI
  // if device self enable UI
    K_CMStudyCaptAttrs.CMSDCDCaptureDisableProc();
    DeviceUIWasDisabled := TRUE;
  end
  else
  begin
    LaunchTimer.Enabled := FALSE;
//  LaunchTimer.Interval := 10;
    N_Dump2Str( 'K_FormCMStudyCapt LaunchTimerTimer start' );
  end;

  if LaunchDeviceFlag then
  begin
    LaunchDeviceFlag := FALSE;
    CMStudyFrame.RFrame.RedrawAllAndShow;

    if (K_CMStudyCaptAttrs.CMSDCDDlg <> nil) and
       (K_CMStudyCaptState = K_cmscDeviceDlgShowLater) then
    begin
      N_Dump1Str( 'K_FormCMStudyCapt.LaunchTimerTimer before CMSDCDDlg show' );
      K_CMStudyCaptAttrs.CMSDCDDlg.Show();
    end
    else
    if Assigned(K_CMStudyCaptAttrs.CMSDCDLaunchDevUIProc) then
    begin
      N_Dump1Str( 'K_FormCMStudyCapt.LaunchTimerTimer before CMSDCDLaunchDevUIProc' );
      K_CMStudyCaptAttrs.CMSDCDLaunchDevUIProc();
    end;
  end; // if LaunchDeviceFlag then

  if LaunchPreviewFlag then
  begin
    LaunchPreviewFlag := FALSE;
    if K_FormCMStudyCaptSlide = nil then
    begin
      K_FormCMStudyCaptSlide := TK_FormCMStudyCaptSlide.Create( Application );
//      K_FormCMStudyCaptSlide.BFFlags := [bffDumpPos,bffToDump2];
//      K_FormCMStudyCaptSlide.BaseFormInit( nil );
    end;
    K_FormCMStudyCaptSlide.ShowSlide( PreviewSlide );
  end; // if LaunchPreviewFlag then

  if CaptureToLastPositionShowWarning then
  begin
    K_CMShowMessageDlgByTimer( ' The image is mounted on the last study position. Please select the next position if you want to continue.',
                                    mtInformation, TRUE, [], FALSE, '', 7 );
    CaptureToLastPositionShowWarning := FALSE;
  end;

  if LaunchAutoTakeFlag then
  begin
    LaunchAutoTakeFlag := FALSE;
    K_CMStudyCaptAttrs.CMSDCDCaptureSlideProc();
  end;


end; // procedure TK_FormCMStudyCapt.LaunchTimerTimer

//*************************************** TK_FormCMStudyCapt.BtPreviewClick ***
// Button Preview OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCapt.BtPreviewClick(Sender: TObject);
begin
  LaunchPreviewFlag := TRUE;
  LaunchTimerTimer(LaunchTimer);
end; // procedure TK_FormCMStudyCapt.BtPreviewClick


//***************************** TK_FormCMStudyCapt.CaptStudyPrevAddDataSave ***
// Add to Deleted List and Save Previousely Added Slidese if exists
//
procedure TK_FormCMStudyCapt.CaptStudyPrevAddDataSave;
var
  CurSelectedItem : TN_UDBase;
begin
  if PrevStudyDelSlide <> nil then
  begin
    SlidesToDelete.Add(PrevStudyDelSlide);
//    PrevStudyDelSlide.UDDelete();
    N_Dump2Str( format( 'K_FormCMStudyCapt >> Add to be deleted list Slide=%s(%p)',
                             [PrevStudyDelSlide.ObjName, Pointer(PrevStudyDelSlide)] ) );
    PrevStudyDelSlide := nil;
  end;

  if StudyPrevAddSlide = nil then Exit;

  // Save Slide
  N_Dump2Str( format( 'K_FormCMStudyCapt >> Save Slide=%s(%p)',
                             [StudyPrevAddSlide.ObjName, Pointer(StudyPrevAddSlide)] ) );
  StudyPrevAddSlide.ObjAliase := '';
  K_CMEDAccess.EDASaveSlidesArray( @StudyPrevAddSlide, 1 );

  // Correct Study Slide Info
  if K_CMEDAccess is TK_CMEDDBAccess then
    with TK_CMEDDBAccess(K_CMEDAccess).SlideStudyInfoUpdateStrings do
    begin
      Text := StudyPrevAddLinkInfo;
      Strings[0] := StudyPrevAddSlide.ObjName + '=' + ValueFromIndex[0];
      N_Dump2Str( format( 'K_FormCMStudyCapt >> Study link info>> %s',
                             [Text] ) );
    end;

  with CMStudyFrame, TN_UDCMStudy(EdSlide) do
  begin
    // Unselect Position for correct Study Thumbnail creation
    CurSelectedItem := CMSSelectedItems[0];
    UnSelectItem( CurSelectedItem );

    // Save Study to DB
    K_CMEDAccess.EDAStudySavingStart();
    TN_UDCMStudy(EdSlide).CreateThumbnail();
    TN_UDCMStudy(EdSlide).SetChangeState();
    K_CMEDAccess.EDAStudyCaptStartPosSavingPrep( TN_UDCMStudy(EdSlide) );
    K_CMEDAccess.EDAStudySave( TN_UDCMStudy(EdSlide) );
    K_CMEDAccess.EDAStudySavingFinish();
    LastSavedCaptStartPos := CMSStudyCaptStartPos;
    SelectItem( CurSelectedItem );
  end;
  StudyPrevAddSlide := nil;
  if UnConditionalClose then Close();
end; // procedure TK_FormCMStudyCapt.CaptStudyPrevAddDataSave

//********************** TK_FormCMStudyCapt.CaptStudyAddSlideDataSavingPrep ***
// Add New Slide for future saving
//
procedure TK_FormCMStudyCapt.CaptStudyAddSlideDataSavingPrep( ASlide : TN_UDCMSlide );
begin
  StudyPrevAddSlide := ASlide;
  if not ReplaceLastSlideMode then
  begin
    if K_CMEDAccess is TK_CMEDDBAccess then
    with TK_CMEDDBAccess(K_CMEDAccess).SlideStudyInfoUpdateStrings do
    begin
      StudyPrevAddLinkInfo := Text;
      Clear();
    end;

    StudyPrevAddItem := TN_UDCMStudy(CMStudyFrame.EdSlide).CMSSelectedItems[0];
  end;
  N_Dump2Str( format( 'TK_FormCMStudyCapt >> AddSlideDataSavingPrep Slide=%s(%p)'#13#10'%s',
                        [StudyPrevAddSlide.ObjName, Pointer(StudyPrevAddSlide),StudyPrevAddLinkInfo] ) );

  ReplaceLastSlideMode := FALSE;
end; // procedure TK_FormCMStudyCapt.CaptStudyAddSlideDataSavingPrep

//************************ TK_FormCMStudyCapt.CaptStudyRemovePrevAddedSlide ***
// Remove previousely added Slide
//
procedure TK_FormCMStudyCapt.CaptStudyRemovePrevAddedSlide( ASlide : TN_UDCMSlide );
begin
  with CMStudyFrame, TN_UDCMStudy(EdSlide) do
  begin
    // Remove Added Slide From Item Study

    CaptStudyContinue();
// Temp code  may be not needed
//    FSlide := ASlide;
//    CurSelItem := CMSSelectedItems[0];
//    if CurSelItem <> StudyPrevAddItem then // New Slide to add was come befor reject is conformed (use StudyPrevAddSlide)
//      FSlide := StudyPrevAddSlide;

    N_Dump2Str( format( 'TK_FormCMStudyCapt >> Remove captured start Slide=%s(%p) from item %s by user',
                        [StudyPrevAddSlide.ObjName, Pointer(StudyPrevAddSlide), StudyPrevAddItem.ObjName] ) );

    K_CMEDAccess.EDAStudyRemoveSlideFromItem( StudyPrevAddItem, StudyPrevAddSlide, TN_UDCMStudy(EdSlide) );
    if K_CMEDAccess is TK_CMEDDBAccess then
      TK_CMEDDBAccess(K_CMEDAccess).SlideStudyInfoUpdateStrings.Clear;

    // Prepare Slide Deletion
    K_CMEDAccess.EDAClearSlideECache( StudyPrevAddSlide );
    K_CMEDAccess.CurSlidesList.Remove( StudyPrevAddSlide );

    if PrevStudyDelSlide <> nil then
    begin
      SlidesToDelete.Add(PrevStudyDelSlide);
      N_Dump2Str( format( 'TK_FormCMStudyCapt >> Add to DelList Slide=%s(%p)',
                        [PrevStudyDelSlide.ObjName, Pointer(PrevStudyDelSlide)] ) );
    end;
    PrevStudyDelSlide := StudyPrevAddSlide; // Slide Should be deleted later (for devices that can change last Slide)

//    if StudyPrevAddSlide = ASlide then // may be this if is not needed
    begin
      StudyPrevAddSlide := nil;
      if not CaptureToLastPosition then
        CurStudyItemIndex := GetItemIndex(StudyPrevAddItem);
    end;

    // Select Previouse Item
    UnselectAll();

    if not CaptureToLastPosition then
    begin
      SelectItemByIndex( CurStudyItemIndex );
      CMSStudyCaptStartPos := CurStudyItemIndex; // Return Study Cepture Position
    end;
    
    RFrame.RedrawAllAndShow();
  end; // with CMStudyFrame, TN_UDCMStudy(EdSlide) do
  // Redraw Study State
end; // procedure TK_FormCMStudyCapt.CaptStudyRemovePrevAddedSlide

//******************************** TK_FormCMStudyCapt.CaptStudyPreviewSlide ***
// Preview new Slide
//
procedure TK_FormCMStudyCapt.CaptStudyPreviewSlide( ASlide : TN_UDCMSlide );
begin
//  N_Dump2Str('!!!!CaptStudyPreviewSlide');
  if K_CMStudyCaptState = K_cmscSkipPreview then Exit;
  if not ReplaceLastSlideMode then
  begin
    PreviewSlide := ASlide;
    if not LaunchPreviewFlag then
    begin
      LaunchTimer.Enabled := TRUE;
      LaunchPreviewFlag := TRUE;
    end
  end
  else
  begin // Show Slide Preview
    PreviewSlide := ASlide;
    LaunchPreviewFlag := TRUE;
    LaunchTimerTimer(LaunchTimer);
  end;
end; // procedure TK_FormCMStudyCapt.CaptStudyPreviewSlide

//********************************* TK_FormCMStudyCapt.CaptStudyAutoTakeTry ***
// Auto Take new Slide if needed
//
procedure TK_FormCMStudyCapt.CaptStudyAutoTakeTry( );
begin
  if not ChBAutoTake.Checked then Exit;
  LaunchTimer.Enabled := TRUE;
  LaunchAutoTakeFlag := TRUE;
end; // procedure TK_FormCMStudyCapt.CaptStudyAutoTakeTry

//************************************ TK_FormCMStudyCapt.CaptStudyContinue ***
// Clear Unconditinal close
//
procedure TK_FormCMStudyCapt.CaptStudyContinue;
begin
  N_Dump2Str( 'K_FormCMStudyCapt.CaptStudyContinue start' );
  StatusBar.SimpleText := '';
  if DeviceUIWasDisabled then
  begin
    K_CMStudyCaptAttrs.CMSDCDCaptureEnableProc();

    if AutoTakeIfContinueCapt then
    begin
      if ChBAutoTake.Visible then
        ChBAutoTake.Checked := TRUE
      else if Assigned(K_CMStudyCaptAttrs.CMSDCDAutoTakeStateSetProc) then
        K_CMStudyCaptAttrs.CMSDCDAutoTakeStateSetProc( 1 );
      AutoTakeIfContinueCapt := FALSE;
    end;
    DeviceUIWasDisabled    := FALSE;
  end; // if CaptureToLastPosition then

  CaptureToLastPosition  := FALSE;

  // Close Preview if is opened
  if K_FormCMStudyCaptSlide <> nil then
    K_FormCMStudyCaptSlide.Close();

end; // procedure TK_FormCMStudyCapt.CaptStudyContinue

end.
