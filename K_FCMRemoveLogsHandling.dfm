inherited K_FormCMRemoveLogsHandling: TK_FormCMRemoveLogsHandling
  Left = 411
  Top = 435
  BorderStyle = bsSingle
  Caption = #1050#1077#1077#1088' logs'
  ClientHeight = 68
  ClientWidth = 193
  PixelsPerInch = 96
  TextHeight = 13
  object LbKeepDelObjs: TLabel [0]
    Left = 16
    Top = 8
    Width = 65
    Height = 13
    Caption = 'Keep logs for '
  end
  object LbMonth: TLabel [1]
    Left = 144
    Top = 8
    Width = 34
    Height = 13
    Caption = 'months'
  end
  inherited BFMinBRPanel: TPanel
    Left = 183
    Top = 58
    TabOrder = 4
  end
  object EdMonthCount: TEdit
    Left = 88
    Top = 6
    Width = 33
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '1'
  end
  object UpDown: TUpDown
    Left = 121
    Top = 6
    Width = 16
    Height = 21
    Associate = EdMonthCount
    Min = 1
    Max = 120
    Position = 1
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 104
    Top = 37
    Width = 72
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 24
    Top = 37
    Width = 72
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
  end
end
