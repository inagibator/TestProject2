inherited K_FormCMCreateStudyFiles: TK_FormCMCreateStudyFiles
  Left = 216
  Top = 319
  Width = 291
  Height = 213
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Study Files Creation'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 273
    Top = 169
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 107
    Top = 8
    Width = 160
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 96
    EditLabel.Height = 13
    EditLabel.Caption = 'Total studies:           '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDProcCount: TLabeledEdit
    Left = 107
    Top = 40
    Width = 160
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 95
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed studies:  '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEDFilesCount: TLabeledEdit
    Left = 107
    Top = 72
    Width = 160
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 96
    EditLabel.Height = 13
    EditLabel.Caption = 'Files created:           '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object BtClose: TButton
    Left = 193
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 4
  end
  object PBProgress: TProgressBar
    Left = 10
    Top = 105
    Width = 263
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 5
  end
  object BtStart: TButton
    Left = 105
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 6
    OnClick = BtStartClick
  end
end
