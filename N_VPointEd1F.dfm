inherited N_VPointEd1Form: TN_VPointEd1Form
  Left = 39
  Top = 174
  Width = 213
  Height = 197
  Caption = 'N_VPointEd1Form'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 15
    Top = 8
    Width = 16
    Height = 13
    Caption = 'X : '
  end
  object Label2: TLabel [1]
    Left = 106
    Top = 8
    Width = 16
    Height = 13
    Caption = 'Y : '
  end
  object Label3: TLabel [2]
    Left = 104
    Top = 37
    Width = 57
    Height = 13
    Caption = 'Num.Digits :'
  end
  object Label4: TLabel [3]
    Left = 110
    Top = 90
    Width = 51
    Height = 13
    Caption = 'Mult.Coef :'
  end
  object Label5: TLabel [4]
    Left = 111
    Top = 62
    Width = 28
    Height = 13
    Caption = 'Step :'
  end
  inherited bnOK: TButton
    Left = 159
    Top = 135
    TabOrder = 8
  end
  inherited bnCancel: TButton
    Left = 110
    Top = 135
    TabOrder = 9
  end
  inherited bnApply: TButton
    Left = 62
    Top = 135
    TabOrder = 10
  end
  inherited bnUndo: TButton
    Left = 14
    Top = 135
    TabOrder = 11
  end
  object bnIncBigX: TButton [9]
    Tag = 40
    Left = 78
    Top = 60
    Width = 24
    Height = 21
    Caption = '>>'
    TabOrder = 0
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnIncSmallX: TButton [10]
    Tag = 30
    Left = 28
    Top = 60
    Width = 24
    Height = 21
    Caption = '>'
    TabOrder = 1
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnDecSmallX: TButton [11]
    Tag = 20
    Left = 3
    Top = 60
    Width = 24
    Height = 21
    Caption = '<'
    TabOrder = 2
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnDecBigX: TButton [12]
    Tag = 10
    Left = 53
    Top = 60
    Width = 24
    Height = 21
    Caption = '<<'
    TabOrder = 3
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object edValue: TEdit [13]
    Tag = 50
    Left = 30
    Top = 5
    Width = 63
    Height = 21
    TabOrder = 4
    Text = 'edValueX'
    OnKeyDown = mbKeyDown
  end
  object mbNumDigits: TComboBox [14]
    Tag = 60
    Left = 163
    Top = 34
    Width = 40
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    Text = '10'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValStep: TComboBox [15]
    Tag = 70
    Left = 141
    Top = 60
    Width = 62
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Text = ' 0.0002'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValMultCoef: TComboBox [16]
    Tag = 80
    Left = 163
    Top = 86
    Width = 40
    Height = 21
    ItemHeight = 13
    TabOrder = 7
    Text = '10'
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object bnDecSmallY: TButton [17]
    Tag = 21
    Left = 16
    Top = 35
    Width = 24
    Height = 21
    Caption = '^'
    TabOrder = 12
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnDecBigY: TButton [18]
    Tag = 11
    Left = 64
    Top = 35
    Width = 24
    Height = 21
    Caption = '^^'
    TabOrder = 13
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnIncSmallY: TButton [19]
    Tag = 31
    Left = 17
    Top = 85
    Width = 24
    Height = 21
    Caption = 'v'
    TabOrder = 14
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object bnIncBigY: TButton [20]
    Tag = 41
    Left = 64
    Top = 85
    Width = 24
    Height = 21
    Caption = 'vv'
    TabOrder = 15
    OnMouseDown = bnMouseDown
    OnMouseUp = bnMouseUp
  end
  object Edit1: TEdit [21]
    Tag = 51
    Left = 122
    Top = 5
    Width = 63
    Height = 21
    TabOrder = 16
    Text = 'edValueY'
    OnKeyDown = mbKeyDown
  end
  inherited cbApplyToAll: TCheckBox
    Left = 14
    Top = 113
    TabOrder = 17
  end
  inherited cbApplyDelta: TCheckBox
    Left = 77
    Top = 112
    TabOrder = 18
  end
  inherited ButtonsTimer: TTimer
    Left = 177
    Top = 101
  end
end
