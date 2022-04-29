inherited K_FormCMSupport: TK_FormCMSupport
  Left = 723
  Top = 496
  Caption = 'MediaSuite Support'
  ClientHeight = 400
  ClientWidth = 477
  OldCreateOrder = True
  OnCanResize = FormCanResize
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnShow = FormShow
  ExplicitWidth = 493
  ExplicitHeight = 439
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 473
    Top = 393
    ExplicitLeft = 473
    ExplicitTop = 393
  end
  object GBInfo: TGroupBox
    Left = 16
    Top = 8
    Width = 459
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    Caption = '   DB Info   '
    TabOrder = 1
    DesignSize = (
      459
      89)
    object MemInfo: TMemo
      Left = 8
      Top = 16
      Width = 443
      Height = 65
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelInner = bvLowered
      BevelOuter = bvRaised
      BorderStyle = bsNone
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
      WordWrap = False
    end
  end
  object GBUtils: TGroupBox
    Left = 16
    Top = 104
    Width = 459
    Height = 273
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '   Utilities   '
    TabOrder = 2
    object BtDBRecovery: TButton
      Left = 12
      Top = 48
      Width = 107
      Height = 25
      Caption = 'DB recovery ...'
      TabOrder = 0
      OnClick = BtDBRecoveryClick
    end
    object BtSysInfo: TButton
      Left = 12
      Top = 16
      Width = 107
      Height = 25
      Caption = 'System information'
      TabOrder = 1
      OnClick = BtSysInfoClick
    end
    object BtImportChngAttrs: TButton
      Left = 12
      Top = 144
      Width = 107
      Height = 25
      Caption = 'Change Imported ...'
      TabOrder = 2
      OnClick = BtImportChngAttrsClick
    end
    object BtCheckFileSize: TButton
      Left = 124
      Top = 16
      Width = 137
      Height = 25
      Action = N_CMResForm.aServResampleLarge
      TabOrder = 3
    end
    object BtCopyFiles: TButton
      Left = 104
      Top = -8
      Width = 137
      Height = 25
      Caption = 'Copy restored files ...'
      TabOrder = 4
      Visible = False
      OnClick = BtCopyFilesClick
    end
    object BtClearFiles: TButton
      Left = 98
      Top = -8
      Width = 137
      Height = 18
      Caption = 'Clear restore info'
      TabOrder = 5
      Visible = False
      OnClick = BtClearFilesClick
    end
    object BtChangePPLIDs: TButton
      Left = 268
      Top = 16
      Width = 180
      Height = 25
      Caption = 'Link Patients ID ...'
      TabOrder = 6
      OnClick = BtChangePPLIDsClick
    end
    object BtUloadDBData: TButton
      Left = 248
      Top = -8
      Width = 137
      Height = 25
      Caption = 'Unload DB Data ...'
      TabOrder = 7
      Visible = False
      OnClick = BtUloadDBDataClick
    end
    object BtLoadDBData: TButton
      Left = 268
      Top = -8
      Width = 163
      Height = 25
      Caption = 'Load  DB Data to target ...'
      TabOrder = 8
      Visible = False
      OnClick = BtLoadDBDataClick
    end
    object BtRepairImageSize: TButton
      Left = 124
      Top = 48
      Width = 137
      Height = 25
      Action = N_CMResForm.aServRepairAttrs1
      TabOrder = 9
    end
    object BtDeleteSlides: TButton
      Left = 124
      Top = 80
      Width = 137
      Height = 25
      Caption = 'Delete media objects ...'
      TabOrder = 10
      OnClick = BtDeleteSlidesClick
    end
    object BtFSAnalysis: TButton
      Left = 124
      Top = 112
      Width = 137
      Height = 25
      Caption = 'Files Storage analysis ...'
      TabOrder = 11
      OnClick = BtFSAnalysisClick
    end
    object BtFSClear: TButton
      Left = 12
      Top = 112
      Width = 107
      Height = 25
      Caption = 'Files Storage clear ...'
      TabOrder = 12
      OnClick = BtFSClearClick
    end
    object BtFSDump: TButton
      Left = 268
      Top = 112
      Width = 180
      Height = 25
      Caption = 'Files Storage dump ...'
      TabOrder = 13
      OnClick = BtFSDumpClick
    end
    object BtPrepDBData: TButton
      Left = 244
      Top = -16
      Width = 163
      Height = 25
      Caption = 'Unload DB Data from source ...'
      TabOrder = 14
      Visible = False
      OnClick = BtPrepDBDataClick
    end
    object BtHCFOldFilesList: TButton
      Left = 12
      Top = 176
      Width = 107
      Height = 25
      Caption = 'HCF Files list'
      TabOrder = 15
      OnClick = BtHCFOldFilesListClick
    end
    object BtHCFRenameFiles: TButton
      Left = 124
      Top = 176
      Width = 137
      Height = 25
      Caption = 'HCF Files rename'
      TabOrder = 16
      OnClick = BtHCFRenameFilesClick
    end
    object Button1: TButton
      Left = 12
      Top = 80
      Width = 107
      Height = 25
      Caption = 'DB integrity check ...'
      TabOrder = 17
      OnClick = Button1Click
    end
    object BtSetDBContexts: TButton
      Left = 268
      Top = 176
      Width = 180
      Height = 25
      Caption = 'Apply Toolbar settings'
      TabOrder = 18
      OnClick = BtSetDBContextsClick
    end
    object BtPrepDBData1: TButton
      Left = 268
      Top = 48
      Width = 180
      Height = 25
      Caption = 'Unload DB Data from source ...'
      TabOrder = 19
      OnClick = BtPrepDBData1Click
    end
    object BtLoadDBData3: TButton
      Left = 268
      Top = 80
      Width = 180
      Height = 25
      Caption = 'Load  DB Data and Files to target ...'
      TabOrder = 20
      OnClick = BtLoadDBData3Click
    end
    object BtFSCopy: TButton
      Left = 124
      Top = 144
      Width = 137
      Height = 25
      Caption = 'Files Storage copy ...'
      TabOrder = 21
      OnClick = BtFSACopyClick
    end
    object BtImportExpToDCM: TButton
      Left = 268
      Top = 208
      Width = 180
      Height = 25
      Caption = 'Export to DICOM Last imported ...'
      TabOrder = 22
      OnClick = BtImportExpToDCMClick
    end
    object BtFSACopy: TButton
      Left = 268
      Top = 144
      Width = 181
      Height = 25
      Caption = 'Files Storage additional copy ...'
      TabOrder = 23
      OnClick = BtFSACopyClick
    end
    object btnAnonymizeDB: TButton
      Left = 12
      Top = 208
      Width = 107
      Height = 25
      Caption = 'Anonymize DB'
      TabOrder = 24
    end
    object btnConvertFromD4W: TButton
      Left = 124
      Top = 208
      Width = 137
      Height = 25
      Caption = 'Convert from D4W DM'
      TabOrder = 25
      OnClick = btnConvertFromD4WClick
    end
    object BtExportAll: TButton
      Left = 268
      Top = 239
      Width = 180
      Height = 25
      Action = N_CMResForm.aServExportSlidesAll
      TabOrder = 26
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 381
    Width = 477
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
  end
end
