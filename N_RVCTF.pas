unit N_RVCTF;
// Form with TN_Rast1Frame for Viewing Visual Components Tree

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, ImgList, Contnrs,
  K_UDT1, K_Script1,
  N_Types, N_BaseF, N_Rast1Fr, N_CompBase, ActnList;

type TN_RastVCTForm = class( TN_BaseForm )
    RFrame: TN_Rast1Frame;
    RVCTFToolBar1: TToolBar;
    ToolButton1: TToolButton;
    StatusBar: TStatusBar;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    tbRefresh: TToolButton;
    ToolButton5: TToolButton;
    ToolButton3: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton12: TToolButton;
    ToolButton10: TToolButton;
    RVCTFActionList: TActionList;
    aShowRubberRect: TAction;

    //**************** RVCTFActionList OnExecute event handlers *************
    procedure aShowRubberRectExecute ( Sender: TObject );

    procedure FormActivate ( Sender: TObject ); override;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction); override;

    procedure WndProc       ( var Msg: TMessage ); override;
    procedure tbDebug1Click ( Sender: TObject );
    procedure tbDebug2Click ( Sender: TObject );
    procedure tbDebug3Click ( Sender: TObject );
//    procedure FormKeyDown ( Sender: TObject; var Key: Word;
//                                                       Shift: TShiftState );
  public
    WndProcessKey: TN_OneIntProcObj;
  function  InitVCTForm  ( AComp: TN_UDCompVis; AModalModeFlag: TN_ModalModeFlag; APRFInitParams: TN_PRFInitParams = nil; APCoords: TN_PRFCoordsState = nil ): integer;
  procedure ShowPictFile ( AFName: string );
end; // type TN_RastVCTForm = class( TN_BaseForm )
type TN_PRastVCTForm = ^TN_RastVCTForm;


//****************** Global procedures **********************

procedure N_ViewCompFull  ( AComp: TN_UDCompVis; APRForm: TN_PRastVCTForm;
                              AOwner: TN_BaseForm; ACaption: string = '' );
procedure N_ViewCompFull2 ( AComp: TN_UDBase; ACaption: string; AOwner: TN_BaseForm );
function  N_ViewEmptyComp ( ASize: TPoint; ACaption: string = '';
                                          AOwner: TN_BaseForm = nil ): TN_RastVCTForm;
function  N_CreateRastVCTForm ( AOwner: TN_BaseForm = nil ): TN_RastVCTForm; overload;
procedure N_CreateRastVCTForm ( APRForm: TN_PRastVCTForm; AOwner: TN_BaseForm ); overload;


implementation
uses
  N_ClassRef, N_Lib0, N_Lib2, N_Gra0, N_Gra1, N_Gra2, N_LibF, N_CompCL, N_InfoF,
  N_ME1, N_ButtonsF, N_Comp1, N_NVTreeFr, N_UDCMap, N_SGComp; // N_Rast1BF,
{$R *.dfm}

procedure TN_RastVCTForm.aShowRubberRectExecute( Sender: TObject );
// Show Rubber Rect, now only for measuring needs
begin
  with TN_RubberRectRFA(RFrame.RFRubberRectAction) do
  begin
    if aShowRubberRect.Checked then // Enable RFRubberRectAction
    begin
      RRConP2UComp := RFrame.RVCTreeRoot;
      RRCurUserRect := N_RectScaleR( RRConP2UComp.PSP.CCoords.CompUCoords, 0.9, DPoint(0.5,0.5) );
      ActEnabled := True;
      ActMaxURect := RRConP2UComp.PSP.CCoords.CompUCoords;
//      RFrame.RFRubberRectStr := ' asd';
    end else //*********************** Disable RFRubberRectAction
    begin
      RRConP2UComp := nil;
      ActEnabled := False;
      Screen.Cursor := crDefault;
    end;
  end; // with TN_RubberRectRFA(RFRubberRectAction) do

  RFrame.RedrawAllAndShow();
end; // procedure TN_RastVCTForm.aShowRubberRectExecute

procedure TN_RastVCTForm.FormActivate( Sender: TObject );
// just call RFrame.OnActivateFrame to set N_ActiveRFrame variable
// (OnActivate Form event handler)
begin
  Inherited;
  RFrame.OnActivateFrame();
end; // procedure TN_RastVCTForm.FormActivate

procedure TN_RastVCTForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  RFrame.RFFreeObjects();
  Inherited;
end; // procedure TN_RastVCTForm.FormClose

//************************************************** TN_RastVCTForm.WndProc ***
// initial Window Proc
//
procedure TN_RastVCTForm.WndProc( var Msg: TMessage );
begin
//  N_IAdd( Format( 'Form WndProc All(%3d): %.8x %.8x %.8x', [N_i2, Msg.Msg, Msg.WParam, Msg.LParam] ) );
//  Inc(N_i2);

  if Msg.Msg = $B02E then
  begin
    if Assigned(WndProcessKey) then WndProcessKey( Msg.WParam );
  end else
    Inherited WndProc( Msg );
{
  if Msg.Msg = $B005 then
  begin
    N_IAdd( Format( 'Form WndProc $B005: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else

  if Msg.Msg = $B005 then
  begin
    N_IAdd( Format( 'Form WndProc $B005: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
  if Msg.Msg = $B006 then
  begin
    N_IAdd( Format( 'Form WndProc $B006: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
  if Msg.Msg = $B02E then
  begin
    N_IAdd( Format( 'Form WndProc $B02E: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
  if Msg.WParam = $0031 then
  begin
    N_IAdd( Format( 'Form WndProc W=$0031: M=%.8x,  L=%.8x', [Msg.Msg, Msg.LParam] ) );
  end else
  if (Msg.LParam and $FF0000) = $030000 then
  begin
    N_IAdd( Format( 'Form WndProc L=$030000: M=%.8x, L=%.8x, W=%.8x', [Msg.Msg, Msg.WParam, Msg.LParam] ));
  end else

  if Msg.Msg = WM_KEYDOWN then
  begin
    N_IAdd( Format( 'Form WndProc Down: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
  if Msg.Msg = WM_KEYUP then
  begin
    N_IAdd( Format( 'Form WndProc Up: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
    Inherited WndProc( Msg );
}
end; // procedure TN_RastVCTForm.WndProc

procedure TN_RastVCTForm.tbDebug1Click( Sender: TObject );
//
begin
end; // procedure TN_RastVCTForm.tbDebug1Click

procedure TN_RastVCTForm.tbDebug2Click( Sender: TObject );
//
begin
end; // procedure TN_RastVCTForm.tbDebug2Click

procedure TN_RastVCTForm.tbDebug3Click( Sender: TObject );
//
begin
end; // procedure TN_RastVCTForm.tbDebug3Click

{
//***************************************** TN_Rast1Frame.WndProc ***
// initial Window Proc
//
procedure TN_RastVCTForm.WndKeyGet( WParam: Longint );
begin
//  N_IAdd( Format( 'Form WndProc All(%3d): %.8x %.8x %.8x', [N_i2, Msg.Msg, Msg.WParam, Msg.LParam] ) );
//  Inc(N_i2);
WParam: Longint

  if Msg.Msg = $B005 then
  begin
    N_IAdd( Format( 'Form WndProc $B005: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end;
end; // procedure TN_RastVCTForm.WndProc
}

{
procedure TN_RastVCTForm.FormKeyDown( Sender: TObject; var Key: Word;
                                               Shift: TShiftState );
// Do NOT receive Keys!
begin
    N_IAdd( Format( 'Form KeyDown: %.8x', [Key] ) );
end;
}

//********************************************** TN_RastVCTForm.InitVCTForm ***
// Init by given Visual Component, redraw and Show Self
// Return 0 or ModalResult
//
function TN_RastVCTForm.InitVCTForm( AComp: TN_UDCompVis; AModalModeFlag: TN_ModalModeFlag;
                                     APRFInitParams: TN_PRFInitParams = nil;
                                     APCoords: TN_PRFCoordsState = nil ): integer;
begin
//  RFrame.RVCTFrInit( AComp ); // old var

  RFrame.RFrInitByComp( AComp );
  if (APRFInitParams = nil) and (APCoords = nil) then
    RFrame.InitializeCoords()
  else
    RFrame.InitializeCoords( APRFInitParams, APCoords );

  RFrame.RFGetActionByClass( N_ActZoom ).ActEnabled := True;
  Result := 0;



  if Visible then
    RFrame.RedrawAllAndShow()
  else // now Form in not visible, redraw and make it visible
  begin
    RFrame.RedrawAll();

    if AModalModeFlag = mmfModal then // Show in Modal mode and return ModalResult
      Result := ShowModal()
    else // Show in not Modal mode
      Show();

  end; // else // now Form in not visible, redraw and make it visible

end; // procedure TN_RastVCTForm.InitVCTForm

//***************************************** TN_RastVCTForm.ShowPictFile ***
// Init Self by given Visual Component
//
procedure TN_RastVCTForm.ShowPictFile( AFName: string );
var
  UDPict: TN_UDPicture;
begin
  UDPict := N_CreateUDPicture( cptFile, rtBArray, AFName );
  InitVCTForm( UDPict, mmfNotModal );
  RFrame.aInitFrameExecute( TObject(2) ); // adjust Form size by component
end; // procedure TN_RastVCTForm.ShowPictFile


//****************** Global procedures **********************

//*******************************************  N_ViewCompFull  ******
// View given Component in new or existing Form
//
// PRForm  - Pointer to TN_RastVCTForm or nil, if new RastVCTForm should
//                                             be created in any variable
// AOwner  - Owner of new RastVCTForm (is used only if PRForm=nil or PRForm^=nil)
// AComp   - Root of Visual Components Tree to draw
// CaptionPrefix - Prefix in Form Caption before AComp.ObjName
//
// in RastVCTForm.FormClose PRForm^ will be cleared (if PRForm <> nil) and
// AComp will be deleted if AComp.RefCounter = 0
//
procedure N_ViewCompFull( AComp: TN_UDCompVis; APRForm: TN_PRastVCTForm;
                                 AOwner: TN_BaseForm; ACaption: string );
var
  NewForm: TN_RastVCTForm;
  PForm: TN_PRastVCTForm;
begin
  if AComp = nil then Exit;

  if APRForm <> nil then
  begin
    N_CreateRastVCTForm( APRForm, AOwner );
    PForm := APRForm;
  end else
  begin
    NewForm := N_CreateRastVCTForm( AOwner );
    NewForm.Left := NewForm.Left + 16;
    NewForm.Top  := NewForm.Top  + 16;
    PForm := @NewForm;
  end;

  with PForm^ do
  begin
    Caption := ACaption;
    if AComp <> nil then
    begin
      if ACaption <> '' then Caption := ACaption
                        else Caption := AComp.ObjName;
    end;

    InitVCTForm( AComp, mmfNotModal );
  end;
end; // procedure N_ViewCompFull

//*******************************************  N_ViewCompFull2  ******
// View given Component in N_MEGlobObj.RastVCTForm without any controls
//
// AComp  - Root of Visual Components Tree to draw
// AOwner - Owner of RastVCTForm
//
procedure N_ViewCompFull2( AComp: TN_UDBase; ACaption: string; AOwner: TN_BaseForm );
begin
  if not (AComp is TN_UDCompVis) then Exit;

  N_CreateRastVCTForm( @N_MEGlobObj.RastVCTForm, AOwner );

  with N_MEGlobObj.RastVCTForm do
  begin
    if ACaption <> '' then Caption := ACaption
                      else Caption := AComp.ObjName;
    RVCTFToolBar1.Visible := False;
    StatusBar.Visible := False;
    InitVCTForm( TN_UDCompVis(AComp), mmfNotModal );
    RFrame.aInitFrameExecute( TObject(2) ); // adjust Form size by component
  end;
end; // procedure N_ViewCompFull2

//*******************************************  N_ViewEmptyComp  ******
// View empty Component (for manual drawing on created canvas)
//
function N_ViewEmptyComp( ASize: TPoint; ACaption: string;
                                         AOwner: TN_BaseForm ): TN_RastVCTForm;
var
  DefEmptyComp: TN_UDCompVis;
begin
  DefEmptyComp := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
  with DefEmptyComp.PCCS()^ do
  begin
    SRSize := FPoint( ASize );
    SRSizeXType := cstPixel;
  end;
  N_ViewCompFull( DefEmptyComp, @N_MEGlobObj.RastVCTFormTmp, AOwner, ACaption );
  Result := N_MEGlobObj.RastVCTFormTmp;
  Result.RFrame.aInitFrameExecute( TObject(2) ); // adjust Form size by component
end; // procedure N_ViewEmptyComp

//*********************************************  N_CreateRastVCTForm(1)  ******
// Create new instance of N_RastVCTForm
//
function N_CreateRastVCTForm( AOwner: TN_BaseForm ): TN_RastVCTForm;
begin
  Result := TN_RastVCTForm.Create( Application );
  with Result do
  begin
    BFSelfName := 'RasterForm';
    BaseFormInit( AOwner );
    ActiveControl := RFrame;

//    RFrame.ParentForm := Result;
    RFrame.SomeStatusbar := StatusBar;
    RFrame.RFDebName := RFrame.Name;

    RFrame.RFOneGroup := TN_SGComp.Create( RFrame );
    RFrame.RFSGroups.Add( RFrame.RFOneGroup );

    with TN_SGComp(RFrame.RFOneGroup) do
    begin
      GName := 'OneGroup';
      SGFlags := $04; // redraw RFA actions without using seach components context (see TN_Rast1Frame.RedrawAllSGroupsActions)
      RFrame.RFRubberRectAction := SetAction( N_ActRubberRect, $00 );
      TN_RubberRectRFA(RFrame.RFRubberRectAction).ActEnabled := False;
    end; // with RFrame.RFOneGroup do

  end; // with Result do
end; // end of function N_CreateRastVCTForm(1)

//*********************************************  N_CreateRastVCTForm(2)  ******
// Create (if not already created) RastVCTForm in given variable
// AOwner  - Owner of new RastVCTForm
//
// APRForm should points to GLOBAL variable,
// because it would be set to nil in OnCloseForm Handler!
//
procedure N_CreateRastVCTForm( APRForm: TN_PRastVCTForm; AOwner: TN_BaseForm );
begin
  Assert( APRForm <> nil, 'APRForm=nil!' ); // a precaution

  if APRForm^ = nil then // new RastVCTForm should be created in
  begin                  // given variable, pointed to by APRForm
    APRForm^ := N_CreateRastVCTForm( AOwner );
    APRForm^.BFOnCloseActions.AddNewClearVarAction( APRForm );
  end;
end; // end of procedure N_CreateRastVCTForm(2)


end.
