unit K_FFontAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_BaseF, N_Lib0, N_Types, Buttons;

type
  TK_FormFontAttrs = class(TN_BaseForm)
    LbFonts: TLabel;
    CmBFontFace: TComboBox;
    BtCancel: TButton;
    BtOK: TButton;
    UDFontSize: TUpDown;
    EdFontSize: TLabeledEdit;
    LbFontStyle: TLabel;
    PnColor: TPanel;
    GBSample: TGroupBox;
    SBtBold: TSpeedButton;
    SBtItalic: TSpeedButton;
    SbtULine: TSpeedButton;
    SBtSLine: TSpeedButton;
    LbTextColor: TLabel;
    MemoSample: TMemo;
    procedure SBtBoldClick(Sender: TObject);
    procedure UDFontSizeEnter(Sender: TObject);
    procedure EdFontSizeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UDFontSizeClick(Sender: TObject; Button: TUDBtnType);
    procedure CmBFontFaceChange(Sender: TObject);
    procedure PnColorClick(Sender: TObject);
  private
    { Private declarations }
    procedure FAUpdateFontSize;
    procedure FAUpdateUDIncr;
  public
    { Public declarations }
    FAShowAfterApplyProc : TN_ProcObj;

    FAPColor : PColor;
    FAFontColor : TColor;

    FAPNFont : TN_PNFont;
    FAFontFlags : array [1..4] of Boolean;
    FAFontSize : Integer;
    FAFontSizePrev : Integer;
    FAFontFace : string;
    FAFontBold : Boolean;
    FAFontItalic : Boolean;
    FAFontUnderline : Boolean;
    FAFontStrikeOut : Boolean;
    procedure FAShowSample();
    procedure FAAplyData();
    procedure FAShowAll();
  end;
type TK_FontAttrsDlgFlags = set of (K_fadHideSample);
var
  K_FormFontAttrs: TK_FormFontAttrs;

function K_FontAttrsDlg( AFlags : TK_FontAttrsDlgFlags; APNFont: TN_PNFont;
                         APColor : PColor = nil; APText : PChar = nil;
                         AShowAfterApplyProc : TN_ProcObj = nil;
                         ACaption : string = '' ): Boolean;

implementation

{$R *.dfm}

uses K_CLib0;

//****************************************************** K_FontAttrsDlg ***
// Select Text Font and Color Attributes
//
// AFlags - show Dialog Flags
// APNFont - pointer to TN_NFont structure
// APColor - pointer to color
// APText  - pointer to sample text first char
// AShowAfterApplyProc - show after attributes apply
// ACaption - Dialog Window Caption
// Result - Returns TRUE if new attributes were selected
//
function K_FontAttrsDlg( AFlags : TK_FontAttrsDlgFlags; APNFont: TN_PNFont;
                         APColor : PColor = nil; APText : PChar = nil;
                         AShowAfterApplyProc : TN_ProcObj = nil;
                         ACaption : string = '' ): Boolean;
var
  SL : TStringList;
  CurAttrChanged : Boolean;

begin
  Result := False;
  if APNFont = nil then Exit; // a precaution
  with TK_FormFontAttrs.Create(Application), APNFont^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//  BaseFormInit(nil);

    if ACaption <> '' then
      Caption := ACaption
    else if Caption[1] = '_' then
      Caption := Copy( Caption, 2, Length(Caption) );

    FAPNFont := APNFont;
    FAShowAfterApplyProc := AShowAfterApplyProc;
    FAFontSize := Round(NFLLWHeight); // Windows FontDialog shows Size(points), not Height(pixels)
    FAFontSizePrev := FAFontSize;
    UDFontSize.Position := FAFontSize;
    FAUpdateUDIncr();
    
    FAFontFace := NFFaceName;
    SL := TStringList.Create;
    K_GetSysFontFaceNamesList( SL );
    SL.Sort();
    CmBFontFace.Items.Assign( SL );
    SL.Free;
    CmBFontFace.ItemIndex := CmBFontFace.Items.IndexOf( FAFontFace );
    if CmBFontFace.ItemIndex = -1 then
      CmBFontFace.ItemIndex := 0;

    FAFontBold := (NFWeight = 0) and (NFBold <> 0);
    SBtBold.Down := FAFontBold;
    FAFontFlags[SBtBold.Tag]:= FAFontBold;

    FAFontItalic := NFWin.lfItalic <> 0;
    SBtItalic.Down := FAFontItalic;
    FAFontFlags[SBtItalic.Tag]:= FAFontItalic;

    FAFontUnderline := NFWin.lfUnderline <> 0;
    SBtULine.Down := FAFontUnderline;
    FAFontFlags[SBtULine.Tag]:= FAFontUnderline;

    FAFontStrikeOut := NFWin.lfStrikeOut <> 0;
    SBtSLine.Down := FAFontStrikeOut;
    FAFontFlags[SBtSLine.Tag]:= FAFontStrikeOut;

    PnColor.ParentBackground := FALSE; // is need for controls wich Color property will be changed by program
    FAPColor := APColor;
    if FAPColor <> nil then
    begin
      FAFontColor := FAPColor^;
      PnColor.Color := FAFontColor;
    end
    else
    begin
      PnColor.Visible := FALSE;
      LbTextColor.Visible := FALSE;
    end;

    if APText <> nil then
      MemoSample.Lines.Text := APText
    else
      MemoSample.Lines.Text := 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';

    FAShowSample();
    if K_fadHideSample in AFlags then
    begin
      GBSample.Visible := FALSE;
//      Constraints.MaxHeight := 195;
//      Constraints.MinHeight := 195;
    end
    else
    begin
      BorderStyle := bsSizeable;
      if MemoSample.Height < 64 then
        Height := Height + 64 - MemoSample.Height;
    end;

    Result := ShowModal() = mrOK;

    if not Result then
    begin
      if not Assigned(FAShowAfterApplyProc) then Exit;
      // Return previous Data
      UDFontSize.Position := FAFontSize;

      SBtBold.Down := FAFontBold;

      SBtItalic.Down := FAFontItalic;

      SBtULine.Down := FAFontUnderline;

      SBtSLine.Down := FAFontStrikeOut;

      if FAPColor <> nil then
        PnColor.Color := FAFontColor;
      FAAplyData();
      FAShowAfterApplyProc();
    end; // if not Result then

    // Check if attributes were realy changed and then change Font and Color
    Result := FALSE;

    CurAttrChanged := UDFontSize.Position <> FAFontSize;
    Result := Result or CurAttrChanged;

    CurAttrChanged := FAFontBold <> SBtBold.Down;
    Result := Result or CurAttrChanged;

    CurAttrChanged := FAFontItalic <> SBtItalic.Down;
    Result := Result or CurAttrChanged;

    CurAttrChanged := FAFontUnderline <> SBtULine.Down;
    Result := Result or CurAttrChanged;

    CurAttrChanged := FAFontStrikeOut <> SBtSLine.Down;
    Result := Result or CurAttrChanged;

    if FAPColor <> nil then
    begin
      CurAttrChanged := PnColor.Color <> FAFontColor;
      Result := Result or CurAttrChanged;
    end;

    if Result then FAAplyData();

  end; // with TK_FormFontAttrs.Create(Application), APNFont^ do
end; // function K_CMSFontAttrsDlg

//******************************************** TK_FormFontAttrs.SBtBoldClick ***
// Font Style Buttons Click Handler
//
procedure TK_FormFontAttrs.SBtBoldClick(Sender: TObject);
begin
  if FAFontFlags[TControl(Sender).Tag] then begin
    TSpeedButton(Sender).AllowAllUp := TRUE;
    TSpeedButton(Sender).Down := FALSE;
    FAFontFlags[TControl(Sender).Tag] := FALSE;
  end else
    FAFontFlags[TControl(Sender).Tag] := TRUE;
  FAShowAll();
end; // procedure TK_FormFontAttrs.SBtBoldClick

//******************************************** TK_FormFontAttrs.UDFontSizeEnter ***
// Font Size UpDown Control Enter Handler
//
procedure TK_FormFontAttrs.UDFontSizeEnter(Sender: TObject);
begin
  FAUpdateFontSize();
end; // TK_FormFontAttrs.UDFontSizeEnter

//******************************************** TK_FormFontAttrs.EdFontSizeKeyDown ***
// Font Size Field Key Down Handler
//
procedure TK_FormFontAttrs.EdFontSizeKeyDown( Sender: TObject;
  var Key: Word; Shift: TShiftState );
begin
  if Key = VK_Return then
  begin
    FAUpdateFontSize();
    EdFontSize.Text := IntToStr( UDFontSize.Position );
    FAShowAll();
  end;
end; // procedure TK_FormFontAttrs.EdFontSizeKeyDown

//******************************************** TK_FormFontAttrs.UDFontSizeClick ***
// Font Size UpDown Control Click Handler
//
procedure TK_FormFontAttrs.UDFontSizeClick(Sender: TObject;
  Button: TUDBtnType);
begin
  FAUpdateUDIncr();
  FAShowAll();
end; // procedure TK_FormFontAttrs.UDFontSizeClick

//******************************************** TK_FormFontAttrs.CmBFontFaceChange ***
// Font Face ComboBox Change Handler
//
procedure TK_FormFontAttrs.CmBFontFaceChange(Sender: TObject);
begin
  FAShowAll();
end; // procedure TK_FormFontAttrs.CmBFontFaceChange

//******************************************** TK_FormFontAttrs.PnColorClick ***
// Text Color Control Click Handler
//
procedure TK_FormFontAttrs.PnColorClick(Sender: TObject);
var
  AColor : TColor;
begin
  AColor := PnColor.Color;
  if not K_SelectColorDlg( AColor ) then Exit;
  PnColor.Color := AColor;
  FAShowAll();
end; // procedure TK_FormFontAttrs.PnColorClick

//*************************************** TK_FormFontAttrs.FAUpdateFontSize ***
// Update Font Size UpDown Control Position by Size TEdit Control
//
procedure TK_FormFontAttrs.FAUpdateFontSize;
begin
  UDFontSize.Position := StrToIntDef( EdFontSize.Text, UDFontSize.Position );
  FAUpdateUDIncr();
  FAFontSizePrev :=  UDFontSize.Position;
end; // procedure TK_FormFontAttrs.FAUpdateFontSize

//***************************************** TK_FormFontAttrs.FAUpdateUDIncr ***
// Update Font Size UpDown Control Increment by Position
//
procedure TK_FormFontAttrs.FAUpdateUDIncr;
begin
  if UDFontSize.Position <= 25 then
    UDFontSize.Increment := 1
  else
  if UDFontSize.Position <= 50 then
  begin
    if (UDFontSize.Increment < 5) and (FAFontSizePrev <> UDFontSize.Position)  then
      UDFontSize.Position := UDFontSize.Position - UDFontSize.Increment + 5;
    UDFontSize.Increment := 5
  end
  else
  if UDFontSize.Position <= 100 then
  begin
    if (UDFontSize.Increment < 10) and (FAFontSizePrev <> UDFontSize.Position)  then
      UDFontSize.Position := UDFontSize.Position - UDFontSize.Increment + 10;
    UDFontSize.Increment := 10
  end
  else
  if UDFontSize.Position <= 500 then
  begin
    if (UDFontSize.Increment < 50) and (FAFontSizePrev <> UDFontSize.Position)  then
      UDFontSize.Position := UDFontSize.Position - UDFontSize.Increment + 50;
    UDFontSize.Increment := 50
  end
  else
  begin
    if (UDFontSize.Increment < 100) and (FAFontSizePrev <> UDFontSize.Position)  then
      UDFontSize.Position := UDFontSize.Position - UDFontSize.Increment + 100;
    UDFontSize.Increment := 100;
  end;

end; // procedure TK_FormFontAttrs.FAUpdateUDIncr

//******************************************** TK_FormFontAttrs.FAShowSample ***
// Show Sample Text using new attributes
//
procedure TK_FormFontAttrs.FAShowSample;
begin
  with MemoSample.Font do begin
    Color := PnColor.Color;
    MemoSample.Color := K_GetContrastColor( Color );
    Size :=  UDFontSize.Position;
    Name := CmBFontFace.Text;
    Style := [];
    if FAFontFlags[1] then Style := Style + [fsBold];
    if FAFontFlags[2] then Style := Style + [fsItalic];
    if FAFontFlags[3] then Style := Style + [fsUnderline];
    if FAFontFlags[4] then Style := Style + [fsStrikeOut];
  end;
end; // procedure TK_FormFontAttrs.FAShowSample

//******************************************** TK_FormFontAttrs.FAAplyData ***
// Apply new Attributes to Source Data
//
procedure TK_FormFontAttrs.FAAplyData;
begin
  with FAPNFont^ do begin
    NFLLWHeight := UDFontSize.Position;

    NFFaceName := CmBFontFace.Text;

    if SBtBold.Down then
      NFBold := 1
    else
      NFBold := 0;

    if SBtItalic.Down then
      NFWin.lfItalic := 1
    else
      NFWin.lfItalic := 0;

    if SBtULine.Down then
      NFWin.lfUnderline := 1
    else
      NFWin.lfUnderline := 0;

    if SBtSLine.Down then
      NFWin.lfStrikeOut := 1
    else
      NFWin.lfStrikeOut := 0;

    if FAPColor <> nil then begin
      FAPColor^ := PnColor.Color;
    end;
    DeleteObject( NFHandle );
  end;

end; // procedure TK_FormFontAttrs.FAAplyData;

//******************************************** TK_FormFontAttrs.FAShowAll ***
// Show Sample Text and Real Text using new attributes
//
procedure TK_FormFontAttrs.FAShowAll;
begin
  FAShowSample();
  if not Assigned(FAShowAfterApplyProc) then Exit;
  FAAplyData();
  FAShowAfterApplyProc();
end; // procedure TK_FormFontAttrs.FAShowAll

end.
