inherited K_FormCMUTLoadDBData: TK_FormCMUTLoadDBData
  Left = 160
  Top = 189
  Width = 444
  Height = 367
  Caption = 'Add data (from other DB)'
  Constraints.MaxHeight = 367
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 424
    Top = 321
  end
  object GBAll: TGroupBox
    Left = 8
    Top = 40
    Width = 420
    Height = 239
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    OnClick = ChBLoadMediaClick
    object LbPatients: TLabel
      Left = 14
      Top = 66
      Width = 38
      Height = 13
      Caption = 'Patients'
    end
    object LbProviders: TLabel
      Left = 14
      Top = 90
      Width = 44
      Height = 13
      Caption = 'Providers'
    end
    object LbLocations: TLabel
      Left = 14
      Top = 114
      Width = 46
      Height = 13
      Caption = 'Locations'
    end
    object LbServers: TLabel
      Left = 14
      Top = 138
      Width = 36
      Height = 13
      Caption = 'Servers'
    end
    object LbOpened: TLabel
      Left = 142
      Top = 18
      Width = 38
      Height = 13
      Caption = 'Opened'
    end
    object LbClients: TLabel
      Left = 14
      Top = 162
      Width = 31
      Height = 13
      Caption = 'Clients'
    end
    object LbAppContexts: TLabel
      Left = 14
      Top = 186
      Width = 95
      Height = 13
      Caption = 'Application contexts'
    end
    object LbStatistics: TLabel
      Left = 14
      Top = 210
      Width = 42
      Height = 13
      Caption = 'Statistics'
    end
    object LbCollisions: TLabel
      Left = 238
      Top = 18
      Width = 85
      Height = 13
      Caption = 'Resolve Collisions'
    end
    object LbLoad: TLabel
      Left = 374
      Top = 18
      Width = 19
      Height = 13
      Caption = 'Add'
    end
    object LbMedia: TLabel
      Left = 14
      Top = 42
      Width = 66
      Height = 13
      Caption = 'Media objects'
    end
    object ChBOpenPat: TCheckBox
      Left = 158
      Top = 66
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 0
    end
    object ChBOpenProv: TCheckBox
      Left = 158
      Top = 90
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 1
    end
    object ChBOpenLoc: TCheckBox
      Left = 158
      Top = 114
      Width = 15
      Height = 17
      Caption = 'Locations'
      Enabled = False
      TabOrder = 2
    end
    object ChBOpenCont: TCheckBox
      Left = 158
      Top = 186
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Enabled = False
      TabOrder = 3
    end
    object ChBOpenStat: TCheckBox
      Left = 158
      Top = 210
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Enabled = False
      TabOrder = 4
    end
    object ChBOpenServ: TCheckBox
      Left = 158
      Top = 138
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Enabled = False
      TabOrder = 5
    end
    object ChBOpenClient: TCheckBox
      Left = 158
      Top = 162
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Enabled = False
      TabOrder = 6
    end
    object ChBOpenMedia: TCheckBox
      Left = 158
      Top = 42
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 7
    end
    object ChBLoadMedia: TCheckBox
      Left = 382
      Top = 42
      Width = 15
      Height = 17
      TabOrder = 8
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadPat: TCheckBox
      Left = 382
      Top = 66
      Width = 15
      Height = 17
      TabOrder = 9
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadProv: TCheckBox
      Left = 382
      Top = 90
      Width = 15
      Height = 17
      TabOrder = 10
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadLoc: TCheckBox
      Left = 382
      Top = 114
      Width = 15
      Height = 17
      Caption = 'Locations'
      TabOrder = 11
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadServ: TCheckBox
      Left = 382
      Top = 138
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      TabOrder = 12
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadClient: TCheckBox
      Left = 382
      Top = 162
      Width = 15
      Height = 17
      Caption = 'Statistics'
      TabOrder = 13
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadCont: TCheckBox
      Left = 382
      Top = 186
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      TabOrder = 14
      OnClick = ChBLoadMediaClick
    end
    object ChBLoadStat: TCheckBox
      Left = 382
      Top = 210
      Width = 15
      Height = 17
      Caption = 'Statistics'
      TabOrder = 15
      OnClick = ChBLoadMediaClick
    end
    object ChBResMedia: TCheckBox
      Left = 270
      Top = 42
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 16
    end
    object ChBResPat: TCheckBox
      Left = 270
      Top = 66
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 17
    end
    object ChBResProv: TCheckBox
      Left = 270
      Top = 90
      Width = 15
      Height = 17
      Enabled = False
      TabOrder = 18
    end
    object ChBResLoc: TCheckBox
      Left = 270
      Top = 114
      Width = 15
      Height = 17
      Caption = 'Locations'
      Enabled = False
      TabOrder = 19
    end
    object ChBResServ: TCheckBox
      Left = 270
      Top = 138
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Enabled = False
      TabOrder = 20
    end
    object ChBResClient: TCheckBox
      Left = 270
      Top = 162
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Enabled = False
      TabOrder = 21
    end
    object ChBResCont: TCheckBox
      Left = 270
      Top = 186
      Width = 15
      Height = 17
      Caption = 'Application contexts'
      Enabled = False
      TabOrder = 22
    end
    object ChBResStat: TCheckBox
      Left = 270
      Top = 210
      Width = 15
      Height = 17
      Caption = 'Statistics'
      Enabled = False
      TabOrder = 23
    end
  end
  object BtCancel: TButton
    Left = 355
    Top = 286
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 2
  end
  inline PathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 8
    Top = 8
    Width = 420
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 0
      Width = 113
      Alignment = taLeftJustify
      Caption = 'Adding data root folder :'
    end
    inherited mbPathName: TComboBox
      Left = 128
      Width = 258
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 395
      Top = 2
      Width = 22
    end
  end
  object BtLoad: TButton
    Left = 275
    Top = 286
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Add'
    TabOrder = 4
    OnClick = BtLoadClick
  end
  object BtOpen: TButton
    Left = 187
    Top = 286
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Open data'
    TabOrder = 5
    OnClick = BtOpenClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 309
    Width = 428
    Height = 19
    Panels = <>
  end
end
