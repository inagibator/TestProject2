inherited K_FormCMFSDump1: TK_FormCMFSDump1
  Left = 391
  Top = 192
  Width = 395
  Height = 264
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Files Storage Dump'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 375
    Top = 221
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
    Top = 175
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
    Top = 175
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Start'
    TabOrder = 6
    OnClick = BtStartClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 206
    Width = 379
    Height = 19
    Panels = <>
  end
  object ChBFileNamesOnly: TCheckBox
    Left = 8
    Top = 176
    Width = 137
    Height = 17
    Caption = 'Dump File Names Only'
    TabOrder = 8
  end
  object RGContent: TRadioGroup
    Left = 8
    Top = 135
    Width = 365
    Height = 33
    Caption = '  Dump content  '
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'both'
      'existed only'
      'needed only')
    TabOrder = 9
  end
  object SaveDialog: TSaveDialog
    FilterIndex = 0
    Left = 160
    Top = 176
  end
end
