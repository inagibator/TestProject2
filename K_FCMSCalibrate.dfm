inherited K_FormCMSCalibrate: TK_FormCMSCalibrate
  Left = 234
  Top = 358
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '_   Enter length of the Poly Line'
  ClientWidth = 277
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbUnit: TLabel [0]
    Left = 141
    Top = 20
    Width = 24
    Height = 13
    Caption = 'Units'
  end
  inherited BFMinBRPanel: TPanel
    Left = 267
    Top = 71
    TabOrder = 4
  end
  object LbEdit: TLabeledEdit
    Left = 60
    Top = 16
    Width = 57
    Height = 21
    Color = 10682367
    EditLabel.Width = 42
    EditLabel.Height = 13
    EditLabel.Caption = 'Length   '
    LabelPosition = lpLeft
    TabOrder = 0
    OnKeyDown = LbEditKeyDown
  end
  object BtCancel: TButton
    Left = 186
    Top = 50
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 96
    Top = 50
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 2
    OnClick = BtOKClick
  end
  object CmBUnits: TComboBox
    Left = 179
    Top = 16
    Width = 83
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 3
    OnChange = CmBUnitsChange
  end
end
