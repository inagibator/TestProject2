unit K_FMVBase0;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_Types, N_Lib1,
  K_FrRaEdit, K_Script1, K_FBase, N_BaseF;

type
  TK_FormMVBase0 = class(TK_FormBase)
    Panel1: TPanel;
    BtApply: TButton;
    BtCancel: TButton;
    BtOK: TButton;
    procedure BtCancelClick( Sender: TObject );
    procedure BtOKClick( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure FormCloseQuery( Sender: TObject; var CanClose: Boolean );
    procedure BtApplyClick( Sender: TObject );
    procedure AfterSaveData;
  protected
    { Private declarations }
    ActionCode : TK_RAFGlobalAction;
  public
    { Public declarations }
    PDGEditCont : Pointer;
    DataWasChanged : Boolean;
    ResultDataWasChanged : Boolean;
    PData       : Pointer;
    ADType      : TK_ExprExtType;
    AModeFlags  : TK_RAModeFlagSet;
    AFDTypeName : string;
    procedure SaveData; virtual;
    procedure AddChangeDataFlag; virtual;
    procedure ClearChangeDataFlag; virtual;
    function  SaveDataIfNeeded : Word;
    function  IfDataWasChanged: Boolean; override;
  end;

type TK_FormClass = Class of TForm;

type TK_DFMVBaseEditCont = record
  RAEDFC     : TK_RAEditFuncCont;
  FormClass  : TK_FormClass;
end;
type TK_PDFMVBaseEditCont = ^TK_DFMVBaseEditCont;

function K_FMVBaseFormPrepare( var Data; PDContext: Pointer ) : TK_FormMVBase0;
function K_EditFMVBaseFunc( var Data; PDContext: Pointer ) : Boolean;


implementation

uses
  K_UDT1,
  N_ButtonsF;

{$R *.dfm}

//**************************************** K_FMVBaseFormPrepare
//
function K_FMVBaseFormPrepare( var Data; PDContext: Pointer ) : TK_FormMVBase0;
begin
  with TK_PDFMVBaseEditCont(PDContext)^ do begin
    Result := TK_FormMVBase0(FormClass.Create(Application));
    with Result do begin
      BaseFormInit( RAEDFC.FOwner, RAEDFC.FSelfName );
      PDGEditCont := PDContext;
      with RAEDFC do begin
        PData := @Data;
        Caption := FDataCapt;
      end;
    end;
  end;
end; //*** function K_FMVBaseFormPrepare

//**************************************** K_EditFMVBaseFunc
//
function K_EditFMVBaseFunc( var Data; PDContext: Pointer ) : Boolean;
begin
  with K_FMVBaseFormPrepare( Data, PDContext ),
       TK_PDFMVBaseEditCont(PDContext)^ do begin
    if RAEDFC.FNotModalShow then
      Show
    else
      ShowModal;
    Result := ResultDataWasChanged;
  end;
end; //*** function K_EditFMVBaseFunc

//**************************************** TK_FormMVBase0.FormShow
//
procedure TK_FormMVBase0.FormShow(Sender: TObject);
begin
  ActionCode := K_fgaOK;
  ResultDataWasChanged := false;
  ClearChangeDataFlag;
  DataSaveModalState := mrNone;

end; //*** procedure TK_FormMVBase0.FormShow

//**************************************** TK_FormMVBase0.FormCloseQuery
//
procedure TK_FormMVBase0.FormCloseQuery( Sender: TObject;
                                         var CanClose: Boolean );
begin
  CanClose := ( SaveDataIfNeeded() <> mrCancel );
  if not CanClose then Exit;
  if PDGEditCont <> nil then
    with TK_PRAEditFuncCont(PDGEditCont)^ do
      if Assigned(FOnGlobalAction) then FOnGlobalAction( Self, K_fgaNone );
end; //*** procedure TK_FormMVBase0.FormCloseQuery

//**************************************** TK_FormMVBase0.BtApplyClick
//
procedure TK_FormMVBase0.BtApplyClick(Sender: TObject);
begin
  ActionCode := K_fgaApplyToAll;
  SaveData;
  ActionCode := K_fgaOK;
end; //*** procedure TK_FormMVBase0.BtApplyClick

//**************************************** TK_FormMVBase0.BtCancelClick
//
procedure TK_FormMVBase0.BtCancelClick(Sender: TObject);
begin
  DataSaveModalState := mrNo;
  CLose;
end; //*** procedure TK_FormMVBase0.BtCancelClick

//**************************************** TK_FormMVBase0.BtOKClick
//
procedure TK_FormMVBase0.BtOKClick(Sender: TObject);
begin
  DataSaveModalState := mrYes;
  CLose;
end; //*** procedure TK_FormMVBase0.BtOKClick

//**************************************** TK_FormMVBase0.AddChangeDataFlag
//
procedure TK_FormMVBase0.AddChangeDataFlag;
begin
  DataWasChanged := true;
  BtOK.Caption := 'OK';
  BtCancel.Enabled := true;
  BtApply.Enabled := true;
end; //*** procedure TK_FormMVBase0.AddChangeDataFlag

//**************************************** TK_FormMVBase0.ClearChangeDataFlag
//
procedure TK_FormMVBase0.ClearChangeDataFlag;
begin
  DataSaveModalState := mrNone;
  DataWasChanged := false;
  BtOK.Caption := 'Выход';
  BtCancel.Enabled := false;
  BtApply.Enabled := false;
end; //*** procedure TK_FormMVBase0.ClearChangeDataFlag

//**************************************** TK_FormMVBase0.AfterSaveData
//
procedure TK_FormMVBase0.AfterSaveData;
begin
  if PDGEditCont <> nil then
    with TK_PRAEditFuncCont(PDGEditCont)^ do begin
      if Assigned(FOnGlobalAction) then FOnGlobalAction( Self, ActionCode );
      if FRLSData.RUDRArray <> nil then
        K_SetChangeSubTreeFlags( FRLSData.RUDRArray );
    end;
  ResultDataWasChanged := true;
  ClearChangeDataFlag;
end; //*** procedure TK_FormMVBase0.SaveData

//**************************************** TK_FormMVBase0.SaveDataIfNeeded
//
function TK_FormMVBase0.SaveDataIfNeeded: Word;
var
  res : Word;
begin
  res := DataSaveModalState;
  if  IfDataWasChanged then begin
    if DataSaveModalState = mrNone then
      res := MessageDlg( 'Данные были изменены - запомнить?',
                         mtConfirmation, [mbYes, mbNo, mbCancel], 0 );
    if (res = mrYes) then  SaveData;
  end;
  Result := res;
end; //*** procedure TK_FormMVBase0.SaveDataIfNeeded

//**************************************** TK_FormMVBase0.IfDataWasChanged
function TK_FormMVBase0.IfDataWasChanged: Boolean;
begin
  Result := DataWasChanged;
end; //*** end of TK_FormMVBase0.IfDataWasChanged

//**************************************** TK_FormMVBase0.SaveData;
procedure TK_FormMVBase0.SaveData;
begin
  AfterSaveData();
end; //*** end of TK_FormMVBase0.SaveData;

end.
