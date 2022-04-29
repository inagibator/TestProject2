unit N_VVEdBaseF;
// Base Form for different Values Visual Editors

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  K_FrRAEdit,
  N_Types, N_Lib1, N_BaseF, N_RaEditF;

type TN_VVESenderType = ( estNotGiven, estDecBig, estDecSmall, estIncSmall,
                 estIncBig, estValue, estNumDigits, estStep, estMultCoef );

type TN_VVEActionType = ( eatNotGiven, eatSetValue, eatSetValueByData,
                          eatUpdateValue );

type TN_VVEdBaseForm = class; // forvard reference

{type} TN_OneValueVEditor = class( TObject ) // One Value Visual Editor Object
    CurValue: double;      // Current Value
    Step: double;          // Abs value of Small Step (used in bnMouseDown)
    MultCoef: integer;     // Multiplication Coef - BigStep = MultCoef*SmallStep
    NumDigits:  integer;   // Number of digits after decimal point
    DataOffset: integer;   // Offset from PData for writing Value in Data Record

    ViewValueControl: TControl; // Control for showing CurValue
    VVEdForm: TN_VVEdBaseForm;  // Owner Form with
    SelfInd: integer;

    procedure SetDataByValue   ( APData: Pointer );
    procedure SetValueByData   ( APData: Pointer );
    procedure SetValue         ( ANewValue: double );
    procedure UpdateValue      ( AAddValue: double );
    function  CurStateToString (): string;
    procedure StringToCurState ( AStateStr: string );
end; // type TN_OneValueVEditor = class( TObject )
{type} TN_OVEditors = Array of TN_OneValueVEditor;

{type} TN_VVEdBaseForm = class( TN_BaseForm )
    bnOK: TButton;
    bnCancel: TButton;
    bnApply: TButton;
    bnUndo: TButton;
    ButtonsTimer: TTimer;
    cbApplyToAll: TCheckBox;
    cbApplyDelta: TCheckBox;

    procedure bnMouseDown ( Sender: TObject; Button: TMouseButton;
                                           Shift: TShiftState; X, Y: Integer );
    procedure bnMouseUp   ( Sender: TObject; Button: TMouseButton;
                                           Shift: TShiftState; X, Y: Integer );
    procedure OnButtonsTimer ( Sender: TObject );

    procedure mbKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure mbCloseUp ( Sender: TObject );

    procedure bnUndoClick   ( Sender: TObject );
    procedure bnApplyClick  ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure bnOKClick     ( Sender: TObject );

    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
    TimerState: integer; // 0 before first MouseDown, 1 while repeating
    RedoMode: boolean;   // used for Shift+Undo
  public
    PData: Pointer;             // Pointer to Data Record
    ValueType: TN_OneValueType; // Value Type for writing Value in Data Record
    OVEditors: TN_OVEditors;    // array of all Form VEditors
    VVEdGAProcOfObj: TK_RAFGlobalActionProc;  // External Global Action
    MemIniPrefix: string;       // used in CurStateToMemIni, MemIniToCurState
    IndividualSteps: boolean;   // True if each VEditor has individual Step
    LastVEdInd: integer;        // Index of Last changed VEditor
    LastStep:   double;         // Last Change value for LastVEdInd VEditor
    OnApplyAction: TK_RAFGlobalAction; // usually fgaApplyToAll
    UndoRects: TN_DRArray;      // Saved Data Records for Undo
    UndoFreeInd: integer;       // First free Index in UndoRects array
    UndoMaxInd:  integer;       // Max filled Index in UndoRects array
    PrevData:    TDRect;        // For "DeltaMode"
    RaEditF: TN_RAEditForm;     // used in VVEdGlobalAction method

    procedure AuxChangeValues   ( AVEdInd: integer ); virtual;
    function  GetRect           (): TDRect;
    procedure SetRect           ( const ADRect: TDRect );
    procedure DecodeSenderTag   ( Sender: TObject; out AVEdInd: integer;
                                            out ASenderType: TN_VVESenderType );
    procedure UpdateByStr       ( Sender: TObject; AStr: string );
    procedure SetValuesByData   ( APData: Pointer );
    procedure SetDataByValues   ( APData: Pointer );
    procedure InitVVEdForm1     ( APData: Pointer; ARAFrame: TK_FrameRAEdit;
                                                        AMemIniPrefix: string );
    procedure InitVVEdForm2     ( APData: Pointer; ANumVEditors: integer;
                                  AMemIniPrefix: string; AOwner: TN_BaseForm = nil );
    procedure VVEdGlobalAction  ( AnActionType : TK_RAFGlobalAction );
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_VVEdBaseForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

implementation
{$R *.dfm}
uses Math,
  K_Script1,
  N_Lib0, N_InfoF, N_ME1;

//****************  TN_OneValueVEditor class methods  ******************

procedure TN_OneValueVEditor.SetValue( ANewValue: double );
// Round given ANewValue and Set CurValue and
// ViewValueControl.Text by Rounded ANewValue
// Source DataRecord is not changed and no Extrenal Procedures are called!
var
  Coef, TmpValue: double;
  Str: string;
begin
  Coef := IntPower( 10.0, NumDigits );
  TmpValue := ANewValue*Coef;
  TmpValue := Floor( TmpValue + 0.5 ); // round
  CurValue := TmpValue / Coef;

  Str := Format( '%.*f', [NumDigits, CurValue] );
  if ViewValueControl is TComboBox then TComboBox(ViewValueControl).Text := Str;
  if ViewValueControl is TEdit then TEdit(ViewValueControl).Text := Str;
end; // procedure TN_OneValueVEditor.SetValue

procedure TN_OneValueVEditor.SetDataByValue( APData: Pointer );
// Set Data (given by Pointer to Data) by CurValue
var
  PTmp: TN_BytesPtr;
begin
  PTmp := TN_BytesPtr(APData) + DataOffset;

  case VVEdForm.ValueType of // write CurValue into Data Record
    ovtInteger: PInteger(PTmp)^ := Round( CurValue );
    ovtFloat:   PFloat(PTmp)^   := CurValue;
    ovtDouble:  PDouble(PTmp)^  := CurValue;
  end; // case ValueType of

end; // procedure TN_OneValueVEditor.SetDataByValue

procedure TN_OneValueVEditor.SetValueByData( APData: Pointer );
// Set New CurValue by given Pointer to Data Record
var
  NewValue: double;
  PTmp: TN_BytesPtr;
begin
  NewValue := 0; // to avoid warning
  PTmp := TN_BytesPtr(APData) + DataOffset;

  case VVEdForm.ValueType of
    ovtInteger: NewValue := PInteger(PTmp)^;
    ovtFloat:   NewValue := PFloat(PTmp)^;
    ovtDouble:  NewValue := PDouble(PTmp)^;
    else
      Assert( False, 'Bad ValueType!' );
  end; // case ValueType of

  SetValue( NewValue );
end; // procedure TN_OneValueVEditor.SetValueByData

procedure TN_OneValueVEditor.UpdateValue( AAddValue: double );
// Update CurValue by given AAddValue, write to source data,
// call needed Extrenal Procedures
begin
  VVEdForm.LastStep := AAddValue; // is needed for Shift Rect Mode in VRectEdForm
  VVEdForm.LastVEdInd := SelfInd;

  SetValue( CurValue + AAddValue );

  VVEdForm.AuxChangeValues( SelfInd ); // VVEdGlobalAction will be called from AuxChangeValues
end; // procedure TN_OneValueVEditor.UpdateValue

function TN_OneValueVEditor.CurStateToString(): String;
// return current State as String
begin
// not implemented yet, may be not needed
end; // function TN_OneValueVEditor.CurStateToString

procedure  TN_OneValueVEditor.StringToCurState( AStateStr: string );
// restore Self State from given AStateStr
begin
// not implemented yet, may be not needed
end; // procedure  TN_OneValueVEditor.StringToCurState


//****************  TN_VVEdBaseForm class handlers  ******************

procedure TN_VVEdBaseForm.bnMouseDown( Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
var
  SenderType: TN_VVESenderType;
begin
  TimerState := 0;
  ButtonsTimer.Interval := 250; // wait time before first event
  ButtonsTimer.Enabled := True;
  DecodeSenderTag( Sender, LastVEdInd, SenderType );

  with OVEditors[LastVEdInd] do
  begin
    case SenderType of
      estDecBig:   LastStep := -Step*MultCoef;
      estDecSmall: LastStep := -Step;
      estIncSmall: LastStep := Step;
      estIncBig:   LastStep := Step*MultCoef;
      else
        Assert( False, 'Bad Tag!' );
    end; // case SenderType of

    UpdateValue( LastStep );
  end; // with OVEditors[Ind] do

end; // procedure TN_VVEdBaseForm.bnMouseDown

procedure TN_VVEdBaseForm.bnMouseUp( Sender: TObject;
                     Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  TimerState := 2;
  ButtonsTimer.Enabled := False;
end; // procedure TN_VVEdBaseForm.bnMouseUp

procedure TN_VVEdBaseForm.OnButtonsTimer( Sender: TObject );
// AutoRepeat last Value Update (LastStep for LastVEdInd)
// (Timer event handler)
begin
  if TimerState = 0 then
  begin
    ButtonsTimer.Interval := 35; // repeat time
    TimerState := 1;
  end;
  ButtonsTimer.Enabled := false;
  if TimerState = 2 then Exit;
  with OVEditors[LastVEdInd] do
    UpdateValue( LastStep );
  if TimerState = 2 then Exit;
  ButtonsTimer.Enabled := true;
end; // procedure TN_VVEdBaseForm.OnButtonsTimer

procedure TN_VVEdBaseForm.mbKeyDown( Sender: TObject;
                                          var Key: Word; Shift: TShiftState );
// Set new MultCoef, Step or NumDigits if Enter pressed
// (OnKeyDown event handler for all ComboBoxes)
var
  Str: string;
begin
  if Key = VK_RETURN then
  begin
    if Sender is TComboBox then Str := TComboBox(Sender).Text;
    if Sender is TEdit then Str := TEdit(Sender).Text;

    UpdateByStr( Sender, Str );

    if Sender is TComboBox then N_MBKeyDownHandler1( Sender, Key, Shift );
  end; // if Key = VK_RETURN then
end; // procedure TN_VVEdBaseForm.mbValMultCoefKeyDown

procedure TN_VVEdBaseForm.mbCloseUp( Sender: TObject );
// Set new MultCoef, Step or NumDigits
// (OnCloseUp event handler for all ComboBoxes)
var
  Str: string;
begin
  with TComboBox(Sender) do
    Str := Items[ItemIndex];

  UpdateByStr( Sender, Str );
end; // procedure TN_VVEdBaseForm.mbCloseUp

procedure TN_VVEdBaseForm.bnUndoClick( Sender: TObject );
// Undo or Redo Changing Values
begin
  if N_KeyIsDown( VK_SHIFT ) then // Redo Changing Values
  begin
    if UndoFreeInd <= UndoMaxInd then // Values for Redo exists
    begin
      RedoMode := True; // to prevent saving Color in Apply+Shift
      SetRect( UndoRects[UndoFreeInd] );
      RedoMode := False;
      Inc( UndoFreeInd );
    end;
  end else if N_KeyIsDown( VK_CONTROL ) then // Undo All - Restore initial Color
  begin
    SetRect( UndoRects[0] );
    UndoFreeInd := 1;
  end else //*************** Undo Changing Color (restore last saved Color)
  begin
    SetRect( UndoRects[UndoFreeInd-1] );

    if UndoFreeInd = 1 then Exit;
    Dec( UndoFreeInd );
  end;
end; // procedure TN_VVEdBaseForm.bnUndoClick

procedure TN_VVEdBaseForm.bnApplyClick( Sender: TObject );
// Change Value by external Procedure of Object
begin
  VVEdGlobalAction( K_fgaApplyToAll );
  if N_KeyIsDown( VK_SHIFT ) and not RedoMode then
  begin
    if Length(UndoRects) < (UndoFreeInd+1) then
      SetLength( UndoRects, UndoFreeInd+10 );
    UndoRects[UndoFreeInd] := GetRect();
    UndoMaxInd := UndoFreeInd;
    Inc( UndoFreeInd );
  end;
end; // procedure TN_VVEdBaseForm.bnApplyClick

procedure TN_VVEdBaseForm.bnCancelClick( Sender: TObject );
// Cancel changing Value
begin
  Close(); // Close should be executed before VVEdGlobalAction !
  if N_KeyIsDown( VK_SHIFT ) then
    VVEdGlobalAction( K_fgaCancelToAll );
end; // procedure TN_VVEdBaseForm.bnCancelClick

procedure TN_VVEdBaseForm.bnOKClick( Sender: TObject );
// Apply (Change Value) and Close Form
begin
  bnApplyClick( Sender );
  Close();  // Close should be executed before VVEdGlobalAction !
  if N_KeyIsDown( VK_SHIFT ) then
    VVEdGlobalAction( K_fgaOKToAll );
end; // procedure TN_VVEdBaseForm.bnOKClick

procedure TN_VVEdBaseForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_VVEdBaseForm.FormClose

//****************  TN_VVEdBaseForm class public methods  ************

//***********************************  TN_VVEdBaseForm.AuxChangeValues  ******
// in Base Form just call External VVEdGlobalAction,
// can be overloaded in Ancestor Forms to perform additional functionality and
// to prevent not needed calling to External VVEdGlobalAction
//
procedure TN_VVEdBaseForm.AuxChangeValues( AVEdInd: integer );
begin
  OVEditors[AVEdInd].SetDataByValue( PData );
  VVEdGlobalAction( OnApplyAction );
end; // end of procedure TN_VVEdBaseForm.AuxChangeValues

//***********************************  TN_VVEdBaseForm.GetRect  ******
// Get all CurValue fields of all OVEditors as double Rect
//
function TN_VVEdBaseForm.GetRect(): TDRect;
var
  i: integer;
  TmpDRect: TDRect;
begin
  for i := 0 to High(OVEditors) do
    with OVEditors[i] do
      move( CurValue, (TN_BytesPtr(@TmpDRect)+i*Sizeof(double))^, Sizeof(double) );

  Result := TmpDRect;
end; // end of function TN_VVEdBaseForm.GetRect

//***********************************  TN_VVEdBaseForm.SetRect  ******
// Set all CurValue fields of all OVEditors by given double Rect
// update DataRecord and call External VVEdGlobalAction
//
procedure TN_VVEdBaseForm.SetRect( const ADRect: TDRect );
var
  i: integer;
begin
  for i := 0 to High(OVEditors) do
    with OVEditors[i] do
    begin
      SetValue( PDouble(TN_BytesPtr(@ADRect)+i*Sizeof(double))^ );
      SetDataByValue( PData );
    end;

  VVEdGlobalAction( OnApplyAction );
end; // end of procedure TN_VVEdBaseForm.SetRect

//***********************************  TN_VVEdBaseForm.DecodeSenderTag  ******
// Decode Sender Tag and return VEditorInd and Sender Type
//
procedure TN_VVEdBaseForm.DecodeSenderTag( Sender: TObject; out AVEdInd: integer;
                                            out ASenderType: TN_VVESenderType );
var
  Tag: integer;
begin
  Assert( Sender is TComponent, 'Bad Sender!' );
  Tag := TComponent(Sender).Tag;
  AVEdInd := Tag mod 10; // first decimal digit is index in OVEditors array
  Assert( AVEdInd <= High(OVEditors), 'Bad Tag!' );

  ASenderType := TN_VVESenderType((Tag div 10) mod 10); // second decimal digit
                                                        //       is Sender Type
end; // end of procedure TN_VVEdBaseForm.DecodeSenderTag

procedure TN_VVEdBaseForm.UpdateByStr( Sender: TObject; AStr: string );
// Update Controls and VEditor by given String AStr
// (used in OnKeyDown and OnCloseUp event handlers for all controls)
var
  VEdInd, i, ibeg, iend: integer;
  NewValue: double;
  Str: string;
  SenderType: TN_VVESenderType;
begin
  DecodeSenderTag( Sender, VEdInd, SenderType );
  Assert( SenderType <> estNotGiven, 'Bad Tag!' );

  if IndividualSteps or   // individual value for each VEditor
     (SenderType = estValue) then // change for ShowValue Control
  begin
    ibeg := VEdInd;
    iend := VEdInd;
  end else //*************** same value for all OVEditors
  begin
    ibeg := 0;
    iend := High(OVEditors);
  end;

  for i := ibeg to iend do
  with OVEditors[i] do
  begin
    Str := AStr;
//    N_i := SelfInd; // debug

    case SenderType of

      estValue: begin
        NewValue := N_ScanDouble( Str );
        // (NewValue - CurValue) should be saved in LastStep for Shift Rect Mode!
        UpdateValue( NewValue - CurValue );
      end;

      estNumDigits: begin
        NumDigits := N_ScanInteger( Str );
        SetValue( CurValue );
      end;

      estStep:      Step := N_ScanDouble( Str );

      estMultCoef:  MultCoef := N_ScanInteger( Str );

    end; // case SenderType of
  end; // with OVEditors[VEdInd] do
end; // procedure TN_VVEdBaseForm.UpdateByStr

//***********************************  TN_VVEdBaseForm.SetDataByValues  ******
// Execute SetDataByValue method for all OVEditors
//
procedure TN_VVEdBaseForm.SetDataByValues( APData: Pointer );
var
  i: integer;
begin
  for i := 0 to High(OVEditors) do
    with OVEditors[i] do
      SetDataByValue( APData );
end; // end of procedure TN_VVEdBaseForm.SetDataByValues

//***********************************  TN_VVEdBaseForm.SetValuesByData  ******
// Execute SetValueByData method for all OVEditors
//
procedure TN_VVEdBaseForm.SetValuesByData( APData: Pointer );
var
  i: integer;
begin
  for i := 0 to High(OVEditors) do
    with OVEditors[i] do
      SetValueByData( APData );
end; // end of procedure TN_VVEdBaseForm.SetValuesByData

//******************************************* TN_VVEdBaseForm.InitVVEdForm1 ***
// Create and Initialize given number of VEditors for editing Value Filed
// (Scalar, Point or Rect) of given ARAFrame
//
// APData   - Pointer to Field to Edit
// ARAFrame - RAFrame with Field to Edit
// AMemIniPrefix - MemIni Section Prefix for saving Form State
//
procedure TN_VVEdBaseForm.InitVVEdForm1( APData: Pointer; ARAFrame: TK_FrameRAEdit;
                                                          AMemIniPrefix: string );
var
  i, VEdInd, CurOffset, NumVEditors: integer;
  CurEd: TEdit;
  SenderType: TN_VVESenderType;
  PRAFC: TK_PRAFColumn;
  CurTCode, MScalSizeType, MPointSizeType, MRectSizeType: TK_ExprExtType;
  RAFrameForm: TComponent;
begin
  with ARAFrame do
  begin

  PRAFC := @RAFCArray[CurLCol];
  Caption := PRAFC^.Caption;

  ValueType := ovtNotDef; // to avoid warning
  CurTCode := PRAFC^.CDType;
  MScalSizeType  := K_GetTypeCodeSafe( 'TN_MScalSize' );
  MPointSizeType := K_GetTypeCodeSafe( 'TN_MPointSize' );
  MRectSizeType  := K_GetTypeCodeSafe( 'TN_MRectSize' );

  if (CurTCode.DTCode = MScalSizeType.DTCode)  or
     (CurTCode.DTCode = MPointSizeType.DTCode) or
     (CurTCode.DTCode = MRectSizeType.DTCode)    then
    ValueType := ovtFloat
  else case CurTCode.DTCode of
    Ord(nptInt),    Ord(nptIPoint), Ord(nptIRect): ValueType := ovtInteger;
    Ord(nptFloat),  Ord(nptFPoint), Ord(nptFRect): ValueType := ovtFloat;
    Ord(nptDouble), Ord(nptDPoint), Ord(nptDRect): ValueType := ovtDouble;
  end; // case PRAFC^.CDType.DTCode of

  NumVEditors := 0;
  if CurTCode.DTCode = MScalSizeType.DTCode then
    NumVEditors := 1
  else  if CurTCode.DTCode = MPointSizeType.DTCode then
    NumVEditors := 2
  else  if CurTCode.DTCode = MRectSizeType.DTCode then
    NumVEditors := 4
  else case PRAFC^.CDType.DTCode of
    Ord(nptInt),    Ord(nptFloat),  Ord(nptDouble): NumVEditors := 1;
    Ord(nptIPoint), Ord(nptFPoint), Ord(nptDPoint): NumVEditors := 2;
    Ord(nptIRect),  Ord(nptFRect),  Ord(nptDRect) : NumVEditors := 4;
  end; // case PRAFC^.CDType.DTCode of

  RAFrameForm := Owner;
  if RAFrameForm is TN_RAEditForm then
  begin
    RaEditF := TN_RAEditForm(RAFrameForm);
    cbApplyToAll.Checked := RaEditF.cbApplyToMarked.Checked;
  end else
    RaEditF := nil;

  PData           := APData;
  VVEdGAProcOfObj := RAFGlobalActionProc; // ARAFrame method
  MemIniPrefix    := AMemIniPrefix;
  OnApplyAction   := K_fgaApplyToAll;
  end; // with ARAFrame do

  //***** Create and init OVEditors

  SetLength( OVEditors, NumVEditors );
  CurOffset := 0;

  for i := 0 to High(OVEditors) do
  begin
    OVEditors[i] := TN_OneValueVEditor.Create();
    with OVEditors[i] do
    begin
      VVEdForm := Self;
      DataOffset := CurOffset;
      SelfInd := i;
    end;

    if ValueType = ovtDouble then Inc( CurOffset, 8 )  // double
                             else Inc( CurOffset, 4 ); // integer or float
  end; // for i := 0 to High(OVEditors) do

  //***** Set ViewValueControl in all OVEditors

  for i := 0 to ComponentCount-1 do
  begin
    if not (Components[i] is TEdit) then Continue;
    CurEd := TEdit(Components[i]);
    DecodeSenderTag( CurEd, VEdInd, SenderType );
    if SenderType = estValue then
      OVEditors[VEdInd].ViewValueControl := CurEd;
  end; // for i := 0 to ComponentCount-1 do

  if ARAFrame.Owner is TN_BaseForm then BaseFormInit( TN_BaseForm(ARAFrame.Owner) )
                                   else BaseFormInit( nil );

  SetValuesByData( PData ); // Set (CurValue fields by Data Record)
  PrevData := PDRect(PData)^;

  //***** Init UndoRects (CurValue fields are already OK)
  SetLength( UndoRects, 1 );
  UndoRects[0] := GetRect(); // Initial Data Record
  UndoFreeInd := 1;
  UndoMaxInd  := 0;

end; // end of procedure TN_VVEdBaseForm.InitVVEdForm1

//******************************************* TN_VVEdBaseForm.InitVVEdForm2 ***
// Create and Initialize ANumVEditors number of VEditors
// VEditors type should alredy be set in Self.ValueType
//
// APData   - Pointer to Field to Edit
// AMemIniPrefix - MemIni Section Prefix for saving Form State
//
procedure TN_VVEdBaseForm.InitVVEdForm2( APData: Pointer; ANumVEditors: integer;
                                     AMemIniPrefix: string; AOwner: TN_BaseForm );
var
  i, VEdInd, CurOffset: integer;
  CurEd: TEdit;
  SenderType: TN_VVESenderType;
begin
  MemIniPrefix := AMemIniPrefix;

  //***** Create and init OVEditors

  SetLength( OVEditors, ANumVEditors );
  CurOffset := 0;

  for i := 0 to High(OVEditors) do
  begin
    OVEditors[i] := TN_OneValueVEditor.Create();
    with OVEditors[i] do
    begin
      VVEdForm := Self;
      DataOffset := CurOffset;
      SelfInd := i;
    end;

    if ValueType = ovtDouble then Inc( CurOffset, 8 )  // double
                             else Inc( CurOffset, 4 ); // integer or float
  end; // for i := 0 to High(OVEditors) do

  //***** Set ViewValueControl in all OVEditors

  for i := 0 to ComponentCount-1 do
  begin
    if not (Components[i] is TEdit) then Continue;
    CurEd := TEdit(Components[i]);
    DecodeSenderTag( CurEd, VEdInd, SenderType );
    if SenderType = estValue then
      OVEditors[VEdInd].ViewValueControl := CurEd;
  end; // for i := 0 to ComponentCount-1 do

  BaseFormInit( AOwner);

  SetValuesByData( APData ); // Set (CurValue fields by Data Record)
  PrevData := PDRect(APData)^;

  //***** Init UndoRects (CurValue fields are already OK)
  SetLength( UndoRects, 1 );
  UndoRects[0] := GetRect(); // Initial Data Record
  UndoFreeInd := 1;
  UndoMaxInd  := 0;

end; // end of procedure TN_VVEdBaseForm.InitVVEdForm2

//***********************************  TN_VVEdBaseForm.VVEdGlobalAction  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_VVEdBaseForm.VVEdGlobalAction( AnActionType : TK_RAFGlobalAction );
// call VVEdGAProcOfObj
begin
  if RaEditF <> nil then // set info, needed in ApplyToAll Mode
  with RaEditF.UpValsInfo do
  begin
    ValsPrevData := PrevData;
    ApplyToAll := cbApplyToAll.Checked;
    ValType    := ValueType;
    NumVals    := Length(OVEditors);
    DeltaMode  := cbApplyDelta.Checked;

    if DeltaMode then
      ValOffset := OVEditors[1].DataOffset
    else
      ValOffset := OVEditors[LastVEdInd].DataOffset;
      
  end; // if RaEditF <> nil then

//  N_MEGlobObj.TestGlobalAction( AnActionType ); // for debug
  if Assigned( VVEdGAProcOfObj ) then VVEdGAProcOfObj( Self, AnActionType );

  if RaEditF <> nil then
    RaEditF.UpValsInfo.ApplyToAll := False;

  PrevData := PDRect(PData)^;
end; // end of procedure TN_VVEdBaseForm.VVEdGlobalAction

//***********************************  TN_VVEdBaseForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_VVEdBaseForm.CurStateToMemIni();
var
  i, VEdInd: integer;
  SenderType: TN_VVESenderType;
  CurMB: TComboBox;
begin
  Inherited;

  for i := 0 to ComponentCount-1 do
  begin
    if not (Components[i] is TComboBox) then Continue;
    CurMB := TComboBox(Components[i]);
//    N_s := CurMB.Name; // debug

    DecodeSenderTag( CurMB, VEdInd, SenderType );
    case SenderType of

    estNumDigits: N_ComboBoxToMemIni( MemIniPrefix+'_NumDig', CurMB );
    estStep:      N_ComboBoxToMemIni( MemIniPrefix+'_Step',   CurMB );
    estMultCoef:  N_ComboBoxToMemIni( MemIniPrefix+'_MultC',  CurMB );

    end; // case SenderType of

  end; // for i := 0 to ComponentCount-1 do
end; // end of procedure TN_VVEdBaseForm.CurStateToMemIni

//***********************************  TN_VVEdBaseForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_VVEdBaseForm.MemIniToCurState();
var
  i, VEdInd: integer;
  SenderType: TN_VVESenderType;
  CurMB: TComboBox;
begin
  Inherited;

  for i := 0 to ComponentCount-1 do
  begin
    if not (Components[i] is TComboBox) then Continue;
    CurMB := TComboBox(Components[i]);
//    N_s := CurMB.Name; // debug

    DecodeSenderTag( CurMB, VEdInd, SenderType );
    case SenderType of

    estNumDigits: begin
      N_MemIniToComboBox( MemIniPrefix+'_NumDig', CurMB );
      if CurMB.Items.Count <= 1 then
      with CurMB.Items do
      begin
        Add( '3' ); Add( '0' ); Add( '1' ); Add( '5' ); Add( '7' );
      end;
    end; // estNumDigits: begin

    estStep: begin
      N_MemIniToComboBox( MemIniPrefix+'_Step', CurMB );
      if CurMB.Items.Count <= 1 then
      with CurMB.Items do
      begin
        Add( '0.1' ); Add( '0.01' ); Add( '1' ); Add( '10' );
      end;
    end; // estStep: begin

    estMultCoef:  begin
      N_MemIniToComboBox( MemIniPrefix+'_MultC', CurMB );
      if CurMB.Items.Count <= 1 then
      with CurMB.Items do
      begin
        Add( '10' ); Add( '5' ); Add( '30' );
      end;
    end; // estMultCoef:  begin

    end; // case SenderType of

    if CurMB.ItemIndex = -1 then // is needed when no info in MemIni
      CurMB.ItemIndex := 0;

    mbCloseUp( CurMB );
  end; // for i := 0 to ComponentCount-1 do
end; // end of procedure TN_VVEdBaseForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//********************************************  N_PrepByRAFrame  ******
// Prepare ValType (as Result), OwnerForm and set cbApplyToAll.Checked
// by given RAFrame
//
function N_PrepByRAFrame( ARAFrame: TK_FrameRAEdit;
                          out AOwnerForm: TN_BaseForm ): TN_OneValueType;
var
  PRAFC: TK_PRAFColumn;
begin
  with ARAFrame do
  begin
    PRAFC := @RAFCArray[CurLCol];

    Result := ovtNotDef; // to avoid warning
    case PRAFC^.CDType.DTCode of
      Ord(nptInt):    Result := ovtInteger;
      Ord(nptFloat):  Result := ovtFloat;
      Ord(nptDouble): Result := ovtDouble;
    end; // case PRAFC^.CDType.DTCode of

    if Owner is TN_BaseForm then AOwnerForm := TN_BaseForm( Owner )
                            else AOwnerForm := nil;
{
    if ApplObj is TN_RAEditForm then
      VScalEdForm.cbApplyToAll.Checked :=
                              TN_RAEditForm(ApplObj).cbApplyToMarked.Checked;
}
  end; // with ARAFrame do
end; // function N_PrepByRAFrame

end.
