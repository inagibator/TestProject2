unit K_FCMDCMStore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  N_BaseF, N_Types, N_Rast1Fr, N_DGrid, N_CM2,
  K_CMDCMDLib, K_CM0;

type
  TK_FormCMDCMStore = class(TN_BaseForm)
    BtStore: TButton;
    BtCancel: TButton;

    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    StateShape: TShape;
    LbServerPort: TLabel;
    LbServerName: TLabel;
    LbServerIP: TLabel;
    LbAppEntity: TLabel;
    PnSlides: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    ChBRedoStore: TCheckBox;

    procedure BtStoreClick(Sender: TObject);
    procedure ChBRedoStoreClick(Sender: TObject);
  private
    { Private declarations }
    DCMExportedCount : Integer;
    SavedCursor: TCursor;
    ServerConnectionIsDone : Boolean;
    ServerConnectionAttrsIsOK : Boolean;

    SDCSlides: TN_UDCMSArray;
    SDCSlidesIni: TN_UDCMSArray;
    SDCThumbsDGrid: TN_DGridArbMatr;
    SDCDrawSlideObj: TN_CMDrawSlideObj;

    procedure ShowDICOMServerState;
    procedure SelectSlidesByRedoStore();

  public
    { Public declarations }
    procedure SDCDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
  end;

var
  K_FormCMDCMStore: TK_FormCMDCMStore;

function K_CMDCMStoreDlg( APSlides : TN_PUDCMSlide; ASCount : Integer ) : Integer;

implementation

{$R *.dfm}

uses DateUtils, Math,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
     System.Types,
{$IFEND CompilerVersion >= 26.0}
     K_FCMDCMDImport, K_CLib0, K_CMDCM, K_FCMDCMSetup,
     N_Lib0, N_Lib1, N_ImLib, N_CM1, N_Comp1, N_Gra2;

function K_CMDCMStoreDlg( APSlides : TN_PUDCMSlide; ASCount : Integer ) : Integer;
var
  DCMServerPort: Integer;
  DCMColsNum : Integer;
  i : Integer;
begin


  with TK_FormCMDCMStore.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbServerName.Caption := N_MemIniToString( 'CMS_DCMStoreSettings', 'Name', ''  );
    LbServerIP.Caption := N_MemIniToString( 'CMS_DCMStoreSettings', 'IP', ''  );
    DCMServerPort := N_MemIniToInt( 'CMS_DCMStoreSettings', 'Port', 0 );
    LbServerPort.Caption := '';
    if DCMServerPort <> 0 then
      LbServerPort.Caption := IntToStr(DCMServerPort);
//    LbAppEntity.Caption := K_CMGetDICOMAppEntityName();
    LbAppEntity.Caption := K_CMDCMSetupCMSuiteAetScu();


    N_Dump1Str( format( 'PACS settings >> Name=%s IP=%s Port=%s AE=%s',
                [LbServerName.Caption, LbServerIP.Caption, LbServerPort.Caption, LbAppEntity.Caption] ) );

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    ServerConnectionAttrsIsOK := (LbServerName.Caption <> '') and
                              (LbServerIP.Caption <> '')   and
                              (DCMServerPort <> 0);
    ServerConnectionIsDone := ServerConnectionAttrsIsOK;
    if ServerConnectionIsDone then
      ServerConnectionIsDone := K_CMDCMServerTestConnection( LbServerIP.Caption, DCMServerPort, LbServerName.Caption, LbAppEntity.Caption, 15, TRUE );
    Screen.Cursor := SavedCursor;
    ShowDICOMServerState();

    SetLength( SDCSlidesIni, ASCount );
    Move( APSlides^, SDCSlidesIni[0], ASCount * SizeOf(TN_UDCMSlide) );
    for i := 0 to High(SDCSlidesIni) do
      with SDCSlidesIni[i] do
        N_Dump2Str( format( ' SlideID=%s $%x', [ObjName,Byte(CMSDCMFSet)] ) );

    SelectSlidesByRedoStore();
    BtStore.Enabled := ServerConnectionAttrsIsOK and (Length(SDCSlides) > 0);
// {DEB} BtStore.Enabled :=(Length(SDCSlides) > 0);

    SDCDrawSlideObj := TN_CMDrawSlideObj.Create();
    SDCThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, SDCGetThumbSize );

    DCMColsNum := Round( ThumbsRFrame.ClientWidth / 150 );
    with SDCThumbsDGrid do
    begin
      DGEdges := Rect( 2, 2, 2, 2 );
      DGGaps  := Point( 2, 2 );
      DGScrollMargins := Rect( 8, 8, 8, 8 );
      begin
        if ASCount <= 2 then
        begin
          DGLFixNumCols   := Max(1,DCMColsNum);
          DGLFixNumRows   := 0;
        end
        else
        if ASCount <= 4 then
        begin
          DGLFixNumCols   := Max(2,DCMColsNum);
          DGLFixNumRows   := 0;
        end
        else
        if ASCount <= 6 then
        begin
          DGLFixNumCols   := Max(3,DCMColsNum);
          DGLFixNumRows   := 0;
        end
        else
        if ASCount <= 12 then
        begin
          DGLFixNumCols   := Max(4,DCMColsNum);
          DGLFixNumRows   := 0;
        end
        else
        begin
          DGLFixNumCols   := Max(5,DCMColsNum);
          DGLFixNumRows   := 0;
        end;
      end;

      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
//      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkBordColor := DGBackColor;
//      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 14; // see DGLItemsAspect

      DGDrawItemProcObj := SDCDrawThumb;
//      DGNumItems := ASCount;
      DGNumItems := Length(SDCSlides);
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
//      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      ThumbsRFrame.DstBackColor := DGBackColor;
    end; // with ThumbsDGrid do

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

    Result := 0;

    N_Dump1Str( 'Before TK_FormCMDCMStore.ShowModal' );
    if ShowModal() = mrOK then
      Result := DCMExportedCount;
    N_Dump1Str( 'After TK_FormCMDCMStore.ShowModal ' + IntToStr(DCMExportedCount) );

    ThumbsRFrame.RFFreeObjects();
    SDCDrawSlideObj.Free();
    SDCThumbsDGrid.Free();

  end; // with TK_FormCMDCMStore.Create(Application) do


end; // function K_CMDCMStoreDlg


//****************************************** TK_FormCMDCMStore.BtStoreClick ***
// Button BtStore OnClick event handler
//
procedure TK_FormCMDCMStore.BtStoreClick(Sender: TObject);
var
  AlreadyExists, OutOfMemoryCount, ImgErrCount : Integer;

begin

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  DCMExportedCount := K_DCMStoreExport( @SDCSlides[0], Length(SDCSlides), '',
                           AlreadyExists, OutOfMemoryCount, ImgErrCount );
  Screen.Cursor := SavedCursor;

  if ImgErrCount > 0 then
  begin
    K_CMShowMessageDlg( format( 'Some error were detected. %d object(s) haven''t been put to the DICOM storage buffer.',
                [ImgErrCount] ), mtWarning );
  end;

  if OutOfMemoryCount > 0 then
  begin
    K_CMShowMessageDlg( format(
'There is not enough memory to process all images. %d object(s) haven''t been put to the DICOM storage buffer.'+
'        Please close some open image(s) or restart Media Suite if needed.',
                [OutOfMemoryCount] ), mtWarning );
    K_CMOutOfMemoryFlag := TRUE;
  end;

  if AlreadyExists > 0 then
  begin
    K_CMShowMessageDlg( format(
' %d object(s) are already in the DICOM storage buffer.',
                [AlreadyExists] ), mtWarning );
  end;

end; // procedure TK_FormCMDCMStore.BtStoreClick

procedure TK_FormCMDCMStore.ShowDICOMServerState;
begin
  if ServerConnectionIsDone then
  begin
    StateShape.Pen.Color   := clGreen;
    StateShape.Pen.Color   := clLime;
    StateShape.Pen.Color   := clOlive;
    StateShape.Brush.Color := clGreen;
  end
  else
  begin
    StateShape.Pen.Color   := clGray;
    StateShape.Brush.Color := clGray;
  end;
end; // procedure TK_FormCMDCMStore.ShowDICOMServerState

//****************************************** TK_FormCMDCMStore.SDCDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of SSAThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMDCMStore.SDCDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  WStr : string;
begin
  with N_CM_GlobObj do  begin
//    CMStringsToDraw[0] := SSASlides[AInd].GetUName;
    CMStringsToDraw[0] := K_CMSlideViewCaption( SDCSlides[AInd] ) + WStr;

{}
    SDCDrawSlideObj.DrawOneThumb1( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
{}
{
    SDCDrawSlideObj.DrawOneThumb2( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
}
  end; // with N_CM_GlobObj do
end; // end of TK_FormCMDCMStore.SDCDrawThumb

//*************************************** TK_FormCMDCMStore.SDCGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of SSAThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMDCMStore.SDCGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := SDCSlides[AInd];
    ThumbDIB  := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TK_FormCMDCMStore.SDCGetThumbSize

procedure TK_FormCMDCMStore.SelectSlidesByRedoStore;
var i, Ind : Integer;
begin
  if ChBRedoStore.Checked then
    SDCSlides := SDCSlidesIni
  else
  begin
    SetLength( SDCSlides, Length(SDCSlidesIni) );
    Ind := 0;
    for i := 0 to High(SDCSlidesIni) do
    begin
      if K_bsdcmsStore in SDCSlidesIni[i].CMSDCMFSet then Continue;
      SDCSlides[Ind] := SDCSlidesIni[i];
      Inc(Ind);
    end;
    SetLength( SDCSlides, Ind );
  end;
end; // procedure TK_FormCMDCMStore.SelectSlidesByRedoStore;

procedure TK_FormCMDCMStore.ChBRedoStoreClick(Sender: TObject);
begin
  SelectSlidesByRedoStore();
  with SDCThumbsDGrid do
  begin
    DGNumItems := Length(SDCSlides);
    DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
  end; // with ThumbsDGrid do
  BtStore.Enabled := ServerConnectionAttrsIsOK and (Length(SDCSlides) > 0);
// {DEB} BtStore.Enabled :=(Length(SDCSlides) > 0);
end; // procedure TK_FormCMDCMStore.ChBRedoStoreClick

end.
