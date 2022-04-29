object N_ColorViewFrame: TN_ColorViewFrame
  Left = 0
  Top = 0
  Width = 237
  Height = 28
  TabOrder = 0
  object Label1: TLabel
    Left = 4
    Top = 6
    Width = 30
    Height = 13
    Caption = 'Color :'
  end
  object edHexColor: TEdit
    Left = 82
    Top = 3
    Width = 57
    Height = 21
    Hint = 'Hex Color ($BBGGRR)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    Text = ' $FFFFFF'
    OnDblClick = edHexColorDblClick
    OnKeyDown = edHexColorKeyDown
  end
  object edDecColor: TEdit
    Left = 144
    Top = 3
    Width = 89
    Height = 21
    Hint = 'Decimal 0-255 Color (Blue, Green Red)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Text = ' 255  255  255'
    OnKeyDown = edDecColorKeyDown
  end
  object edBackColor: TEdit
    Left = 39
    Top = 3
    Width = 38
    Height = 21
    ReadOnly = True
    TabOrder = 2
    OnDblClick = edBackColorDblClick
  end
end
