unit N_CMREd3Fr;
// CMS Application Raster Editor Frame

// Sometimes RFrame Height becoms zero after complex frames reorder
// after setting CMREdit3Frame Min Width Height restrictions 70,80 all works OK

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, ImgList, ActnList, ExtCtrls, StdCtrls,
  Buttons, Types,
  K_UDT1, K_Script1, K_CM0, K_CMRFA,
  N_Types, N_BaseF, N_Rast1Fr, N_CM1,
  N_CompBase, N_Comp1, N_Gra2, // N_CMGammaCorrF, N_CMResampleF,
  N_SGComp, N_MapEdFr, N_CMResF, N_CMRFA, N_Comp2;

type TN_CMRFRRActionType = ( cmrfarrCopy, cmrfarrPaste, cmrfarrCrop );
type TN_CMRFRSActionType = ( cmrfarsCalibrate, cmrfarsMeasure );
type TN_CMRFRVEMode = ( cmrfemNone, cmrfemPoint, cmrfemZoom, cmrfemPan,
                        cmrfemCreateVObj1, cmrfemCreateVObj2, cmrfemIsodensity,
                        cmrfemGetSlideColor, cmrfemCropImage, cmrfemFlashLight );
type TN_CMRFRVOConv = ( cmrfvcRotateLeft, cmrfvcRotateRight, cmrfvcRotate180,
                        cmrfvcFlipHor, cmrfvcFlipVert );
type TN_CMREdit3Frame = class( TFrame )
    RFrame: TN_MapEdFrame;
    CMREd3FrActList: TActionList;
    aFileSaveSlideA: TAction;
    aFilePasteFromFile: TAction;
    aFileReplaceImageF: TAction;
    aFileReplaceSlideF: TAction;
    aDebCMSOneSlideChild: TAction;
    aFileSaveImageF: TAction;
    aFileSaveSlideF: TAction;
    aEditCopySelected: TAction;
    aFilePrint: TAction;
    aDebSaveArchAs: TAction;
    aDebShowNVTreeForm: TAction;
    aEditCopyWhole: TAction;
    aEditPasteInSelection: TAction;
    aEditPasteWhole: TAction;
    aEditCropBySelection: TAction;
    aViewView1To1: TAction;
    aViewShowResHist: TAction;
    aAdjustBrighByTwoPoints: TAction;
    aAdjustBrighByGammaCorr: TAction;
    aAdjustResample: TAction;
    aAdjustFlipHorizontal: TAction;
    aAdjustFlipVertical: TAction;
    aAdjustRotate90CW: TAction;
    aAdjustRotate90CCW: TAction;
    aAdjustSrcHistVisible: TAction;
    aDeb1: TAction;
    aObjBeginEditing: TAction;
    aObjFinishEditing: TAction;
    aObjAddTextNote: TAction;
    aObjAddRoundRect: TAction;
    aObjAddArrow: TAction;
    aObjPasteObject: TAction;
    aObjDeleteAllObj: TAction;
    aObjObjectsVisible: TAction;
    aDeb2: TAction;
    aMesCalibrate: TAction;
    aMesMeasureDistance: TAction;
    aAdjustClearImage: TAction;
    aViewFitToWindow: TAction;
    aObjTst: TAction;
    aViewTst: TAction;
    FrameLeftCaption: TLabel;
    FrameRightCaption: TLabel;
    ImgClibrated: TImage;
    STReadOnly: TStaticText;
    FinishEditing: TSpeedButton;
    ImgHasDiagn: TImage;

	  destructor Destroy       (); override;

    //************************** CMREdActList Actions ***********

    //************************** File Actions ***********
    procedure aFileSaveSlideAExecute    ( Sender: TObject );
    procedure aFilePasteFromFileExecute ( Sender: TObject );

    procedure aFileReplaceImageFExecute ( Sender: TObject );
    procedure aFileReplaceSlideFExecute ( Sender: TObject );
    procedure aFileSaveImageFExecute    ( Sender: TObject );
    procedure aFileSaveSlideFExecute    ( Sender: TObject );

    procedure aFilePrintExecute         ( Sender: TObject );

    //************************** Edit Actions ***********
    procedure aEditCopySelectedExecute     ( Sender: TObject );
    procedure aEditCopyWholeExecute        ( Sender: TObject );
    procedure aEditPasteInSelectionExecute ( Sender: TObject );
    procedure aEditPasteWholeExecute       ( Sender: TObject );
    procedure aEditCropBySelectionExecute  ( Sender: TObject );
{
    //************************** Adjust Actions ***********
    procedure aAdjustBrighByTwoPointsExecute ( Sender: TObject );
    procedure aAdjustBrighByGammaCorrExecute ( Sender: TObject );
    procedure aAdjustSrcHistVisibleExecute   ( Sender: TObject );

    procedure aAdjustResampleExecute         ( Sender: TObject );
    procedure aAdjustFlipHorizontalExecute   ( Sender: TObject );
    procedure aAdjustFlipVerticalExecute     ( Sender: TObject );
    procedure aAdjustRotate90CWExecute       ( Sender: TObject );
    procedure aAdjustRotate90CCWExecute      ( Sender: TObject );

    procedure aAdjustClearImageExecute       ( Sender: TObject );

    //************************** View Actions ***********
    procedure aViewFitToWindowExecute ( Sender: TObject );
    procedure aViewView1To1Execute    ( Sender: TObject );
    procedure aViewShowResHistExecute ( Sender: TObject );


    //************************** Objects Actions ***********
    procedure aObjBeginEditingExecute   ( Sender: TObject );
    procedure aObjFinishEditingExecute  ( Sender: TObject );
    procedure aObjAddRoundRectExecute   ( Sender: TObject );
    procedure aObjAddTextNoteExecute    ( Sender: TObject );
    procedure aObjAddArrowExecute       ( Sender: TObject );
    procedure aObjPasteObjectExecute    ( Sender: TObject );
    procedure aObjDeleteAllObjExecute   ( Sender: TObject );
    procedure aObjObjectsVisibleExecute ( Sender: TObject );

    //************************** Measure Actions ***********
    procedure aMesCalibrateExecute       ( Sender: TObject );
    procedure aMesMeasureDistanceExecute ( Sender: TObject );
}
    //************************** Deb Actions ***********
    procedure aDebCMSOneSlideChildExecute ( Sender: TObject );
    procedure aDebSaveArchAsExecute       ( Sender: TObject );
    procedure aDebShowNVTreeFormExecute   ( Sender: TObject );
    procedure aDeb1Execute                ( Sender: TObject );
    procedure aDeb2Execute                ( Sender: TObject );

    //********************** TN_CMREdit3Frame Handlers ***********
    procedure FrameMouseDown ( Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer );
    procedure FrameDragOver  ( Sender, Source: TObject; X, Y: Integer;
                               State: TDragState; var Accept: Boolean );
    procedure FrameEndDrag   ( Sender, Target: TObject; X,Y: Integer );
    procedure aObjTstExecute ( Sender: TObject );
    procedure FinishEditingClick(Sender: TObject);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FrameDblClick(Sender: TObject);
  protected
    TmpDIB:    TN_DIBObj; // wrk DIB
  public
    EdViewEditMode : TN_CMRFRVEMode; // Frame View Edit Mode
    EdSlide   : TN_UDCMSlide;  // Slide beeing edited
    EdUndoBuf : TK_CMSUndoBuf; // Slide UNDO buffer object
//    OriginalDIB:    TN_DIBObj;    // Original DIBObj (Self is Owner of it)
//    Brigh2PEditForm: TN_Brigh2PEditForm;
//    SrcBrighHist:    TN_BrighHistForm;
//    ResBrighHist:    TN_BrighHistForm;
//    GammaCorrForm:   TN_CMGammaCorrForm;
//    ResampleForm:    TN_CMResampleForm;

    EdVObjSelected:   TN_UDCompVis; // Current Selected Vector Objects
    EdVObjsGroup:     TN_SGComp;    // Group for Vector Objects RFA
    EdAddVObj1RFA      : TK_CMEAddVObj1RFA; // Create PolyLines and TextBox RFAction
    EdAddVObj2RFA      : TK_CMEAddVObj2RFA; // Create Angles RFAction
    EdMoveVObjRFA      : TK_CMEMoveVObjRFA; // Move Measure and Annotation Vector Objects RFAction
    EdIsodensityRFA    : TK_CMEIsodensityRFA;    // Get Image Color for Isodensity Mode
    EdGetSlideColorRFA : TK_CMEGetSlideColorRFA; // Get Slide Color Mode
    EdRubberRectRFA    : TN_RubberRectRFA;       // Change Ellipse or Rectangle by Rubber Rectangle
    EdFlashLightModeRFA: TK_CMEFlashLightModeRFA;// FlashLight Mode RFA
    EdFlashLightRFA    : TN_CMFlashLightRFA;     // FlashLight tool
{ !! obsolete !!
    RRGroup:          TN_SGComp; // Group for RubberRect RFA
    RubberRectRFA:    TN_RubberRectRFA;
    RubberSegmRFA:    TN_RubberSegmRFA;
    EditCompsRFA:     TN_EditCompsRFA;
    MouseActionRFA:   TN_RFAMouseAction;

    SelectedPixRect: TRect;
    RSegmActType: TN_CMRFRSActionType;

    ShowResHist: boolean; // Show resulting(changed) Image Brightness Histogramm
    ShowSrcHist: boolean; // Show Source(original) Image Brightness Histogramm
    PasteMode:   boolean; // Paste Mode (used in MouseMoveProcObj)
    ObjectsVisible: boolean; // Objects are Visible

    RGBValues: TN_BArray; // wrk Array
    XLatTable: TN_BArray; // wrk Array
}

//    StatusBarTimer: TTimer;
//    pmObjectsMenu:  TPopupMenu;
//    CMMainForm:     TN_BaseForm; // always TN_CMMain4Form should be removed!
    SelfIndex:      integer;     // Self index in CMMainForm.EditorFrames array

    EdWillBeFocused : Boolean;

    procedure FrameActivate ( Sender: TObject );
//    procedure FrameClose ( Sender: TObject; var Action: TCloseAction );

    procedure ShowString             ( AStr: string );
    procedure ShowStringByTimer      ( AStr: string );

    procedure UpdateBrighByTwoPoints ( AP1, AP2: TFPoint );
    procedure UpdateBrighByGamma     ( AGamma: double );

    procedure RRectMouseMoveProcObj          ( ARFAction: TObject );
    procedure RRectCancelProcObj             ( ARFAction: TObject );
    procedure RRectCopySeletedRectProcObj    ( ARFAction: TObject );
    procedure RRectPasteInSelectedProcObj    ( ARFAction: TObject );
    procedure RRectCropBySelectedRectProcObj ( ARFAction: TObject );

    procedure RSegmMouseMoveProcObj ( ARFAction: TObject );
    procedure RSegmMouseDownProcObj ( ARFAction: TObject );
    procedure RSegmDrawSegmProcObj  ( ARFAction: TObject );

    procedure ECompsDblClickProcObj   ( ARFAction: TObject );
    procedure ECompsRightClickProcObj ( ARFAction: TObject );

    function  U2ImagePix             ( AUCoords: TDPoint ): TPoint;
    function  GetCurPixelColor       (): integer;
    function  GetSelectedPixRect     (): TRect;
    function  GetVisibleURect        (): TFRect;
    function  GetNewObjURect         ( ASender: TObject ): TFRect;
    procedure InitSelectedRect       ();
//    procedure InitObjComps           ();

    procedure ShowWholeImage         ();
    function  InitSlideView          () : Boolean;
    function  SetNewSlide            ( ANewSlide: TN_UDCMSlide ) : Boolean;
    procedure SetReadOnlyState();
    procedure SetFrameDefaultViewEditMode( );
    procedure RebuildSlideView       ( AShowDump : Boolean = FALSE );
    function  CheckRectEllipsLine    ( AUDPolyLine : TN_UDPolyLine ) : Boolean;
    procedure RebuildVObjsSearchList ();
    procedure RebuildStudySearchList();
    procedure RebuildSlideThumbnail       ();
    function  DeleteVObjSelected( ASaveHistory : Boolean = FALSE ) : Boolean;
//    procedure AffConvVObjs           ( AVOConv : TN_CMRFRVOConv );
//    procedure AffConvVObjs6( APixAffCoefs6: TN_AffCoefs6; AAngle : Double );
    function  ChangeSelectedVObj( ANewState : Integer; AUDVObj : TN_UDCompVis = nil;
                                  ASkipDisableActions : Boolean = FALSE ) : Boolean;
    function  AskAndSaveCurrentDIB   ( ANeedToAsk: boolean ): boolean;
//    procedure RestoreOriginalDIB     ();
    procedure EdFreeObjects          ( AFreeFlags : TN_CMRFEdFreeFlags = [] );
    procedure Ed3FrAddCurState       ( AStrings: TStrings; AIndent: integer );
    procedure Ed3FrDumpCurState      ( AIndent: integer );
    procedure Ed3FrDumpFrameRightCaption( AStr : string = '' );
    function  IfSlideIsImage( ) : Boolean;
    function  IfSlideIsStudy( ) : Boolean;
    procedure Ed3FrClearEditContext();

end; // type TN_CMREdit3Frame = class( TFrame )

type TN_CMREdit3FrArray = array of TN_CMREdit3Frame;


implementation
uses math, clipbrd, StrUtils,
  K_CLib0, K_Arch, K_STBuf, K_VFunc,
  N_ButtonsF, N_Gra0, N_Gra1, N_Lib0, N_Lib1, N_Lib2, N_GCont, N_EdRecF, {N_IPCF,}
  N_CompCL, N_MsgDialF, N_Deb1, N_InfoF, N_EdStrF, N_PrintF,
  N_NVTreeF,{N_MainFFr,} N_EdParF, N_Color1F, N_CMMain5F, N_DGrid, N_BrigHist2F,
  K_CML1F;

{$R *.dfm}

//******************************************** TN_NVTCSMFrame.CMREdit3Frame ***

destructor TN_CMREdit3Frame.Destroy();
begin
//  if N_TstIPCForm <> nil then N_TstIPCForm.AddInfoStr( 'CMREdit3Frame', '5' );
//  OriginalDIB.Free;
//  if N_TstIPCForm <> nil then N_TstIPCForm.AddInfoStr( 'CMREdit3Frame', '6' );
//  EdVObjsGroup.Free; may be not needed because it is free while Rast1Fr.FreeObjects
  Inherited;
//  if N_TstIPCForm <> nil then N_TstIPCForm.AddInfoStr( 'CMREdit3Frame', '7' );
end; // destructor TN_CMREdit3Frame.Destroy


    //************************** File Actions ***********

procedure TN_CMREdit3Frame.aFileSaveSlideAExecute( Sender: TObject );
// Save Slide (used only in child modes):
//   to Other Application in cmsatOneSlideChild mode or
//   to External DB in cmsatOneSlideDBChild mode
//var
//  PatId: integer;
begin
{##!! Obsolete Code
  begin
  PatId := K_CMCurPatientID;
//  PatId := N_CM_CurPatient.P()^.CMPSelfId;

  if N_CMSAppType = cmsatOneSlideChild then
  with N_IPCObj do
  begin
    IPCSelfDataSize := 0;
    EdSlide.SaveSlideInfo( [cmsifChanged] );
//    IPCPutCommand( 21, PatId, EdSlide.P()^.CMSSelfId, 0, 0,
    IPCPutCommand( 21, PatId, StrToInt(EdSlide.ObjName), 0, 0,
                              @IPCSelfData[0], IPCSelfDataSize, 0, ipcatTmpMem );
  end else if N_CMSAppType = cmsatOneSlideDBChild then
  begin
    K_CMDBBeginUpdate();
    K_CMDBInitPatient( PatId );
    EdSlide.SaveSlideInfo( [cmsifExtDB,cmsifChanged] );
    K_CMDBEndUpdate();
  end;

  ShowString( 'Slide updated' );

  end; //
}
end; // procedure TN_CMREdit3Frame.aFileSaveSlideAExecute

procedure TN_CMREdit3Frame.aFilePasteFromFileExecute( Sender: TObject );
// Paste Image from File into Selection
begin

  begin

  ShowMessage( ' Sorry, not implemented yet ...' );
  ShowString( '' );

  end; //
end; // procedure TN_CMREdit3Frame.aFilePasteFromFileExecute

procedure TN_CMREdit3Frame.aFileReplaceImageFExecute( Sender: TObject );
// Replace Slide Image by Image from File
begin

  begin

  ShowMessage( ' Sorry, not implemented yet ...' );
  ShowString( '' );
{
var
  FileName, SlideName: string;
  NewSlide: TN_UDCMSlide;
begin
  ShowString( '' );
  if not GetFileAndSlideNames( FileName, SlideName ) then Exit; // Name was not choosen

  NewSlide := N_CreateSlideFromImage( FileName, SlideName );
  SetNewSlide( NewSlide ); // Update CMREdit3Frame by new Slide
  ShowString( 'Image Replaced' );
}

  end; //  
end; // procedure TN_CMREdit3Frame.aFileReplaceImageFExecute

procedure TN_CMREdit3Frame.aFileReplaceSlideFExecute( Sender: TObject );
// Load Slide - Replace Current Slide (Attributes, Image and Objects)
// by Slide, Saved in File by aFileSaveSlideExecute
//var
//  FileName: string;
begin
{
  begin

  FileName := N_GetFNameFromHist( 'Choose File Name to Load Slide from:',
                                  N_CMSFilesFilter, N_CMSFilesHistName, 400 );

  if FileName =N_NotAString then
  begin
    ShowString( '' );
    Exit;
  end;

  N_CMSReplaceSlideContent( EdSlide, FileName ); // Replace EdSlide Content by New one

  SetNewSlide( EdSlide ); // Update Self by new (just loaded) Slide

  ShowStringByTimer( 'Slide Loaded from File ' + FileName );

  end; //
}
end; // procedure TN_CMREdit3Frame.aFileLoadSlideFExecute

procedure TN_CMREdit3Frame.aFileSaveImageFExecute( Sender: TObject );
// Export Slide Image to BMP or JPEG Raster file
begin
   
  begin

  ShowMessage( ' Sorry, not implemented yet ...' );
  ShowString( '' );

  end; //  
end; // procedure TN_CMREdit3Frame.aFileSaveImageFExecute

procedure TN_CMREdit3Frame.aFileSaveSlideFExecute( Sender: TObject );
// Save Current Slide (Attributes, Image and Objects) to *.cms binary File
//var
//  FileName: string;
//  ParamsForm: TN_EditParamsForm;
begin
{##!! Obsolete Code
  begin

  //*** Get FileName to Save Slide

  ParamsForm := N_CreateEditParamsForm( 400 );
  with ParamsForm do
  begin
    Caption := 'Choose File Name to Save Slide:';
    AddFileNameFrame( '', N_CMSFilesHistName, N_CMSFilesFilter );

    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      ShowString( '' );
      Release; // Free ParamsForm
      Exit;
    end;

    FileName := EPControls[0].CRStr;
    Release; // Free ParamsForm
  end; // with ParamsForm do

  EdSlide.SaveSlideContent( FileName );
  ShowStringByTimer( 'Slide Saved to File ' + FileName );

  end; //
}
end; //procedure TN_CMREdit3Frame.aFileSaveSlideFExecute

procedure TN_CMREdit3Frame.aFilePrintExecute( Sender: TObject );
// Print current Slide (not implemented)
begin
{
var
  PrintForm: TN_PrintForm;
begin
//  PrintForm := N_CreatePrintForm ( nil, Rect(0,0,-1,-1), FPoint(100,100),
//                                   'PrintSettings', Self );
  with PrintForm do
  begin
    ShowModal();
  end; // with PrintForm do
}
end; // procedure TN_CMREdit3Frame.aFilePrintExecute


    //************************** Edit Actions ***********

procedure TN_CMREdit3Frame.aEditCopySelectedExecute( Sender: TObject );
// Copy Selected Rect to Windows Clipboard as raster
begin
{ !! obsolete !!
  begin

  with RubberRectRFA do
  begin
    InitSelectedRect();
    RROnOKProcObj := RRectCopySeletedRectProcObj;
    RFrame.RedrawAllAndShow();
  end; // with RubberRectRFA do

  end; //
}
end; // procedure TN_CMREdit3Frame.aEditCopySelectedExecute

procedure TN_CMREdit3Frame.aEditCopyWholeExecute( Sender: TObject );
// Copy Whole Image to Windows Clipboard as raster
begin
  if not EdSlide.GetMapImage.DIBObj.SaveToClipborad() then
end; // procedure TN_CMREdit3Frame.aEditCopyWholeExecute

procedure TN_CMREdit3Frame.aEditPasteInSelectionExecute( Sender: TObject );
// Paste raster from Windows Clipboard in Selected Rect
//var
//  NRes: integer;
begin
{
  begin

  TmpDIB := TN_DIBObj.Create();
  NRes := TmpDIB.LoadFromClipborad();

  if NRes <> 0 then // failed
  begin
    TmpDIB.Free;

    if NRes = 1 then // no Raster in Clipboard
      N_WarnByMessage( 'No Image in Clipboard' )
    else
      ShowStringByTimer( 'Some Clipborad Error!' );

    Exit;
  end; // if NRes <> 0 then // failed

  with RubberRectRFA do
  begin
    //*** Calc SelectedPixRect and RRCurUserRect by TmpDIB size

    SelectedPixRect := IRect( TmpDIB.DIBSize );


    with OriginalDIB.DIBInfo.bmi, SelectedPixRect do
      RRCurUserRect := FRect( 0, 0, 100.0*Right/(biWidth-1),
                                    100.0*Bottom/(biHeight-1) );

    RROnOKProcObj := RRectPasteInSelectedProcObj;
    ActEnabled := True;
    PasteMode  := True;
    RRFlags    := 1; // is checked in MouseMoveProcObj

    RRectMouseMoveProcObj( nil );

    RFrame.RedrawAllAndShow();
    ShowStringByTimer( 'Press Enter(OK), Escape(Cancel) or DoubleClick to Finish' );
  end; // with RubberRectRFA do

  end; //
}
end; // procedure TN_CMREdit3Frame.aEditPasteInSelectionExecute

procedure TN_CMREdit3Frame.aEditPasteWholeExecute( Sender: TObject );
// Clear current Raster and Paste new Whole Raster from Windows Clipboard
var
  NRes: integer;
begin

  begin

  TmpDIB := TN_DIBObj.Create();
  NRes := TmpDIB.LoadFromClipborad();

  if NRes = 0 then // loaded OK
  begin
    with EdSlide.GetMapImage do begin
      DIBObj.Free;
      DIBObj := TmpDIB;
    end;
    AskAndSaveCurrentDIB( True );
  end else // failed
  begin
    TmpDIB.Free;

    if NRes = 1 then // no Raster in Clipboard
      N_WarnByMessage( 'No Image in Clipboard' )
    else
      ShowString( 'Some Clipborad Error!' );
  end; // else // failed

  end; //
end; // procedure TN_CMREdit3Frame.aEditPasteWholeExecute

procedure TN_CMREdit3Frame.aEditCropBySelectionExecute( Sender: TObject );
// Crop Raster by Selected Rect
begin
{ !! obsolete !!
  begin

  with RubberRectRFA do
  begin
    InitSelectedRect();
    RROnOKProcObj := RRectCropBySelectedRectProcObj;
    RFrame.RedrawAllAndShow();
  end; // with RubberRectRFA do

  end; //
}
end; // procedure TN_CMREdit3Frame.aEditCropBySelectionExecute


    //************************** Deb Actions ***********

var //*************** CMS child application in OneSlide mode Commands:
  N_CM1SCComNames: Array [0..3] of TN_StrInt = (
    (SIStr:'Send ANSI String';   SIInt:10 ),
    (SIStr:'Break Connection';   SIInt: 3 ),
    (SIStr:'Stop Main Process';  SIInt: 2 ),
    (SIStr:'Show Handles';       SIInt:-1 )     ); // N_IPCSendSlideData

procedure TN_CMREdit3Frame.aDebCMSOneSlideChildExecute( Sender: TObject );
// Show Inter Process Communication Test Form in OneSlide Child mode
begin
{
  with N_TstIPCForm do
  begin
    Caption := 'CMS Child (OneSlide mode)';
    SetComNames( N_CM1SCComNames );
    Show();
  end; // with N_CMTstIPCForm do
}
end; // procedure TN_CMREdit3Frame.aDebShowIPCFormExecute

procedure TN_CMREdit3Frame.aDebSaveArchAsExecute( Sender: TObject );
// Save Cur Archive in current or another Archive
var
  CurArchDir, NewArchDir: string;
begin
  Caption := 'Centaur Media Suite'; // Form Caption
  CurArchDir := N_ArchDFilesDir(); // with trailing '\'

//  N_MainFormFrame.aFileArchSaveAsExecute( Sender );

  NewArchDir := N_ArchDFilesDir(); // with trailing '\'

  if AnsiSameText( CurArchDir, NewArchDir ) then  // Same Archive, all done
    Exit;

  //***** Process Arch.files dirs

  if not DirectoryExists( CurArchDir ) then // no Source Dir, delete NewArchDir if any
  begin
    if DirectoryExists( NewArchDir ) then
    begin
      K_DeleteFolderFiles( NewArchDir + '\' );
      RemoveDir( NewArchDir );
    end;
  end else // Copy Image Files from OldArch.files dir to NewArch.files
  begin
    ForceDirectories( NewArchDir );
    K_DeleteFolderFiles( NewArchDir + '\' );
    K_CopyFolderFiles( CurArchDir + '\', NewArchDir + '\' );
  end;
end; // procedure TN_CMREdit3Frame.aDebSaveArchAsExecute

procedure TN_CMREdit3Frame.aDebShowNVTreeFormExecute( Sender: TObject );
// Show NVTree Form (for Debug and for Editing UDBase Objects)
begin
//  N_MainFormFrame.aFormsNVtreeExecute( nil );
  N_CreateNVTreeForm( N_CM_MainForm.CMMCurFMainForm ).Show();
end; // procedure TN_CMREdit3Frame.aDebShowNVTreeFormExecute

procedure TN_CMREdit3Frame.aDeb1Execute( Sender: TObject );
// Deb Action #1
//var
//  SrcRect, DstRect: TRect;
begin
  N_TerminateSelfProcObj();
  Exit;
{
  N_IAdd( Format( 'Src.X=%d, Dst.X=%d', [OriginalDIB.DIBSize.X, RFrame.OCanv.CCRSize.X] ));
  N_T1.Start();
  SrcRect := OriginalDIB.DIBRect;
  DstRect := RFrame.OCanv.CurCRect;
  N_StretchRect( OriginalDIB.DIBOCanv.HMDC, SrcRect,
                 RFrame.OCanv.HMDC, DstRect );
  N_T1.SS( '1:1 StretchRect' );

  N_T1.Start();
  SrcRect := OriginalDIB.DIBRect;
  DstRect := Rect( 0, 0, 5*DstRect.Right, 5*DstRect.Bottom );
  N_StretchRect( OriginalDIB.DIBOCanv.HMDC, SrcRect,
                 RFrame.OCanv.HMDC, DstRect );
  N_T1.SS( '1:5 StretchRect' );

  N_T1.Start();
  SrcRect := Rect( 0, 0, DstRect.Right div 5, DstRect.Bottom div 5 );
  DstRect := RFrame.OCanv.CurCRect;
  N_StretchRect( OriginalDIB.DIBOCanv.HMDC, SrcRect,
                 RFrame.OCanv.HMDC, DstRect );
  N_T1.SS( '0.2:1 StretchRect' );
  N_IAdd( '' );
}
end; // procedure TN_CMREdit3Frame.aDeb1Execute

procedure TN_CMREdit3Frame.aDeb2Execute( Sender: TObject );
// Deb Action #2
begin
//  inherited;

end; // procedure TN_CMREdit3Frame.aDeb2Execute


    //************************** TN_CMREdit3Frame Handlers ***********

procedure TN_CMREdit3Frame.FrameMouseDown( Sender: TObject; Button: TMouseButton;
                                           Shift: TShiftState; X, Y: Integer );
var
  Item : TN_UDBase;
  RCount : Integer;

  procedure SelectOneItem();
  begin
    with N_CM_MainForm, Self do
    begin
      if K_CMStudyGetOneSlideByItem( Item ) <> nil then
      begin
        RCount := 1;
        if not (ssCtrl in Shift) then
        begin
          RCount := TN_UDCMStudy(EdSlide).UnSelectAll();
          RCount := RCount + TN_UDCMStudy(EdSlide).SelectItem( Item );
        end
        else
          TN_UDCMStudy(EdSlide).ToggleSlide( Item );
      end
      else
        RCount := TN_UDCMStudy(EdSlide).UnSelectAll();
    end;
  end;

begin
  N_Dump2Str( 'TN_CMREdit3Frame.FrameMouseDown ' + Name );
  EdWillBeFocused := EdSlide <> nil;
  with N_CM_MainForm do
  begin
    CMMCurBeginDragControlPos.X := X;
    CMMCurBeginDragControlPos.Y := Y;
    if Sender is TN_CMREdit3Frame then
    begin
      CMMCurBeginDragControlPos.X := X - RFrame.Left;
      CMMCurBeginDragControlPos.Y := Y - RFrame.Top;
    end;

    CMMCurFThumbsDGrid.DGSetAllItemsState ( ssmUnmark ); // Unmark ThumbFrame Items
    if CMMFActiveEdFrame <> Self then
    begin
    // Switch to another Active Frame
      EdIsodensityRFA.SkipNextMouseDown := CMMFActiveEdFrame.EdIsodensityRFA.ActEnabled; // Skip Mouse Down if Switch Active Frame by Click
      CMMFActiveEdFrame.Ed3FrClearEditContext();
      with CMMFActiveEdFrame do
      begin
        if IfSlideIsStudy then
        begin
          TN_UDCMStudy(EdSlide).UnSelectAll();
          RFrame.RedrawAllAndShow();
        end;
      end; // with CMMFActiveEdFrame do

    end; // if CMMFActiveEdFrame <> Self then

//!!! move to the end
// CMMFSetActiveEdFrame( Self );

  //##!! Drag Code to Close
  //  Exit;
    if EdWillBeFocused           and
       (TControl(Sender).Parent is TN_Rast1Frame) and
       (TN_UDCMBSlide(EdSlide) is TN_UDCMStudy) then
    begin // Study
    //  Select|UnSelect Study Slides
      with EdVObjsGroup, OneSR do
      begin
        RCount := 0;
        if (ssLeft in Shift) then
        begin
          if SRType <> srtNone then
          begin
            Item := TN_UDBase(SComps[SRCompInd].SComp);
            SelectOneItem();
          end
          else
            RCount := TN_UDCMStudy(EdSlide).UnSelectAll();
        end
        else
        if (ssRight in Shift) then
        begin
          RFrame.SearchInAllGroups2( X, Y );
          if SRType <> srtNone then
          begin
            Item := TN_UDBase(SComps[SRCompInd].SComp);
            if TN_UDCMStudy(EdSlide).IfItemSelected( Item ) = 0 then
              SelectOneItem();
          end;
        end;
        if RCount > 0 then
          RFrame.RedrawAllAndShow();
      end;

     // Start Drag Study Slide
      if (ssLeft in Shift) then
      begin
        DragThumbsTimer.Enabled := true;
        CMMCurBeginDragControl := Self;
      end;
    end
    else
    if (ssLeft in Shift)            and
       (Sender is TN_CMREdit3Frame) and
       (Ord(CMMFEdFrLayout) > Ord(eflOne)) then
    begin // Drag Frame Code
//      Self.BeginDrag( false, 1 );
      DragThumbsTimer.Enabled := true;
      CMMCurBeginDragControl := Self;
    end;

    CMMFSetActiveEdFrame( Self );

  end; // with N_CM_MainForm do

//  RFrame.ShowMainBuf();

end; // procedure TN_CMREdit3Frame.FrameMouseDown

//****************************************** TN_CMREdit3Frame.FrameDragOver ***
// DragOver Event Handler
//
procedure TN_CMREdit3Frame.FrameDragOver( Sender, Source: TObject;
                X, Y: Integer; State: TDragState; var Accept: Boolean );
label LExit;
var
  DragIsSlide : Boolean;
  TargetIsStudy : Boolean;
begin
  Accept := FALSE;
  if N_CM_MainForm.CMMCurDragObject = nil then Exit;

  DragIsSlide := N_CM_MainForm.CMMCurDragObject is TN_UDCMSlide;
  TargetIsStudy := IfSlideIsStudy() and (N_CM_MainForm.CMMCurDragObjectsList.Count <= 1);

  if not TargetIsStudy and
     DragIsSlide       and
     (cmsfIsMediaObj in TN_UDCMSlide(N_CM_MainForm.CMMCurDragObject).P.CMSDB.SFlags) then
    Exit; // Skip Drop Video on Frame (only on study)

  Accept := Self <> Source;

  if not TargetIsStudy or // Target Frame contains opened Study
     not DragIsSlide then // Drag is Frame or Study
  begin
// Target Frame should receive BSlide or Target Frame position should be switched
LExit :
     TFrame(N_CM_MainForm.CMMCurBeginDragControl).DragCursor := crDrag;
     N_CM_MainForm.CMMRedrawDragOverComponent( 0 );
     Exit;
  end;

  //  Check Draged Slide on Study details
  if Sender is TN_CMREdit3Frame then
  begin
    X := X - RFrame.Left;
    Y := Y - RFrame.Top;
  end;

{
  if (X < 0) or (X >= RFrame.Width) or
     (Y < 0) or (Y >= RFrame.Height) then goto LExit;
}

  if Y < 0 then goto LExit;
  Accept := FALSE;
  if (X < 0) or (X >= RFrame.Width) or
     (Y >= RFrame.Height) then goto LExit;

  RFrame.SearchInAllGroups2( X, Y );

  with N_CM_MainForm, EdVObjsGroup, OneSR do
  begin
    Accept := (SRType <> srtNone) and
              (K_CMStudyGetOneSlideByItem( TN_UDBase(SComps[SRCompInd].SComp) ) <> CMMCurDragObject);
    if Accept then
    begin
    // Exists Component Under Cursor - Clear Previouse and Show New
       TFrame(N_CM_MainForm.CMMCurBeginDragControl).DragCursor := crMultiDrag;
       if CMMCurDragOverComp <> SComps[SRCompInd].SComp then
       begin
         CMMRedrawDragOverComponent( 0 ); // Clear Previouse
         CMMCurDragOverComp := SComps[SRCompInd].SComp;
         CMMRedrawDragOverComponent( 1 ); // Show New Component under Cursor
       end
       else
       if CMMCurDragOverComp = nil then
         CMMRedrawDragOverComponent( 1 ); // Show New Component under Cursor
    end
    else
    begin
    // No Component Under Cursor - Clear Previouse
      CMMRedrawDragOverComponent( 0 );
    end;
  end;
end; // procedure TN_CMREdit3Frame.FrameDragOver

//******************************************* TN_CMREdit3Frame.FrameEndDrag ***
// EndDrag Event Handler
//
procedure TN_CMREdit3Frame.FrameEndDrag( Sender, Target: TObject; X,Y: Integer );
begin
{
N_s := Target.ClassName;
N_s := TControl(Target).Name;
N_s := Sender.ClassName;
N_s := TControl(Sender).Name;
exit;
}
  N_Dump2Str( 'TN_CMREdit3Frame.FrameEndDrug ' + Name );
  with N_CM_MainForm do
  begin
    if Target = nil then
    begin
      CMMRedrawDragOverComponent( 0 ); // Clear Previouse Drag Over Component
      CMMCurDragObject := nil;
      CMMCurBeginDragControl := nil;
      CMMCurDragObjectsList.Clear;
      Exit;
    end;
    while not (Target is TN_CMREdit3Frame) do Target := TControl(Target).Parent;

    if CMMCurDragOverComp <> nil then
    begin // Mount Slide to Study
      CMMStudyEndDrug( FALSE );
    end
    else
    if CMMCurDragObject is TN_UDCMBSlide then
    begin
      CMMSlideEndDrag( TN_UDCMSlide(CMMCurDragObject), TN_CMREdit3Frame(Target) );
    end
    else
    begin
      CMMRedrawDragOverComponent( 0 );
      if CMMSwitchEdframes( TN_CMREdit3Frame(Sender), TN_CMREdit3Frame(Target),
                                                   [uieflSkipFramesResize] ) then
      begin
        if N_KeyIsDown( VK_SHIFT ) then
          TN_CMREdit3Frame(Target).EdFreeObjects();
        CMMCurBeginDragControl := nil;
        CMMCurDragObject := nil;
        CMMCurDragObjectsList.Clear;
      end
      else
        N_Dump1Str( 'TN_CMREdit3Frame.FrameEndDrag !!! switch frames error ' + Name );
    end;
  end;
end; // procedure TN_CMREdit3Frame.FrameEndDrag

procedure TN_CMREdit3Frame.aObjTstExecute( Sender: TObject );
begin
//
end; // procedure TN_CMREdit3Frame.aObjTstExecute

//******************************************* TN_CMREdit3Frame.FinishEditingClick ***
// FinishEditing Click Handler
//
procedure TN_CMREdit3Frame.FinishEditingClick(Sender: TObject);
begin
   N_CMResForm.AddCMSActionStart( N_CMResForm.aEditCloseCurActive );
   N_CMResForm.aEditCloseCurActiveExecute( Sender );
   N_CMResForm.AddCMSActionFinish( N_CMResForm.aEditCloseCurActive );
end; // procedure TN_CMREdit3Frame.FinishEditingClick

//******************************************* TN_CMREdit3Frame.FrameMouseMove ***
// Frame Mouse Move Handler
//
procedure TN_CMREdit3Frame.FrameMouseMove(Sender: TObject;
                                          Shift: TShiftState; X, Y: Integer);
begin
  N_CM_MainForm.CMMHideFlashlightIfNeeded()
end; // procedure TN_CMREdit3Frame.FrameMouseMove

//******************************************* TN_CMREdit3Frame.FrameMouseMove ***
// Frame Mouse Double Click Handler
//
procedure TN_CMREdit3Frame.FrameDblClick(Sender: TObject);
var
  Item : TN_UDBase;
  Slide : TN_UDCMSlide;
begin

  N_Dump2Str( 'TN_CMREdit3Frame.FrameDblClick ' + Name );
  if K_CMSFullScreenForm = nil then
  begin
    if (TControl(Sender).Parent is TN_Rast1Frame) and
       IfSlideIsStudy() then
    begin // Study
      with EdVObjsGroup, OneSR do
      begin
        if SRType <> srtNone then
        begin
          N_CM_MainForm.DragThumbsTimer.Enabled := FALSE;
          Item := TN_UDBase(SComps[SRCompInd].SComp);
          Slide := K_CMStudyGetOneSlideByItem( Item );
          if Slide <> nil then
          begin
          // Open Study Slide
//            with N_CMResForm do
//              aMediaAddToOpenedExecute( aMediaAddToOpened );
            N_CM_MainForm.ThumbsRFrameDblClick(nil);
//            N_CM_MainForm.CMMSlideEndDrag( Slide, nil, [uieflSkipActiveEdFrame] ); // Previouse Version
            if EdSlide = SLide then // Slide Was Opened in Current Frame
              EdMoveVObjRFA.SkipNextMouseDown := TRUE;
            Exit;
          end; // if Slide <> nil then
        end; // if SRType <> srtNone then
      end; // with EdVObjsGroup, OneSR do
      // Open Study FullScreen Mode
      N_CMResForm.aEditFullScreenExecute( N_CMResForm.aEditFullScreen );
    end // if Study is Opened
    else
      RFrame.PaintBoxDblClick(Sender);
  end
  else
  begin
  // Close Study FullScreen Mode
    N_CMResForm.aEditFullScreenCloseExecute( N_CMResForm.aEditFullScreenClose );
  end;

end; // procedure TN_CMREdit3Frame.FrameDblClick

//****************  TN_CMREdit3Frame class public methods  ************

procedure TN_CMREdit3Frame.FrameActivate( Sender: TObject );
// just call RFrame.OnActivateFrame to set N_ActiveRFrame variable
// (OnActivate Form event handler)
// not used!!!
begin
  RFrame.OnActivateFrame();
end; // procedure TN_CMREdit3Frame.FrameActivate


// not used!!!
{
procedure TN_CMREdit3Frame.FrameClose( Sender: TObject; var Action: TCloseAction);
var
  NTimes, MaxNTimes: integer;
  label WaitForResponse;
begin
  if (N_CMSAppType = cmsatOneSlideChild) and // Self is Main Form,
          N_IPCObj.IPCIsActive then        // Break Connection before Closing Self
  begin
    N_IPCObj.IPCPutCommand( N_IPCBreakConnection, 0, 0, 0, 0, nil, 0, 0, ipcatPermMem );
    NTimes := 0;
    MaxNTimes := Round( N_IPCObj.IPCMaxWaitTime / N_IPCSleepTime );

    WaitForResponse: //*** Wait for Main Process response to "Break Connection" Command

    if N_IPCObj.IPCPSelfCommand^ > 0 then // not responded yet
    begin
      Inc( NTimes );

      if NTimes < MaxNTimes then
      begin
        Sleep( N_IPCSleepTime );
        Application.ProcessMessages; // may be not really needed
        goto WaitForResponse;
      end else
      begin
        N_IPCObj.IPCTestForm.AddInfoStr( 'No response from Main Process!' );
        N_IPCObj.IPCProcessLostConnection( 4 );
      end;
    end; // if N_CMIPCObj.IPCPSelfCommand^ > 0 then // not responded yet

  end; // if (N_CMSAppType = cmsatOneSlideChild) and // Self is Main Form,

//  OriginalDIB.Free;
  N_SetCursorType( 0 );
  Inherited;
end; // procedure TN_CMREdit3Frame.FrameClose
}

//********************************************* TN_CMREdit3Frame.ShowString ***
// Show String in Main Form StatusBar
//
procedure TN_CMREdit3Frame.ShowString( AStr: string );
begin
  N_CM_MainForm.CMMFShowString( AStr );
end; // procedure TN_CMREdit3Frame.ShowString

//************************************** TN_CMREdit3Frame.ShowStringByTimer ***
// Show String in Main Form StatusBar and Start StatusBarTimer to preseve it
//
procedure TN_CMREdit3Frame.ShowStringByTimer( AStr: string );
begin
  N_CM_MainForm.CMMFShowStringByTimer( AStr );
end; // procedure TN_CMREdit3Frame.ShowStringByTimer

//********************************* TN_CMREdit3Frame.UpdateBrighByTwoPoints ***
// Update Brightnes of EdSlide Image by given Two Points and
// Draw changed Image in RFrame
//
procedure TN_CMREdit3Frame.UpdateBrighByTwoPoints( AP1, AP2: TFPoint );
//var
//  i, NX, NY, NumRGBValues: integer;
begin
{
  begin

  with EdSlide do
  begin
    with EdMapUDDIB.DIBObj do
    begin
      NX := DIBInfo.bmi.biWidth;
      NY := DIBInfo.bmi.biHeight;
      NumRGBValues := 3*NX*NY;

      Move( OriginalDIB.PRasterBytes^, PRasterBytes^, DIBInfo.bmi.biSizeImage );

      GetPixRGBValuesRect( RGBValues, 0, 0, NX-1, NY-1 );

      //***** CReate XLat Table for converting Brightness by given AP1, AP2 points
      N_CreateXLatTableBy2P( XLatTable, AP1, AP2 );

      for i := 0 to NumRGBValues-1 do // Convert Brightness in RGBValues Array
        RGBValues[i] := XLatTable[RGBValues[i]];

      //***** write converted RGBValues back
      SetPixRGBValuesRect( RGBValues, 0, 0, NX-1, NY-1 );
    end; // with EdMapUDDIB.DIBObj do

    RFrame.RedrawAllAndShow();

//    if Assigned(ResBrighHist) then // Redraw Resulting Histogramm if needed
//      ResBrighHist.RFrame.RedrawAllAndShow();

  end; // with EdSlide do

  end; //
}
end; // procedure TN_CMREdit3Frame.UpdateBrighByTwoPoints

//*************************************** TN_CMREdit3Frame.UpdateBrighByGamma ***
// Update Brightnes by given AGamma Coef and Draw SelideToEdit in RFrame
//
procedure TN_CMREdit3Frame.UpdateBrighByGamma( AGamma: double );
//var
//  i, NX, NY, NumRGBValues: integer;
begin
{
  begin

  with EdSlide do
  begin
    with EdMapUDDIB.DIBObj do
    begin
      ShowString( Format( 'Gamma = %5.2f', [AGamma] ) );
      NX := DIBInfo.bmi.biWidth;
      NY := DIBInfo.bmi.biHeight;
      NumRGBValues := 3*NX*NY;

      Move( OriginalDIB.PRasterBytes^, PRasterBytes^, DIBInfo.bmi.biSizeImage );

      GetPixRGBValuesRect( RGBValues, 0, 0, NX-1, NY-1 );

      //***** CReate XLat Table for converting Brightness by given AGamma
      N_CreateXLatTableByGamma( XLatTable, AGamma );

      for i := 0 to NumRGBValues-1 do // Convert Brightness in RGBValues Array
        RGBValues[i] := XLatTable[RGBValues[i]];

      //***** write converted RGBValues back
      SetPixRGBValuesRect( RGBValues, 0, 0, NX-1, NY-1 );
    end; // with EdMapUDDIB.DIBObj do

    RFrame.RedrawAllAndShow();

//    if Assigned(ResBrighHist) then // Redraw Resulting Histogramm if needed
//      ResBrighHist.RFrame.RedrawAllAndShow();

  end; // with EdSlide do
  end; //
}
end; // procedure TN_CMREdit3Frame.UpdateBrighByGamma

//********************************** TN_CMREdit3Frame.RRectMouseMoveProcObj ***
// Show Selected Rect Image Pixel coords
// (used as TN_RubberRectRFA.RROnMouseMoveProcObj)
//
procedure TN_CMREdit3Frame.RRectMouseMoveProcObj( ARFAction: TObject );
//var
//  OriginalFullRect, ClipbrdFullRect: TRect;
begin
{
  begin

  SelectedPixRect := GetSelectedPixRect();

  if (RubberRectRFA.RRFlags <> 0) then
  begin

    if PasteMode then // Paste TmpDIB into Selected rect
    begin
      OriginalFullRect := IRect( OriginalDIB.DIBSize );

      N_CopyRect( EdMapUDDIB.DIBObj.DIBOCanv.HMDC, Point(0,0),
                  OriginalDIB.DIBOCanv.HMDC, OriginalFullRect );

      ClipbrdFullRect := IRect( TmpDIB.DIBSize );

      N_StretchRect( EdMapUDDIB.DIBObj.DIBOCanv.HMDC, SelectedPixRect,
                     TmpDIB.DIBOCanv.HMDC, ClipbrdFullRect );
    end; // if PasteMode then // Paste TmpDIB into Selected rect

    with SelectedPixRect do
      ShowString( Format( 'UpperLeft = %d, %d;  Size = %d, %d',
                                 [Left, Top, Right-Left+1, Bottom-Top+1] ) );
  end;
  end; //
}
end; // procedure TN_CMREdit3Frame.RRectMouseMoveProcObj

//************************************* TN_CMREdit3Frame.RRectCancelProcObj ***
// Cancel current operation (CopySelected, PasteToSelected or Crop)
// (used as TN_RubberRectRFA.RROnCancelProcObj)
//
procedure TN_CMREdit3Frame.RRectCancelProcObj( ARFAction: TObject );
begin
{ !! obsolete !!
  PasteMode := False;
  RubberRectRFA.ActEnabled := False;
  Rframe.RedrawAllAndShow();

//  N_CM_MainForm.CMMainStatusBarTimer.Enabled := False; // Stop Timer (initialization may not finished yet)
  ShowStringByTimer( 'Operation Cancelled!' );
}
end; // procedure TN_CMREdit3Frame.RRectCancelProcObj

//*************************** TN_CMREdit3Frame.RRectCopySelectedRectProcObj ***
// Copy Selected Rect content to Windows Clipboard
// (used as TN_RubberRectRFA.RROnOKProcObj)
//
procedure TN_CMREdit3Frame.RRectCopySeletedRectProcObj( ARFAction: TObject );
begin
{ !! obsolete !!
  begin

  SelectedPixRect := GetSelectedPixRect();

  TmpDIB := TN_DIBObj.Create( EdMapUDDIB.DIBObj, SelectedPixRect, pf24bit );
  TmpDIB.SaveToClipborad();
  TmpDIB.Free;

  RubberRectRFA.ActEnabled := False;
  Rframe.RedrawAllAndShow();
  ShowStringByTimer( 'Image copied to Clipboard' );

  end; //
}
end; // procedure TN_CMREdit3Frame.RRectCopySelectedRectProcObj

//**************************** TN_CMREdit3Frame.RRectPasteInSelectedProcObj ***
// Paste in Selected Rect content from Windows Clipboard
// (used as TN_RubberRectRFA.RROnOKProcObj)
//
procedure TN_CMREdit3Frame.RRectPasteInSelectedProcObj( ARFAction: TObject );
begin
{ !! obsolete !!
  begin

  RubberRectRFA.ActEnabled := False;
  AskAndSaveCurrentDIB( True );
//  AskAndSaveCurrentDIB( False, 'Image Pasted in Selected Rect' );

  end; //
}
end; // procedure TN_CMREdit3Frame.RRectPasteInSelectedProcObj

//************************* TN_CMREdit3Frame.RRectCropBySelectedRectProcObj ***
// Copy Selected Rect content to Windows Clipboard
// (used as TN_RubberRectRFA.RROnOKProcObj)
//
procedure TN_CMREdit3Frame.RRectCropBySelectedRectProcObj( ARFAction: TObject );
//var
//  NDIB : TN_DIBObj;
begin
{ !! obsolete !!
  begin

  SelectedPixRect := GetSelectedPixRect();

//  EdMapUDDIB.DIBObj.Free;
//  EdMapUDDIB.DIBObj := TN_DIBObj.Create( OriginalDIB, SelectedPixRect, pf24bit );

  NDIB := TN_DIBObj.Create( EdMapUDDIB.DIBObj, SelectedPixRect, pf24bit );
  EdMapUDDIB.DIBObj.Free;
  EdMapUDDIB.DIBObj := NDIB;

  RubberRectRFA.ActEnabled := False;

  AskAndSaveCurrentDIB( True );

  end; //
}
end; // procedure TN_CMREdit3Frame.RRectCropBySelectedRectProcObj


//********************************** TN_CMREdit3Frame.RSegmMouseMoveProcObj ***
// Process MouseDown in Calibrate and Measure modes
//   In Measure mode Show RubberSegm Size and it's Size
//     (Distance between RSUPoint1 and Cursor) in mm
//   In Calibrate mode just Show RubberSegm
// (used as TN_RubberSegmRFA.RSOnMouseMoveProcObj)
//
procedure TN_CMREdit3Frame.RSegmMouseMoveProcObj( ARFAction: TObject );
//var
//  Distancemm, FloatPixDX, FloatPixDY: double;
begin
{ !! obsolete !!
  begin

  with RubberSegmRFA, RFrame do
  begin
    if RSState = rsrfaDrawSegm then // Show RubberSegm over the image
    begin
      Redraw();       // Update MainBuf (Draw Main Content)
      RedrawAction(); // Draw RubberSegm
      ShowMainBuf();  // Update PaintBox
    end; // if RSState = rsrfaDrawSegm then // Show RubberSegm over the image

    if (RSegmActType = cmrfarsMeasure) and (RSState = rsrfaDrawSegm) then // Show Distance
    begin
      FloatPixDX := EdMapUDDIB.DIBObj.DIBSize.X * (RSUPoint1.X-CCUser.X) / N_RectWidth( N_CMDIBURect );
      FloatPixDY := EdMapUDDIB.DIBObj.DIBSize.Y * (RSUPoint1.Y-CCUser.Y) / N_RectHeight( N_CMDIBURect );
      Distancemm := Sqrt(FloatPixDX*FloatPixDX + FloatPixDY*FloatPixDY) /
                                                 EdSlide.P()^.CMSDB.PixPermm;
      RFrActionFlags := RFrActionFlags - [rfafShowCoords];
      Self.ShowString( Format( 'Distance = %.2f mm', [Distancemm] ));
    end;
  end; // with RubberSegmRFA do

  end; //
}
end; // procedure TN_CMREdit3Frame.RSegmMouseMoveProcObj

//********************************** TN_CMREdit3Frame.RSegmMouseDownProcObj ***
// Process MouseDown in Calibrate and Measure modes
// (used as TN_RubberSegmRFA.RSOnMouseDownProcObj)
//
procedure TN_CMREdit3Frame.RSegmMouseDownProcObj( ARFAction: TObject );
//var
//  StrDist: string;
//  Distmm, FloatPixDX, FloatPixDY: double;
//  Label Cancel, GetDistancemm, Finish;
begin
{ !! obsolete !!
  begin

  with RubberSegmRFA, RFrame do
  begin
    if RSegmActType = cmrfarsCalibrate then //***** Calibrate Mode
    begin
      if RSState = rsrfaCanceled then
      begin
        Cancel: //********

        ActEnabled := False;
        ShowStringByTimer( 'Calibrating Canceled' );
        goto Finish;
      end;

      if RSState = rsrfaFinished then // calc and save Calibaring coef
      begin
        //***** Get enetered RubberSegm Size in mm from User

        GetDistancemm: //*************
        StrDist := ' ? ';
        if not N_EditString( StrDist, 'Enter Distance in mm :', 300, 'Distance:' ) then
          goto Cancel;

        Distmm := N_ScanDouble( StrDist );

        if (Distmm <= 0) or (Distmm > 400) then
        begin
          ShowMessage( 'Enter Correct distance' );
          goto GetDistancemm;
        end;

        //***** Distmm is OK, calc CMSPixPermm
        FloatPixDX := EdMapUDDIB.DIBObj.DIBSize.X * (RSUPoint1.X-RSUPoint2.X) / N_RectWidth( N_CMDIBURect );
        FloatPixDY := EdMapUDDIB.DIBObj.DIBSize.Y * (RSUPoint1.Y-RSUPoint2.Y) / N_RectHeight( N_CMDIBURect );

        with EdSlide.P()^ do
        begin
          CMSDB.PixPermm := Sqrt(FloatPixDX*FloatPixDX + FloatPixDY*FloatPixDY) / Distmm;
        end;

        ShowStringByTimer( 'Calibrating Finished' );

        ActEnabled := False;
        goto Finish;
      end; // if RSState = rsrfaFinished then // calc and save Calibaring coef

      if RSState = rsrfaDrawSegm then Exit; // nothing to do

    end else if RSegmActType = cmrfarsMeasure then //***** Measure Mode
    begin
      if RSState = rsrfaCanceled then
      begin
        ActEnabled := False;
        ShowStringByTimer( 'Measuring Canceled' );
        goto Finish;
      end;

      if RSState = rsrfaFinished then
      begin
        ShowStringByTimer( 'Click Base Point to measure Distance' );
        goto Finish;
      end;

      if RSState = rsrfaDrawSegm then Exit; // nothing to do

      goto Finish;
    end;

    Finish: //*** Finish using RubberSegm in both Calibrate and Measure modes

    RSState := rsrfaBeforeP1;
    RedrawAllAndShow();
  end; // with RubberSegmRFA, RFrame do

  end; //
}
end; // procedure TN_CMREdit3Frame.RSegmMouseDownProcObj

//*********************************** TN_CMREdit3Frame.RSegmDrawSegmProcObj ***
// Draw current RubberSegment (from RSUPoint1 to cursor) in rsrfaDrawSegm State
// (used as TN_RubberSegmRFA.RSOnRedrawProcObj)
//
procedure TN_CMREdit3Frame.RSegmDrawSegmProcObj( ARFAction: TObject );
begin
{ !! obsolete !!
  begin

  with RubberSegmRFA, RFrame do
  begin
    if RSState <> rsrfaDrawSegm then Exit;

    OCanv.ConSegm[0] := RSUPoint1;
    OCanv.ConSegm[1] := CCUser;

    if RSegmActType = cmrfarsCalibrate then
    begin
      OCanv.DrawUserPolyline2( OCanv.ConSegm, $00FF00, 3 );
    end else if RSegmActType = cmrfarsMeasure then
    begin
      OCanv.DrawUserPolyline2( OCanv.ConSegm, $FFFF00, 3 );
    end;

  end; // with RubberSegmRFA, RFrame do
  end; //
}
end; // procedure TN_CMREdit3Frame.RSegmDrawSegmProcObj


//********************************** TN_CMREdit3Frame.ECompsDblClickProcObj ***
// EditComps Action OnDblClick Handler
// (used as TN_EditCompsRFA.ECOnDblClickProcObj)
//
// Edit Object if ECPosFlags <> 0 or finish Editing if ECPosFlags = 0
//
procedure TN_CMREdit3Frame.ECompsDblClickProcObj( ARFAction: TObject );
//var
//  CurComp: TN_UDCompVis;
begin
end; // procedure TN_CMREdit3Frame.ECompsDblClickProcObj

//******************************** TN_CMREdit3Frame.ECompsRightClickProcObj ***
// EditComps Action OnRightClick Handler
// (used as TN_EditCompsRFA.ECOnRightClickProcObj)
//
// Show pmObjectsMenu with PopupMenuClick as OnClick handler for all Menu Items
//
procedure TN_CMREdit3Frame.ECompsRightClickProcObj( ARFAction: TObject );
var
  ScreenPos: TPoint;
begin
//  with TN_CMMain4Form(CMMainForm), TN_CMMain4Form(CMMainForm).ActiveEditorFrame do
  begin

  with RFrame do
  begin
//    mmiObjectsClick( nil ); // prepare pmObjectsMenu MenuItems

    ScreenPos := PaintBox.ClientToScreen( Point( CCDST.X, CCDST.Y ));
//    pmCMMainObjectsMenu.Popup( ScreenPos.X, ScreenPos.Y+5 );
  end; // with RFrame do

  end; // 
end; // procedure TN_CMREdit3Frame.ECompsRightClickProcObj

//********************************************* TN_CMREdit3Frame.U2ImagePix ***
// Convert User Coords (N_CMDIBURect) to Image Pixel Coords
//
function TN_CMREdit3Frame.U2ImagePix( AUCoords: TDPoint ): TPoint;
begin
  with Result, N_CMDIBURect, EdSlide.GetMapImage.DIBObj do
  begin
    X := Round( (DIBInfo.bmi.biWidth-1) * AUCoords.X / (Right-Left) );
    Y := Round( (DIBInfo.bmi.biHeight-1)* AUCoords.Y / (Bottom-Top) );
  end;
end; // function TN_CMREdit3Frame.U2ImagePix

//*************************************** TN_CMREdit3Frame.GetCurPixelColor ***
// Return Color of Pixel currently under Cursor
//
function TN_CMREdit3Frame.GetCurPixelColor(): integer;
var
  PixImageCoords: TPoint;
  PixColors: TN_IArray;
begin
  with RFrame, EdSlide.GetMapImage.DIBObj do begin
    PixImageCoords.X := Round( CCBuf.X * (DIBSize.X - 1) / (RFLogFramePRect.Right) );
    PixImageCoords.Y := DIBSize.Y - 1 - Round( CCBuf.Y * (DIBSize.Y - 1) / (RFLogFramePRect.Bottom) );
  end;

//  PixImageCoords.X := 255;
//  PixImageCoords.Y := 255;

  with PixImageCoords do
    EdSlide.GetCurrentImage().DIBObj.GetPixColorsVector( PixColors, X, Y, X, Y );

  Result := PixColors[0];
  N_CM_MainForm.CMMFShowString( Format( 'X,Y: %3d,%3d; I: $%6x',
                   [PixImageCoords.X, PixImageCoords.Y, Result] ) );
end; // function TN_CMREdit3Frame.GetCurPixelColor

//************************************* TN_CMREdit3Frame.GetSelectedPixRect ***
// Return Selected Image Pixel Rect
//
function TN_CMREdit3Frame.GetSelectedPixRect(): TRect;
begin

  with EdRubberRectRFA.RRCurUserRect do
  begin
    Result.TopLeft     := U2ImagePix( DPoint(TopLeft) );
    Result.BottomRight := U2ImagePix( DPoint(BottomRight) );
  end;

end; // function TN_CMREdit3Frame.GetSelectedPixRect

//**************************************** TN_CMREdit3Frame.GetVisibleURect ***
// Return User Coords of currently Visible Rect
//
function TN_CMREdit3Frame.GetVisibleURect(): TFRect;
begin
  Result := N_AffConvI2FRect1( RFrame.RFSrcPRect, RFrame.OCanv.P2U );
  N_FRectAnd( Result, N_CMDIBURect );
end; // function TN_CMREdit3Frame.GetVisibleURect

//***************************************** TN_CMREdit3Frame.GetNewObjURect ***
// Return User Coords Rect for New Object:
// in the middle of currently Visible Rect if ASender<>nil or under cursor
//
function TN_CMREdit3Frame.GetNewObjURect( ASender: TObject ): TFRect;
begin
  if ASender = nil then // cursor is over the Image (called from RightClick PopupMenu)
  begin                 // return User Rect near the cursor
    Result := N_RectScaleA( GetVisibleURect(), 0.2, RFrame.CCUser );
  end else // cursor is not over the Image (called from Main Menu)
  begin    // return User Rect in the middle of currently Visible Rect
    Result := N_RectScaleR( GetVisibleURect(), 0.2, DPoint(0.5,0.5) );
  end;
end; // function TN_CMREdit3Frame.GetNewObjURect

//*************************************** TN_CMREdit3Frame.InitSelectedRect ***
// Initialize Selected Rect by 1/3 of currently visible Image fragment
//
procedure TN_CMREdit3Frame.InitSelectedRect();
//var
//  URect: TFRect;
begin
{ !! obsolete !!
  with RubberRectRFA, RFrame do
  begin
    URect := GetVisibleURect();
    RRCurUserRect := N_RectScaleR( URect, 0.33, DPoint(0.5,0.5) );
    ActEnabled := True;
  end; // with RubberRectRFA, RFrame do

  ShowStringByTimer( 'Press Enter(OK), Escape(Cancel) or DoubleClick to Finish' );
}
end; // procedure TN_CMREdit3Frame.InitSelectedRect

{
//******************************************* TN_CMREdit3Frame.InitObjComps ***
// Enabled EditCompsRFA, set ECNumComps and fill ECComps by Object Components
//
procedure TN_CMREdit3Frame.InitObjComps();
var
  i, j: integer;
begin

  with EditCompsRFA do
  begin
    ECNumComps := EdMapRoot.DirLength() - 1;

    if Length(ECComps) < ECNumComps then
    begin
      SetLength( ECComps,     ECNumComps );
      SetLength( ECCurRects,  ECNumComps );
      SetLength( ECBaseRects, ECNumComps );
    end;

    j := 0;
    for i := 0 to ECNumComps-1 do // along all Object Components
    begin
      ECComps[j] := TN_UDCompVis(EdMapRoot.DirChild( i+1 ));
      if ECComps[j] <> nil then Inc( j );
    end;

    ECNumComps := j; // Number of existing Objects
    ECSavedSrcPRect.Left := N_NotAnInteger; // to force recalculating Pix Coords
  end; // with EditCompsRFA do

end; // procedure TN_CMREdit3Frame.InitObjComps
}

//***************************************** TN_CMREdit3Frame.ShowWholeImage ***
// Update MapRoot Size by current Image Size and Show Whole Image (Whole EdMapUDDIB)
//
//    Parameters
// ASkipShow - if TRUE then Redaw without Show should be done
//
procedure TN_CMREdit3Frame.ShowWholeImage( );
var
  NewSize : TFPoint;
//  MapRoot : TN_UDCompVis;
begin
  NewSize := FPoint( EdSlide.GetMapImage.DIBObj.DIBSize );
  with EdSlide.GetMapRoot().PCCS()^ do begin
    SRSize := NewSize;
//    RFrame.RVCTFrInit( MapRoot );
    RFrame.aFitInWindowExecute( nil );
  end;
end; // procedure TN_CMREdit3Frame.ShowWholeImage

//******************************************** TN_CMREdit3Frame.InitSlideView  ***
// Update all needed Self fields and Objects frame Slide
// and show it
// (should be used in after Slide Data Update )
//
function TN_CMREdit3Frame.InitSlideView ( ) : Boolean;
var
  PSkipSelf : PByte;
  WaitShowBound : Double;
  FPixPermm : Float;
//  WMes, FName : string;
//  LoadMapRootError : Boolean;
begin
///////////////////////////////////////////
//  Init Frame SLide View
//
  Result := FALSE;
  if TN_UDCMBSlide(EdSlide) is TN_UDCMStudy then
  begin  // Study
    with TN_UDCMStudy(EdSlide), P^ do
    begin
      Include( CMSRFlags, cmsfIsOpened );
      ImgClibrated.Visible := FALSE;
      FrameLeftCaption.Caption  := K_DateTimeToStr( CMSDTCreated, 'dd"/"mm"/"yy' );
      FrameRightCaption.Caption := CMSSourceDescr;
      //*** Study View Rebuild
      N_Dump2Str( format('Init 1 Study View ID=%s SampleID=%d', [ObjName, CMSStudySampleID] ) );
      TN_UDCMStudy(EdSlide).UnSelectAll();
      RebuildSlideView( );
      N_Dump2Str( 'Init 2 Study View ID=' + ObjName );
//      RebuildStudySearchList( );
//      N_Dump2Str( 'Init 3 Study View ID=' + ObjName );
    end;
    EdUndoBuf := nil;
  end
  else
  begin // Slide
    //!!! 28-02-2013 it should be done before RebuildSlideView( );
    with EdSlide, P^, CMSDB do
    begin
      N_Dump2Str( format( 'Init 0 Fr=%s Slide View ID=%s', [Name, ObjName] ) );
      if K_CMEDAccess.EDACheckSlideMedia( EdSlide ) = K_edFails then Exit;
      Include( CMSRFlags, cmsfIsOpened );

      N_Dump2Str( 'Init 1 Slide View ID=' + ObjName );
      PrepVObjs( );
      RebuildAllMLineTexts();
      PSkipSelf := GetPMeasureRootSkipSelf();
      N_CMResForm.aObjShowHide.Checked := not (cmsfHideDrawings in CMSRFlags);
      if N_CMResForm.aObjShowHide.Checked then
        PSkipSelf^ := 0
      else
        PSkipSelf^ := 1;
      ImgClibrated.Visible := cmsfUserCalibrated in CMSDB.SFlags;
      ImgHasDiagn.Visible := EdSlide.P.CMSDiagn <> '';
    // Set Show WaitState Flag for showing WAIT_INFO for large images
      WaitShowBound := BytesSize / N_CPUFrequency / ((PixBits + 7) shr 3);
      CMSShowWaitStateFlag := WaitShowBound > 0.00045;

      //*** Correct AutoCalibrate Flag
      if not ImgClibrated.Visible           and
         not (cmsfAutoCalibrated in SFlags) and
         not (cmsfProbablyCalibrated in SFlags) then
      begin
        FPixPermm := Round( 72*100/2.54 ) / 1000;
        if FPixPermm <> PixPermm then
        begin
          FPixPermm := Round( 96*100/2.54 ) / 1000;
          if FPixPermm <> PixPermm then
            Include(SFlags, cmsfProbablyCalibrated); // for old slides
  //          Include(SFlags, cmsfAutoCalibrated); // for old slides
        end;
      end;
      FrameLeftCaption.Caption  := K_CMSlideViewCaption( EdSlide );

      Ed3FrDumpFrameRightCaption( 'Before change' );
      FrameRightCaption.Caption := K_CMSlideFilterText( EdSlide );
      Ed3FrDumpFrameRightCaption( 'After change' );

      //*** Slide Image Rebuild
      N_Dump2Str( 'Init 2 Slide View ID=' + ObjName );
  //    RebuildMapImageByDIB( ); // May be not needed - because it was already done in GetMapRoot()
  //    N_Dump2Str( 'Init 3 Slide View ID=' + ObjName );

     //!!! GetCMSUndoBuf should be call before RebuildSlideView
     // because MapRoot can be rebuild inside GetCMSUndoBuf,
     // but new MapRoot is needed in RebuildSlideView
      EdUndoBuf := EdSlide.GetCMSUndoBuf;
      N_Dump2Str( 'Init 3 Slide View ID=' + ObjName );
      RebuildSlideView( TRUE );

      N_Dump2Str( 'Init 4 Slide View ID=' + ObjName );
      InitViewAutoScale();
      N_Dump2Str( 'Init 5 Slide View ID=' + ObjName );
//      RebuildVObjsSearchList( );
    end;
  //*** end of Slide Image Rebuild and Redraw Time
    if (Self = N_CM_MainForm.CMMFActiveEdFrame) then
    begin
      N_CM_MainForm.CMMFSetActiveEdFrame(Self);
    end;
  end;
  RebuildVObjsSearchList( );
  N_Dump2Str( 'Fin Init Slide View ID=' + EdSlide.ObjName );
  EdSlide.CMSRFrame := RFrame;
  Result := TRUE;

//
//  end of Init Frame SLide View
///////////////////////////////////////////
end; // procedure TN_CMREdit3Frame.InitSlideView

//******************************************** TN_CMREdit3Frame.SetNewSlide ***
// Update all needed Self fields and Objects by new given ANewSlide
// and show it
// (should be used in N_CreateCMREdit3Frame and after Slide was replaced)
//
function TN_CMREdit3Frame.SetNewSlide( ANewSlide: TN_UDCMSlide ) : Boolean;
var
//  PSkipSelf : PByte;
//  WaitShowBound : Double;
  HistForm : TForm;
begin
  Result := FALSE;
  if EdSlide = ANewSlide then Exit;
  if EdSlide <> nil then
  begin
    HistForm := nil;
    if ANewSlide <> nil then
    begin
      HistForm := N_BrigHist2Form;
      N_BrigHist2Form := nil;
    end;
    EdFreeObjects();
    TForm(N_BrigHist2Form) := HistForm;
  end;
//  FinishEditing.Action := N_CMResForm.aEditCloseCurActive;
  FinishEditing.Visible := TRUE;
  EdSlide := ANewSlide;
  ImgClibrated.Visible := FALSE;
  ImgHasDiagn.Visible := FALSE;
  STReadOnly.Visible := FALSE;
  if EdSlide = nil then Exit;
  Result := InitSlideView();
  if not Result then
    EdSlide := nil;

  SetFrameDefaultViewEditMode();

  if not Result then  Exit;
  if (EdSlide <> nil) and (TN_UDCMBSlide(EdSlide) is TN_UDCMStudy) then Exit;

  SetReadOnlyState();
  
end; // procedure TN_CMREdit3Frame.SetNewSlide

//******************************************** TN_CMREdit3Frame.SetReadOnlyState ***
// Set EdFrame Readonly State
//
procedure TN_CMREdit3Frame.SetReadOnlyState( );
begin
  STReadOnly.Visible := (EdSlide.P.CMSRFlags * [cmsfSkipSlideEdit, cmsfSkipChangesSave]) <> [];
  if STReadOnly.Visible then
  begin
    if cmsdbfMarkedAsDel in EdSlide.CMSDBStateFlags then
      STReadOnly.Caption := 'D'
    else
      STReadOnly.Caption := 'R';
  end;

end; // procedure TN_CMREdit3Frame.SetReadOnlyState

//******************************************** TN_CMREdit3Frame.SetFrameDefaultViewEditMode ***
// Set Frame Default View Edit Mode
//
procedure TN_CMREdit3Frame.SetFrameDefaultViewEditMode( );
var
//  PSkipSelf : PByte;
//  WaitShowBound : Double;
  FrameWithStudy : Boolean;
begin
  if EdSlide = nil then
  begin
    EdViewEditMode := cmrfemNone;
//    PopupMenu := N_CMResForm.EdFrPointPopupMenu; // Restore Normal PopupMenu
    PopupMenu := N_CM_MainForm.CMMEdFramePopUpMenu;
  end
  else
  begin
    FrameWithStudy := TN_UDCMBSlide(EdSlide) is TN_UDCMStudy;
    if FrameWithStudy then
    begin
      N_CMResForm.EdFrameStudyPopupMenu.OnPopup := N_CM_MainForm.aEdFrameStudyOnPopup;
      PopupMenu := N_CMResForm.EdFrameStudyPopupMenu;
    end
    else
      PopupMenu := N_CM_MainForm.CMMEdFramePopUpMenu;
//      PopupMenu := N_CMResForm.EdFrPointPopupMenu; // Restore Normal PopupMenu
    if N_CM_MainForm.CMMEdVEMode = cmrfemFlashLight then
    begin
      EdViewEditMode := cmrfemFlashLight;
      EdFlashLightModeRFA.ActEnabled := not FrameWithStudy;
    end
    else
    begin
      EdViewEditMode := cmrfemPoint;
      EdMoveVObjRFA.ActEnabled := not FrameWithStudy;
    end;
  end;

end; // procedure TN_CMREdit3Frame.SetFrameDefaultViewEditMode

//***************************************** TN_CMREdit3Frame.RebuildMapRoot ***
// Update all needed Self fields and Objects by Slide MapRoot
// and show it
// (should be used in N_CreateCMREdit3Frame and after Slide was replaced,
// and after undo)
//
procedure TN_CMREdit3Frame.RebuildSlideView( AShowDump : Boolean = FALSE );
var
  SlideMapRoot : TN_UDCompVis;
begin
  with RFrame do
  begin
    SlideMapRoot := EdSlide.GetMapRoot();
{
    if SlideMapRoot <> RVCTreeRoot then
    begin
      RVCTFrInit( SlideMapRoot );
      EdFlashLightModeRFA.CMEFLComp := nil;
    end;
}
    RVCTFrInit3( SlideMapRoot );
//    RFrInitByComp( SlideMapRoot );
    N_Dump2Str( 'RebuildSlideView 1' );
    EdFlashLightModeRFA.CMEFLComp := nil;
    aFitInWindowExecute( nil );
    N_Dump2Str( 'RebuildSlideView 2' );
    if Assigned(RFOnScaleProcObj) then
    begin
      RFOnScaleProcObj( RFrame );
      N_Dump2Str( 'RebuildSlideView 3' );
    end;
    RFGetActionByClass( N_ActZoom ).ActEnabled := True;
  end; // with RFrame do
end; // procedure TN_CMREdit3Frame.RebuildSlideView

//***************************************** TN_CMREdit3Frame.CheckRectEllipsLine ***
// Check Rectangle or Ellips circumscribed line
//
//      Parameters
// AUDPolyLine - circumscribed line
// Result - Returns TRUE if Rectangle or Ellips circumscribed line is rotated by some angle
//
function TN_CMREdit3Frame.CheckRectEllipsLine( AUDPolyLine : TN_UDPolyLine ) : Boolean;
var
  P1, P2 : TFPoint;
begin
  with AUDPolyLine, PISP.CPCoords do
  begin
     P1 := PFPoint(P(0))^;
     P2 := PFPoint(P(1))^;
     Result := (P1.X <> P2.X) and (P1.Y <> P2.Y);
  end;
end; // function TN_CMREdit3Frame.CheckRectEllipsLine

//***************************************** TN_CMREdit3Frame.RebuildVObjsSearchList ***
// Rebuild Vector Objects Search List
//
// Should be used after Slide was replaced and in all cases when Vector Objects
// list is changed
//
procedure TN_CMREdit3Frame.RebuildVObjsSearchList(  );
var
  MapRootMeasures : TN_UDBase;
  i, h, j, n, k, L : Integer;
  UDVObj : TN_UDBase;
  ObjTypeChar : Char;
  LinesList : TList;

  procedure ReallockSComps( DLeng : Integer );
  begin
    L := Length(EdVObjsGroup.SComps);
    if K_NewCapacity( k + DLeng, L ) then
      SetLength( EdVObjsGroup.SComps, L );
  end;

begin

  if EdSlide = nil then Exit;

  if TN_UDCMBSlide(EdSlide) is TN_UDCMStudy then
  begin
    RebuildStudySearchList();
    Exit;
  end;

// Clear Previouse Actions Context
  if EdMoveVObjRFA <> nil then
  begin
    EdMoveVObjRFA.MovedComp := nil;
    EdMoveVObjRFA.MeasureRoot := nil;
  end;

  EdVObjsGroup.OneSR.SRType := srtNone;
  if cmsfHideDrawings in EdSlide.P.CMSRFlags then
  begin
    SetLength( EdVObjsGroup.SComps, 0 );
    N_Dump2Str( 'Search List Clear'  );
    Exit;
  end;

// Build Objects Search List
  LinesList := TList.Create;
  MapRootMeasures := EdSlide.GetMeasureRoot( );
  h := MapRootMeasures.DirHigh;
  k := 0;
  with EdVObjsGroup do
  begin
    for i := 0 to h do
    begin
      UDVObj := MapRootMeasures.DirChild(i);
      ObjTypeChar := UDVObj.ObjName[1];

      N_Dump2Str( 'Search List Add Obj=' + UDVObj.ObjName );
      if (ObjTypeChar = 'E') and
         (Length(UDVObj.ObjName) > 7) and
         (UDVObj.ObjName[8] = 'L') then
        ObjTypeChar := 'Q'; // EllipseLine Flag

      if (ObjTypeChar = 'R') and
         (Length(UDVObj.ObjName) > 4) and
         (UDVObj.ObjName[5] = 'L') then
        ObjTypeChar := 'S'; // RectangleLine Flag

      case ObjTypeChar of
      'D','M' : begin // Measure PolyLine
        with UDVObj do
        begin
          LinesList.Add( DirChild(1) );
          n := DirHigh;
          ReallockSComps( n );
          for j := k to k + n - 1 do
            with SComps[j] do
            begin
              SComp := TN_UDCompVis(DirChild(j - k + 2));
              SFlags := 0;
            end;
        end;
        Inc(k, n);
      end; // 'M' : begin // Measure PolyLine

      'Q' : begin // EllipseLine
        ReallockSComps( 1 );
        with SComps[k] do
        begin
          SComps[k].SComp := TN_UDCompVis(UDVObj.DirChild(1)); // Ellipse Line
          SFlags := 1;
        end;
        Inc(k);
{
        with SComps[k] do begin
          SComps[k].SComp := TN_UDCompVis(UDVObj.DirChild(1)); // Rect Line
          if CheckRectEllipsLine(TN_UDPolyLine(SComp)) then
            SFlags := 1
          else
            SFlags := 3;
        end;
        Inc(k);
}
      end; // 'Q' : begin // EllipseLine

      'S' : begin // RectangleLine
        ReallockSComps( 1 );
        with SComps[k] do
        begin
          SComps[k].SComp := TN_UDCompVis(UDVObj.DirChild(1)); // Rect Line
          if CheckRectEllipsLine(TN_UDPolyLine(SComp)) then
            SFlags := 1
          else
            SFlags := 3;
        end;
        Inc(k);
      end; // 'S' : begin // RectangleLine

      'H' : begin // FreeHandLine
        ReallockSComps( 1 );
        with SComps[k] do
        begin
          SComps[k].SComp := TN_UDCompVis(UDVObj.DirChild(1)); // Free Hand Line
          SFlags := 1;
        end;
        Inc(k);
      end; // 'H' : begin // FreeHandLine

      'L' : begin // PolyLine
        LinesList.Add( UDVObj.DirChild(1) );
      end;

      'N' : begin // Angle
        with UDVObj do
        begin
          LinesList.Add( DirChild(2) ); // Angle Line
          ReallockSComps( 1 );
          with SComps[k] do
          begin
            SComps[k].SComp := TN_UDCompVis(DirChild(3)); // Angle Text
            SFlags := 0;
          end;
        end;
        Inc(k);
      end; // 'N' : begin // Angle

      'F' : begin // Free Angle
        with UDVObj do
        begin
          LinesList.Add( DirChild(3) ); // Angle Line1
          LinesList.Add( DirChild(4) ); // Angle Line2
          ReallockSComps( 3 );
          with SComps[k] do
          begin
            SComp := TN_UDCompVis(DirChild(5));   // Angle Text
            SFlags := 0; // For PolyLine
          end;
        end;
        Inc(k);
      end; // 'F' : begin // Free Angle

      'T' : begin // Text
        ReallockSComps( 1 );
        with SComps[k] do
        begin
          SComp  := TN_UDCompVis(UDVObj); // Text
          SFlags := 0;
        end;
        Inc(k);
      end; // 'T' : begin // Text

      'R' : begin // Rectangle
        with UDVObj do
          LinesList.Add( DirChild(1) ); // Rectangle Border Line
      end; // 'R' : begin // Rectangle

      'E' : begin // Ellipse
        ReallockSComps( 1 );
        with SComps[k], UDVObj do
        begin
          SComp  := TN_UDCompVis(DirChild(1)); // Ellipse Arc Component
          SFlags := 1;
        end;
        Inc(k);
      end; // 'E' : begin // Ellipse

      'A' : begin // Arrow
        with UDVObj do
//!! Old Arrow          LinesList.Add( DirChild(1) ); // Arrow Main Line
          LinesList.Add( DirChild(2) ); // Arrow Main Line
      end; // 'A' : begin // Arrow

      'Z' : begin // FlashLight
        with UDVObj do
        begin
          ReallockSComps( 1 );
          with SComps[k] do
          begin
            SComp  := TN_UDCompVis(DirChild(1)); // Flachlight DIBRect Component
            SFlags := 0;
          end;
          Inc(k);
{
          if UDVObj.ObjName[2] = 'E' then begin
          // Ellipse FlashLight
            ReallockSComps( 1 );
            with SComps[k] do begin
              SComp  := TN_UDCompVis(DirChild(2)); // Flachlight Arc Component
              SFlags := 0;
            end;
            Inc(k);
          end else
          // Rectangle FlashLight
            LinesList.Add( DirChild(2) ); // Rectangle Border Line
}
        end; // with UDVObj do
      end; // 'Z' : begin // FlashLight
      end; // end of case ObjTypeChar
    end; // for i := 0 to h do

    SetLength( SComps, k + LinesList.Count );
    if LinesList.Count > 0 then
    begin
      if k > 0 then
        Move( SComps[0], SComps[LinesList.Count], k * SizeOf(TN_SearchComp) );

      for i := 0 to LinesList.Count - 1 do
      begin
        with SComps[i] do
        begin
          SComp := TN_UDCompVis(LinesList[i]); // PolyLine
          N_Dump2Str( 'Search List Add Line Obj=' + SComp.Owner.ObjName );
          SFlags := 3; // For PolyLine
        end;
      end;
    end; // if LinesList.Count > 0 then

    LinesList.Free;
    N_Dump2Str( format ('Search ListObj(%d) SR=%d Count=%d', [Integer(EdVObjsGroup), Ord(EdVObjsGroup.OneSR.SRType), Length( EdVObjsGroup.SComps)] ) );
  end; // with EdVObjsGroup do


end; // procedure TN_CMREdit3Frame.RebuildVObjsSearchList

//***************************************** TN_CMREdit3Frame.RebuildVObjsSearchList ***
// Rebuild Study Search List
//
// Should be used after Study was replaced
//
procedure TN_CMREdit3Frame.RebuildStudySearchList();
begin
//!!! Study Code is Needed
  if EdSlide = nil then Exit;
  TN_UDCMStudy(EdSlide).RebuildItemsSearchList( EdVObjsGroup, FALSE );
end; // procedure TN_CMREdit3Frame.RebuildStudySearchList

//***************************************** TN_CMREdit3Frame.RebuildSlideThumbnail ***
// Update all needed Self fields and Objects by Slide MapRoot
// and show it
// (should be used in N_CreateCMREdit3Frame and after Slide was replaced,
// and after undo)
//
procedure TN_CMREdit3Frame.RebuildSlideThumbnail();
var
  SelectedVObj : TN_UDCompVis;
  RebuildMapRoot : Boolean;
  WSFlags: TN_CMSlideSFlags; // Slide State Saved Flags
  StudyItem : TN_UDBase;
  Study : TN_UDCMStudy;
begin
  SelectedVObj := EdVObjSelected;
  if SelectedVObj <> nil then
    ChangeSelectedVObj(0);

  with EdSlide.P().CMSDB do begin
  // Skip Show Emboss, Colorize, and Isodensity in Thumbnail
    RebuildMapRoot := (SFlags * [cmsfShowColorize, cmsfShowIsodensity, cmsfShowEmboss]) <> [];
    if RebuildMapRoot then begin
      WSFlags := SFlags;
      SFlags := SFlags - [cmsfShowColorize, cmsfShowIsodensity, cmsfShowEmboss];
      EdSlide.RebuildMapImageByDIB( );
    end;
    EdSlide.CreateThumbnail();

    if IfSlideIsImage() then
    begin
      StudyItem := EdSlide.GetStudyItem();
      Study := K_CMStudyGetStudyByItem( StudyItem );
      if (Study <> nil) and (Study.CMSRFrame <> nil) then
        Study.CMSRFrame.RedrawAllAndShow();
    end;

    if RebuildMapRoot then
    begin
      SFlags := WSFlags;
      EdSlide.RebuildMapImageByDIB( );
    end;
  end;

  if SelectedVObj <> nil then
    ChangeSelectedVObj(1, SelectedVObj);
  N_Dump2Str( 'Slide thumbnail rebuild ID=' + EdSlide.ObjName );
end; // procedure TN_CMREdit3Frame.RebuildSlideThumbnail

//************************************* TN_CMREdit3Frame.DeleteVObjSelected ***
// Delected Selected Vector Object
//
//     Parameters
// ASaveHistory - if TRUE save Slide History
// Result - Returns TRUE if Selected Object was deleted
//
function TN_CMREdit3Frame.DeleteVObjSelected( ASaveHistory : Boolean = FALSE ) : Boolean;
var
  DelComp : TN_UDBase;
  HistVObjType : TK_CMSlideHistVObjType;
begin
  Result := EdSlide <> nil;
  if not Result then Exit;
  DelComp := EdVObjSelected;
  Result := ChangeSelectedVObj( -1 );
  if not Result then Exit;

  // Delete Selected
  if (DelComp.ObjName[1] = 'T') and
     ((DelComp.Owner.ObjName[2] = 'L') or
      (DelComp.Owner.ObjName[2] = 'A') or
      (DelComp.Owner.ObjName[1] = 'D')) then
    DelComp := DelComp.Owner;

  HistVObjType := K_CMEDAccess.EDAGetVObjHistType( DelComp );
  EdVObjSelected := nil;
  Include( K_UDOperateFlags, K_udoUNCDeletion );
  DelComp.Owner.DeleteOneChild( DelComp );
  Exclude( K_UDOperateFlags, K_udoUNCDeletion );

  if ASaveHistory then
    N_CM_MainForm.CMMFFinishVObjEditing( N_CMResForm.aObjDelete.Caption,
               K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                    Ord(K_shVOActDel),
                    Ord( HistVObjType ) ) );

  RebuildVObjsSearchList();
  RFrame.RedrawAllAndShow();
end; // function TN_CMREdit3Frame.DeleteVObjSelected

{
//******************************************* TN_CMREdit3Frame.AffConvVObjs ***
// Convert Vector Objects Cordinates
//
//     Parameters
// AVOConv     - coordinates conversion mode
//
// Should be used after Slide Raster Affine conversion
//
procedure TN_CMREdit3Frame.AffConvVObjs( AVOConv : TN_CMRFRVOConv );
var
  MapRootMeasures : TN_UDBase;
  i, h, j, n, k : Integer;
  UDVObj, UDVChild : TN_UDCompVis;
  WPoint : TFPoint;

  AffCoefs1 : TN_AffCoefs6;
  AffCoefs2 : TN_AffCoefs6;
  PCompCoords : TN_PCompCoords;
  WF : single;
  ObjTypeChar : Char;

  procedure N_AffConv1F2FPoint ( PP : PFPoint ); // local
  // Convert one float point by AffCoefs1
  var
    X1 : Double;
  begin
    with AffCoefs1, PP^ do begin
      X1 := X;
      X := CXX * X + CXY * Y + SX;
      Y := CYX * X1 + CYY * Y + SY;
    end;
  end; // procedure N_AffConv1F2FPoint ( PP : PFPoint ); / // local

  procedure N_AffConv2F2FPoint ( PP : PFPoint ); // local
  // Convert one float point by AffCoefs1
  var
    X1 : Double;
  begin
    with AffCoefs2, PP^ do begin
      X1 := X;
      X := CXX * X + CXY * Y + SX;
      Y := CYX * X1 + CYY * Y + SY;
    end;
  end; // procedure N_AffConv2F2FPoint ( PP : PFPoint ); // local

  function NormAngle( Ang : Float ) : Float; // local
  begin
    Result := Ang;
    if Result < 0 then
      Result := 360 + Result
    else if Result > 360 then
      Result := Result - 360;
  end; // function NormAngle( Ang : Float ) : Float; // local

begin //**************************** main body of TN_CMREdit3Frame.AffConvVObjs
  if EdSlide = nil then Exit;

  case AVOConv of

    cmrfvcRotateLeft:
    begin
      AffCoefs1 := N_CalcAffCoefs6( D3PReper( 0, 0, 0, 100, 100, 0 ),
                                    D3PReper( 0, 100, 100, 100, 0, 0 ) );
      AffCoefs2 := N_CalcAffCoefs6( D3PReper( 0, 0, 0, 10, 10, 0 ),
                                    D3PReper( 0, 0, 10, 0, 0, -10 ) );
    end;

    cmrfvcRotateRight:
    begin
      AffCoefs1 := N_CalcAffCoefs6( D3PReper(   0, 0, 0, 100, 100, 0 ),
                                    D3PReper( 100, 0, 0,   0, 100, 100 ) );
      AffCoefs2 := N_CalcAffCoefs6( D3PReper( 0, 0,   0, 10, 10, 0 ),
                                    D3PReper( 0, 0, -10,  0,  0, 10 ) );
    end;

    cmrfvcRotate180:
    begin
      AffCoefs1 := N_CalcAffCoefs6( D3PReper( 0, 0, 0, 100, 100, 0 ),
                                    D3PReper( 100, 100, 100, 0, 0, 100 ) );
      AffCoefs2 := N_CalcAffCoefs6( D3PReper(  0, 0, 0,  10,  10, 0 ),
                                    D3PReper(  0, 0, 0, -10, -10, 0 ) );
    end;

    cmrfvcFlipHor:
    begin
      AffCoefs1 := N_CalcAffCoefs6( D3PReper(   0, 0,   0, 100, 100, 0 ),
                                    D3PReper( 100, 0, 100, 100,   0, 0  ) );
      AffCoefs2 := N_CalcAffCoefs6( D3PReper(  0, 0,  0, 10,  10, 0 ),
                                    D3PReper(  0, 0,  0, 10, -10, 0 ) );
    end;

    cmrfvcFlipVert:
    begin
      AffCoefs1 := N_CalcAffCoefs6( D3PReper(  0,   0, 0, 100, 100,   0 ),
                                    D3PReper(  0, 100, 0,   0, 100, 100 ) );
      AffCoefs2 := N_CalcAffCoefs6( D3PReper( 0, 0, 0,  10, 10, 0 ),
                                    D3PReper( 0, 0, 0, -10, 10, 0 ) );
    end;

  end; // case AVOConv of

  MapRootMeasures := EdSlide.GetMeasureRoot( );
  h := MapRootMeasures.DirHigh;

  for i := 0 to h do
  begin
    UDVObj := TN_UDCompVis(MapRootMeasures.DirChild(i));
    ObjTypeChar := UDVObj.ObjName[1];
    PCompCoords := @UDVObj.PSP.CCoords;

    with PCompCoords^ do
    begin
      if (ObjTypeChar = 'R') or
         (ObjTypeChar = 'E') or
         (ObjTypeChar = 'A') or
         (ObjTypeChar = 'Z') then // Rect Like - Rect, Ellipse, Arrow, Marnify region
       begin
        WPoint := FPoint( BPCoords.X + SRSize.X / 2, BPCoords.Y + SRSize.Y / 2 );
        N_AffConv1F2FPoint ( @WPoint );

        if (AVOConv = cmrfvcRotateLeft) or (AVOConv = cmrfvcRotateRight) then
        begin
          // Swap User Size
          WF := SRSize.Y;
          SRSize.Y := SRSize.X;
          SRSize.X := WF;
        end;

        BPCoords := FPoint( WPoint.X - SRSize.X / 2, WPoint.Y - SRSize.Y / 2 );

        if UDVObj.ObjName[1] = 'Z' then // for magnify region only
        begin
          K_CMSFlashlightCalcSrcRect( UDVObj, RFrame.RFVectorScale, Point(0,0) );
        end;
      end else // not Rect Like - Line, Angle
      begin
        N_AffConv1F2FPoint ( @BPCoords );
        n := UDVObj.DirHigh;

        for j := 0 to n do // loop along child components
        begin
          UDVChild := TN_UDCompVis(UDVObj.DirChild(j));

          if UDVChild is TN_UDPolyLine then
            with TN_UDPolyline(UDVChild), PISP.CPCoords do
            begin
              for k := 0 to AHigh() do // along all internal points
                N_AffConv2F2FPoint( PFPoint(P(k)) );
            end
          else if UDVChild is TN_UDArc then
          begin
            N_AffConv2F2FPoint ( @UDVChild.PSP.CCoords.BPCoords );

            with TN_UDArc(UDVChild).PSP.CArc do
            case AVOConv of
                cmrfvcRotateLeft : begin
                CArcBegAngle := NormAngle( CArcBegAngle + 90 );
                CArcEndAngle := NormAngle( CArcEndAngle + 90 );
              end;
              cmrfvcRotateRight : begin
                CArcBegAngle := NormAngle( CArcBegAngle - 90 );
                CArcEndAngle := NormAngle( CArcEndAngle - 90 );
              end;
              cmrfvcRotate180  : begin
                CArcBegAngle := NormAngle( CArcBegAngle - 180 );
                CArcEndAngle := NormAngle( CArcEndAngle - 180 );
              end;
              cmrfvcFlipHor    : begin
                CArcBegAngle := NormAngle( -CArcBegAngle );
                CArcEndAngle := NormAngle( -CArcEndAngle );
              end;
              cmrfvcFlipVert   : begin
                CArcBegAngle := NormAngle( 180 - CArcBegAngle );
                CArcEndAngle := NormAngle( 180 - CArcEndAngle );
              end;
            end; // case AVOConv of
          end else if UDVChild is TN_UDParaBox then // Text
            N_AffConv2F2FPoint ( @UDVChild.PSP.CCoords.BPCoords );
        end; // for j := 0 to n do begin // loop along child components
      end; // else begin // not Rect Like - Line, Angle
    end; // with PCompCoords^ do begin
  end; // for i := 0 to h do begin
end; // procedure TN_CMREdit3Frame.AffConvVObjs

//******************************************* TN_CMREdit3Frame.AffConvVObjs6 ***
// Convert Vector Objects Cordinates
//
//     Parameters
// APixAffCoefs6 - AffCoefs6 coeficients for User coordinates
//                 transformation
// AAngle        - Rotate Angle
//
// Should be used after Slide Raster rotate by degree
//
procedure TN_CMREdit3Frame.AffConvVObjs6( APixAffCoefs6: TN_AffCoefs6; AAngle : Double );
var
  MapRootMeasures : TN_UDBase;
  i, h, j, n, k : Integer;
  UDVObj, UDVChild : TN_UDCompVis;
  WPoint : TFPoint;

  PCompCoords : TN_PCompCoords;
  PChildCompCoords : TN_PCompCoords;
  ObjTypeChar : Char;
  PLP : PFPoint;

  procedure N_AffConv6F2FPoint( PP : PFPoint );
  var
    X1 : Double;
  begin
    with APixAffCoefs6, PP^ do begin
      X1 := X;
      X := CXX * X + CXY * Y + SX;
      Y := CYX * X1 + CYY * Y + SY;
    end;
  end;

  function NormAngle( Ang : Float ) : Float;
  begin
    Result := Ang;
    if Result < 0 then
      Result := 360 + Result
    else if Result > 360 then
      Result := Result - 360;
  end;

begin
//  Exit; // debug

  if EdSlide = nil then Exit;

  MapRootMeasures := EdSlide.GetMeasureRoot( );
  h := MapRootMeasures.DirHigh;
  for i := 0 to h do
  begin
    UDVObj := TN_UDCompVis(MapRootMeasures.DirChild(i));
    ObjTypeChar := UDVObj.ObjName[1];
    PCompCoords := @UDVObj.PSP.CCoords;

    with PCompCoords^ do
    begin
      if (ObjTypeChar = 'R') or
         (ObjTypeChar = 'E') or
         (ObjTypeChar = 'A') or
         (ObjTypeChar = 'Z') then begin
      // Rectangle Type Objects Ellips, Rectangle, Arrow, Flashlight
        WPoint := FPoint( BPCoords.X + SRSize.X / 2, BPCoords.Y + SRSize.Y / 2 );
        N_AffConv6F2FPoint ( @WPoint );
        SRSize.X := SRSize.X * APixAffCoefs6.CXX;
        SRSize.Y := SRSize.Y * APixAffCoefs6.CYY;
        BPCoords := FPoint( WPoint.X - SRSize.X / 2, WPoint.Y - SRSize.Y / 2 );
        if UDVObj.ObjName[1] = 'Z' then
          K_CMSFlashlightCalcSrcRect( UDVObj, RFrame.RFVectorScale, Point(0,0) );
      end else if ObjTypeChar = 'T' then
        N_AffConv6F2FPoint ( @BPCoords )
      else // Other Type Objects Line, Measured Line, Freehand, Angle, Free Angle
      begin
        n := UDVObj.DirHigh;

        for j := 0 to n do
        begin
          UDVChild := TN_UDCompVis(UDVObj.DirChild(j));
          PChildCompCoords := @UDVChild.PSP.CCoords;
          if UDVChild is TN_UDPolyLine then begin
          // Polyline childs
            with TN_UDPolyline(UDVChild), PISP.CPCoords  do
              for k := 0 to AHigh() do
              begin
                PLP := PFPoint(P(k));
                PLP^ := N_Add2P( PCompCoords.BPCoords, PLP^ );
                N_AffConv6F2FPoint ( PLP );
              end;
          end else if (UDVChild is TN_UDArc) or (UDVChild is TN_UDParaBox) then
          begin
          // Arc and Text Childs
            PChildCompCoords.BPCoords := N_Add2P( PCompCoords.BPCoords,
                                                  PChildCompCoords.BPCoords );
            N_AffConv6F2FPoint ( @PChildCompCoords.BPCoords );

            if UDVChild is TN_UDArc then
            begin
              with TN_UDArc(UDVChild).PSP.CArc do
              begin
                CArcBegAngle := NormAngle( CArcBegAngle + AAngle );
                CArcEndAngle := NormAngle( CArcEndAngle + AAngle );
              end;
            end; // if UDVChild is TN_UDArc then
          end; // else if (UDVChild is TN_UDArc) or (UDVChild is TN_UDParaBox) then
        end; // for j := 0 to n do
        PCompCoords.BPCoords := FPoint(0,0);
      end; // else // Other Type Objects Line, Measured Line, Freehand, Angle, Free Angle
    end; // with PCompCoords^ do
  end; // for i := 0 to h do

end; // procedure TN_CMREdit3Frame.AffConvVObjs6
}

//************************************* TN_CMREdit3Frame.ChangeSelectedVObj ***
// Change Frame Selected Vector Object State
//
//    Parameters
// ANewState - new Selected State
//#F
//  =0  - unselect
//  >0  - select
//  <0  - only check current state
//#/F
// AUDVObj - given New Selected Vector Object (if =nil then Current Frame Selected Vector Object should be used)
//   (should be used in N_CreateCMREdit3Frame and after Slide was replaced,
//   and after undo)
// ASkipDisableActions - if TRUE then skip interface action rebuild (N_CM_MainForm.CMMFDisableActions should not be call)
// Result - Returns TRUE if given Vector Object which State should be changed was Selected
//
function TN_CMREdit3Frame.ChangeSelectedVObj( ANewState : Integer; AUDVObj : TN_UDCompVis = nil;
                                              ASkipDisableActions : Boolean = FALSE ) : Boolean;
var
  PNewVal : PByte;
  PPrevVal : PByte;
  PrevVal : Byte;
  NewSelected : Boolean;
  NewEdVObjSelected : TN_UDCompVis;
  PrevEdVObjSelected : TN_UDCompVis;

  function GetPVal( VObj : TN_UDCompVis ) : PByte;
  var
    PUP: TN_POneUserParam;
  begin
    Result := nil;
//    PUP := N_GetUserParPtr( VObj.R, 'Selected' );
    PUP := K_CMGetVObjPAttr( VObj, 'Selected' );
    if PUP = nil then Exit;
    Result := PByte(PUP.UPValue.P);
  end;

  procedure ProcessRectOrEllipse( VObj : TN_UDBase; PrevState: Boolean; PNewState : PByte );
  begin

    if (VObj = nil)                    or
       (PrevState = (PNewState^ <> 0)) or
       ( (VObj.ObjName[1] <> 'E')   and
         ( (VObj.ObjName[1] <> 'Z') or
           (VObj.ObjName[2] <> 'E') ) ) then Exit;
    // Ellipse and Ellipse FlashLight Change Selected State
    if PrevState then
    // Clear Additional Info
      with EdVObjsGroup do
      begin
        with SComps[High(SComps)], VObj do
          if SComp = TN_UDCompVis(DirChild(DirHigh)) then
            SetLength( SComps, High(SComps) )
      end
    else
    // Set Additional Info
      with EdVObjsGroup do
      begin
        SetLength( SComps, Length(SComps) + 1 );
        with SComps[High(SComps)], VObj do
        begin
          SComp := TN_UDCompVis(DirChild(DirHigh));
          if (VObj.ObjName[1] = 'E')    and
             (Length(VObj.ObjName) > 7) and
             (VObj.ObjName[8] = 'L')    and
             CheckRectEllipsLine(TN_UDPolyLine(SComp)) then
            SFlags := 1 // For Rotated EllipseLine circumscribed PolyLine
          else
            SFlags := 2; // For Ellipse or FlashLight circumscribed PolyLine
        end;
      end;

  end;

begin

  NewEdVObjSelected := AUDVobj;
  if AUDVobj = nil then
    NewEdVObjSelected := EdVObjSelected;

  Result := false;
  if NewEdVObjSelected <> nil then
  begin
  // Change Component State
    NewSelected := false;
    PNewVal := GetPVal( NewEdVObjSelected );
    if PNewVal <> nil then begin
      Result := PNewVal^ <> 0;
      if ANewState >= 0 then begin
        PNewVal^ := Byte(ANewState);
        NewSelected := ANewState > 0;
      end else
        Exit;
    end;

    if (EdVObjSelected <> nil)     and
       (AUDVobj <> EdVObjSelected) and
       NewSelected then
    begin
      // Unselect Previouse Selected
      PPrevVal := GetPVal( EdVObjSelected );
      PrevVal := PPrevVal^;
      PPrevVal^ := 0;
      ProcessRectOrEllipse( EdVObjSelected, PrevVal <> 0, PPrevVal );
    end;

    PrevEdVObjSelected := EdVObjSelected;

    if NewSelected then
      EdVObjSelected := NewEdVObjSelected
    else
      EdVObjSelected := nil;

    ProcessRectOrEllipse( NewEdVObjSelected, Result, PNewVal );

    if not ASkipDisableActions and
      (PrevEdVObjSelected <> EdVObjSelected) then
      N_CM_MainForm.CMMFDisableActions(nil);
  end;

end; // procedure TN_CMREdit3Frame.ChangeSelectedVObj

//*********************************** TN_CMREdit3Frame.AskAndSaveCurrentDIB ***
// Show Whole Image, Ask if it should be saved (if needed),
// if OK, Save CurrentDIB to file and to OriginalDIB, Return True
// if Not OK - Restore OriginalDIB to CurrentDIB and show it, Return False
//
// ANeedToAsk - is True if Asking is needed
//
function TN_CMREdit3Frame.AskAndSaveCurrentDIB( ANeedToAsk: boolean ): boolean;
var
  IntRes: integer;
  MsgDialogForm: TN_MsgDialogForm;

  Label Save, Restore;
begin
  if ANeedToAsk then
  begin
    ShowWholeImage();
    MsgDialogForm := TN_MsgDialogForm.Create( Application );
    N_PlaceTControl( MsgDialogForm, Self );

    with MsgDialogForm do
    begin
      lbMessage.Caption := 'Save current Image?';
      bnOK.Visible     := True;
      bnCancel.Visible := True;
      IntRes := ShowModal();
    end;

    if IntRes <> mrOK then goto Restore;
  end; // if ANeedToAsk then

  Save: //***************************
  Result := True;
//  EdMapUDDIB.SaveDIBObj();
  N_CM_MainForm.CMMFRebuildActiveView( );
  Exit;

  Restore: //************************
  Result := False;
//  RestoreOriginalDIB();
  ShowStringByTimer( 'Operation Cancelled!' );
end; // procedure TN_CMREdit3Frame.AskAndSaveCurrentDIB

{
//************************************* TN_CMREdit3Frame.RestoreOriginalDIB ***
// Restore CurrentDIB from OriginalDIB and show whole image
//
procedure TN_CMREdit3Frame.RestoreOriginalDIB();
begin

  begin

  EdMapUDDIB.DIBObj.Free;
//  EdMapUDDIB.DIBObj := TN_DIBObj.Create( OriginalDIB );

  ShowWholeImage();

  end; //
end; // procedure TN_CMREdit3Frame.RestoreOriginalDIB
}

//******************************************** TN_NVTCSMFrame.EdFreeObjects ***
// Free all Self Objects, related to EdSlide (Finish Editing EdSlide)
//
//      Parameters
//  AFreeFlags  - are used if slides is deleted
//
procedure TN_CMREdit3Frame.EdFreeObjects( AFreeFlags : TN_CMRFEdFreeFlags = []  );
var
  WSTR : string;
  RebuildVew : Boolean;
  PCMSlide : TN_PCMSlide;
begin
//  if N_TstIPCForm <> nil then N_TstIPCForm.AddInfoStr( 'CMREdit3Frame', '25' );
//  FreeAndNil( OriginalDIB );
  FinishEditing.Visible := FALSE;
//  FinishEditing.Action := nil;

  WSTR := Name;
  if EdSlide <> nil then
  begin
    N_CM_MainForm.CMMFSelectThumbBySlide( EdSlide, TRUE );
    EdSlide.CMSRFrame := nil;
    WSTR := WSTR + ' for SID=' + EdSlide.ObjName;
    if cmrfefSkipSave in AFreeFlags then
      WSTR := WSTR + ' SkipSave';
    if cmrfefSkipUnlock in AFreeFlags then
      WSTR := WSTR + ' SkipUnlock';
  end;
  N_Dump2Str( 'EdFreeObjects in ' + WSTR );

  Assert( EdGetSlideColorRFA <> nil, 'EdGetSlideColorRFA = nil!' );
  with EdGetSlideColorRFA  do
    if ActEnabled then
    begin
      ActEnabled := false;
      N_CM_MainForm.CMMFShowString( '' );
      N_SetMouseCursorType( RFrame, crDefault );
    end;

  Assert( EdIsodensityRFA <> nil, 'EdIsodensityRFA = nil!' );
  with EdIsodensityRFA do
    if ActEnabled then
    begin
      ActEnabled := false;
      N_CM_MainForm.CMMFShowString( '' );
      N_SetMouseCursorType( RFrame, crDefault );
    end;

  Assert( EdAddVObj1RFA <> nil, 'EdAddVObj1RFA = nil!' );
  with EdAddVObj1RFA do
    if ActEnabled and CreateVObjFlag then
    begin
    // Remove Creating Line
      Include( K_UDOperateFlags, K_udoUNCDeletion );
      VObjCompRoot.Owner.DeleteOneChild( VObjCompRoot );
      EdVObjSelected := nil; // Clear Frame Selected VObject Reference
      Exclude( K_UDOperateFlags, K_udoUNCDeletion );
      CreateVObjFlag := false;
      ActEnabled := false;
    end;

  Assert( EdAddVObj2RFA <> nil, 'EdAddVObj2RFA = nil!' );
  with EdAddVObj2RFA do
    if ActEnabled and CreateVObjFlag then
    begin
    // Remove Creating Line
      Include( K_UDOperateFlags, K_udoUNCDeletion );
      VObjCompRoot.Owner.DeleteOneChild( VObjCompRoot );
      EdVObjSelected := nil; // Clear Frame Selected VObject Reference
      Exclude( K_UDOperateFlags, K_udoUNCDeletion );
      CreateVObjFlag := false;
      ActEnabled := false;
    end;

  Assert( EdRubberRectRFA <> nil, 'EdRubberRectRFA = nil!' );
  with EdRubberRectRFA  do
    if ActEnabled then
    begin
      ActEnabled := false;
    end;

  Assert( EdFlashLightModeRFA <> nil, 'EdFlashLightModeRFA = nil!' );
  with EdFlashLightModeRFA do
    if ActEnabled then
    begin
//      ActEnabled := false;
      HideFlashlight(FALSE);
    end;

  N_SetMouseCursorType( RFrame, crDefault );

  PopupMenu := N_CM_MainForm.CMMEdFramePopUpMenu;
//  PopupMenu := N_CMResForm.EdFrPointPopupMenu; // Restore Normal PopupMenu

  ChangeSelectedVObj( 0, nil, TRUE );

  SetLength( EdVObjsGroup.SComps, 0 ); // Clear Search Objects List

  if EdSlide <> nil then
  begin
    PCMSlide := EdSlide.P();
    with EdSlide, PCMSlide^ do
    begin

  //    EdSlide.GetPMeasureRootSkipSelf()^ := 0;
      Exclude( CMSRFlags, cmsfIsOpened );
      if IfSlideIsStudy then
      begin
      // Study
        TN_UDCMStudy(EdSlide).UnSelectAll();
        K_CMEDAccess.EDAUnlockSlides(@EdSlide, 1, K_cmlrmOpenLock);
      end    // if IfSlideIsStudy then
      else
      begin // if not IfSlideIsStudy then
      // Slide
        if not (cmrfefSkipSave in AFreeFlags)              and                              // Slide is not Deleted
           ( (K_CMEDAccess.SlidesSaveMode = K_cmesFinEdit) or
             (K_CMEDAccess.SlidesSaveMode = K_cmesImmediately) ) then
        begin // Slides Save Mode is not saving at the end of Patient Editing
        // Save And Unlock while Finish View/Editing not Deleted SLide
          if K_CMEDAccess.SlidesSaveMode = K_cmesFinEdit then
          begin
            K_CMEDAccess.EDASaveSlidesArray( @EdSlide, 1 );
            if (cmsfSkipChangesSave in CMSRFlags) and
               not (cmsfInitUndoBuf in CMSRFlags) then
            begin
              RebuildVew := EdUndoBuf.UBCurInd <> EdUndoBuf.UBMinInd;
              EdUndoBuf.UBCurInd := EdUndoBuf.UBMinInd;
              EdUndoBuf.UBMinInd := 0;
              if RebuildVew then
              begin
                EdVObjSelected := nil;
                EdUndoBuf.UBGetSlideState(EdUndoBuf.UBCurInd);
                RebuildSlideThumbnail();
                N_CM_MainForm.CMMCurFThumbsDGrid.DGInitRFrame(); // is needed because Thumbnail Aspect may be changed
              end; // if RebuildVew then
            end; // if (cmsfSkipChangesSave in CMSRFlags) ...
          end; // if K_CMEDAccess.SlidesSaveMode = K_cmesFinEdit
        end; // if not (cmrfefSkipSave in AFreeFlags) ...

        if not (cmrfefSkipUnlock in AFreeFlags) then
          K_CMEDAccess.EDAUnlockSlides(@EdSlide, 1, K_cmlrmEditImgLock);
      end; // if not IfSlideIsStudy then
{
      if not (cmrfefSkipUnlock in AFreeFlags) then
        K_CMEDAccess.EDAUnlockSlides(@EdSlide, 1, K_cmlrmEditImgLock);
}
    end; // with EdSlide, PCMSlide^ do
  end; // if EdSlide <> nil then

  if EdViewEditMode <> cmrfemFlashLight then
    EdViewEditMode := cmrfemNone;
  EdSlide    := nil;

  RFrame.RFrInitByComp( nil );
  RFrame.ShowMainBuf();

  ImgClibrated.Visible := FALSE;
  ImgHasDiagn.Visible := FALSE;
  STReadOnly.Visible := FALSE;
  FrameLeftCaption.Caption := '';
  FrameRightCaption.Caption := '';

  RFrame.RFGetActionByClass( N_ActZoom ).ActEnabled := False;

  if (Self = N_CM_MainForm.CMMFActiveEdFrame) then
  begin
    N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( );
// was closed 2013-10-29 because RightToolbar Buttons are hidden
// after call to CMMFSetActiveEdFrame before any Action finish
//    N_CM_MainForm.CMMFSetActiveEdFrame(Self);
  end;

  N_Dump2Str( 'EdFreeObjects Fin' );
end; // procedure TN_CMREdit3Frame.EdFreeObjects

//*************************************** TN_CMREdit3Frame.Ed3FrAddCurState ***
// Add to given strings current state params
//
//     Parameters
// AStrings - given strings
// AIndent  - number of spaces to add before all strings
//
procedure TN_CMREdit3Frame.Ed3FrAddCurState( AStrings: TStrings; AIndent: integer );
var
  Prefix: string;
begin
  Prefix := DupeString( ' ', AIndent+2 );
  with AStrings do
  begin
    Add( Prefix + '*** Edit3Frame ' + RFrame.RFDebName );

    if EdSlide = nil then
      Add( Prefix + 'EdSlide = nil' )
    else
      EdSlide.CMSlideAddCurState( AStrings, AIndent+2 );

//    Add( 'Self:   ' + N_TControlToStr(Self) );
//    Add( 'RFrame: ' + N_TControlToStr(RFrame) );
    RFrame.RFAddCurState( AStrings, AIndent+2 );
  end; // with AStrings do
end; // procedure TN_CMREdit3Frame.Ed3FrAddCurState

//************************************** TN_CMREdit3Frame.Ed3FrDumpCurState ***
// Dump by N_Dump2Strings current state params
//
//     Parameters
// AIndent  - number of spaces to add before all strings
//
procedure TN_CMREdit3Frame.Ed3FrDumpCurState( AIndent: integer );
begin
  N_SL.Clear();
  Ed3FrAddCurState( N_SL, 0 );
  N_Dump2Strings( N_SL, AIndent );
end; // procedure TN_CMREdit3Frame.Ed3FrDumpCurState

//************************************** TN_CMREdit3Frame.Ed3FrDumpFrameRightCaption ***
// Dump FrameRightCaption Control State
//
//
procedure TN_CMREdit3Frame.Ed3FrDumpFrameRightCaption( AStr : string = '' );
begin
  with FrameRightCaption do
  N_Dump2Str( Format( 'Ed3FrDump %s:(L=%d T=%d R=%d D=%d) ' +
                      '%s RightCaption "%s":(L=%d T=%d R=%d D=%d)',
                        [Self.Name, Self.Left, Self.Top, Self.Left + Self.Width - 1, Self.Top + Self.Height - 1,
                         AStr, Caption, Left, Top, Left + Width -1, Top + Height - 1] ));

end; // procedure TN_CMREdit3Frame.Ed3FrDumpFrameRightCaption

//************************************** TN_CMREdit3Frame.IfSlideIsImage ***
// Returns TRUE if Frame Contains Image Slide
//
function TN_CMREdit3Frame.IfSlideIsImage( ) : Boolean;
begin
  Result := FALSE;
  if Self = nil then Exit;
  Result := (EdSlide <> nil) and
            not (TN_UDCMBSlide(EdSlide) is TN_UDCMStudy);
end; // procedure TN_CMREdit3Frame.IfSlideIsImage

//************************************** TN_CMREdit3Frame.IfSlideIsStudy ***
// Returns TRUE if Frame Contains Study Slide
//
function TN_CMREdit3Frame.IfSlideIsStudy( ) : Boolean;
begin
  Result := FALSE;
  if Self = nil then Exit;
  Result := (EdSlide <> nil) and
            (TN_UDCMBSlide(EdSlide) is TN_UDCMStudy);
end; // procedure TN_CMREdit3Frame.IfSlideIsStudy

//********************************** TN_CMREdit3Frame.Ed3FrClearEditContext ***
// Clear Frame current edit context
//
procedure TN_CMREdit3Frame.Ed3FrClearEditContext;
begin
  if (EdViewEditMode = cmrfemCreateVObj1) or
     (EdViewEditMode = cmrfemCreateVObj2) then
  begin
  // Break VObject Creation if needed
    N_CM_MainForm.CMMSkipSelectThumbWhileFinishVObjEditing := TRUE;
    N_CMResForm.aEditPointExecute(nil);
    EdAddVObj1RFA.Execute();
    EdAddVObj2RFA.Execute();
    N_CM_MainForm.CMMSkipSelectThumbWhileFinishVObjEditing := FALSE;
  end;
end; // procedure TN_CMREdit3Frame.Ed3FrClearEditContext



end.
