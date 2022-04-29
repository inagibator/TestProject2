unit N_ExpF;
// Map Editor Export Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, ActnList, OleCtrls, SHDocVw, ToolWin,
  ExtCtrls,
  N_Types, N_BaseF, N_Gra0, N_Gra1, N_UDat4, N_FNameFr, // N_MapEdMF,
  N_PlainEdF, N_UObjFr;

type TN_ExportForm = class( TN_BaseForm )
    frMain: TN_FileNameFrame;
    frAux: TN_FileNameFrame;
    MainMenu1: TMainMenu;
    mmShape: TMenuItem;
    ShapeToASCII1: TMenuItem;
    mmTDB: TMenuItem;
    mmKRLB: TMenuItem;
    mmHTML: TMenuItem;
    Data1: TMenuItem;
    mmTools: TMenuItem;
    PageControl: TPageControl;
    tsShape: TTabSheet;
    bnConvertShapeToASCII: TButton;
    tsTDB: TTabSheet;
    Label2: TLabel;
    Label5: TLabel;
    mbTDBTableName: TComboBox;
    mbDataVectorName: TComboBox;
    tsKRLB: TTabSheet;
    tsHTML: TTabSheet;
    ActionList1: TActionList;
    actToHTMLMap: TAction;
    oHTMLMap1: TMenuItem;
    frExpFN1: TN_FileNameFrame;
    frExpFN2: TN_FileNameFrame;
    frExpFN3: TN_FileNameFrame;
    StatusBar: TStatusBar;
    actExpKrlbLines: TAction;
    ExportLines1: TMenuItem;
    actExpShpPoints: TAction;
    actExpShpLines: TAction;
    actExpShpPolygons: TAction;
    ExportLines2: TMenuItem;
    ExportPolygons1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    mmSVG: TMenuItem;
    aSVGTest1: TAction;
    aSVGTest2: TAction;
    SVGTest11: TMenuItem;
    SVGTest21: TMenuItem;
    tsSVG: TTabSheet;
    aSVGExportMap: TAction;
    aSVGExportLayer: TAction;
    ExportMaptoSVG1: TMenuItem;
    ExportLayertoSVG1: TMenuItem;
    aViewMainFile: TAction;
    aViewAuxFile: TAction;
    ViewMainFile1: TMenuItem;
    ViewAuxFile1: TMenuItem;
    aSVGExportMapToJS: TAction;
    aSVGExportMapToJavaScript1: TMenuItem;
    rgFileType: TRadioGroup;
    mbEncoding: TComboBox;
    Label3: TLabel;
    edAccuracy: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    edWidth: TEdit;
    aSVGExportVCTree: TAction;
    aSVGExportToText: TAction;
    N1: TMenuItem;
    ExportVCTreetoSVG1: TMenuItem;
    ExportVCTreeToText1: TMenuItem;
    N2: TMenuItem;
    tsOther: TTabSheet;
    frMapUObj: TN_UObjFrame;
    lMapUObj: TLabel;
    frCObjName: TN_UObjFrame;
    Label10: TLabel;
    Label11: TLabel;
    frCObjPath: TN_UObjFrame;

    //********* Prepare Functions *****************
    function  SetMainFileNameW (): boolean;
    function  SetCObjR  ( AClassInd: integer ): boolean;

    //********* Shape actions *****************
    procedure actExpShpPointsExecute   ( Sender: TObject );
    procedure actExpShpLinesExecute    ( Sender: TObject );
    procedure actExpShpPolygonsExecute ( Sender: TObject );

    //********* TDB actions *****************

    //********* KRLB actions *****************
    procedure actExpKrlbLinesExecute ( Sender: TObject );

    //********* HTML actions *****************
    procedure actToHTMLMapExecute ( Sender: TObject );

    //********* SVG actions *****************
    procedure aSVGExportMapExecute     ( Sender: TObject );
    procedure aSVGExportLayerExecute   ( Sender: TObject );
    procedure aSVGExportMapToJSExecute ( Sender: TObject );
    procedure aSVGExportVCTreeExecute  ( Sender: TObject );
    procedure aSVGExportToTextExecute  ( Sender: TObject );
    procedure aSVGTest1Execute ( Sender: TObject );
    procedure aSVGTest2Execute ( Sender: TObject );

    //********* Data actions *****************
    //********* Tools actions *****************
    procedure aViewMainFileExecute ( Sender: TObject );
    procedure aViewAuxFileExecute  ( Sender: TObject );

      //*** five standard ComboBox event handlers
    procedure AddTextToItems  ( Sender: TObject; var Key: Word;
                                                    Shift: TShiftState );
    procedure mbUObjCloseUp   ( Sender: TObject );
    procedure mbUObjDblClick  ( Sender: TObject );
    procedure mbUObjDropDown  ( Sender: TObject );
    procedure mbUObjKeyDown   ( Sender: TObject; var Key: Word;
                                                    Shift: TShiftState );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
//    ME: TN_MapEditMainForm; // temporary, delete later
  public
    FNameAux: string;  // set by SetAuxFileNameR
    FNameMain: string; // these fields are set by SetNamesW, SetNamesR
    CObjName: string;  // for reduce code size only
    CObj:      TN_UCObjLayer;
    URefs:     TN_UCObjRefs;
    UPoints:   TN_UDPoints;
    ULines:    TN_ULines;
    UContours: TN_UContours;
    procedure CurArchiveChanged (); override;
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_ExportForm = class( TN_BaseForm )

function N_GetExportForm( AOwner: TN_BaseForm ): TN_ExportForm;

var
  N_ExportForm: TN_ExportForm;

implementation
uses ZLib,
     K_UDT1, K_Script1, K_CLib,  
     N_ClassRef, N_ExpImp1, N_Lib1, N_Lib2, N_Gra2, N_AffC4F, N_ButtonsF,
     N_InfoF, N_Gra3, N_LibF, N_ME1, N_UDCMap, N_WebBrF, N_CompBase;
{$R *.dfm}

    //********* Prepare Functions *****************

function TN_ExportForm.SetMainFileNameW(): boolean;
// prompt for overriting if Main File Name exists and set it to FNameMain variable
// (prepare for Writing to Main File Name)
// return True if FileName is not exists or can be overwritten
begin
  Result := False;
  FNameMain := frMain.mbFileName.Text;
  if FNameMain = '' then
  begin
    N_Show1Str( 'File Name is not defined!' );
    Exit;
  end;

{ // Overwrite Dialog will be called later in SaveUObj to File procedures?
  if not N_ConfirmOverwriteDlg( FNameMain ) then
  begin
    N_Show1Str( 'Operation cancelled!' );
    Exit;
  end;
}
  N_AddTextToTop( frMain.mbFileName, frMain.MaxListSize );

  Result := True;
end; // function TN_ExportForm.SetMainFileNameW

function TN_ExportForm.SetCObjR( AClassInd: integer ): boolean;
// get CObj of given or any type ("open for Reading"),
// assign it to ULines, UPoints, UContours and return True if CObj is OK
//
// AClassInd = -2  means that CObj may be nil
// AClassInd = -1  means that CObj <> nil of any type is OK
// AClassInd >= 0  means that CObj.CI = AClassInd
//
begin
  Result := False;
  N_b := Result; // to avoid warning
{
  CObjName := frCObjName.mb.Text;

  if CObjName = '' then
  begin
    N_Show1Str( 'CObj Name is not defined!' );
    Exit;
  end;

  UPoints   := nil;
  ULines    := nil;
  UContours := nil;

  CObj := N_GetCObjR( CObjName, -1 ); // CObj of any type is OK
  N_AddTextToTop( frCObjName.mb, frCObjName.MaxListSize );
}

  CObj := frCObjName.GetCObjR( -1 ); // CObj of any type is OK
  if CObj.CI = N_UDPointsCI  then UPoints   := TN_UDPoints(CObj);
  if CObj.CI = N_ULinesCI    then ULines    := TN_ULines(CObj);
  if CObj.CI = N_UContoursCI then UContours := TN_UContours(CObj);

  Result := True;
end; // function TN_ExportForm.SetCObjR


    //********* Shape actions *****************

procedure TN_ExportForm.actExpShpPointsExecute( Sender: TObject );
// Export Points to Shape file
begin
  if not SetMainFileNameW() then Exit;
  if not SetCObjR( N_UDPointsCI ) then Exit;

  N_UDPointsToShape( UPoints, FNameMain, N_MEGlobObj.ImpAffCoefs4 );
  N_Show1Str( 'Shape file created OK: "' + FNameMain + '"' );
end; // procedure TN_ExportForm.actExpShpPointsExecute

procedure TN_ExportForm.actExpShpLinesExecute( Sender: TObject );
// Export Lines to Shape file
begin
  if not SetMainFileNameW() then Exit;
  if not SetCObjR( N_ULinesCI ) then Exit;

//  N_ULinesToShape( ULines, FNameMain, N_MEGlobObj.ImpAffCoefs4 );
  N_Show1Str( 'Shape file created OK: "' + FNameMain + '"' );

//  try
//  N_MEExpShapeLines( ME, frMain.GetFileName(), frCObjName.mb.Text );
//  except on E1: Exception do N_MEException( ME, E1 );
//  end; // try
end; // procedure TN_ExportForm.actExpShpLinesExecute

procedure TN_ExportForm.actExpShpPolygonsExecute( Sender: TObject );
// Export Contours to Shape Polygons file
begin
//  try
//  N_MEExpShapePolygons( ME, frMain.GetFileName(), frCObjName.mb.Text );
//  except on E1: Exception do N_MEException( ME, E1 );
//  end; // try
end; // procedure TN_ExportForm.actExpShpPolygonsExecute


    //********* KRLB actions *****************

procedure TN_ExportForm.actExpKrlbLinesExecute( Sender: TObject );
// Export Lines to KRLB and DAT files
begin
//  try
//  N_MEExpKRLBLines( ME, frMain.GetFileName(),
//                        frAux.GetFileName(), frCObjName.mb.Text );
//  except on E1: Exception do N_MEException( ME, E1 );
//  end; // try
end; // procedure TN_ExportForm.actExpKrlbLinesExecute


    //********* HTML actions *****************

procedure TN_ExportForm.actToHTMLMapExecute( Sender: TObject );
// export to HTML Map format
// not implemented by new CObjects!!!
begin
{
var
  i, j, MaxInd: integer;
  Str, pat: string;
  SLM, SL1, SLPat, SLMacro: TStringList;
  Cont: TN_UDDContour;
  ContsDir: TN_UDBase;
begin
  SLM := TStringList.Create;
  SL1 := TStringList.Create;
  SLPat := TStringList.Create;
  SLMacro := TStringList.Create;

  pat:= 'HREF="javascript:ShowData((#NN#));" ALT="(#NAME#)" onMouseOver="ShowName((#NN#))" onMouseOut="ShowName()">';

  SLPat.Add( Pat );
  SLMacro.Add( 'NN=0' );
  SLMacro.Add( 'Name=N' );

  SL1.LoadFromFile( frExpFN1.mbFileName.Text );
  SLM.AddStrings( SL1 );

//  ContsDir := N_GetUObjByPath( ME.Layers, frCObjName.mb.Text );
  ContsDir := nil; // tmp!
  MaxInd := ContsDir.DirHigh();

  for i := 0 to MaxInd do
  begin
    Cont := TN_UDDContour(ContsDir.DirChild(i));
    if Cont = nil then Continue;
    Cont.MakeRCoords;
    for j := 0 to High(Cont.CRings) do
    begin
      Str := '<AREA SHAPE=POLY COORDS="';
      Str := Str + N_DPArrayToStr( Cont.CRings[j].RCoords, '%.0f,%.0f,' );
      Str[Length(Str)] := '"';
      SLM.Add( Str );

      SLPat.Strings[0] := pat;
      SLMacro.Strings[0] := 'NN='+IntToStr(Cont.CObjCode-1);
      SLMacro.Strings[1] := 'Name='+Cont.ObjName;
      K_SListMacroReplace( SLPat, SLMacro );
      SLM.AddStrings( SLPat );
    end;
  end;

  SL1.LoadFromFile( frExpFN3.mbFileName.Text );
  SLM.AddStrings( SL1 );

  SLM.SaveToFile( frMain.mbFileName.Text );

  StatusBar.SimpleText := 'Created OK';
}
end; // procedure TN_ExportForm.actToHTMLMapExecute


    //********* SVG actions *****************

procedure TN_ExportForm.aSVGExportMapExecute( Sender: TObject );
// Export Map (frMapName.mb.Text) to SVG file (frMain.GetFileName())
// and show exported SVG file in browser
begin
{
var
  SrcMap: TN_UDCompVis;
  WBForm: TN_WebBrowserForm;
  SVGEP: TN_SVGExportParams;
begin
  try
  if not SetMainFileNameW then Exit; // set FNameMain by frMain.GetFileName()

  SrcMap := TN_UDCompVis(N_GetUObj( N_MapsDir, frMapName.mb.Text ));
  if SrcMap = nil then
  begin
    N_Show1Str( 'Map "' + frMapName.mb.Text + '" not found!' );
    Exit;
  end;

  FillChar( SVGEP, Sizeof(SVGEP), 0 );
  with SVGEP do
  begin
    Accuracy := StrToInt( edAccuracy.Text );
    WidthInLLW := StrToFloat( edWidth.Text );
    Encoding := mbEncoding.Text;
  end;

  N_ExportMapToSVG ( FNameMain, SrcMap, @SVGEP );
  N_Show1Str( 'SVG file Exported OK to ' + FNameMain );

  WBForm := N_CreateWebBrowserForm( Self );
  N_SetFormPos( WBForm, Rect(10,90,400,400) );
  WBForm.Show();
  WBForm.WebBrowser.Navigate( FNameMain );
  except end;
}
end; // procedure TN_ExportForm.aSVGExportMapExecute

procedure TN_ExportForm.aSVGExportLayerExecute( Sender: TObject );
// Export Layer (frCObjName.mb.Text) to SVG file (frMain.GetFileName())
// and show exported SVG file in browser
begin
{
var
  SrcMap: TN_UDCMap;
  WBForm: TN_WebBrowserForm;
  SVGEP: TN_SVGExportParams;
begin
  try
  if not SetMainFileNameW then Exit; // set FNameMain by frMain.GetFileName()
  if not SetCObjR(-1) then Exit;     // set CObj
//  SrcMap := N_CreateUDCMap( CObj );  // create temporary Map with one Layer
  SrcMap := nil; // temporary, change to UDPanel!

  FillChar( SVGEP, Sizeof(SVGEP), 0 );
  with SVGEP do
  begin
    Accuracy := StrToInt( edAccuracy.Text );
    WidthInLLW := StrToFloat( edWidth.Text );
    Encoding := mbEncoding.Text;
  end;
//!!  N_ExportMapToSVG ( FNameMain, SrcMap, @SVGEP );
  N_Show1Str( 'SVG file Exported OK to ' + FNameMain );

  WBForm := N_CreateWebBrowserForm( Self );
  N_SetFormPos( WBForm, Rect(10,90,400,400) );
  WBForm.Show();
  WBForm.WebBrowser.Navigate( FNameMain );
  SrcMap.Free();
  except end;
}
end; // procedure TN_ExportForm.aSVGExportLayerExecute

procedure TN_ExportForm.aSVGExportMapToJSExecute( Sender: TObject );
// Export Map (frMapName.mb.Text) to Java Script in SVG or HTML file (frMain.GetFileName())
begin
{
var
  Mode: integer;
//  Str: string;
//  PixSize: TPoint;
  SrcMap: TN_UDCMap;
begin
  try
  if not SetMainFileNameW then Exit;

  SrcMap := TN_UDCMap(N_GetUObj( N_MapsDir, frMapName.mb.Text ));
  if SrcMap = nil then
  begin
    N_Show1Str( 'Map "' + frMapName.mb.Text + '" not found!' );
    Exit;
  end;

//  Str := mbSVGPixWidthHeight.Text;
//  PixSize := N_ScanIPoint( Str );
  Mode := 0;
  if rgFileType.ItemIndex = 1 then Mode := Mode or $01;
  N_ExportMapToJS( FNameMain, SrcMap, Mode );
  N_Show1Str( 'Java Script Exported OK to ' + FNameMain );
  except end;
}
end; // procedure TN_ExportForm.aSVGExportMapToJSExecute

procedure TN_ExportForm.aSVGExportVCTreeExecute( Sender: TObject );
// Export VCTree To SVG file
begin
//  inherited;

end; // procedure TN_ExportForm.aSVGExportVCTreeExecute

procedure TN_ExportForm.aSVGExportToTextExecute( Sender: TObject );
// Export VCTree To Text file
begin
{
var
  GlobCont: TK_CSPLCont;
begin
  GlobCont := TK_CSPLCont.Create;
  with GlobCont do
  begin

  Inc( RefCount );
  RootComp := frMapName.SetUObj();
  if RootComp = nil then Exit;

  TK_UDComponent(RootComp).CompIntPixRect := Rect( 0, 0, 100, 100 ); // is needed?

  OCanvas := TN_OCanvas.Create;

  DrawTarget := dtText;

  with DrawContext do
  begin
    RezSL := TStringList.Create;
    RezSL.Add( 'Map=' + RootComp.ObjName );
  end;

  StartCompTree();

  with DrawContext do
  begin
    RezSL.Add( 'End of Map=' + RootComp.ObjName );
    RezSL.SaveToFile( frMain.GetFileName() );
    RezSL.Free;
  end;

  Destroy;
  end; // with GlobCont do
}
end; // procedure TN_ExportForm.aSVGExportToTextExecute

procedure TN_ExportForm.aSVGTest1Execute( Sender: TObject );
// SVG Test1
begin
{
var
  FName: string;
  SL: TStringList;
  Map: TN_UDCMap;
  MapToSVG: TN_MapToSVG;
  WBForm: TN_WebBrowserForm;
begin
  SL := TStringList.Create();
  Map := TN_UDCMap(N_GetUObj( N_MapsDir, frMapName.mb.Text ));
  MapToSVG := TN_MapToSVG.Create();

//  MapToSVG.ExportToSL( SL, Map, 800, 2, 0  );
  FName := frMain.GetFileName();
  SL.SaveToFile( FName );
  N_Show1Str( 'SVG file Exported OK to ' + FName );
  SL.Free();
  MapToSVG.Free();

  WBForm := N_CreateWebBrowserForm( Self );
  N_SetFormPos( WBForm, Rect(10,90,400,400) );
  WBForm.Show();
  WBForm.WebBrowser.Navigate( FName );
}  
end;

procedure TN_ExportForm.aSVGTest2Execute( Sender: TObject );
// SVG Test2
begin
//  inherited;

end;

    //********* Tools actions *****************

procedure TN_ExportForm.aViewMainFileExecute( Sender: TObject );
// View Main File as Text or as Picture
begin
  frMain.aViewByExtensionExecute( nil );
end; // procedure TN_ExportForm.aViewMainFileExecute

procedure TN_ExportForm.aViewAuxFileExecute( Sender: TObject );
// View Aux File as Text or as Picture
begin
  frAux.aViewByExtensionExecute( nil );
end; // procedure TN_ExportForm.aViewAuxFileExecute


//*** five standard ComboBox event handlers

procedure TN_ExportForm.AddTextToItems( Sender: TObject;
                                       var Key: Word; Shift: TShiftState);
// add Text field to Items by Enter (to be able to use it again)
begin
  N_MBKeyDownHandler1( Sender, Key, Shift );
end; // procedure TN_ExportForm.AddTextToItems

procedure TN_ExportForm.mbUObjCloseUp( Sender: TObject );
// save Item index in decimal digits #2,3 of Tag field (for mbUObjOnKeyDown)
begin
//!!  ME.mbUObjCloseUp( Sender );
end; // procedure TN_ExportForm.mbUObjCloseUp

procedure TN_ExportForm.mbUObjDblClick( Sender: TObject );
// show modal form to perform some actions on TComboBox(Sender) type objects
begin
//!!  ME.mbUObjDblClick( Sender );
end; // procedure TN_ExportForm.mbUObjDblClick

procedure TN_ExportForm.mbUObjDropDown( Sender: TObject );
// Add UObj Names to TComboBox(Sender).Items (fill it's DropDown list)
begin
//!!  ME.mbUObjDropDown( Sender );
end; // procedure TN_ExportForm.mbUObjDropDown

procedure TN_ExportForm.mbUObjKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
// perform several functions for TComboBox(Sender) type objects
begin
//!!  ME.mbUObjKeyDown( Sender, Key, Shift );
end; // procedure TN_ExportForm.mbUObjKeyDown

procedure TN_ExportForm.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
  N_ExportForm := nil;
end; // procedure TN_ExportForm.FormClose


          //************* Public methods ******************

//***********************************  TN_ExportForm.CurArchiveChanged  ******
// Update all needed Self fields after current Archive was changed
//
procedure TN_ExportForm.CurArchiveChanged();
begin
  N_GlobUOFrInitOwnerForm := Self;      // used in UOFrInit
  N_GlobUOFrInitStatusbar := StatusBar; // used in UOFrInit

  N_MapEditorDir := K_CurArchive.DirChildByObjName( 'RusFOM' ); // temporary, for RusFOM job

  frCObjPath.UOFrInit( N_MapEditorDir, TN_UDBase );
  frCObjName.UOFrInit( N_MapEditorDir, TN_UCObjLayer, frCObjPath.mb );
  frMapUObj.UOFrInit(  N_MapEditorDir, TN_UDBase );

  N_GlobUOFrInitOwnerForm := nil;      // a precaution
  N_GlobUOFrInitStatusbar := nil;      // a precaution
end; // end of procedure TN_ExportForm.CurArchiveChanged

//***********************************  TN_ExportForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_ExportForm.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'N_MapEdExpF_frCObjName',       frCObjName.mb );
  N_ComboBoxToMemIni( 'N_MapEdExpF_frCObjPath',       frCObjPath.mb );
  N_ComboBoxToMemIni( 'N_MapEdExpF_frMapUObj',        frMapUObj.mb  );

//  frMain.UpdateMemIniFile();
//  frAux.UpdateMemIniFile();
  N_ComboBoxToMemIni( 'N_MapEdExpF_frMain',  frMain.mbFileName );
  N_ComboBoxToMemIni( 'N_MapEdExpF_frAux',   frAux.mbFileName );

  //***** HTML TabSheet
//  frExpFN1.UpdateMemIniFile();
//  frExpFN2.UpdateMemIniFile();
//  frExpFN3.UpdateMemIniFile();
  N_ComboBoxToMemIni( 'N_MapEdExpF_frExpFN1',  frExpFN1.mbFileName );
  N_ComboBoxToMemIni( 'N_MapEdExpF_frExpFN2',  frExpFN2.mbFileName );
  N_ComboBoxToMemIni( 'N_MapEdExpF_frExpFN3',  frExpFN3.mbFileName );

  //***** SVG TabSheet
  N_IntToMemIni( 'N_MapEdExpF', 'rgFileType', rgFileType.ItemIndex );
  N_StringToMemIni( 'N_MapEdExpF', 'mbEncoding', mbEncoding.Text );
  N_StringToMemIni( 'N_MapEdExpF', 'edAccuracy', edAccuracy.Text );
  N_StringToMemIni( 'N_MapEdExpF', 'edWidth',    edWidth.Text );

  //***** Others
end; // end of procedure TN_ExportForm.CurStateToMemIni

//***********************************  TN_ExportForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_ExportForm.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'N_MapEdExpF_frCObjName', frCObjName.mb );
  N_MemIniToComboBox( 'N_MapEdExpF_frCObjPath', frCObjPath.mb );
  N_MemIniToComboBox( 'N_MapEdExpF_frMapUObj',  frMapUObj.mb  );

//  frMain.InitFromMemIniFile( N_MemIniFile, 'N_MapEdExpF_frMain' );
//  frAux.InitFromMemIniFile( N_MemIniFile,  'N_MapEdExpF_frAux' );
  N_MemIniToComboBox( 'N_MapEdExpF_frMain', frMain.mbFileName );
  N_MemIniToComboBox( 'N_MapEdExpF_frAux',  frAux.mbFileName );

  //***** HTML TabSheet
//  frExpFN1.InitFromMemIniFile( N_MemIniFile, 'N_MapEdExpF_frExpFN1' );
//  frExpFN2.InitFromMemIniFile( N_MemIniFile, 'N_MapEdExpF_frExpFN2' );
//  frExpFN3.InitFromMemIniFile( N_MemIniFile, 'N_MapEdExpF_frExpFN3' );
  N_MemIniToComboBox( 'N_MapEdExpF_frExpFN1', frExpFN1.mbFileName );
  N_MemIniToComboBox( 'N_MapEdExpF_frExpFN2', frExpFN2.mbFileName );
  N_MemIniToComboBox( 'N_MapEdExpF_frExpFN3', frExpFN3.mbFileName );

  //***** SVG TabSheet
  rgFileType.ItemIndex := N_MemIniToInt( 'N_MapEdExpF', 'rgFileType' );
  mbEncoding.Text := N_MemIniToString( 'N_MapEdExpF', 'mbEncoding' );
  edAccuracy.Text := N_MemIniToString( 'N_MapEdExpF', 'edAccuracy' );
  edWidth.Text    := N_MemIniToString( 'N_MapEdExpF', 'edWidth' );
  //***** Others
end; // end of procedure TN_ExportForm.MemIniToCurState

    //*********** Global Procedures  *****************************

//********************************************  N_GetExportForm  ******
// Create it if needed and return ExportForm
//
function N_GetExportForm( AOwner: TN_BaseForm ): TN_ExportForm;
begin
  if N_ExportForm <> nil then // already opened
  begin
    Result := N_ExportForm;
    Result.SetFocus;

    Exit;
  end;

  N_ExportForm := TN_ExportForm.Create( Application );
  Result := N_ExportForm;
  with Result do
  begin
    BaseFormInit( AOwner );
    // all UObjFrames ara initialized in CurArchiveChanged method
    CurArchiveChanged();

    frMain.OpenDialog.InitialDir := N_InitialFileDir;
    frAux.OpenDialog.InitialDir  := N_InitialFileDir;
    frExpFN1.OpenDialog.InitialDir  := N_InitialFileDir;
    frExpFN2.OpenDialog.InitialDir  := N_InitialFileDir;
    frExpFN3.OpenDialog.InitialDir  := N_InitialFileDir;
    frMain.OpenDialog.Filter := ' All  files (*.*)|*.*|'     +
                                   ' Text files (*.txt)|*.TXT|' +
                                   'Shape files (*.shp)|*.SHP|' +
                                   ' TDB  files (*.tdb)|*.TDB|' +
                                   ' EMF  files (*.emf)|*.EMF|';
    frAux.OpenDialog.Filter := frMain.OpenDialog.Filter;
  end;
end; // end of function N_GetExportForm


end.
