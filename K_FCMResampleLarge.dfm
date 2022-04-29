inherited K_FormCMResampleLarge: TK_FormCMResampleLarge
  Left = 213
  Top = 344
  Width = 291
  Height = 296
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Check image files size'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 273
    Top = 252
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 139
    Top = 40
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 128
    EditLabel.Height = 13
    EditLabel.Caption = 'Total media objects:           '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDProcCount: TLabeledEdit
    Left = 139
    Top = 72
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 127
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed media objects:  '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEDURCount: TLabeledEdit
    Left = 139
    Top = 136
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 128
    EditLabel.Height = 13
    EditLabel.Caption = 'Unresampled:                     '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object BtClose: TButton
    Left = 193
    Top = 207
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 4
  end
  object PBProgress: TProgressBar
    Left = 10
    Top = 175
    Width = 263
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 5
  end
  object BtStart: TButton
    Left = 105
    Top = 207
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 6
    OnClick = BtStartClick
  end
  object BtReport: TButton
    Left = 17
    Top = 207
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Report'
    TabOrder = 7
    OnClick = BtReportClick
  end
  object ChBOnlyUnresampled: TCheckBox
    Left = 8
    Top = 15
    Width = 265
    Height = 17
    Caption = 'Process unresampled images only'
    TabOrder = 8
  end
  object LbEDLICount: TLabeledEdit
    Left = 139
    Top = 104
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 126
    EditLabel.Height = 13
    EditLabel.Caption = 'Large:                                '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 9
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 238
    Width = 275
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
