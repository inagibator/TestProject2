inherited N_VRectEd1Form: TN_VRectEd1Form
  Left = 60
  Top = 652
  Width = 287
  Height = 288
  Caption = 'N_VRectEd1Form'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 3
    Top = 35
    Width = 22
    Height = 13
    Caption = 'X1 : '
  end
  object Label2: TLabel [1]
    Left = 94
    Top = 35
    Width = 22
    Height = 13
    Caption = 'X2 : '
  end
  object Label3: TLabel [2]
    Left = 175
    Top = 11
    Width = 57
    Height = 13
    Caption = 'Num.Digits :'
  end
  object Label4: TLabel [3]
    Left = 181
    Top = 64
    Width = 51
    Height = 13
    Caption = 'Mult.Coef :'
  end
  object Label5: TLabel [4]
    Left = 182
    Top = 36
    Width = 28
    Height = 13
    Caption = 'Step :'
  end
  object Label6: TLabel [5]
    Left = 51
    Top = 62
    Width = 22
    Height = 13
    Caption = 'Y2 : '
  end
  object Label7: TLabel [6]
    Left = 51
    Top = 9
    Width = 22
    Height = 13
    Caption = 'Y1 : '
  end
  inherited bnOK: TButton
    Left = 223
    Top = 224
    TabOrder = 4
  end
  inherited bnCancel: TButton
    Left = 174
    Top = 224
    TabOrder = 5
  end
  inherited bnApply: TButton
    Left = 126
    Top = 224
    TabOrder = 6
  end
  inherited bnUndo: TButton
    Left = 78
    Top = 224
    TabOrder = 7
  end
  object edValueX1: TEdit [11]
    Tag = 50
    Left = 24
    Top = 32
    Width = 63
    Height = 21
    TabOrder = 0
    OnKeyDown = mbKeyDown
  end
  object mbNumDigits: TComboBox [12]
    Tag = 60
    Left = 234
    Top = 8
    Width = 40
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValStep: TComboBox [13]
    Tag = 70
    Left = 212
    Top = 34
    Width = 62
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object mbValMultCoef: TComboBox [14]
    Tag = 80
    Left = 234
    Top = 60
    Width = 40
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    OnCloseUp = mbCloseUp
    OnKeyDown = mbKeyDown
  end
  object edValueX2: TEdit [15]
    Tag = 52
    Left = 115
    Top = 32
    Width = 63
    Height = 21
    TabOrder = 8
    OnKeyDown = mbKeyDown
  end
  object gbX1Y1: TGroupBox [16]
    Left = 14
    Top = 90
    Width = 119
    Height = 97
    Caption = '  X1,Y1  '
    TabOrder = 9
    object bnIncBigX: TButton
      Tag = 40
      Left = 86
      Top = 43
      Width = 24
      Height = 21
      Caption = '>>'
      TabOrder = 0
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnIncSmallX: TButton
      Tag = 30
      Left = 34
      Top = 43
      Width = 24
      Height = 21
      Caption = '>'
      TabOrder = 1
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnDecSmallX: TButton
      Tag = 20
      Left = 8
      Top = 43
      Width = 24
      Height = 21
      Caption = '<'
      TabOrder = 2
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnDecBigX: TButton
      Tag = 10
      Left = 60
      Top = 43
      Width = 24
      Height = 21
      Caption = '<<'
      TabOrder = 3
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnIncSmallY: TButton
      Tag = 31
      Left = 21
      Top = 68
      Width = 24
      Height = 21
      Caption = 'v'
      TabOrder = 4
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnIncBigY: TButton
      Tag = 41
      Left = 73
      Top = 68
      Width = 24
      Height = 21
      Caption = 'vv'
      TabOrder = 5
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnDecSmallY: TButton
      Tag = 21
      Left = 21
      Top = 18
      Width = 24
      Height = 21
      Caption = '^'
      TabOrder = 6
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object bnDecBigY: TButton
      Tag = 11
      Left = 73
      Top = 18
      Width = 24
      Height = 21
      Caption = '^^'
      TabOrder = 7
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
  end
  object gbX2Y2: TGroupBox [17]
    Left = 143
    Top = 91
    Width = 119
    Height = 97
    Caption = '  X2,Y2  '
    TabOrder = 10
    object Button1: TButton
      Tag = 42
      Left = 87
      Top = 43
      Width = 24
      Height = 21
      Caption = '>>'
      TabOrder = 0
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button2: TButton
      Tag = 32
      Left = 34
      Top = 43
      Width = 24
      Height = 21
      Caption = '>'
      TabOrder = 1
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button3: TButton
      Tag = 22
      Left = 8
      Top = 43
      Width = 24
      Height = 21
      Caption = '<'
      TabOrder = 2
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button4: TButton
      Tag = 12
      Left = 60
      Top = 43
      Width = 24
      Height = 21
      Caption = '<<'
      TabOrder = 3
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button5: TButton
      Tag = 33
      Left = 21
      Top = 68
      Width = 24
      Height = 21
      Caption = 'v'
      TabOrder = 4
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button6: TButton
      Tag = 43
      Left = 73
      Top = 68
      Width = 24
      Height = 21
      Caption = 'vv'
      TabOrder = 5
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button7: TButton
      Tag = 23
      Left = 21
      Top = 18
      Width = 24
      Height = 21
      Caption = '^'
      TabOrder = 6
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
    object Button8: TButton
      Tag = 13
      Left = 73
      Top = 18
      Width = 24
      Height = 21
      Caption = '^^'
      TabOrder = 7
      OnMouseDown = bnMouseDown
      OnMouseUp = bnMouseUp
    end
  end
  object edValueY2: TEdit [18]
    Tag = 53
    Left = 71
    Top = 59
    Width = 63
    Height = 21
    TabOrder = 11
    OnKeyDown = mbKeyDown
  end
  object edValueY1: TEdit [19]
    Tag = 51
    Left = 71
    Top = 6
    Width = 63
    Height = 21
    TabOrder = 12
    OnKeyDown = mbKeyDown
  end
  object cbShift: TCheckBox [20]
    Left = 11
    Top = 230
    Width = 47
    Height = 17
    Caption = 'Shift'
    TabOrder = 13
    OnClick = cbShiftClick
  end
  object cbAspect: TCheckBox [21]
    Left = 155
    Top = 198
    Width = 58
    Height = 17
    Caption = 'Aspect : '
    TabOrder = 14
    OnClick = cbAspectClick
  end
  object edAspect: TEdit [22]
    Left = 214
    Top = 196
    Width = 51
    Height = 21
    TabOrder = 15
    OnKeyDown = edAspectKeyDown
  end
  object bnSetFP: TButton [23]
    Left = 95
    Top = 197
    Width = 42
    Height = 21
    Caption = 'Set FP'
    TabOrder = 16
    OnClick = bnSetFPClick
  end
  inherited cbApplyToAll: TCheckBox
    Left = 11
    Top = 193
    TabOrder = 17
  end
  inherited cbApplyDelta: TCheckBox
    Left = 11
    Top = 212
    TabOrder = 18
  end
  inherited ButtonsTimer: TTimer
    Left = 142
    Top = 6
  end
end
