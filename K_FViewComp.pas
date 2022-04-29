unit K_FViewComp;
// TN_Rast1Frame Base Form for Viewing Visual Components Tree

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, ImgList, ActnList,
  K_Script1, K_FBase, K_Types, K_UDT1,
  N_Types, N_Lib1, N_BaseF, N_Rast1Fr, N_CompBase, ExtCtrls;


type TK_PrepCompContextProc = procedure ( ContextAttr : Integer ) of object;
type TK_ViewCompFlags = set of (K_vcfSkipShow, K_vcfSetFrameState);
//type TK_ClearParentRefProc = procedure ( Sender : Tobject; SelfClose : Boolean ) of object;
//type TK_FormViewComp = class( TN_BaseForm )
type TK_FormViewComp = class( TK_FormBase )
    RFrame: TN_Rast1Frame;
    StatusBar: TStatusBar;

    ActionList1: TActionList;
      FitInWindow:         TAction;
      ZoomToOriginalSize:  TAction;
      ZoomIn:              TAction;
      ZoomOut:             TAction;
      ExportToClipBoard:   TAction;
      SkipComponentChange: TAction;
      SaveComponentCopy:   TAction;

    ToolBar1: TToolBar;
      ToolButton1: TToolButton;
      ToolButton2: TToolButton;
      ToolButton3: TToolButton;
      ToolButton4: TToolButton;
      ToolButton5: TToolButton;
      ToolButton6: TToolButton;
      ToolButton7: TToolButton;
      ToolButton8: TToolButton;
      ToolButton9: TToolButton;
      ToolButton10: TToolButton;

    procedure FormActivate (Sender: TObject); override;
    procedure FormClose (Sender: TObject; var Action: TCloseAction); override;
    procedure FormCreate(Sender: TObject);
    procedure SkipComponentChangeExecute(Sender: TObject);
    procedure FitInWindowExecute(Sender: TObject);
    procedure ExportToClipBoardExecute(Sender: TObject);
    procedure ZoomToOriginalSizeExecute(Sender: TObject);
    procedure ZoomInExecute(Sender: TObject);
    procedure ZoomOutExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveComponentCopyExecute(Sender: TObject);

  public
    { Public declarations }
    PrepCompContextObj : TK_PrepCompContext;
    PrepCompContextAttr: Integer;
    OnPrepCompContext  : TK_PrepCompContextProc;
    OnSaveComponentCopy: TK_SaveUDSubTreeCopyProc;
    OnFormActivate : TK_FormOnActivate;

    SkipActivateRebuild : Boolean;

    RFCoordsState : TN_RFCoordsState;


    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
    procedure ShowComponent( AVCFlags : TK_ViewCompFlags; ACaption : string;
                             UDComp : TN_UDCompVis;
                             APRFCoordsState : TN_PRFCoordsState = nil;
                             APVFInitParams : TN_PRFInitParams = nil );
  private
    RFCStateType  : TK_ExprExtType;
    SkipSaveStateToIni : Boolean; // Skip Save Self State to IniFile

end; // type TN_Rast1BaseForm = class( TN_BaseForm )
type TK_PFormViewComp = ^TK_FormViewComp;

//****************** Global procedures **********************

function  K_CreateVCForm( AOwner: TN_BaseForm; IniName : string ): TK_FormViewComp;

implementation
uses
  K_CLib, K_IMVDar,
  N_ButtonsF;
{$R *.dfm}

//************************************************ TK_FormViewComp.FormActivate
//
procedure TK_FormViewComp.FormActivate( Sender: TObject );
// rebuild RFame.Component ViewContext (neede if in several windows Pictures
// build from single pattern VComTree by different ViewContext are shown)
// and call RFrame.OnActivateFrame to set N_ActiveRFrame variable
// (OnActivate Form event handler)
var
  UDB2 : array [0..1] of TN_UDBase;
begin
  inherited;
  if SkipActivateRebuild then begin
    SkipActivateRebuild := false;
    Exit;
  end;
  if Assigned( OnPrepCompContext ) then
    OnPrepCompContext( PrepCompContextAttr );
  if Assigned(PrepCompContextObj) then begin
    PrepCompContextObj.SetContext();
    if Assigned(OnFormActivate) then
    begin
      PrepCompContextObj.PrepFormActivateParams( UDB2[0] );
      UDB2[1] := RFrame.RVCTreeRoot;
      OnFormActivate( UDB2[0] );
    end;
  end;
  RFrame.RedrawAllAndShow();
  RFrame.OnActivateFrame();
end; // procedure TK_FormViewComp.FormActivate

//************************************************ TK_FormViewComp.FormClose
//
procedure TK_FormViewComp.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  if Assigned(OnClearParentRef) then OnClearParentRef( Self, true );
  PrepCompContextObj.Free;
  Inherited;
  RFrame.RFFreeObjects();
end; // procedure TK_FormViewComp.FormClose

//************************************************ TK_FormViewComp.FormCreate
//
procedure TK_FormViewComp.FormCreate(Sender: TObject);
begin
  inherited;
  RFCoordsState := N_DefRFCoordsState;
  RFCStateType := K_GetTypeCodeSafe( 'TN_RFCoordsState' );
  RFrame.RFrActionFlags := RFrame.RFrActionFlags - [rfafShowCoords]; // RFrameActions control Flags
  RFrame.RFrActionFlags := RFrame.RFrActionFlags + [rfafScrollCoords]; // RFrameActions control Flags
  RFrame.RFrActionFlags := RFrame.RFrActionFlags - [rfafShowColor]; // RFrameActions control Flags
  RFrame.RFCenterInDst := TRUE;
  RFrame.RFGetActionByClass( N_ActZoom ).ActEnabled := True;

end; // procedure TK_FormViewComp.FormCreate

//************************************************ TK_FormViewComp.CurStateToMemIni
//
procedure TK_FormViewComp.CurStateToMemIni;
begin
  if SkipSaveStateToIni then Exit;
  inherited;
  RFrame.GetCoordsState( @RFCoordsState );
  N_SPLValToMemIni( BFSelfName, 'RFCState', RFCoordsState, RFCStateType.DTCode );
end; // procedure TK_FormViewComp.CurStateToMemIni

//************************************************ TK_FormViewComp.MemIniToCurState
//
procedure TK_FormViewComp.MemIniToCurState;
begin
  inherited;
  N_MemIniToSPLVal( BFSelfName, 'RFCState', RFCoordsState, RFCStateType.DTCode );
  K_PosTwinForm( Self );
end; // procedure TK_FormViewComp.MemIniToCurState

//************************************************ TK_FormViewComp.SkipComponentChangeExecute
//
procedure TK_FormViewComp.SkipComponentChangeExecute(Sender: TObject);
begin
  SkipComponentChange.Visible := false;
  if Assigned(PrepCompContextObj) then begin
    PrepCompContextObj.BuildSelfAttrs();
    PrepCompContextObj.CCPSkipRebuildAttrsFlag := true;
  end;
   // (PSelfReference <> nil) and (PObject(PSelfReference)^ = Self);
  if not Assigned(OnClearParentRef) then Exit;
  CurStateToMemIni;
  OnClearParentRef( Self, false );
  SkipSaveStateToIni := true;

//    PObject(PSelfReference)^ := nil;
end; // procedure TK_FormViewComp.SkipComponentChangeExecute

//************************************************ TK_FormViewComp.FitInWindowExecute
//
procedure TK_FormViewComp.FitInWindowExecute(Sender: TObject);
begin
  RFrame.aFitInWindowExecute( Sender );
end; // procedure TK_FormViewComp.SaveViewStateExecute

//************************************************ TK_FormViewComp.ExportToClipBoardExecute
//
procedure TK_FormViewComp.ExportToClipBoardExecute(Sender: TObject);
begin
  RFrame.aCopyToClipboardExecute( Sender );
end; // procedure TK_FormViewComp.ExportToClipBoardExecute

//************************************************ TK_FormViewComp.ZoomToOriginalSizeExecute
//
procedure TK_FormViewComp.ZoomToOriginalSizeExecute(Sender: TObject);
begin
  RFrame.aFitInCompSizeExecute( Sender );
  RFrame.OnResizeFrame( Sender );
end; // procedure TK_FormViewComp.ZoomToOriginalSizeExecute

//************************************************ TK_FormViewComp.ZoomInExecute
//
procedure TK_FormViewComp.ZoomInExecute(Sender: TObject);
begin
  RFrame.aZoomInExecute( Sender );
end; // procedure TK_FormViewComp.ZoomInExecute

//************************************************ TK_FormViewComp.ZoomOutExecute
//
procedure TK_FormViewComp.ZoomOutExecute(Sender: TObject);
begin
  RFrame.aZoomOutExecute( Sender );
end; // procedure TK_FormViewComp.ZoomOutExecute

//************************************************ TK_FormViewComp.FormShow
//
procedure TK_FormViewComp.FormShow(Sender: TObject);
begin
  SkipComponentChange.Visible := Assigned(OnClearParentRef);
  SaveComponentCopy.Visible := Assigned(OnSaveComponentCopy);
end; // procedure TK_FormViewComp.FormShow

//*************************************** TK_FormViewComp.SaveComponentCopyExecute
//
procedure TK_FormViewComp.SaveComponentCopyExecute(Sender: TObject);
begin
  OnSaveComponentCopy( RFrame.RVCTreeRoot,
      K_MVDARSysObjAliases[Ord(K_msdMVRVisComp)] + ' "' + Self.Caption + '"' );
end; //*** end of procedure TK_FormViewComp.SaveComponentCopyExecute

//*************************************** TK_FormViewComp.ShowComponent
//
procedure TK_FormViewComp.ShowComponent( AVCFlags : TK_ViewCompFlags;
                                         ACaption : string; UDComp : TN_UDCompVis;
                                         APRFCoordsState : TN_PRFCoordsState = nil;
                                         APVFInitParams : TN_PRFInitParams = nil );
var
  CurRFCState : TN_RFCoordsState;
  CVFInitParams : TN_RFInitParams;

begin
  Caption := ACaption;

  if Assigned(PrepCompContextObj) then
    with PrepCompContextObj do begin
      SetContext();
      BuildHints( RFrame.InfoStrings );
    end;
//K_vcfSkipShow, K_vcfSetFrameState  (K_vcfSkipShow in AVCFlags)
  if not Visible                    or
     (RFrame.RVCTreeRoot <> UDComp) or
     (K_vcfSetFrameState in AVCFlags) then begin
    if APRFCoordsState = nil then begin
      APRFCoordsState := @CurRFCState;
      CurRFCState := N_DefRFCoordsState
    end;

    if APVFInitParams = nil then begin
      CVFInitParams  := N_DefRFInitParams;
      APVFInitParams := @CVFInitParams;
    end;

    with RFrame do  begin
      RFrInitByComp( UDComp );
      InitializeCoords( APVFInitParams, APRFCoordsState );
    end;
  end;

  SkipActivateRebuild := true;
  if Visible and not (K_vcfSkipShow in AVCFlags) then begin
    RFrame.RedrawAllAndShow();
  end else begin
    RFrame.RedrawAll();
    if not (K_vcfSkipShow in AVCFlags) then Show();
  end;

end; //*** end of procedure TK_FormViewComp.ShowComponent

//****************** Global procedures **********************

//************************************************ K_CreateVCForm
// Create and return new instance of TK_FormViewComp
//
// AOwner  - Owner of created Rast1BaseForm
//
function K_CreateVCForm( AOwner: TN_BaseForm; IniName : string ): TK_FormViewComp;
begin
  Result := TK_FormViewComp.Create( Application );
  with Result do begin
    // Remark: Result.SelfName should be set (if needed) before call to BaseFormInit
    // Common Init Form Code
    BaseFormInit( AOwner, IniName );
    ActiveControl := RFrame;

//    RFrame.ParentForm := Result;
    RFrame.SomeStatusbar := StatusBar;
  end;
end; // end of function K_CreateVCForm


end.

