unit N_PWin;
// PWin (Pages Windows) clases, procedures and global variables

// type TN_PWinForm = class( TForm )    - one Page Window

interface
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     ComCtrls, Types,
     N_PBase;

type TN_PWinForm = class( TForm ) //*** one Pages Window
    PageControl: TPageControl;      // Pages container
  procedure FormActivate ( Sender: TObject );
  procedure FormClose    ( Sender: TObject; var Action: TCloseAction );
  procedure FormDestroy  ( Sender: TObject );
    public
  procedure AddGivenPage ( Page: TN_BasePage; Mode: integer );
end; //*** end of type TN_PWinForm  = class( TForm )

procedure N_CreatePwin ( PwinName: string );
procedure N_DestroyAllPwin();

var
  N_ActivePWin: TN_PWinForm = nil;  // currently active PWin form
  N_IsDockingNow: Boolean = False;  // to prevent some actions while docking
  N_PWinList: TList;                // list of all PWin objects

implementation
uses
     N_Types, N_Lib1;
{$R *.DFM}

//********** TN_PWinForm class methods  **************

//************************************************ TN_PWinForm.FormActivate ***
// update N_ActivePWin and N_ActivePage
// (onActivate event handler)
//
procedure TN_PWinForm.FormActivate( Sender: TObject );
var
  Str: string;
begin
  if N_IsDockingNow then Exit; // prevent change caption while docking
  if PageControl.PageCount > 0 then
    TN_BasePage(PageControl.ActivePage.Controls[0]).FormActivate( Sender );

  if N_ActivePWin = self then Exit;
  if N_ActivePWin <> nil then // del '(*) ' in previously active PWin
  begin
    Str := N_ActivePWin.Caption;
    System.Delete( Str, 1, 4 ); // del '(*) '
    N_ActivePWin.Caption := Str;
  end;
  Caption := '(*) ' + Caption;
  N_ActivePWin := self;
end; // end of function TN_PWinForm.FormActivate

//************************************************ TN_PWinForm.FormClose ***
// OnClose event handler
//
procedure TN_PWinForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree; // destroy form flag
// Remark: OnClose event does not occure when closing main form,
//         all own needed actions should be placed in ONDestroy event handler!
end; // end of procedure TN_PWinForm.FormClose

//************************************************ TN_PWinForm.FormDestroy ***
// OnDestroy event handler
//
procedure TN_PWinForm.FormDestroy(Sender: TObject);
var
  i: integer;
  BPage: TN_BasePage;
begin
  if N_ApplicationTerminated then Exit;
  if N_ActivePWin = self then N_ActivePWin := nil;
  N_PWinList.Remove( self );

//  Remark: when closing aplication, Pages and PWin are destoyed in
//          arbitrary order, depending, probably, upon creation order.
//          So, checking if TabSheets is empty is needed

  for i := 0 to self.PageControl.PageCount-1 do
  begin
    if self.PageControl.Pages[i].ControlCount >= 1 then
    begin
      BPage := TN_BasePage( self.PageControl.Pages[i].Controls[0]);
      BPage.Free;
    end;
  end;
end; // end of procedure TN_PWinForm.FormDestroy

//************************************************ TN_PWinForm.AddGivenPage ***
// show given Page as separate window if Mode=0 or add it to N_ActivePWin
//
procedure TN_PWinForm.AddGivenPage( Page: TN_BasePage; Mode: integer );
begin
  if Mode <> 0 then // add given Page to self
  begin
    Page.ManualDock( PageControl, nil, alClient );
       // address of TN_PageDTree(Page).DTree.TV.Items[i] was changed!!
    PageControl.ActivePage := TTabSheet( Page.Parent );
  end;
  Page.FormActivate( nil );
  N_PageList.Add( Page );
  Page.Show;
  Page.UpdatePageOnEndDock;
end; // end of procedure TN_PWinForm.AddGivenPage

//****************** Global procedures **********************

//************************************************ N_CreatePwin ***
// create new PWin obj and show its form
//
procedure N_CreatePwin( PwinName: string );
var
  PWinForm: TN_PWinForm;
begin
  Application.CreateForm( TN_PWinForm, PWinForm );
  PWinForm.Caption := PwinName;
  N_PWinList.Add( PWinForm );
  PWinForm.Show;
end; // end of procedure N_CreatePwin

//************************************************ N_DestroyAllPwin ***
// Destroy All PWin obj
//
procedure N_DestroyAllPwin();
begin
  while N_PWinList.Count >= 1 do
    TN_PWinForm(N_PWinList.Items[0]).Destroy;
  N_ActivePWin := nil;
end; // end of procedure N_DestroyAllPwin

end.
