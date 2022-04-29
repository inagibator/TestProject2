unit N_CMRFA;
// CMS RFrame Actions: TN_CMFlashLightRFA

interface
uses Windows, Classes, SysUtils,
  N_Types, N_Gra0, N_Rast1Fr, N_CompBase, N_GCont;

type TN_CMFlashLightObj = class( TObject ) // Global Object for CM FlashLight
  FLORFrame: TN_Rast1Frame;

  procedure SetActParams ();
end; // type TN_CMFlashLightObj = class( TN_RFrameAction )


type TN_CMFlashLightRFA = class( TN_RFrameAction ) // CMFlashLightRFrame Action
  CMFLComp: TN_UDCompVis;

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_CMFlashLightRFA = class( TN_RFrameAction )


implementation
uses
  N_Gra1, N_Gra2, N_CompCL;

//****************  TN_CMFlashLightObj class methods  *****************

//***************************************** TN_CMFlashLightObj.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_CMFlashLightObj.SetActParams();
begin

end; // procedure TN_CMFlashLightObj.SetActParams();


//****************  TN_CMFlashLightRFA class methods  *****************

//***************************************** TN_CMFlashLightRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_CMFlashLightRFA.SetActParams();
begin
  ActName := 'CMFlashLight';

  inherited;
end; // procedure TN_CMFlashLightRFA.SetActParams();

//********************************************** TN_CMFlashLightRFA.Execute ***
// Move FlashLight Component
//
procedure TN_CMFlashLightRFA.Execute();
begin
  with ActGroup.RFrame do
  begin
//    N_Dump1Str( Format( 'FL %s, x,y=%d,%d', [RFDebName,CCBuf.X,CCBuf.Y] ));
{
var
  TmpRect: TRect;
    StartAnimPhase1();
    TmpRect := N_RectMake( CCBuf, Point(20,20), N_05DPoint );
    OCanv.DrawPixFilledRect2( TmpRect, $FF );
    FinAnimPhase1();
}
   if CMFLComp <> nil then
   begin
     with CMFLComp.PCCS()^ do
     begin
       BPCoords.X := CCUser.X;
       BPCoords.Y := CCUser.Y;
//       N_Dump1Str( Format( 'CCUser x,y=%.1f,%.1f', [CCUser.X,CCUser.Y] ));

       RedrawAllAndShow();
//       RedrawAll();  // for debug
     end;
   end; // if CMFLComp <> nil then

  end; // with ActGroup.RFrame do
end; // procedure TN_CMFlashLightRFA.Execute

//***************************************** TN_CMFlashLightRFA.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TN_CMFlashLightRFA.RedrawAction();
begin
{
  with N_ActiveRFrame do
  begin
    OCanv.SetBrushAttribs( -1 );
    OCanv.SetPenAttribs( $999999, 1 );
//    OCanv.DrawUserRect( SRSelectionFRect );
    N_TestRectDraw( OCanv, 10, 20, $FF );
  end; // with N_ActiveRFrame, SRCMREdit2Form do
}
end; // procedure TN_CMFlashLightRFA.RedrawAction

Initialization

N_RFAClassRefs[N_ActCMFlashLight] := TN_CMFlashLightRFA;

end.
