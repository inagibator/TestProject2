unit N_EdRecF;
// Edit Record by TK_RAFrame Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_Script1, K_FrRaEdit,
  N_Types, N_Lib1, N_BaseF;

type TN_EditRecordForm = class( TN_BaseForm )
    RAFrame: TK_FrameRAEdit;
    Panel1: TPanel;
    bnOK: TButton;
    bnCancel: TButton;

    procedure bnOKClick ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    FRRAControl:    TK_FRAData;
    DataWasChanged: boolean;
    FormDescr: TK_UDRArray; // if it was created in InitFormDescr

    procedure SetDataChangedFlag   ();
    procedure ClearDataChangedFlag ();
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_EditRecordForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_CreateEditRecordForm ( AOwner: TN_BaseForm ): TN_EditRecordForm; overload;
function  N_CreateEditRecordForm ( var AData; ATypeName, AFormDescrName: string;
                                       AOwner: TN_BaseForm ): TN_EditRecordForm; overload;


implementation
uses N_Lib2;
{$R *.dfm}

//****************  TN_EditRecordForm class handlers  ******************

procedure TN_EditRecordForm.bnOKClick( Sender: TObject );
// Save Changes
begin
  FRRAControl.StoreToSData; // Change source record
end; // procedure TN_EditRecordForm.bnOKClick

procedure TN_EditRecordForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
  FormDescr.Free;
end; // procedure TN_EditRecordForm.FormClose


//****************  TN_EditRecordForm class public methods  ************

procedure TN_EditRecordForm.SetDataChangedFlag();
// update Self Controls after Data was changed
begin
  DataWasChanged := true;
end; // procedure TN_EditRecordForm.SetDataChangedFlag

procedure TN_EditRecordForm.ClearDataChangedFlag();
// set Self Controls as if Data was not changed yet
begin
  DataWasChanged := false;
end; // procedure TN_EditRecordForm.ClearDataChangedFlag

//***************************************** TN_EditRecordForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_EditRecordForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_EditRecordForm.CurStateToMemIni

//***************************************** TN_EditRecordForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_EditRecordForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_EditRecordForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//*********************************************** N_CreateEditRecordForm(1) ***
// Create and return new instance of TN_EditRecordForm
// AOwner - Owner of created Form
//
function N_CreateEditRecordForm( AOwner: TN_BaseForm ): TN_EditRecordForm;
begin
  Result := TN_EditRecordForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    CurArchiveChanged();

    FRRAControl := TK_FRAData.Create( RAFrame );
    with FRRAControl do
    begin
      SetOnDataChange( SetDataChangedFlag ); // set OnDataChange event handler
      SetOnClearDataChange( ClearDataChangedFlag ); // set OnClearDataChange event handler
    end;

    ClearDataChangedFlag();
  end;
end; // function N_CreateEditRecordForm(1)

//*********************************************** N_CreateEditRecordForm(4) ***
// Create and return new instance of TN_EditRecordForm, prepared for
// editing given AData
// AOwner - Owner of created Form
//
function N_CreateEditRecordForm( var AData; ATypeName, AFormDescrName: string;
                                       AOwner: TN_BaseForm ): TN_EditRecordForm;
var
  RAModeFlags: TK_RAModeFlagSet;
  RecordTypeCode : TK_ExprExtType;
begin
  Result := TN_EditRecordForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    CurArchiveChanged();

    FRRAControl := TK_FRAData.Create( RAFrame );
    with FRRAControl do
    begin
      SetOnDataChange( SetDataChangedFlag ); // set OnDataChange event handler
      SetOnClearDataChange( ClearDataChangedFlag ); // set OnClearDataChange event handler
    end;

    ClearDataChangedFlag();
    RecordTypeCode := N_GetSPLTypeCode( [], ATypeName );
    RAModeFlags := [K_ramFillFrameWidth, K_ramSkipResizeWidth];

    if AFormDescrName <> '' then
      FormDescr := K_CreateSPLClassByName( AFormDescrName, [] )
    else
      FormDescr := nil;
      
    FRRAControl.PrepFrameByFormDescr( [], RAModeFlags, AData,
                                               RecordTypeCode, '', FormDescr );
  end; // with Result do
end; // function N_CreateEditRecordForm(4)

end.
