object K_FrameCMSlideFilter: TK_FrameCMSlideFilter
  Left = 0
  Top = 0
  Width = 246
  Height = 21
  TabOrder = 0
  DesignSize = (
    246
    21)
  object CmBFilterAttrs: TComboBox
    Left = 0
    Top = 0
    Width = 246
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 30
    ItemHeight = 13
    TabOrder = 0
    OnChange = CmBFilterAttrsChange
  end
end
