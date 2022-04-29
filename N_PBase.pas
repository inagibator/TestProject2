unit N_PBase;
// BasePage form and its event handlers

// type TN_BasePage = class(TForm) - Base form for Pages in Page Windows Manager

interface
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ComCtrls, ExtCtrls, ToolWin, Types;

type TN_BasePage = class(TForm) // Base form for Pages in Page Windows Manager
    StatusBar: TStatusBar;
  destructor Destroy(); override;
  procedure FormClose     ( Sender: TObject; var Action: TCloseAction );
  procedure FormStartDock ( Sender: TObject; var DragObject: TDragDockObject);
  procedure FormEndDock   ( Sender, Target: TObject; X, Y: Integer );
  procedure FormActivate  ( Sender: TObject );
     public
    DFlags: integer; // Destroy flags
  procedure PageActivate (); virtual;
  procedure UpdatePageOnEndDock (); virtual;
end; // end type TN_BasePage = class(TForm)

procedure N_DestroyAllPages();

//****************** Global variables **********************
var
  N_NumForms: integer = 10; // for creating unic forms and frames names
  N_PageList: TList;               // list of all Pages
  N_ActivePage: TN_BasePage = nil; // currently Active Page

implementation
uses N_PWin;
{$R *.DFM}

//********** TN_BasePage class methods  **************

//************************************************ TN_BasePage.Destroy ***
// Destroy Self
//
destructor TN_BasePage.Destroy();
begin
  N_PageList.Remove( self );  // remove self from PageList
  if N_ActivePage = self then N_ActivePage := nil;
  inherited;
end; // end of destructor TN_BasePage.Destroy

//************************************************ TN_BasePage.FormClose ***
// OnClose event handler
//
procedure TN_BasePage.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Action := caFree; // destroy form flag
end;

//************************************************ TN_BasePage.FormStartDock ***
// OnStartDock event handler
//
procedure TN_BasePage.FormStartDock( Sender: TObject;
                                          var DragObject: TDragDockObject );
begin
  N_IsDockingNow := True; // to prevent Page fields changing while docking
end;

//************************************************ TN_BasePage.FormEndDock ***
// OnEndDock event handler
// occures always when MouseUp on window header or on page header
// set self page new N_ActivePage and make it ActivePage in PageControl
//
procedure TN_BasePage.FormEndDock( Sender, Target: TObject; X,Y: Integer );
begin
  if (Self.Parent <> nil)     and      // self page is docked into PWin
     (Self.Parent.Parent is TPageControl) then
    TPageControl(Self.Parent.Parent).ActivePage := TTabSheet(Self.Parent);

  N_IsDockingNow := False; // enable Page fields changing
  FormActivate( Self );
  UpdatePageOnEndDock();
end;

//************************************************ TN_BasePage.FormActivate ***
// set N_ActivePage := self and update Page Caption
// ( OnActivate event handler, this event occures always when
//   MouseUp on window header or on page header )
//
procedure TN_BasePage.FormActivate( Sender: TObject );
begin
  // Own method PageActivate should be used, because overloading of
  // FormActivate method does not work!
  PageActivate();
end; // end of procedure TN_BasePage.FormActivate

//************************************************ TN_BasePage.PageActivate ***
// set N_ActivePage := self and update Page Caption
// ( is called from TN_BasePage.FormActivate event handler)
// should be overload, if needed, to update N_ActiveVTree
//
procedure TN_BasePage.PageActivate();
var
  Str: string;
begin
  if N_IsDockingNow then Exit; // prevent change caption while docking
  if self = N_ActivePage then Exit;
  if N_ActivePage <> nil then // del '(*)' in previously active Page
  begin
    Str := N_ActivePage.Caption;
    if Copy( Str, 1, 3 ) <> '(*)' then
                  ShowMessage( '!ERROR: Active Page without (*): ' + Str );
    System.Delete( Str, 1, 3 ); // del '(*)'
    N_ActivePage.Caption := Str;
  end;
  N_ActivePage := self;
  Str := N_ActivePage.Caption;
  if Copy( Str, 1, 3 ) = '(*)' then
                  ShowMessage( '!ERROR: Not Active Page with (*): ' + Str );
  N_ActivePage.Caption := '(*)' + Str;
end; // end of procedure TN_BasePage.PageActivate

//*************************************** TN_BasePage.UpdatePageOnEndDock ***
// update references to TTreeNodes (if exists), that are changed while docking
// should be overload for Pages with TTreeView fields
//
procedure TN_BasePage.UpdatePageOnEndDock;
begin
//  empty for TN_BasePage
end; // end of procedure TN_BasePage.UpdatePageOnEndDock

//****************** Global procedures **********************

//************************************************ N_DestroyAllPages ***
// Destroy All Pages (ancestors ot TN_BasePage objects)
//
procedure N_DestroyAllPages();
begin
  while N_PageList.Count >= 1 do
    TN_BasePage(N_PageList.Items[0]).Destroy;
  N_ActivePage := nil;
end; // end of procedure N_DestroyAllPages

end.
