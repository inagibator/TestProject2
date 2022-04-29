inherited K_FormCMSASetLocationData: TK_FormCMSASetLocationData
  Left = 121
  Top = 246
  Width = 435
  Height = 149
  Caption = 'New Practice'
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 415
    Top = 103
  end
  object BtCancel: TButton
    Left = 352
    Top = 83
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 275
    Top = 83
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
  object LbETitle: TLabeledEdit
    Left = 122
    Top = 16
    Width = 297
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 107
    EditLabel.Height = 13
    EditLabel.Caption = 'Practice name             '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 3
  end
  object LbERefN: TLabeledEdit
    Left = 122
    Top = 48
    Width = 297
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 106
    EditLabel.Height = 13
    EditLabel.Caption = 'Practice reference #   '
    LabelPosition = lpLeft
    MaxLength = 10
    TabOrder = 4
  end
end
