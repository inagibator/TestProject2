unit K_FrCMTeethChart1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Types,
  Dialogs, ExtCtrls,
  N_Gra2;

type
  TK_FrameCMTeethChart1 = class(TFrame)
    Image1: TImage;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    SelInds: TList; // this object should be destroyed by owner form
    TmpBitmap2: TBitmap;
    DIBChart, DIBChartSel, DIBChartMask, DIBChartBuf: TN_DIBObj;
    procedure RedrawTeethChart();
    procedure InitFrameObjects();
  public
    { Public declarations }
    TCFrTeethChartState : Int64;  // Current Teeth Chart Scale
    TCFrReadOnlyMode    : Boolean;// Read Only Mode
    procedure ShowTeethChartState( ATeethChartState : Int64 );
    procedure FreeFrameObjects();
  end;

implementation

{$R *.dfm}
uses N_Types, N_Lib1, N_Gra0,
     K_CLib0, K_CM0;

{ TK_FrameCMTeethChart1 }

procedure TK_FrameCMTeethChart1.FreeFrameObjects;
begin
  SelInds.Free;
//exit;
  TmpBitmap2.Free;
  DIBChart.Free;
  DIBChartSel.Free;
  DIBChartMask.Free;
  DIBChartBuf.Free;
end;

procedure TK_FrameCMTeethChart1.InitFrameObjects;
var
  TmpBitmap1 : TBitmap;
  ImgNameSuffix : string;

  function InitDIB( ACMS_MainIniName : string ) : TN_DIBObj;
  var
    FName : string;
  begin
    Result := nil;
    FName := N_MemIniToString( 'CMS_Main', ACMS_MainIniName, '');
    if FName = '' then
    begin
      N_Dump1Str( 'TeethChartInit >> CMS_Main.' + ACMS_MainIniName + ' field is absent' );
      Exit;
    end;

    Result := TN_DIBObj.Create( ); // Teethchart Image
    if Result.LoadFromFile( FName ) <> 0 then
    begin
      FreeAndNil( Result );
      N_Dump1Str( 'TeethChartInit >> File ' + FName + ' is not found or corrupted' );
    end;
{
    Result := TN_DIBObj.Create( FName ); // Teethchart Image
    if Result = nil then
      N_Dump1Str( 'TeethChartInit >> File ' + FName + ' is not found or corrupted' );
}
  end;

begin
  if SelInds <> nil then Exit;

  SelInds := TList.Create;
//exit;
  //***** Prepare Image1 for drawing in it (should be done only once)
  TmpBitmap1 := N_CreateEmptyBMP( Image1.Width, Image1.Height, pf24bit );
  Image1.Picture.Graphic := TmpBitmap1; // now TmpBitmap1 can be destroyed
  TmpBitmap1.Free;
  SetStretchBltMode( Image1.Picture.Bitmap.Canvas.Handle, HALFTONE );

  ImgNameSuffix := '2';
  if K_CMToothNumSchemeFlag = K_CMTNumFDIScheme then
    ImgNameSuffix := '1';

  DIBChart     := InitDIB( 'TeethchartImgFNameNormal' + ImgNameSuffix );// Teethchart Image
  if DIBChart = nil then
    K_CMShowMessageDlg( //sysout
      'Some problems with Teeth Chart Image file were detected', mtError, [], TRUE );
  DIBChartSel  := InitDIB( 'TeethchartImgFNameHighlited' + ImgNameSuffix );// Teethchart Image
  if DIBChartSel = nil then
    K_CMShowMessageDlg( //sysout
      'Some problems with Highlited Teeth Chart Image file were detected', mtError, [], TRUE );
  DIBChartMask := InitDIB( 'TeethchartImgFNameMask' );// Teethchart Image
  if DIBChartMask = nil then
    K_CMShowMessageDlg( //sysout
      'Some problems with Teeth Chart Mask Image file were detected', mtError, [], TRUE );

  if DIBChart <> nil then
    DIBChartBuf := TN_DIBObj.Create( DIBChart );

end;

procedure TK_FrameCMTeethChart1.RedrawTeethChart;
var
  PInd: Pinteger;
begin
  if (DIBChart = nil) or (DIBChartSel = nil) or (DIBChartMask = nil) then Exit;

  if SelInds.Count = 0 then
    PInd := nil
  else
    PInd := Pinteger(@SelInds.List[0]); // range check error in Delphi XE5 if Count = 0

  N_DrawGraphicMenuItems( DIBChartBuf.DIBOCanv.HMDC,
                          DIBChartSel, DIBChart, DIBChartMask,
                          PInd, SelInds.Count, TmpBitmap2 );

  N_StretchRect( Image1.Picture.Bitmap.Canvas.Handle, IRect(Image1.Width, Image1.Height),
                 DIBChartBuf.DIBOCanv.HMDC, DIBChartBuf.DIBRect );

  Repaint();
end;

procedure TK_FrameCMTeethChart1.ShowTeethChartState( ATeethChartState: Int64);
var
  WInds : TN_IArray;
  i, ICount : Integer;
begin
  DoubleBuffered := True; // to prevent flicker while parent form resizing

  if TCFrReadOnlyMode then Exit;

  //*** Rebuild Teeth Numbering Chart
  TCFrTeethChartState := ATeethChartState;
  InitFrameObjects();
  SelInds.Clear;
  SetLength( WInds, 64 );
  ICount := K_SetToInds ( @WInds[0], @TCFrTeethChartState, 64, 0 );

  for i := 0 to ICount - 1 do
    SelInds.Add( Pointer(WInds[i]) );

  RedrawTeethChart();

end;

procedure TK_FrameCMTeethChart1.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ChartInd : Integer;
  ListInd  : Integer;
begin
  if (DIBChartMask = nil) then Exit;
//??  ChartInd := DIBChartMask.GetPixValue( Point(X, Y) );
  ChartInd := DIBChartMask.GetPixValue( Point( Round( X * DIBChartMask.DIBSize.X / Image1.Width),
                                               Round( Y * DIBChartMask.DIBSize.Y / Image1.Height) ) );
  if ChartInd > 63 then Exit;
  ListInd  := SelInds.IndexOf( Pointer(ChartInd) );
  if ListInd >= 0 then
  begin // Remove selected
    K_SetExclude( ChartInd,  @TCFrTeethChartState );
    SelInds.Delete( ListInd );
  end
  else
  begin // Add selected
    K_SetInclude( ChartInd,  @TCFrTeethChartState );
    SelInds.Add( Pointer(ChartInd) );
  end;
  RedrawTeethChart();

end;

end.
