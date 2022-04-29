inherited K_FormCMRepairSlidesAttrs1: TK_FormCMRepairSlidesAttrs1
  Left = 213
  Top = 344
  Width = 291
  Height = 197
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Repair attributes'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 273
    Top = 153
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 139
    Top = 8
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
    Top = 40
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
  object BtClose: TButton
    Left = 193
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 3
  end
  object PBProgress: TProgressBar
    Left = 10
    Top = 76
    Width = 258
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 4
  end
  object BtStart: TButton
    Left = 105
    Top = 108
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 5
    OnClick = BtStartClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 139
    Width = 275
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
