unit K_FCMSZoomMode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, StdCtrls, ComCtrls;

type
  TK_FormCMSZoomMode = class(TN_BaseForm)
    ZoomTrackBar: TTrackBar;
    Lb100_: TLabel;
    Lb800_: TLabel;
    Lb200_: TLabel;
    Lb700_: TLabel;
    Lb300_: TLabel;
    Lb400_: TLabel;
    Lb500_: TLabel;
    Lb600_: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure ZoomTrackBarChange(Sender: TObject);
  private
    { Private declarations }
    PrevRFrame : TObject;
    SkipSliderChange : Boolean;
    procedure TrackBarChangeRedraw();
  public
    { Public declarations }
    procedure SetByCurActiveFrame();
  end;

  function K_CMSZoomModeFormGet() : TK_FormCMSZoomMode;

implementation

{$R *.dfm}

uses Types, 
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra0, N_CMMain5F, N_CMREd3Fr, N_Rast1Fr;

//**************************************************** K_CMSZoomModeFormGet ***
//  Get Zoom Mode dialog form
//
//     Parameters
// Result - Returns Zoom Mode dialog form
//
function K_CMSZoomModeFormGet() : TK_FormCMSZoomMode;
begin
  Result := TK_FormCMSZoomMode.Create(Application);
  with Result, N_CM_MainForm.CMMFActiveEdFrame.RFrame do
  begin
    BFIniPos := ClientToScreen( Point(0,0) );
    BaseFormInit( nil, '', [rspfMFRect,rspfShiftAll], [rspfAppWAR,rspfShiftAll] );
  end;
end; // function K_CMSZoomModeFormGet

//********************************************* TK_FormCMSZoomMode.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSZoomMode.FormShow(Sender: TObject);
begin
//  Width := 70;
  Width := BFFormMinSize.X;
end;

//********************************** TK_FormCMSZoomMode.SetByCurActiveFrame ***
//  Set new current active EdFrame
//
procedure TK_FormCMSZoomMode.SetByCurActiveFrame;
begin
//
  if (Self = nil) or SkipSliderChange then Exit;
  SkipSliderChange := TRUE;
  with N_CM_MainForm do
    if not CMMFCheckBSlideExisting() then
    begin
      PrevRFrame := nil;
      ZoomTrackBar.Position := ZoomTrackBar.Max;
      ZoomTrackBar.Enabled := FALSE;
    end
    else
    begin
      PrevRFrame := CMMFActiveEdFrame.RFrame; // Get RFrameZoomFactor
      ZoomTrackBar.Position := Round(830 - 100 * TN_Rast1Frame(PrevRFrame).RFGetCurRelObjSize());
      ZoomTrackBar.Enabled := TRUE;
    end;
    SkipSliderChange := FALSE;
end; // procedure TK_FormCMSZoomMode.SetByCurActiveFrame;

//************************************* TK_FormCMSFlashlightAttrs.FormClose ***
//  On Form Close Handler
//
procedure TK_FormCMSZoomMode.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i : Integer;
begin
  inherited;
  K_CMSZoomForm := nil;
  with N_CM_MainForm do
  begin
  // Finish Image Scroll Mode in all opened Frames
    for i := 0 to High(CMMFEdFrames) do
      if CMMFEdFrames[i] <> nil then
        with CMMFEdFrames[i], RFrame, EdMoveVObjRFA do
        begin
          ImageScrollMode := FALSE;
          RFrActionFlags := RFrActionFlags - [rfafScrollCoords];
          N_SetMouseCursorType( RFrame, crDefault );
        end;
    CMMFDisableActions( Sender );
  end;

end; // procedure TK_FormCMSZoomMode.FormClose

//**************************** TK_FormCMSFlashlightAttrs.ZoomTrackBarChange ***
//  On TrackBar Change Handler
//
procedure TK_FormCMSZoomMode.ZoomTrackBarChange(Sender: TObject);
var
  NP : TK_NotifyProc;

begin
  if (PrevRFrame <> nil) and not SkipSliderChange then
  begin
    if K_CMSkipMouseMoveRedraw > 0 then
    begin
      NP := TrackBarChangeRedraw;
      if not Assigned(K_CMRedrawObject.OnRedrawProcObj) or
         (TMethod(NP).Code <> TMethod(K_CMRedrawObject.OnRedrawProcObj).Code) then
//         not CompareMem( @K_CMRedrawObject.OnRedrawProcObj, @NP, SizeOf(TK_NotifyProc) ) then
        K_CMRedrawObject.InitRedraw( TrackBarChangeRedraw );
      K_CMRedrawObject.Redraw()
    end
    else
      TrackBarChangeRedraw();
{
    SkipSliderChange := TRUE;
    with TN_Rast1Frame(PrevRFrame) do
    begin
      RFVectorScale := RFVectorScale * (830 - ZoomTrackBar.Position) / Round(100 * RFGetCurRelObjSize());
      SetZoomLevel( rfzmCenter );
      ZoomTrackBar.Position := Round(830 - 100 * RFGetCurRelObjSize());
    end;
    SkipSliderChange := FALSE;
}
  end;

end; // procedure TK_FormCMSZoomMode.ZoomTrackBarChange

//************************** TK_FormCMSFlashlightAttrs.TrackBarChangeRedraw ***
//  On TrackBar Change Redraw routine
//
procedure TK_FormCMSZoomMode.TrackBarChangeRedraw;
begin
  SkipSliderChange := TRUE;
  with TN_Rast1Frame(PrevRFrame) do
  begin
    RFVectorScale := RFVectorScale * (830 - ZoomTrackBar.Position) / Round(100 * RFGetCurRelObjSize());
    SetZoomLevel( rfzmCenter );
    ZoomTrackBar.Position := Round(830 - 100 * RFGetCurRelObjSize());
  end;
  SkipSliderChange := FALSE;
end; // procedure TK_FormCMSharpSmooth.TrackBarChangeRedraw

end.
