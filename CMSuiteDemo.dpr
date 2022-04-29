program CMSuiteDemo;
//{%ToDo 'Proj_CMS.todo'}

uses
  VirtualUI_AutoRun in 'VirtualUI_AutoRun.pas',
  VirtualUI_SDK in 'VirtualUI_SDK.pas',
  L_VirtUI in 'L_VirtUI.pas',
  Forms,
  Windows,
  SysUtils,
  Dialogs,
  Classes,
  GDIPAPI in 'GDIPAPI.pas',
  GDIPOBJ in 'GDIPOBJ.pas',
  Twain in 'Twain.pas',
  Pipes in 'Pipes.pas',
  K_parse in 'K_parse.pas',
  K_BArrays in 'K_BArrays.pas',
  K_DTE1 in 'K_DTE1.pas',
  K_FSelectUDB in 'K_FSelectUDB.pas' {K_FormSelectUDB},
  K_UDConst in 'K_UDConst.pas',
  K_VFunc in 'K_VFunc.pas',
  K_UDT2 in 'K_UDT2.pas',
  K_UDC in 'K_UDC.pas',
  K_STBuf in 'K_STBuf.pas',
  K_IFUnc in 'K_IFUnc.pas',
  K_FEText in 'K_FEText.pas' {K_FormTextEdit},
  K_Giffile in 'K_Giffile.pas',
  K_FPathNameFr in 'K_FPathNameFr.pas' {K_FPathNameFrame: TFrame},
  K_FSDeb in 'K_FSDeb.pas' {K_FormMVDeb},
  K_SParse1 in 'K_SParse1.pas',
  K_Script1 in 'K_Script1.pas',
  K_IWatch in 'K_IWatch.pas' {K_FormInfoWatch},
  K_FSDebTM in 'K_FSDebTM.pas' {K_FormDebParams},
  K_FrRaEdit in 'K_FrRaEdit.pas' {K_FrameRAEdit: TFrame},
  N_RaEditF in 'N_RaEditF.pas' {N_RAEditForm},
  K_FSFList in 'K_FSFList.pas' {K_FormSelectFromUDDir},
  K_FDCSSpace in 'K_FDCSSpace.pas' {K_FormDCSSpace},
  K_FDCSpace in 'K_FDCSpace.pas' {K_FormDCSpace},
  K_FDCSProj in 'K_FDCSProj.pas' {K_FormDCSProjection},
  K_DCSpace in 'K_DCSpace.pas',
  K_FFName in 'K_FFName.pas' {K_FormFileName},
  K_Arch in 'K_Arch.pas',
  N_Color1Fr in 'N_Color1Fr.pas' {N_Color1Frame: TFrame},
  N_Color1F in 'N_Color1F.pas' {N_Color1Form},
  N_VRE3 in 'N_VRE3.pas',
  N_EdStrF in 'N_EdStrF.pas' {N_StrEditForm},
  N_GS1 in 'N_GS1.pas',
  N_Deb1 in 'N_Deb1.pas',
  N_Lib1 in 'N_Lib1.pas',
  N_ClassRef in 'N_ClassRef.pas',
  N_PWin in 'N_PWin.pas' {N_PWinForm},
  N_PBase in 'N_PBase.pas' {N_BasePage},
  N_Memo2Fr in 'N_Memo2Fr.pas' {N_Memo2Frame: TFrame},
  N_MemoFr in 'N_MemoFr.pas' {N_MemoFrame: TFrame},
  N_Gra2 in 'N_Gra2.pas',
  N_InfoF in 'N_InfoF.pas' {N_InfoForm},
  N_PDTree1 in 'N_PDTree1.pas',
  N_ExpImp1 in 'N_ExpImp1.pas',
  N_FNameFr in 'N_FNameFr.pas' {N_FileNameFrame: TFrame},
  N_RastFrOpF in 'N_RastFrOpF.pas' {N_RFrameOptionsForm},
  N_Gra3 in 'N_Gra3.pas',
  N_RichEdF in 'N_RichEdF.pas' {N_RichEditorForm},
  N_Lib2 in 'N_Lib2.pas',
  N_AffC4F in 'N_AffC4F.pas' {N_AffCoefs4Form},
  N_PlainEdF in 'N_PlainEdF.pas' {N_PlainEditorForm},
  N_MsgDialF in 'N_MsgDialF.pas' {N_MsgDialogForm},
  N_Rast1Fr in 'N_Rast1Fr.pas' {N_Rast1Frame: TFrame},
  N_Gra6 in 'N_Gra6.pas',
  N_DBF in 'N_DBF.pas',
  N_LibF in 'N_LibF.pas' {N_LibForm},
  N_SGRA1 in 'N_SGRA1.pas',
  N_MetafEdF in 'N_MetafEdF.pas' {N_MetafEdForm},
  N_UDat4 in 'N_UDat4.pas',
  N_UDCMap in 'N_UDCMap.pas',
  N_FNameF in 'N_FNameF.pas' {N_FileNameForm},
  N_ME1 in 'N_ME1.pas',
  N_NVTreeF in 'N_NVTreeF.pas' {N_NVTreeForm},
  N_GetUObjF in 'N_GetUObjF.pas' {N_GetUObjForm},
  N_Types in 'N_Types.pas',
  N_SGComp in 'N_SGComp.pas',
  K_FRaEdit in 'K_FRaEdit.pas' {K_FormRAEdit},
  K_RAEdit in 'K_RAEdit.pas',
  N_CompCL in 'N_CompCL.pas',
  K_IMVDAR in 'K_IMVDAR.pas',
  N_ACEdF in 'N_ACEdF.pas' {N_AffCoefsEditorForm},
  N_CObjVectEdF in 'N_CObjVectEdF.pas' {N_CObjVectEditorForm},
  N_Gra4 in 'N_Gra4.pas',
  K_FRASearch in 'K_FRASearch.pas' {K_FormRASearchReplace},
  K_FUDVTab in 'K_FUDVTab.pas' {K_FormUDVectorsTab},
  K_FrUDVTab in 'K_FrUDVTab.pas' {K_FrameRATabEdit: TFrame},
  K_FrUDV in 'K_FrUDV.pas' {K_FrameRAVectorEdit: TFrame},
  K_FUDV in 'K_FUDV.pas' {K_FormUDVector},
  N_WebBrF in 'N_WebBrF.pas' {N_WebBrForm},
  K_MVObjs in 'K_MVObjs.pas',
  N_Comp1 in 'N_Comp1.pas',
  K_FSFCombo in 'K_FSFCombo.pas' {K_FormSelectFromCombo},
  K_Script2 in 'K_Script2.pas',
  K_FUDRename in 'K_FUDRename.pas' {K_FormUDRename},
  N_NewUObjF in 'N_NewUObjF.pas' {N_NewUObjForm},
  N_ColViewFr in 'N_ColViewFr.pas' {N_ColorViewFrame: TFrame},
  N_CompBase in 'N_CompBase.pas',
  N_NVtreeOpF in 'N_NVtreeOpF.pas' {N_NVtreeOptionsForm},
  N_ExpF in 'N_ExpF.pas' {N_ExportForm},
  N_NVtreeFr in 'N_NVtreeFr.pas' {N_NVTreeFrame: TFrame},
  N_uobjfr in 'N_uobjfr.pas' {N_UObjFrame: TFrame},
  N_ME2 in 'N_ME2.pas',
  K_SBuf0 in 'K_SBuf0.pas',
  N_VVEdBaseF in 'N_VVEdBaseF.pas' {N_VVEdBaseForm},
  N_VRectEd1F in 'N_VRectEd1F.pas' {N_VRectEd1Form},
  N_VPointEd1F in 'N_VPointEd1F.pas' {N_VPointEd1Form},
  N_Comp2 in 'N_Comp2.pas',
  K_UDT1 in 'K_UDT1.pas' {N_VTreeFrame: TFrame},
  N_CMResF in 'N_CMResF.pas' {N_CMResForm},
  N_GCont in 'N_GCont.pas',
  K_MVMap0 in 'K_MVMap0.pas',
  N_PrintF in 'N_PrintF.pas' {N_PrintForm},
  N_MenuF in 'N_MenuF.pas' {N_MenuForm},
  N_SPLF in 'N_SPLF.pas',
  K_MVQR in 'K_MVQR.pas',
  N_VScalEd1F in 'N_VScalEd1F.pas' {N_VScalEd1Form},
  K_WSBuild1 in 'K_WSBuild1.pas',
  K_CLib0 in 'K_CLib0.pas',
  N_Lib0 in 'N_Lib0.pas',
  K_FRADD in 'K_FRADD.pas' {K_FRADataDeliveryForm},
  N_2DFunc1 in 'N_2DFunc1.pas',
  N_UObj2Fr in 'N_UObj2Fr.pas' {N_UObj2Frame: TFrame},
  N_EdParF in 'N_EdParF.pas' {N_EditParamsForm},
  N_RaEd2DF in 'N_RaEd2DF.pas' {N_RaEdit2DForm},
  K_CSpace in 'K_CSpace.pas',
  K_FrUDList in 'K_FrUDList.pas' {K_FrameUDList: TFrame},
  K_FCSDim in 'K_FCSDim.pas' {K_FormCSDim},
  K_FrCSDim2 in 'K_FrCSDim2.pas' {K_FrameCSDim2: TFrame},
  K_FrCSDim1 in 'K_FrCSDim1.pas' {K_FrameCSDim1: TFrame},
  K_FUDCSDim in 'K_FUDCSDim.pas' {K_FormUDCSDim},
  K_FUDCDim in 'K_FUDCDim.pas' {K_FormUDCDim},
  K_FUDCSDBlock in 'K_FUDCSDBlock.pas' {K_FormUDCSDBlock},
  K_FCSDBlock in 'K_FCSDBlock.pas' {K_FormCSDBlock},
  K_FrCSDBData in 'K_FrCSDBData.pas' {K_FrameCSDBDataEdit: TFrame},
  K_FrCSDBlock in 'K_FrCSDBlock.pas' {K_FrameCSDBlockEdit: TFrame},
  K_FUDCDCor in 'K_FUDCDCor.pas' {K_FormUDCDCor},
  K_FrCDCor in 'K_FrCDCor.pas' {K_FrameCDCor: TFrame},
  K_FrECDRel in 'K_FrECDRel.pas' {K_FrameECDRel: TFrame},
  K_FrCDRel in 'K_FrCDRel.pas' {K_FrameCDRel: TFrame},
  K_FCDRelShow in 'K_FCDRelShow.pas' {K_FormCDRelShow},
  N_HelpF in 'N_HelpF.pas' {N_HelpForm},
  N_BaseF in 'N_BaseF.pas' {N_BaseForm},
  K_IndGlobal in 'K_IndGlobal.pas',
  N_Comp3 in 'N_Comp3.pas',
  K_TSImport0 in 'K_TSImport0.pas',
  K_FMVMSOExp in 'K_FMVMSOExp.pas' {K_FormMVMSOExport},
  K_FRunSPLScript in 'K_FRunSPLScript.pas' {K_FormRunSPLScript},
  K_FRunDFPLScript in 'K_FRunDFPLScript.pas' {K_FormRunDFPLScript},
  N_AlignF in 'N_AlignF.pas' {N_AlignForm},
  N_NLConvF in 'N_NLConvF.pas' {N_NLConvForm},
  N_RVCTF in 'N_RVCTF.pas' {N_RastVCTForm},
  K_FBase in 'K_FBase.pas' {K_FormBase},
  K_Types in 'K_Types.pas',
  K_FViewComp in 'K_FViewComp.pas' {K_FormViewComp},
  N_StatFunc in 'N_StatFunc.pas',
  N_EdRecF in 'N_EdRecF.pas' {N_EditRecordForm},
  K_AInit0 in 'K_AInit0.pas',
  K_AUDTreeInit in 'K_AUDTreeInit.pas',
  K_ASPLInit in 'K_ASPLInit.pas',
  N_CM1 in 'N_CM1.pas',
  K_AMVInit0 in 'K_AMVInit0.pas',
  N_MapEdFr in 'N_MapEdFr.pas' {N_MapEdFrame: TFrame},
  K_TSImport4 in 'K_TSImport4.pas',
  N_Tst2F in 'N_Tst2F.pas' {N_Test2Form},
  N_CMREd3Fr in 'N_CMREd3Fr.pas' {N_CMREdit3Frame: TFrame},
  K_FCMPrint1 in 'K_FCMPrint1.pas' {K_FormCMPrint1},
  N_ButtonsF in 'N_ButtonsF.pas' {N_ButtonsForm},
  N_DGrid in 'N_DGrid.pas',
  N_MapTools in 'N_MapTools.pas',
  N_Act1 in 'N_Act1.pas',
  N_IconSelF in 'N_IconSelF.pas' {N_IconSelectionForm},
  K_FrCMSlideFilter in 'K_FrCMSlideFilter.pas' {K_FrameCMSlideFilter: TFrame},
  N_CM2 in 'N_CM2.pas',
  K_Gra0 in 'K_Gra0.pas',
  K_FCMMain6F in 'K_FCMMain6F.pas' {K_FormCMMain6},
  N_TranspFr in 'N_TranspFr.pas' {N_TranspFrame: TFrame},
  K_MapiControl in 'K_MapiControl.pas',
  N_AVRInit in 'N_AVRInit.pas',
  K_AInit1 in 'K_AInit1.pas',
  N_TstC1 in 'N_TstC1.pas',
  K_FCMDeviceSetup in 'K_FCMDeviceSetup.pas' {K_FormDeviceSetup},
  N_Video in 'N_Video.pas',
  K_FCMUndoRedo in 'K_FCMUndoRedo.pas' {K_FormCMUndoRedo},
  N_CMDevStatF in 'N_CMDevStatF.pas' {N_CMDevStatForm},
  K_FMVBase in 'K_FMVBase.pas' {K_FormMVBase},
  K_FMVBase0 in 'K_FMVBase0.pas' {K_FormMVBase0},
  N_MemoF in 'N_MemoF.pas' {N_MemoForm},
  K_FCMDistr in 'K_FCMDistr.pas' {K_FormCMDistr},
  N_Gra1 in 'N_Gra1.pas',
  K_FCMCaptButDelay in 'K_FCMCaptButDelay.pas' {K_FormCMCaptButDelay: K_FCMSetSlidesAttrs},
  K_FCMSDrawAttrs in 'K_FCMSDrawAttrs.pas' {K_FormCMSDrawAttrs},
  K_FCMSTextAttrs in 'K_FCMSTextAttrs.pas' {K_FormCMSTextAttrs},
  K_FCMSEmbAttrs in 'K_FCMSEmbAttrs.pas' {K_FormCMSEmboss},
  K_FCMSIsodensity in 'K_FCMSIsodensity.pas' {K_FormCMSIsodensity},
  K_FCMSNoiseRAttrs1 in 'K_FCMSNoiseRAttrs1.pas' {K_FormCMSNoiseRAttrs1},
  K_FCMSRotateByAngle in 'K_FCMSRotateByAngle.pas' {K_FormCMSRotateByAngle},
  K_FCMSFlashlightAttrs in 'K_FCMSFlashlightAttrs.pas' {K_FormCMSFlashlightAttrs},
  K_FCMPrefEdit in 'K_FCMPrefEdit.pas' {K_FormPrefEdit},
  N_BrigHist2F in 'N_BrigHist2F.pas' {N_BrigHist2Form},
  K_FCMECacheProc in 'K_FCMECacheProc.pas' {K_FormCMECacheProc},
  N_CMVideo2F in 'N_CMVideo2F.pas' {N_CMVideo2Form},
  N_CMSharp1F in 'N_CMSharp1F.pas' {N_CMSharp1Form},
  K_FCMSBriCoGam1 in 'K_FCMSBriCoGam1.pas' {K_FormCMSBriCoGam1},
  K_FCMSFPathChange1 in 'K_FCMSFPathChange1.pas' {K_FormCMSFPathChange1},
  K_FCMSFilesHandlingE in 'K_FCMSFilesHandlingE.pas' {K_FormCMSFilesHandlingE},
  K_FCMRegister in 'K_FCMRegister.pas' {K_FormCMRegister},
  K_FCMSlideIcon in 'K_FCMSlideIcon.pas' {K_FormCMSlideIcon},
  K_FCMProfileDevice in 'K_FCMProfileDevice.pas' {K_FormCMProfileDevice},
  K_FCMProfileSetting in 'K_FCMProfileSetting.pas' {K_FormCMProfileSetting},
  K_FCMFixStudyDataWarn in 'K_FCMFixStudyDataWarn.pas' {K_FormCMFixStudyDataWarn},
  K_FCMSCalibrate1 in 'K_FCMSCalibrate1.pas' {K_FormCMSCalibrate1},
  K_FCMImport in 'K_FCMImport.pas' {K_FormCMImport},
  K_FCMStudyTemplateSelect in 'K_FCMStudyTemplateSelect.pas' {K_FormCMStudyTemplateSelect},
  K_FFontAttrs in 'K_FFontAttrs.pas' {K_FormFontAttrs},
  N_CMFPedalSF in 'N_CMFPedalSF.pas' {N_CMFPedalSetupForm},
  K_FCMRegCode in 'K_FCMRegCode.pas' {K_FormCMRegCode},
  N_CMVideoProfileF in 'N_CMVideoProfileF.pas' {N_CMVideoProfileForm},
  N_CMTest1F in 'N_CMTest1F.pas' {N_CMTest1Form},
  K_FCMDeviceSetupEnter in 'K_FCMDeviceSetupEnter.pas' {K_FormCMDeviceSetupEnter},
  K_FCMImportExpToDCM in 'K_FCMImportExpToDCM.pas' {K_FormCMImportExpToDCM},
  K_CMTests in 'K_CMTests.pas',
  K_FCMImportPPL in 'K_FCMImportPPL.pas' {K_FormCMImportPPL},
  N_CMAboutF in 'N_CMAboutF.pas' {N_CMAboutForm},
  K_FCMSelectLocation in 'K_FCMSelectLocation.pas' {K_FormCMSelectLoc},
  K_FCMEFSyncProc in 'K_FCMEFSyncProc.pas' {K_FormCMEFSyncProc},
  K_FCMImportReverseEnter in 'K_FCMImportReverseEnter.pas' {K_FormCMImportReverseEnter},
  K_FCMEnterDBAPSW in 'K_FCMEnterDBAPSW.pas' {K_FormCMEnterDBAPSW},
  K_FCMGAdmEnter in 'K_FCMGAdmEnter.pas' {K_FormCMGAdmEnter},
  K_FCMEFSyncInfo in 'K_FCMEFSyncInfo.pas' {K_FormCMEFSyncInfo},
  K_FCMReportShow in 'K_FCMReportShow.pas' {K_FormCMReportShow},
  N_CMDebMP1 in 'N_CMDebMP1.pas',
  N_MSWord in 'N_MSWord.pas',
  N_CMExpRep in 'N_CMExpRep.pas',
  N_MSExcel in 'N_MSExcel.pas',
  K_FCMUTSetDBContexts in 'K_FCMUTSetDBContexts.pas' {K_FormCMUTSetDBContexts},
  K_FCMRemoveLogsHandling in 'K_FCMRemoveLogsHandling.pas' {K_FormCMRemoveLogsHandling},
  N_CMTstDelphiF in 'N_CMTstDelphiF.pas' {N_CMTestDelphiForm},
  N_CMOther2F in 'N_CMOther2F.pas' {N_CMOther2Form},
  K_FCMStart in 'K_FCMStart.pas' {K_FormCMStart},
  K_FCMUTLoadDBData3FSClear in 'K_FCMUTLoadDBData3FSClear.pas' {K_FormCMUTLoadDBData3FSClear},
  K_FCMSysInfo in 'K_FCMSysInfo.pas' {K_FormCMSysInfo},
  K_FCMSSharpAttrs11 in 'K_FCMSSharpAttrs11.pas' {K_FormCMSSharpAttrs11},
  K_FCMFSRecovery1 in 'K_FCMFSRecovery1.pas' {K_FormCMFSRecovery1},
  K_FCMImgFilterProcAttrs in 'K_FCMImgFilterProcAttrs.pas' {K_FormCMImgFilterProcAttrs},
  N_MainFFr in 'N_MainFFr.pas' {N_MainFormFrame: TFrame},
  N_CMMain5F in 'N_CMMain5F.pas' {N_CMMain5Form1},
  K_FCMLinkCLFSetup in 'K_FCMLinkCLFSetup.pas' {K_FormCMLinkCLFSetup},
  K_FCMSupport in 'K_FCMSupport.pas' {K_FormCMSupport},
  N_Gra0 in 'N_Gra0.pas',
  N_CMTest2F in 'N_CMTest2F.pas' {N_CMTest2Form},
  K_FCMSZoomMode in 'K_FCMSZoomMode.pas' {K_FormCMSZoomMode},
  N_CMRFA in 'N_CMRFA.pas',
  K_CMRFA in 'K_CMRFA.pas',
  K_FCMSFlashlightModeAttrs in 'K_FCMSFlashlightModeAttrs.pas' {K_FormCMSFlashlightModeAttrs},
  K_FCMSetSlidesAttrs2 in 'K_FCMSetSlidesAttrs2.pas' {K_FormCMSetSlidesAttrs2},
  K_FCMChangeStudiesAttrs in 'K_FCMChangeStudiesAttrs.pas' {K_FormCMChangeStudiesAttrs},
  K_CMCaptDevReg in 'K_CMCaptDevReg.pas',
  K_FCMProfileOther1 in 'K_FCMProfileOther1.pas' {K_FormCMProfileOther1},
  K_FTestUnit in 'K_FTestUnit.pas' {Form1},
  K_FCMSSharpAttrsN in 'K_FCMSSharpAttrsN.pas' {K_FormCMSSharpAttrsN},
  N_CMCaptDev5F in 'N_CMCaptDev5F.pas' {N_CMCaptDev5Form},
  N_CMCaptDev3sF in 'N_CMCaptDev3sF.pas' {N_CMCaptDev3Form},
  N_CMCaptDev5 in 'N_CMCaptDev5.pas',
  N_CMCaptDev1 in 'N_CMCaptDev1.pas',
  N_CMCaptDev3s in 'N_CMCaptDev3s.pas',
  N_CMCaptDev4 in 'N_CMCaptDev4.pas',
  N_CMCaptDev4F in 'N_CMCaptDev4F.pas' {N_CMCaptDev4Form},
  N_CMCaptDev6aF in 'N_CMCaptDev6aF.pas' {N_CMCaptDev6aForm},
  K_FrCMTeethChart1 in 'K_FrCMTeethChart1.pas' {K_FrameCMTeethChart1: TFrame},
  N_BrigHistFr in 'N_BrigHistFr.pas' {N_BrigHistFrame: TFrame},
  K_FCMImportChngAttrs in 'K_FCMImportChngAttrs.pas' {K_FormCMImportChngAttrs},
  N_CMCaptDev6 in 'N_CMCaptDev6.pas',
  K_FCMSUDefFilters1 in 'K_FCMSUDefFilters1.pas' {K_FormCMSUDefFilters1},
  K_FCMMain5F in 'K_FCMMain5F.pas' {K_FormCMMain5},
  K_CMCaptDevTest in 'K_CMCaptDevTest.pas',
  K_FCMSCalibrate in 'K_FCMSCalibrate.pas' {K_FormCMSCalibrate},
  K_FCMSSharpAttrs12 in 'K_FCMSSharpAttrs12.pas' {K_FormCMSSharpAttrs12},
  K_FCMSASetProvData in 'K_FCMSASetProvData.pas' {K_FormCMSASetProviderData},
  K_FCMSASelectLoc in 'K_FCMSASelectLoc.pas' {K_FormCMSASelectLocation},
  K_FCMSASelectPat in 'K_FCMSASelectPat.pas' {K_FormCMSASelectPatient},
  K_FCMSASetPatData in 'K_FCMSASetPatData.pas' {K_FormCMSASetPatientData},
  K_FCMSpecSettingsSetup in 'K_FCMSpecSettingsSetup.pas' {K_FormCMSpecSettings},
  N_CMCaptDevDemo2 in 'N_CMCaptDevDemo2.pas',
  N_CMCaptDevDemo1F in 'N_CMCaptDevDemo1F.pas' {N_CMCaptDevDemo1Form},
  N_CMCaptDev8aF in 'N_CMCaptDev8aF.pas' {N_CMCaptDev8aForm},
  N_CMCaptDev8SF in 'N_CMCaptDev8SF.pas' {N_CMCaptDev8Form},
  N_CMCaptDev8S in 'N_CMCaptDev8S.pas',
  N_CMCaptDev11F in 'N_CMCaptDev11F.pas' {N_CMCaptDev11Form},
  N_CMCaptDev11 in 'N_CMCaptDev11.pas',
  N_CMCaptDev11aF in 'N_CMCaptDev11aF.pas' {N_CMCaptDev11aForm},
  K_FCMProfileTwain in 'K_FCMProfileTwain.pas' {K_FormCMProfileTwain},
  K_FCMTWAIN in 'K_FCMTWAIN.pas' {K_FormCMTWAIN},
  K_FCMSSharpAttrs in 'K_FCMSSharpAttrs.pas' {K_FormCMSSharpAttrs},
  K_FCMSSharpAttrs1 in 'K_FCMSSharpAttrs1.pas' {K_FormCMSSharpAttrs1},
  N_PixMesFr in 'N_PixMesFr.pas' {N_PixMesFrame: TFrame},
  N_CMCaptDevDemo1 in 'N_CMCaptDevDemo1.pas',
  K_FCMSNoiseRAttrs in 'K_FCMSNoiseRAttrs.pas' {K_FormCMSNoiseRAttrs},
  K_Gra1 in 'K_Gra1.pas',
  K_FCMRemoteClientSetup in 'K_FCMRemoteClientSetup.pas' {K_FormCMRemoteClientSetup},
  K_FCMExportSlides in 'K_FCMExportSlides.pas' {K_FormCMExportSlides},
  K_FCMUTPrepDBData1 in 'K_FCMUTPrepDBData1.pas' {K_FormCMUTPrepDBData1},
  K_FCMSASelectProv in 'K_FCMSASelectProv.pas' {K_FormCMSASelectProvider},
  K_CML1F in 'K_CML1F.pas' {K_CML1Form},
  K_CMSLLL in 'K_CMSLLL.pas',
  K_FCMSAModeSetup in 'K_FCMSAModeSetup.pas' {K_FormCMSAModeSetup},
  N_CMTWAIN3 in 'N_CMTWAIN3.pas',
  N_CMTWAIN2F in 'N_CMTWAIN2F.pas' {N_CMTWAIN2Form},
  N_CMCaptDev0 in 'N_CMCaptDev0.pas',
  N_CMCaptDev9 in 'N_CMCaptDev9.pas',
  K_FMVTSImpUnRegs in 'K_FMVTSImpUnRegs.pas' {K_FormMVTSImpUnRegs},
  N_CML2F in 'N_CML2F.pas' {N_CML2Form},
  K_FCMSharpSmooth in 'K_FCMSharpSmooth.pas' {K_FormCMSharpSmooth},
  K_FCMImgProfileProcAttrs in 'K_FCMImgProfileProcAttrs.pas' {K_FormCMImgProfileProcAttrs},
  N_CML1F in 'N_CML1F.pas' {N_CML1Form},
  K_CML3F in 'K_CML3F.pas' {K_CML3Form},
  K_FCMSelectSlide in 'K_FCMSelectSlide.pas' {K_FormCMSelectSlide},
  K_FCMSetSlidesAttrs3 in 'K_FCMSetSlidesAttrs3.pas' {K_FormCMSetSlidesAttrs3},
  N_ImLib in 'N_ImLib.pas',
  K_FCMChangeSlidesAttrsN2 in 'K_FCMChangeSlidesAttrsN2.pas' {K_FormCMChangeSlidesAttrsN2},
  K_RImage in 'K_RImage.pas',
  N_K_Tmp in 'N_K_Tmp.pas',
  K_FCMSelectMaxPictSize in 'K_FCMSelectMaxPictSize.pas' {K_FormCMSelectMaxPictSize},
  N_CMCaptDev5dF in 'N_CMCaptDev5dF.pas' {N_CMCaptDev5dForm},
  N_CMCaptDev5aF in 'N_CMCaptDev5aF.pas' {N_CMCaptDev5aForm},
  N_CMVideo3F in 'N_CMVideo3F.pas' {N_CMVideo3Form},
  N_Video3 in 'N_Video3.pas',
  N_CMTst1 in 'N_CMTst1.pas',
  N_CMTWAIN1F in 'N_CMTWAIN1F.pas' {N_CMTWAIN1Form},
  K_CMTWAIN in 'K_CMTWAIN.pas',
  N_CMCaptDev7SF in 'N_CMCaptDev7SF.pas' {N_CMCaptDev7Form},
  N_CMCaptDev7S in 'N_CMCaptDev7S.pas',
  N_CMCaptDev7aF in 'N_CMCaptDev7aF.pas' {N_CMCaptDev7aForm},
  K_FCMCreateStudyFiles in 'K_FCMCreateStudyFiles.pas' {K_FormCMCreateStudyFiles},
  USBCam20SDK_TLB in 'USBCam20SDK_TLB.pas',
  K_FCMArchRestore in 'K_FCMArchRestore.pas' {K_FormCMArchRestore},
  K_FCMAltShiftMEnter in 'K_FCMAltShiftMEnter.pas' {K_FormCMAltShiftMEnter},
  K_URImage in 'K_URImage.pas',
  K_CMDCMDLib in 'K_CMDCMDLib.pas',
  K_FCMECacheRecoverMedia in 'K_FCMECacheRecoverMedia.pas' {K_FormCMCacheRecoverMedia},
  K_SBuf in 'K_SBuf.pas',
  K_CM1 in 'K_CM1.pas',
  K_FCMPresent in 'K_FCMPresent.pas' {K_FormCMPresent},
  N_Tst1F in 'N_Tst1F.pas' {N_TestForm},
  K_FCMSysSetup in 'K_FCMSysSetup.pas' {K_FormCMSysSetup},
  K_FCMScan in 'K_FCMScan.pas' {K_FormCMScan},
  K_FCMFSDump1 in 'K_FCMFSDump1.pas' {K_FormCMFSDump1},
  K_CMUtils in 'K_CMUtils.pas',
  K_FCMClientScan in 'K_FCMClientScan.pas' {K_FormCMClientScan},
  N_Tst1 in 'N_Tst1.pas',
  N_CMCaptDev13F in 'N_CMCaptDev13F.pas' {N_CMCaptDev13Form},
  N_CMCaptDev12 in 'N_CMCaptDev12.pas',
  N_CMCaptDev12F in 'N_CMCaptDev12F.pas' {N_CMCaptDev12Form},
  N_CMCaptDev13 in 'N_CMCaptDev13.pas',
  N_CMCaptDev13aF in 'N_CMCaptDev13aF.pas' {N_CMCaptDev13aForm},
  N_CMVideoProfileSF in 'N_CMVideoProfileSF.pas' {N_CMVideoProfileSForm},
  N_CMCaptDev14 in 'N_CMCaptDev14.pas',
  N_CMCaptDev14aF in 'N_CMCaptDev14aF.pas' {N_CMCaptDev14aForm},
  N_CMCaptDev14F in 'N_CMCaptDev14F.pas' {N_CMCaptDev14Form},
  N_CMCaptDev0_2 in 'N_CMCaptDev0_2.pas',
  K_FCMAutoRefreshLag in 'K_FCMAutoRefreshLag.pas' {K_FormCMAutoRefreshLag},
  N_CMCaptDev15SF in 'N_CMCaptDev15SF.pas' {N_CMCaptDev15Form},
  N_CMCaptDev15S in 'N_CMCaptDev15S.pas',
  N_CMCaptDev15aF in 'N_CMCaptDev15aF.pas' {N_CMCaptDev15aForm},
  N_CMCaptDev15bF in 'N_CMCaptDev15bF.pas' {N_CMCaptDev15bForm},
  K_FCMExportPPL in 'K_FCMExportPPL.pas' {K_FormCMExportPPL},
  K_FCMUTUnloadDBData in 'K_FCMUTUnloadDBData.pas' {K_FormCMUTUnloadDBData},
  K_FCMUTLoadDBData3 in 'K_FCMUTLoadDBData3.pas' {K_FormCMUTLoadDBData3},
  K_FCMSASetProvSec in 'K_FCMSASetProvSec.pas' {K_FormCMSASetProvSecurity},
  N_CMCaptDev16SF in 'N_CMCaptDev16SF.pas' {N_CMCaptDev16Form},
  N_CMCaptDev16S in 'N_CMCaptDev16S.pas',
  N_CMCaptDev16aF in 'N_CMCaptDev16aF.pas' {N_CMCaptDev16aForm},
  K_FCMDeviceLimitWarn in 'K_FCMDeviceLimitWarn.pas' {K_FormCMProfileLimitWarn},
  K_FCMScanSetPatData in 'K_FCMScanSetPatData.pas' {K_FormCMScanSetPatData},
  K_FCMSASetLocData in 'K_FCMSASetLocData.pas' {K_FormCMSASetLocationData},
  K_FCMDCMImport in 'K_FCMDCMImport.pas' {K_FormCMDCMImport},
  N_CMVideo4F in 'N_CMVideo4F.pas' {N_CMVideo4Form},
  N_Video4 in 'N_Video4.pas',
  K_FCMScanSelectMedia in 'K_FCMScanSelectMedia.pas' {K_FormCMScanSelectMedia},
  K_FCMSFilesHandling in 'K_FCMSFilesHandling.pas' {K_FormCMSFilesHandling},
  K_CLib in 'K_CLib.pas',
  K_CM0 in 'K_CM0.pas',
  K_CMWEBBase in 'K_CMWEBBase.pas',
  N_CMCaptDev17F in 'N_CMCaptDev17F.pas' {N_CMCaptDev17Form},
  N_CMCaptDev17 in 'N_CMCaptDev17.pas',
  N_CMCaptDev17aF in 'N_CMCaptDev17aF.pas' {N_CMCaptDev17aForm},
  K_FCMTwainTest in 'K_FCMTwainTest.pas' {K_FormCMTwainTest},
  N_CMTWAIN in 'N_CMTWAIN.pas',
  N_CMTWAIN4F in 'N_CMTWAIN4F.pas' {N_CMTWAIN4Form},
  K_FCMTwainASettings in 'K_FCMTwainASettings.pas' {K_FormCMTwainASettings},
  K_FCMImg3DViewsImportProgress in 'K_FCMImg3DViewsImportProgress.pas' {K_FormCMImg3DViewsImportProgress},
  K_FCMCustToolbar in 'K_FCMCustToolbar.pas' {K_FormCMCustToolbar},
  K_FCMDCMSetup in 'K_FCMDCMSetup.pas' {K_FormCMDCMSetup},
  K_FCMMailCAttrs in 'K_FCMMailCAttrs.pas' {K_FormMailCommonAttrs},
  K_FCMDCMCommitment in 'K_FCMDCMCommitment.pas' {K_FormCMDCMCommitment},
  N_CMVideoResF in 'N_CMVideoResF.pas' {N_CMVideoResForm},
  N_CMSendMailF in 'N_CMSendMailF.pas' {N_CMSendMailForm},
  K_FCMResampleLarge in 'K_FCMResampleLarge.pas' {K_FormCMResampleLarge},
  K_FCMPrint in 'K_FCMPrint.pas' {K_FormCMPrint},
  K_FCMHPreview in 'K_FCMHPreview.pas' {K_FormCMHPreview},
  K_FCMRepairSlideAttrs1 in 'K_FCMRepairSlideAttrs1.pas' {K_FormCMRepairSlidesAttrs1},
  K_FCMDBRecovery in 'K_FCMDBRecovery.pas' {K_FormCMDBRecovery},
  K_FCMDeleteSlides in 'K_FCMDeleteSlides.pas' {K_FormCMDeleteSlides},
  K_FCMDPRearrange in 'K_FCMDPRearrange.pas' {K_FormCMDPRearrange},
  N_CMCaptDev20SF in 'N_CMCaptDev20SF.pas' {N_CMCaptDev20Form},
  N_CMCaptDev18 in 'N_CMCaptDev18.pas',
  N_CMCaptDev18aF in 'N_CMCaptDev18aF.pas' {N_CMCaptDev18aForm},
  N_CMCaptDev18F in 'N_CMCaptDev18F.pas' {N_CMCaptDev18Form},
  N_CMCaptDev20S in 'N_CMCaptDev20S.pas',
  K_FCMSUDefFilter2 in 'K_FCMSUDefFilter2.pas' {K_FormCMSUDefFilter2},
  K_FCMSFPathChange in 'K_FCMSFPathChange.pas' {K_FormCMSFPathChange},
  K_FCMSlideIcons in 'K_FCMSlideIcons.pas' {K_FormCMSlideIcons},
  K_FCMDelObjsHandling in 'K_FCMDelObjsHandling.pas' {K_FormCMDelObjsHandling},
  N_CMCaptDev21S in 'N_CMCaptDev21S.pas',
  N_CMCaptDev21SF in 'N_CMCaptDev21SF.pas' {N_CMCaptDev21Form},
  N_CMCaptDev22 in 'N_CMCaptDev22.pas',
  N_CMCaptDev22aF in 'N_CMCaptDev22aF.pas' {N_CMCaptDev22aForm},
  N_CMCaptDev22F in 'N_CMCaptDev22F.pas' {N_CMCaptDev22Form},
  N_CMCaptDev23S in 'N_CMCaptDev23S.pas',
  N_CMCaptDev23aF in 'N_CMCaptDev23aF.pas' {N_CMCaptDev23aForm},
  N_CMCaptDev23SF in 'N_CMCaptDev23SF.pas' {N_CMCaptDev23Form},
  N_CMCaptDev24aF in 'N_CMCaptDev24aF.pas' {N_CMCaptDev24aForm},
  N_CMCaptDev24F in 'N_CMCaptDev24F.pas' {N_CMCaptDev24Form},
  N_CMCaptDev24 in 'N_CMCaptDev24.pas',
  K_FCMStudyCapt in 'K_FCMStudyCapt.pas' {K_FormCMStudyCapt},
  K_FCMStudyCaptSlide in 'K_FCMStudyCaptSlide.pas' {K_FormCMStudyCaptSlide},
  N_CMCaptDev25 in 'N_CMCaptDev25.pas',
  N_CMCaptDev25F in 'N_CMCaptDev25F.pas' {N_CMCaptDev25Form},
  N_CMCaptDev25aF in 'N_CMCaptDev25aF.pas' {N_CMCaptDev25aForm},
  K_FCMStudyTemplatesSetup in 'K_FCMStudyTemplatesSetup.pas' {K_FormCMStudyTemplatesSetup},
  K_FCMFSAnalysis1 in 'K_FCMFSAnalysis1.pas' {K_FormCMFSAnalysis1},
  K_FCMUTSyncPPL in 'K_FCMUTSyncPPL.pas' {K_FormCMUTSyncPPL},
  K_FCMFSDump in 'K_FCMFSDump.pas' {K_FormCMFSDump},
  K_FCMFSAnalysis in 'K_FCMFSAnalysis.pas' {K_FormCMFSAnalysis},
  K_FCMUTLoadDBData in 'K_FCMUTLoadDBData.pas' {K_FormCMUTLoadDBData},
  K_FCMProfileOther2 in 'K_FCMProfileOther2.pas' {K_FormCMProfileOther2},
  N_CMCaptDev19 in 'N_CMCaptDev19.pas',
  N_CMCaptDev19aF in 'N_CMCaptDev19aF.pas' {N_CMCaptDev19aForm},
  N_CMCaptDev19F in 'N_CMCaptDev19F.pas' {N_CMCaptDev19Form},
  N_CMCaptDev26 in 'N_CMCaptDev26.pas',
  N_CMCaptDev26aF in 'N_CMCaptDev26aF.pas' {N_CMCaptDev26aForm},
  N_CMCaptDev26F in 'N_CMCaptDev26F.pas' {N_CMCaptDev26Form},
  N_CMCaptDev27 in 'N_CMCaptDev27.pas',
  N_CMCaptDev27aF in 'N_CMCaptDev27aF.pas' {N_CMCaptDev27aForm},
  N_CMCaptDev27F in 'N_CMCaptDev27F.pas' {N_CMCaptDev27Form},
  N_CMCaptDev28 in 'N_CMCaptDev28.pas',
  N_CMCaptDev28aF in 'N_CMCaptDev28aF.pas' {N_CMCaptDev28aForm},
  N_CMCaptDev28F in 'N_CMCaptDev28F.pas' {N_CMCaptDev28Form},
  N_CMCaptDev29 in 'N_CMCaptDev29.pas',
  N_CMCaptDev29aF in 'N_CMCaptDev29aF.pas' {N_CMCaptDev29aForm},
  N_CMCaptDev29F in 'N_CMCaptDev29F.pas' {N_CMCaptDev29Form},
  N_CMCaptDev30 in 'N_CMCaptDev30.pas',
  N_CMCaptDev30aF in 'N_CMCaptDev30aF.pas' {N_CMCaptDev30aForm},
  N_CMCaptDev30F in 'N_CMCaptDev30F.pas' {N_CMCaptDev30Form},
  N_CMCaptDev31 in 'N_CMCaptDev31.pas',
  N_CMCaptDev31aF in 'N_CMCaptDev31aF.pas' {N_CMCaptDev31aForm},
  N_CMCaptDev31F in 'N_CMCaptDev31F.pas' {N_CMCaptDev31Form},
  K_FCMIntegrityCheck in 'K_FCMIntegrityCheck.pas' {K_FormCMIntegrityCheck},
  K_FCMFSCopy in 'K_FCMFSCopy.pas' {K_FormCMFSCopy},
  N_CMCaptDev32 in 'N_CMCaptDev32.pas',
  N_CMCaptDev32aF in 'N_CMCaptDev32aF.pas' {N_CMCaptDev32aForm},
  K_FCMStudyTemplateChange1 in 'K_FCMStudyTemplateChange1.pas' {K_FormCMStudyTemplateChange1},
  N_CMCaptDev32F in 'N_CMCaptDev32F.pas' {N_CMCaptDev32Form},
  K_FAStrings in 'K_FAStrings.pas' {K_FormAnalisesStrings},
  K_FCMUTLoadDBData1 in 'K_FCMUTLoadDBData1.pas' {K_FormCMUTLoadDBData1},
  N_PMTMain5F in 'N_PMTMain5F.pas' {N_PMTMain5Form},
  N_PMTVizF in 'N_PMTVizF.pas' {N_PMTVizForm},
  K_FCMNewDBAPSW in 'K_FCMNewDBAPSW.pas' {K_FormCMNewDBAPSW},
  K_FCMReports1 in 'K_FCMReports1.pas' {K_FormCMReports1},
  K_CMDCMGLibW in 'K_CMDCMGLibW.pas',
  K_CMDCM in 'K_CMDCM.pas',
  K_FCMDCMDImport in 'K_FCMDCMDImport.pas' {K_FormCMDCMDImport},
  N_CMCaptDev33aF in 'N_CMCaptDev33aF.pas' {N_CMCaptDev33aForm},
  N_CMCaptDev33S in 'N_CMCaptDev33S.pas',
  N_CMCaptDev33SF in 'N_CMCaptDev33SF.pas' {N_CMCaptDev33Form},
  N_PMTHelp2F in 'N_PMTHelp2F.pas' {N_PMTHelp2Form},
  N_CMCaptDev34aF in 'N_CMCaptDev34aF.pas' {N_CMCaptDev34aForm},
  N_CMCaptDev34bF in 'N_CMCaptDev34bF.pas' {N_CMCaptDev34bForm},
  N_CMCaptDev34S in 'N_CMCaptDev34S.pas',
  N_CMCaptDev34SF in 'N_CMCaptDev34SF.pas' {N_CMCaptDev34Form},
  K_FCMDCMQR in 'K_FCMDCMQR.pas' {K_FormCMDCMQR},
  K_FCMUTPrepDBData in 'K_FCMUTPrepDBData.pas' {K_FormCMUTPrepDBData},
  K_FCMUTLoadDBData2 in 'K_FCMUTLoadDBData2.pas' {K_FormCMUTLoadDBData2},
  K_FCMDCMMWL in 'K_FCMDCMMWL.pas' {K_FormCMDCMMWL},
  K_FCMDCMQuery in 'K_FCMDCMQuery.pas' {K_FormCMDCMQuery},
  K_FCMArchSave in 'K_FCMArchSave.pas' {K_FormCMArchSave},
  N_PMTHelpF in 'N_PMTHelpF.pas' {N_PMTHelpForm},
  N_PMTDiagrF in 'N_PMTDiagrF.pas' {N_PMTDiagrForm},
  K_FCMDCMExe in 'K_FCMDCMExe.pas' {K_FormCMDCMExe},
  K_FCMFSClear in 'K_FCMFSClear.pas' {K_FormCMFSClear},
  K_FCMDCMStore in 'K_FCMDCMStore.pas' {K_FormCMDCMStore},
  N_PMTDiagr2F in 'N_PMTDiagr2F.pas' {N_PMTDiagr2Form},
  K_FCMScanWEBSettings in 'K_FCMScanWEBSettings.pas' {K_FormCMScanWEBSettings},
  L_WEBCheckVersionF in 'L_WEBCheckVersionF.pas' {L_WEBCheckVersionForm},
  K_FCMImportReverse in 'K_FCMImportReverse.pas' {K_FormCMImportReverse},
  L_WEBSettingsF in 'L_WEBSettingsF.pas' {L_WEBSettingsForm},
  K_FCMGAdmSettings in 'K_FCMGAdmSettings.pas' {K_FormCMGAdmSettings},
  NetUtils in 'Components\OAuth2\NetUtils.pas',
  OAuth2 in 'Components\OAuth2\OAuth2.pas',
  System.NetConsts in 'Components\OAuth2\System.NetConsts.pas',
  System.NetEncoding in 'Components\OAuth2\System.NetEncoding.pas',
  System.RTLConsts in 'Components\OAuth2\System.RTLConsts.pas',
  N_CMCaptDev35 in 'N_CMCaptDev35.pas',
  N_CMCaptDev35F in 'N_CMCaptDev35F.pas' {N_CMCaptDev35Form},
  ViewerTabSheet in 'VIEWERS\ViewerTabSheet.pas',
  fDICOMViewer in 'VIEWERS\DICOMViewer\fDICOMViewer.PAS' {DICOMViewer},
  fSeriesGraphicViewer in 'VIEWERS\DICOMViewer\fSeriesGraphicViewer.pas' {SeriesGraphicViewer},
  define_types in 'VIEWERS\DICOMViewer\DICOMUtils\define_types.pas',
  dicom in 'VIEWERS\DICOMViewer\DICOMUtils\dicom.pas',
  K_FCMExportSlidesAll in 'K_FCMExportSlidesAll.pas' {K_FormCMExportSlidesAll},
  MagicWand in 'Components\Graphics\MagicWand.pas',
  FilterCornerMask in 'Components\Graphics\FilterCornerMask.pas',
  fProgress in 'Components\Forms\fProgress.pas' {Progress};

///////////////////////////////////////
// !!! Replace DPR Program Begin
//
//$DPR_BODY_BEGIN


{$R *.RES}

label LExit, LRun;


var
  ParInd: Integer;
  SL : TStringList;
  StopBySelfCheckFlag : Boolean;
  NewName: string;
  FName: string;
  Ind: Integer;
  VFile: TK_VFile;

  ResLogFPathInfo: string;

  MaxFreeDump: string;
  OnExcept : TExceptionEvent;
  DumpReadyFlag : Boolean;


const WrapdcmLogLevel = 20000;

//************************ EncodeLLFile
  procedure EncodeLLFile( );
  var
    FStream : TFileStream;
    TE : TN_TextEncoding;
  begin
    FStream := K_TryCreateFileStream( FName, fmOpenRead + fmShareDenyNone );
    if FStream = nil then
      K_CMShowMessageDlg( //sysout
        'Open File "' + FName + '" problem', mtWarning )
    else
    begin
      TE := K_AnalizeStreamBOMBytes( FStream );
      FStream.Free;
      if (TE <> teUTF8) and (TE <> teUTF16LE) and (TE <> teUTF16BE) then
        K_CMShowMessageDlg( //sysout
          'File "' + FName + '" to encode shoud be UTF8, UTF16 or UTF16 Big Endian', mtWarning )
      else
      begin
        NewName := K_ExpandFileName( '(#WrkFiles#)' + ChangeFileExt( ExtractFileName(FName), '.dat' ) );
        if K_vfcrOK = K_VFCopyFile( FName, NewName, K_DFCreateEncrypted, [K_vfcOverwriteNewer] ) then
          K_CMShowMessageDlg( //sysout
            'File "' + FName + '" encoded to "' + NewName + '"', mtInformation )
        else
          K_CMShowMessageDlg( //sysout
            'Read File "' + FName + '" problems', mtWarning );
      end;
    end;
  end; // procedure EncodeLLFile( );

//************************ EncodeLLFilesLoop
  procedure EncodeLLFilesLoop();
  var
    FilePath, FilePat, SearchPat : string;
    F: TSearchRec;
    FCount : Integer;
  begin
    if FName = '' then
      FName := '(##Exe#)CMSuite*.txt';
    FName := K_ExpandFileName(FName);
    FilePath := ExtractFilePath( FName );
    FilePat  := ExtractFileName( FName );

    SearchPat := FName;
    if Pos( '?', FilePat ) > 0 then
      SearchPat := FilePath + '*.*'
    else
      FilePat := '';

  // Search lang file
    FCount := 0;
    if FindFirst( SearchPat, faAnyFile, F ) = 0 then
      repeat
        if (F.Name[1] = '.') or
           ((F.Attr and faDirectory) <> 0) then continue;

        if FilePat <> '' then
        begin
          if not K_CheckTextPattern( F.Name, FilePat ) then continue;
        end;

        FName := FilePath + F.Name;
        EncodeLLFile( );
        Inc(FCount);
      until FindNext( F ) <> 0;
    SysUtils.FindClose( F );

    K_CMShowMessageDlg( //sysout
        IntToStr(FCount) + ' files were encoded', mtInformation );


  end; // procedure EncodeLLFilesLoop();

//************************ CreateLLFiles
  procedure CreateLLFiles;
  begin
    FName := '';
    if K_CMDParams.Count - 1 > ParInd then
      FName := K_ExpandFileName( K_CMDParams[ParInd + 1] );

    NewName := K_ExpandFileName( '(#WrkFiles#)CMSuiteGUIEng' + K_DateTimeToStr( Now(), 'yyyy-mm-dd' ) );

    N_Dump1Str( 'LLL >> Start Create Current UI Texts File ' + NewName + 'Ful.txt');
    ParInd := K_PrepUITextsFiles( NewName + 'Ful.txt', FName,
                             NewName + 'Mod.txt', NewName + 'Del.txt' );
    N_Dump1Str( 'LLL >> Create Fin');
    if FName <> '' then
    begin
      if ParInd < 1 then
        N_Dump1Str( 'LLL >> Previous UI Texts File ' + FName + ' problems' )
      else
      begin
        N_Dump1Str( 'LLL >> Compare Current with ' + FName );
        N_Dump1Str( 'LLL >> New and modified UI Texts in ' + NewName + 'Mod.txt is Empty=' + N_B2S( (ParInd and 2) = 0 ) );
        N_Dump1Str( 'LLL >> Deleted UI Texts in ' + NewName + 'Del.txt is Empty=' + N_B2S( (ParInd and 4) = 0 ) );
      end;


    end;
    K_CMShowMessageDlg( //sysout
        'GUI Files ' + NewName + '*.txt created OK', mtInformation );
  end; // procedure CreateLLFiles;

//************************ CheckLLCMDLKey
  function CheckLLCMDLKey( const AParName : string ) : Boolean ;
  begin
    ParInd := K_CMDParams.IndexOf( AParName );
    Result := ParInd >= 0;
    if not Result then Exit;
    FName := '';
    if K_CMDParams.Count - 1 > ParInd then
      FName := K_ExpandFileName( K_CMDParams[ParInd + 1] );
  end; // function CheckLLCMDLKey


begin
//  N_b := K_SetFileAge( 'D:\Delphi_prj_new\N_Tree\!!_Log.txt', K_StrToDateTime( '2009-12-01 09:10:15.555' ) );
  DumpReadyFlag := FALSE;
  OnExcept := nil;
try
{$IF CompilerVersion >= 26.0} // !!! this code is added 2018-10-30 to dump initial free memory space after Project Units Initialization
  K_GetFreeSpaceProfile(2);
  MaxFreeDump := '!!!MemFreeSpace Init Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n');
{$IFEND CompilerVersion >= 26.0}

{$IF CompilerVersion < 26.0} // !!! this code is removed 2018-07-23 by Cloud request
////////////////////////////////////////////
// Needed to prevent memory fragmentation
// while application initialization is done
// K_CMSReservedSpaceHMem is used to reserve memory
// and free it after CMSuite is started
//
//N_T1.Start();
  K_GetFreeSpaceProfile(2);
//N_T1.Stop();
//N_S := N_T1.ToStr();
  N_u := K_FreeSpaceProfile[0];
  if K_FreeSpaceProfile[1] < 200000000 then
    N_u := N_u - 200000000;
  MaxFreeDump := format( '!!!MemFreeSpace reserve  %u (Profile: %u %u)', [N_u, K_FreeSpaceProfile[0], K_FreeSpaceProfile[1]] );
  K_CMSReservedSpaceHMem := Windows.GlobalAlloc( GMEM_MOVEABLE, N_u );
//
///////////////////////////
{$IFEND CompilerVersion < 26.0}


  Application.Initialize;
  N_Dump1LCInd := 0; // Dump1 Logging Chanel Index in CMS
  N_Dump2LCInd := 2; // Dump2 Logging Chanel Index in CMS

  N_CM_GlobObj := TN_CMGlobObj.Create;
  N_Show1Str := N_CM_GlobObj.CMGOShow1Str;

//  K_CMSInitRegSettingInfo( );

  K_CMEDAServerClientContextInit();
  K_AppFileGPathsCustProc := K_CMCustomizeGPathProc;

//debug
//K_CMSServerClientInfo.CMSSessionInfo.WTSClientProtocolType := WTS_PROTOCOL_TYPE_RDP;
//K_CMSServerClientInfo.CMSClientVirtualName := 'CS567';
//K_CMSServerClientInfo.CMSClientVirtualName := 'CS567';
//K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName := 'CS567';
//K_CMSServerClientInfo.CMSClientVirtualName := 'HOME-5PKR';
//K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName := 'HOME-5PKR';
//K_CMSServerClientInfo.CMSClientVirtualName := 'HOME-5PKR1';
//K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName := 'HOME-5PKR1';
//debug

  try
    K_TreeIniGlobals();
  except
    on E: Exception do
    begin
      if K_StrStartsWith( 'File ', E.Message ) then
      begin
        ParInd := K_CMSFileSelfCheckStopMode + K_CheckFilesCRCNotFound;
        if Pos( 'not found', E.Message ) = 0 then ParInd := K_CMSFileSelfCheckStopMode + K_CheckFilesCRCError;
        K_CMSFileSelfCheckErrMessageDlg( K_ErrFName, ParInd );
      end
      else
        U_CMErrorMessage( 'Application terminated by exception:'+#13#10 + E.Message ); //Ura
      Exit;
    end; // on E: Exception do
  end; // except

// K_CMEDAServerClientContextInit is moved before K_TreeIniGlobals();
//  K_CMEDAServerClientContextInit();

// K_AppFileGPathsCustProc is moved before K_TreeIniGlobals();
//  K_AppFileGPathsCustProc := K_CMCustomizeGPathProc;

// K_InitAppDirsList is closed because all is done in K_TreeIniGlobals();
//  K_InitAppDirsList();

// K_ClearAppTmpFiles is closed because all is done in K_TreeIniGlobals();
//  K_ClearAppTmpFiles( TRUE );


  ResLogFPathInfo := K_CMInitLogFilesGPath();

//////////////////////////////////////////////////
// Check SPL Errors in Precompliled Units
//
  if K_SearchOpenedForm( TK_FormMVDeb  ) <> nil then //
  begin
    Application.Title := 'SPL Errors';
    Application.CreateForm(TN_MenuForm, N_MenuForm);
  Application.CreateForm(TN_ButtonsForm, N_ButtonsForm);
  Application.CreateForm(TK_FormCMGAdmSettings, K_FormCMGAdmSettings);
  Application.Run;
    Exit;
  end; // if ... // SPL Errors in Precompliled Units
//
//////////////////////////////////////////////////
//  TS2 := Now();
  N_IniGlobals();

  K_RIObj := TK_RIGDIP.Create();

//N_d := K_StrToDateTime( '23.04.2002 12:44:46', FALSE );
//N_d := K_StrToDateTime( '2002-04-23 12:44:46', FALSE );

//////////////////////////////////////////////////////////////////
// Check if Dump2 file created in previous session should be saved
// (it may be needed if CMS was aborted by Task Manager of Power Failure)
  AddTerminateProc(N_OnAppTerminate); // add log flush if Terminate
  if not N_LCCheckFinishedOKFlag( N_Dump2LCInd ) then // Rename Dump2 file
  with N_LogChannels[N_Dump2LCInd] do
  begin
//    K_CMSPrevErrLogFName := ChangeFileExt( LCFullFName, N_GetDateTimeStr1() + '.txt' );
    K_CMSPrevErrLogFName := ChangeFileExt( LCFullFName,
                                 N_GetDateTimeStr1(K_GetFileAge(LCFullFName)) + '.txt' );
    RenameFile( LCFullFName, K_CMSPrevErrLogFName );
    N_Dump1Str( 'Prev CMSErrLog.txt file is renamed to' + N_StrCrLF +
                '                  ' + K_CMSPrevErrLogFName );
  end; // if not N_LCCheckFinishedOKFlag( N_CMSDump2LCInd ) then // Save Dump2 file
  DumpReadyFlag := TRUE;
//
//////////////////////////////////////////////////////////////////
{
  K_DCMGLibW.DLLogFileName := ExtractFilePath(N_LogChannels[N_Dump2LCInd].LCFullFName) + 'wrapdcmlog.txt';
  K_DCMGLibW.DLLogLevel    := 0; //

  if not N_MemIniToBool( 'CMS_Main', 'DistrFilesMode', false ) then // Prep Distrib Mode
    K_DCMGLibW.DLInitAll();
}

  with N_LogChannels[N_Dump1LCInd] do // Add ProcessID to DUMP1
    LCPrefix := format( '%u#', [GetCurrentProcessId()] );

  N_Dump1Str( MaxFreeDump );
  N_Dump1Str( '!!!LogFiles path >> ' + ResLogFPathInfo );
{$WARN SYMBOL_PLATFORM OFF}
  N_Dump1Str( 'CMDL >> ' + CmdLine ); // Application Command Line
{$WARN SYMBOL_PLATFORM ON}

  K_ExpandFileNameDumpProc := N_Dump1Str;

  with K_CMSServerClientInfo do
    N_Dump1Str( format( '!!!Client|Server Start >> WTSSessionID=%d WTSProtocolType=%d WTSServerName=%s'#13#10 +
                        '                                                ' +
                        'WTSClientName=%s WTSClientIP=%s CMSClientName=%s WTSUserName=%s WTSFillCode=%d',
             [CMSSessionInfo.WTSSessionID, CMSSessionInfo.WTSClientProtocolType,
              CMSSessionInfo.WTSServerCompName, CMSSessionInfo.WTSClientName,
              CMSSessionInfo.WTSClientIPStr, CMSClientVirtualName,
              CMSSessionInfo.WTSUserName,CMSSessionInfo.WTSFillCode] ) );



///////////////////////////////
// Check Files CRC
//
  if not FileExists(K_ExpandFileName( '(##Exe#)SkipCheckCRC' )) and
     N_MemIniToBool( 'CMS_Main', 'CheckFilesCRC', FALSE ) then
  begin

    N_Dump1Str( 'Start SelfCheck' );

    // Copy Exe to (#TmpFiles#) for CRC Check
    FName := ExtractFileName(Application.ExeName);
    ResLogFPathInfo := IntToStr( K_CopyFile( Application.ExeName,
                                             K_ExpandFileName( '(#TmpFiles#)' ) + FName,
                                             [K_cffOverwriteNewer] ) );
    if ResLogFPathInfo <> '0' then
      N_Dump1Str( format( '!!! >> File %s copy fails Code=%s',
                          [FName,ResLogFPathInfo] ) );

    // Control All Files
    SL := TStringList.Create;

    if not K_CheckMemIniFilesCRC( 'FilesCRC', SL ) then
    begin
      StopBySelfCheckFlag := FALSE;
      for Ind := 0 to SL.Count - 1 do
      begin
        ParInd := Integer(SL.Objects[Ind]);
        NewName := SL[Ind];
        if SameText( ExtractFileName(NewName), FName ) then
        begin
          // if Application.ExeName file was not copied
          if ResLogFPathInfo <> '0' then Continue; // Skip CRC check error
          ParInd := ParInd + K_CMSFileSelfCheckStopMode;
          NewName := Application.ExeName;
          StopBySelfCheckFlag := TRUE;
        end;
        K_CMSFileSelfCheckErrMessageDlg( NewName, ParInd );
      end;

      if StopBySelfCheckFlag then
      begin
        N_Dump1Str( '***** Application is stopped because of SelfCheck Error' );
        goto LExit;
      end;
    end; // if not K_CheckMemIniFilesCRC( 'FilesCRC', SL )
    SL.Free;
    N_Dump1Str( 'Fin SelfCheck' );

  end; // if N_MemIniToBool( 'CMS_Main', 'CheckFilesCRC', FALSE ) then
//
// end of Check Files CRC
///////////////////////////////

  K_CMSWrkFilesInit();

  K_InitAppArchProc := N_InitCMSArchGCont; // Set CMS Project Archive Initialization procedure, called from K_InitArchiveGCont
  //  N_T1.SSS( 'After K_TreeIniGlobals' );

  // Init Regional Settings
  K_VFAssignByPath( VFile, K_ExpandFileName( '(##Exe#)OEMSettings.dat|ini' ) );
  if K_VFileExists0( VFile ) then
  begin
    if K_VFLoadText0( ResLogFPathInfo, VFile ) then
    begin
      K_CMEDAMemIniStrings.Text := ResLogFPathInfo;
      K_CMEDAMemIniFile.SetStrings( K_CMEDAMemIniStrings );
      N_Dump1Str( '***** Regional Settings use ' );
      K_CMEDAccess.EDAHidePasswordForDump( K_CMEDAMemIniStrings, TRUE );
      N_Dump2Strings( K_CMEDAMemIniStrings, 5 );
      K_AddMemIni( K_CMEDAMemIniFile, N_CurMemIni );
      K_InitAppDirsList();
    end; // K_VFLoadText0( ResLogFPathInfo, VFile )
  end; // if K_VFileExists0( VFile ) then

//  if not K_RunCMDScript( K_CMDParams.Values['Run'] ) then
//  begin
//    K_RunCMDScript( K_CMDParams.Values['Exec'] );

  K_CMEDAccessInit();
//      FName := K_ExpandFileName( '(##Exe#)Cms2.ico' );
//      if FileExists( FName ) then
//        Application.Icon.LoadFromFile( FName );
  FName := N_MemIniToString( 'CMS_Main', 'IconFName', '' );
  if FName <> '' then
  begin
    K_VFAssignByPath( VFile, K_ExpandFileName( FName ) );
    if K_VFOpen( VFile ) > 0 then
    begin
      Application.Icon.LoadFromStream( K_VFStreamGetToRead( VFile ) );
      N_Dump2Str( '***** Application Icon from ' + FName );
    end;
    K_VFStreamFree(VFile);
  end;

  if N_MemIniToBool( 'CMS_Main', 'DistrFilesMode', false ) then // Prep Distrib Mode
    // Prepare CMS Files distribute and exit
    Application.CreateForm( TK_FormCMDistr, K_FormCMDistr )
  else // not Distribute mode
  begin

    ////////////////////////////////////////
    // Check LLL Files Creation Mode
    //
      if CheckLLCMDLKey( '-LLCreate' ) then
      begin
        CreateLLFiles();
        goto LExit;
      end;


      if CheckLLCMDLKey( '-LLEncode' ) then
      begin
        EncodeLLFilesLoop();
        goto LExit;
      end;
    //
    ////////////////////////////////////////

    ////////////////////////////////////////
    // Define Application Start Mode
    //
      K_CMDefineStartMode();
      if K_CMSAppStartContext.CMASState = K_cmasStop then
        goto LExit;
    //
    // Define Application Start Mode
    ////////////////////////////////////////

    ///////////////////////////
    // Show CMS Splash Screen
      if not K_CMVUIMode and (K_CMSAppStartContext.CMASMode < K_cmamCOMHPUI) then
      begin
        K_SplashScreenShow();
        N_Dump1Str('***** After SplashScreen Show');
      end;
    ////////////////////////////

      // Create CMS wrk invisible interface form
      Application.CreateForm( TN_CMMain5Form1, N_CM_MainForm);
      Application.OnException := N_CM_MainForm.OnUHException;
      Application.OnHint      := N_CM_MainForm.CMMFShowHint;
      Application.ShowMainForm := FALSE;
      OnExcept := N_CM_MainForm.OnUHException;
//      Application.Terminate(); // debug code

//      N_MainModalForm := N_CM_MainForm;

      // Create CMS UI Actions container form
      Application.CreateForm(TN_CMResForm, N_CMResForm);
      K_SetFFCompCurLangTexts( N_CMResForm );

        // Prepare LLL Forms
      Application.CreateForm(TK_CML1Form, K_CML1Form);
      K_SetFFCompCurLangTexts( K_CML1Form );
      K_PrepLLLCompTexts( K_CML1Form );

      Application.CreateForm(TK_CML3Form, K_CML3Form);
      K_SetFFCompCurLangTexts( K_CML3Form );
      K_PrepLLLCompTexts( K_CML3Form );
      K_CMHistoryEventsInit();

      Application.CreateForm(TN_CML2Form, N_CML2Form);
      K_SetFFCompCurLangTexts( N_CML2Form );
      K_PrepLLLCompTexts( N_CML2Form );

      // Create common invisible interface forms create
      // N_ButtonsForm creation is needed before N_CM_MainForm.FormShow
      Application.CreateForm(TN_ButtonsForm, N_ButtonsForm);
{
      // Init DICOM library
      K_DCMGLibW.DLLogFileName := ExtractFilePath(N_LogChannels[N_Dump2LCInd].LCFullFName) + 'wrapdcmlog.txt';
      K_DCMGLibW.DLLogLevel    := WrapdcmLogLevel; //
      K_DCMGLibW.DLInitAll();
}
      // Run App Init Code
      N_CM_MainForm.FormShow( Application );
      if K_CMSAppStartContext.CMASState = K_cmasStop then goto LExit;

      // Init DICOM library
      if K_CMEDAccess is TK_CMEDDBAccess then
      begin
        K_DCMGLibW.DLLogFileName := ExtractFilePath(N_LogChannels[N_Dump2LCInd].LCFullFName) + 'wrapdcmlog.txt';
        K_DCMGLibW.DLLogLevel    := WrapdcmLogLevel; //
        K_DCMGLibW.DLInitAll();
      end;
  end; // else // not Distribute mode

  // Create common invisible interface forms if were not created early
  Application.CreateForm(TN_MenuForm, N_MenuForm);
  if N_ButtonsForm = nil then
    Application.CreateForm(TN_ButtonsForm, N_ButtonsForm);

LRun: //*****
  N_Dump1Str( '***** Run process: Before Application.Run' );
  Application.ShowHint := TRUE;

  // Check Version Info
  if (N_CMVerNumber = 1) and (N_CMBuildNumber = 0) then
    K_CMShowMessageDlg1( 'Media Suite version is ' + N_CMSVersion +
                         '. Version problem is detected!!!', mtWarning );

  K_ExpandFileNameAppTypeStr := N_MemIniToString( 'CMS_Main', 'AppMode', 'MediaSuite' );
  Application.Run;
  N_Dump1Str( '***** Run process: After Application.Run' );

//  Remove Old Dump Data for All CMS applications (CMSite, CMScan, CMSupport)
  K_CMRemoveOldDumpAllData( );

  N_AddStrToFile( '***** Run 7rocess: Application Finish '#13#10 );

//    except
LExit:  //*****
  N_Dump1Str( 'Application Finish FlushCounters' + N_GetFlushCountersStr() );
  if N_MemIniToBool( 'CMS_UserDeb', 'PreserveErrLog', FALSE ) then
    N_LCExecAction( N_Dump2LCInd, lcaFlush ) // do not write FinishedOK Flag
  else
    N_LCAddFinishedOKFlag( N_Dump2LCInd );

  N_LCExecAction( -1, lcaFlush );
//  end; // if not K_RunCMDScript( K_CMDParams.Values['Run'] ) then

except
  on E: Exception do
  begin
    if Assigned(OnExcept) then
      OnExcept( Application, E )
    else
    begin
      if DumpReadyFlag then
      begin
        K_CMShowMessageDlg( 'Application terminated by exception:'#13#10 +
                            E.Message, mtError );
//        N_Dump1Str( 'ProjExcept >> ' + E.Message );
        N_Dump1Str( 'Application Except 1 FlushCounters' + N_GetFlushCountersStr() );
        N_LCExecAction( -1, lcaFlush );
      end;
//      ExitProcess( 10 );
    end;
  end;
end;

end.

//$DPR_BODY_END
//
// !!! Replace DPR Program End
///////////////////////////////////////
