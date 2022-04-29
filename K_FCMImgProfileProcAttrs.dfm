inherited K_FormCMImgProfileProcAttrs: TK_FormCMImgProfileProcAttrs
  Left = 211
  Top = 122
  ClientHeight = 750
  PixelsPerInch = 96
  TextHeight = 13
  inherited PnAll: TPanel
    Top = 26
  end
  inherited BFMinBRPanel: TPanel
    Top = 738
  end
  object ChBLoadFilter: TCheckBox
    Left = 19
    Top = 8
    Width = 230
    Height = 17
    Caption = 'Load Filter values'
    TabOrder = 2
    OnClick = ChBLoadFilterClick
  end
  object CmBFilters: TComboBox
    Left = 256
    Top = 8
    Width = 73
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    OnChange = CmBFiltersChange
    Items.Strings = (
      'None')
  end
end
