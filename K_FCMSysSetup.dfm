inherited K_FormCMSysSetup: TK_FormCMSysSetup
  Left = 312
  Top = 137
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'System Setup '
  ClientHeight = 570
  ClientWidth = 542
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 530
    Top = 558
  end
  object BtCancel: TButton
    Left = 469
    Top = 537
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object GBGeneral: TGroupBox
    Left = 8
    Top = 8
    Width = 257
    Height = 313
    Caption = '  General  '
    TabOrder = 2
    object Button1: TButton
      Left = 16
      Top = 24
      Width = 225
      Height = 25
      Action = N_CMResForm.aServWindowsSysInfo
      TabOrder = 0
    end
    object Button2: TButton
      Left = 16
      Top = 56
      Width = 225
      Height = 25
      Action = N_CMResForm.aServDelObjHandling
      TabOrder = 1
    end
    object Button3: TButton
      Left = 16
      Top = 88
      Width = 225
      Height = 25
      Action = N_CMResForm.aServSetCaptureDelay
      TabOrder = 2
    end
    object Button4: TButton
      Left = 16
      Top = 120
      Width = 225
      Height = 25
      Action = N_CMResForm.aServSetLogFilesPath
      TabOrder = 3
    end
    object Button5: TButton
      Left = 16
      Top = 184
      Width = 225
      Height = 25
      Action = N_CMResForm.aServConvCMSImgToBMP1
      TabOrder = 4
    end
    object CheckBox1: TCheckBox
      Left = 16
      Top = 256
      Width = 225
      Height = 17
      Action = N_CMResForm.aServXRAYStreamLine
      TabOrder = 5
    end
    object CheckBox2: TCheckBox
      Left = 16
      Top = 280
      Width = 49
      Height = 17
      Action = N_CMResForm.aServUse16BitImages
      TabOrder = 6
    end
    object CheckBox3: TCheckBox
      Left = 72
      Top = 280
      Width = 73
      Height = 17
      Action = N_CMResForm.aServUseGDIPlus
      TabOrder = 7
    end
    object BtAutoRefreshSet: TButton
      Left = 16
      Top = 152
      Width = 225
      Height = 25
      Caption = 'Automatic Refresh'
      TabOrder = 8
      OnClick = BtAutoRefreshSetClick
    end
    object Button20: TButton
      Left = 16
      Top = 216
      Width = 225
      Height = 25
      Action = N_CMResForm.aServRemoveLogsHandling
      TabOrder = 9
    end
  end
  object GBDB: TGroupBox
    Left = 278
    Top = 8
    Width = 257
    Height = 265
    Caption = '  Database  '
    TabOrder = 3
    object Button8: TButton
      Left = 16
      Top = 24
      Width = 225
      Height = 25
      Action = N_CMResForm.aServFilesHandling
      TabOrder = 0
    end
    object Button9: TButton
      Left = 16
      Top = 88
      Width = 225
      Height = 25
      Action = N_CMResForm.aServDBRecoveryByFiles
      TabOrder = 1
    end
    object Button10: TButton
      Left = 16
      Top = 56
      Width = 225
      Height = 25
      Action = N_CMResForm.aServMaintenance
      TabOrder = 2
    end
    object Button15: TButton
      Left = 16
      Top = 120
      Width = 225
      Height = 25
      Action = N_CMResForm.aServResampleLarge
      TabOrder = 3
    end
    object Button17: TButton
      Left = 16
      Top = 152
      Width = 225
      Height = 25
      Action = N_CMResForm.aServECacheRecovery
      TabOrder = 4
    end
    object Button22: TButton
      Left = 16
      Top = 184
      Width = 225
      Height = 25
      Action = N_CMResForm.aServArchSave
      TabOrder = 5
    end
    object Button23: TButton
      Left = 16
      Top = 216
      Width = 225
      Height = 25
      Action = N_CMResForm.aServArchRestore
      TabOrder = 6
    end
  end
  object GBSA: TGroupBox
    Left = 278
    Top = 287
    Width = 257
    Height = 129
    Caption = '  Stand Alone Setup  '
    TabOrder = 4
    object Button11: TButton
      Left = 16
      Top = 24
      Width = 225
      Height = 25
      Action = N_CMResForm.aServSAModeSetup
      TabOrder = 0
    end
    object Button12: TButton
      Left = 16
      Top = 88
      Width = 225
      Height = 25
      Action = N_CMResForm.aServExportPPL
      TabOrder = 1
    end
    object Button13: TButton
      Left = 16
      Top = 56
      Width = 225
      Height = 25
      Action = N_CMResForm.aServImportPPL
      TabOrder = 2
    end
  end
  object Button6: TButton
    Left = 24
    Top = 336
    Width = 225
    Height = 25
    Action = N_CMResForm.aServRemoteClientSetup
    TabOrder = 5
  end
  object Button7: TButton
    Left = 24
    Top = 368
    Width = 225
    Height = 25
    Action = N_CMResForm.aServImportExtDBDlg
    TabOrder = 6
  end
  object Button14: TButton
    Left = 24
    Top = 400
    Width = 225
    Height = 25
    Action = N_CMResForm.aServLinkSetup
    TabOrder = 7
  end
  object Button16: TButton
    Left = 24
    Top = 464
    Width = 225
    Height = 25
    Action = N_CMResForm.aServSpecialSettings
    TabOrder = 8
  end
  object BtWEBAccounts: TButton
    Left = 24
    Top = 528
    Width = 225
    Height = 25
    Caption = 'Web accounts setup'
    TabOrder = 9
    OnClick = BtWEBAccountsClick
  end
  object BtIUApplication: TButton
    Left = 24
    Top = 496
    Width = 225
    Height = 25
    Caption = 'Internet upgrade application'
    TabOrder = 10
    OnClick = BtIUApplicationClick
  end
  object Button18: TButton
    Left = 24
    Top = 432
    Width = 225
    Height = 25
    Action = N_CMResForm.aServDCMSetup
    TabOrder = 11
  end
  object GBPrintTemplates: TGroupBox
    Left = 278
    Top = 427
    Width = 257
    Height = 97
    Caption = '  Print Templates Setup  '
    TabOrder = 12
    object Button19: TButton
      Left = 16
      Top = 24
      Width = 225
      Height = 25
      Action = N_CMResForm.aServPrintTemplatesFNameSet
      TabOrder = 0
    end
    object Button21: TButton
      Left = 16
      Top = 56
      Width = 225
      Height = 25
      Action = N_CMResForm.aServPrintTemplatesExport
      TabOrder = 1
    end
  end
end
