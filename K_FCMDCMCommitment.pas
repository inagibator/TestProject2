unit K_FCMDCMCommitment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls,
  N_BaseF, N_Types, N_Rast1Fr, N_DGrid, N_CM2,
  K_CM0;

type
  TK_FormCMDCMCommitment = class(TN_BaseForm)
    BtComm: TButton;
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
    ChBRedoComm: TCheckBox;

    procedure BtCommClick(Sender: TObject);
    procedure ChBRedoCommClick(Sender: TObject);
  private
    { Private declarations }
    DMCDoneCount : Integer;
    SavedCursor: TCursor;
    ServerConnectionIsDone : Boolean;
    ServerConnectionAttrsIsOK : Boolean;

    SDCSlides: TN_UDCMSArray;
    SDCSlidesIni: TN_UDCMSArray;
    SDCThumbsDGrid: TN_DGridArbMatr;
    SDCDrawSlideObj: TN_CMDrawSlideObj;

    procedure ShowDICOMServerState;
    procedure SelectSlidesByRedoCommitment();

  public
    { Public declarations }
    procedure SDCDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
  end;

var
  K_FormCMDCMCommitment: TK_FormCMDCMCommitment;

function K_CMDCMCommitmentDlg( APSlides : TN_PUDCMSlide; ASCount : Integer ) : Integer;

implementation

{$R *.dfm}

uses DateUtils, Math,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
     System.Types,
{$IFEND CompilerVersion >= 26.0}
     K_FCMDCMDImport, K_CLib0, K_CMDCM, K_CMDCMGLibW, K_CM1,
     N_Lib0, N_Lib1, N_ImLib, N_CM1, N_Comp1, N_Gra2;

function  K_CMDCMCommitmentDlg( APSlides : TN_PUDCMSlide; ASCount : Integer ) : Integer;
var
  DCMServerPort: Integer;
  DCMColsNum : Integer;
  i : Integer;
begin


  with TK_FormCMDCMCommitment.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbServerName.Caption := N_MemIniToString( 'CMS_DCMSCommSettings', 'Name', ''  );
    LbServerIP.Caption := N_MemIniToString( 'CMS_DCMSCommSettings', 'IP', ''  );
    DCMServerPort := N_MemIniToInt( 'CMS_DCMSCommSettings', 'Port', 0 );
    LbServerPort.Caption := '';
    if DCMServerPort <> 0 then
      LbServerPort.Caption := IntToStr(DCMServerPort);
//    LbAppEntity.Caption := K_CMGetDICOMAppEntityName();
    LbAppEntity.Caption := N_MemIniToString( 'CMS_DCMAetScu', 'StoreSCP', ''  );

    N_Dump1Str( format( 'PACS settings >> Name=%s IP=%s Port=%s AE=%s',
                [LbServerName.Caption, LbServerIP.Caption, LbServerPort.Caption, LbAppEntity.Caption] ) );

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    ServerConnectionAttrsIsOK := (LbServerName.Caption <> '') and
                              (LbServerIP.Caption <> '')   and
                              (DCMServerPort <> 0)         and
                              (LbAppEntity.Caption <> '');
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

    SelectSlidesByRedoCommitment();
    BtComm.Enabled := ServerConnectionAttrsIsOK and (Length(SDCSlides) > 0);
// {DEB} BtComm.Enabled :=(Length(SDCSlides) > 0);

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
    N_Dump1Str( 'Before TK_FormCMDCMCommitment.ShowModal' );
    if ShowModal() = mrOK then
      Result := DMCDoneCount;
    N_Dump1Str( 'After TK_FormCMDCMCommitment.ShowModal ' + IntToStr(DMCDoneCount) );

    ThumbsRFrame.RFFreeObjects();
    SDCDrawSlideObj.Free();
    SDCThumbsDGrid.Free();

  end; // with TK_FormCMDCMCommitment.Create(Application) do


end; // function K_CMDCMCommitmentDlg


//************************************* TK_FormCMDCMCommitment.BtStoreClick ***
// Button BtStore OnClick event handler
//
procedure TK_FormCMDCMCommitment.BtCommClick(Sender: TObject);
var
  OutOfMemoryCount, ImgErrCount, DIErrCount : Integer;

  i, DCMResCode : Integer;
  WDCMFNames, WStudiesUID, WStudiesSID, WSeriesUID, WSeriesSID, WContentUID, WContentSID : TN_SArray;
  WStudiesTS, WSeriesTS, WContentTS, WAcqTS : TN_DArray;
  SlideDIB : TN_DIBObj;

  DI : TK_HDCMINST;
  WUInt2 : TN_UInt2;
  SOPInstUID, SOPClassUID : string;
  WBuf : WideString;
  sz : Integer;
  IsNil : Integer;

label ELoopGo;

begin

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    // Get DICOM export attributes
    EDAGetDCMSlideUCAttrs( @SDCSlides[0], Length(SDCSlides),
               WDCMFNames, WStudiesUID, WStudiesSID, WStudiesTS,
               WSeriesUID, WSeriesSID, WSeriesTS,
               WContentUID, WContentSID, WContentTS, WAcqTS );

    DMCDoneCount := 0;
    OutOfMemoryCount := 0;
    ImgErrCount := 0;
    DIErrCount := 0;
    SetLength( WBuf, 100 );
    for i := 0 to High(SDCSlides) do
    with SDCSlides[i] do
    begin
      SlideDIB := ExportToDIB([K_bsedSkipConvGrey16To8,K_bsedSkipAnnotations]);
      if SlideDIB = nil then
      begin
        N_Dump1Str( 'BtCommClick OutOfMemory >> ' + ObjName );
        Inc(OutOfMemoryCount);
        Continue;
      end
      else
      begin // SlideDIB <> nil
        try
          // Export to Raster File
          N_Dump2Str( 'BtCommClick >> before K_CMDCMExportDCMSlideToDCMInst >>' + ObjName );
          DCMResCode := K_CMDCMExportDCMSlideToDCMInst( DI, FALSE, SDCSlides[i], SlideDIB, WDCMFNames[i],
                                WStudiesUID[i], WStudiesSID[i], WStudiesTS[i],
                                WSeriesUID[i], WSeriesSID[i], WSeriesTS[i],
                                WContentUID[i], WContentSID[i], WContentTS[i], WAcqTS[i] );

          N_Dump2Str( 'BtCommClick >> after K_CMDCMExportDCMSlideToDCMInst' );

          if DCMResCode <> 0 then
          begin
            N_Dump1Str( format( 'BtCommClick >> K_CMDCMExportDCMSlideToDCMInst error >> ObjName="%s" ResCode=%d',
                                [ObjName,DCMResCode] ) );
            Inc(ImgErrCount);
            goto ELoopGo;
          end   // if DCMResCode <> 0 then
          else
          begin // if DCMResCode = 0 then

            // Get SopInstanceUID
            sz := 99;
            if 0 <>	 K_DCMGLibW.DLGetValueString( DI, K_CMDCMTSopInstanceUid, @WBuf[1], @sz, @isNil) then
            begin
              N_Dump1Str( 'BtCommClick >> Get SopInstanceUID error' );
              Inc(DIErrCount);
              goto ELoopGo;
            end
            else
              SOPInstUID := N_WideToString( Copy( WBuf, 1, sz ) );

            // Get SopClassUID
            sz := 99;
            if 0 <>	 K_DCMGLibW.DLGetValueString( DI, K_CMDCMTSopClassUid, @WBuf[1], @sz, @isNil) then
            begin
              N_Dump1Str( 'BtCommClick >> Get SopClassUID error' );
              Inc(DIErrCount);
              goto ELoopGo;
            end
            else
              SOPClassUID := N_WideToString( Copy( WBuf, 1, sz ) );

            N_Dump2Str( 'BtCommClick DeleteDcmObject before ');
            WUInt2 := K_DCMGLibW.DLDeleteDcmObject( DI );
            if 0 <> WUInt2 then
            begin
              N_Dump1Str( format( 'BtCommClick >> wrong DLDeleteDcmObject %d', [WUInt2] ) );
              Inc(DIErrCount);
              goto ELoopGo;
            end;

            K_CMDCMSlideStoreCommitmentAdd( 0, StrToInt( ObjName  ), SOPInstUID, SOPClassUID );

            Inc(DMCDoneCount);
          end; // if DCMResCode = 0 then
ELoopGo: //****
        except
          on E: Exception do
          begin
            N_Dump1Str( format( 'BtCommClick Error >> ObjName="%s" E=', [ObjName,E.Message]) );
            Inc(ImgErrCount);
          end;
        end; // try

        FreeAndNil( SlideDIB );
      end; // SlideDIB <> nil
    end; // with  with SDCSlides[i] do do
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  Screen.Cursor := SavedCursor;

  if ImgErrCount > 0 then
  begin
    K_CMShowMessageDlg( format( 'Some errors were detected. %d object(s) haven''t been put to the DICOM storage buffer.',
                [ImgErrCount] ), mtWarning );
  end;

  if DIErrCount > 0 then
  begin
    K_CMShowMessageDlg( format( 'Some errors were detected by wrapdcm.dll. %d object(s) haven''t been put to the DICOM storage buffer.',
                [DIErrCount] ), mtWarning );
  end;

  if OutOfMemoryCount > 0 then
  begin
    K_CMShowMessageDlg( format(
'There is not enough memory to process all images. %d object(s) haven''t been put to the DICOM storage buffer.'+
'        Please close some open image(s) or restart Media Suite if needed.',
                [OutOfMemoryCount] ), mtWarning );
    K_CMOutOfMemoryFlag := TRUE;
  end;

end; // procedure TK_FormCMDCMStore.BtStoreClick

procedure TK_FormCMDCMCommitment.ShowDICOMServerState;
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
procedure TK_FormCMDCMCommitment.SDCDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
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
procedure TK_FormCMDCMCommitment.SDCGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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

procedure TK_FormCMDCMCommitment.SelectSlidesByRedoCommitment;
var i, Ind : Integer;
begin
  if ChBRedoComm.Checked then
    SDCSlides := SDCSlidesIni
  else
  begin
    SetLength( SDCSlides, Length(SDCSlidesIni) );
    Ind := 0;
    for i := 0 to High(SDCSlidesIni) do
    begin
      if K_bsdcmsCommExists in SDCSlidesIni[i].CMSDCMFSet then Continue;
      SDCSlides[Ind] := SDCSlidesIni[i];
      Inc(Ind);
    end;
    SetLength( SDCSlides, Ind );
  end;
end; // procedure TK_FormCMDCMStore.SelectSlidesByRedoCommitment;

procedure TK_FormCMDCMCommitment.ChBRedoCommClick(Sender: TObject);
begin
  SelectSlidesByRedoCommitment();
  with SDCThumbsDGrid do
  begin
    DGNumItems := Length(SDCSlides);
    DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
  end; // with ThumbsDGrid do
  BtComm.Enabled := ServerConnectionAttrsIsOK and (Length(SDCSlides) > 0);
// {DEB} BtComm.Enabled :=(Length(SDCSlides) > 0);
end; // procedure TK_FormCMDCMStore.ChBRedoStoreClick

end.
