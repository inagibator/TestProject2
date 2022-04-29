unit K_FSFCombo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_Script1, K_UDT1,
  N_Types, N_BaseF;

type
  TK_FormSelectFromCombo = class(TN_BaseForm)
    CmBList: TComboBox;
    procedure CmBListSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    WaitForSelect : Boolean;
    function GetSList : TStrings;
  end;

function K_GetFormSelectFromCombo( AOwner: TN_BaseForm ) : TK_FormSelectFromCombo;
function K_SelectFromCombo( FSForm : TK_FormSelectFromCombo; var StartInd : Integer;
                                        ACaption : string = '' ) : Boolean;
function K_SelectFromTStrings( SL : TStrings; var Ind : Integer;
                                        ACaption : string = '' ) : Boolean;
function K_SelectFromUDDir( UDRoot : TN_UDBase; var UDCur : TN_UDBase;
                                        ACaption : string = '' ) : Boolean;
function K_SelectFromDCSpase( UDCSpace : TK_UDRArray; var AInd : Integer;
                                        ACaption : string = '' ) : Boolean;
function K_SelectFromDCSSpase( UDCSSpace : TK_UDRArray; var AInd : Integer;
                                        ACaption : string = '' ) : Boolean;
function K_SelectRecordTypeCode( var TypeCode : Integer;
                                        ACaption : string = '' ) : Boolean;
function K_SelectDBlockElemTypeCode( var TypeCode : Integer;
                                       ACaption : string = '';
                                       UseERDBlock : Boolean = false ) : Boolean;
function K_SelectIniFileSectionItem( SectionName : string; var ItemName : string;
                                        ACaption : string = '' ) : Boolean;

implementation

uses
  Math,
  K_CSpace, K_IFunc, K_DCSPace, K_FrRAEdit;

{$R *.dfm}

procedure TK_FormSelectFromCombo.CmBListSelect(Sender: TObject);
begin
  if WaitForSelect then ModalResult := mrOK;
end;

procedure TK_FormSelectFromCombo.FormShow(Sender: TObject);
begin
  CmBlist.DroppedDown := true;
end;

function TK_FormSelectFromCombo.GetSList: TStrings;
begin
  Result := CmBlist.Items;
end;


function K_GetFormSelectFromCombo( AOwner: TN_BaseForm ) : TK_FormSelectFromCombo;
begin
  Result := TK_FormSelectFromCombo.Create(Application);
  Result.BaseFormInit( AOwner );
end;

function K_SelectFromCombo( FSForm : TK_FormSelectFromCombo; var StartInd : Integer;
                                        ACaption : string = '' ) : Boolean;
begin
  Result := false;
  with FSForm do begin
    if ACaption <> '' then Caption := ACaption;
    with CmBlist do begin
      DropDownCount := Min(Items.Count, 32);
      ItemIndex := StartInd;
      WaitForSelect := true;
      ShowModal;
      if (ModalResult = mrOK) and (ItemIndex <> StartInd)then begin
        StartInd := ItemIndex;
        Result := true;
      end;
    end;
  end;
end;

function K_SelectFromTStrings( SL : TStrings; var Ind : Integer;
                                        ACaption : string = '' ) : Boolean;
var
 FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    GetSList.Assign( SL );
  end;
  Result := K_SelectFromCombo( FSForm, Ind, ACaption );
end;

function K_SelectFromUDDir( UDRoot : TN_UDBase; var UDCur : TN_UDBase;
                                        ACaption : string = '' ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
var
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    UDRoot.BuildChildsList(SList);
    with SList do begin
      Ind := IndexOfObject(UDCur);
      if Ind = -1 then
        Ind := UDRoot.DirHigh;
      Result := K_SelectFromCombo( FSForm, Ind, ACaption );
      if Result then
        UDCur := TN_UDBase( Objects[Ind] );
    end;
  end;
end;

function K_SelectRecordTypeCode( var TypeCode : Integer;
                                        ACaption : string = '' ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    K_BuildValidRecTypesList(SList);
    with SList do begin
      if TypeCode > Ord(nptNoData) then
        Ind := IndexOfObject( TObject(TypeCode) )
      else
        Ind := TypeCode;
      Result := K_SelectFromCombo( FSForm, Ind, ACaption );
      if Result then begin
//        if Ind > Ord(nptNoData) then
          TypeCode := Integer( Objects[Ind] )
//        else
//          TypeCode := Ind;
      end
    end;
  end;
end;

function K_SelectDBlockElemTypeCode( var TypeCode : Integer;
                                       ACaption : string = '';
                                       UseERDBlock : Boolean = false ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    K_BuildDBlockTypesList( SList, UseERDBlock );
    with SList do begin
      if TypeCode > Ord(nptNoData) then
        Ind := IndexOfObject( TObject(TypeCode) )
      else
        Ind := -1;
      Result := K_SelectFromCombo( FSForm, Ind, ACaption );
      if Result then
        TypeCode := Integer( Objects[Ind] );
      Result := (Ind <> -1);
    end;
  end;
end;

function K_SelectFromDCSpase( UDCSpace : TK_UDRArray; var AInd : Integer;
                                        ACaption : string = '' ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    K_SetStringsFromRArray( SList, 0, TK_PDCSpace( UDCSpace.R.P ).Names, 0 );
    with SList do begin
      if (AInd >= 0) or (AInd < Count) then Ind := AInd;
      Result := K_SelectFromCombo( FSForm, Ind, ACaption );
      if Result then AInd := Ind;
    end;
  end;
end;

function K_SelectFromDCSSpase( UDCSSpace : TK_UDRArray; var AInd : Integer;
                                        ACaption : string = '' ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    K_SetStringsFromRArray( SList, 0,
        TK_PDCSpace( TK_UDRArray(UDCSSpace.Owner.Owner).R.P ).Names,
        0, -1, UDCSSpace.R );
    if (AInd >= 0) or (AInd < SList.Count) then Ind := AInd;
    Result := K_SelectFromCombo( FSForm, Ind, ACaption );
    if Result then AInd := Ind;
  end;
end;

function K_SelectIniFileSectionItem( SectionName : string; var ItemName : string;
                                        ACaption : string = '' ) : Boolean;
var
  Ind : Integer;
  SList : TStrings;
  FSForm : TK_FormSelectFromCombo;
begin
  FSForm := K_GetFormSelectFromCombo(nil);
  with FSForm do begin
    SList := GetSList;
    N_CurMemIni.ReadSection( SectionName, SList );
    Ind := -1;
    Result := K_SelectFromCombo( FSForm, Ind, ACaption );
    if Result then ItemName := SList.Strings[Ind];
  end;
end;

end.
