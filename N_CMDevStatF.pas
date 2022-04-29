unit N_CMDevStatF;
// Form for Viewing and Editing CMS Capturing Statistics Table

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, ActnList, ExtCtrls,
  K_FrRaEdit, K_Script1,
  N_BaseF;

type TN_CMDevStatForm = class( TN_BaseForm ) // View/Edit CMS Capturing Statistics Table
    RAEdFrame: TK_FrameRAEdit;
    ActionList: TActionList;
    aCancel: TAction;
    aOK: TAction;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    Button1: TButton;
    Button2: TButton;

    procedure FormCreate ( Sender: TObject );
    procedure FormShow   ( Sender: TObject );
    procedure FormClose  ( Sender: TObject; var Action: TCloseAction ); override;

    //******* OK and Cancel Actions
    procedure aCancelExecute ( Sender: TObject );
    procedure aOKExecute     ( Sender: TObject );
  private
    procedure ClearChangeDataFlag ();
    procedure AfterDataChange     ();
  public
    FRAControl   : TK_FRAData;       // Object to control RAEdFrame Settings
    UDTable      : TK_UDRArray;      // Statistics UDTable
    IncModeFlags : TK_RAModeFlagSet; // Frame Flags Removed from FormDescription Flags
    ExcModeFlags : TK_RAModeFlagSet; // Frame Flags Added to FormDescription Flags
    FDTypeName   : string;           // FormDescription Type Name
end; // type TN_CMDevStatForm = class( TN_BaseForm )

implementation

uses
  K_CLib, K_UDT1,
  N_ButtonsF;

{$R *.dfm}

//********************* TN_CMDevStatForm Form Handlers

//********************************************* TN_CMDevStatForm.FormCreate ***
//
procedure TN_CMDevStatForm.FormCreate( Sender: TObject );
begin
  inherited;

  FRAControl := TK_FRAData.Create( RAEdFrame );
  FRAControl.SkipDataBuf := false;
  FRAControl.SkipClearEmptyRArrays := True;
  FRAControl.SetOnDataChange( AfterDataChange );
  FRAControl.SetOnClearDataChange( ClearChangeDataFlag );
  IncModeFlags := [K_ramSkipResizeWidth,K_ramFillFrameWidth,K_ramShowLRowNumbers,K_ramRowChangeOrder,K_ramRowChangeNum];

  K_SetFFCompCurLangTexts(Self);
end; // TN_CMDevStatForm.FormCreate

//*********************************************** TN_CMDevStatForm.FormShow ***
//
procedure TN_CMDevStatForm.FormShow( Sender: TObject );
begin
  ClearChangeDataFlag;
  if UDTable <> nil then
    with UDTable do
      FRAControl.PrepFrameByFDTypeName( ExcModeFlags, IncModeFlags,
                                        R, R.ArrayType, '', FDTypeName );
end; // TN_CMDevStatForm.FormShow

//********************************************** TN_CMDevStatForm.FormClose ***
//
procedure TN_CMDevStatForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  FreeAndNil( FRAControl );
  inherited;
end; // procedure TN_CMDevStatForm.FormClose

    //******* OK and Cancel Actions

//********************************************* TN_CMDevStatForm.aOKExecute ***
//
procedure TN_CMDevStatForm.aOKExecute( Sender: TObject );
begin
  FRAControl.StoreToSData;
  K_SetChangeSubTreeFlags( UDTable );
  if not (fsModal in FormState)	then Close();
  ModalResult := mrOK;
end; // TN_CMDevStatForm.aOKExecute

//***************************************** TN_CMDevStatForm.aCancelExecute ***
//
procedure TN_CMDevStatForm.aCancelExecute( Sender: TObject );
begin
  if not (fsModal in FormState)	then Close();
  ModalResult := mrCancel;
end; // TN_CMDevStatForm.aCancelExecute

//************* Private methods

//************************************ TN_CMDevStatForm.ClearChangeDataFlag ***
//
procedure TN_CMDevStatForm.ClearChangeDataFlag();
begin
  aOK.Enabled := false;
end; // TN_CMDevStatForm.ClearChangeDataFlag

//**************************************** TN_CMDevStatForm.AfterDataChange ***
//
procedure TN_CMDevStatForm.AfterDataChange();
begin
  aOK.Enabled := true;
end; // TN_CMDevStatForm.AfterDataChange


end.
