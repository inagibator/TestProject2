inherited K_FormCMUTUnloadDBData: TK_FormCMUTUnloadDBData
  Left = 143
  Top = 569
  Width = 452
  Height = 285
  Caption = 'Unload DB data (for loading to other DB)'
  Constraints.MaxHeight = 285
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 202
    Width = 249
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 432
    Top = 239
  end
  object GBAll: TGroupBox
    Left = 8
    Top = 40
    Width = 428
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '  Data processing flags  '
    TabOrder = 1
    object LbPatients: TLabel
      Left = 22
      Top = 98
      Width = 75
      Height = 13
      Caption = 'Unload Patients'
    end
    object LbProviders: TLabel
      Left = 22
      Top = 122
      Width = 81
      Height = 13
      Caption = 'Unload Providers'
    end
    object LbLocations: TLabel
      Left = 238
      Top = 26
      Width = 83
      Height = 13
      Caption = 'Unload Locations'
    end
    object LbServers: TLabel
      Left = 238
      Top = 50
      Width = 73
      Height = 13
      Caption = 'Unload Servers'
    end
    object LbClients: TLabel
      Left = 238
      Top = 74
      Width = 68
      Height = 13
      Caption = 'Unload Clients'
    end
    object LbAppContexts: TLabel
      Left = 238
      Top = 98
      Width = 136
      Height = 13
      Caption = 'Unload Media Suite contexts'
    end
    object LbStatistics: TLabel
      Left = 238
      Top = 122
      Width = 79
      Height = 13
      Caption = 'Unload Statistics'
    end
    object LbMedia: TLabel
      Left = 22
      Top = 26
      Width = 103
      Height = 13
      Caption = 'Unload Media objects'
    end
    object LbCopyMedia: TLabel
      Left = 22
      Top = 50
      Width = 77
      Height = 13
      Caption = 'Copy Media files'
    end
    object LbFrom: TLabel
      Left = 40
      Top = 77
      Width = 20
      Height = 13
      Caption = 'from'
    end
    object ChBUnloadPat: TCheckBox
      Left = 142
      Top = 98
      Width = 15
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object ChBUnloadProv: TCheckBox
      Left = 142
      Top = 122
      Width = 15
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object ChBUnloadLoc: TCheckBox
      Left = 382
      Top = 26
      Width = 15
      Height = 17
      Caption = 'Locations'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object ChBUnloadCont: TCheckBox
      Left = 382
      Top = 98
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object ChBUnloadStat: TCheckBox
      Left = 382
      Top = 122
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object ChBUnloadServ: TCheckBox
      Left = 382
      Top = 50
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object ChBUnloadClient: TCheckBox
      Left = 382
      Top = 74
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object ChBUnloadMedia: TCheckBox
      Left = 142
      Top = 26
      Width = 15
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object ChBCopyMedia: TCheckBox
      Left = 142
      Top = 50
      Width = 15
      Height = 17
      Caption = 'Statistics'
      TabOrder = 8
    end
    object DTPFrom: TDateTimePicker
      Left = 72
      Top = 73
      Width = 99
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      ShowCheckbox = True
      Checked = False
      Color = 10682367
      TabOrder = 9
      OnChange = DTPFromChange
    end
  end
  object BtCancel: TButton
    Left = 363
    Top = 202
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 2
  end
  inline PathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 9
    Top = 8
    Width = 428
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 0
      Width = 104
      Alignment = taLeftJustify
      Caption = 'Copy data root folder :'
    end
    inherited mbPathName: TComboBox
      Left = 112
      Width = 282
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 403
      Top = 2
      Width = 22
    end
  end
  object BtUnload: TButton
    Left = 283
    Top = 202
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Unload'
    TabOrder = 4
    OnClick = BtUnloadClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 227
    Width = 436
    Height = 19
    Panels = <>
  end
end
