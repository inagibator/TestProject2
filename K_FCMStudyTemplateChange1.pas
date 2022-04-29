unit K_FCMStudyTemplateChange1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_Types, N_BaseF, N_CMREd3Fr,
  K_CM0, K_UDT1;

type
  TK_FormCMStudyTemplateChange1 = class(TN_BaseForm)
    TemplateFrame: TN_CMREdit3Frame;
    StatusBar: TStatusBar;
    BtOK: TButton;
    BtCancel: TButton;
    BtUndo: TButton;
    BtReset: TButton;
    BtSetCurOrder: TButton;
    BtSetInitOrder: TButton;
    procedure FormShow(Sender: TObject);
    procedure RFramePaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure BtResetClick(Sender: TObject);
    procedure BtSetCurOrderClick(Sender: TObject);
    procedure BtSetInitOrderClick(Sender: TObject);
    procedure BtUndoClick(Sender: TObject);
  private
    { Private declarations }
    UDTemplate : TN_UDCMSlide;
    SetUDItems : TN_UDArray;
    CurInd : Integer;
    procedure ResetOrder();
  public

  end;

var
  K_FormCMStudyTemplateChange1: TK_FormCMStudyTemplateChange1;

function K_CMStudyTemplateChangeItemsOrder( const AUDTemplateObjName : string ) : Boolean;


implementation

{$R *.dfm}

uses Contnrs,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  System.Types,
{$IFEND CompilerVersion >= 26.0}
K_UDC, K_SBuf, K_UDConst, K_Script1, K_VFunc,
N_Lib1, N_SGComp, N_Comp1, N_CompCL, N_Lib0, N_Lib2, N_Gra0, N_Gra1;

function K_CMStudyTemplateChangeItemsOrder( const AUDTemplateObjName : string ) : Boolean;
var
  UDFont : TN_UDNFont;
  FontHeight : single;
  ShowOrderComp : TN_UDParaBox;
  i, ItemsCount : Integer;
  SResOrder : string;
  NotInitOrder : Boolean;
  PData : Pointer;
  CurOrder, NewOrder : TN_IArray;
  UDInitTemplate : TN_UDCMSlide;
  CurTemplateUDItems : TN_UDArray;

begin
  K_FormCMStudyTemplateChange1 := TK_FormCMStudyTemplateChange1.Create( Application );
  with K_FormCMStudyTemplateChange1, K_CMEDAccess do
  begin
    // Prepare UDTemplate Copy
    UDInitTemplate := TN_UDCMSlide(K_CMEDAccess.ArchStudySamplesLibRoot.DirChildByObjName(AUDTemplateObjName));
    ItemsCount := UDInitTemplate.GetMapRoot().DirLength();
    K_SaveTreeToMem( UDInitTemplate, N_SerialBuf, false, [K_lsfJoinAllSLSR] );
    UDTemplate := TN_UDCMSlide(K_LoadTreeFromMem(N_SerialBuf, [K_lsfJoinAllSLSR]));
    SetLength( SetUDItems, ItemsCount );

    // Enlarge Order Show Font
    ShowOrderComp := TN_UDParaBox(UDTemplate.GetMapRoot().DirChild(0).DirChild(1).DirChild(2));
    with ShowOrderComp do
    begin
      UDFont := TN_UDNFont(TN_POneTextBlock(PISP().CPBTextBlocks.P).OTBNFont);
      with TN_PNFont(UDFont.R.P)^ do
      begin
        FontHeight := NFLLWHeight;
        NFLLWHeight := 30;
      end;
    end; // with TN_UDParaBox(UDTemplate.GetMapRoot().DirChild(0).DirChild(1).DirChild(2)) do

    // Show change order dialog
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Caption := format( 'Change items fill order - %s', [UDTemplate.ObjAliase] );
    N_Dump1Str( 'Before K_FormCMStudyTemplateChange1 ShowModal' );
    Result := mrOK = ShowModal();
    N_Dump1Str( 'After K_FormCMStudyTemplateChange1 ShowModal' );

    if Result then
    begin // Save new order and change runtime Template instance

      // Create new Order array and
      // order string for saving in global context
      SResOrder := '';
      NotInitOrder := FALSE;
      SetLength( NewOrder, ItemsCount );
      for i := 0 to ItemsCount - 1 do
      begin
        if SResOrder <> '' then
          SResOrder := SResOrder + ' ';
        SResOrder := SResOrder + SetUDItems[i].ObjName;
        NewOrder[i] := StrToInt(SetUDItems[i].ObjName);
        if not NotInitOrder then
          NotInitOrder := NewOrder[i] <> i;
      end; // for i := 0 to High(SetUDItems) do

      // Rebuild current runtime Template
      SetLength( CurOrder, ItemsCount );
      SetLength( CurTemplateUDItems, ItemsCount );
      // Build Template Current Order (before changing) and Get Template Items to CurTemplateUDItems
      with UDInitTemplate.GetMapRoot() do
      for i := 0 to ItemsCount - 1 do
      begin
        CurTemplateUDItems[i] := DirChild(i);
        CurOrder[i] := StrToInt(CurTemplateUDItems[i].ObjName);
      end; // for i := 0 to High(CurOrder) do

      // Get from CurTemplateUDItems to SetUDItems in intial order
      for i := 0 to ItemsCount - 1 do
        SetUDItems[CurOrder[i]] := CurTemplateUDItems[i];

      // Get from SetUDItems to CurTemplateUDItems  in new order and replace item order texts
      for i := 0 to ItemsCount - 1 do
      begin
        CurTemplateUDItems[i] := SetUDItems[NewOrder[i]];
        with TN_POneTextBlock(TN_UDParaBox(CurTemplateUDItems[i].DirChild(1).DirChild(2)).PISP().CPBTextBlocks.P)^ do
          OTBMText := IntToStr( i + 1 );
      end;

      // Put new order Items to current runtime Template Items Dir
      with UDInitTemplate.GetMapRoot() do
      begin
        PData := GetDEFieldPointer( 0, K_DEFisChild );
        Move( CurTemplateUDItems[0], TN_PUDBase(PData)^, SizeOf(TN_UDBase) * ItemsCount );
      end;

      // Save new order to context
      EDAGAGlobalToCurState();

      if NotInitOrder then
        N_StringToMemIni( 'StudyTemplatesPosOrder', AUDTemplateObjName, SResOrder )
      else
      begin
        N_CurMemIni.DeleteKey( 'StudyTemplatesPosOrder', AUDTemplateObjName );
        N_CurMemIni.ReadSectionValues( 'StudyTemplatesPosOrder',  TmpStrings );
        if TmpStrings.Count = 0 then
          N_CurMemIni.EraseSection( 'StudyTemplatesPosOrder' );
      end;

      EDASaveContextsData( [K_cmssSkipSlides, K_cmssSkipInstanceBinInfo,
                            K_cmssSkipInstanceInfo, K_cmssSkipPatientInfo,
                            K_cmssSkipProviderInfo, K_cmssSkipLocationInfo,
                            K_cmssSkipExtIniInfo] );
    end; // if Result then

    UDTemplate.Free;
  end; // with K_FormCMStudyTemplateChange1

  // Restore Order Show Font Size
  with TN_PNFont(UDFont.R.P)^ do
    NFLLWHeight := FontHeight;

  K_FormCMStudyTemplateChange1 := nil;

end; // function K_CMStudyTemplateChangeItemsOrder

//********************************************* TK_FormCMStudyCapt.FormShow ***
// OnShow Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.FormShow(Sender: TObject);
begin
  inherited;

  ResetOrder();

  with TemplateFrame do
  begin
    RFrame.RFDebName := Name;
    RFrame.PaintBox.OnDblClick := nil;
    EdVObjsGroup := TN_SGComp.Create( RFrame );
    with EdVObjsGroup do
    begin
      GName := 'VOGroup';
      PixSearchSize := 15;
      SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
                 $04;  // do redraw actions loop witout objects
    end;
    RFrame.RFSGroups.Add( EdVObjsGroup );

//    UDStudy := TN_UDCMStudy(N_CM_MainForm.CMMFActiveEdFrame.EdSlide);
    EdSlide := UDTemplate;
    RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
    RFrame.OCanvBackColor := RFrame.DstBackColor;
    RFrame.RFCenterInDst := True;
    RFrame.RVCTFrInit3( EdSlide.GetMapRoot() );
    RFrame.aFitInWindowExecute( nil );
    RebuildStudySearchList();

    RFrame.RedrawAllAndShow();
  end; // with CMStudyFrame do

end; // procedure TK_FormCMStudyCapt.FormShow

//********************************** TK_FormCMStudyTemplateChange1.RFramePaintBoxMouse ***
// RFramePaintBox OnMouseDown handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.RFramePaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  UDItem : TN_UDBase;
  i : Integer;
begin
  inherited;
  with TemplateFrame, TN_UDCMStudy(EdSlide), EdVObjsGroup, OneSR do
  begin
    if not (ssLeft in Shift) or (SRType = srtNone) then Exit;
    UDItem := TN_UDBase(SComps[SRCompInd].SComp);
    if (CurInd = 0) or
       (0 > K_IndexOfIntegerInRArray( Integer(UDItem), PInteger(@SetUDItems[0]), CurInd ) ) then
    begin
//      if CurInd > 0 then
//        UnSelectItem( SetUDItems[CurInd - 1] );

      BtUndo.Enabled := TRUE;
      SelectItem( UDItem );
      SetUDItems[CurInd] := UDItem;
      Inc(CurInd);
      with TN_POneTextBlock(TN_UDParaBox(UDItem.DirChild(1).DirChild(2)).PISP().CPBTextBlocks.P)^ do
        OTBMText := IntToStr( CurInd );

      if CurInd = High(SetUDItems) then
      begin  // Set Last Item
        with UDTemplate.GetMapRoot() do
        for i := 0 to DirHigh do
        begin // Search for last unset item
          UDItem := DirChild( i );
          if 0 > K_IndexOfIntegerInRArray( Integer(UDItem), PInteger(@SetUDItems[0]), CurInd ) then
          begin // found unset Item
            SelectItem( UDItem );
            SetUDItems[CurInd] := UDItem;
            Inc(CurInd);
            with TN_POneTextBlock(TN_UDParaBox(UDItem.DirChild(1).DirChild(2)).PISP().CPBTextBlocks.P)^ do
              OTBMText := IntToStr( CurInd );
            break;
          end;
        end; // for i := 0 to DirHigh do
        BtOK.Enabled := TRUE;
      end; // if CurInd = High(SetUDItems) then

      RFrame.RedrawAllAndShow();
    end;
 end; // with CMStudyFrame, EdVObjsGroup, OneSR do

end; // procedure TK_FormCMStudyTemplateChange1.RFramePaintBoxMouseDown

//*************************************** TK_FormCMStudyTemplateChange1.FormCloseQuery ***
// OnCloseQuery Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  ConfText : string;
begin

  if (ModalResult = mrCancel) and (CurInd > 0) then
  begin
    ConfText := 'Do you really want to break the procedure?';
    if CurInd = Length(SetUDItems) then
      ConfText := 'Do you really want to exit without saving results?';
    CanClose := mrYes = K_CMShowMessageDlg( ConfText,  mtConfirmation );
  end;
  if not CanClose then Exit;
  N_Dump2Str( 'TK_FormCMStudyTemplateChange1 >> Close start' );

end; // procedure TK_FormCMStudyTemplateChange1.FormCloseQuery


//******************************************** TK_FormCMStudyTemplateChange1.FormClose ***
// OnClose Self handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.FormClose(Sender: TObject;
  var Action: TCloseAction );
begin
  // Close Preview window if Opened

  // Delete all Slides which should be deleted

  inherited;

end; // procedure TK_FormCMStudyTemplateChange1.FormClose


//******************************** TK_FormCMStudyTemplateChange1.ResetOrder ***
// Reset Order - clear all oder texts
//
procedure TK_FormCMStudyTemplateChange1.ResetOrder;
var
  i : Integer;
  ShowOrderComp : TN_UDParaBox;
begin
  with UDTemplate.GetMapRoot() do
  for i := 0 to DirHigh do
  begin
    ShowOrderComp := TN_UDParaBox( DirChild(i).DirChild(1).DirChild(2) );
    with TN_POneTextBlock(ShowOrderComp.PISP().CPBTextBlocks.P)^ do
      OTBMText := '*';
    with ShowOrderComp.PCCS()^ do
      BPCoords := FPoint(10,35);
  end;
  TN_UDCMStudy(UDTemplate).UnSelectAll();
  CurInd := 0;
  BtOK.Enabled := FALSE;
  BtUndo.Enabled := FALSE;
end; // procedure TK_FormCMStudyTemplateChange1.ResetOrder

//****************************** TK_FormCMStudyTemplateChange1.BtResetClick ***
// Button Reset OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.BtResetClick(Sender: TObject);
begin
  N_Dump1Str( 'StudyTemplateChange >> Reset Order' );
  ResetOrder;
  TemplateFrame.RFrame.RedrawAllAndShow();
end; // procedure TK_FormCMStudyTemplateChange1.BtResetClick

//************************ TK_FormCMStudyTemplateChange1.BtSetCurOrderClick ***
// Button Set current order OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.BtSetCurOrderClick( Sender: TObject);
var
  i : Integer;
  UDItem : TN_UDBase;
  PTextBlock : TN_POneTextBlock;
begin
//
  with UDTemplate.GetMapRoot() do
  begin
    for i := 0 to DirHigh do
    begin
      UDItem := DirChild(i);
      TN_UDCMStudy(UDTemplate).SelectItem( UDItem );
      with UDItem do
      begin
        SetUDItems[i] := UDItem;
        PTextBlock := TN_POneTextBlock(TN_UDParaBox(DirChild(1).DirChild(2)).PISP().CPBTextBlocks.P);
        with PTextBlock^ do
        begin
          OTBMText := IntToStr( i + 1 );
        end;
      end; // with UDItem do
    end; // for i := 0 to DirHigh do
    CurInd := DirLength();
  end; // with UDTemplate.GetMapRoot() do
  TemplateFrame.RFrame.RedrawAllAndShow();

  BtUndo.Enabled := TRUE;
  BtOK.Enabled := TRUE;

end; // procedure TK_FormCMStudyTemplateChange1.BtSetCurOrderClick

//*********************** TK_FormCMStudyTemplateChange1.BtSetInitOrderClick ***
// Button Set initial order OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.BtSetInitOrderClick( Sender: TObject);
var
  i, j : Integer;
  UDItem : TN_UDBase;
  PTextBlock : TN_POneTextBlock;
begin
//
  with UDTemplate.GetMapRoot() do
  begin
    for i := 0 to DirHigh do
    begin
      UDItem := DirChild(i);
      TN_UDCMStudy(UDTemplate).SelectItem( UDItem );
      j := StrToInt( UDItem.ObjName );
      with UDItem do
      begin
        SetUDItems[j] := UDItem;
        PTextBlock := TN_POneTextBlock(TN_UDParaBox(DirChild(1).DirChild(2)).PISP().CPBTextBlocks.P);
        with PTextBlock^ do
        begin
          OTBMText := IntToStr( j + 1 );
        end;
      end; // with UDItem do
    end; // for i := 0 to DirHigh do
    CurInd := DirLength();
  end; // with UDTemplate.GetMapRoot() do
  TemplateFrame.RFrame.RedrawAllAndShow();

  BtOK.Enabled := TRUE;
  BtUndo.Enabled := TRUE;

end; // procedure TK_FormCMStudyTemplateChange1.BtSetInitOrderClick

//******************************* TK_FormCMStudyTemplateChange1.BtUndoClick ***
// Button Undo last setting OnClick handler
//
//     Parameters
// Sender    - Event Sender
//
procedure TK_FormCMStudyTemplateChange1.BtUndoClick(Sender: TObject);

  procedure FreeLast();
  var
    ShowOrderComp : TN_UDParaBox;
  begin
    Dec( CurInd );
    TN_UDCMStudy(UDTemplate).UnSelectItem( SetUDItems[CurInd] );
    ShowOrderComp := TN_UDParaBox( SetUDItems[CurInd].DirChild(1).DirChild(2) );
    with TN_POneTextBlock(ShowOrderComp.PISP().CPBTextBlocks.P)^ do
      OTBMText := '*';
  end;
  
begin
  if CurInd = 0 then Exit; // precaution

  FreeLast();
  if CurInd = High(SetUDItems) then
    FreeLast();

  TemplateFrame.RFrame.RedrawAllAndShow();

  BtUndo.Enabled := CurInd > 0;
  BtOK.Enabled := FALSE;
end; // procedure TK_FormCMStudyTemplateChange1.BtUndoClick

end.
