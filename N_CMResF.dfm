object N_CMResForm: TN_CMResForm
  Left = 768
  Top = 418
  Action = aCapCaptDevSetup
  Caption = 'Setup (Advanced) ...'
  ClientHeight = 135
  ClientWidth = 173
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClick = aCapCaptDevSetupExecute
  PixelsPerInch = 96
  TextHeight = 13
  object MainActions: TActionList
    Images = MainIcons18
    Left = 72
    Top = 8
    object aDebSaveArchAs: TAction
      Category = 'Debug1'
      Caption = '_Save Archive As ...'
      ShortCut = 49235
      OnExecute = aDebSaveArchAsExecute
    end
    object aDebCreateDistr: TAction
      Category = 'Debug1'
      Caption = '_Create Distributive'
      OnExecute = aDebCreateDistrExecute
    end
    object aObjCalibrate1: TAction
      Category = 'Objects'
      Caption = '&Calibrate Image by Line'
      Hint = 'Calibrate Image by Line|Calibrate Image by Line '
      ImageIndex = 75
      OnExecute = aObjCalibrate1Execute
    end
    object aDebSyncDPRFilesUses: TAction
      Category = 'Debug1'
      Caption = '_Synchronize *.DPR Files Uses'
      OnExecute = aDebSyncDPRFilesUsesExecute
    end
    object aDebCreateNewGUID: TAction
      Category = 'Debug1'
      Caption = '_Create and show new GUID text'
      OnExecute = aDebCreateNewGUIDExecute
    end
    object aDebCorrectDProjFiles: TAction
      Category = 'Debug1'
      Caption = '_Correct Build DProj Files'
      OnExecute = aDebCorrectDProjFilesExecute
    end
    object aMediaDICOMImport: TAction
      Category = 'Media'
      Caption = '3D'
      Hint = 'Import DICOM '
      ShortCut = 49225
      OnExecute = aMediaDICOMImportExecute
    end
    object aDebChangeContext: TAction
      Category = 'Debug1'
      Caption = '_Change Current DB/Patient/Provider/Location Context'
      OnExecute = aDebChangeContextExecute
    end
    object aDebClearSlidesInDB: TAction
      Category = 'Debug1'
      Caption = '_Clear All Slides In Ext. DB (for All Patients)'
      OnExecute = aDebClearSlidesInDBExecute
    end
    object aDebClearSlidesInArch: TAction
      Category = 'Debug1'
      Caption = '_Clear All Slides in Archive (init Archive)'
      OnExecute = aDebClearSlidesInArchExecute
    end
    object aDebAddSlidesToDB: TAction
      Category = 'Debug1'
      Caption = '_Add Current Slides To Ext. DB (for current Patient)'
      OnExecute = aDebAddSlidesToDBExecute
    end
    object aDebDelArchImgFiles: TAction
      Category = 'Debug1'
      Caption = '_Delete Unused Archive Image Files'
      OnExecute = aDebDelArchImgFilesExecute
    end
    object aDebListSlidesInDB: TAction
      Category = 'Debug1'
      Caption = '_List Slides In Ext. DB (for Current Patient)'
    end
    object aDebAbortCMS: TAction
      Category = 'Debug1'
      Caption = '_Abort CMS by exception'
      OnExecute = aDebAbortCMSExecute
    end
    object aDebCheckFile: TAction
      Category = 'Debug1'
      Caption = '_Check File in Debugger'
      OnExecute = aDebCheckFileExecute
    end
    object aDebConvToGray: TAction
      Category = 'Debug1'
      Caption = '_Convert Slide to Gray'
      OnExecute = aDebConvToGrayExecute
    end
    object aDebEmbossPar: TAction
      Category = 'Debug1'
      Caption = '_Emboss with Params'
      Visible = False
      OnExecute = aDebEmbossParExecute
    end
    object aDebClearLockedSlides: TAction
      Category = 'Debug1'
      Caption = '_Clear Locked Slides from DB'
      OnExecute = aDebClearLockedSlidesExecute
    end
    object aGoToPropDiagMulti: TAction
      Category = 'GoTo'
      Caption = 'Properties/&Diagnoses ...'
      Hint = 'Edit Properties/Diagnoses'
      ImageIndex = 2
      ShortCut = 16452
      OnExecute = aGoToPropDiagMultiExecute
    end
    object aGoToPreferences: TAction
      Category = 'GoTo'
      Caption = 'Pre&ferences ...'
      Hint = 'Edit View Preferences'
      ImageIndex = 1
      OnExecute = aGoToPreferencesExecute
    end
    object aGoToPrint: TAction
      Category = 'GoTo'
      Caption = '&Print ...'
      Hint = 'Print|Print the selected images'
      ImageIndex = 0
      ShortCut = 16464
      OnExecute = aGoToPrintExecute
    end
    object aGoToPrintStudiesOnly: TAction
      Category = 'GoTo'
      Caption = 'Print &studies only ...'
      Hint = 'Print|Print the selected studies'
      ImageIndex = 109
      ShortCut = 24656
      OnExecute = aGoToPrintStudiesOnlyExecute
    end
    object aGoToExit: TAction
      Category = 'GoTo'
      Caption = 'E&xit'
      Hint = 'Exit'
      ImageIndex = 3
      OnExecute = aGoToExitExecute
    end
    object aCapCaptDevSetup: TAction
      Category = 'Capture'
      Caption = 'Setup (Advanced) ...'
      Hint = 'Capture Device Setup ...'
      ImageIndex = 6
      ShortCut = 8313
      OnExecute = aCapCaptDevSetupExecute
    end
    object aViewOneSquare: TAction
      Category = 'View'
      Caption = '&One Square'
      Hint = 'One Editor Frame'
      ImageIndex = 10
      ShortCut = 16496
      OnExecute = aViewOneSquareExecute
    end
    object aViewTwoHorizontal: TAction
      Category = 'View'
      Caption = 'Two &Horizontal'
      Hint = 'Two Editor Frames (Horizontal)'
      ImageIndex = 12
      ShortCut = 16497
      OnExecute = aViewTwoHorizontalExecute
    end
    object aViewTwoVertical: TAction
      Category = 'View'
      Caption = 'Two &Vertical'
      Hint = 'Two Editor Frames (Vertical)'
      ImageIndex = 11
      ShortCut = 16498
      OnExecute = aViewTwoVerticalExecute
    end
    object aViewFourSquares: TAction
      Category = 'View'
      Caption = '&Four Squares'
      Hint = 'Four Editor Frames'
      ImageIndex = 13
      ShortCut = 16499
      OnExecute = aViewFourSquaresExecute
    end
    object aEditStudySelectAll: TAction
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All Objects'
      ImageIndex = 44
      OnExecute = aEditStudySelectAllExecute
    end
    object aEditStudyInvertSelection: TAction
      Category = 'Edit'
      Caption = 'Invert Selection'
      Hint = 'Invert Selection'
      OnExecute = aEditStudyInvertSelectionExecute
    end
    object aEditStudyClearSelection: TAction
      Category = 'Edit'
      Caption = 'Clear Selection'
      Hint = 'Clear Selection'
      OnExecute = aEditStudyClearSelectionExecute
    end
    object aEditStudyDismount: TAction
      Category = 'Edit'
      Caption = 'Dismount selected'
      Hint = 'Dismount selected study items'
      OnExecute = aEditStudyDismountExecute
    end
    object aEditStudyItemSelectVis: TAction
      Category = 'Edit'
      Caption = 'Select Object to display'
      OnExecute = aEditStudyItemSelectVisExecute
    end
    object aEditCloseAll: TAction
      Category = 'Edit'
      Caption = 'Close All'
      Hint = 'Close all opened images'
      ImageIndex = 106
      OnExecute = aEditCloseAllExecute
    end
    object aViewNineSquares: TAction
      Category = 'View'
      Caption = '&Nine Squares'
      Hint = 'Nine Editor Frames '
      ImageIndex = 14
      ShortCut = 16500
      OnExecute = aViewNineSquaresExecute
    end
    object aViewZoom: TAction
      Category = 'View'
      Caption = '&Zoom In and Out'
      Hint = 'Zoom Tool'
      ImageIndex = 15
      ShortCut = 16461
      OnExecute = aViewZoomExecute
    end
    object aViewPanning: TAction
      Category = 'View'
      Caption = '&Panning'
      Hint = 'Pan Tool'
      ImageIndex = 16
      ShortCut = 16462
      OnExecute = aViewPanningExecute
    end
    object aViewFullScreen: TAction
      Category = 'View'
      Caption = 'View Full Scr&een'
      Enabled = False
      Hint = 'View Full Screen'
      ImageIndex = 17
      OnExecute = aViewFullScreenExecute
    end
    object aViewFitToWindow: TAction
      Category = 'View'
      Caption = 'Fit to &Window'
      Hint = 'Fit to Window'
      ImageIndex = 18
      ShortCut = 16471
      OnExecute = aViewFitToWindowExecute
    end
    object aVTBAlterations: TAction
      Category = 'Toolbars'
      AutoCheck = True
      Caption = 'Toolb&ar'
      Checked = True
      Hint = 'Set Toolbar visibility'
      OnExecute = aVTBAlterationsExecute
    end
    object aVTBCapture: TAction
      Category = 'Toolbars'
      AutoCheck = True
      Caption = '&Capture'
      Checked = True
      Hint = 'Toggle Capture Toolbar visibility'
      OnExecute = aVTBCaptureExecute
    end
    object aVTBSystem: TAction
      Category = 'Toolbars'
      AutoCheck = True
      Caption = '&System'
      Checked = True
      Hint = 'Toggle System Toolbar visibility'
      OnExecute = aVTBSystemExecute
    end
    object aVTBViewFilt: TAction
      Category = 'Toolbars'
      AutoCheck = True
      Caption = '&Views and Filters'
      Checked = True
      Hint = 'Toggle View, Filter Toolbar visibility'
      OnExecute = aVTBViewFiltExecute
    end
    object aToolsRotateLeft: TAction
      Category = 'Tools'
      Caption = 'Rotate &Left'
      Hint = 'Rotate Left|Rotate by 90'#176' to the left'
      ImageIndex = 20
      ShortCut = 16460
      OnExecute = aToolsRotateLeftExecute
    end
    object aToolsRotateRight: TAction
      Category = 'Tools'
      Caption = 'Rotate &Right'
      Hint = 'Rotate Right|Rotate by 90'#176' to the right'
      ImageIndex = 21
      ShortCut = 16466
      OnExecute = aToolsRotateRightExecute
    end
    object aToolsRotate180: TAction
      Category = 'Tools'
      Caption = 'Ro&tate by 180'#176
      Hint = 'Rotate by 180'#176'|Rotate by 180'#176' '
      ImageIndex = 22
      ShortCut = 16456
      OnExecute = aToolsRotate180Execute
    end
    object aToolsFlipHorizontally: TAction
      Category = 'Tools'
      Caption = 'Flip &Horizontally'
      Hint = 'Flip Horizontally|Flip Horizontally (side to side)'
      ImageIndex = 24
      ShortCut = 16458
      OnExecute = aToolsFlipHorizontallyExecute
    end
    object aToolsFlipVertically: TAction
      Category = 'Tools'
      Caption = 'Flip &Vertically'
      Hint = 'Flip Vertically|Flip the image vertically (up and down)'
      ImageIndex = 23
      ShortCut = 16459
      OnExecute = aToolsFlipVerticallyExecute
    end
    object aToolsBriCoGam: TAction
      Category = 'Tools'
      Caption = '&Brightness / Contrast / Gamma'
      Hint = 
        'Brightness / Contrast / Gamma|Adjust Brightness, Contrast and Ga' +
        'mma'
      ImageIndex = 25
      ShortCut = 16450
      OnExecute = aToolsBriCoGamExecute
    end
    object aToolsBriCoGam1: TAction
      Category = 'Tools'
      Caption = '&Brightness / Contrast / Gamma'
      Hint = 
        'Brightness / Contrast / Gamma|Adjust Brightness, Contrast and Ga' +
        'mma'
      ImageIndex = 25
      ShortCut = 16450
      Visible = False
      OnExecute = aToolsBriCoGam1Execute
    end
    object aMediaImport: TAction
      Category = 'Media'
      Caption = '2D'
      Hint = 'Import from files|Import media from files'
      ImageIndex = 30
      ShortCut = 16457
      OnExecute = aMediaImportExecute
    end
    object aMediaWCImport: TAction
      Category = 'Media'
      Caption = 'Paste ...'
      Hint = 'Import from Clipboard|Import media from Clipboard'
      ImageIndex = 42
      ShortCut = 24649
      OnExecute = aMediaWCImportExecute
    end
    object aMediaDCMDImport: TAction
      Category = 'Media'
      Caption = 'DICOMDI&R Import ...'
      Hint = 'Import from DICOMDIR files|Import media from DICOMDIR files'
      OnExecute = aMediaDCMDImportExecute
    end
    object aMediaImport3D: TAction
      Category = 'Media'
      Caption = '3D Import ...'
      Hint = 'Import 3D image|Import 3D image from files'
      ImageIndex = 30
      ShortCut = 49225
      OnExecute = aMediaImport3DExecute
    end
    object aMediaExportOpened: TAction
      Category = 'Media'
      Caption = 'Expor&t ...'
      Hint = 'Export media to file|Export Selected media to file'
      ImageIndex = 31
      ShortCut = 16468
      OnExecute = aMediaExportOpenedExecute
    end
    object aMediaExportMarked: TAction
      Category = 'Media'
      Caption = 'Expor&t ...'
      Hint = 'Export media to file|Export Selected media to file'
      ImageIndex = 31
      ShortCut = 16468
      OnExecute = aMediaExportMarkedExecute
    end
    object aMediaWCExport: TAction
      Category = 'Media'
      Caption = 'Copy'
      Hint = 'Export media to Clipboard|Export Selected media to Clipboard'
      ImageIndex = 41
      ShortCut = 24660
      OnExecute = aMediaWCExportExecute
    end
    object aMediaOpen: TAction
      Category = 'Media'
      Caption = '&Open ...'
      Hint = 'Open Selected|Open the selected media'
      ImageIndex = 32
      ShortCut = 16463
      OnExecute = aMediaOpenExecute
    end
    object aMediaAddToOpened: TAction
      Category = 'Media'
      Caption = 'Add to opened'
      OnExecute = aMediaAddToOpenedExecute
    end
    object aMediaDuplicate: TAction
      Category = 'Media'
      Caption = '&Duplicate'
      Hint = 'Duplicate Selected|Duplicate the selected media '
      ImageIndex = 19
      ShortCut = 24644
      OnExecute = aMediaDuplicateExecute
    end
    object aMediaEmail: TAction
      Category = 'Media'
      Caption = '&Email ...'
      Hint = 'Email Selected|Email the selected media'
      ImageIndex = 33
      ShortCut = 16453
      OnExecute = aMediaEmailExecute
    end
    object aMediaEMail1: TAction
      Category = 'Media'
      Caption = '&Email ...'
      Hint = 'Email Selected|Email the selected media'
      ImageIndex = 33
      ShortCut = 16453
      OnExecute = aMediaEmail1Execute
    end
    object aEditCut: TAction
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut Marked'
      ImageIndex = 40
      ShortCut = 16472
      Visible = False
      OnExecute = aEditCutExecute
    end
    object aEditCopyMarked: TAction
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy Marked Objects|Copy Marked Objects to Clipboard'
      ImageIndex = 41
      ShortCut = 16451
      Visible = False
      OnExecute = aEditCopyMarkedExecute
    end
    object aEditCopyOpened: TAction
      Category = 'Edit'
      Caption = 'Copy'
      Hint = 'Copy'
      ImageIndex = 41
      Visible = False
      OnExecute = aEditCopyOpenedExecute
    end
    object aEditPaste: TAction
      Category = 'Edit'
      Caption = 'Pa&ste'
      Hint = 'Paste Objects copies|Paste Objects copies from Clipboard'
      ImageIndex = 42
      ShortCut = 16470
      Visible = False
      OnExecute = aEditPasteExecute
    end
    object aEditDeleteMarked: TAction
      Category = 'Edit'
      Caption = '_De&lete'
      Hint = '_Delete Marked Object(s)'
      ImageIndex = 43
      OnExecute = aEditDeleteMarkedExecute
    end
    object aEditDeleteMarkedCapt: TAction
      Category = 'Edit'
      Caption = 'De&lete'
      Hint = 'Delete Marked Object(s)'
      ImageIndex = 43
      OnExecute = aEditDeleteMarkedExecute
    end
    object aEditDeleteMarkedForEver: TAction
      Category = 'Edit'
      Caption = 'De&lete forever'
      Hint = 'Delete Marked Object(s) forever'
      ImageIndex = 43
      OnExecute = aEditDeleteMarkedExecute
    end
    object aEditDeleteOpened: TAction
      Category = 'Edit'
      Caption = '_Delete Opened Image'
      Hint = '_Delete Opened Image'
      ImageIndex = 43
      OnExecute = aEditDeleteOpenedExecute
    end
    object aEditDeleteOpenedCapt: TAction
      Category = 'Edit'
      Caption = 'Delete Opened Image'
      Hint = 'Delete Opened Image'
      ImageIndex = 43
      OnExecute = aEditDeleteOpenedExecute
    end
    object aEditDeleteOpenedForEver: TAction
      Category = 'Edit'
      Caption = 'Delete Opened Image for ever'
      Hint = 'Delete Opened Image forever'
      ImageIndex = 43
      OnExecute = aEditDeleteOpenedExecute
    end
    object aEditDeleteCommon: TAction
      Category = 'Edit'
      Caption = 'Delete'
      ImageIndex = 43
      ShortCut = 46
      OnExecute = aEditDeleteCommonExecute
    end
    object aEditSelectAll: TAction
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All Objects'
      ImageIndex = 44
      OnExecute = aEditSelectAllExecute
    end
    object aEditSelectAllCommon: TAction
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All Objects'
      ShortCut = 16449
      OnExecute = aEditSelectAllCommonExecute
    end
    object aEditInvertSelection: TAction
      Category = 'Edit'
      Caption = 'Invert Selection'
      Hint = 'Invert Selection'
      OnExecute = aEditInvertSelectionExecute
    end
    object aEditClearSelection: TAction
      Category = 'Edit'
      Caption = 'Clear Selection'
      Hint = 'Clear Selection'
      OnExecute = aEditClearSelectionExecute
    end
    object aEditCloseCurActive: TAction
      Category = 'Edit'
      Caption = 'Close'
      Hint = 'Close opened image'
      ImageIndex = 79
      OnExecute = aEditCloseCurActiveExecute
    end
    object aEditPoint: TAction
      Category = 'Edit'
      Caption = '&Point'
      Hint = 'Point / Select|Select the  object'
      ImageIndex = 45
      ShortCut = 16473
      OnExecute = aEditPointExecute
    end
    object aEditRestOrigImage: TAction
      Category = 'Edit'
      Caption = 'Restore Original &Image'
      Hint = 'Restore Original Image|Restore Original Image'
      ImageIndex = 66
      ShortCut = 16455
      OnExecute = aEditRestOrigImageExecute
    end
    object aEditRestOrigState: TAction
      Category = 'Edit'
      Caption = 'Restore Original &State'
      Hint = 'Return Original State|Return Original State'
      ImageIndex = 46
      ShortCut = 24647
      Visible = False
      OnExecute = aEditRestOrigStateExecute
    end
    object aEditUndoLast: TAction
      Category = 'Edit'
      Caption = '&Undo Last Action'
      Hint = 'Undo the last action'
      ImageIndex = 47
      ShortCut = 16474
      OnExecute = aEditUndoLastExecute
    end
    object aHelpContents: TAction
      Category = 'Help'
      Caption = '&Contents'
      Hint = 'Help Contents'
      ImageIndex = 9
      ShortCut = 112
      OnExecute = aHelpContentsExecute
    end
    object aHelpAbout: TAction
      Category = 'Help'
      Caption = '&About ...'
      Hint = 'About window'
      ShortCut = 24641
      OnExecute = aHelpAboutExecute
    end
    object aVTBAllTopToolBars: TAction
      Category = 'Toolbars'
      AutoCheck = True
      Caption = 'All &Top Toolbars'
      Checked = True
      Hint = 'Set all top Toolbars visibility'
      OnExecute = aVTBAllTopToolBarsExecute
    end
    object aServEditStatTable: TAction
      Category = 'Service'
      Caption = '_View/Edit Statistics Table'
      Hint = '_View/Edit Statistics Table'
      OnExecute = aServEditStatTableExecute
    end
    object aServSetVideoCodec: TAction
      Category = 'Service'
      Caption = '_Set Video Codec'
      Hint = '_Set Video Codec'
      OnExecute = aServSetVideoCodecExecute
    end
    object aEditRedoLast: TAction
      Category = 'Edit'
      Caption = '&Redo Last Action'
      Hint = 'Redo Last Action'
      ImageIndex = 49
      ShortCut = 24666
      OnExecute = aEditRedoLastExecute
    end
    object aEditUndoRedo: TAction
      Category = 'Edit'
      Caption = 'Und&o / Redo ...'
      Hint = 'Undo/Redo|Open up the Undo/Redo window'
      ImageIndex = 48
      ShortCut = 16469
      OnExecute = aEditUndoRedoExecute
    end
    object aObjDelete: TAction
      Category = 'Objects'
      Caption = '&Delete Annotation'
      Hint = 'Delete Annotation|Delete Annotation'
      ImageIndex = 86
      OnExecute = aObjDeleteExecute
    end
    object aObjPolylineM: TAction
      Category = 'Objects'
      Caption = '&Measure Multi Line'
      Hint = 'Measure Multi Line|Measure Multi Line'
      ImageIndex = 73
      OnExecute = aObjPolylineMExecute
    end
    object aToolsNegate: TAction
      Category = 'Tools'
      Caption = '&Positive / Negative'
      Hint = 'Positive / Negative'
      ImageIndex = 34
      OnExecute = aToolsNegateExecute
    end
    object aToolsNegate1: TAction
      Category = 'Tools'
      Caption = '&Positive / Negative'
      Hint = 'Positive / Negative'
      ImageIndex = 34
      Visible = False
      OnExecute = aToolsNegate1Execute
    end
    object aToolsNegate11: TAction
      Category = 'Tools'
      Caption = '&Positive / Negative'
      Hint = 'Positive / Negative'
      ImageIndex = 34
      OnExecute = aToolsNegate11Execute
    end
    object aToolsSharpen: TAction
      Category = 'Tools'
      Caption = '&Sharp / Smooth'
      Hint = 'Sharp / Smooth'
      ImageIndex = 35
      Visible = False
      OnExecute = aToolsSharpenExecute
    end
    object aToolsSharpenN: TAction
      Category = 'Tools'
      Caption = '&Sharp / Smooth'
      Hint = 'Sharp / Smooth'
      ImageIndex = 35
      Visible = False
      OnExecute = aToolsSharpenNExecute
    end
    object aToolsSharpen1: TAction
      Category = 'Tools'
      Caption = '&Sharp / Smooth Test'
      Hint = 'Sharp / Smooth Test'
      Visible = False
      OnExecute = aToolsSharpen1Execute
    end
    object aToolsSharpen2: TAction
      Category = 'Tools'
      Caption = '&Sharp / Smooth fast'
      Hint = '&Sharp / Smooth fast'
      Visible = False
      OnExecute = aToolsSharpen2Execute
    end
    object aToolsSharpen3: TAction
      Category = 'Tools'
      Caption = '&Sharp / Smooth median'
      Hint = '&Sharp / Smooth median'
      Visible = False
      OnExecute = aToolsSharpen3Execute
    end
    object aToolsSharpen12: TAction
      Category = 'Tools'
      Caption = '_&Sharp / Smooth test2'
      Hint = '_&Sharp / Smooth test2'
      OnExecute = aToolsSharpen12Execute
    end
    object aToolsNoiseSelf: TAction
      Category = 'Tools'
      Caption = '&Noise Reduction'
      Hint = 'Noise Reduction'
      ImageIndex = 119
      OnExecute = aToolsNoiseSelfExecute
    end
    object aToolsNoiseAttrs: TAction
      Category = 'Tools'
      Caption = '&Noise Reduction Test'
      Hint = 'Noise Reduction Test '
      ImageIndex = 26
      Visible = False
      OnExecute = aToolsNoiseAttrsExecute
    end
    object aToolsEmboss: TAction
      Category = 'Tools'
      AutoCheck = True
      Caption = '&Emboss'
      Hint = 'Emboss'
      ImageIndex = 37
      OnExecute = aToolsEmbossExecute
    end
    object aToolsEmbossAttrs: TAction
      Category = 'Tools'
      Caption = 'Emboss Att&ributes'
      Hint = 'Emboss'
      ImageIndex = 27
      Visible = False
      OnExecute = aToolsEmbossAttrsExecute
    end
    object aToolsIsodens: TAction
      Category = 'Tools'
      AutoCheck = True
      Caption = '&Isodensity'
      Hint = 'Isodensity'
      ImageIndex = 39
      OnExecute = aToolsIsodensExecute
    end
    object aObjFinishLine: TAction
      Category = 'Objects'
      Caption = 'Finish Annotation'
      Hint = 'Finish Creating Annotation|Finish Creating Annotation'
      OnExecute = aObjFinishLineExecute
    end
    object aObjAngleNorm: TAction
      Category = 'Objects'
      Caption = 'Measure &Angle'
      Hint = 'Measure Angle|Measure Angle'
      ImageIndex = 70
      OnExecute = aObjAngleNormExecute
    end
    object aObjAngleFree: TAction
      Category = 'Objects'
      Caption = 'Measure F&ree Angle'
      Hint = 'Measure Free Angle|Measure Free Angle'
      ImageIndex = 71
      OnExecute = aObjAngleFreeExecute
    end
    object aObjTextBox: TAction
      Category = 'Objects'
      Caption = '&Text Annotation'
      Hint = 'Create Text Annotation|Create Text Annotation'
      ImageIndex = 74
      OnExecute = aObjTextBoxExecute
    end
    object aObjCTA1: TAction
      Category = 'Objects'
      Caption = 'Text &1'
      Hint = 
        'Create Customizable Text Annotation|Create Customizable Text Ann' +
        'otation'
      ImageIndex = 120
      OnExecute = aObjCTA1Execute
    end
    object aObjCTA2: TAction
      Category = 'Objects'
      Caption = 'Text &2'
      ImageIndex = 121
      OnExecute = aObjCTA2Execute
    end
    object aObjCTA3: TAction
      Category = 'Objects'
      Caption = 'Text &3'
      ImageIndex = 122
      OnExecute = aObjCTA3Execute
    end
    object aObjCTA4: TAction
      Category = 'Objects'
      Caption = 'Text &4'
      ImageIndex = 123
      OnExecute = aObjCTA4Execute
    end
    object aObjFreeHand: TAction
      Category = 'Objects'
      Caption = 'Free &Hand'
      Hint = 'Draw Free Hand Line|Draw Free Hand Line'
      ImageIndex = 69
      OnExecute = aObjFreeHandExecute
    end
    object aObjPolyline: TAction
      Category = 'Objects'
      Caption = 'Poly&line'
      Hint = 'Draw Polyline|Draw Polyline'
      ImageIndex = 72
      OnExecute = aObjPolylineExecute
    end
    object aObjArrowLine: TAction
      Category = 'Objects'
      Caption = '&Arrow'
      Hint = 'Draw Arrow|Draw Arrow'
      ImageIndex = 83
      OnExecute = aObjArrowLineExecute
    end
    object aObjEllipseLine: TAction
      Category = 'Objects'
      Caption = '&Ellipse'
      Hint = 'Draw Ellipse|Draw Ellipse'
      ImageIndex = 82
      OnExecute = aObjEllipseLineExecute
    end
    object aObjRectangleLine: TAction
      Category = 'Objects'
      Caption = 'Rectan&gle'
      Hint = 'Draw Rectangle|Draw Rectangle'
      ImageIndex = 81
      OnExecute = aObjRectangleLineExecute
    end
    object aObjChangeAttrs: TAction
      Category = 'Objects'
      Caption = '&Format Annotation'
      Hint = 'Format Annotation|Format Annotation'
      ImageIndex = 88
      OnExecute = aObjChangeAttrsExecute
    end
    object aObjRectangleOld: TAction
      Category = 'Objects'
      Caption = 'Rectan&gle'
      Hint = 'Draw Rectangle|Draw Rectangle'
      Visible = False
      OnExecute = aObjRectangleOldExecute
    end
    object aObjEllipseOld: TAction
      Category = 'Objects'
      Caption = '&Ellipse'
      Hint = 'Draw Ellipse|Draw Ellipse'
      Visible = False
      OnExecute = aObjEllipseOldExecute
    end
    object aObjArrowOld: TAction
      Category = 'Objects'
      Caption = '&Arrow'
      Hint = 'Draw Arrow|Draw Arrow'
      Visible = False
      OnExecute = aObjArrowOldExecute
    end
    object aObjShowHide: TAction
      Category = 'Objects'
      AutoCheck = True
      Caption = '&Show/Hide Annotations'
      Hint = 'Show/Hide Annotations'
      ImageIndex = 87
      OnExecute = aObjShowHideExecute
    end
    object aToolsIsodensAttrs: TAction
      Category = 'Tools'
      Caption = 'Isodensity Attrib&utes'
      Hint = 'Isodensity'
      ImageIndex = 29
      OnExecute = aToolsIsodensAttrsExecute
    end
    object aToolsColorize: TAction
      Category = 'Tools'
      AutoCheck = True
      Caption = '&Colourise'
      Hint = 'Colourise'
      ImageIndex = 38
      OnExecute = aToolsColorizeExecute
    end
    object aViewSlideColor: TAction
      Category = 'View'
      Caption = 'View Slide Color'
      Visible = False
      OnExecute = aViewSlideColorExecute
    end
    object aToolsHistogramm2: TAction
      Category = 'Tools'
      Caption = 'Hi&stogram ...'
      Hint = 'Histogram'
      ImageIndex = 65
      ShortCut = 16465
      OnExecute = aToolsHistogramm2Execute
    end
    object aObjFLZEllipse: TAction
      Category = 'Objects'
      Caption = 'Magnify Region '
      Hint = 'Magnify Region '
      ImageIndex = 85
      OnExecute = aObjFLZEllipseExecute
    end
    object aToolsRotateByAngle: TAction
      Category = 'Tools'
      Caption = 'Rotate by a degree'
      Hint = 'Rotate image by a degree|Rotate image by a degree'
      ImageIndex = 89
      OnExecute = aToolsRotateByAngleExecute
    end
    object aToolsAutoEqualize: TAction
      Category = 'Tools'
      Caption = 'Auto Equalize Image'
      Hint = 'Auto Equalize Image|Auto Equalize Image'
      ImageIndex = 90
      OnExecute = aToolsAutoEqualizeExecute
    end
    object aToolsCropImage: TAction
      Category = 'Tools'
      Caption = 'Crop Image'
      Hint = 'Crop Image'
      ImageIndex = 91
      OnExecute = aToolsCropImageExecute
    end
    object aServFilesHandling: TAction
      Category = 'Service'
      Caption = 'Image and Video Files Handling'
      Hint = 'Image and Video Files Handling'
      OnExecute = aServFilesHandlingExecute
    end
    object aServImportExtDB: TAction
      Category = 'Service'
      Caption = 'Import Data after Conversion'
      Hint = 'Import Data after Conversion'
      Visible = False
      OnExecute = aServImportExtDBExecute
    end
    object aHelpRegistration: TAction
      Category = 'Help'
      Caption = '&Registration ...'
      Hint = 'Client licenses and capture devices possibilities registration'
      OnExecute = aHelpRegistrationExecute
    end
    object aServXRAYStreamLine: TAction
      Category = 'Service'
      AutoCheck = True
      Caption = 'Disable X-Ray Processing Window'
      OnExecute = aServXRAYStreamLineExecute
    end
    object aServProcessClientTasks: TAction
      Category = 'Service'
      Caption = 'Process Client Tasks'
      OnExecute = aServProcessClientTasksExecute
    end
    object aServECacheCheck: TAction
      Category = 'Service'
      Caption = 'ECache Check'
      OnExecute = aServECacheCheckExecute
    end
    object aServECacheAllShow: TAction
      Category = 'Service'
      Caption = 'Display all objects in EmFiles folder'
      OnExecute = aServECacheAllShowExecute
    end
    object aServECacheRecovery: TAction
      Category = 'Service'
      Caption = 'Emergency Cache Recovery ...'
      OnExecute = aServECacheRecoveryExecute
    end
    object aServShowMessageDlg: TAction
      Category = 'Service'
      Caption = 'Show Message'
      OnExecute = aServShowMessageDlgExecute
    end
    object aServSlideHistShow: TAction
      Category = 'Service'
      Caption = 'Show object history'
      Visible = False
      OnExecute = aServSlideHistShowExecute
    end
    object aServSetCaptureDelay: TAction
      Category = 'Service'
      Caption = 'Camera capture Delay'
      OnExecute = aServSetCaptureDelayExecute
    end
    object aCapFootPedalSetup: TAction
      Category = 'Capture'
      Caption = 'Foot Pedal Setup'
      OnExecute = aCapFootPedalSetupExecute
    end
    object aServImportReverse: TAction
      Category = 'Service'
      Caption = 'Reverse last Import after Conversion'
      Visible = False
      OnExecute = aServImportReverseExecute
    end
    object aServConvCMSImgToBMP1: TAction
      Category = 'Service'
      Caption = 'Convert *_r.ecd, *.cmi, *.cmsi to BMP(PNG)'
      OnExecute = aServConvCMSImgToBMP1Execute
    end
    object aViewThumbRefresh: TAction
      Category = 'View'
      Caption = 'Refresh'
      Hint = 'Refresh media objects list '
      ShortCut = 116
      OnExecute = aViewThumbRefreshExecute
    end
    object aServConvCMSImgToBMP: TAction
      Category = 'Service'
      Caption = 'Convert *_R.ECD or *.CMI to BMP'
      Visible = False
      OnExecute = aServConvCMSImgToBMPExecute
    end
    object aServRecoverBadCMSImg: TAction
      Category = 'Service'
      Caption = 'Recover bad *.CMI'
      OnExecute = aServRecoverBadCMSImgExecute
    end
    object aServImportExtDBDlg: TAction
      Category = 'Service'
      Caption = 'Import Data after Conversion'
      Hint = 'Import Data after Conversion'
      OnExecute = aServImportExtDBDlgExecute
    end
    object aServBinDumpMode: TAction
      Category = 'Service'
      AutoCheck = True
      Caption = 'Binary Dump Mode'
      OnExecute = aServBinDumpModeExecute
    end
    object aEditFullScreen: TAction
      Category = 'Edit'
      Caption = 'Full Scr&een'
      Enabled = False
      Hint = 'Full Screen'
      ImageIndex = 17
      ShortCut = 16454
      OnExecute = aEditFullScreenExecute
    end
    object aEditFullScreenClose: TAction
      Category = 'Edit'
      Caption = 'Close Full Screen'
      OnExecute = aEditFullScreenCloseExecute
    end
    object aServCloseCMS: TAction
      Category = 'Service'
      Caption = 'Close CMS'
      OnExecute = aServCloseCMSExecute
    end
    object aServEModeRemoveLocDelFiles: TAction
      Category = 'Service'
      Caption = 
        'Remove Deleted Slides Files in current Location in Enterprise Mo' +
        'de'
      OnExecute = aServEModeRemoveLocDelFilesExecute
    end
    object aServEModeFilesSync: TAction
      Category = 'Service'
      Caption = 'Transfer Files between Locations'
      OnExecute = aServEModeFilesSyncExecute
    end
    object aServSelSlidesToSyncQuery: TAction
      Category = 'Service'
      Caption = 'Schedule Files Transfer'
      Hint = 'Put Selected Slides to Synchronize Files Query'
      OnExecute = aServSelSlidesToSyncQueryExecute
    end
    object aDebCreateFileClones: TAction
      Category = 'Debug1'
      Caption = '_Create Clones from given File'
      OnExecute = aDebCreateFileClonesExecute
    end
    object aDeb2CreateDemoExeDistr: TAction
      Category = 'Debug2'
      Caption = '_Create Distributive '
      OnExecute = aDeb2CreateDemoExeDistrExecute
    end
    object aGoToGAEnter: TAction
      Category = 'GoTo'
      AutoCheck = True
      Caption = 'Administration ...'
      OnExecute = aGoToGAEnterExecute
    end
    object aGoToGASettings: TAction
      Category = 'GoTo'
      Caption = 'Change account details ...'
      Hint = 'Change Global Administrator settings'
      OnExecute = aGoToGASettingsExecute
    end
    object aGoToGAFSyncInfo: TAction
      Category = 'GoTo'
      Caption = 'Files Synchronization Details ...'
      Hint = 'Show Files Synchronization Details'
      OnExecute = aGoToGAFSyncInfoExecute
    end
    object aMediaExportToD4WDocs: TAction
      Category = 'Media'
      Caption = 'Copy to D4W Document Manager ...'
      Hint = 'Copy the selected media to D4W Document Manager'
      OnExecute = aMediaExportToD4WDocsExecute
    end
    object aMediaEMChangeHLoc: TAction
      Category = 'Media'
      Caption = 'Change Host Location'
      Hint = 'Change Host Location for selected objects'
      OnExecute = aMediaEMChangeHLocExecute
    end
    object aDeb2CallTest2Form: TAction
      Category = 'Debug2'
      Caption = '_Call N_CMTest2Form'
      OnExecute = aDeb2CallTest2FormExecute
    end
    object aDeb2DebMP1: TAction
      Category = 'Debug2'
      Caption = '_Deb MP Action 1'
      OnExecute = aDeb2DebMP1Execute
    end
    object aDeb2DebMP2: TAction
      Category = 'Debug2'
      Caption = '_Deb MP Action 2'
      OnExecute = aDeb2DebMP2Execute
    end
    object aGoToReports: TAction
      Category = 'GoTo'
      Caption = 'Reports ...'
      OnExecute = aGoToReportsExecute
    end
    object aViewDisplayDel: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Display deleted objects'
      Hint = 'Display deleted objects'
      Visible = False
      OnExecute = aViewDisplayDelExecute
    end
    object aEditRestoreDel: TAction
      Category = 'Edit'
      Caption = 'Restore deleted objects'
      Hint = 'Restore deleted objects  '
      OnExecute = aEditRestoreDelExecute
    end
    object aServDelObjHandling: TAction
      Category = 'Service'
      Caption = 'Deleted objects handling ...'
      Hint = 'Deleted objects handling'
      OnExecute = aServDelObjHandlingExecute
    end
    object aServRemoveMarkAsDelSlides: TAction
      Category = 'Service'
      Caption = 'Remove "old" marked as deleted objects '
      OnExecute = aServRemoveMarkAsDelSlidesExecute
    end
    object aServSystemInfo: TAction
      Category = 'Service'
      Caption = 'Display System Info'
      OnExecute = aServSystemInfoExecute
    end
    object aServMaintenance: TAction
      Category = 'Service'
      Caption = 'Media objects integrity check'
      OnExecute = aServMaintenanceExecute
    end
    object aServDBRecoveryByFiles: TAction
      Category = 'Service'
      Caption = 'Database recovery'
      OnExecute = aServDBRecoveryByFilesExecute
    end
    object aDeb3ShowTestForm: TAction
      Category = 'Debug3'
      Caption = '_Show Test Form'
      OnExecute = aDeb3ShowTestFormExecute
    end
    object aDebViewEditDBContext: TAction
      Category = 'Debug1'
      Caption = '_View Edit DB Context'
      OnExecute = aDebViewEditDBContextExecute
    end
    object aDebSetPatProvLocInfo: TAction
      Category = 'Debug1'
      Caption = '_Set Patient, Provider, Location Info'
      OnExecute = aDebSetPatProvLocInfoExecute
    end
    object aToolsFilter1: TAction
      Category = 'Tools'
      Caption = 'Filter 1'
      Hint = 'User defined filter 1'
      ImageIndex = 110
      OnExecute = aToolsUFilterImgExecute
    end
    object aToolsFilter2: TAction
      Tag = 1
      Category = 'Tools'
      Caption = 'Filter 2'
      Hint = 'User defined filter 2'
      ImageIndex = 111
      OnExecute = aToolsUFilterImgExecute
    end
    object aToolsFilter3: TAction
      Tag = 2
      Category = 'Tools'
      Caption = 'Filter 3'
      Hint = 'User defined filter 3'
      ImageIndex = 112
      OnExecute = aToolsUFilterImgExecute
    end
    object aToolsFilter4: TAction
      Tag = 3
      Category = 'Tools'
      Caption = 'Filter 4'
      Hint = 'User defined filter 2'
      ImageIndex = 113
      OnExecute = aToolsUFilterImgExecute
    end
    object aServImportChngAttrs: TAction
      Category = 'Service'
      Caption = 'aServImportChngAttrs'
      OnExecute = aServImportChngAttrsExecute
    end
    object aServUpdateUIByDeviceProfiles: TAction
      Category = 'Service'
      Caption = 'Update User Interface by Device Profiles '
      OnExecute = aServUpdateUIByDeviceProfilesExecute
    end
    object aDebShowNVTreeForm: TAction
      Category = 'Debug1'
      Caption = '_Show NVTree Form'
      OnExecute = aDebShowNVTreeFormExecute
    end
    object aObjCalibrateN: TAction
      Category = 'Objects'
      Caption = '&Calibrate Image by Polyline'
      Hint = 'Calibrate Image by Polyline|Calibrate Image by Polyline'
      ImageIndex = 124
      OnExecute = aObjCalibrateNExecute
    end
    object aObjCalibrateDPI: TAction
      Category = 'Objects'
      Caption = '&Calibrate Image by resolution'
      Hint = 'Calibrate Image by resolution|Calibrate Image by resolution'
      ImageIndex = 125
      OnExecute = aObjCalibrateDPIExecute
    end
    object aDebClearFormsCoords: TAction
      Category = 'Debug1'
      Caption = '_Clear all Forms coords in ini file'
      OnExecute = aDebClearFormsCoordsExecute
    end
    object aDebAction1: TAction
      Category = 'Debug1'
      Caption = '_K_CMSDebAction1Proc'
      ImageIndex = 7
      ShortCut = 24625
      OnExecute = aDebAction1Execute
    end
    object aDebAction2: TAction
      Category = 'Debug1'
      Caption = '_N_CMSDebAction2Proc'
      ImageIndex = 8
      ShortCut = 24626
      OnExecute = aDebAction2Execute
    end
    object aDebAction3: TAction
      Category = 'Debug1'
      Caption = '_Deb Action3'
      ImageIndex = 8
      ShortCut = 24627
      OnExecute = aDebAction3Execute
    end
    object aViewDisplayDelButton: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aViewDisplayDelButton'
      Hint = 'Display deleted objects'
      ImageIndex = 126
      OnExecute = aViewDisplayDelExecute
    end
    object aViewZoomMode: TAction
      Category = 'View'
      AutoCheck = True
      Caption = '&Zoom Mode'
      Hint = 'Zoom'
      ImageIndex = 15
      ShortCut = 16461
      OnExecute = aViewZoomModeExecute
    end
    object aServRefreshActiveFrame: TAction
      Category = 'Service'
      Caption = 'Refresh Current Active Frame'
      OnExecute = aServRefreshActiveFrameExecute
    end
    object aToolsFilterA: TAction
      Category = 'Tools'
      Caption = 'Filter A'
      ImageIndex = 100
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFilterB: TAction
      Category = 'Tools'
      Caption = 'Filter B'
      ImageIndex = 101
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFilterC: TAction
      Category = 'Tools'
      Caption = 'Filter C'
      ImageIndex = 102
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFilterD: TAction
      Category = 'Tools'
      Caption = 'Filter D'
      ImageIndex = 103
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFilterE: TAction
      Category = 'Tools'
      Caption = 'Filter E'
      ImageIndex = 104
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFilterF: TAction
      Category = 'Tools'
      Caption = 'Filter F'
      ImageIndex = 105
      OnExecute = aToolsGFilterImgExecute
    end
    object aToolsFlashLight: TAction
      Category = 'Tools'
      AutoCheck = True
      Caption = 'FlashLight Tool'
      OnExecute = aToolsFlashLightExecute
    end
    object aServWindowsSysInfo: TAction
      Category = 'Service'
      Caption = 'Windows System Info'
      OnExecute = aServWindowsSysInfoExecute
    end
    object aToolsFlashLightMode: TAction
      Category = 'Tools'
      AutoCheck = True
      Caption = 'Flashlight Mode'
      Hint = 'Flashlight'
      ImageIndex = 61
      OnExecute = aToolsFlashLightModeExecute
    end
    object aServRemoteClientSetup: TAction
      Category = 'Service'
      Caption = 'Remote Desktop Setup'
      OnExecute = aServRemoteClientSetupExecute
    end
    object aGoToPatients: TAction
      Category = 'GoTo'
      Caption = 'Patient'
      OnExecute = aGoToPatientsExecute
    end
    object aGoToProviders: TAction
      Category = 'GoTo'
      Caption = 'Dentist'
      OnExecute = aGoToProvidersExecute
    end
    object aGoToLocations: TAction
      Category = 'GoTo'
      Caption = 'Practice'
      OnExecute = aGoToLocationsExecute
    end
    object aServSetLogFilesPath: TAction
      Category = 'Service'
      Caption = 'Set logfiles path'
      OnExecute = aServSetLogFilesPathExecute
    end
    object aToolsNoiseAttrs1: TAction
      Category = 'Tools'
      Caption = '&Filters test'
      Hint = 'Filters test '
      ImageIndex = 26
      OnExecute = aToolsNoiseAttrs1Execute
    end
    object aServSAModeSetup: TAction
      Category = 'Service'
      Caption = 'Alone Mode Setup'
      OnExecute = aServSAModeSetupExecute
    end
    object aServExportPPL: TAction
      Category = 'Service'
      Caption = 'Export Data'
      OnExecute = aServExportPPLExecute
    end
    object aServImportPPL: TAction
      Category = 'Service'
      Caption = 'Import Data'
      OnExecute = aServImportPPLExecute
    end
    object aServSysSetup: TAction
      Category = 'Service'
      Caption = 'System Setup'
      OnExecute = aServSysSetupExecute
    end
    object aServLinkSetup: TAction
      Category = 'Service'
      Caption = 'Link Setup'
      OnExecute = aServLinkSetupExecute
    end
    object aToolsImgSharp: TAction
      Category = 'Tools'
      Caption = '&Sharp'
      Hint = 'Sharp'
      ImageIndex = 36
      OnExecute = aToolsImgSharpExecute
    end
    object aToolsImgSmooth: TAction
      Category = 'Tools'
      Caption = 'S&mooth'
      Hint = 'Smooth'
      ImageIndex = 35
      OnExecute = aToolsImgSmoothExecute
    end
    object aToolsMedian: TAction
      Category = 'Tools'
      Caption = 'Me&dian'
      Hint = 'Median'
      ImageIndex = 117
      OnExecute = aToolsMedianExecute
    end
    object aToolsDespeckle: TAction
      Category = 'Tools'
      Caption = 'Despeckle'
      Hint = 'Despeckle'
      ImageIndex = 118
      OnExecute = aToolsDespeckleExecute
    end
    object aToolsConvToGrey: TAction
      Category = 'Tools'
      Caption = 'Convert to greyscale'
      Hint = 'Convert to greyscale'
      ImageIndex = 115
      OnExecute = aToolsConvToGreyExecute
    end
    object aToolsConvTo8: TAction
      Category = 'Tools'
      Caption = 'Convert to 8 bit'
      Hint = 'Convert to 8 bit'
      ImageIndex = 114
      OnExecute = aToolsConvTo8Execute
    end
    object aServApplyCLLContext: TAction
      Category = 'Service'
      Caption = 'Apply CLL Context'
      OnExecute = aServApplyCLLContextExecute
    end
    object aGoToStudy: TAction
      Category = 'GoTo'
      Caption = 'Study ...'
      OnExecute = aGoToStudyExecute
    end
    object aViewStudyOnly: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'View Studies Only'
      Hint = 'View Studies Only'
      ImageIndex = 107
      OnExecute = aViewStudyOnlyExecute
    end
    object aServUse16BitImages: TAction
      Category = 'Service'
      AutoCheck = True
      Caption = '16bit'
      OnExecute = aServUse16BitImagesExecute
    end
    object aServUseGDIPlus: TAction
      Category = 'Service'
      AutoCheck = True
      Caption = 'GDI+'
      OnExecute = aServUseGDIPlusExecute
    end
    object aToolsAutoContrast: TAction
      Category = 'Tools'
      Caption = 'Auto Contrast'
      Hint = 'Auto Contrast Image'
      ImageIndex = 116
      OnExecute = aToolsAutoContrastExecute
    end
    object aDebOption1: TAction
      Category = 'Debug1'
      Caption = 'Deb Option 1'
      OnExecute = aDebOption1Execute
    end
    object aDebOption2: TAction
      Category = 'Debug1'
      Caption = 'Deb Option 2'
      OnExecute = aDebOption2Execute
    end
    object aServResampleLarge: TAction
      Category = 'Service'
      Caption = 'Check image files size ...'
      OnExecute = aServResampleLargeExecute
    end
    object aServCreateStudyFiles: TAction
      Category = 'Service'
      Caption = 'Fix the study data ...'
      OnExecute = aServCreateStudyFilesExecute
    end
    object aDICOMImport: TAction
      Category = 'DICOM'
      Caption = 'DICOM Import'
      OnExecute = aDICOMImportExecute
    end
    object aDICOMExport: TAction
      Category = 'DICOM'
      Caption = 'DICOM Export'
      OnExecute = aDICOMExportExecute
    end
    object aDICOMDIRImport: TAction
      Category = 'DICOM'
      Caption = 'DICOMDIR Import'
      OnExecute = aDICOMDIRImportExecute
    end
    object aDICOMDIRExport: TAction
      Category = 'DICOM'
      Caption = 'DICOMDIR Export'
      OnExecute = aDICOMDIRExportExecute
    end
    object aDICOMImportFolder: TAction
      Category = 'DICOM'
      Caption = 'DICOM Import folder'
      OnExecute = aDICOMImportFolderExecute
    end
    object aServSpecialSettings: TAction
      Category = 'Service'
      Caption = 'Special Settings'
      OnExecute = aServSpecialSettingsExecute
    end
    object aServLaunchVEUI: TAction
      Category = 'Service'
      Caption = 'aServLaunchVEUI'
      OnExecute = aServLaunchVEUIExecute
    end
    object aServLaunchHPUI: TAction
      Category = 'Service'
      Caption = 'aServLaunchHPUI'
      OnExecute = aServLaunchHPUIExecute
    end
    object aCapClientScan: TAction
      Category = 'Capture'
      Caption = 'Client capture'
      Hint = 'Capture using Client Scanner'
      ImageIndex = 108
      Visible = False
      OnExecute = aCapClientScanExecute
    end
    object aCaptByDentalUnit: TAction
      Category = 'Capture'
      Caption = 'Start Capture by Dental Unit'
      OnExecute = VideoOnExecuteHandler
    end
    object aDeb2CreateScanExeDistr: TAction
      Category = 'Debug2'
      Caption = '_Create CMScan.exe Distributive '
      OnExecute = aDeb2CreateDemoExeDistrExecute
    end
    object aServLaunchIUApp: TAction
      Category = 'Service'
      Caption = 'Check for Software Updates'
      OnExecute = aServLaunchIUAppExecute
    end
    object aServLaunchIUAppAuto: TAction
      Category = 'Service'
      Caption = 'aServLaunchIUAppAuto'
      OnExecute = aServLaunchIUAppAutoExecute
    end
    object aVTBCustToolBar: TAction
      Category = 'Toolbars'
      Caption = 'Customize Toolbar ...'
      OnExecute = aVTBCustToolBarExecute
    end
    object aServDCMSetup: TAction
      Category = 'Service'
      Caption = 'DICOM configuration settings'
      OnExecute = aServDCMSetupExecute
    end
    object aServEmailSettings: TAction
      Category = 'Service'
      Caption = 'E-mail settings'
      OnExecute = aServEmailSettingsExecute
    end
    object aDICOMQuery: TAction
      Category = 'DICOM'
      Caption = 'DICOM Query/Retrieve'
      Visible = False
      OnExecute = aDICOMQueryExecute
    end
    object aServRepairAttrs1: TAction
      Category = 'Service'
      Caption = 'Repair Image Size ...'
      OnExecute = aServRepairAttrs1Execute
    end
    object aServPrintTemplatesFNameSet: TAction
      Category = 'Service'
      Caption = 'Select new Print Templates'
      OnExecute = aServPrintTemplatesFNameSetExecute
    end
    object aServPrintTemplatesExport: TAction
      Category = 'Service'
      Caption = 'Export Print Templates'
      OnExecute = aServPrintTemplatesExportExecute
    end
    object aViewPresentation: TAction
      Category = 'View'
      Caption = 'Presentation ...'
      OnExecute = aViewPresentationExecute
    end
    object aObjDot: TAction
      Category = 'Objects'
      Caption = '&Dot Text Annotation'
      ImageIndex = 127
      OnExecute = aObjDotExecute
    end
    object aServClearImg3DTmpFiles: TAction
      Category = 'Service'
      Caption = 'Clear Img3D Temporary Files'
      OnExecute = aServClearImg3DTmpFilesExecute
    end
    object aServRemoveLogsHandling: TAction
      Category = 'Service'
      Caption = 'LogFiles Retention ...'
      OnExecute = aServRemoveLogsHandlingExecute
    end
    object aDebSkip3DViewCall: TAction
      Category = 'Debug1'
      AutoCheck = True
      Caption = '_Skip 3DView Call'
      OnExecute = aDebSkip3DViewCallExecute
    end
    object aServClearInstLostRecords: TAction
      Category = 'Service'
      Caption = 'Clear Instances Lost Records'
      OnExecute = aServClearInstLostRecordsExecute
    end
    object aServArchSave: TAction
      Category = 'Service'
      Caption = 'Archiving objects'
      OnExecute = aServArchSaveExecute
    end
    object aServArchRestore: TAction
      Category = 'Service'
      Caption = 'Restoring objects from Archive'
      OnExecute = aServArchRestoreExecute
    end
    object aViewDisplayArchived: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'Display archived objects'
      Visible = False
      OnExecute = aViewDisplayArchivedExecute
    end
    object aMediaArchRestQAdd: TAction
      Category = 'Media'
      Caption = 'Add archived objects to restoring queue'
      OnExecute = aMediaArchRestQAddExecute
    end
    object aMediaArchRestQDel: TAction
      Category = 'Media'
      Caption = 'Delete archived objects from restoring queue'
      OnExecute = aMediaArchRestQDelExecute
    end
    object aServSysSetupUI: TAction
      Category = 'Service'
      Caption = 'System Setup ...'
      OnExecute = aServSysSetupUIExecute
    end
    object aServPatCopyMove: TAction
      Category = 'Service'
      Caption = 'Launch patient Copy/Move media objects'
      OnExecute = aServPatCopyMoveExecute
    end
    object aServSwitchToPhotometry: TAction
      Category = 'Service'
      Caption = 'Switch User Interface to photometry mode'
      OnExecute = aServSwitchToPhotometryExecute
    end
    object aServSwitchFromPhotometry: TAction
      Category = 'Service'
      Caption = 'Switch User Interface to MediaSuite mode'
      OnExecute = aServSwitchFromPhotometryExecute
    end
    object aServWEBSettings: TAction
      Category = 'Service'
      Caption = 'WEB Settings'
      OnExecute = aServWEBSettingsExecute
    end
    object aMediaExport3D: TAction
      Category = 'Media'
      Caption = '3D Export ...'
      Hint = 'Export marked 3D object files to selected folder'
      ImageIndex = 31
      ShortCut = 49236
      Visible = False
      OnExecute = aMediaExport3DExecute
    end
    object aDICOMStore: TAction
      Category = 'DICOM'
      Caption = 'DICOM Store'
      OnExecute = aDICOMStoreExecute
    end
    object aDICOMMWL: TAction
      Category = 'DICOM'
      Caption = 'DICOM MWL'
      OnExecute = aDICOMMWLExecute
    end
    object aDICOMCommitment: TAction
      Category = 'DICOM'
      Caption = 'DICOM Commitment'
      OnExecute = aDICOMCommitmentExecute
    end
    object aServChangeDBAPSW: TAction
      Category = 'Service'
      Caption = 'Change database password'
      OnExecute = aServChangeDBAPSWExecute
    end
    object aServExportSlidesAll: TAction
      Category = 'Service'
      Caption = 'Export Slides All'
      OnExecute = aServExportSlidesAllExecute
    end
  end
  object MainIcons18: TImageList
    Height = 18
    Width = 18
    Left = 8
    Top = 8
  end
  object ThumbsRFrPopupMenu: TPopupMenu
    Images = MainIcons18
    OnPopup = ThumbsRFrPopupMenuPopup
    Left = 8
    Top = 48
    object PropertiesDiagnoses1: TMenuItem
      Action = aGoToPropDiagMulti
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object SelectAll1: TMenuItem
      Action = aEditSelectAll
    end
    object InvertSelection1: TMenuItem
      Action = aEditInvertSelection
      ImageIndex = 95
    end
    object ClearSelection1: TMenuItem
      Action = aEditClearSelection
      ImageIndex = 96
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Print1: TMenuItem
      Action = aGoToPrint
    end
    object Printstudiesonly1: TMenuItem
      Action = aGoToPrintStudiesOnly
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object Import1: TMenuItem
      Action = aMediaImport
    end
    object Export1: TMenuItem
      Action = aMediaExportMarked
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object Paste1: TMenuItem
      Action = aMediaWCImport
    end
    object Copy1: TMenuItem
      Action = aMediaWCExport
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object Open1: TMenuItem
      Action = aMediaOpen
    end
    object Duplicate1: TMenuItem
      Action = aMediaDuplicate
    end
    object Presentation1: TMenuItem
      Action = aViewPresentation
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object CopytoD4WDocumentManager1: TMenuItem
      Action = aMediaExportToD4WDocs
    end
    object Email1: TMenuItem
      Action = aMediaEMail1
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N3DImport1: TMenuItem
      Action = aMediaImport3D
    end
    object Export3D1: TMenuItem
      Action = aMediaExport3D
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object Archivingobjects1: TMenuItem
      Action = aMediaArchRestQAdd
    end
    object RestoringobjectsfromArchive1: TMenuItem
      Action = aMediaArchRestQDel
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object Delete1: TMenuItem
      Action = aEditDeleteMarked
    end
    object Restoremarkedasdeleted1: TMenuItem
      Action = aEditRestoreDel
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object ChangeHostLocation1: TMenuItem
      Action = aMediaEMChangeHLoc
    end
    object DICOMStore1: TMenuItem
      Action = aDICOMStore
    end
    object DICOMCommitment1: TMenuItem
      Action = aDICOMCommitment
    end
  end
  object EdFramesPopupMenu: TPopupMenu
    Images = MainIcons18
    Left = 80
    Top = 48
    object ZoomInandOut1: TMenuItem
      Action = aViewZoom
    end
    object Panning1: TMenuItem
      Action = aViewPanning
    end
    object Point1: TMenuItem
      Action = aEditPoint
    end
    object FullScreen1: TMenuItem
      Action = aViewFullScreen
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object FinishEditingSlide1: TMenuItem
      Action = aEditCloseCurActive
    end
    object Export2: TMenuItem
      Action = aMediaExportOpened
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object CopyOpened1: TMenuItem
      Action = aEditCopyOpened
    end
  end
  object DynIcons18: TImageList
    Height = 18
    Width = 18
    Left = 104
    Top = 8
  end
  object DynIcons44: TImageList
    Height = 44
    Width = 44
    Left = 136
    Top = 8
  end
  object EdFrPointPopupMenu: TPopupMenu
    Images = MainIcons18
    OnPopup = EdFrPointPopupMenuPopup
    Left = 112
    Top = 48
    object CreateMultiLineMeasure1: TMenuItem
      Action = aObjPolylineM
    end
    object CreateAngle1: TMenuItem
      Action = aObjAngleNorm
    end
    object CreateFreeAngle1: TMenuItem
      Action = aObjAngleFree
    end
    object mCalibrateImage: TMenuItem
      Caption = '&Calibrate Image'
      Hint = 'Calibrate Image|Calibrate Image '
      ImageIndex = 75
      object CalibrateImagebyline1: TMenuItem
        Action = aObjCalibrate1
      end
      object DebMPAction11: TMenuItem
        Action = aObjCalibrateN
      end
      object CalibrateImagebyimageresolution1: TMenuItem
        Action = aObjCalibrateDPI
      end
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object DeleteDrawing1: TMenuItem
      Action = aObjDelete
    end
    object ChangeDrawingattributes1: TMenuItem
      Action = aObjChangeAttrs
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object Dot1: TMenuItem
      Action = aObjDot
    end
    object CreateTextBox1: TMenuItem
      Action = aObjTextBox
    end
    object CustomizableTextAnnotations1: TMenuItem
      Caption = 'Customizable Text Annotations'
      object Text11: TMenuItem
        Action = aObjCTA1
      end
      object Text21: TMenuItem
        Action = aObjCTA2
      end
      object Text31: TMenuItem
        Action = aObjCTA3
      end
      object Text41: TMenuItem
        Action = aObjCTA4
      end
    end
    object FreeHand1: TMenuItem
      Action = aObjFreeHand
    end
    object CreateMultiLine1: TMenuItem
      Action = aObjPolyline
    end
    object Rectangle1: TMenuItem
      Action = aObjRectangleOld
    end
    object Rectangle2: TMenuItem
      Action = aObjRectangleLine
    end
    object Ellipse1: TMenuItem
      Action = aObjEllipseOld
    end
    object Ellipse2: TMenuItem
      Action = aObjEllipseLine
    end
    object Arrow1: TMenuItem
      Action = aObjArrowOld
    end
    object Arrow2: TMenuItem
      Action = aObjArrowLine
    end
    object Flashlight1: TMenuItem
      Action = aObjFLZEllipse
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object ShowDrawings1: TMenuItem
      Action = aObjShowHide
      AutoCheck = True
    end
    object ShowColorize1: TMenuItem
      Action = aToolsColorize
      AutoCheck = True
    end
    object ShowIsodensity1: TMenuItem
      Action = aToolsIsodens
      AutoCheck = True
    end
    object Emboss1: TMenuItem
      Action = aToolsEmboss
      AutoCheck = True
    end
    object ZoomMode1: TMenuItem
      Action = aViewZoomMode
      AutoCheck = True
    end
    object Histogram1: TMenuItem
      Action = aToolsHistogramm2
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object FinishEditing1: TMenuItem
      Action = aEditCloseCurActive
    end
    object CloseFullScreen1: TMenuItem
      Action = aEditFullScreenClose
    end
  end
  object EdFrCrLinePopupMenu: TPopupMenu
    Images = MainIcons18
    OnPopup = EdFrCrLinePopupMenuPopup
    Left = 144
    Top = 48
    object FinishDrawingCreation1: TMenuItem
      Action = aObjFinishLine
      ImageIndex = 76
    end
    object DeleteDrawing2: TMenuItem
      Action = aObjDelete
    end
  end
  object EdFrameStudyPopupMenu: TPopupMenu
    Images = MainIcons18
    Left = 48
    Top = 48
    object MenuItem1: TMenuItem
      Action = aGoToPropDiagMulti
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MenuItem4: TMenuItem
      Action = aEditStudySelectAll
    end
    object MenuItem5: TMenuItem
      Action = aEditStudyInvertSelection
    end
    object MenuItem6: TMenuItem
      Action = aEditStudyClearSelection
    end
    object MenuItem7: TMenuItem
      Caption = '-'
    end
    object MenuItem8: TMenuItem
      Action = aGoToPrint
    end
    object MenuItem10: TMenuItem
      Action = aMediaExportMarked
    end
    object MenuItem11: TMenuItem
      Action = aMediaOpen
    end
    object MenuItem13: TMenuItem
      Action = aMediaEMail1
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object Dismountselected1: TMenuItem
      Action = aEditStudyDismount
    end
    object SelectCurrentVisible1: TMenuItem
      Action = aEditStudyItemSelectVis
    end
    object CloseFullScreen2: TMenuItem
      Action = aEditFullScreenClose
    end
    object Close1: TMenuItem
      Action = aEditCloseCurActive
    end
  end
end
