inherited K_FormCMUTLoadDBData3: TK_FormCMUTLoadDBData3
  Left = 272
  Top = 197
  Width = 477
  Height = 542
  Caption = 'Add data (from other DB)'
  Constraints.MaxHeight = 542
  Constraints.MinHeight = 542
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 10
    Top = 426
    Width = 248
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 449
    Top = 491
  end
  object GBAll: TGroupBox
    Left = 8
    Top = 142
    Width = 449
    Height = 239
    Anchors = [akLeft, akRight, akBottom]
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
    Left = 380
    Top = 438
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
    Width = 453
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 0
      Width = 131
      Alignment = taLeftJustify
      Caption = 'Adding DB data root folder :'
    end
    inherited mbPathName: TComboBox
      Left = 136
      Width = 283
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 428
      Top = 2
      Width = 22
    end
  end
  object BtLoad: TButton
    Left = 220
    Top = 438
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Add DB data'
    Enabled = False
    TabOrder = 4
    OnClick = BtLoadClick
  end
  object BtOpen: TButton
    Left = 140
    Top = 438
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Open data'
    TabOrder = 5
    OnClick = BtOpenClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 484
    Width = 461
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ChBCheckFS: TCheckBox
    Left = 272
    Top = 390
    Width = 161
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = 'Comprehensive data analysis'
    Enabled = False
    TabOrder = 7
  end
  object BtCopy: TButton
    Left = 300
    Top = 422
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Copy files'
    Enabled = False
    TabOrder = 8
    OnClick = BtCopyClick
  end
  object ChBSkipContext: TCheckBox
    Left = 8
    Top = 442
    Width = 121
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Skip previous results'
    TabOrder = 9
  end
  object GBFileStorage: TGroupBox
    Left = 8
    Top = 40
    Width = 449
    Height = 97
    Caption = '  Adding files storage copy  '
    TabOrder = 10
    DesignSize = (
      449
      97)
    inline Img3DPathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 8
      Top = 66
      Width = 434
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      inherited LbPathName: TLabel
        Left = 0
        Width = 87
        Alignment = taLeftJustify
        Caption = 'Img3D root folder :'
      end
      inherited mbPathName: TComboBox
        Left = 90
        Width = 310
        Color = 10682367
      end
      inherited bnBrowse_1: TButton
        Left = 409
        Top = 2
        Width = 22
      end
    end
    inline VideoPathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 8
      Top = 41
      Width = 434
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      inherited LbPathName: TLabel
        Left = 0
        Width = 83
        Alignment = taLeftJustify
        Caption = 'Video root folder :'
      end
      inherited mbPathName: TComboBox
        Left = 90
        Width = 310
        Color = 10682367
      end
      inherited bnBrowse_1: TButton
        Left = 409
        Top = 2
        Width = 22
      end
    end
    inline ImgPathNameFrame: TK_FPathNameFrame
      Tag = 161
      Left = 8
      Top = 16
      Width = 434
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      inherited LbPathName: TLabel
        Left = 0
        Width = 73
        Alignment = taLeftJustify
        Caption = 'Img root folder :'
      end
      inherited mbPathName: TComboBox
        Left = 90
        Width = 310
        Color = 10682367
      end
      inherited bnBrowse_1: TButton
        Left = 409
        Top = 2
        Width = 22
      end
    end
  end
  object BtUndoCopy: TButton
    Left = 300
    Top = 454
    Width = 73
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Undo copy'
    Enabled = False
    TabOrder = 11
    OnClick = BtUndoCopyClick
  end
end
