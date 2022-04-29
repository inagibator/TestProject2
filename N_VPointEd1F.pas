unit N_VPointEd1F;
// Visual Point (as two values) Editor #1 Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FrRAEdit,
  N_Types, N_BaseF, N_VVEdBaseF;

type TN_VPointEd1Form = class( TN_VVEdBaseForm )
    bnIncBigX: TButton;
    bnIncSmallX: TButton;
    bnDecSmallX: TButton;
    bnDecBigX: TButton;
    edValue: TEdit;
    mbNumDigits: TComboBox;
    mbValStep: TComboBox;
    mbValMultCoef: TComboBox;
    bnDecSmallY: TButton;
    bnDecBigY: TButton;
    bnIncSmallY: TButton;
    bnIncBigY: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_VPointEd1Form = class( TN_VVEdBaseForm )

type TN_RAFPointVEditor = class( TK_RAFEditor ) // Any Rect Field Visual Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFPointVEditor = class( TK_RAFEditor )


    //*********** Global Procedures  *****************************

implementation
uses
  K_Script1; // N_Gra0, N_Gra1, N_Lib1, N_EdStrF, N_Rast1Fr,
{$R *.dfm}

//****************  TN_VPointEd1Form class handlers  ******************

procedure TN_VPointEd1Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_VPointEd1Form.FormClose

//****************  TN_VPointEd1Form class public methods  ************

//***********************************  TN_VPointEd1Form.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_VPointEd1Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_VPointEd1Form.CurStateToMemIni

//***********************************  TN_VPointEd1Form.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_VPointEd1Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_VPointEd1Form.MemIniToCurState

//****************  TN_RAFPointVEditor class methods  ******************

//**************************************** TN_RAFPointVEditor.Edit
// Point External Editor
//
function TN_RAFPointVEditor.Edit( var AData ): Boolean;
begin
  with TN_VPointEd1Form.Create( Application ) do
  begin
    InitVVEdForm1( @AData, RAFrame, 'VVE' );
    Show();
  end;
  Result := False;
end; //*** procedure TN_RAFPointVEditor.Edit


    //*********** Global Procedures  *****************************
{
Initialization
  K_RegRAFEditor( 'NPointVEditor', TN_RAFPointVEditor );
}

end.
