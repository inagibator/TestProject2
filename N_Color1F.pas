unit N_Color1F;
// Color Editor Form, based upon Color1Frame

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, ValEdit, StdCtrls, ExtCtrls, ActnList, Menus,
  ToolWin,
  K_FrRAEdit,
  N_Types, N_Lib1, N_BaseF, N_Color1Fr;

type TN_Color1Form = class( TN_BaseForm ) //***** Form for editing one Color
    Color1Frame: TN_Color1Frame;
    procedure FormShow  ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
end; // type TN_Color1Form = class( TN_BaseForm )

type TN_RAFColorViewer = class( TK_RAFViewer ) // External Color Field Viewer
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; Canvas : TCanvas ); override;
end; //*** type TN_RAFColorViewer = class( TK_RAFViewer )

type TN_RAFColorVEditor = class( TK_RAFEditor ) // External Color Field Visual Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFColorVEditor = class( TK_RAFEditor )


//****************** Global procedures **********************

function  N_CreateColor1Form ( AOwner: TN_BaseForm = nil ): TN_Color1Form; overload;
function  N_CreateColor1Form ( var AColor: integer; AGAProcOfObj: TK_RAFGlobalActionProc = nil;
                              AOwner: TN_BaseForm = nil ): TN_Color1Form; overload;
function  N_ModalEditColor ( AColor: integer; ACaption: string = '' ): integer;

implementation
uses
  K_Script1;
{$R *.dfm}

//****************  TN_Color1Form class handlers  ******************

procedure TN_Color1Form.FormShow( Sender: TObject );
// Set ActiveControl to prevent blinking Red ScrollBar button
begin
  Inherited;
  ActiveControl := Color1Frame.bnOK;
end; // procedure TN_Color1Form.FormShow

procedure TN_Color1Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_Color1Form.FormClose


//****************  TN_RAFColorViewer class methods  ******************

//**************************************** TN_RAFColorViewer.DrawCell
//
//
procedure TN_RAFColorViewer.DrawCell(var Data; var RAFC : TK_RAFColumn;
                                ACol, ARow : Integer; Rect: TRect;
                                State: TGridDrawState; Canvas: TCanvas);
begin

  with RAFC do
    if (CDType.DTCode = Ord(nptColor)) and
       (@Data <> nil) then begin
      CFillColor := Integer(data);
      Include( ShowEditFlags, K_racUseFillColor );
    end;
  inherited DrawCell( Data, RAFC, ACol, ARow, Rect, State, Canvas );


end; //*** procedure TN_RAFColorViewer.DrawCell


//****************  TN_RAFColorVEditor class methods  ******************

//**************************************** TN_RAFColorVEditor.Edit
//
//
function TN_RAFColorVEditor.Edit( var AData ) : Boolean;
var
//  Color1Form: TN_Color1Form;
  OwnerForm:  TN_BaseForm;
begin
  if RAFrame.Owner is TN_BaseForm then OwnerForm := TN_BaseForm( RAFrame.Owner )
                                  else OwnerForm := nil;

  with N_CreateColor1Form( Integer(AData), RAFrame.RAFGlobalActionProc, OwnerForm ) do
    Show();
{
  Color1Form := N_CreateColor1Form( OwnerForm );
  with Color1Form.Color1Frame do
  begin
    ParentForm := Color1Form;
    PData := @AData;
    GAProcOfObj := RAFrame.RAFGlobalAction;
    SetLength( UndoColors, 1 );
    UndoColors[0] := Integer(AData); // Initial Color
    UndoFreeInd := 1;
    UndoMaxInd  := 0;
    miAutoApplyMode.Checked := False; // to prevent writing data in SetFieldsByColor
    Color1Form.Show();
    SetFieldsByColor( Integer(AData) ); // should be called after Show to
                                        // prevent blinking Red ScrollBar button
    miAutoApplyMode.Checked := True;
  end;
}  
  Result := False;
end; //*** procedure TN_RAFColorVEditor.Edit


//****************** Global procedures **********************

//**********************************************  N_CreateColor1Form  ******
// Create N_Color1Form
//
function N_CreateColor1Form( AOwner: TN_BaseForm ): TN_Color1Form;
begin
  Result := TN_Color1Form.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
  end;
end; // end of function N_CreateColor1Form

//**********************************************  N_CreateColor1Form  ******
// Create and initialize N_Color1Form
//
// AColor       - variable, that would be changed while editing
// AGAProcOfObj - ProcOfObj, that should be called while editing
// AOwner       - Self Owner
//
function N_CreateColor1Form( var AColor: integer; AGAProcOfObj: TK_RAFGlobalActionProc;
                                          AOwner: TN_BaseForm ): TN_Color1Form;
begin
  Result := N_CreateColor1Form( AOwner );
  with Result.Color1Frame do
  begin
    ParentForm := Result;
    PData := @AColor;
    GAProcOfObj := AGAProcOfObj;
    SetLength( UndoColors, 1 );
    UndoColors[0] := AColor; // Initial Color
    UndoFreeInd := 1;
    UndoMaxInd  := 0;
    miAutoApplyMode.Checked := False; // to prevent writing data in SetFieldsByColor
    SetFieldsByColor( AColor );

    if Assigned(GAProcOfObj) then
      miAutoApplyMode.Checked := True;
  end; // with Result.Color1Frame do
end; // end of function N_CreateColor1Form

//**********************************************  N_ModalEditColor  ******
// Edit given AColor in Modal Mode
//
function N_ModalEditColor( AColor: integer; ACaption: string = '' ): integer;
begin
  Result := AColor;
  with N_CreateColor1Form( Result ) do
  begin
    if ACaption <> '' then
      Caption := ACaption;
    ShowModal();
  end;
end; // end of function N_ModalEditColor

{
Initialization
  K_RegRAFEditor( 'NRAFColorVEditor', TN_RAFColorVEditor );
}
end.
