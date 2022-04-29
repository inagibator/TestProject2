unit K_CMTests;
//CMS Debug Code

interface


procedure K_CMTRebuildAndRedrawSlideAnnots( ACount : Integer );

implementation

uses Windows, SysUtils, Forms, Controls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2, N_Gra0, N_Gra1, N_CMREd3Fr, N_CMMain5F,
  K_CM0, K_UDT1, K_UDC, K_SBuf;

procedure K_CMTRebuildAndRedrawSlideAnnots( ACount : Integer );
var
  MeasureRoot : TN_UDBase;
  PrevOffsFree : Integer;
  i : Integer;
  SavedCursor : TCursor;
begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  Assert( N_CM_MainForm.CMMFActiveEdFrame.EdSlide <> nil, '==nil!' );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide do begin
//    ChangeSelectedVObj( 0 );
    PrepROIView( [K_roiClearRefs] );
    MeasureRoot := GetMeasureRoot();
    K_SaveTreeToMem( MeasureRoot, N_SerialBuf, TRUE );

    for i := 1 to ACount do begin
    // Restore Annotations
      PrevOffsFree := N_SerialBuf.OfsFree;
      K_LoadTreeFromMem0( MeasureRoot, N_SerialBuf, TRUE );
      N_SerialBuf.OfsFree := PrevOffsFree;
      EdSlide.PrepROIView( [K_roiRestoreIfImage] );

    // Rebuild Slide View
      ShowWholeImage( );
      CMMFShowString( Format( 'i=%d', [i] ) );
//      StatusBar.Panels[1].Text := Format( 'i=%d', [i] );
//      Application.ProcessMessages();
    end;
    RebuildVObjsSearchList( );
  end;

  Screen.Cursor := SavedCursor;

end;

end.
