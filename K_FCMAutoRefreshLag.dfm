inherited K_FormCMAutoRefreshLag: TK_FormCMAutoRefreshLag
  Left = 595
  Top = 403
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Automatic Refresh'
  ClientWidth = 210
  FormStyle = fsStayOnTop
  PixelsPerInch = 96
  TextHeight = 13
  object LbSec: TLabel [0]
    Left = 159
    Top = 16
    Width = 19
    Height = 13
    Caption = 'Sec'
  end
  object LbTimer: TLabel [1]
    Left = 32
    Top = 16
    Width = 29
    Height = 13
    Caption = 'Timer:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 200
    Top = 66
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 113
    Top = 45
    Width = 66
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 31
    Top = 45
    Width = 64
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object CmBAutoRefreshLag: TComboBox
    Left = 98
    Top = 13
    Width = 53
    Height = 21
    Style = csDropDownList
    DropDownCount = 9
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      '    0'
      '    5'
      '  10'
      '  15'
      '  20'
      '  30'
      '  40'
      '  50'
      '  60')
  end
end
