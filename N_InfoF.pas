unit N_InfoF;
// form with TMemo just for showing notes

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ToolWin;

type TN_InfoForm = class( TForm ) // Form with TMemo just for showing notes
    Memo: TMemo;
    ToolBar1: TToolBar;
    tbClearLines: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    tbWrap: TToolButton;
    procedure tbClearLinesClick ( Sender: TObject );
    procedure ToolButton2Click ( Sender: TObject );
    procedure ToolButton4Click ( Sender: TObject );
    procedure ToolButton5Click ( Sender: TObject );
    procedure FormDestroy ( Sender: TObject );
    procedure tbWrapClick(Sender: TObject);
      public
    BufLines: TStringList; // BufLines is needed, because adding strings to memo,
                           // even N_InfoForm is not visible, changes
                           // curent Canvas.Handle
    RestoreFocus: Boolean;
    AlwaysShow: Boolean;
    procedure AddStr( Str: String );
end; // type TN_InfoForm = class( TForm )

procedure N_IAdd ( Str: string ); overload;
procedure N_IAdd ( AStrings: TStrings ); overload;
function  N_GetInfoForm (): TN_InfoForm;

var
  N_InfoForm: TN_InfoForm;

implementation
{$R *.DFM}
uses
  K_CLib0,
  N_ButtonsF, N_Lib0, N_Deb1, N_Types; // , N_ME1;

const FileName = 'a_info.txt';

procedure TN_InfoForm.tbClearLinesClick(Sender: TObject);
// Clear Memo
begin
  Memo.Lines.Clear;
end;

procedure TN_InfoForm.ToolButton2Click(Sender: TObject);
// Clear file FileName (a_info.txt)
begin
  if FileExists( FileName ) then DeleteFile( FileName );
end;

procedure TN_InfoForm.ToolButton4Click(Sender: TObject);
// Append Memo.Lines to file FileName (a_info.txt)
var
  FF: TextFile;
begin
  AssignFile( FF, FileName );
  if FileExists( FileName ) then Append( FF )
                            else Rewrite( FF );
  WriteLn( FF, 'InfoForm.Memo from  ' + K_DateTimeToStr( Now() ) );
  WriteLn( FF, Memo.Lines.Text );
  System.Close( FF ); // System is needed to destinguish from Form.Close
end;

procedure TN_InfoForm.ToolButton5Click(Sender: TObject);
// Read from file FileName (a_info.txt)
begin
  if FileExists( FileName ) then Memo.Lines.LoadFromFile( FileName )
                            else Beep;
  Memo.Lines.Add( '' );
  Memo.Lines.Delete( Memo.Lines.Count-1 );
end;

procedure TN_InfoForm.FormDestroy( Sender: TObject );
// Free BufLines
begin
  BufLines.Free;
end; // procedure TN_InfoForm.FormDestroy

procedure TN_InfoForm.AddStr( Str: String );
// add given string to Memo.Lines and show Self if not yet
begin
  Memo.Lines.Add( Str );
  if not Visible then Show;
end;

//********************  Global Procedures  ******

//***********************************************************  N_IAdd(Str)  ***
// add string to Memo.Lines and show form if not yet
// (mainly to reduce code size)
//
procedure N_IAdd( Str: string );
var
  PrevHWND, NewHWND: integer;
begin
//  if not (medfCollectProtocol in N_MEGlobObj.MEDebFlags) then Exit;
//!!  N_AddDebString( 0, Str ); // Add String to Protocol File

  N_GetInfoForm();
  with N_InfoForm do
  begin
    if (Length(Str) = 2) and (Str[1] = Char(0)) then // control command
    begin
      if Str[2] = 'F' then RestoreFocus := not RestoreFocus;
      if Str[2] = 'S' then
      begin
        AlwaysShow := not AlwaysShow;
        Visible := not Visible;
        if Visible and (BufLines.Count > 0) then
        begin
          Memo.Lines.AddStrings( BufLines ); // show accumulated strings
          BufLines.Clear;
        end;
      end;
      Exit;
    end; // if (Length(Str) = 2) and (Str[1] = Char(0)) then // control command

    PrevHWND := Windows.GetFocus(); // always save

    if AlwaysShow then
      Memo.Lines.Add( Str ) // Canvas.Handle will be changed in caller proc!!
    else
      BufLines.Add( Str ); // Canvas.Handle will be preserved

    if (not Visible) and AlwaysShow then Show;

    if RestoreFocus then  // restore focus if needed
    begin
      NewHWND := Windows.GetFocus();
      if NewHWND <> PrevHWND then
        Windows.SetFocus( PrevHWND );
    end;
  end; // with N_InfoForm do
end; // end of procedure N_IAdd(Str)

//*******************************************************  N_IAdd(Strings)  ***
// add string to Memo.Lines and show form if not yet
// (mainly to reduce code size)
//
procedure N_IAdd( AStrings: TStrings );
var
  i, PrevHWND, NewHWND: integer;
begin
//  if not (medfCollectProtocol in N_MEGlobObj.MEDebFlags) then Exit;

  for i := 0 to AStrings.Count-1 do
    N_AddDebString( 0, AStrings[i] ); // Add String to Protocol File

  N_GetInfoForm();
  with N_InfoForm do
  begin
    PrevHWND := Windows.GetFocus(); // always save

    if AlwaysShow then
      Memo.Lines.AddStrings( AStrings ) // Canvas.Handle will be changed in caller proc!!
    else
      BufLines.AddStrings( AStrings ); // Canvas.Handle will be preserved

    if (not Visible) and AlwaysShow then Show;

    if RestoreFocus then  // restore focus if needed
    begin
      NewHWND := Windows.GetFocus();
      if NewHWND <> PrevHWND then
        Windows.SetFocus( PrevHWND );
    end;
  end; // with N_InfoForm do
end; // end of procedure N_IAdd(Strings)

//*****************************************************  N_GetInfoForm  ******
// just create N_InfoForm if not yet
//
function N_GetInfoForm(): TN_InfoForm;
begin
  if N_InfoForm = nil then
  begin
    N_InfoForm := TN_InfoForm.Create(Application);
    with N_InfoForm do
    begin
      BufLines := TStringList.Create();
      Memo.WordWrap := True;
      RestoreFocus := False;
      AlwaysShow := True;
    end;
  end;
  Result := N_InfoForm;
end; // end of function N_GetInfoForm

procedure TN_InfoForm.tbWrapClick( Sender: TObject );
// Toggle Wrap Mode
begin
  N_i1 := Memo.Width;
  N_i2 := Width;

  with Memo do
    if WordWrap then
    begin
      WordWrap := False;
      ScrollBars := ssBoth;
      Update;
    end else
    begin
      WordWrap := True;
      ScrollBars := ssVertical;
      Update;
    end;
end; // procedure TN_InfoForm.tbWrapClick

Initialization
  N_AddStrToFile( 'N_InfoF Initialization' );

end.
