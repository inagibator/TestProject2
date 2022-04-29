unit N_MsgDialF;
// own Message Dialog Form
//( temporary version, later - improve it!)

// QDialogs (CLX platform) and Dialogs(Windows platform) are not compatible
// and should not be used together!!
// all files in project should use either QDialogs or Dialogs !!

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, Menus,
  N_Types;

type TN_MsgDialogForm = class( TForm )
    bnOK: TButton;
    bnCancel: TButton;
    bnYes: TButton;
    bnNo: TButton;
    lbMessage: TLabel;
    Button1: TButton;
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
end; // type TN_MsgDialogForm = class( TForm )

const
  mbYesNo = [mbYes, mbNo];

    //*********** Global Procedures  *****************************

function N_MessageDlg_VRE( Msg: string; DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons; HelpCtx: integer = 0;
                       ACaption: string = '' ): integer;

procedure N_ShowInfoDlg         ( AInfo: string );
function  N_ConfirmOverwriteDlg ( AFName: string ): boolean;
function  N_DeleteFileDlg       ( AFName: string ): boolean;
function  N_CreateNewFileDlg    ( AFName: string ): boolean;
function  N_CreateFileCopyDlg   ( AFName: string ): string;
function  N_RenameFileDlg       ( AFName: string ): string;

// some Delphi type and constants:
//
//  TMsgDlgType = (mtCustom, mtInformation, mtWarning, mtError, mtConfirmation);
//  TMsgDlgBtn  = (mbNone, mbOk, mbCancel, mbYes, mbNo, mbAbort, mbRetry, mbIgnore);
//  TMsgDlgButtons = set of TMsgDlgBtn;
//
//  mbYesNoCancel = [mbYes, mbNo, mbCancel];
//  mbYesNo       = [mbYes, mbNo];
//  mbOKCancel    = [mbOK, mbCancel];
//  mbAbortRetryIgnore = [mbAbort, mbRetry, mbIgnore];

implementation
uses
  K_CLib0,
  N_Lib0, N_Lib1, N_EdStrF;
{$R *.dfm}

//****************  TN_MsgDialogForm class handlers  ******************

procedure TN_MsgDialogForm.FormClose( Sender: TObject;
                                               var Action: TCloseAction );
begin
  Action := caFree;
end; // procedure TN_MsgDialogForm.FormClose

    //*********** Global Procedures  *****************************

function N_MessageDlg_VRE( Msg: string; DlgType: TMsgDlgType;
                           Buttons: TMsgDlgButtons; HelpCtx: integer = 0;
                           ACaption: string = '' ): integer;
var
  NumLines: integer;
begin
  with TN_MsgDialogForm.Create( Application ) do
  begin
    NumLines := N_CalcNumChars( Msg, 0, -1, Char($0D) ) + 2;

    if NumLines > 8 then // Increase Form Height
      Height := Height + 16*(NumLines-8);

    lbMessage.Caption := Msg;

    if mbOK     in Buttons then bnOK.Visible     := True;
    if mbCancel in Buttons then bnCancel.Visible := True;
    if mbYes    in Buttons then bnYes.Visible    := True;
    if mbNo     in Buttons then bnNo.Visible     := True;

    if DlgType = mtInformation  then Caption := ACaption + ' Info :';
    if DlgType = mtWarning      then Caption := ACaption + ' Warning :';
    if DlgType = mtError        then Caption := ACaption + ' Error :';
    if DlgType = mtConfirmation then Caption := ACaption + ' Confirmation :';

    if N_CurLang = clRussian then
    begin
      if DlgType = mtInformation  then Caption := ACaption + ' Информация :';
      if DlgType = mtWarning      then Caption := ACaption + ' Предупреждение :';
      if DlgType = mtError        then Caption := ACaption + ' Ошибка :';
      if DlgType = mtConfirmation then Caption := ACaption + ' Подтверждение :';

      bnCancel.Caption := 'Прервать';
      bnYes.Caption    := 'Да';
      bnNo.Caption     := 'Нет';
    end; // if N_CurLang = clRussian then

    Result := ShowModal();
  end;
end; // end of function N_MessageDlg

//*********************************************************** N_ShowInfoDlg ***
// Just show given AInfo string and return
//
procedure N_ShowInfoDlg( AInfo: string );
begin
  N_MessageDlg_VRE( AInfo, mtInformation, [mbOK], 0 );
end; // end of procedure N_ShowInfoDlg

//********************************************** N_ConfirmOverwriteDlg ***
// Show "Overwrite File" modal dialog and return True if Overwrite
//
// AFName - File Name to overwrite
//
function N_ConfirmOverwriteDlg( AFName: string ): boolean;
begin
  Result := True;
  AFName := K_ExpandFileName( AFName );
  if not FileExists( AFName ) then Exit;

  if N_MessageDlg_VRE( 'File  "' + AFName + '" already exists. Overwrite it ?',
                    mtConfirmation, mbOKCancel, 0 ) = mrCancel then
    Result := False;
end; // end of function N_ConfirmOverwriteDlg

//********************************************** N_DeleteFileDlg ***
// Show "Delete File" modal dialog and return True and DELETE file if OK
// return False if cancelled
//
// FName - File Name to Delete
//
function N_DeleteFileDlg( AFName: string ): boolean;
begin
  AFName := K_ExpandFileName( AFName );
  Result := True;

  if not FileExists( AFName ) then
  begin
    N_MessageDlg_VRE( 'File  "' + AFName + '" not exists!', mtInformation, [mbOK], 0 );
    Result := False;
    Exit;
  end;

  if N_MessageDlg_VRE( 'Are You sure to delete file  "' + AFName + '"  ?',
                        mtConfirmation, mbOKCancel, 0 ) = mrOK then
    Result := DeleteFile( AFName );
end; // end of function N_DeleteFileDlg

//********************************************** N_CreateNewFileDlg ***
// Create new empty File, return True if OK
//
// AFName - File Name to Create
//
function N_CreateNewFileDlg( AFName: string ): boolean;
begin
  Result := False;

  if N_ConfirmOverwriteDlg( AFName ) then
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    Result := ( THandle(-1) <> FileCreate( AFName ) );
{$ELSE}         // Delphi 7 or Delphi 2010
    Result := ( -1 <> FileCreate( AFName ) );
{$IFEND CompilerVersion >= 26.0}
end; // end of function N_CreateNewFileDlg

//********************************************** N_CreateFileCopyDlg ***
// Create a Copy of given AFName, return New File Name if OK or ''
//
// AFName - File Name to Copy
//
function N_CreateFileCopyDlg( AFName: string ): string;
var
  NewFName: string;
begin
  AFName := K_ExpandFileName( AFName );
  Result := '';

  if not FileExists( AFName ) then
  begin
    N_MessageDlg_VRE( 'File  "' + AFName + '" not exists!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  NewFName := AFName;
  if not N_EditString( NewFName, 'Enter New File Name', 400 ) then // cancelled
    Exit;

  //***** Here: New File Name was Entered OK

  if N_ConfirmOverwriteDlg( NewFName ) then
  begin
    N_CreateFileCopy( AFName, NewFName );
    Result := NewFName;
  end;

end; // end of function N_CreateFileCopyDlg

//********************************************** N_RenameFileDlg ***
// Create new empty Text File, return New File Name if OK or ''
//
// AFName - File Name to Rename
//
function N_RenameFileDlg( AFName: string ): string;
var
  NewFName: string;
begin
  AFName := K_ExpandFileName( AFName );
  Result := '';

  if not FileExists( AFName ) then
  begin
    N_MessageDlg_VRE( 'File  "' + AFName + '" not exists!', mtInformation, [mbOK], 0 );
    Exit;
  end;

  NewFName := AFName;
  if not N_EditString( NewFName, 'Enter New File Name', 400 ) then // cancelled
    Exit;

  //***** Here: New File Name was Entered OK

  if NewFName = AFName then Exit; // New Name is same as existing Name

  if N_ConfirmOverwriteDlg( NewFName ) then
  begin
    if FileExists( NewFName ) then
      DeleteFile( NewFName );

    if RenameFile( AFName, NewFName ) then
       Result := NewFName;
  end;

end; // end of function N_RenameFileDlg

Initialization
  N_MessageDlg := N_MessageDlg_VRE;

end.
