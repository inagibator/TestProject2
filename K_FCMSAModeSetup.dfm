inherited K_FormCMSAModeSetup: TK_FormCMSAModeSetup
  Left = 68
  Top = 336
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '   Alone Mode Setup'
  ClientWidth = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 228
    Top = 69
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 155
    Top = 46
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 65
    Top = 46
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object RBHybrid: TRadioButton
    Left = 11
    Top = 16
    Width = 62
    Height = 17
    Caption = 'Hybrid'
    TabOrder = 3
    OnClick = RBLinkClick
  end
  object RBLink: TRadioButton
    Left = 80
    Top = 16
    Width = 61
    Height = 17
    Caption = 'Link'
    TabOrder = 4
    OnClick = RBLinkClick
  end
  object RBIndependent: TRadioButton
    Left = 147
    Top = 16
    Width = 86
    Height = 17
    Caption = 'Independent'
    TabOrder = 5
    OnClick = RBLinkClick
  end
end
