inherited K_FormCMLinkCLFSetup: TK_FormCMLinkCLFSetup
  Left = 505
  Top = 233
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '   Link Setup'
  ClientHeight = 173
  ClientWidth = 239
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 229
    Top = 163
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 156
    Top = 142
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 66
    Top = 142
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object RBCL2000: TRadioButton
    Left = 11
    Top = 16
    Width = 160
    Height = 17
    Caption = 'Command Line CL2000'
    TabOrder = 3
    OnClick = RBVWClick
  end
  object RBVW: TRadioButton
    Left = 12
    Top = 40
    Width = 160
    Height = 17
    Caption = 'Command Line VW'
    TabOrder = 4
    OnClick = RBVWClick
  end
  object RBIni: TRadioButton
    Left = 12
    Top = 64
    Width = 160
    Height = 17
    Caption = 'Text file INI'
    TabOrder = 5
    OnClick = RBVWClick
  end
  object RBUDVW: TRadioButton
    Left = 12
    Top = 88
    Width = 160
    Height = 17
    Caption = 'User defined Command Line'
    TabOrder = 6
    OnClick = RBVWClick
  end
  object RBNone: TRadioButton
    Left = 12
    Top = 112
    Width = 160
    Height = 17
    Caption = 'None'
    TabOrder = 7
    OnClick = RBVWClick
  end
  object BtSetup: TButton
    Left = 178
    Top = 86
    Width = 55
    Height = 23
    Caption = 'Setup'
    TabOrder = 8
    OnClick = BtSetupClick
  end
end
