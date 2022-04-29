unit N_WebBrF;
// Web Brouser Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ActnList, ComCtrls, ToolWin,
  N_Types, N_BaseF;

type TN_WebBrForm = class( TN_BaseForm )
    WebBr: TWebBrowser;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ActionList1: TActionList;
    aRefresh: TAction;
    ToolButton2: TToolButton;
    aGoBack: TAction;
    procedure aGoBackExecute  ( Sender: TObject );
    procedure aRefreshExecute ( Sender: TObject );
  private
    { Private declarations }
  public
    { Public declarations }
end; // type TN_WebBrForm = class( TN_BaseForm )
type TN_PWebBrForm = ^TN_WebBrForm;


    //*********** Global Procedures  *****************************

procedure N_ViewHTMLStrings ( AHTML: TStrings; APBrForm: TN_PWebBrForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewHTMLFile ( AFName: string; APBrForm: TN_PWebBrForm;
                                                         AOwner: TN_BaseForm );

function  N_CreateWebBrForm ( AOwner: TN_BaseForm ): TN_WebBrForm; overload;
procedure N_CreateWebBrForm ( APBrForm: TN_PWebBrForm; AOwner: TN_BaseForm ); overload;

implementation
{$R *.dfm}
uses
  K_CLib0, // K_Arch,
  N_ButtonsF, N_Lib0;

procedure TN_WebBrForm.aGoBackExecute( Sender: TObject );
// GoBack
begin
  WebBr.GoBack();
end; // procedure TN_WebBrForm.aGoBackExecute

procedure TN_WebBrForm.aRefreshExecute( Sender: TObject );
// Refresh current document
begin
  WebBr.Refresh();
end;

    //*********** Global Procedures  *****************************

//*********************************************** N_ViewHTMLStrings ***
// Create (if not yet) WebBrouser Form and show given HTML Strings in it
//
procedure N_ViewHTMLStrings( AHTML: TStrings; APBrForm: TN_PWebBrForm;
                                                         AOwner: TN_BaseForm );
var
  FName: string;
begin
  FName := K_ExpandFileNameByDirPath( '(#TmpFiles#)', 'TestHTML.htm' );
  FName := N_CreateUniqueFileName( FName );

  AHTML.SaveToFile( FName );

  N_ViewHTMLFile( FName, APBrForm, AOwner );
end; // procedure N_ViewHTMLStrings

//*********************************************** N_ViewHTMLFile ***
// Create (if not yet) WebBrouser Form and show given HTML File in it
//
procedure N_ViewHTMLFile( AFName: string; APBrForm: TN_PWebBrForm;
                                                         AOwner: TN_BaseForm );
var
  NewForm: TN_WebBrForm;
  PForm: TN_PWebBrForm;
begin
  if APBrForm <> nil then
  begin
    N_CreateWebBrForm( APBrForm, AOwner );
    PForm := APBrForm;
  end else
  begin
    NewForm := N_CreateWebBrForm( AOwner );
    NewForm.Left := NewForm.Left + 16;
    NewForm.Top  := NewForm.Top  + 16;
    PForm := @NewForm;
  end;

  with PForm^ do
  begin
    Show();
    WebBr.Navigate( 'file://' + AFName );
    Exit;
  end;
end; // procedure N_ViewHTMLFile

//*******************************************  N_CreateWebBrForm(1)  ******
// Create new instance of N_WebBrForm
//
function N_CreateWebBrForm( AOwner: TN_BaseForm ): TN_WebBrForm;
begin
  Result := TN_WebBrForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
  end;
end; // end of function N_CreateWebBrForm(1)

//*********************************************  N_CreateWebBrForm(2)  ******
// Create (if not already created) WebBrForm in given variable
// AOwner  - Owner of new WebBrForm
//
// APBrForm should points to GLOBAL variable,
// because it would be set to nil in OnCloseForm Handler!
//
procedure N_CreateWebBrForm( APBrForm: TN_PWebBrForm; AOwner: TN_BaseForm );
begin
  Assert( APBrForm <> nil, 'APBrForm=nil!' ); // a precaution

  if APBrForm^ = nil then // new RastVCTForm should be created in
  begin                   // given variable, pointed to by APRForm
    APBrForm^ := N_CreateWebBrForm( AOwner );
    APBrForm^.BFOnCloseActions.AddNewClearVarAction( APBrForm );
  end;
end; // end of procedure N_CreateWebBrForm(2)


end.
