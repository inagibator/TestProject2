unit N_ColViewFr;
// Color View and Edit Frame

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type TN_ColorViewFrame = class( TFrame )
    Label1: TLabel;
    edHexColor:  TEdit;
    edDecColor:  TEdit;
    edBackColor: TEdit;

    procedure edHexColorKeyDown   ( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
    procedure edDecColorKeyDown   ( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
    procedure edHexColorDblClick  ( Sender: TObject );
    procedure edBackColorDblClick ( Sender: TObject );
  public
  procedure SetFields      ( AColor: integer );
  procedure SaveToMemIni   ( ASecName, AValName: string );
  procedure LoadFromMemIni ( ASecName, AValName: string );
end; // type TN_ColorViewFrame = class( TFrame )


implementation
uses
  N_Types, N_Lib0, N_Lib1, N_ME1, N_Color1F;
{$R *.dfm}

    //***************  TN_ColorViewFrame handlers  **********************

procedure TN_ColorViewFrame.edHexColorKeyDown( Sender: TObject;
                                          var Key: Word; Shift: TShiftState );
// Set all fields by edHexColor by Enter key
begin
  if Key = VK_RETURN then
    SetFields( N_StrToColor( edHexColor.Text ) );
end; // procedure TN_ColorViewFrame.edHexColorKeyDown

procedure TN_ColorViewFrame.edDecColorKeyDown( Sender: TObject;
                                           var Key: Word; Shift: TShiftState );
// Set all fields by edDecColor by Enter key
begin
  if Key = VK_RETURN then
    SetFields( N_StrToColor( edDecColor.Text ) );
end; // procedure TN_ColorViewFrame.edDecColorKeyDown

procedure TN_ColorViewFrame.edHexColorDblClick( Sender: TObject );
// Set all fields by N_MEGlobObj.CurColor
begin
  SetFields( N_MEGlobObj.CurColor );
end; // procedure TN_ColorViewFrame.edHexColorDblClick

procedure TN_ColorViewFrame.edBackColorDblClick( Sender: TObject );
// Edit Color in Modal Mode
begin
  SetFields( N_ModalEditColor( edBackColor.Color ) );
end; // procedure TN_ColorViewFrame.edBackColorDblClick


    //***************  TN_ColorViewFrame Public nethods  ********************

procedure TN_ColorViewFrame.SetFields( AColor: integer );
// Set all fields by given AColor
begin
  if (AColor = N_CurColor) then
  begin
    edBackColor.Color := $FFFFFF;
    edBackColor.Text := ' Current';
    edHexColor.Text  := ' -2';
    edDecColor.Text  := '';
  end else if (AColor = N_EmptyColor) or ((AColor and $FF000000) <> 0) then
  begin
    edBackColor.Color := $FFFFFF;
    edBackColor.Text := ' Empty';
    edHexColor.Text  := ' -1';
    edDecColor.Text  := '';
  end else // AColor is normal Color
  begin
    edBackColor.Color := AColor;
    edBackColor.Text := '';
    edHexColor.Text  := ' ' + N_ColorToHTMLHex( AColor );
    edDecColor.Text  := ' ' + N_ColorToRGBDecimals( AColor );
  end;
end; // end of procedure TN_ColorViewFrame.SetFields

procedure TN_ColorViewFrame.SaveToMemIni( ASecName, AValName: string );
// Save current color to MemIni
begin
  N_IntToMemIni( ASecName, AValName, edBackColor.Color );
end; // end of procedure TN_ColorViewFrame.SaveToMemIni

procedure TN_ColorViewFrame.LoadFromMemIni( ASecName, AValName: string );
// Set all fields by color from MemIni
begin
  SetFields( N_MemIniToInt( ASecName, AValName ) );
end; // end of procedure TN_ColorViewFrame.LoadFromMemIni

end.
