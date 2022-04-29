inherited K_FormSelectFromCombo: TK_FormSelectFromCombo
  Left = 238
  Top = 112
  Width = 437
  Height = 55
  Caption = 'K_FormSelectFromCombo'
  Constraints.MaxHeight = 55
  Constraints.MinHeight = 55
  OnShow = FormShow
  DesignSize = (
    429
    21)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 417
    Top = 9
    TabOrder = 1
  end
  object CmBList: TComboBox
    Left = 0
    Top = 0
    Width = 429
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnSelect = CmBListSelect
  end
end
