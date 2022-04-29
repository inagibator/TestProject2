inherited K_FormCMArchSave: TK_FormCMArchSave
  Left = 172
  Top = 472
  Width = 454
  Height = 427
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Media Objects Archiving'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 332
    Width = 425
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 435
    Top = 385
  end
  object BtClose: TButton
    Left = 364
    Top = 354
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object BtStart: TButton
    Left = 278
    Top = 354
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 2
    OnClick = BtStartClick
  end
  object GBDBState: TGroupBox
    Left = 4
    Top = 8
    Width = 436
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DB media objects  '
    TabOrder = 3
    DesignSize = (
      436
      81)
    object LbEMCountDB: TLabeledEdit
      Left = 168
      Top = 16
      Width = 254
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 158
      EditLabel.Height = 13
      EditLabel.Caption = 'Total number:                               '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object LbEMCountArchived: TLabeledEdit
      Left = 167
      Top = 48
      Width = 255
      Height = 21
      Anchors = [akTop, akRight]
      EditLabel.Width = 156
      EditLabel.Height = 13
      EditLabel.Caption = 'Archived (with non-deleted files): '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
      Text = '0 (0)'
    end
  end
  object GBArchivingAttrs: TGroupBox
    Left = 4
    Top = 128
    Width = 436
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Archiving attributes  '
    TabOrder = 4
    DesignSize = (
      436
      105)
    object LbCopyMedia: TLabel
      Left = 12
      Top = 48
      Width = 179
      Height = 13
      Caption = 'Archiving media objects maximal date:'
    end
    object LbEMCountToBeArchived: TLabeledEdit
      Left = 207
      Top = 16
      Width = 221
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 194
      EditLabel.Height = 13
      EditLabel.Caption = 'To be archived media objects:                 '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = '0'
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
    object ChBArchVideo: TCheckBox
      Left = 12
      Top = 76
      Width = 121
      Height = 17
      Caption = 'Archive video objects'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = ChBArchVideoClick
    end
    object ChBArchImg3D: TCheckBox
      Left = 206
      Top = 76
      Width = 113
      Height = 15
      Caption = 'Archive 3D objects'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = ChBArchVideoClick
    end
  end
  inline FPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 0
    Top = 96
    Width = 440
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    inherited LbPathName: TLabel
      Left = 13
      Width = 63
      Caption = 'Archive path:'
    end
    inherited mbPathName: TComboBox
      Left = 80
      Width = 333
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 415
      Top = 2
    end
  end
  object GBArchiving: TGroupBox
    Left = 4
    Top = 244
    Width = 436
    Height = 77
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Archiving progress  '
    TabOrder = 6
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
  object BtDeleteFiles: TButton
    Left = 120
    Top = 354
    Width = 146
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Delete non-deleted files'
    TabOrder = 7
    OnClick = BtDeleteFilesClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 16
    Top = 360
  end
end
