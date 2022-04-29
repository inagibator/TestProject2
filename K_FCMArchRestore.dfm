inherited K_FormCMArchRestore: TK_FormCMArchRestore
  Left = 321
  Top = 324
  Width = 390
  Height = 394
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Media Objects Restoring from archive'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 299
    Width = 366
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 371
    Top = 352
  end
  object BtClose: TButton
    Left = 300
    Top = 321
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object BtStart: TButton
    Left = 217
    Top = 321
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
    Width = 371
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DB media objects  '
    TabOrder = 3
    DesignSize = (
      371
      49)
    object LbEMCountDB: TLabeledEdit
      Left = 40
      Top = 16
      Width = 95
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 33
      EditLabel.Height = 13
      EditLabel.Caption = 'Total:  '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object LbEMCountArchived: TLabeledEdit
      Left = 246
      Top = 16
      Width = 113
      Height = 21
      Anchors = [akTop, akRight]
      EditLabel.Width = 89
      EditLabel.Height = 13
      EditLabel.Caption = 'Archived (Queue): '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
      Text = '0 (0)'
    end
  end
  object GBRestoringAttrs: TGroupBox
    Left = 4
    Top = 96
    Width = 371
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Archive restoring attributes  '
    TabOrder = 4
    DesignSize = (
      371
      105)
    object LbEMCountToBeRestored: TLabeledEdit
      Left = 207
      Top = 68
      Width = 156
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 191
      EditLabel.Height = 13
      EditLabel.Caption = 'To be restored media objects:                 '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
    end
    object RGArchRest: TRadioGroup
      Left = 8
      Top = 16
      Width = 355
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      Caption = '  Restore mode  '
      Columns = 2
      Items.Strings = (
        'All'
        'Queue ')
      TabOrder = 1
      OnClick = RGArchRestClick
    end
  end
  inline FPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 0
    Top = 64
    Width = 375
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
      Width = 268
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 350
      Top = 2
    end
  end
  object GBRestoring: TGroupBox
    Left = 4
    Top = 212
    Width = 371
    Height = 77
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Restoring progress  '
    TabOrder = 6
    DesignSize = (
      371
      77)
    object LbEDProcCount: TLabeledEdit
      Left = 160
      Top = 20
      Width = 202
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
      Width = 352
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Smooth = True
      TabOrder = 1
    end
  end
  object BtRecoverLink: TButton
    Left = 57
    Top = 321
    Width = 150
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Recover the link to the DB'
    Enabled = False
    TabOrder = 7
    OnClick = BtRecoverLinkClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 8
    Top = 320
  end
end
