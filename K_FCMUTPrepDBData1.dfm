inherited K_FormCMUTPrepDBData1: TK_FormCMUTPrepDBData1
  Left = 251
  Top = 386
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Prepare DB data'
  ClientHeight = 257
  ClientWidth = 549
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 16
    Top = 231
    Width = 318
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
  end
  object LbCopyMedia: TLabel [1]
    Left = 14
    Top = 69
    Width = 103
    Height = 13
    Caption = 'Copy Media files from:'
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 539
    Top = 247
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 470
    Top = 224
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 0
  end
  inline PathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 16
    Top = 36
    Width = 519
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    inherited LbPathName: TLabel
      Left = 0
      Width = 79
      Alignment = taLeftJustify
      Caption = 'Resulting folder :'
    end
    inherited mbPathName: TComboBox
      Left = 96
      Width = 391
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 495
      Top = 2
      Width = 22
    end
  end
  object BtSync: TButton
    Left = 349
    Top = 224
    Width = 115
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Prepare'
    TabOrder = 3
    OnClick = BtSyncClick
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 8
    Width = 519
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 4
    inherited Label1: TLabel
      Left = -1
      Width = 95
      Caption = 'Link info (*.xml,*txt) :'
    end
    inherited mbFileName: TComboBox
      Left = 96
      Width = 391
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 495
    end
    inherited OpenDialog: TOpenDialog
      Left = 189
    end
    inherited OpenPictureDialog: TOpenPictureDialog
      Left = 218
    end
    inherited FilePopupMenu: TPopupMenu
      Left = 249
    end
    inherited FNameActList: TActionList
      Left = 278
    end
  end
  object GBAll: TGroupBox
    Left = 16
    Top = 89
    Width = 517
    Height = 129
    Anchors = [akLeft, akBottom]
    Caption = '  Data unload flags  '
    TabOrder = 5
    object LbPatients: TLabel
      Left = 22
      Top = 50
      Width = 75
      Height = 13
      Caption = 'Unload Patients'
    end
    object LbProviders: TLabel
      Left = 22
      Top = 74
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
      Left = 22
      Top = 98
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
    object ChBUnloadPat: TCheckBox
      Left = 142
      Top = 50
      Width = 15
      Height = 17
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object ChBUnloadProv: TCheckBox
      Left = 142
      Top = 74
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
      Left = 142
      Top = 98
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
  end
  object DTPFrom: TDateTimePicker
    Left = 128
    Top = 65
    Width = 99
    Height = 21
    Date = 39542.430481226850000000
    Format = 'dd/MM/yyyy'
    Time = 39542.430481226850000000
    ShowCheckbox = True
    Checked = False
    Color = 10682367
    TabOrder = 6
    Visible = False
    OnChange = DTPFromChange
  end
  object ChBCheckFS: TCheckBox
    Left = 378
    Top = 70
    Width = 163
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Comprehensive data analysis'
    TabOrder = 7
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 320
    Top = 224
  end
end
