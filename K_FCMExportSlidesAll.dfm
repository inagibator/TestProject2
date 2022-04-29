inherited K_FormCMExportSlidesAll: TK_FormCMExportSlidesAll
  Left = 307
  Top = 478
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Media Objects Exporting'
  ClientHeight = 414
  ClientWidth = 438
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  ExplicitWidth = 454
  ExplicitHeight = 453
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 356
    Width = 425
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 435
    Top = 411
    ExplicitLeft = 435
    ExplicitTop = 411
  end
  object BtClose: TButton
    Left = 364
    Top = 380
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object BtStart: TButton
    Left = 278
    Top = 380
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
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DB media objects  '
    TabOrder = 3
    DesignSize = (
      436
      49)
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
  end
  object GBArchivingAttrs: TGroupBox
    Left = 4
    Top = 96
    Width = 436
    Height = 169
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Export attributes  '
    TabOrder = 4
    DesignSize = (
      436
      169)
    object LbEMCountToBeExported: TLabeledEdit
      Left = 207
      Top = 16
      Width = 221
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 194
      EditLabel.Height = 13
      EditLabel.Caption = 'To be exported media objects:                 '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
    end
    object GBFormat: TGroupBox
      Left = 203
      Top = 45
      Width = 150
      Height = 116
      Caption = '  Export Image file(s) format  '
      TabOrder = 1
      object RBJPEG: TRadioButton
        Tag = 1
        Left = 16
        Top = 36
        Width = 73
        Height = 17
        Caption = 'JPEG'
        TabOrder = 0
        OnClick = RBBMPClick
      end
      object RBBMP: TRadioButton
        Left = 17
        Top = 16
        Width = 72
        Height = 17
        Caption = 'BMP'
        TabOrder = 1
        OnClick = RBBMPClick
      end
      object RBPNG: TRadioButton
        Tag = 2
        Left = 16
        Top = 56
        Width = 73
        Height = 17
        Caption = 'PNG'
        TabOrder = 2
        OnClick = RBBMPClick
      end
      object RBDICOMDIR: TRadioButton
        Tag = 5
        Left = 16
        Top = 120
        Width = 113
        Height = 17
        Caption = 'DICOMDIR'
        TabOrder = 3
      end
    end
    object GBFtypes: TGroupBox
      Left = 11
      Top = 45
      Width = 142
      Height = 116
      Caption = '  Export Image file(s) type  '
      TabOrder = 2
      object RBMod: TRadioButton
        Tag = 1
        Left = 8
        Top = 36
        Width = 73
        Height = 17
        Caption = 'Modified'
        TabOrder = 0
        OnClick = RBOrigClick
      end
      object RBOrig: TRadioButton
        Left = 9
        Top = 16
        Width = 72
        Height = 17
        Caption = 'Original'
        TabOrder = 1
        OnClick = RBOrigClick
      end
      object RBOrigMod: TRadioButton
        Tag = 2
        Left = 8
        Top = 56
        Width = 121
        Height = 17
        Caption = 'Original and Modified'
        TabOrder = 2
        OnClick = RBOrigClick
      end
      object RadioButton5: TRadioButton
        Tag = 5
        Left = 16
        Top = 120
        Width = 113
        Height = 17
        Caption = 'DICOMDIR'
        TabOrder = 3
      end
      object ChBDate: TCheckBox
        Left = 9
        Top = 91
        Width = 121
        Height = 17
        Caption = 'Create date folders'
        TabOrder = 4
        OnClick = ChBAnnotClick
      end
      object ChBAnnot: TCheckBox
        Left = 9
        Top = 74
        Width = 121
        Height = 17
        Caption = 'Include annotations'
        TabOrder = 5
        OnClick = ChBAnnotClick
      end
    end
  end
  inline FPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 0
    Top = 64
    Width = 440
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    ExplicitTop = 64
    ExplicitWidth = 440
    ExplicitHeight = 27
    inherited LbPathName: TLabel
      Width = 69
      Caption = 'Export path:    '
      ExplicitWidth = 69
    end
    inherited mbPathName: TComboBox
      Left = 80
      Width = 333
      Color = 10682367
      ExplicitLeft = 80
      ExplicitWidth = 333
    end
    inherited bnBrowse_1: TButton
      Left = 415
      Top = 2
      ExplicitLeft = 415
      ExplicitTop = 2
    end
  end
  object GBArchiving: TGroupBox
    Left = 4
    Top = 268
    Width = 436
    Height = 77
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Export progress  '
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
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 16
    Top = 376
  end
end
