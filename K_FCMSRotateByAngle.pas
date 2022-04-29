unit K_FCMSRotateByAngle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2, N_Gra0, N_Gra1,
  K_CM0, K_UDT1;

type
  TK_FormCMSRotateByAngle = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    TBVal: TTrackBar;
    Timer: TTimer;
    Label1_: TLabel;
    Label2_: TLabel;
    Label3_: TLabel;
    procedure TBValChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    MeasureRoot : TN_UDBase;
//    VObjsViewState : Byte;
    procedure RedrawImage();
  public
    { Public declarations }
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    IniSize  : TFPoint;
    ResultingAngle : Double;
    ResPixAffCoefs6: TN_AffCoefs6;
    ResUCAffCoefs6: TN_AffCoefs6;
    PrevValPosition : Integer;
  end;

var
  K_FormCMSRotateByAngle: TK_FormCMSRotateByAngle;

function K_CMSRotateDlg( ) : Boolean;

implementation

uses Math,
  K_CLib0, K_SBuf, K_UDC,
  N_CompBase, N_Lib1, N_CMMain5F, N_CM1, K_CML1F;

{$R *.dfm}

function K_CMSRotateDlg( ) : Boolean;
var
  ImgViewConvData : TK_CMSImgViewConvData;
  WDIB : TN_DIBObj;
  WDIB1 : TN_DIBObj;
begin

  K_FormCMSRotateByAngle := TK_FormCMSRotateByAngle.Create(Application);
  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetMapImage, K_FormCMSRotateByAngle do
  begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

  // Save Annotations
    MeasureRoot := GetMeasureRoot();

    PrepROIView( [K_roiClearRefs] );
    K_SaveTreeToMem( MeasureRoot, N_SerialBuf, TRUE );


  // Save MapImage DIB
    SavedDIB := DIBObj;

  // Replace MapImage DIB by Copy
    NewDIB := TN_DIBObj.Create( SavedDIB );
    DIBObj := NewDIB;

   // Save Init size - needed for future ThumbFrame Rebuild
    IniSize  := GetMapRoot().PCCS().SRSize;

    SkipRebuild := TRUE;
    TBVal.Position := TBVal.Max shr 1;
    SkipRebuild := FALSE;
//    Result := (ShowModal() = mrOK);
    PrevValPosition := -1;
    K_CMRedrawObject.InitRedraw( RedrawImage );
    Result := (ShowModal() = mrOK) and (ResultingAngle <> 0);
    with P()^, GetCurrentImage do
    begin
      N_CM_MainForm.CMMCurFMainForm.Refresh();
      if Result then
      begin
        SavedDIB.Free;
      // Needed for ThumbFrame Rebuild
        GetMapRoot().PCCS().SRSize := IniSize;


       // Set New DIB to Current Image
        if CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );


        //Apply Flip/Rotate to Current
        GetImgViewConvData( @ImgViewConvData );
        ImgViewConvData.VCNegateFlag     := FALSE;
        ImgViewConvData.VCShowEmboss     := FALSE;
        ImgViewConvData.VCShowColorize   := FALSE;
        ImgViewConvData.VCShowIsodensity := FALSE;
        ImgViewConvData.VCCoFactor  := 0; // Image Contrast Correction Factor
        ImgViewConvData.VCGamFactor := 0; // Image Gamma Correction Factor
        ImgViewConvData.VCBriFactor := 0; // Image Brightness Correction Factor

        SavedDIB := nil;
        with DIBObj do
        begin
          if cmsfGreyScale in CMSDB.SFlags then
          begin
          // Current Image is Grey
            K_CMConvDIBBySlideViewConvData( SavedDIB, DIBObj,
                                            @ImgViewConvData, pf24bit, epfBMP );
            WDIB := nil;
          end
          else
          begin
          // Current Image is TrueColor
            K_CMConvDIBBySlideViewConvData( SavedDIB, DIBObj,
                                            @ImgViewConvData, DIBPixFmt, DIBExPixFmt );
            WDIB := DIBObj;
          end;
        end;

        SavedDIB.RotateByAngle( 0, ResultingAngle, $FFFFFF, WDIB,
                      @ResPixAffCoefs6, @ResUCAffCoefs6, K_CMImgMaxPixelsSize );
        CMSDB.PixWidth := WDIB.DIBSize.X;
        CMSDB.PixHeight := WDIB.DIBSize.Y;
        CMSDB.BytesSize := ((CMSDB.PixBits + 7) shr 3) * CMSDB.PixWidth * CMSDB.PixHeight;

        if cmsfGreyScale in CMSDB.SFlags then
        begin
          // Current Image is Grey - Convert wrk DIB to Grey
          with DIBObj do
            WDIB1 := TN_DIBObj.Create( WDIB, 0, DIBPixFmt, -1, DIBExPixFmt );
          WDIB.CalcGrayDIB( WDIB1 );
          DIBObj.Free;
          DIBObj := WDIB1;
          WDIB.Free;
        end;
        SavedDIB.Free;

        // Rotate Current
//        SavedDIB.RotateByAngle( 0, ResultingAngle, $FFFFFF, DIBObj, @ResPixAffCoefs6, @ResUCAffCoefs6 );

        // Clear Flip/Rotate in Map Attributes
        GetPMapRootAttrs()^.MRFlipRotateAttrs := 0;


        // Rebuild Map Image by new Current Image
        RebuildMapImageByDIB( DIBObj );

        // Rebuilding Annotations is needed
        // ...

        if CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
        PrepROIView( [K_roiRestoreIfImage] ); // may be not neede because always ResultingAngle <> 0
      end
      else
      begin
       // Cancel Changes
        N_Dump2Str( 'Cancel Rotate Changes' );
        K_LoadTreeFromMem0( MeasureRoot, N_SerialBuf, TRUE );
        with GetMapImage() do
        begin
          DIBObj.Free;
          DIBObj := SavedDIB;
        end;
        PrepROIView( [K_roiRestoreIfImage] );
       // Rebuild Slide View
        ShowWholeImage( );
//        RebuildMapRoot( );
      end;
    end;
    K_FormCMSRotateByAngle := nil;
  end;
end; // function K_CMSRotateDlg

procedure TK_FormCMSRotateByAngle.RedrawImage;
begin
  SkipRebuild := TRUE;
  PrevValPosition := TBVal.Position;
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSRotateByAngle.RedrawImage

procedure TK_FormCMSRotateByAngle.TBValChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame  do begin
    if (Sender <> nil) and
       ( SkipRebuild                        or
         (PrevValPosition = TBVal.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBVal)              and
         (csLButtonDown in TControl(Sender).ControlState)) ) then
      Exit;

    if K_CMSkipMouseMoveRedraw > 0 then
      K_CMRedrawObject.Redraw()
    else
      RedrawImage();
{
    SkipRebuild := TRUE;
    PrevValPosition := TBVal.Position;
    Timer.Enabled := TRUE;
}
  end;
end; // procedure TK_FormCMSRotateByAngle.TBValChange

procedure TK_FormCMSRotateByAngle.TimerTimer(Sender: TObject);
var
  Base : Integer;
  PrevOffsFree : Integer;
begin
  Timer.Enabled := FALSE;
  with N_CM_MainForm, CMMFActiveEdFrame  do begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    Base := TBVal.Max shr 1;
    ResultingAngle := (TBVal.Position - Base) / Base * 45;

    N_Dump2Str( 'Rotate SLide ' + IntToStr(SavedDIB.DIBInfo.bmi.biWidth) +
     'x' + IntToStr(SavedDIB.DIBInfo.bmi.biHeight) + ' by ' + FloatToStr(ResultingAngle) );

  //  Rotate By angle
//    SavedDIB.RotateByAngle( 0, ResultingAngle, $FFFFFF, NewDIB, ResultingAffCoefs6 );
    SavedDIB.RotateByAngle( 0, ResultingAngle, RFrame.DstBackColor, NewDIB,
                      @ResPixAffCoefs6, @ResUCAffCoefs6, K_CMImgMaxPixelsSize );

  // Restore Annotations
    PrevOffsFree := N_SerialBuf.OfsFree;
    K_LoadTreeFromMem0( MeasureRoot, N_SerialBuf, TRUE );
    N_SerialBuf.OfsFree := PrevOffsFree;
    EdSlide.PrepROIView( [K_roiRestoreIfImage] );

  // Rebuild Slide View
//    with N_CM_MainForm.CMMFActiveEdFrame do begin
    EdSlide.AffConvVObjects6( ResUCAffCoefs6, ResultingAngle, RFrame.RFVectorScale );
//    AffConvVObjs6( ResUCAffCoefs6, ResultingAngle );
    ShowWholeImage( );
//      RebuildMapRoot( );
//      RFrame.RedrawAllAndShow();
//    end;

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );

    SkipRebuild := FALSE;

    // Check Memory Free Space
    K_CMSCheckMemFreeSpaceDlg( K_CML1Form.LLLFinishActionAndRestart.Caption );
//      'Please finish this action and restart CMS.' );

  end;
end; // procedure TK_FormCMSRotateByAngle.TimerTimer

end.
