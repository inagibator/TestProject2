inherited K_FormCMUTLoadDBData1: TK_FormCMUTLoadDBData1
  Left = 216
  Top = 185
  Width = 456
  Height = 408
  Caption = 'Add data (from other DB)'
  Constraints.MaxHeight = 408
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 10
    Top = 324
    Width = 172
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 428
    Top = 357
  end
  object GBAll: TGroupBox
    Left = 8
    Top = 40
    Width = 428
    Height = 239
    Anchors = [akLeft, akTop, akRight]
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
    Left = 359
    Top = 320
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
    Width = 432
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
      Width = 270
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 407
      Top = 2
      Width = 22
    end
  end
  object BtLoad: TButton
    Left = 279
    Top = 320
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Add'
    TabOrder = 4
    OnClick = BtLoadClick
  end
  object BtOpen: TButton
    Left = 191
    Top = 320
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Open data'
    TabOrder = 5
    OnClick = BtOpenClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 350
    Width = 440
    Height = 19
    Panels = <>
  end
  object ChBCheckFS: TCheckBox
    Left = 24
    Top = 288
    Width = 401
    Height = 17
    Caption = 'Comprehensive data analysis'
    TabOrder = 7
  end
end
