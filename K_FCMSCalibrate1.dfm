inherited K_FormCMSCalibrate1: TK_FormCMSCalibrate1
  Left = 370
  Top = 392
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '   Enter image resolution'
  ClientWidth = 217
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 207
    Top = 71
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 131
    Top = 50
    Width = 77
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 44
    Top = 50
    Width = 77
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = BtOKClick
  end
  object CmBUnits: TComboBox
    Left = 96
    Top = 16
    Width = 113
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ItemHeight = 13
    TabOrder = 2
    OnChange = CmBUnitsChange
    Items.Strings = (
      'Pixel size, '#181'm'
      '')
  end
  object LbEdit: TEdit
    Left = 20
    Top = 16
    Width = 57
    Height = 21
    Color = 10682367
    TabOrder = 4
  end
end
