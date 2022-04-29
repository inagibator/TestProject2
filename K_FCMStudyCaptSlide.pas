unit K_FCMStudyCaptSlide;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  N_BaseF, N_Rast1Fr, K_CM0;

type
  TK_FormCMStudyCaptSlide = class(TN_BaseForm)
    RFrame: TN_Rast1Frame;
    Timer: TTimer;
    BtCancel: TButton;
    RGPreviewTimeout: TRadioGroup;
    BtOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure RFramePaintBoxMouseDown(Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure RGPreviewTimeoutClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    PreviewSlide : TN_UDCMSlide;
  public
    procedure ShowSlide( ASlide : TN_UDCMSlide );
    { Public declarations }
  end;

var
  K_FormCMStudyCaptSlide: TK_FormCMStudyCaptSlide;

implementation

{$R *.dfm}

uses N_Types, K_FCMStudyCapt, K_CML1F, K_VFunc;

var TimeoutVal : array [0..3] of Integer = (0,5000,10000,20000);

//*************************************** TK_FormCMStudyCaptSlide.ShowSlide ***
// Preview new Slide
//
//     Parameters
// ASlide - new Slide to preview
//
procedure TK_FormCMStudyCaptSlide.ShowSlide( ASlide : TN_UDCMSlide );
var
  TimerEnabled : Boolean;
begin
  N_Dump2Str( format( 'Preview Slide=%s(%p)', [ASlide.ObjName, Pointer(ASlide)] ) );
  PreviewSlide := ASlide;
  K_FormCMStudyCapt.BtPreview.Enabled := FALSE;
  if Visible then
  begin
    // Save Timer State
    TimerEnabled   := Timer.Enabled;
    // Stop Timer
    Timer.Enabled := FALSE;

    if IsIconic(Handle) then // Normal Window Size if Minimized
      ShowWindow( Handle, SW_SHOWNORMAL );

    // Show new Slide
    with RFrame do
    begin
      RVCTFrInit3( PreviewSlide.GetMapRoot() );
      N_Dump2Str( 'Preview Change Slide' );
      aFitInWindowExecute( nil );
    end;

    // Show Window on Screen Top
    SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE );
    // Restart Timer
    Timer.Enabled := TimerEnabled;
  end
  else
  begin
    Show();
  end;
end; // procedure TK_FormCMStudyCaptSlide.ShowSlide

//**************************************** TK_FormCMStudyCaptSlide.FormShow ***
// OnShow Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.FormShow(Sender: TObject);
begin
  if PreviewSlide = nil then
  begin
    ModalResult := mrOK;
    Exit;
  end;

  if K_CMStudyCaptImgConfirmDlgCoords.Left = -1000 then
  begin
    K_CMStudyCaptImgConfirmDlgCoords.Left   := K_FormCMStudyCapt.Left;
    K_CMStudyCaptImgConfirmDlgCoords.Top    := K_FormCMStudyCapt.Top;
    K_CMStudyCaptImgConfirmDlgCoords.Right  := K_FormCMStudyCapt.Width;
    K_CMStudyCaptImgConfirmDlgCoords.Bottom := K_FormCMStudyCapt.CMStudyFrame.Height + 32;
  end;

  Left   := K_CMStudyCaptImgConfirmDlgCoords.Left;
  Top    := K_CMStudyCaptImgConfirmDlgCoords.Top;
  Width  := K_CMStudyCaptImgConfirmDlgCoords.Right;
  Height := K_CMStudyCaptImgConfirmDlgCoords.Bottom;

  with RFrame do
  begin
    RFCenterInDst := True;
    RFClearFlags := 0;
    RVCTFrInit3( PreviewSlide.GetMapRoot() );
    N_Dump2Str( 'Preview FormShow' );
    aFitInWindowExecute( nil );
  end;

  SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE );

  RGPreviewTimeout.ItemIndex  := K_IndexOfIntegerInRArray( K_CMStudyCaptPreviewTimeout, @TimeoutVal[0], Length(TimeoutVal) );

end; // procedure TK_FormCMStudyCaptSlide.FormShow

//************************************** TK_FormCMStudyCaptSlide.TimerTimer ***
// Timer OnTimer handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := FALSE;
  N_Dump2Str( 'Preview Timer' );

  // Close Preview Window
  if fsModal in FormState then
    ModalResult := mrOK
  else
    Close();
end; // procedure TK_FormCMStudyCaptSlide.TimerTimer

//************************* TK_FormCMStudyCaptSlide.RFramePaintBoxMouseDown ***
// RFramePaintBox OnMouseDown handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.RFramePaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Close Preview Window
  if fsModal in FormState then
    ModalResult := mrOK
  else
    Close();

end; // procedure TK_FormCMStudyCaptSlide.RFramePaintBoxMouseDown

//*********************************** TK_FormCMStudyCaptSlide.BtCancelClick ***
// BtCancel OnClick handler (Reject Last captured Image)
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.BtCancelClick(Sender: TObject);
var
  SelfTimerEnabled, StudyTimerEnabled : Boolean;
begin

  SelfTimerEnabled := Timer.Enabled;
  Timer.Enabled := FALSE;

  StudyTimerEnabled := K_FormCMStudyCapt.LaunchTimer.Enabled;
  K_FormCMStudyCapt.LaunchTimer.Enabled := FALSE;

  N_Dump2Str( format( 'TK_FormCMStudyCapt >> Start Remove Slide=%s(%p), selected item=%s by user',
                        [PreviewSlide.ObjName, Pointer(PreviewSlide),
                         TN_UDCMStudy(K_FormCMStudyCapt.CMStudyFrame.EdSlide).CMSSelectedItems[0].ObjName] ) );
  if mrYes = K_CMShowMessageDlg( K_CML1Form.LLLCaptToStudy1.Caption,
                        //    'The image will be permanently deleted. Please click Yes to confirm the deletion.',
                             mtConfirmation ) then
  begin // Reject Previewed Slide
    K_FormCMStudyCapt.CaptStudyRemovePrevAddedSlide( PreviewSlide );

    if fsModal in FormState then
      ModalResult := mrOK
    else
      Close();
  end
  else
    Timer.Enabled := SelfTimerEnabled;

  K_FormCMStudyCapt.LaunchTimer.Enabled := StudyTimerEnabled;


end; // procedure TK_FormCMStudyCaptSlide.BtCancelClick

//*************************************** TK_FormCMStudyCaptSlide.FormClose ***
// OnClose Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  N_Dump2Str( 'Preview FormClose' );
  SetWindowPos( Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE );
  // Store Confirm Dlg Screen Coords
  K_CMStudyCaptImgConfirmDlgCoords.Left   := Left;
  K_CMStudyCaptImgConfirmDlgCoords.Top    := Top;
  K_CMStudyCaptImgConfirmDlgCoords.Right  := Width;
  K_CMStudyCaptImgConfirmDlgCoords.Bottom := Height;
  K_FormCMStudyCaptSlide := nil;

  with K_FormCMStudyCapt do
  begin
    if K_CMStudyCaptState <> K_cmscSkipPreview then
      BtPreview.Enabled := StudyPrevAddSlide <> nil;
    CaptStudyAutoTakeTry( );
  end;
end; // procedure TK_FormCMStudyCaptSlide.FormClose

//*************************** TK_FormCMStudyCaptSlide.RGPreviewTimeoutClick ***
// RGPreviewTimeout OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.RGPreviewTimeoutClick(Sender: TObject);
begin
  K_CMStudyCaptPreviewTimeout := TimeoutVal[RGPreviewTimeout.ItemIndex];
  N_Dump2Str( 'Preview Timeout=' + IntToStr(K_CMStudyCaptPreviewTimeout) );
  // Restart Timer
  Timer.Enabled := FALSE;
  Timer.Enabled := K_CMStudyCaptPreviewTimeout > 0;
  // Set New Timer Interval
  if Timer.Enabled then
    Timer.Interval := K_CMStudyCaptPreviewTimeout;
end; // procedure TK_FormCMStudyCaptSlide.RGPreviewTimeoutClick

//*************************************** TK_FormCMStudyCaptSlide.BtOKClick ***
// BtOK OnClick handler 
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyCaptSlide.BtOKClick(Sender: TObject);
begin
  // Close Preview Window
  if fsModal in FormState then
    ModalResult := mrOK
  else
    Close();

end; // procedure TK_FormCMStudyCaptSlide.BtOKClick

end.
