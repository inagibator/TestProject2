unit N_PMTMain5F;
// CMS Application Photometry Main Form
//
// Updates:
//   Po-sm param added in 4.030.30 28.03.2021
//
// FormShow
// PMTCalcResults
// PMTResultsToText2


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, ExtCtrls, ComCtrls, Menus, ImgList, ActnList,
  N_Types, N_Rast1Fr, N_DGrid, N_CMREd3Fr,
  K_CM0, K_Types;

type
  TN_PMTPointStatus = ( psNotExists, psCurrent, psExists ); // Point Status in Vizard

  TN_PMTMain5Form = class( TN_BaseForm ) // CMS Application Photometry Main Form
    Top2Panel: TPanel;
    MainMenu1: TMainMenu;
    StatusBar: TStatusBar;
    Bot2Panel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    Splitter1: TSplitter;
    EdFramesPanel: TPanel;
    MainIcons44: TImageList;
    MainIcons18: TImageList;
    Goto1: TMenuItem;
    PMTActionList: TActionList;
    Patient1: TMenuItem;
    N1: TMenuItem;
    SwitchUserInterfacetoMediaSuitemode1: TMenuItem;
    aCOMCreateNewPMTObj: TAction;
    aCOMOpenPMTObj: TAction;
    Media1: TMenuItem;
    Createphotometricobject1: TMenuItem;
    aCOMImportFilesToPMTObj: TAction;
    Openphotometricobject1: TMenuItem;
    Importimagestoopendobject1: TMenuItem;
    Preferences1: TMenuItem;
    ThumbRFramePopupMenu: TPopupMenu;
    Importimagestoopendobject2: TMenuItem;
    Createphotometricobject2: TMenuItem;
    Openphotometricobject2: TMenuItem;
    Edit1: TMenuItem;
    EdFramePopUpMenu: TPopupMenu;
    aOpenDelActiveSlide: TAction;
    Deleteimage1: TMenuItem;
    aOpenClosePMTObj: TAction;
    Closephotometricobject1: TMenuItem;
    aOpenDelPMTObj: TAction;
    View1: TMenuItem;
    ViewsandFilters1: TMenuItem;
    aPPAddAllFront: TAction;
    aPPAddAllSide: TAction;
    aPPAddFpr: TAction;
    aPPAddFpl: TAction;
    aPPAddFn: TAction;
    aPPAddFsn: TAction;
    aPPAddFstr: TAction;
    aPPAddFstl: TAction;
    aPPAddFgn: TAction;
    aPPAddSn: TAction;
    aPPAddSpo: TAction;
    aPPAddSsn: TAction;
    aPPAddSsto: TAction;
    aPPAddSsm: TAction;
    aPPAddSpg: TAction;
    aPPAddStp: TAction;
    aPPAddSor: TAction;
    aPPAddAllFront1: TMenuItem;
    aPPAddAllSide1: TMenuItem;
    aShowResults: TAction;
    ShowResults1: TMenuItem;
    N2: TMenuItem;
    aPPAddFPr1: TMenuItem;
    aPPAddFPl1: TMenuItem;
    aPPAddFn1: TMenuItem;
    aPPAddFsn1: TMenuItem;
    aPPAddFstr1: TMenuItem;
    aPPAddFstl1: TMenuItem;
    aPPAddFgn1: TMenuItem;
    N3: TMenuItem;
    aPPAddSn1: TMenuItem;
    aPPAddSpo1: TMenuItem;
    aPPAddSsn1: TMenuItem;
    aPPAddSsto1: TMenuItem;
    aPPAddSsm1: TMenuItem;
    aPPAddSpg1: TMenuItem;
    aPPAddStp1: TMenuItem;
    aPPAddSor1: TMenuItem;
    CropImage1: TMenuItem;
    N4: TMenuItem;
    Rotatebyadegree1: TMenuItem;
    RotateLeft1: TMenuItem;
    RotateRight1: TMenuItem;
    Rotateby1801: TMenuItem;
    FlipVertically1: TMenuItem;
    FlipHorizontally1: TMenuItem;
    N5: TMenuItem;
    Deleteopenedphotometricobject1: TMenuItem;
    N6: TMenuItem;
    Filter11: TMenuItem;
    N7: TMenuItem;
    Tools1: TMenuItem;
    BrightnessContrastGamma1: TMenuItem;
    N8: TMenuItem;
    Rotatebyadegree2: TMenuItem;
    RotateLeft2: TMenuItem;
    RotateRight2: TMenuItem;
    Rotateby1802: TMenuItem;
    N9: TMenuItem;
    CropImage2: TMenuItem;
    aCOMDelele: TAction;
    N10: TMenuItem;
    Delete1: TMenuItem;
    aCOMDelMarkPMTObjs: TAction;
    PropertiesDiagnoses1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    PropertiesDiagnoses2: TMenuItem;
    Deleteallmarkedphotometricobjects1: TMenuItem;
    N13: TMenuItem;
    UndoLastAction1: TMenuItem;
    RedoLastAction1: TMenuItem;
    UndoRedo1: TMenuItem;
    PMTTimer: TTimer;
    aOpenClearAllActiveSlideAnnots: TAction;
    Clearactiveslideannotations1: TMenuItem;
    Createphotometricobject3: TMenuItem;
    aOpenSwitchSlides: TAction;
    Switchimages1: TMenuItem;
    Switchimages2: TMenuItem;
    aCOMImportFilesToPMTObj1: TAction;
    aSaveResults: TAction;
    aPPAddSta: TAction;
    AddSideta1: TMenuItem;
    Help1: TMenuItem;
    FPar1: TMenuItem;
    FPar2: TMenuItem;
    aCOMStart: TAction;
    N14: TMenuItem;
    AddAllFrontPoints1: TMenuItem;
    AddAllSidePoints1: TMenuItem;
    N15: TMenuItem;
    ShowResults2: TMenuItem;
    HelpFront: TMenuItem;
    HelpSide: TMenuItem;
    HelpFPar1: TMenuItem;
    snststgn1: TMenuItem;
    ststnsn1: TMenuItem;
    snngn1: TMenuItem;
    PoRPoLPon1: TMenuItem;
    Ponsm1: TMenuItem;
    Ponsn1: TMenuItem;
    nsnpg1: TMenuItem;
    Ponpg1: TMenuItem;
    tatpsnn1: TMenuItem;
    PonPosn1: TMenuItem;
    PonPosto1: TMenuItem;
    PonPopg1: TMenuItem;
    PonPLVsn1: TMenuItem;
    PonPLVsto1: TMenuItem;
    PonPLVpg1: TMenuItem;
    PoRPoLPon2: TMenuItem;
    N16: TMenuItem;

    aCOMUnitePMTObjs: TAction;
    Createphotometricobject4: TMenuItem;
    Unite2objects1: TMenuItem;
    aCOMSplitUnitedPMTObj: TAction;
    Splitunitedphotometricobject1: TMenuItem;
    aCOMSwitchUnitedPMTObjs: TAction;
    Createphotometricobject5: TMenuItem;
    aComDiagn: TAction;
    aShowDiagram: TAction;
    ShowDiagram1: TMenuItem;
    aComCalibrate2: TAction;
    Administration1: TMenuItem;


    //********* PMTActionList ActionList actions  *********************

    procedure aCOMCreateNewPMTObjExecute     ( Sender: TObject );
    procedure aCOMOpenPMTObjExecute          ( Sender: TObject );
    procedure aCOMImportFilesToPMTObjExecute ( Sender: TObject );
    procedure aCOMImportFilesToPMTObj1Execute( Sender: TObject );
    procedure aCOMDeleleExecute              ( Sender: TObject );
    procedure aCOMDelMarkPMTObjsExecute      ( Sender: TObject );
    procedure aComDiagnExecute               ( Sender: TObject );

    procedure aOpenDelActiveSlideExecute            ( Sender: TObject );
    procedure aOpenClosePMTObjExecute               ( Sender: TObject );
    procedure aOpenDelPMTObjExecute                 ( Sender: TObject );
    procedure aOpenClearAllActiveSlideAnnotsExecute ( Sender: TObject );
    procedure aOpenSwitchSlidesExecute              ( Sender: TObject );

    procedure aPPAddAllFrontExecute ( Sender: TObject );
    procedure aPPAddAllSideExecute  ( Sender: TObject );
    procedure aShowResultsExecute   ( Sender: TObject );
    procedure aSaveResultsExecute   ( Sender: TObject );
    procedure aShowDiagramExecute   ( Sender: TObject );

    procedure aPPAddFprExecute  ( Sender: TObject );
    procedure aPPAddFplExecute  ( Sender: TObject );
    procedure aPPAddFnExecute   ( Sender: TObject );
    procedure aPPAddFsnExecute  ( Sender: TObject );
    procedure aPPAddFstrExecute ( Sender: TObject );
    procedure aPPAddFstlExecute ( Sender: TObject );
    procedure aPPAddFgnExecute  ( Sender: TObject );
    procedure aPPAddFpgExecute  ( Sender: TObject );

    procedure aPPAddSnExecute   ( Sender: TObject );
    procedure aPPAddSpoExecute  ( Sender: TObject );
    procedure aPPAddSsnExecute  ( Sender: TObject );
    procedure aPPAddSstoExecute ( Sender: TObject );
    procedure aPPAddSsmExecute  ( Sender: TObject );
    procedure aPPAddSpgExecute  ( Sender: TObject );
    procedure aPPAddStpExecute  ( Sender: TObject );
    procedure aPPAddStaExecute  ( Sender: TObject );
    procedure aPPAddSorExecute  ( Sender: TObject );


//************************ TN_PMTMain5Form Event Handlers

    procedure FormShow       ( Sender: TObject );
    procedure FormCloseQuery ( Sender: TObject; var CanClose: Boolean );
    procedure FormClose      ( Sender: TObject; var Action: TCloseAction ); override;
    procedure PMTTimerTimer  ( Sender: TObject );
    procedure ThumbsRFramePaintBoxDblClick ( Sender: TObject );
    procedure CMMFDisableActions           ( Sender: TObject );

    procedure FPar1Click (Sender: TObject );
    procedure FPar2Click (Sender: TObject );
    procedure aCOMStartExecute(Sender: TObject);
    procedure HelpFPar1Click( Sender: TObject );
    procedure HelpFPar2Click( Sender: TObject );
    procedure HelpFPar3Click( Sender: TObject );
    procedure HelpFPar4Click( Sender: TObject );
    procedure HelpFSPar1Click( Sender: TObject );
    procedure HelpSPar1Click( Sender: TObject );
    procedure HelpSPar1Click0( Sender: TObject );
    procedure HelpSPar3Click( Sender: TObject );
    procedure HelpSPar4Click( Sender: TObject );
    procedure HelpSPar5Click( Sender: TObject );
    procedure HelpSPar6Click( Sender: TObject );
    procedure HelpSPar7Click( Sender: TObject );
    procedure HelpSPar8Click( Sender: TObject );
    procedure HelpSPar9Click( Sender: TObject );
    procedure HelpSPar10Click( Sender: TObject );
    procedure HelpSPar11Click( Sender: TObject );

//    procedure aCOMCalibrate(Sender: TObject);

    procedure aCOMUnitePMTObjsExecute        ( Sender: TObject );
    procedure aCOMSplitUnitedPMTObjExecute   ( Sender: TObject );
    procedure aCOMSwitchUnitedPMTObjsExecute ( Sender: TObject );
    procedure aComCalibrate2Execute(Sender: TObject);
  private
    { Private declarations }
    PMTThumbsDGrid: TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame

    procedure PMTFWndProc        ( var Msg: TMessage );
    procedure PMTActsDisableProc ();
    function  DelPMTObj          ( AUDStudy : TN_UDCMStudy ): Boolean;
    procedure SetEd3FrameHeader  ( AFrameInd : Integer );
    function  GetCurStudy        (): TN_UDCMStudy;
  public
    { Public declarations }
//    PMTPatNames: String;  // Patient Names
//    PMTPatDOB:   String;  // Patient DOB

    //***** Pairs of synchro Arrays:

    PMTFrontPNames: TN_SArray; // Ordered Front Points Names (filled in Form.Show)
    PMTSidePNames:  TN_SArray; // Ordered Side Points Names  (filled in Form.Show)

    PMTOrdFPoints:   TN_DPArray; // Ordered Front view Points (filled in PMTFillOrderedPoints)
    PMTOrdSPoints:   TN_DPArray; // Ordered Side view Points  (filled in PMTFillOrderedPoints)
    PMTOrdFPointsMM: TN_DPArray; // Ordered Front view Points in mm. (filled in PMTFillOrderedPoints)
    PMTOrdSPointsMM: TN_DPArray; // Ordered Side view Points  in mm. (filled in PMTFillOrderedPoints)

    //***** All Params Arrays (in ver 1 - 0-3 Front, 4-14 Side, 15 Front-Side )
    PMTResPlos:   TN_SArray; // ("B", "C" or "T")  (filled in Form.Show)
    PMTResults:   TN_DArray; // Calculated Results Values (Calculated in CalcResults)
    PMTResNames:  TN_SArray; // Results Names  (filled in Form.Show)
    PMTResUnits:  TN_SArray; // Results Units Names ('', '∞' or 'mm.') (filled in Form.Show)
    PMTResDeltaV: TN_DArray; // Calculated Results Delta as Value (double) (Calculated in CalcResults)
    PMTResDeltaS: TN_SArray; // Calculated Results Delta as String (Calculated in CalcResults)
    PMTResProbS:  TN_SArray; // Results Probability ('*', '**' or '***') (Calculated in CalcResults)
    PMTResDiagrV: TN_DArray; // Calculated Value (double) for Diagram (Calculated in CalcResults)
    PMTResDiagr_B: Double;   // B Value (0-100) for Diagram (Calculated in CalcResults)
    PMTResDiagr_C: Double;   // C Value (0-100) for Diagram (Calculated in CalcResults)
    PMTResDiagr_T: Double;   // T Value (0-100) for Diagram (Calculated in CalcResults)
    PMTCoefNorm:   Double;   // NormCoef for calculating PMTNorm values

//    PMTNormDelta:  TN_SArray; // Given Norm+/-Delta (string) (filled in Form.Show) OLD VAR, not used
    PMTBaseNorm:   TN_DArray; // Given Base Norm (double)  (filled in Form.Show)
    PMTBaseDelta:  TN_SArray; // Given Base Delta (string) (filled in Form.Show)
    PMTHelpNames:  TN_SArray; // Given Help Pics File Names suffixes (filled in Form.Show)
    PMTNorm:       TN_DArray; // Calculated Real Norm (double)  (Calculated in CalcResults)
    PMTNormDelta:  TN_SArray; // Calculated Real Norm+/-Delta (string) (Calculated in CalcResults)

    PMTResults2:   TN_DArray; // Calculated Results Values for RFRames 2,3 (Calculated in CalcResults)
    PMTResDeltaV2: TN_DArray; // Calculated Results Delta for RFRames 2,3 as Value (double) (Calculated in CalcResults)
    PMTResDeltaS2: TN_SArray; // Calculated Results Delta for RFRames 2,3 as String (Calculated in CalcResults)
    PMTResProbS2:  TN_SArray; // Results Probability for RFRames 2,3 ('норм.', '*', '**' or '***') (Calculated in CalcResults)
    PMTResDiagrV2: TN_DArray; // Calculated Value (double) for RFRames 2,3 for Diagram (Calculated in CalcResults)
    PMTResDiagr_B2: Double;   // B Value (0-100) for RFRames 2,3 for Diagram (Calculated in CalcResults)
    PMTResDiagr_C2: Double;   // C Value (0-100) for RFRames 2,3 for Diagram (Calculated in CalcResults)
    PMTResDiagr_T2: Double;   // T Value (0-100) for RFRames 2,3 for Diagram (Calculated in CalcResults)

    PMTMainHeader: string; // ѕротокол фотометрического исследовани€ лица.
    PMTResHeader1: string; // фас
    PMTResHeader2: string; // профиль
    PMTResHeader3: string; // Ћинейные параметры (фас)
    PMTResHeader4: string; // Ћинейные параметры (профиль)

    PMTCCardNumber: string; //
    PMTCFIO:        string; //
    PMTCF:          string; // ‘амили€
    PMTCI:          string; // »м€
    PMTCO:          string; // ќтчество
    PMTCDOB:        string; // ƒата рождени€
    PMTCDiagn:      TStringList; //
    PMTCDoctor:     string; //
    PMTCStudyDate:  string; //
    PMTCSumma4R:    string; // Adress Line 1 дл€ размера четырех верхних резцов

    PMTNCardNumber: string; //
    PMTNFIO:        string; //
    PMTNDOB:        string; //
    PMTNDiagn:      string; //
    PMTNDoctor:     string; //
    PMTNStudyDate:  string; //
    PMTNSumma4R:    string; // —умма четырех верхних резцов =

    PMTCurRFrameInd: Integer;  // Current Ed3RFrame Index (0-Front, 1-Side)
    PMTCurVizardInd: Integer;  // Current (with -->>) Vizard Point Index

    PMTFinPointFuncObj: TN_IntFuncObj;

    procedure PMTStartPointSetting ( ARFrameInd: Integer; APointName: String );
    function  PMTFinPointSetting   (): Integer;
    function  PMTGetSlideInfo      ( AUDSlide: TN_UDCMSlide; out ACapts : TN_SArray;
                                           out AUPoints : TN_DPArray ) : TPoint;
    function  DelSlidePMTPointsByList ( AUDSlide: TN_UDCMSlide;
                      ACapts : TN_SArray; const ADelListStr : string ) : string;
    procedure PMTFillOrderedPoints ( AStartRFInd: Integer );
    procedure PMTCreateVizardForm  ();
    function  PMTPointExists       ( AFPoint: TDPoint ): Boolean;
    procedure PMTSetPointStatus    ( APointInd: Integer; APointStatus: TN_PMTPointStatus );
    function  PMTGetPointStatus    ( APointInd: Integer ): TN_PMTPointStatus;
    function  PMTCalcFName         (): String;
    procedure PMTCalcResults       ( AStartRFInd: Integer );
    procedure PMTResultsToHTML     ( AStrings: TStrings );
    procedure PMTResultsToHTML2    ( AStrings: TStrings );
    procedure PMTResultsToCSV      ( AStrings: TStrings );
    procedure PMTResultsToText     ( AStrings: TStrings );
    procedure PMTResultsToText2    ( AStrings: TStrings );
    function  PMTRebuildLineAnnot  ( ): Boolean;
    function  PMTRemoveLineAnnot   ( ): Boolean;
end; // type TN_PMTMain5Form = class( TN_BaseForm ) // CMS Application Photometry Main Form

// type TN_PTMFrontInds = ( fiFPr, fiFPl, fiFn, fiFsn, fiFstr, fiFstl, fiFgn, fiFpg );
// type TN_PTMSideInds  = ( siSn, siSpo, siSsn, siSsto, siSsm, siSpg, siSNTA, siSor );

{
ћорфометрические точки на фотографи€х лица в фас
Pr	зрачкова€ точка	центр правого зрачка
Pl	зрачкова€ точка	центр левого зрачка
n	  кожна€ точка (nasion)	—ередина углублени€ носа по зрачковой линии.
sn	кожна€ точка subnasion	подносова€ точка
str	кожна€ точка stomion	точка смыкани€ губ справа
stl	кожна€ точка stomion	точка смыкани€ губ слева
gn	кожна€ точка gnation	наиболее нижн€€ точка подбородочного выступа

ћорфометрические точки на фотографи€х лица в профиль
n	  кожна€ точка nasion	наиболее глубока€ точка в области перехода лобной части в нос
po	кожна€ точка porion	наиболее верхн€€ часть козелка уха
sn	кожна€ точка subnasion	точка перехода контура основани€ носа в вермиллион верхней губы
sto	кожна€ точка stomion	“очка смыкани€ губ
sm	кожна€ точка supramentale	наиболее глубока€ точка подбородочно-губной складки
pg	кожна€ точка pogonion	наиболее выступающа€ точка на переднем контуре подбородочного выступа
tp  низ подбородка ближе к шее
ta  низ подбородка ближе к наружи
or	кожна€ точка orbitale	“очка нижнего кра€ орбиты
}

const
// Front view points inds:
  N_F_Pr  = 0;
  N_F_Pl  = 1;
  N_F_n   = 2;
  N_F_sn  = 3;
  N_F_str = 4;
  N_F_stl = 5;
  N_F_gn  = 6;
  N_F_PoR = 7;
  N_F_PoL = 8;

// Side view points inds:
  N_S_n   = 0;
  N_S_po  = 1;
  N_S_sn  = 2;
  N_S_sto = 3;
  N_S_sm  = 4;
  N_S_pg  = 5;
  N_S_tp  = 6;
  N_S_ta  = 7;
  N_S_or  = 8;

  N_Params = 36; // Number of Params (Length of PMTResults, PMTResNames, PMTHelpNames, ...)
                 //

var
  N_PMTMain5Form: TN_PMTMain5Form;

implementation

uses
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
     System.Types,
{$IFEND CompilerVersion >= 26.0}
     StdCtrls, Grids, Math,
     K_VFunc,
     N_CMMain5F, N_CMResF, N_CM1, N_Gra0, N_Gra1, N_Lib1, N_Lib0, N_CompBase,N_CompCL,
     N_Lib2, N_Comp1, N_Comp2, N_MemoF, N_PMTVizF,
     K_CMRFA, K_CLib0, K_UDT1, K_CML1F, K_FCMSetSlidesAttrs3,
     N_PMTHelpF, N_PMTHelp2F, N_PMTDiagr2F;

{$R *.dfm}

var OpenedStudy : TN_UDCMStudy;


//************************ TN_PMTMain5Form Actions OnExecute Handlers

//****************************** TN_PMTMain5Form.aCOMCreateNewPMTObjExecute ***
// Create new photometric object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCreateNewPMTObj Action handler
//
procedure TN_PMTMain5Form.aCOMCreateNewPMTObjExecute(Sender: TObject);
var
  Study : TN_UDBase;
begin
  with N_CMResForm do
  begin
    AddCMSActionStart( Sender );
    Study := K_CMEDAccess.ArchStudySamplesLibRoot.DirChildByObjName( '100' );
    if Study = nil then
      N_Dump1Str( 'aCreateNewPMTObj PMT sample is not found' )
    else
    begin

      Study := K_CMStudyCreateFromSample( Study, '', 0 );
      N_Dump1Str( 'Study ID=' + Study.ObjName + ' ' + Study.ObjInfo );
      N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
      N_CM_MainForm.CMMFShowStringByTimer( 'New photometric object is created' );
      if K_CMStudyOpenOnCreateGUIModeFlag then
      begin
        N_CM_MainForm.CMMFSelectThumbBySlide( TN_UDCMSlide(Study), FALSE, TRUE );
//        aCOMOpenPMTObjExecute( aCOMOpenPMTObj );
      end;
      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();
    end;

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm do
end; // procedure TN_PMTMain5Form.aCOMCreateNewPMTObjExecute

//*********************************** TN_PMTMain5Form.aCOMOpenPMTObjExecute ***
// Open existed photometric object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCreateNewPMTObj Action handler
//
procedure TN_PMTMain5Form.aCOMOpenPMTObjExecute(Sender: TObject);
var
  UDStudy : TN_UDCMStudy;
  ImgSlide : TN_UDCMSlide;
  MapRoot : TN_UDBase;

  PMTCapts : TN_SArray;
  PMTPoints : TN_DPArray;

  PMTSize : TPoint;
  RealOpen : Boolean;
label LExit;
begin
  with N_CMResForm do
  begin
    AddCMSActionStart( Sender );
    // Use ThumbnailFrame or Current Active Study Selection
    UDStudy := GetCurStudy();
    if UDStudy = nil then // precaution
    begin
LExit: //******
//      K_CMD4WWaitApplyDataFlag := false;
      Dec(K_CMD4WWaitApplyDataCount);
      N_Dump2Str( 'Nothing to do aOpenPMTObj' );
      Exit;
    end;

    with N_CM_MainForm do
    begin
      if UDStudy.CMSStudyItemsCount <> 2 then
      begin // 4 Items Study
        if CMMFEdFrLayout <> eflFourHSp then
        begin
          CMMFSetEdFramesLayout0( eflFourHSp );
          CMMFShowString( '' ); // Clear Images Saving Strings
        end;
        CMMFEdFrames[0].EdFreeObjects();
        CMMFEdFrames[1].EdFreeObjects();
        if Assigned(CMMFEdFrames[2]) then
        begin
          CMMFEdFrames[2].EdFreeObjects();
          CMMFEdFrames[3].EdFreeObjects();
        end;

        if CMMFActiveEdFrameSlideStudy <> nil then
          K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(CMMFActiveEdFrameSlideStudy), 1, K_cmlrmOpenLock );
        CMMFActiveEdFrameSlideStudy := nil;

        if 0 <> K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @(TN_UDCMSlide(UDStudy)), 1,
              K_CML1Form.LLLFileAccessCheck11.Caption // 'Press OK to stop opening.'
                                                     ) then goto LExit;
        RealOpen := FALSE;
        MapRoot := UDStudy.GetMapRoot();
        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(0) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[0] );
          SetEd3FrameHeader( 0 );
        end;

        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(1) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[1] );
          SetEd3FrameHeader( 1 );
        end;

        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(2) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[2] );
          SetEd3FrameHeader( 2 );
        end;

        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(3) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[3] );
          SetEd3FrameHeader( 3 );
        end;

      end   // end of 4 Items Study
      else
      begin // 2 Items Study
        if CMMFEdFrLayout <> eflTwoVSp then
        begin
          CMMFSetEdFramesLayout0( eflTwoVSp );
          CMMFShowString( '' ); // Clear Images Saving Strings
        end;
        CMMFEdFrames[0].EdFreeObjects();
        CMMFEdFrames[1].EdFreeObjects();
        if Assigned(CMMFEdFrames[2]) then
        begin
          CMMFEdFrames[2].EdFreeObjects();
          CMMFEdFrames[3].EdFreeObjects();
        end;
        if CMMFActiveEdFrameSlideStudy <> nil then
          K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(CMMFActiveEdFrameSlideStudy), 1, K_cmlrmOpenLock );
        CMMFActiveEdFrameSlideStudy := nil;


        if 0 <> K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @(TN_UDCMSlide(UDStudy)), 1,
              K_CML1Form.LLLFileAccessCheck11.Caption // 'Press OK to stop opening.'
                                                     ) then goto LExit;
        RealOpen := FALSE;
        MapRoot := UDStudy.GetMapRoot();
        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(0) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[0] );
          SetEd3FrameHeader( 0 );
  // is added to show how it works

  PMTSize := PMTGetSlideInfo( ImgSlide, PMTCapts, PMTPoints );
        end;

        ImgSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(1) );
        if ImgSlide <> nil then
        begin
          RealOpen := TRUE;
          CMMAddMediaToOpened( ImgSlide, [], CMMFEdFrames[1] );
          SetEd3FrameHeader( 1 );
  // is added to show how it works
  PMTSize := PMTGetSlideInfo( ImgSlide, PMTCapts, PMTPoints );
        end;
      end;   // end of 2 Items Study

      if RealOpen then
      begin
        CMMFActiveEdFrameSlideStudy := UDStudy;
        K_CMEDAccess.EDALockSlides( @TN_UDCMSlide(CMMFActiveEdFrameSlideStudy), 1, K_cmlrmOpenLock );
      end;

// is added to show how it works
//MapRoot := UDStudy.GetItemThumbnailByIndex(0);
//MapRoot := UDStudy.GetItemThumbnailByIndex(1);

      ThumbsRFrame.RedrawAllAndShow();
    end; // with N_CM_MainForm do

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm do
end; // procedure TN_PMTMain5Form.aCOMOpenPMTObjExecute

//************************** TN_PMTMain5Form.aCOMImportFilesToPMTObjExecute ***
// Import files to opened photometric object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aImportFilesToPMTObj Action handler
//
procedure TN_PMTMain5Form.aCOMImportFilesToPMTObjExecute(Sender: TObject);
var
  NumImpSlides : Integer;
  NumSlides : Integer;
  ImpFiles: TStringList;

  i : Integer;
  LockResult : Integer;
  SavedList : TList;
  WasLockedFlag : Boolean;
  MountedInds : TN_IArray;
  LockStudyResult : Integer;
  UnlockMode : TK_CMEDLockResultMode;

  UDStudy : TN_UDCMStudy;

label LExit;
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    UDStudy := GetCurStudy();
    if UDStudy = nil then // precaution
    begin
LExit: //******
//      K_CMD4WWaitApplyDataFlag := false;
      Dec(K_CMD4WWaitApplyDataCount);
      N_Dump2Str( 'aImportFilesToPMTObj Nothing to do' );
      Exit;
    end;

    N_Dump2Str( 'aImportFilesToPMTObj select files' );
    ImpFiles := TStringList.Create;
    K_CMImportFilesSelectDlg( ImpFiles );
    if ImpFiles.Count = 0 then goto LExit;

    NumSlides := K_CMSlidesImportFromFilesList( ImpFiles );
    N_Dump2Str( format('Import %d of %d files', [NumSlides, ImpFiles.Count] ) );
    ImpFiles.Free;
    if NumSlides = 0 then goto LExit;


    //////////////////////////////////////////////////
    // Save New Slides to Wrk List because of possible
    // refresh CurSlidesSet inside CMMOpenedStudiesLock
    SavedList := TList.Create;
    with K_CMEDAccess do
    begin
      LockResult := CurSlidesList.Count - NumSlides;
      for i := 0 to NumSlides - 1 do
      begin
        SavedList.Add( CurSlidesList[LockResult] );
        CurSlidesList.Delete(LockResult);
      end;
    end;
    //////////////////////////////////////////////////

//    MountToStudy := CMMStudiesLockTry( @UDStudy, 1, WasLockedFlag, 10, 300 );
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    //////////////////////////////////////////////////
    // Restore Saved Slides to CurSlidesSet
    for i := 0 to NumSlides - 1 do
      K_CMEDAccess.CurSlidesList.Add( SavedList[i] );
    SavedList.Free;
    //////////////////////////////////////////////////

    if LockStudyResult > 0 then goto LExit;

    MountedInds := nil;
//    NumImpSlides := 0;
//    if MountToStudy then
      NumImpSlides := K_CMSetSlidesAttrs3( MountedInds, NumSlides, nil,
                             UDStudy, K_CML1Form.LLLCaptHandler10.Caption
//        'Process Output from Import'
                                   );
    if Length(MountedInds) > 0 then
    begin
      K_CMEDAccess.EDAStudySavingStart();
      UDStudy.CreateThumbnail();
      UDStudy.SetChangeState();
      K_CMEDAccess.EDAStudySave( UDStudy );
      K_CMEDAccess.EDAStudySavingFinish();
    end;

    if not WasLockedFlag and (cmsfIsLocked in UDStudy.P.CMSRFlags) then
    begin
      UnlockMode := K_cmlrmEditStudyLock;
      if CMMFActiveEdFrameSlideStudy = UDStudy then
        UnlockMode := K_cmlrmSaveOpenLock;
      K_CMEDAccess.EDAUnLockSlides( TN_PUDCMSlide(@UDStudy), 1, UnlockMode );
    end;

    if NumImpSlides > 0 then
    begin
      N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
      N_CM_MainForm.CMMFShowStringByTimer( format( '%d images are imported',[NumImpSlides]) );

      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();
    end;

    N_Dump2Str( format('Import %d of %d files', [NumImpSlides,NumSlides] ) );
    AddCMSActionFinish( Sender );

    if (NumImpSlides > 0) and
       (CMMFActiveEdFrameSlideStudy = UDStudy) then
      aCOMOpenPMTObjExecute( aCOMOpenPMTObj );

  end; // with N_CMResForm, N_CM_MainForm do
end; // procedure TN_PMTMain5Form.aCOMImportFilesToPMTObjExecute

//************************* TN_PMTMain5Form.aCOMImportFilesToPMTObj1Execute ***
// Import files to opened photometric object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aImportFilesToPMTObj1 Action handler
//
procedure TN_PMTMain5Form.aCOMImportFilesToPMTObj1Execute(Sender: TObject);
var
  UDStudy : TN_UDCMStudy;
  MapRoot,ItemFront, ItemSide : TN_UDBase;
  ImgSlide : TN_UDCMSlide;
  ImgImpCount, ImgImpInd, NumSlides : Integer;
  i : Integer;
  ImpFiles: TStringList;

  LockResult : Integer;
  SavedList : TList;
  WasLockedFlag : Boolean;
  LockStudyResult : Integer;
  UnlockMode : TK_CMEDLockResultMode;

label LExit, FinAction;
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    UDStudy := GetCurStudy();
    if UDStudy = nil then // precaution
    begin
LExit: //******
//      K_CMD4WWaitApplyDataFlag := false;
      Dec(K_CMD4WWaitApplyDataCount);
      N_Dump2Str( 'aImportFilesToPMTObj Nothing to do' );
      Exit;
    end;

    ImgImpCount := 0;
    ImgImpInd := -1;

    MapRoot := UDStudy.GetMapRoot();
    ItemFront := MapRoot.DirChild(0);
    ImgSlide := K_CMStudyGetOneSlideByItem( ItemFront );
    if ImgSlide = nil then
    begin
      Inc(ImgImpCount);
      ImgImpInd := 0;
    end;

    ItemSide := MapRoot.DirChild(1);
    ImgSlide := K_CMStudyGetOneSlideByItem( ItemSide );
    if ImgSlide = nil then
    begin
      Inc(ImgImpCount);
      if ImgImpInd = -1 then
        ImgImpInd := 1;
    end;
    N_Dump2Str( format('aImportFilesToPMTObj Count=%d Ind=%d', [ImgImpCount,ImgImpInd] ) );
    if ImgImpInd = -1 then goto LExit;

    N_Dump2Str( 'aImportFilesToPMTObj select files' );
    ImpFiles := TStringList.Create;
    K_CMImportFilesSelectDlg( ImpFiles );
    if ImpFiles.Count = 0 then goto LExit;

    // Remove extra files names
    if ImpFiles.Count > ImgImpCount then
      for i := ImpFiles.Count - 1 downto ImgImpCount do
        ImpFiles.Delete(i);

    NumSlides := K_CMSlidesImportFromFilesList( ImpFiles );
    N_Dump2Str( format('Import %d of %d files', [NumSlides, ImpFiles.Count] ) );
    ImpFiles.Free;
    if NumSlides = 0 then goto LExit;

    //////////////////////////////////////////////////
    // Save New Slides to Wrk List because of possible
    // refresh CurSlidesSet inside CMMOpenedStudiesLock
    SavedList := TList.Create;
    with K_CMEDAccess do
    begin
      LockResult := CurSlidesList.Count - NumSlides;
      for i := 0 to NumSlides - 1 do
      begin
        SavedList.Add( CurSlidesList[LockResult] );
        CurSlidesList.Delete(LockResult);
      end;
    end;
    //////////////////////////////////////////////////

    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );

    if LockStudyResult > 0 then
    begin
      for i := 0 to NumSlides - 1 do
        TN_UDBase(SavedList[i]).UDDelete();
      SavedList.Free;
      goto LExit;
    end;

    //////////////////////////////////////////////////
    // Restore Saved Slides to CurSlidesSet
    for i := 0 to NumSlides - 1 do
      K_CMEDAccess.CurSlidesList.Add( SavedList[i] );

    K_CMEDAccess.EDASaveSlidesList(SavedList);

    i := 0;
    if ImgImpInd = 0 then
    begin // Add Image to Front Item
      with K_CMEDAccess.CurSlidesList do
        K_CMEDAccess.EDAStudyMountOneSlideToEmptyItem( ItemFront, TN_UDCMSlide(Items[Count - NumSlides]), UDStudy );
      if NumSlides = 1 then goto FinAction;
      ImgImpInd := 1;
      i := 1;
    end;


    if ImgImpInd = 1 then
    begin // Add Image to Side Item
      with K_CMEDAccess.CurSlidesList do
        K_CMEDAccess.EDAStudyMountOneSlideToEmptyItem( ItemSide, TN_UDCMSlide(Items[Count - NumSlides + i]), UDStudy );
    end;

FinAction: //*****
    K_CMEDAccess.EDAStudySavingStart();
    UDStudy.CreateThumbnail();
    UDStudy.SetChangeState();
    K_CMEDAccess.EDAStudySave( UDStudy );
    K_CMEDAccess.EDAStudySavingFinish();

    if not WasLockedFlag and (cmsfIsLocked in UDStudy.P.CMSRFlags) then
    begin
      UnlockMode := K_cmlrmEditStudyLock;
      if CMMFActiveEdFrameSlideStudy = UDStudy then
        UnlockMode := K_cmlrmSaveOpenLock;
      K_CMEDAccess.EDAUnLockSlides( TN_PUDCMSlide(@UDStudy), 1, UnlockMode );
    end;

    if NumSlides > 0 then
    begin
      N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
      N_CM_MainForm.CMMFShowStringByTimer( format( '%d images are imported',[NumSlides]) );

      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();
    end;

//    N_Dump2Str( 'aImportFilesToPMTObj fin' );
    AddCMSActionFinish( Sender );

    if CMMFActiveEdFrameSlideStudy = UDStudy then
      aCOMOpenPMTObjExecute( aCOMOpenPMTObj );

    SavedList.Free;

  end; // with N_CMResForm, N_CM_MainForm do

end; // procedure TN_PMTMain5Form.aCOMImportFilesToPMTObj1Execute

//*************************************** TN_PMTMain5Form.aCOMDeleteExecute ***
// Delete common selected annotation, opened photometric object or marked photometric objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCOMDelPMTObj Action handler
//
procedure TN_PMTMain5Form.aCOMDeleleExecute(Sender: TObject);
begin
  if N_CM_MainForm.CMMFActiveEdFrame.RFrame.Focused  and
     (N_CM_MainForm.CMMFActiveEdFrame.EdVObjSelected <> nil) then
    N_CMResForm.aObjDeleteExecute( Sender )
  else
  if aCOMDelMarkPMTObjs.Enabled then
    aCOMDelMarkPMTObjsExecute( Sender )
  else
  if aOpenDelPMTObj.Enabled then
    aOpenDelPMTObjExecute( Sender );

end; // procedure TN_PMTMain5Form.aCOMDeleteExecute

//******************************* TN_PMTMain5Form.aCOMDelMarkPMTObjsExecute ***
// Delete all marked photometric objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCOMDelMarkPMTObjs Action handler
//
procedure TN_PMTMain5Form.aCOMDelMarkPMTObjsExecute(Sender: TObject);
var
  MessageText : string;
  PMTSlides : TN_UDCMSArray;
  i, NumMarked : Integer;


label Fin;
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    with N_CM_MainForm do
      NumMarked := CMMGetMarkedSlidesArray( PMTSlides );
    if NumMarked = 0 then goto Fin; // precaution

    MessageText := 'Do you confirm that you really want to delete selected photometric objects?' + #13#10 +
     // 'Do you confirm that you really want to delete selected photometric objects?'
      '              ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLProceed.Caption;
    if mrYes <> K_CMShowMessageDlg( MessageText,  mtConfirmation, [], FALSE, K_CML1Form.LLLDelConfirm.Caption ) then goto Fin;


    if K_CMSFullScreenForm <> nil then
      aEditFullScreenCloseExecute( Sender );

    for i := 0 to NumMarked -1 do
    begin
      if cmsfIsOpened in PMTSlides[i].P.CMSRFlags then
        aOpenDelPMTObjExecute( nil )
      else
        DelPMTObj( TN_UDCMStudy(PMTSlides[i]) );
    end;

Fin: //*****
    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm do

end; // procedure TN_PMTMain5Form.ACOMDelMarkPMTObjsExecute

//**************************************** TN_PMTMain5Form.aCOMDiagnExecute ***
// Show Properties/Diagnoses Form
//
//     Parameters
// Sender - Event Sender
//
// OnExecute PMTActionList.aCOMDiagn Action handler
//
procedure TN_PMTMain5Form.aComDiagnExecute( Sender: TObject );
begin
  N_CMResForm.aGoToPropDiagMultiExecute( Sender );
end; // procedure TN_PMTMain5Form.aCOMDiagnExecute

procedure TN_PMTMain5Form.aOpenDelActiveSlideExecute(Sender: TObject);
var
  ItemInd : Integer;
  UDStudy : TN_UDCMStudy;
  UDSlide : TN_UDCMSlide;
  WasLockedFlag : Boolean;
  LockStudyResult : Integer;
  MessageText : string;

label Fin;

begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    if Sender <> nil then
    begin
      MessageText := K_CML1Form.LLLDelOpened1.Caption + #13#10 +
       // 'Do you confirm that you really want to delete opened image?'
        '              ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLProceed.Caption;
      if mrYes <> K_CMShowMessageDlg( MessageText,  mtConfirmation, [], FALSE, K_CML1Form.LLLDelConfirm.Caption ) then goto Fin;
    end;
    // Prepare Array to Detete

    // Lock Study
    UDSlide := CMMFActiveEdFrame.EdSlide;
    UDStudy := UDSlide.GetStudy();
//    DismountFromStudy := CMMStudiesLockTry( @UDStudy, 1, WasLockedFlag, 10, 300 );
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult = 0 then
    begin
      K_CMEDAccess.EDAStudySavingStart();

      ItemInd := 0;
      if CMMFActiveEdFrame = CMMFEdFrames[1] then
        ItemInd := 1;
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( UDStudy.GetMapRoot().DirChild( ItemInd ),
                                                     UDSlide, UDStudy, FALSE );

      UDStudy.CreateThumbnail();
      UDStudy.SetChangeState();
      K_CMEDAccess.EDAStudySave( UDStudy );
      K_CMEDAccess.EDAStudySavingFinish();

//      N_CM_MainForm.CMMFRebuildVisSlides( TRUE );

      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

      aEditCloseCurActiveExecute( aEditCloseCurActive );
      K_CMSlidesDeleteExecute( @UDSlide, 1, FALSE );



     // Unlock Study
     if not WasLockedFlag and (cmsfIsLocked in UDStudy.P.CMSRFlags) then
        K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(UDStudy), 1, K_cmlrmSaveOpenLock );
    end; // if LockStudyResult = 0 then
Fin: //*****
    AddCMSActionFinish( Sender );

  end; // with N_CMResForm, N_CM_MainForm do
end; // procedure TN_PMTMain5Form.aOpenDeleteExecute

procedure TN_PMTMain5Form.aOpenClosePMTObjExecute(Sender: TObject);
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    if K_CMSFullScreenForm <> nil then
      aEditFullScreenCloseExecute( Sender );

    CMMFEdFrames[0].EdFreeObjects();
    CMMFEdFrames[1].EdFreeObjects();
    if CMMFActiveEdFrameSlideStudy.CMSStudyItemsCount > 2 then
    begin
      CMMFEdFrames[2].EdFreeObjects();
      CMMFEdFrames[3].EdFreeObjects();
    end;

    K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(CMMFActiveEdFrameSlideStudy), 1, K_cmlrmOpenLock );
    CMMFActiveEdFrameSlideStudy := nil;

    ThumbsRFrame.RedrawAllAndShow();

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm do
end; // procedure TN_PMTMain5Form.aOpenCloseExecute

procedure TN_PMTMain5Form.aOpenDelPMTObjExecute(Sender: TObject);
var
  UDStudy : TN_UDCMStudy;
  UDSlide : TN_UDCMSlide;
  MessageText : string;

label Fin;
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );
    if Sender <> nil then
    begin
      MessageText := 'Do you confirm that you really want to delete opened photometric object?' + #13#10 +
       // 'Do you confirm that you really want to delete opened photometric object?'
        '              ' + K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLProceed.Caption;
      if mrYes <> K_CMShowMessageDlg( MessageText,  mtConfirmation, [], FALSE, K_CML1Form.LLLDelConfirm.Caption ) then goto Fin;
    end;

    if K_CMSFullScreenForm <> nil then
      aEditFullScreenCloseExecute( Sender );

    UDStudy := nil;
    UDSlide := CMMFEdFrames[0].EdSlide;
    if UDSlide <> nil then
    begin
      CMMFSetActiveEdFrame( CMMFEdFrames[0], TRUE );
      UDStudy := UDSlide.GetStudy();
      aOpenDelActiveSlideExecute(nil);
    end;

    UDSlide := CMMFEdFrames[1].EdSlide;
    if UDSlide <> nil then
    begin
      CMMFSetActiveEdFrame( CMMFEdFrames[1], TRUE );
      UDStudy := UDSlide.GetStudy();
      aOpenDelActiveSlideExecute(nil);
    end;

    K_CMSlidesDeleteExecute( TN_PUDCMSlide(@UDStudy), 1, FALSE );

    CMMFRebuildVisSlides( TRUE );

Fin: //*****
    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm do

end; // procedure TN_PMTMain5Form.aOpenDelObjExecute

procedure TN_PMTMain5Form.aOpenClearAllActiveSlideAnnotsExecute( Sender: TObject );
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );


    CMMFActiveEdFrame.EdSlide.GetMeasureRoot.ClearChilds();
    CMMFActiveEdFrame.EdVObjSelected := nil;

    CMMFActiveEdFrame.RebuildVObjsSearchList();
    CMMFActiveEdFrame.RFrame.RedrawAllAndShow();

    N_CM_MainForm.CMMFFinishVObjEditing( N_CMResForm.aObjDelete.Caption,
               K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                    Ord(K_shVOActDel),
                    Ord(K_shVOTypeDot) ) );

    CMMFRebuildVisSlides( TRUE );

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm do

end; // procedure TN_PMTMain5Form.aOpenClearAllActiveSlideAnnotsExecute

procedure TN_PMTMain5Form.aOpenSwitchSlidesExecute(Sender: TObject);
var
  UDStudy : TN_UDCMStudy;
  UDSlide0, UDSlide1 : TN_UDCMSlide;
  UDItem0, UDItem1  : TN_UDBase;
  LockStudyResult : Integer;
  WasLockedFlag : Boolean;

label Fin;
begin
  with N_CMResForm, N_CM_MainForm do
  begin
    AddCMSActionStart( Sender );

    UDStudy := nil;
    UDItem0 := nil;
    UDItem1 := nil;
    UDSlide0 := CMMFEdFrames[0].EdSlide;
    if UDSlide0 <> nil then
    begin
      UDItem0 := UDSlide0.GetStudyItem();
      UDStudy := TN_UDCMStudy(UDItem0.Owner.Owner);
    end;

    UDSlide1 := CMMFEdFrames[1].EdSlide;
    if UDSlide1 <> nil then
    begin
      UDItem1 := UDSlide1.GetStudyItem();
      UDStudy := TN_UDCMStudy(UDItem1.Owner.Owner);
    end;

    if UDStudy = nil then goto Fin; // Precation

    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult <> 0 then goto Fin;

    K_CMEDAccess.EDAStudySavingStart();

    if UDSlide0 <> nil then
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( UDItem0,
                                                     UDSlide0, UDStudy, FALSE );
    if UDSlide1 <> nil then
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( UDItem1,
                                                     UDSlide1, UDStudy, FALSE );

    if UDSlide0 <> nil then
    begin
      if UDItem1 = nil then
        UDItem1 := UDStudy.GetMapRoot.DirChild(1);
      K_CMEDAccess.EDAStudyMountAddSlideToItem( UDItem1,
                                                     UDSlide0, UDStudy, FALSE );
      CMMFEdFrames[1].SetNewSlide( UDSlide0 )
    end;

    if UDSlide1 <> nil then
    begin
      if UDItem0 = nil then
        UDItem0 := UDStudy.GetMapRoot.DirChild(0);
      K_CMEDAccess.EDAStudyMountAddSlideToItem( UDItem0,
                                                     UDSlide1, UDStudy, FALSE );
      CMMFEdFrames[0].SetNewSlide( UDSlide1 );
    end;

    UDStudy.CreateThumbnail();
    UDStudy.SetChangeState();
    K_CMEDAccess.EDAStudySave( UDStudy );
    K_CMEDAccess.EDAStudySavingFinish();

    // Unlock Study
    if not WasLockedFlag and (cmsfIsLocked in UDStudy.P.CMSRFlags) then
      K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(UDStudy), 1, K_cmlrmSaveOpenLock );

    CMMFRebuildVisSlides( TRUE );

Fin: //****
    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm do
end; // procedure TN_PMTMain5Form.aOpenSwitchSlidesExecute


procedure TN_PMTMain5Form.aPPAddAllFrontExecute( Sender: TObject );
// Start Adding Front Points Vizard
//
begin
  PMTCurRFrameInd := 0; // Front RFRame Index
  PMTCreateVizardForm();
end; // procedure TN_PMTMain5Form.aPPAddAllFrontExecute

procedure TN_PMTMain5Form.aPPAddAllSideExecute( Sender: TObject );
// Start Adding Side Points Vizard
//
begin
  PMTCurRFrameInd := 1; // Side RFRame Index
  PMTCreateVizardForm();
end; // procedure TN_PMTMain5Form.aPPAddAllSideExecute

procedure TN_PMTMain5Form.aShowResultsExecute( Sender: TObject );
// Prepare Results in Text, HTML and CSV files and Show Results as Text
var
  i, SavedEncMode, NumBytes: Integer;
  FName: String;
  MemoF: TN_MemoForm;
  SL, DiagnAll: TStringList;
//  SavedEncMode: TN_TextEncoding;
  PatientDBData:  TK_CMSAPatientDBData;
  ProviderDBData: TK_CMSAProviderDBData;
  ResBytes: TN_BArray;
begin
  if N_CM_MainForm.CMMFActiveEdFrameSlideStudy = nil then Exit; // No Study

  N_Dump1Str( 'Start aShowResultsExecute' );

  //***** Prepare Patient and Provider related fields:
  //  PMTCCardNumber, PMTCFIO, PMTCDOB, PMTCDoctor, PMTCStudyDate, PMTCDiagn


  DiagnAll := TStringList.Create;
  DiagnAll.Text := TN_PCMSlide(N_CM_MainForm.CMMFActiveEdFrameSlideStudy.P())^.CMSDiagn;

  if K_CMEDAccess is TK_CMEDDBAccess then
    with K_CMEDAccess do
    begin
      EDASAGetOnePatientInfo( IntToStr( CurPatID ), @PatientDBData, [K_cmsagiSkipLock] );
      with PatientDBData do
      begin
        PMTCCardNumber := APCardNum;
        PMTCF := APSurname;
        PMTCI := APFirstname;
        PMTCO := APMiddle;
        PMTCFIO := PMTCF + ' ' + PMTCI + ' ' + PMTCO;
        PMTCDOB := DateToStr( APDOB );
        PMTCSumma4R := APAddr1;
      end; // with PatientDBData do

      EDASAGetOneProviderInfo( IntToStr( CurProvID ), @ProviderDBData, [K_cmsagiSkipLock] );
      with ProviderDBData do
        PMTCDoctor := AUSurname + ' ' + AUFirstname + ' ' + AUMiddle;
    end; // with K_CMEDAccess do

  if DiagnAll.Count >= 1 then // StudyDate is first line in Diagnoses
    PMTCStudyDate := DiagnAll[0]
  else
    PMTCStudyDate := '';

  if not Assigned(PMTCDiagn) then
    PMTCDiagn := TStringList.Create;

  PMTCDiagn.Clear;

  if DiagnAll.Count >= 2 then // all other lines are real Diagnoses
    for i := 1 to DiagnAll.Count-1 do
      PMTCDiagn.Add( DiagnAll[i] );

  DiagnAll.Free;

  PMTCalcResults( 2 ); // Calc Results for RFrames 2,3 if needed
  PMTCalcResults( 0 ); // Calc Results for RFrames 0,1
  N_Dump1Str( 'After PMTCalcResults()' );

  SL := TStringList.Create;
//  PatParams := K_CMEDAccess.EDAGetPatientMacroInfo(); // Patient Params needed for version with DB

//  FName := N_MemIniToString( 'CMS_UserMain', 'PMTResFName', 'C:\PMTResult' ); // File Name Prefix
//  FName := K_ExpandFileName( FName );
//  FName := FName + '_' + K_DateTimeToStr( Now(), 'yyyy-mm-dd_hh-nn-ss' );
  FName := PMTCalcFName();

  PMTResultsToHTML2( SL );
  SL.SaveToFile( FName + '.html' );

//  PMTResultsToCSV( SL );
//  SL.SaveToFile( FName + '.csv' );

  SavedEncMode := Integer(N_NeededTextEncoding); // save current value, a precaution
  N_NeededTextEncoding := N_UseBOMFlag or Integer(teUTF8);
  NumBytes := N_EncodeStringToBytes( SL.Text, ResBytes );
  N_WriteBinFile ( FName + '.xls', @ResBytes[0], NumBytes );

  Integer(N_NeededTextEncoding) := SavedEncMode; // restore original value


//  PMTResultsToText( SL );
  PMTResultsToText2( SL );
  SL.SaveToFile( FName + '.txt' );

  MemoF := N_CreateMemoForm( 'Results', Self ); // Show Results in Text format
  with MemoF do
  begin
    Caption := 'Results';
    Memo.Lines.AddStrings( SL );
    Memo.ScrollBars := ssBoth;
    Show();
  end; // with MemoF do

  SL.Free;
end; // procedure TN_PMTMain5Form.aShowResultsExecute

procedure TN_PMTMain5Form.aSaveResultsExecute( Sender: TObject );
// Save Results in HTML and CSV formats
var
  FName: String;
begin
  PMTCalcResults( 0 ); // Calc Results in PMTResults DArray and fill PMTResNames SArray

  FName := N_MemIniToString( 'CMS_UserMain', 'PMTResFName', 'C:\PMTResult' );
  FName := K_ExpandFileName( FName );
  FName := FName + '_' + K_DateTimeToStr( Now(), 'yyyy-mm-dd_hh-nn-ss' );

//  PMTResultsToHTML( FName + '.html' ); // Save Calculated Results in HTML format

end; // procedure TN_PMTMain5Form.aSaveResultsExecute

procedure TN_PMTMain5Form.aShowDiagramExecute( Sender: TObject );
// Show Diagram
begin
//  N_ShowPMTDiagram();
  N_ShowPMTDiagram2();
end; // procedure TN_PMTMain5Form.aShowDiagramExecute


//**************************** Single Front Points

procedure TN_PMTMain5Form.aPPAddFprExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'pr' );
end;

procedure TN_PMTMain5Form.aPPAddFplExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'pl' );
end;

procedure TN_PMTMain5Form.aPPAddFnExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'n' );
end;

procedure TN_PMTMain5Form.aPPAddFsnExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'sn' );
end;

procedure TN_PMTMain5Form.aPPAddFstrExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'str' );
end;

procedure TN_PMTMain5Form.aPPAddFstlExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'stl' );
end;

procedure TN_PMTMain5Form.aPPAddFgnExecute( Sender: TObject );
begin
  PMTStartPointSetting( 0, 'gn' );
end;

procedure TN_PMTMain5Form.aPPAddFpgExecute(Sender: TObject);
begin
  PMTStartPointSetting( 0, 'pg' );
end;


//**************************** Single Side Points

procedure TN_PMTMain5Form.aPPAddSnExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'n' );
end;

procedure TN_PMTMain5Form.aPPAddSpoExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'Po' );
end;

procedure TN_PMTMain5Form.aPPAddSsnExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'sn' );
end;

procedure TN_PMTMain5Form.aPPAddSstoExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'sto' );
end;

procedure TN_PMTMain5Form.aPPAddSsmExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'sm' );
end;

procedure TN_PMTMain5Form.aPPAddSpgExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'pg' );
end;

procedure TN_PMTMain5Form.aPPAddStpExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'tp' );
end;

procedure TN_PMTMain5Form.aPPAddStaExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'ta' );
end;

procedure TN_PMTMain5Form.aPPAddSorExecute( Sender: TObject );
begin
  PMTStartPointSetting( 1, 'or' );
end;


//************************ TN_PMTMain5Form Event Handlers

//************************************************ TN_PMTMain5Form.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TN_PMTMain5Form.FormShow(Sender: TObject);
begin
  N_PMTMain5Form := Self;
  if N_CM_MainForm.CMMCurFMainFormSkipOnShow then
  begin
    N_CM_MainForm.CMMCurFMainFormSkipOnShow := FALSE;
    Exit;
  end;

  N_Dump1Str( '***** Start TN_PMTMain5Form OnShow Handler' );

  SetLength( PMTFrontPNames, 9 );
  PMTFrontPNames[N_F_Pr]  := 'pr';
  PMTFrontPNames[N_F_Pl]  := 'pl';
  PMTFrontPNames[N_F_n]   := 'n';
  PMTFrontPNames[N_F_sn]  := 'sn';
  PMTFrontPNames[N_F_str] := 'str';
  PMTFrontPNames[N_F_stl] := 'stl';
  PMTFrontPNames[N_F_gn]  := 'gn';
  PMTFrontPNames[N_F_PoR] := 'Po(R)';
  PMTFrontPNames[N_F_PoL] := 'Po(L)';

  SetLength( PMTSidePNames, 9 );
  PMTSidePNames[N_S_n]   := 'n';
  PMTSidePNames[N_S_po]  := 'Po';
  PMTSidePNames[N_S_sn]  := 'sn';
  PMTSidePNames[N_S_sto] := 'sto';
  PMTSidePNames[N_S_sm]  := 'sm';
  PMTSidePNames[N_S_pg]  := 'pg';
  PMTSidePNames[N_S_tp]  := 'tp';
  PMTSidePNames[N_S_ta]  := 'ta';
  PMTSidePNames[N_S_or]  := 'or';

  SetLength( PMTResPlos, N_Params ); // N_Params = 36
  PMTResPlos[0]  := 'B';
  PMTResPlos[1]  := 'B';
  PMTResPlos[2]  := 'T';
  PMTResPlos[3]  := 'T';

  PMTResPlos[4]  := 'B';
  PMTResPlos[5]  := 'C';
  PMTResPlos[6]  := 'C';
  PMTResPlos[7]  := 'C';
  PMTResPlos[8]  := 'C';
  PMTResPlos[9]  := 'C';
  PMTResPlos[10] := 'C';
  PMTResPlos[11] := 'C';
  PMTResPlos[12] := '*C';
  PMTResPlos[13] := '*C';
  PMTResPlos[14] := '*C';

  PMTResPlos[15] := 'T';
  PMTResPlos[16] := '*';
  PMTResPlos[17] := '*';
  PMTResPlos[18] := '*';
  PMTResPlos[19] := '*';
  PMTResPlos[20] := 'B';

  PMTResPlos[21] := 'T';
  PMTResPlos[22] := 'B';
  PMTResPlos[23] := 'B';
  PMTResPlos[24] := 'B';
  PMTResPlos[25] := 'B';
  PMTResPlos[26] := '*B';

  PMTResPlos[27] := 'C';
  PMTResPlos[28] := 'C';
  PMTResPlos[29] := 'C';
  PMTResPlos[30] := 'C'; // Po-sm param added in 4.030.30
  PMTResPlos[31] := 'C';
  PMTResPlos[32] := 'C';
  PMTResPlos[33] := 'C';
  PMTResPlos[34] := 'C';
  PMTResPlos[35] := '*'; // not used


  SetLength( PMTResUnits, N_Params );
  PMTResUnits[0]  := '';
  PMTResUnits[1]  := '';
  PMTResUnits[2]  := '∞';
  PMTResUnits[3]  := '∞';

  PMTResUnits[4]  := '∞';
  PMTResUnits[5]  := '∞';
  PMTResUnits[6]  := '∞';
  PMTResUnits[7]  := '∞';
  PMTResUnits[8]  := '∞';
  PMTResUnits[9]  := '';
  PMTResUnits[10] := '';
  PMTResUnits[11] := '';
  PMTResUnits[12] := '';
  PMTResUnits[13] := '';
  PMTResUnits[14] := '';

  PMTResUnits[15] := '';
  PMTResUnits[16] := '*';
  PMTResUnits[17] := '*';
  PMTResUnits[18] := '*';
  PMTResUnits[19] := '*';
  PMTResUnits[20] := '';

  PMTResUnits[21] := 'мм.';
  PMTResUnits[22] := 'мм.';
  PMTResUnits[23] := 'мм.';
  PMTResUnits[24] := 'мм.';
  PMTResUnits[25] := 'мм.';
  PMTResUnits[26] := 'мм.';

  PMTResUnits[27] := 'мм.';
  PMTResUnits[28] := 'мм.';
  PMTResUnits[29] := 'мм.';
  PMTResUnits[30] := 'мм.'; // Po-sm param added in 4.030.30
  PMTResUnits[31] := 'мм.';
  PMTResUnits[32] := 'мм.';
  PMTResUnits[33] := 'мм.';
  PMTResUnits[34] := 'мм.';
  PMTResUnits[35] := '*';

  SetLength( PMTBaseDelta, N_Params );
  PMTBaseDelta[0]  := '±0.02';
  PMTBaseDelta[1]  := '±0.01';
  PMTBaseDelta[2]  := '±2.7';
  PMTBaseDelta[3]  := '±0.01';

  PMTBaseDelta[4]  := '±5.3';
  PMTBaseDelta[5]  := '±2.4';
  PMTBaseDelta[6]  := '±2.1';
  PMTBaseDelta[7]  := '±2.2';
  PMTBaseDelta[8]  := '±2.7';
  PMTBaseDelta[9]  := '±0.03';
  PMTBaseDelta[10] := '±0.03';
  PMTBaseDelta[11] := '±0.02';
  PMTBaseDelta[12] := '±0.03';
  PMTBaseDelta[13] := '±0.04';
  PMTBaseDelta[14] := '±0.03';

  PMTBaseDelta[15] := '±0.04';
  PMTBaseDelta[16] := '';
  PMTBaseDelta[17] := '';
  PMTBaseDelta[18] := '';
  PMTBaseDelta[19] := '';
  PMTBaseDelta[20] := '±0.06';

  PMTBaseDelta[21] := '±4.1';
  PMTBaseDelta[22] := '±3.8';
  PMTBaseDelta[23] := '±1.8';
  PMTBaseDelta[24] := '±0.2';
  PMTBaseDelta[25] := '±0.8';
  PMTBaseDelta[26] := '****';

  PMTBaseDelta[27] := '±2.8';
  PMTBaseDelta[28] := '±3.5'; // prev value - 2.7
  PMTBaseDelta[29] := '±2.8';
  PMTBaseDelta[30] := '±3.3'; // Po-sm param added in 4.030.30
  PMTBaseDelta[31] := '±3.5';
  PMTBaseDelta[32] := '±0.5';
  PMTBaseDelta[33] := '±0.2';
  PMTBaseDelta[34] := '±0.4';
  PMTBaseDelta[35] := '';


  SetLength( PMTBaseNorm, N_Params );
  PMTBaseNorm[0]  := 0.75;
  PMTBaseNorm[1]  := 0.46;
  PMTBaseNorm[2]  := 91.3;
  PMTBaseNorm[3]  := 0.1;

  PMTBaseNorm[4]  := 176.8;
  PMTBaseNorm[5]  := 79.0;
  PMTBaseNorm[6]  := 70.5;
  PMTBaseNorm[7]  := 72.7;
  PMTBaseNorm[8]  := 89.4;
  PMTBaseNorm[9]  := 1.06;
  PMTBaseNorm[10] := 1.03;
  PMTBaseNorm[11] := 0.80;
  PMTBaseNorm[12] := 1.00;
  PMTBaseNorm[13] := 0.90;
  PMTBaseNorm[14] := 0.80;

  PMTBaseNorm[15] := 1.44;
  PMTBaseNorm[16] := -1;
  PMTBaseNorm[17] := -1;
  PMTBaseNorm[18] := -1;
  PMTBaseNorm[19] := -1;
  PMTBaseNorm[20] := 2.15;

  PMTBaseNorm[21] := 136.8;
  PMTBaseNorm[22] := 126.2;
  PMTBaseNorm[23] := 58.8;
  PMTBaseNorm[24] := 67.4;
  PMTBaseNorm[25] := 22.1;
  PMTBaseNorm[26] := 45.4; //!!! was not given

  PMTBaseNorm[27] :=  94.7;
  PMTBaseNorm[28] := 105.6; // prev value - 89.6
  PMTBaseNorm[29] :=  92.0;
  PMTBaseNorm[30] := 112.5; // Po-sm param added in 4.030.30
  PMTBaseNorm[31] := 118.4;
  PMTBaseNorm[32] := -11.1;
  PMTBaseNorm[33] :=  -3.7;
  PMTBaseNorm[34] :=  -8.2;
  PMTBaseNorm[35] :=  -1;

  SetLength( PMTResNames, N_Params );
  PMTResNames[0]  := '   nЦsn/snЦgn';    // HelpFPar1Click
  PMTResNames[1]  := '   sn-sto/sto-gn'; // HelpFPar2Click
  PMTResNames[2]  := '/_ n-sn/st-st';
  PMTResNames[3]  := '/_ sn-n-gn';

  PMTResNames[4]  := '/_ n/sn/pg';     // HelpSPar1Click
  PMTResNames[5]  := '/_ Po/n/sn';
  PMTResNames[6]  := '/_ Po/n/sm';
  PMTResNames[7]  := '/_ Po/n/pg';
  PMTResNames[8]  := 'ta-tp/sn-n';     // HelpSPar5Click
  PMTResNames[9]  := 'Po-n/Po-sn';
  PMTResNames[10] := 'Po-n/Po-sto';
  PMTResNames[11] := 'Po-n/Po-pg';
  PMTResNames[12] := 'Po-n/PLV-sn';   // HelpSPar9Click
  PMTResNames[13] := 'Po-n/PLV-sto';
  PMTResNames[14] := 'Po-n/PLV-pg';

  PMTResNames[15] := 'Po(L)-Po(R)/Po-n';
  PMTResNames[16] := ''; // reserved
  PMTResNames[17] := ''; // reserved
  PMTResNames[18] := ''; // reserved
  PMTResNames[19] := ''; // reserved
  PMTResNames[20] := '   nЦgn/nЦsn';

  PMTResNames[21] := 'Po(L)-Po(R)'; // Front abs. values in mm.
  PMTResNames[22] := '   nЦgn';
  PMTResNames[23] := '   nЦsn';
  PMTResNames[24] := '   snЦgn';
  PMTResNames[25] := '   snЦsto';
  PMTResNames[26] := '   stoЦgn';

  PMTResNames[27] := '   PoЦn'; // Side abs. values in mm.
  PMTResNames[28] := '   PoЦsn';
  PMTResNames[29] := '   PoЦsto';
  PMTResNames[30] := '   PoЦsm'; // Po-sm param added in 4.030.30
  PMTResNames[31] := '   PoЦpg';
  PMTResNames[32] := '   PLVЦsn';
  PMTResNames[33] := '   PLVЦsto';
  PMTResNames[34] := '   PLVЦpg';
  PMTResNames[35] := ''; // reserved


  SetLength( PMTHelpNames, N_Params );
  PMTHelpNames[0] := 'F1'; // Help Image File Name is  PMTH_F1.png
  PMTHelpNames[1] := 'F2';
  PMTHelpNames[2] := 'F3';
  PMTHelpNames[3] := 'F4';
  PMTHelpNames[4] := 'S1';
  PMTHelpNames[5] := 'S2';
  PMTHelpNames[6] := 'S4'; // $4, not S3!
  PMTHelpNames[7] := 'S3';
  PMTHelpNames[8] := 'S5';
  PMTHelpNames[9] := 'S6';
  PMTHelpNames[10] := 'S6';
  PMTHelpNames[11] := 'S6';
  PMTHelpNames[12] := 'S7';
  PMTHelpNames[13] := 'S7';
  PMTHelpNames[14] := 'S7';
  PMTHelpNames[15] := 'FS1';


  //*************** Report fields Names and content

  PMTMainHeader := 'ѕротокол фотометрического исследовани€ лица.';
  PMTResHeader1 := 'фас';
  PMTResHeader2 := 'профиль';
  PMTResHeader3 := 'Ћинейные параметры (фас)';
  PMTResHeader4 := 'Ћинейные параметры (профиль)';

  PMTNCardNumber := 'є карты ортодонтического пациента';
  PMTNFIO        := '‘»ќ';
  PMTNDOB        := 'ƒата рождени€';
  PMTNDiagn      := 'ƒиагноз';
  PMTNDoctor     := '¬рач';
  PMTNStudyDate  := 'ƒата исследовани€';
  PMTNSumma4R    := '—умма четырех верхних резцов = ';

  //***** DB Fields content for Demo version

  PMTCCardNumber := '1234567890';
  PMTCF        := '»ванов';
  PMTCI        := '»ван';
  PMTCO        := '»ванович';
  PMTCFIO      := '»ванов »ван »ванович';
  PMTCDOB      := '01.02.1999';
  PMTCDoctor   := '“ихонова јнастаси€ ћихайловна';
  PMTCSumma4R  := '33.0';

//  BFFlags := [bffToDump1];
  Self.Caption := N_CM_MainForm.Caption;

{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
  ThumbsRFrame.VScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}

  DoubleBuffered := True;
  Bot2Panel.DoubleBuffered := True;
  Top2Panel.DoubleBuffered := True;
  EdFramesPanel.DoubleBuffered := True;

  //*** Form.WindowProc should be changed for processing Arrow and Tab keys
//  WindowProc := OwnWndProc;
  WindowProc := PMTFWndProc;

  if PMTThumbsDGrid = nil then // for recall after files handling on start
  begin
    PMTThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, N_CM_MainForm.CMMFGetThumbSize );
    with PMTThumbsDGrid do
    begin
      DGEdges := Rect( 2, 2, 2, 2 );
  //    DGEdges := Rect( 12, 12, 12, 12 );
      DGGaps  := Point( 2, 2 );
      DGScrollMargins := Rect( 8, 8, 8, 8 );

      DGLFixNumCols   := 1;
      DGLFixNumRows   := 0;
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
  //    DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 28; // see DGLItemsAspect   - 2 Text Lines

      DGDrawItemProcObj := N_CM_MainForm.CMMFDrawThumb;
      DGExtExecProcObj  := N_CMResForm.ThumbsRFrameExecute;

      ThumbsRFrame.DstBackColor := DGBackColor;
      ThumbsRFrame.RFDebName := 'Thumbs';
      Windows.SetStretchBltMode( ThumbsRFrame.OCanv.HMDC, HALFTONE );
    end; // with CMMFThumbsDGrid do
  end;

  // Set Current Visual Contex
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurCaptToolBar := nil;
  N_CM_MainForm.CMMCurFThumbsDGrid := PMTThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := nil;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := PMTActsDisableProc;
  N_CM_MainForm.CMMCurUpdateCustToolBar := nil;
  N_CM_MainForm.CMMCurSlideFilterFrame := nil;
  N_CM_MainForm.CMMCurBigIcons := MainIcons44;
  N_CM_MainForm.EdFramesPanel.Parent := Bot2Panel;


  //  N_CM_MainForm.CMMCurSmallIcons:= MainIcons18;
  N_CMResForm.MainIcons18.Assign( MainIcons18 );
  K_CMDynIconsSInd := N_CMResForm.MainIcons18.Count;
  N_CM_MainForm.CMMCurMainMenu := MainMenu1;
  N_CM_MainForm.CMMCurMainMenu.Images := N_CMResForm.MainIcons18;

//  Init Controls Context
  Self.OnKeyDown := N_CM_MainForm.FormKeyDown;
  Self.OnKeyPress := N_CM_MainForm.FormKeyPress;

  EdFramesPanel.OnResize := N_CM_MainForm.CMMEdFramesPanelResize;

  // N_CM_IDEMode :
  // = 0 Release Version
  // = 1 Full Design Mode
  // = 2 Patial Design Mode
//  Debug1.Visible := (N_CM_IDEMode = 1);
//  Debug2.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);

//  Init ThumbsRFr Context
//  ThumbsRFrame.PopupMenu := N_CMResForm.ThumbsRFrPopupMenu;
  ThumbsRFrame.OnContextPopup := N_CM_MainForm.ThumbsRFrameContextPopup;
//  ThumbsRFrame.OnEndDrag := N_CM_MainForm.ThumbsRFrameEndDrag;
//  ThumbsRFrame.PaintBox.OnDblClick := N_CM_MainForm.ThumbsRFrameDblClick;
//  ThumbsRFrame.OnMouseDownProcObj := N_CM_MainForm.OnThumbsFrameMouseDown;
//  ThumbsRFrame.DragCursor := crMultiDrag;
//  ThumbsRFrame.RFDumpEvents := True;

  // Set EdFrames Context
  N_CM_MainForm.CMMEdFramePopUpMenu := EdFramePopUpMenu;

  BaseFormInit( nil, '', [rspfPrimMonWAR,rspfMaximize], [rspfAppWAR,rspfShiftAll] );
// 2017-08-22 - skip form moving processing to the new monitor
//  N_EnableMainFormMove := True;
  N_ProcessMainFormMove( N_GetScreenRectOfControl( Self ) );

  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)
    if not K_CMEDAccessInit2() then
      N_Dump1Str( 'TN_PMTMain5Form OnShow Handler >> K_CMEDAccessInit2=FALSE' );
  end; // if K_CMEDAccess <> nil then

  N_Dump1Str( Format( 'MainForm5: FormSize=(%d,%d) ClientSize=(%d,%d) BFMinBRPanelLT=(%d,%d)',
                [Width,Height,ClientWidth,ClientHeight,BFMinBRPanel.Left,BFMinBRPanel.Top] ));

  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)
    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
//    FSRecovery1MItem.Visible := K_CMDesignModeFlag or not (K_CMEDAccess is TK_CMEDDBAccess);
  end  // if K_CMEDAccess <> nil then
  else
    N_CM_MainForm.CMMFDisableActions( nil );

  N_CM_MainForm.FormActivate( Sender ); // To Close CMS Splash Screen earlier then FormActivate

  N_Dump1Str( '***** Finish TN_PMTMain5Form OnShow Handler' );
// 07-11-2014 close for COM StartSession proper work
//  K_CMSAppStartContext.CMASMode := K_cmamWait; // Clear Start Mode (??? may be needed for HR Preview)

  OpenedStudy := nil;
end; // procedure TN_PMTMain5Form.FormShow

//****************************************** TN_PMTMain5Form.FormCloseQuery ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_PMTMain5Form.FormCloseQuery( Sender: TObject;  var CanClose: Boolean );
begin
  inherited;
  CanClose := not K_CMD4WSkipCloseUI; // needed to prevent application UI close
  N_Dump2Str( 'TN_PMTMain5Form.FormCloseQuery CanClose =' + N_B2S(CanClose) );
end; // TN_PMTMain5Form.FormCloseQuery


//*********************************************** TN_PMTMain5Form.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_PMTMain5Form.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  WCurPatID : Integer;
  i : Integer;
//  WCurProvID, WCurLocID : Integer;
begin

//  if K_CMSZoomForm <> nil then
//    K_CMSZoomForm.Close;
//////////////////////////////////////////////////////////////////
//  Should be changed when real multy interface will be done
//

  K_GetFreeSpaceProfile();
  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );

  WCurPatID  := K_CMEDAccess.CurPatID;
//  WCurProvID := K_CMEDAccess.CurProvID;
//  WCurLocID  := K_CMEDAccess.CurLocID;

  N_Dump1Str( '***** TN_PMTMain5Form.OnClose Start' );
// To prevent collision in N_CM_MainForm.FormClose

  Inc(K_CMD4WWaitApplyDataCount); // To Prevent сall to K_CMD4WApplyBufContext while FilesSaving
  N_CM_MainForm.CMMCurFThumbsRFrame := nil; // To prevent ThumbsRFrame Redraw

  N_CM_MainForm.CMMFFreeEdFrObjects();
  if N_CM_MainForm.CMMFActiveEdFrameSlideStudy <> nil then
    K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(N_CM_MainForm.CMMFActiveEdFrameSlideStudy), 1, K_cmlrmOpenLock );
  N_CM_MainForm.CMMFActiveEdFrameSlideStudy := nil;


  Dec(K_CMD4WWaitApplyDataCount); // clear

  // Restore EdFrames Context
  N_CM_MainForm.CMMEdFramePopUpMenu := N_CMResForm.EdFrPointPopupMenu;


// To prevent actions in K_FormCMSIsodensity.FormClose
  PMTThumbsDGrid.Free;
  ThumbsRFrame.RFFreeObjects();

  N_CM_MainForm.EdFramesPanel.Parent := N_CM_MainForm;
  N_CM_MainForm.CMMCurFMainForm := nil;
  N_CM_MainForm.CMMCurFStatusBar := nil;
  N_CM_MainForm.CMMCurCaptToolBar := nil;
  N_CM_MainForm.CMMCurFThumbsDGrid := nil;
  N_CM_MainForm.CMMCurFThumbsRFrame := nil;
  N_CM_MainForm.CMMCurFThumbsResizeWidth := N_CM_MainForm.CMMCurFThumbsResizeTControl.Width;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := nil;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := nil;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := nil;
  N_CM_MainForm.CMMCurSlideFilterFrame := nil;
  N_CM_MainForm.CMMCurBigIcons := nil;
  N_CM_MainForm.CMMCurMainMenu := nil;
//  N_CM_MainForm.CMMFEdFrLayout := eflNotDef; //!!!

  K_CMShowPMTStudiesOnlyFlag := FALSE;

  inherited;
  N_PMTMain5Form := nil;


//////////////////////////////////////////////////////////////////
//  New Main Interface Form Finish Code - Close Main "Start" Form

  if K_CMD4WAppFinState then
  begin
    N_Dump1Str( 'TN_PMTMain5Form.OnClose >> N_CM_MainForm is already closed' );
    Exit;   // N_CM_MainForm (CMS) is already closed
  end;

  if K_CMGAModeFlag then // Clear GA Mode if VEUI is closed
    K_CMEDAccess.EDAClearGAMode();

  if K_CMEDAccess is TK_CMEDDBAccess and not K_CMSwitchMainUIFlag then
    TK_CMEDDBAccess(K_CMEDAccess).EDAClearActiveContext();

  if not K_CMCloseOnCurUICloseFlag then
  begin
    N_Dump1Str( 'TN_PMTMain5Form.OnClose >> Other UI mode is launching' );
    Exit; // CMS should be continued on UI form closing
  end;

//  K_CMD4WHPNewPatientID    := WCurPatID;  // D4W HP New Patient ID
//  K_CMD4WHPNewProviderID   := WCurProvID; // D4W HP New Provider ID
//  K_CMD4WHPNewLocationID   := WCurLocID;  // D4W HP New Location ID

{}
/////////////////////////////////
// Dump Active Instances Table
//
  if K_CMEDAccess is TK_CMEDDBAccess then
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      if (LANDBConnection <> nil)    and
         (LANDBConnection.Connected) and
         (CurBlobDSet <> nil) then
      begin
        TmpStrings.Clear;
        EDADumpActiveContext( CurBlobDSet, TmpStrings, TRUE );
        if TmpStrings.Count > 1 then
          N_Dump1Str('*** Other Active CMSuites on Self Close ***'#13#10 + TmpStrings.Text);
      end
      else
        N_Dump1Str('*** Fails to Dump Other Active CMSuites on Self Close ***');
    end;
//
// Dump Active Instances Table
/////////////////////////////////
{}

//!!  if FALSE and
    if K_CMD4WAppRunByCOMClient and
       not K_CMOutOfMemoryFlag  and
       not K_CMD4WCloseAppByUI  and
       not (N_KeyIsDown(VK_SHIFT) and N_KeyIsDown(VK_CONTROL)) then
    begin
  // Close Connection only if is Run By Client and memory collisions were not detected


      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        EDAAppDeactivate();
        EDARebuildADOObjects;

        ATimer.Enabled := TRUE;
      end;
      K_CMD4WCNewPatientID := WCurPatID; // Set K_CMD4WCNewPatientID as Flag that
                                         // CMS should be awaked with this patient context
                                         // on SetWindowState and ExecUICommand COM commands

      K_CMAutoCloseLastActTS := Now(); // Set Start DateTime to AutoClose CMSuite

      ////////////////////////////////
      // Dump Opened Slides UNDO files
      K_CMEDAccess.TmpStrings.Clear;
      for i := 0 to K_CMEDAccess.CurSlidesList.Count - 1 do
        if TObject(K_CMEDAccess.CurSlidesList[i]) is TN_UDCMSlide then
        begin
          with TN_UDCMSlide(K_CMEDAccess.CurSlidesList[i]) do
          if CMSUndoBuf <> nil then
            K_CMEDAccess.TmpStrings.Add( CMSUndoBuf.FUndoFilePath );
        end;
      if K_CMEDAccess.TmpStrings.Count > 0 then
        N_Dump1Str( format('UNDO Files List in %s:'#13#10, [K_ExpandFileName('(#TmpFiles#)')] ) +
                    K_CMEDAccess.TmpStrings.Text );

      N_Dump1Str( 'TN_PMTMain5Form.OnClose >> Close UI, wait for COM client events' +
                  #13#10'=========='#13#10 );
      K_CMSAppStartContext.CMASMode := K_cmamSleep;
      Exit;
    end;
// Temp code to prevent warnings
{!!
i := N_i;
N_i := i;
N_i := WCurPatID;
}
//  N_Dump1Str( '***** N_PMTMain5Form.OnClose 2' );

  // Close Application
//??  N_CM_MainForm.ActTimer.Enabled := TRUE;
//??  K_CMD4WMainFormCloseFlag := TRUE;
  N_CM_MainForm.Close();
//  N_Dump1Str( '***** N_PMTMain5Form.OnClose 3' );
//  N_CM_MainForm.Release();
//  N_Dump1Str( '***** N_PMTMain5Form.OnClose 4' );

//  K_CMEDAccess.SkipProcessMessages := TRUE;
end; // procedure TN_PMTMain5Form.FormClose

procedure TN_PMTMain5Form.PMTTimerTimer( Sender: TObject );
// On Timer Event Hadler
begin
  PMTTimer.Enabled := FALSE;

  with N_CM_MainForm do
  begin
    if (N_CM_MainForm.CMMFActiveEdFrame <> nil) and
       ((N_CM_MainForm.CMMFActiveEdFrame.EdViewEditMode = cmrfemNone) or
        (N_CM_MainForm.CMMFActiveEdFrame.EdViewEditMode = cmrfemPoint)) then
    begin
      if Assigned(PMTFinPointFuncObj) then
      begin
        if PMTFinPointFuncObj() = 1 then
          Exit; // do not Enable Timer
      end;
    end; // if ...
  end; // with N_CM_MainForm do

  PMTTimer.Enabled := TRUE;
end; // procedure TN_PMTMain5Form.TimerTimer

//**************************** TN_PMTMain5Form.ThumbsRFramePaintBoxDblClick ***
// ThumbsRFrame.PaintBox DblClick
//
//     Parameters
// Sender    - Event Sender
//
// OnDblClick Self handler
//
procedure TN_PMTMain5Form.ThumbsRFramePaintBoxDblClick(Sender: TObject);
begin
  aCOMOpenPMTObjExecute(aCOMOpenPMTObj);
end; // procedure TN_PMTMain5Form.ThumbsRFramePaintBoxDblClick

//************************************** TN_PMTMain5Form.CMMFDisableActions ***
// Disable needed Actions by current Application state
//
//     Parameters
// Sender - Event Sender
//
// Used as OnClick handler for all MainMenu1.Media Items and should be
// called after all other code, that may affect list of disabled Actions
//
procedure TN_PMTMain5Form.CMMFDisableActions( Sender: TObject );
begin
  N_CM_MainForm.CMMFDisableActions( Sender );
end; // procedure TN_PMTMain5Form.CMMFDisableActions


//************************ TN_PMTMain5Form Private Methods

//********************************************* TN_PMTMain5Form.PMTFWndProc ***
// Self WindowProc
//
//     Parameters
// Msg - Window Message
//
procedure  TN_PMTMain5Form.PMTFWndProc( var Msg: TMessage );
begin
//if N_KeyIsDown(VK_SHIFT) then
//N_Dump2Str( format('%x %x', [Msg.Msg,Msg.WParam]) );
  if (Msg.Msg = WM_SYSCOMMAND) and
     (Msg.WParam and $FFF0 = SC_MINIMIZE) then
    ShowWindow( Application.Handle, SW_SHOWMINIMIZED )
  else
    OwnWndProc( Msg );
end; //  TN_PMTMain5Form.PMTFWndProc

//************************************** TN_PMTMain5Form.PMTActsDisableProc ***
// Self actions disabled procedure
//
procedure TN_PMTMain5Form.PMTActsDisableProc;
var
  PMTSlides : TN_UDCMSArray;
  NumMarked : Integer;
  FullFaceOpen, ProfileOpen : Boolean;
  UDStudy, UDOpenStudy : TN_UDCMStudy;
  MapRoot : TN_UDBase;
  SelectedStudyFullFaceSlide, SelectedStudyProfileSlide,
  OpenedStudyFullFaceSlide, OpenedStudyProfileSlide : TN_UDCMSlide;
begin
  with N_CM_MainForm do
  begin
    NumMarked := CMMGetMarkedSlidesArray( PMTSlides );
    UDStudy := nil;
    if NumMarked <> 0 then
      TN_UDCMSlide(UDStudy) := PMTSlides[NumMarked - 1];

    OpenedStudyFullFaceSlide := CMMFEdFrames[0].EdSlide;
    OpenedStudyProfileSlide  := CMMFEdFrames[1].EdSlide;
    FullFaceOpen  := OpenedStudyFullFaceSlide <> nil;
    ProfileOpen := OpenedStudyProfileSlide <> nil;
    UDOpenStudy := nil;
    if FullFaceOpen then
      UDOpenStudy := OpenedStudyFullFaceSlide.GetStudy
    else
    if ProfileOpen then
      UDOpenStudy := OpenedStudyProfileSlide.GetStudy;

    SelectedStudyFullFaceSlide := nil;
    SelectedStudyProfileSlide  := nil;
    if UDStudy <> nil then
    begin
      MapRoot := UDStudy.GetMapRoot();
      SelectedStudyFullFaceSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(0) );
      SelectedStudyProfileSlide := K_CMStudyGetOneSlideByItem( MapRoot.DirChild(1) );
    end;

    aOpenDelActiveSlide.Enabled := CMMFActiveEdFrame.EdSlide <> nil;
    aOpenClearAllActiveSlideAnnots.Enabled := aOpenDelActiveSlide.Enabled and
                   (CMMFActiveEdFrame.EdSlide.GetMeasureRoot.DirLength > 0);

    aOpenClosePMTObj.Enabled := UDOpenStudy <> nil;
    aOpenDelPMTObj.Enabled   := UDOpenStudy <> nil;

    aComDiagn.Enabled := UDOpenStudy = nil;
    aShowResults.Enabled   := UDOpenStudy <> nil;
    aPPAddAllFront.Enabled := UDOpenStudy <> nil;
    aPPAddAllSide.Enabled  := UDOpenStudy <> nil;
    aShowDiagram.Enabled   := UDOpenStudy <> nil;
    aComCalibrate2.Enabled := UDOpenStudy <> nil;

    aCOMDelMarkPMTObjs.Enabled := NumMarked > 0;
    aCOMDelele.Enabled    := aCOMDelMarkPMTObjs.Enabled or
                             aOpenDelPMTObj.Enabled or
                             N_CMResForm.aObjDelete.Enabled;

  //  aCOMOpenPMTObj.Enabled := NumMarked > 0;
    aCOMOpenPMTObj.Enabled := (SelectedStudyFullFaceSlide <> nil) or
                              (SelectedStudyProfileSlide <> nil);
    aCOMImportFilesToPMTObj1.Enabled := (NumMarked <> 0) and
                                       ((SelectedStudyFullFaceSlide = nil) or
                                        (SelectedStudyProfileSlide = nil));
    aCOMImportFilesToPMTObj.Enabled := aCOMImportFilesToPMTObj1.Enabled;

    aCOMUnitePMTObjs.Enabled := NumMarked = 2;
    if aCOMUnitePMTObjs.Enabled then
    begin // check PMT object  PMTSlides[1]
      UDOpenStudy := CMMFActiveEdFrameSlideStudy;
      aCOMUnitePMTObjs.Enabled := (UDStudy.CMSStudyItemsCount = 2) and
                                  (CMMFActiveEdFrameSlideStudy <> UDStudy);
      if aCOMUnitePMTObjs.Enabled then
      begin // check PMT object  PMTSlides[0]
        TN_UDCMSlide(UDStudy) := PMTSlides[0];
        aCOMUnitePMTObjs.Enabled := (UDStudy.CMSStudyItemsCount = 2) and
                                    (CMMFActiveEdFrameSlideStudy <> UDStudy);
      end;
    end;

    aCOMSplitUnitedPMTObj.Enabled := NumMarked = 1;
    if aCOMSplitUnitedPMTObj.Enabled then
      aCOMSplitUnitedPMTObj.Enabled := (UDStudy.CMSStudyItemsCount = 4) and
                                       (CMMFActiveEdFrameSlideStudy <> UDStudy);

    aCOMSwitchUnitedPMTObjs.Enabled := NumMarked = 1;
    if aCOMSwitchUnitedPMTObjs.Enabled then
      aCOMSwitchUnitedPMTObjs.Enabled := (UDStudy.CMSStudyItemsCount = 4) and
                                         (CMMFActiveEdFrameSlideStudy <> UDStudy);

    if {(UDOpenStudy = nil) or}
       (UDOpenStudy = CMMFActiveEdFrameSlideStudy) then Exit;

    // Restore ActiveEdFrameSlideStudy and rebuild ThumbsRFrame view
    CMMFActiveEdFrameSlideStudy := UDStudy;
    ThumbsRFrame.RedrawAllAndShow();
  end;


end; // procedure TN_PMTMain5Form.PMTActsDisableProc

function TN_PMTMain5Form.DelPMTObj( AUDStudy : TN_UDCMStudy ) : Boolean;
var
  UDSlide : TN_UDCMSlide;
  UDItem  : TN_UDBase;
  WasLockedFlag : Boolean;
  LockStudyResult : Integer;

begin
  with N_CMResForm, N_CM_MainForm do
  begin
    Result := FALSE;
    LockStudyResult := CMMOpenedStudiesLockDlg( @AUDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult <> 0 then Exit;
    Result := TRUE;

    UDItem := AUDStudy.GetMapRoot.DirChild(0);
    UDSlide := K_CMStudyGetOneSlideByItem( UDItem );
    if UDSlide <> nil then
    begin
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( UDItem,
                                                     UDSlide, AUDStudy, FALSE );
      K_CMSlidesDeleteExecute( @UDSlide, 1, FALSE );
    end;

    UDItem := AUDStudy.GetMapRoot.DirChild(1);
    UDSlide := K_CMStudyGetOneSlideByItem( UDItem );
    if UDSlide <> nil then
    begin
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( UDItem,
                                                     UDSlide, AUDStudy, FALSE );
      K_CMSlidesDeleteExecute( @UDSlide, 1, FALSE );
    end;

     // Unlock Study
    if not WasLockedFlag and (cmsfIsLocked in AUDStudy.P.CMSRFlags) then
      K_CMEDAccess.EDAUnLockSlides( @TN_UDCMSlide(AUDStudy), 1, K_cmlrmSaveOpenLock );

    K_CMSlidesDeleteExecute( TN_PUDCMSlide(@AUDStudy), 1, FALSE );

    CMMFRebuildVisSlides( TRUE );
  end; // with N_CMResForm, N_CM_MainForm do

end; // function TN_PMTMain5Form.DelPMTObj

//*************************************** TN_PMTMain5Form.SetEd3FrameHeader ***
// Set frame Header by index ( 0-Front, 1-Side )
//
//     Parameters
// AFrameInd - Frame index
//
procedure TN_PMTMain5Form.SetEd3FrameHeader ( AFrameInd : Integer );
begin
  with N_CM_MainForm, CMMFEdFrames[AFrameInd] do
  begin
    if (AFrameInd and 1) = 0 then
      FrameRightCaption.Caption := 'Front view'
    else
      FrameRightCaption.Caption := 'Side view';

    ImgClibrated.Visible  := FALSE;
    STReadOnly.Visible    := FALSE;
    FinishEditing.Visible := FALSE;
    ImgHasDiagn.Visible   := FALSE;
  end;
end; // procedure TN_PMTMain5Form.SetEd3FrameHeader

//********************************************* TN_PMTMain5Form.GetCurStudy ***
// Get current selected study
//
function TN_PMTMain5Form.GetCurStudy () : TN_UDCMStudy;
var
  PMTSlides : TN_UDCMSArray;
  NumMarked : Integer;

begin
  Result := nil;
  with N_CM_MainForm do
    NumMarked := CMMGetMarkedSlidesArray( PMTSlides );
  if NumMarked = 0 then Exit;
  TN_UDCMSlide(Result) := PMTSlides[NumMarked - 1];
end; // function TN_PMTMain5Form.GetCurStudy


//************************ TN_PMTMain5Form Public Methods

//*************************************** TN_PMTMain5Form.PMTStartPointSetting ***
// Start Setting given photometric point in given (Front or Side) RFrame
//
//     Parameters
// APointName - Point Name
// ARFrameInd - ARFrame Index (0-Front, 1-Side)
//
procedure TN_PMTMain5Form.PMTStartPointSetting( ARFrameInd: Integer; APointName: String );
begin
  with N_CM_MainForm do
  begin
    CMMFSetActiveEdFrame( CMMFEdFrames[ARFrameInd], TRUE );
    K_CMAddDotCapt := APointName;
    CMMFShowStringByTimer( 'Click to place ' + APointName + ' Point' );

    if (ARFrameInd = 0) and (APointName = PMTFrontPNames[N_F_n]) then
      PMTRebuildLineAnnot(); // Create or Rebuild between the eye Line on Front View

    with N_CMResForm do
      aObjDotExecute( aObjDot );
  end;
end; // procedure TN_PMTMain5Form.PMTStartPointSetting

//***************************************** TN_PMTMain5Form.PMTFinPointSetting ***
// Fin Setting Point and start next one if needed
//
// Can be used as PMTPointFin procedure of object
//
function TN_PMTMain5Form.PMTFinPointSetting(): Integer;
var
  i: Integer;
  PrevPoint: TDPoint;
  Label AllPointsExist;
begin
  Assert( Assigned(N_PMTVizForm), 'Bad N_PMTVizForm in PMTFinPointSetting' );
  Result := 0; // do not Stop PMTTimer (GridVizard exists)

  with N_CM_MainForm, N_PMTVizForm.StringGrid do
  begin
//    PointWasCreated := CMMFActiveEdFrame.EdViewEditMode = cmrfemPoint;
    Assert( (PMTCurVizardInd >= 0) and (PMTCurVizardInd < RowCount), 'Bad PMTCurVizardInd in PMTFinPointSetting' );

    //***** Check if previous Point PrevPoint was Created or Skipped

    PMTFillOrderedPoints( 0 );

    if PMTCurRFrameInd = 0 then
      PrevPoint := PMTOrdFPoints[PMTCurVizardInd]  // Front Points
    else
      PrevPoint := PMTOrdSPoints[PMTCurVizardInd]; // Side Points
      
    if PMTPointExists( PrevPoint ) then
      PMTSetPointStatus( PMTCurVizardInd, psExists ) // update just Created Point Status
    else // Point was NOT Created
      PMTSetPointStatus( PMTCurVizardInd, psNotExists ); // update just Skipped Point Status

    if PMTCurVizardInd >= (RowCount-1) then // just Created or Skipped Point was Last one
      goto AllPointsExist;

    //********* Search for next Point to Place


    for i := PMTCurVizardInd+1 to RowCount-1 do // along all Points after PMTCurVizardInd
    begin
      if PMTGetPointStatus( i ) = psNotExists then // found, start placing i-th Point
      begin
        PMTCurVizardInd  := i;
        PMTSetPointStatus( i, psCurrent ); // update i-th Point Status
        PMTStartPointSetting( PMTCurRFrameInd, Trim(Cells[1,i]) ); // start placing i-th Point
        Selection := TGridRect( Rect(0, i, 1, i) );
        Exit;
      end;
    end; // for i := PMTCurVizardInd+1 to RowCount-1 do // along all Points after PMTCurVizardInd

    AllPointsExist: //*************************************

    N_CM_MainForm.CMMFShowStringByTimer( 'All Points Exist' );
    N_PMTVizForm.Close;
    Result := 1; // Stop PMTTimer (GridVizard no more exists)
  end; // with N_CM_MainForm do
end; // procedure TN_PMTMain5Form.PMTFinPointSetting

//***************************************** TN_PMTMain5Form.PMTGetSlideInfo ***
// Get Slide photometric points info
//
//     Parameters
// AUDSlide - slide with photometric image
// ACapts   - resulting array of photometric dots captions
// AUPoints - resulting array of photometric dots user coords
// Result - returns TPoint with image size
//
function TN_PMTMain5Form.PMTGetSlideInfo( AUDSlide: TN_UDCMSlide; out ACapts : TN_SArray; out AUPoints : TN_DPArray ) : TPoint;
var
  i, h, n : Integer;
  MapRootMeasures : TN_UDBase;
  UDVObj : TN_UDCompVis;

  PCompCoords : TN_PCompCoords;
  PLP : PFPoint;
  TmpFPoint: TFPoint;
begin
  ACapts  := nil;
  AUPoints := nil;
  Result.X := 0;
  Result.Y := 0;
  if AUDSlide = nil then Exit; // precaution

  with TN_PCMSlide(AUDSlide.P).CMSDB do
  begin
    Result.X := PixWidth;
    Result.Y := PixHeight;
  end;
  MapRootMeasures := AUDSlide.GetMeasureRoot( );
  h := MapRootMeasures.DirHigh;
  if h = -1 then Exit;

  SetLength( ACapts, h + 1 );
  SetLength( AUPoints, h + 1 );

  n := 0;
  for i := 0 to h do
  begin
    UDVObj := TN_UDCompVis(MapRootMeasures.DirChild(i));
    if not K_StrStartsWith( 'Dot', UDVObj.ObjName ) then Continue;

    ACapts[n] := TN_POneTextBlock(TN_UDParaBox(UDVObj.DirChild(2)).PSP.CParaBox.CPBTextBlocks.P())^.OTBMText;

    PCompCoords := @UDVObj.PSP.CCoords;
    PLP := PFPoint(TN_UDPolyline(UDVObj.DirChild(1)).PISP.CPCoords.P(0));
    TmpFPoint := N_Add2P( PCompCoords.BPCoords, PLP^ );
    AUPoints[n].X := TmpFPoint.X;
    AUPoints[n].Y := TmpFPoint.Y;

    Inc(n);
  end; // for i := 0 to h do

  SetLength( ACapts, n );
  SetLength( AUPoints, n );
end; // function TN_PMTMain5Form.PMTGetSlideInfo

//********************************* TN_PMTMain5Form.DelSlidePMTPointsByList ***
// Delete Slide photometric points by names list
//
//     Parameters
// AUDSlide - slide with photometric image
// ACapts   - array of photometric dots captions
// ADelListStr - commaseparated points list to delete
// Result - returns commaseparated list of names of realy deleted points
//
function  TN_PMTMain5Form.DelSlidePMTPointsByList( AUDSlide: TN_UDCMSlide;
                       ACapts : TN_SArray; const ADelListStr : string ) : string;
var
  SL, SLR : TStringList;
  i, Ind : Integer;
  MapRootMeasures : TN_UDBase;
begin
  SL := TStringList.Create;
  SLR := TStringList.Create;
  SL.CommaText := ADelListStr;
  SL.Sort;

  MapRootMeasures := AUDSlide.GetMeasureRoot();
  for i := High(ACapts) downto 0 do
    if SL.Find( ACapts[i], Ind ) then
    begin
      SLR.Add( ACapts[i] );
      MapRootMeasures.DeleteDirEntry( i );
    end;

  Result := SLR.CommaText;
  SL.Free;
  SLR.Free;
end; // function TN_PMTMain5Form.DelSlidePMTPointsByList

//************************************ TN_PMTMain5Form.PMTFillOrderedPoints ***
// Fill PMTOrdFPoints, PMTOrdSPoints, PMTOrdFPointsMM, PMTOrdSPointsMM arrays
// by points coords in RFRames 0,1 (AStartRFInd=0) or in RFRames 2,3 (AStartRFInd=2)
//
//     Parameters
// AStartRFInd  - given Start RFrame Index (0 or 2)
//
// Point Value (-1,-1) means that Point is absent
//
procedure TN_PMTMain5Form.PMTFillOrderedPoints( AStartRFInd: Integer );
var
  i, FoundInd: Integer;
  PointsCapts:  TN_SArray;
  PointsCoords: TN_DPArray;
  ImgSlide: TN_UDCMSlide;
begin
  //***** Process Front Points

  SetLength( PMTOrdFPoints,   Length(PMTFrontPNames) );
  SetLength( PMTOrdFPointsMM, Length(PMTFrontPNames) );

  for i := 0 to High(PMTOrdFPoints) do // fill all points by "No Point" flag
  begin
    PMTOrdFPoints[i].X   := -1.0;
    PMTOrdFPoints[i].Y   := -1.0;
    PMTOrdFPointsMM[i].X := -1.0;
    PMTOrdFPointsMM[i].Y := -1.0;
  end;

  if (AStartRFInd = 2) and
     (N_CM_MainForm.CMMFActiveEdFrameSlideStudy.CMSStudyItemsCount = 2) then
    Exit;

  ImgSlide := N_CM_MainForm.CMMFEdFrames[AStartRFInd+0].EdSlide;

  if ImgSlide <> nil then // Front View Slide exists
  begin
    PMTGetSlideInfo( ImgSlide, PointsCapts, PointsCoords );

//    for i := 0 to High(PointsCapts) do // along all existing Front Points
//      N_Dump1Str( Format( 'FName=%s, %8.3f  %8.3f ', [PointsCapts[i], PointsCoords[i].X, PointsCoords[i].Y] ) );

    for i := 0 to High(PointsCapts) do // along all existing Front Points
    begin
//      FoundInd := N_SearchInSArray( PMTFrontPNames, 0, -1, PointsCapts[i] );
//      FoundInd := -1; //!!!
      FoundInd := K_SearchInSArray( PMTFrontPNames, PointsCapts[i], 0, -1 );

      if FoundInd >= 0 then
        PMTOrdFPoints[FoundInd] := PointsCoords[i];
    end; // for i := 0 to High(PointsCapts) do // along all existing Front Points

    for i := 0 to High(PMTOrdFPoints) do // calc PMTOrdFPointsMM (abs coords in mm.)
    begin
      PMTOrdFPointsMM[i].X := ImgSlide.CalcMMDistance( FPoint(0,0), FPoint(PMTOrdFPoints[i].X,0) );
      PMTOrdFPointsMM[i].Y := ImgSlide.CalcMMDistance( FPoint(0,0), FPoint(0,PMTOrdFPoints[i].Y) );
    end; // for i := 0 to High(PMTOrdFPoints) do // calc PMTOrdFPointsMM (abs coords in mm.)

  end; // if ImgSlide <> nil then // Front View Slide exists


  //***** Process Side Points

  SetLength( PMTOrdSPoints,   Length(PMTSidePNames) );
  SetLength( PMTOrdSPointsMM, Length(PMTSidePNames) );

  for i := 0 to High(PMTOrdSPoints) do // fill all points by "No Point" flag
  begin
    PMTOrdSPoints[i].X := -1.0;
    PMTOrdSPoints[i].Y := -1.0;
    PMTOrdSPointsMM[i].X := -1.0;
    PMTOrdSPointsMM[i].Y := -1.0;
  end;

  ImgSlide := N_CM_MainForm.CMMFEdFrames[AStartRFInd+1].EdSlide;

  if ImgSlide <> nil then // Side View Slide exists
  begin
    PMTGetSlideInfo( ImgSlide, PointsCapts, PointsCoords );

//    for i := 0 to High(PointsCapts) do // along all existing Side Points
//      N_Dump1Str( Format( 'SName=%s, %8.3f  %8.3f ', [PointsCapts[i], PointsCoords[i].X, PointsCoords[i].Y] ) );

    for i := 0 to High(PointsCapts) do // along all existing Side Points
    begin
//      FoundInd := N_SearchInSArray( PMTSidePNames, 0, -1, PointsCapts[i] );
//      FoundInd := -1; //!!!
      FoundInd := K_SearchInSArray( PMTSidePNames, PointsCapts[i], 0, -1 );

      if FoundInd >= 0 then
        PMTOrdSPoints[FoundInd] := PointsCoords[i];
    end; // for i := 0 to High(PointsCapts) do // along all existing Side Points

    for i := 0 to High(PMTOrdSPoints) do // calc PMTOrdSPointsMM (abs coords in mm.)
    begin
      PMTOrdSPointsMM[i].X := ImgSlide.CalcMMDistance( FPoint(0,0), FPoint(PMTOrdSPoints[i].X,0) );
      PMTOrdSPointsMM[i].Y := ImgSlide.CalcMMDistance( FPoint(0,0), FPoint(0,PMTOrdSPoints[i].Y) );
    end; // for i := 0 to High(PMTOrdFPoints) do // calc PMTOrdFPointsMM (abs coords in mm.)

  end; // if ImgSlide <> nil then // Front View Slide exists

//  N_Dump1Str( 'After 8. Side' );

end; // procedure TN_PMTMain5Form.PMTFillOrderedPoints

//************************************* TN_PMTMain5Form.PMTCreateVizardForm ***
// Start creating all Points Vizard (for both Views)
//
// PMTCurRFrameInd on input is used as needed ARFrame Index (0-Front, 1-Side)
//
procedure TN_PMTMain5Form.PMTCreateVizardForm();
var
  i, CenterY, FormBordWidth, FormBordHeight: Integer;
  Ed3FrRect: TRect;
begin
  // Fill PMTOrdFPoints and PMTOrdSPoints arrays by coords of current points
  PMTFillOrderedPoints( 0 );

  PMTFinPointFuncObj := PMTFinPointSetting;
  PMTTimer.Enabled := True;

  N_PMTVizForm := TN_PMTVizForm.Create( Application ); // Create StringGrid Vizard Form
  with N_PMTVizForm do
  begin
    FormBordWidth  := Width  - ClientWidth  + 4; // +4 is experimental value
    FormBordHeight := Height - ClientHeight + 4;
//    Show();
  end; // with N_PMTVizForm do

  with N_PMTVizForm.StringGrid do
  begin
    ColWidths[0] := 45; // first  column width (Point Status)
    ColWidths[1] := 65; // second column width (Point Name)

    if PMTCurRFrameInd = 0 then // Front Points
    begin
      RowCount := Length( PMTFrontPNames ); // Needed Number of  Rows in StringGrid Vizard
      N_PMTVizForm.StringGrid.ClientWidth  := GridWidth;  // decrease ClientWidth
      N_PMTVizForm.StringGrid.ClientHeight := GridHeight; // decrease ClientHeight

      // Place StringGrid Vizard Form near needed FRame (over other RFrame)
      //   Ed3FrRect is needed FRame Coords
      Ed3FrRect := N_GetScreenRectOfControl( N_CM_MainForm.CMMFEdFrames[0].RFrame );

      N_PMTVizForm.Left  := Ed3FrRect.Right + 30;
      N_PMTVizForm.Width := GridWidth + FormBordWidth;

      CenterY := (Ed3FrRect.Top + Ed3FrRect.Bottom) div 2;
      N_PMTVizForm.Height := GridHeight + FormBordHeight; // set Height before Top!
      N_PMTVizForm.Top := CenterY - N_PMTVizForm.Height div 2;

      N_PMTVizForm.Caption := ' Front Points';
      PMTCurVizardInd  := -1;

      //***** Find first Front Point that is not exists (was not Placed yet)

      for i := 0 to High(PMTOrdFPoints) do // along all Vizard Rows
      begin
        Cells[1,i] := '   ' + PMTFrontPNames[i];

        if PMTPointExists( PMTOrdFPoints[i] ) then // i-th Point Exists
        begin
          PMTSetPointStatus( i, psExists );
        end else // i-th Point Not Exists
        begin
          if PMTCurVizardInd = -1 then // make i-th Point Current
          begin
            PMTCurVizardInd  := i;
            PMTSetPointStatus( i, psCurrent );
            PMTStartPointSetting ( PMTCurRFrameInd, PMTFrontPNames[i] );
            Selection := TGridRect( Rect(0, i, 1, i) );
          end else
            PMTSetPointStatus( i, psNotExists );
        end; // else // i-th Point Not Exists

      end; // for i := 0 to High(PMTOrdFPoints) do // along all Vizard Rows

      if PMTCurVizardInd = -1 then // All Points already Exist, nothing to Place
      begin
        N_CM_MainForm.CMMFShowStringByTimer( 'All Fronts Points Exist' );
        N_PMTVizForm.Close;
        Exit;
      end else // All Done, exit and wait to Create PMTCurVizardInd Point by Mouse Click
        N_PMTVizForm.Show();

    end else //********************** ARFrameInd = 1, Side Points
    begin
      RowCount := Length( PMTSidePNames ); // Needed Number of  Rows in StringGrid Vizard
      N_PMTVizForm.StringGrid.ClientWidth  := GridWidth;  // decrease ClientWidth
      N_PMTVizForm.StringGrid.ClientHeight := GridHeight; // decrease ClientHeight

      // Place StringGrid Vizard Form near needed FRame (over other RFrame)
      //   Ed3FrRect is needed FRame Coords
      Ed3FrRect := N_GetScreenRectOfControl( N_CM_MainForm.CMMFEdFrames[1].RFrame );

      N_PMTVizForm.Width := GridWidth + FormBordWidth;
      N_PMTVizForm.Left  := Ed3FrRect.Left - N_PMTVizForm.Width - 30;

      CenterY := (Ed3FrRect.Top + Ed3FrRect.Bottom) div 2;
      N_PMTVizForm.Height := GridHeight + FormBordHeight; // set Height before Top!
      N_PMTVizForm.Top := CenterY - N_PMTVizForm.Height div 2;

      N_PMTVizForm.Caption := ' Side Points';
      PMTCurVizardInd  := -1;

      //***** Find first Side Point that is not exists (was not Placed yet)

      for i := 0 to High(PMTOrdSPoints) do // along all Vizard Rows
      begin
        Cells[1,i] := '   ' + PMTSidePNames[i];

        if PMTPointExists( PMTOrdSPoints[i] ) then // i-th Point Exists
        begin
          PMTSetPointStatus( i, psExists );
        end else // i-th Point Not Exists
        begin
          if PMTCurVizardInd = -1 then // make i-th Point Current
          begin
            PMTCurVizardInd  := i;
            PMTSetPointStatus( i, psCurrent );
            PMTStartPointSetting ( PMTCurRFrameInd, PMTSidePNames[i] );
            Selection := TGridRect( Rect(0, i, 1, i) );
          end else
            PMTSetPointStatus( i, psNotExists );
        end; // else // i-th Point Not Exists

      end; // for i := 0 to High(PMTOrdSPoints) do // along all Vizard Rows

      if PMTCurVizardInd = -1 then // All Points already Exist, nothing to Place
      begin
        N_CM_MainForm.CMMFShowStringByTimer( 'All Side Points Exist' );
        N_PMTVizForm.Close;
        Exit;
      end else // All Done, exit and wait to Create PMTCurVizardInd Point by Mouse Click
        N_PMTVizForm.Show();

    end; // else //****************** ARFrameInd = 1, Side Points

  end; // with N_PMTVizForm.StringGrid do

//  N_ShowPMTHelpImage();

end; // procedure TN_PMTMain5Form.PMTCreateVizardForm

//****************************************** TN_PMTMain5Form.PMTPointExists ***
// Check if given AFPoint exists ( is not (1,-1) )
//
//     Parameters
// AFPoint - Given Point to Check
// Return  - True if AFPoint exists or False if it is = (1,-1)
//
function TN_PMTMain5Form.PMTPointExists( AFPoint: TDPoint ): Boolean;
begin
  Result := True;

  if (AFPoint.X = -1.0) and (AFPoint.Y = -1.0) then
    Result := False;
end; // function TN_PMTMain5Form.PMTNoPoint

//*************************************** TN_PMTMain5Form.PMTSetPointStatus ***
// Set Given Point Status in Vizard StringGrid left Column (psNotExists,psCurrent,psExists)
// and Show Help Image if APointStatus=psCurrent
//
//     Parameters
// APointInd    - given Point Index
// APointStatus - Point Status in Vizard StringGrid left Column (psNotExists,psCurrent,psExists)
//
// If APointStatus = psCurrent, Show Help Image with curretn Point
//
procedure TN_PMTMain5Form.PMTSetPointStatus( APointInd: Integer; APointStatus: TN_PMTPointStatus );
var
  Str: String;
begin
  if N_PMTVizForm = nil then Exit; // a precaution

  case APointStatus of
    psNotExists: Str := '  -';
    psCurrent:   Str := ' -->>';
    psExists:    Str := '  +';
  end; // case APointStatus of

  with N_PMTVizForm.StringGrid do
  begin
    Assert( (APointInd >= 0) and (APointInd < RowCount), 'Bad APointInd in PMTSetPointStatus' );
    Cells[0,APointInd] := Str;
  end; // with N_PMTVizForm.StringGrid do

  N_PMTVizForm.Repaint();

  if APointStatus = psCurrent then // Show Help Image
    N_ShowPMTHelpImage();

end; // procedure TN_PMTMain5Form.PMTSetPointStatus

//*************************************** TN_PMTMain5Form.PMTGetPointStatus ***
// Get Given Point Status in Vizard StringGrid left Column (psNotExists,psCurrent,psExists)
//
//     Parameters
// APointInd  - given Point Index
// Return     - Point Status in Vizard StringGrid left Column (psNotExists,psCurrent,psExists)
//
function TN_PMTMain5Form.PMTGetPointStatus( APointInd: Integer ): TN_PMTPointStatus;
var
  Str: String;
begin
  Result := psExists; // just to avoid warning
  if N_PMTVizForm = nil then Exit; // a precaution

  with N_PMTVizForm.StringGrid do
  begin
    Assert( (APointInd >= 0) and (APointInd < RowCount), 'Bad APointInd in PMTSetPointStatus' );
    Str := Cells[0,APointInd];

    if Length(Str) > 3 then
      Result := psCurrent
    else if Str[3] = '-' then
      Result := psNotExists
    else
      Result := psExists;
  end; // with N_PMTVizForm.StringGrid do

end; // function TN_PMTMain5Form.PMTGetPointStatus

//******************************************** TN_PMTMain5Form.PMTCalcFName ***
// Calculate resulting File Name without Extention, create all needed directories
// ѕрефикс\‘јћ»Ћ»я_»ќ-ƒƒ.ћћ.√√\‘јћ»Ћ»я_»ќ-ƒƒ.ћћ.√√-ƒƒ.ћћ.√√(»)-ƒƒ.ћћ.√√(T)
//   ƒƒ.ћћ.√√    - Patient DOB
//   ƒƒ.ћћ.√√(») - Study Date
//   ƒƒ.ћћ.√√(T) - Current Date Time
//
//     Parameters
// Return - Full File Name without Extention
//
function TN_PMTMain5Form.PMTCalcFName(): String;
var
  FName1, FName2, IO, FIODOB: String;
begin
  FName1 := N_MemIniToString( 'CMS_UserMain', 'PMTResFName', 'C:\PMTResults\' ); // File Name Prefix
  FName2 := K_ExpandFileName( FName1 );

  if Length(PMTCI) >=1 then IO := PMTCI[1];
  if Length(PMTCO) >=1 then IO := IO + PMTCO[1];

  FIODOB := PMTCF + '_' + IO + '-' + PMTCDOB;
  FName2 := FName2 + FIODOB + '\'; // FName2 now contains all needed Dirs
  N_b := K_ForceDirPath( FName2 );
  FName2 := FName2 + FIODOB + '-' + PMTCStudyDate; // add File Name (without CurDateTime) to Dirs Name
  Result := FName2 + '-' + K_DateTimeToStr( Now(), 'dd-mm-yy_hh-nn-ss' ); // add CurDateTime

end; // function TN_PMTMain5Form.PMTCalcFName(): String;

//****************************************** TN_PMTMain5Form.PMTCalcResults ***
// if AStartRFInd = 0 then Calc Results in:
//    PMTResults, PMTResDeltaV, PMTResDeltaS, PMTResProbS using RFrames 0, 1
// else (AStartRFInd = 2) Calc Results in:
//    PMTResults2, PMTResDeltaV2, PMTResDeltaS2, PMTResProbS2 using RFrames 2, 3
//    ( PMTResults, PMTResDeltaV, PMTResDeltaS, PMTResProbS changed! (became the same) )
//
//     Parameters
// AStartRFInd  - given Start RFrame Index (0 or 2)
//
procedure TN_PMTMain5Form.PMTCalcResults( AStartRFInd: Integer );
var
  i, ResInd: Integer;
  D2, Eps, PLVsn, PLVsto, PLVpg: Double;
  n2, L, L2, strl: TDPoint; // xt,

  function Dist( ADP1, ADP2: TDPoint ): Double;
  // local function - Calc Distance between two Points
  begin
    Result := N_P2PDistance( ADP1, ADP2 );
  end; // function Dist( ADP1, ADP2: TDPoint ): Double;

  function Angle4( ADP1, ADP2, ADP3, ADP4: TDPoint ): Double;
  // local function - Calc Angle between two segments (ADP1,ADP2) and (ADP3,ADP4)
  // rotate from (ADP3,ADP4) to (ADP1,ADP2) Counterclockwise
  // Angle4( DPoint(0,0), DPoint(1,0), DPoint(0,0), DPoint(1,1) ) = 45
  //
  begin
    Result := N_SegmAngle( ADP1, ADP2 ) - N_SegmAngle( ADP3, ADP4 );
  end; // function Angle4( ADP1, ADP2, ADP3, ADP4: TDPoint ): Double;

  function Angle3( ADP1, ADP2, ADP3: TDPoint ): Double;
  // local function - Calc Angle between two segments  (ADP2,ADP3) (ADP2,ADP1)
  // rotate from (ADP2,ADP3) to (ADP2,ADP1) Counterclockwise
  // Angle3( DPoint(1,1), DPoint(0,0), DPoint(0,1) ) = 45
  begin
    Result := N_SegmAngle( ADP2, ADP1 ) - N_SegmAngle( ADP2, ADP3 );
  end; // function Angle3( ADP1, ADP2, ADP3: TDPoint ): Double;

  function Norm( AAngle: double ): Double;
  // local function - Normalize AAngle to 0 - 180 range
  begin
    Result := abs( AAngle );

    if Result > 180 then Result := 360 - Result;
  end; // function Dist( ADP1, ADP2: TDPoint ): Double;

begin
{
  N_d := Dist( DPoint(0,0), DPoint(1,1) ); // 1.41..
  N_d := Angle4( DPoint(0,0), DPoint(1,0), DPoint(0,0), DPoint(1,1) ); // 45
  N_d := Angle4( DPoint(0,0), DPoint(1,1), DPoint(0,1), DPoint(1,1) ); // -45
  N_d := Angle3( DPoint(1,1), DPoint(0,0), DPoint(0,1) ); // 45
  N_d := Angle3( DPoint(0,1), DPoint(0,0), DPoint(1,1) ); // -45
  N_dp := N_CalcCrossPoint( DPoint(0,0), DPoint(1,1), DPoint(0,1), DPoint(1,0) ); // (0.5,0.5)
  N_dp := N_CalcCrossPoint( DPoint(0,0), DPoint(1,1), DPoint(0,1), DPoint(1,1) ); // (1,1)
  N_dp := N_CalcCrossPoint( DPoint(0,0), DPoint(1,1), DPoint(0,0), DPoint(0,1) ); // (0,0)
  N_dp := N_CalcCrossPoint( DPoint(0,0), DPoint(1,1), DPoint(0,0), DPoint(2,2) ); // (0,0)
  N_dp := N_CalcCrossPoint( DPoint(0,0), DPoint(1,0), DPoint(0,1), DPoint(1,1) ); // (none)
}

  N_Dump1Str( 'Start PMTCalcResults()' );

//  PMTPatNames := '»ванов »ван »ванович'; // Patient Names (temporary for no DB version)
//  PMTPatDOB   := '21.11.1991';           // Patient DOB (temporary for no DB version)

  // Fill PMTOrdFPoints and PMTOrdSPoints arrays by coords of current points
  // in RFrames 0,1 or 2,3
  PMTFillOrderedPoints( AStartRFInd );
  N_Dump1Str( 'After PMTFillOrderedPoints()' );

  SetLength( PMTResults, N_Params ); // All Results (in var1: 0-3 Front, 4-14 Side, 15FS)
  for i := 0 to N_Params-1 do PMTResults[i] := N_NotADouble;

  if PMTCSumma4R = '' then
    PMTCoefNorm := 1.0
  else
  begin
    N_s := PMTCSumma4R;
    PMTCoefNorm := N_ScanDouble( N_s ); // N_ScanDouble changes N_s!

    if PMTCoefNorm = N_NotADouble then // in versions <= 4.030.26
      PMTCoefNorm := 1.0
//      PMTCoefNorm := 1.1 // for debug
    else
      PMTCoefNorm := PMTCoefNorm / 33.0;
  end;

  PMTCoefNorm := 1.0; // In versions  >= 4.030.28 PMTCSumma4R is not used

  SetLength( PMTNorm,      N_Params ); // Real (calculated by PMTCoefNorm) Norm
  SetLength( PMTNormDelta, N_Params ); // Real (calculated by PMTCoefNorm) Norm and delta as string
  for i := 0 to N_Params-1 do
  begin
    if i <> 3 then
      PMTNorm[i] := PMTBaseNorm[i] * PMTCoefNorm // Calculate Real Norm (double)
    else // i = 3 special case
      PMTNorm[i] := PMTBaseNorm[i]; // Real Norm = Base Norm

    PMTNormDelta[i] := Format( '%6.2f', [PMTNorm[i]] ) + PMTBaseDelta[i]; // Calculated Real Norm+/-Delta (string)
  end; // for i := 0 to N_Params-1 do

  if PMTOrdFPointsMM[N_F_str].X = -1.0 then Exit; // Points do not exist

  Eps := 1.0/1000000; // e-6

  strl.X := (PMTOrdFPointsMM[N_F_str].X + PMTOrdFPointsMM[N_F_stl].X) / 2.0;
  strl.Y := (PMTOrdFPointsMM[N_F_str].Y + PMTOrdFPointsMM[N_F_stl].Y) / 2.0;


  //***** Front View Results

  //***********************************************************************
  // 1.	nЦsn/snЦgn - соотношение верхней передней высоты лица и нижней передней высоты лица
  ResInd := 0;
//  PMTResNames[ResInd] := '   nЦsn/snЦgn';
  D2 := Dist( PMTOrdFPointsMM[N_F_sn], PMTOrdFPointsMM[N_F_gn] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_n], PMTOrdFPointsMM[N_F_sn] ) / D2;
//  N_Dump1Str( 'After 1.	nЦsn/snЦgn' );

  //***********************************************************************
  // 2.	sn-sto/sto-gn - соотношение высот средней и нижней трети лица
  //                   xt - пересечение sn-gn и str-stl, strl=(str+stl)/2
  ResInd := 1;
//  PMTResNames[ResInd] := '   sn-sto/sto-gn';
//  xt := N_CalcCrossPoint( PMTOrdFPointsMM[N_F_sn],  PMTOrdFPointsMM[N_F_gn],
//                          PMTOrdFPointsMM[N_F_str], PMTOrdFPointsMM[N_F_stl] );
//  D2 := Dist( xt, PMTOrdFPointsMM[N_F_gn] );

  D2 := Dist( strl, PMTOrdFPointsMM[N_F_gn] );

  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
//    PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_sn], xt ) / D2;
    PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_sn], strl ) / D2;
//  N_Dump1Str( 'After 2.' );

  //***********************************************************************
  // 3.	st-st>n-sn - угол ...
  ResInd := 2;
//  PMTResNames[ResInd] := '/_ st-st/n-sn';
  PMTResults[ResInd] := Angle4( PMTOrdFPointsMM[N_F_str], PMTOrdFPointsMM[N_F_stl],
                                PMTOrdFPointsMM[N_F_n],   PMTOrdFPointsMM[N_F_sn] );
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 3.' );

  //***********************************************************************
  // 4.	n-sn>n-gn   - угол, показывает степень смещени€ подбородка от вертикальной линии лица
  ResInd := 3;
//  PMTResNames[ResInd] := '/_ sn-n-gn';
  PMTResults[ResInd] := -Angle4( PMTOrdFPointsMM[N_F_n],   PMTOrdFPointsMM[N_F_sn],
                                 PMTOrdFPointsMM[N_F_n],   PMTOrdFPointsMM[N_F_gn] );
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 4.' );


  //***** Side View Results

  //***********************************************************************
  // 1. ”гол n/sn/pg - угол профил€ лица
  ResInd := 4;
//  PMTResNames[ResInd] := '/_ n/sn/pg';
  PMTResults[ResInd] := 360 - Angle3( PMTOrdSPointsMM[N_S_n], PMTOrdSPointsMM[N_S_sn],
                                      PMTOrdSPointsMM[N_S_pg] );
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 1. Side' );

  //***********************************************************************
  // 2.	”гол po/n/sn - угол, характеризующий положение точки sn по отношению к референтной линии
  ResInd := 5;
//  PMTResNames[ResInd] := '/_ Po/n/sn';
  PMTResults[ResInd] := Abs(Angle3( PMTOrdSPointsMM[N_S_po],   PMTOrdSPointsMM[N_S_n],
                                    PMTOrdSPointsMM[N_S_sn] ));
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 2. Side' );

  //***********************************************************************
  // 3.	”гол po/n/sm - угол, характеризующий положение точки sm по отношению к референтной линии
  ResInd := 6;
//  PMTResNames[ResInd] := '/_ Po/n/sm';
  PMTResults[ResInd] := Abs(Angle3( PMTOrdSPointsMM[N_S_po],   PMTOrdSPointsMM[N_S_n],
                                    PMTOrdSPointsMM[N_S_sm] ));
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 3. Side' );

  //***********************************************************************
  // 4.	”гол po/n/pg - угол, характеризующий положение передней точки подбородочного отдела по отношению к референтной линии
  ResInd := 7;
//  PMTResNames[ResInd] := '/_ Po/n/pg';
  PMTResults[ResInd] := Abs(Angle3( PMTOrdSPointsMM[N_S_po],   PMTOrdSPointsMM[N_S_n],
                                    PMTOrdSPointsMM[N_S_pg] ));
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );
//  N_Dump1Str( 'After 4. Side' );

  //***********************************************************************
  // 5.	ta-tp>sn-n   - шейный угол наклона касательной глоточной части, проведенной через точку NTA, к вертикальной линии лица.
  ResInd := 8;
//  PMTResNames[ResInd] := '/_ ta-tp/sn-n';
  PMTResults[ResInd] := Angle4( PMTOrdSPointsMM[N_S_ta],  PMTOrdSPointsMM[N_S_tp],
                                PMTOrdSPointsMM[N_S_sn],  PMTOrdSPointsMM[N_S_n] );
  PMTResults[ResInd] := Norm( PMTResults[ResInd] );

  //***********************************************************************
  // 6.	po-n/po-sn  - соотношение рассто€ний референтной линии к сагиттальной длине po-sn
  ResInd := 9;
//  PMTResNames[ResInd] := '   Po-n/Po-sn';
  D2 := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_sn] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / D2;

  //***********************************************************************
  // 7.	po-n/po-sto - соотношение рассто€ний референтной линии к сагиттальной длине po-sto
  ResInd := 10;
//  PMTResNames[ResInd] := '   Po-n/Po-sto';
  D2 := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_sto] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / D2;

  //***********************************************************************
  // 8.	Po-n/Po-pg  - соотношение рассто€ний референтной линии к сагиттальной длине po-pg
  ResInd := 11;
//  PMTResNames[ResInd] := '   Po-n/Po-pg';
  D2 := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_pg] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / D2;


  //  	PL  - перпендикул€р к линии po-n из точки n, задаетс€ точками n и n2
  //	  L   - (построенна€ точка) - пересечение линии po-or и PL(n,n2)
  //	  PLV - перпендикул€р к линии po-or из точки L, задаетс€ точками L и L2

  n2 := N_CalcPerpendicular( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n], PMTOrdSPointsMM[N_S_n] );

  L  := N_CalcCrossPoint( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_or],
                          PMTOrdSPointsMM[N_S_n], n2 );
  N_Dump1Str( Format( 'L = %8.3f  %8.3f ', [L.X, L.Y] ) );

  L2 := N_CalcPerpendicular( PMTOrdSPointsMM[N_S_po], L, L );

  //***********************************************************************
  // 9.	po-n/PLV-sn  - соотношение рассто€ний референтной линии к сагиттальной длине PLV-sn
  ResInd := 12;
//  PMTResNames[ResInd] := '   Po-n/PLV-sn';
  PLVsn := N_P2LSDistance( PMTOrdSPointsMM[N_S_sn], L, L2 );
  if PLVsn < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / PLVsn;

  //***********************************************************************
  // 10.	po-n/PLV-sto  - соотношение рассто€ний референтной линии к сагиттальной длине PLV-sto
  ResInd := 13;
//  PMTResNames[ResInd] := '   Po-n/PLV-sto';
  PLVsto := N_P2LSDistance( PMTOrdSPointsMM[N_S_sto], L, L2 );
  if PLVsto < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / PLVsto;

  //***********************************************************************
  // 11.	po-n/PLV-pg  - соотношение рассто€ний референтной линии к сагиттальной длине PLV-pg
  ResInd := 14;
//  PMTResNames[ResInd] := '   Po-n/PLV-pg';
  PLVpg := N_P2LSDistance( PMTOrdSPointsMM[N_S_pg], L, L2 );
  if PLVpg < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_S_po], PMTOrdSPointsMM[N_S_n] ) / PLVpg;


  //***** Front-Side View Results

  //***********************************************************************
  // FS1.	Po(R)-Po(L)/Po-n - новый фас-профиль параметр
  ResInd := 15;
//  PMTResNames[ResInd] := 'Po(L)-Po(R)/Po-n';
  D2 := Dist( PMTOrdSPointsMM[N_S_Po], PMTOrdSPointsMM[N_S_n] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_PoL], PMTOrdFPointsMM[N_F_PoR] ) / D2;

  //***********************************************************************
  // nЦsn/snЦgn - соотношение верхней передней высоты лица и нижней передней высоты лица
  ResInd := 20;
//  PMTResNames[ResInd] := '   nЦgn/nЦsn';
  D2 := Dist( PMTOrdFPointsMM[N_F_n], PMTOrdFPointsMM[N_F_sn] );
  if D2 < Eps then
    PMTResults[ResInd] := N_NotADouble
  else
    PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_n], PMTOrdFPointsMM[N_F_gn] ) / D2;

//  N_Dump1Str( 'After 20.	nЦgn/nЦsn' );


  //***** Front View abs Params in mm.

  //***********************************************************************
  // Po(L)-Po(R)
  ResInd := 21;
  //  PMTResNames[ResInd] := 'Po(L)-Po(R)';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_PoL], PMTOrdFPointsMM[N_F_PoR] );

  //***********************************************************************
  // nЦgn
  ResInd := 22;
  //  PMTResNames[ResInd] := 'nЦgn';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_n], PMTOrdFPointsMM[N_F_gn] );

  //***********************************************************************
  // nЦsn
  ResInd := 23;
  //  PMTResNames[ResInd] := 'nЦsn';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_n], PMTOrdFPointsMM[N_F_sn] );

  //***********************************************************************
  // snЦgn
  ResInd := 24;
  //  PMTResNames[ResInd] := 'snЦgn';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_sn], PMTOrdFPointsMM[N_F_gn] );

  //***********************************************************************
  // snЦsto,  strl=(str+stl)/2

  ResInd := 25;
  //  PMTResNames[ResInd] := 'snЦsto';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_sn], strl );

  //***********************************************************************
  // stoЦgn,  strl=(str+stl)/2
  ResInd := 26;
  //  PMTResNames[ResInd] := 'stoЦgn';
  PMTResults[ResInd] := Dist( PMTOrdFPointsMM[N_F_gn], strl );


  //***** Side View abs Params in mm.

  //***********************************************************************
  // PoЦn
  ResInd := 27;
  //  PMTResNames[ResInd] := 'PoЦn';
  PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_s_Po], PMTOrdSPointsMM[N_s_n] );

  //***********************************************************************
  // PoЦsn
  ResInd := 28;
  //  PMTResNames[ResInd] := 'PoЦsn';
  PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_s_Po], PMTOrdSPointsMM[N_s_sn] );

  //***********************************************************************
  // PoЦsto
  ResInd := 29;
  //  PMTResNames[ResInd] := 'PoЦsto';
  PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_s_Po], PMTOrdSPointsMM[N_s_sto] );

  //***********************************************************************
  // PoЦsm
  ResInd := 30;
  //  PMTResNames[ResInd] := 'PoЦsm';
  PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_s_Po], PMTOrdSPointsMM[N_s_sm] );

  //***********************************************************************
  // PoЦpg
  ResInd := 31;
  //  PMTResNames[ResInd] := 'PoЦpg';
  PMTResults[ResInd] := Dist( PMTOrdSPointsMM[N_s_Po], PMTOrdSPointsMM[N_s_pg] );

  //***********************************************************************
  // PLVЦsn
  ResInd := 32;
  //  PMTResNames[ResInd] := 'PLVЦsn';
  PMTResults[ResInd] := -PLVsn;

  //***********************************************************************
  // PLVЦsto
  ResInd := 33;
  //  PMTResNames[ResInd] := 'PLVЦsto';
  PMTResults[ResInd] := -PLVsto;

  //***********************************************************************
  // PLVЦpg
  ResInd := 34;
  //  PMTResNames[ResInd] := 'PLVЦpg';
  PMTResults[ResInd] := -PLVpg;


  //***** All PMTResults[0-33] are calculated
  //      Calc PMTResDeltaV, PMTResDeltaS, PMTResProbS, PMTResDiagrV

  SetLength( PMTResDeltaV, N_Params ); // отклонение от скорректированной нормы в процентах (as double)
  SetLength( PMTResDeltaS, N_Params ); // отклонение (as string): '-' <3, '>60.0' or value in (3-60)
  SetLength( PMTResProbS,  N_Params ); // веро€тность (as string): 'норма' (<=3), '*' (<=6), '**' (<=9), '***' (>9)
  SetLength( PMTResDiagrV, N_Params ); // баллы дл€ диаграмы: 0 (<=3), 1 (<=30), 2 (<=60), 3 (>60)

  PMTResDiagr_B := 0;
  PMTResDiagr_C := 0;
  PMTResDiagr_T := 0;

  for i := 0 to N_Params-1 do // Calc PMTResDeltaV, PMTResDeltaS, PMTResProbS, PMTResDiagrV
  begin
    PMTResDeltaV[i] := N_NotADouble;
    PMTResDeltaS[i] := '-';
    PMTResProbS[i]  := '-';

    if (PMTNorm[i] = N_NotADouble) or (PMTResults[i] = N_NotADouble) or
       (abs(PMTNorm[i]) < Eps) then Continue;

//    if i = 15 then // debug
//      N_i := 1;

    PMTResDeltaV[i] := 100.0 * abs((PMTNorm[i] - PMTResults[i]) / PMTNorm[i]); // Delta Value in Percents

    if PMTResDeltaV[i] > 60.0 then
      PMTResDeltaS[i] := '>60.0'
    else if PMTResDeltaV[i] > 3.0 then
      PMTResDeltaS[i] := Format( '%6.3f', [PMTResDeltaV[i]] );

    if PMTResDeltaV[i] <= 3.0 then
      PMTResProbS[i] := 'норма'
    else if PMTResDeltaV[i] <= 6.0 then
      PMTResProbS[i] := '  *  '
    else if PMTResDeltaV[i] <= 9.0 then
      PMTResProbS[i] := ' **  '
    else // PMTResDeltaV[i] > 9.0
      PMTResProbS[i] := ' *** ';

    if PMTResDeltaV[i] <= 3.0 then PMTResDiagrV[i] := 0
    else if PMTResDeltaV[i] <= 30  then PMTResDiagrV[i] := 1
    else if PMTResDeltaV[i] <= 60  then PMTResDiagrV[i] := 2
    else PMTResDiagrV[i] := 3;

    if PMTResPlos[i][1] = 'B' then
      PMTResDiagr_B := PMTResDiagr_B + 100.0*PMTResDiagrV[i]/(3*8)
    else if PMTResPlos[i][1] = 'C' then
      PMTResDiagr_C := PMTResDiagr_C + 100.0*PMTResDiagrV[i]/(3*14)
    else if PMTResPlos[i][1] = 'T' then
      PMTResDiagr_T := PMTResDiagr_T + 100.0*PMTResDiagrV[i]/(3*4);

    N_Dump1Str( Format( 'i=%d, DeltaV=%3.1f, DiagrV=%3.1f, Plos=%s   %.1f %.1f %.1f',
                        [i, PMTResDeltaV[i], PMTResDiagrV[i], PMTResPlos[i],
                            PMTResDiagr_B, PMTResDiagr_C, PMTResDiagr_T] ) );

  end; // for i := 0 to N_Params-1 do // Calc PMTResDeltaV, PMTResDeltaS, PMTResProbS

  //***** Copy just calulated values to PMTResults2, PMTResDeltaV2, PMTResDeltaS2, PMTResProbS2
  //      if AStartRFInd = 2

  if AStartRFInd = 2 then // Copy just calulated values
  begin
    SetLength( PMTResults2,   N_Params );
    SetLength( PMTResDeltaV2, N_Params );
    SetLength( PMTResDeltaS2, N_Params );
    SetLength( PMTResProbS2,  N_Params );
    SetLength( PMTResDiagrV2, N_Params );

    for i := 0 to N_Params-1 do
    begin
      PMTResults2[i]   := PMTResults[i];
      PMTResDeltaV2[i] := PMTResDeltaV[i];
      PMTResDeltaS2[i] := PMTResDeltaS[i];
      PMTResProbS2[i]  := PMTResProbS[i];
      PMTResDiagrV2[i] := PMTResDiagrV[i];
    end; // for i := 0 to N_Params-1 do

    PMTResDiagr_B2 := PMTResDiagr_B;
    PMTResDiagr_C2 := PMTResDiagr_C;
    PMTResDiagr_T2 := PMTResDiagr_T;

  end; // if AStartRFInd = 2 then // Copy just calulated values

  N_Dump1Str( 'End of PMTCalcResults' );

end; // procedure TN_PMTMain5Form.PMTCalcResults

//**************************************** TN_PMTMain5Form.PMTResultsToHTML ***
// Prepare caculated Results in HTML format in given AStrings
//
procedure TN_PMTMain5Form.PMTResultsToHTML( AStrings: TStrings );
var
  i, j: Integer;
  Str: String;
  SL: TStrings;
begin
  SL := AStrings; // for nice code only
  SL.Clear;

  Str := '<html><body><p> <font size="5">' + PMTCFIO + ',  ' + PMTCDOB
                                           + '</font></p> <br>';
  SL.Add( Str );
  SL.Add( '' );
  SL.Add( '<table border=1 cellpadding=5 width=900>' );
  SL.Add( '<tr align=center bgcolor="#AAAAAA" >' );
  SL.Add( '  <td width="15%"><font size="3">параметр</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">до лечени€<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">в процессе<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">после<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">N</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">откл. от N</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">delta (%)</font></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );
  SL.Add( '<tr align=center bgcolor="#CCCCCC">' );
  SL.Add( '  <td><font size="3">‘ј—</font></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );

  for i := 0 to 4 do // along all Front View Results
  begin
    if i = 4 then j := 15 // Front-side Param
             else j := i; // Front Params

    SL.Add( '<tr align=center>' );
    SL.Add( '  <td>' + PMTResNames[j] + '</td>' );
    SL.Add( '  <td>' + Format( '%05.3f', [PMTResults[j]] ) + '</td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '</tr>' );
    SL.Add( '' );

  end; // for i := 0 to 4 do // along all Front View Results

  SL.Add( '<tr align=center bgcolor="#CCCCCC">' );
  SL.Add( '  <td><font size="3">ѕ–ќ‘»Ћ№</font></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );


  for i := 4 to 14 do // along all Side View Results
  begin
    SL.Add( '<tr align=center>' );
    SL.Add( '  <td>' + PMTResNames[i] + '</td>' );
    SL.Add( '  <td>' + Format( '%05.3f', [PMTResults[i]] ) + '</td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '</tr>' );
    SL.Add( '' );
  end; // for i := 6 to 16 do // along all Side View Results

end; // procedure TN_PMTMain5Form.PMTResultsToHTML

//*************************************** TN_PMTMain5Form.PMTResultsToHTML2 ***
// Prepare caculated Results in HTML format in given AStrings
//
procedure TN_PMTMain5Form.PMTResultsToHTML2( AStrings: TStrings );
var
  i: Integer;
  SL: TStrings;
  FourRFramesStudy: Boolean;

  function CreateResStr( AResInd: integer ): string; // local
  begin
    Result := '<tr align=center>' +
              '  <td>' + PMTResPlos[AResInd] + '</td>' +
                '<td bgcolor="#CCFFCC">' + PMTResNames[AResInd] + '</td>'  +  // light green
                '<td bgcolor="#FFFFAA">' + PMTNormDelta[AResInd] + '</td>' +  // yellow
                '<td>' + Format( '%07.3f', [PMTResults[AResInd]] ) + '</td>' +
                '<td>' + PMTResDeltaS[AResInd] + '</td>' +
                '<td>' + PMTResProbS[AResInd] + '</td> ';

    if FourRFramesStudy then
    begin
      Result := Result +
                '<td>' + Format( '%07.3f', [PMTResults2[AResInd]] ) + '</td>' +
                '<td>' + PMTResDeltaS2[AResInd] + '</td>' +
                '<td>' + PMTResProbS2[AResInd] + '</td>';
    end;

    Result := Result + '</tr>';

  end; // function CreateResStr( AResInd: integer ): string; // local

begin
  SL := AStrings; // for nice code only
  SL.Clear;

  FourRFramesStudy := N_CM_MainForm.CMMFActiveEdFrameSlideStudy.CMSStudyItemsCount = 4;
//  N_s := TN_PCMSlide(N_CM_MainForm.CMMFActiveEdFrameSlideStudy.P())^.CMSDiagn;

  SL := AStrings;
  SL.Clear;
  SL.Add( '<html><body><p> <font size="4">' );
  SL.Add( PMTMainHeader + '<br>' );
  SL.Add( '<br>' );
  SL.Add( PMTNCardNumber + '  ' + PMTCCardNumber + '<br>' );
  SL.Add( PMTNFIO        + '  ' + PMTCFIO + '<br>' );
  SL.Add( PMTNDOB        + '  ' + PMTCDOB + '<br>' );

  //***** PMTCDiagn was set in aShowResultsExecute

  if PMTCDiagn.Count >= 1 then // Diagn exists
  begin
    SL.Add( PMTNDiagn      + '  ' + PMTCDiagn[0] + '<br>' );

    for i := 1 to PMTCDiagn.Count-1 do
      SL.Add( '  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + PMTCDiagn[i] + '<br>' );
  end; // if PMTCDiagn.Count >= 1 then // Diagn exists

  SL.Add( PMTNDoctor     + '  ' + PMTCDoctor + '<br>' );
  SL.Add( PMTNStudyDate  + '  ' + PMTCStudyDate + '<br>' );
  SL.Add( '<br>' );
  SL.Add( PMTNSumma4R  + PMTCSumma4R + ' мм<br>' );
  SL.Add( '</font></p> <br>' );

//  SL.Add( '<font size="3">' );

  SL.Add( '<table border=1 cellpadding=5 width=600>' );
  SL.Add( '<tr align=center bgcolor="#CCFFCC"> <font size="3">' ); // light green
  SL.Add( '  <td width="8%">ѕлоскость</td>' );
  SL.Add( '  <td width="15%">ѕараметр</td>' );
  SL.Add( '  <td width="5%">N</td>' );
  SL.Add( '  <td width="5%">1</td>' );
  SL.Add( '  <td width="5%">откл.%</td>' );
  SL.Add( '  <td width="5%">P</td>' );

  if FourRFramesStudy then
  begin
    SL.Add( '  <td width="5%">2</td>' );
    SL.Add( '  <td width="5%">откл.%</td>' );
    SL.Add( '  <td width="5%">P</td>' );
  end;

  SL.Add( '</font> </tr>' );

  SL.Add( CreateResStr( 15 ) ); // the only one Front/Side Param

 //***** Front Params

  SL.Add( '<tr align=center bgcolor="#CCFFCC">' + // light green
          '  <td></td><td>' + PMTResHeader1 + '</td>' );
  SL.Add( '  <td></td><td></td><td></td><td></td>' );
  if FourRFramesStudy then
    SL.Add( '  <td></td><td></td><td></td>' );
  SL.Add( '</tr>' );

  SL.Add( CreateResStr( 20 ) );
  for i := 0 to 3 do SL.Add( CreateResStr( i ) );


 //***** Side Params

  SL.Add( '<tr align=center bgcolor="#CCFFCC">' + // light green
          '  <td></td><td>' + PMTResHeader2 + '</td>' );
  SL.Add( '  <td></td><td></td><td></td><td></td>' );
  if FourRFramesStudy then
    SL.Add( '  <td></td><td></td><td></td>' );
  SL.Add( '</tr>' );

  for i := 4 to 11 do SL.Add( CreateResStr( i ) ); // Params 12-14 are skiped!

  //***** abs Front View Params in mm.

  SL.Add( '<tr align=center bgcolor="#CCFFCC">' + // light green
          '  <td></td><td>' + PMTResHeader3 + '</td>' );
  SL.Add( '  <td></td><td></td><td></td><td></td>' );
  if FourRFramesStudy then
    SL.Add( '  <td></td><td></td><td></td>' );
  SL.Add( '</tr>' );

  for i := 21 to 25 do SL.Add( CreateResStr( i ) ); // Param 26 is skiped!
  SL.Add( '' );

  //***** abs Side View Params in mm.

  SL.Add( '<tr align=center bgcolor="#CCFFCC">' + // light green
          '  <td></td><td>' + PMTResHeader4 + '</td>' );
  SL.Add( '  <td></td><td></td><td></td><td></td>' );
  if FourRFramesStudy then
    SL.Add( '  <td></td><td></td><td></td>' );
  SL.Add( '</tr>' );

  for i := 27 to 34 do SL.Add( CreateResStr( i ) );


  SL.Add( '</table></font>' );


{
  SL.Add( '<table border=1 cellpadding=5 width=900>' );
  SL.Add( '<tr align=center bgcolor="#AAAAAA" >' );
  SL.Add( '  <td width="15%"><font size="3">параметр</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">до лечени€<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">в процессе<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="15%"><font size="3">после<br>(__.__.____)</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">N</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">откл. от N</font></td>' );
  SL.Add( '  <td width="5%"><font size="3">delta (%)</font></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );
  SL.Add( '<tr align=center bgcolor="#CCCCCC">' );
  SL.Add( '  <td><font size="3">‘ј—</font></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );

  for i := 0 to 4 do // along all Front View Results
  begin
    if i = 4 then j := 15 // Front-side Param
             else j := i; // Front Params

    SL.Add( '<tr align=center>' );
    SL.Add( '  <td>' + PMTResNames[j] + '</td>' );
    SL.Add( '  <td>' + Format( '%05.3f', [PMTResults[j]] ) + '</td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '</tr>' );
    SL.Add( '' );

  end; // for i := 0 to 4 do // along all Front View Results

  SL.Add( '<tr align=center bgcolor="#CCCCCC">' );
  SL.Add( '  <td><font size="3">ѕ–ќ‘»Ћ№</font></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '  <td></td>' );
  SL.Add( '</tr>' );
  SL.Add( '' );


  for i := 4 to 14 do // along all Side View Results
  begin
    SL.Add( '<tr align=center>' );
    SL.Add( '  <td>' + PMTResNames[i] + '</td>' );
    SL.Add( '  <td>' + Format( '%05.3f', [PMTResults[i]] ) + '</td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '  <td></td>' );
    SL.Add( '</tr>' );
    SL.Add( '' );
  end; // for i := 6 to 16 do // along all Side View Results
}

end; // procedure TN_PMTMain5Form.PMTResultsToHTML2

//***************************************** TN_PMTMain5Form.PMTResultsToCSV ***
// Prepare caculated Results in CSV format in given AStrings
//
procedure TN_PMTMain5Form.PMTResultsToCSV( AStrings: TStrings );
var
  i, j: Integer;
  Str: String;
  SL: TStrings;
begin
  SL := AStrings; // for nice code only
  SL.Clear;
  SL.Add( PMTCFIO + ', ' + PMTCDOB );
  SL.Add( '' );
  SL.Add( 'параметр;до лечени€ (__.__.____);в процессе (__.__.____);после (__.__.____);' +
          'N;откл. от N;delta (%)' );

  SL.Add( '‘ј—' );

  for i := 0 to 4 do // along all Front View Results
  begin
    if i = 4 then j := 15 // Front-side Param
             else j := i; // Front Params

    Str := PMTResNames[j];
    SL.Add( Str + Format( ';%05.3f', [PMTResults[j]] ) )
  end; // for i := 0 to 4 do // along all Front View Results

  SL.Add( 'ѕ–ќ‘»Ћ№' );

  for i := 4 to 14 do // along all Side View Results
  begin
    SL.Add( PMTResNames[i] + Format( ';%05.3f', [PMTResults[i]] ) );
  end; // for i := 6 to 16 do // along all Side View Results

end; // procedure TN_PMTMain5Form.PMTResultsToCSV

//**************************************** TN_PMTMain5Form.PMTResultsToText ***
// Prepare caculated Results in Text format in given AStrings (Version 1)
//
procedure TN_PMTMain5Form.PMTResultsToText( AStrings: TStrings );
var
  i, j: Integer;
  Str, StrFVR, StrSVR, StrFPRC, StrSPRC: String;
  SL: TStrings;
begin
  StrFVR  := 'јнфас';
  StrSVR  := 'ѕрофиль';
  StrFPRC := ' оординаты точек анфас';
  StrSPRC := ' оординаты точек профиль';

  SL := AStrings; // for nice code only
  SL.Clear;
  SL.Add( PMTCFIO + ',  ' + PMTCDOB );
  SL.Add( '' );
//  SL.Add( 'Front View Results' );
  SL.Add( StrFVR );
  SL.Add( '' );

  for i := 0 to 3 do // along all Front View Results
  begin
    Str := '                 = ';

    for j := 1 to Length(PMTResNames[i]) do
      Str[j] := PMTResNames[i,j];

    Str := Str + Format( '%05.3f', [PMTResults[i]] );

    SL.Add( Str );
  end; // for i := 0 to 3 do // along all Front View Results

  SL.Add( Format( '%s = %05.3f', [PMTResNames[15], PMTResults[15]] ) ); // special FS Param
  SL.Add( '' );


//  SL.Add( 'Side View Results' );
  SL.Add( StrSVR );
  SL.Add( '' );

  for i := 4 to 14 do // along all Side View Results
  begin
    Str := '                 = ';

    for j := 1 to Length(PMTResNames[i]) do
      Str[j] := PMTResNames[i,j];

    Str := Str + Format( '%05.3f', [PMTResults[i]] );

    SL.Add( Str );
  end; // for i := 4 to 14 do // along all Side View Results

  SL.Add( '' );
//  SL.Add( 'Front Points Relative Coords:' );
  SL.Add( StrFPRC );
  SL.Add( '' );

  for i := 0 to High(PMTOrdFPointsMM) do // along all Created Front Points
  begin
    Str := '    = ';

    for j := 1 to Length(PMTFrontPNames[i]) do
      Str[j] := PMTFrontPNames[i,j];

    Str := Str + Format( '(%05.2f, %05.2f)', [PMTOrdFPoints[i].X, PMTOrdFPoints[i].Y] );

    SL.Add( Str );
  end; // for i := 0 to High(PMTOrdFPoints) do // along all Created Front Points

  SL.Add( '' );
//  SL.Add( 'Side Points Relative Coords:' );
  SL.Add( StrSPRC );
  SL.Add( '' );

  for i := 0 to High(PMTOrdSPoints) do // along all Created Side Points
  begin
    Str := '    = ';

    for j := 1 to Length(PMTSidePNames[i]) do
      Str[j] := PMTSidePNames[i,j];

    Str := Str + Format( '(%05.2f, %05.2f)', [PMTOrdSPoints[i].X, PMTOrdSPoints[i].Y] );

    SL.Add( Str );
  end; // for i := 0 to High(PMTOrdSPoints) do // along all Created Side Points

end; // procedure TN_PMTMain5Form.PMTResultsToText( AStrings: TStrings );

//*************************************** TN_PMTMain5Form.PMTResultsToText2 ***
// Prepare caculated Results in Text format in given AStrings (Version 2)
//
procedure TN_PMTMain5Form.PMTResultsToText2( AStrings: TStrings );
var
  i, j: Integer;
  Str, StrFPRC, StrSPRC, GapStr, StrDiagr: String;
  FourRFramesStudy: Boolean;
  SL: TStrings;

  function CreateResStr( AResInd: integer ): string; // local
  begin
    GapStr := N_CreateWhiteChars( 2 );

//    Result := N_CreateWhiteChars( 5 ) + PMTResPlos[AResInd] + GapStr;
    Result := Format( ' %2d  %s', [AResInd, PMTResPlos[AResInd]] ) + GapStr;

    Result := Result + N_FormatString( PMTResNames[AResInd], '', 16, $0 ) + GapStr;
    Result := Result + N_FormatString( PMTNormDelta[AResInd], '', 10, $1 ) + GapStr;

    Result := Result + Format( '%07.2f', [PMTResults[AResInd]] ) + GapStr;
    Result := Result + N_FormatString( PMTResDeltaS[AResInd], '', 7, $1 ) + GapStr;
    Result := Result + N_FormatString( PMTResProbS[AResInd], '', 5, $1 );

    if FourRFramesStudy then
    begin
      Result := Result + GapStr;
      Result := Result + Format( '%07.2f', [PMTResults2[AResInd]] ) + GapStr;
      Result := Result + N_FormatString( PMTResDeltaS2[AResInd], '', 7, $1 ) + GapStr;
      Result := Result + N_FormatString( PMTResProbS2[AResInd], '', 5, $1 );
    end;

  end; // function CreateResStr( AResInd: integer ): string; // local

begin
  StrFPRC  := ' оординаты точек (фас) %%, мм.';
  StrSPRC  := ' оординаты точек (профиль) %%, мм.';
  StrDiagr := 'ѕараметры диаграммы по ос€м B, C, T';

  FourRFramesStudy := N_CM_MainForm.CMMFActiveEdFrameSlideStudy.CMSStudyItemsCount = 4;
//  N_s := TN_PCMSlide(N_CM_MainForm.CMMFActiveEdFrameSlideStudy.P())^.CMSDiagn;

  SL := AStrings;
  SL.Clear;
  SL.Add( '' );
  SL.Add( '       ' + PMTMainHeader );
  SL.Add( '' );
  SL.Add( PMTNCardNumber + '  ' + PMTCCardNumber );
  SL.Add( PMTNFIO        + '  ' + PMTCFIO );
  SL.Add( PMTNDOB        + '  ' + PMTCDOB );

  //***** PMTCDiagn was set in aShowResultsExecute

  if PMTCDiagn.Count >= 1 then // Diagn exists
  begin
    SL.Add( PMTNDiagn      + '  ' + PMTCDiagn[0] );

    for i := 1 to PMTCDiagn.Count-1 do
      SL.Add( '  ' + PMTCDiagn[i] );
  end; // if PMTCDiagn.Count >= 1 then // Diagn exists

  SL.Add( PMTNDoctor     + '  ' + PMTCDoctor );
  SL.Add( PMTNStudyDate  + '  ' + PMTCStudyDate );
  SL.Add( '' );
  SL.Add( PMTNSumma4R  + PMTCSumma4R + ' мм' );
  SL.Add( '      оэффициент нормы = ' + Format( '%5.2f', [PMTCoefNorm] ) );
  SL.Add( '' );
  SL.Add( '' );

  if FourRFramesStudy then
    SL.Add( 'ѕлоскость   ѕараметр          N           1    откл1%    P1        2    откл2%    P2' )
  else // Two RFrames Study
    SL.Add( 'ѕлоскость   ѕараметр          N           1    откл.%    P' );

  SL.Add( CreateResStr( 15 ) ); // the only one Front/Side Param

  SL.Add( PMTResHeader1 ); // Front View Params
  SL.Add( CreateResStr( 20 ) );
  for i := 0 to 3 do SL.Add( CreateResStr( i ) );
  SL.Add( '' );

  SL.Add( PMTResHeader2 ); // Side View Params
  for i := 4 to 11 do SL.Add( CreateResStr( i ) ); // Params 12-14 are skiped!
  SL.Add( '' );

  SL.Add( PMTResHeader3 ); // abs Front View Params in mm.
  for i := 21 to 25 do SL.Add( CreateResStr( i ) ); // Param 26 is skiped!
  SL.Add( '' );

  SL.Add( PMTResHeader4 ); // abs Side View Params in mm.
//  for i := 27 to 30 do SL.Add( CreateResStr( i ) );  // Params 31 and 33 are skiped!
//  for i := 27 to 33 do SL.Add( CreateResStr( i ) );  // Param 30 added
  for i := 27 to 34 do SL.Add( CreateResStr( i ) );
  SL.Add( '' );
  SL.Add( '' );

  SL.Add( StrDiagr + Format( ' (1) = %2.1f,  %2.1f,  %2.1f',
                                [PMTResDiagr_B,PMTResDiagr_C,PMTResDiagr_T] ) );
  if FourRFramesStudy then
    SL.Add( StrDiagr + Format( ' (2) = %2.1f,  %2.1f,  %2.1f',
                                [PMTResDiagr_B2,PMTResDiagr_C2,PMTResDiagr_T2] ) );

  SL.Add( '' );
  SL.Add( '' );

  SL.Add( StrFPRC ); // Front Points Relative Coords
  SL.Add( '' );

  for i := 0 to High(PMTOrdFPoints) do // along all Created Front Points
  begin
    Str := '    = ';

    for j := 1 to Length(PMTFrontPNames[i]) do
      Str[j] := PMTFrontPNames[i,j];

    Str := Str + Format( '(%05.2f, %05.2f),  (%05.2f, %05.2f)',
                          [PMTOrdFPoints[i].X, PMTOrdFPoints[i].Y,
                           PMTOrdFPointsMM[i].X, PMTOrdFPointsMM[i].Y] );

    SL.Add( Str );
  end; // for i := 0 to High(PMTOrdFPoints) do // along all Created Front Points
  SL.Add( '' );

  SL.Add( StrSPRC ); // Side Points Relative Coords
  SL.Add( '' );

  for i := 0 to High(PMTOrdSPoints) do // along all Created Side Points
  begin
    Str := '    = ';

    for j := 1 to Length(PMTSidePNames[i]) do
      Str[j] := PMTSidePNames[i,j];

    Str := Str + Format( '(%05.2f, %05.2f),  (%05.2f, %05.2f)',
                          [PMTOrdSPoints[i].X, PMTOrdSPoints[i].Y,
                           PMTOrdSPointsMM[i].X, PMTOrdSPointsMM[i].Y] );

    SL.Add( Str );
  end; // for i := 0 to High(PMTOrdSPoints) do // along all Created Side Points

end; // procedure TN_PMTMain5Form.PMTResultsToText2

//************************************* TN_PMTMain5Form.PMTRebuildLineAnnot ***
// Add new or rebuild existing between the eye Line on Front View
//
//     Parameters
// Result - Returns TRUE if new Line was added
//
function TN_PMTMain5Form.PMTRebuildLineAnnot( ): Boolean;
var
  AP1, AP2 : TDPoint;
  AColor : Integer;
  ALWidth : Float;
  UD3 : TN_UDBase;
  UDL3 : TN_UDPolyline;
  FActType : Byte;
  FActCapt : string;
  PUPColor: TN_POneUserParam;
  PUPLineWidth: TN_POneUserParam;
begin
  // Check if eye points exists

  PMTFillOrderedPoints( 0 );
  Result := False;

  if (PMTOrdFPoints[N_F_Pr].X = -1.0) or (PMTOrdFPoints[N_F_Pl].X = -1.0) then Exit;

  //   Prepare params:
  // AP1 - Line 1-st point
  // AP2 - Line 2-d point
  // AColor  - Line color (is used for added Line, not used if existing is rebuild)
  // ALWidth - Line width (0.1 to 12) in points (is used for added Line, not used if existing is rebuild)

  AP1 := PMTOrdFPoints[N_F_Pr];
  AP2 := PMTOrdFPoints[N_F_Pl];
  AColor := N_ClGreen;
  ALWidth := 0.1;

  with N_CM_MainForm, CMMFEdFrames[0], EdSlide, GetMeasureRoot() do
  begin
    UD3 := DirChild(0);
    if UD3.ObjName[1] <> 'L' then
    begin
    // Add New Object
      UD3 := AddNewMeasurement('Line');
      MoveEntries( 0, DirHigh() );
      FActType := Ord(K_shVOActAdd);
      FActCapt := 'Add Eyes Line';
      Result := TRUE;
      PUPColor := K_CMGetVObjPAttr( UD3, 'MainColor' );
      if PUPColor <> nil then
        PInteger(PUPColor.UPValue.P)^ := AColor;
      PUPLineWidth := K_CMGetVObjPAttr( UD3, 'LineWidth' );
      if PUPLineWidth <> nil then
        PFloat(PUPLineWidth.UPValue.P)^ := ALWidth;
      RebuildVObjsSearchList();
    end
    else
    begin
      FActType := Ord(K_shVOActMoveVertex);
      FActCapt := 'Rebuild Eyes Line';
      Result := FALSE;
    end;
    TN_UDCompVis(UD3).PSP.CCoords.BPCoords := FPoint( -100,-100 );
    UDL3 := TN_UDPolyline(UD3.DirChild(1));
    with UDl3.PSP.CPolyline.CPCoords do
    begin
      PFPoint(P(0))^ := N_Add2P( FPoint( AP1 ), FPoint( 100,100 ) );
      PFPoint(P(1))^ := N_Add2P( FPoint( AP2 ), FPoint( 100,100 ) );
    end;
    CMMFFinishVObjEditing( FActCapt,
        K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
          Ord(K_shCAVOObject), FActType, Ord(K_shVOTypePolyLine)));
  end; // with N_CM_MainForm, CMMFEdFrames[0], EdSlide, GetMeasureRoot() do
end; // function TN_PMTMain5Form.PMTRebuildLineAnnot

//************************************** TN_PMTMain5Form.PMTRemoveLineAnnot ***
// Remove between the eye Line on Front View
//
//     Parameters
// Result - Returns TRUE if Line was removed
//
function TN_PMTMain5Form.PMTRemoveLineAnnot( ) : Boolean;
var
  UD3 : TN_UDBase;
begin
  with N_CM_MainForm, CMMFEdFrames[0], EdSlide, GetMeasureRoot() do
  begin
    UD3 := DirChild(0);
    Result := UD3.ObjName[1] = 'L';
    if not Result then Exit;
    RemoveDirEntry( 0 );
    CMMFFinishVObjEditing( 'Remove Eyes Line',
        K_CMEDAccess.EDABuildHistActionCode(K_shATChange,
          Ord(K_shCAVOObject), Ord(K_shVOActDel), Ord(K_shVOTypePolyLine)));
  end; // with N_CM_MainForm, CMMFEdFrames[0], EdSlide, GetMeasureRoot() do
end; // function TN_PMTMain5Form.PMTRemoveLineAnnot

procedure TN_PMTMain5Form.FPar1Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 0 );
end; // procedure TN_PMTMain5Form.FPar1Click

procedure TN_PMTMain5Form.FPar2Click(Sender: TObject);
begin
  N_ShowPMTHelp2Image( 0 );
end;

procedure TN_PMTMain5Form.aCOMStartExecute( Sender: TObject );
// Start working: Create New PMT Obj, Load Images in it and Open it
begin
  aCOMCreateNewPMTObjExecute( Sender );
  aCOMImportFilesToPMTObjExecute( Sender );
  aCOMOpenPMTObjExecute( Sender );
end; // procedure TN_PMTMain5Form.aCOMStartExecute

procedure TN_PMTMain5Form.HelpFPar1Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 0 );
end; // procedure TN_PMTMain5Form.HelpFPar1Click

procedure TN_PMTMain5Form.HelpFPar2Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 1 );
end; // procedure TN_PMTMain5Form.HelpFPar2Click

procedure TN_PMTMain5Form.HelpFPar3Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 2 );
end; // procedure TN_PMTMain5Form.HelpFPar3Click

procedure TN_PMTMain5Form.HelpFPar4Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 3 );
end; // procedure TN_PMTMain5Form.HelpFPar4Click

procedure TN_PMTMain5Form.HelpFSPar1Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 15 );
end; // procedure TN_PMTMain5Form.HelpFSPar1Click

procedure TN_PMTMain5Form.HelpSPar1Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 4 );
end; // procedure TN_PMTMain5Form.HelpSPar1Click

procedure TN_PMTMain5Form.HelpSPar1Click0( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 5 );
end; // procedure TN_PMTMain5Form.HelpSPar2Click

procedure TN_PMTMain5Form.HelpSPar3Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 6 );
end; // procedure TN_PMTMain5Form.HelpSPar3Click

procedure TN_PMTMain5Form.HelpSPar4Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 7 );
end; // procedure TN_PMTMain5Form.HelpSPar4Click

procedure TN_PMTMain5Form.HelpSPar5Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 8 );
end; // procedure TN_PMTMain5Form.HelpSPar5Click

procedure TN_PMTMain5Form.HelpSPar6Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 9 );
end; // procedure TN_PMTMain5Form.HelpSPar6Click

procedure TN_PMTMain5Form.HelpSPar7Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 10 );
end; // procedure TN_PMTMain5Form.HelpSPar7Click

procedure TN_PMTMain5Form.HelpSPar8Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 11 );
end; // procedure TN_PMTMain5Form.HelpSPar8Click

procedure TN_PMTMain5Form.HelpSPar9Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 12 );
end; // procedure TN_PMTMain5Form.HelpSPar9Click

procedure TN_PMTMain5Form.HelpSPar10Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 13 );
end; // procedure TN_PMTMain5Form.HelpSPar10Click

procedure TN_PMTMain5Form.HelpSPar11Click( Sender: TObject );
begin
  N_ShowPMTHelp2Image( 14 );
end; // procedure TN_PMTMain5Form.HelpSPar11Click

{
procedure TN_PMTMain5Form.aCOMCalibrate( Sender: TObject );
begin
  with N_CMResForm do
  begin
    AddCMSActionStart( Sender );
    CalibrateCurActiveSlide( 0 );
    AddCMSActionFinish( Sender );
  end;
end;
}

procedure TN_PMTMain5Form.aCOMUnitePMTObjsExecute( Sender: TObject );
// Convert two marked two-slides objects to new one four-slides object
//
var
  Str, Str1: String;
  UDStudyRes, UDStudy, UDStudy1 : TN_UDCMStudy;
  PMTSlides : TN_UDCMSArray;

  Item, ItemRes : TN_UDBase;
  ImgSlide, ImgSlide1 : TN_UDCMSlide;
  MapRoot : TN_UDBase;
  LockStudyResult : Integer;
  WasLockedFlag, WasLockedFlag1 : Boolean;


label LExit;
begin
  with N_CMResForm, N_CM_MainForm, K_CMEDAccess do
  begin
    AddCMSActionStart( Sender );

    CMMGetMarkedSlidesArray( PMTSlides );
    TN_UDCMSlide(UDStudy)  := PMTSlides[0];
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult <> 0 then goto LExit;

    TN_UDCMSlide(UDStudy1) := PMTSlides[1];
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy1, 1, WasLockedFlag1, FALSE );
    if LockStudyResult <> 0 then goto LExit;

    TN_UDBase(UDStudyRes) := ArchStudySamplesLibRoot.DirChildByObjName( '101' );
    if UDStudyRes = nil then
    begin
      N_Dump1Str( 'aCOMUnitePMTObjs PMT 4 sample is not found' );
LExit: //******
      Dec(K_CMD4WWaitApplyDataCount);
      Exit;
    end;

    UDStudyRes := K_CMStudyCreateFromSample( UDStudyRes, '', 0 );
    N_Dump1Str( 'Study4 ID=' + UDStudyRes.ObjName + ' ' + UDStudyRes.ObjInfo );

    // Dismount ImgSlides from source study 1
    EDAStudySavingStart();
    MapRoot := UDStudy.GetMapRoot();
    Item := MapRoot.DirChild(0);
    ImgSlide := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item, ImgSlide, UDStudy );
    Item.DeleteDirEntry(0);

    Item := MapRoot.DirChild(1);
    ImgSlide1 := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item1, ImgSlide1, UDStudy );
    Item.DeleteDirEntry(0);

    MapRoot := UDStudyRes.GetMapRoot();
    ItemRes := MapRoot.DirChild(0);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide, UDStudyRes );

    // Dismount ImgSlides from source study 2
    ItemRes := MapRoot.DirChild(1);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide1, UDStudyRes );

    MapRoot := UDStudy1.GetMapRoot();
    Item := MapRoot.DirChild(0);
    ImgSlide := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item, ImgSlide, UDStudy1 );
    Item.DeleteDirEntry(0);

    Item := MapRoot.DirChild(1);
    ImgSlide1 := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item1, ImgSlide1, UDStudy1 );
    Item.DeleteDirEntry(0);

    MapRoot := UDStudyRes.GetMapRoot();
    ItemRes := MapRoot.DirChild(2);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide, UDStudyRes );

    ItemRes := MapRoot.DirChild(3);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide1, UDStudyRes );

    UDStudyRes.CreateThumbnail();
    UDStudyRes.SetChangeState();

    Str  := UDStudy.P()^.CMSDiagn;
    Str1 := UDStudy1.P()^.CMSDiagn;
    if Length(Str) >= 1 then
      Str := Str + #13#10;
    Str := Str + Str1;
    UDStudyRes.P()^.CMSDiagn := Str;

    EDAStudySave( UDStudyRes );
    EDAStudySavingFinish();

    // Delete Source study 1
    K_CMSlidesDeleteExecute( TN_PUDCMSlide(@UDStudy), 1, FALSE );

    // Delete Source study 2
    K_CMSlidesDeleteExecute( TN_PUDCMSlide(@UDStudy1), 1, FALSE );

    N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
    N_CM_MainForm.CMMFShowStringByTimer( 'New united photometric object is created' );

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm, K_CMEDAccess do
end; // procedure TN_PMTMain5Form.aCOMUnitePMTObjsExecute

procedure TN_PMTMain5Form.aCOMSplitUnitedPMTObjExecute( Sender: TObject );
// Convert marked four-slides object to two new one two-slides objects
//
var
  Str: String;
  UDStudyRes, UDStudyRes1, UDStudy : TN_UDCMStudy;
  PMTSlides : TN_UDCMSArray;

  Item, ItemRes : TN_UDBase;
  ImgSlide, ImgSlide1, ImgSlide2, ImgSlide3 : TN_UDCMSlide;
  MapRoot : TN_UDBase;
  LockStudyResult : Integer;
  WasLockedFlag : Boolean;


label LExit, LExit1;
begin
  with N_CMResForm, N_CM_MainForm, K_CMEDAccess do
  begin
    AddCMSActionStart( Sender );

    CMMGetMarkedSlidesArray( PMTSlides );
    TN_UDCMSlide(UDStudy)  := PMTSlides[0];
    Str  := UDStudy.P()^.CMSDiagn;
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult <> 0 then goto LExit;

    TN_UDBase(UDStudyRes) := ArchStudySamplesLibRoot.DirChildByObjName( '100' );
    if UDStudyRes = nil then
    begin
LExit1: //******
      N_Dump1Str( 'aCOMSplitUnitedPMTObj PMT 2 sample is not found' );
LExit: //******
      Dec(K_CMD4WWaitApplyDataCount);
      Exit;
    end;

    UDStudyRes := K_CMStudyCreateFromSample( UDStudyRes, '', 0 );
    N_Dump1Str( 'Study2 ID1=' + UDStudyRes.ObjName + ' ' + UDStudyRes.ObjInfo );

    TN_UDBase(UDStudyRes1) := ArchStudySamplesLibRoot.DirChildByObjName( '100' );
    if UDStudyRes1 = nil then goto LExit1;

    UDStudyRes1 := K_CMStudyCreateFromSample( UDStudyRes1, '', 0 );
    N_Dump1Str( 'Study2 ID2=' + UDStudyRes1.ObjName + ' ' + UDStudyRes.ObjInfo );

    // Dismount ImgSlides from source study 1
    EDAStudySavingStart();
    MapRoot := UDStudy.GetMapRoot();
    Item := MapRoot.DirChild(0);
    ImgSlide := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item, ImgSlide, UDStudy );
    Item.DeleteDirEntry(0);

    Item := MapRoot.DirChild(1);
    ImgSlide1 := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item1, ImgSlide1, UDStudy );
    Item.DeleteDirEntry(0);

    Item := MapRoot.DirChild(2);
    ImgSlide2 := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item1, ImgSlide1, UDStudy );
    Item.DeleteDirEntry(0);

    Item := MapRoot.DirChild(3);
    ImgSlide3 := K_CMStudyGetOneSlideByItem( Item );
//    EDAStudyDismountOneSlideFromItem( Item1, ImgSlide1, UDStudy );
    Item.DeleteDirEntry(0);

    MapRoot := UDStudyRes.GetMapRoot();
    ItemRes := MapRoot.DirChild(0);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide, UDStudyRes );

    ItemRes := MapRoot.DirChild(1);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide1, UDStudyRes );

    UDStudyRes.CreateThumbnail();
    UDStudyRes.SetChangeState();
    UDStudyRes.P()^.CMSDiagn := Str;
    EDAStudySave( UDStudyRes );

    MapRoot := UDStudyRes1.GetMapRoot();
    ItemRes := MapRoot.DirChild(0);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide2, UDStudyRes1 );

    ItemRes := MapRoot.DirChild(1);
    EDAStudyMountOneSlideToEmptyItem( ItemRes, ImgSlide3, UDStudyRes1 );

    UDStudyRes1.CreateThumbnail();
    UDStudyRes1.SetChangeState();
    UDStudyRes1.P()^.CMSDiagn := Str;
    EDAStudySave( UDStudyRes1 );

    EDAStudySavingFinish();

    // Delete Source study
    K_CMSlidesDeleteExecute( TN_PUDCMSlide(@UDStudy), 1, FALSE );


    N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
    N_CM_MainForm.CMMFShowStringByTimer( 'United photometric object is splitted' );

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm, K_CMEDAccess do

end; // procedure TN_PMTMain5Form.aCOMSplitUnitedPMTObjExecute

procedure TN_PMTMain5Form.aCOMSwitchUnitedPMTObjsExecute( Sender: TObject );
// Change Slides order in marked (not opened) Study:
// Slides 0, 1, 2, 3 becam 2,3,0,1
//
var
  UDStudy : TN_UDCMStudy;
  PMTSlides : TN_UDCMSArray;

  Item : TN_UDBase;
  ImgSlide, ImgSlide1, ImgSlide2, ImgSlide3 : TN_UDCMSlide;
  MapRoot : TN_UDBase;
  LockStudyResult : Integer;
  WasLockedFlag : Boolean;

begin
  with N_CMResForm, N_CM_MainForm, K_CMEDAccess do
  begin
    AddCMSActionStart( Sender );

    CMMGetMarkedSlidesArray( PMTSlides );
    TN_UDCMSlide(UDStudy)  := PMTSlides[0];
    LockStudyResult := CMMOpenedStudiesLockDlg( @UDStudy, 1, WasLockedFlag, FALSE );
    if LockStudyResult <> 0 then
    begin
      Dec(K_CMD4WWaitApplyDataCount);
      Exit;
    end;

    // Dismount ImgSlides from source study 1
    EDAStudySavingStart();
    MapRoot := UDStudy.GetMapRoot();
    Item := MapRoot.DirChild(0);
    ImgSlide := K_CMStudyGetOneSlideByItem( Item );
    EDAStudyDismountOneSlideFromItem( Item, ImgSlide, UDStudy );

    Item := MapRoot.DirChild(1);
    ImgSlide1 := K_CMStudyGetOneSlideByItem( Item );
    EDAStudyDismountOneSlideFromItem( Item, ImgSlide1, UDStudy );

    Item := MapRoot.DirChild(2);
    ImgSlide2 := K_CMStudyGetOneSlideByItem( Item );
    EDAStudyDismountOneSlideFromItem( Item, ImgSlide2, UDStudy );

    Item := MapRoot.DirChild(3);
    ImgSlide3 := K_CMStudyGetOneSlideByItem( Item );
    EDAStudyDismountOneSlideFromItem( Item, ImgSlide3, UDStudy );

    Item := MapRoot.DirChild(0);
    EDAStudyMountOneSlideToEmptyItem( Item, ImgSlide2, UDStudy );

    Item := MapRoot.DirChild(1);
    EDAStudyMountOneSlideToEmptyItem( Item, ImgSlide3, UDStudy );


    Item := MapRoot.DirChild(2);
    EDAStudyMountOneSlideToEmptyItem( Item, ImgSlide, UDStudy );

    Item := MapRoot.DirChild(3);
    EDAStudyMountOneSlideToEmptyItem( Item, ImgSlide1, UDStudy );

    UDStudy.CreateThumbnail();
    UDStudy.SetChangeState();
    EDAStudySave( UDStudy );

    EDAStudySavingFinish();

    // Unlock source study
    with UDStudy.P^ do
    if not WasLockedFlag and (cmsfIsLocked in CMSRFlags) then
    begin
      Include( CMSRFlags, cmsfIsUsed );
      K_CMEDAccess.EDAUnlockSlides( @TN_UDCMSlide(UDStudy), 1, K_cmlrmOpenLock );
    end;

    N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
    N_CM_MainForm.CMMFShowStringByTimer( 'United photometric objects are switched' );

    AddCMSActionFinish( Sender );
  end; // with N_CMResForm, N_CM_MainForm, K_CMEDAccess do

end; // procedure TN_PMTMain5Form.aCOMSwitchUnitedPMTObjsExecute

procedure TN_PMTMain5Form.aComCalibrate2Execute(Sender: TObject);
begin
  with N_CMResForm do
  begin
    AddCMSActionStart( Sender );
    CalibrateCurActiveSlide( 0 );
    AddCMSActionFinish( Sender );
  end;
end; // procedure TN_PMTMain5Form.aComCalibrate2Execute

end.



