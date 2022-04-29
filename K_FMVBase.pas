unit K_FMVBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FMVBase0, K_FrRaEdit;

type
  TK_FormMVBase = class(TK_FormMVBase0)
    FrameRAEdit: TK_FrameRAEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  private
    { Private declarations }
    procedure AfterDataChange; 
  public
    { Public declarations }
    FRAControl : TK_FRAData;
    procedure SaveData; override;
  end;

implementation

{$R *.dfm}
uses N_Types, N_Lib0;
//**************************************** TK_FormMVBase.FormCreate
//
procedure TK_FormMVBase.FormCreate( Sender: TObject );
begin
  inherited;
  FRAControl := TK_FRAData.Create( FrameRAEdit );
  FRAControl.SkipDataBuf := false;
  FRAControl.SetOnDataChange( AfterDataChange );
  FRAControl.SetOnClearDataChange( ClearChangeDataFlag );
  ActionCode := K_fgaOK;
end; //*** procedure TK_FormMVBase.FormCreate

//**************************************** TK_FormMVBase.FormShow
//
procedure TK_FormMVBase.FormShow( Sender: TObject );
begin
  inherited;
  if PDGEditCont <> nil then
    with TK_PRAEditFuncCont(PDGEditCont)^ do begin
      ADType := FDType;
      AModeFlags := FSetModeFlags -[K_ramSkipResizeHeight];
    end;

  FRAControl.PrepFrameByFDTypeName( [], AModeFlags, PData^, ADType, '', AFDTypeName );
end; //*** procedure TK_FormMVBase.FormShow

//**************************************** TK_FormMVBase.SaveData
//
procedure TK_FormMVBase.SaveData;
begin
  FRAControl.StoreToSData;
  inherited;
end; //*** procedure TK_FormMVBase.SaveData

//**************************************** TK_FormMVBase.FormClose
//
procedure TK_FormMVBase.FormClose( Sender: TObject;
                                   var Action: TCloseAction );
begin
  inherited;
  FreeAndNil( FRAControl );
end; //*** procedure TK_FormMVBase.FormClose

//**************************************** TK_FormMVBase.AfterDataChange
//  After Data Change Handler
//
procedure TK_FormMVBase.AfterDataChange;
begin
  AddChangeDataFlag;
  if N_KeyIsDown(VK_RETURN) then 
  BtOKClick(nil);

end; //*** procedure TK_FormMVBase.AfterDataChange


end.
