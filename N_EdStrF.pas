unit N_EdStrF;
// Form for Editing any String and CObj Reg and Item Codes as Strings

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_UDat4;

type TN_StrEditForm = class( TForm )
    bnOk: TButton;
    bnCancel: TButton;
    edStr1: TLabeledEdit;
    edStr2: TLabeledEdit;
    mb1: TComboBox;
    label1: TLabel;
    procedure edkeyDown  ( Sender: TObject; var Key: Word;
                                                     Shift: TShiftState );
    procedure mb1CloseUp ( Sender: TObject );
  public
    mb1AutoClose: boolean; // True if Form should be closed in mb1CloseUp

    procedure AdjustFormSizePos ( ALeft, ATop: integer; AFormWidth: integer = -1 );
end; // type TN_StrEditForm = class( TForm )

    //*********** Global Procedures  *****************************

function N_EditString ( var InpOutStr: string; FormCaption: string;
                    FormWidth: integer = -1; AEditLabel: string = '' ): boolean; overload;
function N_EditString (  var InpOutStr: string; AStrings: array of string;
              ALabel, AFormCaption: string; AFormWidth: integer = -1 ): boolean; overload;

function N_EditItemsCodes ( CL: TN_UCObjLayer; ItemInd, NumItems: integer;
                                                 FormCaption: string ): boolean;
//function N_EditRegionCodes ( CL: TN_ULines; BegItemInd, NumItems: integer;
//                                                 FormCaption: string ): boolean;

function N_EditTwoStrings ( var InpOutStr1, InpOutStr2: string;
    Caption1, Caption2, FormCaption: string; FormWidth: integer = -1 ): boolean;

function N_GetEnumIndex ( AStrings: array of string; AInpInd: integer;
                                    ALabel, AFormCaption: string ): integer;
function N_ShowNotModalWarning ( AWarningText: string; AFormCaption: string;
                                 AFormWidth: integer = -1 ): TN_StrEditForm; overload;

implementation
uses
  N_Lib1, N_Lib2, N_ClassRef, N_MsgDialF;
{$R *.dfm}

//************************ TN_StrEditForm Handlers *******************

procedure TN_StrEditForm.edkeyDown( Sender: TObject; var Key: Word;
                                                         Shift: TShiftState );
// Close form with ModalResult mrOK or mrCancel
//( OnKeyDown handler for all TEdit conrols)
begin
  if Key = VK_RETURN then // Enter pressed, finish editing with mrOK result
    ModalResult := mrOK;

  if Key = VK_ESCAPE then // Escape pressed, cancel editing
    ModalResult := mrCancel;
end; // procedure TN_StrEditForm.edkeyDown

procedure TN_StrEditForm.mb1CloseUp( Sender: TObject );
// Close form with ModalResult mrOK
begin
  if mb1AutoClose then
    ModalResult := mrOK;
end; // procedure TN_StrEditForm.mb1CloseUp


//************************ TN_StrEditForm Methods *******************

//**************************************** TN_StrEditForm.AdjustFormSizePos ***
// Adjust Form Size and Position
//
procedure TN_StrEditForm.AdjustFormSizePos( ALeft, ATop: integer;
                                                   AFormWidth: integer = -1 );
var
  NeededHeight: integer;
begin
  if AFormWidth <> -1 then Width := AFormWidth;

  Left := ALeft;
  Top  := ATop;

  if Left+Width >= N_AppWAR.Right then
    Left := N_AppWAR.Right - Width - 1;

  NeededHeight := 75 + mb1.Items.Count*13;

  if (Top+NeededHeight) >= N_AppWAR.Bottom then
    Top := N_AppWAR.Bottom - NeededHeight - 1;

  ActiveControl := nil;
end; // procedure TN_StrEditForm.AdjustFormSizePos


    //*********** Global Procedures  *****************************

//**************************************************** N_EditString(simple) ***
// Edit given string in TN_StrEditForm
// return True if String was edited or False if editing was cancelled
//
function N_EditString( var InpOutStr: string; FormCaption: string;
                       FormWidth: integer = -1;
                       AEditLabel: string = '' ): boolean; overload;
var
  StrEditForm: TN_StrEditForm;
  MrResult: TModalResult;
begin
  Result := False;
  StrEditForm := TN_StrEditForm.Create( Application );
  with StrEditForm do
  begin
    if FormWidth <> -1 then Width := FormWidth;
    Caption := FormCaption;

    edStr1.Visible := True;
    edStr1.Left := 10;
    edStr1.EditLabel.Caption := '';
    edStr1.Text := InpOutStr;

    label1.Caption := AEditLabel;

    Left := Mouse.CursorPos.X - (Width div 2);
    Top  := Mouse.CursorPos.Y - (Height div 2);

    if Top+Height >= N_AppWAR.Bottom then
      Top := N_AppWAR.Bottom - Height - 1;

    if Left+Width >= N_AppWAR.Right then
      Left := N_AppWAR.Right - Width - 1;

    ActiveControl := nil;
    MrResult := ShowModal();
    if MrResult = mrOK then
    begin
     InpOutStr := edStr1.Text;
     Result := True;
    end;
    Release; // Release StrEditForm
  end; // with StrEditForm do
end; // function N_EditString(simple)

//************************************************** N_EditString(withList) ***
// Edit given InpOutStr, using ComboBox with predefined list
// return False if canceled
//
function N_EditString(  var InpOutStr: string; AStrings: array of string;
              ALabel, AFormCaption: string; AFormWidth: integer = -1 ): boolean;
var
  StrEditForm: TN_StrEditForm;
  MrResult: TModalResult;
begin
  Result := False;
  StrEditForm := TN_StrEditForm.Create( Application );
  with StrEditForm do
  begin
    mb1.Visible := True;
    mb1.DropDownCount := Length( AStrings );
    mb1.Style := csDropDown;
    N_i := mb1.Width;

    label1.Visible := True;
    label1.Caption := ALabel;
    Caption := AFormCaption;

    N_i := mb1.Width;
    N_SetMBItems( mb1, AStrings, 0, -1 );
    N_i := mb1.Width;
    mb1.Text := InpOutStr;
    N_i := mb1.Width;
    mb1AutoClose := False;
    N_i := mb1.Width;

    with Mouse.CursorPos do
      AdjustFormSizePos( X, Y+10, AFormWidth );

    MrResult := ShowModal();

    if MrResult = mrOK then
    begin
      InpOutStr := mb1.Text;
      Result := True;
    end;
    Release; // Release StrEditForm
  end; // with StrEditForm do
end; // function N_EditString(withList)

//************************************************* N_EditItemsCodes ***
// Edit Items All Codes
// ( set resuting Codes to all Items from ItemInd to ItemInd+NumItems-1 )
// return True if Code was edited or False if editing was cancelled
//
function N_EditItemsCodes( CL: TN_UCObjLayer; ItemInd, NumItems: integer;
                                                 FormCaption: string ): boolean;
var
  i, NumInts: Integer;
  Str: string;
  WrkInts: TN_IArray;
begin
  WrkInts := nil; // to avoid warning
  Str := CL.GetItemAllCodes( ItemInd );

  Result := N_EditString( Str, FormCaption, 200 );

  if Result then // Str was changed
  begin

    N_StringToCObjCodes( Str, WrkInts, NumInts );

    for i := ItemInd to ItemInd+NumItems-1 do
      CL.SetItemAllCodes( i, @WrkInts[0], NumInts );

  end; // if Result then // Str was changed
end; // function N_EditItemsCodes

{
//************************************************* N_EditRegionCodes ***
// Edit RegionCodes
// return True if RegionCodes were edited or False if editing was cancelled
//
function N_EditRegionCodes( CL: TN_ULines; BegItemInd, NumItems: integer;
                                                FormCaption: string ): boolean;
var
  NumCodesBytes: integer;
  Str: string;
  PFRegCode: PInteger;
  IArray: TN_IArray;
  WrkBCodes: TN_BArray;
begin
//  CL.GetRegCodes( BegItemInd, PFRegCode, NumCodes );
//  Str := N_ConvIntsToStr( PFRegCode, NumCodes, ' ' );

  Str :=

  Result := N_EditString( Str, FormCaption, 300 );

  if Result then // Str was changed
  begin
    if (CL.WFlags and N_RCXYBit) = 0 then // CL has no Region Codes
    begin
      if N_MessageDlg( 'Lines Layer "' + CL.ObjName + '" has no Region Codes. Add it ?',
                   mtConfirmation, mbOKCancel, 0 ) = mrCancel then Exit;
    end; // if (CL.WFlags and N_RCXYBit) = 0 then

    N_ScanIArray( Str, IArray );
    if Length(IArray) = 0 then
    begin
      CL.SetRegCodes( BegItemInd, NumItems, nil, 0 );
    end else
    begin
      N_SortElements( TN_BytesPtr(@IArray[0]), Length(IArray), Sizeof(integer),
                                                      0, N_CompareIntegers );
      CL.SetRegCodes( BegItemInd, NumItems, @IArray[0], Length(IArray) );
    end;
  end;
end; // function N_EditRegionCodes
}

//************************************************* N_EditTwoStrings ***
// Edit two given strings in TN_StrEditForm
// return True if Strings were edited or False if editing was cancelled
//
function N_EditTwoStrings( var InpOutStr1, InpOutStr2: string;
        Caption1, Caption2, FormCaption: string; FormWidth: integer ): boolean;
var
  StrEditForm: TN_StrEditForm;
  MrResult: TModalResult;
begin
  Result := False;
  StrEditForm := TN_StrEditForm.Create( Application );
  with StrEditForm do
  begin
    edStr1.Visible := True;
    edStr1.EditLabel.Caption := Caption1;
    edStr1.Text := InpOutStr1;

    edStr2.Visible := True;
    edStr2.EditLabel.Caption := Caption2;
    edStr2.Text := InpOutStr2;

    if FormWidth <> -1 then Width := FormWidth;
    Caption := FormCaption;

    Left := Mouse.CursorPos.X;
    Top := Mouse.CursorPos.Y + 10;

    if Top+Height >= N_AppWAR.Bottom then
      Top := N_AppWAR.Bottom - Height - 1;

    if Left+Width >= N_AppWAR.Right then
      Left := N_AppWAR.Right - Width - 1;

    MrResult := ShowModal();
    if MrResult = mrOK then
    begin
     InpOutStr1 := edStr1.Text;
     InpOutStr2 := edStr2.Text;
     Result := True;
    end;
    Release; // Release StrEditForm
  end; // with StrEditForm do
end; // function N_EditTwoStrings

//************************************************* N_GetEnumIndex ***
// Choose and return Index of Enum, given by AStrings
// return -1 if canceled
//
function N_GetEnumIndex( AStrings: array of string; AInpInd: integer; // TN_SArray
                                    ALabel, AFormCaption: string ): integer;
var
  StrEditForm: TN_StrEditForm;
  MrResult: TModalResult;
begin
  Result := -1;
  StrEditForm := TN_StrEditForm.Create( Application );
  with StrEditForm do
  begin
    mb1.Visible := True;
    mb1.DropDownCount := Length( AStrings );
    mb1.Style := csDropDownList;

    label1.Visible := True;
    label1.Caption := ALabel;
    Caption := AFormCaption;

    N_SetMBItems( mb1, AStrings, AInpInd, 0 );
    mb1AutoClose := True;
    MrResult := ShowModal();

    if MrResult = mrOK then
      Result := mb1.ItemIndex;

    Release; // Release StrEditForm
  end; // with StrEditForm do
end; // function N_GetEnumIndex

//*************************************************** N_ShowNotModalWarning ***
// Show Not Modal Warning
//
function N_ShowNotModalWarning( AWarningText: string; AFormCaption: string;
                                AFormWidth: integer = -1 ): TN_StrEditForm; overload;
begin
  Result := TN_StrEditForm.Create( Application );
  with Result do
  begin
    if AFormWidth <> -1 then Width := AFormWidth;
    Caption := AFormCaption;

    label1.Caption := AWarningText;

    Left := 300;
    Top  := 300;

    ActiveControl := nil;
    Show();
  end; // with Result do
end; // function N_ShowNotModalWarning


end.
