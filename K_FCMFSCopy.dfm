inherited K_FormCMFSCopy: TK_FormCMFSCopy
  Left = 172
  Top = 472
  Width = 457
  Height = 342
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Media Objects Files Copy'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 244
    Width = 425
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 438
    Top = 300
  end
  object BtClose: TButton
    Left = 364
    Top = 266
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object BtStart: TButton
    Left = 278
    Top = 266
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Resume'
    TabOrder = 2
    OnClick = BtStartClick
  end
  object GBCopyAttrs: TGroupBox
    Left = 4
    Top = 40
    Width = 436
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Copying attributes  '
    TabOrder = 3
    DesignSize = (
      436
      105)
    object LbCopyMedia: TLabel
      Left = 12
      Top = 48
      Width = 170
      Height = 13
      Caption = 'Copying media objects minimal date:'
    end
    object LbEMCountToBeCopied: TLabeledEdit
      Left = 207
      Top = 16
      Width = 221
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 194
      EditLabel.Height = 13
      EditLabel.Caption = 'To be copied media objects:                    '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
    end
    object DTPFrom: TDateTimePicker
      Left = 207
      Top = 44
      Width = 221
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      Color = 10682367
      TabOrder = 1
      OnChange = DTPFromChange
    end
    object ChBCopyVideo: TCheckBox
      Left = 12
      Top = 76
      Width = 121
      Height = 17
      Caption = 'Copy video objects'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = ChBCopyVideoClick
    end
    object ChBCopyImg3D: TCheckBox
      Left = 206
      Top = 76
      Width = 113
      Height = 15
      Caption = 'Copy 3D objects'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = ChBCopyVideoClick
    end
  end
  inline FPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 4
    Top = 8
    Width = 436
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    inherited LbPathName: TLabel
      Left = 9
      Width = 51
      Caption = 'Copy path:'
    end
    inherited mbPathName: TComboBox
      Left = 68
      Width = 337
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 411
      Top = 2
    end
  end
  object GBArchiving: TGroupBox
    Left = 4
    Top = 156
    Width = 436
    Height = 77
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Copying progress  '
    TabOrder = 5
    DesignSize = (
      436
      77)
    object LbEDProcCount: TLabeledEdit
      Left = 160
      Top = 20
      Width = 267
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 145
      EditLabel.Height = 13
      EditLabel.Caption = 'Processed media objects:        '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object PBProgress: TProgressBar
      Left = 10
      Top = 50
      Width = 417
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Smooth = True
      TabOrder = 1
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 16
    Top = 272
  end
end
