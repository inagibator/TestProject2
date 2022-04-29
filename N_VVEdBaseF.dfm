object N_VVEdBaseForm: TN_VVEdBaseForm
  Left = 285
  Top = 674
  Width = 193
  Height = 161
  Caption = 'N_VVEdBaseForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object bnOK: TButton
    Left = 140
    Top = 102
    Width = 42
    Height = 21
    Caption = 'OK'
    TabOrder = 0
    OnClick = bnOKClick
  end
  object bnCancel: TButton
    Left = 96
    Top = 102
    Width = 42
    Height = 21
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = bnCancelClick
  end
  object bnApply: TButton
    Left = 52
    Top = 102
    Width = 42
    Height = 21
    Caption = 'Apply'
    TabOrder = 2
    OnClick = bnApplyClick
  end
  object bnUndo: TButton
    Left = 8
    Top = 102
    Width = 42
    Height = 21
    Caption = 'Undo'
    TabOrder = 3
    OnClick = bnUndoClick
  end
  object cbApplyToAll: TCheckBox
    Left = 59
    Top = 75
    Width = 47
    Height = 17
    Caption = 'To All'
    TabOrder = 4
  end
  object cbApplyDelta: TCheckBox
    Left = 113
    Top = 74
    Width = 49
    Height = 17
    Caption = 'Delta'
    TabOrder = 5
  end
  object ButtonsTimer: TTimer
    Interval = 0
    OnTimer = OnButtonsTimer
    Left = 75
    Top = 3
  end
end
