unit N_MemoF;
// Form with TMemo for viewing and editing texts

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  N_Types, N_Lib1, N_BaseF, StdCtrls, ActnList, Menus;

type TN_MemoForm = class( TN_BaseForm ) // Form with TMemo for viewing and editing texts
    Memo: TMemo;
    ContextMenu: TPopupMenu;
    TMemoActions: TActionList;

    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_MemoForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_ShowLogChanForm ( ALCInd: integer; AOwner: TN_BaseForm ): TN_MemoForm;

function  N_CreateMemoForm ( AFormName: string; AOwner: TN_BaseForm ): TN_MemoForm;

//var
//    N_MemoForm: TN_MemoForm;

implementation
uses
  N_ButtonsF;
{$R *.dfm}

//****************  TN_MemoForm class handlers  ******************

//*************************************************** TN_MemoForm.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_MemoForm.FormClose( Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  Inherited;

  for i := 0 to High(N_LogChannels) do // clear all refs to Self from Protocol Channels
    with N_LogChannels[i] do
      if LCShowForm = Self then LCShowForm := nil;
end; // procedure TN_MemoForm.FormClose


//****************  TN_MemoForm class public methods  ************

//******************************************** TN_MemoForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_MemoForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_MemoForm.CurStateToMemIni

//******************************************** TN_MemoForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_MemoForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_MemoForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//****************************************************** N_ShowLogChanForm ***
// Show Protocol Chanel Form for given Protocol Channel Index
//
//     Parameters
// APCInd - given Protocol Channel Index
// AOwner - Owner of Form if it should be created
// Result - Return Opened Form
//
// Create if needed TN_MemoForm for showing Protocol and show it
//
function N_ShowLogChanForm( ALCInd: integer; AOwner: TN_BaseForm ): TN_MemoForm;
//var
//  PrevHWND, NewHWND: HWND;
begin
  Result := nil;
  if (ALCInd < 0) or (ALCInd > High(N_LogChannels)) then Exit;

  with N_LogChannels[ALCInd] do
  begin
    if LCShowForm = nil then // Create New Form and fill it by PCBuf
    begin
      LCShowForm := N_CreateMemoForm( 'ProtChanForm'+IntToStr(ALCInd), AOwner );
      if LCShowForm is TN_MemoForm then
      with TN_MemoForm(LCShowForm) do
      begin
        if lcfFlushMode in LCFlags then
        begin
          if FileExists( LCFullFName ) then
            Memo.Lines.LoadFromFile( LCFullFName );
        end else
          Memo.Lines.Assign( LCBuf );

        Caption := 'Log Channel ' + IntToStr( ALCInd );
      end;
    end; // if PCShowForm = nil then // Create New Form and fill it by PCBuf

    if LCShowForm is TN_MemoForm then // make it visible
    with TN_MemoForm(LCShowForm) do
    begin

      Memo.WordWrap := False;
      Memo.ScrollBars := ssBoth;

      if not Visible then Show;

      FormStyle := fsStayOnTop;

      //*** Scroll to the end of Lines (should be done after Show and after setting FormStyle!)
      Memo.SelStart := 10000000; // more than current Ptotocol Size in bytes
      Memo.SelLength := 1;
    end; // with TN_MemoForm(PCShowForm) do

    if LCShowForm is TN_MemoForm then
      Result := TN_MemoForm(LCShowForm);

  end; // with N_LogChannels[ALCInd] do

end; // function N_ShowLogChanForm

//******************************************************** N_CreateMemoForm ***
// Create and return new instance of TN_MemoForm
//
//     Parameters
// AOwner - Owner of created Form
// Result - Return created Form
//
function N_CreateMemoForm( AFormName: string; AOwner: TN_BaseForm ): TN_MemoForm;
begin
  Result := TN_MemoForm.Create( Application );
  N_PlaceTControl( Result, 4, 400, 300 ); // used only if no info in MemIni
  
  with Result do
  begin
//    BaseFormInit( AOwner, AFormName );
    BaseFormInit( AOwner, AFormName, [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    CurArchiveChanged();
  end;
end; // function N_CreateMemoForm

end.
