unit K_CML1F;
//CMS GUI multilingual support - K_1 Interface Texts Container

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TK_CML1Form = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    LLLPropDiagn1: TLabel;
    LLLPropDiagn2: TLabel;
    LLLUDViewFilters1: TLabel;
    LLLUDViewFilters2: TLabel;
    LLLPropDiagn3: TLabel;
    LLLUDViewFilters3: TLabel;
    LLLUDViewFilters4: TLabel;
    LLLUDViewFilters5: TLabel;
    LLLPropDiagn4: TLabel;
    LLLSelLoc1: TLabel;
    LLLSelLoc2: TLabel;
    LLLSelLoc3: TLabel;
    LLLSelLoc4: TLabel;
    LLLSelLoc5: TLabel;
    LLLSelLoc6: TLabel;
    LLLSelLoc7: TLabel;
    LLLSelLoc8: TLabel;
    LLLSelLoc9: TLabel;
    LLLSelLoc10: TLabel;
    LLLSelLoc11: TLabel;
    LLLSelLoc12: TLabel;
    LLLSelLoc13: TLabel;
    LLLSelPat1: TLabel;
    LLLSelPat2: TLabel;
    LLLSelPat3: TLabel;
    LLLSelPat4: TLabel;
    LLLSelPat5: TLabel;
    LLLSelPat6: TLabel;
    LLLSelPat7: TLabel;
    LLLSelPat8: TLabel;
    LLLSelPat9: TLabel;
    LLLSelPat10: TLabel;
    LLLSelPat11: TLabel;
    LLLSelPat12: TLabel;
    LLLSelPat13: TLabel;
    LLLSelPat14: TLabel;
    LLLObjEdit1: TLabel;
    LLLObjEdit2: TLabel;
    LLLObjEdit3: TLabel;
    LLLObjEdit4: TLabel;
    LLLObjEdit5: TLabel;
    LLLObjEdit6: TLabel;
    LLLObjEdit7: TLabel;
    LLLObjEdit8: TLabel;
    LLLObjEdit9: TLabel;
    LLLObjEdit10: TLabel;
    LLLObjEdit11: TLabel;
    LLLObjEdit12: TLabel;
    LLLObjEdit13: TLabel;
    LLLObjEdit14: TLabel;
    LLLObjEdit15: TLabel;
    LLLObjEdit16: TLabel;
    LLLObjEdit17: TLabel;
    LLLObjEdit18: TLabel;
    LLLObjEdit19: TLabel;
    LLLObjEdit20: TLabel;
    LLLObjEdit21: TLabel;
    LLLObjEdit22: TLabel;
    LLLObjEdit23: TLabel;
    LLLObjEdit24: TLabel;
    LLLObjEdit25: TLabel;
    LLLObjEdit26: TLabel;
    LLLImgFilterProc1: TLabel;
    LLLImgFilterProc2: TLabel;
    LLLImgFilterProc3: TLabel;
    LLLTools1: TLabel;
    LLLTools2: TLabel;
    LLLTools3: TLabel;
    LLLTools4: TLabel;
    LLLTools5: TLabel;
    LLLTools6: TLabel;
    LLLTools7: TLabel;
    LLLTools8: TLabel;
    LLLTools9: TLabel;
    LLLMedia1: TLabel;
    LLLMedia2: TLabel;
    LLLMedia3: TLabel;
    LLLMedia4: TLabel;
    LLLMedia5: TLabel;
    LLLMedia6: TLabel;
    LLLMedia7: TLabel;
    LLLEdit1: TLabel;
    LLLEdit2: TLabel;
    LLLEdit3: TLabel;
    LLLEdit4: TLabel;
    LLLEdit5: TLabel;
    LLLEdit6: TLabel;
    LLLEdit7: TLabel;
    LLLImportChng1: TLabel;
    LLLImportChng2: TLabel;
    LLLImportChng3: TLabel;
    LLLImportChng4: TLabel;
    LLLRebuildSlidesView1: TLabel;
    LLLDBImportRev1: TLabel;
    LLLDBImportRev2: TLabel;
    LLLDBImportRev3: TLabel;
    LLLDBImportRev4: TLabel;
    LLLDBImportRev5: TLabel;
    LLLDBImportRev6: TLabel;
    LLLDBImportRev7: TLabel;
    LLLDBImportRev8: TLabel;
    LLLSupport1: TLabel;
    LLLSupport2: TLabel;
    LLLProfile1: TLabel;
    LLLProfile2: TLabel;
    LLLUndoRedo1: TLabel;
    LLLHist1: TLabel;
    LLLPrefEdit1: TLabel;
    LLLPrefEdit2: TLabel;
    LLLPrefEdit3: TLabel;
    LLLPrefEdit4: TLabel;
    LLLGASettings1: TLabel;
    LLLGASettings2: TLabel;
    LLLGASettings3: TLabel;
    LLLGASettings4: TLabel;
    LLLExport1: TLabel;
    LLLExport2: TLabel;
    LLLDistUnitsFormat: TComboBox;
    LLLDistUnitsAliase: TComboBox;
    LLLResolutionUnitsAliase: TComboBox;
    TabSheet2: TTabSheet;
    LLLSysInfo1: TLabel;
    LLLSysInfo2: TLabel;
    LLLSysInfo3: TLabel;
    LLLSysInfo4: TLabel;
    LLLThumbsRFrame1: TLabel;
    LLLThumbsRFrame2: TLabel;
    LLLThumbsRFrame3: TLabel;
    LLLThumbsRFrame4: TLabel;
    LLLDBImport1: TLabel;
    LLLDBImport2: TLabel;
    LLLDBImport3: TLabel;
    LLLDBImport4: TLabel;
    LLLDBImport5: TLabel;
    LLLDBImport6: TLabel;
    LLLDBImport7: TLabel;
    LLLDBImport8: TLabel;
    LLLDBImport9: TLabel;
    LLLDBImport10: TLabel;
    LLLDBImport11: TLabel;
    LLLDBImport12: TLabel;
    LLLDBImport13: TLabel;
    LLLDBImport14: TLabel;
    LLLDBImport15: TLabel;
    LLLSlidesOpen1: TLabel;
    LLLSlidesOpen2: TLabel;
    LLLSlidesOpen3: TLabel;
    LLLSlidesOpen4: TLabel;
    LLLSlidesOpen5: TLabel;
    LLLSlidesOpen6: TLabel;
    LLLSlidesOpen7: TLabel;
    LLLSlidesOpen8: TLabel;
    LLLIntegrityCheck1: TLabel;
    LLLIntegrityCheck2: TLabel;
    LLLIntegrityCheck3: TLabel;
    LLLIntegrityCheck4: TLabel;
    LLLIntegrityCheck5: TLabel;
    LLLIntegrityCheck6: TLabel;
    LLLIntegrityCheck7: TLabel;
    LLLIntegrityCheck8: TLabel;
    LLLDBRecovery1: TLabel;
    LLLDBRecovery2: TLabel;
    LLLDBRecovery3: TLabel;
    LLLDBRecovery4: TLabel;
    LLLDBRecovery5: TLabel;
    LLLSADialogs1: TLabel;
    LLLSADialogs2: TLabel;
    LLLSADialogs3: TLabel;
    LLLSADialogs4: TLabel;
    LLLSADialogs5: TLabel;
    LLLSADialogs6: TLabel;
    LLLSADialogs7: TLabel;
    LLLReport8: TLabel;
    LLLReport9: TLabel;
    LLLReport1: TLabel;
    LLLReport2: TLabel;
    LLLReport3: TLabel;
    LLLReport4: TLabel;
    LLLReport5: TLabel;
    LLLReport6: TLabel;
    LLLReport7: TLabel;
    LLLFileAccessCheck10: TLabel;
    LLLFileAccessCheck11: TLabel;
    LLLFileAccessCheck12: TLabel;
    LLLFileAccessCheck13: TLabel;
    LLLFileAccessCheck14: TLabel;
    LLLChangeSlideAttrs: TLabel;
    LLLSetSessionCont1: TLabel;
    LLLSetSessionCont2: TLabel;
    LLLSetSessionCont3: TLabel;
    LLLSetSessionCont4: TLabel;
    LLLFileAccessCheck1: TLabel;
    LLLFileAccessCheck2: TLabel;
    LLLFileAccessCheck3: TLabel;
    LLLFileAccessCheck4: TLabel;
    LLLFileAccessCheck5: TLabel;
    LLLFileAccessCheck6: TLabel;
    LLLFileAccessCheck7: TLabel;
    LLLFileAccessCheck8: TLabel;
    LLLFileAccessCheck9: TLabel;
    LLLPrint1: TLabel;
    LLLPrint2: TLabel;
    LLLSelectProfileIcons: TLabel;
    LLLCloseCMS: TLabel;
    LLLReportHeaderTexts: TComboBox;
    LLLSysInfoProgress: TComboBox;
    LLLButtonCtrlTexts: TComboBox;
    TabSheet3: TTabSheet;
    LLLPathChange1: TLabel;
    LLLPathChange2: TLabel;
    LLLPathChange3: TLabel;
    LLLPathChange4: TLabel;
    LLLPathChange5: TLabel;
    LLLPathChange6: TLabel;
    LLLPathChange7: TLabel;
    LLLPathChange8: TLabel;
    LLLPathChange9: TLabel;
    LLLPathChange10: TLabel;
    LLLPathChange11: TLabel;
    LLLPathChange12: TLabel;
    LLLPathChange13: TLabel;
    LLLPathChange14: TLabel;
    LLLPathChange15: TLabel;
    LLLPathChange16: TLabel;
    LLLPathChange17: TLabel;
    LLLPathChange18: TLabel;
    LLLPathChange19: TLabel;
    LLLPathChange20: TLabel;
    LLLPathChange21: TLabel;
    LLLPathChange22: TLabel;
    LLLPathChange23: TLabel;
    LLLPathChange24: TLabel;
    LLLPathChange25: TLabel;
    LLLPathChange26: TLabel;
    LLLPathChange27: TLabel;
    LLLPathChange28: TLabel;
    LLLPathChange29: TLabel;
    LLLPathChange30: TLabel;
    LLLPathChange31: TLabel;
    LLLPathChange32: TLabel;
    LLLPathChange33: TLabel;
    LLLPathChange34: TLabel;
    LLLPathChange35: TLabel;
    LLLPathChange36: TLabel;
    LLLPathChange37: TLabel;
    LLLPathChange38: TLabel;
    LLLPathChange39: TLabel;
    LLLSysErrMes: TLabel;
    LLLSlidesLock1: TLabel;
    LLLSlidesLock2: TLabel;
    LLLSlidesLock3: TLabel;
    LLLSlidesLock4: TLabel;
    LLLPrepVideoFile1: TLabel;
    LLLPrepVideoFile2: TLabel;
    TabSheet4: TTabSheet;
    LLLCaptHandler1: TLabel;
    LLLCaptHandler2: TLabel;
    LLLCaptHandler3: TLabel;
    LLLCaptHandler4: TLabel;
    LLLCaptHandler5: TLabel;
    LLLCaptHandler6: TLabel;
    LLLCaptHandler7: TLabel;
    LLLCaptHandler8: TLabel;
    LLLCaptHandler9: TLabel;
    LLLCaptHandler10: TLabel;
    LLLCaptHandler11: TLabel;
    LLLCaptHandler12: TLabel;
    LLLCaptHandler13: TLabel;
    LLLCaptHandler14: TLabel;
    LLLCaptHandler15: TLabel;
    LLLExpProcTexts: TComboBox;
    LLLExpColNames: TComboBox;
    LLLExpImpRowNames: TComboBox;
    LLLImpColNames: TComboBox;
    LLLImpProcTexts: TComboBox;
    LLLExpImpNotSingleUser: TLabel;
    LLLImpFileIsMissing: TLabel;
    LLLImpFin: TLabel;
    LLLExpFin: TLabel;
    LLLImpReadFileError: TLabel;
    LLLImpReadFileError1: TLabel;
    LLLExpWrongLinkFName: TLabel;
    LLLSynchFin: TLabel;
    LLLSetFIO1: TLabel;
    LLLSetFIO2: TLabel;
    LLLShortcutNone: TLabel;
    LLLLinkCLFSetup1: TLabel;
    LLLLinkCLFSetup2: TLabel;
    LLLLinkCLFSetup3: TLabel;
    LLLProceed: TLabel;
    LLLNothingToDo: TLabel;
    LLLPressOkToClose: TLabel;
    LLLPressYesToProceed: TLabel;
    LLLPressOKToContinue: TLabel;
    LLLDelConfirm: TLabel;
    LLLActProceed1: TLabel;
    LLLSave1: TLabel;
    LLLSave2: TLabel;
    LLLLinks1: TLabel;
    LLLLinks2: TLabel;
    LLLLinks3: TLabel;
    LLLLinks4: TLabel;
    LLLLinks5: TLabel;
    LLLLinks6: TLabel;
    LLLLinks7: TLabel;
    LLLDelProfile1: TLabel;
    LLLDelProfile2: TLabel;
    LLLWrongNameOrPassword: TLabel;
    LLLWrongPassword: TLabel;
    LLLGAEnter1: TLabel;
    LLLGAEnter2: TLabel;
    LLLGAEnter3: TLabel;
    LLLFinishActionAndRestart: TLabel;
    LLLDelOpened1: TLabel;
    LLLClientSetup1: TLabel;
    LLLClientSetup2: TLabel;
    LLLClientSetup3: TLabel;
    LLLSAModeSetup: TLabel;
    LLLPolyline1: TLabel;
    LLLPolyline2: TLabel;
    LLLNewMediaType: TLabel;
    LLLSetLogFilesPath1: TLabel;
    LLLSetLogFilesPath2: TLabel;
    LLLRestoreDelSlides1: TLabel;
    LLLRestoreDelSlides2: TLabel;
    LLLFilesMove: TLabel;
    LLLConvImgToBMP2: TLabel;
    LLLConvImgToBMP3: TLabel;
    LLLConvImgToBMP4: TLabel;
    LLLConvImgToBMP1: TLabel;
    LLLConvImgToBMP5: TLabel;
    LLLRefreshSlides1: TLabel;
    LLLRefreshSlides2: TLabel;
    LLLRefreshSlides3: TLabel;
    LLLRefreshSlides4: TLabel;
    LLLRefreshSlides5: TLabel;
    LLLCalibrate: TLabel;
    LLLCalibrate1: TLabel;
    LLLCalibrate2: TLabel;
    LLLDevProfile1: TLabel;
    LLLDevProfile2: TLabel;
    LLLDevProfile3: TLabel;
    LLLDevProfile4: TLabel;
    LLLDelObjs1: TLabel;
    LLLDelObjs3: TLabel;
    LLLDeviceSetup: TLabel;
    LLLActionFin: TLabel;
    LLLAddToOpened1: TLabel;
    LLLAddToOpened2: TLabel;
    LLLAddToOpened3: TLabel;
    LLLAddToOpened4: TLabel;
    LLLAddToOpened5: TLabel;
    LLLCheckVideoFile1: TLabel;
    LLLCheckVideoFile2: TLabel;
    LLLCheckVideoFile3: TLabel;
    LLLFreeSpaceWarn1: TLabel;
    LLLFreeSpaceWarn2: TLabel;
    LLLSelProv1: TLabel;
    LLLSelProv2: TLabel;
    LLLSelProv3: TLabel;
    LLLSelProv4: TLabel;
    LLLSelProv5: TLabel;
    LLLSelProv6: TLabel;
    LLLSelProv7: TLabel;
    LLLSelProv8: TLabel;
    LLLSelProv9: TLabel;
    LLLSelProv10: TLabel;
    LLLSelProv11: TLabel;
    LLLSelProv12: TLabel;
    LLLSelProv13: TLabel;
    LLLSlidesDel1: TLabel;
    LLLSlidesDel2: TLabel;
    LLLSlidesDel3: TLabel;
    LLLSlidesDel4: TLabel;
    LLLSlidesDel5: TLabel;
    LLLDupl1: TLabel;
    LLLDupl2: TLabel;
    LLLDupl3: TLabel;
    LLLDupl4: TLabel;
    LLLECache1: TLabel;
    LLLECache2: TLabel;
    LLLECache3: TLabel;
    LLLECache4: TLabel;
    LLLECache5: TLabel;
    LLLECache6: TLabel;
    LLLECache7: TLabel;
    LLLECache8: TLabel;
    LLLECache9: TLabel;
    LLLECache10: TLabel;
    LLLECache11: TLabel;
    LLLECache12: TLabel;
    LLLECache13: TLabel;
    LLLECache14: TLabel;
    LLLECache15: TLabel;
    LLLFileImport1: TLabel;
    LLLFileImport2: TLabel;
    LLLFileImport3: TLabel;
    LLLVideoExport: TLabel;
    LLLDemoConstraints1: TLabel;
    LLLDemoConstraints2: TLabel;
    LLLImportNotes: TLabel;
    LLLAppInit1: TLabel;
    LLLAppInit2: TLabel;
    LLLAppInit3: TLabel;
    LLLAppInit4: TLabel;
    LLLAppInit5: TLabel;
    LLLAppInit6: TLabel;
    LLLAppInit7: TLabel;
    LLLAppInit8: TLabel;
    LLLAppInit18: TLabel;
    LLLAppInit9: TLabel;
    LLLAppInit10: TLabel;
    LLLAppInit11: TLabel;
    LLLAppInit12: TLabel;
    LLLAppInit13: TLabel;
    LLLAppInit14: TLabel;
    LLLAppInit15: TLabel;
    LLLAppInit16: TLabel;
    LLLAppInit17: TLabel;
    LLLDelOpened2: TLabel;
    TabSheet5: TTabSheet;
    LLLRegister1: TLabel;
    LLLRegister2: TLabel;
    LLLRegister3: TLabel;
    LLLRegister4: TLabel;
    LLLRegister5: TLabel;
    LLLRegister6: TLabel;
    LLLRegister7: TLabel;
    LLLRegister8: TLabel;
    LLLRegister9: TLabel;
    LLLRegister10: TLabel;
    LLLRegister11: TLabel;
    LLLRegister12: TLabel;
    LLLRegister13: TLabel;
    LLLRegister14: TLabel;
    LLLRegister15: TLabel;
    LLLRegister16: TLabel;
    LLLRegister17: TLabel;
    LLLRegister18: TLabel;
    LLLRegister19: TLabel;
    LLLRegister20: TLabel;
    LLLMPatAppTaskBar: TLabel;
    LLLMPatAppTitleBar: TLabel;
    LLLMPatAppVIPTitleBar: TLabel;
    LLLMPatAppLockTitleBar: TLabel;
    LLLMPatAppLockMes: TLabel;
    LLLMPatMailSubject: TLabel;
    LLLMPatPrintPatDetails1: TLabel;
    LLLMPatPrintPatDetails2: TLabel;
    LLLRegisterType: TComboBox;
    LLLRegister21: TLabel;
    LLLStudy1: TLabel;
    LLLStudy2: TLabel;
    LLLStudy3: TLabel;
    LLLStudy4: TLabel;
    LLLStudy5: TLabel;
    LLLStudyColorsList: TComboBox;
    LLLStudyNameNone: TLabel;
    LLLExpFileNameParts: TComboBox;
    LLLMedia8: TLabel;
    LLLFixMediaTypes: TComboBox;
    LLLIniMediaTypes: TComboBox;
    LLLPrintPageTexts: TComboBox;
    LLLPrintSlideTexts: TComboBox;
    LLLDBRecovery6: TLabel;
    LLLDBRecovery7: TLabel;
    LLLFileImport5: TLabel;
    LLLEmail1: TLabel;
    LLLEmail2: TLabel;
    LLLEmail3: TLabel;
    LLLEmail4: TLabel;
    LLLMemory2: TLabel;
    LLLMemory1: TLabel;
    LLLMemory3: TLabel;
    LLLMemory4: TLabel;
    LLLMemory5: TLabel;
    LLLMemory6: TLabel;
    LLLMemory7: TLabel;
    LLLMemory8: TLabel;
    LLLMemory9: TLabel;
    LLLConvImgToBMP6: TLabel;
    LLLResampleLarge1: TLabel;
    LLLResampleLarge2: TLabel;
    LLLResampleLarge3: TLabel;
    LLLResampleLarge4: TLabel;
    LLLResampleLarge5: TLabel;
    LLLResampleLarge0: TLabel;
    LLLDBRecovery8: TLabel;
    LLLDBRecovery9: TLabel;
    LLLCreateStudyFiles1: TLabel;
    LLLCreateStudyFiles2: TLabel;
    LLLCreateStudyFiles3: TLabel;
    LLLCreateStudyFiles4: TLabel;
    LLLCopyMovePatData1: TLabel;
    LLLCopyMovePatData2: TLabel;
    LLLECache16: TLabel;
    LLLMPatHPCommoPart: TLabel;
    LLLMPatHPSlidePart: TLabel;
    LLLMemory10: TLabel;
    LLLAppInit19: TLabel;
    LLLDBRecovery10: TLabel;
    LLLImg3D1: TLabel;
    LLLImg3D2: TLabel;
    LLLImg3D3: TLabel;
    LLLImg3D4: TLabel;
    LLLIU1: TLabel;
    LLLIUCapt: TLabel;
    LLLFileAccessCheck31: TLabel;
    LLLFileAccessCheck34: TLabel;
    LLLIntegrityCheck9: TLabel;
    LLLDBRecovery11: TLabel;
    LLLDBRecovery12: TLabel;
    LLLDBRecovery13: TLabel;
    LLLObjEdit27: TLabel;
    LLLEmail5: TLabel;
    LLLObjEdit28: TLabel;
    LLLCheckVideoFile4: TLabel;
    LLLSysInfo5: TLabel;
    LLLCheckImg3DFolder1: TLabel;
    LLLCaptToStudy1: TLabel;
    LLLSysInfo6: TLabel;
    LLLStudy6: TLabel;
    LLLStudy7: TLabel;
    LLLPathChange40: TLabel;
    LLLDICOM1: TLabel;
    LLLDICOM2: TLabel;
    LLLExport3: TLabel;
    LLLExport4: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  K_CML1Form: TK_CML1Form;

  K_CMSIniMediaTypes : TStringlist;
  K_CMSFixMediaTypes : TStringlist;
  K_CMSPrintPageTexts : TStringlist;
  K_CMSPrintSlideTexts : TStringlist;
  K_CMSColorizePalettes : TStringlist;

implementation

{$R *.dfm}

uses K_CLib;

procedure TK_CML1Form.FormCreate(Sender: TObject);
begin
// Add Texts from IniFile
  inherited;
  K_SetStringsByVaues( LLLIniMediaTypes.Items, K_CMSIniMediaTypes );
  K_SetStringsByVaues( LLLFixMediaTypes.Items, K_CMSFixMediaTypes );
  K_SetStringsByVaues( LLLPrintPageTexts.Items, K_CMSPrintPageTexts );
  K_SetStringsByVaues( LLLPrintSlideTexts.Items, K_CMSPrintSlideTexts );
//  K_SetStringsByIniSectionVaues( 'CMSFixMediaTypes', LLLFixMediaTypes.Items );
//  K_SetStringsByIniSectionVaues( 'CMSIniMediaTypes', LLLIniMediaTypes.Items );
//  K_SetStringsByIniSectionVaues( 'CMSPrintPageTexts', LLLPrintPageTexts.Items );
//  K_SetStringsByIniSectionVaues( 'CMSPrintSlideTexts', LLLPrintSlideTexts.Items );
end;

Initialization
  K_CMSIniMediaTypes := TStringlist.Create;
  K_CMSIniMediaTypes.CommaText :=
  '"1=Cephalometric","2=Intraoral","3=Intraoral Camera",' +
  '"4=Panoramic","5=Digital Photo’s","6=Documents"';

  K_CMSFixMediaTypes := TStringlist.Create;
  K_CMSFixMediaTypes.CommaText := '0=Unassigned';

  K_CMSPrintPageTexts  := TStringlist.Create;
  K_CMSPrintPageTexts.CommaText :=
  '"PageHeader=Page Header",' +
  '"PageFooter=Printed: (#PrintDate#) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Page (#PageNumber#) of (#PageCount#)",' +
  '"PageFooter1=Printed: (#PrintDate#) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"';

  K_CMSPrintSlideTexts := TStringlist.Create;
  K_CMSPrintSlideTexts.CommaText :=
  '"SlideHeader=(#SlideDTTaken#) (#SlideChartNo#)","SlideFooter=(#SlideDiagn#)"';
//  '"SlideHeader=(#SlideDTTaken#) (ID: (#SlideID#))","SlideFooter="';


  K_CMSColorizePalettes := TStringlist.Create;
  K_CMSColorizePalettes.CommaText :=
  '"Sepia=#000000, #FFEE88","Hot=#000000, #FF0000, #FFFFFF",' +
  '"Black-Blue-Cyan-White=#000000, #0000FF, #00FFFF, #FFFFFF",' +
  '"Blue-Yellow-Green=#0000FF, #FFFF00, #00FF00",' +
  '"Blue-Magenta-Red=#0000FF, #FF00FF, #FF0000",' +
  '"Multicolour 1=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FF0000",' +
  '"Multicolour 2=#FFFFFF, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Multicolour 3=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF"';
{
  '"Sepia=#000000, #FFEE88","Hot=#000000, #FF0000, #FFFFFF",' +
  '"Black-Blue-Cyan-White=#000000, #0000FF, #00FFFF, #FFFFFF",' +
  '"Blue-Yellow-Green=#0000FF, #FFFF00, #00FF00",' +
  '"Blue-Magenta-Red=#0000FF, #FF00FF, #FF0000",' +
  '"Colorize5.7_1=#00FFFF, #FFFF00, #000000, #FF00FF, #00FFFF",' +
  '"Colorize6_1=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FF0000",' +
  '"Colorize6_2=#FFFFFF, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Colorize6_3=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Colorize7_1=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF, #00FFFF",' +
  '"Colorize7_2=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #00FFFF, #FFFFFF, #FF00FF",' +
  '"Colorize7.4_1=#FF0000, #FF00FF, #0000FF, #000000, #FFFF00, #FFFFFF, #00FFFF, #00FF00",' +
  '"Colorize7.4_2=#FF0000, #FF00FF, #FFFFFF, #FFFF00, #000000, #0000FF, #00FFFF, #00FF00",' +
  '"Colorize8=#FFFF00, #FF0000, #FF00FF, #0000FF, #000000, #00FF00, #00FFFF, #FFFFFF, #FFFF00"';
//****
  '"Blue-Magenta-Red=#0000FF, #FF00FF, #FF0000",' +
  '"Colorize5.7_1=#00FFFF, #FFFF00, #000000, #FF00FF, #00FFFF",' +
  '"Colorize6_1=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FF0000",' +
  '"Colorize6_2=#FFFFFF, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Colorize6_3=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Colorize7_1=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF, #00FFFF",' +
  '"Colorize7_2=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #00FFFF, #FFFFFF, #FF00FF",' +
  '"Colorize7.4_1=#FF0000, #FF00FF, #0000FF, #000000, #FFFF00, #FFFFFF, #00FFFF, #00FF00",' +
  '"Colorize7.4_2=#FF0000, #FF00FF, #FFFFFF, #FFFF00, #000000, #0000FF, #00FFFF, #00FF00",' +
  '"Colorize8=#FFFF00, #FF0000, #FF00FF, #0000FF, #000000, #00FF00, #00FFFF, #FFFFFF, #FFFF00"';

  '"Cyan-Yellow-Black-Magenta-Cyan=#00FFFF, #FFFF00, #000000, #FF00FF, #00FFFF",' +
  '"Red-Yellow-Green-Black-Blue-Magenta-Red=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FF0000",' +
  '"White-Yellow-Green-Black-Blue-Magenta-White=#FFFFFF, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Red-Yellow-Green-Black-Blue-Magenta-White=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +
  '"Red-Yellow-Green-Black-Blue-Magenta-White-Cyan=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF, #00FFFF",' +
  '"Red-Yellow-Green-Black-Blue-Cyan-White-Magenta=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #00FFFF, #FFFFFF, #FF00FF",' +
  '"Red-Magenta-Blue-Black-Yellow-White-Cyan-Green=#FF0000, #FF00FF, #0000FF, #000000, #FFFF00, #FFFFFF, #00FFFF, #00FF00",' +
  '"Red-Magenta-White-Yellow-Black-Blue-Cyan-Green=#FF0000, #FF00FF, #FFFFFF, #FFFF00, #000000, #0000FF, #00FFFF, #00FF00",' +
  '"Yellow-Red-Magenta-Blue-Black-Green-Cyan-White-Yellow=#FFFF00, #FF0000, #FF00FF, #0000FF, #000000, #00FF00, #00FFFF, #FFFFFF, #FFFF00"';

//  '"Red2Black-Red-Yellow-Green-Black-Blue-Magenta-White-White2Cyan=#7F0000, #FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF, #7FFFFF",' +
//  '"Red2Black-Red-Yellow-Green-Black-Blue-Cyan-White-White2Magenta=#7F0000, #FF0000, #FFFF00, #00FF00, #000000, #0000FF, #00FFFF, #FFFFFF, #FF7FFF",' +

!!!!!
  '"Black-Magenta-Yellow-Cyan=#000000, #FF00FF, #FFFF00, #00FFFF",' +
  '"Black-Green-Yellow-White-Magenta-Blue-Cyan-Black-Green-Yellow-White-Magenta-Blue-Cyan='+
  '#000000, #00FF00, #FFFF00, #FFFFFF, #FF00FF, #0000FF, #00FFFF, #000000, #00FF00, #FFFF00, #FFFFFF, #FF00FF, #0000FF, #00FFFF",'+
  '"Yellow-White-Cyan-Green-Yellow-Magenta-Red-Black-Blue-Magenta-White-Blue-Cyan-Black-Green-Red-Yellow='+
  '#FFFF00, #FFFFFF, #FFFF00, #00FF00, #FFFF00, #FF00FF, #FF0000, #000000, #0000FF, #FF00FF, #FFFFFF, #0000FF, #00FFFF, #000000, #00FF00, #FF0000, #FFFF00"';
  '"Cyan-Green-Yellow-Black-Magenta-Blue-Cyan=#00FFFF, #00FF00, #00FF00, #000000, #FF00FF, #0000FF, #00FFFF",' +
  '"Cyan-Yellow-Green-Black-Blue-Magenta-Cyan=#00FFFF, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #00FFFF",' +
  '"Red-Yellow-Green-Black-Blue-Magenta-White=#FF0000, #FFFF00, #00FF00, #000000, #0000FF, #FF00FF, #FFFFFF",' +

}
Finalization
  K_CMSIniMediaTypes.Free;
  K_CMSFixMediaTypes.Free;
  K_CMSPrintPageTexts.Free;
  K_CMSPrintSlideTexts.Free;
  K_CMSColorizePalettes.Free;

end.
