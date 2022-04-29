unit N_CMResF;
// CM Resource Form - Form with ImageLists, ActionLists and other Delphi objects,
// that should always exist (is created by Delphi).
//
// N_CMResF unit should be included in Implementation Section Uses
// statetment to make it's Objects accessible by Delphi Designer
//
// To create first ref to some TN_CMResForm's object in some Form,
// N_CMResF uint should be already opened in Delphi Editor

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ActnList, Menus, Types, StdCtrls, CheckLst,
  L_VirtUI,
  N_Types, N_Rast1Fr, N_CompBase, K_CLib, System.Actions, Vcl.FileCtrl,
  System.IOUtils;

type TN_CMResForm = class( TForm ) // CM Resource Form
    MainActions: TActionList;
    aGoToPrint: TAction;
    aGoToExit: TAction;
    aViewOneSquare: TAction;
    aViewTwoHorizontal: TAction;
    aViewTwoVertical: TAction;
    aViewFourSquares: TAction;
    aViewNineSquares: TAction;
    aViewZoom: TAction;
    aGoToPreferences: TAction;
    aViewPanning: TAction;
    aViewFullScreen: TAction;
    aViewFitToWindow: TAction;
    aVTBAlterations: TAction;
    aVTBCapture: TAction;
    aVTBSystem: TAction;
    aVTBViewFilt: TAction;
    aCapCaptDevSetup: TAction;
    aToolsRotateLeft: TAction;
    aToolsRotateRight: TAction;
    aToolsRotate180: TAction;
    aToolsFlipHorizontally: TAction;
    aToolsFlipVertically: TAction;
    aToolsBriCoGam: TAction;
    aMediaImport: TAction;
    aMediaOpen: TAction;
    aMediaEmail: TAction;
    aEditCut: TAction;
    aEditCopyMarked: TAction;
    aEditPaste: TAction;
    aEditDeleteMarked: TAction;
    aEditSelectAll: TAction;
    aEditPoint: TAction;
    aEditUndoLast: TAction;
    aEditUndoRedo: TAction;
    aEditRestOrigImage: TAction;
    aObjPolylineM: TAction;

    aHelpContents: TAction;
    aHelpAbout: TAction;

    aDebSaveArchAs: TAction;
    aDebAction1: TAction;
    aDebCreateDistr: TAction;

    aDebAction2: TAction;
    aDebClearSlidesInDB: TAction;
    aDebAddSlidesToDB: TAction;
    aDebListSlidesInDB: TAction;
    aDebAbortCMS: TAction;

    MainIcons18: TImageList;
//    MainIcons18: TImageList;
//    MainIcons44: TImageList;
    DynIcons18: TImageList;
    DynIcons44: TImageList;

    ThumbsRFrPopupMenu: TPopupMenu;
    PropertiesDiagnoses1: TMenuItem;
    Print1: TMenuItem;
    Import1: TMenuItem;
    Export1: TMenuItem;
    Open1: TMenuItem;
    Email1: TMenuItem;
    N1: TMenuItem;
    Delete1: TMenuItem;
    SelectAll1: TMenuItem;
    N2: TMenuItem;
    aEditClearSelection: TAction;
    aEditInvertSelection: TAction;
    N3: TMenuItem;
    InvertSelection1: TMenuItem;
    ClearSelection1: TMenuItem;
    aVTBAllTopToolBars: TAction;
    aEditCloseCurActive: TAction;
    EdFramesPopupMenu: TPopupMenu;
    FinishEditingSlide1: TMenuItem;
    aEditDeleteOpened: TAction;
    aEditCopyOpened: TAction;
    aEditDeleteCommon: TAction;
    N4: TMenuItem;
    CopyOpened1: TMenuItem;
    aMediaExportOpened: TAction;
    N5: TMenuItem;
    Export2: TMenuItem;
    ZoomInandOut1: TMenuItem;
    Panning1: TMenuItem;
    Point1: TMenuItem;
    aDebChangeContext: TAction;
    aServEditStatTable: TAction;
    aServSetVideoCodec: TAction;
    aDebCheckFile: TAction;
    aEditRedoLast: TAction;
    FullScreen1: TMenuItem;
    aDebDelArchImgFiles: TAction;
    aObjDelete: TAction;
    aToolsNegate: TAction;
    aToolsSharpen: TAction;
    aToolsNoiseSelf: TAction;
    aToolsEmboss: TAction;
    aToolsColorize: TAction;
    aToolsIsodens: TAction;
    aToolsIsodensAttrs: TAction;
    aObjAngleNorm: TAction;
    aObjAngleFree: TAction;
    aObjCalibrate1: TAction;
    aObjChangeAttrs: TAction;
    aObjShowHide: TAction;
    aObjPolyline: TAction;
    aObjTextBox: TAction;
    EdFrPointPopupMenu: TPopupMenu;
    FinishEditing1: TMenuItem;
    N6: TMenuItem;
    DeleteDrawing1: TMenuItem;
    ChangeDrawingattributes1: TMenuItem;
    N7: TMenuItem;
    CreateMultiLineMeasure1: TMenuItem;
    CreateAngle1: TMenuItem;
    CreateFreeAngle1: TMenuItem;
    mCalibrateImage: TMenuItem;
    N8: TMenuItem;
    CreateMultiLine1: TMenuItem;
    CreateTextBox1: TMenuItem;
    ShowDrawings1: TMenuItem;
    EdFrCrLinePopupMenu: TPopupMenu;
    DeleteDrawing2: TMenuItem;
    aObjFinishLine: TAction;
    FinishDrawingCreation1: TMenuItem;
    N9: TMenuItem;
    ShowColorize1: TMenuItem;
    ShowIsodensity1: TMenuItem;
    aToolsBriCoGam1: TAction;
    aDebEmbossPar: TAction;
    aToolsEmbossAttrs: TAction;
    aToolsNoiseAttrs: TAction;
    Emboss1: TMenuItem;
    aViewSlideColor: TAction;
    aObjRectangleOld: TAction;
    aObjEllipseOld: TAction;
    Rectangle1: TMenuItem;
    Ellipse1: TMenuItem;
    aObjArrowOld: TAction;
    Arrow1: TMenuItem;
    aDebClearSlidesInArch: TAction;
    aMediaDuplicate: TAction;
    Duplicate1: TMenuItem;
    aMediaWCImport: TAction;
    aMediaWCExport: TAction;
    aObjFreeHand: TAction;
    FreeHand1: TMenuItem;
    aEditRestOrigState: TAction;
    aObjFLZEllipse: TAction;
    Flashlight1: TMenuItem;
    aGoToPropDiagMulti: TAction;
    aToolsRotateByAngle: TAction;
    aToolsAutoEqualize: TAction;
    aToolsCropImage: TAction;
    aServFilesHandling: TAction;
    aServImportExtDB: TAction;
    aHelpRegistration: TAction;
    aDebClearLockedSlides: TAction;
    aServXRAYStreamLine: TAction;
    aServECacheCheck: TAction;
    aMediaExportMarked: TAction;
    aServECacheAllShow: TAction;
    aServShowMessageDlg: TAction;
    aServSlideHistShow: TAction;
    aDebCreateFileClones: TAction;
    aServSetCaptureDelay: TAction;
    aCapFootPedalSetup: TAction;
    aServImportReverse: TAction;
    aViewThumbRefresh: TAction;
    aServConvCMSImgToBMP: TAction;
    aServImportExtDBDlg: TAction;
    aServBinDumpMode: TAction;
    aEditFullScreen: TAction;
    aEditFullScreenClose: TAction;
    CloseFullScreen1: TMenuItem;
    aServCloseCMS: TAction;
    aServEModeRemoveLocDelFiles: TAction;
    aServEModeFilesSync: TAction;
    aServSelSlidesToSyncQuery: TAction;
    aDebSetPatProvLocInfo: TAction;
    aDeb2CreateDemoExeDistr: TAction;
    aDebSyncDPRFilesUses: TAction;
    aGoToGAEnter: TAction;
    aGoToGASettings: TAction;
    aGoToGAFSyncInfo: TAction;
    aMediaEMChangeHLoc: TAction;
    ChangeHostLocation1: TMenuItem;
    N10: TMenuItem;
    aDeb2DebMP1: TAction;
    aDeb2DebMP2: TAction;
    aGoToReports: TAction;
    aViewDisplayDel: TAction;
    aEditRestoreDel: TAction;
    Restoremarkedasdeleted1: TMenuItem;
    aServDelObjHandling: TAction;
    aServRemoveMarkAsDelSlides: TAction;
    aServSystemInfo: TAction;
    aServMaintenance: TAction;
    aServDBRecoveryByFiles: TAction;
    aDeb3ShowTestForm: TAction;
    aDebViewEditDBContext: TAction;
    aToolsFilter1: TAction;
    aToolsFilter2: TAction;
    aToolsFilter3: TAction;
    aToolsFilter4: TAction;
    aServUpdateUIByDeviceProfiles: TAction;
    aDebShowNVTreeForm: TAction;
    aObjCalibrateN: TAction;
    aObjCalibrateDPI: TAction;
    CalibrateImagebyline1: TMenuItem;
    DebMPAction11: TMenuItem;
    CalibrateImagebyimageresolution1: TMenuItem;
    aEditCloseAll: TAction;
    aDebClearFormsCoords: TAction;
    aDeb2CallTest2Form: TAction;
    aViewZoomMode: TAction;
    aToolsHistogramm2: TAction;
    aServRefreshActiveFrame: TAction;
    aToolsNegate1: TAction;
    aToolsNegate11: TAction;
    aObjArrowLine: TAction;
    Arrow2: TMenuItem;
    ZoomMode1: TMenuItem;
    Histogram1: TMenuItem;
    aToolsFlashLight: TAction;
    aObjRectangleLine: TAction;
    aObjEllipseLine: TAction;
    Ellipse2: TMenuItem;
    Rectangle2: TMenuItem;
    aServWindowsSysInfo: TAction;
    aToolsFlashLightMode: TAction;
    aServConvCMSImgToBMP1: TAction;
    aToolsSharpen1: TAction;
    aServImportChngAttrs: TAction;
    aToolsFilterA: TAction;
    aToolsFilterB: TAction;
    aToolsFilterC: TAction;
    aToolsFilterD: TAction;
    aToolsFilterE: TAction;
    aToolsFilterF: TAction;
    aServRemoteClientSetup: TAction;
    aToolsSharpen2: TAction;
    aToolsSharpen3: TAction;
    aGoToPatients: TAction;
    aGoToProviders: TAction;
    aGoToLocations: TAction;
    aToolsSharpenN: TAction;
    aToolsSharpen12: TAction;
    aToolsNoiseAttrs1: TAction;
    aServSAModeSetup: TAction;
    aServExportPPL: TAction;
    aServImportPPL: TAction;
    aServSysSetup: TAction;
    aMediaAddToOpened: TAction;
    aServLinkSetup: TAction;
    aToolsImgSharp: TAction;
    aToolsImgSmooth: TAction;
    aToolsMedian: TAction;
    aToolsDespeckle: TAction;
    aServApplyCLLContext: TAction;
    aEditDeleteMarkedForEver: TAction;
    aEditDeleteOpenedForEver: TAction;
    aEditDeleteMarkedCapt: TAction;
    aEditDeleteOpenedCapt: TAction;
    aGoToStudy: TAction;
    EdFrameStudyPopupMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem13: TMenuItem;
    aEditStudySelectAll: TAction;
    aEditStudyInvertSelection: TAction;
    aEditStudyClearSelection: TAction;
    N11: TMenuItem;
    Close1: TMenuItem;
    CloseFullScreen2: TMenuItem;
    aEditStudyDismount: TAction;
    Dismountselected1: TMenuItem;
    aEditSelectAllCommon: TAction;
    aViewStudyOnly: TAction;
    aServRecoverBadCMSImg: TAction;
    aServUse16BitImages: TAction;
    aServUseGDIPlus: TAction;
    aDebAction3: TAction;
    aToolsConvToGrey: TAction;
    aToolsConvTo8: TAction;
    aToolsAutoContrast: TAction;
    aDebOption1: TAction;
    aDebOption2: TAction;
    aServResampleLarge: TAction;
    aServCreateStudyFiles: TAction;
    aMediaDCMDImport: TAction;
    aDICOMImport: TAction;
    aDICOMExport: TAction;
    aDICOMDIRImport: TAction;
    aDICOMDIRExport: TAction;
    aDICOMImportFolder: TAction;
    aServLaunchVEUI: TAction;
    aServLaunchHPUI: TAction;
    aServSpecialSettings: TAction;
    aCapClientScan: TAction;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    aGoToPrintStudiesOnly: TAction;
    Printstudiesonly1: TMenuItem;
    aCaptByDentalUnit: TAction;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    aDeb2CreateScanExeDistr: TAction;
    aServECacheRecovery: TAction;
    aServProcessClientTasks: TAction;
    aDebCreateNewGUID: TAction;
    aMediaImport3D: TAction;
    N3DImport1: TMenuItem;
    N16: TMenuItem;
    aServLaunchIUApp: TAction;
    aServLaunchIUAppAuto: TAction;
    aDebCorrectDProjFiles: TAction;
    aMediaExportToD4WDocs: TAction;
    CopytoD4WDocumentManager1: TMenuItem;
    aObjCTA1: TAction;
    CustomizableTextAnnotations1: TMenuItem;
    Text11: TMenuItem;
    Text21: TMenuItem;
    Text31: TMenuItem;
    Text41: TMenuItem;
    aObjCTA2: TAction;
    aObjCTA3: TAction;
    aObjCTA4: TAction;
    aServDCMSetup: TAction;
    aVTBCustToolBar: TAction;
    aServEmailSettings: TAction;
    aDICOMQuery: TAction;
    aMediaEMail1: TAction;
    aServRepairAttrs1: TAction;
    aServPrintTemplatesFNameSet: TAction;
    aServPrintTemplatesExport: TAction;
    aViewPresentation: TAction;
    Presentation1: TMenuItem;
    aViewDisplayDelButton: TAction;
    aObjDot: TAction;
    Dot1: TMenuItem;
    aServClearImg3DTmpFiles: TAction;
    aEditStudyItemSelectVis: TAction;
    SelectCurrentVisible1: TMenuItem;
    aServRemoveLogsHandling: TAction;
    aDebSkip3DViewCall: TAction;
    aServClearInstLostRecords: TAction;
    aServArchSave: TAction;
    aServArchRestore: TAction;
    aViewDisplayArchived: TAction;
    aMediaArchRestQAdd: TAction;
    aMediaArchRestQDel: TAction;
    N17: TMenuItem;
    Archivingobjects1: TMenuItem;
    RestoringobjectsfromArchive1: TMenuItem;
    aServSysSetupUI: TAction;
    aServPatCopyMove: TAction;
    aServSwitchToPhotometry: TAction;
    aServSwitchFromPhotometry: TAction;
    aServWEBSettings: TAction;
    aMediaExport3D: TAction;
    Export3D1: TMenuItem;
    aDICOMStore: TAction;
    aDICOMMWL: TAction;
    DICOMStore1: TMenuItem;
    aDICOMCommitment: TAction;
    DICOMCommitment1: TMenuItem;
    aServChangeDBAPSW: TAction;
    aMediaDICOMImport: TAction;
    aServExportSlidesAll: TAction;
//    aServCloseCMS: TAction;


    //********* MainActions ActionList actions  *********************

    //********* GoTo Actions
//    procedure aGoToPropDiagExecute     ( Sender: TObject );
    procedure aGoToPropDiagMultiExecute( Sender: TObject );
    procedure aGoToPreferencesExecute  ( Sender: TObject );
    procedure aGoToPrintExecute        ( Sender: TObject );
    procedure aGoToPrintStudiesOnlyExecute( Sender: TObject );
    procedure aGoToExitExecute         ( Sender: TObject );
    procedure aGoToGAEnterExecute      ( Sender: TObject );
    procedure aGoToGASettingsExecute   ( Sender: TObject );
    procedure aGoToGAFSyncInfoExecute  ( Sender: TObject );
    procedure aGoToReportsExecute      ( Sender: TObject );
    procedure aGoToPatientsExecute     ( Sender: TObject );
    procedure aGoToProvidersExecute    ( Sender: TObject );
    procedure aGoToLocationsExecute    ( Sender: TObject );
    procedure aGoToStudyExecute        ( Sender: TObject );

    //********* Edit Actions
    procedure aEditStudySelectAllExecute      ( Sender: TObject );
    procedure aEditStudyInvertSelectionExecute( Sender: TObject );
    procedure aEditStudyClearSelectionExecute ( Sender: TObject );
    procedure aEditStudyDismountExecute       ( Sender: TObject );
    procedure aEditStudyItemSelectVisExecute  ( Sender: TObject );
    procedure aEditCutExecute          ( Sender: TObject );
    procedure aEditCopyMarkedExecute   ( Sender: TObject );
    procedure aEditCopyOpenedExecute   ( Sender: TObject );
    procedure aEditPasteExecute        ( Sender: TObject );
    procedure aEditDeleteMarkedExecute ( Sender: TObject );
    procedure aEditDeleteOpenedExecute ( Sender: TObject );
    procedure aEditDeleteCommonExecute ( Sender: TObject );
    procedure aEditSelectAllExecute    ( Sender: TObject );
    procedure aEditSelectAllCommonExecute(Sender: TObject);
    procedure aEditInvertSelectionExecute ( Sender: TObject );
    procedure aEditClearSelectionExecute  ( Sender: TObject );
    procedure aEditCloseCurActiveExecute  ( Sender: TObject );
    procedure aEditCloseAllExecute        ( Sender: TObject );
    procedure aEditPointExecute           ( Sender: TObject );
    procedure aEditRestOrigImageExecute   ( Sender: TObject );
    procedure aEditRestOrigStateExecute   ( Sender: TObject );
    procedure aEditUndoLastExecute   ( Sender: TObject );
    procedure aEditRedoLastExecute   ( Sender: TObject );
    procedure aEditUndoRedoExecute   ( Sender: TObject );
    procedure aEditFullScreenExecute      ( Sender: TObject );
    procedure aEditFullScreenCloseExecute ( Sender: TObject );
    procedure aEditRestoreDelExecute      ( Sender: TObject );

    //********* View Actions
    procedure aViewOneSquareExecute     ( Sender: TObject );
    procedure aViewTwoHorizontalExecute ( Sender: TObject );
    procedure aViewTwoVerticalExecute   ( Sender: TObject );
    procedure aViewFourSquaresExecute   ( Sender: TObject );
    procedure aViewNineSquaresExecute   ( Sender: TObject );
    procedure aViewZoomExecute          ( Sender: TObject );
    procedure aViewPanningExecute       ( Sender: TObject );
    procedure aViewFullScreenExecute    ( Sender: TObject );
    procedure aViewFitToWindowExecute   ( Sender: TObject );
    procedure aViewSlideColorExecute    ( Sender: TObject );
    procedure aViewThumbRefreshExecute  ( Sender: TObject );
    procedure aViewDisplayDelExecute    ( Sender: TObject );
    procedure aViewZoomModeExecute      ( Sender: TObject );
    procedure aViewStudyOnlyExecute     ( Sender: TObject );
    procedure aViewPresentationExecute  ( Sender: TObject );
    procedure aViewDisplayArchivedExecute( Sender: TObject );

    //********* View->Toolbars Actions
    procedure aVTBAlterationsExecute    ( Sender: TObject );
    procedure aVTBCaptureExecute        ( Sender: TObject );
    procedure aVTBSystemExecute         ( Sender: TObject );
    procedure aVTBViewFiltExecute       ( Sender: TObject );
    procedure aVTBAllTopToolbarsExecute ( Sender: TObject );
    procedure aVTBCustToolBarExecute    ( Sender: TObject );

    //********* Capture Actions
    procedure aCapCaptDevSetupExecute   ( Sender: TObject );
    procedure aCapFootPedalSetupExecute ( Sender: TObject );
    procedure aCapClientScanExecute     ( Sender: TObject );

    //********* Tools Actions
    procedure aToolsRotateLeftExecute       ( Sender: TObject );
    procedure aToolsRotateRightExecute      ( Sender: TObject );
    procedure aToolsRotate180Execute        ( Sender: TObject );
    procedure aToolsFlipHorizontallyExecute ( Sender: TObject );
    procedure aToolsFlipVerticallyExecute   ( Sender: TObject );
    procedure aToolsBriCoGamExecute         ( Sender: TObject );
    procedure aToolsBriCoGam1Execute        ( Sender: TObject );
    procedure aToolsNegateExecute           ( Sender: TObject );
    procedure aToolsNegate1Execute          ( Sender: TObject );
    procedure aToolsNegate11Execute         ( Sender: TObject );
    procedure aToolsSharpenExecute          ( Sender: TObject );
    procedure aToolsSharpenNExecute         ( Sender: TObject );
    procedure aToolsSharpen1Execute         ( Sender: TObject );
    procedure aToolsSharpen2Execute         ( Sender: TObject );
    procedure aToolsSharpen3Execute         ( Sender: TObject );
    procedure aToolsSharpen12Execute        ( Sender: TObject );
    procedure aToolsImgSharpExecute         ( Sender: TObject );
    procedure aToolsImgSmoothExecute        ( Sender: TObject );
    procedure aToolsNoiseSelfExecute        ( Sender: TObject );
    procedure aToolsMedianExecute           ( Sender: TObject );
    procedure aToolsDespeckleExecute        ( Sender: TObject );
    procedure aToolsNoiseAttrsExecute       ( Sender: TObject );
    procedure aToolsNoiseAttrs1Execute      ( Sender: TObject );
    procedure aToolsEmbossExecute           ( Sender: TObject );
    procedure aToolsEmbossAttrsExecute      ( Sender: TObject );
    procedure aToolsIsodensExecute          ( Sender: TObject );
    procedure aToolsIsodensAttrsExecute     ( Sender: TObject );
    procedure aToolsColorizeExecute         ( Sender: TObject );
//    procedure aToolsHistogrammExecute       ( Sender: TObject );
    procedure aToolsHistogramm2Execute      ( Sender: TObject );
    procedure aToolsRotateByAngleExecute    ( Sender: TObject );
    procedure aToolsAutoEqualizeExecute     ( Sender: TObject );
    procedure aToolsCropImageExecute        ( Sender: TObject );
    procedure aToolsUFilterImgExecute       ( Sender: TObject );
    procedure aToolsGFilterImgExecute       ( Sender: TObject );
    procedure aToolsFlashLightExecute       ( Sender: TObject );
    procedure aToolsFlashLightModeExecute   ( Sender: TObject );
    procedure aToolsConvToGreyExecute       ( Sender: TObject );
    procedure aToolsConvTo8Execute          ( Sender: TObject );
    procedure aToolsAutoContrastExecute     ( Sender: TObject );

    //********* Media Actions
    procedure aMediaImportExecute         ( Sender: TObject );
    procedure aMediaDICOMImportExecute    ( Sender: TObject );
    procedure aMediaWCImportExecute       ( Sender: TObject );
    procedure aMediaDCMDImportExecute     ( Sender: TObject );
    procedure aMediaImport3DExecute       ( Sender: TObject );
    procedure aMediaExportOpenedExecute   ( Sender: TObject );
    procedure aMediaExportMarkedExecute   ( Sender: TObject );
    procedure aMediaWCExportExecute       ( Sender: TObject );
    procedure aMediaOpenExecute           ( Sender: TObject );
    procedure aMediaAddToOpenedExecute    ( Sender: TObject );
    procedure aMediaDuplicateExecute      ( Sender: TObject );
    procedure aMediaEmailExecute          ( Sender: TObject );
    procedure aMediaEmail1Execute         ( Sender: TObject );
    procedure aMediaEMChangeHLocExecute   ( Sender: TObject );
    procedure aMediaExportToD4WDocsExecute( Sender: TObject );
    procedure aMediaArchRestQAddExecute   ( Sender: TObject );
    procedure aMediaArchRestQDelExecute   ( Sender: TObject );
    procedure aMediaExport3DExecute       ( Sender: TObject );

    //********* Objects (Drawings) Actions
    procedure aObjDeleteExecute      ( Sender: TObject );
    procedure aObjPolylineMExecute   ( Sender: TObject );
    procedure aObjPolylineExecute    ( Sender: TObject );
    procedure aObjFreeHandExecute    ( Sender: TObject );
    procedure aObjArrowLineExecute   ( Sender: TObject );
    procedure aObjRectangleLineExecute(Sender: TObject );
    procedure aObjEllipseLineExecute ( Sender: TObject );
    procedure aObjFinishLineExecute  ( Sender: TObject );
    procedure aObjAngleNormExecute   ( Sender: TObject );
    procedure aObjAngleFreeExecute   ( Sender: TObject );
    procedure aObjChangeAttrsExecute ( Sender: TObject );
    procedure aObjTextBoxExecute     ( Sender: TObject );
    procedure aObjDotExecute         ( Sender: TObject );
    procedure aObjCTA1Execute        ( Sender: TObject );
    procedure aObjCTA2Execute        ( Sender: TObject );
    procedure aObjCTA3Execute        ( Sender: TObject );
    procedure aObjCTA4Execute        ( Sender: TObject );
    procedure aObjRectangleOldExecute( Sender: TObject );
    procedure aObjEllipseOldExecute  ( Sender: TObject );
    procedure aObjArrowOldExecute    ( Sender: TObject );
    procedure aObjCalibrate1Execute  ( Sender: TObject );
    procedure aObjCalibrateNExecute  ( Sender: TObject );
    procedure aObjCalibrateDPIExecute( Sender: TObject );
    procedure aObjShowHideExecute    ( Sender: TObject );
    procedure aObjFLZEllipseExecute  ( Sender: TObject );

    //********* DICOM Actions
    procedure aDICOMExportExecute      ( Sender: TObject );
    procedure aDICOMDIRExportExecute   ( Sender: TObject );
    procedure aDICOMImportExecute      ( Sender: TObject );
    procedure aDICOMDIRImportExecute   ( Sender: TObject );
    procedure aDICOMImportFolderExecute( Sender: TObject );
    procedure aDICOMQueryExecute       ( Sender: TObject );
    procedure aDICOMStoreExecute       ( Sender: TObject );
    procedure aDICOMMWLExecute         ( Sender: TObject );
    procedure aDICOMCommitmentExecute  ( Sender: TObject );



    //********* Help Actions
    procedure aHelpContentsExecute     ( Sender: TObject );
    procedure aHelpAboutExecute        ( Sender: TObject );
    procedure aHelpRegistrationExecute ( Sender: TObject );

    //********* Service Actions
    procedure aServEditStatTableExecute   ( Sender: TObject );
    procedure aServSetVideoCodecExecute   ( Sender: TObject );
    procedure aServFilesHandlingExecute   ( Sender: TObject );
    procedure aServImportExtDBExecute     ( Sender: TObject );
    procedure aServImportExtDBDlgExecute  ( Sender: TObject );
    procedure aServXRAYStreamLineExecute  ( Sender: TObject );
    procedure aServProcessClientTasksExecute( Sender: TObject );
    procedure aServECacheCheckExecute     ( Sender: TObject );
    procedure aServECacheAllShowExecute   ( Sender: TObject );
    procedure aServECacheRecoveryExecute  ( Sender: TObject );
    procedure aServSlideHistShowExecute   ( Sender: TObject );
    procedure aServShowMessageDlgExecute  ( Sender: TObject );
    procedure aServSetCaptureDelayExecute ( Sender: TObject );
    procedure aServImportReverseExecute   ( Sender: TObject );
    procedure aServImportChngAttrsExecute ( Sender: TObject );
    procedure aServConvCMSImgToBMP1Execute( Sender: TObject );
    procedure aServConvCMSImgToBMPExecute ( Sender: TObject );
    procedure aServRecoverBadCMSImgExecute( Sender: TObject );
    procedure aServBinDumpModeExecute     ( Sender: TObject );
    procedure aServCloseCMSExecute        ( Sender: TObject );
    procedure aServRemoveMarkAsDelSlidesExecute ( Sender: TObject );
    procedure aServEModeRemoveLocDelFilesExecute( Sender: TObject );
    procedure aServEModeFilesSyncExecute        ( Sender: TObject );
    procedure aServSelSlidesToSyncQueryExecute  ( Sender: TObject );
    procedure aServDelObjHandlingExecute        ( Sender: TObject );
    procedure aServSystemInfoExecute            ( Sender: TObject );
    procedure aServMaintenanceExecute           ( Sender: TObject );
    procedure aServDBRecoveryByFilesExecute     ( Sender: TObject );
    procedure aServUpdateUIByDeviceProfilesExecute( Sender: TObject );
    procedure aServRefreshActiveFrameExecute      ( Sender: TObject );
    procedure aServWindowsSysInfoExecute          ( Sender: TObject );
    procedure aServRemoteClientSetupExecute     ( Sender: TObject );
    procedure aServSetLogFilesPathExecute       ( Sender: TObject );
    procedure aServSAModeSetupExecute           ( Sender: TObject );
    procedure aServExportPPLExecute             ( Sender: TObject );
    procedure aServImportPPLExecute             ( Sender: TObject );
    procedure aServSysSetupExecute              ( Sender: TObject );
    procedure aServLinkSetupExecute             ( Sender: TObject );
    procedure aServApplyCLLContextExecute       ( Sender: TObject );
    procedure aServUseGDIPlusExecute            ( Sender: TObject );
    procedure aServUse16BitImagesExecute        ( Sender: TObject );
    procedure aServResampleLargeExecute         ( Sender: TObject );
    procedure aServCreateStudyFilesExecute      ( Sender: TObject );
    procedure aServSpecialSettingsExecute       ( Sender: TObject );
    procedure aServLaunchVEUIExecute            ( Sender: TObject );
    procedure aServLaunchHPUIExecute            ( Sender: TObject );
    procedure aServLaunchIUAppExecute           ( Sender: TObject );
    procedure aServLaunchIUAppAutoExecute       ( Sender: TObject );
    procedure aServDCMSetupExecute              ( Sender: TObject );
    procedure aServEmailSettingsExecute         ( Sender: TObject );
    procedure aServRepairAttrs1Execute          ( Sender: TObject );
    procedure aServPrintTemplatesFNameSetExecute( Sender: TObject );
    procedure aServPrintTemplatesExportExecute  ( Sender: TObject );
    procedure aServClearImg3DTmpFilesExecute    ( Sender: TObject );
    procedure aServRemoveLogsHandlingExecute    ( Sender: TObject );
    procedure aServClearInstLostRecordsExecute  ( Sender: TObject );
    procedure aServArchSaveExecute              ( Sender: TObject );
    procedure aServArchRestoreExecute           ( Sender: TObject );
    procedure aServSysSetupUIExecute            ( Sender: TObject );
    procedure aServPatCopyMoveExecute           ( Sender: TObject );
    procedure aServSwitchToPhotometryExecute    ( Sender: TObject );
    procedure aServSwitchFromPhotometryExecute  ( Sender: TObject );
    procedure aServWEBSettingsExecute           ( Sender: TObject );
    procedure aServChangeDBAPSWExecute          ( Sender: TObject );
    procedure aServExportSlidesAllExecute       ( Sender: TObject );

    //********* Debug1 Actions
    procedure aDebSaveArchAsExecute        ( Sender: TObject );
    procedure aDebCreateDistrExecute       ( Sender: TObject );
    procedure aDebSyncDPRFilesUsesExecute  ( Sender: TObject );
    procedure aDebCreateNewGUIDExecute     ( Sender: TObject );
    procedure aDebCorrectDProjFilesExecute ( Sender: TObject );
    procedure aDebViewEditDBContextExecute ( Sender: TObject );
    procedure aDebChangeContextExecute     ( Sender: TObject );
    procedure aDebClearSlidesInDBExecute   ( Sender: TObject );
    procedure aDebAddSlidesToDBExecute     ( Sender: TObject );
    procedure aDebAbortCMSExecute          ( Sender: TObject );
    procedure aDebClearLockedSlidesExecute ( Sender: TObject );
    procedure aDebCheckFileExecute         ( Sender: TObject );
    procedure aDebDelArchImgFilesExecute   ( Sender: TObject );
    procedure aDebConvToGrayExecute        ( Sender: TObject );
    procedure aDebEmbossParExecute         ( Sender: TObject );
    procedure aDebClearSlidesInArchExecute ( Sender: TObject );
    procedure aDebCreateFileClonesExecute  ( Sender: TObject );
    procedure aDebSetPatProvLocInfoExecute ( Sender: TObject );
    procedure aDebShowNVTreeFormExecute    ( Sender: TObject );
    procedure aDebClearFormsCoordsExecute  ( Sender: TObject );
    procedure aDebSkip3DViewCallExecute    ( Sender: TObject );

    //********* Deb Actions and Options
    procedure aDebAction1Execute           ( Sender: TObject );
    procedure aDebAction2Execute           ( Sender: TObject );
    procedure aDebAction3Execute           ( Sender: TObject );
    procedure aDebOption1Execute           ( Sender: TObject );
    procedure aDebOption2Execute           ( Sender: TObject );

    //********* Debug2 Actions
    procedure aDeb2CreateDemoExeDistrExecute ( Sender: TObject );
    procedure aDeb2CallTest2FormExecute      ( Sender: TObject );
    procedure aDeb2DebMP1Execute             ( Sender: TObject );
    procedure aDeb2DebMP2Execute             ( Sender: TObject );

    //********* Debug3 Actions
    procedure aDeb3ShowTestFormExecute ( Sender: TObject );

    // Event Handlers
    procedure EdFrCrLinePopupMenuPopup(Sender: TObject);
    procedure FullScreenFormActivate(Sender: TObject);
    procedure EdFrPointPopupMenuPopup(Sender: TObject);
    procedure ThumbsRFrPopupMenuPopup(Sender: TObject);

    procedure VideoOnExecuteHandler ( ASender: TObject );
    procedure TwainOnExecuteHandler ( ASender: TObject );
    procedure OtherOnExecuteHandler ( ASender: TObject );
    procedure Other3DOnExecuteHandler( ASender: TObject );

  public
    CMRFCaptureToolbar:  boolean; // saved state of Capture Toolbar
    CMRFSystemToolbar:   boolean; // saved state of System Toolbar
    CMRFViewFiltToolbar: boolean; // saved state of View and Filter Toolbar
    CMRFVideoMode:       boolean; // True inside VideoOnExecuteHandler
    CMRFTWAINMode:       boolean; // True inside TWAINOnExecuteHandler
    CMRFOtherMode:       boolean; // True inside OtherOnExecuteHandler

    procedure ThumbsRFrameExecute ( ARFrameAction: TN_RFrameAction );
    function  CreateBinDumpFile   ( AInstStr: string; AMemPtr: Pointer; AMemSize: integer ): boolean;

//    procedure TwainOnExecuteHandler ( ASender: TObject );
//    procedure OtherOnExecuteHandler ( ASender: TObject );
//    procedure VideoOnExecuteHandler ( ASender: TObject );

    procedure CalibrateCurActiveSlide ( AClibrationMode : Integer );

    procedure AddCMSActionStart  ( ASender: TObject );
    procedure AddCMSActionFinish ( ASender: TObject );
    function  CheckSlideMemBeforeAction( ASender: TObject; ABufsCount, ADIBsCount : Integer ) : Boolean;
    procedure MediaExportMarked( Sender: TObject; AExportMode : Integer );
    procedure DICOMImport( Sender: TObject; const AFilter : string );
  private
    EdFrAAttrs : TK_CtrlAlignAttrs;
    FullScreenScaleFactor : Double;
    hTaskBar: THandle;

end; // type TN_CMResForm = class( TForm ) // CMS Application Resourses Form

//************************************************** TK_CMEGetSlideColorRFA ***
// Get Slide Color Raster Frame Action
//
type TK_CMEGetSlideColorRFA = class( TN_RFrameAction )
//  SkipNextMouseDown : Boolean;
  procedure Execute (); override;
end; // type TK_CMEGetSlideColorRFA = class( TN_RFrameAction )
{
type TK_CMEditObjRFA = class( TN_RFrameAction ) // Edit CMS Objects
//  MapRoot: TObject;
  SavedCursorPos: TPoint;
  SavedFPoint: TFPoint;
  MyDragMode: boolean;
  SavedComp: TN_UDCompVis;
  SavedInd: integer;

  procedure SetActParams      (); override;
  procedure Execute           (); override;
end; // type TK_CMEditObjRFA = class( TN_RFrameAction )
}

var
  N_CMResForm: TN_CMResForm; // is needed, because it creates by Delphi!
  K_CMShowMessageDlgText : string;
  K_CMShowMessageDlgType : TMsgDlgType;
  K_CMShowMessageDlgButtons : TMsgDlgButtons ;
  K_CMShowMessageDlgSkipLog : Boolean;
  K_CMShowMessageDlgCaption : string;
  K_CMShowMessageDlgShowInterval : Integer;
  K_CMShowGUIFlag : Boolean;


implementation
uses IniFiles, math, ComCtrls, StrUtils,
     DirectShow9, Contnrs,
     K_CLib0, K_UDC, K_UDConst, K_Script1, K_FrRaEdit, K_FRunDFPLScript,
     K_Types, K_UDT1, K_Arch, K_RImage,
     {K_FCMSetSlidesAttrs,} K_FCMSetSlidesAttrs2, K_CM0, K_CM1,
     K_FCMPrint, K_FCMPrint1,
     K_VFunc, K_FCMPrefEdit, K_FCMDeviceSetup, K_FCMUndoRedo, K_FCMSCalibrate,
     K_FCMSDrawAttrs, K_FCMSTextAttrs, K_FCMSSharpAttrs, K_FCMSSharpAttrsN,
     K_FCMSSharpAttrs1, K_FCMSSharpAttrs12, K_FCMSIsodensity, K_FCMSBriCoGam1,
     K_FCMSNoiseRAttrs, K_FCMSNoiseRAttrs1, K_FCMSEmbAttrs,
     {K_FCMChangeSlidesAttrsN,} K_FCMChangeSlidesAttrsN2, K_FCMChangeStudiesAttrs,
     K_FCMSRotateByAngle, K_FCMSFlashlightAttrs, K_FCMSFPathChange,
     K_FCMSFilesHandling, K_FCMSFilesHandlingE, K_FCMRegister,
     K_FCMDeviceSetupEnter, K_FCMECacheProc, K_FCMExportSlides, K_FEText,
     K_FCMImportReverseEnter, K_FCMImportReverse, K_SBuf, K_CMTests,
     K_FCMImport, K_FCMEFSyncProc, K_UDT2, K_FCMDistr, K_FCMGAdmEnter,
     K_FCMGAdmSettings, K_FCMSelectLocation, K_FCMEFSyncInfo,
     K_FCMReports1, K_FCMDelObjsHandling, K_FCMSysInfo, K_FCMIntegrityCheck,
     {K_FCMDBRecovery}K_CMUtils, K_FCMProfileTwain, K_FCMSCalibrate1, K_FCMSZoomMode,
     K_CMCaptDevReg, K_FCMImportChngAttrs, K_FCMRemoteClientSetup, K_FCMSSharpAttrs11,
     K_FCMSASelectPat, K_FCMSASelectProv, K_FCMSASelectLoc, K_FCMSAModeSetup,
     K_FCMExportPPL, K_FCMImportPPL, K_FCMSysSetup, K_CML1F, K_FCMLinkCLFSetup,
     K_FCMAltShiftMEnter, K_CMSLLL, K_FCMSharpSmooth,
     K_FSelectUDB, K_FCMStudyTemplateSelect, K_FCMSelectMaxPictSize, K_FCMResampleLarge,
     K_FCMCreateStudyFiles, K_FCMFixStudyDataWarn, K_FCMDCMDImport,
     K_FCMSpecSettingsSetup, K_FCMScan, K_FCMClientScan, K_FCMDeviceLimitWarn,
     K_FCMECacheRecoverMedia, K_FCMTWAIN, K_FCMCustToolbar, K_FCMMailCAttrs,
     K_FCMDCMSetup, K_FCMDCMQuery, K_FCMRepairSlideAttrs1, K_FCMPresent,
     K_STBuf, K_FCMSelectSlide, K_FCMRemoveLogsHandling, K_FCMStudyCapt,
     K_FCMArchSave, K_FCMArchRestore{, K_CMDCM}, K_FCMDCMImport, K_FCMDCMStore,
     K_FCMDCMCommitment, K_FCMDCMMWL, K_FCMDCMQR, K_FCMNewDBAPSW,
     K_FCMExportSlidesAll,

     N_CMTst1, N_CMTest1F, // for debug N_Tst1,
     N_Lib1,  N_BaseF,    N_NVTreeF,   N_NVtreeFr, N_MenuF, N_ImLib,
     N_CM1,   N_Comp1, N_CMREd3Fr, N_EdRecF,   N_MemoF,
     N_ClassRef, N_Lib0, N_Lib2, N_GS1, N_Deb1, N_ME1, N_GCont,
     N_Gra0, N_Gra1, N_Gra2, N_Gra6, N_CMAboutF, N_TstC1,
     N_EdParF, N_CMDevStatF,
     N_EdStrF, N_InfoF, N_CMFPedalSF, N_CMTWAIN1F, N_CMTWAIN2F, N_CMTWAIN3,
     N_SGComp, N_UDCMap, K_FCMMain5F, N_CMMain5F, N_Comp2,
     N_DGrid, N_IconSelF, N_Video,  N_Video3,  N_CMVideo2F, N_CMVideo3F,  N_CMVideo4F,
     N_CMDebMP1, N_CMTstDelphiF, N_CMExpRep, N_CMVideoProfileF, // N_CMExtCDevs,
     N_CMTest2F, N_BrigHist2F, N_Gra3, N_CMVideoResF, K_CML3F,
     fDICOMViewer;
{$R *.dfm}

    //********* MainActions ActionList actions  *********************

    //********* GoTo Actions

//*************************************** TN_CMResForm.aGoToPropDiagMultiExecute ***
// Show / Edit Selected Slides Attributes
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToPropDiagMulti Action handler
//
procedure TN_CMResForm.aGoToPropDiagMultiExecute(Sender: TObject);
// Show / Edit Current Slide Properties / Diagnoses
var
  Slide : TN_UDCMSlide;
//??05-11-09  SelectedVObj : TN_UDCompVis;
  Ed3Frame : TN_CMREdit3Frame;
  CurWasChanged : Boolean;
  ObjectsChanged : Boolean;
  ThumbFrameUpdate : Boolean;
  UpdateState : TK_CMEDBUStateFlags;
  UpdateOpenedViewCount : Integer;
  i : Integer;
  CurSaveIsNeeded : Boolean;
  RFStateInds : TN_IArray;
  NumSlides, Ind : Integer;
  ImgSlides : TN_UDCMSArray;
  StudiesCount : Integer;
  PSLideAttrs : TN_PCMSlide;

label FExit, FinAction;

begin
  ImgSlides := nil; // warning precaution
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, K_CMEDAccess do
  begin
    CMMFShowString( '' ); // clear

    NumSlides := Length(CMMAllSlidesToOperate);
    ImgSlides := Copy( CMMAllSlidesToOperate );
    StudiesCount := K_CMSeparateSlidesAndStudies( @ImgSlides[0], NumSlides );

    if StudiesCount > 0 then
    begin
    // Studies
//PSLideAttrs := ImgSlides[0].P;
//N_i := Word(PSLideAttrs.CMSRFlags);
      K_CMSlidesLockForOpen( @ImgSlides[0], StudiesCount, K_cmlrmOpenLock );
      if LockResCount = 0 then goto FExit;

      N_Dump2Str( 'Before K_CMChangeStudiesAttrsDlg' );
      K_CMChangeStudiesAttrsDlg( @LockResSlides[0], LockResCount );
      N_Dump2Str( 'After K_CMChangeStudiesAttrsDlg' );


      ObjectsChanged := FALSE;

      Ind := 0;
      for i := 0 to LockResCount - 1 do
      begin
        Slide := LockResSlides[i];
        PSLideAttrs := Slide.P;

        Ed3Frame := CMMFFindEdFrame( Slide );
        if Ed3Frame = nil then
        begin
          ImgSlides[Ind] := Slide;
          Inc( Ind );
        end
        else
          //!!! Redraw is needed for proper Slides selection by mouse in opened Study
          // after this Study have been draw during Properties dialog
          Ed3Frame.RFrame.RedrawAllAndShow();

        if cmsfAttribsChanged in PSLideAttrs.CMSRFlags then
        begin
        // Slide Properties were changed
          if Ed3Frame <> nil then
            Ed3Frame.FrameRightCaption.Caption := PSLideAttrs.CMSSourceDescr; // Study Name

          K_CMEDAccess.SaveSlidesList.Add( Slide ); // Add Slide to List for Saving

          ObjectsChanged := TRUE;
        end;
      end; // for i := 0 to LockResCount - 1 do

      if ObjectsChanged then
      begin
      // Some Studies were changed
        if K_CMEDAccess.SaveSlidesList.Count > 0 then
        begin
          K_CMEDAccess.EDASaveSlidesList( K_CMEDAccess.SaveSlidesList ); // Save after Slide Properties Editing
          K_CMEDAccess.SaveSlidesList.Clear;
        end;

        CMMCurFThumbsRFrame.RedrawAllAndShow()
      end;

      // Free Locked Studies
      if Ind > 0 then
        K_CMEDAccess.EDAUnlockSlides( @ImgSlides[0], Ind, K_cmlrmOpenLock );

    end
    else
    begin
    // Slides

      K_CMSlidesLockForOpen( @ImgSlides[0],
                               NumSlides, K_cmlrmEditPropLock );

      if LockResCount = 0 then
      begin
  FExit:
        CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
        goto FinAction;
      end;

      N_Dump2Str( 'Before K_CMChangeSlidesAttrsDlg' );
      K_CMChangeSlidesAttrsDlg( @LockResSlides[0], LockResCount );
      N_Dump2Str( 'After K_CMChangeSlidesAttrsDlg' );
        // Check Update Mode

      ObjectsChanged := FALSE;
      ThumbFrameUpdate := FALSE;
      UpdateOpenedViewCount := 0;

      for i := 0 to LockResCount - 1 do
      begin
        Slide := LockResSlides[i];
        UpdateState := K_CMEDAccess.LockResState[i].LSUpdate;

        Ed3Frame := nil;
        if cmsfIsOpened in Slide.P.CMSRFlags then
          Ed3Frame := N_CM_MainForm.CMMFFindEdFrame( Slide );
//        CurWasChanged := cmssfAttribsChanged in Slide.CMSlideECSFlags;
        CurWasChanged := Slide.Marker <> 0;

        if CurWasChanged then
        begin
        // Slide Properties were changed
          CurSaveIsNeeded := K_CMEDAccess.SlidesSaveMode = K_cmesImmediately;
          if Ed3Frame <> nil then
            with Ed3Frame do
            begin
              FrameLeftCaption.Caption  := K_CMSlideViewCaption( EdSlide );
              FrameRightCaption.Caption := K_CMSlideFilterText( EdSlide );
              ImgHasDiagn.Visible := EdSlide.P.CMSDiagn <> '';
            end // if CMMFEdFrames[i].EdSlide = Slide then // found
          else
          begin
            CurSaveIsNeeded := TRUE; // Save is Needed for not opened slides
          end;

          with Slide, P^ do
          begin
//1          CMSUndoBuf.UBPushSlideState( 'Edit Properties/Diagnoses', [cmssfAttribsChanged],
//2            CMSUndoBuf.UBPushSlideState( TAction(Sender).Hint, [cmssfAttribsChanged],
//2                 EDABuildHistActionCode( K_shATChange, Ord(K_shCAProps), 0 ) );
//2            CMSlideECSFlags := [];
{3
             if not (cmsfIsMediaObj in CMSDB.SFlags) and
               (CMSlideEdState = K_edsFullAccess)  then
            // Push Slide State to UNDO Buffer - not needed for Video because UNDO|REDO couldn't be done for Video
              CMSUndoBuf.UBPushSlideState( TAction(Sender).Hint, [cmssfAttribsChanged],
                                         Slide.Marker );
}
            if CMSlideEdState = K_edsFullAccess then
            begin
              if not (cmsfIsMediaObj in CMSDB.SFlags) then
              // Push Slide State to UNDO Buffer - not needed for Video because UNDO|REDO couldn't be done for Video
                CMSUndoBuf.UBPushSlideState( TAction(Sender).Hint, [cmssfAttribsChanged],
                                             Slide.Marker )
              else
              begin // Add For Video
                with K_CMEDAccess do
                  EDAAddHistActionToSlideBuffer( Slide, Slide.Marker );
                Include( CMSlideECSFlags, cmssfAttribsChanged ); // Set Slide Changing FLag for ECache
              end;
            end;
            Slide.Marker := 0;
            K_CMEDAccess.EDASaveSlideToECache( Slide );
          end;

          if CurSaveIsNeeded then
            K_CMEDAccess.SaveSlidesList.Add( Slide ); // Add Slide to List for Saving

          ObjectsChanged := TRUE;
        end;

        if not (cmsfIsLocked in Slide.P.CMSRFlags) and
           (UpdateState * [K_dbusOldMapRoot,K_dbusNewMapRoot,K_dbusOldCurImg,K_dbusNewCurImg] <> []) then
        begin // Slide was Updated by another User
          if (Ed3Frame <> nil) then
          begin
            if Slide.CMSlideEdState = K_edsSkipOpen then
              Ed3Frame.EdFreeObjects()
            else
  // !! is already checked before
  //          if UpdateState * [K_dbusOldMapRoot,K_dbusNewMapRoot,K_dbusOldCurImg,K_dbusNewCurImg] <> [] then
            begin
              Inc(UpdateOpenedViewCount);
              Ed3Frame.InitSlideView();
              Ed3Frame.EdVObjSelected := nil;
            end;
          end;

          if not CurWasChanged then // not needed because it was already rebuit in "if WasChanged then"
            ThumbFrameUpdate := TRUE;
        end;

        if Ed3Frame <> nil then
        begin
          Ed3Frame.SetReadOnlyState();
        end;
      end; // for i := 0 to LockResCount - 1 do

      if ObjectsChanged then begin
      // Some Slides were changed
        if K_CMEDAccess.SaveSlidesList.Count > 0 then
        begin
          K_CMEDAccess.EDASaveSlidesList( K_CMEDAccess.SaveSlidesList ); // Save after Slide Properties Editing
          K_CMEDAccess.SaveSlidesList.Clear;
        end;

        CMMFRebuildVisSlides( TRUE ); // Try to Restore Thumbs Selection
        CMMFShowString( '' );
      end
      else if ThumbFrameUpdate then begin
        DGGetSelection( RFStateInds );
        DGInitRFrame();
        DGSetSelection( RFStateInds );
      end;
      K_CMEDAccess.EDAUnlockAllLockedSlides(K_cmlrmEditPropLock);
  //    K_CMEDAccess.EDAUnlockSlides( @LockResSlides[0], LockResCount, K_cmlrmEditPropLock  ); // Unlock (real Unlock only if is not opened)

      CMMFDisableActions( nil );

      if UpdateOpenedViewCount > 0 then
        K_CMShowMessageDlg( format( K_CML1Form.LLLSlidesOpen1.Caption,
//        K_CMShowMessageDlg( format( K_CML1Form.LLLPropDiagn2.Caption,  //text is duplicated
  //        '%d opened Media object(s) were updated because they have been changed by other CMS user(s)',
                            [UpdateOpenedViewCount] ),
                            mtInformation );
    end;
  end; // with N_CM_MainForm, CMMCurFThumbsDGrid, K_CMEDAccess do

FinAction:
  K_CMEDAccess.LockResCount := 0;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToPropDiagMultiExecute

//************************************ TN_CMResForm.aGoToPreferencesExecute ***
// Show CMS Application Preferences Form
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToPreferences Action handler
//
procedure TN_CMResForm.aGoToPreferencesExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with TK_FormPrefEdit.Create(Application) do
  begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal;
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToPreferencesExecute

//****************************************** TN_CMResForm.aGoToPrintExecute ***
// Show Print Form for printing Marked Slides
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToPrint Action handler
//
procedure TN_CMResForm.aGoToPrintExecute( Sender: TObject );
var
  SelectedVObj : TN_UDCompVis;
  SlidesArray : TN_UDCMSArray;
  SavedCursor : TCursor;
  ResSlidesCount : Integer;
//  CloseForm : TForm;

  procedure ProcessSelectedVObj();
  begin
    // Clear Selected Vobj
    with N_CM_MainForm do
    begin
      if (CMMFActiveEdFrame.EdSlide <> nil) and
         (0 <= K_IndexOfIntegerInRArray(
                       Integer(CMMFActiveEdFrame.EdSlide),
                       PInteger(@CMMAllSlidesToOperate[0]),
                       Length(CMMAllSlidesToOperate))) then
        SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

      if SelectedVObj <> nil then
        CMMFActiveEdFrame.ChangeSelectedVObj( 0 );
    end;
  end;

begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  with N_CM_MainForm, K_CMEDAccess do
  begin
    if K_CMStudyAddSlidesGUIModeFlag then
      SlidesArray := K_CMSAddStudyCurSlidesToArray( CMMAllSlidesToOperate )
    else
      SlidesArray := Copy( CMMAllSlidesToOperate, 0, Length(CMMAllSlidesToOperate) );

    K_CMSlidesLockForOpen( @SlidesArray[0],
                           Length(SlidesArray), K_cmlrmOpenLock );
    if LockResCount = 0 then begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      AddCMSActionFinish( Sender );
      Screen.Cursor := SavedCursor;
      Exit;
    end;
    K_CMSResampleSlides( @LockResSlides[0], LockResCount, CMMFShowString );
    SlidesArray := Copy( LockResSlides, 0, LockResCount );
  end;

  SelectedVObj := nil;
  with TK_FormCMPrint1.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PreparePrintList( SlidesArray );
    Screen.Cursor := SavedCursor;
    ResSlidesCount := SPSlidesCount;
    if ResSlidesCount > 0 then
    begin
      ProcessSelectedVObj();
      ShowModal;
    end
    else
    begin
      N_CM_MainForm.CMMFShowString( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do' );
      Close;
    end;
  end; // with TK_FormCMPrint1.Create( Application ) do

{
  // Select PrintManager
  if K_CMDesignModeFlag then
  begin
    CloseForm := TK_FormCMPrint1.Create( Application );
    with TK_FormCMPrint1( CloseForm ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      PreparePrintList( SlidesArray );
      Screen.Cursor := SavedCursor;
      ResSlidesCount := SPSlidesCount;
      if ResSlidesCount > 0 then
      begin
        ProcessSelectedVObj();
        ShowModal;
        // Restore Selected Vobj
        if SelectedVObj <> nil then
          N_CM_MainForm.CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

        N_CM_MainForm.CMMRedrawOpenedFromGiven( @K_CMEDAccess.LockResSlides[0],
                                                K_CMEDAccess.LockResCount );
      end
    end // with TK_FormCMPrint1.Create( Application ) do
  end
  else
  begin
    CloseForm := TK_FormCMPrint.Create( Application );
    with TK_FormCMPrint( CloseForm ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      PreparePrintList( SlidesArray );
      Screen.Cursor := SavedCursor;
      ResSlidesCount := SPSlidesCount;
      if ResSlidesCount > 0 then
      begin
        ProcessSelectedVObj();
        ShowModal;
      end;
    end; // with TK_FormCMPrint.Create( Application ) do
  end;

  if ResSlidesCount > 0 then
  begin
    // Restore Selected Vobj
    if SelectedVObj <> nil then
      N_CM_MainForm.CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

    N_CM_MainForm.CMMRedrawOpenedFromGiven( @K_CMEDAccess.LockResSlides[0],
                                            K_CMEDAccess.LockResCount );

  end
  else
  begin
    N_CM_MainForm.CMMFShowString( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do' );
    CloseForm.Close;
  end;
}
  K_CMEDAccess.EDAUnlockAllLockedSlides(K_cmlrmOpenLock);

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToPrintExecute

//******************************* TN_CMResForm.aGoToPrintStudiesOnlyExecute ***
// Show Print Form for printing Marked Studies Only
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToPrintStudiesOnly Action handler
//
procedure TN_CMResForm.aGoToPrintStudiesOnlyExecute( Sender: TObject );
var
//  SelectedVObj : TN_UDCompVis;
  SlidesArray : TN_UDCMSArray;
  i, j : Integer;

begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, K_CMEDAccess do
  begin
    SetLength( SlidesArray, Length(CMMAllSlidesToOperate) );
    j := 0;
    for i := 0 to High(CMMAllSlidesToOperate) do
      if TN_UDCMBSlide(CMMAllSlidesToOperate[i]) is TN_UDCMStudy then
      begin
        SlidesArray[j] := CMMAllSlidesToOperate[i];
        Inc(j);
      end;
    SetLength( SlidesArray, j );

    K_CMSlidesLockForOpen( @SlidesArray[0],
                           Length(SlidesArray), K_cmlrmOpenLock );
    if LockResCount = 0 then
    begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      AddCMSActionFinish( Sender );
      Exit;
    end;
    SlidesArray := Copy( LockResSlides, 0, LockResCount );
  end;

//  K_FormCMPrint := TK_FormCMPrint.Create( Application );
//  with K_FormCMPrint do
//  with TK_FormCMPrint.Create( Application ) do
  with TK_FormCMPrint1.Create( Application ) do
  begin
//    BaseFormInit ( nil, '', [fvfWhole] );
    SPStudiesOnlyFlag := TRUE;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PreparePrintList( SlidesArray );
    if SPSlidesCount > 0 then
    begin
{ !!! not needed for studies
      // Clear Selected Vobj
      SelectedVObj := nil;
      with N_CM_MainForm do
      begin
        if (CMMFActiveEdFrame.EdSlide <> nil) and
           (0 <= K_IndexOfIntegerInRArray(
                         Integer(CMMFActiveEdFrame.EdSlide),
                         PInteger(@CMMAllSlidesToOperate[0]),
                         Length(CMMAllSlidesToOperate))) then
          SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

        if SelectedVObj <> nil then
          CMMFActiveEdFrame.ChangeSelectedVObj( 0 );
      end;
}
      ShowModal;
{ !!! not needed for studies

      // Restore Selected Vobj
      if SelectedVObj <> nil then
        N_CM_MainForm.CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

      N_CM_MainForm.CMMRedrawOpenedFromGiven( @K_CMEDAccess.LockResSlides[0],
                                              K_CMEDAccess.LockResCount );
}
    end
    else
    begin
      N_CM_MainForm.CMMFShowString( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do' );
      Close;
    end;

    with K_CMEDAccess do
      EDAUnlockAllLockedSlides(K_cmlrmOpenLock);
//      EDAUnlockSlides( @LockResSlides[0], LockResCount, K_cmlrmOpenLock );
  end; // with TK_FormCMPrint.Create( Application ) do
  K_CMEDAccess.LockResCount := 0;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToPrintStudiesOnlyExecute

//******************************************* TN_CMResForm.aGoToExitExecute ***
// Exit Application
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToExit Action handler
//
procedure TN_CMResForm.aGoToExitExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
//  N_CM_MainForm.ModalResult := mrOK;
//  N_CM_MainForm..CMMFAppClose();
  if N_KeyIsDown(VK_SHIFT) then
  begin
    aServSysSetupUIExecute( aServSysSetupUI );
{
    if K_CMAltShiftMConfirmDlg( ) then
    begin
      if K_CMEDAccess is TK_CMEDDBAccess then
        with K_CMEDAccess do
          EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                             Ord(K_shNCAAltShiftM) ) );

      aServSysSetupExecute(aServSysSetup);
    end;
}
  end
  else
  begin
    N_Dump1Str( '***** Close by aGoToExit Action ' );
    K_CMCloseOnFinActionFlag := TRUE;
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToExitExecute


//**************************************** TN_CMResForm.aGoToGAEnterExecute ***
// Enter Global Adiministration mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToGAEnter Action handler
//
procedure TN_CMResForm.aGoToGAEnterExecute(Sender: TObject);
var
  Ind : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if not aGoToGAEnter.Checked then
  begin // Clear [Admin] in Main Form
    K_CMGAModeFlag := FALSE;
    if K_CMEDAccess is TK_CMEDDBAccess then
      K_CMGAModeFlag := TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafEGAMode], 0 ) <> K_edOK;
    if not K_CMGAModeFlag then
    begin
      with N_CM_MainForm.CMMCurFMainForm do
      begin
        Ind := Pos( K_CMSMainFormCaptPref2, Caption );
        Caption := Copy( Caption, Ind + Length(K_CMSMainFormCaptPref2), Length(Caption) );
        if K_CMDebVersionModeFlag then
          Caption := K_CMSMainFormCaptPref1 + Caption;
  //      Caption := '[Deb]' + Caption;
      end;

      if K_CMGAModePrintTemplatesSaveFlag then // Print Templates saving is needed
        K_CMEDAccess.EDAPrintLocMemIniSave;

      N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLGAEnter1.Caption ); //'The Global Administrator session is ended'
      K_CMShowMessageDlg( K_CML1Form.LLLGAEnter1.Caption + ' ' + K_CML1Form.LLLPressOkToContinue.Caption,
//                        'The Global Administrator session is ended. Press OK to continue'
                          mtInformation, [], FALSE, '', 5 );
    end;
  end   // if not aGoToGAEnter.Checked then
  else
  begin // if aGoToGAEnter.Checked then
  //  K_CMEnterpriseGAModeFlag := K_CMGlobAdmConfirmDlg();  // Enterprise Global Admin Mode Flag
    K_CMGAModeFlag := FALSE;
    if K_CMGlobAdmConfirmDlg() then
    begin
      K_CMGAModeFlag := TRUE;
      if K_CMEDAccess is TK_CMEDDBAccess then
        K_CMGAModeFlag := TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafEGAMode], 1 ) = K_edOK;

      if not K_CMGAModeFlag then
        K_CMShowMessageDlg( K_CML1Form.LLLGAEnter2.Caption,
//        'Global administration mode is set by another CMS user.' + Chr($0D) + Chr($0A) +
//        '               Please try again later.',
           mtWarning );
    end; // if K_CMGlobAdmConfirmDlg() then

    if K_CMGAModeFlag then
    begin
      // 2019-08-04 to improve Location context saving
      // Load Location Context for proper Contexts saving
      // (because it is saving in GA mode only)
      // All other calls to EDALocationToCurState() in GA mode are not needed
      // if EDALocationToCurState() will be done in GA mode start
      K_CMEDAccess.EDALocationToCurState();

      with N_CM_MainForm do
      begin
//        CMMCurFMainForm.Caption := '[Admin] ' + CMMCurFMainForm.Caption;
        CMMCurFMainForm.Caption := K_CMSMainFormCaptPref2 + CMMCurFMainForm.Caption;
        CMMFShowStringByTimer( K_CML1Form.LLLGAEnter3.Caption ); // 'You are in Global administration mode'
      end;
      K_CMShowMessageDlg( K_CML1Form.LLLGAEnter3.Caption + ' ' + K_CML1Form.LLLPressOkToContinue.Caption,
//                        'You are in Global administration mode. Please OK to continue'
                           mtInformation, [], FALSE, '', 5 );
    end; // if K_CMGAModeFlag then
  end; // if aGoToGAEnter.Checked then

  aGoToGAEnter.Checked := K_CMGAModeFlag; // Set New value after apply current
  N_CM_MainForm.CMMFDisableActions( nil );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToGAEnterExecute

//************************************* TN_CMResForm.aGoToGASettingsExecute ***
// Change Global Adiministrator Settings
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToGASettings Action handler
//
procedure TN_CMResForm.aGoToGASettingsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if K_CMGlobAdmConfirmDlg() then
    K_CMGlobAdmSettingsDlg( );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToGASettingsExecute


//************************************ TN_CMResForm.aGoToGAFSyncInfoExecute ***
// Files Synchronization Detailes and Settings
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToGAFSyncInfo Action handler
//
procedure TN_CMResForm.aGoToGAFSyncInfoExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMCMEFSyncInfoDlg();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToGAFSyncInfoExecute

//**************************************** TN_CMResForm.aGoToReportsExecute ***
// CMS Statistics Reports
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToReports Action handler
//
procedure TN_CMResForm.aGoToReportsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if K_CMEDDBVersion < 13 then
    N_CM_MainForm.CMMFShowStringByTimer( //sysout
                                        'Action is not implemented' )
  else
    K_CMReportsDlg();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToReportsExecute

//*************************************** TN_CMResForm.aGoToPatientsExecute ***
// Select Current Session Patient
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToPatients Action handler
//
procedure TN_CMResForm.aGoToPatientsExecute(Sender: TObject);
var
  NewPatSID, CurPatSID : string;
Label SelectLoop;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CurPatSID := IntToStr( K_CMEDAccess.CurPatID );

SelectLoop:
  NewPatSID := CurPatSID;
  if K_CMSASelectPatientDlg( NewPatSID, K_CMMarkAsDelShowFlag, FALSE ) then
  begin
    if not K_CMMarkAsDelShowFlag then
    begin
      if NewPatSID <> CurPatSID then
      begin
        N_CM_MainForm.CMMCurFMainForm.Refresh();
        case K_CMSetCurSessionContext( StrToIntDef( NewPatSID, K_CMEDAccess.CurPatID ),
                                     K_CMEDAccess.CurProvID, K_CMEDAccess.CurLocID ) of
        1: begin
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServProcessClientTasks, FALSE );
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServECacheCheck, TRUE );
        end;
        -1,-2: goto SelectLoop;
        end;
      end
      else
        K_CMBuildUICaptionsByCurContext();
    end
  end
  else
    K_CMBuildUICaptionsByCurContext();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToPatientsExecute


//************************************** TN_CMResForm.aGoToProvidersExecute ***
// Select Current Session Provider
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToProviders Action handler
//
procedure TN_CMResForm.aGoToProvidersExecute( Sender: TObject );
var
  NewProvSID, CurProvSID : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CurProvSID := IntToStr(K_CMEDAccess.CurProvID );
  NewProvSID := CurProvSID;

  if K_CMSASelectProviderDlg( NewProvSID, K_CMMarkAsDelShowFlag ) then
  begin
    if not K_CMMarkAsDelShowFlag then
    begin
      if NewProvSID <> CurProvSID then
      begin
        N_CM_MainForm.CMMCurFMainForm.Refresh();
        if 1 = K_CMSetCurSessionContext( K_CMEDAccess.CurPatID,
                                     StrToIntDef( NewProvSID, K_CMEDAccess.CurProvID ),
                                     K_CMEDAccess.CurLocID ) then
        begin
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServProcessClientTasks, FALSE );
          N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServECacheCheck, TRUE );
        end;
      end
      else
        K_CMBuildUICaptionsByCurContext();
    end // if not K_CMMarkAsDelShowFlag then
  end // if K_CMSASelectProviderDlg(...
  else
    K_CMBuildUICaptionsByCurContext();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToProvidersExecute

//************************************** TN_CMResForm.aGoToLocationsExecute ***
// Select Current Session Location
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToLocations Action handler
//
procedure TN_CMResForm.aGoToLocationsExecute(Sender: TObject);
var
  LocSID : string;
  CurLocSID : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CurLocSID := IntToStr( K_CMEDAccess.CurLocID );
  LocSID := CurLocSID;
  if K_CMSASelectLocationDlg( LocSID, K_CMMarkAsDelShowFlag ) then
  begin
    if not K_CMMarkAsDelShowFlag then
    begin
      if LocSID <> CurLocSID then
      begin
        K_CMSetCurSessionContext( K_CMEDAccess.CurPatID,
                                  K_CMEDAccess.CurProvID,
                                  StrToIntDef( LocSID, K_CMEDAccess.CurLocID ) );
      end
      else
        K_CMBuildUICaptionsByCurContext();
    end
  end
  else
    K_CMBuildUICaptionsByCurContext();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToLocationsExecute

//****************************************** TN_CMResForm.aGoToStudyExecute ***
// Select Study Sample to Create
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aGoToStudy Action handler
//
procedure TN_CMResForm.aGoToStudyExecute(Sender: TObject);
var
  Study : TN_UDBase;
  StudyName : string;
  StudyColorInd : Integer;
  Samples : TN_UDCMSArray;
  i, Ind : Integer;
  SSampleList : string;
  RebuildCurSetFlag : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  SetLength( Samples, K_CMEDAccess.ArchStudySamplesLibRoot.DirLength() );

  Ind := 0;
  SSampleList := N_MemIniToString( 'CMS_Main', 'StudySamplesList', '' );
  if SSampleList <> '' then
  begin // Use Samples List From IniFile
    K_CMEDAccess.TmpStrings.CommaText := SSampleList;
    for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
    begin
      Samples[Ind] := TN_UDCMSlide(K_CMEDAccess.ArchStudySamplesLibRoot.DirChildByObjName( K_CMEDAccess.TmpStrings[i] ));
      if (Samples[Ind] = nil) or (Samples[Ind].ObjInfo <> '') then Continue;
      Inc( Ind );
    end;
  end // if SSampleList <> '' then
  else
  // Use All Samples Root
  for i := 0 to High(Samples) do
  begin
    Samples[Ind] := TN_UDCMSlide(K_CMEDAccess.ArchStudySamplesLibRoot.DirChild(i));
    if Samples[Ind].ObjInfo <> '' then Continue;
    Inc( Ind );
  end;

  if Ind > 0 then
  begin
  // Select Sample to create Study
    if K_CMStudyTemplateSelect( @Samples[0], Ind,
                                TN_UDCMStudy(Study), StudyName, StudyColorInd,
                                RebuildCurSetFlag ) then
    begin //
      Study := K_CMStudyCreateFromSample( Study, StudyName, StudyColorInd );
      N_Dump1Str( 'Study ID=' + Study.ObjName + ' ' + Study.ObjInfo );
      N_CM_MainForm.CMMFRebuildVisSlides( TRUE );
      N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLStudy1.Caption ); // 'New study is created'
      if K_CMStudyOpenOnCreateGUIModeFlag then
      begin
        N_CM_MainForm.CMMFSelectThumbBySlide( TN_UDCMSlide(Study), FALSE, TRUE );
        aMediaAddToOpenedExecute( aMediaAddToOpened );
      end;
      K_CMEDAccess.EDASetPatientSlidesUpdateFlag();
    end;
    if RebuildCurSetFlag then
      aViewThumbRefreshExecute( aViewThumbRefresh );

  end; // if Ind > 0 then

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aGoToStudyExecute

    //********* Edit Actions

//******************************************** TN_CMResForm.aEditStudySelectAllExecute ***
// Mark all Slides in Current Active Study with visible Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditStudySelectAll Action handler
//
procedure TN_CMResForm.aEditStudySelectAllExecute(Sender: TObject);
var
  SelCount : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, CMMFActiveEdFrame do
  begin
    if IfSlideIsStudy then
    begin
      SelCount := TN_UDCMStudy(EdSlide).SelectAll();
      RFrame.RedrawAllAndShow();

      CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit1.Caption,
  //           ' %d object(s) are selected',
             [SelCount] ) );
      if DGMarkedList.Count > 0 then
      begin
        // Clear Thumbs Selection
        DGMarkSingleItem( -1 ); // for proper Marked Items order
        DGRFrame.ShowMainBuf();
      end;

      CMMFDisableActions( nil );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditStudySelectAllExecute

//******************************************** TN_CMResForm.aEditStudyInvertSelectionExecute ***
// Invert Slides Selection in Current Active Study with visible Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditStudyInvertSelection Action handler
//
procedure TN_CMResForm.aEditStudyInvertSelectionExecute(Sender: TObject);
var
  SelCount : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, CMMFActiveEdFrame do
  begin
    if IfSlideIsStudy() then
    begin
      SelCount := TN_UDCMStudy(EdSlide).InvertSelection();
      RFrame.RedrawAllAndShow();

      CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit1.Caption,
  //           ' %d object(s) are selected',
             [SelCount] ) );
      if DGMarkedList.Count > 0 then
      begin
        // Clear Thumbs Selection
        DGMarkSingleItem( -1 ); // for proper Marked Items order
        DGRFrame.ShowMainBuf();
      end;

      CMMFDisableActions( nil );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditStudyInvertSelectionExecute

//******************************************** TN_CMResForm.aEditStudyClearSelectionExecute ***
// Clear Slides Selection in Current Active Study with visible Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditStudyClearSelection Action handler
//
procedure TN_CMResForm.aEditStudyClearSelectionExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame {, CMMCurFThumbsDGrid,}  do
  begin
    if IfSlideIsStudy then
    begin
      TN_UDCMStudy(EdSlide).UnSelectAll();
      RFrame.RedrawAllAndShow();

      CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit1.Caption,
  //           ' %d object(s) are selected',
             [0] ) );
{
      if DGMarkedList.Count > 0 then
      begin
        // Clear Thumbs Selection
        DGMarkSingleItem( -1 ); // for proper Marked Items order
        DGRFrame.ShowMainBuf();
      end;
}
      CMMFDisableActions( nil );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditStudyClearSelectionExecute

//******************************************** TN_CMResForm.aEditStudyDismountExecute ***
// Dismount Selected positions Slides (one Slide in position) in Current Active Study
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditStudyDismount Action handler
//
procedure TN_CMResForm.aEditStudyDismountExecute(Sender: TObject);
var
  SelCount, i : Integer;
  WasLockedFlag : Boolean;
  Slides : TN_UDCMSArray;

label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if IfSlideIsStudy then
    begin
      if CMMActiveStudyLockDlg( WasLockedFlag, FALSE ) > 0 then goto LExit;


      with TN_UDCMStudy(EdSlide) do
      begin
        SelCount := CMSSelectedCount;
        if K_CMEDDBVersion >= 39 then
          SelCount := 0;
        K_CMEDAccess.EDAStudySavingStart();
        for i := CMSSelectedCount - 1 downto 0  do
          if K_CMEDDBVersion >= 39 then
          begin
            K_CMEDAccess.EDAStudyDismountAllSlidesFromItem( CMSSelectedItems[i], Slides, TN_UDCMStudy(EdSlide), FALSE, K_CMStudyItemFRFags(CMSSelectedItems[i]), K_CMStudyItemTeethFags( CMSSelectedItems[i] )  );
            SelCount := SelCount + Length(Slides);
            if Length(Slides) > 0 then // Save FlipRotated Slides after dismounting
              K_CMEDAccess.EDASaveSlidesArray( @Slides[0], Length(Slides) );
          end
          else
            K_CMEDAccess.EDAStudyDismountOneSlideFromItem( CMSSelectedItems[i],
                                                           nil, TN_UDCMStudy(EdSlide)  );

        UnSelectAll();

        CreateThumbnail();
        SetChangeState();
        K_CMEDAccess.EDAStudySave( TN_UDCMStudy(EdSlide) );
        K_CMEDAccess.EDAStudySavingFinish();
      end;

      if not WasLockedFlag then
      // UnLocked for Edit
        CMMActiveStudyUnLock();

      RFrame.RedrawAllAndShow();

      CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit7.Caption,
  //           ' %d object(s) are dismounted',
             [SelCount] ) );

      CMMFRebuildVisSlides();
      CMMFDisableActions( nil );
    end; // if IfSlideIsStudy then
  end; // with N_CM_MainForm do

LExit:
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditStudyDismountExecute

//***************************** TN_CMResForm.aEditStudyItemSelectVisExecute ***
// Select Study Item current visible if item has more than one slide mounted
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditStudyItemSelectVis Action handler
//
procedure TN_CMResForm.aEditStudyItemSelectVisExecute(Sender: TObject);
var
  Slides : TN_UDCMSArray;
  SortedSlides : TN_UDCMSArray;
  WasLockedFlag : Boolean;
  Ind, i : Integer;
  SortedData : TN_DArray;


label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if not IfSlideIsStudy then goto LExit;

    with TN_UDCMStudy(EdSlide) do
    begin
      Ind := 0;
      K_CMStudyGetAllSlidesByItem( CMSSelectedItems[0], Slides, Ind );

      // Sorted invisible slides
      SetLength( SortedData, High(Slides) );

      for i := 1 to High(Slides) do
        SortedData[i-1] := LongWord(Slides[i].CMSStudyItemPos) + i / 1000;

      N_CFuncs.DescOrder := TRUE;
      N_SortArrayOfElems( @SortedData[0], High(Slides), SizeOf(Double),
                          N_CFuncs.CompOneDouble );

      SetLength( SortedSlides, Length(Slides) );
      SortedSlides[0] := Slides[0];
      for i := 1 to High(Slides) do
      begin
        Ind := Round(Frac(SortedData[i-1]) * 1000);
        SortedSlides[i] := Slides[Ind];
      end;


      Ind := K_CMSelectSlideDlg( @SortedSlides[0], Length(SortedSlides), 'Select the object to be displayed', TRUE );
      if Ind <= 0 then goto LExit; // Cancel or Select Current Visible

      if CMMActiveStudyLockDlg( WasLockedFlag, FALSE ) > 0 then goto LExit;
      K_CMEDAccess.EDAStudySavingStart();

      // !!! 2017-11-09
      // ARuntimeLinksOnly parameter should be TRUE for skiping changes in Teeth and Rotate Flags while change position Slides order
      K_CMEDAccess.EDAStudyItemSlideSetCurrent( CMSSelectedItems[0], SortedSlides[Ind], TN_UDCMStudy(EdSlide), TRUE );

      CreateThumbnail();
      SetChangeState();
      K_CMEDAccess.EDAStudySave( TN_UDCMStudy(EdSlide) );
      K_CMEDAccess.EDAStudySavingFinish();
    end;

    if not WasLockedFlag then
    // UnLocked for Edit
      CMMActiveStudyUnLock();

    RFrame.RedrawAllAndShow();


    CMMFDisableActions( nil );
  end; // with N_CM_MainForm do

LExit: //*********
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditStudyItemSelectVisExecute

//******************************************** TN_CMResForm.aEditCutExecute ***
// Cut Marked Slides to internal Clipboard
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditCut Action handler
//
procedure TN_CMResForm.aEditCutExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  // not implemented, may be not needed (delete action is enough)
  N_CM_MainForm.CMMFShowStringByTimer( //sysout
                                      'Cut Action' ); // debug
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditCutExecute

//************************************* TN_CMResForm.aEditCopyMarkedExecute ***
// Copy Marked Slides to internal Clipboard
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditCopyMarked Action handler
//
procedure TN_CMResForm.aEditCopyMarkedExecute( Sender: TObject );
var
  NumSlides: integer;
  SlidesArray : TN_UDCMSArray;
begin
  SlidesArray := nil; // to skip warning
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  SlidesArray := K_CMSBuildSlidesArrayByList( K_CMCurVisSlidesArray,
                               N_CM_MainForm.CMMCurFThumbsDGrid.DGMarkedList );
  NumSlides := K_CMSlidesCopyToClipboard( @SlidesArray[0], Length(SlidesArray) );
  N_CM_MainForm.CMMFShowStringByTimer( //sysout
               Format( ' %d object(s) copied to clipboard', [NumSlides] ) );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditCopyMarkedExecute

//************************************* TN_CMResForm.aEditCopyOpenedExecute ***
// Copy Slide, opened in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// Copy opened in Active Editor Frame Slide to internal Clipboard
//
// OnExecute MainActions.aEditCopyOpened Action handler
//
procedure TN_CMResForm.aEditCopyOpenedExecute( Sender: TObject );
var
  NumSlides: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    NumSlides := K_CMSlidesCopyToClipboard( @CMMFActiveEdFrame.EdSlide, 1 );
    CMMFShowStringByTimer( //sysout
                Format( ' %d object(s) copied to clipboard', [NumSlides] ) );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditCopyOpenedExecute

//****************************************** TN_CMResForm.aEditPasteExecute ***
// Paste Slides from internal Clipboard
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditPaste Action handler
//
// Paste Slides that were copied to internal Clipboard
// by aEditCopyMarked or aEditCopyOpened action.
//
procedure TN_CMResForm.aEditPasteExecute( Sender: TObject );
//
var
  NumSlides: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  NumSlides := K_CMSlidesPasteFromClipboard();
  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.CMMFShowStringByTimer( //sysout
                  Format( ' %d object(s) are pasted', [NumSlides] ) );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditPasteExecute

//*********************************** TN_CMResForm.aEditDeleteMarkedExecute ***
// Delete Marked Slides
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditDeleteMarked Action handler
//
procedure TN_CMResForm.aEditDeleteMarkedExecute( Sender: TObject );
var
  i, NumSlides: integer;
  SlidesArray: TN_UDCMSArray;
//  EdFrame: TN_CMREdit3Frame;
  MarkAsDelInd, DelInd : Integer;
  Ind: integer;
  Label Fin, NothingToDo;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid do
  begin

    SlidesArray := nil; // for skip warning
    NumSlides := DGMarkedList.Count;
    if NumSlides = 0 then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
NothingToDo:
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      N_Dump2Str( 'Nothing to do :' + TAction(Sender).Caption );
      goto Fin;
    end;

    SlidesArray := K_CMSBuildSlidesArrayByList( K_CMCurVisSlidesArray, DGMarkedList );

{ //!! New code for Separating Not Empty Studies }
    Ind := 0;
    for i := 0 to High(SlidesArray) do
    begin
      if TN_UDCMBSlide(SlidesArray[i]) is TN_UDCMStudy then
      begin
       if 0 <> SlidesArray[i].GetFileTypeCounts() then
         Continue;
      end;
      SlidesArray[Ind] := SlidesArray[i];
      Inc(Ind);
    end;

    if Ind < NumSlides then
      K_CMShowMessageDlg( format( K_CML1Form.LLLDelObjs3.Caption,
      // '%d not empty study object(s) of %d object(s) are skiped!'
                     [NumSlides - Ind, NumSlides] ), mtInformation );

{ //!! New code for complex dialog }
    if Ind = 0 then
    begin
      N_Dump2Str( 'Nothing to do after skiping Studies :' + TAction(Sender).Caption );
      goto NothingToDo;
    end;

    NumSlides := Ind;
    SetLength( SlidesArray, NumSlides );

    MarkAsDelInd := 0;
    if K_CMMarkAsDelUseFlag then
    begin // Separate slides to MarkAsDel and Del
      MarkAsDelInd := NumSlides;
      DelInd := NumSlides * 2;
      SetLength( SlidesArray, DelInd );
      for i := 0 to NumSlides - 1 do
      begin
        if not (cmsdbfMarkedAsDel in SlidesArray[i].CMSDBStateFlags) and
           not (TN_UDCMBSlide(SlidesArray[i]) is TN_UDCMStudy) then
        begin
          SlidesArray[MarkAsDelInd] := SlidesArray[i];
          Inc(MarkAsDelInd);
        end
        else
        begin
          Dec(DelInd);
          SlidesArray[DelInd] := SlidesArray[i];
        end;
      end;
      Move( SlidesArray[NumSlides], SlidesArray[0], SizeOf(TN_UDCMSlide) * NumSlides );
      SetLength( SlidesArray, NumSlides );
      MarkAsDelInd := MarkAsDelInd - NumSlides;
    end;

    if MarkAsDelInd > 0 then
    begin // Mark As Deleted
      if K_CMSlidesDelConfirmDlg( @SlidesArray[0], MarkAsDelInd, TRUE ) then
        K_CMSlidesDeleteExecute( @SlidesArray[0], MarkAsDelInd, TRUE );
    end;
    NumSlides := NumSlides - MarkAsDelInd;
    if NumSlides > 0 then
    begin // Delete - Remove from DB
      if K_CMSlidesDelConfirmDlg( @SlidesArray[MarkAsDelInd], NumSlides, FALSE ) then
        K_CMSlidesDeleteExecute( @SlidesArray[MarkAsDelInd], NumSlides, FALSE );
    end;
{
    if not K_CMSlidesDelConfirmDlg( @SlidesArray[0], NumSlides, false ) then goto Fin;
    K_CMSlidesDeleteExecute( @SlidesArray[0], Length(SlidesArray), FALSE );
}
{} //!! New code for complex dialog
{ //!! Old code
    if mrYes <> K_CMShowMessageDlg( 'Are you sure you want to delete ' +
                     IntToStr(NumSlides) + ' selected object(s)?', mtConfirmation ) then Exit;
    K_CMSlidesDeleteExecute( K_CMSBuildSlidesArrayByList( K_CMCurVisSlidesArray, DGMarkedList ) );
} //!! Old code
  end; // with N_CM_MainForm, CMMCurFThumbsDGrid do

  Fin: //*****
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditDeleteMarkedExecute

//*********************************** TN_CMResForm.aEditDeleteOpenedExecute ***
// Delete Slide, opened in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditDeleteOpened Action handler
//
procedure TN_CMResForm.aEditDeleteOpenedExecute( Sender: TObject );
var
//  NumSlides: integer;
  MessageText : string;
  MarkAsDelFlag : Boolean;
  IfStudy : Boolean;
  Label Fin;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
//    SlidesArray := nil; // to avoid warning
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      goto Fin;
    end;

    IfStudy := CMMFActiveEdFrame.IfSlideIsStudy;
    MarkAsDelFlag := K_CMMarkAsDelUseFlag and not IfStudy and
       not (cmsdbfMarkedAsDel in CMMFActiveEdFrame.EdSlide.CMSDBStateFlags);
    MessageText := K_CML1Form.LLLDelOpened1.Caption;
     // 'Do you confirm that you really want to delete opened image?'
    if IfStudy then
      MessageText := K_CML1Form.LLLDelOpened2.Caption;
      // 'Do you confirm that you really want to delete opened study?'
    if not MarkAsDelFlag then
      MessageText := MessageText + #13#10'              ' +
                     K_CML1Form.LLLActProceed1.Caption + ' ' + K_CML1Form.LLLProceed.Caption;
{
    if not MarkAsDelFlag then
      MessageText :=
          'Do you confirm that you really want to delete opened image?'#13#10 +
          '              This action is irreversible. Proceed?'
    else
      MessageText :=
          'Do you confirm that you really want to deleted opened image?';
}
    if mrYes <> K_CMShowMessageDlg( MessageText,  mtConfirmation, [], FALSE, K_CML1Form.LLLDelConfirm.Caption ) then goto Fin;
//    if mrYes <> K_CMShowMessageDlg( MessageText,  mtConfirmation, [], FALSE, 'Objects deletion confirmation' ) then goto Fin;

    // Prepare Array to Detete
    K_CMSlidesDeleteExecute( @CMMFActiveEdFrame.EdSlide, 1, MarkAsDelFlag );
  end; // with N_CM_MainForm do

  Fin: //*****
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditDeleteOpenedExecute

//*********************************** TN_CMResForm.aEditDeleteCommonExecute ***
// Delete Selected Slides or Annotation (if ActiveEdFrame is Focused)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditDeleteCommon Action handler
//
procedure TN_CMResForm.aEditDeleteCommonExecute( Sender: TObject );
begin
  if N_CM_MainForm.CMMFActiveEdFrame.RFrame.Focused  and
     (N_CM_MainForm.CMMFActiveEdFrame.EdVObjSelected <> nil) then
    aObjDeleteExecute( Sender )
  else
  if aEditDeleteMarked.Enabled then
    aEditDeleteMarkedExecute( Sender )
  else
  if aEditDeleteOpened.Enabled then
    aEditDeleteOpenedExecute( Sender );
end; // procedure TN_CMResForm.aEditDeleteCommonExecute

//************************************** TN_CMResForm.aEditSelectAllExecute ***
// Mark all visible Slides Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditSelectAll Action handler
//
procedure TN_CMResForm.aEditSelectAllExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid do
  begin
    DGSetAllItemsState( ssmMark );
    CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit1.Caption,
//           ' %d object(s) are selected',
           [DGNumItems] ) );
    if DGNumItems > 0 then
    begin
      CMMCurFThumbsRFrame.SetFocus();
      DGSelectItem(0);
    end;
    CMMFDisableActions( nil );
    CMMCurFThumbsRFrame.Refresh();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditSelectAllExecute

//************************************** TN_CMResForm.aEditSelectAllCommonExecute ***
// Mark all Slides in Thumbnail Frame or Study
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditSelectAllCommon Action handler
//
procedure TN_CMResForm.aEditSelectAllCommonExecute(Sender: TObject);
begin
  with N_CM_MainForm do
  begin
    if CMMFActiveEdFrame.RFrame.Focused and
       CMMFActiveEdFrame.IfSlideIsStudy and
       (TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).GetFileTypeCounts() > 0) then
      aEditStudySelectAllExecute( aEditStudySelectAll )
    else
      aEditSelectAllExecute( aEditSelectAll );
  end;
end; // procedure TN_CMResForm.aEditSelectAllCommonExecute

//******************************** TN_CMResForm.aEditInvertSelectionExecute ***
// Toggle Mark State of all Slides with visible Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditInvertSelection Action handler
//
procedure TN_CMResForm.aEditInvertSelectionExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid do
  begin
    DGSetAllItemsState( ssmToggleMark );
    CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit1.Caption,
//           ' %d object(s) are selected',
           [DGMarkedList.Count] ) );

    if DGMarkedList.Count > 0 then
    begin
      DGSelectItem( Integer(DGMarkedList[0]) );
      CMMCurFThumbsRFrame.SetFocus();
    end;
    CMMFDisableActions( nil );
    CMMCurFThumbsRFrame.Refresh();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditInvertSelectionExecute

//********************************* TN_CMResForm.aEditClearSelectionExecute ***
// Unmark all Slides with visible Thumbnails
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditClearSelection Action handler
//
procedure TN_CMResForm.aEditClearSelectionExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid do
  begin
    DGMarkSingleItem( -1 ); // for proper Marked Items order
    DGRFrame.ShowMainBuf();
    CMMFDisableActions( nil );
  end; // with N_CM_MainForm.CMMCurFThumbsDGrid do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditClearSelectionExecute

//********************************** TN_CMResForm.aEditCloseCurActiveExecute ***
// Finish Editing Slide in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditCloseCurActive Action handler
//
procedure TN_CMResForm.aEditCloseCurActiveExecute( Sender: TObject );
var
  RestoreLayout : Boolean;
  RestoreStudy : Boolean;
  UsedFramesCount : Integer;
  i : Integer;

  procedure CheckRestoreMode( AFrame : TN_CMREdit3Frame );
  begin
    with N_CM_MainForm do
      if K_CMStudySingleOpenGUIModeFlag then
      begin
        RestoreLayout := AFrame.IfSlideIsStudy and (CMMStudyPrevLayout <> N_CMMain5F.TN_EdFrLayout.eflNotDef);
        RestoreStudy := not RestoreLayout and
                       (UsedFramesCount = 1) and
                       (CMMStudyLastOpened <> nil);
      end;
  end;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    RestoreLayout := FALSE;
    RestoreStudy  := FALSE;
    UsedFramesCount :=0;

    if K_CMStudySingleOpenGUIModeFlag then
      for i := 0 to CMMFNumVisEdFrames-1 do
        if CMMFEdFrames[i].EdSlide <> nil then Inc(UsedFramesCount);

    if Sender = aEditCloseCurActive then
    begin
      if K_CMSFullScreenForm <> nil then
        aEditFullScreenCloseExecute( Sender );
      if CMMFActiveEdFrame <> nil then
      begin
        CheckRestoreMode( CMMFActiveEdFrame );
        CMMFActiveEdFrame.EdFreeObjects();
      end;
    end
    else if (Sender is TControl) then
    begin
      CheckRestoreMode( TN_CMREdit3Frame(TControl(Sender).Parent) );
      TN_CMREdit3Frame(TControl(Sender).Parent).EdFreeObjects();
    end;

    CMMFDisableActions( nil );
    K_FormCMSIsodensity.InitIsodensityMode();

    if RestoreLayout then
    begin
      N_Dump2Str( 'Close >> Set CMMStudyPrevLayout' );
      CMMFSetEdFramesLayout0( CMMStudyPrevLayout );
      CMMStudyPrevLayout := eflNotDef;
      CMMStudyLastOpened := nil;
      N_Dump2Str( 'Close >> Clear Study in Open Context' );
      CMMFShowString( '' ); // Clear Images Saving Strings
    end;

    if RestoreStudy then
    begin
      N_Dump2Str( 'Close >> Before CMMAddMediaToOpened' );
      CMMAddMediaToOpened( TN_UDCMSlide(CMMStudyLastOpened), [] );
      N_Dump2Str( 'Close >> After CMMAddMediaToOpened' );
    end;

  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditCloseCurActiveExecute

//********************************** TN_CMResForm.aEditCloseAllExecute ***
// Finish Editing Slide in All Editor Frames
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditCloseAll Action handler
//
procedure TN_CMResForm.aEditCloseAllExecute(Sender: TObject);
var
  RestoreLayout : Boolean;
  RestoreStudy : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    RestoreLayout := FALSE;
    RestoreStudy  := FALSE;
    if K_CMStudySingleOpenGUIModeFlag then
    begin
      RestoreLayout := CMMFActiveEdFrame.IfSlideIsStudy and (CMMStudyPrevLayout <> eflNotDef);
      RestoreStudy  := not RestoreLayout and
                      (CMMStudyLastOpened <> nil);
    end;

    CMMFFreeEdFrObjects();
    CMMFDisableActions( nil );
    K_FormCMSIsodensity.InitIsodensityMode();

    if RestoreLayout then
    begin
      N_Dump2Str( 'CloseAll >> Set CMMStudyPrevLayout' );
      CMMFSetEdFramesLayout0( CMMStudyPrevLayout );
      CMMStudyPrevLayout := eflNotDef;
      CMMStudyLastOpened := nil;
      N_Dump2Str( 'CloseAll >> Clear Study in Open Context' );
      CMMFShowString( '' ); // Clear Images Saving Strings
    end;

    if RestoreStudy then
    begin
      N_Dump2Str( 'CloseAll >> Before CMMAddMediaToOpened' );
      CMMAddMediaToOpened( TN_UDCMSlide(CMMStudyLastOpened), [] );
      N_Dump2Str( 'CloseAll >> After CMMAddMediaToOpened' );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditCloseAllExecute

//****************************************** TN_CMResForm.aEditPointExecute ***
// Set Normal mode for Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// Set Active Editor Frame in Normal mode from Zoom or Panning mode
//
// OnExecute MainActions.aEditPoint Action handler
//
procedure TN_CMResForm.aEditPointExecute( Sender: TObject );
var
  ActEdFrame : TN_CMREdit3Frame;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    ActEdFrame := CMMFActiveEdFrame;
    if Sender <> nil then
      ActEdFrame := nil;
    CMMSetFramesMode( cmrfemPoint, ActEdFrame );
    if CMMFCheckBSlideExisting() then
    begin
      CMMFActiveEdFrame.RebuildVObjsSearchList();
      K_FormCMSIsodensity.SelfClose();
    end;
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditPointExecute

//*************************************** TN_CMResForm.aEditRestOrigExecute ***
// Restoró Image original pixels, flip and rotate state and
// remove all annotions in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditRestOrig Action handler
//
procedure TN_CMResForm.aEditRestOrigImageExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
    begin
      if CMMFActiveEdFrame.EdSlide.CMSShowWaitStateFlag then
        CMMFShowHideWaitState( TRUE );
      // Clear All changes
      EdUndoBuf.UBRestoreSrcImage( aEditRestOrigImage.Caption );
      EdVObjSelected := nil;
      CMMFFinishImageEditing( K_CML1Form.LLLEdit6.Caption,
//                         'Original Image is restored',
                         [], -1, TRUE ); // [] Change Flags because all done in UBRestoreSrcImage

      EdSlide.CMSlideECSFlags := EdSlide.CMSlideECSFlags + [cmssfCurImgChanged];
      K_CMEDAccess.EDASaveSlideToECache( EdSlide );
      if K_CMEDAccess.SlidesSaveMode = K_cmesImmediately then // needed because CMMFFinishImageEditing was called with [] Change Flags
        K_CMEDAccess.EDASaveSlidesArray( @EdSlide, 1 );

      CMMFDisableActions( nil );
      K_FormCMSIsodensity.InitIsodensityMode();
      RebuildVObjsSearchList();
      if CMMFActiveEdFrame.EdSlide.CMSShowWaitStateFlag then
        CMMFShowHideWaitState( FALSE );
    end; // with N_CM_MainForm do
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditRestoreOrigExecute

//************************************* TN_CMResForm.aEditReturnOrigExecute ***
// Restore original Image pixels but save it's flip and rotate xtate and
// and all annotations in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditRestOrigState Action handler
//
procedure TN_CMResForm.aEditRestOrigStateExecute( Sender: TObject );
var
  SelectedVObj : TN_UDCompVis;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
    begin
      SelectedVObj := EdVObjSelected;

      if SelectedVObj <> nil then
        ChangeSelectedVObj( 0 );

      EdUndoBuf.UBRestoreSrcState( aEditRestOrigState.Caption );

      if SelectedVObj <> nil then
        ChangeSelectedVObj( 1, SelectedVObj );

      CMMFFinishImageEditing( K_CML1Form.LLLEdit7.Caption,
//        'Image is returned to Original state',
         [], -1 );
      CMMFDisableActions( nil );
      K_FormCMSIsodensity.InitIsodensityMode();
    end; // with N_CM_MainForm do
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditReturnOrigExecute

//*************************************** TN_CMResForm.aEditUndoLastExecute ***
// Undo last editing action in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditUndoLast Action handler
//
procedure TN_CMResForm.aEditUndoLastExecute( Sender: TObject );
var
  Size1 : TPoint;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
      if (EdUndoBuf <> nil) then
      begin
        CMMFShowHideWaitState( TRUE );
        Size1 := EdSlide.GetMapImage.DIBObj.DIBSize;
        CMMFRebuildViewAfterUNDO( EdUndoBuf.UBPopSlideState, TPoint(Size1) );
  //!! Not needed because is done in CMMFRebuildViewAfterUNDO
  //!!      if Int64(EdSlide.GetMapImage.DIBObj.DIBSize) <> Int64(Size1) then
  //!!        CMMCurFThumbsDGrid.DGInitRFrame(); // is needed because Thumbnail Aspect may be changed
        CMMFShowHideWaitState( FALSE );
        CMMFShowStringByTimer( K_CML1Form.LLLEdit2.Caption
    //         'Last Action Undone'
                              ); // debug
      end;
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditUndoLastExecute

//*************************************** TN_CMResForm.aEditRedoLastExecute ***
// Redo last editing action in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditRedoLast Action handler
//
procedure TN_CMResForm.aEditRedoLastExecute( Sender: TObject );
var
  Size1 : TPoint;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
      if (EdUndoBuf <> nil) then
      begin
        CMMFShowHideWaitState( TRUE );
        Size1 := EdSlide.GetMapImage.DIBObj.DIBSize;
        CMMFRebuildViewAfterUNDO( EdUndoBuf.UBPrevPopedSlideState(), Size1 );
        CMMFShowHideWaitState( FALSE );
        CMMFShowStringByTimer( K_CML1Form.LLLEdit3.Caption
//                  'Last Action Redone'
                             ); // debug
      end;
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditRedoLastExecute

//*************************************** TN_CMResForm.aEditUndoRedoExecute ***
// Show Undo-Redo Form for Undo or Redo several last editing actions
// in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditUndoRedo Action handler
//
procedure TN_CMResForm.aEditUndoRedoExecute( Sender: TObject );
var
  CInd, Delta: Integer;
  Size1 : TPoint;
  CSFlags: TN_CMSlideSFlags;
  RedrawSlide : Boolean;
  i, j : Integer;
  HistActType : TK_CMSlideHistActType;
  PSkipSelf : PByte;
  SkipSelf : Byte;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
    if (EdUndoBuf <> nil) then
    begin
      CMMFShowHideWaitState( TRUE );
      with TK_FormCMUndoRedo.Create(Application) do
      begin
  //      BaseFormInit( nil );
        BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    // Prepare Image View in UNDO/REDO Form
        // clear Selected Vobj
        RedrawSlide := ChangeSelectedVObj( 0 );

        // Save Colorize/Isodensity state and clear
        with EdSlide, P.CMSDB do begin
          CSFlags := SFlags * [cmsfShowColorize,cmsfShowIsodensity];
          SFlags := SFlags - [cmsfShowColorize,cmsfShowIsodensity];
          if CSFlags <> [] then begin
            RebuildMapImageByDIB();
            RedrawSlide := TRUE;
          end;

          PSkipSelf := GetPMeasureRootSkipSelf();
          SkipSelf := PSkipSelf^;
          PSkipSelf^ := 0;
        end;

  //      if RedrawSlide then
  //        RFrame.RedrawAllAndShow();

        CInd := EdUndoBuf.UBCurInd; // UBCount
        N_Dump2Str( format( 'UndoRedo Start Cur=%d of %d', [CInd, EdUndoBuf.UBCount] ) );
        Size1 := EdSlide.GetMapImage.DIBObj.DIBSize;
        ShowUndoBufList( EdUndoBuf );

        ShowModal;

        // Restore Colorize/Isodensity state and clear
  //      RedrawSlide := FALSE;

        with EdSlide.P.CMSDB do
          if (cmsfGreyScale in SFlags) and (CSFlags <> []) then begin
            SFlags := SFlags + CSFlags;
            RedrawSlide := TRUE;
          end;

//        if ModalResult <> mrOK then
        if (ModalResult <> mrOK) or (EdUndoBuf.UBCurInd = CInd) then
        begin  // Cancel Undo/Redo state selection
          N_Dump2Str( 'UndoRedo Fin without change state' );
          EdUndoBuf.UBCurInd := CInd;
          // Restore Slide context because MapRoot Subtree is changed to it's copy
          EdSlide.PutDirChildSafe( K_CMSlideIndMapRoot, URCurMapRoot );
          EdSlide.PrepROIView( [] );
          RebuildVObjsSearchList();
          RFrame.RFrChangeRootComp( URCurMapRoot );
          EdSlide.GetPMeasureRootSkipSelf()^ := SkipSelf;
          if RedrawSlide then
          begin
            EdSlide.RebuildMapImageByDIB();
            RFrame.RedrawAllAndShow();
          end;
            RFrame.RedrawAllAndShow(); // for Search Context Rebuild
        end
        else
        begin  // select Undo/Redo state  - ModalResult = mrOK
          Delta := EdUndoBuf.UBCurInd - CInd;
          if Delta > 0 then
            CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit4.Caption,
  //                    '%d Actions Redone',
                                   [Delta] ) )
          else
            CMMFShowStringByTimer( Format( K_CML1Form.LLLEdit5.Caption,
  //             '%d Actions Undone',
                                   [-Delta] ) );

          // Add Slide History
          i := CInd;
          j := EdUndoBuf.UBCurInd;
          HistActType := K_shATUndoChange;
          if Delta > 0 then
            HistActType := K_shATRedoChange;

          with  K_CMEDAccess do
            repeat
              if Delta > 0 then Inc( i );
              EDAAddHistActionToSlideBuffer( EdSlide, EDAChangeHistActionType(
                         EdUndoBuf.UBGetSlideHistActionCode( i ), HistActType ) );
              if Delta < 0 then Dec( i );
            until i = j;

          N_Dump2Str( format( 'UndoRedo Fin Cur=%d of %d', [j, EdUndoBuf.UBCount] ) );
          URCurMapRoot.UDDelete();
          if RedrawSlide then
            EdSlide.ClearMapImage();
          CMMFRebuildViewAfterUNDO( URChangeSlideCurState, TPoint(Size1) );
        end; // if ModalResult = mrOK then
      end; // with TK_FormCMUndoRedo.Create(Application) do
      CMMFShowHideWaitState( FALSE );
    end; // with CMMFActiveEdFrame do
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditUndoRedoExecute

//************************************* TN_CMResForm.aEditFullScreenExecute ***
// Edit annotations in Active Editor Frame in FullScreenMode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditFullScreen Action handler
//
procedure TN_CMResForm.aEditFullScreenExecute(Sender: TObject);
var
//  MonitorIndex : integer;
//  NeededHeight, NeededWidth, NeededLeft, NeededTop : integer;
  ZoomLeft : Integer;
  ZoomTop  : Integer;
//  WMeth : TWndMethod;
//  CurMonitor : TMonitor;
  NeededRect, CurFormRect, CurMonitorRect : TRect;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
  //    Dec(K_CMD4WWaitApplyDataCount);
  //    K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    NeededRect := K_PrepFullScreenInfo( CMMCurFMainForm, CurFormRect, CurMonitorRect );
{
    // Get Proper Monitor
    //    CurMonitor := Monitor;
    with CMMCurFMainForm do
      CurFormRect := IRect( Left, Top, Left + Width, Top + Height );
    N_GetMonWARByRect( CurFormRect, @MonitorIndex );
    CurMonitor := Screen.Monitors[MonitorIndex];

    with CurMonitor do
    begin
      CurMonitorRect := WorkareaRect;
      NeededHeight := WorkareaRect.Bottom - WorkareaRect.Top;
      NeededWidth  := WorkareaRect.Right - WorkareaRect.Left;
      NeededLeft   := WorkareaRect.Left;
      NeededTop    := WorkareaRect.Top;
      if Primary then // Current Monitor is Primary
      begin
      // use whole Monitor Size instead of Work Area Size
      // (TaskBar is present only on Primary monitor)
        NeededHeight := Height;
        NeededWidth  := Width;
        NeededLeft   := Left;
        NeededTop    := Top;
      end;
    end; //  with CurMonitor do
}
    K_CMSFullScreenForm := TN_BaseForm.Create( Application );

    with TN_BaseForm(K_CMSFullScreenForm) do
    begin
      BFSelfName := 'FullScreenForm';
  //    RFrame.ParentForm := Result;
  //    BaseFormInit( N_CM_MainForm );
        BaseFormInit( nil );
  //    BaseFormInit( nil, '', [rspfCurMonWAR,rspfMaximize], [rspfCurMonWAR,rspfMaximize] );

      Left := NeededRect.Left;
      Top  := NeededRect.Top;
      Height := NeededRect.Bottom;
      Width  := NeededRect.Right;
{
      Left := NeededLeft;
      Top  := NeededTop;
      Height := NeededHeight;
      Width  := NeededWidth;
}
      BorderStyle := bsNone;

      K_GetCtrlAlignAttrs( CMMFActiveEdFrame, EdFrAAttrs );

      FullScreenScaleFactor := CMMFActiveEdFrame.RFrame.RFGetCurRelObjSize();
      CMMFActiveEdFrame.Align := alNone;

      CMMFActiveEdFrame.Top    := -18; // To hide EdFrame Caption (its height = 16)
//      CMMFActiveEdFrame.Height := NeededHeight + 20;
      CMMFActiveEdFrame.Height := NeededRect.Bottom + 20;
      CMMFActiveEdFrame.Left   := -2; // To hide EdFrame Left Border
      CMMFActiveEdFrame.Width  := Width + 4; // To hide EdFrame Left Border

      CMMFActiveEdFrame.Parent := K_CMSFullScreenForm;
      ActiveControl := CMMFActiveEdFrame.RFrame;

      hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
      if hTaskbar <> 0 then
      begin // Hide TaskBar
        EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
        ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
      end;

      if N_BrigHist2Form <> nil then
      begin // Hide BrigHist Form
        N_BrigHist2Form.SelfClose();
        CMMCallActionByTimer( N_CMResForm.aToolsHistogramm2, FALSE );
      end;

      if K_FormCMSIsodensity <> nil then
      begin // Hide Isodensity Form
        K_FormCMSIsodensity.SelfClose();
        CMMCallActionByTimer( N_CMResForm.aToolsIsodensAttrs, FALSE );
      end;

      ZoomLeft := 0;
      ZoomTop  := 0;
      if K_CMSZoomForm <> nil then
      begin // Hide Zoom Form
        ZoomLeft := K_CMSZoomForm.Left;
        ZoomTop  := K_CMSZoomForm.Top;
        K_CMSZoomForm.Top := 0;
        K_CMSZoomForm.Left := 0;
        K_CMSZoomForm.Close();
        CMMCallActionByTimer( N_CMResForm.aViewZoomMode, FALSE ); // This Code is OK
      end;

      // activate prev actions
      CMMCallActionByTimer( nil, TRUE, 100 ); // This Code is OK
      // Set KeyPress handler to FullScreen Form
      OnKeyPress := N_CM_MainForm.FormKeyPress;
      KeyPreview := TRUE;

      // Correct Zoom Level before to Full Screen
      with CMMFActiveEdFrame.RFrame do
      begin
        RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
        SetZoomLevel( rfzmCenter );
      end;


      // Hide Main Form if needed
      N_IRectAnd( CurMonitorRect, CurFormRect );
      if (CurMonitorRect.Left <> CurFormRect.Left)   or
         (CurMonitorRect.Top <> CurFormRect.Top)     or
         (CurMonitorRect.Right <> CurFormRect.Right) or
         (CurMonitorRect.Bottom <> CurFormRect.Bottom) then
        CMMCurFMainForm.Hide; // Hide Main Visible Form before

      ShowModal;


      if K_CMSZoomForm <> nil then
      begin
        K_CMSZoomForm.Left := ZoomLeft;
        K_CMSZoomForm.Top  := ZoomTop;
      end;

      FullScreenScaleFactor := CMMFActiveEdFrame.RFrame.RFGetCurRelObjSize();

      if FullScreenScaleFactor < 1 then FullScreenScaleFactor := 1;

      K_SetCtrlAlignAttrs( CMMFActiveEdFrame, EdFrAAttrs );

      K_CMSFullScreenForm := nil;

      // Correct Zoom Level after Full Screen
      with CMMFActiveEdFrame.RFrame do
      begin
        RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
//        SetZoomLevel( rfzmCenter );
        SetZoomLevel( rfzmUpperleft );
      end;

      CMMCallActionByTimer( N_CMResForm.aServRefreshActiveFrame, TRUE, 100 ); // This Code is OK

      if hTaskbar <> 0 then
      begin // Show TaskBar
        EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
        ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
      end;

    end; // with TN_BaseForm(K_CMSFullScreenForm) do

    CMMFDisableActions( Sender );

    // Show Main Form if needed
    if not CMMCurFMainForm.Visible then
    begin
      CMMCurFMainFormSkipOnShow := TRUE;
      CMMCurFMainForm.Show; // Show Main Visible Form after hide
      // Return Form before (Left,Top) because Show move Form to the Monitor (Left,Top)
//      CMMCurFMainForm.Left := CurFormRect.Left;
//      CMMCurFMainForm.Top := CurFormRect.Top;
    end;

  end; // with N_CM_MainForm do

//  N_CM_MainForm.CMMFShowStringByTimer( 'Full Screen Action' ); // debug
  AddCMSActionFinish( Sender );

{ !!! old code 24-06-2018
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
  //    Dec(K_CMD4WWaitApplyDataCount);
  //    K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    K_CMSFullScreenForm := TN_BaseForm.Create( Application );

    with TN_BaseForm(K_CMSFullScreenForm) do
    begin
      BFSelfName := 'FullScreenForm';
  //    RFrame.ParentForm := Result;
  //    BaseFormInit( N_CM_MainForm );
//        BaseFormInit( nil );
      BaseFormInit( nil, '', [rspfCurMonWAR,rspfMaximize], [rspfCurMonWAR,rspfMaximize] );

      NeededHeight := Height;
      NeededWidth  := Width;

      BorderStyle := bsNone;
//      Top    := 0;
//      Left   := 0;
//      Width  := Screen.Width;
//      Height := Screen.Height;
//      Width  := N_RectWidth( N_CurMonWAR );
//      Height := N_RectHeight( N_CurMonWAR );
//      Height := Height + 16;

      N_GetMonWARByRect( N_CurMonWAR, @MonitorIndex ); // Get Current Monitor Index

      with Screen.Monitors[MonitorIndex] do
      begin
        if Primary then // Current Monitor is Primary
        begin
        // use whole Monitor Size instead of Work Area Size
        // (TaskBar is present only on Primary monitor)
          NeededHeight := Height;
          NeededWidth  := Width;
        end;
      end; // with Screen.Monitors[MonitorIndex] do

      Height := NeededHeight;
      Width  := NeededWidth;

      K_GetCtrlAlignAttrs( CMMFActiveEdFrame, EdFrAAttrs );

      FullScreenScaleFactor := CMMFActiveEdFrame.RFrame.RFGetCurRelObjSize();
      CMMFActiveEdFrame.Align := alNone;

      CMMFActiveEdFrame.Top    := -18; // To hide EdFrame Caption (its height = 16)
      CMMFActiveEdFrame.Height := NeededHeight + 20;
      CMMFActiveEdFrame.Left    := -2; // To hide EdFrame Left Border
      CMMFActiveEdFrame.Width   := Width + 4; // To hide EdFrame Left Border

      CMMFActiveEdFrame.Parent := K_CMSFullScreenForm;
      ActiveControl := CMMFActiveEdFrame.RFrame;

      hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
      if hTaskbar <> 0 then
      begin // Hide TaskBar
        EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
        ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
      end;

      if N_BrigHist2Form <> nil then
      begin
        N_BrigHist2Form.SelfClose();
        CMMCallActionByTimer( N_CMResForm.aToolsHistogramm2, FALSE );
      end;

      if K_FormCMSIsodensity <> nil then
      begin
        K_FormCMSIsodensity.SelfClose();
        CMMCallActionByTimer( N_CMResForm.aToolsIsodensAttrs, FALSE );
      end;

      ZoomLeft := 0;
      ZoomTop  := 0;
      if K_CMSZoomForm <> nil then
      begin
        ZoomLeft := K_CMSZoomForm.Left;
        ZoomTop  := K_CMSZoomForm.Top;
        K_CMSZoomForm.Top := 0;
        K_CMSZoomForm.Left := 0;
        K_CMSZoomForm.Close();
        CMMCallActionByTimer( N_CMResForm.aViewZoomMode, FALSE ); // This Code is OK
      end;
      CMMCallActionByTimer( nil, TRUE, 100 ); // This Code is OK
      OnKeyPress := N_CM_MainForm.FormKeyPress;
      KeyPreview := TRUE;

      // Correct Zoom Level before Full Screen
      with CMMFActiveEdFrame.RFrame do
      begin
        RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
        SetZoomLevel( rfzmCenter );
      end;

{  // !! try to skip Ctrl+F key
      WMeth := CMMFullScreenWndProc;
      TMethod(WMeth).Data := K_CMSFullScreenForm;
      WindowProc := WMeth;
}
{
      ShowModal;

      if K_CMSZoomForm <> nil then
      begin
        K_CMSZoomForm.Left := ZoomLeft;
        K_CMSZoomForm.Top  := ZoomTop;
      end;

      FullScreenScaleFactor := CMMFActiveEdFrame.RFrame.RFGetCurRelObjSize();

      if FullScreenScaleFactor < 1 then FullScreenScaleFactor := 1;

      K_SetCtrlAlignAttrs( CMMFActiveEdFrame, EdFrAAttrs );

      K_CMSFullScreenForm := nil;

      // Correct Zoom Level after Full Screen
      with CMMFActiveEdFrame.RFrame do
      begin
        RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
//        SetZoomLevel( rfzmCenter );
        SetZoomLevel( rfzmUpperleft );
      end;

      CMMCallActionByTimer( N_CMResForm.aServRefreshActiveFrame, TRUE, 100 ); // This Code is OK

      if hTaskbar <> 0 then
      begin // Show TaskBar
        EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
        ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
      end;

    end; // with TN_BaseForm(K_CMSFullScreenForm) do

    CMMFDisableActions( Sender );


  end; // with N_CM_MainForm do

//  N_CM_MainForm.CMMFShowStringByTimer( 'Full Screen Action' ); // debug
  AddCMSActionFinish( Sender );
}
end; // procedure TN_CMResForm.aEditFullScreenExecute

//*************************************** TN_CMResForm.aEditFullScreenCloseExecute ***
// Finish Editing annotations in FullScreenMode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditFScreenClose Action handler
//
procedure TN_CMResForm.aEditFullScreenCloseExecute(Sender: TObject);
begin
  if K_CMSFullScreenForm = nil then
    N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption )
  else
  begin
    K_CMSFullScreenForm.Close();
{ !!! Debug code - try to operate with FullSceen Form in non modal state
    with N_CM_MainForm do
    begin
      if fsModal in K_CMSFullScreenForm.FormState then
      // Finish Full Screen in modal state
        K_CMSFullScreenForm.ModalResult := mrOK
      else
      begin
      // Done all needed after finish Full Screen in non modal state
        K_CMSFullScreenForm.Close();

        FullScreenScaleFactor := CMMFActiveEdFrame.RFrame.RFGetCurRelObjSize();
        K_SetCtrlAlignAttrs( CMMFActiveEdFrame, EdFrAAttrs );

        K_CMSFullScreenForm := nil;

        // Correct Zoom Level after Full Screen
        with CMMFActiveEdFrame.RFrame do
        begin
          RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
          SetZoomLevel( rfzmUpperleft );
        end;

        CMMCallActionByTimer( N_CMResForm.aServRefreshActiveFrame, TRUE, 100 ); // This Code is OK

        if hTaskbar <> 0 then
        begin
          EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
          ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
        end;


        CMMFDisableActions( Sender );


        AddCMSActionFinish( Sender );

      end;
    end; // with N_CM_MainForm do
}
    N_Dump2Str( 'Do ' + TAction(Sender).Caption );
  end;
end; // procedure TN_CMResForm.aEditFullScreenCloseExecute

//***************************** TN_CMResForm.aEditRestoreMarkedAsDelExecute ***
// Restore Sledes Marked as Deleted
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aEditRestoreMarkedAsDel Action handler
//
procedure TN_CMResForm.aEditRestoreDelExecute(Sender: TObject);
var
  NumSlides : Integer;
  SlidesArray : TN_UDCMSArray;
  ExtLockedStr : string;

Label Fin;
begin
  SlidesArray := nil; // to skip warning
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with K_CMEDAccess do
  begin
    SlidesArray := K_CMSBuildSlidesArrayByList( K_CMCurVisSlidesArray,
                               N_CM_MainForm.CMMCurFThumbsDGrid.DGMarkedList );
    NumSlides := Length(SlidesArray);
    if NumSlides = 0 then
    begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      goto Fin;
    end;
    NumSlides := K_CMSlidesUnDelete( @SlidesArray[0], NumSlides );
    ExtLockedStr := '';

    if LockResDelCount > 0 then
    begin
      ExtLockedStr := format( K_CML1Form.LLLRestoreDelSlides1.Caption, [LockResDelCount]);
//      ExtLockedStr := format(
//        ' %d Media object(s) are already deleted by other CMS user{s}',
//        [LockResDelCount]);
      K_CMShowMessageDlg( ExtLockedStr, mtInformation );
      ExtLockedStr := ',' + ExtLockedStr;
      K_CMSlidesSetDeleteState(@LockResDelSlides[0], LockResDelCount, FALSE );
      K_CMDelSlidesFree();
    end;
    EDADelSlides( @LockResSlides[0], LockResCount, FALSE, TRUE );
    LockResCount := 0; // Clear LockResCount to prevent AMSC Error
  end;

  with N_CM_MainForm do
  begin
    CMMFRebuildVisSlides();
//    CMMFDisableActions(nil);
    CMMFShowStringByTimer( format( K_CML1Form.LLLRestoreDelSlides2.Caption,
       // ' %d object(s) were restored%s'
                          [NumSlides,ExtLockedStr] ) );
  end;
//  K_FormCMSIsodensity.InitIsodensityMode();

Fin:
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aEditRestoreMarkedAsDelExecute

    //*********  View Actions  ************

procedure N_SetEdFramesLayoutExecute( AEdFrLayout: TN_EdFrLayout );
begin
  N_CM_MainForm.CMMFSetEdFramesLayout0( AEdFrLayout );
  N_CM_MainForm.CMMFShowString( '' ); // Clear Images Saving Strings
end;

//************************************** TN_CMResForm.aViewOneSquareExecute ***
// Set One Editor Frame Layout
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewOneSquare Action handler
//
procedure TN_CMResForm.aViewOneSquareExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_SetEdFramesLayoutExecute( eflOne );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewOneSquareExecute

//********************************** TN_CMResForm.aViewTwoHorizontalExecute ***
// Set Two Editor Frames with Horizontal Splitter between them Layout
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewTwoHorizontal Action handler
//
procedure TN_CMResForm.aViewTwoHorizontalExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_SetEdFramesLayoutExecute( eflTwoHSp );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewTwoHorizontalExecute

//************************************ TN_CMResForm.aViewTwoVerticalExecute ***
// Set Two Editor Frames with Vertical Splitter between them Layout
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewTwoVertical Action handler
//
procedure TN_CMResForm.aViewTwoVerticalExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_SetEdFramesLayoutExecute( eflTwoVSp );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewTwoVerticalExecute

//************************************ TN_CMResForm.aViewFourSquaresExecute ***
// Set Four Editor Frames with Horizontal Splitter between Frames Pairs Layout
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewFourSquares Action handler
//
procedure TN_CMResForm.aViewFourSquaresExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_SetEdFramesLayoutExecute( eflFourHSp );
  AddCMSActionFinish( Sender );
end;  // procedure TN_CMResForm.aViewFourSquaresExecute

//************************************ TN_CMResForm.aViewNineSquaresExecute ***
// Set Nine Editor Frames without Splitters Layout
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewNineSquares Action handler
//
procedure TN_CMResForm.aViewNineSquaresExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  N_SetEdFramesLayoutExecute( eflNine );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewNineSquaresExecute

//******************************************* TN_CMResForm.aViewZoomExecute ***
// Set Zoom mode for Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// In Zoom mode Cursor is magnifying glass and Image can be zoomed by mouse clicks
//
// OnExecute MainActions.aViewZoom Action handler
//
procedure TN_CMResForm.aViewZoomExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    CMMSetFramesMode( cmrfemZoom );
    K_FormCMSIsodensity.SelfClose();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewZoomExecute

//**************************************** TN_CMResForm.aViewPanningExecute ***
// Set Panning mode for Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// In Panning mode Cursor is crSizeAll and Image can be shifted by mouse drag
//
// OnExecute MainActions.aViewPanning Action handler
//
procedure TN_CMResForm.aViewPanningExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    CMMSetFramesMode( cmrfemPan );
    K_FormCMSIsodensity.SelfClose();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewPanningExecute

//************************************* TN_CMResForm.aViewFullScreenExecute ***
// Show Slide in Active Editor Frame over the full Screen
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aViewFullScreen Action handler
//
procedure TN_CMResForm.aViewFullScreenExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do begin
    if not CMMFCheckBSlideExisting() then begin
  //    Dec(K_CMD4WWaitApplyDataCount);
  //    K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do
    begin
      RFrame.aFullScreenExecute( Sender );
      CMMCurFMainForm.SetFocus();
    end;
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewFullScreenExecute

//*********************************** TN_CMResForm.aViewFitToWindowExecute ***
// Set Panning mode for Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// In Panning mode Cursor is crSizeAll and Image can be shifted by mouse drag
//
// OnExecute MainActions.aViewFitToWindow Action handler
//
procedure TN_CMResForm.aViewFitToWindowExecute( Sender: TObject );
//
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CM_MainForm.CMMFActiveEdFrame.RFrame.aFitInWindowExecute( nil );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewFitToWindowExecute

//************************************* TN_CMResForm.aViewSlideColorExecute ***
// Set View Color mode for Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// In View Color mode Cursor is crSizeAll and Image color is shown in StatusBar
//
// OnExecute MainActions.aViewSlideColor Action handler
//
procedure TN_CMResForm.aViewSlideColorExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
//    CMMFActiveEdFrame.PopupMenu := EdFramesPopupMenu;
//    CMMFActiveEdFrame.PopupMenu := EdFrPointPopupMenu;
    CMMFActiveEdFrame.PopupMenu := CMMEdFramePopUpMenu;
    N_SetMouseCursorType( CMMFActiveEdFrame.RFrame, crDefault );

    with CMMFActiveEdFrame, RFrame do
    begin
      RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys,rfafScrollCoords];
      EdViewEditMode := cmrfemGetSlideColor;
      CMMEdVEMode := cmrfemGetSlideColor;
      EdGetSlideColorRFA.ActEnabled := TRUE;
    end;
    K_FormCMSIsodensity.SelfClose();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewSlideColorExecute

//*********************************** TN_CMResForm.aViewThumbRefreshExecute ***
// Refresh thumbnails list
//
//     Parameters
// Sender - Event Sender
//
// Display new objects thumbnails in case they have been
// acquired on other network PC's for the same patient.
//
// OnExecute MainActions.aViewThumbRefresh Action handler
//
procedure TN_CMResForm.aViewThumbRefreshExecute(Sender: TObject);
var
  NewSlidesCount, DelSlidesCount, UpdateSlidesCount : Integer;
  WStr : string;
  UseProfilesValidation : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMEDAccess.EDARefreshCurSlidesSet( NewSlidesCount, DelSlidesCount,
                                       UpdateSlidesCount );
  with N_CM_MainForm do
  begin
    CMMFRebuildVisSlides();
//    if ((NewSlidesCount > 0) or (DelSlidesCount > 0) or (UpdateSlidesCount > 0)) then
    if  (Sender <> aViewDisplayDel) and
       ((NewSlidesCount > 0) or (DelSlidesCount > 0) or (UpdateSlidesCount > 0)) then
    begin
      CMMFDisableActions( nil );
      WStr := '';

      if NewSlidesCount > 0 then
        WStr := WStr +  Format( K_CML1Form.LLLRefreshSlides1.Caption, [NewSlidesCount] );
//        WStr := WStr +  Format( ' %d new object(s) have been created', [NewSlidesCount] );
      if DelSlidesCount > 0 then begin
        if WStr <> '' then
          WStr := WStr + ',';
        WStr := WStr + Format( K_CML1Form.LLLRefreshSlides2.Caption, [DelSlidesCount] );
//        WStr := WStr + Format( ' %d object(s) have been deleted', [DelSlidesCount] );
      end;
      if UpdateSlidesCount > 0 then
      begin
        if WStr <> '' then
          WStr := WStr + ',';
        WStr := WStr + Format( K_CML1Form.LLLRefreshSlides3.Caption, [UpdateSlidesCount] );
//        WStr := WStr + Format( ' %d object(s) have been changed', [UpdateSlidesCount] );
        WStr := K_CML1Form.LLLRefreshSlides4.Caption + WStr;
//      WStr := 'Media objects list was changed by other CMS user(s) activity:' + WStr;
      end;

      if WStr <> '' then
      begin
        CMMFShowStringByTimer( WStr );
      end;
    end;

    if (Sender <> aViewDisplayDel) or not aViewDisplayDel.Checked then
    begin
    // Done if Pure Refresh or not DisplayMarkedAsDel View Mode
      UpdateSlidesCount := K_CMRefreshOpenedView();

      if UpdateSlidesCount > 0 then
      begin

        K_CMShowMessageDlg( format( K_CML1Form.LLLSlidesOpen1.Caption,
//        K_CMShowMessageDlg( format( K_CML1Form.LLLRefreshSlides5.Caption, // Text is Duplicated
  //        ' %d opened Media object(s) were updated because they have been changed by other CMS user(s) ',
                            [UpdateSlidesCount] ), mtInformation );
      end;
    end;

    K_FormCMSIsodensity.InitIsodensityMode();

    UseProfilesValidation := K_CMLimitDevUseTypeNameValidation();
    if UseProfilesValidation and
       (K_CMLimitDevProfilesToRTDBContext() > 0) then
      K_FCMShowDeviceLimitWarning(); // Show Warning

    CMMFDisableActions( nil );

    if UseProfilesValidation then
      CMMUpdateUIByDeviceProfiles ();

    EdFramesPanel.Refresh;
    
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewThumbRefreshExecute

//*********************************** TN_CMResForm.aViewDisplayDelExecute ***
// Toggle Marked as Deleted Show Flag and Refresh thumbnails list
//
//     Parameters
// Sender - Event Sender
//
// Display or hide objects thumbnails in case they have been marked as deleted
//
// OnExecute for MainActions.aViewShowMarkedAsDel and
// MainActions.aViewShowMarkedAsDelButton Actions handler
//
procedure TN_CMResForm.aViewDisplayDelExecute(Sender: TObject);
var
  OpenSlides : TN_UDCMSArray;
  i, Ind: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMShowArchivedSlidesFlag then
  begin
    aViewDisplayArchived.Checked := FALSE;
    aViewDisplayArchivedExecute( nil );
  end;

  K_CMMarkAsDelShowFlag := TAction(Sender).Checked;
  if Sender = aViewDisplayDel then
    aViewDisplayDelButton.Checked := K_CMMarkAsDelShowFlag
  else
    aViewDisplayDel.Checked := K_CMMarkAsDelShowFlag;

  N_Dump1Str( format( 'Show deleted=%s', [N_B2S(K_CMMarkAsDelShowFlag)] ) );

  // Close all opend slides
  Ind := 0;
  with N_CM_MainForm do
  begin
    SetLength( OpenSlides, CMMFNumVisEdFrames );
    for i := 0 to CMMFNumVisEdFrames-1 do
    begin
      if CMMFEdFrames[i].EdSlide = nil then Continue;
      OpenSlides[Ind] := CMMFEdFrames[i].EdSlide;
      Inc(Ind);
    end; // for i := 0 to CMMFNumVisEdFrames-1 do
  end;
  if Ind > 0 then
    K_CMSlidesClose( @OpenSlides[0], Ind, [] );

  aViewThumbRefreshExecute( aViewThumbRefresh );
//  DisplayDelButton.Enabled := TRUE;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewDisplayDelExecute

//*********************************** TN_CMResForm.aViewZoomModeExecute ***
// Open Zoom Mode
//
//     Parameters
// Sender - Event Sender
//
// Display form with Zoom slider
//
// OnExecute MainActions.aViewZoomMode Action handler
//
procedure TN_CMResForm.aViewZoomModeExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if K_CMSZoomForm <> nil then
    K_CMSZoomForm.Close()
  else
  begin
    K_CMSZoomForm := K_CMSZoomModeFormGet();
    TK_FormCMSZoomMode(K_CMSZoomForm).SetByCurActiveFrame();
    K_CMSZoomForm.Show;
  end;
  N_CM_MainForm.CMMFDisableActions( Sender );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewZoomModeExecute

//************************************** TN_CMResForm.aViewStudyOnlyExecute ***
// Set View Studies Only Mode
//
//     Parameters
// Sender - Event Sender
//
// Display Studies Only in Thumbnails Frame
//
// OnExecute MainActions.aViewStudyOnly Action handler
//
procedure TN_CMResForm.aViewStudyOnlyExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMStudyOnlyThumbsShowGUIModeFlag := aViewStudyOnly.Checked;
  N_CM_MainForm.CMMFRebuildVisSlides();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewStudyOnlyExecute

//*********************************** TN_CMResForm.aViewPresentationExecute ***
// Presentation manager
//
//     Parameters
// Sender - Event Sender
//
// View selected slides in Presentation manager
//
// OnExecute MainActions.aViewPresentation Action handler
//
procedure TN_CMResForm.aViewPresentationExecute(Sender: TObject);
var
  SlidesArray : TN_UDCMSArray;
  SavedCursor : TCursor;

begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  with N_CM_MainForm, K_CMEDAccess do
  begin
    SlidesArray := Copy( CMMAllSlidesToOperate, 0, Length(CMMAllSlidesToOperate) );

    K_CMSlidesLockForOpen( @SlidesArray[0],
                           Length(SlidesArray), K_cmlrmOpenLock );
    if LockResCount = 0 then begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      AddCMSActionFinish( Sender );
      Screen.Cursor := SavedCursor;
      Exit;
    end;
    K_CMSResampleSlides( @LockResSlides[0], LockResCount, CMMFShowString );
    SlidesArray := Copy( LockResSlides, 0, LockResCount );
  end;
  Screen.Cursor := SavedCursor;

  if Length(SlidesArray) > 0 then
    with K_CMGetPresentForm() do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      PRSetSlides( @SlidesArray[0], Length(SlidesArray) );

      ShowModal;
    end // with TK_FormCMPrint1.Create( Application ) do
  else
    N_CM_MainForm.CMMFShowString( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do' );

  K_CMEDAccess.EDAUnlockAllLockedSlides(K_cmlrmOpenLock);

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewPresentationExecute

//******************************** TN_CMResForm.aViewDisplayArchivedExecute ***
// Set View Studies Only Mode
//
//     Parameters
// Sender - Event Sender
//
// Display Studies Only in Thumbnails Frame
//
// OnExecute MainActions.aViewStudyOnly Action handler
//
procedure TN_CMResForm.aViewDisplayArchivedExecute(Sender: TObject);
var
  i, L : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMMarkAsDelShowFlag then
  begin
    aViewDisplayDel.Checked := FALSE;
    aViewDisplayDelExecute(  aViewDisplayDel );
  end;
  K_CMShowArchivedSlidesFlag := aViewDisplayArchived.Checked;
  N_Dump1Str( format( 'Show archived=%s', [N_B2S(K_CMShowArchivedSlidesFlag)] ) );
  if Sender <> nil then
  begin // Execute Action by User (not indirect call from other actions)
    with N_CM_MainForm do
    begin
      CMMFRebuildVisSlides();
      // Close all become invisible (Studies with archived slides only)
      if not K_CMShowArchivedSlidesFlag then
      begin
        L := Length(K_CMCurVisSlidesArray);
        for i := 0 to High(CMMFEdFrames) do
        begin
          if (CMMFEdFrames[i] <> nil)         and
             CMMFEdFrames[i].Visible          and
             (CMMFEdFrames[i].EdSlide <> nil) and
             ( (L = 0) or
               (0 > K_IndexOfIntegerInRArray( Integer(CMMFEdFrames[i].EdSlide),
                              PInteger(@K_CMCurVisSlidesArray[0]), L ) ) ) then
          CMMFEdFrames[i].EdFreeObjects();
        end; // for i := 0 to High(CMMFEdFrames) do
      end; // if not K_CMShowArchivedSlidesFlag then
    end; // with N_CM_MainForm do
  end; // if Sender <> nil then
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewDisplayArchivedExecute

    //********* View->Toolbars Actions

//************************************* TN_CMResForm.aVTBAlterationsExecute ***
// Set Alterations Toolbar Visibility
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBAlterations Action handler
//
procedure TN_CMResForm.aVTBAlterationsExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CM_MainForm.CMMFChangeToolBarsVisibility();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aVTBAlterationsExecute

//***************************************** TN_CMResForm.aVTBCaptureExecute ***
// Toggle Capture Toolbar Visibility (not used now)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBCapture Action handler
//
procedure TN_CMResForm.aVTBCaptureExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CM_MainForm.CMMFChangeToolBarsVisibility();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aVTBCaptureExecute

//****************************************** TN_CMResForm.aVTBSystemExecute ***
// Toggle System Toolbar Visibility (not used now)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBSystem Action handler
//
procedure TN_CMResForm.aVTBSystemExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CM_MainForm.CMMFChangeToolBarsVisibility();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aVTBSystemExecute

//**************************************** TN_CMResForm.aVTBViewFiltExecute ***
// Toggle View and Filter Toolbar Visibility (not used now)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBViewFilt Action handler
//
procedure TN_CMResForm.aVTBViewFiltExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CM_MainForm.CMMFChangeToolBarsVisibility();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aVTBViewFiltExecute

//********************************** TN_CMResForm.aVTBAllTopToolbarsExecute ***
// Set All Top Toolbars Visibility
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBAllTopToolbars Action handler
//
procedure TN_CMResForm.aVTBAllTopToolbarsExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

{ old var
  if aVTBAllTopToolbars.Checked then // restore saved states for All Top Toolbars
  begin
    aVTBViewFilt.Checked := CMRFViewFiltToolbar;
    aVTBCapture.Checked  := CMRFCaptureToolbar;
    aVTBSystem.Checked   := CMRFSystemToolbar;
  end else //************************** save states for All Top Toolbars and hide them
  begin
    CMRFViewFiltToolbar := aVTBViewFilt.Checked;
    CMRFCaptureToolbar  := aVTBCapture.Checked;
    CMRFSystemToolbar   := aVTBSystem.Checked;

    aVTBViewFilt.Checked := False;
    aVTBCapture.Checked  := False;
    aVTBSystem.Checked   := False;
  end;
}
  N_CM_MainForm.CMMFChangeToolBarsVisibility();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aVTBAllTopToolbarsExecute


//************************************* TN_CMResForm.aVTBCustToolBarExecute ***
// Customize Tools bar
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aVTBCustToolBar Action handler
//
procedure TN_CMResForm.aVTBCustToolBarExecute(Sender: TObject);
var
  UseGlobals : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
//UseGlobals := K_CMGAModeFlag and K_CMUseCustToolbarGlobal;
  UseGlobals := K_CMGAModeFlag and
                ((K_CMUseCustToolbarInd = 1) or (K_CMUseCustToolbarInd = 2));

  if UseGlobals then
  begin
    if K_CMUseCustToolbarInd = 2 then
      K_CMEDAccess.EDANotGAGlobalToCurState() // Get Last Global Flags
    else
      K_CMEDAccess.EDALocationToCurState(); // Get Global ToolBar Info
  end;

  if K_CMCustomizeToolbarDlg( K_CMUseCustToolbarInd ) then
  begin // CustomizeToolbarDlg returns TRUE
    N_CM_MainForm.CMMCurUpdateCustToolBar();
    if UseGlobals then
    begin
      if K_CMUseCustToolbarInd = 1 then
      begin // Save ToolBar Info to Location Context
        N_CM_MainForm.CMMUpdateUIByCTA();
        K_CMEDAccess.EDALocationToMemIni1();
      end
      else // Save ToolBar Info to Global Context
        K_CMEDAccess.EDANotGAGlobalToMemIni1();
    end; // if UseGlobals then

  end
  else
  if UseGlobals then
  begin // CustomizeToolbarDlg returns FALSE
    // Apply new Location MemIni Context to Interface
    // because new New Context was Load
    N_CM_MainForm.CMMUpdateUIByCTA();
    N_CM_MainForm.CMMCurUpdateCustToolBar();
  end; // if UseGlobals then

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServCustToolBarExecute

    //********* Capture Actions

//************************************ TN_CMResForm.aCapCaptDevSetupExecute ***
// Show "Capture Device Setup" form
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCapCaptDevSetup Action handler
//
procedure TN_CMResForm.aCapCaptDevSetupExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMDemoModeFlag   or
     K_CMDeviceSetupConfirmDlg( ) then
  begin
    with K_CMEDAccess do
        EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                               Ord(K_shNCACapDevSetup) ) );
    with TK_FormDeviceSetup.Create( Application ) do
    begin
//      BaseFormInit( nil, '', [fvfCenter] );
      BFIniSize := Point( 400, 300 );
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      ShowModal;
    end;
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aCapCaptDevSetupExecute

//********************************** TN_CMResForm.aCapFootPedalSetupExecute ***
// Show "Foot Pedal Setup" form
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCapFootPedalSetup Action handler
//
procedure TN_CMResForm.aCapFootPedalSetupExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  N_CMSetFootPedal();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aCapFootPedalSetupExecute

//************************************** TN_CMResForm.aCapClientScanExecute ***
// Capture by client capture software CMScan
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aCapClientScan Action handler
//
procedure TN_CMResForm.aCapClientScanExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_FCMClientScanDlg();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aCapClientScanExecute

    //********* Tools Actions

//************************************ TN_CMResForm.aToolsRotateLeftExecute ***
// Rotate Image in Active Editor Frame to the Left
//
//     Parameters
// Sender - Event Sender
//
// Rotate Image in Active Editor Frame by 90 degree CounterClockWise
//
// OnExecute MainActions.aToolsRotateLeft Action handler
//
procedure TN_CMResForm.aToolsRotateLeftExecute( Sender: TObject );
var
  RFlags : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting( ) then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

{
    with CMMFActiveEdFrame, EdSlide.GetPMapRootAttrs^ do begin
      with EdSlide.GetMapImage.DIBObj, DIBInfo.bmi do begin
        FlipAndRotate( N_RotateFRFlags( 0, 90 ) );
        AffConvVObjs( cmrfvcRotateLeft );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags ( MRFlipRotateAttrs, 90 );
    end;
}
    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 1, 0 ) then Exit;

    with CMMFActiveEdFrame, EdSlide, GetPMapRootAttrs^ do
    begin
      with GetMapImage.DIBObj do
      begin
        RFlags := N_RotateFRFlags( 0, 90 );
        FlipAndRotate( RFlags );
        AffConvVObjects( RFlags, RFrame.RFVectorScale );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags ( MRFlipRotateAttrs, 90 );
      N_Dump2Str( format( '!!>> Slide ID=%s FlipRotate=%d', [ObjName,MRFlipRotateAttrs] ) );
    end;

    CMMFFinishImageEditing( aToolsRotateLeft.Caption, [cmssfMapRootChanged],
         K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActRotateLeft) ) );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsRotateLeftExecute

//*********************************** TN_CMResForm.aToolsRotateRightExecute ***
// Rotate Image in Active Editor Frame to the Right
//
//     Parameters
// Sender - Event Sender
//
// Rotate Image in Active Editor Frame by 90 degree ClockWise
//
// OnExecute MainActions.aToolsRotateRight Action handler
//
procedure TN_CMResForm.aToolsRotateRightExecute( Sender: TObject );
var
  RFlags : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
{
    with CMMFActiveEdFrame, EdSlide.GetPMapRootAttrs^ do begin
      with EdSlide.GetMapImage.DIBObj, DIBInfo.bmi do begin
        FlipAndRotate( N_RotateFRFlags( 0, -90 ) );
        AffConvVObjs( cmrfvcRotateRight );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags ( MRFlipRotateAttrs, -90 );
    end;
}
    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 1, 0 ) then Exit;

    with CMMFActiveEdFrame, EdSlide, GetPMapRootAttrs^ do
    begin
      with GetMapImage.DIBObj do
      begin
        RFlags := N_RotateFRFlags( 0, -90 );
        FlipAndRotate( RFlags );
        AffConvVObjects( RFlags, RFrame.RFVectorScale );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags ( MRFlipRotateAttrs, -90 );
      N_Dump2Str( format( '!!>> Slide ID=%s FlipRotate=%d', [ObjName,MRFlipRotateAttrs] ) );
    end;

    CMMFFinishImageEditing( aToolsRotateRight.Caption, [cmssfMapRootChanged],
         K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActRotateRight) ) );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsRotateRightExecute

//************************************* TN_CMResForm.aToolsRotate180Execute ***
// Rotate Image in Active Editor Frame by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsRotate180 Action handler
//
procedure TN_CMResForm.aToolsRotate180Execute( Sender: TObject );
var
  RFlags : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
{
    with CMMFActiveEdFrame, EdSlide.GetPMapRootAttrs^ do begin
      with EdSlide.GetMapImage.DIBObj, DIBInfo.bmi do begin
        FlipAndRotate( N_RotateFRFlags( 0, 180 ) );
        AffConvVObjs( cmrfvcRotate180 );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags( MRFlipRotateAttrs, 180 );
    end;
}
    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 1, 0 ) then Exit;

    with CMMFActiveEdFrame, EdSlide, GetPMapRootAttrs^ do
    begin
      with GetMapImage.DIBObj do
      begin
        RFlags := N_RotateFRFlags( 0, 180 );
        FlipAndRotate( RFlags );
        AffConvVObjects( RFlags, RFrame.RFVectorScale );
      end;
      MRFlipRotateAttrs := N_RotateFRFlags ( MRFlipRotateAttrs, 180 );
      N_Dump2Str( format( '!!>> Slide ID=%s FlipRotate=%d', [ObjName,MRFlipRotateAttrs] ) );
    end;

    CMMFFinishImageEditing( aToolsRotate180.Caption, [cmssfMapRootChanged],
         K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActRotate180) ) );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsRotate180Execute

//****************************** TN_CMResForm.aToolsFlipHorizontallyExecute ***
// Flip Image in Active Editor Frame Horizontally
//
//     Parameters
// Sender - Event Sender
//
// Flip Image in Active Editor Frame relative to Vertical Axis
//
// OnExecute MainActions.aToolsFlipHorizontally Action handler
//
procedure TN_CMResForm.aToolsFlipHorizontallyExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
{
    with CMMFActiveEdFrame, EdSlide.GetPMapRootAttrs^ do begin
      with EdSlide.GetMapImage.DIBObj, DIBInfo.bmi do begin
        FlipAndRotate( N_FlipHorBit );
        AffConvVObjs( cmrfvcFlipHor );
      end;
      MRFlipRotateAttrs := MRFlipRotateAttrs xor N_FlipHorBit;
    end;
}
    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 1, 0 ) then Exit;

    with CMMFActiveEdFrame, EdSlide, GetPMapRootAttrs^ do begin
      with GetMapImage.DIBObj do begin
        FlipAndRotate( N_FlipHorBit );
        AffConvVObjects( N_FlipHorBit, RFrame.RFVectorScale );
      end;
      MRFlipRotateAttrs := MRFlipRotateAttrs xor N_FlipHorBit;
      N_Dump2Str( format( '!!>> Slide ID=%s FlipRotate=%d', [ObjName,MRFlipRotateAttrs] ) );
    end;

    CMMFFinishImageEditing( aToolsFlipHorizontally.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActFlipHor) ) );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsFlipHorizontallyExecute

//******************************** TN_CMResForm.aToolsFlipVerticallyExecute ***
// Flip Image in Active Editor Frame Vertically
//
//     Parameters
// Sender - Event Sender
//
// Flip Image in Active Editor Frame relative to Horizontal Axis
//
// OnExecute MainActions.aToolsFlipVertically Action handler
//
procedure TN_CMResForm.aToolsFlipVerticallyExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
{
    with CMMFActiveEdFrame, EdSlide.GetPMapRootAttrs^ do begin
      with EdSlide.GetMapImage.DIBObj, DIBInfo.bmi do begin
        FlipAndRotate( N_FlipVertBit );
        AffConvVObjs( cmrfvcFlipVert );
      end;
      MRFlipRotateAttrs := MRFlipRotateAttrs xor N_FlipVertBit;
    end;
}
    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 1, 0 ) then Exit;

    with CMMFActiveEdFrame, EdSlide, GetPMapRootAttrs^ do begin
      with GetMapImage.DIBObj do begin
        FlipAndRotate( N_FlipVertBit );
        AffConvVObjects( N_FlipVertBit, RFrame.RFVectorScale );
      end;
      MRFlipRotateAttrs := MRFlipRotateAttrs xor N_FlipVertBit;
      N_Dump2Str( format( '!!>> Slide ID=%s FlipRotate=%d', [ObjName,MRFlipRotateAttrs] ) );
    end;

    CMMFFinishImageEditing( aToolsFlipVertically.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActFlipVert) ) );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsFlipVerticallyExecute

//************************************** TN_CMResForm.aToolsBriCoGamExecute ***
// Adjust Image in Active Editor Frame (with two Preview Frames)
//
//     Parameters
// Sender - Event Sender
//
// Adjust Brightness, Contrast and Gamma of Image in Active Editor Frame
//
// OnExecute MainActions.aToolsBriCoGam Action handler
//
procedure TN_CMResForm.aToolsBriCoGamExecute( Sender: TObject );
var
  DlgResultFlag : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
{
    if K_CMSNF_BriCoGamDialogMode then
      DlgResultFlag := K_CMSBriCoGam1Dlg( )
    else
      DlgResultFlag := K_CMSBriCoGamDlg( );
}

    DlgResultFlag := K_CMSBriCoGam1Dlg( );
    if DlgResultFlag then // Image was Changed
      CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActBriCoGam) ) )
    else
      CMMFCancelImageEditing();
{
    if K_CMSBriCoGamDlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsBriCoGam.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActBriCoGam) ) )
    else
      CMMFCancelImageEditing();
}
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsBriCoGamExecute

//************************************* TN_CMResForm.aToolsBriCoGam1Execute ***
// Adjust Image in Active Editor Frame (without Preview Frames)
//
//     Parameters
// Sender - Event Sender
//
// Adjust Brightness, Contrast and Gamma of Image in Active Editor Frame
//
// OnExecute MainActions.aToolsBriCoGam1 Action handler
//
procedure TN_CMResForm.aToolsBriCoGam1Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSBriCoGam1Dlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsBriCoGam1.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActBriCoGam) ) )
    else
      CMMFCancelImageEditing();

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsBriCoGam1Execute

//**************************************** TN_CMResForm.aToolsNegateExecute ***
// Negate Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// Negate Image in Active Editor Frame
//
// OnExecute MainActions.aToolsNegate Action handler
//
procedure TN_CMResForm.aToolsNegateExecute(Sender: TObject);
var
  PrevDIB : TN_DIBObj;
  ImgViewConvData : TK_CMSImgViewConvData;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    with CMMFActiveEdFrame.EdSlide, P()^.CMSDB,
         GetCurrentImage(),
         GetPMapRootAttrs()^ do
    begin

      if (SFlags * [cmsfShowColorize,cmsfShowIsodensity,cmsfShowEmboss]) <> [] then
      begin
      // Clear Show Modes
        SFlags := SFlags - [cmsfShowColorize,cmsfShowIsodensity,cmsfShowEmboss];
        RebuildMapImageByDIB();
        K_FormCMSIsodensity.InitIsodensityMode();
      end;

      // Negate Map Image
      GetMapImage.DIBObj.XORPixels( $00FFFFFF );

      // Apply BriCoGam Attrs to Current Image
      PrevDIB := DIBObj;
      DIBObj := nil;
      FillChar( ImgViewConvData, SizeOf(TK_CMSImgViewConvData), 0 );
      GetImgViewConvData( @ImgViewConvData, [vcifBriCoGam] );
      K_CMConvDIBBySlideViewConvData( DIBObj, PrevDIB,
                        @ImgViewConvData, PrevDIB.DIBPixFmt, PrevDIB.DIBExPixFmt );
      PrevDIB.Free;

      // Negate Current Image
      DIBObj.XORPixels( $00FFFFFF );

      // Clear BriCoGam Attrs
      MRCoFactor := 0;
      MRGamFactor:= 0;
      MRBriFactor:= 0;
    end;

//    CMMFActiveEdFrame.EdSlide.GetCurrentImage().DIBObj.XORPixels( $00FFFFFF );
    CMMFFinishImageEditing( aToolsNegate.Caption, [cmssfCurImgChanged, cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActNegate) ) );
    CMMFDisableActions( Sender );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNegateExecute

//**************************************** TN_CMResForm.aToolsNegate1Execute ***
// Negate Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// Negate Image in Active Editor Frame
//
// OnExecute MainActions.aToolsNegate1 Action handler
//
procedure TN_CMResForm.aToolsNegate1Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if aToolsEmboss.Checked and
       not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    with CMMFActiveEdFrame.EdSlide, {P()^.CMSDB,}
//         GetCurrentImage(),
         GetPMapRootAttrs()^ do
    begin
      if K_smriNegateImg in MRImgFlags then
      begin
        MRImgFlags := MRImgFlags - [K_smriNegateImg];
        MRBriFactor := - MRBriFactor;
      end
      else
      begin
        MRImgFlags := MRImgFlags + [K_smriNegateImg];
        MRBriFactor := - MRBriFactor;
      end;

      RebuildMapImageByDIB();
    end;

//    CMMFActiveEdFrame.EdSlide.GetCurrentImage().DIBObj.XORPixels( $00FFFFFF );
    CMMFFinishImageEditing( aToolsNegate1.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActNegate) ) );
    CMMFShowHideWaitState( FALSE );
    CMMFDisableActions( Sender );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNegate1Execute

//**************************************** TN_CMResForm.aToolsNegate11Execute ***
// Negate Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// Negate Image in Active Editor Frame
//
// OnExecute MainActions.aToolsNegate11 Action handler
//
procedure TN_CMResForm.aToolsNegate11Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if aToolsEmboss.Checked and
       not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    with CMMFActiveEdFrame.EdSlide, {P()^.CMSDB,
         GetCurrentImage(), }
         GetPMapRootAttrs()^ do
    begin
      if K_smriNegateImg in MRImgFlags then
      begin
        MRImgFlags := MRImgFlags - [K_smriNegateImg];
        MRBriFactor := - MRBriFactor;
      end
      else
      begin
        MRImgFlags := MRImgFlags + [K_smriNegateImg];
        MRBriFactor := - MRBriFactor;
      end;

      RebuildMapImageByDIB();
    end;

//    CMMFActiveEdFrame.EdSlide.GetCurrentImage().DIBObj.XORPixels( $00FFFFFF );
    CMMFFinishImageEditing( aToolsNegate11.Caption, [cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActNegate) ) );
    CMMFDisableActions( Sender );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNegate11Execute

//*************************************** TN_CMResForm.aToolsSharpenExecute ***
// Sharpen or Smoothen Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpen Action handler
//
procedure TN_CMResForm.aToolsSharpenExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSSharpenDlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsSharpen.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpenExecute

//*************************************** TN_CMResForm.aToolsSharpenNExecute ***
// Fast Sharpen or Smoothen Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpenN Action handler
//
procedure TN_CMResForm.aToolsSharpenNExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSSharpenNDlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsSharpen.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpenNExecute

//************************************** TN_CMResForm.aToolsSharpen1Execute ***
// Sharpen or Smoothen Image in Active Editor Frame Test
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpen1 Action handler
//
procedure TN_CMResForm.aToolsSharpen1Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() or
       not K_CMSNF_SharpenTestMode then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSSharpen1Dlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsSharpen1.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpen1Execute

//************************************** TN_CMResForm.aToolsSharpen2Execute ***
// Sharpen or Smoothen Image by Fast Smooth procedure in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpen2 Action handler
//
procedure TN_CMResForm.aToolsSharpen2Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSSharpen11Dlg( N_ConvDIBToArrAverageFast1 ) then // Image was Changed
      CMMFFinishImageEditing( aToolsSharpen2.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpen2Execute

//************************************** TN_CMResForm.aToolsSharpen2Execute ***
// Sharpen or Smoothen Image by Median Smooth procedure in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpen2 Action handler
//
procedure TN_CMResForm.aToolsSharpen3Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if K_CMSSharpen11Dlg( N_ConvDIBToArrMedianHuang ) then // Image was Changed
      CMMFFinishImageEditing( aToolsSharpen3.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpen3Execute

//*************************************** TN_CMResForm.aToolsSharpen12Execute ***
// Fast Sharpen or Smoothen Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsSharpenN Action handler
//
procedure TN_CMResForm.aToolsSharpen12Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    // Disable CMS UI
    CMMSetUIEnabled( FALSE );
    N_AppSkipEvents := TRUE; // needed TRUE to not skeep events in Rast1Frame
{
    Include( CMMUICurStateFlags, uicsAllActsDisabled);
    CMMFDisableActions( Self );
//    N_AppSkipEvents := TRUE;
    Inc(K_CMD4WWaitApplyDataCount);
}

    with TK_FormCMSSharpAttrs12.Create(Application) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

      Show();
    end;
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsSharpen12Execute

//************************************** TN_CMResForm.aToolsImgSharpExecute ***
// Sharpen Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsImgSharp Action handler
//
procedure TN_CMResForm.aToolsImgSharpExecute(Sender: TObject);
var
  NDIBs : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting()then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    NDIBs := 1;
    if aToolsEmboss.Checked then
      NDIBs := 2;
    if not CheckSlideMemBeforeAction( Sender, 1, NDIBs ) then Exit;

    if K_CMSSharpSmoothDlg( TRUE ) then // Image was Changed
    begin
      CMMFShowHideWaitState( TRUE );

      CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSharpen) ) );
      CMMFShowHideWaitState( FALSE );
    end
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aToolsImgSharpExecute

//************************************** TN_CMResForm.aToolsImgSmoothExecute ***
// Smoothen Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsImgSmooth Action handler
//
procedure TN_CMResForm.aToolsImgSmoothExecute(Sender: TObject);
var
  NDIBs : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting()then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    NDIBs := 1;
    if aToolsEmboss.Checked then
      NDIBs := 2;
    if not CheckSlideMemBeforeAction( Sender, 1, NDIBs ) then Exit;

    if K_CMSSharpSmoothDlg( FALSE ) then // Image was Changed
    begin
      CMMFShowHideWaitState( TRUE );
      CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActSmoothen) ) );
      CMMFShowHideWaitState( FALSE );
    end
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aToolsImgSmoothExecute


//***************************************** TN_CMResForm.aToolsNoiseSelfExecute ***
// Reduce Image Noise by Self Algorithm in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Reduce Image Noise by Self Algorithm in Active Editor Frame
//
// OnExecute MainActions.aToolsNoiseSelf Action handler
//
procedure TN_CMResForm.aToolsNoiseSelfExecute(Sender: TObject);
var
  NewDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 2, 1 ) then Exit;

    // Initialize Values

    NewDIB := nil;
    DIBObj.CalcDeNoise1DIB( NewDIB, 5, 2.0/sqrt(2), 1.1, 1.1 );
    DIBObj.Free;
    DIBObj := NewDIB;
    RebuildMapImageByDIB( DIBObj );

    CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActNoise) ) );
    CMMFShowHideWaitState( FALSE );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNoiseSelfExecute

//***************************************** TN_CMResForm.aToolsMedianExecute ***
// Reduce Image Noise by Median in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Reduce Image Noise by Median in Active Editor Frame
//
// OnExecute MainActions.aToolsMedian Action handler
//
procedure TN_CMResForm.aToolsMedianExecute(Sender: TObject);
var
  NewDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    // Initialize Values

    NewDIB := nil;
    DIBObj.CalcDeNoise3DIB( NewDIB, 5 );
    DIBObj.Free;
    DIBObj := NewDIB;
    RebuildMapImageByDIB( DIBObj );

    CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActMedian) ) );
    CMMFShowHideWaitState( FALSE );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsMedianExecute

//***************************************** TN_CMResForm.aToolsDespeckleExecute ***
// Reduce Image Noise by Despeckle in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Reduce Image Noise by Despeckle in Active Editor Frame
//
// OnExecute MainActions.aToolsDespeckle Action handler
//
procedure TN_CMResForm.aToolsDespeckleExecute(Sender: TObject);
var
  NewDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    // Initialize Values

    NewDIB := nil;
    DIBObj.CalcDeNoise2DIB( NewDIB, 5, 0.4 );
    DIBObj.Free;
    DIBObj := NewDIB;
    RebuildMapImageByDIB( DIBObj );

    CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActDespeckle) ) );
    CMMFShowHideWaitState( FALSE );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsDespeckleExecute

//************************************ TN_CMResForm.aToolsNoiseAttrsExecute ***
// Reduce Image Noise in Active Editor Frame (with Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Reduce Image Noise in Active Editor Frame (enhanced)
//
// OnExecute MainActions.aToolsNoiseAttrs Action handler
//
procedure TN_CMResForm.aToolsNoiseAttrsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() or
       not K_CMSNF_NoiseTestMode then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

   // Paste Reduce Image Noise Code here ...
    if K_CMSNoiseRedDlg( ) then // Image was Changed
      CMMFFinishImageEditing( aToolsNoiseSelf.Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActNoise) ) )
    else
    begin
      CMMFCancelImageEditing();
      CMMFRefreshActiveEdFrameHistogram( );
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNoiseAttrsExecute

//************************************ TN_CMResForm.aToolsNoiseAttrs1Execute ***
// Reduce Image Noise in Active Editor Frame (with Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Reduce Image Noise in Active Editor Frame (enhanced)
//
// OnExecute MainActions.aToolsNoiseAttrs1 Action handler
//
procedure TN_CMResForm.aToolsNoiseAttrs1Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() or
       not K_CMSNF_NoiseTestMode then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

   // Paste Reduce Image Noise Code here ...

    // Disable CMS UI
    N_CM_MainForm.CMMSetUIEnabled( FALSE );
    N_AppSkipEvents := TRUE; // needed to not skip events in Rast1Frame
{
    Include( CMMUICurStateFlags, uicsAllActsDisabled);
    CMMFDisableActions( Self );
    Inc(K_CMD4WWaitApplyDataCount);
//    N_AppSkipEvents := TRUE;
}
    with TK_FormCMSNoiseRAttrs1.Create(Application) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

      FinishImageEditingCaption := aToolsNoiseAttrs1.Caption;
      Show();
    end;

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsNoiseAttrs1Execute

//**************************************** TN_CMResForm.aToolsEmbossExecute ***
// Emboss Image in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsEmboss Action handler
//
procedure TN_CMResForm.aToolsEmbossExecute( Sender: TObject );
begin
//  N_WarnByMessage( 'Under reconstraction' );
//  Exit;

  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if aToolsEmboss.Checked and
       not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    with CMMFActiveEdFrame.EdSlide, P()^ do
    begin
      if aToolsEmboss.Checked then
      begin
        if aToolsIsodens.Checked then
        begin
        // Toggle Isodensity Mode
          aToolsIsodens.Checked := FALSE;
          aToolsIsodensExecute( Sender );
        end;
        Include( CMSDB.SFlags, cmsfShowEmboss );
      end
      else
      begin
        Exclude( CMSDB.SFlags, cmsfShowEmboss );
      end;
      // Rebuild MapImage By View Attributes
      RebuildMapImageByDIB();
      CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//      CMMFRebuildActiveView( [rvfAllViewRebuild] );
      CMMFDisableActions( Sender );
      CMMFShowHideWaitState( FALSE );

      if aToolsEmboss.Checked      and
         aToolsEmbossAttrs.Visible and
         (Sender <> aToolsEmbossAttrs) then
           aToolsEmbossAttrsExecute(Sender );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsEmbossExecute

//*********************************** TN_CMResForm.aToolsEmbossAttrsExecute ***
// Emboss Image in Active Editor Frame (with Dialog)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsEmboss Action handler
//
procedure TN_CMResForm.aToolsEmbossAttrsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not aToolsEmboss.Checked then begin
      aToolsEmboss.Checked := true;
      aToolsEmbossExecute( Sender );
    end;

    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    if K_CMSEmbossDlg( ) then
      with CMMFActiveEdFrame.EdSlide, P^ do begin
        RebuildMapImageByDIB();
        CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//        CMMFRebuildActiveView( [rvfAllViewRebuild] );
      end;

    CMMFShowStringByTimer( K_CML1Form.LLLTools1.Caption
//                  'Set Image Emboss'
                          );

  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsEmbossAttrsExecute

//*************************************** TN_CMResForm.aToolsIsodensExecute ***
// Colorize Image by Isodensity Filter in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsIsodens Action handler
//
procedure TN_CMResForm.aToolsIsodensExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;

      if Sender is TAction then
        N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    with CMMFActiveEdFrame.EdSlide, P()^ do begin
      if aToolsIsodens.Checked then
      begin
        if aToolsEmboss.Checked then
        begin
        // Toggle Emboss Mode
          aToolsEmboss.Checked := FALSE;
          aToolsEmbossExecute( Sender );
        end;
        if aToolsFlashLightMode.Checked then
        begin
          aToolsFlashLightMode.Checked := FALSE;
          aToolsFlashLightModeExecute( Sender );
        end;

        Include( CMSDB.SFlags, cmsfShowIsodensity );
        if Sender <> nil then
          aToolsIsodensAttrsExecute( Sender );
      end
      else
      begin
        Exclude( CMSDB.SFlags, cmsfShowIsodensity );
        K_FormCMSIsodensity.InitIsodensityMode();
      end;
      CMMFRefreshActiveEdFrameHistogram( );
      // Rebuild MapImage By View Attributes
      RebuildMapImageByDIB();
      CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//      CMMFRebuildActiveView( [rvfAllViewRebuild] );
      CMMFDisableActions( Sender );
    end;

//    CMMFFinishImageEditing( 'Isodensity Image', [cmssfMapRootChanged] );
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsIsodensExecute

//********************************** TN_CMResForm.aToolsIsodensAttrsExecute ***
// Show Edit Isodensity Filter Attributes
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsIsodensAttrs Action handler
//
procedure TN_CMResForm.aToolsIsodensAttrsExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

//    CMMFActiveEdFrame.PopupMenu := EdFrPointPopupMenu;
    CMMFActiveEdFrame.PopupMenu := CMMEdFramePopUpMenu;
//    N_SetMouseCursorType( CMMFActiveEdFrame.RFrame, crDefault );

    if K_FormCMSIsodensity = nil then
    begin
      with TK_FormCMSIsodensity.Create(Application) do
      begin
//        BaseFormInit( N_CM_MainForm.CMMCurFMainForm );
        BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

        if not aToolsIsodens.Checked then
        begin
          aToolsIsodens.Checked := true;
//          aToolsIsodensExecute( Sender );
        end;
        Show();
      end
    end else
      with K_FormCMSIsodensity do begin
        if Visible and Enabled then
          SetFocus();
      end;

//    CMMEdVEMode := cmrfemIsodensity;
    CMMFShowStringByTimer( K_CML1Form.LLLTools2.Caption
//             'Set Image Isodensity'
                         );

  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsIsodensAttrsExecute

//************************************** TN_CMResForm.aToolsColorizeExecute ***
// Colorize Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsColorize Action handler
//
procedure TN_CMResForm.aToolsColorizeExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    with CMMFActiveEdFrame.EdSlide, P()^ do
    begin
      if aToolsColorize.Checked then
      begin
        CMSDB.ViewAttrs.ColPalInd := K_CMColorizePalIndex;
        Include( CMSDB.SFlags, cmsfShowColorize )
      end
      else
        Exclude( CMSDB.SFlags, cmsfShowColorize );
      // Rebuild MapImage By View Attributes
      RebuildMapImageByDIB();
      CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//      CMMFRebuildActiveView( [rvfAllViewRebuild] );
    end;
    CMMFShowHideWaitState( FALSE );

//    CMMFFinishImageEditing( 'Colorize Image', [cmssfMapRootChanged] );
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsColorizeExecute

{
//************************************ TN_CMResForm.aToolsHistogrammExecute ***
// Show modal window with Histogramm of Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsHistogramm Action handler
//
procedure TN_CMResForm.aToolsHistogrammExecute( Sender: TObject );
begin
var
  BHistForm: TN_BrighHistForm;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting( ) then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    // in not modal mode BHistForm should be global!
    BHistForm := nil;
    N_CreateBrighHistForm( CMMFActiveEdFrame.EdSlide.GetMapImage.DIBObj,
                                         @BHistForm, K_CML1Form.LLLHist1.Caption, // 'Histogram',
                                         nil );
    BHistForm.Hide; // just to enable ShowModal
    BHistForm.ShowModal;
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsHistogrammExecute
}

//*********************************** TN_CMResForm.aToolsHistogramm2Execute ***
// Show modal window with Histogramm of Image in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsHistogramm Action handler
//
procedure TN_CMResForm.aToolsHistogramm2Execute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    N_CreateBrigHist2Form( @N_BrigHist2Form,
                           K_CML1Form.LLLHist1.Caption,
//                           'Histogram',
                           nil );
    CMMFSetActiveEdFrame( CMMFActiveEdFrame );
    N_BrigHist2Form.Show(); // should be called after CMMFRefreshActiveEdFrameHistogram in CMMFSetActiveEdFrame
    N_BrigHist2Form.Refresh();
//    N_BrigHist2Form.Show();    // is needed for correct working of Realign()
//    N_BrigHist2Form.Realign(); // is needed for correct RFrame.Width, RFrame.Height
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsHistogramm2Execute

//******************************** TN_CMResForm.aToolsRotateByAngleExecute ***
// Rotate Active Frame Slide by any angle
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsRotateByAngle Action handler
//
procedure TN_CMResForm.aToolsRotateByAngleExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not CheckSlideMemBeforeAction( Sender, 0, 3 ) then Exit;

    with CMMFActiveEdFrame do
    begin
//      CMMFShowStringByTimer( 'Action is not implemented' );

      // Show Rotate Dialog
      ChangeSelectedVObj( 0 );
      EdViewEditMode := cmrfemNone;
      if K_CMSRotateDlg( ) then begin
//        with K_FormCMSRotateByAngle do
//          AffConvVObjs6( ResUCAffCoefs6, ResultingAngle );
        CMMFFinishImageEditing( TAction(Sender).Caption,
//                              'Image is rotated by degree',
                                [cmssfCurImgChanged, cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActRotateByAngle) ) );
        CMMFDisableActions( nil );
      end else
        CMMFCancelImageEditing();

      aEditPointExecute( nil );

    end; // with N_CM_MainForm do
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsRotateByAngleExecute

//********************************** TN_CMResForm.aToolsAutoEqualizeExecute ***
// Auto Equalize Active Frame Slide pixels
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsAutoEqualize Action handler
//
procedure TN_CMResForm.aToolsAutoEqualizeExecute( Sender: TObject );
var
  NDIB : TN_DIBObj;
  PCMSlide : TN_PCMSlide;
//  ImgViewConvData : TK_CMSImgViewConvData;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end; // if not CMMFCheckBSlideExisting() then
 
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;
 
    with CMMFActiveEdFrame do
    begin
//      CMMFShowStringByTimer( 'Action is not implemented' );
 
      // Rebuild Current Image
      with EdSlide, GetCurrentImage() do
      begin
        //***** DIBObj should be modifies, NDIB is used (if needed) as temporary obj

//        NDIB := nil; // old variant
//        DIBObj.CalcEqualizedDIB( NDIB, 30, 3.0 );
//        DIBObj.Free;
//        DIBObj := NDIB;

//        N_CMDIBAdjustByIntPar( DIBObj, 2 ); // for debug only
//        N_CMDIBAdjustAutoAll( DIBObj, 0.8 ); // for debug only (0.3 0.55 0.8)

        NDIB := nil;

        DIBObj.CalcMaxContrastDIB( NDIB );
        FreeAndNil( DIBObj );

        NDIB.CalcEqualizedDIB( DIBObj, 30, 3.0 ); // OKvar
//        NDIB.CalcEqualizedDIB( DIBObj, 30, 0.1*StrToInt(N_ReadTextFile('aatst1.txt')) ); // debug

        FreeAndNil( NDIB );

        PCMSlide := P();
        with PCMSlide^ do
          if CMSDB.PixBits <> DIBObj.DIBNumBits then
            K_CMSlideSetAttrsByDIB( PCMSlide, DIBObj, FALSE );
 
        // Clear Flip/Rotate in Map Attributes
        with GetPMapRootAttrs()^ do
        begin
          MRCoFactor  := 0;
          MRGamFactor := 0;
          MRBriFactor := 0;
        end;
        // Rebuild Map Image by new Current Image
        RebuildMapImageByDIB( );
      end; // with EdSlide, GetCurrentImage(), DIBObj do
 

  // Save Image changes
 
      CMMFFinishImageEditing( TAction(Sender).Caption,
//                            'Image is equalized',
                              [cmssfCurImgChanged, cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActAutoEqualize) ) );
      CMMFDisableActions( nil );
    end; // with CMMFActiveEdFrame do
 
    CMMFShowStringByTimer( K_CML1Form.LLLTools3.Caption
//            'Image autoequalized OK'
                          );
  end; // with N_CM_MainForm do
 
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsAutoEqualizeExecute
{
//********************************** TN_CMResForm.aToolsAutoEqualizeExecute ***
// Auto Equalize Active Frame Slide pixels
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsAutoEqualize Action handler
//
procedure TN_CMResForm.aToolsAutoEqualizeExecute( Sender: TObject );
var
  NDIB : TN_DIBObj;
  PCMSlide : TN_PCMSlide;
//  ImgViewConvData : TK_CMSImgViewConvData;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end; // if not CMMFCheckBSlideExisting() then

    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    with CMMFActiveEdFrame do
    begin
//      CMMFShowStringByTimer( 'Action is not implemented' );

      // Rebuild Current Image
      with EdSlide, GetCurrentImage() do
      begin
        NDIB := nil;
        DIBObj.CalcEqualizedDIB( NDIB, 30, 3.0 );
        DIBObj.Free;
        DIBObj := NDIB;
        PCMSlide := P();
        with PCMSlide^ do
          if CMSDB.PixBits <> NDIB.DIBNumBits then
            K_CMSlideSetAttrsByDIB( PCMSlide, NDIB, FALSE );

        // Clear Flip/Rotate in Map Attributes
        with GetPMapRootAttrs()^ do
        begin
          MRCoFactor  := 0;
          MRGamFactor := 0;
          MRBriFactor := 0;
        end;
        // Rebuild Map Image by new Current Image
        RebuildMapImageByDIB( );
      end; // with EdSlide, GetCurrentImage(), DIBObj do


  // Save Image changes

      CMMFFinishImageEditing( TAction(Sender).Caption,
//                            'Image is equalized',
                              [cmssfCurImgChanged, cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActAutoEqualize) ) );
      CMMFDisableActions( nil );
    end; // with CMMFActiveEdFrame do

    CMMFShowStringByTimer( K_CML1Form.LLLTools3.Caption
//            'Image autoequalized OK'
                          );
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsAutoEqualizeExecute
}
//************************************* TN_CMResForm.aToolsCropImageExecute ***
// Crop Active Frame Slide Image
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsCropImage Action handler
//
procedure TN_CMResForm.aToolsCropImageExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    ChangeSelectedVObj( 0 );
    ShowWholeImage( );
    CMMSetFramesMode( cmrfemCropImage, CMMFActiveEdFrame );
    K_FormCMSIsodensity.SelfClose();
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsCropImageExecute

//************************************ TN_CMResForm.aToolsUFilterImgExecute ***
// Apply user filter to Active Frame Slide Image
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsUFilterImg Action handler
//
procedure TN_CMResForm.aToolsUFilterImgExecute( Sender: TObject );
var
  CMSlideSaveStateFlags : TK_CMSlideSaveStateFlags;
  Ind : Integer;
//  VObjsConvFlags : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not CheckSlideMemBeforeAction( Sender, 0, 2 ) then Exit;

    CMMFShowHideWaitState( TRUE );

  // Filterd Slide Image
    if Sender is TAction then
      Ind := TComponent(Sender).Tag // this case is really works
    else
      Ind := TMenuItem(Sender).Action.Tag;

    N_CM_MainForm.CMMFShowString( K_CML1Form.LLLTools4.Caption
//      ' Image is processing by custom filter. Please wait ...'
                                 );
    CMSlideSaveStateFlags := K_CMSlideConvByAutoImgProcAttrs( EdSlide,
            @TK_PCMUFilterProfile(K_CMEDAccess.UFiltersProfiles.PDE(Ind)).CMUFPAutoImgProcAttrs,
            RFrame.RFVectorScale );
    if CMSlideSaveStateFlags <> [] then
      CMMFFinishImageEditing( format( K_CML1Form.LLLTools5.Caption,
//         'Image is processed by custom filter %d',
         [Ind + 1]), CMSlideSaveStateFlags,
           K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                            Ord(K_shImgActUFilter) ) )
    else
      N_CM_MainForm.CMMFShowString( '' );

    CMMFDisableActions( nil );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsUFilterImgExecute

//************************************ TN_CMResForm.aToolsGFilterImgExecute ***
// Apply global filter to Active Frame Slide Image
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsGFilterImg Action handler
//
procedure TN_CMResForm.aToolsGFilterImgExecute(Sender: TObject);
var
  CMSlideSaveStateFlags : TK_CMSlideSaveStateFlags;
  Ind : Integer;
//  VObjsConvFlags : Integer;
const
  FilterNames = 'ABCDEF';
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not CheckSlideMemBeforeAction( Sender, 0, 2 ) then Exit;

    CMMFShowHideWaitState( TRUE );

    if Sender is TAction then
      Ind := TComponent(Sender).Tag // this case is really works
    else
    if Sender is TMenuItem then
      Ind := TMenuItem(Sender).Action.Tag
    else
      Ind := TControl(Sender).Action.Tag;

  // Filter Slide Image
    N_CM_MainForm.CMMFShowString( K_CML1Form.LLLTools6.Caption
//       ' Image is processing by global filter. Please wait ...'
                                );
    CMSlideSaveStateFlags := K_CMSlideConvByAutoImgProcAttrs( EdSlide,
            @TK_PCMUFilterProfile(K_CMEDAccess.GFiltersProfiles.PDE(Ind)).CMUFPAutoImgProcAttrs,
            RFrame.RFVectorScale );
    if CMSlideSaveStateFlags <> [] then

      CMMFFinishImageEditing( format( K_CML1Form.LLLTools7.Caption,
//        'Image is processed by global filter %s',
           [FilterNames[Ind + 1]] ), CMSlideSaveStateFlags,
           K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                            Ord(K_shImgActGFilter) ) )
    else
      N_CM_MainForm.CMMFShowString( '' );

    CMMFDisableActions( nil );
    CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsGFilterImgExecute

//************************************ TN_CMResForm.aToolsFlashLightExecute ***
// FlashLight Tool
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aToolsFlashLight Action handler
//
procedure TN_CMResForm.aToolsFlashLightExecute( Sender: TObject );
begin
  N_TestFlashLight( aToolsFlashLight.Checked );
end; // procedure TN_CMResForm.aToolsFlashLightExecute

//*********************************** TN_CMResForm.aViewFlashLightModeExecute ***
// View Flashlight
//
//     Parameters
// Sender - Event Sender
//
// View Flashlight instead of cursor on Slide View/Edit Frames
//
// OnExecute MainActions.aViewFlashLightMode Action handler
//
procedure TN_CMResForm.aToolsFlashLightModeExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );


  if N_CM_MainForm.CMMEdVEMode <> cmrfemFlashLight then
  begin
    aToolsFlashLightMode.Checked := TRUE;
    N_CM_MainForm.CMMSetFramesMode( cmrfemFlashLight );
  end
  else
  begin
    aToolsFlashLightMode.Checked := FALSE;
{ !!! it is already done in AddCMSActionStart
    if N_CM_MainForm.CMMFlashlightLastEd3Frame <> nil then
    begin
       N_CM_MainForm.CMMFlashlightLastEd3Frame.EdFlashLightModeRFA.HideFlashlight( TRUE );
       N_CM_MainForm.CMMFlashlightLastEd3Frame := nil;
    end;
}
    N_CM_MainForm.CMMSetFramesMode( cmrfemPoint );
  end;
  N_CM_MainForm.CMMFDisableActions( Sender );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aViewFlashLightModeExecute

//************************************ TN_CMResForm.aToolsConvToGreyExecute ***
// Convert to grey in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Convert Color Image to Grey in Active Editor Frame
//
// OnExecute MainActions.aToolsConvToGrey Action handler
//
procedure TN_CMResForm.aToolsConvToGreyExecute(Sender: TObject);
var
  NewDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    // Initialize Values

    NewDIB := TN_DIBObj.Create(DIBObj, 0, pfCustom, -1, epfGray8);
    DIBObj.CalcGrayDIB(NewDIB);
    DIBObj.Free;
    DIBObj := NewDIB;

    K_CMSlideSetAttrsByDIB( P(), DIBObj, FALSE );

    // Rebuild Map Image by new Current Image
    RebuildMapImageByDIB( );

    CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfAttribsChanged,cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActConvToGrey) ) );
    CMMFShowHideWaitState( FALSE );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aToolsConvToGreyExecute

//*************************************** TN_CMResForm.aToolsConvTo8Execute ***
// Convert to 8 bit in Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Convert Grey 16 bit Image to Grey 8 in Active Editor Frame
//
// OnExecute MainActions.aToolsConvTo8 Action handler
//
procedure TN_CMResForm.aToolsConvTo8Execute(Sender: TObject);
var
  NewDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    // Initialize Values

    NewDIB := TN_DIBObj.Create( DIBObj, DIBObj.DIBRect, pfCustom, epfGray8 );
    DIBObj.Free;
    DIBObj := NewDIB;

    K_CMSlideSetAttrsByDIB( P(), DIBObj, FALSE );

    // Rebuild Map Image by new Current Image
    RebuildMapImageByDIB( );

    CMMFFinishImageEditing( TAction(Sender).Caption, [cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActConvTo8) ) );
    CMMFShowHideWaitState( FALSE );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aToolsConvTo8Execute

//********************************** TN_CMResForm.aToolsAutoContrastExecute ***
// Auto Contrast Active Editor Frame (without Dialog)
//
//     Parameters
// Sender - Event Sender
//
// Calculate Auto Contrast DIB in Active Editor Frame
//
// OnExecute MainActions.aToolsAutoContrast Action handler
//
procedure TN_CMResForm.aToolsAutoContrastExecute(Sender: TObject);
var
  NDIB : TN_DIBObj;
  PCMSlide : TN_PCMSlide;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end; // if not CMMFCheckBSlideExisting() then

    CMMFShowHideWaitState( TRUE );
    if not CheckSlideMemBeforeAction( Sender, 0, 1 ) then Exit;

    with CMMFActiveEdFrame do
    begin
//      CMMFShowStringByTimer( 'Action is not implemented' );

      // Rebuild Current Image
      with EdSlide, GetCurrentImage() do
      begin
        if DIBObj.DIBNumBits > 8 then
          DIBObj.DIBNumBits := 16;

        // Needed (not debug) code:
        NDIB := nil;
        DIBObj.CalcMaxContrastDIB( NDIB );
        DIBObj.Free();
        DIBObj := NDIB;

//        N_CMDIBAdjustE2V( DIBObj ); // debug
//        N_CMDIBAdjustLight( DIBObj ); // debug
//        N_CMDIBAdjustByIntPar( DIBObj, StrToInt(N_ReadTextFile('aatst1.txt')) ); // debug

        PCMSlide := P();
        with PCMSlide^ do
          CMSDB.PixBits := DIBObj.DIBNumBits;

        // Clear Flip/Rotate in Map Attributes
        with GetPMapRootAttrs()^ do
        begin
          MRCoFactor  := 0;
          MRGamFactor := 0;
          MRBriFactor := 0;
        end;
        // Rebuild Map Image by new Current Image
        RebuildMapImageByDIB( );
      end; // with EdSlide, GetCurrentImage(), DIBObj do


  // Save Image changes

      CMMFFinishImageEditing( TAction(Sender).Caption,
//                            'Image is equalized',
                              [cmssfCurImgChanged, cmssfMapRootChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActAutoContrast) ) );
      CMMFShowHideWaitState( FALSE );
      CMMFDisableActions( nil );
    end; // with CMMFActiveEdFrame do

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aToolsAutoContrastExecute

    //********* Media Actions

//**************************************** TN_CMResForm.aMediaImportExecute ***
// Import media objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaImport Action handler
//
procedure TN_CMResForm.aMediaImportExecute( Sender: TObject );
var
  NumSlides: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMEDAccess.EDADCMSeriesStart();
  NumSlides := K_CMSlidesImportFromFiles();
  K_CMEDAccess.EDADCMSeriesFin();
  if NumSlides > 0 then
  begin
    with (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5) do
      if (pgcViewerHolder.ActivePage = DICOMViewerHolder) then
        pgcViewerHolder.ActivePage := tsSlidesViewer;

    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;
  N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia1.Caption,
//                ' %d Media object(s) are imported',
                   [NumSlides] ) );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaImportExecute

//************************************** TN_CMResForm.aMediaWCImportExecute ***
// Import media object from Widows Clipboard
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaWCImport Action handler
//
procedure TN_CMResForm.aMediaWCImportExecute( Sender: TObject );
var
  SL : TStringList;
  ImpNum : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  ImpNum := 0;
  if Windows.IsClipboardFormatAvailable( CF_DIB ) then
  begin // Import from Cliboard DIB
    if K_CMSlideWClipboardImport() then
      ImpNum := 1;
  end
  else if Windows.IsClipboardFormatAvailable( CF_HDROP ) then
  begin // Import from Cliboard DROPFILES
    SL := TStringList.Create;
    if N_GetFNamesFromClipboard( SL ) > 0 then
      ImpNum := K_CMSlidesImportFromFilesList( SL, '', // 'Clipboard'
                              K_CML1Form.LLLCaptHandler15.Caption  );
    SL.Free;
    if ImpNum > 0 then
    begin
      ImpNum := N_CM_MainForm.CMMSetSlidesAttrs( ImpNum, nil,
                               K_CML1Form.LLLCaptHandler10.Caption,
  //        'Process Output from Import',
                               [] );
    end;
  end;

  if ImpNum > 0 then
  begin
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;

  N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia2.Caption,
//    ' %d Media object(s) are imported from Clipboard',
                        [ImpNum] ) );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaWCImportExecute

//************************************ TN_CMResForm.aMediaDCMDImportExecute ***
// Import media objects from DICOMDIR
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaDCMDImport Action handler
//
procedure TN_CMResForm.aMediaDCMDImportExecute(Sender: TObject);
var
  NumSlides: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  NumSlides := K_CMSlidesImportFromDICOMDIR( nil );

  if NumSlides > 0 then
  begin
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;

  N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia1.Caption,
//                ' %d Media object(s) are imported',
                   [NumSlides] ) );
  if NumSlides > 0 then
    K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaDCMDImportExecute

{$R-}
procedure TN_CMResForm.aMediaDICOMImportExecute(Sender: TObject);
  function IsDICOM(AFileName: string): Boolean;
  var
    FP: file;
    lDICMcode: integer;
  begin
    Result := false;
    if ('.DCM' = ExtractFileExt(AFileName)) then
      Result := true;

    if ('.DCM' <> ExtractFileExt(AFileName)) then
    begin
      Filemode := 0;
      AssignFile(FP, AFileName);
      try
        Filemode := 0; // read only - might be CD
        System.Reset(FP, 1);

        if FileSize(FP) <= 132 then Exit;

        Seek(FP, 128);

        BlockRead(FP, lDICMcode, 4);

        Result := (lDICMcode = 1296255300);
      finally
        CloseFile(FP);
      end; // try..finally open file
      Filemode := 2; // read/write
    end; // Ext <> DCM
  end;

  procedure ScanForFiles(AFileList: TStringList; const APath: string);
  var
    FileName, Dir: string;
  begin
    for FileName in TDirectory.GetFiles(APath) do
      if IsDICOM(FileName) then
        if not ExtractFileName(FileName).Equals('DICOMDIR') then
          AFileList.Add(FileName);

    for Dir in TDirectory.GetDirectories(APath) do
      ScanForFiles(AFileList, Dir);
  end;
var
  OpenDialog: TFileOpenDialog;

  Dir: string;
  FileList: TStringList;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  OpenDialog := TFileOpenDialog.Create(nil);

  try
    OpenDialog.Options := OpenDialog.Options + [fdoPickFolders];

    if not OpenDialog.Execute then
      Exit;

    Dir := OpenDialog.FileName;
  finally
    FreeAndNil(OpenDialog);
  end;

  if Dir.IsEmpty then
    Exit;

  FileList := TStringList.Create;

  ScanForFiles(FileList, Dir);

  if FileList.Count > 0 then
    K_CMSlidesImportDICOM(FileList[0], Dir);

  FreeAndNil(FileList);

  LockWindowUpdate(N_CM_MainForm.CMMCurFMainForm.Handle);

  try
    if not Assigned(DICOMViewer) then
    begin
      DICOMViewer := TDICOMViewer.Create((N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder);
      DICOMViewer.Parent := (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder;
      (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder.Tag := integer(DICOMViewer);
      DICOMViewer.Show;
    end;

    DICOMViewer.Study.Reset;
    DICOMViewer.Study.Load(Dir);
  finally
    //LockWindowUpdate(N_CM_MainForm.Handle);
     //
    (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).tsSlidesViewer.TabVisible := True;
    (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder.TabVisible := True;
    (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePage := (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder;

    LockWindowUpdate(0);
  end;
end;
{$R+}

// procedure TN_CMResForm.aMediaDCMDImportExecute

//************************************** TN_CMResForm.aMediaImport3DExecute ***
// Import 3D Image from files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaImport3D Action handler
//
procedure TN_CMResForm.aMediaImport3DExecute(Sender: TObject);
var
  ImportPath : string;
{
  Slide3D : TN_UDCMSlide;
  InfoFName : string;
  CurSlidesNum, ResCode : Integer;
  AddViewsInfo : string;
}
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMImportFolderSelectDlg( ImportPath ) then
  begin
    K_CMImg3DImport( ImportPath );
{
    Slide3D := K_CMSlideCreateForImg3DObject();
    Slide3D.CreateThumbnail(); // create TMP  thubmnail
    K_CMEDAccess.EDAAddSlide( Slide3D );
    with Slide3D, P()^ do
    begin
      N_CM_MainForm.CMMSetUIEnabled( FALSE );
      N_CM_MainForm.CMMCurFMainForm.Hide();

      ResCode := K_CMImg3DCall( CMSDB.MediaFExt, ImportPath );

      if K_CMD4WAppFinState then
      begin
        N_Dump1Str( '3D> !!! CMSuite is terminated' );
        Application.Terminate;
        Exit;
      end;

      N_CM_MainForm.CMMCurFMainFormSkipOnShow := TRUE;
      N_CM_MainForm.CMMCurFMainForm.Show();

      N_CM_MainForm.CMMSetUIEnabled( TRUE );

      if ResCode = 0 then
      begin
      // Rebuild Thumbnail
        CreateThumbnail(); // create TMP  thubmnail
        K_CMImg3DAttrsInit( P() );

        CMSSourceDescr := ExtractFileName(ExcludeTrailingPathDelimiter(ImportPath));

        // Rebuild 3D slide ECache
        CMSlideECSFlags := [cmssfAttribsChanged];
        K_CMEDAccess.EDASaveSlideToECache( Slide3D );

        // Save 3D object
        K_CMEDAccess.EDASaveSlidesArray( @Slide3D, 1 );

        // Import and Save 2D views
        InfoFName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
                                         K_CMSlideGetImg3DFolderName( Slide3D.ObjName );
        CurSlidesNum := N_CM_MainForm.CMMImg3DViewsImportAndShowProgress( Slide3D.ObjName, InfoFName );
//        if CurSlidesNum = 0 then
          K_CMEDAccess.EDASetPatientSlidesUpdateFlag();

        N_CM_MainForm.CMMFRebuildVisSlides();
        N_CM_MainForm.CMMFDisableActions( nil );

        AddViewsInfo := K_CML1Form.LLLImg3D1.Caption; // ' 3D object is imported'
        if CurSlidesNum > 0 then
          AddViewsInfo := format( K_CML1Form.LLLImg3D2.Caption,
                                 //  '3D object and %s',
                           [format( K_CML1Form.LLLImg3D3.Caption,
          //                ' %d 3D views are imported'
                                 [CurSlidesNum] )] );
        N_CM_MainForm.CMMFShowStringByTimer( AddViewsInfo );

      end   // if ResCode = 0 then
      else
      begin // if ResCode <> 0 then
        // Remove New Slide
        with TK_CMEDDBAccess(K_CMEDAccess) do
        begin
          CurSlidesList.Delete(K_CMEDAccess.CurSlidesList.Count - 1);
          EDAClearSlideECache( Slide3D );
        end;

//        K_DeleteFolderFiles( Slide3D.P.CMSDB.MediaFExt );
        Slide3D.UDDelete();
      end;
    end; // with Slide3D, P()^ do
}
  end; // if K_CMImportFolderSelectDlg( ImportPath ) then

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaImport3DExecute

//********************************** TN_CMResForm.aMediaExportOpenedExecute ***
// Export Opened Slide
//
//     Parameters
// Sender - Event Sender
//
// Export one Selected Slide as *.bmp, *.jpg, *.tif or *.png  file
//
// OnExecute MainActions.aMediaExportOpened Action handler
//
procedure TN_CMResForm.aMediaExportOpenedExecute( Sender: TObject );
var
  Slide : TN_UDCMSlide;
  SelectedVObj : TN_UDCompVis;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, K_CMEDAccess do
  begin
    Slide := nil;
    if Length(CMMAllSlidesToOperate) = 1 then
      Slide := CMMAllSlidesToOperate[0]
    else if DGSelectedInd >= 0 then
      Slide := TN_UDCMSlide(K_CMCurVisSlidesArray[DGSelectedInd]);

    if (Slide = nil) or
       (0 <> EDACheckFilesAccessBySlidesSet( @Slide, 1,
                          K_CML1Form.LLLFileAccessCheck10.Caption {' Press OK to stop export.'} )) then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    K_CMSlidesLockForOpen( @Slide, 1, K_cmlrmOpenLock );
    if LockResCount = 0 then
    begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );
//      CMMFShowStringByTimer('Nothing to do!');
      AddCMSActionFinish( Sender );
      Exit;
    end;

    K_CMSResampleSlides( @Slide, 1, CMMFShowString );

    // Clear Selected Vobj
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (CMMFActiveEdFrame.EdSlide = Slide) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    if K_CMSlideExport( Slide ) then
      CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia4.Caption,
//        ' %d Media object(s) are exported',
                            [1] ) );

    CMMFFinishSlidesAction( SelectedVObj );

  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaExportOpenedExecute

//********************************** TN_CMResForm.aMediaExportMarkedExecute ***
// Export Marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides to Operate as *.bmp, *.jpg, *.tif, *.png, DICOM, DICOMDIR  file
//
// OnExecute MainActions.aMediaExportMarked Action handler
//
procedure TN_CMResForm.aMediaExportMarkedExecute( Sender: TObject );
begin
  MediaExportMarked( Sender, 0 );
end; // procedure TN_CMResForm.aMediaExportMarkedExecute

//******************************** TN_CMResForm.aMediaWCExportExecute ***
// Export Slides to Windows Clipboard
//
//     Parameters
// Sender - Event Sender
//
//
// OnExecute MainActions.aMediaWCExport Action handler
//
procedure TN_CMResForm.aMediaWCExportExecute(Sender: TObject);
var
  SelectedVObj : TN_UDCompVis;
  SlidesArray : TN_UDCMSArray;
  ECount, PixBits : Integer;
  Exported : Boolean;
  SavedCursor : TCursor;
begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, K_CMEDAccess do
  begin
    ECount := Length(CMMAllSlidesToOperate);
    if K_CMStudyAddSlidesGUIModeFlag then
    begin
      SlidesArray := K_CMSAddStudyCurSlidesToArray( CMMAllSlidesToOperate );
      ECount := Length(SlidesArray);
    end
    else
      SlidesArray := Copy( CMMAllSlidesToOperate, 0, ECount );

    if (ECount = 0) or
       (0 <> EDACheckFilesAccessBySlidesSet( @SlidesArray[0], ECount,
           K_CML1Form.LLLFileAccessCheck10.Caption )) then // ' Press OK to stop export.'
    begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit; // precaution
    end;

    K_CMSlidesLockForOpen( @SlidesArray[0], ECount, K_cmlrmOpenLock );

    if LockResCount = 0 then
    begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );
//      CMMFShowStringByTimer('Nothing to do!');
      AddCMSActionFinish( Sender );
      Exit;
    end;

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    // Clear Selected Vobj
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (0 <= K_IndexOfIntegerInRArray(
                     Integer(CMMFActiveEdFrame.EdSlide),
                     PInteger(@LockResSlides[0]),
                     LockResCount )) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    ECount := 0;
    Exported := FALSE;
    if (LockResCount = 1)  then
    begin
    // Try Single not 16-bit or with annotations
      PixBits := LockResSlides[0].P^.CMSDB.PixBits;
      if (PixBits =  8) or
         (PixBits = 24) or
         (LockResSlides[0].GetMeasureRoot( ).DirLength() > 0) then
      begin
      // Single Slide Export
        Exported := TRUE;
        if K_CMSlideWClipbordExport( LockResSlides[0] ) then
          ECount := 1;
      end
    end;

    if not Exported then
    begin
    // Multi Slides Export or Single 16-bit Export
      K_CMSResampleSlides( @LockResSlides[0], LockResCount, CMMFShowString );
      ECount := K_CMSlidesWClipbordExport( @LockResSlides[0], LockResCount );
    end;

    if ECount > 0 then
    begin
      K_CMSlidesSaveHistory( @LockResSlides[0], LockResCount,
         EDABuildHistActionCode( K_shATNotChange, Ord(K_shNCAExportWClipboard) ) );
      CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia8.Caption,
//             ' %d Media object(s) are exported to Clipboard',
                               [ECount] ) );
    end;

    CMMFFinishSlidesAction( SelectedVObj );
    Screen.Cursor := SavedCursor;

  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaWCExportExecute

{
//******************************** TN_CMResForm.aMediaWCExportExecute ***
// Export Slides to Windows Clipboard
//
//     Parameters
// Sender - Event Sender
//
//
// OnExecute MainActions.aMediaWCExport Action handler
//
procedure TN_CMResForm.aMediaWCExportExecute(Sender: TObject);
var
  Slide : TN_UDCMSlide;
  SelectedVObj : TN_UDCompVis;
  MesStr : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid, K_CMEDAccess do
  begin
    Slide := nil;
    if Length(CMMAllSlidesToOperate) = 1 then
      Slide := CMMAllSlidesToOperate[0]
    else if DGSelectedInd >= 0 then
      Slide := TN_UDCMSlide(K_CMCurVisSlidesArray[DGSelectedInd]);

    if (Length(CMMAllSlidesToOperate) > 1) then
    begin

      K_CMShowMessageDlg( K_CML1Form.LLLExportOpened1.Caption,
//        ' Only one object can be copied to clipboard.' + Chr($0D)+ Chr($0A)+
//        'Please clear your current selection and select one object only ',
          mtWarning );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if (Slide = nil) or
       (0 <> K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @Slide, 1,
                          K_CML1Form.LLLFileAccessCheck10.Caption )) then // ' Press OK to stop export.'
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    K_CMSlidesLockForOpen( @Slide, 1, K_cmlrmOpenLock );
    if LockResCount = 0 then
    begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );
//      CMMFShowStringByTimer('Nothing to do!');
      AddCMSActionFinish( Sender );
      Exit;
    end;

    // Clear Selected Vobj
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (CMMFActiveEdFrame.EdSlide = Slide) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    MesStr := '';
      if K_CMSlideWClipbordExport( Slide ) then
        MesStr := K_CML1Form.LLLExportOpened3.Caption;

    // Restore Selected Vobj
    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

    CMMRedrawOpenedFromGiven( @LockResSlides[0], LockResCount );


    if MesStr <> '' then
      CMMFShowStringByTimer( MesStr ); // debug

    EDAUnlockAllLockedSlides( K_cmlrmOpenLock );

  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaWCExportExecute
}

//****************************************** TN_CMResForm.aMediaOpenExecute ***
// Open marked Slides for editing
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaOpen Action handler
//
procedure TN_CMResForm.aMediaOpenExecute( Sender: TObject );
var
  NumMarked : integer;
  ImgSlides : TN_UDCMSArray;
  RFStateInds : TN_IArray;
  StudiesCount : Integer;

  i: integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMCurFThumbsDGrid do
  begin
    Inc(CMMSkipDisableActionsCount);
    CMMFShowString( '' ); // clear

    DGGetSelection( RFStateInds );
    NumMarked := CMMGetMarkedSlidesArray( ImgSlides );

    for i := NumMarked - 1 downto 0 do
      if (cmsfIsImg3DObj in ImgSlides[i].P^.CMSDB.SFlags) then
        ImgSlides.Delete(i);

    NumMarked := Length(ImgSlides);

    if NumMarked > 0 then
    begin
      // Mix of Studies and Slides is not allowed now

      // Separate Studies and open them in Read Mode
      StudiesCount := K_CMSeparateSlidesAndStudies( @ImgSlides[0], NumMarked );
      if StudiesCount > 0 then
      begin
        K_CMSMediaOpen( @ImgSlides[0], StudiesCount, TRUE );
  //      K_CMEDAccess.LockResCount := 0;
        NumMarked := NumMarked - StudiesCount;
      end;


      // Open Slides in Edit Mode
      if (NumMarked > 0) and
         (0 = K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @ImgSlides[StudiesCount], NumMarked,
                          K_CML1Form.LLLFileAccessCheck11.Caption {' Press OK to stop opening.'} )) then
      begin

        K_CMSMediaOpen( @ImgSlides[StudiesCount], NumMarked );
  //      K_CMEDAccess.LockResCount := 0;
        DGSetSelection( RFStateInds );
      end;
    end;

    Dec(CMMSkipDisableActionsCount);
    CMMFDisableActions(nil);

  end; // with N_CM_MainForm, CMMCurFThumbsDGrid do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaOpenExecute

//****************************************** TN_CMResForm.aMediaAddToOpenedExecute ***
// Add selected Slide to Opened for editing
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaAddToOpened Action handler
//
procedure TN_CMResForm.aMediaAddToOpenedExecute(Sender: TObject);
var
  UDSlide : TN_UDCMSlide;
  AddToOpenedFlags : TK_CMSlideAddToOpenedFlags;

  ImgSlides : TN_UDCMSArray;
  NumMarked : Integer;

label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

 // Use ThumbnailFrame or Current Active Study Selection
  with N_CM_MainForm do
  begin
    NumMarked := CMMGetMarkedSlidesArray( ImgSlides );
    if NumMarked = 0 then
    begin
LExit:
//      K_CMD4WWaitApplyDataFlag := false;
      Dec(K_CMD4WWaitApplyDataCount);
      N_Dump2Str( 'Nothing to do aMediaAddToOpened' );
      Exit;
    end;

    UDSlide := ImgSlides[NumMarked - 1];

    if not (cmsfDICOMStudy in UDSlide.P^.CMSDB.SFlags) then
      if 0 <> K_CMEDAccess.EDACheckFilesAccessBySlidesSet( @UDSlide, 1,
            K_CML1Form.LLLFileAccessCheck11.Caption // 'Press OK to stop opening.'
                                                   ) then goto LExit;

    AddToOpenedFlags := [];
    if Sender = nil then
      AddToOpenedFlags := [uieflSkipBWRules];

    if (cmsfDICOMStudy in UDSlide.P^.CMSDB.SFlags) then
    begin
      LockWindowUpdate(N_CM_MainForm.CMMCurFMainForm.Handle);

      try
        if not Assigned(DICOMViewer) then
        begin
          DICOMViewer := TDICOMViewer.Create((N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder);
          DICOMViewer.Parent := (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder;
          (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder.Tag := integer(DICOMViewer);
          DICOMViewer.Show;
        end;

        DICOMViewer.Study.Reset;
        DICOMViewer.Study.Load(ExtractFilePath(TK_CMEDDBAccess(K_CMEDAccess).EDAGetDICOMPath(UDSlide)));
      finally
        (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).tsSlidesViewer.TabVisible := True;
        (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder.TabVisible := True;

        LockWindowUpdate(0);

        (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePage := (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).DICOMViewerHolder;
      end;
    end
    else
    begin
      if not CMMAddMediaToOpened( UDSlide, AddToOpenedFlags ) then goto LExit;
      (N_CM_MainForm.CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex := 0;
    end;
  end;

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aMediaAddToOpenedExecute

//***************************************** TN_CMResForm.aMediaDuplicateExecute ***
// Duplicate marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Duplicate marked Slides current state to new Slide Objects
//
// OnExecute MainActions.aMediaDuplicate Action handler
//
procedure TN_CMResForm.aMediaDuplicateExecute(Sender: TObject);
var
  NumSlides : Integer;
  SelectedVObj : TN_UDCompVis;
  WarnStr : string;
  SaveCursor : TCursor;
  i, Ind : Integer;
  NumOutOfMemory : Integer;

label FExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, K_CMEDAccess do
  begin

  { //!! New code for Separating Studies }
    NumSlides := Length(CMMAllSlidesToOperate);
    Ind := 0;
    for i := 0 to High(CMMAllSlidesToOperate) do
    begin
      if TN_UDCMBSlide(CMMAllSlidesToOperate[i]) is TN_UDCMStudy then
         Continue;
      CMMAllSlidesToOperate[Ind] := CMMAllSlidesToOperate[i];
      Inc(Ind);
    end;

    SetLength( CMMAllSlidesToOperate, Ind );

    if Ind < NumSlides then
      K_CMShowMessageDlg( format( K_CML1Form.LLLDupl4.Caption,
      // '%d study object(s) of %d object(s) are skiped!'
                     [NumSlides - Ind, NumSlides] ), mtInformation );

    if Ind = 0 then goto FExit;

    NumSlides := K_CMDEMOAddConstraint( Length(CMMAllSlidesToOperate) );

    if (NumSlides > 0) and
       (0 = EDACheckFilesAccessBySlidesSet( @CMMAllSlidesToOperate[0], NumSlides,
            K_CML1Form.LLLFileAccessCheck12.Caption {' Press OK to stop duplicate.'} )) then
    begin

      K_CMSlidesLockForOpen( @CMMAllSlidesToOperate[0], NumSlides, K_cmlrmOpenLock );
      if LockResCount = 0 then begin
FExit:
        CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
        AddCMSActionFinish( Sender );
        Exit;
      end;
//      if LockResUpdateThumbCount > 0 then CMMCurFThumbsDGrid.DGInitRFrame();
//      if LockResUpdateOpenImgCount > 0 then K_CMRefreshOpenedView();

      K_CMSResampleSlides( @LockResSlides[0], LockResCount, CMMFShowString );
      // Duplicate Slides
      K_CMSlidesCopyToClipboard( @LockResSlides[0], LockResCount );

      // Clear Selected Vobj
      SelectedVObj := nil;
      if (CMMFActiveEdFrame.EdSlide <> nil) and
         (0 <= K_IndexOfIntegerInRArray(
                       Integer(CMMFActiveEdFrame.EdSlide),
                       PInteger(@LockResSlides[0]),
                       LockResCount)) then
        SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;
      if SelectedVObj <> nil then
        CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

      SaveCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;

    // Disable CMS UI
      N_CM_MainForm.CMMSetUIEnabled( FALSE );
{
      Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
      N_CM_MainForm.CMMFDisableActions( Self );
      N_AppSkipEvents := TRUE;
      K_CMD4WSkipCloseUI := TRUE;
}

      NumSlides := K_CMSlidesPasteFromClipboard0( TRUE, NumOutOfMemory ); // Without History
//      NumSlides := K_CMSlidesPasteFromClipboard(); // With History

    // Enable CMS UI
      N_CM_MainForm.CMMSetUIEnabled( TRUE );
{
      K_CMD4WSkipCloseUI := FALSE;
      N_AppSkipEvents := FALSE;
      Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
      N_CM_MainForm.CMMFDisableActions( Self );
}

      Screen.Cursor := SaveCursor;


      // Restore Selected Vobj
      if SelectedVObj <> nil then
        CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

//  not needed because opend slides are not drawn in other context
//      CMMRedrawOpenedFromGiven( @LockResSlides[0], LockResCount );

      CMMFRebuildVisSlides();

      WarnStr := '';
      if NumOutOfMemory > 0 then
      begin
        K_CMShowMessageDlg( format( K_CML1Form.LLLMemory8.Caption,
//'There is not enough memory to process all images. %d object(s) haven''t been duplicated.'+
//'        Please close some open image(s) or restart Media Suite if needed.',
                [NumOutOfMemory] ), mtWarning );
        K_CMOutOfMemoryFlag := TRUE;
      end;

      WarnStr := '';
      if LockResCount > NumSlides + NumOutOfMemory then
        WarnStr := Format( K_CML1Form.LLLMedia6.Caption,
//            ', %d Media Files are inaccessible',
                           [LockResCount - NumSlides - NumOutOfMemory] );

      CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia5.Caption,
//        ' %d Media object(s) are duplicated',
                            [NumSlides] ) + WarnStr );
      if NumSlides > 0 then
        EDASetPatientSlidesUpdateFlag();

      EDAUnlockAllLockedSlides( K_cmlrmOpenLock );
    end;
  end; // with N_CM_MainForm, K_CMEDAccess do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaDuplicateExecute


//***************************************** TN_CMResForm.aMediaEmailExecute ***
// Email marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Open default Email application with empty message and attached files, that
// are ziped Images of Marked Slides
//
// OnExecute MainActions.aMediaEmail Action handler
//
procedure TN_CMResForm.aMediaEmailExecute( Sender: TObject );
var
  SelectedVObj : TN_UDCompVis;
  ECount : Integer;
  SlidesArray : TN_UDCMSArray;
//  PrevLeft, PrevTop : Integer;

const
  MaxSizeArray : array [0..4] of TPoint =
        ((X:640;Y:480),(X:800;Y:600),(X:1024;Y:768),(X:1280;Y:1024),(X:0;Y:0));
label FExit;
begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, K_CMEDAccess do
  begin
    ECount := Length(CMMAllSlidesToOperate);
    if (ECount = 0) or
       (0 <> EDACheckFilesAccessBySlidesSet( @CMMAllSlidesToOperate[0], ECount,
                           K_CML1Form.LLLFileAccessCheck13.Caption {' Press OK to stop emailing.'} )) then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      goto FExit;
    end;

    if not K_CMSelectMaxPictSizeDlg( K_CMSlideEESizeInd ) then
    begin
      N_Dump2Str( 'Stop inside MaxSize Selection Dlg ' + TAction(Sender).Caption );
      goto FExit;
    end;

    if K_CMStudyAddSlidesGUIModeFlag then
    begin
      SlidesArray := K_CMSAddStudyCurSlidesToArray( CMMAllSlidesToOperate );
      ECount := Length(SlidesArray);
    end
    else
      SlidesArray := Copy( CMMAllSlidesToOperate, 0, ECount );


    K_CMSlidesLockForOpen( @SlidesArray[0], ECount, K_cmlrmOpenLock );

    if LockResCount = 0 then begin
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      goto FExit;
    end;

    SlidesArray := Copy( LockResSlides, 0, LockResCount );


  //////////////////////////////////////////////
  // To prevent rare case when Mail modal window
  // was hide "under" CMS main Window
  //!!!       Start
    {}
    /////////
    // Var -1 - Wait a little for SelectMaxPictSizeDlg window will be hide
    sleep(10);
    {}
    {}
    /////////
    // Var 0 - Proccess other messages for SelectMaxPictSizeDlg window hide
    Application.ProcessMessages();
    {}
    {
    /////////
    // Var 1 - Refresh CMS main Window before
    // Mail modal window will be shown
    N_CM_MainForm.CMMCurFMainForm.Refresh();
    {}
    {
    ///////// !!! error - 2-nd call to Mail Dialog Windows hides it
    // var 2 - Move CMS main Window out of screen until Mail Dialog will be finished
    PrevLeft := N_CM_MainForm.CMMCurFMainForm.Left;
    PrevTop  := N_CM_MainForm.CMMCurFMainForm.Top;
    N_CM_MainForm.CMMCurFMainForm.Left := N_WholeWAR.Right + 100;
    N_CM_MainForm.CMMCurFMainForm.Top  := N_WholeWAR.Bottom + 100;
    {}
  // !!!       end of Start
  //////////////////////////////////////////////

    // Clear Selected Vobj
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (0 <= K_IndexOfIntegerInRArray(
                     Integer(CMMFActiveEdFrame.EdSlide),
                     PInteger(@SlidesArray[0]),
                     LockResCount )) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    K_CMSResampleSlides( @SlidesArray[0], LockResCount, CMMFShowString );

    ECount := K_CMSlidesEmailing( @SlidesArray[0], LockResCount,
                                          MaxSizeArray[K_CMSlideEESizeInd].X,
                                          MaxSizeArray[K_CMSlideEESizeInd].Y );

  //////////////////////////////////////////////
  // To prevent rare case when Mail modal window
  // was hide "under" CMS main Window
  // !!!       Finish
    {
    /////////
    // var 2 - Restore CMS main Window position after Mail Dialog
    N_CM_MainForm.CMMCurFMainForm.Left := PrevLeft;
    N_CM_MainForm.CMMCurFMainForm.Top  := PrevTop;
    {}
  // !!!       end of Finish
  //////////////////////////////////////////////

// 2019-10-16 - save Original Size Selection
//    if K_CMSlideEESizeInd = High(MaxSizeArray) then
//      K_CMSlideEESizeInd := 0; // not save Original Size Selection


//!!! UnLock is now done inside Slides Emailing
//  EDAUnlockSlides( @LockResSlides[0], LockResCount, K_cmlrmOpenLock);
//    LockResCount := 0; // Clear LockResCount for self check routine
    // Restore Selected Vobj
    if not K_CMD4WAppFinState then
    begin
      if SelectedVObj <> nil then
        CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

      CMMRedrawOpenedFromGiven( @SlidesArray[0], Length(SlidesArray) );
      if ECount >= 0 then
      begin
        CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia7.Caption,
//             ' %d Media object(s) are emailed',
                               [ECount] ) )
      end
      else
//      if (ECount >= -1000) and (ECount <= -1003) then !!! error exception codes -1003 <= Code <= -1000
      if (ECount <= -1000) and (ECount >= -1003) then
        K_CMShowMessageDlg1( K_CML1Form.LLLEmail1.Caption,
//            ' Emailing internal exception',
              mtWarning )
      else if ECount = -1 then
        CMMFShowStringByTimer( K_CML1Form.LLLEmail2.Caption ) // ' Emailing was aborted by user'
      else if ECount = -2 then
        K_CMShowMessageDlg1( K_CML1Form.LLLEmail3.Caption,
//            ' Emailing failure',
              mtWarning )
      else
        K_CMShowMessageDlg1( K_CML1Form.LLLEmail4.Caption,
//            ' Emailing error',
              mtWarning )
    end;
  end; // with N_CM_MainForm, K_CMEDAccess do

FExit:
  AddCMSActionFinish( Sender );
  if not K_CMD4WAppFinState then Exit;

//!!!!!!!!! Special Applicatio Termination if Emailing Dialog was opened
  N_Dump1Str( 'Application.Terminate inside aMediaEmailExecute' );
  Application.Terminate;
end; // procedure TN_CMResForm.aMediaEmailExecute

//**************************************** TN_CMResForm.aMediaEmail1Execute ***
// Email marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Open default Email application with empty message and attached files, that
// are ziped Images of Marked Slides
//
// OnExecute MainActions.aMediaEmail1 Action handler
//
procedure TN_CMResForm.aMediaEmail1Execute( Sender: TObject );
var
  SelectedVObj : TN_UDCompVis;
  ECount : Integer;
  SlidesArray : TN_UDCMSArray;
//  PrevLeft, PrevTop : Integer;
  SL1, SL, ML : TStrings;
  Res : Boolean;
  MailSubject : string;
  PrevMailSettings : string;
  UseGlobalSettings : Boolean;
const
  MaxSizeArray : array [0..4] of TPoint =
        ((X:640;Y:480),(X:800;Y:600),(X:1024;Y:768),(X:1280;Y:1024),(X:0;Y:0));
label FExit, LNothingToDo;
begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, K_CMEDAccess do
  begin
    ECount := Length(CMMAllSlidesToOperate);
    if (ECount = 0) or
       (0 <> EDACheckFilesAccessBySlidesSet( @CMMAllSlidesToOperate[0], ECount,
                           K_CML1Form.LLLFileAccessCheck13.Caption {' Press OK to stop emailing.'} )) then
    begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
LNothingToDo: //************
      N_Dump2Str( K_CML1Form.LLLNothingToDo.Caption + ' ' + TAction(Sender).Caption );
      goto FExit;
    end;

    if not K_CMSelectMaxPictSizeDlg( K_CMSlideEESizeInd ) then
    begin
      N_Dump2Str( 'Stop inside MaxSize Selection Dlg ' + TAction(Sender).Caption );
      goto FExit;
    end;

    if K_CMStudyAddSlidesGUIModeFlag then
    begin
      SlidesArray := K_CMSAddStudyCurSlidesToArray( CMMAllSlidesToOperate );
      ECount := Length(SlidesArray);
    end
    else
      SlidesArray := Copy( CMMAllSlidesToOperate, 0, ECount );


    K_CMSlidesLockForOpen( @SlidesArray[0], ECount, K_cmlrmOpenLock );

    if LockResCount = 0 then
      goto LNothingToDo;
//    begin
//      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
//      goto FExit;
//    end;

    SlidesArray := Copy( LockResSlides, 0, LockResCount );

   //////////////////////////////////////////////
  // To prevent rare case when Mail modal window
  // was hide "under" CMS main Window
  //!!!       Start
    {}
    /////////
    // Var -1 - Wait a little for SelectMaxPictSizeDlg window will be hide
    sleep(10);
    {}
    {}
    /////////
    // Var 0 - Proccess other messages for SelectMaxPictSizeDlg window hide
    Application.ProcessMessages();
    {}
    {
    /////////
    // Var 1 - Refresh CMS main Window before
    // Mail modal window will be shown
    N_CM_MainForm.CMMCurFMainForm.Refresh();
    {}
    {
    ///////// !!! error - 2-nd call to Mail Dialog Windows hides it
    // var 2 - Move CMS main Window out of screen until Mail Dialog will be finished
    PrevLeft := N_CM_MainForm.CMMCurFMainForm.Left;
    PrevTop  := N_CM_MainForm.CMMCurFMainForm.Top;
    N_CM_MainForm.CMMCurFMainForm.Left := N_WholeWAR.Right + 100;
    N_CM_MainForm.CMMCurFMainForm.Top  := N_WholeWAR.Bottom + 100;
    {}
  // !!!       end of Start
  //////////////////////////////////////////////

    K_CMSResampleSlides( @SlidesArray[0], LockResCount, CMMFShowString );


    // Clear Selected Vobj in emailing Slide
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (0 <= K_IndexOfIntegerInRArray(
                     Integer(CMMFActiveEdFrame.EdSlide),
                     PInteger(@SlidesArray[0]),
                     LockResCount )) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    // Export Slides for Emailing
    SL := TStringList.Create;
    ML := K_CMEDAccess.EDAGetProviderMacroInfo();
    ECount := K_CMSlidesExportFilesList( @SlidesArray[0], LockResCount,
                                         K_ExpandFileName('(#TmpFiles#)'), '.jpg',
                                         SL, ML, MaxSizeArray[K_CMSlideEESizeInd].X,
                                         MaxSizeArray[K_CMSlideEESizeInd].Y );
    if LockResCount <> ECount then
      N_Dump1Str( format( 'K_CMSlidesEmailing >> %d of %d files are prepare', [ECount,LockResCount] ) );


    if K_CMSlidesExportFilesOutOfMemory > 0 then
    begin
      K_CMShowMessageDlg( format( K_CML1Form.LLLMemory2.Caption,
  //'There is not enough memory to process all images. %d object(s) haven''t been attached.'+
  //'        Please close some open image(s) or restart Media Suite if needed.',
                  [K_CMSlidesExportFilesOutOfMemory] ), mtWarning );
      K_CMOutOfMemoryFlag := TRUE;
    end;

    // Restore Selected Vobj in emailed Slide
    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 1, SelectedVObj );

    K_CMEDAccess.EDAUnlockAllLockedSlides( K_cmlrmOpenLock );

    if ECount = 0 then
    begin
      // Restore Selected Vobj
      SL.Free;
      goto LNothingToDo;
    end
    else
    begin
      N_Dump2Str( 'K_CMSlidesEmailing >> files list:' );
      N_Dump2Strings( SL, 5 );
    end;

    MailSubject := K_StringMListReplace( K_CML1Form.LLLMPatMailSubject.Caption,
                                         ML, K_ummRemoveMacro );

    // Init Current Email context
    UseGlobalSettings := not N_MemIniToBool( 'CMS_Main', 'UseEMailLocalSettings', FALSE );
    if UseGlobalSettings then
    begin
      SL1 := TStringList.Create;
      N_CurMemIni.ReadSectionValues( 'GCMS_Email', SL1 );
      N_CurMemIni.EraseSection( 'CMS_Email' );
      K_AddStringsToMemIniSection( N_CurMemIni, 'CMS_Email', SL1 );
      SL1.Free;
    end;

    // Select Email Client
    if not N_MemIniToBool( 'CMS_Email', 'SelfEmailClient', FALSE ) then
      Res := K_CMFilesEmailingByMapi( MailSubject, SL )
    else
    begin
      // Dump Cur Mail Client Settings
      N_CurMemIni.ReadSectionValues( 'CMS_Email', K_CMEDAccess.TmpStrings );
      K_CMEDAccess.EDAHidePasswordForDump( K_CMEDAccess.TmpStrings );
    //N_Dump2Str( '     SMTP Email Settings:' );
    //N_Dump2Strings( K_CMEDAccess.TmpStrings, 5 );
      PrevMailSettings := K_CMEDAccess.TmpStrings.Text;
      N_Dump1Str( '     SMTP Email Settings:'#13#10 + PrevMailSettings );
      Res := K_CMFilesEmailingBySelfClient( MailSubject, SL );
      N_CurMemIni.ReadSectionValues( 'CMS_Email', K_CMEDAccess.TmpStrings );
{
      if UseGlobalSettings and
         (PrevMailSettings <> K_CMEDAccess.TmpStrings.Text) and then
      if  then
      begin
        SL1 := TStringList.Create;
        N_CurMemIni.ReadSectionValues( 'GCMS_Email', SL1 );
        N_CurMemIni.EraseSection( 'CMS_Email' );
        K_AddStringsToMemIniSection( N_CurMemIni, 'CMS_Email', SL1 );
        SL1.Free;
      end;
}      
    end;

    SL.Free;


  //////////////////////////////////////////////
  // To prevent rare case when Mail modal window
  // was hide "under" CMS main Window
  // !!!       Finish
    {
    /////////
    // var 2 - Restore CMS main Window position after Mail Dialog
    N_CM_MainForm.CMMCurFMainForm.Left := PrevLeft;
    N_CM_MainForm.CMMCurFMainForm.Top  := PrevTop;
    {}
  // !!!       end of Finish
  //////////////////////////////////////////////

// 2019-10-16 - save Original Size Selection
//    if K_CMSlideEESizeInd = High(MaxSizeArray) then
//      K_CMSlideEESizeInd := 0; // not save Original Size Selection


//!!! UnLock is now done inside Slides Emailing
//  EDAUnlockSlides( @LockResSlides[0], LockResCount, K_cmlrmOpenLock);
//    LockResCount := 0; // Clear LockResCount for self check routine
    // Restore Selected Vobj
    if not K_CMD4WAppFinState then
    begin
      // Save Statistics if Slides are really emailed
      if Res then
      begin
        K_CMSlidesSaveHistory( @SlidesArray[0], Length(SlidesArray),
           K_CMEDAccess.EDABuildHistActionCode(K_shATNotChange, Ord(K_shNCAEmail) ) );
        CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia7.Caption,
//             ' %d Media object(s) are emailed',
                               [ECount] ) )
      end;
      // Redraw Opend Slides - needed to rebuild Components pixel coords for VObjs correct search
      CMMRedrawOpenedFromGiven( @SlidesArray[0], Length(SlidesArray) );
    end;
  end; // with N_CM_MainForm, K_CMEDAccess do

FExit:
  AddCMSActionFinish( Sender );
  if not K_CMD4WAppFinState then Exit;

//!!!!!!!!! Special Applicatio Termination if Emailing Dialog was opened
  N_Dump1Str( 'Application.Terminate inside aMediaEmailExecute' );
  Application.Terminate;
end; // procedure TN_CMResForm.aMediaEmail1Execute

//***************************************** TN_CMResForm.aMediaEMChangeHLocExecute ***
// Change Host Location for selected objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aMediaEMChangeHLoc Action handler
//
procedure TN_CMResForm.aMediaEMChangeHLocExecute(Sender: TObject);
var
  NumMarked, NewHLoc : Integer;
  ImgSlides : TN_UDCMSArray;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  NewHLoc := K_CMEMSelectLocationDlg( );
  with N_CM_MainForm do
    if NewHLoc <> -1 then
    begin
      CMMFShowString( '' ); // clear
      NumMarked := CMMGetMarkedSlidesArray( ImgSlides );
      TK_CMEDDBAccess(K_CMEDAccess).EDAEMSetSlidesHLoc( @ImgSlides[0], NumMarked , NewHLoc );
      CMMFShowStringByTimer( Format( 'New host location is set to %d Media object(s)', [NumMarked ] ) );
    end
    else
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do' );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaEMChangeHLocExecute

//******************************* TN_CMResForm.aMediaExportToD4WDocsExecute ***
// Export Marked Slides to D4W document manager
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides as *.jpg files
//
// OnExecute MainActions.aMediaExportToD4WDocs Action handler
//
procedure TN_CMResForm.aMediaExportToD4WDocsExecute(Sender: TObject);
begin
  MediaExportMarked( Sender, 3 );
end; // procedure TN_CMResForm.aMediaExportToD4WDocsExecute

//********************************** TN_CMResForm.aMediaArchRestQAddExecute ***
// Add archived slides to restoring queue
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides as *.jpg files
//
// OnExecute MainActions.aMediaArchRestQAdd Action handler
//
procedure TN_CMResForm.aMediaArchRestQAddExecute(Sender: TObject);
var
  SQLStr, LogStr, DumpStr : string;
  SlidesArray: TN_UDCMSArray;
  i, j, k, m : Integer;
  SL : TStringList;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, TK_CMEDDBAccess(K_CMEDAccess) do
  begin
{}
    SetLength( SlidesArray, Length(CMMAllSlidesToOperate) );
    j := 0;
    for i := 0 to High(CMMAllSlidesToOperate) do
      if TN_UDCMBSlide(CMMAllSlidesToOperate[i]) is TN_UDCMStudy then
      begin
        k := TN_UDCMStudy(CMMAllSlidesToOperate[i]).GetCurSlidesToArray( SlidesArray, j );
        for m := j to k - 1 do
        begin
          with SlidesArray[m] do
          if CMSArchived and (CMSArchDate = 0) then
          begin
            SlidesArray[j] := SlidesArray[m];
            Inc(j);
          end;
        end;
      end
      else
      begin
        SlidesArray[j] := CMMAllSlidesToOperate[i];
        Inc(j);
      end;
    SetLength( SlidesArray, j );
{}
    // Build Slides List Select Condition
    EDABuildSelectSQLBySlidesList( @SlidesArray[0],
                                 Length(SlidesArray), @SQLStr, @LogStr );

    with CurSQLCommand1 do
    begin // Add Slides to Restoring Queue
      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' set ' +
        K_CMENDBSTFSlideDTArch + ' = ' + EDADBDateToSQL( EDAGetSyncTimestamp() ) +
        ' where (' + SQLStr + ') and ' + K_CMENDBSTFSlideThumbnail + ' is null';
      Execute;
    end;

    aViewThumbRefreshExecute( N_CMResForm.aViewThumbRefresh );

    // Rebuild Slides Array after aViewThumbRefresh
    DumpStr := format( 'ArchRestQAdd>> Selected to add %d %s',
                       [Length(SlidesArray), LogStr] );
    SL := TStringList.Create();
    LogStr := Copy( LogStr, 1 + Pos( '=', LogStr ), Length(LogStr) );
    SL.CommaText := LogStr;
    m := 0;
    for i := 0 to SL.Count - 1 do
      for j := 0 to CurSlidesList.Count - 1 do
        with TN_UDCMBSlide(CurSlidesList[j]) do
        if (ObjName = SL[i]) then
        begin
          if CMSArchived and (CMSArchDate <> 0) then
          begin
            SlidesArray[m] := TN_UDCMSlide(CurSlidesList[j]);
            Inc(m);
          end;
          break;
        end;
    SL.Free;

    if m > 0 then
    begin
      EDASaveSlidesListHistory( @SlidesArray[0], m,
                                       EDABuildHistActionCode(
                                                   K_shATNotChange,
                                                   Ord(K_shNCAArchive),
                                                   Ord(K_shNCAArchQAdd) ) );
      EDABuildSelectSQLBySlidesList( @SlidesArray[0], m, nil, @LogStr );
      DumpStr := format( '%s'#13#10'     Realy deleted %d %s', [DumpStr, m, LogStr] );
    end;
    N_Dump1Str( DumpStr );
    CMMFShowStringByTimer( format( ' %d objects are added to restore queue', [m]) );
  end; // with N_CM_MainForm, K_CMEDAccess do


  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaArchRestQAddExecute

//********************************** TN_CMResForm.aMediaArchRestQDelExecute ***
// Delete archived slides frome restoring queue
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides as *.jpg files
//
// OnExecute MainActions.aMediaArchRestQDel Action handler
//
procedure TN_CMResForm.aMediaArchRestQDelExecute(Sender: TObject);
var
  SQLStr, LogStr, DumpStr : string;
  SlidesArray: TN_UDCMSArray;
  i, j, k, m : Integer;
  SL : TStringList;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    j := 0;
    SetLength( SlidesArray, Length(CMMAllSlidesToOperate) );
    for i := 0 to High(CMMAllSlidesToOperate) do
      if TN_UDCMBSlide(CMMAllSlidesToOperate[i]) is TN_UDCMStudy then
      begin
        k := TN_UDCMStudy(CMMAllSlidesToOperate[i]).GetCurSlidesToArray( SlidesArray, j );
        for m := j to k - 1 do
        begin
          with SlidesArray[m] do
          if CMSArchived and (CMSArchDate <> 0) then
          begin
            SlidesArray[j] := SlidesArray[m];
            Inc(j);
          end;
        end;
      end
      else
      begin
        SlidesArray[j] := CMMAllSlidesToOperate[i];
        Inc(j);
      end;
    SetLength( SlidesArray, j );

    // Build Slides List Select Condition
    EDABuildSelectSQLBySlidesList( @SlidesArray[0],
                                 Length(SlidesArray), @SQLStr, @LogStr );

    with CurSQLCommand1 do
    begin // Delete Slides from Restoring Queue
      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' set ' +
                     K_CMENDBSTFSlideDTArch + ' = NULL  where (' + SQLStr +
                     ') and ' + K_CMENDBSTFSlideThumbnail + ' is null';
      Execute;
    end;

    aViewThumbRefreshExecute( N_CMResForm.aViewThumbRefresh );

    // Rebuild Slides Array after aViewThumbRefresh
    DumpStr := format( 'ArchRestQDel>> Selected to delete %d %s',
                       [Length(SlidesArray), LogStr] );
    SL := TStringList.Create();
    LogStr := Copy( LogStr, 1 + Pos( '=', LogStr ), Length(LogStr) );
    SL.CommaText := LogStr;
    m := 0;
    for i := 0 to SL.Count - 1 do
      for j := 0 to CurSlidesList.Count - 1 do
        with TN_UDCMBSlide(CurSlidesList[j]) do
        if (ObjName = SL[i]) then
        begin
          if CMSArchived and (CMSArchDate = 0) then
          begin
            SlidesArray[m] := TN_UDCMSlide(CurSlidesList[j]);
            Inc(m);
          end;
          break;
        end;
    SL.Free;

    if m > 0 then
    begin
      EDASaveSlidesListHistory( @SlidesArray[0], m,
                                       EDABuildHistActionCode(
                                                     K_shATNotChange,
                                                     Ord(K_shNCAArchive),
                                                     Ord(K_shNCAArchQDel) ) );
      EDABuildSelectSQLBySlidesList( @SlidesArray[0], m, nil, @LogStr );
      DumpStr := format( '%s'#13#10'     Realy deleted %d %s', [DumpStr, m, LogStr] );
    end;

    N_Dump1Str( DumpStr );
    CMMFShowStringByTimer( format( ' %d objects are deleted from restore queue', [m]) );
  end; // with N_CM_MainForm, K_CMEDAccess do



  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaArchRestQDelExecute

//********************************** TN_CMResForm.aMediaArchRestQDelExecute ***
// Export marked 3D object files to selected folder
//
//     Parameters
// Sender - Event Sender
//
// Copy all files from 'SrcFiles' SubFolder of marked 3D object folder to selected folder
//
// OnExecute MainActions.aMediaExport3D Action handler
//
procedure TN_CMResForm.aMediaExport3DExecute(Sender: TObject);
var
  FPath : string;
  Folder3D : string;
  RCount, Res : Integer;
  FSlide : TN_UDCMSlide;
  FSize : Int64;
  AllCount : Integer;
  SavedCursor : TCursor;

label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  FPath := '';
  if not K_SelectFolderNew( 'Select export Folder', FPath ) then goto LExit;

  FPath := IncludeTrailingPathDelimiter(FPath);

  with N_CM_MainForm do
  begin
    if Length(CMMAllSlidesToOperate) <> 1 then
    begin
      N_Dump1Str( 'aMediaExport3D precaution 1' );
      goto LExit;
    end;

    FSlide := CMMAllSlidesToOperate[0];
    with FSlide.P.CMSDB do
// 2020-07-28 add Capt3DDevObjName <> ''   if not (cmsfIsImg3DObj in CMSDB.SFlags) or
// 2020-07-28 add Capt3DDevObjName <> ''      (CMSDB.Capt3DDevObjName <> '') then
// 2020-09-25 add new condition for Dev3D objs
    if not ( (cmsfIsImg3DObj in SFlags) and
             ((Capt3DDevObjName = '') or (MediaFExt = '')) ) then
    begin // in this case action really is disabled
      N_Dump1Str( 'aMediaExport3D precaution 2' );
      goto LExit;
    end;

    Folder3D := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( FSlide ) +
                   K_CMSlideGetImg3DFolderName( FSlide.ObjName );
    if not DirectoryExists( Folder3D ) then
    begin
    // Show Message
      CMMImg3DFolderAbsentDlg(Folder3D);
      goto LExit;
    end;

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    Res := K_CMExport3DObj( FSlide, FPath, Folder3D, AllCount, RCount, FSize );
    if Res = 1 then
    begin
      K_CMShowMessageDlg(  'It is not proper 3D object for export',
                            mtError );
      goto LExit;
    end
    else

    CMMFShowStringByTimer( format( ' %d of %d files (total size %d) are copied to %s ',
                           [RCount, AllCount, FSize, FPath] ) );
    Screen.Cursor := SavedCursor;
  end; // with N_CM_MainForm do

LExit: //*****
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aMediaExport3DExecute

    //********* Objects (Drawings) Actions

//****************************************** TN_CMResForm.aObjDeleteExecute ***
// Delete Selected Object in Active Editor Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjDelete Action handler
//
procedure TN_CMResForm.aObjDeleteExecute( Sender: TObject );
label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
LExit:
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not CMMFActiveEdFrame.DeleteVObjSelected( TRUE ) then
    begin
      aEditPointExecute( nil );
      goto LExit;
    end;

    with CMMFActiveEdFrame do
    begin // Clear VObj Creation Context
      if EdAddVObj1RFA.CreateVObjFlag then
      begin // Clear Calibration Mode
        EdAddVObj1RFA.LineCalibrateFlag := FALSE;
        EdAddVObj1RFA.PolyLineCalibrateFlag := FALSE;
      end;
      EdAddVObj1RFA.CreateVObjFlag := FALSE;
      EdAddVObj2RFA.CreateVObjFlag := FALSE;

      if EdMoveVObjRFA.CreateVObjMode <> 0 then
      begin
        EdMoveVObjRFA.CreateVObjMode := 0;
        EdMoveVObjRFA.MovePointMode := false;
      end;
      EdMoveVObjRFA.MoveObjMode := false; //!!! 2013-11-07 to prevent crash after deteion by DEl WMKey
    end;

    aEditPointExecute( nil );
    // Disable Actions which are enabled for selected object 
    N_CMResForm.aObjChangeAttrs.Enabled := FALSE;
    N_CMResForm.aObjDelete.Enabled := FALSE;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aObjDeleteExecute

//*************************************** TN_CMResForm.aObjPolylineMExecute ***
// Start Creating Measure Polyline (Set Active Editor Frame in Add Measure Polyline Mode)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjPolylineM Action handler
//
procedure TN_CMResForm.aObjPolylineMExecute( Sender: TObject );
label LExit;
begin
  if Sender <> nil then
    if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then
    begin
LExit:
      if Sender <> nil then begin
//        Dec(K_CMD4WWaitApplyDataCount);
//        K_CMD4WWaitApplyDataFlag := false;
        N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
        AddCMSActionFinish( Sender );
      end;

      Exit;
    end;

    with CMMFActiveEdFrame, EdSlide, P()^ do
    if (aObjPolylineM = Sender)                 and
       not (cmsfUserCalibrated in CMSDB.SFlags) and
       not (cmsfAutoCalibrated in CMSDB.SFlags) and
       not CMSSkipNotCalibratedWarning then
    begin
      CMSSkipNotCalibratedWarning := (cmsfProbablyCalibrated in CMSDB.SFlags);

      if not CMSSkipNotCalibratedWarning then
      begin
        CMMSetMUFRectByActiveFrame();
        K_CMShowMessageDlg1( K_CML1Form.LLLPolyline1.Caption,
//               'This object is not calibrated. Please do the calibration of this object first'
                 mtWarning );
        CMMRestoreMUFRect();
        goto LExit;
      end   // if not CMSSkipNotCalibratedWarning then
      else
      begin // if CMSSkipNotCalibratedWarning then
        CMMSetMUFRectByActiveFrame();
        K_CMShowMessageDlg1( K_CML1Form.LLLPolyline2.Caption +
                             K_CML1Form.LLLPressOKToContinue.Caption,
//                           'This object has been imported from the external source. The measurement can be inaccurate. To guarantee the accurate measurement it is recommended to calibrate this object first. Press OK to continue'
                             mtWarning );
        CMMRestoreMUFRect();
      end; // if CMSSkipNotCalibratedWarning then
    end; // if (aObjPolylineM = Sender) ...

    if not aObjShowHide.Checked then
    begin
      aObjShowHide.Checked := TRUE;
      aObjShowHideExecute(Sender);
    end;

    CMMFActiveEdFrame.PopupMenu := EdFrCrLinePopupMenu;

    with CMMFActiveEdFrame, RFrame do
    begin
      EdAddVObj1RFA.ActEnabled := TRUE;
      EdAddVObj1RFA.AddMode := 1;
      RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys, rfafScrollCoords];
      EdViewEditMode := cmrfemCreateVObj1;
    end;

    if Sender <> nil then
      CMMFShowString( K_CML1Form.LLLObjEdit4.Caption
//        'Click at polyline start vertex'
                     );
  end; // with N_CM_MainForm do

  if Sender <> nil then
    AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjPolylineMExecute

//**************************************** TN_CMResForm.aObjPolylineExecute ***
// Start Creating Polyline (Set Active Editor Frame in Add Polyline Mode)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjPolyline Action handler
//
procedure TN_CMResForm.aObjPolylineExecute( Sender: TObject );
begin
  aObjPolylineMExecute( Sender );
  with N_CM_MainForm.CMMFActiveEdFrame do
    EdAddVObj1RFA.AddMode := 0;
end; // end of TN_CMResForm.aObjPolylineExecute

//**************************************** TN_CMResForm.aObjFreeHandExecute ***
// Start Creating FreeHand Line (Set Active Editor Frame in Add Polyline Mode)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjPolyline Action handler
//
procedure TN_CMResForm.aObjFreeHandExecute( Sender: TObject );
begin
  aObjPolylineMExecute(Sender);
  with N_CM_MainForm.CMMFActiveEdFrame do
    EdAddVObj1RFA.AddMode := 3;
end; // end of TN_CMResForm.aObjFreeHandExecute

//**************************************** TN_CMResForm.aObjArrowLineExecute ***
// Start Creating Arrow line (Set Active Editor Frame in Add Arrowline Mode)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjArrowLine Action handler
//
procedure TN_CMResForm.aObjArrowLineExecute( Sender: TObject );
begin
//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
//  exit;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  aObjPolylineMExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.AddMode := 4;
    CMMFShowString( K_CML1Form.LLLObjEdit5.Caption
//      'Click at arrow start vertex'
                   );
  end;
  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjArrowLineExecute

//***************************************** TN_CMResForm.aObjRectangleLineExecute ***
// Add Rectangle Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjRectangle Action handler
//
procedure TN_CMResForm.aObjRectangleLineExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aObjPolylineMExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.AddMode := 5;
    CMMFShowString( K_CML1Form.LLLObjEdit6.Caption
    //              'Click at rectangle start position'
                   );
  end;
  AddCMSActionFinish( Sender );

end; // end of TN_CMResForm.aObjRectangleLineExecute

//***************************************** TN_CMResForm.aObjEllipseLineExecute ***
// Add Ellipse Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjEllipse Action handler
//
procedure TN_CMResForm.aObjEllipseLineExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aObjPolylineMExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.AddMode := 6;
    CMMFShowString( K_CML1Form.LLLObjEdit7.Caption
//         'Click at ellipse start position'
                   );
  end;
  AddCMSActionFinish( Sender );

end; // end of TN_CMResForm.aObjEllipseLineExecute


//************************************** TN_CMResForm.aObjFinishLineExecute ***
// Finish Creating Polyline
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjFinishLine Action handler
//
procedure TN_CMResForm.aObjFinishLineExecute( Sender: TObject );
begin
  aEditPointExecute( nil );

// !!! This Code needed for Windows 7 !!!
// In Windows 7 after Popup Menu called by Right Mouse Click
// no event is raised in Rast1Fr to finish current New Line
// This code is event emulation to finish current New Line
// !!! This Code needed for Windows 7 !!!
  with N_CM_MainForm do
    if CMMFCheckBSlideExisting() then
      with CMMFActiveEdFrame.RFrame do
      begin
        N_Dump2Str( '!!! Before Finish Line RF MouseDown Event Emulation ' );
        CHType    := htMouseDown;   // Handler Type
        RFExecAllSGroupsActions();
        CHType := htNotDef;
        N_Dump2Str( '!!! After Finish Line RF MouseDown Event Emulation' );
      end;
end; // end of TN_CMResForm.aObjFinishLineExecute

//*************************************** TN_CMResForm.aObjAngleNormExecute ***
// Start Creating Normal Angle
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjAngleNorm Action handler
//
procedure TN_CMResForm.aObjAngleNormExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    if not aObjShowHide.Checked then begin
      aObjShowHide.Checked := TRUE;
      aObjShowHideExecute( Sender );
    end;

    with CMMFActiveEdFrame, RFrame do
    begin
      CMMFActiveEdFrame.PopupMenu := EdFrCrLinePopupMenu;
      EdAddVObj2RFA.ActEnabled := TRUE;
      EdAddVObj2RFA.AddMode := 0;
      RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys, rfafScrollCoords];
      EdViewEditMode := cmrfemCreateVObj2;
    end;

    CMMFShowStringByTimer( K_CML1Form.LLLObjEdit8.Caption
//      'Click at Angle Start Vertex'
                         );
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjAngleNormExecute

//*************************************** TN_CMResForm.aObjAngleFreeExecute ***
// Start Creating Free Angle
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjAngleFree Action handler
//
procedure TN_CMResForm.aObjAngleFreeExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aObjAngleNormExecute(Sender);
  N_CM_MainForm.CMMFActiveEdFrame.EdAddVObj2RFA.AddMode := 1;

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjAngleFreeExecute

//***************************************** TN_CMResForm.aObjTextBoxExecute ***
// Add TextBox Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjTextBox Action handler
//
procedure TN_CMResForm.aObjTextBoxExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aObjPolylineMExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.AddMode := 2; // Set Text Annotation Add Mode

    CMMFShowString( K_CML1Form.LLLObjEdit9.Caption
//       'Click at Text position'
        );
  end;

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjTextBoxExecute

//********************************************* TN_CMResForm.aObjDotExecute ***
// Add Dot Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjTextBox Action handler
//
procedure TN_CMResForm.aObjDotExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aObjPolylineMExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.AddMode := 7; // Set Dot Annotation Add Mode

    EdMoveVObjRFA.SkipNextMouseDown := FALSE;
    CMMFShowString( K_CML1Form.LLLObjEdit28.Caption
//       'Click at Text position'
        );
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aObjDotExecute

procedure CTAExcute(Sender: TObject; Ind : Integer );
begin
  N_CMResForm.aObjTextBoxExecute( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdAddVObj1RFA.CTASectName := K_CMVobjCTAGetMemIniContext( Ind, EdAddVObj1RFA.CTAUseMode );
    if EdAddVObj1RFA.CTAUseMode < 100 then // Change Status text if already define annotation is used
      CMMFShowString( format( '%s (%s)',
        [K_CML1Form.LLLObjEdit9.Caption, K_CML1Form.LLLObjEdit27.Caption] )
  //       'Click at Text position (Click + Shift to modify Text attributes)'
          );
  end;
end; // procedure CTAExcut

//******************************************** TN_CMResForm.aObjCTA1Execute ***
// Add Customizable TextBox Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCTA1 Action handler
//
procedure TN_CMResForm.aObjCTA1Execute(Sender: TObject);
begin
  CTAExcute( Sender, 1 );
end; // procedure TN_CMResForm.aObjCTA1Execute

//******************************************** TN_CMResForm.aObjCTA2Execute ***
// Add Customizable TextBox Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCTA2 Action handler
//
procedure TN_CMResForm.aObjCTA2Execute(Sender: TObject);
begin
  CTAExcute( Sender, 2 );
end; // procedure TN_CMResForm.aObjCTA2Execute

//******************************************** TN_CMResForm.aObjCTA3Execute ***
// Add Customizable TextBox Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCTA3 Action handler
//
procedure TN_CMResForm.aObjCTA3Execute(Sender: TObject);
begin
  CTAExcute( Sender, 3 );
end; // procedure TN_CMResForm.aObjCTA3Execute

//******************************************** TN_CMResForm.aObjCTA4Execute ***
// Add Customizable TextBox Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCTA2 Action handler
//
procedure TN_CMResForm.aObjCTA4Execute(Sender: TObject);
begin
  CTAExcute( Sender, 4 );
end; // procedure TN_CMResForm.aObjCTA4Execute

//***************************************** TN_CMResForm.aObjRectangleOldExecute ***
// Add Rectangle Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjRectangle Action handler
//
procedure TN_CMResForm.aObjRectangleOldExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
{}
  aEditPointExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    EdMoveVObjRFA.CreateVObjMode := 1;
    CMMFShowString( K_CML1Form.LLLObjEdit6.Caption
//      'Click at Rectangle start position'
                   );
  end;
{}
  AddCMSActionFinish( Sender );

end; // end of TN_CMResForm.aObjRectangleOldExecute

//***************************************** TN_CMResForm.aObjEllipseExecute ***
// Add Ellipse Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjEllipse Action handler
//
procedure TN_CMResForm.aObjEllipseOldExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
{}
  aEditPointExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    EdMoveVObjRFA.CreateVObjMode := 2;
    CMMFShowString( K_CML1Form.LLLObjEdit10.Caption
//      'Click at Ellipse start position'
                   );
  end;
{}
  AddCMSActionFinish( Sender );

end; // end of TN_CMResForm.aObjEllipseExecute


//***************************************** TN_CMResForm.aObjArrowOldExecute ***
// Add Arrow Object
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjArrow Action handler
//
procedure TN_CMResForm.aObjArrowOldExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
{}
  aEditPointExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    EdMoveVObjRFA.CreateVObjMode := 3;
    CMMFShowString( K_CML1Form.LLLObjEdit11.Caption
//         'Click at Arrow start position'
                   );
  end;
{}
  AddCMSActionFinish( Sender );

end; // end of TN_CMResForm.aObjArrowOldExecute

//************************************* TN_CMResForm.aObjChangeAttrsExecute ***
// Change Object Attributes
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjChangeAttrs Action handler
//
procedure TN_CMResForm.aObjChangeAttrsExecute( Sender: TObject );
var
  UDComp : TN_UDBase;
  UDOwnerChild0 : TN_UDBase;
  ChangedAttrsFlag : Boolean;
  Info : string;
  EmptyTextResult : Boolean;

label LExit;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    UDComp := EdVObjSelected;

    UDOwnerChild0 := UDComp.Owner.DirChild(1);

    Info := UDComp.ObjName;
    if (UDComp is TN_UDParaBox) and
       ((UDOwnerChild0 is TN_UDPolyline) or
        (UDOwnerChild0 is TN_UDArc))then
    begin
      UDOwnerChild0 := UDComp.Owner; // Some Measure Text
      Info := 'Measure ' + Info;
    end
    else
      UDOwnerChild0 := nil;          // Annotaion Text

    K_CMSPCAddVObj( 'Start ' + Info + ' Attrs Edit' );
    CMMSetMUFRectByActiveFrame();
    if UDComp.ObjName[1] = 'Z' then
    begin
      ChangedAttrsFlag := K_CMSFlashlightAttrsDlg( UDComp );
    end
    else
    if UDComp.ObjName[1] = 'D' then
    begin
      UDComp := UDComp.DirChild(2); // Change Edit component to UDText component
      ChangedAttrsFlag := K_CMSlideTextAttrsDlg( RFrame, EmptyTextResult, FALSE, UDComp, UDComp.Owner );
    end
    else
    if UDComp.ObjName[1] = 'T' then
    begin
      ChangedAttrsFlag := K_CMSlideTextAttrsDlg( RFrame, EmptyTextResult, FALSE, UDComp, UDOwnerChild0 );
      if EmptyTextResult then
      begin
        DeleteVObjSelected(TRUE);
        goto LExit;
      end;

      if ChangedAttrsFlag then
      begin
        K_CMSVObjTextPosRebuild( RFrame, TN_UDParaBox(UDComp), [cmtpfSkipFinalShow] );
      end;
    end
    else
      ChangedAttrsFlag := K_CMSlideDrawAttrsDlg(UDComp, RFrame);
    CMMRestoreMUFRect();

    if ChangedAttrsFlag then
      CMMFFinishVObjEditing( aObjChangeAttrs.Caption,
                 K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                      Ord(K_shVOActEdAttrs),
                      Ord( K_CMEDAccess.EDAGetVObjHistType( UDComp ) ) ) )
    else
      N_Dump2Str( 'Cancel ' + Info + ' Attrs Edit' );

  end;

LExit:
  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjChangeAttrsExecute

//*************************************** TN_CMResForm.aObjCalibrate1Execute ***
// Calibrate Image by created line segment and set it's size
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCalibrate1 Action handler
//
procedure TN_CMResForm.aObjCalibrate1Execute( Sender: TObject );
//var
//  UndoCapt : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CalibrateCurActiveSlide( 0 );

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjCalibrate1Execute

//*************************************** TN_CMResForm.aObjCalibrateNExecute ***
// Calibrate Image by created polyline and set it's size
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCalibrateN Action handler
//
procedure TN_CMResForm.aObjCalibrateNExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CalibrateCurActiveSlide( 1 );

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjCalibrateNExecute

//*************************************** TN_CMResForm.aObjCalibrateDPIExecute( ***
// Calibrate Image by resolution set
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjCalibrateDPI Action handler
//
procedure TN_CMResForm.aObjCalibrateDPIExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  CalibrateCurActiveSlide( 2 );

  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjCalibrateDPIExecute


//**************************************** TN_CMResForm.aObjShowHideExecute ***
// Show/Hide Objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjShowHide Action handler
//
procedure TN_CMResForm.aObjShowHideExecute( Sender: TObject );
var
  PSkipSelf : PByte;
label LExit;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then begin
LExit:
//      Dec(K_CMD4WWaitApplyDataCount);
//      K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;
    with CMMFActiveEdFrame do begin
      if EdSlide = nil then goto LExit;

      ChangeSelectedVObj( 0 ); // To prevent Access Violation Error with MagnifyTool
      with EdSlide, P()^ do begin
        PSkipSelf := GetPMeasureRootSkipSelf;
        if aObjShowHide.Checked then begin
          Exclude( CMSRFlags, cmsfHideDrawings );
          PSkipSelf^ := 0
        end else begin
          Include( CMSRFlags, cmsfHideDrawings );
          PSkipSelf^ := 1;
        end;
      end;
      RFrame.RedrawAllAndShow();
      RebuildVObjsSearchList();
      CMMFSelectThumbBySlide( EdSlide );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // end of TN_CMResForm.aObjShowHideExecute


//**************************************** TN_CMResForm.aObjFLZEllipseExecute ***
// Add Ellipse Flashlight
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aObjArrow Action handler
//
procedure TN_CMResForm.aObjFLZEllipseExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
{}
  aEditPointExecute( nil );
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    EdMoveVObjRFA.CreateVObjMode := 4;
    CMMFShowString( K_CML1Form.LLLObjEdit13.Caption
//      'Click at Flashlight resulting position or Escape to remove'
                  );
  end;
{}
  AddCMSActionFinish( Sender );
end;

    //********* DICOM Actions

//**************************************** TN_CMResForm.aDICOMExportExecute ***
// Export Marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides to Operate as DICOM  file
//
// OnExecute MainActions.aDICOMExport Action handler
//
procedure TN_CMResForm.aDICOMExportExecute(Sender: TObject);
begin
  MediaExportMarked( Sender, 1 );
end; // procedure TN_CMResForm.aDICOMExportExecute

//**************************************** TN_CMResForm.aDICOMExportExecute ***
// Export Marked Slides
//
//     Parameters
// Sender - Event Sender
//
// Export all Slides to Operate as DICOMDIR  file
//
// OnExecute MainActions.aDICOMDIRExport Action handler
//
procedure TN_CMResForm.aDICOMDIRExportExecute(Sender: TObject);
begin
  MediaExportMarked( Sender, 2 );
end; // TN_CMResForm.aDICOMDIRExportExecute

//**************************************** TN_CMResForm.aDICOMImportExecute ***
// Import media objects from DICOM Files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMImport Action handler
//
procedure TN_CMResForm.aDICOMImportExecute(Sender: TObject);
begin
  DICOMImport(Sender, N_MemIniToString( 'CMS_Main', 'DICOMImportFilter', 'All files (*.*)|*.*' ) );
end; // procedure TN_CMResForm.aDICOMImportExecute

//************************************* TN_CMResForm.aDICOMDIRImportExecute ***
// Import media objects from DICOMDIR Files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMDIRImport Action handler
//
procedure TN_CMResForm.aDICOMDIRImportExecute(Sender: TObject);
begin
  DICOMImport(Sender, 'DICOMDIR file|DICOMDIR' );
end; // procedure TN_CMResForm.aDICOMDIRImportExecute

//**************************************** TN_CMResForm.aDICOMImportExecute ***
// Import media objects from DICOM Files Folder
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMImportFolder Action handler
//
procedure TN_CMResForm.aDICOMImportFolderExecute(Sender: TObject);
begin
  DICOMImport(Sender, '' );
end; // procedure TN_CMResForm.aDICOMImportFolderExecute

//***************************************** TN_CMResForm.aDICOMQueryExecute ***
// Query/Retrieve media objects from DICOM Server
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMQuery Action handler
//
procedure TN_CMResForm.aDICOMQueryExecute(Sender: TObject);

var
  NumSlides: integer;
  BufSize: Integer;
  BufStr, TmpFilesDir: String;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if not K_CMDICOMNewFlag then
  begin
    BufSize := GetCurrentDirectory( 0, nil ); // including terminating zero
    SetLength( BufStr, BufSize );
    GetCurrentDirectory( BufSize, @BufStr[1] );
    BufStr := IncludeTrailingPathDelimiter( MidStr( BufStr, 1, BufSize-1 ) );
    TmpFilesDir := K_ExpandFileName( '(#TmpFiles#)' );
    if TmpFilesDir <> BufStr then
      SetCurrentDirectory( @TmpFilesDir[1] );

    NumSlides := K_CMDCMQueryDlg();

    if TmpFilesDir <> BufStr then
      SetCurrentDirectory( @BufStr[1] );

    if NumSlides > 0 then
    begin
      N_CM_MainForm.CMMFRebuildVisSlides();
      N_CM_MainForm.CMMFDisableActions( nil );
    end;

    N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia1.Caption,
  //                ' %d Media object(s) are imported',
                     [NumSlides] ) );
  end
  else
  if K_CMEDDBVersion >= 46 then
  begin
    NumSlides := K_CMDCMQRDlg();

    N_CM_MainForm.CMMFShowStringByTimer( format( {K_CML1Form.LLLMedia1.Caption,}
                  ' %d queries to retrieve are put to queue',
                     [NumSlides] ) );
  end
  else
    N_Dump1Str( 'Nothing to do' );

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aDICOMQueryExecute

//***************************************** TN_CMResForm.aDICOMStoreExecute ***
// Store media objects to DICOM PACS Server
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMStore Action handler
//
procedure TN_CMResForm.aDICOMStoreExecute(Sender: TObject);
var
  NumSlides: integer;
  Slides, OpenedSlides : TN_UDCMSArray;
  i, ChangedCount, NotOpenedCount, OpenedCount : Integer;

label LExit;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, K_CMEDAccess do
  begin
    NumSlides := Length(CMMAllSlidesToOperate);
    if NumSlides = 0 then
    begin
      N_Dump2Str( 'Empty source array' );
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      goto LExit;
    end;
{
    NumSlides := Length(CMMAllSlidesToOperate);
    Setlength( Slides, NumSlides );
    Ind := 0;
    for i := 0 to High(Slides) do
    begin
      if cmsfIsOpened in CMMAllSlidesToOperate[i].P.CMSRFlags then Continue;
      Slides[Ind] := CMMAllSlidesToOperate[i];
      Inc( Ind );
    end;
    SetLength( Slides, Ind );

    if NumSlides > Ind then      //'%d  opened media object(s) are skiped'
      N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLDICOM2.Caption,
//                ' %d Media object(s) are skiped',
                   [NumSlides - Ind] ) );


    if Ind = 0 then
    begin
      N_Dump2Str( 'Empty array after skip opened' );
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      goto LExit;
    end;
}
    // select changed objects
    Setlength( Slides, NumSlides );
    ChangedCount := 0;
    for i := 0 to High(Slides) do
    begin
      with CMMAllSlidesToOperate[i].P()^ do
      if not (cmsfIsOpened in CMSRFlags) or
         ( not (cmsfCurImgChanged in CMSRFlags)  and
           not (cmsfMapRootChanged in CMSRFlags) and
           not (cmsfAttribsChanged in CMSRFlags) and
           not (cmsfThumbChanged in CMSRFlags) ) then Continue;
      Slides[ChangedCount] := CMMAllSlidesToOperate[i];
      Inc( ChangedCount );
    end;

    if ChangedCount > 0 then
    begin
      EDASaveSlidesArray( @Slides[0], ChangedCount );
      N_CM_MainForm.CMMFShowStringByTimer(
                format( ' %d Media object(s) are saved',
                   [ChangedCount] ) );
    end;

    // try select not opened
    Setlength( OpenedSlides, NumSlides );

    NotOpenedCount := 0;
    OpenedCount := 0;
    for i := 0 to High(Slides) do
    begin
      with CMMAllSlidesToOperate[i].P()^ do
      if cmsfIsOpened in CMSRFlags then
      begin
        OpenedSlides[OpenedCount] := CMMAllSlidesToOperate[i];
        Inc( OpenedCount );
      end
      else
      begin
        Slides[NotOpenedCount] := CMMAllSlidesToOperate[i];
        Inc( NotOpenedCount );
      end;
    end; // for i := 0 to High(Slides) do

    if NotOpenedCount > 0 then
    begin
      K_CMSlidesLockForOpen( @Slides[0],
                                 NotOpenedCount, K_cmlrmEditImgLock );

      if LockResCount = 0 then
      begin
        N_Dump2Str( 'Empty array after lock attepmt' );
        CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
        goto LExit;
      end;
      if LockResCount < NotOpenedCount then
        N_CM_MainForm.CMMFShowStringByTimer( Format(
                  ' %d Media object(s) are opened by other user',
                     [NumSlides - LockResCount] ) );

      for i := 0 to LockResCount - 1 do
        Slides[i] := LockResSlides[i];
      NotOpenedCount := LockResCount;
    end;

    NumSlides := NotOpenedCount;
    for i := 0 to OpenedCount - 1 do
    begin
      Slides[NumSlides] := OpenedSlides[i];
      Inc(NumSlides);
    end;

  end; // with N_CM_MainForm do


  NumSlides := K_CMDCMStoreDlg( @Slides[0], NumSlides );

  if NotOpenedCount > 0 then
    K_CMEDAccess.EDAUnlockSlides(  @Slides[0], NotOpenedCount, K_cmlrmEditImgLock );

  N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLDICOM1.Caption,
//                ' %d Media object(s) store process is started',
                   [NumSlides] ) );

//  if NumSlides > 0 then // Refresh slides view
//    aViewThumbRefreshExecute( N_CMResForm.aViewThumbRefresh );


LExit: //*****
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDICOMStoreExecute

//***************************************** TN_CMResForm.aDICOMStoreExecute ***
// DICOM MWL info
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMMWL Action handler
//
procedure TN_CMResForm.aDICOMMWLExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  TK_FormCMDCMMWL.Create(Application).ShowModal;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDICOMMWLExecute

//************************************ TN_CMResForm.aDICOMCommitmentExecute ***
// Commitment of media objects in DICOM PACS
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMCommitment Action handler
//
procedure TN_CMResForm.aDICOMCommitmentExecute(Sender: TObject);
var
  NumSlides: integer;
  Slides : TN_UDCMSArray;
  i, StoredCount : Integer;

label LExit;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, K_CMEDAccess do
  begin
    NumSlides := Length(CMMAllSlidesToOperate);
    if NumSlides = 0 then
    begin
      N_Dump2Str( 'Empty source array' );
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      goto LExit;
    end;

    // Select Stored Slides
    Setlength( Slides, NumSlides );
    StoredCount := 0;
    for i := 0 to High(Slides) do
    begin
      if not (K_bsdcmsStore in CMMAllSlidesToOperate[i].CMSDCMFSet) then Continue;
      Slides[StoredCount] := CMMAllSlidesToOperate[i];
      Inc( StoredCount );
    end;

    if StoredCount = 0 then
    begin
      N_Dump2Str( 'Stored objects are absent' );
      CMMFShowStringByTimer( K_CML1Form.LLLNothingToDo.Caption );// 'Nothing to do!');
      goto LExit;
    end;
  end; // with N_CM_MainForm do

  NumSlides := K_CMDCMCommitmentDlg( @Slides[0], StoredCount );

  N_CM_MainForm.CMMFShowStringByTimer( Format(
                ' %d Media object(s) commitment process is started',
                   [NumSlides] ) );


LExit: //*****
  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aDICOMCommitmentExecute

    //********* Help Actions

procedure TN_CMResForm.aHelpContentsExecute( Sender: TObject );
//
var
  HelpFName: string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  HelpFName := K_ExpandFileName(
    N_MemIniToString( 'CMS_Main', 'HelpFName', '' ) );
  if FileExists( HelpFName ) then
    K_ShellExecute( 'Open', HelpFName );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aHelpContentsExecute

procedure TN_CMResForm.aHelpAboutExecute( Sender: TObject );
// Show CMS About Form
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TN_CMAboutForm.Create(Application) do begin
//      BFFlags := [bffToDump1];
//      BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
//  Some About Form Property := K_FormCMScan <> nil; 
    ShowModal;
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aHelpAboutExecute


procedure TN_CMResForm.aHelpRegistrationExecute(Sender: TObject);
// Show CMS Registration Form
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );

  with TK_FormCMRegister.Create(Application) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    ShowModal();
  end;

  AddCMSActionFinish( Sender );
end;


    //********* Service Actions

//********************************** TN_CMResForm.aServEditStatTableExecute ***
// View/Edit CMS Capturing Statistics Table
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServEditStatTable Action handler
//
procedure TN_CMResForm.aServEditStatTableExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TN_CMDevStatForm.Create(Application) do
  begin
    UDTable := N_CM_VideoStat;
    IncModeFlags := IncModeFlags + [K_ramColVertical];
    FDTypeName := 'TN_CMVideoStatFormDescr';
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    ShowModal;
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServEditStatTableExecute

//********************************** TN_CMResForm.aServSetVideoCodecExecute ***
// Set Prefered Video Codec
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSetVideoCodec Action handler
//
// Choose Video Codec Name from currently available Video Codecs (or 'Not Used'
// string, that means using umcompressed video) and put choosen string
// at top of N_CMSVideoComprSectName section of ini file
//
procedure TN_CMResForm.aServSetVideoCodecExecute( Sender: TObject );
var
  TopNameInd, ErrCode: integer;
  AvailableNames, GivenNames: TStringList;
  Label Fin;
begin
  if K_CMShowGUIFlag then Exit;
  AddCMSActionStart( Sender );

  AvailableNames := TStringList.Create();
  GivenNames := TStringList.Create();

  N_DSEnumFilters( CLSID_VideoCompressorCategory, '', AvailableNames, ErrCode );

  if ErrCode <> 0 then // some Error
  begin
    N_Dump2Str( Format( '   Error=%d, %s', [ErrCode,N_DSErrorString] ));
    goto Fin;
  end; // if ErrCode <> 0 then // some Error

  AvailableNames.Insert( 0, N_NotUsedStr ); // add "Not Used" string at Top

  //***** Get Compr. Names, given in Ini file
  N_MemIniToStrings( N_CMSVideoComprSectName, GivenNames );

  //***** Set TopNameInd - initially highlighted Item (GivenNames[0])
  TopNameInd := 0;
  if GivenNames.Count >= 1 then // not empty
  begin
    TopNameInd := AvailableNames.IndexOf( GivenNames[0] );
    if TopNameInd = -1 then TopNameInd := 0;
  end;

  with N_CreateEditParamsForm( 300 ) do
  begin
    AddHistComboBox( 'Available Video Compressors:', '' );

    with TComboBox(EPControls[0].CRContr) do
    begin
      Items.AddStrings( AvailableNames );
      ItemIndex := TopNameInd;
    end;

    ShowSelfModal();

    N_i := ModalResult;
    N_b := OKPressed;

    if ModalResult = mrOK then
    with EPControls[0] do
    begin
      N_SetSectionTopString( N_CMSVideoComprSectName, CRStr );
      if cmpfMenuAll in N_CM_LogFlags then
        N_Dump2Str( 'Video Codec choosen="' +  CRStr + '"' );
    end;
  end; // with N_CreateEditParamsForm( 300 ) do

  Fin: //***************************
  GivenNames.Free();
  AvailableNames.Free();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSetVideoCodecExecute

//********************************** TN_CMResForm.aServFilesHandlingExecute ***
// Image and Video Files Handling
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServFilesHandling Action handler
//
// Handling Image and Video Files Location Attributes
//
procedure TN_CMResForm.aServFilesHandlingExecute(Sender: TObject);
var
  BForm : TN_BaseForm;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  // Check Password is needed
{
  if K_CMEDAccess.SlidesCRFC.RootFolder = '' then
    with TK_FormCMSFilesHandling.Create( Self ) do ShowModal
  else
    with TK_FormCMSFPathChange.Create( Self ) do ShowModal;
}

  if not K_CMEnterpriseModeFlag then
    BForm := TK_FormCMSFilesHandling.Create( Application )
  else
    BForm := TK_FormCMSFilesHandlingE.Create( Application );

  with BForm do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    ShowModal;
  end;
  N_CM_MainForm.CMMFDisableActions( nil );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServFilesHandlingExecute

//************************************ TN_CMResForm.aServImportExtDBExecute ***
// Import Data from External DB (After conversion from other application)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServImportExtDB Action handler
//
// Implements Import Data from External DB
//
procedure TN_CMResForm.aServImportExtDBExecute( Sender: TObject );
{
var
  OpenDialog: TOpenDialog;
  ImpFiles : TStringList;
  i : Integer;
  ImpCount : Integer;
  ImpFNames : string;
  FPath, FName : string;
  SavedCursor : TCursor;
  Label Fin;

  procedure AddImpFileName( const AFName : string );
  begin
    if ImpFNames <> '' then begin
      if ImpCount = 1 then         // 2-nd file - more then one
        ImpFNames := FPath + ' files ' + ExtractFileName(ImpFNames);
      ImpFNames := ImpFNames + ', ' + AFName // 3-d and all next
    end else
      ImpFNames := FPath + AFName; // 1-st or single file
  end;
}
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
{
  OpenDialog := TOpenDialog.Create( Application );
  with OpenDialog do begin
    InitialDir := K_ExpandFileName( N_MemIniToString( 'CMS_Main', 'LastImportFromExtDBDir', 'c:\' ) );
//    FileName := WFName;
    Filter := 'Media data files (*.xml)|slides*.xml|All data files (*.xml)|*.xml|All files (*.*)|*.*';
    FilterIndex := 1;
//    Options := Options + [ofEnableSizing, ofAllowMultiSelect];
    Options := Options + [ofEnableSizing];
//    Title := 'Import from External DB';
    Title := 'Select needed Slides.xml file';
    ImpFiles := nil;
    if Execute and (Files.Count > 0) then begin
      ImpFiles := TStringList.Create;
      ImpFiles.Assign(Files);
    end;
    Free;
  end;

  if (ImpFiles = nil) or (ImpFiles.Count = 0) then goto Fin;

  ImpFNames := '';
  ImpCount := 0;
  FPath := ExtractFilePath( ImpFiles[0]);
  N_StringToMemIni( 'CMS_Main', 'LastImportFromExtDBDir', FPath );
  // Search for Provders and Import if found  (for standalone)

  // Search for Patients and Import if found  (for standalone)

  // Search for Slides and Import if found
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  // Disable CMS UI
  N_CM_MainForm.CMMSetUIEnabled( FALSE );
//  N_CM_MainForm.CMMAllActsDisabled := TRUE;
//  N_CM_MainForm.CMMFDisableActions( Self );
//  N_AppSkipEvents := TRUE;
//  K_CMD4WSkipCloseUI := TRUE;

  for i := 0 to ImpFiles.Count - 1 do begin
    FName := ExtractFileName( ImpFiles[i] );
    if not SameText( ExtractFileExt( FName ), '.xml' ) then Continue;
//    if SameText( ExtractFileName( ImpFiles[i] ), 'slides.xml' ) then begin
    if K_StrStartsWith( 'slides', FName, TRUE, 6 ) then begin
      if K_CMSImportFromExtDB( ImpFiles[i] ) then begin
        AddImpFileName( 'slides.xml' );
        Inc(ImpCount);
      end;

      if K_CMD4WAppFinState then goto Fin;

      break;
    end;
  end;

  Screen.Cursor := SavedCursor;

  // Enable CMS UI
  N_CM_MainForm.CMMSetUIEnabled( TRUE );
//  K_CMD4WSkipCloseUI := FALSE;
//  N_AppSkipEvents := FALSE;
//  N_CM_MainForm.CMMAllActsDisabled := FALSE;
//  N_CM_MainForm.CMMFDisableActions( Self );

  if ImpFNames = '' then
    ImpFNames := 'Nothing to do'
  else
    ImpFNames := 'Finish Data Import from ' + ImpFNames;

  if ImpCount > 1 then
    N_CM_MainForm.CMMFShowStringByTimer( ImpFNames );

  ImpFiles.Free;
  Fin: //****
}
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServImportExtDBExecute

//********************************* TN_CMResForm.aServImportExtDBDlgExecute ***
// Import Data from External DB (After conversion from other application)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServImportExtDBDlg Action handler
//
// Implements Import Data from External DB
//
procedure TN_CMResForm.aServImportExtDBDlgExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMSlideImportDlg( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServImportExtDBDlgExecute


//************************************ TN_CMResForm.aServXRAYStreamLineExecute ***
// XRAY Capturing StreamLine mode control
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServXRAYStreamLine Action handler
//
// Implements Control of XRAY Capturing StreamLine mode
//
procedure TN_CMResForm.aServXRAYStreamLineExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMXrayCaptStreamLineMode := aServXRAYStreamLine.Checked;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServXRAYStreamLineExecute

//***************************** TN_CMResForm.aServProcessClientTasksExecute ***
// Process Client Tasks
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServProcessClientTasks Action handler
//
// Implements Client Tasks Processing before aServECacheCheck Action
//
procedure TN_CMResForm.aServProcessClientTasksExecute(Sender: TObject);
begin
  Inc(K_CMD4WWaitApplyDataCount);

  // Add To ECache Slides from not finished client tasks
  if K_CMScanIsInstalled then
    K_CMScanProcessClientTasks()
  else
  // Set Flag to repeat K_CMScanProcessClientTasks when Client PC Exchange folder will be Auto Detected
    K_CMScanProcessClientTasksFlag := K_CMScanDataPathOnClientPCAuto;

  Dec(K_CMD4WWaitApplyDataCount);
end; // procedure TN_CMResForm.aServProcessClientTasksExecute

//************************************ TN_CMResForm.aServECacheCheckExecute ***
// ECache Check and Recovery Dialog Show
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServECacheCheck Action handler
//
// Implements Control of ECache Check and Recovery Dialog Show
//
procedure TN_CMResForm.aServECacheCheckExecute(Sender: TObject);
begin
  Inc(K_CMD4WWaitApplyDataCount);

  if K_CMECacheFilesProcessDlg() then
  begin
    K_CMEDAccess.EDAGetCurSlidesSet();
    N_CM_MainForm.CMMFRebuildVisSlides();
  end;

  Dec(K_CMD4WWaitApplyDataCount);
end; // procedure TN_CMResForm.aServECacheCheckExecute

//************************************ TN_CMResForm.aServECacheAllShowExecute ***
// ECache all Objects Show Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServECacheAllShow Action handler
//
// Implements Control of ECache All Objects Show Dialog
//
procedure TN_CMResForm.aServECacheAllShowExecute(Sender: TObject);
begin
  K_CMECacheFilesShowDlg();
end; // procedure TN_CMResForm.aServECacheAllShowExecute

//************************************ TN_CMResForm.aServECacheAllShowExecute ***
// ECache Objects Recovery Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServECacheAllShow Action handler
//
// Implements Control of ECache All Objects Recovery Dialog
//
procedure TN_CMResForm.aServECacheRecoveryExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if K_CMCacheMediaRecoveryDlg( ) then
    aViewThumbRefreshExecute(Sender);

  AddCMSActionFinish( Sender );
end;

//********************************** TN_CMResForm.aServSlideHistShowExecute ***
// Slide History Show Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSlideHistShow Action handler
//
// Implements Control of Slide History Show Dialog
//
procedure TN_CMResForm.aServSlideHistShowExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm do
    if CMMFActiveEdFrame.EdSlide <> nil then
      K_CMSlideHistoryShowDlg( CMMFActiveEdFrame.EdSlide );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSlideHistShowExecute

//********************************* TN_CMResForm.aServShowMessageDlgExecute ***
// Show Message Dialog by Timer
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServShowMessageDlg Action handler
//
// Implements Show Message Dialog by Timer Event
//
procedure TN_CMResForm.aServShowMessageDlgExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );
  K_CMShowMessageDlg( K_CMShowMessageDlgText, K_CMShowMessageDlgType,
                      K_CMShowMessageDlgButtons, K_CMShowMessageDlgSkipLog,
                      K_CMShowMessageDlgCaption, K_CMShowMessageDlgShowInterval );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServShowMessageDlgExecute

//******************************** TN_CMResForm.aServSetCaptureDelayExecute ***
// Show Capture Delay Setting Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSetCaptButDelay Action handler
//
// Set K_CMCaptButDelay - Capture Delay in seconds
//
procedure TN_CMResForm.aServSetCaptureDelayExecute( Sender: TObject );
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMChangeCaptButDelay();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSetCaptureDelayExecute

//********************************** TN_CMResForm.aServImportReverseExecute ***
// Reverse last import after conversion
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServImportReverse Action handler
//
procedure TN_CMResForm.aServImportReverseExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMReverseImportConfirmDlg( ) then
    K_CMReverseImportDlg( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServImportReverseExecute

//******************************* TN_CMResForm.aServImportChngAttrsExecute ***
// Change last import after conversion slides attributes
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServImportChngAttrs Action handler
//
procedure TN_CMResForm.aServImportChngAttrsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMSlideImportChangeAttrsDlg( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServImportChngAttrsExecute

//********************************** TN_CMResForm.aServConvCMSImgToBMP1Execute ***
// Convert CMS Image file to BMP
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServConvCMSImgToBMP1 Action handler
//
procedure TN_CMResForm.aServConvCMSImgToBMP1Execute(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  WFName : string;
  Buf : TN_BArray;
  Buf1 : TN_BArray;
  DFile: TK_DFile;
  UDDIB : TN_UDBase;
  ConvFiles : TStringList;
  i, CCount : Integer;
  DIB1, DIB2: TN_DIBObj;
  UncompressedCount : Integer;
  PData : Pointer;
  DSize : Integer;
  RIEncodingInfo : TK_RIFileEncInfo;

label Cont;

  procedure DumpAndMessage( const AMesText, ADumpText : string );
  begin
    K_CMShowMessageDlg( AMesText + #13#10 + WFName,  mtWarning );
    N_Dump1Str( 'ConvToFile >> ' + WFName + ADumpText );
  end;

  procedure SaveToFile( ADIB : TN_DIBObj );
  var
    ConvFName : string;
  begin
    if ADIB.DIBExPixFmt <= epfGray8 then
    begin
      ConvFName := ChangeFileExt(WFName, '.bmp');
      ADIB.SaveToBMPFormat( ConvFName )
    end
    else
    begin
      ConvFName := ChangeFileExt(WFName, '.png');
      K_RIObj.RIClearFileEncInfo( @RIEncodingInfo );
      RIEncodingInfo.RIFileEncType := rietNotDef;
      if K_RIObj.RISaveDIBToFile( ADIB, ConvFName, @RIEncodingInfo ) <> rirOK then
      begin
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP6.Caption,
                        'RISaveDIBToFile fails K_RIObj=' + K_RIObj.ClassName );
        Exit;
      end;
    end;
    N_Dump1Str( 'ConvToFile >> ' + ConvFName );
    Inc(CCount);
  end;

  procedure ConvToBMP( ADIB : TN_DIBObj );
  begin
    ADIB.SaveToBMPFormat( ChangeFileExt(WFName, '.bmp') );
    N_Dump1Str( 'ConvToFile >> ' + WFName );
    Inc(CCount);
  end;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  OpenDialog := TOpenDialog.Create( Application );
  OpenDialog.Filter := ' CMI files (*.cmi)|*.CMI|' +
                       ' ECD files (*.ecd)|*_R.ECD|' +
                       ' CMSI files (*.cmsi)|*.CMSI|' +
                       ' All files (*.*)|*.*|';
  OpenDialog.InitialDir := K_ExpandFileName( N_MemIniToString( 'CMS_Main', 'ConvToBMPPath', '' ) );
Cont:
  with OpenDialog do begin
    Options := Options + [ofEnableSizing,ofAllowMultiSelect];
    Title := K_CML1Form.LLLConvImgToBMP1.Caption;
//    Title := 'CMS Image file conversion';
    ConvFiles := TStringList.Create;
    if Execute and (Files.Count > 0) then
    begin
      ConvFiles.Assign(Files);
      N_StringToMemIni( 'CMS_Main', 'ConvToBMPPath',
        IncludeTrailingPathDelimiter( ExtractFilePath( ConvFiles[0] ) ) );
    end
    else
    begin
      OpenDialog.Free;
      ConvFiles.Free;
      AddCMSActionFinish( Sender );
      Exit;
    end;
  end;

  CCount := 0;
  for i := 0 to ConvFiles.Count -1 do
  begin
    WFName := ConvFiles[i];
    if SameText( ExtractFileExt(WFName), '.cmsi' ) then
    begin
      try
        DIB2 := nil;
        DIB2 := N_CreateDIBFromCMSI( WFName );
        DIB1 := DIB2;
        if DIB2.DIBExPixFmt = epfGray16 then begin
        // 16-bit Grey
          DIB2 := TN_DIBObj.Create( DIB1 , DIB1.DIBRect, pfCustom, epfGray8 );
//          DIB2 := N_CreateGray8DIBFromGray16( DIB1 );
          DIB1.Free;
        end;
        ConvToBMP( DIB2 );
      except
        on E: Exception do begin
          DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' format error' );
//          DumpAndMessage( 'File has not proper format ', ' format error' );
        end;
      end;
      FreeAndNil( DIB2 );
    end
    else
    begin
{
      if K_DFOpen( WFName, DFile, [] ) then
      begin
        DumpAndMessage( 'Couldn''t open file ', ' open error >> ' +
                    K_DFGetErrorString( DFile.DFErrorCode ) );
        Continue;
      end;
}
      if not K_DFOpen( WFName, DFile, [K_dfoSkipExceptions] ) then
      begin
        if DFile.DFErrorCode <> K_dfrErrBadDataSize then
        begin
//          DumpAndMessage( 'Couldn''t open file ', ' open error >> ' +
          DumpAndMessage( K_CML1Form.LLLConvImgToBMP3.Caption, ' open error >> ' +
                      K_DFGetErrorString( DFile.DFErrorCode ) );
          FreeAndNil(DFile.DFStream);
          Continue;
        end
        else

//          DumpAndMessage( 'Open file error. Try to continue covertion.', ' open error >> ' +
          DumpAndMessage( K_CML1Form.LLLConvImgToBMP4.Caption, ' open error >> ' +
                      K_DFGetErrorString( DFile.DFErrorCode ) );
      end;

      SetLength( Buf, DFile.DFPlainDataSize );
      PData := @Buf[0];
      DSize := DFile.DFPlainDataSize;
      K_DFReadAll( @Buf[0], DFile );

      UncompressedCount := N_GetUncompressedSize(PData, DSize );
      if UncompressedCount <> -1 then
      begin // Uncompress Data
        if UncompressedCount > Length(Buf1) then
          SetLength(Buf1, UncompressedCount);
        UncompressedCount := N_DecompressMem(PData, DSize, @Buf1[0],
          UncompressedCount);
        if UncompressedCount <> -1 then
        begin
          PData := @Buf1[0];
          DSize := UncompressedCount;
        end
        else
        begin
          DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' uncompression error' );
//          DumpAndMessage( 'File has not proper format ', ' uncompression error' );
          Continue;
        end;
      end;


      UDDIB := K_CMCreateUDDIBBySData( PData, DSize );
      if UDDIB = nil then
      begin
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' deserialization error' );
//        DumpAndMessage( 'File has not proper format ', ' deserialization error' );
        Continue;
      end;

      try
        TN_UDDIB(UDDIB).LoadDIBObj();
        SaveToFile( TN_UDDIB(UDDIB).DIBObj );
//        ConvToBMP( TN_UDDIB(UDDIB).DIBObj );
      except
        on E: Exception do begin
          DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' LoadDIBObj error >> ' + E.Message );
//          DumpAndMessage( 'File has not proper format ', ' LoadDIBObj error' );
        end;
      end;

      UDDIB.Free;
    end;
  end;

  K_CMShowMessageDlg( format( K_CML1Form.LLLConvImgToBMP5.Caption,
//         '%d of %d files are converted to BMP',
           [CCount,ConvFiles.Count] ),  mtInformation );
  goto Cont;

end; // procedure TN_CMResForm.aServConvCMSImgToBMP1Execute

//********************************** TN_CMResForm.aServConvCMSImgToBMPExecute ***
// Convert CMS Image file to BMP
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServConvCMSImgToBMP Action handler
//
procedure TN_CMResForm.aServConvCMSImgToBMPExecute(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  WFName : string;
  Buf : TN_BArray;
  DFile: TK_DFile;
  UDDIB : TN_UDBase;
begin
  OpenDialog := TOpenDialog.Create( Application );
  with OpenDialog do begin
    Options := Options + [ofEnableSizing];
    Title := K_CML1Form.LLLConvImgToBMP1.Caption;
    WFName := '';
    if Execute  then
      WFName := FileName;
    OpenDialog.Free;
  end;

  if WFName = '' then Exit;
  if not K_DFOpen( WFName, DFile, [] ) then begin
    K_CMShowMessageDlg( K_CML1Form.LLLConvImgToBMP3.Caption + #13#10 +
                            WFName,  mtWarning );
    Exit;
  end;

  SetLength( Buf, DFile.DFPlainDataSize );
  K_DFReadAll( @Buf[0], DFile );
  N_SerialBuf.LoadFromMem( Buf[0], DFile.DFPlainDataSize );
  Buf := nil;
  UDDIB := K_LoadTreeFromMem( N_SerialBuf );
  if (UDDIB = nil) or not (UDDIB is TN_UDDIB) then begin
    K_CMShowMessageDlg( K_CML1Form.LLLConvImgToBMP2.Caption + #13#10 +
                            WFName,  mtWarning );
    Exit;
  end;
  if TN_UDDIB(UDDIB).DIBObj = nil then
    TN_UDDIB(UDDIB).LoadDIBObj();
  TN_UDDIB(UDDIB).DIBObj.SaveToBMPFormat( ChangeFileExt(WFName, '.bmp') );
end; // procedure TN_CMResForm.aServConvCMSImgToBMPExecute

//********************************** TN_CMResForm.aServRecoverBadCMSImgExecute ***
// Recover bad CMS Image files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRecoverBadCMSImg Action handler
//
// Check CMS Image files in given root folder and recover bad if possible.
// Replace bad files with recoverd and create BMP for visual control.
//
procedure TN_CMResForm.aServRecoverBadCMSImgExecute(Sender: TObject);
var
  FPath : string;
  RPath : string;
  BPath : string;
  WFName : string;
  DFName : string;
  Buf : TN_BArray;
  Buf1 : TN_BArray;
  DFile: TK_DFile;
  UDDIB : TN_UDBase;
  i, CCount, RCount : Integer;
  UncompressedCount : Integer;
  PData : Pointer;
  DSize : Integer;
  ReadResultFlag : Boolean;
  FilesList : TStringList;

label LExit;

  procedure ConvToBMP( ADIB : TN_DIBObj );
  begin
    ADIB.SaveToBMPFormat( ChangeFileExt(WFName, '.bmp') );
    N_Dump1Str( 'RIMG  >> Conv to BMP ' + DFName );
    Inc(CCount);
  end;

  procedure DumpAndMessage( const AMesText, ADumpText : string );
  begin
    K_CMShowMessageDlg( AMesText + #13#10 + DFName,  mtWarning );
    N_Dump1Str( 'RIMG >> ' + DFName + ADumpText );
  end;

begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  FPath := K_ExpandFileName( N_MemIniToString( 'CMS_Main', 'RestoreImgFilesPath', '' ) );
  FilesList := nil;
  if not K_SelectFolder( 'Select Image Files Folder', FPath, FPath ) then goto LExit;
  FPath := IncludeTrailingPathDelimiter(FPath);
  RPath := IncludeTrailingPathDelimiter(FPath + 'Recovered');
  BPath := IncludeTrailingPathDelimiter(FPath + 'BMP');
  N_StringToMemIni( 'CMS_Main', 'RestoreImgFilesPath', FPath );

  K_CMEDAccess.TmpStrings.Clear;
  K_ScanFilesTree( FPath, K_CMEDAccess.EDASelectDataFiles, 'RF_*.cmi' );

  N_Dump1Str( format( 'RIMG >> Start Restore Files Path "%s" Count=%d',
                            [FPath, K_CMEDAccess.TmpStrings.Count] ) );
  if K_CMEDAccess.TmpStrings.Count = 0 then goto LExit;


  CCount := 0;
  RCount := 0;
  FilesList := TStringList.Create;
  FilesList.Assign( K_CMEDAccess.TmpStrings );
  for i := 0 to FilesList.Count -1 do
  begin
    WFName := FilesList[i];
    DFName := Copy( WFName, Length(FPath) + 1, Length(WFName) );
//    if '13300\PX_13267\2012-04-19\RF_00002484.cmi' = DFName then
//    if '13400\PX_13325\2012-04-18\RF_00002478.cmi' = DFName then
//      RCount := RCount;
    if not K_DFOpen( WFName, DFile, [K_dfoSkipExceptions] ) then
    begin
      if DFile.DFErrorCode <> K_dfrErrBadDataSize then
      begin
//          DumpAndMessage( 'Couldn''t open file ', ' open error >> ' +
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP3.Caption, ' open error >> ' +
                    K_DFGetErrorString( DFile.DFErrorCode ) );
        FreeAndNil(DFile.DFStream);
        Continue;
      end
      else

//          DumpAndMessage( 'Open file error. Try to continue covertion.', ' open error >> ' +
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP4.Caption, ' open error >> ' +
                    K_DFGetErrorString( DFile.DFErrorCode ) );
    end;

    SetLength( Buf, DFile.DFPlainDataSize );
    PData := @Buf[0];
    DSize := DFile.DFPlainDataSize;
    ReadResultFlag := K_DFReadAll( @Buf[0], DFile );
    if not ReadResultFlag then
      N_Dump1Str( 'RIMG >> Read Error ' + DFName + ' ' + K_DFGetErrorString( DFile.DFErrorCode ) )
    else
      N_Dump1Str( 'RIMG >> Read ' + DFName );

    UncompressedCount := N_GetUncompressedSize(PData, DSize );
    if UncompressedCount <> -1 then
    begin // Uncompress Data
      if UncompressedCount > Length(Buf1) then
        SetLength(Buf1, UncompressedCount);
      UncompressedCount := N_DecompressMem(PData, DSize, @Buf1[0],
        UncompressedCount);
      if UncompressedCount <> -1 then
      begin
        PData := @Buf1[0];
        DSize := UncompressedCount;
      end
      else
      begin
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' uncompression error' );
//          DumpAndMessage( 'File has not proper format ', ' uncompression error' );
        Continue;
      end;
    end;


    UDDIB := K_CMCreateUDDIBBySData( PData, DSize );
    if UDDIB = nil then
    begin
      DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' deserialization error' );
//        DumpAndMessage( 'File has not proper format ', ' deserialization error' );
      Continue;
    end;

    try
      // Check Load Possibility
      TN_UDDIB(UDDIB).LoadDIBObj();


      // Convert To BPM
      if not ReadResultFlag then
      begin
        WFName := BPath + DFName;
        K_ForceFilePath( WFName );
        ConvToBMP( TN_UDDIB(UDDIB).DIBObj );
      end;

      WFName := RPath + DFName;
      K_ForceFilePath( WFName );

      K_CMGetUDDIBSData( TN_UDDIB(UDDIB), PData, DSize );
      K_CMEDAccess.EDASlideDataToFile(PData, DSize, WFName);
      Inc(RCount);
      N_Dump1Str( 'RIMG  >> Recover ' + DFName );
    except
      on E: Exception do begin
        DumpAndMessage( K_CML1Form.LLLConvImgToBMP2.Caption, ' LoadDIBObj error >> ' + E.Message );
//          DumpAndMessage( 'File has not proper format ', ' LoadDIBObj error' );
      end;
    end;

    UDDIB.Free;
  end;

  K_CMShowMessageDlg( format( '%d of %d files are recovered and %d are converted to BMP',
           [RCount,FilesList.Count,CCount] ),  mtInformation );
LExit:
  FilesList.Free;
  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aServRecoverBadCMSImgExecute

//************************************ TN_CMResForm.aServBinDumpModeExecute ***
// Set/Clear Binary dump mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServBinDumpMode Action handler
//
procedure TN_CMResForm.aServBinDumpModeExecute( Sender: TObject );
begin
  // now empty, aServBinDumpMode.Checked field is used
end; // procedure TN_CMResForm.aServBinDumpModeExecute

//************************************ TN_CMResForm.aServCloseCMSExecute ***
// Close CMS
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServCloseCMS Action handler
//
procedure TN_CMResForm.aServCloseCMSExecute(Sender: TObject);
begin
  N_CM_MainForm.CMMFAppClose( '***** Close by aServCloseCMS Action' );
end; // procedure TN_CMResForm.aServCloseCMSExecute

//************************************ TN_CMResForm.aServRemoveMarkAsDelSlidesExecute ***
// Remove from DB marked as deleted objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRemoveMarkAsDelSlides Action handler
//
procedure TN_CMResForm.aServRemoveMarkAsDelSlidesExecute(Sender: TObject);
begin
  if K_CMEDAccess is TK_CMEDDBAccess then
    TK_CMEDDBAccess(K_CMEDAccess).EDAClearMarkAsDelSlides( 100 );
end; // procedure TN_CMResForm.aServRemoveMarkAsDelSlidesExecute

//************************************ TN_CMResForm.aServRemoveLocDelFilesExecute ***
// Remove Deleted Slides Files in current Location in Enterprise Mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRemoveDelSlides Action handler
//
procedure TN_CMResForm.aServEModeRemoveLocDelFilesExecute(Sender: TObject);
begin
  if K_CMEDAccess is TK_CMEDDBAccess then
    TK_CMEDDBAccess(K_CMEDAccess).EDAClearLocDelSlides( 100 );
end; // procedure TN_CMResForm.aServRemoveLocDelFilesExecute

//************************************ TN_CMResForm.aServEFSyncExecute ***
// Synchronize Files in All Locations in Enterprise Mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServEFSync Action handler
//
procedure TN_CMResForm.aServEModeFilesSyncExecute(Sender: TObject);
begin
//  if not K_CMEnterpriseModeFlag then Exit;
  N_Dump1Str( 'Start Files Synchronization Process' );

  with TK_FormCMEFSyncProc.Create(Application) do
  begin
//    BaseFormInit( nil, '', [] );
    BaseFormInit( nil, '', [rspfPrimMonWAR,rspfCenter], [rspfPrimMonWAR,rspfCenter] );
    StartSyncMode := TRUE;
    ShowModal;
    aViewThumbRefreshExecute(Sender);
  end;

  N_Dump1Str( 'Finish Files Synchronization Process' );
end; // procedure TN_CMResForm.aServRemoveLocDelFilesExecute

//************************************ TN_CMResForm.aServSelSlidesToSyncQueryExecute ***
// Put Selected Slides to Synchronize Files Query
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSelSlidesToSyncQuery Action handler
//
procedure TN_CMResForm.aServSelSlidesToSyncQueryExecute(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    Connection := LANDBConnection;
{
// Test Add from Appointment Book
    CommandText := format( 'select "DBA"."cms_SyncFilesQueryFromABook"( ''<root><record LocationID="%d" PatientID="%d"/></root>'' );',
      [CurLocID,CurPatID] );
{}
{}
// Test Add  Single Query Element
    CommandText := 'select "DBA"."cms_SyncFilesQueryAddPat"( '+
                        IntToSTr(ClientAppGlobID) + ',' +
                        IntToSTr(CurProvID) + ',' +
                        IntToSTr(CurLocID)  + ',' +
                        IntToSTr(CurPatID)  + ', 1 );';
{}
    N_Dump1Str( 'DB>> ' + CommandText );
    Execute;
  end;
end; // procedure TN_CMResForm.aServSelSlidesToSyncQueryExecute


//************************************ TN_CMResForm.aServDelObjHandlingExecute ***
// Deleted objects Handling
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServDelObjHandling Action handler
//
procedure TN_CMResForm.aServDelObjHandlingExecute(Sender: TObject);
begin
//  K_CMShowMessageDlg( ' Action is not implemented ', mtInformation );
//  N_CM_MainForm.CMMFShowStringByTimer( 'Action is not implemented' );
//  Exit;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMDelObjsHandlingDlg( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServDelObjHandlingExecute

//************************************ TN_CMResForm.aServSystemInfoExecute ***
// Show System Information Now not used ???
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSystemInfo Action handler
//
procedure TN_CMResForm.aServSystemInfoExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TK_FormCMSysInfo.Create( Application) do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSystemInfoExecute

//************************************ TN_CMResForm.aServMaintenanceExecute ***
// DB and Media files Maintenance
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServMaintenance Action handler
//
procedure TN_CMResForm.aServMaintenanceExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMAllPatObjCopyMoveResumeAndWait( 0 ) then
  begin
    if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) <> K_edOK then
      K_CMShowMessageDlg( K_CML1Form.LLLIntegrityCheck1.Caption,
  //         'Integrity check is now selected by another CMS user.'#13#10 +
  //         '              Please try again later.',
               mtWarning )
    else
    begin // if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) = K_edOK
      with TK_FormCMIntegrityCheck.Create( Application) do
      begin
  //      BaseFormInit(nil);
        BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
        ShowModal();
      end;
      TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 0 );
      N_CM_MainForm.CMMFDisableActions( Sender );
      aViewThumbRefreshExecute( Sender );
    end; // if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) = K_edOK
  end; // K_CMAllPatObjCopyMoveResumeAndWait( 0 )

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServMaintenanceExecute

//******************************* TN_CMResForm.aServRestoreDBByFilesExecute ***
// Restore DB by Media Objects files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRestoreDBByFiles Action handler
//
procedure TN_CMResForm.aServDBRecoveryByFilesExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if K_CMDBRecoveryDlg() then
  begin
    if K_CMSDBRecoveryMode then
      Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled)
    else
      Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    N_CM_MainForm.CMMFDisableActions( Sender );
    aViewThumbRefreshExecute( Sender );
  end;
{
  if K_CMSDBRecoveryMode or
     K_CMAllPatObjCopyMoveResumeAndWait( 0 ) then
    with TK_FormCMDBRecovery.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      ShowModal;
      if K_CMSDBRecoveryMode then
        Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled)
      else
        Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
      N_CM_MainForm.CMMFDisableActions( Sender );
      aViewThumbRefreshExecute( Sender );
  //    end;
    end;
}
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServRestoreDBByFilesExecute

//*********************** TN_CMResForm.aServUpdateUIByDeviceProfilesExecute ***
// Update User Interface by Device Profiles
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRebuildDeviceUI Action handler
//
procedure TN_CMResForm.aServUpdateUIByDeviceProfilesExecute(Sender: TObject);
begin
  N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
end; // procedure TN_CMResForm.aServUpdateUIByDeviceProfilesExecute

//***************************** TN_CMResForm.aServRefreshActiveFrameExecute ***
// Refresh Current Active Frame
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRefreshActiveFrame Action handler
//
procedure TN_CMResForm.aServRefreshActiveFrameExecute(Sender: TObject);
begin
  with N_CM_MainForm do
  begin
    CMMCurFMainForm.SetFocus();
//    CMMCurFMainForm.SetFocusedControl( CMMFActiveEdFrame.RFrame );
    CMMFSetActiveEdFrame( CMMFActiveEdFrame );
  end;

end; // procedure TN_CMResForm.aServRefreshActiveFrameExecute

//************************************ TN_CMResForm.aServWindowsSysInfoExecute ***
// Show Sysyten Info
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServWindowsSysInfo Action handler
//
// Show:
//   - all Windows Environment strings
//   - several Windows Directories
//   - remote session flag
//   - all Clipboard Formats currently in Windows buffer
//
procedure TN_CMResForm.aServWindowsSysInfoExecute( Sender: TObject );
var
  BufStr: String;
  NRes, BufSize, NeededSize: integer;
  WTSSessionInfo : TK_WTSSessionInfo;
begin
  with N_CreateMemoForm( '', nil ) do
  begin
    Caption := 'Windows System Info';
    Width  := 500;
    Height := 550;
    Memo.ScrollBars := ssBoth;
    Memo.WordWrap := False;

    Memo.Lines.Add( '***** Windows Environment strings:' );
    K_GetWinEnvironmentStrings( Memo.Lines );
    Memo.Lines.Add( '' );

    Memo.Lines.Add( '***** Windows Directories:' );
    BufSize := 4000;
    SetLength( BufStr, BufSize );
    NeededSize := Windows.GetWindowsDirectory( @BufStr[1], BufSize );
    if NeededSize = 0 then N_Dump1Str( '1. Not enough Size!' );
    Memo.Lines.Add( 'GetWindowsDirectory       = ' + BufStr );

{$IF SizeOf(Char) = 2} // Wide Chars (Delphi 2010) Types and constants
    NeededSize := GetSystemWindowsDirectoryW( @BufStr[1], BufSize );
{$ELSE} //*************** Ansi Chars (Delphi 7) Types and constants
    NeededSize := GetSystemWindowsDirectoryA( @BufStr[1], BufSize );
{$IFEND}
    if NeededSize = 0 then N_Dump1Str( '2. Not enough Size!' );
    Memo.Lines.Add( 'GetSystemWindowsDirectory = ' + BufStr );

    NeededSize := Windows.GetSystemDirectory( @BufStr[1], BufSize );
    if NeededSize = 0 then N_Dump1Str( '3. Not enough Size!' );
    Memo.Lines.Add( 'GetSystemDirectory        = ' + BufStr );

    Memo.Lines.Add( 'GetCurrentDirectory       = ' + GetCurrentDir() );


    Memo.Lines.Add( '' ); // two calls is needed to have one empty separator string !?
    Memo.Lines.Add( '' );

    Memo.Lines.Add( '***** Other Windows Info:' );
    NRes := Windows.GetSystemMetrics( $1000 ); // $1000 is SM_REMOTESESSION (absent in Delphi7)
    Memo.Lines.Add( 'Is Remote Session = ' + IntToStr(NRes) );
    Memo.Lines.Add( 'Clipboard Formats: ' + N_GetClipboardFormats() );
    BufStr := 'FALSE';
    if K_IsWin64Bit() then
      BufStr := 'TRUE';
    Memo.Lines.Add( 'Windows 64 bit OS = ' + BufStr );

    N_GetFNamesFromClipboard( N_SL );

    if N_SL.Count > 0 then
    begin
      Memo.Lines.Add( '   Refs to Files in Clipboard:' );
      Memo.Lines.AddStrings( N_SL );
    end;

// MaxFree: integer;
//    MaxFree := K_FreeSpaceSearchMax( 1500000000, K_FreeSpaceBufCheck, 10 );
//    Memo.Lines.Add( Format( 'Max free Memory block size = %.1f MB', [MaxFree/(1024.0*1024.0)] ) );
//    MaxFree := K_FreeSpaceSearchMax( 1500000000, N_CheckDIBFreeSpace, 10 );
//    Memo.Lines.Add( Format( 'Max free  Image block size  = %.1f MB', [MaxFree/(1024.0*1024.0)] ) );

    Memo.Lines.Add( '' ); // two calls is needed to have one empty separator string !?

    Memo.Lines.Add( '***** Windows Terminal Session Info (Wtsapi32.dll):' );
    K_WTSGetSessionInfo( @WTSSessionInfo );
    Memo.Lines.Add( 'Server Name = ' + WTSSessionInfo.WTSServerCompName );
    Memo.Lines.Add( 'Service Protocol Type(0-Consol,1-ICA,2-RDP) = ' + IntToStr(WTSSessionInfo.WTSClientProtocolType) );
    Memo.Lines.Add( 'SessionID = ' + IntToStr( WTSSessionInfo.WTSSessionID) );
    Memo.Lines.Add( 'Client Name = ' + WTSSessionInfo.WTSClientName );
    Memo.Lines.Add( 'Client IP = ' + WTSSessionInfo.WTSClientIPStr );

    Memo.Lines.Add( '' ); // two calls is needed to have one empty separator string !?

    Memo.Lines.Add( '***** Platform Info:' );
    N_PlatformInfo( Memo.Lines, $FFF );
    Memo.Lines.Add( '' );

    ShowModal;
  end; // with N_CreateMemoForm( 'Windows Environment strings', nil ) do
end; // procedure TN_CMResForm.aServWindowsSysInfoExecute

//******************************** TN_CMResForm.aServRemoteClientSetupExecute ***
// Show Remote Client Setup Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRemoteClientSetup Action handler
//
// Set Capture Device Profiles saving context mode
//
procedure TN_CMResForm.aServRemoteClientSetupExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMRemoteClientSetupDlg();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServRemoteClientSetupExecute

//******************************** TN_CMResForm.aServSetLogFilesPathExecute ***
// Set LogFiles Path
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSetLogFilesPath Action handler
//
// Set LogFiles Path instead of CMSUserIni
//
procedure TN_CMResForm.aServSetLogFilesPathExecute(Sender: TObject);
var
  CMSUserIniPath : string;
  CurControl : TWinControl;
  MemIni : TMemIniFile;
  ErrMes : string;
  WSL : TStringList;
label LExit;
begin

  ErrMes := K_CML1Form.LLLSetLogFilesPath1.Caption;
//  ErrMes := ' UserIni file is not specified ';
  CMSUserIniPath := N_MemIniToString( 'CMSIniFiles', 'User', '' );
  if CMSUserIniPath = '' then
  begin
LExit:
    K_CMShowMessageDlg( ErrMes, mtWarning );
    Exit;
  end;

  CMSUserIniPath := K_ExpandFileName( CMSUserIniPath );
  ErrMes := format( K_CML1Form.LLLSetLogFilesPath2.Caption, [CMSUserIniPath] );
//  ErrMes := format(' UserIni (%s) file is not found ', [CMSUserIniPath] );
//  ErrMes := ' UserIni (' + CMSUserIniPath + ') file is not found ';
  if not FileExists( CMSUserIniPath ) then goto LExit;

  MemIni := TMemIniFile.Create(CMSUserIniPath);
  CMSUserIniPath := MemIni.ReadString( K_FileGPathsIniSection, 'LogFiles', '' );
  N_CurMemIni.DeleteKey('N_Forms', 'N_EditParamsForm');
  with N_CreateEditParamsForm( 350 ) do
  begin // Set new Value to LocationsInfo and to DB
    Caption := 'Set path to the log files folder';
    AddLEdit( '', 0,  CMSUserIniPath );
    Position := poScreenCenter;
    ClientWidth  := ContrWidth + LeftMargin + RightMargin;
    ClientHeight := CurTop + 10;
    Constraints.MaxHeight := Height;
    Constraints.MinHeight := Height;
    Constraints.MinWidth := Width;
    CurControl := TWinControl(EPControls[0].CRContr);
    CurControl.Anchors := CurControl.Anchors + [akRight];
//    TEdit(CurControl).ParentBackground := FALSE; // is need for controls wich Color property will be changed by program
    TEdit(CurControl).Color := $00A2FFFF;
    ActiveControl := CurControl;
    ShowModal();

    if ModalResult = mrOK then
    begin
      // Set new Value to Log Files Path
      if TEdit(CurControl).Text <> '' then
        MemIni.WriteString( K_FileGPathsIniSection, 'LogFiles', TEdit(CurControl).Text )
      else
        MemIni.DeleteKey( K_FileGPathsIniSection, 'LogFiles' );
      // Save Ini file
      WSL := TStringList.Create;
      MemIni.GetStrings( WSL );
      WSL.SaveToFile( MemIni.FileName );
      WSL.Free;
    end;
    MemIni.Free;
  end; // with N_CreateEditParamsForm( 250 ) do
end; //procedure TN_CMResForm.aServSetLogFilesPathExecute

//******************************** TN_CMResForm.aServSAModeSetupExecute ***
// Show Alone Mode Setup Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSAModeSetup Action handler
//
// Setup Alone Mode
//
procedure TN_CMResForm.aServSAModeSetupExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMSAModeSetup() then
    N_CM_MainForm.CMMFDisableActions( nil );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSAModeSetupExecute

//******************************** TN_CMResForm.aServExportPPLExecute ***
// Export Patient/Provider/Location data
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServExportPPL Action handler
//
// Export Patients\Providers\Locations Data
//
procedure TN_CMResForm.aServExportPPLExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMExportPPLDlg();
  AddCMSActionFinish( Sender );
end;
// procedure TN_CMResForm.aServExportPPLExecute

//******************************** TN_CMResForm.aServImportPPLExecute ***
// Import Patient/Provider/Location data
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServImportPPL Action handler
//
// Import Patients\Providers\Locations Data
//
procedure TN_CMResForm.aServImportPPLExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMImportPPLDlg();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServImportPPLExecute

//******************************** TN_CMResForm.aServSysSetupExecute ***
// Show System Setup Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSysSetup Action handler
//
// System Setup Dialog (Alt+Shft+M)
//
procedure TN_CMResForm.aServSysSetupExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMSASysSetup( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSysSetupExecute

//******************************** TN_CMResForm.aServLinkSetupExecute ***
// Link Setup Dialog
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServLinkSetup Action handler
//
// Setup Link Command Line Format
//
procedure TN_CMResForm.aServLinkSetupExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMSLinkCLFSetup();
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServLinkSetupExecute

//******************************** TN_CMResForm.aServApplyCLLContextExecute ***
// Apply Link Context
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServApplyCLLContext Action handler
//
// Apply Context get from Link Command Line
//
procedure TN_CMResForm.aServApplyCLLContextExecute(Sender: TObject);
var
  NewProvID, NewLocID : Integer;
begin
  AddCMSActionStart( Sender );

  K_CMEDAccess.UpdatePPLFlagsSet := [];
//  if K_CMSCLLAttrs.PatientAttrs.CLLPID > 0 then
  if K_CMSCLLAttrs.PatientAttrs.CLLPID <> -1 then
  begin
    Include( K_CMEDAccess.UpdatePPLFlagsSet, K_uliPatients );
    NewProvID := K_CMSCLLAttrs.ProviderAttrs.CLLUID;
    if NewProvID = -1 then
      NewProvID := K_CMEDAccess.CurProvID
    else
      Include( K_CMEDAccess.UpdatePPLFlagsSet, K_uliProviders );

    NewLocID := K_CMSCLLAttrs.LocationAttrs.CLLLID;
    if NewLocID = -1 then
      NewLocID := K_CMEDAccess.CurLocID
    else
      Include( K_CMEDAccess.UpdatePPLFlagsSet, K_uliLocations );
    K_CMSetCurSessionContext1( K_CMSCLLAttrs.PatientAttrs.CLLPID, NewProvID,
                               NewLocID, nil );
    K_SetForegroundWindow( N_CM_MainForm.CMMCurFMainForm.Handle );
  end
  else
    N_Dump1Str( '!!! aServApplyCLLContext patient is not specified');


  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServApplyCLLContextExecute


//************************************* TN_CMResForm.aServUseGDIPlusExecute ***
// Use GDI+ mode control
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServUseGDIPlus Action handler
//
// Apply Context get from Link Command Line
//
procedure TN_CMResForm.aServUseGDIPlusExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );
  if aServUseGDIPlus.Checked then
    K_CMSRImageType := 0
  else
    K_CMSRImageType := K_CMSRImageNotGDIType;
  if not K_CMSRebuildCommonRImage() then
    aServUseGDIPlus.Checked := K_CMSRImageType = 0;
  aServUse16BitImages.Enabled := K_CMGAModeFlag and
                                 not aServUseGDIPlus.Checked;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServUseGDIPlusExecute

//********************************* TN_CMResForm.aServUse16BitImagesExecute ***
// Use 16 bit Images mode control
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServUse16BitImages Action handler
//
// Apply Context get from Link Command Line
//
procedure TN_CMResForm.aServUse16BitImagesExecute(Sender: TObject);
begin
  K_CMSSkip16bitMode := not aServUse16BitImages.Checked;
  N_Dump1Str( '16bitMode=' + N_B2S( not K_CMSSkip16bitMode ) );
  aServUseGDIPlus.Enabled := K_CMGAModeFlag and
                             not aServUse16BitImages.Checked;
end; // procedure TN_CMResForm.aServUse16BitImagesExecute

//********************************** TN_CMResForm.aServResampleLargeExecute ***
// Resample Large Images loaded in previouse versions
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServResampleLarge Action handler
//
procedure TN_CMResForm.aServResampleLargeExecute(Sender: TObject);
var
  CurPatientID : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafRLIMode], 1 ) <> K_edOK then
    K_CMShowMessageDlg( K_CML1Form.LLLResampleLarge1.Caption,
//         'Resample Large Images is now selected by another CMS user'#13#10 +
//         '              Please try again later...',
             mtWarning )
  else
  begin
    // select not existing Patient
    CurPatientID := K_CMEDAccess.CurPatID;
    K_CMGAModeSkipAutoClearFlag := TRUE;
    K_CMSetCurSessionContext( 0, K_CMEDAccess.CurProvID, K_CMEDAccess.CurLocID );

    K_CMSResampleOutOfMemCount := 0;
    with TK_FormCMResampleLarge.Create( Application) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      ShowModal();
    end;

    // Return current patient
    if -1 = K_CMSetCurSessionContext( CurPatientID, K_CMEDAccess.CurProvID, K_CMEDAccess.CurLocID ) then
    begin
      N_Dump1Str('aServResampleLarge >> CMS is finished by user because Patient was locked');
      N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE );
    end;

    K_CMGAModeSkipAutoClearFlag := FALSE;
    TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafRLIMode], 0 );

    N_CM_MainForm.CMMFDisableActions( Sender );

    if K_CMSResampleOutOfMemCount > 0 then
    begin
    // Show Warning
       K_CMShowMessageDlg( K_CML1Form.LLLMemory9.Caption + ' ' +
                           K_CML1Form.LLLPressOkToClose.Caption, mtWarning );
    // Close Media Suite
      N_CM_MainForm.CMMCallActionByTimer(aGoToExit, TRUE);
    end;


  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServResampleLargeExecute

//******************************* TN_CMResForm.aServCreateStudyFilesExecute ***
// Create Study Files utility
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServCreateStudyFiles Action handler
//
procedure TN_CMResForm.aServCreateStudyFilesExecute(Sender: TObject);
var
  ClearFixStudyDataMode : Boolean;
  StartCreateStudyFilesDlg : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDAGetFixStudyDataMode();
    if K_CMSFixStudyDataMode <> 0 then
    begin
      N_Dump1Str( 'aServCreateStudyFiles >> Start FixStudyDataMode=' + IntToStr(K_CMSFixStudyDataMode) );
      StartCreateStudyFilesDlg := K_CMSFixStudyDataMode = 2;
      if not StartCreateStudyFilesDlg then
      begin
      // Show CreateStudyFiles Warning
        EDAChangeFixStudyDataMode( FALSE );
        StartCreateStudyFilesDlg := K_CMFixStudyDataWarnDlg();
      end;
      if StartCreateStudyFilesDlg then
      begin
        if EDALockUnlockActMode( [K_iafDBMMode,K_iafCSFMode], 1 ) <> K_edOK then
          K_CMShowMessageDlg( K_CML1Form.LLLCreateStudyFiles4.Caption,
      //         'Study data fixing is now selected by another CMS user.'#13#10 +
      //         '              Please try again later.',
                   mtWarning )
        else
        begin
          ClearFixStudyDataMode := K_CMSCreateStudyFilesDlg();
          EDALockUnlockActMode( [K_iafDBMMode,K_iafCSFMode], 0 );
          if ClearFixStudyDataMode then
            EDAChangeFixStudyDataMode( TRUE );
        end;
      end; // if (K_CMSFixStudyDataMode = 1) and K_CMFixStudyDataWarnDlg() then
      N_Dump1Str( 'aServCreateStudyFiles >> Fin FixStudyDataMode=' + IntToStr(K_CMSFixStudyDataMode) );
    end; // if K_CMSFixStudyDataMode <> 0 then
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
  N_CM_MainForm.CMMFDisableActions( Sender );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServCreateStudyFilesExecute

//******************************** TN_CMResForm.aServSpecialSettingsExecute ***
// Launch ViewEdit UI
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSpecialSettings Action handler
//
procedure TN_CMResForm.aServSpecialSettingsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
//  K_CMSLinkCLFSetup();
  if K_CMSpecialSettingsConfirmDlg() and
     K_CMSpecSettingsSetup( ) then
    N_CM_MainForm.CMMFDisableActions(Sender);
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSpecialSettingsExecute

//************************************* TN_CMResForm.aServLaunchVEUIExecute ***
// Launch ViewEdit UI
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServLaunchVEUI Action handler
//
procedure TN_CMResForm.aServLaunchVEUIExecute(Sender: TObject);
begin
  N_Dump1Str( 'aServLaunchVEUI start' );
  if N_CM_MainForm.CMMCurFMainForm <> nil then exit; // Skip not needed launch
  K_CMPrepLaunchVEUI();
  if K_CMLimitDevProfilesToRTDBContext() > 0 then
    K_FCMShowDeviceLimitWarning(); // Show Warning
  N_Dump1Str( 'aServLaunchVEUI fin' );
end; // procedure TN_CMResForm.aServLaunchVEUIExecute

//************************************* TN_CMResForm.aServLaunchHPUIExecute ***
// Launch HR Preview UI
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServLaunchVEUI Action handler
//
procedure TN_CMResForm.aServLaunchHPUIExecute(Sender: TObject);
begin
  K_CMSwithToHPUI();
end; // procedure TN_CMResForm.aServLaunchHPUIExecute

//************************************ TN_CMResForm.aServLaunchIUAppExecute ***
// Launch Internet Upgrade Application Manual
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServLaunchIUApp Action handler
//
procedure TN_CMResForm.aServLaunchIUAppExecute(Sender: TObject);
var
  AUCLine : string;
  FParams : string;
  WarnStr : string;
begin
  if not FileExists(K_CMIUCheckUpdatesPath) then
  begin
    N_Dump1Str( format( 'IU >> Application %s is absent', [K_CMIUCheckUpdatesPath] ) );
    Exit;
  end;

  FParams := '/CMS';
  if K_CMIUCheckUpdatesCMDLType = 1 then
    FParams := FParams + ' /Pilot';

  AUCLine := '"' + K_CMIUCheckUpdatesPath + '" ' + FParams;
  N_Dump1Str( 'IU >> CMDL="' + AUCLine );
  WarnStr := K_RunExe( K_CMIUCheckUpdatesPath, FParams, '',
                       N_MemIniToBool( 'CMS_UserDeb', 'RunExeByCreateProcess', FALSE ) );
{
  if (UpperCase( ExtractFileExt(K_CMIUCheckUpdatesPath) ) = '.BAT') or
     not N_MemIniToBool( 'CMS_UserDeb', 'IULaunchByCreateProcess', FALSE ) then
  begin
    K_ShellExecute('Open', K_CMIUCheckUpdatesPath, -1, @WarnStr, FParams );
    if WarnStr <> '' then
      WarnStr := 'ShellExecute: ' + WarnStr;
  end
  else
  begin
    if not K_RunExeByCmdl( AUCLine ) then
    begin
      ErrCode := GetLastError();
      WarnStr := format( 'CreateProcess: ErrCode=%d >> %s', [ErrCode, SysErrorMessage( ErrCode )] );
    end;
  end;
}
  if WarnStr <> '' then
  begin
    N_Dump1Str( 'IU >> Launch Error >> ' + WarnStr );
    K_CMShowMessageDlg( 'Error running Internet Upgrade Application'#13#10 + AUCLine, mtError );
  end;
end; // procedure TN_CMResForm.aServLaunchIUAppExecute

//******************************** TN_CMResForm.aServLaunchIUAppAutoExecute ***
// Launch Internet Upgrade Application Auto
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServLaunchIUApp Action handler
//
procedure TN_CMResForm.aServLaunchIUAppAutoExecute(Sender: TObject);
begin
  K_CMEDAccess.EDANotGAGlobalToCurState();
  if not FileExists(K_CMIUCheckUpdatesPath) then
  begin
    N_Dump1Str( format( 'IU >> Auto application %s is absent', [K_CMIUCheckUpdatesPath] ) );
    Exit;
  end;

  K_CMIURemindeTS := Int(Now());
  K_CMEDAccess.EDANotGAGlobalToMemIni1();

  if mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLIU1.Caption,  mtConfirmation, [], FALSE, K_CML1Form.LLLIUCapt.Caption ) then Exit;
//    if mrYes <> K_CMShowMessageDlg( "Would you like to check for updates to your software?',  mtConfirmation, [], FALSE, 'Check for update?' ) then Exit;

  aServLaunchIUAppExecute(Sender);
end; // procedure TN_CMResForm.aServLaunchIUAppAutoExecute

//*************************************** TN_CMResForm.aServDCMSetupExecute ***
// Set DICOM Server Attributes
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServDCMSetup Action handler
//
procedure TN_CMResForm.aServDCMSetupExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

//  K_CMEDAccess.EDALocationToCurState(); // Get Global ToolBar Info
  K_CMDCMSetupDlg();
//  if K_CMDCMSetupDlg() then
//    K_CMEDAccess.EDALocationToMemIni1();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSetDCMServerAttrsExecute

//********************************** TN_CMResForm.aServEmailSettingsExecute ***
// Change E-mail Settings
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServEmailSettings Action handler
//
procedure TN_CMResForm.aServEmailSettingsExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  K_CMEmailSettingsDlg();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServEmailSettingsExecute

//*********************************** TN_CMResForm.aServRepairAttrs1Execute ***
// Repair Slides Size
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRepairAttrs1 Action handler
//
procedure TN_CMResForm.aServRepairAttrs1Execute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TK_FormCMRepairSlidesAttrs1.Create( Application ) do
     ShowModal();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServRepairAttrs1Execute

//********************* TN_CMResForm.aServPrintTemplatesInfoFNameSetExecute ***
// Set Print Templates Info File Name
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServPrintTemplatesInfoFNameSet Action handler
//
procedure TN_CMResForm.aServPrintTemplatesFNameSetExecute(
  Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  K_CMEDAccess.TmpStrings.Clear();
//  K_CMImportFilesSelectDlg( K_CMEDAccess.TmpStrings, '*.ini', 3 );

  K_CMImportFilesSelectDlg( K_CMEDAccess.TmpStrings,
        'Print Templates files (*.ini)|*.ini|All files (*.*)|*.*', 3,
        'Print Temlates Decription select' );

  if K_CMEDAccess.TmpStrings.Count > 0 then
  begin
    K_CMGAModePrintTemplatesFName := K_CMEDAccess.TmpStrings[0];
    N_Dump1Str( format( 'Set Print Templates Decription to apply from "%s"', [K_CMGAModePrintTemplatesFName] ) );
    K_CMShowMessageDlg1( 'New Print Templates Decription is ready. Use Print action to apply.',
                             mtInformation, [], '', 5 );

  end
  else
    K_CMGAModePrintTemplatesFName := '';

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServPrintTemplatesInfoFNameSetExecute

//*********************** TN_CMResForm.aServPrintTemplatesInfoUnloadExecute ***
// Print Templates Info Unload
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServPrintTemplatesExport Action handler
//
procedure TN_CMResForm.aServPrintTemplatesExportExecute(
  Sender: TObject);
var
  SaveDialog: TSaveDialog;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  SaveDialog := TSaveDialog.Create(Application);
  with SaveDialog do
  begin

    InitialDir := K_ExpandFileName(N_MemIniToString('CMS_Main',
        'LastExportDir', ''));

    Filter := 'Print Templates files (*.ini)|*.ini|All files (*.*)|*.*';
    FilterIndex := 1;
    Options := Options + [ofEnableSizing];
    Title := 'Export Print Temlates';

    FileName := 'CMSPrintTemplates.ini';


    if Execute then
    begin
      N_StringToMemIni( 'CMS_Main', 'LastExportDir', ExtractFilePath(FileName) );
      if K_CMEDAccess.EDAPrintLocMemIniUnload( FileName ) <> K_edOK then
        K_CMShowMessageDlg1( format( 'Print Templates Decription file creation error "%s"', [FileName] ),
                             mtError, [], '', 5 )
      else
        N_CM_MainForm.CMMFShowStringByTimer(format( ' Print Templates Decription was created in "%s"', [FileName] ) );
    end;
    Free;
  end; // with SaveDialog do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServPrintTemplatesInfoUnloadExecute

//***************************** TN_CMResForm.aServClearImg3DTmpFilesExecute ***
// Clear 3D Image Temporary Files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServClearImg3DTmpFiles Action handler
//
procedure TN_CMResForm.aServClearImg3DTmpFilesExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );

  with TK_CMEDDBAccess(K_CMEDAccess) DO
    K_ScanFilesTree( SlidesImg3DRootFolder,
                     EDAScanFilesToClearImg3DTmpFiles, 'DT_*.txt' );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServClearImg3DTmpFilesExecute

//***************************** TN_CMResForm.aServRemoveLogsHandlingExecute ***
// Remove Logs Handling
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServRemoveLogsHandling Action handler
//
procedure TN_CMResForm.aServRemoveLogsHandlingExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMRemoveLogsHandlingDlg( );
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServRemoveLogsHandlingExecute

//*************************** TN_CMResForm.aServClearInstLostRecordsExecute ***
// Clear old CMSuite Instances
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServClearInstLostRecords Action handler
//
procedure TN_CMResForm.aServClearInstLostRecordsExecute(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  if EDAClearInstLostRecords() then
    N_CM_MainForm.CMMCallActionByTimer( aServClearInstLostRecords, TRUE, 100 )
  else
  if InstLostRecordsCount > 0 then
  begin
    InstLostRecordsCount := 0;
    TmpStrings.Clear;
    EDADumpActiveContext( CurBlobDSet, TmpStrings );
    N_Dump1Str('DB>> After LostRecords deletion >> Active Instances Dump ***'#13#10 + TmpStrings.Text);
  end;
end; // procedure TN_CMResForm.aServClearInstLostRecordsExecute

//*************************************** TN_CMResForm.aServArchSaveExecute ***
// Archiving media objects files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServArchSave Action handler
//
procedure TN_CMResForm.aServArchSaveExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  aEditCloseAllExecute( aEditCloseAll );

  K_CMArchSaveDlg( );

  aViewThumbRefreshExecute( aViewThumbRefresh );

  with N_CM_MainForm, CMMFActiveEdFrame  do
  begin
    if IfSlideIsStudy then
      RFrame.RedrawAllAndShow();
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServArchSaveExecute

//************************************ TN_CMResForm.aServArchRestoreExecute ***
// Restoring media objects files from aechive
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServArchRestore Action handler
//
procedure TN_CMResForm.aServArchRestoreExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  K_CMArchRestoreDlg( );

  aViewThumbRefreshExecute( aViewThumbRefresh );

  with N_CM_MainForm, CMMFActiveEdFrame  do
  begin
    if IfSlideIsStudy then
      RFrame.RedrawAllAndShow();
  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // TN_CMResForm.aServArchRestoreExecute

//********************* TN_CMResForm.TN_CMResForm.aServSystemSetupUIExecute ***
// System setup
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSystemSetupUI Action handler
//
procedure TN_CMResForm.aServSysSetupUIExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMAltShiftMConfirmDlg( ) then
  begin
    if K_CMEDAccess is TK_CMEDDBAccess then
      with K_CMEDAccess do
        EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                           Ord(K_shNCAAltShiftM) ) );

    aServSysSetupExecute(aServSysSetup);
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSystemSetupUIExecute

//************************** procedure TN_CMResForm.aServPatCopyMoveExecute ***
// Copy/Move patient media objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServPatCopyMove Action handler
//
procedure TN_CMResForm.aServPatCopyMoveExecute(Sender: TObject);
var
  ParamsStr : string;
  SrcPatID, DstPatID, CopyMode : Integer;
  ShowDialogFlag : Boolean;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  // Get action params
  ParamsStr := K_CMSlidesCopyMoveLaunchTasksList[0];
  K_CMSlidesCopyMoveLaunchTasksList.Delete(0);
  if K_CMSlidesCopyMoveLaunchTasksList.Count = 0 then
    FreeAndNil( K_CMSlidesCopyMoveLaunchTasksList );
  K_CMEDAccess.TmpStrings.Clear;
  K_CMEDAccess.TmpStrings.CommaText := ParamsStr;
  SrcPatID := StrToInt(K_CMEDAccess.TmpStrings[0]);
  DstPatID := StrToInt(K_CMEDAccess.TmpStrings[1]);
  CopyMode := StrToInt(K_CMEDAccess.TmpStrings[2]);
  ShowDialogFlag := N_S2B(K_CMEDAccess.TmpStrings[3]);

  // Do action and dump results
  N_Dump1Str( format( 'aServPatCopyMoveExecute Result=%d',
             [K_CMSlidesCopyMoveByPat( SrcPatID, DstPatID, CopyMode, ShowDialogFlag )] ) );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServPatCopyMoveExecute

//******************* procedure TN_CMResForm.aServSwitchToPhotometryExecute ***
// Switch UI to photometry mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSwitchToPhotometry Action handler
//
procedure TN_CMResForm.aServSwitchToPhotometryExecute(Sender: TObject);
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  // Close Main Full CMSuite UI
  K_CMCloseOnCurUICloseFlag := FALSE;
  K_CMSwitchMainUIFlag := TRUE;
  N_CM_MainForm.CMMCurFMainForm.Close();
  K_CMSwitchMainUIFlag := FALSE;

  // Open photometry UI
  K_CMSMainUIShowMode := 1;
  K_CMPrepLaunchVEUI();

  K_CMBuildUICaptionsByCurContext();

  N_StringToMemIni( 'CMS_Main', 'EdFramesLayout', IntToStr( Integer(N_CM_MainForm.CMMFEdFrLayout) ) );
  N_SetEdFramesLayoutExecute( eflTwoVSp );

  K_CMShowPMTStudiesOnlyFlag := TRUE;
  N_CM_MainForm.CMMFRebuildVisSlides();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSwitchToPhotometryExecute

//***************** procedure TN_CMResForm.aServSwitchFromPhotometryExecute ***
// Switch UI from photometry mode
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServSwitchFromPhotometry Action handler
//
procedure TN_CMResForm.aServSwitchFromPhotometryExecute(Sender: TObject);
var
  WStr : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  // Close Main Full CMSuite UI
  K_CMCloseOnCurUICloseFlag := FALSE;
  K_CMSwitchMainUIFlag := TRUE;
  N_CM_MainForm.CMMCurFMainForm.Close();
  K_CMSwitchMainUIFlag := FALSE;

  // Open CMSuite UI
  K_CMSMainUIShowMode := 0;
  K_CMPrepLaunchVEUI();

  K_CMBuildUICaptionsByCurContext();

  WStr := N_MemIniToString( 'CMS_Main', 'EdFramesLayout', '1' );
  N_SetEdFramesLayoutExecute(  TN_EdFrLayout( StrToIntDef( WStr, 1 ) ) );

  K_CMShowPMTStudiesOnlyFlag := FALSE;
  N_CM_MainForm.CMMFRebuildVisSlides();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServSwitchFromPhotometryExecute

//************************** procedure TN_CMResForm.aServWEBSettingsExecute ***
// Edit WEB settings
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServWEBSettings Action handler
//
procedure TN_CMResForm.aServWEBSettingsExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );

  N_Dump1Str( format( 'aServWEBSettingsExecute before >> %d',
             [K_CMVUIScanPortNumber] ) );
  if L_CMVUISetWEBAttrs() then // Saving K_CMVUIScanPortNumber to CMSWEBSettings and to DB Instance context
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    N_Dump1Str( format( 'aServWEBSettingsExecute after >> %d',
                [K_CMVUIScanPortNumber] ) );
    EDAInstanceCurStateToMemIni();
    if K_edOK <> EDASaveOneAppMemIniContext( Ord(K_actGInstIni), ClientAppGlobID, 0, 'Instance|Save' ) then
      N_Dump1Str( 'aServWEBSettingsExecute >> EDASaveOneAppMemIniContext not OK' );
  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServWEBSettingsExecute

//*********************************** TN_CMResForm.aServChangeDBAPSWExecute ***
// Change DBA password
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServChangeDBAPSW Action handler
//
procedure TN_CMResForm.aServChangeDBAPSWExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );

  if K_CMSetNewDBAPSWDlg() then
  begin
    K_CMSetDBAPSW();
    N_CM_MainForm.CMMFShowStringByTimer( 'New password is set' );
  end
  else
    N_CM_MainForm.CMMFShowStringByTimer( '' );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServChangeDBAPSWExecute

//************************************** TN_CMResForm.aServExportAllExecute ***
// Export All Objects
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServExportAll Action handler
//
procedure TN_CMResForm.aServExportSlidesAllExecute(Sender: TObject);
begin
  AddCMSActionStart( Sender );

  if K_CMEDAccess.PatientsInfo.R.ALength = 1 then
    K_CMEDAccess.EDASAGetPatientsInfo( FALSE, TRUE );
  K_CMExportSlidesAllDlg();

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aServExportSlidesAllExecute

    //********* Debug1 Actions

procedure TN_CMResForm.aDebSaveArchAsExecute( Sender: TObject );
// Save Cur Archive in current or another Archive
var
  CurArchDir, NewArchDir: string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  Caption := 'Centaur Media Suite'; // Form Caption
  CurArchDir := N_ArchDFilesDir(); // with trailing '\'

//  MFFrame.aFileArchSaveAsExecute( Sender );

  NewArchDir := N_ArchDFilesDir(); // with trailing '\'

  if AnsiSameText( CurArchDir, NewArchDir ) then  // Same Archive, all done
  begin
    AddCMSActionFinish( Sender );
    Exit;
  end;

  //***** Process Arch.files dirs

  if not DirectoryExists( CurArchDir ) then // no Source Dir, delete NewArchDir if any
  begin
    if DirectoryExists( NewArchDir ) then
    begin
      K_DeleteFolderFiles( NewArchDir + '\' );
      RemoveDir( NewArchDir );
    end;
  end else // Copy Image Files from OldArch.files dir to NewArch.files
  begin
    ForceDirectories( NewArchDir );
    K_DeleteFolderFiles( NewArchDir + '\' );
    K_CopyFolderFiles( CurArchDir + '\', NewArchDir + '\' );
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebSaveArchAsExecute

procedure TN_CMResForm.aDebCreateDistrExecute( Sender: TObject );
// Create CMS Application Distributive
var
  CurCodePage : Integer;
begin
  CurCodePage := N_NeededCodePage;
  N_NeededCodePage := 1251;
  K_GetFormRunDFPLScript( nil ).ShowModal;
  N_NeededCodePage := CurCodePage;
//  K_GetFormRunDFPLScript( nil ).Show;
end; // procedure TN_CMResForm.aCreateDistrExecute


//******************************** TN_CMResForm.aDebSyncDPRFilesUsesExecute ***
// Synchronized CMS Delphi Projects Uses
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebSyncDPRFilesUses Action handler
//
procedure TN_CMResForm.aDebSyncDPRFilesUsesExecute(Sender: TObject);

  procedure DoPRJ( const ASrcDPRFName, ADstDPRFName, ASkipUList : string );
  begin
    case  K_SyncDPRUsesAndBody( ASrcDPRFName, ADstDPRFName, ASkipUList ) of
   -1: K_CMShowMessageDlg( //sysout
      ' File ' + ASrcDPRFName + ' has no body markers ', mtWarning );
    0: Exit;
    1: K_CMShowMessageDlg( //sysout
      ' File ' + ASrcDPRFName + ' not found ', mtWarning );
    2: K_CMShowMessageDlg( //sysout
      ' File ' + ADstDPRFName + ' not found ', mtWarning );
    3: K_CMShowMessageDlg( //sysout
      ' File ' + ASrcDPRFName + ' has not proper Delphi project structure ', mtWarning );
    4: K_CMShowMessageDlg( //sysout
      ' File ' + ASrcDPRFName + ' - "N_..." or "K_..." Units are not found ', mtWarning );
    5: K_CMShowMessageDlg( //sysout
      ' File ' + ADstDPRFName + ' has not proper Delphi project structure ', mtWarning );
    6: K_CMShowMessageDlg( //sysout
      ' File ' + ADstDPRFName + ' - "N_..." or "K_..." Units are not found ', mtWarning );
    end;
  end;

begin
  DoPRJ( K_ExpandFileName('(##Exe#)Proj_CMS.dpr'),
         K_ExpandFileName('(##Exe#)Proj_CMS_07.dpr'),
         '' );

  DoPRJ( K_ExpandFileName('(##Exe#)Proj_CMS.dpr'),
         K_ExpandFileName('(##Exe#)Proj_CMS_10.dpr'),
         '' );

  DoPRJ( K_ExpandFileName('(##Exe#)Proj_CMS.dpr'),
         K_ExpandFileName('(##Exe#)Proj_CMSDemo.dpr'),
         'K_CMSCom,K_CMSCom_TLB' );

  DoPRJ( K_ExpandFileName('(##Exe#)Proj_CMS.dpr'),
         K_ExpandFileName('(##Exe#)Proj_CMSDemo_10.dpr'),
         'K_CMSCom,K_CMSCom_TLB' );

  N_CM_MainForm.CMMFShowStringByTimer( //sysout
     ' Projetcs syncronization is finished' );

end; // procedure TN_CMResForm.aDebSyncDPRFilesUsesExecute

//*********************************** TN_CMResForm.aDebCreateNewGUIDExecute ***
// Create and show new GUID text
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aServCreateNewGUID Action handler
//
procedure TN_CMResForm.aDebCreateNewGUIDExecute(Sender: TObject);
var
  GUID: TGUID;
  GUIDText: string;
begin
  CreateGUID( GUID );
  GUIDText := GUIDToString( GUID );
  CreateGUID( GUID );
  GUIDText := GUIDText + #13#10 + GUIDToString( GUID );
  CreateGUID( GUID );
  GUIDText := GUIDText + #13#10 + GUIDToString( GUID );
  K_GetFormTextEdit.EditText( GUIDText, 'New GUIDs Text', TRUE );
end; // procedure TN_CMResForm.aDebCreateNewGUIDExecute

//******************************** TN_CMResForm.aDebCorrectDrojFilesExecute ***
// Correct Build Droj Files Product Version
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebCorrectBuildDrojFiles Action handler
//
procedure TN_CMResForm.aDebCorrectDProjFilesExecute(Sender: TObject);
var
  F: TSearchRec;
  FilePath  : string;
  FileName : string;
  SearchPat  : string;
  SL, SLP : TStringList;
  i, CCount : Integer;
  NewValue : string;

begin

  FilePath := N_MemIniToString( 'DFPLPathsHistory', '0', '' );
  if not K_SelectFolder( 'Select Folder', '', FilePath ) then Exit;

  FilePath := IncludeTrailingPathDelimiter( FilePath );
  SearchPat := FilePath + '*.dproj';

  SL := TStringList.Create;
  SLP := TStringList.Create;
  SLP.Add( 'Process *.dproj files in ' + FilePath );
  SLP.Add( '' );
  if FindFirst( SearchPat, faAnyFile, F ) = 0 then
    repeat
      if (F.Name[1] = '.') or
         ((F.Attr and faDirectory) <> 0) then continue;

      FileName := FilePath + F.Name;
    ///////////////////////////
    //  Process DPROJ file

    SL.LoadFromFile( FileName );
    K_VFLoadStrings ( SL, FileName );

    NewValue := '';
    CCount := 0;
    for i := 0 to SL.Count - 1 do
    begin
      if Pos( '<VerInfo_Keys>', SL[i] ) = 0 then Continue;
      if NewValue <> '' then
      begin
        SL[i] := NewValue;
        Inc( CCount );
      end
      else
        NewValue := SL[i];
    end; // for i := 0 to SL.Count - 1 do

    SLP.Add( format( '%d line(s) were changed, file %s', [CCount,F.Name] ) );
    if CCount > 0 then
    begin
      if not K_StringsSaveToFile( FileName, SL,  K_femUTF8 ) then
        SLP[SLP.Count-1] := SLP[SLP.Count-1] + ' !!! Save error';
    end;

    //  Process DPROJ file
    ///////////////////////////
    until FindNext( F ) <> 0;
  FindClose( F );

  K_ShowMessage( SLP.Text ); // show report

  SLP.Free;
  SL.Free;

end; // procedure TN_CMResForm.aDebCorrectDrojFilesExecute

//******************************* TN_CMResForm.aDebViewEditDBContextExecute ***
// View/Edit DB Context
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebViewEditDBContext Action handler
//
procedure TN_CMResForm.aDebViewEditDBContextExecute(Sender: TObject);
var
  DSize: Integer;
  PData: Pointer;
  RCode : TK_CMEDResult;
  IContType, IContID : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    IContType := Ord(K_actProvIni);
    IContID   := 1;
    RCode := EDAGetOneAppContext( IntToStr(IContType), IntToStr(IContID), '0', PData, DSize );
    if (DSize > 0) and (RCode = K_edOK) then
    begin
      EDAAnsiTextToString(PData, DSize);
      TmpStrings.Text := PChar(PData);
      if K_GetFormTextEdit.EditStrings( TmpStrings, 'Provider=1 DB Context' ) then
      begin
        EDASaveOneAppContext(CurDSet1, IContType, IContID, 0, TmpStrings);
      end;
    end;
  end;

  AddCMSActionFinish( Sender );

end; // procedure TN_CMResForm.aDebViewEditDBContextExecute

procedure TN_CMResForm.aDebChangeContextExecute( Sender: TObject );
// Change DB/Patient/Provider/Location Context
var
  L, ANCPatientID, ANCProviderID, ANCLocationID: Integer;
  AStrs: TN_SArray;
  ChangeLocFlag : Boolean;
  SetContextResult : Integer;

  procedure GetIDs ( AUDTab : TK_UDRArray ); // local
  begin
    with AUDTab.R do begin
      L := ARowCount - 1;
      if L < 1 then begin
        SetLength( AStrs, 1 );
        AStrs[0] := '0';
        Exit;
      end;
      SetLength( AStrs, L );
      K_MoveStrings( AStrs[0], -1,
                     PString(PME(0, 1))^, AColCount * SizeOf(string), L );
    end;
  end; // procedure GetIDs - local

begin //********************* TN_CMResForm.aDebChangeContextExecute main body
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CreateEditParamsForm( 250 ) do
  begin
    L := 1;

    GetIDs ( K_CMEDAccess.PatientsInfo );
    AddFixComboBox( 'Current Patient Id:', AStrs,
      K_IndexOfStringInRArray( IntToStr(K_CMEDAccess.CurPatID),  @AStrs[0], L ) );

    GetIDs ( K_CMEDAccess.ProvidersInfo );
    AddFixComboBox( 'Current Provider Id:', AStrs,
      K_IndexOfStringInRArray( IntToStr(K_CMEDAccess.CurProvID),  @AStrs[0], L ) );

    GetIDs ( K_CMEDAccess.LocationsInfo );
    AddFixComboBox( 'Current Location Id:', AStrs,
      K_IndexOfStringInRArray( IntToStr(K_CMEDAccess.CurLocID),  @AStrs[0], L ) );

{
    with TComboBox( EPControls[2].CRContr ) do
    begin
      Style := csOwnerDrawFixed;
      OnDrawItem  := N_CM_MainForm.OnComboBoxColorItemDraw;
      Items.Clear;
      Items.AddStrings( N_CM_MainForm.CMMStudyColorsList );
      ItemIndex := 0;
    end;
}
    ShowSelfModal();

    ANCPatientID := StrToIntDef( EPControls[0].CRStr, K_CMEDAccess.CurPatID );
    ANCProviderID := StrToIntDef( EPControls[1].CRStr, K_CMEDAccess.CurProvID );
    ANCLocationID := StrToIntDef( EPControls[2].CRStr, K_CMEDAccess.CurLocID );
  end; // with N_CreateEditParamsForm( 250 ) do

  ChangeLocFlag := ANCLocationID <> K_CMEDAccess.CurLocID;
  SetContextResult := K_CMSetCurSessionContext( ANCPatientID, ANCProviderID, ANCLocationID );
  if (SetContextResult = 1)
           and
     (K_CMEDAccess is TK_CMEDDBAccess) then
  begin
    N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServProcessClientTasks, FALSE );
    N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServECacheCheck, TRUE );
  end
  else
  if SetContextResult = -2 then
    N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE );

  if ChangeLocFlag then
    N_CM_MainForm.CMMCallActionByTimer(N_CMResForm.aServEModeRemoveLocDelFiles, TRUE );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebChangeContextExecute

procedure TN_CMResForm.aDebClearSlidesInArchExecute( Sender: TObject );
var
  MTNum : Integer;
  CurArchFName : string;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  if K_CMEDAccess is TK_CMEDDBAccess then
    K_ShowMessage( 'Action couldn''t be done while External DB is opened' )
  else begin
    N_CM_MainForm.CMMFFreeEdFrObjects();
    K_CMEDAccess.EDAClearAllEData();
    K_CMEDAccess.EDAddInitialMediaTypes ( @MTNum );
    if MTNum > 0 then
      N_Dump2Str( IntToStr(MTNum) + ' initial Media Types are added' );
    N_CM_MainForm.CMMFShowStringByTimer( //sysout
     'All Slides in Achive Cleared' );
    K_CMEDAccess.EDAGetCurSlidesSet( );
    N_CM_MainForm.CMMFRebuildVisSlides();
    CurArchFName := K_CurArchive.ObjAliase;
    K_CurArchive.ObjAliase := K_ExpandFileName( N_MemIniToString( 'CMS_Main', 'EmptyArchive', CurArchFName ) );
    if K_CurArchive.ObjAliase <> CurArchFName then begin
      K_SaveArchive( K_CurArchive, [K_lsfSkipJoinChangedSLSR] );
      K_CurArchive.ObjAliase := CurArchFName;
    end;

  end;

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebClearSlidesInArchExecute

procedure TN_CMResForm.aDebClearSlidesInDBExecute( Sender: TObject );
// Clear Data In External DB
var
  DFile : string;
  DFPath : string;
  DFIni : string;
  SavedCursor : TCursor;
  StartUpInfo : TStartUpInfo;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  // Clear External DB
  if not K_CMEDDBUtilInitData( TRUE ) then Exit;

  N_CM_MainForm.CMMFShowStringByTimer( //sysout
     'All Slides in External DB Cleared' );
     
  if K_CMEDAccess is TK_CMEDDBAccess then begin
    N_CM_MainForm.CMMFFreeEdFrObjects();
    K_CMEDAccess.EDAGetCurSlidesSet( );
    N_CM_MainForm.CMMFRebuildVisSlides();
    K_ShowMessage( 'Application use External DB. To create compressed DB File copy try again without Extenal DB.'  );
    AddCMSActionFinish( Sender );
    Exit;
  end;

  // Compress DB File
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  DFile := K_ExpandFileName( N_MemIniToString( 'CMSDB', 'DBFile', '' ) );
  DFPath := ExcludeTrailingPathDelimiter(ExtractFilePath( DFile ));
  FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
  StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartUpInfo.wShowWindow := SW_SHOWMINIMIZED;
  if not K_WaitForExecute( 'dbunload -c "uid=dba;pwd=sql;dbf='+DFile+'" -ar ' + DFPath,
                            -1, @StartUpInfo ) then;
//    Result := 'Îøèáêè ïðè çàïóñêå ðàñ÷åòíîãî ìîäóëÿ ->' + SysErrorMessage( GetLastError() )

  // Copy compressed DB File to Ini

  DFIni := K_ExpandFileName( N_MemIniToString( 'CMSDB', 'DBFileIni', DFile ) );
  K_CopyFile( DFile, DFIni, [K_cffOverwriteReadOnly] );
  Screen.Cursor := SavedCursor;
  N_CM_MainForm.CMMFShowStringByTimer( //sysout
    'Compressed DB File copy is created' );
  K_ShowMessage( 'Compressed DB File copy in'#13#10 +
                  DFIni +  ' is created', '', K_msInfo  );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebClearSlidesInDBExecute

procedure TN_CMResForm.aDebAddSlidesToDBExecute( Sender: TObject );
// Add all N_CM_CurPatient Slides to External DB
var
  i : Integer;
  EdFrame: TN_CMREdit3Frame;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CreateEditParamsForm( 250 ), N_CM_MainForm do
  begin
    AddCheckBox( 'Replace Patient Slides', True );

    ShowSelfModal();

    if K_CMEDDBUtilSaveToDB( EPControls[0].CRBool ) then
    begin
      with K_CMEDAccess do
        for i := 0 to DelSlidesList.Count - 1 do // along all Slides to delete
        begin
          EdFrame := CMMFFindEdFrame( TN_UDCMSlide(DelSlidesList[i]) );
          if EdFrame <> nil then // Editor Frame with Opened SlidesArray[i]
            EdFrame.EdFreeObjects();
        end; // for i := 0 to High(SlidesArray) do // along all Slides to delete

      CMMFRebuildVisSlides();
      CMMFShowStringByTimer( // sysout
        IntToStr( K_CMEDAccess.CurSlidesList.Count ) + ' Slides added to External DB' );
    end; // if K_CMEDDBUtilSaveToDB( EPControls[0].CRBool ) then
  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebAddSlidesToDBExecute

//**************************************** TN_CMResForm.aDebAbortCMSExecute ***
// Just abotr Application
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebAbortCMS Action handler
//
procedure TN_CMResForm.aDebAbortCMSExecute( Sender: TObject );
// Abort Application
begin
//  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  raise Exception.Create( 'Application aborted by test exception' );
{
  N_ApplicationTerminated := True; // is used in some OnFormDestroy handlers
  Application.Terminate; // close Self (Self is in Modal mode)
}
end; // procedure TN_CMResForm.aDebAbortCMSExecute

//******************************* TN_CMResForm.aDebClearLockedSlidesExecute ***
// Clear all Locked SLides from DB
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebClearLockedSlidesExecute Action handler
//
procedure TN_CMResForm.aDebClearLockedSlidesExecute( Sender: TObject );
begin
//
  if not (K_CMEDAccess is TK_CMEDDBAccess) then Exit;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with TK_CMEDDBAccess(K_CMEDAccess) do
    try
//      LANDBConnection.BeginTrans;
      with CurSQLCommand1 do begin
        ExtDataErrorCode := K_eeDBLock;
        Connection := LANDBConnection;
      // Delete Slides Locked by Active Instance
        CommandText :=  'DELETE FROM ' + K_CMENDBLockSlidesTable;
        Execute;

      end;
//      LANDBConnection.CommitTrans;
    except
      on E: Exception do begin
        ExtDataErrorString := E.Message;
        EDAShowErrMessage( TRUE );
      end;
    end;
end; // procedure TN_CMResForm.aDebClearLockedSlidesExecute

//*************************************** TN_CMResForm.aDebCheckFileExecute ***
// Choose file in dialog and Check it in Debugger
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebCheckFile Action handler
//
procedure TN_CMResForm.aDebCheckFileExecute( Sender: TObject );
var
  FName: string;
  BArray: TN_BArray;
  DebDIB: TN_DIBObj;
begin
  FName := N_GetFNameFromHist( 'Choose File Name', 'Any|*.*', 'CMSDebFiles', 350 );
  if not FileExists( FName ) then Exit;

  N_ReadBinFile( FName, BArray );
  N_i := Length( BArray );
  DebDIB := TN_DIBObj.Create ( FName );
//  DebDIB.LoadFromMemBMP( @BArray[0] ); // this statement should be examined in debugger
//  DebDIB.SaveToBMPFormat( 'c:\\za3.bmp' );
  DebDIB.Free;
end; // procedure TN_CMResForm.aDebCheckFileExecute

//****************************** TN_CMResForm.aDebDeleteArchImgFilesExecute ***
// Delete Unused Archive Image Files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebDeleteArchImgFiles Action handler
//
procedure TN_CMResForm.aDebDelArchImgFilesExecute( Sender: TObject );
begin
  K_CMEDAccess.EDADelUnusedImgFiles( );
end; // procedure TN_CMResForm.aDebDeleteArchImgFilesExecute

var N_ConvToGrayModes: array [0..2] of string =
                       ( ' 8 bit Gray ', ' 16 bit Gray ', ' 24 bit Color ' );

//************************************** TN_CMResForm.aDebConvToGrayExecute ***
// Convert Slide in ActiveEdFrame to some Gray type
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDebConvToGray Action handler
//
procedure TN_CMResForm.aDebConvToGrayExecute( Sender: TObject );
var
  ModeInd: integer;
  GrayDIB: TN_DIBObj;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm  do
  begin
    if not CMMFCheckBSlideExisting() then Exit;

    with CMMFActiveEdFrame, EdSlide, P()^, GetCurrentImage do
    begin
      ModeInd := N_GetRadioIndex( 'Convert to Gray mode', '', 0, 300, N_ConvToGrayModes );

      if ModeInd = -1 then begin
//        Dec(K_CMD4WWaitApplyDataCount);
//        K_CMD4WWaitApplyDataFlag := false;
        N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
        AddCMSActionFinish( Sender );
        Exit;
      end;


      case ModeInd of
      0: GrayDIB := TN_DIBObj.Create( DIBObj, 0, pfCustom, -1, epfGray8 );
      1: GrayDIB := TN_DIBObj.Create( DIBObj, 0, pfCustom, -1, epfGray16 );
      2: GrayDIB := TN_DIBObj.Create( DIBObj, 0, pf24bit,  -1, epfBMP );
      else
        GrayDIB := nil; // to avoid warning
        Assert( False, 'Bad Mode Ind!' );
      end; // case ModeInd of

      DIBObj.CalcGrayDIB( GrayDIB );
      DIBObj.Free;
      DIBObj := GrayDIB;


      ClearMapImage();
      SetAttrsByCurImgParams( FALSE ); // update EdSlide.CMSDB fields
    end; // with EdSlide, P()^, GetCurrentImage do

    CMMFFinishImageEditing( 'Set Grey', [cmssfAttribsChanged, cmssfCurImgChanged],
             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                              Ord(K_shImgActConvToGrey) ) );
    CMMFDisableActions(Sender);
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebConvToGrayExecute

procedure TN_CMResForm.aDebEmbossParExecute( Sender: TObject );
// Emboss with Params
begin
  with N_CM_MainForm do
  begin
    if not CMMFCheckBSlideExisting() then Exit;

    with CMMFActiveEdFrame.EdSlide, P()^ do begin
      if aToolsEmboss.Checked then begin
        if aToolsIsodens.Checked then begin
        // Toggle Isodensity Mode
          aToolsIsodens.Checked := FALSE;
          aToolsIsodensExecute( Sender );
        end;
        Include( CMSDB.SFlags, cmsfShowEmboss );
      end else begin
        Exclude( CMSDB.SFlags, cmsfShowEmboss );
      end;
      // Rebuild MapImage By View Attributes
      RebuildMapImageByDIB();

//!! new Interface feature - thumbnail changed only for changes that save slide UNDO state
//!!      Include( CMSRFlags, cmsfAttribsChanged );
      CMMFRebuildActiveView( [rvfAllViewRebuild] );
    end;
  end; // with N_CM_MainForm do
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebEmbossParExecute

procedure TN_CMResForm.aDebCreateFileClonesExecute(Sender: TObject);
var
  SStartInd : string;
  SFilesCount : string;
  SFNameFormat : string;
  SFName, SFRPath : string;
  SFName1, SFExt : string;
  StartInd, FilesCount, i : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CreateEditParamsForm( 250 ) do
  begin
    Caption := 'Select file cloning attributes';
    AddFileNameFrame( 'Select File to clone', '', '*.*' );

    AddLEdit( 'File start Index:', 350, SStartInd );
    AddLEdit( 'Files Count:', 350, SFilesCount );
    SFNameFormat := 'RF_%.8d';
    AddLEdit( 'File name format:', 350, SFNameFormat );

    AddPathNameFrame( 'Select Resulting Path', '' );

    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      Release; // Free ParamsForm
      AddCMSActionFinish( Sender );
      Exit;
    end;

    SFName := EPControls[0].CRStr;
    StartInd := StrToIntDef( EPControls[1].CRStr, 1 );
    FilesCount := StrToIntDef( EPControls[2].CRStr, 0 );
    SFNameFormat := EPControls[3].CRStr;
    SFRPath := ExtractFilePath( EPControls[4].CRStr );
    SFExt := ExtractFileExt(SFName);
    SFName1 := format(SFNameFormat, [StartInd] ) + SFExt;
    if mrYes <> K_CMShowMessageDlg( //sysout
    format( 'Are you sure you want to create %d clone(s)', [FilesCount] ) + #13#10 +
    'from file ' + SFName + #13#10 +
    'to path ' + SFRPath + #13#10 +
    'starting with name ' + SFName1, mtConfirmation ) then Exit;
    SFNameFormat := SFRPath +  SFNameFormat + SFExt;

    for i := 1 to  FilesCount do begin
      SFName1 := format(SFNameFormat, [StartInd] );
      K_CopyFile( SFName, SFName1, [K_cffOverwriteNewer] );
      Application.ProcessMessages();
      Inc(StartInd);
    end;

    K_CMShowMessageDlg( //sysout
      format('%d file clone(s) were created', [FilesCount]), mtInformation );
  end; // with N_CreateEditParamsForm( 250 ) do

  AddCMSActionFinish( Sender );
end;

procedure TN_CMResForm.aDebSetPatProvLocInfoExecute(Sender: TObject);
var
  UDInfo : TK_UDRArray;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  UDInfo := TK_UDRArray(K_UDCursorGetObj(K_ArchiveCursor + 'AppInfo\CurrentData\PatientsData'));
  K_CMEDAccess.PatientsInfo.R.Free();
  K_CMEDAccess.PatientsInfo.R := UDInfo.R.AAddRef();

  UDInfo := TK_UDRArray(K_UDCursorGetObj(K_ArchiveCursor + 'AppInfo\CurrentData\ProvidersData'));
  K_CMEDAccess.ProvidersInfo.R.Free();
  K_CMEDAccess.ProvidersInfo.R := UDInfo.R.AAddRef();

  UDInfo := TK_UDRArray(K_UDCursorGetObj(K_ArchiveCursor + 'AppInfo\CurrentData\LocationsData'));
  K_CMEDAccess.LocationsInfo.R.Free();
  K_CMEDAccess.LocationsInfo.R := UDInfo.R.AAddRef();

  AddCMSActionFinish( Sender );
end;

procedure TN_CMResForm.aDebShowNVTreeFormExecute( Sender: TObject );
begin
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsUseObjDisabledFlag];
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsUseObjCheckedFlag];
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsUseObjCheckedFlag,K_vtfsUseObjDisabledFlag];
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipNodeIcon];
//  K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsSkipNodeIcon,K_vtfsUseObjCheckedFlag];
  N_CreateNVTreeForm( N_CM_MainForm.CMMCurFMainForm ).Show();
end; // procedure TN_CMResForm.aDebShowNVTreeFormExecute

procedure TN_CMResForm.aDebClearFormsCoordsExecute( Sender: TObject );
// Clear all Forms coords in ini file (clear [N_Forms] section
begin
  N_ClearSavedFormCoords();
end; // procedure TN_CMResForm.aDebClearFormsCoordsExecute

procedure TN_CMResForm.aDebSkip3DViewCallExecute(Sender: TObject);
begin
//  aDebSkip3DViewCall.Checked;
end; // procedure TN_CMResForm.aDebSkip3DViewCallExecute

procedure K_TEst();
begin
  N_s := 'SoredexDSD.dll';
  N_h := LoadLibrary( @N_s[1] );
  N_s := 'SetImageFormat';
  TN_cdeclIntFuncInt(GetProcAddress( N_h, @N_s[1] ))(0);
end;

procedure TN_CMResForm.aDebAction1Execute( Sender: TObject );
// Debug Action 1
begin
  K_CMSDebAction1Proc();
end; // procedure TN_CMResForm.aDebAction1Execute

//var
//  N_SDots: array [0..3] of string = ( '...', '   ', '.  ', '.. ' );

procedure TN_CMResForm.aDebAction2Execute( Sender: TObject );
// Debug Action 2
begin
  N_CMSDebAction2Proc();
end; // procedure TN_CMResForm.aDebAction2Execute

procedure TN_CMResForm.aDebAction3Execute( Sender: TObject );
// Debug Action 3
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    N_CMSDebAction3Proc( TAction(Sender).Caption );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebAction3Execute

procedure TN_CMResForm.aDebOption1Execute( Sender: TObject );
// Debug Option 1
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    N_CMSDebOption1Proc( TAction(Sender).Caption );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebOption1Execute

procedure TN_CMResForm.aDebOption2Execute( Sender: TObject );
// Debug Option 2
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  with N_CM_MainForm, CMMFActiveEdFrame, EdSlide, GetCurrentImage do
  begin
    if not CMMFCheckBSlideExisting() then begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit;
    end;

    N_CMSDebOption2Proc( TAction(Sender).Caption );

  end; // with N_CM_MainForm do

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.aDebOption2Execute


    //********* Debug2 Actions

//****************************** TN_CMResForm.aDebCreateDemoExeDistrExecute ***
// Create Demo Exe Distributive
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDeb2CreateDemoExeDistr Action handler
//
procedure TN_CMResForm.aDeb2CreateDemoExeDistrExecute( Sender: TObject );
begin
  with TK_FormCMDistr.Create(Application) do
  begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal;
  end;
end; // procedure TN_CMResForm.aDeb2CreateDemoExeDistrExecute

//********************************** TN_CMResForm.aDeb2CallTest2FormExecute ***
// Call N_CMTest2Form
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDeb2CallTest2Form Action handler
//
procedure TN_CMResForm.aDeb2CallTest2FormExecute( Sender: TObject );
begin
  N_CreateCMTest2Form( nil ).Show();
end; // procedure TN_CMResForm.aDeb2CallTest2FormExecute

//***************************************** TN_CMResForm.aDeb2DebMP1Execute ***
// Deb MP Action 1
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDeb2DebMP1 Action handler
//
procedure TN_CMResForm.aDeb2DebMP1Execute( Sender: TObject );
begin
  N_CMDebMPProc1();
end; // procedure TN_CMResForm.aDeb2DebMP1Execute

//***************************************** TN_CMResForm.aDeb2DebMP2Execute ***
// Deb MP Action 2
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDeb2DebMP1 Action handler
//
procedure TN_CMResForm.aDeb2DebMP2Execute( Sender: TObject );
begin
  N_CMDebMPProc2();
end; // procedure TN_CMResForm.aDeb2DebMP2Execute


    //********* Debug3 Actions

//*********************************** TN_CMResForm.aDeb3ShowTestFormExecute ***
// Show Test Form (for solving DPI raleted problems)
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDeb2DebMP1 Action handler
//
procedure TN_CMResForm.aDeb3ShowTestFormExecute( Sender: TObject );
begin
  N_ShowCMTestDelphiForm();
end; // procedure TN_CMResForm.aDeb3ShowTestFormExecute


    //********* TN_CMResForm Event Handlers  *********************
//********************************************* TN_CMResForm.EdFrCrLinePopupMenuPopup ***
// OnPopup Event Handler for Annotation Creation Popup Menu
//
procedure TN_CMResForm.EdFrCrLinePopupMenuPopup(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    N_CMResForm.EdFrCrLinePopupMenu.Items[0].Visible :=
      (EdViewEditMode <> cmrfemCreateVObj2);
//      (EdViewEditMode <> cmrfemCreateVObj2) or
//      (EdAddVObj2RFA.AddMode = 2) or
//      ((EdAddVObj2RFA.AddMode = 0) and (EdAddVObj2RFA.CurPointInd = 2));
  end; // with N_CM_MainForm do
end; // end of procedure TN_CMResForm.EdFrCrLinePopupMenuPopup


//********************************************* TN_CMResForm.EdFrCrLinePopupMenuPopup ***
// OnFormActivate Event Handler for FullScreen Form in non modal state
//
procedure TN_CMResForm.FullScreenFormActivate(Sender: TObject);
begin
  if N_BrigHist2Form <> nil then
    SetWindowPos( N_BrigHist2Form.Handle, HWND_TOPMOST, 0,0,0,0,SWP_NOMOVE + SWP_NOSIZE );

  if K_FormCMSIsodensity <> nil then
    SetWindowPos( K_FormCMSIsodensity.Handle, HWND_TOPMOST, 0,0,0,0,SWP_NOMOVE + SWP_NOSIZE );

  if K_CMSZoomForm <> nil then
    SetWindowPos( K_CMSZoomForm.Handle, HWND_TOPMOST, 0,0,0,0,SWP_NOMOVE + SWP_NOSIZE );
end;

//************************************ TN_CMResForm.EdFrPointPopupMenuPopup ***
// OnPopup Event Handler for EdFrame Popup Menu
//
procedure TN_CMResForm.EdFrPointPopupMenuPopup(Sender: TObject);
begin
// Needed to prevent moving selected object after PopUp Menu option is not selected
  with N_CM_MainForm, CMMFActiveEdFrame do
    EdMoveVObjRFA.SkipNextMouseDown := TRUE;
  ShowDrawings1.ImageIndex := -1;
  ShowColorize1.ImageIndex := -1;
  ShowIsodensity1.ImageIndex := -1;
  Emboss1.ImageIndex := -1;
  ZoomMode1.ImageIndex := -1;
end; // procedure TN_CMResForm.EdFrPointPopupMenuPopup

//************************************ TN_CMResForm.ThumbsRFrPopupMenuPopup ***
// OnPopup Event Handler for ThumbsRFr Popup Menu
//
procedure TN_CMResForm.ThumbsRFrPopupMenuPopup(Sender: TObject);
begin
//
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if EdSlide = nil then Exit;
  end;
end; // procedure TN_CMResForm.ThumbsRFrPopupMenuPopup

    //********* TN_CMResForm public methods  *********************

//****************************** TN_CMResForm.ThumbsRFrameExecute ***
// Disable needed Actions after any change in Thumbs Frame
//
//     Parameters
// ARFrameAction - given RFrame Action (not used)
//
// Used as TN_DGridBase.DGExtExecProcObj Procedure of Object
//
// Will be called from TN_SGBase.GExecAllActions or TN_SGBase.GExecOneAction
// just after calling ARFrameAction.Execute
//
procedure TN_CMResForm.ThumbsRFrameExecute( ARFrameAction: TN_RFrameAction );
begin
  with ARFrameAction.ActGroup.RFrame do
    if (CHType = htMouseDown) or (CHType = htMouseUp ) then
      N_CM_MainForm.CMMFDisableActions( nil );
end; // procedure procedure TN_CMResForm.ThumbsRFrameExecute

//****************************************** TN_CMResForm.CreateBinDumpFile ***
// Save given Memory block to binary dump file
//
//     Parameters
// AInstStr - calling instance (to distinguish calling from several palaces)
// AMemPtr  - Pointer to Memoru to dump
// AMemSize - Number of bytes to dump or nil if only Result value is needed
// Result   - Return True if dumping from AInstStr instance is needed
//
// Can be used as N_BinaryDumpProcObj (of TN_BinaryDumpProcObj type)
//
function TN_CMResForm.CreateBinDumpFile( AInstStr: string; AMemPtr: Pointer;
                                         AMemSize: integer ): boolean;
var
  FName: string;
begin
  Result := True;
  if AMemPtr = nil then Exit; // only resulting value was needed
  if not aServBinDumpMode.Checked then Exit;

  FName := K_ExpandFileName( '(#CMSLogFiles#)' );
  FName := N_CreateUniqueFileName( FName + N_GetDateTimeStr1() + '_Dump.bin' );
  N_WriteBinFile( FName, AMemPtr, AMemSize );

  N_Dump1Str( Format( 'Binary Dump file created (%s) "%s"', [AInstStr,FName] ));
end; // function TN_CMResForm.CreateBinDumpFile

{
//************************************** TN_CMResForm.TwainOnExecuteHandler ***
// Twain OnExecute Handler
//
procedure TN_CMResForm.LaunchTWAINDevice();
begin
end;
}

//************************************** TN_CMResForm.TwainOnExecuteHandler ***
// Twain OnExecute Handler
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// OnExecute handler for all Actions, MenuItems and ToolButtons, associated with TWAIN
// Capturing devices
//
// ASender.Tag contains needed device Profile index
//
procedure TN_CMResForm.TwainOnExecuteHandler( ASender: TObject );
var
  i, ResCode: Integer;
  SL: TStringList;
  PCMTwainProfile: TK_PCMTwainProfile;
  CurTwainProfile: TK_CMTwainProfile;
  CMCaptProfileInd : Integer;

label Fin;
begin
  AddCMSActionStart( ASender );

  //***** Check that Images Folder is accessible
  if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLCaptHandler1.Caption,
//        'The Images folder is not accessible. Capture is not possible because images cannot be saved.'#13#10 +
//        'Please check network connection, permission to access the Images folder and start Capture again.',
         mtWarning, [mbOK] );
    AddCMSActionFinish( ASender );
    Exit;
  end; // if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then

  if N_CM_MainForm.CMMDevGroupTButton <> nil then
  begin// Switch GroupButton Current action
    N_CM_MainForm.CMMDevGroupTButton.Action := TAction(ASender);
    for i := 0 to N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items.Count - 1 do
      if N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items[i].Action = ASender then
      begin
        N_CM_MainForm.CMMDevGroupInd := i;
        Break;
      end;
  end; // if N_CM_MainForm.CMMDevGroupTButton <> nil then

  // Get K_CMCaptProfileInd and PCMTwainProfile
  CMCaptProfileInd := TComponent(ASender).Tag; // Capture (TWAIN) device profile index
  PCMTwainProfile := K_CMEDAccess.TwainProfiles.PDE(CMCaptProfileInd);

  //***** Check if Profile.CMDPProductName is corrupted
  //      (is needed after migrating from some old CMS versions)
  if PCMTwainProfile^.CMDPProductName = '' then
  begin // Try to Correct CMDPProductName
    SL := TStringList.Create;
    K_CMBuildTwainDevicesList( SL );
    K_CMRecoverDeviceProfile( -1 <> SL.IndexOf( PCMTwainProfile.CMDPCaption ),
                              K_CMEDAccess.TwainProfiles, CMCaptProfileInd,
                              (@CurTwainProfile), TK_FormCMProfileTwain );
    SL.Free;
  end; // if PCMTwainProfile^.CMDPProductName = '' then

  // Correct Undefined Twain Mode
  with PCMTwainProfile^ do
    K_CMDeviceProfileAutoTWAINMode( CMDPStrPar1, CMDPProductName );

  //***** Acquire Slides from given TWAIN device in mode 1, 2 or 3

  with PCMTwainProfile^ do
    N_Dump1Str( Format( 'TwainOnExecuteHandler: Before Get Slides From TWAIN in mode %s %s',
                                [CMDPStrPar1,CMDPProductName] ) );
{
  K_scfUploadDataBeforeCaptFin,   // start data upload from CMScan to CMSuite before capturing is finished
  K_scfApplyProfileDICOMDefaults, // apply profile DICOM attributes default values
  K_scfUseFullStatyOnTopMode      // Use full stay on top for CMS Device Windows
}
  if not K_CMEDAccess.EDAStartCapture( [K_scfSlideUploadWOGap],
                                 TK_PCMDeviceProfile(PCMTwainProfile) ) then
    goto Fin;

  if PCMTwainProfile^.CMDPStrPar1 = '1' then
  begin // TWAIN Mode 1, modal mode
    K_CMEDAccess.EDADCMSeriesStart();
    N_CMGetSlidesFromTWAIN1( PCMTwainProfile );
    K_CMEDAccess.EDADCMSeriesFin();
  end
  else if PCMTwainProfile^.CMDPStrPar1 = '2' then
  begin // TWAIN Mode 2, modal mode
    K_CMEDAccess.EDADCMSeriesStart();
    N_CMGetSlidesFromTWAIN2( PCMTwainProfile );
    K_CMEDAccess.EDADCMSeriesFin();
  end
  else if PCMTwainProfile^.CMDPStrPar1[1] = '3' then // TWAIN Mode 3, not modal mode!
  begin
    // Disable CMS UI
    // Disable all controls and processing commands from D4W
    N_CM_MainForm.CMMSetUIEnabled( FALSE );

    K_CMEDAccess.EDADCMSeriesStart(); // will be finished in K_CMSlidesSaveScanned3
    ResCode := N_CMGetSlidesFromTWAIN3( PCMTwainProfile ); // start capturing

    if K_CMD4WAppFinState then Exit; // Precaution

    if ResCode <> 0 then // N_CMGetSlidesFromTWAIN3 error
    begin
      N_Dump1Str( 'TWAIN mode 3 initialization Error' );
      K_CMSlidesSaveScanned3( TK_PCMDeviceProfile(PCMTwainProfile), nil ); // just enable all controls back
    end; // if ResCode <> 0 then // N_CMGetSlidesFromTWAIN3 error

    // if ResCode = 0, All controls will be enabled back
    // inside K_CMSlidesSaveScanned3 called from CMTTimerOnTimer
  end
  else if PCMTwainProfile^.CMDPStrPar1[1] = '4' then // TWAIN Mode 4, modal mode
  begin

    if K_CMInitSlidesFromTWAIN( PCMTwainProfile ) then
    begin
{

      if not (K_CMEDAccess is TK_CMEDCSAccess)          and
         N_CM_MainForm.CMMFActiveEdFrame.IfSlideIsStudy and
         (K_CMEDDBVersion >= 39) then
      begin
        N_Dump1Str( format( 'TWAIN Capture to Study=%s, Device=%s',
                            [N_CM_MainForm.CMMFActiveEdFrame.EdSlide.ObjName,
                             PCMTwainProfile.CMDPCaption] ) );

        K_FormCMStudyCapt := TK_FormCMStudyCapt.Create( Application );
        K_FormCMStudyCapt.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//        K_CMStudyCaptModeState    := 0;
        K_CMStudyCaptState        := K_cmscDeviceDlgShowLater;
        K_CMStudyCaptAttrs.CMSDCDDlgCPanel := nil;
        K_CMStudyCaptAttrs.CMSDCDDlg := K_CMGetSlidesFromTWAIN( PCMTwainProfile );
        K_FormCMStudyCapt.Caption := Format( K_CML3Form.LLLCaptToStudyTWAINCaption.Caption, [PCMTwainProfile.CMDPCaption] );
        N_Dump1Str( 'Before K_FormCMStudyCapt ShowModal' );
        K_FormCMStudyCapt.ShowModal();
        N_Dump1Str( 'After K_FormCMStudyCapt ShowModal' );
      end  // if N_CM_MainForm.CMMFActiveEdFrame.IfSlideIsStudy and (K_CMEDDBVersion >= 39) then
      else
{}
        K_CMEDAccess.EDADCMSeriesStart(); // will be finished in K_CMSlidesSaveScanned3
        K_CMGetSlidesFromTWAINModal( PCMTwainProfile );
    end;

//        K_CMGetSlidesFromTWAIN( PCMTwainProfile );
  end
  else // a precaution, unknown mode (bad value in CMDPStrPar1)
    K_CMShowMessageDlg1( Format( K_CML1Form.LLLCaptHandler2.Caption, //'Mode %s not implemented!'
                         [PCMTwainProfile^.CMDPStrPar1] ), mtWarning, [mbOK] );

Fin: //***********
  AddCMSActionFinish( ASender );
end; // procedure TN_CMResForm.TwainOnExecuteHandler

//************************************** TN_CMResForm.OtherOnExecuteHandler ***
// New Other Capturing Devices OnExecute Handler
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// OnExecute handler for all Actions, MenuItems and ToolButtons, associated with Other
// Capturing devices
//
// ASender.Tag contains needed device Profile index
//
procedure TN_CMResForm.OtherOnExecuteHandler( ASender: TObject );
var
  i: Integer;
  CDServObj: TK_CMCDServObj;
  PCMDeviceProfile: TK_PCMDeviceProfile;
  CaptSlidesArray: TN_UDCMSArray;
  CMCaptProfileInd : Integer;
  CMScanCaptureFlags : TK_CMScanCaptureFlags;
  StudyWasLocked : Boolean;

label Fin;
begin
  AddCMSActionStart( ASender );
  SetLength( CaptSlidesArray, 0 );

  //***** Check if Images Folder is accessible
  if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLCaptHandler1.Caption,
//        'The Images folder is not accessible. Capture is not possible because images cannot be saved.'#13#10 +
//        'Please check network connection, permission to access the Images folder and start Capture again.',
         mtWarning, [mbOK] );
    AddCMSActionFinish( ASender );
    Exit;
  end; // if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then

  if N_CM_MainForm.CMMDevGroupTButton <> nil then
  begin// Switch GroupButton Current action
    N_CM_MainForm.CMMDevGroupTButton.Action := TAction(ASender);
    for i := 0 to N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items.Count - 1 do
      if N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items[i].Action = ASender then
      begin
        N_CM_MainForm.CMMDevGroupInd := i;
        Break;
      end;
  end; // if N_CM_MainForm.CMMDevGroupTButton <> nil then

  // Get K_CMCaptProfileInd and PCMTwainProfile
  CMCaptProfileInd := TComponent(ASender).Tag; // Capture (TWAIN) device profile index
  PCMDeviceProfile := K_CMEDAccess.OtherProfiles.PDE(CMCaptProfileInd);

  with PCMDeviceProfile^ do
    N_Dump1Str( Format( 'NewOtherOnExecuteHandler 1: DLLInd=%d, (%s), (%s) S1="%s" S2="%s"',
                                [CMDPDLLInd,CMDPProductName,CMDPGroupName,
                                 CMDPStrPar1,CMDPStrPar2] ) );
  if PCMDeviceProfile.CMDPGroupName = '' then
  begin
    // try to convert profile
    if not N_CMECDConvProfile( PCMDeviceProfile ) then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLCaptHandler3.Caption,
//         'Bad device Profile. Please delete it and create again.',
          mtError );
      AddCMSActionFinish( ASender );
      Exit;
    end;
  end; // if PCMDeviceProfile.CMDPGroupName = '' then

  CDServObj := K_CMCDGetDeviceObj( PCMDeviceProfile );

  if CDServObj = nil then // error creating CDServObj
  begin
    K_CMShowMessageDlg( format(
        K_CML1Form.LLLCaptHandler4.Caption + '          ' + K_CML1Form.LLLPressOKToContinue.Caption,
//        'Capture Device Service Object %s is not found.'#13#10 +
//        '          Press OK to continue',
        [PCMDeviceProfile.CMDPProductName]),
         mtWarning, [mbOK] );
{
    K_CMShowMessageDlg(
        'Capture Device Service Object ' +
        '' +  PCMDeviceProfile.CMDPProductName + ' is not found.'#13#10 +
        '          Press OK to continue',
         mtWarning, [mbOK] );
}
  end
  else // CDServObj created OK (normal case)
  begin
    N_OtherDevices := True; // just to enable dump in N_BaseForm
    CMScanCaptureFlags := [];
    if Pos( CDServObj.CDSName, N_CMFullStayOnTopList ) > 0 then
      CMScanCaptureFlags := [K_scfUseFullStayOnTopMode];
    if not K_CMEDAccess.EDAStartCapture( CMScanCaptureFlags, PCMDeviceProfile ) then
      goto Fin;

//    K_CMStudyCaptModeState := -1;
    K_CMStudyCaptState := K_cmscNon;
    if not (K_CMEDAccess is TK_CMEDCSAccess)          and
       N_CM_MainForm.CMMFActiveEdFrame.IfSlideIsStudy and
       (K_CMEDDBVersion >= 39) then
      K_CMStudyCaptState := CDServObj.CDSStartCaptureToStudy( PCMDeviceProfile, K_CMStudyCaptAttrs );
{
                                                   K_CMStudyCaptDevDlg,
                                                   K_CMStudyCaptDevDlgCPanel,
                                                   K_CMStudyCaptDeviceSeriesRoutine,
                                                   K_CMStudyCaptDeviceAutoStartRoutine );
)
//    if K_CMStudyCaptModeState >= 0 then
{!!! This case was suggested to Karpenkov but he selected more simple
    if K_CMStudyCaptState >= K_cmscOK then
    begin // ServObject maintains Capture to Study
      if N_CM_MainForm.CMMOpenedStudiesLock(
         TN_PUDCMStudy(@N_CM_MainForm.CMMFActiveEdFrame.EdSlide), 1, StudyWasLocked, FALSE ) <> 0  then
      begin
      // Should be Confirm
        if mrYes = K_CMShowMessageDlg( 'The study is locked by another user. Select "Yes" if you want to continue capture in old mode. Select "No" if you want to try later.',
                             mtConfirmation ) then
          K_CMStudyCaptState := K_cmscNon
        else
          goto Fin;

      end;
    end;   // if K_CMStudyCaptModeState >= K_cmscOK then
}

    if K_CMStudyCaptState >= K_cmscOK then
    begin
      if N_CM_MainForm.CMMOpenedStudiesLock(
         TN_PUDCMStudy(@N_CM_MainForm.CMMFActiveEdFrame.EdSlide), 1, StudyWasLocked, FALSE ) <> 0  then
      begin
        K_CMShowMessageDlg( K_CML1Form.LLLStudy6.Caption,
        // 'The study is locked by another user. Please resume your operation later.',
                            mtWarning );
        K_CMStudyCaptState := K_cmscNon;
        goto Fin;
      end;

      N_Dump1Str( format( 'Capture to Study=%s, CaptState=%d, Device=%s',
                          [N_CM_MainForm.CMMFActiveEdFrame.EdSlide.ObjName,
                           Ord(K_CMStudyCaptState),
                           PCMDeviceProfile.CMDPCaption] ) );

      K_FormCMStudyCapt := TK_FormCMStudyCapt.Create( Application );
      K_FormCMStudyCapt.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      K_FormCMStudyCapt.Caption := PCMDeviceProfile.CMDPCaption + ' X-Ray Capture';
      N_Dump1Str( 'Before K_FormCMStudyCapt ShowModal' );
      K_CMEDAccess.EDADCMSeriesStart();
      K_FormCMStudyCapt.ShowModal();
      K_CMEDAccess.EDADCMSeriesFin();
      N_Dump1Str( 'After K_FormCMStudyCapt ShowModal' );
      if not StudyWasLocked then
        N_CM_MainForm.CMMOpenedStudiesUnLock(
                  TN_PUDCMStudy(@N_CM_MainForm.CMMFActiveEdFrame.EdSlide), 1 );
    end // if K_CMStudyCaptModeState >= K_cmscOK then
    else
    begin // if K_CMStudyCaptModeState < 0 then
    // ServObject doesn't maintains Capture to Study
      K_CMEDAccess.EDADCMSeriesStart(); // will be finished in K_CMSlidesSaveScanned3
      if CDServObj.NotModalCapture then
      begin //*** Not Modal Capture
        N_Dump2Str( 'Start Not Modal Capture from ' + PCMDeviceProfile.CMDPCaption );
      // Disable CMS UI
      // Disable all controls and processing commands from D4W
        N_CM_MainForm.CMMSetUIEnabled( FALSE );
        CDServObj.CDSStartCaptureImages( PCMDeviceProfile );
      end   //*** Not Modal Capture
      else
      begin //*** Modal Capture
        CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
        with PCMDeviceProfile^ do
          N_Dump1Str( Format( 'NewOtherOnExecuteHandler 2: DLLInd=%d, (%s), (%s) S1="%s" S2="%s"',
                                      [CMDPDLLInd,CMDPProductName,CMDPGroupName,
                                       CMDPStrPar1,CMDPStrPar2] ) );
        if not K_CMD4WAppFinState then
          K_CMSlidesSaveScanned3( PCMDeviceProfile, CaptSlidesArray )
        else
          N_Dump1Str( format( 'Slides saving (%d) is skipted on CMSAppFinState', [Length(CaptSlidesArray)] ) );
      end; //*** Modal Capture
    end; // if K_CMStudyCaptModeState < 0 then

    N_OtherDevices := False; // restore
  end; // else // CDServObj created OK (normal case)
Fin : //*************
  AddCMSActionFinish( ASender );
end; // procedure TN_CMResForm.OtherOnExecuteHandler

//************************************ TN_CMResForm.Other3DOnExecuteHandler ***
// New Other Capturing Devices OnExecute Handler
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// OnExecute handler for all Actions, MenuItems and ToolButtons, associated with Other
// Capturing devices
//
// ASender.Tag contains needed device Profile index
//
procedure TN_CMResForm.Other3DOnExecuteHandler( ASender: TObject );
var
  i: Integer;
  CDServObj: TK_CMCDServObj;
  PCMDeviceProfile: TK_PCMDeviceProfile;
  CaptSlidesArray: TN_UDCMSArray;
  CMCaptProfileInd : Integer;
  CMScanCaptureFlags : TK_CMScanCaptureFlags;

label Fin;
begin
  AddCMSActionStart( ASender );
  SetLength( CaptSlidesArray, 0 );

  //***** Check if Images Folder is accessible
  if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLCaptHandler1.Caption,
//        'The Images folder is not accessible. Capture is not possible because images cannot be saved.'#13#10 +
//        'Please check network connection, permission to access the Images folder and start Capture again.',
         mtWarning, [mbOK] );
    AddCMSActionFinish( ASender );
    Exit;
  end; // if K_CMEDAccess.EDACheckImgFilesFolderAccess() <> 0 then

  if N_CM_MainForm.CMMDevGroupTButton <> nil then
  begin// Switch GroupButton Current action
    N_CM_MainForm.CMMDevGroupTButton.Action := TAction(ASender);
    for i := 0 to N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items.Count - 1 do
      if N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items[i].Action = ASender then
      begin
        N_CM_MainForm.CMMDevGroupInd := i;
        Break;
      end;
  end; // if N_CM_MainForm.CMMDevGroupTButton <> nil then

  // Get K_CMCaptProfileInd and PCMTwainProfile
  CMCaptProfileInd := TComponent(ASender).Tag; // Capture  device profile index
  PCMDeviceProfile := K_CMEDAccess.OtherProfiles3D.PDE(CMCaptProfileInd);

  with PCMDeviceProfile^ do
    N_Dump1Str( Format( 'NewOther3DOnExecuteHandler 1: DLLInd=%d, (%s), (%s) S1="%s" S2="%s"',
                                [CMDPDLLInd,CMDPProductName,CMDPGroupName,
                                 CMDPStrPar1,CMDPStrPar2] ) );
  CDServObj := K_CMCDGetDeviceObj( PCMDeviceProfile );

  if CDServObj = nil then // error creating CDServObj
  begin
    K_CMShowMessageDlg( format(
        K_CML1Form.LLLCaptHandler4.Caption + '          ' + K_CML1Form.LLLPressOKToContinue.Caption,
//        'Capture Device Service Object %s is not found.'#13#10 +
//        '          Press OK to continue',
        [PCMDeviceProfile.CMDPProductName]),
         mtWarning, [mbOK] );
{
    K_CMShowMessageDlg(
        'Capture Device Service Object ' +
        '' +  PCMDeviceProfile.CMDPProductName + ' is not found.'#13#10 +
        '          Press OK to continue',
         mtWarning, [mbOK] );
}
  end
  else // CDServObj created OK (normal case)
  begin
    N_OtherDevices := True; // just to enable dump in N_BaseForm
    CMScanCaptureFlags := [];
    if Pos( CDServObj.CDSName, N_CMFullStayOnTopList ) > 0 then
      CMScanCaptureFlags := [K_scfUseFullStayOnTopMode];
    if not K_CMEDAccess.EDAStartCapture( CMScanCaptureFlags, PCMDeviceProfile ) then
      goto Fin;

    K_CMStudyCaptState := K_cmscNon;
  // ServObject doesn't maintains Capture to Study
    if CDServObj.NotModalCapture then
    begin //*** Not Modal Capture
    N_Dump2Str( 'Start Not Modal Capture from ' + PCMDeviceProfile.CMDPCaption );
    // Disable CMS UI
    // Disable all controls and processing commands from D4W
      N_CM_MainForm.CMMSetUIEnabled( FALSE );
      CDServObj.CDSStartCaptureImages( PCMDeviceProfile );
    end   //*** Not Modal Capture
    else
    begin //*** Modal Capture
      CDServObj.CDSCaptureImages( PCMDeviceProfile, CaptSlidesArray );
      if not K_CMD4WAppFinState then
        K_CMSlidesSaveScanned3( PCMDeviceProfile, CaptSlidesArray, TRUE )
      else
        N_Dump1Str( format( 'Slides saving (%d) is skipted on CMSAppFinState', [Length(CaptSlidesArray)] ) );
    end; //*** Modal Capture

    N_OtherDevices := False; // restore
  end; // else // CDServObj created OK (normal case)
Fin : //*************
  AddCMSActionFinish( ASender );
end; // procedure TN_CMResForm.Other3DOnExecuteHandler

//************************************** TN_CMResForm.VideoOnExecuteHandler ***
// Video OnExecute Handler (from Igor, 05.06.2017)
//
//     Parameters
// ASender - Event Sender (MenuItem of ToolButton)
//
// OnExecute handler for all Actions, MenuItems and Buttons, associated with VIDEO
// Capturing devices
//
// ASender.Tag contains needed device Profile index
//
procedure TN_CMResForm.VideoOnExecuteHandler( ASender: TObject );
var
  i, IError, MaxWidth, MaxHeight: integer;
//  AddSlidesCount: integer;
  DevName, ProfileName: string;
  AdditionalSize, MaxLPSize, NeededLPSize: TPoint;
  DevNamesList, CapsList: TStringList;
  PCMVideoProfile: TK_PCMVideoProfile;
  CMVideo2Form: TN_CMVideo2Form;
  CMVideo3Form: TN_CMVideo3Form;
  CMVideo4Form: TN_CMVideo4Form;
  CurVideoProfile : TK_CMVideoProfile;
  CMCaptProfileInd : Integer;
  Form: TN_CMVideoResForm;

  Label Fin;
begin
  AddCMSActionStart( ASender );

  if K_CMEDAccess.EDACheckVideoFilesFolderAccess() <> 0 then
  begin
    K_CMShowMessageDlg1( K_CML1Form.LLLCaptHandler5.Caption, mtWarning, [ mbOK ] );
    AddCMSActionFinish( ASender );
    Exit; // precaution
  end;

  if N_CM_MainForm.CMMDevGroupTButton <> nil then
  begin // Switch GroupButton Current action
    N_CM_MainForm.CMMDevGroupTButton.Action := TAction( ASender );
    for i := 0 to N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items.Count - 1 do
      if N_CM_MainForm.CMMDevGroupTButton.DropdownMenu.Items[ i ].Action = ASender then
      begin
        N_CM_MainForm.CMMDevGroupInd := i;
        Break;
      end;
  end;

  CMRFVideoMode := True;
  CMCaptProfileInd := TComponent( ASender ).Tag;
  PCMVideoProfile := K_CMEDAccess.VideoProfiles.PDE( CMCaptProfileInd );

  //***** Check if device defind by Profile.CMDPProductName is currently alailable

  DevNamesList := TStringList.Create(); // get list of currently alailable devices
  N_DSEnumFilters( CLSID_VideoInputDeviceCategory, '', DevNamesList, IError );

  if IError <> 0 then
  begin
    K_CMShowMessageDlg( Format(
                   K_CML1Form.LLLCaptHandler6.Caption, [ IError ]), mtWarning );
    goto Fin;
  end; // if IError <> 0 then

  //if DevNamesList.Count = 0 then // not one Device is available
  //begin
  //  K_CMShowMessageDlg( K_CML1Form.LLLCaptHandler7.Caption, mtInformation );
  //  goto Fin;
  //end; // if DevNamesList.Count = 0 then // not one Device is available

  // Check if Profile.CMDPProductName is corrupted
  if PCMVideoProfile.CMDPProductName = '' then
  // Try to Correct CMDPProductName
    K_CMRecoverDeviceProfile( -1 <> DevNamesList.IndexOf( PCMVideoProfile.CMDPCaption ),
                              K_CMEDAccess.VideoProfiles, CMCaptProfileInd,
                              (@CurVideoProfile), TN_CMVideoProfileForm );

  DevName := PCMVideoProfile^.CMDPProductName;
  ProfileName := PCMVideoProfile^.CMDPCaption;
  if -1 <> DevNamesList.IndexOf( DevName ) then // DevName Device is available
  begin

    if cmpfVideoAll in N_CM_LogFlags then // check and Log DevName Video Caps if not yet
    begin
      if N_LogDevNamesList = nil then
        N_LogDevNamesList := TStringList.Create;

      if -1 = N_LogDevNamesList.IndexOf( DevName ) then // Log DevName Video Caps
      begin
        N_LogDevNamesList.Add( DevName ); // to Log only once in a session
        CapsList := TStringList.Create;
        N_DSEnumVideoCaps( DevName, CapsList );
        N_Dump2Strings( CapsList, 5 );
        CapsList.Clear;
        N_DSEnumVideoSizes( DevName, CapsList );
        N_Dump2Str( 'Resolutions: ' + CapsList.CommaText );
        CapsList.Free;
      end; // if -1 = N_LogDevNamesList.IndexOf( DevName ) then // Log DevName Video Caps
    end; // if cmpfVideoAll in N_CM_LogFlags then // check and Log DevName Video Caps if not yet

    if PCMVideoProfile.CMDPStrPar1 = '' then // CMDPStrPar1 is '' if profile was created before version CMS3019
      PCMVideoProfile.CMDPStrPar1 := '1';

//    K_CMEDAccess.EDAStartCapture( PCMVideoProfile^.CMDPMTypeID );
    if not K_CMEDAccess.EDAStartCapture( [K_scfSlideUploadWOGap,
                                   K_scfSkipProfileDICOMDefaults,
                                   K_scfUseFullStayOnTopMode],
                                   TK_PCMDeviceProfile(PCMVideoProfile) ) then
      goto Fin;

    K_CMEDAccess.EDADCMSeriesStart();
    if PCMVideoProfile.CMDPStrPar1 = '1' then
    begin

      CMVideo2Form := N_CreateCMVideo2Form( nil, PCMVideoProfile );
      N_Dump2Str( 'CMVideo2Form Created' );

      N_FlagForm := 0; // flag which form is used for Pedal/Camera Button

      if CMVideo2Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
      //**** Mode 1
      with CMVideo2Form do //************************************* Mode 1
      begin
        CMVFCalcVideoAspect( PCMVideoProfile^.CMVResolution );

        //***** adjust maximized CMVideo2Form Size by just calculated CMVFCurVideoAspect
        AdditionalSize.X := CMVideo2Form.Width  - LeftPanel.Width;  // additional Form Width
        AdditionalSize.Y := CMVideo2Form.Height - LeftPanel.Height; // additional Form Height

        MaxWidth  := N_RectWidth( N_CurMonWAR );
        MaxHeight := N_RectHeight( N_CurMonWAR );

        MaxLPSize.X := MaxWidth  - AdditionalSize.X; // Max Left Panel Size
        MaxLPSize.Y := MaxHeight - AdditionalSize.Y;

        // Needed Left Panel Size
        NeededLPSize := N_AdjustSizeByAspect( aamDecRect, MaxLPSize, CMVFCurVideoAspect );

        CMVideo2Form.Left   := N_CurMonWAR.Left;
        CMVideo2Form.Top    := N_CurMonWAR.Top;

        CMVideo2Form.Width  := MaxWidth - ( MaxLPSize.X - NeededLPSize.X );
        CMVideo2Form.Height := MaxHeight - ( MaxLPSize.Y - NeededLPSize.Y );

        //***** Configure CMVFVideoCapt and some controls

        // Prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
        CMVFPrepare( [ N_CMVideo2F.cmvfpfInitialCall ] );
        CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
        rgOneTwoClicksClick( Nil );

        ShowModal();


        if K_CMEDAccess is TK_CMEDCSAccess then
          K_CMEDAccess.EDAFinCapture( )
        else
        // Show Properties/Diagnoses Form for Captured Media Objects
          K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                              format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                              PCMVideoProfile^.CMDPMTypeID,
                              K_CML1Form.LLLCaptHandler13.Caption, nil );
      end; // if CMVideo2Form <> nil then
      // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
    end // if CurVideoProfile.CMDPStrPar1 = '1' then
    else // for Mode 2 and 3
    //***** Mode 2
    if PCMVideoProfile.CMDPStrPar1 = '2' then //******************** Mode 2
    begin
      CMVideo3Form := N_CreateCMVideo3Form( nil, PCMVideoProfile );
      N_Dump2Str( 'CMVideo3Form Created' );

      N_FlagForm := 1; // flag which form is used for Pedal/Camera Button

      if CMVideo3Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
      with CMVideo3Form do
      begin
        //***** configure CMVFVideoCapt and some controls

        // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
        CMVFPrepare( [ N_CMVideo3F.cmvfpfInitialCall ] );
        CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
        rgOneTwoClicksClick( Nil );

        ShowModal();

        if K_CMEDAccess is TK_CMEDCSAccess then
          K_CMEDAccess.EDAFinCapture()
        else
        // Show Properties/Diagnoses Form for Captured Media Objects
          K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                              format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                              PCMVideoProfile^.CMDPMTypeID,
                              K_CML1Form.LLLCaptHandler13.Caption, nil );
      end;
    end
    else
    //***** Mode 3
    if PCMVideoProfile.CMDPStrPar1 = '3' then //******************** Mode 3
    begin
      CMVideo4Form := N_CreateCMVideo4Form( nil, PCMVideoProfile );
      N_Dump2Str( 'CMVideo4Form Created' );

      N_FlagForm := 2; // flag which form is used for Pedal/Camera Button

      if CMVideo4Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
      with CMVideo4Form do
      begin
        //***** configure CMVFVideoCapt and some controls

        // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
        CMVFPrepare( [ N_CMVideo4F.cmvfpfInitialCall ] );
        CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
        rgOneTwoClicksClick( Nil );

        ShowModal();

        N_Dump1Str('ModalResult after ShowModal - ' +
                                          IntToStr( CMVideo4Form.ModalResult) );

        while CMVideo4Form.ModalResult = idRetry do
        begin
          CMVideo4Form.Free;
          CMVideo4Form := N_CreateCMVideo4Form( nil, PCMVideoProfile );
          N_Dump2Str( 'CMVideo4Form Created' );

          N_FlagForm := 2; // flag which form is used for Pedal/Camera Button

          if CMVideo4Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
          with CMVideo4Form do
          begin

       {     CMVFCalcVideoAspect( PCMVideoProfile^.CMVResolution );

            //***** adjust maximized CMVideo2Form Size by just calculated CMVFCurVideoAspect
            AdditionalSize.X := CMVideo4Form.Width  - LeftPanel.Width;  // additional Form Width
            AdditionalSize.Y := CMVideo4Form.Height - LeftPanel.Height; // additional Form Height

            MaxWidth  := N_RectWidth( N_CurMonWAR );
            MaxHeight := N_RectHeight( N_CurMonWAR );

            MaxLPSize.X := MaxWidth  - AdditionalSize.X;
            MaxLPSize.Y := MaxHeight - AdditionalSize.Y;

            // Needed Left Panel Size
            NeededLPSize := N_AdjustSizeByAspect( aamDecRect, MaxLPSize, CMVFCurVideoAspect );

            CMVideo4Form.Left   := N_CurMonWAR.Left;
            CMVideo4Form.Top    := N_CurMonWAR.Top;

            CMVideo4Form.Width  := MaxWidth - ( MaxLPSize.X - NeededLPSize.X );
            CMVideo4Form.Height := MaxHeight - ( MaxLPSize.Y - NeededLPSize.Y );
         }
            //***** configure CMVFVideoCapt and some controls
            N_Dump1Str('N_CMRes before Prepare');
            // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
            CMVFPrepare( [ N_CMVideo4F.cmvfpfInitialCall ] );
            N_Dump1Str('N_CMRes after Prepare');
            CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
            rgOneTwoClicksClick( Nil );
            N_Dump1Str('N_CMRes before ShowModal');
            ShowModal();
            N_Dump1Str('N_CMRes after ShowModal');
            //SSASlides := N_CMVideo4Form.CMVFSSASlides;
          end;
        end;
        N_Dump1Str('N_CMRes after the whole block');

        if K_CMEDAccess is TK_CMEDCSAccess then
          K_CMEDAccess.EDAFinCapture()
        else
        // Show Properties/Diagnoses Form for Captured Media Objects
          K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                              format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                              PCMVideoProfile^.CMDPMTypeID,
                              K_CML1Form.LLLCaptHandler13.Caption, nil );
      end; // if CMVideo2Form <> nil then
      // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
    end;
    K_CMEDAccess.EDADCMSeriesFin();
  end else // DevName Device is NOT available
  begin
    N_Dump1Str('Device is not found');
    //K_CMShowMessageDlg( Format( K_CML1Form.LLLCaptHandler9.Caption, [ DevName ] ),
    //                                                            mtInformation );
    Form := TN_CMVideoResForm.Create( Application );
    Form.BaseFormInit( Nil, '', [ rspfMFRect, rspfCenter ], [ rspfAppWAR,
                                                               rspfShiftAll ] );
    Form.Caption := 'Video device disconnected';
    Form.DeviceName := DevName;
    Form.Label1.Caption := 'Your ' + ProfileName +
                                          ' is turned OFF or/and disconnected.';
    Form.Label2.Caption := 'Please, connect and/or turn your ' + ProfileName +
                                                                         ' ON.';
    Form.ShowModal();
    N_Dump1Str('ShowModal ends');
    if Form.ModalResult = mrYes then
    begin

      N_Dump1Str('Device is started');

      if cmpfVideoAll in N_CM_LogFlags then // check and Log DevName Video Caps if not yet
      begin
        if N_LogDevNamesList = nil then
          N_LogDevNamesList := TStringList.Create;

        if -1 = N_LogDevNamesList.IndexOf( DevName ) then // Log DevName Video Caps
        begin
          N_LogDevNamesList.Add( DevName ); // to Log only once in a session
          CapsList := TStringList.Create;
          N_DSEnumVideoCaps( DevName, CapsList );
          N_Dump2Strings( CapsList, 5 );
          CapsList.Clear;
          N_DSEnumVideoSizes( DevName, CapsList );
          N_Dump2Str( 'Resolutions: ' + CapsList.CommaText );
          CapsList.Free;
        end; // if -1 = N_LogDevNamesList.IndexOf( DevName ) then // Log DevName Video Caps
      end; // if cmpfVideoAll in N_CM_LogFlags then // check and Log DevName Video Caps if not yet

      if PCMVideoProfile.CMDPStrPar1 = '' then // CMDPStrPar1 is '' if profile was created before version CMS3019
        PCMVideoProfile.CMDPStrPar1 := '1';

  //    K_CMEDAccess.EDAStartCapture( PCMVideoProfile^.CMDPMTypeID );
      if not K_CMEDAccess.EDAStartCapture( [K_scfSlideUploadWOGap,
                                     K_scfSkipProfileDICOMDefaults,
                                     K_scfUseFullStayOnTopMode],
                                     TK_PCMDeviceProfile(PCMVideoProfile) ) then
        goto Fin;

      K_CMEDAccess.EDADCMSeriesStart();
      if PCMVideoProfile.CMDPStrPar1 = '1' then
      begin

        CMVideo2Form := N_CreateCMVideo2Form( nil, PCMVideoProfile );
        N_Dump2Str( 'CMVideo2Form Created' );

        N_FlagForm := 0; // flag which form is used for Pedal/Camera Button

        if CMVideo2Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
        //**** Mode 1
        with CMVideo2Form do //************************************* Mode 1
        begin
          CMVFCalcVideoAspect( PCMVideoProfile^.CMVResolution );

          //***** adjust maximized CMVideo2Form Size by just calculated CMVFCurVideoAspect
          AdditionalSize.X := CMVideo2Form.Width  - LeftPanel.Width;  // additional Form Width
          AdditionalSize.Y := CMVideo2Form.Height - LeftPanel.Height; // additional Form Height

          MaxWidth  := N_RectWidth( N_CurMonWAR );
          MaxHeight := N_RectHeight( N_CurMonWAR );

          MaxLPSize.X := MaxWidth  - AdditionalSize.X; // Max Left Panel Size
          MaxLPSize.Y := MaxHeight - AdditionalSize.Y;

          // Needed Left Panel Size
          NeededLPSize := N_AdjustSizeByAspect( aamDecRect, MaxLPSize, CMVFCurVideoAspect );

          CMVideo2Form.Left   := N_CurMonWAR.Left;
          CMVideo2Form.Top    := N_CurMonWAR.Top;

          CMVideo2Form.Width  := MaxWidth - ( MaxLPSize.X - NeededLPSize.X );
          CMVideo2Form.Height := MaxHeight - ( MaxLPSize.Y - NeededLPSize.Y );

          //***** Configure CMVFVideoCapt and some controls

          // Prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
          CMVFPrepare( [ N_CMVideo2F.cmvfpfInitialCall ] );
          CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
          rgOneTwoClicksClick( Nil );

          ShowModal();

          if K_CMEDAccess is TK_CMEDCSAccess then
            K_CMEDAccess.EDAFinCapture( )
          else
          // Show Properties/Diagnoses Form for Captured Media Objects
            K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                                format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                                PCMVideoProfile^.CMDPMTypeID,
                                K_CML1Form.LLLCaptHandler13.Caption, nil );
        end; // if CMVideo2Form <> nil then
        // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
      end // if CurVideoProfile.CMDPStrPar1 = '1' then
      else // for Mode 2 and 3
      //***** Mode 2
      if PCMVideoProfile.CMDPStrPar1 = '2' then //******************** Mode 2
      begin
        CMVideo3Form := N_CreateCMVideo3Form( nil, PCMVideoProfile );
        N_Dump2Str( 'CMVideo3Form Created' );

        N_FlagForm := 1; // flag which form is used for Pedal/Camera Button

        if CMVideo3Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
        with CMVideo3Form do
        begin
          //***** configure CMVFVideoCapt and some controls

          // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
          CMVFPrepare( [ N_CMVideo3F.cmvfpfInitialCall ] );
          CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
          rgOneTwoClicksClick( Nil );

          ShowModal();

          if K_CMEDAccess is TK_CMEDCSAccess then
            K_CMEDAccess.EDAFinCapture()
          else
          // Show Properties/Diagnoses Form for Captured Media Objects
            K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                                format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                                PCMVideoProfile^.CMDPMTypeID,
                                K_CML1Form.LLLCaptHandler13.Caption, nil );
        end;
      end
      else
      //***** Mode 3
      if PCMVideoProfile.CMDPStrPar1 = '3' then //******************** Mode 3
      begin
        CMVideo4Form := N_CreateCMVideo4Form( nil, PCMVideoProfile );
        N_Dump2Str( 'CMVideo4Form Created' );

        N_FlagForm := 2; // flag which form is used for Pedal/Camera Button

        if CMVideo4Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
        with CMVideo4Form do
        begin
          //***** configure CMVFVideoCapt and some controls

          // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
          CMVFPrepare( [ N_CMVideo4F.cmvfpfInitialCall ] );
          CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
          rgOneTwoClicksClick( Nil );

          ShowModal();

          N_Dump1Str('ModalResult after ShowModal - ' +
                                            IntToStr( CMVideo4Form.ModalResult) );

          while CMVideo4Form.ModalResult = idRetry do
          begin
            CMVideo4Form := N_CreateCMVideo4Form( nil, PCMVideoProfile );
            N_Dump2Str( 'CMVideo4Form Created' );

            N_FlagForm := 2; // flag which form is used for Pedal/Camera Button

            if CMVideo4Form <> nil then // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo2Form
            with CMVideo4Form do
            begin
              //***** configure CMVFVideoCapt and some controls

              // prepare CMVideoForm after CMVFVideoCapt is fully OK - new Portnoy code
              CMVFPrepare( [ N_CMVideo4F.cmvfpfInitialCall ] );
              CMVFShowNumCaptured(); // prepare NumCaptLabel.Caption
              rgOneTwoClicksClick( Nil );

              ShowModal();
              //SSASlides := N_CMVideo4Form.CMVFSSASlides;
            end;
          end;

          if K_CMEDAccess is TK_CMEDCSAccess then
            K_CMEDAccess.EDAFinCapture()
          else
          // Show Properties/Diagnoses Form for Captured Media Objects
            K_CMScanSlidesSave( CMVFNumStills + CMVFNumVideos,
                                format( K_CML1Form.LLLCaptHandler8.Caption, [ PCMVideoProfile^.CMDPCaption ]),
                                PCMVideoProfile^.CMDPMTypeID,
                                K_CML1Form.LLLCaptHandler13.Caption, nil );
        end; // if CMVideo4Form <> nil then
        // Created OK, if not, all needed diagnostics are inside N_CreateCMVideo4Form
      end;
      K_CMEDAccess.EDADCMSeriesFin();
    end;
  end; // Device is not found

  //*** Here: Finished OK or was not created

  Fin : //*****
  FreeAndNil( DevNamesList );
  CMRFVideoMode := False;
  N_Dump2Str( 'Fin TN_CMResForm.VideoOnExecuteHandler' );
  AddCMSActionFinish( ASender );
//  N_CM_MainForm.CMMCallActionByTimer( Nil, TRUE );
end; // procedure TN_CMResForm.VideoOnExecuteHandler

//************************************ TN_CMResForm.CalibrateCurActiveSlide ***
// Calibrate current active slide
//
//     Parameters
// AClibrationMode - Clibration Mode:
//#F
//  0 - calibration by line
//  1 - calibration by polyline
//  2 - calibration by resolution set
//#/F
//
procedure TN_CMResForm.CalibrateCurActiveSlide( AClibrationMode: Integer );
var
  UndoCapt : string;
begin

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if AClibrationMode = 2 then
    begin
    // Calibration by Resolution
      CMMSetMUFRectByActiveFrame();
      if K_CMSlideResolutionDlg( ) then
      begin
        ImgClibrated.Visible := TRUE;
        CMMFFinishVObjEditing( aObjCalibrateDPI.Caption,
            K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                      Ord(K_shImgActResolution) ) );
      end;
      CMMRestoreMUFRect();
    end
    else
    begin
    // Calibration by line
      if (EdVObjSelected = nil) or
         (EdVObjSelected.ObjName[1] <> 'M') then
      begin
        aObjPolylineMExecute( nil );
        EdAddVObj1RFA.LineCalibrateFlag := TRUE;
        EdAddVObj1RFA.PolyLineCalibrateFlag := AClibrationMode = 1;
        CMMFShowString( K_CML1Form.LLLObjEdit12.Caption
//           'Click at Calibrate Segment Start Vertex'
                       );
      end
      else
      begin
  {
        if Sender = nil then // Start Editing from creation
          N_Dump2Str( 'Start calibration value editing' );
  }
  //!!!! this Code is not use now
        CMMSetMUFRectByActiveFrame();
        if K_CMSlideCalibrateDlg( EdVObjSelected, EdAddVObj1RFA.PolyLineCalibrateFlag ) then
        begin
          ImgClibrated.Visible := TRUE;
          if EdAddVObj1RFA.PolyLineCalibrateFlag then
            UndoCapt := aObjCalibrateN.Caption
          else
            UndoCapt := aObjCalibrate1.Caption;
          CMMFFinishVObjEditing( UndoCapt,
              K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAVOObject),
                        Ord(K_shVOActCalibrate),
                        Ord( K_shVOTypeMeasureLine ) ) );
        end;
        CMMRestoreMUFRect();
  {
         else if Sender = nil then // Remove Calibration Segment if Cancel from Creation
          aEditUndoLastExecute( Sender ); // Not Needed because
  //        CMMFActiveEdFrame.DeleteVObjSelected(); //!! VObj Deltion is Not Enough
  }
      end;
    end;
  end;

end; // procedure TN_CMResForm.CalibrateCurActiveSlide


//****************************************** TN_CMResForm.AddCMSActionStart ***
// Add Info to CMS Log about Starting given Action
//
//     Parameters
// ASender - TAction Object
//
procedure TN_CMResForm.AddCMSActionStart( ASender: TObject );
var
  ACapt : string;
begin
//K_GetFreeSpaceProfile();
//N_Dump1Str( '!!! Start action MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
  // Clear CMMDisableActionsIsDone on Action start
  N_CM_MainForm.CMMDisableActionsIsDone := FALSE;

  ////////////////////////////////////
  // Free Main Memory after Application
  // initialization is finished - Dump Memory Profile
  //
  if K_CMSReservedSpaceHMem <> 0 then
  begin
    N_Dump2Str( '!!!MemFreeSpace reserved free' );
    Windows.GlobalFree( K_CMSReservedSpaceHMem );
    K_CMSReservedSpaceHMem := 0;

    K_GetFreeSpaceProfile();
    N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//    N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );

//    K_CMEDAccess.TmpStrings.Text := '!!!MemFreeSpace Info:';
//    K_GetFreeSpaceInfo( K_CMEDAccess.TmpStrings );
//    N_Dump1Strings( K_CMEDAccess.TmpStrings );

    K_CMSCheckMaxMemFreeTimeDelta := N_MemIniToDbl('CMS_UserDeb', 'MemFreeCheckMinutes', 0 ) / (24 * 60);
    if K_CMSCheckMaxMemFreeTimeDelta < 0 then K_CMSCheckMaxMemFreeTimeDelta := 0;

  end;
  //
  ///////////////////////////////////
//K_GetFreeSpaceProfile();
//N_Dump1Str( '!!!MemFreeSpace on ActionStart Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );

  N_CM_MainForm.CMMCropCancelProcObj( nil );

  if not (ASender is TAction) then Exit; // a precaution

  ACapt := TAction(ASender).Caption;
  if N_CM_MainForm.CMMFActiveEdFrame <> nil then
    ACapt := N_CM_MainForm.CMMFActiveEdFrame.Name + '  ' + ACapt;

  Inc(K_CMD4WWaitApplyDataCount);
  N_Dump1Str( format( 'Start Action %s WC=%d AMSC=%d',
    [ACapt,K_CMD4WWaitApplyDataCount,K_AMSCObj.AMSCObjsList.Count]) );
//  N_CheckAllExec( 'Start Action' );
  K_AMSCObj.AMSCheckExec('Start Action');

  N_CM_MainForm.CMMHideFlashlightIfNeeded();

  if N_CM_MainForm.CMMFActiveEdFrame <> nil then
    N_CM_MainForm.CMMFActiveEdFrame.Ed3FrClearEditContext();
end; // procedure TN_CMResForm.AddCMSActionStart

//***************************************** TN_CMResForm.AddCMSActionFinish ***
// Add Info to CMS Protocol about Finishing given Action
//
//     Parameters
// ASender - TAction Object
//
procedure TN_CMResForm.AddCMSActionFinish( ASender: TObject );
var
  ACapt : string;
  DT : TDateTime;
//  MaxFree : Integer;
  DBAccessFlag : Boolean;

label LExit;
begin
  if not (ASender is TAction) then Exit; // a precaution

  // Change Actions Enabled State after Action is finished
  // because Action may change context (do not call CMMFDisableActions if it is done early)
  if not K_CMD4WAppFinState and not N_CM_MainForm.CMMDisableActionsIsDone then
    N_CM_MainForm.CMMFDisableActions(nil);

  N_CM_MainForm.CMMDisableActionsIsDone := FALSE;

/////////////////////////////////
// DUMP Action Finish Info
//
  ACapt := TAction(ASender).Caption;

  if K_CMD4WAppFinState then
  begin
    N_Dump1Str( format( 'Finish Action %s on CMSAppFinState WC=%d', [ACapt,K_CMD4WWaitApplyDataCount] ) );
    K_CMD4WWaitApplyDataCount := 0; // Clear Wait Counter needed in DEMO mode
    if K_CMEDAccess <> nil then goto LExit;
    Exit;
  end;

  DBAccessFlag := K_CMEDAccess is TK_CMEDDBAccess;

  if N_CM_MainForm.CMMFActiveEdFrame <> nil then
    ACapt := N_CM_MainForm.CMMFActiveEdFrame.Name + ' ' + ACapt;

  if K_CMCloseOnFinActionFlag then
    ACapt := ACapt + ' CloseOnFinActionFlag ';

  if not K_CMEDAccess.AccessReady and DBAccessFlag then
    ACapt := ACapt + ' AccessNotReady ';

  N_Dump1Str( format( 'Finish Action start %s WC=%d AMSC=%d', [ACapt,K_CMD4WWaitApplyDataCount,K_AMSCObj.AMSCObjsList.Count] ) );
//
// DUMP Action Finish Info
/////////////////////////////////

//  N_CheckAllExec( 'Finish Action' );
  K_AMSCObj.AMSCheckExec('Finish Action');

  if K_CMCloseOnFinActionFlag then
  begin
  // CMS Close after Action Finishing
    N_CM_MainForm.CMMFAppClose( '***** CMS Close on Finish Action' );
    K_CMD4WWaitApplyDataCount := 0;
    K_CMCloseOnFinActionFlag := FALSE; // Clear Close OnFinActionFlag afte Action is Done
    Exit;
  end;

  if not K_CMEDAccess.AccessReady then
  begin
    N_Dump2Str( 'Clear Wait Counter in DEMO mode' );
    K_CMD4WWaitApplyDataCount := 0; // Clear Wait Counter in DEMO mode
    Exit; // If not AccessReady then Special Action Call during CMS Initialization
  end;
{
  if not K_CMEDAccess.AccessReady and not K_CMEDAccess.ExecCommandsFlag then
  begin
    if not DBAccessFlag then
      K_CMD4WWaitApplyDataCount := 0; // Clear Wait Counter in DEMO mode
    Exit; // If not AccessReady then Special Action Call during CMS Initialization
  end;
}
////////////////////////////
// Decrement Wait Counter
//
  Dec(K_CMD4WWaitApplyDataCount);

//  if K_CMD4WWaitApplyDataCount = -1 then
  if K_CMD4WWaitApplyDataCount < 0 then
  begin
    K_CMShowMessageDlg( K_CML1Form.LLLActionFin.Caption + ' ' + K_CML1Form.LLLPressOKToContinue.Caption,
//      'CMS wait error have been detected. Press OK to continue.',
        mtWarning, [mbOK] );
    K_CMD4WWaitApplyDataCount := 0
  end;
//
// Decrement Wait Counter
////////////////////////////


////////////////////////////////////
// Check Memory and Disk Free Space
//
  if  K_CMD4WWaitApplyDataCount = 0 then
  begin
{!!! Skip FreeMem Check after action - because of FreeMemoryCheck before action
    if not K_CMSCheckMemFreeSpaceDlg( '   ' + K_CML1Form.LLLPressOkToClose.Caption
//      '   Please press OK to close CMS.'
               ) then
    begin
      N_CM_MainForm.CMMFAppClose( '***** Close by Memory FreeSpace check' ); // close
      Exit;
    end
    else
}
      if K_CMEDAccess.EDACheckMinDiskFreeSpace() then goto LExit;
  end;
//
// Check Memory and Disk Free Space
////////////////////////////////////

////////////////////////////////////////
// Test Memory Free Space Limiting Value
//   Dump Memory Profile if needed
//
  if K_CMSCheckMaxMemFreeTimeDelta <> 0 then
  begin
  // Check Maximal Memory Free Space
    DT := Now();
    if DT > K_CMSCheckMaxMemFreeTimeStamp then
    begin
      K_CMSCheckMaxMemFreeTimeStamp := DT + K_CMSCheckMaxMemFreeTimeDelta;
      K_GetFreeSpaceProfile();
      N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//      N_Dump1Str( 'MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );

//      K_CMEDAccess.TmpStrings.Text := 'MemFreeSpace Info:';
//      K_GetFreeSpaceInfo( K_CMEDAccess.TmpStrings );
//      N_Dump1Strings( K_CMEDAccess.TmpStrings );
    end; // if DT > K_CMSCheckMaxMemFreeTimeStamp then
  end; // if K_CMSCheckMaxMemFreeTimeDelta <> 0 then
//
// Test Memory Free Space Limiting Value
////////////////////////////////////////

////////////////////////////////////////
//  Apply D4W buffered Commands
//
  if K_CMD4WWaitApplyDataCount = 0 then
  begin
    K_CMD4WApplyBufContext( );
    // Activate waiting actions
    N_CM_MainForm.CMMCallActionByTimer( nil, TRUE );
  end;
  N_Dump2Str( 'Finish Action fin' );

LExit:
  K_CMEDAccess.ExecCommandsFlag := FALSE; //

end; // procedure TN_CMResForm.AddCMSActionFinish

//********************************** TN_CMResForm.CheckSlideMemBeforeAction ***
// Check Current Active Slide Memory before given Action start
//
//     Parameters
// ASender - TAction Object
// ABufsCount - number of Buffers to check
// ADIBsCount - number of DIBs to check
//
function TN_CMResForm.CheckSlideMemBeforeAction( ASender: TObject; ABufsCount, ADIBsCount : Integer ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    Result := K_CMSCheckMemForSlideDlg( EdSlide, K_CML1Form.LLLMemory3.Caption,
//                '     There is not enough memory to finish the action.'+#13#10+
//                'Please close some open image(s) or restart Media Suite.',
                                        ABufsCount, ADIBsCount );
    if not Result then
    begin
      CMMFShowHideWaitState( FALSE );
      AddCMSActionFinish( ASender );
    end;
  end;
end; // procedure TN_CMResForm.CheckSlideMemBeforeAction


//****************************************** TN_CMResForm.MediaExportMarked ***
// Export Marked Slides
//
//     Parameters
// Sender - Event Sender
// AExportMode - 0 - any type, can be selected by user
//               1 - only DICOM format should be used
//               2 - only DICOMDIR format should be used
//               3 - export to D4W docs
//
// Export all Slides to Operate as *.bmp, *.jpg, *.tif, *.png, DICOM, DICOMDIR  file
//
// OnExecute MainActions.aMediaExportMarked Action handler
//
procedure TN_CMResForm.MediaExportMarked( Sender: TObject; AExportMode : Integer );
var
  SelectedVObj : TN_UDCompVis;
  ECount : Integer;
  SlidesArray : TN_UDCMSArray;
  i, UInd : Integer;
Label LExit;

begin
  SlidesArray := nil;
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );
  with N_CM_MainForm, K_CMEDAccess do
  begin
    ECount := Length(CMMAllSlidesToOperate);
    if K_CMStudyAddSlidesGUIModeFlag then
    begin
      SlidesArray := K_CMSAddStudyCurSlidesToArray( CMMAllSlidesToOperate );
      ECount := Length(SlidesArray);
    end
    else
      SlidesArray := Copy( CMMAllSlidesToOperate, 0, ECount );

// 2020-07-28 add Capt3DDevObjName <> ''
// 2020-09-25 add new condition for Dev3D objs
    // Skip Device 3D objects
    UInd := 0;
    for i := 0 to High(SlidesArray) do
      with SlidesArray[i].P.CMSDB do
      if not (cmsfIsImg3DObj in SFlags) or ((Capt3DDevObjName = '') or (MediaFExt = '')) then
      begin
        SlidesArray[UInd] := SlidesArray[i];
        Inc(UInd);
      end;

    if UInd < ECount then
    begin
      SetLength( SlidesArray, UInd );
      ECount := UInd;
    end;


    if (ECount = 0) or
       (0 <> EDACheckFilesAccessBySlidesSet( @SlidesArray[0], ECount,
           K_CML1Form.LLLFileAccessCheck10.Caption )) then // ' Press OK to stop export.'
    begin
      N_Dump2Str( 'Nothing to do ' + TAction(Sender).Caption );
      AddCMSActionFinish( Sender );
      Exit; // precaution
    end;

    K_CMSlidesLockForOpen( @SlidesArray[0], ECount, K_cmlrmOpenLock );

    if LockResCount = 0 then begin
      CMMFShowStringByTimer('Nothing to do!');
      AddCMSActionFinish( Sender );
      Exit;
    end;

    // Clear Selected Vobj
    SelectedVObj := nil;
    if (CMMFActiveEdFrame.EdSlide <> nil) and
       (0 <= K_IndexOfIntegerInRArray(
                     Integer(CMMFActiveEdFrame.EdSlide),
                     PInteger(@LockResSlides[0]),
                     LockResCount )) then
      SelectedVObj := CMMFActiveEdFrame.EdVObjSelected;

    if SelectedVObj <> nil then
      CMMFActiveEdFrame.ChangeSelectedVObj( 0 );

    K_CMSResampleSlides( @LockResSlides[0], LockResCount, CMMFShowString );

    ECount := K_CMExportSlidesDlg( @LockResSlides[0], LockResCount, AExportMode );


    CMMFFinishSlidesAction( SelectedVObj );

    if ECount > 0 then
      CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia4.Caption,
//        ' %d Media object(s) are exported',
                            [ECount] ) );

  end;
  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.MediaExportMarked

//**************************************** TN_CMResForm.DICOMImport ***
// Import media objects from DICOM Files
//
//     Parameters
// Sender - Event Sender
//
// OnExecute MainActions.aDICOMImport Action handler
//
procedure TN_CMResForm.DICOMImport(Sender: TObject; const AFilter : string );
var
  NumSlides: integer;
  ImpFiles: TStringList;
  ImportPath : string;
  i : Integer;
begin
  if K_CMShowGUIFlag then Exit; AddCMSActionStart( Sender );

  ImpFiles := TStringList.Create;
  if AFilter = '' then
  begin
    if K_CMImportFolderSelectDlg( ImportPath ) then
      ImpFiles.Add( ImportPath );
//      ImpFiles.Add( IncludeTrailingPathDelimiter(ImportPath) );
  end
  else
    K_CMImportFilesSelectDlg( ImpFiles, AFilter, 1 );

  NumSlides := 0;
  if ImpFiles.Count > 0 then
  begin
    if ImpFiles.Count > 1 then
    // Remove 'DICOMDIR' from ImpFiles names if number of selected files FilesFolders is more than 1
      for i := ImpFiles.Count - 1 downto 0 do
        if UpperCase(ExtractFileName(ImpFiles[i])) = 'DICOMDIR' then
          ImpFiles.Delete(i);

    if K_CMDICOMNewFlag then
      NumSlides := K_FCMDCMImport.K_CMSlidesImportFromDCMFList(ImpFiles)
    else
      NumSlides := K_CMSlidesImportFromDICOMDIR( ImpFiles );
  end; // if ImpFiles.Count > 0 then
  ImpFiles.Free;

  if NumSlides > 0 then
  begin
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;

  N_CM_MainForm.CMMFShowStringByTimer( Format( K_CML1Form.LLLMedia1.Caption,
//                ' %d Media object(s) are imported',
                   [NumSlides] ) );

  AddCMSActionFinish( Sender );
end; // procedure TN_CMResForm.DICOMImport

{*** TK_CMEGetSlideColorRFA ***}
procedure TK_CMEGetSlideColorRFA.Execute;
var
  WCursor : TCursor;
  ColorStr : string;
  ResStr   : string;
  CurColor : Integer;
  PixMapImageCoords: TPoint;
begin
  inherited;

  with TN_SGComp(ActGroup), OneSR, RFrame, TN_CMREdit3Frame(Parent) do
  begin
    if EdViewEditMode <> cmrfemGetSlideColor then begin
    // Close Self Activity
      Self.ActEnabled := false;
      // Clear Selected
      N_CM_MainForm.CMMFShowString( '' );
      if (EdViewEditMode <> cmrfemPoint) and
         (RFrame.Parent = N_CM_MainForm.CMMFActiveEdFrame) then
        N_CMResForm.aEditPointExecute(nil)
      else
        N_SetMouseCursorType( RFrame, crDefault );
      Exit;
    end;
{
    if SkipNextMouseDown and (CHType = htMouseDown) then begin
       SkipNextMouseDown := FALSE;
       Exit;
    end;
}
    WCursor := crDefault;
    with CCBuf, RFLogFramePRect do
      if (X >= 0) and (X <= Right) and
         (Y >= 0) and (Y <= Bottom) then
        WCursor := crGetColor; // Test Color Cursor
    if RFrame.Cursor <> WCursor then
      N_SetMouseCursorType( RFrame, WCursor );

    ColorStr := '';
    if WCursor = crGetColor  then begin

      with EdSlide, GetMapImage() do
      begin
        PixMapImageCoords := BufToDIBCoords( CCBuf );
        CurColor := DIBObj.GetPixColor( PixMapImageCoords );
      end;
{
function  N_ColorToHTMLHex     ( AColor: integer ): string;
function  N_ColorToQHTMLHex    ( AColor: integer ): string;
function  N_ColorToRGBDecimals ( AColor: integer ): string;
}
      ColorStr := N_ColorToRGBDecimals( CurColor );
      ResStr := Format( 'X,Y: %5d,%5d; C: ',
                         [PixMapImageCoords.X, PixMapImageCoords.Y] )
                + ColorStr;
      if CHType = htMouseDown then begin
         if ssLeft in CMKShift then
            K_PutTextToClipboard( ColorStr );
      end;
    end; // if WCursor = crGetColor  then begin

    N_CM_MainForm.CMMFShowString( ResStr );

  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end;
{*** end of TK_CMEGetSlideColorRFA ***}


{
//****************  TK_CMEditObjRFA class methods  *****************

//******************************************** TK_CMEditObjRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TK_CMEditObjRFA.SetActParams();
begin
  ActName := 'EditCMSObjects';
  inherited;
end; // procedure TK_CMEditObjRFA.SetActParams();

//************************************************* TK_CMEditObjRFA.Execute ***
// Edit CMS Objects
// Now only shows text in StatusBar about object under cursor
//
procedure TK_CMEditObjRFA.Execute();
var
  Str: string;
  UDComp: TN_UDCompVis;
  PCurFPoint: PFPoint;
  NewFPoint, NewPixPoint: TFPoint;
begin
  inherited;

  with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do
  begin
    Str := Format( 'pix X,Y,type = %d, %d, (%d) ', [CCBuf.X,CCBuf.Y, integer(SRType)] );

    if SRType <> srtNone then
    begin
      UDComp := SComps[SRCompInd].SComp; // founded Component
      Str := Str + UDComp.ObjName;

      if SRType = srtPolyline then
      begin
        Str := Str + Format( ' VI,SI= %d, %d', [VertInd, SegmInd] );

        if (CHType = htMouseDown) and (VertInd >= 0) then
        with TN_UDPolyline(UDComp) do
        begin
          SavedComp := UDComp;
          SavedInd  := VertInd;
          SavedCursorPos := CCBuf;
          SavedFPoint := UDPBufPixCoords[VertInd];
          MyDragMode := True;
        end;
      end; // if SRType = srtPlyline then
    end; // if SRType <> srtNone then

    if CHType = htMouseUp then
    begin
      MyDragMode := False;
    end;

    if MyDragMode then
    with TN_UDPolyline(SavedComp) do
    begin
      NewPixPoint.X := SavedFPoint.X + CCBuf.X - SavedCursorPos.X;
      NewPixPoint.Y := SavedFPoint.Y + CCBuf.Y - SavedCursorPos.Y;
      NewFPoint := N_AffConvF2FPoint( NewPixPoint, UDPFromBufPixCoefs4 );

      PCurFPoint := PFPoint(PISP()^.CPCoords.P(SavedInd));
      N_fp := PCurFPoint^; // debug
      PCurFPoint^ := NewFPoint;
      RedrawAllAndShow();
    end;

    N_CM_MainForm.CMMFShowString( Str );
  end; // with TN_SGComp(ActGroup), OneSR, ActGroup.RFrame do

end; // procedure TK_CMEditObjRFA.Execute
}




Initialization

  N_RFAClassRefs[N_ActCMEGetSlideColor]  := TK_CMEGetSlideColorRFA;


end.
