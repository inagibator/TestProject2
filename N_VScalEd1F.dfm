inherited N_VScalEd1Form: TN_VScalEd1Form
  Left = 248
  Top = 315
  Width = 123
  Height = 185
  Caption = 'N_VScalEd1Form'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited bnOK: TButton
    Left = 65
    Top = 100
    TabOrder = 8
  end
  inherited bnCancel: TButton
    Left = 8
    Top = 100
    TabOrder = 9
  end
  inherited bnApply: TButton
    Left = 65
    Top = 125
    TabOrder = 10
  end
  inherited bnUndo: TButton
    Top = 125
    TabOrder = 11
  end
  object bnIncBig: TButton [4]
    Tag = 40
    Left = 86
    Top = 31
    Width = 24
    Height = 21
    Caption = '>>'
    TabOrder = 0
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnIncSmall: TButton [5]
    Tag = 30
    Left = 60
    Top = 31
    Width = 24
    Height = 21
    Caption = '>'
    TabOrder = 1
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnDecSmall: TButton [6]
    Tag = 20
    Left = 30
    Top = 31
    Width = 24
    Height = 21
    Caption = '<'
    TabOrder = 2
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnDecBig: TButton [7]
    Tag = 10
    Left = 4
    Top = 31
    Width = 24
    Height = 21
    Caption = '<<'
    TabOrder = 3
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object edValue: TEdit [8]
    Tag = 50
    Left = 5
    Top = 5
    Width = 63
    Height = 21
    TabOrder = 4
    Text = 'edValue'
    OnKeyDown = mbKeyDown
  end
  object mbNumDigits: TComboBox [9]
    Tag = 60
    Left = 74
    Top = 6
    Width = 36
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    Text = '10'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValStep: TComboBox [10]
    Tag = 70
    Left = 4
    Top = 57
    Width = 62
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Text = ' 0.05%'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValMultCoef: TComboBox [11]
    Tag = 80
    Left = 69
    Top = 57
    Width = 42
    Height = 21
    ItemHeight = 13
    TabOrder = 7
    Text = '10'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  inherited cbApplyToAll: TCheckBox
    Left = 4
    Top = 80
    TabOrder = 12
  end
  inherited cbApplyDelta: TCheckBox
    Left = 63
    Top = 79
    TabOrder = 13
  end
  inherited ButtonsTimer: TTimer
    Left = 68
  end
end
