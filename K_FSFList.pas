unit K_FSFList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ExtCtrls, 
  N_BaseF, N_Types,
  K_FrRaEdit;

type
  TK_FormSelectFromList = class(TN_BaseForm)
    CheckListBox: TCheckListBox;
    SelectListBox: TListBox;
    BtCancel: TButton;
    BtOK: TButton;
    procedure SelectListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CurListBox : TCustomListBox;
    procedure SetItemsList(  AStrings : TStrings; AUseItemsCheck : Boolean = FALSE );
    function  SelectElements( var ACheckedIndexes : TN_IArray ) : Boolean;
    function  SelectElement( var ASelectedInd : Integer ) : Boolean;
  end;

function K_GetFormSelectFromList( AOwner: TN_BaseForm = nil; ASelfName : string = '' ) : TK_FormSelectFromList;
function K_SelectRAFrameFieldsList( RAFrame : TK_FrameRAEdit; FL : TStrings;
                                    ACaption : string = '';
                                    AOwner: TN_BaseForm = nil ) : Boolean;

implementation

{$R *.dfm}

function K_GetFormSelectFromList( AOwner: TN_BaseForm = nil; ASelfName : string = '' ) : TK_FormSelectFromList;
begin
  Result := TK_FormSelectFromList.Create(Application);
//  Result.BaseFormInit( AOwner );
  Result.BaseFormInit( AOwner, ASelfName, [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
end;

function K_SelectRAFrameFieldsList( RAFrame : TK_FrameRAEdit; FL : TStrings;
                                    ACaption : string = '';
                                    AOwner: TN_BaseForm = nil ) : Boolean;
var
  CheckedIndexes : TN_IArray;
  i : Integer;
begin
  with K_GetFormSelectFromList( AOwner, 'SelectRAFrameFields' ) do
  begin
    if ACaption <> '' then
      Caption := ACaption
    else
      Caption := TForm(RAFrame.Owner).Caption;

    RAFrame.GetFieldsList( CheckListBox.Items );
//*** build CheckedIndexes from FieldsList
    SetLength( CheckedIndexes, FL.Count );
    for i := 0 to High(CheckedIndexes) do
      CheckedIndexes[i] := RAFrame.IndexOfColumn( FL[i] );
    Result := SelectElements( CheckedIndexes );
    if not Result then Exit;
    RAFrame.GetFieldsList( FL, false, CheckedIndexes );
  end;

end;

{*** TK_FormSelectFromList ***}

function TK_FormSelectFromList.SelectElements( var ACheckedIndexes: TN_IArray): Boolean;
var
  i, Ind : Integer;
begin

  Result := false;
  if CurListBox = nil then Exit;
  if CurListBox = CheckListBox then
    for i := 0 to High(ACheckedIndexes) do
    begin
      Ind := ACheckedIndexes[i];
      if (Ind < 0) or (Ind >= CheckListBox.Items.Count) then continue;
      CheckListBox.Checked[Ind] := true;
    end
  else
    for i := 0 to High(ACheckedIndexes) do
    begin
      Ind := ACheckedIndexes[i];
      if (Ind < 0) or (Ind >= SelectListBox.Items.Count) then continue;
      SelectListBox.Selected[Ind] := true;
    end;

  CurListBox.MultiSelect := TRUE;
  ShowModal;
  if ModalResult = mrOK then
  begin
    SetLength(ACheckedIndexes, CurListBox.Items.Count);
    Ind := 0;
    for i := 0 to High(ACheckedIndexes) do
    begin
      if CurListBox = CheckListBox then
      begin
        if CheckListBox.Checked[i] = false then continue;
      end
      else
      begin
        if SelectListBox.Selected[i] = false then continue;
      end;
      ACheckedIndexes[Ind] := i;
      Inc(Ind);
    end;
    SetLength(ACheckedIndexes, Ind);
    Result := true;
  end;
end;

function TK_FormSelectFromList.SelectElement( var ASelectedInd : Integer ) : Boolean;
begin
  Result := false;
  if CurListBox = nil then Exit;
  CurListBox.MultiSelect := FALSE;
  CurListBox.ItemIndex := ASelectedInd;
  ShowModal;
  if ModalResult = mrOK then
  begin
    ASelectedInd := CurListBox.ItemIndex;
    Result := true;
  end;
end;

procedure TK_FormSelectFromList.SetItemsList( AStrings: TStrings; AUseItemsCheck : Boolean = FALSE );
begin
  SelectListBox.Visible := not AUseItemsCheck;
  CheckListBox.Visible := AUseItemsCheck;
  if AUseItemsCheck then
    CurListBox := CheckListBox
  else
    CurListBox := SelectListBox;

  if AStrings = nil then Exit;

  CurListBox.Items.Clear;
  CurListBox.Items.Assign( AStrings );
end;

{*** end of TK_FormSelectFromList ***}

procedure TK_FormSelectFromList.SelectListBoxDblClick(Sender: TObject);
begin
  if CurListBox.ItemIndex < 0 then Exit;
  ModalResult := mrOK;
end;

end.

