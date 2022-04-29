inherited K_FormCMDBRecovery: TK_FormCMDBRecovery
  Left = 489
  Top = 240
  Width = 292
  Height = 281
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Database recovery'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 272
    Top = 235
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 120
    Top = 16
    Width = 154
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 111
    EditLabel.Height = 13
    EditLabel.Caption = 'Media objects files:       '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDProcCount: TLabeledEdit
    Left = 120
    Top = 48
    Width = 154
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 110
    EditLabel.Height = 13
    EditLabel.Caption = 'Media objects in DB:    '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEDErrCount: TLabeledEdit
    Left = 120
    Top = 80
    Width = 154
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 109
    EditLabel.Height = 13
    EditLabel.Caption = 'Corrupted files:             '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object BtClose: TButton
    Left = 194
    Top = 192
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 4
  end
  object PBProgress: TProgressBar
    Left = 8
    Top = 161
    Width = 264
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 5
  end
  object BtStart: TButton
    Left = 106
    Top = 192
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 6
    OnClick = BtStartClick
  end
  object BtReport: TButton
    Left = 18
    Top = 192
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Report'
    TabOrder = 7
    OnClick = BtReportClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 223
    Width = 276
    Height = 19
    Panels = <>
  end
  object ChBAddDuplicated: TCheckBox
    Left = 8
    Top = 112
    Width = 265
    Height = 17
    Hint = 
      'Files with duplicated identifiers will be recovered with new ide' +
      'ntifier'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Recover duplicated as new'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object ChBShowWarning: TCheckBox
    Left = 8
    Top = 136
    Width = 265
    Height = 17
    Hint = 'Show bad file structure warnings'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Show bad file structure warnings'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
  end
  object FlistTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = FlistTimerTimer
    Left = 8
    Top = 65528
  end
end
