unit N_Tst1F;
// Test Form for testing Frames and Controls

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ComCtrls, StdCtrls, ExtCtrls,
  ToolWin, ActnList, StdActns, ExtActns, CheckLst,
  N_Rast1Fr, Menus, N_TranspFr;

type TN_TestForm = class( TForm )
    StatusBar: TStatusBar;
    MainMenu1: TMainMenu;
    Dummy11: TMenuItem;
    Dummy21: TMenuItem;
    Dummy111: TMenuItem;
    Dummy121: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Print1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    TranspFrame: TN_TranspFrame;
    ToolButton2: TToolButton;
    procedure bnTest2Click  ( Sender: TObject );
    procedure bnItalicClick ( Sender: TObject );
    procedure FormResize(Sender: TObject);
  public
    procedure ShowInt( AInt: integer );
    procedure ShowString( AStr: string );
end; // type TN_TestForm = class( TForm )

function N_CreateTestForm(): TN_TestForm;

implementation
//uses
//  N_CMResF;
{$R *.DFM}

    //*********** TN_TestForm Handlers  *****************************

procedure TN_TestForm.bnTest2Click( Sender: TObject );
// Test2 Click:
begin
  TranspFrame.Visible := not TranspFrame.Visible;
end; // procedure TN_TestForm.bnTest2Click

procedure TN_TestForm.bnItalicClick(Sender: TObject);
// Italic Click
begin
end;

    //*********** TN_TestForm Public methods  *****************************

procedure TN_TestForm.ShowInt( AInt: integer );
// Show given AInt in StatusBar
begin
  StatusBar.SimpleText := IntToStr( AInt );
end; // procedure TN_TestForm.ShowInt

procedure TN_TestForm.ShowString( AStr: string );
// Show given AStr in StatusBar
begin
  StatusBar.SimpleText := AStr;
end; // procedure TN_TestForm.ShowInt

    //*********** Global Procedures  *****************************

//*******************************************  N_CreateTestForm  ******
// Create new instance of N_TestForm
//
function N_CreateTestForm(): TN_TestForm;
begin
  Result := TN_TestForm.Create( Application );
  with Result do
  begin
  end;
end; // end of function N_CreateTestForm


procedure TN_TestForm.FormResize(Sender: TObject);
//var
//  i: integer;
begin
//  TranspFrame.Visible := True;
//  Repaint;
//  Application.ProcessMessages;


//  Panel3.Visible := False;
//  Panel4.Visible := False;
{
  sl, st: integer;

  sl := Panel4.Left;
  st := Panel4.Top;

  Panel4.Left := Panel4.Left + 30;

  for i := 0 to 98 do
  begin
    Panel4.Left := Panel4.Left + 10;
    Panel4.Left := Panel4.Left - 10;
  end;

  Panel4.Top := Panel4.Top + 10;

  Panel4.Left := sl;
  Panel4.Top  := st;

  for i := 0 to 2 do
  begin
    Panel5.Left := Panel5.Left + 10;
    Panel5.Left := Panel5.Left - 10;
  end;
}

//  Panel4.Visible := True;
//  Panel3.Visible := True;
//  TranspFrame.Visible := False;
end;

end.
