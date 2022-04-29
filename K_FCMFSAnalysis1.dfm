inherited K_FormCMFSAnalysis1: TK_FormCMFSAnalysis1
  Left = 391
  Top = 192
  Width = 395
  Height = 258
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Files Storage analysis'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 375
    Top = 212
  end
  object LbEDFilesCount: TLabeledEdit
    Left = 132
    Top = 16
    Width = 241
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 121
    EditLabel.Height = 13
    EditLabel.Caption = 'Files Storage files:            '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDDBCount: TLabeledEdit
    Left = 132
    Top = 48
    Width = 241
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 122
    EditLabel.Height = 13
    EditLabel.Caption = 'All Media objects:             '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEDProcCount: TLabeledEdit
    Left = 132
    Top = 80
    Width = 241
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 122
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed Media objects:'
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object BtClose: TButton
    Left = 297
    Top = 169
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 4
  end
  object PBProgress: TProgressBar
    Left = 8
    Top = 113
    Width = 367
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 5
  end
  object BtStart: TButton
    Left = 209
    Top = 169
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Start'
    TabOrder = 6
    OnClick = BtStartClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 200
    Width = 379
    Height = 19
    Panels = <>
  end
  object ChBUsePrevious: TCheckBox
    Left = 8
    Top = 144
    Width = 369
    Height = 17
    Caption = 'Use previous results'
    TabOrder = 8
    Visible = False
  end
  object SaveDialog: TSaveDialog
    FilterIndex = 0
    Left = 8
    Top = 192
  end
end
