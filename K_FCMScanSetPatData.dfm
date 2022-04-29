inherited K_FormCMScanSetPatData: TK_FormCMScanSetPatData
  Left = 335
  Top = 312
  Width = 307
  Height = 149
  BorderIcons = [biSystemMenu]
  Caption = 'Patient details'
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 287
    Top = 103
  end
  object BtOK: TButton
    Left = 155
    Top = 83
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object LbESurname: TLabeledEdit
    Left = 88
    Top = 16
    Width = 203
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 69
    EditLabel.Height = 13
    EditLabel.Caption = 'Surname         '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 2
  end
  object LbEFirstname: TLabeledEdit
    Left = 88
    Top = 48
    Width = 203
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 69
    EditLabel.Height = 13
    EditLabel.Caption = 'First name       '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 229
    Top = 83
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
