inherited K_FormCMFSRecovery1: TK_FormCMFSRecovery1
  Left = 430
  Top = 340
  Width = 322
  Height = 233
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Files info dump'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 302
    Top = 187
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 72
    Top = 16
    Width = 232
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = 'All:             '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDErrCount: TLabeledEdit
    Left = 72
    Top = 80
    Width = 232
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'Errors:        '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object BtClose: TButton
    Left = 224
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 3
    OnClick = BtCloseClick
  end
  object PBProgress: TProgressBar
    Left = 10
    Top = 115
    Width = 294
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 4
  end
  object BtStart: TButton
    Left = 136
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Start'
    TabOrder = 5
    OnClick = BtStartClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 175
    Width = 306
    Height = 19
    Panels = <>
  end
  object LbEDProcCount: TLabeledEdit
    Left = 72
    Top = 48
    Width = 232
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed:'
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 7
  end
  object B1: TButton
    Left = 8
    Top = 144
    Width = 25
    Height = 25
    Caption = 'B1'
    TabOrder = 8
    OnClick = B1Click
  end
  object B2: TButton
    Left = 48
    Top = 144
    Width = 25
    Height = 25
    Caption = 'B2'
    TabOrder = 9
    OnClick = B2Click
  end
  object B3: TButton
    Left = 88
    Top = 144
    Width = 25
    Height = 25
    Caption = 'B3'
    TabOrder = 10
    OnClick = B3Click
  end
end
