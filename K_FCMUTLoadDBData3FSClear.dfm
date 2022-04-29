inherited K_FormCMUTLoadDBData3FSClear: TK_FormCMUTLoadDBData3FSClear
  Left = 266
  Top = 390
  Width = 440
  Height = 170
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Undo copy files'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 414
    Top = 120
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 140
    Top = 8
    Width = 279
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 131
    EditLabel.Height = 13
    EditLabel.Caption = 'Total number:                      '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object BtClose: TButton
    Left = 342
    Top = 97
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 2
  end
  object PBProgress: TProgressBar
    Left = 7
    Top = 73
    Width = 411
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 3
  end
  object BtStart: TButton
    Left = 254
    Top = 97
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 4
    OnClick = BtStartClick
  end
  object LbEDDelCount: TLabeledEdit
    Left = 140
    Top = 40
    Width = 280
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 130
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed number:             '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 5
  end
end
