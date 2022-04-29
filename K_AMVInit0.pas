unit K_AMVInit0;

interface

implementation

uses Forms,
  K_CLib, K_FrRAEdit, N_ClassRef, K_FRAEdit, K_MVMap0, K_MVObjs, K_IndGlobal,
  K_RAEdit;

Initialization

// K_RAEdit
  K_RegRAFEditor( 'RAFUDCSProj', TK_RAFUDCSProjEditor );
  K_RegRAFEditor( 'RAFUDCSProj1', TK_RAFUDCSProjEditor1 );

// K_IndGlobal

  K_ClearRAEditFuncCont( @K_UDRACPEditCont );
  with K_UDRACPEditCont do begin
    FSetModeFlags := [K_ramFillFrameWidth,K_ramShowLRowNumbers,
      K_ramRowChangeOrder,K_ramUseFillColor,K_ramRowChangeNum,
      K_ramRowAutoChangeNum];
  end;

  K_ClearRAEditFuncCont( @K_UDRAWDEditCont );
  with K_UDRAWDEditCont do begin
    FSetModeFlags := [K_ramFillFrameWidth,K_ramUseFillColor];
  end;


  K_ClearRAEditFuncCont( @K_UDVectorEditCont.RAEDFC );
  with K_UDVectorEditCont do begin
    FFDClassName := 'TK_FormUDVTabUni';
    FFTClassName := 'TK_TypeUDVTabUni';
    FTargetCSS := nil;
  end;

  K_ClearRAEditFuncCont( @K_UDVHTMFileRefEditCont.RAEDFC );
  with K_UDVHTMFileRefEditCont do begin
    FFDClassName := 'TK_HTMRefForm';
    FFTClassName := '';
    FTargetCSS := nil;
  end;


  K_RegGEFunc( 'TK_UDVector', K_EditUDVectorFunc, @K_UDVectorEditCont );
  K_RegGEFunc( 'TK_UDVector1', K_EditUDVectorFunc, @K_UDVectorEditCont );
  K_RegGEFunc( 'Color:TK_UDRArray', K_EditUDRAFunc0, @K_UDRACPEditCont );
  K_RegGEFunc( 'TK_MVWebWindow:TK_UDRArray', K_EditUDRAFunc0, @K_UDRAWDEditCont );
  K_RegGEFunc( 'TK_UDMVWVTreeWin', K_EditUDRAFunc0, @K_UDRAWSWEditCont );
  K_RegGEFunc( 'TK_UDMVWVHTMWin', K_EditUDRAFunc0, @K_UDRAWSWEditCont );
  K_RegGEFunc( 'TK_DSSVector', K_EditDSSVectorFunc, @K_UDVectorEditCont );
  K_RegGEFunc( 'TK_VHTMRefVector', K_EditDSSVectorFunc, @K_UDVHTMFileRefEditCont );

// K_MVObjs
  N_ClassRefArray[K_UDMVFolderCI]  := TK_UDMVFolder;
  N_ClassTagArray[K_UDMVFolderCI]  := 'MVFolder';

  N_ClassRefArray[K_UDMVVectorCI]  := TK_UDMVVector;
  N_ClassTagArray[K_UDMVVectorCI]  := 'MVVector';

  N_ClassRefArray[K_UDMVTableCI]  := TK_UDMVTable;
  N_ClassTagArray[K_UDMVTableCI]  := 'MVTable';

  N_ClassRefArray[K_UDMVWFolderCI]  := TK_UDMVWFolder;
  N_ClassTagArray[K_UDMVWFolderCI]  := 'MVWFolder';

  N_ClassRefArray[K_UDMVWVTreeWinCI]  := TK_UDMVWVTreeWin;
  N_ClassTagArray[K_UDMVWVTreeWinCI]  := 'MVWVTreeWin';

  N_ClassRefArray[K_UDMVWLDiagramWinCI]  := TK_UDMVWLDiagramWin;
  N_ClassTagArray[K_UDMVWLDiagramWinCI]  := 'MVWLDiagramWin';

  N_ClassRefArray[K_UDMVWTableWinCI]  := TK_UDMVWTableWin;
  N_ClassTagArray[K_UDMVWTableWinCI]  := 'MVWTableWin';

  N_ClassRefArray[K_UDMVWWinGroupCI]  := TK_UDMVWWinGroup;
  N_ClassTagArray[K_UDMVWWinGroupCI]  := 'MVWWinGroup';

  N_ClassRefArray[K_UDMVWHTMWinCI]  := TK_UDMVWHTMWin;
  N_ClassTagArray[K_UDMVWHTMWinCI]  := 'MVWHTMWin';

  N_ClassRefArray[K_UDMVWVHTMWinCI]  := TK_UDMVWVHTMWin;
  N_ClassTagArray[K_UDMVWVHTMWinCI]  := 'MVWVHTMWin';

  N_ClassRefArray[K_UDMVWSiteCI]  := TK_UDMVWSite;
  N_ClassTagArray[K_UDMVWSiteCI]  := 'MVWSite';

  N_ClassRefArray[K_UDMVVWFrameSetCI]  := TK_UDMVVWFrameSet;
  N_ClassTagArray[K_UDMVVWFrameSetCI]  := 'MVVWFrameSet';

  N_ClassRefArray[K_UDMVVWLayoutCI]  := TK_UDMVVWLayout;
  N_ClassTagArray[K_UDMVVWLayoutCI]  := 'MVVWLayout';

  N_ClassRefArray[K_UDMVVWindowCI]  := TK_UDMVVWindow;
  N_ClassTagArray[K_UDMVVWindowCI]  := 'MVVWindow';

  N_ClassRefArray[K_UDMVVWFrameCI]  := TK_UDMVVWFrame;
  N_ClassTagArray[K_UDMVVWFrameCI]  := 'MVVWFrame';

  N_ClassRefArray[K_UDMVVWFrameSetCI]  := TK_UDMVVWFrameSet;
  N_ClassTagArray[K_UDMVVWFrameSetCI]  := 'MVVWFrameSet';

  N_ClassRefArray[K_UDMVCorPictCI]  := TK_UDMVCorPict;
  N_ClassTagArray[K_UDMVCorPictCI]  := 'MVCorPict';


  K_RegRAFViewer( 'RAFMVTabViewer',  TK_RAFMVTabViewer );

  K_RegRAFEditor( 'RAFMVTabEditor', TK_RAFMVTabEditor );

  K_RegRAFEditor( 'RAFMVVWinNameEditor', TK_RAMVVWinNameEditor );


  K_RegRAFrDescription( 'WWList:TN_UDBase', 'TK_WWListUDBasesForm' );
//  K_RegRAFrDescription( 'arrayof TK_MVWebScript1', 'TK_MVWebScriptsForm' );
//  K_RegRAFrDescription( 'UDCSProjection', 'TK_UDCSProjForm' );
//  K_RegRAFrDescription( 'HTMFileName', 'TK_HTMRefForm' );

  K_RegRAFEditor( 'RAFMVCorPictUDMVVectorEditor', TK_RAFMVCorPictUDMVVectorEditor );

// K_MVMap0
  N_ClassRefArray[K_UDMVMapDescrCI]  := TK_UDMVMapDescr;
  N_ClassTagArray[K_UDMVMapDescrCI]  := 'MVMapDescr';

  N_ClassRefArray[K_UDMVMLDColorFillCI]  := TK_UDMVMLDColorFill;
  N_ClassTagArray[K_UDMVMLDColorFillCI]  := 'MVMLDColorFill';

  N_ClassRefArray[K_UDMVWCartWinCI]  := TK_UDMVWCartWin;
  N_ClassTagArray[K_UDMVWCartWinCI]  := 'MVWCartWin';

  N_ClassRefArray[K_UDMVWCartGroupWinCI]  := TK_UDMVWCartGroupWin;
  N_ClassTagArray[K_UDMVWCartGroupWinCI]  := 'MVWCartGroupWin';

  N_ClassRefArray[K_UDMVWCartLayerCI]  := TK_UDMVWCartLayer;
  N_ClassTagArray[K_UDMVWCartLayerCI]  := 'MVWCartLayer';

// K_FRAEdit
  K_RAListEditCont.FOwner := nil;
//  K_RAListEditCont.FModeFlags := [K_ramColChangeNum];
  K_RegGEFunc( 'arrayof TK_RAList', K_EditRAListFunc, Pointer(@K_RAListEditCont) );

Finalization

end.
