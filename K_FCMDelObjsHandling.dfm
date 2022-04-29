inherited K_FormCMDelObjsHandling: TK_FormCMDelObjsHandling
  Left = 411
  Top = 435
  BorderStyle = bsSingle
  Caption = 'Deleted objects'
  ClientHeight = 116
  ClientWidth = 190
  PixelsPerInch = 96
  TextHeight = 13
  object LbKeepDelObjs: TLabel [0]
    Left = 16
    Top = 8
    Width = 103
    Height = 13
    Caption = 'Keep deleted objects:'
  end
  object LbMonth: TLabel [1]
    Left = 112
    Top = 56
    Width = 34
    Height = 13
    Caption = 'months'
  end
  inherited BFMinBRPanel: TPanel
    Left = 180
    Top = 106
    TabOrder = 6
  end
  object RBForEver: TRadioButton
    Left = 16
    Top = 32
    Width = 65
    Height = 17
    Caption = 'for ever'
    TabOrder = 0
    OnClick = RBForEverClick
  end
  object RBFor: TRadioButton
    Left = 16
    Top = 56
    Width = 41
    Height = 17
    Caption = 'for'
    Checked = True
    TabOrder = 1
    TabStop = True
    OnClick = RBForEverClick
  end
  object EdMonthCount: TEdit
    Left = 56
    Top = 54
    Width = 33
    Height = 21
    ReadOnly = True
    TabOrder = 2
    Text = '6'
  end
  object UpDown: TUpDown
    Left = 89
    Top = 54
    Width = 16
    Height = 21
    Associate = EdMonthCount
    Min = 1
    Max = 120
    Position = 6
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 101
    Top = 85
    Width = 72
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object BtOK: TButton
    Left = 21
    Top = 85
    Width = 72
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 5
  end
end
