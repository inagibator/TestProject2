unit N_CMTstDelphiF;
// Test Delphi (not Base) Form for testing "Large Fonts" effects

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF; // N_CMTst2F,

type TN_CMTestDelphiForm = class( TN_BaseForm )
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    Shape1: TShape;
    Shape2: TShape;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;

    procedure FormShow      ( Sender: TObject );
    procedure FormClose     ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormResize    ( Sender: TObject ); override;
    procedure BFFormCanResize ( Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean); override;
    procedure Button1Click  ( Sender: TObject );
  public
    Bn1ClickCounter: integer;
    procedure DumpCoords ( AHeader: string );
end; // type TN_CMTestDelphiForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_ShowCMTestDelphiForm (): TN_CMTestDelphiForm;

var
  N_CMTestDelphiForm: TN_CMTestDelphiForm;

implementation
  uses
       N_Lib1;
{$R *.dfm}

//****************  TN_TestDelphiForm class handlers  ******************

procedure TN_CMTestDelphiForm.FormShow( Sender: TObject );
begin
  Exit;

  N_Dump1Str( 'After EnableAlign in FormShow' );
//  EnableAlign();
  DumpCoords( 'From FormShow' );

  Width  := Width  + 200;
  Height := Height + 200;
  DumpCoords( 'After increase +200  in FormShow:' );
end; // procedure TN_CMTestDelphiForm.FormShow

procedure TN_CMTestDelphiForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited;
end; // procedure TN_CMTestDelphiForm.FormClose

procedure TN_CMTestDelphiForm.FormResize( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMTestDelphiForm.FormResize

procedure TN_CMTestDelphiForm.BFFormCanResize( Sender: TObject; var NewWidth,
                                             NewHeight: Integer; var Resize: Boolean );
begin
  inherited;
//
end; // procedure TN_CMTestDelphiForm.FormCanResize

procedure TN_CMTestDelphiForm.Button1Click( Sender: TObject );
  procedure FixCoords();
  begin
    N_i := Button2.Left; Button2.Left := N_i+1; Button2.Left := N_i;
    N_i := Button2.Top;  Button2.Top  := N_i+1; Button2.Top  := N_i;
  end; // procedure FixCoords();
begin
  if Bn1ClickCounter = 0 then
  begin
    N_Dump1Str( ' B1Click 0) ' + BFAP() );
    Width  := 220;
    DumpCoords( 'After Width  := 220' );
    Height := 220;
    DumpCoords( 'After Height  := 220' );
    N_Dump1Str( '' );

    Inc(Bn1ClickCounter);
    Exit;
  end;

  if Bn1ClickCounter = 1 then
  begin
    N_Dump1Str( ' B1Click 1) ' + BFAP() );
    Width  := 300;
//    Height := 300;
    DumpCoords( 'After Width  := 300' );
    Realign();
    DumpCoords( 'After Realign, Fix Bn2 TopLeft' );

    FixCoords();
    N_Dump1Str( ' B1Click 1a) ' + BFAP() );
    EnableAlign();
    DumpCoords( 'After EnableAlign' );
    N_Dump1Str( '' );

    Inc(Bn1ClickCounter);
    Exit;
  end;

  if Bn1ClickCounter = 2 then
  begin
    N_Dump1Str( ' B1Click 2) ' + BFAP() );
    Width  := 310;
//    Height := 310;
    DumpCoords( 'After Width  := 310' );
    N_Dump1Str( '' );

    Inc(Bn1ClickCounter);
    Exit;
  end;

  if Bn1ClickCounter = 3 then
  begin
    N_Dump1Str( ' B1Click 3) ' + BFAP() );
    DisableAlign();
    Width  := 330;
//    Height := 330;
    DumpCoords( 'After Width  := 330' );
    N_Dump1Str( '' );

    FixCoords();
    EnableAlign();
    DumpCoords( 'After FixCoords and EnableAlign' );

    Inc(Bn1ClickCounter);
    Exit;
  end;

  if Bn1ClickCounter = 4 then
  begin
    N_Dump1Str( ' B1Click 4) ' + BFAP() );

    DisableAlign();
    DumpCoords( 'After DisableAlign' );

    Height := 300;
    DumpCoords( 'After Height  := 300, Fix Bn2 TopLeft' );

    N_i := Button2.Left; Button2.Left := N_i+1; Button2.Left := N_i;
    N_i := Button2.Top;  Button2.Top  := N_i+1; Button2.Top  := N_i;

    EnableAlign();
    DumpCoords( 'After EnableAlign' );
    N_Dump1Str( '' );

    Inc(Bn1ClickCounter);
    Exit;
  end;

  Exit;

  Width  := Width  + 20;
  Height := Height + 20;

  Exit;
  Width  := Width  + 20;
  Height := Height + 20;
  Width  := Width  - 20;
  Height := Height - 20;

//  Realign();
//  EnableAlign();
end; // procedure TN_CMTestDelphiForm.Button1Click


//****************************************** TN_CMTestDelphiForm.DumpCoords ***
// Dump all needed Coords
//
procedure TN_CMTestDelphiForm.DumpCoords( AHeader: string );
begin
  N_Dump1Str( AHeader );
  N_Dump1Str( Format( '  %s Delta=(%d,%d)',
                      [BFAP(), Width-ClientWidth, Height-ClientHeight] ));

  with Button2 do
    N_Dump1Str( Format( '  Button2   (x,y,w,h): %d %d %d %d (LR=%d,%d)', [Left,Top,Width,Height,Left+Width,Top+Height] ));

  with BFMinBRPanel do
    N_Dump1Str( Format( '  BFMinBRP %d %d %d %d (LR=%d,%d) (MinSize=%d,%d)', [Left,Top,Width,Height,
                            Left+Width, Top+Height,
                            BFFormMinSize.X, BFFormMinSize.Y] ));
  N_Dump1Str( '' );
  Exit;

//  with Panel1 do
//    N_Dump1Str( Format( 'Panel1    (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));
  with HorzScrollBar do
    N_Dump1Str( Format( 'HorzSB Range=%d Size=%d Vis=%d', [Range,Size,integer(IsScrollBarVisible())] ));
  with VertScrollBar do
    N_Dump1Str( Format( 'HorzSB Range=%d Size=%d Vis=%d', [Range,Size,integer(IsScrollBarVisible())] ));
  with Label1 do
    N_Dump1Str( Format( 'Label1    (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));


  N_Dump1Str( Format( 'Form AutoScroll=%d, AutoSize=%d', [integer(AutoScroll),integer(AutoSize)] ));
  with Constraints do
    N_Dump1Str( Format( 'Form Constraints: min= %d %d, max= %d %d', [MinWidth,MinHeight,MaxWidth,MaxHeight] ));
  N_Dump1Str( Format( 'Form Scaled=%d, Position type=%d', [integer(Scaled),integer(Position)] ));
  N_Dump1Str( Format( 'Form PixelsPerInch=%d, H,V SBars=%d %d', [PixelsPerInch,integer(HorzScrollBar.Visible),integer(VertScrollBar.Visible)] ));
  with Label1 do
    N_Dump1Str( Format( 'Label1    (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));
  with GroupBox1 do
    N_Dump1Str( Format( 'GroupBox1 (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));
  with Button1 do
    N_Dump1Str( Format( 'Button1   (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));
  with Button2 do
    N_Dump1Str( Format( 'Button2   (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));
//  with Panel1 do
//    N_Dump1Str( Format( 'Panel1    (x,y,w,h): %d %d %d %d', [Left,Top,Width,Height] ));

  N_Dump1Str( '' );
end; // procedure TN_CMTestDelphiForm.DumpCoords



//****************  TN_TestDelphiForm class public methods  ************


    //*********** Global Procedures  *****************************

//************************************************** N_ShowCMTestDelphiForm ***
// Create and Show Form, log all needed fields
//
//     Parameters
// AOwner - Owner of created Form
// Result - Return created Form
//
function N_ShowCMTestDelphiForm(): TN_CMTestDelphiForm;
var
  Delta, MinDelta, SavedRange, SBSize: integer;
  NeededRectStr: string;
Label Skip1;
begin
  N_Dump1Str( '' );
  N_Dump1Str( '*** Tmp Base Form Test 3 ***' );
  N_Dump1Str( '' );

  Result := TN_CMTestDelphiForm.Create( Application );
  with Result do
  begin
//    Button2.Anchors := [akRight, akBottom]; // temporary, later remove!
    DumpCoords( 'After TN_CMTestDelphiForm.Create:' );

// Now MinSize = 290 250

// MinSize.X < NeededSize.X < MaxSize.X;  MinSize.Y < NeededSize.Y < MaxSize.Y
// (Small increased form on Big Monitor, normal case)
// (initial Size should be SavedSize)
// (Resize is possible in MinSize - MaxSize interval in Align mode)
//    BFFormMaxRect := Rect( 0, 0, 1000, 800 );
//    NeededRectStr := '200 100 500 400';

// NeededSize.X < MinSize.X < MaxSize.X;  NeededSize.Y < MinSize.Y < MaxSize.Y
// (Small form on Big Monitor, saved Size < Min Size, normal case)
// (initial Size should be MinSize)
// (Resize is possible in MinSize - MaxSize interval in Align mode)
//    BFFormMaxRect := Rect( 0, 0, 1000, 800 );
//    NeededRectStr := '200 100 200 150';

// NeededSize.X < MaxSize.X < MinSize.X;  NeededSize.Y < MaxSize.Y < MinSize.Y - Case 1)
// (Big Form on Small Monitor)
// (initial Form Size should be SavedSize, initial Canvas Size should be MinSize)
// (Resize is possible in 0 - MaxSize interval in Disable Align mode)
//    BFFormMaxRect := Rect( 0, 0, 240, 220 );
//    NeededRectStr := '200 100 200 150';

// MinSize.X > MaxSize.X;  MinSize.Y <= FormMaxSize.Y - Case 2)
// (Landscape Form on Portrait Monitor)
// initial Form Size should be , clipped by MaxSize,
// initial Canvas Size should be (MinSize.X, SavedSize.Y))
// Resize is possible in 0 - MaxSize interval in Disable Align mode
//    BFFormMaxRect := Rect( 0, 0, 240, 800 );
//    NeededRectStr := '200 100 800 500';

// NeededSize.X < MinSize.X < MaxSize.X;  NeededSize.Y < MinSize.Y < MaxSize.Y - Case 3)
// (Portrait Form on Landscape Monitor)
// initial Form Size should be SavedSize, clipped by MaxSize,
// initial Canvas Size should be (SavedSize.X, MinSize.Y))
// (Resize is possible in 0 - MaxSize interval in Disable Align mode)
    BFFormMaxRect := Rect( 0, 0, 1000, 200 );
    NeededRectStr := '200 100 800 500';


    BFSectionName := 'N_Forms';
    BFSelfName := 'AA_CMTestDelphiForm';
    BFFlags := [bffToDump1]; // enable Dump coords to main log
    N_StringToMemIni( BFSectionName, BFSelfName, NeededRectStr );

    N_Dump1Str( 'Before BaseFormInit();' );
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

//    BFFormMaxRect := Rect(0,0,1279,975);
//    BFFormMaxRect := Rect(0,0,150,150);
//    BFChangeSelfSize( Point(450,450) );

    DumpCoords( 'After BaseFormInit();' );
    Show();
    DumpCoords( 'After Show:' );
  end; // with Result do

  Exit;


  Result := TN_CMTestDelphiForm.Create( Application );
  with Result do
  begin
//    BaseFormInit( nil, '' );

//    N_Dump1Str( Format( '1) TButton2 %x', [PInteger(@Button2.Anchors)^] ) );
    Button2.Anchors := [akRight, akBottom]; // temporary, later remove!
//    N_Dump1Str( Format( '2) TButton2 %x', [PInteger(@Button2.Anchors)^] ) );
    DumpCoords( 'After TN_CMTestDelphiForm.Create:' );

//    DisableAlign();
//    N_Dump1Str( 'After DisableAlign:' );
//    DumpCoords();

    N_Dump1Str( 'Before BaseFormInit();' );
//    BaseFormInit();
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    N_Dump1Str( '' );
    DumpCoords( 'After BaseFormInit();' );

    goto Skip1;

//    Height := 320;
//    Width := 260;

    with HorzScrollBar do // get Vertical additional Size
    begin
      Delta := Height - ClientHeight;

      if IsScrollBarVisible() then // Horizontal ScrollBar is Visible
      begin
        Visible := False;
        MinDelta := Height - ClientHeight;
        Visible := True;
        SBSize := Delta - MinDelta;
      end else // Horizontal ScrollBar is NOT Visible
      begin
        MinDelta := Delta;
        SavedRange := Range;
        Range := ClientWidth + 1;
        Delta := Height - ClientHeight;
        Range := SavedRange;
        SBSize := Delta - MinDelta;
      end; // else // Horizontal ScrollBar is NOT Visible
    end; // with HorzScrollBar do // get Vertical additional Size

    N_Dump1Str( Format( 'Vert MinDelta=%d SBSize=%d', [MinDelta,SBSize] ));


//      Delta := Width - ClientWidth;

//    if

//    Width  := 1264;
//    Height := 978;
//    Left := 8;
//    Top  := 8;

//    Width  := 300;
//    Height := 300;

    goto Skip1;

    HorzScrollBar.Visible := False;
    VertScrollBar.Visible := False;
    DumpCoords( 'Set ScrollBars Visible to False' );

    N_Dump1Str( 'DisableAlign' );
    DisableAlign();
{
    Panel1.Left := 1500;
    Panel1.Top  := 1500;
    Panel1.Width := 1;
    Panel1.Height := 1;

    ClientWidth  := Panel1.Left + Panel1.Width  + 30;
    ClientHeight := Panel1.Top  + Panel1.Height + 30;
    ClientWidth  := Panel1.Left + Panel1.Width  + 1;
    ClientHeight := Panel1.Top  + Panel1.Height + 1;
}
    DumpCoords( 'After proper increase:' );


    N_Dump1Str( 'After Realign' );
    Realign();
//    DumpCoords();

    N_Dump1Str( 'EnableAlign' );
    EnableAlign();
//    DumpCoords();


//    ClientWidth  := Panel1.Left + Panel1.Width  + 1;
//    ClientHeight := Panel1.Top  + Panel1.Height + 1;
    Realign();

    N_Dump1Str( 'After precise increase:' );
//    DumpCoords();

    Width  := Width  + 1;
    Height := Height + 1;
    N_Dump1Str( 'After increase +1:' );
//    DumpCoords();

    Width  := Width  + 100;
    Height := Height + 100;
    N_Dump1Str( 'After increase +100:' );
//    DumpCoords();

//    ClientWidth  := Panel1.Left + Panel1.Width  + 30;
//    ClientHeight := Panel1.Top  + Panel1.Height + 30;

    N_Dump1Str( 'After increase +30:' );
//    DumpCoords();

//    ClientWidth  := Panel1.Left + Panel1.Width  + 1;
//    ClientHeight := Panel1.Top  + Panel1.Height + 1;

    N_Dump1Str( 'After decrease -29:' );
//    DumpCoords();

    Width  := 158;
    Height := 190;
    N_Dump1Str( 'After Shrink (Set New Small Size (158 190)):' );
//    DumpCoords();

    Skip1:
    Show();
//    ShowModal();
    DumpCoords( 'After Show:' );

//    N_Dump1Str( 'EnableAlign' );
//    EnableAlign();
//    DumpCoords();

  end;
end; // function N_ShowCMTestDelphiForm


end.
