unit N_VScalEd1F;
// Visual Scalar Editor #1 Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FrRAEdit,
  N_Types, N_BaseF, N_VVEdBaseF;

type TN_VScalEd1Form = class( TN_VVEdBaseForm )
    bnIncBig: TButton;
    bnIncSmall: TButton;
    bnDecSmall: TButton;
    bnDecBig: TButton;
    edValue: TEdit;
    mbNumDigits: TComboBox;
    mbValStep: TComboBox;
    mbValMultCoef: TComboBox;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_VScalEd1Form = class( TN_VVEdBaseForm )

type TN_RAFScalVEditor = class( TK_RAFEditor ) // Any Rect Field Visual Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFScalVEditor = class( TK_RAFEditor )


    //*********** Global Procedures  *****************************

implementation
uses
  K_Script1,
  N_RAEditF;
{$R *.dfm}

//****************  TN_VScalEd1Form class handlers  ******************

procedure TN_VScalEd1Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_VScalEd1Form.FormClose

//****************  TN_VScalEd1Form class public methods  ************

//***********************************  TN_VScalEd1Form.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_VScalEd1Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_VScalEd1Form.CurStateToMemIni

//***********************************  TN_VScalEd1Form.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_VScalEd1Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_VScalEd1Form.MemIniToCurState

//****************  TN_RAFScalVEditor class methods  ******************

//**************************************** TN_RAFScalVEditor.Edit
// Scalar Value External Editor
//
function TN_RAFScalVEditor.Edit( var AData ) : Boolean;
begin
  with TN_VScalEd1Form.Create( Application ) do
  begin
    InitVVEdForm1( @AData, RAFrame, 'VVE' );
    Show();
  end;
  Result := False;
end; //*** procedure TN_RAFScalVEditor.Edit


    //*********** Global Procedures  *****************************
{
Initialization
  K_RegRAFEditor( 'NScalVEditor', TN_RAFScalVEditor );
}
end.
