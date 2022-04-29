object K_FPathNameFrame: TK_FPathNameFrame
  Tag = 161
  Left = 0
  Top = 0
  Width = 262
  Height = 24
  TabOrder = 0
  DesignSize = (
    262
    24)
  object LbPathName: TLabel
    Left = 7
    Top = 6
    Width = 28
    Height = 13
    Alignment = taRightJustify
    Caption = 'Path :'
  end
  object mbPathName: TComboBox
    Left = 41
    Top = 3
    Width = 194
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnCloseUp = mbPathNameCloseUp
    OnKeyDown = mbPathNameKeyDown
  end
  object bnBrowse_1: TButton
    Left = 237
    Top = 3
    Width = 23
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = bnBrowse_1Click
  end
end
