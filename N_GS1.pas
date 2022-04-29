unit N_GS1;
// ngs... Global Strings (Names, Values, Constants)

interface
uses Windows;

// TN_GSArray3 - dynamic Array[i,j,k] of Global Strings:
//    i - Language Index (i=0 - string names)
//    j - Form Index
//    k - String Index

type TN_GSArray3    = array of array of array of string;
type TN_GSFormNames = array of string; // GSForm Names

var
  N_GSArray3: TN_GSArray3;       // All Global Strings for several languages
  N_GSFormNames: TN_GSFormNames; // GSForm Names

  N_CurGSLangInd: integer = 2; // Current GSLanguage Index
  N_CurGSFormInd: integer;     // Current GSForm Index

const  //*********************
  N_MaxGSLangInd = 2;   // Max Value for N_CurGSLangInd
  N_MaxGSFormInd = 199; // Max Value for N_CurGSFormInd

  //***************** Special (N_CurGSFormInd not used ) *********
  ngsMenuSeparator1 = 11;
  ngsMenuSeparator2 = 12;
  ngsMenuSeparator3 = 13;
  ngsMenuSeparator4 = 14;
  ngsMenuSeparator5 = 15;
  ngsAllMenuItems   = $FFFF;

  //***************** MapEdMainForm (N_CurGSFormInd = ngsMapEdMF) *********
  ngsMapEdMF = 1;
  ngsCaption     = 100;
  ngsbnEdLines   = 101;
  ngsMapEdMFSize = 102;

  //***************** VREOpForm (N_CurGSFormInd = ngsVREOpF) *********
  ngsVREOpF  = 2;
  ngsFormCaption = 100;

  //*************** EdVertexMenu
  ngsEVMChooseSubAct  = 102;
  ngsEVMMoveCurVert   = 103;
  ngsEVMAddVertOnSegm = 104;
  ngsEVMAddVertToLine = 105;
  ngsEVMEnlargeLine   = 106;
  ngsEVMStartNewLine  = 107;
  ngsEVMFinishLine    = 108;
  ngsEVMDelLastVert   = 109;
  ngsEVMDelCurVert    = 110;
  ngsEVMDelNewVerts   = 111;

  //*************** Actions TabSheet
  ngstsActions      = 121;
  ngsgbActions      = 122;

  ngsrbMovePoint    = 125;
  ngsrbAddPoint     = 126;
  ngsrbDeletePoint  = 127;

  ngsrbMoveLabel    = 128;
  ngsrbEditLabel    = 129;
  ngsrbEmptyAction  = 130;

  ngsrbMoveVertex   = 132;
  ngsrbAddVertex    = 133;
  ngsrbDeleteVertex = 134;

  ngsrbEnlargeLine  = 135;
  ngsrbNewLine      = 136;
  ngsrbDeleteLine   = 137;
  ngsrbSplitCombLine= 138;

  ngsrbAffConvLine  = 141;

  ngsVREOpFSize     = 200;


function  N_GS    ( GSInd: integer ): string;
procedure N_SetGS ( const GSInd: integer; const GSName, GSEng, GSRus: string );
procedure N_InitGSArray ();


implementation

//******************************************************  N_GS  ************
// Return Global String with given Index (GSInd)
// for current N_CurGSFormInd, N_CurGSLangInd values
//
function N_GS( GSInd: integer ): string;
begin
  if (GSInd >= ngsMenuSeparator1) and (GSInd <= ngsMenuSeparator5) then // Menu Separators
    Result := '-'
  else
    Result := N_GSArray3[N_CurGSLangInd, N_CurGSFormInd, GSInd];
end; // function N_GS

//*****************************************************  N_SetGS  **********
// Set GSName, GSEng, GSRus (for using in N_InitGSArray() proc)
//
procedure N_SetGS( const GSInd: integer; const GSName, GSEng, GSRus: string );
begin
  N_GSArray3[0, N_CurGSFormInd, GSInd] := GSName;
  N_GSArray3[1, N_CurGSFormInd, GSInd] := GSEng;
  N_GSArray3[2, N_CurGSFormInd, GSInd] := GSRus;
end; // procedure N_SetGS

//***********************************************  N_BegGSFormDef  **********
// Begin of GSForm definition (for using in N_InitGSArray() proc)
//
procedure N_BegGSFormDef( const GSFormInd, GSFormSize: integer;
                                                   const GSFormName: string );
begin
  N_CurGSFormInd := GSFormInd;
  SetLength( N_GSArray3[0, N_CurGSFormInd], GSFormSize );
  SetLength( N_GSArray3[1, N_CurGSFormInd], GSFormSize );
  SetLength( N_GSArray3[2, N_CurGSFormInd], GSFormSize );
end; // procedure N_BegGSFormDef

//***********************************************  N_InitGSArray  **********
// initialization of N_GSArray
//
procedure N_InitGSArray();
begin
  SetLength( N_GSArray3, 3 ); // 0-GSName, 1-English, 2-Russian
  SetLength( N_GSArray3[0], N_MaxGSFormInd+1 );
  SetLength( N_GSArray3[1], N_MaxGSFormInd+1 );
  SetLength( N_GSArray3[2], N_MaxGSFormInd+1 );
  SetLength( N_GSFormNames, N_MaxGSFormInd+1 );

//  K_InitGSArray();

  //***************** MapEdMainForm ****************************
  N_BegGSFormDef( ngsMapEdMF, ngsMapEdMFSize, 'MapEdMF' );
  N_SetGS( ngsCaption, 'Caption', 'Map Editor', 'Редактор Карт' );
  N_SetGS( ngsbnEdLines, 'bnEdLines', 'Ed Lines', 'Ред. Линий' );

  //***************** VREOpForm ****************************
  N_BegGSFormDef( ngsVREOpF, ngsVREOpFSize, 'VREOpF' );
  N_SetGS( ngsFormCaption,   'FormCaption',   'Vector Editor Options', 'Установки векторного редактора' );

  //*************** EditVertexMenu
  N_SetGS( ngsEVMMoveCurVert,   'EVMMoveCurVert',   'Move Vertex',             'Двигать вершину' );
  N_SetGS( ngsEVMAddVertOnSegm, 'EVMAddVertOnSegm', 'Add Vertex On Segment',   'Добавить вершину на сегмент' );
  N_SetGS( ngsEVMAddVertToLine, 'EVMAddVertToLine', 'Add Vertex to Line',      'Добавить вершину к линии' );
  N_SetGS( ngsEVMEnlargeLine,   'EVMEnlargeLine',   'Enlarge Current Line',    'Нарастить текущую линию' );
  N_SetGS( ngsEVMStartNewLine,  'EVMStartNewLine',  'Start New Line',          'Начать новую линию' );
  N_SetGS( ngsEVMFinishLine,    'EVMFinishLine',    'Finish Line',             'Завершить линию' );
  N_SetGS( ngsEVMDelCurVert,    'EVMDelCurVert',    'Delete Current Vertex',   'Удалить текущую вершину' );
  N_SetGS( ngsEVMDelLastVert,   'EVMDelLastVert',   'Delete Last Vertex',      'Удалить последнюю вершину' );
  N_SetGS( ngsEVMDelNewVerts,   'EVMDelNewVerts',   'Delete All new Vertexes', 'Удалить все новые вершины' );

  //*************** Actions TabSheet
  N_SetGS( ngstsActions,   'tsActions',   'Actions', 'Операции' );
  N_SetGS( ngsgbActions,   'gbActions',   ' Current Edit Action ', ' Текущая операция редактирования ' );

  N_SetGS( ngsrbMovePoint,   'rbMovePoint',   'Move  Point',   'Двигать точку' );
  N_SetGS( ngsrbAddPoint,    'rbAddPoint',    'Add     Point', 'Новая   точка' );
  N_SetGS( ngsrbDeletePoint, 'rbDeletePoint', 'Delete Point',  'Удалить точку' );

  N_SetGS( ngsrbMoveLabel,   'rbMoveLabel',   'Move Label',    'Двигать надпись' );
  N_SetGS( ngsrbEditLabel,   'rbEditLabel',   'Edit    Label', 'Редактир. надпись' );
  N_SetGS( ngsrbEmptyAction, 'rbEmptyAction', 'Empty Action',  'Пустая операция' );

  N_SetGS( ngsrbMoveVertex,   'rbMoveVertex',   'Move  Vertex',   'Двигать вершину' );
  N_SetGS( ngsrbAddVertex,    'rbAddVertex',    'Add     Vertex', 'Новая   вершина' );
  N_SetGS( ngsrbDeleteVertex, 'rbDeleteVertex', 'Delete Vertex',  'Удалить вершину' );

  N_SetGS( ngsrbEnlargeLine,  'rbEnlargeLine',   'Enlarge Line',    'Нарастить линию' );
  N_SetGS( ngsrbNewLine,      'rbNewLine',       'New      Line',   'Начать новую линию' );
  N_SetGS( ngsrbDeleteLine,   'rbDeleteLine',    'Delete   Line',   'Удалить линию' );
  N_SetGS( ngsrbSplitCombLine,'rbSplitCombLine', 'Split/Comb Line', 'Разд./Объединить' );

  N_SetGS( ngsrbAffConvLine,  'rbAffConvLine',   'Aff. Conv Line',   'Аффинное преобр.' );


end; // procedure N_InitGSArray

end.

