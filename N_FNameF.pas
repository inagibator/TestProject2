unit N_FNameF;
// Form with FileNameFrame for choosing File Name

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  N_Types, N_FNameFr, N_BaseF, ExtCtrls;

type TN_FileNameForm = class( TN_BaseForm )
    FileNameFrame: TN_FileNameFrame;
    bnCancel: TButton;
    bnOK: TButton;
    procedure FormClose( Sender: TObject; var Action: TCloseAction ); override;
    procedure FileNameFramembFileNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    function SelectFileName( IniFSectionName: string ): string;
end; // type TN_FileNameForm = class( TForm )

implementation
uses N_Lib1;
{$R *.dfm}

procedure TN_FileNameForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;

  Action := caFree;
end;

//**********************************  TN_FileNameForm.SelectFileName  ********
// ShowModal Self and return choosen FileName
// use and update given N_CurMemIni section (with File Names History)
//
function TN_FileNameForm.SelectFileName( IniFSectionName: string ): string;
begin
  with FileNameFrame do
  begin
//    InitFromMemIniFile( N_CurMemIni, IniFSectionName );
    N_MemIniToComboBox( 'IniFSectionName', FileNameFrame.mbFileName );
    ShowModal;
//    UpdateMemIniFile();
    N_ComboBoxToMemIni( 'IniFSectionName',  FileNameFrame.mbFileName );

    if (ModalResult = mrOk) then Result := mbFileName.Text
                            else Result := '';
  end; // with FileNameFrame.mbFileName do
end; // function TN_FileNameForm.SelectFileName

procedure TN_FileNameForm.FileNameFramembFileNameChange(Sender: TObject);
begin
  inherited;
  FileNameFrame.mbFileNameChange(Sender);

end;

end.
