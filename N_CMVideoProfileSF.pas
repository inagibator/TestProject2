unit N_CMVideoProfileSF;
// Video Profile Editor Settings Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus,
  K_CM0,
  N_Types, N_Lib1, N_BaseF, StdCtrls, ExtCtrls, N_Video4, DirectShow9;

type TN_CMVideoProfileSForm = class( TN_BaseForm )
    rgVCMode: TRadioGroup;
    edFreezeUnfreeze: TEdit;
    edSaveAndUnfreeze: TEdit;
    bnOK: TButton;
    GroupBox1: TGroupBox;
    rbFreezeUnfreeze: TRadioButton;
    rbSaveAndUnfreeze: TRadioButton;
    bnReset: TButton;
    CmBStillPin: TCheckBox;
    lbRenderer: TLabel;
    cbRenderer: TComboBox;
    lbFilter: TLabel;
    cbFilter: TComboBox;
    cbClose: TCheckBox;
    lbCloseBottom: TLabel;
    gbSironaMode: TGroupBox;
    cbActivateMode: TCheckBox;
    cbCloseMode: TCheckBox;

    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown  ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyPress ( Sender: TObject; var Key: Char );
    procedure bnOKClick    ( Sender: TObject );
    procedure FormShow     ( Sender: TObject );
    procedure rbFreezeUnfreezeClick ( Sender: TObject );
    procedure rbSaveAndUnfreezeClick( Sender: TObject );
    procedure bnResetClick          ( Sender: TObject );
    procedure rgVCModeClick         ( Sender: TObject );

  public
    PVProfile: TK_PCMVideoProfile;
    PVEnableKeystrokes: Bool;

end; // type TN_CMVideoProfileSForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_CreateCMVideoProfileSForm ( AOwner: TN_BaseForm ): TN_CMVideoProfileSForm;
function  N_GetCMVideoProfileSForm    ( AOwner: TN_BaseForm ): TN_CMVideoProfileSForm;

var
  N_CMVideoProfileSForm: TN_CMVideoProfileSForm;

implementation
uses
  N_CMFPedalSF, N_CMVideoProfileF;
{$R *.dfm}

//****************  TN_CMVideoProfileSForm class handlers  ******************

//*********************************************** TN_CMVideoProfileSForm.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMVideoProfileSForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_CMVideoProfileSForm.FormClose


//****************  TN_CMVideoProfileSForm class public methods  ************


    //*********** Global Procedures  *****************************

//**************************************************** N_CreateCMVideoProfileSForm ***
// Create and return new instance of TN_CMVideoProfileSForm
//
//     Parameters
// AOwner - Owner of created Form
// Result - Return created Form
//
function N_CreateCMVideoProfileSForm( AOwner: TN_BaseForm ): TN_CMVideoProfileSForm;
begin
  Result := TN_CMVideoProfileSForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    CurArchiveChanged();
  end;
end; // function N_CreateCMVideoProfileSForm

//******************************************************* N_GetCMVideoProfileSForm ***
// Create TN_CMVideoProfileSForm if needed and return it
//
//     Parameters
// AOwner - Self Owner or nil if not given
// Result - Return created or already existing Form
//
function N_GetCMVideoProfileSForm( AOwner: TN_BaseForm ): TN_CMVideoProfileSForm;
begin
  if N_CMVideoProfileSForm <> nil then // already opened
  begin
    Result := N_CMVideoProfileSForm;
    Result.SetFocus;
    Exit;
  end;

  N_CMVideoProfileSForm := TN_CMVideoProfileSForm.Create( Application );
  Result := N_CMVideoProfileSForm;
  with Result do
  begin
    BaseFormInit( AOwner );
    CurArchiveChanged();
  end; // with Result do
end; // end of function N_GetCMVideoProfileSForm

//************************************** TN_CMVideoProfileSForm.FormKeyDown ***
// Enter Keystrokes for "Keystroke" Camera button device
//
//     Parameters
// Sender - Event Sender
// Key    - Virtual Keyboard key
// Shift  - Shift Flags
//
// OnKeyDown Self handler
//
procedure TN_CMVideoProfileSForm.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  if rbFreezeUnfreeze.Enabled then
  begin

    if (Key = VK_SHIFT) or (Key = VK_CONTROL) or (Key = VK_MENU) then
      Exit;

    if rbFreezeUnfreeze.Checked then
    begin
      edFreezeUnfreeze.Text := ShortCutToText( ShortCut( Key, Shift ) );
      N_Dump1Str( Format( 'edFreezeUnfreeze.Text = %s (%d)', [edFreezeUnfreeze.Text,Key] ) );
    end;

    if rbSaveAndUnfreeze.Checked then
    begin
      edSaveAndUnfreeze.Text := ShortCutToText( ShortCut( Key, Shift ) );
      N_Dump1Str( Format( 'edSaveAndUnfreeze.Text = %s (%d)', [edSaveAndUnfreeze.Text,Key] ) );
    end;

  end; // if rbFreezeUnfreeze.Enabled then
end; // procedure TN_CMVideoProfileSForm.FormKeyDown

//************************************* TN_CMVideoProfileSForm.FormKeyPress ***
// Just dump enetered key (mainly for debug)
//
//     Parameters
// Sender - Event Sender
// Key    - Key Character
//
// OnKeyPress Self handler
//
procedure TN_CMVideoProfileSForm.FormKeyPress( Sender: TObject; var Key: Char );
begin
  if rbFreezeUnfreeze.Enabled then
  begin
    N_Dump1Str( Format( 'from FormKeyPress Char=%d', [integer(Key)] ) );
  end; // if rbFreezeUnfreeze.Enabled then
end; // procedure TN_CMVideoProfileSForm.FormKeyPress

//**************************************** TN_CMVideoProfileSForm.bnOKClick ***
// Save current settings (Video Mode and KeyStrokes)
//
//     Parameters
// Sender - Event Sender
//
// OnClick bnOK handler
//
procedure TN_CMVideoProfileSForm.bnOKClick( Sender: TObject );
var
  TempStr: string;
begin
//  inherited;

  with PVProfile^ do
  begin
    CMDPStrPar1 := '1'; // Video mode 1

    if rgVCMode.ItemIndex = 1 then
      CMDPStrPar1 := '2' // Video mode 2
    else if rgVCMode.ItemIndex = 2 then
      CMDPStrPar1 := '3'; // Video mode 3

    if edFreezeUnfreeze.Text = 'None' then
      CMFreezeUnfreezeKey := 0
    else
      CMFreezeUnfreezeKey := TextToShortCut( edFreezeUnfreeze.Text );

    if edSaveAndUnfreeze.Text = 'None' then
      CMSaveAndUnfreezeKey := 0
    else
      CMSaveAndUnfreezeKey := TextToShortCut( edSaveAndUnfreeze.Text );

    N_Dump2Str(
      'TN_CMVideoProfileSForm.bnOKClick before CMDPStrPar2[4], CMDPStrPar2 = ' +
                                                                   CMDPStrPar2);
    if CmBStillPin.Checked then // still pin parameters
      CMDPStrPar2[4] := '1'
    else
      CMDPStrPar2[4] := '0';

    N_Dump2Str(
      'TN_CMVideoProfileSForm.bnOKClick before CMDPStrPar2[5], CMDPStrPar2 = ' +
                                                                   CMDPStrPar2);

    if cbClose.Checked then // close after disconnect parameters
      CMDPStrPar2[5] := '1'
    else
      CMDPStrPar2[5] := '0';

    N_Dump2Str(
      'TN_CMVideoProfileSForm.bnOKClick before CMDPStrPar2[7], CMDPStrPar2 = ' +
                                                                   CMDPStrPar2);

    // ***** save filter and renderer
    TempStr := IntToStr( cbFilter.ItemIndex div 10 );
    CMDPStrPar2[7] := TempStr[1];
    TempStr := IntToStr( cbFilter.ItemIndex mod 10 );
    CMDPStrPar2[8] := TempStr[1];

    N_Dump2Str(
      'TN_CMVideoProfileSForm.bnOKClick before CMDPStrPar2[6], CMDPStrPar2 = ' +
                                                                   CMDPStrPar2);

    TempStr := IntToStr( cbRenderer.ItemIndex );
    CMDPStrPar2[6] := TempStr[1];
  end; // with PVProfile^ do

end; // procedure TN_CMVideoProfileSForm.bnOKClick

//***************************************** TN_CMVideoProfileSForm.FormShow ***
// Init Form by Video Profile (Video Mode and KeyStrokes)
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMVideoProfileSForm.FormShow( Sender: TObject );
var
  i, AErrCode: integer;
  AvailableNames, NeededNames: TStringList;
begin
//  inherited;
  with PVProfile^ do
  begin
    rgVCMode.ItemIndex := 0; // Video mode 1

    if CMDPStrPar1 = '2' then // Video mode 2
      rgVCMode.ItemIndex := 1
    else if CMDPStrPar1 = '3' then // Video mode 3
      rgVCMode.ItemIndex := 2;

    if PVEnableKeystrokes then // Enable Keystrokes controls
    begin

      if (CMFreezeUnfreezeKey = 0) then
        edFreezeUnfreeze.Text := 'None'
      else
        edFreezeUnfreeze.Text := ShortCutToText( CMFreezeUnfreezeKey );

      if CMSaveAndUnfreezeKey = 0 then
        edSaveAndUnfreeze.Text := 'None'
      else
        edSaveAndUnfreeze.Text := ShortCutToText( CMSaveAndUnfreezeKey );

    end else // Disable Keystrokes controls
    begin
      edFreezeUnfreeze.Text  := 'None';
      edSaveAndUnfreeze.Text := 'None';
      rbFreezeUnfreeze.Checked  := False;
      rbSaveAndUnfreeze.Checked := False;
      rbFreezeUnfreeze.Enabled  := False;
      rbSaveAndUnfreeze.Enabled := False;
      bnReset.Enabled := False;
    end; // else // Disable Keystrokes controls

//  FPCBDUActivateMode := N_MemIniToInt( 'CMS_UserMain', 'SironaActivateMode', 0 );
//  FPCBDUCloseMode    := N_MemIniToInt( 'CMS_UserMain', 'SironaCloseMode',    0 );


  end; // with PVProfile^ do

  // ***** set and fill a filter combobox
  AvailableNames := TStringList.Create;
  NeededNames    := TStringList.Create;

  N_DSEnumFilters(CLSID_VideoCompressorCategory, '', AvailableNames, AErrCode);
  if AErrCode > 0 then
    Exit;

  N_MemIniToStrings( 'CMS_VideoCompr', NeededNames ); // retrive NeededNames

  for i := 0 to AvailableNames.Count - 1 do//NeededNames.Count - 1 do // along all NeededNames
  begin
   //if AvailableNames.IndexOf( NeededNames[i] ) >= 0 then
     cbFilter.Items.Add(AvailableNames[i]);//NeededNames[i]);
  end;
  for i := 0 to AvailableNames.Count - 1 do
    N_Dump2Str('All possible compession filters: ' + IntToStr(i) +
                                                      ': ' + AvailableNames[i]);


  N_Dump2Str(
    'TN_CMVideoProfileSForm.FormShow before CMDPStrPar2[7, 8], CMDPStrPar2 = ' +
                                                        PVProfile^.CMDPStrPar2);
  cbFilter.ItemIndex := StrToInt(PVProfile^.CMDPStrPar2[7])*10 +
                                            StrToInt(PVProfile^.CMDPStrPar2[8]);
  N_Dump2Str(
    'TN_CMVideoProfileSForm.FormShow before CMDPStrPar2[6], CMDPStrPar2 = ' +
                                                        PVProfile^.CMDPStrPar2);

  cbRenderer.ItemIndex := StrToInt(PVProfile^.CMDPStrPar2[6]);
  N_Dump2Str(
    'TN_CMVideoProfileSForm.FormShow after CMDPStrPar2[6], CMDPStrPar2 = ' +
                                                        PVProfile^.CMDPStrPar2);

  NeededNames.Free;
  AvailableNames.Free;

   // set if enable or not
  if (rgVCMode.ItemIndex = 0) or (rgVCMode.ItemIndex = 1) then
  begin
    CmBStillPin.Enabled := False;
    cbRenderer.Enabled  := False;
    cbFilter.Enabled    := False;
    lbRenderer.Enabled  := False;
    lbFilter.Enabled    := False;
  end
  else
  begin
    cbRenderer.Enabled := True;
    cbFilter.Enabled   := True;
    lbRenderer.Enabled := True;
    lbFilter.Enabled   := True;

    if PVProfile^.CMDPStrPar2[4] = '2' then
      CmBStillPin.Enabled := False
    else
      CmBStillPin.Enabled := True;
  end;

  if PVProfile^.CMDPStrPar2[4] = '1' then // still pin params
    CmBStillPin.Checked := True
  else
    CmBStillPin.Checked := False;

  if PVProfile^.CMDPStrPar2[5] = '1' then // close after disconnect params
    cbClose.Checked := True
  else
    cbClose.Checked := False;

end; // procedure TN_CMVideoProfileSForm.FormShow

//**************************** TN_CMVideoProfileSForm.rbFreezeUnfreezeClick ***
// Just Check Self and Uncheck rbSaveAndUnfreeze
//
//     Parameters
// Sender - Event Sender
//
// OnClick rbFreezeUnfreeze handler
//
procedure TN_CMVideoProfileSForm.rbFreezeUnfreezeClick( Sender: TObject );
begin
  if rbFreezeUnfreeze.Checked then Exit;

  rbFreezeUnfreeze.Checked  := True;
  rbSaveAndUnfreeze.Checked := False;
end; // procedure TN_CMVideoProfileSForm.rbFreezeUnfreezeClick

//*************************** TN_CMVideoProfileSForm.rbSaveAndUnfreezeClick ***
// Just Check Self and Uncheck rbFreezeUnfreeze
//
//     Parameters
// Sender - Event Sender
//
// OnClick rbSaveAndUnfreeze handler
//
procedure TN_CMVideoProfileSForm.rbSaveAndUnfreezeClick( Sender: TObject );
begin
  if rbSaveAndUnfreeze.Checked then Exit;

  rbFreezeUnfreeze.Checked  := False;
  rbSaveAndUnfreeze.Checked := True;
end;

procedure TN_CMVideoProfileSForm.rgVCModeClick(Sender: TObject);
begin
  inherited;
  // set if enabled or not
  if (rgVCMode.ItemIndex = 0) or (rgVCMode.ItemIndex = 1) then
  begin
    CmBStillPin.Enabled := False;
    cbRenderer.Enabled  := False;
    cbFilter.Enabled    := False;
    lbRenderer.Enabled  := False;
    lbFilter.Enabled    := False;
  end
  else
  begin
    cbRenderer.Enabled := True;
    cbFilter.Enabled   := False;//True;
    lbRenderer.Enabled := True;
    lbFilter.Enabled   := False;//True;
    if PVProfile^.CMDPStrPar2[4] = '2' then
      CmBStillPin.Enabled := False
    else
      CmBStillPin.Enabled := True;
  end;

  if (rgVCMode.ItemIndex = 0) then
  begin
    cbClose.Enabled       := False;
    lbCloseBottom.Enabled := False;
  end
  else
  begin
    cbClose.Enabled       := True;
    lbCloseBottom.Enabled := True;
  end;
end;

// procedure TN_CMVideoProfileSForm.rbSaveAndUnfreezeClick

procedure TN_CMVideoProfileSForm.bnResetClick( Sender: TObject );
begin
  if rbFreezeUnfreeze.Checked then
    edFreezeUnfreeze.Text := 'None';

  if rbSaveAndUnfreeze.Checked then
    edSaveAndUnfreeze.Text := 'None';

end; // procedure TN_CMVideoProfileSForm.bnResetClick

end.
